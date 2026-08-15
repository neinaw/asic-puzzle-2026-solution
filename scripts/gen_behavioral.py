#!/usr/bin/env python3
"""
Generate a plain-Verilog behavioral model for each Sky130 std-cell type used
in our extracted netlists, straight from the cell's Liberty description
(combinational `function` attributes, and `ff` group for flip-flops).

This turns our black-box gate netlist into a fully generic, technology-free
Verilog design that any simulator or formal tool (sby/yosys) can reason
about without any liberty/blackbox machinery.
"""
import re
import sys

LIB = "/home/ansh/.ciel/ciel/sky130/versions/8afc8346a57fe1ab7934ba5a6056ea8b43078e71/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

# Cells with no Liberty entry (pure physical/fill cells) or with pins that
# carry no logical function - hand-specified.
NO_OP_CELLS = {
    "sky130_fd_sc_hd__tapvpwrvgnd_1": ["VPWR", "VGND"],
    "sky130_fd_sc_hd__decap_3": ["VPWR", "VGND"],
    "sky130_fd_sc_hd__diode_2": ["DIODE", "VPWR", "VGND"],
    "sky130_fd_sc_hd__fill_1": ["VPWR", "VGND"],
    "sky130_fd_sc_hd__fill_2": ["VPWR", "VGND"]
}


def extract_cell_block(lib_text, cell_name):
    m = re.search(r'cell \("%s"\) \{' % re.escape(cell_name), lib_text)
    if not m:
        return None
    depth = 0
    i = m.end() - 1
    while True:
        if lib_text[i] == "{":
            depth += 1
        elif lib_text[i] == "}":
            depth -= 1
            if depth == 0:
                break
        i += 1
    return lib_text[m.start(): i + 1]


def parse_pins(block):
    """Return {pin_name: {'direction':..., 'function': str|None}}"""
    pins = {}
    for m in re.finditer(r'(?<!pg_)pin \("([^"]+)"\) \{', block):
        name = m.group(1)
        if name in ("VPWR", "VGND", "VPB", "VNB"):
            # power/well pins: not part of our interconnect-only extraction
            continue
        depth = 0
        i = m.end() - 1
        while True:
            if block[i] == "{":
                depth += 1
            elif block[i] == "}":
                depth -= 1
                if depth == 0:
                    break
            i += 1
        pin_block = block[m.end(): i]
        d = re.search(r'direction\s*:\s*"([^"]+)"', pin_block)
        f = re.search(r'\bfunction\s*:\s*"([^"]*)"', pin_block)
        pins[name] = {
            "direction": d.group(1) if d else None,
            "function": f.group(1) if f else None,
        }
    return pins


def parse_ff(block):
    m = re.search(r'ff \("([^"]+)"\s*,\s*"([^"]+)"\)\s*\{', block)
    if not m:
        return None
    depth = 0
    i = m.end() - 1
    while True:
        if block[i] == "{":
            depth += 1
        elif block[i] == "}":
            depth -= 1
            if depth == 0:
                break
        i += 1
    ff_block = block[m.end(): i]
    info = {"iq": m.group(1), "iqn": m.group(2)}
    for key in ("clocked_on", "next_state", "clear", "preset"):
        km = re.search(r'%s\s*:\s*"([^"]*)"' % key, ff_block)
        info[key] = km.group(1) if km else None
    return info


BOOL_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*|[&|!()]")


def lib_expr_to_verilog(expr):
    # Liberty boolean syntax (&, |, !, parens, bare identifiers) is already
    # valid as a Verilog boolean/bitwise expression over 1-bit signals.
    return expr.strip()


def gen_module(cell_type, lib_text):
    if cell_type in NO_OP_CELLS:
        ports = NO_OP_CELLS[cell_type]
        # A module with no cells/assigns at all gets auto-tagged `blackbox`
        # by Yosys, which then refuses to simulate it. Add a harmless
        # internal signal so the module has real (if useless) content.
        return f"module {cell_type} ({', '.join(ports)});\n" + \
            "".join(f"  input {p};\n" for p in ports if p != "DIODE") + \
            ("  input DIODE;\n" if "DIODE" in ports else "") + \
            f"  wire _unused = ^{{{', '.join(ports)}}};\n" + \
            "endmodule\n"

    block = extract_cell_block(lib_text, cell_type)
    if block is None:
        raise RuntimeError(f"cell {cell_type!r} not found in liberty")

    pins = parse_pins(block)
    ff = parse_ff(block)

    port_names = list(pins.keys()) + ["VPWR", "VGND"]
    lines = [f"module {cell_type} ({', '.join(port_names)});"]
    for name, info in pins.items():
        if info["direction"] == "input":
            lines.append(f"  input {name};")
        else:
            lines.append(f"  output reg {name};" if ff else f"  output {name};")
    lines.append("  input VPWR;")
    lines.append("  input VGND;")

    if ff:
        clk = ff["clocked_on"]
        nxt = lib_expr_to_verilog(ff["next_state"])
        clear = ff["clear"]
        preset = ff["preset"]
        # find which output pin(s) alias IQ / IQN
        q_pins = [n for n, info in pins.items()
                  if info["direction"] == "output" and info["function"] == ff["iq"]]
        qn_pins = [n for n, info in pins.items()
                   if info["direction"] == "output" and info["function"] == ff["iqn"]]

        if clear and preset:
            raise RuntimeError(f"{cell_type}: both clear and preset set, unsupported")

        if clear:
            # clear is an expression like "!RESET_B" - active level of the
            # expression means async clear to 0. We assume it is a bare
            # (possibly inverted) single signal, as is the case for all
            # sky130_fd_sc_hd__df*tp cells.
            m = re.match(r"^!(\w+)$", clear.strip())
            if m:
                rst_sig, rst_active = m.group(1), "0"
            else:
                m = re.match(r"^(\w+)$", clear.strip())
                rst_sig, rst_active = m.group(1), "1"
            edge = "negedge" if rst_active == "0" else "posedge"
            lines.append(f"  always @(posedge {clk} or {edge} {rst_sig})")
            lines.append(f"    if ({clear})")
            for qp in q_pins:
                lines.append(f"      {qp} <= 1'b0;")
            for qp in qn_pins:
                lines.append(f"      {qp} <= 1'b1;")
            lines.append("    else begin")
            for qp in q_pins:
                lines.append(f"      {qp} <= {nxt};")
            for qp in qn_pins:
                lines.append(f"      {qp} <= !({nxt});")
            lines.append("    end")
        elif preset:
            m = re.match(r"^!(\w+)$", preset.strip())
            if m:
                set_sig, set_active = m.group(1), "0"
            else:
                m = re.match(r"^(\w+)$", preset.strip())
                set_sig, set_active = m.group(1), "1"
            edge = "negedge" if set_active == "0" else "posedge"
            lines.append(f"  always @(posedge {clk} or {edge} {set_sig})")
            lines.append(f"    if ({preset})")
            for qp in q_pins:
                lines.append(f"      {qp} <= 1'b1;")
            for qp in qn_pins:
                lines.append(f"      {qp} <= 1'b0;")
            lines.append("    else begin")
            for qp in q_pins:
                lines.append(f"      {qp} <= {nxt};")
            for qp in qn_pins:
                lines.append(f"      {qp} <= !({nxt});")
            lines.append("    end")
        else:
            # No async clear/preset (e.g. dfxtp): give it a defined
            # power-on state instead of leaving Q as simulation 'x',
            # since nothing else in the design will ever force it.
            for qp in q_pins:
                lines.append(f"  initial {qp} = 1'b0;")
            for qp in qn_pins:
                lines.append(f"  initial {qp} = 1'b1;")
            lines.append(f"  always @(posedge {clk}) begin")
            for qp in q_pins:
                lines.append(f"      {qp} <= {nxt};")
            for qp in qn_pins:
                lines.append(f"      {qp} <= !({nxt});")
            lines.append("  end")
    else:
        for name, info in pins.items():
            if info["direction"] != "output":
                continue
            fn = info["function"]
            if fn is None:
                continue
            lines.append(f"  assign {name} = {lib_expr_to_verilog(fn)};")

    lines.append("endmodule")
    return "\n".join(lines) + "\n"


def main():
    cell_types = [l.strip() for l in sys.stdin if l.strip()]
    lib_text = open(LIB).read()
    out = []
    out.append("// Auto-generated behavioral models derived from Sky130 Liberty functions.")
    out.append('`default_nettype none')
    for ct in cell_types:
        out.append(gen_module(ct, lib_text))
    print("\n".join(out))


if __name__ == "__main__":
    main()

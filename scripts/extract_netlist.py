#!/usr/bin/env python3
"""
Extract a structural netlist from a Sky130 GDS by treating every standard-cell
instance as an opaque black box and tracing only the interconnect layers
(li1, met1-met5 and their vias) between them, using KLayout's LayoutToNetlist.

We deliberately do NOT connect poly/diffusion/licon/well layers, so KLayout
never "sees inside" a standard cell to do transistor-level extraction - each
cell's internal li1 pin shapes just show up as isolated islands, which
become that cell's pins automatically once something outside the cell
touches them. This gives a clean gate-level netlist without needing any
device/transistor recognition.

Layer numbers taken from the Sky130 KLayout LVS deck
(sky130A/libs.tech/klayout/lvs/sky130.lvs).
"""
import sys
import re
import argparse
import klayout.db as db

import gen_behavioral as genb

INTERCONNECT_LAYERS = [
    # (name, drawing (layer, datatype), pin/label (layer, datatype))
    ("li1", (67, 20), (67, 5)),
    ("met1", (68, 20), (68, 5)),
    ("met2", (69, 20), (69, 5)),
    ("met3", (70, 20), (70, 5)),
    ("met4", (71, 20), (71, 5)),
    ("met5", (72, 20), (72, 5)),
]

VIA_LAYERS = [
    # (name, (layer, datatype), lower interconnect name, upper interconnect name)
    ("mcon", (67, 44), "li1", "met1"),
    ("via1", (68, 44), "met1", "met2"),
    ("via2", (69, 44), "met2", "met3"),
    ("via3", (70, 44), "met3", "met4"),
    ("via4", (71, 44), "met4", "met5"),
]


def extract(gds_path, top_cell_name):
    layout = db.Layout()
    layout.read(gds_path)
    top_cell = layout.cell(layout.cell_by_name(top_cell_name))

    l2n = db.LayoutToNetlist(db.RecursiveShapeIterator(layout, top_cell, []))

    regions = {}
    label_regions = {}
    for name, ld, lp in INTERCONNECT_LAYERS:
        li = layout.layer(*ld)
        regions[name] = l2n.make_layer(li, name)
        ll = layout.layer(*lp)
        label_regions[name] = l2n.make_text_layer(ll, name + "_label")

    vias = {}
    for name, ld, _lo, _hi in VIA_LAYERS:
        li = layout.layer(*ld)
        vias[name] = l2n.make_layer(li, name)

    # intra-layer connectivity + label attachment (for net naming)
    for name, _, _ in INTERCONNECT_LAYERS:
        l2n.connect(regions[name])
        l2n.connect(regions[name], label_regions[name])

    # inter-layer connectivity through vias
    for name, _, lo, hi in VIA_LAYERS:
        l2n.connect(regions[lo], vias[name])
        l2n.connect(vias[name], regions[hi])

    l2n.extract_netlist()
    return l2n


SIMPLE_IDENT_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_$]*$")


def vname(name):
    """Render a name as a valid Verilog identifier, escaping it if needed."""
    if SIMPLE_IDENT_RE.match(name):
        return name
    return "\\" + name + " "


def classify_cells(cell_types):
    """For each cell type actually used in the design, decide whether it's:
    - a no-op (no output pins at all: power taps, decap, antenna diodes) -> drop
    - a pure identity buffer (one input, one output, function == that input,
      e.g. buf_*/clkbuf_* cells used for clock-tree fanout) -> alias away
    - anything else (real logic/flops) -> keep as-is

    Buffers are detected by function, not by name, so this also naturally
    catches any other single-input pass-through cell the library adds.
    """
    lib_text = open(genb.LIB).read()
    drop_types = set()
    buffer_types = {}  # cell_type -> (input_pin_name, output_pin_name)
    for ct in cell_types:
        if ct in genb.NO_OP_CELLS:
            drop_types.add(ct)
            continue
        block = genb.extract_cell_block(lib_text, ct)
        if block is None:
            continue
        pins = genb.parse_pins(block)
        if genb.parse_ff(block):
            continue
        inputs = [n for n, info in pins.items() if info["direction"] == "input"]
        outputs = [n for n, info in pins.items() if info["direction"] == "output"]
        if not outputs:
            drop_types.add(ct)
            continue
        if len(inputs) == 1 and len(outputs) == 1:
            fn = (pins[outputs[0]]["function"] or "").strip().strip("()").strip()
            if fn == inputs[0]:
                buffer_types[ct] = (inputs[0], outputs[0])
    return drop_types, buffer_types


def dump_verilog(l2n, top_cell_name, out_path):
    netlist = l2n.netlist()
    netlist.make_top_level_pins()
    top = netlist.circuit_by_name(top_cell_name)
    if top is None:
        raise RuntimeError(f"no circuit named {top_cell_name!r} in extracted netlist")

    def net_id(net):
        # stable-ish identifier for a net when it has no meaningful label
        return "n" + str(net.cluster_id)

    def net_name(net):
        nm = net.name
        if nm:
            return nm
        return net_id(net)

    port_names = []
    port_seen = set()
    for pin in top.each_pin():
        nm = pin.name()
        if nm and nm not in port_seen:
            port_seen.add(nm)
            port_names.append(nm)

    # Pass 1: materialize every subcircuit's raw pin->net connections, and
    # collect the set of cell types actually used so we only need to look
    # up Liberty info for those.
    raw_instances = []  # list of (cell_type, inst_name, {pin_name: raw_net_name})
    used_types = set()
    for sub in top.each_subcircuit():
        ref = sub.circuit_ref()
        cell_type = ref.name
        if not cell_type.startswith("sky130_fd_sc_hd__"):
            # power-strap via stacks etc: physical-only, not logic cells
            continue
        used_types.add(cell_type)
        inst_name = sub.name or f"{cell_type}_{sub.id()}"
        conns = {}
        for pin in ref.each_pin():
            net = sub.net_for_pin(pin.id())
            if net is None:
                continue
            pname = pin.name()
            if not pname:
                # Unnamed local net incidentally touched by routing (no text
                # label matched it) - real standard-cell pins are always
                # labeled, so this isn't a real port; skip it.
                print(
                    f"warning: dropping unnamed-pin connection on "
                    f"{cell_type} {inst_name} (net {net_name(net)!r})",
                    file=sys.stderr,
                )
                continue
            conns[pname] = net_name(net)
        raw_instances.append((cell_type, inst_name, conns))

    drop_types, buffer_types = classify_cells(used_types)

    # Pass 2: build a net-name alias map from every buffer instance's
    # output net to its input net, then resolve each alias transitively
    # (buffers chain, e.g. a clock tree) down to its ultimate driver.
    alias_raw = {}
    n_buffers = 0
    n_dropped = 0
    for cell_type, inst_name, conns in raw_instances:
        if cell_type in buffer_types:
            in_pin, out_pin = buffer_types[cell_type]
            if out_pin in conns and in_pin in conns:
                alias_raw[conns[out_pin]] = conns[in_pin]
                n_buffers += 1
            else:
                # buffer with a floating pin (e.g. unused/unrouted instance)
                # - nothing downstream to alias, just drop it below.
                n_dropped += 1
        elif cell_type in drop_types:
            n_dropped += 1

    resolved_cache = {}

    def resolve(name):
        if name in resolved_cache:
            return resolved_cache[name]
        seen_chain = set()
        cur = name
        while cur in alias_raw and cur not in seen_chain:
            seen_chain.add(cur)
            cur = alias_raw[cur]
        resolved_cache[name] = cur
        return cur

    print(
        f"alias-merged {n_buffers} buffer instances, "
        f"dropped {n_dropped} no-op instances",
        file=sys.stderr,
    )

    lines = []
    lines.append(f"module {vname(top_cell_name)} ({', '.join(vname(n) for n in port_names)});")
    for nm in port_names:
        lines.append(f"  inout {vname(nm)};")

    # declare a wire for every resolved net name actually used by a kept
    # instance (skip ports, and skip anything that got aliased away)
    seen = set(port_names)
    wire_names = []
    for cell_type, inst_name, conns in raw_instances:
        if cell_type in buffer_types or cell_type in drop_types:
            continue
        for nm in conns.values():
            rnm = resolve(nm)
            if rnm not in seen:
                seen.add(rnm)
                wire_names.append(rnm)
    for nm in wire_names:
        lines.append(f"  wire {vname(nm)};")

    counts = {}
    for cell_type, inst_name, conns in raw_instances:
        if cell_type in buffer_types or cell_type in drop_types:
            continue
        counts[cell_type] = counts.get(cell_type, 0) + 1
        conn_strs = [f".{vname(pname)}({vname(resolve(nm))})" for pname, nm in conns.items()]
        lines.append(f"  {vname(cell_type)} {vname(inst_name)} ({', '.join(conn_strs)});")

    lines.append("endmodule")

    if not out_path:
        print("\n".join(lines) + "\n")

    else:
        with open(out_path, "w") as f:
            f.write("\n".join(lines) + "\n")

    return counts


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("gds")
    ap.add_argument("top_cell")
    ap.add_argument("-o", "--out", default=None, help="path to output (default: stdout)")
    ap.add_argument("--l2n-out", default=None, help="also dump the raw .l2n database")
    args = ap.parse_args()

    l2n = extract(args.gds, args.top_cell)
    if args.l2n_out:
        l2n.write(args.l2n_out)

    counts = dump_verilog(l2n, args.top_cell, args.out)

    if args.out:
        print(f"wrote {args.out}")

    print("---- statistics ----")
    print("instance counts by cell type:")
    for cell_type, n in sorted(counts.items(), key=lambda kv: -kv[1]):
        print(f"  {n:4d}  {cell_type}")


if __name__ == "__main__":
    main()

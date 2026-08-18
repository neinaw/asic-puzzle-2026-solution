# This repository contains my attempt at solving Jane Street's 2026 ASIC Puzzle

## Puzzle Content
1. [Jane Street's Blog](https://blog.janestreet.com/can-you-reverse-engineer-an-asic/)
2. [Puzzle Repository](https://github.com/janestreet/asic-puzzle-2026)

## Working through the warmup

### 1. First Impressions
I had never worked with a straight GDS file up until this challenge, which set me up for a rocky start. I dove straight into the deep end by opening the warmup's GDS in KLayout. After some poking around, I figured out that the *tech node* for this challenge was [SkyWater's 130nm process node](https://skywater-pdk.readthedocs.io/en/main/).

Before proceeding further, I tried making GDSes for simpler circuits (basically the ones that were taught in college) - inverters, adders, muxes, flip-flops, etc. I used [LibreLane](https://librelane.readthedocs.io/en/stable/getting_started/index.html) to set up a 100um x 100um die, with the default configuration to get a feel for the flow and get my hands dirty with KLayout. For those interested, my experiments are in `learnings/`. Note: LibreLane has some flow defaults on size and logic density, meaning it won't let you generate a GDS for a plain inverter on its own, which is why the GDS itself is padded with filler cells and such to meet DRC/LVS checks.

### 2. Tracing nets
KLayout will let you *load* a technology (.lyt) - in this case Sky130 to update the workspace with correct layer colors, design rules, etc. Then the "trace nets" feature allows you to select a *net* and *trace* all cells that are on that *net* - it can do this by inferring layer connections from the technology. This turns out to be a crucial feature for this reverse-engineering process.

For example, tracing the input of the inverter `X` (`learnings/01_inverter`) reveals that `X` is connected to the net `in` (which is also an IO pin). Likewise, the output `Y` is connected to the net `out`. So far so good!

### 3. Reverse-engineering the netlist from the GDS
The Sky130 PDK is completely open source, which means we can deduce the function of each cell used in the given top. If we have 1. all different cells used and 2. the connections between them, we will have reverse-engineered the netlist!

One way to do this would be to manually find each cell instance, *trace* its IO in KLayout, and name the unique connections. This would, however, be tedious, slow, and error-prone.

A better way is to *automate* this process. KLayout conveniently gives a [Python API](https://www.klayout.org/klayout-pypi/) for its net tracer feature (and much more). Here I gave Claude the API reference, a local copy of the PDK, and asked it to build a script that walks over all cell instances, finds the nets it's connected to, and spits out verilog with all cell instances and their unique connections (nets). 

I faced some hiccups with sby and iverilog while simulating the netlist directly, so the script merges all buffers (such as clock buffers) and drops filler cells and otherwise all non-functional cells which may not be relevant to functional simulation.

#### Example Usage:
```
$ ./scripts/extract_netlist.py ../learnings/01_inverter/inverter.gds inverter

alias-merged 0 buffer instances, dropped 1918 no-op instances
module inverter (VGND, VPWR, in, out);
  inout VGND;
  inout VPWR;
  inout in;
  inout out;
  sky130_fd_sc_hd__inv_2 sky130_fd_sc_hd__inv_2_773 (.VPWR(VPWR), .Y(out), .VGND(VGND), .A(in));
endmodule

---- statistics ----
instance counts by cell type:
     1  sky130_fd_sc_hd__inv_2
```

#### Netlist to functional RTL
At this point the netlist is extracted, i.e., standard cells and their connections (nets) - but the cells themselves are black boxes. Since the PDK is open source, all we have to do is look into the cell definitions and extract the function.

I had Claude write a minimal functional library of these standard cells derived directly from the lib tech (minus all the Liberty-provided comments, conditional compilation macros, etc.) for use in simulations (`warmup/reverse/sky130_behavioral.v`). Note that this reference has "extra" code - there may be two sky130_* cells with the same logical function but different drive strengths. Logically, all such variants of one function type should be merged, but this is something I chose to ignore.

The GDS was now fully reverse-engineered to functional verilog. But we retroactively *know* the intended function of adder_demo, so it saves us from having to derive it (for now). To gain some confidence about the scripts that were made so far, I wrote a small equivalence testbench that checks the cycle-by-cycle output of the original source (golden) against the reverse-engineered RTL with a free-running clock and random inputs. Run `make run` from `warmup/reverse/` to run the equivalence check. The reverse -engineered verilog will be generated in `warmup/reverse/outdir/extracted.v`

## Solving the Puzzle

So far we have:
1. A script that builds up a netlist from an input GDS comprising standard cells from the Sky130 PDK
2. A library that describes the RTL functions of the standard cells
3. A way to simulate the reverse-engineered RTL, which is in a pseudo-netlist form.

### Formal Verification
*Reading* the netlist is a very difficult task. I have all the logic cells but no information about the behavior - what the correct input is, how many cycles the output lasts, etc. But I can choose to exploit the fact that `success` (a 1 bit output) must go high for *some* input combination. To solve this exact problem, formal methods have a mode called `cover`. We specify the statement that has to be covered `cover (success)`, for which a formal tool could give one out of two possible answers:

1. The statement can **never** be true for **any** input combination (success can never be 1).
2. The statement is true (or can be reached) for **some** input combination - **AND** it gives you that exact winning sequence which satisfies the condition!

The formal tool I used is [SymbiYosys (sby)](https://symbiyosys.readthedocs.io/en/latest/). SBY, conveniently also dumps the "winning" trace in VCD format which can be easily extracted using the `vcdvcd` Python package. The SBY file is in `puzzle/solution/puzzle_formal_top.sby`.

### Simulation for Extracting the Final Answer
I wrote a small behavioral testbench that drives the stimulus extracted from the formal trace, and then runs the extracted netlist for a few extra (50) cycles, recovering the final answer string: `(* TWO STARS *)` (which happens to resemble an OCaml comment?!)

To run the entire flow end-to-end, run `make run` from `puzzle/solution`. Note: you might need to install some dependencies for Python for it to work!

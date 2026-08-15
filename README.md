# This repository contains my attempt at solving Jane Street's 2026 ASIC Puzzle

## Puzzle Content
1. [Jane Street's Blog](https://blog.janestreet.com/can-you-reverse-engineer-an-asic/)
2. [Puzzle Repository](https://github.com/janestreet/asic-puzzle-2026)

## Working through the warmup

### 1. First Impressions
I had never worked with a straight GDS file up until this challenge which set me up to a rocky start. I dove straight into the deep end with opening the warmup's GDS in KLayout. Some poking around later I figured out that the *tech node* for this challenge was [SkyWater's 130nm process node](https://skywater-pdk.readthedocs.io/en/main/).

Before proceeding further, I tried making GDSes for simpler circuits (basically the ones that were taught in college) - inverters, adders, muxes, flip flops, etc. I used [LibreLane](https://librelane.readthedocs.io/en/stable/getting_started/index.html) to setup a 100umx100um die, with the default configuration to get a feel for the flow, and getting my hands dirty with KLayout. For those interested my experiments are in `learnings/`. Note: LibreLane has some flow defaults on size and logic density - meaning it won't let you generate a GDS for a plain inverter on its own which is why the GDS itself is padded with filler cells and such-like to meet DRC/LVS checks.

### 2. Tracing nets
KLayout will let you *load* a technology (.lyt) - in this case sky130 to update the workspace with correct layer colors, design rules, etc. Then the "trace nets" feature allows you to select a *net* and *trace* all cells that are on that *net* - it can do this by inferring layer connections from the technology. This turns out to be a crucial feature for this reverse-engineering process.

For example, tracing the input of the inverter `X` (`learnings/01_inverter`) reveals that `X` is connected to the net `in` (which is also an IO pin). Likewise the output `Y` is connected to the net `out`. So far so good!

### 3. Reverse-engineering the netlist from GDS layout
The Sky130 PDK is completely open source - which means we can deduce the function of each cell used in the given top. If we have 1. all different cells used and 2. the connections between them, we will have reverse-engineered the netlist!

One way to do this would be to manually find each cell instance, *trace* its IO in KLayout and name the unique connections. This would however be tedious, slow and error prone.

A better way is to *automate* this process. KLayout conveniently gives a [Python API](https://www.klayout.org/klayout-pypi/) for its net tracer feature (and much more). Here I gave claude the API reference, a local copy of the PDK and asked it to build a script that walks over all cell instances, find the nets its connected to, and spit out a .v with all cell instances their unique connections (nets). 

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
As mentioned earlier the PDK is open source, so I had claude write a clean functional reference (minus all the Liberty provided comments, conditional compilation, etc.) for use in simulations. There is extra code as there may be two sky130_* cells with the same logical function but different drive strenghts. The reference has dedicated definitions for either when we really could've merged them. But this is something I chose to ignore for now.

At this point the GDS was fully reverse-engineered to functional verilog. But we retroactively *know* the function so it saves us from having to infer it (for now). To gain some confidence about the scripts that were made so far, I(claude) wrote a small equivalence testbench that compares the reverse-engineered RTL to the original source. Run `make run` from from `warmup/reverse/` to run the equivalence check. The reverse engineered verilog will be generated in `warmup/reverse/outdir/extracted.v`

## Solving the Puzzle


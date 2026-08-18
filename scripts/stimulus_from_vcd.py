#!/usr/bin/env python3

import argparse
from pathlib import Path

from vcdvcd import VCDVCD

vcd = VCDVCD("outdir/formal/engine_0/trace0.vcd")

clk = vcd["formal_top.clk"]
I = vcd["formal_top.I"]
success = vcd["formal_top.success"]
rst_n = vcd["formal_top.rst_n"]

clk_edges = []
prev = None
for t, v in clk.tv:
    if prev == '0' and v == '1':
        clk_edges.append(t)
    prev = v

def value_before(signal, time):
    val = '0'
    for t, v in signal.tv:
        if t >= time:
            break
        val = v
    return val

def value_after(signal, time):
    val = '0'
    for t, v in signal.tv:
        if t > time:
            break
        val = v
    return val

def write_to_file(out_file):
  with open(out_file, "w") as file:
    for _cycle, t in enumerate(clk_edges):
      if value_after(success, t) == '1':
        return
      else:
        file.write(f"{value_before(I, t)}{value_before(rst_n, t)}\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("out_file", help="output path, relative to this script's directory")
    args = parser.parse_args()

    out_path = Path(__file__).resolve().parent / args.out_file
    write_to_file(out_path)

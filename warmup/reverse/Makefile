TB_TOP     := tb_equiv_check.v
GOLD_REF   := ../00_source.v
BEHAVIORAL := sky130_behavioral.v

GDS      := ../04_final.gds
TOP_CELL := adder_demo

SCRIPTS_DIR     := ../../scripts
EXTRACT_NETLIST := $(SCRIPTS_DIR)/extract_netlist.py
GEN_BEHAVIORAL  := $(SCRIPTS_DIR)/gen_behavioral.py

OUTDIR    := outdir
EXTRACTED := $(OUTDIR)/extracted.v
SIM       := $(OUTDIR)/sim

.PHONY: default run clean
default: run

run: $(SIM)
	vvp $(SIM)

$(SIM): $(TB_TOP) $(GOLD_REF) $(BEHAVIORAL) $(EXTRACTED)
	iverilog -o $@ $^

# Extracted module comes out named after $(TOP_CELL) (its GDS cell name), but
# GOLD_REF already defines a module of that name - rename it so both can be
# compiled into the same testbench.
$(EXTRACTED): $(GDS) $(EXTRACT_NETLIST) $(GEN_BEHAVIORAL) | $(OUTDIR)
	python3 $(EXTRACT_NETLIST) $(GDS) $(TOP_CELL) -o $@.raw
	sed 's/^module $(TOP_CELL) /module extracted /' $@.raw > $@
	rm -f $@.raw

$(OUTDIR):
	mkdir -p $@

clean:
	rm -rf $(OUTDIR)

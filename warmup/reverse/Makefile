TB_TOP_V     := tb_equiv_check.v
GOLD_REF_V   := ../00_source.v
BEHAVIORAL_V := sky130_behavioral.v

GDS      := ../04_final.gds
TOP_CELL := adder_demo

SCRIPTS_DIR        := ../../scripts
EXTRACT_NETLIST_PY := $(SCRIPTS_DIR)/extract_netlist.py
GEN_BEHAVIORAL_PY  := $(SCRIPTS_DIR)/gen_behavioral.py

OUTDIR      := outdir
EXTRACTED_V := $(OUTDIR)/extracted.v
SIM         := $(OUTDIR)/sim

.PHONY: default run clean
default: run

run: $(SIM)
	vvp $(SIM)

$(SIM): $(TB_TOP_V) $(GOLD_REF_V) $(BEHAVIORAL_V) $(EXTRACTED_V)
	iverilog -o $@ $^

# Extracted module comes out named after $(TOP_CELL) (its GDS cell name), but
# GOLD_REF_V already defines a module of that name - rename it so both can be
# compiled into the same testbench.
$(EXTRACTED_V): $(GDS) $(EXTRACT_NETLIST_PY) $(GEN_BEHAVIORAL_PY) | $(OUTDIR)
	python3 $(EXTRACT_NETLIST_PY) $(GDS) $(TOP_CELL) -o $@.raw
	sed 's/^module $(TOP_CELL) /module extracted /' $@.raw > $@
	rm -f $@.raw

$(OUTDIR):
	mkdir -p $@

clean:
	rm -rf $(OUTDIR)

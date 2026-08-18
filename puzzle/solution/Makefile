TB_BEHAV_V        := tb_puzzle_behav.v
WRAPPER_V         := puzzle_wrapper.v
FORMAL_TOP_V      := formal_top.v
FORMAL_SBY        := puzzle_formal_top.sby
BEHAV_MODEL_LIB_V := ../../warmup/reverse/sky130_behavioral.v
GDS               := ../puzzle.gds
TOP_CELL          := puzzle

SCRIPTS_DIR           := ../../scripts
EXTRACT_NETLIST_PY    := $(SCRIPTS_DIR)/extract_netlist.py
GEN_BEHAVIORAL_PY     := $(SCRIPTS_DIR)/gen_behavioral.py
STIMULUS_FROM_VCD_PY  := $(SCRIPTS_DIR)/stimulus_from_vcd.py

OUTDIR        := outdir
FORMAL_OUTDIR := $(OUTDIR)/formal

NETLIST_EXTRACTED_V := $(OUTDIR)/puzzle_netlist_extracted.v
TRACE_VCD            := $(FORMAL_OUTDIR)/engine_0/trace0.vcd
STIMULUS_MEM         := $(OUTDIR)/stimulus.mem
SIM                  := $(OUTDIR)/sim

.PHONY: run stimulus formal netlist clean
.default: run

run: $(SIM) $(STIMULUS_MEM)
	vvp $(SIM)

$(SIM): $(TB_BEHAV_V) $(WRAPPER_V) $(NETLIST_EXTRACTED_V) $(BEHAV_MODEL_LIB_V) | $(OUTDIR)
	iverilog -g2012 -o $@ $^

stimulus: $(STIMULUS_MEM)

$(STIMULUS_MEM): $(TRACE_VCD) $(STIMULUS_FROM_VCD_PY) | $(OUTDIR)
	$(STIMULUS_FROM_VCD_PY) $(abspath $@)

formal: $(TRACE_VCD)

$(TRACE_VCD): $(FORMAL_TOP_V) $(FORMAL_SBY) $(NETLIST_EXTRACTED_V) $(BEHAV_MODEL_LIB_V) | $(OUTDIR)
	sby -f -d $(FORMAL_OUTDIR) $(FORMAL_SBY)

netlist: $(NETLIST_EXTRACTED_V)

$(NETLIST_EXTRACTED_V): $(GDS) $(EXTRACT_NETLIST_PY) $(GEN_BEHAVIORAL_PY) | $(OUTDIR)
	python3 $(EXTRACT_NETLIST_PY) $(GDS) $(TOP_CELL) -o $@

$(OUTDIR):
	mkdir -p $@

clean:
	rm -rf $(OUTDIR)

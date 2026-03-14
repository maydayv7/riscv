INC_DIR  = ../modules
BFLAGS   = -i $(INC_DIR) -f filelist.txt
TOP_MOD  = testbench
SNAPSHOT = riscv_sim
MEM_GEN  = ../mem_generator


# Vivado Tools
XVLOG = xvlog
XELAB = xelab
XSIM  = xsim

MAKE = mingw32-make


.PHONY: help clean

help:
	@echo "Usage: make <program_name>"

# 1. Generate Hex Files
# 2. Vivado Simulation Flow
# 3. Run Simulation
%:
	$(MAKE) clean -C $(MEM_GEN)
	$(MAKE) $@ -C $(MEM_GEN)
	$(XVLOG) $(BFLAGS)
	$(XELAB) -top $(TOP_MOD) -snapshot $(SNAPSHOT) -debug typical
	$(XSIM) $(SNAPSHOT) -runall -log stdout


clean:
	-rmdir /S /Q xsim.dir
	-del /Q /F xvlog.log xvlog.pb xelab.log xelab.pb xsim.log xsim.jou xsim.pb
	-del /Q /F riscv_sim.wdb stdout dfx_runtime.txt

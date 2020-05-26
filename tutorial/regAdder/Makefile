H3_CYGWIN_MODELSIM_PATH = $(H3_MODELSIM_PATH)

VLOG = $(H3_CYGWIN_MODELSIM_PATH)/vlog
VLIB = $(H3_CYGWIN_MODELSIM_PATH)/vlib
VSIM = $(H3_CYGWIN_MODELSIM_PATH)/vsim

# modelsim does not exist
# MODELSIM = $(H3_CYGWIN_MODELSIM_PATH)/modelsim.exe

PROJECT_WORK = ModelSim
LIBRARY_WORK = $(PROJECT_WORK)/$(LIBRARY_NAME)


# Library name and top-level module to be simulated
LIBRARY_NAME    = H3_Modules
TOPLEVEL_MODULE = H3_RegAdderSim

# Specify source files
SOURCES = \
	Adder.v \
	RegFile.v \
	RegAdder.v \
	RegAdderSim.v



DEPS = \
	$(SOURCES) \

#	+incdir+../../Src

OPTIONS = \
	-lint \
	-pedanticerrors \
	+librescan \
	-sv -nocovercells \
	-work $(LIBRARY_WORK) \
	#-incr \



all: $(DEPS) $(LIBRARY_WORK)
	$(VLOG) $(OPTIONS) $(SOURCES)


# vlib LIBRARY
clean:
	mkdir -p $(PROJECT_WORK)
	rm -rf $(LIBRARY_WORK)
	( cd $(PROJECT_WORK); $(VLIB) $(LIBRARY_NAME); )

lib: clean

$(LIBRARY_WORK): Makefile
	make clean


# simulation
# vsim LIBRARY -do "run -all"
sim:
	( cd $(PROJECT_WORK); $(VSIM) $(LIBRARY_NAME).$(TOPLEVEL_MODULE) -do "run -all"; )

# GUI simulation
sim-gui:
	( cd $(PROJECT_WORK); $(VSIM) $(LIBRARY_NAME).$(TOPLEVEL_MODULE) -do "do wave.do; run 50ns"; )

#	( cd $(WORK); $(VLOG) $(OPTIONS) $(DEPS); )

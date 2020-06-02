H3_CYGWIN_MODELSIM_PATH = $(H3_MODELSIM_PATH)

VLOG = $(H3_CYGWIN_MODELSIM_PATH)/vlog
VLIB = $(H3_CYGWIN_MODELSIM_PATH)/vlib
VSIM = $(H3_CYGWIN_MODELSIM_PATH)/vsim

PROJECT_WORK = ModelSim
LIBRARY_WORK = $(PROJECT_WORK)/$(LIBRARY_NAME)


# Library name and top-level module to be simulated
LIBRARY_NAME    = H3_Modules
TOPLEVEL_MODULE = H3_MainSim

# Specify source files
SOURCES = \
	ALU.v \
	Branch.v \
	CPU.v \
	Decoder.v \
	DMem.v \
	IMem.v \
	IOCtrl.v \
	LEDDrv.v \
	Main.v \
	MainSim.v \
	PC.v \
	RegFile.v \
	Stage1.v \
	Stage2.v \
	Stage3.v \
	Stage4.v \
	Types.v \

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
	mkdir $(PROJECT_WORK) -p
	rm -f -r $(LIBRARY_WORK)
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
	( cd $(PROJECT_WORK); $(VSIM) $(LIBRARY_NAME).$(TOPLEVEL_MODULE) -do "do wave.do; run 2050000000ns";  )




#	( cd $(WORK); $(VLOG) $(OPTIONS) $(DEPS); )



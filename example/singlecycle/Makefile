H3_CYGWIN_MODELSIM_PATH = $(shell cygpath -u "$$H3_MODELSIM_PATH")

VLOG = $(H3_CYGWIN_MODELSIM_PATH)/vlog.exe
VLIB = $(H3_CYGWIN_MODELSIM_PATH)/vlib.exe
VSIM = $(H3_CYGWIN_MODELSIM_PATH)/vsim.exe
MODELSIM = $(H3_CYGWIN_MODELSIM_PATH)/modelsim.exe

PROJECT_WORK = ModelSim
LIBRARY_WORK = $(PROJECT_WORK)/$(LIBRARY_NAME)


# ライブラリ名とトップレベルモジュール（シミュレーション対象）
LIBRARY_NAME    = H3_Modules
TOPLEVEL_MODULE = H3_MainSim 

# コンパイル対象のファイル
SOURCES = \
	ALU.v \
	Branch.v \
	ClockDivider.v \
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

# do wave.do で 波形フォーマットを読み込む
sim-gui: 
	( cd $(PROJECT_WORK); $(MODELSIM) $(LIBRARY_NAME).$(TOPLEVEL_MODULE) ;  )




#	( cd $(WORK); $(VLOG) $(OPTIONS) $(DEPS); )



####                            
####                            
#### AUTHOR: S. M. TAHMEED REZA 
####                            
####                            


ROOT_D   := ${shell realpath .}
SRC      := ${ROOT_D}/src
SUB      := ${ROOT_D}/sub
INC      := ${ROOT_D}/include
INF      := ${ROOT_D}/interface
TBD      := ${ROOT_D}/test/tb
UVM      := ${ROOT_D}/test/uvm

FST      := ${ROOT_D}/flist.f
LOG      := ${ROOT_D}/log.debug

TESTTYPE    := TB
TOP         := tb_top

TESTPLUSARG := --testplusarg UVM_VERBOSITY=UVM_HIGH
TESTPLUSARG += --testplusarg TESTNAME=${TESTNAME}

ifeq (${TESTTYPE}, UVM)
	TOP := uvm_top
endif

####
# DIRECTORY BUILDER
####

init:
	@echo "\033[7;32m//// INITIALIZING WORKSPACE... ///\033[0m"
	@mkdir -p src
	@mkdir -p sub
	@mkdir -p include
	@mkdir -p interface
	@mkdir -p test/uvm
	@touch test/uvm/uvm_top.sv
	@mkdir -p test/tb
	@touch test/tb/tb_top.sv
	@touch flist.f
	@touch log.debug

uvm_test_init:
	@echo "\033[7;32m//// INITIALIZING UVM TEST: ${TESTNAME}... ///\033[0m"
	@mkdir -p test/uvm/${TESTNAME}
	@touch test/uvm/${TESTNAME}/${TESTNAME}.sv
	@mkdir -p test/uvm/${TESTNAME}/components
	@touch test/uvm/${TESTNAME}/components/driver.sv
	@touch test/uvm/${TESTNAME}/components/monitor.sv
	@touch test/uvm/${TESTNAME}/components/sequencer.sv
	@touch test/uvm/${TESTNAME}/components/scoreboard.sv
	@touch test/uvm/${TESTNAME}/components/agent.sv
	@touch test/uvm/${TESTNAME}/components/env.sv
	@mkdir -p test/uvm/${TESTNAME}/inheritors
	@mkdir -p test/uvm/${TESTNAME}/sequences
	@mkdir -p test/uvm/${TESTNAME}/seq_items
	@mkdir -p test/uvm/${TESTNAME}/objects

uvm_seq_init:
	@touch test/uvm/${TESTNAME}/sequences/${SEQUENCE}/${SEQUENCE}.sv

uvm_seq_item_init:
	@touch test/uvm/${TESTNAME}/seq_items/${SEQ_ITEM}/${SEQ_ITEM}.sv

uvm_inheritor_init:
	@touch test/uvm/${TESTNAME}/inheritors/${INHERITOR}/${INHERITOR}.sv

uvm_object_init:
	@touch test/uvm/${TESTNAME}/objects/${OBJECT}/${OBJECT}.sv

clean_uvm_test:
	@echo "\033[7;31m//// REMOVING UVM TEST: ${TESTNAME}... ///\033[0m"
	@rm -rf test/uvm/${TESTNAME}

deinit: clean
	@echo "\033[7;31m//// NUKING WORKSPACE... ///\033[0m"
	@rm -rf src
	@rm -rf sub
	@rm -rf include
	@rm -rf interface
	@rm -rf test
	@rm -rf flist.f
	@rm -rf log.debug
	@rm -rf *.sh

####
# FLIST BUILDER
####

flist:
	@rm -rf ${FST}
	@touch ${FST}
	@echo "-i ${INC}"                                                                         >> ${FST}
	@find ${SUB} -type f \( -name "*pkg.sv" -o -name "*pkg.v" \)                              >> ${FST}
	@find ${SRC} -type f \( -name "*pkg.sv" -o -name "*pkg.v" \)                              >> ${FST}
	@find ${INF} -type f \( -name "*pkg.sv" -o -name "*pkg.v" \)                              >> ${FST}
	@find ${TBD} -type f \( -name "*pkg.sv" -o -name "*pkg.v" \)                              >> ${FST}
	@find ${UVM} -type f \( -name "*pkg.sv" -o -name "*pkg.v" \)                              >> ${FST}

	@find ${SUB} -type f \( -name "*.sv" -o -name "*.v" \) ! -name "*pkg.sv" ! -name "*pkg.v" >> ${FST}
	@find ${SRC} -type f \( -name "*.sv" -o -name "*.v" \) ! -name "*pkg.sv" ! -name "*pkg.v" >> ${FST}
	@find ${INF} -type f \( -name "*.sv" -o -name "*.v" \) ! -name "*pkg.sv" ! -name "*pkg.v" >> ${FST}
	@find ${TBD} -type f \( -name "*.sv" -o -name "*.v" \) ! -name "*pkg.sv" ! -name "*pkg.v" >> ${FST}

	@find ${UVM}/${TESTNAME} -type f -name "*seq_item.sv"   >> ${FST}
	@find ${UVM}/${TESTNAME} -type f -name "*sequence.sv"   >> ${FST}
	@find ${UVM}/${TESTNAME} -type f -name "*driver.sv"     >> ${FST}
	@find ${UVM}/${TESTNAME} -type f -name "*monitor.sv"    >> ${FST}
	@find ${UVM}/${TESTNAME} -type f -name "*sequencer.sv"  >> ${FST}
	@find ${UVM}/${TESTNAME} -type f -name "*scoreboard.sv" >> ${FST}
	@find ${UVM}/${TESTNAME} -type f -name "*agent.sv"      >> ${FST}
	@find ${UVM}/${TESTNAME} -type f -name "*env.sv"        >> ${FST}
	@find ${UVM}/${TESTNAME} -type f -name "*test.sv"       >> ${FST}
	@find ${UVM}             -type f -name "uvm_top.sv"     >> ${FST}

####
# OPERATION THEATRE
####

clean:
	@echo "\033[7;31m//// PERFORMING CLEAN-UP... ///\033[0m"
	@rm -rf build
	@rm -rf log.debug
	@rm -rf flist.f

build: 
	@mkdir -p build

xvlog:
	@echo ""                                 | tee -a log.debug
	@echo "//// COMPILATION STAGE ////"      | tee -a log.debug
	@echo ""                                 | tee -a log.debug
	@cd build; xvlog --sv -f ${FST} -L uvm   | tee -a ../log.debug

xelab:
	@echo ""                                                            | tee -a log.debug
	@echo "//// ELABORATION STAGE ////"                                 | tee -a log.debug
	@echo ""                                                            | tee -a log.debug
	@cd build; xelab ${TOP} -s ${TOP} -timescale 1ns/1ps -debug typical | tee -a ../log.debug

xsim:
	@echo ""                                       | tee -a log.debug
	@echo "//// SIMULATION STAGE ////"             | tee -a log.debug
	@echo ""                                       | tee -a log.debug
	@cd build; xsim ${TOP} ${TESTPLUSARG} --runall | tee -a ../log.debug

gsim:
	@echo ""                                    | tee -a log.debug
	@echo "//// SIMULATION STAGE ////"          | tee -a log.debug
	@echo ""                                    | tee -a log.debug
	@cd build; xsim ${TOP} ${TESTPLUSARG} --gui | tee -a ../log.debug

run_sim: clean flist build xvlog xelab xsim
run_gui: clean flist build xvlog xelab gsim
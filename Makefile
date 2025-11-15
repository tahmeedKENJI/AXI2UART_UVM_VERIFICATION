####                            
####                            
#### AUTHOR: S. M. TAHMEED REZA 
####                            
####                            


export ROOT_D   := ${shell realpath .}
INC      := ${ROOT_D}/include
PKG      := ${ROOT_D}/package
SRC      := ${ROOT_D}/src
SUB      := ${ROOT_D}/sub
TBD      := ${ROOT_D}/test/tb
UVM      := ${ROOT_D}/test/uvm
SCT      := ${ROOT_D}/scripts

FST      := ${ROOT_D}/flist.f
LOG      := ${ROOT_D}/log.debug

TESTTYPE    := TB
TOP         := tb_top

DEFINITION  := -L uvm
DEFINITION  += -d USE_AXI

UVM_VERBOSITY ?= UVM_LOW

TESTPLUSARG := --testplusarg UVM_VERBOSITY=${UVM_VERBOSITY}
TESTPLUSARG += --testplusarg TESTNAME=${TESTNAME}
TESTPLUSARG += --testplusarg CLKFREQMHZ=${CLKFREQMHZ}

RUNTYPE     ?= --runall
GUI         ?= 0

ifeq (${GUI}, 1)
	RUNTYPE := --gui
endif

ifeq (${TESTTYPE}, UVM)
	TOP := uvm_tb_top
endif

####
# DIRECTORY BUILDER
####

init:
	@echo "\033[7;32m//// INITIALIZING WORKSPACE... ///\033[0m"
	@mkdir -p src
	@mkdir -p package

	@mkdir -p include
	@touch include/dependencies.svh
	@python3 scripts/gen_dependencies_header.py include/dependencies.svh

	@mkdir -p test/uvm
	@touch test/uvm/uvm_tb_top.sv
	@python3 scripts/gen_uvm_tb_top.py test/uvm/uvm_tb_top.sv

	@mkdir -p test/uvm/testcases
	@mkdir -p test/uvm/environments
	@mkdir -p test/uvm/scoreboards
	@mkdir -p test/uvm/components
	@mkdir -p test/uvm/sequences
	@mkdir -p test/uvm/seq_items
	@mkdir -p test/uvm/objects
	@mkdir -p test/uvm/interfaces

	@mkdir -p test/tb
	@touch test/tb/tb_top.sv

	@touch flist.f
	@touch log.debug

uvm_test_init:
	@touch test/uvm/testcases/${TESTNAME}_test.sv
	@python3 scripts/uvm_gen_component.py test/uvm/testcases/${TESTNAME}_test.sv ${TESTNAME}_test uvm_test

uvm_scoreboard_init:
	@touch test/uvm/scoreboards/${SCOREBOARD}_scoreboard.sv
	@python3 scripts/uvm_gen_component.py test/uvm/scoreboards/${SCOREBOARD}_scoreboard.sv ${SCOREBOARD}_scoreboard uvm_scoreboard

uvm_env_init:
	@touch test/uvm/environments/${ENV}_env.sv
	@python3 scripts/uvm_gen_component.py test/uvm/environments/${ENV}_env.sv ${ENV}_env uvm_env

uvm_component_init:
	@mkdir -p test/uvm/components/${COMPONENT}

	@touch test/uvm/components/${COMPONENT}/${COMPONENT}_driver.sv
	@python3 scripts/uvm_gen_component.py test/uvm/components/${COMPONENT}/${COMPONENT}_driver.sv ${COMPONENT}_driver uvm_driver

	@touch test/uvm/components/${COMPONENT}/${COMPONENT}_monitor.sv
	@python3 scripts/uvm_gen_component.py test/uvm/components/${COMPONENT}/${COMPONENT}_monitor.sv ${COMPONENT}_monitor uvm_monitor

	@touch test/uvm/components/${COMPONENT}/${COMPONENT}_sequencer.sv
	@python3 scripts/uvm_gen_component.py test/uvm/components/${COMPONENT}/${COMPONENT}_sequencer.sv ${COMPONENT}_sequencer uvm_sequencer

	@touch test/uvm/components/${COMPONENT}/${COMPONENT}_agent.sv
	@python3 scripts/uvm_gen_component.py test/uvm/components/${COMPONENT}/${COMPONENT}_agent.sv ${COMPONENT}_agent uvm_agent

uvm_seq_init:
	@touch test/uvm/sequences/${SEQUENCE}_sequence.sv
	@python3 scripts/uvm_gen_sequence.py test/uvm/sequences/${SEQUENCE}_sequence.sv ${SEQUENCE}_sequence

uvm_seq_item_init:
	@touch test/uvm/seq_items/${SEQ_ITEM}_seq_item.sv
	@python3 scripts/uvm_gen_seq_item.py test/uvm/seq_items/${SEQ_ITEM}_seq_item.sv ${SEQ_ITEM}_seq_item

uvm_interface_init:
	@touch test/uvm/interfaces/${INTERFACE}.sv
	@python3 scripts/uvm_gen_interface.py test/uvm/interfaces/${INTERFACE}.sv ${INTERFACE}

uvm_object_init:
	@touch test/uvm/objects/${OBJECT}.sv
	@python3 scripts/uvm_gen_object.py test/uvm/objects/${OBJECT}.sv ${OBJECT}

deinit: clean
	@echo "\033[7;31m//// NUKING WORKSPACE... ///\033[0m"
	@rm -rf src
	@rm -rf include
	@rm -rf package
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
	@echo "-i ${INC}"                                      >> ${FST}
	
	@find ${PKG} -type f \( -name "*.sv" -o -name "*.v" \) >> ${FST}
	@find ${SUB} -type f \( -name "*.sv" -o -name "*.v" \) >> ${FST}
	@find ${SRC} -type f \( -name "*.sv" -o -name "*.v" \) >> ${FST}
	@find ${TBD} -type f \( -name "*.sv" -o -name "*.v" \) >> ${FST}

	@find ${UVM}/interfaces   	-type f -name "*.sv" 	>> ${FST}
	@find ${UVM}/seq_items    	-type f -name "*.sv" 	>> ${FST}
	@find ${UVM}/objects      	-type f -name "*.sv" 	>> ${FST}
	@find ${UVM}/sequences    	-type f -name "*.sv" 	>> ${FST}
	@find ${UVM}/components   	-type f -name "*.sv" 	>> ${FST}
	@find ${UVM}/scoreboards  	-type f -name "*.sv" 	>> ${FST}
	@find ${UVM}/environments 	-type f -name "*.sv" 	>> ${FST}
	@find ${UVM}/testcases 		-type f -name "*.sv" 	>> ${FST}
	@find ${UVM}/top       		-type f -name "*.sv" 	>> ${FST}

####
# OPERATION THEATRE
####

clean:
	@echo "\033[7;31m//// PERFORMING CLEAN-UP... ///\033[0m"
	@rm -rf build
	@rm -rf log.debug

build: 
	@mkdir -p build

xvlog:
	@echo ""                                      | tee -a log.debug
	@echo "//// COMPILATION STAGE ////"           | tee -a log.debug
	@echo ""                                      | tee -a log.debug
	@cd build; xvlog --sv -f ${FST} ${DEFINITION} | tee -a ../log.debug

xelab:
	@echo ""                                                            | tee -a log.debug
	@echo "//// ELABORATION STAGE ////"                                 | tee -a log.debug
	@echo ""                                                            | tee -a log.debug
	@cd build; xelab ${TOP} -s ${TOP} -timescale 1ns/1ps -debug typical | tee -a ../log.debug

xsim:
	@echo ""                                         | tee -a log.debug
	@echo "//// SIMULATION STAGE ////"               | tee -a log.debug
	@echo ""                                         | tee -a log.debug
	@cd build; xsim ${TOP} ${TESTPLUSARG} ${RUNTYPE} | tee -a ../log.debug

run: clean build xvlog xelab xsim
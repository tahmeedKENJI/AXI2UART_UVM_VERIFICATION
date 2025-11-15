set_param project.enableReportConfiguration 0
load_feature core
current_fileset
xsim {uvm_tb_top} -testplusarg UVM_VERBOSITY=UVM_LOW -testplusarg TESTNAME=base_test -testplusarg CLKFREQMHZ= -autoloadwcfg

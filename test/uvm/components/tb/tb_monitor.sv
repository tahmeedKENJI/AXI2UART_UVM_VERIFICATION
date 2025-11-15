`include "dependencies.svh"

class tb_monitor extends uvm_monitor;

    `uvm_component_utils(tb_monitor)

    function new(string name="tb_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(tb_seq_item) tb_analysis_port;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tb_analysis_port = new("tb_analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

endclass

    
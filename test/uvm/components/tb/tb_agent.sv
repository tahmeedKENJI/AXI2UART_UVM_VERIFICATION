`include "dependencies.svh"

class tb_agent extends uvm_agent;

    `uvm_component_utils(tb_agent)

    tb_driver       u_tb_driver;
    tb_monitor      u_tb_monitor;
    tb_sequencer    u_tb_sequencer;

    function new(string name="tb_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        u_tb_driver     = tb_driver::type_id::create("u_tb_driver", this);
        u_tb_monitor    = tb_monitor::type_id::create("u_tb_monitor", this);
        u_tb_sequencer  = tb_sequencer::type_id::create("u_tb_sequencer", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        u_tb_driver.seq_item_port.connect(u_tb_sequencer.seq_item_export);
    endfunction

endclass

    
`include "dependencies.svh"

class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    simple_env u_env;
    virtual tb_intf u_tb_intf;
    
    function new(string name="base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        u_env = simple_env::type_id::create("u_env", this);
        if(!uvm_config_db#(virtual tb_intf)::get(this, "", "tb_intf", u_tb_intf)) begin
            `uvm_error(get_name(), "Testbench Interface NOT FOUND")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        apply_reset();
        #100ns;
        send_to_rx(8'h5B, '0);
        send_to_rx(8'h9B, '0);
        repeat (10000) @(posedge u_tb_intf.clk);
        phase.drop_objection(this);
    endtask

    task apply_reset;
        apply_reset_sequence u_apply_reset_sequence;
        u_apply_reset_sequence = apply_reset_sequence::type_id::create("u_apply_reset_sequence");
        u_apply_reset_sequence.start(u_env.u_tb_agent.u_tb_sequencer);
    endtask

    task send_to_rx(serial_to_parallel_t array, logic isRandom);
        send_rx_sequence u_seq;
        u_seq = send_rx_sequence::type_id::create("u_seq");

        u_seq.isRandomData = isRandom;
        u_seq.data = array;
        u_seq.start(u_env.u_uart_agent.u_uart_sequencer);
    endtask

endclass

    
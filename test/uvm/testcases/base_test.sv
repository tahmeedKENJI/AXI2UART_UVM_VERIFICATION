`include "dependencies.svh"

class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    simple_env u_env;
    virtual uart_intf u_uart_intf;

    function new(string name="base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        u_env = simple_env::type_id::create("u_env", this);

        if (!uvm_config_db #(virtual uart_intf)::get(this, "", "uart_intf", u_uart_intf)) begin
            `uvm_error(get_name(), "UART Interface NOT FOUND")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        apply_reset();
        #100ns;
        u_uart_intf.send_rx(8'h9B);
        #100ns;
        phase.drop_objection(this);
    endtask

    task apply_reset;
        apply_reset_sequence u_apply_reset_sequence;
        u_apply_reset_sequence = apply_reset_sequence::type_id::create("u_apply_reset_sequence");
        u_apply_reset_sequence.start(u_env.u_tb_agent.u_tb_sequencer);
    endtask

endclass

    
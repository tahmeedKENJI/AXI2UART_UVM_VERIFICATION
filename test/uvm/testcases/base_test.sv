`include "dependencies.svh"

class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    simple_env u_env;
    virtual tb_intf u_tb_intf;
    virtual axi_intf u_axi_intf;
    
    function new(string name="base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        u_env = simple_env::type_id::create("u_env", this);
        if(!uvm_config_db#(virtual tb_intf)::get(this, "", "tb_intf", u_tb_intf)) begin
            `uvm_error(get_name(), "Testbench Interface NOT FOUND")
        end
        if(!uvm_config_db#(virtual axi_intf)::get(this, "", "axi_intf", u_axi_intf)) begin
            `uvm_error(get_name(), "AXI Interface NOT FOUND")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        apply_reset();
        #100ns;
        send_axi_write(8'h00, 32'b1);
    
        #100ns

        fork
            begin
                send_axi_write(8'h14, 8'h59);
            end
            begin
                send_to_rx(8'h1B, '0);
                send_to_rx(8'h9B, '0);
            end
        join
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

    task send_axi_write(axi_addr_t addr, axi_data_t data);
        axi_data_t data_array [];
        axi_strb_t strb_array [];
        axi_resp_t resp;
        int len = 0;

        data_array = new[len + 1];
        strb_array = new[len + 1];

        data_array[0] = data;
        strb_array[0] = '1;

        u_axi_intf.mstr_write_xactn(addr, len, 2, 1, data_array, strb_array, resp);
    endtask

    task test_axi_write(axi_addr_t addr, int len);
        axi_data_t u_data [];
        axi_strb_t u_strb [];
        axi_resp_t u_resp;

        u_data = new[len + 1];
        u_strb = new[len + 1];

        for (int i = 0; i <= len; i++) begin
            u_data[i] =  $urandom;
            u_strb[i] = '1;
        end

        u_axi_intf.mstr_write_xactn(8'h00, len, 2, 1, u_data, u_strb, u_resp);
    endtask

endclass

    
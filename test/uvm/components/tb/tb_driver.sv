`include "dependencies.svh"

class tb_driver extends uvm_driver #(tb_seq_item);

    `uvm_component_utils(tb_driver)

    virtual tb_intf u_tb_intf;

    function new(string name="tb_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual tb_intf)::get(this, "", "tb_intf", u_tb_intf)) begin
            `uvm_error(get_name(), "Testbench Interface NOT FOUND")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);        
        super.run_phase(phase);
        process_item();
    endtask

    task process_item();
        forever begin
            tb_seq_item item;
            item = tb_seq_item::type_id::create("item");

            @(posedge u_tb_intf.clk);
            seq_item_port.get_next_item(item);
            if (item.toggleReset) u_tb_intf.apply_reset();
            seq_item_port.item_done(item);
        end
    endtask

endclass

    
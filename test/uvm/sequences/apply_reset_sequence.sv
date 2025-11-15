`include "dependencies.svh"

class apply_reset_sequence extends uvm_sequence;

    `uvm_object_utils(apply_reset_sequence)

    function new(string name="apply_reset_sequence");
        super.new(name);
    endfunction

    virtual task body();
        tb_seq_item item;

        item = tb_seq_item::type_id::create("apply_reset");
        start_item(item);
        item.toggleReset = '1;
        finish_item(item);
    endtask
    
endclass


`include "dependencies.svh"

class tb_seq_item extends uvm_sequence_item;

    `uvm_object_utils(tb_seq_item)

    logic toggleReset;

    function new(string name="tb_seq_item");
        super.new(name);
    endfunction
    
endclass


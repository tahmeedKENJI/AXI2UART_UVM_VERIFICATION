`include "dependencies.svh"

class reg_rsp_seq_item extends uvm_sequence_item;

    `uvm_object_utils(reg_rsp_seq_item)

    function new(string name="reg_rsp_seq_item");
        super.new(name);
    endfunction
    
endclass


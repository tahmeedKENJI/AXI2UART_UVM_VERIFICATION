`include "dependencies.svh"

class reg_req_seq_item extends uvm_sequence_item;

    `uvm_object_utils(reg_req_seq_item)

    function new(string name="reg_req_seq_item");
        super.new(name);
    endfunction
    
    logic isTest;
    logic isWrite;
    int len;

    axi_addr_t addr;
    axi_data_t data;

endclass


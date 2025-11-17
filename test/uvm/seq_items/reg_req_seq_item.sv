`include "dependencies.svh"

class reg_req_seq_item extends uvm_sequence_item;

    `uvm_object_utils(reg_req_seq_item)

    function new(string name="reg_req_seq_item");
        super.new(name);
    endfunction
    
    logic [tb_pkg::ADDR_WIDTH-1:0] addr;
    logic [tb_pkg::DATA_WIDTH-1:0] data;
    logic [tb_pkg::STRB_WIDTH-1:0] strb;

endclass


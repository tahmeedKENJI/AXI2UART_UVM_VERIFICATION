`include "dependencies.svh"

class send_axi_sequence extends uvm_sequence;

    `uvm_object_utils(send_axi_sequence)

    function new(string name="send_axi_sequence");
        super.new(name);
    endfunction

    logic isTest;
    logic isWrite;
    int len;

    axi_addr_t addr;
    axi_data_t data;

    virtual task body();
        reg_req_seq_item item;

        item = reg_req_seq_item::type_id::create("reg_req_item");
        start_item(item);

        item.isWrite = isWrite;
        item.isTest = isTest;
        item.addr = addr;

        if(isTest) item.len = len;
        else item.len = 0;
        
        if (isWrite) item.data = data;
        else item.data = '0;

        finish_item(item);
    endtask
    
endclass


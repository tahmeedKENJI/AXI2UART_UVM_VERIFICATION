`include "dependencies.svh"

class send_rx_sequence extends uvm_sequence;

    `uvm_object_utils(send_rx_sequence)

    function new(string name="send_rx_sequence");
        super.new(name);
    endfunction

    logic isRandomData;
    serial_to_parallel_t data;

    virtual task body();
        uart_rx_seq_item rx_item;

        rx_item = uart_rx_seq_item::type_id::create("rx_item");
        start_item(rx_item);
        if (isRandomData)   rx_item.randomize();
        else                rx_item.rx_array = data;
        finish_item(rx_item);
    endtask
    
endclass


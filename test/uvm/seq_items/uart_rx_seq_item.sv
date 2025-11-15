`include "dependencies.svh"

class uart_rx_seq_item extends uvm_sequence_item;

    `uvm_object_utils(uart_rx_seq_item)

    function new(string name="uart_rx_seq_item");
        super.new(name);
    endfunction

    rand serial_to_parallel_t rx_array;
    
endclass


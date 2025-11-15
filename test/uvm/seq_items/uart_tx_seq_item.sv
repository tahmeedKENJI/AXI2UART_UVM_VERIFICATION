`include "dependencies.svh"

class uart_tx_seq_item extends uvm_sequence_item;

    `uvm_object_utils(uart_tx_seq_item)

    function new(string name="uart_tx_seq_item");
        super.new(name);
    endfunction

    rand serial_to_parallel_t tx_array;
    
endclass


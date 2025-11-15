`include "dependencies.svh"

class uart_agent extends uvm_agent;

    `uvm_component_utils(uart_agent)

    function new(string name="uart_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    uart_driver     u_uart_driver;
    uart_monitor    u_uart_monitor;
    uart_sequencer  u_uart_sequencer;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        u_uart_driver       = uart_driver::type_id::create("u_uart_driver", this);
        u_uart_monitor      = uart_monitor::type_id::create("u_uart_monitor", this);
        u_uart_sequencer    = uart_sequencer::type_id::create("u_uart_sequencer", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        u_uart_driver.seq_item_port.connect(u_uart_sequencer.seq_item_export);
    endfunction

endclass

    
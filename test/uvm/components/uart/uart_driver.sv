`include "dependencies.svh"

class uart_driver extends uvm_driver #(uart_rx_seq_item);

    `uvm_component_utils(uart_driver)

    function new(string name="uart_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual uart_intf u_uart_intf;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual uart_intf)::get(this, "", "uart_intf", u_uart_intf)) begin
            `uvm_error(get_name(), "UART Interface NOT FOUND")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        uart_rx_seq_item item;

        super.run_phase(phase);

        forever begin
            item = uart_rx_seq_item::type_id::create("uart_dvr_item");
            seq_item_port.get_next_item(item);
            `uvm_info(get_name(), "RX Item captured by driver", UVM_HIGH)
            u_uart_intf.send_rx(item.rx_array);
            `uvm_info(get_name(), "RX Item driven by interface", UVM_HIGH)
            seq_item_port.item_done(item);
        end

    endtask

endclass

    
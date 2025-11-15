`include "dependencies.svh"

class uart_monitor extends uvm_monitor;

    `uvm_component_utils(uart_monitor)

    function new(string name="uart_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(uart_rx_seq_item) rx_analysis_port;
    uvm_analysis_port #(uart_tx_seq_item) tx_analysis_port;

    uart_tx_seq_item tx_item;
    uart_rx_seq_item rx_item;

    virtual uart_intf u_uart_intf;

    time sample_period = 100ns;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rx_analysis_port = new("rx_analysis_port", this);
        tx_analysis_port = new("tx_analysis_port", this);

        if (!uvm_config_db #(virtual uart_intf)::get(this, "", "uart_intf", u_uart_intf)) begin
            `uvm_error(get_name(), "UART Interface NOT FOUND")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        fork
            begin
                sample_tx();
            end
            begin
                sample_rx();
            end
        join
    endtask

    task sample_tx();
        logic previousTx;

        tx_item = uart_tx_seq_item::type_id::create("uart_tx_mon_item");
        forever begin
            #(sample_period);
            if (previousTx === '1 && u_uart_intf.tx === '0) begin
                `uvm_info(get_name(), "Monitor Tx Sampling", UVM_HIGH)
                u_uart_intf.recv_tx(tx_item.tx_array);
                `uvm_info(get_name(), $sformatf("\ntx_item.tx_array: %b\n", tx_item.tx_array), UVM_HIGH)
                tx_analysis_port.write(tx_item);
            end
            previousTx = u_uart_intf.tx;
        end
    endtask

    task sample_rx();
        logic previousRx;

        rx_item = uart_rx_seq_item::type_id::create("uart_rx_mon_item");
        forever begin
            #(sample_period);
            if (previousRx === '1 && u_uart_intf.rx === '0) begin
                `uvm_info(get_name(), "Monitor Rx Sampling", UVM_HIGH)
                u_uart_intf.recv_rx(rx_item.rx_array);
                `uvm_info(get_name(), $sformatf("\nrx_item.rx_array: %b\n", rx_item.rx_array), UVM_HIGH)
                rx_analysis_port.write(rx_item);
            end
            previousRx = u_uart_intf.rx;
        end
    endtask

endclass

    
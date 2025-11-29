`include "dependencies.svh"

class simple_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(simple_scoreboard)

    function new(string name="simple_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    `uvm_analysis_imp_decl(_tb)
    `uvm_analysis_imp_decl(_rx)
    `uvm_analysis_imp_decl(_tx)
    `uvm_analysis_imp_decl(_wreq)
    `uvm_analysis_imp_decl(_wrsp)
    `uvm_analysis_imp_decl(_rreq)
    `uvm_analysis_imp_decl(_rrsp)

    uvm_analysis_imp_tb #(tb_seq_item, simple_scoreboard) tb_analysis_imp;
    uvm_analysis_imp_rx #(uart_rx_seq_item, simple_scoreboard) rx_analysis_imp;
    uvm_analysis_imp_tx #(uart_tx_seq_item, simple_scoreboard) tx_analysis_imp;

    uvm_analysis_imp_wreq #(reg_req_seq_item, simple_scoreboard) w_req_analysis_imp;
    uvm_analysis_imp_wrsp #(reg_rsp_seq_item, simple_scoreboard) w_rsp_analysis_imp;
    uvm_analysis_imp_rreq #(reg_req_seq_item, simple_scoreboard) r_req_analysis_imp;
    uvm_analysis_imp_rrsp #(reg_rsp_seq_item, simple_scoreboard) r_rsp_analysis_imp;

    virtual uart_intf u_uart_intf;

    int counter = 0;
    serial_to_parallel_t tx_array_queue [$];
    serial_to_parallel_t rx_array_queue [$];

    axi_data_t axi2tx_queue [$];
    axi_data_t rx2axi_queue [$];

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tb_analysis_imp = new("tb_analysis_imp", this);
        rx_analysis_imp = new("rx_analysis_imp", this);
        tx_analysis_imp = new("tx_analysis_imp", this);

        w_req_analysis_imp = new("w_req_analysis_imp", this);
        w_rsp_analysis_imp = new("w_rsp_analysis_imp", this);
        r_req_analysis_imp = new("r_req_analysis_imp", this);
        r_rsp_analysis_imp = new("r_rsp_analysis_imp", this);

        if (!uvm_config_db #(virtual uart_intf)::get(this, "", "uart_intf", u_uart_intf)) begin
            `uvm_error(get_name(), "UART Interface NOT FOUND")
        end
    endfunction

    virtual function void write_tb(tb_seq_item item);
    endfunction

    virtual function void write_rx(uart_rx_seq_item item);
        counter += 1;
        `uvm_info(get_name(), $sformatf("\nC: %d - rx_item.rx_array: %b\n", counter, item.rx_array), UVM_LOW)
        rx_array_queue.push_back(item.rx_array);
    endfunction

    virtual function void write_tx(uart_tx_seq_item item);
        counter += 1;
        `uvm_info(get_name(), $sformatf("\nC: %d - tx_item.tx_array: %b\n", counter, item.tx_array), UVM_LOW)
        tx_array_queue.push_back(item.tx_array);
    endfunction

    virtual function void write_wreq(reg_req_seq_item item);
        counter += 1;
        `uvm_info(get_name(), $sformatf("\nC: %d - waddr: %b, wdata: %b\n", counter, item.addr, item.data), UVM_LOW)
        if (item.addr == `TX_FIFO_DATA_REG) begin
            axi2tx_queue.push_back(item.data);
        end
    endfunction

    virtual function void write_wrsp(reg_rsp_seq_item item);
    endfunction

    virtual function void write_rreq(reg_req_seq_item item);
        counter += 1;
        `uvm_info(get_name(), $sformatf("\nC: %d - raddr: %b, rdata: %b\n", counter, item.addr, item.data), UVM_LOW)
        if (item.addr == `RX_FIFO_DATA_REG) begin
            rx2axi_queue.push_back(item.data);
        end
    endfunction

    virtual function void write_rrsp(reg_rsp_seq_item item);
        counter += 1;
        `uvm_info(get_name(), $sformatf("\nC: %d - rdata: %b\n", counter, item.data), UVM_LOW)
    endfunction

    virtual function void extract_phase(uvm_phase phase);
        
        int tx_queue_size = 0;
        int rx_queue_size = 0;
        int tx_match_counter = 0;
        int rx_match_counter = 0;

        if (tx_array_queue.size() != axi2tx_queue.size())  begin
            `uvm_error("TX_DATA_MISMATCH", "AXI TX data and output TX data amounts did not match")
        end else begin
            tx_queue_size = tx_array_queue.size();
        end

        while ((tx_array_queue.size() > 0) && (axi2tx_queue.size() > 0)) begin
            serial_to_parallel_t txData = tx_array_queue.pop_front();
            serial_to_parallel_t axi2tx = axi2tx_queue.pop_front();

            if (txData != axi2tx) begin
                `uvm_error("TX_DATA_MISMATCH", "AXI TX data and output TX data did not match")
            end else begin
                tx_match_counter += 1;
            end
        end

        if (rx_array_queue.size() != rx2axi_queue.size())  begin
            `uvm_error("RX_DATA_MISMATCH", "AXI RX data and input RX data amounts did not match")
        end else begin
            rx_queue_size = rx_array_queue.size();
        end

        while ((rx_array_queue.size() > 0) && (rx2axi_queue.size() > 0)) begin
            serial_to_parallel_t rxData = rx_array_queue.pop_front();
            serial_to_parallel_t rx2axi = rx2axi_queue.pop_front();

            if (rxData != rx2axi) begin
                `uvm_error("RX_DATA_MISMATCH", "Input RX data and AXI RX data did not match")
            end else begin
                rx_match_counter += 1;
            end
        end

    endfunction
endclass

    
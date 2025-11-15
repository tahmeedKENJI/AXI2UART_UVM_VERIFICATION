`include "dependencies.svh"

interface uart_intf;

    logic tx;
    logic rx;

    uart_state_t tx_state = tb_pkg::IDLE;
    uart_state_t send_rx_state = tb_pkg::IDLE;
    uart_state_t recv_rx_state = tb_pkg::IDLE;

    logic parityEnable;
    logic parityType; // 0: odd, 1: even
    logic numStopBits;

    localparam int time_period = 10e9 / BAUD_RATE;

    task send_rx(logic [7:0] data);
        while (1) begin
            if (send_rx_state == tb_pkg::IDLE) begin
                rx <= '1;
                send_rx_state <= START;
                #(time_period);
            end else if (send_rx_state == START) begin
                rx <= '0;
                send_rx_state <= DATA;
                #(time_period);
            end else if (send_rx_state == DATA) begin
                for (int i = 0; i < 8; i++) begin
                    rx <= data[i];
                    if (i == 7) begin
                        if (parityEnable) send_rx_state <= PARITY;
                        else send_rx_state <= STOP; 
                    end
                    #(time_period);
                end
            end else if (send_rx_state == STOP) begin
                rx <= '1;
                send_rx_state <= tb_pkg::IDLE;
                #(time_period);
                return;
            end
        end
    endtask

    task recv_rx(output logic [7:0] data);
        while (1) begin
            if (recv_rx_state == tb_pkg::IDLE) begin
                recv_rx_state <= START;
                `uvm_info("UART_INTF", "SAMPLING INIT", UVM_HIGH)
                #(time_period / 2);
            end else if (recv_rx_state == START) begin
                if (rx != '0) `uvm_error("UART_INTF", "Rx Start bit violation")
                `uvm_info("UART_INTF", "SAMPLING START", UVM_HIGH)
                recv_rx_state <= DATA;
                #(time_period);
            end else if (recv_rx_state == DATA) begin
                for (int i = 0; i < 8; i++) begin
                    data[i] = rx;
                    `uvm_info("UART_INTF", $sformatf("SAMPLING DATA [i]: %b, rx: %b", data[i], rx), UVM_HIGH)
                    if (i == 7) begin
                        if (parityEnable) recv_rx_state <= PARITY;
                        else recv_rx_state <= STOP; 
                    end
                    #(time_period);
                end
            end else if (recv_rx_state == STOP) begin
                if (rx != '1) `uvm_error("UART_INTF", "Rx Stop bit violation")
                `uvm_info("UART_INTF", "SAMPLING STOP", UVM_HIGH)
                recv_rx_state <= tb_pkg::IDLE;
                return;
            end
        end
    endtask

    task recv_tx(output logic [7:0] data);
        while (1) begin
            if (tx_state == tb_pkg::IDLE) begin
                tx_state <= START;
                #(time_period / 2);
            end else if (tx_state == START) begin
                if (tx != '0) `uvm_error("UART_INTF", "Tx Start bit violation")
                tx_state <= DATA;
                #(time_period);
            end else if (tx_state == DATA) begin
                for (int i = 0; i < 8; i++) begin
                    data[i] = tx;
                    if (i == 7) begin
                        if (parityEnable) tx_state <= PARITY;
                        else tx_state <= STOP; 
                    end
                    #(time_period);
                end
            end else if (tx_state == STOP) begin
                if (tx != '1) `uvm_error("UART_INTF", "Tx Stop bit violation")
                tx_state <= tb_pkg::IDLE;
                return;
            end
        end
    endtask


endinterface

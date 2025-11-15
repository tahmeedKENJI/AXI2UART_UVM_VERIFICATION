`include "dependencies.svh"

interface uart_intf;

    logic tx;
    logic rx;

    uart_state_t tx_state = tb_pkg::IDLE;
    uart_state_t rx_state = tb_pkg::IDLE;

    logic parityEnable;
    logic parityType; // 0: odd, 1: even
    logic numStopBits;

    localparam int time_period = 10e9 / BAUD_RATE;

    task send_rx(logic [7:0] data);
        while (1) begin
            if (rx_state == tb_pkg::IDLE) begin
                rx <= '1;
                rx_state <= START;
                #(time_period);
            end else if (rx_state == START) begin
                rx <= '0;
                rx_state <= DATA;
                #(time_period);
            end else if (rx_state == DATA) begin
                for (int i = 0; i < 8; i++) begin
                    rx <= data[i];
                    if (i == 7) begin
                        if (parityEnable) rx_state <= PARITY;
                        else rx_state <= STOP; 
                    end
                    #(time_period);
                end
            end else if (rx_state == STOP) begin
                rx <= '1;
                rx_state <= tb_pkg::IDLE;
                #(time_period);
                break;
            end
        end
    endtask

    task recv_tx(logic [7:0] data);
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
                    data[i] <= tx;
                    if (i == 7) begin
                        if (parityEnable) tx_state <= PARITY;
                        else tx_state <= STOP; 
                    end
                    #(time_period);
                end
            end else if (tx_state == STOP) begin
                if (tx != '1) `uvm_error("UART_INTF", "Tx Stop bit violation")
                tx_state <= tb_pkg::IDLE;
                #(time_period);
                break;
            end
        end
    endtask

endinterface

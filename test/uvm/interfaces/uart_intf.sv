`include "dependencies.svh"

interface uart_intf;

    logic tx;
    logic rx;

    uart_state_t tx_state = tb_pkg::IDLE;
    uart_state_t send_rx_state = tb_pkg::IDLE;
    uart_state_t recv_rx_state = tb_pkg::IDLE;

    logic parityEnable;
    logic parityType; // 0: odd, 1: even
    logic [3:0] numDataBits;
    logic [1:0] numStopBits;
    int baudRate;
    int time_period;

    logic isConfigured;

    task configure_uart(logic isDefault, 
                        uart_config_t _uart_config);

        isConfigured = '1;

        if (isDefault) begin
            parityEnable = uart_default_config.parityEnable;
            parityType = uart_default_config.parityType;
            numDataBits = uart_default_config.numDataBits;
            numStopBits = uart_default_config.numStopBits;
            baudRate = uart_default_config.baudRate;
            time_period = 10e9 / uart_default_config.baudRate;
        end else begin
            parityEnable = _uart_config.parityEnable;
            parityType = _uart_config.parityType;
            numDataBits = _uart_config.numDataBits;
            numStopBits = _uart_config.numStopBits;
            baudRate = _uart_config.baudRate;
            time_period = 10e9 / _uart_config.baudRate;
        end
    endtask

    task get_configure_uart(output uart_config_t _uart_config);
        if (!isConfigured) `uvm_fatal("UART_INTF", "UART NOT CONFIGURED!!!")

        _uart_config.parityEnable = parityEnable;
        _uart_config.parityType = parityType;
        _uart_config.numDataBits = numDataBits;
        _uart_config.numStopBits = numStopBits;
        _uart_config.baudRate = baudRate;

    endtask

    task send_rx(logic [7:0] data);
        // send_rx_state = START;

        if (!isConfigured) `uvm_fatal("UART_INTF", "UART NOT CONFIGURED!!!")

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
                for (int i = 0; i < numDataBits; i++) begin
                    rx <= data[i];
                    if (i == numDataBits - 1) begin
                        if (parityEnable) send_rx_state <= tb_pkg::PARITY;
                        else send_rx_state <= STOP; 
                    end
                    #(time_period);
                end
            end else if (send_rx_state == tb_pkg::PARITY) begin
                if (parityType) begin
                    rx <= ~(^data);
                end else begin
                    rx <= (^data);
                end
                send_rx_state <= STOP;
                #(time_period);
            end else if (send_rx_state == STOP) begin
                for(int i = 0; i < numStopBits; i++) begin
                    rx <= '1;
                    if (i == numStopBits - 1) send_rx_state <= tb_pkg::IDLE;
                    #(time_period);
                end
                break;
            end
        end
    endtask

    task recv_rx(output logic [7:0] data, output logic parityOK);
        if (!isConfigured) `uvm_fatal("UART_INTF", "UART NOT CONFIGURED!!!")
        @(negedge rx);
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
                for (int i = 0; i < numDataBits; i++) begin
                    data[i] = rx;
                    `uvm_info("UART_INTF", $sformatf("SAMPLING DATA [i]: %b, rx: %b", data[i], rx), UVM_HIGH)
                    if (i == numDataBits - 1) begin
                        if (parityEnable) recv_rx_state <= tb_pkg::PARITY;
                        else recv_rx_state <= STOP; 
                    end
                    #(time_period);
                end
            end else if (recv_rx_state == tb_pkg::PARITY) begin
                if (parityType) begin
                    if (rx != ~(^data)) begin
                        `uvm_error("UART_INTF", "Rx Parity bit violation");
                        parityOK = '0;
                    end else parityOK = '1;
                end else begin
                    if (rx != (^data)) begin
                        `uvm_error("UART_INTF", "Rx Parity bit violation");
                        parityOK = '0;
                    end else parityOK = '1;
                end
                recv_rx_state <= STOP;
                #(time_period);
            end else if (recv_rx_state == STOP) begin
                if (rx != '1) `uvm_error("UART_INTF", "Rx Stop bit violation")
                `uvm_info("UART_INTF", "SAMPLING STOP", UVM_HIGH)
                recv_rx_state <= tb_pkg::IDLE;
                break;
            end
        end
    endtask

    task recv_tx(output logic [7:0] data, output logic parityOK);
        if (!isConfigured) `uvm_fatal("UART_INTF", "UART NOT CONFIGURED!!!")
        @(negedge tx);
        while (1) begin
            if (tx_state == tb_pkg::IDLE) begin
                tx_state <= START;
                #(time_period / 2);
            end else if (tx_state == START) begin
                if (tx != '0) `uvm_error("UART_INTF", "Tx Start bit violation")
                tx_state <= DATA;
                #(time_period);
            end else if (tx_state == DATA) begin
                for (int i = 0; i < numDataBits; i++) begin
                    data[i] = tx;
                    if (i == numDataBits - 1) begin
                        if (parityEnable) tx_state <= tb_pkg::PARITY;
                        else tx_state <= STOP; 
                    end
                    #(time_period);
                end
            end else if (tx_state == tb_pkg::PARITY) begin
                if (parityType) begin
                    if (rx != ~(^data)) begin
                        `uvm_error("UART_INTF", "Tx Parity bit violation");
                        parityOK = '0;
                    end else parityOK = '1;
                end else begin
                    if (rx != (^data)) begin
                        `uvm_error("UART_INTF", "Tx Parity bit violation");
                        parityOK = '0;
                    end else parityOK = '1;
                end
                tx_state <= STOP;
                #(time_period);
            end else if (tx_state == STOP) begin
                if (tx != '1) `uvm_error("UART_INTF", "Tx Stop bit violation")
                tx_state <= tb_pkg::IDLE;
                break;
            end
        end
    endtask


endinterface

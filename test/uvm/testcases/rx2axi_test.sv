`include "dependencies.svh"

class rx2axi_test extends base_test;

    `uvm_component_utils(rx2axi_test)

    function new(string name="rx2axi_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    int num_uart_data;
    uart_config_t uart_config_1, uart_config_2;

    virtual function void build_phase(uvm_phase phase);
        u_env = simple_env::type_id::create("u_env", this);
        if(!uvm_config_db#(virtual tb_intf)::get(this, "", "tb_intf", u_tb_intf)) begin
            `uvm_error(get_name(), "Testbench Interface NOT FOUND")
        end
        if(!uvm_config_db#(virtual uart_intf)::get(this, "", "uart_intf", u_uart_intf)) begin
            `uvm_error(get_name(), "UART Interface NOT FOUND")
        end
    endfunction

    virtual task configure_phase (uvm_phase phase);
        num_uart_data = 20;
        uart_config_1 = '{
            parityEnable : '0,
            parityType : '0,
            numDataBits : 8,
            numStopBits : 1,
            rx_int_en : '1,
            baudRate : 9600
        };
    endtask

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        apply_reset();
        #100ns;
        u_uart_intf.configure_uart('0, uart_config_1);
        send_uart_configuration(uart_config_1);

        repeat(num_uart_data) send_to_rx($urandom, '0);
        @(posedge u_tb_intf.clk);
        send_multi_axi_read(`RX_FIFO_DATA_REG, num_uart_data-1);

        repeat (25e2) @(posedge u_tb_intf.clk);

        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        string testname;
        void'($value$plusargs("TESTNAME=%s", testname));

        if ((uvm_report_server::get_server().get_id_count("UART_INTF_ERROR") == 0)
            && (uvm_report_server::get_server().get_id_count("AXI_INTF_ERROR") == 0)
            && (uvm_report_server::get_server().get_id_count("RX_DATA_MISMATCH") == 0)) begin
            $display("\033[1;32mTEST PASSED: \033[0m%s", testname);
        end else begin
            $display("\033[1;31mTEST FAILED: \033[0m%s", testname);
        end    
    endfunction

endclass

    
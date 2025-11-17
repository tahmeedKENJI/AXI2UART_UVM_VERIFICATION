`include "dependencies.svh"

module uvm_tb_top;

    logic clk;
    uart_config_t uart_config;

    tb_intf u_tb_intf (
        .clk        (clk)
    );

    axi_intf u_axi_intf (
        .clk        (clk)
    );

    uart_intf u_uart_intf ();

    uart_top #(
        .req_t      (tb_uvm_axi_req_t),
        .resp_t     (tb_uvm_axi_resp_t)
    ) u_dut (
        
        .arst_ni    (u_tb_intf.rst_n),   
        .clk_i      (clk),     
        .req_i      (u_axi_intf.axi_req),     
        .resp_o     (u_axi_intf.axi_resp),     
        .tx_o       (u_uart_intf.tx),   
        .rx_i       (u_uart_intf.rx),   
        .irq_o      ()
    );

    task automatic start_clk(int clk_freq_MHz);
        real time_period;
        time_period = 1000 / clk_freq_MHz;
        fork
            forever begin
                clk <= '0;
                #(time_period / 2);
                clk <= '1;
                #(time_period / 2);
            end
        join_none
    endtask

    initial begin
        string testname = "base_test";
        int clk_freq_MHz = 100;

        if (!$value$plusargs("TESTNAME=%s", testname)) testname = "base_test";
        if (!$value$plusargs("CLKFREQMHZ=%d", clk_freq_MHz)) clk_freq_MHz = 100;

        uart_config = '{
            parityEnable : '1,
            parityType : '0,
            numDataBits : 8,
            numStopBits : 1,
            baudRate : 9600
        };
        u_uart_intf.configure_uart('0, uart_config);

        uvm_config_db #(virtual tb_intf)::set(null, "*", "tb_intf", u_tb_intf);
        uvm_config_db #(virtual axi_intf)::set(null, "*", "axi_intf", u_axi_intf);
        uvm_config_db #(virtual uart_intf)::set(null, "*", "uart_intf", u_uart_intf);

        `uvm_info("TOP", $sformatf("\nSYS_CLK: %0d MHz\nTEST_NAME: %s\n", clk_freq_MHz, testname), UVM_HIGH)

        start_clk(clk_freq_MHz); // Specify Clock Speed

        run_test(testname);
    end

endmodule

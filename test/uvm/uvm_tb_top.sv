`include "dependencies.svh"

module uvm_tb_top;

    logic clk, rst_n;

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
        // uvm_config_db #()::set(null, "*", " ", );

        `uvm_info("TOP", $sformatf("\nSYS_CLK: %0d MHz\nTEST_NAME: %s\n", clk_freq_MHz, testname), UVM_HIGH)

        start_clk(clk_freq_MHz); // Specify Clock Speed

        run_test(testname);
    end

endmodule

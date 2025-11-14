import sys
import os

if len(sys.argv) < 1:
    sys.exit(1)

file_path = sys.argv[1]

os.makedirs(os.path.dirname(file_path), exist_ok=True)

content = f"""\
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
        $value$plusargs("TESTNAME=%s", testname);
        // uvm_config_db #()::set(null, "*", " ", );

        // start_clk(); // Specify Clock Speed

        run_test(testname);
    end

endmodule
"""

with open(file_path, "w") as f:
    f.write(content)
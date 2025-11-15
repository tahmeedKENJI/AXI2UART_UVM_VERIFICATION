`include "dependencies.svh"

interface tb_intf(
    input logic clk
);

    logic rst_n;

    task automatic apply_reset;
        rst_n <= '1;
        repeat (2) @(posedge clk);
        rst_n <= '0;
        repeat (4) @(posedge clk);
        rst_n <= '1;
    endtask

endinterface

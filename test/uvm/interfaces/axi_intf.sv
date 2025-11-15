`include "dependencies.svh"

interface axi_intf (
    input logic clk
);
    
    tb_uvm_axi_req_t    axi_req;
    tb_uvm_axi_resp_t   axi_resp;

endinterface

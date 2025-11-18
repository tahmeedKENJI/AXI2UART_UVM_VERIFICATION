`include "apb/typedef.svh"

module apb_to_simple_if #(
    parameter type         req_t    = base_pkg::apb_req_t,
    parameter type         resp_t   = base_pkg::apb_resp_t,
    parameter logic [63:0] MEM_BASE = '0,
    parameter int          MEM_SIZE = 32
) (
    input  logic  arst_ni,
    input  logic  clk_i,
    input  req_t  req_i,
    output resp_t resp_o,

    output logic                           mem_we_o,
    output logic [           MEM_SIZE-1:0] mem_waddr_o,
    output logic [$bits(req_i.pwdata)-1:0] mem_wdata_o,
    output logic [ $bits(req_i.pstrb)-1:0] mem_wstrb_o,
    input  logic [                    1:0] mem_wresp_i,

    output logic                           mem_re_o,
    output logic [           MEM_SIZE-1:0] mem_raddr_o,
    input  logic [$bits(req_i.pwdata)-1:0] mem_rdata_i,
    input  logic [                    1:0] mem_rresp_i
);

  localparam int ADDR_W = $bits(req_i.paddr);
  localparam int DATA_W = $bits(req_i.pwdata);

  logic                intr_req_o;
  logic [  ADDR_W-1:0] intr_addr_o;
  logic                intr_we_o;
  logic [  DATA_W-1:0] intr_wdata;
  logic [DATA_W/8-1:0] intr_wstrb;
  logic [  DATA_W-1:0] intr_rdata;

  assign mem_we_o = intr_req_o & intr_we_o;
  assign mem_waddr_o = intr_addr_o;
  assign mem_wdata_o = intr_wdata;
  assign mem_wstrb_o = intr_wstrb;

  assign mem_re_o = intr_req_o & ~intr_we_o;
  assign mem_raddr_o = intr_addr_o;

  assign intr_rdata = mem_rdata_i;

  apb_wrapper #(
      .ADDR_W   (ADDR_W),
      .DATA_W   (DATA_W),
      .MEM_SIZE (MEM_SIZE),
      .BASE_ADDR(MEM_BASE)
  ) u_apb_wrapper (
      .PCLK            (clk_i),
      .PRESETn         (arst_ni),
      .PSELx           (req_i.psel),
      .PENABLE         (req_i.penable),
      .PWRITE          (req_i.pwrite),
      .PWDATA          (req_i.pwdata),
      .PSTRB           (req_i.pstrb),
      .PADDR           (req_i.paddr),
      .PRDATA          (resp_o.prdata),
      .PREADY          (resp_o.pready),
      .PSLVERR         (resp_o.pslverr),
      .mem_req_o       (intr_req_o),
      .mem_addr_o      (intr_addr_o),
      .mem_we_o        (intr_we_o),
      .mem_wdata       (intr_wdata),
      .mem_wstrb       (intr_wstrb),
      .mem_rdata       (intr_rdata),
      .mem_error_i     (mem_wresp_i[0] | mem_wresp_i[1] | mem_rresp_i[0] | mem_rresp_i[1])
  );

endmodule

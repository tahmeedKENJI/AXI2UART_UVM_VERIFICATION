
// This module acts as a wrapper, connecting the APB bus interface to an internal
// memory. It integrates an APB state machine (`apb_fsm`), a generic memory block
// (`generic_mem`), and error generation logic (`err_gen`).

module apb_wrapper #(
    parameter int          ADDR_W     = 32,
    parameter int          DATA_W     = 64,
    parameter int          MEM_SIZE   = 32,
    parameter int unsigned BASE_ADDR  = 0
) (
    input  logic                PCLK,
    input  logic                PRESETn,
    input  logic                PSELx,
    input  logic                PENABLE,
    input  logic                PWRITE,
    input  logic [  DATA_W-1:0] PWDATA,
    input  logic [DATA_W/8-1:0] PSTRB,
    input  logic [  ADDR_W-1:0] PADDR,
    output logic [  DATA_W-1:0] PRDATA,
    output logic                PREADY,
    output logic                PSLVERR,

    output logic                mem_req_o,
    output logic [  ADDR_W-1:0] mem_addr_o,
    output logic                mem_we_o,
    output logic [  DATA_W-1:0] mem_wdata,
    output logic [DATA_W/8-1:0] mem_wstrb,
    input  logic [  DATA_W-1:0] mem_rdata,
    input  logic                mem_error_i
);

  assign mem_wdata = PWDATA;
  assign mem_wstrb  = PSTRB;

  // --- Address Translation ---
  // This section translates the system-level APB address (PADDR) to the local address
  // space of the internal memory (`generic_mem`). It calculates the required internal
  // address width and subtracts the base address to get the local address.
  localparam ADDR_W_T = MEM_SIZE;
  assign mem_addr_o = PADDR - BASE_ADDR;

  // --- Internal Signals ---
  logic [2:0] slv_err;  // Slave error flags from the error generator


  // --- APB State Machine Instance ---
  // This FSM implements the APB slave protocol logic.
  apb_fsm #(
      .DATA_W(DATA_W)
  ) fsm (
      .PCLK   (PCLK),
      .PRESETn(PRESETn),
      .PSELx(PSELx),
      .PENABLE(PENABLE),
      .PWRITE(PWRITE),
      .error(slv_err[0] | slv_err[1] | mem_error_i),
      .prdata_intr(mem_rdata),
      .req(mem_req_o),
      .we(mem_we_o),
      .PREADY(PREADY),
      .PSLVERR(PSLVERR),
      .PRDATA(PRDATA)
  );

  // --- Error Generator Instance ---
  // This module checks for address-related errors, such as out-of-bounds access.
  err_gen #(
      .ADDR_W(ADDR_W),
      .DATA_W(DATA_W),
      .MEM_SIZE(MEM_SIZE),
      .BASE_ADDR(BASE_ADDR)
  ) e_gen (
      .addr (PADDR),
      .error(slv_err)
  );

endmodule

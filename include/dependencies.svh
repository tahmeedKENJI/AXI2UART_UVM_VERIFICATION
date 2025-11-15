`ifndef _DEPENDENCIES_SVH_
`define _DEPENDENCIES_SVH_

`include "uvm_macros.svh"
`include "axi/typedef.svh"

import uvm_pkg::*;
import tb_pkg::*;

`AXI_TYPEDEF_ALL(tb_uvm_axi, logic [ADDR_WIDTH-1:0], logic [ID_WIDTH-1:0], logic [DATA_WIDTH-1:0], logic [STRB_WIDTH-1:0], logic [USER_WIDTH-1:0])

`endif


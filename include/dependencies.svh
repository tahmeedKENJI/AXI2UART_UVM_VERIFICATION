`ifndef _DEPENDENCIES_SVH_
`define _DEPENDENCIES_SVH_

`include "uvm_macros.svh"
`include "axi/typedef.svh"

import uvm_pkg::*;
import tb_pkg::*;

`AXI_TYPEDEF_ALL(tb_uvm_axi, axi_addr_t, axi_id_t, axi_data_t, axi_strb_t, axi_user_t)

`endif


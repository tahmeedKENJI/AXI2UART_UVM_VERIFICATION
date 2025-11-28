`ifndef _DEPENDENCIES_SVH_
`define _DEPENDENCIES_SVH_

`include "uvm_macros.svh"
`include "axi/typedef.svh"

import uvm_pkg::*;
import tb_pkg::*;

`AXI_TYPEDEF_ALL(tb_uvm_axi, axi_addr_t, axi_id_t, axi_data_t, axi_strb_t, axi_user_t)

`define CTRL_REG            8'h00
`define CLK_EN              0
`define TX_FIFO_FLUSH       1
`define RX_FIFO_FLUSH       2

`define CFG_REG             8'h04
`define PARITY_EN           0
`define PARITY_TYPE         1
`define STOP_BITS           2
`define RX_INT_EN           3

`define CLK_DIV_REG         8'h08

`define TX_FIFO_STAT_REG    8'h0C

`define RX_FIFO_STAT_REG    8'h10

`define TX_FIFO_DATA_REG    8'h14

`define RX_FIFO_DATA_REG    8'h18

`define RX_FIFO_PEEK_REG    8'h1C

`endif


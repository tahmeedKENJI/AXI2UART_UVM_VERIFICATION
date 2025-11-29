`include "dependencies.svh"

class simple_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(simple_scoreboard)

    function new(string name="simple_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    `uvm_analysis_imp_decl(_tb)
    `uvm_analysis_imp_decl(_rx)
    `uvm_analysis_imp_decl(_tx)
    `uvm_analysis_imp_decl(_wreq)
    `uvm_analysis_imp_decl(_wrsp)
    `uvm_analysis_imp_decl(_rreq)
    `uvm_analysis_imp_decl(_rrsp)

    uvm_analysis_imp_tb #(tb_seq_item, simple_scoreboard) tb_analysis_imp;
    uvm_analysis_imp_rx #(uart_rx_seq_item, simple_scoreboard) rx_analysis_imp;
    uvm_analysis_imp_tx #(uart_tx_seq_item, simple_scoreboard) tx_analysis_imp;

    uvm_analysis_imp_wreq #(reg_req_seq_item, simple_scoreboard) w_req_analysis_imp;
    uvm_analysis_imp_wrsp #(reg_rsp_seq_item, simple_scoreboard) w_rsp_analysis_imp;
    uvm_analysis_imp_rreq #(reg_req_seq_item, simple_scoreboard) r_req_analysis_imp;
    uvm_analysis_imp_rrsp #(reg_rsp_seq_item, simple_scoreboard) r_rsp_analysis_imp;

    int counter = 0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tb_analysis_imp = new("tb_analysis_imp", this);
        rx_analysis_imp = new("rx_analysis_imp", this);
        tx_analysis_imp = new("tx_analysis_imp", this);

        w_req_analysis_imp = new("w_req_analysis_imp", this);
        w_rsp_analysis_imp = new("w_rsp_analysis_imp", this);
        r_req_analysis_imp = new("r_req_analysis_imp", this);
        r_rsp_analysis_imp = new("r_rsp_analysis_imp", this);
    endfunction

    virtual function void write_tb(tb_seq_item item);
    endfunction

    virtual function void write_rx(uart_rx_seq_item item);
        counter += 1;
        `uvm_info(get_name(), $sformatf("\nC: %d - rx_item.rx_array: %b\n", counter, item.rx_array), UVM_LOW)
    endfunction

    virtual function void write_tx(uart_tx_seq_item item);
        counter += 1;
        `uvm_info(get_name(), $sformatf("\nC: %d - tx_item.tx_array: %b\n", counter, item.tx_array), UVM_LOW)
    endfunction

    virtual function void write_wreq(reg_req_seq_item item);
        counter += 1;
        `uvm_info(get_name(), $sformatf("\nC: %d - waddr: %b, wdata: %b\n", counter, item.addr, item.data), UVM_LOW)
    endfunction

    virtual function void write_wrsp(reg_rsp_seq_item item);
    endfunction

    virtual function void write_rreq(reg_req_seq_item item);
        counter += 1;
        `uvm_info(get_name(), $sformatf("\nC: %d - raddr: %b\n", counter, item.addr), UVM_LOW)
    endfunction

    virtual function void write_rrsp(reg_rsp_seq_item item);
        counter += 1;
        `uvm_info(get_name(), $sformatf("\nC: %d - rdata: %b\n", counter, item.data), UVM_LOW)
    endfunction
endclass

    
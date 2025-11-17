`include "dependencies.svh"

class simple_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(simple_scoreboard)

    function new(string name="simple_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    `uvm_analysis_imp_decl(_tb)
    `uvm_analysis_imp_decl(_rx)
    `uvm_analysis_imp_decl(_tx)
    `uvm_analysis_imp_decl(_req)
    `uvm_analysis_imp_decl(_rsp)

    uvm_analysis_imp_tb #(tb_seq_item, simple_scoreboard) tb_analysis_imp;
    uvm_analysis_imp_rx #(uart_rx_seq_item, simple_scoreboard) rx_analysis_imp;
    uvm_analysis_imp_tx #(uart_tx_seq_item, simple_scoreboard) tx_analysis_imp;

    uvm_analysis_imp_req #(reg_req_seq_item, simple_scoreboard) req_analysis_imp;
    uvm_analysis_imp_rsp #(reg_rsp_seq_item, simple_scoreboard) rsp_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tb_analysis_imp = new("tb_analysis_imp", this);
        rx_analysis_imp = new("rx_analysis_imp", this);
        tx_analysis_imp = new("tx_analysis_imp", this);

        req_analysis_imp = new("w_req_analysis_imp", this);
        rsp_analysis_imp = new("w_rsp_analysis_imp", this);
    endfunction

    virtual function void write_tb(tb_seq_item item);
    endfunction

    virtual function void write_rx(uart_rx_seq_item item);
        `uvm_info(get_name(), $sformatf("\nrx_item.rx_array: %b\n", item.rx_array), UVM_LOW)
    endfunction

    virtual function void write_tx(uart_tx_seq_item item);
        `uvm_info(get_name(), $sformatf("\ntx_item.tx_array: %b\n", item.tx_array), UVM_LOW)
    endfunction

    virtual function void write_req(reg_req_seq_item item);
    endfunction

    virtual function void write_rsp(reg_rsp_seq_item item);
    endfunction

endclass

    
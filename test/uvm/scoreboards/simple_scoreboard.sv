`include "dependencies.svh"

class simple_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(simple_scoreboard)

    function new(string name="simple_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    `uvm_analysis_imp_decl(_tb)

    uvm_analysis_imp_tb #(tb_seq_item, simple_scoreboard) tb_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tb_analysis_imp = new("tb_analysis_imp", this);
    endfunction

    virtual function void write_tb(tb_seq_item item);
    endfunction

endclass

    
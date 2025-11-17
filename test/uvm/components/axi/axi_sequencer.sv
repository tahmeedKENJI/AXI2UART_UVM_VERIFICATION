`include "dependencies.svh"

class axi_sequencer extends uvm_sequencer #(reg_req_seq_item);

    `uvm_component_utils(axi_sequencer)

    function new(string name="axi_sequencer", uvm_component parent=null);
        super.new(name, parent);
    endfunction

endclass

    
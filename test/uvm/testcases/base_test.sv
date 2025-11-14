`include "dependencies.svh"

class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    function new(string name="base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass

    
`include "dependencies.svh"

class axi_monitor extends uvm_monitor;

    `uvm_component_utils(axi_monitor)

    function new(string name="axi_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual axi_intf u_axi_intf;

    uvm_analysis_port #(reg_req_seq_item) req_analysis_port;
    uvm_analysis_port #(reg_rsp_seq_item) rsp_analysis_port;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual axi_intf)::get(this, "", "axi_intf", u_axi_intf)) begin
            `uvm_error(get_name(), "AXI Interface NOT FOUND")
        end
        req_analysis_port = new("w_req_analysis_port", this);
        rsp_analysis_port = new("w_rsp_analysis_port", this);

    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

endclass

    
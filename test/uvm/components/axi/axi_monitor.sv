`include "dependencies.svh"

class axi_monitor extends uvm_monitor;

    `uvm_component_utils(axi_monitor)

    function new(string name="axi_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual axi_intf u_axi_intf;

    uvm_analysis_port #(reg_req_seq_item) w_req_analysis_port;
    uvm_analysis_port #(reg_rsp_seq_item) w_rsp_analysis_port;
    uvm_analysis_port #(reg_req_seq_item) r_req_analysis_port;
    uvm_analysis_port #(reg_rsp_seq_item) r_rsp_analysis_port;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual axi_intf)::get(this, "", "axi_intf", u_axi_intf)) begin
            `uvm_error(get_name(), "AXI Interface NOT FOUND")
        end
        w_req_analysis_port = new("w_req_analysis_port", this);
        w_rsp_analysis_port = new("w_rsp_analysis_port", this);
        r_req_analysis_port = new("r_req_analysis_port", this);
        r_rsp_analysis_port = new("r_rsp_analysis_port", this);                
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        fork
            u_axi_intf.start_watch();
            sample_wxactn();
            sample_rxactn();
        join
    endtask

    task sample_wxactn();
        reg_req_seq_item w_req;
        reg_rsp_seq_item w_rsp;
        axi_addr_t addr;
        axi_data_t data [];
        int len;

        w_req = reg_req_seq_item::type_id::create("axi_mon_w_req");
        w_rsp = reg_rsp_seq_item::type_id::create("axi_mon_w_rsp");

        w_req.isWrite = '1;
        w_rsp.isWrite = '1;

        forever begin
            u_axi_intf.package_wxactn(addr, data, len);
            for (int i = 0; i <= len; i++) begin
                w_req.addr = addr;
                w_req.data = data[i];
                w_req_analysis_port.write(w_req);
                w_rsp_analysis_port.write(w_rsp);
            end
        end

    endtask

    task sample_rxactn();
        reg_req_seq_item r_req;
        reg_rsp_seq_item r_rsp;
        axi_addr_t addr;
        axi_data_t data [];
        int len;

        r_req = reg_req_seq_item::type_id::create("axi_mon_r_req");
        r_rsp = reg_rsp_seq_item::type_id::create("axi_mon_r_rsp");

        r_req.isWrite = '0;
        r_rsp.isWrite = '0;

        forever begin
            u_axi_intf.package_rxactn(addr, data, len);
            for (int i = 0; i <= len; i++) begin
                r_req.addr = addr;
                r_rsp.data = data[i];
                r_req_analysis_port.write(r_req);
                r_rsp_analysis_port.write(r_rsp);
            end
        end

    endtask

endclass

    
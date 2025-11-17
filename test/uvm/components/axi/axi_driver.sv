`include "dependencies.svh"

class axi_driver extends uvm_driver #(reg_req_seq_item);

    `uvm_component_utils(axi_driver)

    function new(string name="axi_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual axi_intf u_axi_intf;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual axi_intf)::get(this, "", "axi_intf", u_axi_intf)) begin
            `uvm_error(get_name(), "AXI Interface NOT FOUND")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        reg_req_seq_item item;

        super.run_phase(phase);
        forever begin
            @(posedge u_axi_intf.clk);
            item = reg_req_seq_item::type_id::create("axi_dvr_item");
            seq_item_port.get_next_item(item);

            if (item.isTest) begin
                if (item.isWrite) begin
                    test_axi_write(item.addr, item.len);
                end else begin
                    test_axi_read(item.addr, item.len);
                end
            end else begin
                if (item.isWrite) begin
                    send_axi_write(item.addr, item.data);
                end else begin
                    send_axi_read(item.addr);
                end
            end

            seq_item_port.item_done(item);
        end
    endtask

    task send_axi_read(axi_addr_t addr);
        axi_data_t data_array [];
        axi_resp_t resp_array [];
        int len = 0;

        data_array = new[len + 1];
        resp_array = new[len + 1];

        u_axi_intf.mstr_read_xactn(addr, len, 2, 1, data_array, resp_array);
    endtask

    task test_axi_read(axi_addr_t addr, int len);
        axi_data_t u_data [];
        axi_resp_t u_resp [];

        u_data = new[len + 1];
        u_resp = new[len + 1];

        u_axi_intf.mstr_read_xactn(addr, len, 2, 0, u_data, u_resp);
    endtask

    task send_axi_write(axi_addr_t addr, axi_data_t data);
        axi_data_t data_array [];
        axi_strb_t strb_array [];
        axi_resp_t resp;
        int len = 0;

        data_array = new[len + 1];
        strb_array = new[len + 1];

        data_array[0] = data;
        strb_array[0] = '1;

        u_axi_intf.mstr_write_xactn(addr, len, 2, 1, data_array, strb_array, resp);

    endtask

    task test_axi_write(axi_addr_t addr, int len);
        axi_data_t u_data [];
        axi_strb_t u_strb [];
        axi_resp_t u_resp;

        u_data = new[len + 1];
        u_strb = new[len + 1];

        for (int i = 0; i <= len; i++) begin
            u_data[i] =  $urandom;
            u_strb[i] = '1;
        end

        u_axi_intf.mstr_write_xactn(addr, len, 2, 0, u_data, u_strb, u_resp);
    endtask

endclass

    
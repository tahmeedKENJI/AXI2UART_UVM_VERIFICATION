`include "dependencies.svh"

interface axi_intf (
    input logic clk
);
    tb_uvm_axi_req_t    axi_req;
    tb_uvm_axi_resp_t   axi_resp;

    task mstr_write_xactn(axi_addr_t addr, int len, int size, int burst, axi_data_t data [], axi_strb_t strb [], output axi_resp_t resp);
        
        axi_id_t wid = $urandom;
        axi_id_t bid;
        logic last;

        send_aw(addr, len, size, burst, wid);
        for (int i = 0; i <= len; i++) begin
            if (i == len)   last = '1;
            else            last = '0;
            send_w(data[i], strb[i], last);
        end
        recv_b(resp, bid);
        if (wid != bid) `uvm_error("AXI_INTF", "Write Request and response ID mismatch")

    endtask

    task mstr_read_xactn(axi_addr_t addr, int len, int size, int burst, output axi_data_t data [], output axi_resp_t resp []);
        
        axi_id_t rid = $urandom;
        axi_id_t bid;
        logic last;

        send_ar(addr, len, size, burst, rid);
        for (int i = 0; i <= len; i++) begin
            recv_r(resp[i], data[i], bid, last);
            if (rid != bid) `uvm_error("AXI_INTF", "Write Request and response ID mismatch")
            if (i == len && ~last) `uvm_error("AXI_INTF", "No Last Read received") 
        end

    endtask

    task send_aw(axi_addr_t addr, int len, int size, int burst, axi_id_t id = 0);

        axi_req.aw_valid <= '1;
        axi_req.aw.id <= id;
        axi_req.aw.addr <= addr;
        axi_req.aw.len <= len;
        axi_req.aw.size <= size;
        axi_req.aw.burst <= burst;

        do @(posedge clk);
        while (!axi_resp.aw_ready);

        axi_req.aw_valid <= '0;

    endtask

    task send_ar(axi_addr_t addr, int len, int size, int burst, axi_id_t id = 0);

        axi_req.ar_valid <= '1;
        axi_req.ar.id <= id;
        axi_req.ar.addr <= addr;
        axi_req.ar.len <= len;
        axi_req.ar.size <= size;
        axi_req.ar.burst <= burst;

        do @(posedge clk);
        while (!axi_resp.ar_ready);

        axi_req.ar_valid <= '0;

    endtask

    task send_w(axi_data_t data, axi_strb_t strb, logic last);

        axi_req.w_valid <= '1;
        axi_req.w.data <= data;
        axi_req.w.strb <= strb;
        axi_req.w.last <= last;

        if (!last) begin
            do @(posedge clk);
            while (!axi_resp.w_ready);
        end else begin
            @(posedge clk);
            axi_req.w_valid <= '0;
        end

    endtask

    task recv_b(axi_resp_t resp, axi_id_t id = 0);

        axi_req.b_ready <= '1;
        do @(posedge clk);
        while (!axi_resp.b_valid);

        id <= axi_resp.b.id;
        resp <= axi_resp.b.resp;

        axi_req.b_ready <= '0;

    endtask

    task recv_r(axi_resp_t resp, axi_data_t data, axi_id_t id = 0, logic last);

        axi_req.r_ready <= '1;
        do @(posedge clk);
        while (!axi_resp.r_valid);

        id <= axi_resp.r.id;
        resp <= axi_resp.r.resp;
        data <= axi_resp.r.data;
        last <= axi_resp.r.last;

        axi_req.r_ready <= '0;

    endtask

endinterface

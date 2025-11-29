`include "dependencies.svh"

interface axi_intf (
    input logic clk
);
    tb_uvm_axi_req_t    axi_req;
    tb_uvm_axi_resp_t   axi_resp;

    tb_uvm_axi_aw_chan_t    aw_queue [$];
    tb_uvm_axi_w_chan_t     w_queue [$];
    tb_uvm_axi_b_chan_t     b_queue [$];
    tb_uvm_axi_ar_chan_t    ar_queue [$];
    tb_uvm_axi_r_chan_t     r_queue [$];

    tb_uvm_axi_aw_chan_t    aw_current;
    tb_uvm_axi_w_chan_t     w_current ;
    tb_uvm_axi_b_chan_t     b_current ;
    tb_uvm_axi_ar_chan_t    ar_current;
    tb_uvm_axi_r_chan_t     r_current ;

    tb_uvm_axi_aw_chan_t    aw_current_debug;
    tb_uvm_axi_w_chan_t     w_current_debug ;
    tb_uvm_axi_b_chan_t     b_current_debug ;
    tb_uvm_axi_ar_chan_t    ar_current_debug;
    tb_uvm_axi_r_chan_t     r_current_debug ;

    task mstr_write_xactn(axi_addr_t addr, int len, int size, int burst, axi_data_t data [], axi_strb_t strb [], output axi_resp_t resp);
        
        axi_id_t wid = $urandom;
        axi_id_t bid;
        logic last;

        fork
            send_aw(addr, len, size, burst, wid);
            for (int i = 0; i <= len; i++) begin
                if (i == len)   last = '1;
                else            last = '0;
                send_w(data[i], strb[i], last);
            end
            recv_b(resp, bid);        
        join
        if (wid != bid) `uvm_error("AXI_INTF_ERROR", "Write Request and response ID mismatch")

    endtask

    task mstr_read_xactn(axi_addr_t addr, int len, int size, int burst, output axi_data_t data [], output axi_resp_t resp []);
        
        axi_id_t rid = $urandom;
        axi_id_t bid;
        logic last;

        fork
            send_ar(addr, len, size, burst, rid);
            for (int i = 0; i <= len; i++) begin
                recv_r(resp[i], data[i], bid, last);
                if (rid != bid) `uvm_error("AXI_INTF_ERROR", "Write Request and response ID mismatch")
                if (i == len && ~last) `uvm_error("AXI_INTF_ERROR", "No Last Read received") 
            end
        join

    endtask

    task send_aw(axi_addr_t addr, int len, int size, int burst, axi_id_t id = 0);

        axi_req.aw = '0;

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

        axi_req.ar = '0;

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

        axi_req.w = '0;
        
        axi_req.w_valid <= '1;
        axi_req.w.data <= data;
        axi_req.w.strb <= strb;
        axi_req.w.last <= last;

        do @(posedge clk);
        while (!axi_resp.w_ready);

        axi_req.w_valid <= '0;


    endtask

    task recv_b(axi_resp_t resp, axi_id_t id = 0);

        axi_req.b_ready <= '1;
        do @(posedge clk);
        while (!axi_resp.b_valid);

        id = axi_resp.b.id;
        resp = axi_resp.b.resp;

        axi_req.b_ready <= '0;

    endtask

    task recv_r(axi_resp_t resp, axi_data_t data, axi_id_t id = 0, logic last);

        axi_req.r_ready <= '1;
        do @(posedge clk);
        while (!axi_resp.r_valid);

        id = axi_resp.r.id;
        resp = axi_resp.r.resp;
        data = axi_resp.r.data;
        last = axi_resp.r.last;

        axi_req.r_ready <= '0;

    endtask

    task start_watch();      
        fork
            forever begin
                if ((axi_req.aw_valid && axi_resp.aw_ready)) begin
                    aw_queue.push_back(axi_req.aw);
                    aw_current_debug = axi_req.aw;
                end
                @(posedge clk);
            end
            forever begin
                if ((axi_req.w_valid && axi_resp.w_ready)); begin
                    w_queue.push_back(axi_req.w);
                    w_current_debug = axi_req.w;
                end
                @(posedge clk);
            end
            forever begin
                if ((axi_req.b_ready && axi_resp.b_valid)) begin
                    b_queue.push_back(axi_resp.b);
                    b_current_debug = axi_resp.b;
                end
                @(posedge clk);
            end

            forever begin
                if ((axi_req.ar_valid && axi_resp.ar_ready)) begin
                    ar_queue.push_back(axi_req.ar);
                    ar_current_debug = axi_req.ar;
                end
                @(posedge clk);
            end
            forever begin
                if ((axi_req.r_ready && axi_resp.r_valid)) begin
                    r_queue.push_back(axi_resp.r);
                    r_current_debug = axi_resp.r;
                end
                @(posedge clk);
            end
        join
    endtask

    task automatic package_wxactn(output axi_addr_t addr, ref axi_data_t data [], output int req_len);
        while (1) begin
            if(aw_queue.size() > 0) begin
                aw_current = aw_queue.pop_front();
                data = new[aw_current.len + 1];

                do @(posedge clk);
                while (w_queue.size() <= aw_current.len);

                for (int i = 0; i <= aw_current.len; i++) begin
                    w_current = w_queue.pop_front();
                    data[i] = w_current.data;
                    if (i == aw_current.len && !(w_current.last)) `uvm_error("AXI_INTF_ERROR", "Write data last not found")
                end

                do @(posedge clk);
                while (!(b_queue.size() > 0));

                b_current = b_queue.pop_front();

                if (aw_current.id != b_current.id) `uvm_error("AXI_INTF_ERROR", "Write Queue ID mismatch")

                addr = aw_current.addr;
                req_len = aw_current.len;
                break;
            end
            @(posedge clk);
        end
    endtask
    
    task automatic package_rxactn(output axi_addr_t addr, ref axi_data_t data [], output int req_len);
        while (1) begin
            if(ar_queue.size() > 0) begin
                ar_current = ar_queue.pop_front();
                data = new[ar_current.len + 1];

                do @(posedge clk);
                while (r_queue.size() <= ar_current.len);

                for (int i = 0; i <= ar_current.len; i++) begin
                    r_current = r_queue.pop_front();
                    data[i] = r_current.data;
                    if (i == ar_current.len && !(r_current.last)) `uvm_error("AXI_INTF_ERROR", "Read data last not found")
                    if (ar_current.id != r_current.id) `uvm_error("AXI_INTF_ERROR", "Read Queue ID mismatch")
                end

                addr = ar_current.addr;
                req_len = ar_current.len;
                break;
            end
            @(posedge clk);
        end
    endtask

endinterface

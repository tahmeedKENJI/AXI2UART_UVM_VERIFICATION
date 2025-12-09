`include "dependencies.svh"

class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  simple_env u_env;
  virtual tb_intf u_tb_intf;
  virtual uart_intf u_uart_intf;

  uart_config_t uart_config;

  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    u_env = simple_env::type_id::create("u_env", this);
    if (!uvm_config_db#(virtual tb_intf)::get(this, "", "tb_intf", u_tb_intf)) begin
      `uvm_error(get_name(), "Testbench Interface NOT FOUND")
    end
    if (!uvm_config_db#(virtual uart_intf)::get(this, "", "uart_intf", u_uart_intf)) begin
      `uvm_error(get_name(), "UART Interface NOT FOUND")
    end
  endfunction

  virtual task configure_phase(uvm_phase phase);
    uart_config = '{
        parityEnable : '0,
        parityType : '0,
        numDataBits : 8,
        numStopBits : 1,
        rx_int_en : '1,
        baudRate : 9600
    };
    u_uart_intf.configure_uart('0, uart_config);
  endtask

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    apply_reset();
    #100ns;
    send_uart_configuration(uart_config);

    fork
      begin
        send_multi_axi_write(`TX_FIFO_DATA_REG, 1);
      end
      begin
        repeat (2) send_to_rx($urandom, '0);

        @(posedge u_tb_intf.clk);
        send_multi_axi_read(`RX_FIFO_DATA_REG, 1);
      end
    join

    repeat (200000) @(posedge u_tb_intf.clk);
    phase.drop_objection(this);
  endtask

  virtual function void report_phase(uvm_phase phase);
    string testname;
    void'($value$plusargs("TESTNAME=%s", testname));

    if (uvm_report_server::get_server().get_severity_count(UVM_ERROR) == 0) begin
      $display("\033[1;32mTEST PASSED: \033[0m%s", testname);
    end else begin
      $display("\033[1;31mTEST FAILED: \033[0m%s", testname);
    end
  endfunction

  task apply_reset;
    apply_reset_sequence u_apply_reset_sequence;
    u_apply_reset_sequence = apply_reset_sequence::type_id::create("u_apply_reset_sequence");
    u_apply_reset_sequence.start(u_env.u_tb_agent.u_tb_sequencer);
  endtask

  task send_to_rx(serial_to_parallel_t array, logic isRandom);
    send_rx_sequence u_seq;
    u_seq = send_rx_sequence::type_id::create("u_seq");

    u_seq.isRandomData = isRandom;
    u_seq.data = array;
    u_seq.start(u_env.u_uart_agent.u_uart_sequencer);
  endtask

  task send_axi_write(axi_addr_t addr, axi_data_t data);
    send_axi_sequence u_seq;
    u_seq = send_axi_sequence::type_id::create("u_seq_write");

    u_seq.isTest = '0;
    u_seq.isWrite = '1;
    u_seq.addr = addr;
    u_seq.data = data;
    u_seq.start(u_env.u_axi_agent.u_axi_w_sequencer);
  endtask

  task send_multi_axi_write(axi_addr_t addr, int len);
    send_axi_sequence u_seq;
    u_seq = send_axi_sequence::type_id::create("u_seq_write");

    u_seq.isTest = '1;
    u_seq.len = len;
    u_seq.isWrite = '1;
    u_seq.addr = addr;
    u_seq.data = $urandom;
    u_seq.start(u_env.u_axi_agent.u_axi_w_sequencer);
  endtask

  task send_axi_read(axi_addr_t addr);
    send_axi_sequence u_seq;
    u_seq = send_axi_sequence::type_id::create("u_seq_read");

    u_seq.isTest = '0;
    u_seq.isWrite = '0;
    u_seq.addr = addr;
    u_seq.start(u_env.u_axi_agent.u_axi_r_sequencer);
  endtask

  task send_multi_axi_read(axi_addr_t addr, int len);
    send_axi_sequence u_seq;
    u_seq = send_axi_sequence::type_id::create("u_seq_read");

    u_seq.isTest = '1;
    u_seq.len = len;
    u_seq.isWrite = '0;
    u_seq.addr = addr;
    u_seq.start(u_env.u_axi_agent.u_axi_r_sequencer);
  endtask

  task send_uart_configuration(uart_config_t uart_config, logic tx_flush = '0, logic rx_flush = '0);
    axi_data_t ctrl_data = '0;
    axi_data_t cfg_data = '0;
    axi_data_t clk_div_data = '0;
    int clk_freq_MHz;

    ctrl_data |= (1 << `CLK_EN);
    if (tx_flush) ctrl_data |= (1 << `TX_FIFO_FLUSH);
    if (rx_flush) ctrl_data |= (1 << `RX_FIFO_FLUSH);

    if (uart_config.parityEnable) cfg_data |= (1 << `PARITY_EN);
    if (uart_config.parityType) cfg_data |= (1 << `PARITY_TYPE);
    if (uart_config.numStopBits == 2) cfg_data |= (1 << `STOP_BITS);
    if (uart_config.rx_int_en) cfg_data |= (1 << `RX_INT_EN);

    if (!$value$plusargs("CLKFREQMHZ=%d", clk_freq_MHz)) clk_freq_MHz = 100;
    clk_div_data = int'((clk_freq_MHz * 1e6) / uart_config.baudRate) + 1;

    send_axi_write(`CTRL_REG, ctrl_data);
    send_axi_write(`CFG_REG, cfg_data);
    // send_axi_write(`CLK_DIV_REG, clk_div_data);

  endtask


  task recv_uart_configuration();
    send_axi_read(`CTRL_REG);
    send_axi_read(`CFG_REG);
  endtask

endclass


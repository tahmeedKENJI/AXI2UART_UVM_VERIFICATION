`include "dependencies.svh"

class simple_env extends uvm_env;

    `uvm_component_utils(simple_env)

    tb_agent u_tb_agent;
    uart_agent u_uart_agent;
    axi_agent u_axi_agent;
    simple_scoreboard u_scoreboard;

    function new(string name="simple_env", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        u_tb_agent = tb_agent::type_id::create("u_tb_agent", this);
        u_uart_agent = uart_agent::type_id::create("u_uart_agent", this);
        u_axi_agent = axi_agent::type_id::create("u_axi_agent", this);
        u_scoreboard = simple_scoreboard::type_id::create("u_scoreboard", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        u_tb_agent.u_tb_monitor.tb_analysis_port.connect(u_scoreboard.tb_analysis_imp);
        u_uart_agent.u_uart_monitor.rx_analysis_port.connect(u_scoreboard.rx_analysis_imp);
        u_uart_agent.u_uart_monitor.tx_analysis_port.connect(u_scoreboard.tx_analysis_imp);
        u_axi_agent.u_axi_monitor.req_analysis_port.connect(u_scoreboard.req_analysis_imp);
        u_axi_agent.u_axi_monitor.rsp_analysis_port.connect(u_scoreboard.rsp_analysis_imp);
    endfunction

endclass

    
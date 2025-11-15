`include "dependencies.svh"

class simple_env extends uvm_env;

    `uvm_component_utils(simple_env)

    tb_agent u_tb_agent;
    simple_scoreboard u_scoreboard;

    function new(string name="simple_env", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        u_tb_agent = tb_agent::type_id::create("u_tb_agent", this);
        u_scoreboard = simple_scoreboard::type_id::create("u_scoreboard", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        u_tb_agent.u_tb_monitor.tb_analysis_port.connect(u_scoreboard.tb_analysis_imp);
    endfunction

endclass

    
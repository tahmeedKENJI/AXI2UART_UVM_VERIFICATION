import sys
import os

if len(sys.argv) < 3:
    sys.exit(1)

file_path = sys.argv[1]
class_name = sys.argv[2]
base_class = sys.argv[3]

os.makedirs(os.path.dirname(file_path), exist_ok=True)

if ("driver" in base_class):
    content = f"""\
`include "dependencies.svh"

class {class_name} extends {base_class} #();

    `uvm_component_utils({class_name})

    function new(string name="{class_name}", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

endclass

    """

elif ("sequencer" in base_class):
    content = f"""\
`include "dependencies.svh"

class {class_name} extends {base_class} #();

    `uvm_component_utils({class_name})

    function new(string name="{class_name}", uvm_component parent=null);
        super.new(name, parent);
    endfunction

endclass

    """

elif (("agent" in base_class) or ("env" in base_class)):
    content = f"""\
`include "dependencies.svh"

class {class_name} extends {base_class};

    `uvm_component_utils({class_name})

    function new(string name="{class_name}", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

endclass

    """

elif ("scoreboard" in base_class):
    content = f"""\
`include "dependencies.svh"

class {class_name} extends {base_class};

    `uvm_component_utils({class_name})

    function new(string name="{class_name}", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    `uvm_analysis_imp_decl()

    uvm_analysis_imp #(, {class_name}) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_analysis_imp = new("m_analysis_imp", this);
    endfunction

    virtual function void write();
    endfunction

endclass

    """

elif ("monitor" in base_class):
    content = f"""\
`include "dependencies.svh"

class {class_name} extends {base_class};

    `uvm_component_utils({class_name})

    function new(string name="{class_name}", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #() mon_analysis_port;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_analysis_port = new("mon_analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

endclass

    """

else:
    content = f"""\
`include "dependencies.svh"

class {class_name} extends {base_class};

    `uvm_component_utils({class_name})

    function new(string name="{class_name}", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

endclass

    """

with open(file_path, "w") as f:
    f.write(content)
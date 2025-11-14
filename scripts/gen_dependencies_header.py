import sys
import os

if len(sys.argv) < 1:
    sys.exit(1)

file_path = sys.argv[1]

os.makedirs(os.path.dirname(file_path), exist_ok=True)

content = f"""\
`ifndef _DEPENDENCIES_SVH_
`define _DEPENDENCIES_SVH_

`include "uvm_macros.svh"
import uvm_pkg::*;

`endif

"""

with open(file_path, "w") as f:
    f.write(content)
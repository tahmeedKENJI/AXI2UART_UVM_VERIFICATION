import sys
import os

if len(sys.argv) < 2:
    sys.exit(1)

file_path = sys.argv[1]
class_name = sys.argv[2]

os.makedirs(os.path.dirname(file_path), exist_ok=True)

content = f"""\
`include "dependencies.svh"

class {class_name};
    
endclass

"""

with open(file_path, "w") as f:
    f.write(content)
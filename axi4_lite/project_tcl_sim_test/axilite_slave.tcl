# ///////////////////////////////////////////////////////////////////////////// 
#  Copyright (c) 2024 Talha Mahboob
#  
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#  
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
# ///////////////////////////////////////////////////////////////////////////// 

# Create a new project
create_project axilite_slave ./axilite_slave_prj -force

# Add RTL files to the project
add_files -fileset sources_1 [glob ../rtl/*.sv]

# Add testbench files to the simulation set
add_files -fileset sim_1 [glob ../sim/*.sv]

# Create and configure the simulation
# Create the simulation set if not already created
if {[get_filesets sim_1] == ""} {
    create_fileset sim_1 -type simulation
}

# Set the top module for simulation in the simulation set
set_property top tb_slave_axil [get_filesets sim_1]

# Launch the simulation
launch_simulation

# Run the simulation for a specified time
run 1000ns
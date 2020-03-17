# VHDL_clock
VHDL multi function clock

# compile with Quartus 9.x

1. git clone
2. create a new project from the directory of this repo
3. in the new project wizard of Quartus, import all the vhd files from /source
4. import VHDL_clock.bdf from folder /quartus_files, choose Cyclone II as device
5. set top-level entity as VHDL_clock
6. run compilation
7. set pin assignment
8. compile again

# directory usage
/source is used for store VHDL source code (.vhd files)<br>
/quartus_files is used for store other types of files like Quartus project, circuits, netform lists and simulation waves

# Quartus project
The project file is located at /quartus_files/VHDL_clock.qpf
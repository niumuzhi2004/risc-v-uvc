# analyze source files
exec xvlog -sv ../rtl/processor_pkg.sv
exec xvlog -sv ../rtl/alu.sv
exec xvlog -sv ../rtl/comparator.sv
exec xvlog -sv ../rtl/control_unit.sv
exec xvlog -sv ../rtl/extend.sv
exec xvlog -sv ../rtl/hazard_unit.sv
exec xvlog -sv ../rtl/register_file.sv
exec xvlog -sv ../rtl/pipeline_registers/regD.sv
exec xvlog -sv ../rtl/pipeline_registers/regF.sv
exec xvlog -sv ../rtl/pipeline_registers/regE.sv
exec xvlog -sv ../rtl/pipeline_registers/regM.sv
exec xvlog -sv ../rtl/pipeline_registers/regW.sv
exec xvlog -sv ../rtl/processor_top.sv

exec xvlog -sv ../tb/smoke/data_mem.sv
exec xvlog -sv ../tb/smoke/instr_mem.sv
exec xvlog -sv ../tb/smoke/tb_top.sv

# elaborate design
exec xelab -top tb_top -snapshot tb_top_snapshot \
    -debug typical \
    -timescale 1ns/1ps

# run simulation
exec xsim tb_top_snapshot -gui -tclbatch ./smoke/wave.tcl
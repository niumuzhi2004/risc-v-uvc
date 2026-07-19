# analyze RTL source files
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

# analyze testbench source files
exec xvlog -sv ../tb/uvm/interfaces/data_if.sv
exec xvlog -sv ../tb/uvm/interfaces/instr_if.sv
exec xvlog -sv ../tb/uvm/interfaces/debug_if.sv
exec xvlog -sv ../tb/assertions/processor_sva.sv

exec xvlog -sv -L uvm ../tb/uvm/tb_pkg.sv

exec xvlog -sv -L uvm ../tb/uvm/top/tb_top.sv

# elaborate design
exec xelab -top tb_top \
    -snapshot tb_top_snapshot \
    -L uvm \
    -timescale 1ns/1ps \
    -debug typical
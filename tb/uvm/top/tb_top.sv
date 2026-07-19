`include "uvm_macros.svh"

import uvm_pkg::*;
import tb_pkg::*;

module tb_top();

    // clock generation
    logic clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    data_if  data_if_inst(clk);
    debug_if debug_if_inst(clk);
    instr_if instr_if_inst(clk);

    processor #( 
        .PC_RESET(PC_RESET) 
    ) dut (
        .clk(clk),
        .rst_n(instr_if_inst.rst_n),
        .PCF(instr_if_inst.A),
        .InstrF(instr_if_inst.RD),
        .mem_addr(data_if_inst.A),
        .mem_wr_data(data_if_inst.WD),
        .mem_we(data_if_inst.WE),
        .mem_re(data_if_inst.RE),
        .mem_rd_data(data_if_inst.RD),
        .DebugRegFile(debug_if_inst.DebugRegFile),
        .Halt(debug_if_inst.Halt),
        .Instr(debug_if_inst.Instr),
        .PC(debug_if_inst.PC),
        .Valid(debug_if_inst.Valid)
    );

    bind processor processor_sva u_sva (
        .clk(clk),
        .rst_n(instr_if_inst.rst_n),
        .mem_re(dut.mem_re),
        .mem_we(dut.mem_we),
        .Halt(dut.Halt),
        .Valid(dut.Valid),
        .DebugRegFile(dut.DebugRegFile)
    );

    initial begin
        // set initial values
        instr_if_inst.RD    = 0;
        instr_if_inst.rst_n = 1;
        data_if_inst.RD     = 0;

        uvm_config_db #(virtual instr_if)::set(
            null, "uvm_test_top.environment.ins_agent.*", "vif", instr_if_inst
        );

        uvm_config_db #(virtual data_if)::set(
            null, "uvm_test_top.environment.data_agent.*", "vif", data_if_inst
        );

        uvm_config_db #(virtual debug_if)::set(
            null, "uvm_test_top.environment.debug_mon", "vif", debug_if_inst
        );

       run_test(); 
    end

    initial begin
        #(WATCHDOG_CYCLES_GLOBAL * CLK_PERIOD);
        `uvm_warning("WATCHDOG", "Simulation Timeout: Possible infinite loop.")
        $finish;
    end

endmodule
`ifndef TB_PKG
`define TB_PKG

package tb_pkg;

    import uvm_pkg::*;
    import processor_pkg::*;
    `include "uvm_macros.svh"

    `uvm_analysis_imp_decl(_iss)
    `uvm_analysis_imp_decl(_exp)
    `uvm_analysis_imp_decl(_act)
    `uvm_analysis_imp_decl(_coverage)

    parameter int WATCHDOG_CYCLES_PER_TEST = 200;
    parameter int WATCHDOG_CYCLES_GLOBAL   = 250;
    parameter int CLK_PERIOD               = 10; // ns
    parameter int PC_RESET                 = 32'h00000000;

    // instruction types
    typedef enum logic [5:0] { 
        LB, LH, LW, LBU, LHU,                                   // LOAD
        ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI,   // I-TYPE
        AUIPC, LUI,                                             // U-TYPE
        SB, SH, SW,                                             // S-TYPE
        ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND,       // R-TYPE
        BEQ, BNE, BLT, BGE, BLTU, BGEU,                         // B-TYPE
        JALR, JAL,                                              // JUMP
        NOP
    } instr_t;

    typedef enum logic [1:0] {
        LARGER, EQUAL, SMALLER
    } compare_t;

    // hazard types
    typedef enum logic [1:0] {
        NO_HAZARD, RAW, LOAD_STALL, JUMP_BRANCH
    } hazard_t;

    // RAW hazard stages
    typedef enum logic [1:0] {
        MATCH_MEM,  // rs1/rs2 in EX matches rd in MEM
        MATCH_WB,   // rs1/rs2 in EX matches rd in WB
        NO_MATCH    // rs1/rs2 in EX does not match rd
    } raw_stage_t;

    // hazard sequence
    typedef enum logic [3:0] {
        RAW_THEN_LOAD_STALL            = 4'b0000,
        LOAD_STALL_THEN_RAW            = 4'b0001,
        RAW_THEN_JUMP_OR_BRANCH        = 4'b0010,
        JUMP_OR_BRANCH_THEN_RAW        = 4'b0011,
        LOAD_STALL_THEN_JUMP_OR_BRANCH = 4'b0100,
        CONSECUTIVE_RAWS               = 4'b0110,
        CONSECUTIVE_LOAD_STALLS        = 4'b0111,
        CONSECUTIVE_JUMP_OR_BRANCHES   = 4'b1000
    } hazard_seq_t;


    // include testbench components
    `include "./agents/data_mem_agent/data_mem_seq_item.sv"
    `include "./agents/data_mem_agent/data_mem_sequencer.sv"
    `include "./agents/data_mem_agent/data_mem_monitor.sv"
    `include "./agents/data_mem_agent/data_mem_driver.sv"
    `include "./agents/data_mem_agent/data_mem_agent.sv"

    `include "./agents/instr_agent/instr_seq_item.sv"
    `include "./agents/instr_agent/instr_sequencer.sv"
    `include "./agents/instr_agent/instr_monitor.sv"
    `include "./agents/instr_agent/instr_driver.sv"
    `include "./agents/instr_agent/instr_agent.sv"

    `include "./debug_monitor/debug_seq_item.sv"
    `include "./debug_monitor/debug_monitor.sv"

    `include "./env/scoreboard.sv"
    `include "./env/iss.sv"
    `include "./env/coverage_collector.sv"
    `include "./env/env.sv"

    `include "./sequences/base_seq.sv"
    `include "./sequences/constrained_random_seq.sv"
    `include "./sequences/addr_alignment_seq.sv"
    `include "./sequences/consecutive_hazards_seq.sv"
    `include "./sequences/invalid_branch_seq.sv"
    `include "./sequences/invalid_jal_seq.sv"
    `include "./sequences/invalid_jalr_seq.sv"
    `include "./sequences/directed_testing_seq.sv"
    `include "./sequences/rand_without_jump_seq.sv"

    `include "./tests/base_test.sv"
    `include "./tests/constrained_random_test.sv"
    `include "./tests/addr_alignment_test.sv"
    `include "./tests/consecutive_hazards_test.sv"
    `include "./tests/invalid_branch_test.sv"
    `include "./tests/invalid_jal_test.sv"
    `include "./tests/invalid_jalr_test.sv"
    `include "./tests/directed_testing_test.sv"
    `include "./tests/rand_without_jump_test.sv"

endpackage

`endif
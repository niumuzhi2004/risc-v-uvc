`ifndef TB_PKG
`define TB_PKG

package tb_pkg;

    import uvm_pkg::*;
    import processor_pkg::*;
    `include "uvm_macros.svh"

    `uvm_analysis_imp_decl(_iss)

    typedef enum logic [5:0] { 
        LB, LH, LW, LBU, LHU,                                   // LOAD
        ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI,   // I-TYPE
        AUIPC, LUI,                                             // U-TYPE
        SB, SH, SW,                                             // S-TYPE
        ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND,       // R-TYPE
        BEQ, BNE, BLT, BGE, BLTU, BGEU,                         // B-TYPE
        JALR, JAL                                               // JUMP
    } instr_t;

endpackage

`endif
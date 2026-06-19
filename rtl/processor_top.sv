module processor #(
    parameter PC_RESET = 32'h00000000
) (
    input  logic        clk,
    input  logic        rst_n,

    // instruction memory interface
    output logic [31:0] PC_F,
    input  logic [31:0] instr_F,

    // data memory interface
    output logic [31:0] mem_addr,
    output logic [31:0] mem_wr_data,
    output logic [3:0]  mem_we,
    output logic        mem_re,
    input  logic [31:0] mem_rd_data,

    // register file debug port
    output logic [31:0] DebugRegFile [32],
    output logic        halt
)

endmodule
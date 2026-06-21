`timescale 1ns / 1ps

module tb_top();

    logic clk = 0;
    always #5 clk = ~clk;

    logic rst_n = 1;
    logic [31:0] PCF, InstrF, mem_addr, mem_wr_data, mem_rd_data;
    logic [3:0]  mem_we;
    logic mem_re;
    logic [31:0] DebugRegFile [32];
    logic Halt;

    processor CPU (
        .clk(clk),
        .rst_n(rst_n),
        .PCF(PCF),
        .InstrF(InstrF),
        .mem_addr(mem_addr),
        .mem_wr_data(mem_wr_data),
        .mem_we(mem_we),
        .mem_re(mem_re),
        .mem_rd_data(mem_rd_data),
        .DebugRegFile(DebugRegFile),
        .Halt(Halt)
    );

    instr_mem IM (
        .A(PCF[7:2]),
        .RD(InstrF)
    );

    data_mem  DM (
        .clk(clk),
        .A(mem_addr[7:2]),
        .WD(mem_wr_data),
        .WE(mem_we),
        .RE(mem_re),
        .RD(mem_rd_data)
    );

    initial begin

        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;

        @(posedge Halt);
        $finish;

    end
    
endmodule
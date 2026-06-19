module regM(
    input  logic clk,
    input  logic rst_n,

    // from control unit
    input  logic       HaltE,
    output logic       HaltM,
    input  logic       RegWriteE,
    output logic       RegWriteM,
    input  logic [1:0] ResultSrcE,
    output logic [1:0] ResultSrcM,
    input  logic       MemWriteE,
    output logic       MemWriteM,
    input  logic [1:0] MemWidthE,
    output logic [1:0] MemWidthM,
    input  logic       MemSignE,
    output logic       MemSignM,

    // from main pipeline
    input  logic        CompResultE,
    output logic        CompResultM,
    input  logic [31:0] ALUResultE,
    output logic [31:0] ALUResultM,
    input  logic [31:0] WriteDataE,
    output logic [31:0] WriteDataM,
    input  logic [4:0]  RdE,
    output logic [4:0]  RdM,
    input  logic [31:0] PCPlus4E,
    output logic [31:0] PCPlus4M
);

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            HaltM       <= 1'b0;
            RegWriteM   <= 1'b0;
            ResultSrcM  <= 2'b0;
            MemWriteM   <= 1'b0;
            MemWidthM   <= 2'b0;
            MemSignM    <= 1'b0;
            CompResultM <= 1'b0;
            ALUResultM  <= 32'b0;
            WriteDataM  <= 32'b0;
            RdM         <= 5'b0;
            PCPlus4M    <= 32'b0;
        end 
        else begin
            HaltM       <= HaltE;
            RegWriteM   <= RegWriteE;
            ResultSrcM  <= ResultSrcE;
            MemWriteM   <= MemWriteE;
            MemWidthM   <= MemWidthE;
            MemSignM    <= MemSignE;
            CompResultM <= CompResultE;
            ALUResultM  <= ALUResultE;
            WriteDataM  <= WriteDataE;
            RdM         <= RdE;
            PCPlus4M    <= PCPlus4E;
        end
    end
    
endmodule
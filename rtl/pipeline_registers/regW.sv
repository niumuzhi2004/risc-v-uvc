module regW(
    input logic clk,
    input logic rst_n,

    // from control unit
    input  logic       HaltM,
    output logic       HaltW,
    input  logic       RegWriteM,
    output logic       RegWriteW,
    input  logic [1:0] ResultSrcM,
    output logic [1:0] ResultSrcW,

    // from main pipeline
    input  logic        CompResultM,
    output logic        CompResultW,
    input  logic [31:0] ALUResultM,
    output logic [31:0] ALUResultW,
    input  logic [31:0] ReadDataM,
    output logic [31:0] ReadDataW,
    input  logic [4:0]  RdM,
    output logic [4:0]  RdW,
    input  logic [31:0] PCPlus4M,
    output logic [31:0] PCPlus4W
);

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            HaltW       <= 1'b0;
            RegWriteW   <= 1'b0;
            ResultSrcW  <= 2'b0;
            CompResultW <= 1'b0;
            ALUResultW  <= 32'b0;
            ReadDataW   <= 32'b0;
            RdW         <= 5'b0;
            PCPlus4W    <= 32'b0;
        end 
        else begin
            HaltW       <= HaltM;
            RegWriteW   <= RegWriteM;
            ResultSrcW  <= ResultSrcM;
            CompResultW <= CompResultM;
            ALUResultW  <= ALUResultM;
            ReadDataW   <= ReadDataM;
            RdW         <= RdM;
            PCPlus4W    <= PCPlus4M;
        end
    end
    
endmodule
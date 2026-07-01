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
    input  logic [31:0] InstrM,
    output logic [31:0] InstrW,
    input  logic        CompResultM,
    output logic        CompResultW,
    input  logic [31:0] ALUResultM,
    output logic [31:0] ALUResultW,
    input  logic [31:0] ReadDataM,
    output logic [31:0] ReadDataW,
    input  logic [31:0] PCM,
    output logic [31:0] PCW,
    input  logic [4:0]  RdM,
    output logic [4:0]  RdW,
    input  logic [31:0] PCPlus4M,
    output logic [31:0] PCPlus4W,
    input  logic        ValidM,
    output logic        ValidW
);

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            HaltW       <= 1'b0;
            RegWriteW   <= 1'b0;
            ResultSrcW  <= 2'b0;
            InstrW      <= 32'b0;
            CompResultW <= 1'b0;
            ALUResultW  <= 32'b0;
            ReadDataW   <= 32'b0;
            PCW         <= 32'b0;
            RdW         <= 5'b0;
            PCPlus4W    <= 32'b0;
            ValidW      <= 1'b0;
        end 
        else begin
            HaltW       <= HaltM;
            RegWriteW   <= RegWriteM;
            ResultSrcW  <= ResultSrcM;
            InstrW      <= InstrM;
            CompResultW <= CompResultM;
            ALUResultW  <= ALUResultM;
            ReadDataW   <= ReadDataM;
            PCW         <= PCM;
            RdW         <= RdM;
            PCPlus4W    <= PCPlus4M;
            ValidW      <= ValidM;
        end
    end
    
endmodule
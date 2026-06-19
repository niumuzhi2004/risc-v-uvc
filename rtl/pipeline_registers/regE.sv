module regE(
    input  logic clk,
    input  logic clr,
    input  logic rst_n,

    // from control unit
    input  logic       HaltD,
    output logic       HaltE,
    input  logic       RegWriteD,
    output logic       RegWriteE,
    input  logic [1:0] ResultSrcD,
    output logic [1:0] ResultSrcE,
    input  logic       MemWriteD,
    output logic       MemWriteE,
    input  logic [1:0] MemWidthD,
    output logic [1:0] MemWidthE,
    input  logic       MemSignD,
    output logic       MemSignE,
    input  logic       JumpD,
    output logic       JumpE,
    input  logic       BranchD,
    output logic       BranchE,
    input  logic [2:0] ALUControlD,
    output logic [2:0] ALUControlE,
    input  logic [1:0] ALUSrc1D,
    output logic [1:0] ALUSrc1E,
    input  logic       ALUSrc2D,
    output logic       ALUSrc2E,
    input  logic       AdderESrcD,
    output logic       AdderESrcE,
    input  logic       CompSignD,
    output logic       CompSignE,
    input  logic [1:0] CompOpD,
    output logic [1:0] CompOpE,

    // from main pipeline
    input  logic [31:0] RD1D,
    output logic [31:0] RD1E,
    input  logic [31:0] RD2D,
    output logic [31:0] RD2E,
    input  logic [4:0]  Rs1D,
    output logic [4:0]  Rs1E,
    input  logic [4:0]  Rs2D,
    output logic [4:0]  Rs2E,
    input  logic [31:0] PCD,
    output logic [31:0] PCE,
    input  logic [31:0] ImmExtD,
    output logic [31:0] ImmExtE,
    input  logic [4:0]  RdD,
    output logic [4:0]  RdE,
    input  logic [31:0] PCPlus4D,
    output logic [31:0] PCPlus4E
);

    always_ff @(posedge clk) begin
        if (~rst_n | clr) begin
            HaltE       <= 1'b0;
            RegWriteE   <= 1'b0;
            ResultSrcE  <= 2'b0;
            MemWriteE   <= 1'b0;
            MemWidthE   <= 2'b0;
            MemSignE    <= 1'b0;
            JumpE       <= 1'b0;
            BranchE     <= 1'b0;
            ALUControlE <= 3'b0;
            ALUSrc1E    <= 2'b0;
            ALUSrc2E    <= 1'b0;
            AdderESrcE  <= 1'b0;
            CompSignE   <= 1'b0;
            CompOpE     <= 2'b0;
            RD1E        <= 32'b0;
            RD2E        <= 32'b0;
            Rs1E        <= 5'b0;
            Rs2E        <= 5'b0;
            PCE         <= 32'b0;
            ImmExtE     <= 32'b0;
            RdE         <= 5'b0;
            PCPlus4E    <= 32'b0;
        end 
        else begin
            HaltE       <= HaltD;
            RegWriteE   <= RegWriteD;
            ResultSrcE  <= ResultSrcD;
            MemWriteE   <= MemWriteD;
            MemWidthE   <= MemWidthD;
            MemSignE    <= MemSignD;
            JumpE       <= JumpD;
            BranchE     <= BranchD;
            ALUControlE <= ALUControlD;
            ALUSrc1E    <= ALUSrc1D;
            ALUSrc2E    <= ALUSrc2D;
            AdderESrcE  <= AdderESrcD;
            CompSignE   <= CompSignD;
            CompOpE     <= CompOpD;
            RD1E        <= RD1D;
            RD2E        <= RD2D;
            Rs1E        <= Rs1D;
            Rs2E        <= Rs2D;
            PCE         <= PCD;
            ImmExtE     <= ImmExtD;
            RdE         <= RdD;
            PCPlus4E    <= PCPlus4D;
        end
    end

endmodule
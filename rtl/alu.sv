import processor_pkg::*;

module alu(
    input  logic [31:0] Src1,
    input  logic [31:0] Src2,
    input  logic [2:0]  ALUControl,
    output logic [31:0] ALUResult
);

    always_comb begin
        case (ALUControl)
            ALU_ADD: ALUResult = Src1 + Src2;
            ALU_SUB: ALUResult = Src1 - Src2;
            ALU_AND: ALUResult = Src1 & Src2;
            ALU_OR:  ALUResult = Src1 | Src2;
            ALU_XOR: ALUResult = Src1 ^ Src2;
            ALU_SLL: ALUResult = Src1 << Src2[4:0];
            ALU_SRL: ALUResult = Src1 >> Src2[4:0];
            ALU_SRA: ALUResult = $signed(Src1) >>> Src2[4:0];
            default: ALUResult = 32'b0;
        endcase
    end
    
endmodule
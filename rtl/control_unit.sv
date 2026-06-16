import processor_pkg::*;

module control_unit(
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7_5,

    output logic       RegWrite,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic [1:0] MemWidth,
    output logic       MemSign,
    output logic       Jump,
    output logic       Branch,
    output logic [2:0] ALUControl,
    output logic [1:0] ALUSrc1,
    output logic       ALUSrc2,
    output logic       AdderESrc,
    output logic       CompSign,
    output logic [1:0] CompOp, 
    output logic [2:0] ImmSrc,
    output logic       Halt
);

    always_comb begin

        case (op)
            I_LOAD: begin
                RegWrite   = 1'b1;
                ResultSrc  = RESULT_SEL_READ_DATA;
                MemWrite   = 1'b0;
                MemSign    = (funct3 inside {FUNCT3_LBU, FUNCT3_LHU}) ? 1'b0 : 1'b1;
                Jump       = 1'b0;
                Branch     = 1'b0;
                ALUControl = ALU_ADD;
                ALUSrc1    = ALU_SEL_RD1;
                ALUSrc2    = ALU_SEL_IMM_EXT;
                AdderESrc  = ADDER_SEL_RD1;     // don't care
                CompSign   = 1'b1;              // don't care
                CompOp     = COMP_EQ;           // don't care
                ImmSrc     = IMM_I_TYPE;
                Halt       = 1'b0;

                if (funct3 inside {FUNCT3_LB, FUNCT3_LBU})
                    MemWidth = MEM_SEL_BYTE;
                else if (funct3 inside {FUNCT3_LH, FUNCT3_LHU})
                    MemWidth = MEM_SEL_HALF;
                else
                    MemWidth = MEM_SEL_WORD;
            end

            I_TYPE: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                MemWidth  = MEM_SEL_BYTE;       // don't care
                MemSign   = 1'b1;               // don't care
                Jump      = 1'b0;
                Branch    = 1'b0;
                ALUSrc1   = ALU_SEL_RD1;
                ALUSrc2   = ALU_SEL_IMM_EXT;
                AdderESrc = ALU_SEL_RD1E;       // don't care
                ImmSrc    = IMM_I_TYPE;
                Halt      = 1'b0;

                if (funct3 == FUNCT3_SLTI) begin
                    ResultSrc = RESULT_SEL_COM_RESULT;
                    CompSign  = 1'b1;
                    CompOp    = COMP_LT;
                end
                else if (funct3 == FUNCT3_SLTIU) begin
                    ResultSrc = RESULT_SEL_COM_RESULT;
                    CompSign  = 1'b0;
                    CompOp    = COMP_LT;
                end
                else begin
                    ResultSrc = RESULT_SEL_ALU_RESULT;
                    CompSign  = 1'b1;           // don't care
                    CompOp    = COMP_EQ;        // don't care
                end

                case (funct3)
                    FUNCT3_ADDI:  ALUControl = ALU_ADD;
                    FUNCT3_SLLI:  ALUControl = ALU_SLL;
                    FUNCT3_SLTI:  ALUControl = ALU_ADD; // not in datapath
                    FUNCT3_SLTIU: ALUControl = ALU_ADD; // not in datapath
                    FUNCT3_XORI:  ALUControl = ALU_XOR;
                    FUNCT3_SRI:   ALUControl = funct7_5 ? ALU_SRA : ALU_SRL;
                    FUNCT3_ORI:   ALUControl = ALU_OR;
                    FUNCT3_ANDI:  ALUControl = ALU_AND;
                    default:      ALUControl = ALU_ADD;
                endcase
            end

            U_AUIPC: begin
                RegWrite   = 1'b1;
                ResultSrc  = RESULT_SEL_ALU_RESULT;
                MemWrite   = 1'b0;
                MemWidth   = MEM_SEL_BYTE;      // don't care
                MemSign    = 1'b1;              // don't care
                Jump       = 1'b0;
                Branch     = 1'b0;
                ALUControl = ALU_ADD;
                ALUSrc1    = ALU_SEL_PC;
                ALUSrc2    = ALU_SEL_IMM_EXT;
                AdderESrc  = ADDER_SEL_RD1;     // don't care
                CompSign   = 1'b1;              // don't care
                CompOp     = COMP_EQ;           // don't care
                ImmSrc     = IMM_U_TYPE;
                Halt       = 1'b0;
            end

            S_TYPE: begin
                RegWrite   = 1'b0;
                ResultSrc  = RESULT_SEL_ALU_RESULT;     // Not in datapath
                MemWrite   = 1'b1;
                MemSign    = 1'b1; 
                Jump       = 1'b0;
                Branch     = 1'b0;
                ALUControl = ALU_ADD;
                ALUSrc1    = ALU_SEL_RD1;
                ALUSrc2    = ALU_SEL_IMM_EXT;
                AdderESrc  = ADDER_SEL_RD1;     // don't care
                CompSign   = 1'b1;              // don't care
                CompOp     = COMP_EQ;           // don't care
                ImmSrc     = IMM_S_TYPE;
                Halt       = 1'b0;

                if (funct3 == FUNCT3_SB)
                    MemWidth = MEM_SEL_BYTE;
                else if (funct3 == FUNCT3_SH)
                    MemWidth = MEM_SEL_HALF;
                else
                    MemWidth = MEM_SEL_WORD;
            end

            R_TYPE: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                MemWidth  = MEM_SEL_BYTE;       // don't care
                MemSign   = 1'b1;               // don't care
                Jump      = 1'b0;
                Branch    = 1'b0;
                ALUSrc1   = ALU_SEL_RD1;
                ALUSrc2   = ALU_SEL_RD2;
                AdderESrc = ADDER_SEL_RD1;      // don't care
                ImmSrc    = IMM_B_TYPE;         // don't care
                Halt      = 1'b0;

                if (funct3 == FUNCT3_SLT) begin
                    ResultSrc = RESULT_SEL_COM_RESULT;
                    CompSign  = 1'b1;
                    CompOp    = COMP_LT;
                end
                else if (funct3 == FUNCT3_SLTU) begin
                    ResultSrc = RESULT_SEL_COM_RESULT;
                    CompSign  = 1'b0;
                    CompOp    = COMP_LT;
                end
                else begin
                    ResultSrc = RESULT_SEL_ALU_RESULT;
                    CompSign  = 1'b1;           // don't care
                    CompOp    = COMP_EQ;        // don't care
                end

                case (funct3)
                    FUNCT3_ADD_SUB: ALUControl = funct7_5 ? ALU_SUB : ALU_ADD;
                    FUNCT3_SLL:     ALUControl = ALU_SLL;
                    FUNCT3_SLT:     ALUControl = ALU_ADD; // not in datapath
                    FUNCT3_SLTU:    ALUControl = ALU_ADD; // not in datapath
                    FUNCT3_XOR:     ALUControl = ALU_XOR;
                    FUNCT3_SRL_SRA: ALUControl = funct7_5 ? ALU_SRA : ALU_SRL;
                    FUNCT3_OR:      ALUControl = ALU_OR;
                    FUNCT3_AND:     ALUControl = ALU_AND;
                    default:        ALUControl = ALU_ADD;
                endcase
            end

            U_LUI: begin
                RegWrite   = 1'b1;
                ResultSrc  = RESULT_SEL_ALU_RESULT;
                MemWrite   = 1'b0;
                MemWidth   = MEM_SEL_BYTE;      // don't care
                MemSign    = 1'b1;              // don't care
                Jump       = 1'b0;
                Branch     = 1'b0;
                ALUControl = ALU_ADD;
                ALUSrc1    = ALU_SEL_ZERO;
                ALUSrc2    = ALU_SEL_IMM_EXT;
                AdderESrc  = ADDER_SEL_RD1;     // don't care
                CompSign   = 1'b1;              // don't care
                CompOp     = COMP_EQ;           // don't care
                ImmSrc     = IMM_U_TYPE;
                Halt       = 1'b0;
            end

            B_TYPE: begin
                RegWrite   = 1'b0;
                ResultSrc  = RESULT_SEL_ALU_RESULT;
                MemWrite   = 1'b0;
                MemWidth   = MEM_SEL_BYTE;      // don't care
                MemSign    = 1'b1;              // don't care
                Jump       = 1'b0;
                Branch     = 1'b1;
                ALUControl = ALU_ADD;           // don't care
                ALUSrc1    = ALU_SEL_RD1;       // don't care
                ALUSrc2    = ALU_SEL_RD2;       // don't care
                AdderESrc  = ADDER_SEL_PC;
                ImmSrc     = IMM_B_TYPE;
                Halt       = 1'b0;

                if (funct3 inside {FUNCT3_BLTU, FUNCT3_BGEU})
                    CompSign = 1'b0;
                else
                    CompSign = 1'b1;
                
                case (funct3)
                    FUNCT3_BEQ:  CompOp = COMP_EQ;
                    FUNCT3_BNE:  CompOp = COMP_NE;
                    FUNCT3_BLT:  CompOp = COMP_LT;
                    FUNCT3_BGE:  CompOp = COMP_GE;
                    FUNCT3_BLTU: CompOp = COMP_LT;
                    FUNCT3_BGEU: CompOp = COMP_GE;
                    default:     CompOp = COMP_EQ;
                endcase
            end

            I_JALR: begin
                RegWrite   = 1'b1;
                ResultSrc  = RESULT_SEL_PC_PLUS_4;
                MemWrite   = 1'b0;
                MemWidth   = MEM_SEL_BYTE;      // don't care
                MemSign    = 1'b1;              // don't care
                Jump       = 1'b1;
                Branch     = 1'b0;
                ALUControl = ALU_ADD;           // don't care
                ALUSrc1    = ALU_SEL_RD1;       // don't care
                ALUSrc2    = ALU_SEL_RD2;       // don't care
                AdderESrc  = ADDER_SEL_RD1;
                CompSign   = 1'b1;              // don't care
                CompOp     = COMP_EQ;           // don't care
                ImmSrc     = IMM_I_TYPE;
                Halt       = 1'b0;
            end

            J_TYPE: begin
                RegWrite   = 1'b1;
                ResultSrc  = RESULT_SEL_PC_PLUS_4;
                MemWrite   = 1'b0;
                MemWidth   = MEM_SEL_BYTE;      // don't care
                MemSign    = 1'b1;              // don't care
                Jump       = 1'b1;
                Branch     = 1'b0;
                ALUControl = ALU_ADD;           // don't care
                ALUSrc1    = ALU_SEL_RD1;       // don't care
                ALUSrc2    = ALU_SEL_RD2;       // don't care
                AdderESrc  = ADDER_SEL_PC;
                CompSign   = 1'b1;              // don't care
                CompOp     = COMP_EQ;           // don't care
                ImmSrc     = IMM_J_TYPE;
                Halt       = 1'b0;
            end
            
            default: begin
                RegWrite   = 1'b0;
                ResultSrc  = RESULT_SEL_ALU_RESULT;
                MemWrite   = 1'b0; 
                MemWidth   = MEM_SEL_BYTE;
                MemSign    = 1'b1;
                Jump       = 1'b0;
                Branch     = 1'b0;
                ALUControl = ALU_ADD;
                ALUSrc1    = ALU_SEL_RD1;
                ALUSrc2    = ALU_SEL_RD2;
                AdderESrc  = ADDER_SEL_RD1;
                CompSign   = 1'b1;
                CompOp     = COMP_EQ;
                ImmSrc     = IMM_I_TYPE;
                Halt       = 1'b1;
            end
        endcase
        
    end
    
endmodule
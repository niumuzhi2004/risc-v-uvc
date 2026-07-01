import processor_pkg::*;

module processor #(
    parameter PC_RESET = 32'h00000000
) (
    input  logic        clk,
    input  logic        rst_n,

    // instruction memory interface
    output logic [31:0] PCF,
    input  logic [31:0] InstrF,

    // data memory interface
    output logic [31:0] mem_addr,
    output logic [31:0] mem_wr_data,
    output logic [3:0]  mem_we,
    output logic        mem_re,
    input  logic [31:0] mem_rd_data,

    // register file debug port
    output logic [31:0] DebugRegFile [32],
    output logic        Halt,
    output logic [31:0] Instr,
    output logic [31:0] PC,
    output logic        Valid
);

    // Fetch stage
    logic PCSrcE, StallF;
    logic [31:0] PCPlus4F, PCTargetE, PCF_p;

    regF #(PC_RESET) rF (clk, ~StallF, rst_n, PCF_p, PCF);

    always_comb begin
        PCF_p    = PCSrcE ? PCTargetE : PCPlus4F;       // PC source select mux
        PCPlus4F = PCF + 4;                             // PC plus 4 adder
    end


    // Decode stage
    logic [6:0] op;
    logic [2:0] funct3;
    logic funct7_5;
    logic [31:0] InstrD;

    assign op       = InstrD[6:0];
    assign funct3   = InstrD[14:12];
    assign funct7_5 = InstrD[30];

    logic HaltD, RegWriteD, MemWriteD, MemSignD, JumpD, BranchD, ALUSrc2D, AdderESrcD, CompSignD;
    logic [1:0] ResultSrcD, MemWidthD, ALUSrc1D, CompOpD;
    logic [2:0] ALUControlD, ImmSrcD;

    logic [4:0]  RdW;
    logic [31:0] ResultW;
    logic        RegWriteW;
    logic [31:0] RD1D, RD2D;
    logic [4:0]  Rs1D, Rs2D, RdD;
    logic [31:0] PCD, ImmExtD, PCPlus4D;

    logic StallD, FlushD;

    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD  = InstrD[11:7];

    regD rD (clk, ~StallD, FlushD, rst_n, InstrF, InstrD, PCF, PCD, PCPlus4F, PCPlus4D);
    control_unit CU (
        op, funct3, funct7_5, RegWriteD, ResultSrcD, MemWriteD, MemWidthD, MemSignD, JumpD,
        BranchD, ALUControlD, ALUSrc1D, ALUSrc2D, AdderESrcD, CompSignD, CompOpD, ImmSrcD, HaltD
    );
    register_file RF (
        clk, InstrD[19:15], InstrD[24:20], RdW, RegWriteW, ResultW, RD1D, RD2D, DebugRegFile
    );
    extend EXT (InstrD[31:7], ImmSrcD, ImmExtD);


    // Execute stage
    logic HaltE, RegWriteE, MemWriteE, MemSignE, JumpE, BranchE, ALUSrc2E, AdderESrcE, CompSignE;
    logic [1:0] ResultSrcE, MemWidthE, ALUSrc1E, CompOpE;
    logic [2:0] ALUControlE;

    logic [31:0] InstrE, RD1E, RD2E;
    logic [4:0]  Rs1E, Rs2E, RdE;
    logic [31:0] PCE, ImmExtE, PCPlus4E;
    logic [31:0] AddSrcE, Src1E, Src2E, Comp1E, Comp2E, ALUResultE, WriteDataE;
    logic CompResultE;
    logic [31:0] ResultM;

    logic FlushE;
    logic [1:0] ForwardAE, ForwardBE;
    logic ValidE;

    alu AU (Src1E, Src2E, ALUControlE, ALUResultE);
    comparator COM (CompSignE, CompOpE, Comp1E, Comp2E, CompResultE);
    regE rE (
        clk, FlushE, rst_n, HaltD, HaltE, RegWriteD, RegWriteE, ResultSrcD, ResultSrcE, 
        MemWriteD, MemWriteE, MemWidthD, MemWidthE, MemSignD, MemSignE, JumpD, JumpE, BranchD,
        BranchE, ALUControlD, ALUControlE, ALUSrc1D, ALUSrc1E, ALUSrc2D, ALUSrc2E, AdderESrcD,
        AdderESrcE, CompSignD, CompSignE, CompOpD, CompOpE, InstrD, InstrE, RD1D, RD1E, RD2D,
        RD2E, Rs1D, Rs1E, Rs2D, Rs2E, PCD, PCE, ImmExtD, ImmExtE, RdD, RdE, PCPlus4D, PCPlus4E  
    );

    always_comb begin
        PCSrcE = (CompResultE && BranchE) || JumpE;     // PCSrc logic
        
        case (ForwardAE)                                // ForwardA mux
            FORWARD_SEL_RDE:     Comp1E = RD1E;
            FORWARD_SEL_RESULTW: Comp1E = ResultW;
            FORWARD_SEL_RESULTM: Comp1E = ResultM;
            default:             Comp1E = RD1E;
        endcase

        case (ForwardBE)                                // ForwardB mux
            FORWARD_SEL_RDE:     WriteDataE = RD2E;
            FORWARD_SEL_RESULTW: WriteDataE = ResultW;
            FORWARD_SEL_RESULTM: WriteDataE = ResultM;
            default:             WriteDataE = RD2E;
        endcase

        case (ALUSrc1E)                                 // ALU input #1 mux
            ALU_SEL_RD1:  Src1E = Comp1E;
            ALU_SEL_PC:   Src1E = PCE;
            ALU_SEL_ZERO: Src1E = 32'b0;
            default:      Src1E = Comp1E;
        endcase

        case (ALUSrc2E)                                 // ALU input #2 mux
            ALU_SEL_RD2:     Src2E = WriteDataE;
            ALU_SEL_IMM_EXT: Src2E = ImmExtE;
            default:         Src2E = WriteDataE;
        endcase

        case (AdderESrcE)                               // PC target adder input #1 mux
            ADDER_SEL_RD1: AddSrcE = Comp1E;
            ADDER_SEL_PC:  AddSrcE = PCE;
            default:       AddSrcE = Comp1E;
        endcase

        Comp2E    = Src2E;                              // same wire
        PCTargetE = AddSrcE + ImmExtE;                  // PC target adder
        ValidE    = ~FlushE;                            // instruction is valid when no bubble
    end


    // Memory stage
    logic HaltM, RegWriteM, MemWriteM, MemSignM;
    logic [1:0] ResultSrcM, MemWidthM;

    logic CompResultM, ValidM;
    logic [4:0]  RdM;
    logic [31:0] InstrM, ReadDataM, ALUResultM, WriteDataM, PCM, PCPlus4M;

    assign mem_addr    = ALUResultM;
    assign mem_wr_data = WriteDataM;
    assign mem_re      = (ResultSrcM == RESULT_SEL_READ_DATA);

    regM rM (
        clk, rst_n, HaltE, HaltM, RegWriteE, RegWriteM, ResultSrcE, ResultSrcM, MemWriteE,
        MemWriteM, MemWidthE, MemWidthM, MemSignE, MemSignM, InstrE, InstrM, CompResultE, 
        CompResultM, ALUResultE, ALUResultM, WriteDataE, WriteDataM, PCE, PCM, RdE, RdM,
        PCPlus4E, PCPlus4M, ValidE, ValidM
    );

    logic [15:0] read_half;
    logic [7:0]  read_byte;

    always_comb begin

        case (ResultSrcM)                               // ResultM forwarding mux
            RESULT_SEL_COM_RESULT: ResultM = {31'b0, CompResultM};
            RESULT_SEL_ALU_RESULT: ResultM = ALUResultM;
            RESULT_SEL_PC_PLUS_4:  ResultM = PCPlus4M;
            default:               ResultM = ALUResultM;
        endcase

        if (MemWriteM) begin                            // memory write enable generation
            case (MemWidthM)
                MEM_SEL_WORD: mem_we = 4'b1111;
                MEM_SEL_HALF: begin
                    case (ALUResultM[1:0])
                        2'b00:   mem_we = 4'b0011;
                        2'b10:   mem_we = 4'b1100;
                        default: mem_we = 4'b0000;      // wrong alignment, block write 
                    endcase
                end
                MEM_SEL_BYTE: begin
                    case (ALUResultM[1:0])
                        2'b00:   mem_we = 4'b0001;
                        2'b01:   mem_we = 4'b0010;
                        2'b10:   mem_we = 4'b0100;
                        2'b11:   mem_we = 4'b1000;
                        default: mem_we = 4'b0000;      // wrong alignment, block write 
                    endcase
                end
                default: mem_we = 4'b0000;
            endcase
        end
        else begin
            mem_we = 4'b0000;
        end

        if (ResultSrcM == RESULT_SEL_READ_DATA) begin   // memory read width & sign logic 
            case (MemWidthM)
                MEM_SEL_WORD: ReadDataM = mem_rd_data;
                MEM_SEL_HALF: begin
                    case (ALUResultM[1:0])
                        2'b00:   read_half = mem_rd_data[15:0];
                        2'b10:   read_half = mem_rd_data[31:16];
                        default: read_half = 16'b0;     // wrong alignment, read invalid
                    endcase

                    if (MemSignM) ReadDataM = {{16{read_half[15]}}, read_half};
                    else          ReadDataM = {16'b0, read_half};
                end
                MEM_SEL_BYTE: begin
                    case (ALUResultM[1:0])
                        2'b00:   read_byte = mem_rd_data[7:0];
                        2'b01:   read_byte = mem_rd_data[15:8];
                        2'b10:   read_byte = mem_rd_data[23:16];
                        2'b11:   read_byte = mem_rd_data[31:24];
                        default: read_byte = 8'b0;      // wrong alignment, read invalid
                    endcase

                    if (MemSignM) ReadDataM = {{24{read_byte[7]}}, read_byte};
                    else          ReadDataM = {24'b0, read_byte};
                end
                default: ReadDataM = 32'b0;
            endcase
        end
        else begin
            ReadDataM = 32'b0;
        end
        
    end


    // Writeback stage
    logic HaltW;
    logic [1:0] ResultSrcW;

    logic CompResultW, ValidW;
    logic [31:0] InstrW, ALUResultW, ReadDataW, PCW, PCPlus4W;

    regW rW (
        clk, rst_n, HaltM, HaltW, RegWriteM, RegWriteW, ResultSrcM, ResultSrcW, 
        InstrM, InstrW, CompResultM, CompResultW, ALUResultM, ALUResultW, ReadDataM,
        ReadDataW, PCM, PCW, RdM, RdW, PCPlus4M, PCPlus4W, ValidM, ValidW
    );

    always_comb begin
        // make external
        Halt  = HaltW;
        Instr = InstrW;
        PC    = PCW;
        Valid = ValidW;
        
        case (ResultSrcW)                               // ResultW select mux
            RESULT_SEL_COM_RESULT: ResultW = {31'b0, CompResultW};
            RESULT_SEL_ALU_RESULT: ResultW = ALUResultW;
            RESULT_SEL_READ_DATA:  ResultW = ReadDataW;
            RESULT_SEL_PC_PLUS_4:  ResultW = PCPlus4W;
            default:               ResultW = ALUResultW;
        endcase
    end


    // Hazard unit
    hazard_unit HU(
        Rs1E, Rs2E, RdM, RdW, RegWriteM, RegWriteW, ForwardAE, ForwardBE, Rs1D, Rs2D,
        RdE, ResultSrcE, StallF, StallD, PCSrcE, FlushE, FlushD
    );


endmodule
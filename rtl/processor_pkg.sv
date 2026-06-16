package processor_pkg;

    // op code for RV32I instructions
    typedef enum logic [6:0] {
        I_LOAD  = 7'b0000011,
        I_TYPE  = 7'b0010011,
        U_AUIPC = 7'b0010111,
        S_TYPE  = 7'b0100011,
        R_TYPE  = 7'b0110011,
        U_LUI   = 7'b0110111,
        B_TYPE  = 7'b1100011,
        I_JALR  = 7'b1100111,
        J_TYPE  = 7'b1101111
    } op_t;

    // result select mux
    typedef enum logic [1:0] { 
        RESULT_SEL_ALU_RESULT = 2'b00,
        RESULT_SEL_READ_DATA  = 2'b01,
        RESULT_SEL_PC_PLUS_4  = 2'b10,
        RESULT_SEL_COM_RESULT = 2'b11
    } result_src_sel_t;

    // data memory access width select mux
    typedef enum logic [1:0] {
        MEM_SEL_BYTE = 2'b00,
        MEM_SEL_HALF = 2'b01,
        MEM_SEL_WORD = 2'b10
    } mem_width_sel_t;

    // ALU input #1 source select mux
    typedef enum logic [1:0] {
        ALU_SEL_RD1  = 2'b00,
        ALU_SEL_PC   = 2'b01,
        ALU_SEL_ZERO = 2'b10
    } alu_src1_sel_t;

    // ALU input #2 source select mux
    typedef enum logic { 
        ALU_SEL_RD2     = 1'b0,
        ALU_SEL_IMM_EXT = 1'b1
    } alu_src2_sel_t;

    // Ex stage adder input #1 source select mux
    typedef enum logic { 
        ADDER_SEL_RD1 = 1'b0,
        ADDER_SEL_PC  = 1'b1
    } adder_src_sel_t;

    // Comparator input #2 source select mux
    typedef enum logic {  
        COMP_SEL_RD2     = 1'b0,
        COMP_SEL_IMM_EXT = 1'b1
    } comparator_src_sel_t;

    // funct3 code for load instructions
    typedef enum logic[2:0] {
        FUNCT3_LB  = 3'b000,       // load byte
        FUNCT3_LH  = 3'b001,       // load half-word
        FUNCT3_LW  = 3'b010,       // load word
        FUNCT3_LBU = 3'b100,       // load byte unsigned
        FUNCT3_LHU = 3'b101        // load half-word unsigned
    } funct3_load_t;

    // funct3 code for store instructions
    typedef enum logic[2:0] {
        FUNCT3_SB  = 3'b000,       // store byte
        FUNCT3_SH  = 3'b001,       // store half-word
        FUNCT3_SW  = 3'b010        // store word
    } funct3_store_t;

    // funct3 code for I-type instructions
    typedef enum logic[2:0] {
        FUNCT3_ADDI  = 3'b000,
        FUNCT3_SLLI  = 3'b001,
        FUNCT3_SLTI  = 3'b010,
        FUNCT3_SLTIU = 3'b011,
        FUNCT3_XORI  = 3'b100,
        FUNCT3_SRI   = 3'b101,
        FUNCT3_ORI   = 3'b110,
        FUNCT3_ANDI  = 3'b111
    } funct3_Itype_t;

    // funct3 code for R-type instructions
    typedef enum logic[2:0] {
        FUNCT3_ADD_SUB = 3'b000,
        FUNCT3_SLL     = 3'b001,
        FUNCT3_SLT     = 3'b010,
        FUNCT3_SLTU    = 3'b011,
        FUNCT3_XOR     = 3'b100,
        FUNCT3_SRL_SRA = 3'b101,
        FUNCT3_OR      = 3'b110,
        FUNCT3_AND     = 3'b111
    } funct3_Rtype_t;

    // funct3 code for B-type instructions
    typedef enum logic [2:0] {  
        FUNCT3_BEQ  = 3'b000,
        FUNCT3_BNE  = 3'b001,
        FUNCT3_BLT  = 3'b100,
        FUNCT3_BGE  = 3'b101,
        FUNCT3_BLTU = 3'b110,
        FUNCT3_BGEU = 3'b111
    } funct3_Btype_t;

    // ALU operation select
    typedef enum logic [2:0] {
        ALU_ADD = 3'b000,          // addition
        ALU_SUB = 3'b001,          // subtraction
        ALU_AND = 3'b010,          // logical AND
        ALU_OR  = 3'b011,          // logical OR
        ALU_XOR = 3'b100,          // logical XOR
        ALU_SLL = 3'b101,          // shift left logical
        ALU_SRL = 3'b110,          // shift right logical
        ALU_SRA = 3'b111           // shift right arithmetic
    } alu_op_t;

    // comparator operation select
    typedef enum logic [1:0] {  
        COMP_EQ = 2'b00,            // equal to
        COMP_NE = 2'b01,            // not equal to
        COMP_LT = 2'b10,            // less than
        COMP_GE = 2'b11             // greater than or equal to
    } comp_op_t;

    // immediate encoding type
    typedef enum logic[2:0] {  
        IMM_J_TYPE = 3'b000,
        IMM_I_TYPE = 3'b001,
        IMM_S_TYPE = 3'b010,
        IMM_B_TYPE = 3'b011,
        IMM_U_TYPE = 3'b100
    } imm_src_t;


endpackage
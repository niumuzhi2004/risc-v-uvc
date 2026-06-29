class instr_seq_item extends uvm_sequence_item;

    rand instr_t instruction;
    rand logic [4:0]  rs1;
    rand logic [4:0]  rs2;
    rand logic [4:0]  rd;
    rand logic [19:0] imm;

    logic [6:0] op;
    logic [2:0] funct3;
    logic [6:0] funct7; // only bit 5 is significant for RV32I

    bit is_last = 0;    // for signaling program end

    `uvm_object_utils_begin(instr_seq_item)
        `uvm_field_enum(instr_t, instruction, UVM_ALL_ON)
        `uvm_field_int(rs1,     UVM_ALL_ON)
        `uvm_field_int(rs2,     UVM_ALL_ON)
        `uvm_field_int(rd,      UVM_ALL_ON)
        `uvm_field_int(imm,     UVM_ALL_ON)
        `uvm_field_int(op,      UVM_ALL_ON)
        `uvm_field_int(funct3,  UVM_ALL_ON)
        `uvm_field_int(funct7,  UVM_ALL_ON)
        `uvm_field_int(is_last, UVM_ALL_ON)
    `uvm_object_utils_end

    // constraints for immediate formatting per instruction type
    constraint imm_format { 
        if (instruction inside {ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND})
            imm == 20'b0; 
        else if (instruction inside {LB, LH, LW, LBU, LHU, ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI, JALR})
            imm[19:12] == 8'b0;
        else if (instruction inside {SB, SH, SW})
            imm[19:12] == 8'b0;
        else if (instruction inside {BEQ, BNE, BLT, BGE, BLTU, BGEU})
            imm[19:13] == 7'b0 && imm[0] == 1'b0;
        else if (instruction == JAL)
            imm[0] == 1'b0;
        else if (~(instruction inside {AUIPC, LUI}))
            imm == 20'b0;
    }

    // S-type and B-type instructions do not have rd
    constraint no_rd {
        (instruction inside {SB, SH, SW, BEQ, BNE, BLT, BGE, BLTU, BGEU}) -> rd == 5'b0;
    }

    // U-type and J-type instructions do not have rs1
    constraint no_rs1 {
        (instruction inside {AUIPC, LUI, JAL}) -> rs1 == 5'b0;
    }

    // I-, U-, and J-type instructions do not have rs2
    constraint no_rs2 {
        (instruction inside {
            LB, LH, LW, LBU, LHU, ADDI, SLLI, SLTI, SLTIU,
            XORI, SRLI, SRAI, ORI, ANDI, JALR, AUIPC, LUI, JAL
        }) -> rs2 == 5'b0;
    }

    // only part of imm needed for SLLI, SRLI, and SRAI
    constraint partial_imm {
        (instruction inside {SLLI, SRLI, SRAI}) -> imm[11:5] == 7'b0;
    }

    function new(string name = "instr_seq_item");
        super.new(name);
    endfunction

    function void post_randomize();

        case (instruction)
            LB:    funct3 = 3'b000;
            LH:    funct3 = 3'b001;
            LW:    funct3 = 3'b010;
            LBU:   funct3 = 3'b100;
            LHU:   funct3 = 3'b101;
            ADDI:  funct3 = 3'b000;
            SLLI:  funct3 = 3'b001;
            SLTI:  funct3 = 3'b010;
            SLTIU: funct3 = 3'b011;
            XORI:  funct3 = 3'b100;
            SRLI:  funct3 = 3'b101;
            SRAI:  funct3 = 3'b101;
            ORI:   funct3 = 3'b110;
            ANDI:  funct3 = 3'b111;
            SB:    funct3 = 3'b000;
            SH:    funct3 = 3'b001;
            SW:    funct3 = 3'b010;
            ADD:   funct3 = 3'b000;
            SUB:   funct3 = 3'b000;
            SLL:   funct3 = 3'b001;
            SLT:   funct3 = 3'b010;
            SLTU:  funct3 = 3'b011;
            XOR:   funct3 = 3'b100;
            SRL:   funct3 = 3'b101;
            SRA:   funct3 = 3'b101;
            OR:    funct3 = 3'b110;
            AND:   funct3 = 3'b111;
            BEQ:   funct3 = 3'b000;
            BNE:   funct3 = 3'b001;
            BLT:   funct3 = 3'b100;
            BGE:   funct3 = 3'b101;
            BLTU:  funct3 = 3'b110;
            BGEU:  funct3 = 3'b111;
            JALR:  funct3 = 3'b000;
            default: funct3 = 3'b0;
        endcase

        if (instruction inside {LB, LH, LW, LBU, LHU}) 
            op = 7'd3;
        else if (instruction inside {ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI})
            op = 7'd19;
        else if (instruction == AUIPC) 
            op = 7'd23;
        else if (instruction inside {SB, SH, SW})
            op = 7'd35;
        else if (instruction inside {ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND})
            op = 7'd51;
        else if (instruction == LUI)
            op = 7'd55;
        else if (instruction inside {BEQ, BNE, BLT, BGE, BLTU, BGEU})
            op = 7'd99;
        else if (instruction == JALR)
            op = 7'd103;
        else if (instruction == JAL)
            op = 7'd111;
        else 
            op = 7'b0;

        if (instruction inside {SRAI, SUB, SRA})
            funct7 = 7'b0100000;
        else 
            funct7 = 7'b0000000;

    endfunction

    // custom method for printing debug statement
    function string convert2string();
        return $sformatf(
            "Instruction %s: rs1 = %d, rs2 = %d, rd = %d, imm = %h",
            instruction.name(), rs1, rs2, rd, imm
        );
    endfunction

endclass
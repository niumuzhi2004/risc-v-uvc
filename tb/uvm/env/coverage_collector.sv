class coverage_collector extends uvm_component;
    `uvm_component_utils(coverage_collector)

    instr_t  instruction;
    logic    [4:0] rd;
    hazard_t prev_hazard; // hazard type of the previous instruction, if any
    logic    [31:0] prev_instr = 32'b0;

    // receive transactions from debug monitor
    uvm_analysis_imp_coverage #(debug_seq_item, coverage_collector) coverage_imp;

    covergroup load_cg with function sample(
        logic [11:0] immediate,
        logic [31:0] addr,
        logic [1:0]  addr_low_bits
    );
        // LOAD-01
        cp_instr_type: coverpoint instruction {
            bins is_lb  = { LB };
            bins is_lh  = { LH };
            bins is_lw  = { LW };
            bins is_lbu = { LBU };
            bins is_lhu = { LHU };
        }

        // LOAD-02
        cp_imm_value: coverpoint immediate {
            bins positive = { [12'h001:12'h7FF] };
            bins negative = { [12'h800:12'hFFF] };
            bins is_zero  = { 12'h000 };
        }

        // LOAD-03
        cp_addr_value: coverpoint addr {
            bins valid      = { [32'h0000_0000:32'h0011_1111] };
            bins above_top  = { [32'h0100_0000:32'h7FFF_FFFF] };
            bins below_base = { [32'h8000_0000:32'hFFFF_FFFF] };
        }

        // LOAD-04
        cp_addr_alignment: coverpoint addr_low_bits iff (instruction != LW) {
            bins zero_zero = { 2'b00 };
            bins zero_one  = { 2'b01 };
            bins one_zero  = { 2'b10 };
            bins one_one   = { 2'b11 };
        }

        // LOAD-05
        cp_rd: coverpoint rd {
            bins is_x0  = { 5'd0 };
            bins not_x0 = { [5'd1:5'd31] };
        }
    endgroup

    covergroup itype_cg with function sample(
        logic [11:0] immediate,
        logic [4:0]  uimm,
        compare_t    rs1_vs_imm
    );
        // ITYPE-01
        cp_instr_type: coverpoint instruction {
            bins is_addi  = { ADDI };
            bins is_slli  = { SLLI };
            bins is_slit  = { SLTI };
            bins is_slitu = { SLTIU };
            bins is_xori  = { XORI };
            bins is_srli  = { SRLI };
            bins is_srai  = { SRAI };
            bins is_ori   = { ORI };
            bins is_andi  = { ANDI };
        }

        // ITYPE-02
        cp_imm_value_add: coverpoint immediate iff (instruction == ADDI) {
            bins is_max = { 12'h7FF };
            bins is_pos = { [12'h001:12'h7FE] };
            bins zero   = { 12'h000 };
            bins is_neg = { [12'h801:12'hFFF] }; 
            bins is_min = { 12'h800 };
        }

        // ITYPE-03
        cp_uimm_value: coverpoint uimm iff (instruction inside {SLLI, SRLI, SRAI}) {
            bins is_max = { 5'b11111 };
            bins is_min = { 5'b00000 };
            bins in_bet = { [5'b00001:5'b11110] };
        }

        // ITYPE-04
        cp_rs1_vs_imm: coverpoint rs1_vs_imm iff (instruction inside {SLTI, SLTIU}) {
            bins is_larger  = { LARGER };
            bins is_equal   = { EQUAL };
            bins is_smaller = { SMALLER };
        }

        // ITYPE-05
        cp_imm_value_logic: coverpoint immediate iff (instruction inside {ANDI, ORI, XORI}) {
            bins is_max = { 12'hFFF };
            bins is_min = { 12'h000 };
            bins in_bet = { [12'h001:12'hFFE] };
        }

        // ITYPE-06
        cp_rd: coverpoint rd {
            bins is_x0  = { 5'd0 };
            bins not_x0 = { [5'd1:5'd31] };
        }
    endgroup

    covergroup utype_cg with function sample(
        logic [19:0] upimm
    );
        // UTYPE-01
        cp_instr_type: coverpoint instruction {
            bins is_auipc = { AUIPC };
            bins is_lui   = { LUI };
        }

        // UTYPE-02
        cp_upimm_value_auipc: coverpoint upimm iff (instruction == AUIPC) {
            bins is_min = { 20'hFFFFF };
            bins is_neg = { [20'h80000:20'hFFFFE] };
            bins is_pos = { [20'h00000:20'h7FFFE] };
            bins is_max = { 20'h7FFFF };
        }

        // UTYPE-03
        cp_upimm_value_lui: coverpoint upimm iff (instruction == LUI) {
            bins is_min  = { 20'hFFFFF };
            bins is_neg  = { [20'h80000:20'hFFFFE] };
            bins is_pos  = { [20'h00001:20'h7FFFE] };
            bins is_max  = { 20'h7FFFF };
            bins is_zero = { 20'h00000 };
        }

        // UTYPE-04
        cp_rd: coverpoint rd {
            bins is_x0  = { 5'd0 };
            bins not_x0 = { [5'd1:5'd31] };
        }
    endgroup

    covergroup rtype_cg with function sample(
        logic [31:0] rs1_value,
        logic [31:0] rs2_value,
        logic        overflow,
        logic        underflow,
        logic [4:0]  rs2_value_lower_bits, // rs2_value[4:0]
        compare_t    rs1_vs_rs2
    );
        // RTYPE-01
        cp_instr_type: coverpoint instruction {
            bins is_add  = { ADD };
            bins is_sub  = { SUB };
            bins is_sll  = { SLL };
            bins is_slt  = { SLT };
            bins is_sltu = { SLTU };
            bins is_xor  = { XOR };
            bins is_srl  = { SRL };
            bins is_sra  = { SRA };
            bins is_or   = { OR };
            bins is_and  = { AND };
        }

        // RTYPE-02
        cp_rs1: coverpoint rs1_value iff (instruction inside {ADD, SUB}) {
            bins is_pos  = { [32'h0000_0001:32'h7FFF_FFFF] };
            bins is_neg  = { [32'h8000_0000:32'hFFFF_FFFF] };
            bins is_zero = { 32'h0000_0000 };
        }

        cp_rs2: coverpoint rs2_value iff (instruction inside {ADD, SUB}) {
            bins is_pos  = { [32'h0000_0001:32'h7FFF_FFFF] };
            bins is_neg  = { [32'h8000_0000:32'hFFFF_FFFF] };
            bins is_zero = { 32'h0000_0000 };
        }

        cp_rs1_rs2: cross cp_rs1, cp_rs2;

        cp_overflow: coverpoint overflow iff (instruction inside {ADD, SUB}) {
            bins yes = { 1'b1 };
            bins no  = { 1'b0 };
        }

        cp_underflow: coverpoint underflow iff (instruction inside {ADD, SUB}) {
            bins yes = { 1'b1 };
            bins no  = { 1'b0 };
        }

        // RTYPE-03
        cp_rs2_lower_bits: coverpoint rs2_value_lower_bits iff (instruction inside {SLL, SRL, SRA}) {
            bins is_max = { 5'b11111 };
            bins is_min = { 5'b00000 };
            bins in_bet = { [5'b00001:5'b11110] };
        }

        // RTYPE-04
        cp_rs1_vs_rs2: coverpoint rs1_vs_rs2 iff (instruction inside {SLT, SLTU}) {
            bins is_larger  = { LARGER };
            bins is_equal   = { EQUAL };
            bins is_smaller = { SMALLER };
        }

        // RTYPE-05
        cp_rs1_val: coverpoint rs1_value iff (instruction inside {AND, OR, XOR}) {
            bins is_max = { 32'hFFFF_FFFF };
            bins is_min = { 32'h0000_0000 };
            bins in_bet = { [32'h0000_0001:32'hFFFF_FFFE] };
        }

        cp_rs2_val: coverpoint rs2_value iff (instruction inside {AND, OR, XOR}) {
            bins is_max = { 32'hFFFF_FFFF };
            bins is_min = { 32'h0000_0000 };
            bins in_bet = { [32'h0000_0001:32'hFFFF_FFFE] };
        }

        cp_rs1_rs2_val: cross cp_rs1_val, cp_rs2_val;

        // RTYPE-06
        cp_rd: coverpoint rd {
            bins is_x0  = { 5'd0 };
            bins not_x0 = { [5'd1:5'd31] };
        }
    endgroup

    covergroup stype_cg with function sample(
        logic [11:0] immediate,
        logic [31:0] addr,
        logic [1:0]  addr_low_bits
    );
        // STYPE-01
        cp_instr_type: coverpoint instruction {
            bins is_sb = { SB };
            bins is_sh = { SH };
            bins is_sw = { SW };
        }

        // STYPE-02
        cp_imm_value: coverpoint immediate {
            bins is_pos  = { [12'h001:12'h7FF] };
            bins is_neg  = { [12'h800:12'hFFF] };
            bins is_zero = { 12'h000 };
        }

        // STYPE-03
        cp_addr: coverpoint addr {
            bins valid      = { [32'h0000_0000:32'h0011_1111] };
            bins above_top  = { [32'h0100_0000:32'h7FFF_FFFF] };
            bins below_base = { [32'h8000_0000:32'hFFFF_FFFF] };
        }

        // STYPE-04
        cp_addr_alignment: coverpoint addr_low_bits iff (instruction != SW) {
            bins zero_zero = { 2'b00 };
            bins zero_one  = { 2'b01 };
            bins one_zero  = { 2'b10 };
            bins one_one   = { 2'b11 };
        }
    endgroup

    covergroup btype_cg with function sample(
        compare_t    rs1_vs_rs2,
        logic [31:0] sign_extended_imm,
        logic [31:0] PC_target,
        logic [1:0]  PC_target_lower_bits
    );
        // BTYPE-01
        cp_instr_type: coverpoint instruction {
            bins is_beq  = { BEQ };
            bins is_bne  = { BNE };
            bins is_blt  = { BLT };
            bins is_bge  = { BGE };
            bins is_bltu = { BLTU };
            bins is_bgeu = { BGEU };
        }

        // BTYPE-02
        cp_rs1_vs_rs2: coverpoint rs1_vs_rs2 {
            bins is_larger  = { LARGER };
            bins is_equal   = { EQUAL };
            bins is_smaller = { SMALLER };
        }

        cp_instr_rs1_vs_rs2: cross cp_instr_type, cp_rs1_vs_rs2;

        // BTYPE-03
        cp_sign_extended_imm: coverpoint sign_extended_imm {
            bins jumps_backward = { [32'h8000_0000:32'hFFFF_FFFF] };
            bins jumps_forward  = { [32'h0000_0001:32'h7FFF_FFFF] };
            bins does_not_jump  = { 32'h0000_0000 };
        }

        cp_PC_target: coverpoint PC_target {
            bins is_valid     = { [32'h0000_0000:32'h0000_00FF] };
            bins is_negative  = { [32'h8000_0000:32'hFFFF_FFFF] };
            bins out_of_range = { [32'h0000_0100:32'h7FFF_FFFF] };
        }

        // BTYPE-04
        cp_PC_alignment: coverpoint PC_target_lower_bits {
            bins is_aligned  = { 2'b00 };
            bins not_aligned = { [2'b01:2'b11] };
        }
    endgroup

    covergroup jalr_cg with function sample(
        logic [31:0] sign_extended_imm,
        logic [31:0] PC_target,
        logic [1:0]  PC_target_lower_bits
    );
        // JALR-01
        cp_sign_extended_imm: coverpoint sign_extended_imm {
            bins jumps_backward = { [32'h8000_0000:32'hFFFF_FFFF] };
            bins jumps_forward  = { [32'h0000_0005:32'h7FFF_FFFF] };
            bins does_not_jump  = { 32'h0000_0000 };
            bins jumps_to_next  = { 32'h0000_0004 };
        }

        cp_PC_target: coverpoint PC_target {
            bins is_valid     = { [32'h0000_0000:32'h0000_00FF] };
            bins is_negative  = { [32'h8000_0000:32'hFFFF_FFFF] };
            bins out_of_range = { [32'h0000_0100:32'h7FFF_FFFF] };
        }

        // JALR-02
        cp_rd: coverpoint rd {
            bins is_x0  = { 5'd0 };
            bins not_x0 = { [5'd1:5'd31] };
        }

        // JALR-03
        cp_PC_alignment: coverpoint PC_target_lower_bits {
            bins is_aligned  = { 2'b00 };
            bins not_aligned = { [2'b01:2'b11] };
        }
    endgroup

    covergroup jtype_cg with function sample(
        logic [31:0] sign_extended_imm,
        logic [31:0] PC_target,
        logic [1:0]  PC_target_lower_bits
    );
        // JTYPE-01
        cp_sign_extended_imm: coverpoint sign_extended_imm {
            bins jumps_backward = { [32'h8000_0000:32'hFFFF_FFFF] };
            bins jumps_forward  = { [32'h0000_0005:32'h7FFF_FFFF] };
            bins does_not_jump  = { 32'h0000_0000 };
            bins jumps_to_next  = { 32'h0000_0004 };
        }

        cp_PC_target: coverpoint PC_target {
            bins is_valid     = { [32'h0000_0000:32'h0000_00FF] };
            bins is_negative  = { [32'h8000_0000:32'hFFFF_FFFF] };
            bins out_of_range = { [32'h0000_0100:32'h7FFF_FFFF] };
        }

        // JTYPE-02
        cp_rd: coverpoint rd {
            bins is_x0  = { 5'd0 };
            bins not_x0 = { [5'd1:5'd31] };
        }

        // JTYPE-03
        cp_PC_alignment: coverpoint PC_target_lower_bits {
            bins is_aligned  = { 2'b00 };
            bins not_aligned = { [2'b01:2'b11] };
        }
    endgroup

    covergroup raw_cg with function sample(
        raw_stage_t rs1_stage,
        raw_stage_t rs2_stage,
        logic [4:0] rs1,
        logic [4:0] rs2,
        logic [4:0] rd_prev
    );
        // HAZARD-01 & HAZARD-02
        cp_rs1_stage: coverpoint rs1_stage {
            bins match_rd_mem = { MATCH_MEM };
            bins match_rd_wb  = { MATCH_WB };
            bins do_not_match = { NO_MATCH };
        }

        cp_rs2_stage: coverpoint rs2_stage {
            bins match_rd_mem = { MATCH_MEM };
            bins match_rd_wb  = { MATCH_WB };
            bins do_not_match = { NO_MATCH };
        }

        cp_rs1: coverpoint rs1 {
            bins is_x0  = { 5'd0 };
            bins not_x0 = { [5'd1:5'd31] };
        }

        cp_rs2: coverpoint rs2 {
            bins is_x0  = { 5'd0 };
            bins not_x0 = { [5'd1:5'd31] };
        }

        cp_rs1_rs2_stages: cross cp_rs1_stage, cp_rs2_stage, cp_rs1, cp_rs2;

        cp_rd_prev: coverpoint rd_prev {
            bins is_x0  = { 5'd0 };
            bins not_x0 = { [5'd1:5'd31] };
        }

        cp_rs1_rd_prev: cross cp_rs1, cp_rd_prev;
        cp_rs2_rd_prev: cross cp_rs2, cp_rd_prev;
    endgroup

    covergroup consecutive_hazard_cg with function sample(
        hazard_seq_t hazard_sequence
    );
        // HAZARD-04
        cp_hazard_sequence: coverpoint hazard_sequence {
            bins raw_then_load = { RAW_THEN_LOAD_STALL };
            bins load_then_raw = { LOAD_STALL_THEN_RAW };
            bins raw_then_jb   = { RAW_THEN_JUMP_OR_BRANCH };
            bins jb_then_raw   = { JUMP_OR_BRANCH_THEN_RAW };
            bins load_then_jb  = { LOAD_STALL_THEN_JUMP_OR_BRANCH };
            bins jb_then_load  = { JUMP_OR_BRANCH_THEN_LOAD_STALL };
            bins consec_raws   = { CONSECUTIVE_RAWS };
            bins consec_loads  = { CONSECUTIVE_LOAD_STALLS };
            bins consec_jbs    = { CONSECUTIVE_JUMP_OR_BRANCHES };
        }
    endgroup

    function new(string name = "coverage_collector", uvm_component parent = null);
        super.new(name, parent);
        load_cg               = new();
        itype_cg              = new();
        utype_cg              = new();
        rtype_cg              = new();
        stype_cg              = new();
        btype_cg              = new();
        jalr_cg               = new();
        jtype_cg              = new();
        raw_cg                = new();
        consecutive_hazard_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        coverage_imp = new("coverage_imp", this);
    endfunction

    function void write_coverage(debug_seq_item item);
        // decode instruction
        logic [6:0]  op          = item.Instr[6:0];
        logic [4:0]  rs1         = item.Instr[19:15];
        logic [4:0]  rs2         = item.Instr[24:20];
        logic [2:0]  funct3      = item.Instr[14:12];
        logic [6:0]  funct7      = item.Instr[31:25];
        logic [31:0] imm         = 32'b0;
        logic [31:0] addr        = 32'b0;
        logic [1:0]  comp_result = 2'b11; // 2'b00 -> a > b, 2'b01 -> a = b, 2'b10 -> a < b
        logic        overflow    = 1'b0;
        logic        underflow   = 1'b0;
        logic [31:0] PC_target   = 32'b0;
        logic [32:0] R_result    = 33'b0; // used for checking overflow/underflow in ADD/SUB instructions

        rd = item.Instr[11:7];

        case (op)
            7'd3: begin     // Load
                case (funct3)
                    3'b000:  instruction = LB;
                    3'b001:  instruction = LH;
                    3'b010:  instruction = LW;
                    3'b100:  instruction = LBU;
                    3'b101:  instruction = LHU;
                    default: instruction = NOP;
                endcase

                imm[11:0] = item.Instr[31:20];
                addr      = item.RegFile[rs1] + {{20{imm[11]}}, imm[11:0]};
                load_cg.sample(imm[11:0], addr, addr[1:0]);
            end

            7'd19: begin    // I-Type
                case (funct3)
                    3'b000:  instruction = ADDI;
                    3'b001:  instruction = SLLI;
                    3'b010:  instruction = SLTI;
                    3'b011:  instruction = SLTIU;
                    3'b100:  instruction = XORI;
                    3'b101:  instruction = (funct7[5]) ? SRAI : SRLI;
                    3'b110:  instruction = ORI;
                    3'b111:  instruction = ANDI;
                    default: instruction = NOP;
                endcase

                imm[11:0] = item.Instr[31:20];

                if (instruction == SLTI) begin
                    if ($signed(item.RegFile[rs1]) > $signed({{20{imm[11]}}, imm[11:0]})) 
                        comp_result = LARGER;
                    else if (item.RegFile[rs1] == {{20{imm[11]}}, imm[11:0]}) 
                        comp_result = EQUAL;
                    else 
                        comp_result = SMALLER;
                end
                else if (instruction == SLTIU) begin
                    if (item.RegFile[rs1] > {{20{imm[11]}}, imm[11:0]}) 
                        comp_result = LARGER;
                    else if (item.RegFile[rs1] == {{20{imm[11]}}, imm[11:0]}) 
                        comp_result = EQUAL;
                    else 
                        comp_result = SMALLER;
                end

                itype_cg.sample(imm[11:0], imm[4:0], comp_result);
            end

            7'd23: begin    // AUIPC
                instruction = AUIPC;
                imm[31:12]  = item.Instr[31:12];
                utype_cg.sample(imm[31:12]);
            end

            7'd35: begin    // S-Type
                case (funct3)
                    3'b000:  instruction = SB;
                    3'b001:  instruction = SH;
                    3'b010:  instruction = SW;
                    default: instruction = NOP;
                endcase

                imm[11:0] = {item.Instr[31:25], item.Instr[11:7]};
                addr      = item.RegFile[rs1] + {{20{imm[11]}}, imm[11:0]};
                stype_cg.sample(imm[11:0], addr, addr[1:0]);
            end

            7'd51: begin    // R-Type
                case (funct3)
                    3'b000:  instruction = (funct7[5]) ? SUB : ADD;
                    3'b001:  instruction = SLL;
                    3'b010:  instruction = SLT;
                    3'b011:  instruction = SLTU;
                    3'b100:  instruction = XOR;
                    3'b101:  instruction = (funct7[5]) ? SRA : SRL;
                    3'b110:  instruction = OR;
                    3'b111:  instruction = AND;
                    default: instruction = NOP;
                endcase

                if (instruction == ADD) begin
                    R_result = {1'b0, item.RegFile[rs1]} + {1'b0, item.RegFile[rs2]};
                    overflow  = R_result[32];
                end
                else if (instruction == SUB) begin
                    R_result = {1'b0, item.RegFile[rs1]} - {1'b0, item.RegFile[rs2]};
                    underflow = R_result[32];
                end

                else if (instruction == SLT) begin
                    if ($signed(item.RegFile[rs1]) > $signed(item.RegFile[rs2])) 
                        comp_result = LARGER;
                    else if (item.RegFile[rs1] == item.RegFile[rs2]) 
                        comp_result = EQUAL;
                    else 
                        comp_result = SMALLER;
                end
                else if (instruction == SLTU) begin
                    if (item.RegFile[rs1] > item.RegFile[rs2]) 
                        comp_result = LARGER;
                    else if (item.RegFile[rs1] == item.RegFile[rs2]) 
                        comp_result = EQUAL;
                    else 
                        comp_result = SMALLER;
                end

                rtype_cg.sample(item.RegFile[rs1], item.RegFile[rs2], overflow, underflow,
                                item.RegFile[rs2][4:0], comp_result);
            end

            7'd55: begin    // LUI
                instruction = LUI;
                imm[31:12]  = item.Instr[31:12];
                utype_cg.sample(imm[31:12]);
            end

            7'd99: begin    // B-Type
                case (funct3)
                    3'b000:  instruction = BEQ;
                    3'b001:  instruction = BNE;
                    3'b100:  instruction = BLT;
                    3'b101:  instruction = BGE;
                    3'b110:  instruction = BLTU;
                    3'b111:  instruction = BGEU;
                    default: instruction = NOP;
                endcase

                if (instruction inside {BEQ, BNE, BLT, BGE}) begin
                    if ($signed(item.RegFile[rs1]) > $signed(item.RegFile[rs2])) 
                        comp_result = LARGER;
                    else if (item.RegFile[rs1] == item.RegFile[rs2]) 
                        comp_result = EQUAL;
                    else 
                        comp_result = SMALLER;
                end
                else if (instruction inside {BLTU, BGEU}) begin
                    if (item.RegFile[rs1] > item.RegFile[rs2]) 
                        comp_result = LARGER;
                    else if (item.RegFile[rs1] == item.RegFile[rs2]) 
                        comp_result = EQUAL;
                    else 
                        comp_result = SMALLER;
                end

                imm[12:0]  = {item.Instr[31], item.Instr[7], item.Instr[30:25], item.Instr[11:8], 1'b0};
                imm[31:13] = {19{imm[12]}};
                PC_target  = item.PC + imm;

                btype_cg.sample(comp_result, imm, PC_target, PC_target[1:0]);
            end

            7'd103: begin   // JALR
                instruction = JALR;
                imm[11:0]   = item.Instr[31:20];
                imm[31:12]  = {20{imm[11]}};
                PC_target   = (item.RegFile[rs1] + imm);
                jalr_cg.sample(imm, PC_target, PC_target[1:0]);
            end

            7'd111: begin   // J-Type
                instruction = JAL;
                imm[20:0]   = {item.Instr[31], item.Instr[19:12], item.Instr[20], item.Instr[30:21], 1'b0};
                imm[31:21]  = {11{imm[20]}};
                PC_target   = item.PC + imm;
                jtype_cg.sample(imm, PC_target, PC_target[1:0]);
            end
        endcase

        hazard_t curr_hazard  = NO_HAZARD;

        if (prev_instr != 32'b0 && item.Instr != 32'b0) begin

            // identify RAW & load-stall hazards
            raw_stage_t rs1_stage = NO_MATCH;
            raw_stage_t rs2_stage = NO_MATCH;

            if (prev_instr[6:0] inside {7'd3, 7'd19, 7'd23, 7'd51, 7'd55, 7'd103, 7'd111}) begin
                if (prev_instr[11:7] == rs1) begin
                    curr_hazard = RAW;
                    if (prev_instr[6:0] == 7'd3) begin      // previous instruction is LOAD
                        rs1_stage = MATCH_WB;               // rs1 in EX matches rd in WB
                        curr_hazard = LOAD_STALL;
                    end
                    else
                        rs1_stage = MATCH_MEM;              // rs1 in EX matches rd in MEM
                end

                if (prev_instr[11:7] == rs2) begin
                    curr_hazard = RAW;
                    if (prev_instr[6:0] == 7'd3) begin      // previous instruction is LOAD
                        rs2_stage   = MATCH_WB;             // rs2 in EX matches rd in WB
                        curr_hazard = LOAD_STALL;
                    end
                    else
                        rs2_stage = MATCH_MEM;              // rs2 in EX matches rd in MEM
                end

                if (curr_hazard == RAW || curr_hazard == LOAD_STALL)
                    raw_cg.sample(rs1_stage, rs2_stage, rs1, rs2, prev_instr[11:7]);
            end

            // identify jump or branch hazards
            if (op inside {7'd99, 7'd103, 7'd111})
                curr_hazard = JUMP_BRANCH;

            // identify consecutive hazards, if any
            if (prev_hazard != NO_HAZARD && curr_hazard != NO_HAZARD) begin
                hazard_seq_t hazard_sequence;

                if (prev_hazard == RAW && curr_hazard == LOAD_STALL)
                    hazard_sequence = RAW_THEN_LOAD_STALL;
                else if (prev_hazard == LOAD_STALL && curr_hazard == RAW)
                    hazard_sequence = LOAD_STALL_THEN_RAW;
                else if (prev_hazard == RAW && curr_hazard == JUMP_BRANCH)
                    hazard_sequence = RAW_THEN_JUMP_OR_BRANCH;
                else if (prev_hazard == JUMP_BRANCH && curr_hazard == RAW)
                    hazard_sequence = JUMP_OR_BRANCH_THEN_RAW;
                else if (prev_hazard == LOAD_STALL && curr_hazard == JUMP_BRANCH)
                    hazard_sequence = LOAD_STALL_THEN_JUMP_OR_BRANCH;
                else if (prev_hazard == JUMP_BRANCH && curr_hazard == LOAD_STALL)
                    hazard_sequence = JUMP_OR_BRANCH_THEN_LOAD_STALL;
                else if (prev_hazard == RAW && curr_hazard == RAW)
                    hazard_sequence = CONSECUTIVE_RAWS;
                else if (prev_hazard == LOAD_STALL && curr_hazard == LOAD_STALL)
                    hazard_sequence = CONSECUTIVE_LOAD_STALLS;
                else if (prev_hazard == JUMP_BRANCH && curr_hazard == JUMP_BRANCH)
                    hazard_sequence = CONSECUTIVE_JUMP_OR_BRANCHES;

                consecutive_hazard_cg.sample(hazard_sequence);
            end
        end

        prev_instr  = item.Instr;
        prev_hazard = curr_hazard;

    endfunction

endclass
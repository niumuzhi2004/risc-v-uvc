// Directed Testing Sequence for HAZARD-04

class consecutive_hazards_seq extends base_seq;
    `uvm_object_utils(consecutive_hazards_seq)

    instr_seq_item prev_item;

    // covers all hazard combinations
    // each jump/branch jumps exactly two instructions ahead
    // NO_HAZARD instruction padded after every jump/branch

    hazard_t hazard_list [] = '{ 
        RAW, LOAD_STALL, RAW, JUMP_BRANCH, NO_HAZARD, RAW, LOAD_STALL,
        JUMP_BRANCH, NO_HAZARD, LOAD_STALL, RAW, RAW, LOAD_STALL,
        LOAD_STALL, RAW, JUMP_BRANCH, NO_HAZARD, JUMP_BRANCH, NO_HAZARD
    };

    constraint program_length {
        program_size == 20;     // override randomized program size in base_seq
    }

    function new(string name = "consecutive_hazards_seq");
        super.new(name);
    endfunction

    virtual task generate_program();

        // generate first instruction
        instr_seq_item first_item = instr_seq_item::type_id::create("first_item");
        if (!first_item.randomize() with {
            // instruction needs to have an rd field
            instruction inside {
                LB, LH, LW, LBU, LHU, ADDI, SLLI, SLTI, SLTIU,
                XORI, SRLI, SRAI, ORI, ANDI, AUIPC, ADD, SUB, SLL,
                SLT, SLTU, XOR, SRL, SRA, OR, AND, LUI
            };

            rd != 5'b0; // guard against x0
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(first_item);
        prev_item = first_item;

        foreach (hazard_list[i]) begin
            instr_seq_item item = instr_seq_item::type_id::create("item");
            generate_hazard(item, hazard_list[i]);
            program_items.push_back(item);
            prev_item = item;
        end

    endtask

    task generate_hazard(instr_seq_item curr_item, hazard_t hazard_type);

        case (hazard_type)
            RAW: begin
                if (!curr_item.randomize() with {
                    // instruction needs to have rd and rs1 fields (R-type or I-type)
                    instruction inside {
                        LB, LH, LW, LBU, LHU, ADDI, SLLI, SLTI, SLTIU,
                        XORI, SRLI, SRAI, ORI, ANDI, ADD, SUB, SLL,
                        SLT, SLTU, XOR, SRL, SRA, OR, AND
                    };

                    instruction inside {    // I-type
                        LB, LH, LW, LBU, LHU, ADDI, SLLI, SLTI, SLTIU,
                        XORI, SRLI, SRAI, ORI, ANDI
                    } -> (rs1 == prev_item.rd);

                    instruction inside {    // R-type
                        ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
                    } -> (rs1 == prev_item.rd) || (rs2 == prev_item.rd);

                    rd != 5'b0;

                }) begin
                    `uvm_error("Body", "Randomization failed!")
                end
            end

            LOAD_STALL: begin
                if (!curr_item.randomize() with {
                    // instruction needs to be LOAD type
                    instruction inside { LB, LH, LW, LBU, LHU };
                    rs1 == prev_item.rd;
                    rd  != 5'b0; 
                }) begin
                    `uvm_error("Body", "Randomization failed!")
                end
            end

            JUMP_BRANCH: begin
                if (!curr_item.randomize() with {
                    // for convenience we use JAL to represent jump/branch operations
                    instruction == JAL;
                    imm[19:1]   == {18'b0, 1'b1}; // PC = PC + 8
                    rd          != 5'b0;
                }) begin
                    `uvm_error("Body", "Randomization failed!")
                end
            end

            NO_HAZARD: begin
                if (!curr_item.randomize()) begin
                    `uvm_error("Body", "Randomization failed!")
                end
            end
            
            default: begin
                if (!curr_item.randomize()) begin
                    `uvm_error("Body", "Randomization failed!")
                end
            end
        endcase

    endtask

endclass
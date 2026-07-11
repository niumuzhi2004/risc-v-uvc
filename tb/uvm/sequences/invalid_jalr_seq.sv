// Directed Testing Sequence for JALR-01

// test program
// jalr xn, x0, -252 -> JALR-01-E
// jalr xn, x0, 234  -> JALR-01-F
// jalr xn, x0, 8    -> JALR-01-D

class invalid_jalr_seq extends base_seq;
    `uvm_object_utils(invalid_jalr_seq)

    logic [11:0] imm_list [3] = '{12'hF04, 12'h0EA, 12'h008};

    constraint program_length {
        program_size == 3;      // override randomized program size in base_seq
    }

    function new(string name = "invalid_jalr_seq");
        super.new(name);
    endfunction

    virtual task generate_program();
        foreach (imm_list[i]) begin
            instr_seq_item item = instr_seq_item::type_id::create("item");

            if (!item.randomize() with {
                instruction == JALR;
                rs1         == 5'b0;
                imm[11:0]   == imm_list[i];
            }) begin
                `uvm_error("Body", "Randomization failed!")
            end

            program_items.push_back(item);
        end
    endtask

endclass
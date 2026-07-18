// Directed Testing Sequence for JALR-01 and JALR-03

// test program
// jalr xn, x0, -252 -> JALR-01-E
// jalr xn, x0, 264  -> JALR-01-F
// jalr xn, x0, 12   -> JALR-01-C
// jalr xn, x0, 16   -> JALR-01-C
// jalr xn, x0, 21   -> JALR-03-B
// jalr xn, x0, 20   -> JALR-01-D

class invalid_jalr_seq extends base_seq;
    `uvm_object_utils(invalid_jalr_seq)

    logic [11:0] imm_list [6] = '{12'hF04, 12'h108, 12'h00C, 12'h010, 12'h015, 12'h14};

    constraint program_length {
        program_size == 6;      // override randomized program size in base_seq
    }

    function new(string name = "invalid_jalr_seq");
        super.new(name);
    endfunction

    virtual task generate_program();
        foreach (imm_list[i]) begin
            instr_seq_item item = instr_seq_item::type_id::create("item");
            item.pc_must_align.constraint_mode(0); // turn off PC alignment constraint

            if (!item.randomize() with {
                instruction == JALR;
                rs1         == 5'b0; // rs1 = x0
                imm[11:0]   == imm_list[i];
            }) begin
                `uvm_error("Body", "Randomization failed!")
            end

            program_items.push_back(item);
            `uvm_info("SEQ", $sformatf("Generated %s", item.convert2string()), UVM_LOW)
        end
    endtask

endclass
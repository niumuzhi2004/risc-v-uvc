// Directed Testing Sequence for BTYPE-03 and BTYPE-04

// test program
// beq x0, x0, -252 -> BTYPE-03-E
// beq x0, x0, 516  -> BTYPE-03-F
// beq x0, x0, 6    -> BTYPE-04-B
// beq x0, x0, 0    -> BTYPE-03-D

class invalid_branch_seq extends base_seq;
    `uvm_object_utils(invalid_branch_seq)

    logic [11:0] imm_list [4] = '{12'hF82, 12'h102, 12'h003, 12'h000};

    constraint program_length {
        program_size == 4;      // override randomized program size in base_seq
    }

    function new(string name = "invalid_branch_seq");
        super.new(name);
    endfunction

    virtual task generate_program();
        foreach (imm_list[i]) begin
            instr_seq_item item = instr_seq_item::type_id::create("item");
            item.pc_must_align.constraint_mode(0); // turn off PC alignment constraint

            if (!item.randomize() with {
                instruction == BEQ;
                rs1         == 5'b0;
                rs2         == 5'b0;
                imm[12:1]   == imm_list[i];
                imm[0]      == 1'b0;
            }) begin
                `uvm_error("Body", "Randomization failed!")
            end

            program_items.push_back(item);
            `uvm_info("SEQ", $sformatf("Generated %s", item.convert2string()), UVM_LOW)
        end
    endtask

endclass
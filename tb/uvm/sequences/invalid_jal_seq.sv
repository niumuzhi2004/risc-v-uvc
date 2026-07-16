// Directed Testing Sequence for JTYPE-01

// test program
// jal xn, -252 -> JTYPE-01-E
// jal xn, 516  -> JTYPE-01-F
// jal xn, 0    -> JTYPE-01-D

class invalid_jal_seq extends base_seq;
    `uvm_object_utils(invalid_jal_seq)

    logic [19:0] imm_list [3] = '{20'hFFF82, 20'h00102, 20'h00000};

    constraint program_length {
        program_size == 3;      // override randomized program size in base_seq
    }

    function new(string name = "invalid_jal_seq");
        super.new(name);
    endfunction

    virtual task generate_program();
        foreach (imm_list[i]) begin
            instr_seq_item item = instr_seq_item::type_id::create("item");

            if (!item.randomize() with {
                instruction == JAL;
                imm[19:0]   == imm_list[i];
            }) begin
                `uvm_error("Body", "Randomization failed!")
            end

            program_items.push_back(item);
            `uvm_info("SEQ", $sformatf("Generated %s", item.convert2string()), UVM_LOW)
        end
    endtask

endclass
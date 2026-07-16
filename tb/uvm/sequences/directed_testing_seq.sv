// Directed Testing Sequence for Hard-to-Hit Coverage Bins

// LUI x1, 0x02000
// LB  x2, 0(x1)    -> LOAD-03-C

class directed_testing_seq extends base_seq;
    `uvm_object_utils(directed_testing_seq)

    constraint program_length {
        program_size == 2;  // override randomized program size in base_seq
    }

    function new(string name = "directed_testing_seq");
        super.new(name);
    endfunction

    virtual task generate_program();

        instr_seq_item item1 = instr_seq_item::type_id::create("item1");
        instr_seq_item item2 = instr_seq_item::type_id::create("item2");

        if (!item1.randomize() with {
            instruction == LUI;
            rd          == 5'd1;
            imm         == 20'h02000;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item1);
        `uvm_info("SEQ", $sformatf("Generated %s", item1.convert2string()), UVM_LOW)

        if (!item2.randomize() with {
            instruction == LB;
            rd          == 5'd2;
            rs1         == 5'd1;
            imm         == 12'b0;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item2);
        `uvm_info("SEQ", $sformatf("Generated %s", item2.convert2string()), UVM_LOW)

    endtask

endclass
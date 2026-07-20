// Directed Testing Sequence for Hard-to-Hit Coverage Bins

// RTYPE-05-C
// 1    ADDI x1, x0, 0xFFF
// 2    AND  x2, x1, x1
// 3    AND  x3, x0, x1

// JTYPE-02-A
// 4    JAL  x0, 4

// HAZARD-01-E
// 5    LW   x4, 0(x0)
// 6    AND  x5, x4, x4
// 7    LW   x6, 0(x0)
// 8    XOR  x7, x5, x6
// 9    LW   x8, 0(x0)
// 10   OR   x9, x0, x8


class directed_testing_seq extends base_seq;
    `uvm_object_utils(directed_testing_seq)

    constraint program_length {
        program_size == 10;  // override randomized program size in base_seq
    }

    function new(string name = "directed_testing_seq");
        super.new(name);
    endfunction

    virtual task generate_program();

        instr_seq_item item1  = instr_seq_item::type_id::create("item1");
        instr_seq_item item2  = instr_seq_item::type_id::create("item2");
        instr_seq_item item3  = instr_seq_item::type_id::create("item3");
        instr_seq_item item4  = instr_seq_item::type_id::create("item4");
        instr_seq_item item5  = instr_seq_item::type_id::create("item5");
        instr_seq_item item6  = instr_seq_item::type_id::create("item6");
        instr_seq_item item7  = instr_seq_item::type_id::create("item7");
        instr_seq_item item8  = instr_seq_item::type_id::create("item8");
        instr_seq_item item9  = instr_seq_item::type_id::create("item9");
        instr_seq_item item10 = instr_seq_item::type_id::create("item10");

        // Instruction 1: ADDI x1, x0, 0xFFF
        if (!item1.randomize() with {
            instruction == ADDI;
            rd          == 5'd1;
            rs1         == 5'd0;
            imm         == 12'hFFF;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item1);
        `uvm_info("SEQ", $sformatf("Generated %s", item1.convert2string()), UVM_LOW)

        // Instruction 2: AND x2, x1, x1
        if (!item2.randomize() with {
            instruction == AND;
            rd          == 5'd2;
            rs1         == 5'd1;
            rs2         == 5'd1;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item2);
        `uvm_info("SEQ", $sformatf("Generated %s", item2.convert2string()), UVM_LOW)

        // Instruction 3: AND x3, x0, x1
        if (!item3.randomize() with {
            instruction == AND;
            rd          == 5'd3;
            rs1         == 5'd0;
            rs2         == 5'd1;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item3);
        `uvm_info("SEQ", $sformatf("Generated %s", item3.convert2string()), UVM_LOW)

        // Instruction 4: JAL x0, 4
        if (!item4.randomize() with {
            instruction == JAL;
            rd          == 5'd0;
            imm         == 20'd2;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item4);
        `uvm_info("SEQ", $sformatf("Generated %s", item4.convert2string()), UVM_LOW)

        // Instruction 5: LW x4, 0(x0)
        if (!item5.randomize() with {
            instruction == LW;
            rd          == 5'd4;
            rs1         == 5'd0;
            imm         == 12'h000;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item5);
        `uvm_info("SEQ", $sformatf("Generated %s", item5.convert2string()), UVM_LOW)

        // Instruction 6: AND x5, x4, x4
        if (!item6.randomize() with {
            instruction == AND;
            rd          == 5'd5;
            rs1         == 5'd4;
            rs2         == 5'd4;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item6);
        `uvm_info("SEQ", $sformatf("Generated %s", item6.convert2string()), UVM_LOW)

        // Instruction 7: LW x6, 0(x0)
        if (!item7.randomize() with {
            instruction == LW;
            rd          == 5'd6;
            rs1         == 5'd0;
            imm         == 12'h000;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item7);
        `uvm_info("SEQ", $sformatf("Generated %s", item7.convert2string()), UVM_LOW)

        // Instruction 8: XOR x7, x5, x6
        if (!item8.randomize() with {
            instruction == XOR;
            rd          == 5'd7;
            rs1         == 5'd5;
            rs2         == 5'd6;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item8);
        `uvm_info("SEQ", $sformatf("Generated %s", item8.convert2string()), UVM_LOW)

        // Instruction 9: LW x8, 0(x0)
        if (!item9.randomize() with {
            instruction == LW;
            rd          == 5'd8;
            rs1         == 5'd0;
            imm         == 12'h000;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item9);
        `uvm_info("SEQ", $sformatf("Generated %s", item9.convert2string()), UVM_LOW)

        // Instruction 10: OR x9, x0, x8
        if (!item10.randomize() with {
            instruction == OR;
            rd          == 5'd9;
            rs1         == 5'd0;
            rs2         == 5'd8;
        }) begin
            `uvm_error("Body", "Randomization failed!")
        end
        program_items.push_back(item10);
        `uvm_info("SEQ", $sformatf("Generated %s", item10.convert2string()), UVM_LOW)

    endtask

endclass
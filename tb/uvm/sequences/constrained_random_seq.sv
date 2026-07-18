class constrained_random_seq extends base_seq;
    `uvm_object_utils(constrained_random_seq)

    rand int unsigned PC_index;

    function new(string name = "constrained_random_seq");
        super.new(name);
    endfunction

    virtual task generate_program();

        // initialize register file to avoid unknown values
        init_registers();

        // create random instructions to form test program
        create_random_instrs();

        // filter branch/jump instructions to lower the probability of infinite loops
        filter_branch_jump();

    endtask

    task init_registers();
        // initialize registers x1-x31
        for (int i=0; i<31; ++i) begin
            instr_seq_item item = instr_seq_item::type_id::create("item");
            if (!item.randomize() with {
                solve bucket_fill before instruction, rd;
                bucket_fill dist { 0 := 7, 1 := 3 };

                // 70% chance assign register value with ADDI
                if (bucket_fill == 0) {
                    instruction == ADDI;
                    rd          == i+1;
                    rs1         == 5'd0;
                } 
                
                // 30% chance assign register value with LUI
                else {
                    instruction == LUI;
                    rd          == i+1;
                }
            }) begin
                `uvm_error("Body", $sformatf("Randomization failed for instruction #%0d!", i))
            end
            program_items.push_back(item);
            `uvm_info("SEQ", $sformatf("Generated %s", item.convert2string()), UVM_LOW)
        end
    endtask

    task create_random_instrs();
        for (int i=31; i<program_size; ++i) begin
            instr_seq_item item = instr_seq_item::type_id::create("item");
            
            if (!item.randomize()) begin
                `uvm_error("Body", $sformatf("Randomization failed for instruction #%0d!", i))
            end

            program_items.push_back(item);
            `uvm_info("SEQ", $sformatf("Generated %s", item.convert2string()), UVM_LOW)
        end
    endtask

    task filter_branch_jump();
        for (int i=31; i<program_size; ++i) begin

            // check if instruction is branch/jump
            // if so, make sure PC target is between program start and end
            // and is not the current PC (to avoid infinite loop)

            // because jumping backwards may lead to infinite loops,
            // forward jumps are preferred over backward jumps
            // with a distribution of 90/10

            if (program_items[i].op inside {7'd99, 7'd103, 7'd111}) begin

                if (i == 31) begin
                    if (!randomize(PC_index) with {
                        PC_index inside {[ 32:program_size-1 ]};            // must jump forward
                    }) begin
                        `uvm_error("SEQ", "Failed to randomize PC_index!")
                    end
                end
                else if (i == program_size - 1) begin
                    if (!randomize(PC_index) with {
                        PC_index inside {[ 31:i-1 ]};                       // must jump backward
                    }) begin
                        `uvm_error("SEQ", "Failed to randomize PC_index!")
                    end
                end
                else begin
                    if (!randomize(PC_index) with {
                        PC_index dist {
                            [i+1:program_size-1] :/ 90,                     // 90% prob jump forward
                            [31:i-1]             :/ 10                      // 10% prob jump backward
                        };
                    }) begin
                        `uvm_error("SEQ", "Failed to randomize PC_index!")
                    end
                end

                case (program_items[i].op)
                    7'd99: begin    // B-Type, offset = SignExt({imm[12:1], 1'b0}) 
                        int PC_offset = (PC_index - i) * 4;
                        program_items[i].imm[12:1] = PC_offset[12:1];
                    end
                    7'd111: begin   // JAL, offset = SignExt({imm[20:1], 1'b0})
                        int PC_offset = (PC_index - i) * 4;
                        program_items[i].imm[19:0] = PC_offset[19:0];
                    end
                    7'd103: begin   // JALR, offset = rs1 + SignExt(imm)
                        int PC_offset = PC_index * 4;
                        program_items[i].rs1 = 5'b0;    // force rs1 to be x0, so offset = SignExt(imm)
                        program_items[i].imm[11:0] = PC_offset[11:0];
                    end
                endcase

            end
        end
    endtask

endclass
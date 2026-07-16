// constrained random sequence, but exclude jump/branch instructions

class rand_without_jump_seq extends constrained_random_seq;
    `uvm_object_utils(rand_without_jump_seq)

    function new(string name = "rand_without_jump_seq");
        super.new(name);
    endfunction

    virtual task generate_program();

        // initialize register file to avoid unknown values
        init_registers();

        // create random instructions to form test program
        create_random_instrs();

    endtask

    task create_random_instrs();
        for (int i=20; i<program_size; ++i) begin
            instr_seq_item item = instr_seq_item::type_id::create("item");
            if (!item.randomize() with {
                !(instruction inside { BEQ, BNE, BGE, BLT, BGEU, BLTU, JALR, JAL });
                rs1 inside {0, registers[0:19]};
                rs2 inside {0, registers[0:19]};
            }) begin
                `uvm_error("Body", $sformatf("Randomization failed for instruction #%0d!", i))
            end
            program_items.push_back(item);
            `uvm_info("SEQ", $sformatf("Generated %s", item.convert2string()), UVM_LOW)
        end
    endtask

endclass
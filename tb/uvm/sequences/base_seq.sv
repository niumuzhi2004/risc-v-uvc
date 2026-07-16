class base_seq extends uvm_sequence #(instr_seq_item);
    `uvm_object_utils(base_seq)

    rand int unsigned program_size;
    instr_seq_item    program_items[$];

    constraint program_length {
        // program needs to have at least 20 instructions to 
        // have a moderate chance at covering all instruction types
        program_size inside {[40:62]};
    }

    function new(string name = "base_seq");
        super.new(name);
    endfunction

    virtual task generate_program();
        repeat (program_size) begin
            instr_seq_item item = instr_seq_item::type_id::create("item");
            if (!item.randomize()) begin
                `uvm_error("Body", "Randomization failed!")
            end
            program_items.push_back(item);
            `uvm_info("SEQ", $sformatf("Generated %s", item.convert2string()), UVM_LOW)
        end
    endtask

    task body();
        generate_program();
        foreach (program_items[i]) begin
            req = program_items[i];
            if (i == (program_size - 1))
                req.is_last = 1;
            start_item(req);
            finish_item(req);
        end
    endtask

endclass
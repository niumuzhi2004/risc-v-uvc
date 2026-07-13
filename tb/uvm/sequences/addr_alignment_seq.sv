// Directed Testing Sequence for LOAD-04, STYPE-04

class addr_alignment_seq extends base_seq;
    `uvm_object_utils(addr_alignment_seq)

    instr_t     applicable_instrs [4] = '{ LB, LH, SB, SH };
    logic [1:0] addr_lower_bits   [4] = '{ 2'b00, 2'b01, 2'b10, 2'b11 };

    constraint program_length {
        program_size == 16;     // override randomized program size in base_seq
    }

    function new(string name = "addr_alignment_seq");
        super.new(name);
    endfunction

    virtual task generate_program();
        foreach (applicable_instrs[i]) begin
            foreach (addr_lower_bits[j]) begin
                instr_seq_item item = instr_seq_item::type_id::create("item");

                if (!item.randomize() with {
                    instruction == applicable_instrs[i];
                    rs1         == 5'b0;    // rs1 is x0
                    imm[1:0]    == addr_lower_bits[j];
                }) begin
                    `uvm_error("Body", "Randomization failed!")
                end

                program_items.push_back(item);
            end
        end
    endtask

endclass
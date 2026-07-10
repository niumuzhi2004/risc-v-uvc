class constrained_random_seq extends base_seq;
    `uvm_object_utils(constrained_random_seq)

    function new(string name = "constrained_random_seq");
        super.new(name);
    endfunction

    virtual task generate_program();
        super.generate_program();
        
        // check if instruction is branch/jump
        // if so, make sure PC target is between program start and end
        // and is not the current PC (to avoid infinite loop)

        // because jumping backwards may lead to infinite loops,
        // forward jumps are preferred over backward jumps
        // with a distribution of 80/20

        foreach (program_items[i]) begin

            // for B-Type, PC advances by 
            if (program_items[i].op inside {7'd99, 7'd103, 7'd111}) begin

                int PC_index;

                if (i == 0) 
                    PC_index = $urandom_range(1, program_size-1);           // must jump forward
                else if (i == program_size - 1) 
                    PC_index = $urandom_range(0, i-1);                      // must jump backward
                else begin
                    randcase
                        80: PC_index = $urandom_range(i+1, program_size-1); // 80% prob jump forward
                        20: PC_index = $urandom_range(0, i-1);              // 20% prob jump backward
                    endcase
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
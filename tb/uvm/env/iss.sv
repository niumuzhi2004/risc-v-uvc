class iss extends uvm_component;
    `uvm_component_utils(iss)

    logic [31:0] reg_file [32];
    logic [31:0] data_mem [64];
    logic [31:0] PC;

    // receives instruction and PC from debug monitor
    uvm_analysis_imp_iss #(debug_seq_item, iss) iss_imp;

    // sends predicted register file values to scoreboard
    uvm_analysis_port #(debug_seq_item) iss_ap;

    function new(string name = "iss", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        iss_imp = new("iss_imp", this);
        iss_ap  = new("iss_ap",  this);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        reg_file[0] = 32'b0;
        foreach (data_mem[i])
            data_mem[i] = 32'hDEADBEEF;
    endfunction

    function void write_iss(debug_seq_item item);

        // decode instruction
        logic [6:0]  op       = item.Instr[6:0];
        logic [4:0]  rd       = 5'b0;
        logic [4:0]  rs1      = 5'b0;
        logic [4:0]  rs2      = 5'b0;
        logic [2:0]  funct3   = 3'b0;
        logic [6:0]  funct7   = 7'b0;
        logic [31:0] imm      = 32'b0;
        logic [31:0] mem_addr = 32'b0;
        logic [31:0] mem_data = 32'b0;
        debug_seq_item result;
        
        PC = item.PC;

        case (op)

            7'd3: begin                                 // load instructions
                funct3    = item.Instr[14:12];
                rd        = item.Instr[11:7];
                rs1       = item.Instr[19:15];
                imm[11:0] = item.Instr[31:20];
                PC        = PC + 4;

                mem_addr  = reg_file[rs1] + {{20{imm[11]}}, imm[11:0]};
                mem_data  = data_mem[mem_addr[7:2]];

                case (funct3)
                    3'b000: begin                       // lb
                        case (mem_addr[1:0])
                            2'b00: reg_file[rd] = {{24{mem_data[7]}},  mem_data[7:0]};
                            2'b01: reg_file[rd] = {{24{mem_data[15]}}, mem_data[15:8]};
                            2'b10: reg_file[rd] = {{24{mem_data[23]}}, mem_data[23:16]};
                            2'b11: reg_file[rd] = {{24{mem_data[31]}}, mem_data[31:24]};
                            default: reg_file[rd] = 32'b0;
                        endcase
                    end
                    3'b001: begin                       // lh
                        case (mem_addr[1:0])
                            2'b00: reg_file[rd] = {{16{mem_data[15]}}, mem_data[15:0]};
                            2'b10: reg_file[rd] = {{16{mem_data[31]}}, mem_data[31:16]};
                            default: reg_file[rd] = 32'b0;
                        endcase
                    end
                    3'b010: reg_file[rd] = mem_data;    // lw
                    3'b100: begin                       // lbu
                        case (mem_addr[1:0])
                            2'b00: reg_file[rd] = {24'b0, mem_data[7:0]};
                            2'b01: reg_file[rd] = {24'b0, mem_data[15:8]};
                            2'b10: reg_file[rd] = {24'b0, mem_data[23:16]};
                            2'b11: reg_file[rd] = {24'b0, mem_data[31:24]};
                            default: reg_file[rd] = 32'b0;
                        endcase
                    end
                    3'b101: begin                       // lhu
                        case (mem_addr[1:0])
                            2'b00: reg_file[rd] = {16'b0, mem_data[15:0]};
                            2'b10: reg_file[rd] = {16'b0, mem_data[31:16]};
                            default: reg_file[rd] = 32'b0;
                        endcase
                    end
                    default: reg_file[rd] = 32'b0;
                endcase
            end

            7'd19: begin                                // I-type
                funct3    = item.Instr[14:12];
                rd        = item.Instr[11:7];
                rs1       = item.Instr[19:15];
                imm[11:0] = item.Instr[31:20];
                PC        = PC + 4;

                case (funct3)
                    3'b000: reg_file[rd] = reg_file[rs1] + {{20{imm[11]}}, imm[11:0]};                                  // addi
                    3'b001: reg_file[rd] = reg_file[rs1] << imm[4:0];                                                   // slli
                    3'b010: reg_file[rd] = {31'b0, ($signed(reg_file[rs1]) < $signed({{20{imm[11]}}, imm[11:0]}))};     // slti
                    3'b011: reg_file[rd] = {31'b0, (reg_file[rs1] < {{20{imm[11]}}, imm[11:0]})};                       // sltiu
                    3'b100: reg_file[rd] = reg_file[rs1] ^ {{20{imm[11]}}, imm[11:0]};                                  // xori
                    3'b101: reg_file[rd] = imm[10] ? (reg_file[rs1] >>> imm[4:0])                                       // srai
                                                   : (reg_file[rs1] >> imm[4:0]);                                       // srli
                    3'b110: reg_file[rd] = reg_file[rs1] | {{20{imm[11]}}, imm[11:0]};                                  // ori
                    3'b111: reg_file[rd] = reg_file[rs1] & {{20{imm[11]}}, imm[11:0]};                                  // andi
                    default: reg_file[rd] = 32'b0;
                endcase
            end

            7'd23: begin                                // AUIPC
                rd           = item.Instr[11:7];
                imm[31:12]   = item.Instr[31:12];
                reg_file[rd] = {imm[31:12], 12'b0} + item.PC;
                PC           = PC + 4;
            end

            7'd35: begin                                // S-type
                funct3    = item.Instr[14:12];
                imm[4:0]  = item.Instr[11:7];
                rs1       = item.Instr[19:15];
                rs2       = item.Instr[24:20];
                imm[11:5] = item.Instr[31:25];
                PC        = PC + 4;

                mem_addr  = reg_file[rs1] + {{20{imm[11]}}, imm[11:0]};
                mem_data  = reg_file[rs2];

                case (funct3)
                    3'b000: begin                                   // sb
                        case (mem_addr[1:0])
                            2'b00: data_mem[mem_addr[7:2]][7:0]   = mem_data[7:0];
                            2'b01: data_mem[mem_addr[7:2]][15:8]  = mem_data[7:0];
                            2'b10: data_mem[mem_addr[7:2]][23:16] = mem_data[7:0];
                            2'b11: data_mem[mem_addr[7:2]][31:24] = mem_data[7:0];
                        endcase
                    end
                    3'b001: begin                                   // sh
                        case (mem_addr[1:0])
                            2'b00: data_mem[mem_addr[7:2]][15:0]  = mem_data[15:0];
                            2'b10: data_mem[mem_addr[7:2]][31:16] = mem_data[15:0];
                        endcase
                    end
                    3'b010: data_mem[mem_addr[7:2]] = mem_data;     // sw
                endcase
            end

            7'd51: begin                                // R-type
                funct3 = item.Instr[14:12];
                rd     = item.Instr[11:7];
                rs1    = item.Instr[19:15];
                rs2    = item.Instr[24:20];
                funct7 = item.Instr[31:25];
                PC     = PC + 4;

                case (funct3)
                    3'b000: reg_file[rd] = funct7[5] ? (reg_file[rs1] - reg_file[rs2])                  // sub
                                                     : (reg_file[rs1] + reg_file[rs2]);                 // add
                    3'b001: reg_file[rd] = reg_file[rs1] << reg_file[rs2][4:0];                         // sll
                    3'b010: reg_file[rd] = {31'b0, ($signed(reg_file[rs1]) < $signed(reg_file[rs2]))};  // slt
                    3'b011: reg_file[rd] = {31'b0, (reg_file[rs1] < reg_file[rs2])};                    // sltu
                    3'b100: reg_file[rd] = reg_file[rs1] ^ reg_file[rs2];                               // xor
                    3'b101: reg_file[rd] = funct7[5] ? (reg_file[rs1] >>> reg_file[rs2][4:0])           // sra
                                                     : (reg_file[rs1] >> reg_file[rs2][4:0]);           // srl
                    3'b110: reg_file[rd] = reg_file[rs1] | reg_file[rs2];                               // or
                    3'b111: reg_file[rd] = reg_file[rs1] & reg_file[rs2];                               // and
                    default: reg_file[rd] = 32'b0;
                endcase
            end

            7'd55: begin                                // LUI
                rd           = item.Instr[11:7];
                imm[31:12]   = item.Instr[31:12];
                reg_file[rd] = {imm[31:12], 12'b0};
                PC           = PC + 4;
            end

            7'd99: begin                                // B-type
                funct3    = item.Instr[14:12];
                imm[4:1]  = item.Instr[11:8];
                imm[11]   = item.Instr[7];
                rs1       = item.Instr[19:15];
                rs2       = item.Instr[24:20];
                imm[10:5] = item.Instr[30:25];
                imm[12]   = item.Instr[31];

                case (funct3)
                    3'b000: PC = (reg_file[rs1] == reg_file[rs2]) ? (PC + {{19{imm[12]}}, imm[12:1], 1'b0}) : (PC + 4);                         // beq
                    3'b001: PC = (reg_file[rs1] != reg_file[rs2]) ? (PC + {{19{imm[12]}}, imm[12:1], 1'b0}) : (PC + 4);                         // bne
                    3'b100: PC = ($signed(reg_file[rs1]) < $signed(reg_file[rs2]))  ? (PC + {{19{imm[12]}}, imm[12:1], 1'b0}) : (PC + 4);       // blt
                    3'b101: PC = ($signed(reg_file[rs1]) >= $signed(reg_file[rs2])) ? (PC + {{19{imm[12]}}, imm[12:1], 1'b0}) : (PC + 4);       // bge
                    3'b110: PC = (reg_file[rs1] < reg_file[rs2])  ? (PC + {{19{imm[12]}}, imm[12:1], 1'b0}) : (PC + 4);                         // bltu
                    3'b111: PC = (reg_file[rs1] >= reg_file[rs2]) ? (PC + {{19{imm[12]}}, imm[12:1], 1'b0}) : (PC + 4);                         // bgeu
                    default: PC = PC + 4;
                endcase
            end

            7'd103: begin                               // JALR
                funct3    = item.Instr[14:12];
                rd        = item.Instr[11:7];
                rs1       = item.Instr[19:15];
                imm[11:0] = item.Instr[31:20];

                if (funct3 == 3'b000) begin
                    PC           = reg_file[rs1] + {{20{imm[11]}}, imm[11:0]};
                    reg_file[rd] = item.PC + 4;
                end else begin
                    PC = PC + 4;
                end
            end

            7'd111: begin                               // JAL
                rd         = item.Instr[11:7];
                imm[20]    = item.Instr[31];
                imm[10:1]  = item.Instr[30:21];
                imm[11]    = item.Instr[20];
                imm[19:12] = item.Instr[19:12];

                PC           = PC + {{11{imm[20]}}, imm[20:1], 1'b0};
                reg_file[rd] = item.PC + 4;
            end

            default: PC = PC + 4;
        endcase

        reg_file[0] = 32'b0;

        // send predicted register file to scoreboard
        result         = debug_seq_item::type_id::create("result");
        result.Instr   = item.Instr;
        result.PC      = item.PC;
        result.RegFile = reg_file;
        iss_ap.write(result);

        `uvm_info("ISS", $sformatf("Processed %s", result.convert2string()), UVM_LOW)

    endfunction

endclass
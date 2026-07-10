class instr_driver extends uvm_driver #(instr_seq_item);
    `uvm_component_utils(instr_driver)

    virtual instr_if vif;
    logic [31:0] instr_mem [64];
    int program_size = 0;
    uvm_event halt_event;

    function new(string name = "instr_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual instr_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not found!")
        end

        halt_event = uvm_event_pool::get_global("halt_event");
    endfunction

    task run_phase(uvm_phase phase);
        halt_event.reset();

        // collect entire program from sequencer
        forever begin
            seq_item_port.get_next_item(req);
            if (program_size >= 63) begin
                `uvm_fatal("PROGRAM_OVERFLOW", "Program exceeds instruction memory size.")
            end
            instr_mem[program_size] = encode(req);
            program_size++;
            bit last = req.is_last;
            seq_item_port.item_done();
            if (last) break;
        end

        // manage halt and reset
        instr_mem[program_size] = 32'b0; // insert all zero instruction as last instruction
        vif.driver_cb.rst_n <= 1'b0;
        repeat (2) @ (vif.driver_cb);
        vif.driver_cb.rst_n <= 1'b1;

        // load program into DUT
        do begin
            @ (vif.driver_cb);
            vif.driver_cb.RD <= instr_mem[vif.driver_cb.A[7:2]];
        end while (halt_event.is_off());
            
    endtask

    function logic [31:0] encode(instr_seq_item req);
        logic [31:0] instruction;

        if (req.op inside {7'd3, 7'd19, 7'd103}) begin      // I-type
            if (req.instruction inside {SRLI, SRAI, SLLI})
                instruction = {req.funct7, req.imm[4:0], req.rs1, req.funct3, req.rd, req.op};
            else
                instruction = {req.imm[11:0], req.rs1, req.funct3, req.rd, req.op};
        end 
        else if (req.op inside {7'd23, 7'd55})              // U-type
            instruction = {req.imm, req.rd, req.op};
        else if (req.op == 7'd35)                           // S-type
            instruction = {req.imm[11:5], req.rs2, req.rs1, req.funct3, req.imm[4:0], req.op};
        else if (req.op == 7'd51)                           // R-type
            instruction = {req.funct7, req.rs2, req.rs1, req.funct3, req.rd, req.op};
        else if (req.op == 7'd99)                           // B-type
            instruction = {req.imm[12], req.imm[10:5], req.rs2, req.rs1, req.funct3, req.imm[4:1], req.imm[11], req.op};
        else if (req.op == 7'd111)                          // J-type
            instruction = {req.imm[19], req.imm[9:0], req.imm[10], req.imm[18:11], req.rd, req.op};
        else 
            instruction = 32'b0;

        return instruction;
    endfunction

endclass
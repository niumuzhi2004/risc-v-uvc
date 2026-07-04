class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    // receive expected register file results from ISS
    uvm_analysis_imp_exp #(debug_seq_item, scoreboard) exp_imp;
    
    // receive actual register file values from debug monitor
    uvm_analysis_imp_act #(debug_seq_item, scoreboard) act_imp;

    // queues for comparison - since we don't know whether expected or actual result comes first
    debug_seq_item exp_queue [$];
    debug_seq_item act_queue [$];

    int pass_count = 0;
    int fail_count = 0;

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_imp = new("exp_imp", this);
        act_imp = new("act_imp", this);
    endfunction

    function void write_exp(debug_seq_item item);
        if (act_queue.size() > 0)
            compare(item, act_queue.pop_front());
        else
            exp_queue.push_back(item);
    endfunction

    function void write_act(debug_seq_item item);
        if (exp_queue.size() > 0)
            compare(exp_queue.pop_front(), item);
        else
            act_queue.push_back(item);
    endfunction

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (act_queue.size() > 0 || exp_queue.size() > 0) begin
            `uvm_error("SB_MISMATCH", "Comparison queue not matched at the end of simulation!")
        end

        `uvm_info("SB_SUMMARY", $sformatf("%d instructions passed, %d failed", pass_count, fail_count), UVM_LOW)
    endfunction

    function void compare(debug_seq_item exp_item, debug_seq_item act_item);
        if (exp_item.compare(act_item)) begin
            pass_count++;
            `uvm_info("SB_PASS", $sformatf("Instruction %h @ PC (%h) passed.", act_item.Instr, act_item.PC), UVM_LOW)
        end 
        else begin
            fail_count++;

            if (exp_item.PC != act_item.PC) begin
                `uvm_error("SB_FAIL", $sformatf("PC Mismatch: Expected %h, Got %h", exp_item.PC, act_item.PC))
            end

            foreach (exp_item.RegFile[i]) begin
                if (exp_item.RegFile[i] != act_item.RegFile[i]) begin
                    `uvm_error("SB_FAIL", $sformatf(
                        "Instruction %h @ PC (%h): x%d Mismatch: Expected %h, Got %h",
                        act_item.Instr, act_item.PC,
                        i, exp_item.RegFile[i], act_item.RegFile[i]
                    ))
                end
            end
        end
    endfunction

endclass
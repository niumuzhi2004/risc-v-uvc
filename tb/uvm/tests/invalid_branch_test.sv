class invalid_branch_test extends base_test;
    `uvm_component_utils(invalid_branch_test)

    function new(string name = "invalid_branch_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        invalid_branch_seq branch_seq = invalid_branch_seq::type_id::create("branch_seq");

        fork
            branch_seq.start(environment.ins_agent.sequencer);
            #(WATCHDOG_CYCLES * CLK_PERIOD);
        join_any
        disable fork;
        `uvm_warning("WATCHDOG", "Expected Behavior: Branch-to-itself loop timeout.")

        phase.drop_objection(this);
    endtask

endclass
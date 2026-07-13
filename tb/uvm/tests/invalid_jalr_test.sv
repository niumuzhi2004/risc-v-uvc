class invalid_jalr_test extends base_test;
    `uvm_component_utils(invalid_jalr_test)

    function new(string name = "invalid_jalr_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        invalid_jalr_seq jalr_seq = invalid_jalr_seq::type_id::create("jalr_seq");
        phase.raise_objection(this);

        fork
            jalr_seq.start(environment.ins_agent.sequencer);
            #(WATCHDOG_CYCLES_PER_TEST * CLK_PERIOD);
        join_any
        disable fork;
        `uvm_warning("WATCHDOG", "Expected Behavior: Jump-to-itself loop timeout.")

        phase.drop_objection(this);
    endtask

endclass
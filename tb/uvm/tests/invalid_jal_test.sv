class invalid_jal_test extends base_test;
    `uvm_component_utils(invalid_jal_test)

    function new(string name = "invalid_jal_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        invalid_jal_seq       jal_seq = invalid_jal_seq::type_id::create("jal_seq");

        fork 
            jal_seq.start(environment.ins_agent.sequencer);
            #(WATCHDOG_CYCLES * CLK_PERIOD);
        join_any
        disable fork;
        `uvm_warning("WATCHDOG", "Expected Behavior: Jump-to-itself loop timeout.")

        phase.drop_objection(this);
    endtask

endclass
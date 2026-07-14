class consecutive_hazards_test extends base_test;
    `uvm_component_utils(consecutive_hazards_test)

    function new(string name = "consecutive_hazards_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        consecutive_hazards_seq seq = consecutive_hazards_seq::type_id::create("seq");
        phase.raise_objection(this);
        if (!seq.randomize()) begin 
            `uvm_error("TEST", "Sequence randomization failed!")
        end
        seq.start(environment.ins_agent.sequencer);
        `uvm_info("TEST", "Waiting for DUT to halt...", UVM_NONE)
        halt_event.wait_trigger();
        `uvm_info("TEST", "DUT halted! Ending test.", UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass
class consecutive_hazards_test extends base_test;
    `uvm_component_utils(consecutive_hazards_test)

    function new(string name = "consecutive_hazards_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        consecutive_hazards_seq seq = consecutive_hazards_seq::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(environment.ins_agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass
class constrained_random_test extends base_test;
    `uvm_component_utils(constrained_random_test)

    function new(string name = "constrained_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        constrained_random_seq seq = constrained_random_seq::type_id::create("seq");
        seq.start(environment.ins_agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass
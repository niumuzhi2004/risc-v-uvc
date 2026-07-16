class rand_without_jump_test extends base_test;
    `uvm_component_utils(rand_without_jump_test)

    function new(string name = "rand_without_jump_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rand_without_jump_seq seq = rand_without_jump_seq::type_id::create("seq");
        phase.raise_objection(this);
        if (!seq.randomize()) begin 
            `uvm_error("TEST", "Sequence randomization failed!")
        end

        fork
            begin
                seq.start(environment.ins_agent.sequencer);
                `uvm_info("TEST", "Waiting for DUT to halt...", UVM_NONE)
                halt_event.wait_trigger();
                `uvm_info("TEST", "DUT halted! Ending test.", UVM_NONE)
            end

            begin
                #(WATCHDOG_CYCLES_PER_TEST * CLK_PERIOD);
            end
        join_any
        disable fork;
        `uvm_warning("WATCHDOG", "Expected Behavior: There might be an infinite loop.")

        phase.drop_objection(this);
    endtask

endclass
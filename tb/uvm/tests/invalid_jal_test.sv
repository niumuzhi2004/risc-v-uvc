class invalid_jal_test extends base_test;
    `uvm_component_utils(invalid_jal_test)

    function new(string name = "invalid_jal_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        invalid_jal_seq seq = invalid_jal_seq::type_id::create("seq");
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
                `uvm_warning("WATCHDOG", "Expected Behavior: Jump-to-itself loop timeout.")
            end
        join_any
        disable fork;

        phase.drop_objection(this);
    endtask

endclass
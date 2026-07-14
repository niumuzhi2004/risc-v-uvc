class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    env environment;
    uvm_event halt_event;

    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        environment = env::type_id::create("environment", this);
        halt_event  = uvm_event_pool::get_global("halt_event");
    endfunction

endclass
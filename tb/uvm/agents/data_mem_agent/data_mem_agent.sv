class data_mem_agent extends uvm_agent;
    `uvm_component_utils(data_mem_agent)

    data_mem_sequencer sequencer;
    data_mem_driver    driver;
    data_mem_monitor   monitor;

    function new(string name = "data_mem_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sequencer = data_mem_sequencer::type_id::create("sequencer", this);
        driver    = data_mem_driver::type_id::create("driver", this);
        monitor   = data_mem_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass
class data_mem_sequencer extends uvm_sequencer #(data_mem_seq_item);
    `uvm_component_utils(data_mem_sequencer)

    function new(string name = "data_mem_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass
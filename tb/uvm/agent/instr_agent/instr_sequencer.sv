class instr_sequencer extends uvm_sequencer #(instr_seq_item);
    `uvm_component_utils(instr_sequencer)

    function new(string name = "instr_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass
class debug_seq_item extends uvm_sequence_item;

    logic [31:0] Instr;
    logic [31:0] PC;
    logic [31:0] RegFile [32];

    `uvm_object_utils_begin(debug_seq_item)
        `uvm_field_int(Instr, UVM_ALL_ON)
        `uvm_field_int(PC,    UVM_ALL_ON)
        `uvm_field_sarray_int(RegFile, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "debug_seq_item");
        super.new(name);
    endfunction

    // custom method for printing debug statement
    function string convert2string();
        return $sformatf("@ PC %h: Instruction: %h", PC, Instr);
    endfunction

endclass
class iss_result_item extends uvm_sequence_item;

    logic [31:0] Instr, PC;
    logic [31:0] predicted_reg_file [32];

    `uvm_object_utils_begin(iss_result_item)
        `uvm_field_int(Instr, UVM_ALL_ON)
        `uvm_field_int(PC,    UVM_ALL_ON)
        `uvm_field_sarray_int(predicted_reg_file, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "iss_result_item");
        super.new(name);
    endfunction

endclass
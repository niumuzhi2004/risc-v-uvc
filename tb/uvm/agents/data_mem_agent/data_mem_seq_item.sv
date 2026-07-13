class data_mem_seq_item extends uvm_sequence_item;

    logic [31:0] A, WD, RD;
    logic [3:0]  WE;
    logic        RE;

    `uvm_object_utils_begin(data_mem_seq_item)
        `uvm_field_int(A, UVM_ALL_ON)
        `uvm_field_int(WD, UVM_ALL_ON)
        `uvm_field_int(RD, UVM_ALL_ON)
        `uvm_field_int(WE, UVM_ALL_ON)
        `uvm_field_int(RE, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "data_mem_seq_item");
        super.new(name);
    endfunction

    // custom method for printing debug statement
    function string convert2string();
        string debugStr = "";
        if (WE != 4'b0) 
            debugStr = {debugStr, $sformatf("Writing %h to address %h (byte enable: %b). \n", WD, A, WE)};
        if (RE)
            debugStr = {debugStr, $sformatf("Reading %h from address %h.", RD, A)};
        return debugStr;
    endfunction
    
endclass
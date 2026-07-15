class data_mem_driver extends uvm_driver #(data_mem_seq_item);
    `uvm_component_utils(data_mem_driver)

    virtual data_if vif;
    logic [31:0] data_mem [64];

    function new(string name = "data_mem_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual data_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not found!")
        end
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        foreach (data_mem[i]) begin
            data_mem[i] = 32'hDEADBEEF; // non-zero value to flag uninitialized memory
        end
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(vif.driver_cb);
            vif.driver_cb.RD <= vif.driver_cb.RE ? data_mem[vif.driver_cb.A[7:2]] : 32'b0;
            if (vif.driver_cb.WE[0]) data_mem[vif.driver_cb.A[7:2]][7:0]   = vif.driver_cb.WD[7:0];
            if (vif.driver_cb.WE[1]) data_mem[vif.driver_cb.A[7:2]][15:8]  = vif.driver_cb.WD[15:8];
            if (vif.driver_cb.WE[2]) data_mem[vif.driver_cb.A[7:2]][23:16] = vif.driver_cb.WD[23:16];
            if (vif.driver_cb.WE[3]) data_mem[vif.driver_cb.A[7:2]][31:24] = vif.driver_cb.WD[31:24];
        end
    endtask

endclass
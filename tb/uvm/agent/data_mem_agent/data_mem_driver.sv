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
            seq_item_port.get_next_item(req);
            drive_item2bus(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_item2bus(data_mem_seq_item req);
        @(vif.driver_cb);
        req.A  = vif.driver_cb.A;
        req.WE = vif.driver_cb.WE;
        req.WD = vif.driver_cb.WD;
        req.RE = vif.driver_cb.RE;

        vif.driver_cb.RD <= vif.driver_cb.RE ? data_mem[vif.driver_cb.A[7:2]] : 32'b0;

        if (req.WE[0]) data_mem[req.A[7:2]][7:0]   = req.WD[7:0];
        if (req.WE[1]) data_mem[req.A[7:2]][15:8]  = req.WD[15:8];
        if (req.WE[2]) data_mem[req.A[7:2]][23:16] = req.WD[23:16];
        if (req.WE[3]) data_mem[req.A[7:2]][31:24] = req.WD[31:24];
    endtask

endclass
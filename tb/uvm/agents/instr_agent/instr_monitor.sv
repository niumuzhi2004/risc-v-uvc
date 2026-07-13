class instr_monitor extends uvm_monitor;
    `uvm_component_utils(instr_monitor)

    virtual instr_if vif;
    uvm_analysis_port #(instr_seq_item) instr_ap;

    function new(string name = "instr_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        instr_ap = new("instr_ap", this);

        if (!uvm_config_db #(virtual instr_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not found!")
        end
    endfunction

    task run_phase(uvm_phase phase);
        instr_seq_item mon_item;

        forever begin
            @ (vif.monitor_cb);
            // exclude NOP instructions
            if (vif.rst_n && vif.monitor_cb.RD != 32'h00000013) begin
                mon_item    = instr_seq_item::type_id::create("mon_item");
                // instr_ap.write(mon_item);
            end
        end
    endtask

endclass
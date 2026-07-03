class data_mem_monitor extends uvm_monitor;
    `uvm_component_utils(data_mem_monitor)

    virtual data_if vif;
    uvm_analysis_port #(data_mem_seq_item) data_mem_ap;

    function new(string name = "data_mem_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        data_mem_ap = new("data_mem_ap", this); // instantiate analysis port

        if (!uvm_config_db #(virtual data_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not found!")
        end
    endfunction

    task run_phase(uvm_phase phase);
        data_mem_seq_item mon_item;

        forever begin
            @ (vif.monitor_cb);
            if (vif.monitor_cb.WE != 4'b0 || vif.monitor_cb.RE) begin
                mon_item    = data_mem_seq_item::type_id::create("mon_item");
                mon_item.A  = vif.monitor_cb.A;
                mon_item.WD = vif.monitor_cb.WD;
                mon_item.WE = vif.monitor_cb.WE;
                mon_item.RD = vif.monitor_cb.RD;
                mon_item.RE = vif.monitor_cb.RE;
                data_mem_ap.write(mon_item);
            end
        end
    endtask

endclass
class debug_monitor extends uvm_monitor;
    `uvm_component_utils(debug_monitor)

    virtual debug_if vif;
    uvm_analysis_port #(debug_seq_item) debug_ap_scoreboard;
    uvm_analysis_port #(debug_seq_item) debug_ap_coverage;
    uvm_event halt_event;

    function new(string name = "debug_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        debug_ap_scoreboard = new("debug_ap_scoreboard", this);
        debug_ap_coverage   = new("debug_ap_coverage", this);

        if (!uvm_config_db #(virtual debug_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not found!")
        end

        halt_event = uvm_event_pool::get_global("halt_event");
    endfunction

    task run_phase(uvm_phase phase);
        debug_seq_item mon_item;

        forever begin
            @(vif.monitor_cb);
            if (vif.monitor_cb.Valid && !vif.monitor_cb.Halt) begin
                mon_item       = debug_seq_item::type_id::create("mon_item");
                mon_item.Instr = vif.monitor_cb.Instr;
                mon_item.PC    = vif.monitor_cb.PC;
                mon_item.DebugRegFile = vif.monitor_cb.DebugRegFile;

                debug_ap_scoreboard.write(mon_item);
                debug_ap_coverage.write(mon_item);
            end
            else if (vif.monitor_cb.Halt)
                halt_event.trigger();
        end
    endtask

endclass
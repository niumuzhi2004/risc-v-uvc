class env extends uvm_environment;
    `uvm_component_utils(env)

    data_mem_agent     data_agent;
    instr_agent        ins_agent;
    debug_monitor      debug_mon;
    iss                predictor;
    scoreboard         score;
    coverage_collector cover_inst;

    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        data_agent = data_mem_agent::type_id::create("data_agent", this);
        ins_agent  = instr_agent::type_id::create("ins_agent", this);
        debug_mon  = debug_monitor::type_id::create("debug_mon", this);
        predictor  = iss::type_id::create("predictor", this);
        score      = scoreboard::type_id::create("score", this);
        cover_inst = coverage_collector::type_id::create("cover_inst", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        debug_mon.debug_ap.connect(score.act_imp);
        debug_mon.debug_ap.connect(predictor.iss_imp);
        debug_mon.debug_ap.connect(cover_inst.coverage_imp);
        predictor.iss_ap.connect(score.exp_imp);
    endfunction

endclass
interface debug_if(
    input logic clk
);

    logic Halt, Valid;
    logic [31:0] Instr, PC;
    logic [31:0] DebugRegFile [32];

    clocking monitor_cb @(posedge clk);
        default input #1;
        input Halt, Valid, Instr, PC, DebugRegFile;
    endclocking

    modport monitor_port (clocking monitor_cb, input clk);
    
endinterface
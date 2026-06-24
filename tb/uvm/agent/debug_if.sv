interface debug_if(
    input logic clk
);

    logic Halt;
    logic [31:0] DebugRegFile [32];

    clocking monitor_cb @(posedge clk);
        default input #1;
        input Halt, DebugRegFile;
    endclocking

    modport monitor_port (clocking monitor_cb, input clk);
    
endinterface
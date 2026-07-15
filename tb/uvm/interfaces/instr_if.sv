interface instr_if(
    input logic clk
);

    logic rst_n;
    logic [31:0] A, RD;

    // drive on the falling edge when the new Address becomes stable
    clocking driver_cb @(negedge clk);
        default input #1 output #1;
        input A;
        output RD, rst_n;
    endclocking

    clocking monitor_cb @(posedge clk);
        default input #1;
        input A, RD;
    endclocking

    modport driver_port  (clocking driver_cb, input clk);
    modport monitor_port (clocking monitor_cb, input clk);
    
endinterface
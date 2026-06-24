interface data_if(
    input logic clk
);

    logic [31:0] A, WD, RD;
    logic [3:0]  WE;
    logic        RE;

    clocking driver_cb @(posedge clk);
        default input #1 output #1;
        input  A, WD, WE, RE;
        output RD;
    endclocking

    clocking monitor_cb @(posedge clk);
        default input #1;
        input A, WD, WE, RE, RD;
    endclocking

    modport driver_port  (clocking driver_cb, input clk);
    modport monitor_port (clocking monitor_cb, input clk);
    
endinterface
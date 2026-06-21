module data_mem(
    input  logic clk,

    input  logic [5:0]  A,
    input  logic [31:0] WD,
    input  logic [3:0]  WE,
    input  logic        RE,
    output logic [31:0] RD
);

    logic [31:0] mem [64];

    // read logic
    assign RD = RE ? mem[A] : 32'b0;

    // write logic 
    always_ff @(posedge clk) begin
        if (WE[0]) mem[A][7:0]   <= WD[7:0];
        if (WE[1]) mem[A][15:8]  <= WD[15:8];
        if (WE[2]) mem[A][23:16] <= WD[23:16];
        if (WE[3]) mem[A][31:24] <= WD[31:24];
    end
    
endmodule
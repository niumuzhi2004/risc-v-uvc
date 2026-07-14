module register_file(
    input  logic clk,

    input  logic [4:0]  A1,
    input  logic [4:0]  A2,
    input  logic [4:0]  A3,

    input  logic        WE3,
    input  logic [31:0] WD3,
    output logic [31:0] RD1,
    output logic [31:0] RD2,

    output logic [31:0] DebugRegFile [32]
);

    logic [31:0] regs [32];

    // write logic
    always_ff @(negedge clk) begin
        if (WE3 && (A3 != 5'b0))
            regs[A3] <= WD3;
    end

    // read logic & debug port
    always_comb begin
        RD1 = (A1 == 5'b0) ? 32'b0 : regs[A1];
        RD2 = (A2 == 5'b0) ? 32'b0 : regs[A2];
        DebugRegFile = regs;        // debug port wired to registers
        DebugRegFile[0] = 32'b0;    // x0 is always 0
    end
    
endmodule
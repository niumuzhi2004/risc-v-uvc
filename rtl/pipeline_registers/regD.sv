module regD(
    input  logic clk,
    input  logic en,
    input  logic clr,
    input  logic rst_n,

    input  logic [31:0] InstrF,
    output logic [31:0] InstrD,
    input  logic [31:0] PCF,
    output logic [31:0] PCD,
    input  logic [31:0] PCPlus4F,
    output logic [31:0] PCPlus4D
);

    always_ff @(posedge clk) begin
        if (~rst_n | clr) begin
            InstrD   <= 32'h00000013; // NOP, addi x0, x0, 0
            PCD      <= 32'b0;
            PCPlus4D <= 32'b0;
        end 
        else if (en) begin
            InstrD   <= InstrF;
            PCD      <= PCF;
            PCPlus4D <= PCPlus4F;
        end
    end
    
endmodule
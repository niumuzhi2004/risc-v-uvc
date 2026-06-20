module regF #(
    parameter PC_RESET
) (
    input logic clk,
    input logic en,
    input logic rst_n,

    input  logic [31:0] PCF_p,
    output logic [31:0] PCF
);

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            PCF <= PC_RESET;
        end 
        else if (en) begin
            PCF <= PCF_p;
        end
    end
    
endmodule
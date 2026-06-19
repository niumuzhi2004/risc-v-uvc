module regF(
    input logic clk,
    input logic en,
    input logic rst_n,

    input  logic [31:0] PCF_p,
    output logic [31:0] PCF
);

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            PCF <= 32'b0;
        end 
        else if (en) begin
            PCF <= PCF_p;
        end
    end
    
endmodule
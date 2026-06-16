import processor_pkg::*;

module comparator(
    input  logic        CompSrc,
    input  logic        CompSign,
    input  logic [1:0]  CompOp,
    input  logic [31:0] RD1,
    input  logic [31:0] RD2,
    input  logic [31:0] ImmExt,
    output logic        CompResult
);

    wire [31:0] src1, src2;

    always_comb begin

        src1 = RD1;
        src2 = (CompSrc == COMP_SEL_RD2) ? RD2 : ImmExt;

        case (CompOp)
            COMP_EQ: CompResult = (src1 == src2);
            COMP_NE: CompResult = (src1 != src2);
            COMP_LT: CompResult = CompSign ? ($signed(src1) < $signed(src2))  : (src1 < src2);
            COMP_GE: CompResult = CompSign ? ($signed(src1) >= $signed(src2)) : (src1 >= src2);
            default: CompResult = 1'b0;
        endcase

    end
    
endmodule
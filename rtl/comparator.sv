import processor_pkg::*;

module comparator(
    input  logic        CompSign,
    input  logic [1:0]  CompOp,
    input  logic [31:0] Comp1,
    input  logic [31:0] Comp2,
    output logic        CompResult
);

    always_comb begin

        case (CompOp)
            COMP_EQ: CompResult = (Comp1 == Comp2);
            COMP_NE: CompResult = (Comp1 != Comp2);
            COMP_LT: CompResult = CompSign ? ($signed(Comp1) < $signed(Comp2))  : (Comp1 < Comp2);
            COMP_GE: CompResult = CompSign ? ($signed(Comp1) >= $signed(Comp2)) : (Comp1 >= Comp2);
            default: CompResult = 1'b0;
        endcase

    end
    
endmodule
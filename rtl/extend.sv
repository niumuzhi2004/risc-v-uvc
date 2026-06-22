import processor_pkg::*;

module extend(
    input  logic [24:0] Imm,
    input  logic [2:0]  ImmSrc,
    output logic [31:0] ImmExt
);

    always_comb begin
        
        case (ImmSrc)
            IMM_I_TYPE: ImmExt = {{21{Imm[24]}}, Imm[23:13]};
            IMM_S_TYPE: ImmExt = {{21{Imm[24]}}, Imm[23:18], Imm[4:0]};
            IMM_B_TYPE: ImmExt = {{20{Imm[24]}}, Imm[0], Imm[23:18], Imm[4:1], 1'b0};
            IMM_U_TYPE: ImmExt = {Imm[24:5], 12'b0};
            IMM_J_TYPE: ImmExt = {{12{Imm[24]}}, Imm[12:5], Imm[13], Imm[23:14], 1'b0};
            default:    ImmExt = 32'b0;
        endcase

    end
    
endmodule
import processor_pkg::*;

module hazard_unit(
    // for forwarding
    input  logic [4:0] Rs1E,
    input  logic [4:0] Rs2E,
    input  logic [4:0] RdM,
    input  logic [4:0] RdW,
    input  logic       RegWriteM,
    input  logic       RegWriteW, 
    output logic [1:0] ForwardAE,
    output logic [1:0] ForwardBE,

    // for stall
    input  logic [4:0] Rs1D,
    input  logic [4:0] Rs2D,
    input  logic [4:0] RdE,
    input  logic [1:0] ResultSrcE,
    output logic       StallF,
    output logic       StallD,

    // for flush
    input  logic       PCSrcE,
    output logic       FlushE,
    output logic       FlushD
);  

    logic lwStall;

    always_comb begin

        // forwarding logic for I-, U-, R-, and J-type instructions
        if (RegWriteM && (Rs1E == RdM) && (Rs1E != 0))
            ForwardAE = FORWARD_SEL_RESULTM;    // forward from memory stage
        else if (RegWriteW && (Rs1E == RdW) && (Rs1E != 0))
            ForwardAE = FORWARD_SEL_RESULTW;    // forward from writeback stage
        else
            ForwardAE = FORWARD_SEL_RDE;        // no forwarding

        if (RegWriteM && (Rs2E == RdM) && (Rs2E != 0))
            ForwardBE = FORWARD_SEL_RESULTM;    // forward from memory stage
        else if (RegWriteW && (Rs2E == RdW) && (Rs2E != 0))
            ForwardBE = FORWARD_SEL_RESULTW;    // forward from writeback stage
        else
            ForwardBE = FORWARD_SEL_RDE;        // no forwarding

        // stall logic for load instructions
        lwStall = (ResultSrcE == RESULT_SEL_READ_DATA) &&
                  ((Rs1D == RdE && Rs1D != 0) || (Rs2D == RdE && Rs2D != 0));
        
        StallF = lwStall;
        StallD = lwStall;

        // flush logic for branch & jump instructions
        FlushD = PCSrcE;
        FlushE = lwStall || PCSrcE; // flush needed for either stall or flush logic
        
    end
    
endmodule
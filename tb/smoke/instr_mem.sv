module instr_mem(
    input  logic [5:0]  A,
    output logic [31:0] RD
);

    logic [31:0] mem [64];
    assign RD = mem[A];

    initial begin
        $readmemh("../programs/smoke_test1.hex", mem);
    end
    
endmodule
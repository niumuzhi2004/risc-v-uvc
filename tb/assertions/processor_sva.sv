module processor_sva (
    input logic        clk,
    input logic        rst_n,
    input logic        mem_re,
    input logic [3:0]  mem_we,
    input logic        Halt,
    input logic [31:0] PCF,
    input logic        Valid,
    input logic [31:0] DebugRegFile [32]
);

    // no simultaneous data memory reads and writes
    property mem_we_re;
        @(posedge clk) disable iff (~rst_n)
        mem_re |-> not(|mem_we);
    endproperty

    // valid byte enable patterns for SB, SH, and SW
    property mem_we_vals;
        @(posedge clk) disable iff (~rst_n)
        (mem_we inside {4'b1111, 4'b0000, 4'b1100, 4'b0011, 4'b0001, 4'b0010, 4'b0100, 4'b1000});
    endproperty

    // halt never deasserts once asserted, unless during reset
    property halt_assertion;
        @(posedge clk) disable iff (~rst_n)
        not($fell(Halt));
    endproperty

    // program counter needs to be a multiple of 4
    property pc_value;
        @(posedge clk) disable iff (~rst_n)
        (PCF[1:0] == 2'b00);
    endproperty

    // register x0 must always be zero
    property x0_value;
        @(posedge clk) disable iff (~rst_n)
        (DebugRegFile[0] == 32'b0);
    endproperty

    // valid must not be high during reset
    property valid_value;
        @(posedge clk) 
        ~rst_n |-> ~Valid;
    endproperty

    no_simultaneous_read_and_write: assert property (mem_we_re);
    valid_mem_we_patterns:          assert property (mem_we_vals);
    halt_only_asserts_once:         assert property (halt_assertion);
    program_counter_aligned:        assert property (pc_value);
    register_x0_always_zero:        assert property (x0_value);
    not_valid_during_reset:         assert property (valid_value);

endmodule
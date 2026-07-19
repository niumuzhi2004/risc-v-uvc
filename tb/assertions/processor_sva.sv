module processor_sva (
    input logic        clk,
    input logic        rst_n,
    input logic        mem_re,
    input logic [3:0]  mem_we,
    input logic        Halt,
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
        Halt |-> ##1 Halt;
    endproperty

    // register x0 must always be zero
    property x0_value;
        @(posedge clk) disable iff (~rst_n)
        (DebugRegFile[0] == 32'b0);
    endproperty

    // valid must not be high during reset or halt
    property valid_value;
        @(posedge clk)
        ((!$isunknown(rst_n)) && (!$isunknown(Halt)) && (~rst_n || Halt)) |-> ~Valid;
    endproperty

    no_simultaneous_read_and_write: assert property (mem_we_re)
    else $error("SVA Violation: No simultaneous data memory reads and writes");

    valid_mem_we_patterns: assert property (mem_we_vals)
    else $error("SVA Violation: Invalid memory write enable pattern");

    halt_only_asserts_once: assert property (halt_assertion)
    else $error("SVA Violation: Halt signal deasserted after being asserted");

    register_x0_always_zero: assert property (x0_value)
    else $error("SVA Violation: Register x0 is not zero");
    
    not_valid_during_reset_or_halt: assert property (valid_value)
    else $error("SVA Violation: Valid signal is high during reset or halt");

endmodule
bind processor processor_sva u_sva (
    .clk(clk),
    .rst_n(rst_n),
    .mem_re(mem_re),
    .mem_we(mem_we),
    .Halt(Halt),
    .PCF(PCF),
    .Valid(Valid),
    .DebugRegFile(DebugRegFile)
);
# RISC-V Pipelined Processor UVM Verification Component

## Overview
This project implements a simple **UVM (Universal Verification Methodology) verification component** for a RISC-V (RV32I) pipelined processor.

## DUT Specification

<p align="center">
    <img src="./.github/pipelined_cpu.svg?v=1" width="100%"><br>
    <sup>Pipelined Processor with Control and Full Hazard Handling.</sup>
</p>

| Parameter | Value |
|-----------|-------|
| Pipeline Depth | 5-stage (fetch, decode, execute, memory, and writeback) |
| Hazard Handling | Full forwarding + stall on load-use hazards |
| Instruction Set Architecture (ISA) | RV32I subset (excluding `FENCE`, `ECALL`, and `EBREAK`) |
| Memory | Synchronous SRAMs in RTL ||
| Reset | Synchronous, active-low |
| Debug status flags | `Halt`, `DebugRegFiles` (32 register `x0`-`x31` exposed) |


For more details on the design of RISC-V pipelined processor, please refer to the [DUT Design](./docs/DUT_specs.md).

## Smoke Test
Before diving into the full UVM testbench, we first run a simple smoke test to verify basic functionality of the DUT. The smoke test initializes the processor, applies a few instructions, and checks for correct execution.

A smoke-test program includes the instructions below, in an attempt to cover R-type, I-type, S-type, B-type, U-type, and J-type instructions, as well as read-after-write (RAW) hazards, load hazards, and branch and jump control hazards:

```assembly
 1 | addi  x3, x0, 0x100
 2 | addi  x1, x0, 4
 3 | lui   x2, 0xFFFFF
 4 | srl   x2, x2, x1
 5 | bgeu  x2, x3, -4
 6 | sw    x2, 4(x1)
 7 | lh    x4, 4(x1)
 8 | xor   x9, x4, x0
 9 | jal   x5, 8
10 | and   x2, x1, x0 // gets skipped
11 | slt   x6, x1, x5
12 | auipc x7, 0x00001
13 | jalr  x8, x5, 16
```

The test is translated into machine code and terminated by the `Halt` signal triggered by an all-zero instruction. The register file was checked in the end to see if it follows the expected results:

| Register | Value | Set by Instruction |
|----------|-------|--------------------|
| x1 | `4` | Line 2:  `addi` |
| x2 | `0x000000FF` | Line 4: `srl` loop |
| x3 | `0x100` | Line 1: `addi` |
| x4 | `0x000000FF` | Line 7: `lh` |
| x5 | `36` | Line 9: `jal` |
| x6 | `1` | Line 11: `slt` |
| x7 | `0x102C` | Line 12: `auipc` |
| x8 | `52` | Line 13: `jalr` |
| x9 | `0x000000FF` | Line 8: `xor` |

## Testbench Architecture


## Results


## Requirements
| Tool | Version |
|---|---| 
| Xilinx Vivado | XSIM v2025.2 |
| UVM | UVM 1.2 (within Vivado) |


## How to Run
```cmd
cd sim
vivado -mode batch -source run.tcl
```

> Coverage report generated at `sim/coverage_report/functionalCoverageReport/dashboard.html`


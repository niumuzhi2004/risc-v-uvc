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
| Debug status flags | `Halt`, `Instr`, `PC`, `Valid`, `DebugRegFile` (32 register `x0`-`x31` exposed) |


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

## Verification Plan
The verification plan includes a comprehensive set of directed and constrained-random tests to cover all supported instructions, hazard scenarios, and pipeline behaviors. More details can be found in the [Verification Plan](./docs/verification_plan.md).

## Testbench Architecture
<p align="center">
    <img src="./.github/tb_arch.svg" width="90%"><br>
    <sup>UVM Testbench Architecture.</sup>
</p>

- **UVC** - UVM verification component
    - **Instruction Agent**: Drives programs into instruction memory and manages reset
    - **Data Memory Agent**: Handles write and read transactions from the DUT
    - **Debug Monitor**: standalone monitor collecting debug status flags
    - **Sequence Items**: `instr_seq_item`, `data_mem_seq_item`, and `debug_seq_item`
- **Environment** - System-level components
    - **Scoreboard**: Compares DUT outputs with expected results
    - **Coverage Collector**: functional covergroups reflecting [Feature Coverage Plan](./docs/verification_plan.md#feature-coverage-plan)
    - **ISS**: SystemVerilog Instruction Set Simulator as reference model
- **Sequences** - 2 constrained random and 6 directed sequences to cover instructions and hazards
    - **Constrained Random Sequence** - generates random instructions
    - **Random Without Jumps Sequence** - excludes jump and branch instructions
    - **Address Alignment Sequence** - tests aligned and unaligned memory accesses
    - **Consecutive Hazards Sequence** - tests back-to-back hazard scenarios
    - **Invalid Branch/JAL/JALR Sequence** - tests invalid branch, `JAL`, and `JALR` instructions
    - **Directed Testing Sequence** - covers hard-to-hit coverage bins
- **Tests** - 8 tests mapping to the sequences above

More on the testbench architecture can be found in the [Testbench Architecture](./docs/tb_architecture.md).


## Assertions

The testbench includes a set of SystemVerilog Assertions (SVA) to ensure several crucial properties of the DUT are not violated during the simulation.

1. No simultaneous read and write to the data memory.
2. Valid byte enable combinations for `SB`, `SH`, and `SW`.
3. Halt never deasserts once asserted, unless during reset.
4. Register `x0` is always zero.
5. Valid must not be asserted during reset or halt.

## Results

`constrained_random_test` is run for 100 seeds, and `rand_without_jump_test` is run for 50 seeds. The directed tests are each run once. The simulation results are summarized below:

| Result | Status |
|--------|--------|
| Total Instructions Run | 10307 |
| Functional Coverage | 100% |
| Scoreboard Pass Rate | 100% |
| `UVM_ERROR` Count | 0 |
| Assertion Violations | 0 |

## Requirements
| Tool | Version |
|---|---| 
| Xilinx Vivado | XSIM v2025.2 |
| UVM | UVM 1.2 (within Vivado) |

## Repo Structure
- `docs/` - Documentation for DUT specs, testbench architecture, and verification plan
- `rtl/` - RTL source files for the RISC-V pipelined processor
- `sim/` - Simulation scripts
    - `sim/smoke/` - tcl simulation scripts for smoke test
    - `sim/uvm/` - tcl & Python simulation scripts for UVM testbench
- `tb/` - UVM testbench source files
    - `tb/assertions/` - SystemVerilog assertions
    - `tb/smoke/` - Smoke test testbench files
    - `tb/uvm/` - UVM testbench files

## How to Run
### Running the smoke test

```cmd
cd sim
vivado -mode batch -source ./smoke/run.tcl
```

### Running the UVM testbench
```cmd
cd sim
python ./uvm/regression.py
```

> Coverage report generated at `sim/coverage_report/functionalCoverageReport/dashboard.html`


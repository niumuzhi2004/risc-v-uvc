# RISC-V Pipelined Processor UVM Verification Component

## Overview
This project implements a simple **UVM (Universal Verification Methodology) verification component** for a RISC-V (RV32I) pipelined processor.

## DUT Specification
| Parameter | Value |
|-----------|-------|
| Pipeline Depth | 5-stage (fetch, decode, execute, memory, and writeback) |
| Hazard Handling | Full forwarding + stall on load-use hazards |
| Instruction Set Architecture (ISA) | RV32I subset (excluding `FENCE`, `ECALL`, and `EBREAK`) |
| Memory | Synchronous SRAMs in RTL ||
| Reset | Synchronous, active-low |
| Debug status flags | `Halt`, `DebugRegFiles` (32 register `x0`-`x31` exposed) |

<p align="center">
    <img src="./.github/pipelined_cpu.svg?v=1" width="100%"><br>
    <sup>Pipelined Processor with Control and Full Hazard Handling.</sup>
</p>

For more details on the design of RISC-V pipelined processor, please refer to the [DUT Design](./rtl/DUT.md).


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


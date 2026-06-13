# RISC-V Pipelined Processor UVM Verification Component

## Overview
This project implements a simple **UVM (Universal Verification Methodology) verification component** for a RISC-V (RV32I) pipelined processor.

## DUT Specification
| Parameter | Value |
|-----------|-------|
| Pipeline Depth | 5-stage (fetch `IF`, decode `ID`, execute `EX`, memory `MEM`, and writeback `WB`) |
| Hazard Handling | Full forwarding + stall on load-use hazards |
| Instruction Set Architecture (ISA) | RV32I subset (excluding `FENCE`, `ECALL`, and `EBREAK`) |
| Memory | Synchronous SRAMs in RTL ||
| Reset | Synchronous, active-low |
| Debug status flags | TBD |


## Control Unit
![Control Unit of RISC-V Pipelined Processor](./.github/pipelined_control_unit.svg)

| Control Signal | Width | Explanation |
|----------------|-------|-------------|
| `RegWrite`   | 1 | Enable write to register file |
| `ResultSrc`  | 2 | Mux select for result: (1) ALU result, (2) read data from data memory, or (3) `PC+4` |
| `MemWrite`   | 1 | Enable write to data memory |
| `MemWidth`   | 2 | Data memory access width: byte/half-word/word |
| `MemSign`    | 1 | Data signedness: signed/unsigned |
| `Jump`       | 1 | Jump instruction (`jal` or `jalr`)  |
| `Branch`     | 1 | Branch instruction (`beq`, `bne`, `blt`, `bge`, `bltu`, or `bgeu`) |
| `ALUControl` | 3 | ALU operation select (`ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, or `SRA`) |
| `ALUSrc1`    | 2 | Mux select for ALU input #1: (1) RD1 from register file, (2) PC, or (3) zero |
| `ALUSrc2`    | 1 | Mux select for ALU input #2: (1) RD2 from register file or (2) extended immediate |
| `ImmSrc`     | 3 | Specifies immediate encoding for I-, S-, B-, U-, and J-type instructions |


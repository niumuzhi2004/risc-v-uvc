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


## Control Unit

<p align="center">
    <img src="./.github/control_unit.svg" width="50%"><br>
    <sup>Control Unit of RISC-V Pipelined Processor.</sup>
</p>

The control unit decodes the instruction based on (1) the `op` code, (2) the `funct3` field, and (3) the `funct7` field, generating the following control signals:

| Control Signal | Width | Explanation |
|----------------|-------|-------------|
| `RegWrite`   | 1 | Enable write to register file |
| `ResultSrc`  | 2 | Mux select for result: (1) ALU result, (2) read data from data memory, (3) `PC+4`, or (4) comparator result |
| `MemWrite`   | 1 | Enable write to data memory |
| `MemWidth`   | 2 | Data memory access width: byte/half-word/word |
| `MemSign`    | 1 | Memory data signedness: signed/unsigned |
| `Jump`       | 1 | Jump instruction (`jal` or `jalr`)  |
| `Branch`     | 1 | Branch instruction (`beq`, `bne`, `blt`, `bge`, `bltu`, or `bgeu`) |
| `ALUControl` | 3 | ALU operation select (`ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, or `SRA`) |
| `ALUSrc1`    | 2 | Mux select for ALU input #1: (1) RD1 from register file, (2) PC, or (3) zero |
| `ALUSrc2`    | 1 | Mux select for ALU input #2: (1) RD2 from register file or (2) extended immediate |
| `AdderESrc`    | 1 | Mux select for Ex stage adder input #1: (1) RD1 from register file or (2) PC |
| `CompSign`    | 1 | Comparison signedness: signed/unsigned |
| `CompOp`    | 2 | Comparator operation select (`EQ`, `NE`, `LT`, or `GE`) |
| `ImmSrc`     | 3 | Specifies immediate encoding for I-, S-, B-, U-, and J-type instructions |
| `Halt`     | 1 | Halts the processor in case of unrecognized op code |

It is worth noting that input #2 to the comparator and input #2 to the ALU share the same control signal. Either that only one of them is used at a time, or they share the same source (`RD1E` or `ImmExtE`) for certain instructions (`SLT`, `SLTU`, `SLTI`, and `SLTIU`).


## Register File

<p align="center">
    <img src="./.github/register_file.svg" width="60%"><br>
    <sup>Register File of RISC-V Pipelined Processor.</sup>
</p>

The register file has 32 registers `x0`-`x31`, each 32 bits wide. It supports two read ports and one write port. Register `x0` is hardwired to zero and cannot be written to.

| Port | Width | Explanation |
|--------|-------|-------------|
| `CLK` | 1 | Clock signal (inverted)|
| `A1` | 5 | Read address for `RD1` |
| `A2` | 5 | Read address for `RD2` |
| `A3` | 5 | Write address for `WD3` |
| `RD1` | 32 | Read data output port #1 |
| `RD2` | 32 | Read data output port #2 |
| `WE3` | 1 | Write enable for `WD3` |
| `WD3` | 32 | Write data input port |
| `DebugRegFile` | 1024 | Debug output for all 32 registers (32 bits each) |

The 5-bit addresses cover all 32 registers. Write operations occur on the falling edge of the clock when `WE3` is asserted. Read operations are combinational, providing the contents of the addressed registers on `RD1` and `RD2`. In addition, the registers are exposed as a debug output `DebugRegFile` for easier verification and debugging.


## ALU

<p align="center">
    <img src="./.github/ALU.svg" width="50%"><br>
    <sup>ALU of RISC-V Pipelined Processor.</sup>
</p>

The arithmetic logic unit (ALU) performs various arithmetic and logical operations based on the `ALUControl` signal. It takes two 32-bit inputs and produces a 32-bit output. The following operations are supported:

| ALUControl | Operation | Description | Formula |
|------------|-----------|-------------|---------|
| `000` | `ADD` | Addition | $`\text{ALUResult} = \text{Src1} + \text{Src2}`$ |
| `001` | `SUB` | Subtraction | $`\text{ALUResult} = \text{Src1} - \text{Src2}`$ |
| `010` | `AND`  | Bitwise AND | $`\text{ALUResult} = \text{Src1} \; \& \; \text{Src2}`$ |
| `011` | `OR`   | Bitwise OR | $`\text{ALUResult} = \text{Src1} \; \vert \; \text{Src2}`$ |
| `100` | `XOR` | Bitwise XOR | $`\text{ALUResult} = \text{Src1} \oplus \text{Src2}`$ |
| `101` | `SLL` | Shift Left Logical | $`\text{ALUResult} = \text{Src1} \ll \text{Src2}_{4:0}`$|
| `110` | `SRL` | Shift Right Logical | $`\text{ALUResult} = \text{Src1} \gg \text{Src2}_{4:0}`$|
| `111` | `SRA` | Shift Right Arithmetic | $`\text{ALUResult} = \text{Src1} \ggg \text{Src2}_{4:0}`$|


## Comparator
<p align="center">
    <img src="./.github/comparator.svg" width="55%"><br>
    <sup>Comparator of RISC-V Pipelined Processor.</sup>
</p>

The comparator performs comparisons for branch instructions and along with `SLT`, `SLTU`, `SLTI`, and `SLTIU`. It takes two 32-bit inputs and produces a 1-bit output indicating the result of the comparison. The comparison type is specified through the `CompOp` signal, and the signedness of the comparison is specified through `CompSign`. The following operations are supported:

| CompOp | Operation | Description | Formula |
|--------|-----------|-------------|---------|
| `00` | `EQ` | Equal to | $`\text{CompResult} = (\text{Src1} == \text{Src2})`$ |
| `01` | `NE` | Not equal to | $`\text{CompResult} = (\text{Src1} \neq \text{Src2})`$ |
| `10` | `LT` | Less than | $`\text{CompResult} = (\text{Src1} < \text{Src2})`$ |
| `11` | `GE` | Greater than or equal to | $`\text{CompResult} = (\text{Src1} \geq \text{Src2})`$ |

When `CompSign` is asserted, the comparator treats both inputs as signed integers. Otherwise, both inputs are treated as unsigned integers. 


## Extend Unit
<p align="center">
    <img src="./.github/extend_unit.svg" width="55%"><br>
    <sup>Extend Unit of RISC-V Pipelined Processor.</sup>
</p>

The extend unit generates the extended immediate values based on the instruction type specified by the `ImmSrc` control signal. It takes the top 25 bits from the instruction as input and produces a 32-bit extended immediate value as output. First, the unit recovers the original immediate value based on the RISC-V 32-bit instruction formats:

<table>
  <thead>
    <tr>
      <th>Instruction Type</th>
      <th>31:25</th>
      <th>24:20</th>
      <th>19:15</th>
      <th>14:12</th>
      <th>11:7</th>
      <th>6:0</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>R-type</td>
      <td><code>funct7</code></td>
      <td><code>rs2</code></td>
      <td><code>rs1</code></td>
      <td><code>funct3</code></td>
      <td><code>rd</code></td>
      <td><code>op</code></td>
    </tr>
    <tr>
      <td>I-type</td>
      <td colspan="2">imm<sub>11:0</sub></td>
      <td><code>rs1</code></td>
      <td><code>funct3</code></td>
      <td><code>rd</code></td>
      <td><code>op</code></td>
    </tr>
    <tr>
      <td>S-type</td>
      <td>imm<sub>11:5</sub></td>
      <td><code>rs2</code></td>
      <td><code>rs1</code></td>
      <td><code>funct3</code></td>
      <td>imm<sub>4:0</sub></td>
      <td><code>op</code></td>
    </tr>
    <tr>
      <td>B-type</td>
      <td>imm<sub>12,10:5</sub></td>
      <td><code>rs2</code></td>
      <td><code>rs1</code></td>
      <td><code>funct3</code></td>
      <td>imm<sub>4:1,11</sub></td>
      <td><code>op</code></td>
    </tr>
    <tr>
      <td>U-type</td>
      <td colspan="4">imm<sub>31:12</sub></td>
      <td><code>rd</code></td>
      <td><code>op</code></td>
    </tr>
    <tr>
      <td>J-type</td>
      <td colspan="4">imm<sub>20,10:1,11,19:12</sub></td>
      <td><code>rd</code></td>
      <td><code>op</code></td>
    </tr>
  </tbody>
</table>

Then, based on the instruction type, the extend unit generates the extended immediate value as follows:


| ImmSrc | Instruction Type | Immediate Encoding |
|--------|------------------|--------------------|
| `000` | I-type | $`\text{ImmExt} = \text{SignExt}({\textbf{{imm}}_{11:0}})`$ |
| `001` | S-type | $`\text{ImmExt} = \text{SignExt}({\textbf{{imm}}_{11:0}})`$ |
| `010` | B-type | $`\text{ImmExt} = \text{SignExt}({\textbf{{imm}}_{12:1}, \text{1'b0}})`$ |
| `011` | U-type | $`\text{ImmExt} = \{\textbf{{imm}}_{31:12}, \text{12'b0}\}`$ |
| `100` | J-type | $`\text{ImmExt} = \text{SignExt}({\textbf{{imm}}_{20:1}, \text{1'b0}})`$ |
> **Note:** R-type instructions have no immediate field, so `ImmSrc` is a don't-care for them.


## Hazard Unit
<p align="center">
    <img src="./.github/hazard_unit.svg" width="55%"><br>
    <sup>Hazard Unit of RISC-V Pipelined Processor.</sup>
</p>

The hazard unit detects data and control hazards in the pipeline and generates the appropriate forwarding, stall, and flush signals to ensure correct execution of instructions. The following types of hazards are handled:

| Hazard Type | Applicable Instructions | Handling |
|-------------|-------------------------|----------|
| Read-after-write (RAW) data hazard | I-, U-, R-, and J-type instructions | Forwarding from `MEM`/`WB` stages to `EX` stage |
| Load data hazard | Load instructions | Stall the `IF` and `ID` stages for one cycle |
| Control hazard | Branch and jump instructions | Assume path not taken; if the branch is taken or jump is taken, flush the instructions in `IF` and `ID` stages |


## Data Memory Interface

The actual data memory is not implemented in the RTL. Instead, the processor interfaces with a synchronous SRAM module that mimics the behavior of a real memory. The SRAM has the following interface, which is slightly different than the data memory interface drawn in the block diagram:

| Port | Width | Explanation |
|------|-------|-------------|
|`clk` | 1 | Clock signal |
|`mem_addr` | 32 | Memory address |
|`mem_wr_data` | 32 | Write data |
|`mem_we` | 4 | Byte enable for write (each bit represent one byte in a word) |
|`mem_rd_data` | 32 | Read data |
|`mem_re` | 1 | Read enable |

Signal `mem_addr` is wired to `ALUResultM`, and `mem_wr_data` is wired to `WriteDataM`. `mem_re` is asserted when `ResultSrcM` selects read memory data. `mem_we` is determined from `MemWidthM` and the last two bits of `mem_addr` for alignment:

|`MemWidthM` | `ALUResultM[1:0]` | `mem_we` |
|------------|-------------------|----------|
| WORD | `00` | `4'b1111` |
| HALF | `00` | `4'b0011` |
| HALF | `10` | `4'b1100` |
| BYTE | `00` | `4'b0001` |
| BYTE | `01` | `4'b0010` |
| BYTE | `10` | `4'b0100` |
| BYTE | `11` | `4'b1000` |

Similarly, the appropriate bits in `mem_rd_data` is extracted based on `MemWidthM` and the last two bits of `mem_addr`, and then sign-extended or zero-extended based on `MemSignM` to produce the final read data `ReadDataM`.
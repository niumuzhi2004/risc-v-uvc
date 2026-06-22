# Design of RISC-V Pipelined Processor (RV32I)

## Architecture Overview
The RISC-V pipelined processor is a 5-stage pipeline architecture that implements a subset of the RV32I instruction set architecture (ISA). The five stages of the pipeline are:
1. **Instruction Fetch (IF)**: Fetches the instruction from the instruction memory.
2. **Instruction Decode (ID)**: Decodes the fetched instruction and reads from the register file.
3. **Execute (EX)**: Performs the required operation using the ALU, comparator, or adder.
4. **Memory Access (MEM)**: Accesses the data memory if needed.
5. **Write Back (WB)**: Writes the result back to the register file.

<p align="center">
    <img src="../.github/pipelined_cpu.svg?v=1" width="100%"><br>
    <sup>Pipelined Processor with Control and Full Hazard Handling.</sup>
</p>

## List of Supported Instructions

### 1.1 RISC-V 32-Bit Instruction Formats

<table id="riscv-instructions">
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

### 1.2 Supported RV32I Instructions

<div style="overflow-x: auto; white-space: nowrap;">
  <table id="riscv-instructions" style="width: 100%; min-width: 600px;">
    <thead>
      <tr>
        <th>op</th>
        <th>funct3</th>
        <th>Type</th>
        <th>Instruction</th>
        <th>Description</th>
        <th>Operation</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>3</td>
        <td>000</td>
        <td>I</td>
        <td><code>lb rd, imm(rs1)</code></td>
        <td>load byte</td>
        <td>rd = SignExt([rs1 + SignExt(imm<sub>11:0</sub>)]<sub>7:0</sub>)</td>
      </tr>
      <tr>
        <td>3</td>
        <td>001</td>
        <td>I</td>
        <td><code>lh rd, imm(rs1)</code></td>
        <td>load half</td>
        <td>rd = SignExt([rs1 + SignExt(imm<sub>11:0</sub>)]<sub>15:0</sub>)</td>
      </tr>
      <tr>
        <td>3</td>
        <td>010</td>
        <td>I</td>
        <td><code>lw rd, imm(rs1)</code></td>
        <td>load word</td>
        <td>rd = [rs1 + SignExt(imm<sub>11:0</sub>)]<sub>31:0</sub></td>
      </tr>
      <tr>
        <td>3</td>
        <td>100</td>
        <td>I</td>
        <td><code>lbu rd, imm(rs1)</code></td>
        <td>load byte unsigned</td>
        <td>rd = ZeroExt([rs1 + SignExt(imm<sub>11:0</sub>)]<sub>7:0</sub>)</td>
      </tr>
      <tr>
        <td>3</td>
        <td>101</td>
        <td>I</td>
        <td><code>lhu rd, imm(rs1)</code></td>
        <td>load half unsigned</td>
        <td>rd = ZeroExt([rs1 + SignExt(imm<sub>11:0</sub>)]<sub>15:0</sub>)</td>
      </tr>
      <tr>
        <td>19</td>
        <td>000</td>
        <td>I</td>
        <td><code>addi rd, rs1, imm</code></td>
        <td>add immediate</td>
        <td>rd = rs1 + SignExt(imm<sub>11:0</sub>)</td>
      </tr>
      <tr>
        <td>19</td>
        <td>001<sup>*</sup></td>
        <td>I</td>
        <td><code>slli rd, rs1, uimm</code></td>
        <td>shift left logical immediate</td>
        <td>rd = rs1 &lt;&lt; imm<sub>4:0</sub></td>
      </tr>
      <tr>
        <td>19</td>
        <td>010</td>
        <td>I</td>
        <td><code>slti rd, rs1, imm</code></td>
        <td>set less than immediate</td>
        <td>rd = (rs1 &lt; SignExt(imm<sub>11:0</sub>))</td>
      </tr>
      <tr>
        <td>19</td>
        <td>011</td>
        <td>I</td>
        <td><code>sltiu rd, rs1, imm</code></td>
        <td>set less than imm. unsigned</td>
        <td>rd = (rs1 &lt; SignExt(imm<sub>11:0</sub>))</td>
      </tr>
      <tr>
        <td>19</td>
        <td>100</td>
        <td>I</td>
        <td><code>xori rd, rs1, imm</code></td>
        <td>xor immediate</td>
        <td>rd = rs1 ^ SignExt(imm<sub>11:0</sub>)</td>
      </tr>
      <tr>
        <td>19</td>
        <td>101<sup>*</sup></td>
        <td>I</td>
        <td><code>srli rd, rs1, uimm</code></td>
        <td>shift right logical immediate</td>
        <td>rd = rs1 &gt;&gt; imm<sub>4:0</sub></td>
      </tr>
      <tr>
        <td>19</td>
        <td>101<sup>**</sup></td>
        <td>I</td>
        <td><code>srai rd, rs1, uimm</code></td>
        <td>shift right arithmetic imm.</td>
        <td>rd = rs1 &gt;&gt;&gt; imm<sub>4:0</sub></td>
      </tr>
      <tr>
        <td>19</td>
        <td>110</td>
        <td>I</td>
        <td><code>ori rd, rs1, imm</code></td>
        <td>or immediate</td>
        <td>rd = rs1 | SignExt(imm<sub>11:0</sub>)</td>
      </tr>
      <tr>
        <td>19</td>
        <td>111</td>
        <td>I</td>
        <td><code>andi rd, rs1, imm</code></td>
        <td>and immediate</td>
        <td>rd = rs1 &amp; SignExt(imm<sub>11:0</sub>)</td>
      </tr>
      <tr>
        <td>23</td>
        <td>-</td>
        <td>U</td>
        <td><code>auipc rd, upimm</code></td>
        <td>add upper immediate to PC</td>
        <td>rd = {imm<sub>31:12</sub>, 12'b0} + PC</td>
      </tr>
      <tr>
        <td>35</td>
        <td>000</td>
        <td>S</td>
        <td><code>sb rs2, imm(rs1)</code></td>
        <td>store byte</td>
        <td>[rs1 + SignExt(imm<sub>11:0</sub>)]<sub>7:0</sub> = rs2<sub>7:0</sub></td>
      </tr>
      <tr>
        <td>35</td>
        <td>001</td>
        <td>S</td>
        <td><code>sh rs2, imm(rs1)</code></td>
        <td>store half</td>
        <td>[rs1 + SignExt(imm<sub>11:0</sub>)]<sub>15:0</sub> = rs2<sub>15:0</sub></td>
      </tr>
      <tr>
        <td>35</td>
        <td>010</td>
        <td>S</td>
        <td><code>sw rs2, imm(rs1)</code></td>
        <td>store word</td>
        <td>[rs1 + SignExt(imm<sub>11:0</sub>)]<sub>31:0</sub> = rs2</td>
      </tr>
      <tr>
        <td>51</td>
        <td>000<sup>*</sup></td>
        <td>R</td>
        <td><code>add rd, rs1, rs2</code></td>
        <td>add</td>
        <td>rd = rs1 + rs2</td>
      </tr>
      <tr>
        <td>51</td>
        <td>000<sup>**</sup></td>
        <td>R</td>
        <td><code>sub rd, rs1, rs2</code></td>
        <td>sub</td>
        <td>rd = rs1 - rs2</td>
      </tr>
      <tr>
        <td>51</td>
        <td>001<sup>*</sup></td>
        <td>R</td>
        <td><code>sll rd, rs1, rs2</code></td>
        <td>shift left logical</td>
        <td>rd = rs1 &lt;&lt; rs2<sub>4:0</sub></td>
      </tr>
      <tr>
        <td>51</td>
        <td>010<sup>*</sup></td>
        <td>R</td>
        <td><code>slt rd, rs1, rs2</code></td>
        <td>set less than</td>
        <td>rd = (rs1 &lt; rs2)</td>
      </tr>
      <tr>
        <td>51</td>
        <td>011<sup>*</sup></td>
        <td>R</td>
        <td><code>sltu rd, rs1, rs2</code></td>
        <td>set less than unsigned</td>
        <td>rd = (rs1 &lt; rs2)</td>
      </tr>
      <tr>
        <td>51</td>
        <td>100<sup>*</sup></td>
        <td>R</td>
        <td><code>xor rd, rs1, rs2</code></td>
        <td>xor</td>
        <td>rd = rs1 ^ rs2</td>
      </tr>
      <tr>
        <td>51</td>
        <td>101<sup>*</sup></td>
        <td>R</td>
        <td><code>srl rd, rs1, rs2</code></td>
        <td>shift right logical</td>
        <td>rd = rs1 &gt;&gt; rs2<sub>4:0</sub></td>
      </tr>
      <tr>
        <td>51</td>
        <td>101<sup>**</sup></td>
        <td>R</td>
        <td><code>sra rd, rs1, rs2</code></td>
        <td>shift right arithmetic</td>
        <td>rd = rs1 &gt;&gt;&gt; rs2<sub>4:0</sub></td>
      </tr>
      <tr>
        <td>51</td>
        <td>110<sup>*</sup></td>
        <td>R</td>
        <td><code>or rd, rs1, rs2</code></td>
        <td>or</td>
        <td>rd = rs1 | rs2</td>
      </tr>
      <tr>
        <td>51</td>
        <td>111<sup>*</sup></td>
        <td>R</td>
        <td><code>and rd, rs1, rs2</code></td>
        <td>and</td>
        <td>rd = rs1 &amp; rs2</td>
      </tr>
      <tr>
        <td>55</td>
        <td>-</td>
        <td>U</td>
        <td><code>lui rd, upimm</code></td>
        <td>load upper immediate</td>
        <td>rd = {imm<sub>31:12</sub>, 12'b0}</td>
      </tr>
      <tr>
        <td>99</td>
        <td>000</td>
        <td>B</td>
        <td><code>beq rs1, rs2, label</code></td>
        <td>branch if =</td>
        <td>if (rs1 == rs2)<br>PC += SignExt({imm<sub>12:1</sub>, 1'b0})</td>
      </tr>
      <tr>
        <td>99</td>
        <td>001</td>
        <td>B</td>
        <td><code>bne rs1, rs2, label</code></td>
        <td>branch if &ne;</td>
        <td>if (rs1 &ne; rs2)<br>PC += SignExt({imm<sub>12:1</sub>, 1'b0})</td>
      </tr>
      <tr>
        <td>99</td>
        <td>100</td>
        <td>B</td>
        <td><code>blt rs1, rs2, label</code></td>
        <td>branch if &lt;</td>
        <td>if (rs1 &lt; rs2)<br>PC += SignExt({imm<sub>12:1</sub>, 1'b0})</td>
      </tr>
      <tr>
        <td>99</td>
        <td>101</td>
        <td>B</td>
        <td><code>bge rs1, rs2, label</code></td>
        <td>branch if &ge;</td>
        <td>if (rs1 &ge; rs2)<br>PC += SignExt({imm<sub>12:1</sub>, 1'b0})</td>
      </tr>
      <tr>
        <td>99</td>
        <td>110</td>
        <td>B</td>
        <td><code>bltu rs1, rs2, label</code></td>
        <td>branch if &lt; unsigned</td>
        <td>if (rs1 &lt; rs2)<br>PC += SignExt({imm<sub>12:1</sub>, 1'b0})</td>
      </tr>
      <tr>
        <td>99</td>
        <td>111</td>
        <td>B</td>
        <td><code>bgeu rs1, rs2, label</code></td>
        <td>branch if &ge; unsigned</td>
        <td>if (rs1 &ge; rs2)<br>PC += SignExt({imm<sub>12:1</sub>, 1'b0})</td>
      </tr>
      <tr>
        <td>103</td>
        <td>000</td>
        <td>I</td>
        <td><code>jalr rd, rs1, imm</code></td>
        <td>jump and link register</td>
        <td>PC = rs1 + SignExt(imm),<br>rd = PC + 4</td>
      </tr>
      <tr>
        <td>111</td>
        <td>-</td>
        <td>J</td>
        <td><code>jal rd, label</code></td>
        <td>jump and link</td>
        <td>PC = PC + SignExt({imm<sub>20:1</sub>, 1'b0}),<br>rd = PC + 4</td>
      </tr>
    </tbody>
  </table>
</div>

> <sup>*</sup>  Implies a `funct7` value of `0000000` <br>
> <sup>**</sup> Implies a `funct7` value of `0100000` <br>

## List of Submodules
- [Control Unit](#21-control-unit)
- [Register File](#22-register-file)
- [Arithmetic Logic Unit (ALU)](#23-arithmetic-logic-unit-alu)
- [Comparator](#24-comparator)
- [Extend Unit](#25-extend-unit)
- [Hazard Unit](#26-hazard-unit)
- [Data Memory Interface](#27-data-memory-interface)


### 2.1 Control Unit

<p align="center">
    <img src="../.github/control_unit.svg" width="50%"><br>
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


### 2.2 Register File

<p align="center">
    <img src="../.github/register_file.svg" width="60%"><br>
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


### 2.3 Arithmetic Logic Unit (ALU)

<p align="center">
    <img src="../.github/ALU.svg" width="50%"><br>
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


### 2.4 Comparator
<p align="center">
    <img src="../.github/comparator.svg" width="55%"><br>
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


### 2.5 Extend Unit
<p align="center">
    <img src="../.github/extend_unit.svg" width="55%"><br>
    <sup>Extend Unit of RISC-V Pipelined Processor.</sup>
</p>

The extend unit generates the extended immediate values based on the instruction type specified by the `ImmSrc` control signal. It takes the top 25 bits from the instruction as input and produces a 32-bit extended immediate value as output. First, the unit recovers the original immediate value based on the [RISC-V 32-bit instruction formats](#riscv-instructions):

Then, based on the instruction type, the extend unit generates the extended immediate value as follows:


| ImmSrc | Instruction Type | Immediate Encoding |
|--------|------------------|--------------------|
| `000` | I-type | $`\text{ImmExt} = \text{SignExt}({\textbf{{imm}}_{11:0}})`$ |
| `001` | S-type | $`\text{ImmExt} = \text{SignExt}({\textbf{{imm}}_{11:0}})`$ |
| `010` | B-type | $`\text{ImmExt} = \text{SignExt}({\textbf{{imm}}_{12:1}, \text{1'b0}})`$ |
| `011` | U-type | $`\text{ImmExt} = \{\textbf{{imm}}_{31:12}, \text{12'b0}\}`$ |
| `100` | J-type | $`\text{ImmExt} = \text{SignExt}({\textbf{{imm}}_{20:1}, \text{1'b0}})`$ |
> **Note:** R-type instructions have no immediate field, so `ImmSrc` is a don't-care for them.


### 2.6 Hazard Unit
<p align="center">
    <img src="../.github/hazard_unit.svg" width="55%"><br>
    <sup>Hazard Unit of RISC-V Pipelined Processor.</sup>
</p>

The hazard unit detects data and control hazards in the pipeline and generates the appropriate forwarding, stall, and flush signals to ensure correct execution of instructions. The following types of hazards are handled:

| Hazard Type | Applicable Instructions | Handling |
|-------------|-------------------------|----------|
| Read-after-write (RAW) data hazard | I-, U-, R-, and J-type instructions | Forwarding from `MEM`/`WB` stages to `EX` stage |
| Load data hazard | Load instructions | Stall the `IF` and `ID` stages for one cycle |
| Control hazard | Branch and jump instructions | Assume path not taken; if the branch is taken or jump is taken, flush the instructions in `IF` and `ID` stages |


### 2.7 Data Memory Interface

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


## Instruction Datapaths

## References
D. Harris and S. L. Harris, Digital Design and Computer Architecture: RISC-V Edition.
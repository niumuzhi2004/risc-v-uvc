# Verification Plan

- [Introduction](#introduction)
- [Verification Approach](#verification-approach)
- [Feature Coverage Plan](#feature-coverage-plan)
- [Regression Plan](#regression-plan)

## Introduction
The DUT is a RISC-V 5-stage pipelined processor that supports RV32I I-, B-, U-, J-, and S-type instructions. The verification process intends to ensure that the DUT can correctly execute all supported instructions, handle data and control hazards, and maintain proper pipeline operation while running various programs. Timing, power, and excluded instructions (`FENCE`, `ECALL`, `EBREAK`) are not in the scope of this verification plan. 

## Verification Approach
The verification plan relies on the Universal Verification Methodology (UVM) framework to create a modular and reusable testbench. A combination of directed and constrained-random testing will be used to achieve comprehensive coverage of the DUT's functionality. Specifically, UVM 1.2 will be simulated using XSIM within Xilinx Vivado v2025.2, and the testbench will be built in SystemVerilog.

## Feature Coverage Plan
<table>
<thead>
      <tr>
        <th>Feature&nbsp;ID&nbsp;&nbsp;&nbsp;</th>
        <th>Feature&nbsp;Description&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </th>
        <th>Verification&nbsp;Scenarios&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </th>
        <th>Test&nbsp;Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
      </tr>
    </thead>
<tbody>
    <tr>
    <td rowspan="5">LOAD-01</td>
    <td rowspan="5">Processor executes all 5 load instructions (lb, lh, lw, lbu, and lhu)</td>
    <td>LOAD-01-A: instruction is load byte</td>
    <td rowspan="5">Constrained Random</td>
    </tr>
    <tr>
    <td>LOAD-01-B: instruction is load half</td>
    </tr>
    <tr>
    <td>LOAD-01-C: instruction is load word</td>
    </tr>
    <tr>
    <td>LOAD-01-D: instruction is load byte unsigned</td>
    </tr>
    <tr>
    <td>LOAD-01-E: instruction is load half unsigned</td>
    </tr>
    <tr>
    <td rowspan="3">LOAD-02</td>
    <td rowspan="3">Load instructions include a signed immediate that acts as an address offset</td>
    <td>LOAD-02-A: immediate is positive</td>
    <td rowspan="3">Constrained Random</td>
    </tr>
    <tr>
    <td>LOAD-02-B: immediate is negative</td>
    </tr>
    <tr>
    <td>LOAD-02-C: immediate is zero</td>
    </tr>
    <tr>
    <td rowspan="3">LOAD-03</td>
    <td rowspan="3">The address of data memory to read from is computed from the sum of rs1 and the sign-extended immediate</td>
    <td>LOAD-03-A: address is valid</td>
    <td rowspan="3">Constrained Random</td>
    </tr>
    <tr>
    <td>LOAD-03-B: address wraps below base (negative value)</td>
    </tr>
    <tr>
    <td>LOAD-03-C: address wraps above top (out of memory range)</td>
    </tr>
    <tr>
    <td rowspan="7">LOAD-04</td>
    <td rowspan="7">RV32I requires the address to be aligned when reading half or byte values</td>
    <td>LOAD-04-A: reading half with address bits[1:0] = 00</td>
    <td rowspan="7">Directed Testing</td>
    </tr>
    <tr>
    <td>LOAD-04-B: reading half with address bits[1:0] = 10</td>
    </tr>
    <tr>
    <td>LOAD-04-C: reading half with address bits[1:0] = 01/11 *</td>
    </tr>
    <tr>
    <td>LOAD-04-D: reading byte with address bits[1:0] = 00</td>
    </tr>
    <tr>
    <td>LOAD-04-E: reading byte with address bits[1:0] = 01</td>
    </tr>
    <tr>
    <td>LOAD-04-F: reading byte with address bits[1:0] = 10</td>
    </tr>
    <tr>
    <td>LOAD-04-G: reading byte with address bits[1:0] = 11</td>
    </tr>
    <tr>
    <td rowspan="2">LOAD-05</td>
    <td rowspan="2">Processor should not write if register rd is x0 but should write normally otherwise.</td>
    <td>LOAD-05-A: register rd is x0</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>LOAD-05-B: register rd is x1-x31</td>
    </tr>
    <tr>
    <td rowspan="9">ITYPE-01</td>
    <td rowspan="9">Processor executes all 9 I-type instructions (addi, slli, slti, sltiu, xori, srli, srai, ori, andi)</td>
    <td>ITYPE-01-A: instruction is addi</td>
    <td rowspan="9">Constrained Random</td>
    </tr>
    <tr>
    <td>ITYPE-01-B: instruction is slli</td>
    </tr>
    <tr>
    <td>ITYPE-01-C: instruction is slti</td>
    </tr>
    <tr>
    <td>ITYPE-01-D: instruction is sltiu</td>
    </tr>
    <tr>
    <td>ITYPE-01-E: instruction is xori</td>
    </tr>
    <tr>
    <td>ITYPE-01-F: instruction is srli</td>
    </tr>
    <tr>
    <td>ITYPE-01-G: instruction is srai</td>
    </tr>
    <tr>
    <td>ITYPE-01-H: instruction is ori</td>
    </tr>
    <tr>
    <td>ITYPE-01-I: instruction is andi</td>
    </tr>
    <tr>
    <td rowspan="5">ITYPE-02</td>
    <td rowspan="5">Instruction addi performs an addition of a value from register file rs1 and a signed immediate</td>
    <td>ITYPE-02-A: immediate is at max value (12'h7FF)</td>
    <td rowspan="5">Constrained Random</td>
    </tr>
    <tr>
    <td>ITYPE-02-B: immediate is positive (but less than max)</td>
    </tr>
    <tr>
    <td>ITYPE-02-C: immediate is zero</td>
    </tr>
    <tr>
    <td>ITYPE-02-D: immediate is negative (but more than min)</td>
    </tr>
    <tr>
    <td>ITYPE-02-E: immediate is at min value (12'h800)</td>
    </tr>
    <tr>
    <td rowspan="3">ITYPE-03</td>
    <td rowspan="3">Instructions slli, srli, and srai shift the value from register rs1 by an upper immediate (imm[4:0])</td>
    <td>ITYPE-03-A: upper immediate is 5'b11111</td>
    <td rowspan="3">Constrained Random</td>
    </tr>
    <tr>
    <td>ITYPE-03-B: upper immediate is 5'b00000</td>
    </tr>
    <tr>
    <td>ITYPE-03-C: upper immediate is some value in between</td>
    </tr>
    <tr>
    <td rowspan="5">ITYPE-04</td>
    <td rowspan="5">Instructions slti and sltiu compare the value in register rs1 to an immediate</td>
    <td>ITYPE-04-A: rs1 is larger than the immediate (both signed)</td>
    <td rowspan="5">Constrained Random</td>
    </tr>
    <tr>
    <td>ITYPE-04-B: rs1 is smaller than the immediate (both signed)</td>
    </tr>
    <tr>
    <td>ITYPE-04-C: rs1 is larger than the immediate (both unsigned)</td>
    </tr>
    <tr>
    <td>ITYPE-04-D: rs1 is smaller than the immediate (both unsigned)</td>
    </tr>
    <tr>
    <td>ITYPE-04-E: rs1 is equal to the immediate</td>
    </tr>
    <tr>
    <td rowspan="3">ITYPE-05</td>
    <td rowspan="3">Instructions xori, ori, andi perform bitwise logical operations between rs1 and an immediate</td>
    <td>ITYPE-05-A: immediate is 12'hFFF</td>
    <td rowspan="3">Constrained Random</td>
    </tr>
    <tr>
    <td>ITYPE-05-B: immediate is 12'h000</td>
    </tr>
    <tr>
    <td>ITYPE-05-C: immediate is some value between them</td>
    </tr>
    <tr>
    <td rowspan="2">ITYPE-06</td>
    <td rowspan="2">Processor should not write if register rd is x0 but should write normally otherwise.</td>
    <td>ITYPE-06-A: register rd is x0</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>ITYPE-06-B: register rd is x1-x31</td>
    </tr>
    <tr>
    <td rowspan="2">UTYPE-01</td>
    <td rowspan="2">Processor executes all 2 U-type instructions (auipc, lui)</td>
    <td>UTYPE-01-A: instruction is auipc</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>UTYPE-01-B: instruction is lui</td>
    </tr>
    <tr>
    <td rowspan="4">UTYPE-02</td>
    <td rowspan="4">Instruction auipc adds an upper immediate (imm[31:12]) to the current program counter</td>
    <td>UTYPE-02-A: immediate is 20'hFFFFF</td>
    <td rowspan="4">Constrained Random</td>
    </tr>
    <tr>
    <td>UTYPE-02-B: immediate MSB (bit 19) is 1</td>
    </tr>
    <tr>
    <td>UTYPE-02-C: immediate MSB (bit 19) is 0</td>
    </tr>
    <tr>
    <td>UTYPE-02-D: immediate is 20'h7FFFF</td>
    </tr>
    <tr>
    <td rowspan="5">UTYPE-03</td>
    <td rowspan="5">Instruction lui loads an upper immediate (imm[31:12]) to register rd</td>
    <td>UTYPE-03-A: immediate is 20'hFFFFF</td>
    <td rowspan="5">Constrained Random</td>
    </tr>
    <tr>
    <td>UTYPE-03-B: immediate MSB (bit 19) is 1</td>
    </tr>
    <tr>
    <td>UTYPE-03-C: immediate MSB (bit 19) is 0</td>
    </tr>
    <tr>
    <td>UTYPE-03-D: immediate is 20'h7FFFF</td>
    </tr>
    <tr>
    <td>UTYPE-03-E: immediate is 20'h00000</td>
    </tr>
    <tr>
    <td rowspan="2">UTYPE-04</td>
    <td rowspan="2">Processor should not write if register rd is x0 but should write normally otherwise</td>
    <td>UTYPE-04-A: register rd is x0</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>UTYPE-04-B: register rd is x1-x31</td>
    </tr>
    <tr>
    <td rowspan="10">RTYPE-01</td>
    <td rowspan="10">Processor executes all 10 R-type instructions (add, sub, sll, slt, sltu, xor, srl, sra, or, and)</td>
    <td>RTYPE-01-A: instruction is add</td>
    <td rowspan="10">Constrained Random</td>
    </tr>
    <tr>
    <td>RTYPE-01-B: instruction is sub</td>
    </tr>
    <tr>
    <td>RTYPE-01-C: instruction is sll</td>
    </tr>
    <tr>
    <td>RTYPE-01-D: instruction is slt</td>
    </tr>
    <tr>
    <td>RTYPE-01-E: instruction is sltu</td>
    </tr>
    <tr>
    <td>RTYPE-01-F: instruction is xor</td>
    </tr>
    <tr>
    <td>RTYPE-01-G: instruction is srl</td>
    </tr>
    <tr>
    <td>RTYPE-01-H: instruction is sra</td>
    </tr>
    <tr>
    <td>RTYPE-01-I: instruction is or</td>
    </tr>
    <tr>
    <td>RTYPE-01-J: instruction is and</td>
    </tr>
    <tr>
    <td rowspan="5">RTYPE-02</td>
    <td rowspan="5">Instruction add/sub add/subtract values from registers rs1 and rs2 and save to rd</td>
    <td>RTYPE-02-A: rs1 is positive/zero/negative</td>
    <td rowspan="3">Constrained Random</td>
    </tr>
    <tr>
    <td>RTYPE-02-B: rs2 is positive/zero/negative</td>
    </tr>
    <tr>
    <td>RTYPE-02-C: rs1_sign cross rs2_sign</td>
    </tr>
    <tr>
    <td>RTYPE-02-D: result overflows</td>
    <td rowspan="2">Directed Testing</td>
    </tr>
    <tr>
    <td>RTYPE-02-E: result underflows</td>
    </tr>
    <tr>
    <td rowspan="3">RTYPE-03</td>
    <td rowspan="3">Instructions sll, srl, and sra shift the value from register rs1 by rs2[4:0]</td>
    <td>RTYPE-03-A: rs2 is 5'b11111</td>
    <td rowspan="3">Constrained Random</td>
    </tr>
    <tr>
    <td>RTYPE-03-B: rs2 is 5'b00000</td>
    </tr>
    <tr>
    <td>RTYPE-03-C: rs2 is some value in between</td>
    </tr>
    <tr>
    <td rowspan="5">RTYPE-04</td>
    <td rowspan="5">Instructions slt and sltu compare the value in register rs1 to rs2</td>
    <td>RTYPE-04-A: rs1 is larger than rs2 (both signed)</td>
    <td rowspan="5">Constrained Random</td>
    </tr>
    <tr>
    <td>RTYPE-04-B: rs1 is smaller than rs2 (both signed)</td>
    </tr>
    <tr>
    <td>RTYPE-04-C: rs1 is larger than rs2 (both unsigned)</td>
    </tr>
    <tr>
    <td>RTYPE-04-D: rs1 is smaller than rs2 (both unsigned)</td>
    </tr>
    <tr>
    <td>RTYPE-04-E: rs1 is equal to rs2</td>
    </tr>
    <tr>
    <td rowspan="3">RTYPE-05</td>
    <td rowspan="3">Instructions xor, or, and perform bitwise logical operations between rs1 and rs2</td>
    <td>RTYPE-05-A: rs1 is 32'hFFFF_FFFF/32'h0000_0000/in between</td>
    <td rowspan="3">Constrained Random</td>
    </tr>
    <tr>
    <td>RTYPE-05-B: rs2 is 32'hFFFF_FFFF/32'h0000_0000/in between</td>
    </tr>
    <tr>
    <td>RTYPE-05-C: rs1_val cross rs2_val</td>
    </tr>
    <tr>
    <td rowspan="2">RTYPE-06</td>
    <td rowspan="2">Processor should not write if register rd is x0 but should write normally otherwise</td>
    <td>RTYPE-06-A: register rd is x0</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>RTYPE-06-B: register rd is x1-x31</td>
    </tr>
    <tr>
    <td rowspan="3">STYPE-01</td>
    <td rowspan="3">Processor executes all 3 save instructions (sb, sh, sw)</td>
    <td>STYPE-01-A: instruction is save byte</td>
    <td rowspan="3">Constrained Random</td>
    </tr>
    <tr>
    <td>STYPE-01-B: instruction is save half</td>
    </tr>
    <tr>
    <td>STYPE-01-C: instruction is save word</td>
    </tr>
    <tr>
    <td rowspan="3">STYPE-02</td>
    <td rowspan="3">Save instructions include a signed immediate that acts as an address offset</td>
    <td>STYPE-02-A: immediate is positive</td>
    <td rowspan="3">Constrained Random</td>
    </tr>
    <tr>
    <td>STYPE-02-B: immediate is negative</td>
    </tr>
    <tr>
    <td>STYPE-02-C: immediate is zero</td>
    </tr>
    <tr>
    <td rowspan="3">STYPE-03</td>
    <td rowspan="3">The address of data memory to write to is computed from the sum of rs1 and the sign-extended immediate</td>
    <td>STYPE-03-A: address is valid</td>
    <td rowspan="3">Constrained Random</td>
    </tr>
    <tr>
    <td>STYPE-03-B: address wraps below base (negative value)</td>
    </tr>
    <tr>
    <td>STYPE-03-C: address wraps above top (out of memory range)</td>
    </tr>
    <tr>
    <td rowspan="7">STYPE-04</td>
    <td rowspan="7">RV32I requires the address to be aligned when writing half or byte values</td>
    <td>STYPE-04-A: writing half with address bits[1:0] = 00</td>
    <td rowspan="7">Directed Testing</td>
    </tr>
    <tr>
    <td>STYPE-04-B: writing half with address bits[1:0] = 10</td>
    </tr>
    <tr>
    <td>STYPE-04-C: writing half with address bits[1:0] = 01/11 *</td>
    </tr>
    <tr>
    <td>STYPE-04-D: writing byte with address bits[1:0] = 00</td>
    </tr>
    <tr>
    <td>STYPE-04-E: writing byte with address bits[1:0] = 01</td>
    </tr>
    <tr>
    <td>STYPE-04-F: writing byte with address bits[1:0] = 10</td>
    </tr>
    <tr>
    <td>STYPE-04-G: writing byte with address bits[1:0] = 11</td>
    </tr>
    <tr>
    <td rowspan="6">BTYPE-01</td>
    <td rowspan="6">Processor executes all 6 branch instructions (beq, bne, blt, bge, bltu, bgeu)</td>
    <td>BTYPE-01-A: instruction is beq</td>
    <td rowspan="6">Constrained Random</td>
    </tr>
    <tr>
    <td>BTYPE-01-B: instruction is bne</td>
    </tr>
    <tr>
    <td>BTYPE-01-C: instruction is blt</td>
    </tr>
    <tr>
    <td>BTYPE-01-D: instruction is bge</td>
    </tr>
    <tr>
    <td>BTYPE-01-E: instruction is bltu</td>
    </tr>
    <tr>
    <td>BTYPE-01-F: instruction is bgeu</td>
    </tr>
    <tr>
    <td rowspan="5">BTYPE-02</td>
    <td rowspan="5">All branch instructions compare the value in rs1 to the value in rs2</td>
    <td>BTYPE-02-A: rs1 is larger than rs2 (both signed)</td>
    <td rowspan="5">Constrained Random</td>
    </tr>
    <tr>
    <td>BTYPE-02-B: rs1 is smaller than rs2 (both signed)</td>
    </tr>
    <tr>
    <td>BTYPE-02-C: rs1 is larger than rs2 (both unsigned)</td>
    </tr>
    <tr>
    <td>BTYPE-02-D: rs1 is smaller than rs2 (both unsigned)</td>
    </tr>
    <tr>
    <td>BTYPE-02-E: rs1 is equal to rs2</td>
    </tr>
    <tr>
    <td rowspan="6">BTYPE-03</td>
    <td rowspan="6">All branch instructions jump to a target PC, which is the current PC plus signed extended immediate</td>
    <td>BTYPE-03-A: PC jumps backward</td>
    <td rowspan="3">Constrained Random</td>
    </tr>
    <tr>
    <td>BTYPE-03-B: PC jumps forward</td>
    </tr>
    <tr>
    <td>BTYPE-03-C: Branch condition false, PC does not jump</td>
    </tr>
    <tr>
    <td>BTYPE-03-D: Branch condition true, PC jumps to itself (invalid)</td>
    <td rowspan="3">Directed Testing</td>
    </tr>
    <tr>
    <td>BTYPE-03-E: PC jumps to negative (invalid)</td>
    </tr>
    <tr>
    <td>BTYPE-03-F: PC jumps to out of program range (invalid)</td>
    </tr>
    <tr>
    <td rowspan="2">BTYPE-04</td>
    <td rowspan="2">PC should be a multiple of 4 to be aligned</td>
    <td>BTYPE-04-A: PC is aligned (PC[1:0] = 2'b00)</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>BTYPE-04-B: PC is not aligned</td>
    </tr>
    <tr>
    <td rowspan="6">JALR-01</td>
    <td rowspan="6">Instruction jalr jump to a target PC, which is the sum of rs1 and a sign-extended immediate</td>
    <td>JALR-01-A: PC jumps backward</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>JALR-01-B: PC jumps forward</td>
    </tr>
    <tr>
    <td>JALR-01-C: PC jumps to precisely the next address (PC+4)</td>
    <td rowspan="4">Directed Testing</td>
    </tr>
    <tr>
    <td>JALR-01-D: PC jumps to itself (invalid)</td>
    </tr>
    <tr>
    <td>JALR-01-E: PC jumps to negative (invalid)</td>
    </tr>
    <tr>
    <td>JALR-01-F: PC jumps to out of program range (invalid)</td>
    </tr>
    <tr>
    <td rowspan="2">JALR-02</td>
    <td rowspan="2">Processor should not write if register rd is x0 but should write normally otherwise.</td>
    <td>JALR-02-A: register rd is x0</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>JALR-02-B: register rd is x1-x31</td>
    </tr>
    <tr>
    <td rowspan="2">JALR-03</td>
    <td rowspan="2">PC should be a multiple of 4 to be aligned</td>
    <td>JALR-03-A: PC is aligned (PC[1:0] = 2'b00)</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>JALR-03-B: PC is not aligned</td>
    </tr>
    <tr>
    <td rowspan="6">JTYPE-01</td>
    <td rowspan="6">Instruction jal jump to a target PC, which is the sum of the current PC and a sign-extended immediate</td>
    <td>JTYPE-01-A: PC jumps backward</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>JTYPE-01-B: PC jumps forward</td>
    </tr>
    <tr>
    <td>JTYPE-01-C: PC jumps to precisely the next address (PC+4)</td>
    <td rowspan="4">Directed Testing</td>
    </tr>
    <tr>
    <td>JTYPE-01-D: PC jumps to itself (invalid)</td>
    </tr>
    <tr>
    <td>JTYPE-01-E: PC jumps to negative (invalid)</td>
    </tr>
    <tr>
    <td>JTYPE-01-F: PC jumps to out of program range (invalid)</td>
    </tr>
    <tr>
    <td rowspan="2">JTYPE-02</td>
    <td rowspan="2">Processor should not write if register rd is x0 but should write normally otherwise</td>
    <td>JTYPE-02-A: register rd is x0</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>JTYPE-02-B: register rd is x1-x31</td>
    </tr>
    <tr>
    <td rowspan="2">JTYPE-03</td>
    <td rowspan="2">PC should be a multiple of 4 to be aligned</td>
    <td>JTYPE-03-A: PC is aligned (PC[1:0] = 2'b00)</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>JTYPE-03-B: PC is not aligned</td>
    </tr>
    <tr>
    <td rowspan="7">HAZARD-01</td>
    <td rowspan="7">A read-after-write (RAW) hazard would occur if the next instruction reads the register that the previous instruction wrote to. Processor should handle RAW hazard via forwarding</td>
    <td>HAZARD-01-A: rs1 in EX matches Rd in MEM/WB</td>
    <td rowspan="7">Constrained Random</td>
    </tr>
    <tr>
    <td>HAZARD-01-B: rs2 in EX matches Rd in MEM/WB</td>
    </tr>
    <tr>
    <td>HAZARD-01-C: rs1 is x0/x1-x31</td>
    </tr>
    <tr>
    <td>HAZARD-01-D: rs2 is x0/x1-x31</td>
    </tr>
    <tr>
    <td>HAZARD-01-E: rs1_stage cross rs2_stage, rs1_isx0, rs2_isx0</td>
    </tr>
    <tr>
    <td>HAZARD-01-F: Rd in MEM/WB is x0, rs1 in EX is also x0</td>
    </tr>
    <tr>
    <td>HAZARD-01-G: Rd in MEM/WB is x0, rs2 in EX is also x0</td>
    </tr>
    <tr>
    <td rowspan="2">HAZARD-02</td>
    <td rowspan="2">For a load instruction, which requires two clock cycles to settle, processor should stall &amp; flush</td>
    <td>HAZARD-02-A: rs1 in ID is x0/x1-x31 and matches Rd in EX</td>
    <td rowspan="2">Directed Testing</td>
    </tr>
    <tr>
    <td>HAZARD-02-B: rs2 in ID is x0/x1-x31 and matches Rd in EX</td>
    </tr>
    <tr>
    <td rowspan="2">HAZARD-03</td>
    <td rowspan="2">For jump and branch, processor needs to assume path not taken and flush if taken</td>
    <td>HAZARD-03-A: instruction is jal/jalr</td>
    <td rowspan="2">Constrained Random</td>
    </tr>
    <tr>
    <td>HAZARD-03-B: instruction is branch</td>
    </tr>
    <tr>
    <td rowspan="9">HAZARD-04</td>
    <td rowspan="9">Processor needs to respond to consecutive hazards of various types correctly</td>
    <td>HAZARD-04-A: RAW followed by load stall</td>
    <td rowspan="9">Directed Testing</td>
    </tr>
    <tr>
    <td>HAZARD-04-B: load stall followed by RAW</td>
    </tr>
    <tr>
    <td>HAZARD-04-C: RAW followed by jump/branch</td>
    </tr>
    <tr>
    <td>HAZARD-04-D: jump/branch followed by RAW</td>
    </tr>
    <tr>
    <td>HAZARD-04-E: load stall followed by jump/branch</td>
    </tr>
    <tr>
    <td>HAZARD-04-F: jump/branch followed by load stall</td>
    </tr>
    <tr>
    <td>HAZARD-04-G: consecutive RAWs</td>
    </tr>
    <tr>
    <td>HAZARD-04-H: consecutive load stalls (2nd load instruction's rs1 is the same register as rd of the 1st load instruction)</td>
    </tr>
    <tr>
    <td>HAZARD-04-I: consecutive jumps/branches</td>
    </tr>
    <tr>
    <td rowspan="2">OP-01</td>
    <td rowspan="2">Halt must only fire once on illegal opcode</td>
    <td>OP-01-A: op code is legal</td>
    <td rowspan="2">Directed Testing</td>
    </tr>
    <tr>
    <td>OP-01-B: op code is illegal and triggers halt</td>
    </tr>
    <tr>
    <td rowspan="6">RESET-01</td>
    <td rowspan="6">Processor needs to handle reset correctly in various circumstances</td>
    <td>RESET-01-A: reset during normal operation (no hazard)</td>
    <td rowspan="6">Directed Testing</td>
    </tr>
    <tr>
    <td>RESET-01-B: reset during RAW</td>
    </tr>
    <tr>
    <td>RESET-01-C: reset during load stall</td>
    </tr>
    <tr>
    <td>RESET-01-D: reset during jump/branch</td>
    </tr>
    <tr>
    <td>RESET-01-E: reset during illegal opcode</td>
    </tr>
    <tr>
    <td>RESET-01-F: processor fetches first instruction from PC_RESET</td>
    </tr>
    <tr>
    <td>X0-01</td>
    <td>x0 always reads as zero even when the previous instruction attempts to write to it</td>
    <td>X0-01-A: x0 reads zero for all cases</td>
    <td>Constrained Random</td>
    </tr>
    <tr>
    <td>PIPELINE-01</td>
    <td>Pipeline should implement NOP correctly if pipelined is not filled</td>
    <td>PIPELINE-01-A: first 4 cycles after reset deasserts</td>
    <td>Directed Testing</td>
    </tr>
</tbody>
</table>

> <p><em>* Misaligned memory access produce defined behavior (write gets blocked or read returns all zero data). No exception mechanism was implemented.</em></p>

For the Excel version of the feature coverage plan, please refer to [the attached Excel file](./Verification_Plan.xlsx).

## Regression Plan

The regression consists of 100 constrained-random tests each with a different seed. The criteria for closure is that (1) 100% functional coverage bins are hit, and (2) 100% scoreboard pass rate across all regression seeds. 
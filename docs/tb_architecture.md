# Testbench Architecture
<p align="center">
    <img src="../.github/tb_arch.svg" width="100%"><br>
    <sup>UVM Testbench Architecture.</sup>
</p>

## Agents

### Instruction Agent

The instruction agent drives programs into instruction memory, manages reset, and observes the instruction memory interface. It connects to the DUT via the instruction interface. Transactions are represented by `instr_seq_item`. 

- The **sequencer** delivers test program instructions from the various sequences to the driver. 
- The **driver** simulates an instruction memory that can store 64 instructions. It collects all instructions in the test program from the sequencer, resets the DUT, and loads the instructions into the DUT until `Halt` is asserted. 
- The **monitor** observes the interface signals and currently has no subscribers, but it can be extended for future use. 

### Data Memory Agent

The data memory agent handles write and read transactions from the DUT and observes the data memory interface. It connects to the DUT via the data memory interface. Transactions are represented by `data_mem_seq_item`. 

- The **sequencer** is functionally present but not used, as the data memory agent only reactively responds to the DUT's read and write operations.
- The **driver** simulates a data memory that can store 64 words. It reads out the data from its internal memory when `RE` is asserted and writes data into its internal memory when the corresponding byte-enable signals in `WE` are asserted.
- The **monitor** observes the interface signals and currently has no subscribers, but it can be extended for future use. 

### Debug Monitor

Rather than a full-fledged agent, a standalone debug monitor is used to observe the following debug status flags:

| Debug Flag | Signal Width | Description |
|------------|--------------|-------------|
| `Halt`     | 1 | Control unit asserts halt when it sees illegal op codes * |
| `Instr`    | 32 | The retiring instruction |
| `Valid`    | 1 | Asserted when the retiring instruction is valid |
| `PC`       | 32 | The program counter of the retiring instruction |
| `DebugRegFile` | 32 x 32 | Directly exposes 32 registers of the DUT's register file |

> *The testbench uses an all-zero illegal instruction, which triggers `Halt`, to signal the end of program. 

It connects to the DUT via the debug interface and broadcasts to the coverage collector, instruction set simulator (ISS), and scoreboard. Transactions are represented by `debug_seq_item`. 


## Environment

The environment instantiates the instruction agent, data memory agent, and debug monitor. It also encapsulates the coverage collector, ISS, and scoreboard. 

### Coverage Collector

The coverage collector specifies the functional coverage groups and bins listed in the [Verification Plan](./verification_plan.md#feature-coverage-plan). It receives the retired instruction, program counter, and debug register file from the debug monitor via `uvm_analysis_imp`.

### Instruction Set Simulator (ISS)

A SystemVerilog instruction set simulator (ISS) acts as a reference model and generates expected results of instructions execution. It receives the instruction from the debug monitor via `uvm_analysis_imp`, simulates the instruction, and sends the resulting register file values and program counter value to the scoreboard via `uvm_analysis_port`. To execute the load and branch/jump instructions, it keeps an internal copy of the data and instruction memories.

### Scoreboard

The scoreboard compares the DUT's output against the expected results to determine whether a test passes or fails. It receives the expected results from the ISS via `uvm_analysis_imp` and the DUT's actual outputs from the debug monitor via another `uvm_analysis_imp`.

## Interfaces

To connect to the DUT, three interfaces are used: the instruction interface, the data memory interface, and the debug interface. They wire directly to the DUT's ports. The UVM components access these interfaces through virtual interface handles passed via `uvm_config_db`. 

## Sequences and Tests

The following sequences are designed to generate test programs that cover the feature coverage plan:

| Sequence | Type | Program Length | Description |
|----------|------|----------------|-------------|
| `constrained_random_seq` | Constrained Random | 20-64 | Generates a random program that aims to broadly cover all instruction types |
| `addr_alignment_seq` | Directed Testing | 16 | Tests address alignment when loading or storing byte or half values (`LOAD-04`, `STYPE-04`) |
| `consecutive_hazards_seq` | Directed Testing | 20 | Tests back-to-back RAW, load stall, and jump/branch hazards (`HAZARD-04`) |
| `invalid_branch_seq` | Directed Testing | 3 | Tests branch instructions with invalid PC targets (`BTYPE-03`) |
| `invalid_jal_seq` | Directed Testing | 3 | Tests `JAL` instructions with invalid PC targets (`JTYPE-01`) |
| `invalid_jalr_seq` | Directed Testing | 3 | Tests `JALR` instructions with invalid PC targets (`JALR-01`) |

In the constrained random sequence, to avoid infinite loops as much as possible, we tuned the probability of generating forward branches and jumps to 80%, and backward branches and jumps to 20%. The minimum number of instructions in a program is set to 20, which yields a moderate chance of covering all instruction types. 

A test is generated for each sequence. A watchdog timer is implemented to terminate the simulation in case of an infinite loop. 
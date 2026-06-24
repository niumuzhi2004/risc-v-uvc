## Testbench Architecture
<p align="center">
    <img src="../.github/tb_arch.svg" width="100%"><br>
    <sup>UVM Testbench Architecture.</sup>
</p>

The testbench includes 2 agents—an instruction agent and a data memory agent—each consisting of a driver, monitor, and sequencer. The instruction agent drives programs into instruction memory, manages reset, and observes the instruction fetch interface. The data memory agent handles write and read transactions from the DUT and observes the data memory interface. In addition, a standalone monitor is used to observe the `DebugRegFile` port and the `Halt` signal. A virtual sequencer coordinates all agents by issuing transactions to the instruction sequencer and the data memory sequencer. 

An instruction set simulator (ISS) acts as a reference model and generate expected results of instructions execution. The scoreboard compares the DUT's output against the expected results from the ISS to determine pass/fail status. The coverage collector specifies the functional coverage groups and bins that represent the various instruction types and hazard scenarios. 

The instruction monitor is connected to the ISS to provide the executed instructions for the ISS to simulate. The data memory monitor is connected to both the scoreboard for verifying results and the ISS for providing values read from memory. The debug monitor also connects to the scoreboard. When the `Halt` signal is asserted, the scoreboard can compare the DUT's register file against the ISS's register file to determine if the test passed or failed. In addition, all three monitors are connected to the coverage collector to record functional coverage. Note that all these connections are achieved through the analysis port mechanism in UVM. 

To connect to the DUT, three interfaces are used: the instruction interface, the data memory interface, and the debug interface. They wire directly to the DUT's ports. The UVM components access these interfaces through virtual interface handles passed via `uvm_config_db`. 
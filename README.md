# MIPS-Processor-RTL

A verilog RTL implementaion for a minimal subset of MIPS processor.
The processor is pipelined with 5 stages:
- Fetch stage
- Decode stage
- Execute stage
- Memory stage 
- Write back stage

The processor solves hazard using both bypassing and stalls.

# How to run:
Change your directory and type make to compile and make [iverilog/modelsim] [test name from benchmarks].

DIR=./mips-benchmarks

iverilog:
	cp $(DIR)/$(TEST).x $(DIR)/sw.x
	iverilog mem.v fetch.v core_defines.v decoder.v reg_comp.v reg_file.v decode.v ALU.v execute.v mem_stage.v write_back.v core.v core_tb.v
	./a.out > log.txt
	gtkwave core_tb.vcd

modelsim:
	cp $(DIR)/$(TEST).x $(DIR)/sw.x
	vsim -do modelsim.tcl

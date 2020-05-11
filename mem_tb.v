`timescale 1ns / 1ps

//#################### Defines  ####################
`define all_tests

//#################### Module ####################
module mem_tb();
parameter data_width = 32;
parameter address_width = 32;
parameter mem_depth = (1048576>>2); // == 1MB in Bytes
parameter base_address = 32'h80020000;
parameter Tclk = 2;
//#################### Wires ####################
wire [data_width-1:0] data_out;

//#################### Regs ####################
reg clock;
reg [address_width-1:0] address;
reg [data_width-1:0] data_in;
reg read_write;
reg enable;

//#################### Variables ####################
integer i;
integer lines;
integer file;

//#################### Logic ####################
//-------------------- DUT instantiation --------------------
mem mem_inst (	.clock(clock), 
		.address(address), 
		.data_in(data_in), 
		.read_write(read_write), 
		.enable(enable), 
		.data_out(data_out) );

//-------------------- clock --------------------
always begin
#(Tclk/2) clock <= !clock;
end

//-------------------- initializations --------------------
initial begin
	$dumpfile("mem_tb.vcd");
	$dumpvars(0,mem_tb);
	clock <= 1;
	address <= 0;
	data_in <= 0;
	read_write <= 0;
	enable <= 0;
end

//-------------------- Test Stimulus --------------------
initial begin
 	
	file = $fopen("log.txt","w"); 
	#(1.01*Tclk)
	enable <= 1;
	read_write <= 1;
	
	$readmemh("./benchmarks/SumArray.x",mem_inst.mem);
	lines=56;	
	$fwrite(file,"\nSumArray.x\n");
	for(i=0; i<lines; i++) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;

`ifdef all_tests
	$readmemh("./benchmarks/add.x",mem_inst.mem);
	lines=28;	
	$fwrite(file,"\nadd.x\n");
	for(i=0; i<lines; i++) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;

	$readmemh("./benchmarks/BubbleSort.x",mem_inst.mem);
	lines=116;	
	$fwrite(file,"\nBubbleSort.x\n");
	for(i=0; i<lines; i++) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;

	$readmemh("./benchmarks/CheckVowel.x",mem_inst.mem);
	lines=132;	
	$fwrite(file,"\nCheckVowel.x\n");
	for(i=0; i<lines; i++) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;

	$readmemh("./benchmarks/Combinations.x",mem_inst.mem);
	lines=76;	
	$fwrite(file,"\nCombinations.x\n");
	for(i=0; i<lines; i++) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;

	$readmemh("./benchmarks/fact.x",mem_inst.mem);
	lines=56;	
	$fwrite(file,"\nfact.x\n");
	for(i=0; i<lines; i++) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;

	$readmemh("./benchmarks/Fibonacci.x",mem_inst.mem);
	lines=52;	
	$fwrite(file,"\nFibonacci.x\n");
	for(i=0; i<lines; i++) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;

	$readmemh("./benchmarks/SimpleAdd.x",mem_inst.mem);
	lines=28;	
	$fwrite(file,"\nSimpleAdd.x\n");
	for(i=0; i<lines; i++) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;

	$readmemh("./benchmarks/SimpleIf.x",mem_inst.mem);
	lines=40;	
	$fwrite(file,"\nSimpleIf.x\n");
	for(i=0; i<lines; i++) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;


	$readmemh("./benchmarks/Swap.x",mem_inst.mem);
	lines=56;	
	$fwrite(file,"\nSwap.x\n");
	for(i=0; i<lines; i++) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;


	$readmemh("./benchmarks/SwapShift.x",mem_inst.mem);
	lines=64;	
	$fwrite(file,"\nSwapShift.x\n");
	for(i=0; i<lines; i++) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;
`endif

	$fclose(file); 
	$finish();
end

endmodule




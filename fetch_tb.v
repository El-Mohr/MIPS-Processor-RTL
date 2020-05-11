`timescale 1ns / 1ps

//#################### Defines  ####################

//#################### Module ####################
module fetch_tb();
parameter data_width = 32;
parameter address_width = 32;
parameter mem_depth = (1048576>>2); // == 1MB in Bytes
parameter base_address = 32'h80020000;
parameter Tclk = 2;
parameter Dclk = (1.00000000000001*Tclk);
//#################### Wires ####################
wire [data_width-1:0] instr;

//#################### Regs ####################
reg clock;
reg reset;

//#################### Variables ####################
integer i;
integer lines;
integer file;

//#################### Logic ####################
//-------------------- DUT instantiation --------------------
fetch #(	.data_width(data_width),
		.address_width(address_width),
		.mem_depth(mem_depth),
		.base_address(base_address)
) fetch_inst (	.clock(clock), 
		.reset(reset), 
		.instr(instr) );

//-------------------- clock --------------------
always begin
#(Tclk/2) clock <= !clock;
end

//-------------------- initializations --------------------
initial begin
	$dumpfile("fetch_tb.vcd");
	$dumpvars(0,fetch_tb);
	clock <= 1;
	reset <= 1;
	$readmemh("./benchmarks/SumArray.x",fetch_inst.mem_inst.mem);
	lines=56;	
	file = $fopen("log.txt","w"); 
end

//-------------------- Test Stimulus --------------------
initial begin
	#Dclk
	reset <= 0;
	for(i=0; i<lines; i++) begin
		$fwrite(file,"PC:\t%h\tContent:\t%h\n",fetch_inst.pc, instr);
		#Dclk;
	end
	$fwrite(file,"PC:\t%h\tContent:\t%h\n",fetch_inst.pc, instr);
	#Dclk;

	$fclose(file); 
	$finish();
end

endmodule




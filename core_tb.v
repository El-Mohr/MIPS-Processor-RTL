`timescale 1ns / 1ps

//#################### Defines  ####################

//#################### Module ####################
module core_tb();
parameter data_width = 32;
parameter address_width = 32;
parameter mem_depth = (1048576>>2); // == 1MB in Bytes
//parameter mem_depth = (1024>>2); // == 1MB in Bytes
parameter base_address = 32'h80020000;
//parameter base_address = 32'h00400000;
parameter reg_address_width = 5;
parameter SP =  base_address + (mem_depth<<2); // stack pointer
parameter Tclk = 2;
parameter Dclk = (1.001*Tclk);

//#################### Wires ####################

//#################### Regs ####################
reg clock;
reg reset;

//#################### Variables ####################
integer i;
integer lines;
integer file;

//#################### Logic ####################
//-------------------- DUT instantiation --------------------
core #(	.data_width(data_width),
		.mem_address_width(address_width),
		.mem_depth(mem_depth),
		.base_address(base_address),
		.reg_address_width(reg_address_width),
		.SP(SP)
) core_inst (	.clock(clock), 
		.reset(reset) );

//-------------------- clock --------------------
always begin
#(Tclk/2) clock <= !clock;
end

//-------------------- initializations --------------------
initial begin
	$dumpfile("core_tb.vcd");
	$dumpvars(0,core_tb);
	clock <= 1;
	reset <= 1;	
	file = $fopen("state.txt","w"); 
	$readmemh("./mips-benchmarks/sw.x",core_inst.fetch_inst.mem_inst.mem);
	$readmemh("./mips-benchmarks/sw.x",core_inst.mem_stage_inst.mem_inst.mem);
end

//-------------------- Test Stimulus --------------------
initial begin
	
	//Reset
	#Tclk;
	reset <= 0;

	//Log state before
	$fwrite(file,"Reg File Before\n");
	for(i=0; i<32; i=i+1) begin
		$fwrite(file,"Reg[%0d] = %0d\n",i,core_inst.decode_inst.reg_file_inst.mem[i]);
	end

	//Wait until SP is returned back at the end of program
	#(5*Tclk);
	while(core_inst.decode_inst.reg_file_inst.mem[29] != SP) begin
		#Tclk;
	end
	

	//Log state after
	$fwrite(file,"Reg File After\n");
	for(i=0; i<32; i=i+1) begin
		$fwrite(file,"Reg[%0d] = %0d\n",i,core_inst.decode_inst.reg_file_inst.mem[i]);
	end


	//Log mem after
	$fwrite(file,"Mem After\n");
	for(i=SP; i>SP-1024; i=i-4) begin
		$fwrite(file,"Mem[%h] = %0d\n",i,core_inst.mem_stage_inst.mem_inst.mem[(i-base_address)>>2]);
	end

	$writememh("./mem_dumb.txt",core_inst.mem_stage_inst.mem_inst.mem);
	$writememh("./reg_file_dumb.txt",core_inst.decode_inst.reg_file_inst.mem);

	$fclose(file); 
	$finish();
end


endmodule




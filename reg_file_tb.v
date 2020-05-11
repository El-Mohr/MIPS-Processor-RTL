`timescale 1ns / 1ps

//#################### Defines  ####################


//#################### Module ####################
module reg_file_tb();
parameter data_width = 32;
parameter address_width = 5;
parameter reg_depth = 2**address_width; //32
parameter Tclk = 2;
parameter Dclk = (1.001*Tclk);
//#################### Wires ####################
wire [data_width-1:0] data_s1val;
wire [data_width-1:0] data_s2val;

//#################### Regs ####################
reg clock;
reg reset;
reg write_enable;
reg [address_width-1:0] address_s1;
reg [address_width-1:0] address_s2;
reg [address_width-1:0] address_d;
reg [data_width-1:0] data_dval;
	
//#################### Variables ####################
integer i;
integer file;

//#################### Logic ####################
//-------------------- DUT instantiation --------------------
reg_file #(	.data_width(data_width),
		.address_width(address_width),
		.reg_depth(reg_depth)
) reg_file_inst (	.clock(clock), 
		.reset(reset),
		.write_enable(write_enable),
		.address_s1(address_s1),
		.address_s2(address_s2),
		.address_d(address_d),
		.data_dval(data_dval),
		.data_s1val(data_s1val),
		.data_s2val(data_s2val) 
);

//-------------------- clock --------------------
always begin
#(Tclk/2) clock <= !clock;
end

//-------------------- initializations --------------------
initial begin
	$dumpfile("reg_file_tb.vcd");
	$dumpvars(0,reg_file_tb);
	clock <= 1;
	reset <= 1;
	write_enable <= 0;
	address_s1 <= 0;
	address_s2 <= 0;
	address_d <= 0;
	data_dval <= 0;
	file = $fopen("log.txt","w"); 
end

//-------------------- Test Stimulus --------------------
initial begin
		
	#Dclk
	reset <= 0;
	for(i=1; i<32; i=i+1) begin
		reg_file_inst.mem[i] = i;
	end

	$fwrite(file,"Reading Intialized Data\n");
	
	for(i=0; i<32; i=i+2) begin
		address_s1 = i;
		address_s2 = i+1;
		$fwrite(file,"Reg[%0d] = %0d\nReg[%0d] = %0d\n",i,data_s1val,i+1,data_s2val);
		#Tclk;
	end

	#Tclk;

	$fwrite(file,"Reading Written Data At The Same Cycle\n");
	for(i=0; i<32; i=i+1) begin
		write_enable = 1;
		address_d = i;
		data_dval = i*2;
		address_s1 = i;
		$fwrite(file,"Reg[%0d] = %0d\n",i,data_s1val);
		#Tclk;
	end

	write_enable = 0;
	#Tclk;

	$fwrite(file,"Reading Written After 1 Cycle\n");
	for(i=0; i<32; i=i+1) begin
		write_enable = 1;
		address_d = i;
		data_dval = i*3;
		#Tclk;
		address_s1 = i;
		$fwrite(file,"Reg[%0d] = %0d\n",i,data_s1val);
	end

	#Tclk;

	$fclose(file); 
	$finish();
end

endmodule




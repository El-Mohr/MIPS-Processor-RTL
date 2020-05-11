`timescale 1ns / 1ps

//#################### Defines  ####################

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
reg [data_width/8-1:0] byte_we;

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
		.byte_we(byte_we), 
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
	byte_we <= 0;
end

//-------------------- Test Stimulus --------------------
initial begin
 	
	file = $fopen("log.txt","w"); 
	#(1.01*Tclk)
	enable <= 1;
	

	//Write all 0s
	read_write <= 0;
	byte_we <= 4'b1111;
	for(i=0; i<10; i=i+1) begin
		address <= base_address +i*4;
		data_in <= {{32{1'b0}}};
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end

	read_write <= 1;
	for(i=0; i<10; i=i+1) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	

	//Write all 1s but one byte only
	read_write <= 0;
	byte_we <= 4'b1000;
	for(i=0; i<10; i=i+1) begin
		address <= base_address +i*4;
		data_in <= {{32{1'b1}}};
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end

	read_write <= 1;
	for(i=0; i<10; i=i+1) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;


	//Write all 1s but two byte only
	read_write <= 0;
	byte_we <= 4'b0011;
	for(i=0; i<10; i=i+1) begin
		address <= base_address +i*4;
		data_in <= {{32{1'b1}}};
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end

	read_write <= 1;
	for(i=0; i<10; i=i+1) begin
		address <= base_address +i*4;
		#Tclk;
		$fwrite(file,"Address:\t%h\tContent:\t%h\n",address, data_out);
	end
	#Tclk;
	$fclose(file); 
	$finish();
end

endmodule




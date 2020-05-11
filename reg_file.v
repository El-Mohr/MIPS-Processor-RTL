`timescale 1ns / 1ps

//#################### Defines  ####################
//`define DEBUG

//#################### Module ####################
module reg_file #( 
	parameter data_width = 32,
	parameter address_width = 5,
	parameter reg_depth = 2**address_width, //32
	parameter SP = 0
)
(
	input clock,
	input write_enable,
	input [address_width-1:0] address_s1,
	input [address_width-1:0] address_s2,
	input [address_width-1:0] address_d,
	input [data_width-1:0] data_dval,
	output [data_width-1:0] data_s1val,
	output [data_width-1:0] data_s2val
);

//#################### Variables ####################
integer i;

//#################### Wires ####################

//#################### Regs ####################
reg [data_width-1:0] mem [reg_depth-1:0];

//#################### Logic ####################
//-------------------- Read Logic  --------------------
assign data_s1val = mem[address_s1];
assign data_s2val = mem[address_s2];

initial begin
	for(i=0; i<reg_depth; i=i+1) begin
			mem[i] <= 0;
	end
	mem[29] <= SP;
end

//-------------------- Write Logic --------------------
always@(posedge clock) begin
	mem[0] <= 0;
	if(write_enable==1 && address_d!=0) begin
		mem[address_d] <= data_dval;
	end
	`ifdef DEBUG
		$display("Register File Out A: %d\tRegister File Out B: ", data_s1val, data_s2val);
	`endif	
end

endmodule

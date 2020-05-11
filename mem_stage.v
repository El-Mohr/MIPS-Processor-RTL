`timescale 1ns / 1ps

//#################### Defines  ####################


//#################### Module ####################
module mem_stage #( 
	parameter data_width = 32,
	parameter address_width = 32,
	parameter mem_depth = (1048576>>2), // == 1MB in Bytes
	parameter base_address = 32'h80020000 
)
(
	input clock,
	input read_write,
	input enable,
	input load_sign,
	input [1:0] access_size,
	input [address_width-1:0] address,
	input [data_width-1:0] data_in,
	output reg [data_width-1:0] data_out_mod

);

//#################### Wires ####################
wire [data_width-1:0] data_out;
reg [data_width-1:0] data_in_mod;
reg [data_width/8-1:0] byte_we;
reg [4:0] shift_amount;
reg [15:0] data_out_shifted_16;
reg [7:0] data_out_shifted_8;

//#################### Regs ####################


//#################### Logic ####################

//-------------------- mem instantiation --------------------
mem #(		.data_width(data_width),
		.address_width(address_width),
		.mem_depth(mem_depth),
		.base_address(base_address)
) mem_inst (	.clock(clock), 
		.address(address), 
		.data_in(data_in_mod), 
		.read_write(read_write), 
		.enable(enable), 
		.byte_we(byte_we), 
		.data_out(data_out) );

//-------------------- modify data --------------------
always@(*) begin
	byte_we =  4'b1111;
	data_in_mod = data_in;
	data_out_mod = data_out;
	shift_amount = 0;
	data_out_shifted_16 = 0;
	data_out_shifted_8 = 0;
	case(access_size)
		1:begin
			byte_we =  4'b1100 >> address[1:0];
			shift_amount = (2-address[1:0]) << 3;
			data_in_mod = data_in << shift_amount; 
			data_out_shifted_16 = data_out >> shift_amount;
			if(load_sign == 1) begin
				data_out_mod = {{16{data_out_shifted_16[15]}},data_out_shifted_16};
			end
			else begin
				data_out_mod = {16'b0,data_out_shifted_16};
			end
		end
		2:begin
			byte_we =  4'b1000 >> address[1:0];
			shift_amount = (3-address[1:0]) << 3;
			data_in_mod = data_in << shift_amount;
			data_out_shifted_8 = data_out >> shift_amount;
			if(load_sign == 1) begin
				data_out_mod = {{24{data_out_shifted_8[7]}},data_out_shifted_8};
			end
			else begin
				data_out_mod = {24'b0,data_out_shifted_8};
			end
		end
	endcase

end
endmodule

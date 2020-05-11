`timescale 1ns / 1ps

//#################### Defines  ####################


//#################### Module ####################
module fetch #( 
	parameter data_width = 32,
	parameter address_width = 32,
	parameter mem_depth = (1048576>>2), // == 1MB in Bytes
	parameter base_address = 32'h80020000 
)
(
	input clock,
	input reset,
	input write_enable,
	input [address_width-1:0] br_target,
	input [address_width-1:0] j_target,
	input [address_width-1:0] reg_A,
	input br_taken,
	input [1:0] j_taken,
	output [data_width-1:0] instr,
	output [address_width-1:0] PC_plus4
);

//#################### Wires ####################
wire read_write;
wire enable;
wire [data_width/8-1:0] byte_we;

//#################### Regs ####################
reg [address_width-1:0] pc;

//#################### Logic ####################

//-------------------- mem instantiation --------------------
mem #(		.data_width(data_width),
		.address_width(address_width),
		.mem_depth(mem_depth),
		.base_address(base_address)
) mem_inst (	.clock(clock), 
		.address(pc), 
		.data_in(), 
		.read_write(read_write), 
		.enable(enable), 
		.byte_we(byte_we), 
		.data_out(instr) );

//-------------------- memory control --------------------
assign read_write = 1;
assign enable = 1;
assign byte_we = 4'b1111;

//-------------------- PC assignement --------------------
assign PC_plus4 = pc + 4;

always@(posedge clock) begin
	if(reset==1) begin
		pc <= base_address;
	end
	else begin
		if(write_enable == 1) begin
			if(br_taken == 1) begin
				pc <= br_target;
			end
			else case(j_taken)
				0:begin
					pc <= PC_plus4;
				end
				1:begin
					pc <= j_target;
				end
				2:begin
					pc <= reg_A;
				end
				default:begin

				end
			endcase
		end
	end
end

endmodule

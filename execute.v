`timescale 1ns / 1ps
//#################### Defines  ####################
//`define DEBUG

//#################### Includes  ####################
`include "core_defines.v"


//#################### Module ####################
module execute #( 
	parameter data_width = 32,
	parameter address_width = 32
)
(
	input [2:0] br_op,	// to be removed later
	input [4:0] sa,
	input [15:0] immediate,
	input [25:0] target,
	input [4:0] alu_opcode,
	input [1:0] alu_in_1_sel,
	input [1:0] alu_in_2_sel,
	input [data_width-1:0] reg_file_data_1,
	input [data_width-1:0] reg_file_data_2,
	input [data_width-1:0] PC_plus4,
	output [data_width-1:0] result,
	output [data_width-1:0] hi_result,
	output [address_width-1:0] br_target,
	output [address_width-1:0] j_target,
	output br_taken
);

//#################### Local Parameters ####################
localparam BEQ = 1, BNE = 2, BLTZ = 3, BGEZ = 4, BLEZ = 5, BGTZ = 6;

//#################### Wires ####################
wire [data_width-1:0] in_s1;
wire [data_width-1:0] in_s2;
wire zero;
wire [data_width-1:0] sign_ext_imm;

wire over_flow;	//to be used for reg_file write enable later

//#################### Logic ####################
//-------------------- sign extension --------------------
assign sign_ext_imm = {{16{immediate[15]}},immediate};

//-------------------- MUXs --------------------
assign in_s1 = alu_in_1_sel==0? reg_file_data_1 : alu_in_1_sel==1? {{27{1'b0}},sa} :{{27{1'b0}},5'd16};
assign in_s2 = alu_in_2_sel==0? reg_file_data_2 : alu_in_2_sel==1? sign_ext_imm : 0;

//-------------------- Branch Target --------------------
assign br_target = PC_plus4 + (sign_ext_imm<<2);

//-------------------- Jump Target --------------------
assign j_target = {PC_plus4[31:28], ({2'b0,target}<<2)};
//assign j_target = PC_plus4;

//-------------------- Branch Taken --------------------
assign br_taken = ((br_op==BEQ) && zero) || ((br_op==BNE) && !zero) || ((br_op==BLTZ) && in_s1[31]) || ((br_op==BGEZ) && !in_s1[31]) || ((br_op==BLEZ) && (zero || in_s1[31])) || ((br_op==BGTZ) && !(zero || in_s1[31])) ; 

//-------------------- ALU Instances --------------------
ALU #(	.data_width(data_width)
) ALU_inst (	
		.in_s1(in_s1),
		.in_s2(in_s2), 
		.alu_opcode(alu_opcode), 
		.result(result), 
		.hi(hi_result), 
		.over_flow(over_flow),
		.zero(zero) 
);

`ifdef DEBUG
	always@(PC_plus4) begin
		if(br_op==0) begin
			$display("ALU output: %d\tHi: %d", result, hi_result);
		end
		else begin
			$display("Control Operation!!\tTarget Address: %d\tTaken: %b", br_target, br_taken);
		end
	end
`endif

endmodule

`timescale 1ns / 1ps
//#################### Defines  ####################


//#################### Includes  ####################
`include "core_defines.v"

//#################### Module ####################
module decode #( 
	parameter data_width = 32,
	parameter address_width = 5,
	parameter SP = 0
)
(
	input clock,
	input reset,
	input [data_width-1:0] instr,
	input [data_width-1:0] wb_data,
	input [data_width-1:0] hi_result,
	input hi_we_r,
	input lo_we_r,
	input reg_file_we_r,
	input [address_width-1:0] address_d_r,
	output [2:0] br_op,
	output [4:0] sa,
	output [15:0] immediate,
	output [25:0] target,
	output [4:0] alu_opcode,
	output [1:0] alu_in_1_sel,
	output [1:0] alu_in_2_sel,
	output [data_width-1:0] hi_out,
	output [data_width-1:0] lo_out,
	output [data_width-1:0] reg_file_data_1,
	output [data_width-1:0] reg_file_data_2,
	output mem_read_write,
	output mem_enable,
	output load_sign,
	output [1:0] access_size,
	output [1:0] j_taken,
	output [2:0] reg_write_src,
	output hi_we,
	output lo_we,
	output reg_file_we,
	output [address_width-1:0] address_d,
	output [4:0] rs,
	output [4:0] rt,
	output instr_load,
	output instr_store,
	output instr_uses_rs,
	output instr_uses_rt,
	output instr_uses_hi,
	output instr_uses_lo
);

//#################### Wires ####################
//wire [data_width-1:0] data_dval;
//wire [4:0] rs;
//wire [4:0] rt;
wire [4:0] rd;
wire [1:0]reg_dest_sel;

//#################### Logic ####################
//-------------------- MUXs --------------------
assign address_d = reg_dest_sel==0? rd : reg_dest_sel==1? rt : 32'd31;
//assign data_dval = wb_data; //to be changed later

//-------------------- Hi and Lo Instances --------------------
reg_comp #(	.data_width(data_width)
) hi_reg (	.clock(clock), 
		.reset(reset),
		.write_enable(hi_we_r),
		.data_in(hi_result),
		.data_out(hi_out)
);

reg_comp #(	.data_width(data_width)
) lo_reg (	.clock(clock), 
		.reset(reset),
		.write_enable(lo_we_r),
		.data_in(wb_data),
		.data_out(lo_out)
);


//-------------------- Decoder Instance --------------------
decoder #(	.data_width(data_width)
) decoder_inst (	.instr(instr), 
		.br_op(br_op),
		.rs(rs),
		.rt(rt),
		.rd(rd),
		.sa(sa),
		.immediate(immediate),
		.target(target),
		.alu_opcode(alu_opcode),
		.alu_in_1_sel(alu_in_1_sel),
		.alu_in_2_sel(alu_in_2_sel),
		.reg_dest_sel(reg_dest_sel),
		.hi_we(hi_we), 
		.lo_we(lo_we), 
		.reg_file_we(reg_file_we),
		.mem_read_write(mem_read_write),
		.mem_enable(mem_enable),
		.load_sign(load_sign),
		.access_size(access_size),
		.j_taken(j_taken),
		.reg_write_src(reg_write_src),
		.instr_load(instr_load),
		.instr_store(instr_store),
		.instr_uses_rs(instr_uses_rs),
		.instr_uses_rt(instr_uses_rt),
		.instr_uses_hi(instr_uses_hi),
		.instr_uses_lo(instr_uses_lo)

);

//-------------------- Register File Instance --------------------
reg_file #(	.data_width(data_width),
		.address_width(address_width),
		.SP(SP)
) reg_file_inst (	.clock(clock), 
		.write_enable(reg_file_we_r),  //to be changed later
		.address_s1(rs),
		.address_s2(rt),
		.address_d(address_d_r),
		.data_dval(wb_data),
		.data_s1val(reg_file_data_1),
		.data_s2val(reg_file_data_2) 
);


endmodule

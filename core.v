`timescale 1ns / 1ps

//#################### Defines  ####################

//#################### Module ####################
module core #( 
	parameter data_width = 32,
	parameter mem_address_width = 32,
	parameter mem_depth = (1048576>>2), // == 1MB in Bytes
	parameter base_address = 32'h80020000,
	parameter reg_address_width = 5,
	parameter SP =  base_address + (mem_depth<<2) // stack pointer
)
(
	input clock,
	input reset
);

//#################### Wires ####################
wire [data_width-1:0] instr;
wire [data_width-1:0] wb_data;
wire [data_width-1:0] hi_result;
wire [2:0] br_op;	// to be removed later
wire [4:0] sa;
wire [15:0] immediate;
wire [25:0] target;
wire [4:0] alu_opcode;
wire [1:0] alu_in_1_sel;
wire [1:0] alu_in_2_sel;
wire [data_width-1:0] hi_out;
wire [data_width-1:0] lo_out;
wire [data_width-1:0] reg_file_data_1;
wire [data_width-1:0] reg_file_data_2;
wire [data_width-1:0] PC_plus4;	
wire [2:0] reg_write_src;
wire [data_width-1:0] mem_data;
wire [data_width-1:0] alu_data;
wire mem_read_write;
wire mem_enable;
wire load_sign;
wire [1:0] access_size;
wire [mem_address_width-1:0] br_target;
wire [mem_address_width-1:0] j_target;
wire br_taken;
wire [1:0] j_taken;
wire hi_we;
wire lo_we;
wire reg_file_we;
wire [reg_address_width-1:0] address_d;

//#################### pipes ####################
wire [data_width-1:0] instr_FD;
wire [data_width-1:0] PC_plus4_FD;	

wire [2:0] br_op_DX;
wire [4:0] sa_DX;
wire [15:0] immediate_DX;
wire [25:0] target_DX;
wire [4:0] alu_opcode_DX;
wire [1:0] alu_in_1_sel_DX;
wire [1:0] alu_in_2_sel_DX;
wire [data_width-1:0] hi_out_DX;
wire [data_width-1:0] lo_out_DX;
wire [data_width-1:0] reg_file_data_1_DX;
wire [data_width-1:0] reg_file_data_2_DX;
wire mem_read_write_DX;
wire mem_enable_DX;
wire load_sign_DX;
wire [1:0] access_size_DX;
wire [1:0] j_taken_DX;
wire [2:0] reg_write_src_DX;
wire [data_width-1:0] PC_plus4_DX;	
wire hi_we_DX;
wire lo_we_DX;
wire reg_file_we_DX;
wire [reg_address_width-1:0] address_d_DX;
wire [data_width-1:0] hi_out_final;
wire [data_width-1:0] lo_out_final;


wire [data_width-1:0] alu_data_XM;
wire [data_width-1:0] hi_result_XM;
wire [data_width-1:0] reg_file_data_2_XM;
wire [data_width-1:0] hi_out_final_XM;
wire [data_width-1:0] lo_out_final_XM;
wire mem_read_write_XM;
wire mem_enable_XM;
wire load_sign_XM;
wire [1:0] access_size_XM;
wire [2:0] reg_write_src_XM;
wire [data_width-1:0] PC_plus4_XM;	
wire hi_we_XM;
wire lo_we_XM;
wire reg_file_we_XM;
wire [reg_address_width-1:0] address_d_XM;

wire [data_width-1:0] mem_data_MW;
wire [data_width-1:0] alu_data_MW;
wire [data_width-1:0] hi_result_MW;
wire [data_width-1:0] hi_out_final_MW;
wire [data_width-1:0] lo_out_final_MW;
wire [2:0] reg_write_src_MW;
wire [data_width-1:0] PC_plus4_MW;
wire hi_we_MW;
wire lo_we_MW;
wire reg_file_we_MW;
wire [reg_address_width-1:0] address_d_MW;	

wire [4:0] rs;
wire [4:0] rt;
wire instr_load;
wire instr_store;
wire instr_uses_rs;
wire instr_uses_rt;
wire instr_uses_hi;
wire instr_uses_lo;

wire [4:0] rs_DX;
wire [4:0] rt_DX;
wire instr_uses_rs_DX;
wire instr_uses_rt_DX;
wire instr_load_DX;
wire instr_uses_hi_DX;
wire instr_uses_lo_DX;

wire [4:0] rs_XM;
wire [4:0] rt_XM;
wire instr_uses_rs_XM;
wire instr_uses_rt_XM;
wire instr_uses_hi_XM;
wire instr_uses_lo_XM;

wire instr_uses_hi_MW;
wire instr_uses_lo_MW;

wire [data_width-1:0] alu_operand_1;
wire [data_width-1:0] alu_operand_2;
wire [data_width-1:0] alu_operand_2_XM;
wire [data_width-1:0] mem_data_in;

//#################### Hazards Wires ####################
wire reset_FD;
wire reset_DX;
wire reset_XM;
wire reset_MW;

wire pipe_we_FD;
wire pipe_we_DX;
wire pipe_we_XM;
wire pipe_we_MW;

wire PC_we;

wire ctrl_flush;
wire load_use_stall;
wire raw_stall;
wire div_mul_stall;
wire raw_stall_X; //to be deleted
wire raw_stall_M; //to be deleted
wire div_mul_stall_X; //to be deleted
wire div_mul_stall_M; //to be deleted

wire wx_bypass_rs;
wire mx_bypass_rs;
wire wx_bypass_rt;
wire wm_bypass_rt;
wire mx_bypass_rt;

wire wx_bypass_hi;
wire mx_bypass_hi;
wire wx_bypass_lo;
wire mx_bypass_lo;

wire mf_hi_lo_stall;
wire mf_hi_lo_stall_X; //to be deleted
wire mf_hi_lo_stall_M; //to be deleted

wire wx_bypass_rs_hi; 
wire wx_bypass_rs_lo;
wire mx_bypass_rs_hi; 
wire mx_bypass_rs_lo;

wire wx_bypass_rt_hi; 
wire wx_bypass_rt_lo;
wire mx_bypass_rt_hi; 
wire mx_bypass_rt_lo;


//#################### Hazards ####################
//-------------------- Control Hazards --------------------
assign ctrl_flush = br_taken  | j_taken_DX[0] | j_taken_DX[1];

//-------------------- Data Hazards --------------------
//-------------------- Stalls --------------------
assign load_use_stall = (reg_file_we_DX == 1) && (instr_load_DX == 1) && (address_d_DX != 0) &&  ( ((instr_uses_rs == 1 ) && (rs == address_d_DX)) || ((instr_uses_rt == 1 ) && (instr_store == 0) && (rt == address_d_DX)) );

assign raw_stall = (reg_file_we_MW == 1) && (address_d_MW != 0) && ( ((instr_uses_rs == 1) && (rs == address_d_MW)) || ((instr_uses_rt == 1) && (rt == address_d_MW)) );

//assign raw_stall_M = (reg_file_we_XM == 1) && (address_d_XM != 0) && ( ((instr_uses_rs == 1) && (rs == address_d_XM)) || ((instr_uses_rt == 1) && (rt == address_d_XM)) );

//assign raw_stall_X = (reg_file_we_DX == 1) && (address_d_DX != 0) && ( ((instr_uses_rs == 1) && (rs == address_d_DX)) || ((instr_uses_rt == 1) && (rt == address_d_DX)) );

assign div_mul_stall = ((hi_we_MW == 1) && (instr_uses_hi == 1)) || ((lo_we_MW == 1) && (instr_uses_lo == 1));

//assign div_mul_stall_M = ((hi_we_XM == 1) && (instr_uses_hi == 1)) || ((lo_we_XM == 1) && (instr_uses_lo == 1));

//assign div_mul_stall_X = ((hi_we_DX == 1) && (instr_uses_hi == 1)) || ((lo_we_DX == 1) && (instr_uses_lo == 1));

assign mf_hi_lo_stall = (reg_file_we_MW == 1) && ((instr_uses_hi_MW | instr_uses_lo_MW) == 1) && (address_d_MW != 0) && ( ((instr_uses_rs == 1) && (rs == address_d_MW)) || ((instr_uses_rt == 1) && (rt == address_d_MW)) );

//assign mf_hi_lo_stall_M = (reg_file_we_XM == 1) && ((instr_uses_hi_XM | instr_uses_lo_XM) == 1) && (address_d_XM != 0) && ( ((instr_uses_rs == 1) && (rs == address_d_XM)) || ((instr_uses_rt == 1) && (rt == address_d_XM)) );

//assign mf_hi_lo_stall_X = (reg_file_we_DX == 1) && ((instr_uses_hi_DX | instr_uses_lo_DX) == 1) && (address_d_DX != 0) && ( ((instr_uses_rs == 1) && (rs == address_d_DX)) || ((instr_uses_rt == 1) && (rt == address_d_DX)) );


assign reset_FD = reset | ctrl_flush;
assign reset_DX = reset | ctrl_flush | load_use_stall | raw_stall | div_mul_stall | mf_hi_lo_stall;
assign reset_XM = reset;
assign reset_MW = reset;

assign PC_we = !(load_use_stall | raw_stall | div_mul_stall | mf_hi_lo_stall);
assign pipe_we_FD = !(load_use_stall | raw_stall | div_mul_stall | mf_hi_lo_stall);
assign pipe_we_DX = 1;
assign pipe_we_XM = 1;
assign pipe_we_MW = 1;


//-------------------- Bypasses --------------------
assign wx_bypass_rs = (reg_file_we_MW == 1) && (address_d_MW != 0) && ((instr_uses_rs_DX == 1) && (rs_DX == address_d_MW));
assign wx_bypass_rt = (reg_file_we_MW == 1) && (address_d_MW != 0) && ((instr_uses_rt_DX == 1) && (rt_DX == address_d_MW));

assign wm_bypass_rt = (reg_file_we_MW == 1) && (address_d_MW != 0) && ((instr_uses_rt_XM == 1) && (rt_XM == address_d_MW));

assign mx_bypass_rs = (reg_file_we_XM == 1) && (address_d_XM != 0) && ((instr_uses_rs_DX == 1) && (rs_DX == address_d_XM));
assign mx_bypass_rt = (reg_file_we_XM == 1) && (address_d_XM != 0) && ((instr_uses_rt_DX == 1) && (rt_DX == address_d_XM));

assign wx_bypass_hi = (hi_we_MW == 1) && (instr_uses_hi_DX == 1);
assign wx_bypass_lo = (lo_we_MW == 1) && (instr_uses_lo_DX == 1);

assign mx_bypass_hi = (hi_we_XM == 1) && (instr_uses_hi_DX == 1);
assign mx_bypass_lo = (lo_we_XM == 1) && (instr_uses_lo_DX == 1);

assign wx_bypass_rs_hi = (instr_uses_hi_MW == 1) && (address_d_MW != 0) && ((instr_uses_rs_DX == 1) && (rs_DX == address_d_MW));
assign wx_bypass_rs_lo = (instr_uses_lo_MW == 1) && (address_d_MW != 0) && ((instr_uses_rs_DX == 1) && (rs_DX == address_d_MW));

assign mx_bypass_rs_hi = (instr_uses_hi_XM == 1) && (address_d_XM != 0) && ((instr_uses_rs_DX == 1) && (rs_DX == address_d_XM));
assign mx_bypass_rs_lo = (instr_uses_lo_XM == 1) && (address_d_XM != 0) && ((instr_uses_rs_DX == 1) && (rs_DX == address_d_XM));

assign wx_bypass_rt_hi = (instr_uses_hi_MW == 1) && (address_d_MW != 0) && ((instr_uses_rt_DX == 1) && (rt_DX == address_d_MW));
assign wx_bypass_rt_lo = (instr_uses_lo_MW == 1) && (address_d_MW != 0) && ((instr_uses_rt_DX == 1) && (rt_DX == address_d_MW));

assign mx_bypass_rt_hi = (instr_uses_hi_XM == 1) && (address_d_XM != 0) && ((instr_uses_rt_DX == 1) && (rt_DX == address_d_XM));
assign mx_bypass_rt_lo = (instr_uses_lo_XM == 1) && (address_d_XM != 0) && ((instr_uses_rt_DX == 1) && (rt_DX == address_d_XM));


assign alu_operand_1 = mx_bypass_rs_hi ==1? hi_out_final_XM : mx_bypass_rs_lo ==1? lo_out_final_XM : mx_bypass_rs == 1? alu_data_XM : wx_bypass_rs_hi ==1? hi_out_final_MW : wx_bypass_rs_lo ==1? lo_out_final_MW : wx_bypass_rs == 1? wb_data : reg_file_data_1_DX;

assign alu_operand_2 = mx_bypass_rt_hi ==1? hi_out_final_XM : mx_bypass_rt_lo ==1? lo_out_final_XM : mx_bypass_rt == 1? alu_data_XM : wx_bypass_rt_hi ==1? hi_out_final_MW : wx_bypass_rt_lo ==1? lo_out_final_MW : wx_bypass_rt == 1? wb_data : reg_file_data_2_DX;

assign mem_data_in = wm_bypass_rt == 1? wb_data : alu_operand_2_XM;

assign lo_out_final = mx_bypass_lo == 1? alu_data_XM : wx_bypass_lo == 1? wb_data : lo_out_DX;
assign hi_out_final = mx_bypass_hi == 1? hi_result_XM : wx_bypass_hi == 1? hi_result_MW : hi_out_DX;


//#################### Stages Instantiations ####################
//-------------------- Fetch Instantiation --------------------
fetch #(	.data_width(data_width),
		.address_width(mem_address_width),
		.mem_depth(mem_depth),
		.base_address(base_address)
) fetch_inst (	.clock(clock), 
		.reset(reset), 
		.write_enable(PC_we), 
		.reg_A(alu_operand_1), 
		.j_target(j_target), 
		.br_target(br_target),
		.j_taken(j_taken_DX), 
		.br_taken(br_taken), 
		.instr(instr),
		.PC_plus4(PC_plus4)
 );

//-------------------- Decode Instantiation --------------------
decode #(	.data_width(data_width),
			.address_width(reg_address_width),
			.SP(SP)
) decode_inst (	.clock(clock),
				.reset(reset),
				.instr(instr_FD),
				.wb_data(wb_data),
				.hi_result(hi_result_MW),
				.hi_we(hi_we),
				.lo_we(lo_we),
				.reg_file_we(reg_file_we),
				.address_d(address_d),
				.br_op(br_op),
				.sa(sa),
				.immediate(immediate),
				.target(target),
				.alu_opcode(alu_opcode),
				.alu_in_1_sel(alu_in_1_sel),
				.alu_in_2_sel(alu_in_2_sel),
				.hi_out(hi_out),
				.lo_out(lo_out),
				.reg_file_data_1(reg_file_data_1),
				.reg_file_data_2(reg_file_data_2),
				.mem_read_write(mem_read_write),
				.mem_enable(mem_enable),
				.load_sign(load_sign),
				.access_size(access_size),
				.reg_write_src(reg_write_src),
				.j_taken(j_taken),
				.hi_we_r(hi_we_MW),
				.lo_we_r(lo_we_MW),
				.reg_file_we_r(reg_file_we_MW),
				.address_d_r(address_d_MW),
				.rs(rs),
				.rt(rt),
				.instr_load(instr_load),
				.instr_store(instr_store),
				.instr_uses_rs(instr_uses_rs),
				.instr_uses_rt(instr_uses_rt),
				.instr_uses_hi(instr_uses_hi),
				.instr_uses_lo(instr_uses_lo)

 );

//-------------------- Execute Instantiation --------------------
execute #(	.data_width(data_width),
		.address_width(mem_address_width)
) execute_inst (.br_op(br_op_DX),
				.sa(sa_DX),
				.immediate(immediate_DX),
				.target(target_DX),
				.alu_opcode(alu_opcode_DX),
				.alu_in_1_sel(alu_in_1_sel_DX),
				.alu_in_2_sel(alu_in_2_sel_DX),
				.reg_file_data_1(alu_operand_1),
				.reg_file_data_2(alu_operand_2),
				.PC_plus4(PC_plus4_DX),
				.result(alu_data),
				.hi_result(hi_result),
				.br_taken(br_taken),
				.j_target(j_target),
				.br_target(br_target)
 );

//-------------------- Memory Stage Instantiation --------------------
mem_stage #(	.data_width(data_width),
		.address_width(mem_address_width),
		.mem_depth(mem_depth),
		.base_address(base_address)
) mem_stage_inst (	.clock(clock), 
		.read_write(mem_read_write_XM),
		.enable(mem_enable_XM),
		.load_sign(load_sign_XM),
		.access_size(access_size_XM),
		.address(alu_data_XM),
		.data_in(mem_data_in),
		.data_out_mod(mem_data)
 );

//-------------------- Write Back Instantiation --------------------
write_back #(	.data_width(data_width)
) write_back_inst (	.reg_write_src(reg_write_src_MW), 
		.mem_data(mem_data_MW), 
		.alu_data(alu_data_MW),
		.hi_reg(hi_out_final_MW),
		.lo_reg(lo_out_final_MW),
		.PC_plus4(PC_plus4_MW),
		.wb_data(wb_data)
 );


//-------------------- FD Pipe --------------------
reg_comp #(	.data_width(data_width)
) instr_FD_reg (	.clock(clock), 
		.reset(reset_FD),
		.write_enable(pipe_we_FD),
		.data_in(instr),
		.data_out(instr_FD)
);

reg_comp #(	.data_width(data_width)
) PC_plus4_FD_reg (	.clock(clock), 
		.reset(reset_FD),
		.write_enable(pipe_we_FD),
		.data_in(PC_plus4),
		.data_out(PC_plus4_FD)
);


//-------------------- DX Pipe --------------------
reg_comp #(	.data_width(3)
) br_op_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(br_op),
		.data_out(br_op_DX)
);

reg_comp #(	.data_width(5)
) sa_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(sa),
		.data_out(sa_DX)
);

reg_comp #(	.data_width(16)
) immediate_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(immediate),
		.data_out(immediate_DX)
);

reg_comp #(	.data_width(26)
) target_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(target),
		.data_out(target_DX)
);

reg_comp #(	.data_width(5)
) alu_opcode_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(alu_opcode),
		.data_out(alu_opcode_DX)
);

reg_comp #(	.data_width(2)
) alu_in_1_sel_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(alu_in_1_sel),
		.data_out(alu_in_1_sel_DX)
);

reg_comp #(	.data_width(2)
) alu_in_2_sel_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(alu_in_2_sel),
		.data_out(alu_in_2_sel_DX)
);

reg_comp #(	.data_width(data_width)
) hi_out_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(hi_out),
		.data_out(hi_out_DX)
);

reg_comp #(	.data_width(data_width)
) lo_out_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(lo_out),
		.data_out(lo_out_DX)
);

reg_comp #(	.data_width(data_width)
) reg_file_data_1_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(reg_file_data_1),
		.data_out(reg_file_data_1_DX)
);

reg_comp #(	.data_width(data_width)
) reg_file_data_2_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(reg_file_data_2),
		.data_out(reg_file_data_2_DX)
);

reg_comp #(	.data_width(1)
) mem_read_write_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(mem_read_write),
		.data_out(mem_read_write_DX)
);

reg_comp #(	.data_width(1)
) mem_enable_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(mem_enable),
		.data_out(mem_enable_DX)
);

reg_comp #(	.data_width(1)
) load_sign_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(load_sign),
		.data_out(load_sign_DX)
);

reg_comp #(	.data_width(2)
) access_size_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(access_size),
		.data_out(access_size_DX)
);

reg_comp #(	.data_width(2)
) j_taken_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(j_taken),
		.data_out(j_taken_DX)
);

reg_comp #(	.data_width(3)
) reg_write_src_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(reg_write_src),
		.data_out(reg_write_src_DX)
);

reg_comp #(	.data_width(data_width)
) PC_plus4_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(PC_plus4_FD),
		.data_out(PC_plus4_DX)
);

reg_comp #(	.data_width(1)
) hi_we_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(hi_we),
		.data_out(hi_we_DX)
);

reg_comp #(	.data_width(1)
) lo_we_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(lo_we),
		.data_out(lo_we_DX)
);

reg_comp #(	.data_width(1)
) reg_file_we_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(reg_file_we),
		.data_out(reg_file_we_DX)
);

reg_comp #(	.data_width(reg_address_width)
) address_d_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(address_d),
		.data_out(address_d_DX)
);

reg_comp #(	.data_width(5)
) rs_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(rs),
		.data_out(rs_DX)
);

reg_comp #(	.data_width(5)
) rt_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(rt),
		.data_out(rt_DX)
);

reg_comp #(	.data_width(1)
) instr_uses_rs_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(instr_uses_rs),
		.data_out(instr_uses_rs_DX)
);

reg_comp #(	.data_width(1)
) instr_uses_rt_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(instr_uses_rt),
		.data_out(instr_uses_rt_DX)
);

reg_comp #(	.data_width(1)
) instr_load_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(instr_load),
		.data_out(instr_load_DX)
);

reg_comp #(	.data_width(1)
) instr_uses_hi_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(instr_uses_hi),
		.data_out(instr_uses_hi_DX)
);

reg_comp #(	.data_width(1)
) instr_uses_lo_DX_reg (	.clock(clock), 
		.reset(reset_DX),
		.write_enable(pipe_we_DX),
		.data_in(instr_uses_lo),
		.data_out(instr_uses_lo_DX)
);


//-------------------- XM Pipe --------------------
reg_comp #(	.data_width(data_width)
) alu_data_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(alu_data),
		.data_out(alu_data_XM)
);

reg_comp #(	.data_width(data_width)
) hi_result_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(hi_result),
		.data_out(hi_result_XM)
);

reg_comp #(	.data_width(data_width)
) reg_file_data_2_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(reg_file_data_2_DX),
		.data_out(reg_file_data_2_XM)
);

reg_comp #(	.data_width(data_width)
) lo_out_final_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(lo_out_final),
		.data_out(lo_out_final_XM)
);

reg_comp #(	.data_width(data_width)
) hi_out_final_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(hi_out_final),
		.data_out(hi_out_final_XM)
);

reg_comp #(	.data_width(1)
) mem_read_write_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(mem_read_write_DX),
		.data_out(mem_read_write_XM)
);

reg_comp #(	.data_width(1)
) mem_enable_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(mem_enable_DX),
		.data_out(mem_enable_XM)
);

reg_comp #(	.data_width(1)
) load_sign_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(load_sign_DX),
		.data_out(load_sign_XM)
);

reg_comp #(	.data_width(2)
) access_size_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(access_size_DX),
		.data_out(access_size_XM)
);

reg_comp #(	.data_width(3)
) reg_write_src_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(reg_write_src_DX),
		.data_out(reg_write_src_XM)
);

reg_comp #(	.data_width(data_width)
) PC_plus4_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(PC_plus4_DX),
		.data_out(PC_plus4_XM)
);

reg_comp #(	.data_width(1)
) hi_we_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(hi_we_DX),
		.data_out(hi_we_XM)
);

reg_comp #(	.data_width(1)
) lo_we_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(lo_we_DX),
		.data_out(lo_we_XM)
);

reg_comp #(	.data_width(1)
) reg_file_we_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(reg_file_we_DX),
		.data_out(reg_file_we_XM)
);

reg_comp #(	.data_width(reg_address_width)
) address_d_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(address_d_DX),
		.data_out(address_d_XM)
);

reg_comp #(	.data_width(5)
) rs_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(rs_DX),
		.data_out(rs_XM)
);

reg_comp #(	.data_width(5)
) rt_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(rt_DX),
		.data_out(rt_XM)
);

reg_comp #(	.data_width(1)
) instr_uses_rs_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(instr_uses_rs_DX),
		.data_out(instr_uses_rs_XM)
);

reg_comp #(	.data_width(1)
) instr_uses_rt_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(instr_uses_rt_DX),
		.data_out(instr_uses_rt_XM)
);

reg_comp #(	.data_width(1)
) instr_uses_hi_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(instr_uses_hi_DX),
		.data_out(instr_uses_hi_XM)
);

reg_comp #(	.data_width(1)
) instr_uses_lo_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(instr_uses_lo_DX),
		.data_out(instr_uses_lo_XM)
);

reg_comp #(	.data_width(data_width)
) alu_operand_2_XM_reg (	.clock(clock), 
		.reset(reset_XM),
		.write_enable(pipe_we_XM),
		.data_in(alu_operand_2),
		.data_out(alu_operand_2_XM)
);


//-------------------- MW Pipe --------------------
reg_comp #(	.data_width(data_width)
) mem_data_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(mem_data),
		.data_out(mem_data_MW)
);

reg_comp #(	.data_width(data_width)
) alu_data_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(alu_data_XM),
		.data_out(alu_data_MW)
);

reg_comp #(	.data_width(data_width)
) hi_result_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(hi_result_XM),
		.data_out(hi_result_MW)
);


reg_comp #(	.data_width(data_width)
) lo_out_final_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(lo_out_final_XM),
		.data_out(lo_out_final_MW)
);

reg_comp #(	.data_width(data_width)
) hi_out_final_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(hi_out_final_XM),
		.data_out(hi_out_final_MW)
);

reg_comp #(	.data_width(3)
) reg_write_src_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(reg_write_src_XM),
		.data_out(reg_write_src_MW)
);

reg_comp #(	.data_width(data_width)
) PC_plus4_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(PC_plus4_XM),
		.data_out(PC_plus4_MW)
);

reg_comp #(	.data_width(1)
) hi_we_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(hi_we_XM),
		.data_out(hi_we_MW)
);

reg_comp #(	.data_width(1)
) lo_we_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(lo_we_XM),
		.data_out(lo_we_MW)
);

reg_comp #(	.data_width(1)
) reg_file_we_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(reg_file_we_XM),
		.data_out(reg_file_we_MW)
);

reg_comp #(	.data_width(reg_address_width)
) address_d_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(address_d_XM),
		.data_out(address_d_MW)
);

reg_comp #(	.data_width(1)
) instr_uses_hi_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(instr_uses_hi_XM),
		.data_out(instr_uses_hi_MW)
);

reg_comp #(	.data_width(1)
) instr_uses_lo_MW_reg (	.clock(clock), 
		.reset(reset_MW),
		.write_enable(pipe_we_MW),
		.data_in(instr_uses_lo_XM),
		.data_out(instr_uses_lo_MW)
);

endmodule




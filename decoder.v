`timescale 1ns / 1ps
//#################### Defines  ####################
`define DEBUG

//#################### Includes  ####################
`include "core_defines.v"

//#################### Module ####################
module decoder #( 
	parameter data_width = 32
)
(
	input [data_width-1:0] instr,
	output reg [2:0] br_op,
	output reg [4:0] rs,
	output reg [4:0] rt,
	output reg [4:0] rd,
	output reg [4:0] sa,
	output reg [15:0] immediate,
	output reg [25:0] target,
	output reg [4:0] alu_opcode,
	output reg [1:0] alu_in_1_sel,
	output reg [1:0] alu_in_2_sel,
	output reg [1:0]reg_dest_sel,
	output reg hi_we,
	output reg lo_we,
	output reg reg_file_we,
	output reg mem_read_write,
	output reg mem_enable,
	output reg load_sign,
	output reg [1:0] access_size,
	output reg [1:0] j_taken,
	output reg [2:0] reg_write_src,
	output reg instr_load,
	output reg instr_store,
	output reg instr_uses_rs,
	output reg instr_uses_rt,
	output reg instr_uses_hi,
	output reg instr_uses_lo
);

//#################### Local Parameters ####################
localparam ADD = 0, ADD_OVER = 1, SUB = 2, SUB_OVER = 3,
	   AND = 4, OR = 5, XOR = 6, NOR = 7, 
	   SLL = 8, SRL = 9, SRA = 10,
	   MULT = 11,  MULTU = 12,  DIV = 13,  DIVU = 14,
	   SLT = 15, SLTU = 16;

localparam BEQ = 1, BNE = 2, BLTZ = 3, BGEZ = 4, BLEZ = 5, BGTZ = 6;

//#################### Wires ####################
reg [5:0] opcode;
reg [5:0] func;
reg [4:0] branch_func;
//reg [4:0] rs;
//reg [4:0] rt;
//reg [4:0] rd;
//reg [4:0] sa;
//reg [15:0] immediate;
//reg [25:0] target;

//#################### Regs ####################


//#################### Logic ####################
always@(instr) begin //clock is added just for debugging to be removed finally
//-------------------- Fields Assignements --------------------
	opcode = instr[31:26];
	rs = instr[25:21];
	rt = instr[20:16];
	branch_func = instr[20:16];
	rd = instr[15:11];
	sa = instr[10:6];
	func = instr[5:0];
	immediate = instr[15:0];
	target = instr[25:0];
//-------------------- Decoder Logic --------------------
	hi_we = 0; 
	lo_we = 0;
	reg_file_we = 0;
	reg_dest_sel = 0; //0 rd, 1 rt, 2 cons31
	alu_opcode = ADD;
	alu_in_1_sel = 0; //0 reg, 1 shift amount, 2 cons16
	alu_in_2_sel = 0; //0 reg, 1 immediate, 2 cons0
	br_op = 0; //None branch
	mem_read_write = 1; //0 write, 1 read
	mem_enable = 0;	
	load_sign = 1; //0 unsigned, 1 signed
	access_size = 0; //0 word, 1 half, 2 byte
	j_taken = 0; //0 not taken, 1 direct, 2 reg
	reg_write_src = 0; //0 alu out, 1 mem out, 2 hi, 3 lo, 4 pcPlus4
	instr_load = 0;
	instr_store = 0;
	instr_uses_rs = 1;
	instr_uses_rt = 1;
	instr_uses_hi = 0;
	instr_uses_lo = 0;

	case(opcode)
		`SPECIAL_OP:begin 
			case(func)
				`ADD_FUNC:begin
					alu_opcode = ADD_OVER;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: add r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs,rt);
					`endif
				end
				`ADDU_FUNC:begin
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: addu r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs,rt);
					`endif
				end

				`SUB_FUNC:begin
					alu_opcode = SUB_OVER;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: sub r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs,rt);
					`endif
				end
								
				`SUBU_FUNC:begin
					alu_opcode = SUB;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: subu r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs,rt);
					`endif
				end
								
				`MULT_FUNC:begin
					hi_we = 1;
					lo_we = 1;
					alu_opcode = MULT;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: mult r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rs,rt);
					`endif
				end

				`MULTU_FUNC:begin
					hi_we = 1;
					lo_we = 1;
					alu_opcode = MULTU;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: multu r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rs,rt);
					`endif
				end

				`DIV_FUNC:begin
					hi_we = 1;
					lo_we = 1;
					alu_opcode = DIV;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: div r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rs,rt);
					`endif
				end

				`DIVU_FUNC:begin
					hi_we = 1;
					lo_we = 1;
					alu_opcode = DIVU;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: divu r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rs,rt);
					`endif
				end	

				`MFHI_FUNC:begin
					reg_file_we = 1;
					reg_write_src = 2; //0 alu out, 1 mem out, 2 hi, 3 lo
					instr_uses_rs = 0;
					instr_uses_rt = 0;
					instr_uses_hi = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: mfhi r%0d", core_inst.PC_plus4_FD-4,instr,rd);
					`endif
				end

				`MFLO_FUNC:begin
					reg_file_we = 1;
					reg_write_src = 3; //0 alu out, 1 mem out, 2 hi, 3 lo
					instr_uses_rs = 0;
					instr_uses_rt = 0;
					instr_uses_lo = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: mflo r%0d", core_inst.PC_plus4_FD-4,instr,rd);
					`endif
				end					
		
				`SLT_FUNC:begin
					alu_opcode = SLT;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: slt r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs,rt);
					`endif
				end
				
				`SLTU_FUNC:begin
					alu_opcode = SLTU;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: sltu r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs,rt);
					`endif
				end
			
				`SLL_FUNC:begin
					alu_opcode = SLL;
					alu_in_1_sel = 1;
					reg_file_we = 1;
					instr_uses_rs = 0;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: sll r%0d, r%0d, %0d", core_inst.PC_plus4_FD-4,instr,rd,rt,sa);
					`endif
				end
								
				`SLLV_FUNC:begin
					alu_opcode = SLL;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: sllv r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rt,rs);
					`endif
				end

				`SRL_FUNC:begin
					alu_opcode = SRL;
					alu_in_1_sel = 1;
					reg_file_we = 1;
					instr_uses_rs = 0;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: srl r%0d, r%0d, %0d", core_inst.PC_plus4_FD-4,instr,rd,rt,sa);
					`endif
				end
								
				`SRLV_FUNC:begin
					alu_opcode = SRL;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: srlv r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rt,rs);
					`endif
				end

				`SRA_FUNC:begin
					alu_opcode = SRA;
					alu_in_1_sel = 1;
					reg_file_we = 1;
					instr_uses_rs = 0;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: sra r%0d, r%0d, %0d", core_inst.PC_plus4_FD-4,instr,rd,rt,sa);
					`endif
				end
								
				`SRAV_FUNC:begin
					alu_opcode = SRA;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: srav r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rt,rs);
					`endif
				end
																		
				`AND_FUNC:begin
					alu_opcode = AND;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: and r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs,rt);
					`endif
				end
								
				`OR_FUNC:begin
					alu_opcode = OR;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: or r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs,rt);
					`endif
				end
								
				`XOR_FUNC:begin
					alu_opcode = XOR;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: xor r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs,rt);
					`endif
				end

				`NOR_FUNC:begin
					alu_opcode = NOR;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: nor r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs,rt);
					`endif
				end

				`JR_FUNC:begin
					reg_file_we = 0;
					reg_file_we = 1;
					j_taken = 2; //0 not taken, 1 direct, 2 reg
					instr_uses_rt = 0;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: jr r%0d", core_inst.PC_plus4_FD-4,instr,rs);
					`endif
				end

				`JALR_FUNC:begin
					reg_file_we = 1;
					j_taken = 2; //0 not taken, 1 direct, 2 reg
					reg_write_src = 4; //0 alu out, 1 mem out, 2 hi, 3 lo, 4 pcPlus4
					instr_uses_rt = 0;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: jalr r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs);
					`endif
				end							
								
				default:begin
					//reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: NOT FOUND", core_inst.PC_plus4_FD-4,instr);
					`endif
				end
			endcase
		end

		`SPECIAL2_OP:begin 
			case(func)
				`MUL_FUNC:begin
					alu_opcode = MULT;
					reg_file_we = 1;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: mul r%0d, r%0d, r%0d", core_inst.PC_plus4_FD-4,instr,rd,rs,rt);
					`endif
				end
				
				default:begin
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: NOT FOUND", core_inst.PC_plus4_FD-4,instr);
					`endif
				end
			endcase
		end

		`REGIMM_OP:begin 
			case(branch_func)
				`BGEZ_BRFUNC:begin
					alu_opcode = SUB;
					alu_in_2_sel = 2; //0 reg, 1 immediate, 2 cons0
					br_op = BGEZ; 
					instr_uses_rt = 0;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: bgez r%0d, 0x%h", core_inst.PC_plus4_FD-4,instr,rs,$signed(immediate));
					`endif
				end

				`BLTZ_BRFUNC:begin
					alu_opcode = SUB;
					alu_in_2_sel = 2; //0 reg, 1 immediate, 2 cons0
					br_op = BLTZ; 
					instr_uses_rt = 0;
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: bltz r%0d, 0x%h", core_inst.PC_plus4_FD-4,instr,rs,$signed(immediate));
					`endif
				end
				
				default:begin
					`ifdef DEBUG #0.5
						$display("PC: %h\tInstr Bits: %b\tInstr Assembly: NOT FOUND", core_inst.PC_plus4_FD-4,instr);
					`endif
				end
			endcase
		end

		`ADDI_OP:begin 
			alu_opcode = ADD_OVER;
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
			reg_file_we = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: addi r%0d, r%0d, %0d", core_inst.PC_plus4_FD-4,instr,rt,rs,$signed(immediate));
			`endif
		end

		`ADDIU_OP:begin 
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
			reg_file_we = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: addiu r%0d, r%0d, %0d", core_inst.PC_plus4_FD-4,instr,rt,rs,$signed(immediate));
			`endif
		end

		`SLTI_OP:begin 
			alu_opcode = SLT;
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
			reg_file_we = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: slti r%0d, r%0d, %0d", core_inst.PC_plus4_FD-4,instr,rt,rs,$signed(immediate));
			`endif
		end

		`SLTIU_OP:begin 
			alu_opcode = SLTU;
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
			reg_file_we = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: sltiu r%0d, r%0d, %0d", core_inst.PC_plus4_FD-4,instr,rt,rs,immediate);
			`endif
		end

		`ANDI_OP:begin 
			alu_opcode = AND;
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
			reg_file_we = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: andi r%0d, r%0d, %0d", core_inst.PC_plus4_FD-4,instr,rt,rs,immediate);
			`endif
		end

		`ORI_OP:begin 
			alu_opcode = OR;
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
			reg_file_we = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: ori r%0d, r%0d, %0d", core_inst.PC_plus4_FD-4,instr,rt,rs,immediate);
			`endif
		end

		`XORI_OP:begin 
			alu_opcode = XOR;
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
			reg_file_we = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: xori r%0d, r%0d, %0d", core_inst.PC_plus4_FD-4,instr,rt,rs,immediate);
			`endif
		end

		`LW_OP:begin
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
	        reg_write_src =  1;
			mem_enable = 1;	
			reg_file_we = 1;
			instr_load = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: lw r%0d, %0d(r%0d)", core_inst.PC_plus4_FD-4,instr,rt,$signed(immediate),rs);
			`endif
		end

		`SW_OP:begin 
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			mem_read_write = 0; //0 write, 1 read
			mem_enable = 1;	
			instr_store = 1;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: sw r%0d, %0d(r%0d)", core_inst.PC_plus4_FD-4,instr,rt,$signed(immediate),rs);
			`endif
		end

		`LB_OP:begin 
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
			reg_write_src =  1;
			mem_enable = 1;	
			access_size = 2; //0 word, 1 half, 2 byte
			reg_file_we = 1;
			instr_load = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: lb r%0d, %0d(r%0d)", core_inst.PC_plus4_FD-4,instr,rt,$signed(immediate),rs);
			`endif
		end

		`SB_OP:begin 
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			mem_read_write = 0; //0 write, 1 read
			mem_enable = 1;	
			access_size = 2; //0 word, 1 half, 2 byte
			instr_store = 1;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: sb r%0d, %0d(r%0d)", core_inst.PC_plus4_FD-4,instr,rt,$signed(immediate),rs);
			`endif
		end

		`LBU_OP:begin 
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
	        reg_write_src =  1;
			mem_enable = 1;	
			load_sign = 0; //0 unsigned, 1 signed
			access_size = 2; //0 word, 1 half, 2 byte
			reg_file_we = 1;
			instr_load = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: lbu r%0d, %0d(r%0d)", core_inst.PC_plus4_FD-4,instr,rt,$signed(immediate),rs);
			`endif
		end

		`LH_OP:begin 
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
	       	reg_write_src =  1;
			mem_enable = 1;	
			access_size = 1; //0 word, 1 half, 2 byte
			reg_file_we = 1;
			instr_load = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: lh r%0d, %0d(r%0d)", core_inst.PC_plus4_FD-4,instr,rt,$signed(immediate),rs);
			`endif
		end

		`LHU_OP:begin 
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
	       	reg_write_src =  1;
			mem_enable = 1;	
			load_sign = 0; //0 unsigned, 1 signed
			access_size = 1; //0 word, 1 half, 2 byte
			reg_file_we = 1;
			instr_load = 1;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: lhu r%0d, %0d(r%0d)", core_inst.PC_plus4_FD-4,instr,rt,$signed(immediate),rs);
			`endif
		end

		`SH_OP:begin 
			alu_in_2_sel = 1; //0 reg, 1 immediate, 2 cons0
			mem_read_write = 0; //0 write, 1 read
			mem_enable = 1;	
			access_size = 1; //0 word, 1 half, 2 byte
			instr_store = 1;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: sh r%0d, %0d(r%0d)", core_inst.PC_plus4_FD-4,instr,rt,$signed(immediate),rs);
			`endif
		end

		`J_OP:begin 
			j_taken = 1; //0 not taken, 1 direct, 2 reg
			instr_uses_rs = 0;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: j 0x%h", core_inst.PC_plus4_FD-4,instr,target);
			`endif
		end

		`JAL_OP:begin 
			reg_dest_sel = 2; //0 rd, 1 rt, 2 cons31
			reg_file_we = 1;
			j_taken = 1; //0 not taken, 1 direct, 2 reg
			reg_write_src = 4; //0 alu out, 1 mem out, 2 hi, 3 lo, 4 pcPlus4
			instr_uses_rs = 0;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: jal 0x%h", core_inst.PC_plus4_FD-4,instr,target);
			`endif
		end

		`BEQ_OP:begin
			alu_opcode = SUB;
			br_op = BEQ; 
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: beq r%0d, r%0d, 0x%h", core_inst.PC_plus4_FD-4,instr,rs,rt,$signed(immediate));
			`endif
		end

		`BNE_OP:begin
			alu_opcode = SUB;
			br_op = BNE; 
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: bne r%0d, r%0d, 0x%h", core_inst.PC_plus4_FD-4,instr,rt,rs,$signed(immediate));
			`endif
		end

		`BGTZ_OP:begin 
			alu_opcode = SUB;
			alu_in_2_sel = 2; //0 reg, 1 immediate, 2 cons0
			br_op = BGTZ; 
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: bgtz r%0d, 0x%h", core_inst.PC_plus4_FD-4,instr,rs,$signed(immediate));
			`endif
		end

		`BLEZ_OP:begin
			alu_opcode = SUB;
			alu_in_2_sel = 2; //0 reg, 1 immediate, 2 cons0 
			br_op = BLEZ; 
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: blez r%0d, 0x%h", core_inst.PC_plus4_FD-4,instr,rs,$signed(immediate));
			`endif
		end

		`LUI_OP:begin 
			alu_opcode = SLL;
			alu_in_1_sel = 2; //cons16
			alu_in_2_sel = 1; //immediate
			reg_dest_sel = 1; //0 rd, 1 rt, 2 cons31
			reg_file_we = 1;
			instr_uses_rs = 0;
			instr_uses_rt = 0;
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: lui r%0d, %0d", core_inst.PC_plus4_FD-4,instr,rt,$signed(immediate));
			`endif
		end

		default:begin
			`ifdef DEBUG #0.5
				$display("PC: %h\tInstr Bits: %b\tInstr Assembly: NOT FOUND", core_inst.PC_plus4_FD-4,instr);
			`endif
		end
	endcase
end //always

endmodule

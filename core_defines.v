`ifndef _core_defines_h
`define _core_defines_h


//#################### SPECIAL OPCODES ####################
`define SPECIAL_OP 	 6'b000000	//RTYPE_OPCODE
`define SPECIAL2_OP 	 6'b011100
`define REGIMM_OP 	 6'b000001

//#################### OPCODES ####################
`define ADDI_OP 	 6'b001000
`define ADDIU_OP 	 6'b001001
`define SLTI_OP 	 6'b001010
`define SLTIU_OP 	 6'b001011
`define ANDI_OP 	 6'b001100
`define ORI_OP 		 6'b001101
`define XORI_OP 	 6'b001110
`define LW_OP 	 	 6'b100011
`define SW_OP 	 	 6'b101011
`define LB_OP 	 	 6'b100000
`define SB_OP 	 	 6'b101000
`define LBU_OP 	 	 6'b100100
`define LH_OP 	 	 6'b100001
`define LHU_OP 	 	 6'b100101
`define SH_OP 	 	 6'b101001
`define J_OP 	 	 6'b000010
`define JAL_OP 	 	 6'b000011
`define BEQ_OP 	 	 6'b000100
`define BNE_OP 	 	 6'b000101
`define BGTZ_OP 	 6'b000111
`define BLEZ_OP 	 6'b000110
`define LUI_OP 	 	 6'b001111

//#################### RTYPE FUNCTIONS ####################
`define ADD_FUNC 	 6'b100000
`define ADDU_FUNC 	 6'b100001
`define SUB_FUNC 		 6'b100010
`define SUBU_FUNC 	 6'b100011
`define MULT_FUNC 	 6'b011000
`define MULTU_FUNC 	 6'b011001
`define DIV_FUNC 	 6'b011010
`define DIVU_FUNC 	 6'b011011
`define MFHI_FUNC 	 6'b010000
`define MFLO_FUNC 	 6'b010010
`define SLT_FUNC 	 6'b101010
`define SLTU_FUNC 	 6'b101011
`define SLL_FUNC 	 6'b000000
`define SLLV_FUNC 	 6'b000100
`define SRL_FUNC 	 6'b000010
`define SRLV_FUNC 	 6'b000110
`define SRA_FUNC 	 6'b000011
`define SRAV_FUNC 	 6'b000111
`define AND_FUNC 	 6'b100100
`define OR_FUNC 	 6'b100101
`define XOR_FUNC 	 6'b100110
`define NOR_FUNC 	 6'b100111
`define JALR_FUNC 	 6'b001001
`define JR_FUNC 	 6'b001000

//#################### REFIMM FUNCTIONS ####################
`define MUL_FUNC 	 6'b000010

//#################### BRANCH FUNCTIONS ####################
`define BGEZ_BRFUNC 	 5'b00001
`define BLTZ_BRFUNC 	 5'b00000

`endif


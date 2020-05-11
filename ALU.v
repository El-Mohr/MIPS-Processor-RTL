`timescale 1ns / 1ps

//#################### Defines  ####################


//#################### Module ####################
module ALU #( 
	parameter data_width = 32
)
(
	input [data_width-1:0] in_s1,
	input [data_width-1:0] in_s2,
	input [4:0] alu_opcode,
	output reg [data_width-1:0] result,
	output reg [data_width-1:0] hi,
	output over_flow,
	output reg zero
);

//#################### Local Parameters ####################
localparam ADD = 0, ADD_OVER = 1, SUB = 2, SUB_OVER = 3,
	   AND = 4, OR = 5, XOR = 6, NOR = 7, 
	   SLL = 8, SRL = 9, SRA = 10,
	   MULT = 11,  MULTU = 12,  DIV = 13,  DIVU = 14,
	   SLT = 15, SLTU = 16;

//#################### Wires ####################
wire [data_width-1:0] operand_a;
wire [data_width-1:0] operand_b;
wire sign_ext_a;
wire sign_ext_b;
//#################### Regs ####################
reg temp;

//#################### Logic ####################
//-------------------- Handling Sign  --------------------
assign operand_a = in_s1;
assign operand_b = ( (alu_opcode == SUB) || (alu_opcode == SUB_OVER) )? (~in_s2 + 1): in_s2;
assign over_flow = ( (alu_opcode == ADD_OVER) || (alu_opcode == SUB_OVER) ) && (temp != result[data_width-1]) ;
assign sign_ext_a = ( (alu_opcode == MULTU) || (alu_opcode == DIVU) ||  (alu_opcode == SLTU) )? 0 : operand_a[data_width-1] ;
assign sign_ext_b = ( (alu_opcode == MULTU) || (alu_opcode == DIVU) ||  (alu_opcode == SLTU) )? 0 : operand_b[data_width-1] ;
//-------------------- ALU  --------------------
always@(*) begin
	result = 0;
	hi = 0;
	zero = 0;
	temp = 0;

	case(alu_opcode)
		ADD, ADD_OVER, SUB, SUB_OVER :begin 
			{temp,result} = {sign_ext_a,operand_a} + {sign_ext_b,operand_b};
			zero = (result == 0);
		end
		AND :begin 
			result = operand_a & operand_b;
		end
		OR :begin 
			result = operand_a | operand_b;
		end
		XOR :begin 
			result = operand_a ^ operand_b;
		end
		NOR :begin 
			result = ~ (operand_a | operand_b);
		end
		SLL :begin 
			result = operand_b << operand_a[4:0] ;
		end
		SRL :begin 
			result = operand_b >> operand_a[4:0] ;
		end
		SRA :begin 
			result = operand_b >>> operand_a[4:0] ;
		end
		MULT, MULTU:begin 
			{hi,result} = $signed({sign_ext_a,operand_a}) * $signed({sign_ext_b,operand_b});
		end
		DIV, DIVU:begin 
			result =  $signed({sign_ext_a,operand_a}) /  $signed({sign_ext_b,operand_b});
			hi =  $signed({sign_ext_a,operand_a}) %  $signed({sign_ext_b,operand_b});
		end
		SLT, SLTU:begin 
			result = ( $signed({sign_ext_a,operand_a}) < $signed({sign_ext_b,operand_b}) );
		end
		default : $display("Error: Not Supported ALU operation"); 
	endcase
			
end

endmodule

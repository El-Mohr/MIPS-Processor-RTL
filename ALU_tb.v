
`timescale 1ns / 1ps

//#################### Defines  ####################


//#################### Module ####################
module ALU_tb();
parameter data_width = 32;
parameter Tclk = 2;
parameter Dclk = (1.001*Tclk);
//#################### Wires ####################
wire [data_width-1:0] result;
wire [data_width-1:0] hi;
wire over_flow;
wire zero;

//#################### Regs ####################
reg [data_width-1:0] in_s1;
reg [data_width-1:0] in_s2;
reg [4:0] alu_opcode;
	
//#################### Local Parameters ####################
localparam ADD = 0, ADD_OVER = 1, SUB = 2, SUB_OVER = 3,
	   AND = 4, OR = 5, XOR = 6, NOR = 7, 
	   SLL = 8, SRL = 9, SRA = 10,
	   MULT = 11,  MULTU = 12,  DIV = 13,  DIVU = 14,
	   SLT = 15, SLTU = 16;

//#################### Variables ####################
integer i;
integer file;

//#################### Logic ####################
//-------------------- DUT instantiation --------------------
ALU #(	.data_width(data_width)
) ALU_inst (	
		.in_s1(in_s1),
		.in_s2(in_s2), 
		.alu_opcode(alu_opcode), 
		.result(result), 
		.hi(hi), 
		.over_flow(over_flow),
		.zero(zero) 
);

//-------------------- initializations --------------------
initial begin
	$dumpfile("ALU_tb.vcd");
	$dumpvars(0,ALU_tb);
	in_s1 <= 0;
	in_s2 <= 0;
	alu_opcode <= 0;
	file = $fopen("log.txt","w"); 
end

//-------------------- Test Stimulus --------------------
initial begin
		
	#Dclk
	
	//Test positive overflow	
	in_s1 = 2147483647;
	in_s2 = 2147483647;
	alu_opcode = ADD;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tOver Flow = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), over_flow);

	in_s1 = 2147483647;
	in_s2 = 2147483647;
	alu_opcode = ADD_OVER;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tOver Flow = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), over_flow);

	//Test negative overflow	
	in_s1 = -2147483647;
	in_s2 = -2147483647;
	alu_opcode = ADD;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tOver Flow = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), over_flow);

	in_s1 = -2147483647;
	in_s2 = -2147483647;
	alu_opcode = ADD_OVER;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tOver Flow = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), over_flow);

	//Test Regular Addition	
	in_s1 = 1;
	in_s2 = 2;
	alu_opcode = ADD_OVER;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tOver Flow = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), over_flow);

	in_s1 = -1;
	in_s2 = -2;
	alu_opcode = ADD_OVER;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tOver Flow = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), over_flow);

	//Test Regular Subtraction	
	in_s1 = 3;
	in_s2 = 1;
	alu_opcode = SUB_OVER;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tOver Flow = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), over_flow);

	in_s1 = -3;
	in_s2 = -1;
	alu_opcode = SUB_OVER;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tOver Flow = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), over_flow);

	//Test Multiplication	
	in_s1 = 3;
	in_s2 = 1;
	alu_opcode = MULT;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);

	in_s1 = -3;
	in_s2 = -1;
	alu_opcode = MULT;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);
	
	in_s1 = -3;
	in_s2 = 1;
	alu_opcode = MULT;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);

	in_s1 = 3;
	in_s2 = 1;
	alu_opcode = MULTU;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);

	in_s1 = -3;
	in_s2 = -1;
	alu_opcode = MULTU;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);
	
	in_s1 = -3;
	in_s2 = 1;
	alu_opcode = MULTU;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);


	//Test Division	
	in_s1 = 8;
	in_s2 = 3;
	alu_opcode = DIV;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);

	in_s1 = -8;
	in_s2 = -3;
	alu_opcode = DIV;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);
	
	in_s1 = -8;
	in_s2 = 3;
	alu_opcode = DIV;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);

	in_s1 = 8;
	in_s2 = 3;
	alu_opcode = DIVU;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);

	in_s1 = -8;
	in_s2 = -3;
	alu_opcode = DIVU;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);
	
	in_s1 = -8;
	in_s2 = 3;
	alu_opcode = DIVU;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\tHi = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result), hi);
	

	//Test SLT	
	in_s1 = -1;
	in_s2 = 3;
	alu_opcode = SLT;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result));

	in_s1 = -1;
	in_s2 = 3;
	alu_opcode = SLTU;
	#Tclk
	$fwrite(file,"Operation = %d\tin_s1 = %d\tin_s2 = %d\tResult = %d\n",alu_opcode,$signed(in_s1),$signed(in_s2),$signed(result));


	$fclose(file); 
	$finish();
end

endmodule




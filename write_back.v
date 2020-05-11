`timescale 1ns / 1ps
//#################### Defines  ####################


//#################### Module ####################
module write_back #( 
	parameter data_width = 32
)
(
	input [2:0] reg_write_src,
	input [data_width-1:0] mem_data,
	input [data_width-1:0] alu_data,
	input [data_width-1:0] hi_reg,
	input [data_width-1:0] lo_reg,
	input [data_width-1:0] PC_plus4,
	output [data_width-1:0] wb_data
);

//#################### Logic ####################
//-------------------- MUX --------------------
assign wb_data = reg_write_src==0? alu_data : reg_write_src==1? mem_data :  reg_write_src==2? hi_reg : reg_write_src==3? lo_reg : PC_plus4;

endmodule

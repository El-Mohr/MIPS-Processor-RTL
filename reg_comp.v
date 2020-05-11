`timescale 1ns / 1ps

//#################### Defines  ####################


//#################### Module ####################
module reg_comp#( 
	parameter data_width = 32
)
(
	input clock,
	input reset,
	input write_enable,
	input [data_width-1:0] data_in,
	output reg [data_width-1:0] data_out
);

//#################### Logic ####################
//-------------------- Flip Flop --------------------
always@(posedge clock) begin
	if (reset) begin
		data_out <= 0;
	end
	else begin
		if(write_enable==1) begin
			data_out <= data_in;
		end
	end	
end

endmodule

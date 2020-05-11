`timescale 1ns / 1ps

//#################### Defines  ####################


//#################### Module ####################
module mem #( 
	parameter data_width = 32,
	parameter address_width = 32,
	parameter mem_depth = (1048576>>2), // == 1MB in Bytes
	parameter base_address = 32'h80020000 
)
(
	input clock,
	input [address_width-1:0] address,
	input [data_width-1:0] data_in,
	input read_write,
	input enable,
	input [data_width/8-1:0] byte_we,
	output [data_width-1:0] data_out
);

//#################### Regs ####################
reg [data_width-1:0] mem [mem_depth-1:0];

//#################### Variables ####################
genvar i;

//#################### Logic ####################
//-------------------- Read --------------------
assign data_out = (enable==1 && read_write==1)? mem[(address-base_address)>>2] : {data_width{1'bz}};

//-------------------- Write --------------------
generate
	for(i=0; i<data_width/8; i=i+1) begin : mem_wr
		always@(posedge clock) begin
			if(enable==1 && read_write==0) begin //write at 0
				if(byte_we[i] == 1) begin
					mem[(address-base_address)>>2][8*(i+1)-1:8*i] <= data_in[8*(i+1)-1:8*i];
				end
			end
		end	
	end
endgenerate

endmodule

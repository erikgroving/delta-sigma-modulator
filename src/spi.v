module SPI (
	input	SCLK,
	input	MOSI,
	output [4: 0]  w_cos_1 [7: 0],
	output [4: 0]  w_sin_1 [7: 0],                           
	output [4: 0]  w_cos_2 [7: 0],                           
	output [4: 0]  w_sin_2 [7: 0]
);

	always @(posedge SCLK) begin
	
	end

endmodule
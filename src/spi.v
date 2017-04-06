module SPI (
	input	SCLK,
	input	MOSI,
	input	reset,
	output [4: 0]  w_cos_1 [7: 0],
	output [4: 0]  w_sin_1 [7: 0],                           
	output [4: 0]  w_cos_2 [7: 0],                           
	output [4: 0]  w_sin_2 [7: 0]
);

	reg	[7: 0]	spi_data_in;
	reg	[7: 0]	spi_cycle;
	always @(posedge SCLK) begin
		if (reset) begin
			spi_data_in	<= 8'b0;
			spi_cycle	<= 8'b0;
		end
	end

endmodule
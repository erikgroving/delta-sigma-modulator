// Total shift register is 32 bits. MSB first
// SIn[7:1] - Address
// SIn[0] - R/W (SIn[0]==1 -> Write , SIn[0]==0 -> Read)
// SIn [31:8] - Data
module SPI (
	input	SCLK,
	input	MOSI,
	input 	ss,
	input	reset,
	output [7: 0][4: 0]  w_cos_1,
	output [7: 0][4: 0]  w_sin_1,                           
	output [7: 0][4: 0]  w_cos_2,                           
	output [7: 0][4: 0]  w_sin_2 
);
	
	parameter addr_w_cos1_f	= 7'h01;
	parameter addr_w_cos1_s	= 7'h02;
	parameter addr_w_sin1_f	= 7'h03;
	parameter addr_w_sin1_s	= 7'h04;
	parameter addr_w_cos2_f	= 7'h05;
	parameter addr_w_cos2_s	= 7'h06;
	parameter addr_w_sin2_f	= 7'h07;
	parameter addr_w_sin2_s	= 7'h08;

	wire		master_en;
	reg	[31: 0]	spi_data_in;
	wire [7: 1]	spi_addr;
	
	
	
	reg	[3: 0][4: 0]	w_cos1_f;	// first half of w_cos_1
	reg	[3: 0][4: 0]	w_cos1_s; // second half
	reg	[3: 0][4: 0]	w_sin1_f;
	reg	[3: 0][4: 0]	w_sin1_s;
	reg	[3: 0][4: 0]	w_cos2_f;	// first half of w_cos_1
	reg	[3: 0][4: 0]	w_cos2_s; // second half
	reg	[3: 0][4: 0]	w_sin2_f;
	reg	[3: 0][4: 0]	w_sin2_s;
	

	wire w_cos1_f_en;	// first half of w_cos_1
	wire w_cos1_s_en; // second half
	wire w_sin1_f_en;
	wire w_sin1_s_en;
	wire w_cos2_f_en;	// first half of w_cos_1
	wire w_cos2_s_en; // second half
	wire w_sin2_f_en;
	wire w_sin2_s_en;
	
	reg	[5:	0]	counter;
	
	// Assign outputs to the 16-bit registers
	assign w_cos_1[3: 0]	= w_cos1_f;
	assign w_cos_1[7: 4]	= w_cos1_s;
	assign w_sin_1[3: 0]	= w_sin1_f;
	assign w_sin_1[7: 4]	= w_sin1_s;
	assign w_cos_2[3: 0]	= w_cos2_f;
	assign w_cos_2[7: 4]	= w_cos2_s;
	assign w_sin_2[3: 0]	= w_sin2_f;
	assign w_sin_2[7: 4]	= w_sin2_s;
	
	
	
	// similar to SPI.v
	assign spi_addr		= spi_data_in[30:24];	// bit [31] (oldest bit) is the R/W, so then bits 30:24 (7 bits) is the address
	assign master_en 	= (~ss) & (counter == 6'd32) & spi_data_in[31];	// slave select low (active low), 
																		// transaction finished, and write bit high
	assign w_cos1_f_en	= master_en & (spi_addr == addr_w_cos1_f);
	assign w_cos1_s_en	= master_en & (spi_addr == addr_w_cos1_s);
	assign w_sin1_f_en	= master_en & (spi_addr == addr_w_sin1_f);
	assign w_sin1_s_en	= master_en & (spi_addr == addr_w_sin1_s);
	assign w_cos2_f_en	= master_en & (spi_addr == addr_w_cos2_f);
	assign w_cos2_s_en	= master_en & (spi_addr == addr_w_cos2_s);
	assign w_sin2_f_en	= master_en & (spi_addr == addr_w_sin2_f);
	assign w_sin2_s_en	= master_en & (spi_addr == addr_w_sin2_s);
	
	
	// code similar to SPI.v
	always @ (negedge SCLK or posedge reset) begin
      	if (reset) begin
			counter		<= 6'd0;
		end
     	else if (~ss) begin
			if (counter == 6'd32) begin
				counter	<= 6'd0;
			end				
			counter	<= counter + 1'b1;
		end
	end
	
	
	// SPI Data register (similar to SRegister.v)
	always @ (posedge SCLK or posedge reset) begin
		if (reset)
			spi_data	<= 32'b0;
		else if (~ss) begin
			spi_data	<= {spi_data[30:1], MOSI};
		end
	end

	
endmodule


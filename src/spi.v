// Total shift register is 32 bits. MSB
// Send R/W --> Address --> Data
// spi_data[30:24] - Address
// spi_data[31] - R/W (SIn[0]==1 -> Write , SIn[0]==0 -> Read)
// spi_data[23: 0] - Data (ONLY 20 BITS USED PER TRANSACTION, USING 23:4

// Example:

// Write 1 2 3 4 to the first half of w_sin_1 , w_sin_1[0] = 1, w_sin_1[3] = 4
// spi_data[31] 	= 0x1, we are doing a write!
// spi_data[30:24] 	= 0x3, use the address of the first half of w_sin_1
// spi_data[23: 19]	= 0x1
// spi_data[18: 14] = 0x2
// spi_data[13: 9]	= 0x3
// spi_data[8: 4]	= 0x4
// spi_data[3: 0]	= don't care

// Combine this into a 32 bit string and write it via SPI to properly set.


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
	
	
	
	wire [3: 0][4: 0]	w_cos1_f;	// first half of w_cos_1
	wire [3: 0][4: 0]	w_cos1_s; // second half
	wire [3: 0][4: 0]	w_sin1_f;
	wire [3: 0][4: 0]	w_sin1_s;
	wire [3: 0][4: 0]	w_cos2_f;	// first half of w_cos_1
	wire [3: 0][4: 0]	w_cos2_s; // second half
	wire [3: 0][4: 0]	w_sin2_f;
	wire [3: 0][4: 0]	w_sin2_s;
	wire 				w_cos1_f_en;	// first half of w_cos_1
	wire 				w_cos1_s_en; // second half
	wire 				w_sin1_f_en;
	wire 				w_sin1_s_en;
	wire 				w_cos2_f_en;	// first half of w_cos_1
	wire 				w_cos2_s_en; // second half
	wire 				w_sin2_f_en;
	wire 				w_sin2_s_en;	
	reg	[5:	0]			counter;
	
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
			spi_data_in	<= 32'b0;
		else if (~ss) begin
			spi_data_in	<= {spi_data_in[30:1], MOSI};
		end
	end
	
	
	// w_cos1_f
	internalRegister w_cos1_f_i (
		.clock(SCLK),
		.reset(reset),
		.en(w_cos1_f_en),
		.D(spi_data_in[23:4]),
		.Q(w_cos1_f)
	);
	
	// w_cos1_s
	internalRegister w_cos1_s_i (
		.clock(SCLK),
		.reset(reset),
		.en(w_cos1_s_en),
		.D(spi_data_in[23:4]),
		.Q(w_cos1_s)
	);
	
	// w_sin1_f
	internalRegister w_sin1_f_i (
		.clock(SCLK),
		.reset(reset),
		.en(w_sin1_f_en),
		.D(spi_data_in[23:4]),
		.Q(w_sin1_f)
	);
	
	// w_sin1_s
	internalRegister w_sin1_s_i (
		.clock(SCLK),
		.reset(reset),
		.en(w_sin1_s_en),
		.D(spi_data_in[23:4]),
		.Q(w_sin1_s)
	);
	
	// w_cos2_f
	internalRegister w_cos2_f_i (
		.clock(SCLK),
		.reset(reset),
		.en(w_cos2_f_en),
		.D(spi_data_in[23:4]),
		.Q(w_cos2_f)
	);
	
	// w_cos2_s
	internalRegister w_cos2_s_i (
		.clock(SCLK),
		.reset(reset),
		.en(w_cos2_s_en),
		.D(spi_data_in[23:4]),
		.Q(w_cos2_s)
	);
	
	// w_sin2_f
	internalRegister w_sin2_f_i (
		.clock(SCLK),
		.reset(reset),
		.en(w_sin2_f_en),
		.D(spi_data_in[23:4]),
		.Q(w_sin2_f)
	);
	
	// w_sin2_s
	internalRegister w_sin2_s_i (
		.clock(SCLK),
		.reset(reset),
		.en(w_sin2_s_en),
		.D(spi_data_in[23:4]),
		.Q(w_sin2_s)
	);
	
	
endmodule

module internalRegister (
	input clock,
	input reset,
	input en,
	input [19: 0] 		D,
	output reg [3: 0][4: 0]	Q
);

	always @(posedge clock) begin
		if (reset) begin
			Q		<= 20'b0;
		end
		else if (en) begin
			Q[0]	<= D[19:15];
			Q[1]	<= D[14:10];
			Q[2]	<= D[9:5];
			Q[3]	<= D[4:0];
		end
	end

endmodule

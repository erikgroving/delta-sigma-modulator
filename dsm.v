// Okay, so I'm doing the bitwise representation this way:
// 20 bits: 
// [19:16] 	-- saturation bits (I hope output can't become greater than 16 times input
// [15] 	-- the voltage bit (if high: 1 Volt, if low: -1 Volt)
// [14: 0] 	-- fractional bits that aren't used in final output 
`define VIN_FS				20'h0_8000	// bit 15 is high, 1 volt
`define VIN_FS_RECIPROCAL	20'h0_8000	// 1/1 is still 1
`define VIN_FS_HALF			20'h0_4000	// half of VIN_FS (bit 14 is high)
`define VIN_FS_HALF_NEG		20'hF_C000
`define Q_OFF 				20'h0_4000	// bit 14 is high -> 0.5 Volts
// Top level module
module DSM_top (
	input			clock,
	input			reset,
	input	[19: 0]	vin, 	// 1 bit
	output	reg		pwm		// 1 bit
	
	//input	[31: 0]	dith_i,		// Dithering is currently off
);

	wire	[19: 0]	pwm_scaled;				// PWM * vin_FS/2	
	wire	[19: 0]	vin_pwm_scaled_delta;	// vin - pwm_scaled
	wire	[19: 0]	dss_o;
	wire	[19: 0]	dss_vin_sum;
	wire	[19: 0]	dss_vin_sum_dith;
	wire			quant_o;
	

	
	// Multiply by (VIN_FS/2) (bitshifted once)
	assign	pwm_scaled				= pwm ? `VIN_FS_HALF : `VIN_FS_HALF_NEG;
	// Assuming KFW is 1
	assign	vin_pwm_scaled_delta	= vin - pwm_scaled;
	// Sum DSS output with vin
	assign	dss_vin_sum				= dss_o + vin;
	// Dither the dss output summed with vin
	assign 	dss_vin_sum_dith		= dss_vin_sum /*+ dith_i*/;	// dithering turned off
	
	always @(posedge clock) begin
		if (reset) begin
			pwm	<= #1 1'b0;
		end
		else begin
			pwm	<= #1 quant_o;	// bits 19-16 are for saturation, ignore. 14-0 are fractional bits
		end
	end
	
	// I need to know how wide y (dss_out) should be
	// This means I need to know what n is.
	// Also need an idea of what A, B, C, and D are
	// see below 
	// Question: What is n (number of states)?
	// answer: see below, i thinks it is 4.
	// Question: What are the values of A, B, C and D? (I can leave undefined for now)
	// answer: you can run tb.m and get the value of A,B,C,D. only D is a number ,ABC are all matrix
	DSS DSS_i (
		.clock(clock),
		.reset(reset),
		.u(vin_pwm_scaled_delta),
		.y(dss_o)
	);
	
	quantizer quantizer_i (
		.in1(dss_vin_sum_dith),
		.clock(clock),
		.reset(reset),
		.out1(quant_o)
	);
	

endmodule


// Discrete-state space
// N is number of states
// Question: How many states are there? (need this to write)
//answer: i get the following from the help of Discrete State-Space
//x(n+1)=Ax(n)+Bu(n), y(n)=Cx(n)+Du(n),
//where u is the input, x is the state, and y is the output. The matrix coefficients must //have these characteristics, as illustrated in the following diagram:

//A must be an n-by-n matrix, where n is the number of states. (4*4,so n=4)
//B must be an n-by-m matrix, where m is the number of inputs. (4*1,m=1)
//C must be an r-by-n matrix, where r is the number of outputs. (1*4, r=1)
//D must be an r-by-m matrix. (1*1)

//The block accepts one input and generates one output. The width of the input vector
// is the number of columns in the B and D matrices. The width of the output vector
// is the number of rows in the C and D matrices. To define the initial state vector,
// use the Initial conditions parameter.

module DSS (
	input			clock,
	input			reset,
	input	[19: 0] u,
	output	[19: 0]	y
);
	// 25 bit precision for the DSS since they are pretty small.
	// 2's complement since there are negative numbers
	// [24]	- -2
	// [23] - 1
	// [22: 0] fractional precision bits
	wire	[24: 0]	A0 [3: 0];	// row 0
	wire	[24: 0]	A1 [3: 0];	// row 1
	wire	[24: 0] A2 [3: 0];	// row 2
	wire	[24: 0] A3 [3: 0];	// row 3
	
	
	wire	[3: 0]	B;
	wire	[24: 0]	C [3: 0];
	wire	[24: 0] D;
	
	wire	[19: 0] xn1 [3: 0];
	reg		[19: 0]	xn0	[3: 0];
	wire	[44: 0] temp_xn1;
	wire	[44: 0] temp_y;
	
	always @ (posedge clock) begin
		if (reset) begin
			xn0[0]	<= 20'b0;
			xn0[1]	<= 20'b0;
			xn0[2]	<= 20'b0;
			xn0[3]	<= 20'b0;
		end
		else begin
			xn0[0]	<= xn1[0];
			xn0[1]	<= xn1[1];
			xn0[2]	<= xn1[2];
			xn0[3]	<= xn1[3];
		end
	end
	
		// TODO: shift bits properly for multiplication
	assign temp_xn1	= A0[0]*xn0[0]+A0[1]*xn0[1]+A0[2]*xn0[2]+A0[3]*xn0[3];
	assign xn1[0]	= temp_xn1[42:23] + u;
	assign xn1[1]	= xn0[0];
	assign xn1[2]	= xn0[1];
	assign xn1[3]	= xn0[2];
	assign temp_y	= C[0]*xn0[0]+C[1]*xn0[1]+C[2]*xn0[2]+C[3]*xn0[3]+D*u;
	assign y		= temp_y[42:23] + u;
	
	
	// Walkthrough of how the representation of A0[0] is done
	// Multiply by 2^23 (so there are 23 fractional bits)
	// If negative 2's complement.
	// A0[0] = -6.28132e-04
	// -6.281320980921351e-04 * 2^23 = -5269.15 ~= -5269
	// 5269 in hex: 0x000_1495
	// Invert: 0x1FF_EB6A, 2's complment -> 0x1FF_EB6B
	// If we look at this value:
	// -2^24 --> -16777216, 0xFF_EB6B = 16771947
	// -16777216 + 16771947 = -5269
	// This divided 2^23 is -6.28113e-4, close enough(I hope, actual is -6.28132e-4)
	
	// First row
	assign A0[0]	= 25'h1FF_EB6B;		// -6.28113e-4 (supposed to be -6.28132e-04)
	assign A0[1]	= 25'h100_40AB;		// -1.99802649 (supposed to be -1.99802650)
	assign A0[2]	= 25'h1FF_EB6B;		// same as A0[0]
	assign A0[3]	= 25'h180_0000;		// -1
	// Second row
	assign A1[0]	= 25'h080_0000;		// 1
	assign A1[1]	= 25'h0;			// 0
	assign A1[2]	= 25'h0;			// 0
	assign A1[3]	= 25'h0;			// 0
	// Third Row
	assign A2[0]	= 25'h0;			// 0
	assign A2[1]	= 25'h080_0000;		// 1
	assign A2[2]	= 25'h0;			// 0
	assign A2[3]	= 25'h0;			// 0
	// Fourth Row
	assign A3[0]	= 25'h0;			// 0
	assign A3[1]	= 25'h0;			// 0
	assign A3[2]	= 25'h080_0000;		// 1
	assign A3[3]	= 25'h0;			// 0
	
	// B
	assign B		= 4'b0001;
	
	// C
	assign C[0]		= 25'h18F_5D27;		// -0.8799698
	assign C[1]		= 25'h88055;		//  0.0664163
	assign C[2]		= 25'h1B2_1A18;		// -0.6085788
	assign C[3]		= 25'h32FC9;		//  0.0248957
	
	// D
	assign D		= 25'h1FCD037;		// -0.0248957
	

endmodule

// Quantizer
module quantizer (
	input	[19: 0] in1,
	input			reset,
	input			clock,
	output			out1
);
	wire	[19: 0]	zoh_i;
	reg		[19: 0]	zoh_o;
	
	assign zoh_i	= in1;
		
	// Zero order hold at Ts
	always @(posedge clock) begin
		if (reset) begin
			zoh_o	<= 20'b0;
		end
		else begin
			zoh_o	<= zoh_i;
		end
	end
	
	// Quantize the output
	assign out1	= ~zoh_o[19];
endmodule
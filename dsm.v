`include "parameters.vh"
// Top level module
module DSM_top (
	input							clock,
	input							reset,
	input		[`T_BITS - 1: 0]	vin,
	input		[`T_BITS - 1: 0]	dith_i,
	output		[1: 0]				pwm	
);

	wire	[`T_BITS - 1: 0]	pwm_scaled;				// PWM * vin_FS/2	
	wire	[`T_BITS - 1: 0]	vin_pwm_scaled_delta;	// vin - pwm_scaled
	wire	[`T_BITS - 1: 0]	dss_o;
	wire	[`T_BITS - 1: 0]	dss_vin_sum;
	wire	[`T_BITS - 1: 0]	dss_vin_sum_dith;
	
	
	// Multiply by (VIN_FS/2) (bitshifted once)
	assign	pwm_scaled				= 	pwm == 2'b00	? `T_BITS'h0 	: 
										pwm == 2'b01	? `VIN_FS_HALF 	: `VIN_FS_HALF_NEG;
	// Assuming KFW is 1
	assign	vin_pwm_scaled_delta	= vin - pwm_scaled;
	// Sum DSS output with vin
	assign	dss_vin_sum				= dss_o + vin;
	// Dither the dss output summed with vin
	assign 	dss_vin_sum_dith		= dss_vin_sum + dith_i;	// dithering turned off
	
	
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
		.out1(pwm)
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
	input						clock,
	input						reset,
	input	[`T_BITS - 1: 0] 	u,
	output	[`T_BITS - 1: 0]	y
);

	wire signed	[10: 0] A0 	[3: 0];	// 11 bits, 2 dec, 9 frac
	wire signed	[9: 0]	C	[3: 0]; // 10 bits, 1 dec, 9 frac
	wire signed	[9: 0] 	D;			// 10 bits, 1 dec, 9 frac
	
	wire signed	[`T_BITS - 1: 0] 	xn1 [3: 0];
	reg	 signed	[`T_BITS - 1: 0]	xn0	[3: 0];
	wire signed	[`T_BITS + 10: 0] 	temp_xn1;
	wire signed [`T_BITS + 10: 0]	temp_y;
	
	
	wire signed	[`T_BITS + 10: 0] 	temp_y1;
	wire signed	[`T_BITS + 10: 0] 	temp_y2;
	wire signed	[`T_BITS + 10: 0] 	temp_y3;
	wire signed	[`T_BITS + 10: 0] 	temp_y4;
	wire signed	[`T_BITS + 10: 0] 	temp_y5;
	reg  signed	[`T_BITS + 10: 0] 	y1;
	reg  signed	[`T_BITS + 10: 0] 	y2;
	reg  signed	[`T_BITS + 10: 0] 	y3;
	reg  signed	[`T_BITS + 10: 0] 	y4;
	reg  signed	[`T_BITS + 10: 0] 	y5;
	
	always @ (posedge clock) begin
		if (reset) begin
			xn0[0]	<= 11'b0;
			xn0[1]	<= 11'b0;
			xn0[2]	<= 11'b0;
			xn0[3]	<= 11'b0;
			y1		<= 26'b0;
			y2		<= 26'b0;
			y3		<= 26'b0;
			y4		<= 26'b0;
			y5		<= 26'b0;
			
		end
		else begin
			xn0[0]	<= xn1[0];
			xn0[1]	<= xn1[1];
			xn0[2]	<= xn1[2];
			xn0[3]	<= xn1[3];
			y1		<= temp_y1;
			y2		<= temp_y2;
			y3		<= temp_y3;
			y4		<= temp_y4;
			y5		<= temp_y5;
		end
	end
	
	assign temp_xn1	= A0[1]*xn0[1];
	assign xn1[0]	= $signed(temp_xn1[`T_BITS + 8:9]) + $signed(u) - xn0[3];
	assign xn1[1]	= xn0[0];
	assign xn1[2]	= xn0[1];
	assign xn1[3]	= xn0[2];
	
	assign temp_y1	= C[0]*xn0[0];
	assign temp_y2	= C[1]*xn0[1];
	assign temp_y3	= C[2]*xn0[2];
	assign temp_y4	= C[3]*xn0[3];
	assign temp_y5	= D*$signed(u);
	assign temp_y	= y1 + y2 + y3 + y4 + y5;
	//assign temp_y = temp_y1 + temp_y2 + temp_y3 + temp_y4 + temp_y5;
	assign y		= temp_y[`T_BITS + 8: 9];

	
	// First row
	assign A0[0]	= 11'h0;		// -6.28113e-4 (supposed to be -6.28132e-04)
	assign A0[1]	= 11'h401;		// -1.99802649 (supposed to be -1.99802650)
	assign A0[2]	= 11'h0;		// same as A0[0]
	assign A0[3]	= 11'h600;		// -1


	
	// C	// 14 fractional bits
	assign C[0]		= 10'h23D;		// -0.8799698
	assign C[1]		= 10'h22;		//  0.0664163
	assign C[2]		= 10'h2C8;		// -0.6085788
	assign C[3]		= 10'hD;		//  0.0248957

	// D 	// 14 fractional bits
	assign D		= 10'h3F3;		// -0.0248957
	

endmodule

// Quantizer
module quantizer (
	input	[`T_BITS - 1: 0] in1,
	input			reset,
	input			clock,
	output	[1: 0]	out1
);
	wire signed	[`T_BITS: 0]	zoh_i;
	
	assign zoh_i	= $signed(in1) + $signed(`QUANT_OFF);
		

	// Quantize the output
//	assign out1	= ~zoh_o[19];
	assign out1	= 	(zoh_i < $signed(`QUANT_LOW)) 			? 2'b11 :
					(reset || zoh_i  < $signed(`QUANT_HIGH)) 	? 2'b00	: 2'b01 ;
endmodule
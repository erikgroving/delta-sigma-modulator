`include "parameters.vh"
// Top level module
module DSM_TOP (
	input							clock,
	input							reset,
	input		[`T_BITS - 1: 0]	vin,
	input		[`T_BITS - 1: 5]	dith_i,
	output reg		[1: 0]			pwm	
);

	reg		[14: 0]				vin_reg;
	wire	[`T_BITS - 1: 0]	pwm_scaled;				// PWM * vin_FS/2	
	wire	[`T_BITS - 1: 0]	vin_pwm_scaled_delta;	// vin - pwm_scaled
	wire	[9: 0]				dss_o;
	wire	[9: 0]				dss_vin_sum;
	wire	[9: 0]				dss_vin_sum_dith;
	wire	[1: 0]				quant_o;
	
	always @(posedge clock) begin
		if (reset) begin
			vin_reg	<= 15'b0;
			pwm		<= 2'b0;
		end
		else begin
			vin_reg	<= vin;
			pwm		<= quant_o;
		end
	end
	
	
	// Multiply by (VIN_FS/2) (bitshifted once)
	assign	pwm_scaled				= 	pwm == 2'b00	? `T_BITS'h0 	: 
										pwm == 2'b01	? `VIN_FS_HALF 	: `VIN_FS_HALF_NEG;
	// Assuming KFW is 1
	assign	vin_pwm_scaled_delta	= vin_reg - pwm_scaled;
	// Sum DSS output with vin
	assign	dss_vin_sum				= dss_o + vin_reg[14: 5];
	// Dither the dss output summed with vin
	assign 	dss_vin_sum_dith		= dss_vin_sum + dith_i[14:5];
	
	
	DSS DSS_I (
		.clock(clock),
		.reset(reset),
		.u(vin_pwm_scaled_delta),
		.y(dss_o)
	);
	
	QUANTIZER QUANTIZER_I (
		.in1(dss_vin_sum_dith[9: 6]),
		.reset(reset),
		.out1(quant_o)
	);
	

endmodule

module DSS (
	input						clock,
	input						reset,
	input	[`T_BITS - 1: 0] 	u,
	output	[9: 0]				y
);

	wire signed	[`T_BITS - 1: 0] 	xn1;
	reg	 signed	[`T_BITS - 1: 0]	xn0		[3: 0];
	wire		[`T_BITS + 10: 0]	s_xn0	[3: 0];
	wire 	 	[`T_BITS + 10: 0]	s_u;
	wire signed	[`T_BITS + 3 : 0] 	temp_xn1;
	wire signed [`T_BITS - 2: 0]	temp_y;	
	
	wire  		[`T_BITS + 10: 0]	temp_xn1_s_summand;	
	wire  		[`T_BITS + 8: 0] 	temp_y1_in [3: 0];
	wire  		[`T_BITS + 8: 0] 	temp_y2_in [1: 0];
	wire  		[`T_BITS + 8: 0] 	temp_y3_in [3: 0];
	wire  		[`T_BITS + 8: 0] 	temp_y4_in [1: 0];
	wire  		[`T_BITS + 8: 0] 	temp_y5_in [1: 0];
	
	wire signed	[`T_BITS + 2: 0] 	temp_y1;
	wire signed	[`T_BITS + 2: 0] 	temp_y2;
	wire signed	[`T_BITS + 2: 0] 	temp_y3;
	wire signed	[`T_BITS + 2: 0] 	temp_y4;
	wire signed	[`T_BITS + 2: 0] 	temp_y5;
	wire signed	[`T_BITS - 2: 0] 	y1;
	wire signed	[`T_BITS - 2: 0] 	y2;
	wire signed	[`T_BITS - 2: 0] 	y3;
	wire signed	[`T_BITS - 2: 0] 	y4;
	wire signed	[`T_BITS - 2: 0] 	y5;
	
	always @ (posedge clock) begin
		if (reset) begin
			xn0[0]	<= 11'b0;
			xn0[1]	<= 11'b0;
			xn0[2]	<= 11'b0;
			xn0[3]	<= 11'b0;
		end
		else begin
			xn0[0]	<= xn1;
			xn0[1]	<= xn0[0];
			xn0[2]	<= xn0[1];
			xn0[3]	<= xn0[2];

		end
	end
	assign y1		= $signed(temp_y1[`T_BITS + 2: 4]);
	assign y2		= $signed(temp_y2[`T_BITS + 2: 4]);
	assign y3		= $signed(temp_y3[`T_BITS + 2: 4]);
	assign y4		= $signed(temp_y4[`T_BITS + 2: 4]);
	assign y5		= $signed(temp_y5[`T_BITS + 2: 4]);	
	assign s_u		= {{11{u[`T_BITS - 1]}}, u};
	assign s_xn0[0]	= {{11{xn0[0][`T_BITS - 1]}}, xn0[0]};
	assign s_xn0[1]	= {{11{xn0[1][`T_BITS - 1]}}, xn0[1]};
	assign s_xn0[2]	= {{11{xn0[2][`T_BITS - 1]}}, xn0[2]};
	assign s_xn0[3]	= {{11{xn0[3][`T_BITS - 1]}}, xn0[3]};

	
	assign temp_xn1_s_summand = (s_xn0[1] << 10);
	
	assign temp_xn1	= $signed(s_xn0[1][`T_BITS + 10: 7]) - 
					  $signed(temp_xn1_s_summand[`T_BITS + 10: 7]);
	assign xn1	= $signed(temp_xn1[`T_BITS + 1:2]) + $signed(u) - xn0[3];
	
	
	assign temp_y1_in[0] = (s_xn0[0] << 8);
	assign temp_y1_in[1] = (s_xn0[0] << 7);
	assign temp_y1_in[2] = (s_xn0[0] << 6);
	assign temp_y1_in[3] = (s_xn0[0] << 1);	
	assign temp_y2_in[0] = (s_xn0[1] << 5);
	assign temp_y2_in[1] = (s_xn0[1] << 1);
	assign temp_y3_in[0] = (s_xn0[2] << 7);
	assign temp_y3_in[1] = (s_xn0[2] << 9);
	assign temp_y3_in[2] = (s_xn0[2] << 6);
	assign temp_y3_in[3] = (s_xn0[2] << 3);
	assign temp_y4_in[0] = (s_xn0[3] << 3);
	assign temp_y4_in[1] = (s_xn0[3] << 2);
	assign temp_y5_in[0] = (s_u << 3);
	assign temp_y5_in[1] = (s_u << 2);

	
	assign temp_y1 	= $signed(temp_y1_in[0][`T_BITS + 8: 8]) +
					  $signed(temp_y1_in[1][`T_BITS + 8: 8]) +
					  $signed(temp_y1_in[2][`T_BITS + 8: 8]) + 
					  $signed(temp_y1_in[3][`T_BITS + 8: 8]) + 
					  $signed(s_xn0[0][`T_BITS + 8: 8]);
	assign temp_y2 	= $signed(temp_y2_in[0][`T_BITS + 8: 8]) +
					  $signed(temp_y2_in[1][`T_BITS + 8: 8]);
	assign temp_y3 	= $signed(temp_y3_in[0][`T_BITS + 8: 8]) -
					  $signed(temp_y3_in[1][`T_BITS + 8: 8]) +
					  $signed(temp_y3_in[2][`T_BITS + 8: 8]) +
					  $signed(temp_y3_in[3][`T_BITS + 8: 8]);					 
	assign temp_y4 	= $signed(temp_y4_in[0][`T_BITS + 8: 8]) +
					  $signed(temp_y4_in[1][`T_BITS + 8: 8]) +
					  $signed(s_xn0[3][`T_BITS + 8: 8]);
	assign temp_y5 	= $signed(temp_y5_in[0][`T_BITS + 8: 8]) +
					  $signed(temp_y5_in[1][`T_BITS + 8: 8]) +
					  $signed(s_u[`T_BITS + 8: 8]);
	assign temp_y  	= y2 - y1 + y3 + y4 - y5;
	assign y		= temp_y[11: 2];

endmodule

// Quantizer
module QUANTIZER (
	input	[3: 0] in1,
	input			reset,
	output	[1: 0]	out1
);

	// Quantize the output
	assign out1	= 	($signed(in1) < $signed(`QUANT_LOW)) 			? 2'b11 :
					(reset || $signed(in1)  < $signed(`QUANT_HIGH)) ? 2'b00	: 2'b01 ;
endmodule
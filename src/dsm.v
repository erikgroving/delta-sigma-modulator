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

module DSS (
	input						clock,
	input						reset,
	input	[`T_BITS - 1: 0] 	u,
	output	[`T_BITS - 1: 0]	y
);

	wire signed	[`T_BITS - 1: 0] 	xn1 	[3: 0];
	reg	 signed	[`T_BITS - 1: 0]	xn0		[3: 0];
	wire signed	[`T_BITS + 10: 0]	s_xn0	[3: 0];
	wire signed [`T_BITS + 10: 0]	s_u;
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
	
	assign s_u		= {{11{u[`T_BITS - 1]}}, u};
	assign s_xn0[0]	= {{11{xn0[0][`T_BITS - 1]}}, xn0[0]};
	assign s_xn0[1]	= {{11{xn0[1][`T_BITS - 1]}}, xn0[1]};
	assign s_xn0[2]	= {{11{xn0[2][`T_BITS - 1]}}, xn0[2]};
	assign s_xn0[3]	= {{11{xn0[3][`T_BITS - 1]}}, xn0[3]};
	
	assign temp_xn1	= s_xn0[1] - (s_xn0[1] << 10);
	assign xn1[0]	= $signed(temp_xn1[`T_BITS + 8:9]) + $signed(u) - xn0[3];
	assign xn1[1]	= xn0[0];
	assign xn1[2]	= xn0[1];
	assign xn1[3]	= xn0[2];

	
	assign temp_y1	= (s_xn0[0] << 8) + (s_xn0[0] << 7) +
					  (s_xn0[0] << 6) + (s_xn0[0] << 1) + s_xn0[0];
	assign temp_y2	= (s_xn0[1] << 5) + (s_xn0[1] << 1);
	assign temp_y3	= (s_xn0[2] << 7) - (s_xn0[2] << 9) +
					  (s_xn0[2] << 6) + (s_xn0[2] << 3);
	assign temp_y4	= (s_xn0[3] << 3) + (s_xn0[3] << 2) + s_xn0[3];
	assign temp_y5	= (s_u << 3) + (s_u << 2) + s_u;

	assign temp_y	= y2 - y1 + y3 + y4 - y5;
	assign y		= temp_y[`T_BITS + 8: 9];

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
	assign out1	= 	(zoh_i < $signed(`QUANT_LOW)) 				? 2'b11 :
					(reset || zoh_i  < $signed(`QUANT_HIGH)) 	? 2'b00	: 2'b01 ;
endmodule
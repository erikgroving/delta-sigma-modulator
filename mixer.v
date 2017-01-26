// This doesn't need to be its own module
module mixer (
	input	[19: 0]	interp_i,
	input	[19: 0] LO,
	output	[19: 0] mix_o
);

	wire signed [24: 0] ampl;
	
	assign ampl = 25'h028_619a;	// 0.6309573 * 0.5 = 0.3154786
	
	assign mix_o = ampl * $signed(interp_i) * $signed(LO);
	
	

endmodule
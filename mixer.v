// This doesn't need to be its own module, by the way
module mixer (
	input	[19: 0]	interp_i,
	input	[19: 0] LO,
	output	[19: 0] mix_o
);
	wire signed [39: 0] mult_res;
	
	assign mult_res = LO * interp_i;
	// Since ampl = -4, and gain of 0.5, we multiply by -2, 
	// which can be done by bitshifting left once, and then
	// negating (15 bits originally, only shift right 14)
	assign mix_o = -(mult_res[33:14]);
endmodule
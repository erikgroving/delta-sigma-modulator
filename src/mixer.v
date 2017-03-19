// This doesn't need to be its own module

// So I'm a little worried about synthesis times
// in this module. The reason being is that the
// there are two multiplies, first in input * LO,
// next is that result * ampl/2. This means that there
// are two serial multiplies, and multiplies are expensive.
// If this synthesizes at a bad clock period, I can make the
// ampl multiply a bitshift-sum operation.
`include "parameters.vh"
module mixer (
	input	[14: 0]	interp_i,
	input	[1: 0] 				LO,
	output	[14: 0]	mix_o
);

	wire signed [14: 0] ampl;
	wire signed [14: 0] inter_res;
	wire signed	[29: 0] mix_res;
	
	assign ampl = 15'h2861;	// 0.6309573 * 0.5 = 0.3154786 (15 fractional bits)
	
	assign inter_res	= 	LO[1] ? -interp_i :
							LO[0] ? interp_i : 15'b0;
							
	assign mix_res		= inter_res * ampl;
	assign mix_o		= mix_res[29: 15];

endmodule
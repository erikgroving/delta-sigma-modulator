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

	wire signed [14: 0] inter_res;
	wire signed [29: 0] se_inter_res; 			// sign extend
	wire signed	[29: 0] sl_inter_res [4: 0];	// shift left
	wire signed	[22: 0] mix_res;
	
	//assign ampl = 15'h2861;	// 0.6309573 * 0.5 = 0.3154786 (15 fractional bits)
	
	assign inter_res		= 	LO[1] ? $signed(-interp_i) 	:
								LO[0] ? $signed(interp_i) 	: 15'b0;
	assign se_inter_res		= 	$signed({{15{inter_res[14]}}, inter_res});
	assign sl_inter_res[0]	= 	se_inter_res << 13;
	assign sl_inter_res[1]	=	se_inter_res << 11;
	assign sl_inter_res[2]	=	se_inter_res << 6;
	assign sl_inter_res[3]	= 	se_inter_res << 5;
	assign sl_inter_res[4]	=	se_inter_res;

							
	assign mix_res			= 	$signed(sl_inter_res[0][29: 7]) + 
								$signed(sl_inter_res[1][29: 7]) + 
								$signed(sl_inter_res[2][29: 7]) + 
								$signed(sl_inter_res[3][29: 7]) +
								$signed(sl_inter_res[4][29: 7]);
	assign mix_o			= 	mix_res[22: 8];

endmodule
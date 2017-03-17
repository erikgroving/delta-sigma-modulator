module mixer_iq (
	input	[14: 0]	mixin_i,
	input	[14: 0]	mixin_q,
	input	[1: 0] LO_i,
	input	[1: 0] LO_q,
	output	[14: 0] mix_o
);

	wire signed [14: 0] ampl;
	wire signed [14: 0] inter_res_i;
	wire signed [14: 0] inter_res_q;
	wire signed	[29: 0] mix_res_i;
	wire signed	[29: 0] mix_res_q;
	
	assign ampl = 15'h2861;	// 0.6309573 * 0.5 = 0.3154786
	
	
	//i
	assign inter_res_i	= 	LO_i[1] ? -mixin_i :
							LO_i[0] ? mixin_i : 15'b0;	
	assign mix_res_i		= inter_res_i * ampl;
	
	
	//q
	assign inter_res_q	= 	LO_q[1] ? -mixin_q :
							LO_q[0] ? mixin_q : 15'b0;			
	assign mix_res_q		= inter_res_q * ampl;
	
	
	
	
	// sum up
	assign mix_o		= $signed(mix_res_q[29:15])+$signed(mix_res_i[29:15]); //may overflow here? please check:)

endmodule

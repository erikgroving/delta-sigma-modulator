module mixer_iq (
	input	[10: 0]	mixin_i,
	input	[10: 0]	mixin_q,
	input	[1: 0] LO_i,
	input	[1: 0] LO_q,
	output	[10: 0] mix_o
);

	wire signed [10: 0] ampl;
	wire signed [10: 0] inter_res_i;
	wire signed [10: 0] inter_res_q;
	wire signed	[21: 0] mix_res_i;
	wire signed	[21: 0] mix_res_q;
	
	assign ampl = 11'hA1;	// 0.6309573 * 0.5 = 0.3154786
	
	
	//i
	assign inter_res_i	= 	LO_i[1] ? -mixin_i :
							LO_i[0] ? mixin_i : 11'b0;	
	assign mix_res_i		= inter_res_i * ampl;
	
	
	//q
	assign inter_res_q	= 	LO_q[1] ? -mixin_q :
							LO_q[0] ? mixin_q : 11'b0;			
	assign mix_res_q		= inter_res_q * ampl;
	
	
	
	
	// sum up
	assign mix_o		= $signed(mix_res_q[19:9])+$signed(mix_res_i[19:9]); //may overflow here? please check:)

endmodule

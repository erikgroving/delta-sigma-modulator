module mixer_iq (
	input           clock,
	input           reset,
	input	[14: 0]	mixin_i,
	input	[14: 0]	mixin_q,
	input	[1: 0] LO_i,
	input	[1: 0] LO_q,
	output	reg [14: 0] mix_o
);

	wire  		[14: 0] inter_res_i;
	wire signed [29: 0] se_inter_res_i; 			// sign extend
	wire signed	[29: 0] sl_inter_res_i [4: 0];	// shift left	
	wire signed [29: 0] se_inter_res_q; 			// sign extend
	wire signed	[29: 0] sl_inter_res_q [4: 0];	// shift left
	wire  		[14: 0] inter_res_q;
	wire signed	[22: 0] mix_res_i;
	wire signed	[22: 0] mix_res_q;
	wire		[14: 0] mix_tmp;
	
	//assign ampl = 15'h2861;	// 0.6309573 * 0.5 = 0.3154786
	
	
	//i
	assign inter_res_i = 	LO_i[1] ? -mixin_i 	:
							LO_i[0] ? mixin_i 	: 15'b0;	
							
	assign se_inter_res_i	 = 	$signed({{15{inter_res_i[14]}}, inter_res_i});
	assign sl_inter_res_i[0] = 	se_inter_res_i << 13;
	assign sl_inter_res_i[1] =	se_inter_res_i << 11;
	assign sl_inter_res_i[2] =	se_inter_res_i << 6;
	assign sl_inter_res_i[3] = 	se_inter_res_i << 5;
	assign sl_inter_res_i[4] =	se_inter_res_i;
	
	assign mix_res_i = 	$signed(sl_inter_res_i[0][29: 7]) + 
						$signed(sl_inter_res_i[1][29: 7]) + 
						$signed(sl_inter_res_i[2][29: 7]) + 
						$signed(sl_inter_res_i[3][29: 7]) +
						$signed(sl_inter_res_i[4][29: 7]);	
	
	//q
	assign inter_res_q	= 	LO_q[1] ? -mixin_q 	:
							LO_q[0] ? mixin_q 	: 15'b0;			
	
	assign se_inter_res_q	 = 	$signed({{15{inter_res_q[14]}}, inter_res_q});

	assign sl_inter_res_q[0] = 	se_inter_res_q << 13;
	assign sl_inter_res_q[1] =	se_inter_res_q << 11;
	assign sl_inter_res_q[2] =	se_inter_res_q << 6;
	assign sl_inter_res_q[3] = 	se_inter_res_q << 5;
	assign sl_inter_res_q[4] =	se_inter_res_q;
	
	assign mix_res_q = 	$signed(sl_inter_res_q[0][29: 7]) + 
						$signed(sl_inter_res_q[1][29: 7]) + 
						$signed(sl_inter_res_q[2][29: 7]) + 
						$signed(sl_inter_res_q[3][29: 7]) +
						$signed(sl_inter_res_q[4][29: 7]);	

	assign mix_tmp		= mix_res_q[22:8]+mix_res_i[22:8]; 

	always_ff @(posedge clock) begin
		if (reset)
			mix_o <= 'b0;
		else
			mix_o <= mix_tmp;
	end


endmodule

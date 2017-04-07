module PHASESHIFT (
	input			clock,
	input 			reset,
	input 	[9: 0] sysin_i,
	input 	[9: 0] sysin_q,
	
	input 	[4: 0]  w_cos_1,
	input 	[4: 0]  w_sin_1,
	input 	[4: 0]  w_cos_2,
	input 	[4: 0]  w_sin_2, //bit depth for the w coefficients are pending, maybe 5 ot 6 bits
	output reg	[14: 0] out_i,
	output reg	[14: 0] out_q
);

	wire		[14: 0] out_i_w;
	wire 		[14: 0] out_q_w;

	wire signed [19: 0] ii_1;
	wire signed [19: 0] iq_1;
	wire signed [19: 0] qi_1;
	wire signed [19: 0] qq_1;

	wire signed [19: 0] ii_2;
	wire signed [19: 0] iq_2;
	wire signed [19: 0] qi_2;
	wire signed [19: 0] qq_2;
					 
	wire signed [20: 0] i_cwm_1;
	wire signed [20: 0] q_cwm_1;
	wire signed [20: 0] i_cwm_2;
	wire signed [20: 0] q_cwm_2;
					 
	wire signed [21: 0] out_i_sat;
	wire signed [21: 0] out_q_sat;
		
		//implement adder in phaseShift

	//for beam 1
	assign ii_1 = $signed(sysin_i) * $signed(w_cos_1);
	assign iq_1 = $signed(sysin_i) * $signed(w_sin_1);
	assign qi_1 = $signed(sysin_q) * $signed(w_cos_1);
	assign qq_1 = $signed(sysin_q) * $signed(w_sin_1);
	assign i_cwm_1 = ii_1 + qq_1;
	assign q_cwm_1 = qi_1 - iq_1;


	//for beam 2
	assign ii_2 = $signed(sysin_i) * $signed(w_cos_2);
	assign iq_2 = $signed(sysin_i) * $signed(w_sin_2);
	assign qi_2 = $signed(sysin_q) * $signed(w_cos_2);
	assign qq_2 = $signed(sysin_q) * $signed(w_sin_2);
	assign i_cwm_2 = ii_2 + qq_2;
	assign q_cwm_2 = qi_2 - iq_2;

	//sum them up, the adder is implemented here in phaseshift module
	assign out_i_sat = i_cwm_1 + i_cwm_2;
	assign out_q_sat = q_cwm_1 + q_cwm_2;
	
	
	// Check saturation and then assign output
	// positive check then negative check, if neither were true, then set to bottom 20 bits
	assign out_i_w = 	{out_i_sat[21], |out_i_sat[20:14]} == 2'b01	?	15'h3FFF : 
						{out_i_sat[21], &out_i_sat[20:14]} == 2'b10	?	15'h4000 :  out_i_sat[14: 0];

	assign out_q_w =	{out_q_sat[21], |out_q_sat[20:14]} == 2'b01	?	15'h3FFF : 
						{out_q_sat[21], &out_q_sat[20:14]} == 2'b10	?	15'h4000 :  out_q_sat[14: 0] ;

	// synopsys sync_set_reset "reset"	
	always_ff @(posedge clock) begin
		if (reset) begin 
			out_i	<= 15'b0;
			out_q	<= 15'b0;
		end
		else begin
			out_i	<= out_i_w;
			out_q	<= out_q_w;
		end
	end
					
					
endmodule

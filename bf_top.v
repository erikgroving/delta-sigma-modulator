module bf_top (

  input			clock,
  input			reset,
  input	[7: 0]	vin_i_1,//all of the four vin should be 8 bits instead
  input [7: 0] 	vin_q_1,//all of the four vin should be 8 bits instead
  input	[7: 0]	vin_i_2,//all of the four vin should be 8 bits instead
  input [7: 0] 	vin_q_2,//all of the four vin should be 8 bits instead

//Probably need to change to 5 or 6 bits	
  input [4: 0]  w_cos_1 [7: 0],
  input [4: 0]  w_sin_1 [7: 0],                           
  input [4: 0]  w_cos_2 [7: 0],                           
  input [4: 0]  w_sin_2 [7: 0],  
  output [1: 0]	pwm [7: 0]
);


//LO_i and LO_q are needed to be given here in top

wire [19:0] out_i [7:0];
wire [19:0] out_q [7:0];
wire [19:0] mix_o [7:0];

wire [19: 0] interp_o_i_1;
wire [19: 0] interp_o_q_1;
wire [19: 0] interp_o_i_2;
wire [19: 0] interp_o_q_2;


////////////////////////interp:need to be modified for 8 bit input.../////////////////////////////////
						// has been modified for 8 bit input, still 20 bit output
//beam one
	interp interp_i_1 (
		.clock(clock),
		.reset(reset),
		.v_in(vin_i_1),
		
		.interp_o(interp_o_i_1)
	);
	
	//beam one
	interp interp_q_1 (
		.clock(clock),
		.reset(reset),
		.v_in(vin_q_1),
		
		.interp_o(interp_o_q_1)
	);
	
	//beam two
	interp interp_i_2 (
		.clock(clock),
		.reset(reset),
		.v_in(vin_i_2),
		
		.interp_o(interp_o_i_2)
	);
	
	//beam two
	interp interp_q_2 (
		.clock(clock),
		.reset(reset),
		.v_in(vin_q_2),
		
		.interp_o(interp_o_q_2)
	);
	
	///////////////////////////////dith gen////////////////////////////////////////////////////////////
	lfsr lfsr (
		.clock(clock),
		.reset(reset),
		.dith_o(dith)
	);                       //I think one lfsr is enough
	
	
	genvar i;
	generate 
		for (i = 0; i < 8; i=i+1) begin
			phaseShift phaseShift_i (
			   .interp_o_i_1(interp_o_i_1),
			   .interp_o_q_1(interp_o_q_1),
			   .interp_o_i_2(interp_o_i_2),
			   .interp_o_q_2(interp_o_q_2),
			   .w_cos_1(w_cos_1[i]),
			   .w_sin_1(w_sin_1[i]),
			   .w_cos_2(w_cos_2[i]),
			   .w_sin_2(w_sin_2[i]),
			   
			   .out_i(out_i[i]),
			   .out_q(out_q[i])				
			);
			
			mixer_iq mixer_iq_i (
				.mixin_i(out_i[i]),
				.mixin_q(out_q[i]), 
				.LO_i(LO_i),          // 1, 0, -1, 0
				.LO_q(LO_q),          // 0, 1, 0 ,-1
				.mix_o(mix_o[i])
			); 
 			
			DSM_top dsm_i (
				.clock(clock),
				.reset(reset),
				.vin(mix_o[i]),
				.dith_i(dith),
				.pwm(pwm[i])
			);    			
		end	
	endgenerate
endmodule

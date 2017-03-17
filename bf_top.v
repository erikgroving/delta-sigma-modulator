module bf_top (

  input			clock,
  input			reset,
  input	[7: 0]	vin_i_1,
  input [7: 0] 	vin_q_1,
  input	[7: 0]	vin_i_2,
  input [7: 0] 	vin_q_2,

	
// Changed to 5 bits
  input [4: 0]  w_cos_1 [7: 0],
  input [4: 0]  w_sin_1 [7: 0],                           
  input [4: 0]  w_cos_2 [7: 0],                           
  input [4: 0]  w_sin_2 [7: 0],  
  output [1: 0]	pwm [7: 0]
);


	wire [19:0] out_i [7:0];
	wire [19:0] out_q [7:0];
	wire [19:0] mix_o [7:0];

	wire [19:0] dith;
	
	wire [19: 0] interp_o_i;
	wire [19: 0] interp_o_q;


	wire	[1: 0] 	LO_i;
	wire	[1: 0]	LO_q;
	reg		[1: 0] 	LO_cnt;
	
	
	assign	LO_i = 	LO_cnt[0]		? 2'b00 :			// 1 --> 0 --> -1 --> 0
					~LO_cnt[1] 		? 2'b01 : 2'b10;
	assign	LO_q =	~LO_cnt[0]		? 2'b00 :			// 0 --> 1 --> 0 --> -1
					~LO_cnt[1]		? 2'b01 : 2'b10;	
	
	always @(posedge clock) begin
		if (reset) begin
			LO_cnt	<= 2'b0;
		end
		else begin
			LO_cnt	<= LO_cnt + 1'b1;
		end
	end
	

	
	lfsr lfsr (
		.clock(clock),
		.reset(reset),
		.dith_o(dith)
	);                       //I think one lfsr is enough
	
	
	genvar i;
	generate 
		for (i = 0; i < 8; i=i+1) begin
			phaseShift phaseShift_i (
			   .sysin_i_1(vin_i_1),
			   .sysin_q_1(vin_q_1),
			   .sysin_i_2(vin_i_2),
			   .sysin_q_2(vin_q_2),
			   .w_cos_1(w_cos_1[i]),
			   .w_sin_1(w_sin_1[i]),
			   .w_cos_2(w_cos_2[i]),
			   .w_sin_2(w_sin_2[i]),
			   
			   .out_i(out_i[i]),
			   .out_q(out_q[i])				
			);

			interp interp_i (
				.clock(clock),
				.reset(reset),
				.v_in(out_i[i])),
		
				.interp_o(interp_o_i)
			);
			
			interp interp_q (
				.clock(clock),
				.reset(reset),
				.v_in(out_q[i]),
		
				.interp_o(interp_o_q)
			);
			
			mixer_iq mixer_iq_i (
				.mixin_i(interp_o_i),
				.mixin_q(interp_o_q), 
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

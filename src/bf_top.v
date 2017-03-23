module bf_top (

  input			clock,
  input			reset,
  input	[9: 0]	vin_i,
  input [9: 0] 	vin_q,


	
// Changed to 5 bits
  input [4: 0]  w_cos_1 [7: 0],
  input [4: 0]  w_sin_1 [7: 0],                           
  input [4: 0]  w_cos_2 [7: 0],                           
  input [4: 0]  w_sin_2 [7: 0],  
  output [1: 0]	pwm [7: 0]
);


	wire [14:0] out_i [7:0];
	wire [14:0] out_q [7:0];
	wire [14:0] mix_o [7:0];

	wire [14:0] dith;

	wire [14: 0] interp_o_i [7: 0];
	wire [14: 0] interp_o_q [7: 0];
	
	reg  [9: 0]		vin_i_sync [1: 0];
	reg  [9: 0]		vin_q_sync [1: 0];
	wire [14: 0]	sysin_i;
	wire [14: 0]	sysin_q;

	
	always @(posedge clock) begin
		if (reset) begin
			vin_i_sync[0]	<= 20'b0;
			vin_i_sync[1]	<= 20'b0;
			vin_q_sync[0]	<= 20'b0;
			vin_q_sync[1]	<= 20'b0;
		end
		else begin
			vin_i_sync[0]	<= vin_i;
			vin_i_sync[1]	<= vin_i_sync[0];
			vin_q_sync[0]	<= vin_q;
			vin_q_sync[1]	<= vin_q_sync[0];
		end
	end
	
	
	
	assign sysin_i	= {{5{vin_i[9]}}, vin_i_sync[1]};
	assign sysin_q	= {{5{vin_q[9]}}, vin_q_sync[1]};
	

	
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
			   .clock(clock),
			   .reset(reset),
			   .sysin_i(sysin_i),
			   .sysin_q(sysin_q),
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
				.v_in(out_i[i]),
				
				.interp_o(interp_o_i[i])
			);
			
			interp interp_q (
				.clock(clock),
				.reset(reset),
				.v_in(out_q[i]),
		
				.interp_o(interp_o_q[i])
			);
			
			mixer_iq mixer_iq_i (
				.clock(clock),
				.reset(reset),
				.mixin_i(interp_o_i[i]),
				.mixin_q(interp_o_q[i]), 
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

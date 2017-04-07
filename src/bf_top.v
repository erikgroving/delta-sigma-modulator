module BF_TOP (
  input			CLOCK,
  input			RESET,
  input			SCLK,
  input			SS,
  input			MOSI,
  input	[9: 0]	VIN_I,
  input [9: 0] 	VIN_Q,
  output [7: 0][1: 0] PWM 
);



	wire [7: 0][4: 0]  w_cos_1;
	wire [7: 0][4: 0]  w_sin_1;                          
	wire [7: 0][4: 0]  w_cos_2;                          
	wire [7: 0][4: 0]  w_sin_2; 
	
	// synchronizers
	reg [7: 0][4: 0]  w_cos_1_sync_1;
	reg [7: 0][4: 0]  w_sin_1_sync_1;                          
	reg [7: 0][4: 0]  w_cos_2_sync_1;                          
	reg [7: 0][4: 0]  w_sin_2_sync_1; 	
	reg [7: 0][4: 0]  w_cos_1_sync_2;
	reg [7: 0][4: 0]  w_sin_1_sync_2;                          
	reg [7: 0][4: 0]  w_cos_2_sync_2;                          
	reg [7: 0][4: 0]  w_sin_2_sync_2; 	

	reg					ps_clock;
	reg	[2: 0]			ps_clock_cnt;

	wire [7: 0][14:0] 	out_i;
	wire [7: 0][14:0] 	out_q;
	wire [7: 0][14:0] 	mix_o;

	wire [14: 5] 		dith;

	wire [7: 0][14: 0] 	interp_o_i;
	wire [7: 0][14: 0] 	interp_o_q;
	
	reg  [1: 0][9: 0]	vin_i_sync;
	reg  [1: 0][9: 0]	vin_q_sync;
	wire [9: 0]			sysin_i;
	wire [9: 0]			sysin_q;

	always @(posedge CLOCK) begin
		if (RESET) begin
			ps_clock_cnt	<= 3'b0;
		end
		else begin
			ps_clock_cnt	<= ps_clock_cnt + 1'b1;
		end
		
		ps_clock	<= (ps_clock_cnt > 3'd3);
	end
	
	
	always @(posedge ps_clock) begin
		if (RESET) begin
			vin_i_sync[0]	<= 20'b0;
			vin_i_sync[1]	<= 20'b0;
			vin_q_sync[0]	<= 20'b0;
			vin_q_sync[1]	<= 20'b0;
			w_cos_1_sync_1	<= 40'b0;
			w_cos_1_sync_2	<= 40'b0;
			w_sin_1_sync_1	<= 40'b0;
			w_sin_1_sync_2	<= 40'b0;
			w_cos_2_sync_1	<= 40'b0;
			w_cos_2_sync_2	<= 40'b0;
			w_sin_2_sync_1	<= 40'b0;
			w_sin_2_sync_2	<= 40'b0;
		end
		else begin
			vin_i_sync[0]	<= VIN_I;
			vin_i_sync[1]	<= vin_i_sync[0];
			vin_q_sync[0]	<= VIN_Q;
			vin_q_sync[1]	<= vin_q_sync[0];			
			w_cos_1_sync_1	<= w_cos_1;
			w_cos_1_sync_2	<= w_cos_1_sync_1;
			w_sin_1_sync_1	<= w_sin_1;
			w_sin_1_sync_2	<= w_sin_1_sync_1;
			w_cos_2_sync_1	<= w_cos_2;
			w_cos_2_sync_2	<= w_cos_2_sync_1;
			w_sin_2_sync_1	<= w_sin_2;
			w_sin_2_sync_2	<= w_sin_2_sync_1;
		end
	end
	
	assign sysin_i	= vin_i_sync[1];
	assign sysin_q	= vin_q_sync[1];	
	
	
	wire	[1: 0] 	LO_i;
	wire	[1: 0]	LO_q;
	reg		[1: 0] 	LO_cnt;
	
	
	assign	LO_i = 	LO_cnt[0]		? 2'b00 :			// 1 --> 0 --> -1 --> 0
					~LO_cnt[1] 		? 2'b01 : 2'b10;
	assign	LO_q =	~LO_cnt[0]		? 2'b00 :			// 0 --> 1 --> 0 --> -1
					~LO_cnt[1]		? 2'b01 : 2'b10;	
	
	always @(posedge CLOCK) begin
		if (RESET) begin
			LO_cnt	<= 2'b0;
		end
		else begin
			LO_cnt	<= LO_cnt + 1'b1;
		end
	end
	

	
	LFSR LFSR_I (
		.clock(CLOCK),
		.reset(RESET),
		.dith_o(dith)
	);                       //I think one lfsr is enough
	
	SPI SPI_I (
		.SCLK(SCLK),
		.MOSI(MOSI),
		.ss(SS),
		.reset(RESET),
		.w_cos_1(w_cos_1),
		.w_sin_1(w_sin_1),
		.w_cos_2(w_cos_2),
		.w_sin_2(w_sin_2)
	);

	
	
	
	genvar i;
	generate 
		for (i = 0; i < 8; i=i+1) begin
			PHASESHIFT PHASESHIFT_I (
			   .clock(ps_clock),
			   .reset(RESET),
			   .sysin_i(sysin_i),
			   .sysin_q(sysin_q),
			   .w_cos_1(w_cos_1_sync_2[i]),
			   .w_sin_1(w_sin_1_sync_2[i]),
			   .w_cos_2(w_cos_2_sync_2[i]),
			   .w_sin_2(w_sin_2_sync_2[i]),
			   
			   .out_i(out_i[i]),
			   .out_q(out_q[i])				
			);

			
			INTERPOLATE INTERPOLATE_I (
				.clock(CLOCK),
				.ps_clock(ps_clock),
				.reset(RESET),
				.v_in(out_i[i]),
				
				.interp_o(interp_o_i[i])
			);
			
			INTERPOLATE INTERPOLATE_Q (
				.clock(CLOCK),
				.ps_clock(ps_clock),
				.reset(RESET),
				.v_in(out_q[i]),
		
				.interp_o(interp_o_q[i])
			);
			
			MIXER_IQ MIXER_IQ_I (
				.clock(CLOCK),
				.reset(RESET),
				.mixin_i(interp_o_i[i]),
				.mixin_q(interp_o_q[i]), 
				.LO_i(LO_i),          // 1, 0, -1, 0
				.LO_q(LO_q),          // 0, 1, 0 ,-1
				.mix_o(mix_o[i])
			); 
 			
			DSM_TOP DSM_I (
				.clock(CLOCK),
				.reset(RESET),
				.vin(mix_o[i]),
				.dith_i(dith),
				.pwm(PWM[i])
			);    			
		end	
	endgenerate
endmodule

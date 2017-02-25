module dsm_top (
	input			clock,
	input			reset,
	input	[19: 0]	dith_i,
	input	[19: 0]	vin,
	output	[1: 0]	pwm
);

	wire	[1: 0] 	LO;
	reg		[1: 0] 	LO_cnt;
	wire	[19: 0]	interp_o;
	wire	[19: 0] mix_o;
	
	
	assign	LO	= 	LO_cnt[0]		? 2'b00 :
					~LO_cnt[1] 		? 2'b01 : 2'b10;
	
	always @(posedge clock) begin
		if (reset) begin
			LO_cnt	<= 2'b0;
		end
		else begin
			LO_cnt	<= LO_cnt + 1'b1;
		end
	end

	interp interp_i (
		.clock(clock),
		.reset(reset),
		.v_in(vin),
		.interp_o(interp_o)
	);
	
	mixer mixer_i (
		.interp_i(interp_o), 
		//.interp_i(vin),
		.LO(LO),
		.mix_o(mix_o)
	);
	
	
	DSM_top dsm_i (
		.clock(clock),
		.reset(reset),
		.vin(mix_o),
		.dith_i(dith_i),
		.pwm(pwm)
	);

endmodule
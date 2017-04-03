`include "parameters.vh"

module dsm_top (
	input			clock,
	input			reset,
	input	[14: 0]	vin,
	output	[1: 0]	pwm
);

	wire	[1: 0] 				LO;
	reg		[1: 0] 				LO_cnt;
	wire	[`T_BITS - 1: 0]	interp_o;
	wire	[`T_BITS - 1: 0] 	mix_o;	
	wire	[`T_BITS - 1: 5]	dith;
	reg		[`T_BITS - 1: 0]	vin_sync [1: 0];
	
	always @(posedge clock) begin
		if (reset) begin
			vin_sync[0]	<= 15'b0;
			vin_sync[1]	<= 15'b0;
		end
		else begin
			vin_sync[0]	<= vin;
			vin_sync[1]	<= vin_sync[0];
		end
	end
	
	
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
		.v_in(vin_sync[1]),
		.interp_o(interp_o)
	);
	
	mixer mixer_i (
		.interp_i(interp_o), 
		.LO(LO),
		.mix_o(mix_o)
	);
	
	lfsr lfsr_i (
		.clock(clock),
		.reset(reset),
		.dith_o(dith)
	);
	
	
	DSM_top dsm_i (
		.clock(clock),
		.reset(reset),
		.vin(mix_o),
		.dith_i(dith),
		.pwm(pwm)
	);

endmodule
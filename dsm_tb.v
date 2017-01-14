module  dsm_tb ();

	reg 		clock;
	reg 		reset;
	reg	[19: 0] vin;
	wire		pwm;

	dsm dsm_i (
		.clock(clock),
		.reset(reset),
		.vin(vin),
		.pwm(pwm)
	);
	
	always begin
		#5;
		clock	= ~clock;
	end
	
	initial begin
		clock = 0;
		reset = 0;
		vin	= 20'b0;
		#5;
		reset = 1;
		#20;
		reset = 0;
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		@(negedge clock);
		vin	=
		
	end

endmodule
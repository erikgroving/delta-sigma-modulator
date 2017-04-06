module LFSR_TB (

);

	reg					clock;
	reg 				reset;
	wire signed [19: 0]	lfsr;
	
	integer lfsr_out;
	
	
	LFSR LFSR_I(
		.clock(clock),
		.reset(reset),
		.lfsr_o(lfsr)
	);
	
	always begin
		#5;
		clock = ~clock;
	end
	
	initial begin
		clock = 1'b0;
		reset = 1'b1;
		lfsr_out = $fopen("../lfsr_out.txt", "w");
		@(posedge clock);
		#1;
		reset = 1'b0;
		#5000000;
		$fclose(lfsr_out);
		$finish;
	end
		
	always @(negedge clock) begin
		if (!reset) begin
			$fdisplay(lfsr_out, "%d", lfsr);
		end
	end
		
endmodule
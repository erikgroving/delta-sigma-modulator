module  dsm_tb ();

	reg 		clock;
	reg 		reset;
	reg	[19: 0] vin;
	wire		pwm;
	
	integer data_file;
	integer scan_file;

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
		data_file = $fopen("vin_bin.txt", "r");
		if (data_file == 0) begin
			$display("could not open data file");
			$finish;
		end
		#5;
		reset = 1;
		#20;
		reset = 0;
	end

	always @(negedge clock) begin
		if (reset) begin
			vin	<= 20'b0;
		end
		else begin
			scan_file = $fscanf(data_file, "%b\n", vin); 
			if ($feof(data_file)) begin
				$display("reached end of file");
				$finish;
			end
		end
	end
	
endmodule
module  dsm_tb ();

	reg 		clock;
	reg 		reset;
	reg	[19: 0] vin;
	wire		pwm;
	
	integer data_file;
	integer scan_file;
	integer write_file;

	DSM_top dsm_i (
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
		reset = 1;
		data_file = $fopen("vin_bin.txt", "r");
		write_file = $fopen("pwm.txt", "w");
		if (data_file == 0) begin
			$display("could not open data file");
			$finish;
		end
		#20;
		@(posedge clock);
		reset = #1 0;
	end

	always @(negedge clock) begin
		if (reset) begin
			vin	<= 20'b0;
		end
		else begin
			$fdisplay(write_file, "%01b", pwm);
			scan_file = $fscanf(data_file, "%b\n", vin); 
			if ($feof(data_file)) begin
				$fclose(write_file);
				$fclose(scan_file);
				$finish;
			end
		end
	end
	
endmodule
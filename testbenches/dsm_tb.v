module  dsm_tb ();

	reg 		clock;
	reg 		reset;
	reg	[10: 0] vin;
	wire [1: 0]	pwm;
	
	integer data_file;
	integer scan_file;
	integer write_file;

	DSM_top dsm_i (
		.clock(clock),
		.reset(reset),
		.dith_i(11'h0),
		.vin(vin),
		.pwm(pwm)
	);
	
	always begin
		#1;
		clock	= ~clock;
	end

	initial begin
		clock = 0;
		reset = 1;
		data_file = $fopen("../dsm_in_bin.txt", "r");
		write_file = $fopen("pwm.txt", "w");			
		if (data_file == 0) begin
			$display("could not open data file");
			$finish;
		end
		#10;
		@(posedge clock);
		reset = #1 0;
	end

	always @(negedge clock) begin
		if (reset) begin
			vin	<= 11'b0;
		end
		else begin
			if (pwm == 2'b01) begin
				$fdisplay(write_file, "1");
			end
			else if (pwm == 2'b11) begin
				$fdisplay(write_file, "-1");
			end
			else begin
				$fdisplay(write_file, "0");
			end
			scan_file = $fscanf(data_file, "%b\n", vin); 
			if ($feof(data_file)) begin
				$fclose(write_file);
				$fclose(scan_file);
				$finish;
			end
		end
	end
	
endmodule
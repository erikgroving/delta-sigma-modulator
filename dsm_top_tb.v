module dsm_top_tb (

);

	// Testbench signals
	reg	signed [19: 0]	vin;
	reg 				clock;		
	reg					reset;
	reg					ds_clock;	// 50x slower than clock (4GHz -- 80 MHz)
	wire				pwm;
	
	// Testbench input and output file descriptors
	integer				write_file;
	integer 			data_file;
	integer 			scan_file;

	
	// System reset, clock initialization, and opening files
	initial begin		
		clock = 0;	
		ds_clock = 0;
		reset	= 1;
		#300; // Need reset to happens on the 80MHz too
		data_file = $fopen("interp_vin_bin.txt", "r");
		write_file = $fopen("dsm_out.txt", "w");			
		if (data_file == 0) begin
			$display("could not open data file");
			$finish;
		end
		#10;
		@(posedge clock);
		reset = #1 0;
	end

	
	always @(negedge clock) begin
		if (!reset) begin
			if (pwm) begin
				$fdisplay(write_file, "1");
			end
			else begin
				$fdisplay(write_file, "-1");
			end
			//$fdisplay(write_file, "%01b", pwm);
		end
	end
	
	// mixer comment always @ (negedge ds_clock) begin
	always @(negedge clock) begin
		if (reset) begin
			vin	<= 20'b0;
		end
		else begin

			scan_file = $fscanf(data_file, "%b\n", vin); 
			if ($feof(data_file)) begin
				$fclose(write_file);
				$fclose(data_file);
				$fclose(scan_file);
				$finish;
			end
		end	
	end
	
	always begin
		#1;
		clock = ~clock;
	end
	always begin
		#50;
		ds_clock = ~ds_clock;
	end
	
	dsm_top dsm_top_i (
		.clock(clock),
		.reset(reset),
		.vin(vin),
		.pwm(pwm)
	);
	
endmodule
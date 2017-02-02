module interp_tb(

);
		
	reg		[19: 0]	vin;
	wire	[19: 0]	interp_o;
	reg 			clock;		
	reg				reset;
	reg				ds_clock;	// 50x slower than clock (4GHz -- 80 MHz)
	integer			write_file;
	integer 		data_file;
	integer 		scan_file;

	

	initial begin		
		clock = 0;	
		ds_clock = 0;
		reset	= 1;
		data_file = $fopen("interp_vin_bin.txt", "r");
		write_file = $fopen("interp_out.txt", "w");			
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
			$fdisplay(write_file, "Time: %4.0f\tCurrent Vin: %d\tOutput: %d", $time, vin, interp_o);
		end
	end
	
	always @ (negedge ds_clock) begin
		if (reset) begin
			vin	<= 20'b0;
		end
		else begin

			scan_file = $fscanf(data_file, "%b\n", vin); 
			if ($feof(data_file)) begin
				$fclose(write_file);
				$fclose(data_file);
				$fclose(scan_file);
				$display("Reached end");
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
	
	// Read 1 sample every edge of ds_clock
	
	
	interp interp_i (
		.clock(clock),
		.reset(reset),
		.v_in(vin),
		.interp_o(interp_o)
	);


endmodule
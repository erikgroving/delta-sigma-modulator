module interp_tb(

);
		
	reg		[19: 0]	vin;
	wire	[19: 0]	interp_o;
	reg		[19: 0] actual_interp_o;
	wire	[19: 0] mix_o;
	wire	[1: 0]	LO;
	reg		[1: 0] 	LO_cnt;
	reg 			clock;		
	reg				reset;
	reg				act_reset;
	reg				ds_clock;	// 50x slower than clock (4GHz -- 80 MHz)
	integer			write_file;
	integer 		data_file;
	integer			actual_interp_out_file;
	integer 		scan_file;
	integer			interp_scan_file;

	

	initial begin		
		clock = 0;	
		ds_clock = 0;
		reset	= 1;
		actual_interp_out_file = $fopen("../actual_interp_out.txt", "r");
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
	
	initial begin
		act_reset	= 1'b1;
		#110;
		act_reset	= 1'b0;
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
	
	always @(negedge clock) begin
		if (!reset) begin
			$fdisplay(write_file, "Actual: %d\tGenerated: %d", actual_interp_o, interp_o);
		end
		
		if (act_reset) begin
			actual_interp_o	<= 20'b0;
		end
		else begin
			interp_scan_file = $fscanf(actual_interp_out_file, "%b\n", actual_interp_o);
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
		#25;
		ds_clock = ~ds_clock;
	end
	
	// Read 1 sample every edge of ds_clock
	
	
	interp interp_i (
		.clock(clock),
		.reset(reset),
		.v_in(vin),
		.interp_o(interp_o)
	);
	
	mixer mixer_i (
		.interp_i(interp_o),
		.LO(LO),
		.mix_o(mix_o)
	);


endmodule
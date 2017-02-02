module mixer_tb(

);
		
	reg 			clock;
	reg	[19: 0]		interp_i;
	reg	[19: 0] 	LO;
	wire [19: 0]	mix_o;
	integer			write_file;
	
	mixer mixer_i (
		.interp_i(interp_i),
		.LO(LO),
		.mix_o(mix_o)
	);
		
		
	initial begin		
		write_file = $fopen("mix_o.txt", "w");
		clock = 0;		
		interp_i = 20'b0;
		LO = 20'b0;
		@(negedge clock);
		interp_i = 20'h4000;
		LO = 20'h4000;
		@(negedge clock);
		interp_i = 20'd100;
		LO = 20'd300;
		@(negedge clock);
		$fclose(write_file);
		$finish;
	end
	
	always begin
		#5;
		clock = ~clock;
	end
		
	always @(negedge clock) begin
			$fdisplay(write_file, "%d", mix_o);
			/*
			scan_file = $fscanf(data_file, "%b\n", vin); 
			if ($feof(data_file)) begin
				$fclose(write_file);
				$fclose(scan_file);
				$display("Reached end");
				$finish;
			end
			*/
	end


endmodule
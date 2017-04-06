module BF_TOP_TB (

);
	
	reg 		clock;
	reg			ds_clock;
	reg 		reset;
	reg  [9: 0]	vin_i;
	reg  [9: 0] vin_q;
	wire [4: 0]	w_cos_1 [7: 0];
	wire [4: 0]	w_sin_1 [7: 0];
	wire [4: 0]	w_cos_2 [7: 0];
	wire [4: 0]	w_sin_2 [7: 0];
	wire [1: 0]	pwm 	[7: 0];
	
	// Testbench input and output file descriptors
	integer				pwm_0_file;
	integer				pwm_1_file;
	integer				pwm_2_file;
	integer				pwm_3_file;
	integer				pwm_4_file;
	integer				pwm_5_file;
	integer				pwm_6_file;
	integer				pwm_7_file;
	integer				i_input_file;
	integer				q_input_file;
	integer 			scan_file;

	
	// System reset, clock initialization, and opening files
	initial begin		
		clock 		= 0;
		ds_clock	= 0;
		reset		= 1;
		#300;
		i_input_file = $fopen("../../input/i_input_bin.txt", "r");
		q_input_file = $fopen("../../input/q_input_bin.txt", "r");
		pwm_0_file = $fopen("../../output/pwm_0.txt", "w");			
		pwm_1_file = $fopen("../../output/pwm_1.txt", "w");			
		pwm_2_file = $fopen("../../output/pwm_2.txt", "w");			
		pwm_3_file = $fopen("../../output/pwm_3.txt", "w");			
		pwm_4_file = $fopen("../../output/pwm_4.txt", "w");			
		pwm_5_file = $fopen("../../output/pwm_5.txt", "w");			
		pwm_6_file = $fopen("../../output/pwm_6.txt", "w");			
		pwm_7_file = $fopen("../../output/pwm_7.txt", "w");			

		#10;
		@(posedge clock);
		reset = #1 0;
	end

	
	assign w_cos_1[0]	= 5'd15;
	assign w_cos_1[1]	= -5'd11;
	assign w_cos_1[2]	= 5'd2;
	assign w_cos_1[3]	= 5'd9;
	assign w_cos_1[4]	= -5'd15;
	assign w_cos_1[5]	= 5'd13;
	assign w_cos_1[6]	= -5'd5;
	assign w_cos_1[7]	= -5'd6;

	assign w_cos_2[0]	= 5'd15;
	assign w_cos_2[1]	= 5'd0;
	assign w_cos_2[2]	= -5'd15;
	assign w_cos_2[3]	= 5'd0;
	assign w_cos_2[4]	= 5'd15;
	assign w_cos_2[5]	= 5'd0;
	assign w_cos_2[6]	= -5'd15;
	assign w_cos_2[7]	= 5'd0;
	
	assign w_sin_1[0]	= 5'd0;
	assign w_sin_1[1]	= -5'd10;
	assign w_sin_1[2]	= 5'd15;
	assign w_sin_1[3]	= -5'd12;
	assign w_sin_1[4]	= 5'd3;
	assign w_sin_1[5]	= 5'd8;
	assign w_sin_1[6]	= -5'd15;
	assign w_sin_1[7]	= 5'd14;

	assign w_sin_2[0]	= 5'd0;
	assign w_sin_2[1]	= 5'd15;
	assign w_sin_2[2]	= 5'd0;
	assign w_sin_2[3]	= -5'd15;
	assign w_sin_2[4]	= 5'd0;
	assign w_sin_2[5]	= 5'd15;
	assign w_sin_2[6]	= 5'd0;
	assign w_sin_2[7]	= -5'd15;
	
	BF_TOP BF_TOP_I (
		.CLOCK(clock),
		.RESET(reset),
		.SCLK(sclk),
		.MOSI(mosi),
		.VIN_I(vin_i),
		.VIN_Q(vin_q),
		.PWM(pwm)
	);
	
	
	always begin
		#1;
		clock = ~clock;
	end
	always begin
		#8;
		ds_clock = ~ds_clock;
	end
	
	
	always @(negedge clock) begin
		if (!reset) begin
		
			if (pwm[0] == 2'b01) begin
				$fdisplay(pwm_0_file, "1");
			end
			else if (pwm[0] == 2'b11) begin
				$fdisplay(pwm_0_file, "-1");
			end
			else begin
				$fdisplay(pwm_0_file, "0");
			end
		
			if (pwm[1] == 2'b01) begin
				$fdisplay(pwm_1_file, "1");
			end
			else if (pwm[1] == 2'b11) begin
				$fdisplay(pwm_1_file, "-1");
			end
			else begin
				$fdisplay(pwm_1_file, "0");
			end
		
			if (pwm[2] == 2'b01) begin
				$fdisplay(pwm_2_file, "1");
			end
			else if (pwm[2] == 2'b11) begin
				$fdisplay(pwm_2_file, "-1");
			end
			else begin
				$fdisplay(pwm_2_file, "0");
			end
		
			if (pwm[3] == 2'b01) begin
				$fdisplay(pwm_3_file, "1");
			end
			else if (pwm[3] == 2'b11) begin
				$fdisplay(pwm_3_file, "-1");
			end
			else begin
				$fdisplay(pwm_3_file, "0");
			end
		
			if (pwm[4] == 2'b01) begin
				$fdisplay(pwm_4_file, "1");
			end
			else if (pwm[4] == 2'b11) begin
				$fdisplay(pwm_4_file, "-1");
			end
			else begin
				$fdisplay(pwm_4_file, "0");
			end
		
			if (pwm[5] == 2'b01) begin
				$fdisplay(pwm_5_file, "1");
			end
			else if (pwm[5] == 2'b11) begin
				$fdisplay(pwm_5_file, "-1");
			end
			else begin
				$fdisplay(pwm_5_file, "0");
			end
		
			if (pwm[6] == 2'b01) begin
				$fdisplay(pwm_6_file, "1");
			end
			else if (pwm[6] == 2'b11) begin
				$fdisplay(pwm_6_file, "-1");
			end
			else begin
				$fdisplay(pwm_6_file, "0");
			end
		
			if (pwm[7] == 2'b01) begin
				$fdisplay(pwm_7_file, "1");
			end
			else if (pwm[7] == 2'b11) begin
				$fdisplay(pwm_7_file, "-1");
			end
			else begin
				$fdisplay(pwm_7_file, "0");
			end
			
			
		end
	end	
	
	always @ (negedge ds_clock) begin
	//always @(negedge clock) begin
		if (reset) begin
			vin_i	<= 10'b0;
			vin_q	<= 10'b0;
		end
		else begin
			scan_file = $fscanf(i_input_file, "%b\n", vin_i); 
			scan_file = $fscanf(q_input_file, "%b\n", vin_q); 
			if ($feof(i_input_file)) begin
				$fclose(i_input_file);
				$fclose(q_input_file);
				$fclose(pwm_0_file);
				$fclose(pwm_1_file);
				$fclose(pwm_2_file);
				$fclose(pwm_3_file);
				$fclose(pwm_4_file);
				$fclose(pwm_5_file);
				$fclose(pwm_6_file);
				$fclose(pwm_7_file);
				$fclose(scan_file);
				$finish;
			end
		end	
	end

	
endmodule
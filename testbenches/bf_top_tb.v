module BF_TOP_TB (

);
	parameter registerwidth=32; 
	reg  LOAD;
	reg [registerwidth-1:0] DATA;
	wire MOSI;
	wire SOut;


	reg 				clock;
	reg					ds_clock;
	reg 				reset;
	reg  [9: 0]			vin_i;
	reg  [9: 0] 		vin_q;
	reg	 [31: 0] 		spi_data;
	reg					SS;
	reg					sclk;
	wire [7: 0][4: 0]	w_cos_1;
	wire [7: 0][4: 0]	w_sin_1;
	wire [7: 0][4: 0]	w_cos_2;
	wire [7: 0][4: 0]	w_sin_2;
	wire [7: 0][1: 0]	pwm;
	
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
		SS 			= 1'b1;
		reset 		= 1'b0;
		sclk		= 1'b0;
		
		
		#20;
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
		#50;
		//*******w_cos_1_f**********
		DATA <= 32'h817D4490;
		#50 LOAD<=1'b1;
		#50 LOAD <=1'b0;
		#100 SS <=1'b0;
		sclk <= 1'b0;
		repeat (66)
		begin
		#50 sclk <= ~sclk;
		end
		#10 SS<=1'b1;
		#500;
		
		//*******w_cos_1_s**********
		DATA <= 32'h828B77A0;
		#50 LOAD<=1'b1;
		#50 LOAD <=1'b0;
		#100 SS <=1'b0;
		sclk <= 1'b0;
		repeat (66)
		begin
		#50 sclk <= ~sclk;
		end
		#10 SS<=1'b1;
		#500;
		
		//*******w_sin_1_f**********
		DATA <= 32'h83059F40;
		#50 LOAD<=1'b1;
		#50 LOAD <=1'b0;
		#100 SS <=1'b0;
		sclk <= 1'b0;
		repeat (66)
		begin
		#50 sclk <= ~sclk;
		end
		#10 SS<=1'b1;
		#500;
		
		//*******w_sin_1_s**********
		DATA <= 32'h841A22E0;
		#50 LOAD<=1'b1;
		#50 LOAD <=1'b0;
		#100 SS <=1'b0;
		sclk <= 1'b0;
		repeat (66)
		begin
		#50 sclk <= ~sclk;
		end
		#10 SS<=1'b1;
		#500;
		
		//*******w_cos_2_f**********
		DATA <= 32'h85782200;
		#50 LOAD<=1'b1;
		#50 LOAD <=1'b0;
		#100 SS <=1'b0;
		sclk <= 1'b0;
		repeat (66)
		begin
		#50 sclk <= ~sclk;
		end
		#10 SS<=1'b1;
		#500;
		
		//*******w_cos_2_s**********
		DATA <= 32'h86782200;
		#50 LOAD<=1'b1;
		#50 LOAD <=1'b0;
		#100 SS <=1'b0;
		sclk <= 1'b0;
		repeat (66)
		begin
		#50 sclk <= ~sclk;
		end
		#10 SS<=1'b1;
		#500;
		
		
		//*******w_sin_2_f**********
		DATA <= 32'h8703C110;
		#50 LOAD<=1'b1;
		#50 LOAD <=1'b0;
		#100 SS <=1'b0;
		sclk <= 1'b0;
		repeat (66)
		begin
		#50 sclk <= ~sclk;
		end
		#10 SS<=1'b1;
		#500;
		
		//*******w_sin_2_s**********
		DATA <= 32'h8803C110;
		#50 LOAD<=1'b1;
		#50 LOAD <=1'b0;
		#100 SS <=1'b0;
		sclk <= 1'b0;
		repeat (66)
		begin
		#50 sclk <= ~sclk;
		end
		#10 SS<=1'b1;
		#500;
		
		
		
	end

	

	SRegistertest #(registerwidth) inputdata(
		.Clock(sclk), 
		.Resetb(~reset), 
		.Pload(LOAD), 
		.PIn(DATA), 
		.SOut(MOSI)
	);
	
	
	
	
	BF_TOP BF_TOP_I (
		.CLOCK(clock),
		.RESET(reset),
		.SCLK(sclk),
		.MOSI(MOSI),
		.SS(SS),
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
			else if (pwm[0] == 2'b10) begin
				$fdisplay(pwm_0_file, "-1");
			end
			else begin
				$fdisplay(pwm_0_file, "0");
			end
		
			if (pwm[1] == 2'b01) begin
				$fdisplay(pwm_1_file, "1");
			end
			else if (pwm[1] == 2'b10 begin
				$fdisplay(pwm_1_file, "-1");
			end
			else begin
				$fdisplay(pwm_1_file, "0");
			end
		
			if (pwm[2] == 2'b01) begin
				$fdisplay(pwm_2_file, "1");
			end
			else if (pwm[2] == 2'b10) begin
				$fdisplay(pwm_2_file, "-1");
			end
			else begin
				$fdisplay(pwm_2_file, "0");
			end
		
			if (pwm[3] == 2'b01) begin
				$fdisplay(pwm_3_file, "1");
			end
			else if (pwm[3] == 2'b10) begin
				$fdisplay(pwm_3_file, "-1");
			end
			else begin
				$fdisplay(pwm_3_file, "0");
			end
		
			if (pwm[4] == 2'b01) begin
				$fdisplay(pwm_4_file, "1");
			end
			else if (pwm[4] == 2'b10) begin
				$fdisplay(pwm_4_file, "-1");
			end
			else begin
				$fdisplay(pwm_4_file, "0");
			end
		
			if (pwm[5] == 2'b01) begin
				$fdisplay(pwm_5_file, "1");
			end
			else if (pwm[5] == 2'b10)	begin
				$fdisplay(pwm_5_file, "-1");
			end
			else begin
				$fdisplay(pwm_5_file, "0");
			end
		
			if (pwm[6] == 2'b01) begin
				$fdisplay(pwm_6_file, "1");
			end
			else if (pwm[6] == 2'b10) begin
				$fdisplay(pwm_6_file, "-1");
			end
			else begin
				$fdisplay(pwm_6_file, "0");
			end
		
			if (pwm[7] == 2'b01) begin
				$fdisplay(pwm_7_file, "1");
			end
			else if (pwm[7] == 2'b10) begin
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
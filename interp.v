`include "parameters.vh"

module interp (
	input							clock,
	input							reset,
	input 		[13: 0]				v_in,		// signal in
	output wire	[`T_BITS - 1: 0]	interp_o	// interpolated output singal
);


	// interp is from 80MHz to 4GHz, that's a
	// step of 50, thus we need to have the 
	// difference divided by 50.
	// We can do this with 4 shifts / adds
	// v_step = v_diff * (2^-6 + 2^-8 + 2^-11 -2^-16)
	// this equates to doing 4 bits shifts of v_diff, and
	// adding the result: 
	// v_step = v_diff >> 6 + v_diff >> 8 + v_diff >> 11 - v_diff >> 16
	// this is 0.0200043, we want 0.02, should be close enough
	reg signed	[`I_BITS - 1: 0] 	interp;
	reg signed 	[`I_BITS - 1: 0] 	v;			// current v
	reg signed 	[`I_BITS - 1: 0] 	v_prev;		// previous v
	wire signed [`I_BITS - 1: 0]	v_step;		// 1/50 * v_diff
	wire signed [`I_BITS - 1: 0] 	v_diff;		// current_v - previous_v

	wire				prescale_clk;	// 80 MHz clock
	reg	[3: 0]			prescale_cnt;	// Counter to prescale
	
	always @(posedge clock) begin
		// Prescale counter and interp,
		// whenever we get a new sample, set the
		// output to the prev_v, then for each cycle after
		// increment interp_o by the step difference.
		if (reset) begin
			prescale_cnt	<= 4'd0;
		end
		else begin
			prescale_cnt	<= prescale_cnt + 1'b1;
		end
		
		
		// record samples every 80 MHz, interpolated samples will
		// be output according to the data		
		if (reset) begin
			v_prev	<= `I_BITS'b0;
			v		<= `I_BITS'b0;		
		end
		else if (prescale_cnt == 4'd15) begin
			v_prev	<= v;
			v		<= {v_in, `I_BITS_SUB_VIN_BITS'b0};// 
		end
		
		// prescale_clk goes high when it goes from 24->25
		// so when that happens, set interp_o to v (the next v_prev)
		// otherwise we just increment by the step (which is (v - v_prev)/50)
		if (reset) begin
			interp	<= `I_BITS'd0;
		end
		else if (prescale_cnt == 4'd15) begin
			interp	<= v;
		end
		else begin
			interp	<= $signed(interp) + $signed(v_step);
		end
	end
	
	assign interp_o = {interp[`I_U_LIM], interp[`I_U_LIM: `I_L_LIM]};
	
	assign prescale_clk	= (prescale_cnt == 6'd14);
	
	assign v_diff 	= v - v_prev;
	assign v_step	= {{4{v_diff[`I_U_LIM]}}, v_diff[`I_U_LIM:4]};

	
endmodule
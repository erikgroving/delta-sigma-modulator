`include "parameters.vh"

module INTERPOLATE (
	input							clock,
	input							ps_clock,
	input							reset,
	input 		[14: 0]				v_in,		// signal in
	output	[`T_BITS - 1: 0]		interp_o	// interpolated output singal
);

	reg signed	[`I_BITS - 1: 0] 	interp;
	wire signed [`I_BITS - 1: 0]	interp_sum;
	reg signed 	[`I_BITS - 1: 0] 	v;			// current v
	reg signed 	[`I_BITS - 1: 0] 	v_prev;		// previous v
	wire signed [`I_BITS - 1: 0]	v_step;		// 1/50 * v_diff
	wire signed [`I_BITS - 1: 0] 	v_diff;		// current_v - previous_v
	
	reg	signed	[`I_BITS - 1: 0]	v_clock;
	reg signed	[`I_BITS - 1: 0]	v_clock_prev;

	
	// synopsys sync_set_reset "reset"	
	always_ff @(posedge ps_clock or posedge reset) begin
		if (reset) begin
			v_prev	<= `I_BITS'b0;
			v		<= `I_BITS'b0;		
		end
		else begin
			v_prev	<= v;
			v		<= $signed({v_in, `I_BITS_SUB_VIN_BITS'b0});// 
		end
	end
	
	// synopsys sync_set_reset "reset"	
	always_ff @(posedge clock) begin
		// listen for changes of v
		if (reset) begin
			v_clock			<= `I_BITS'b0;
			v_clock_prev	<= `I_BITS'b0;
		end
		else begin
			v_clock			<= v;
			v_clock_prev	<= v_clock;
		end
		if (reset) begin
			interp	<= `I_BITS'd0;
		end
		else if (v_clock != v_clock_prev) begin
			interp	<= v;
		end
		else begin
			interp	<= interp_sum;
		end
	end
	
	assign interp_sum 	= $signed(interp) + $signed(v_step);
	assign interp_o 	= interp[`I_U_LIM: `I_L_LIM];
		
	assign v_diff 		= v - v_prev;
	assign v_step		= $signed({{3{v_diff[`I_U_LIM]}}, v_diff[`I_U_LIM:3]});

	
endmodule
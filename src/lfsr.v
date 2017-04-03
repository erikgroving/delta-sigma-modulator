`include "parameters.vh"
module lfsr (
	input 						clock,
	input 						reset,
	output reg [`T_BITS - 1: 5]	dith_o
);
	
	reg	[19: 0]	lfsr_20;
	reg	[20: 0]	lfsr_21;
	reg	[21: 0]	lfsr_22;
	reg	[22: 0]	lfsr_23;
	
	wire signed	[`T_BITS - 1: 0]	dith_pre;
	
	assign	dith_pre	= $signed(lfsr_20[`F_BITS - 1:0]) + $signed(lfsr_21[`F_BITS - 1:0]) + 
							$signed(lfsr_22[`F_BITS - 1:0]) + $signed(lfsr_23[`F_BITS - 1:0]);
	
	//
	always @(posedge clock) begin			
		dith_o			<= {{2{dith_pre[`T_BITS - 1]}}, dith_pre[`T_BITS - 1:7]};
		if (reset) begin
			lfsr_20			<= 20'hA_BCDE;
			lfsr_21			<= 21'h08_fa82;
			lfsr_22			<= 22'h13_cbaf;
			lfsr_23			<= 23'h3b_113f;
		end
		else begin
			lfsr_20[19:1]	<= lfsr_20[18:0];
			lfsr_21[20:1]	<= lfsr_21[19:0];
			lfsr_22[21:1]	<= lfsr_22[20:0];
			lfsr_23[22:1]	<= lfsr_23[21:0];
	
			lfsr_20[0]		<= lfsr_20[19] ~^ lfsr_20[16];
			lfsr_21[0]		<= lfsr_21[20] ~^ lfsr_21[18];
			lfsr_22[0]		<= lfsr_22[21] ~^ lfsr_21[20];
			lfsr_23[0]		<= lfsr_23[22] ~^ lfsr_23[17];			
		
		end
	end
	

	
endmodule
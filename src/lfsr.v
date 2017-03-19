`include "parameters.vh"
module lfsr (
	input 						clock,
	input 						reset,
	output [`T_BITS - 1: 0]		dith_o
);
	
	reg	signed 	[19: 0]	lfsr_20;
	reg	signed 	[20: 0]	lfsr_21;
	reg	signed 	[21: 0]	lfsr_22;
	reg	signed 	[22: 0]	lfsr_23;
	reg	signed 	[23: 0]	lfsr_24;
	reg	signed 	[24: 0]	lfsr_25;	
	wire		[`T_BITS - 1: 0]	dith_pre;
	
	assign	dith_pre	= $signed(lfsr_20[`F_BITS - 1:0]) + $signed(lfsr_21[`F_BITS - 1:0]) + 
							$signed(lfsr_22[`F_BITS - 1:0]) + $signed(lfsr_23[`F_BITS - 1:0]);
	assign	dith_o		= {{2{dith_pre[`T_BITS - 1]}}, dith_pre[`T_BITS - 1:2]};
	
	//
	always @(posedge clock) begin
		if (reset) begin
			lfsr_20			<= 20'hA_BCDE;
			lfsr_21			<= 21'h08_fa82;
			lfsr_22			<= 22'h13_cbaf;
			lfsr_23			<= 23'h3b_113f;
			lfsr_24			<= 24'h51_2345;
			lfsr_25			<= 25'h12_882B;
		end
		else begin
			lfsr_20[19:1]	<= lfsr_20[18:0];
			lfsr_21[20:1]	<= lfsr_21[19:0];
			lfsr_22[21:1]	<= lfsr_22[20:0];
			lfsr_23[22:1]	<= lfsr_23[21:0];
			lfsr_24[23:1]	<= lfsr_24[22:0];
			lfsr_25[24:1]	<= lfsr_25[23:0];
	
			lfsr_20[0]		<= lfsr_20[19] ~^ lfsr_20[16];
			lfsr_21[0]		<= lfsr_21[20] ~^ lfsr_21[18];
			lfsr_22[0]		<= lfsr_22[21] ~^ lfsr_21[20];
			lfsr_23[0]		<= lfsr_23[22] ~^ lfsr_23[17];			
			lfsr_24[0]		<= lfsr_24[23] ~^ lfsr_24[22] ~^ lfsr_24[21] ~^lfsr_24[16];
			lfsr_25[0]		<= lfsr_25[24] ~^ lfsr_25[21];			
		end
	end
	

	
endmodule
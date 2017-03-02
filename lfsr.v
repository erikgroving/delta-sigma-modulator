module lfsr (
	input 				clock,
	input 				reset,
	output reg [19: 0]	lfsr_o
);
	
	//
	always @(posedge clock) begin
		if (reset) begin
			lfsr_o			<= 20'hABCDE;
		end
		else begin
			lfsr_o[20:1]	<= lfsr_o[19:0];
			lfsr_o[0]		<= ~(lfsr_o[19] ^ lfsr_o[16]);
		end
	end
	

	
endmodule
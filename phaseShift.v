//not sure about bitshift and overflow stuff, please check all :), 
module phaseShift(
  input [19:0] interp_o_i_1,
	input [19:0] interp_o_q_1,
	input [19:0] interp_o_i_2,
	input [19:0] interp_o_q_2,
	input [3:0]  w_cos_1,
	input [3:0]  w_sin_1,
	input [3:0]  w_cos_2,
	input [3:0]  w_sin_2, //bit depth for the w coefficients are pending
	output [19:0] out_i,
	output [19:0] out_q
	);
	
	
	
wire signed [23:0] ii_1;
wire signed [23:0] iq_1;
wire signed [23:0] qi_1;
wire signed [23:0] qq_1;

wire signed [23:0] ii_2;
wire signed [23:0] iq_2;
wire signed [23:0] qi_2;
wire signed [23:0] qq_2;

wire signed [24:0] i_cwm_1;
wire signed [24:0] q_cwm_1;
wire signed [24:0] i_cwm_2;
wire signed [24:0] q_cwm_2;
	
	//implement adder in phaseShift

//for beam 1
assign ii_1=interp_o_i_1*w_cos_1;
assign iq_1=interp_o_i_1*w_sin_1;
assign qi_1=interp_o_q_1*w_cos_1;
assign qq_1=interp_o_q_1*w_sin_1;
assign i_cwm_1=ii_1+qq_1;
assign q_cwm_1=qi_1-iq_1;

//for beam 2
assign ii_2=interp_o_i_2*w_cos_2;
assign iq_2=interp_o_i_2*w_sin_2;
assign qi_2=interp_o_q_2*w_cos_2;
assign qq_2=interp_o_q_2*w_sin_2;
assign i_cwm_2=ii_2+qq_2;
assign q_cwm_2=qi_2-iq_2;


//sum them up, the adder is implemented here in phaseshift module

assign out_i=i_cwm_1[24:5]+i_cwm_2[24:5];
assign out_q=q_cwm_1[24:5]+q_cwm_2[24:5];

endmodule

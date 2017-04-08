
module SRegistertest(Clock, Resetb, Pload, PIn, SOut);
   //synopsys sync_set_reset "Reset,Set"
   parameter width = 20;

   input Clock, Resetb, Pload;
   output 	     SOut;
   input [width-1:0] PIn;

   reg [width-1:0] POut;
   
   assign SOut = POut[width-1];
      
   always @ (negedge Clock or negedge Resetb or posedge Pload) 
   	  begin
      		if (~Resetb)
      		POut <= {width{1'b0}};
      		else if (Pload) 
      			begin
      			POut <= PIn;
      			end
      		else
      			begin
	 				if (width == 1)
	   				POut <= 0;
	 				else
	   				POut <= {POut[width-2:0],1'b0};
      			end
   		end
   
endmodule // SRegister

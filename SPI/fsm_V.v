module fsm(input i_Clk, 
	        input i_Rst, 
			  input i_Signal, 
			  output reg [7:0] o_State, 
			  output reg o_Signal);

   localparam[7:0] 
			IDLE = 2'b00000000,
			STATE_1 = 2'b00000001,
			STATE_2 = 2'b00000010,
			STATE_3 = 2'b00000011;
	
	//reg[7:0] o_State;
	//reg o_Signal;

always @(posedge i_Clk, posedge i_Rst)
begin
	
   if(i_Rst)
       o_State <= IDLE;
   else
   begin
       case(o_State)
       IDLE:
       begin
            if(i_Signal) o_State <= STATE_1;
            else o_State <= STATE_2;
       end

       STATE_1:
       begin
            if(i_Signal) o_State <= STATE_3;
            else o_State <= STATE_2;
       end

       STATE_2:
       begin
            if(i_Signal) o_State <= STATE_1;
            else o_State <= STATE_3;
       end

       STATE_3:
       begin
            if(i_Signal) o_State <= STATE_1;
            else o_State <= STATE_2;
       end
       endcase
	end
end


always @(posedge i_Clk, posedge i_Rst)
begin
    if( i_Rst )
       o_Signal <= 0;
    else if( o_State == 2'b11 )
       o_Signal <= 1;
    else o_Signal <= 0;

end

endmodule
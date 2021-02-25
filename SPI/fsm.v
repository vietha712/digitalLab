module fsm(input i_Clk, 
	        input i_Rst, 
			  input i_Signal,
//			  input i_trigger,//DungTT
//			  output reg [7:0] o_State, 
			  output reg [7:0] o_State);

   localparam[7:0] 
			IDLE = 8'b00000000,
			STATE_1 = 8'b00000001,
			STATE_2 = 8'b00000010,
			STATE_3 = 8'b00000011;

initial
		begin
			o_State    <= IDLE;
//			l_State_en <= 1'b0;
		end


	/*
	Thiết kế một FSM:  FSM bao gồm các trạng thái : IDLE, STATE_1, STATE_2 và STATE_3
	Sau khi reset, trạng thái mặc định là IDLE.
	Trong trạng thái IDLE:
		Nếu nhận dữ liệu từ SPI = 0 : vào trạng thái STATE_2
		Nếu nhận dữ liệu từ SPI = 1 : vào trạng thái STATE_1
	Trong trạng thái STATE_1:
		Nếu nhận dữ liệu từ SPI = 0 : vào trạng thái STATE_2
		Nếu nhận dữ liệu từ SPI = 1 : vào trạng thái STATE_3
	Trong trạng thái STATE_2:
		Nếu nhận dữ liệu từ SPI = 0 : giữ nguyên trạng thái
		Nếu nhận dữ liệu từ SPI = 1 : vào trạng thái STATE_1
	Trong trạng thái STATE_3:
		Nếu nhận dữ liệu từ SPI = 0 : vào trạng thái STATE_2
		Nếu nhận dữ liệu từ SPI = 1 : vào trạng thái STATE_1
	Xuất trạng thái FSM ra màn hình mỗi khi nhận dữ liệu từ SPI
	*/
	always @(posedge i_Clk)
	begin
		if (~i_Rst)
		begin
			o_State    <= IDLE;
//			l_State_en <= 1'b0;
		end
		else
			begin
					case (o_State)
						IDLE:
							begin
								if(i_Signal == 1'b0)
									o_State = STATE_2;
								else
									o_State = STATE_1;
							end
						STATE_1:
							begin
								if(i_Signal == 1'b0)
									o_State = STATE_2;
								else
									o_State = STATE_3;
							end
						STATE_2:
							begin
								if(i_Signal == 1'b0)
									o_State = STATE_2;
								else
									o_State = STATE_1;
							end
						STATE_3:
							begin
								if(i_Signal == 1'b0)
									o_State = STATE_2;
								else
									o_State = STATE_1;
							end
						default:
							begin
							end
					endcase
			end
	end


//always @(posedge i_Clk, posedge i_Rst)
//begin
//    if( i_Rst )
//       o_Signal <= 0;
//    else if( o_State == 2'b11 )
//       o_Signal <= 1;
//    else o_Signal <= 0;
//
//end

endmodule

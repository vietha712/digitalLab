/* finite state machine */

module fsm(input i_Clk, input RESET_N, input i_Data);
	localparam IDLE        = 2'b00;
	localparam STATE_1     = 2'b01;
	localparam STATE_2     = 2'b10;
	localparam STATE_3     = 2'b11;
	reg fsm_state;

	initial
		begin
			fsm_state = IDLE;
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
	always @(posedge i_Clk or negedge RESET_N)
	begin
		if (~RESET_N)
		begin
			fsm_state  <= IDLE;   // Resets to high
		end
		else
		begin
			case (fsm_state)
				IDLE:
					begin
						if(i_Data == 1'b0)
							fsm_state <= STATE_2;
						else
							fsm_state <= STATE_1;
					end
				STATE_1:
					begin
						if(i_Data == 1'b0)
							fsm_state <= STATE_2;
						else
							fsm_state <= STATE_3;
					end
				STATE_2:
					begin
						if(i_Data == 1'b0)
							fsm_state <= STATE_2;
						else
							fsm_state <= STATE_1;
					end
				STATE_3:
					begin
						if(i_Data == 1'b0)
							fsm_state <= STATE_2;
						else
							fsm_state <= STATE_1;
					end
				default:
					begin
					end
			endcase
		end

		$monitor("Current state machine 0x%X", fsm_state); 
	end
endmodule

/* finite state machine */

module fsm(input i_Clk, input i_Rst, input i_Data, output [1:0]o_State);
	localparam IDLE        = 2'b00;
	localparam STATE_1     = 2'b01;
	localparam STATE_2     = 2'b10;
	localparam STATE_3     = 2'b11;
	reg [1:0]l_state;
	assign o_State[1:0] = l_state[1:0];

	initial
		begin
			l_state = IDLE;
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
	always @(posedge i_Clk or negedge i_Rst)
	begin
		if (~i_Rst)
		begin
			l_state  <= IDLE;   // Resets to high
		end
		else
		begin
			case (l_state)
				IDLE:
					begin
						if(i_Data == 1'b0)
							l_state <= STATE_2;
						else
							l_state <= STATE_1;
					end
				STATE_1:
					begin
						if(i_Data == 1'b0)
							l_state <= STATE_2;
						else
							l_state <= STATE_3;
					end
				STATE_2:
					begin
						if(i_Data == 1'b0)
							l_state <= STATE_2;
						else
							l_state <= STATE_1;
					end
				STATE_3:
					begin
						if(i_Data == 1'b0)
							l_state <= STATE_2;
						else
							l_state <= STATE_1;
					end
				default:
					begin
					end
			endcase
		end

		$monitor("l_state = 0x%X", l_state); 
		$monitor("o_State = 0x%X", o_State); 
	end
endmodule



/* test bench for finite state machine */
module tb_fsm;
	reg clk, reset, data;
	wire [1:0]fsm_state;

	always  
	begin 
		clk = 1; #10; 
		clk = 0; #10;  
	end  

	initial  
	begin  
		reset = 0; 
		#22; 
		reset = 1;
		data  = 0;
	end  

	// use SPI mode 0
	always @(negedge clk)
	begin
		data  <= $random;
	end


	fsm fsm_test
	(
		.i_Clk(clk),
		.i_Rst(reset),
		.i_Data(data),
		.o_State(fsm_state[1:0])
	);
endmodule



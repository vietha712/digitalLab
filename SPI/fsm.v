
/* finite state machine */

module fsm(input i_Clk, input i_Rst, input i_Data, output [7:0]o_State, output o_State_en);
	localparam IDLE        = 8'b00000000;
	localparam STATE_1     = 8'b00000001;
	localparam STATE_2     = 8'b00000010;
	localparam STATE_3     = 8'b00000011;
	reg [7:0]l_State;
	reg l_State_en;

	// output from FSM
	assign o_State[7:0] = l_State[7:0];
	assign o_State_en   = l_State_en;



	initial
		begin
			l_State    <= IDLE;
			l_State_en <= 1'b0;
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
			l_State    <= IDLE;
			l_State_en <= 1'b0;
		end
		else
		begin
			case (l_State)
				IDLE:
					begin
						if(i_Data == 1'b0)
							l_State = STATE_2;
						else
							l_State = STATE_1;
					end
				STATE_1:
					begin
						if(i_Data == 1'b0)
							l_State = STATE_2;
						else
							l_State = STATE_3;
					end
				STATE_2:
					begin
						if(i_Data == 1'b0)
							l_State = STATE_3;
						else
							l_State = STATE_1;
					end
				STATE_3:
					begin
						if(i_Data == 1'b0)
							l_State = STATE_2;
						else
							l_State = STATE_1;
					end
				default:
					begin
					end
			endcase
			
			if (l_State == STATE_3)
				l_State_en = 1'b1;
			else
				l_State_en = 1'b0;
		end

		$monitor("o_State = 0x%X", o_State); 
		$monitor("l_State = 0x%X", l_State); 
	end

endmodule




/* test bench for finite state machine */
module tb_fsm;
	reg clk, reset, data;
	wire [7:0]state;
	wire state_en;

	always  
	begin 
		clk = 1; #10; 
		clk = 0; #10;  
	end  

	initial  
	begin  
		reset     = 0; 
		data      = 0; 
		#22; 
		reset = 1;
	end  

	// use SPI mode 0
	always @(negedge clk)
	begin
		data  = $random;
	end


	fsm fsm_test_instance
	(
		.i_Clk(clk),
		.i_Rst(reset),
		.i_Data(data),
		.o_State(state[7:0]),
		.o_State_en(state_en)
	);
endmodule



//Description: This file contains the implementation of FSM and SPI interface
// 				The FPGA is configured as a slave to receive the command from the master.
//					The FSM instance then will handle the received command.
//					The current state of the FSM will then be saved to the buffer to send back to the master via SPI interface.
//					Master command to get the current state is: 11111111
//					Master command to feed the input for state change to FSM is: 00000000 and 00000001
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module SpiLab
	(
	input[35:0]  GPIO_0, //MOSI, CS
	output[35:0] GPIO_1, //MISO
	input CLOCK_50,
	input[9:0] SW,
	output[9:0] LEDR, //output LED
	);

	localparam SPI_Mode = 0; // rising edge is captured CPOL = 0, CPHA = 0
	
	//Slave specific
	reg w_Slave_RX_DV,   r_Slave_TX_DV;
	wire [7:0] w_Slave_RX_Byte;
	wire [7:0] r_Slave_TX_Byte;
	
	// FSM state
	wire [7:0] fsm_State;

	//Clock divider variables
	wire SPI_Clk;
	
	//Assignment
	assign r_Slave_TX_Byte = fsm_State;

	//Clock divider to output the clock at 10 MHz
	Des_Devide_Clock clockDiv(.clock_in(CLOCK_50), .clock_out(SPI_Clk));


	// Instantiate FPGA board as a slave to receive the command from ESP32
	SPI_Slave #(.SPI_MODE(SPI_Mode)) SPI_Slave_Hw
	(
		.i_Rst_L(SW[0]),
		.i_Clk(CLOCK_50), //50 MHz
		.o_RX_DV(w_Slave_RX_DV),
		.o_RX_Byte(w_Slave_RX_Byte[7:0]),
		.i_TX_DV(r_Slave_TX_DV),
		.i_TX_Byte(r_Slave_TX_Byte[7:0]),
		
		// SPI interfaces
		.i_SPI_Clk (GPIO_0[2]), // 10 MHz. Satisfy that the FPGA clk is 4x faster than SPI
		.o_SPI_MISO(GPIO_1[0]),
		.i_SPI_MOSI(GPIO_0[0]),
		.i_SPI_CS_n(GPIO_0[1])
	);


	// FSM instance here
	fsm fsmLab
	(
		.i_Clk(CLOCK_50),
		.i_Rst(SW[1]),
		.i_Signal (w_Slave_RX_Byte[0]),
		.o_State(fsm_State),
		.o_Signal(LEDR[0])
	);



	//Polling to wait for master's command
	always @(posedge CLOCK_50)
	begin
	
	if(w_Slave_RX_Byte == 8'b11111111)
		begin
			r_Slave_TX_DV <= 1'b1;
		end
	else
		begin
			r_Slave_TX_DV <= 1'b0;
		end
		
	end


endmodule








//Description: This file contains the implementation of FSM and SPI interface
// 				The FPGA is configured as a slave to receive the command from the master.
//					The FSM instance then will handle the received command.
//					The current state of the FSM will then be saved to the buffer to send back to the master via SPI interface.
//					Master command to get the current state is: 11111111
//					Master command to feed the input for state change to FSM is: 00000000 and 00000001
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module SpiLab
	(
	input[35:0] GPIO_0, //MOSI, CS
	output[35:0] GPIO_1, //MISO
	input CLOCK_50,
	input[9:0] SW,
	output[9:0] LEDR //output LED
	);

	localparam SPI_Mode = 0; // rising edge is captured CPOL = 0, CPHA = 0
	
	//Slave specific
	wire w_Slave_RX_DV;   
	reg r_Slave_TX_DV;
	wire [7:0] w_Slave_RX_Byte;
	wire [7:0] r_Slave_TX_Byte;
	
	//DungTT: add to count number of bytes transfer
	wire [7:0] w_Slave_RX_No_Byte;
	wire [7:0] w_Slave_TX_No_Byte;
	
	// FSM state
	wire [7:0] fsm_State;

	//Clock divider variables
	wire SPI_Clk;
	
	//Assignment
//	assign r_Slave_TX_Byte = fsm_State;
	assign r_Slave_TX_Byte[7:0] = fsm_State;
//	assign r_Slave_TX_Byte[7:0] = 8'b00110011;
	assign LEDR[9:8] = fsm_State;//DungTT: to monitor fms_state
	assign LEDR[7:0] = w_Slave_RX_No_Byte;//DungTT: to count number of bytes (every 8 bits) received from master
//	assign LEDR[7:0] = w_Slave_RX_Byte;//DungTT: to monitor data received from SPI master
	
	//Clock divider to output the clock at 10 MHz
	//DungTT: no need clock divider due to no useful
//	Des_Devide_Clock clockDiv(.clock_in(CLOCK_50), .clock_out(SPI_Clk));


	// Instantiate FPGA board as a slave to receive the command from ESP32
	SPI_Slave #(.SPI_MODE(SPI_Mode)) SPI_Slave_Hw
	(
		.i_Rst_L(SW[0]),
		.i_Clk(CLOCK_50), //50 MHz
		.o_RX_DV(w_Slave_RX_DV),
		.o_RX_Byte(w_Slave_RX_Byte[7:0]),
		.i_TX_DV(r_Slave_TX_DV),
		.i_TX_Byte(r_Slave_TX_Byte[7:0]),
		
		//DungTT
		.o_No_Byte_rev(w_Slave_RX_No_Byte[7:0]), // Number of bits received
		.o_No_Byte_trans(w_Slave_TX_No_Byte[7:0]), // Number of bits transmitted
		
		// SPI interfaces
		.i_SPI_Clk(GPIO_0[2]), // get clk from Master ESP32: 5 MHz. Satisfy that the FPGA clk is 4x faster than SPI
										// 10MHz does not work?!
		//.i_SPI_Clk (SPI_Clk),
		.o_SPI_MISO(GPIO_1[0]),
		.i_SPI_MOSI(GPIO_0[0]),
		.i_SPI_CS_n(GPIO_0[1])
	);
	
	// FSM instance here
	fsm fsmLab
	(
		.i_Clk(GPIO_0[1]),//DungTT: replace clk by trigger from CS pin
//		.i_Clk(w_Slave_RX_DV),//DungTT: replace clk by trigger from CS pin
		.i_Rst(SW[1]),
		.i_Signal(w_Slave_RX_Byte[0]),
		.o_State(fsm_State)
	);
	

//	//Polling to wait for master's command
//	always @(posedge CLOCK_50)
//	begin
//	
//	if (w_Slave_RX_Byte == 8'b11111111)
//		begin
//			r_Slave_TX_DV <= 1'b1;
////			turn = 1'b0;
//		end
//	else
//		begin
//			r_Slave_TX_DV <= 1'b0;
////			turn <= 1'b0;
//		end
//		
//	end


endmodule

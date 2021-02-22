//Description: This file contains the implementation of FSM and SPI interface
// 				The FPGA is configured as a slave to receive the command from the master.
//					The FSM instance then will handle the received command.
//					The current state of the FSM will then be saved to the buffer to send back to the master via SPI interface.
//					Master command to get state is: 11111111
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module SpiLab
	(
	input[35:0]  GPIO_0, //MOSI, CS, CLK
	output[35:0] GPIO_1, //MISO
	input CLOCK_50,
	// input[9:0] SW, // i_Data
	input RESET_N  // RESET_N
	);

	localparam Spi_Mode = 0;
	
	//Slave specific
	wire        w_Slave_RX_DV,   r_Slave_TX_DV;
	wire  [7:0] w_Slave_RX_Byte;
	wire  [7:0] r_Slave_TX_Byte;

	// reg r_Rst_L = 1'b0; //init with default value


/*
	//Clock divider variables
	wire clock_out_spi;

	//Clock divider to output the clock at 25MHz
	Des_Devide_Clock clockDiv(.clock_in(CLOCK_50), .clock_out(clock_out_spi));
*/


/*
	// FSM
	// reg[1:0] fsm_state;
	wire  [7:0] o_fsm_txdata;
	reg   [7:0] o_fsm_rxdata;

	always @(posedge CLOCK_50)
		begin
			if(SW[0] == 2'b1)
				begin
					o_fsm_rxdata[7:0] <= w_Slave_RX_Byte[7:0];
					r_Slave_TX_Byte[7:0] <= o_fsm_txdata[7:0];
				end
		end
*/





	// Instantiate FPGA board as a slave to receive the command from ESP32
	SPI_Slave #(.SPI_MODE(Spi_Mode)) spiSlaveHw
	(
		.i_Rst_L(RESET_N),
		.i_Clk(CLOCK_50),                  //use CLOCK_50
		.o_RX_DV(w_Slave_RX_DV),
		.o_RX_Byte(w_Slave_RX_Byte[7:0]),
		.i_TX_DV(r_Slave_TX_DV),
		.i_TX_Byte(r_Slave_TX_Byte[7:0]),
		
		// SPI interfaces
		.i_SPI_Clk (GPIO_0[2]),
		.o_SPI_MISO(GPIO_1[0]),
		.i_SPI_MOSI(GPIO_0[0]),
		.i_SPI_CS_n(GPIO_0[1])
	);


	// FSM instance here
	fsm fsmLab
	(
		.i_Clk(CLOCK_50),
		.i_Rst(RESET_N),
		.i_Data_en(w_Slave_RX_DV),
		.i_Data (w_Slave_RX_Byte[0]),
		.o_State(r_Slave_TX_Byte[7:0]),
		.o_State_en(r_Slave_TX_DV)
	);


/*
//	//Polling to wait for master's command
//	always @(posedge clock_out_spi)
//	
//	if(w_Slave_RX_Byte == 8'b11111111)
//		begin
//			r_Slave_TX_Byte <= fsm_state; //update FSM state to slave tx buffer
//			//assign r_Slave_TX_Byte = fsm_state;
//		end
*/


endmodule





/* test bench for SpiLab */
module tb_SpiLab;

	reg  clk, reset;
	reg  [35:0]SpiLab_GPIO_0;
	wire [35:0]SpiLab_GPIO_1;
	reg  [7:0] count = 0;

	reg i_SPI_Clk, o_SPI_MISO, i_SPI_MOSI, i_SPI_CS_n; // for debugging


	initial
	begin
		SpiLab_GPIO_0[1]     = 1;   //chip select
		reset                = 0; 
		#22; 
		//SpiLab_GPIO_0[1]     = 0;   //chip select
		reset                = 1; 
	end

	always
	begin
		clk = 1; #10;
		clk = 0; #10; 
	end


	always
	begin
		SpiLab_GPIO_0[2] = 1; #100;
		SpiLab_GPIO_0[2] = 0; #100;
	end
	always @(posedge SpiLab_GPIO_0[2])
	begin
		count = count + 1;
		if (count < 9)
			SpiLab_GPIO_0[1]     = 0;   //chip select
		else if (count < 30)
			SpiLab_GPIO_0[1]     = 1;   //chip select
		else
			count = 0;
	end

	// use SPI mode 0
	always @(negedge SpiLab_GPIO_0[2])
	begin
		SpiLab_GPIO_0[0]  = $random;
	end

	always @(posedge clk)
	begin
		i_SPI_Clk  = SpiLab_GPIO_0[2];  // for debugging
		o_SPI_MISO = SpiLab_GPIO_1[0];  // for debugging
		i_SPI_MOSI = SpiLab_GPIO_0[0];  // for debugging
		i_SPI_CS_n = SpiLab_GPIO_0[1];  // for debugging
	end


	SpiLab SpiLab_test_instance
	(
		.GPIO_0  (SpiLab_GPIO_0),
		.GPIO_1  (SpiLab_GPIO_1),
		.CLOCK_50(clk),
		.RESET_N (reset)
	);
endmodule





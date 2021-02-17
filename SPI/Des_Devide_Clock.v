// Verilog code for clock divider on FPGA
// Top level Verilog code for clock divider on FPGA

module Des_Devide_Clock( clock_in, clock_out);
 
	input clock_in;           // input clock on FPGA
	output clock_out;         // output clock after dividing the input clock by divisor
	reg[27:0] counter = 28'd0;
	parameter DIVISOR = 28'd10;
	
	// The frequency of the output clk_out = The frequency of the input clk_in divided by DIVISOR
	// For example: Fclk_in = 50Mhz, if you want to get 1Hz signal to blink LEDs
	// You will modify the DIVISOR parameter value to 28'd50.000.000
	// Then the frequency of the output clk_out = 50Mhz/50.000.000 = 1Hz
	
	always @( posedge clock_in)
	begin
		counter <= counter + 28'd1;
		if( counter >= ( DIVISOR - 1))
			counter <= 28'd0;
	end
	
	assign clock_out = (counter < DIVISOR/2) ? 1'b0 : 1'b1;
	

endmodule


// Simulation
`timescale 1ns / 1ps 
module tb_Devide_Clock;

	// Inputs
	reg clock_in;
	// Outputs
	wire clock_out;
	
	// Instantiate the Unit Under Test (UUT)
	// Test the clock divider in Verilog
	Des_Devide_Clock DUT( clock_in, clock_out);
	
	initial 
	begin
		// Initialize Inputs
		clock_in = 0;
		
		// create input clock 50MHz by using the software
		forever #10 clock_in = ~clock_in;
		
	end
      
endmodule


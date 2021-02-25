/**
We need 04 pins (wires) to communicate btw esp32 & FPGA
The default pins for SPI on the ESP32.
HSPI
MOSI = GPIO13
MISO = GPIO12
CLK = GPIO14
CD = GPIO15

/SPI interface
  .i_SPI_Clk (GPIO_0[2]),
  .o_SPI_MISO(GPIO_1[0]),
  .i_SPI_MOSI(GPIO_0[0]),
  .i_SPI_CS_n(GPIO_0[1])
  
VSPI
MOSI = GPIO23 --> GPIO0 - 0
MISO = GPIO19 --> GPIO1 - 0
CLK/SCK = GPIO18 --> GPIO0 - 2
CS/SS = GPIO5 --> GPIO0 - 1
 **/

#include <SPI.h>

#define ssFPGA 5// 5 pin selects slave ID
#define MOSI 23// 
#define MISO 19//
#define SCK 18//  18
//uint32_t const maxSpeed = 5000000;
#define Set_CS LOW //LOW is selected
#define Reset_CS HIGH //

void setup()
{
    Serial.begin(115200);
    while (!Serial) {
      ; // wait
    }
    Serial.println("Serial Begin");
    
    SPI.begin(SCK, MISO, MOSI, ssFPGA);   
    Serial.println("SPI Begin");   
    
    pinMode(ssFPGA, OUTPUT); 
    digitalWrite(ssFPGA, Reset_CS);
    Serial.println("Please type input: 0 or 1");   
}

void loop() 
{     
    //Wait & read data from Serial
      while (!Serial.available()){
        ;
      }
      byte mosi = Serial.read();
      Serial.flush();
      delay(10);
        
      SPI.beginTransaction(SPISettings(5000000, MSBFIRST, SPI_MODE0)); //config SPI transaction with 03 parametter: maxSpeed/ dataOrder/ dataMode
                                                                            //need to be adapted with FPGA KIT
    //SPI.setFrequency(maxSpeed);
    //Start transfer via SPI
      digitalWrite(ssFPGA, Set_CS);//select slave
      byte miso = SPI.transfer(mosi);
      digitalWrite(ssFPGA, Reset_CS);
      SPI.endTransaction();
      
    //Console
//      Serial.print("SPI transfered to FPGA: ");
//      Serial.println(mosi, HEX);
//      Serial.print("Data received from FPGA: ");
      Serial.println(miso, HEX);
      Serial.flush();
}

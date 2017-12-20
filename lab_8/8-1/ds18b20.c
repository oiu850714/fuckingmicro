#include "ds18b20.h"


#define Convert_T 0x44
#define Read_Scratchpad 0xBE

/* Send ConvT through OneWire with resolution
 * param:
 *   OneWire: send through this
 *   resolution: temperature resolution
 * retval:
 *    0 -> OK
 *    1 -> Error
 */
int DS18B20_ConvT(OneWire_t* OneWire, DS18B20_Resolution_t resolution) {
	// TODO

	OneWire_WriteByte(OneWire, Convert_T);

	switch(resolution){
	case 9:
		delay_us(93750);
		break;
	case 10:
		delay_us(187500);
		break;
	case 11:
		delay_us(375000);
		break;
	case 12:
		delay_us(750000);
		break;
	}

	//display(GPIOA->IDR);

	return 0;
}

/* Read temperature from OneWire
 * param:
 *   OneWire: send through this
 *   destination: output temperature
 * retval:
 *    0 -> OK
 *    1 -> Error
 */
uint8_t DS18B20_Read(OneWire_t* OneWire, short *destination) {
	// TODO
	short firstByte = 0, secondByte = 0;
	OneWire_WriteByte(OneWire, Read_Scratchpad);
	firstByte = OneWire_ReadByte(OneWire);
	secondByte = OneWire_ReadByte(OneWire);
	*destination = (secondByte << 8) + firstByte;
	return 0;
}

/* Set resolution of the DS18B20
 * param:
 *   OneWire: send through this
 *   resolution: set to this resolution
 * retval:
 *    0 -> OK
 *    1 -> Error
 */
uint8_t DS18B20_SetResolution(OneWire_t* OneWire, DS18B20_Resolution_t resolution) {
	// TODO
	return 0;
}

/* Check if the temperature conversion is done or not
 * param:
 *   OneWire: send through this
 * retval:
 *    0 -> OK
 *    1 -> Not yet
 */
uint8_t DS18B20_Done(OneWire_t* OneWire) {
	// TODO
	return 0;
}

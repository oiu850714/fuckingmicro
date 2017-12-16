#include "onewire.h"
#include "ref.h"

/* Init OneWire Struct with GPIO information
 * param:
 *   OneWire: struct to be initialized
 *   GPIOx: Base of the GPIO DQ used, e.g. GPIOA
 *   GPIO_Pin: The pin GPIO DQ used, e.g. 5
 */
#define SKIP_ROM 0xCC

void ONEWIRE_INPUT(OneWire_t* OneWireStruct)
{
	OneWireStruct->GPIOx->MODER &= ~(0x3);
	OneWireStruct->GPIOx->MODER |= 0x0; // turn to input mode
	OneWireStruct->GPIOx->PUPDR &= ~(0x3);
	OneWireStruct->GPIOx->PUPDR |= 0x1; // turn to pull-up
}

void ONEWIRE_OUTPUT(OneWire_t* OneWireStruct)
{
	OneWireStruct->GPIOx->MODER &= ~(0x3);
	OneWireStruct->GPIOx->MODER |= 0x1; // PA0 set to output mode
	//OneWireStruct->GPIOx->ODR |= 0x1; // negedge!!!!!!!
	OneWireStruct->GPIOx->ODR &= ~(0x1);
	//OneWireStruct->GPIOx->ODR |= 0x0; // GPIOx will be GPIOA, reset pin 0
}

void delay_use_SysTick(int usec)
{
	SysTick->VAL = 8000000;
	while(1)
	{
		if(SysTick->VAL <= 8000000 - 4 * usec)
			return;
	}
}

void OneWire_Init(OneWire_t* OneWireStruct) { //, GPIO_TypeDef* GPIOx, uint32_t GPIO_Pin) {
	// TODO
	ONEWIRE_OUTPUT(OneWireStruct);
	OneWire_Reset(OneWireStruct);
}

/* Send reset through OneWireStruct
 * Please implement the reset protocol
 * param:
 *   OneWireStruct: wire to send
 * retval:
 *    0 -> Reset OK
 *    1 -> Reset Failed
 */
uint8_t OneWire_Reset(OneWire_t* OneWireStruct) {
	// TODO
	delay_use_SysTick(480);
	ONEWIRE_INPUT(OneWireStruct);
	delay_use_SysTick(70);
	if(!((OneWireStruct->GPIOx->IDR) & 0x1)) // if true, onewire set successful
	{
		delay_use_SysTick(410);
		//display(1);
		return 1;
	}
	else
	{
		delay_use_SysTick(410);
		//display(0);
		return 0;
	}
}

/* Write 1 bit through OneWireStruct
 * Please implement the send 1-bit protocol
 * param:
 *   OneWireStruct: wire to send
 *   bit: bit to send
 */
void OneWire_WriteBit(OneWire_t* OneWireStruct, uint8_t bit) {
	// TODO

	if(bit == 0)
	{
		ONEWIRE_OUTPUT(OneWireStruct);
		delay_use_SysTick(60);
		ONEWIRE_INPUT(OneWireStruct);
	}
	else
	{
		ONEWIRE_OUTPUT(OneWireStruct);
		delay_use_SysTick(10);
		ONEWIRE_INPUT(OneWireStruct);
		delay_use_SysTick(50);
	}
}

/* Read 1 bit through OneWireStruct
 * Please implement the read 1-bit protocol
 * param:
 *   OneWireStruct: wire to read from
 */
uint8_t OneWire_ReadBit(OneWire_t* OneWireStruct) {
	// TODO
	ONEWIRE_OUTPUT(OneWireStruct);
	delay_use_SysTick(2);
	ONEWIRE_INPUT(OneWireStruct);
	delay_use_SysTick(10);
	uint8_t readBit = OneWireStruct->GPIOx->IDR & 0x1;
	delay_use_SysTick(50);
	return readBit;
}

/* A convenient API to write 1 byte through OneWireStruct
 * Please use OneWire_WriteBit to implement
 * param:
 *   OneWireStruct: wire to send
 *   byte: byte to send
 */
void OneWire_WriteByte(OneWire_t* OneWireStruct, uint8_t byte) {
	// TODO
	for(int i = 0; i < 8; i++)
	{
		OneWire_WriteBit(OneWireStruct, byte & 0x1);
		delay_use_SysTick(2);
		byte >>= 1;
	}
}

/* A convenient API to read 1 byte through OneWireStruct
 * Please use OneWire_ReadBit to implement
 * param:
 *   OneWireStruct: wire to read from
 */
uint8_t OneWire_ReadByte(OneWire_t* OneWireStruct) {
	// TODO
	uint8_t readByte = 0;
	for(int i = 0; i < 8; i++)
	{
		readByte += (OneWire_ReadBit(OneWireStruct) << i);
		delay_use_SysTick(1);
	}
	return readByte;
}

/* Send ROM Command, Skip ROM, through OneWireStruct
 * You can use OneWire_WriteByte to implement
 */
void OneWire_SkipROM(OneWire_t* OneWireStruct) {
	// TODO
	OneWire_WriteByte(OneWireStruct, SKIP_ROM);
}

#include "ds18b20.h"
#include "gpio.h"
#include "onewire.h"
#include "ref.h"
//#include "stm32l476xx.h"

#define SET_REG(REG, SELECT, VAL) {((REG)=((REG)&(~(SELECT))) | (VAL));};

int check_handler = 87;

extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
extern void GPIO_init();

#define SCAN_LIMIT_CMD 0x0B
#define SHUTDOWN_CMD 0x0C


OneWire_t OneWire = {GPIOA, 0};

void display(int n)
{
	int position = 1;

	if(n == 0) //special case for zero
	{
		max7219_send(1, 0);
		max7219_send(SCAN_LIMIT_CMD, 0);
	}
	else
	{
		if(n < 0)
		{
			n = n * -1;
			while(n > 0)
			{
				max7219_send(position, n%10);
				n /= 10;
				position++;
			}
			max7219_send(position, 10); //print '-'
			max7219_send(SCAN_LIMIT_CMD, position-1);
		}
		else
		{
			while(n > 0)
			{
				max7219_send(position, n%10);
				n /= 10;
				position++;
			}
			max7219_send(SCAN_LIMIT_CMD, position-2);
		}
	}

}

void SystemClock_Config(){
	SysTick->CTRL |= 0x7; //3'b111
	SysTick->LOAD = 8000000;

	//TODO: Setup system clock and SysTick timer interrupt
}
void SysTick_Handler(void) {
	//TODO: Show temperature on 7-seg display
	OneWire_Init(&OneWire);
	OneWire_SkipROM(&OneWire);
	DS18B20_ConvT(&OneWire, 12);
	short temperature;
	DS18B20_Read(&OneWire, &temperature);
	//display(temperature);
	//check_handler++;
}

int main(){
	SystemClock_Config();
	GPIO_init();
	max7219_init();

	while(1){
		/*
		if(user_press_button()) {
		}
		*/
	}
//TODO: Enable or disable Systick timer
}


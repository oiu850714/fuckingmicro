//#include "gpio.h"
//#include "ref.h"
#include "stm32l476xx.h"
//#include "core_cm4.h"

#define SET_REG(REG, SELECT, VAL) {((REG)=((REG)&(~(SELECT))) | (VAL));};

int key_value = 0;

extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
extern void GPIO_init();

#define SCAN_LIMIT_CMD 0x0B
#define SHUTDOWN_CMD 0x0C

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

void keypad_init()
{
	// SET keypad gpio OUTPUT //
	RCC->AHB2ENR = RCC->AHB2ENR|0x2;
	//Set PA8,9,10,12 as output mode
	GPIOA->MODER= GPIOA->MODER&0xFDD5FFFF;
	//set PA8,9,10,12 is Pull-up output
	GPIOA->PUPDR=GPIOA->PUPDR|0x1150000;
	//Set PA8,9,10,12 as medium speed mode
	GPIOA->OSPEEDR=GPIOA->OSPEEDR|0x1150000;
	//Set PA8,9,10,12 as high
	//GPIOA->ODR=GPIOA->ODR|10111<<8;
	// SET keypad gpio INPUT //
	//Set PB5,6,7,9 as INPUT mode
	GPIOB->MODER=GPIOB->MODER&0xFFF303FF;
	//set PB5,6,7,9 is Pull-down input
	GPIOB->PUPDR=GPIOB->PUPDR|0x8A800;
	//Set PB5,6,7,9 as medium speed mode
	GPIOB->OSPEEDR=GPIOB->OSPEEDR|0x45400;
}

void EXTI_Setup()
{
	display(2);
	RCC->APB2ENR |= 0x1;

	SET_REG(SYSCFG->EXTICR[1], SYSCFG_EXTICR2_EXTI5, SYSCFG_EXTICR2_EXTI5_PB);
	SET_REG(SYSCFG->EXTICR[1], SYSCFG_EXTICR2_EXTI6, SYSCFG_EXTICR2_EXTI6_PB);
	SET_REG(SYSCFG->EXTICR[1], SYSCFG_EXTICR2_EXTI7, SYSCFG_EXTICR2_EXTI7_PB);
	SET_REG(SYSCFG->EXTICR[2], SYSCFG_EXTICR3_EXTI9, SYSCFG_EXTICR3_EXTI9_PB);

	/*SET_REG(EXTI->RTSR1, EXTI_RTSR1_RT5, EXTI_RTSR1_RT5);
	SET_REG(EXTI->RTSR1, EXTI_RTSR1_RT6, EXTI_RTSR1_RT6);
	SET_REG(EXTI->RTSR1, EXTI_RTSR1_RT7, EXTI_RTSR1_RT7);
	SET_REG(EXTI->RTSR1, EXTI_RTSR1_RT9, EXTI_RTSR1_RT9);

	SET_REG(EXTI->IMR1, EXTI_IMR1_IM5, EXTI_IMR1_IM5);
	SET_REG(EXTI->IMR1, EXTI_IMR1_IM6, EXTI_IMR1_IM6);
	SET_REG(EXTI->IMR1, EXTI_IMR1_IM7, EXTI_IMR1_IM7);
	SET_REG(EXTI->IMR1, EXTI_IMR1_IM9, EXTI_IMR1_IM9);*/

	EXTI->RTSR1 |= 0x2E0;
	EXTI->IMR1 |= 0x2E0;

	__enable_irq();

	//NVIC_EnableIRQ(23);

	//NVIC->STIR = 23;
	NVIC_SetPriority(EXTI9_5_IRQn, 0);
	NVIC_ClearPendingIRQ(EXTI9_5_IRQn);
	NVIC_EnableIRQ(EXTI9_5_IRQn);
	display(100);

	//display((NVIC->IABR[0] & (0x1 << 23)) >> 23);
}

void SystemClock_Config()
{
	//TODO: Setup system clock and SysTick timer interrupt
	SysTick_Config(400000);
}

void SysTick_Handler(void)
{
	GPIOA->ODR=GPIOA->ODR|10111<<8;
	//key_value++;
}

void EXTI9_5_IRQHandler(void)
{
	display(123);
	EXTI->PR1 |= (1<<5);
	EXTI->PR1 |= (1<<6);
	EXTI->PR1 |= (1<<7);
	EXTI->PR1 |= (1<<9);
}

int main(){
	/*GPIOA->PUPDR &= ~(0x3);
	GPIOA->PUPDR |= 0x1;
	GPIOA->OSPEEDR &= ~(0x3);
	GPIOA->OSPEEDR |= 0x1;*/


	GPIO_init();
	max7219_init();
	keypad_init();
	SystemClock_Config();
	EXTI_Setup();
	while(1)
	{

	}
//TODO: Enable or disable Systick timer
}


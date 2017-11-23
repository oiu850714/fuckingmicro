#include "stm32l476xx.h"

extern void GPIO_init();
extern void delay_1s();
int user_press_button()
{
	int counter = 45000;
	int debounce_flag = 0;
	while(counter--)
	{
		debounce_flag = (GPIOC->IDR & 0x2000);
		//fucking button is active low
		//so when button is not pressed, IDR & 0x2000 is not zero
	}
	return debounce_flag != 0x2000;
}
void SystemClock_Config(int frequency_option){

	//RCC->CFGR |= RCC_CFGR_SW_MSI;
	RCC->CFGR |= RCC_CFGR_SWS_MSI;

	RCC->PLLCFGR &= ~RCC_PLLCFGR_PLLREN;
	RCC->PLLCFGR &= ~RCC_PLLCFGR_PLLQEN;
	RCC->PLLCFGR &= ~RCC_PLLCFGR_PLLPEN;

	//step 1
	RCC->CR &= (~RCC_CR_PLLON);

	//step 2

	while((RCC->CR & RCC_CR_PLLRDY))
	{// true means PLL is "locked"???
		;
	}


	//step 3, phase 1
	RCC->PLLCFGR &= (~RCC_PLLCFGR_PLLR);
	RCC->PLLCFGR &= (~RCC_PLLCFGR_PLLN);
	RCC->PLLCFGR &= (~RCC_PLLCFGR_PLLM);
	RCC->PLLCFGR &= (~RCC_PLLCFGR_PLLSRC);

	//step 3, phase 2
	switch(frequency_option)
	{
	case 0://1MHz
		RCC->PLLCFGR |= RCC_PLLCFGR_PLLR;
		RCC->PLLCFGR |= RCC_PLLCFGR_PLLN_3;
		RCC->PLLCFGR |= (RCC_PLLCFGR_PLLM_0 | RCC_PLLCFGR_PLLM_1);
		break;
	case 1:
		RCC->PLLCFGR |= RCC_PLLCFGR_PLLR_1;
		RCC->PLLCFGR |= (RCC_PLLCFGR_PLLN_0 | RCC_PLLCFGR_PLLN_3);
		RCC->PLLCFGR &= (~RCC_PLLCFGR_PLLM);
		break;
	case 2:
		RCC->PLLCFGR |= RCC_PLLCFGR_PLLR_0;
		RCC->PLLCFGR |= (RCC_PLLCFGR_PLLN_1 | RCC_PLLCFGR_PLLN_3);
		RCC->PLLCFGR &= (~RCC_PLLCFGR_PLLM);
		break;
	case 3:
		RCC->PLLCFGR &= (~RCC_PLLCFGR_PLLR);
		RCC->PLLCFGR |= RCC_PLLCFGR_PLLN_3;
		RCC->PLLCFGR &= (~RCC_PLLCFGR_PLLM);
		break;
	case 4://40MHz
		RCC->PLLCFGR &= (~RCC_PLLCFGR_PLLR);
		RCC->PLLCFGR |= (RCC_PLLCFGR_PLLN_2 | RCC_PLLCFGR_PLLN_4);
		RCC->PLLCFGR &= (~RCC_PLLCFGR_PLLM);
		break;
	}
	RCC->PLLCFGR |= RCC_PLLCFGR_PLLSRC_MSI;

	//step 4
	RCC->CR |= RCC_CR_PLLON;

	while(!(RCC->CR & RCC_CR_PLLRDY))
	{// true means PLL is "locked"???
		;
	}


	//step 5
	RCC->PLLCFGR |= RCC_PLLCFGR_PLLREN;
	RCC->PLLCFGR |= RCC_PLLCFGR_PLLQEN;
	RCC->PLLCFGR |= RCC_PLLCFGR_PLLPEN;

	//last fuck
	//RCC->CFGR |= RCC_CFGR_SW_PLL;
	RCC->CFGR |= RCC_CFGR_SWS_PLL;

    //TODO: Change the SYSCLK source and set the corresponding Prescaler value.
}



int main(){
	SystemClock_Config(0);
	GPIO_init();
	int frequency_option = 1;
	while(1){
		/*if (user_press_button())
		{
			//Change_frequency(frequency_option++ % 5);
			SystemClock_Config(frequency_option++ % 5);
			//TODO: Update system clock rate
		}*/

		GPIOA->BSRR = (1<<5);
		delay_1s ();
		GPIOA->BRR = (1<<5);
		delay_1s ();

		frequency_option++;
		if(frequency_option == 10)
			SystemClock_Config(3);

	}
}

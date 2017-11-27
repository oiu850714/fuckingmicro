#include "stm32l476xx.h"
#define TIME_SEC 12.70
extern void GPIO_init();
extern void max7219_init();
extern void Display();
void Timer_init( TIM_TypeDef *timer)
{
    //TODO: Initialize timer
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
	SET_REG(TIM2->CR1, TIM_CR1_DIR , TIM_COUNTERMODE_DOWN);
	//down counter
	TIM2->ARR = (uint32_t)TIM_ARR_VAL;
	//Reload value
	TIM2->PSC = (uint32_t)TIME_SEC*(MSI_DEFAULT_FREQ/TIM_ARR_VAL);
	//Prescalser
	TIM2->EGR = TIM_EGR_UG;
	//Reinitialize the counte
}
void Timer_start(TIM_TypeDef *timer){
	TIM2->CR1 |= TIM_CR1_CEN;
	//start timer
	int pre_val = TIM_ARR_VAL;
	while(1){
		int timerValue = TIM2->CNT;
		//polling the counter value
		if(pre_val < timerValue){
			//check if times up
			TIM2->CR1 &= ~TIM_CR1_CEN;
			return;
		}
		pre_val = timerValue;
	int dis_val = TIME_SEC*100*timerValue/TIM_ARR_VAL;
	//convert counter value to time(seconds)
	Display_f(dis_val, 2);
	//display the time on the 7-SEG LED
	}
    //TODO: start timer and show the time on the 7-SEG LED.
}
int main()
{
   GPIO_init();
   max7219_init();
   Timer_init();
   Timer_start();
   while(1)
   {
	   ///////////////////////
	   ///////////////////////
	   ///////////////////////
	   // WATCH 009-MCSL-CounterTimer.pdf page 26???
	   ///////////////////////
	   ///////////////////////
	   //TODO: Polling the timer count and do lab requirements
   }
}


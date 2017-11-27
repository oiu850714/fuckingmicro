#include "stm32l476xx.h"
#define TIME_SEC 7.60
extern void GPIO_init();
extern void max7219_init();
extern void Display();


#define SET_REG(REG, SELECT, VAL) {((REG)=((REG)&(~(SELECT))) | (VAL));};
#define TIM_ARR_VAL 40000
#define PSC_FACTOR 1
#define SCAN_LIMIT_CMD 0x0B
#define SHUTDOWN_CMD 0x0C

void display(int n)
{
	int position = 1;
	if(n < 10)
	{
		max7219_send(1, n);
		max7219_send(2, 0);
		max7219_send(3, 0 | 0x80);
		max7219_send(SCAN_LIMIT_CMD, 2);
	}
	else if(n < 100)
	{
		max7219_send(1, n%10);
		max7219_send(2, n/10);
		max7219_send(3, 0 | 0x80);
		max7219_send(SCAN_LIMIT_CMD, 2);
	}
	else
	{
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
					if(position == 3)
					{
						max7219_send(position, n%10 | 0x80);
					}
					else
						max7219_send(position, n%10);
					n /= 10;
					position++;
				}
				max7219_send(SCAN_LIMIT_CMD, position-2);
			}
		}
	}

}


void Timer_init( TIM_TypeDef *timer)
{
    //TODO: Initialize timer
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
	SET_REG(timer->CR1, TIM_CR1_DIR , TIM_CR1_DIR);
	//down counter, DIR register only has one bit
	timer->ARR = (uint32_t)TIM_ARR_VAL;
	//Reload value
	//TIM2->PSC = (uint32_t)TIME_SEC*(MSI_DEFAULT_FREQ/TIM_ARR_VAL);
	//above?????
	timer->PSC = (uint32_t)PSC_FACTOR;
	//Prescaler
	timer->EGR = TIM_EGR_UG;
	//009, page 64
	//Reinitialize the counter
}
void Timer_start(TIM_TypeDef *timer){
	int display_time = 0;
	timer->CR1 |= TIM_CR1_CEN;
	//start timer
	int pre_val = TIM_ARR_VAL;
	while(1){
		int timerValue = timer->CNT;
		//polling the counter value
		if(pre_val < timerValue){
			//check if times up
			//timer->CR1 &= ~TIM_CR1_CEN;
			//return;
			timer->CNT = (uint32_t)TIM_ARR_VAL;
			display_time += 1;
		}
	pre_val = timerValue;
	//int dis_val = TIME_SEC*100*timerValue/TIM_ARR_VAL;
	int dis_val = timerValue;
	//convert counter value to time(seconds)
	display(10000-(dis_val/1000)*25/1000);
	display(timerValue/10);
	//display(timerValue);
	//display(pre_val);
	//display the time on the 7-SEG LED
	}
    //TODO: start timer and show the time on the 7-SEG LED.
}

void T_S(TIM_TypeDef *timer)
{
	timer->CR1 |= TIM_CR1_CEN;
	timer->CNT = (uint32_t)TIM_ARR_VAL;
	timer->EGR |= TIM_EGR_UG;
}
int main()
{
   GPIO_init();
   max7219_init();
   Timer_init(TIM2);
   T_S(TIM2);

   TIM_TypeDef *timer = TIM2;
   int display_time = 0;
   //start timer
   T_S(timer);
   while(1)
   {
	   if(timer->CNT < 20000)//counter count to ARR_VAL
	   {
		   display_time += 1;
		   T_S(timer);
	   }
	   display(display_time < TIME_SEC*100 ? display_time : TIME_SEC*100);
	   //Timer_start(TIM2);
	   ///////////////////////
	   ///////////////////////
	   ///////////////////////
	   // WATCH 009-MCSL-CounterTimer.pdf page 26???
	   // wait one second
	   ///////////////////////
	   ///////////////////////

	   ///////////////////////
	   ///////////////////////
	   // enable timer: page 55
	   ///////////////////////
	   ///////////////////////

	   ///////////////////////
	   ///////////////////////
	   // timer register: manual page 904
	   ///////////////////////
	   ///////////////////////

	   //TODO: Polling the timer count and do lab requirements
	   /*
	   int timerValue = timer->CNT;
	   int pre_val = TIM_ARR_VAL;
	   //polling the counter value
	   if(pre_val < timerValue){
		   //check if times up
		   //timer->CR1 &= ~TIM_CR1_CEN;
		   //return;
		   timer->CNT = (uint32_t)TIM_ARR_VAL;
		   display_time += 1;
	   }
	   pre_val = timerValue;
	   //int dis_val = TIME_SEC*100*timerValue/TIM_ARR_VAL;
	   int dis_val = timerValue;
	   //convert counter value to time(seconds)
	   //display(10000-(dis_val/1000)*25/1000);
	   //display(pre_val);
	   //display the time on the 7-SEG LED
	   */

   }
}


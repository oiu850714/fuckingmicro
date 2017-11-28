#include "stm32l476xx.h"
#define TIME_SEC 7.60
extern void GPIO_init();
extern void max7219_init();
extern void Display();


#define SET_REG(REG, SELECT, VAL) {((REG)=((REG)&(~(SELECT))) | (VAL));};


#define SCAN_LIMIT_CMD 0x0B
#define SHUTDOWN_CMD 0x0C
int TIM_ARR_VAL = 99;
int PSC_FACTOR = 0;
int CCR1_VAL = 50;
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
	GPIOA->ODR=GPIOA->ODR|10111<<8;
	// SET keypad gpio INPUT //
	//Set PB5,6,7,9 as INPUT mode
	GPIOB->MODER=GPIOB->MODER&0xFFF303FF;
	//set PB5,6,7,9 is Pull-down input
	GPIOB->PUPDR=GPIOB->PUPDR|0x8A800;
	//Set PB5,6,7,9 as medium speed mode
	GPIOB->OSPEEDR=GPIOB->OSPEEDR|0x45400;
}

unsigned char Table[4][4]
					   = {{13, 12, 11, 10},
						  {14, 9, 6, 3},
						  {0, 8, 5, 2},
						  {15, 7, 4, 1}};

#define B5679_IDR 0x2E0 //10_1110_0000
char keypad_scan()
{
	int flag_keypad = 0;
	int k = 0;
	int flag_debounce = 0;
	int position_c = 0, position_r = 0;
	int flag_keypad_r = 0;

	while(1)
	{
		GPIOA -> ODR = GPIOA -> ODR|0x1700;
		flag_keypad = GPIOB -> IDR&B5679_IDR;
		if(flag_keypad != 0){
			k = 45000;
			while(k != 0) {
				flag_debounce = GPIOB -> IDR&B5679_IDR;
				k--;
			}
		}
		if(flag_debounce != 0){
			for(int i = 0; i < 4; i++){ //scan keypad from first column
				position_c = i + 8;
				if(i == 3)
					position_c++;
				//set PA8,9,10,12(column) low and set pin high from PA8
				GPIOA -> ODR = (GPIOA -> ODR & 0xFFFFE8FF) | 1 << position_c;
				for(int j = 0; j < 4; j++){ //read input from first row
					position_r = j + 5;
					if(j == 3)
						position_r++;
					flag_keypad_r = GPIOB -> IDR & 1 << position_r;
					if(flag_keypad_r != 0)
						return Table[i][j];
				}
			}
		}
	}
	return -1;
}

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

void Timer_init( TIM_TypeDef *timer)
{
    //TODO: Initialize timer
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
	SET_REG(timer->CR1, TIM_CR1_DIR , TIM_CR1_DIR);
	timer->PSC = (uint32_t)PSC_FACTOR;
	timer->ARR = (uint32_t)TIM_ARR_VAL;

	TIM2->EGR = TIM_EGR_UG;
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

extern void GPIO_init();

void GPIO_init_AF(){
//TODO: Initial GPIO pin as alternate function for buzzer. You can choose to use C or assembly to finish this function.
	SET_REG(GPIOA->MODER, GPIO_MODER_MODE0, GPIO_MODER_MODE0_1); //set PA0 as AF mode
	SET_REG(GPIOA->AFR[0],  GPIO_AFRL_AFSEL0_0,  GPIO_AFRL_AFSEL0_0); //use AF1 for PA0(TIM2_CH1)
}



void PWM_channel_init(){
    //TODO: Initialize timer PWM channel
	SET_REG(TIM2 -> CCER, TIM_CCER_CC1E, TIM_CCER_CC1E); //set TIM2_CH1 as output
	// set PWM2
	SET_REG(TIM2 -> CCMR1, TIM_CCMR1_OC1PE, TIM_CCMR1_OC1PE);
	SET_REG(TIM2 -> CCMR1, TIM_CCMR1_OC1M_0 , TIM_CCMR1_OC1M_0);
    SET_REG(TIM2 -> CCMR1, TIM_CCMR1_OC1M_1 , TIM_CCMR1_OC1M_1);
	SET_REG(TIM2 -> CCMR1, TIM_CCMR1_OC1M_2 , TIM_CCMR1_OC1M_2);

	SET_REG(TIM2 -> CCR1, TIM_CCR1_CCR1 , CCR1_VAL);

}
int main(){
	GPIO_init();
    GPIO_init_AF();
    keypad_init();
	Timer_init(TIM2);
    PWM_channel_init();
    TIM_TypeDef *timer = TIM2;
    T_S(timer);
    SET_REG(timer->CR1, TIM_CR1_CEN , 0x0);
    while(1)
    {
    	int result = keypad_scan();
    	display(result);

    	if(result == 1)
    	{
    		PSC_FACTOR = 153;
    		Timer_init(TIM2);
    		SET_REG(timer->CR1, TIM_CR1_CEN , 0x1);
    	}
    	else if(result == 2)
		{
			PSC_FACTOR = 136;
			Timer_init(TIM2);
			SET_REG(timer->CR1, TIM_CR1_CEN , 0x1);
		}
    	else if(result == 3)
		{
			PSC_FACTOR = 122;
			Timer_init(TIM2);
			SET_REG(timer->CR1, TIM_CR1_CEN , 0x1);
		}
    	else if(result == 4)
		{
			PSC_FACTOR = 115;
			Timer_init(TIM2);
			SET_REG(timer->CR1, TIM_CR1_CEN , 0x1);
		}
    	else if(result == 5)
		{
			PSC_FACTOR = 102;
			Timer_init(TIM2);
			SET_REG(timer->CR1, TIM_CR1_CEN , 0x1);
		}
    	else if(result == 6)
		{
			PSC_FACTOR = 91;
			Timer_init(TIM2);
			SET_REG(timer->CR1, TIM_CR1_CEN , 0x1);
		}
    	else if(result == 7)
		{
			PSC_FACTOR = 83;
			Timer_init(TIM2);
			SET_REG(timer->CR1, TIM_CR1_CEN , 0x1);
		}
    	else if(result == 8)
    	{
    		PSC_FACTOR = 77;
			Timer_init(TIM2);
			SET_REG(timer->CR1, TIM_CR1_CEN , 0x1);
    	}
    	else if(result == 9)
		{
    		CCR1_VAL += 5;
    		if(CCR1_VAL > 90)
    			CCR1_VAL = 90;
    		PWM_channel_init();
		}
    	else if(result == 10)
		{
    		CCR1_VAL -= 5;
    		if(CCR1_VAL < 10)
    		    CCR1_VAL = 10;
    		PWM_channel_init();
		}

    	delay_1s();

    	SET_REG(timer->CR1, TIM_CR1_CEN , 0x0);
    }
    //TODO: Scan the keypad and use PWM to send the corresponding frequency square wave to buzzer.
}


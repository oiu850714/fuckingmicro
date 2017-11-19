#include "stm32l476xx.h"
//TODO: define your gpio pin
#define X0
#define X1
#define X2
#define X3
#define Y0
#define Y1
#define Y2
#define Y3

//unsigned int x_pin[4] = {X0, X1, X2, X3};
//unsigned int y_pin[4] = {Y0, Y1, Y2, Y3};
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);

/* TODO: initial keypad gpio pin, X as output and Y as input */
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

/* TODO: scan keypad value
 * return:
 * >=0: key pressed value
 * -1: no key press
*/

unsigned char Table[4][4]
					   = {{13, 12, 11, 10},
						  {14, 9, 6, 3},
						  {0, 8, 5, 2},
						  {15, 7, 4, 1}};

#define B5679_IDR 0x2E0 //10_1110_0000

int flags[4][4] = {0};
int keypad_scan()
{
	int flag_keypad = 0;
	int k = 0;
	int flag_debounce = 0;
	int position_c = 0, position_r = 0;
	int flag_keypad_r = 0;

	int all_button_sum = 0;
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
					if(flag_keypad_r != 0){
						if(i == 1 && j == 0 || i == 3 && j == 0)
						{
							return -2;
						}
						if(flags[i][j] == 0){
							all_button_sum += Table[i][j];
							flags[i][j] = 1;
						}
					}
				}
			}
			return all_button_sum;
		}
		else
		{	for(int i = 0; i < 4; i++)
			{
				for(int j = 0; j < 4; j++)
				{
					flags[i][j] = 0;
				}
			}
			return -1;
		}
	}
}

#define SCAN_LIMIT_CMD 0x0B

int main() {
	GPIO_init();
	max7219_init();
	keypad_init();

	int sum = 0;

	max7219_send(1, 0);
	max7219_send(SCAN_LIMIT_CMD, 0);
	//initialize 7-seg

	while(1)
	{
		int result = keypad_scan();
		if(result == -1)
			continue;
		else if(result == -2)
		{
			sum = 0;
		}
		//max7219_send(2, result/10);
		//max7219_send(1, result%10);
		sum += result == -2 ? 0 : result;
		int display_sum = sum;
		int position = 1;
		if(sum > 99999999)
			continue;
		do
		{
			max7219_send(position, display_sum%10);
			display_sum /= 10;
			max7219_send(SCAN_LIMIT_CMD, position - 1);
			position++;
		}
		while(display_sum);
	}
}

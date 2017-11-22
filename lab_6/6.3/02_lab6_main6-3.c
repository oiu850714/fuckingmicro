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
int queue_opr[100];
int queue_opd[100];
int front_opr = 0;
int	rear_opr = 0;
int	front_opd = 0;
int	rear_opd = 0;
int	ptr = 0;
#define SCAN_LIMIT_CMD 0x0B
#define SHUTDOWN_CMD 0x0C

unsigned char Table[4][4]
					   = {{13, 12, 11, 10},
						  {14, 9, 6, 3},
						  {0, 8, 5, 2},
						  {15, 7, 4, 1}};

#define B5679_IDR 0x2E0 //10_1110_0000

int keypad_scan()
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
				max7219_send(position, n%10);
				n /= 10;
				position++;
			}
			max7219_send(SCAN_LIMIT_CMD, position-2);
		}
	}

}

void push_opd(int n)
{
	queue_opd[rear_opd] = n;
	rear_opd++;
}
void push_opr(int n)
{
	queue_opr[rear_opr] = n;
	rear_opr++;
}

int pop_opd_back()
{
	return queue_opd[--rear_opd];
}

int pop_opd_front()
{
	return queue_opd[front_opd++];
}

int pop_opr()
{
	return queue_opr[front_opr++];
}





int main() {
	GPIO_init();
	max7219_init();
	keypad_init();



	max7219_send(1, 0);
	max7219_send(SCAN_LIMIT_CMD, 0);
	//initialize 7-seg
	max7219_send(SHUTDOWN_CMD, 0);
	int num = 0;
	int sum = 0;
	int flag1 = 0; //mul or div
	int flag2 = 0; //check continuous operator

	while(1)
	{
		int reset = 0; //reset

		while(1)
		{

			int result = keypad_scan();

			if(result == -1) //no push
				continue;
			else if(result == 14) //reset
			{
				max7219_send(SHUTDOWN_CMD, 0);
				reset = 1;
				break;
			}
			else if(result == 15) //equal
			{
				if(flag1 == 1)
				{
					int tmp = pop_opd_back();
					num = tmp * num;
					flag1 = 0;
				}
				else if(flag1 == 2)
				{
					int tmp = pop_opd_back();
					num = tmp / num;
					flag1 = 0;
				}
				push_opd(num);
				flag2 = 0;
				break;
			}
			else if(result < 10) //operand
			{
				max7219_send(SHUTDOWN_CMD, 1);
				flag2 = 0;
				if((num * 10 + result) < 1000)
				{
					num = num * 10 + result;
					display(num);
				}
			}
			else if(flag2 == 0)  //operator
			{
				max7219_send(SHUTDOWN_CMD, 0);
				if(flag1 == 1)
				{
					int tmp = pop_opd_back();
					num = tmp * num;
					flag1 = 0;
				}
				else if(flag1 == 2)
				{
					int tmp = pop_opd_back();
					num = tmp / num;
					flag1 = 0;
				}

				push_opd(num);
				flag2 = 1;
				if(result == 10)
				{
					push_opr(0);
					flag1 = 0;
				}
				else if(result == 11)
				{
					push_opr(1);
					flag1 = 0;
				}
				else if(result == 12)
				{
					flag1 = 1;
				}
				else if(result == 13)
				{
					flag1 = 2;
				}
				num = 0;
			}
		}

		if(reset)
		{
			front_opr = 0;
			rear_opr = 0;
			front_opd = 0;
			rear_opd = 0;
			ptr = 0;
			num = 0;
			sum = 0;
			flag1 = 0;
			flag2 = 0;
			display(0);
		}
		else
		{
			sum = pop_opd_front();
			//(pop_opd_front());
			while(front_opd != rear_opd)
			{
				int opr_tmp = pop_opr();
				if(opr_tmp == 0)
				{
					sum += pop_opd_front();
					//display(111);
				}
				else if(opr_tmp == 1)
				{
					sum -= pop_opd_front();
				}
			}
			num = sum;
			display(sum);
		}
	}

}

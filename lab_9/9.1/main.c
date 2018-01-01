#include "gpio.h"
#include "stm32l476xx.h"
#include <string.h>

#define SET_REG(REG, SELECT, VAL) {((REG)=((REG)&(~(SELECT))) | (VAL));};

void GPIO_Init()
{
	RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN | RCC_AHB2ENR_GPIOCEN); // UART
	TM_GPIO_Init(GPIOA, 2, TM_GPIO_Mode_AF, TM_GPIO_OType_PP, TM_GPIO_PuPd_NOPULL, TM_GPIO_Speed_Low);
	TM_GPIO_Init(GPIOA, 3, TM_GPIO_Mode_AF, TM_GPIO_OType_PP, TM_GPIO_PuPd_NOPULL, TM_GPIO_Speed_Low);
	GPIOA->AFR[0] = (GPIOB->AFR[0] & ~(0x0000FF00)) | 0x00007700; // AF7 for pin
}

void UART_Init()
{
	RCC->AHB1ENR |= RCC_APB1ENR1_USART2EN;

	//asynchronous
	USART2->CR2 &= ~(USART_CR2_LINEN | USART_CR2_CLKEN);
	USART2->CR3 &= ~(USART_CR3_SCEN | USART_CR3_HDSEL | USART_CR3_IREN);

	SET_REG(USART2->CR1,
			USART_CR1_M |  USART_CR1_M | USART_CR1_PS | USART_CR1_PCE |
			USART_CR1_TE | USART_CR1_RE | USART_CR1_OVER8, USART_CR1_TE | USART_CR1_RE);

	SET_REG(USART2->BRR, 0xFF, 4000000L/9600L);
	SET_REG(USART2->CR2, USART_CR2_STOP, 0);
	USART2->CR1 |= (USART_CR1_UE);


}

void UART_transmit(char *arr, uint32_t size)
{
	for (int i = 0; i < size; i++)
	{
		USART2->TDR = arr[i];
		while (!(USART2->ISR & 0x40)); //TC is bit 6
	}
}

int main()
{
	GPIO_Init();
	UART_Init();
	char arr[] = "ABC";
	UART_transmit(arr, strlen(arr));
}

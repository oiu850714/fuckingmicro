.syntax unified
.cpu cortex-m4
.thumb

.data
	leds: .byte 0
	password: .byte 11

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 0x4800040C
	.equ GPIOB_ODR, 0x48000414
	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_PUPDR, 0x4800080C
	.equ GPIOC_IDR, 0x48000810
	.equ initial, 0xFFFFFFFF
	.equ light, 0xFFFFFF87
	.equ extinguish, 0xFFFFFF78
	.equ DEBOUNCE_upperbound, 0xFFFF
	.equ X, 800
	.equ Y, 800


main:

	BL   GPIO_init

Loop:
	//TODO: Write the display pattern into leds variable
	ldr		r8, =GPIOC_IDR
	ldr		r8, [r8]
	movs    r7, #0;
	movs    r8, #0;
	ldr     r9, =DEBOUNCE_upperbound
	BL      CHECK_BUTTON
	BL		DisplayLED
	B		Loop

GPIO_init:
	//TODO: Initial LED GPIO pins as output
	//Enable clock
	movs r0, #6
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]

	//Set PB3~6 as output mode
	movs r0, #0x1540
	ldr r1, =GPIOB_MODER
	ldr r2, [r1]
	and r2, #0xFFFFC03F
	orrs r2, r2, r0
	str r2, [r1]

	movs r0, #0x2A80
	ldr r1, =GPIOB_OSPEEDR
	strh r0, [r1]

	ldr r1, =GPIOB_ODR
	ldr r2, =initial
	strh r2, [r1]
	//Set PC0~3&13 as input mode
	ldr r1, =GPIOC_MODER
	ldr r0, [r1]
	ldr r2, =#0xF3FFFF00
	and r0, r2
	str r0, [r1]
	//Set data register address
	/*ldr r2, =GPIOC_IDR
	ldr r3, [r2]
	movs r4, #1
	lsl r4, #13
	ands r3, r4
	beq do_pushed*/

	BX LR

DisplayLED:
	ldr r10, =GPIOB_ODR
	//ldr r2, =GPIOC_IDR
	//ldr r3, [r2]
	//lsl r3, #3
	//strh r3, [r1]
	ldr r11, =light
	ldr r12, =extinguish
	cmp  r7, #1
	bne PASSWORD_WRONG

	movs r6, lr

	strh r11, [r10]
	bl Delay
	strh r12, [r10]
	bl Delay
	strh r11, [r10]
	bl Delay
	strh r12, [r10]
	bl Delay
	strh r11, [r10]
	bl Delay
	strh r12, [r10]
	movs lr, r6
	BX LR
PASSWORD_WRONG:
	movs r6, lr

	strh r11, [r10]
	bl Delay
	strh r12, [r10]

	movs lr, r6

	BX LR
CHECK_BUTTON:
	ldr		r10, =GPIOC_IDR
	ldr		r11, [r10]
	movs	r12, #1
	lsl		r12, #13
	ands	r11, r12
	bne		set_counter_to_zero
	add		r8, #1
	cmp		r8, r9
	beq		CHECK_PASSWORD
	b 		CHECK_BUTTON
set_counter_to_zero:
	mov		r8, #0
	b		CHECK_BUTTON
CHECK_PASSWORD:
	ldr		r8, =password
	ldr		r8, [r8]
	ldr		r10, =GPIOC_IDR
	ldr		r11, [r10]
	movs	r12, #0xF
	and		r12, r11, r12
	eor     r12, #0xF
	cmp 	r8, r12
	bne 	NOT_MATCH
	movs	r7, #1
	bx lr
NOT_MATCH:
	movs	r7, #0
	bx lr
Delay:
	//TODO: Write a delay 1sec function
	ldr r3, =X
L1:
	ldr r4, =Y
L2:
	subs r4, #1
	bne L2
	subs r3, #1
	bne L1
	bx lr
	BX LR
L:
	B L

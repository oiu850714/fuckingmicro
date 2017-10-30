	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr: .byte 0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x73, 0x77, 0x1F, 0x4E, 0x3D, 0x4F, 0x47 //TODO: put 0 to F 7-Seg LED pattern here

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_BASE, 0x48000000
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDER, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_IDR, 0x48000010
	.equ GPIOA_ODR, 0x48000014
	.equ GPIO_BSRR_OFFSET, 0x18
	.equ GPIO_BRR_OFFSET, 0x28


	.equ DIGIT_0, 0x01
	.equ DECODE_MODE, 0x09
	.equ DISPLAY_TEST, 0x0F
	.equ SCAN_LIMIT, 0x0B
	.equ INTENSITY, 0x0A
	.equ SHUTDOWN, 0x0C
	.equ DATA, 0x20
	.equ LOAD, 0x40
	.equ CLOCK, 0x80

	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_IDR, 0x48000810
	.equ LONG_PRESSED_UPPER, 0x0001FFFF

	.equ X, 1200
	.equ Y, 1200

main:
    BL   GPIO_init
    BL   max7219_init
    movs r2, #0
	movs r3, #1
	mov  r0, #0x1
	mov  r1, #0x0
	BL MAX7219Send
	//----------shitty copy and paste---------------
	ldr r0, =SCAN_LIMIT
	mov r1, #0x0 //all LED shoud turned on, i.e seg0 to seg7
	BL MAX7219Send
	//----------shitty copy and paste end-----------
	BL CHECK_BUTTON_reset_r8
	mov r2, #1
	mov r3, #1

fib:
	movs r4, #0 // r4 is which seg need to print
	mov r5, r2 // initialize fib number
loop:
	mov r0, #10 // use to exract most right decimal
	cmp r5, #0
	bne not_zero
zero:
	push {r2, r3, r4}
	//----------shitty copy and paste---------------
	ldr r0, =SCAN_LIMIT
	mov r1, r4 //all LED shoud turned on, i.e seg0 to seg7
	sub r1, #1
	BL MAX7219Send
	//----------shitty copy and paste end-----------
	pop {r2, r3, r4}
	BL CHECK_BUTTON_reset_r8
	add r5, r2, r3
	mov r2, r3
	mov r3, r5
	b fib
not_zero:	//calcalate val % 10
	add r4, #1
	cmp r4, #9
	bne not_overflow
overflow:
	mov r1, 1
	mov r0, 1
	BL MAX7219Send
	mov r1, 10
	mov r0, 2
	BL MAX7219Send
	//----------shitty copy and paste---------------
	ldr r0, =SCAN_LIMIT
	mov r1, #1 //all LED shoud turned on, i.e seg0 to seg7
	BL MAX7219Send
	//----------shitty copy and paste end-----------
over_flow_busy_loop:
	BL CHECK_BUTTON_reset_r8
	cmp		r2, #1
	beq		fib
	b		over_flow_busy_loop
not_overflow:
	udiv r1, r5, r0
	mul r1, r1, r0
	sub r1, r5, r1
	//calcalate which decimal bit need to print
	push {r0, r2, r3, r4, r5}
	mov r0, r4
	BL MAX7219Send
	//BL delay
	pop {r0, r2, r3, r4, r5}
	udiv r5, r5, r0
	b loop

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	movs r0, #0x5 // 5 is 3'b101, turn on port A and port C
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]

	ldr r1, =GPIOA_MODER
	ldr r2, =#0xABFF5400
	str r2, [r1]

	// --------- set PC13 ---------

	//Set GPIOC Pin13 as input mode
	ldr		r1, =GPIOC_MODER
	ldr		r0, [r1]
	ldr		r2, =#0xF3FFFFFF
	and		r0, r2
	str		r0, [r1]
	//Set data register	address

	BX LR



MAX7219Send:
   //input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r1, =GPIOA_BASE
	ldr r2, =LOAD
	ldr r3, =DATA
	ldr r4, =CLOCK
	ldr r5, =GPIO_BSRR_OFFSET
	ldr r6, =GPIO_BRR_OFFSET
	mov r7, #16
.max7219send_loop:
	mov r8, #1
	sub r9, r7, #1
	lsl r8, r8, r9 // r8 = mask
	str r4, [r1,r6]//HAL_GPIO_WritePin(GPIOA, CLOCK, 0);
	tst r0, r8
	beq .bit_not_set//bit not set
	str r3, [r1,r5]
	b .if_done
.bit_not_set:
	str r3, [r1,r6]
.if_done:
	str r4, [r1,r5]
	subs r7, r7, #1
	bgt .max7219send_loop
	str r2, [r1,r6]
	str r2, [r1,r5]

	BX LR

max7219_init:
	//TODO: Initialize max7219 registers
	push {lr}
	push {r2}
	push {r1}
	push {r0}

	ldr r0, =DECODE_MODE
	ldr r1, =#0xFF //all 7-set use decode mode, i.e. 11111111
	BL MAX7219Send
	ldr r0, =DISPLAY_TEST
	ldr r1, =#0x0
	BL MAX7219Send
	ldr r0, =SCAN_LIMIT
	ldr r1, =0x7 //all LED shoud turned on, i.e seg0 to seg7
	BL MAX7219Send
	ldr r0, =INTENSITY
	ldr r1, =#0xA
	BL MAX7219Send
	ldr r0, =SHUTDOWN
	ldr r1, =#0x1
	BL MAX7219Send

	pop {r0}
	pop {r1}
	pop {r2}
	pop {pc}
	BX LR

CHECK_BUTTON_reset_r8:
	mov		r8, #0
CHECK_BUTTON:
	ldr		r10, =GPIOC_IDR
	ldr		r11, [r10]
	movs	r12, #1
	lsl		r12, #13
	ands	r11, r12
	bne		set_counter_to_zero
	add		r8, #1
	b 		CHECK_BUTTON
set_counter_to_zero:
	ldr		r9, =LONG_PRESSED_UPPER
	cmp		r8, r9
	blt		counter_less_than_long_pressed
counter_greater_than_long_pressed:
	mov		r1,	#0
	mov		r0, #1
	push	{lr}
	bl		MAX7219Send
	ldr 	r0, =SCAN_LIMIT
	mov 	r1, #0x0 //all LED shoud turned on, i.e seg0 to seg7
	BL MAX7219Send
	pop		{lr}
	mov		r2, #1
	mov		r3, #1
	push	{lr}
	bl		CHECK_BUTTON_reset_r8
	pop		{lr}
	bx		lr
counter_less_than_long_pressed:
	ldr		r9, =0xFFF
	cmp		r8, r9
	blt		counter_less_than_debounced
cal_next_fin_numbders:
	bx		lr
counter_less_than_debounced:
	b		CHECK_BUTTON_reset_r8

set_limit:
	ldr r0, =SCAN_LIMIT
	ldr r1, =0x7 //all LED shoud turned on, i.e seg0 to seg7
	BL MAX7219Send

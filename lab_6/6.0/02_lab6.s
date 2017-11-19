	.syntax unified
	.cpu cortex-m4
	.thumb


.text
	.global GPIO_init
	.global max7219_send
	.global max7219_init

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


GPIO_init:
	// In the prologue, push r4 to r11 to the stack,
	// and push the return address in r14, to the stack.
	push {r4, r5, r6, r7, r8, r9, r10, r11, lr}
	// Copy any passed arguments (in r0 to r3)
	// to the local scratch registers (r4 to r11).
	/* no parameters */


	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	movs r4, #0x1
	ldr r5, =RCC_AHB2ENR
	str r4, [r5]

	ldr r5, =GPIOA_MODER
	ldr r6, =#0xABFF5400
	str r6, [r5]

	pop {r4, r5, r6, r7, r8, r9, r10, r11, lr}

	BX LR


max7219_send:
   //input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219


	// In the prologue, push r4 to r11 to the stack,
	// and push the return address in r14, to the stack.
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}
	// Copy any passed arguments (in r0 to r3)
	// to the local scratch registers (r4 to r11).


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


	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}

	BX LR

max7219_init:
	//TODO: Initialize max7219 registers
	/*
	push {lr}
	push {r2}
	push {r1}
	push {r0}
	*/

	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}

	ldr r0, =DECODE_MODE
	ldr r1, =#0x7F
	BL max7219_send
	ldr r0, =DISPLAY_TEST
	ldr r1, =#0x0
	BL max7219_send
	ldr r0, =SCAN_LIMIT
	ldr r1, =0x6
	BL max7219_send
	ldr r0, =INTENSITY
	ldr r1, =#0xA
	BL max7219_send
	ldr r0, =SHUTDOWN
	ldr r1, =#0x1
	BL max7219_send

	/*
	pop {r0}
	pop {r1}
	pop {r2}
	pop {pc}
	*/
	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, pc}
	BX LR

.syntax unified
.cpu cortex-m4
.thumb

.data
leds: .byte 0


.text
.global main
.equ RCC_AHB2ENR, 0x4002104C
.equ GPIOB_MODER, 0x48000400
.equ GPIOB_OTYPER, 0x48000404
.equ GPIOB_OSPEEDR, 0x48000408
.equ GPIOB_PUPDR, 0x4800040C
.equ GPIOB_ODR, 0x48000414

.equ X, 1200
.equ Y, 1200
.equ MASK, 0x3C0 // 00...001111000000
.equ INITIAL_STATE, 0xFFFFFF9F
.equ TURN_ON_PB3456 , 0xFFFFC030

main:
	//Enable GPIO port B
	movs	r0, #0x2
	ldr		r1, =RCC_AHB2ENR
	str		r0, [r1]

	//Set PB3-PB6 as output mode
	movs	r0, #0x1540
	ldr		r1, =GPIOB_MODER
	ldr		r2, [r1]
	//and		r2, #0xFFFFC030 // Mask MODERS
	ldr 	r3, =TURN_ON_PB3456
	and		r2, r3
	//and		r2, #0xFFFFCFFF
	//and		r2, #0xFFFFF0FF
	//and		r2, #0xFFFFFF3F
	//and		r2, #0xFFFFFFF0
	orrs	r2, r2, r0
	str		r2, [r1]

	//Default PB4 is Pull-up output, no need to set
	/*
	//Set PB4 as high speed mode
	movs	r0, #0x200
	ldr		r1, =GPIOB_OSPEEDR
	strh	r0, [r1]
	*/
	/*
	movs	r0, #0x200
	ldr		r1, =GPIOB_PUPDR
	strh	r0, [r1]
	*/
/*L:
	movs	r0,	#120

	//movs	r0, #(1<<5)
	strh	r0, [r1]
	B L
*/
	ldr		r1, =GPIOB_ODR
	ldr		r2, =MASK
	ldr		r5, =leds

LOOP:
	//movs	r0, #0
	//subs	r0, r0, #225
	//r0 = 0xFFFFFF9F
	//---------------- turn left -------------
	ldr r0, =INITIAL_STATE
	and		r3, r0, r2
	lsr		r3, #3
	strh	r3, [r1]
	//store to GPIO output
	bl UPDATE_leds
	bl	Delay
	bl TURN_LEFT
	bl UPDATE_leds
	bl	Delay
	bl TURN_LEFT
	bl UPDATE_leds
	bl	Delay
	bl TURN_LEFT
	bl UPDATE_leds
	bl	Delay
	bl TURN_LEFT
	bl UPDATE_leds
	//------------- turn right -------------
	bl	Delay
	bl TURN_RIGHT
	bl UPDATE_leds
	bl	Delay
	bl TURN_RIGHT
	bl UPDATE_leds
	bl	Delay
	bl TURN_RIGHT
	bl UPDATE_leds
	bl	Delay
	b	LOOP

Delay:
	ldr		r3, =X
L1:	ldr		r4, =Y
L2:	subs	r4, #1
	bne		L2
	subs	r3, #1
	bne		L1
	bx		LR


UPDATE_leds:
	mov		r4, r3
	lsr		r4, #3
	eor		r4, 0xF
	strb	r4, [r5]
	bx lr

TURN_LEFT:
	lsl		r0, #1
	and		r3, r0, r2
	lsr		r3, #3
	strh	r3, [r1]
	bx lr

TURN_RIGHT:
	lsr		r0, #1
	and		r3, r0, r2
	lsr		r3, #3
	strh	r3, [r1]
	bx lr

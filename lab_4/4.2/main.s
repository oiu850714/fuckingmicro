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
.equ GPIOC_MODER, 0x48000800

.equ X, 800
.equ Y, 800
.equ MASK, 0x3C0 // 00...001111000000
.equ INITIAL_STATE, 0xFFFFFF9F
.equ TURN_ON_PB3456 , 0xFFFFC030
.equ GPIOC_IDR, 0x48000810
.equ DEBOUNCE_upperbound, 0xFFFF
.equ DEBOUNCE_in_stop_state, 0x3fff

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

	// --------- set PC13 ---------
	movs	r0, #0x6
	ldr		r1, =RCC_AHB2ENR
	str		r0, [r1]

	//Set GPIOC Pin13 as input mode
	ldr		r1, =GPIOC_MODER
	ldr		r0, [r1]
	ldr		r2, =#0xF3FFFFFF
	and		r0, r2
	str		r0, [r1]
	//Set data register	address
	/*
	ldr		r2, =GPIOC_IDR
	ldr		r3, [r2]
	movs	r4, #1
	lsl		r4, #13
	ands	r3, r4
	beq		do_pushed
	*/

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

	movs	r8, #0 // counter
	ldr		r9, =DEBOUNCE_upperbound

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
	movs	r7,	lr
	ldr		r3, =X
L1:	ldr		r4, =Y
	bl CHECK_BOTTON
L2:	subs	r4, #1
	bne		L2
	subs	r3, #1
	bne		L1
	movs	lr, r7
	bx		LR



CHECK_BOTTON:
	ldr		r10, =GPIOC_IDR
	ldr		r11, [r10]
	movs	r12, #1
	lsl		r12, #13
	ands	r11, r12
	bne		set_counter_to_zero
	add		r8, #1
	cmp		r8, r9
	beq		STOP_turn_led
	b 		CHECK_BOTTON

set_counter_to_zero:
	mov		r8, #0
	b return_check_botton
STOP_turn_led:
	mov		r8, #0
leave_botton:
	ldr		r10, =GPIOC_IDR
	ldr		r11, [r10]
	movs	r12, #1
	lsl		r12, #13
	ands	r11, r12
	beq		STOP_turn_led
	add		r8, #1
	cmp		r8, r9
	bne		leave_botton
in_stop_state_set_counter_to_zero:
	mov		r8, #0
stop_state_looping:
	ldr		r11, [r10]
	movs	r12, #1
	lsl		r12, #13
	ands	r11, r12
	bne		in_stop_state_set_counter_to_zero // user not push botton, go to STOP_turn_led to set counter to zero
	add		r8, #1
	cmp		r8, r9
	bne		stop_state_looping
set_botton_0:
	mov		r8, #0
leave_botton_2:


	ldr		r10, =GPIOC_IDR
	ldr		r11, [r10]
	movs	r12, #1
	lsl		r12, #13
	ands	r11, r12
	beq		set_botton_0
	add		r8, #1
	cmp		r8, r9
	bne		leave_botton_2

continuing_turning_led:
	mov		r8, #0
return_check_botton:
	bx lr


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

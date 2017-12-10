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



//A-2, LED is plug in PB3
.equ X1, 0x8
.equ X2, 0x0
.equ Y1, 0x1
.equ Y2, 0x8
.equ ONLY_TURN_PB3, 0xFFF7 //111...110111
.equ TURN_OFF_ALL_LED, 0xFFFF

main:
    //Enable GPIO port B
    movs    r0, #0x2
    ldr     r1, =RCC_AHB2ENR
    str     r0, [r1]

    //Set PB3-PB6 as output mode
    movs    r0, #0x1540
    ldr     r1, =GPIOB_MODER
    ldr     r2, [r1]
    //and       r2, #0xFFFFC030 // Mask MODERS
    ldr     r3, =TURN_ON_PB3456
    and     r2, r3
    orrs    r2, r2, r0
    str     r2, [r1]

    ldr     r1, =GPIOB_ODR
    ldr     r2, =MASK
    ldr     r5, =leds

    ldr     r9, =TURN_OFF_ALL_LED
    strh    r9, [r1]
    ldr     r6, =X1
    ldr     r7, =X2
    sub     r6, r6, r7
    mul     r6, r6, r6// (X1- X2)^2

    ldr     r7, =Y1
    ldr     r8, =Y2
    sub     r7, r7, r8
    mul     r7, r7, r7// (Y1- Y2)^2

    add     r8, r6, r7
    cmp     r8, #100
    bgt     TURN_LED
    b       B
TURN_LED:
    ldr     r0, =ONLY_TURN_PB3
    strh    r0, [r1]
B:
    b   B

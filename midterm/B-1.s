    .syntax unified
    .cpu cortex-m4
    .align

.data
    store_int_array: .zero 128
    expr_result: .word 0
    arr: .byte 0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x73, 0x77, 0x1F, 0x4E, 0x3D, 0x4F, 0x47 //TODO: put 0 to F 7-Seg LED pattern here

.text
    .global main
    str: .asciz "8888 8666 1992 110 864 76"
    //str: .ascii "-8000 100 30 + - 10 -"
    //str: .asciz "-100 10 +"
    .equ mark, 0xFFFF


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

    .equ X, 1200
    .equ Y, 1200


main:
//TODO: Setup stack pointer to end of user_stack and calculate the expression using PUSH, POP operators, and store the result into expr_result
    ldr r0, =str
    mov r1, r0 // start address of the token
    ldr r2, =store_int_array
    mov r11, #0 //r11 is the flag that will be used later, see code below..
while_having_token:
    ldrb    r10, [r0] // r5 store the actual char
    cmp     r10, #0 // end of string
    beq     start_sort // need extract last token
    cmp     r10, #32 // char is ' '
    beq atoi
    b not_extracted_token
extracted_token:
    add r0, #1
    mov r1, r0 // update next token's starting address
    b while_having_token
not_extracted_token:
    add r0, #1
    b while_having_token

sorted:
    push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}
    BL   GPIO_init
    BL   max7219_init
    pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}

    add r2, #2 // point to address after last element

loop:
    movs r10, #0
    BL   Display0toF
    B loop

Display0toF:
    //TODO: Display 0 to F at first digit on 7-SEG LED. Display one per second.
    push {lr}
Display0toF_LOOP:
    ldr r7, =store_int_array
    ldrh r9, [r7, r10]
    mov r0, 0 //nth_digit

while_have_digit_to_send:
    mov r4, #10
    udiv r5, r9, r4
    mul r5, r5, r4
    sub r1, r9, r5 // now r1 is rightmost decimal digit
    udiv r9, r9, r4

    add r0, #1
    push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}
    BL MAX7219Send
    pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}
    push {r0, r1}
    mov r1, r0
    sub r1, #1
    ldr r0, =SCAN_LIMIT
    //r0, r1 will be changed by set scan limit, so it also needs push
    push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}
    BL MAX7219Send
    pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}
    pop {r0, r1}

    cmp r9, #0
    bne while_have_digit_to_send

    push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}
    BL Delay
    pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}

    //r2 should be the last degit's address
    add r10, #2
    add r8, r7, r10 // r7 is sorted array
    cmp r8, r2
    bne Display0toF_LOOP

    pop {pc}

    BX LR


L: b L

atoi:
    //TODO: implement a "convert string to integer" function

    //now r1 is address of first charactor of token, r0 is addfress of space
    mov r5, r1 // r5 is iterator

    mov r6, #0 // r6 store tmp calculated integer

while_having_character:
    mov r9, #10
    ldrb r7, [r5]
    mul r6, r6, r9 // r9 is 10
    sub r7, r7, #48
    add r6, r6, r7
    add r5, r5, #1
    cmp r5, r0
    bne while_having_character

    strh r6, [r2] // r2 is store_int_array + ith int's address
    add r2, #2 // because use half word, so address += 2

    cmp r11, #1
    bne extracted_token
    beq extract_last_token
/*
while_having_character:
    ldrb r7, [r5]
    sub r7, r7, #48
    mul r6, r6, r9 // r9 is 10
    add r6, r6, r7
    add r5, r5, #1
    cmp r5, r3
    bne while_having_character
only_one_char:
    mul r6, r6, r8
    push {r6}
    BX LR
*/


start_sort:
    mov r11, #1 // r11 is flag saying the atoi is from start_sort
    b atoi
extract_last_token:
    /*
    ldrh    r12, =mark
    str     r12, [r2]
    add     r2, #2
    */
    sub     r2, #2 // let r2 point "on" last integer
    ldr r0, =store_int_array



    mov r3, #0 // int i = 0

do_sort:
    add r3, #2 // two byte
    mov r4, #0 // int j = 0

do_sort_inner:


    //r0 =arr1
    ldrh r5, [r0, r4]
    add r4, #2 // an int is two byte, so +2
    ldrh r6, [r0, r4]
    // r5 = arr1[j], r6 = arr[j+1]

    cmp r5, r6
    blt do_not_swap

    strh r5, [r0, r4]
    mov r7, r4
    sub r7, r7, #2 // fuck, two byte so -2
    strh r6, [r0, r7]

do_not_swap:
    //leave inner loop
    //cmp r4, #7
    add r8, r0, r4
    //add r8, #2 // notice that cmp r4, #7
    cmp r8, r2
    bne do_sort_inner

    add r8, r0, r3
    cmp r8, r2
    bne do_sort
    //leave outer loop

    b sorted


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
    ldr r1, =#0x7F
    BL MAX7219Send
    ldr r0, =DISPLAY_TEST
    ldr r1, =#0x0
    BL MAX7219Send
    ldr r0, =SCAN_LIMIT
    ldr r1, =0x0
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

Delay:
    //TODO: Write a delay 1sec function
        ldr     r3, =X
    L1: ldr     r4, =Y
    L2: subs    r4, #1
        bne     L2
        subs    r3, #1
        bne     L1
        bx      LR
    BX LR

GPIO_init:
    //TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
    movs r0, #0x1
    ldr r1, =RCC_AHB2ENR
    str r0, [r1]

    ldr r1, =GPIOA_MODER
    ldr r2, =#0xABFF5400
    str r2, [r1]

    BX LR


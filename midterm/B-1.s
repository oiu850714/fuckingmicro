    .syntax unified
    .cpu cortex-m4
    .align

.data
    store_int_array: .zero 128
    expr_result: .word 0

.text
    .global main
    str: .asciz "5 6 0 30 24"
    //str: .ascii "-8000 100 30 + - 10 -"
    //str: .asciz "-100 10 +"
    .equ mark, 0xFFFF
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

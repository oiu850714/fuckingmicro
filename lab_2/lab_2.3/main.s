.data
	arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC

.text
	.global main

do_sort:
	add r3, #1
	mov r4, #0 // int j = 0

do_sort_inner:


	//r0 =arr1
	ldrb r5, [r0, r4]
	add r4, #1
	ldrb r6, [r0, r4]
	// r5 = arr1[j], r6 = arr[j+1]

	cmp r5, r6
	blt do_not_swap

	strb r5, [r0, r4]
	mov r7, r4
	sub r7, r7, #1
	strb r6, [r0, r7]

do_not_swap:
	//leave inner loop
	cmp r4, #7
	bne do_sort_inner

	cmp r3, #8
	bne do_sort
	//leave outer loop

	bx lr

main:
	ldr r0, =arr1
	mov r3, #0 // int i = 0
	bl do_sort
	ldr r0, =arr2
	mov r3, #0 // int i = 0
	bl do_sort

	nop

L : b L


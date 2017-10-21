.syntax unified
.cpu cortex-m4
.thumb

.data
	result: .byte 0
.text
	.global main
	.equ X, 0x55AA
	.equ Y, 0xAA55

hamm:
	//TODO
	//mov R2, #5 mod 2
	mov r2, #1 //mask
	and r2, r2, r1
	add R3, R3, R2
	lsrs R1, R1, #1
	cmp r1, #0
	bne hamm
	bx lr

main:
	//movs R0, #X
	//movs R1, #Y

	ldr R0, =X
	ldr R1, =Y

	eor R1, R0, R1
	// now R1 is X xor Y
	mov r3, #0 // rs = hamm distance
	bl hamm

	ldr r4, =result
	str r3, [r4]
L: b L

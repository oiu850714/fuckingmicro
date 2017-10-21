	.syntax unified
	.cpu cortex-m4
	.thumb
	.align

.data
	result: .word  0
	max_size:  .word  0
.text
	.global main
	m: .word  0x5EEE4
	n: .word  0x6EE21

	//m: .word  0x
	//n: .word  0x60

main:

	mov r8, #0

	ldr r0, =m // number1
	ldr r0, [r0]
	ldr r1, =n // number2
	ldr r1, [r1]
	mov r2, #1 // GCD(n1, n2)
	push {r2}
	push {r0}
	push {r1}
	add r8, r8, #3
	bl GCD
	ldr r0, =result
	str r2, [r0]
	ldr r0, =max_size
	str r8, [r0]

	b L

L: b L

GCD:
    //TODO: Implement your GCD function
	ldr r1, [sp]
	ldr r0, [sp, #4]
	push {lr}
	add r8, r8, #1


	cmp r0, #0
	bne R0_IS_NOT_0
	cmp r1, #0
	bne R1_IS_NOT_0
	pop {lr}
	pop {r1}
	pop {r0}
	mov r2, #0
	str r2, [sp]
	BX LR // both zero, return

R0_IS_NOT_0:
R1_IS_NOT_0:

	cmp r0, #0
	beq R0_IS_0_and_R1_IS_NOT_0
	cmp r1, #0
	beq R0_IS_NOT_0_and_R1_IS_0
	b BOTH_NOT_0

R0_IS_0_and_R1_IS_NOT_0:
	mov r2, r1
	pop {lr}
	pop {r1}
	pop {r0}
	str r2, [sp]
	BX LR
R0_IS_NOT_0_and_R1_IS_0:
	mov r2, r0
	pop {lr}
	pop {r1}
	pop {r0}
	str r2, [sp]
	BX LR

BOTH_NOT_0:
	cmp r0, r1
	bne NOT_EQUAL
	mov r2, r1 // both equal
	pop {lr}
	pop {r1}
	pop {r0}
	str r2, [sp]
	BX LR

NOT_EQUAL:
	mov r2, r0
	mov r3, r1
	and r2, r2, #0x1
	and r3, r3, #0x1
// always use r2 r3!!


	cmp r2, #0
	bne R0_IS_ODD
	cmp r3, #0
	bne R1_IS_ODD
	mov r4, #1
	lsr r0, r4 // both even
	lsr r1, r4 // both even
	push {r2}
	push {r0}
	push {r1}
	add r8, r8, #3
	bl GCD
	pop {r2}
	lsl r2, r4
	pop {lr}
	pop {r1}
	pop {r0}
	str r2, [sp]
	BX LR

R0_IS_ODD:
R1_IS_ODD:
	mov r4, #1
	cmp r2, #0
	beq R0_IS_EVEN
	cmp r3, #0
	beq R1_IS_EVEN
	b BOTH_NOT_EVEN

R0_IS_EVEN:
	lsr r0, r4
	push {r2}
	push {r0}
	push {r1}
	add r8, r8, #3
	bl GCD
	pop {r2}
	pop {lr}
	pop {r1}
	pop {r0}
	str r2, [sp]
	BX LR

R1_IS_EVEN:
	lsr r1, r4
	push {r2}
	push {r0}
	push {r1}
	add r8, r8, #3
	bl GCD
	pop {r2}
	pop {lr}
	pop {r1}
	pop {r0}
	str r2, [sp]
	BX LR

BOTH_NOT_EVEN:
	cmp r0, r1
	blt R0_LESS_THAN_R1

	sub r0, r0, r1
	lsr r0, r4
	b CALCULATED_PARA
R0_LESS_THAN_R1:
	sub r1, r1, r0
	lsr r1, r4
CALCULATED_PARA:
	push {r2}
	push {r0}
	push {r1}
	add r8, r8, #3
	bl GCD
	pop {r2}
	pop {lr}
	pop {r1}
	pop {r0}
	str r2, [sp]
	BX LR


	//MOVS 	R0, #1;
	//MOVS	R1, #2

	//PUSH	{R0, R1}

	//LDR	R2,	[sp]    // R2 = 1
	//LDR	R3, [sp, #4]  //R3 = 2

	//POP	   {R0, R1}


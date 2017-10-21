.text
    .global main
.equ N, 100

fib:
    //TODO
	movs R2, R4
	add R4, R4, R1
	bvc no_overflow
	movs R4, #0
	sub R4, R4, #2
	bx lr
no_overflow:
	movs R1, R2

	sub R0, R0, #1

	cmp R0, #0
	beq finish

	b fib
finish:
    bx lr

main:
    movs R0, #N
	movs R1, #1
	movs R4, #0

	cmp R0, #1
	bge not_less
	movs R4, #0
	sub R4, R4, #1
	b out_of_range


not_less:
	cmp R0, #100
	bls no_out_of_range
	movs R4, #0
	sub R4, R4, #1
	b out_of_range
no_out_of_range:
    bl fib
out_of_range:

	nop

L: b L

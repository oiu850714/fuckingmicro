	.syntax unified
	.cpu cortex-m4
	.align

.data
    user_stack: .zero 128
	expr_result: .word 0

.text
    .global main
    postfix_expr: .asciz "-8000 100 30 + - 10 -"
    //postfix_expr: .asciz "-100 10 +"

main:
//TODO: Setup stack pointer to end of user_stack and calculate the expression using PUSH, POP operators, and store the result into expr_result
	ldr r0, =postfix_expr
	ldr r1, =user_stack
	add r1, r1, 128
    msr msp, r1
	// above: setup msp(main stack pointer) to value of user_stack
	movs r10, #0 // result

	movs r3, r0 // r3 store the address+1 of the current token's last element
while_having_token:
	movs r0, r3
extract_token:
	ldrb r2, [r3]
	cmp r2, #0
	beq last_cal // if postfix_expre[i] == 0, then end program
	add r3, r3, #1
	cmp r2, #32 // postfix_expr[i++] == ' '
	bne extract_token
	//now r3 point to address storing ' '
	sub r3, r3, #1 // postfix[i] = charactor after ' ', so --i
	subs r4, r3, r0 //calculate token's length
	cmp r4, #1 //if equal, that means token's length is 1
	sub r2, r3, #1
	ldrb r2, [r2]
	bne token_is_operand
	cmp r2, #43 // if exp[i] != '+'
	beq token_is_operator_plus
	cmp r2, #45 // && if exp[i] != '-'
	beq token_is_operator_minus
	//b token_is_operand // then token is operand
token_is_operand:
	bl atoi
	b not_operator
token_is_operator_plus:
	bl calc_value_plus
	b have_calculated
token_is_operator_minus:
	bl calc_value_minus
not_operator:
have_calculated:
	add r3, r3, #1
	b while_having_token
	// +1, address after ' '
	/*
	ldrb r4, [r3]
	cmp r4, #43 // '+'
	bne while_having_token
	cmp r4, #45 // '-'
	bne while_having_token
	cmp r4, #48 // '0'
	bge while_having_token // >= '0'
	cmp r4, #57 // <= '9'
	ble while_having_token
	*/
last_cal:
	sub r3, r3, #1
	ldrb r4, [r3]
	cmp r4, #'+'
	beq last_plus
	cmp r4, #'-'
	beq last_minus
last_plus:
	bl calc_value_plus
	b program_end
last_minus:
	bl calc_value_minus

program_end:
	ldr r6, =expr_result
	str r12, [r6]
	B	L
L:

atoi:
    //TODO: implement a ¡§convert string to integer¡¨ function

    //now r0 is address of first charactor of token, r3 is addfress of space
	mov r5, r0 // r5 is iterator
	mov r6, #0 // r6 store tmp calculated integer
	mov r9, #10
	ldrb r7, [r5]
	cmp r7, #'-'
	beq set_minus_flag
	mul r6, r6, r9 // r9 is 10
	sub r7, r7, #48
	add r6, r6, r7
	mov r8, #1
	add r5, r5, #1
	cmp r5, r3
	beq only_one_char
	b while_having_character
set_minus_flag:
	mov r8, #0
	sub r8, r8, #1
	add r5, r5, #1
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

calc_value_plus:
	//TODO: calculate temporary value
	pop {r11, r12}
	add r12, r12, r11
	push {r12}
	BX LR

calc_value_minus:
	//TODO: calculate temporary value
	pop {r11, r12}
	sub r12, r12, r11
	push {r12}
	BX LR

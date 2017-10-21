	.syntax unified
	.cpu cortex-m4
	.thumb

.text
	.global main
	.equ RCC_BASE,0x40021000
	.equ RCC_CR,0x0
	.equ RCC_CFGR,0x08
	.equ RCC_PLLCFGR,0x0c
	.equ RCC_CCIPR,0x88
	.equ RCC_AHB2ENR,0x4C
	.equ RNG_CLK_EN,18

	.equ UMAX, 0xFFFFFFFF

	// Register address for RNG (Random Number Generator)
	.equ RNG_BASE,0x50060800 //RNG BASE Address
	.equ RNG_CR_OFFSET,0x00 //RNG Control Register
	.equ RNGEN,2 // RNG_CR bit 2

	.equ RNG_SR_OFFSET,0x04 //RNG Status Register
	.equ DRDY,0 // RNG_SR bit 0
	.equ RNG_DR_OFFSET,0x08 //RNG Data Register (Generated random number!)
	//Data Settings for 3.4.4
	.equ SAMPLE,1000000

set_flag:
	ldr r2,[r0,r1]
	orr r2,r2,r3
	str r2,[r0,r1]
	bx lr

enable_fpu:
	//Your code in 3.4.1
  //Your code start from here
	//; CPACR is located at address 0xE000ED88
	LDR.W R0, =0xE000ED88
	//; Read CPACR
	LDR R1, [R0]
	//; Set bits 20-23 to enable CP10 and CP11 coprocessors
	ORR R1, R1, #(0xF << 20)
	//; Write back the modified value to the CPACR
	STR R1, [R0]
	//; wait for store to complete
	DSB
	//;reset pipeline now the FPU is enabled
	ISB


	bx lr

enable_rng:
	//Your code start from here
	//Set the RNGEN bit to 1

	LDR.W R0, =RNG_BASE
	LDR R1, [R0, RNG_CR_OFFSET]
	ORR R1, R1, #(0x1 << RNGEN)
	STR R1, [R0]
	DSB
	ISB
	bx lr

get_rand:
	//Your code start from here
	//read RNG_SR
	//check DRDY bit, wait until to 1
	//read RNG_DR for random number and store into a register for later usage

	LDR.W R0, =RNG_BASE
	LDR R1, [R0, RNG_SR_OFFSET]
	AND R1, R1, #0x1
	cmp r1, #1
	bne get_rand
	//if not branch, data is ready

	LDR.W R1, [R0, RNG_DR_OFFSET]
	bx lr

main:
//RCC Settings
	ldr r0,=RCC_BASE
	ldr r1,=RCC_CR
	ldr r3,=#(1<<8) //HSION
	bl set_flag
	ldr r1,=RCC_CFGR
	ldr r3,=#(3<<24) //HSI16 selected
	bl set_flag
	ldr r1,=RCC_PLLCFGR
	ldr r3,=#(1<<24|1<<20|1<<16|10<<8|2<<0)
	bl set_flag
	ldr r1,=RCC_CCIPR
	ldr r3,=#(2<<26)
	bl set_flag
	ldr r1,=RCC_AHB2ENR
	ldr r3,=#(1<<RNG_CLK_EN)
	bl set_flag
	ldr r1,=RCC_CR
	ldr r3,=#(1<<24) //PLLON
	bl set_flag
chk_PLLON:
	ldr r2,[r0,r1]
	ands r2,r2,#(1<<25)
	beq chk_PLLON

//Your code start from here
//Enable FPU,RNG
	bl enable_fpu
	bl enable_rng

	bl get_rand
	mov R2, R1
	bl get_rand
	mov R3, R1
//Generate 2 random U32 number x,y
	// now r2, r3 is x, y

	ldr r4, =UMAX
	vmov s0, r4
	vcvt.f32.u32 s0, s0

	vmov s1, r2
	vcvt.f32.u32 s1, s1

	vmov s2, r3
	vcvt.f32.u32 s2, s2

	vdiv.f32 s1, s1, s0
	vdiv.f32 s2, s2, s0
	//Map x,y in unit range [0,1] using FPU

	vmul.f32 s1, s1, s1
	vmul.f32 s2, s2, s2

	vadd.f32 s3, s1, s2
	vsqrt.f32 s3, s3

//Calculate the z=sqrt(x^2+y^2) using FPU
//Show the result of z in your report
L: 	b L

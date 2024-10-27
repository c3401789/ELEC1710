.syntax unified
  .cpu cortex-m3
  .thumb
  .global task4

.equ	GPIOC_ODR,	0x4001100C	// For 7-seg on pins 0 to 7
.equ	GPIOA_IDR,	0x40010808	// For custom buttons on pins 8-11

// Entry point from main.c
// 134218154 - 134218064 : 90 bytes
task4:
	/*
	The next state is stored with 3 bits based on the position which is the current state
	7	6	5	4	3	2	1	0
	000 000 110 110 110 011 010 010 -> 0x36CD2
	Can only store 16 bits per MOV, do a lower and upper inst
	*/
	LDR R0, =data			// Store output data for LED into R0
	MOV R1, 0				// Store current state into R1
	MOVW R2, #0x6CD2   		// Store next-state, lower 16 bits in R2
	MOVT R2, #0x0003   		// Store next-state, upper 16 bits in R2
	MOV R4, #3				// Store multiplier for MUL constant in update_even
	MOV R5, #0				// Store initial bit offset of 0 for update_even
	LDR R7, =GPIOC_ODR		// Store address of output data register
	LDR R8, =GPIOA_IDR 		// Store address of input data register
	MOV R9, #0x800000		// Store delay interval
	MOV R10, #0x0

	B loop					// branch to loop label


loop:
	// Delay loop
	SUB R9, R9, #1			// Subtract 1 from R9
	CMP R9, 0				// Compare R9 to 0
	IT GT					// if greater than 0
		BGT loop			// Branch back to loop
	MOV R9, #0x800000		// Reset delay counter

	// Update LED
	LDRB R6, [R0, R1] 		// Load 1 byte from data[R0] at position state[R1], store in R6
    STR R6, [R7]			// Store the byte at R6 into ODR[R7]

    // Update Input pin
	LDR R10, [R8] 			// Load the data at address GPIOA_IDR into r10
	UBFX R10, R10, #8, #1 	// extract 1 bit at position 8 from R10, store back into R10

	// Compare input state
	CMP R10, #0				// check if the input is 0: low, 1:high
	ITTEE EQ				// IF then block
		// Input not pushed
		ADDEQ R1, R1, #1	// Increment R1 by 1
		ANDEQ R1, R1, #7	// Apply mask (111) to wrap the value at 8 (1000) back to (000)
		// Input was pushed
		LSRNE R3, R2, R5	// Shift R2 right by the value in R1 (position), store the result in R3
		ANDNE R1, R3, #0x7	// Apply mask (111) to (24 bits in R3), ignoring bits 24-4, store in R1
	// Mutliple R1 and R4, store in R5. R5 used to store bit offset
	MUL R5, R1, R4			// MULTIPLY R1(STATE 0-7) BY 3, STORE IN R5

	B loop					// Return to loop label



.align 4
data:
	.byte 0x39  // C
    .byte 0x4F  // 3
    .byte 0x66  // 4
    .byte 0x3F  // 0
    .byte 0x06  // 1
    .byte 0x07  // 7
    .byte 0x7F  // 8
    .byte 0x67  // 9

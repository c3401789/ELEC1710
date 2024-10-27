// 88 bytes
.syntax unified
.cpu cortex-m3
.thumb
.global task4

.equ	GPIOC_ODR,	0x4001100C	// For 7-seg on pins 0 to 6
.equ	GPIOA_IDR,	0x40010808	// For custom buttons on pins 8-11
.equ	DELAY,		0x800000	// Approx 1 second delay
.equ	NEXT_STATES,0x36CD2		// 000 000 110 110 110 011 010 010

/*
========= Hardware Configuration =========
Input switches:
	Input A: 		PA8
	Input CLK:		PA9
Output 7-Segment Display:
	Segment A:		PC0
	Segment B:		PC1
	Segment C:		PC2
	Segment D:		PC3
	Segment E:		PC4
	Segment F:		PC5
	Segment G:		PC6
	Segment H:		Not configured
==========================================
*/
//134218064 - 134218152
task4:
	// Initial start up values
	LDR R0, =GPIOC_ODR		// Load address of GPIOC Uutput Data Register into R0
	LDR R1, =GPIOA_IDR		// Load address of GPIOA Input Data Register into R1
	LDR R2, =NEXT_STATES		// Load the Q values into R2
	LDR R3, =DELAY			// Load the delay into R3, approx 1s
	LDR R4, =ssegdata		// Load the LUT address into R4
	MOV R5, #7			// Current offset [Start at last so next is first]
	MOV R6, #21			// Bit position within next states [Start at last so next is first]
	MOV R11, #3			// Constant for multiplier
	MOV R12, #0			// Input A pin value

					// Continue to exec label

exec:
	// Get input A
	LDR R12, [R1] 			// Load the GPIOA_IDR values from address at R1 and store it in R12
	UBFX R12, R12, #8, #1		// Get 1 bit @ position 8 from R12, store in R12 - Input A

	CMP R12, #1			// Compare Input A(R12) to high
	ITTEE EQ			// If Input A is high
		ADDEQ R5, R5, #1	// Increment current offset (R4) by #1
		ANDEQ R5, R5, #7	// Mask the lower 3 bits (#7 = 111) in the current offset (R5) [8 wraps to 0]
					// If Input A is low
		LSRNE R12, R2, R6	// Take the next state map(R2), Shift right by R6 digits. Store in R12
		ANDNE R5, R12, #7	// Mask the lower 3 bits (7 = 111b) and store them in the current offset(R5)
	MUL R6, R5, R11			// Multiply the current offset (R5) by 3 (R11). Store our new position within
								// the next state map at R6.

								// Update the 7 Segment Display
	LDRB R12, [R4, R5]			// Load byte from memory, at address stored in R1 + offset (R4) - save to R2
	STR R12, [R0]				// Store the byte at R2 into the GPIO C output data register (R0)

	BL delay					// Branch to delay label, storing the return address in the link register
  	B exec   					// branch back to exec

delay:
	SUB R3, R3, #1				// Subtract 1 from R3 and store result back in R3
	CMP R3, #0					// Compare R3 to 0
	IT GT						// If R3 is greater than 0
		BGT delay				// return to top of delay label
								// R3 is not greater than 0
	LDR R3, =DELAY				// Reset the delay counter
	BX LR						// return to link register address


.align 4
ssegdata:   // The LUT
    .byte 0x39  // C
    .byte 0x4F  // 3
    .byte 0x66  // 4
    .byte 0x3F  // 0
    .byte 0x06  // 1
    .byte 0x07  // 7
    .byte 0x7F  // 8
    .byte 0x67  // 9

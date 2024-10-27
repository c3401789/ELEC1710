// 1787 bytes
  .syntax unified
  .cpu cortex-m3
  .thumb
  .global task3

.equ	GPIOC_ODR,	0x4001100C	// For 7-seg on pins 0 to 6
.equ	DELAY,		0x800000	// Approx 1 second delay

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

task3:
	// Initial start up values
	LDR R0, =GPIOC_ODR			// Load address of GPIOC output data register into R0
	LDR R1, =ssegdata			// Load address of look-up table into R1
	LDR R3, =DELAY				// Store the value in DELAY into R3
	MOV R4, 0					// Store the current offset
								// Continue to exec label

exec:

	LDRB R2, [R1, R4]			// Load byte from memory, at address stored in R1 + offset (R4) - save to R2
	STR R2, [R0]				// Store the byte at R2 into the GPIO C output data register (R0)
	BL delay					// Branch to delay label, storing the return address in the link register

	ADD R4, R4, #1				// Increment current offset (R4) by #1
	AND R4, R4, #7				// Mask the lower 3 bits (#7 = 111) in the current offset (R4) [8 wraps to 0]

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

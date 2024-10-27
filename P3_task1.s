  .syntax unified
  .cpu cortex-m3
  .thumb
  .global task1

.equ	GPIOC_ODR,	0x4001100C	// For 7-seg on pins 0 to 6

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

task1:
	// Initial start up values
	LDR R0, =GPIOC_ODR			// Load address of GPIOC output data register into R0
	LDR R1, =ssegdata			// Load address of look-up table into R1

exec:
	LDRB R2, [R1, #12]			// Load byte from memory, at address stored in R1 + offset #12 - save to R2
	STR R2, [R0]				// Store the byte at R2 into the GPIO C output data register (R0)

	LDRB R2, [R1, #3]			// Load byte from memory, at address stored in R1 + offset #12 - save to R2
	STR R2, [R0]				// Store the byte at R2 into the GPIO C output data register (R0)

	LDRB R2, [R1, #4]			// Load byte from memory, at address stored in R1 + offset #12 - save to R2
	STR R2, [R0]				// Store the byte at R2 into the GPIO C output data register (R0)

	LDRB R2, [R1, #0]			// Load byte from memory, at address stored in R1 + offset #12 - save to R2
	STR R2, [R0]				// Store the byte at R2 into the GPIO C output data register (R0)

	LDRB R2, [R1, #1]			// Load byte from memory, at address stored in R1 + offset #12 - save to R2
	STR R2, [R0]				// Store the byte at R2 into the GPIO C output data register (R0)

	LDRB R2, [R1, #7]			// Load byte from memory, at address stored in R1 + offset #12 - save to R2
	STR R2, [R0]				// Store the byte at R2 into the GPIO C output data register (R0)

	LDRB R2, [R1, #8]			// Load byte from memory, at address stored in R1 + offset #12 - save to R2
	STR R2, [R0]				// Store the byte at R2 into the GPIO C output data register (R0)

	LDRB R2, [R1, #9]			// Load byte from memory, at address stored in R1 + offset #12 - save to R2
	STR R2, [R0]				// Store the byte at R2 into the GPIO C output data register (R0)

  	B exec   					// Return to task1

.align 4
ssegdata:   // The LUT
    .byte 0x3F  // 0
    .byte 0x06  // 1
    .byte 0x5B  // 2
    .byte 0x4F  // 3
    .byte 0x66  // 4
    .byte 0x6D  // 5
    .byte 0x7D  // 6
    .byte 0x07  // 7
    .byte 0x7F  // 8
    .byte 0x67  // 9
    .byte 0x77  // A
    .byte 0x7C  // B
    .byte 0x39  // C
    .byte 0x5E  // D
    .byte 0x79  // E
    .byte 0x71  // F

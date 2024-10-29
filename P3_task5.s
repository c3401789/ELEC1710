// 122 bytes [134218064 - 134218186]
.syntax unified
.cpu cortex-m3
.thumb
.global task5

.equ	GPIOC_ODR,	0x4001100C	// For 7-seg on pins 0 to 6
.equ	GPIOA_IDR,	0x40010808	// For custom buttons on pins 8-11
.equ	DELAY,		0x247280	// Approx 500 ms
.equ	NEXT_STATES,0x36CD2		// Q Values: 000 000 110 110 110 011 010 010


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

task5:
	// Initial start up values
	LDR R0, =GPIOC_ODR			// Load address of GPIOC Output Data Register into R0
	LDR R1, =GPIOA_IDR			// Load address of GPIOA Input Data Register into R1
	LDR R2, =NEXT_STATES		// Load the next-state Q values into R2
	LDR R3, =DELAY				// Load the delay into R3, approx 1s
	LDR R4, =ssegdata			// Load the LUT address into R4
	MOV R5, #7					// Current offset for LUT [Start at end, wrap on pulse]
	MOV R6, #21					// Bit position within next states [Start at end, wrap on pulse]
	MOV R7, #0					// GPIOA Input Data Register
	MOV R8, #0					// Input A pin value
	MOV R9, #0					// Input CLK pin value
	MOV R10, #0					// Flag for debouncing
	MOV R11, #0					// Not used
	MOV R12, #3					// Constant for multiplier
								// Continue to loop label
loop:
	// Load GPIOA_IDR
	LDR R7, [R1] 				// Load the GPIOA_IDR data from the address stored at R1 and store it in R7
	UBFX R9, R7, #9, #1			// Get 1 bit @ position 9 from R7, store in R9 - CLK input

	// Check for first pulse on CLK
	CMP R9, R10					// Compare CLK val (R9) to Debounce flag (R10)
	ITT GT						// If CLK val (R9) is greater than debounce flag (R10), first pass
		MOVGT R10, #1			// Set the flag (R10)
		BLGT update_sseg		// Update the 7seg display

	// Decrease counter
	CMP R3, #0					// Compare the counter (R3) to 0
	IT GT						// If counter (R3) is greater than 0
		SUBGT R3, R3, #1		// Substract 1 from Counter (R3), Store result back to Counter (R3)

	// Check for reset
	ADD R9, R3, R9 				// Add the CLK input val (R9) to the counter (R3). Used to reset

	CMP R9, #0					// Compare that CLK input value (R3) and counter (R9) are both 0
	ITT EQ						// If the CLK and the counter are both 0
		MOVEQ R10, 0			// Reset the debounce flag (R10)
		LDREQ R3, =DELAY		// Reset the counter (R3)

	B loop						// Start at top of loop


update_sseg:
	// Get pin value
	UBFX R8, R7, #8, #1			// Get 1 bit from GPIOA_IDR(R7) Pin 8, store in Input A(R8)

	// Check Input A state
	CMP R8, #1					// Compare Input A(R8) to high
	ITTEE EQ					// If Input A is equal to high
		ADDEQ R5, R5, #1		// Increment current offset (R5) by #1
		ANDEQ R5, R5, #7		// Mask the lower 3 bits (#7 = 111) in the current offset (R5) [8 wraps to 0]
								// If Input A is not equal to high (low)
								// Q vals = 000 000 110 110 110 011 010 010
		LSRNE R8, R2, R6		// Take the next state Q vals(R2), Shift right by current offset (R6) digits. Store in R8
		ANDNE R5, R8, #7		// Mask the lower 3 bits (7 = 111b) and store them in the current offset(R5)
	MUL R6, R5, R12				// Multiply the current offset (R5) by 3 (R12). Store our new position within
								// the next state map at R6
	// Update display
	LDRB R8, [R4, R5]			// Load byte from ssegdata(R4) at offset(R5)[0-7], Store in R8
	STR R8, [R0]				// Store the byte at R8 into the GPIOC output data register (R0)

  	BX LR						// Return to address stored in link register


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

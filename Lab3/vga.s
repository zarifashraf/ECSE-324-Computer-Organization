.text
.equ VPB_Base, 0xC8000000
.equ VCB_Base, 0xC9000000
.global VGA_clear_charbuff_ASM
.global VGA_clear_pixelbuff_ASM
.global VGA_write_char_ASM
.global VGA_write_byte_ASM
.global VGA_draw_point_ASM
.equ PS2_Data_Base, 0xFF200100
.global read_PS2_data_ASM

.global _start
_start:
        bl      draw_test_screen
end:
        b       end
VGA_draw_point_ASM:
	PUSH {R0-R3, LR}		// callee-save convention
	MOV R3, #300			// the block checks if the coordinates are within range
	ADD R3, R3, #19			
	CMP R0, #0				// check x coordinate is greater than 0
	BXLT LR
	CMP R0, R3 				// check x coordinate is less than 319
	BXGT LR
	CMP R1, #0 				// check y coordinate is greater than 0
	BXLT LR
	CMP R1, #239 			// check y coordinate is less than 239 
	BXGT LR
	
	LDR R3, =VPB_Base
	LSL R0, #1				// shift by 1 since x coordinate starts from the 1st bit	
	ADD R3, R3, R0 			// add x coordinate to the base address 
	LSL R1, #10				// shift by 10 since y coordinate starts from the 10th bit
	ADD R3, R3, R1 			// add y coordinate to the base address
	STRH R2, [R3] 			// store the input value to the address
	POP {R0-R3, LR}
	BX LR

VGA_clear_pixelbuff_ASM:

	PUSH {R0-R7,LR}			// callee-save convention
	MOV R0, #0 				// x counter begins at 0			
	MOV R5, #300
	ADD R5, R5, #19			// R5 holds the value 319
	MOV R1, #0				// y counter begins at 0
	MOV R6, R1				// R6 is a copy of the y counter
	LDR R2, =VPB_Base		// R2 points to the Pixel Buffer Base Address
	LDR R3, END				// load zero into R3

PB_XLOOP:
		CMP R0, R5			// if R0 > 319, all x pixels have been cleared
		BGT END_VGA_C_P_ASM 		
		MOV R1, R6			// reset y loop

PB_YLOOP:
		CMP R1, #239		// if R1 > 239, all y pixels have been cleared
		ADDGT R0, R0, #1	// r0 = r0 + 1
		BGT PB_XLOOP		// back to outer loop

		MOV R4, R1			// take y counter
		LSL R4, #10			// shift by 10 since y starts at the 10th bit
		ADD R4, R4, R2		// add base address
		MOV R7, R0 			// make a copy of the x counter
		LSL R7, #1			// shift by 1 since x starts at the 1st bit
		ADD R4, R4, R7 		// add the value of x counter

		STRH R3, [R4] 		// store 0s into the location
		ADD R1, R1, #1 		// r1 = r1 + 1
		B PB_YLOOP

END_VGA_C_P_ASM: 
	POP {R0-R7,LR}			
	BX LR 					// leave


VGA_write_char_ASM:
	PUSH {R0-R6, LR}
	// the block checks if the coordinates are within range
	CMP R0, #0				// check if x coordinate is greater than 0
	BXLT LR				
	CMP R0, #79				// check if x coordinate is less than 79
	BXGT LR
	CMP R1, #0				// check if y coordinate is greater than 0
	BXLT LR
	CMP R1, #59				// check if y coordinate is less than 59
	BXGT LR
	
	LDR R3 ,=VCB_Base
	ADD R3, R3, R0			// add x coordinate to the base address
	LSL R1, #7				// shift by 7 as y coordinate starts from 7th bit
	ADD R3, R3, R1			// add y coordinate to the base address
	STRB R2, [R3]			// store the input value to the address
	POP {R0-R6,LR}
	BX LR

VGA_clear_charbuff_ASM:
	
	PUSH {R0-R5,LR}			// callee-save convention
	MOV R0, #0 				// x counter begins at 0
	MOV R1, #0				// y counter begins at 0
	MOV R5, R1				// R5 contains y counter copy for yloop reset
	LDR R2, =VCB_Base		// R2 points to the memory address of Character Buffer Base
	LDR R3, END				// load zeros into R3

CB_XLOOP:
	CMP R0, #79				// if R0 > 79, all x coordinates have been cleared
	BGT VGA_C_C_ASM 		
	MOV R1, R5				// Reset yloop

CB_YLOOP:
	CMP R1, #59				// if R1 > 59, all y coordinates have been cleared
	ADDGT R0, R0, #1		// R0 = R0 + 1
	BGT CB_XLOOP			// Branch to X loop

	MOV R4, R1				// take y counter
	LSL R4, #7				// shift by 7 since y starts from the 7th bit
	ADD R4, R4, R2			// add the base address
	ADD R4, R4, R0 			// add the x counter

	STRB R3, [R4] 			// store value into the location
	ADD R1, R1, #1 			// R1 = R1 + 1
	B CB_YLOOP

VGA_C_C_ASM: 
	POP {R0-R5,LR}			
	BX LR 					

draw_test_screen:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r6, #0
        ldr     r10, .draw_test_screen_L8
        ldr     r9, .draw_test_screen_L8+4
        ldr     r8, .draw_test_screen_L8+8
        b       .draw_test_screen_L2
.draw_test_screen_L7:
        add     r6, r6, #1
        cmp     r6, #320
        beq     .draw_test_screen_L4
.draw_test_screen_L2:
        smull   r3, r7, r10, r6
        asr     r3, r6, #31
        rsb     r7, r3, r7, asr #2
        lsl     r7, r7, #5
        lsl     r5, r6, #5
        mov     r4, #0
.draw_test_screen_L3:
        smull   r3, r2, r9, r5
        add     r3, r2, r5
        asr     r2, r5, #31
        rsb     r2, r2, r3, asr #9
        orr     r2, r7, r2, lsl #11
        lsl     r3, r4, #5
        smull   r0, r1, r8, r3
        add     r1, r1, r3
        asr     r3, r3, #31
        rsb     r3, r3, r1, asr #7
        orr     r2, r2, r3
        mov     r1, r4
        mov     r0, r6
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        add     r5, r5, #32
        cmp     r4, #240
        bne     .draw_test_screen_L3
        b       .draw_test_screen_L7
.draw_test_screen_L4:
        mov     r2, #72
        mov     r1, #5
        mov     r0, #20
        bl      VGA_write_char_ASM
        mov     r2, #101
        mov     r1, #5
        mov     r0, #21
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #22
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #23
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #24
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #5
        mov     r0, #25
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #5
        mov     r0, #26
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #27
        bl      VGA_write_char_ASM
        mov     r2, #114
        mov     r1, #5
        mov     r0, #28
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #29
        bl      VGA_write_char_ASM
        mov     r2, #100
        mov     r1, #5
        mov     r0, #30
        bl      VGA_write_char_ASM
        mov     r2, #33
        mov     r1, #5
        mov     r0, #31
        bl      VGA_write_char_ASM
        pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
        .word   1717986919
        .word   -368140053
        .word   -2004318071

END:	.word 0x0
	
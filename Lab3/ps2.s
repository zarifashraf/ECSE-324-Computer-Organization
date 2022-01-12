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
        bl      input_loop
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
	LSL R4, #7				// shift by 7 since y coordinate starts from the 7th bit
	ADD R4, R4, R2			// add the base address
	ADD R4, R4, R0 			// add the x counter

	STRB R3, [R4] 			// store value into the location
	ADD R1, R1, #1 			// 	R1 = R1 + 1
	B CB_YLOOP

VGA_C_C_ASM: 
	POP {R0-R5,LR}			
	BX LR 					

read_PS2_data_ASM:
	PUSH {R1-R2, LR}		// callee-save convention
	LDR R1, =PS2_Data_Base
	LDR R1, [R1]			// load the data inside R1 to R1, so we can perform calculations
	AND R2, R1, #0x8000		// all bits execept RVALID is cleared

	CMP R2, #1				// if RAVLID = 0, branch out
	BLT RVALID0

	AND R1, #0xFF 			// all bits except the data bits are cleared
	STRB R1, [R0]			// store data inside r0
	MOV R0, #1				// r0 = 1
	POP {R1-R2, LR}
	BX	LR

RVALID0:
	MOVLT R0, #0			// if RVALID = 0, r0 =1
	POP {R1-R2, LR}		
	BX LR 


write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}

END:	.word 0x0
	
	
	
	
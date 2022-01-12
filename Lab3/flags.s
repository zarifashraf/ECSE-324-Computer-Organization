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

draw_real_life_flag:
       push    {r4, lr}
        sub     sp, sp, #8	
        //mov     r0, r1
        ldr     r4, .flags_L32+4
        str     r4, [sp]
        mov     r3, #120	// height
        mov     r2, #320	// width
        mov     r1, #0		// y-coordinates
        mov     r0, #0	    // x-coordinates
        bl      draw_rectangle
        ldr     r3, .flags_L32+8 // red flag
        str     r3, [sp]
        mov     r3, #120	//height
        mov     r2, #320	//width
        mov     r1, r3		// y-coordinates
        mov     r0, #0		// x-coordinates
        bl      draw_rectangle
        add     sp, sp, #8
        pop     {r4, pc}
draw_imaginary_flag:
        push    {r4, lr}
        sub     sp, sp, #8
        ldr     r3, .flags_L420
        str     r3, [sp]
        mov     r3, #240
        mov     r2, #106
        mov     r1, #0
        mov     r0, r1
        bl      draw_rectangle
        ldr     r4, .flags_L32+4
        mov     r3, r4
        mov     r2, #43
        mov     r1, #120
        mov     r0, #53
        bl      draw_star
        str     r4, [sp]
        mov     r3, #120
        mov     r2, #214
        mov     r1, #0
        mov     r0, #106
        bl      draw_rectangle
        ldr     r3, .flags_L420
        str     r3, [sp]
        mov     r3, #120
        mov     r2, #214
        mov     r1, r3
        mov     r0, #106
        bl      draw_rectangle
        add     sp, sp, #8
        pop     {r4, pc}
.flags_L420:
		.word 60000
draw_texan_flag:
        push    {r4, lr}
        sub     sp, sp, #8
        ldr     r3, .flags_L32
        str     r3, [sp]
        mov     r3, #240
        mov     r2, #106
        mov     r1, #0
        mov     r0, r1
        bl      draw_rectangle
        ldr     r4, .flags_L32+4
        mov     r3, r4
        mov     r2, #43
        mov     r1, #120
        mov     r0, #53
        bl      draw_star
        str     r4, [sp]
        mov     r3, #120
        mov     r2, #214
        mov     r1, #0
        mov     r0, #106
        bl      draw_rectangle
        ldr     r3, .flags_L32+8
        str     r3, [sp]
        mov     r3, #120
        mov     r2, #214
        mov     r1, r3
        mov     r0, #106
        bl      draw_rectangle
        add     sp, sp, #8
        pop     {r4, pc}
.flags_L32:
        .word   2911
        .word   65535
        .word   45248

draw_rectangle:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        ldr     r7, [sp, #32]
        add     r9, r1, r3
        cmp     r1, r9
        popge   {r4, r5, r6, r7, r8, r9, r10, pc}
        mov     r8, r0
        mov     r5, r1
        add     r6, r0, r2
        b       .flags_L2
.flags_L5:
        add     r5, r5, #1
        cmp     r5, r9
        popeq   {r4, r5, r6, r7, r8, r9, r10, pc}
.flags_L2:
        cmp     r8, r6
        movlt   r4, r8
        bge     .flags_L5
.flags_L4:
        mov     r2, r7
        mov     r1, r5
        mov     r0, r4
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        cmp     r4, r6
        bne     .flags_L4
        b       .flags_L5
should_fill_star_pixel:
        push    {r4, r5, r6, lr}
        lsl     lr, r2, #1
        cmp     r2, r0
        blt     .flags_L17
        add     r3, r2, r2, lsl #3
        add     r3, r2, r3, lsl #1
        lsl     r3, r3, #2
        ldr     ip, .flags_L19
        smull   r4, r5, r3, ip
        asr     r3, r3, #31
        rsb     r3, r3, r5, asr #5
        cmp     r1, r3
        blt     .flags_L18
        rsb     ip, r2, r2, lsl #5
        lsl     ip, ip, #2
        ldr     r4, .flags_L19
        smull   r5, r6, ip, r4
        asr     ip, ip, #31
        rsb     ip, ip, r6, asr #5
        cmp     r1, ip
        bge     .flags_L14
        sub     r2, r1, r3
        add     r2, r2, r2, lsl #2
        add     r2, r2, r2, lsl #2
        rsb     r2, r2, r2, lsl #3
        ldr     r3, .flags_L19+4
        smull   ip, r1, r3, r2
        asr     r3, r2, #31
        rsb     r3, r3, r1, asr #5
        cmp     r3, r0
        movge   r0, #0
        movlt   r0, #1
        pop     {r4, r5, r6, pc}
.flags_L17:
        sub     r0, lr, r0
        bl      should_fill_star_pixel
        pop     {r4, r5, r6, pc}
.flags_L18:
        add     r1, r1, r1, lsl #2
        add     r1, r1, r1, lsl #2
        ldr     r3, .flags_L19+8
        smull   ip, lr, r1, r3
        asr     r1, r1, #31
        sub     r1, r1, lr, asr #5
        add     r2, r1, r2
        cmp     r2, r0
        movge   r0, #0
        movlt   r0, #1
        pop     {r4, r5, r6, pc}
.flags_L14:
        add     ip, r1, r1, lsl #2
        add     ip, ip, ip, lsl #2
        ldr     r4, .flags_L19+8
        smull   r5, r6, ip, r4
        asr     ip, ip, #31
        sub     ip, ip, r6, asr #5
        add     r2, ip, r2
        cmp     r2, r0
        bge     .flags_L15
        sub     r0, lr, r0
        sub     r3, r1, r3
        add     r3, r3, r3, lsl #2
        add     r3, r3, r3, lsl #2
        rsb     r3, r3, r3, lsl #3
        ldr     r2, .flags_L19+4
        smull   r1, ip, r3, r2
        asr     r3, r3, #31
        rsb     r3, r3, ip, asr #5
        cmp     r0, r3
        movle   r0, #0
        movgt   r0, #1
        pop     {r4, r5, r6, pc}
.flags_L15:
        mov     r0, #0
        pop     {r4, r5, r6, pc}
.flags_L19:
        .word   1374389535
        .word   954437177
        .word   1808407283
draw_star:
        push    {r4, r5, r6, r7, r8, r9, r10, fp, lr}
        sub     sp, sp, #12
        lsl     r7, r2, #1
        cmp     r7, #0
        ble     .flags_L21
        str     r3, [sp, #4]
        mov     r6, r2
        sub     r8, r1, r2
        sub     fp, r7, r2
        add     fp, fp, r1
        sub     r10, r2, r1
        sub     r9, r0, r2
        b       .flags_L23
.flags_L29:
        ldr     r2, [sp, #4]
        mov     r1, r8
        add     r0, r9, r4
        bl      VGA_draw_point_ASM
.flags_L24:
        add     r4, r4, #1
        cmp     r4, r7
        beq     .flags_L28
.flags_L25:
        mov     r2, r6
        mov     r1, r5
        mov     r0, r4
        bl      should_fill_star_pixel
        cmp     r0, #0
        beq     .flags_L24
        b       .flags_L29
.flags_L28:
        add     r8, r8, #1
        cmp     r8, fp
        beq     .flags_L21
.flags_L23:
        add     r5, r10, r8
        mov     r4, #0
        b       .flags_L25
.flags_L21:
        add     sp, sp, #12
        pop     {r4, r5, r6, r7, r8, r9, r10, fp, pc}
input_loop:
        push    {r4, r5, r6, r7, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      draw_texan_flag
        mov     r6, #0
        mov     r4, r6
        mov     r5, r6
        ldr     r7, .flags_L52
        b       .flags_L39
.flags_L46:
        bl      draw_real_life_flag
.flags_L39:
        strb    r5, [sp, #7]
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .flags_L39
        cmp     r6, #0
        movne   r6, r5
        bne     .flags_L39
        ldrb    r3, [sp, #7]    @ zero_extendqisi2
        cmp     r3, #240
        moveq   r6, #1
        beq     .flags_L39
        cmp     r3, #28
        subeq   r4, r4, #1
        beq     .flags_L44
        cmp     r3, #35
        addeq   r4, r4, #1
.flags_L44:
        cmp     r4, #0
        blt     .flags_L45
        smull   r2, r3, r7, r4
        sub     r3, r3, r4, asr #31
        add     r3, r3, r3, lsl #1
        sub     r4, r4, r3
        bl      VGA_clear_pixelbuff_ASM
        cmp     r4, #1
        beq     .flags_L46
        cmp     r4, #2
        beq     .flags_L47
        cmp     r4, #0
        bne     .flags_L39
        bl      draw_texan_flag
        b       .flags_L39
.flags_L45:
        bl      VGA_clear_pixelbuff_ASM
.flags_L47:
        bl      draw_imaginary_flag
        mov     r4, #2
        b       .flags_L39
.flags_L52:
        .word   1431655766

END:	.word 0x0
	
	
	
	
	
	
	
	
	
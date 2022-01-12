ARRAY:  .word 5, 6, 7, 8
n:      .word 4
log2_n: .word 0
tmp:    .word 0    
norm:   .word 1   
cnt:    .word 100 
k:      .word 10  
t:      .word 2   


.global _start

_start: 

LDR r0, =ARRAY  // r0 points to the beginning of the ARRAY
LDR r1, n       // the value of n is loaded into r1
LDR r2, log2_n	// the value of log2_n is loaded into r2
LDR r3, tmp		// the value of tmp is loaded into r3
LDR r4, norm	// the value of norm is loaded into r4
LDR r5, cnt		// the value of cnt is loaded into r5
LDR r6, k		// the value of k is loaded into r6
LDR r7, t    	// the value of t is loaded into r7
MOV r8, #1       // stores the 1 needed in LSL
MOV r10, #0      // r10 is the counter i
		
WHILE:	

LSL r9, r8, r2   // 1 << log2_n
CMP r9, r1       // (1 << log2_n) - n
BGE FOR       
ADD r2, r2, #1   //	log2_n++
B WHILE
		
FOR:  

CMP r10, r1       // i - n
BGE CODE
LDR r9, [r0], #4  // load the value in r0 into r9 and increment r0 by 4
MLA r3, r9, r9, r3    // tmp = tmp + (*ptr) * (*ptr)
ADD r10, r10, #1  // i = i + 1 
B FOR
		
CODE:   

ASR r3, r3, r2    // tmp = tmp >> log2_n
PUSH {r0-r10, LR}	// push parameters and LR
BL RECURSION
LDR r4, [SP, #16] // get return value from stack
STR r4, norm	 // store in memory
LDR LR, [SP, #44]	// restore LR
ADD SP, SP, #48	// remove parameters and LR from stack

END:

B END
		
RECURSION:  

PUSH {r0-r8}   //callee-save convention
LDR r0, [SP, #48] //load parameter tmp from stack
LDR r1, [SP, #52] //load parameter norm from stack
LDR r2, [SP, #56] //load parameter cnt from stack
LDR r3, [SP, #60] //load parameter k from stack
LDR r4, [SP, #64] //load parameter t from stack
MOV r5, #0        // the value of step will be loaded into r5
MOV r6, #0        // the value of -t will be loaded into r6
MOV r7, #0 		  // r7 is the counter cnt
		   
LOOP:      

MUL r5, r1, r1
SUB r5, r5, r0 
MUL r5, r5, r1 
ASR r5, r5, r3 // step = ((xi * xi - a) * xi) >> k;
CMP r4, r5 // t - step
MOVLT r5, r4  // if step > t, step = t
NEG r6, r4 // r6 = -t
CMP r5, r6 // - t - step
MOVLT r5, r6   // else if -t > step, step = -t
B UPDATE
		   
UPDATE:    

SUB r1, r1, r5  // norm = norm - step
SUBS r2, r2, #1 // cnt = cnt - 1
BGT LOOP        // loop if cnt > 0
STR r1, [SP, #52] // store sum on stack, replacing norm
POP {r0-r8}	// restore registers
BX LR


		
		
		
		
		
	
	
a:    .word 168
xi:   .word 1
cnt:  .word 100
k:    .word 10
t:    .word 2

.global _start

_start: 

LDR r0, a   // loads the value of a into r0
LDR r1, xi  // loads the value of xi into r1
LDR r2, cnt // loads the value of cnt into r2
LDR r3, k   // loads the value of k into r3
LDR r4, t   // loads the value of t into r4
PUSH {r0-r4, LR} // push parameters and LR
BL 	RECURSION // branch and link
LDR r0, [SP, #24] // get return value from stack
STR r0, xi // store in memory
LDR LR, [SP, #20] // restore LR
ADD SP, SP, #24 // remove parameters and LR from stack


END:	

B END
		
RECURSION: 

PUSH {r0-r6}	  // callee-save convention
LDR r0, [SP, #28] //load parameter a from stack
LDR r1, [SP, #32] //load parameter xi from stack
LDR r2, [SP, #36] //load parameter cnt from stack
LDR r3, [SP, #40] //load parameter k from stack
LDR r4, [SP, #44] //load parameter t from stack
MOV r5, #0        // the value of grad will be loaded into r5
MOV r6, #0        // the value of -t will be loaded into r6
		   
LOOP:	   

MUL r5, r1, r1
SUB r5, r5, r0 
MUL r5, r5, r1 
ASR r5, r5, r3 // grad = ((xi * xi - a) * xi) >> k;
CMP r4, r5 // t - grad
MOVLT r5, r4  // if grad > t, grad = t
NEG r6, r4 // r6 = -t
CMP r5, r6 // - t - grad
MOVLT r5, r6   // else if -t > grad, grad = -t
B UPDATE
		   
UPDATE:    

SUB r1, r1, r5  // Xi = Xi - grad
SUBS r2, r2, #1 // cnt = cnt - 1
BGT LOOP        // loop if cnt > 0
STR r1, [SP, #52] // store sum on stack
POP {r0-r6}	// restore registers
BX LR
		
	
	
	
	
	
	
	
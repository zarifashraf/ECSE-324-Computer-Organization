ARRAY:	.word 4, 2, 1, 4, -1, 
n:		.word 5

.global _start

_start:

LDR r0, =ARRAY	 			//r0 points to the beginning of the ARRAY
LDR r1, n 					// r1 contains the value of n	
MOV r2, #0					// r2 = n - 1
MOV r3, #0					// r3 is the counter i
MOV r4, #0 					// r4 is the counter j				
MOV r5, #0					// r5 will be used to store cur_min_idx	
MOV r6, #0 					// r6 is tmp
		

FOR:
SUB r2, r1, #1				// r2 = n-1
CMP r3, r2					// i - (n - 1)
BGT	END						// if i > n - 1, end the program
LDR r6, [r0, r3, LSL #2]	// loads the next element in the array into r6
MOV r5, r3					// cur_min_idx = i
MOV r4, r3					// j = i
	
FOR2:					

ADD r4, r4, #1				// j = j + 1
CMP r1, r4					// n - j
BLE	SWAP					// if n <= j, do not continue here
LDR r8, [r0, r4, LSL #2]	// loads the next element in the array into r8
CMP r6, r8					// tmp - r8
BLE FOR2					
MOV r6, r8				
MOV r5, r4					// cur_min_idx = j				
B	FOR2

SWAP:
push {r1, r6, r4, r2 }		// calle-save convention
MOV r2, #4					// r2 holds the constant 4
MUL r12, r3, r2				// i * 4
ADD r1, r12, r0				// ptr + i
MUL r12, r5, r2				// cur_min_idx * 4
ADD r6, r12, r0				// ptr + cur_min_idx
LDR r9, [r6]				// swap
LDR r4, [r1]
STR r4, [r6]				
STR r9, [r1]			 
ADD r3, r3, #1				// i = i + 1
pop {r1, r6, r4, r2}		// restore registers
B	FOR

END:
B	END






	
	
	
	
	
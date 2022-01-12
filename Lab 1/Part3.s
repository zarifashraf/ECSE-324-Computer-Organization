ARRAY: .word 3, 4, 5, 4
n: .word 4


.global _start

_start:

MOV r0, #0 // r0 stores the mean
LDR r2, =ARRAY // r2 points to the array
LDR r7, [r2] // r7 contains the value of the array element, now 3
MOV r1, #0 // r1 is the counter i for MEAN
MOV r6, #0 // r6 is the counter i for CENTER
LDR r3, n // r3 contains the value of n
MOV r4, #0 // r4 contains the value of log2_n
MOV	r5, #1 // r5 contains the value 1





WHILE:

LSL r5,r5,r4 // 1<<log2_n
CMP	r5, r3 // logically shifted value minus n, if the result is 0 or greater, do not add to r4
BGE	MEAN
ADD	r4, r4, #1 // log2n++
B	WHILE

MEAN:


CMP r1, r3
BGE MEAN_SHIFT
LDR r7, [r2] // load the value in r2 to r7
ADD r0, r0, r7// mean = mean + *ptr
ADD r2, r2, #4 // ptr points to the next element in the array
ADD r1, r1, #1 // increment the pointer i
B	MEAN

MEAN_SHIFT:


ASR	r0, r0, r4 // mean = mean >> log2_n
LDR r2, =ARRAY
B	CENTER

CENTER:


CMP	r6, r3
BGE END
LDR r8, [r2] // load the value of r2 into r8
SUB	r8, r8, r0	// *ptr -= mean
STR r8, [r2],#4
ADD r6, r6, #1
B	CENTER

END: B END
	
	
	
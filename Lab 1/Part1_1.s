a:	  .word 168
xi:   .word 1
cnt:  .word 100
k:	  .word 10
t:	  .word 2

.global _start

_start:	

LDR r0, xi  // the value of xi is loaded into r0
LDR r1, a   // the value of a is loaded into r1
LDR r2, k   // the value of k is loaded into r2
LDR r3, cnt // the value of cnt is loaded into r3
LDR r4, t   // the value of t is loaded into r4
MOV r5, #0  // r5 is the counter i
MOV r6, #0  // the value of step will be loaded into r6
MOV r7, #0  // the value of -t will be loaded into r7
		
FOR:   

CMP r3, r5  // cnt - i
BLE STORE   // if cnt < i , do not carry out the operation
MUL r6, r0, r0 
SUB r6, r6, r1 
MUL r6, r6, r0 
ASR r6, r6, r2 // ((xi*xi-a)*xi)>>k
NEG r7, r4 // -t is stored in r7
CMP r4, r6	// t - step
MOVLT r6, r4 // if Step > t, step = t
CMP r6, r7	 // Step - (-t)
MOVLT r6, r7 // if step < -t, step = -t
B UPDATE

UPDATE: 

SUB r0, r0, r6 // xi = xi - step
ADD r5, r5, #1 // i = i + 1
B FOR

STORE:    

STR r0, xi // store the value of r0 in xi

END:

B END 


	
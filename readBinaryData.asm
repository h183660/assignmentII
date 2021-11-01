; Subtask 1 Data input
;
; In assembly, data in decimal form (like in the A*.mat les) is not only more
; computationally expensive, there also is no standard library that has this
; functionality built-in. Manually implemementing decimal input would require
; reading the individual digits, translating them to integers and adding them
; together each with the right power-of-10 factor. This is not required for this assignment.
;
; Instead, you are to accept the data in the binary format that toBinary.c produces.
; Fortunately, this is already the format that the matrices will have in memory as 
; x86-native arrays, so all that needs to be done is copying to the program's memory.
;
; This is already implemented in the readBinaryData routine. Your task is to
; comment every line of this routine, explaining what it does and/or why.
;
;====================
; D A T A  I N P U T
;====================
; void readBinaryData(tgtAddress, nBytes)
readBinaryData:
   mov eax,SYS_READ        ; SYS_READ is equal to 3, corresponding to the sys_read system call. This is stored in the accumulator.
   mov ebx,STDIN           ; STDIN is equal to 0 from the .data section. 0 is the file descriptor for STDIN.
   mov ecx, w32FrStck(1)   ; Saves input data to the adress stored in ecx.
   mov edx, 8*4            ; Size of the incoming message. 8*4=32, this corresponding to a 32bit binary number.
   int 80h                 ; Interrupt, it now reads 32 characters from STDIN and stores it where ECX points to.
   mov eax, 8*4            ; Sets EAX to 32 (0x20), like in 32 bits...
   mov ecx, w32FrStck(1)   ; Sets ecx to the address stored in w32FrStck(1)
   add ecx, eax            ; Adds 32 to the address stored in ecx
   mov w32FrStck(1), ecx   ; Stores the value back in w32FrStck(1) 
   mov edx, w32FrStck(2)   ; Stores the remainding bits from w32FrStck(2) to edx.
   sub edx, eax            ; Subtracts 32 (0x20) from the remainding bits.
   mov w32FrStck(2), edx   ; Stores the updated remainding bits value to the w32FrStck(2) adress.
   cmp edx, 0              ; Compares the "remainding bits" with 0.
   jg readBinaryData       ; Jumps to readBinaryDate (loops) if remainding bits > 0.
   ret
; - Would the routine work with matrices of any size?
; It does work with the A- and B matrices we are using,
; but what requirement makes this possible?
; 
; No, it would not work with matrices of any size. The matrices has to fit the specified
; row and column count from the .data section, here lies the variables l, n and m. 
; l and n specify the A matrix height and width, while n and m specify the heigth and
; width of matrix B. Here l = 300, n = 50 and m = 500, this matches the given A and B
; matrices. If you wanted matrices of other sized theese values has to be changed.
;
; Furthermore matrix multiplication is only defined while the number of columns in 
; matrix A matches the number of rows in matrix B.
; 
; - What could be changed to actually make it work with any size?
; Discuss if your suggestion has any drawbacks.
; 
; The l, n and m variables could be changed to fit matrices of other sizes, but this 
; requires compiling again for different values. 
; 
; The program could also be rewritten, it could take the matrix heigth and width as 
; a argument from SYS_READ. and use theese values while calling readBinaryData.

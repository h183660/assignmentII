readBinaryData:
   mov eax,SYS_READ        ; SYS_READ is equal to 3, corresponding to the sys_read system call. This is stored in the accumulator.
   mov ebx,STDIN           ; STDIN is equal to 0 from the .data section. 0 is the file descriptor for STDIN. Moves 0 into ebx.
   mov ecx, w32FrStck(1)   ; Store matrix adress to ecx. The later syscall saves input data to the adress stored in ecx.
   mov edx, 8*4            ; Size of the incoming message. 8*4=32, this corresponding to a 32bit binary number or double word.
   int 80h                 ; Interrupt, it now reads 32 characters from STDIN and stores it where ECX points to.
   mov eax, 8*4            ; Sets EAX to 32 (0x20), like in 32 bits...
   mov ecx, w32FrStck(1)   ; Sets ecx to the address stored in w32FrStck(1)
   add ecx, eax            ; Adds 32 to the address stored in ecx
   mov w32FrStck(1), ecx   ; Stores the value back in w32FrStck(1), this is now the adress for the next number.
   mov edx, w32FrStck(2)   ; Stores the remainding bits from w32FrStck(2) to edx.
   sub edx, eax            ; Subtracts 32 (0x20) from the remainding bits.
   mov w32FrStck(2), edx   ; Stores the updated remainding bits value to the w32FrStck(2) adress.
   cmp edx, 0              ; Compares the "remainding bits" with 0.
   jg readBinaryData       ; Jumps to readBinaryDate (loops) if remainding bits > 0.
   ret
; - Would the routine work with matrices of any size?
; It does work with the A- and B matrices we are using,
; but what requirement makes this possible?

; No, it would not work with matrices of any size. The matrices has to fit the specified
; row and column count from the .data section, here lies the variables l, n and m. 
; l and n specify the A matrix height and width, while n and m specify the heigth and
; width of matrix B. Here l = 300, n = 50 and m = 500, this matches the given A and B
; matrices. If you wanted matrices of other sized these values has to be changed.

; Furthermore matrix multiplication is only defined while the number of columns in 
; matrix A matches the number of rows in matrix B.

; - What could be changed to actually make it work with any size?
; Discuss if your suggestion has any drawbacks.

; The l, n and m variables could be changed to fit matrices of other sizes, but this 
; requires compiling again for different values. 

; The program could also be rewritten more, it could take the matrix heigth and width as 
; a argument from SYS_READ. and use theese values while calling readBinaryData. This would
; take a lot more work.
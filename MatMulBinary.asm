;  ======================================================
;     A  S  S  E  M  B  L  Y    T  E  M  P  L  A  T  E
;  ======================================================
;
;  This is the program you are supposed to complete and make equivalent to
;  the existing Java program.
;
;  ========================
;  H E L P E R  M A C R O S
;  ========================
;
;  These macros illustrate how assembly uses the stack for passing values around,
;  in particular passing arguments to "functions".
;  Note that the macros are expanded before the actual assembler begins, you
;  could as well do that manuall.
; 
; Reference the 32-bit value that has been `push`ed nth-most recently.
%define w32FrStck(n) [esp + 4 * (n)]

; Invoke a function with two arguments passed via the stack.
%macro call2 3
  push dword %3  ; second argument
  push dword %2  ; first argument
  call %1
  add esp, 2*4   ; clean up stack
%endmacro

; Read the two arguments in a function call.
%macro funargs2 2
  mov %1, w32FrStck(1)
  mov %2, w32FrStck(2)
%endmacro

; Read the three arguments in a function call.
%macro funargs3 3
  mov %1, w32FrStck(1)
  mov %2, w32FrStck(2)
  mov %3, w32FrStck(3)
%endmacro

; Invoke a function with one 32-bit value returned,
; and three arguments passed via the stack.
%macro call3_1 5
  push dword 0   ; result
  push dword %5  ; third argument
  push dword %4  ; second argument
  push dword %3  ; first argument
  call %2
  add esp, 3*4   ; clean up arguments from stack
  pop %1         ; retrieve result
%endmacro

; Read the three arguments in a function call.
%macro funret3_1 1
  mov w32FrStck(4), %1
  ret
%endmacro

section .data
   l equ 300
   n equ 50
   m equ 500
   STDIN equ 0
   STDOUT equ 1
   SYS_READ equ 3
   SYS_WRITE equ 4
   LINE_SHIFT equ 10

section .bss
   inNumber resb 4
   matrixA resb 4*l*n
   matrixB resb 4*n*m
   matrixC resb 4*l*m
   digest resb 4

%macro setupMatrixIndexing 4
   mov eax, %3      ; y
   mov ebx, %2      ; w
   mul ebx          ; eax <- y*w   {ebx*eax}
   mov ebx, %4      ; x
   add eax, ebx     ; eax <- y*w + x  {linear index into matrix}
   mov ebx, 4
   mul ebx          ; 32-bit
   mov ebx, %1      ; m
   add ebx, eax     ; ebx <- &m + 4*(y*w + x)  {absolute address of matrix element}
%endmacro

%macro readoutMatrix 5
   setupMatrixIndexing %2, %3, %4, %5
   mov %1, [ebx] ; m[y][x]
%endmacro

%macro writeToMatrix 5
   setupMatrixIndexing %2, %3, %4, %5
   mov [ebx], %1 ; m[y][x]
%endmacro



;================================
;  M A I N  E N T R Y  P O I N T
;================================
section .text
global _start
_start:

   ; Read matrices from stdin
   call2 readBinaryData, matrixA, 4*l*n
   call2 readBinaryData, matrixB, 4*n*m

   call matmul

   call3_1 eax, jumpTrace, matrixC, l, m

   ; readoutMatrix eax, matrixA, n, 40, 29
   mov edx,0  ; div requires initial high half zero
   mov ebx,26
   div ebx    ; edx <- eax%ebx
   push edx

   ; Print a number as characterId-in-alphabet
   mov edx, 'a'
   pop ecx
   add edx, ecx

   mov eax,SYS_WRITE
   mov ebx,STDOUT
   mov ecx,digest
   mov [ecx], edx
   add ecx, 1
   mov [ecx], byte LINE_SHIFT
   mov ecx,digest
   mov edx,2
   int 80h

   mov ebx,0
   mov eax,1       ; sys_exit
   int 80h




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





; Subtask 2 Pseudo-hash
;
; The jumpTrace function reduces a matrix to a single integer, one that will 
; change unpredictably if any of the matrix entries is varied.
; 
; The assembly template contains part of this function's implementation, 
; demonstrating in particular how to set up a function and a loop.
; You need to complete the second half of the loop body.
; Make use of the provided macros, and comment your code extensively.
; 
; In order to check/debug this part, we recommend temporarily modifying
; both the assembly main-routine and the corresponding Java reference to
; directly show the jump-trace of one of the input matrices, without computing
; the matrix multiplication. Ensure that the assembly version then consistently
; gives the same output as the Java one (given different matrix inputs from the examples).
;
; Java Referance Method:
;
;   // A pseudo-hash for matrices.
;   public static char jumpTrace(int[][] m) {
;     int w = m[0].length;
;     int h = m.length;
;     int iterations = w*h;
;     int x=0, y=0;
;     int acc=1;
;     for (int i=0; i<iterations; ++i) {
;       acc = (acc*m[y][x] + 1) % (w*h);
;       y = acc % h;
;
;
;
;       x = (acc*m[y][x]) % w;
;
;
;
;     }
;     return (char) (((int) 'a') + acc%26);
;   }
;=======================================
; P S E U D O  H A S H  F U N C T I O N
;=======================================
; char jumpTrace(matrixAddr, height, width)
jumpTrace:
   funargs3 edx, ecx, ebx ; m, h, w
   push edx               ; m             ; #7
   mov eax, ebx           ; eax <- w
   mul ecx                ; eax <- w*h  {eax*ecx} {iterations}
   push eax               ; matrix size   ; #6
   push ebx               ; w             ; #5
   push ecx               ; h             ; #4
   push dword 0           ; x             ; #3
   push dword 0           ; y             ; #2
   push dword 1           ; acc           ; #1
   push eax               ; iterations    ; #0

jTLoop:
   readoutMatrix eax, w32FrStck(7), w32FrStck(5), w32FrStck(2), w32FrStck(3)
                    ;     m       ,     w       ,     y       ,     x
   mov ecx, w32FrStck(1)  ; acc
   mul ecx                ; eax <- acc*m[y][x]
   inc eax                ;
   mov ebx, w32FrStck(6)  ; w*h
   mov edx, 0             ;
   div ebx                ; edx <- (acc*m[y][x] + 1) % (w*h)
   mov w32FrStck(1), edx  ; acc
   mov ebx, w32FrStck(4)  ; h
   mov eax, edx           ; acc
   mov edx, 0             ;
   div ebx                ; edx <- acc % h
   mov w32FrStck(2), edx  ; y <- acc%h
   readoutMatrix eax, w32FrStck(7), w32FrStck(5), w32FrStck(2), w32FrStck(3)
                          ; m     ,     w       ,     y       ,     x





;
;                                      ┌───────────────────
;──────────────────────────────────────┤ TO BE FILLED
;                                      └ (ca. 6 instructions)
   mov ecx, w32FrStck(1)  ; acc
   mul ecx                ; eax <- acc*m[y][x]
   mov ebx, w32FrStck(5)  ; w
   mov edx, 0
   div ebx                ; edx <- (acc*m[y][x]) % (w)
   mov w32FrStck(3), edx  ; x <- edx
   
   
   
   

   mov ecx, w32FrStck(0)  ; iterations
   dec ecx                ; --iterations
   mov w32FrStck(0), ecx  ; iterations
   cmp ecx, 0             ; iterations > 0 ?
   jg jTLoop

   pop edx                ; iterations  ; #0
   pop eax                ; acc         ; #1
   pop edx                ; y           ; #2
   pop edx                ; x           ; #3
   pop edx                ; h           ; #4
   pop edx                ; w           ; #5
   pop edx                ; matrix size ; #6
   pop edx                ; m           ; #7

   funret3_1 eax





; Subtask 3 Matrix multiplication
; 
; For the final part you are on your own: implement the nested loop that computes
; the product of matrices A and B and stores the result in C.
; 
;==========================================
; M A T R I X  M U L T I P L I C A T I O N
;==========================================
; Perform multiplication on the global matrices A and B, storing the result in C.
;
; Java Referance Code:
;
;    for (int i=0; i<l; ++i) { // Ytre for løkke
;      for (int j=0; j<m; ++j) { // Midterste for loop
;        int acc = 0;
;        for (int k=0; k<n; ++k) { // Innerste for loop
;          acc += A[i][k] * B[k][j];
;        } // Indre for loop
;        C[i][j] = acc;
;      } // Midterste for loop
;    } // Ytre foor loop
matmul:
;                                      ┌───────────────────
; ─────────────────────────────────────┤ TO BE FILLED
;                                      └───────────
   middle_loop:
;  int acc = 0;
   inner_loop:
;  acc += A[i][k] * B[k][j]
;  for (int k=0; k<n; ++k)
   inc k
   cmp k, n
   jl inner_loop
;  C[i][j] = acc;
;  for (int j=0; j<m; ++j)
   inc j
   cmp j, m
   jl middle_loop
;  for (int i=0; i<l; ++i)
   inc i
   cmp i, l
   jl matmul
   ret
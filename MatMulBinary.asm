;  ======================================================
;     A  S  S  E  M  B  L  Y    T  E  M  P  L  A  T  E
;  ======================================================
;
;  This is the program you are supposed to complete and make equivalent to
;  the existing Java program.





;  H E L P E R  M A C R O S
;  ========================
;
;  These macros illustrate how assembly uses the stack for passing values around,
;  in particular passing arguments to "functions".
;  Note that the macros are expanded before the actual assembler begins, you
;  could as well do that manuall.

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




;  M A I N  E N T R Y  P O I N T
;  =============================
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
   mov eax,1       ;; sys_exit
   int 80h




; D A T A  I N P U T
; ==================
; void readBinaryData(tgtAddress, nBytes)
readBinaryData:
   mov eax,SYS_READ        ;  ────────────┐
   mov ebx,STDIN           ;   TO BE      │
   mov ecx, w32FrStck(1)   ;   COMMENTED  │
   mov edx, 8*4            ;              │
   int 80h                 ;              │
   mov eax, 8*4            ;              │
   mov ecx, w32FrStck(1)   ;              │
   add ecx, eax            ;              │
   mov w32FrStck(1), ecx   ;              │
   mov edx, w32FrStck(2)   ;              │
   sub edx, eax            ;              │
   mov w32FrStck(2), edx   ;              │
   cmp edx, 0              ;              │
   jg readBinaryData       ;  ────────────┘
   ret




; P S E U D O  H A S H  F U N C T I O N
; =====================================
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
   inc eax                
   mov ebx, w32FrStck(6)  ; w*h
   mov edx, 0             
   div ebx                ; edx <- (acc*m[y][x] + 1) % (w*h)
   mov w32FrStck(1), edx  ; acc
   mov ebx, w32FrStck(4)  ; h
   mov eax, edx           ; acc
   mov edx, 0             
   div ebx                ; edx <- acc % h
   mov w32FrStck(2), edx  ; y <- acc%h
   readoutMatrix eax, w32FrStck(7), w32FrStck(5), w32FrStck(2), w32FrStck(3)
                          ; m     ,     w       ,     y       ,     x

   ;                                      ┌───────────────────
   ; ─────────────────────────────────────┤ TO BE FILLED
   ;                                      └ (ca. 6 instructions)
                          
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




; M A T R I X  M U L T I P L I C A T I O N
; ========================================
; Perform multiplication on the global matrices A and B, storing the result in C.
matmul:
   ;                                      ┌───────────────────
   ; ─────────────────────────────────────┤ TO BE FILLED
   ;                                      └───────────
   ret


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
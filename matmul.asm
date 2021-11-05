matmul:           
   push dword 0                 ; acc           #3
   push dword 0                 ; iterations k  #2
   push dword 0                 ; iterations j  #1
   push dword 0                 ; iterations i  #0
   
;  for (int i=0; i<l; ++i)
outer_loop:
   mov ecx, w32FrStck(0)  ; iterations i
   cmp ecx, l             ; compare i and l
   jge outer_loop_end     ; i < l ?
   
;  for (int j=0; j<m; ++j)
   mov ecx, w32FrStck(1) ; j
   mov ecx, 0 ; j = 0 resets j for next loop
   mov w32FrStck(1), ecx ; store j
middle_loop:
   mov ecx, w32FrStck(1)  ; ecx <- iterations j
   cmp ecx, m             ; compare j and m
   jge middle_loop_end    ; j < m ?
   
;  int acc = 0;
   mov eax, w32FrStck(3) ; acc
   mov eax, 0            ; acc = 0
   mov w32FrStck(3), eax ; store acc
   
;  for (int k=0; k<n; ++k)
   mov ecx, w32FrStck(2) ; k
   mov ecx, 0 ; k = 0 resets k for next loop
   mov w32FrStck(2), ecx ; store k
inner_loop:
   mov ecx, w32FrStck(2)  ; iterations k
   cmp ecx, n             ; compare k and n
   jge inner_loop_end     ; k < n ?
   
;  acc += A[i][k] * B[k][j]
   readoutMatrix ecx, matrixA, n, w32FrStck(0), w32FrStck(2) ; ecx <- A[i][k]
                  ;     mA    , w,      y=i    ,     x=k
   readoutMatrix eax, matrixB , m, w32FrStck(2), w32FrStck(1) ; eax <- B[k][j]
                  ;     mB    , w,      y=k    ,     x=j
   mul ecx ; eax <- (A[i][k] * B[k][j])
   mov ecx, w32FrStck(3) ; ecx <- acc
   add eax, ecx ; acc += A[i][k] * B[k][j]
   mov w32FrStck(3), eax ; store acc
   
   mov ecx, w32FrStck(2)  ; iterations k
   inc ecx                ; k++
   mov w32FrStck(2), ecx  ; save k
   jmp inner_loop         ; jump to start of inner loop
   
inner_loop_end:
   
;  C[i][j] = acc;
   mov ecx, w32FrStck(3) ; acc
   writeToMatrix ecx , matrixC, m, w32FrStck(0), w32FrStck(1)
            ;    acc ,   mC   , w,     y=i     ,     x=j
   
   mov ecx, w32FrStck(1)  ; iterations j
   inc ecx                ; j++
   mov w32FrStck(1), ecx  ; save j
   jmp middle_loop        ; jump to start of middle loop

middle_loop_end:
   
   mov ecx, w32FrStck(0)  ; iterations i
   inc ecx                ; i++
   mov w32FrStck(0), ecx  ; save i
   jmp outer_loop         ; jump to start of outer loop

outer_loop_end:
   
   pop eax                ; i           ; #0
   pop ebx                ; j           ; #1
   pop ecx                ; k           ; #2
   pop edx                ; acc         ; #3
   
   ret
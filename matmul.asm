; Subtask 3 Matrix multiplication
matmul:
   push 0                 ; acc           #3
   push 0                 ; iterations k  #2
   push 0                 ; iterations j  #1
   push 0                 ; iterations i  #0
   
;  for (int i=0; i<l; ++i)
   mov ecx, w32FrStck(0) ; i
   mov ecx, 0 ; i = 0
   mov w32FrStck(0), ecx ; store i
outer_loop:
   mov ecx, w32FrStck(0)  ; iterations i
   cmp ecx, l             ; i < l ?
   jge outer_loop_end

;  for (int j=0; j<m; ++j)
   mov ecx, w32FrStck(1) ; j
   mov ecx, 0 ; j = 0
   mov w32FrStck(1), ecx ; store j
middle_loop:
   mov ecx, w32FrStck(1)  ; iterations j
   cmp ecx, m             ; j < m ?
   jge middle_loop_end
   

;  int acc = 0;
   mov eax, w32FrStck(3) ; acc
   mov eax, 0            ; acc = 0
   mov w32FrStck(3), eax ; store acc

;  for (int k=0; k<n; ++k)
   mov ecx, w32FrStck(2) ; k
   mov ecx, 0 ; k = 0
   mov w32FrStck(2), ecx ; store k
inner_loop:
   mov ecx, w32FrStck(2)  ; iterations k
   cmp ecx, n             ; k < n ?
   jge inner_loop_end

;  acc += A[i][k] * B[k][j]
   readoutMatrix eax, matrixA , n, w32FrStck(0), w32FrStck(2)
                  ;     mA    , w,      y=i    ,     x=k
   readoutMatrix ebx, matrixB , m, w32FrStck(2), w32FrStck(1)
                  ;     mB    , w,      y=k    ,     x=j
   mul ebx ; A[i][k] * B[k][j]
   mov ebx, w32FrStck(3) ; acc
   add ebx, eax ; acc += A[i][k] * B[k][j]
   add ebx, edx
   mov w32FrStck(3), ebx ; store acc
   

   mov ecx, w32FrStck(2)  ; iterations k
   inc ecx                ; k++
   mov w32FrStck(2), ecx  ; save k
   jmp inner_loop

inner_loop_end:
   
;  C[i][j] = acc;
   mov ebx, w32FrStck(3) ; acc
   writeToMatrix ebx , matrixC, m, w32FrStck(0), w32FrStck(1)
            ;    acc ,   mC   , w,     y=i     ,     x=j
   

   mov ecx, w32FrStck(1)  ; iterations j
   inc ecx                ; j++
   mov w32FrStck(1), ecx  ; save j
   jmp middle_loop
middle_loop_end:
   

   mov ecx, w32FrStck(0)  ; iterations i
   inc ecx                ; i++
   mov w32FrStck(0), ecx  ; save i
   jmp outer_loop
outer_loop_end:
   
   pop edx                ; i           ; #0
   pop eax                ; j           ; #1
   pop edx                ; k           ; #2
   pop eax                ; acc         ; #3
   
   ret
; Subtask 3 Matrix multiplication
matmul:
   push 0                 ; acc                 #3
   push 0                 ; iterations k (=n)   #2
   push 0                 ; iterations j (=m)   #1
   push 0                 ; iterations i (=l)   #0

outer_loop:
   mov ecx, w32FrStck(1) ; j
   mov ecx, 0 ; j = 0
   mov w32FrStck(1), ecx ; store j

middle_loop:
   mov ecx, w32FrStck(2) ; k
   mov ecx, 0 ; k = 0
   mov w32FrStck(2), ecx ; store k

;  int acc = 0;
   mov eax, w32FrStck(3)
   mov eax, 0
   mov w32FrStck(3), eax

inner_loop:

;  acc += A[i][k] * B[k][j]
   readoutMatrix eax, matrixA , n, w32FrStck(2), w32FrStck(0)
                  ;     mA    , w,      y=k    ,     x=i
   readoutMatrix ebx, matrixB , m, w32FrStck(1), w32FrStck(2)
                  ;     mB    , w,      y=j    ,     x=k
   mul ebx ; A[i][k] * B[k][j]d
   mov ecx, w32FrStck(3) ; acc
   add ecx, eax; acc += A[i][k] * B[k][j]
   mov w32FrStck(3), ecx ; store acc
   
;  for (int k=0; k<n; ++k)
   mov ecx, w32FrStck(2)  ; iterations k
   inc ecx                ; k++
   mov w32FrStck(2), ecx  ; save k
   cmp ecx, n             ; k < n ?
   jl inner_loop
   
;  C[i][j] = acc;
   mov eax, w32FrStck(3)
   writeToMatrix eax , matrixC, m, w32FrStck(1), w32FrStck(0)
            ;    acc ,   mc   , w,     y       ,     x
   
;  for (int j=0; j<m; ++j)
   mov ecx, w32FrStck(1)  ; iterations j
   inc ecx                ; j++
   mov w32FrStck(1), ecx  ; save j
   cmp ecx, m             ; j < m ?
   jl middle_loop
   
;  for (int i=0; i<l; ++i)
   mov ecx, w32FrStck(0)  ; iterations i
   inc ecx                ; i++
   mov w32FrStck(0), ecx  ; save i
   cmp ecx, l             ; i < l ?
   jl outer_loop
   
   pop edx                ; i           ; #0
   pop eax                ; j           ; #1
   pop edx                ; k           ; #2
   pop eax                ; acc         ; #3
   
   ret
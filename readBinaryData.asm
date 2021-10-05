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
#!/bin/bash
nasm -f elf32 MatMulBinary.asm -o MatMulBinary.o
ld -m elf_i386 MatMulBinary.o -o MatMulBinary

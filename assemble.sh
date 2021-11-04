#!/bin/bash
nasm -f elf -F dwarf -g MatMulBinary.asm
ld -m elf_i386 MatMulBinary.o -o MatMulBinary

javac MatMulUniversal.java
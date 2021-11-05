#!/bin/bash
nasm -f elf -F dwarf -g MatMulBinary.asm
ld -m elf_i386 MatMulBinary.o -o MatMulBinary

javac MatMulUniversal.java

(cat A0.mat B4.mat | ./toBinary)>input

cat input | java MatMulUniversal --binary
cat input | ./MatMulBinary
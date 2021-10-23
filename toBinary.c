// This is a simple helper tool for converting decimal integer numbers
// into machine-native 32-bit signed binary integers.
//
// It is not necessary that you do anything with this source file, you
// only need to compile it and use the resulting executable program.


#include <stdint.h>
#include <stdio.h>

int main () {
  int32_t x;
  while (scanf("%d", &x) == 1) { // Read decimal number from stdin
    fwrite(&x, 4, 1, stdout);    // Put binary number to stdout
  }
  return 0;
}

#include <stdio.h>
#include <stdlib.h>

#include "char_binary/char_binary_wrap.h"

int main() {
  /* The array functions use 'char *', as %apply SWIGTYPE * { char * } does not add a pointer to it */
  char *chars = char_binary_new_pchar(3);
  char_binary_pchar_setitem(chars, 1, 'x');
  if (char_binary_pchar_getitem(chars, 1) != 'x') {
    fprintf(stderr, "pchar_getitem failed\n");
    exit(1);
  }
  char_binary_delete_pchar(chars);
  return 0;
}

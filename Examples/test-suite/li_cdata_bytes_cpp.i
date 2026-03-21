%module li_cdata_bytes_cpp

%include <cdata.i>

%{
#include <stdlib.h>
static unsigned char _pre_bug[0x200];
void *predefStr(void) {
  unsigned i;
  for (i = 0; i < 0x100; i++) {
    _pre_bug[i] = (unsigned char)i;
    _pre_bug[i + 0x100] = (unsigned char)i;
  }
  return _pre_bug;
}
int verifyBytes(void *ptr) {
  unsigned i;
  unsigned char *p;
  if (ptr == NULL)
    return -1;
  p = (unsigned char *)ptr;
  for (i = 0; i < 0x100; i++) {
    unsigned char v = (unsigned char)(0x100 - 1 - i);
    if (p[i] != v || p[i + 0x100] != v)
      return -1;
  }
  return 0;
}
%}

void *malloc(size_t size);
void free(void *);
void *predefStr(void);
int verifyBytes(void *ptr);

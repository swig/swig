/* -----------------------------------------------------------------------------
 * debug.c
 * 
 * This file contains a variety of different programming errors to test with
 * WAD.
 * ----------------------------------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include <assert.h>

typedef double Real;
typedef Real Float;

char buffer[256];

/* A simple segmentation fault on an uninitialized pointer */
int seg_crash() {
  int *a = 0;
  *a = 3;
  return 1;
}

/* Blow the process heap */

int blowheap_crash() {
  int i;
  int *a = (int *) malloc(sizeof(int));

  for (i = 0;; i++) {
    a[i] = i;
  }
}

/* Buffer overflow crash on the stack */
int overflow_crash() {
  int a[512];
  int i;

  for (i = 0; i < 1024; i++) {
    a[i] = i;
  }
}

/* A simple bus error.  */
int bus_crash() {
  double *a = (double *) (buffer+1);
  *a = 3.4;
  return 1;
}

/* An assertion */
int abort_crash(int n) {
  assert(n > 0);
  return 1;
}

/* A math error (maybe) */
int math_crash(int x, int y) {
  return x/y;
}

void type_crash(int a, short b, char c, unsigned long d, float f, double g) {
  int la;
  short lb;
  char  lc;
  long  ld;
  float lf;
  double lg;
  long   ll;

  la = a;
  lb = b;
  lc = c;
  ld = ld;
  lf = lf;
  lg = lg;
  assert(0);
}

#ifdef NEED_MAIN

static const char *usage="\n\
Usage: debug type\n\
   seg        - Fail with an uninitialized pointer.\n\
   bus        - Fail with a bus error.\n\
   abort      - Fail with an assertion error.\n\
   math       - Fail with a math error.\n\
   heap       - Blow the process heap.\n\
   overflow   - Buffer overflow on the stack.\n\
";

int main(int argc, char **argv) {
  int n;

  printf("WAD debug program.\n");

  if (argc < 2) {
    printf("%s\n", usage);
    exit(0);
  }
  if (strcmp(argv[1],"abort") == 0) {
    abort_crash(-4);
  } else if (strcmp(argv[1],"seg") ==0) {
    seg_crash();
  } else if (strcmp(argv[1],"bus") == 0) {
    bus_crash();
  } else if (strcmp(argv[1],"math") == 0) {
    math_crash(3,0);
  } else if (strcmp(argv[1],"heap") == 0) {
    blowheap_crash();
  } else if (strcmp(argv[1],"overflow") == 0) {
    overflow_crash();
  } else if (strcmp(argv[1],"type") == 0) {
    type_crash(0,2,'x',420000,3.14159,2.1828);
  }
}

#endif

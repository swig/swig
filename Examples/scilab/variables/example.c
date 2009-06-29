/* File : example.c */

/* I'm a file containing some C global variables */

/* Deal with Microsoft's attempt at deprecating C standard runtime functions */
#if !defined(SWIG_NO_CRT_SECURE_NO_DEPRECATE) && defined(_MSC_VER)
# define _CRT_SECURE_NO_DEPRECATE
#endif

#include <stdio.h>
#include <stdlib.h>
#include "sciprint.h"

int              ivar = 0;                    
short            svar = 0;
long             lvar = 0;
unsigned int     uivar = 0;
unsigned short   usvar = 0;
unsigned long    ulvar = 0;
signed char      scvar = 0;
unsigned char    ucvar = 0;
char             cvar = 0;
float            fvar = 0;
double           dvar = 0;
char            *strvar=0;
double          *Foo1;
double          *Foo2;



/* A debugging function to print out their values */

void print_vars() {
  printf("ivar      = %d\n", ivar);
  printf("svar      = %d\n", svar);
  printf("lvar      = %ld\n", lvar);
  printf("uivar     = %u\n", uivar);
  printf("usvar     = %u\n", usvar);
  printf("ulvar     = %lu\n", ulvar);
  printf("scvar     = %d\n", scvar);
  printf("ucvar     = %u\n", ucvar);
  printf("fvar      = %g\n", fvar);
  printf("dvar      = %g\n", dvar);
  printf("cvar      = %c\n", cvar);
  printf("strvar    = %s\n",strvar);
}




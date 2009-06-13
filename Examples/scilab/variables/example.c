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


/* A debugging function to print out their values */

void print_vars() {
  sciprint("ivar      = %d\n", ivar);
  sciprint("svar      = %d\n", svar);
  sciprint("lvar      = %ld\n", lvar);
  sciprint("uivar     = %u\n", uivar);
  sciprint("usvar     = %u\n", usvar);
  sciprint("ulvar     = %lu\n", ulvar);
  sciprint("scvar     = %d\n", scvar);
  sciprint("ucvar     = %u\n", ucvar);
  sciprint("fvar      = %g\n", fvar);
  sciprint("dvar      = %g\n", dvar);
  sciprint("cvar      = %c\n", cvar);
  sciprint("strvar    = %s\n",strvar);
}




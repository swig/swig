/* ----------------------------------------------------------------------------- 
 * vars.c
 *
 *     This file examines the stack trace and tries to make some sense out of
 *     collected debugging information.  This includes locating the data on
 *     the stack and/or registers. 
 *
 *     This feature is detached from the debugging info collector to make
 *     it independent of debugging formats.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"

/* -----------------------------------------------------------------------------
 * wad_build_vars()
 *
 * Build variable information for a single stack frame
 * ----------------------------------------------------------------------------- */
 
void wad_build_vars(WadFrame *f) {
  char *stack = 0;
  char *nstack = 0;
  char *pstack = 0;
  WadLocal  *loc;
  int   laststack = 0;
  WadLocal  *lastloc = 0;

  stack = (char *) f->stack;
  if (f->next) {
    nstack = (char *) f->next->stack;
  }
  if (f->prev) {
    pstack = (char *) f->prev->stack;
  }
  loc = f->debug_args;

  while (loc) {
    loc->ptr = 0;
    if (loc->loc == PARM_STACK) {
      if ((loc->stack >= 0) && (nstack)) {
	loc->ptr = (void *) (nstack + loc->stack);
      } else if (loc->stack < 0) {
	loc->ptr = (void *) (stack + f->stack_size + loc->stack);
      }
      loc->size = sizeof(long);
    }
    if (loc->loc == PARM_REGISTER) {
      /* Parameter is located in a register */
#ifdef WAD_SOLARIS
      if ((loc->reg >= 24) && (loc->reg < 32)) {
	/* Value is located in the %in registers.  */
	  loc->ptr = (void *) (stack + (loc->reg - 16)*sizeof(int));
	  loc->size = sizeof(int);
      } else if ((loc->reg >= 8) && (loc->reg < 16)) {

          /* Value is located in the %on registers */
	if (nstack) {
	  loc->ptr = (void *) (stack + (loc->reg)*sizeof(int));
	  loc->size = sizeof(int);
	}
      } else if ((loc->reg >= 16) && (loc->reg < 24)) {
	/* Value has been placed in the %ln registers */
	loc->ptr = (void *) (stack + (loc->reg - 16)*sizeof(int));
	loc->size = sizeof(int);
      }
#endif
    }
#ifdef OLD
    if (lastloc) {
      /* Figure out the size */
      if (!lastloc->size)
	lastloc->size = abs(loc->stack - lastloc->stack);
    }
    lastloc = loc;
#endif

    loc = loc->next;
  }
#ifdef OLD
  /* If last size is not set. Assume that it is a word */
  if (lastloc && (!lastloc->size)) {
    lastloc->size = 4;
  }
#endif

}

/* This function creates a formatted integer given a pointer, size, and sign flag */
static
char *wad_format_int(char *ptr, int nbytes, int sgn) {
  static char fmt[128];
  unsigned char   *s;
  int     incr;
  unsigned long value = 0;
  int     i;

#ifdef WAD_LITTLE_ENDIAN
  s = (unsigned char *) (ptr + nbytes - 1);
  incr = -1;
#else
  s = (unsigned char *) (ptr);
  incr = +1;
#endif
  for (i = 0; i < nbytes; i++, s += incr) {
    value = (value << 8) + *s;
  }
  if (sgn) {
    sprintf(fmt,"%ld", (long) value);
  } else {
    sprintf(fmt,"%lu", value);
  }
  return fmt;
}

/* Try to make a formatted version of a local */
char *wad_format_var(WadLocal *l) {
  static char hexdigits[] = "0123456789abcdef";
  static char buffer[1024];
  double dval;
  float  fval;

  buffer[0] = 0;

  switch(l->type) {
  case WAD_TYPE_INT32:
    strcpy(buffer,wad_format_int(l->ptr,4,1));
    break;
  case WAD_TYPE_UINT32:
    strcpy(buffer,wad_format_int(l->ptr,4,0));
    break;
  case WAD_TYPE_INT16:
    strcpy(buffer,wad_format_int(l->ptr,2,1));
    break;
  case WAD_TYPE_UINT16:
    strcpy(buffer,wad_format_int(l->ptr,2,0));
    break;
  case WAD_TYPE_INT8:
    strcpy(buffer,wad_format_int(l->ptr,1,1));
    break;
  case WAD_TYPE_UINT8:
    strcpy(buffer,wad_format_int(l->ptr,1,0));
    break;
  case WAD_TYPE_CHAR:
    sprintf(buffer,"'%c'", *((char *)l->ptr));
    break;
  case WAD_TYPE_FLOAT:
    memcpy(&fval,l->ptr,sizeof(float));
    sprintf(buffer,"%g",fval);
    break;
  case WAD_TYPE_DOUBLE:
    memcpy(&dval,l->ptr,sizeof(double));
    sprintf(buffer,"%g",dval);
    break;
  case WAD_TYPE_UNKNOWN:
  case WAD_TYPE_POINTER:
  default:
    /* Hmmm. Unknown data type.   We'll just treat it as a word */
    if (l->ptr) {
      int   incr,i;
      int    b;
      int    leading = 1;
      char  *c;
      char  *ptr;
#ifdef WAD_LITTLE_ENDIAN
      ptr = ((char *) l->ptr) + 3;
      incr = -1;
#else
      ptr = (char *) l->ptr;
      incr =1 ;
#endif
      strcat(buffer,"0x");
      c = buffer+2;
      for (i = 0; i < 4; i++) {
	b = (int) *ptr;
	if (!leading || (b)) {
	  if (!leading || (b & 0xf0))
	    *(c++) = hexdigits[(b & 0xf0) >> 4];
	  *(c++) = hexdigits[(b & 0xf)];
	  leading = 0;
	}
	ptr += incr;
      }
      if (leading)
	*(c++) = '0';
      
      *c = 0;
    }
  }
  return buffer;
}






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
    }
    if (lastloc) {
      /* Figure out the size */
      if (!lastloc->size)
	lastloc->size = abs(loc->stack - lastloc->stack);
    }
    lastloc = loc;
    loc = loc->next;
  }

  /* If last size is not set. Assume that it is a word */
  if (lastloc && (!lastloc->size)) {
    lastloc->size = 4;
  }

}

/* Try to make a formatted version of a local */
char *wad_format_var(WadLocal *l) {
  static char hexdigits[] = "0123456789abcdef";
  static char buffer[1024];

  buffer[0] = 0;

  switch(l->type) {
  case TYPE_UNKNOWN:
  default:
    /* Hmmm. Unknown data type.   We'll just dump out digits */
    if (l->ptr) {
      if (l->size <= 8) {
	int   incr,i;
	int    b;
	int    leading = 1;
	char  *c;
	char  *ptr;
#ifdef WAD_LITTLE_ENDIAN
	ptr = ((char *) l->ptr) + l->size - 1;
	incr = -1;
#else
	ptr = (char *) l->ptr;
	incr =1 ;
#endif
	strcat(buffer,"0x");
	c = buffer+2;
	for (i = 0; i < l->size; i++) {
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
      } else {
	sprintf(buffer,"unknown(%d bytes)", l->size);
      }
    }
  }
  return buffer;
}






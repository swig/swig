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
 * Copyright (C) 2000.  The University of Chicago. 
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * See the file COPYING for a complete copy of the LGPL.
 * ----------------------------------------------------------------------------- */

#include "wad.h"

static char cvs[] = "$Id$";

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
  int   n;

  stack = (char *) f->stack;
  if (f->next) {
    nstack = (char *) f->next->stack;
  }
  if (f->prev) {
    pstack = (char *) f->prev->stack;
  }

  for (n = 0; n < 2; n++) {
    if (n == 0) loc = f->debug_args;
    else loc = f->debug_locals;

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
      loc = loc->next;
    }
  }
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
    return wad_format_signed((long) value,-1);
  } else {
    return wad_format_unsigned((unsigned long) value, -1);
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
    wad_strcpy(buffer,wad_format_int(l->ptr,4,1));
    break;
  case WAD_TYPE_UINT32:
    wad_strcpy(buffer,wad_format_int(l->ptr,4,0));
    break;
  case WAD_TYPE_INT16:
    wad_strcpy(buffer,wad_format_int(l->ptr,2,1));
    break;
  case WAD_TYPE_UINT16:
    wad_strcpy(buffer,wad_format_int(l->ptr,2,0));
    break;
  case WAD_TYPE_INT8:
    wad_strcpy(buffer,wad_format_int(l->ptr,1,1));
    break;
  case WAD_TYPE_UINT8:
    wad_strcpy(buffer,wad_format_int(l->ptr,1,0));
    break;
  case WAD_TYPE_CHAR:
    buffer[0] = '\'';
    buffer[1] = *((char *) l->ptr);
    buffer[2] = '\'';
    buffer[3] = 0;
    break;
  case WAD_TYPE_FLOAT:
    wad_memcpy(&fval,l->ptr,sizeof(float));
    sprintf(buffer,"%g",fval);
    break;
  case WAD_TYPE_DOUBLE:
    wad_memcpy(&dval,l->ptr,sizeof(double));
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
      wad_strcat(buffer,"0x");
      c = buffer+2;
      for (i = 0; i < sizeof(void *); i++) {
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

/* Convert a wad local variable to a long */
long wad_local_as_long(WadLocal *loc) {
  long           value = 0;
  int32          i32;
  int16          i16;
  int8           i8;
  uint32         u32;
  uint16         u16;
  uint8          u8;

  switch(loc->type) {
  case WAD_TYPE_INT32:
    wad_memcpy(&i32,loc->ptr,4);
    value = (long) i32;
    break;
  case WAD_TYPE_UINT32:
    wad_memcpy(&u32,loc->ptr,4);
    value = (long) u32;
    break;
  case WAD_TYPE_INT16:
    wad_memcpy(&i16,loc->ptr,2);
    value = (long) i16;
    break;
  case WAD_TYPE_UINT16:
    wad_memcpy(&u16,loc->ptr,2);
    value = (long) u16;
    break;
  case WAD_TYPE_INT8:
  case WAD_TYPE_CHAR:
    wad_memcpy(&i8, loc->ptr,1);
    value = (long) i8;
    break;
  case WAD_TYPE_UINT8:
    wad_memcpy(&u8, loc->ptr,1);
    value = (long) u8;
    break;
  default:
    wad_memcpy(&u32,loc->ptr,4);
    value = (long) u32;
  }
  return value;
}

/* Convert a wad local variable to a long */
double wad_local_as_double(WadLocal *loc) {
  double         value = 0;
  float          fval;

  switch(loc->type) {
  case WAD_TYPE_DOUBLE:
    wad_memcpy(&value,loc->ptr,8);
    break;
  case WAD_TYPE_FLOAT:
    wad_memcpy(&fval,loc->ptr,4);
    value = (double) fval;
    break;
  default:
    value = 0;
  }
  return value;
}







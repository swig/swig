/* ----------------------------------------------------------------------------- 
 * io.c
 *
 *     This file provides some I/O routines so that WAD can produce 
 *     debugging output without using buffered I/O.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"
#include <stdarg.h>

void wad_printf(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  vfprintf(stderr,fmt,ap);
  va_end(ap);
}

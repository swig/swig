/* ----------------------------------------------------------------------------- 
 * io.c
 *
 *     This file provides some I/O routines so that WAD can produce 
 *     debugging output without using buffered I/O.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago.  All rights reserved. 
 * ----------------------------------------------------------------------------- */

#include "wad.h"
#include <stdarg.h>

static char cvs[] = "$Header$";

/* Utility functions used to generate strings that are guaranteed not to 
   rely upon malloc() and related functions */

char *wad_format_hex(unsigned long u, int leading) {
  static char result[64];
  int i;
  char *c;
  c = &result[63];
  *c = 0;
  for (i = 0; i < (sizeof(unsigned long)*2); i++) {
    int d;
    d = (int) (u & 0xf);
    c--;
    if (d < 10) {
      *c = '0' + d;
    } else {
      *c = 'a' + (d-10);
    }
    if (!u && !leading) break;
    u = u >> 4;
  }
  return c;
}

char *wad_format_unsigned(unsigned long u, int width) {
  static char result[128];
  static char digits[] = "0123456789";
  char *c, *w;
  int count = 0;
  int i;
  c = &result[64];
  while (u) {
    int digit = u % 10;
    *(--c) = digits[digit];
    count++;
    u = u / 10;
  }
  if (!count) {
    *(--c) = '0';
    count++;
  }
  w = &result[64];
  for (i = count; i < width; i++) {
    *(w++) = ' ';
  }
  *w = 0;
  return c;
}

char *wad_format_signed(signed long s, int width) {
  static char result[128];
  unsigned long u;
  char *c = result;
  if (s < 0) {
    *(c++) = '-';
    width--;
    u = (unsigned long) (-s);
    if (u == 0) {
      u = (unsigned long) s;
    }
  } else {
    u = (unsigned long) s;
  }
  *c = 0;
  wad_strcat(result, wad_format_unsigned(u,width));
  return result;
}


void wad_printf(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  vfprintf(stderr,fmt,ap);
  va_end(ap);
}

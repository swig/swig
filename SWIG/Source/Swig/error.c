/* ----------------------------------------------------------------------------- 
 * error.c
 *
 *     Error handling functions.   These are used to issue warnings and
 *     error messages.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include <stdarg.h>
#include <ctype.h>

static char cvsroot[] = "$Header$";

#define MAXWARN 1000

static int silence = 0;            /* Silent operation */
static char filter[MAXWARN] = { 0 };
static int warnall = 0;

/* -----------------------------------------------------------------------------
 * Swig_warning()
 *
 * Issue a warning message
 * ----------------------------------------------------------------------------- */

void 
Swig_warning(int wnum, const String_or_char *filename, int line, const char *fmt, ...) {
  String *out;
  char   *msg;
  va_list ap;
  if (silence) return;

  va_start(ap,fmt);

  out = NewString("");
  vPrintf(out,fmt,ap);
  {
    char temp[64], *t;
    t = temp;
    msg = Char(out);
    while (isdigit(*msg)) {
      *(t++) = *(msg++);
    }
    if (t != temp) {
      msg++;
      wnum = atoi(temp);
    }
  }
  if (warnall || !filter[wnum]) {
    if (wnum) {
      Printf(stderr,"%s:%d: Warning(%d): ", filename, line, wnum);
    } else {
      Printf(stderr,"%s:%d: Warning: ", filename, line, wnum);
    }
    Printf(stderr,"%s",msg);
  }
  Delete(out);
  va_end(ap);
}

/* -----------------------------------------------------------------------------
 * Swig_error()
 *
 * Issue an error message
 * ----------------------------------------------------------------------------- */

static int nerrors = 0;

void 
Swig_error(const String_or_char *filename, int line, const char *fmt, ...) {
  va_list ap;

  if (silence) return;

  va_start(ap,fmt);
  if (line > 0) {
    Printf(stderr,"%s:%d: ", filename, line);
  } else {
    Printf(stderr,"%s:EOF: ", filename);
  }
  vPrintf(stderr,fmt,ap);
  va_end(ap);
  nerrors++;
}

/* -----------------------------------------------------------------------------
 * Swig_numerrors()
 *
 * Returns number of errors received.
 * ----------------------------------------------------------------------------- */

int
Swig_numerrors(void) {
  return nerrors;
}

/* -----------------------------------------------------------------------------
 * Swig_error_silent()
 *
 * Set silent flag
 * ----------------------------------------------------------------------------- */

void
Swig_error_silent(int s) {
  silence = s;
}

/* -----------------------------------------------------------------------------
 * Swig_warnfilter()
 * ----------------------------------------------------------------------------- */

void
Swig_warnfilter(const String_or_char *wlist, int allow) {
  char *c;
  int  wnum;
  String *s = NewString(wlist);
  c = Char(s);
  c = strtok(c,",");
  while (c) {
    wnum = atoi(c);
    if ((wnum > 0) && (wnum < MAXWARN)) {
      filter[wnum] = allow;
    }
    c = strtok(NULL,",");
  }
  Delete(s);
}

void
Swig_warnall(void) {
  warnall = 1;
}



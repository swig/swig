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

char cvsroot_error_c[] = "$Header$";

/* -----------------------------------------------------------------------------
 * Commentary on the warning filter.
 *
 * The warning filter is a string of numbers prefaced by (-) or (+) to
 * indicate whether or not a warning message is displayed.  For example:
 *
 *      "-304-201-140+210+201"
 *
 * The filter string is scanned left to right and the first occurrence
 * of a warning number is used to determine printing behavior.
 *
 * The same number may appear more than once in the string.  For example, in the 
 * above string, "201" appears twice.  This simply means that warning 201
 * was disabled after it was previously enabled.  This may only be temporary
 * setting--the first number may be removed later in which case the warning
 * is reenabled.
 * ----------------------------------------------------------------------------- */

static int silence = 0;            /* Silent operation */
static String *filter = 0;         /* Warning filter */
static int warnall = 0;
static int   nwarning = 0;

/* -----------------------------------------------------------------------------
 * Swig_warning()
 *
 * Issue a warning message
 * ----------------------------------------------------------------------------- */

void 
Swig_warning(int wnum, const String_or_char *filename, int line, const char *fmt, ...) {
  String *out;
  char   *msg;
  int     wrn = 1;
  va_list ap;
  if (silence) return;
  
  va_start(ap,fmt);

  out = NewString("");
  vPrintf(out,fmt,ap);
  {
    char temp[64], *t;
    t = temp;
    msg = Char(out);
    while (isdigit((int) *msg)) {
      *(t++) = *(msg++);
    }
    if (t != temp) {
      msg++;
      *t = 0;
      wnum = atoi(temp);
    }
  }

  /* Check in the warning filter */
  if (filter) {
    char    temp[32];    
    char *c;
    sprintf(temp,"%d",wnum);
    c = Strstr(filter,temp);
    if (c) {
      if (*(c-1) == '-') wrn = 0;     /* Warning disabled */
      if (*(c-1) == '+') wrn = 1;     /* Warning enabled */
    }
  }
  if (warnall || wrn) {
    if (wnum) {
      Printf(stderr,"%s:%d: Warning(%d): ", filename, line, wnum);
    } else {
      Printf(stderr,"%s:%d: Warning: ", filename, line, wnum);
    }
    Printf(stderr,"%s",msg);
    nwarning++;
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
 * Swig_error_count()
 *
 * Returns number of errors received.
 * ----------------------------------------------------------------------------- */

int
Swig_error_count(void) {
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
 *
 * Takes a comma separate list of warning numbers and puts in the filter.
 * ----------------------------------------------------------------------------- */

void
Swig_warnfilter(const String_or_char *wlist, int add) {
  char *c;
  String *s;

  if (!filter) filter = NewString("");
  s = NewString(wlist);
  c = Char(s);
  c = strtok(c,", ");
  while (c) {
    if (isdigit((int) *c) || (*c == '+') || (*c == '-')) {
      if (add) {
	Insert(filter,0,c);
	if (isdigit((int) *c)) {
	  Insert(filter,0,"-");
	}
      } else {
	char temp[32];
	if (isdigit((int) *c)) {
	  sprintf(temp,"-%s",c);
	} else {
	  strcpy(temp,c);
	}
	Replace(filter,temp,"", DOH_REPLACE_FIRST);
      }
    }
    c = strtok(NULL,", ");
  }
  Delete(s);
}

void
Swig_warnall(void) {
  warnall = 1;
}


/* ----------------------------------------------------------------------------- 
 * Swig_warn_count()
 *
 * Return the number of warnings
 * ----------------------------------------------------------------------------- */

int
Swig_warn_count(void) {
  return nwarning;
}


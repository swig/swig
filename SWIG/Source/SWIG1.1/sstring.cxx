/* -----------------------------------------------------------------------------
 * sstring.cxx
 *
 *     SWIG string object.
 *
 * Note: 6/27/2000 - This module is now just a wrapper around a DOHString.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2000.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "internal.h"
#include <ctype.h>
extern "C" {
#include "doh.h"
}

//-----------------------------------------------------------------------
// char *copy_string(char *str)
//
// Makes a copy of string str.  Returns a pointer to it.
//-----------------------------------------------------------------------

char *copy_string(char *str) {
  char *res = 0;
  if (str) {
    res = new char[strlen(str)+1];
    strcpy(res,str);
  }
  return res;
}

//-----------------------------------------------------------------------
// void format_string(char *str)
//
// Replace all of the escape sequences in the string str.   It is
// assumed that the new string is smaller than the original!
//-----------------------------------------------------------------------

void format_string(char *str) {
  char *newstr, *c,*c1;
  int  state;
  if (!str) return;
  newstr = copy_string(str);
  c = newstr;
  c1 = str;
  state = 0;
  while (*c) {
    switch(state) {
    case 0:
      if (*c == '\\')
	state = 1;
      else {
	*(c1++) = *c;
	state = 0;
      }
      break;
   case 1:
      // We're in a simple escape sequence figure out what to do
      switch(*c) {
      case 'n':
	*(c1++) = '\n';
	break;
      case 'f':
	*(c1++) = '\f';
	break;
      case 'r':
	*(c1++) = '\r';
	break;
      case 't':
	*(c1++) = '\t';
	break;
      case '\\':
	*(c1++) = '\\';
      break;
      case '\"':
	*(c1++) = '\"';
      break;
      case '\'':
	*(c1++) = '\'';
      break;
      default:
	*(c1++) = '\\';
        *(c1++) = *c;
      }
      state = 0;
      break;
    default:
      *(c1++) = *c;
      state = 0;
    }
    c++;
  }
  *c1 = 0;
  delete newstr;
}




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

// ---------------------------------------------------------------------------
// $Header$
// sstring.cxx
//
// SWIG String class.
// This class is used to construct long strings when writing
// wrapper functions.  It also "mimicks" the C++ streams I/O
// library for creating strings.  For example :
//
//     str << "hi there" << 3 << "\n";
//
// Will append the given strings to str.
//
// The idea here is to provide a mechanism for writing wrapper
// functions as strings before writing them out to a file.
//
// ---------------------------------------------------------------------------

String::String() {
  str = NewString("");
}

String::String(const char *s) {
  str = NewString(s);
}

String::~String() {
  Delete(str);
}

char *String::get() const {
  return Char(str);
}

String &operator<<(String &t,const char *s) {
  Append(t.str,s);
  return t;
}

String &operator<<(String &t,const char s) {
  char temp[2] = { 0, 0 };
  temp[0] = s;
  Append(t.str,temp);
  return t;
}

String &operator<<(String &t,const int a) {
  char  temp[64];
  sprintf(temp,"%d",a);
  Append(t.str,temp);
  return t;
}

String &operator<<(String &t, const String &s) {
  Append(t.str,s.str);
  return t;
}

String &String::operator=(const char *s) {
  Delete(str);
  str = NewString(s);
  return *this;
}

String &operator>>(const char *s, String &t) {
  Insert(t.str,0,s);
  return t;
}

String &operator>>(const String &s, String &t) {
  Insert(t.str,0,s.str);
  return t;
}

void String::replace(const char *token, const char *rep) {
  Replace(str,token,rep,DOH_REPLACE_ANY);
}

void String::replaceid(const char *token, const char *rep) {
  Replace(str,token,rep,DOH_REPLACE_ID);
}

// -----------------------------------------------------------------
// void String::strip()
//
// Intelligently strips whitespace from a string.    Will not strip
// whitespace if it is between two characters that are part of a
// legal C identifier. For example 'unsigned int'.
// -----------------------------------------------------------------

void String::strip() {
  DOH *so = str;
  char *s = Char(so);
  char *c, lastchar = 0;
  int   whitespace = 0;

  str = NewString("");
  c = s;
  while(*c) {
    if (!isspace(*c)) {
      // See if this character doesn't violate our whitespace rules
      if (whitespace) {
	if (isalnum(lastchar) || (lastchar == '_') || (lastchar == '$')) {
	  if (isalnum(*c) || (*c == '_') || (*c == '$'))
	    Putc(' ', str);
	}
      }
      Putc(*c,str);
      lastchar = *c;
      whitespace = 0;
    } else {
      whitespace = 1;
    }
    c++;
  }
  Delete(so);
}




/* ----------------------------------------------------------------------------- 
 * naming.cxx
 *
 *     Functions for creating various kinds of names used during code generation.
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

// Hash table containing naming data

static Hash naming_hash;

//-----------------------------------------------------------------
// make_wrap_name(char *s)
//
// Takes the name at src, and converts it into a syntactically
// valid identifier name.   This is a hack to get the wrapper
// generator to support class member functions and other things.
//
// ie.  We can define a function name as obj->foo(),
// but we'll need to call the wrapper function something like
// _wrap_obj__foo()
//-----------------------------------------------------------------

void make_wrap_name(char *s) {

  char *c1 = s;
  int  i;
  for (i = 0; i < (int) strlen(s); i++, c1++) {
    if(!isalnum(*c1)) *c1 = '_';
  }
}

// --------------------------------------------------------------------------------
// void name_register(char *method, char *format)
//
// Registers a new naming scheme.
// --------------------------------------------------------------------------------

void name_register(char *method, char *format) {
  naming_hash.remove(method);
  naming_hash.add(method,copy_string(format));
}

// --------------------------------------------------------------------------------
// char *name_getformat(char *method)
//
// Get name format
// --------------------------------------------------------------------------------

static char *name_getformat(char *method) {
  return (char *) naming_hash.lookup(method);
}

// --------------------------------------------------------------------------------
// char *name_wrapper(char *fname, char *prefix, int suppress)
//
// Returns the name of a wrapper function.  The following variables are
// available :
//
//         %f          -> fname
//         %p          -> prefix
//         %l          -> language
//
// By default a wrapper function gets the name _wrap_prefixfname.
//
// --------------------------------------------------------------------------------

char *name_wrapper(char *fname, char *prefix, int suppress) {
  static String fmt;
  char   *f;

  f = name_getformat((char*)"wrapper");
  if (!f) {
    f = (char*)"_wrap_%p%f";                  // Default wrapper name
  }
  fmt = f;
  fmt.replace("%f",fname);
  fmt.replace("%l",typemap_lang);
  fmt.replace("%p",prefix);
  if (!suppress)
    make_wrap_name(fmt);
  return fmt;
}


// --------------------------------------------------------------------------------
// char *name_member(char *fname, char *classname, int suppress)
//
// Returns the name of a method function.  The following variables are
// available :
//
//         %f          -> fname
//         %c          -> classname
//         %l          -> language
//
// By default, the name of a method is given as Classname_method.
// --------------------------------------------------------------------------------

char *name_member(char *fname, char *classname, int suppress) {
  static String fmt;
  char   *f;

  f = name_getformat((char*)"member");
  if (!f) {
    f = (char*)"%c_%f";
  }
  fmt = f;
  fmt.replace("%f",fname);
  fmt.replace("%l",typemap_lang);
  fmt.replace("%c",classname);
  if (!suppress)
    make_wrap_name(fmt);
  return fmt;
}


// --------------------------------------------------------------------------------
// char *name_get(char *vname, int suppress)
//
// Returns the name of the accessor function used to get a variable.
//
//         %v          -> variable name
//
// --------------------------------------------------------------------------------

char *name_get(char *vname, int suppress) {
  static String fmt;
  char   *f;

  f = name_getformat((char*)"get");
  if (!f) {
    f = (char*)"%v_get";
  }
  fmt = f;
  fmt.replace("%v",vname);
  if (!suppress)
    make_wrap_name(fmt);
  return fmt;
}

// --------------------------------------------------------------------------------
// char *name_set(char *vname, int suppress)
//
// Returns the name of the accessor function used to set a variable.
//
//         %v          -> variable name
// --------------------------------------------------------------------------------

char *name_set(char *vname, int suppress) {
  static String fmt;
  char   *f;

  f = name_getformat((char*)"set");
  if (!f) {
    f = (char*)"%v_set";
  }
  fmt = f;
  fmt.replace("%v",vname);
  if (!suppress)
    make_wrap_name(fmt);
  return fmt;
}
  

// --------------------------------------------------------------------------------
// char *name_construct(char *classname, int suppress)
//
// Returns the name of the accessor function used to create an object.
// By default this is "new_classname"
//
//         %c          -> classname
//         %l          -> language
//
// --------------------------------------------------------------------------------

char *name_construct(char *classname, int suppress) {
  static String fmt;
  char   *f;

  f = name_getformat((char*)"construct");
  if (!f) {
    f = (char*)"new_%c";
  }
  fmt = f;
  fmt.replace("%l",typemap_lang);
  fmt.replace("%c",classname);
  if (!suppress)
    make_wrap_name(fmt);
  return fmt;
}
  

// --------------------------------------------------------------------------------
// char *name_destroy(char *classname, int suppress)
//
// Returns the name of the accessor function used to destroy an object.
// By default this is "delete_classname"
//
//         %c          -> classname
//         %l          -> language
//
// --------------------------------------------------------------------------------

char *name_destroy(char *classname, int suppress) {
  static String fmt;
  char   *f;

  f = name_getformat((char*)"destroy");
  if (!f) {
    f = (char*)"delete_%c";
  }
  fmt = f;
  fmt.replace("%l",typemap_lang);
  fmt.replace("%c",classname);
  if (!suppress)
    make_wrap_name(fmt);
  return fmt;
}

/* ----------------------------------------------------------------------------- 
 * wrapfunc.cxx
 *
 *     Wrapper function object.
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

// ------------------------------------------------------------------
// This file defines a class for writing wrappers.  Instead of worrying
// about I/O problems, this wrapper class can be used to write functions
// out of order.
// 
// Defines 3 string objects.
//     def      - Wrapper function definition (function name and arguments)
//     locals   - Local variable definitions
//     code     - The actual wrapper function code
//
//-------------------------------------------------------------------

#include "internal.h"
#include <ctype.h>

extern "C" {
#include "doh.h"
}

WrapperFunction::WrapperFunction() {
  h = NewHash();
  localh = NewHash();
  def = NewString("");
  locals = NewString("");
  code = NewString("");
}

WrapperFunction::~WrapperFunction() {
  Delete(h);
  Delete(localh);
}

// -------------------------------------------------------------------
// isolate the type name.  This is a hack (sorry).
// -------------------------------------------------------------------

static char type_ext[512];
static char *isolate_type_name(char *tname) {
  static char s[512];
  char *c = s;

  while ((*tname) && (isalnum(*tname) || (*tname == '_') || (*tname == '$') || (*tname == ' ') || (*tname == ':'))) {
    *(c++) = *tname;
    tname++;
  }
  *c = 0;
  strcpy(type_ext,tname);
  return s;
}

// -------------------------------------------------------------------
// Print out a wrapper function.
// -------------------------------------------------------------------

void WrapperFunction::print(DOHFile *f) {
  DOHString *s;
  DOH  *key;
  
  key = Firstkey(localh);
  while (key) {
    s = Getattr(localh,key);
    Delitem(s,DOH_END);
    Printv(locals,tab4,s,";\n",0);
    key = Nextkey(localh);
  }
  Printf(f,"%s\n",def);
  Printf(f,"%s",locals);
  Printf(f,"%s\n",code);
}

// -------------------------------------------------------------------
// Safely add a local variable.
//
// Maintains a hash table to prevent double adding.
// -------------------------------------------------------------------

void WrapperFunction::add_local(char *type, char *name, char *defarg) {
  char *stored_type;
  char *new_type;
  char temp[256],*c,*t;

  new_type = new char[strlen(type)+1];
  strcpy(new_type,type);

  // Figure out what the name of this variable is

  c = name;
  t = temp;
  while ((isalnum(*c) || (*c == '_') || (*c == '$')) && (*c)) {
    *(t++) = *c;
    c++;
  }
  *t = 0;
  if (Getattr(h,temp)) {
    // Check to see if a type mismatch has occurred
    stored_type = GetChar(h,temp);
    if (strcmp(type,stored_type) != 0) 
      fprintf(stderr,"Error. Type %s conflicts with previously declared type of %s\n",
	      type, stored_type);
    return;    
  } else {
    SetChar(h,temp,new_type);
  }

  // See if any wrappers have been generated with this type 

  char *tname = isolate_type_name(type);
  DOHString *lstr = Getattr(localh,tname);
  if (!lstr) {
    lstr = NewStringf("%s ", tname);
    Setattr(localh,tname,lstr);
  }
  
  // Successful, write some wrapper code

  if (!defarg) {
    Printv(lstr,type_ext,name,",",0);
  } else {
    Printv(lstr,type_ext,name, "=", defarg, ",", 0);
  }
}


// -------------------------------------------------------------------
// char *WrapperFunction::new_local(char *type, char *name, char *defarg) {
//
// A safe way to add a new local variable.  type and name are used as
// a starting point, but a new local variable will be created if these
// are already in use.
// -------------------------------------------------------------------

char *WrapperFunction::new_local(char *type, char *name, char *defarg) {
  char *new_type;
  static DOHString *new_name = 0;
  char *c;
  new_type = new char[strlen(type)+1];

  if (!new_name) new_name = NewString("");
  strcpy(new_type,type);
  Clear(new_name);
  c = name;
  for (c = name; ((isalnum(*c) || (*c == '_') || (*c == '$')) && (*c)); c++)
    Putc(*c,new_name);

  // Try to add a new local variable
  if (Getattr(h,new_name)) {
    // Local variable already exists, try to generate a new name
    int i = 0;
    Clear(new_name);
    // This is a little funky.  We copy characters until we reach a nonvalid
    // identifier symbol, add a number, then append the rest.   This is
    // needed to properly handle arrays.
    c = name;
    for (c = name; ((isalnum(*c) || (*c == '_') || (*c == '$')) && (*c)); c++)
      Putc(*c,new_name);
    Printf(new_name,"%d",i);
    while (Getattr(h,new_name)) {
      i++;
      c = name;
      Clear(new_name);
      for (c = name; ((isalnum(*c) || (*c == '_') || (*c == '$')) && (*c)); c++)
	Putc(*c,new_name);
      Printf(new_name,"%d",i);
    }
    Setattr(h,new_name,new_type);
  } else {
    Setattr(h,new_name,new_type);
  }
  Printf(new_name,"%s",c);
  // Successful, write some wrapper code
  if (!defarg)
    Printv(locals,tab4,type, " ", new_name, ";\n");
  else
    Printv(locals,tab4,type, " ", new_name, " = ", defarg, ";\n");

  // Need to strip off the array symbols now

  c = Char(new_name);
  while ((isalnum(*c) || (*c == '_') || (*c == '$')) && (*c))
    c++;
  *c = 0;
  return Char(new_name);
}

// ------------------------------------------------------------------
// static WrapperFunction::del_type(void *obj)
//
// Callback function used when cleaning up the hash table.
// ------------------------------------------------------------------

void WrapperFunction::del_type(void *obj) {
  delete (char *) obj;
}

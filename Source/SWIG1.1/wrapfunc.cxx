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
}

WrapperFunction::~WrapperFunction() {
  Delete(h);
  Delete(localh);
}

// -------------------------------------------------------------------
// isolate the type name.  This is a hack (sorry).
// -------------------------------------------------------------------

static String type_ext;
static char *isolate_type_name(char *tname) {
  static String s;
  s = "";
  while ((*tname) && (isalnum(*tname) || (*tname == '_') || (*tname == '$') || (*tname == ' ') || (*tname == ':'))) {
    s << *tname;
    tname++;
  }
  type_ext = "";
  type_ext = tname;
  return s.get();
}

// -------------------------------------------------------------------
// Print out a wrapper function.
// -------------------------------------------------------------------

void WrapperFunction::print(FILE *f) {
  String *s;
  DOH  *key;
  
  key = Firstkey(localh);
  while (key) {
    s = (String *) GetVoid(localh,key);
    char *c = s->get();
    c[strlen(c)-1] = 0;
    locals << tab4 << c << ";\n";
    key = Nextkey(localh);
  }
  fprintf(f,"%s\n",def.get());
  fprintf(f,"%s",locals.get());
  fprintf(f,"%s\n",code.get());
}

// -------------------------------------------------------------------
// Print out a wrapper function.
// -------------------------------------------------------------------

void WrapperFunction::print(String &f) {
  String *s;
  DOH *key;
  key = Firstkey(localh);
  while (key) {
    s = (String *) GetVoid(localh,key);
    char *c = s->get();
    c[strlen(c)-1] = 0;
    locals << tab4 << c << ";\n";
    key = Nextkey(localh);
  }

  f << def << "\n"
    << locals << "\n"
    << code << "\n";
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
  String *lstr = (String *) GetVoid(localh,tname);
  if (!lstr) {
    lstr = new String;
    *(lstr) << tname << " ";
    SetVoid(localh,tname,lstr);
  }
  
  // Successful, write some wrapper code

  if (!defarg) {
    *(lstr) << type_ext << name << ",";
    // locals << tab4 << type << " " << name << ";\n";
  } else {
    *(lstr) << type_ext << name << "=" << defarg << ",";
    // locals << tab4 << type << " " << name << " = " << defarg << ";\n";
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
  static String new_name;
  char *c;
  new_type = new char[strlen(type)+1];

  strcpy(new_type,type);
  new_name = "";
  c = name;
  for (c = name; ((isalnum(*c) || (*c == '_') || (*c == '$')) && (*c)); c++)
    new_name << *c;

  // Try to add a new local variable
  if (Getattr(h,new_name.get())) {
    // Local variable already exists, try to generate a new name
    int i = 0;
    new_name = "";
    // This is a little funky.  We copy characters until we reach a nonvalid
    // identifier symbol, add a number, then append the rest.   This is
    // needed to properly handle arrays.
    c = name;
    for (c = name; ((isalnum(*c) || (*c == '_') || (*c == '$')) && (*c)); c++)
      new_name << *c;
    new_name << i;
    while (Getattr(h,new_name.get())) {
      i++;
      c = name;
      new_name = "";
      for (c = name; ((isalnum(*c) || (*c == '_') || (*c == '$')) && (*c)); c++)
	new_name << *c;
      new_name << i;
    }
    Setattr(h,new_name.get(),new_type);
  } else {
    Setattr(h,new_name.get(),new_type);
  }
  new_name << c;
  // Successful, write some wrapper code
  if (!defarg)
    locals << tab4 << type << " " << new_name << ";\n";
  else
    locals << tab4 << type << " " << new_name << " = " << defarg << ";\n";

  // Need to strip off the array symbols now

  c = new_name.get();
  while ((isalnum(*c) || (*c == '_') || (*c == '$')) && (*c))
    c++;
  *c = 0;
  return new_name;
}

// ------------------------------------------------------------------
// static WrapperFunction::del_type(void *obj)
//
// Callback function used when cleaning up the hash table.
// ------------------------------------------------------------------

void WrapperFunction::del_type(void *obj) {
  delete (char *) obj;
}

/* ----------------------------------------------------------------------------- 
 * wrapfunc.c
 *
 *     This file defines a object for creating wrapper functions.  Primarily
 *     this is used for convenience since it allows pieces of a wrapper function
 *     to be created in a non-linear manner.
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

#include "swig.h"

/* -----------------------------------------------------------------------------
 * isolate the type name.  This is a hack (sorry).
 * ----------------------------------------------------------------------------- */ 

static char type_ext[512];
static char *isolate_type_name(char *tname) {
  static char s[512];
  char   *c;
  c = s;
  while ((*tname) && (isalnum(*tname) || (*tname == '_') || (*tname == '$') || (*tname == ' ') || (*tname == ':'))) {
    *c = *tname;
    tname++;
    c++;
  }
  strcpy(type_exit,tname);
  return s;
}

/* -----------------------------------------------------------------------------
 * NewSwigWrapper()
 *
 * Create a new wrapper function object.
 * ----------------------------------------------------------------------------- */

SwigWrapper *
NewSwigWrapper() {
  SwigWrapper *w;
  w = (SwigWrapper *) malloc(sizeof(SwigWrapper));
  w->h = NewHash();
  w->localh = NewHash();
  w->locals = NewString();
  w->code = NewString();
  w->def = NewString();
}

/* -----------------------------------------------------------------------------
 * DelSwigWrapper()
 *
 * Delete a wrapper function object.
 * ----------------------------------------------------------------------------- */

void
DelSwigWrapper(SwigWrapper *w) {
  Delete(w->h);
  Delete(w->localh);
  Delete(w->locals);
  Delete(w->code);
  Delete(w->def);
  free(w);
}

/* -----------------------------------------------------------------------------
 * SwigWrapper_print()
 *
 * Print out a wrapper function.
 * ----------------------------------------------------------------------------- */

void 
SwigWrapper_print(SwigWrapper *w, DOHFile *f) {
  DOHString *s, *key, *c;

  key = Firstkey(w->localh);
  while (key) {
    s = Getattr(w->localh,key);
    c = Copy(s);
    Delitem(c,DOH_END);
    Append(c,";\n");
    Printf(w->locals,"    %s;\n", c);
    Delete(c);
    key = Nextkey(w->localh);
  }
  Printf(f,"%s\n", w->def);
  Printf(f,"%s", w->locals);
  Printf(f,"%s\n", w->code);
}

/* -----------------------------------------------------------------------------
 * SwigWrapper_add_local()
 *
 * Add a new local variable (accounts for duplicates)
 * ----------------------------------------------------------------------------- */

void
SwigWrapper_add_local(SwigWrapper *w, char *type, char *name, char *defarg) {
  DOHString *stored_type, *lstr;
  char *new_type;
  char temp[256],*c,*t;
  char *tname;

  new_type = copy_string(type);

  /* Figure out what the name of this variable is */

  c = name;
  t = temp;
  while ((isalnum(*c) || (*c == '_') || (*c == '$')) && (*c)) {
    *(t++) = *c;
    c++;
  }
  *t = 0;
  if (Getattr(w->h,temp)) {
    /* Check to see if a type mismatch has occurred */
    stored_type = Getattr(w->h,temp);
    if (Cmp(type,stored_type) != 0) {
      fprintf(stderr,"Error. Type %s conflicts with previously declared type of %s\n",
	      type, stored_type);
      return;    
    }
  } else {
    Setattr(w->h,temp,new_type);
  }

  /* See if any wrappers have been generated with this type */

  tname = isolate_type_name(type);
  lstr = Getattr(w->localh, tname);
  if (!lstr) {
    lstr = NewStringf("%s ",tname);
    Setattr(w->localh, tname, lstr);
  }
  
  /* Successful, write some wrapper code */
  if (!defarg) {
    Printf(lstr,"%s%s,", type_ext,name);
  } else {
    Printf(lstr,"%s%s = %s,", type_ext,name,defarg);
  }
  Delete(lstr);
}

#ifdef OLD

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
  if (h.add(new_name,new_type,WrapperFunction::del_type) == -1) {
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
    while (h.add(new_name,new_type,WrapperFunction::del_type) == -1) {
      i++;
      c = name;
      new_name = "";
      for (c = name; ((isalnum(*c) || (*c == '_') || (*c == '$')) && (*c)); c++)
	new_name << *c;
      new_name << i;
    }
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

#endif


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
 * NewSwigWrapper()
 *
 * Create a new wrapper function object.
 * ----------------------------------------------------------------------------- */

SwigWrapper *
NewSwigWrapper() {
  SwigWrapper *w;
  w = (SwigWrapper *) malloc(sizeof(SwigWrapper));
  w->localh = NewHash();
  w->locals = NewString("");
  w->code = NewString("");
  w->def = NewString("");
  return w;
}

/* -----------------------------------------------------------------------------
 * DelSwigWrapper()
 *
 * Delete a wrapper function object.
 * ----------------------------------------------------------------------------- */

void
DelSwigWrapper(SwigWrapper *w) {
  Delete(w->localh);
  Delete(w->locals);
  Delete(w->code);
  Delete(w->def);
  free(w);
}

/* -----------------------------------------------------------------------------
 * SwigWrapper_print()
 *
 * Print out a wrapper function.  Does pretty printing as well.
 * ----------------------------------------------------------------------------- */

void 
SwigWrapper_print(SwigWrapper *w, DOHFile *f) {
  DOHString *str, *ts;
  int level = 0;
  int c, i;
  int empty = 1;

  str = NewString("");
  ts = NewString("");
  Printf(str,"%s\n", w->def);
  Printf(str,"%s\n", w->locals);
  Printf(str,"%s\n", w->code);

  Seek(str,0, SEEK_SET);
  Clear(ts);
  while ((c = Getc(str)) != EOF) {

    if (c == '{') {
      Putc(c,ts);
      Putc('\n',ts);
      for (i = 0; i < level; i++) 
	Putc(' ',f);
      Printf(f,"%s", ts);
      Clear(ts);
      level+=4;
      while ((c = Getc(str)) != EOF) {
	if (!isspace(c)) {
	  Ungetc(c,str);
	  break;
	}
      }
    } else if (c == '}') {
      if (!empty) {
	Putc('\n',ts);
	for (i = 0; i < level; i++)
	  Putc(' ',f);
	Printf(f,"%s",ts);
	Clear(ts);
      }
      level-=4;
      Putc(c,ts);
    } else if (c == '\n') {
      Putc(c,ts);
      for (i = 0; i < level; i++)
	Putc(' ',f);
      Printf(f,"%s",ts);
      Clear(ts);
      empty = 1;
    } else {
      Putc(c,ts);
      empty = 0;
    }
  }
  Delete(ts);
  Delete(str);
}

/* -----------------------------------------------------------------------------
 * SwigWrapper_add_local()
 *
 * Adds a new local variable declaration to a function. Returns -1 if already
 * present (which may or may not be okay to the caller).
 * ----------------------------------------------------------------------------- */

int
SwigWrapper_add_local(SwigWrapper *w, DOHString_or_char *decl, DOHString_or_char *name) {
  /* See if the local has already been declared */
  if (Getattr(w->localh,name)) {
    return -1;
  }
  Setattr(w->localh,name,decl);
  Printf(w->locals,"%s;\n", decl);
}

/* -----------------------------------------------------------------------------
 * SwigWrapper_check_local()
 *
 * Check to see if a local name has already been declared
 * ----------------------------------------------------------------------------- */

int
SwigWrapper_check_local(SwigWrapper *w, DOHString_or_char *name) {
  if (Getattr(w->localh,name)) {
    return 1;
  }
  return 0;
}

#ifdef TEST
int main() {
  SwigWrapper *w;
  w = NewSwigWrapper();
  Printf(w->def,"int foo_wrap(ClientData clientdata, Tcl_Interp *interp, int argc, char *argv[]) {");
  SwigWrapper_add_local(w,"int a", "a");
  SwigWrapper_add_local(w,"int a", "a");
  SwigWrapper_add_local(w,"int b", "b");
  SwigWrapper_add_local(w,"char temp[256]","temp");
  
  Printf(w->code,"for (i = 0; i < 10; i++) { printf(\"%%d\", i); }\n");

  Printf(w->code,"if (1) { foo;\n} else { bar; \n}\n");

  Printf(w->code,"}\n");
  SwigWrapper_print(w,stdout);
  DelSwigWrapper(w);
}
#endif


/* -----------------------------------------------------------------------------
 * emit.cxx
 *
 *     Useful functions for emitting various pieces of code.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2000.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

#include "internal.h"
extern "C" {
#include "swig.h"
}

static char cvsroot[] = "$Header$";

/* -----------------------------------------------------------------------------
 * new_create_function()
 * 
 * Create a new function
 * ----------------------------------------------------------------------------- */

void new_create_function(char *name, char *iname, SwigType *type, ParmList *l) {
  Hash *h;
  h = NewHash();
  Setattr(h,"name",name);
  Setattr(h,"scriptname",iname);
  Setattr(h,"type",type);
  Setattr(h,"parms",l);
  lang->function(h);
  Delete(h);
}

/* -----------------------------------------------------------------------------
 * emit_args()
 *
 * Creates a list of variable declarations for both the return value
 * and function parameters.
 *
 * The return value is always called result and arguments arg0, arg1, arg2, etc...
 * Returns the number of parameters associated with a function.
 * ----------------------------------------------------------------------------- */

int emit_args(DOH *node, Wrapper *f) {

  SwigType *rt;
  ParmList *l;
  Parm *p;
  int   i;
  char *tm;
  SwigType *pt;
  DOHString  *pvalue;
  DOHString  *pname;
  DOHString  *lname;

  rt = Getattr(node,"type");
  l = Getattr(node,"parms");

  /* Emit function arguments */
  Swig_cargs(f, l);

  i = 0;
  p = l;
  while (p != 0) {
    lname  = Getlname(p);
    pt     = Gettype(p);
    pname  = Getname(p);
    pvalue = Getvalue(p);

    tm = Swig_typemap_lookup((char*)"arginit",pt,pname,(char*)"",lname,f);
    if (tm) {
      Printv(f,tm,"\n",0);
    }
    /* Check for ignore or default typemaps */
    tm = Swig_typemap_lookup((char*)"default",pt,pname,(char*)"",lname,f);
    if (tm) {
      Printv(f,tm,"\n",0);
    }
    tm = Swig_typemap_lookup((char*)"ignore",pt,pname,(char*)"",lname,f);
    if (tm) {
      Printv(f,tm,"\n",0);
      Setignore(p,1);
    }
    i++;
    p = Getnext(p);
  }
  return(i);
}

/* -----------------------------------------------------------------------------
 * int emit_func_call(char *decl, DataType *t, ParmList *l, Wrapper*f)
 *
 * Emits code for a function call (new version).
 *
 * Exception handling support :
 *
 *     -  This function checks to see if any sort of exception mechanism
 *        has been defined.  If so, we emit the function call in an exception
 *        handling block.
 * ----------------------------------------------------------------------------- */

static DOH *fcall = 0;

void emit_set_action(DOHString_or_char *decl) {
  if (fcall) Delete (fcall);
  fcall = NewString(decl);
}

void emit_func_call(DOH *node, Wrapper *f) {
  char *decl;
  SwigType *t;
  ParmList *l;
  char *tm;

  decl = GetChar(node,"name");
  t = Getattr(node,"type");
  l = Getattr(node,"parms");

  if ((tm = Swig_typemap_lookup((char*)"except",t,decl,(char*)"result",(char*)"",0))) {
    Printv(f,tm,0);
    Replace(f,"$name",decl,DOH_REPLACE_ANY);
  } else if ((tm = Swig_except_lookup())) {
    Printv(f,tm,0);
    Replace(f,"$name",decl,DOH_REPLACE_ANY);
  } else {
    Printv(f,"$function",0);
  }
  
  if (!fcall) fcall = NewString(Swig_cfunction_call(decl,l));

  if (CPlusPlus) {
    Swig_cppresult(f, t, (char*)"result", Char(fcall));
  } else {
    Swig_cresult(f, t, (char*)"result", Char(fcall));
  }
  Delete(fcall);
  fcall = 0;
}

/* -----------------------------------------------------------------------------
 * void emit_set_get()
 *
 * Emits a pair of functions to set/get the value of a variable.  This is
 * only used in the event the target language can't provide variable linking
 * on its own.
 *
 * double foo;
 *
 * Gets translated into the following :
 *
 * double foo_set(double x) {
 *      return foo = x;
 * }
 *
 * double foo_get() {
 *      return foo;
 * }
 * ----------------------------------------------------------------------------- */

/* How to assign a C allocated string */

static char *c_str = (char *)"\
if ($target) free($target);\n\
$target = ($rtype) malloc(strlen($source)+1);\n\
strcpy((char *)$target,$source);\n\
return $ltype $target;\n";

/* How to assign a C allocated string */

static char *cpp_str = (char *)"\
if ($target) delete [] $target;\n\
$target = ($rtype) (new char[strlen($source)+1]);\n\
strcpy((char *)$target,$source);\n\
return ($ltype) $target;\n;";


void emit_set_get(DOH *node) {
  char *name, *iname;
  SwigType *t;
  Wrapper *w;
  DOHString *new_iname;
  char    *code = 0;
  
  name = GetChar(node,"name");
  iname = GetChar(node,"iname");
  t = Getattr(node,"type");

  /* First write a function to set the variable of the variable */
  if (!(Status & STAT_READONLY)) {

    if (SwigType_type(t) == T_STRING) {
      if (CPlusPlus)
	code = cpp_str;
      else
	code = c_str;
    }
    w = Swig_cvarset_wrapper(name, t, code);
    Printf(f_header,"%s", w);
    new_iname = Swig_name_set(iname);
    DohIncref(new_iname);
    new_create_function(GetChar(w,"name"), Char(new_iname), Gettype(w), Getparms(w));
    Delete(new_iname);
    Delete(w);
  }

  w = Swig_cvarget_wrapper(name,t,0);
  Printf(f_header,"%s", w);
  new_iname = Swig_name_get(iname);
  DohIncref(new_iname);
  new_create_function(GetChar(w,"name"), Char(new_iname), Gettype(w), Getparms(w));
  Delete(new_iname);
  Delete(w);
}

/* ------------------------------------------------------------------
 * int check_numopt()
 *
 * Gets the number of optional arguments for a ParmList. 
 * ------------------------------------------------------------------ */

int check_numopt(ParmList *p) {
  int  n = 0;
  int  i = 0;
  int  state = 0;

  for (;p; p = Getnext(p),i++) {
    SwigType *pt = Gettype(p);
    String   *pn = Getname(p);
    if (Getvalue(p)) {
      n++;
      state = 1;
    } else if (Swig_typemap_search((char*)"default",pt,pn)) {
      n++;
      state = 1;
    } else if (Swig_typemap_search((char*)"ignore",pt,pn)) {
      n++;
    } else {
      if (state) {
	Printf(stderr,"%s : Line %d.  Argument %d must have a default value!\n", input_file,line_number,i+1);
      }
    }
  }
  return n;
}









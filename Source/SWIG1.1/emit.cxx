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
 * emit_args()
 *
 * Creates a list of variable declarations for both the return value
 * and function parameters.
 *
 * The return value is always called result and arguments arg0, arg1, arg2, etc...
 * Returns the number of parameters associated with a function.
 * ----------------------------------------------------------------------------- */

int emit_args(SwigType *rt, ParmList *l, Wrapper *f) {

  Parm *p;
  int   i;
  char *tm;
  SwigType *pt;
  DOHString  *pvalue;
  DOHString  *pname;
  DOHString  *lname;

  /* Emit function arguments */
  Swig_cargs(f, l);

  i = 0;
  p = l;
  while (p != 0) {
    lname  = Getlname(p);
    pt     = Gettype(p);
    pname  = Getname(p);
    pvalue = Getvalue(p);

    tm = typemap_lookup((char*)"arginit", typemap_lang, pt,pname,(char*)"",lname,f);
    if (tm) {
      Printv(f->code,tm,"\n",0);
    }
    /* Check for ignore or default typemaps */
    tm = typemap_lookup((char*)"default",typemap_lang,pt,pname,(char*)"",lname,f);
    if (tm) {
      Printv(f->code,tm,"\n",0);
    }
    tm = typemap_lookup((char*)"ignore",typemap_lang,pt,pname,(char*)"",lname,f);
    if (tm) {
      Printv(f->code,tm,"\n",0);
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

void emit_func_call(char *decl, SwigType *t, ParmList *l, Wrapper *f) {
  char *tm;

  if ((tm = typemap_lookup((char*)"except",typemap_lang,t,decl,(char*)"result",(char*)"",0))) {
    Printv(f->code,tm,0);
    Replace(f->code,"$name",decl,DOH_REPLACE_ANY);
  } else if ((tm = fragment_lookup((char*)"except",typemap_lang))) {
    Printv(f->code,tm,0);
    Replace(f->code,"$name",decl,DOH_REPLACE_ANY);
  } else {
    Printv(f->code,"$function",0);
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
 * void emit_set_get(char *name, char *iname, DataType *type)
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


void emit_set_get(char *name, char *iname, SwigType *t) {

  Wrapper *w;
  DOHString *new_iname;
  char    *code = 0;
    
  /* First write a function to set the variable of the variable */
  if (!(Status & STAT_READONLY)) {

    if (SwigType_type(t) == T_STRING) {
      if (CPlusPlus)
	code = cpp_str;
      else
	code = c_str;
    }
    w = Swig_cvarset_wrapper(name, t, code);
    Wrapper_print(w,f_header);
    new_iname = Swig_name_set(iname);
    DohIncref(new_iname);
    lang->create_function(Wrapper_Getname(w), Char(new_iname), Wrapper_Gettype(w), Wrapper_Getparms(w));
    Delete(new_iname);
    DelWrapper(w);
  }

  w = Swig_cvarget_wrapper(name,t,0);
  Wrapper_print(w,f_header);
  new_iname = Swig_name_get(iname);
  DohIncref(new_iname);
  lang->create_function(Wrapper_Getname(w), Char(new_iname), Wrapper_Gettype(w), Wrapper_Getparms(w));
  Delete(new_iname);
  DelWrapper(w);
}







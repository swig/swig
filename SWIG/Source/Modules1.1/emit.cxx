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

#include "swig11.h"

static char cvsroot[] = "$Header$";

extern Language *lang;

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
  String *tm;
  SwigType *pt;

  /* Emit function arguments */
  Swig_cargs(f, l);

  /* Attach typemaps to parameters */
  Swig_typemap_attach_parms("ignore",l,f);
  Swig_typemap_attach_parms("default",l,f);
  Swig_typemap_attach_parms("arginit",l,f);

  /* Apply the arginit, default, and arginit typemaps */

  p = l;
  while (p) {
    tm = Getattr(p,"tmap:arginit");
    if (tm) {
      Replace(tm,"$target", Getattr(p,"lname"), DOH_REPLACE_ANY);
      Printv(f->code,tm,"\n",0);
      p = Getattr(p,"tmap:arginit:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Apply the default typemap */
  p = l;
  while (p) {
    tm = Getattr(p,"tmap:default");
    if (tm) {
      Replace(tm,"$target", Getattr(p,"lname"), DOH_REPLACE_ANY);
      Printv(f->code,tm,"\n",0);
      p = Getattr(p,"tmap:default:next");
    } else {
      p = nextSibling(p);
    }
  }
  
  /* Apply the ignore typemap */
  p = l;
  while (p) {
    tm = Getattr(p,"tmap:ignore");
    if (tm) {
      Parm *np;
      Replace(tm,"$target", Getattr(p,"lname"), DOH_REPLACE_ANY);
      Printv(f->code,tm,"\n",0);
      np = Getattr(p,"tmap:default:next");

      /* Deprecate this part later */
      while (p && (p != np)) {
	Setattr(p,"ignore","1");
	p = nextSibling(p);
      }
      /* -- end deprecate */

    } else {
      p = nextSibling(p);
    }
  }

  /* Hack for compatibility -- Remove later */
  i = 0;
  p = l;
  while (p != 0) {
    pt     = Getattr(p,"type");
    if (SwigType_type(pt) != T_VOID) {
      i++;
    }
    p = nextSibling(p);
  }
  /* End hack */
  return i;
}

/* -----------------------------------------------------------------------------
 * emit_attach_parmmaps()
 *
 * Attach the standard parameter related typemaps.
 * ----------------------------------------------------------------------------- */

void emit_attach_parmmaps(ParmList *l, Wrapper *f) {
  Swig_typemap_attach_parms("in",l,f);
  Swig_typemap_attach_parms("argout",l,f);
  Swig_typemap_attach_parms("check",l,f);
  Swig_typemap_attach_parms("freearg",l,f);
}

/* -----------------------------------------------------------------------------
 * emit_num_arguments()                                         ** new in 1.3.10
 *
 * Calculate the total number of arguments.   This function is safe for use
 * with multi-valued typemaps which may change the number of arguments in
 * strange ways.
 * ----------------------------------------------------------------------------- */

int emit_num_arguments(ParmList *parms) {
  Parm *p = parms;
  int   nargs = 0;

  while (p) {
    /* Ignored arguments */
    if (Getattr(p,"tmap:ignore")) {
      p = Getattr(p,"tmap:ignore:next");
    } else {
      /* Marshalled arguments */
      nargs++;
      if (Getattr(p,"tmap:in")) {
	p = Getattr(p,"tmap:in:next");
      } else {
	p = nextSibling(p);
      }
    }
  }
  return nargs;
}

/* -----------------------------------------------------------------------------
 * emit_num_required()                                          ** new in 1.3.10
 *
 * Computes the number of required arguments.  This is function is safe for
 * use with multi-valued typemaps and knows how to skip over everything
 * properly.
 * ----------------------------------------------------------------------------- */

int emit_num_required(ParmList *parms) {
  Parm *p = parms;
  int   nargs = 0;

  while (p) {
    /* Ignored arguments */
    if (Getattr(p,"tmap:ignore")) {
      p = Getattr(p,"tmap:ignore:next");
    } else {
      if (Getattr(p,"value")) return nargs;
      if (Getattr(p,"tmap:default")) return nargs;
      nargs++;
      if (Getattr(p,"tmap:in")) {
	p = Getattr(p,"tmap:in:next");
      } else {
	p = nextSibling(p);
      }
    }
  }

  /* Might want an error message if any arguments that follow don't have defaults */
  return nargs;
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
  if (decl) {
    fcall = NewString(decl);
  } else {
    fcall = 0;
  }
}

void emit_func_call(char *decl, SwigType *t, ParmList *l, Wrapper *f) {
  String *tm;

  if ((tm = Swig_typemap_lookup((char*)"except",t,decl,(char*)"result", (char*)"result",(char*)"",0))) {
    Printv(f->code,tm,0);
    Replace(f->code,"$name",decl,DOH_REPLACE_ANY);
    Delete(tm);
  } else if ((tm = Swig_except_lookup())) {
    Printv(f->code,tm,0);
    Replace(f->code,"$name",decl,DOH_REPLACE_ANY);
    Delete(tm);
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
  File    *f_header;
  
  f_header = Swig_filebyname("header");
  assert(f_header);

  /* First write a function to set the variable of the variable */
  if (!ReadOnly) {

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

/* ------------------------------------------------------------------
 * int check_numopt()
 *
 * Gets the number of optional arguments for a ParmList. 
 * ------------------------------------------------------------------ */

int check_numopt(ParmList *p) {
  int  n = 0;
  int  i = 0;
  int  state = 0;

  for (;p; p = nextSibling(p),i++) {
    SwigType *pt = Getattr(p,"type");
    String   *pn = Getattr(p,"name");
    if (Getattr(p,"value")) {
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






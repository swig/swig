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

/* -----------------------------------------------------------------------------
 * emit_args()
 *
 * Creates a list of variable declarations for both the return value
 * and function parameters.
 *
 * The return value is always called result and arguments arg0, arg1, arg2, etc...
 * Returns the number of parameters associated with a function.
 * ----------------------------------------------------------------------------- */

void emit_args(SwigType *rt, ParmList *l, Wrapper *f) {

  Parm *p;
  String *tm;

  /* Emit function arguments */
  Swig_cargs(f, l);

  if (rt && (SwigType_type(rt) != T_VOID))
    Wrapper_add_local(f,"result", SwigType_lstr(rt,"result"));
  
  /* Attach typemaps to parameters */
  Swig_typemap_attach_parms("ignore",l,f);
  Swig_typemap_attach_parms("default",l,f);
  Swig_typemap_attach_parms("arginit",l,f);

  /* Apply the arginit, default, and ignore typemaps */

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
  return;
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
 * replace_args()
 * ----------------------------------------------------------------------------- */

static
void replace_args(Parm *p, String *s) {
  int i;
  while (p) {
    String *n = Getattr(p,"name");
    if (n) {
      Replace(s,n,Getattr(p,"lname"), DOH_REPLACE_ID);
    }
    p = nextSibling(p);
  }
}
 
/* -----------------------------------------------------------------------------
 * int emit_action()
 *
 * Emits action code for a wrapper and checks for exception handling
 * ----------------------------------------------------------------------------- */

void emit_action(Node *n, Wrapper *f) {
  String *tm;
  String *action;
  String *wrap;
  Parm   *p;

  /* Emit wrapper code (if any) */
  wrap = Getattr(n,"wrap:code");
  if (wrap) {
    File *f_code = Swig_filebyname("header");
    if (f_code) {
      Printv(f_code,wrap,0);
    }
  }
  action = Getattr(n,"wrap:action");
  assert(action);

  /* Preassert -- EXPERIMENTAL */
  tm = Getattr(n,"feature:preassert");
  if (tm) {
    p = Getattr(n,"parms");
    replace_args(p,tm);
    Printv(f->code,tm,"\n",0);
  }

  /* Exception handling code */

  /* Look for except typemap */
  tm = Swig_typemap_lookup_new("except",n,"result",0);

  /* Look for except feature */
  if (!tm) {
    tm = Getattr(n,"feature:except");
  }

  /* Look for global exception (deprecated) */
  if (!tm) {
    tm = Swig_except_lookup();
  }
  if (tm) {
    Replaceall(tm,"$name",Getattr(n,"name"));
    Replaceall(tm,"$symname", Getattr(n,"sym:name"));
    Replaceall(tm,"$function", action);
    Replaceall(tm,"$action", action);
    Printv(f->code,tm,"\n", 0);
  } else {
    Printv(f->code, action, "\n",0);
  }
  /* Postassert - EXPERIMENTAL */
  tm = Getattr(n,"feature:postassert");
  if (tm) {
    p = Getattr(n,"parms");
    replace_args(p,tm);
    Printv(f->code,tm,"\n",0);
  }
}





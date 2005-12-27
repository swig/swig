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

#include "swigmod.h"

char cvsroot_emit_cxx[] = "$Header$";

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

  /* Handle return type */
  if (rt && (SwigType_type(rt) != T_VOID)) {
    SwigType *vt = cplus_value_type(rt);
    SwigType *tt = vt ? vt : rt;
    SwigType *lt = SwigType_ltype(tt);
    String *lstr = SwigType_str(lt,"result");
    if (SwigType_ispointer(lt)) {
      Wrapper_add_localv(f,"result", lstr, "= 0", NULL);
    } else{
      Wrapper_add_local(f,"result", lstr);
    }
    if (vt) {
      Delete(vt);
    }
    Delete(lt);
    Delete(lstr);
  }
  
  /* Attach typemaps to parameters */
  /*  Swig_typemap_attach_parms("ignore",l,f); */

  Swig_typemap_attach_parms("default",l,f);
  Swig_typemap_attach_parms("arginit",l,f);

  /* Apply the arginit and default */
  p = l;
  while (p) {
    tm = Getattr(p,"tmap:arginit");
    if (tm) {
      Replace(tm,"$target", Getattr(p,"lname"), DOH_REPLACE_ANY);
      Printv(f->code,tm,"\n",NIL);
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
      Printv(f->code,tm,"\n",NIL);
      p = Getattr(p,"tmap:default:next");
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
  Swig_typemap_attach_parms("typecheck",l,0);
  Swig_typemap_attach_parms("argout",l,f);
  Swig_typemap_attach_parms("check",l,f);
  Swig_typemap_attach_parms("freearg",l,f);

  {
    /* This is compatibility code to deal with the deprecated "ignore" typemap */
    Parm *p = l;
    Parm *np;
    String *tm;
    while (p) {
      tm = Getattr(p,"tmap:in");
      if (tm && checkAttribute(p,"tmap:in:numinputs","0")) {
	Replaceall(tm,"$target", Getattr(p,"lname"));
	Printv(f->code,tm,"\n",NIL);
	np = Getattr(p,"tmap:in:next");
	while (p && (p != np)) {
	  Setattr(p,"ignore","1");
	  p = nextSibling(p);
	}
      } else if (tm) {
	p = Getattr(p,"tmap:in:next");
      } else {
	p = nextSibling(p);
      }
    }
  }

  /* Perform a sanity check on "in" and "freearg" typemaps.  These
     must exactly match to avoid chaos.  If a mismatch occurs, we
     nuke the freearg typemap */

  {
    Parm *p = l;
    Parm *npin, *npfreearg;
    while (p) {
      npin = Getattr(p,"tmap:in:next");
      
      /*
      if (Getattr(p,"tmap:ignore")) {
	npin = Getattr(p,"tmap:ignore:next");
      } else if (Getattr(p,"tmap:in")) {
	npin = Getattr(p,"tmap:in:next");
      }
      */

      if (Getattr(p,"tmap:freearg")) {
	npfreearg = Getattr(p,"tmap:freearg:next");
	if (npin != npfreearg) {
	  while (p != npin) {
	    Delattr(p,"tmap:freearg");
	    Delattr(p,"tmap:freearg:next");
	    p = nextSibling(p);
	  }
	}
      }
      p = npin;
    }
  }
      
  /* Check for variable length arguments with no input typemap.
     If no input is defined, we set this to ignore and print a
     message.
   */
  {
    Parm *p = l;
    Parm *lp = 0;
    while (p) {
      if (!checkAttribute(p,"tmap:in:numinputs","0")) {
	lp = p;
	p = Getattr(p,"tmap:in:next");
	continue;
      }
      if (SwigType_isvarargs(Getattr(p,"type"))) {
	Swig_warning(WARN_LANG_VARARGS,input_file,line_number,"Variable length arguments discarded.\n");
	Setattr(p,"tmap:in","");
      }
      lp = 0;
      p = nextSibling(p);
    }
    
    /* Check if last input argument is variable length argument */
    if (lp) {
      p = lp;
      while (p) {
	if (SwigType_isvarargs(Getattr(p,"type"))) {
	  Setattr(l,"emit:varargs",lp);
	  break;
	}
	p = nextSibling(p);
      }
    }
  }
}

/* -----------------------------------------------------------------------------
 * emit_num_arguments()
 *
 * Calculate the total number of arguments.   This function is safe for use
 * with multi-valued typemaps which may change the number of arguments in
 * strange ways.
 * ----------------------------------------------------------------------------- */

int emit_num_arguments(ParmList *parms) {
  Parm *p = parms;
  int   nargs = 0;

  while (p) {
    if (Getattr(p,"tmap:in")) {
      nargs += GetInt(p,"tmap:in:numinputs");
      p = Getattr(p,"tmap:in:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* DB 04/02/2003: Not sure this is necessary with tmap:in:numinputs */
  /*
  if (parms && (p = Getattr(parms,"emit:varargs"))) {
    if (!nextSibling(p)) {
      nargs--;
    }
  }
  */
  return nargs;
}

/* -----------------------------------------------------------------------------
 * emit_num_required()
 *
 * Computes the number of required arguments.  This function is safe for
 * use with multi-valued typemaps and knows how to skip over everything
 * properly. Note that parameters with default values are counted unless
 * the compact default args option is on.
 * ----------------------------------------------------------------------------- */

int emit_num_required(ParmList *parms) {
  Parm *p = parms;
  int   nargs = 0;
  Parm *first_default_arg = 0;
  int   compactdefargs = ParmList_is_compactdefargs(p);

  while (p) {
    if (Getattr(p,"tmap:in") && checkAttribute(p,"tmap:in:numinputs","0")) {
      p = Getattr(p,"tmap:in:next");
    } else {
      if (Getattr(p,"tmap:default")) break;
      if (Getattr(p,"value")) {
        if (!first_default_arg)
          first_default_arg = p;
        if (compactdefargs) break;
      }
      nargs+= GetInt(p,"tmap:in:numinputs");
      if (Getattr(p,"tmap:in")) {
	p = Getattr(p,"tmap:in:next");
      } else {
	p = nextSibling(p);
      }
    }
  }

  /* Print error message for non-default arguments following default arguments */
  /* The error message is printed more than once with most language modules, this ought to be fixed */
  if (first_default_arg) {
    p = first_default_arg;
    while (p) {
      if (Getattr(p,"tmap:in") && checkAttribute(p,"tmap:in:numinputs","0")) {
        p = Getattr(p,"tmap:in:next");
      } else {
        if (!Getattr(p,"value") && (!Getattr(p,"tmap:default"))) {
          Swig_error(Getfile(p),Getline(p),"Non-optional argument '%s' follows an optional argument.\n",Getattr(p,"name"));
        }
        if (Getattr(p,"tmap:in")) {
          p = Getattr(p,"tmap:in:next");
        } else {
          p = nextSibling(p);
        }
      }
    }
  }

  /* DB 04/02/2003: Not sure this is necessary with tmap:in:numinputs */
  /*
  if (parms && (p = Getattr(parms,"emit:varargs"))) {
    if (!nextSibling(p)) {
      nargs--;
    }
  }
  */
  return nargs;
}

/* -----------------------------------------------------------------------------
 * emit_isvarargs()
 *
 * Checks if a function is a varargs function
 * ----------------------------------------------------------------------------- */

int
emit_isvarargs(ParmList *p) {
  if (!p) return 0;
  if (Getattr(p,"emit:varargs")) return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 * void emit_mark_vararg_parms()
 *
 * Marks the vararg parameters which are to be ignored.
 * Vararg parameters are marked as ignored if there is no 'in' varargs (...) 
 * typemap.
 * ----------------------------------------------------------------------------- */

void emit_mark_varargs(ParmList *l) {
  Parm *p = l;
  while (p) {
    if (SwigType_isvarargs(Getattr(p,"type")))
      if (!Getattr(p,"tmap:in"))
        Setattr(p,"varargs:ignore","1");
    p = nextSibling(p);
  }
}

#if 0
/* replace_contract_args.  This function replaces argument names in contract
   specifications.   Used in conjunction with the %contract directive. */

static
void replace_contract_args(Parm *cp, Parm *rp, String *s) {
  while (cp && rp) {
    String *n = Getattr(cp,"name");
    if (n) {
      Replace(s,n,Getattr(rp,"lname"), DOH_REPLACE_ID);
    }
    cp = nextSibling(cp);
    rp = nextSibling(rp);
  }
}
#endif

/* -----------------------------------------------------------------------------
 * int emit_action()
 *
 * Emits action code for a wrapper and checks for exception handling
 * ----------------------------------------------------------------------------- */

void emit_action(Node *n, Wrapper *f) {
  String *tm;
  String *action;
  String *wrap;
  SwigType *rt;
  ParmList *throws = Getattr(n,"throws");

  /* Look for fragments */
  {
    String *f;
    f = Getattr(n,"feature:fragment");
    if (f) {
      char  *c, *tok;
      String *t = Copy(f);
      c = Char(t);
      tok = strtok(c,",");
      while (tok) {
	Swig_fragment_emit(tok);
	tok = strtok(NULL,",");
      }
      Delete(t);
    }
  }

  /* Emit wrapper code (if any) */
  wrap = Getattr(n,"wrap:code");
  if (wrap && Swig_filebyname("header")!=Getattr(n,"wrap:code:done") ) {
    File *f_code = Swig_filebyname("header");
    if (f_code) {
      Printv(f_code,wrap,NIL);
    }
    Setattr(n,"wrap:code:done",f_code);
  }
  action = Getattr(n,"feature:action");
  if (!action)
    action = Getattr(n,"wrap:action");
  assert(action != 0);

  if (!(is_public(n)) && is_member_director(n)) {
    /* We need to add an extra dynamic_cast to
       access the director class, where the virtual
       methods are all public */
    Node* parent = Getattr(n,"parentNode");
    String* symname = Getattr(parent, "sym:name");
    String* dirname = NewStringf("SwigDirector_%s", symname);
    String* dirdecl = NewStringf("%s *darg = 0", dirname);    
    Wrapper_add_local(f, "darg", dirdecl);
    Printf(f->code, "darg = dynamic_cast<%s *>(arg1);\n",dirname); 
    Replace(action, "arg1", "darg", DOH_REPLACE_FIRST);
    if (Getattr(n,"qualifier")) {
      /* fix constant casting introduced by a const method decl */
      String* classtype = Getattr(parent, "classtype");
      /*
	String *ccast = NewStringf("((%s const *)darg)",classtype);
	if (Strstr(action,ccast) != 0) 
      */
      Replace(action, classtype, dirname, DOH_REPLACE_FIRST);
    }
    Delete(dirname);
    Delete(dirdecl);
  }

  /* Get the return type */

  rt = Getattr(n,"type");

  /* Emit contract code (if any) */
  if (Swig_contract_mode_get()) {
    /* Preassertion */
    tm = Getattr(n, "contract:preassert");
    if (Len(tm)) {
      Printv(f->code,tm,"\n",NIL);
    }
  }
  /* Exception handling code */

  /* saves action -> eaction for postcatching exception */
  String *eaction = NewString("");
  
  /* If we are in C++ mode and there is an exception specification. We're going to
     enclose the block in a try block */
  if (throws) {
    Printf(eaction,"try {\n");
  }

  Printv(eaction, action, NIL);

  if (throws) {
    int unknown_catch = 0;
    Printf(eaction,"}\n");
    for (Parm *ep = throws; ep; ep = nextSibling(ep)) {
      String *em = Swig_typemap_lookup_new("throws",ep,"_e",0);
      if (em) {
        SwigType *et = Getattr(ep,"type");
        SwigType *etr = SwigType_typedef_resolve_all(et);
        if (SwigType_isreference(etr) || SwigType_ispointer(etr) || SwigType_isarray(etr)) {
          Printf(eaction,"catch(%s) {", SwigType_str(et, "_e"));
        } else {
          Printf(eaction,"catch(%s) {", SwigType_str(et, "&_e"));
        }
	Replaceall(em,"$exception","_e");
	Printv(eaction,em,"\n",NIL);
	Printf(eaction,"}\n");
      } else {
	Swig_warning(WARN_TYPEMAP_THROW, Getfile(n), Getline(n),
		     "No 'throws' typemap defined for exception type '%s'\n", 
		     SwigType_str(Getattr(ep,"type"),0));
	unknown_catch = 1;
      }
    }
    if (unknown_catch) {
      Printf(eaction,"catch(...) { throw; }\n");
    }
  }

  /* Look for except typemap (Deprecated) */
  tm = Swig_typemap_lookup_new("except",n,"result",0);

  /* Look for except feature */
  if (!tm) {
    tm = GetFlagAttr(n,"feature:except");
    if (tm) tm = Copy(tm);
  }  
  if ((tm) && Len(tm) && (Strcmp(tm,"1") != 0)) {
    Replaceall(tm,"$name",Getattr(n,"name"));
    Replaceall(tm,"$symname", Getattr(n,"sym:name"));
    Replaceall(tm,"$function", eaction);
    Replaceall(tm,"$action", eaction);
    Printv(f->code,tm,"\n", NIL);
    Delete(tm);
  } else {
    Printv(f->code,eaction,"\n",NIL);
  }
  Delete(eaction);

  /* Emit contract code (if any) */
  if (Swig_contract_mode_get()) {
    /* Postassertion */
    tm = Getattr(n, "contract:postassert");
    if (Len(tm)) {
      Printv(f->code,tm,"\n",NIL);
    }
  }

}

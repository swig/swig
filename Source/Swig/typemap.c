/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * typemap.c
 *
 * A somewhat generalized implementation of SWIG1.1 typemaps.
 * ----------------------------------------------------------------------------- */

char cvsroot_typemap_c[] = "$Id$";

#include "swig.h"
#include "cparse.h"
#include <ctype.h>

#if 0
#define SWIG_DEBUG
#endif

static int typemap_search_debug = 0;
static int in_typemap_search_multi = 0;

static void replace_embedded_typemap(String *s, ParmList *parm_sublist, Wrapper *f);

/* -----------------------------------------------------------------------------
 * Typemaps are stored in a collection of nested hash tables.  Something like
 * this:
 *
 * [ type ]
 *    +-------- [ name ]
 *    +-------- [ name ]
 *    
 * Each hash table [ type ] or [ name ] then contains references to the
 * different typemap methods.    These are referenced by names such as
 * "tmap:in", "tmap:out", "tmap:argout", and so forth.
 *
 * The object corresponding to a specific typemap method has the following attributes:
 *
 *    "type"    -  Typemap type
 *    "pname"   -  Parameter name
 *    "code"    -  Typemap code
 *    "typemap" -  Descriptive text describing the actual map
 *    "locals"  -  Local variables (if any)
 *    "kwargs"  -  Typemap attributes
 * 
 * Example for a typemap method named "in":
 *   %typemap(in, warning="987:my warning", noblock=1) int &my_int (int tmp) "$1 = $input;"
 *
 *    "type"    -  r.int
 *    "pname"   -  my_int
 *    "code"    -  $1 = $input;
 *    "typemap" -  typemap(in) int &my_int
 *    "locals"  -  int tmp
 *    "kwargs"  -  warning="987:my typemap warning", foo=123
 * 
 * ----------------------------------------------------------------------------- */

#define MAX_SCOPE  32


static Hash *typemaps[MAX_SCOPE];
static int tm_scope = 0;

static Hash *get_typemap(int tm_scope, SwigType *type) {
  Hash *tm = 0;
  SwigType *dtype = 0;
  if (SwigType_istemplate(type)) {
    String *ty = Swig_symbol_template_deftype(type, 0);
    dtype = Swig_symbol_type_qualify(ty, 0);
    /* Printf(stderr,"gettm %s %s\n", type, dtype); */
    type = dtype;
    Delete(ty);
  }
  tm = Getattr(typemaps[tm_scope], type);


  if (dtype) {
    if (!tm) {
      String *t_name = SwigType_templateprefix(type);
      if (!Equal(t_name, type)) {
	tm = Getattr(typemaps[tm_scope], t_name);
      }
      Delete(t_name);
    }
    Delete(dtype);
  }

  return tm;
}

static void set_typemap(int tm_scope, SwigType *type, Hash *tm) {
  SwigType *dtype = 0;
  if (SwigType_istemplate(type)) {
    String *ty = Swig_symbol_template_deftype(type, 0);
    dtype = Swig_symbol_type_qualify(ty, 0);
    /* Printf(stderr,"settm %s %s\n", type, dtype); */
    type = dtype;
    Delete(ty);
  } else {
    dtype = Copy(type);
    type = dtype;
  }
  Setattr(typemaps[tm_scope], type, tm);
  Delete(dtype);
}


/* -----------------------------------------------------------------------------
 * Swig_typemap_init()
 *
 * Initialize the typemap system
 * ----------------------------------------------------------------------------- */

void Swig_typemap_init() {
  int i;
  for (i = 0; i < MAX_SCOPE; i++) {
    typemaps[i] = 0;
  }
  typemaps[0] = NewHash();
  tm_scope = 0;
}

static String *typemap_method_name(const_String_or_char_ptr tmap_method) {
  static Hash *names = 0;
  String *s;
  /* Due to "interesting" object-identity semantics of DOH,
     we have to make sure that we only intern strings without object
     identity into the hash table.

     (typemap_attach_kwargs calls typemap_method_name several times with
     the "same" String *tmap_method (i.e., same object identity) but differing
     string values.)

     Most other callers work around this by using char* rather than
     String *.
     -- mkoeppe, Jun 17, 2003
   */
  const char *method_without_object_identity = Char(tmap_method);
  if (!names)
    names = NewHash();
  s = Getattr(names, method_without_object_identity);
  if (s)
    return s;
  s = NewStringf("tmap:%s", tmap_method);
  Setattr(names, method_without_object_identity, s);
  Delete(s);
  return s;
}

#if 0
/* -----------------------------------------------------------------------------
 * Swig_typemap_new_scope()
 * 
 * Create a new typemap scope
 * ----------------------------------------------------------------------------- */

void Swig_typemap_new_scope() {
  tm_scope++;
  typemaps[tm_scope] = NewHash();
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_pop_scope()
 *
 * Pop the last typemap scope off
 * ----------------------------------------------------------------------------- */

Hash *Swig_typemap_pop_scope() {
  if (tm_scope > 0) {
    return typemaps[tm_scope--];
  }
  return 0;
}
#endif

/* ----------------------------------------------------------------------------- 
 * typemap_register()
 *
 * Internal implementation for Swig_typemap_register()
 * ----------------------------------------------------------------------------- */

static void typemap_register(const_String_or_char_ptr tmap_method, ParmList *parms, const_String_or_char_ptr code, ParmList *locals, ParmList *kwargs, const_String_or_char_ptr actual_tmap_method, ParmList *parmlist_start) {
  Hash *tm;
  Hash *tm1;
  Hash *tm2;
  Parm *np;
  String *tm_method;
  SwigType *type;
  String *pname;

  if (!parms)
    return;
  tm_method = typemap_method_name(tmap_method);

  /* Register the first type in the parameter list */

  type = Getattr(parms, "type");
  pname = Getattr(parms, "name");

  /* See if this type has been seen before */
  tm = get_typemap(tm_scope, type);
  if (!tm) {
    tm = NewHash();
    set_typemap(tm_scope, type, tm);
    Delete(tm);
  }
  if (pname) {
    /* See if parameter has been seen before */
    tm1 = Getattr(tm, pname);
    if (!tm1) {
      tm1 = NewHash();
      Setattr(tm, pname, tm1);
      Delete(tm1);
    }
    tm = tm1;
  }

  /* Now see if this typemap method has been seen before */
  tm2 = Getattr(tm, tm_method);
  if (!tm2) {
    tm2 = NewHash();
    Setattr(tm, tm_method, tm2);
    Delete(tm2);
  }

  /* For a multi-argument typemap, the typemap code and information
     is really only stored in the last argument.  However, to
     make this work, we perform a really neat trick using
     the typemap method name.

     For example, consider this typemap

     %typemap(in) (int foo, int *bar, char *blah[]) {
     ...
     }

     To store it, we look at typemaps for the following:

     typemap method            type-name
     ----------------------------------------------
     "in"                      int foo
     "in-int+foo:"             int *bar
     "in-int+foo:-p.int+bar:   char *blah[]

     Notice how the typemap method name expands to encode information about
     previous arguments.        

   */

  np = nextSibling(parms);
  if (np) {
    /* Make an entirely new typemap method key */
    String *multi_tmap_method = NewStringf("%s-%s+%s:", tmap_method, type, pname);
    /* Now reregister on the remaining arguments */
    typemap_register(multi_tmap_method, np, code, locals, kwargs, actual_tmap_method, parmlist_start);

    /*    Setattr(tm2,multi_tmap_method,multi_tmap_method); */
    Delete(multi_tmap_method);
  } else {
    ParmList *clocals = CopyParmList(locals);
    ParmList *ckwargs = CopyParmList(kwargs);
    String *parms_str = ParmList_str(parmlist_start);
    String *typemap;
    if (ParmList_len(parmlist_start) > 1)
     typemap = NewStringf("typemap(%s) (%s)", actual_tmap_method, parms_str);
    else
     typemap = NewStringf("typemap(%s) %s", actual_tmap_method, parms_str);

    Setattr(tm2, "code", code);
    Setattr(tm2, "type", type);
    Setattr(tm2, "typemap", typemap);
    if (pname) {
      Setattr(tm2, "pname", pname);
    }
    Setattr(tm2, "locals", clocals);
    Setattr(tm2, "kwargs", ckwargs);

    Delete(clocals);
    Delete(ckwargs);

    Delete(parms_str);
    Delete(typemap);
  }
}

/* ----------------------------------------------------------------------------- 
 * Swig_typemap_register()
 *
 * Add a new, possibly multi-argument, typemap
 * ----------------------------------------------------------------------------- */

void Swig_typemap_register(const_String_or_char_ptr tmap_method, ParmList *parms, const_String_or_char_ptr code, ParmList *locals, ParmList *kwargs) {
  typemap_register(tmap_method, parms, code, locals, kwargs, tmap_method, parms);
}

/* -----------------------------------------------------------------------------
 * typemap_get()
 *
 * Retrieve typemap information from current scope.
 * ----------------------------------------------------------------------------- */

static Hash *typemap_get(SwigType *type, const_String_or_char_ptr name, int scope) {
  Hash *tm, *tm1;
  /* See if this type has been seen before */
  if ((scope < 0) || (scope > tm_scope))
    return 0;
  tm = get_typemap(scope, type);
  if (!tm) {
    return 0;
  }
  if ((name) && Len(name)) {
    tm1 = Getattr(tm, name);
    return tm1;
  }
  return tm;
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_copy()
 *
 * Copy a typemap
 * ----------------------------------------------------------------------------- */

int Swig_typemap_copy(const_String_or_char_ptr tmap_method, ParmList *srcparms, ParmList *parms) {
  Hash *tm = 0;
  String *tm_method;
  Parm *p;
  String *pname;
  SwigType *ptype;
  int ts = tm_scope;
  String *tm_methods, *multi_tmap_method;
  if (ParmList_len(parms) != ParmList_len(srcparms))
    return -1;

  tm_method = typemap_method_name(tmap_method);
  while (ts >= 0) {
    p = srcparms;
    tm_methods = NewString(tm_method);
    while (p) {
      ptype = Getattr(p, "type");
      pname = Getattr(p, "name");

      /* Lookup the type */
      tm = typemap_get(ptype, pname, ts);
      if (!tm)
	break;

      tm = Getattr(tm, tm_methods);
      if (!tm)
	break;

      /* Got a match.  Look for next typemap */
      multi_tmap_method = NewStringf("%s-%s+%s:", tm_methods, ptype, pname);
      Delete(tm_methods);
      tm_methods = multi_tmap_method;
      p = nextSibling(p);
    }
    Delete(tm_methods);

    if (!p && tm) {

      /* Got some kind of match */
      Swig_typemap_register(tmap_method, parms, Getattr(tm, "code"), Getattr(tm, "locals"), Getattr(tm, "kwargs"));
      return 0;
    }
    ts--;
  }
  /* Not found */
  return -1;

}

/* -----------------------------------------------------------------------------
 * Swig_typemap_clear()
 *
 * Delete a multi-argument typemap
 * ----------------------------------------------------------------------------- */

void Swig_typemap_clear(const_String_or_char_ptr tmap_method, ParmList *parms) {
  SwigType *type;
  String *name;
  Parm *p;
  String *multi_tmap_method;
  Hash *tm = 0;

  /* This might not work */
  multi_tmap_method = NewString(tmap_method);
  p = parms;
  while (p) {
    type = Getattr(p, "type");
    name = Getattr(p, "name");
    tm = typemap_get(type, name, tm_scope);
    if (!tm)
      return;
    p = nextSibling(p);
    if (p)
      Printf(multi_tmap_method, "-%s+%s:", type, name);
  }
  if (tm) {
    tm = Getattr(tm, typemap_method_name(multi_tmap_method));
    if (tm) {
      Delattr(tm, "code");
      Delattr(tm, "locals");
      Delattr(tm, "kwargs");
    }
  }
  Delete(multi_tmap_method);
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_apply()
 *
 * Multi-argument %apply directive.  This is pretty horrible so I sure hope
 * it works.
 * ----------------------------------------------------------------------------- */

static int count_args(String *s) {
  /* Count up number of arguments */
  int na = 0;
  char *c = Char(s);
  while (*c) {
    if (*c == '+')
      na++;
    c++;
  }
  return na;
}

int Swig_typemap_apply(ParmList *src, ParmList *dest) {
  String *ssig, *dsig;
  Parm *p, *np, *lastp, *dp, *lastdp = 0;
  int narg = 0;
  int ts = tm_scope;
  SwigType *type = 0, *name;
  Hash *tm, *sm;
  int match = 0;

  /*  Printf(stdout,"apply : %s --> %s\n", ParmList_str(src), ParmList_str(dest)); */

  /* Create type signature of source */
  ssig = NewStringEmpty();
  dsig = NewStringEmpty();
  p = src;
  dp = dest;
  lastp = 0;
  while (p) {
    lastp = p;
    lastdp = dp;
    np = nextSibling(p);
    if (np) {
      Printf(ssig, "-%s+%s:", Getattr(p, "type"), Getattr(p, "name"));
      Printf(dsig, "-%s+%s:", Getattr(dp, "type"), Getattr(dp, "name"));
      narg++;
    }
    p = np;
    dp = nextSibling(dp);
  }

  /* make sure a typemap node exists for the last destination node */
  type = Getattr(lastdp, "type");
  tm = get_typemap(tm_scope, type);
  if (!tm) {
    tm = NewHash();
    set_typemap(tm_scope, type, tm);
    Delete(tm);
  }
  name = Getattr(lastdp, "name");
  if (name) {
    Hash *tm1 = Getattr(tm, name);
    if (!tm1) {
      tm1 = NewHash();
      Setattr(tm, NewString(name), tm1);
      Delete(tm1);
    }
    tm = tm1;
  }

  /* This is a little nasty.  We need to go searching for all possible typemaps in the
     source and apply them to the target */

  type = Getattr(lastp, "type");
  name = Getattr(lastp, "name");

  while (ts >= 0) {

    /* See if there is a matching typemap in this scope */
    sm = typemap_get(type, name, ts);

    /* if there is not matching, look for a typemap in the
       original typedef, if any, like in:

       typedef unsigned long size_t;
       ...
       %apply(size_t) {my_size};  ==>  %apply(unsigned long) {my_size};
     */
    if (!sm) {
      SwigType *ntype = SwigType_typedef_resolve(type);
      if (ntype && (Cmp(ntype, type) != 0)) {
	sm = typemap_get(ntype, name, ts);
      }
      Delete(ntype);
    }

    if (sm) {
      /* Got a typemap.  Need to only merge attributes for methods that match our signature */
      Iterator ki;
      match = 1;
      for (ki = First(sm); ki.key; ki = Next(ki)) {
	/* Check for a signature match with the source signature */
	if ((count_args(ki.key) == narg) && (Strstr(ki.key, ssig))) {
	  String *oldm;
	  /* A typemap we have to copy */
	  String *nkey = Copy(ki.key);
	  Replace(nkey, ssig, dsig, DOH_REPLACE_ANY);

	  /* Make sure the typemap doesn't already exist in the target map */

	  oldm = Getattr(tm, nkey);
	  if (!oldm || (!Getattr(tm, "code"))) {
	    String *code;
	    ParmList *locals;
	    ParmList *kwargs;
	    Hash *sm1 = ki.item;

	    code = Getattr(sm1, "code");
	    locals = Getattr(sm1, "locals");
	    kwargs = Getattr(sm1, "kwargs");
	    if (code) {
	      Replace(nkey, dsig, "", DOH_REPLACE_ANY);
	      Replace(nkey, "tmap:", "", DOH_REPLACE_ANY);
	      Swig_typemap_register(nkey, dest, code, locals, kwargs);
	    }
	  }
	  Delete(nkey);
	}
      }
    }
    ts--;
  }
  Delete(ssig);
  Delete(dsig);
  return match;
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_clear_apply()
 *
 * %clear directive.   Clears all typemaps for a type (in the current scope only).    
 * ----------------------------------------------------------------------------- */

/* Multi-argument %clear directive */
void Swig_typemap_clear_apply(Parm *parms) {
  String *tsig;
  Parm *p, *np, *lastp;
  int narg = 0;
  Hash *tm;
  String *name;

  /* Create a type signature of the parameters */
  tsig = NewStringEmpty();
  p = parms;
  lastp = 0;
  while (p) {
    lastp = p;
    np = nextSibling(p);
    if (np) {
      Printf(tsig, "-%s+%s:", Getattr(p, "type"), Getattr(p, "name"));
      narg++;
    }
    p = np;
  }
  tm = get_typemap(tm_scope, Getattr(lastp, "type"));
  if (!tm) {
    Delete(tsig);
    return;
  }
  name = Getattr(lastp, "name");
  if (name) {
    tm = Getattr(tm, name);
  }
  if (tm) {
    /* Clear typemaps that match our signature */
    Iterator ki, ki2;
    char *ctsig = Char(tsig);
    for (ki = First(tm); ki.key; ki = Next(ki)) {
      char *ckey = Char(ki.key);
      if (strncmp(ckey, "tmap:", 5) == 0) {
	int na = count_args(ki.key);
	if ((na == narg) && strstr(ckey, ctsig)) {
	  Hash *h = ki.item;
	  for (ki2 = First(h); ki2.key; ki2 = Next(ki2)) {
	    Delattr(h, ki2.key);
	  }
	}
      }
    }
  }
  Delete(tsig);
}

/* Internal function to strip array dimensions. */
static SwigType *strip_arrays(SwigType *type) {
  SwigType *t;
  int ndim;
  int i;
  t = Copy(type);
  ndim = SwigType_array_ndim(t);
  for (i = 0; i < ndim; i++) {
    SwigType_array_setdim(t, i, "ANY");
  }
  return t;
}

static void debug_search_result_display(Node *tm) {
  if (tm)
    Printf(stdout, "  Using: %%%s\n", Getattr(tm, "typemap"));
  else
    Printf(stdout, "  None found\n");
}

/* -----------------------------------------------------------------------------
 * typemap_search()
 *
 * Search for a typemap match. This is where the typemap pattern matching rules 
 * are implemented... tries to find the most specific typemap that includes a 
 * 'code' attribute.
 * ----------------------------------------------------------------------------- */

static Hash *typemap_search(const_String_or_char_ptr tmap_method, SwigType *type, const_String_or_char_ptr name, const_String_or_char_ptr qualifiedname, SwigType **matchtype) {
  Hash *result = 0, *tm, *tm1, *tma;
  Hash *backup = 0;
  SwigType *noarrays = 0;
  SwigType *primitive = 0;
  SwigType *ctype = 0;
  int ts;
  int isarray;
  const String *cname = 0;
  const String *cqualifiedname = 0;
  SwigType *unstripped = 0;
  String *tm_method = typemap_method_name(tmap_method);
  int debug_display = (in_typemap_search_multi == 0) && typemap_search_debug;

  if ((name) && Len(name))
    cname = name;
  if ((qualifiedname) && Len(qualifiedname))
    cqualifiedname = qualifiedname;
  ts = tm_scope;

  if (debug_display) {
    String *empty_string = NewStringEmpty();
    String *typestr = SwigType_str(type, cqualifiedname ? cqualifiedname : (cname ? cname : empty_string));
    Printf(stdout, "---- Searching for a suitable '%s' typemap for: %s\n", tmap_method, typestr);
    Delete(typestr);
    Delete(empty_string);
  }
  while (ts >= 0) {
    ctype = type;
    while (ctype) {
      /* Try to get an exact type-match */
      tm = get_typemap(ts, ctype);
      if (debug_display && cqualifiedname)
	Printf(stdout, "  Looking for: %s\n", SwigType_str(ctype, cqualifiedname));
      if (tm && cqualifiedname) {
	tm1 = Getattr(tm, cqualifiedname);
	if (tm1) {
	  result = Getattr(tm1, tm_method);	/* See if there is a type - qualified name match */
	  if (result && Getattr(result, "code"))
	    goto ret_result;
	  if (result)
	    backup = result;
	}
      }
      if (debug_display && cname)
	Printf(stdout, "  Looking for: %s\n", SwigType_str(ctype, cname));
      if (tm && cname) {
	tm1 = Getattr(tm, cname);
	if (tm1) {
	  result = Getattr(tm1, tm_method);	/* See if there is a type - name match */
	  if (result && Getattr(result, "code"))
	    goto ret_result;
	  if (result)
	    backup = result;
	}
      }
      if (debug_display)
	Printf(stdout, "  Looking for: %s\n", SwigType_str(ctype, 0));
      if (tm) {
	result = Getattr(tm, tm_method);	/* See if there is simply a type match */
	if (result && Getattr(result, "code"))
	  goto ret_result;
	if (result)
	  backup = result;
      }
      isarray = SwigType_isarray(ctype);
      if (isarray) {
	/* If working with arrays, strip away all of the dimensions and replace with "ANY".
	   See if that generates a match */
	if (!noarrays) {
	  noarrays = strip_arrays(ctype);
	}
	tma = get_typemap(ts, noarrays);
	if (debug_display && cqualifiedname)
	  Printf(stdout, "  Looking for: %s\n", SwigType_str(noarrays, cqualifiedname));
	if (tma && cqualifiedname) {
	  tm1 = Getattr(tma, cqualifiedname);
	  if (tm1) {
	    result = Getattr(tm1, tm_method);	/* See if there is a type - qualified name match */
	    if (result && Getattr(result, "code"))
	      goto ret_result;
	    if (result)
	      backup = result;
	  }
	}
	if (debug_display && cname)
	  Printf(stdout, "  Looking for: %s\n", SwigType_str(noarrays, cname));
	if (tma && cname) {
	  tm1 = Getattr(tma, cname);
	  if (tm1) {
	    result = Getattr(tm1, tm_method);	/* See if there is a type - name match */
	    if (result && Getattr(result, "code"))
	      goto ret_result;
	    if (result)
	      backup = result;
	  }
	}
	if (debug_display)
	  Printf(stdout, "  Looking for: %s\n", SwigType_str(noarrays, 0));
	if (tma) {
	  result = Getattr(tma, tm_method);	/* See if there is a type match */
	  if (result && Getattr(result, "code"))
	    goto ret_result;
	  if (result)
	    backup = result;
	}
	Delete(noarrays);
	noarrays = 0;
      }

      /* No match so far.   If the type is unstripped, we'll strip its
         qualifiers and check.   Otherwise, we'll try to resolve a typedef */

      if (!unstripped) {
	unstripped = ctype;
	ctype = SwigType_strip_qualifiers(ctype);
	if (!Equal(ctype, unstripped))
	  continue;		/* Types are different */
	Delete(ctype);
	ctype = unstripped;
	unstripped = 0;
      }
      {
	String *octype;
	if (unstripped) {
	  Delete(ctype);
	  ctype = unstripped;
	  unstripped = 0;
	}
	octype = ctype;
	ctype = SwigType_typedef_resolve(ctype);
	if (octype != type)
	  Delete(octype);
      }
    }

    /* Hmmm. Well, no match seems to be found at all. See if there is some kind of default (SWIGTYPE) mapping */

    primitive = SwigType_default(type);
    while (primitive) {
      tm = get_typemap(ts, primitive);
      if (debug_display && cqualifiedname)
	Printf(stdout, "  Looking for: %s\n", SwigType_str(primitive, cqualifiedname));
      if (tm && cqualifiedname) {
	tm1 = Getattr(tm, cqualifiedname);
	if (tm1) {
	  result = Getattr(tm1, tm_method);	/* See if there is a type - qualified name match */
	  if (result)
	    goto ret_result;
	}
      }
      if (debug_display && cname)
	Printf(stdout, "  Looking for: %s\n", SwigType_str(primitive, cname));
      if (tm && cname) {
	tm1 = Getattr(tm, cname);
	if (tm1) {
	  result = Getattr(tm1, tm_method);	/* See if there is a type - name match */
	  if (result)
	    goto ret_result;
	}
      }
      if (debug_display)
	Printf(stdout, "  Looking for: %s\n", SwigType_str(primitive, 0));
      if (tm) {
	result = Getattr(tm, tm_method);	/* See if there is simply a type match */
	if (result)
	  goto ret_result;
      }
      {
	SwigType *nprim = SwigType_default(primitive);
	Delete(primitive);
	primitive = nprim;
      }
    }
    if (ctype != type) {
      Delete(ctype);
      ctype = 0;
    }
    ts--;			/* Hmmm. Nothing found in this scope.  Guess we'll go try another scope */
  }
  result = backup;

ret_result:
  if (noarrays)
    Delete(noarrays);
  if (primitive)
    Delete(primitive);
  if ((unstripped) && (unstripped != type))
    Delete(unstripped);
  if (matchtype) {
    *matchtype = Copy(ctype);
  }
  if (type != ctype)
    Delete(ctype);
  return result;
}


/* -----------------------------------------------------------------------------
 * typemap_search_multi()
 *
 * Search for a multi-argument typemap.
 * ----------------------------------------------------------------------------- */

static Hash *typemap_search_multi(const_String_or_char_ptr tmap_method, ParmList *parms, int *nmatch) {
  SwigType *type;
  SwigType *mtype = 0;
  String *name;
  String *multi_tmap_method;
  Hash *tm;
  Hash *tm1 = 0;

  if (!parms) {
    *nmatch = 0;
    return 0;
  }
  type = Getattr(parms, "type");
  name = Getattr(parms, "name");

  /* Try to find a match on the first type */
  tm = typemap_search(tmap_method, type, name, 0, &mtype);
  if (tm) {
    if (mtype && SwigType_isarray(mtype)) {
      Setattr(parms, "tmap:match", mtype);
    }
    Delete(mtype);
    multi_tmap_method = NewStringf("%s-%s+%s:", tmap_method, type, name);
    in_typemap_search_multi++;
    tm1 = typemap_search_multi(multi_tmap_method, nextSibling(parms), nmatch);
    in_typemap_search_multi--;
    if (tm1)
      tm = tm1;
    if (Getattr(tm, "code")) {
      *(nmatch) = *nmatch + 1;
      if (typemap_search_debug && tm1 && (in_typemap_search_multi == 0)) {
	Printf(stdout, "  Multi-argument typemap found...\n");
      }
    } else {
      tm = 0;
    }
    Delete(multi_tmap_method);
  }

  if (typemap_search_debug && (in_typemap_search_multi == 0))
    debug_search_result_display(tm);

  return tm;
}


/* -----------------------------------------------------------------------------
 * typemap_replace_vars()
 *
 * Replaces typemap variables on a string.  index is the $n variable.
 * type and pname are the type and parameter name.
 * ----------------------------------------------------------------------------- */

static void replace_local_types(ParmList *p, const String *name, const String *rep) {
  SwigType *t;
  while (p) {
    t = Getattr(p, "type");
    Replace(t, name, rep, DOH_REPLACE_ANY);
    p = nextSibling(p);
  }
}

static int check_locals(ParmList *p, const char *s) {
  while (p) {
    char *c = GetChar(p, "type");
    if (strstr(c, s))
      return 1;
    p = nextSibling(p);
  }
  return 0;
}

static int typemap_replace_vars(String *s, ParmList *locals, SwigType *type, SwigType *rtype, String *pname, String *lname, int index) {
  char var[512];
  char *varname;
  SwigType *ftype;
  int bare_substitution_count = 0;

  Replaceall(s, "$typemap", "$TYPEMAP"); /* workaround for $type substitution below */

  ftype = SwigType_typedef_resolve_all(type);

  if (!pname)
    pname = lname;
  {
    Parm *p;
    int rep = 0;
    p = locals;
    while (p) {
      if (Strchr(Getattr(p, "type"), '$'))
	rep = 1;
      p = nextSibling(p);
    }
    if (!rep)
      locals = 0;
  }

  sprintf(var, "$%d_", index);
  varname = &var[strlen(var)];

  /* If the original datatype was an array. We're going to go through and substitute
     its array dimensions */

  if (SwigType_isarray(type) || SwigType_isarray(ftype)) {
    String *size;
    int ndim;
    int i;
    if (SwigType_array_ndim(type) != SwigType_array_ndim(ftype))
      type = ftype;
    ndim = SwigType_array_ndim(type);
    size = NewStringEmpty();
    for (i = 0; i < ndim; i++) {
      String *dim = SwigType_array_getdim(type, i);
      if (index == 1) {
	char t[32];
	sprintf(t, "$dim%d", i);
	Replace(s, t, dim, DOH_REPLACE_ANY);
	replace_local_types(locals, t, dim);
      }
      sprintf(varname, "dim%d", i);
      Replace(s, var, dim, DOH_REPLACE_ANY);
      replace_local_types(locals, var, dim);
      if (Len(size))
	Putc('*', size);
      Append(size, dim);
      Delete(dim);
    }
    sprintf(varname, "size");
    Replace(s, var, size, DOH_REPLACE_ANY);
    replace_local_types(locals, var, size);
    Delete(size);
  }

  /* Parameter name substitution */
  if (index == 1) {
    Replace(s, "$parmname", pname, DOH_REPLACE_ANY);
  }
  strcpy(varname, "name");
  Replace(s, var, pname, DOH_REPLACE_ANY);

  /* Type-related stuff */
  {
    SwigType *star_type, *amp_type, *base_type, *lex_type;
    SwigType *ltype, *star_ltype, *amp_ltype;
    String *mangle, *star_mangle, *amp_mangle, *base_mangle, *base_name;
    String *descriptor, *star_descriptor, *amp_descriptor;
    String *ts;
    char *sc;

    sc = Char(s);

    if (strstr(sc, "type") || check_locals(locals, "type")) {
      /* Given type : $type */
      ts = SwigType_str(type, 0);
      if (index == 1) {
	Replace(s, "$type", ts, DOH_REPLACE_ANY);
	replace_local_types(locals, "$type", type);
      }
      strcpy(varname, "type");
      Replace(s, var, ts, DOH_REPLACE_ANY);
      replace_local_types(locals, var, type);
      Delete(ts);
      sc = Char(s);
    }
    if (strstr(sc, "ltype") || check_locals(locals, "ltype")) {
      /* Local type:  $ltype */
      ltype = SwigType_ltype(type);
      ts = SwigType_str(ltype, 0);
      if (index == 1) {
	Replace(s, "$ltype", ts, DOH_REPLACE_ANY);
	replace_local_types(locals, "$ltype", ltype);
      }
      strcpy(varname, "ltype");
      Replace(s, var, ts, DOH_REPLACE_ANY);
      replace_local_types(locals, var, ltype);
      Delete(ts);
      Delete(ltype);
      sc = Char(s);
    }
    if (strstr(sc, "mangle") || strstr(sc, "descriptor")) {
      /* Mangled type */

      mangle = SwigType_manglestr(type);
      if (index == 1)
	Replace(s, "$mangle", mangle, DOH_REPLACE_ANY);
      strcpy(varname, "mangle");
      Replace(s, var, mangle, DOH_REPLACE_ANY);

      descriptor = NewStringf("SWIGTYPE%s", mangle);

      if (index == 1)
	if (Replace(s, "$descriptor", descriptor, DOH_REPLACE_ANY))
	  SwigType_remember(type);

      strcpy(varname, "descriptor");
      if (Replace(s, var, descriptor, DOH_REPLACE_ANY))
	SwigType_remember(type);

      Delete(descriptor);
      Delete(mangle);
    }

    /* One pointer level removed */
    /* This creates variables of the form
       $*n_type
       $*n_ltype
     */

    if (SwigType_ispointer(ftype) || (SwigType_isarray(ftype)) || (SwigType_isreference(ftype))) {
      if (!(SwigType_isarray(type) || SwigType_ispointer(type) || SwigType_isreference(type))) {
	star_type = Copy(ftype);
      } else {
	star_type = Copy(type);
      }
      if (!SwigType_isreference(star_type)) {
	if (SwigType_isarray(star_type)) {
	  SwigType_del_element(star_type);
	} else {
	  SwigType_del_pointer(star_type);
	}
	ts = SwigType_str(star_type, 0);
	if (index == 1) {
	  Replace(s, "$*type", ts, DOH_REPLACE_ANY);
	  replace_local_types(locals, "$*type", star_type);
	}
	sprintf(varname, "$*%d_type", index);
	Replace(s, varname, ts, DOH_REPLACE_ANY);
	replace_local_types(locals, varname, star_type);
	Delete(ts);
      } else {
	SwigType_del_element(star_type);
      }
      star_ltype = SwigType_ltype(star_type);
      ts = SwigType_str(star_ltype, 0);
      if (index == 1) {
	Replace(s, "$*ltype", ts, DOH_REPLACE_ANY);
	replace_local_types(locals, "$*ltype", star_ltype);
      }
      sprintf(varname, "$*%d_ltype", index);
      Replace(s, varname, ts, DOH_REPLACE_ANY);
      replace_local_types(locals, varname, star_ltype);
      Delete(ts);
      Delete(star_ltype);

      star_mangle = SwigType_manglestr(star_type);
      if (index == 1)
	Replace(s, "$*mangle", star_mangle, DOH_REPLACE_ANY);

      sprintf(varname, "$*%d_mangle", index);
      Replace(s, varname, star_mangle, DOH_REPLACE_ANY);

      star_descriptor = NewStringf("SWIGTYPE%s", star_mangle);
      if (index == 1)
	if (Replace(s, "$*descriptor", star_descriptor, DOH_REPLACE_ANY))
	  SwigType_remember(star_type);
      sprintf(varname, "$*%d_descriptor", index);
      if (Replace(s, varname, star_descriptor, DOH_REPLACE_ANY))
	SwigType_remember(star_type);

      Delete(star_descriptor);
      Delete(star_mangle);
      Delete(star_type);
    } else {
      /* TODO: Signal error if one of the $* substitutions is
         requested */
    }
    /* One pointer level added */
    amp_type = Copy(type);
    SwigType_add_pointer(amp_type);
    ts = SwigType_str(amp_type, 0);
    if (index == 1) {
      Replace(s, "$&type", ts, DOH_REPLACE_ANY);
      replace_local_types(locals, "$&type", amp_type);
    }
    sprintf(varname, "$&%d_type", index);
    Replace(s, varname, ts, DOH_REPLACE_ANY);
    replace_local_types(locals, varname, amp_type);
    Delete(ts);

    amp_ltype = SwigType_ltype(type);
    SwigType_add_pointer(amp_ltype);
    ts = SwigType_str(amp_ltype, 0);

    if (index == 1) {
      Replace(s, "$&ltype", ts, DOH_REPLACE_ANY);
      replace_local_types(locals, "$&ltype", amp_ltype);
    }
    sprintf(varname, "$&%d_ltype", index);
    Replace(s, varname, ts, DOH_REPLACE_ANY);
    replace_local_types(locals, varname, amp_ltype);
    Delete(ts);
    Delete(amp_ltype);

    amp_mangle = SwigType_manglestr(amp_type);
    if (index == 1)
      Replace(s, "$&mangle", amp_mangle, DOH_REPLACE_ANY);
    sprintf(varname, "$&%d_mangle", index);
    Replace(s, varname, amp_mangle, DOH_REPLACE_ANY);

    amp_descriptor = NewStringf("SWIGTYPE%s", amp_mangle);
    if (index == 1)
      if (Replace(s, "$&descriptor", amp_descriptor, DOH_REPLACE_ANY))
	SwigType_remember(amp_type);
    sprintf(varname, "$&%d_descriptor", index);
    if (Replace(s, varname, amp_descriptor, DOH_REPLACE_ANY))
      SwigType_remember(amp_type);

    Delete(amp_descriptor);
    Delete(amp_mangle);
    Delete(amp_type);

    /* Base type */
    if (SwigType_isarray(type)) {
      SwigType *bt = Copy(type);
      Delete(SwigType_pop_arrays(bt));
      base_type = SwigType_str(bt, 0);
      Delete(bt);
    } else {
      base_type = SwigType_base(type);
    }

    base_name = SwigType_namestr(base_type);
    if (index == 1) {
      Replace(s, "$basetype", base_name, DOH_REPLACE_ANY);
      replace_local_types(locals, "$basetype", base_name);
    }
    strcpy(varname, "basetype");
    Replace(s, var, base_type, DOH_REPLACE_ANY);
    replace_local_types(locals, var, base_name);

    base_mangle = SwigType_manglestr(base_type);
    if (index == 1)
      Replace(s, "$basemangle", base_mangle, DOH_REPLACE_ANY);
    strcpy(varname, "basemangle");
    Replace(s, var, base_mangle, DOH_REPLACE_ANY);
    Delete(base_mangle);
    Delete(base_type);
    Delete(base_name);

    lex_type = SwigType_base(rtype);
    if (index == 1)
      Replace(s, "$lextype", lex_type, DOH_REPLACE_ANY);
    strcpy(varname, "lextype");
    Replace(s, var, lex_type, DOH_REPLACE_ANY);
    Delete(lex_type);
  }

  /* Replace any $n. with (&n)-> */
  {
    char temp[64];
    sprintf(var, "$%d.", index);
    sprintf(temp, "(&$%d)->", index);
    Replace(s, var, temp, DOH_REPLACE_ANY);
  }

  /* Replace the bare $n variable */
  sprintf(var, "$%d", index);
  bare_substitution_count = Replace(s, var, lname, DOH_REPLACE_ANY);
  Delete(ftype);
  return bare_substitution_count;
}

/* ------------------------------------------------------------------------
 * static typemap_locals()
 *
 * Takes a string, a parameter list and a wrapper function argument and
 * creates the local variables.
 * ------------------------------------------------------------------------ */

static void typemap_locals(DOHString * s, ParmList *l, Wrapper *f, int argnum) {
  Parm *p;
  char *new_name;

  p = l;
  while (p) {
    SwigType *pt = Getattr(p, "type");
    SwigType *at = SwigType_alttype(pt, 1);
    String *pn = Getattr(p, "name");
    String *value = Getattr(p, "value");
    if (at)
      pt = at;
    if (pn) {
      if (Len(pn) > 0) {
	String *str;
	int isglobal = 0;

	str = NewStringEmpty();

	if (strncmp(Char(pn), "_global_", 8) == 0) {
	  isglobal = 1;
	}

	/* If the user gave us $type as the name of the local variable, we'll use
	   the passed datatype instead */

	if ((argnum >= 0) && (!isglobal)) {
	  Printf(str, "%s%d", pn, argnum);
	} else {
	  Append(str, pn);
	}
	if (isglobal && Wrapper_check_local(f, str)) {
	  p = nextSibling(p);
	  Delete(str);
	  if (at)
	    Delete(at);
	  continue;
	}
	if (value) {
	  String *pstr = SwigType_str(pt, str);
	  new_name = Wrapper_new_localv(f, str, pstr, "=", value, NIL);
	  Delete(pstr);
	} else {
	  String *pstr = SwigType_str(pt, str);
	  new_name = Wrapper_new_localv(f, str, pstr, NIL);
	  Delete(pstr);
	}
	if (!isglobal) {
	  /* Substitute  */
	  Replace(s, pn, new_name, DOH_REPLACE_ID | DOH_REPLACE_NOQUOTE);
	}
	Delete(str);
      }
    }
    p = nextSibling(p);
    if (at)
      Delete(at);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_lookup()
 *
 * Attach one or more typemaps to a node and optionally generate the typemap contents
 * into the wrapper.
 *
 * Looks for a typemap matching the given type and name and attaches the typemap code
 * and any typemap attributes to the provided node.
 *
 * The node should contain the "type" and "name" attributes for the typemap match on.
 * input. The typemap code and typemap attribute values are attached onto the node
 * prefixed with "tmap:". For example with tmap_method="in", the typemap code can be retrieved 
 * with a call to Getattr(node, "tmap:in") (this is also the string returned) and the 
 * "noblock" attribute can be retrieved with a call to Getattr(node, "tmap:in:noblock").
 *
 * tmap_method - typemap method, eg "in", "out", "newfree"
 * node        - the node to attach the typemap and typemap attributes to
 * lname       - name of variable to substitute $1, $2 etc for
 * f           - wrapper code to generate into if non null
 * actioncode  - code to generate into f before the out typemap code, unless
 *              the optimal attribute is set in the out typemap in which case
 *              $1 in the out typemap will be replaced  by the code in actioncode.
 * ----------------------------------------------------------------------------- */

static String *Swig_typemap_lookup_impl(const_String_or_char_ptr tmap_method, Node *node, const_String_or_char_ptr lname, Wrapper *f, String *actioncode) {
  SwigType *type;
  SwigType *mtype = 0;
  String *pname;
  String *qpname = 0;
  Hash *tm = 0;
  String *s = 0;
  String *sdef = 0;
  ParmList *locals;
  ParmList *kw;
  char temp[256];
  String *symname;
  String *cname = 0;
  String *clname = 0;
  char *cmethod = Char(tmap_method);
  int optimal_attribute = 0;
  int optimal_substitution = 0;
  int num_substitutions = 0;

  /* special case, we need to check for 'ref' call and set the default code 'sdef' */
  if (node && Cmp(tmap_method, "newfree") == 0) {
    sdef = Swig_ref_call(node, lname);
  }

  type = Getattr(node, "type");
  if (!type)
    return sdef;

  pname = Getattr(node, "name");

  if (pname && node && checkAttribute(node, "kind", "function")) {
    /* 
       For functions, add on a qualified name search, for example
       struct Foo {
         int *foo(int bar)   ->  Foo::foo
       };
     */
    Symtab *st = Getattr(node, "sym:symtab");
    String *qsn = st ? Swig_symbol_string_qualify(pname, st) : 0;
    if (qsn && Len(qsn) && !Equal(qsn, pname))
      qpname = qsn;
  }

  tm = typemap_search(tmap_method, type, pname, qpname, &mtype);
  if (typemap_search_debug)
    debug_search_result_display(tm);

  Delete(qpname);
  qpname = 0;

  if (!tm)
    return sdef;

  s = Getattr(tm, "code");
  if (!s)
    return sdef;

  /* Empty typemap. No match */
  if (Cmp(s, "pass") == 0)
    return sdef;

  s = Copy(s);			/* Make a local copy of the typemap code */

  /* Attach kwargs - ie the typemap attributes */
  kw = Getattr(tm, "kwargs");
  while (kw) {
    String *value = Copy(Getattr(kw, "value"));
    String *kwtype = Getattr(kw, "type");
    char *ckwname = Char(Getattr(kw, "name"));
    if (kwtype) {
      String *mangle = Swig_string_mangle(kwtype);
      Append(value, mangle);
      Delete(mangle);
    }
    sprintf(temp, "%s:%s", cmethod, ckwname);
    Setattr(node, typemap_method_name(temp), value);
    if (Cmp(temp, "out:optimal") == 0)
      optimal_attribute = (Cmp(value, "0") != 0) ? 1 : 0;
    Delete(value);
    kw = nextSibling(kw);
  }
  
  if (optimal_attribute) {
    /* Note: "out" typemap is the only typemap that will have the "optimal" attribute set.
     * If f and actioncode are NULL, then the caller is just looking to attach the "out" attributes
     * ie, not use the typemap code, otherwise both f and actioncode must be non null. */
    if (actioncode) {
      clname = Copy(actioncode);
      /* check that the code in the typemap can be used in this optimal way.
       * The code should be in the form "result = ...;\n". We need to extract
       * the "..." part. This may not be possible for various reasons, eg
       * code added by %exception. This optimal code generation is bit of a
       * hack and circumvents the normal requirement for a temporary variable 
       * to hold the result returned from a wrapped function call.
       */
      if (Strncmp(clname, "result = ", 9) == 0) {
        int numreplacements = Replace(clname, "result = ", "", DOH_REPLACE_ID_BEGIN);
        if (numreplacements == 1) {
          numreplacements = Replace(clname, ";\n", "", DOH_REPLACE_ID_END);
          if (numreplacements == 1) {
            if (Strchr(clname, ';') == 0) {
              lname = clname;
              actioncode = 0;
              optimal_substitution = 1;
            }
          }
        }
      }
      if (!optimal_substitution) {
        Swig_warning(WARN_TYPEMAP_OUT_OPTIMAL_IGNORED, Getfile(node), Getline(node), "Method %s usage of the optimal attribute in the out typemap at %s:%d ignored as the following cannot be used to generate optimal code: %s\n", Swig_name_decl(node), Getfile(s), Getline(s), clname);
        Delattr(node, "tmap:out:optimal");
      }
    } else {
      assert(!f);
    }
  }
  if (actioncode) {
    assert(f);
    Append(f->code, actioncode);
  }

  /* emit local variables declared in typemap, eg emit declarations for aa and bb in:
   * %typemap(in) foo (int aa, int bb) "..." */
  locals = Getattr(tm, "locals");
  if (locals)
    locals = CopyParmList(locals);

  if (pname) {
    if (SwigType_istemplate(pname)) {
      cname = SwigType_namestr(pname);
      pname = cname;
    }
  }
  if (SwigType_istemplate((char *) lname)) {
    clname = SwigType_namestr((char *) lname);
    lname = clname;
  }

  if (mtype && SwigType_isarray(mtype)) {
    num_substitutions = typemap_replace_vars(s, locals, mtype, type, pname, (char *) lname, 1);
  } else {
    num_substitutions = typemap_replace_vars(s, locals, type, type, pname, (char *) lname, 1);
  }
  if (optimal_substitution && num_substitutions > 1)
    Swig_warning(WARN_TYPEMAP_OUT_OPTIMAL_MULTIPLE, Getfile(node), Getline(node), "Multiple calls to %s might be generated due to optimal attribute usage in the out typemap at %s:%d.\n", Swig_name_decl(node), Getfile(s), Getline(s));

  if (locals && f) {
    typemap_locals(s, locals, f, -1);
  }

  {
    ParmList *parm_sublist = NewParm(type, pname);
    Setattr(parm_sublist, "lname", lname);
    replace_embedded_typemap(s, parm_sublist, f);
    Delete(parm_sublist);
  }

  Replace(s, "$name", pname, DOH_REPLACE_ANY);

  symname = Getattr(node, "sym:name");
  if (symname) {
    Replace(s, "$symname", symname, DOH_REPLACE_ANY);
  }

  Setattr(node, typemap_method_name(tmap_method), s);
  if (locals) {
    sprintf(temp, "%s:locals", cmethod);
    Setattr(node, typemap_method_name(temp), locals);
    Delete(locals);
  }

  if (Checkattr(tm, "type", "SWIGTYPE")) {
    sprintf(temp, "%s:SWIGTYPE", cmethod);
    Setattr(node, typemap_method_name(temp), "1");
  }

  /* Look for warnings */
  {
    String *w;
    sprintf(temp, "%s:warning", cmethod);
    w = Getattr(node, typemap_method_name(temp));
    if (w) {
      Swig_warning(0, Getfile(node), Getline(node), "%s\n", w);
    }
  }

  /* Look for code fragments */
  {
    String *fragment;
    sprintf(temp, "%s:fragment", cmethod);
    fragment = Getattr(node, typemap_method_name(temp));
    if (fragment) {
      String *fname = Copy(fragment);
      Setfile(fname, Getfile(node));
      Setline(fname, Getline(node));
      Swig_fragment_emit(fname);
      Delete(fname);
    }
  }

  Delete(cname);
  Delete(clname);
  Delete(mtype);
  if (sdef) {			/* put 'ref' and 'newfree' codes together */
    String *p = NewStringf("%s\n%s", sdef, s);
    Delete(s);
    Delete(sdef);
    s = p;
  }
  Delete(actioncode);
  return s;
}

String *Swig_typemap_lookup_out(const_String_or_char_ptr tmap_method, Node *node, const_String_or_char_ptr lname, Wrapper *f, String *actioncode) {
  assert(actioncode);
  assert(Cmp(tmap_method, "out") == 0);
  return Swig_typemap_lookup_impl(tmap_method, node, lname, f, actioncode);
}

String *Swig_typemap_lookup(const_String_or_char_ptr tmap_method, Node *node, const_String_or_char_ptr lname, Wrapper *f) {
  return Swig_typemap_lookup_impl(tmap_method, node, lname, f, 0);
}

/* -----------------------------------------------------------------------------
 * typemap_attach_kwargs()
 *
 * If this hash (tm) contains a linked list of parameters under its "kwargs"
 * attribute, add keys for each of those named keyword arguments to this
 * parameter for later use.
 * For example, attach the typemap attributes to p:
 * %typemap(in, foo="xyz") ...
 * A new attribute called "tmap:in:foo" with value "xyz" is attached to p.
 * ----------------------------------------------------------------------------- */

static void typemap_attach_kwargs(Hash *tm, const_String_or_char_ptr tmap_method, Parm *p) {
  String *temp = NewStringEmpty();
  Parm *kw = Getattr(tm, "kwargs");
  while (kw) {
    String *value = Copy(Getattr(kw, "value"));
    String *type = Getattr(kw, "type");
    if (type) {
      Hash *v = NewHash();
      Setattr(v, "type", type);
      Setattr(v, "value", value);
      Delete(value);
      value = v;
    }
    Clear(temp);
    Printf(temp, "%s:%s", tmap_method, Getattr(kw, "name"));
    Setattr(p, typemap_method_name(temp), value);
    Delete(value);
    kw = nextSibling(kw);
  }
  Clear(temp);
  Printf(temp, "%s:match_type", tmap_method);
  Setattr(p, typemap_method_name(temp), Getattr(tm, "type"));
  Delete(temp);
}

/* -----------------------------------------------------------------------------
 * typemap_warn()
 *
 * If any warning message is attached to this parameter's "tmap:<method>:warning"
 * attribute, print that warning message.
 * ----------------------------------------------------------------------------- */

static void typemap_warn(const_String_or_char_ptr tmap_method, Parm *p) {
  String *temp = NewStringf("%s:warning", tmap_method);
  String *w = Getattr(p, typemap_method_name(temp));
  Delete(temp);
  if (w) {
    Swig_warning(0, Getfile(p), Getline(p), "%s\n", w);
  }
}

static void typemap_emit_code_fragments(const_String_or_char_ptr tmap_method, Parm *p) {
  String *temp = NewStringf("%s:fragment", tmap_method);
  String *f = Getattr(p, typemap_method_name(temp));
  if (f) {
    String *fname = Copy(f);
    Setfile(fname, Getfile(p));
    Setline(fname, Getline(p));
    Swig_fragment_emit(fname);
    Delete(fname);
  }
  Delete(temp);
}

static String *typemap_get_option(Hash *tm, const_String_or_char_ptr name) {
  Parm *kw = Getattr(tm, "kwargs");
  while (kw) {
    String *kname = Getattr(kw, "name");
    if (Equal(kname, name)) {
      return Getattr(kw, "value");
    }
    kw = nextSibling(kw);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_attach_parms()
 *
 * Given a parameter list, this function attaches all of the typemaps and typemap
 * attributes to the parameter for each type in the parameter list. 
 *
 * This function basically provides the typemap code and typemap attribute values as
 * attributes on each parameter prefixed with "tmap:". For example with tmap_method="in", the typemap
 * code can be retrieved for the first parameter with a call to Getattr(parm, "tmap:in")
 * and the "numinputs" attribute can be retrieved with a call to Getattr(parm, "tmap:in:numinputs").
 *
 * tmap_method - typemap method, eg "in", "out", "newfree"
 * parms       - parameter list to attach each typemap and all typemap attributes
 * f           - wrapper code to generate into if non null
 * ----------------------------------------------------------------------------- */

void Swig_typemap_attach_parms(const_String_or_char_ptr tmap_method, ParmList *parms, Wrapper *f) {
  Parm *p, *firstp;
  Hash *tm;
  int nmatch = 0;
  int i;
  String *s;
  ParmList *locals;
  int argnum = 0;
  char temp[256];
  char *cmethod = Char(tmap_method);
  String *kwmatch = 0;
  p = parms;

#ifdef SWIG_DEBUG
  Printf(stdout, "Swig_typemap_attach_parms:  %s\n", tmap_method);
#endif

  while (p) {
    argnum++;
    nmatch = 0;
#ifdef SWIG_DEBUG
    Printf(stdout, "parms:  %s %s %s\n", tmap_method, Getattr(p, "name"), Getattr(p, "type"));
#endif
    tm = typemap_search_multi(tmap_method, p, &nmatch);
#ifdef SWIG_DEBUG
    if (tm)
      Printf(stdout, "found:  %s\n", tm);
#endif
    if (!tm) {
      p = nextSibling(p);
      continue;
    }
    /*
       Check if the typemap requires to match the type of another
       typemap, for example:

       %typemap(in) SWIGTYPE * (int var) {...}
       %typemap(freearg,match="in") SWIGTYPE * {if (var$argnum) ...}

       here, the freearg typemap requires the "in" typemap to match,
       or the 'var$argnum' variable will not exist.
     */
    kwmatch = typemap_get_option(tm, "match");
    if (kwmatch) {
      String *tmname = NewStringf("tmap:%s", kwmatch);
      String *tmin = Getattr(p, tmname);
      Delete(tmname);
#ifdef SWIG_DEBUG
      if (tm)
	Printf(stdout, "matching:  %s\n", kwmatch);
#endif
      if (tmin) {
	String *tmninp = NewStringf("tmap:%s:numinputs", kwmatch);
	String *ninp = Getattr(p, tmninp);
	Delete(tmninp);
	if (ninp && Equal(ninp, "0")) {
	  p = nextSibling(p);
	  continue;
	} else {
	  SwigType *typetm = Getattr(tm, "type");
	  String *temp = NewStringf("tmap:%s:match_type", kwmatch);
	  SwigType *typein = Getattr(p, temp);
	  Delete(temp);
	  if (!Equal(typein, typetm)) {
	    p = nextSibling(p);
	    continue;
	  } else {
	    int nnmatch;
	    Hash *tmapin = typemap_search_multi(kwmatch, p, &nnmatch);
	    String *tmname = Getattr(tm, "pname");
	    String *tnname = Getattr(tmapin, "pname");
	    if (!(tmname && tnname && Equal(tmname, tnname)) && !(!tmname && !tnname)) {
	      p = nextSibling(p);
	      continue;
	    }
	  }

	}
      } else {
	p = nextSibling(p);
	continue;
      }
    }

    s = Getattr(tm, "code");
    if (!s) {
      p = nextSibling(p);
      continue;
    }
#ifdef SWIG_DEBUG
    if (s)
      Printf(stdout, "code:  %s\n", s);
#endif

    /* Empty typemap. No match */
    if (Cmp(s, "pass") == 0) {
      p = nextSibling(p);
      continue;
    }

    s = Copy(s);
    locals = Getattr(tm, "locals");
    if (locals)
      locals = CopyParmList(locals);
    firstp = p;
#ifdef SWIG_DEBUG
    Printf(stdout, "nmatch:  %d\n", nmatch);
#endif
    for (i = 0; i < nmatch; i++) {
      SwigType *type;
      String *pname;
      String *lname;
      SwigType *mtype;


      type = Getattr(p, "type");
      pname = Getattr(p, "name");
      lname = Getattr(p, "lname");
      mtype = Getattr(p, "tmap:match");

      if (mtype) {
	typemap_replace_vars(s, locals, mtype, type, pname, lname, i + 1);
	Delattr(p, "tmap:match");
      } else {
	typemap_replace_vars(s, locals, type, type, pname, lname, i + 1);
      }

      if (Checkattr(tm, "type", "SWIGTYPE")) {
	sprintf(temp, "%s:SWIGTYPE", cmethod);
	Setattr(p, typemap_method_name(temp), "1");
      }
      p = nextSibling(p);
    }

    if (locals && f) {
      typemap_locals(s, locals, f, argnum);
    }

    replace_embedded_typemap(s, firstp, f);

    /* Replace the argument number */
    sprintf(temp, "%d", argnum);
    Replace(s, "$argnum", temp, DOH_REPLACE_ANY);

    /* Attach attributes to object */
#ifdef SWIG_DEBUG
    Printf(stdout, "attach: %s %s %s\n", Getattr(firstp, "name"), typemap_method_name(tmap_method), s);
#endif
    Setattr(firstp, typemap_method_name(tmap_method), s);	/* Code object */

    if (locals) {
      sprintf(temp, "%s:locals", cmethod);
      Setattr(firstp, typemap_method_name(temp), locals);
      Delete(locals);
    }

    /* Attach a link to the next parameter.  Needed for multimaps */
    sprintf(temp, "%s:next", cmethod);
    Setattr(firstp, typemap_method_name(temp), p);

    /* Attach kwargs */
    typemap_attach_kwargs(tm, tmap_method, firstp);

    /* Print warnings, if any */
    typemap_warn(tmap_method, firstp);

    /* Look for code fragments */
    typemap_emit_code_fragments(tmap_method, firstp);

    /* increase argnum to consider numinputs */
    argnum += nmatch - 1;
    Delete(s);
#ifdef SWIG_DEBUG
    Printf(stdout, "res: %s %s %s\n", Getattr(firstp, "name"), typemap_method_name(tmap_method), Getattr(firstp, typemap_method_name(tmap_method)));
#endif

  }
#ifdef SWIG_DEBUG
  Printf(stdout, "Swig_typemap_attach_parms: end\n");
#endif

}

/* Splits the arguments of an embedded typemap */
static List *split_embedded_typemap(String *s) {
  List *args = 0;
  char *c, *start;
  int level = 0;
  int angle_level = 0;
  int leading = 1;

  args = NewList();
  c = strchr(Char(s), '(');
  assert(c);
  c++;

  start = c;
  while (*c) {
    if (*c == '\"') {
      c++;
      while (*c) {
	if (*c == '\\') {
	  c++;
	} else {
	  if (*c == '\"')
	    break;
	}
	c++;
      }
    }
    if ((level == 0) && angle_level == 0 && ((*c == ',') || (*c == ')'))) {
      String *tmp = NewStringWithSize(start, c - start);
      Append(args, tmp);
      Delete(tmp);
      start = c + 1;
      leading = 1;
      if (*c == ')')
	break;
      c++;
      continue;
    }
    if (*c == '(')
      level++;
    if (*c == ')')
      level--;
    if (*c == '<')
      angle_level++;
    if (*c == '>')
      angle_level--;
    if (isspace((int) *c) && leading)
      start++;
    if (!isspace((int) *c))
      leading = 0;
    c++;
  }
  return args;
}

/* -----------------------------------------------------------------------------
 * replace_embedded_typemap()
 *
 * This function replaces the special variable macro $typemap(...) with typemap
 * code. The general form of $typemap is as follows:
 *
 *   $typemap(method, typelist, var1=value, var2=value, ...)
 *
 * where varx parameters are optional and undocumented; they were used in an earlier version of $typemap.
 * A search is made using the typemap matching rules of form:
 *
 *   %typemap(method) typelist {...}
 *
 * and if found will substitute in the typemap contents, making appropriate variable replacements.
 *
 * For example:
 *   $typemap(in, int)			     # simple usage matching %typemap(in) int { ... }
 *   $typemap(in, int b)		     # simple usage matching %typemap(in) int b { ... } or above %typemap
 *   $typemap(in, (Foo<int, bool> a, int b)) # multi-argument typemap matching %typemap(in) (Foo<int, bool> a, int b) {...}
 * ----------------------------------------------------------------------------- */

static void replace_embedded_typemap(String *s, ParmList *parm_sublist, Wrapper *f) {
  char *start = 0;
  while ((start = strstr(Char(s), "$TYPEMAP("))) { /* note $typemap capitalisation to $TYPEMAP hack */

    /* Gather the parameters */
    char *end = 0, *c;
    int level = 0;
    String *dollar_typemap;
    int syntax_error = 1;
    c = start;
    while (*c) {
      if (*c == '(')
	level++;
      if (*c == ')') {
	level--;
	if (level == 0) {
	  end = c + 1;
	  break;
	}
      }
      c++;
    }
    if (end) {
      dollar_typemap = NewStringWithSize(start, (end - start));
      syntax_error = 0;
    } else {
      dollar_typemap = NewStringWithSize(start, (c - start));
    }

    if (!syntax_error) {
      List *l;
      String *tmap_method;
      Hash *vars;
      syntax_error = 1;

      /* Split apart each parameter in $typemap(...) */
      l = split_embedded_typemap(dollar_typemap);

      if (Len(l) >= 2) {
	ParmList *to_match_parms;
	tmap_method = Getitem(l, 0);

	/* the second parameter might contain multiple sub-parameters for multi-argument 
	 * typemap matching, so split these parameters apart */
	to_match_parms = Swig_cparse_parms(Getitem(l, 1));
	if (to_match_parms) {
	  Parm *p = to_match_parms;
	  Parm *sub_p = parm_sublist;
	  String *empty_string = NewStringEmpty(); 
	  String *lname = empty_string;
	  while (p) {
	    if (sub_p) {
	      lname = Getattr(sub_p, "lname");
	      sub_p = nextSibling(sub_p);
	    }
	    Setattr(p, "lname", lname);
	    p = nextSibling(p);
	  }
	  Delete(empty_string);
	}

	/* process optional extra parameters - the variable replacements (undocumented) */
	vars = NewHash();
	{
	  int i, ilen;
	  ilen = Len(l);
	  for (i = 2; i < ilen; i++) {
	    String *parm = Getitem(l, i);
	    char *eq = strchr(Char(parm), '=');
	    char *c = Char(parm);
	    if (eq && (eq - c > 0)) {
	      String *name = NewStringWithSize(c, eq - c);
	      String *value = NewString(eq + 1);
	      Insert(name, 0, "$");
	      Setattr(vars, name, value);
	    } else {
	      to_match_parms = 0; /* error - variable replacement parameters must be of form varname=value */
	    }
	  }
	}

	/* Perform a typemap search */
	if (to_match_parms) {
	  static int already_substituting = 0;
	  String *tm;
	  String *attr;
	  int match = 0;
#ifdef SWIG_DEBUG
	  Printf(stdout, "Swig_typemap_attach_parms:  embedded\n");
#endif
	  if (!already_substituting) {
	    already_substituting = 1;
	    Swig_typemap_attach_parms(tmap_method, to_match_parms, f);
	    already_substituting = 0;

	    /* Look for the typemap code */
	    attr = NewStringf("tmap:%s", tmap_method);
	    tm = Getattr(to_match_parms, attr);
	    if (tm) {
	      Printf(attr, "%s", ":next");
	      /* fail if multi-argument lookup requested in $typemap(...) and the lookup failed */
	      if (!Getattr(to_match_parms, attr)) {
		/* Replace parameter variables */
		Iterator ki;
		for (ki = First(vars); ki.key; ki = Next(ki)) {
		  Replace(tm, ki.key, ki.item, DOH_REPLACE_ANY);
		}
		/* offer the target language module the chance to make special variable substitutions */
		Language_replace_special_variables(tmap_method, tm, to_match_parms);
		/* finish up - do the substitution */
		Replace(s, dollar_typemap, tm, DOH_REPLACE_ANY);
		Delete(tm);
		match = 1;
	      }
	    }

	    if (!match) {
	      String *dtypemap = NewString(dollar_typemap);
	      Replaceall(dtypemap, "$TYPEMAP", "$typemap");
	      Swig_error(Getfile(s), Getline(s), "No typemap found for %s\n", dtypemap);
	      Delete(dtypemap);
	    }
	    Delete(attr);
	  } else {
	    /* simple recursive call check, but prevents using an embedded typemap that contains another embedded typemap */
	    String *dtypemap = NewString(dollar_typemap);
	    Replaceall(dtypemap, "$TYPEMAP", "$typemap");
	    Swig_error(Getfile(s), Getline(s), "Recursive $typemap calls not supported - %s\n", dtypemap);
	    Delete(dtypemap);
	  }
	  syntax_error = 0;
	}
	Delete(vars);
      }
      Delete(l);
    }

    if (syntax_error) {
      String *dtypemap = NewString(dollar_typemap);
      Replaceall(dtypemap, "$TYPEMAP", "$typemap");
      Swig_error(Getfile(s), Getline(s), "Syntax error in: %s\n", dtypemap);
      Delete(dtypemap);
    }
    Replace(s, dollar_typemap, "<error in embedded typemap>", DOH_REPLACE_ANY);
    Delete(dollar_typemap);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_debug()
 *
 * Display all typemaps
 * ----------------------------------------------------------------------------- */

void Swig_typemap_debug() {
  int ts;
  Printf(stdout, "---[ typemaps ]--------------------------------------------------------------\n");

  ts = tm_scope;
  while (ts >= 0) {
    Printf(stdout, "::: scope %d\n\n", ts);
    Printf(stdout, "%s\n", typemaps[ts]);
    ts--;
  }
  Printf(stdout, "-----------------------------------------------------------------------------\n");
}


/* -----------------------------------------------------------------------------
 * Swig_typemap_search_debug_set()
 *
 * Turn on typemap searching debug display
 * ----------------------------------------------------------------------------- */

void Swig_typemap_search_debug_set(void) {
  typemap_search_debug = 1;
}


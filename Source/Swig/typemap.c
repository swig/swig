/* -----------------------------------------------------------------------------
 * typemap.c
 *
 *     A somewhat generalized implementation of SWIG1.1 typemaps.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "swig.h"

#define MAX_SCOPE  32

static Hash *typemaps[MAX_SCOPE];
static int   tm_scope = 0;

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

static char *parm_key(String_or_char *pname) {
  static char temp[512] = "-";
  strcpy(temp+1,Char(pname));
  return temp;
}

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

Hash *
Swig_typemap_pop_scope() {
  if (tm_scope > 0) {
    return Swig_temp_result(typemaps[tm_scope--]);
  }
  return 0;
}

/* ----------------------------------------------------------------------------- 
 * Swig_typemap_register()
 *
 * Add a new typemap
 * ----------------------------------------------------------------------------- */

void
Swig_typemap_register(char *op, SwigType *type, String_or_char *pname, String_or_char *code, ParmList *locals) {
  char *key;
  Hash *tm;
  Hash *tm1;
  Hash *tm2;

  /* See if this type has been seen before */
  tm = Getattr(typemaps[tm_scope],type);
  if (!tm) {
    tm = NewHash();
    Setattr(typemaps[tm_scope],Char(type),tm);
    Delete(tm);
  }
  if ((pname) && Len(pname)) {
    /* See if parameter has been seen before */
    key = parm_key(pname);
    tm1 = Getattr(tm,key);
    if (!tm1) {
      tm1 = NewHash();
      Setattr(tm,key,tm1);
      Delete(tm1);
    }
    tm = tm1;
  }
  tm2 = Getattr(tm,op);
  if (tm2) {
    SwigType *tm_type;
    String   *tm_pname;
    tm_type = Getattr(tm2,"type");
    tm_pname = Getattr(tm2,"pname");
    if (Cmp(tm_type,type) || Cmp(tm_pname,pname)) {
      tm2 = 0;
    }
  }
  if (!tm2) {
    tm2 = NewHash();
    Setattr(tm,op,tm2);
    Delete(tm2);
  }
  Setattr(tm2,"code",NewString(code));
  Setattr(tm2,"type",NewString(type));
  Setattr(tm2,"typemap",NewStringf("typemap(%s) %s", op, SwigType_str(type,pname)));
  if (pname) {
    Setattr(tm2,"pname", NewString(pname));
  }
  Setattr(tm2,"locals", CopyParmList(locals));
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_get()
 *
 * Retrieve typemap information from current scope.
 * ----------------------------------------------------------------------------- */

static Hash *
Swig_typemap_get(SwigType *type, String_or_char *name, int scope) {
  Hash *tm, *tm1;
  /* See if this type has been seen before */
  if ((scope < 0) || (scope > tm_scope)) return 0;
  tm = Getattr(typemaps[scope],type);
  if (!tm) {
    return 0;
  }
  if ((name) && Len(name)) {
    tm1 = Getattr(tm, parm_key(name));
    return tm1;
  }
  return tm;
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_copy()
 *
 * Copy a typemap
 * ----------------------------------------------------------------------------- */

void
Swig_typemap_copy(char *op, SwigType *stype, String_or_char *sname, 
		  SwigType *ttype, String_or_char *tname) {

  Hash *tm=0, *tm1;
  int ts = tm_scope;
  while (ts >= 0) {
    tm = Swig_typemap_get(stype,sname,ts);
    if (tm) break;
    tm = Swig_typemap_get(stype,0,ts);
    if (tm) break;
    ts--;
  }
  if (!tm) return;
  tm1 = Getattr(tm,op);
  if (!tm1) return;
  Swig_typemap_register(op,ttype,tname, Getattr(tm1,"code"), Getattr(tm1,"locals"));
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_clear()
 *
 * Delete a typemap
 * ----------------------------------------------------------------------------- */

void
Swig_typemap_clear(char *op, SwigType *type, String_or_char *name) {
  Hash *tm;

  tm = Swig_typemap_get(type,name,tm_scope);
  if (tm)
    Delattr(tm,op);
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_apply()
 *
 * %apply directive.  This function is nothing more than a glorified typemap
 * copy.  Note: this is *very* different than SWIG1.1 although the end result
 * is very "similar."
 * ----------------------------------------------------------------------------- */

static void merge_attributes(Hash *target, Hash *source) {
  String *key;
  for (key = Firstkey(source); key; key = Nextkey(source)) {
    /*    if (Getattr(target,key)) continue; */
    Setattr(target,key,Getattr(source,key));
  }
}

void 
Swig_typemap_apply(SwigType *tm_type, String_or_char *tmname, SwigType *type, String_or_char *pname) {
  Hash *tm, *tm1, *am;
  int ts = tm_scope;
  char *key;

  tm = Swig_typemap_get(type,pname,tm_scope);
  if (!tm) {
    tm = Getattr(typemaps[tm_scope],type);
    if (!tm) {
      tm = NewHash();
      Setattr(typemaps[tm_scope], Char(type), tm);
      Delete(tm);
    }
    if ((pname) && Len(pname)) {
      key = parm_key(pname);
      tm1 = NewHash();
      Setattr(tm,key,tm1);
      Delete(tm1);
      tm = tm1;
    }
  }
  /* tm contains the typemap table into which we are going to be copying */
  while (ts >= 0) {
    am = Swig_typemap_get(tm_type, tmname,ts);
    if (am) {
      merge_attributes(tm,am);
    }
    ts--;
  }
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_clear_apply()
 *
 * %clear directive.   Clears all typemaps for a type. 
 * ----------------------------------------------------------------------------- */

void
Swig_typemap_clear_apply(SwigType *type, String_or_char *name) {
  Hash *tm;
  
  tm = Getattr(typemaps[tm_scope],type);
  if (!tm) return;
  if ((name) && (Len(name))) {
    Delattr(tm,parm_key(name));
  } else {
    Delattr(typemaps[tm_scope],type);
  }
}


/* Internal function to strip array dimensions. */
static SwigType *strip_arrays(SwigType *type) {
  SwigType *t;
  int ndim;
  int i;
  t = Copy(type);
  ndim = SwigType_array_ndim(t);
  for (i = 0; i < ndim; i++) {
    SwigType_array_setdim(t,i,"ANY");
  }
  return t;
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_search_op()
 *
 * Search for a typemap match.
 * ----------------------------------------------------------------------------- */

Hash *
Swig_typemap_search(char *op, SwigType *type, String_or_char *name) {
  Hash *result = 0, *tm, *tm1, *tma;
  SwigType *noarrays = 0;
  SwigType *primitive = 0;
  SwigType *ctype = 0;
  int ts;
  int isarray;
  char *cname = 0;

  if ((name) && Len(name)) cname = parm_key(name);
  isarray = SwigType_isarray(type);
  ts = tm_scope;
  while (ts >= 0) {
    ctype = type;
    while (ctype) {
      /* Try to get an exact type-match */
      tm = Getattr(typemaps[ts],ctype);
      if (tm && cname) {
	tm1 = Getattr(tm,cname);
	if (tm1) {
	  result = Getattr(tm1,op);          /* See if there is a type-name match */
	  if (result) goto ret_result;
	}
      }
      if (tm) {
	result = Getattr(tm,op);            /* See if there is simply a type match */
	if (result) goto ret_result;
      }
      
      if (isarray) {
	/* If working with arrays, strip away all of the dimensions and replace with ANY.
	   See if that generates a match */
	if (!noarrays) noarrays = strip_arrays(ctype);
	tma = Getattr(typemaps[ts],noarrays);
	if (tma && cname) {
	  tm1 = Getattr(tma,cname);
	  if (tm1) {
	    result = Getattr(tm1,op);       /* type-name match */
	    if (result) goto ret_result;
	  }
	}
	if (tma) {
	  result = Getattr(tma,op);        /* type match */
	  if (result) goto ret_result;
	}
      }
      
      /* No match so far.  If this type had a typedef declaration, maybe there are
         some typemaps for that */
      {
	SwigType *nt = SwigType_typedef_resolve(ctype);
	if (ctype != type) Delete(ctype);
	ctype = nt;
      }
    }
    
    /* Hmmm. Well, no match seems to be found at all. See if there is some kind of default mapping */
    if (!primitive)
      primitive = SwigType_default(type);
    tm = Getattr(typemaps[ts],primitive);
    if (tm) {
      result = Getattr(tm,op);
      if (result) goto ret_result;
    }
    if (ctype != type) Delete(ctype);
    ts--;         /* Hmmm. Nothing found in this scope.  Guess we'll go try another scope */
  }
  
 ret_result:
  if (noarrays) Delete(noarrays);
  if (primitive) Delete(primitive);
  if (type != ctype) Delete(ctype);
  return result;
}


/* ------------------------------------------------------------------------
 * static typemap_locals()
 *
 * Takes a string, a parameter list and a wrapper function argument and
 * creates the local variables.
 * ------------------------------------------------------------------------ */

static void typemap_locals(SwigType *t, String_or_char *pname, DOHString *s, ParmList *l, Wrapper *f) {
  Parm *p;
  char *new_name;
  
  p = l;
  while (p) {
    SwigType *pt = Gettype(p);
    String   *pn = Getname(p);
    if (pn) {
      if (Len(pn) > 0) {
	DOHString *str;
	SwigType  *tt;

	str = NewString("");
	/* If the user gave us $type as the name of the local variable, we'll use
	   the passed datatype instead */

	if (Cmp(SwigType_base(pt),"$type")==0 || Cmp(SwigType_base(pt),"$basetype")==0) {
	  tt = t;
	} else {
	  tt = pt;
	}
	Printf(str,"%s",pn);
	/* Substitute parameter names */
	Replace(str,"$arg",pname, DOH_REPLACE_ANY);
        if (Cmp(SwigType_base(pt),"$basetype")==0) {
          /* use $basetype */
	  new_name = Wrapper_new_localv(f,str,SwigType_base(tt),str,0);
        } else {
          new_name = Wrapper_new_localv(f,str, SwigType_str(tt,str), 0);
	}
	/* Substitute  */
	Replace(s,pn,new_name,DOH_REPLACE_ID);
      }
    }
    p = Getnext(p);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_lookup()
 *
 * Perform a typemap lookup (ala SWIG1.1)
 * ----------------------------------------------------------------------------- */

char *Swig_typemap_lookup(char *op, SwigType *type, String_or_char *pname, String_or_char *source,
			  String_or_char *target, Wrapper *f) 
{
  Hash   *tm;
  String *s;
  ParmList *locals;

  tm = Swig_typemap_search(op,type,pname);
  if (!tm) return 0;

  s = Getattr(tm,"code");
  if (!s) return 0;
  s = Copy(s);             /* Make a local copy of the typemap code */

  locals = Getattr(tm,"locals");

  /* Replace array dimensions */
  if (locals && f) {
    typemap_locals(type,pname,s,locals,f);
  }

  /* If the original datatype was an array. We're going to go through and substitute
     it's array dimensions */

  if (SwigType_isarray(type)) {
    char temp[10];
    int  ndim = SwigType_array_ndim(type);
    int i;
    for (i = 0; i < ndim; i++) {
      DOHString *dim = SwigType_array_getdim(type,i);
      sprintf(temp,"$dim%d",i);
      if (f)
	Replace(Getattr(f,"locals"),temp,dim, DOH_REPLACE_ANY);
      Replace(s,temp,dim,DOH_REPLACE_ANY);
    }
  }
  
  /* Now perform character replacements */
  Replace(s,"$source",source,DOH_REPLACE_ANY);
  Replace(s,"$target",target,DOH_REPLACE_ANY);
  {
    String *tmname = Getattr(tm,"typemap");
    if (tmname) Replace(s,"$typemap",tmname, DOH_REPLACE_ANY);
  }
  Replace(s,"$type",SwigType_str(type,0),DOH_REPLACE_ANY);
  {
    SwigType *ltype = Swig_clocal_type(type);
    Replace(s,"$ltype",SwigType_str(ltype,0), DOH_REPLACE_ANY);
    Delete(ltype);
  }
  Replace(s,"$parmname",pname, DOH_REPLACE_ANY);

  /* Print base type (without any pointers) */
  Replace(s,"$basetype",SwigType_base(type), DOH_REPLACE_ANY);
  Replace(s,"$basemangle",SwigType_manglestr(SwigType_base(type)), DOH_REPLACE_ANY);
  Replace(s,"$mangle",SwigType_manglestr(type), DOH_REPLACE_ANY);
  Swig_temp_result(s);
  return Char(s);
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_debug()
 * ----------------------------------------------------------------------------- */

void Swig_typemap_debug() {
  int ts;
  Printf(stdout,"---[ typemaps ]--------------------------------------------------------------\n");
  
  ts = tm_scope;
  while (ts >= 0) {
    Printf(stdout,"::: scope %d\n\n",ts);
    Printf(stdout,"%s\n", typemaps[ts]);
    ts--;
  }
  Printf(stdout,"-----------------------------------------------------------------------------\n");
}
 

/* -----------------------------------------------------------------------------
 * %except directive support.
 *
 * These functions technically don't really have anything to do with typemaps
 * except that they have the same scoping rules.  Therefore, it's easy enough to 
 * just use the hash table structure of the typemap code.
 * ----------------------------------------------------------------------------- */

void Swig_except_register(String_or_char *code) {
  String *s = NewString(code);
  Setattr(typemaps[tm_scope],"*except*",s);
  Delete(s);
}

char *Swig_except_lookup() {
  String *s;
  int ts = tm_scope;
  while (ts >= 0) {
    s = Getattr(typemaps[tm_scope],"*except*");
    if (s) {
      s = Copy(s);
      Swig_temp_result(s);
      return Char(s);
    }
    ts--;
  }
  return 0;
}

void Swig_except_clear() {
  Delattr(typemaps[tm_scope],"*except*");
}

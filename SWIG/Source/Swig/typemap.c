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

/* -----------------------------------------------------------------------------
 * Typemaps are stored in a collection of nested hash tables.  Something like
 * this:
 *
 * [ type ]
 *    +-------- [ name ]
 *    +-------- [ name ]
 *    
 * Each hash table [ type ] or [ name ] then contains references to the
 * different typemap methods.    These are reference by names such as
 * "tmap:in", "tmap:out", "tmap:argout", and so forth.
 *
 * The object corresponding to a specific method has the following
 * attributes:
 *
 *    "type"    -  Typemap type
 *    "pname"   -  Parameter name
 *    "code"    -  Typemap code
 *    "typemap" -  Descriptive text describing the actual map
 *    "locals"  -  Local variables (if any)
 *    "multi"   -  If a multiple valued typemap, a pointer to the next
 *                 typemap entry.
 * 
 * ----------------------------------------------------------------------------- */

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

static char *tmop_name(const String_or_char *op) {
  static char temp[512] = "tmap:";
  strcpy(temp+5,Char(op));
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
    return typemaps[tm_scope--];
  }
  return 0;
}

/* ----------------------------------------------------------------------------- 
 * Swig_typemap_register()
 *
 * Add a new typemap
 * ----------------------------------------------------------------------------- */

void
Swig_typemap_register(const String_or_char *op, SwigType *type, String_or_char *pname, String_or_char *code, ParmList *locals) {
  Hash *tm;
  Hash *tm1;
  Hash *tm2;
  String *tmop = NewStringf("tmap:%s",op);

  /* See if this type has been seen before */
  tm = Getattr(typemaps[tm_scope],type);
  if (!tm) {
    tm = NewHash();
    Setattr(typemaps[tm_scope],Char(type),tm);
    Delete(tm);
  }
  if ((pname) && Len(pname)) {
    /* See if parameter has been seen before */
    tm1 = Getattr(tm,pname);
    if (!tm1) {
      tm1 = NewHash();
      Setattr(tm,NewString(pname),tm1);
      Delete(tm1);
    }
    tm = tm1;
  }
  tm2 = Getattr(tm,tmop);
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
    Setattr(tm,tmop,tm2);
    Delete(tm2);
  }
  Setattr(tm2,"code",NewString(code));
  Setattr(tm2,"type",NewString(type));
  Setattr(tm2,"typemap",NewStringf("typemap(%s) %s", op, SwigType_str(type,pname)));
  if (pname) {
    Setattr(tm2,"pname", NewString(pname));
  }
  Setattr(tm2,"locals", CopyParmList(locals));
  Delete(tmop);
}


/* ----------------------------------------------------------------------------- 
 * Swig_typemap_register_multi()
 *
 * Add a new multi-valued typemap
 * ----------------------------------------------------------------------------- */

void
Swig_typemap_register_multi(const String_or_char *op, ParmList *parms, String_or_char *code, ParmList *locals) {
  Hash *tm;
  Hash *tm1;
  Hash *tm2;
  Parm *np;
  String *tmop;
  SwigType *type;
  String   *pname;

  if (!parms) return;
  tmop = NewStringf("tmap:%s",op);

  /* Register the first type in the parameter list */

  type = Getattr(parms,"type");
  pname = Getattr(parms,"name");

  /* See if this type has been seen before */
  tm = Getattr(typemaps[tm_scope],type);
  if (!tm) {
    tm = NewHash();
    Setattr(typemaps[tm_scope],Copy(type),tm);
    Delete(tm);
  }
  if (pname) {
    /* See if parameter has been seen before */
    tm1 = Getattr(tm,pname);
    if (!tm1) {
      tm1 = NewHash();
      Setattr(tm,NewString(pname),tm1);
      Delete(tm1);
    }
    tm = tm1;
  }

  /* Now see if this typemap op has been seen before */
  tm2 = Getattr(tm,tmop);
  if (!tm2) {
    tm2 = NewHash();
    Setattr(tm,tmop,tm2);
    Delete(tm2);
  }

  /* For a multi-valued typemap, the typemap code and information
     is really only stored in the last argument.  However, to
     make this work, we perform a really neat trick using
     the typemap operator name.

     For example, consider this typemap

       %typemap(in) (int foo, int *bar, char *blah[]) {
            ...
       }

     To store, it we save information for a typemap
          "in" -> int foo
          "in-int *bar:" --> int *bar
          "in-char *blah[]:in-int *bar:"  --> char *blah[]

  */

  np = nextSibling(parms);
  if (np) {
    /* Make an entirely new operator key */
    String *newop = NewStringf("%s-%s:",op,type);
    /* Now reregister on the remaining arguments */
    Swig_typemap_register_multi(newop,np,code,locals);
    Setattr(tm2,newop,newop);
    Delete(newop);
  } else {
    Setattr(tm2,"code",NewString(code));
    Setattr(tm2,"type",Copy(type));
    Setattr(tm2,"typemap",NewStringf("typemap(%s) %s", op, SwigType_str(type,pname)));
    if (pname) {
      Setattr(tm2,"pname", NewString(pname));
    }
    Setattr(tm2,"locals", CopyParmList(locals));
    Delete(tmop);
  }
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

void
Swig_typemap_copy(const String_or_char *op, SwigType *stype, String_or_char *sname, 
		  SwigType *ttype, String_or_char *tname) {

  Hash *tm=0, *tm1;
  String *tmop;
  int ts = tm_scope;

  tmop = NewStringf("tmap:%s",op);
  while (ts >= 0) {
    tm = Swig_typemap_get(stype,sname,ts);
    if (!tm) {
      tm = Swig_typemap_get(stype,0,ts);
    }
    if (tm) {
      tm1 = Getattr(tm,tmop);
      if (tm1) {
	Swig_typemap_register(op,ttype,tname, Getattr(tm1,"code"), Getattr(tm1,"locals"));
	Delete(tmop);
	return;
      }
    }
    ts--;
  }
  Delete(tmop);
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_clear()
 *
 * Delete a typemap
 * ----------------------------------------------------------------------------- */

void
Swig_typemap_clear(const String_or_char *op, SwigType *type, String_or_char *name) {
  Hash *tm;

  tm = Swig_typemap_get(type,name,tm_scope);
  if (tm)
    Delattr(tm,tmop_name(op));
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_clear_multi()
 *
 * Delete a multi-valued typemap
 * ----------------------------------------------------------------------------- */

void
Swig_typemap_clear_multi(const String_or_char *op, ParmList *parms) {
  SwigType *type;
  String   *name;
  Parm     *p;
  String   *newop;
  Hash *tm = 0;
  
  newop = NewString(op);
  p = parms;
  while (p) {
    type = Getattr(p,"type");
    name = Getattr(p,"name");
    tm = Swig_typemap_get(type,name,tm_scope);
    if (!tm) return;
    p = nextSibling(p);
    if (p) 
      Printf(newop,"-%s:", type);
  }
  if (tm)
    Delattr(tm,tmop_name(newop));
  Delete(newop);
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
    if (Getattr(target,key)) continue;
    Setattr(target,key,Getattr(source,key));
  }
}

void 
Swig_typemap_apply(SwigType *tm_type, String_or_char *tmname, SwigType *type, String_or_char *pname) {
  Hash *tm, *tm1, *am;
  int ts = tm_scope;

  tm = Swig_typemap_get(type,pname,tm_scope);
  if (!tm) {
    tm = Getattr(typemaps[tm_scope],type);
    if (!tm) {
      tm = NewHash();
      Setattr(typemaps[tm_scope], Char(type), tm);
      Delete(tm);
    }
    if ((pname) && Len(pname)) {
      tm1 = NewHash();
      Setattr(tm,NewString(pname),tm1);
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
    Delattr(tm,name);
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
 * Swig_typemap_search()
 *
 * Search for a typemap match.
 * ----------------------------------------------------------------------------- */

Hash *
Swig_typemap_search(const String_or_char *op, SwigType *type, String_or_char *name) {
  Hash *result = 0, *tm, *tm1, *tma;
  SwigType *noarrays = 0;
  SwigType *primitive = 0;
  SwigType *ctype = 0;
  int ts;
  int isarray;
  String *cname = 0;
  SwigType *unstripped = 0;
  String   *tmop = NewStringf("tmap:%s",op);

  if ((name) && Len(name)) cname = name;
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
	  result = Getattr(tm1,tmop);          /* See if there is a type-name match */
	  if (result) goto ret_result;
	}
      }
      if (tm) {
	result = Getattr(tm,tmop);            /* See if there is simply a type match */
	if (result) goto ret_result;
      }
      
      if (isarray) {
	/* If working with arrays, strip away all of the dimensions and replace with "".
	   See if that generates a match */
	if (!noarrays) noarrays = strip_arrays(ctype);
	tma = Getattr(typemaps[ts],noarrays);
	if (tma && cname) {
	  tm1 = Getattr(tma,cname);
	  if (tm1) {
	    result = Getattr(tm1,tmop);       /* type-name match */
	    if (result) goto ret_result;
	  }
	}
	if (tma) {
	  result = Getattr(tma,tmop);        /* type match */
	  if (result) goto ret_result;
	}
      }
      
      /* No match so far.   If the type is unstripped, we'll strip it's
         qualifiers and check.   Otherwise, we'll try to resolve a typedef */

      if (!unstripped) {
	unstripped = ctype;
	ctype = SwigType_strip_qualifiers(ctype);
	if (Cmp(ctype,unstripped)) continue;
	Delete(ctype);
	ctype = unstripped;
	unstripped = 0;
      }
      {
	if (unstripped) {
	  if (unstripped != type) Delete(unstripped);
	  unstripped = 0;
	}
	ctype = SwigType_typedef_resolve(ctype);
      }
    }
    
    /* Hmmm. Well, no match seems to be found at all. See if there is some kind of default mapping */
    if (!primitive)
      primitive = SwigType_default(type);
    tm = Getattr(typemaps[ts],primitive);
    if (tm && cname) {
      tm1 = Getattr(tm,cname);
      if (tm1) {
	result = Getattr(tm1,tmop);          /* See if there is a type-name match */
	if (result) goto ret_result;
      }
    }
    if (tm) {			/* See if there is simply a type match */
      result = Getattr(tm,tmop);
      if (result) goto ret_result;
    }
    if (ctype != type) Delete(ctype);
    ts--;         /* Hmmm. Nothing found in this scope.  Guess we'll go try another scope */
  }
  
 ret_result:
  Delete(tmop);
  if (noarrays) Delete(noarrays);
  if (primitive) Delete(primitive);
  if ((unstripped) && (unstripped != type)) Delete(unstripped);
  if (type != ctype) Delete(ctype);
  return result;
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_search_multi()
 *
 * Search for a multi-valued typemap.
 * ----------------------------------------------------------------------------- */

Hash *
Swig_typemap_search_multi(const String_or_char *op, ParmList *parms, int *nmatch) {
  SwigType *type;
  String   *name;
  String   *newop;
  Hash     *tm, *tm1;

  if (!parms) {
    *nmatch = 0;
    return 0;
  }
  type = Getattr(parms,"type");
  name = Getattr(parms,"name");

  /* Try to find a match on the first type */
  tm = Swig_typemap_search(op, type, name);
  if (tm) {
    newop = NewStringf("%s-%s:", op, type);
    tm1 = Swig_typemap_search_multi(newop, nextSibling(parms), nmatch);
    if (tm1) tm = tm1;
    if (Getattr(tm,"code")) {
      *(nmatch) = *nmatch + 1;
    } else {
      tm = 0;
    }
    Delete(newop);
  }
  return tm;
}


/* -----------------------------------------------------------------------------
 * typemap_replace_vars()
 *
 * Replaces typemap variables on a string.  index is the $n variable.
 * type and pname are the type and parameter name.
 * ----------------------------------------------------------------------------- */

static
void typemap_replace_vars(String *s, SwigType *type, String *pname, String *lname, int index) 
{
  char var[512];
  char *varname;

  sprintf(var,"$%d_",index);
  varname = &var[strlen(var)];
    
  /* If the original datatype was an array. We're going to go through and substitute
     it's array dimensions */
    
  if (SwigType_isarray(type)) {
    int  ndim = SwigType_array_ndim(type);
    int i;
    for (i = 0; i < ndim; i++) {
      String *dim = SwigType_array_getdim(type,i);
      if (!index) {
	char t[32];
	sprintf(t,"$dim%d",i);
	Replace(s,t,dim,DOH_REPLACE_ANY);
      }
      sprintf(varname,"dim%d",i);
      Replace(s,var,dim,DOH_REPLACE_ANY);
      Delete(dim);
    }
  }

  /* Parameter name substitution */
  if (!index) {
    Replace(s,"$name",pname, DOH_REPLACE_ANY);
  }
  strcpy(varname,"name");
  Replace(s,var,pname,DOH_REPLACE_ANY);

  /* Type-related stuff */
  {
    SwigType *star_type, *amp_type, *base_type;
    SwigType *ltype, *star_ltype, *amp_ltype;
    String *mangle, *star_mangle, *amp_mangle, *base_mangle;
    String *descriptor, *star_descriptor, *amp_descriptor;
    String *ts;
    char   *sc;

    sc = Char(s);

    if (strstr(sc,"type")) {
      /* Given type : $type */
      ts = SwigType_str(type,0);
      if (!index)
	Replace(s, "$type", ts, DOH_REPLACE_ANY);
      strcpy(varname,"type");
      Replace(s,var,ts,DOH_REPLACE_ANY);
      Delete(ts);
      sc = Char(s);
    }
    if (strstr(sc,"ltype")) {
      /* Local type:  $ltype */
      ltype = Swig_clocal_type(type);
      ts = SwigType_str(ltype,0);
      if (!index)
	Replace(s, "$ltype", ts, DOH_REPLACE_ANY);
      strcpy(varname,"ltype");
      Replace(s,var,ts,DOH_REPLACE_ANY);
      Delete(ts);
      Delete(ltype);
      sc = Char(s);
    }
    if (strstr(sc,"mangle") || strstr(sc,"descriptor")) {
      /* Mangled type */
      
      mangle = SwigType_manglestr(type);
      if (!index)
	Replace(s, "$mangle", mangle, DOH_REPLACE_ANY);
      strcpy(varname,"mangle");
      Replace(s,var,mangle,DOH_REPLACE_ANY);
    
      descriptor = NewStringf("SWIGTYPE%s", mangle);
      if (!index)
	if (Replace(s, "$descriptor", descriptor, DOH_REPLACE_ANY))
	  SwigType_remember(type);
      
      strcpy(varname,"descriptor");
      if (Replace(s,var,descriptor,DOH_REPLACE_ANY))
	SwigType_remember(type);
      
      Delete(descriptor);
      Delete(mangle);
    }
    
    /* One pointer level removed */
    /* This creates variables of the form
          $*n_type
          $*n_ltype
    */


    if (SwigType_ispointer(type)) {
      star_type = Copy(type);
      SwigType_del_pointer(star_type);
      ts = SwigType_str(star_type,0);
      if (!index) 
	Replace(s, "$*type", ts, DOH_REPLACE_ANY);
      sprintf(varname,"$*%d_type",index);
      Replace(s,varname,ts,DOH_REPLACE_ANY);
      Delete(ts);
      
      star_ltype = Swig_clocal_type(star_type);
      ts = SwigType_str(star_ltype,0);
      if (!index)
	Replace(s, "$*ltype", ts, DOH_REPLACE_ANY);
      sprintf(varname,"$*%d_ltype",index);
      Replace(s,varname,ts,DOH_REPLACE_ANY);
      Delete(ts);
      Delete(star_ltype);
      
      star_mangle = SwigType_manglestr(star_type);
      if (!index) 
	Replace(s, "$*mangle", star_mangle, DOH_REPLACE_ANY);
      
      sprintf(varname,"$*%d_mangle",index);
      Replace(s,varname,star_mangle,DOH_REPLACE_ANY);
      
      star_descriptor = NewStringf("SWIGTYPE%s", star_mangle);
      if (!index)
	if (Replace(s, "$*descriptor",
		    star_descriptor, DOH_REPLACE_ANY))
	  SwigType_remember(star_type);
      sprintf(varname,"$*%d_descriptor",index);
      if (Replace(s,varname,star_descriptor,DOH_REPLACE_ANY))
	SwigType_remember(star_type);
      
      Delete(star_descriptor);
      Delete(star_mangle);
    }
    else {
      /* TODO: Signal error if one of the $* substitutions is
	 requested */
    }
    /* One pointer level added */
    amp_type = Copy(type);
    SwigType_add_pointer(amp_type);
    ts = SwigType_str(amp_type,0);
    if (!index) 
      Replace(s, "$&type", ts, DOH_REPLACE_ANY);
    sprintf(varname,"$&%d_type",index);
    Replace(s,varname,ts,DOH_REPLACE_ANY);
    Delete(ts);
    
    amp_ltype = Swig_clocal_type(amp_type);
    ts = SwigType_str(amp_ltype,0);
    
    if (!index)
      Replace(s, "$&ltype", ts, DOH_REPLACE_ANY);
    sprintf(varname,"$&%d_ltype",index);
    Replace(s,varname,ts,DOH_REPLACE_ANY);
    Delete(ts);
    Delete(amp_ltype);
    
    amp_mangle = SwigType_manglestr(amp_type);
    if (!index) 
      Replace(s, "$&mangle", amp_mangle, DOH_REPLACE_ANY);
    sprintf(varname,"$&%d_mangle",index);
    Replace(s,varname,amp_mangle,DOH_REPLACE_ANY);
    
    amp_descriptor = NewStringf("SWIGTYPE%s", amp_mangle);
    if (!index) 
      if (Replace(s, "$&descriptor",
		  amp_descriptor, DOH_REPLACE_ANY))
	SwigType_remember(amp_type);
    sprintf(varname,"$&%d_descriptor",index);
    if (Replace(s,varname,amp_descriptor,DOH_REPLACE_ANY))
      SwigType_remember(amp_type);
    
    Delete(amp_descriptor);
    Delete(amp_mangle);
    
    /* Base type */
    base_type = SwigType_base(type);
    if (!index)
      Replace(s,"$basetype", base_type, DOH_REPLACE_ANY);
    strcpy(varname,"basetype");
    Replace(s,var,base_type,DOH_REPLACE_ANY);
    
    base_mangle = SwigType_manglestr(base_type);
    if (!index)
      Replace(s,"$basemangle", base_mangle, DOH_REPLACE_ANY);
    strcpy(varname,"basemangle");
    Replace(s,var,base_mangle,DOH_REPLACE_ANY);
    Delete(base_mangle);
    Delete(base_type);
  }
  /* Replace the bare $n variable */
  sprintf(var,"$%d",index);
  Replace(s,var,lname,DOH_REPLACE_ANY);
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
  SwigType *pbase = 0;

  p = l;
  while (p) {
    SwigType *pt = Getattr(p,"type");
    String   *pn = Getattr(p,"name");
    if (pn) {
      if (Len(pn) > 0) {
	DOHString *str;

	str = NewString("");
	/* If the user gave us $type as the name of the local variable, we'll use
	   the passed datatype instead */

	Printf(str,"%s",pn);
	/* Substitute parameter names */
	Replace(str,"$arg",pname, DOH_REPLACE_ANY);
	pbase = SwigType_base(pt);
        if (Cmp(pbase,"$basetype")==0) /* use $basetype */
	  new_name = Wrapper_new_localv(f,str,SwigType_base(t),str,0);
	else if (Cmp(pbase, "$type") == 0
		 || Cmp(pbase, "$ltype") == 0) 
	  new_name = Wrapper_new_localv(f,str,SwigType_str(Swig_clocal_type(t), 0),str,0);
	else if ((Cmp(pbase, "$*type") == 0
		  || Cmp(pbase, "$*ltype") == 0)
		 && SwigType_ispointer(t)) {
	  SwigType *star_type = Copy(t);
	  SwigType_del_pointer(star_type);
	  new_name = Wrapper_new_localv(f,str,SwigType_str(Swig_clocal_type(star_type), 0),
					str, 0);
	  Delete(star_type);
	}
	else if (Cmp(pbase, "$&type") == 0
		 || Cmp(pbase, "$&ltype") == 0) {
	  SwigType *amp_type = Copy(t);
	  SwigType_add_pointer(amp_type);
	  new_name = Wrapper_new_localv(f,str,SwigType_str(Swig_clocal_type(amp_type), 0),
					str, 0);
	  Delete(amp_type);
	}
	else 
          new_name = Wrapper_new_localv(f,str, SwigType_str(pt,str), 0);
	/* Substitute  */
	Replace(s,pn,new_name,DOH_REPLACE_ID);
	Delete(pbase);
      }
    }
    p = nextSibling(p);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_lookup()
 *
 * Perform a typemap lookup (ala SWIG1.1)
 * ----------------------------------------------------------------------------- */

String *Swig_typemap_lookup(const String_or_char *op, SwigType *type, String_or_char *pname,
			  String_or_char *lname, String_or_char *source,
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

  if (locals && f) {
    typemap_locals(type,pname,s,locals,f);
  }
  typemap_replace_vars(s,type,pname,lname,0);
   
  /* Now perform character replacements */
  Replace(s,"$source",source,DOH_REPLACE_ANY);
  Replace(s,"$target",target,DOH_REPLACE_ANY);
  {
    String *tmname = Getattr(tm,"typemap");
    if (tmname) Replace(s,"$typemap",tmname, DOH_REPLACE_ANY);
  }
  Replace(s,"$parmname",pname, DOH_REPLACE_ANY);
  Replace(s,"$name",pname,DOH_REPLACE_ANY);
  return s;
}


/* -----------------------------------------------------------------------------
 * Swig_typemap_lookup_multi()
 *
 * Perform a multi-valued typemap lookup
 * ----------------------------------------------------------------------------- */

String *Swig_typemap_lookup_multi(const String_or_char *op, ParmList *parms, String_or_char *source, Wrapper *f, int *nmatch) 
{
  Hash      *tm;
  String    *s;
  SwigType  *type;
  String    *pname;
  String    *target;
  ParmList  *locals;
  int        argnum = 0;

  tm = Swig_typemap_search_multi(op,parms,nmatch);
  if (!tm) return 0;

  s = Getattr(tm,"code");
  if (!s) return 0;
  s = Copy(s);             /* Make a local copy of the typemap code */

  locals = Getattr(tm,"locals");

  /* This is a bit of hack.  We perform the "normal" typemap substitutions on the
     first argument */

  argnum = 0;
  while (parms) {
    type = Getattr(parms,"type");
    pname = Getattr(parms,"name");
    target = Getattr(parms,"lname");

    if (locals && f && !argnum) {
      typemap_locals(type,pname,s,locals,f);
    }
    
    typemap_replace_vars(s,type,pname,target,argnum);

    /* Now perform character replacements (compatibility mode) */

    if (!argnum) {
      String *tmname;
      Replace(s,"$source",source,DOH_REPLACE_ANY);
      Replace(s,"$target",target,DOH_REPLACE_ANY);
      Replace(s,"$name",pname, DOH_REPLACE_ANY);
      tmname = Getattr(tm,"typemap");
      if (tmname) Replace(s,"$typemap",tmname, DOH_REPLACE_ANY);
    }
    parms = nextSibling(parms);
    argnum++;

  }
  return s;
}


/* -----------------------------------------------------------------------------
 * Swig_typemap_single()
 *
 * Perform a single valued typemap lookup
 * ----------------------------------------------------------------------------- */

String *Swig_typemap_single(const String_or_char *op, ParmList *parms, Hash *vars, Wrapper *f)
{
  Hash   *tm;
  String *s;
  String *key;
  ParmList *locals;
  SwigType  *type = Getattr(parms,"type");
  String    *pname = Getattr(parms,"name");
  String    *lname = Getattr(parms,"lname");

  tm = Swig_typemap_search(op,type,pname);
  if (!tm) return 0;

  s = Getattr(tm,"code");
  if (!s) return 0;
  s = Copy(s);             /* Make a local copy of the typemap code */

  locals = Getattr(tm,"locals");

  if (locals && f) {
    typemap_locals(type,pname,s,locals,f);
  }
  typemap_replace_vars(s,type,pname,lname,0);
  {
    String *tmname = Getattr(tm,"typemap");
    if (tmname) Replace(s,"$typemap",tmname, DOH_REPLACE_ANY);
  }
  Replace(s,"$parmname",pname, DOH_REPLACE_ANY);
  Replace(s,"$name",pname,DOH_REPLACE_ANY);

  for (key = Firstkey(vars); key; key = Nextkey(vars)) {
    String *val = Getattr(vars,key);
    Replace(s,key,val,DOH_REPLACE_ANY);
  }
  return s;
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_multi()
 *
 * Perform a multi-valued typemap lookup
 * ----------------------------------------------------------------------------- */

String *Swig_typemap_multi(const String_or_char *op, ParmList *parms, Hash *vars, Wrapper *f, int *nmatch) 
{
  Hash      *tm;
  String    *s;
  SwigType  *type;
  String    *pname;
  String    *lname;
  String    *tmname;
  ParmList  *locals;
  String    *key;
  int        argnum = 0;

  tm = Swig_typemap_search_multi(op,parms,nmatch);
  if (!tm) return 0;

  s = Getattr(tm,"code");
  if (!s) return 0;
  s = Copy(s);             /* Make a local copy of the typemap code */

  locals = Getattr(tm,"locals");

  argnum = 0;
  while (parms) {
    type = Getattr(parms,"type");
    pname = Getattr(parms,"name");
    lname = Getattr(parms,"lname");

    if (locals && f && !argnum) {
      typemap_locals(type,pname,s,locals,f);
    }

    typemap_replace_vars(s,type,pname,lname,argnum);

    /* Now perform character replacements (compatibility mode) */

    if (!argnum) {
      String *tmname;
      Replace(s,"$name",pname, DOH_REPLACE_ANY);
    }
    parms = nextSibling(parms);
    argnum++;

  }
  tmname = Getattr(tm,"typemap");
  if (tmname) Replace(s,"$typemap",tmname, DOH_REPLACE_ANY);

  /* Replace all user supplied variables */
  for (key = Firstkey(vars); key; key = Nextkey(vars)) {
    String *val = Getattr(vars,key);
    Replace(s,key,val,DOH_REPLACE_ANY);
  }
  return s;
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
      return Char(s);
    }
    ts--;
  }
  return 0;
}

void Swig_except_clear() {
  Delattr(typemaps[tm_scope],"*except*");
}

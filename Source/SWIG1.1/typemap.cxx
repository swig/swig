/* ----------------------------------------------------------------------------- 
 * typemap.cxx
 *
 *     Typemap support.
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

#include "internal.h"
#include <limits.h>

extern "C" {
#include "doh.h"
}

/* ------------------------------------------------------------------------
 * This file provides universal support for typemaps.   Typemaps are created
 * using the following SWIG command in an interface file:
 *
 *       %typemap(lang,operation) type { code }        Make a new typemap
 *       %typemap(lang,operation) type;                Clears any previous typemap
 *
 * lang is an identifier indicating the target language.  The typemap will
 * simply be ignored if its for a different language.  The code is the
 * corresponding C code for the mapping.  An example typemap might look
 * like this :
 *
 *       %typemap(tcl,get) double {
 *              $target = atof($source);
 *       }
 *       %typemap(tcl,set) double {
 *              sprintf($target,"%0.17f",$source);
 *       }
 *
 * The variables $target and $source should be used in any type-mappings.
 * Additional local variables can be created, but this should be done 
 * by enclosing the entire code fragment in an extra set of braces.
 *
 * The C++ API to the type-mapper is as follows :
 *
 * void typemap_register(char *op, char *lang, DataType *type, char *pname, String &getcode, ParmList *args)
 * char *typemap_lookup(char *op, char *lang, DataType *type, char *pname, char *source, char *target);
 * void typemap_clear(char *op, char *lang, DataType *type, char *pname);
 *
 * The lookup functions return a character string corresponding to the type-mapping
 * code or NULL if none exists.   The string return will have the source and target
 * strings substituted for the strings "$source" and "$target" in the type-mapping code.
 *
 * (2/19/97) This module has been extended somewhat to provide generic mappings
 * of other parts of the code--most notably exceptions.
 *
 * void fragment_register(char *op, char *lang, String &code)
 * char fragment_lookup(char *op, char *lang, int age);
 * char fragment_clear(char *op, char *lang);
 *
 * ------------------------------------------------------------------------ */

static ParmList *last_args = 0;

int type_id = 0;

/* Structure for holding a typemap */

struct TypeMap {
  char       *lang;
  SwigType   *type;
  DOHString  *code;
  int         first;
  int         last;
  TypeMap     *next;
  TypeMap     *previous;                 /* Previously defined typemap (if any) */
  ParmList    *args;                     /* Local variables (if any) */

  TypeMap(char *l, SwigType *t, String_or_char *c, ParmList *p = 0) {
    lang = Swig_copy_string(l);
    type = Copy(t);
    code = NewString(c);
    first = type_id;
    last = INT_MAX;
    next = 0;
    previous = 0;
    if (p) {
      args = CopyParmList(p);
    } else {
      args = 0;
    }
  }
  TypeMap(char *l, String_or_char *c) {
    lang = Swig_copy_string(l);
    type = 0;
    code = NewString(c);
    first = type_id;
    last = INT_MAX;
    next = 0;
    previous = 0;
    args = 0;
  }
  TypeMap(TypeMap *t) {
    lang = Swig_copy_string(t->lang);
    type = Copy(t->type);
    code = Copy(t->code);
    first = type_id;
    last = INT_MAX;
    next = 0;
    previous = t->previous;
    if (args) {
      args = CopyParmList(args);
    } else {
      args = 0;
    }
  }
};

/* Hash tables for storing type-mappings */

static DOH *typemap_hash = 0;

/* Structure for holding "applications of a typemap" */

struct TmMethod {
  String   *name;           /* Typemap name; */
  SwigType *type;       /* Typemap type */
  TmMethod *next;       /* Next method */
  TmMethod(String *n, SwigType *t, TmMethod *m = 0) {
    if (n) name = Copy(n);
    else name = 0;
    if (t) {
      type = Copy(t);
    } else {
      type = 0;
    }
    next = m;
  }
};

/* Hash table for storing applications of a datatype */

static DOH *application_hash = 0;

/* ------------------------------------------------------------------------
 * void typemap_apply(DataType *tm_type, char *tm_name, DataType *type, char *pname)
 *
 * Attempts to apply a typemap given by (tm_type,tm_name) to (type,pname)
 * Called by the %apply directive.
 * ------------------------------------------------------------------------ */

void typemap_apply(SwigType *tm_type, String_or_char *tm_name, SwigType *type, String_or_char *pname) {
  TmMethod *m,*m1;
  String *temp;

  /* Form the application name */
  if (!pname) pname = (String_or_char*)"";
  temp = NewStringf("%s$%s",SwigType_str(type,0),pname);

  /* See if there is a method already defined */

  if (!application_hash) application_hash = NewHash();
  m = (TmMethod *) GetVoid(application_hash,temp);
  
  if (!m) {
    m = new TmMethod(temp,type,0);
    SetVoid(application_hash,temp,m);
  }

  Delete(temp);

  /* Check to see if an array typemap has been applied to a non-array type */

  if ((SwigType_isarray(tm_type)) && (!SwigType_isarray(type))) {
    Printf(stderr,"%s:%d: Warning. Array typemap has been applied to a non-array type.\n",
	    input_file,line_number);
  }

  /* If both are arrays, make sure they have the same dimension  */

  if ((SwigType_isarray(tm_type)) && (SwigType_isarray(type))) {
    if (SwigType_array_ndim(tm_type) != SwigType_array_ndim(type)) {
      Printf(stderr,"%s:%d: Warning. Array types have different number of dimensions.\n",
	      input_file,line_number);
    } else {
      for (int i = 0; i < SwigType_array_ndim(tm_type); i++) {
	String *s1 = SwigType_array_getdim(tm_type,i);
	String *s2 = SwigType_array_getdim(type,i);
	if (Cmp(s1,"") != 0) {
	  if (Cmp(s1,s2))
	    Printf(stderr,"%s:%d: Warning. Array typemap applied to an array of different size.\n",
		    input_file, line_number);
	}
      }
    }
  }

  /* Add a new mapping corresponding to the typemap */
  m1 = new TmMethod(tm_name,tm_type,m->next);
  m->next = m1;
  
}
/* ------------------------------------------------------------------------
 * void typemap_clear_apply(SwigType *type, char *pname)
 *
 * Clears the application of a typemap.
 * Called by the %clear directive.
 * ------------------------------------------------------------------------ */

void typemap_clear_apply(SwigType *type, String_or_char *pname) {
  String *temp;
  if (!pname) pname = (String_or_char*)"";
  temp = NewStringf("%s$%s", SwigType_str(type,0), pname);
  if (!application_hash) application_hash = NewHash();
  Delattr(application_hash,temp);
  Delete(temp);
}

/* ------------------------------------------------------------------------
 * char *typemap_string(char *lang, DataType *type, char *pname, char *suffix)
 *
 * Produces a character string corresponding to a lang, datatype, and
 * method.   This string is used as the key for our typemap hash table.
 * ------------------------------------------------------------------------ */

static String *typemap_string(char *op, char *lang, SwigType *type, String_or_char *pname) {
  String *str;
  str = NewStringf("%s-%s-%s",op,lang,SwigType_str(type,pname));
  /*  Printf(stdout,"key: %s\n", str); */
  return Swig_temp_result(str);
}

/* ------------------------------------------------------------------------
 * void typemap_register(char *op, char *lang, DataType *type, char *pname,
 *                       char *getcode, ParmList *args)
 *
 * Register a new mapping with the type-mapper.  
 * ------------------------------------------------------------------------ */

void typemap_register(char *op, char *lang, SwigType *type, String_or_char *pname, 
                      String_or_char *getcode, ParmList *args) {
  
  String   *key;
  TypeMap  *tm, *tm_old;
  int      is_default = 0;

  if (!typemap_hash) typemap_hash = NewHash();


  tm = new TypeMap(lang,type,getcode,args);
  /* If this is a default typemap, downgrade the type! */

  if (Cmp(pname,"SWIG_DEFAULT_TYPE") == 0) {
    tm->type = SwigType_default(tm->type);
    is_default = 1;
  }

  key = typemap_string(op,lang,tm->type,pname);

  /* Get any previous setting of the typemap */
  tm_old = (TypeMap *) GetVoid(typemap_hash, key);
  if (tm_old) {

    /* Perform a chaining operation, but only if the last typemap is active. */
    /* If found, we need to attach the old version to the new one */

    tm->previous = tm_old;
    tm->next = tm_old;
    tm_old->last = type_id;
  } 

  /* Add new typemap to the hash table */
  SetVoid(typemap_hash,key,tm);

  /* Just a sanity check to make sure args look okay. */
  
  if (args) {
    Parm *p = tm->args;
    while (p) {
      String *pn = Getname(p);
      if (pn) {
	/*	printf("    %s %s\n", pt,pn); */
      } else {
	Printf(stderr,"%s:%d:  Typemap error. Local variables must have a name\n",
		input_file, line_number);
      }
      p = Getnext(p);
    }
  }
}

/* ------------------------------------------------------------------------
 * static TypeMap *typemap_search(char *key, int id) 
 *
 * An internal function for searching for a particular typemap given
 * a key value and datatype id.
 *
 * Basically this checks the hash table and then checks the id against
 * first and last values, looking for a match.   This is to properly
 * handle scoping problems.
 * ------------------------------------------------------------------------ */

static TypeMap *
typemap_search(String_or_char *key, int id) {
  TypeMap *tm;
  if (!typemap_hash) typemap_hash = NewHash();
  tm = (TypeMap *) GetVoid(typemap_hash,key);
  while (tm) {
    if ((id >= tm->first) && (id < tm->last)) return tm;
    else tm = tm->next;
  }
  return tm;
}

/* ------------------------------------------------------------------------
 * TypeMap *typemap_search_array(char *op, char *lang, DataType *type, char *pname, DOHString *str)
 *
 * Performs a typemap lookup on an array type.  This is abit complicated
 * because we need to look for ANY tags specifying that any array dimension
 * is valid.   The resulting code will be placed in str with dimension variables
 * substituted.
 * ------------------------------------------------------------------------ */

static
TypeMap *typemap_search_array(char *op, char *lang, SwigType *type, String_or_char *pname, DOHString *str) {
  SwigType  *atype;
  String    *key;
  int       ndim,i,j,k,n;
  TypeMap   *tm;
  char      temp[10];

  if (!SwigType_isarray(type)) return 0;

  /* First check to see if exactly this array has been mapped */

  key = typemap_string(op,lang,type,pname);
  tm = typemap_search(key,type_id);

  /* Check for unnamed array of specific dimensions */
  if (!tm) {
    key = typemap_string(op,lang,type,(char*)"");
    tm = typemap_search(key,type_id);
  } 

  if (!tm) {
    /* We're going to go search for matches with the ANY tag */
    ndim = SwigType_array_ndim(type);             /* Get number of dimensions */
    j = (1 << ndim) - 1;                          /* Status bits */
    for (i = 0; i < (1 << ndim); i++) {
      /* Form an array string */
      atype = Copy(type);
      k = j;
      for (n = 0; n < ndim; n++) {
	if (!(k & 1)) {
	  SwigType_array_setdim(atype,n,"ANY");
	}
	k = k >> 1;
      }
      key = typemap_string(op,lang,type,pname);
      tm = typemap_search(key,type_id);
      if (!tm) {
	key = typemap_string(op,lang,type,(char*)"");
	tm = typemap_search(key,type_id);
      }
      if (tm) {
	Delete(atype);
	break;
      }
      j--;
    }
    Delete(atype);
  }      
	
  if (tm) {
    Printf(str,"%s",tm->code);
    ndim = SwigType_array_ndim(type);
    sprintf(temp,"%d",ndim);
    Replace(str,"$ndim",temp, DOH_REPLACE_ANY);
    for (i = 0; i < ndim; i++) {
      sprintf(temp,"$dim%d",i);
      Replace(str,temp,SwigType_array_getdim(type,i), DOH_REPLACE_ANY);
    }
  }
  return tm;
}

/* ------------------------------------------------------------------------
 * static typemap_locals(Datatype *t, char *pname, String &s, ParmList *l, Wrapper *f)
 *
 * Takes a string, a parameter list and a wrapper function argument and
 * starts creating local variables.
 *
 * Substitutes locals in the string with actual values used.
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
    p = Getnext(l);
  }
  /* If the original datatype was an array. We're going to go through and substitute
     it's array dimensions */

  if (SwigType_isarray(t)) {
    char temp[10];
    for (int i = 0; i < SwigType_array_ndim(t); i++) {
      sprintf(temp,"$dim%d",i);
      Replace(f->locals,temp,SwigType_array_getdim(t,i), DOH_REPLACE_ANY);
    }
  }
}

/* ------------------------------------------------------------------------
 * char *typemap_lookup(char *op, char *lang, DataType *type, char *pname, char *source,
 *                      char *target, WrapperFunction *f)
 *            
 * Looks up a "get" function in the type-map and returns a character string
 * containing the appropriate translation code.
 *
 * op       is string code for type of mapping
 * lang     is the target language string
 * type     is the datatype
 * pname    is an optional parameter name
 * source   is a string with the source variable
 * target   is a string containing the target value
 * f        is a wrapper function object (optional)
 *
 * Returns NULL if no mapping is found.
 *
 * Typemaps follow a few rules regarding naming and C pointers by checking
 * declarations in this order.
 *
 *         1.   type name []         - A named array (most specific)
 *         2.   type name            - Named argument
 *         3.   type []              - Type with array
 *         4.   type                 - Ordinary type
 * 
 * Array checking is only made if the datatype actally has an array specifier      
 * 
 * Array checking uses a special token "ANY" that indicates that any
 * dimension will match.  Since we are passed a real datatype here, we
 * need to hack this a special case.
 *
 * Array dimensions are substituted into the variables $dim1, $dim2,...,$dim9
 * ------------------------------------------------------------------------ */

static SwigType *realtype;        /* This is a gross hack */
static String   *realname = 0;    /* Real parameter name */

static char *typemap_lookup_internal(char *op, char *lang, SwigType *type, String_or_char *pname,
				     String_or_char *source, String_or_char *target, Wrapper *f) {
  String *str = 0;
  String  *key = 0;
  TypeMap *tm = 0;

  last_args = 0;
  if (!lang) {
    return 0;
  }
  str = NewString("");
  /* First check for named array */
  tm = typemap_search_array(op,lang,type,pname,str);

  /* Check for named argument */
  if (!tm) {
    key = typemap_string(op,lang,type,pname);
    tm = typemap_search(key,type_id);
    if (tm)
      Printf(str,"%s",tm->code);
  }

  /* Check for unnamed type */
  if (!tm) {
    key = typemap_string(op,lang,type,(char*)"");
    tm = typemap_search(key,type_id);
    if (tm)
      Printf(str,"%s", tm->code);
  }
  if (!tm) {
    Delete(str);
    return 0;
  }
  
  /* Now perform character replacements */

  Replace(str,"$source",source,DOH_REPLACE_ANY);
  Replace(str,"$target",target,DOH_REPLACE_ANY);
  Replace(str,"$type",SwigType_str(realtype,0),DOH_REPLACE_ANY);
  if (realname) {
    Replace(str,"$parmname",realname,DOH_REPLACE_ANY);
  } else {
    Replace(str,"$parmname","", DOH_REPLACE_ANY);
  }
  /* Print base type (without any pointers) */
  Replace(str,"$basetype",SwigType_base(realtype), DOH_REPLACE_ANY);
  Replace(str,"$basemangle",SwigType_manglestr(SwigType_base(realtype)), DOH_REPLACE_ANY);
  Replace(str,"$mangle",SwigType_manglestr(realtype), DOH_REPLACE_ANY);

  /* If there were locals and a wrapper function, replace */
  if ((tm->args) && f) {
    typemap_locals(realtype, pname, str,tm->args,f);
  }

  /* Return character string */
  last_args = tm->args;
  Swig_temp_result(str);
  return Char(str);
}

/* ----------------------------------------------------------
 * Real function call that takes care of application mappings
 * ---------------------------------------------------------- */

char *typemap_lookup(char *op, char *lang, SwigType *type, String_or_char *pname, String_or_char *source,
                     String_or_char *target, Wrapper *f) {
  TmMethod *m;
  char *result;
  String *temp;
  String_or_char *ppname;
  char *tstr;

  realtype = type;          /* The other half of the gross hack */
  realname = pname;

  // Printf(stdout,"Looking up %s\n", SwigType_str(type,pname));

  /* Try to apply typemap right away */

  result = typemap_lookup_internal(op,lang,type,pname,source,target,f);

  /* If not found, try to pick up anything that might have been
     specified with %apply */

  if (!result) {
    temp = NewStringf("%s$%s", SwigType_str(type,0), pname);
    m = (TmMethod *) GetVoid(application_hash,temp);
    if (!m) {
      Clear(temp);
      Printf(temp,"%s$",SwigType_str(type,0));
      m = (TmMethod *) GetVoid(application_hash,temp);
    }
    Delete(temp);
    if (m) {
      m = m->next;
      while (m) {
	result = typemap_lookup_internal(op,lang,m->type,m->name,source,target,f);
	if (result) {
	  return result;
	}
	m = m->next;
      }
    }
  }

  /* Still no idea, try to find a default typemap */

  if (!result) {
    SwigType *t = SwigType_default(type);
    result = typemap_lookup_internal(op,lang,t,(char*)"SWIG_DEFAULT_TYPE",source,target,f);
    if (result) {
      Delete(t);
      return result;
    }
    Delete(t);
  }
  return result;
}

/* ----------------------------------------------------------------------------
 * char *typemap_check(char *op, char *lang, SwigType *type, String_or_char *pname)
 *
 * Checks to see if there is a typemap.  Returns typemap string if found, NULL
 * if not.
 * ---------------------------------------------------------------------------- */

char *typemap_check_internal(char *op, char *lang, SwigType *type, String_or_char *pname) {
  DOHString *str = 0;
  String  *key = 0;
  TypeMap *tm = 0;


  if (!lang) {
    return 0;
  }
  str = NewString("");

  /* First check for named array */

  tm = typemap_search_array(op,lang,type,pname,str);

  /* Check for named argument */
  if (!tm) {
    key = typemap_string(op,lang,type,pname);
    tm = typemap_search(key,type_id);
  }

  /* Check for unnamed array */
  if ((!tm) && (SwigType_isarray(type))) {
    key = typemap_string(op,lang,type,(char*)"");
    tm = typemap_search(key,type_id);
  } 

  /* Check for unnamed type */
  if (!tm) {
    key = typemap_string(op,lang,type,(char*)"");
    tm = typemap_search(key,type_id);
  }
  if (!tm) {
    Delete(str);
    return 0;
  }
  Printf(str,"%s",tm->code);
  /* Return character string */
  Swig_temp_result(str);
  return Char(str);
}

/** Function for checking with applications */

char *typemap_check(char *op, char *lang, SwigType *type, String_or_char *pname) {
  TmMethod *m;
  char temp[512];
  char *result;
  char *ppname;
  char *tstr;
  /* Try to apply typemap right away */

  result = typemap_check_internal(op,lang,type,pname);

#ifdef OLD
  if (!result) {
    int drop_pointer = 0;
    ppname = pname;
    if (!ppname) ppname = (char*)"";
    
     /* The idea : We're going to cycle through applications and
	drop pointers off until we get a match.    */

    while (drop_pointer <= (type->_is_pointer - type->_implicit_ptr)) {
      type->_is_pointer -= drop_pointer;
      tstr = DataType_str(type,0);
      sprintf(temp,"%s$%s",tstr,ppname);
      /* No mapping was found.  See if the name has been mapped with %apply */
      if (!application_hash) application_hash = NewHash();
      m = (TmMethod *) GetVoid(application_hash,temp);
      if (!m) {
	sprintf(temp,"%s$",tstr);
	m = (TmMethod *) GetVoid(application_hash,temp);
      }
      if (m) {
	m = m->next;
	while (m) {
	  char *oldary = 0;
	  static DOHString *newarray = 0;
	  if (!newarray) newarray = NewString("");
	  if (*(m->name)) ppname = m->name;
	  else ppname = pname;
	  m->type->_is_pointer += drop_pointer;
	  if (DataType_arraystr(m->type))
	    oldary = Swig_copy_string(DataType_arraystr(m->type));
	  else
	    oldary = 0;

	  /* If the mapping type is an array and has the 'ANY' keyword, we
	     have to play some magic */
	  
	  if ((DataType_arraystr(m->type)) && (DataType_arraystr(type))) {
	    /* Build up the new array string */
	    Clear(newarray);
	    for (int n = 0; n < DataType_array_dimensions(m->type); n++) {
	      char *d = DataType_get_dimension(m->type,n);
	      if (strcmp(d,"ANY") == 0) {
		Printf(newarray,"[%s]", DataType_get_dimension(type,n));
	      } else {
		Printf(newarray,"[%s]", d);
	      }
	    }
	    DataType_set_arraystr(m->type, Char(newarray));
	  } else if (DataType_arraystr(type)) {
	    DataType_set_arraystr(m->type, DataType_arraystr(type));
	  }
	  result = typemap_check_internal(op,lang,m->type,ppname);
	  DataType_set_arraystr(m->type,oldary);
	  if (oldary) free(oldary);
	  m->type->_is_pointer -= drop_pointer;
	  if (result) {
	    type->_is_pointer += drop_pointer;
	    return result;
	  }
	  m = m->next;
	}
      }
      type->_is_pointer += drop_pointer;
      drop_pointer++;
    }
  }
#endif

  /* If still no result, might have a default typemap */
  if (!result) {
    SwigType *t = SwigType_default(type);
    result = typemap_check_internal(op,lang,t,(char*)"SWIG_DEFAULT_TYPE");
    if (result) {
      Delete(t);
      return result;
    }
    Delete(t);
  }
  return result;
}

/* ------------------------------------------------------------------------
 * void typemap_clear(char *op, char *lang, DataType *type, char *pname)
 *
 * Clears any previous typemap.   This works like a stack.  Clearing a
 * typemap returns to any previous typemap in force.   If there is no
 * previous map, then don't worry about it.
 * ------------------------------------------------------------------------ */

void typemap_clear(char *op, char *lang, SwigType *type, String_or_char *pname) {
  
  String   *key;
  TypeMap  *tm;

  key = typemap_string(op,lang,type,pname);

  /* Look for any previous version, simply set the last id if
     applicable. */
  
  if (!typemap_hash) typemap_hash = NewHash();
  tm = (TypeMap *) GetVoid(typemap_hash,key);
  if (tm) {
    if (tm->last > type_id) tm->last = type_id;
  }
}

/* ------------------------------------------------------------------------
 * void typemap_copy(char *op, char *lang, DataType *stype, char *sname,
 *                   DataType *ttype, char *tname)
 *
 * Copies the code associate with a typemap
 * ------------------------------------------------------------------------ */

void typemap_copy(char *op, char *lang, SwigType *stype, String_or_char *sname,
		      SwigType *ttype, String_or_char *tname) {
  
  String   *key;
  TypeMap  *tm, *tk, *tn;

  /* Try to locate a previous typemap */

  key = typemap_string(op,lang,stype,sname);
  tm = typemap_search(key,type_id);
  if (!tm) return;
  typemap_register(op,lang,ttype,tname,tm->code,tm->args);
}

/* ------------------------------------------------------------------------
 * char *fragment_string(char *op, char *lang)
 *
 * Produces a character string corresponding to a language and method
 * This string is used as the key for our typemap hash table.
 * ------------------------------------------------------------------------ */

static char *fragment_string(char *op, char *lang) {
  static char str[512];
  sprintf(str,"fragment:%s%s", lang, op);
  return str;
}

/* ------------------------------------------------------------------------
 * void fragment_register(char *op, char *lang, char *code)
 *
 * Register a code fragment with the type-mapper.
 * ------------------------------------------------------------------------ */

void fragment_register(char *op, char *lang, String_or_char *code) {
  
  char     *key;
  TypeMap  *tm,*tm_old;
  char      temp[256];
  
  tm = new TypeMap(lang,code);
  key = fragment_string(op,lang);

  /* Get any previous setting of the typemap */

  tm_old = (TypeMap *) GetVoid(typemap_hash,key);
  if (tm_old) {
    /* If found, we need to attach the old version to the new one */

    /* Perform a chaining operation  */

    sprintf(temp,"$%s",op);
    if (type_id < tm_old->last)
      Replace(tm->code,temp,tm_old->code,DOH_REPLACE_ANY);

    tm->next = tm_old;
    tm_old->last = type_id;

    /* Remove the old one from the hash */
  
    Delattr(typemap_hash,key);
  }
  
  /* Perform a default chaining operation if needed (defaults to nothing) */
  sprintf(temp,"$%s",op);
  Replace(tm->code,temp,"", DOH_REPLACE_ANY);

  /* Add new typemap to the hash table */
  SetVoid(typemap_hash,key,tm);
}


/* ------------------------------------------------------------------------
 * char *fragment_lookup(char *op, char *lang)
 *
 * op       is string code for type of mapping
 * lang     is the target language string
 *
 * Returns NULL if no mapping is found.
 *
 * ------------------------------------------------------------------------ */

char *fragment_lookup(char *op, char *lang) {
  DOHString *str;
  char *key = 0;
  TypeMap *tm = 0;

  if (!lang) {
    return 0;
  }
  str = NewString("");
  key = fragment_string(op,lang);
  tm = typemap_search(key,type_id);

  if (!tm) return 0;

  Append(str,tm->code);
  Swig_temp_result(str);
  return Char(str);
}

/* ------------------------------------------------------------------------
 * void fragment_clear(char *op, char *lang)
 *
 * Clears any previous fragment definition.   Is a stack operation--will
 * restore any previously declared typemap.
 * ------------------------------------------------------------------------ */

void fragment_clear(char *op, char *lang) {
  
  char     *key;
  TypeMap  *tm;

  key = fragment_string(op,lang);

  /* Look for any previous version, simply set the last id if
     applicable. */
  
  tm = (TypeMap *) GetVoid(typemap_hash,key);
  if (tm) {
    if (tm->last > type_id) tm->last = type_id;
  }
}

/* -----------------------------------------------------------------------------
 * typemap_initialize()
 *
 * Initialize the hash tables
 * ----------------------------------------------------------------------------- */

void
typemap_initialize() {
  typemap_hash = NewHash();
  application_hash = NewHash();
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
    } else if (typemap_check((char*)"default",typemap_lang,pt,pn)) {
      n++;
      state = 1;
    } else if (typemap_check((char*)"ignore",typemap_lang,pt,pn)) {
      n++;
    } else {
      if (state) {
	Printf(stderr,"%s : Line %d.  Argument %d must have a default value!\n", input_file,line_number,i+1);
      }
    }
  }
  return n;
}


/* -----------------------------------------------------------------------------
 * typemap_match_parms()
 *
 * Match typemaps for a list of parameters.  This function is only a hack to
 * ease the migration to the new SWIG typemap system.  Returns a DOH list
 * of hash table objects containing all of the matches.
 * ----------------------------------------------------------------------------- */

DOHList *
typemap_match_parms(ParmList *l) {
  
  DOHList *tl;
  DOHHash *tm;
  Parm    *p;

  char    *s;
  tl = NewList();

  p = l;
  while (p) {
    SwigType *pt = Gettype(p);
    String   *pn = Getname(p);
    ParmList *vars = 0;

    tm = NewHash();

    /* Look up all of the argument related typemaps */
    /* "in"      */
    if ((s = typemap_lookup((char*)"in",typemap_lang,pt,pn,(char *)"$source",(char *)"$target",0))) {
      Setattr(tm,"in",s);
    }

    /* "ignore"  */
    if ((s = typemap_lookup((char*)"ignore",typemap_lang,pt,pn,(char *)"$source",(char *)"$target",0))) {
      Setattr(tm,"ignore",s);
    }

    /* "argout"  */
    if ((s = typemap_lookup((char*)"argout",typemap_lang,pt,pn,(char *)"$source",(char *)"$target",0))) {
      Setattr(tm,"argout",s);
    }

    /* "default" */
    if ((s = typemap_lookup((char*)"default",typemap_lang,pt,pn,(char *)"$source",(char *)"$target",0))) {
      Setattr(tm,"default",s);
    }

    /* "check"   */
    if ((s = typemap_lookup((char*)"check",typemap_lang,pt,pn,(char *)"$source",(char *)"$target",0))) {
      Setattr(tm,"check",s);
    }

    /* "arginit" */
    if ((s = typemap_lookup((char*)"arginit",typemap_lang,pt,pn,(char *)"$source",(char *)"$target",0))) {
      Setattr(tm,"arginit",s);
    }
    Setattr(tm,"locals", vars);
    Append(tl,tm);
    Delete(tm);
    p = Getnext(p);
  }
  return tl;
}




/* -----------------------------------------------------------------------------
 * stype.c
 *
 *     This file provides general support for datatypes that are encoded in
 *     the form of simple strings.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "swig.h"
#include <ctype.h>

/* -----------------------------------------------------------------------------
 * Synopsis
 *
 * The purpose of this module is to provide a general purpose type representation
 * based on simple text strings. 
 *
 * General idea:
 *
 * Types are represented by a base type (e.g., "int") and a collection of
 * type operators applied to the base (e.g., pointers, arrays, etc...).
 *
 * Encoding:
 *
 * Types are encoded as strings of type constructors such as follows:
 *
 *        String Encoding                 C Example
 *        ---------------                 ---------
 *        p.p.int                         int **
 *        a(300).a(400).int               int [300][400]
 *        p.q(const).char                 char const *
 *
 * All type constructors are denoted by a trailing '.':
 * 
 *  'p.'                = Pointer (*)
 *  'r.'                = Reference (&)
 *  'a(n).'             = Array of size n  [n]
 *  'f(..,..).'         = Function with arguments  (args)
 *  'q(str).'           = Qualifier (such as const or volatile) (const, volatile)
 *  'm(qual).'          = Pointer to member (qual::*)
 *
 * The encoding follows the order that you might describe a type in words.
 * For example "p.a(200).int" is "A pointer to array of int's" and
 * "p.q(const).char" is "a pointer to a const char".
 *
 * This representation of types is fairly convenient because ordinary string
 * operations can be used for type manipulation. For example, a type could be
 * formed by combining two strings such as the following:
 *
 *        "p.p." + "a(400).int" = "p.p.a(400).int"
 *
 * Similarly, one could strip a 'const' declaration from a type doing something
 * like this:
 *
 *        Replace(t,"q(const).","",DOH_REPLACE_ANY)
 *
 * For the most part, this module tries to minimize the use of special
 * characters (*, [, <, etc...) in its type encoding.  One reason for this
 * is that SWIG might be extended to encode data in formats such as XML
 * where you might want to do this:
 * 
 *      <function>
 *         <type>p.p.int</type>
 *         ...
 *      </function>
 *
 * Or alternatively,
 *
 *      <function type="p.p.int" ...>blah</function>
 *
 * In either case, it's probably best to avoid characters such as '&', '*', or '<'.
 *
 * Why not use C syntax?  Well, C syntax is fairly complicated to parse
 * and not particularly easy to manipulate---especially for adding, deleting and
 * composing type constructors.  The string representation presented here makes
 * this pretty easy.
 *
 * Why not use a bunch of nested data structures?  Are you kidding? How
 * would that be easier to use than a few simple string operations? 
 * ----------------------------------------------------------------------------- */


SwigType *NewSwigType(int t) {
  switch(t) {
  case T_BOOL:
    return NewString("bool");
    break;
  case T_INT:
    return NewString("int");
    break;
  case T_UINT:
    return NewString("unsigned int");
    break;
  case T_SHORT:
    return NewString("short");
    break;
  case T_USHORT:
    return NewString("unsigned short");
    break;
  case T_LONG: 
    return NewString("long");
    break;
  case T_ULONG:
    return NewString("unsigned long");
    break;
  case T_FLOAT:
    return NewString("float");
    break;
  case T_DOUBLE:
    return NewString("double");
    break;
  case T_CHAR:
    return NewString("char");
    break;
  case T_SCHAR:
    return NewString("signed char");
    break;
  case T_UCHAR:
    return NewString("unsigned char");
    break;
  case T_STRING: {
    SwigType *t = NewString("char");
    SwigType_add_pointer(t);
    return t;
    break;
  }
  case T_VOID:
    return NewString("void");
    break;
  default :
    return NewString("");
    break;
  }
}

/* -----------------------------------------------------------------------------
 * SwigType_add_pointer()
 *
 * Adds a pointer constructor to a type
 * ----------------------------------------------------------------------------- */

void
SwigType_add_pointer(SwigType *t) {
  Insert(t,0,"p.");
}

void 
SwigType_del_pointer(SwigType *t) {
  char *c = Char(t);
  if (strncmp(c,"q(",2) == 0) {
    Delete(SwigType_pop(t));
    c = Char(t);
  }
  if (strncmp(c,"p.",2)) {
    printf("Fatal error. SwigType_del_pointer applied to non-pointer.\n");
    abort();
  }
  Replace(t,"p.","", DOH_REPLACE_ANY | DOH_REPLACE_FIRST);
}

/* -----------------------------------------------------------------------------
 * SwigType_add_memberpointer()
 * 
 * Add a pointer to a member to a type
 * ----------------------------------------------------------------------------- */

void
SwigType_add_memberpointer(SwigType *t, String_or_char *name) {
  String *temp = NewStringf("m(%s).", name);
  Insert(t,0,temp);
  Delete(temp);
}

/* -----------------------------------------------------------------------------
 * SwigType_add_array()
 *
 * Adds an array constructor to a type
 * ----------------------------------------------------------------------------- */

void
SwigType_add_array(SwigType *t, String *size) {
  char temp[256];
  sprintf(temp,"a(%s).", Char(size));
  Insert(t,0,temp);
}

/* -----------------------------------------------------------------------------
 * SwigType_pop_arrays()
 *
 * Pop all arrays off as a single item
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_pop_arrays(SwigType *t) {
  String *ta;
  if (!SwigType_isarray(t)) return 0;
  ta = NewString("");
  while (SwigType_isarray(t)) {
    SwigType *td = SwigType_pop(t);
    Append(ta,td);
    Delete(td);
  }
  return ta;
}

/* -----------------------------------------------------------------------------
 * SwigType_add_reference()
 *
 * Adds a reference constructor to a type.
 * ----------------------------------------------------------------------------- */

void
SwigType_add_reference(SwigType *t) {
  Insert(t,0,"r.");
}

/* -----------------------------------------------------------------------------
 * SwigType_add_qualifier()
 *
 * Adds a qualifier to a type
 * ----------------------------------------------------------------------------- */

void
SwigType_add_qualifier(SwigType *t, String *qual) {
  char temp[256];
  if (!SwigType_isqualifier(t)) {
    sprintf(temp,"q(%s).",Char(qual));
    Insert(t,0,temp);
  } else {
    /* Already has a qualifier on it.   We are going to generate a 
       canonical qualifier string */
    String *qt;
    char   *c, *qc;
    String *newq;
    
    qt = SwigType_pop(t);          /* Rip off the old qualifier */
    /* See if the added qualifier is already there */
    if (strstr(Char(qt),Char(qual))) {
      /* Already added this qualifier */
      SwigType_push(t,qt);
      Delete(qt);
      return;
    }
    /* We need to add the qualifier to the qualifier list */
    /* To do this, we keep the qualifiers in alphabetical order */
    newq = NewString("q(");
    qc = Char(qual);
    c = Char(qt)+2;
    c = strtok(c," ).");
    while (c) {
      if (!strlen(c)) {
	c = strtok(NULL," ).");
	continue;
      }
      if (qc) {
	if (strcmp(c,qc) < 0) {
	  Printf(newq,"%s",c);
	} else {
	  Printf(newq,"%s %s", qc,c);
	  qc = 0;
	}
      } else {
	Printf(newq,"%s",c);
      }
      c = strtok(NULL," ).");
      if (c) Putc(' ',newq);
    }
    if (qc) {
      Printf(newq," %s",qc);
    }
    Putc(')',newq);
    Putc('.',newq);
    SwigType_push(t,newq);
    Delete(newq);
    Delete(qt);
  }
}

/* -----------------------------------------------------------------------------
 * SwigType_add_function()
 *
 * Adds a function to a type. Accepts a list of abstract types as parameters.
 * These abstract types should be passed as a list of type-strings.
 * ----------------------------------------------------------------------------- */

void
SwigType_add_function(SwigType *t, ParmList *parms) {
  String *pstr;
  Parm   *p;

  Insert(t,0,").");
  pstr = NewString("f(");
  p = parms;
  for (p = parms; p; p = nextSibling(p)) {
    if (p != parms) Putc(',',pstr);
    Printf(pstr,"%s", Getattr(p,"type"));
  }
  Insert(t,0,pstr);
  Delete(pstr);
}

SwigType *
SwigType_pop_function(SwigType *t) {
  SwigType *f = 0;
  SwigType *g = 0;
  char *c = Char(t);
  if (strncmp(c,"q(",2) == 0) {
    f = SwigType_pop(t);
    c = Char(t);
  }
  if (strncmp(c,"f(",2)) {
    printf("Fatal error. SwigType_pop_function applied to non-function.\n");
    abort();
  }
  g = SwigType_pop(t);
  if (f) SwigType_push(g,f);
  Delete(f);
  return g;
}

ParmList *
SwigType_function_parms(SwigType *t) {
  List *l = SwigType_parmlist(t);
  Hash *p, *pp = 0, *firstp = 0;
  DOH  *obj;
  for (obj = Firstitem(l); obj; obj = Nextitem(l)) {
    p = NewParm(obj,0);
    if (!firstp) firstp = p;
    if (pp) {
      set_nextSibling(pp,p);
    }
    pp = p;
  }
  Delete(l);
  return firstp;
}

/* -----------------------------------------------------------------------------
 * static isolate_element()
 *
 * Isolate a single element of a type string (delimeted by periods)
 * ----------------------------------------------------------------------------- */

static String *
isolate_element(char *c) {
  String *result = NewString("");
  while (*c) {
    if (*c == '.') {
      Putc(*c,result);
      return result;
    }
    else if (*c == '(') {
      int nparen = 1;
      Putc(*c,result);
      c++;
      while(*c) {
	Putc(*c,result);
	if (*c == '(') nparen++;
	if (*c == ')') {
	  nparen--;
	  if (nparen == 0) break;
	}
	c++;
      }
    } else {
      Putc(*c,result);
    }
    if (*c) c++;
  }
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_split()
 *
 * Splits a type into it's component parts and returns a list of string.
 * ----------------------------------------------------------------------------- */

List *SwigType_split(SwigType *t) {
  DOH     *item;
  List *list;
  char *c;
  int len;

  c = Char(t);
  list = NewList();
  while (*c) {
    item = isolate_element(c);
    len = Len(item);
    if (len) {
      Append(list,item);
      Delete(item);
    } else {
      Delete(item);
      break;
    }
    c = c + len;
    if (*c == '.') c++;
  }
  return list;
}

/* -----------------------------------------------------------------------------
 * SwigType_pop()
 *
 * Pop off the first type-constructor object and updates the type
 * ----------------------------------------------------------------------------- */

String *SwigType_pop(SwigType *t)
{
  String *result;
  char      *c;

  if (Len(t) == 0) return 0;
  c = Char(t);
  result = isolate_element(c);
  Replace(t,result,"",DOH_REPLACE_ANY | DOH_REPLACE_FIRST);
  c = Char(t);
  if (*c == '.') {
    Delitem(t,0);
  }
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_push()
 *
 * Push a type constructor onto the type
 * ----------------------------------------------------------------------------- */

void SwigType_push(SwigType *t, String *cons)
{
  if (!cons) return;
  if (!Len(cons)) return;
  if (Len(t)) {
    char *c = Char(cons);
    if (c[strlen(c)-1] != '.')
      Insert(t,0,".");
  }
  Insert(t,0,cons);
}

/* -----------------------------------------------------------------------------
 * SwigType_parmlist()
 *
 * Splits a comma separated list of components into strings.
 * ----------------------------------------------------------------------------- */

List *SwigType_parmlist(String *p) {
  DOH     *item;
  List *list;
  char *c;

  c = Char(p);
  while (*c && (*c != '(') && (*c != '.')) c++;
  if (!*c || (*c == '.')) return 0;
  c++;
  list = NewList();
  item = NewString("");
  while (*c) {
    if (*c == ',') {
      Append(list,item);
      Delete(item);
      item = NewString("");
    } else if (*c == '(') {
      int nparens = 1;
      Putc(*c,item);
      c++;
      while (*c) {
	Putc(*c,item);
	if (*c == '(') nparens++;
	if (*c == ')') {
	  nparens--;
	  if (nparens == 0) break;
	}
	c++;
      }
    } else if (*c == ')') {
      break;
    } else {
      Putc(*c,item);
    }
    if (*c)
      c++;
  }
  Append(list,item);
  Delete(item);
  return list;
}

/* -----------------------------------------------------------------------------
 * SwigType_parm()
 *
 * Returns the parameter of an operator as a string
 * ----------------------------------------------------------------------------- */

String *SwigType_parm(SwigType *t) {
  String *result;
  char *c;
  int  nparens = 0;

  c = Char(t);
  while (*c && (*c != '(') && (*c != '.')) c++;
  if (!*c || (*c == '.')) return 0;
  c++;
  result = NewString("");
  while (*c) {
    if (*c == ')') {
      if (nparens == 0) return result;
      nparens--;
    } else if (*c == '(') {
      nparens++;
    }
    Putc(*c,result);
    c++;
  }
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_ispointer()
 * SwigType_isarray()
 * SwigType_isreference()
 * SwigType_isfunction()
 * SwigType_isqualifier()
 *
 * Testing functions for querying a datatype
 * ----------------------------------------------------------------------------- */

int SwigType_ispointer(SwigType *t) {
  char *c;
  if (!t) return 0;
  c = Char(t);
  if (strncmp(c,"q(",2) == 0) {
    c = strchr(c,'.');
    if (!c) return 0;
    c++;
  }
  if (strncmp(c,"p.",2) == 0) {
    return 1;
  }
  return 0;
}

int SwigType_ismemberpointer(SwigType *t) {
  char *c;
  if (!t) return 0;
  c = Char(t);
  if (strncmp(c,"m(",2) == 0) {
    return 1;
  }
  return 0;
}

int SwigType_isreference(SwigType *t) {
  char *c;
  if (!t) return 0;
  c = Char(t);
  if (strncmp(c,"r.",2) == 0) {
    return 1;
  }
  return 0;
}

int SwigType_isarray(SwigType *t) {
  char *c;
  if (!t) return 0;
  c = Char(t);
  if (strncmp(c,"a(",2) == 0) {
    return 1;
  }
  return 0;
}

int SwigType_isfunction(SwigType *t) {
  char *c;
  if (!t) {
    return 0;
  }
  c = Char(t);
  if (strncmp(c,"q(",2) == 0) {
    /* Might be a 'const' function.  Try to skip over the 'const' */
    c = strchr(c,'.');
    if (c) c++;
    else return 0;
  }
  if (strncmp(c,"f(",2) == 0) {
    return 1;
  }
  return 0;
}

int SwigType_isqualifier(SwigType *t) {
  char *c;
  if (!t) return 0;
  c = Char(t);
  if (strncmp(c,"q(",2) == 0) {
    return 1;
  }
  return 0;
}

int SwigType_isconst(SwigType *t) {
  char *c;
  if (!t) return 0;
  c = Char(t);
  if (strncmp(c,"q(",2) == 0) {
    String *q = SwigType_parm(t);
    if (strstr(Char(q),"const")) {
      Delete(q);
      return 1;
    }
    Delete(q);
  }
  /* Hmmm. Might be const through a typedef */
  if (SwigType_issimple(t)) {
    int ret;
    SwigType *td = SwigType_typedef_resolve(t);
    if (td) {
      ret = SwigType_isconst(td);
      Delete(td);
      return ret;
    }
  }
  return 0;
}

int SwigType_isenum(SwigType *t) {
  char *c = Char(t);
  if (!t) return 0;
  if (strncmp(c,"enum ",5) == 0) {
    return 1;
  }
  return 0;
}

int SwigType_issimple(SwigType *t) {
  char *c = Char(t);
  if (!t) return 0;
  if (strchr(c,'.')) return 0;
  return 1;
}

/* -----------------------------------------------------------------------------
 * SwigType_base()
 *
 * Returns the base name of a datatype.
 * ----------------------------------------------------------------------------- */

SwigType *SwigType_base(SwigType *t) {
  char *c, *d;

  c = Char(t);
  d = c + strlen(c);
  while (d > c) {
    d--;
    if (*d == '.') return NewString(d+1);
  }
  return NewString(c);
}

/* -----------------------------------------------------------------------------
 * SwigType_prefix()
 *
 * Returns the prefix of a datatype
 * ----------------------------------------------------------------------------- */

String *SwigType_prefix(SwigType *t) {
  char *c, *d;
  String *r = 0;

  c = Char(t);
  d = c + strlen(c);
  while (d > c) {
    d--;
    if (*d == '.') {
      char t = *(d+1);
      *(d+1) = 0;
      r = NewString(c);
      *(d+1) = t;
      return r;
    }
  }
  return NewString("");
}

/* -----------------------------------------------------------------------------
 * SwigType_strip_qualifiers()
 * 
 * Strip all qualifiers from a type and return a new type
 * ----------------------------------------------------------------------------- */

static Hash *memoize_stripped = 0;

SwigType *
SwigType_strip_qualifiers(SwigType *t) {
  SwigType *r;
  List *l;
  SwigType *e;
  if (!memoize_stripped) memoize_stripped = NewHash();
  r = Getattr(memoize_stripped,t);
  if (r) return Copy(r);
  
  l = SwigType_split(t);
  r = NewString("");
  for (e = Firstitem(l); e; e = Nextitem(l)) {
    if (SwigType_isqualifier(e)) continue;
    Append(r,e);
  }
  Setattr(memoize_stripped,Copy(t),Copy(r));
  return r;
}

/* -----------------------------------------------------------------------------
 * SwigType_array_ndim()
 *
 * Returns the number of dimensions of an array.
 * ----------------------------------------------------------------------------- */

int SwigType_array_ndim(SwigType *t) {
  int ndim = 0;
  char *c = Char(t);

  while (c && (strncmp(c,"a(",2) == 0)) {
    c = strchr(c,'.');
    c++;
    ndim++;
  }
  return ndim;
}

/* -----------------------------------------------------------------------------
 * SwigType_array_getdim()
 *
 * Get the value of the nth dimension.
 * ----------------------------------------------------------------------------- */

String *SwigType_array_getdim(SwigType *t, int n) {
  char *c = Char(t);
  while (c && (strncmp(c,"a(",2) == 0) && (n > 0)) {
    c = strchr(c,'.');
    c++;
    n--;
  }
  if (n == 0) return SwigType_parm(c);
  return 0;
}

/* -----------------------------------------------------------------------------
 * SwigType_array_setdim()
 *
 * Replace the nth dimension of an array to a new value.
 * ----------------------------------------------------------------------------- */

void SwigType_array_setdim(SwigType *t, int n, String_or_char *rep) {
  String *result = 0;
  char temp;
  char *start;
  char *c = Char(t);

  start = c;
  if (strncmp(c,"a(",2)) abort;

  while (c && (strncmp(c,"a(",2) == 0) && (n > 0)) {
    c = strchr(c,'.');
    c++;
    n--;
  }
  if (n == 0) {
    temp = *c;
    *c = 0;
    result = NewString(start);
    Printf(result,"a(%s)",rep);
    *c = temp;
    c = strchr(c,'.');
    Append(result,c);
  }
  Clear(t);
  Append(t,result);
  Delete(result);
}

/* -----------------------------------------------------------------------------
 * SwigType_array_type()
 *
 * Return the base type of an array
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_array_type(SwigType *ty) {
  SwigType *t;
  t = Copy(ty);
  while (SwigType_isarray(t)) {
    Delete(SwigType_pop(t));
  }
  return t;
}

/* -----------------------------------------------------------------------------
 * SwigType_default()
 *
 * Create the default string for this datatype.   This takes a type and strips it
 * down to its most primitive form--resolving all typedefs and removing operators.
 *
 * Rules:
 *     Pointers:      p.SWIGTYPE
 *     References:    r.SWIGTYPE
 *     Arrays:        a().SWIGTYPE
 *     Types:         SWIGTYPE
 *     MemberPointer: m(CLASS).SWIGTYPE
 *     Enums:         enum SWIGENUM
 * ----------------------------------------------------------------------------- */

static Hash *default_cache = 0;

SwigType *SwigType_default(SwigType *t) {
  String *r1, *def;
  String *r = 0;

  if (!default_cache) default_cache = NewHash();
  
  r = Getattr(default_cache,t);
  if (r) return Copy(r);
  
  r = t;
  while ((r1 = SwigType_typedef_resolve(r))) {
    if (r != t) Delete(r);
    r = r1;
  }
  if (SwigType_isqualifier(r)) {
    if (r == t) r = Copy(t);
    do {
      Delete(SwigType_pop(r));
    } while (SwigType_isqualifier(r));
  }
  if (SwigType_ispointer(r)) {
    def = NewString("p.SWIGTYPE");
  } else if (SwigType_isreference(r)) {
    def = NewString("r.SWIGTYPE");
  } else if (SwigType_isarray(r)) {
    def = NewString("a().SWIGTYPE");
  } else if (SwigType_ismemberpointer(r)) {
    def = NewString("m(CLASS).SWIGTYPE");
  } else if (SwigType_isenum(r)) {
    def = NewString("enum SWIGTYPE");
  } else {
    def = NewString("SWIGTYPE");
  }
  if (r != t) Delete(r);
  Setattr(default_cache,t,Copy(def));
  return def;
}

/* -----------------------------------------------------------------------------
 * SwigType_str(DOH *s, DOH *id)
 *
 * Create a C string representation of a datatype.
 * ----------------------------------------------------------------------------- */

String *
SwigType_str(SwigType *s, const String_or_char *id)
{
  String *result;
  String *element = 0, *nextelement;
  List *elements;
  int nelements, i;

  if (id) {
    result = NewString(Char(id));
  } else {
    result = NewString("");
  }

  elements = SwigType_split(s);
  nelements = Len(elements);

  if (nelements > 0) {
    element = Getitem(elements,0);
  }
  /* Now, walk the type list and start emitting */
  for (i = 0; i < nelements; i++) {
    if (i < (nelements - 1)) {
      nextelement = Getitem(elements,i+1);
    } else {
      nextelement = 0;
    }
    if (SwigType_isqualifier(element)) {
      DOH *q = 0;
      q = SwigType_parm(element);
      Insert(result,0," ");
      Insert(result,0,q);
      Delete(q);
    } else if (SwigType_ispointer(element)) {
      Insert(result,0,"*");
      if ((nextelement) && ((SwigType_isfunction(nextelement) || (SwigType_isarray(nextelement))))) {
	Insert(result,0,"(");
	Append(result,")");
      }
    } else if (SwigType_ismemberpointer(element)) {
      String *q;
      q = SwigType_parm(element);
      Insert(result,0,"::*");
      Insert(result,0,q);
      if ((nextelement) && ((SwigType_isfunction(nextelement) || (SwigType_isarray(nextelement))))) {
	Insert(result,0,"(");
	Append(result,")");
      }
      Delete(q);
    }
    else if (SwigType_isreference(element)) Insert(result,0,"&");
    else if (SwigType_isarray(element)) {
      DOH *size;
      Append(result,"[");
      size = SwigType_parm(element);
      Append(result,size);
      Append(result,"]");
      Delete(size);
    } else if (SwigType_isfunction(element)) {
      DOH *parms, *p;
      int j, plen;
      Append(result,"(");
      parms = SwigType_parmlist(element);
      plen = Len(parms);
      for (j = 0; j < plen; j++) {
	p = SwigType_str(Getitem(parms,j),0);
	Append(result,p);
	if (j < (plen-1)) Append(result,",");
      }
      Append(result,")");
      Delete(parms);
    } else {
      Insert(result,0," ");
      Insert(result,0,element);
    }
    element = nextelement;
  }
  Delete(elements);
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_ltype(SwigType *ty)
 *
 * Create a locally assignable type
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_ltype(SwigType *s) {
  String *result,*result_qualified;
  String *element;
  SwigType *td, *tc = 0;
  List *elements;
  int nelements, i;
  int firstarray = 1;

  result = NewString("");
  tc = Copy(s);
  /* Nuke all leading qualifiers */
  while (SwigType_isqualifier(tc)) {
    Delete(SwigType_pop(tc));
  }
  if (SwigType_issimple(tc)) {
    /* Resolve any typedef definitions */
    td = SwigType_typedef_resolve(tc);
    if (td && (SwigType_isconst(td) || SwigType_isarray(td) || SwigType_isenum(td))) {
      /* We need to use the typedef type */
      Delete(tc);
      tc = td;
    } else if (td) {
      Delete(td);
    }
  }
  elements = SwigType_split(tc);
  nelements = Len(elements);
  /* Now, walk the type list and start emitting */
  for (i = 0; i < nelements; i++) {
    element = Getitem(elements,i);
    if (SwigType_isqualifier(element)) {
      /* Do nothing. Ignore */
    } else if (SwigType_ispointer(element)) {
      Append(result,element);
      firstarray = 0;
    } else if (SwigType_ismemberpointer(element)) {
      Append(result,element);
      firstarray = 0;
    } else if (SwigType_isreference(element)) {
      Append(result,"p.");
      firstarray = 0;
    } else if (SwigType_isarray(element) && firstarray) {
      Append(result,"p.");
      firstarray = 0;
    } else if (SwigType_isenum(element)) {
      Append(result,"int");
    } else {
      Append(result,element);
    }
  }
  Delete(elements);
  Delete(tc);
  result_qualified = SwigType_typedef_qualified(result);
  Delete(result);
  /*  Printf(stdout,"ltype(%s) --> %s\n", s, result_qualified); */
  return result_qualified;
}

/* -----------------------------------------------------------------------------
 * SwigType_lstr(DOH *s, DOH *id)
 *
 * Produces a type-string that is suitable as a lvalue in an expression.
 * That is, a type that can be freely assigned a value without violating
 * any C assignment rules.
 *
 *      -   Qualifiers such as 'const' and 'volatile' are stripped.
 *      -   Arrays are converted into a *single* pointer (i.e.,
 *          double [][] becomes double *).
 *      -   References are converted into a pointer.
 *      -   Typedef names that refer to read-only types will be replaced
 *          with an equivalent assignable version.
 * -------------------------------------------------------------------- */

String *
SwigType_lstr(SwigType *s, const String_or_char *id)
{
  String *result;
  SwigType  *tc;

  tc = SwigType_ltype(s);
  result = SwigType_str(tc,id);
  Delete(tc);
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_rcaststr()
 *
 * Produces a casting string that maps the type returned by lstr() to the real 
 * datatype printed by str().
 * ----------------------------------------------------------------------------- */

String *SwigType_rcaststr(SwigType *s, const String_or_char *name) {
  String *result, *cast;
  String *element = 0, *nextelement;
  SwigType *td, *rs, *tc = 0;
  List *elements;
  int      nelements, i;
  int      clear = 1;
  int      firstarray = 1;

  result = NewString("");

  if (SwigType_isconst(s)) {
    tc = Copy(s);
    Delete(SwigType_pop(tc));
    rs = tc;
  } else {
    rs = s;
  }

  if (SwigType_issimple(rs)) {
    td = SwigType_typedef_resolve(rs);
    if ((td) && (SwigType_isconst(td) || SwigType_isarray(td))) {
      elements = SwigType_split(td);
    } else if (td && SwigType_isenum(td)) {
      elements = SwigType_split(rs);
      clear = 0;
    } else {
      elements = SwigType_split(rs);
    } 
    if (td) Delete(td);
  } else {
    elements = SwigType_split(rs);
  }
  nelements = Len(elements);
  if (nelements > 0) {
    element = Getitem(elements,0);
  }
  /* Now, walk the type list and start emitting */
  for (i = 0; i < nelements; i++) {
    if (i < (nelements - 1)) {
      nextelement = Getitem(elements,i+1);
    } else {
      nextelement = 0;
    }
    if (SwigType_isqualifier(element)) {
      DOH *q = 0;
      q = SwigType_parm(element);
      Insert(result,0," ");
      Insert(result,0,q);
      Delete(q);
      clear = 0;
    } else if (SwigType_ispointer(element)) {
      Insert(result,0,"*");
      if ((nextelement) && ((SwigType_isfunction(nextelement) || (SwigType_isarray(nextelement))))) {
	Insert(result,0,"(");
	Append(result,")");
      }
      firstarray = 0;
    } else  if (SwigType_ismemberpointer(element)) {
      String *q;
      Insert(result,0,"::*");
      q = SwigType_parm(element);
      Insert(result,0,q);
      Delete(q);
      if ((nextelement) && ((SwigType_isfunction(nextelement) || (SwigType_isarray(nextelement))))) {
	Insert(result,0,"(");
	Append(result,")");
      }
      firstarray = 0;
    } else if (SwigType_isreference(element)) {
      Insert(result,0,"&");
    } else if (SwigType_isarray(element)) {
      DOH *size;
      if (firstarray) {
	Append(result,"(*)");
	firstarray = 0;
      } else {
	Append(result,"[");
	size = SwigType_parm(element);
	Append(result,size);
	Append(result,"]");
	Delete(size);
	clear = 0;
      }
    } else if (SwigType_isfunction(element)) {
      DOH *parms, *p;
      int j, plen;
      Append(result,"(");
      parms = SwigType_parmlist(element);
      plen = Len(parms);
      for (j = 0; j < plen; j++) {
	p = SwigType_str(Getitem(parms,j),0);
	Append(result,p);
	if (j < (plen-1)) Append(result,",");
      }
      Append(result,")");
      Delete(parms);
    } else if (SwigType_isenum(element)) {
      Insert(result,0,element);
      clear = 0;
    } else {
      SwigType *q;
      Insert(result,0," ");
      q = SwigType_typedef_qualified(element);
      Insert(result,0,q);
      Delete(q);
    }
    element = nextelement;
  }
  Delete(elements);
  if (clear) {
    cast = NewString("");
  } else {
    cast = NewStringf("(%s)",result);
  }
  if (name) {
    if (SwigType_isreference(s)) {
      Append(cast,"*");
    }
    Append(cast,name);
  }
  Delete(result);
  Delete(tc);
  return cast;
}


/* -----------------------------------------------------------------------------
 * SwigType_lcaststr()
 *
 * Casts a variable from the real type to the local datatype.
 * ----------------------------------------------------------------------------- */

String *SwigType_lcaststr(SwigType *s, const String_or_char *name) {
  String *result;

  result = NewString("");

  if (SwigType_isarray(s)) {
    Printf(result,"(%s)%s", SwigType_lstr(s,0),name);
  } else if (SwigType_isreference(s)) {
    Printf(result,"(%s)", SwigType_lstr(s,0));
    if (name) 
      Printf(result,"&%s", name);
  } else if (SwigType_isqualifier(s)) {
    Printf(result,"(%s)%s", SwigType_lstr(s,0),name);
  } else {
    if (name)
      Append(result,name);
  }
  return result;
}

String *SwigType_manglestr_default(SwigType *s) {
  char *c;
  String *result;

  result = SwigType_ltype(s);

  Replace(result,"struct ","", DOH_REPLACE_ANY);     /* This might be problematic */
  Replace(result,"class ","", DOH_REPLACE_ANY);
  Replace(result,"union ","", DOH_REPLACE_ANY);
  c = Char(result);
  while (*c) {
    if (*c == '<') *c = 'T';
    else if (*c == '>') *c = 't';
    else if (!isalnum((int)*c)) *c = '_';
    c++;
  }
  Insert(result,0,"_");
  return result;
}

String *SwigType_manglestr(SwigType *s) {
  return SwigType_manglestr_default(s);
}

/* -----------------------------------------------------------------------------
 * Scope handling
 *
 * These functions are used to manipulate typedefs and scopes.
 * ----------------------------------------------------------------------------- */

#define MAX_SCOPE 8

static Hash   *type_scopes = 0;              /* Hash table of scope names           */
static Hash   *scopes[MAX_SCOPE];            /* List representing the current scope */
static String *scopenames[MAX_SCOPE];        /* Names of the various scopes         */
static int      scope_level = 0;

static void init_scopes() {
  if (type_scopes) return;
  type_scopes = NewHash();
  scopes[scope_level] = NewHash();
  scopenames[scope_level] = NewString("");
  Setattr(type_scopes,"::",scopes[scope_level]);
}

/* -----------------------------------------------------------------------------
 * SwigType_typedef()
 *
 * Defines a new typedef. Returns -1 if the type name is already defined.
 * ----------------------------------------------------------------------------- */

int SwigType_typedef(SwigType *type, String_or_char *name) {
  int level;
  String *tdname;

  init_scopes();
  if (Getattr(scopes[scope_level],name)) return -1;
  if (Cmp(type,name) == 0) {
    return 0;
  }
  level = scope_level;
  tdname = NewString(name);
  while (level >= 0) {
    Setattr(scopes[level],Copy(tdname),type);
    if (Len(scopenames[level])) {
      Insert(tdname,0,"::");
      Insert(tdname,0,scopenames[level]);
    } else {
      break;
    }
    level--;
  }
  if (default_cache)
    Delattr(default_cache,type);
  return 0;
}

/* -----------------------------------------------------------------------------
 * SwigType_new_scope()
 *
 * Creates a new scope
 * ----------------------------------------------------------------------------- */

void SwigType_new_scope() {
  init_scopes();
  scope_level++;
  scopes[scope_level] = NewHash();
  scopenames[scope_level] = NewString("");
}

/* -----------------------------------------------------------------------------
 * SwigType_reset_scopes()
 *
 * Reset the scope system
 * ----------------------------------------------------------------------------- */

void SwigType_reset_scopes() {
  Delete(type_scopes);
  type_scopes = 0;
  init_scopes();
}

/* -----------------------------------------------------------------------------
 * SwigType_set_scope_name()
 *
 * Set the name of the current scope.  Note: this will create an entry in the
 * type_scopes hash.
 * ----------------------------------------------------------------------------- */

void SwigType_set_scope_name(String_or_char *name) {
  String *key;
  int i;
  init_scopes();
  scopenames[scope_level] = NewString(Char(name));
  key = NewString("");
  for (i = 1; i <= scope_level; i++) {
    Append(key,scopenames[scope_level]);
    if (i < scope_level) Append(key,"::");
  }
  Setattr(type_scopes,key,scopes[scope_level]);
}

/* -----------------------------------------------------------------------------
 * SwigType_merge_scope()
 *
 * Merges the contents of one scope into the current scope.
 * ----------------------------------------------------------------------------- */

void SwigType_merge_scope(Hash *scope) {
  String *key;
  String *type;

  init_scopes();
  key = Firstkey(scope);
  while (key) {
    type = Getattr(scope,key);
    SwigType_typedef(type,key);
    key = Nextkey(scope);
  }
}

/* -----------------------------------------------------------------------------
 * SwigType_pop_scope()
 *
 * Pop off the last scope and perform a merge operation.  Returns the hash
 * table for the scope that was popped off.
 * ----------------------------------------------------------------------------- */

Hash *SwigType_pop_scope() {
  Hash *s;
  init_scopes();
  if (scope_level == 0) return 0;
  s = scopes[scope_level--];
  return s;
}

/* ----------------------------------------------------------------------------- 
 * SwigType_typedef_resolve()
 *
 * Resolves a typedef and returns a new type string.  Returns 0 if there is no
 * typedef mapping.
 * ----------------------------------------------------------------------------- */

SwigType *SwigType_typedef_resolve(SwigType *t) {
  String *base;
  String *type = 0;
  String *r;
  int level;

  init_scopes();
  base = SwigType_base(t);

  level = scope_level;
  while (level >= 0) {
    /* See if we know about this type */
    type = Getattr(scopes[level],base);
    if (type) break;
    level--;
  }
  Delete(base);
  if (level < 0) {
    return 0;
  }
  r = SwigType_prefix(t);
  Append(r,type);
  return r;
}

/* -----------------------------------------------------------------------------
 * SwigType_typedef_resolve_all()
 *
 * Fully resolve a type down to its most basic datatype
 * ----------------------------------------------------------------------------- */

SwigType *SwigType_typedef_resolve_all(SwigType *t) {
  SwigType *n;
  SwigType *r = Copy(t);
  
  while ((n = SwigType_typedef_resolve(r))) {
    Delete(r);
    r = n;
  }
  return r;
}

/* -----------------------------------------------------------------------------
 * SwigType_typedef_qualified()
 *
 * Given a type declaration, this function fully qualifies it according to
 * typedef scope rules
 * ----------------------------------------------------------------------------- */

SwigType *SwigType_typedef_qualified(SwigType *t) 
{
  List   *elements;
  String *result;
  int     i,len;
  int     level;
  init_scopes();

  result = NewString("");
  elements = SwigType_split(t);
  len = Len(elements);
  for (i = 0; i < len; i++) {
    String *e = Getitem(elements,i);
    if (SwigType_issimple(e)) {
      level = scope_level;
      while (level >= 0) {
	if (Getattr(scopes[level],e)) {
	  if (Len(scopenames[level])) {
	    Insert(e,0,"::");
	    Insert(e,0,scopenames[level]);
	  } else {
	    break;
	  }
	}
	level--;
      }
      Append(result,e);
    } else if (SwigType_isfunction(e)) {
      List *parms = SwigType_parmlist(e);
      String *s = NewString("f(");
      String *p;
      p = Firstitem(parms);
      while (p) {
	Append(s,SwigType_typedef_qualified(p));
	p = Nextitem(parms);
	if (p) {
	  Append(s,",");
	}
      }
      Append(s,").");
      Append(result,s);
      Delete(s);
    } else {
      Append(result,e);
    }
  }
  Delete(elements);
  return result;
}

/* ----------------------------------------------------------------------------- 
 * SwigType_istypedef()
 *
 * Checks a typename to see if it is a typedef.
 * ----------------------------------------------------------------------------- */

int SwigType_istypedef(SwigType *t) {
  String *base, *type;
  int level;

  init_scopes();
  base = SwigType_base(t);
  level = scope_level;
  while (level >= 0) {
    /* See if we know about this type */
    type = Getattr(scopes[level],base);
    if (type) {
      Delete(base);
      return 1;
    }
    level--;
  }
  Delete(base);
  return 0;
}

/* -----------------------------------------------------------------------------
 * SwigType_type()
 *
 * Returns an integer code describing the datatype.  This is only used for
 * compatibility with SWIG1.1 language modules and is likely to go away once
 * everything is based on typemaps.
 * ----------------------------------------------------------------------------- */

int SwigType_type(SwigType *t) 
{
  char *c;
  /* Check for the obvious stuff */
  c = Char(t);

  if (strncmp(c,"p.",2) == 0) {
    if (SwigType_type(c+2) == T_CHAR) return T_STRING;
    else return T_POINTER;
  }
  if (strncmp(c,"a(",2) == 0) return T_ARRAY;
  if (strncmp(c,"r.",2) == 0) return T_REFERENCE;
  if (strncmp(c,"m(",2) == 0) return T_MPOINTER;
  if (strncmp(c,"q(",2) == 0) {
    while(*c && (*c != '.')) c++;
    if (*c) return SwigType_type(c+1);
    return T_ERROR;
  }
  if (strncmp(c,"f(",2) == 0) return T_FUNCTION;
  
  /* Look for basic types */
  if (strcmp(c,"int") == 0) return T_INT;
  if (strcmp(c,"long") == 0) return T_LONG;
  if (strcmp(c,"short") == 0) return T_SHORT;
  if (strcmp(c,"unsigned") == 0) return T_UINT;
  if (strcmp(c,"unsigned short") == 0) return T_USHORT;
  if (strcmp(c,"unsigned long") == 0) return T_ULONG;
  if (strcmp(c,"unsigned int") == 0) return T_UINT;
  if (strcmp(c,"char") == 0) return T_CHAR;
  if (strcmp(c,"signed char") == 0) return T_SCHAR;
  if (strcmp(c,"unsigned char") == 0) return T_UCHAR;
  if (strcmp(c,"float") == 0) return T_FLOAT;
  if (strcmp(c,"double") == 0) return T_DOUBLE;
  if (strcmp(c,"void") == 0) return T_VOID;
  if (strcmp(c,"bool") == 0) return T_BOOL;
  if (strcmp(c,"long long") == 0) return T_LONGLONG;
  if (strcmp(c,"unsigned long long") == 0) return T_ULONGLONG;
  if (strncmp(c,"enum ",5) == 0) return T_INT;
  /* Hmmm. Unknown type */
  if (SwigType_istypedef(t)) {
    int r;
    SwigType *nt = SwigType_typedef_resolve(t);
    r = SwigType_type(nt);
    Delete(nt);
    return r;
  } 
  return T_USER;
}

/******************************************************************************
 ***                         * * * WARNING * * *                            ***
 ***                                                                        ***
 *** Don't even think about modifying anything below this line unless you   ***
 *** are completely on top of *EVERY* subtle aspect of the C++ type system  ***
 *** are you are prepared to suffer endless hours of agony trying to        ***
 *** debug the SWIG run-time type checker after you break it.               ***
 ******************************************************************************/

/* -----------------------------------------------------------------------------
 * SwigType_remember()
 *
 * This function "remembers" a datatype that was used during wrapper code generation
 * so that a type-checking table can be generated later on. It is up to the language
 * modules to actually call this function--it is not done automatically.
 *
 * Type tracking is managed through two separate hash tables.  The hash 'r_mangled'
 * is mapping between mangled type names (used in the target language) and 
 * fully-resolved C datatypes used in the source input.   The second hash 'r_resolved'
 * is the inverse mapping that maps fully-resolved C datatypes to all of the mangled
 * names in the scripting languages.  For example, consider the following set of
 * typedef declarations:
 *
 *      typedef double Real;
 *      typedef double Float;
 *      typedef double Point[3];
 *
 * Now, suppose that the types 'double *', 'Real *', 'Float *', 'double[3]', and
 * 'Point' were used in an interface file and "remembered" using this function.
 * The hash tables would look like this:
 *
 * r_mangled {
 *   _p_double : [ p.double, a(3).double ]
 *   _p_Real   : [ p.double ]
 *   _p_Float  : [ p.double ]
 *   _Point    : [ a(3).double ]
 *
 * r_resolved {
 *   p.double     : [ _p_double, _p_Real, _p_Float ]
 *   a(3).double  : [ _p_double, _Point ]
 * }
 *
 * Together these two hash tables can be used to determine type-equivalency between
 * mangled typenames.  To do this, we view the two hash tables as a large graph and
 * compute the transitive closure.
 * ----------------------------------------------------------------------------- */

static Hash *r_mangled = 0;                /* Hash mapping mangled types to fully resolved types */
static Hash *r_resolved = 0;               /* Hash mapping resolved types to mangled types       */
static Hash *r_ltype = 0;                  /* Hash mapping mangled names to their local c type   */

void SwigType_remember(SwigType *t) {
  String *mt;
  SwigType *lt;
  Hash   *h;
  SwigType *fr;

  if (!r_mangled) {
    r_mangled = NewHash();
    r_resolved = NewHash();
    r_ltype = NewHash();
  }

  mt = SwigType_manglestr(t);               /* Create mangled string */
  if (SwigType_istypedef(t))
    lt = Copy(t);
  else
    lt = SwigType_ltype(t);
  Setattr(r_ltype, mt, lt);
  fr = SwigType_typedef_resolve_all(t);     /* Create fully resolved type */

  /* Added to deal with possible table bug */
  fr = SwigType_strip_qualifiers(fr);

  /*  Printf(stdout,"%s ---> %s\n", t, fr); */

  h = Getattr(r_mangled,mt);
  if (!h) {
    h = NewHash();
    Setattr(r_mangled,mt,h);
    Delete(h);
  }
  Setattr(h,fr,mt);

  h = Getattr(r_resolved, fr);
  if (!h) {
    h = NewHash();
    Setattr(r_resolved,fr,h);
    Delete(h);
  }
  Setattr(h,mt,fr);
}

/* -----------------------------------------------------------------------------
 * SwigType_equivalent_mangle()
 *
 * Return a list of all of the mangled typenames that are equivalent to another
 * mangled name.   This works as follows: For each fully qualified C datatype
 * in the r_mangled hash entry, we collect all of the mangled names from the
 * r_resolved hash and combine them together in a list (removing duplicate entries).
 * ----------------------------------------------------------------------------- */

List *SwigType_equivalent_mangle(String *ms, Hash *checked, Hash *found) {
  List *l;
  Hash *h;
  Hash *ch;
  Hash *mh;

  if (found) {
    h = found;
  } else {
    h = NewHash();
  }
  if (checked) {
    ch = checked;
  } else {
    ch = NewHash();
  }
  if (Getattr(ch,ms)) goto check_exit;    /* Already checked this type */
  Setattr(h,ms,"1");
  Setattr(ch, ms, "1");
  mh = Getattr(r_mangled,ms);
  if (mh) {
    String *key;
    key = Firstkey(mh);
    while (key) {
      Hash *rh;
      if (Getattr(ch,key)) {
	key = Nextkey(mh);
	continue;
      }
      Setattr(ch,key,"1");
      rh = Getattr(r_resolved,key);
      if (rh) {
	String *rkey;
	rkey = Firstkey(rh);
	while (rkey) {
	  Setattr(h,rkey,"1");
	  SwigType_equivalent_mangle(rkey,ch,h);
	  rkey = Nextkey(rh);
	}
      }
      key = Nextkey(mh);
    }
  }
 check_exit:
  if (!found) {
    l = Hash_keys(h);
    Delete(h);
    Delete(ch);
    return l;
  } else {
    return 0;
  }
}

/* -----------------------------------------------------------------------------
 * SwigType_inherit()
 *
 * Record information about inheritance.  We keep a hash table that keeps
 * a mapping between base classes and all of the classes that are derived
 * from them.
 *
 * subclass is a hash that maps base-classes to all of the classes derived from them.
 * ----------------------------------------------------------------------------- */

static Hash   *subclass = 0;
static Hash   *conversions = 0;

void
SwigType_inherit(String *derived, String *base) {
  Hash *h;
  if (!subclass) subclass = NewHash();
  
  h = Getattr(subclass,base);
  if (!h) {
    h = NewHash();
    Setattr(subclass,base,h);
  }
  Setattr(h,derived,"1");
}

/* -----------------------------------------------------------------------------
 * SwigType_inherit_equiv()
 *
 * Modify the type table to handle C++ inheritance
 * ----------------------------------------------------------------------------- */

void SwigType_inherit_equiv(File *out) {
  String *rkey, *bkey, *ckey;
  String *prefix, *base;
  Hash   *sub;
  Hash   *rh;
  List   *rlist;

  if (!conversions) conversions = NewHash();
  if (!subclass) subclass = NewHash();

  rkey = Firstkey(r_resolved);
  while (rkey) {
    /* rkey is a fully qualified type.  We strip all of the type constructors off of it just to get the base */
    base = SwigType_base(rkey);

    /* Check to see whether the base is recorded in the subclass table */
    sub = Getattr(subclass,base);
    Delete(base);
    if (!sub) {
      rkey = Nextkey(r_resolved);
      continue;
    }

    /* This type has subclasses.  We now need to walk through these subtypes and generate pointer converion functions */
    rh = Getattr(r_resolved, rkey);
    rlist = NewList();
    for (ckey = Firstkey(rh); ckey; ckey = Nextkey(rh)) {
      Append(rlist,ckey);
    }
    bkey = Firstkey(sub);
    while (bkey) {
      prefix= SwigType_prefix(rkey);
      Append(prefix,bkey);
      Setattr(rh,SwigType_manglestr(prefix),prefix);
      ckey = NewStringf("%s+%s",SwigType_manglestr(prefix), SwigType_manglestr(rkey));
      if (!Getattr(conversions,ckey)) {
	String *convname = NewStringf("%sTo%s", SwigType_manglestr(prefix), SwigType_manglestr(rkey));
	Printf(out,"static void *%s(void *x) {\n", convname);
	Printf(out,"    return (void *)((%s) ((%s) x));\n", SwigType_lstr(rkey,0), SwigType_lstr(prefix,0));
	Printf(out,"}\n");
	Setattr(conversions,ckey,convname);
	Delete(ckey);	

	/* This inserts conversions for typedefs */
	{
	  Hash *r = Getattr(r_resolved, prefix);
	  if (r) {
	    String *rrkey = Firstkey(r);
	    while (rrkey) {
	      String *rlkey;
	      String *rkeymangle;

	      /* Make sure this name equivalence is not due to inheritance */

	      if (Cmp(prefix, Getattr(r,rrkey)) == 0) {
		rkeymangle = SwigType_manglestr(rkey);
		ckey = NewStringf("%s+%s", rrkey, rkeymangle);
		if (!Getattr(conversions, ckey)) {
		  Setattr(conversions, ckey, convname);
		}
		Delete(ckey);
		for (rlkey = Firstitem(rlist); rlkey; rlkey = Nextitem(rlist)) {
		  ckey = NewStringf("%s+%s", rrkey, rlkey);
		  Setattr(conversions, ckey, convname);
		  Delete(ckey);
		}
		Delete(rkeymangle);
	      }
	      rrkey = Nextkey(r);
	    }
	  }
	}
	Delete(convname);
      }
      Delete(prefix);
      bkey = Nextkey(sub);
    }
    rkey = Nextkey(r_resolved);
  }
      
}

/* -----------------------------------------------------------------------------
 * SwigType_type_table()
 *
 * Generate the type-table for the type-checker.
 * ----------------------------------------------------------------------------- */

void
SwigType_emit_type_table(File *f_forward, File *f_table) {
  DOH *key;
  String *types, *table;
  int i = 0;

  if (!r_mangled) {
    r_mangled = NewHash();
    r_resolved = NewHash();
  }

  Printf(f_table,"\n/* -------- TYPE CONVERSION AND EQUIVALENCE RULES (BEGIN) -------- */\n\n");

  SwigType_inherit_equiv(f_table);

#ifdef DEBUG
  Printf(stdout,"---r_mangled---\n");
  Printf(stdout,"%s\n", r_mangled);
  
  Printf(stdout,"---r_resolved---\n");
  Printf(stdout,"%s\n", r_resolved);

  Printf(stdout,"---r_ltype---\n");
  Printf(stdout,"%s\n", r_ltype);

  Printf(stdout,"---subclass---\n");
  Printf(stdout,"%s\n", subclass);

  Printf(stdout,"---scopes[0]---\n");
  Printf(stdout,"%s\n", scopes[0]);
  
#endif
  table = NewString("");
  types = NewString("");
  Printf(table,"static swig_type_info *swig_types_initial[] = {\n");
  key = Firstkey(r_mangled);
  Printf(f_forward,"\n/* -------- TYPES TABLE (BEGIN) -------- */\n\n");
  while (key) {
    List *el;
    String *en;
    Printf(f_forward,"#define  SWIGTYPE%s swig_types[%d] \n", key, i);
    Printv(types,"static swig_type_info _swigt_", key, "[] = {", 0);
    Printv(types,"{\"", key, "\", 0, \"", SwigType_str(Getattr(r_ltype,key),0),"\"},", 0);
    el = SwigType_equivalent_mangle(key,0,0);
    for (en = Firstitem(el); en; en = Nextitem(el)) {
      String *ckey;
      String *conv;
      ckey = NewStringf("%s+%s", en, key);
      conv = Getattr(conversions,ckey);
      if (conv) {
	Printf(types,"{\"%s\", %s},", en, conv);
      } else {
	Printf(types,"{\"%s\"},", en);
      }
      Delete(ckey);
    }
    Delete(el);
    Printf(types,"{0}};\n");
    Printv(table, "_swigt_", key, ", \n", 0);
    key = Nextkey(r_mangled);
    i++;
  }

  Printf(table, "0\n};\n");
  Printf(f_forward,"static swig_type_info *swig_types[%d];\n", i+1);
  Printf(f_forward,"\n/* -------- TYPES TABLE (END) -------- */\n\n");
  Printf(f_table,"%s\n", types);
  Printf(f_table,"%s\n", table);
  Printf(f_table,"\n/* -------- TYPE CONVERSION AND EQUIVALENCE RULES (END) -------- */\n\n");
  Delete(types);
  Delete(table);
}

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

char cvsroot_stype_c[] = "$Header$";

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
  case T_LONGLONG:
    return NewString("long long");
    break;
  case T_ULONGLONG:
    return NewString("unsigned long long");
    break;
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
 * SwigType_add_template()
 *
 * Adds a template to a type.   This template is encoded in the SWIG type
 * mechanism and produces a string like this:
 *
 *  vector<int *> ----> "vector<(p.int)>"
 * ----------------------------------------------------------------------------- */

void
SwigType_add_template(SwigType *t, ParmList *parms) {
  Parm   *p;

  Append(t,"<(");
  p = parms;
  for (p = parms; p; p = nextSibling(p)) {
    String *v;
    if (Getattr(p,"default")) continue;
    if (p != parms) Append(t,",");
    v = Getattr(p,"value");
    if (v) {
      Append(t,v);
    } else {
      Append(t,Getattr(p,"type"));
    }
  }
  Append(t,")>");
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
    } else if (*c == '(') {
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

List *SwigType_parmlist(const String *p) {
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
 * Testing functions for querying a raw datatype
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

int SwigType_ismutable(SwigType *t) {
  int r;
  SwigType *qt = SwigType_typedef_resolve_all(t);
  if (SwigType_isreference(qt)) {
    Delete(SwigType_pop(qt));
  }
  r = SwigType_isconst(qt);
  Delete(qt);
  return r ? 0 : 1;
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
  while (*c) {
    if (*c == '<') {
      int nest = 1;
      c++;
      while (*c && nest) {
	if (*c == '<') nest++;
	if (*c == '>') nest--;
	c++;
      }
      c--;
    }
    if (*c == '.') return 0;
    c++;
  }
  return 1;
}

int SwigType_isvarargs(const SwigType *t) {
  if (Strcmp(t,"v(...)") == 0) return 1;
  return 0;
}

int SwigType_istemplate(const SwigType *t) {
  if (Strstr(t,"<(")) return 1;
  return 0;
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

  /* Check for a type constructor */
  if ((d > c) && (*(d-1) == '.')) d--;

  while (d > c) {
    d--;
    if (*d == '>') {
      /* Skip over template--that's part of the base name */
      int ntemp = 1;
      d--;
      while ((d > c) && (ntemp > 0)) {
	if (*d == '>') ntemp++;
	if (*d == '<') ntemp--;
	d--;
      }
    }
    if (*d == ')') {
      /* Skip over params */
      int nparen = 1;
      d--;
      while ((d > c) && (nparen > 0)) {
	if (*d == ')') nparen++;
	if (*d == '(') nparen--;
	d--;
      }
    }
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

  /* Check for a type constructor */
  if ((d > c) && (*(d-1) == '.')) d--;

  while (d > c) {
    d--;
    if (*d == '>') {
      int nest = 1;
      d--;
      while ((d > c) && (nest)) {
	if (*d == '>') nest++;
	if (*d == '<') nest--;
	d--;
      }
    }
    if (*d == ')') {
      /* Skip over params */
      int nparen = 1;
      d--;
      while ((d > c) && (nparen)) {
	if (*d == ')') nparen++;
	if (*d == '(') nparen--;
	d--;
      }
    }

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
 * SwigType_templateprefix()
 *
 * Returns the prefix before the first template definition.
 * For example:
 *
 *     Foo<(p.int)>::bar
 *
 * Results in "Foo"
 * ----------------------------------------------------------------------------- */

String *
SwigType_templateprefix(SwigType *t) {
  char *c;
  String *r;
  String *s = NewString(t);
  c = Char(s);
  while (*c) {
    if (*c == '<') {
      *c = 0;
      r = NewString(Char(s));
      Delete(s);
      return r;
    }
    c++;
  }
  return s;
}

/* -----------------------------------------------------------------------------
 * SwigType_templatesuffix()
 *
 * Returns text after a template substitution.  Used to handle scope names
 * for example:
 *
 *        Foo<(p.int)>::bar
 *
 * returns "::bar"
 * ----------------------------------------------------------------------------- */

String *
SwigType_templatesuffix(const SwigType *t) {
  char *c;
  c = Char(t);
  while (*c) {
    if ((*c == '<') && (*(c+1) == '(')) {
      int nest = 1;
      c++;
      while (*c && nest) {
	if (*c == '<') nest++;
	if (*c == '>') nest--;
	c++;
      }
      return NewString(c);
    }
    c++;
  }
  return NewString("");
}

/* -----------------------------------------------------------------------------
 * SwigType_templateargs()
 *
 * Returns the template part
 * ----------------------------------------------------------------------------- */

String *
SwigType_templateargs(SwigType *t) {
  String *result = NewString("");
  char *c;
  c = Char(t);
  while (*c) {
    if ((*c == '<') && (*(c+1) == '(')) {
      int nest = 1;
      Putc(*c,result);
      c++;
      while (*c && nest) {
	Putc(*c,result);
	if (*c == '<') nest++;
	if (*c == '>') nest--;
	c++;
      }
      return result;
    }
    c++;
  }
  Delete(result);
  return 0;
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
  } else if (SwigType_isvarargs(r)) {
    def = NewString("v(...)");
  } else {
    def = NewString("SWIGTYPE");
  }
  if (r != t) Delete(r);
  Setattr(default_cache,t,Copy(def));
  return def;
}

/* -----------------------------------------------------------------------------
 * SwigType_namestr()
 *
 * Returns a string of the base type.  Takes care of template expansions
 * ----------------------------------------------------------------------------- */

String *
SwigType_namestr(const SwigType *t) {
  String *r;
  String *suffix;
  List   *p;
  char   tmp[256];
  char   *c, *d, *e;
  int     i, sz;

  if (!SwigType_istemplate(t)) return NewString(t);

  c = Strstr(t,"<(");

  d = Char(t);
  e = tmp;
  while (d != c) {
    *(e++) = *(d++);
  }
  *e = 0;
  r = NewString(tmp);
  Putc('<',r);
  
  p = SwigType_parmlist(t);
  sz = Len(p);
  for (i = 0; i < sz; i++) {
    Append(r,SwigType_str(Getitem(p,i),0));
    if ((i+1) < sz) Putc(',',r);
  }
  Putc(' ',r);
  Putc('>',r);
  suffix = SwigType_templatesuffix(t);
  Append(r,suffix);
  Delete(suffix);
#if 0
  if (SwigType_istemplate(r)) {
    SwigType *rr = SwigType_namestr(r);
    Delete(r);
    return rr;
  }
#endif
  return r;
}

/* -----------------------------------------------------------------------------
 * SwigType_str()
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
    else if (SwigType_isreference(element)) {
      Insert(result,0,"&");
    }  else if (SwigType_isarray(element)) {
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
      if (Strcmp(element,"v(...)") == 0) {
	Insert(result,0,"...");
      } else {
	String *bs = SwigType_namestr(element);
	Insert(result,0," ");
	Insert(result,0,bs);
	Delete(bs);
      }
    }
    element = nextelement;
  }
  Delete(elements);
  Chop(result);
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_ltype(SwigType *ty)
 *
 * Create a locally assignable type
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_ltype(SwigType *s) {
  String *result;
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
    if (td && (SwigType_isconst(td) || SwigType_isarray(td) || SwigType_isenum(td) || SwigType_isreference(td))) {
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
  return result;
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
  int      isreference = 0;

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
    if ((td) && (SwigType_isconst(td) || SwigType_isarray(td) || SwigType_isreference(td))) {
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
      isreference = 1;
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
      String *bs = SwigType_namestr(element);
      Insert(result,0,bs);
      Delete(bs);
      clear = 0;
    } else {
      String *bs = SwigType_namestr(element);
      Insert(result,0," ");
      Insert(result,0,bs);
      Delete(bs);
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
    if (isreference) {
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
    Printf(result,"(%s)", SwigType_str(s,0));
    if (name) 
      Printf(result,"%s", name);
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
  String *result,*base;
  SwigType *lt;
  SwigType *ss = 0;

  if (SwigType_istemplate(s)) {
    ss = SwigType_typedef_resolve_all(s);
    s = ss;
  }
  lt = SwigType_ltype(s);
  result = SwigType_prefix(lt);
  base = SwigType_base(lt);

  c = Char(result);
  while (*c) {
    if (!isalnum((int)*c)) *c = '_';
    c++;
  }
  if (SwigType_istemplate(base)) {
    String *b = SwigType_namestr(base);
    Delete(base);
    base = b;
  }

  Replace(base,"struct ","", DOH_REPLACE_ANY);     /* This might be problematic */
  Replace(base,"class ","", DOH_REPLACE_ANY);
  Replace(base,"union ","", DOH_REPLACE_ANY);

  c = Char(base);
  while (*c) {
    if (*c == '<') *c = 'T';
    else if (*c == '>') *c = 't';
    else if (*c == '*') *c = 'p';
    else if (*c == '[') *c = 'a';
    else if (*c == ']') *c = 'A';
    else if (*c == '&') *c = 'R';
    else if (*c == '(') *c = 'f';
    else if (*c == ')') *c = 'F';
    else if (!isalnum((int)*c)) *c = '_';
    c++;
  }
  Append(result,base);
  Insert(result,0,"_");
  Delete(lt);
  Delete(base);
  if (ss) Delete(ss);
  return result;
}

String *SwigType_manglestr(SwigType *s) {
  return SwigType_manglestr_default(s);
}

/* -----------------------------------------------------------------------------
 * SwigType_typename_replace()
 *
 * Replaces a typename in a type with something else.  Needed for templates.
 * ----------------------------------------------------------------------------- */

void
SwigType_typename_replace(SwigType *t, String *pat, String *rep) {
  String *nt;
  int    i;
  List   *elem;

  if (!Strstr(t,pat)) return;

  if (Strcmp(t,pat) == 0) {
    Replace(t,pat,rep,DOH_REPLACE_ANY);
    return;
  }
  nt = NewString("");
  elem = SwigType_split(t);
  for (i = 0; i < Len(elem); i++) {
    String *e = Getitem(elem,i);
    if (SwigType_issimple(e)) {
      if (Strcmp(e,pat) == 0) {
	/* Replaces a type of the form 'pat' with 'rep<args>' */
	Replace(e,pat,rep,DOH_REPLACE_ANY);
      } else if (SwigType_istemplate(e)) {
         /* Replaces a type of the form 'pat<args>' with 'rep' */
	if (Strncmp(e,pat,Len(pat)) == 0) {
	  String *repbase = SwigType_templateprefix(rep);
	  Replace(e,pat,repbase,DOH_REPLACE_ID | DOH_REPLACE_FIRST);
	  Delete(repbase);
	} 
	{
	  List *tparms = SwigType_parmlist(e);
	  int j;
	  String *nt = SwigType_templateprefix(e);
	  Printf(nt,"<(");
	  for (j = 0; j < Len(tparms); j++) {
	    SwigType_typename_replace(Getitem(tparms,j), pat, rep);
	    Printf(nt,"%s",Getitem(tparms,j));
	    if (j < (Len(tparms)-1)) Printf(nt,",");
	  }
	  Printf(nt,")>%s", SwigType_templatesuffix(e));
	  Clear(e);
	  Append(e,nt);
	  Delete(nt);
	}
      }
    } else if (SwigType_isfunction(e)) {
      int j;
      List *fparms = SwigType_parmlist(e);
      Clear(e);
      Printf(e,"f(");
      for (j = 0; j < Len(fparms); j++) {
	SwigType_typename_replace(Getitem(fparms,j), pat, rep);
	Printf(e,"%s",Getitem(fparms,j));
	if (j < (Len(fparms)-1)) Printf(e,",");
      }
      Printf(e,").");
    }
    Append(nt,e);
  }
  Clear(t);
  Append(t,nt);
}

/* -----------------------------------------------------------------------------
 * SwigType_check_decl()
 *
 * Checks type declarators for a match
 * ----------------------------------------------------------------------------- */

int
SwigType_check_decl(SwigType *ty, const SwigType *decl) {
  SwigType *t,*t1,*t2;
  int r;
  t = SwigType_typedef_resolve_all(ty);
  t1 = SwigType_strip_qualifiers(t);
  t2 = SwigType_prefix(t1);
  r = Cmp(t2,decl);
  Delete(t);
  Delete(t1);
  Delete(t2);
  if (r == 0) return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 * typeobj.c
 *
 *     This file provides functions for constructing, manipulating, and testing
 *     type objects.   Type objects are merely the raw low-level representation
 *     of C++ types.   They do not incorporate high-level type system features
 *     like typedef, namespaces, etc.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2003.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

char cvsroot_typeobj_c[] = "$Header$";

#include "swig.h"
#include <ctype.h>

/* -----------------------------------------------------------------------------
 * Synopsis
 *
 * This file provides a collection of low-level functions for constructing and
 * manipulating C++ data types.   In SWIG, C++ datatypes are encoded as simple
 * text strings.  This representation is compact, easy to debug, and easy to read.
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
 * For C++, typenames may be parameterized using <(...)>.  Here are some
 * examples:
 *
 *       String Encoding                  C++ Example
 *       ---------------                  ------------
 *       p.vector<(int)>                  vector<int> *
 *       r.foo<(int,p.double)>            foo<int,double *> &
 *
 * Contents of this file:
 *
 * Most of this functions in this file pertain to the low-level manipulation
 * of type objects.   There are constructor functions like this:
 *
 *       SwigType_add_pointer()
 *       SwigType_add_reference()
 *       SwigType_add_array()
 *
 * These are used to build new types.  There are also functions to undo these
 * operations.  For example:
 *
 *       SwigType_del_pointer()
 *       SwigType_del_reference()
 *       SwigType_del_array()
 *
 * In addition, there are query functions
 *
 *       SwigType_is_pointer()
 *       SwigType_is_reference()
 *       SwigType_is_array()
 *
 * Finally, there are some data extraction functions that can be used to
 * extract array dimensions, template arguments, and so forth.
 * 
 * It is very important for developers to realize that the functions in this
 * module do *NOT* incorporate higher-level type system features like typedef.
 * For example, you could have C code like this:
 *
 *        typedef  int  *intptr;
 *       
 * In this case, a SwigType of type 'intptr' will be treated as a simple type and
 * functions like SwigType_is_pointer() will evaluate as false.  It is strongly
 * advised that developers use the TypeSys_* interface to check types in a more
 * reliable manner.
 * ----------------------------------------------------------------------------- */


/* -----------------------------------------------------------------------------
 * NewSwigType()
 *
 * Constructs a new type object.   Eventually, it would be nice for this function
 * to accept an initial value in the form a C/C++ abstract type (currently unimplemented).
 * ----------------------------------------------------------------------------- */

#ifdef NEW
SwigType *
NewSwigType(const String_or_char *initial) {
  return NewString(initial);
}

#endif

/* The next few functions are utility functions used in the construction and 
   management of types */

/* -----------------------------------------------------------------------------
 * static element_size()
 *
 * This utility function finds the size of a single type element in a type string.
 * Type elements are always delimeted by periods, but may be nested with 
 * parentheses.  A nested element is always handled as a single item.
 *
 * Returns the integer size of the element (which can be used to extract a 
 * substring, to chop the element off, or for other purposes).
 * ----------------------------------------------------------------------------- */

static int 
element_size(char *c) {
  int nparen;
  char *s = c;
  while (*c) {
    if (*c == '.') {
      c++;
      return (int) (c - s);
    } else if (*c == '(') {
      nparen = 1;
      c++;
      while (*c) {
	if (*c == '(') nparen++;
	if (*c == ')') {
	  nparen--;
	  if (nparen == 0) break;
	}
	c++;
      }
    }
    if (*c) c++;
  }
  return (int) (c - s);
}

/* -----------------------------------------------------------------------------
 * SwigType_del_element()
 *
 * Deletes one type element from the type.  
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_del_element(SwigType *t) {
  int sz = element_size(Char(t));
  Delslice(t,0,sz);
  return t;
}

/* -----------------------------------------------------------------------------
 * SwigType_pop()
 * 
 * Pop one type element off the type.
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_pop(SwigType *t) {
  SwigType  *result;
  char      *c;
  int        sz;

  c = Char(t);
  if (!*c) return 0;

  sz = element_size(c);
  result = NewStringWithSize(c,sz);
  Delslice(t,0,sz);
  c = Char(t);
  if (*c == '.') {
    Delitem(t,0);
  }
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_parm()
 *
 * Returns the parameter of an operator as a string
 * ----------------------------------------------------------------------------- */

String *
SwigType_parm(SwigType *t) {
  char *start, *c;
  int  nparens = 0;

  c = Char(t);
  while (*c && (*c != '(') && (*c != '.')) c++;
  if (!*c || (*c == '.')) return 0;
  c++;
  start = c;
  while (*c) {
    if (*c == ')') {
      if (nparens == 0) break;
      nparens--;
    } else if (*c == '(') {
      nparens++;
    }
    c++;
  }
  return NewStringWithSize(start, (int) (c-start));
}

/* -----------------------------------------------------------------------------
 * SwigType_split()
 *
 * Splits a type into it's component parts and returns a list of string.
 * ----------------------------------------------------------------------------- */

List *SwigType_split(const SwigType *t) {
  DOH     *item;
  List    *list;
  char    *c;
  int      len;

  c = Char(t);
  list = NewList();
  while (*c) {
    len = element_size(c);
    item = NewStringWithSize(c,len);
    Append(list,item);
    Delete(item);
    c = c + len;
    if (*c == '.') c++;
  }
  return list;
}

/* -----------------------------------------------------------------------------
 * SwigType_parmlist()
 *
 * Splits a comma separated list of type components into strings.
 * ----------------------------------------------------------------------------- */

List *SwigType_parmlist(const String *p) {
  DOH     *item;
  List *list;
  char *c, *itemstart;

  c = Char(p);
  while (*c && (*c != '(') && (*c != '.')) c++;
  if (!*c || (*c == '.')) return 0;
  c++;
  list = NewList();
  itemstart = c;
  while (*c) {
    if (*c == ',') {
      item = NewStringWithSize(itemstart, (int) (c - itemstart));
      Append(list,item);
      Delete(item);
      itemstart = c+1;
    } else if (*c == '(') {
      int nparens = 1;
      c++;
      while (*c) {
	if (*c == '(') nparens++;
	if (*c == ')') {
	  nparens--;
	  if (nparens == 0) break;
	}
	c++;
      }
    } else if (*c == ')') {
      break;
    }
    if (*c) c++;
  }
  item = NewStringWithSize(itemstart,(int) (c - itemstart));
  Append(list,item);
  Delete(item);
  return list;
}

/* -----------------------------------------------------------------------------
 *                                 Pointers
 *
 * SwigType_add_pointer()
 * SwigType_del_pointer()
 * SwigType_ispointer()
 *
 * Add, remove, and test if a type is a pointer.  The deletion and query
 * functions take into account qualifiers (if any).
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_add_pointer(SwigType *t) {
  Insert(t,0,"p.");
  return t;
}

SwigType *
SwigType_del_pointer(SwigType *t) {
  char *c, *s;
  c = Char(t);
  s = c;
  /* Skip qualifiers, if any */
  if (strncmp(c,"q(",2) == 0) {
    c = strchr(c,'.');
    assert(c);
    c++;
  }
  if (strncmp(c,"p.",2)) {
    printf("Fatal error. SwigType_del_pointer applied to non-pointer.\n");
    abort();
  }
  Delslice(t,0,(c-s)+2);
  return t;
}

int
SwigType_ispointer(SwigType *t) {
  char *c;
  if (!t) return 0;
  c = Char(t);
  /* Skip qualifiers, if any */
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

/* -----------------------------------------------------------------------------
 *                                 References
 *
 * SwigType_add_reference()
 * SwigType_del_reference()
 * SwigType_isreference()
 *
 * Add, remove, and test if a type is a pointer.  The deletion and query
 * functions take into account qualifiers (if any).
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_add_reference(SwigType *t) {
  Insert(t,0,"r.");
  return t;  
}

SwigType *
SwigType_del_reference(SwigType *t) {
  char *c = Char(t);
  int check = strncmp(c,"r.",2);
  assert(check == 0);
  Delslice(t,0,2);
  return t;
}

int
SwigType_isreference(SwigType *t) {
  char *c;
  if (!t) return 0;
  c = Char(t);
  if (strncmp(c,"r.",2) == 0) {
    return 1;
  } 
  return 0;
}

/* -----------------------------------------------------------------------------
 *                                  Qualifiers
 *
 * SwigType_add_qualifier()
 * SwigType_del_qualifier()
 * SwigType_is_qualifier()
 *
 * Adds type qualifiers like "const" and "volatile".   When multiple qualifiers
 * are added to a type, they are combined together into a single qualifier.
 * Repeated qualifications have no effect.  Moreover, the order of qualifications
 * is alphabetical---meaning that "const volatile" and "volatile const" are
 * stored in exactly the same way as "q(const volatile)".
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_add_qualifier(SwigType *t, const String_or_char *qual) {
  char temp[256], newq[256];
  int  sz, added = 0;
  char *q, *cqual;

  char *c = Char(t);
  cqual = Char(qual);

  if (!(strncmp(c,"q(",2) == 0)) {
    sprintf(temp,"q(%s).",cqual);
    Insert(t,0,temp);
    return t;
  } 

  /* The type already has a qualifier on it.  In this case, we first check to
     see if the qualifier is already specified.  In that case do nothing.
     If it is a new qualifier, we add it to the qualifier list in alphabetical
     order */

  sz = element_size(c);
  strncpy(temp,c, (sz < 256) ? sz : 256);

  if (strstr(temp,cqual)) {
    /* Qualifier already added */
    return t;
  }

  /* Add the qualifier to the existing list. */

  strcpy(newq,"q(");
  q = temp+2;
  q = strtok(q," ).");
  while (q) {
    if (strcmp(cqual,q) < 0) {
      /* New qualifier is less that current qualifier.  We need to insert it */
      strcat(newq,cqual);
      strcat(newq," ");
      strcat(newq,q);
      added = 1;
    } else {
      strcat(newq,q);
    }
    q = strtok(NULL," ).");
    if (q) {
      strcat(newq," ");
    }
  }
  if (!added) {
    strcat(newq," ");
    strcat(newq,cqual);
  }
  strcat(newq,").");
  Delslice(t,0,sz);
  Insert(t,0,newq);
  return t;
}

SwigType *
SwigType_del_qualifier(SwigType *t) {
  char *c = Char(t);
  int check = strncmp(c,"q(",2);
  assert(check == 0);
  Delslice(t,0,element_size(Char(t)));
  return t;
}

int 
SwigType_isqualifier(SwigType *t) {
  char *c;
  if (!t) return 0;
  c = Char(t);
  if (strncmp(c,"q(",2) == 0) {
    return 1;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 *                                Member Pointers
 *
 * SwigType_add_memberpointer()
 * SwigType_del_memberpointer()
 * SwigType_ismemberpointer()
 *
 * Add, remove, and test for C++ pointer to members.
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_add_memberpointer(SwigType *t, const String_or_char *name) {
  String *temp = NewStringf("m(%s).", name);
  Insert(t,0,temp);
  Delete(temp);
  return t;
}

SwigType *
SwigType_del_memberpointer(SwigType *t) {
  char *c = Char(t);
  int check = strncmp(c,"m(",2);
  assert(check == 0);
  Delslice(t,0,element_size(c));
  return t;
}

int 
SwigType_ismemberpointer(SwigType *t) {
  char *c;
  if (!t) return 0;
  c = Char(t);
  if (strncmp(c,"m(",2) == 0) {
    return 1;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 *                                    Arrays
 *
 * SwigType_add_array()
 * SwigType_del_array()
 * SwigType_isarray()
 *
 * Utility functions:
 *
 * SwigType_array_ndim()        - Calculate number of array dimensions.
 * SwigType_array_getdim()      - Get array dimension
 * SwigType_array_setdim()      - Set array dimension
 * SwigType_array_type()        - Return array type
 * SwigType_pop_arrays()        - Remove all arrays
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_add_array(SwigType *t, const String_or_char *size) {
  char temp[512];
  strcpy(temp,"a(");
  strcat(temp,Char(size));
  strcat(temp,").");
  Insert(t,0,temp);
  return t;
}

SwigType *
SwigType_del_array(SwigType *t) {
  char *c = Char(t);
  int check = strncmp(c,"a(",2);
  assert(check == 0);
  Delslice(t,0,element_size(c));
  return t;
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

/* Remove all arrays */
SwigType *
SwigType_pop_arrays(SwigType *t) {
  String *ta;
  assert(SwigType_isarray(t));
  ta = NewString("");
  while (SwigType_isarray(t)) {
    SwigType *td = SwigType_pop(t);
    Append(ta,td);
    Delete(td);
  }
  return ta;
}

/* Return number of array dimensions */
int 
SwigType_array_ndim(SwigType *t) {
  int ndim = 0;
  char *c = Char(t);

  while (c && (strncmp(c,"a(",2) == 0)) {
    c = strchr(c,'.');
    c++;
    ndim++;
  }
  return ndim;
}

/* Get nth array dimension */
String *
SwigType_array_getdim(SwigType *t, int n) {
  char *c = Char(t);
  while (c && (strncmp(c,"a(",2) == 0) && (n > 0)) {
    c = strchr(c,'.');
    c++;
    n--;
  }
  if (n == 0) return SwigType_parm(c);
  return 0;
}

/* Replace nth array dimension */
void SwigType_array_setdim(SwigType *t, int n, const String_or_char *rep) {
  String *result = 0;
  char temp;
  char *start;
  char *c = Char(t);

  start = c;
  if (strncmp(c,"a(",2)) abort();

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

/* Return base type of an array */
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
 *                                    Functions
 *
 * SwigType_add_function()
 * SwigType_del_function()
 * SwigType_isfunction()
 * SwigType_pop_function()
 *
 * Add, remove, and test for function types.
 * ----------------------------------------------------------------------------- */

/* Returns the function type, t, constructed from the parameters, parms */
SwigType *
SwigType_add_function(SwigType *t, ParmList *parms) {
  String *pstr;
  Parm   *p;

  Insert(t,0,").");
  pstr = NewString("f(");
  p = parms;
  for (p = parms; p; p = nextSibling(p)) {
    if (p != parms) Putc(',',pstr);
    Printv(pstr, Getattr(p,"type"), NIL);
  }
  Insert(t,0,pstr);
  Delete(pstr);
  return t;
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

int 
SwigType_isfunction(SwigType *t) {
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

ParmList *
SwigType_function_parms(SwigType *t) {
  List *l = SwigType_parmlist(t);
  Hash *p, *pp = 0, *firstp = 0;
  Iterator o;

  for (o = First(l); o.item; o = Next(o)) {
    p = NewParm(o.item,0);
    if (!firstp) firstp = p;
    if (pp) {
      set_nextSibling(pp,p);
    }
    pp = p;
  }
  Delete(l);
  return firstp;
}

int SwigType_isvarargs(const SwigType *t) {
  if (Strcmp(t,"v(...)") == 0) return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 *                                    Templates
 *
 * SwigType_add_template()
 *
 * Template handling.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * SwigType_add_template()
 *
 * Adds a template to a type.   This template is encoded in the SWIG type
 * mechanism and produces a string like this:
 *
 *  vector<int *> ----> "vector<(p.int)>"
 * ----------------------------------------------------------------------------- */

SwigType *
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
  return t;
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
SwigType_templateprefix(const SwigType *t) {
  const char *c;
  const char *s;

  s = Char(t);
  c = s;
  while (*c) {
    if (*c == '<') {
      return NewStringWithSize(s,c-s);
    }
    c++;
  }
  return NewString(s);
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
  const char *c;
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
SwigType_templateargs(const SwigType *t) {
  const char *c;
  const char *start;
  c = Char(t);
  while (*c) {
    if ((*c == '<') && (*(c+1) == '(')) {
      int nest = 1;
      start = c;
      c++;
      while (*c && nest) {
	if (*c == '<') nest++;
	if (*c == '>') nest--;
	c++;
      }
      return NewStringWithSize(start,c-start);
    }
    c++;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * SwigType_istemplate()
 *
 * Tests a type to see if it includes template parameters
 * ----------------------------------------------------------------------------- */

int 
SwigType_istemplate(const SwigType *t) {
  if (Strstr(t,"<(")) return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 * SwigType_base()
 *
 * This function returns the base of a type.  For example, if you have a
 * type "p.p.int", the function would return "int".
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_base(const SwigType *t) {
  char *c;
  char *lastop = 0;
  c = Char(t);

  lastop = c;

  /* Search for the last type constructor separator '.' */
  while (*c) {
    if (*c == '.') {
      if (*(c+1)) {
	lastop = c+1;
      }
      c++;
      continue;
    }
    if (*c == '<') {
      /* Skip over template---it's part of the base name */
      int ntemp = 1;
      c++;
      while ((*c) && (ntemp > 0)) {
	if (*c == '>') ntemp--;
	else if (*c == '<') ntemp++;
	c++;
      }
      if (ntemp) break;
      continue;
    }
    if (*c == '(') {
      /* Skip over params */
      int nparen = 1;
      c++;
      while ((*c) && (nparen > 0)) {
	if (*c == '(') nparen++;
	else if (*c == ')') nparen--;
	c++;
      }
      if (nparen) break;
      continue;
    }
    c++;
  }
  return NewString(lastop);
}

/* -----------------------------------------------------------------------------
 * SwigType_prefix()
 *
 * Returns the prefix of a datatype.  For example, the prefix of the
 * type "p.p.int" is "p.p.".
 * ----------------------------------------------------------------------------- */

String *
SwigType_prefix(const SwigType *t) {
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
 * SwigType_strip_qualifiers()
 * 
 * Strip all qualifiers from a type and return a new type
 * ----------------------------------------------------------------------------- */

SwigType *
SwigType_strip_qualifiers(SwigType *t) {
  static Hash *memoize_stripped = 0;
  SwigType *r;
  List     *l;
  Iterator  ei;

  if (!memoize_stripped) memoize_stripped = NewHash();
  r = Getattr(memoize_stripped,t);
  if (r) return Copy(r);
  
  l = SwigType_split(t);
  r = NewString("");
  
  for (ei = First(l);ei.item; ei = Next(ei)) {
    if (SwigType_isqualifier(ei.item)) continue;
    Append(r,ei.item);
  }
  Delete(l);
  {
    String *key, *value;
    key = Copy(t);
    value = Copy(r);
    Setattr(memoize_stripped,key,value);
    Delete(key);
    Delete(value);
  }
  return r;
}



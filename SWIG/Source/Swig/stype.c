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
 *  'p.'                = Pointer
 *  'r.'                = Reference
 *  'a(n).'             = Array of size n
 *  'f(..,..).'         = Function with arguments
 *  'q(str).'           = Qualifier (such as const or volatile)
 *  't(...).'           = Template specifier???
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
 * where we might want to do things like this:
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
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * SwigType_add_pointer()
 *
 * Adds a pointer constructor to a type
 * ----------------------------------------------------------------------------- */

void
SwigType_add_pointer(DOHString *t) {
  Insert(t,0,"p.");
}

/* -----------------------------------------------------------------------------
 * SwigType_add_array()
 *
 * Adds an array constructor to a type
 * ----------------------------------------------------------------------------- */

void
SwigType_add_array(DOHString *t, DOHString *size) {
  char temp[256];
  sprintf(temp,"a(%s).", Char(size));
  Insert(t,0,temp);
}

/* -----------------------------------------------------------------------------
 * SwigType_add_reference()
 *
 * Adds a reference constructor to a type.
 * ----------------------------------------------------------------------------- */

void
SwigType_add_reference(DOHString *t) {
  Insert(t,0,"r.");
}

/* -----------------------------------------------------------------------------
 * SwigType_add_qualifier()
 *
 * Adds a qualifier to a type
 * ----------------------------------------------------------------------------- */

void
SwigType_add_qualifier(DOHString *t, DOHString *qual) {
  char temp[256];
  sprintf(temp,"q(%s).",Char(qual));
  Insert(t,0,temp);
}

/* -----------------------------------------------------------------------------
 * SwigType_add_function()
 *
 * Adds a function to a type. Accepts a list of abstract types as parameters.
 * These abstract types should be passed as a list of type-strings.
 * ----------------------------------------------------------------------------- */

void
SwigType_add_function(DOHString *t, DOHList *parms) {
  DOHString *pstr;
  int        i,l;

  Insert(t,0,").");
  pstr = NewString("f(");
  l = Len(parms);
  for (i = 0; i < l; i++) {
    Printf(pstr,"%s",Getitem(parms,i));
    if (i < (l-1))
      Putc(',',pstr);
  }
  Insert(t,0,pstr);
  Delete(pstr);
}

/* -----------------------------------------------------------------------------
 * static isolate_element()
 *
 * Isolate a single element of a type string (delimeted by periods)
 * ----------------------------------------------------------------------------- */

static DOHString *
isolate_element(char *c) {
  DOHString *result = NewString("");
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
 * SwigType_split(DOH *t)
 *
 * Splits a type into it's component parts and returns a list of string.
 * ----------------------------------------------------------------------------- */

DOHList *SwigType_split(DOHString_or_char *t) {
  DOH     *item;
  DOHList *list;
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
 * Pop off the first type-constructor object and update the type
 * ----------------------------------------------------------------------------- */

DOHString *SwigType_pop(DOH *t)
{
  DOHString *result;
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

void SwigType_push(DOHString *t, DOHString *cons)
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

DOHList *SwigType_parmlist(DOHString *p) {
  DOH     *item;
  DOHList *list;
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

DOHString *SwigType_parm(DOHString *t) {
  DOHString *result;
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

int SwigType_ispointer(DOHString_or_char *t) {
  char *c;

  c = Char(t);
  if (strncmp(c,"p.",2) == 0) return 1;
  return 0;
}

int SwigType_isreference(DOHString_or_char *t) {
  char *c;
  c = Char(t);
  if (strncmp(c,"r.",2) == 0) return 1;
  return 0;
}

int SwigType_isarray(DOHString_or_char *t) {
  char *c;
  c = Char(t);
  if (strncmp(c,"a(",2) == 0) return 1;
  return 0;
}

int SwigType_isfunction(DOHString_or_char *t) {
  char *c;
  c = Char(t);
  if (strncmp(c,"f(",2) == 0) return 1;
  return 0;
}

int SwigType_isqualifier(DOHString_or_char *t) {
  char *c;
  c = Char(t);
  if (strncmp(c,"q(",2) == 0) return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 * SwigType_base()
 *
 * Returns the base name of a datatype.
 * ----------------------------------------------------------------------------- */

DOHString *SwigType_base(DOHString *t) {
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

DOHString *SwigType_prefix(DOHString *t) {
  char *c, *d;
  DOHString *r = 0;

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
 * SwigType_array_ndim()
 *
 * Returns the number of dimensions of an array.
 * ----------------------------------------------------------------------------- */

int SwigType_array_ndim(DOHString_or_char *t) {
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

DOHString *SwigType_array_getdim(DOHString_or_char *t, int n) {

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

void SwigType_array_setdim(DOHString_or_char *t, int n, DOHString_or_char *rep) {
  DOHString *result = 0;
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
 * SwigType_default()
 *
 * Create the default string for this datatype.   This takes a type and strips it
 * down to its most primitive form--resolving all typedefs and removing operators.
 *
 * Rules:
 *     Pointers:      p.SWIGPOINTER
 *     References:    r.SWIGREFERENCE
 *     Arrays:        a().SWIGARRAY
 *     Types:         SWIGTYPE
 *
 * ----------------------------------------------------------------------------- */

DOHString *SwigType_default(DOHString_or_char *t) {
  DOHString *r1, *def;
  DOHString *r = NewString(t);

  while ((r1 = SwigType_typedef_resolve(r))) {
    Delete(r);
    r = r1;
  }
  
  if (SwigType_ispointer(r)) {
    def = NewString("p.SWIGPOINTER");
  } else if (SwigType_isreference(r)) {
    def = NewString("r.SWIGREFERENCE");
  } else if (SwigType_isarray(r)) {
    def = NewString("a().SWIGARRAY");
  } else {
    def = NewString("SWIGTYPE");
  }
  Delete(r);
  return def;
}

/* -----------------------------------------------------------------------------
 * SwigType_str(DOH *s, DOH *id)
 *
 * Create a C string representation of a datatype.
 * ----------------------------------------------------------------------------- */

DOHString *
SwigType_str(DOHString *s, DOHString_or_char *id)
{
  DOHString *result;
  DOHString *element = 0, *nextelement;
  DOHList *elements;
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
    if (SwigType_ispointer(element)) {
      Insert(result,0,"*");
      if ((nextelement) && ((SwigType_isfunction(nextelement) || (SwigType_isarray(nextelement))))) {
	Insert(result,0,"(");
	Append(result,")");
      }
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
	Delete(p);
      }
      Append(result,")");
      Delete(parms);
    } else if (SwigType_isqualifier(element)) {
      DOH *q = 0;
      q = SwigType_parm(element);
      Insert(result,0," ");
      Insert(result,0,q);
      Delete(q);
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

DOHString *
SwigType_lstr(DOHString *s, DOHString_or_char *id)
{
  DOHString *result;
  DOHString *element = 0, *nextelement;
  DOHList *elements;
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
    if (SwigType_ispointer(element)) {
      Insert(result,0,"*");
      if ((nextelement) && ((SwigType_isfunction(nextelement) || (SwigType_isarray(nextelement))))) {
	Insert(result,0,"(");
	Append(result,")");
      }
    } else if (SwigType_isreference(element)) {
      Insert(result,0,"*");
    } else if (SwigType_isarray(element)) {
      DOH *size;
      Insert(result,0,"*");
      while (nextelement && (SwigType_isarray(nextelement))) {
	i++;
	nextelement = Getitem(elements,i+1);
      }
      if ((nextelement) && ((SwigType_isfunction(nextelement) || (SwigType_isarray(nextelement))))) {
	Insert(result,0,"(");
	Append(result,")");
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
	Delete(p);
      }
      Append(result,")");
      Delete(parms);
    } else if (SwigType_isqualifier(element)) {
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
 * SwigType_rcaststr()
 *
 * Produces a casting string that maps the type returned by lstr() to the real 
 * datatype printed by str().
 * ----------------------------------------------------------------------------- */

DOHString *SwigType_rcaststr(DOHString *s, DOHString_or_char *name) {
  DOHString *result, *cast;
  DOHString *element = 0, *nextelement;
  DOHList *elements;
  int      nelements, i;
  int      clear = 1;
  int      firstarray = 1;

  result = NewString("");
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
    if (SwigType_ispointer(element)) {
      Insert(result,0,"*");
      if ((nextelement) && ((SwigType_isfunction(nextelement) || (SwigType_isarray(nextelement))))) {
	Insert(result,0,"(");
	Append(result,")");
      }
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
	Delete(p);
      }
      Append(result,")");
      Delete(parms);
    } else if (SwigType_isqualifier(element)) {
      DOH *q = 0;
      q = SwigType_parm(element);
      Insert(result,0," ");
      Insert(result,0,q);
      Delete(q);
      clear = 0;
    } else {
      Insert(result,0," ");
      Insert(result,0,element);
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
  return cast;
}


/* -----------------------------------------------------------------------------
 * SwigType_lcaststr()
 *
 * Casts a variable from the real type to the local datatype.
 * ----------------------------------------------------------------------------- */

DOHString *SwigType_lcaststr(DOHString *s, DOHString_or_char *name) {
  DOHString *result;

  result = NewString("");

  if (SwigType_isarray(s)) {
    Printf(result,"(%S)%s", SwigType_lstr(s,0),name);
  } else if (SwigType_isreference(s)) {
    Printf(result,"(%S)", SwigType_lstr(s,0));
    if (name) 
      Printf(result,"&%s", name);
  } else if (SwigType_isqualifier(s)) {
    Printf(result,"(%S)%s", SwigType_lstr(s,0),name);
  } else {
    if (name)
      Append(result,name);
  }
  return result;
}

/* -----------------------------------------------------------------------------
 * Scope handling
 *
 * These functions are used to manipulate typedefs and scopes.
 * ----------------------------------------------------------------------------- */

#define MAX_SCOPE 8

static DOHHash   *type_scopes = 0;              /* Hash table of scope names           */
static DOHHash   *scopes[MAX_SCOPE];            /* List representing the current scope */
static DOHString *scopenames[MAX_SCOPE];        /* Names of the various scopes         */
static int      scope_level = 0;

static void init_scopes() {
  if (type_scopes) return;
  type_scopes = NewHash();
  scopes[scope_level] = NewHash();
  scopenames[scope_level] = NewString("::");
  Setattr(type_scopes,"::",scopes[scope_level]);
}

/* -----------------------------------------------------------------------------
 * SwigType_typedef()
 *
 * Defines a new typedef. Returns -1 if the type name is already defined.
 * ----------------------------------------------------------------------------- */

int SwigType_typedef(DOHString_or_char *type, DOHString_or_char *name) {
  init_scopes();
  if (Getattr(scopes[scope_level],name)) return -1;
  Setattr(scopes[scope_level],name,type);
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

void SwigType_set_scope_name(DOHString_or_char *name) {
  DOHString *key;
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

void SwigType_merge_scope(DOHHash *scope, DOHString_or_char *prefix) {
  DOHString *name;
  DOHString *key;
  DOHString *type;

  init_scopes();
  key = Firstkey(scope);
  while (key) {
    type = Getattr(scope,key);
    if (prefix) {
      name = NewStringf("%s::%s",prefix,key);
    } else {
      name = NewString(key);
    }
    Setattr(scopes[scope_level],name,type);
    key = Nextkey(scope);
  }
}

/* -----------------------------------------------------------------------------
 * SwigType_pop_scope()
 *
 * Pop off the last scope and perform a merge operation.  Returns the hash
 * table for the scope that was popped off.
 * ----------------------------------------------------------------------------- */

DOHHash *SwigType_pop_scope() {
  DOHHash *s;
  DOHString *prefix;
  init_scopes();
  if (scope_level == 0) return 0;
  prefix = scopenames[scope_level];
  s = scopes[scope_level--];
  SwigType_merge_scope(s,prefix);
  return s;
}

/* ----------------------------------------------------------------------------- 
 * SwigType_typedef_resolve()
 *
 * Resolves a typedef and returns a new type string.  Returns 0 if there is no
 * typedef mapping.
 * ----------------------------------------------------------------------------- */

DOHString *SwigType_typedef_resolve(DOHString_or_char *t) {
  DOHString *base;
  DOHString *type;
  DOHString *r;
  int level;

  init_scopes();
  base = SwigType_base(t);

  level = scope_level;
  while (level >= 0) {
    /* See if we know about this type */
    type = Getattr(scopes[scope_level],base);
    if (type) break;
    level--;
  }
  if (level < 0) {
    Delete(base);
    return 0;
  }
  r = SwigType_prefix(t);
  Append(r,type);
  return r;
}


/* ----------------------------------------------------------------------------- 
 * SwigType_istypedef()
 *
 * Checks a typename to see if it is a typedef.
 * ----------------------------------------------------------------------------- */

int SwigType_istypedef(DOHString_or_char *t) {
  DOHString *base, *type;
  int level;

  base = SwigType_base(t);
  level = scope_level;
  while (level >= 0) {
    /* See if we know about this type */
    type = Getattr(scopes[scope_level],base);
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
 * SwigType_cmp()
 *
 * Compares two type-strings using all available typedef information.  Returns 0
 * if equal, 1 if not. 
 * ----------------------------------------------------------------------------- */

int SwigType_cmp(DOHString_or_char *tpat, DOHString_or_char *type) {
  DOHString *r, *s;
  char *p, *t;

  p = Char(tpat);
  t = Char(type);

  if (strcmp(p,t) == 0) return 0;
  
  r = SwigType_typedef_resolve(type);
  while (r) {
    t = Char(r);
    if (strcmp(p,t) == 0) {
      Delete(r);
      return 0;
    }
    s = SwigType_typedef_resolve(r);
    Delete(r);
    r = s;
  }
  return 1;
}

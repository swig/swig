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
 * is that SWIG might be extended to interact with data encodings such as
 * XML in which case a type could be provided as follows:
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
 * In either case, it's probably best to avoid characters such as '&'
 * or '<'.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * StringType_add_pointer()
 *
 * Adds a pointer constructor to a type
 * ----------------------------------------------------------------------------- */

void
StringType_add_pointer(DOHString *t) {
  Insert(t,0,"p.");
}

/* -----------------------------------------------------------------------------
 * StringType_add_array()
 *
 * Adds an array constructor to a type
 * ----------------------------------------------------------------------------- */

void
StringType_add_array(DOHString *t, DOHString *size) {
  char temp[256];
  sprintf(temp,"a(%s).", Char(size));
  Insert(t,0,temp);
}

/* -----------------------------------------------------------------------------
 * StringType_add_reference()
 *
 * Adds a reference constructor to a type.
 * ----------------------------------------------------------------------------- */

void
StringType_add_reference(DOHString *t) {
  Insert(t,0,"r.");
}

/* -----------------------------------------------------------------------------
 * StringType_add_qualifier()
 *
 * Adds a qualifier to a type
 * ----------------------------------------------------------------------------- */

void
StringType_add_qualifier(DOHString *t, DOHString *qual) {
  char temp[256];
  sprintf(temp,"q(%s).",Char(qual));
  Insert(t,0,temp);
}

/* -----------------------------------------------------------------------------
 * StringType_add_function()
 *
 * Adds a function to a type. Accepts a list of abstract types as parameters.
 * These abstract types should be passed as a list of type-strings.
 * ----------------------------------------------------------------------------- */

void
StringType_add_function(DOHString *t, DOHList *parms) {
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
    if (*c == '.') return result;
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
    } else if (*c == '{') {
      int nbrace = 1;
      Putc(*c,result);
      c++;
      while(*c) {
	Putc(*c,result);
	if (*c == '{') nbrace++;
	if (*c == '}') {
	  nbrace--;
	  if (nbrace == 0) break;
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
 * StringType_split(DOH *t)
 *
 * Splits a type into it's component parts and returns a list of string.
 * ----------------------------------------------------------------------------- */

DOHList *StringType_split(DOHString_or_char *t) {
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
 * StringType_pop()
 *
 * Pop off the first type-constructor object and update the type
 * ----------------------------------------------------------------------------- */

DOHString *StringType_pop(DOH *t)
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
 * StringType_push()
 *
 * Push a type constructor onto the type
 * ----------------------------------------------------------------------------- */

void StringType_push(DOHString *t, DOHString *cons)
{
  if (!cons) return;
  if (!Len(cons)) return;
  if (Len(t)) {
    int len;
    char *c = Char(cons);
    if (c[strlen(c)-1] != '.')
      Insert(t,0,".");
  }
  Insert(t,0,cons);
}

/* -----------------------------------------------------------------------------
 * StringType_split_parms()
 *
 * Splits a comma separated list of components into strings.
 * ----------------------------------------------------------------------------- */

DOHList *StringType_split_parms(DOHString *p) {
  DOH     *item;
  DOHList *list;
  char *c;

  c = Char(p);
  assert(*c == '(');
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
    } else if (*c == '{') {
      int nbraces = 1;
      Putc(*c,item);
      c++;
      while (*c) {
	Putc(*c,item);
	if (*c == '{') nbraces++;
	if (*c == '}') {
	  nbraces--;
	  if (nbraces == 0) break;
	}
	c++;
      }
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
 * StringType_ispointer()
 * StringType_isarray()
 * StringType_isreference()
 * StringType_isfunction()
 * StringType_isqualifier()
 *
 * Testing functions for querying a datatype
 * ----------------------------------------------------------------------------- */

int StringType_ispointer(DOHString *t) {
  char *c;

  assert(DohIsString(t));
  c = Char(t);
  if (*c == '*') return 1;
  return 0;
}

int StringType_isreference(DOHString *t) {
  char *c;

  assert(DohIsString(t));
  c = Char(t);
  if (*c == '&') return 1;
  return 0;
}

int StringType_isarray(DOHString *t) {
  char *c;

  assert(DohIsString(t));
  c = Char(t);
  if (*c == '[') return 1;
  return 0;
}

int StringType_isfunction(DOHString *t) {
  char *c;

  assert(DohIsString(t));
  c = Char(t);
  if (*c == '(') return 1;
  return 0;
}

int StringType_isqualifier(DOHString *t) {
  char *c;

  assert(DohIsString(t));
  c = Char(t);
  if (*c == '+') return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 * StringType_base()
 *
 * Returns the base of a datatype.
 * ----------------------------------------------------------------------------- */

DOHString *StringType_base(DOHString *t) {
  char *c, *d;

  assert(DohIsString(t));
  c = Char(t);
  d = c + strlen(c);
  while (d > c) {
    d--;
    if (*d == '.') return NewString(d+1);
  }
  return NewString(c);
}

/* -----------------------------------------------------------------------------
 * StringType_cstr(DOH *s, DOH *id)
 *
 * Create a C string representation of a datatype.
 * ----------------------------------------------------------------------------- */

DOHString *
StringType_cstr(DOHString *s, DOHString_or_char *id)
{
  DOHString *result;
  DOHString *element, *nextelement;
  DOHList *elements;
  int nelements, i;
  char *c;

  if (id) {
    result = NewString(Char(id));
  } else {
    result = NewString("");
  }

  elements = StringType_split(s);
  Printf(stdout,"%s\n",elements);
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
    if (StringType_ispointer(element)) {
      Insert(result,0,"*");
      if ((nextelement) && ((StringType_isfunction(nextelement) || (StringType_isarray(nextelement))))) {
	Insert(result,0,"(");
	Append(result,")");
      }
    }
    else if (StringType_isreference(element)) Insert(result,0,"&");
    else if (StringType_isarray(element)) Append(result,element);
    else if (StringType_isfunction(element)) {
      DOH *parms, *p;
      int j, plen;
      Append(result,"(");
      parms = StringType_split_parms(element);
      plen = Len(parms);
      for (j = 0; j < plen; j++) {
	p = StringType_cstr(Getitem(parms,j),0);
	Append(result,p);
	if (j < (plen-1)) Append(result,",");
	Delete(p);
      }
      Append(result,")");
      Delete(parms);
    } else if (StringType_isstruct(element)) {
      DOH *members, *m;
      int j, mlen;
      Append(result,"{");
      members = StringType_split_struct(element);
      mlen = Len(members);
      for (j = 0; j < mlen; j++) {
	m = StringType_cstr(Getitem(members,j),0);
	Append(result,m);
	if (j < (mlen-1)) Append(result,";");
	Delete(m);
      }
      Append(result,"}");
      Delete(members);
    } else if (StringType_isqualifier(element)) {
      Insert(result,0, " ");
      Insert(result,0,Char(element)+1);

    } else {
      Insert(result,0," ");
      Insert(result,0,element);
    }
    element = nextelement;
  }
  return result;
}

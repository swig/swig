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
 * One of the goals of SWIG2.0 is to provide a standardized representation
 * of parse trees using XML.   However, it order to do this, it is necessary
 * to provide a textual representation of all parsing elements including datatypes.
 * Unfortunately, type systems are relatively complicated--making a
 * low-level or direct XML representation unnecessarily complicated to work
 * with.  For example, you probably wouldn't want to do this:
 *
 *       <type><pointer><array size="500"><pointer><pointer>int
 *             </pointer></pointer></array></pointer></type>
 *        
 * The purpose of this module is to provide a general purpose type system
 * in which types are represented as simple text strings.   The goal of
 * this representation is to make it extremely easy to specify types in
 * XML documents, reduce memory overhead, and to allow fairly easy type
 * manipulation by anyone who wants to play with the type system.
 *
 * General idea:
 *
 * Types are represented by a base type (e.g., "int") and a collection of
 * type elements applied to the base (e.g., pointers, arrays, etc...).
 * 
 * Encoding:
 *
 * Types are encoded as strings of type constructors separated by '.' delimeters.
 *
 *            String Encoding             C Example
 *            ---------------             ---------
 *            *.*.i-32                    int **
 *            [300].[400].i-32            int [300][400]
 *            *.+const.c-8                char const *
 * 
 * '*'                = Pointer
 * '&'                = Reference
 * '[...]'            = Array
 * '(..,..)'          = Function
 * '{s/tag/..,..}'    = Structure (/tag/ optional)
 * '{u/tag/..,..}'    = Union (/tag/ optional)
 * '{c/tag/..,..}'    = Class (/tag/ optional)
 * '</t/n=v,n=,..>'   = Enum (/tag/ optional, n = name, 
 *                            v = value (optional))
 * '+str'             = Qualifier
 * 'i-w'              = w-bit signed integer
 * 'u-w'              = w-bit unsigned integer
 * 'c-w'              = w-bit character
 *
 * for structures, unions, classes, and enums, a missing body (no curly braces)
 * is denoted by a backslash (\) where the body would appear.  See examples.
 *
 * e.g. '*.+const.i-64'        pointer to const 64-bit integer
 * '(si-32,*.i-32).c-8         function taking 32-bit integer and
 *                              pointer to 32-bit integer and
 *                              returning 8-bit character
 * '{s/Foo/i-32,*.c-8}'        structure, tagged 'Foo', containing a
 *                              32-bit integer and a pointer to 
 *                              8-bit character
 * '{si-32,*.c-8}'             same structure, without tag
 * '{ui-32,*.c-8}'             union with same members, without tag
 * '&</Nums/one=1,two,three>'  reference to enumeration, tagged
 *                              'Nums', mapping 'one' to 1, as well as
 *                              'two' and 'three'.
 * '&</Nums/\>'                same enum, without its body
 *
 * The encoding follows the order that you might describe a type in words.
 * For example "*.[200].int" is "A pointer to array of int's" and 
 * "*.+const.char" is "a pointer to a const char".
 *
 * This representation is particularly convenient because string operations
 * can be used to combine and manipulate types.  For example, a type could be
 * formed by combining two strings such as the following:
 *
 *        "*.*." + "[400].int" = "*.*.[400].int"
 *
 * Similarly, one could strip a 'const' declaration from a type doing something
 * like this:
 *
 *        Replace(t,"+const.","",DOH_REPLACE_ANY)
 *
 * The string representation of types also provides a convenient way to 
 * build typemaps and other pattern matching rules against type information.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * StringType_add_pointer()
 *
 * Adds a pointer constructor to a type
 * ----------------------------------------------------------------------------- */

void 
StringType_add_pointer(DOHString *t) {
  assert(DohIsString(t));
  Insert(t,0,"*.");
}

/* -----------------------------------------------------------------------------
 * StringType_add_array()
 *
 * Adds an array constructor to a type
 * ----------------------------------------------------------------------------- */

void 
StringType_add_array(DOHString *t, DOHString *size) {
  assert(DohIsString(t));
  Insert(t,0,"].");
  Insert(t,0,size);
  Insert(t,0,"[");
}

/* -----------------------------------------------------------------------------
 * StringType_add_reference()
 *
 * Adds a reference constructor to a type.
 * ----------------------------------------------------------------------------- */

void 
StringType_add_reference(DOHString *t) {
  assert(DohIsString(t));
  Insert(t,0,"&.");
}

/* -----------------------------------------------------------------------------
 * StringType_add_qualifier()
 *
 * Adds a qualifier to a type
 * ----------------------------------------------------------------------------- */

void 
StringType_add_qualifier(DOHString *t, DOHString *qual) {
  assert(DohIsString(t));
  Insert(t,0,".");
  Insert(t,0,qual);
  Insert(t,0,"+");
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

  assert(DohIsString(t));
  Insert(t,0,").");
  pstr = NewString("");
  l = Len(parms);
  Putc('(',pstr);
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

DOHList *StringType_split(DOH *t) {
  DOH     *item;
  DOHList *list;
  char *c;
  int len;

  assert(DohIsString(t));
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

  assert(DohIsString(t));
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
  assert(DohIsString(t));
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

  assert(DohIsString(p));
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
 * StringType_get_tag()
 *
 * Returns the tag for a struct/enum/whatnot
 * ----------------------------------------------------------------------------- */

DOHString *StringType_get_tag(DOHString *s) {
   char *c = Char(s);

   if (*c == '{')
      c += 2;
   else if (*c == '<')
      c++;
   else
      assert(0);

   if (*c == '/') {
      char *rv, *p;
      c++;
      p = strchr(c, (int)'/');
      if (!p) return NULL;
      rv = DohMalloc(p - c + 1);
      memmove(rv, c, p - c);
      rv[p - c] = 0;
      return rv;
   }
   else
      return NULL;
}

/* -----------------------------------------------------------------------------
 * StringType_split_enum()
 *
 * Splits a comma separated list of enum elements
 * ----------------------------------------------------------------------------- */

DOHList *StringType_split_enum(DOHString *s) {
   DOHList *list;
   DOH     *item;
   char    *c = Char(s);

   assert(*c == '<');
   c++;
   if (*c == '/') {
      c++;
      while (*c)
	 if (*(c++) == '/') break;
   }
   if (*c == '\\')
      return NULL;		/* no body at all */

   list = NewList();
   item = NewString("");
   while (*c)
   {
      if (*c == ',') {
	 Append(list, item);
	 Delete(item);
	 item = NewString("");
      } else if (*c == '>')
	 break;
      else
	 Putc(*c, item);
      c++;
   }
   Append(list, item);
   Delete(item);
   return list;
}

/* -----------------------------------------------------------------------------
 * StringType_split_struct()
 *
 * Splits a comma separated list of structure components
 * ----------------------------------------------------------------------------- */

DOHList *StringType_split_struct(DOHString *p) {
  DOH     *item;
  DOHList *list;
  char    *c;

  assert(DohIsString(p));
  c = Char(p);
  assert(*c == '{');
  c++;
  assert(*c == 's' || *c == 'c' || *c == 'u');
  c++;
  if (*c == '/') {
     c++;
     while (*c)
	if (*(c++) == '/') break;
  }
  if (*c == '\\')
     return NULL;		/* no body at all */
  list = NewList();
  item = NewString("");
  while (*c) {
    if (*c == ',') {
      Append(list,item);
      Delete(item);
      item = NewString("");
    } else if (*c == '{') {
      int nbrace = 1;
      Putc(*c,item);
      c++;
      while (*c) {
	Putc(*c,item);
	if (*c == '{') nbrace++;
	if (*c == '}') {
	  nbrace--;
	  if (nbrace == 0) break;
	}
	c++;
      }
    } else if (*c == '}') {
      break;
    } else if (*c == '(') {
      int nparen = 1;
      Putc(*c,item);
      c++;
      while (*c) {
	Putc(*c,item);
	if (*c == '(') nparen++;
	if (*c == ')') {
	  nparen--;
	  if (nparen == 0) break;
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
 * StringType_isstruct()
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

int StringType_isstruct(DOHString *t) {
  char *c;

  assert(DohIsString(t));
  c = Char(t);
  if (*c == '{') return 1;
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

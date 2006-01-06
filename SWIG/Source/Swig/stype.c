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
#include "cparse.h"
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
  case T_COMPLEX:
    return NewString("complex");
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
    break;
  }
  return NewStringEmpty();
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
 * SwigType_ispointer()
 * SwigType_ispointer_return()
 * SwigType_isarray()
 * SwigType_isreference()
 * SwigType_isfunction()
 * SwigType_isqualifier()
 *
 * Testing functions for querying a raw datatype
 * ----------------------------------------------------------------------------- */

int SwigType_ispointer_return(SwigType *t) {
  char* c;
  int idx;
  if (!t) return 0;
  c = Char(t);
  idx = strlen(c)-4;
  if (idx >= 0) {
       return (strcmp(c+idx, ").p.") == 0);
  }
  return 0;
}

int SwigType_isreference_return(SwigType *t) {
  char* c;
  int idx;
  if (!t) return 0;
  c = Char(t);
  idx = strlen(c)-4;
  if (idx >= 0) {
       return (strcmp(c+idx, ").r.") == 0);
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
  if (SwigType_isreference(qt) || SwigType_isarray(qt)) {
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
 *     Enums:         enum SWIGTYPE
 *
 * Note: if this function is applied to a primitive type, it returns NULL.  This
 * allows recursive application for special types like arrays.
 * ----------------------------------------------------------------------------- */

#ifdef SWIG_DEFAULT_CACHE
static Hash *default_cache = 0;
#endif

#define SWIG_NEW_TYPE_DEFAULT
/* The new default type resolution method:

1.- It preserves the original mixed types, then it goes 'backward'
    first deleting the qualifier, then the inner types
    
    typedef A *Aptr;
    const Aptr&;
    r.q(const).Aptr       -> r.q(const).p.SWIGTYPE
    r.q(const).p.SWIGTYPE -> r.p.SWIGTYPE
    r.p.SWIGTYPE          -> r.SWIGTYPE
    r.SWIGTYPE            -> SWIGTYPE


    enum Hello {};
    const Hello& hi;
    r.q(const).Hello          -> r.q(const).enum SWIGTYPE
    r.q(const).enum SWIGTYPE  -> r.enum SWIGTYPE
    r.enum SWIGTYPE           -> r.SWIGTYPE
    r.SWIGTYPE                -> SWIGTYPE

    int a[2][4];
    a(2).a(4).int           -> a(ANY).a(ANY).SWIGTYPE
    a(ANY).a(ANY).SWIGTYPE  -> a(ANY).a().SWIGTYPE
    a(ANY).a().SWIGTYPE     -> a(ANY).p.SWIGTYPE
    a(ANY).p.SWIGTYPE       -> a(ANY).SWIGTYPE
    a(ANY).SWIGTYPE         -> a().SWIGTYPE
    a().SWIGTYPE            -> p.SWIGTYPE
    p.SWIGTYPE              -> SWIGTYPE
*/

static 
void SwigType_add_default(String *def, SwigType *nr)
{
  if (Strcmp(nr,"SWIGTYPE") == 0) {
    StringAppend(def,"SWIGTYPE");
  } else {
    String *q = SwigType_isqualifier(nr) ? SwigType_pop(nr) : 0;
    if (q && strstr(Char(nr),"SWIGTYPE")) {
      StringAppend(def, nr);
    } else {
      String *nd = SwigType_default(nr);
      if (nd) {
	String *bdef = nd;
	if (q) {
	  bdef = NewStringf("%s%s", q, nd);
	  if ((Strcmp(nr,bdef) == 0)) {
	    Delete(bdef);
	    bdef = nd;
	  } else {
	    Delete(nd);
	  }
	}
	StringAppend(def,bdef);
	Delete(bdef);
      } else {
	StringAppend(def,nr);
      }
    }
    Delete(q);
  }
}


SwigType *SwigType_default(SwigType *t) {
  String *r1, *def;
  String *r = 0;
  char *cr;

#ifdef SWIG_DEFAULT_CACHE
  if (!default_cache) default_cache = NewHash();
  
  r = Getattr(default_cache,t);
  if (r) {
    return Copy(r);
  }
#endif
 
  if (SwigType_isvarargs(t)) {
    return 0;
  }

  r = t;
  while ((r1 = SwigType_typedef_resolve(r))) {
    if (r != t) Delete(r);
    r = r1;
  }
  if (SwigType_isqualifier(r)) {
    String *q;
    if (r == t) r = Copy(t);
    q = SwigType_pop(r);
    if (strstr(Char(r),"SWIGTYPE")) {
      Delete(q);
      def = r;
      return def;
    }
    Delete(q);
  }
  cr = Char(r);
  if (strcmp(cr,"p.SWIGTYPE") == 0) {
    def = NewString("SWIGTYPE");
  } else if (SwigType_ispointer(r)) {
#ifdef SWIG_NEW_TYPE_DEFAULT
    SwigType *nr = Copy(r);
    SwigType_del_pointer(nr);
    def = SwigType_isfunction(nr) ? 
      NewStringEmpty() : NewString("p.");
    SwigType_add_default(def, nr);
    Delete(nr);
#else
    def = NewString("p.SWIGTYPE");
#endif
  } else if (strcmp(cr,"r.SWIGTYPE") == 0) {
    def = NewString("SWIGTYPE");
  } else if (SwigType_isreference(r)) {
#ifdef SWIG_NEW_TYPE_DEFAULT
    SwigType *nr = Copy(r);
    SwigType_del_reference(nr);
    def = NewString("r.");
    SwigType_add_default(def, nr);
    Delete(nr);
#else
    def = NewString("r.SWIGTYPE");
#endif
  } else if (SwigType_isarray(r)) {
    if (strcmp(cr,"a().SWIGTYPE") == 0) {
      def = NewString("p.SWIGTYPE");
    } else if (strcmp(cr,"a(ANY).SWIGTYPE") == 0) {
      def = NewString("a().SWIGTYPE");
    } else {
      int i, empty = 0;
      int ndim = SwigType_array_ndim(r);
      SwigType *nr = Copy(r);
      for (i = 0; i < ndim; i++) {
	String *dim = SwigType_array_getdim(r,i);
	if (!Len(dim)) {
	  char *c = Char(nr);
	  empty = strstr(c,"a(ANY).") != c;
	}
	Delete(dim);
      }
      if (empty) {
	def = NewString("a().");
      } else {
	def = NewString("a(ANY).");
      }
#ifdef SWIG_NEW_TYPE_DEFAULT
      SwigType_del_array(nr);
      SwigType_add_default(def, nr);
#else
      StringAppend(def,"SWIGTYPE");
#endif
      Delete(nr);
    }
  } else if (SwigType_ismemberpointer(r)) {
    if (strcmp(cr,"m(CLASS).SWIGTYPE") == 0) {
      def = NewString("p.SWIGTYPE");
    } else {
      def = NewString("m(CLASS).SWIGTYPE");
    }
  } else if (SwigType_isenum(r)) {
    if (strcmp(cr,"enum SWIGTYPE") == 0) {
      def = NewString("SWIGTYPE");
    } else {
      def = NewString("enum SWIGTYPE");
    }
  } else if (SwigType_isfunction(r)) {
    if (strcmp(cr,"f(ANY).SWIGTYPE") == 0) {
      def = NewString("p.SWIGTYPE");
    } else {
      def = NewString("p.f(ANY).SWIGTYPE");
    }
  } else {
    def = NewString("SWIGTYPE");
  }
  if (r != t) Delete(r);
  if (StringEqual(def,t)) {
    Delete(def);
    def = 0;
  }

#ifdef SWIG_DEFAULT_CACHE
  /* The cache produces strange results, see enum_template.i case */
  if (def) {
    String *cdef  = Copy(def);
    Setattr(default_cache,t, cdef); 
    Delete(cdef);
  }
#endif

  /* Printf(stderr,"type : def %s : %s\n", t, def);  */

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
  int     i, sz;
  char   *d = Char(t);
  char   *c = strstr(d,"<(");

  if (!c) return NewString(t);

  r = NewStringWithSize(d, c - d);
  if (*(c - 1) == '<')  Putc(' ',r);
  Putc('<',r);
  
  p = SwigType_parmlist(c+1);
  sz = Len(p);
  for (i = 0; i < sz; i++) {
    String *str = SwigType_str(Getitem(p,i),0);
    StringAppend(r,str);
    if ((i+1) < sz) Putc(',',r);
    Delete(str);
  }
  Putc(' ',r);
  Putc('>',r);
  suffix = SwigType_templatesuffix(t);
  StringAppend(r,suffix);
  Delete(suffix);
  Delete(p);
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
    result = NewString(id);
  } else {
    result = NewStringEmpty();
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
	StringAppend(result,")");
      }
    } else if (SwigType_ismemberpointer(element)) {
      String *q;
      q = SwigType_parm(element);
      Insert(result,0,"::*");
      Insert(result,0,q);
      if ((nextelement) && ((SwigType_isfunction(nextelement) || (SwigType_isarray(nextelement))))) {
	Insert(result,0,"(");
	StringAppend(result,")");
      }
      Delete(q);
    }
    else if (SwigType_isreference(element)) {
      Insert(result,0,"&");
      if ((nextelement) && ((SwigType_isfunction(nextelement) || (SwigType_isarray(nextelement))))) {
	Insert(result,0,"(");
	StringAppend(result,")");
      }
    }  else if (SwigType_isarray(element)) {
      DOH *size;
      StringAppend(result,"[");
      size = SwigType_parm(element);
      StringAppend(result,size);
      StringAppend(result,"]");
      Delete(size);
    } else if (SwigType_isfunction(element)) {
      DOH *parms, *p;
      int j, plen;
      StringAppend(result,"(");
      parms = SwigType_parmlist(element);
      plen = Len(parms);
      for (j = 0; j < plen; j++) {
	p = SwigType_str(Getitem(parms,j),0);
	StringAppend(result,p);
	if (j < (plen-1)) StringAppend(result,",");
      }
      StringAppend(result,")");
      Delete(parms);
    } else {
      if (strcmp(Char(element),"v(...)") == 0) {
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
  int notypeconv = 0;

  result = NewStringEmpty();
  tc = Copy(s);
  /* Nuke all leading qualifiers */
  while (SwigType_isqualifier(tc)) {
    Delete(SwigType_pop(tc));
  }
  if (SwigType_issimple(tc)) {
    /* Resolve any typedef definitions */
    td = SwigType_typedef_resolve(tc);
    if (td && (SwigType_isconst(td) || SwigType_isarray(td) || SwigType_isreference(td))) {
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
    /* when we see a function, we need to preserve the following types */
    if (SwigType_isfunction(element)) {
      notypeconv = 1;
    }
    if (SwigType_isqualifier(element)) {
      /* Do nothing. Ignore */
    } else if (SwigType_ispointer(element)) {
      StringAppend(result,element);
      firstarray = 0;
    } else if (SwigType_ismemberpointer(element)) {
      StringAppend(result,element);
      firstarray = 0;
    } else if (SwigType_isreference(element)) {
      if (notypeconv) {
	StringAppend(result,element);
      } else {
	StringAppend(result,"p.");
      }
      firstarray = 0;
    } else if (SwigType_isarray(element) && firstarray) {
      if (notypeconv) {
	StringAppend(result,element);
      } else {
	StringAppend(result,"p.");
      }
      firstarray = 0;
    } else if (SwigType_isenum(element)) {
      int anonymous_enum = (Cmp(element,"enum ") == 0); 
      if (notypeconv || !anonymous_enum) {
	StringAppend(result,element);
      } else {
	StringAppend(result,"int");
      }
    } else {
      StringAppend(result,element);
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
  int      isarray = 0;

  result = NewStringEmpty();

  if (SwigType_isconst(s)) {
    tc = Copy(s);
    Delete(SwigType_pop(tc));
    rs = tc;
  } else {
    rs = s;
  }

  td = SwigType_typedef_resolve(rs);
  if (td) {
    if ((SwigType_isconst(td) || SwigType_isarray(td) || SwigType_isreference(td))) {
      elements = SwigType_split(td);
    } else {
      elements = SwigType_split(rs);
    } 
    Delete(td);
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
	StringAppend(result,")");
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
	StringAppend(result,")");
      }
      firstarray = 0;
    } else if (SwigType_isreference(element)) {
	Insert(result,0,"&");
	if ((nextelement) && ((SwigType_isfunction(nextelement) || (SwigType_isarray(nextelement))))) {
	  Insert(result,0,"(");
	  StringAppend(result,")");
	}
	isreference = 1;
    } else if (SwigType_isarray(element)) {
      DOH *size;
      if (firstarray && !isreference) {
	StringAppend(result,"(*)");
	firstarray = 0;
      } else {
	StringAppend(result,"[");
	size = SwigType_parm(element);
	StringAppend(result,size);
	StringAppend(result,"]");
	Delete(size);
	clear = 0;
      }
      isarray = 1;
    } else if (SwigType_isfunction(element)) {
      DOH *parms, *p;
      int j, plen;
      StringAppend(result,"(");
      parms = SwigType_parmlist(element);
      plen = Len(parms);
      for (j = 0; j < plen; j++) {
	p = SwigType_str(Getitem(parms,j),0);
	StringAppend(result,p);
	Delete(p);
	if (j < (plen-1)) StringAppend(result,",");
      }
      StringAppend(result,")");
      Delete(parms);
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
    cast = NewStringEmpty();
  } else {
    cast = NewStringf("(%s)",result);
  }
  if (name) {
    if (isreference) {
      if (isarray) Clear(cast);
      StringAppend(cast,"*");
    }
    StringAppend(cast,name);
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

  result = NewStringEmpty();

  if (SwigType_isarray(s)) {
    String *lstr = SwigType_lstr(s,0);
    Printf(result,"(%s)%s", lstr,name);
    Delete(lstr);
  } else if (SwigType_isreference(s)) {
    String *str = SwigType_str(s,0);
    Printf(result,"(%s)", str);
    Delete(str);
    if (name) 
      StringAppend(result,name);
  } else if (SwigType_isqualifier(s)) {
    String *lstr = SwigType_lstr(s,0);
    Printf(result,"(%s)%s", lstr,name);
    Delete(lstr);
  } else {
    if (name)
      StringAppend(result,name);
  }
  return result;
}


/* keep old mangling since Java codes need it */
String *SwigType_manglestr_default(SwigType *s) {
  char *c;
  String *result = 0;
  String *base = 0;
  SwigType *lt;
  SwigType *sr = SwigType_typedef_qualified(s);
  SwigType *ss = SwigType_typedef_resolve_all(sr);
  
  s = ss;

  if (SwigType_istemplate(ss)) {
    SwigType *ty = Swig_symbol_template_deftype(ss,0);
    Delete(ss);
    ss = ty;
    s = ss;
  }
  Delete(sr);

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
  Replace(base,"enum ","", DOH_REPLACE_ANY);

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
  StringAppend(result,base);
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
  int    i, ilen;
  List   *elem;

  if (!Strstr(t,pat)) return;

  if (StringEqual(t,pat)) {
    Replace(t,pat,rep,DOH_REPLACE_ANY);
    return;
  }
  nt = NewStringEmpty();
  elem = SwigType_split(t);
  ilen = Len(elem);
  for (i = 0; i < ilen; i++) {
    String *e = Getitem(elem,i);
    if (SwigType_issimple(e)) {
      if (StringEqual(e,pat)) {
	/* Replaces a type of the form 'pat' with 'rep<args>' */
	Replace(e,pat,rep,DOH_REPLACE_ANY);
      } else if (SwigType_istemplate(e)) {
         /* Replaces a type of the form 'pat<args>' with 'rep' */
	if (StringEqual(e,pat)) {
	  String *repbase = SwigType_templateprefix(rep);
	  Replace(e,pat,repbase,DOH_REPLACE_ID | DOH_REPLACE_FIRST);
	  Delete(repbase);
	} 
	{
	  String *tsuffix;
	  List *tparms = SwigType_parmlist(e);
	  int j, jlen;
	  String *nt = SwigType_templateprefix(e);
	  StringAppend(nt,"<(");
	  jlen = Len(tparms);
	  for (j = 0; j < jlen; j++) {
	    SwigType_typename_replace(Getitem(tparms,j), pat, rep);
	    StringAppend(nt,Getitem(tparms,j));
	    if (j < (jlen-1)) Putc(',',nt);
	  }
	  tsuffix = SwigType_templatesuffix(e);
	  Printf(nt,")>%s", tsuffix);
	  Delete(tsuffix);
	  Clear(e);
	  StringAppend(e,nt);
	  Delete(nt);
	  Delete(tparms);
	}
      } else if (Swig_scopename_check(e)) {
	String *first, *rest;
	first = Swig_scopename_first(e);
	rest = Swig_scopename_suffix(e);
	SwigType_typename_replace(rest,pat,rep);
	SwigType_typename_replace(first,pat,rep);
	Clear(e);
	Printv(e,first,"::",rest,NIL);
	Delete(first);
	Delete(rest);
      }
    } else if (SwigType_isfunction(e)) {
      int j, jlen;
      List *fparms = SwigType_parmlist(e);
      Clear(e);
      StringAppend(e,"f(");
      jlen = Len(fparms);
      for (j = 0; j < jlen; j++) {
	SwigType_typename_replace(Getitem(fparms,j), pat, rep);
	StringAppend(e,Getitem(fparms,j));
	if (j < (jlen-1)) Putc(',',e);
      }
      StringAppend(e,").");
      Delete(fparms);
    } else if (SwigType_isarray(e)) {
      Replace(e,pat,rep, DOH_REPLACE_ID);
    }
    StringAppend(nt,e);
  }
  Clear(t);
  StringAppend(t,nt);
  Delete(nt);
  Delete(elem);
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
  r = Equal(t2,decl);
  Delete(t);
  Delete(t1);
  Delete(t2);
  return r == 1;
}

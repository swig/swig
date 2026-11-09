/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * stype.c
 *
 * This file provides general support for datatypes that are encoded in
 * the form of simple strings.
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include "cparse.h"
#include <ctype.h>
#include <limits.h>

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
 *  'z.'                = Rvalue reference (&&)
 *  'v.'                = Variadic (...)
 *  'a(n).'             = Array of size n  [n]
 *  'f(..,..).'         = Function with arguments  (args)
 *  'q(str).'           = Qualifier, such as const or volatile (cv-qualifier), or noexcept for a function type
 *  'm(cls).'           = Pointer to member (cls::*)
 *  'auto.'             = C++20 constrained placeholder marker, always paired
 *                        with a 'c(<id>)' base, e.g. 'auto.c(Numeric)'
 *                        represents 'Numeric auto'.
 *  'c(<id>)'           = Base carrying the concept-id of a C++20
 *                        constrained 'Concept auto' placeholder.
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
 * More examples:
 *
 *        String Encoding                     C++ Example
 *        ---------------                     -----------
 *        p.f(bool).r.q(const).long           const long & (*)(bool)
 *        m(Funcs).q(const).f(bool).long      long (Funcs::*)(bool) const
 *        r.q(const).m(Funcs).f(int).long     long (Funcs::*const &)(int)
 *        m(Funcs).z.q(const).f(bool).long    long (Funcs::*)(bool) const &&
 *        p.q(noexcept).f(bool).long          long (*)(bool) noexcept
 *        m(Funcs).r.q(noexcept).f().long     long (Funcs::*)() & noexcept
 *
 * Function decl examples:
 *
 *        f(bool).                            long a(bool);
 *        r.f(bool).                          long b(bool) &;
 *        z.f(bool).                          long c(bool) &&;
 *        z.q(const).f(bool).                 long d(bool) const &&;
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
  switch (t) {
  case T_BOOL:
    return NewString("bool");
  case T_UNKNOWN:
    /* Handle like T_INT since we used to just use T_INT where we now use
     * T_UNKNOWN.
     */
  case T_INT:
    return NewString("int");
  case T_UINT:
    return NewString("unsigned int");
  case T_SHORT:
    return NewString("short");
  case T_USHORT:
    return NewString("unsigned short");
  case T_LONG:
    return NewString("long");
  case T_ULONG:
    return NewString("unsigned long");
  case T_FLOAT:
    return NewString("float");
  case T_DOUBLE:
    return NewString("double");
  case T_LONGDOUBLE:
    return NewString("long double");
  case T_FLTCPLX:
    return NewString("float _Complex");
  case T_COMPLEX:
    return NewString("_Complex");
  case T_CHAR:
    return NewString("char");
  case T_SCHAR:
    return NewString("signed char");
  case T_UCHAR:
    return NewString("unsigned char");
  case T_STRING:
    {
      SwigType *t = NewString("char");
      SwigType_add_qualifier(t, "const");
      SwigType_add_pointer(t);
      return t;
    }
  case T_WCHAR:
    return NewString("wchar_t");
  case T_WSTRING:
    {
      SwigType *t = NewString("wchar_t");
      SwigType_add_qualifier(t, "const");
      SwigType_add_pointer(t);
      return t;
    }
  case T_LONGLONG:
    return NewString("long long");
  case T_ULONGLONG:
    return NewString("unsigned long long");
  case T_VOID:
    return NewString("void");
  case T_AUTO:
    return NewString("auto");
  default:
    break;
  }
  return NewStringEmpty();
}

/* -----------------------------------------------------------------------------
 * SwigType_push()
 *
 * Push a type constructor onto the type
 * ----------------------------------------------------------------------------- */

void SwigType_push(SwigType *t, String *cons) {
  if (!cons)
    return;
  if (!Len(cons))
    return;

  if (Len(t)) {
    char *c = Char(cons);
    if (c[strlen(c) - 1] != '.')
      Insert(t, 0, ".");
  }
  Insert(t, 0, cons);
}

/* -----------------------------------------------------------------------------
 * SwigType_push_merge_qualifiers()
 *
 * Pushes prefix, the prefix of a type that names a typedef, onto t, the type that the typedef resolves to.  A qualifier at the end of prefix
 * is merged with one that t starts with and goes after any arrays that t starts with, as C++ qualifies the elements of an array.  For example,
 * pushing 'r.q(const).' onto 'q(volatile).p.Foo' and 'q(const).' onto 'a(7).q(volatile).double' gives
 *   r.q(const volatile).p.Foo           Foo *const volatile &
 *   a(7).q(const volatile).double       double const volatile [7]
 * rather than, as SwigType_push() gives,
 *   r.q(const).q(volatile).p.Foo        Foo *volatile const &
 *   q(const).a(7).q(volatile).double    double volatile const[7]
 * ----------------------------------------------------------------------------- */

void SwigType_push_merge_qualifiers(SwigType *t, String *prefix) {
  SwigType *last = SwigType_last(prefix);
  if (last && SwigType_isqualifier(last) && (SwigType_isarray(t) || SwigType_isqualifier(t))) {
    SwigType *arrays = SwigType_isarray(t) ? SwigType_pop_arrays(t) : 0;
    String *qualifiers = SwigType_parm(last);
    String *rest = SwigType_prefix(prefix);
    SwigType_add_qualifier(t, qualifiers);
    SwigType_push(t, arrays);
    SwigType_push(t, rest);
    Delete(rest);
    Delete(qualifiers);
    Delete(arrays);
  } else {
    SwigType_push(t, prefix);
  }
  Delete(last);
}

/* -----------------------------------------------------------------------------
 * SwigType_ispointer_return()
 *
 * Testing functions for querying a raw datatype
 * ----------------------------------------------------------------------------- */

int SwigType_ispointer_return(const SwigType *t) {
  char *c;
  int idx;
  if (!t)
    return 0;
  c = Char(t);
  idx = (int)strlen(c) - 4;
  if (idx >= 0) {
    return (strcmp(c + idx, ").p.") == 0);
  }
  return 0;
}

int SwigType_isreference_return(const SwigType *t) {
  char *c;
  int idx;
  if (!t)
    return 0;
  c = Char(t);
  idx = (int)strlen(c) - 4;
  if (idx >= 0) {
    return (strcmp(c + idx, ").r.") == 0);
  }
  return 0;
}

int SwigType_isconst(const SwigType *t) {
  char *c;
  if (!t)
    return 0;
  c = Char(t);
  if (strncmp(c, "q(", 2) == 0) {
    String *q = SwigType_parm(t);
    if (strstr(Char(q), "const")) {
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

int SwigType_ismutable(const SwigType *t) {
  int r;
  SwigType *qt = SwigType_remove_reference(SwigType_typedef_resolve_all(t));
  while (SwigType_isarray(qt)) {
    Delete(SwigType_pop(qt));
  }
  r = SwigType_isconst(qt);
  Delete(qt);
  return r ? 0 : 1;
}

int SwigType_isenum(const SwigType *t) {
  char *c = Char(t);
  if (!t)
    return 0;
  if (strncmp(c, "enum ", 5) == 0) {
    return 1;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * SwigType_isclasskey()
 *
 * Returns 1 if the type t starts with a class-key as defined by the C++ standard, that is "class", "struct" or "union",
 * as in 'struct S', otherwise 0.  SwigType_isenum() is the equivalent for an enum.
 * ----------------------------------------------------------------------------- */

int SwigType_isclasskey(const SwigType *t) {
  char *c = Char(t);
  if (!t)
    return 0;
  return (strncmp(c, "struct ", 7) == 0) || (strncmp(c, "union ", 6) == 0) || (strncmp(c, "class ", 6) == 0);
}

int SwigType_issimple(const SwigType *t) {
  char *c = Char(t);
  if (!t)
    return 0;
  while (*c) {
    if (c[0] == '<' && c[1] == '(') {
      /* Skip a template argument list "<(...)>", but not a '<' operator such as in an array dimension "a(2 << 1)" */
      int nparen = 1;
      c += 2;
      while (*c && nparen) {
        if (*c == '(')
          nparen++;
        else if (*c == ')')
          nparen--;
        c++;
      }
      continue;
    }
    if (*c == '.')
      return 0;
    c++;
  }
  return 1;
}

/* -----------------------------------------------------------------------------
 * SwigType_default_create()
 *
 * Create the default type for this datatype. This takes a type and strips it
 * down to a generic form first by resolving all typedefs.
 *
 * Rules:
 *     Pointers:              p.SWIGTYPE
 *     References:            r.SWIGTYPE
 *     Arrays no dimension:   a().SWIGTYPE
 *     Arrays with dimension: a(ANY).SWIGTYPE
 *     Member pointer:        m(CLASS).SWIGTYPE
 *     Function pointer:      f(ANY).SWIGTYPE, without the function's qualifiers, such as 'noexcept'
 *     Enums:                 enum SWIGTYPE
 *     Types:                 SWIGTYPE
 *
 * Examples (also see SwigType_default_deduce):
 *
 *  int [2][4]
 *    a(2).a(4).int
 *    a(ANY).a(ANY).SWIGTYPE
 *
 *  struct A {};
 *  typedef A *Aptr;
 *  Aptr const &
 *    r.q(const).Aptr
 *    r.q(const).p.SWIGTYPE
 *
 *  enum E {e1, e2};
 *  enum E const &
 *    r.q(const).enum E
 *    r.q(const).enum SWIGTYPE
 * ----------------------------------------------------------------------------- */

SwigType *SwigType_default_create(const SwigType *ty) {
  SwigType *r = 0;
  List *l;
  Iterator it;
  int numitems;

  if (!SwigType_isvarargs(ty)) {
    SwigType *t = SwigType_typedef_resolve_all(ty);
    r = NewStringEmpty();
    l = SwigType_split(t);
    numitems = Len(l);

    if (numitems >= 1) {
      String *last_subtype = Getitem(l, numitems - 1);
      if (SwigType_isenum(last_subtype))
        Setitem(l, numitems - 1, "enum SWIGTYPE");
      else
        Setitem(l, numitems - 1, "SWIGTYPE");
    }

    for (it = First(l); it.item; it = Next(it)) {
      String *subtype = it.item;
      if (SwigType_isarray(subtype)) {
        if (Equal(subtype, "a()."))
          Append(r, "a().");
        else
          Append(r, "a(ANY).");
      } else if (SwigType_isqualifier(subtype) && SwigType_isfunction(Next(it).item)) {
        /* Drop the qualifiers of a function type, which f(ANY) matches whatever they are */
      } else if (SwigType_isfunction(subtype)) {
        Append(r, "f(ANY).SWIGTYPE");
        break;
      } else if (SwigType_ismemberpointer(subtype)) {
        Append(r, "m(CLASS).SWIGTYPE");
        break;
      } else {
        Append(r, subtype);
      }
    }

    Delete(l);
    Delete(t);
  }

  return r;
}

/* -----------------------------------------------------------------------------
 * SwigType_default_deduce()
 *
 * This function implements type deduction used in the typemap matching rules
 * and is very close to the type deduction used in partial template class
 * specialization matching in that the most specialized type is always chosen.
 * SWIGTYPE is used as the generic type. The basic idea is to repeatedly call
 * this function to find a deduced type until nothing matches.
 *
 * The type t must have already been converted to the default type via a call to
 * SwigType_default_create() before calling this function.
 *
 * Example deductions (matching the examples described in SwigType_default_create),
 * where the most specialized matches are highest in the list:
 *
 *    a(ANY).a(ANY).SWIGTYPE
 *    a(ANY).a().SWIGTYPE
 *    a(ANY).p.SWIGTYPE
 *    a(ANY).SWIGTYPE
 *    a().SWIGTYPE
 *    p.SWIGTYPE
 *    SWIGTYPE
 *
 *    r.q(const).p.SWIGTYPE
 *    r.q(const).SWIGTYPE
 *    r.SWIGTYPE
 *    SWIGTYPE
 *
 *    r.q(const).enum SWIGTYPE
 *    r.enum SWIGTYPE
 *    r.SWIGTYPE
 *    SWIGTYPE
 * ----------------------------------------------------------------------------- */

SwigType *SwigType_default_deduce(const SwigType *t) {
  SwigType *r = NewStringEmpty();
  List *l;
  Iterator it;
  int numitems;

  l = SwigType_split(t);

  numitems = Len(l);
  if (numitems >= 1) {
    String *last_subtype = Getitem(l, numitems - 1);
    int is_enum = SwigType_isenum(last_subtype);

    if (numitems >= 2) {
      String *subtype = Getitem(l, numitems - 2); /* last but one */
      if (SwigType_isarray(subtype)) {
        if (is_enum) {
          /* enum deduction, enum SWIGTYPE => SWIGTYPE */
          Setitem(l, numitems - 1, "SWIGTYPE");
        } else {
          /* array deduction, a(ANY). => a(). => p. */
          const char *deduced_subtype = 0;
          if (Strcmp(subtype, "a().") == 0) {
            deduced_subtype = "p.";
          } else if (Strcmp(subtype, "a(ANY).") == 0) {
            deduced_subtype = "a().";
          } else {
            assert(0);
          }
          Setitem(l, numitems - 2, deduced_subtype);
        }
      } else if (SwigType_ismemberpointer(subtype)) {
        /* member pointer deduction, m(CLASS). => p. */
        Setitem(l, numitems - 2, "p.");
      } else if (is_enum && !SwigType_isqualifier(subtype)) {
        /* enum deduction, enum SWIGTYPE => SWIGTYPE */
        Setitem(l, numitems - 1, "SWIGTYPE");
      } else {
        /* simple type deduction, eg, r.p.p. => r.p. */
        /* also function pointers eg, p.f(ANY). => p. */
        Delitem(l, numitems - 2);
      }
    } else {
      if (is_enum) {
        /* enum deduction, enum SWIGTYPE => SWIGTYPE */
        Setitem(l, numitems - 1, "SWIGTYPE");
      } else {
        /* delete the only item, we are done with deduction */
        Delitem(l, 0);
      }
    }
  } else {
    assert(0);
  }

  for (it = First(l); it.item; it = Next(it)) {
    Append(r, it.item);
  }

  if (Len(r) == 0) {
    Delete(r);
    r = 0;
  }

  Delete(l);
  return r;
}

/* -----------------------------------------------------------------------------
 * SwigType_namestr()
 *
 * Returns a string of the base type.  Takes care of template expansions
 * ----------------------------------------------------------------------------- */

String *SwigType_namestr(const SwigType *t) {
  String *r;
  String *suffix;
  List *p;
  int i, sz;
  char *d = Char(t);
  char *c = strstr(d, "<(");

  if (!c || !strstr(c + 2, ")>"))
    return NewString(t);

  r = NewStringWithSize(d, (int)(c - d));
  if (*(c - 1) == '<')
    Putc(' ', r);
  Putc('<', r);

  p = SwigType_parmlist(c + 1);
  sz = Len(p);
  for (i = 0; i < sz; i++) {
    String *str = SwigType_str(Getitem(p, i), 0);
    /* Avoid creating a <: token, which is the same as [ in C++ - put a space after '<'. */
    if (i == 0 && Len(str))
      Putc(' ', r);
    Append(r, str);
    if ((i + 1) < sz)
      Putc(',', r);
    Delete(str);
  }
  Putc(' ', r);
  Putc('>', r);
  suffix = SwigType_templatesuffix(t);
  if (Len(suffix) > 0) {
    String *suffix_namestr = SwigType_namestr(suffix);
    Append(r, suffix_namestr);
    Delete(suffix_namestr);
  } else {
    Append(r, suffix);
  }
  Delete(suffix);
  Delete(p);
  return r;
}

/* Return a qualifier element with the qualifiers of the qualifier element q, such as 'q(const noexcept).', that are 'noexcept'
   if is_noexcept is set or those that are not if it is not set, or NULL if there are none. */
static SwigType *qualifier_noexcept_part(const SwigType *q, int is_noexcept) {
  SwigType *result = 0;
  String *qualifier_list = SwigType_parm(q);
  List *words = Split(qualifier_list, ' ', INT_MAX);
  Iterator word;
  for (word = First(words); word.item; word = Next(word)) {
    if (!!Equal(word.item, "noexcept") == !!is_noexcept) {
      if (!result)
        result = NewStringEmpty();
      SwigType_add_qualifier(result, word.item);
    }
  }
  Delete(words);
  Delete(qualifier_list);
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_remove_noexcept_qualifier()
 *
 * Removes the 'noexcept' from the qualifier element at the start of t, such as the qualifiers 'q(const noexcept).' of a
 * function type, and the element too if it has no other qualifier.  Returns 1 if t had a 'noexcept' and 0 if not.
 * ----------------------------------------------------------------------------- */

int SwigType_remove_noexcept_qualifier(SwigType *t) {
  SwigType *noexcept_qualifier;
  SwigType *other_qualifiers;
  if (!SwigType_isqualifier(t))
    return 0;
  noexcept_qualifier = qualifier_noexcept_part(t, 1);
  if (!noexcept_qualifier)
    return 0;
  other_qualifiers = qualifier_noexcept_part(t, 0);
  SwigType_del_qualifier(t);
  if (other_qualifiers)
    SwigType_push(t, other_qualifiers);
  Delete(other_qualifiers);
  Delete(noexcept_qualifier);
  return 1;
}

/* Return a copy of the type t without the 'noexcept' of each function type in it, as in 'p.q(noexcept).f(int).int' or
   'm(C).q(const noexcept).f().int', but not in the parameter types of a function. */
static SwigType *function_noexcept_removed(const SwigType *t) {
  SwigType *result = NewStringEmpty();
  List *elements = SwigType_split(t);
  int nelements = Len(elements);
  int i;
  for (i = 0; i < nelements; i++) {
    SwigType *element = Getitem(elements, i);
    if (SwigType_isqualifier(element) && i + 1 < nelements && SwigType_isfunction(Getitem(elements, i + 1))) {
      SwigType *qualifiers = qualifier_noexcept_part(element, 0);
      if (qualifiers)
        Append(result, qualifiers);
      Delete(qualifiers);
    } else {
      Append(result, element);
    }
  }
  Delete(elements);
  return result;
}

/* Return the qualifiers of a function type, such as 'r.q(const noexcept).', as the text that follows its parameter list, 'const & noexcept'. */
static String *function_qualifiers_str(const SwigType *qualifiers) {
  String *result = NewStringEmpty();
  const char *refqualifier = 0;
  int is_noexcept = 0;
  List *elements = SwigType_split(qualifiers);
  Iterator element;
  for (element = First(elements); element.item; element = Next(element)) {
    if (SwigType_isqualifier(element.item)) {
      SwigType *cv_qualifier = qualifier_noexcept_part(element.item, 0);
      SwigType *noexcept_qualifier = qualifier_noexcept_part(element.item, 1);
      if (cv_qualifier) {
        String *cv_qualifiers = SwigType_parm(cv_qualifier);
        Printv(result, Len(result) ? " " : "", cv_qualifiers, NIL);
        Delete(cv_qualifiers);
      }
      if (noexcept_qualifier)
        is_noexcept = 1;
      Delete(cv_qualifier);
      Delete(noexcept_qualifier);
    } else if (SwigType_isreference(element.item)) {
      refqualifier = "&";
    } else if (SwigType_isrvalue_reference(element.item)) {
      refqualifier = "&&";
    }
  }
  if (refqualifier)
    Printv(result, Len(result) ? " " : "", refqualifier, NIL);
  if (is_noexcept)
    Printv(result, Len(result) ? " " : "", "noexcept", NIL);
  Delete(elements);
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_str()
 *
 * Create a C string representation of a datatype.
 * The qualifiers of a function type, such as those of a member function and 'noexcept', follow its parameter list.
 * ----------------------------------------------------------------------------- */

String *SwigType_str(const SwigType *s, const_String_or_char_ptr id) {
  String *result;
  String *element = 0;
  String *nextelement;
  String *forwardelement;
  SwigType *function_qualifiers = 0;
  List *elements;
  int nelements, i;

  if (id) {
    /* Stringify the id expanding templates, for example when the id is a fully qualified class template name. The id is
     * not split into type elements as the declarator 'f(int x)' would otherwise lose its name 'f' as a function element. */
    String *id_str = NewString(id); /* unfortunate copy due to current const limitations */
    result = SwigType_namestr(id_str);
    Delete(id_str);
  } else {
    result = NewStringEmpty();
  }

  elements = SwigType_split(s);
  nelements = Len(elements);

  if (nelements > 0) {
    element = Getitem(elements, 0);
  }
  /* Now, walk the type list and start emitting */
  for (i = 0; i < nelements; i++) {
    if (i < (nelements - 1)) {
      nextelement = Getitem(elements, i + 1);
      forwardelement = nextelement;
      if (SwigType_isqualifier(nextelement)) {
        if (i < (nelements - 2))
          forwardelement = Getitem(elements, i + 2);
      }
    } else {
      nextelement = 0;
      forwardelement = 0;
    }
    if (SwigType_isqualifier(element)) {
      if (!function_qualifiers) {
        if (SwigType_isfunction(nextelement)) {
          /* The qualifiers of a function type go after its parameter list, as for the 'noexcept' in 'p.q(noexcept).f().int' */
          function_qualifiers = Copy(element);
        } else {
          DOH *q = 0;
          q = SwigType_parm(element);
          /* No space after a qualifier with nothing after it, as in 'int (*const)(int)' */
          if (Len(result) > 0) {
            Insert(result, 0, " ");
          }
          Insert(result, 0, q);
          Delete(q);
        }
      }
    } else if (SwigType_ispointer(element)) {
      Insert(result, 0, "*");
      if ((forwardelement) && ((SwigType_isfunction(forwardelement) || (SwigType_isarray(forwardelement))))) {
        Insert(result, 0, "(");
        Append(result, ")");
      }
    } else if (SwigType_ismemberpointer(element)) {
      String *q;
      q = SwigType_parm(element);
      Insert(result, 0, "::*");
      Insert(result, 0, q);
      if ((forwardelement) && ((SwigType_isfunction(forwardelement) || (SwigType_isarray(forwardelement))))) {
        Insert(result, 0, "(");
        Append(result, ")");
      }
      {
        String *next3elements = NewStringEmpty();
        int j;
        for (j = i + 1; j < i + 4 && j < nelements; j++) {
          Append(next3elements, Getitem(elements, j));
        }
        if (SwigType_isfunction(next3elements))
          function_qualifiers = SwigType_pop_function_qualifiers(next3elements);
        Delete(next3elements);
      }
      Delete(q);
    } else if (SwigType_isreference(element)) {
      if (!function_qualifiers)
        Insert(result, 0, "&");
      if ((forwardelement) && ((SwigType_isfunction(forwardelement) || (SwigType_isarray(forwardelement))))) {
        Insert(result, 0, "(");
        Append(result, ")");
      }
    } else if (SwigType_isrvalue_reference(element)) {
      if (!function_qualifiers)
        Insert(result, 0, "&&");
      if ((forwardelement) && ((SwigType_isfunction(forwardelement) || (SwigType_isarray(forwardelement))))) {
        Insert(result, 0, "(");
        Append(result, ")");
      }
    } else if (SwigType_isvariadic(element)) {
      Insert(result, 0, "...");
      if ((forwardelement) && ((SwigType_isfunction(forwardelement) || (SwigType_isarray(forwardelement))))) {
        Insert(result, 0, "(");
        Append(result, ")");
      }
    } else if (strcmp(Char(element), "auto.") == 0) {
      /* C++20 constrained placeholder marker, paired with a c(<id>) base. */
      Insert(result, 0, " ");
      Insert(result, 0, "auto");
    } else if (SwigType_isarray(element)) {
      DOH *size;
      Append(result, "[");
      size = SwigType_parm(element);
      Append(result, size);
      Append(result, "]");
      Delete(size);
    } else if (SwigType_isfunction(element)) {
      DOH *parms, *p;
      int j, plen;
      Append(result, "(");
      parms = SwigType_parmlist(element);
      plen = Len(parms);
      for (j = 0; j < plen; j++) {
        p = SwigType_str(Getitem(parms, j), 0);
        Append(result, p);
        if (j < (plen - 1))
          Append(result, ",");
      }
      Append(result, ")");
      if (function_qualifiers) {
        String *p = function_qualifiers_str(function_qualifiers);
        Append(result, " ");
        Append(result, p);
        Delete(p);
        Delete(function_qualifiers);
        function_qualifiers = 0;
      }
      Delete(parms);
    } else {
      if (strcmp(Char(element), "v(...)") == 0) {
        Insert(result, 0, "...");
      } else if (SwigType_isconcept(element)) {
        /* c(<id>) base - emit just the concept-id, expanding any inner template-id. */
        String *cn = SwigType_parm(element);
        String *cn_namestr = SwigType_namestr(cn);
        Insert(result, 0, " ");
        Insert(result, 0, cn_namestr);
        Delete(cn_namestr);
        Delete(cn);
      } else {
        String *bs = SwigType_namestr(element);
        Insert(result, 0, " ");
        Insert(result, 0, bs);
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
 * SwigType_ltype(const SwigType *ty)
 *
 * Create a locally assignable type
 * ----------------------------------------------------------------------------- */

SwigType *SwigType_ltype(const SwigType *s) {
  String *result;
  String *element;
  SwigType *td, *tc = 0;
  List *elements;
  int nelements, i;
  int firstarray = 1;
  int notypeconv = 0;
  int ignore_member_function_qualifiers = 0;

  result = NewStringEmpty();
  /* Nuke all leading qualifiers */
  tc = SwigType_remove_qualifier(Copy(s));
  if (SwigType_issimple(tc)) {
    /* Resolve any typedef definitions */
    SwigType *tt = Copy(tc);
    td = 0;
    while ((td = SwigType_typedef_resolve(tt))) {
      if (td && (SwigType_isconst(td) || SwigType_isarray(td) || SwigType_isreference(td) || SwigType_isrvalue_reference(td))) {
        /* We need to use the typedef type */
        Delete(tt);
        break;
      } else if (td) {
        Delete(tt);
        tt = td;
      }
    }
    if (td) {
      Delete(tc);
      tc = td;
    }
  }

  elements = SwigType_split(tc);
  nelements = Len(elements);

  /* Now, walk the type list and start emitting */
  for (i = 0; i < nelements; i++) {
    element = Getitem(elements, i);
    /* when we see a function, we need to preserve the following types */
    if (SwigType_isfunction(element)) {
      notypeconv = 1;
      ignore_member_function_qualifiers = 0;
    }
    if (ignore_member_function_qualifiers) {
      /* cv-qualifiers and ref-qualifiers up until the f() element have already been added */
    } else if (SwigType_isqualifier(element)) {
      /* swallow cv-qualifiers, but not the 'noexcept' of a function type, which an assignment cannot add */
      if (i + 1 < nelements && SwigType_isfunction(Getitem(elements, i + 1))) {
        SwigType *noexcept_qualifier = qualifier_noexcept_part(element, 1);
        if (noexcept_qualifier)
          Append(result, noexcept_qualifier);
        Delete(noexcept_qualifier);
      }
    } else if (SwigType_ispointer(element)) {
      Append(result, element);
      firstarray = 0;
    } else if (SwigType_ismemberpointer(element)) {
      Append(result, element);
      {
        String *next3elements = NewStringEmpty();
        int j;
        for (j = i + 1; j < i + 4 && j < nelements; j++) {
          Append(next3elements, Getitem(elements, j));
        }
        if (SwigType_isfunction(next3elements)) {
          SwigType *member_function_qualifiers = SwigType_pop_function_qualifiers(next3elements);
          /* compilers won't let us cast from a member function without qualifiers to one with qualifiers, so the qualifiers are kept in the ltype */
          if (member_function_qualifiers)
            Append(result, member_function_qualifiers);
          Delete(member_function_qualifiers);
          ignore_member_function_qualifiers = 1;
        }
        Delete(next3elements);
      }
      firstarray = 0;
    } else if (SwigType_isreference(element)) {
      if (notypeconv) {
        Append(result, element);
      } else {
        Append(result, "p.");
      }
      firstarray = 0;
    } else if (SwigType_isrvalue_reference(element)) {
      if (notypeconv) {
        Append(result, element);
      } else {
        Append(result, "p.");
      }
      firstarray = 0;
    } else if (SwigType_isarray(element) && firstarray) {
      if (notypeconv) {
        Append(result, element);
      } else {
        Append(result, "p.");
      }
      firstarray = 0;
    } else if (SwigType_isenum(element)) {
      int anonymous_enum = (Cmp(element, "enum ") == 0);
      if (notypeconv || !anonymous_enum) {
        Append(result, element);
      } else {
        Append(result, "int");
      }
    } else {
      Append(result, element);
    }
  }
  Delete(elements);
  Delete(tc);
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_lstr()
 *
 * Produces a type-string that is suitable as a lvalue in an expression.
 * That is, a type that can be freely assigned a value without violating
 * any C assignment rules.
 *
 *      -   Qualifiers such as 'const' and 'volatile' are stripped.
 *          Except for member function cv-qualifiers and ref-qualifiers and the 'noexcept' of a function type.
 *      -   An array is converted into a pointer to its first element (i.e., double [][] becomes double (*)[]).
 *      -   References are converted into a pointer.
 *      -   Typedef names that refer to read-only types will be replaced
 *          with an equivalent assignable version.
 * -------------------------------------------------------------------- */

String *SwigType_lstr(const SwigType *s, const_String_or_char_ptr id) {
  String *result;
  SwigType *tc;

  tc = SwigType_ltype(s);
  result = SwigType_str(tc, id);
  Delete(tc);
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_decay_array()
 *
 * Return a copy of type 's' with an array, or a typedef of an array, changed into a pointer to its first element, as C
 * does for a function parameter declared as an array.  Unlike SwigType_ltype(), the qualifiers and the typedef names
 * of the element type are kept, so 'a(3).q(const).int' becomes 'p.q(const).int'.  Any other type is copied unchanged.
 * ----------------------------------------------------------------------------- */

SwigType *SwigType_decay_array(const SwigType *s) {
  SwigType *t;
  if (SwigType_isarray(s)) {
    t = Copy(s);
  } else {
    t = SwigType_typedef_resolve_all(s);
    if (!SwigType_isarray(t)) {
      Delete(t);
      return Copy(s);
    }
  }
  SwigType_del_array(t);
  SwigType_add_pointer(t);
  return t;
}

/* -----------------------------------------------------------------------------
 * SwigType_rcaststr()
 *
 * Produces a casting string that maps the type returned by lstr() to the real
 * datatype printed by str().
 * ----------------------------------------------------------------------------- */

String *SwigType_rcaststr(const SwigType *s, const_String_or_char_ptr name) {
  String *result, *cast;
  String *element = 0;
  String *nextelement;
  String *forwardelement;
  String *function_qualifiers = 0;
  SwigType *td, *tc = 0;
  const SwigType *rs;
  List *elements;
  int nelements, i;
  int clear = 1;
  int firstarray = 1;
  int isreference = 0;
  int isfunction = 0;

  result = NewStringEmpty();

  /* Leave out the top level cv-qualifiers: a cast of a value does not need them and g++ warns that they are ignored */
  if (SwigType_isqualifier(s) || SwigType_isconst(s)) {
    tc = Copy(s);
    Delete(SwigType_pop(tc));
    rs = tc;
  } else {
    rs = s;
  }

  if ((SwigType_isconst(rs) || SwigType_isarray(rs) || SwigType_isreference(rs) || SwigType_isrvalue_reference(rs))) {
    td = 0;
  } else {
    td = SwigType_typedef_resolve(rs);
    if (td)
      td = SwigType_typedef_resolve_all(td);
  }

  if (td) {
    if ((SwigType_isconst(td) || SwigType_isarray(td) || SwigType_isreference(td) || SwigType_isrvalue_reference(td))) {
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
    element = Getitem(elements, 0);
  }
  /* Now, walk the type list and start emitting */
  for (i = 0; i < nelements; i++) {
    if (i < (nelements - 1)) {
      nextelement = Getitem(elements, i + 1);
      forwardelement = nextelement;
      if (SwigType_isqualifier(nextelement)) {
        if (i < (nelements - 2))
          forwardelement = Getitem(elements, i + 2);
      }
    } else {
      nextelement = 0;
      forwardelement = 0;
    }
    if (SwigType_isqualifier(element)) {
      if (!function_qualifiers) {
        if (SwigType_isfunction(nextelement)) {
          function_qualifiers = Copy(element);
        } else {
          DOH *q = 0;
          q = SwigType_parm(element);
          /* No space after a qualifier with nothing after it, as in 'int (A::*const)(int)' */
          if (Len(result) > 0) {
            Insert(result, 0, " ");
          }
          Insert(result, 0, q);
          Delete(q);
          clear = 0;
        }
      }
    } else if (SwigType_ispointer(element)) {
      Insert(result, 0, "*");
      if ((forwardelement) && ((SwigType_isfunction(forwardelement) || (SwigType_isarray(forwardelement))))) {
        Insert(result, 0, "(");
        Append(result, ")");
      }
      firstarray = 0;
    } else if (SwigType_ismemberpointer(element)) {
      String *q;
      Insert(result, 0, "::*");
      q = SwigType_parm(element);
      Insert(result, 0, q);
      if ((forwardelement) && ((SwigType_isfunction(forwardelement) || (SwigType_isarray(forwardelement))))) {
        Insert(result, 0, "(");
        Append(result, ")");
      }
      {
        String *next3elements = NewStringEmpty();
        int j;
        for (j = i + 1; j < i + 4 && j < nelements; j++) {
          Append(next3elements, Getitem(elements, j));
        }
        if (SwigType_isfunction(next3elements))
          function_qualifiers = SwigType_pop_function_qualifiers(next3elements);
        Delete(next3elements);
      }
      firstarray = 0;
      Delete(q);
    } else if (SwigType_isreference(element)) {
      if (!function_qualifiers) {
        Insert(result, 0, "&");
        if (!isfunction)
          isreference = 1;
      }
      if ((forwardelement) && ((SwigType_isfunction(forwardelement) || (SwigType_isarray(forwardelement))))) {
        Insert(result, 0, "(");
        Append(result, ")");
      }
    } else if (SwigType_isrvalue_reference(element)) {
      if (!function_qualifiers) {
        Insert(result, 0, "&&");
        if (!isfunction)
          isreference = 1;
      }
      if ((forwardelement) && ((SwigType_isfunction(forwardelement) || (SwigType_isarray(forwardelement))))) {
        Insert(result, 0, "(");
        Append(result, ")");
      }
      clear = 0;
    } else if (SwigType_isarray(element)) {
      DOH *size;
      if (firstarray && !isreference) {
        Append(result, "(*)");
        firstarray = 0;
      } else {
        Append(result, "[");
        size = SwigType_parm(element);
        Append(result, size);
        Append(result, "]");
        Delete(size);
        clear = 0;
      }
    } else if (SwigType_isfunction(element)) {
      DOH *parms, *p;
      int j, plen;
      Append(result, "(");
      parms = SwigType_parmlist(element);
      plen = Len(parms);
      for (j = 0; j < plen; j++) {
        p = SwigType_str(Getitem(parms, j), 0);
        Append(result, p);
        Delete(p);
        if (j < (plen - 1))
          Append(result, ",");
      }
      Append(result, ")");
      Delete(parms);
      if (function_qualifiers) {
        String *p = function_qualifiers_str(function_qualifiers);
        Append(result, " ");
        Append(result, p);
        Delete(p);
        Delete(function_qualifiers);
        function_qualifiers = 0;
        clear = 0;
      }
      isfunction = 1;
    } else {
      String *bs = SwigType_namestr(element);
      Insert(result, 0, " ");
      Insert(result, 0, bs);
      Delete(bs);
    }
    element = nextelement;
  }
  Delete(elements);
  if (clear) {
    cast = NewStringEmpty();
  } else {
    cast = NewStringf("(%s)", result);
  }
  if (name) {
    if (isreference) {
      Append(cast, "*");
    }
    Append(cast, name);
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

String *SwigType_lcaststr(const SwigType *s, const_String_or_char_ptr name) {
  String *result;

  result = NewStringEmpty();
  if (name && Len(name) == 0)
    name = 0;

  if (SwigType_isarray(s)) {
    String *lstr = SwigType_lstr(s, 0);
    Printf(result, "(%s)%s", lstr, name);
    Delete(lstr);
  } else if (SwigType_isreference(s)) {
    String *str = SwigType_str(s, 0);
    Printf(result, "(%s)", str);
    Delete(str);
    if (name)
      Append(result, name);
  } else if (SwigType_isrvalue_reference(s)) {
    String *str = SwigType_str(s, 0);
    Printf(result, "(%s)", str);
    Delete(str);
    if (name)
      Append(result, name);
  } else if (SwigType_isqualifier(s)) {
    String *lstr = SwigType_lstr(s, 0);
    Printf(result, "(%s)%s", lstr, name);
    Delete(lstr);
  } else if (SwigType_ispointer(s)) {
    SwigType *sc = Copy(s);
    Delete(SwigType_pop(sc));
    if (SwigType_isqualifier(sc) && name && !Equal(name, "0")) {
      /* Only cast const pointer values (remove const in cast - they are assigned to a non-const pointer type) */
      SwigType_add_pointer(sc);
      String *lstr = SwigType_lstr(sc, 0);
      Printf(result, "(%s)%s", lstr, name);
      Delete(lstr);
    } else {
      if (name)
        Append(result, name);
    }
    Delete(sc);
  } else {
    if (name)
      Append(result, name);
  }
  return result;
}

#if 0
/* Alternative implementation for manglestr_default. Mangling is similar to the original
   except for a few subtle differences for example in templates:
    namespace foo {
      template<class T> class bar {};
      typedef int Integer;
      void test2(bar<Integer *> *x);
    }
    Mangling is more consistent and changes from
    _p_foo__barT_int_p_t to
    _p_foo__barT_p_int_t.
*/
static void mangle_stringcopy(String *destination, const char *source, int count) {
  while (count-- > 0) {
    char newc = '_';
    if (!(*source == '.' || *source == ':' || *source == ' '))
      newc = *source;
    /* TODO: occasionally '*' or numerics need converting to '_', eg in array dimensions and template expressions */
    Putc(newc, destination);
    source++;
  }
}

static void mangle_subtype(String *mangled, SwigType *s);

/* -----------------------------------------------------------------------------
 * mangle_namestr()
 *
 * Mangles a type taking care of template expansions. Similar to SwigType_namestr().
 * The type may include a trailing '.', for example "p."
 * ----------------------------------------------------------------------------- */

static void mangle_namestr(String *mangled, SwigType *t) {
  int length = Len(t);
  if (SwigType_isqualifier(t)) {
    Append(mangled, "q_");
    mangle_stringcopy(mangled, Char(t)+2, length-4);
    Append(mangled, "__");
  } else if (SwigType_ismemberpointer(t)) {
    Append(mangled, "m_");
    mangle_stringcopy(mangled, Char(t)+2, length-4);
    Append(mangled, "__");
  } else if (SwigType_isarray(t)) {
    Append(mangled, "a_");
    mangle_stringcopy(mangled, Char(t)+2, length-4);
    Append(mangled, "__");
  } else if (SwigType_isfunction(t)) {
    List *p = SwigType_parmlist(t);
    int sz = Len(p);
    int i;
    Append(mangled, "f_");
    for (i = 0; i < sz; i++) {
      mangle_subtype(mangled, Getitem(p, i));
      Putc('_', mangled);
    }
    Append(mangled, (sz > 0) ? "_" : "__");
  } else if (SwigType_isvarargs(t)) {
    Append(mangled, "___");
  } else {
    char *d = Char(t);
    char *c = strstr(d, "<(");
    if (!c || !strstr(c + 2, ")>")) {
      /* not a template type */
      mangle_stringcopy(mangled, Char(t), Len(t));
    } else {
      /* a template type */
      String *suffix;
      List *p;
      int i, sz;
      mangle_stringcopy(mangled, d, c-d);
      Putc('T', mangled);
      Putc('_', mangled);

      p = SwigType_parmlist(c + 1);
      sz = Len(p);
      for (i = 0; i < sz; i++) {
        mangle_subtype(mangled, Getitem(p, i));
        Putc('_', mangled);
      }
      Putc('t', mangled);
      suffix = SwigType_templatesuffix(t);
      if (Len(suffix) > 0) {
        mangle_namestr(mangled, suffix);
      } else {
        Append(mangled, suffix);
      }
      Delete(suffix);
      Delete(p);
    }
  }
}

static void mangle_subtype(String *mangled, SwigType *s) {
  List *elements;
  int nelements, i;

  assert(s);
  elements = SwigType_split(s);
  nelements = Len(elements);
  for (i = 0; i < nelements; i++) {
    SwigType *element = Getitem(elements, i);
    mangle_namestr(mangled, element);
  }
  Delete(elements);
}

static String *manglestr_default(const SwigType *s) {
  String *mangled = NewString("_");
  SwigType *sr = SwigType_typedef_resolve_all(s);
  SwigType *sq = SwigType_typedef_qualified(sr);
  SwigType *ss = SwigType_remove_global_scope_prefix(sq);
  SwigType *type = ss;
  SwigType *lt;

  if (SwigType_istemplate(ss)) {
    SwigType *ty = Swig_symbol_template_deftype(ss, 0);
    Delete(ss);
    ss = ty;
    type = ss;
  }

  lt = SwigType_ltype(type);

  Replace(lt, "struct ", "", DOH_REPLACE_ANY);
  Replace(lt, "class ", "", DOH_REPLACE_ANY);
  Replace(lt, "union ", "", DOH_REPLACE_ANY);
  Replace(lt, "enum ", "", DOH_REPLACE_ANY);

  mangle_subtype(mangled, lt);

  Delete(ss);
  Delete(sq);
  Delete(sr);

  return mangled;
}

#else

static String *manglestr_default(const SwigType *s) {
  char *c;
  String *result = 0;
  String *base = 0;
  SwigType *lt;
  SwigType *lt_noexcept;
  SwigType *sr = SwigType_typedef_resolve_all(s);
  SwigType *sq = SwigType_typedef_qualified(sr);
  SwigType *ss = SwigType_remove_global_scope_prefix(sq);
  SwigType *type = ss;

  if (SwigType_istemplate(ss)) {
    SwigType *dt = Swig_symbol_template_deftype(ss, 0);
    String *ty = Swig_symbol_type_qualify(dt, 0);
    Delete(dt);
    Delete(ss);
    ss = ty;
    type = ss;
  }

  /* A pointer to a noexcept function converts to a pointer to the function without noexcept, so both have the same runtime type */
  lt_noexcept = SwigType_ltype(type);
  lt = function_noexcept_removed(lt_noexcept);
  Delete(lt_noexcept);
  result = SwigType_prefix(lt);
  base = SwigType_base(lt);

  c = Char(result);
  while (*c) {
    if (!isalnum((int)*c))
      *c = '_';
    c++;
  }
  if (SwigType_istemplate(base)) {
    String *b = SwigType_namestr(base);
    Delete(base);
    base = b;
  }

  Replace(base, "struct ", "", DOH_REPLACE_ANY); /* This might be problematic */
  Replace(base, "class ", "", DOH_REPLACE_ANY);
  Replace(base, "union ", "", DOH_REPLACE_ANY);
  Replace(base, "enum ", "", DOH_REPLACE_ANY);

  c = Char(base);
  while (*c) {
    if (*c == '<')
      *c = 'T';
    else if (*c == '>')
      *c = 't';
    else if (*c == '*')
      *c = 'p';
    else if (*c == '[')
      *c = 'a';
    else if (*c == ']')
      *c = 'A';
    else if (*c == '&')
      *c = 'R';
    else if (*c == '(')
      *c = 'f';
    else if (*c == ')')
      *c = 'F';
    else if (!isalnum((int)*c))
      *c = '_';
    c++;
  }
  Append(result, base);
  Insert(result, 0, "_");
  Delete(lt);
  Delete(base);
  Delete(ss);
  Delete(sq);
  Delete(sr);
  return result;
}
#endif

String *SwigType_manglestr(const SwigType *s) {
#if 0
  /* Debugging checks to ensure a proper SwigType is passed in and not a stringified type */
  String *angle = Strchr(s, '<');
  if (angle && Strncmp(angle, "<(", 2) != 0)
    Printf(stderr, "SwigType_manglestr error: %s\n", s);
  else if (Strchr(s, '*') || Strchr(s, '&') || Strchr(s, '['))
    Printf(stderr, "SwigType_manglestr error: %s\n", s);
#endif
  return manglestr_default(s);
}

/* -----------------------------------------------------------------------------
 * SwigType_typename_replace()
 *
 * Replaces a typename in a type with something else.  Needed for templates.
 * Merges the qualifiers that meet into one qualifier, which collapses a duplicate const.
 * A qualifier goes after the arrays of an array, as C++ qualifies the elements of an array.
 * Reference collapsing probably should be implemented here.
 * Example:
 *   t=r.q(const).T pat=T rep=int                    =>  r.q(const).int
 *   t=r.q(const).T pat=T rep=q(const).int           =>  r.q(const).int  (duplicate const removed)
 *   t=r.q(const).T pat=T rep=q(volatile).int        =>  r.q(const volatile).int
 *   t=r.q(const).T pat=T rep=q(const volatile).int  =>  r.q(const volatile).int
 *   t=r.q(const).T pat=T rep=a(3).int               =>  r.a(3).q(const).int
 *   t=r.q(const).T pat=T rep=a(3).q(const).int      =>  r.a(3).q(const).int
 * ----------------------------------------------------------------------------- */

void SwigType_typename_replace(SwigType *t, String *pat, String *rep) {
  String *nt;
  int i, ilen;
  List *elem;

  if (!Strstr(t, pat))
    return;

  if (Equal(t, pat)) {
    Replace(t, pat, rep, DOH_REPLACE_ANY);
    return;
  }
  nt = NewStringEmpty();
  elem = SwigType_split(t);
  ilen = Len(elem);
  for (i = 0; i < ilen; i++) {
    String *e = Getitem(elem, i);
    if (SwigType_isdecltype(e)) {
      /* The expression is C++ text rather than a type, so a name in it becomes the C++ spelling of rep, as in
       * 'decltype(N + 1)' becoming 'decltype(3 + 1)' or 'decltype(T())' becoming 'decltype(double())' */
      String *expr = SwigType_decltype_expr(e);
      String *repstr = SwigType_str(rep, 0);
      SwigType *replaced;
      Replace(expr, pat, repstr, DOH_REPLACE_ID);
      replaced = SwigType_new_decltype(expr);
      Clear(e);
      Append(e, replaced);
      Delete(replaced);
      Delete(repstr);
      Delete(expr);
    } else if (SwigType_issimple(e)) {
      if (Equal(e, pat)) {
        /* Replaces a type of the form 'pat' with 'rep<args>' */
        if ((SwigType_isqualifier(rep) || SwigType_isarray(rep)) && i > 0 && SwigType_isqualifier(Getitem(elem, i - 1))) {
          /* Merge the qualifiers that meet, so 'r.q(const).T' with rep 'q(volatile).int' becomes 'r.q(const volatile).int'.
           * The qualifier goes after the arrays of rep, so with rep 'a(3).int' it becomes 'r.a(3).q(const).int' */
          SwigType *merged = Copy(rep);
          SwigType_push_merge_qualifiers(merged, nt);
          Clear(nt);
          Clear(e);
          Append(e, merged);
          Delete(merged);
        } else {
          Replace(e, pat, rep, DOH_REPLACE_ANY);
        }
      } else if (SwigType_istemplate(e)) {
        /* Replaces a type of the form 'pat<args>' with 'rep' */
        {
          /* To match "e=TemplateTemplateT<(float)>"
           * with "pat=TemplateTemplateT"
           * we need to compare only the first part of the string e.
           */
          int len = Len(pat);

          /* Len(e) > len, not >= (because we expect at least a
           * character '<' following the template typename)
           */
          if (Len(e) > len) {
            String *firstPartOfType = NewStringWithSize(e, len);
            const char *e_as_char = Char(e);

            if (Equal(firstPartOfType, pat) && e_as_char[len] == '<') {
              String *repbase = SwigType_templateprefix(rep);
              Replace(e, pat, repbase, DOH_REPLACE_ID | DOH_REPLACE_FIRST);
              Delete(repbase);
            }
            Delete(firstPartOfType);
          }
        }

        {
          String *tsuffix;
          List *tparms = SwigType_parmlist(e);
          int j, jlen;
          String *nt = SwigType_templateprefix(e);
          Append(nt, "<(");
          jlen = Len(tparms);
          for (j = 0; j < jlen; j++) {
            SwigType_typename_replace(Getitem(tparms, j), pat, rep);
            Append(nt, Getitem(tparms, j));
            if (j < (jlen - 1))
              Putc(',', nt);
          }
          tsuffix = SwigType_templatesuffix(e);
          SwigType_typename_replace(tsuffix, pat, rep);
          Printf(nt, ")>%s", tsuffix);
          Delete(tsuffix);
          Clear(e);
          Append(e, nt);
          Delete(nt);
          Delete(tparms);
        }
      } else if (Swig_scopename_check(e)) {
        String *first = 0;
        String *rest = 0;
        Swig_scopename_split(e, &first, &rest);

        /* Swig_scopename_split doesn't handle :: prefix very well ... could do with a rework */
        if (Strncmp(rest, "::", 2) == 0) {
          String *tmp = NewString(Char(rest) + 2);
          Clear(rest);
          Printv(rest, tmp, NIL);
          Delete(tmp);
          assert(!first);
        }

        Clear(e);
        if (first)
          SwigType_typename_replace(first, pat, rep);
        SwigType_typename_replace(rest, pat, rep);
        Printv(e, first ? first : "", "::", rest, NIL);
        Delete(first);
        Delete(rest);
      }
    } else if (SwigType_isfunction(e)) {
      int j, jlen;
      List *fparms = SwigType_parmlist(e);
      Clear(e);
      Append(e, "f(");
      jlen = Len(fparms);
      for (j = 0; j < jlen; j++) {
        SwigType_typename_replace(Getitem(fparms, j), pat, rep);
        Append(e, Getitem(fparms, j));
        if (j < (jlen - 1))
          Putc(',', e);
      }
      Append(e, ").");
      Delete(fparms);
    } else if (SwigType_isarray(e)) {
      Replace(e, pat, rep, DOH_REPLACE_ID);
    }
    Append(nt, e);
  }
  Clear(t);
  Append(t, nt);
  Delete(nt);
  Delete(elem);
}

/* -----------------------------------------------------------------------------
 * SwigType_variadic_expands()
 *
 * Whether the variadic type 't' is an expansion of the pack named 'pack_name', such as 'v.r.Ts' of 'Ts'.
 * ----------------------------------------------------------------------------- */

int SwigType_variadic_expands(const SwigType *t, const String *pack_name) {
  return SwigType_isvariadic(t) && Swig_contains_identifier(t, pack_name);
}

/* -----------------------------------------------------------------------------
 * SwigType_variadic_replace()
 *
 * Replaces variadic parameter with a list of (zero or more) parameters.
 * Needed for variadic templates.
 *
 * Explicitly written template arguments all go to the first pack, so a pack declared after it in the same
 * template parameter list, the variadic entries following 'unexpanded_variadic_parm', is replaced by none.
 * A pack of any other template, such as a member template's own, is left for that template's instantiation.
 * ----------------------------------------------------------------------------- */

void SwigType_variadic_replace(SwigType *t, Parm *unexpanded_variadic_parm, ParmList *expanded_variadic_parms) {
  String *nt;
  int i, ilen;
  List *elem;
  if (!unexpanded_variadic_parm)
    return;

  if (SwigType_isvariadic(t) && ParmList_expanded_pack(nextSibling(unexpanded_variadic_parm), t)) {
    Clear(t);
    return;
  }
  if (SwigType_isvariadic(t) && !SwigType_variadic_expands(t, Getattr(unexpanded_variadic_parm, "name")))
    return;

  if (SwigType_isvariadic(t)) {
    /* Based on expand_variadic_parms() but input is single SwigType (t) instead of ParmList */
    String *unexpanded_name = Getattr(unexpanded_variadic_parm, "name");
    ParmList *expanded = CopyParmList(expanded_variadic_parms);
    Parm *ep = expanded;
    SwigType *fparms;
    while (ep) {
      SwigType *newtype = Copy(t);
      SwigType_del_variadic(newtype);
      Replaceid(newtype, unexpanded_name, Getattr(ep, "type"));
      Setattr(ep, "type", newtype);
      ep = nextSibling(ep);
    }
    Clear(t);
    fparms = SwigType_function_parms_only(expanded);
    Append(t, fparms);
    Delete(expanded);

    return;
  }
  nt = NewStringEmpty();
  elem = SwigType_split(t);
  ilen = Len(elem);
  for (i = 0; i < ilen; i++) {
    String *e = Getitem(elem, i);
    if (SwigType_isfunction(e)) {
      int j, jlen, first = 1;
      List *fparms = SwigType_parmlist(e);
      Clear(e);
      Append(e, "f(");
      jlen = Len(fparms);
      for (j = 0; j < jlen; j++) {
        SwigType *type = Getitem(fparms, j);
        SwigType_variadic_replace(type, unexpanded_variadic_parm, expanded_variadic_parms);
        /* A pack replaced by no parms leaves nothing, wherever it is in the list */
        if (Len(type) > 0) {
          if (!first)
            Putc(',', e);
          Append(e, type);
          first = 0;
        }
      }
      Append(e, ").");
      Delete(fparms);
    }
    if (SwigType_istemplate(e)) {
      int j, jlen, first = 1;
      List *tparms = SwigType_templateargslist(e);
      String *tprefix = SwigType_templateprefix(e);
      String *tsuffix = SwigType_templatesuffix(e);
      Clear(e);
      Append(e, tprefix);
      Append(e, "<(");
      jlen = Len(tparms);
      for (j = 0; j < jlen; j++) {
        SwigType *type = Getitem(tparms, j);
        SwigType_variadic_replace(type, unexpanded_variadic_parm, expanded_variadic_parms);
        if (Len(type) > 0) {
          if (!first)
            Putc(',', e);
          Append(e, type);
          first = 0;
        }
      }
      Append(e, ")>");
      Append(e, tsuffix);
      Delete(tparms);
    }
    Append(nt, e);
  }
  Clear(t);
  Append(t, nt);
  Delete(nt);
  Delete(elem);
}

/* -----------------------------------------------------------------------------
 * SwigType_remove_global_scope_prefix()
 *
 * Removes the unary scope operator (::) prefix indicating global scope in all
 * components of the type
 * ----------------------------------------------------------------------------- */

SwigType *SwigType_remove_global_scope_prefix(const SwigType *t) {
  SwigType *result;
  const char *type = Char(t);
  if (strncmp(type, "::", 2) == 0)
    type += 2;
  result = NewString(type);
  Replaceall(result, ".::", ".");
  Replaceall(result, "(::", "(");
  Replaceall(result, "enum ::", "enum ");
  return result;
}

/* -----------------------------------------------------------------------------
 * SwigType_check_decl()
 *
 * Checks type declarators for a match
 * ----------------------------------------------------------------------------- */

int SwigType_check_decl(const SwigType *ty, const SwigType *decl) {
  SwigType *t, *t1, *t2;
  int r;
  t = SwigType_typedef_resolve_all(ty);
  t1 = SwigType_strip_qualifiers(t);
  t2 = SwigType_prefix(t1);
  r = Equal(t2, decl);
  Delete(t);
  Delete(t1);
  Delete(t2);
  return r == 1;
}

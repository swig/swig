/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * vla.c
 *
 * C99 variable length array parameter support.  The size of a variable length array parameter refers to an earlier
 * parameter, so it is only known at runtime, such as the sizes of 'a' and 'm' in:
 *
 *   void f(int n, int a[n]);
 *   void g(int r, int c, double m[r][c][3]);
 *
 * Each such size is removed from the parameter's type, so that the parameter is wrapped as an array of unknown size,
 * such as 'int a[]' and 'double m[][][3]'.  The sizes of a parameter that is itself an array are kept as its "vlasize"
 * attribute, which has an element for each of the leading arrays of the type.  The size of a variable dimension gives
 * each parameter it refers to by its position in the declaration, $1 for the first parameter.  The size of any other
 * dimension is empty.  So the "vlasize" of 'm' is:
 *
 *   a($1).a($2).a().
 *
 * A typemap written for a variable length array parameter has '*' as the size of each variable dimension, as C99 has
 * for a variable length array of unspecified size in a function prototype, such as 'int [*]' or 'double [*][*][3]'.
 * Such a typemap only matches a variable length array parameter.  Its $1_dim0, $dim0 and $1_size special variables
 * expand to the runtime size, such as '(arg1)', which only some of the typemaps can use, see Swig_vla_check_size_use().
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include <ctype.h>

/* The size of dimension 'i' in 'vlasize', the "vlasize" of a C99 variable length array parameter, such as '$1' for
   dimension 0 of 'a($1).a().', or an empty size for a dimension that is not variable.  Return 0 if 'vlasize' is 0 or
   has no dimension 'i'. */
static String *vlasize_dimension(const String *vlasize, int i) {
  String *size = 0;
  if (vlasize) {
    List *sizes = SwigType_split(vlasize);
    if (i < Len(sizes))
      size = SwigType_parm(Getitem(sizes, i));
    Delete(sizes);
  }
  return size;
}

/* The parameters of the declaration in the parameters 'parms' of a wrapper, which for a method puts self first.  A
   "vlasize" gives the parameters it refers to by their position in the declaration. */
static ParmList *declaration_parms(ParmList *parms) {
  while (parms && Getattr(parms, "self")) {
    parms = nextSibling(parms);
  }
  return parms;
}

/* Return a copy of the type 't' of a parameter in 'parms' with the size removed from each array whose size refers to a
   parameter before 'end', as the size of a C99 variable length array does.  An array in the type of a parameter of a
   function type is included.  For example, the parameter 'a' in:
     int n, void (*a[n])(int b[n])
   has the type 'a(n).p.f(a(n).int).void', which is returned as:
     a().p.f(a().int).void
   Return 0 if there is no such array. */
static SwigType *unsized_variable_length_arrays(const SwigType *t, ParmList *parms, Parm *end) {
  List *elements = SwigType_split(t);
  SwigType *unsized = NewStringEmpty();
  int changed = 0;
  int i;
  /* Build the copy from the innermost element out, as the SwigType_add_* functions add an element to the front */
  for (i = Len(elements) - 1; i >= 0; i--) {
    String *element = Getitem(elements, i);
    if (SwigType_isarray(element)) {
      String *size = SwigType_parm(element);
      if (ParmList_find_name_in(parms, end, size)) {
        SwigType_add_array(unsized, "");
        changed = 1;
      } else {
        SwigType_add_array(unsized, size);
      }
      Delete(size);
    } else if (SwigType_isfunction(element)) {
      ParmList *fparms = SwigType_function_parms(element, 0);
      Parm *fparm;
      for (fparm = fparms; fparm; fparm = nextSibling(fparm)) {
        SwigType *unsized_fparm = unsized_variable_length_arrays(Getattr(fparm, "type"), parms, end);
        if (unsized_fparm) {
          Setattr(fparm, "type", unsized_fparm);
          Delete(unsized_fparm);
          changed = 1;
        }
      }
      SwigType_add_function(unsized, fparms);
      Delete(fparms);
    } else {
      SwigType_push(unsized, element);
    }
  }
  Delete(elements);
  if (!changed) {
    Delete(unsized);
    unsized = 0;
  }
  return unsized;
}

/* The sizes of the array dimensions of a parameter 'p' in 'parms' of type 'type' that is a C99 variable length array,
   kept as its "vlasize".  There is a size for each of the leading arrays of 'type': the size of a dimension that refers
   to a parameter before 'p', with each such parameter given by its position, or empty for any other dimension.  For
   example, the parameter 'm' in:
     int r, int c, double m[r][c][3]
   has the sizes:
     a($1).a($2).a().
   Return 0 if no dimension is variable. */
static String *variable_length_array_sizes(const SwigType *type, ParmList *parms, Parm *p) {
  List *elements = SwigType_split(type);
  String *sizes = NewStringEmpty();
  int variable = 0;
  int i;
  for (i = 0; i < Len(elements) && SwigType_isarray(Getitem(elements, i)); i++) {
    String *size = SwigType_parm(Getitem(elements, i));
    if (ParmList_find_name_in(parms, p, size)) {
      ParmList_replace_names_positional(size, parms, p);
      variable = 1;
    } else {
      Clear(size);
    }
    Printf(sizes, "a(%s).", size);
    Delete(size);
  }
  Delete(elements);
  if (!variable) {
    Delete(sizes);
    sizes = 0;
  }
  return sizes;
}

/* -----------------------------------------------------------------------------
 * Swig_vla_unsize_parms()
 *
 * Remove the size of each C99 variable length array in the parameter types of 'parms', which is a size that refers to
 * an earlier parameter and so is only known at runtime, so that the parameter is wrapped as an array of unknown size.
 * For example, these parameters:
 *   int n, int a[n]
 *   int n, double m[n][n]
 *   int n, int (*p)[n]
 * become:
 *   int n, int a[]
 *   int n, double m[][]
 *   int n, int (*p)[]
 * The sizes of a parameter that is itself such an array are kept as its "vlasize" for $1_dim0 and the rest in a typemap
 * written with '[*]', see variable_length_array_sizes().
 * ----------------------------------------------------------------------------- */

void Swig_vla_unsize_parms(ParmList *parms) {
  Parm *p;
  for (p = parms; p; p = nextSibling(p)) {
    SwigType *type = Getattr(p, "type");
    /* The parser marks a parameter with arrays written '[*]' with "unspecified_size_arrays" for a multi-argument
       typemap pattern.  Every parameter list is parsed alike, so remove it from a declaration's parameters, where it
       has no use, to keep it out of the parse tree. */
    Delattr(p, "unspecified_size_arrays");
    if (type && Strstr(type, "a(")) {
      SwigType *unsized;
      String *sizes = variable_length_array_sizes(type, parms, p);
      if (sizes) {
        Setattr(p, "vlasize", sizes);
        Delete(sizes);
      }
      unsized = unsized_variable_length_arrays(type, parms, p);
      if (unsized) {
        Setattr(p, "type", unsized);
        Delete(unsized);
      }
    }
  }
}

/* Return a copy of the type 't' of a parameter 'p' in 'parms' with '*' as the size of each of its leading arrays whose
   size refers to a parameter before 'p', such as 's.rows' in:
     struct S s, double m[s.rows]
   The type is split into its elements, as such a size can contain a '.'. */
static SwigType *starred_variable_length_arrays(const SwigType *t, ParmList *parms, Parm *p) {
  List *elements = SwigType_split(t);
  SwigType *starred = NewStringEmpty();
  int leading = 1;
  int i;
  for (i = 0; i < Len(elements); i++) {
    String *element = Getitem(elements, i);
    leading = leading && SwigType_isarray(element);
    if (leading) {
      String *size = SwigType_parm(element);
      Printf(starred, "a(%s).", ParmList_find_name_in(parms, p, size) ? "*" : size);
      Delete(size);
    } else {
      Append(starred, element);
    }
  }
  Delete(elements);
  return starred;
}

/* -----------------------------------------------------------------------------
 * Swig_vla_star_parms()
 *
 * In the parameters 'parms' of a multi-argument typemap pattern, give '*' as the size of each array dimension of a C99
 * variable length array parameter whose size refers to an earlier parameter of the pattern, so that the typemap only
 * matches such a parameter, as a typemap written with '[*]' does.  For example:
 *   int n, double a[n][3]
 * becomes:
 *   int n, double a[*][3]
 * The size of any other variable length array, such as one behind a pointer, is removed as for a declaration.
 * ----------------------------------------------------------------------------- */

void Swig_vla_star_parms(ParmList *parms) {
  Parm *p;
  for (p = parms; p; p = nextSibling(p)) {
    SwigType *type = Getattr(p, "type");
    if (type && Strstr(type, "a(")) {
      SwigType *starred = starred_variable_length_arrays(type, parms, p);
      SwigType *unsized = unsized_variable_length_arrays(starred, parms, p);
      Setattr(p, "type", unsized ? unsized : starred);
      Delete(unsized);
      Delete(starred);
    }
  }
}

/* -----------------------------------------------------------------------------
 * Swig_vla_merge_sizes()
 *
 * A function declared again with the same type, which C allows, can give the size of a C99 variable length array
 * parameter that the first declaration 'c', the one that is wrapped, does not.  For example:
 *   void f(int, int a[*]);
 *   void f(int n, int a[n]);
 * Keep the size from the later declaration 'n' for a typemap written with '[*]', for each array dimension that does
 * not have one.  The size gives the parameters it refers to by position, so it does not depend on their names.
 * ----------------------------------------------------------------------------- */

void Swig_vla_merge_sizes(Node *c, Node *n) {
  Parm *cp;
  Parm *np;
  if (!Equal(nodeType(c), "cdecl") || !Equal(nodeType(n), "cdecl") || !Equal(Getattr(c, "decl"), Getattr(n, "decl")))
    return;
  for (cp = Getattr(c, "parms"), np = Getattr(n, "parms"); cp && np; cp = nextSibling(cp), np = nextSibling(np)) {
    String *csizes = Getattr(cp, "vlasize");
    String *nsizes = Getattr(np, "vlasize");
    if (nsizes && !csizes) {
      Setattr(cp, "vlasize", nsizes);
    } else if (nsizes) {
      String *merged = NewStringEmpty();
      String *csize;
      int i;
      for (i = 0; (csize = vlasize_dimension(csizes, i)); i++) {
        String *nsize = vlasize_dimension(nsizes, i);
        Printf(merged, "a(%s).", Len(csize) == 0 && nsize ? nsize : csize);
        Delete(csize);
        Delete(nsize);
      }
      Setattr(cp, "vlasize", merged);
      Delete(merged);
    }
  }
}

/* -----------------------------------------------------------------------------
 * Swig_vla_parameter_type()
 *
 * For a C99 variable length array parameter 'node', such as the 'char s[n]' of 'int n, char s[n]', return a copy of
 * 'type', its type or a type it reduces to, with '*' as the size of each array dimension whose size is only known at
 * runtime, as given by the parameter's "vlasize".  This is the type of a typemap written for one, as in 'char [*]'.
 * Return 0 otherwise, or when 'type' has none of those array dimensions.
 * ----------------------------------------------------------------------------- */

SwigType *Swig_vla_parameter_type(const SwigType *type, Node *node) {
  String *vlasize = node ? Getattr(node, "vlasize") : 0;
  SwigType *vla = 0;
  if (vlasize && SwigType_isarray(type)) {
    int ndim = SwigType_array_ndim(type);
    int i;
    for (i = 0; i < ndim; i++) {
      String *size = vlasize_dimension(vlasize, i);
      if (size && Len(size) > 0) {
        if (!vla)
          vla = Copy(type);
        SwigType_array_setdim(vla, i, "*");
      }
      Delete(size);
    }
  }
  return vla;
}

/* -----------------------------------------------------------------------------
 * Swig_vla_wrapped_type()
 *
 * For 'matchtype', the type of a typemap written with '[*]' that matched a C99 variable length array parameter, as in
 * 'int [*]', return a copy without the '*' sizes, as in 'int []'.  This is the type the parameter is wrapped as, which
 * $1_type and the other type variables expand to, as '*' as a size is only valid in a function prototype.  Return 0
 * when 'matchtype' has no array dimension with '*' as its size.
 * ----------------------------------------------------------------------------- */

SwigType *Swig_vla_wrapped_type(const SwigType *matchtype) {
  SwigType *wrapped = 0;
  if (SwigType_isarray_vla(matchtype)) {
    int ndim = SwigType_array_ndim(matchtype);
    int i;
    wrapped = Copy(matchtype);
    for (i = 0; i < ndim; i++) {
      String *dim = SwigType_array_getdim(wrapped, i);
      if (Equal(dim, "*"))
        SwigType_array_setdim(wrapped, i, "");
      Delete(dim);
    }
  }
  return wrapped;
}

/* -----------------------------------------------------------------------------
 * Swig_vla_dimension_operand()
 *
 * The size that dimension 'i' of C99 variable length array parameter 'p' in the parameters 'parms' of a wrapper has at
 * runtime, as an operand in C, such as '(arg1)' for the 'char s[n]' of 'int n, char s[n]'.  Return 0 if the dimension
 * is not variable.
 * ----------------------------------------------------------------------------- */

String *Swig_vla_dimension_operand(Parm *p, ParmList *parms, int i) {
  String *size = vlasize_dimension(Getattr(p, "vlasize"), i);
  String *operand = 0;
  if (size && Len(size) > 0) {
    operand = NewStringf("(%s)", size);
    ParmList_replace_positional(operand, declaration_parms(parms), "lname");
  }
  Delete(size);
  return operand;
}

/* Whether 's' contains the array size variable 'var', but not only as the start of another variable, as '$1_dim1' is
   of '$1_dim10'. */
static int has_array_size_var(const String *s, const String *var) {
  int len = Len(var);
  const char *c = Strstr(s, var);
  while (c && isdigit((unsigned char)c[len])) {
    c = Strstr(c + len, var);
  }
  return c != 0;
}

/* Whether 's' uses a size of a C99 variable length array parameter that a typemap written with '[*]' matched as
   'matchtype', which is a size only known at runtime: $<index>_dim<i> for each dimension i written as '[*]', also
   $dim<i> for 'index' 1, or $<index>_size. */
static int uses_vla_size(const String *s, SwigType *matchtype, int index) {
  int used = 0;
  int runtime = 0;
  int ndim = SwigType_array_ndim(matchtype);
  int i;
  for (i = 0; i < ndim && !used; i++) {
    String *dim = SwigType_array_getdim(matchtype, i);
    if (Equal(dim, "*")) {
      String *var = NewStringf("$%d_dim%d", index, i);
      String *shortvar = NewStringf("$dim%d", i);
      runtime = 1;
      used = has_array_size_var(s, var) || (index == 1 && has_array_size_var(s, shortvar));
      Delete(shortvar);
      Delete(var);
    }
    Delete(dim);
  }
  if (runtime && !used) {
    String *sizevar = NewStringf("$%d_size", index);
    used = has_array_size_var(s, sizevar);
    Delete(sizevar);
  }
  return used;
}

/* Report the error that 'what', a typemap or a part of one, cannot use the runtime size of C99 variable length array
   parameter 'p'.  The error is reported once only, as the typemaps for a function can be attached more than once.  It
   is reported once for each 'key' at the location of 'p', or for each message when 'key' is 0. */
static void report_vla_size_use(Parm *p, const String *what, const String *key) {
  static Hash *reported = 0;
  String *pname = Getattr(p, "name");
  String *pstr = pname ? Copy(pname) : SwigType_str(Getattr(p, "type"), 0);
  String *message = NewStringf("%s cannot use the runtime size of variable length array parameter '%s'.\n", what, pstr);
  String *reported_key = NewStringf("%s:%d:%s", Getfile(p), Getline(p), key ? key : message);
  if (!reported)
    reported = NewHash();
  if (!Getattr(reported, reported_key)) {
    Swig_error(Getfile(p), Getline(p), "%s", message);
    Setattr(reported, reported_key, "1");
  }
  Delete(reported_key);
  Delete(message);
  Delete(pstr);
}

/* -----------------------------------------------------------------------------
 * Swig_vla_check_size_use()
 *
 * The runtime size of a C99 variable length array parameter 'p' is a variable in the C wrapper, such as 'arg1' for 's'
 * in these parameters:
 *   int n, char s[n]
 * It only has a value once the arguments are converted, so only these typemaps written with '[*]' can use it, as
 * $1_dim0, $dim0 or $1_size for 'index' 1:
 *   %typemap(in) with numinputs other than 0
 *   %typemap(check)
 *   %typemap(argout)
 *   %typemap(freearg)
 * Report an error for any other typemap 'tm' that matched 'p' as 'matchtype' and uses the size in its code.  These are
 * the typemaps that run before the arguments are converted, such as 'typecheck', 'default' and 'arginit', and the
 * target language typemaps.  Also report a typemap attribute that uses it.  Only typemap_attach_parms() can substitute
 * the size, which 'substituted' is set for, as the size needs the other parameters.
 * ----------------------------------------------------------------------------- */

void Swig_vla_check_size_use(const_String_or_char_ptr tmap_method, Hash *tm, SwigType *matchtype, Parm *p, int index, int substituted) {
  String *code = Getattr(tm, "code");
  int allowed = 0;
  Parm *kw;

  if (!SwigType_isarray_vla(matchtype))
    return;

  if (substituted) {
    if (Equal(tmap_method, "in")) {
      /* The last numinputs given is the one the wrapper uses, as typemap_attach_kwargs() attaches each in turn */
      String *numinputs = 0;
      for (kw = Getattr(tm, "kwargs"); kw; kw = nextSibling(kw)) {
        if (Equal(Getattr(kw, "name"), "numinputs"))
          numinputs = Getattr(kw, "value");
      }
      allowed = !Equal(numinputs, "0");
    } else {
      allowed = Equal(tmap_method, "check") || Equal(tmap_method, "argout") || Equal(tmap_method, "freearg");
    }
  }

  if (!allowed && code && uses_vla_size(code, matchtype, index)) {
    String *what;
    if (substituted && Equal(tmap_method, "in")) {
      what = NewString("An 'in' typemap with numinputs=0");
    } else {
      what = NewStringf("The '%s' typemap", tmap_method);
    }
    report_vla_size_use(p, what, 0);
    Delete(what);
  }

  for (kw = Getattr(tm, "kwargs"); kw; kw = nextSibling(kw)) {
    String *value = Getattr(kw, "value");
    if (DohIsString(value) && uses_vla_size(value, matchtype, index)) {
      String *what = NewStringf("The '%s' typemap attribute '%s'", tmap_method, Getattr(kw, "name"));
      report_vla_size_use(p, what, 0);
      Delete(what);
    }
  }
}

/* -----------------------------------------------------------------------------
 * Swig_vla_check_locals()
 *
 * A typemap's local variables are declared before any argument is converted, so they cannot use the runtime size of a
 * C99 variable length array parameter.  Report an error for each of the typemap's 'locals' whose type or value uses a
 * size of parameter 'p', which the typemap written with '[*]' matched as 'matchtype' for typemap parameter 'index'.
 * ----------------------------------------------------------------------------- */

void Swig_vla_check_locals(ParmList *locals, SwigType *matchtype, Parm *p, int index) {
  Parm *local;
  for (local = locals; local; local = nextSibling(local)) {
    String *name = Getattr(local, "name");
    String *lvalue = Getattr(local, "value");
    if (uses_vla_size(Getattr(local, "type"), matchtype, index) || (lvalue && uses_vla_size(lvalue, matchtype, index))) {
      String *what = NewStringf("Typemap local variable '%s'", name);
      report_vla_size_use(p, what, name);
      Delete(what);
    }
  }
}

/* -----------------------------------------------------------------------------
 * Swig_vla_is_size_parm()
 *
 * Whether parameter 'p' in the parameters 'parms' of a wrapper is used in the size of a later C99 variable length array
 * parameter, as 'n' is here:
 *   int n, int a[n]
 * The array's "vlasize" gives the parameters it uses by their position in the declaration, which a wrapper for a
 * method puts after self, so the size of 'a' is '$1'.
 * ----------------------------------------------------------------------------- */

int Swig_vla_is_size_parm(ParmList *parms, Parm *p) {
  int used = 0;
  int position = 1;
  Parm *q;
  for (q = declaration_parms(parms); q && q != p; q = nextSibling(q)) {
    position++;
  }
  if (q) {
    String *dollar = NewStringf("$%d", position);
    for (q = nextSibling(p); q && !used; q = nextSibling(q)) {
      String *vlasize = Getattr(q, "vlasize");
      used = vlasize && has_array_size_var(vlasize, dollar);
    }
    Delete(dollar);
  }
  return used;
}

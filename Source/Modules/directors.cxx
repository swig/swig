/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * directors.cxx
 *
 * Director support functions.
 * Not all of these may be necessary, and some may duplicate existing functionality
 * in SWIG.  --MR
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"

/* -----------------------------------------------------------------------------
 * Swig_csuperclass_call()
 *
 * Generates a fully qualified method call, including the full parameter list.
 * e.g. "base::method(i, j)"
 * ----------------------------------------------------------------------------- */

String *Swig_csuperclass_call(String *base, String *method, ParmList *l) {
  String *call = NewString("");
  int arg_idx = 0;
  Parm *p;
  if (base) {
    Printf(call, "%s::", base);
  }
  Printf(call, "%s(", method);
  for (p = l; p; p = nextSibling(p)) {
    SwigType *pt = Getattr(p, "type");
    SwigType *rpt = SwigType_typedef_resolve_all(pt);
    String *pname = Getattr(p, "name");
    String *pname_created = 0;
    if (!pname && (SwigType_type(pt) != T_VOID)) {
      pname_created = NewStringf("arg%d", arg_idx++);
    }
    if (p != l)
      Printf(call, ", ");
    String *parm_name = pname_created ? pname_created : pname;
    if (SwigType_isrvalue_reference(rpt))
      Printv(call, "std::move(", parm_name, ")", NIL);
    else
      Printv(call, parm_name, NIL);
    Delete(pname_created);
    Delete(rpt);
  }
  Printf(call, ")");
  return call;
}

/* -----------------------------------------------------------------------------
 * Swig_class_declaration()
 *
 * Generate the start of a class/struct declaration.
 * e.g. "class myclass"
 * ----------------------------------------------------------------------------- */

String *Swig_class_declaration(Node *n, String *name) {
  if (!name) {
    name = Getattr(n, "sym:name");
  }
  String *result = NewString("");
  String *kind = Getattr(n, "kind");
  Printf(result, "%s %s", kind, name);
  return result;
}

/* -----------------------------------------------------------------------------
 * Swig_class_name()
 * ----------------------------------------------------------------------------- */

String *Swig_class_name(Node *n) {
  String *name;
  name = Copy(Getattr(n, "sym:name"));
  return name;
}

/* -----------------------------------------------------------------------------
 * Swig_director_declaration()
 *
 * Generate the full director class declaration, complete with base classes.
 * e.g. "class SwigDirector_myclass : public myclass, public Swig::Director {"
 * ----------------------------------------------------------------------------- */

String *Swig_director_declaration(Node *n) {
  String *classname = Swig_class_name(n);
  String *directorname = Language::instance()->directorClassName(n);
  String *base = Getattr(n, "classtype");
  String *declaration = Swig_class_declaration(n, directorname);

  Printf(declaration, " : public %s, public Swig::Director {\n", base);
  Delete(classname);
  Delete(directorname);
  return declaration;
}

/* -----------------------------------------------------------------------------
 * Swig_method_call()
 * ----------------------------------------------------------------------------- */

String *Swig_method_call(const_String_or_char_ptr name, ParmList *parms) {
  String *func = NewString("");
  int comma = 0;
  Parm *p = parms;
  String *nname = SwigType_namestr(name);
  Printf(func, "%s(", nname);

  while (p) {
    SwigType *pt = Getattr(p, "type");
    if ((SwigType_type(pt) != T_VOID)) {
      SwigType *rpt = SwigType_typedef_resolve_all(pt);
      String *pname = Getattr(p, "name");
      if (comma)
        Append(func, ",");
      if (SwigType_isrvalue_reference(rpt))
        Printv(func, "std::move(", pname, ")", NIL);
      else
        Printv(func, pname, NIL);
      Delete(rpt);
      comma = 1;
    }
    p = nextSibling(p);
  }

  Printf(func, ")");
  return func;
}

/* -----------------------------------------------------------------------------
 * Swig_method_decl()
 *
 * Return a stringified version of a C/C++ declaration.
 * The declarator, the id followed by the parameters, qualifiers and exception_specification, if any, goes inside the
 * return type, as in 'int (*id(int x) const noexcept)(int,int)' for a method returning a function pointer.
 * ----------------------------------------------------------------------------- */

String *Swig_method_decl(SwigType *return_base_type, SwigType *decl, const_String_or_char_ptr id, List *args, int default_args,
                         const_String_or_char_ptr exception_specification) {
  bool conversion_operator = Strstr(id, "operator ") != 0 && !return_base_type;

  Parm *parm = args;
  int arg_idx = 0;
  while (parm) {
    String *type = Getattr(parm, "type");
    String *name = Getattr(parm, "name");
    if (!name && Cmp(type, "void")) {
      name = NewString("");
      Printf(name, "arg%d", arg_idx++);
      Setattr(parm, "name", name);
    }
    parm = nextSibling(parm);
  }

  String *rettype = Copy(decl);
  String *quals = SwigType_pop_function_qualifiers(rettype);
  String *popped_decl = SwigType_pop_function(rettype);
  if (return_base_type)
    Append(rettype, return_base_type);

  String *args_string = default_args ? ParmList_str_defaultargs(args) : ParmList_str(args);
  String *declarator = NewStringf("%s(%s)", id, args_string);
  if (quals) {
    String *qualifiers = SwigType_str(quals, 0);
    Printv(declarator, " ", qualifiers, NIL);
    Delete(qualifiers);
  }
  if (exception_specification)
    Printv(declarator, " ", exception_specification, NIL);

  String *result = conversion_operator ? Copy(declarator) : SwigType_str(rettype, declarator);

  Delete(declarator);
  Delete(args_string);
  Delete(popped_decl);
  Delete(quals);
  Delete(rettype);
  return result;
}

/* -----------------------------------------------------------------------------
 * Swig_director_exception_specification()
 *
 * Return the exception specification for the director method of the member function n, which is 'noexcept', 'noexcept(false)'
 * or a 'throw' exception specification, or NULL if n has none.  A 'noexcept' with an expression other than 'false' gives 'noexcept',
 * which is never looser than the specification of n, as the expression need not be valid in the director class.  The 'throw' one
 * lists the exceptions of n that have a "throws" typemap, which is attached to the "throws" parameters of n.
 * ----------------------------------------------------------------------------- */

String *Swig_director_exception_specification(Node *n) {
  String *nexcept = Getattr(n, "noexcept");
  if (nexcept)
    return NewString(Equal(nexcept, "false") ? "noexcept(false)" : "noexcept");
  ParmList *throw_parm_list = Getattr(n, "throws");
  if (!throw_parm_list && !Getattr(n, "throw"))
    return NULL;
  String *exception_specification = NewString("throw(");
  if (throw_parm_list)
    Swig_typemap_attach_parms("throws", throw_parm_list, 0);
  bool first = true;
  for (Parm *p = throw_parm_list; p; p = nextSibling(p)) {
    if (Getattr(p, "tmap:throws")) {
      if (!first)
        Append(exception_specification, ", ");
      first = false;
      String *str = SwigType_str(Getattr(p, "type"), 0);
      Append(exception_specification, str);
      Delete(str);
    }
  }
  Append(exception_specification, ")");
  return exception_specification;
}

/* -----------------------------------------------------------------------------
 * Swig_director_emit_dynamic_cast()
 *
 * In order to call protected virtual director methods from the target language, we need
 * to add an extra dynamic_cast to call the public C++ wrapper in the director class.
 * Also for non-static protected members when the allprotected option is on.
 * ----------------------------------------------------------------------------- */

bool Swig_director_emit_dynamic_cast(Node *n, Wrapper *f) {
  // TODO: why is the storage element removed in staticmemberfunctionHandler ??
  if ((!is_public(n) && (is_member_director(n) || GetFlag(n, "explicitcall"))) ||
      (is_non_virtual_protected_access(n) && !(Swig_storage_isstatic_custom(n, "staticmemberfunctionHandler:storage") || Swig_storage_isstatic(n)) &&
       !Equal(nodeType(n), "constructor"))) {
    Node *parent = Getattr(n, "parentNode");
    String *dirname;
    String *dirdecl;
    dirname = Language::instance()->directorClassName(parent);
    dirdecl = NewStringf("%s *darg = 0", dirname);
    Wrapper_add_local(f, "darg", dirdecl);
    Printf(f->code, "darg = dynamic_cast<%s *>(arg1);\n", dirname);
    Delete(dirname);
    Delete(dirdecl);
    return true;
  }
  return false;
}

/* -----------------------------------------------------------------------------
 * Swig_director_parms_fixup()
 *
 * For each parameter in the C++ member function, copy the parameter name
 * to its "lname"; this ensures that Swig_typemap_attach_parms() will do
 * the right thing when it sees strings like "$1" in "directorin" typemaps.
 * ----------------------------------------------------------------------------- */

void Swig_director_parms_fixup(ParmList *parms) {
  Parm *p;
  int i;
  for (i = 0, p = parms; p; p = nextSibling(p), ++i) {
    String *arg = Getattr(p, "name");
    String *lname = 0;

    if (!arg && !Equal(Getattr(p, "type"), "void")) {
      lname = NewStringf("arg%d", i);
      Setattr(p, "name", lname);
    } else
      lname = Copy(arg);

    Setattr(p, "lname", lname);
    Delete(lname);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_director_can_unwrap()
 *
 * Determine whether a function's return type can be returned as an existing
 * target language object instead of creating a new target language object.
 * Must be a director class and only for return by pointer or reference only
 * (not by value or by pointer to pointer etc).
 * ----------------------------------------------------------------------------- */

bool Swig_director_can_unwrap(Node *n) {

  // FIXME: this will not try to unwrap directors returned as non-director
  //        base class pointers!

  bool unwrap = false;

  String *type = Getattr(n, "type");
  SwigType *t = SwigType_typedef_resolve_all(type);
  SwigType *t1 = SwigType_strip_qualifiers(t);
  SwigType *prefix = SwigType_prefix(t1);

  if (Strcmp(prefix, "p.") == 0 || Strcmp(prefix, "r.") == 0) {
    Node *parent = Swig_methodclass(n);
    Node *module = Getattr(parent, "module");
    Node *target = Swig_directormap(module, t1);
    if (target)
      unwrap = true;
  }

  Delete(prefix);
  Delete(t1);
  Delete(t);

  return unwrap;
}

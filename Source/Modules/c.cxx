/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * c.cxx
 *
 * C language module for SWIG.
 * ----------------------------------------------------------------------------- */

#include <ctype.h>
#include "swigmod.h"

extern "C" {
extern int UseWrapperSuffix;
}

// Return true if the type is one of the builtin types of the typemaps in c.swg, which the header file declares as they are, such as 'unsigned int'.
int SwigType_isbuiltin(SwigType *t) {
  const char *builtins[] = {"void",
                            "bool",
                            "char",
                            "signed char",
                            "unsigned char",
                            "short",
                            "unsigned short",
                            "int",
                            "unsigned int",
                            "long",
                            "unsigned long",
                            "long long",
                            "unsigned long long",
                            "float",
                            "double",
                            0};
  int i = 0;
  char *c = Char(t);
  if (!t)
    return 0;
  while (builtins[i]) {
    if (strcmp(c, builtins[i]) == 0)
      return 1;
    i++;
  }
  return 0;
}

// Private helpers, could be made public and reused from other language modules in the future.
namespace {

enum exceptions_support {
  exceptions_support_enabled,   // Default value in C++ mode.
  exceptions_support_disabled,  // Not needed at all.
  exceptions_support_imported   // Needed, but already defined in an imported module.
};

// When using ScopedPtr, it's very simple to accidentally pass it to a vararg function, such as Printv() or Printf(), resulting in catastrophic results
// during run-time (crash or, worse, junk in the generated output), so make sure gcc warning about this, which is not enabled by default for some reason (see
// https://gcc.gnu.org/bugzilla/show_bug.cgi?id=64867 for more information), is enabled.
#if defined(__GNUC__) && !defined(__clang__)
#pragma GCC diagnostic error "-Wconditionally-supported"
#endif  // __GNUC__

// Delete a DOH object on scope exit.
class ScopedPtr {
public:
  ScopedPtr() : obj_(NULL) {
  }
  explicit ScopedPtr(DOH *obj) : obj_(obj) {
  }
  ~ScopedPtr() {
    Delete(obj_);
  }

  // This is an std::auto_ptr<>-like "destructive" copy ctor which allows to return objects of this type from functions.
  ScopedPtr(ScopedPtr const &other) : obj_(other.release()) {
  }

  // Same for the assignment operator.
  ScopedPtr &operator=(ScopedPtr const &other) {
    reset(other.release());

    return *this;
  }

  // Assignment operator takes ownership of the pointer, just as the ctor does.
  ScopedPtr &operator=(DOH *obj) {
    reset(obj);

    return *this;
  }

  DOH *get() const {
    return obj_;
  }

  DOH *release() const /* not really */ {
    DOH *obj = obj_;
    const_cast<DOH *&>(const_cast<ScopedPtr *>(this)->obj_) = NULL;
    return obj;
  }

  void reset(DOH *obj = NULL) {
    if (obj != obj_) {
      Delete(obj_);
      obj_ = obj;
    }
  }

  operator DOH *() const {
    return obj_;
  }

protected:
  DOH *obj_;
};

// Adopts ownership from a raw pointer and transfers it to the returned ScopedPtr.
// For explicitly initializing a ScopedPtr by assignment such as:
//   ScopedPtr type = adopt(Copy(t));
ScopedPtr adopt(DOH *obj) {
  return ScopedPtr(obj);
}

// Wrapper for a DOH object which can be owned or not.
class MaybeOwnedPtr : public ScopedPtr {
public:
  explicit MaybeOwnedPtr(DOH *obj = NULL) : ScopedPtr(obj), owned_(true) {
  }

  MaybeOwnedPtr(MaybeOwnedPtr const &other) : ScopedPtr(other) {
    owned_ = other.owned_;

    // We can live other.owned_ unchanged, as its pointer is null now anyhow.
  }

  MaybeOwnedPtr &operator=(MaybeOwnedPtr const &other) {
    reset(other.release());
    owned_ = other.owned_;

    return *this;
  }

  ~MaybeOwnedPtr() {
    if (!owned_)
      obj_ = NULL;  // Prevent it from being deleted by the base class dtor.
  }

  void assign_owned(DOH *obj) {
    reset(obj);
  }

  void assign_non_owned(DOH *obj) {
    reset(obj);
    owned_ = false;
  }

private:
  bool owned_;
};

// Helper class setting the given pointer to the given value in its ctor and resetting it in the dtor.
//
// Used to non-intrusively set a pointer to some object only during this object life-time.
template <typename T>
class TempPtrSetter {
public:
  // Pointer must be non-null, its current value is restored when this object is destroyed.
  TempPtrSetter(T *ptr, T value) : ptr_(ptr), value_orig_(*ptr) {
    *ptr_ = value;
  }

  ~TempPtrSetter() {
    *ptr_ = value_orig_;
  }

private:
  T *const ptr_;
  T const value_orig_;

  // Non copyable.
  TempPtrSetter(const TempPtrSetter &);
  TempPtrSetter &operator=(const TempPtrSetter &);
};

// Helper class to output "begin" fragment in the ctor and "end" in the dtor.
class BeginEndOutputGuard {
public:
  BeginEndOutputGuard(File *f, const_String_or_char_ptr begin, const_String_or_char_ptr end) : f_(f), end_(NewString(end)) {
    String *const s = NewString(begin);
    Dump(s, f_);
    Delete(s);
  }

  ~BeginEndOutputGuard() {
    Dump(end_, f_);
    Delete(end_);
  }

private:
  // Non copyable.
  BeginEndOutputGuard(const BeginEndOutputGuard &);
  BeginEndOutputGuard &operator=(const BeginEndOutputGuard &);

  File *const f_;
  String *const end_;
};

// Subclass to output extern "C" guards when compiling as C++.
class CPlusPlusOutputGuard : private BeginEndOutputGuard {
public:
  explicit CPlusPlusOutputGuard(File *f) :
    BeginEndOutputGuard(f,
                        "#ifdef __cplusplus\n"
                        "extern \"C\" {\n"
                        "#endif\n\n",
                        "#ifdef __cplusplus\n"
                        "}\n"
                        "#endif\n\n") {
  }
};

// String containing one indentation level for the generated code.
const char *const cindent = "  ";

// Returns the non-owned string to the name of the class or enum to use in C wrappers.
String *get_c_proxy_name(Node *n) {
  String *proxyname = Getattr(n, "proxyname");
  if (!proxyname) {
    String *symname = Getattr(n, "sym:name");
    String *nspace = Getattr(n, "sym:nspace");

    if (nspace) {
      ScopedPtr nspace_mangled = adopt(Swig_name_mangle_string(nspace));
      proxyname = NewStringf("%s_%s", (DOH *)nspace_mangled, symname);
    } else {
      proxyname = Swig_name_type(symname);
    }
    Setattr(n, "proxyname", proxyname);

    Delete(proxyname);  // It stays alive because it's referenced by the hash.
  }

  return proxyname;
}

// Returns the first named "import" node under the given one (which must be non-NULL). May return NULL.
Node *find_first_named_import(Node *parent) {
  for (Node *n = firstChild(parent); n; n = nextSibling(n)) {
    if (Cmp(nodeType(n), "import") == 0) {
      // We've almost succeeded, but there are sometimes some weird unnamed import modules that don't really count for our purposes, so skip them.
      if (Getattr(n, "module"))
        return n;
    } else if (Cmp(nodeType(n), "include") == 0) {
      // Recurse into this node as included files may contain imports too.
      if (Node *const import = find_first_named_import(n))
        return import;
    } else {
      // We consider that import nodes can only occur in the global scope, some don't bother recursing here. If this turns out to be false, we'd just need to
      // start doing it.
    }
  }

  return NULL;
}

// Return true if the type is a pointer or a reference to a function or an array, or to a pointer to one and so on, with any
// cv-qualifiers, as in 'int (*const &)(int)', 'int (**)(int)', 'int (&)(int)' or 'int (*)[4]', which SwigType_str() outputs
// with the declarator inside it. An array of a class or an enum, or of pointers to one, is left out, as C has no arrays of the
// incomplete struct that the header file declares a class as, and the C++ wrappers take a pointer to an enum for it.
bool is_ptr_to_func_or_array(const SwigType *type) {
  ScopedPtr ptr_type = adopt(SwigType_remove_qualifier(Copy(type)));
  while (SwigType_ispointer(ptr_type) || SwigType_isanyreference(ptr_type)) {
    Delete(SwigType_pop(ptr_type));
    SwigType_remove_qualifier(ptr_type);
    if (SwigType_isfunction(ptr_type))
      return true;
    if (SwigType_isarray(ptr_type)) {
      ScopedPtr base_type = adopt(SwigType_base(ptr_type));
      return !SwigType_isenum(base_type) && SwigType_type(base_type) != T_USER;
    }
  }
  return false;
}

// Return true if the type is a pointer to member, or a pointer or a reference to one and so on, with any cv-qualifiers, as in 'int Foo::*',
// 'int (Foo::*const &)(int)' or 'int Foo::**'.
bool is_member_pointer_type(const SwigType *type) {
  ScopedPtr ptr_type = adopt(SwigType_remove_qualifier(Copy(type)));
  while (SwigType_ispointer(ptr_type) || SwigType_isanyreference(ptr_type)) {
    Delete(SwigType_pop(ptr_type));
    SwigType_remove_qualifier(ptr_type);
  }
  return SwigType_ismemberpointer(ptr_type);
}

// Return true if the type is a pointer to member, with any cv-qualifiers, or a const reference to one, as in 'int Foo::*const &', which the typemaps pass and
// return by value as the struct holding the bytes of the pointer to member, see get_member_pointer_struct_name().
bool is_member_pointer_value(SwigType *type) {
  ScopedPtr value_type = adopt(SwigType_typedef_resolve_all(type));
  SwigType_remove_qualifier(value_type);
  if (SwigType_isreference(value_type)) {
    Delete(SwigType_pop(value_type));
    if (!SwigType_isconst(value_type))
      return false;
    SwigType_remove_qualifier(value_type);
  }
  return SwigType_ismemberpointer(value_type);
}

// Return the name of the struct holding the bytes of a pointer to member of the given type, which has no top level cv-qualifiers, in the wrappers, as C has
// no pointers to members, such as 'SWIGTYPE_m_Shape__f_void__double' for 'double (Shape::*)()'.
String *get_member_pointer_struct_name(SwigType *type) {
  ScopedPtr mangled_type = adopt(SwigType_manglestr(type));
  return NewStringf("SWIGTYPE%s", mangled_type.get());
}

// Append the base type, whose typedefs are resolved, of the type and of each parameter of a function type in it, as in a function pointer, to base_types.
void append_base_types(SwigType *type, List *base_types) {
  ScopedPtr resolved_type = adopt(SwigType_typedef_resolve_all(type));
  ScopedPtr elements = adopt(SwigType_split(resolved_type));
  for (Iterator i = First(elements); i.item; i = Next(i)) {
    if (SwigType_isfunction(i.item)) {
      ScopedPtr parms = adopt(SwigType_parmlist(i.item));
      for (Iterator j = First(parms); j.item; j = Next(j)) {
        append_base_types(j.item, base_types);
      }
    }
  }

  ScopedPtr base_type = adopt(SwigType_base(resolved_type));
  Append(base_types, base_type);
}

// Return true if is_used() is true for one of the base types of the type, see append_base_types().
bool uses_base_type(SwigType *type, bool (*is_used)(SwigType *base_type)) {
  ScopedPtr base_types = adopt(NewList());
  append_base_types(type, base_types);
  for (Iterator i = First(base_types); i.item; i = Next(i)) {
    if (is_used(i.item))
      return true;
  }
  return false;
}

// Remove volatile from the type that the pointer or reference type points or refers to, keeping any const, as in 'Foo *' for
// 'Foo volatile *' or 'Foo const &' for 'Foo const volatile &'.
void remove_referred_volatile(SwigType *type) {
  ScopedPtr referred_type = adopt(Copy(type));
  ScopedPtr pointer_or_reference = adopt(SwigType_pop(referred_type));
  if (!SwigType_isqualifier(referred_type))
    return;
  ScopedPtr qualifier = adopt(SwigType_pop(referred_type));
  if (!Strstr(qualifier, "volatile"))
    return;
  if (Strstr(qualifier, "const"))
    SwigType_add_qualifier(referred_type, "const");
  SwigType_push(referred_type, pointer_or_reference);
  Clear(type);
  Append(type, referred_type);
}

// Return the type with a pointer in place of each reference in it and in the parameters of any function in it, as
// C has no references, as in 'int *(*)(int const *,int)' for 'int &(*)(int const &,int)'.
// The qualifiers of each function type, such as the 'noexcept' of 'int (*)(int) noexcept', are dropped too, as C does not have them.
SwigType *references_to_pointers(const SwigType *type) {
  ScopedPtr elements = adopt(SwigType_split(type));
  int const last = Len(elements) - 1;
  SwigType *c_type = Copy(Getitem(elements, last));
  for (int i = last - 1; i >= 0; i--) {
    SwigType *const element = Getitem(elements, i);
    if (SwigType_isanyreference(element)) {
      SwigType_add_pointer(c_type);
    } else if (SwigType_isqualifier(element) && SwigType_isfunction(Getitem(elements, i + 1))) {
      // Drop the qualifiers of the function type at i + 1, which C does not have
    } else if (SwigType_isfunction(element)) {
      ParmList *const parms = SwigType_function_parms(element, NULL);
      for (Parm *p = parms; p; p = nextSibling(p)) {
        ScopedPtr c_parm_type = adopt(references_to_pointers(Getattr(p, "type")));
        Setattr(p, "type", c_parm_type);
      }
      SwigType_add_function(c_type, parms);
      Delete(parms);
    } else {
      SwigType_push(c_type, element);
    }
  }
  return c_type;
}

// Return the C type that the special variable, such as "$resolved_type", is replaced with in a typemap for the type, given the C name
// of its base type, c_name. The typemap adds a '*' after the special variable, as in "$resolved_type*", so a pointer to a pointer
// keeps its other pointers, as in 'cvoid_S *' for 'S **', which the typemap makes 'cvoid_S **'. With "$*resolved_type", this '*' is
// the reference removed from the type instead, as in 'cvoid_S *' for 'S *&'. Any other type is replaced with just c_name.
String *get_special_variable_c_type(SwigType *type, const char *special_variable, String *c_name) {
  ScopedPtr ptr_type = adopt(Copy(type));
  if (Strcmp(special_variable, "$*resolved_type") != 0 && SwigType_ispointer(ptr_type))
    SwigType_del_pointer(ptr_type);
  ScopedPtr c_type = adopt(NewStringEmpty());
  while (SwigType_ispointer(ptr_type)) {
    SwigType_del_pointer(ptr_type);
    SwigType_add_pointer(c_type);
  }
  ScopedPtr base_type = adopt(SwigType_base(type));
  if (Len(c_type) == 0 || !Equal(ptr_type, base_type))
    return Copy(c_name);

  Append(c_type, c_name);
  return SwigType_str(c_type, 0);
}

// Return the declaration of the function with the given return type, which is NULL for a constructor, name and parameters, as a
// const member function if is_const is true. Each type is either type text, which SwigType_str() outputs as it is, or a SwigType,
// which SwigType_str() outputs with the declarator inside it for a function pointer, as in 'int (*f(int x))(int,int)'.
ScopedPtr get_func_decl(SwigType *return_type, String *name, ParmList *parms, bool is_const = false) {
  ScopedPtr decl = adopt(SwigType_add_function(NewStringEmpty(), parms));
  if (is_const)
    SwigType_add_qualifier(decl, "const");

  return ScopedPtr(Swig_method_decl(return_type, decl, name, parms, 0));
}

// Return the cv-qualifier of the member function with the given decl, such as 'q(const).' for both 'int f() const' and
// 'int f() const &', whose decl 'r.q(const).f().' starts with its ref-qualifier, or NULL if it has none.
SwigType *get_function_cv_qualifier(SwigType *decl) {
  if (!SwigType_isfunction(decl))
    return NULL;

  ScopedPtr function = adopt(SwigType_remove_reference(Copy(decl)));
  return SwigType_isqualifier(function) ? SwigType_pop(function) : NULL;
}

// Return the parameter list of the member function with the given decl without its qualifiers, such as 'f(int).' for
// the decl 'r.q(const).f(int).p.' of 'int *f(int) const &', or NULL if decl is not a function.
SwigType *get_function_parms_type(SwigType *decl) {
  if (!SwigType_isfunction(decl))
    return NULL;

  ScopedPtr return_type = adopt(Copy(decl));
  ScopedPtr function = adopt(SwigType_pop_function(return_type));
  Delete(SwigType_pop_function_qualifiers(function));
  return function.release();
}

// Return true if the cv-qualifier, such as 'q(const volatile).', which may be NULL, has 'volatile'. Adding 'volatile' to
// such a cv-qualifier gives the same cv-qualifier.
bool is_volatile_qualifier(SwigType *cv_qualifier) {
  if (!cv_qualifier)
    return false;

  ScopedPtr volatile_qualifier = adopt(SwigType_add_qualifier(Copy(cv_qualifier), "volatile"));
  return Equal(volatile_qualifier, cv_qualifier);
}

// The qualifiers of the member function with the given decl, which an overload with the same parameters differs in.
struct FunctionQualifiers {
  explicit FunctionQualifiers(SwigType *decl) {
    ScopedPtr cv_qualifier = adopt(get_function_cv_qualifier(decl));
    is_const = SwigType_isconst(cv_qualifier);
    is_volatile = is_volatile_qualifier(cv_qualifier);

    // The decl of a function starts with its ref-qualifier.
    is_rvalue = SwigType_isfunction(decl) && SwigType_isrvalue_reference(decl);
  }

  bool is_const;
  bool is_volatile;
  bool is_rvalue;
};

/*
  Information about a type used in the C++ wrappers, common to the function return type and its parameters.
 */
class CxxTypeDesc {
public:
  // The type is "void" until this function is called. It is either the C++ type given by a typemap, which SwigType_str() outputs as it is, or the SwigType of
  // a function pointer, which SwigType_str() outputs with the declarator inside it, as in 'int (*f)(int,int)' or 'int (*f(int))(int,int)'.
  void set_type(SwigType *type) {
    type_ = Copy(type);
  }

  // Return the type set by set_type(), or "void" if it was not called.
  SwigType *type() const {
    return type_ ? type_ : get_void_type();
  }

protected:
  CxxTypeDesc() {
  }

  ScopedPtr type_;

private:
  static String *get_void_type() {
    static String *const void_type = NewString("void");
    return void_type;
  }
};

/*
  Information about the function return type.
 */
class CxxRTypeDesc : public CxxTypeDesc {
public:
  // Default ctor creates a "void" return type.
  CxxRTypeDesc() {
  }

  // If this returns true, get_return_code() can't be called.
  bool is_void() const {
    return !type_;
  }

  // This function must be called before calling get_return_code(), as must set_type().
  //
  // NB: It takes ownership of the string, the intended use is to pass it NewStringf(...).
  void set_return_value(String *new_string) {
    value_ = new_string;
  }

  // This function applies the given typemap, which must set $result variable from $cresult containing the result of C wrapper function call.
  //
  // If it is not called, the trivial "$result = $cresult" typemap is used and, in fact, the extra variables are optimized away and just "return $cresult" is
  // generated directly for brevity.
  //
  // If the string doesn't start with "$result = ", it is prepended to it implicitly, for convenience.
  //
  // NB: It takes ownership of the string, which is typically returned from Swig_typemap_lookup().
  void apply_out_typemap(String *new_out_tm_string) {
    out_tm_ = new_out_tm_string;
  }

  // Return the string containing the code for returning the value, previously set by set_return_value().
  //
  // The returned string ends with a semicolon, i.e. is a complete statement (or possibly more than one).
  //
  // Asserts unless both set_type() and set_return_value() had been called.
  ScopedPtr get_return_code() const {
    assert(type_);
    assert(value_);

    if (!out_tm_) {
      // Trivial case when we return the same value, just do it.
      //
      // Add extra spaces after/before opening/closing braces because we keep everything on the same line in this case.
      return ScopedPtr(NewStringf(" return %s; ", value_.get()));
    }

    // We need to start by introducing a temporary variable for the C call result because if $cresult is used twice by the typemap, we don't want to call the
    // function twice. Note that just "auto" is enough because C functions can't return references, but we need "auto&&" for C++ result which can be anything
    // (defined by the user in their typemaps).
    ScopedPtr code = adopt(NewStringf("\n"
                                      "%sauto swig_cres = %s;\n",
                                      cindent,
                                      value_.get()));

    // We support 2 cases: either typemap is a statement, or multiple statements, containing assignment to $result, in which case this assignment must occur at
    // its beginning.
    bool const has_result = strstr(Char(out_tm_), "$result = ") != NULL;
    if (has_result) {
      Printv(code, cindent, "auto&& ", NIL);
    } else {
      // Or the typemap is just an expression, which can be returned directly, without defining $result at all. Note that this is more than an optimization as
      // it allows the generated code to work even with non-copyable classes.
      Printv(code, cindent, "return ", NIL);
    }

    // Skip leading whitespace and chop the trailing whitespace from the typemap to keep indentation consistent.
    const char *tm = Char(out_tm_);
    while (isspace(*tm))
      ++tm;
    Append(code, tm);
    Chop(code);

    if ((Char(code))[Len(code) - 1] != ';')
      Append(code, ";");

    Replaceall(code, "$cresult", "swig_cres");

    if (has_result) {
      Printf(code, "\n%sreturn $result;\n", cindent);
      Replaceall(code, "$result", "swig_cxxres");
    } else {
      Append(code, "\n");
    }

    return code;
  }

private:
  ScopedPtr value_;
  ScopedPtr out_tm_;
};

/*
  Information about a function parameter.

  This is similar to CxxRTypeDesc, but is used for the parameters and not the return type.
 */
class CxxPTypeDesc : public CxxTypeDesc {
public:
  // Ctor initializes the object to an empty/unknown state, call set_type() later to finish initialization, before calling get_param_code().
  CxxPTypeDesc() {
  }

  // This may be called before calling get_param_code() if a translation from C++ to C type is necessary. By default the parameter is passed "as is".
  void apply_in_typemap(String *new_in_tm_string) {
    in_tm_ = new_in_tm_string;
  }

  // Return the full expression needed to pass the given value as parameter to C wrapper function.
  ScopedPtr get_param_code(String *value) const {
    assert(type_);

    if (!in_tm_) {
      return ScopedPtr(Copy(value));
    }

    // There doesn't seem to be any simple way to use the full SWIG typemap expansion machinery here, so just do it manually.
    ScopedPtr code = adopt(Copy(in_tm_));
    Replace(code, "$1", value, DOH_REPLACE_NUMBER_END);
    return code;
  }

private:
  ScopedPtr in_tm_;
};

/*
  Struct containing information needed only for generating C++ wrappers.
*/
struct CxxWrappers {
  // Default ctor doesn't do anything, use initialize() if C++ wrappers really need to be generated.
  CxxWrappers() :
    except_check_start(NULL),
    except_check_end(NULL),
    sect_cxx_h(NULL),
    sect_types(NULL),
    sect_decls(NULL),
    sect_impls(NULL),
    ptype_desc_(NULL),
    rtype_desc_(NULL),
    node_func_(NULL) {
  }

  void initialize() {
    sect_cxx_h = NewStringEmpty();
    sect_types = NewStringEmpty();
    sect_decls = NewStringEmpty();
    sect_impls = NewStringEmpty();

    // Allow using SWIG directive to inject code here.
    Swig_register_filebyname("cxxheader", sect_cxx_h);
    Swig_register_filebyname("cxxcode", sect_impls);
  }

  // This function must be called after initialize(). The two can't be combined because we don't yet know if we're going to use exceptions or not when we
  // initialize the object of this class in C::main(), so this one is called later from C::top().
  void initialize_exceptions(exceptions_support support) {
    switch (support) {
    case exceptions_support_enabled:
    case exceptions_support_imported:
      except_check_start = "swig_check(";
      except_check_end = ")";
      break;

    case exceptions_support_disabled:
      except_check_start = except_check_end = "";
      break;
    }
  }

  bool is_initialized() const {
    return sect_types != NULL;
  }

  bool is_exception_support_enabled() const {
    return *except_check_start != '\0';
  }

  // All the functions below are only used when is_initialized() returns true.

  // Fill the provided rtype_desc with the type information for the given function node.
  //
  // Returns false in case of error, i.e. if function wrapper can't be generated at all.
  bool lookup_cxx_ret_type(CxxRTypeDesc &rtype_desc, Node *n) {
    String *const func_type = Getattr(n, "type");
    if (SwigType_type(func_type) == T_VOID) {
      // Nothing to do, rtype_desc is void by default.
      return true;
    }

    // As above, ensure our replaceSpecialVariables() is used.
    TempPtrSetter<CxxRTypeDesc *> set(&rtype_desc_, &rtype_desc);

    bool use_cxxout = true;
    String *type(Swig_typemap_lookup("cxxouttype", n, "", NULL));
    if (!type) {
      use_cxxout = false;
      type = Swig_typemap_lookup("ctype", n, "", NULL);
    }

    if (!type) {
      Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF,
                   Getfile(n),
                   Getline(n),
                   "No ctype typemap defined for the return type \"%s\" of %s\n",
                   SwigType_str(func_type, NULL),
                   Getattr(n, "sym:name"));
      return false;
    }

    if (!do_resolve_type(n, func_type, type, NULL, &rtype_desc))
      return false;

    if (use_cxxout) {
      if (String *out_tm = Swig_typemap_lookup("cxxout", n, "", NULL))
        rtype_desc.apply_out_typemap(out_tm);
    }

    return true;
  }

  // Return the type description for the given parameter of the function.
  bool lookup_cxx_parm_type(CxxPTypeDesc &ptype_desc, Node *n, Parm *p) {
    // Ensure our own replaceSpecialVariables() is used for $typemap() expansion.
    TempPtrSetter<CxxPTypeDesc *> set(&ptype_desc_, &ptype_desc);

    bool use_cxxin = true;
    String *type = Swig_typemap_lookup("cxxintype", p, "", NULL);
    if (!type) {
      use_cxxin = false;
      type = Swig_typemap_lookup("ctype", p, "", NULL);
    }

    if (!type) {
      Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF,
                   Getfile(p),
                   Getline(p),
                   "No ctype typemap defined for the parameter \"%s\" of %s\n",
                   Getattr(p, "name"),
                   Getattr(n, "sym:name"));
      return false;
    }

    if (!do_resolve_type(n, Getattr(p, "type"), type, &ptype_desc, NULL))
      return false;

    if (use_cxxin) {
      if (String *in_tm = Getattr(p, "tmap:cxxin"))
        ptype_desc.apply_in_typemap(Copy(in_tm));
    }

    return true;
  }

  // This function is called from C::replaceSpecialVariables() but only does something non-trivial when it's called by our own lookup_cxx_xxx_type() functions.
  bool replaceSpecialVariables(String *method, String *tm, Parm *parm) {
    if (!ptype_desc_ && !rtype_desc_)
      return false;

    if (Cmp(method, "ctype") != 0) {
      Swig_warning(WARN_C_UNSUPPORTTED, input_file, line_number, "Unsupported %s typemap %s\n", method, tm);
      return false;
    }

    if (SwigType *type = Getattr(parm, "type")) {
      if (ptype_desc_)
        ptype_desc_->set_type(type);
      if (rtype_desc_)
        rtype_desc_->set_type(type);

      if (!do_resolve_type(node_func_, type, tm, ptype_desc_, rtype_desc_))
        return false;
    }

    return true;
  }

  // Used for generating exception checks around the calls, see initialize_exceptions().
  const char *except_check_start;
  const char *except_check_end;

  // The order of the members here is the same as the order in which they appear in the output file.

  // This section doesn't contain anything by default but can be used by typemaps etc. It is the only section outside of the namespace in which all the other
  // declaration live.
  String *sect_cxx_h;

  // This section contains forward declarations of the classes.
  String *sect_types;

  // Full declarations of the classes.
  String *sect_decls;

  // Implementation of the classes.
  String *sect_impls;

private:
  // Warn that the C++ wrappers do not support the type of a parameter, if ptype_desc is given, or a return type.
  static void warn_unsupported_type(String *type, CxxPTypeDesc *ptype_desc) {
    Swig_warning(WARN_C_UNSUPPORTTED,
                 input_file,
                 line_number,
                 "Unsupported C++ wrapper function %s type \"%s\"\n",
                 ptype_desc ? "parameter" : "return",
                 SwigType_str(type, 0));
  }

  // Return true if the type is a class, wrapped or not, or an enum.
  static bool is_class_or_enum(SwigType *type) {
    return SwigType_isenum(type) || SwigType_isclass(type) || Language::instance()->classLookup(type);
  }

  // Replace "resolved_type" occurrences in the string with the value corresponding to the given type.
  //
  // Note that the node here is the function itself, but type may be either its return type or the type of one of its parameters, so it's passed as a different
  // parameter.
  //
  // Also fills in the start/end wrapper parts of the provided type descriptions if they're not null, with the casts needed to translate from C type to C++ type
  // (this is used for the parameters of C++ functions, hence the name) and from C types to C++ types (which is used for the function return values).
  static bool do_resolve_type(Node *n, String *type, String *s, CxxPTypeDesc *ptype_desc, CxxRTypeDesc *rtype_desc) {
    enum TypeKind { Type_Ptr, Type_Ref, Type_Obj, Type_Enm, Type_Max } typeKind = Type_Max;

    // These correspond to the typemaps for SWIGTYPE*, SWIGTYPE&, SWIGTYPE and enum SWIGTYPE, respectively, defined in c.swg.
    static const char *typemaps[Type_Max] = {
      "$resolved_type*",
      "$*resolved_type*",
      "$&resolved_type*",
      "$resolved_type",
    };

    for (int i = 0; i < Type_Max; ++i) {
      if (Strstr(s, typemaps[i])) {
        typeKind = static_cast<TypeKind>(i);
        break;
      }
    }

    if (typeKind == Type_Max) {
      if (Strstr(s, "resolved_type")) {
        Swig_warning(WARN_C_UNSUPPORTTED, input_file, line_number, "Unsupported typemap \"%s\" used for type \"%s\" of \"%s\"\n", s, type, Getattr(n, "name"));

        return false;
      }

      // Nothing else needed.
      if (rtype_desc)
        rtype_desc->set_type(s);
      if (ptype_desc)
        ptype_desc->set_type(s);

      return true;
    }

    // The logic here is somewhat messy because we use the same "$resolved_type*" typemap for pointers/references to both enums and classes, but we actually
    // need to do quite different things for them. It could probably be simplified by changing the typemaps to be distinct, but this would require also updating
    // the code for C wrappers generation in substituteResolvedTypeSpecialVariable().
    //
    // An even better idea might be to try to define this using cxx{in,out} typemaps for the various types and let the generic SWIG machinery do all the
    // matching instead of doing it in the code here.
    ScopedPtr resolved_type = adopt(SwigType_typedef_resolve_all(type));
    ScopedPtr base_resolved_type = adopt(SwigType_base(resolved_type));

    // A pointer to member is passed to and returned from the C function by value as the struct holding its bytes, which the C++ wrappers use too. A pointer
    // or a reference to one other than a const reference is an opaque pointer, which is not supported, as for any other type that SWIG does not wrap.
    if (is_member_pointer_type(resolved_type)) {
      ScopedPtr member_pointer_type = adopt(SwigType_remove_qualifier_reference(Copy(resolved_type)));
      if (typeKind != Type_Enm || !SwigType_ismemberpointer(member_pointer_type)) {
        warn_unsupported_type(type, ptype_desc);
        return false;
      }

      ScopedPtr struct_name = adopt(get_member_pointer_struct_name(member_pointer_type));
      Replaceall(s, typemaps[typeKind], struct_name);
      if (rtype_desc)
        rtype_desc->set_type(s);
      if (ptype_desc)
        ptype_desc->set_type(s);

      return true;
    }

    // A function pointer is passed to and returned from the C function as it is, so it has the type that the C function
    // is declared with. Only its top level qualifiers are removed, as those of its return type, such as the 'const' of
    // 'const char *(*)(int)', are part of this type. A function pointer passed by const reference is passed as the
    // function pointer. A class or an enum in this type is not supported, as its name would refer to the C++ wrapper
    // class or enum in the namespace of the C++ wrappers.
    if (typeKind == Type_Ptr) {
      ScopedPtr stripped_type = adopt(SwigType_remove_qualifier_reference(Copy(resolved_type)));
      if (SwigType_isfunctionpointer(stripped_type)) {
        if (uses_base_type(stripped_type, is_class_or_enum)) {
          warn_unsupported_type(type, ptype_desc);
          return false;
        }

        // The C function is declared with a pointer in place of each reference in this type, as C has no references.
        ScopedPtr c_type = adopt(references_to_pointers(stripped_type));
        if (!Equal(c_type, stripped_type)) {
          if (rtype_desc) {
            ScopedPtr cxx_type_str = adopt(SwigType_str(stripped_type, 0));
            rtype_desc->apply_out_typemap(NewStringf("(%s)$cresult", cxx_type_str.get()));
          }
          if (ptype_desc) {
            ScopedPtr c_type_str = adopt(SwigType_str(c_type, 0));
            ptype_desc->apply_in_typemap(NewStringf("(%s)$1", c_type_str.get()));
          }
        }

        if (rtype_desc)
          rtype_desc->set_type(stripped_type);
        if (ptype_desc)
          ptype_desc->set_type(stripped_type);

        return true;
      }
    }

    ScopedPtr typestr;
    if (SwigType_isenum(base_resolved_type)) {
      // As for a class, an array of enums is passed as a pointer to its first element, but an array of pointers to enums or an array of arrays is not supported
      if (typeKind == Type_Ptr) {
        ScopedPtr element_type = adopt(SwigType_strip_qualifiers(resolved_type));
        SwigType_remove_qualifier_reference(element_type);
        if (SwigType_isarray(element_type)) {
          Delete(SwigType_pop(element_type));
          if (SwigType_ispointer(element_type) || SwigType_isarray(element_type)) {
            warn_unsupported_type(type, ptype_desc);
            return false;
          }
        }
      }

      String *enumname = NULL;
      if (Node *const enum_node = Language::instance()->enumLookup(base_resolved_type)) {
        // This is the name of the enum in C wrappers, it should be already set by getEnumName().
        enumname = Getattr(enum_node, "enumname");

        if (enumname) {
          String *const enum_symname = Getattr(enum_node, "sym:name");

          if (Checkattr(enum_node, "ismember", "1")) {
            Node *const parent_class = parentNode(enum_node);
            typestr = NewStringf("%s::%s", Getattr(parent_class, "sym:name"), enum_symname);
          } else {
            typestr = Copy(enum_symname);
          }
        }
      }

      if (!enumname) {
        // Unknown enums are mapped to int and no casts are necessary in this case.
        typestr = NewString("int");
      }

      // The pointers and the reference of the type are kept, as in 'E **' for 'E **' and 'E *&' for 'E *&', as the C
      // function takes and returns a pointer for each of them, and an array decays to a pointer. A pointer passed by const
      // reference is passed and returned as just the pointer, as for a class below.
      ScopedPtr passed_type = adopt(SwigType_strip_qualifiers(resolved_type));
      if (typeKind == Type_Ptr) {
        SwigType_remove_qualifier_reference(passed_type);
        passed_type = SwigType_decay_array(passed_type);
      }
      ScopedPtr cxx_type = adopt(NewStringEmpty());
      // The C function takes a pointer for each of them, as in 'E**' for 'E **' or 'E *&'
      ScopedPtr c_pointers = adopt(NewStringEmpty());
      while (SwigType_ispointer(passed_type) || SwigType_isreference(passed_type)) {
        ScopedPtr element = adopt(SwigType_pop(passed_type));
        Append(cxx_type, element);
        Append(c_pointers, "*");
      }
      Append(cxx_type, typestr);
      typestr = SwigType_str(cxx_type, 0);

      if (enumname) {
        switch (typeKind) {
        case Type_Ptr:
          if (rtype_desc) {
            rtype_desc->apply_out_typemap(NewStringf("(%s)$cresult", typestr.get()));
          }

          if (ptype_desc) {
            ptype_desc->apply_in_typemap(NewStringf("(%s%s)$1", enumname, c_pointers.get()));
          }
          break;

        case Type_Ref:
          if (rtype_desc) {
            rtype_desc->apply_out_typemap(NewStringf("(%s)(*($cresult))", typestr.get()));
          }

          if (ptype_desc) {
            ptype_desc->apply_in_typemap(NewStringf("(%s%s)&($1)", enumname, c_pointers.get()));
          }
          break;

        case Type_Enm:
          if (rtype_desc) {
            rtype_desc->apply_out_typemap(NewStringf("(%s)$cresult", typestr.get()));
          }

          if (ptype_desc) {
            ptype_desc->apply_in_typemap(NewStringf("(%s)$1", enumname));
          }
          break;

        case Type_Obj:
        case Type_Max:
          // Unreachable, but keep here to avoid -Wswitch warnings.
          assert(0);
        }
      } else {
        // This is the only thing we need to do even when we don't have the enum name.
        if (typeKind == Type_Ref && ptype_desc)
          ptype_desc->apply_in_typemap(NewString("&($1)"));
      }
    } else {
      String *classname;
      if (Node *const class_node = Language::instance()->classLookup(type)) {
        // Deal with some special cases:
        switch (typeKind) {
        case Type_Ptr:
          // A pointer passed by const reference is passed and returned as just the pointer, as we don't have any pointer
          // valued variable to give out a reference to. The top level qualifiers of the pointer, as in 'Foo *const', are
          // removed too. They do not change the type of a parameter and are ignored in a return type, while a volatile
          // parameter or return type is deprecated in C++20.
          SwigType_remove_qualifier_reference(resolved_type);
          // An array is passed and returned as a pointer to its first element, as the C function takes and returns this pointer.
          resolved_type = SwigType_decay_array(resolved_type);
          break;

        case Type_Obj:
          // Const and volatile objects are just objects for our purposes here, remove the qualifiers to avoid having "const const" in the output and as
          // swig_self() is not volatile.
          if (SwigType_isqualifier(resolved_type))
            SwigType_del_qualifier(resolved_type);
          break;

        case Type_Ref:
        case Type_Enm:
        case Type_Max:
          // Nothing special to do.
          break;
        }

        classname = Getattr(class_node, "sym:name");

        // A pointer or a reference to a volatile class is taken and returned without volatile, as in the other target languages, as swig_self() is
        // not volatile, see is_const().
        if (typeKind == Type_Ptr || typeKind == Type_Ref)
          remove_referred_volatile(resolved_type);

        // We don't use namespaces, but the type may contain them, so get rid of them by replacing the base type name, which is fully qualified, with just the
        // class name, which is not.
        ScopedPtr cxx_type = adopt(SwigType_prefix(resolved_type));
        Append(cxx_type, classname);
        typestr = SwigType_str(cxx_type, 0);
      } else {
        classname = NULL;
      }

      if (!classname) {
        warn_unsupported_type(type, ptype_desc);
        return false;
      }

      const char *const owns = GetFlag(n, "feature:new") ? "true" : "false";
      switch (typeKind) {
      case Type_Ptr:
        if (ptype_desc) {
          // NULL is passed on to the C function, as NULL returned by it is returned below.
          ptype_desc->apply_in_typemap(NewString("$1 ? $1->swig_self() : nullptr"));
        }

        if (rtype_desc) {
          rtype_desc->apply_out_typemap(NewStringf("$cresult ? new %s($cresult, %s) : nullptr;", classname, owns));
        }
        break;

      case Type_Ref:
        if (rtype_desc) {
          // We can't return a reference, as this requires an existing object and we don't have any, so we have to return an object instead, and this object
          // must be constructed using the special ctor not taking the pointer ownership.
          typestr = Copy(classname);

          rtype_desc->apply_out_typemap(NewStringf("%s{$cresult, false}", classname));
        }

        if (ptype_desc) {
          ptype_desc->apply_in_typemap(NewString("$1.swig_self()"));
        }
        break;

      case Type_Obj:
        if (rtype_desc) {
          // The pointer returned by C function wrapping a function returning an object should never be null unless an exception happened, so we don't test
          // for it here, unlike in Type_Ptr case.
          //
          // Also, normally all returned objects should be owned by their wrappers, but there is a special case of objects not being returned by value: this
          // seems not to make sense, but can actually happen when typemaps map references or pointers to objects, like they do for e.g. shared_ptr<>.
          //
          // Note that we must use the type of the function, retrieved from its node, here and not the type passed to us which is the result of typemap
          // expansion and so may not be a reference any more.
          rtype_desc->apply_out_typemap(NewStringf("%s{$cresult, %s}", typestr.get(), SwigType_isreference(Getattr(n, "type")) ? owns : "true"));
        }

        if (ptype_desc) {
          // It doesn't seem like it can ever be useful to pass an object by value to a wrapper function and it can fail if it doesn't have a copy ctor (see
          // code related to has_copy_ctor_ in our dtor above), so always pass it by const reference instead.
          Append(typestr, " const&");

          ptype_desc->apply_in_typemap(NewString("$1.swig_self()"));
        }
        break;

      case Type_Enm:
      case Type_Max:
        // Unreachable, but keep here to avoid -Wswitch warnings.
        assert(0);
      }
    }

    Replaceall(s, typemaps[typeKind], typestr);

    if (rtype_desc)
      rtype_desc->set_type(s);
    if (ptype_desc)
      ptype_desc->set_type(s);

    return true;
  }

  // These pointers are temporarily set to non-null value only while expanding a typemap for C++ wrappers, see replaceSpecialVariables().
  CxxPTypeDesc *ptype_desc_;
  CxxRTypeDesc *rtype_desc_;

  // This one is set from the outside, so make it public for simplicity.
public:
  Node *node_func_;
};

/*
  CxxFunctionWrapper

  Outputs the C++ wrapper function. It's different from the C function because it is declared inside the namespace and so doesn't need the usual prefix and may
  also have different parameter and return types when objects and/or cxx{in,out}type typemaps are involved.
 */
class CxxFunctionWrapper {
public:
  // Call can_wrap() to check if this wrapper can be emitted later.
  explicit CxxFunctionWrapper(CxxWrappers &cxx_wrappers, Node *n, Parm *p) : cxx_wrappers_(cxx_wrappers) {
    func_node = NULL;

    except_check_start = except_check_end = "";

    if (Checkattr(n, "feature:cxxignore", "1"))
      return;

    // Usually generating wrappers for overloaded methods is fine, but sometimes their types can clash after applying typemaps and in this case we have no
    // choice but to avoid generating them, as otherwise we'd just generate uncompilable code.
    if (Getattr(n, "sym:overloaded")) {
      Swig_overload_check(n);
      if (Getattr(n, "overload:ignore"))
        return;
    }

    if (!cxx_wrappers_.lookup_cxx_ret_type(rtype_desc, n))
      return;

    parms_call = NewStringEmpty();

    if (p) {
      // We want to use readable parameter names in our wrappers instead of the autogenerated arg$N if possible, so do it, and do it before calling
      // Swig_typemap_attach_parms(), as this uses the parameter names for typemap expansion.
      for (Parm *p2 = p; p2; p2 = nextSibling(p2)) {
        String *name = Getattr(p2, "name");
        if (!name) {
          // Can't do anything for unnamed parameters.
          continue;
        }

        // A parameter named like an earlier one keeps its autogenerated name, as C++ does not allow two parameters with the same name.
        if (ParmList_find_name(p, name) != p2) {
          continue;
        }

        // Static variables use fully qualified names, so we need to strip the scope from them.
        ScopedPtr name_ptr;
        if (Strstr(name, "::")) {
          name_ptr = Swig_scopename_last(name);
          name = name_ptr.get();
        }

        Setattr(p2, "lname", name);
      }

      Swig_typemap_attach_parms("cxxin", p, NULL);

      for (; p; p = Getattr(p, "tmap:in:next")) {
        if (Checkattr(p, "tmap:in:numinputs", "0"))
          continue;

        String *const name = Getattr(p, "lname");

        CxxPTypeDesc ptype_desc;
        if (!cxx_wrappers_.lookup_cxx_parm_type(ptype_desc, n, p))
          return;

        parms_cxx = ParmList_join(parms_cxx.release(), NewParm(ptype_desc.type(), name, p));

        if (Len(parms_call))
          Append(parms_call, ", ");
        Append(parms_call, ptype_desc.get_param_code(name));
      }
    }

    // Avoid checking for exceptions unnecessarily. Note that this is more than an optimization: we'd get into infinite recursion if we checked for exceptions
    // thrown by members of SWIG_CException itself if we didn't do it.
    if (cxx_wrappers_.is_exception_support_enabled() && !Checkattr(n, "noexcept", "true") && (!Checkattr(n, "throw", "1") || Getattr(n, "throws"))) {
      except_check_start = cxx_wrappers_.except_check_start;
      except_check_end = cxx_wrappers_.except_check_end;
    }

    // Everything is fine, so set func_node to indicate success.
    func_node = n;
  }

  bool can_wrap() const {
    return func_node != NULL;
  }

  // Emit just the function body, including the braces around it.
  //
  // This helper is used both by our emit() and emit_member_function().
  void emit_body(String *wparms) {
    String *const wname = Getattr(func_node, "wrap:name");

    Append(cxx_wrappers_.sect_impls, "{");

    if (rtype_desc.is_void()) {
      Printv(cxx_wrappers_.sect_impls, " ", wname, "(", wparms, "); ", NIL);

      if (*except_check_start != '\0') {
        Printv(cxx_wrappers_.sect_impls, except_check_start, except_check_end, "; ", NIL);
      }
    } else {
      rtype_desc.set_return_value(NewStringf("%s%s(%s)%s", except_check_start, wname, wparms, except_check_end));
      Append(cxx_wrappers_.sect_impls, rtype_desc.get_return_code());
    }

    Append(cxx_wrappers_.sect_impls, "}\n");
  }

  // Do emit the function wrapper.
  void emit() {
    // The wrapper function name should be sym:name, but the sym:name of a global variable accessor is the name of its C
    // wrapper, with the namespace prefix, if any, added by our own globalvariableHandler(). So use the name of the
    // variable saved there instead, if available. This is definitely clumsy and it would be better to avoid it, but this
    // would probably need to be done by separating C and C++ wrapper generation in two different passes and so would
    // require significantly more changes than this hack.
    String *name = Getattr(func_node, "c:globalvariableHandler:sym:name");
    if (!name)
      name = Getattr(func_node, "sym:name");

    Printv(cxx_wrappers_.sect_impls, "inline ", get_decl(name, parms_cxx).get(), " ", NIL);

    emit_body(parms_call);
  }

  // Return the declaration of the wrapper with the given name, which may be qualified by the class name, and parameters, which are parms_cxx or none, as a
  // const member function if is_const is true. A constructor has no return type, nor does a conversion operator, which is_conversion is true for.
  ScopedPtr get_decl(String *name, ParmList *parms, bool is_const = false, bool is_conversion = false) const {
    SwigType *const return_type = is_conversion || Checkattr(func_node, "nodeType", "constructor") ? NULL : rtype_desc.type();
    return get_func_decl(return_type, name, parms, is_const);
  }

  CxxWrappers &cxx_wrappers_;
  Node *func_node;
  CxxRTypeDesc rtype_desc;
  // The parameters of the wrapper, with the C++ types given by the typemaps.
  ScopedPtr parms_cxx;
  ScopedPtr parms_call;
  const char *except_check_start;
  const char *except_check_end;

private:
  // Non copyable.
  CxxFunctionWrapper(const CxxFunctionWrapper &);
  CxxFunctionWrapper &operator=(const CxxFunctionWrapper &);
};

/*
  Return true if the class, or one of its base classes, uses multiple inheritance, i.e. has more than one base class.

  The output first_base parameter is optional and is filled with the first base class (if any).
*/
bool uses_multiple_inheritance(Node *n, ScopedPtr *first_base_out = NULL) {
  if (first_base_out)
    first_base_out->reset();

  List *const baselist = Getattr(n, "bases");
  if (!baselist)
    return false;

  ScopedPtr first_base;
  for (Iterator i = First(baselist); i.item; i = Next(i)) {
    if (Checkattr(i.item, "feature:ignore", "1"))
      continue;

    if (first_base)
      return true;

    if (uses_multiple_inheritance(i.item))
      return true;

    first_base = Copy(i.item);
  }

  if (first_base_out)
    *first_base_out = first_base;

  return false;
}

/*
  CxxClassWrapper

  Outputs the declaration of the class wrapping the given one if we're generating C++ wrappers, i.e. if the provided CxxWrappers object is initialized.
*/
class CxxClassWrapper {
public:
  // If the provided CxxWrappers object is not initialized, this class doesn't do anything.
  //
  // The node pointer must be valid, point to a class and remain valid for the lifetime of this object.
  CxxClassWrapper(CxxWrappers &cxx_wrappers, Node *n) : cxx_wrappers_(cxx_wrappers) {
    class_node_ = NULL;

    if (!cxx_wrappers_.is_initialized())
      return;

    if (Checkattr(n, "feature:cxxignore", "1"))
      return;

    String *const classname = Getattr(n, "sym:name");

    ScopedPtr base_classes = adopt(NewStringEmpty());
    if (uses_multiple_inheritance(n, &first_base_)) {
      Swig_warning(WARN_C_UNSUPPORTTED, Getfile(n), Getline(n), "Multiple inheritance not supported yet, skipping C++ wrapper generation for %s\n", classname);

      // Return before initializing class_node_, so that the dtor won't output anything neither.
      return;
    }

    if (first_base_)
      Printv(base_classes, " : public ", Getattr(first_base_, "sym:name"), NIL);

    Printv(cxx_wrappers_.sect_types, "class ", classname, ";\n", NIL);

    Printv(cxx_wrappers_.sect_decls,
           "class ",
           classname,
           base_classes.get(),
           " {\n"
           "public:",
           NIL);

    // If we have any extra code, inject it. Note that we need a hack with an artificial extra node to use Swig_typemap_lookup(), as it needs a "type" attribute
    // which the class node doesn't have.
    ScopedPtr dummy = adopt(NewHash());
    Setattr(dummy, "type", Getattr(n, "name"));
    Setfile(dummy, Getfile(n));
    Setline(dummy, Getline(n));
    ScopedPtr cxxcode = adopt(Swig_typemap_lookup("cxxcode", dummy, "", NULL));
    if (!cxxcode || *Char(cxxcode) != '\n')
      Append(cxx_wrappers_.sect_decls, "\n");
    if (cxxcode) {
      Replaceall(cxxcode, "$cxxclassname", classname);
      Replaceall(cxxcode, "$cclassptrname", get_c_class_ptr(n));
      Append(cxx_wrappers_.sect_decls, cxxcode);
    }

    class_node_ = n;
    dtor_wname_ = NULL;
    has_copy_ctor_ = false;
    conversion_decls_ = NewHash();
  }

  // Get indentation used inside this class declaration.
  const char *get_indent() const {
    // Currently we always use a single level of indent, but this would need to change if/when nested classes are supported.
    //
    // As the first step, we should probably change all occurrences of "cindent" in this class itself to use get_indent() instead.
    return cindent;
  }

  // Emit wrapper of a member function.
  void emit_member_function(Node *n) {
    if (!class_node_)
      return;

    // We don't need to redeclare functions inherited from the base class, as we use real inheritance.
    if (Getattr(n, "c:inherited_from"))
      return;

    // And we even don't need to redeclare virtual functions actually overridden in the derived class, as their implementation is the same as in the base class
    // anyhow, so don't bother generating needless extra code.
    if (Getattr(n, "override"))
      return;

    // Also ignore friend function declarations: they appear inside the class, but we shouldn't generate any wrappers for them.
    if (Checkattr(n, "storage", "friend"))
      return;

    // As mentioned elsewhere, we can't use Swig_storage_isstatic() here because the "storage" attribute is temporarily saved in another view when this
    // function is being executed, so rely on another attribute to determine if it's a static function instead.
    const bool is_member = Checkattr(n, "ismember", "1");
    const bool is_static = is_member && Getattr(n, "cplus:staticbase");
    const bool is_ctor = Checkattr(n, "nodeType", "constructor");

    Parm *p = Getattr(n, "parms");
    if (p && is_member && !is_ctor && !is_static) {
      // We should have "this" as the first parameter and we need to just skip it, as we handle it specially in C++ wrappers.
      if (Checkattr(p, "name", "self")) {
        p = nextSibling(p);
      } else {
        // This is not supposed to happen, so warn if it does.
        Swig_warning(WARN_C_UNSUPPORTTED, Getfile(n), Getline(n), "Unexpected first parameter \"%s\" in %s\n", Getattr(p, "name"), Getattr(n, "sym:name"));
      }
    }

    CxxFunctionWrapper func_wrapper(cxx_wrappers_, n, p);
    if (!func_wrapper.can_wrap())
      return;

    // Define aliases for the stuff actually stored in the function wrapper object.
    CxxRTypeDesc &rtype_desc = func_wrapper.rtype_desc;
    ParmList *const parms_cxx = func_wrapper.parms_cxx;
    String *const parms_call = func_wrapper.parms_call;

    // For some reason overloaded functions use fully-qualified name, so we can't just use the name directly.
    ScopedPtr name_ptr = adopt(Swig_scopename_last(Getattr(n, "name")));
    String *name = name_ptr;
    ScopedPtr conversion_name;
    if (Getattr(n, "template") && !is_ctor) {
      // A member function template instance has the name given by %template, as for the C function, as a C++ name such as 'f<(int)>' cannot be declared.
      name = get_member_symname(n);
    } else if (GetFlag(n, "conversion_operator")) {
      conversion_name = get_conversion_name(n, rtype_desc.type());
      name = conversion_name ? conversion_name.get() : get_member_symname(n);
    } else if (!is_operator(name)) {
      // A member function or variable has the name given by %rename, as for the C function, while an operator, which is wrapped
      // only when it is renamed, keeps its C++ name. A constructor or a destructor has no such name.
      if (String *const symname = get_member_symname(n))
        name = symname;
    }
    String *const wname = Getattr(n, "wrap:name");

    String *const classname = Getattr(class_node_, "sym:name");

    // The name of the member in its definition outside the class.
    ScopedPtr impl_name = adopt(NewStringf("%s::%s", classname, is_ctor ? classname : name));

    if (Checkattr(n, "kind", "variable")) {
      // A getter has no parameters, as it gets the member variable of swig_self() or the static member variable.
      if (Checkattr(n, "memberget", "1")) {
        Printv(cxx_wrappers_.sect_decls, cindent, func_wrapper.get_decl(name, NULL, true).get(), ";\n", NIL);

        rtype_desc.set_return_value(NewStringf("%s(swig_self())", Getattr(n, "sym:name")));
        Printv(cxx_wrappers_.sect_impls,
               "inline ",
               func_wrapper.get_decl(impl_name, NULL, true).get(),
               " "
               "{",
               rtype_desc.get_return_code().get(),
               "}\n",
               NIL);
      } else if (Checkattr(n, "memberset", "1")) {
        Printv(cxx_wrappers_.sect_decls, cindent, func_wrapper.get_decl(name, parms_cxx).get(), ";\n", NIL);

        Printv(cxx_wrappers_.sect_impls,
               "inline ",
               func_wrapper.get_decl(impl_name, parms_cxx).get(),
               " "
               "{ ",
               Getattr(n, "sym:name"),
               "(swig_self(), ",
               parms_call,
               "); }\n",
               NIL);
      } else if (Checkattr(n, "varget", "1")) {
        Printv(cxx_wrappers_.sect_decls, cindent, "static ", func_wrapper.get_decl(name, NULL).get(), ";\n", NIL);

        rtype_desc.set_return_value(NewStringf("%s()", Getattr(n, "sym:name")));
        Printv(cxx_wrappers_.sect_impls,
               "inline ",
               func_wrapper.get_decl(impl_name, NULL).get(),
               " "
               "{",
               rtype_desc.get_return_code().get(),
               "}\n",
               NIL);
      } else if (Checkattr(n, "varset", "1")) {
        Printv(cxx_wrappers_.sect_decls, cindent, "static ", func_wrapper.get_decl(name, parms_cxx).get(), ";\n", NIL);

        Printv(cxx_wrappers_.sect_impls,
               "inline ",
               func_wrapper.get_decl(impl_name, parms_cxx).get(),
               " "
               "{ ",
               Getattr(n, "sym:name"),
               "(",
               parms_call,
               "); }\n",
               NIL);
      } else {
        Swig_warning(WARN_C_UNSUPPORTTED, Getfile(n), Getline(n), "Not generating C++ wrappers for variable %s\n", Getattr(n, "sym:name"));
      }
    } else if (is_ctor) {
      // Delegate to the ctor from opaque C pointer taking ownership of the object.
      Printv(cxx_wrappers_.sect_decls, cindent, func_wrapper.get_decl(classname, parms_cxx).get(), ";\n", NIL);

      Printv(cxx_wrappers_.sect_impls,
             "inline ",
             func_wrapper.get_decl(impl_name, parms_cxx).get(),
             " : ",
             classname,
             "{",
             func_wrapper.except_check_start,
             wname,
             "(",
             parms_call,
             ")",
             func_wrapper.except_check_end,
             "} {}\n",
             NIL);

      // Remember that we had a copy ctor.
      if (Checkattr(n, "copy_constructor", "1"))
        has_copy_ctor_ = true;
    } else if (Checkattr(n, "nodeType", "destructor")) {
      if (first_base_) {
        // Delete the pointer and reset the ownership flag to ensure that the base class doesn't do it again.
        Printv(cxx_wrappers_.sect_decls,
               cindent,
               get_virtual_prefix(n),
               "~",
               classname,
               "() {\n",
               cindent,
               cindent,
               "if (swig_owns_self_) {\n",
               cindent,
               cindent,
               cindent,
               wname,
               "(swig_self());\n",
               cindent,
               cindent,
               cindent,
               "swig_owns_self_ = false;\n",
               cindent,
               cindent,
               "}\n",
               cindent,
               "}\n",
               NIL);
      } else {
        // Slightly simplified version for classes without base classes, as we don't need to reset swig_self_ then.
        Printv(cxx_wrappers_.sect_decls,
               cindent,
               get_virtual_prefix(n),
               "~",
               classname,
               "() {\n",
               cindent,
               cindent,
               "if (swig_owns_self_)\n",
               cindent,
               cindent,
               cindent,
               wname,
               "(swig_self_);\n",
               cindent,
               "}\n",
               NIL);

        // We're also going to need this in move assignment operator.
        dtor_wname_ = wname;
      }
    } else if (is_member) {
      // Wrapper parameters list may or not include "this" pointer and may or not have other parameters, so construct it piecewise for simplicity.
      ScopedPtr wparms = adopt(NewStringEmpty());
      if (!is_static)
        Append(wparms, "swig_self()");
      if (Len(parms_call)) {
        if (Len(wparms))
          Append(wparms, ", ");
        Append(wparms, parms_call);
      }

      bool const is_conversion = conversion_name.get() != NULL;
      Printv(cxx_wrappers_.sect_decls,
             cindent,
             is_static ? "static " : get_virtual_prefix(n),
             is_conversion && Checkattr(n, "storage", "explicit") ? "explicit " : "",
             func_wrapper.get_decl(name, parms_cxx, is_const(n), is_conversion).get(),
             ";\n",
             NIL);

      Printv(cxx_wrappers_.sect_impls, "inline ", func_wrapper.get_decl(impl_name, parms_cxx, is_const(n), is_conversion).get(), " ", NIL);

      func_wrapper.emit_body(wparms);
    } else {
      // This is something we don't know about
      Swig_warning(WARN_C_UNSUPPORTTED, Getfile(n), Getline(n), "Not generating C++ wrappers for %s\n", Getattr(n, "sym:name"));
    }
  }

  ~CxxClassWrapper() {
    // Don't do anything if generation of the wrapper for this class was disabled in ctor.
    if (!class_node_)
      return;

    // This is the name used for the class pointers in C wrappers.
    ScopedPtr c_class_ptr = get_c_class_ptr(class_node_);

    String *const classname = Getattr(class_node_, "sym:name");

    // We need to generate a ctor from the C object pointer, which is required to be able to create objects of this class from pointers created by C wrappers
    // and also by any derived classes.
    Printv(cxx_wrappers_.sect_decls,
           "\n",
           cindent,
           "explicit ",
           classname,
           "(",
           c_class_ptr.get(),
           " swig_self, "
           "bool swig_owns_self = true) noexcept : ",
           NIL);

    if (first_base_) {
      // In this case we delegate to the base class ctor, but need a cast because it expects a different pointer type (as these types are opaque, there is no
      // relationship between them).
      Printv(cxx_wrappers_.sect_decls, Getattr(first_base_, "sym:name"), "{(", get_c_class_ptr(first_base_).get(), ")swig_self, swig_owns_self}", NIL);
    } else {
      // Just initialize our own field.
      Printv(cxx_wrappers_.sect_decls, "swig_self_{swig_self}, swig_owns_self_{swig_owns_self}", NIL);
    }

    Append(cxx_wrappers_.sect_decls, " {}\n");

    // If the class doesn't have a copy ctor, forbid copying it: we currently must do it even if the original class has a perfectly cromulent implicit copy ctor
    // because we don't wrap it and copying would use the trivial ctor that would just copy the swig_self_ pointer resulting in double destruction of it later.
    // To fix this, we would need to always provide our own C wrapper for the copy ctor, which is not something we do currently.
    if (!has_copy_ctor_) {
      Printv(cxx_wrappers_.sect_decls, cindent, classname, "(", classname, " const&) = delete;\n", NIL);
    }

    // We currently never wrap the assignment operator, so we have to always disable it for the same reason we disable the copy ctor above.
    // It would definitely be nice to provide the assignment, if possible.
    Printv(cxx_wrappers_.sect_decls, cindent, classname, "& operator=(", classname, " const&) = delete;\n", NIL);

    // OTOH we may always provide move ctor and assignment, as we can always implement them trivially ourselves.
    if (first_base_) {
      Printv(cxx_wrappers_.sect_decls,
             cindent,
             classname,
             "(",
             classname,
             "&& obj) = default;\n",
             cindent,
             classname,
             "& operator=(",
             classname,
             "&& obj) = default;\n",
             NIL);
    } else {
      Printv(cxx_wrappers_.sect_decls,
             cindent,
             classname,
             "(",
             classname,
             "&& obj) noexcept : "
             "swig_self_{obj.swig_self_}, swig_owns_self_{obj.swig_owns_self_} { "
             "obj.swig_owns_self_ = false; "
             "}\n",
             cindent,
             classname,
             "& operator=(",
             classname,
             "&& obj) noexcept {\n",
             NIL);

      if (dtor_wname_) {
        Printv(cxx_wrappers_.sect_decls, cindent, cindent, "if (swig_owns_self_)\n", cindent, cindent, cindent, dtor_wname_, "(swig_self_);\n", NIL);
      }

      Printv(cxx_wrappers_.sect_decls,
             cindent,
             cindent,
             "swig_self_ = obj.swig_self_;\n",
             cindent,
             cindent,
             "swig_owns_self_ = obj.swig_owns_self_;\n",
             cindent,
             cindent,
             "obj.swig_owns_self_ = false;\n",
             cindent,
             cindent,
             "return *this;\n",
             cindent,
             "}\n",
             NIL);
    }

    // We also need a swig_self() method for accessing the C object pointer.
    Printv(cxx_wrappers_.sect_decls, cindent, c_class_ptr.get(), " swig_self() const noexcept ", NIL);

    if (first_base_) {
      // If we have a base class, we reuse its existing "self" pointer.
      Printv(cxx_wrappers_.sect_decls, "{ return (", c_class_ptr.get(), ")", Getattr(first_base_, "sym:name"), "::swig_self(); }\n", NIL);
    } else {
      // We use our own pointer, which we also have to declare, together with the ownership flag.
      //
      // Perhaps we could avoid having a separate bool flag by reusing the low-order bit of the pointer itself as the indicator of ownership and masking it when
      // retrieving it here in the future. If we decide to implement this optimization, the code generated here should be the only thing that would need to
      // change.
      Printv(cxx_wrappers_.sect_decls, "{ return swig_self_; }\n", cindent, c_class_ptr.get(), " swig_self_;\n", cindent, "bool swig_owns_self_;\n", NIL);
    }

    Printv(cxx_wrappers_.sect_decls,
           "};\n"
           "\n",
           NIL);
  }

private:
  // Various helpers.

  // Return the string containing the pointer type used for representing the objects of the given class in the C wrappers.
  //
  // Returned value includes "*" at the end.
  static ScopedPtr get_c_class_ptr(Node *class_node) {
    return ScopedPtr(NewStringf("SwigObj_%s*", get_c_proxy_name(class_node)));
  }

  // Return the sym:name of the member function or variable n without the class prefix of the name of its C function, or NULL for any other member.
  static String *get_member_symname(Node *n) {
    String *symname = Getattr(n, "memberfunctionHandler:sym:name");
    if (!symname)
      symname = Getattr(n, "staticmemberfunctionHandler:sym:name");
    if (!symname)
      symname = Getattr(n, "membervariableHandler:sym:name");
    if (!symname)
      symname = Getattr(n, "staticmembervariableHandler:sym:name");
    return symname;
  }

  // Return true if name is the name of an operator, such as 'operator +'.
  static bool is_operator(String *name) {
    return Strncmp(name, "operator ", 9) == 0;
  }

  // Return the name of the C++ wrapper of the conversion operator n, which converts to the type cxx_type that the C++ wrapper returns, as in 'operator Foo'
  // for 'operator Foo &()', or NULL if a conversion operator cannot name this type, as for a function pointer, or if another one already converts to it.
  ScopedPtr get_conversion_name(Node *n, SwigType *cxx_type) {
    if (is_ptr_to_func_or_array(cxx_type))
      return ScopedPtr();

    ScopedPtr cxx_type_str = adopt(SwigType_str(cxx_type, 0));
    ScopedPtr conversion_name = adopt(NewStringf("operator %s", cxx_type_str.get()));
    // Two conversion operators to the same type can differ in their const qualifier.
    ScopedPtr conversion_decl = adopt(NewStringf("%s%s", conversion_name.get(), is_const(n) ? " const" : ""));
    if (Getattr(conversion_decls_, conversion_decl))
      return ScopedPtr();

    Setattr(conversion_decls_, conversion_decl, "1");
    return conversion_name;
  }

  // Return "virtual " if this is a virtual function, empty string otherwise.
  static const char *get_virtual_prefix(Node *n) {
    return Checkattr(n, "storage", "virtual") ? "virtual " : "";
  }

  // Return true for a const or const volatile function, which may also be ref-qualified. The C++ wrapper itself is never
  // volatile, as the swig_self() function it calls is not.
  static bool is_const(Node *n) {
    return SwigType_isconst(Getattr(n, "qualifier"));
  }

  CxxWrappers &cxx_wrappers_;

  // The class node itself, left null only if we skip generating wrappers for it for whatever reason.
  Node *class_node_;

  // We currently don't support generating C++ wrappers for classes using multiple inheritance. This could be implemented, with some tweaks to allow
  // initializing the other base classes after creating the most-derived object, but hasn't been done yet. Until then we store just the first base class (if
  // any, this member can also be null).
  ScopedPtr first_base_;

  // Name of the C function used for deleting the owned object, if any.
  String *dtor_wname_;

  // True if the class defines an explicit copy ctor.
  bool has_copy_ctor_;

  // The declarations of the conversion operators of the C++ wrapper, such as 'operator Foo const', see get_conversion_name().
  ScopedPtr conversion_decls_;

  // Non copyable.
  CxxClassWrapper(const CxxClassWrapper &);
  CxxClassWrapper &operator=(const CxxClassWrapper &);
};

}  // anonymous namespace

class C : public Language {
  static const char *usage;

  // These files contain types used by the wrappers declarations and the declarations themselves and end up in the output header file.
  String *sect_wrappers_types;
  String *sect_wrappers_decl;

  // The structs and unions declared in sect_wrappers_types when wrapping C code because SWIG has not seen them.
  ScopedPtr forward_declared_types_;

  // The opaque types declared in sect_wrappers_types, see getOpaqueTypeName(), as C before C11 does not allow a typedef to be repeated.
  ScopedPtr opaque_types_;

  // The structs holding the bytes of a pointer to member defined in sect_wrappers, see getMemberPointerStruct().
  ScopedPtr member_pointer_structs_;

  // This one contains wrapper functions definitions and end up in the output C++ file.
  String *sect_wrappers;

  String *empty_string;

  // Namespace used for the C++ wrappers, set from -namespace command-line option if specified or from the module name otherwise.
  String *ns_cxx;

  // Prefix used for all symbols, if non-null. If ns_cxx was specified, it is a mangled version of it.
  String *ns_prefix;

  // Name of the module, used as a prefix for module-level symbols if ns_prefix is null.
  String *module_name;

  // Name of the output header, set in top().
  String *outfile_h;

  // Used only while generating wrappers for an enum and contains the prefix, ending with underscore, to use for enum elements or is empty.
  ScopedPtr enum_prefix_;

  // Used only while generating wrappers for an enum, as we don't know if enum will have any elements or not in advance and we must not generate an empty enum,
  // so we accumulate the full declaration here and then write it to sect_wrappers_types at once only if there are any elements.
  String *enum_decl;

  // Selects between the wrappers (public) declarations and (private) definitions.
  enum { output_wrapper_decl, output_wrapper_def } current_output;

  // Selects between various kinds of needed support for exception-related code.
  exceptions_support exceptions_support_;

  // This object contains information necessary only for C++ wrappers generation, use its is_initialized() to check if this is being done.
  CxxWrappers cxx_wrappers_;

  // Non-owning pointer to the current C++ class wrapper if we're currently generating one or NULL.
  CxxClassWrapper *cxx_class_wrapper_;

  // This is parallel to enum_prefix_ but for C++ enum elements.
  ScopedPtr cxx_enum_prefix_;

  // This is parallel to enum_decl but for C++ enum declaration.
  String *cxx_enum_decl;

  // An extra indent level needed for nested C++ enums.
  const char *cxx_enum_indent;

public:
  /* -----------------------------------------------------------------------------
   * C()
   * ----------------------------------------------------------------------------- */

  C() : empty_string(NewString("")), ns_cxx(NULL), ns_prefix(NULL), module_name(NULL), outfile_h(NULL), cxx_class_wrapper_(NULL) {
    UseWrapperSuffix = 1;
  }

  ~C() {
    Delete(ns_cxx);
    Delete(ns_prefix);
  }

  // Return true if the sym:name of the node is used as the name of its wrapper function without adding a prefix.
  //
  // The basic idea here is that for class members we don't need to use any prefix at all, as they're already prefixed by the class name, which has the
  // appropriate prefix, but we need to use a prefix for the other symbols.
  //
  // However there are a couple of special cases complicating this:
  //
  //  - Friend functions are declared inside the class, but are not member functions, so we have to check for both the current class and "ismember" property.
  //  - Destructors and implicitly generated constructors don't have "ismember" for some reason, so we need to check for them specifically.
  //  - Variable getters and setters don't need to use the prefix as they don't clash with anything.
  bool isSymNameWrapperName(Node *n) const {
    return (getCurrentClass() && (Checkattr(n, "ismember", "1") || Checkattr(n, "nodeType", "constructor") || Checkattr(n, "nodeType", "destructor"))) ||
           Checkattr(n, "varget", "1") || Checkattr(n, "varset", "1");
  }

  // Construct the name to be used for a function with the given name in C wrappers.
  MaybeOwnedPtr getFunctionWrapperName(Node *n, String *name) const {
    MaybeOwnedPtr wname;

    if (isSymNameWrapperName(n)) {
      wname.assign_non_owned(name);
      return wname;
    }

    // Use namespace as the prefix if feature:nspace is in use.
    ScopedPtr scopename_prefix;
    if (GetFlag(parentNode(n), "feature:nspace")) {
      scopename_prefix = Swig_scopename_prefix(Getattr(n, "name"));
      if (scopename_prefix) {
        ScopedPtr mangled_prefix = adopt(Swig_name_mangle_string(scopename_prefix));
        scopename_prefix = mangled_prefix;
      }
    }

    // Fall back to the module name if we don't use feature:nspace and don't have the global prefix neither.
    //
    // Note that we really, really need to use some prefix, as wrapper function can't have the same name as the original function being wrapped.
    String *const prefix = scopename_prefix ? scopename_prefix : ns_prefix ? ns_prefix : module_name;

    wname.assign_owned(NewStringf("%s_%s", prefix, name));
    return wname;
  }

  // Return the sym:name of the node as the other target languages have it, for the $symname special variable.
  //
  // The -namespace option puts its prefix in the sym:name of the nodes that use it as their wrapper name. The naming
  // formats registered in main() do so for a class member, constructor or destructor, such as 'ns_Klass_method'.
  // globalvariableHandler() does so for a global variable, giving 'ns_gvar_get' for its getter. So remove the prefix.
  String *getSymName(Node *n) const {
    String *const symname = Getattr(n, "sym:name");
    if (ns_prefix && isSymNameWrapperName(n)) {
      int const prefix_len = Len(ns_prefix);
      if (Strncmp(symname, ns_prefix, prefix_len) == 0 && Char(symname)[prefix_len] == '_')
        return NewString(Char(symname) + prefix_len + 1);
    }
    return Copy(symname);
  }

  /* -----------------------------------------------------------------------------
   * getClassProxyName()
   *
   * Test to see if a type corresponds to something wrapped with a proxy class.
   * Return NULL if not, otherwise the proxy class name.
   * ----------------------------------------------------------------------------- */

  String *getClassProxyName(SwigType *t) {
    Node *n = classLookup(t);

    return n ? Copy(get_c_proxy_name(n)) : NULL;
  }

  /* -----------------------------------------------------------------------------
   * getEnumName()
   *
   * Return the name to use for the enum in the generated code.
   * Also caches it in the node for subsequent access.
   * Returns NULL if the node doesn't correspond to an enum.
   * ----------------------------------------------------------------------------- */

  String *getEnumName(Node *n) {
    String *enumname = Getattr(n, "enumname");
    if (!enumname) {
      // We can't use forward-declared enums because we can't define them for C wrappers (we could forward declare them in C++ if their underlying type,
      // available as "inherit" node attribute, is specified, but not in C), so we have no choice but to use "int" for them.
      if (Checkattr(n, "sym:weak", "1"))
        return NULL;

      String *symname = Getattr(n, "sym:name");
      if (symname) {
        // Add in class scope when referencing enum if not a global enum
        String *proxyname = 0;
        if (String *name = Getattr(n, "name")) {
          if (String *scopename_prefix = Swig_scopename_prefix(name)) {
            proxyname = getClassProxyName(scopename_prefix);
            Delete(scopename_prefix);
          }
        }
        if (proxyname) {
          enumname = NewStringf("%s_%s", proxyname, symname);
          Delete(proxyname);
        } else {
          // global enum or enum in a namespace
          enumname = Copy(get_c_proxy_name(n));
        }
        Setattr(n, "enumname", enumname);
        Delete(enumname);
      }
    }

    return enumname;
  }

  /* -----------------------------------------------------------------------------
   * getEnumCType()
   *
   * Return the C type of the enum type enumtype.
   * ----------------------------------------------------------------------------- */

  String *getEnumCType(SwigType *enumtype) {
    Node *const enum_node = enumLookup(enumtype);
    String *const enumname = enum_node ? getEnumName(enum_node) : NULL;

    // We use the enum name in the wrapper declaration if it's available, as this makes it more type safe, but we always use just int for the function
    // definition because we don't have the enum declaration in scope there. This obviously only actually works if the actual enum underlying type is int (or
    // smaller).
    if (current_output == output_wrapper_decl && enumname) {
      // We need to add "enum" iff this is not already a typedef for the enum.
      if (Checkattr(enum_node, "allows_typedef", "1"))
        return Copy(enumname);
      return NewStringf("enum %s", enumname);
    }
    return NewString("int");
  }

  /* -----------------------------------------------------------------------------
   * getOpaqueTypeName()
   *
   * Return the name of the opaque struct used in the header file for the type, which SWIG does not wrap, as in
   * 'SWIGTYPE_p_Foo' for 'Foo *', and declare it in the header file, unless it is already declared. The header file of a
   * module importing another one includes the header file of the other one, which may declare the same type, so the
   * declaration is guarded.
   * ----------------------------------------------------------------------------- */

  String *getOpaqueTypeName(SwigType *type) {
    ScopedPtr mangled_type = adopt(SwigType_manglestr(type));
    String *const typestr = NewStringf("SWIGTYPE%s", mangled_type.get());
    if (!Getattr(opaque_types_, typestr)) {
      Printf(sect_wrappers_types, "#ifndef %s_DEFINED\n#define %s_DEFINED\ntypedef struct %s %s;\n#endif\n\n", typestr, typestr, typestr, typestr);
      // The key is a copy of typestr, which the caller may change, as replaceBaseTypes() does
      Setattr(opaque_types_, Char(typestr), "1");
    }
    return typestr;
  }

  /* -----------------------------------------------------------------------------
   * getMemberPointerStruct()
   *
   * Return the name of the struct holding the bytes of a pointer to member of the given type, see
   * get_member_pointer_struct_name(), and define it, unless it is already defined, in the header file or in the wrapper
   * file, depending on current_output. Its array of 4 pointers has the alignment of a pointer to member in the common
   * ABIs, which has at most a pointer and three ints, so it is large enough for one. The wrappers check that it is.
   * The header file of a module importing another one includes the header file of the other one, which may define the
   * same struct, so the definition is guarded there.
   * ----------------------------------------------------------------------------- */

  String *getMemberPointerStruct(SwigType *type) {
    String *const struct_name = get_member_pointer_struct_name(type);
    bool const is_decl = current_output == output_wrapper_decl;
    Hash *const defined_structs = is_decl ? opaque_types_ : member_pointer_structs_;
    if (!Getattr(defined_structs, struct_name)) {
      String *const out = is_decl ? sect_wrappers_types : sect_wrappers;
      if (is_decl)
        Printf(out, "#ifndef %s_DEFINED\n#define %s_DEFINED\n", struct_name, struct_name);
      Printf(out, "typedef struct %s {\n%svoid *swig_data[4];\n} %s;\n", struct_name, cindent, struct_name);
      if (is_decl)
        Printf(out, "#endif\n");
      Printf(out, "\n");
      Setattr(defined_structs, Char(struct_name), "1");
    }
    return struct_name;
  }

  /* -----------------------------------------------------------------------------
   * replaceBaseTypes()
   *
   * Return a copy of type with its base type and the base types of the parameters of any function in it, as in a
   * function pointer, replaced by the type that new_base_type() returns for each of them.
   * ----------------------------------------------------------------------------- */

  SwigType *replaceBaseTypes(SwigType *type, SwigType *(C::*new_base_type)(SwigType *base)) {
    ScopedPtr elements = adopt(SwigType_split(type));
    int const last = Len(elements) - 1;
    SwigType *const result = (this->*new_base_type)(Getitem(elements, last));

    for (int i = last - 1; i >= 0; i--) {
      SwigType *const element = Getitem(elements, i);
      if (SwigType_isfunction(element)) {
        ParmList *const parms = SwigType_function_parms(element, NULL);
        for (Parm *p = parms; p; p = nextSibling(p)) {
          ScopedPtr parm_type = adopt(replaceBaseTypes(Getattr(p, "type"), new_base_type));
          Setattr(p, "type", parm_type);
        }
        SwigType_add_function(result, parms);
        Delete(parms);
      } else {
        SwigType_push(result, element);
      }
    }
    return result;
  }

  /* -----------------------------------------------------------------------------
   * getCNameBaseType()
   *
   * Return the C name of the class or enum base type, see getCNamesType(), or a copy of any other base type.
   * ----------------------------------------------------------------------------- */

  SwigType *getCNameBaseType(SwigType *base) {
    SwigType *c_name = SwigType_isenum(base) ? getEnumCType(base) : getClassProxyName(base);
    if (!c_name && SwigType_isclass(base)) {
      // A class that is not wrapped is the opaque struct that a pointer to it points to elsewhere in the header file, as
      // in 'SWIGTYPE_p_Foo *' for a 'Foo *' parameter
      ScopedPtr ptr_type = adopt(SwigType_add_pointer(Copy(base)));
      c_name = getOpaqueTypeName(ptr_type);
    }
    return c_name ? c_name : Copy(base);
  }

  /* -----------------------------------------------------------------------------
   * getCNamesType()
   *
   * Return the type, whose typedefs are resolved, with the C names of the classes and enums in its base type and in
   * the parameters of any function in it, as in a function pointer, as their C++ names are not valid in C.
   * ----------------------------------------------------------------------------- */

  SwigType *getCNamesType(SwigType *type) {
    return replaceBaseTypes(type, &C::getCNameBaseType);
  }

  /* -----------------------------------------------------------------------------
   * substituteResolvedTypeSpecialVariable()
   *
   * Return true if tm is replaced with a SwigType rather than with C type text, see substituteResolvedType().
   * ----------------------------------------------------------------------------- */

  bool substituteResolvedTypeSpecialVariable(SwigType *classnametype, String *tm, const char *classnamespecialvariable, Node *file_line_node) {
    // A pointer to member, or a const reference to one, is passed by value as the struct holding its bytes, see getMemberPointerStruct(). Any other pointer
    // or reference to one, which the 'SWIGTYPE &' typemaps take as a pointer, is an opaque pointer, as for a type that SWIG does not wrap, as in
    // 'SWIGTYPE_p_m_Foo__int *' for 'int Foo::*&'.
    if (CPlusPlus && is_member_pointer_type(classnametype)) {
      ScopedPtr typestr;
      if (SwigType_ismemberpointer(classnametype) && Strcmp(classnamespecialvariable, "$resolved_type") == 0) {
        typestr = getMemberPointerStruct(classnametype);
      } else if (current_output == output_wrapper_def) {
        typestr = NewString("SwigObj");
      } else {
        ScopedPtr ptr_type = adopt(Copy(classnametype));
        if (!SwigType_ispointer(ptr_type))
          SwigType_add_pointer(ptr_type);
        typestr = getOpaqueTypeName(ptr_type);
      }
      Replaceall(tm, classnamespecialvariable, typestr);
      return false;
    }

    // The type of a pointer or reference to a function or an array, or to a pointer to one, cannot be followed by a '*' or a
    // name, so it is given as it is when not using C++, as any other type below, and in the header file for C++, using the C
    // names of the classes and enums in it. This is checked first, as the return type of a function pointer can be an enum.
    if (!CPlusPlus || current_output == output_wrapper_decl) {
      ScopedPtr ctype = adopt(Copy(classnametype));
      // C has no references, so the reference removed by "$*resolved_type" in the 'SWIGTYPE &' typemaps becomes a
      // pointer, as in 'int (*carg1)(int)' for 'int (&)(int)', 'int (*carg1)[4]' for 'int (&)[4]' or
      // 'int (**carg1)(int)' for 'int (*&)(int)'.
      if (CPlusPlus && Strcmp(classnamespecialvariable, "$*resolved_type") == 0) {
        SwigType_add_pointer(ctype);
      }
      if (is_ptr_to_func_or_array(ctype)) {
        if (CPlusPlus) {
          // Each other reference becomes a pointer too, as in 'int *(*carg1)(int const *)' for 'int &(*)(int const &)'
          ctype = references_to_pointers(ctype);
          ctype = getCNamesType(ctype);
        }
        emitBaseTypeFragments(ctype, file_line_node);
        Clear(tm);
        Append(tm, ctype);
        return true;
      }
    }

    // Just use the original C type when not using C++, we know that this type can be used in the wrappers. It keeps its qualifiers, as in
    // 'struct S const *', but an array decays to a pointer, as for a function parameter. An enum has its C name, see getEnumCType().
    if (!CPlusPlus) {
      ScopedPtr ctype = adopt(SwigType_decay_array(classnametype));
      ScopedPtr c_btype = adopt(SwigType_base(ctype));
      if (SwigType_isenum(c_btype)) {
        ScopedPtr c_enumname = adopt(getEnumCType(c_btype));
        ctype = SwigType_prefix(ctype);
        Append(ctype, c_enumname);
      } else if (SwigType_isclasskey(c_btype) && !classLookup(c_btype) && !Getattr(forward_declared_types_, c_btype)) {
        // A struct or union that SWIG has not seen defined, as one only declared in a %{ %} block, is not declared in the header file
        // with the others, but one first named in a parameter list is not visible outside it, so it is declared before it is used.
        Printf(sect_wrappers_types, "%s;\n\n", c_btype.get());
        Setattr(forward_declared_types_, c_btype, "1");
      }
      Clear(tm);
      Append(tm, ctype);
      return true;
    }

    ScopedPtr btype = adopt(SwigType_base(classnametype));
    if (SwigType_isenum(btype)) {
      ScopedPtr c_enumname = adopt(getEnumCType(btype));
      ScopedPtr c_type = adopt(get_special_variable_c_type(classnametype, classnamespecialvariable, c_enumname));
      Replaceall(tm, classnamespecialvariable, c_type);
    } else {
      String *typestr = NIL;
      if (current_output == output_wrapper_def || Cmp(btype, "SwigObj") == 0) {
        // Special case, just leave it unchanged.
        typestr = NewString("SwigObj");
      } else {
        typestr = getClassProxyName(btype);
        if (!typestr && SwigType_isbuiltin(btype)) {
          typestr = Copy(btype);
        }
        if (typestr) {
          String *const c_type = get_special_variable_c_type(classnametype, classnamespecialvariable, typestr);
          Delete(typestr);
          typestr = c_type;
        } else {
          // Swig doesn't know anything about this type, use descriptor for it.
          typestr = getOpaqueTypeName(classnametype);
        }
      }

      Replaceall(tm, classnamespecialvariable, typestr);
      Delete(typestr);
    }
    return false;
  }

  /* -----------------------------------------------------------------------------
   * substituteResolvedType()
   *
   * Substitute the special variable $csclassname with the proxy class name for classes/structs/unions
   * that SWIG knows about. Also substitutes enums with enum name.
   * Otherwise use the $descriptor name for the C# class name. Note that the $&csclassname substitution
   * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - typemap contents that might contain the special variable to be replaced
   *   file_line_node - node whose file and line are used for the typemaps looked up
   * Outputs:
   *   tm - typemap contents complete with the special variable substitution
   * Returns true if tm is replaced with a SwigType, which SwigType_str() outputs with the declarator inside it for a
   * function pointer, rather than with C type text. This is the original C type when wrapping C and the C type of a
   * pointer or reference to a function or an array, or to a pointer to one, in the header file when wrapping C++.
   * ----------------------------------------------------------------------------- */

  bool substituteResolvedType(SwigType *pt, String *tm, Node *file_line_node) {
    SwigType *type = SwigType_typedef_resolve_all(pt);
    // The qualifiers of the return type of a function pointer, or of the elements of an array, are part of its type,
    // but SwigType_strip_qualifiers() would remove them too, so only the top level qualifiers are removed from a
    // pointer or reference to a function or an array or to a pointer to one. The same goes for a pointer to member, as
    // a pointer to a const member function is a different type, which has a different name. When not using C++, only
    // the top level qualifiers are removed from any type, as the original C type is used.
    SwigType *strippedtype = SwigType_remove_qualifier(Copy(type));
    if (CPlusPlus && !is_ptr_to_func_or_array(strippedtype) && !is_member_pointer_type(strippedtype)) {
      Delete(strippedtype);
      strippedtype = SwigType_strip_qualifiers(type);
    }
    bool is_swigtype = false;

    if (Strstr(tm, "$resolved_type")) {
      // A pointer passed by const reference, as in the 'SWIGTYPE *const &' typemap, is passed as the pointer, so it has the type of the pointer
      SwigType *classnametype = SwigType_remove_qualifier_reference(Copy(strippedtype));
      if (substituteResolvedTypeSpecialVariable(classnametype, tm, "$resolved_type", file_line_node))
        is_swigtype = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$*resolved_type")) {
      SwigType *classnametype = Copy(strippedtype);
      Delete(SwigType_pop(classnametype));
      if (Len(classnametype) > 0) {
        if (substituteResolvedTypeSpecialVariable(classnametype, tm, "$*resolved_type", file_line_node))
          is_swigtype = true;
      }
      Delete(classnametype);
    }
    if (Strstr(tm, "$&resolved_type")) {
      SwigType *classnametype = Copy(strippedtype);
      // A C++ object passed or returned by value is a pointer in C, but when not using C++, the original C type of a
      // struct passed or returned by value is used, as the wrapper passes or returns it by value too
      if (CPlusPlus)
        SwigType_add_pointer(classnametype);
      if (substituteResolvedTypeSpecialVariable(classnametype, tm, "$&resolved_type", file_line_node))
        is_swigtype = true;
      Delete(classnametype);
    }

    Delete(strippedtype);
    Delete(type);
    return is_swigtype;
  }

  /*----------------------------------------------------------------------
   * replaceSpecialVariables()
   *
   * Override the base class method to ensure that $resolved_type is expanded correctly inside $typemap().
   *--------------------------------------------------------------------*/

  virtual void replaceSpecialVariables(String *method, String *tm, Parm *parm) {
    // This function is called by Swig_typemap_lookup(), which may be called when generating C or C++ wrappers, so delegate to the latter one if necessary.
    if (cxx_wrappers_.is_initialized() && cxx_wrappers_.replaceSpecialVariables(method, tm, parm))
      return;

    // The typemap that $typemap() expands to is put into the text of another typemap, so it needs C type text
    SwigType *type = Getattr(parm, "type");
    if (substituteResolvedType(type, tm, parm)) {
      ScopedPtr ctype = adopt(SwigType_str(tm, 0));
      Clear(tm);
      Append(tm, ctype);
    }
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {
    bool except_flag = CPlusPlus;
    bool use_cxx_wrappers = CPlusPlus;

    // look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
        if (strcmp(argv[i], "-help") == 0) {
          Printf(stdout, "%s", usage);
        } else if (strcmp(argv[i], "-namespace") == 0) {
          if (argv[i + 1]) {
            ns_cxx = NewString(argv[i + 1]);
            ns_prefix = Swig_name_mangle_string(ns_cxx);
            Swig_mark_arg(i);
            Swig_mark_arg(i + 1);
            i++;
          } else {
            Swig_arg_error();
          }
        } else if (strcmp(argv[i], "-nocxx") == 0) {
          use_cxx_wrappers = false;
          Swig_mark_arg(i);
        } else if (strcmp(argv[i], "-noexcept") == 0) {
          except_flag = false;
          Swig_mark_arg(i);
        }
      }
    }

    // add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGC 1", 0);
    if (except_flag)
      Preprocessor_define("SWIG_C_EXCEPT 1", 0);
    if (CPlusPlus)
      Preprocessor_define("SWIG_CPPMODE 1", 0);
    if (use_cxx_wrappers)
      Preprocessor_define("SWIG_CXX_WRAPPERS 1", 0);

    SWIG_library_directory("c");

    SWIG_config_file("c.swg");

    String *const ns_prefix_ = ns_prefix ? NewStringf("%s_", ns_prefix) : NewString("");

    // The default naming convention is to use new_Foo(), copy_Foo() and delete_Foo() for the default/copy ctor and dtor of the class Foo, but we prefer to
    // start all Foo methods with the same prefix, so change this. Notice that new/delete are chosen to ensure that we avoid conflicts with the existing class
    // methods, more natural create/destroy, for example, could result in errors if the class already had a method with the same name, but this is impossible
    // for the chosen names as they're keywords in C++ ("copy" is still a problem but we'll just have to live with it).
    Swig_name_register("construct", NewStringf("%s%%n%%c_new", ns_prefix_));
    Swig_name_register("copy", NewStringf("%s%%n%%c_copy", ns_prefix_));
    Swig_name_register("destroy", NewStringf("%s%%n%%c_delete", ns_prefix_));

    // These ones are only needed when using a global prefix, as otherwise the defaults are fine.
    if (ns_prefix) {
      Swig_name_register("member", NewStringf("%s%%n%%c_%%m", ns_prefix_));
      Swig_name_register("type", NewStringf("%s%%c", ns_prefix_));
    }

    Delete(ns_prefix_);

    exceptions_support_ = except_flag ? exceptions_support_enabled : exceptions_support_disabled;

    if (use_cxx_wrappers)
      cxx_wrappers_.initialize();

    allow_overloading();
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {
    module_name = Getattr(n, "name");
    String *outfile = Getattr(n, "outfile");

    // initialize I/O
    const ScopedPtr f_wrappers_cxx = adopt(NewFile(outfile, "w", SWIG_output_files()));
    if (!f_wrappers_cxx) {
      FileErrorDisplay(outfile);
      Exit(EXIT_FAILURE);
    }

    Swig_banner(f_wrappers_cxx);

    Swig_obligatory_macros(f_wrappers_cxx, "C");

    // Open the file where all wrapper declarations will be written to in the end.
    outfile_h = Getattr(n, "outfile_h");
    const ScopedPtr f_wrappers_h = adopt(NewFile(outfile_h, "w", SWIG_output_files()));
    if (!f_wrappers_h) {
      FileErrorDisplay(outfile_h);
      Exit(EXIT_FAILURE);
    }

    Swig_banner(f_wrappers_h);

    // Associate file with the SWIG sections with the same name, so that e.g. "%header" contents end up in sect_header etc.
    const ScopedPtr sect_begin = adopt(NewStringEmpty());
    const ScopedPtr sect_header = adopt(NewStringEmpty());
    const ScopedPtr sect_runtime = adopt(NewStringEmpty());
    const ScopedPtr sect_init = adopt(NewStringEmpty());

    // This one is used outside of this function, so it's a member variable rather than a local one.
    sect_wrappers = NewStringEmpty();

    Swig_register_filebyname("begin", sect_begin);
    Swig_register_filebyname("header", sect_header);
    Swig_register_filebyname("wrapper", sect_wrappers);
    Swig_register_filebyname("runtime", sect_runtime);
    Swig_register_filebyname("init", sect_init);

    // This one is C-specific and goes directly to the output header file.
    Swig_register_filebyname("cheader", f_wrappers_h);

    // Deal with exceptions support.
    if (exceptions_support_ == exceptions_support_enabled) {
      // Redefine SWIG_CException_Raise() to have a unique prefix in the shared library built from SWIG-generated sources to allow using more than one extension
      // in the same process without conflicts. This has to be done in this hackish way because we really need to change the name of the function itself, not
      // its wrapper (which is not even generated).
      Printv(sect_runtime, "#define SWIG_CException_Raise ", (ns_prefix ? ns_prefix : module_name), "_SWIG_CException_Raise\n", NIL);

      // We need to check if we have any %imported modules, as they would already define the exception support code and we want to have exactly one copy of it
      // in the generated shared library, so check for "import" nodes.
      if (find_first_named_import(n)) {
        // We import another module, which will have already defined SWIG_CException, so set the flag indicating that we shouldn't do it again in this one and
        // define the symbol to skip compiling its implementation.
        Printv(sect_runtime, "#define SWIG_CException_DEFINED 1\n", NIL);

        // Also set a flag telling classDeclaration() to skip creating SWIG_CException wrappers.
        exceptions_support_ = exceptions_support_imported;
      }
    }

    if (cxx_wrappers_.is_initialized())
      cxx_wrappers_.initialize_exceptions(exceptions_support_);

    {
      String *const include_guard_name = NewStringf("SWIG_%s_WRAP_H_", module_name);
      String *const include_guard_begin = NewStringf("#ifndef %s\n"
                                                     "#define %s\n\n",
                                                     include_guard_name,
                                                     include_guard_name);
      String *const include_guard_end = NewStringf("\n"
                                                   "#endif /* %s */\n",
                                                   include_guard_name);

      BeginEndOutputGuard include_guard_wrappers_h(f_wrappers_h, include_guard_begin, include_guard_end);

      // All the struct types used by the functions go to f_wrappers_types so that they're certain to be defined before they're used by any functions. All the
      // functions declarations go directly to f_wrappers_decl we write both of them to f_wrappers_h at the end.
      sect_wrappers_types = NewString("");
      sect_wrappers_decl = NewString("");
      forward_declared_types_ = NewHash();
      opaque_types_ = NewHash();
      member_pointer_structs_ = NewHash();

      {
        CPlusPlusOutputGuard cplusplus_guard_wrappers(sect_wrappers), cplusplus_guard_wrappers_h(sect_wrappers_decl);

        // emit code for children
        Language::top(n);
      }  // close extern "C" guards

      Dump(sect_wrappers_types, f_wrappers_h);
      Delete(sect_wrappers_types);

      Dump(sect_wrappers_decl, f_wrappers_h);
      Delete(sect_wrappers_decl);

      if (cxx_wrappers_.is_initialized()) {
        if (!ns_cxx) {
          // We need some namespace for the C++ wrappers as otherwise their names could conflict with the C functions, so use the module name if nothing was
          // explicitly specified.
          ns_cxx = Copy(module_name);
        }

        Printv(f_wrappers_h, "#ifdef __cplusplus\n\n", NIL);
        Dump(cxx_wrappers_.sect_cxx_h, f_wrappers_h);

        // Generate possibly nested namespace declarations, as unfortunately we can't rely on C++17 nested namespace definitions being always available.
        ScopedPtr cxx_ns_end = adopt(NewStringEmpty());
        for (const char *c = Char(ns_cxx);;) {
          const char *const next = strstr(c, "::");

          MaybeOwnedPtr ns_component;
          if (next) {
            ns_component.assign_owned(NewStringWithSize(c, (int)(next - c)));
          } else {
            ns_component.assign_non_owned((DOH *)c);
          }

          Printf(f_wrappers_h, "namespace %s {\n", ns_component.get());
          Printf(cxx_ns_end, "}\n");

          if (!next)
            break;

          c = next + 2;
        }

        Printv(f_wrappers_h, "\n", NIL);
        Dump(cxx_wrappers_.sect_types, f_wrappers_h);

        Printv(f_wrappers_h, "\n", NIL);
        Dump(cxx_wrappers_.sect_decls, f_wrappers_h);

        Printv(f_wrappers_h, "\n", NIL);
        Dump(cxx_wrappers_.sect_impls, f_wrappers_h);

        Printv(f_wrappers_h, "\n", cxx_ns_end.get(), "\n#endif /* __cplusplus */\n", NIL);
      }
    }  // close wrapper header guard

    // write all to the file
    Dump(sect_begin, f_wrappers_cxx);
    Dump(sect_runtime, f_wrappers_cxx);
    Dump(sect_header, f_wrappers_cxx);
    Dump(sect_wrappers, f_wrappers_cxx);
    Dump(sect_init, f_wrappers_cxx);

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * importDirective()
   * ------------------------------------------------------------------------ */

  virtual int importDirective(Node *n) {
    // When we import another module, we need access to its declarations in our header, so we must include the header generated for that module. Unfortunately
    // there doesn't seem to be any good way to get the name of that header, so we try to guess it from the header name of this module. This is obviously not
    // completely reliable, but works reasonably well in practice and it's not clear what else could we do, short of requiring some C-specific %import attribute
    // specifying the name of the header explicitly.

    // We can only do something if we have a module name.
    if (String *const imported_module_name = Getattr(n, "module")) {
      // Start with our header name.
      ScopedPtr header_name = adopt(Copy(outfile_h));

      // Strip the output directory from the file name, as it should be common to all generated headers.
      Replace(header_name, SWIG_output_directory(), "", DOH_REPLACE_FIRST);

      // And replace our module name with the name of the one being imported.
      Replace(header_name, module_name, imported_module_name, DOH_REPLACE_FIRST);

      // Finally inject inclusion of this header.
      Printv(Swig_filebyname("cheader"), "#include \"", header_name.get(), "\"\n", NIL);
    }

    return Language::importDirective(n);
  }

  /* -----------------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalvariableHandler(Node *n) {
    // Don't export static globals, they won't be accessible when using a shared library, for example.
    if (Checkattr(n, "storage", "static"))
      return SWIG_NOWRAP;

    // We can't export variables defined inside namespaces to C directly, whatever their type, and we can only export them under their original name, so we
    // can't do it when using a global namespace prefix neither.
    if (!ns_prefix && !ScopedPtr(Swig_scopename_prefix(Getattr(n, "name")))) {
      // If we can export the variable directly, do it, this will be more convenient to use from C code than accessor functions.
      if (String *const var_decl = make_c_var_decl(n, Getattr(n, "type"), false)) {
        Printv(sect_wrappers_decl, "SWIGIMPORT ", var_decl, ";\n\n", NIL);
        Delete(var_decl);
        return SWIG_OK;
      }
    }

    // Save the sym:name of the variable, which names the C++ wrappers of its accessors, as for a member variable, for
    // CxxFunctionWrapper::emit(). The sym:name of an accessor is the name of the C wrapper that the C++ one calls.
    if (!getCurrentClass()) {
      Swig_require("c:globalvariableHandler", n, "*sym:name", NIL);

      // We have to prepend the global prefix to the names of the accessors for this variable, if we use one.
      //
      // Note that we can't just register the name format using the prefix for "get" and "set", as we do it for
      // "member". Using it for both would result in the prefix being used twice for the member variables getters and
      // setters, so we have to work around it here instead.
      if (ns_prefix) {
        ScopedPtr prefixed_name = adopt(NewStringf("%s_%s", ns_prefix, Getattr(n, "sym:name")));
        Setattr(n, "sym:name", prefixed_name);
      }
    }

    // Otherwise, e.g. if it's of a C++-only type, or a reference, generate accessor functions for it.
    int const rc = Language::globalvariableHandler(n);

    if (Getattr(n, "view"))
      Swig_restore(n);

    return rc;
  }

  /* ----------------------------------------------------------------------
   * prepend_feature()
   * ---------------------------------------------------------------------- */

  String *prepend_feature(Node *n) {
    String *prepend_str = Getattr(n, "feature:prepend");
    if (prepend_str) {
      char *t = Char(prepend_str);
      if (*t == '{') {
        Delitem(prepend_str, 0);
        Delitem(prepend_str, DOH_END);
      }
    }
    return (prepend_str ? prepend_str : empty_string);
  }

  /* ----------------------------------------------------------------------
   * append_feature()
   * ---------------------------------------------------------------------- */

  String *append_feature(Node *n) {
    String *append_str = Getattr(n, "feature:append");
    if (append_str) {
      char *t = Char(append_str);
      if (*t == '{') {
        Delitem(append_str, 0);
        Delitem(append_str, DOH_END);
      }
    }
    return (append_str ? append_str : empty_string);
  }

  /* ----------------------------------------------------------------------
   * canThrow()
   *
   * Notes that the wrapper for 'n' needs the 'fail' label that SWIG_fail jumps to,
   * if the 'typemap' typemap attached to 'parameter' has the canthrow attribute.
   * ---------------------------------------------------------------------- */

  void canThrow(Node *n, const_String_or_char_ptr typemap, Node *parameter) {
    String *canthrow_attribute = NewStringf("tmap:%s:canthrow", typemap);
    String *canthrow = Getattr(parameter, canthrow_attribute);
    if (canthrow)
      Setattr(n, "c:canthrow", "1");
    Delete(canthrow_attribute);
  }

  /* ----------------------------------------------------------------------
   * emit_fail_label()
   *
   * Appends the 'fail' label that SWIG_fail jumps to after an error, if a typemap or feature used by the
   * wrapper has the canthrow attribute, followed by the cleanup code and a return of 'fail_result', which
   * is NULL for a void function. Returns true if the label is added.
   * ---------------------------------------------------------------------- */

  bool emit_fail_label(Node *n, Wrapper *wrapper, String *cleanup, const char *fail_result) {
    if (!Getattr(n, "c:canthrow")) {
      // A simple check, which is not foolproof, for code that jumps to the label. SWIG_exception is usually found as the SWIG_fail it expands to.
      const char *jump = Strstr(wrapper->code, "SWIG_exception") ? "SWIG_exception" : Strstr(wrapper->code, "SWIG_fail") ? "SWIG_fail" : NULL;
      if (jump) {
        Swig_warning(WARN_C_CANTHROW_MISSING,
                     input_file,
                     line_number,
                     "Wrapper code uses %s, but no 'fail' label is generated for it to jump to, as the canthrow attribute is not set.\n",
                     jump);
      }
      return false;
    }

    if (fail_result) {
      Printv(wrapper->code, "fail: SWIGUNUSED;\n", cleanup, "return ", fail_result, ";\n", NIL);
    } else {
      Printv(wrapper->code, "return;\n", "fail: SWIGUNUSED;\n", cleanup, "return;\n", NIL);
    }
    return true;
  }

  /* ----------------------------------------------------------------------
   * get_mangled_type()
   *
   * Returns the mangled type of a parameter of an overloaded function, which is appended to the C name of the function
   * to distinguish it from its other overloads. A pointer to a function is mangled as 'f'. Otherwise each element of the
   * type before its base type, which is the return type of a pointer to member function, is mangled as:
   *   'p' for a pointer
   *   'r' for a reference
   *   'z' for an rvalue reference
   *   'c' for 'const' and 'v' for 'volatile'
   *   'a' followed by the size for an array
   *   'm' followed by the mangled class for a pointer to member
   *   'f' followed by the mangled type of each parameter, each one after '_', for a function
   *   'v' for a variadic type
   * The base type is mangled as its first letter for a builtin type whose name is one word, such as 'i' for 'int', 'e'
   * followed by its name for an enum or its mangled name otherwise, as for 'unsigned int', which would otherwise have the
   * same first letter as other builtin types.
   * ---------------------------------------------------------------------- */

  String *get_mangled_type(SwigType *type_arg) {
    ScopedPtr resolved_type = adopt(SwigType_typedef_resolve_all(type_arg));

    // A pointer to a function is mangled as 'f', without its parameter and return types. Any other pointer, or a pointer
    // to member, is mangled from type_arg, without resolving its typedefs, unlike any other type. A pointer to member
    // function keeps its parameter and return types, as overloads can differ in them only, which the wrappers pass as
    // different types.
    SwigType *type = resolved_type;
    if (SwigType_ispointer(resolved_type) || SwigType_ismemberpointer(resolved_type)) {
      ScopedPtr pointee = adopt(Copy(resolved_type));
      Delete(SwigType_pop(pointee));
      if (SwigType_ispointer(resolved_type) && SwigType_isfunction(pointee))
        return NewString("f");
      type = type_arg;
    }

    ScopedPtr prefix = adopt(NewStringEmpty());
    ScopedPtr type_prefix = adopt(SwigType_prefix(type));
    ScopedPtr elements = adopt(SwigType_split(type_prefix));
    for (Iterator i = First(elements); i.item; i = Next(i)) {
      SwigType *const element = i.item;
      if (SwigType_ispointer(element)) {
        Append(prefix, "p");
      } else if (SwigType_isreference(element)) {
        Append(prefix, "r");
      } else if (SwigType_isrvalue_reference(element)) {
        Append(prefix, "z");
      } else if (SwigType_isqualifier(element)) {
        if (SwigType_isconst(element))
          Append(prefix, "c");
        if (is_volatile_qualifier(element))
          Append(prefix, "v");
      } else if (SwigType_isarray(element)) {
        ScopedPtr size = adopt(SwigType_array_getdim(element, 0));
        Printv(prefix, "a", size.get(), NIL);
      } else if (SwigType_ismemberpointer(element)) {
        ScopedPtr class_name = adopt(SwigType_parm(element));
        ScopedPtr mangled_class_name = adopt(Swig_name_mangle_type(class_name));
        Printv(prefix, "m", mangled_class_name.get(), NIL);
      } else if (SwigType_isfunction(element)) {
        Append(prefix, "f");
        ScopedPtr parm_types = adopt(SwigType_parmlist(element));
        for (Iterator j = First(parm_types); j.item; j = Next(j)) {
          ScopedPtr mangled_parm_type = adopt(get_mangled_type(j.item));
          Printv(prefix, "_", mangled_parm_type.get(), NIL);
        }
      } else if (SwigType_isvariadic(element)) {
        Append(prefix, "v");
      } else {
        Append(prefix, element);
      }
    }

    // An array size can be an expression, such as 'N+1' or 'sizeof("abc")', so mangle it.
    String *result = Swig_name_mangle_string(prefix);

    ScopedPtr base = adopt(SwigType_base(type));
    if (SwigType_isbuiltin(base) && !Strchr(base, ' ')) {
      Printf(result, "%c", *Char(base));
    } else if (SwigType_isenum(base)) {
      ScopedPtr enumname = adopt(Swig_scopename_last(base));
      const char *s = Char(enumname);
      static const size_t len_enum_prefix = strlen("enum ");
      if (strncmp(s, "enum ", len_enum_prefix) == 0)
        s += len_enum_prefix;
      Printf(result, "e%s", s);
    } else {
      // Use Swig_name_mangle_type() here and not Swig_name_mangle_string() to get slightly simpler mangled name for templates (notably avoiding "_Sp_" and
      // "_SP_" fragments for the parentheses used by SWIG internally around template parameters).
      ScopedPtr mangled_base = adopt(Swig_name_mangle_type(base));
      Append(result, mangled_base);
    }

    return result;
  }

  void functionWrapperCSpecific(Node *n) {
    // this is C function, we don't apply typemaps to it
    String *name = Getattr(n, "sym:name");
    MaybeOwnedPtr wname = getFunctionWrapperName(n, name);
    SwigType *type = Getattr(n, "type");
    SwigType *return_type = NULL;
    ParmList *parms = Getattr(n, "parms");
    Parm *p;
    bool is_void_return = (SwigType_type(type) == T_VOID);

    // create new function wrapper object
    Wrapper *wrapper = NewWrapper();

    // create new wrapper name, which emit_action() requires
    Setattr(n, "wrap:name", wname);

    // $symname in the typemaps and the %exception code expands to sym:name, so use the other target languages' one
    Swig_save("functionWrapperCSpecific", n, "sym:name", NIL);
    String *symname = getSymName(n);
    Setattr(n, "sym:name", symname);
    Delete(symname);

    // make sure lnames are set, as they are not for the parameter of a variable setter
    int index = 1;
    for (p = parms; p; (p = nextSibling(p)), index++) {
      if (!Getattr(p, "lname")) {
        String *lname = NewStringf("arg%d", index);
        Setattr(p, "lname", lname);
        Delete(lname);
      }
    }
    return_type = SwigType_str(type, 0);

    // emit wrapper prototype and code
    ScopedPtr parms_c;
    for (p = parms; p; p = nextSibling(p)) {
      ScopedPtr parm_type = adopt(SwigType_decay_array(Getattr(p, "type")));
      parms_c = ParmList_join(parms_c.release(), NewParm(parm_type, Getattr(p, "lname"), p));
    }

    // the name goes inside the declaration, as for a function returning a pointer to an array, which is what the getter
    // of an array variable returns, as in 'int (*name(void))[3]'
    ScopedPtr def_type = adopt(SwigType_decay_array(type));
    Printv(wrapper->def, get_func_decl(def_type, wname, parms_c).get(), " {\n", NIL);

    // the result variable is assigned to, so it does not have the qualifiers of a const return type
    if (!is_void_return) {
      Printv(wrapper->code, ScopedPtr(SwigType_lstr(type, "result")).get(), ";\n", NIL);
    }

    // attach 'check' typemaps
    Swig_typemap_attach_parms("check", parms, wrapper);

    // insert constraint checking
    for (p = parms; p;) {
      String *tm;
      if ((tm = Getattr(p, "tmap:check"))) {
        canThrow(n, "check", p);
        Replaceall(tm, "$target", Getattr(p, "lname"));
        Replaceall(tm, "$name", name);
        Printv(wrapper->code, tm, "\n", NIL);
        p = Getattr(p, "tmap:check:next");
      } else {
        p = nextSibling(p);
      }
    }

    // the action of a variable setter is the memberin or globalin typemap
    if (Getattr(n, "memberset"))
      canThrow(n, "memberin", n);
    else if (Getattr(n, "varset"))
      canThrow(n, "globalin", n);

    // %exception
    if (Getattr(n, "feature:except:canthrow"))
      Setattr(n, "c:canthrow", "1");

    Append(wrapper->code, prepend_feature(n));
    Append(wrapper->code, ScopedPtr(emit_action(n)).get());
    Append(wrapper->code, append_feature(n));
    // The result variable has no qualifiers, so it is cast back to the return type, as a 'char **' cannot be returned as a 'const char **' without a cast
    if (!is_void_return)
      Printv(wrapper->code, "return ", ScopedPtr(SwigType_rcaststr(type, "result")).get(), ";\n", NIL);

    SwigType *resolved_type = SwigType_typedef_resolve_all(type);
    if (SwigType_type(resolved_type) == T_USER) {
      // A struct returned by value cannot be 0, so a zero initialised one is returned after an error
      if (emit_fail_label(n, wrapper, empty_string, "swig_null_result")) {
        String *null_result = NewStringf("static %s swig_null_result;\n", return_type);
        Insert(wrapper->code, 0, null_result);
        Delete(null_result);
      }
    } else {
      emit_fail_label(n, wrapper, empty_string, is_void_return ? NULL : "0");
    }
    Delete(resolved_type);

    emit_isvoid_special_variables(n, wrapper->code, is_void_return);
    Replaceall(wrapper->code, "$symname", Getattr(n, "sym:name"));

    Printf(wrapper->code, "}");

    Wrapper_print(wrapper, sect_wrappers);
    Swig_restore(n);

    emit_wrapper_func_decl(n, wname);

    // cleanup
    Delete(return_type);
    DelWrapper(wrapper);
  }

  void functionWrapperAppendOverloaded(String *name, Parm *first_param) {
    for (Parm *p = first_param; p; p = nextSibling(p)) {
      ScopedPtr mangled = adopt(get_mangled_type(Getattr(p, "type")));
      Printv(name, "_", mangled.get(), NIL);
    }
  }

  /* ----------------------------------------------------------------------
   * functionWrapperAppendQualifiers()
   *
   * Appends to name, the C name of the overloaded member function n, a suffix distinguishing it from its overloads with
   * the same parameters, which differ from n only in their qualifiers. The suffix has '_const', '_volatile' and
   * '_rvalue', in this order, for each of the 'const', 'volatile' and '&&' qualifiers of n that one of these overloads
   * does not have. So each combination of the qualifiers gets a different name. For example, these overloads get the
   * suffixes '', '_const' and '_volatile':
   *   int f(int);
   *   int f(int) const;
   *   int f(int) volatile;
   * A qualifier that all of them have adds nothing, so these overloads get the suffixes '' and '_const':
   *   int g(int) volatile;
   *   int g(int) const volatile;
   * ---------------------------------------------------------------------- */

  void functionWrapperAppendQualifiers(String *name, Node *n) {
    SwigType *const decl = Getattr(n, "decl");
    ScopedPtr parms_type = adopt(get_function_parms_type(decl));
    if (!parms_type)
      return;

    FunctionQualifiers const qualifiers(decl);
    bool add_const = false;
    bool add_volatile = false;
    bool add_rvalue = false;
    for (Node *nover = Getattr(n, "sym:overloaded"); nover; nover = Getattr(nover, "sym:nextSibling")) {
      if (nover == n)
        continue;

      SwigType *const over_decl = Getattr(nover, "decl");
      ScopedPtr over_parms_type = adopt(get_function_parms_type(over_decl));
      if (!Equal(over_parms_type, parms_type))
        continue;

      FunctionQualifiers const over_qualifiers(over_decl);
      if (qualifiers.is_const && !over_qualifiers.is_const)
        add_const = true;
      if (qualifiers.is_volatile && !over_qualifiers.is_volatile)
        add_volatile = true;
      if (qualifiers.is_rvalue && !over_qualifiers.is_rvalue)
        add_rvalue = true;
    }

    if (add_const)
      Append(name, "_const");
    if (add_volatile)
      Append(name, "_volatile");
    if (add_rvalue)
      Append(name, "_rvalue");
  }

  /* ----------------------------------------------------------------------
   * get_wrapper_func_return_type()
   *
   * Return the type returned by the wrapper of the function n, which is C type text or a SwigType, see substituteResolvedType().
   * ---------------------------------------------------------------------- */
  ScopedPtr get_wrapper_func_return_type(Node *n) {
    SwigType *type = Getattr(n, "type");
    String *return_type;

    if ((return_type = Swig_typemap_lookup("ctype", n, "", 0))) {
      // a SwigType from substituteResolvedType() already uses the C names of the classes and enums
      if (!substituteResolvedType(type, return_type, n))
        Replaceall(return_type, "::", "_");
    } else {
      Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(type, 0));
      return_type = NewString("");
    }

    return ScopedPtr(return_type);
  }

  /* ----------------------------------------------------------------------
   * get_wrapper_func_parms()
   *
   * Return the parameters of the wrapper of the function n with the C types and names used for them, none after an error.
   * Each type is C type text or a SwigType, see substituteResolvedType().
   * If a non-null wrapper is specified, it is used to emit typemap-defined code in it and it also determines whether we're generating the prototype for the
   * declarations or the definitions, which changes the type used for the C++ objects.
   * ---------------------------------------------------------------------- */
  ScopedPtr get_wrapper_func_parms(Node *n, Wrapper *wrapper = NULL) {
    ParmList *parms = Getattr(n, "parms");

    Parm *p;
    ScopedPtr parms_c;

    // attach the standard typemaps, except when wrapping C, as the 'in' typemaps are then not used
    if (wrapper) {
      emit_attach_parm_typemaps(parms, wrapper);
    } else if (CPlusPlus) {
      // Attach "in" manually, we need it for tmap:in:numinputs below.
      Swig_typemap_attach_parms("in", parms, 0);
    }
    Setattr(n, "wrap:parms", parms);  // never read again?!

    // attach 'ctype' typemaps, except when wrapping C, as the wrapper then has the parameters of the function, see
    // functionWrapperCSpecific(), so the 'ctype' typemap of each parameter is looked up on its own below instead
    if (CPlusPlus)
      Swig_typemap_attach_parms("ctype", parms, 0);

    // prepare function definition
    for (p = parms; p;) {
      String *tm;
      SwigType *type = NULL;

      if (wrapper) {
        p = emit_ignored_in_typemaps(p, wrapper->code);
      } else if (CPlusPlus) {
        while (p && checkAttribute(p, "tmap:in:numinputs", "0")) {
          p = Getattr(p, "tmap:in:next");
        }
      }
      if (!p)
        break;

      type = Getattr(p, "type");
      if (SwigType_type(type) == T_VOID) {
        p = nextSibling(p);
        continue;
      }

      if (SwigType_type(type) == T_VARARGS) {
        Swig_error(Getfile(n), Getline(n), "Vararg function %s not supported.\n", Getattr(n, "name"));
        return ScopedPtr(NULL);
      }

      String *lname = Getattr(p, "lname");
      String *c_parm_type = 0;
      String *arg_name = NewString("");

      Printf(arg_name, "c%s", lname);

      ScopedPtr parm_ctype;
      if (CPlusPlus) {
        tm = Getattr(p, "tmap:ctype");
      } else {
        parm_ctype = Swig_typemap_lookup("ctype", p, "", 0);
        tm = parm_ctype.get();
      }
      if (tm) {  // set the appropriate type for parameter
        c_parm_type = Copy(tm);
        bool const is_swigtype = substituteResolvedType(type, c_parm_type, p);

        // We prefer to keep typedefs in the wrapper functions signatures as it makes them more readable, but we can't do it for nested typedefs as
        // they're not valid in C, so resolve them in this case. A SwigType from substituteResolvedType() is already resolved.
        if (!is_swigtype && strstr(Char(c_parm_type), "::")) {
          SwigType *const tdtype = SwigType_typedef_resolve_all(c_parm_type);
          Delete(c_parm_type);
          c_parm_type = tdtype;
        }

        // template handling
        Replaceall(c_parm_type, "$tt", SwigType_lstr(type, 0));
      } else {
        Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(type, 0));
        // the parameter is declared without a type, an invalid declaration, as a parameter needs a type
        c_parm_type = NewStringEmpty();
      }

      parms_c = ParmList_join(parms_c.release(), NewParm(c_parm_type, arg_name, p));

      // apply typemaps for input parameter, except when wrapping C
      if (!CPlusPlus) {
        p = nextSibling(p);
      } else if ((tm = Getattr(p, "tmap:in"))) {
        Replaceall(tm, "$input", arg_name);
        if (wrapper) {
          canThrow(n, "in", p);
          Setattr(p, "emit:input", arg_name);
          Printf(wrapper->code, "%s\n", tm);
        }
        p = Getattr(p, "tmap:in:next");
      } else {
        Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(type, 0));
        p = nextSibling(p);
      }

      Delete(arg_name);
      Delete(c_parm_type);
    }

    return parms_c;
  }

  /* ----------------------------------------------------------------------
   * emit_wrapper_func_decl()
   *
   * Declares the wrapper function, using the C types used for it, in the header.
   * The node here is a function declaration.
   * ---------------------------------------------------------------------- */
  void emit_wrapper_func_decl(Node *n, String *wname) {
    current_output = output_wrapper_decl;

    // add function declaration to the proxy header file
    ScopedPtr parms_c = get_wrapper_func_parms(n);
    ScopedPtr return_type = get_wrapper_func_return_type(n);
    Printv(sect_wrappers_decl, "SWIGIMPORT ", get_func_decl(return_type, wname, parms_c).get(), ";\n\n", NIL);
  }

  void functionWrapperCPPSpecific(Node *n) {
    ParmList *parms = Getattr(n, "parms");
    String *name = Copy(Getattr(n, "sym:name"));

    // mangle name if function is overloaded
    if (Getattr(n, "sym:overloaded")) {
      if (!Getattr(n, "copy_constructor")) {
        Parm *first_param = (Parm *)parms;
        if (first_param) {
          // Skip the first "this" parameter of the wrapped methods, it doesn't participate in overload resolution and would just result in extra long
          // and ugly names.
          //
          // We need to avoid dropping the first argument of static methods which don't have "this" pointer, in spite of being members (and we have to
          // use "cplus:staticbase" for this instead of just using Swig_storage_isstatic() because "storage" is reset in staticmemberfunctionHandler()
          // and so is not available here.
          //
          // Of course, the constructors don't have the extra first parameter neither.
          if (!Checkattr(n, "nodeType", "constructor") && Checkattr(n, "ismember", "1") && !Getattr(n, "cplus:staticbase")) {
            first_param = nextSibling(first_param);

            // A special case of overloading on the qualifiers of "this" only, we still need to distinguish between those.
            functionWrapperAppendQualifiers(name, n);
          }

          functionWrapperAppendOverloaded(name, first_param);
        }
      }
    }

    // make sure lnames are set
    Parm *p;
    int index = 1;
    String *lname = 0;

    for (p = (Parm *)parms, index = 1; p; (p = nextSibling(p)), index++) {
      if (!(lname = Getattr(p, "lname"))) {
        lname = NewStringf("arg%d", index);
        Setattr(p, "lname", lname);
      }
    }

    // C++ function wrapper
    current_output = output_wrapper_def;

    SwigType *type = Getattr(n, "type");
    ScopedPtr return_type = get_wrapper_func_return_type(n);
    MaybeOwnedPtr wname = getFunctionWrapperName(n, name);
    bool is_void_return = (SwigType_type(type) == T_VOID);
    // create new function wrapper object
    Wrapper *wrapper = NewWrapper();

    // create new wrapper name
    Setattr(n, "wrap:name", wname);

    // $symname in the typemaps and the %exception code expands to sym:name, so use the other target languages' one
    Swig_save("functionWrapperCPPSpecific", n, "sym:name", NIL);
    String *symname = getSymName(n);
    Setattr(n, "sym:name", symname);
    Delete(symname);

    // add variable for holding result of original function 'cppresult'
    if (!is_void_return) {
      SwigType *value_type = cplus_value_type(type);
      SwigType *cppresult_type = value_type ? value_type : type;
      String *cppresult_decl = SwigType_lstr(cppresult_type, "cppresult");
      Wrapper_add_local(wrapper, "cppresult", cppresult_decl);
      Delete(cppresult_decl);
      Delete(value_type);
    }

    // create wrapper function prototype
    ScopedPtr parms_c = get_wrapper_func_parms(n, wrapper);
    Printv(wrapper->def, "SWIGEXPORTC ", get_func_decl(return_type, wname, parms_c).get(), " {", NIL);

    // emit variables for holding parameters
    emit_parameter_variables(parms, wrapper);

    // emit variable for holding function return value
    emit_return_variable(n, return_type, wrapper);

    // insert constraint checking
    for (p = parms; p;) {
      String *tm;
      if ((tm = Getattr(p, "tmap:check"))) {
        canThrow(n, "check", p);
        Replaceall(tm, "$target", Getattr(p, "lname"));
        Replaceall(tm, "$name", name);
        Printv(wrapper->code, tm, "\n", NIL);
        p = Getattr(p, "tmap:check:next");
      } else {
        p = nextSibling(p);
      }
    }

    // look for the throws typemaps used for the exception specification and the canthrow attribute
    if (ParmList *throw_parm_list = Getattr(n, "catchlist")) {
      Swig_typemap_attach_parms("throws", throw_parm_list, 0);
      for (p = throw_parm_list; p; p = nextSibling(p)) {
        if (Getattr(p, "tmap:throws"))
          canThrow(n, "throws", p);
      }
    }

    // the action of a variable setter is the memberin or globalin typemap
    if (Getattr(n, "memberset"))
      canThrow(n, "memberin", n);
    else if (Getattr(n, "varset"))
      canThrow(n, "globalin", n);

    // %exception
    if (Getattr(n, "feature:except:canthrow"))
      Setattr(n, "c:canthrow", "1");

    // create action code
    String *action = Getattr(n, "wrap:action");
    if (!action)
      action = NewString("");

    String *cbase_name = Getattr(n, "c:base_name");
    if (cbase_name) {
      Replaceall(action, "arg1)->", NewStringf("(%s*)arg1)->", Getattr(n, "c:inherited_from")));
      Replaceall(action, Getattr(n, "name"), cbase_name);
    }

    Replaceall(action, "result =", "cppresult =");

    // prepare action code to use, e.g. insert try-catch blocks
    action = emit_action(n);

    // emit output typemap if needed
    if (!is_void_return) {
      String *tm;
      if ((tm = Swig_typemap_lookup_out("out", n, "cppresult", wrapper, action))) {
        canThrow(n, "out", n);
        // This is ugly, but the type of our result variable is not always the same as the actual return type currently because
        // get_wrapper_func_return_type() applies ctype typemap to it. These types are more or less compatible though, so we should be able to cast
        // between them explicitly.
        const char *start = Char(tm);
        const char *p = strstr(start, "$result = ");
        if (p == start || (p && p[-1] == ' ')) {
          p += strlen("$result = ");
          ScopedPtr result_cast = adopt(NewStringf("(%s)", return_type.get()));

          // However don't add a cast which is already there.
          if (strncmp(p, Char(result_cast), strlen(Char(result_cast))) != 0)
            Insert(tm, (int)(p - start), result_cast);
        }
        Replaceall(tm, "$result", "result");
        Replaceall(tm, "$owner", GetFlag(n, "feature:new") ? "1" : "0");
        Printf(wrapper->code, "%s", tm);
        if (Len(tm))
          Printf(wrapper->code, "\n");
      } else {
        Swig_warning(
          WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(type, 0), Getattr(n, "name"));
      }
    } else {
      Append(wrapper->code, action);
    }

    // insert argument output code
    for (p = parms; p;) {
      String *tm;
      if ((tm = Getattr(p, "tmap:argout"))) {
        if (Len(tm) != 0) {
          canThrow(n, "argout", p);
          if (is_void_return && Strstr(tm, "$result")) {
            String *pname = Getattr(p, "name") ? Getattr(p, "name") : Getattr(p, "lname");
            Swig_error(Getfile(n), Getline(n), "The 'argout' typemap of parameter '%s' uses $result, but '%s' returns void.\n", pname, name);
          }
          String *input = NewStringf("c%s", Getattr(p, "lname"));
          Replaceall(tm, "$input", input);
          Replaceall(tm, "$result", "result");
          Delete(input);
          Printv(wrapper->code, tm, "\n", NIL);
        }
        p = Getattr(p, "tmap:argout:next");
      } else {
        p = nextSibling(p);
      }
    }

    // insert cleanup code, which is run after an error too, so the canthrow attribute is not used for a freearg typemap, which cannot use SWIG_fail
    ScopedPtr cleanup = adopt(NewStringEmpty());
    for (p = parms; p;) {
      String *tm;
      if ((tm = Getattr(p, "tmap:freearg"))) {
        if (tm && (Len(tm) != 0)) {
          String *input = NewStringf("c%s", Getattr(p, "lname"));
          Replaceall(tm, "$source", Getattr(p, "lname"));
          Replaceall(tm, "$input", input);
          Delete(input);
          Printv(cleanup, tm, "\n", NIL);
        }
        p = Getattr(p, "tmap:freearg:next");
      } else {
        p = nextSibling(p);
      }
    }
    Append(wrapper->code, cleanup);

    if (!is_void_return)
      Append(wrapper->code, "return result;\n");
    // A pointer to member is returned as a struct, which cannot be 0, so a zero initialised one is returned after an error
    if (is_member_pointer_value(type)) {
      if (emit_fail_label(n, wrapper, cleanup, "swig_null_result"))
        Wrapper_add_localv(wrapper, "swig_null_result", "static", return_type.get(), "swig_null_result", NIL);
    } else {
      emit_fail_label(n, wrapper, cleanup, is_void_return ? NULL : "0");
    }

    emit_isvoid_special_variables(n, wrapper->code, is_void_return);
    Replaceall(wrapper->code, "$symname", Getattr(n, "sym:name"));

    Append(wrapper->code, "}\n");

    Wrapper_print(wrapper, sect_wrappers);
    Swig_restore(n);

    // cleanup
    DelWrapper(wrapper);

    emit_wrapper_func_decl(n, wname);

    if (cxx_wrappers_.is_initialized()) {
      TempPtrSetter<Node *> set(&cxx_wrappers_.node_func_, n);

      if (cxx_class_wrapper_) {
        cxx_class_wrapper_->emit_member_function(n);
      } else {
        CxxFunctionWrapper w(cxx_wrappers_, n, Getattr(n, "parms"));
        if (w.can_wrap())
          w.emit();
      }
    }

    Delete(name);
  }

  /* ----------------------------------------------------------------------
   * functionWrapper()
   * ---------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
    if (!Getattr(n, "sym:overloaded")) {
      if (!addSymbol(Getattr(n, "sym:name"), n))
        return SWIG_ERROR;
    }

    // A variable getter and setter are wrapped from the same node, so only the typemaps and features of this wrapper decide if it can fail
    Delattr(n, "c:canthrow");

    if (CPlusPlus) {
      functionWrapperCPPSpecific(n);
    } else {
      functionWrapperCSpecific(n);
    }

    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * copy_node()
   *
   * This is not a general-purpose node copying function, but just a helper of classHandler().
   * --------------------------------------------------------------------- */

  Node *copy_node(Node *node) {
    Node *new_node = NewHash();
    Setattr(new_node, "name", Copy(Getattr(node, "name")));
    Setattr(new_node, "ismember", Copy(Getattr(node, "ismember")));
    Setattr(new_node, "view", Copy(Getattr(node, "view")));
    Setattr(new_node, "kind", Copy(Getattr(node, "kind")));
    Setattr(new_node, "access", Copy(Getattr(node, "access")));
    Setattr(new_node, "parms", Copy(Getattr(node, "parms")));
    Setattr(new_node, "type", Copy(Getattr(node, "type")));
    Setattr(new_node, "decl", Copy(Getattr(node, "decl")));
    // use the features, such as %exception, and the exception specification of the base class member
    for (Iterator ki = First(node); ki.key; ki = Next(ki)) {
      if (Strncmp(ki.key, "feature:", 8) == 0)
        Setattr(new_node, ki.key, Copy(ki.item));
    }
    if (ParmList *throws = Getattr(node, "throws"))
      Setattr(new_node, "throws", CopyParmList(throws));
    if (ParmList *catchlist = Getattr(node, "catchlist"))
      Setattr(new_node, "catchlist", CopyParmList(catchlist));

    Node *const parent = parentNode(node);
    Setattr(new_node, "c:inherited_from", Getattr(parent, "name"));
    Setattr(new_node, "sym:name", Getattr(node, "sym:name"));
    Setattr(new_node, "sym:symtab", Getattr(parent, "symtab"));
    set_nodeType(new_node, "cdecl");

    return new_node;
  }

  /* ---------------------------------------------------------------------
   * is_in()
   *
   * tests if given name already exists in one of child nodes of n
   * --------------------------------------------------------------------- */

  Hash *is_in(String *name, Node *n) {
    Hash *h;
    for (h = firstChild(n); h; h = nextSibling(h)) {
      if (Cmp(name, Getattr(h, "name")) == 0)
        return h;
    }
    return 0;
  }

  /* ---------------------------------------------------------------------
   * resolve_undeclared_typedefs()
   *
   * Return a copy of type with each typedef that the header file does not declare replaced by the type it stands for,
   * such as 'int *' for 'Integer' after 'typedef int *Integer'. The header file declares a wrapped struct or enum that is
   * declared with a typedef by its typedef name, as in 'typedef struct {...} Foo', so the base type is resolved until it
   * is such a name or it is not a typedef.
   * --------------------------------------------------------------------- */
  SwigType *resolve_undeclared_typedefs(SwigType *type) {
    SwigType *resolved = Copy(type);
    for (;;) {
      ScopedPtr base = adopt(SwigType_base(resolved));
      if (Node *enum_node = enumLookup(base)) {
        if (Checkattr(enum_node, "allows_typedef", "1") && Equal(Getattr(enum_node, "sym:name"), base))
          break;
      } else if (Node *class_node = classLookup(base)) {
        String *tdname = Getattr(class_node, "tdname");
        if (tdname && Equal(tdname, base))
          break;
      }
      SwigType *next = SwigType_typedef_resolve(resolved);
      if (!next)
        break;
      Delete(resolved);
      resolved = next;
    }
    return resolved;
  }

  /* ---------------------------------------------------------------------
   * intForUnknownEnum()
   *
   * Return 'int' for an enum base type that SWIG does not know, which the header file cannot declare, as 'int' is used
   * for a parameter of such an enum type of a wrapper function too, or a copy of any other base type. For example,
   * replaceBaseTypes() with it gives 'int (*)(int)' for 'enum E (*)(enum EE)' when neither E nor EE is known.
   * --------------------------------------------------------------------- */
  SwigType *intForUnknownEnum(SwigType *base) {
    return (SwigType_isenum(base) && !enumLookup(base)) ? NewString("int") : Copy(base);
  }

  // Look up the 'ctype' typemap of each base type in the type for the fragments it uses, such as "stdbool_inc" for a bool.
  void emitBaseTypeFragments(SwigType *type, Node *file_line_node) {
    ScopedPtr base_types = adopt(NewList());
    append_base_types(type, base_types);
    for (Iterator i = First(base_types); i.item; i = Next(i)) {
      ScopedPtr base_parm = adopt(NewParm(i.item, 0, file_line_node));
      ScopedPtr base_tm = adopt(Swig_typemap_lookup("ctype", base_parm, "", 0));
    }
  }

  /* ---------------------------------------------------------------------
   * make_c_var_decl()
   *
   * Return the C declaration of the variable n, a global variable or a struct member, with the given type, which for a
   * struct member is given by its "type" and "decl" attributes, see emit_c_struct_def().
   *
   * If the variable has a type not representable in C, returns NULL, the caller must check for this!
   *
   * This function accounts for four special cases:
   *  1. If the type is an anonymous enum, "int" is used instead.
   *  2. If the type of a global variable is an array, the bound of its first dimension is stripped, as in 'int x[][4]'
   *     for 'int x[3][4]'. A struct member keeps it, as it gives the size and layout of the struct.
   *  3. A typedef that the header file does not declare is resolved, see resolve_undeclared_typedefs().
   *  4. An enum that SWIG does not know is replaced by "int", see intForUnknownEnum().
   * --------------------------------------------------------------------- */
  String *make_c_var_decl(Node *n, SwigType *type, bool is_struct_member) {
    String *name = Getattr(n, "name");
    String *type_str = SwigType_str(type, 0);
    // the type declared, which SwigType_str() gives with the name inside the declaration, as for a function pointer
    SwigType *decl_type = Copy(type);

    if (Getattr(n, "unnamedinstance")) {
      // If this is an anonymous enum, we can declare the variable as int even though we can't reference this type.
      if (Strncmp(type_str, "enum $", 6) != 0) {
        // Otherwise we're out of luck, with the current approach of exposing the variables directly we simply can't do it, we would need to use accessor
        // functions instead to support this.
        Swig_error(Getfile(n), Getline(n), "Variables of anonymous non-enum types are not supported.\n");
        return SWIG_ERROR;
      }

      const char *const unnamed_end = strchr(Char(type_str) + 6, '$');
      if (!unnamed_end) {
        Swig_error(Getfile(n), Getline(n), "Unsupported anonymous enum type \"%s\".\n", type_str);
        return SWIG_ERROR;
      }

      Delete(decl_type);
      decl_type = SwigType_prefix(type);
      Append(decl_type, "int");
    } else {
      ScopedPtr btype = adopt(SwigType_base(type));
      // Enums are special as they can be unknown, i.e. not wrapped by SWIG, see below
      if (!SwigType_isenum(btype)) {
        // Don't bother with checking if type is representable in C if we're wrapping C and not C++ anyhow: of course it is.
        if (CPlusPlus) {
          if (SwigType_isanyreference(type))
            return NIL;

          if (!SwigType_isbuiltin(btype))
            return NIL;

          // A pointer to member, such as one to a member function returning an int, is not a C type
          ScopedPtr resolved_type = adopt(SwigType_typedef_resolve_all(type));
          if (is_member_pointer_type(resolved_type))
            return NIL;
        }
        Delete(decl_type);
        decl_type = resolve_undeclared_typedefs(type);
      }
    }

    // An enum that is unknown, i.e. not wrapped by SWIG, is not declared in the header file, so we just use int instead,
    // also in the parameters of a function pointer.
    SwigType *const known_enums_type = replaceBaseTypes(decl_type, &C::intForUnknownEnum);
    Delete(decl_type);
    decl_type = known_enums_type;
    emitBaseTypeFragments(decl_type, n);

    if (!is_struct_member && SwigType_isarray(decl_type)) {
      SwigType_array_setdim(decl_type, 0, "");
    }
    String *const var_decl = SwigType_str(decl_type, name);

    Delete(decl_type);
    Delete(type_str);

    return var_decl;
  }

  /* ---------------------------------------------------------------------
   * emit_c_struct_def()
   *
   * Append the declarations of C struct members to the given string.
   * Notice that this function has a side effect of outputting all enum declarations inside the struct into sect_wrappers_types directly.
   * This is done to avoid gcc warnings "declaration does not declare anything" given for the anonymous enums inside the structs.
   * --------------------------------------------------------------------- */

  void emit_c_struct_def(String *out, Node *n) {
    for (Node *node = firstChild(n); node; node = nextSibling(node)) {
      String *const ntype = nodeType(node);
      if (Cmp(ntype, "cdecl") == 0) {
        // The type of a member is given by its "type" and "decl" attributes, as in 'p.f(int).int' for 'int (*fp)(int)'
        ScopedPtr member_type = adopt(NewString(Getattr(node, "type")));
        SwigType_push(member_type, Getattr(node, "decl"));
        ScopedPtr t = adopt(SwigType_typedef_resolve_all(member_type));
        if (SwigType_isfunction(t)) {
          Swig_warning(WARN_C_UNSUPPORTTED, input_file, line_number, "Extending C struct with %s is not currently supported, ignored.\n", SwigType_str(t, 0));
        } else {
          String *const var_decl = make_c_var_decl(node, member_type, true);
          Printv(out, cindent, var_decl, ";\n", NIL);
          Delete(var_decl);
        }
      } else if (Cmp(ntype, "enum") == 0) {
        // This goes directly into sect_wrappers_types, before this struct declaration.
        emit_one(node);
      } else {
        // WARNING: proxy declaration can be different than original code
        if (Cmp(nodeType(node), "extend") == 0)
          emit_c_struct_def(out, node);
      }
    }
  }

  /* ---------------------------------------------------------------------
   * classDeclaration()
   * --------------------------------------------------------------------- */

  virtual int classDeclaration(Node *n) {
    if (Cmp(Getattr(n, "name"), "SWIG_CException") == 0) {
      // Ignore this class only if it was already wrapped in another module, imported from this one (if exceptions are disabled, we shouldn't be even parsing
      // SWIG_CException in the first place and if they're enabled, we handle it normally).
      if (exceptions_support_ == exceptions_support_imported)
        return SWIG_NOWRAP;
    }

    return Language::classDeclaration(n);
  }

  /* ---------------------------------------------------------------------
   * classHandler()
   * --------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {
    String *const name = get_c_proxy_name(n);

    if (CPlusPlus) {
      CxxClassWrapper cxx_class_wrapper_obj(cxx_wrappers_, n);
      TempPtrSetter<CxxClassWrapper *> set_cxx_class_wrapper(&cxx_class_wrapper_, &cxx_class_wrapper_obj);

      // inheritance support: attach all members from base classes to this class
      if (List *baselist = Getattr(n, "bases")) {
        Iterator i;
        for (i = First(baselist); i.item; i = Next(i)) {
          // look for member variables and functions
          Node *node;
          for (node = firstChild(i.item); node; node = nextSibling(node)) {
            if ((Cmp(Getattr(node, "kind"), "variable") == 0) || (Cmp(Getattr(node, "kind"), "function") == 0)) {
              if ((Cmp(Getattr(node, "access"), "public") == 0) && (Cmp(Getattr(node, "storage"), "static") != 0)) {
                // Assignment operators are not inherited in C++ and symbols without sym:name should be ignored, not copied into the derived class.
                if (Getattr(node, "sym:name") && Cmp(Getattr(node, "name"), "operator =") != 0) {
                  String *parent_name = Getattr(parentNode(node), "name");
                  Hash *dupl_name_node = is_in(Getattr(node, "name"), n);
                  // if there's a duplicate inherited name, due to the C++ multiple
                  // inheritance, change both names to avoid ambiguity
                  if (dupl_name_node) {
                    String *cif = Getattr(dupl_name_node, "c:inherited_from");
                    String *old_name = Getattr(dupl_name_node, "sym:name");
                    if (cif && parent_name && (Cmp(cif, parent_name) != 0)) {
                      Setattr(dupl_name_node, "sym:name", NewStringf("%s%s", cif ? cif : "", old_name));
                      Setattr(dupl_name_node, "c:base_name", old_name);
                      Node *new_node = copy_node(node);
                      Setattr(new_node, "name", NewStringf("%s%s", parent_name, old_name));
                      Setattr(new_node, "c:base_name", old_name);
                      appendChild(n, new_node);
                    }
                  } else {
                    appendChild(n, copy_node(node));
                  }
                }
              }
            }
          }
        }
      }

      // declare type for specific class in the proxy header
      Printv(sect_wrappers_types, "typedef struct SwigObj_", name, " ", name, ";\n\n", NIL);

      return Language::classHandler(n);
    } else {
      // this is a C struct or union, declare it in the proxy as in the original code, as the wrappers use the original type
      String *struct_def = NewStringEmpty();
      String *const tdname = Getattr(n, "tdname");
      if (tdname)
        Append(struct_def, "typedef ");
      Append(struct_def, Getattr(n, "kind"));
      if (!Getattr(n, "unnamed"))
        Printv(struct_def, " ", Getattr(n, "name"), NIL);
      Append(struct_def, " {\n");
      emit_c_struct_def(struct_def, n);
      Append(struct_def, "}");
      if (tdname)
        Printv(struct_def, " ", tdname, NIL);
      Append(struct_def, ";\n\n");

      Printv(sect_wrappers_types, struct_def, NIL);
      Delete(struct_def);
    }
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * staticmembervariableHandler()
   * --------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {
    SwigType *type = Getattr(n, "type");
    SwigType *tdtype = SwigType_typedef_resolve_all(type);
    if (tdtype) {
      type = tdtype;
      Setattr(n, "type", type);
    }
    Delete(type);
    return Language::staticmembervariableHandler(n);
  }

  /* ---------------------------------------------------------------------
   * membervariableHandler()
   * --------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {
    SwigType *type = Getattr(n, "type");
    SwigType *tdtype = SwigType_typedef_resolve_all(type);
    if (tdtype) {
      type = tdtype;
      Setattr(n, "type", type);
    }
    Delete(type);
    return Language::membervariableHandler(n);
  }

  /* ---------------------------------------------------------------------
   * constructorHandler()
   * --------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {
    // For some reason, the base class implementation of constructorDeclaration() only takes care of the copy ctor automatically for the languages not
    // supporting overloading (i.e. not calling allow_overloading(), as we do). So duplicate the relevant part of its code here,
    if (!Abstract && Getattr(n, "copy_constructor")) {
      return Language::copyconstructorHandler(n);
    }

    if (GetFlag(n, "feature:extend")) {
      // Pretend that all ctors added via %extend are overloaded to avoid clash between the functions created for them and the actual exported function, that
      // could have the same "Foo_new" name otherwise.
      SetFlag(n, "sym:overloaded");
    }

    return Language::constructorHandler(n);
  }

  /* ----------------------------------------------------------------------
   * Language::enumforwardDeclaration()
   * ---------------------------------------------------------------------- */

  virtual int enumforwardDeclaration(Node *n) {
    // Base implementation of this function calls enumDeclaration() for "missing" enums, i.e. those without any definition at all. This results in invalid (at
    // least in C++) enum declarations in the output, so simply don't do this here.
    (void)n;
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * enumDeclaration()
   * --------------------------------------------------------------------- */

  virtual int enumDeclaration(Node *n) {
    if (ImportMode)
      return SWIG_OK;

    if (getCurrentClass() && (cplus_mode != PUBLIC))
      return SWIG_NOWRAP;

    // We don't know here if we're going to have any non-ignored enum elements, so generate enum declaration in a temporary string.
    enum_decl = NewStringEmpty();

    // Another string for C++ enum declaration, which differs from the C one because it never uses the prefix, as C++ enums are declared in the correct scope.
    cxx_enum_decl = cxx_wrappers_.is_initialized() ? NewStringEmpty() : NULL;

    // If we're currently generating a wrapper class, we need an extra level of indent.
    if (cxx_enum_decl) {
      if (cxx_class_wrapper_) {
        cxx_enum_indent = cxx_class_wrapper_->get_indent();
        Append(cxx_enum_decl, cxx_enum_indent);
      } else {
        cxx_enum_indent = "";
      }
    }

    String *const symname = Getattr(n, "sym:name");

    // Preserve the typedef if we have it in the input.
    bool const is_typedef = Checkattr(n, "allows_typedef", "1");
    if (is_typedef) {
      Printv(enum_decl, "typedef ", NIL);
      if (cxx_enum_decl)
        Printv(cxx_enum_decl, "typedef ", NIL);
    }
    Printv(enum_decl, "enum", NIL);
    if (cxx_enum_decl)
      Printv(cxx_enum_decl, "enum", NIL);

    String *enum_prefix;
    if (Node *const klass = getCurrentClass()) {
      enum_prefix = get_c_proxy_name(klass);
    } else {
      enum_prefix = ns_prefix;  // Possibly NULL, but that's fine.
    }

    // C++ enum names don't use the prefix, as they're defined in namespace or class scope.
    String *cxx_enum_prefix = NULL;

    ScopedPtr enumname;
    ScopedPtr cxx_enumname;

    // Unnamed enums may just have no name at all or have a synthesized invalid name of the form "$unnamedN$ which is indicated by "unnamed" attribute.
    if (String *const name = Getattr(n, "unnamed") ? NULL : symname) {
      // If it's a typedef, its sym:name is the typedef name, but we don't want to use it here (we already use it for the typedef we generate), so use the
      // actual C++ name instead.
      if (is_typedef) {
        // But the name may include the containing class, so get rid of it.
        enumname = Swig_scopename_last(Getattr(n, "name"));
      } else {
        enumname = Copy(name);
      }

      const bool scoped_enum = Checkattr(n, "scopedenum", "1");

      if (cxx_enum_decl) {
        // In C++ we can use actual scoped enums instead of emulating them with element prefixes.
        if (scoped_enum)
          Printv(cxx_enum_decl, " class", NIL);

        // And enum name itself shouldn't include the prefix neither, as this enum is either inside a namespace or inside a class, so use enumname before it
        // gets updated below.
        Printv(cxx_enum_decl, " ", enumname.get(), NIL);
      }

      if (enum_prefix) {
        enumname = NewStringf("%s_%s", enum_prefix, enumname.get());
      }

      Printv(enum_decl, " ", enumname.get(), NIL);
      if (cxx_enum_decl)
        Printv(cxx_enum_decl, " ", cxx_enumname.get(), NIL);

      // For scoped enums, their name should be prefixed to their elements in addition to any other prefix we use.
      if (scoped_enum) {
        enum_prefix = enumname.get();
        cxx_enum_prefix = cxx_enumname.get();
      }
    }

    enum_prefix_ = enum_prefix ? NewStringf("%s_", enum_prefix) : NewStringEmpty();
    cxx_enum_prefix_ = cxx_enum_prefix ? NewStringf("%s_", cxx_enum_prefix) : NewStringEmpty();

    Printv(enum_decl, " {\n", NIL);
    if (cxx_enum_decl)
      Printv(cxx_enum_decl, " {\n", NIL);

    int const len_orig = Len(enum_decl);

    // Emit each enum item.
    Language::enumDeclaration(n);

    // Only emit the enum declaration if there were actually any items.
    if (Len(enum_decl) > len_orig) {
      Printv(enum_decl, "\n}", NIL);
      if (cxx_enum_decl)
        Printv(cxx_enum_decl, "\n", cxx_enum_indent, "}", NIL);

      if (is_typedef) {
        Printv(enum_decl, " ", enum_prefix_.get(), symname, NIL);
        if (cxx_enum_decl)
          Printv(cxx_enum_decl, " ", symname, NIL);
      }
      Printv(enum_decl, ";\n\n", NIL);
      if (cxx_enum_decl)
        Printv(cxx_enum_decl, ";\n\n", NIL);

      Append(sect_wrappers_types, enum_decl);
      if (cxx_enum_decl) {
        // Enums declared in global scopes can be just defined before everything else, but nested enums have to be defined inside the declaration of the class,
        // which we must be in process of creating, so output them in the appropriate section.
        Append(cxx_class_wrapper_ ? cxx_wrappers_.sect_decls : cxx_wrappers_.sect_types, cxx_enum_decl);
      }
    }

    Delete(enum_decl);
    if (cxx_enum_decl)
      Delete(cxx_enum_decl);

    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * enumvalueDeclaration()
   * --------------------------------------------------------------------- */

  virtual int enumvalueDeclaration(Node *n) {
    if (Cmp(Getattr(n, "ismember"), "1") == 0 && Cmp(Getattr(n, "access"), "public") != 0)
      return SWIG_NOWRAP;
    Swig_require("enumvalueDeclaration", n, "?enumvalueex", "?enumvalue", NIL);

    if (!GetFlag(n, "firstenumitem")) {
      Printv(enum_decl, ",\n", NIL);
      if (cxx_enum_decl)
        Printv(cxx_enum_decl, ",\n", NIL);
    }

    String *const symname = Getattr(n, "sym:name");
    Printv(enum_decl, cindent, enum_prefix_.get(), symname, NIL);
    if (cxx_enum_decl)
      Printv(cxx_enum_decl, cxx_enum_indent, cindent, cxx_enum_prefix_.get(), symname, NIL);

    // We only use "enumvalue", which comes from the input, and not "enumvalueex" synthesized by SWIG itself because C should use the correct value for the enum
    // items without an explicit one anyhow (and "enumvalueex" can't be always used as is in C code for enum elements inside a class or even a namespace).
    String *value = Getattr(n, "enumvalue");
    if (value) {
      // We can't always use the raw value, check its type to see if we need to transform it.
      MaybeOwnedPtr cvalue;
      switch (SwigType_type(Getattr(n, "type"))) {
      case T_BOOL:
        // Boolean constants can't appear in C code, so replace them with their values in the simplest possible case. This is not exhaustive, of course,
        // but better than nothing and doing the right thing is not simple at all as we'd need to really parse the expression, just textual substitution
        // wouldn't be enough (consider e.g. an enum element called "very_true" and another one using it as its value).
        if (Cmp(value, "true") == 0) {
          cvalue.assign_owned(NewString("1"));
        } else if (Cmp(value, "false") == 0) {
          cvalue.assign_owned(NewString("0"));
        } else {
          Swig_error(Getfile(n), Getline(n), "Unsupported boolean enum value \"%s\".\n", value);
        }
        break;
      default:
        cvalue.assign_non_owned(value);
      }

      Printv(enum_decl, " = ", cvalue.get(), NIL);
      if (cxx_enum_decl)
        Printv(cxx_enum_decl, " = ", cvalue.get(), NIL);
    }

    Swig_restore(n);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * constantWrapper()
   * --------------------------------------------------------------------- */

  virtual int constantWrapper(Node *n) {
    // A pointer to member constant is wrapped by a getter function, as an immutable variable is, since C code cannot use its value, such as '&Foo::bar'
    ScopedPtr resolved_type = adopt(SwigType_typedef_resolve_all(Getattr(n, "type")));
    if (is_member_pointer_type(resolved_type)) {
      SetFlag(n, "feature:immutable");
      return globalvariableHandler(n);
    }

    String *name = Getattr(n, "sym:name");
    // We use the "value" and hope that it will work in C as well as in C++.
    String *value = Getattr(n, "value");
    Printv(sect_wrappers_decl, "#define ", name, " ", value, "\n", NIL);
    return SWIG_OK;
  }
}; /* class C */

/* -----------------------------------------------------------------------------
 * swig_c()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_c() {
  return new C();
}

extern "C" Language *swig_c(void) {
  return new_swig_c();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *C::usage = "\
C Options (available with -c)\n\
     -namespace ns   - use prefix based on the provided namespace\n\
     -nocxx          - do not generate C++ wrappers\n\
     -noexcept       - do not generate exception handling code\n\
\n";

/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.cxx
 *
 * C language module for SWIG.
 * ----------------------------------------------------------------------------- */

#include <ctype.h>
#include "swigmod.h"

int SwigType_isbuiltin(SwigType *t) {
  const char* builtins[] = { "void", "short", "int", "long", "char", "float", "double", "bool", 0 };
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
namespace
{

// Delete a DOH object on scope exit.
class scoped_dohptr
{
public:
  scoped_dohptr() : obj_(NULL) {}
  explicit scoped_dohptr(DOH* obj) : obj_(obj) {}
  ~scoped_dohptr() { Delete(obj_); }

  // This is an std::auto_ptr<>-like "destructive" copy ctor which allows to return objects of this type from functions.
  scoped_dohptr(scoped_dohptr const& other) : obj_(other.release()) {}

  // Same for the assignment operator.
  scoped_dohptr& operator=(scoped_dohptr const& other) {
    reset(other.release());

    return *this;
  }

  // Assignment operator takes ownership of the pointer, just as the ctor does.
  scoped_dohptr& operator=(DOH* obj) {
    reset(obj);

    return *this;
  }

  DOH* get() const { return obj_; }

  DOH* release() const /* not really */ {
    DOH* obj = obj_;
    const_cast<DOH*&>(const_cast<scoped_dohptr*>(this)->obj_) = NULL;
    return obj;
  }

  void reset(DOH* obj = NULL) {
    if (obj != obj_) {
      Delete(obj_);
      obj_ = obj;
    }
  }

  operator DOH*() const { return obj_; }

protected:
  DOH* obj_;
};

// Wrapper for a DOH object which can be owned or not.
class maybe_owned_dohptr : public scoped_dohptr
{
public:
  explicit maybe_owned_dohptr(DOH* obj = NULL) : scoped_dohptr(obj), owned_(true) {}

  maybe_owned_dohptr(maybe_owned_dohptr const& other) : scoped_dohptr(other) {
    owned_ = other.owned_;

    // We can live other.owned_ unchanged, as its pointer is null now anyhow.
  }

  maybe_owned_dohptr& operator=(maybe_owned_dohptr const& other) {
    reset(other.release());
    owned_ = other.owned_;

    return *this;
  }

  ~maybe_owned_dohptr() {
    if (!owned_)
      obj_ = NULL; // Prevent it from being deleted by the base class dtor.
  }

  void assign_owned(DOH* obj) {
    reset(obj);
  }

  void assign_non_owned(DOH* obj) {
    reset(obj);
    owned_ = false;
  }

private:
  bool owned_;
};

// Helper class to output "begin" fragment in the ctor and "end" in the dtor.
class begin_end_output_guard
{
public:
  begin_end_output_guard(File* f, const_String_or_char_ptr begin, const_String_or_char_ptr end)
    : f_(f),
      end_(NewString(end))
  {
    String* const s = NewString(begin);
    Dump(s, f_);
    Delete(s);
  }

  ~begin_end_output_guard()
  {
    Dump(end_, f_);
    Delete(end_);
  }

private:
  // Non copyable.
  begin_end_output_guard(const begin_end_output_guard&);
  begin_end_output_guard& operator=(const begin_end_output_guard&);

  File* const f_;
  String* const end_;
};

// Subclass to output extern "C" guards when compiling as C++.
class cplusplus_output_guard : private begin_end_output_guard
{
public:
  explicit cplusplus_output_guard(File* f)
    : begin_end_output_guard(
        f,
        "#ifdef __cplusplus\n"
        "extern \"C\" {\n"
        "#endif\n\n",
        "#ifdef __cplusplus\n"
        "}\n"
        "#endif\n\n"
      )
  {
  }
};

// String containing one indentation level for the generated code.
const char* const cindent = "  ";

} // anonymous namespace

class C:public Language {
  static const char *usage;

  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_wrappers_cxx;
  File *f_wrappers_types;
  File *f_wrappers_decl;
  File *f_wrappers_aliases;
  File *f_init;

  String *empty_string;

  // Prefix for module-level symbols, currently just the module name.
  String *module_prefix;

  // Used only while generating wrappers for an enum, initially true and reset to false as soon as we see any enum elements.
  bool enum_is_empty;

  // Selects between the wrappers (public) declarations and (private) definitions.
  enum {
    output_wrapper_decl,
    output_wrapper_def
  } current_output;

public:

  /* -----------------------------------------------------------------------------
   * C()
   * ----------------------------------------------------------------------------- */

  C() :
    empty_string(NewString("")),
    module_prefix(NULL)
  {
  }

  ~C()
  {
    Delete(module_prefix);
  }

  // Return the name to be used in proxy code and cache it as "proxyname".
  String *getProxyName(Node *n)
  {
     if (!n)
      return 0;

     String *proxyname = NULL;
     if ((proxyname = Getattr(n, "proxyname")))
      return Copy(proxyname);

     String *symname = Getattr(n, "sym:name");
     String *nspace = Getattr(n, "sym:nspace");

     if (nspace) {
       scoped_dohptr nspace_mangled(Swig_string_mangle(nspace));
       proxyname = NewStringf("%s_%s", (DOH*)nspace_mangled, symname);
     } else {
       proxyname = Copy(symname);
     }
     Setattr(n, "proxyname", proxyname);

     return proxyname;
  }

  // Construct the name to be used for a function with the given name in C wrappers.
  //
  // The returned string must be freed by caller.
  maybe_owned_dohptr getFunctionWrapperName(Node *n, String *name) const
  {
    maybe_owned_dohptr wname;

    // For class members we don't need to use any prefix at all, as they're already prefixed by the class name, which has the appropriate prefix.
    if (!GetFlag(n, "c:globalfun")) {
      wname.assign_non_owned(name);
      return wname;
    }

    // Use namespace as the prefix if feature:nspace is in use.
    scoped_dohptr scopename_prefix;
    if (GetFlag(parentNode(n), "feature:nspace")) {
      scopename_prefix = Swig_scopename_prefix(Getattr(n, "name"));
      if (scopename_prefix) {
	scoped_dohptr mangled_prefix(Swig_string_mangle(scopename_prefix));
	scopename_prefix = mangled_prefix;
      }
    }

    // Fall back to the module name if we don't use feature:nspace or are outside of any namespace.
    //
    // Note that we really, really need to use some prefix, as a global wrapper function can't have the same name as the original function (being wrapped) with
    // the same name.
    String* const prefix = scopename_prefix ? scopename_prefix : module_prefix;

    wname.assign_owned(NewStringf("%s_%s", prefix, name));
    return wname;
  }

  /* -----------------------------------------------------------------------------
   * getClassProxyName()
   *
   * Test to see if a type corresponds to something wrapped with a proxy class.
   * Return NULL if not, otherwise the proxy class name to be freed by the caller.
   * ----------------------------------------------------------------------------- */

   String *getClassProxyName(SwigType *t) {
     Node *n = classLookup(t);

    return n ? getProxyName(n) : NULL;

   }

  /* -----------------------------------------------------------------------------
   * getEnumName()
   *
   * Return the name to use for the enum in the generated code.
   * Also caches it in the node for subsequent access.
   * Returns NULL if the node doesn't correspond to an enum.
   * ----------------------------------------------------------------------------- */

  String *getEnumName(Node *n) {
    String *enumname = NULL;
    if (n) {
      enumname = Getattr(n, "enumname");
      if (!enumname) {
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
	    enumname = getProxyName(n);
          }
          Setattr(n, "enumname", enumname);
          Delete(enumname);
        }
      }
    }

    return enumname;
  }


  /* -----------------------------------------------------------------------------
   * substituteResolvedTypeSpecialVariable()
   * ----------------------------------------------------------------------------- */

  void substituteResolvedTypeSpecialVariable(SwigType *classnametype, String *tm, const char *classnamespecialvariable) {
    if (!CPlusPlus) {
      // Just use the original C type when not using C++, we know that this type can be used in the wrappers.
      Clear(tm);
      String* const s = SwigType_str(classnametype, 0);
      Append(tm, s);
      Delete(s);
      return;
    }

    if (SwigType_isenum(classnametype)) {
      String *enumname = getEnumName(enumLookup(classnametype));
      if (enumname)
	Replaceall(tm, classnamespecialvariable, enumname);
      else
	Replaceall(tm, classnamespecialvariable, NewStringf("int"));
    } else {
      scoped_dohptr btype(SwigType_base(classnametype));
      String* typestr = NIL;
      if (current_output == output_wrapper_def || Cmp(btype, "SwigObj") == 0) {
	// Special case, just leave it unchanged.
	typestr = NewString("SwigObj");
      } else {
	typestr = getClassProxyName(classnametype);
	if (!typestr) {
	  if (SwigType_isbuiltin(btype)) {
	    // This should work just as well in C without any changes.
	    typestr = SwigType_str(classnametype, 0);
	  } else {
	    // Swig doesn't know anything about this type, use descriptor for it.
	    typestr = NewStringf("SWIGTYPE%s", SwigType_manglestr(classnametype));

	    // And make sure it is declared before it is used.
	    Printf(f_wrappers_types, "typedef struct %s %s;\n\n", typestr, typestr);
	  }
	}
      }

      Replaceall(tm, classnamespecialvariable, typestr);
      Delete(typestr);
    }
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
   * Outputs:
   *   tm - typemap contents complete with the special variable substitution
   * ----------------------------------------------------------------------------- */

  void substituteResolvedType(SwigType *pt, String *tm) {
    SwigType *type = SwigType_typedef_resolve_all(pt);
    SwigType *strippedtype = SwigType_strip_qualifiers(type);

    if (Strstr(tm, "$resolved_type")) {
      SwigType *classnametype = Copy(strippedtype);
      substituteResolvedTypeSpecialVariable(classnametype, tm, "$resolved_type");
      Delete(classnametype);
    }
    if (Strstr(tm, "$*resolved_type")) {
      SwigType *classnametype = Copy(strippedtype);
      Delete(SwigType_pop(classnametype));
      if (Len(classnametype) > 0) {
	substituteResolvedTypeSpecialVariable(classnametype, tm, "$*resolved_type");
      }
      Delete(classnametype);
    }
    if (Strstr(tm, "$&resolved_type")) {
      SwigType *classnametype = Copy(strippedtype);
      SwigType_add_pointer(classnametype);
      substituteResolvedTypeSpecialVariable(classnametype, tm, "$&resolved_type");
      Delete(classnametype);
    }

    Delete(strippedtype);
    Delete(type);
  }

  /*----------------------------------------------------------------------
   * replaceSpecialVariables()
   *
   * Override the base class method to ensure that $resolved_type is expanded correctly inside $typemap().
   *--------------------------------------------------------------------*/

  virtual void replaceSpecialVariables(String *method, String *tm, Parm *parm) {
    (void)method;
    SwigType *type = Getattr(parm, "type");
    substituteResolvedType(type, tm);
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {
    bool except_flag = CPlusPlus;

    // look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
        if (strcmp(argv[i], "-help") == 0) {
          Printf(stdout, "%s\n", usage);
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

    SWIG_library_directory("c");

    // add typemap definitions
    SWIG_typemap_lang("c");
    SWIG_config_file("c.swg");

    // The default naming convention is to use new_Foo(), copy_Foo() and delete_Foo() for the default/copy ctor and dtor of the class Foo, but we prefer to
    // start all Foo methods with the same prefix, so change this. Notice that new/delete are chosen to ensure that we avoid conflicts with the existing class
    // methods, more natural create/destroy, for example, could result in errors if the class already had a method with the same name, but this is impossible
    // for the chosen names as they're keywords in C++ ("copy" is still a problem but we'll just have to live with it).
    Swig_name_register("construct", "%n%c_new");
    Swig_name_register("copy", "%n%c_copy");
    Swig_name_register("destroy", "%n%c_delete");

    allow_overloading();
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {
    String *module = Getattr(n, "name");
    module_prefix = Copy(module);
    String *outfile = Getattr(n, "outfile");

    // initialize I/O
    f_begin = NewFile(outfile, "w", SWIG_output_files());
    if (!f_begin) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_runtime = NewString("");
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_wrappers_cxx = NewString("");

    Swig_banner(f_begin);

    // Open the file where all wrapper declarations will be written to in the end.
    String* const outfile_h = Getattr(n, "outfile_h");
    File* const f_wrappers_h = NewFile(outfile_h, "w", SWIG_output_files());
    if (!f_wrappers_h) {
      FileErrorDisplay(outfile_h);
        SWIG_exit(EXIT_FAILURE);
      }

    Swig_banner(f_wrappers_h);

    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);
    Swig_register_filebyname("cheader", f_wrappers_h);

    {
      String* const include_guard_name = NewStringf("SWIG_%s_WRAP_H_", Char(module));
      String* const include_guard_begin = NewStringf(
          "#ifndef %s\n"
          "#define %s\n\n",
          include_guard_name,
          include_guard_name
        );
      String* const include_guard_end = NewStringf(
          "\n"
          "#endif /* %s */\n",
          include_guard_name
        );

      begin_end_output_guard
        include_guard_wrappers_h(f_wrappers_h, include_guard_begin, include_guard_end);

      // All the struct types used by the functions go to f_wrappers_types so that they're certain to be defined before they're used by any functions. All the
      // functions declarations go directly to f_wrappers_decl and f_wrappers_h_body combines both of them.
      String* const f_wrappers_h_body = NewString("");
      f_wrappers_types = NewString("");
      f_wrappers_decl = NewString("");

      // We may also define aliases for the global wrapper functions to allow calling them using their original names, but as this can result in problems (as
      // usual when using the preprocessor), this is only done when SWIG_DEFINE_WRAPPER_ALIASES is defined, so use a separate section for this.
      f_wrappers_aliases = NIL;

      {

        cplusplus_output_guard
          cplusplus_guard_wrappers(f_wrappers),
          cplusplus_guard_wrappers_h(f_wrappers_h_body);

        // emit code for children
        Language::top(n);

        Dump(f_wrappers_types, f_wrappers_h_body);
        Delete(f_wrappers_types);

        Dump(f_wrappers_decl, f_wrappers_h_body);
        Delete(f_wrappers_decl);
      } // close extern "C" guards

      Dump(f_wrappers_h_body, f_wrappers_h);
      Delete(f_wrappers_h_body);

      if (f_wrappers_aliases) {
	Dump(f_wrappers_aliases, f_wrappers_h);
	Delete(f_wrappers_aliases);

	Printv(f_wrappers_h, "#endif /* SWIG_DEFINE_WRAPPER_ALIASES */\n", NIL);
      }
    } // close wrapper header guard

    // write all to the file
    Dump(f_header, f_runtime);
    Dump(f_wrappers_cxx, f_runtime);
    Wrapper_pretty_print(f_wrappers, f_runtime);
    Dump(f_init, f_runtime);
    Dump(f_runtime, f_begin);

    // cleanup
    Delete(f_begin);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_wrappers_cxx);
    Delete(f_wrappers_h);
    Delete(f_init);
    Delete(f_runtime);

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalvariableHandler(Node *n) {
    // Don't export static globals, they won't be accessible when using a shared library, for example.
    if (Checkattr(n, "storage", "static"))
      return SWIG_NOWRAP;

    // We can't export variables defined inside namespaces to C directly, whatever their type.
    String* const scope = Swig_scopename_prefix(Getattr(n, "name"));
    if (!scope) {
      // If we can export the variable directly, do it, this will be more convenient to use from C code than accessor functions.
      if (String* const var_decl = make_c_var_decl(n)) {
	Printv(f_wrappers_decl, "SWIGIMPORT ", var_decl, ";\n\n", NIL);
	Delete(var_decl);
	return SWIG_OK;
      }
    } else {
      Delete(scope);
    }

    // Otherwise, e.g. if it's of a C++-only type, or a reference, generate accessor functions for it.
    return Language::globalvariableHandler(n);
  }

  /* -----------------------------------------------------------------------
   * globalfunctionHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalfunctionHandler(Node *n) {
    SwigType *type = Getattr(n, "type");

    Setattr(n, "c:globalfun", "1");

    if (!SwigType_ispointer(type) && !SwigType_isreference(type))
      Setattr(n, "c:retval", "1");

    return Language::globalfunctionHandler(n);
  }

  /* ----------------------------------------------------------------------
   * prepend_feature()
   * ---------------------------------------------------------------------- */

  String* prepend_feature(Node *n) {
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

  String* append_feature(Node *n) {
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
   * get_mangled_type()
   * ---------------------------------------------------------------------- */

  String *get_mangled_type(SwigType *type_arg) {
    String *result = NewString("");
    SwigType *type = 0;
    SwigType *tdtype = SwigType_typedef_resolve_all(type_arg);
    if (tdtype)
      type = tdtype;
    else
      type = Copy(type_arg);

    // special cases for ptr to function as an argument
    if (SwigType_ismemberpointer(type)) {
      SwigType_del_memberpointer(type);
      SwigType_add_pointer(type);
    }
    if (SwigType_ispointer(type)) {
      SwigType_del_pointer(type);
      if (SwigType_isfunction(type)) {
        Printf(result, "f");
	Delete(type);
	return result;
      }
      Delete(type);
      type = Copy(type_arg);
    }

    SwigType *prefix = SwigType_prefix(type);
    if (Len(prefix)) {
      Replaceall(prefix, ".", "");
      Replaceall(prefix, "const", "c");
      Replaceall(prefix, "volatile", "v");
      Replaceall(prefix, "a(", "a");
      Replaceall(prefix, "m(", "m");
      Replaceall(prefix, "q(", "");
      Replaceall(prefix, ")", "");
      Replaceall(prefix, " ", "");
      Printf(result, "%s", prefix);
    }

    type = SwigType_base(type);
    if (SwigType_isbuiltin(type)) {
      Printf(result, "%c", *Char(SwigType_base(type)));
    } else if (SwigType_isenum(type)) {
      String* enumname = Swig_scopename_last(type);
      const char* s = Char(enumname);
      static const int len_enum_prefix = strlen("enum ");
      if (strncmp(s, "enum ", len_enum_prefix) == 0)
	s += len_enum_prefix;
      Printf(result, "e%s", s);
    } else {
      Printf(result, "%s", Char(Swig_name_mangle(SwigType_base(type))));
    }

    Delete(prefix);
    Delete(type);

    return result;
  }

  void functionWrapperCSpecific(Node *n)
    {
       // this is C function, we don't apply typemaps to it
       String *name = Getattr(n, "sym:name");
       maybe_owned_dohptr wname = getFunctionWrapperName(n, name);
       SwigType *type = Getattr(n, "type");
       SwigType *return_type = NULL;
       String *arg_names = NULL;
       ParmList *parms = Getattr(n, "parms");
       Parm *p;
       String *proto = NewString("");
       int gencomma = 0;
       bool is_void_return = (SwigType_type(type) == T_VOID);

       // create new function wrapper object
       Wrapper *wrapper = NewWrapper();

       // create new wrapper name
       Setattr(n, "wrap:name", wname); //Necessary to set this attribute? Apparently, it's never read!

       // create function call
       arg_names = Swig_cfunction_call(empty_string, parms);
       if (arg_names) {
            Delitem(arg_names, 0);
            Delitem(arg_names, DOH_END);
       }
       return_type = SwigType_str(type, 0);

       // emit wrapper prototype and code
       for (p = parms, gencomma = 0; p; p = nextSibling(p)) {
            Printv(proto, gencomma ? ", " : "", SwigType_str(Getattr(p, "type"), 0), " ", Getattr(p, "lname"), NIL);
            gencomma = 1;
       }
       Printv(wrapper->def, return_type, " ", wname.get(), "(", proto, ") {\n", NIL);

       // attach 'check' typemaps
       Swig_typemap_attach_parms("check", parms, wrapper);

       // insert constraint checking
       for (p = parms; p; ) {
            String *tm;
            if ((tm = Getattr(p, "tmap:check"))) {
                 Replaceall(tm, "$target", Getattr(p, "lname"));
                 Replaceall(tm, "$name", name);
                 Printv(wrapper->code, tm, "\n", NIL);
                 p = Getattr(p, "tmap:check:next");
            } else {
                 p = nextSibling(p);
            }
       }

       Append(wrapper->code, prepend_feature(n));
       if (!is_void_return) {
            Printv(wrapper->code, return_type, " result;\n", NIL);
            Printf(wrapper->code, "result = ");
       }
       Printv(wrapper->code, Getattr(n, "name"), "(", arg_names, ");\n", NIL);
       Append(wrapper->code, append_feature(n));
       if (!is_void_return)
         Printf(wrapper->code, "return result;\n");
       Printf(wrapper->code, "}");

       Wrapper_print(wrapper, f_wrappers);

       emit_wrapper_func_decl(n, name);

       // cleanup
       Delete(proto);
       Delete(arg_names);
       Delete(return_type);
       DelWrapper(wrapper);
    }

  static void functionWrapperPrepareArgs(const ParmList *parms)
    {
       Parm *p;
       int index = 1;
       String *lname = 0;

       for (p = (Parm*)parms, index = 1; p; (p = nextSibling(p)), index++) {
            if(!(lname = Getattr(p, "lname"))) {
                 lname = NewStringf("arg%d", index);
                 Setattr(p, "lname", lname);
            }
       }
    }

  void functionWrapperAppendOverloaded(String *name, Parm* first_param)
    {
       String *over_suffix = NewString("");
       Parm *p;
       String *mangled;

       for (p = first_param; p; p = nextSibling(p)) {
            mangled = get_mangled_type(Getattr(p, "type"));
            Printv(over_suffix, "_", mangled, NIL);
       }
       Append(name, over_suffix);
       Delete(over_suffix);
    }

  String *get_wrapper_func_return_type(Node *n)
    {
      SwigType *type = Getattr(n, "type");
      String *return_type;

      if ((return_type = Swig_typemap_lookup("ctype", n, "", 0))) {
	substituteResolvedType(type, return_type);
      } else {
	Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(type, 0));
	return_type = NewString("");
      }

      Replaceall(return_type, "::", "_");

      return return_type;
    }

  /* ----------------------------------------------------------------------
   * get_wrapper_func_proto()
   *
   * Return the function signature, i.e. the comma-separated list of argument types and names surrounded by parentheses.
   * If a non-null wrapper is specified, it is used to emit typemap-defined code in it and it also determines whether we're generating the prototype for the
   * declarations or the definitions, which changes the type used for the C++ objects.
   * ---------------------------------------------------------------------- */
  scoped_dohptr get_wrapper_func_proto(Node *n, Wrapper* wrapper = NULL)
    {
       ParmList *parms = Getattr(n, "parms");

       Parm *p;
       String *proto = NewString("(");
       int gencomma = 0;

       // attach the standard typemaps
       if (wrapper) {
	 emit_attach_parmmaps(parms, wrapper);
       } else {
	 // We can't call emit_attach_parmmaps() without a wrapper, it would just crash.
	 // Attach "in" manually, we need it for tmap:in:numinputs below.
	 Swig_typemap_attach_parms("in", parms, 0);
       }
       Setattr(n, "wrap:parms", parms); //never read again?!

       // attach 'ctype' typemaps
       Swig_typemap_attach_parms("ctype", parms, 0);


       // prepare function definition
       for (p = parms, gencomma = 0; p; ) {
            String *tm;
            SwigType *type = NULL;

            while (p && checkAttribute(p, "tmap:in:numinputs", "0")) {
                 p = Getattr(p, "tmap:in:next");
            }
            if (!p) break;

            type = Getattr(p, "type");
            if (SwigType_type(type) == T_VOID) {
                 p = nextSibling(p);
                 continue;
            }

	    if (SwigType_type(type) == T_VARARGS) {
	      Swig_error(Getfile(n), Getline(n), "Vararg function %s not supported.\n", Getattr(n, "name"));
	      return scoped_dohptr(NULL);
	    }

            String *lname = Getattr(p, "lname");
            String *c_parm_type = 0;
            String *arg_name = NewString("");

            Printf(arg_name, "c%s", lname);

	    if ((tm = Getattr(p, "tmap:ctype"))) { // set the appropriate type for parameter
		 c_parm_type = Copy(tm);
		 substituteResolvedType(type, c_parm_type);

		 // We prefer to keep typedefs in the wrapper functions signatures as it makes them more readable, but we can't do it for nested typedefs as
		 // they're not valid in C, so resolve them in this case.
		 if (strstr(Char(c_parm_type), "::")) {
		   SwigType* const tdtype = SwigType_typedef_resolve_all(c_parm_type);
		   Delete(c_parm_type);
		   c_parm_type = tdtype;
		 }

		 // template handling
		 Replaceall(c_parm_type, "$tt", SwigType_lstr(type, 0));
	    } else {
		 Swig_warning(WARN_C_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(type, 0));
	    }

            Printv(proto, gencomma ? ", " : "", c_parm_type, " ", arg_name, NIL);
            gencomma = 1;

            // apply typemaps for input parameter
            if ((tm = Getattr(p, "tmap:in"))) {
                 Replaceall(tm, "$input", arg_name);
		 if (wrapper) {
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

       Printv(proto, ")", NIL);
       return scoped_dohptr(proto);
    }

  /* ----------------------------------------------------------------------
   * emit_wrapper_func_decl()
   *
   * Declares the wrapper function, using the C types used for it, in the header.
   * Also emits a define allowing to use the function without the "_wrap_" prefix.
   * The node here is a function declaration.
   * ---------------------------------------------------------------------- */
  void emit_wrapper_func_decl(Node *n, String *name)
    {
       current_output = output_wrapper_decl;

       maybe_owned_dohptr wname = getFunctionWrapperName(n, name);
       String *preturn_type = get_wrapper_func_return_type(n);

       // add function declaration to the proxy header file
       Printv(f_wrappers_decl, "SWIGIMPORT ", preturn_type, " ", wname.get(), get_wrapper_func_proto(n).get(), ";\n\n", NIL);

       if (GetFlag(n, "c:globalfun")) {
	 if (!f_wrappers_aliases) {
	   // Allocate it on demand.
	   f_wrappers_aliases = NewStringEmpty();
	   Printv(f_wrappers_aliases, "#ifdef SWIG_DEFINE_WRAPPER_ALIASES\n", NIL);
	 }

	 Printf(f_wrappers_aliases, "#define %s %s\n", name, wname.get());
       }

       // cleanup
       Delete(preturn_type);
    }


    void functionWrapperCPPSpecificWrapper(Node *n, String *name)
    {
       current_output = output_wrapper_def;

       // C++ function wrapper
       SwigType *type = Getattr(n, "type");
       SwigType *return_type = get_wrapper_func_return_type(n);
       maybe_owned_dohptr wname = getFunctionWrapperName(n, name);
       ParmList *parms = Getattr(n, "parms");
       Parm *p;
       bool is_void_return = (SwigType_type(type) == T_VOID);
       // create new function wrapper object
       Wrapper *wrapper = NewWrapper();

       // create new wrapper name
       Setattr(n, "wrap:name", wname);

       // add variable for holding result of original function 'cppresult'
       if (!is_void_return) {
	 SwigType *value_type = cplus_value_type(type);
	 SwigType* cppresult_type = value_type ? value_type : type;
	 SwigType* ltype = SwigType_ltype(cppresult_type);
	 Wrapper_add_local(wrapper, "cppresult", SwigType_str(ltype, "cppresult"));
	 Delete(ltype);
	 Delete(value_type);
       }

       // create wrapper function prototype
       Printv(wrapper->def, "SWIGEXPORTC ", return_type, " ", wname.get(), NIL);

       Printv(wrapper->def, get_wrapper_func_proto(n, wrapper).get(), NIL);
       Printv(wrapper->def, " {", NIL);

	// emit variables for holding parameters
	emit_parameter_variables(parms, wrapper);

	// emit variable for holding function return value
	emit_return_variable(n, return_type, wrapper);

       // insert constraint checking
       for (p = parms; p; ) {
            String *tm;
            if ((tm = Getattr(p, "tmap:check"))) {
                 Replaceall(tm, "$target", Getattr(p, "lname"));
                 Replaceall(tm, "$name", name);
                 Printv(wrapper->code, tm, "\n", NIL);
                 p = Getattr(p, "tmap:check:next");
            } else {
                 p = nextSibling(p);
            }
       }

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
	      // This is ugly, but the type of our result variable is not always the same as the actual return type currently because
	      // get_wrapper_func_return_type() applies ctype typemap to it. These types are more or less compatible though, so we should be able to cast
	      // between them explicitly.
	      const char* start = Char(tm);
	      const char* p = strstr(start, "$result = ");
	      if (p == start || (p && p[-1] == ' ')) {
		Insert(tm, p - start + strlen("$result = "), NewStringf("(%s)", return_type));
	      }
                 Replaceall(tm, "$result", "result");
		 Replaceall(tm, "$owner", GetFlag(n, "feature:new") ? "1" : "0");
                 Printf(wrapper->code, "%s", tm);
                 if (Len(tm))
                   Printf(wrapper->code, "\n");
            } else {
                 Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(type, 0), Getattr(n, "name"));
            }
       } else {
            Append(wrapper->code, action);
       }

       // insert cleanup code
       for (p = parms; p; ) {
            String *tm;
            if ((tm = Getattr(p, "tmap:freearg"))) {
                 if (tm && (Len(tm) != 0)) {
                      String *input = NewStringf("c%s", Getattr(p, "lname"));
                      Replaceall(tm, "$source", Getattr(p, "lname"));
                      Replaceall(tm, "$input", input);
                      Delete(input);
                      Printv(wrapper->code, tm, "\n", NIL);
                 }
                 p = Getattr(p, "tmap:freearg:next");
            } else {
                 p = nextSibling(p);
            }
       }

       if (is_void_return) {
	 Replaceall(wrapper->code, "$null", "");
       } else {
	 Replaceall(wrapper->code, "$null", "0");

         Append(wrapper->code, "return result;\n");
       }

       Append(wrapper->code, "}\n");

       Wrapper_print(wrapper, f_wrappers);

       // cleanup
       Delete(return_type);
       DelWrapper(wrapper);
    }

    void functionWrapperCPPSpecific(Node *n)
    {
       ParmList *parms = Getattr(n, "parms");
       String *name = Copy(Getattr(n, "sym:name"));

       // mangle name if function is overloaded
       if (Getattr(n, "sym:overloaded")) {
            if (!Getattr(n, "copy_constructor")) {
		Parm* first_param = (Parm*)parms;
		if (first_param) {
		  // Skip the first "this" parameter of the wrapped methods, it doesn't participate in overload resolution and would just result in extra long
		  // and ugly names.
		  //
		  // The check for c:globalfun is needed to avoid dropping the first argument of static methods which don't have "this" pointer neither, in
		  // spite of being members. Of course, the constructors don't have it neither.
		  if (!Checkattr(n, "nodeType", "constructor") &&
			Checkattr(n, "ismember", "1") &&
			  !Checkattr(n, "c:globalfun", "1")) {
		    first_param = nextSibling(first_param);

		    // A special case of overloading on const/non-const "this" pointer only, we still need to distinguish between those.
		    if (SwigType_isconst(Getattr(n, "decl"))) {
		      const char * const nonconst = Char(Getattr(n, "decl")) + 9 /* strlen("q(const).") */;
		      for (Node* nover = Getattr(n, "sym:overloaded"); nover; nover = Getattr(nover, "sym:nextSibling")) {
			if (nover == n)
			  continue;

			if (Cmp(Getattr(nover, "decl"), nonconst) == 0) {
			  // We have an overload differing by const only, disambiguate.
			  Append(name, "_const");
			  break;
			}
		      }
		    }
		  }

		  functionWrapperAppendOverloaded(name, first_param);
		}
            }
       }

       // make sure lnames are set
       functionWrapperPrepareArgs(parms);

       // C++ function wrapper
       functionWrapperCPPSpecificWrapper(n, name);
       emit_wrapper_func_decl(n, name);

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

    Node* const parent = parentNode(node);
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
   * make_c_var_decl()
   *
   * Return the C declaration for the given node of "variable" kind.
   *
   * If the variable has a type not representable in C, returns NULL, the caller must check for this!
   *
   * This function accounts for two special cases:
   *  1. If the type is an anonymous enum, "int" is used instead.
   *  2. If the type is an array, its bounds are stripped.
   * --------------------------------------------------------------------- */
  String *make_c_var_decl(Node *n) {
    String *name = Getattr(n, "name");
    SwigType *type = Getattr(n, "type");
    String *type_str = SwigType_str(type, 0);

    if (Getattr(n, "unnamedinstance")) {
      // If this is an anonymous enum, we can declare the variable as int even though we can't reference this type.
      if (Strncmp(type_str, "enum $", 6) != 0) {
	// Otherwise we're out of luck, with the current approach of exposing the variables directly we simply can't do it, we would need to use accessor
	// functions instead to support this.
	Swig_error(Getfile(n), Getline(n), "Variables of anonymous non-enum types are not supported.\n");
	return SWIG_ERROR;
      }

      const char * const unnamed_end = strchr(Char(type_str) + 6, '$');
      if (!unnamed_end) {
	Swig_error(Getfile(n), Getline(n), "Unsupported anonymous enum type \"%s\".\n", type_str);
	return SWIG_ERROR;
      }

      String* const int_type_str = NewStringf("int%s", unnamed_end + 1);
      Delete(type_str);
      type_str = int_type_str;
    } else {
      scoped_dohptr btype(SwigType_base(type));
      if (SwigType_isenum(btype)) {
	// Enums are special as they can be unknown, i.e. not wrapped by SWIG. In this case we just use int instead.
	if (!enumLookup(btype)) {
	  Replaceall(type_str, btype, "int");
	}
      } else {
	// Don't bother with checking if type is representable in C if we're wrapping C and not C++ anyhow: of course it is.
	if (CPlusPlus) {
	  if (SwigType_isreference(type))
	    return NIL;

	  if (!SwigType_isbuiltin(btype))
	    return NIL;

	  // Final complication: define bool if it is used here.
	  if (Cmp(btype, "bool") == 0) {
	    Printv(f_wrappers_types, "#include <stdbool.h>\n\n", NIL);
	  }
	}
      }
    }

    String* const var_decl = NewStringEmpty();
    if (SwigType_isarray(type)) {
      String *dims = Strchr(type_str, '[');
      char *c = Char(type_str);
      c[Len(type_str) - Len(dims) - 1] = '\0';
      Printv(var_decl, c, " ", name, "[]", NIL);
    } else {
      Printv(var_decl, type_str, " ", name, NIL);
    }

    Delete(type_str);

    return var_decl;
  }

  /* ---------------------------------------------------------------------
   * emit_c_struct_def()
   *
   * Append the declarations of C struct members to the given string.
   * Notice that this function has a side effect of outputting all enum declarations inside the struct into f_wrappers_types directly.
   * This is done to avoid gcc warnings "declaration does not declare anything" given for the anonymous enums inside the structs.
   * --------------------------------------------------------------------- */

  void emit_c_struct_def(String* out, Node *n) {
    for ( Node* node = firstChild(n); node; node = nextSibling(node)) {
      String* const ntype = nodeType(node);
      if (Cmp(ntype, "cdecl") == 0) {
	SwigType* t = NewString(Getattr(node, "type"));
	SwigType_push(t, Getattr(node, "decl"));
	t = SwigType_typedef_resolve_all(t);
	if (SwigType_isfunction(t)) {
            Swig_warning(WARN_C_UNSUPPORTTED, input_file, line_number, "Extending C struct with %s is not currently supported, ignored.\n", SwigType_str(t, 0));
	} else {
	  String* const var_decl = make_c_var_decl(node);
	  Printv(out, cindent, var_decl, ";\n", NIL);
	  Delete(var_decl);
	}
      } else if (Cmp(ntype, "enum") == 0) {
	// This goes directly into f_wrappers_types, before this struct declaration.
	emit_one(node);
      } else {
	// WARNING: proxy declaration can be different than original code
	if (Cmp(nodeType(node), "extend") == 0)
	  emit_c_struct_def(out, node);
      }
    }
  }

  /* ---------------------------------------------------------------------
   * classHandler()
   * --------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {
    String *name = getProxyName(n);

    if (CPlusPlus) {
      // inheritance support: attach all members from base classes to this class
      if (List *baselist = Getattr(n, "bases")) {
	Iterator i;
	for (i = First(baselist); i.item; i = Next(i)) {
	  // look for member variables and functions
	  Node *node;
	  for (node = firstChild(i.item); node; node = nextSibling(node)) {
	    if ((Cmp(Getattr(node, "kind"), "variable") == 0)
		|| (Cmp(Getattr(node, "kind"), "function") == 0)) {
	      if ((Cmp(Getattr(node, "access"), "public") == 0)
		  && (Cmp(Getattr(node, "storage"), "static") != 0)) {
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
      Printv(f_wrappers_types, "typedef struct SwigObj_", name, " ", name, ";\n\n", NIL);

      Delete(name);
      return Language::classHandler(n);
    } else {
      // this is C struct, just declare it in the proxy
      String* struct_def = NewStringEmpty();
      String* const tdname = Getattr(n, "tdname");
      if (tdname)
        Append(struct_def, "typedef struct {\n");
      else
        Printv(struct_def, "struct ", name, " {\n", NIL);
      emit_c_struct_def(struct_def, n);
      if (tdname)
        Printv(struct_def, "} ", tdname, ";\n\n", NIL);
      else
        Append(struct_def, "};\n\n");

      Printv(f_wrappers_types, struct_def, NIL);
      Delete(struct_def);

      Delete(name);
    }
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * staticmemberfunctionHandler()
   * --------------------------------------------------------------------- */

  virtual int staticmemberfunctionHandler(Node *n) {
    SwigType *type = Getattr(n, "type");
    SwigType *tdtype;
    tdtype = SwigType_typedef_resolve_all(type);
    if (tdtype)
      type = tdtype;
    if (type) {
      if (!SwigType_ispointer(type) && !SwigType_isreference(type))
        Setattr(n, "c:retval", "1");
    }
    return Language::staticmemberfunctionHandler(n);
  }

  /* ---------------------------------------------------------------------
   * memberfunctionHandler()
   * --------------------------------------------------------------------- */

  virtual int memberfunctionHandler(Node *n) {
    SwigType *type = Getattr(n, "type");
    SwigType *tdtype;
    tdtype = SwigType_typedef_resolve_all(type);
    if (tdtype)
      type = tdtype;
    if (type) {
      if (!SwigType_ispointer(type) && !SwigType_isreference(type))
        Setattr(n, "c:retval", "1");
    }
    return Language::memberfunctionHandler(n);
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
    SwigType *btype = SwigType_base(type);
    if (SwigType_isarray(type) && !SwigType_isbuiltin(btype)) {
      // this hack applies to member objects array (not ptrs.)
      SwigType_add_pointer(btype);
      SwigType_add_array(btype, NewStringf("%s", SwigType_array_getdim(type, 0)));
      Setattr(n, "type", btype);
    }
    if (type) {
      if (!SwigType_ispointer(type) && !SwigType_isreference(type))
        Setattr(n, "c:retval", "1");
    }
    Delete(type);
    Delete(btype);
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
    SwigType *btype = SwigType_base(type);
    if (SwigType_isarray(type) && !SwigType_isbuiltin(btype)) {
      // this hack applies to member objects array (not ptrs.)
      SwigType_add_pointer(btype);
      SwigType_add_array(btype, NewStringf("%s", SwigType_array_getdim(type, 0)));
      Setattr(n, "type", btype);
    }
    if (type) {
      if (!SwigType_ispointer(type) && !SwigType_isreference(type))
        Setattr(n, "c:retval", "1");
    }
    Delete(type);
    Delete(btype);
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

  /* ---------------------------------------------------------------------
   * enumDeclaration()
   * --------------------------------------------------------------------- */

  virtual int enumDeclaration(Node *n) {
    if (ImportMode)
      return SWIG_OK;

    if (getCurrentClass() && (cplus_mode != PUBLIC))
      return SWIG_NOWRAP;

    // Preserve the typedef if we have it in the input.
    String* const tdname = Getattr(n, "tdname");
    if (tdname) {
      Printv(f_wrappers_types, "typedef ", NIL);
    }
    Printv(f_wrappers_types, "enum", NIL);

    if (String* const name = Getattr(n, "name")) {
      String* const enumname = Swig_name_mangle(name);
      Printv(f_wrappers_types, " ", enumname, NIL);
      Delete(enumname);
    }

    // We don't know here if we're going to have any non-ignored enum elements, so let enumvalueDeclaration() itself reset this flag if it does get called, this
    // is simpler than trying to determine it here, even if it's a bit ugly because we generate the opening brace there, but the closing one here.
    enum_is_empty = true;

    // Emit each enum item.
    Language::enumDeclaration(n);

    if (!enum_is_empty) {
      Printv(f_wrappers_types, "\n}", NIL);
    }

    if (tdname) {
      String* const enumname = Swig_name_mangle(tdname);
      Printv(f_wrappers_types, " ", enumname, NIL);
      Delete(enumname);
    }
    Printv(f_wrappers_types, ";\n\n", NIL);

    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * enumvalueDeclaration()
   * --------------------------------------------------------------------- */

  virtual int enumvalueDeclaration(Node *n) {
    if (Cmp(Getattr(n, "ismember"), "1") == 0 && Cmp(Getattr(n, "access"), "public") != 0)
      return SWIG_NOWRAP;
    Swig_require("enumvalueDeclaration", n, "*value", "?enumvalueex", "?enumvalue", NIL);

    enum_is_empty = false;

    if (GetFlag(n, "firstenumitem"))
      Printv(f_wrappers_types, " {\n", NIL);
    else
      Printv(f_wrappers_types, ",\n", NIL);

    String* const enumitemname = Getattr(n, "value");
    Printv(f_wrappers_types, cindent, Swig_name_mangle(enumitemname), NIL);

    // We only use "enumvalue", which comes from the input, and not "enumvalueex" synthesized by SWIG itself because C should use the correct value for the enum
    // items without an explicit one anyhow (and "enumvalueex" can't be always used as is in C code for enum elements inside a class or even a namespace).
    String *value = Getattr(n, "enumvalue");
    if (value) {
      String* const cvalue = Copy(value);

      // Due to what seems to be a bug in SWIG parser, char values for enum elements lose their quotes, i.e.
      //
      //  enum { x = 'a', y = '\x62' };
      //
      // in input results in value being just "a" or "\x62". Try to repair this brokenness.
      if (*Char(value) == '\\') {
	Push(cvalue, "'");
	Append(cvalue, "'");
      } else if (Len(value) == 1 && !Swig_symbol_clookup(enumitemname, NULL)) {
	Push(cvalue, "'");
	Append(cvalue, "'");
      }

      // Boolean constants can't appear in C code neither, so replace them with their values in the simplest possible case. This is not exhaustive, of course,
      // but better than nothing and doing the right thing is not simple at all as we'd need to really parse the expression, just textual substitution wouldn't
      // be enough (consider e.g. an enum element called "very_true" and another one using it as its value).
      if (Cmp(value, "true") == 0) {
	Clear(cvalue);
	Append(cvalue, "1");
      } else if (Cmp(value, "false") == 0) {
	Clear(cvalue);
	Append(cvalue, "0");
      }

      Printv(f_wrappers_types, " = ", cvalue, NIL);

      Delete(cvalue);
    }

    Swig_restore(n);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * constantWrapper()
   * --------------------------------------------------------------------- */

  virtual int constantWrapper(Node *n) {
    String *name = Getattr(n, "sym:name");
    // If it's a #define or a %constant, use raw value and hope that it will work in C as well as in C++. This is not ideal, but using "value" is even worse, as
    // it doesn't even work for simple char constants such as "#define MY_X 'x'", that would end up unquoted in the generated code.
    String *value = Getattr(n, "rawval");

    if (!value) {
      // Check if it's not a static member variable because its "value" is a reference to a C++ variable and won't translate to C correctly.
      //
      // Arguably, those should be handled in overridden memberconstantHandler() and not here.
      value = Getattr(n, "staticmembervariableHandler:value");
      if (value && Equal(Getattr(n, "valuetype"), "char")) {
	// We need to quote this value.
	const unsigned char c = *Char(value);
	Clear(value);
	if (isalnum(c)) {
	  Printf(value, "'%c'", c);
	} else {
	  Printf(value, "'\\x%x%x'", c / 0x10, c % 0x10);
	}
      }
    }

    if (!value) {
      // Fall back on whatever SWIG parsed the value as for all the rest.
      value = Getattr(n, "value");
    }

    Printv(f_wrappers_decl, "#define ", name, " ", value, "\n", NIL);
    return SWIG_OK;
  }
};				/* class C */

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

const char *C::usage = (char *) "\
C Options (available with -c)\n\
     -noexcept     - do not generate exception handling code\n\
\n";


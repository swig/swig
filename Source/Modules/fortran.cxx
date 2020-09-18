/* File : fortran.cxx */
#include "swigmod.h"
#include "cparse.h"
#include <ctype.h>

#define ASSERT_OR_PRINT_NODE(COND, NODE) \
  do { \
    if (!(COND)) { \
      Printf(stdout, "********************************\n"); \
      Swig_print_node(NODE); \
      Printf(stdout, "Assertion '" #COND "' failed for node at %s:%d\n", Getfile(NODE), Getline(NODE)); \
      assert(COND); \
    } \
  } while (0)

namespace {
/* -------------------------------------------------------------------------
 * GLOBAL DATA
 * ------------------------------------------------------------------------- */

const char usage[] = "\
Fotran Options (available with -fortran)\n\
     -cppcast    - Enable C++ casting operators (default) \n\
     -nocppcast  - Disable C++ casting operators\n\
     -fext       - Change file extension of generated Fortran files to <ext>\n\
                   (default is f90)\n\
\n";

//! Maximum line length
const int g_max_line_length = 128;

const char g_fortran_end_statement[] = "\n";

/* -------------------------------------------------------------------------
 * UTILITY FUNCTIONS
 * ------------------------------------------------------------------------- */

/*!
 * \brief Whether a class method is a constructor.
 */
bool is_node_constructor(Node *n) {
  return (Cmp(Getattr(n, "nodeType"), "constructor") == 0) || Getattr(n, "handled_as_constructor");
}

/*!
 * \brief Whether a node is a compile-time constant that isn't acutally defined in client code.
 */
bool has_constant_storage(Node *n) {
  String *s = Getattr(n, "storage");
  return s && (Cmp(s, "%constant") == 0);
}

/*!
 * \brief Whether a node is a compile-time constant as defined by C++.
 */
bool has_constexpr_storage(Node *n) {
  String *s = Getattr(n, "storage");
  return s && (Cmp(s, "constexpr") == 0);
}

/*!
 * \brief Whether a class method is pure virtual
 */
bool is_pure_virtual(Node *n) {
  return (Cmp(Getattr(n, "storage"), "virtual") == 0) && (Cmp(Getattr(n, "value"), "0") == 0);
}

/* -------------------------------------------------------------------------
 * \brief Print a comma-joined line of items to the given output.
 */
int print_wrapped_list(String *out, Iterator it, int line_length) {
  const char *prefix = "";
  for (; it.item; it = Next(it)) {
    line_length += 2 + Len(it.item);
    if (line_length >= g_max_line_length) {
      Printv(out, prefix, NULL);
      prefix = "&\n    ";
      line_length = 4 + Len(it.item);
    }
    Printv(out, prefix, it.item, NULL);
    prefix = ", ";
  }
  return line_length;
}

/* -------------------------------------------------------------------------
 * \brief Return a function wrapper for Fortran code.
 */
Wrapper *NewFortranWrapper() {
  Wrapper *w = NewWrapper();
  w->end_statement = g_fortran_end_statement;
  return w;
}

/* -------------------------------------------------------------------------
 * \brief Whether an expression is a standard base-10 integer compatible with
 * fortran
 *
 * Note that if it has a suffix e.g. `l` or `u`, or a prefix `0` (octal), it's
 * not compatible.
 */
bool is_fortran_intexpr(String *s) {
  const char *p = Char(s); // 'peek': next character
  char c = *p++; // character being processed

  // Empty string is not an integer
  if (c == '\0')
    return false;

  // Allow leading negative sign
  if (c == '-')
    c = *p++;

  // If it's a multi-digit number that starts with 0, it's octal, and thus
  // not a simple integer
  if (c == '0' && *p != '\0')
    return false;

  // See if any of the remaining characters aren't ints
  while (c) {
    if (!isdigit(c))
      return false;

    c = *p++;
  }
  return true;
}

/* -------------------------------------------------------------------------
 * \brief Check a parameter for invalid dimension names.
 */
int fix_fortran_dims(Node *n, const char *tmap_name, String *typemap) {
  String *key = NewStringf("tmap:%s:checkdim", tmap_name);
  bool is_checkdims = GetFlag(n, key);
  Delete(key);
  if (!is_checkdims)
    return SWIG_OK;

  SwigType *t = Getattr(n, "type");

  if (SwigType_isarray(t)) {
    int ndim = SwigType_array_ndim(t);
    for (int i = 0; i < ndim; i++) {
      String *dim = SwigType_array_getdim(t, i);
      if (dim && Len(dim) > 0 && !is_fortran_intexpr(dim)) {
        Swig_warning(WARN_LANG_IDENTIFIER, input_file, line_number, "Array dimension expression '%s' is incompatible with Fortran\n", dim);
        Delete(dim);
        return SWIG_ERROR;
      }
      Delete(dim);
    }

    // Replace empty dimensions with assumed-size dimension
    Replaceall(typemap, "dimension()", "dimension(*)");
    Replaceall(typemap, ",)", ",*)");
  } else if (SwigType_ispointer(t)) {
    // Note that we use `imname` instead of `lname` since it was temporarily changed for typemap matching for ftype. Pointers should only have a single
    // dimension, so we replace with deferred size.
    String *dimname = NewStringf("%s_dim0", Getattr(n, "imname"));
    Replaceall(typemap, dimname, "*");
    Delete(dimname);
  } else {
    ASSERT_OR_PRINT_NODE(false, n);
  }

  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Determine whether to wrap an enum as a fortran parameter.
 */
bool is_native_enum_decl(Node *n) {
  String *enum_feature = Getattr(n, "feature:fortran:const");
  if (!enum_feature) {
    // Determine from enum values
    for (Node *c = firstChild(n); c; c = nextSibling(c)) {
      if (Getattr(c, "error") || GetFlag(c, "feature:ignore")) {
        return false;
      }

      String *enum_value = Getattr(c, "enumvalue");
      if (enum_value && !is_fortran_intexpr(enum_value)) {
        return false;
      }
    }
    // No bad values
    return true;
  } else if (Strcmp(enum_feature, "0") == 0) {
    // User forced it not to be a native enum
    return false;
  } else {
    // %fortranconst was set as a flag
    return true;
  }
}

/* -------------------------------------------------------------------------
 * \brief Determine whether an enum is being wrapped
 */
bool is_wrapped_enum(Node *n) {
  return !GetFlag(n, "enumMissing") && GetFlag(n, "fortran:declared");
}

/* -------------------------------------------------------------------------
 * \brief Get the special string value corresponding to whether a function is
 * a void return type (subroutine)
 */
String *subroutine_flag_str(bool is_subroutine) {
  static String *is_subroutine_flag = NewString("is subroutine");
  static String *not_subroutine_flag = NewString("is function");
  return is_subroutine ? is_subroutine_flag : not_subroutine_flag;
}

/* -------------------------------------------------------------------------
 * \brief Whether an SWIG type can be rendered as TYPE VAR.
 *
 * Some declarations (arrays, function pointers, member function pointers)
 * require the variable to be embedded in the middle of the array and thus
 * require special treatment.
 */
bool return_type_needs_typedef(String *s) {
  String *strprefix = SwigType_prefix(s);
  bool result = (Strstr(strprefix, "p.a(") || Strstr(strprefix, "p.f(") || Strstr(strprefix, "p.m("));
  Delete(strprefix);
  return result;
}

/* -------------------------------------------------------------------------
 * \brief Construct any necessary 'import' identifier.
 *
 * When the `imtype` is an actual `type(Foo)`, it's necessary to import the identifier Foo from the module definition scope. This function examines the
 * evaluated `imtype` (could be `imtype:in`, probably has $fortranclassname replaced)
 */
String *make_import_string(String *imtype) {
  char *start = Strstr(imtype, "type(");
  if (start == NULL)
    return NULL; // No 'type('

  start += 5; // Advance to whatever comes after 'type'
  char *end = start;
  while (*end != '\0' && *end != ')')
    ++end;

  // Create a substring and convert to lowercase
  String* result = NewStringWithSize(start, end - start);
  for (char* c = Char(result); *c != '\0'; ++c)
    *c = tolower(*c);

  if (Strcmp(result, "c_ptr") == 0
      || Strcmp(result, "c_funptr") == 0)
  {
    // Don't import types pulled in from `use, intrinsic :: ISO_C_BINDING`
    Delete(result);
    result = NULL;
  }

  return result;
}

/* -------------------------------------------------------------------------
 * \brief Whether a name is a valid fortran identifier
 */
bool is_valid_identifier(const_String_or_char_ptr name) {
  const char *c = Char(name);
  if (*c == '\0')
    return false;
  if (*c == '_')
    return false;
  if (*c >= '0' && *c <= '9')
    return false;
  if (Len(name) > 63)
    return false;
  return true;
}

/* -------------------------------------------------------------------------
 * \brief Make a string shorter by hashing its end.
 *
 * Requires input to be longer than 63 chars.
 * Returns new'd string.
 */
String *shorten_identifier(String *inp, int maxlen, int warning) {
  assert(Len(inp) > maxlen);
  String *result = NewStringWithSize(inp, maxlen);
  unsigned int hash = 5381;
  // Hash truncated characters *AND* characters that might be replaced by the hash
  // (2**8 / (10 + 26)) =~ 7.1, so backtrack 8 chars
  for (const char *src = Char(inp) + maxlen - 8; *src != '\0'; ++src) {
    hash = (hash * 33 + *src) & 0xffffffffu;
  }
  // Replace the last chars with the hash encoded into 0-10 + A-Z
  char *dst = Char(result) + maxlen;
  while (hash > 0) {
    unsigned long rem = hash % 36;
    hash = hash / 36;
    *dst-- = (rem < 10 ? '0' + rem : ('A' + rem - 10));
  }

  if (warning != WARN_NONE && !Getmeta(inp, "already_warned")) {
    Swig_warning(warning, input_file, line_number, "Fortran identifiers may be no longer than 64 characters: renaming '%s' to '%s'\n", inp, result);
    Setmeta(inp, "already_warned", "1");
  }
  return result;
}

/* -------------------------------------------------------------------------
 * \brief If a string is too long, shorten it. Otherwise leave it.
 *
 * This should only be used for strings whose beginnings are valid fortran
 * identifiers -- e.g. strings that we construct.
 *
 * *assumes ownership of input and returns new'd value*
 */
String *ensure_short(String *str, int maxlen=63, int warning=WARN_NONE) {
  if (Len(str) > maxlen) {
    String *shortened = shorten_identifier(str, maxlen, warning);
    assert(is_valid_identifier(shortened));
    Delete(str);
    str = shortened;
  }
  return str;
}

/* -------------------------------------------------------------------------
 * \brief If a string is too long, shorten it. Otherwise leave it.
 *
 * This should only be used for strings whose beginnings are valid fortran
 * identifiers -- e.g. strings that we construct.
 *
 * *assumes ownership of input and returns new'd value*
 */
String *proxy_name_construct(String *nspace, const_String_or_char_ptr classname, const_String_or_char_ptr symname) {
  String *result;
  if (nspace && classname) {
    result = NewStringf("swigf_%s_%s_%s", nspace, classname, symname);
  } else if (nspace || classname) {
    result = NewStringf("swigf_%s_%s", nspace ? nspace : classname, symname);
  } else {
    result = NewStringf("swigf_%s", symname);
  }
  return ensure_short(result);
}

String *proxy_name_construct(String *nspace, const_String_or_char_ptr symname) {
  return proxy_name_construct(nspace, NULL, symname);
}

/* -------------------------------------------------------------------------
 * \brief Change a symname to a valid Fortran identifier, warn if changing
 *
 * The maximum length of a Fortran identifier is 63 characters, according
 * to the Fortran standard.
 *
 * This name is *not* guaranteed to be unique!
 *
 * \return new'd valid identifier name
 */
String *make_fname(String *name, int warning = WARN_LANG_IDENTIFIER) {
  assert(name);
  String* result = NULL;

  // Move underscores and leading digits to the end of the string
  const char *start = Char(name);
  const char *c = start;
  const char *stop = start + Len(name);
  while (c != stop && (*c == '_' || (*c >= '0' && *c <= '9'))) {
    ++c;
  }
  if (c != start) {
    // Move invalid characters to the back of the string
    if (c == stop) {
      // No valid characters, e.g. _1234; prepend an 'f'
      result = NewString("f");
    } else {
      result = NewStringWithSize(c, (int)(stop - c));
    }
    String *tail = NewStringWithSize(start, (int)(c - start));
    Printv(result, tail, NULL);
    Delete(tail);

    if (warning != WARN_NONE && !Getmeta(name, "already_warned")) {
      Swig_warning(warning, input_file, line_number,
                   "Fortran identifiers may not begin with underscores or numerals: renaming '%s' to '%s'\n",
                   name, result);
    }
    Setmeta(name, "already_warned", "1");
  }

  // The beginning of the string is set up; now capture and shorten if too long
  result = ensure_short(result ? result : Copy(name), 63, warning);

  assert(is_valid_identifier(result));
  return result;
}

/* -------------------------------------------------------------------------
 * \brief Create a mangled SWIGTYPEMyClassName for Fortran proxy code.
 */
String *create_mangled_fname(SwigType *classnametype) {
  // Memoize mangled names
  static Hash *mangled_type_cache = NewHash();
  String *result = Getattr(mangled_type_cache, classnametype);
  if (!result) {
    // Create mangled SWIGTYPE_p_FooBar
    String *mangled = SwigType_manglestr(classnametype);
    Insert(mangled, 0, "SWIGTYPE");
    result = make_fname(mangled, WARN_NONE);
    Delete(mangled);
  }
  return result;
}

/* -------------------------------------------------------------------------
 * \brief Get/attach and return a typemap to the given node.
 *
 * If 'ext' is non-null, then after binding/searchinbg, a search will be made
 * for the typemap with the given extension. If that's present, it's used
 * instead of the default typemap. (This allows overriding of e.g. 'tmap:ctype'
 * with 'tmap:ctype:in'.)
 *
 * If 'warning' is WARN_NONE, then if the typemap is not found, the return
 * value will be NULL. Otherwise a mangled typename will be created and saved
 * to attributes (or if attributes is null, then the given node).
 */
String *get_typemap(const_String_or_char_ptr tmname, const_String_or_char_ptr ext, Node *n, int warning, bool attach) {
  assert(tmname);
  String *result = NULL;
  String *key = NewStringf("tmap:%s", tmname);

  if (attach) {
    // Attach the typemap, or NULL if it's not there
    String *lname = Getattr(n, "lname");
    if (!lname)
      lname = Getattr(n, "name");
    assert(lname);
    result = Swig_typemap_lookup(tmname, n, lname, NULL);
  } else {
    // Look up a typemap that should already be attached
    result = Getattr(n, key);
  }

  if (!result && warning != WARN_NONE) {
    // Typemap was not found: emit a warning
    SwigType *type = Getattr(n, "type");
    if (!type) {
      type = Getattr(n, "name");
    }
    if (!type) {
      type = NewString("UNKNOWN");
    }
    Swig_warning(warning, Getfile(n), Getline(n),
                 "No '%s' typemap defined for %s\n",
                 tmname, SwigType_str(type, NULL));

    String *tmap_match_key = NewStringf("tmap:%s:match_type", tmname);
    Setattr(n, tmap_match_key, "SWIGTYPE");
    Delete(tmap_match_key);
  }

  if (ext) {
    String *tempkey = NewStringf("tmap:%s:%s", tmname, ext);
    String *suffixed_tm = Getattr(n, tempkey);
    if (suffixed_tm) {
      // Replace the output value with the specialization
      result = suffixed_tm;
      // Replace the key with the specialized key
      Delete(key);
      key = tempkey;
      tempkey = NULL;
    }
    Delete(tempkey);
  }

  Delete(key);
  return result;
}

/* ------------------------------------------------------------------------- */
//! Attach and return a typemap to the given node.
String *attach_typemap(const_String_or_char_ptr tmname, Node *n, int warning) {
  return get_typemap(tmname, NULL, n, warning, true);
}

//! Get and return a typemap to the given node.
String *get_typemap(const_String_or_char_ptr tmname, Node *n, int warning) {
  return get_typemap(tmname, NULL, n, warning, false);
}

//! Get and return a typemap (with extension) to the given node.
String *get_typemap(const_String_or_char_ptr tmname, const_String_or_char_ptr ext, Node *n, int warning) {
  return get_typemap(tmname, ext, n, warning, false);
}

/* -------------------------------------------------------------------------
 * \brief Get a plain-text type like "int *", convert it to "p.int"
 *
 * This also sets the attribute in the node.
 *
 * This function is exclusively used for the "tmap:ctype" attribute, which
 * the user inputs as a plain-text C declaration but doesn't automatically get
 * converted by the SWIG type system like the "type" attribute does.
 *
 * Caller is responsible for calling Delete on the return value. Will return
 * NULL if the typemap isn't defined.
 */
SwigType *parse_typemap(const_String_or_char_ptr tmname, const_String_or_char_ptr ext, Node *n, int warning) {
  // Get the typemap, which has the *unparsed and unsimplified* type
  String *raw_tm = get_typemap(tmname, ext, n, warning);
  // Convert the plain-text string to a SWIG type
  SwigType *parsed_type = Swig_cparse_type(raw_tm);
  if (!parsed_type) {
    return NULL;
  }

  // Replace the contents of the original typemap string with the parsed
  // result -- this is a sort of hack for avoiding the 'Setattr(tmname,
  // resolved_type)' where we'd have to recalculate the tmname key again
  Clear(raw_tm);
  Printv(raw_tm, parsed_type, NULL);
  Delete(parsed_type);
  return raw_tm;
}

SwigType *parse_typemap(const_String_or_char_ptr tmname, Node *n, int warning) {
  return parse_typemap(tmname, NULL, n, warning);
}

//---------------------------------------------------------------------------//
// Swig_fragment_emit can't be called with a const char* argument.
void emit_fragment(const char *name) {
  String *temp = NewString(name);
  Swig_fragment_emit(temp);
  Delete(temp);
}

//---------------------------------------------------------------------------//
// Construct noexecept | throws(...) for director methods
String *function_exception_qualifiers(Node *n) {
  String *result = NULL;
  if (Getattr(n, "noexcept")) {
    return NewString(" noexcept");
  }

  ParmList *throw_parm_list = Getattr(n, "throws");
  if (throw_parm_list || Getattr(n, "throw")) {
    Parm *p;
    result = NewString(" throw(");

    if (throw_parm_list)
      Swig_typemap_attach_parms("throws", throw_parm_list, 0);

    int gencomma = 0;
    for (p = throw_parm_list; p; p = nextSibling(p)) {
      if (Getattr(p, "tmap:throws")) {
        if (gencomma++) {
          Append(result, ", ");
        }
        String *str = SwigType_str(Getattr(p, "type"), 0);
        Append(result, str);
        Delete(str);
      }
    }

    Append(result, ")");
  }
  return result;
}

//---------------------------------------------------------------------------//
// Construct a 'this' parameter from a member function declaration
Parm *make_self_parm(String *classname, Node *n) {
  SwigType *type = NewString(classname);
  if (String *qualifier = Getattr(n, "qualifier")) {
    SwigType_push(type, qualifier);
  }
  SwigType_add_pointer(type);
  Parm *p = NewParm(type, "self", n);
  Setattr(p, "self", "1");
  Setattr(p, "hidden", "1");
  return p;
}

/* ------------------------------------------------------------------------- */
} // end anonymous namespace

class FORTRAN : public Language {
private:
  // >>> OUTPUT FILES

  // Injected into .cxx file
  String *f_begin;   //!< Very beginning of output file
  String *f_runtime; //!< SWIG runtime code
  String *f_policies;//!< AssignmentType flags for each class
  String *f_header;  //!< Declarations and inclusions from .i
  String *f_wrapper; //!< C++ Wrapper code
  String *f_init;    //!< C++ initalization functions

  // Injected into module file
  String *f_fbegin;      //!< Very beginning of output file
  String *f_fuse;        //!< Fortran "use" directives
  String *f_fdecl;       //!< Module declaration constructs
  String *f_fabstract;   //!< Fortran "abstract interface" declarations
  String *f_finterfaces; //!< Fortran interface declarations to SWIG functions
  String *f_fsubprograms;//!< Fortran subroutine wrapper functions
  String *f_directors;   //!< Director methods
  String *f_directors_h; //!< Director headers

  // Keep track of anonymous classes and enums
  Hash *d_emitted_mangled;
  // Declared "abstract interface" callback types (SwigType -> function node)
  Hash *d_callbacks;

  // Module-wide procedure interfaces
  Hash *d_overloads; //!< Overloaded subroutine -> overload names
  Hash *d_private_overloads; //!< Overloaded subroutine flagged for 'private' use

  // Current class parameters
  String *f_class;          //!< Proxy code in currently generated class
  Hash *d_method_overloads; //!< Overloaded subroutine -> overload names

  // Inside of the 'enum' definitions
  List *d_enum_public; //!< List of enumerator values

  // >>> CONFIGURE OPTIONS

  String *d_fext; //!< Fortran file extension

public:
  virtual void main(int argc, char *argv[]);
  virtual int top(Node *n);
  virtual int moduleDirective(Node *n);
  virtual int functionWrapper(Node *n);
  virtual int destructorHandler(Node *n);
  virtual int constructorHandler(Node *n);
  virtual int classDeclaration(Node *n);
  virtual int classHandler(Node *n);
  virtual int memberfunctionHandler(Node *n);
  virtual int membervariableHandler(Node *n);
  virtual int globalvariableHandler(Node *n);
  virtual int globalfunctionHandler(Node *n);
  virtual int staticmemberfunctionHandler(Node *n);
  virtual int staticmembervariableHandler(Node *n);
  virtual int enumDeclaration(Node *n);
  virtual int callbackfunctionHandler(Node *n);
  virtual int constantWrapper(Node *n);

  virtual int classDirectorInit(Node *n);
  virtual int classDirectorConstructor(Node *n);
  virtual int classDirectorDefaultConstructor(Node *n);
  virtual int classDirectorMethod(Node *n, Node *parent, String *super);
  virtual int classDirectorDestructor(Node *n);
  virtual int classDirectorEnd(Node *n);
  virtual int classDirectorDisown(Node *n);
  virtual bool extraDirectorProtectedCPPMethodsRequired() const { return false; }

  virtual String *makeParameterName(Node *n, Parm *p, int arg_num, bool is_setter = false) const;
  virtual void replaceSpecialVariables(String *method, String *tm, Parm *parm);

  FORTRAN();

private:
  Wrapper *cfuncWrapper(Node *n);
  Wrapper *imfuncWrapper(Node *n, bool bindc);
  Wrapper *proxyfuncWrapper(Node *n);

  int fortrancallbackHandler(Node *n);
  int bindcfunctionHandler(Node *n);
  int bindcvarWrapper(Node *n);

  void add_assignment_operator(Node *n);
  void write_docstring(Node *n, String *dest);

  void write_wrapper(String *filename);
  void write_header(String *filename, String *include_guard);
  void write_module(String *filename);

  void replace_fclassname(Node *n, SwigType *type, String *tm);
  String *get_fsymname(Node *n, String *symname = NULL);
  String *get_proxyname(Node *parent, SwigType *classnametype);
  bool is_wrapped_type(SwigType *classnametype);
  bool is_wrapped_class(Node *n);

  // Add n overloaded
  int add_overload(String *fsymname, Node *n, String *fname, bool is_private);
  // Add lowercase symbol (fortran) to the module's namespace
  int add_fsymbol(String *s, Node *n);
  // Whether the current class is a BIND(C) struct
  bool is_bindc_struct() const { assert(this->getCurrentClass()); return d_method_overloads == NULL; }
};

/* -------------------------------------------------------------------------
 * \brief Constructor.
 */
FORTRAN::FORTRAN() :
  d_emitted_mangled(NULL), d_callbacks(NULL), d_overloads(NULL), d_private_overloads(NULL), f_class(NULL), d_method_overloads(NULL), 
  d_enum_public(NULL) {

  // Mark this language as supporting directors
  director_language = 1;
  // Clear base-class member data set by Lang constructor and not used by this language.
  Delete(none_comparison);
  none_comparison = NewString("");
  Delete(director_ctor_code);
  director_ctor_code = NewString("$director_new");
}

/* -------------------------------------------------------------------------
 * \brief Main function for code generation.
 */
void FORTRAN::main(int argc, char *argv[]) {
  int cppcast = 1;

  /* Set language-specific subdirectory in SWIG library */
  SWIG_library_directory("fortran");

  // Default string extension
  d_fext = NewString("f90");

  // Set command-line options
  for (int i = 1; i < argc; ++i) {
    if (strcmp(argv[i], "-cppcast") == 0) {
      cppcast = 1;
      Swig_mark_arg(i);
    } else if (strcmp(argv[i], "-nocppcast") == 0) {
      cppcast = 0;
      Swig_mark_arg(i);
    } else if (strcmp(argv[i], "-fext") == 0) {
      Swig_mark_arg(i);
      if (argv[i + 1]) {
        Delete(d_fext);
        d_fext = NewString(argv[i + 1]);
        Swig_mark_arg(i + 1);
        ++i;
      } else {
        Swig_arg_error();
      }
    } else if ((strcmp(argv[i], "-help") == 0)) {
      Printv(stdout, usage, NULL);
    }
  }

  /* Enable C++ casting */
  if (cppcast) {
    Preprocessor_define("SWIG_CPLUSPLUS_CAST", 0);
  }

  /* Set language-specific preprocessing symbol */
  Preprocessor_define("SWIGFORTRAN 1", 0);

  /* Set typemap language (historical) */
  SWIG_typemap_lang("fortran");

  /* Set language-specific configuration file */
  SWIG_config_file("fortran.swg");

  allow_overloading();
  Swig_interface_feature_enable();
}

/* -------------------------------------------------------------------------
 * \brief Top-level code generation function.
 */
int FORTRAN::top(Node *n) {
  // Configure output filename using the name of the SWIG input file
  String *foutfilename = NewStringf("%s%s.%s", SWIG_output_directory(), Getattr(n, "name"), d_fext);
  Setattr(n, "fortran:outfile", foutfilename);
  Delete(foutfilename);

  // >>> C++ WRAPPER CODE

  // run time code (beginning of .cxx file)
  f_begin = NewStringEmpty();
  Swig_register_filebyname("begin", f_begin);

  // run time code (beginning of .cxx file)
  f_runtime = NewStringEmpty();
  Swig_register_filebyname("runtime", f_runtime);

  f_policies = NewStringEmpty();

  // header code (after run time)
  f_header = NewStringEmpty();
  Swig_register_filebyname("header", f_header);

  // C++ wrapper code (middle of .cxx file)
  f_wrapper = NewStringEmpty();
  Swig_register_filebyname("wrapper", f_wrapper);

  // initialization code (end of .cxx file)
  f_init = NewStringEmpty();
  Swig_register_filebyname("init", f_init);

  // >>> FORTRAN WRAPPER CODE

  // Code before the `module` statement
  f_fbegin = NewStringEmpty();
  Swig_register_filebyname("fbegin", f_fbegin);

  // Start of module:
  f_fuse = NewStringEmpty();
  Swig_register_filebyname("fuse", f_fuse);

  // Module declarations
  f_fdecl = NewStringEmpty();
  Swig_register_filebyname("fdecl", f_fdecl);

  // Fortran BIND(C) abstract interfavces
  f_fabstract = NewStringEmpty();
  Swig_register_filebyname("fabstract", f_fabstract);

  // Fortran BIND(C) interfavces
  f_finterfaces = NewStringEmpty();
  Swig_register_filebyname("finterfaces", f_finterfaces);

  // Fortran subroutines (proxy code)
  f_fsubprograms = NewStringEmpty();
  Swig_register_filebyname("fsubprograms", f_fsubprograms);

  // Director methods
  f_directors = NewString("");
  Swig_register_filebyname("director", f_directors);

  // Director header file
  f_directors_h = NewString("");
  Swig_register_filebyname("director_h", f_directors_h);

  d_emitted_mangled = NewHash();
  d_callbacks = NewHash();
  d_overloads = NewHash();
  d_private_overloads = NewHash();

  // >>> PROCESS

  // Add standard SWIG classes, fragments
  Node *fragment_hash = NewHash();
  String *clsname = NewString("SwigClassWrapper");
  this->add_fsymbol(clsname, fragment_hash);
  Delete(fragment_hash);
  Delete(clsname);

  // Add module to proxy symbol table
  Node *module = Getattr(n, "module");
  String *modname = Swig_string_lower(Getattr(module, "name"));
  if (add_fsymbol(modname, module) == SWIG_NOWRAP)
    return SWIG_NOWRAP;

  // Note that documentation is a daughter node labeled "docstring";
  // to unify the doc string processing we just set it as a feature attribute
  if (Node *options = Getattr(module, "options")) {
    if (String *docstring = Getattr(options, "docstring")) {
      Setattr(module, "feature:docstring", docstring);
      this->write_docstring(module, f_fuse);
    }
    if (Getattr(options, "directors")) {
      this->allow_directors();
    }
  }

  Printf(f_runtime, "\n\n#ifndef SWIGFORTRAN\n#define SWIGFORTRAN\n#endif\n\n");
  if (directorsEnabled()) {
    Printf(f_runtime, "#define SWIG_DIRECTORS\n");

    Printf(f_directors, "\n\n");
    Printf(f_directors, "/* ---------------------------------------------------\n");
    Printf(f_directors, " * C++ director class methods\n");
    Printf(f_directors, " * --------------------------------------------------- */\n\n");
    String *outfile_h = Getattr(n, "outfile_h");
    ASSERT_OR_PRINT_NODE(outfile_h, n);
    String *filename = Swig_file_filename(outfile_h);
    Printf(f_directors, "#include \"%s\"\n\n", filename);
    Delete(filename);
  }

  // Write module title
  Printv(f_fuse, "module ", modname, "\n use, intrinsic :: ISO_C_BINDING\n", NULL);

  // Emit all other wrapper code
  Language::top(n);

  // >>> OUTPUT

  if (directorsEnabled()) {
    // Insert director runtime into the f_runtime file (make it occur before %header section)
    Swig_insert_file("director_common.swg", f_runtime);
    Swig_insert_file("director.swg", f_runtime);
  }

  // Write C++ wrapper file
  write_wrapper(Getattr(n, "outfile"));

  if (directorsEnabled()) {
    String *include_guard = NewStringf("SWIG_%s_WRAP_H_", modname);
    write_header(Getattr(n, "outfile_h"), include_guard);
    Delete(include_guard);
  }

  // Write fortran module file
  write_module(Getattr(n, "fortran:outfile"));

  // Clean up files and other data
  Delete(d_overloads);
  Delete(d_private_overloads);
  Delete(d_callbacks);
  Delete(d_emitted_mangled);
  Delete(f_fsubprograms);
  Delete(f_finterfaces);
  Delete(f_fdecl);
  Delete(f_fuse);
  Delete(f_init);
  Delete(f_wrapper);
  Delete(f_header);
  Delete(f_policies);
  Delete(f_runtime);
  Delete(f_fbegin);
  Delete(f_begin);

  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Write C++ wrapper code
 */
void FORTRAN::write_wrapper(String *filename) {
  // Open file
  File *out = NewFile(filename, "w", SWIG_output_files());
  if (!out) {
    FileErrorDisplay(filename);
    SWIG_exit(EXIT_FAILURE);
  }

  // Write SWIG auto-generation banner
  Swig_banner(out);

  // Write different sections
  Dump(f_begin, out);
  Dump(f_runtime, out);
  Dump(f_policies, out);
  Dump(f_header, out);
  Dump(f_directors, out);

  // Write wrapper code
  if (CPlusPlus)
    Printf(out, "extern \"C\" {\n");
  Dump(f_wrapper, out);
  if (CPlusPlus)
    Printf(out, "} // extern\n");

  // Write initialization code
  Wrapper_pretty_print(f_init, out);

  // Close file
  Delete(out);
}

/* -------------------------------------------------------------------------
 * \brief Write headers (director declarations)
 */
void FORTRAN::write_header(String *filename, String *include_guard) {
  // Open file
  File *out = NewFile(filename, "w", SWIG_output_files());
  if (!out) {
    FileErrorDisplay(filename);
    SWIG_exit(EXIT_FAILURE);
  }

  // Write SWIG auto-generation banner
  Swig_banner(out);
  Printv(out, "\n#ifndef ", include_guard, "\n#define ", include_guard, "\n\n", NULL);
  Dump(f_directors_h, out);
  Printv(out, "\n#endif /* ", include_guard, "*/\n", NULL);
  Delete(out);
}

/* -------------------------------------------------------------------------
 * \brief Write Fortran implementation module
 */
void FORTRAN::write_module(String *filename) {
  // Open file
  File *out = NewFile(filename, "w", SWIG_output_files());
  if (!out) {
    FileErrorDisplay(filename);
    SWIG_exit(EXIT_FAILURE);
  }

  // Write SWIG auto-generation banner
  Swig_banner_target_lang(out, "!");

  // Write module
  Dump(f_fbegin, out);
  Dump(f_fuse, out);
  Printv(out,
         " implicit none\n"
         " private\n",
         NULL);

  // Types and such
  Printv(out, "\n ! DECLARATION CONSTRUCTS\n", f_fdecl, NULL);

  // Overloads and renamed module procedures
  for (Iterator kv = First(d_overloads); kv.key; kv = Next(kv)) {
    Iterator proc_name_list = First(kv.item);
    if (!proc_name_list.item) {
      // Skip empty overload list, probably from lack of class constructors
      continue;
    }

    Printv(out,
           " interface ", kv.key, "\n"
           "  module procedure ",
           NULL);

    // Write overloaded procedure names
    int line_length = 19;
    line_length = print_wrapped_list(out, proc_name_list, line_length);
    Printv(out, "\n end interface\n", NULL);
    if (!GetFlag(d_private_overloads, kv.key)) {
      Printv(out, " public :: ", kv.key, "\n", NULL);
    }
  }

  if (Len(f_fabstract) > 0) {
    Printv(out,
           "\n! FUNCTION POINTER DECLARATIONS\n"
           "abstract interface\n",
           f_fabstract,
           "end interface\n"
           "\n",
           NULL);
  }
  if (Len(f_finterfaces) > 0) {
    Printv(out,
           "\n! WRAPPER DECLARATIONS\n"
           "interface\n",
           f_finterfaces,
           "end interface\n"
           "\n",
           NULL);
  }
  if (Len(f_fsubprograms) > 0) {
    Printv(out,
           "\ncontains\n"
           " ! MODULE SUBPROGRAMS\n",
           f_fsubprograms,
           NULL);
  }
  Printv(out, "\nend module", "\n", NULL);

  // Close file
  Delete(out);
}

/* -------------------------------------------------------------------------
 * \brief Process a %module
 */
int FORTRAN::moduleDirective(Node *n) {
  if (ImportMode) {
    // This %module directive is inside another module being %imported
    String *modname = Swig_string_lower(Getattr(n, "name"));
    Printv(f_fuse, " use ", modname, "\n", NULL);
    Delete(modname);
  }
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Wrap basic functions.
 *
 * This is called from many different handlers, including:
 *  - member functions
 *  - member variables (once each for get&set)
 *  - global variables (once each for get&set)
 *  - static functions
 */
int FORTRAN::functionWrapper(Node *n) {
  const bool member = GetFlag(n, "fortran:ismember");
  bool generic = false;

  // >>> SET UP WRAPPER NAME

  String *symname = Getattr(n, "sym:name");
  String *fsymname = NULL; // Fortran name alias (or member function name)
  String *fname = NULL;    // Fortran proxy function name; null if bind(C)
  String *imname = NULL;   // Fortran interface function name
  String *wname = NULL;    // SWIG C wrapper function name
  String *overload_ext = Getattr(n, "sym:overloaded") ? Getattr(n, "sym:overname") : NULL;

  // Generate a unique wrapper name
  wname = Swig_name_wrapper(symname);
  imname = ensure_short(NewStringf("swigc_%s", symname),
                        63 - (overload_ext ? Len(overload_ext) : 0));

  if (String *private_fname = Getattr(n, "fortran:fname")) {
    // Create "private" fortran wrapper function class (swigf_xx) name that will be bound to a class
    fname = Copy(private_fname);
    ASSERT_OR_PRINT_NODE(is_valid_identifier(fname), n);
  } else if (String *varname = Getattr(n, "fortran:variable")) {
    const char* prefix = (GetFlag(n, "memberset") || GetFlag(n, "varset")) ? "set" : "get";
    fname = ensure_short(NewStringf("%s_%s", prefix, varname));

    if (member) {
      // We're wrapping a static/member variable. The getter/setter name is an alias to the class-namespaced proxy function.
      fsymname = fname;
      fname = proxy_name_construct(this->getNSpace(), Getattr(n, "sym:name"));
    }
  } else {
    // Default: use symbolic function name
    fname = make_fname(symname, WARN_NONE);
  }

  if (String *manual_name = Getattr(n, "feature:fortran:generic")) {
    // Override the fsymname name for this function
    assert(!fsymname);
    fsymname = Copy(manual_name);
    generic = true;
  } else if (String *manual_name = Getattr(n, "fortran:name")) {
    // Override the fsymname name for this function
    assert(!fsymname);
    fsymname = Copy(manual_name);
  }

  // Add suffix if the function is overloaded (can't overload C bound functions)
  if (String *overload_ext = (Getattr(n, "sym:overloaded") ? Getattr(n, "sym:overname") : NULL)) {
    Append(wname, overload_ext);
    Append(imname, overload_ext);
    if (!fsymname) {
      // Overloaded functions become fsymname
      fsymname = fname;
      fname = proxy_name_construct(this->getNSpace(), symname);
    }
    fname = ensure_short(fname, 63 - Len(overload_ext));
    Append(fname, overload_ext);
    generic = true;
  }

  // Check for conflicts with other member functions in parent classes:
  // - If the lowercase/renamed function name is the same as any other class
  //   function (or base class's function), print a warning and ignore it.
  // - If the function shadows another function, the signature must match
  //   exactly: if the parent is 'generic', this one must be as well. If it's a
  //   subroutine, same deal.
  if (member) {
    assert(fsymname);
    String *lower_fsymname = Swig_string_lower(fsymname);
    Symtab *fsymtab = Getattr(this->getCurrentClass(), "fortran:symtab");
    Node *overload_base = NULL;

    // Check against lowercase name conflicts
    for (Symtab *st = fsymtab; st; st = parentNode(st)) {
      if (Node *other = Getattr(st, lower_fsymname)) {
        String *other_fsymname = Getattr(other, "wrap:fsymname");
        if (!other_fsymname) {
          other_fsymname = Getattr(other, "fortran:name");
        }
        if (other_fsymname && !Equal(other_fsymname, fsymname)) {
          // It's actually a different identifier
          Swig_warning(WARN_FORTRAN_NAME_COLLISION, input_file, line_number,
                       "Ignoring '%s' due to name conflict with '%s'\n",
                       fsymname, other_fsymname);
          Swig_warning(WARN_FORTRAN_NAME_COLLISION, Getfile(other), Getline(other),
                       "Previous declaration of '%s'\n",
                       Getattr(other, "sym:name"));
          SetFlag(n, "fortran:ignore");
          return SWIG_NOWRAP;
        } else if (st != fsymtab) {
          // Same function but in a base class
          overload_base = other;
        }
      }
    }

    // Check for shadowing/hiding base class function. Allow non-generic
    // functions to shadow base class functions.
    if (Node *other = Getattr(n, "hides")) {
      if (Getattr(other, "fortran:generic")) {
        Swig_warning(WARN_LANG_OVERLOAD_SHADOW, input_file, line_number,
                     "Ignoring '%s' because it shadows a generic base class function '%s'\n",
                     fsymname, Getattr(other, "fortran:name"));
        Swig_warning(WARN_LANG_OVERLOAD_SHADOW, Getfile(other), Getline(other),
                     "Previous declaration of '%s'\n",
                     Getattr(other, "sym:name"));
        SetFlag(n, "fortran:ignore");
        return SWIG_NOWRAP;
      }
    }

    // Check for different return type
    if (Node *other = Getattr(n, "override")) {
      if (SwigType *covar = Getattr(n, "covariant")) {
        Swig_warning(WARN_FORTRAN_COVARIANT_RET, input_file, line_number,
                     "Ignoring '%s' because the base class function '%s' has a different return type '%s'\n",
                     fsymname, Getattr(other, "fortran:name"),
                     SwigType_str(covar, NULL));
        Swig_warning(WARN_FORTRAN_COVARIANT_RET, Getfile(other), Getline(other),
                     "Previous declaration of '%s'\n",
                     Getattr(other, "sym:name"));
        SetFlag(n, "fortran:ignore");
        return SWIG_NOWRAP;
      }

      if (Getattr(other, "fortran:generic")) {
        // The base class's method is wrapped and it's generic. Do *not*
        // generate a wrapper for this function since it would be ambiguous
        // with the base class.
        SetFlag(n, "fortran:ignore");
        return SWIG_NOWRAP;
      }
    }

    if (Node *other = overload_base) {
      // Same name as a base class function; either implementing it or
      // overloading it.
      if (Getattr(other, "fortran:generic")) {
        // Parent class's function is generic, so must we be too
        generic = true;
      } else if (generic) {
        Swig_warning(WARN_LANG_OVERLOAD_SHADOW, input_file, line_number,
                     "Ignoring generic '%s': it cannot override a specific binding '%s' with the same name\n",
                     fsymname, Getattr(other, "fortran:name"));
        Swig_warning(WARN_LANG_OVERLOAD_SHADOW, Getfile(other), Getline(other),
                     "Previous declaration of '%s'\n",
                     Getattr(other, "sym:name"));
        SetFlag(n, "fortran:ignore");
        return SWIG_NOWRAP;
      }
      // Mark the function as overriding in Fortran, even though it may not be
      // overriding in C++
      Setattr(n, "fortran:override", other);
    }

    // Add name to the symtab
    Setattr(fsymtab, lower_fsymname, n);

    Delete(lower_fsymname);
  }

  if (generic) {
    Setattr(n, "fortran:generic", fsymname);
  }

  // Add the interface subroutine name to the module scope
  if (add_fsymbol(imname, n) == SWIG_NOWRAP)
    return SWIG_NOWRAP;
  // Add the fortran subroutine name to the module scope
  if (add_fsymbol(fname, n) == SWIG_NOWRAP)
    return SWIG_NOWRAP;

  // Save wrapper names
  Setattr(n, "wrap:name", wname);
  Setattr(n, "wrap:imname", imname);
  Setattr(n, "wrap:fname", fname);
  // Note: since this node may be used to generate multiple functions (e.g.
  // 'set' and 'get'), do *not* save as 'fortran:name'.
  if (fsymname) {
    Setattr(n, "wrap:fsymname", fsymname);
  }

  if (member) {
    if (String *selfname = Getattr(n, "fortran:rename_self")) {
      // Modify the first parameter name so that custom types will match
      // But pre-calculate the original name so that user-facing argument names match
      Parm *first_parm = Getattr(n, "parms");
      ASSERT_OR_PRINT_NODE(first_parm, n);
      this->makeParameterName(n, first_parm, 0);
      Setattr(first_parm, "name", selfname);
    }
  }

  // >>> GENERATE WRAPPER CODE

  int result = SWIG_NOWRAP;
  Wrapper *cfunc = this->cfuncWrapper(n);
  Wrapper *imfunc = cfunc ? this->imfuncWrapper(n, false) : NULL;
  Wrapper *ffunc = imfunc ? this->proxyfuncWrapper(n) : NULL;
  if (ffunc) {
    Wrapper_print(cfunc, f_wrapper);
    Wrapper_print(imfunc, f_finterfaces);
    Wrapper_print(ffunc, f_fsubprograms);
    result = SWIG_OK;
  }

  if (cfunc)
    DelWrapper(cfunc);
  if (imfunc)
    DelWrapper(imfunc);
  if (ffunc)
    DelWrapper(ffunc);

  if (result != SWIG_OK) {
    SetFlag(n, "fortran:ignore");
    return result;
  }

  // >>> GENERATE CODE FOR MODULE INTERFACE

  bool fprivate = GetFlag(n, "fortran:private");
  if (member) {
    // Wrapping a member function
    ASSERT_OR_PRINT_NODE(!this->is_bindc_struct(), n);
    ASSERT_OR_PRINT_NODE(f_class, n);
    ASSERT_OR_PRINT_NODE(fname, n);
    ASSERT_OR_PRINT_NODE(fsymname, n);

    String *qualifiers = NewStringEmpty();

    if (generic || fprivate) {
      Append(qualifiers, ", private");
    }
    if (String *extra_quals = Getattr(n, "fortran:procedure")) {
      Printv(qualifiers, ", ", extra_quals, NULL);
    }

    Printv(f_class, "  procedure", qualifiers, " :: ", NULL);

    if (!generic) {
      // Declare procedure name, aliasing the private mangled function name
      // Add qualifiers like "static" for static functions
      Printv(f_class, fsymname, " => ", fname, "\n", NULL);
    } else {
      // Add name to method overload list
      List *overloads = Getattr(d_method_overloads, fsymname);
      if (!overloads) {
        overloads = NewList();
        Setattr(d_method_overloads, fsymname, overloads);
      }
      Append(overloads, fname);

      // Declare a private procedure
      Printv(f_class, fname, "\n", NULL);
    }
  } else if (fsymname) {
    int result = this->add_overload(fsymname, n, fname, fprivate);
    if (result == SWIG_NOWRAP)
      return SWIG_NOWRAP;
  } else if (!fprivate) {
    // Expose the proxy function with its native name
    ASSERT_OR_PRINT_NODE(fname && Len(fname) > 0, n);
    Printv(f_fdecl, " public :: ", fname, "\n", NULL);
  }

  if (Getattr(n, "fortran:variable") && !Getattr(n, "feature:immutable")) {
    // This variable has both a getter and setter, so the node will be reused
    // (generating two different functions). Avoid name conflicts by deleting
    // `fortran:name`.
    Delattr(n, "fortran:name");
    Delattr(n, "wrap:fsymname");
    Delattr(n, "fortran:subroutine");
  }

  Delete(fname);
  Delete(imname);
  Delete(wname);
  Delete(fsymname);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Generate C/C++ wrapping code
 */
Wrapper * FORTRAN::cfuncWrapper(Node *n) {
  String *symname = Getattr(n, "sym:name");

  Wrapper *cfunc = NewWrapper();

  // >>> RETURN VALUES

  // Get the SWIG type representation of the C return type, but first the
  // ctype typemap has to be attached
  Swig_typemap_lookup("ctype", n, Getattr(n, "name"), NULL);
  SwigType *c_return_type = parse_typemap("ctype", n, WARN_FORTRAN_TYPEMAP_CTYPE_UNDEF);
  if (!c_return_type) {
    Swig_error(input_file, line_number,
               "Failed to parse 'ctype' typemap return value of '%s'\n",
               symname);
    return NULL;
  }

  const bool is_csubroutine = (Strcmp(c_return_type, "void") == 0);

  String *c_return_str = NULL;
  if (return_type_needs_typedef(c_return_type)) {
    // For these types (where the name is the middle of the expression rather than at the right side,
    // i.e. void (*func)() instead of int func, we either have to add a new typedef OR wrap the
    // entire function in parens. The former is easier.
    c_return_str = NewStringf("%s_swigrtype", symname);

    String *typedef_str = SwigType_str(c_return_type, c_return_str);
    Printv(cfunc->def, "typedef ", typedef_str, ";\n", NULL);
    Delete(typedef_str);
  } else {
    // Typical case: convert return type into a regular string
    c_return_str = SwigType_str(c_return_type, NULL);
  }

  Printv(cfunc->def, "SWIGEXPORT ", c_return_str, " ", Getattr(n, "wrap:name"), "(", NULL);

  if (!is_csubroutine) {
    // Add local variables for result
    Wrapper_add_localv(cfunc, "fresult", c_return_str, "fresult", NULL);
  }

  // >>> FUNCTION PARAMETERS/ARGUMENTS

  // Emit all of the local variables for holding arguments.
  ParmList *parmlist = Getattr(n, "parms");
  emit_parameter_variables(parmlist, cfunc);
  Swig_typemap_attach_parms("ctype", parmlist, cfunc);
  emit_attach_parmmaps(parmlist, cfunc);
  emit_mark_varargs(parmlist);
  Setattr(n, "wrap:parms", parmlist);

  if (Getattr(n, "sym:overloaded")) {
    // After emitting parameters, check for invalid overloads
    Swig_overload_check(n);
    if (Getattr(n, "overload:ignore")) {
      DelWrapper(cfunc);
      return NULL;
    }
  }

  // Create a list of parameters wrapped by the intermediate function
  List *cparmlist = NewList();

  // Loop using the 'tmap:in:next' property rather than 'nextSibling' to account for multi-argument typemaps
  const char *prepend_comma = "";
  for (Parm *p = parmlist; p; p = Getattr(p, "tmap:in:next")) {
    if (checkAttribute(p, "tmap:in:numinputs", "0")) {
      // The typemap is being skipped with the 'numinputs=0' keyword
      continue;
    }
    if (checkAttribute(p, "varargs:ignore", "1")) {
      // We don't understand varargs
      Swig_warning(WARN_LANG_NATIVE_UNIMPL, Getfile(p), Getline(p),
                   "Variable arguments (in function '%s') are not implemented in Fortran.\n",
                   Getattr(n, "sym:name"));
      continue;
    }

    // Name of the argument in the function call (e.g. farg1)
    String *imname = NewStringf("f%s", Getattr(p, "lname"));
    Setattr(p, "imname", imname);
    Append(cparmlist, p);

    // Get the user-provided C type string, and convert it to a SWIG
    // internal representation using Swig_cparse_type
    SwigType *ctype = parse_typemap("ctype", "in", p, WARN_FORTRAN_TYPEMAP_CTYPE_UNDEF);
    if (!ctype) {
      Swig_error(input_file, line_number,
                 "Failed to parse 'ctype' typemap for argument '%s' of '%s'\n",
                 SwigType_str(Getattr(p, "type"), Getattr(p, "name")), symname);
      return NULL;
    }
    // Convert the type and argument name to a valid C expression
    String *carg = SwigType_str(ctype, imname);
    Printv(cfunc->def, prepend_comma, carg, NULL);
    Delete(carg);

    // Since we successfully output an argument, the next one should have a comma before it
    prepend_comma = ", ";
  }

  // Save list of wrapped parms for im declaration and proxy
  Setattr(n, "wrap:cparms", cparmlist);

  // END FUNCTION DEFINITION
  Printv(cfunc->def, ") {", NULL);

  // >>> CHECK FOR MISSING TYPES

  if (GetFlag(n, "feature:fortran:onlywrapped")) {
    // Check return type
    if (!this->is_wrapped_class(n)) {
      DelWrapper(cfunc);
      return NULL;
    }
    for (Iterator it = First(cparmlist); it.item; it = Next(it)) {
      if (!this->is_wrapped_class(it.item)) {
        DelWrapper(cfunc);
        return NULL;
      }
    }
  }

  // >>> ADDITIONAL WRAPPER CODE

  String *cleanup = NewStringEmpty();
  String *outarg = NewStringEmpty();

  // Add input conversion for parameters being passed through the C wrapper
  for (Iterator it = First(cparmlist); it.item; it = Next(it)) {
    Parm *p = it.item;
    if (String *tm = Getattr(p, "tmap:in")) {
      this->replace_fclassname(n, Getattr(p, "type"), tm);
      String *imname = Getattr(p, "imname");
      Replaceall(tm, "$input", imname);
      Setattr(p, "emit:input", imname);
      Printv(cfunc->code, tm, "\n", NULL);
    }
  }

  // Insert constraint checking and cleanup code.
  // Note that this loops over *all* input parameters, even those that
  // are ignored or have numinputs=0.
  for (Parm *p = parmlist; p; p = nextSibling(p)) {
    if (String *tm = Getattr(p, "tmap:check")) {
      Replaceall(tm, "$input", Getattr(p, "emit:input"));
      Printv(cfunc->code, tm, "\n", NULL);
    }
    if (String *tm = Getattr(p, "tmap:argout")) {
      Replaceall(tm, "$result", "fresult");
      Replaceall(tm, "$input", Getattr(p, "emit:input"));
      Printv(outarg, tm, "\n", NULL);
    }
    if (String *tm = Getattr(p, "tmap:freearg")) {
      Replaceall(tm, "$input", Getattr(p, "emit:input"));
      Printv(cleanup, tm, "\n", NULL);
    }
  }

  // Generate code to make the C++ function call
  Swig_director_emit_dynamic_cast(n, cfunc);
  String *actioncode = emit_action(n);

  // Generate code to return the value
  String *return_cpptype = Getattr(n, "type");
  if (String *code = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), cfunc, actioncode)) {
    if (Len(code) > 0) {
      // Output typemap is defined; emit the function call and result
      // conversion code
      Replaceall(code, "$result", "fresult");
      Replaceall(code, "$owner", (GetFlag(n, "feature:new") ? "1" : "0"));
      Printv(cfunc->code, code, "\n", NULL);
    }
  } else {
    // XXX this should probably raise an error
    Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
                 "Unable to use return type %s in function %s.\n",
                 SwigType_str(return_cpptype, NULL), Getattr(n, "name"));
  }
  emit_return_variable(n, return_cpptype, cfunc);

  // Output argument output and cleanup code
  Printv(cfunc->code, outarg, NULL);
  Printv(cfunc->code, cleanup, NULL);

  // Return value "resource management", as opposed to the "out" typemap's
  // "value conversion" (not used in any of SWIG codebase as far as I can
  // tell; only mentioned once in manual)
  if (String *ret_code = Swig_typemap_lookup("ret", n, Swig_cresult_name(), NULL)) {
    Chop(ret_code);
    Printv(cfunc->code, ret_code, "\n", NULL);
  }

  if (!is_csubroutine) {
    String *qualified_return = SwigType_rcaststr(c_return_str, "fresult");
    Printf(cfunc->code, "    return %s;\n", qualified_return);
    Delete(qualified_return);
  }

  Printf(cfunc->code, "}\n");

  if (Getattr(n, "feature:contract")) {
    // Update contract assertion macro to include the neded return function
    Replaceall(cfunc->code, "SWIG_contract_assert(", "SWIG_contract_assert(return $null, ");
  }

  // Apply standard SWIG substitutions
  if (Strstr(cfunc->code, "$")) {
    // Cleanup code if a function exits early -- in practice, not used.
    Replaceall(cfunc->code, "$cleanup", cleanup);
    // Function name for error messages
    if (Strstr(cfunc->code, "$decl")) {
      // Full function name
      String *decl = Swig_name_decl(n);
      Replaceall(cfunc->code, "$decl", decl);
      Delete(decl);
    }

    // Get 'null' return type if specified
    String *null_return_type = Getattr(n, "tmap:ctype:null");
    Replaceall(cfunc->code, "$null", null_return_type ? null_return_type : "0");

    // Apply standard SWIG substitutions
    Replaceall(cfunc->code, "$symname", Getattr(n, "sym:name"));
  }

  // Write the C++ function into the wrapper code file

  Delete(cparmlist);
  Delete(outarg);
  Delete(cleanup);
  Delete(c_return_str);

  return cfunc;
}

/* -------------------------------------------------------------------------
 * \brief Generate Fortran interface code
 *
 * This is the Fortran equivalent of the cfuncWrapper's declaration.
 */
Wrapper *FORTRAN::imfuncWrapper(Node *n, bool bindc) {
  const char * const tmtype = bindc ? "bindc" : "imtype";
  const int warning_flag = bindc ? WARN_TYPEMAP_UNDEF : WARN_FORTRAN_TYPEMAP_IMTYPE_UNDEF;

  Wrapper *imfunc = NewFortranWrapper();

  // >>> RETURN VALUES

  String *return_cpptype = Getattr(n, "type");

  // Attach typemap for return value
  String *return_imtype = attach_typemap(tmtype, n, warning_flag);
  if (bindc && !return_imtype) {
    return NULL;
  }
  this->replace_fclassname(n, return_cpptype, return_imtype);

  const bool is_imsubroutine = (Len(return_imtype) == 0);

  // Determine based on return typemap whether it's a function or subroutine (we could equivalently check that return_cpptype is `void`)
  const char *im_func_type = (is_imsubroutine ? "subroutine" : "function");
  Printv(imfunc->def, im_func_type, " ", Getattr(n, "wrap:imname"), "(", NULL);

  // Hash of import statements needed for the interface code
  Hash *imimport_hash = NewHash();

  // If return type is a fortran C-bound type, add import statement
  if (String *imimport = make_import_string(return_imtype)) {
    SetFlag(imimport_hash, imimport);
    Delete(imimport);
  }

  // >>> FUNCTION PARAMETERS/ARGUMENTS

  ParmList *parmlist = Getattr(n, "parms");
  Swig_typemap_attach_parms(tmtype, parmlist, NULL);

  // Get the list of actual parameters used by the C function
  // (these are pointers to values in parmlist, with some elements possibly
  // removed)
  List *cparmlist = Getattr(n, "wrap:cparms");
  assert(cparmlist);

  // Append "using" statements and dummy variables to the interface
  // "definition" (before the code and local variable declarations)
  String *imlocals = NewStringEmpty();

  // >>> BUILD WRAPPER FUNCTION AND INTERFACE CODE
  List *imfunc_arglist = NewList();
  for (Iterator it = First(cparmlist); it.item; it = Next(it)) {
    Parm *p = it.item;

    // Add function parameter name (e.g. farg1) to the arglist
    String *imname = Getattr(p, "imname");
    Append(imfunc_arglist, imname);

    // Add dummy argument to wrapper body
    String *imtype = get_typemap(tmtype, "in", p, warning_flag);
    if (!imtype) {
      return NULL;
    }
    if (fix_fortran_dims(p, tmtype, imtype) != SWIG_OK) {
      DelWrapper(imfunc);
      return NULL;
    }
    this->replace_fclassname(n, Getattr(p, "type"), imtype);
    Printv(imlocals, "\n   ", imtype, " :: ", imname, NULL);

    // Include import statements if present; needed for actual structs
    // passed into interface code
    if (String *imimport = make_import_string(imtype)) {
      SetFlag(imimport_hash, imimport);
      Delete(imimport);
    }
  }

  // END FUNCTION DEFINITION
  print_wrapped_list(imfunc->def, First(imfunc_arglist), Len(imfunc->def));
  Printv(imfunc->def, ") &\n    bind(C", NULL);

  if (String *wname = Getattr(n, "wrap:name")) {
    // Binding to an acutal function
    Printv(imfunc->def, ", name=\"", wname, "\")", NULL);
  } else {
    // Creating an abstract interface
    Printv(imfunc->def, ")", NULL);
  }

  if (!is_imsubroutine) {
    // Declare dummy return value if it's a function
    Printv(imfunc->def, " &\n     result(fresult)", NULL);
    Printv(imlocals, "\n", return_imtype, " :: fresult", NULL);
  }

  // Write the function local block
  Printv(imfunc->code, "   use, intrinsic :: ISO_C_BINDING", NULL);
  for (Iterator kv = First(imimport_hash); kv.key; kv = Next(kv)) {
    Printv(imfunc->code, "\n   import :: ", kv.key, NULL);
  }
  Printv(imfunc->code, imlocals, "\n  end ", im_func_type, NULL);

  Delete(imimport_hash);
  return imfunc;
}

/* -------------------------------------------------------------------------
 * \brief Generate Fortran proxy code
 *
 * This is for the native Fortran interaction.
 */
Wrapper *FORTRAN::proxyfuncWrapper(Node *n) {
  Wrapper *ffunc = NewFortranWrapper();

  // Write documentation
  this->write_docstring(n, ffunc->def);

  // >>> FUNCTION RETURN VALUES

  String *return_ftype = attach_typemap("ftype", n, WARN_FORTRAN_TYPEMAP_FTYPE_UNDEF);
  if (fix_fortran_dims(n, "ftype", return_ftype) != SWIG_OK) {
    DelWrapper(ffunc);
    return SWIG_ERROR;
  }
  assert(return_ftype);

  // Return type for the C call
  String *return_imtype = get_typemap("imtype", n, WARN_NONE);

  // Check whether the Fortran proxy routine returns a variable, and whether
  // the actual C function does

  // Replace any instance of $fortranclassname in return type
  SwigType *return_cpptype = Getattr(n, "type");
  this->replace_fclassname(n, return_cpptype, return_ftype);
  this->replace_fclassname(n, return_cpptype, return_imtype);

  // String for calling the im wrapper on the fortran side (the "action")
  String *fcall = NewStringEmpty();

  const bool is_imsubroutine = (Len(return_imtype) == 0);
  if (!is_imsubroutine) {
    Wrapper_add_localv(ffunc, "fresult", return_imtype, ":: fresult", NULL);
    // Call function and set intermediate result
    Printv(fcall, "fresult = ", NULL);
  } else {
    Printv(fcall, "call ", NULL);
  }
  Printv(fcall, Getattr(n, "wrap:imname"), "(", NULL);

  // See whether to convert to a subroutine. Overriding daughter must match
  // parent, and overloaded functions much all match.
  bool is_fsubroutine = (Len(return_ftype) == 0);
  bool func_to_subroutine = !is_imsubroutine && GetFlag(n, "feature:fortran:subroutine");
  Node *conflicting_subroutine = NULL;

  Node *overridden = Getattr(n, "fortran:override");
  if (overridden && !(Getattr(n, "fortran:variable") && Getattr(overridden, "fortran:variable"))) {
    // Overridden, but *not* a variable, which can get wrapped twice (for getters and setters)
    String *is_parent_subroutine = Getattr(overridden, "fortran:subroutine");
    if (is_parent_subroutine != NULL && is_parent_subroutine != subroutine_flag_str(is_fsubroutine)) {
      // The parent procedure's return value conflicts with this one. (Perhaps the
      // conversion feature was applied only to the parent class, or a weird
      // typemap is in play?)
      conflicting_subroutine = overridden;
    }
  }

  if (Node *overload = Getattr(n, "sym:overloaded")) {
    // Skip ignored overloads or uninstantiated overloads (friend functions implicitly instantiated
    // in a templated struct, see friends.i)
    while (overload && (GetFlag(overload, "fortran:ignore") || !Getattr(overload, "fortran:subroutine"))) {
      overload = Getattr(overload, "sym:nextSibling");
    }
    if (overload && overload != n) {
      String *is_sibling_fsubroutine = Getattr(overload, "fortran:subroutine");
      if (!Equal(is_sibling_fsubroutine, subroutine_flag_str(is_fsubroutine))) {
        // The parent procedure's return value conflicts with this one. (Perhaps the
        // conversion feature was applied only to the parent class, or a weird
        // typemap is in play?)
        conflicting_subroutine = overload;
      }
    }
  }

  // Mark as a subroutine if it's naturally a subroutine or is being converted;
  // but mark it as a function if it's not being wrapped because it looks like
  // a subroutine. This allows later non-void functions to correctly wrapped as
  // functions.
  is_fsubroutine = (is_fsubroutine || func_to_subroutine) && !conflicting_subroutine;

  // Before possibly returning, save whether we're a subroutine in case of other overloads
  Setattr(n, "fortran:subroutine", subroutine_flag_str(is_fsubroutine));

  if (conflicting_subroutine) {
    // An already-wrapped overloaded function already has been declared as
    // a Fortran function.
    Swig_warning(WARN_LANG_OVERLOAD_IGNORED, Getfile(n), Getline(n),
                 "Overloaded function cannot return both 'void' and non-'void' in Fortran: ignoring\n");
    Swig_warning(WARN_LANG_OVERLOAD_IGNORED, Getfile(conflicting_subroutine), Getline(conflicting_subroutine),
                 "Other function declared here\n");
    DelWrapper(ffunc);
    return NULL;
  }

  if (func_to_subroutine && GetFlag(n, "tmap:ftype:nofortransubroutine")) {
    Swig_warning(WARN_FORTRAN_NO_SUBROUTINE, Getfile(n), Getline(n),
                 "The given type '%s' cannot be converted from a function result to an optional subroutine argument\n",
                 return_cpptype);
    func_to_subroutine = false;
    is_fsubroutine = false;
    if (!GetFlag(n, "feature:fortran:subroutine")) {
      // Feature was *automatically* set, so it will generate invalid Fortran
      // unless we exit now
      DelWrapper(ffunc);
      return NULL;
    }
  }

  String *swig_result_name = NULL;
  if (!is_fsubroutine || func_to_subroutine) {
    // Return dummy argument name for function, or `intent(out), optional` name
    // for the function-to-subroutine case
    if (overridden) {
      swig_result_name = Getattr(overridden, "wrap:fresult");
    }
    if (!swig_result_name) {
      swig_result_name = Getattr(n, "wrap:fresult");
    }
    if (!swig_result_name) {
      swig_result_name = NewString("swig_result");
    } else {
      swig_result_name = Copy(swig_result_name);
    }
  }

  String *fargs = NewStringEmpty();
  if (!is_fsubroutine) {
    // Add dummy variable for Fortran proxy return
    Printv(fargs, return_ftype, " :: ", swig_result_name, "\n", NULL);
  }

  // >>> FUNCTION NAME

  const char *f_func_type = (is_fsubroutine ? "subroutine" : "function");
  String *fsymname = Getattr(n, "wrap:fname");
  Printv(ffunc->def, f_func_type, " ", fsymname, "(", NULL);

  // >>> FUNCTION PARAMETERS/ARGUMENTS

  // Get the list of actual parameters used by the C function
  // (these are pointers to values in parmlist, with some elements possibly
  // removed)
  List *cparmlist = Getattr(n, "wrap:cparms");
  assert(cparmlist);

  for (Iterator it = First(cparmlist); it.item; it = Next(it)) {
    Parm *p = it.item;
    // Temporarily set lname to imname so that "fin" typemap will
    // substitute farg1 instead of arg1
    Setattr(p, "proxyfuncWrapper:lname", Getattr(p, "lname"));
    Setattr(p, "lname", Getattr(p, "imname"));
  }

  // Attach proxy input typemap (proxy arg -> farg1 in fortran function)
  ParmList *parmlist = Getattr(n, "parms");
  Swig_typemap_attach_parms("ftype", parmlist, ffunc);
  Swig_typemap_attach_parms("fin", parmlist, ffunc);
  Swig_typemap_attach_parms("fargout", parmlist, ffunc);

  // Restore parameter names
  for (Iterator it = First(cparmlist); it.item; it = Next(it)) {
    Parm *p = it.item;
    String *imname = Getattr(p, "imname");

    // Add any needed temporary variables to convert to typemap
    if (String *temptype = Getattr(p, "tmap:fin:temp")) {
      Chop(temptype);
      if (Len(temptype) > 0) {
        String *tempname = NewStringf("%s_temp", imname);
        this->replace_fclassname(n, Getattr(p, "type"), temptype);
        Wrapper_add_localv(ffunc, tempname, temptype, "::", tempname, NULL);
      }
    }

    // Emit local intermediate parameter in the proxy function
    String *imtype = get_typemap("imtype", p, WARN_FORTRAN_TYPEMAP_IMTYPE_UNDEF);
    this->replace_fclassname(n, Getattr(p, "type"), imtype);
    Wrapper_add_localv(ffunc, imname, imtype, "::", imname, NULL);

    // Restore local variable name
    Setattr(p, "lname", Getattr(p, "proxyfuncWrapper:lname"));
    Delattr(p, "proxyfuncWrapper:lname");
  }

  // >>> BUILD WRAPPER FUNCTION AND INTERFACE CODE

  String *prepend = Getattr(n, "feature:fortran:prepend");
  if (prepend) {
    Chop(prepend);
    Printv(ffunc->code, prepend, "\n", NULL);
  }

  // Fortran requires that an overriding procedure has exactly the same dummy
  // argument names. We want to change and warn if they're different. If the
  // *number* is different (weird typemap applied to either just the parent or
  // just the daughter function) then we have to give up.
  List *parent_arglist = NULL;
  Iterator parent_arg;
  if (overridden) {
    parent_arglist = Getattr(overridden, "fortran:fargs");
    parent_arg = First(parent_arglist);
  }

  int i = 0;
  List *ffunc_arglist = NewList();
  List *fcall_arglist = NewList();
  for (Iterator it = First(cparmlist); it.item; it = Next(it)) {
    Parm *p = it.item;

    // Get Fortran type *before* generating parameter name
    // to avoid generating `class(A) :: a` when faced with
    //   struct A;
    //   void blah(A* a);
    //   struct A{};
    String *ftype = get_typemap("ftype", "in", p, WARN_FORTRAN_TYPEMAP_FTYPE_UNDEF);
    if (fix_fortran_dims(p, "ftype", ftype) != SWIG_OK) {
      DelWrapper(ffunc);
      return NULL;
    }
    this->replace_fclassname(n, Getattr(p, "type"), ftype);

    // Add parameter name to declaration list
    String *farg = this->makeParameterName(n, p, i++);
    if (parent_arglist) {
      if (!parent_arg.item) {
        Swig_error(input_file, line_number,
                   "Function '%s' has a different number of Fortran arguments from the function it overrides\n",
                   fsymname);
        Swig_error(Getfile(overridden), Getline(overridden), "Base class function declared here\n");
        return NULL;
      }
      if (Strcmp(farg, parent_arg.item) != 0) {
        Swig_warning(WARN_FORTRAN_ARGUMENT_NAME, Getfile(n), Getline(n),
                     "Changing argument name '%s' to '%s' to match the overridden function '%s'\n",
                     farg,
                     parent_arg.item,
                     fsymname);
        Delete(farg);
        farg = Copy(parent_arg.item);
      }
      parent_arg = Next(parent_arg);
    }
    Append(ffunc_arglist, farg);

    // Add dummy argument to wrapper body
    Printv(fargs, "   ", ftype, " :: ", farg, "\n", NULL);

    // Add this argument to the intermediate call function
    Append(fcall_arglist, Getattr(p, "imname"));

    // >>> F PROXY CONVERSION

    String *fin = get_typemap("fin", p, WARN_TYPEMAP_IN_UNDEF);
    if (Len(fin) > 0) {
      Replaceall(fin, "$input", farg);
      Printv(ffunc->code, fin, "\n", NULL);
    }

    Delete(farg);
  }

  if (func_to_subroutine) {
    assert(swig_result_name);
    Append(ffunc_arglist, swig_result_name);

    Printv(fargs, return_ftype, ", intent(out), optional :: ", swig_result_name, "\n", NULL);
  }

  // END FUNCTION DEFINITION
  print_wrapped_list(ffunc->def, First(ffunc_arglist), Len(ffunc->def));
  Printv(ffunc->def, ")", NULL);
  if (!is_fsubroutine) {
    Setattr(n, "fname", swig_result_name);
    Printv(ffunc->def, " &\n     result(", swig_result_name, ")", NULL);
  }

  if (Cmp(Getattr(n, "storage"), "virtual") == 0) {
    // Save argument names so that potentially overridden classes
    Setattr(n, "fortran:fargs", ffunc_arglist);
  }

  Delete(ffunc_arglist);

  // END FUNCTION DEFINITION
  print_wrapped_list(fcall, First(fcall_arglist), Len(fcall));
  Printv(fcall, ")", NULL);
  Delete(fcall_arglist);

  // Save fortran function call action
  Setattr(n, "wrap:faction", fcall);

  // Emit code to make the Fortran function call in the proxy code
  if (String *action_wrap = Getattr(n, "feature:shadow")) {
    Replaceall(action_wrap, "$action", fcall);
    Chop(action_wrap);
    Printv(ffunc->code, action_wrap, "\n", NULL);
  } else {
    Printv(ffunc->code, fcall, "\n", NULL);
  }

  // Append dummy variables to the proxy function definition
  Chop(fargs);
  Printv(ffunc->def, "\n   use, intrinsic :: ISO_C_BINDING\n", fargs, NULL);

  // >>> ADDITIONAL WRAPPER CODE

  // Get the typemap for output argument conversion
  Parm *outparm = NewParm(return_cpptype, Getattr(n, "name"), n);
  Setattr(outparm, "lname", "fresult"); // Replaces $1
  String *fbody = attach_typemap("fout", outparm, WARN_FORTRAN_TYPEMAP_FOUT_UNDEF);

  // Add any needed temporary variables
  if (String *temptype = Getattr(outparm, "tmap:fout:temp")) {
    Chop(temptype);
    if (Len(temptype) > 0) {
      const char *tempname = "fresult_temp";
      Wrapper_add_localv(ffunc, tempname, temptype, "::", tempname, NULL);
    }
  }
  Delete(outparm);

  // Output typemap is defined; emit the function call and result
  // conversion code
  Chop(fbody);
  if (Len(fbody) > 0) {
    if (func_to_subroutine) {
      Insert(fbody, 0, "if (present($result)) then\n");
    }
    Replaceall(fbody, "$result", swig_result_name);
    Replaceall(fbody, "$owner", (GetFlag(n, "feature:new") ? ".true." : ".false."));
    this->replace_fclassname(n, return_cpptype, fbody);
    if (func_to_subroutine) {
      Printv(fbody, "\nendif\n", NULL);
    }
    Printv(ffunc->code, fbody, "\n", NULL);
  }

  // Add post-call conversion routines for input arguments
  for (Iterator it = First(cparmlist); it.item; it = Next(it)) {
    Parm *p = it.item;
    String *tm = Getattr(p, "tmap:fargout");
    if (tm && Len(tm) > 0) {
      Chop(tm);
      Replaceall(tm, "$result", swig_result_name);
      Replaceall(tm, "$input", Getattr(p, "fname"));
      Replaceall(tm, "$1", Getattr(p, "imname"));
      Printv(ffunc->code, tm, "\n", NULL);
    }
  }

  // Optional "append" proxy code
  String *append = Getattr(n, "feature:fortran:append");
  if (append) {
    Chop(append);
    Printv(ffunc->code, append, "\n", NULL);
  }

  // Output argument output and cleanup code
  Printv(ffunc->code, "  end ", f_func_type, NULL);

  // Write the C++ function into the wrapper code file
  Delete(fcall);
  Delete(fargs);
  Delete(swig_result_name);
  return ffunc;
}

/* -------------------------------------------------------------------------
 * Generate wrappers for a %fortranbindc global variable.
 */
int FORTRAN::bindcvarWrapper(Node *n) {
  String *fsymname = this->get_fsymname(n);
  if (!fsymname) {
    return SWIG_NOWRAP;
  }

  String *bindc_typestr = attach_typemap("bindc", n, WARN_NONE);
  if (!bindc_typestr) {
    Swig_warning(WARN_TYPEMAP_UNDEF, Getfile(n), Getline(n),
                 "The 'bindc' typemap for '%s' is not defined, so the corresponding variable cannot be generated\n",
                 SwigType_str(Getattr(n, "type"), Getattr(n, "sym:name")));
    return SWIG_NOWRAP;
  }

  if (fix_fortran_dims(n, "bindc", bindc_typestr) != SWIG_OK) {
    return SWIG_NOWRAP;
  }

  if (CPlusPlus && !Swig_storage_isexternc(n)) {
    Swig_error(input_file,
               line_number,
               "The C++ global variable '%s' is not defined with external "
               "C linkage (extern \"C\"), but it is marked with %%fortranbindc.\n",
               Getattr(n, "sym:name"));
    return SWIG_ERROR;
  }

  String *name = Getattr(n, "name");
  ASSERT_OR_PRINT_NODE(name, n);
  ASSERT_OR_PRINT_NODE(Getattr(n, "type"), n);

  const char* protection_str = "";
  if (strncmp(Char(Getattr(n, "type")), "q(const)", 8) == 0) {
    protection_str = "protected, ";
  }

  Printv(f_fdecl, " ", bindc_typestr, ", public, ", protection_str, "&\n",
         "   bind(C, name=\"", name, "\") :: ",
         (Len(name) > 60 ? "&\n    " : ""),
         fsymname, "\n",
         NULL);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * Add an assignment operator.
 *
 * The LHS must be intent(inout), and the RHS must be intent(in).
 */
void FORTRAN::add_assignment_operator(Node *classn) {
  ASSERT_OR_PRINT_NODE(Strcmp(nodeType(classn), "class") == 0 && !this->is_bindc_struct(), classn);

  // Create new node representing self-assignment function
  Node *n = NewHash();
  set_nodeType(n, "cdecl");
  Setfile(n, Getfile(classn));
  Setline(n, Getline(classn));

  String *name = NewString("operator =");
  String *symname = NewString("op_assign__");

  Setattr(n, "kind", "function");
  Setattr(n, "name", name);
  Setattr(n, "sym:name", symname);
  Setattr(n, "feature:fortran:generic", "assignment(=)");

  // Add to the class's symbol table
  Symtab *prev_scope = Swig_symbol_setscope(Getattr(classn, "symtab"));
  Node *added = Swig_symbol_add(symname, n);
  Swig_symbol_setscope(prev_scope);
  ASSERT_OR_PRINT_NODE(added == n, n);

  // Make sure the function declaration is public
  Setattr(n, "access", "public");

  // Function declaration: takes const reference to class, returns nothing
  SwigType *classtype = Getattr(classn, "classtypeobj");
  String *decl = NewStringf("f(r.q(const).%s).", classtype);
  Setattr(n, "decl", decl);
  Setattr(n, "type", "void");

  // Change parameters so that the correct self/other are used for typemap matching.
  // Notably, 'other' should be treated as a *MUTABLE* reference for type matching.
  String *argtype = NewStringf("r.%s", classtype);
  Parm *other_parm = NewParm(argtype, "other", classn);
  this->makeParameterName(n, other_parm, 0);
  Setattr(other_parm, "name", "ASSIGNMENT_OTHER");
  Setattr(n, "parms", other_parm);
  Setattr(n, "fortran:rename_self", "ASSIGNMENT_SELF"); // Use INOUT for class handle

  // Get C++ class name
  String *classname = Getattr(classn, "classtype");
  if (String *smartptr_type = Getattr(classn, "feature:smartptr")) {
    // The pointed-to data is actually SP<CLASS>, not CLASS.
    classname = smartptr_type;
  }
  // Determine construction flags.
  String *policystr = Getattr(classn, "fortran:policy");

  // Define action code
  String *code = NULL;
  if (CPlusPlus) {
    code = NewStringf("SWIG_assign<%s, %s>(farg1, *farg2);\n", classname, policystr);
  } else {
    code = NewStringf("SWIG_assign(farg1, *farg2);\n");
  }
  Setattr(n, "feature:action", code);

  // Insert assignment fragment
  Setattr(n, "feature:fragment", "SWIG_assign");

  // Add the new assignment operator to the class's definition.
  appendChild(classn, n);

  Delete(code);
  Delete(classtype);
  Delete(other_parm);
  Delete(symname);
  Delete(name);
  Delete(decl);
  Delete(argtype);
}

/* -------------------------------------------------------------------------
 * \brief Write documentation for the given node to the passed string.
 */
void FORTRAN::write_docstring(Node *n, String *dest) {
  String *docs = Getattr(n, "feature:docstring");

  if (!docs)
    return;

  List *lines = SplitLines(docs);

  // Skip leading blank lines
  Iterator it = First(lines);
  while (it.item && Len(it.item) == 0) {
    it = Next(it);
  }

  for (; it.item; it = Next(it)) {
    // Chop(it.item);
    Printv(dest, "!> ", it.item, "\n", NULL);
  }

  Delete(lines);
}

/* -------------------------------------------------------------------------
 * \brief Create a friendly parameter name
 */
String *FORTRAN::makeParameterName(Node *n, Parm *p, int arg_num, bool) const {
  String *name = Getattr(p, "fname");
  if (name) {
    // Name has already been converted and checked by a previous loop
    return name;
  }

  name = Getattr(p, "name");
  if (name && Len(name) > 0 && is_valid_identifier(name) && !Strstr(name, "::")) {
    // Valid fortran name; convert to lowercase
    name = Swig_string_lower(name);
  } else {
    // Invalid name; replace with something simple
    name = NewStringf("arg%d", arg_num);
  }
  String *origname = name;

  // Symbol tables for module and forward-declared class scopes
  FORTRAN *mthis = const_cast<FORTRAN *>(this);
  Hash *symtab = mthis->symbolScopeLookup(NULL);

  bool valid = false;
  while (!valid)
  {
    valid = true;
    if (ParmList *parmlist = Getattr(n, "parms")) {
      // Check against previously generated names in this parameter list
      for (Parm *other = parmlist; other; other = nextSibling(other)) {
        if (other == p)
          break;
        String *other_name = Getattr(other, "fname");
        if (other_name && Strcmp(name, other_name) == 0) {
          valid = false;
          break;
        }
      }
    }

    // If the parameter name is in the fortran scope, or in the
    // forward-declared classes, mangle it
    if (valid && (Getattr(symtab, name))) {
      valid = false;
    }

    if (!valid) {
      if (name != origname)
        Delete(name);
      // Try another name and loop again
      name = NewStringf("%s%d", origname, arg_num++);
    }
  }

  // Save the name for next time we have to use this parameter
  Setattr(p, "fname", name);
  return name;
}

/* ------------------------------------------------------------------------- */

void FORTRAN::replaceSpecialVariables(String *method, String *tm, Parm *parm) {
  (void)method;
  SwigType *type = Getattr(parm, "type");
  this->replace_fclassname(NULL, type, tm);
}

/* -------------------------------------------------------------------------
 * \brief Process a class declaration.
 *
 * The superclass calls classHandler.
 */
int FORTRAN::classDeclaration(Node *n) {
  String *fsymname = NULL;

  if (!GetFlag(n, "feature:onlychildren")) {
    // Set up Fortran proxy name, adding to symbol table (even if the class is being imported)
    fsymname = this->get_fsymname(n);
    // Return if it's a duplicate
    if (!fsymname)
      return SWIG_NOWRAP;
  }
  if (GetFlag(n, "feature:fortran:bindc")) {
    // Prevent default constructors, destructors, etc.
    SetFlag(n, "feature:nodefault");
  }

  // Build symbol table here, even if class is being imported
  Symtab *fsymtab = NewHash();
  Setattr(n, "fortran:symtab", fsymtab);

  String *lower_fsymname = NULL;
  if (fsymname) {
    lower_fsymname = Swig_string_lower(fsymname);
    Setattr(fsymtab, lower_fsymname, n);
    Setattr(fsymtab, "fortran:name", fsymname);
  }

  // Add the base class's symbol table as a parent.
  Symtab *base_fsymtab = NULL;
  for (Iterator base = First(Getattr(n, "bases")); base.item; base = Next(base)) {
    Node *b = base.item;
    if (GetFlag(b, "feature:ignore"))
      continue;
    base_fsymtab = Getattr(b, "fortran:symtab");
    ASSERT_OR_PRINT_NODE(base_fsymtab, b);
    appendChild(base_fsymtab, fsymtab);
  }

  // See if this class conflicts with methods in base class
  if (lower_fsymname) {
    for (Symtab *st = base_fsymtab; st; st = parentNode(st)) {
      if (Node *other = Getattr(st, lower_fsymname)) {
        Swig_error(input_file, line_number,
                   "Class '%s' has the same Fortran name as an inherited class function '%s'\n",
                   fsymname, Getattr(other, "fortran:name"));
        Swig_error(Getfile(other), Getline(other), "Previous declaration of '%s'\n",
                   Getattr(other, "sym:name"));
        return SWIG_NOWRAP;
      }
    }
  }

  // Define policy
  if (CPlusPlus) {
    if (SwigType *name = Getattr(n, "name")) {
      String *policystr = Swig_string_mangle(name);
      Insert(policystr, 0, "SWIGPOLICY_");
      Setattr(n, "fortran:policy", policystr);

      // Define policies for the class
      const char *policy = "swig::ASSIGNMENT_DEFAULT";
      if (Getattr(n, "feature:smartptr")) {
        policy = "swig::ASSIGNMENT_SMARTPTR";
      } else if (!GetFlag(n, "allocate:default_destructor")) {
        policy = "swig::ASSIGNMENT_NODESTRUCT";
      }
      Printv(f_policies, "#define ", policystr, " ", policy, "\n", NULL);
    }
  }

  return Language::classDeclaration(n);
}

/* -------------------------------------------------------------------------
 * \brief Generate wrappers for a class.
 */
int FORTRAN::classHandler(Node *n) {
  String *fsymname = Getattr(n, "fortran:name");
  String *base_fsymname = NULL;

  // Iterate through the base classes. If no bases are set (null pointer sent
  // to `First`), the loop will be skipped and baseclass be NULL.
  for (Iterator base = First(Getattr(n, "bases")); base.item; base = Next(base)) {
    Node *b = base.item;
    if (GetFlag(b, "feature:ignore"))
      continue;
    if (!base_fsymname) {
      // First class that was encountered
      base_fsymname = Getattr(b, "fortran:name");
    } else {
      // Another base class exists
      Swig_warning(WARN_FORTRAN_MULTIPLE_INHERITANCE, Getfile(n), Getline(n),
                   "Multiple inheritance is not supported in Fortran. Ignoring base class %s for %s\n",
                   Getattr(b, "sym:name"),
                   Getattr(n, "sym:name"));
    }
  }

  const bool bindc = GetFlag(n, "feature:fortran:bindc");
  if (bindc && base_fsymname) {
    // Disallow inheritance for BIND(C) types
    Swig_error(input_file, line_number,
               "Struct '%s' uses the '%%fortranbindc' feature, so it cannot use inheritance.\n",
               fsymname);
    return SWIG_NOWRAP;
  }

  ASSERT_OR_PRINT_NODE(!f_class, n);
  f_class = NewStringEmpty();

  ASSERT_OR_PRINT_NODE(Getattr(n, "kind") && Getattr(n, "classtype"), n);
  f_class = NewStringf(" ! %s %s\n", Getattr(n, "kind"), Getattr(n, "classtype"));

  // Write documentation
  this->write_docstring(n, f_class);

  // Declare class
  Printv(f_class, " type", NULL);
  if (base_fsymname) {
    Printv(f_class, ", extends(", base_fsymname, ")", NULL);
  } else if (bindc) {
    Printv(f_class, ", bind(C)", NULL);
  }
  Printv(f_class, ", public :: ", fsymname, "\n", NULL);

  if (!bindc) {
    if (!base_fsymname) {
      // Insert the class data if this doesn't inherit from anything
      emit_fragment("SwigClassWrapper_f");
      Printv(f_class,
             "  type(SwigClassWrapper), public :: swigdata\n",
             NULL);
    }

    // Initialize output strings that will be added by 'functionHandler'.
    d_method_overloads = NewHash();

    // Add an assignment function to the class node
    this->add_assignment_operator(n);

    // Add overload entry for constructors (must do this outside of `add_overload` since the class name already exists as a symbol)
    ASSERT_OR_PRINT_NODE(!Getattr(d_overloads, fsymname), n);
    Setattr(d_overloads, fsymname, NewList());
    // The derived type is already marked as public, so don't add the additional "public" declaration
    SetFlag(d_private_overloads, fsymname);

    // Assignment operator means we're guaranteed to have at least one method, so it's OK to unconditionally put 'contains'
    Printv(f_class, " contains\n", NULL);
  }

  // Emit class members
  Language::classHandler(n);

  if (!bindc) {
    // Write overloads
    for (Iterator kv = First(d_method_overloads); kv.key; kv = Next(kv)) {
      Printv(f_class, "  generic :: ", kv.key, " => ", NULL);
      // Note: subtract 2 becaues this first line is an exception to
      // prepend_comma, added inside the iterator
      int line_length = 13 + Len(kv.key) + 4 - 2;

      // Write overloaded procedure names
      print_wrapped_list(f_class, First(kv.item), line_length);
      Printv(f_class, "\n", NULL);
    }
    Delete(d_method_overloads);
    d_method_overloads = NULL;
  }

  // Close out the type
  Printf(f_class, " end type %s\n", fsymname);

  // Add fortran handle if a director
  if (Node *handlen = Getattr(n, "fortran:handle")) {
    String *handlefsymname = Getattr(handlen, "fortran:name");
    Printv(f_class, " type ", handlefsymname, "\n",
                    "  class(", fsymname, "), pointer :: swigfptr\n",
                    " end type ", handlefsymname, "\n", NULL);
  }

  // Write the constructed class out to the declaration part of the module
  Printv(f_fdecl, f_class, NULL);
  Delete(f_class);
  f_class = NULL;

  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Extra stuff for constructors.
 */
int FORTRAN::constructorHandler(Node *n) {
  // Set fortran symname of this function to the class symname
  Setattr(n, "fortran:name", Getattr(this->getCurrentClass(), "fortran:name"));

  // Make constructor method name conform to other interface wrapper names
  String *fname = proxy_name_construct(this->getNSpace(), "new", Getattr(n, "sym:name"));
  Setattr(n, "fortran:fname", fname);
  Delete(fname);

  // Override the result variable name
  Setattr(n, "wrap:fresult", "self");

  Language::constructorHandler(n);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Handle extra destructor stuff.
 */
int FORTRAN::destructorHandler(Node *n) {
  // Make the destructor a member function called 'release'
  Setattr(n, "fortran:name", "release");
  SetFlag(n, "fortran:ismember");

  // Throwing in a destructor calls `std::terminate`, so don't bother adding wrapper code
  if (!GetFlag(n, "feature:allowexcept")) {
    UnsetFlag(n, "feature:except");
  }

  // Make destructor method name conform to other interface wrapper names
  String *fname = proxy_name_construct(this->getNSpace(), Getattr(n, "sym:name"), "release");
  Setattr(n, "fortran:fname", fname);
  Delete(fname);

  // Use a custom typemap: input must be mutable and clean up properly
  Setattr(n, "fortran:rename_self", "DESTRUCTOR_SELF");
  // Wrap the proxy action so it only 'delete's if it owns
  String *destruct_action = NewStringEmpty();
  Printv(destruct_action, "if (btest(farg1%cmemflags, swig_cmem_own_bit)) then\n", NULL);
  if (Swig_directorclass(getCurrentClass())) {
    Printv(destruct_action, " call swig_finalize(self)\n", NULL);
  }
  Printv(destruct_action,
         " $action\n"
         "endif\n"
         "farg1%cptr = C_NULL_PTR\n"
         "farg1%cmemflags = 0\n",
         NULL);
  Setattr(n, "feature:shadow", destruct_action);

  return Language::destructorHandler(n);
}

/* -------------------------------------------------------------------------
 * \brief Process member functions.
 *
 * This is *NOT* called when generating get/set wrappers for membervariableHandler.
 */
int FORTRAN::memberfunctionHandler(Node *n) {
  String *class_symname = Getattr(this->getCurrentClass(), "sym:name");

  if (this->is_bindc_struct()) {
    Swig_error(input_file, line_number,
               "Struct '%s' has the 'fortranbindc' feature set, so it cannot have member functions\n",
               class_symname);
    return SWIG_NOWRAP;
  }

  // Create a private procedure name that gets bound to the Fortan TYPE
  String *fwrapname = proxy_name_construct(this->getNSpace(), class_symname, Getattr(n, "sym:name"));
  Setattr(n, "fortran:fname", fwrapname);
  Delete(fwrapname);

  // Save original member function name, mangled to a valid fortran name
  Setattr(n, "fortran:name", make_fname(Getattr(n, "sym:name")));

  // Set as a member variable unless it's a constructor
  if (!is_node_constructor(n)) {
    SetFlag(n, "fortran:ismember");
  }

  Language::memberfunctionHandler(n);

  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Process member variables.
 */
int FORTRAN::membervariableHandler(Node *n) {
  String *fsymname = make_fname(Getattr(n, "sym:name"));
  if (this->is_bindc_struct()) {
    // Write the type for the class member
    String *bindc_typestr = attach_typemap("bindc", n, WARN_TYPEMAP_UNDEF);
    SwigType *datatype = Getattr(n, "type");

    if (!bindc_typestr) {
      // In order for the struct's data to correspond to the C-aligned
      // data, an interface type MUST be specified!
      String *class_symname = Getattr(this->getCurrentClass(), "sym:name");
      Swig_error(input_file, line_number,
                 "Struct '%s' has the 'fortranbindc' feature set, but member variable '%s' (type '%s') has no 'bindc' typemap defined\n",
                 class_symname, fsymname, SwigType_namestr(datatype));
      return SWIG_NOWRAP;
    }
    this->replace_fclassname(n, datatype, bindc_typestr);

    ASSERT_OR_PRINT_NODE(Len(fsymname) > 0, n);
    Printv(f_class, "  ", bindc_typestr, ", public :: ", fsymname, "\n", NULL);
    Delete(fsymname);
  } else {
    // Create getter and/or setter functions, first preserving
    // the original member variable name
    Setattr(n, "fortran:variable", fsymname);
    SetFlag(n, "fortran:ismember");
    Language::membervariableHandler(n);
  }
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Process global variables.
 */
int FORTRAN::globalvariableHandler(Node *n) {
  if (GetFlag(n, "feature:fortran:bindc")) {
    return this->bindcvarWrapper(n);
  } else if (GetFlagAttr(n, "feature:fortran:const") && has_constexpr_storage(n)) {
    // constexpr global variable
    return this->constantWrapper(n);
  }

  // No special cases: treat like a global variable
  String *fsymname = Copy(Getattr(n, "sym:name"));
  Setattr(n, "fortran:variable", fsymname);
  Language::globalvariableHandler(n);
  Delete(fsymname);

  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Process global-scope functions.
 */
int FORTRAN::globalfunctionHandler(Node *n) {
  if (GetFlagAttr(n, "feature:fortran:callback")) {
    // Flag is set to a non-"0" value
    Node *cbnode = Getattr(n, "fortran:callback");
    if (!cbnode) {
      this->fortrancallbackHandler(n);
      cbnode = Getattr(n, "fortran:callback");
    }
    if (cbnode && Cmp(Getattr(cbnode, "sym:name"), Getattr(n, "sym:name")) == 0) {
      // Callback name is the *same* as the function name: we're *just* wrapping as a callback. Return immediately.
      return SWIG_NOWRAP;
    }
  }

  if (GetFlag(n, "feature:fortran:bindc")) {
    if (GetFlagAttr(n, "feature:callback")) {
      Swig_warning(WARN_FORTRAN_IGNORE_CALLBACK, input_file,
                 line_number,
                 "Ignoring %%callback for %%fortranbindc function '%s'\n",
                 Getattr(n, "sym:name"));
    }
    // The wrapped function name *is* the C function name
    Setattr(n, "wrap:name", Getattr(n, "name"));

    // Just generate the function interface
    return this->bindcfunctionHandler(n);
  } else {
    // Generate wrapper functions
    return Language::globalfunctionHandler(n);
  }
}

/* -------------------------------------------------------------------------
 * \brief Create an "abstract inferface" (Fortran callback definition) from a
 * function node.
 *
 * We do *not* check d_callbacks for existing matching signatures. The user
 * might want to have two separate meaningful callback names and we don't want
 * to mysteriously prevent one from being wrapped.
 */
int FORTRAN::fortrancallbackHandler(Node *n) {
  // Create a shallow copy of the node with params
  Node *cbnode = copyNode(n);
  Setattr(cbnode, "parms", Getattr(n, "parms"));

  // Create symname for the callback from the
  String *cb = GetFlagAttr(n, "feature:fortran:callback");
  assert(cb);
  String *cbname = NewStringf(cb, Getattr(n, "sym:name"));
  Setattr(cbnode, "sym:name", cbname);

  // Wrap the callback
  int result = this->bindcfunctionHandler(cbnode);

  if (result == SWIG_OK) {
    // Save to parent node
    Setattr(n, "fortran:callback", cbnode);

    // Save function pointer type in the cache of types
    // Construct function pointer type corresponding to this function
    SwigType *fptype = Copy(Getattr(n, "type"));
    SwigType_push(fptype, Getattr(n, "decl"));
    Setattr(d_callbacks, fptype, cbnode);
    Delete(fptype);
  }

  return result;
}

/* -------------------------------------------------------------------------
 * \brief Generate an interface-only `bind(C)` function wrapper.
 *
 * This uses the *original* C function name to generate the interface to, and
 * create an acceptable Fortran identifier based on whatever renames have been
 * requested.
 */
int FORTRAN::bindcfunctionHandler(Node *n) {
  String *symname = Getattr(n, "sym:name");

  if (CPlusPlus && !Swig_storage_isexternc(n)) {
    Swig_error(input_file,
               line_number,
               "The C++ function '%s' is not defined with external "
               "C linkage (extern \"C\"), but it is being directly wrapped.\n",
               symname);
  }

  // Interface function name in Fortran module
  String *imname = make_fname(symname, WARN_NONE);

  // Add the interface subroutine name to the module scope
  if (add_fsymbol(imname, n) == SWIG_NOWRAP)
    return SWIG_NOWRAP;

  Setattr(n, "wrap:imname", imname);

  // Emit all of the local variables for holding arguments.
  ParmList *parmlist = Getattr(n, "parms");
  Swig_typemap_attach_parms("bindc", parmlist, NULL);
  emit_attach_parmmaps(parmlist, NULL);
  Setattr(n, "wrap:parms", parmlist);

  // Create a list of parameters wrapped by the intermediate function
  List *cparmlist = NewList();
  int i = 0;
  for (Parm *p = parmlist; p; p = nextSibling(p), ++i) {
    // Skip void parameters
    if (Cmp(Getattr(p, "type"), "void") == 0) {
      continue;
    }
    // Use C argument names
    String *imname = this->makeParameterName(n, p, i);
    Setattr(p, "imname", imname);
    Append(cparmlist, p);
  }

  // Save list of wrapped parms for im declaration and proxy
  Setattr(n, "wrap:cparms", cparmlist);

  // Generate the wrapper
  if (Wrapper *imfunc = this->imfuncWrapper(n, true)) {
    // Write to 'abstract' interfaces if it's not associated with an actual C
    // function
    Wrapper_print(imfunc, Getattr(n, "wrap:name") == NULL ? f_fabstract : f_finterfaces);
    DelWrapper(imfunc);
  } else {
    SetFlag(n, "fortran:ignore");
    return SWIG_NOWRAP;
  }

  // Expose the interface function
  ASSERT_OR_PRINT_NODE(imname && Len(imname) > 0, n);
  Printv(f_fdecl, " public :: ", imname, "\n", NULL);
  Setattr(n, "fortran:name", imname);
  Delete(imname);

  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Process static member functions.
 */
int FORTRAN::staticmemberfunctionHandler(Node *n) {
  String *class_symname = Getattr(getCurrentClass(), "sym:name");
  if (this->is_bindc_struct()) {
    Swig_error(input_file, line_number,
               "Struct '%s' has the 'fortranbindc' feature set, so it cannot have static member functions\n",
               class_symname);
    return SWIG_NOWRAP;
  }

  // Preserve original function name
  Setattr(n, "fortran:name", make_fname(Getattr(n, "sym:name")));

  // Create a private procedure name that gets bound to the Fortan TYPE
  String *fwrapname = proxy_name_construct(this->getNSpace(), class_symname,Getattr(n, "sym:name"));

  Setattr(n, "fortran:fname", fwrapname);

  // Add 'nopass' procedure qualifier
  Setattr(n, "fortran:procedure", "nopass");

  // Mark as a member function
  SetFlag(n, "fortran:ismember");

  Language::staticmemberfunctionHandler(n);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Process static member variables.
 */
int FORTRAN::staticmembervariableHandler(Node *n) {
  // Preserve variable name
  Setattr(n, "fortran:variable", Getattr(n, "sym:name"));

  SetFlag(n, "fortran:ismember");

  // Add 'nopass' procedure qualifier for getters and setters
  Setattr(n, "fortran:procedure", "nopass");
  Language::staticmembervariableHandler(n);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Wrap an enum declaration
 */
int FORTRAN::enumDeclaration(Node *n) {
  String *access = Getattr(n, "access");
  if (access && Strcmp(access, "public") != 0) {
    // Not a public enum
    return SWIG_NOWRAP;
  }

  if (GetFlag(n, "sym:weak")) {
    // Ignore forward declarations
    return SWIG_NOWRAP;
  }

  String *class_symname = NULL;
  Symtab *fsymtab = NULL;
  if (Node *classnode = this->getCurrentClass()) {
    // Scope the enum since it's in a class
    class_symname = Getattr(classnode, "sym:name");
    fsymtab = Getattr(classnode, "fortran:symtab");
  }

  String *symname = Getattr(n, "sym:name");
  String *scope_prefix = NULL;
  String *fsymname = NULL;
  if (!symname) {
    // Anonymous enum TYPE:
    // enum {FOO=0, BAR=1};
  } else if (Strstr(symname, "$unnamed") != NULL) {
    // Anonymous enum VALUE
    // enum {FOO=0, BAR=1} foo;
  } else {
    // Get symname for this enum, prepending with embedded class name if needed
    String *scoped_symname = class_symname ? NewStringf("%s_%s", class_symname, symname) : Copy(symname);

    fsymname = this->get_fsymname(n, scoped_symname);
    Delete(scoped_symname);
    if (!fsymname)
      return SWIG_NOWRAP;
  }

  // Set up scoping prefixes for enum values
  String *enum_class = Strcmp(Getattr(n, "enumkey"), "enum") != 0 ? symname : NULL;
  if (class_symname && enum_class) {
    scope_prefix = NewStringf("%s_%s", class_symname, enum_class);
  } else if (enum_class) {
    scope_prefix = Copy(enum_class);
  } else if (class_symname) {
    scope_prefix = Copy(class_symname);
  }

  if (!fsymtab) {
    fsymtab = NewHash();
  }
  if (fsymname) {
    String *lower_fsymname = Swig_string_lower(fsymname);
    Setattr(fsymtab, "fortran:name", fsymname);
    Setattr(fsymtab, lower_fsymname, n);
    Delete(lower_fsymname);
  }
  Setattr(n, "fortran:symtab", fsymtab);

  if (ImportMode) {
    // Don't generate wrappers if we're in import mode, but make sure the
    // symbol renaming above is still performed. Also make sure to mark that
    // the enum is available for use as a type
    SetFlag(n, "fortran:declared");
    return SWIG_OK;
  }

  if (String *name = Getattr(n, "name")) {
    Printv(f_fdecl, " ! ", NULL);
    if (String *storage = Getattr(n, "storage")) {
      Printv(f_fdecl, storage, " ", NULL);
    }
    Printv(f_fdecl, Getattr(n, "enumkey"), " ", name, "\n", NULL);
  }

  // Determine whether to add enum as a native fortran enumeration. If false,
  // the values are all wrapped as constants. Only create the list if values are defined.
  bool is_native = is_native_enum_decl(n) && firstChild(n);

  // Check all enum values and update their names
  for (Node *c = firstChild(n); c; c = nextSibling(c)) {
    if (Getattr(c, "error") || GetFlag(c, "feature:ignore")) {
      // We're not wrapping
      continue;
    }

    String *child_symname = Getattr(c, "sym:name");
    if (scope_prefix) {
      child_symname = NewStringf("%s_%s", scope_prefix, child_symname);
    }

    bool ignore_child = false;
    String *child_fsymname = make_fname(child_symname, WARN_NONE);
    String *lower_fsymname = Swig_string_lower(child_fsymname);

    for (Symtab *st = fsymtab; st; st = parentNode(st)) {
      Node *other = Getattr(st, lower_fsymname);
      if (other) {
        Swig_warning(WARN_FORTRAN_NAME_COLLISION, Getfile(c), Getline(c),
                     "Ignoring '%s' due to name conflict with '%s' in '%s'\n",
                     child_fsymname, Getattr(other, "fortran:name"), Getattr(st, "fortran:name"));
        Swig_warning(WARN_FORTRAN_NAME_COLLISION, Getfile(other), Getline(other),
                     "Previous declaration of '%s'\n",
                     Getattr(other, "sym:name"));

        ignore_child = true;
        is_native = false;
        break;
      }
    }
    if (ignore_child) {
      SetFlag(c, "feature:ignore");
    } else {
      Setattr(c, "fortran:name", child_fsymname);
    }
    // Force enum to have integer type
    Setattr(c, "type", "int");
    // Add enum name to the symtab
    Setattr(fsymtab, lower_fsymname, n);
    Delete(lower_fsymname);
  }

  if (is_native) {
    // Create enumerator statement and initialize list of enum values
    d_enum_public = NewList();
    Printv(f_fdecl, " enum, bind(c)\n", NULL);

    // Mark that the enum is available for use as a type
    SetFlag(n, "fortran:declared");
  }

  // Emit enum items
  int result = Language::enumDeclaration(n);

  if (d_enum_public) {
    if (Len(d_enum_public) == 0) {
      // Wrapping failed: possible errors in one of the enums
      result = SWIG_ERROR;
    }
    // End enumeration
    Printv(f_fdecl, " end enum\n", NULL);

    if (fsymname) {
      ASSERT_OR_PRINT_NODE(Len(fsymname) > 0, n);
      // Create "kind=" value for the enumeration type
      Printv(f_fdecl, " integer, parameter, public :: ",  fsymname,
             " = kind(", First(d_enum_public).item, ")\n", NULL);
    }

    // Make the enum values public
    Printv(f_fdecl, " public :: ", NULL);
    print_wrapped_list(f_fdecl, First(d_enum_public), 11);
    Putc('\n', f_fdecl);

    // Clean up
    Delete(d_enum_public);
    d_enum_public = NULL;
  } else if (fsymname) {
    // Create "kind=" value for the enumeration type
    Printv(f_fdecl, " integer, parameter, public :: ",  fsymname,
           " = C_INT\n", NULL);

    // Mark that the enum is available for use as a type
    SetFlag(n, "fortran:declared");
  }

  // Clean up
  Delete(fsymname);
  Delete(scope_prefix);

  return result;
}


/* -------------------------------------------------------------------------
 * \brief Process callbacks, which generate 'getter' wrapper functions
 *
 * To avoid breaking the later 'functionWrapper', we create a copy of the node.
 */
int FORTRAN::callbackfunctionHandler(Node *n) {
  // Create a shallow copy of the node with params
  Node *cbnode = copyNode(n);
  Setattr(cbnode, "parms", Getattr(n, "parms"));
  Language::callbackfunctionHandler(cbnode);
  Setattr(n, "feature:callback:node", cbnode);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Process *compile-time* constants
 *
 * These include:
 * \code
    %callback("%s_cb") add;
    %constant int wrapped_const = (1 << 3) | 1;
    #define MY_INT 0x123
    constexpr int myint = 4;
 * \endcode
 * and enum values.
 *
 * - Native enum values will become enumerators
 * - Non-native enum values become C-bound external constants
 * - Constants marked with `%fortranconst` will be rendered as *named constants*
 * - Constants marked with `%fortranbindc` also become C-bound external constants
 * - All other types will generate `getter` functions that return native fortran types.
 */
int FORTRAN::constantWrapper(Node *n) {
  enum {
    NATIVE_ENUM,
    EXTERN_ENUM,
    NATIVE_CONSTANT,
    EXTERN_CONSTANT
  } constant_type;

  if (d_enum_public) {
    constant_type = NATIVE_ENUM;
  } else if (Cmp(nodeType(n), "enumitem") == 0) {
    constant_type = EXTERN_ENUM;
  } else if (GetFlag(n, "feature:fortran:const") || Getattr(n, "feature:fortran:constvalue")) {
    constant_type = NATIVE_CONSTANT;
  } else if (GetFlag(n, "feature:fortran:bindc") && has_constant_storage(n)) {
    constant_type = EXTERN_CONSTANT;
  } else {
    // Not a natively representable value: wrap as immutable global variable
    SetFlag(n, "feature:immutable");
    return this->globalvariableHandler(n);
  }

  // Get symbolic name
  String *fsymname = this->get_fsymname(n);
  if (!fsymname) {
    return SWIG_ERROR;
  }

  if (constant_type == NATIVE_ENUM) {
    // Add to list of public enums
    Append(d_enum_public, fsymname);
    Printv(f_fdecl, "  enumerator :: ", fsymname, NULL);
    if (String *value = Getattr(n, "enumvalue")) {
      Printv(f_fdecl, " = ", value, NULL);
    }
    Printv(f_fdecl, "\n", NULL);
    return SWIG_OK;
  }

  // Attach bindc typemaps
  String *bindc_typestr = attach_typemap("bindc", n, WARN_NONE);
  if (!bindc_typestr) {
    Swig_error(input_file,
               line_number,
               "The constant '%s' has no 'bindc' typemap.\n",
               Getattr(n, "sym:name"));
    return SWIG_ERROR;
  }

  // Get value of the constant
  String *value = (constant_type == NATIVE_CONSTANT ? Getattr(n, "feature:fortran:constvalue") : NULL);
  if (!value) {
    // String types will have the quoted, escaped value set as rawval
    value = Getattr(n, "rawval");
  }
  if (!value) {
    value = Getattr(n, "value");
  }
  if (!value) {
    Swig_error(input_file,
               line_number,
               "The constant '%s' has no value.\n",
               Getattr(n, "sym:name"));
    return SWIG_ERROR;
  }

  if (constant_type == NATIVE_CONSTANT) {
    if (String *special_bindc_typestr = Getattr(n, "tmap:bindc:fortranconst")) {
      // Override type
      bindc_typestr = special_bindc_typestr;
    }
    if (String *suffix = Getattr(n, "tmap:bindc:kind")) {
      // Add specifier such as _C_DOUBLE to the native value. Otherwise, for example,
      // 1.000000001 will be truncated to 1 because fortran will think it's a float.
      Printv(value, "_", suffix, NULL);
    }
    // Wrap as a compile-time module parameter
    Printv(f_fdecl, " ", bindc_typestr, ", parameter, public :: ", fsymname, " = ", value, "\n", NULL);
    return SWIG_OK;
  }

  String *wname = Swig_name_wrapper(Getattr(n, "sym:name"));
  Setattr(n, "wrap:name", wname);

  if (constant_type == EXTERN_ENUM) {
    // Generate an int enum (whether a C++ enum class value, an enum that looks like `value = 'a'`, etc.)
    Printv(f_wrapper, "SWIGEXPORT SWIGEXTERN const int ", wname, " = (int)(", value, ");\n\n", NULL);
  } else {
    // Write SWIG code
    SwigType *type = Copy(Getattr(n, "type"));
    SwigType_add_qualifier(type, "const");
    String *declstring = SwigType_str(type, wname);
    Printv(f_wrapper, "SWIGEXPORT SWIGEXTERN ", declstring, " = ", value, ";\n\n", NULL);
    Delete(declstring);
    Delete(type);
  }

  // Add bound variable to interfaces
  Printv(f_fdecl, " ", bindc_typestr, ", protected, public, &\n",
         "   bind(C, name=\"", wname, "\") :: ",
         (Len(wname) > 60 ? "&\n    " : ""),
         fsymname, "\n",
         NULL);
  Delete(wname);

  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * DIRECTOR SUPPORT
 *
 * Methods below are ordered roughly in the same order they're called.
 * ------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------
 * \brief Begin generating a director class.
 */
int FORTRAN::classDirectorInit(Node *n) {
  // Create a node representing the fortran 'handle' class
  Node *handlen = NewHash();
  Setattr(n, "fortran:handle", handlen);
  set_nodeType(handlen, "class");
  Setfile(handlen, Getfile(n));
  Setline(handlen, Getline(n));

  // Construct symname and add to Fortran symbol table (not wrapped in C)
  String *handlename = NewStringf("SwigHandle%s", Getattr(n, "fortran:name"));
  Setattr(handlen, "name", handlename);
  Setattr(handlen, "sym:name", handlename);
  String *handlefsymname = this->get_fsymname(handlen, handlename);
  if (!handlefsymname)
    return SWIG_ERROR;

  // Add to C symbol table so that it gets wrapped as a class
  Swig_symbol_cadd(handlename, handlen);

  // Declare the handle class
  Printv(f_directors_h, "class ", handlename, ";\n", NULL);
  // Define the director class as a subclass of the C++ class
  String *dirclassname = Getattr(n, "director:classname");
  String *basename = Getattr(n, "classtype");
  Printv(f_directors_h,
         "class ", dirclassname, " : public ", basename, " {\npublic:\n", NULL);

  // Create a fake %extend directive to hold 'swigfhandle'
  Node *extendn = NewHash();
  appendChild(n, extendn);
  set_nodeType(extendn, "extend");

  // Define the 'swigfhandle' variable
  Node *memvarn = NewHash();
  appendChild(extendn, memvarn);
  set_nodeType(memvarn, "cdecl");
  SetFlag(memvarn, "ismember");
  Setattr(memvarn, "sym:name", "swigfhandle");
  Setattr(memvarn, "name", "swigfhandle");
  Setattr(memvarn, "decl", "p.");
  Setattr(memvarn, "access", "public");
  Setattr(memvarn, "kind", "variable");
  Setattr(memvarn, "type", handlename);
  Setattr(memvarn, "sym:symtab", Getattr(n, "symtab"));
  SetFlag(memvarn, "fortran:private");

  // Add proxy code for handle conversion
  String *dyncast_fname = ensure_short(NewStringf("swigd_dyncast_%s", basename));
  String *dyncast_fsymname = NewString("swig_dyncast");
  int result = this->add_overload(dyncast_fsymname, n, dyncast_fname, true);
  if (result == SWIG_NOWRAP)
    return SWIG_NOWRAP;

  Printv(f_fsubprograms,
         "function ", dyncast_fname, "(swigfbase) &\n"
         "  result(fresult)\n"
         " type(", basename, "), intent(in) :: swigfbase\n"
         " class(", basename, "), pointer :: fresult\n"
         " type(", handlename, "), pointer :: swigfhandle\n"
         " swigfhandle => swigfbase%get_swigfhandle()\n"
         " fresult => swigfhandle%swigfptr\n"
         "end function\n\n",
         NULL);

  // Add proxy code for initialization
  String *init_fname = ensure_short(NewStringf("swigd_init_%s", basename));
  String *init_fsymname = NewString("swig_initialize");
  result = this->add_overload(init_fsymname, n, init_fname, false);
  if (result == SWIG_NOWRAP)
    return SWIG_NOWRAP;

  Printv(f_fsubprograms,
         "subroutine ", init_fname, "(self, source)\n"
         " class(", basename, "), target :: self\n"
         " type(", basename, "), intent(in), optional :: source\n"
         " type(", handlename, "), pointer :: swigfhandle\n"
         " if (present(source)) then\n"
         "   self%swigdata = source%swigdata\n"
         " end if\n"
         " self%swigdata%cmemflags = ibclr(self%swigdata%cmemflags, swig_cmem_rvalue_bit)\n"
         " allocate(swigfhandle)\n"
         " swigfhandle%swigfptr => self\n"
         " call self%set_swigfhandle(swigfhandle)\n"
         "end subroutine\n\n",
         NULL);

  // Add proxy code for uninitialization
  String *uninit_fname = ensure_short(NewStringf("swigd_finalize_%s", basename));
  String *uninit_fsymname = NewString("swig_finalize");
  result = this->add_overload(uninit_fsymname, n, uninit_fname, true);
  if (result == SWIG_NOWRAP)
    return SWIG_NOWRAP;

  Printv(f_fsubprograms,
         "subroutine ", uninit_fname, "(self)\n"
         " class(", basename, "), intent(inout) :: self\n"
         " type(", handlename, "), pointer :: swigfhandle\n"
         " swigfhandle => self%get_swigfhandle()\n"
         " if (associated(swigfhandle)) deallocate(swigfhandle)\n"
         "end subroutine\n\n",
         NULL);

  return Language::classDirectorInit(n);
}

/* -------------------------------------------------------------------------
 * \brief Emit a constructor for the class.
 */
int FORTRAN::classDirectorConstructor(Node *n) {
  if (Getattr(n, "defaultargs")) {
    // Avoid ambiguous calls by not wrapping this constructor.
    return SWIG_NOWRAP;
  }

  // Declare the constructor
  Node *classnode = this->getCurrentClass();
  String *dirclassname = Getattr(classnode, "director:classname");
  String *decl = Getattr(n, "decl");
  ParmList *parms = Getattr(n, "parms");

  bool declare_default_args = true;
  String *target = Swig_method_decl(NULL, decl, dirclassname, parms, declare_default_args);
  Printf(f_directors_h, "  %s;\n", target);
  Delete(target);

  // Provide a definition (call base constructor)
  declare_default_args = false;
  target = Swig_method_decl(NULL, decl, dirclassname, parms, declare_default_args);
  String *call = Swig_csuperclass_call(NULL, Getattr(classnode, "classtype"), parms);

  Printf(f_directors, "%s::%s : %s, swigfhandle(NULL) {}\n\n", dirclassname, target, call);

  Delete(target);
  Delete(call);
  return Language::classDirectorConstructor(n);
}

/* -------------------------------------------------------------------------
 * \brief Emit a default constructor (if needed) for the class.
 */
int FORTRAN::classDirectorDefaultConstructor(Node *n) {
  String *dirclassname = Getattr(getCurrentClass(), "director:classname");
  Wrapper *w = NewWrapper();

  // Write declaration
  Printf(f_directors_h, "  %s();\n", dirclassname);

  // Write definition
  Printf(w->def, "%s::%s() : swigfhandle(NULL) {", dirclassname, dirclassname);
  Printf(w->code, "}\n");
  Wrapper_print(w, f_directors);
  DelWrapper(w);

  return Language::classDirectorDefaultConstructor(n);
}

/* -------------------------------------------------------------------------
 * \brief Emit a virtual method that will dispatch to the Fortran class.
 *
 * - If function is ignored by the user, its body must still be generated if
 *   it's a virtual function (otherwise the director class can't be used at
 *   all).
 *
 * Components:
 * - Declaration of the Director class method (header file)
 * - Definition of the Director class method ('director' block)
 * - Definition of the Fortran intermediate callback code (module subprograms),
 *   bound to C so it's callable by the C++ Director code
 * - Declaration of the C-bound intermediate callback code
 *
 * Director class method:
 *  - "directorin" typemap converts arguments to intermediate "ctype" types
 *  - Calls Fortran intermediate function
 *  - "directorfin" typemap converts "imtype" to "ftype"
 *  - Calls Fortran type-bound method
 *  - "directorfout" converts "ftype" to "imtype", returns to C++ code
 *  - "directorout" converts "ctype" to actual C++ type
 */
int FORTRAN::classDirectorMethod(Node *n, Node *classn, String *super) {
  bool ignored = GetFlag(n, "feature:ignore");
  bool pure_virtual = is_pure_virtual(n);
  if (ignored && !pure_virtual)
    return SWIG_NOWRAP;

  if (Getattr(n, "defaultargs")) {
    // Default arguments in virtual functions -> headaches
    Swig_warning(WARN_LANG_NATIVE_UNIMPL, Getfile(n), Getline(n),
                 "Ignoring virtual function %s with default arguments\n",
                 Getattr(n, "name"));
    return SWIG_NOWRAP;
  }

  // Output containers: definition and declaration
  Wrapper *cppfunc = NewWrapper(); // Member definition
  String *directors_h = NewStringEmpty(); // Member declaration

  Wrapper *imfunc = NewFortranWrapper(); // Fortran (C-bound) proxy conversion code (wname)
  String *imfunc_h = NewStringEmpty(); // C declaration of the proxy code

  /*** CONSTRUCT FUNCTION NAMES ***/

  // The symname of this member function isn't yet constructed; do it manually.
  // (see 'kludge alert' in other languages' directors)
  // Same code as in lang::memberfunctionHandler and
  String *symname = Swig_name_member(getNSpace(), getClassPrefix(), Getattr(n, "sym:name"));

  if (String *overload_ext = (Getattr(n, "sym:overloaded") ? Getattr(n, "sym:overname") : NULL)) {
    Append(symname, overload_ext);
  }
  String *imname = ensure_short(NewStringf("swigd_%s", symname)); // Name in Fortran module
  String *wname = NewStringf("_swigd_%s", symname); // Exposed bind(C) function name
  // Save names for debugging
  Setattr(n, "director:wrap:imname", imname);
  Setattr(n, "director:wrap:name", wname);

  /*** CONSTRUCT C++ FUNCTION SIGNATURES ***/

  String *dirclassname = Getattr(classn, "director:classname");
  String *name = Getattr(n, "name");

  String *decl = Getattr(n, "decl");
  ParmList *parms = Getattr(n, "parms");
  {
    // 'conversion operator' is e.g. `operator bool();`, and `classDirectorMethods:type` is the original return
    // type from the node (e.g. `int` for `int blah();`), since `type` has temporarily
    // been replaced by the `returntype` attribute
    SwigType *rtype = Getattr(n, "conversion_operator") ? NULL : Getattr(n, "classDirectorMethods:type");

    // Construct C++ definition name and parameters
    {
      String *qualified_name = NewStringf("%s::%s", dirclassname, name);
      String *signature = Swig_method_decl(rtype, decl, qualified_name, parms, 0);
      Dump(signature, cppfunc->def);
      Delete(qualified_name);
      Delete(signature);
    }
    {
      String *signature = Swig_method_decl(rtype, decl, name, parms, 1);
      Printf(directors_h, "  virtual %s", signature);
      Delete(signature);
    }

    // Add noexcept/throw qualifiers
    if (String *qualifiers = function_exception_qualifiers(n)) {
      Dump(qualifiers, cppfunc->def);
      Dump(qualifiers, directors_h);
      Delete(qualifiers);
    }
  }

  Append(cppfunc->def, " {\n");
  Append(directors_h, ";\n");

  /*** RETURN TYPE ***/

  if (GetFlag(n, "feature:fortran:subroutine")) {
    Swig_error(input_file, line_number,
               "Can't apply the %%fortransubroutine feature to a director class method (%s)\n",
               symname);
  }

  // Typemaps for C++ -> C -> IM -> F
  SwigType *return_cpptype = Getattr(n, "type");
  Swig_typemap_lookup("ctype", n, Getattr(n, "name"), NULL);
  SwigType *return_ctype = parse_typemap("ctype", n, WARN_FORTRAN_TYPEMAP_CTYPE_UNDEF);
  String *return_imtype = attach_typemap("imtype", n, WARN_FORTRAN_TYPEMAP_IMTYPE_UNDEF);
  String *return_ftype = attach_typemap("ftype", n, WARN_FORTRAN_TYPEMAP_FTYPE_UNDEF);
  ASSERT_OR_PRINT_NODE(return_ftype && return_imtype && return_ctype, n);
  this->replace_fclassname(n, return_cpptype, return_ftype);
  this->replace_fclassname(n, return_cpptype, return_imtype);

  // C++ declaration of Fortran-defined intermediate function
  String *return_cstr = NULL;
  if (return_type_needs_typedef(return_ctype)) {
    // For these types (where the name is the middle of the expression rather than at the right side,
    // i.e. void (*func)() instead of int func, we either have to add a new typedef OR wrap the
    // entire function in parens. The former is easier.
    return_cstr = NewStringf("%s_swigrtype", symname);

    String *typedef_str = SwigType_str(return_ctype, return_cstr);
    Printv(imfunc_h, "typedef ", typedef_str, ";\n", NULL);
    Delete(typedef_str);
  } else {
    // Typical case: convert return type into a regular string
    return_cstr = SwigType_str(return_ctype, NULL);
  }
  Printv(imfunc_h, "extern \"C\" ", return_cstr, " ", wname, "(", NULL);

  // Fortran intermediate function definition
  bool is_subroutine = (Len(return_imtype) == 0);

  // Determine based on return typemap whether it's a function or subroutine
  // (we could equivalently check that return_cpptype is `void`)
  const char *im_func_type = (is_subroutine ? "subroutine" : "function");
  Printv(imfunc->def, im_func_type, " ", imname, "(", NULL);

  // String for calling the intermediate function from C++, and the native Fortran from the intermediate
  String *imcall = NewStringEmpty();
  String *fcall = NewStringEmpty();

  if (!is_subroutine) {
    // C++ return result
    String *cpp_return_str = SwigType_str(return_cpptype, NULL);
    Wrapper_add_localv(cppfunc, "cppresult", cpp_return_str, "cppresult", NULL);
    Delete(cpp_return_str);

    // C-compatible return type in C++ code
    String *c_return_str = SwigType_str(return_ctype, NULL);
    Wrapper_add_localv(cppfunc, "imresult", c_return_str, "imresult", NULL);
    Delete(c_return_str);
    Printv(imcall, "imresult = ", NULL);

    // C-compatible return type from intermediate function
    Wrapper_add_localv(imfunc, "imresult", return_imtype, ":: imresult", NULL);

    // Native fortran return type
    String *return_ftype = attach_typemap("ftype", n, WARN_TYPEMAP_UNDEF);
    if (!return_ftype) {
      Swig_error(input_file, line_number,
                 "No 'ftype' for '%s' in '%s'\n",
                 SwigType_str(Getattr(n, "type"), Getattr(n, "name")), symname);
      return SWIG_ERROR;
    }
    Wrapper_add_localv(imfunc, "fresult", return_ftype, ":: fresult", NULL);
    Printv(fcall, "fresult = ", NULL);

  } else {
    Printv(fcall, "call ", NULL);
  }
  Printv(imcall, wname, "(", NULL);
  Printv(fcall, "self%", name, "(", NULL);


  if (!pure_virtual) {
    // Allow calling an uninitialized 
    String *super_call = Swig_method_call(super, Getattr(n, "parms"));
    Printv(cppfunc->code,
           "if (!this->swigfhandle) {\n"
           "  return ", super_call, ";\n"
           "}\n", NULL);
    Delete(super_call);
  } else {
    Printv(cppfunc->code,
           "  if (!this->swigfhandle)\n"
           "SWIG_exception_impl(\"",
           symname,
           "\", SWIG_NullReferenceError, \"Derived type for '",
           Getattr(classn, "name"),
           "' was not initialized\", return NULL);\n",
           NULL);
  }
  
  /*** PARAMETERS ***/

  // Get the linked list of function arguments, create a "self"/this parameter with the *parent* class to do type matching
  ParmList *parmlist = Getattr(n, "parms");
  Parm *self_parm = make_self_parm(this->getClassName(), n);
  this->makeParameterName(n, self_parm, 0);
  Setattr(self_parm, "name", "DIRECTOR_SELF");
  Setattr(self_parm, "lname", "this");
  Setattr(self_parm, "imname", "farg0");

  if (!parmlist || Cmp(Getattr(parmlist, "type"), "void") != 0) {
    // The function signature is not empty. Append the function arguments to the implicit 'this' argument.
    set_nextSibling(self_parm, parmlist);

    // Set lname [used in type matching] to function argument names for C arguments
    int i = 1;
    for (Parm *p = parmlist; p; p = nextSibling(p)) {
      String *name = Getattr(p, "name");
      ASSERT_OR_PRINT_NODE(name, n);
      Setattr(p, "lname", name);
      String *imarg = NewStringf("farg%d", i++);
      Setattr(p, "imname", imarg);
      Delete(imarg);
    }
  }
  parmlist = self_parm;

  // Process C typemaps
  Swig_typemap_attach_parms("out", parmlist, NULL);
  Swig_typemap_attach_parms("ctype", parmlist, NULL);
  Swig_typemap_attach_parms("imtype", parmlist, NULL);
  Swig_typemap_attach_parms("directorin", parmlist, cppfunc);
  Swig_typemap_attach_parms("directorargout", parmlist, cppfunc);

  // Process Fortran arguments
  Setattr(self_parm, "lname", "self");
  Swig_typemap_attach_parms("ftype", parmlist, NULL);
  Swig_typemap_attach_parms("fdirectorin", parmlist, NULL);

  // Create
  List *imfunc_arglist = NewList();
  List *fcall_arglist = NewList();
  Printv(cppfunc->code,
         "// Convert arguments to ctype via directorin\n",
         NULL);

  // Loop using the 'tmap:directorin:next' property rather than 'nextSibling' to account for multi-argument typemaps
  const char *prepend_comma = "";
  int i = 0;
  for (Parm *p = parmlist; p; p = Getattr(p, "tmap:directorin:next")) {
    // Name of the argument in the function call (e.g. farg1)
    String *imarg = Getattr(p, "imname");
    // Name of the argument as a native fortran type
    String *farg = this->makeParameterName(n, p, i++);

    // Get the user-provided C type string, and convert it to a SWIG
    // internal representation using Swig_cparse_type
    SwigType *ctype = parse_typemap("ctype", "in", p, WARN_FORTRAN_TYPEMAP_CTYPE_UNDEF);
    if (!ctype) {
      Swig_error(input_file, line_number,
                 "Failed to parse 'ctype' typemap for argument '%s' of '%s'\n",
                 SwigType_str(Getattr(p, "type"), Getattr(p, "name")), symname);
      return SWIG_ERROR;
    }

    // Create local variables that become arguments to fortran
    {
      String *cdecl = SwigType_lstr(ctype, imarg);
      Wrapper_add_localv(cppfunc, imarg, cdecl, NULL);
      Delete(cdecl);
    }

    // Add C++ -> C conversion typemaps for input args
    {
      String *tm = Getattr(p, "tmap:directorin");
      if (!tm) {
        Swig_error(input_file, line_number,
                   "No 'directorin' for argument '%s' of '%s'\n",
                   SwigType_str(Getattr(p, "type"), Getattr(p, "name")), symname);
        return SWIG_ERROR;
      }
      Replaceall(tm, "$input", imarg);
      Setattr(p, "emit:directorinput", tm);
      Printv(cppfunc->code, tm, "\n", NULL);
    }

    // Create local fortran variables
    {
      String *imname = Getattr(p, "imname");

      // Emit local C-compatible parameter in the proxy function
      String *imtype = get_typemap("imtype", "in", p, WARN_FORTRAN_TYPEMAP_IMTYPE_UNDEF);
      this->replace_fclassname(n, Getattr(p, "type"), imtype);
      Wrapper_add_localv(imfunc, imarg, imtype, "::", imname, NULL);

      // Emit local native fortran parameter in the proxy function
      String *ftype = get_typemap("ftype", p, WARN_FORTRAN_TYPEMAP_FTYPE_UNDEF);
      this->replace_fclassname(n, Getattr(p, "type"), ftype);
      Wrapper_add_localv(imfunc, farg, ftype, "::", farg, NULL);

      // Add any needed temporary variables to convert to typemap
      if (String *temptype = Getattr(p, "tmap:fdirectorin:temp")) {
        Chop(temptype);
        if (Len(temptype) > 0) {
          this->replace_fclassname(n, Getattr(p, "type"), temptype);
          String *tempname = NewStringf("%s_temp", farg);
          Wrapper_add_localv(imfunc, tempname, temptype, "::", tempname, NULL);
        }
      }
    }      

    // Add C -> F conversion typemaps for input args
    {
      String *tm = Getattr(p, "tmap:fdirectorin");
      if (!tm) {
        Swig_error(input_file, line_number,
                   "No 'fdirectorin' for argument '%s' of '%s'\n",
                   SwigType_str(Getattr(p, "type"), Getattr(p, "name")), symname);
        return SWIG_ERROR;
      }
      Replaceall(tm, "$input", imarg);
      Setattr(p, "emit:fdirectorin", tm);
      Printv(imfunc->code, tm, "\n", NULL);
    }

    // Add argument to function calls
    Printv(imcall, prepend_comma, imarg, NULL);
    Append(imfunc_arglist, imarg);
    if (!Getattr(p, "self")) {
      // Skip extra 'self' argument
      Append(fcall_arglist, farg);
    }

    // Add C declaration of fortran intermediate function
    String *carg = SwigType_str(ctype, imarg);
    Printv(imfunc_h, prepend_comma, carg, NULL);
    Delete(carg);

    // Since we successfully output an argument, the next one should have a comma before it
    prepend_comma = ", ";
  }

  // End C declaration
  Printv(imfunc_h, ");\n\n", NULL);

  // End Fortran dummy argument list
  print_wrapped_list(imfunc->def, First(imfunc_arglist), Len(imfunc->def));
  Printv(imfunc->def, ") &\n",
         "bind(C, name=\"", wname, "\")",
         NULL);
  if (!is_subroutine) {
    Printv(imfunc->def, " &\n     result(imresult)", NULL);
  }

  // End function calls
  print_wrapped_list(fcall, First(fcall_arglist), Len(fcall));
  Printv(imfunc->code, fcall, ")\n", NULL);
  Printv(cppfunc->code, imcall, ");\n", NULL);

  /*** FUNCTION RETURN TYPE ***/

  if (!is_subroutine) {
    Parm *outparm = NewParm(return_cpptype, Getattr(n, "name"), n);
    Setattr(outparm, "lname", "imresult"); // Replaces $1

    // Add C++ -> C conversion typemaps for output args
    {
      String *tm = attach_typemap("directorout", outparm, WARN_TYPEMAP_UNDEF);
      if (!tm) {
        Swig_error(input_file, line_number,
                   "No 'directorout' typemap for '%s' in '%s'\n",
                   return_cpptype, symname);
        return SWIG_ERROR;
      }
      Replaceall(tm, "$result", "cppresult");
      Setattr(n, "emit:directorout", tm);
      Printv(cppfunc->code, tm, "\n", NULL);
    }

    // Create local fortran variables
    {
      // Add any needed temporary variables to convert to typemap
      if (String *temptype = Getattr(n, "tmap:fdirectorout:temp")) {
        Chop(temptype);
        if (Len(temptype) > 0) {
          this->replace_fclassname(n, return_cpptype, temptype);
          const char *tempname = "fresult_temp";
          Wrapper_add_localv(imfunc, tempname, temptype, "::", tempname, NULL);
        }
      }
    }      

    // Add C -> F conversion typemaps for input args
    {
      Setattr(outparm, "lname", "fresult");
      String *tm = attach_typemap("fdirectorout", outparm, WARN_TYPEMAP_UNDEF);
      if (!tm) {
        Swig_error(input_file, line_number,
                   "No 'fdirectorout' typemap for '%s' in '%s'\n",
                   return_cpptype, symname);
        return SWIG_ERROR;
      }
      Replaceall(tm, "$result", "imresult");
      Printv(imfunc->code, tm, "\n", NULL);
    }

    String *qualified_return = SwigType_rcaststr(return_cpptype, "cppresult");
    Printf(cppfunc->code, "return %s;", qualified_return);
    Delete(qualified_return);
    Delete(outparm);
  }
  
  /*** END ***/

  Printf(cppfunc->code, "}\n");
  Printv(imfunc->code, "\n end ", im_func_type, NULL);

  // Print C-bound declaration *before* C++ director definition
  Dump(imfunc_h, f_directors);
  Wrapper_print(cppfunc, f_directors);
  // Print class method declaration
  Dump(directors_h, f_directors_h);
  // Print Fortran callback code
  Wrapper_print(imfunc, f_fsubprograms);

  Delete(self_parm);
  Delete(fcall);
  DelWrapper(cppfunc);
  DelWrapper(imfunc);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Emit virtual destructor for the director class.
 *
 * This is identical to csharp and basically the same as in the base class, but with the addition of the C++11 `noexcept`.
 */
int FORTRAN::classDirectorDestructor(Node *n) {
  String *dirclassname = Getattr(getCurrentClass(), "director:classname");

  const char *qualifier = "";
  if (Getattr(n, "noexcept")) {
    qualifier = " noexcept";
  } else if (Getattr(n, "throw")) {
    qualifier = " throw()";
  }

  // Declare destructor
  Printf(f_directors_h, "  virtual ~%s()%s;\n", dirclassname, qualifier);

  // Define destructor
  Printf(f_directors, "%s::~%s()%s {\n}\n\n", dirclassname, dirclassname, qualifier);

  Delete(dirclassname);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Complete director class after it has been entirely processed.
 */
int FORTRAN::classDirectorEnd(Node *n) {
  Node *handlen = Getattr(n, "fortran:handle");
  String *handlename = Getattr(handlen, "name");
  // End class declaration
  Printv(f_directors_h,
         "  ", handlename, " *swigfhandle;\n"
         "};\n",
         NULL);

  // Provide wrapper definitions for the get/set functions we created
  String *basename = Getattr(n, "classtype");
  String *dirclassname = Getattr(n, "director:classname");
  String *mname = Swig_name_member(NULL, this->getClassPrefix(), "swigfhandle");
  String *mrename_get = Swig_name_get(NULL, mname);
  String *mrename_set = Swig_name_set(NULL, mname);
  Printv(f_directors,
         "SWIGINTERNINLINE ", handlename, " *", mrename_get, "(", basename, " *self) {\n",
         "  ", dirclassname, " *derived = dynamic_cast<", dirclassname, "*>(self);\n",
         "  if (!derived) SWIG_exception_impl(\"", mrename_get, "\", SWIG_NullReferenceError, \"Class instance was not created in Fortran code\", return NULL);\n"
         "  return derived->swigfhandle;\n"
         "}\n"
         "SWIGINTERNINLINE void ", mrename_set, "(", basename, " *self, ", handlename, " *swigfhandle) {\n"
         "  ", dirclassname, " *derived = dynamic_cast<", dirclassname, "*>(self);\n",
         "  if (!derived) SWIG_exception_impl(\"", mrename_set, "\", SWIG_NullReferenceError, \"Class instance was not created in Fortran code\", return);\n"
         "  derived->swigfhandle = swigfhandle;\n"
         "}\n\n",
         NULL);

  return Language::classDirectorEnd(n);
}

/* -------------------------------------------------------------------------
 * \brief Suppress generation of a "disown" free function.
 */
int FORTRAN::classDirectorDisown(Node *n) {
  (void)n;
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * HELPER FUNCTIONS
 * ------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------
 * \brief Substitute special '\$[*&]?fortranclassname' in typemaps.
 */
void FORTRAN::replace_fclassname(Node *n, SwigType *intype, String *tm) {
  assert(intype);
  SwigType *resolvedtype = SwigType_typedef_resolve_all(intype);
  SwigType *strippedtype = SwigType_strip_qualifiers(resolvedtype);

  if (Strstr(tm, "$fortranclassname")) {
    if (String *repl = this->get_proxyname(n, strippedtype)) {
      Replaceall(tm, "$fortranclassname", repl);
    }
  }
  if (Strstr(tm, "$*fortranclassname")) {
    String *repltype = Copy(strippedtype);
    Delete(SwigType_pop(repltype));
    if (Len(repltype) > 0) {
      if (String *repl = this->get_proxyname(n, repltype)) {
        Replaceall(tm, "$*fortranclassname", repl);
      }
    }
    Delete(repltype);
  }
  if (Strstr(tm, "$&fortranclassname")) {
    String *repltype = Copy(strippedtype);
    SwigType_add_pointer(repltype);
    if (String *repl = this->get_proxyname(n, repltype)) {
      Replaceall(tm, "$&fortranclassname", repl);
    }
    Delete(repltype);
  }

  Delete(resolvedtype);
  Delete(strippedtype);
}

/* -------------------------------------------------------------------------
 * \brief Get (creating if necessary) the 'fortran:name' of a class or enum.
 *
 * This is the symbolic name of the *proxy* class or enum *in Fortran*. It's
 * guaranteed to be a proper Fortran identifier.
 *
 * If the resulting symbol already exists (SWIG error), we return NULL.
 */
String *FORTRAN::get_fsymname(Node *n, String *symname) {
  String *fsymname = Getattr(n, "fortran:name");
  if (fsymname) {
    return fsymname;
  }

  // Create fortran identifier from symname
  if (!symname) {
    symname = Getattr(n, "sym:name");
  }
  ASSERT_OR_PRINT_NODE(symname, n);
  fsymname = make_fname(symname);

  if (this->add_fsymbol(fsymname, n) == SWIG_ERROR) {
    fsymname = NULL;
  } else {
    Setattr(n, "fortran:name", fsymname);
  }
  return fsymname;
}

/* ------------------------------------------------------------------------- */

String *FORTRAN::get_proxyname(Node *parent, SwigType *basetype) {
  Node *n = NULL;

  bool is_enum = SwigType_isenum(basetype);
  bool is_funptr = !is_enum && SwigType_isfunction(basetype);
  if (is_enum) {
    n = this->enumLookup(basetype);
  } else if (is_funptr) {
    n = Getattr(d_callbacks, basetype);
  } else {
    n = this->classLookup(basetype);
  }

  if (n && (!is_enum || is_wrapped_enum(n))) {
    // Class node or enum with already-generated wrapper
    return this->get_fsymname(n);
  }

  String *replacementname = create_mangled_fname(basetype);
  if (Getattr(d_emitted_mangled, replacementname)) {
    // Mangled type has already been emitted
    return replacementname;
  }

  // First time encountering this particular mangled type.
  // Create a node so we can insert into the fortran symbol table
  n = NewHash();
  Setattr(n, "name", basetype);
  Setattr(n, "sym:name", replacementname);
  if (parent) {
    Setfile(n, Getfile(parent));
    Setline(n, Getline(parent));
  }
  if (is_enum) {
    set_nodeType(n, "enumforward");
  } else if (is_funptr) {
    // Create a 'callback node' like fortrancallbackHandler
    set_nodeType(n, "cdecl");
    Setattr(n, "kind", "function");
    Setattr(n, "storage", "externc");

    // Split function declaration into return/param
    String *rtype = Copy(basetype);
    SwigType_add_pointer(rtype);
    SwigType *funcparams = SwigType_functionpointer_decompose(rtype);
    Setattr(n, "type", rtype);
    Setattr(n, "decl", funcparams);

    // Convert function signature to ParmList
    ParmList *parms = SwigType_function_parms(basetype, n);
    Setattr(n, "parms", parms);

    // Set parameter names
    int i = 0;
    for (Parm *p = parms; p; p = nextSibling(p), ++i) {
      String *name = NewStringf("arg%d", i);
      Setattr(p, "name", name);
      Delete(name);
    }
  } else {
    set_nodeType(n, "classforward");
  }

  if (!ImportMode) {
    if (!is_funptr) {
      // Function interfaces add the symbol themselves inside bindcfunctionHandler; enums and classes are added here.
      if (this->add_fsymbol(replacementname, n) == SWIG_NOWRAP) {
        ASSERT_OR_PRINT_NODE(false, n);
        return NULL;
      }
    }

    // Emit the wrapper code
    if (is_enum) {
      // Generate automatic enum declaration
      Replace(replacementname, "enum ", "", DOH_REPLACE_ANY);
      Printv(f_fdecl, "integer, parameter, public :: ", replacementname, " = C_INT\n", NULL);
    } else if (is_funptr) {
      // Generate automatic abstract function declaration
      int result = this->bindcfunctionHandler(n);
      if (!result) {
        // Failed to generate automatic type
        Printv(f_fabstract,
               " subroutine ", replacementname, "() bind(C)\n",
               " end subroutine\n",
               NULL);

        Swig_warning(WARN_LANG_NATIVE_UNIMPL, input_file, line_number,
                     "Procedure pointer '%s' is incompatible with Fortran\n",
                     replacementname);

        emit_fragment("SwigClassWrapper_f");
      }
      // Add callback node to the list of successfully generated types
      Setattr(d_callbacks, basetype, n);
    } else {
      emit_fragment("SwigClassWrapper_f");
      Printv(f_fdecl,
             " type, public :: ", replacementname, "\n",
             "  type(SwigClassWrapper), public :: swigdata\n",
             " end type\n",
             NULL);
    }
  }
  Setattr(d_emitted_mangled, replacementname, n);
  return replacementname;
}

/* ------------------------------------------------------------------------- */

bool FORTRAN::is_wrapped_type(SwigType *basetype) {
  if (SwigType_isenum(basetype)) {
    Node *n = this->enumLookup(basetype);
    return n && is_wrapped_enum(n);
  } else {
    return this->classLookup(basetype) != NULL;
  }
}

/* ------------------------------------------------------------------------- */

bool FORTRAN::is_wrapped_class(Node *n) {
  static Hash *cached_classes = NewHash();
  static String *is_wrapped = NewString("is wrapped");
  static String *not_wrapped = NewString("not wrapped");

  assert(n);

  SwigType *intype = Getattr(n, "type");

  // Check cache first
  String *cache_hit = Getattr(cached_classes, intype);
  if (cache_hit) {
    return Equal(cache_hit, is_wrapped);
  }

  SwigType *resolvedtype = SwigType_typedef_resolve_all(intype);
  SwigType *strippedtype = SwigType_strip_qualifiers(resolvedtype);

  String *tm = attach_typemap("ftype", n, WARN_NONE);

  bool result;
  if (!tm) {
    // Somehow there's no ftype; allow it to be wrapped so the error is handled later
    result = true;
  } else if (Strstr(tm, "$fortranclassname")) {
    result = this->is_wrapped_type(strippedtype);
  } else if (Strstr(tm, "$*fortranclassname")) {
    SwigType_pop(strippedtype);
    result = this->is_wrapped_type(strippedtype);
  } else if (Strstr(tm, "$&fortranclassname")) {
    SwigType_add_pointer(strippedtype);
    result = this->is_wrapped_type(strippedtype);
  } else {
    // Type doesn't resolve to something that expects a class name
    result = true;
  }

  // Save in cache
  Setattr(cached_classes, intype, result ? is_wrapped : not_wrapped);
  Delete(resolvedtype);
  Delete(strippedtype);
  return result;
}

/* -------------------------------------------------------------------------
 * \brief Add an overload for the generic method "fsymname" and the specific
 * procedure name "fname".
 *
 * Return SWIG_NOWRAP if the name conflicts.
 */
int FORTRAN::add_overload(String *fsymname, Node *n, String *fname, bool is_private) {
  // The module function name is aliased, and perhaps overloaded.
  // Append this function name to the list of overloaded names
  // for the symbol. The 'public' access specification gets added later.
  List *overloads = Getattr(d_overloads, fsymname);
  if (!overloads) {
    // If this is the first overload, make sure the symname is added to the global scope
    if (add_fsymbol(fsymname, n) == SWIG_NOWRAP)
      return SWIG_NOWRAP;
    overloads = NewList();
    Setattr(d_overloads, fsymname, overloads);
  }
  Append(overloads, fname);
  if (is_private) {
    SetFlag(d_private_overloads, fsymname);
  }
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Add lowercase symbol since fortran is case insensitive
 *
 * Return SWIG_NOWRAP if the name conflicts.
 */
int FORTRAN::add_fsymbol(String *s, Node *n) {
  ASSERT_OR_PRINT_NODE(s, n);
  if (GetFlag(n, "fortran:error_symbol")) {
    // Already warned about this symbol being a duplicate
    return SWIG_ERROR;
  }

  if (!is_valid_identifier(s)) {
    Swig_error(input_file, line_number,
               "The name '%s' is not a valid Fortran identifier. You must %%rename this %s.\n",
               s, nodeType(n));
    return SWIG_NOWRAP;
  }
  String *lower = Swig_string_lower(s);
  int result = this->addSymbol(lower, n, NULL);
  if (result == SWIG_ERROR) {
    // Don't warn about the symbol if we encounter it again
    SetFlag(n, "fortran:error_symbol");
  }

  Delete(lower);
  return result;
}

/* -------------------------------------------------------------------------
 * Expose the code to the SWIG main function.
 * ------------------------------------------------------------------------- */

extern "C" Language *swig_fortran(void) {
  return new FORTRAN();
}


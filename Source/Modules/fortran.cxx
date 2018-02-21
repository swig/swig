/* File : fortran.cxx */
#include "swigmod.h"
#include "cparse.h"
#include <ctype.h>

#define ASSERT_OR_PRINT_NODE(COND, NODE) \
  do { \
    if (!(COND)) { \
      Printf(stdout, "Assertion '" #COND "' failed for node:\n"); \
      Swig_print_node(NODE); \
      assert(0); \
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

const char fortran_end_statement[] = "\n";

/* -------------------------------------------------------------------------
 * UTILITY FUNCTIONS
 * ------------------------------------------------------------------------- */

/*!
 * \brief Whether a node is a constructor.
 *
 * Node should be a function
 */
bool is_node_constructor(Node *n) {
  return (Cmp(Getattr(n, "nodeType"), "constructor") == 0 || Getattr(n, "handled_as_constructor"));
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
  w->end_statement = fortran_end_statement;
  return w;
}

/* -------------------------------------------------------------------------
 * \brief Whether an expression is a standard base-10 integer compatible with
 * fortran
 *
 * Note that if it has a suffix e.g. `l` or `u`, or a prefix `0` (octal), it's
 * not compatible.
 *
 * Simple expressions like `1 + 2` are OK.
 */
bool is_fortran_intexpr(String *s) {
  const char *p = Char(s);
  char c = *p++;

  // Empty string is not an integer
  if (c == '\0')
    return false;

  // Outer loop over words/tokens
  while (c) {
    // If it's a multi-digit number that starts with 0, it's octal, and thus
    // not a simple integer
    if (c == '0' && *p != 0)
      return false;

    while (c) {
      if (c == '+' || c == '-' || c == '*' || c == ' ' || c == '/') {
        c = *p++;
        break;
      }

      if (!isdigit(c))
        return false;

      c = *p++;
    }
  }
  return true;
}

/* -------------------------------------------------------------------------
 * \brief Check a parameter for invalid dimension names.
 */
bool bad_fortran_dims(Node *n, const char *tmap_name) {
  bool is_bad = false;
  // See if the typemap needs its dimensions checked
  String *key = NewStringf("tmap:%s:checkdim", tmap_name);
  if (GetFlag(n, key)) {
    SwigType *t = Getattr(n, "type");
    if (SwigType_isarray(t)) {
      int ndim = SwigType_array_ndim(t);
      for (int i = 0; i < ndim; i++) {
        String *dim = SwigType_array_getdim(t, i);
        if (dim && !is_fortran_intexpr(dim)) {
          Swig_warning(WARN_LANG_IDENTIFIER, input_file, line_number,
                       "Array dimension expression '%s' is incompatible with Fortran\n",
                       dim);
          is_bad = true;
        }
        Delete(dim);
      }
    }
  }

  Delete(key);
  return is_bad;
}

/* -------------------------------------------------------------------------
 * \brief Determine whether to wrap an enum as a value.
 */
bool is_native_enum(Node *n) {
  String *enum_feature = Getattr(n, "feature:fortran:enumerator");
  if (!enum_feature) {
    // Determine from enum values
    for (Node *c = firstChild(n); c; c = nextSibling(c)) {
      if (Getattr(c, "error") || GetFlag(c, "feature:ignore"))
        continue;

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
    // "feature:fortran:enumerator" was set as a flag
    return true;
  }
}

/* -------------------------------------------------------------------------
 * \brief Determine whether to wrap an enum as a value.
 */
bool is_native_parameter(Node *n) {
  String *param_feature = Getattr(n, "feature:fortran:parameter");
  if (!param_feature) {
    // No user override given
    String *value = Getattr(n, "value");
    return is_fortran_intexpr(value);
  } else if (Strcmp(param_feature, "0") == 0) {
    // Not a native param
    return false;
  } else {
    // Value specified and isn't "0"
    return true;
  }
}

/* -------------------------------------------------------------------------
 * \brief Determine whether to wrap a function/class as a c-bound struct.
 */
bool is_bindc(Node *n) {
  String *bindc_feature = Getattr(n, "feature:fortran:bindc");
  if (!bindc_feature) {
    // No user override given: if it's extern(C) storage function, default
    // to binding it.
    String *kind = Getattr(n, "kind");
    if (!kind || Strcmp(kind, "function") != 0 || GetFlag(n, "ismember")) {
      // Not a function
      return false;
    }
    return !CPlusPlus || Swig_storage_isexternc(n);
  } else if (Strcmp(bindc_feature, "0") == 0) {
    // Not a native param
    return false;
  } else {
    // Value specified and isn't "0"
    return true;
  }
}

/* -------------------------------------------------------------------------
 * \brief Whether an SWIG type can be rendered as TYPE VAR.
 *
 * Some declarations (arrays, function pointers, member function pointers)
 * require the variable to be embedded in the middle of the array and thus
 * require special treatment.
 */
bool needs_typedef(String *s) {
  String *strprefix = SwigType_prefix(s);
  bool result = (Strstr(strprefix, "p.a(") || Strstr(strprefix, "p.f(") || Strstr(strprefix, "p.m("));
  Delete(strprefix);
  return result;
}

/* -------------------------------------------------------------------------
 * \brief Get some name attached to the node.
 *
 * This is for user feedback only.
 */
String *get_symname_or_name(Node *n) {
  String *s = Getattr(n, "sym:name");
  if (!s) {
    s = Getattr(n, "name");
  }
  return s;
}

/* -------------------------------------------------------------------------
 * \brief Get/attach and return a typemap to the given node.
 *
 * If 'ext' is non-null, then after binding/searchinbg, a search will be made
 * for the typemap with the given extension. If that's present, it's used
 * instead of the default typemap. (This allows overriding of e.g. 'tmap:ctype'
 * with 'tmap:ctype:out'.)
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
                 tmname, SwigType_str(type, 0));

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

/* -------------------------------------------------------------------------
 *! Attach and return a typemap to the given node.
 */
String *attach_typemap(const_String_or_char_ptr tmname, Node *n, int warning) {
  return get_typemap(tmname, NULL, n, warning, true);
}

//! Attach and return a typemap (with extension) to the given node.
String *attach_typemap(const_String_or_char_ptr tmname, const_String_or_char_ptr ext, Node *n, int warning) {
  return get_typemap(tmname, ext, n, warning, true);
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
 * This function is (exclusively?) used for the "tmap:ctype" attribute, which
 * the user inputs as a plain-text C declaration but doesn't automatically get
 * converted by the SWIG type system like the "type" attribute does.
 *
 * Caller is responsible for calling Delete on the return value. Will return
 * NULL if the typemap isn't defined.
 */
SwigType *parse_typemap(const_String_or_char_ptr tmname, const_String_or_char_ptr ext, Node *n, int warning) {
  // Get the typemap, which has the *unparsed and unsimplified* type
  String *raw_tm = get_typemap(tmname, ext, n, warning, true);
  // Convert the plain-text string to a SWIG type
  SwigType *parsed_type = Swig_cparse_type(raw_tm);
  assert(parsed_type);
  // Resolve typedefs in the parsed type
  SwigType *resolved_type = SwigType_typedef_resolve_all(parsed_type);

  // Replace the contents of the original typemap string with the parsed
  // result -- this is a sort of hack for avoiding the 'Setattr(tmname,
  // resolved_type)' where we'd have to recalculate the tmname key again
  Clear(raw_tm);
  Printv(raw_tm, resolved_type, NULL);
  Delete(parsed_type);
  Delete(resolved_type);
  return raw_tm;
}

/* ------------------------------------------------------------------------- */
String *add_explicit_scope(String *s) {
  if (!CPlusPlus) {
    return s;
  }
  if (!Strstr(s, "::")) {
    String *temp = NewStringf("::%s", s);
    Delete(s);
    s = temp;
  }
  return s;
}

/* ------------------------------------------------------------------------- */
}                                 // end anonymous namespace

class FORTRAN : public Language {
private:
  // >>> OUTPUT FILES

  // Injected into .cxx file
  String *f_begin;                                   //!< Very beginning of output file
  String *f_runtime;                                 //!< SWIG runtime code
  String *f_header;                                  //!< Declarations and inclusions from .i
  String *f_wrapper;                                 //!< C++ Wrapper code
  String *f_init;                                    //!< C++ initalization functions

  // Injected into module file
  String *f_fbegin;                                      //!< Very beginning of output file
  String *f_fmodule;                                     //!< Fortran "module" and "use" directives
  String *f_fpublic;                                     //!< List of public interface functions and mapping
  String *f_fparams;                                     //!< Generated enumeration/param types
  String *f_ftypes;                                      //!< Generated class types
  String *f_finterfaces;                                 //!< Fortran interface declarations to SWIG functions
  String *f_fwrapper;                                    //!< Fortran subroutine wrapper functions

  // Keep track of "No $fclassname replacement
  Hash *d_warned_fclassname;

  // Module-wide procedure interfaces
  Hash *d_overloads;                                 //!< Overloaded subroutine -> overload names

  // Current class parameters
  Hash *d_method_overloads;                                 //!< Overloaded subroutine -> overload names

  // Inside of the 'enum' definitions
  List *d_enum_public;                                 //!< List of enumerator values

  // >>> CONFIGURE OPTIONS

  String *d_fext;                                 //!< Fortran file extension

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
  virtual int staticmemberfunctionHandler(Node *n);
  virtual int staticmembervariableHandler(Node *n);
  virtual int enumDeclaration(Node *n);
  virtual int constantWrapper(Node *n);
  virtual int classforwardDeclaration(Node *n);

  virtual String *makeParameterName(Node *n, Parm *p, int arg_num, bool is_setter = false) const;
  virtual void replaceSpecialVariables(String *method, String *tm, Parm *parm);

  FORTRAN() : d_warned_fclassname(NULL), d_overloads(NULL), d_method_overloads(NULL), d_enum_public(NULL) {}

private:
  void cfuncWrapper(Node *n);
  int imfuncWrapper(Node *n);
  int proxyfuncWrapper(Node *n);
  void assignmentWrapper(Node *n);
  void write_docstring(Node *n, String *dest);

  void write_wrapper(String *filename);
  void write_module(String *filename);

  String *attach_class_typemap(const_String_or_char_ptr tmname, int warning);

  bool replace_fclassname(SwigType *type, String *tm);
  void replace_fspecial_impl(SwigType *classnametype, String *tm, const char *classnamespecialvariable, bool is_enum);

  // Add lowercase symbol (fortran)
  int add_fsymbol(String *s, Node *n, int warning=WARN_FORTRAN_NAME_CONFLICT);
  // Make a unique symbolic name
  String *make_unique_symname(Node *n);
  // Get overloads of the given named method
  List *get_method_overloads(String *generic);
  // Whether the current class is a BIND(C) struct
  bool is_basic_struct() const { return d_method_overloads == NULL; }
};

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
  f_fmodule = NewStringEmpty();
  Swig_register_filebyname("fmodule", f_fmodule);

  // Public interface functions
  f_fpublic = NewStringEmpty();
  Swig_register_filebyname("fpublic", f_fpublic);

  // Enums and parameters
  f_fparams = NewStringEmpty();
  Swig_register_filebyname("fparams", f_fparams);

  // Fortran classes
  f_ftypes = NewStringEmpty();
  Swig_register_filebyname("ftypes", f_ftypes);

  // Fortran BIND(C) interfavces
  f_finterfaces = NewStringEmpty();
  Swig_register_filebyname("finterfaces", f_finterfaces);

  // Fortran subroutines (proxy code)
  f_fwrapper = NewStringEmpty();
  Swig_register_filebyname("fwrapper", f_fwrapper);

  // Tweak substitution code
  Swig_name_register("wrapper", "swigc_%f");
  Swig_name_register("set", "set_%n%v");
  Swig_name_register("get", "get_%n%v");

  d_warned_fclassname = NewHash();
  d_overloads = NewHash();

  // Declare scopes: fortran types and forward-declared types
  this->symbolAddScope("fortran");
  this->symbolAddScope("fortran_fwd");

  // Emit all other wrapper code
  Language::top(n);

  // Write C++ wrapper file
  write_wrapper(Getattr(n, "outfile"));

  // Write fortran module file
  write_module(Getattr(n, "fortran:outfile"));

  // Clean up files and other data
  Delete(d_overloads);
  Delete(f_fwrapper);
  Delete(f_finterfaces);
  Delete(f_ftypes);
  Delete(f_fpublic);
  Delete(f_fmodule);
  Delete(f_init);
  Delete(f_wrapper);
  Delete(f_header);
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

  // Write three different levels of output
  Dump(f_begin, out);
  Dump(f_runtime, out);
  Dump(f_header, out);

  // Write wrapper code
  Printf(out, "#ifdef __cplusplus\n");
  Printf(out, "extern \"C\" {\n");
  Printf(out, "#endif\n");
  Dump(f_wrapper, out);
  Printf(out, "#ifdef __cplusplus\n");
  Printf(out, "}\n");
  Printf(out, "#endif\n");

  // Write initialization code
  Wrapper_pretty_print(f_init, out);

  // Close file
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
  Dump(f_fmodule, out);
  Printv(out,
         " implicit none\n"
         " private\n",
         NULL);
  if (Len(f_fpublic) > 0 || Len(d_overloads) > 0) {
    Printv(out, "\n ! PUBLIC METHODS AND TYPES\n", f_fpublic, NULL);
  }

  // Write overloads and renamed module procedures
  for (Iterator kv = First(d_overloads); kv.key; kv = Next(kv)) {
    Printv(out,
           " public :: ",
           kv.key,
           "\n"
           " interface ",
           kv.key,
           "\n"
           "  module procedure ",
           NULL);

    // Write overloaded procedure names
    int line_length = 19;
    line_length = print_wrapped_list(out, First(kv.item), line_length);
    Printv(out,
           "\n"
           " end interface\n",
           NULL);
  }

  if (Len(f_fparams) > 0) {
    Printv(out, "\n ! PARAMETERS\n", f_fparams, NULL);
  }
  if (Len(f_ftypes) > 0) {
    Printv(out, "\n ! TYPES\n", f_ftypes, "\n", NULL);
  }
  if (Len(f_finterfaces) > 0) {
    Printv(out,
           "\n ! WRAPPER DECLARATIONS\n"
           " interface\n",
           f_finterfaces,
           " end interface\n"
           "\n",
           NULL);
  }
  if (Len(f_fwrapper) > 0) {
    Printv(out,
           "\ncontains\n"
           " ! FORTRAN PROXY CODE\n",
           f_fwrapper,
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
  String *modname = Swig_string_lower(Getattr(n, "name"));
  int success = this->add_fsymbol(modname, n, WARN_NONE);
  
  if (ImportMode) {
    // This %module directive is inside another module being %imported
    Printv(f_fmodule, " use ", modname, "\n", NULL);
    success = SWIG_OK;
  } else if (success) {
    // This is the first time the `%module` directive is seen. (Note that
    // other `%module` directives may be present, but they're
    // given the same name as the main module and should be ignored.
    // Write documentation if given. Note that it's simply labeled "docstring"
    // and in a daughter node; to unify the doc string processing we just set
    // it as a feature attribute on the module.
    Node *options = Getattr(n, "options");
    if (options) {
      String *docstring = Getattr(options, "docstring");
      if (docstring) {
        Setattr(n, "feature:docstring", docstring);
        this->write_docstring(n, f_fmodule);
      }
    }

    Printv(f_fmodule,
           "module ",
           modname,
           "\n"
           " use, intrinsic :: ISO_C_BINDING\n",
           NULL);
  }

  Delete(modname);
  return success;
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
  const bool is_cbound = is_bindc(n);
  const bool is_member_function = GetFlag(n, "fortran:ismember");

  // >>> SET UP WRAPPER NAME

  String *symname = Getattr(n, "sym:name");
  String *fsymname = NULL;                                 // Fortran public function name alias
  String *fname = NULL;                                    // Fortran proxy function name
  String *wname = NULL;                                    // SWIG wrapper function name

  if (!is_cbound) {
    // Usual case: generate a unique wrapper name
    wname = Swig_name_wrapper(symname);
  } else {
    // BIND(C): name is preserved
    wname = Copy(symname);
  }

  if (String *private_fname = Getattr(n, "fortran:fname")) {
    // Create "private" fortran wrapper function class name that will
    // be bound to a class
    ASSERT_OR_PRINT_NODE(!is_cbound, n);
    fname = Copy(private_fname);
  } else {
    // Use actual symbolic function name
    fname = Copy(symname);
  }

  // Add suffix if the function is overloaded
  bool is_overloaded = Getattr(n, "sym:overloaded");
  if (is_overloaded) {
    String *overload_ext = Getattr(n, "sym:overname");
    Append(wname, overload_ext);
    Append(fname, overload_ext);
  }

  Setattr(n, "wrap:name", wname);
  Setattr(n, "wrap:fname", fname);

  // Add the fortran subroutine name to the current scope
  if (add_fsymbol(fname, n) == SWIG_NOWRAP)
    return SWIG_NOWRAP;

  if (String *varname = Getattr(n, "fortran:variable")) {
    // We're wrapping a variable or member variable: construct a custom
    // name.
    if (Getattr(n, "varset") || Getattr(n, "memberset")) {
      fsymname = Swig_name_set(getNSpace(), varname);
    } else if (Getattr(n, "varget") || Getattr(n, "memberget")) {
      fsymname = Swig_name_get(getNSpace(), varname);
    } else {
      ASSERT_OR_PRINT_NODE(0, n);
    }
  } else {
    // Get manually-set fsymname and make a copy
    fsymname = Getattr(n, "fortran:name");
    if (!fsymname) {
      // Alias defaults to symname
      fsymname = symname;
    }
    fsymname = Copy(fsymname);
  }

  if (!is_cbound) {
    // >>> GENERATE WRAPPER CODE

    // Typical function wrapping
    this->cfuncWrapper(n);
    if (this->imfuncWrapper(n) == SWIG_NOWRAP)
      return SWIG_NOWRAP;
    if (this->proxyfuncWrapper(n) == SWIG_NOWRAP)
      return SWIG_NOWRAP;
  } else {
    if (CPlusPlus && !Swig_storage_isexternc(n)) {
      Swig_warning(WARN_LANG_IDENTIFIER, input_file, line_number,
                   "The function '%s' appears not to be defined with external "
                   "C linkage (extern \"C\"). Link errors may result.\n",
                   symname);
    }
    // Simply binding a function for Fortran

    // Emit all of the local variables for holding arguments.
    ParmList *parmlist = Getattr(n, "parms");
    Swig_typemap_attach_parms("bindc", parmlist, NULL);
    emit_attach_parmmaps(parmlist, NULL);
    Setattr(n, "wrap:parms", parmlist);

    // Create a list of parameters wrapped by the intermediate function
    List *cparmlist = NewList();
    int i = 0;
    for (Parm *p = parmlist; p; p = nextSibling(p), ++i) {
      // Use C arguments
      String *imname = this->makeParameterName(n, p, i);
      Setattr(p, "imname", imname);
      Append(cparmlist, p);
    }

    // Save list of wrapped parms for im declaration and proxy
    Setattr(n, "wrap:cparms", cparmlist);

    if (this->imfuncWrapper(n) == SWIG_NOWRAP)
      return SWIG_NOWRAP;
  }

  // >>> GENERATE CODE FOR MODULE INTERFACE

  if (is_member_function) {
    ASSERT_OR_PRINT_NODE(!is_basic_struct(), n);
    String *qualifiers = NewStringEmpty();

    if (is_overloaded) {
      // Overload the procedure name; the name exposed by the module is
      // the "generic"
      String *generic = fsymname;
      fsymname = Copy(fsymname);
      Append(fsymname, Getattr(n, "sym:overname"));

      // Add name to method overload list
      List *overloads = this->get_method_overloads(generic);
      Append(overloads, fsymname);

      // Make the procedure private
      Append(qualifiers, ", private");
      Delete(generic);
    }
    if (String *extra_quals = Getattr(n, "fortran:procedure")) {
      // Add qualifiers like "static" for static functions
      Printv(qualifiers, ", ", extra_quals, NULL);
    }

    Printv(f_ftypes, "  procedure", qualifiers, " :: ", fsymname, " => ", fname, "\n", NULL);
    Delete(qualifiers);
  } else if (Strcmp(fsymname, fname) != 0) {
    // The function name is aliased, either by 'fortran:fname' or an
    // overload. Append this function name to the list of overloaded names
    // for the symbol. 'public' access specification gets added later.
    List *overloads = Getattr(d_overloads, fsymname);
    if (!overloads) {
      overloads = NewList();
      Setattr(d_overloads, fsymname, overloads);
    }
    Append(overloads, Copy(fname));
  } else {
    //
    Printv(f_fpublic, " public :: ", fsymname, "\n", NULL);
  }

  Delete(fname);
  Delete(wname);
  Delete(fsymname);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Generate C/C++ wrapping code
 */
void FORTRAN::cfuncWrapper(Node *n) {
  String *symname = Getattr(n, "sym:name");

  Wrapper *cfunc = NewWrapper();

  // >>> RETURN VALUES

  // Get the SWIG type representation of the C return type, but first the
  // ctype typemap has to be attached
  Swig_typemap_lookup("ctype", n, Getattr(n, "name"), NULL);
  SwigType *c_return_type = parse_typemap("ctype", "out", n, WARN_FORTRAN_TYPEMAP_CTYPE_UNDEF);
  const bool is_csubroutine = (Strcmp(c_return_type, "void") == 0);

  String *c_return_str = NULL;
  if (needs_typedef(c_return_type)) {
    // For these types (where the name is the middle of the expression
    // rather than at the right side,
    // i.e. void (*func)() instead of int func,
    // we either have to add a new typedef OR wrap the
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
  Setattr(n, "wrap:parms", parmlist);

  // Create a list of parameters wrapped by the intermediate function
  List *cparmlist = NewList();

  const char *prepend_comma = "";
  Parm *p = parmlist;
  while (p) {
    if (checkAttribute(p, "tmap:in:numinputs", "0")) {
      // Skip this typemap
      p = Getattr(p, "tmap:in:next");
      continue;
    } else if (SwigType_isvarargs(Getattr(p, "type"))) {
      Swig_warning(WARN_LANG_NATIVE_UNIMPL, Getfile(p), Getline(p),
                   "Variable arguments (in function '%s') are not implemented in Fortran.\n",
                   SwigType_namestr(Getattr(n, "sym:name")));
    } else {
      // Name of the argument in the function call (e.g. farg1)
      String *imname = NewStringf("f%s", Getattr(p, "lname"));
      Setattr(p, "imname", imname);
      Append(cparmlist, p);

      // Get the user-provided C type string, and convert it to a SWIG
      // internal representation using Swig_cparse_type . Then convert the
      // type and argument name to a valid C expression using SwigType_str.
      SwigType *parsed_tm = parse_typemap("ctype", NULL, p, WARN_FORTRAN_TYPEMAP_CTYPE_UNDEF);
      if (!parsed_tm) {
        Swig_error(input_file, line_number,
                   "Failed to parse 'ctype' typemap for argument %s of %s\n",
                   SwigType_str(Getattr(p, "type"), Getattr(p, "name")), SwigType_namestr(symname));
        return;
      }
      String *carg = SwigType_str(parsed_tm, imname);
      Printv(cfunc->def, prepend_comma, carg, NULL);
      Delete(carg);

      // Next iteration
      prepend_comma = ", ";
    }

    // Next iteration
    p = nextSibling(p);
  }

  // Save list of wrapped parms for im declaration and proxy
  Setattr(n, "wrap:cparms", cparmlist);

  // END FUNCTION DEFINITION
  Printv(cfunc->def, ") {", NULL);

  // >>> ADDITIONAL WRAPPER CODE

  String *cleanup = NewStringEmpty();
  String *outarg = NewStringEmpty();

  // Insert input conversion, constraint checking, and cleanup code
  for (Iterator it = First(cparmlist); it.item; it = Next(it)) {
    Parm *p = it.item;
    if (String *tm = Getattr(p, "tmap:in")) {
      this->replace_fclassname(Getattr(p, "type"), tm);
      String *imname = Getattr(p, "imname");
      Replaceall(tm, "$input", imname);
      Setattr(p, "emit:input", imname);
      Printv(cfunc->code, tm, "\n", NULL);
    }
    if (String *tm = Getattr(p, "tmap:check")) {
      Replaceall(tm, "$input", Getattr(p, "emit:input"));
      Printv(cfunc->code, tm, "\n", NULL);
    }
    if (String *tm = Getattr(p, "tmap:freearg")) {
      Replaceall(tm, "$input", Getattr(p, "emit:input"));
      Printv(cleanup, tm, "\n", NULL);
    }
    if (String *tm = Getattr(p, "tmap:argout")) {
      Replaceall(tm, "$result", "fresult");
      Replaceall(tm, "$input", Getattr(p, "emit:input"));
      Printv(outarg, tm, "\n", NULL);
    }
  }

  // Generate code to make the C++ function call
  Swig_director_emit_dynamic_cast(n, cfunc);
  String *actioncode = emit_action(n);

  // Generate code to return the value
  String *cpp_return_type = Getattr(n, "type");
  if (String *code = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), cfunc, actioncode)) {
    // Output typemap is defined; emit the function call and result
    // conversion code
    Replaceall(code, "$result", "fresult");
    Replaceall(code, "$owner", (GetFlag(n, "feature:new") ? "1" : "0"));
    Printv(cfunc->code, code, "\n", NULL);
  } else {
    // XXX this should probably raise an error
    Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
                 "Unable to use return type %s in function %s.\n",
                 SwigType_str(cpp_return_type, 0), Getattr(n, "name"));
  }
  emit_return_variable(n, cpp_return_type, cfunc);

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
  Wrapper_print(cfunc, f_wrapper);

  Delete(cparmlist);
  Delete(outarg);
  Delete(cleanup);
  Delete(c_return_str);
  DelWrapper(cfunc);
}

/* -------------------------------------------------------------------------
 * \brief Generate Fortran interface code
 *
 * This is the Fortran equivalent of the cfuncWrapper's declaration.
 */
int FORTRAN::imfuncWrapper(Node *n) {
  // Name of the C wrapper function
  String *wname = Getattr(n, "wrap:name");
  String *cpp_return_type = Getattr(n, "type");

  Wrapper *imfunc = NewFortranWrapper();

  const char *tmtype = "imtype";
  const char *tmimportkey = "tmap:imtype:import";
  int warning_flag = WARN_FORTRAN_TYPEMAP_IMTYPE_UNDEF;
  if (is_bindc(n)) {
    tmtype = "bindc";
    tmimportkey = "tmap:bindc:import";
    warning_flag = WARN_TYPEMAP_UNDEF;
  }

  // >>> RETURN VALUES

  // Attach typemap for return value
  String *im_return_str = attach_typemap(tmtype, n, warning_flag);

  // Check whether the C routine returns a variable
  const bool is_imsubroutine = (Len(im_return_str) == 0);
  const char *im_func_type = (is_imsubroutine ? "subroutine" : "function");

  Printv(imfunc->def, im_func_type, " ", wname, "(", NULL);

  // Hash of import statements needed for the interface code
  Hash *imimport_hash = NewHash();

  // If return type is a fortran C-bound type, add import statement
  String *imimport = Getattr(n, tmimportkey);
  if (imimport) {
    this->replace_fclassname(cpp_return_type, imimport);
    Setattr(imimport_hash, imimport, "1");
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
  const char *prepend_comma = "";
  for (Iterator it = First(cparmlist); it.item; it = Next(it)) {
    Parm *p = it.item;

    // Name of the argument in the function call (e.g. farg1)
    String *imname = Getattr(p, "imname");

    // Add parameter name to declaration list
    Printv(imfunc->def, prepend_comma, imname, NULL);

    // Add dummy argument to wrapper body
    String *imtype = get_typemap(tmtype, "in", p, warning_flag);
    this->replace_fclassname(Getattr(p, "type"), imtype);
    Printv(imlocals, "\n   ", imtype, " :: ", imname, NULL);

    // Check for bad dimension parameters
    if (bad_fortran_dims(p, tmtype)) {
      return SWIG_NOWRAP;
    }

    // Include import statements if present; needed for actual structs
    // passed into interface code
    String *imimport = Getattr(p, tmimportkey);
    if (imimport) {
      this->replace_fclassname(Getattr(p, "type"), imimport);
      Setattr(imimport_hash, imimport, "1");
    }

    // Next iteration
    prepend_comma = ", ";
  }

  // END FUNCTION DEFINITION
  Printv(imfunc->def,
         ") &\n"
         "    bind(C, name=\"",
         wname,
         "\")",
         NULL);

  if (!is_imsubroutine) {
    // Declare dummy return value if it's a function
    Printv(imfunc->def, " &\n     result(fresult)", NULL);
    this->replace_fclassname(cpp_return_type, im_return_str);
    Printv(imlocals, "\n", im_return_str, " :: fresult", NULL);
  }

  // Write the function local block
  Printv(imfunc->code, "   use, intrinsic :: ISO_C_BINDING", NULL);
  for (Iterator kv = First(imimport_hash); kv.key; kv = Next(kv)) {
    Printv(imfunc->code, "\n   import :: ", kv.key, NULL);
  }
  Printv(imfunc->code, imlocals, "\n  end ", im_func_type, NULL);

  // Write the C++ function into the wrapper code file
  Wrapper_print(imfunc, f_finterfaces);

  DelWrapper(imfunc);
  Delete(imimport_hash);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Generate Fortran proxy code
 *
 * This is for the native Fortran interaction.
 */
int FORTRAN::proxyfuncWrapper(Node *n) {
  Wrapper *ffunc = NewFortranWrapper();

  // Write documentation
  this->write_docstring(n, f_fwrapper);

  // >>> FUNCTION RETURN VALUES

  String *fargs = NewStringEmpty();

  String *f_return_str = NULL;
  if (!f_return_str) {
    f_return_str = Getattr(n, "feature:ftype");
    Chop(f_return_str);
  }
  if (!f_return_str) {
    f_return_str = attach_typemap("ftype", "out", n, WARN_FORTRAN_TYPEMAP_FTYPE_UNDEF);
  }
  assert(f_return_str);

  // Return type for the C call
  String *im_return_str = get_typemap("imtype", "out", n, WARN_NONE);

  // Check whether the Fortran proxy routine returns a variable, and whether
  // the actual C function does

  // Replace any instance of $fclassname in return type
  String *cpp_return_type = Getattr(n, "type");
  this->replace_fclassname(cpp_return_type, f_return_str);
  this->replace_fclassname(cpp_return_type, im_return_str);

  // String for calling the im wrapper on the fortran side (the "action")
  String *fcall = NewStringEmpty();

  const bool is_imsubroutine = (Len(im_return_str) == 0);
  if (!is_imsubroutine) {
    Wrapper_add_localv(ffunc, "fresult", im_return_str, ":: fresult", NULL);
    // Call function and set intermediate result
    Printv(fcall, "fresult = ", NULL);
  } else {
    Printv(fcall, "call ", NULL);
  }
  Printv(fcall, Getattr(n, "wrap:name"), "(", NULL);

  const char *swig_result_name = "";
  const bool is_fsubroutine = (Len(f_return_str) == 0);
  if (!is_fsubroutine) {
    if (String *fresult_override = Getattr(n, "wrap:fresult")) {
      swig_result_name = Char(fresult_override);
    } else {
      swig_result_name = "swig_result";
    }
    // Add dummy variable for Fortran proxy return
    Printv(fargs, f_return_str, " :: ", swig_result_name, "\n", NULL);
  }

  // >>> FUNCTION NAME

  const char *f_func_type = (is_fsubroutine ? "subroutine" : "function");
  Printv(ffunc->def, f_func_type, " ", Getattr(n, "wrap:fname"), "(", NULL);

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
    Setattr(p, "lname:saved", Getattr(p, "lname"));
    Setattr(p, "lname", Getattr(p, "imname"));
  }

  // Attach proxy input typemap (proxy arg -> farg1 in fortran function)
  ParmList *parmlist = Getattr(n, "parms");
  Swig_typemap_attach_parms("ftype", parmlist, ffunc);
  Swig_typemap_attach_parms("fin", parmlist, ffunc);
  Swig_typemap_attach_parms("findecl", parmlist, ffunc);
  Swig_typemap_attach_parms("ffreearg", parmlist, ffunc);

  // Restore parameter names
  for (Iterator it = First(cparmlist); it.item; it = Next(it)) {
    Parm *p = it.item;
    String *imname = Getattr(p, "imname");

    // Emit local intermediate parameter in the proxy function
    String *imtype = get_typemap("imtype", p, WARN_FORTRAN_TYPEMAP_IMTYPE_UNDEF);
    this->replace_fclassname(Getattr(p, "type"), imtype);
    Wrapper_add_localv(ffunc, imname, imtype, "::", imname, NULL);

    // Restore local variable name
    Setattr(p, "lname", Getattr(p, "lname:saved"));
    Delattr(p, "lname:saved");
  }

  // >>> BUILD WRAPPER FUNCTION AND INTERFACE CODE

  String *prepend = Getattr(n, "feature:fortran:prepend");
  if (prepend) {
    Chop(prepend);
    Printv(ffunc->code, prepend, "\n", NULL);
  }

  int i = 0;
  const char *prepend_comma = "";
  for (Iterator it = First(cparmlist); it.item; it = Next(it), ++i) {
    Parm *p = it.item;
    String *cpptype = Getattr(p, "type");

    // Add parameter name to declaration list
    String *farg = this->makeParameterName(n, p, i);
    Setattr(p, "fname", farg);
    Printv(ffunc->def, prepend_comma, farg, NULL);

    // Add dummy argument to wrapper body
    String *ftype = get_typemap("ftype", "in", p, WARN_FORTRAN_TYPEMAP_FTYPE_UNDEF);
    this->replace_fclassname(cpptype, ftype);
    Printv(fargs, "   ", ftype, " :: ", farg, "\n", NULL);

    if (bad_fortran_dims(p, "ftype")) {
      return SWIG_NOWRAP;
    }

    // Add this argument to the intermediate call function
    Printv(fcall, prepend_comma, Getattr(p, "imname"), NULL);

    // >>> F PROXY CONVERSION

    String *fin = get_typemap("fin", p, WARN_TYPEMAP_IN_UNDEF);
    Replaceall(fin, "$input", farg);
    Printv(ffunc->code, fin, "\n", NULL);

    // Add any needed temporary variables
    String *findecl = get_typemap("findecl", p, WARN_NONE);
    if (findecl) {
      Chop(findecl);
      Printv(fargs, findecl, "\n", NULL);
    }

    Delete(farg);

    // Next iteration
    prepend_comma = ", ";
  }

  // END FUNCTION DEFINITION
  Printv(ffunc->def, ")", NULL);
  Printv(fcall, ")", NULL);

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

  if (!is_fsubroutine) {
    Setattr(n, "fname", swig_result_name);
    Printv(ffunc->def, " &\n     result(", swig_result_name, ")", NULL);
  }

  // Append dummy variables to the proxy function definition
  Chop(fargs);
  Printv(ffunc->def, "\n   use, intrinsic :: ISO_C_BINDING\n", fargs, NULL);

  // >>> ADDITIONAL WRAPPER CODE

  // Get transformations on the output data in the fortran proxy code
  String *fbody = Getattr(n, "feature:fout");
  String *fparm = Getattr(n, "feature:foutdecl");

  if (!fbody) {
    // Instead of using a feature (overriding), use a typemap
    if (fparm) {
      // Foutdecl *must* have fout
      Swig_warning(WARN_NONE, input_file, line_number,
                   "'feature:foutdecl' is being ignored for %s because 'feature:fout' is not defined for it\n",
                   Getattr(n, "name"));
    }

    // Get the typemap for output argument conversion
    Parm *temp = NewParm(cpp_return_type, Getattr(n, "name"), n);
    Setattr(temp, "lname", "fresult");                                 // Replaces $1
    fbody = attach_typemap("fout", temp, WARN_FORTRAN_TYPEMAP_FOUT_UNDEF);
    if (bad_fortran_dims(temp, "fout")) {
      return SWIG_NOWRAP;
    }

    fparm = attach_typemap("foutdecl", temp, WARN_NONE);
    Delete(temp);
  } else {
    // Replace special variables in feature
    Replaceall(fbody, "$1", "fresult");
  }
  Chop(fbody);

  if (fparm) {
    Chop(fparm);
    // Write fortran output parameters after dummy argument
    Printv(ffunc->def, "\n", fparm, NULL);
  }

  // Output typemap is defined; emit the function call and result
  // conversion code
  if (Len(fbody) > 0) {
    Replaceall(fbody, "$result", swig_result_name);
    Replaceall(fbody, "$owner", (GetFlag(n, "feature:new")
                                 ? ".true." : ".false."));
    this->replace_fclassname(cpp_return_type, fbody);
    Printv(ffunc->code, fbody, "\n", NULL);
  }

  // Optional "append" proxy code
  String *append = Getattr(n, "feature:fortran:append");
  if (append) {
    Chop(append);
    Printv(ffunc->code, append, "\n", NULL);
  }

  // Insert Fortran cleanup code
  String *fcleanup = NewStringEmpty();
  for (Iterator it = First(cparmlist); it.item; it = Next(it), ++i) {
    Parm *p = it.item;
    if (String *tm = Getattr(p, "tmap:ffreearg")) {
      Chop(tm);
      Replaceall(tm, "$input", Getattr(p, "fname"));
      Printv(fcleanup, tm, "\n", NULL);
    }
  }
  if (Len(fcleanup) > 0) {
    Printv(ffunc->code, fcleanup, "\n", NULL);
  }

  // Output argument output and cleanup code
  Printv(ffunc->code, "  end ", f_func_type, NULL);

  // Apply standard SWIG substitutions
  Replaceall(ffunc->code, "$symname", Getattr(n, "sym:name"));

  // Write the C++ function into the wrapper code file
  Wrapper_print(ffunc, f_fwrapper);

  DelWrapper(ffunc);
  Delete(fcleanup);
  Delete(fcall);
  Delete(fargs);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief KLUDGE: manually add assignment code to output file.
 *
 * I'd later like to do this by adding a child node to the class during
 * classDeclaration, as is done with copy constructors in Language. But I kept
 * getting assertions in the type resolution part of the code.
 *
 * Here 'n' is the class node.
 */
void FORTRAN::assignmentWrapper(Node *n) {
  ASSERT_OR_PRINT_NODE(!is_basic_struct(), n);

  String *symname = Getattr(n, "sym:name");
  String *classtype = Getattr(n, "feature:smartptr");
  if (!classtype) {
    classtype = Getattr(n, "classtype");
  }
  classtype = add_explicit_scope(Copy(classtype));

  // Create overloaded aliased name
  String *generic = NewString("assignment(=)");
  String *fname = NewStringf("swigf_assignment_%s", Getattr(n, "sym:name"));
  String *wrapname = NewStringf("swigc_assignment_%s", Getattr(n, "sym:name"));

  // Add self-assignment to method overload list
  List *overloads = this->get_method_overloads(generic);
  Append(overloads, fname);

  // Define the method
  Printv(f_ftypes, "  procedure, private :: ", fname, "\n", NULL);

  // Add the proxy code implementation of assignment (increments the
  // reference counter)
  Printv(f_fwrapper,
         "  subroutine ",
         fname,
         "(self, other)\n"
         "   use, intrinsic :: ISO_C_BINDING\n"
         "   class(",
         symname,
         "), intent(inout) :: self\n"
         "   type(",
         symname,
         "), intent(in) :: other\n"
         "   call ",
         wrapname,
         "(self%swigdata, other%swigdata)\n"
         "  end subroutine\n",
         NULL);

  // Add interface code
  Printv(f_finterfaces,
         "  subroutine ",
         wrapname,
         "(self, other) &\n"
         "     bind(C, name=\"",
         wrapname,
         "\")\n"
         "   use, intrinsic :: ISO_C_BINDING\n"
         "   import :: SwigClassWrapper\n"
         "   type(SwigClassWrapper), intent(inout) :: self\n"
         "   type(SwigClassWrapper), intent(in) :: other\n"
         "  end subroutine\n",
         NULL);

  // Determine construction flags. These are ignored if C++11 is being used
  // to compile the wrapper. If 'default_destructor' is not set, the class probably has a private or protected destructor.
  String *flags = NewString("0");
  if (GetFlag(n, "allocate:default_destructor")) {
    Printv(flags, " | swig::IS_DESTR", NULL);
  }
  if (!Abstract && GetFlag(n, "allocate:copy_constructor")) {
    Printv(flags, " | swig::IS_COPY_CONSTR", NULL);
  }
  if (GetFlag(n, "allocate:has_assign") && !GetFlag(n, "allocate:noassign")) {
    Printv(flags, " | swig::IS_COPY_ASSIGN", NULL);
  }

  // Add C code
  Wrapper *cfunc = NewWrapper();
  Printv(cfunc->def,
         "SWIGEXPORT void ",
         wrapname,
         "("
         "SwigClassWrapper * self, "
         "SwigClassWrapper const * other) {\n",
         NULL);
  Printv(cfunc->code,
         "typedef ",
         classtype,
         " swig_lhs_classtype;\n"
         "SWIG_assign(swig_lhs_classtype, self,\n"
         "            swig_lhs_classtype, ",
         (CPlusPlus ? "const_cast<SwigClassWrapper*>(other)" : "(SwigClassWrapper*)(other)"),
         ",\n"
         "             ",
         flags,
         ");\n"
         "}\n",
         NULL);
  Wrapper_print(cfunc, f_wrapper);

  // Insert assignment fragment
  String *fragname = NewString("SWIG_assign");
  Swig_fragment_emit(fragname);

  Delete(fragname);
  Delete(flags);
  Delete(generic);
  Delete(fname);
  Delete(wrapname);
  Delete(classtype);
  DelWrapper(cfunc);
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
    Printv(dest, "! ", it.item, "\n", NULL);
  }

  Delete(lines);
}

/* -------------------------------------------------------------------------
 * \brief Create a friendly parameter name
 */
String *FORTRAN::makeParameterName(Node *n, Parm *p, int arg_num, bool setter)  const {
  String *name = Getattr(p, "name");
  if (name) {
    if (Strstr(name, "::"))

    {
      // Name has qualifiers (probably a static variable setter)
      // so replace it with something simple
      name = NewStringf("value%d", arg_num);
    } else {
      name = Swig_name_make(p, 0, name, 0, 0);
    }
  } else {
    // The general function which replaces arguments whose
    // names clash with keywords with (less useful) "argN".
    name = Language::makeParameterName(n, p, arg_num, setter);
  }
  // Fortran parameters will all be lowercase
  String *oldname = name;
  name = Swig_string_lower(oldname);
  Delete(oldname);
  oldname = NULL;

  // XXX: the older symbolScopeLookup function is not const-correct
  FORTRAN* mthis = const_cast<FORTRAN*>(this);

  // If the parameter name is in the fortran scope, or in the
  // forward-declared classes, mangle it
  Hash *symtab = mthis->symbolScopeLookup("fortran");
  Hash *fwdsymtab = mthis->symbolScopeLookup("fortran_fwd");
  String *origname = name;                                 // save pointer to unmangled name
  while (Getattr(symtab, name) || Getattr(fwdsymtab, name)) {
    // Rename
    Delete(oldname);
    oldname = name;
    name = NewStringf("%s%d", origname, arg_num++);
  }
  return name;
}

/* -------------------------------------------------------------------------
 * \brief Process a class declaration.
 *
 * The superclass calls classHandler.
 */
int FORTRAN::classDeclaration(Node *n) {
  if (!GetFlag(n, "feature:onlychildren")) {
    if (ImportMode) {
      // Add the class to the symbol table since it's not being wrapped
      add_fsymbol(Getattr(n, "sym:name"), n);
    }
    if (is_bindc(n)) {
      // Prevent default constructors, destructors, etc.
      SetFlag(n, "feature:nodefault");
    }
  }
  return Language::classDeclaration(n);
}

/* -------------------------------------------------------------------------
 * \brief Process classes.
 */
int FORTRAN::classHandler(Node *n) {
  // Add the class name or warn if it's a duplicate
  String *symname = Getattr(n, "sym:name");
  if (add_fsymbol(symname, n) == SWIG_NOWRAP)
    return SWIG_NOWRAP;

  String *basename = NULL;

  // Iterate through the base classes. If no bases are set (null pointer sent
  // to `First`), the loop will be skipped and baseclass be NULL.
  for (Iterator base = First(Getattr(n, "bases")); base.item; base = Next(base)) {
    Node *b = base.item;
    if (GetFlag(b, "feature:ignore"))
      continue;
    if (!basename) {
      // First class that was encountered
      basename = Getattr(b, "sym:name");
    } else {
      // Another base class exists
      Swig_warning(WARN_FORTRAN_MULTIPLE_INHERITANCE, Getfile(b), Getline(b),
                   "Multiple inheritance is not supported in Fortran. Ignoring base class %s for %s",
                   SwigType_namestr(Getattr(b, "sym:name")),
                   SwigType_namestr(Getattr(n, "sym:name")));
    }
  }

  const bool basic_struct = is_bindc(n);
  if (basic_struct && basename) {
    // Disallow inheritance for BIND(C) types
    Swig_error(input_file, line_number,
               "Struct '%s' has the 'bindc' feature set, so it cannot use inheritance.\n",
               SwigType_namestr(symname));
    return SWIG_NOWRAP;
  }

  // Make the class publicly accessible
  Printv(f_fpublic, " public :: ", symname, "\n", NULL);

  // Write documentation
  this->write_docstring(n, f_ftypes);

  // Declare class
  Printv(f_ftypes, " type", NULL);
  if (basename) {
    Printv(f_ftypes, ", extends(", basename, ")", NULL);
  } else if (basic_struct) {
    Printv(f_ftypes, ", bind(C)", NULL);
  }
  Printv(f_ftypes, " :: ", symname, "\n", NULL);

  if (!basic_struct) {
    if (!basename) {
      String *fdata = this->attach_class_typemap("fdata", WARN_NONE);
      if (!fdata) {
        Swig_error(input_file, line_number,
                   "Class '%s' has no '%s' typemap defined\n",
                   SwigType_namestr(symname), "fdata");
        return SWIG_NOWRAP;
      }
      Chop(fdata);
      // Insert the class data if this doesn't inherit from anything
      Printv(f_ftypes,
             "  ! These should be treated as PROTECTED data\n"
             "  ",
             fdata,
             "\n",
             NULL);
      Delete(fdata);
    }
    Printv(f_ftypes, " contains\n", NULL);

    // Initialize output strings that will be added by 'functionHandler'.
    d_method_overloads = NewHash();
  }

  assert(basic_struct == this->is_basic_struct());

  // Emit class members
  Language::classHandler(n);

  if (!basic_struct) {
    this->assignmentWrapper(n);

    // Write overloads
    for (Iterator kv = First(d_method_overloads); kv.key; kv = Next(kv)) {
      Printv(f_ftypes, "  generic :: ", kv.key, " => ", NULL);
      // Note: subtract 2 becaues this first line is an exception to
      // prepend_comma, added inside the iterator
      int line_length = 13 + Len(kv.key) + 4 - 2;

      // Write overloaded procedure names
      print_wrapped_list(f_ftypes, First(kv.item), line_length);
      Printv(f_ftypes, "\n", NULL);
    }
  }

  // Close out the type
  Printv(f_ftypes, " end type\n", NULL);

  Delete(d_method_overloads);
  d_method_overloads = NULL;

  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Extra stuff for constructors.
 */
int FORTRAN::constructorHandler(Node *n) {
  Node *classn = getCurrentClass();
  ASSERT_OR_PRINT_NODE(classn, n);

  // Get the constructor's name. This will usually be the unscoped C++ class
  // name: for std::vector<int> will be "vector", but the user can possibly
  // %rename a constructor as well, i.e.
  String *symname = Getattr(n, "sym:name");
  // The class's symbolic name (e.g. VecInt)
  String *classname = Getattr(classn, "sym:name");

  // Rename the proxy function to "create_$fclassname"
  String *constructor_name = NULL;
  if (Strcmp(symname, classname) != 0) {
    // The constructor has been %rename'd. Note that this may cause
    // problems if the class is templated and being instantiated more than
    // once: https://github.com/swig/swig/issues/844
    constructor_name = Copy(symname);
  } else {
    constructor_name = NewStringf("create_%s", classname);
  }
  Setattr(n, "fortran:name", constructor_name);
  Delete(constructor_name);

  // Override the result variable name
  Setattr(n, "wrap:fresult", "self");

  // NOTE: return type has not yet been assigned at this point
  return Language::constructorHandler(n);
}

/* -------------------------------------------------------------------------
 * \brief Handle extra destructor stuff.
 */
int FORTRAN::destructorHandler(Node *n) {
  Setattr(n, "fortran:name", "release");

  Node *classnode = getCurrentClass();

  // Handle ownership semantics by wrapping the destructor action
  String *fdis = this->attach_class_typemap("fdestructor", WARN_NONE);
  if (!fdis) {
    Swig_error(input_file, line_number,
               "Class '%s' has no '%s' typemap defined\n",
               SwigType_namestr(Getattr(classnode, "sym:name")), "fdestructor");
    return SWIG_NOWRAP;
  }
  Replaceall(fdis, "$input", "self");
  Setattr(n, "feature:shadow", fdis);

  SetFlag(n, "fortran:ismember");

  if (Getattr(classnode, "feature:final")) {
    // Create 'final' name wrapper
    String *classname = Getattr(classnode, "sym:name");
    String *fname = NewStringf("swigf_final_%s", classname);
    if (add_fsymbol(fname, n) != SWIG_NOWRAP) {
      // Add the 'final' subroutine to the methods
      Printv(f_ftypes, "  final :: ", fname, "\n", NULL);

      // Add the 'final' implementation
      Printv(f_fwrapper,
             "  subroutine ",
             fname,
             "(self)\n"
             "   use, intrinsic :: ISO_C_BINDING\n"
             "   type(",
             classname,
             ") :: self\n",
             fdis,
             "  end subroutine\n",
             NULL);
    }
    Delete(fname);
  }

  return Language::destructorHandler(n);
}

/* -------------------------------------------------------------------------
 * \brief Process member functions.
 */
int FORTRAN::memberfunctionHandler(Node *n) {
  if (is_basic_struct()) {
    String *class_symname = Getattr(getCurrentClass(), "sym:name");
    Swig_error(input_file, line_number,
               "Struct '%s' has the 'bindc' feature set, so it cannot have member functions\n",
               SwigType_namestr(class_symname));
    return SWIG_NOWRAP;
  }

  // If the function name starts with two underscores, modify it
  String *symname = Getattr(n, "sym:name");
  String *fsymname = Getattr(n, "fortran:name");

  if (!fsymname) {
    if (strncmp(Char(symname), "__", 2) == 0) {
      // For now, just delete the leading underscores
      fsymname = NewString(Char(symname) + 2);
    } else {
      // Preserve original member name
      fsymname = Copy(symname);
    }
    Setattr(n, "fortran:name", fsymname);
  } else {
    fsymname = Copy(fsymname);
  }

  String *class_symname = Getattr(getCurrentClass(), "sym:name");
  ASSERT_OR_PRINT_NODE(class_symname, n);

  // Create a private procedure name that gets bound to the Fortan TYPE
  String *fwrapname = NewStringf("swigf_%s_%s", class_symname, fsymname);
  Setattr(n, "fortran:fname", fwrapname);

  if (String *generic_name = Getattr(n, "feature:fortran:generic")) {
    List *overloads = this->get_method_overloads(generic_name);
    Append(overloads, fsymname);
  }

  // Set as a member variable unless it's a constructor
  if (!is_node_constructor(n)) {
    SetFlag(n, "fortran:ismember");
  }

  Delete(fwrapname);
  Delete(fsymname);

  Language::memberfunctionHandler(n);

  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Process member variables.
 */
int FORTRAN::membervariableHandler(Node *n) {
  if (is_basic_struct()) {
    // Write the type for the class member
    String *bindc_typestr = attach_typemap("bindc", n, WARN_TYPEMAP_UNDEF);
    String *symname = Getattr(n, "sym:name");
    SwigType *datatype = Getattr(n, "type");

    if (!bindc_typestr) {
      // In order for the struct's data to correspond to the C-aligned
      // data, an interface type MUST be specified!
      String *class_symname = Getattr(getCurrentClass(), "sym:name");
      Swig_error(input_file, line_number,
                 "Struct '%s' has the 'bindc' feature set, but member variable '%s' (type '%s') has no 'bindc' typemap defined\n",
                 SwigType_namestr(class_symname), symname, SwigType_namestr(datatype));
      return SWIG_NOWRAP;
    }
    this->replace_fclassname(datatype, bindc_typestr);

    Printv(f_ftypes, "  ", bindc_typestr, ", public :: ", symname, "\n", NULL);
  } else {
    // Create getter and/or setter functions, first preserving
    // the original member variable name
    String *fsymname = Copy(Getattr(n, "sym:name"));
    Setattr(n, "fortran:variable", fsymname);
    SetFlag(n, "fortran:ismember");
    Language::membervariableHandler(n);
    Delete(fsymname);
  }
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Process static member functions.
 */
int FORTRAN::globalvariableHandler(Node *n) {
  if (GetFlag(n, "feature:fortran:parameter")) {
    this->constantWrapper(n);
  } else {
    Language::globalvariableHandler(n);
  }
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Process static member functions.
 */
int FORTRAN::staticmemberfunctionHandler(Node *n) {
  // Preserve original function name
  Setattr(n, "fortran:name", Getattr(n, "sym:name"));

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

  String *enum_name = NULL;
  String *symname = Getattr(n, "sym:name");
  if (!symname) {
    // Anonymous enum TYPE:
    // enum {FOO=0, BAR=1};
  } else if (Strstr(symname, "$unnamed") != NULL) {
    // Anonymous enum VALUE
    // enum {FOO=0, BAR=1} foo;
  } else if (Node *classnode = getCurrentClass()) {
    // Scope the enum since it's in a class
    enum_name = NewStringf("%s_%s", Getattr(classnode, "sym:name"), symname);
    // Save the alias name
    Setattr(n, "fortran:name", enum_name);
  } else {
    enum_name = Copy(symname);
  }

  // Make sure the enum name isn't a duplicate
  if (enum_name && (add_fsymbol(enum_name, n) == SWIG_NOWRAP))
    return SWIG_NOWRAP;

  // Don't generate wrappers if we're in import mode, but make sure the symbol renaming above is still performed
  if (ImportMode)
    return SWIG_OK;

  // Determine whether to add enum as a native fortran enumeration. If false,
  // the values are all wrapped as constants.
  if (is_native_enum(n)) {
    // Create enumerator statement and initialize list of enum values
    d_enum_public = NewList();
    Printv(f_fparams, " enum, bind(c)\n", NULL);
  }

  if (enum_name) {
    // Print a placeholder enum value so we can use 'kind(ENUM)'
    Swig_save("enumDeclaration", n, "sym:name", "value", "type", NULL);

    // Type may not be set if this enum is actually a typedef
    if (!Getattr(n, "type")) {
      String *type = NewStringf("enum %s", enum_name);
      Setattr(n, "type", type);
      Delete(type);
    }

    // Create placeholder for the enumeration type
    Setattr(n, "sym:name", enum_name);
    Setattr(n, "value", "-1");
    constantWrapper(n);

    Swig_restore(n);
    Delete(enum_name);
  }

  // Emit enum items
  Language::enumDeclaration(n);

  if (d_enum_public) {
    // End enumeration
    Printv(f_fparams, " end enum\n", NULL);

    // Make the enum class *and* its values public
    Printv(f_fpublic, " public :: ", NULL);
    print_wrapped_list(f_fpublic, First(d_enum_public), 11);
    Putc('\n', f_fpublic);
    Delete(d_enum_public);
    d_enum_public = NULL;
  }

  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Process constants
 *
 * These include callbacks declared with

     %constant int (*ADD)(int,int) = add;

 * as well as values such as

     %constant int wrapped_const = (1 << 3) | 1;

 * that need to be interpreted by the C compiler.
 *
 * They're also called inside enumvalueDeclaration (either directly or through
 * memberconstantHandler)
 */
int FORTRAN::constantWrapper(Node *n) {
  String *nodetype = nodeType(n);
  String *symname = Getattr(n, "sym:name");
  String *value = Getattr(n, "rawval");

  if (Strcmp(nodetype, "enumitem") == 0) {
    // Make unique enum values for the user
    symname = this->make_unique_symname(n);

    // Set type from the parent enumeration
    String *t = Getattr(parentNode(n), "enumtype");
    Setattr(n, "type", t);

    if (d_enum_public) {
      // We are wrapping an enumeration in Fortran. Get the enum value OR
      // the automatically generated value (PREV + 1). Since the
      // name of PREV typically needs updating (since we just created a
      // unique symname), we update the next enum value if appropriate.
      if (!value) {
        value = Getattr(n, "enumvalue");
      }
      if (!value) {
        value = Getattr(n, "enumvalueex");
      }

      // This is the ONLY place where we can fix the next enum's automatic
      // value if this one has its name changed.
      Node *next = nextSibling(n);
      if (next && !Getattr(next, "enumvalue")) {
        String *updated_ex = NewStringf("%s + 1", symname);
        Setattr(next, "enumvalueex", updated_ex);
      }
    }
  } else if (Strcmp(nodetype, "enum") == 0) {
    // Symbolic name is already unique
  } else {
    // Not an enum or enumitem
    if (add_fsymbol(symname, n) == SWIG_NOWRAP)
      return SWIG_NOWRAP;
  }

  if (!value) {
    // For constants, the given value. For enums etc., the C++ identifier.
    value = Getattr(n, "value");
  }
  ASSERT_OR_PRINT_NODE(value, n);

  // Get Fortran data type
  String *bindc_typestr = attach_typemap("bindc", n, WARN_TYPEMAP_UNDEF);
  if (!bindc_typestr) {
    Swig_warning(WARN_TYPEMAP_UNDEF, Getfile(n), Getline(n),
                 "The 'bindc' typemap for '%s' is not defined, so the corresponding constant cannot be generated\n",
                 SwigType_str(Getattr(n, "type"), Getattr(n, "sym:name")));
    return SWIG_NOWRAP;
  }

  // Check for incompatible array dimensions
  if (bad_fortran_dims(n, "bindc")) {
    return SWIG_NOWRAP;
  }

  if (d_enum_public) {
    // We're wrapping a native enumerator: add to the list of enums being
    // built
    Append(d_enum_public, symname);
    // Print the enum to the list
    Printv(f_fparams, "  enumerator :: ", symname, " = ", value, "\n", NULL);
  } else if (is_native_parameter(n)) {
    // Search for the KIND embedded in `integer(C_DOUBLE)` so that we can
    // append the fortran specifier. This is kind of a hack, but native
    // parameters should really only be used for the kinds we define in
    // fortypemaps.swg
    const char *start = Char(bindc_typestr);
    const char *stop = start + Len(bindc_typestr);
    for (; start != stop; ++start) {
      if (*start == '(') {
        ++start;
        break;
      }
    }
    for (; stop != start; --stop) {
      if (*stop == ')') {
        break;
      }
    }

    if (stop != start) {
      // Append fortran type specifier; otherwise e.g. 1.000000001 will
      // be truncated to 1 because fortran will think it's a float
      String *suffix = NewStringWithSize(start, (int)(stop - start));
      Printv(value, "_", suffix, NULL);
      Delete(suffix);
    }

    Printv(f_fparams, " ", bindc_typestr, ", parameter, public :: ", symname, " = ", value, "\n", NULL);
  } else {
    /*! Add to public fortran code:
         *
         *   IMTYPE, protected, bind(C, name="swigc_SYMNAME") :: SYMNAME
         *
         * Add to wrapper code:
         *
         *   {const_CTYPE = SwigType_add_qualifier(CTYPE, "const")}
         *   {SwigType_str(const_CTYPE, swigc_SYMNAME) = VALUE;}
         */
    Swig_save("constantWrapper", n, "wrap:name", "lname", NULL);

    // SYMNAME -> swigc_SYMNAME
    String *wname = Swig_name_wrapper(symname);
    Setattr(n, "wrap:name", wname);

    // Set the value to replace $1 with in the 'out' typemap
    Setattr(n, "lname", value);

    // Get conversion to C type from native c++ type, *AFTER* changing
    // lname and wrap:name
    String *cwrap_code = attach_typemap("out", n, WARN_TYPEMAP_OUT_UNDEF);
    if (!cwrap_code)
      return SWIG_NOWRAP;

    if (Strstr(cwrap_code, "\n")) {
      // There's a newline in the output code, indicating it's
      // nontrivial.
      Swig_warning(WARN_LANG_NATIVE_UNIMPL, input_file, line_number,
                   "The 'out' typemap for '%s' is too complex to wrap as a %%constant variable. This will be implemented later\n",
                   symname);

      return SWIG_NOWRAP;
    }

    // Get type of C value
    Swig_typemap_lookup("ctype", n, symname, NULL);
    SwigType *c_return_type = parse_typemap("ctype", "out", n, WARN_FORTRAN_TYPEMAP_CTYPE_UNDEF);
    if (!c_return_type)
      return SWIG_NOWRAP;

    // Add a const to the return type
    SwigType_add_qualifier(c_return_type, "const");
    String *declstring = SwigType_str(c_return_type, wname);

    // Write SWIG code
    Replaceall(cwrap_code, "$result", declstring);
    Printv(f_wrapper, "SWIGEXPORT SWIGEXTERN ", cwrap_code, "\n\n", NULL);

    // Replace fclassname if needed
    this->replace_fclassname(c_return_type, bindc_typestr);

    // Add bound variable to interfaces
    Printv(f_fparams, " ", bindc_typestr, ", protected, public, &\n", "   bind(C, name=\"", wname, "\") :: ", symname, "\n", NULL);

    Swig_restore(n);
    Delete(declstring);
    Delete(wname);
  }

  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Handle a forward declaration of a class.
 *
 * This is necessary for the case:
 *
 *   struct A;
 *   void foo(A a);
 *
 * to allow 'a' to be correctly renamed.
 */
int FORTRAN::classforwardDeclaration(Node *n) {
  // Add symbolic name to the forward declaration symbol table
  String *symname = Getattr(n, "sym:name");
  if (symname) {
    String *lower = Swig_string_lower(symname);

    const char scope[] = "fortran_fwd";
    Node *existing = this->symbolLookup(lower, scope);
    if (!existing) {
      this->addSymbol(lower, n, scope);
    }
    Delete(lower);
  }

  return Language::classforwardDeclaration(n);
}

/* -------------------------------------------------------------------------
 * HELPER FUNCTIONS
 * ------------------------------------------------------------------------- */
/*!
 * \brief Attach and return a typemap belonging to the current class.
 *
 * This is used by things like `fdata`.
 */
String *FORTRAN::attach_class_typemap(const_String_or_char_ptr tmname, int warning) {
  assert(this->is_wrapping_class());
  String *class_type = this->getClassType();
  Node *class_node = this->getCurrentClass();

  String *temp_name = NewString("temp_class");
  Parm *temp = NewParm(class_type, temp_name, class_node);
  String *result = attach_typemap(tmname, temp, warning);
  Delete(temp_name);
  Delete(temp);

  if (result) {
    this->replace_fclassname(class_type, result);
  }

  return result;
}

/* -------------------------------------------------------------------------
 * \brief Substitute special '$fXXXXX' in typemaps.
 *
 * This is currently only used for '$fclassname'
 */
bool FORTRAN::replace_fclassname(SwigType *intype, String *tm) {
  assert(intype);
  bool substitution_performed = false;
  SwigType *basetype = SwigType_base(intype);

  if (Strstr(tm, "$fclassname")) {
    replace_fspecial_impl(basetype, tm, "$fclassname", false);
    substitution_performed = true;
  }
  if (Strstr(tm, "$fenumname")) {
    replace_fspecial_impl(basetype, tm, "$fenumname", true);
    substitution_performed = true;
  }

#if 0
    Printf(stdout, "replace %s (%c): %s => %s => '%s'\n",
           SwigType_isenum(basetype) ? "ENUM " : "CLASS",
           substitution_performed ? 'X' : ' ',
           intype,
           basetype,
           tm);
#endif

  Delete(basetype);

  return substitution_performed;
}

/* ------------------------------------------------------------------------- */

void FORTRAN::replace_fspecial_impl(SwigType *basetype, String *tm, const char *classnamespecialvariable, bool is_enum) {
  String *replacementname = NULL;
  String *alloc_string = NULL;
  Node *lookup = (is_enum ? enumLookup(basetype) : classLookup(basetype));

  if (lookup) {
    // Check first to see if there's a fortran symbolic name on the node
    replacementname = Getattr(lookup, "fortran:name");
    if (!replacementname) {
      // If not, use the symbolic name
      replacementname = Getattr(lookup, "sym:name");
    }
  }

  if (!replacementname) {
    // No class/enum type or symname was found
    if (!GetFlag(d_warned_fclassname, basetype)) {
      // First time encountered with this particular class
      Swig_warning(WARN_FORTRAN_TYPEMAP_FTYPE_UNDEF, input_file, line_number,
                   "No %s '$fclassname' replacement found for %s\n",
                   is_enum ? "enum" : "class",
                   SwigType_str(basetype, 0));
      SetFlag(d_warned_fclassname, basetype);
    }
    // Replace with a placeholder class
    alloc_string = NewString(is_enum ? "SwigUnknownEnum" : "SwigUnknownClass");
    // Emit the fragment that defines the class (forfragments.swg)
    String *fragment_string = NewStringf("%s_f", alloc_string);
    Swig_fragment_emit(fragment_string);
    Delete(fragment_string);

    // Return the replacement name
    replacementname = alloc_string;
  }
  Replaceall(tm, classnamespecialvariable, replacementname);
  Delete(alloc_string);
}

/* ------------------------------------------------------------------------- */

void FORTRAN::replaceSpecialVariables(String *method, String *tm, Parm *parm) {
  (void)method;
  SwigType *type = Getattr(parm, "type");
  this->replace_fclassname(type, tm);
}

/* -------------------------------------------------------------------------
 * \brief Add lowercase symbol since fortran is case insensitive
 *
 * Return SWIG_NOWRAP if the name conflicts.
 */
int FORTRAN::add_fsymbol(String *s, Node *n, int warn) {
  assert(s);
  const char scope[] = "fortran";
  String *lower = Swig_string_lower(s);
  Node *existing = this->symbolLookup(lower, scope);

  if (existing) {
    if (warn != WARN_NONE) {
      String *n1 = get_symname_or_name(n);
      String *n2 = get_symname_or_name(existing);
      Swig_warning(warn, input_file, line_number,
                   "Ignoring '%s' due to Fortran name ('%s') conflict with '%s'\n",
                   n1, lower, n2);
    }
    Delete(lower);
    return SWIG_NOWRAP;
  }

  int success = this->addSymbol(lower, n, scope);
  assert(success);
  Delete(lower);
  return SWIG_OK;
}

/* -------------------------------------------------------------------------
 * \brief Make a unique fortran symbol name by appending numbers.
 */
String *FORTRAN::make_unique_symname(Node *n) {
  String *symname = Getattr(n, "sym:name");

  // Since enum values are in the same namespace as everything else in the
  // module, make sure they're not duplicated with the scope
  Hash *symtab = this->symbolScopeLookup("fortran");
  Hash *fwdsymtab = this->symbolScopeLookup("fortran_fwd");

  // Lower-cased name for scope checking
  String *orig_lower = Swig_string_lower(symname);
  String *lower = orig_lower;

  int i = 0;
  while (Getattr(symtab, lower) || Getattr(fwdsymtab, lower)) {
    // Duplicate symbol!
    if (i != 0)
      Delete(lower);

    // Check with an extra number
    ++i;
    lower = NewStringf("%s%d", orig_lower, i);
  }
  if (i != 0) {
    // Warn that name has changed
    String *newname = NewStringf("%s%d", symname, i);
    Swig_warning(WARN_FORTRAN_NAME_CONFLICT, input_file, line_number,
                 "Renaming duplicate %s '%s' (Fortran name '%s')  to '%s'\n",
                 nodeType(n), symname, lower, newname);
    symname = newname;
    // Replace symname and decrement reference counter
    Setattr(n, "sym:name", newname);
    Delete(newname);
  }

  // Add lowercase name to symbol table
  Setattr(symtab, lower, n);
  Delete(lower);

  return symname;
}

/* -------------------------------------------------------------------------
 * Get the list of overloaded methods for the current 'generic' name.
 *
 * This only applies while a class is being wrapped to methods in that particular class.
 */
List *FORTRAN::get_method_overloads(String *generic) {
  assert(d_method_overloads);
  List *overloads = Getattr(d_method_overloads, generic);
  if (!overloads) {
    overloads = NewList();
    Setattr(d_method_overloads, generic, overloads);
  }
  return overloads;
}

/* -------------------------------------------------------------------------
 * Expose the code to the SWIG main function.
 * ------------------------------------------------------------------------- */

extern "C" Language *swig_fortran(void) {
  return new FORTRAN();
}
/* vim: set ts=2 sw=2 sts=2 tw=129 : */

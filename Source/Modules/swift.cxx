/* -----------------------------------------------------------------------------
 * swift.cxx
 *
 * Swift language module for SWIG.
 *
 * Generates:
 *   <module>_wrap.cxx  – extern "C" C++ wrappers (compiled into the shared lib)
 *   <module>_wrap.h    – C declarations (imported by Swift via a bridging header)
 *   <module>.swift     – Swift proxy classes, enums and module-level functions
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"
#include "cparse.h"
#include "swiftdoc.h"
#include <ctype.h>

/* Swift warning numbers (WARN_SWIFT_*) are allocated in swigwarn.h. */

/* -------------------------------------------------------------------------
 * Helper: lowercase the first character of a DOH String.
 * ------------------------------------------------------------------------- */
static String *lowercaseFirst(const String *s) {
  if (!s || Len(s) == 0)
    return NewString("");
  String *r = Copy(s);
  char *c = Char(r);
  *c = (char)tolower((unsigned char)*c);
  return r;
}

/* -------------------------------------------------------------------------
 * Helper: backtick-escape Swift keywords.
 * ------------------------------------------------------------------------- */
static String *swiftEscapeIdentifier(String *name) {
  static const char *keywords[] = {
    "associatedtype",  "class",    "deinit", "enum",        "extension", "func",  "import", "init",     "inout",  "let",      "operator",
    "precedencegroup", "protocol", "struct", "subscript",   "typealias", "var",   "break",  "case",     "catch",  "continue", "default",
    "defer",           "do",       "else",   "fallthrough", "for",       "guard", "if",     "in",       "repeat", "return",   "throw",
    "switch",          "where",    "while",  "Any",         "false",     "is",    "nil",    "rethrows", "self",   "Self",     "super",
    "throws",          "true",     "try",    NULL};
  if (!name || Len(name) == 0)
    return name;
  for (int i = 0; keywords[i]; i++) {
    if (Strcmp(name, keywords[i]) == 0) {
      String *escaped = NewStringf("`%s`", name);
      Delete(name);
      return escaped;
    }
  }
  return name;
}

/* -------------------------------------------------------------------------
 * Resolve the Swift proxy class name for a SWIG type.
 * Handles %template instantiations, shared_ptr<T> → T, and enums.
 * ------------------------------------------------------------------------- */
static String *swiftNestedName(Node *n) {
  String *cn = Getattr(n, "sym:name");
  if (!cn || Len(cn) == 0)
    return NewString("");
  Node *parent = Getattr(n, "parentNode");
  if (parent) {
    String *nt = Getattr(parent, "nodeType");
    if (nt && (Equal(nt, "class") || Equal(nt, "classforward"))) {
      /* Only go ONE level up (immediate parent only, no further recursion).
       * Nested enums named "Type" use underscore to avoid Swift metatype conflict. */
      String *pn = Getattr(parent, "sym:name");
      if (pn && Len(pn) > 0) {
        String *ntype = Getattr(n, "nodeType");
        if (ntype && Equal(ntype, "enum") && Equal(cn, "Type"))
          return NewStringf("%s_Type", pn);
        return NewStringf("%s.%s", pn, cn);
      }
    }
  }
  return Copy(cn);
}

static String *resolveSwiftClassName(SwigType *t) {
  Node *n = Language::classLookup(t);
  if (n) {
    String *cn = Getattr(n, "sym:name");
    if (cn && Len(cn) > 0 && Strncmp(cn, "__dummy_", 8) != 0)
      return swiftNestedName(n);
  }

  {
    SwigType *ty1 = SwigType_typedef_resolve_all(t);
    SwigType *ty2 = SwigType_strip_qualifiers(ty1);
    SwigType *base = SwigType_base(ty2);
    Replaceall(base, "class ", "");
    Replaceall(base, "struct ", "");
    Replaceall(base, "union ", "");
    Replaceall(base, "enum ", "");
    if (Strncmp(base, "::", 2) == 0) {
      String *old = base;
      base = NewString(Char(base) + 2);
      Delete(old);
    }
    Node *sn = Swig_symbol_clookup(base, 0);
    if (sn) {
      String *cn = Getattr(sn, "sym:name");
      if (cn && Len(cn) > 0 && Strncmp(cn, "__dummy_", 8) != 0) {
        String *result = swiftNestedName(sn);
        Delete(base);
        Delete(ty2);
        Delete(ty1);
        return result;
      }
    }
    Delete(base);
    Delete(ty2);
    Delete(ty1);
  }

  SwigType *base2 = SwigType_base(t);
  if (SwigType_istemplate(base2)) {
    String *targs = SwigType_templateargs(base2);
    if (targs) {
      List *plist = SwigType_parmlist(targs);
      Delete(targs);
      if (plist) {
        for (int i = 0; i < Len(plist); i++) {
          String *arg = Getitem(plist, i);
          String *cn = resolveSwiftClassName(arg);
          if (cn && !Equal(cn, "UnsafeMutableRawPointer?")) {
            Delete(plist);
            Delete(base2);
            return cn;
          }
          Delete(cn);
        }
        Delete(plist);
      }
    }
  }
  Delete(base2);
  return NewString("UnsafeMutableRawPointer?");
}

/* =========================================================================
 * class SWIFT
 * ========================================================================= */
class SWIFT : public Language {
  static const char *usage;

  /* ---- output files ---- */
  File *f_begin;        /* beginning of _wrap.cxx */
  File *f_runtime;      /* SWIG runtime code */
  File *f_header;       /* #include / extern declarations */
  File *f_wrappers;     /* generated C wrapper functions */
  File *f_init;         /* SWIG_init() function */
  List *filenames_list; /* for portability check */

  /* ---- accumulated string buffers ---- */
  String *swift_header_code;    /* C declarations for _wrap.h */
  String *swift_module_code;    /* module-level Swift code */
  String *swift_module_imports; /* import statements at top of .swift */
  String *upcasts_code;         /* C++ upcast helpers */

  /* ---- per-class state ---- */
  String *proxy_class_name;
  String *proxy_class_def;            /* "public class Foo : Base {\n" */
  String *proxy_class_code;           /* body of current Swift class */
  String *proxy_class_constants_code; /* nested enum / static let */
  String *destructor_call;            /* C call used in deinit */
  String *enum_code;                  /* current enum being built */
  String *vector_element_swifttype;   /* if this class is a std::vector, the Swift type its
                                         getElement(i:) returns; used to auto-emit a
                                         RandomAccessCollection conformance (NULL otherwise) */

  /* ---- flags ---- */
  bool static_flag;
  bool variable_wrapper_flag;
  bool current_class_has_base; /* set by classHandler: does the current proxy class have a wrapped base */
  bool doxygen;                /* -doxygen: translate C++ Doxygen comments to Swift markup */
  bool autorename;             /* -autorename: lower-case the first letter of method names so
                                  they follow Swift's lowerCamelCase convention */

  /* ---- doxygen ---- */
  DoxygenTranslator *doxygenTranslator;

  /* ---- options ---- */
  String *outfile_h;     /* override for C header filename */
  String *outfile_swift; /* override for .swift filename  */

  /* ---- director support ---- */
  bool director_flag;                  /* current class has director enabled */
  String *director_classname;          /* "SwigDirector_Foo" */
  String *director_symname;            /* "Foo" — set in classDirectorInit, before classHandler */
  String *director_cb_struct_name;     /* "SwigSwiftCallbacks_Foo" */
  String *director_cb_fields;          /* struct body: one fn-ptr field per method */
  String *director_cpp_methods;        /* C++ virtual override bodies */
  String *director_swift_dispatch_fns; /* module-level Swift @convention(c) dispatch fns */
  String *director_swift_open_methods; /* open func swig_* declarations */
  String *director_swift_init_cb;      /* cbs.swig_* = fn; lines in Swift init body */
  Hash *director_method_count;         /* base-name → seen-count, for overload dedup */
  Hash *class_generated_inits;         /* class sym:name → comma-list of arg counts actually emitted */
  Hash *class_static_methods;          /* class sym:name → pipe-delimited list of static method names */

  /* =========================================================================
   * Private helpers
   * ========================================================================= */

  /* Look up a Swift-specific typemap by name.
   * If `type` is non-null, creates a temporary lookup node with that type set
   * (needed for class-level lookups where `n` is a classdefn node, not a type node). */
  const String *typemapLookup(Node *n, const char *tmap, SwigType *type, int warning) {
    Node *lookup_node = n;
    if (type) {
      lookup_node = NewHash();
      Setattr(lookup_node, "type", type);
      Setattr(lookup_node, "sym:name", Getattr(n, "sym:name"));
    }
    String *tm = Swig_typemap_lookup(tmap, lookup_node, "", 0);
    if (type)
      Delete(lookup_node);
    if (!tm) {
      if (warning != WARN_NONE)
        Swig_warning(warning, Getfile(n), Getline(n), "No %s typemap defined for %s\n", tmap, SwigType_str(type, 0));
      return NewString("");
    }
    return tm;
  }

  /* Build the overloaded name for a function (appends _2, _3, … for overloads) */
  String *getOverloadedName(Node *n) {
    String *name = Copy(Getattr(n, "sym:name"));
    if (Getattr(n, "sym:overloaded")) {
      String *ovstr = Getattr(n, "sym:overname");
      assert(ovstr);
      if (ovstr)
        Append(name, ovstr);
    }
    return name;
  }

  /* Write a C declaration line into swift_header_code */
  void emitCDeclaration(const String *c_return_type, const String *wname, const String *params) {
    Printf(swift_header_code, "SWIGEXPORT %s %s(%s);\n", c_return_type, wname, params);
  }

  /* Convert a SWIG symbol name to a Swift method name, preserving casing and escaping keywords. */
  String *swiftMethodName(const String *sym) {
    String *name = Copy(sym);
    /* With -autorename, lower-case the leading capital so methods follow Swift's
     * lowerCamelCase convention (GetVersion -> getVersion, ToISO -> toISO).
     * Types and enum cases are emitted elsewhere and are left untouched. */
    if (autorename && Len(name) > 0) {
      const char *s = Char(name);
      if (s[0] >= 'A' && s[0] <= 'Z') {
        String *lowered = NewStringf("%c%s", (char)(s[0] - 'A' + 'a'), s + 1);
        /* Remember original -> renamed so the doxygen translator can rewrite
         * references to this function in documentation comments. */
        swiftRenamedSymbols[std::string(Char(sym))] = std::string(Char(lowered));
        Delete(name);
        name = lowered;
      }
    }
    return swiftEscapeIdentifier(name);
  }

  /* Pre-pass: record the -autorename mapping for every wrapped function up front so
   * documentation comments can resolve references to functions declared later in the
   * file. Only function cdecls are recorded (never classes/enums), so type names are
   * never mistaken for renamed functions. */
  void collectRenames(Node *n) {
    for (Node *c = firstChild(n); c; c = nextSibling(c)) {
      String *nt = Getattr(c, "nodeType");
      if (nt && Equal(nt, "cdecl")) {
        String *symname = Getattr(c, "sym:name");
        SwigType *decl = Getattr(c, "decl");
        if (symname && decl && SwigType_isfunction(decl) && !GetFlag(c, "feature:ignore"))
          Delete(swiftMethodName(symname)); /* side effect: populates swiftRenamedSymbols */
      }
      collectRenames(c);
    }
  }

  /* Emit the standard SWIG banner in the target language comment style */
  void emitBanner(File *f) {
    Printf(f, "/*\n");
    Swig_banner_target_lang(f, " *");
    Printf(f, " */\n");
  }

  /* The SWIG module name, or "" before top() has set current_module.
   * Used to expand the $module substitution in generated Swift code. */
  const char *moduleName() {
    String *name = current_module ? Getattr(current_module, "name") : NULL;
    return name ? Char(name) : "";
  }

  /* A self-referential member (e.g. a method returning the enclosing class) resolves to the
   * opaque bridge type "UnsafeMutableRawPointer?"; substitute the current proxy class name so
   * the Swift signature names the class.  Consumes and replaces the passed string. */
  String *selfClassNameIfOpaque(String *cn) {
    if (Equal(cn, "UnsafeMutableRawPointer?") && proxy_class_name && Len(proxy_class_name) > 0) {
      Delete(cn);
      return Copy(proxy_class_name);
    }
    return cn;
  }

  /* Current module node (set in top()) */
  Node *current_module;

  /* =========================================================================
   * Constructor / destructor
   * ========================================================================= */
public:
  SWIFT() :
    f_begin(NULL),
    f_runtime(NULL),
    f_header(NULL),
    f_wrappers(NULL),
    f_init(NULL),
    filenames_list(NULL),
    swift_header_code(NULL),
    swift_module_code(NULL),
    swift_module_imports(NULL),
    upcasts_code(NULL),
    proxy_class_name(NULL),
    proxy_class_def(NULL),
    proxy_class_code(NULL),
    proxy_class_constants_code(NULL),
    destructor_call(NULL),
    enum_code(NULL),
    static_flag(false),
    variable_wrapper_flag(false),
    current_class_has_base(false),
    doxygen(false),
    autorename(false),
    doxygenTranslator(NULL),
    outfile_h(NULL),
    outfile_swift(NULL),
    director_flag(false),
    director_classname(NULL),
    director_symname(NULL),
    director_cb_struct_name(NULL),
    director_cb_fields(NULL),
    director_cpp_methods(NULL),
    director_swift_dispatch_fns(NULL),
    director_swift_open_methods(NULL),
    director_swift_init_cb(NULL),
    director_method_count(NULL),
    class_generated_inits(NewHash()),
    class_static_methods(NewHash()),
    current_module(NULL) {
    directorLanguage();
    /* Swift directors use a separate factory function; the regular constructor
     * wrapper must always create the plain (non-director) class. */
    Delete(director_ctor_code);
    director_ctor_code = NewString("$nondirector_new");
  }

  ~SWIFT() {
    delete doxygenTranslator;
    Delete(class_generated_inits);
    Delete(class_static_methods);
  }

  /* =========================================================================
   * main() – command-line options
   * ========================================================================= */
  virtual void main(int argc, char *argv[]) {
    SWIG_library_directory("swift");
    Preprocessor_define("SWIGSWIFT 1", 0);
    SWIG_config_file("swift.swg");

    /* Command-line option parsing */
    int doxygen_translator_flags = 0;
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
        if (strcmp(argv[i], "-help") == 0) {
          Printf(stdout, "%s\n", usage);
        } else if (strcmp(argv[i], "-outfile") == 0) {
          if (argv[i + 1]) {
            Swig_mark_arg(i);
            outfile_swift = NewString(argv[++i]);
            Swig_mark_arg(i);
          } else {
            Swig_arg_error();
          }
        } else if (strcmp(argv[i], "-autorename") == 0) {
          Swig_mark_arg(i);
          autorename = true;
        } else if (strcmp(argv[i], "-doxygen") == 0) {
          Swig_mark_arg(i);
          doxygen = true;
          scan_doxygen_comments = true;
        } else if (strcmp(argv[i], "-debug-doxygen-translator") == 0) {
          Swig_mark_arg(i);
          doxygen_translator_flags |= DoxygenTranslator::debug_translator;
        } else if (strcmp(argv[i], "-debug-doxygen-parser") == 0) {
          Swig_mark_arg(i);
          doxygen_translator_flags |= DoxygenTranslator::debug_parser;
        }
      }
    }

    if (doxygen)
      doxygenTranslator = new SwiftDocConverter(doxygen_translator_flags);
    else if (doxygen_translator_flags)
      Printf(stderr, "swig: warning: -debug-doxygen-translator/-debug-doxygen-parser have no effect without -doxygen.\n");

    /* Allow standard SWIG options */
    allow_overloading();
    allow_directors();
  }

  /* =========================================================================
   * top() – entry point; sets up all output files and drives code generation
   * ========================================================================= */
  virtual int top(Node *n) {
    current_module = n;

    /* Populate the autorename map before generating, so doxygen doc comments can
     * resolve references to functions regardless of declaration order. */
    if (autorename)
      collectRenames(n);

    /* --- collect module name --- */
    String *module = Getattr(n, "name");

    /* --- output filenames --- */
    String *outfile = Getattr(n, "outfile"); /* e.g. enrollment_wrap.cxx */
    String *outfile_base = Swig_file_basename(outfile);

    String *h_filename;
    if (!outfile_h) {
      h_filename = NewStringf("%s.h", outfile_base);
    } else {
      h_filename = Copy(outfile_h);
    }

    String *swift_filename;
    if (!outfile_swift) {
      swift_filename = NewStringf("%s%s.swift", SWIG_output_directory(), module);
    } else {
      swift_filename = Copy(outfile_swift);
    }

    /* --- open C wrapper file --- */
    f_begin = NewFile(outfile, "w", SWIG_output_files());
    f_runtime = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_init = NewString("");

    if (!f_begin) {
      FileErrorDisplay(outfile);
      Exit(EXIT_FAILURE);
    }

    filenames_list = NewList();

    /* --- accumulated buffers --- */
    swift_header_code = NewString("");
    swift_module_code = NewString("");
    swift_module_imports = NewString("");
    upcasts_code = NewString("");
    vector_element_swifttype = NULL;

    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("init", f_init);

    /* classDirector() in lang.cxx always writes using_protected_members_code to
     * "director_h" regardless of language.  Register f_header for both handles so
     * that content lands somewhere harmless (the using-declarations are valid C++). */
    Swig_register_filebyname("director", f_header);
    Swig_register_filebyname("director_h", f_header);

    /* --- Inject the SWIG runtime into the C output --- */
    Swig_banner(f_begin);
    Swig_obligatory_macros(f_runtime, "SWIFT");
    if (CPlusPlus)
      Printf(f_runtime, "\n#define SWIGCPP\n");
    Printf(f_runtime, "#define SWIGSWIFT\n\n");
    /* Director runtime: provides Swig::Director and Swig::DirectorPureVirtualException.
     * lang.cxx emits upcall-detection code for director-enabled classes regardless of
     * language; including this header makes that code compile.  Our director classes
     * do NOT inherit Swig::Director, so dynamic_cast<Swig::Director*> always returns
     * nullptr and the upcall branch is never taken — the code is harmless dead code. */
    if (Swig_directors_enabled())
      Swig_insert_file("swift/director.swg", f_runtime);

    /* --- Open C header file and emit declarations --- */
    Printf(swift_header_code, "/* Auto-generated by SWIG – do not edit. */\n");
    Printf(swift_header_code, "#pragma once\n");
    Printf(swift_header_code, "#ifdef __cplusplus\nextern \"C\" {\n#endif\n\n");
    Printf(swift_header_code, "#include <stdint.h>\n");
    Printf(swift_header_code, "#include <stddef.h>\n\n");
    Printf(swift_header_code, "#ifndef SWIGEXPORT\n#  define SWIGEXPORT\n#endif\n\n");
    /* Exception API always declared */
    Printf(swift_header_code, "void SWIG_Swift_SetPendingException(const char *msg);\n");
    Printf(swift_header_code, "const char *swig_swift_get_pending_exception(void);\n");
    Printf(swift_header_code, "void swig_swift_clear_pending_exception(void);\n");
    /* Typed exception API for language bindings */
    Printf(swift_header_code, "const char *swig_swift_get_typed_exception_type(void);\n");
    Printf(swift_header_code, "void *swig_swift_steal_typed_exception_ptr(void);\n");
    Printf(swift_header_code, "void swig_swift_release_typed_exception(void *p);\n");
    /* Director string return buffer helper */
    Printf(swift_header_code, "const char *swig_swift_director_store_string(const char *s);\n\n");

    /* --- Open Swift file --- */
    File *f_swift = NewFile(swift_filename, "w", SWIG_output_files());
    if (!f_swift) {
      FileErrorDisplay(swift_filename);
      Exit(EXIT_FAILURE);
    }
    Append(filenames_list, Copy(swift_filename));

    emitBanner(f_swift);
    Printf(f_swift, "// Swift proxy module: %s\n\n", module);

    /* --- collect %pragma(swift) module* --- */
    /* (will be written after Language::top) */

    /* Director canthrow: forward-declare the exception query functions so the
     * director class bodies (emitted into f_header) can call them.  The actual
     * definitions live in the %insert(runtime) block in swift.swg which is
     * dumped into f_runtime before f_header, but C++ still requires a
     * declaration in scope at the call site. */
    if (Swig_directors_enabled()) {
      Printf(f_header,
             "extern \"C\" const char *swig_swift_get_pending_exception(void);\n"
             "extern \"C\" void swig_swift_clear_pending_exception(void);\n\n");
    }

    /* --- drive code generation --- */
    Printf(f_wrappers, "\n#ifdef __cplusplus\nextern \"C\" {\n#endif\n\n");

    Language::top(n);

    Printf(f_wrappers, "\n#ifdef __cplusplus\n}\n#endif\n");

    /* upcasts */
    if (Len(upcasts_code))
      Printv(f_wrappers, upcasts_code, NIL);

    /* --- emit module-level Swift code (module imports + helper + global fns) --- */
    if (Len(swift_module_imports))
      Printv(f_swift, swift_module_imports, "\n", NIL);
    if (Len(swift_module_code))
      Printv(f_swift, swift_module_code, "\n", NIL);

    /* --- close C header file --- */
    Printf(swift_header_code, "\n#ifdef __cplusplus\n}\n#endif\n");
    {
      File *f_h = NewFile(h_filename, "w", SWIG_output_files());
      if (!f_h) {
        FileErrorDisplay(h_filename);
        Exit(EXIT_FAILURE);
      }
      Append(filenames_list, Copy(h_filename));
      emitBanner(f_h);
      Printv(f_h, swift_header_code, NIL);
      Delete(f_h);
    }

    Delete(f_swift);
    Delete(h_filename);
    Delete(swift_filename);
    Delete(outfile_base);

    /* --- merge C/C++ buffers into the wrap file --- */
    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    Dump(f_wrappers, f_begin);
    Wrapper_pretty_print(f_init, f_begin);

    Delete(f_runtime);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Delete(f_begin);

    /* --- cleanup --- */
    Delete(swift_header_code);
    swift_header_code = NULL;
    Delete(swift_module_code);
    swift_module_code = NULL;
    Delete(swift_module_imports);
    swift_module_imports = NULL;
    Delete(upcasts_code);
    upcasts_code = NULL;
    Delete(filenames_list);
    filenames_list = NULL;

    return SWIG_OK;
  }

  /* =========================================================================
   * pragmaDirective() – handle %pragma(swift) …
   * ========================================================================= */
  virtual int pragmaDirective(Node *n) {
    if (!ImportMode) {
      String *lang = Getattr(n, "lang");
      String *code = Getattr(n, "name");
      String *value = Getattr(n, "value");

      if (Strcmp(lang, "swift") == 0) {
        String *strvalue = NewString(value);
        Replaceall(strvalue, "\\\"", "\"");
        // $module -> the SWIG module name, so module-level Swift code (modulecode /
        // moduleimports) can reference it the same way typemaps do.
        // current_module is set in top() before this runs.
        if (current_module)
          Replaceall(strvalue, "$module", moduleName());

        if (Strcmp(code, "moduleimports") == 0) {
          Printv(swift_module_imports, strvalue, "\n", NIL);
        } else if (Strcmp(code, "modulecode") == 0) {
          Printv(swift_module_code, strvalue, "\n", NIL);
        } else {
          Swig_error(input_file, line_number, "Unrecognized Swift pragma.\n");
        }
        Delete(strvalue);
      }
    }
    return Language::pragmaDirective(n);
  }

  /* =========================================================================
   * functionWrapper() – generates the extern "C" C wrapper for one function.
   * ========================================================================= */
  virtual int functionWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    SwigType *returntype = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *tm;
    Parm *p;
    int i;
    String *c_return_type = NewString("");
    String *cleanup = NewString("");
    String *outarg = NewString("");
    int num_arguments = 0;
    bool is_void_return;

    String *overloaded_name = getOverloadedName(n);

    if (!Getattr(n, "sym:overloaded")) {
      if (!addSymbol(symname, n))
        return SWIG_ERROR;
    }

    /* Create a new C wrapper function */
    Wrapper *f = NewWrapper();

    /* Wrapper function name */
    String *wname = Swig_name_wrapper(overloaded_name);
    Setattr(n, "wrap:name", wname);

    /* Attach typemaps to param list – ctype/imtype for C wrapper, swifttype/swiftin for Swift proxy */
    Swig_typemap_attach_parms("ctype", l, f);
    Swig_typemap_attach_parms("imtype", l, NULL);
    Swig_typemap_attach_parms("swifttype", l, NULL);
    Swig_typemap_attach_parms("swiftin", l, NULL);

    /* Get C return type from "ctype" typemap */
    if ((tm = Swig_typemap_lookup("ctype", n, "", 0))) {
      String *ctypeout = Getattr(n, "tmap:ctype:out");
      if (ctypeout)
        tm = ctypeout;
      Printv(c_return_type, tm, NIL);
    } else {
      Swig_warning(WARN_SWIFT_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(returntype, 0));
      Printv(c_return_type, "void *", NIL);
    }

    is_void_return = (Cmp(c_return_type, "void") == 0);
    if (!is_void_return)
      Wrapper_add_localv(f, "jresult", c_return_type, "jresult = 0", NIL);

    /* C function header */
    Printv(f->def, "SWIGEXPORT ", c_return_type, " ", wname, "(", NIL);

    /* Parameter variables */
    emit_parameter_variables(l, f);
    emit_attach_parmmaps(l, f);

    Setattr(n, "wrap:parms", l);

    /* Overloading check */
    if (Getattr(n, "sym:overloaded")) {
      Swig_overload_check(n);
      if (Getattr(n, "overload:ignore")) {
        DelWrapper(f);
        Delete(c_return_type);
        Delete(cleanup);
        Delete(outarg);
        Delete(overloaded_name);
        return SWIG_OK;
      }
    }

    /* Build the C parameter declaration header and header-file declaration */
    String *c_param_decl = NewString(""); /* for the header file */
    num_arguments = emit_num_arguments(l);
    int gencomma = 0;

    for (i = 0, p = l; i < num_arguments; i++) {
      while (checkAttribute(p, "tmap:in:numinputs", "0"))
        p = Getattr(p, "tmap:in:next");

      SwigType *pt = Getattr(p, "type");
      String *ln = Getattr(p, "lname");
      String *c_param_type = NewString("");
      String *arg = NewString("");

      Printf(arg, "j%s", ln);

      if ((tm = Getattr(p, "tmap:ctype"))) {
        Printv(c_param_type, tm, NIL);
      } else {
        Swig_warning(WARN_SWIFT_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap for %s\n", SwigType_str(pt, 0));
        Printv(c_param_type, "void *", NIL);
      }

      if (gencomma) {
        Printf(f->def, ", ");
        Printf(c_param_decl, ", ");
      }
      Printf(f->def, "%s %s", c_param_type, arg);
      Printf(c_param_decl, "%s", c_param_type);
      gencomma = 1;

      /* Emit the "in" typemap – converts C arg to C++ type */
      if ((tm = Getattr(p, "tmap:in"))) {
        Replaceall(tm, "$input", arg);
        Setattr(p, "emit:input", arg);
        Printf(f->code, "%s\n", tm);
        p = Getattr(p, "tmap:in:next");
      } else {
        Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
        p = nextSibling(p);
      }

      Delete(c_param_type);
      Delete(arg);
    }

    /* Closing paren of C function def */
    Printf(f->def, ") {");

    /* Emit the C header declaration */
    emitCDeclaration(c_return_type, wname, c_param_decl);
    Delete(c_param_decl);

    /* check/freearg/argout typemaps */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:check"))) {
        Replaceall(tm, "$input", Getattr(p, "emit:input"));
        Printv(f->code, tm, "\n", NIL);
        p = Getattr(p, "tmap:check:next");
      } else {
        p = nextSibling(p);
      }
    }
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:freearg"))) {
        Replaceall(tm, "$input", Getattr(p, "emit:input"));
        Printv(cleanup, tm, "\n", NIL);
        p = Getattr(p, "tmap:freearg:next");
      } else {
        p = nextSibling(p);
      }
    }
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:argout"))) {
        Replaceall(tm, "$result", "jresult");
        Replaceall(tm, "$input", Getattr(p, "emit:input"));
        Printv(outarg, tm, "\n", NIL);
        p = Getattr(p, "tmap:argout:next");
      } else {
        p = nextSibling(p);
      }
    }

    /* Emit the C++ call via SWIG's emit_action */
    String *actioncode = emit_action(n);
    /* lang.cxx wraps director-enabled calls in "if (upcall) { ... } else { ... }"
     * where the true-branch calls the method NON-virtually (ClassName::method())
     * and the false-branch calls it virtually (method()).  Our directors do not
     * inherit Swig::Director so dynamic_cast upcall detection always returns false.
     *
     * For director classes we ALWAYS want the non-virtual call: the Swift proxy
     * method calls the C++ base implementation directly, while C++ virtual dispatch
     * (triggered externally) goes through the director callbacks.  Using the virtual
     * call would cause infinite recursion when the user calls proxy.method() from
     * Swift (proxy → C wrapper → virtual → director → Swift dispatch → proxy → ...).
     *
     * For non-director classes the upcall branch is dead code — keep if(false) so
     * the compiler elides it cleanly. */
    Replaceall(actioncode, "if (upcall)", director_flag ? "if (true)" : "if (false)");
    /* lang.cxx replaces arg1 with darg (a director-cast pointer) in the else
     * branch for protected virtual methods — darg is the director subclass
     * pointer, which has public access to the overriding method.  Prepend the
     * declaration to the action code (not to locals) so it comes AFTER the
     * "in" typemaps that initialise arg1.
     * Note: director_classname is only valid inside classDirectorInit..End,
     * which runs AFTER functionWrapper; use proxy_class_name instead. */
    if (Strstr(actioncode, "(darg)->") && director_flag && proxy_class_name) {
      String *darg_init = NewStringf("  SwigDirector_%s *darg = (SwigDirector_%s *)arg1;\n", proxy_class_name, proxy_class_name);
      Insert(actioncode, 0, darg_init);
      Delete(darg_init);
    }

    /* Handle return value */
    if ((tm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), f, actioncode))) {
      Replaceall(tm, "$result", "jresult");
      if (GetFlag(n, "feature:new"))
        Replaceall(tm, "$owner", "1");
      else
        Replaceall(tm, "$owner", "0");
      Printf(f->code, "%s", tm);
      if (Len(tm))
        Printf(f->code, "\n");
    } else {
      Swig_warning(
        WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(returntype, 0), Getattr(n, "name"));
    }
    emit_return_variable(n, returntype, f);

    Printv(f->code, outarg, NIL);
    Printv(f->code, cleanup, NIL);

    if (!is_void_return)
      Printf(f->code, "  return jresult;\n");
    Printf(f->code, "}\n");

    Replaceall(f->code, "$cleanup", cleanup);
    Replaceall(f->code, "$isvoid", is_void_return ? "1" : "0");
    Replaceall(f->code, "$null", is_void_return ? "" : "0");

    Wrapper_print(f, f_wrappers);

    /* For global (non-class) functions, emit a Swift proxy at module level */
    if (!is_wrapping_class()) {
      emitSwiftProxyMethod(n, swift_module_code, false);
    } else if (variable_wrapper_flag && proxy_class_code) {
      /* Member variable: emit only GetFoo() getter; skip setter. */
      String *orig_varname = Getattr(n, "membervariableHandler:sym:name");
      if (orig_varname && Len(orig_varname) > 0) {
        String *cur_sym = Getattr(n, "sym:name");
        bool is_getter = (Len(cur_sym) > 4 && strcmp(Char(cur_sym) + Len(cur_sym) - 4, "_get") == 0);
        if (is_getter) {
          String *cap = Copy(orig_varname);
          char *c = Char(cap);
          *c = (char)toupper((unsigned char)*c);
          String *swift_method_name = NewStringf("Get%s", cap);
          String *saved = Copy(cur_sym);
          Setattr(n, "sym:name", swift_method_name);
          emitSwiftProxyMethod(n, proxy_class_code, false);
          Setattr(n, "sym:name", saved);
          Delete(saved);
          Delete(swift_method_name);
          Delete(cap);
        }
      }
    }

    DelWrapper(f);
    Delete(c_return_type);
    Delete(cleanup);
    Delete(outarg);
    Delete(overloaded_name);

    return SWIG_OK;
  }

  /* =========================================================================
   * Helper: if -doxygen is enabled and the node carries a Doxygen comment,
   * translate it to a Swift documentation comment and write it (indented to
   * match the following declaration) into dst_code, immediately before it.
   * ========================================================================= */
  void emitDoxygenComment(Node *n, String *dst_code, const_String_or_char_ptr indent, bool nextLeadsNewline = true) {
    if (!doxygen || !doxygenTranslator->hasDocumentation(n))
      return;
    String *comment = doxygenTranslator->getDocumentation(n, indent);
    Chop(comment);  // normalise: strip the trailing newline/spaces so we control spacing
    Printv(dst_code, "\n", comment, NIL);
    if (!nextLeadsNewline)
      Printv(dst_code, "\n", NIL);  // the following declaration is not emitted with a leading newline
    Delete(comment);
  }

  /* =========================================================================
   * Helper: build the Swift proxy method body for a wrapped function.
   *
   * Writes into dst_code the full Swift method (signature + body).
   * ========================================================================= */
  void emitSwiftProxyMethod(Node *n, String *dst_code, bool is_static) {
    String *symname = Getattr(n, "sym:name");
    SwigType *rettype = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *wname = Getattr(n, "wrap:name");
    String *tm;
    Parm *p;
    int i;

    if (!wname)
      return; /* shouldn't happen */

    /* Swift method name: lowercase first char */
    String *swift_name = swiftMethodName(symname);

    /* -- determine return type in Swift -- */
    String *swift_return_type = NewString("");
    if ((tm = Swig_typemap_lookup("swifttype", n, "", 0))) {
      String *out_attr = Getattr(n, "tmap:swifttype:out");
      if (out_attr)
        tm = out_attr;
      Printv(swift_return_type, tm, NIL);
    } else {
      Swig_warning(WARN_SWIFT_TYPEMAP_SWIFTTYPE_UNDEF, input_file, line_number, "No swifttype typemap for %s\n", SwigType_str(rettype, 0));
      Printv(swift_return_type, "/* UNKNOWN */", NIL);
    }

    {
      String *ret_cn = resolveSwiftClassName(rettype);
      ret_cn = selfClassNameIfOpaque(ret_cn);
      Replaceall(swift_return_type, "$swiftclassname", ret_cn);
      Replaceall(swift_return_type, "$module", moduleName());
      Delete(ret_cn);
    }
    bool is_void = (Len(swift_return_type) == 0 || Cmp(swift_return_type, "Void") == 0);

    /* -- look up swiftout typemap -- */
    String *swiftout = Swig_typemap_lookup("swiftout", n, "", 0);
    if (!swiftout) {
      Swig_warning(WARN_SWIFT_TYPEMAP_SWIFTOUT_UNDEF, input_file, line_number, "No swiftout typemap for %s\n", SwigType_str(rettype, 0));
      swiftout = NewString("$imcall\n    try swigCheckException()\n");
    }

    /* -- build Swift parameter list and the C call argument list -- */
    String *swift_params = NewString("");
    String *c_args = NewString("");

    /* For non-static member functions, first C arg is swigCPtr */
    if (is_wrapping_class() && !static_flag) {
      Printf(c_args, "swigCPtr");
    }

    /* Re-attach typemaps to the restored original parms.
     * Language::memberfunctionHandler calls Swig_MethodToFunction which uses
     * CopyParmList, so functionWrapper attaches typemaps to copies. After
     * Swig_restore the originals have no tmap:* attributes set. */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("swifttype", l, NULL);
    Swig_typemap_attach_parms("swiftin", l, NULL);
    int num_args = emit_num_arguments(l);
    int gencomma = is_wrapping_class() && !static_flag ? 1 : 0;
    int swift_comma = 0;

    /* For member variable wrappers, the first parm is the implicit self —
     * already captured by swigCPtr; skip it in the Swift param list. */
    int i_start = 0;
    Parm *p_start = l;
    if (variable_wrapper_flag && is_wrapping_class() && !static_flag && num_args > 0) {
      while (p_start && checkAttribute(p_start, "tmap:in:numinputs", "0"))
        p_start = Getattr(p_start, "tmap:in:next");
      if (p_start) {
        p_start = Getattr(p_start, "tmap:in:next") ? Getattr(p_start, "tmap:in:next") : nextSibling(p_start);
        i_start = 1;
      }
    }

    /* Walk parameters, skipping those consumed by "numinputs=0" typemaps */
    for (i = i_start, p = p_start; i < num_args; i++) {
      while (checkAttribute(p, "tmap:in:numinputs", "0"))
        p = Getattr(p, "tmap:in:next");

      SwigType *pt = Getattr(p, "type");
      /* original C++ parameter name (may be empty) */
      String *pname = Getattr(p, "name");
      String *lname = Getattr(p, "lname"); /* local name: argN or the param name */

      /* Use C++ param name if available, otherwise argN fallback */
      String *swift_arg_name;
      if (pname && Len(pname) > 0)
        swift_arg_name = Copy(pname);
      else if (lname && Len(lname) > 0)
        swift_arg_name = Copy(lname);
      else
        swift_arg_name = NewStringf("arg%d", i + 1);
      swift_arg_name = swiftEscapeIdentifier(swift_arg_name);

      /* Swift parameter type */
      String *swift_param_type = NewString("");
      if ((tm = Getattr(p, "tmap:swifttype"))) {
        Printv(swift_param_type, tm, NIL);
        String *pcn = paramSwiftClassName(p);
        pcn = selfClassNameIfOpaque(pcn);
        Replaceall(swift_param_type, "$swiftclassname", pcn);
        Replaceall(swift_param_type, "$module", moduleName());
        Delete(pcn);
      } else {
        Swig_warning(WARN_SWIFT_TYPEMAP_SWIFTTYPE_UNDEF, input_file, line_number, "No swifttype for %s\n", SwigType_str(pt, 0));
        Printv(swift_param_type, "/* UNKNOWN */", NIL);
      }

      /* swiftin typemap – how to convert the Swift arg to a C arg */
      String *swiftin_tm = NewString("");
      if ((tm = Getattr(p, "tmap:swiftin"))) {
        Printv(swiftin_tm, tm, NIL);
        Replaceall(swiftin_tm, "$swiftinput", swift_arg_name);
        String *pcn = paramSwiftClassName(p);
        pcn = selfClassNameIfOpaque(pcn);
        Replaceall(swiftin_tm, "$swiftclassname", pcn);
        Replaceall(swiftin_tm, "$module", moduleName());
        Delete(pcn);
      } else {
        Swig_warning(WARN_SWIFT_TYPEMAP_SWIFTIN_UNDEF, input_file, line_number, "No swiftin for %s\n", SwigType_str(pt, 0));
        Printv(swiftin_tm, swift_arg_name, NIL);
      }

      /* Add to Swift param list */
      if (swift_comma)
        Printf(swift_params, ", ");
      Printf(swift_params, "%s: %s", swift_arg_name, swift_param_type);
      swift_comma = 1;

      /* Add to C call arg list */
      if (gencomma)
        Printf(c_args, ", ");
      Printf(c_args, "%s", swiftin_tm);
      gencomma = 1;

      p = Getattr(p, "tmap:in:next") ? Getattr(p, "tmap:in:next") : nextSibling(p);
      Delete(swift_arg_name);
      Delete(swift_param_type);
      Delete(swiftin_tm);
    }

    /* Build $imcall: the actual C function call */
    String *imcall = NewStringf("%s(%s)", wname, c_args);

    /* Build the swiftout body, substituting $imcall and class name */
    String *body = Copy(swiftout);
    Replaceall(body, "$imcall", imcall);
    /* Detect value-type member getter: SWIGTYPE* typemap has $owner marker; shared_ptr
     * typemaps hardcode 'true'. Check before replacing so we can distinguish the cases.
     * Only class members (is_wrapping_class) can be value-type getters; global vars stay optional. */
    bool is_value_type_getter = variable_wrapper_flag && is_wrapping_class() && !is_static && !is_void && (Strstr(body, "$owner") != NULL);
    /* Shared_ptr typemaps hardcode 'true' for ownership; replace with $owner first */
    Replaceall(body, ", true)", ", $owner)");
    Replaceall(body, "$owner", GetFlag(n, "feature:new") ? "true" : "false");
    {
      String *ret_cn = resolveSwiftClassName(rettype);
      ret_cn = selfClassNameIfOpaque(ret_cn);
      Replaceall(body, "$swiftclassname", ret_cn);
      Replaceall(body, "$module", moduleName());
      Delete(ret_cn);
    }

    /* Value-type member getters always return the address of a struct member — never null.
     * Convert the guard-let optional pattern to force-unwrap and strip '?' from return type. */
    if (is_value_type_getter) {
      if (Strstr(body, "guard let ptr = jresult else { return nil }")) {
        if (Len(swift_return_type) > 0 && Char(swift_return_type)[Len(swift_return_type) - 1] == '?')
          Delitem(swift_return_type, DOH_END);
        Replaceall(body, "guard let ptr = jresult else { return nil }\n    return ", "return ");
        Replaceall(body, "(ptr, ", "(jresult!, ");
      }
    }

    /* swift:nonnull feature: the C++ contract guarantees a valid pointer or a thrown
     * exception, so drop the optional return type and throw a standard NSError if the
     * pointer is unexpectedly null. Opt-in per method via %feature("swift:nonnull").
     * No effect on non-pointer returns (the guard-let pattern is absent). */
    if (!is_value_type_getter && GetFlag(n, "feature:swift:nonnull") && Strstr(body, "guard let ptr = jresult else { return nil }")) {
      if (Len(swift_return_type) > 0 && Char(swift_return_type)[Len(swift_return_type) - 1] == '?')
        Delitem(swift_return_type, DOH_END);
      String *mod = Getattr(current_module, "name");
      String *guard =
        NewStringf("guard let ptr = jresult else {\n"
                   "        throw NSError(domain: \"%s\", code: 1, userInfo: [NSLocalizedDescriptionKey: \"%s%s%s unexpectedly returned a null pointer\"])\n"
                   "    }",
                   mod ? Char(mod) : "",
                   (proxy_class_name && Len(proxy_class_name) > 0) ? Char(proxy_class_name) : "",
                   (proxy_class_name && Len(proxy_class_name) > 0) ? "." : "",
                   Char(symname));
      Replaceall(body, "guard let ptr = jresult else { return nil }", guard);
      Delete(guard);
    }

    /* Emit the Swift method.
     * Typemap bodies already carry 4-space indentation.
     * Class methods need 4 more spaces (total 8); top-level get no extra indent. */
    bool in_class = is_wrapping_class();
    const char *outer_indent = in_class ? "    " : "";
    const char *body_indent = in_class ? "    " : "";
    const char *close_indent = in_class ? "    " : "";

    bool is_override = (Getattr(n, "override") != NULL);
    /* Static class methods that shadow a base class method need 'override class func'.
     * staticmemberfunctionHandler sets "swift:static_override" when the ancestor
     * class_static_methods hash contains the same method name. */
    if (!is_override && is_static)
      is_override = (Getattr(n, "swift:static_override") != NULL);
    /* Validate that the Swift parameter labels actually match the overridden method.
     * If C++ param names differ (e.g. base uses "composer" but derived uses no name → "arg1"),
     * the Swift signatures are different, so "override" must not be used. */
    if (is_override && !is_static) {
      Node *base_node = Getattr(n, "override");
      if (base_node) {
        ParmList *base_parms = Getattr(base_node, "parms");
        /* Walk both lists comparing param names; stop at the first mismatch */
        Parm *cp = l;
        Parm *bp = base_parms;
        bool mismatch = false;
        while (cp || bp) {
          /* skip hidden current params */
          while (cp && checkAttribute(cp, "tmap:in:numinputs", "0"))
            cp = Getattr(cp, "tmap:in:next");
          /* skip SWIG-hidden base params (no typemaps; use 'hidden' attribute if any) */
          if (!cp && !bp)
            break;
          if (!cp || !bp) {
            mismatch = true;
            break;
          }
          String *cn = Getattr(cp, "name");
          String *cl = Getattr(cp, "lname");
          String *bn = Getattr(bp, "name");
          String *bl = Getattr(bp, "lname");
          const char *cur_label = (cn && Len(cn)) ? Char(cn) : (cl && Len(cl)) ? Char(cl) : "arg";
          const char *base_label = (bn && Len(bn)) ? Char(bn) : (bl && Len(bl)) ? Char(bl) : "arg";
          if (strcmp(cur_label, base_label) != 0) {
            mismatch = true;
            break;
          }
          cp = Getattr(cp, "tmap:in:next") ? Getattr(cp, "tmap:in:next") : nextSibling(cp);
          bp = nextSibling(bp);
        }
        if (mismatch)
          is_override = false;
      }
    }
    /* Access modifier defaults to public, but can be overridden per method with
     * %feature("swiftmethodmodifiers") (e.g. "internal", "private", "fileprivate"),
     * analogous to %csmethodmodifiers / %javamethodmodifiers. The "override" and
     * "class" (static) qualifiers are structural and always preserved. */
    const char *access = "public";
    String *mods_feature = Getattr(n, "feature:swiftmethodmodifiers");
    if (mods_feature && Len(mods_feature) > 0)
      access = Char(mods_feature);
    String *method_mods = NewString(outer_indent);
    if (is_static && is_override)
      Printf(method_mods, "override %s class", access);
    else if (is_static)
      Printf(method_mods, "%s class", access);
    else if (is_override)
      Printf(method_mods, "override %s", access);
    else
      Append(method_mods, access);

    emitDoxygenComment(n, dst_code, in_class ? "    " : 0);
    if (is_void) {
      Printf(dst_code, "\n%s func %s(%s) throws {\n", method_mods, swift_name, swift_params);
    } else {
      Printf(dst_code, "\n%s func %s(%s) throws -> %s {\n", method_mods, swift_name, swift_params, swift_return_type);
    }
    /* Indent body lines.
     * Typemap bodies start with \n (from the %{...%} opening line); skip it. */
    const char *raw_body = Char(body);
    if (raw_body && *raw_body == '\n')
      raw_body++;
    String *indented = NewString(raw_body);
    Replaceall(indented, "\n", NewStringf("\n%s", body_indent));
    Chop(indented);
    Printf(dst_code, "%s%s\n%s}\n", body_indent, indented, close_indent);
    Delete(method_mods);

    /* If this is std_vector.i's getElement(i:) accessor, remember the exact Swift type
     * it returns. classHandler uses it to auto-emit a RandomAccessCollection conformance
     * whose subscript return type matches getElement by construction. */
    if (!is_void && is_wrapping_class() && Equal(symname, "getElement") && !vector_element_swifttype) {
      vector_element_swifttype = Copy(swift_return_type);
    }

    Delete(swift_name);
    Delete(swift_return_type);
    Delete(swift_params);
    Delete(c_args);
    Delete(imcall);
    Delete(body);
    Delete(indented);
  }

  /* =========================================================================
   * Director helpers
   * ========================================================================= */

  /* Return a Swift default literal for the given imtype string (used in dispatch
   * guard clauses and open-func default bodies). */
  static String *imtypeDefault(const String *imt) {
    if (!imt || Len(imt) == 0 || Cmp(imt, "Void") == 0)
      return NewString("");
    /* Optional types (end in '?') → nil */
    const char *s = Char(imt);
    if (s[strlen(s) - 1] == '?')
      return NewString("nil");
    if (Cmp(imt, "Bool") == 0)
      return NewString("false");
    if (Cmp(imt, "Float") == 0 || Cmp(imt, "Double") == 0)
      return NewString("0.0");
    /* Numeric Swift types */
    return NewString("0");
  }

  /* Return a Swift default return statement for an open func body. */
  static String *swifttypeDefault(const String *swt) {
    if (!swt || Len(swt) == 0 || Cmp(swt, "Void") == 0)
      return NewString("");
    const char *s = Char(swt);
    /* Optional → nil */
    if (s[strlen(s) - 1] == '?')
      return NewString("return nil");
    if (Cmp(swt, "String") == 0)
      return NewString("return \"\"");
    if (Cmp(swt, "Bool") == 0)
      return NewString("return false");
    if (Cmp(swt, "Float") == 0 || Cmp(swt, "Double") == 0)
      return NewString("return 0.0");
    /* Numeric types */
    if (Cmp(swt, "Int32") == 0 || Cmp(swt, "Int64") == 0 || Cmp(swt, "UInt32") == 0 || Cmp(swt, "UInt64") == 0 || Cmp(swt, "Int16") == 0 ||
        Cmp(swt, "UInt16") == 0 || Cmp(swt, "Int8") == 0 || Cmp(swt, "UInt8") == 0 || Cmp(swt, "Int") == 0 || Cmp(swt, "UInt") == 0 || Cmp(swt, "CChar") == 0)
      return NewString("return 0");
    /* Non-optional class type: must override */
    return NewStringf("fatalError(\"SwigDirector: %s must be overridden\")", swt);
  }

  /* Resolve the Swift class name for a wrapped-class parameter type (for
   * substituting $swiftclassname in typemaps). */
  static String *paramSwiftClassName(Parm *p) {
    return resolveSwiftClassName(Getattr(p, "type"));
  }

  /* =========================================================================
   * classDirectorInit() – begin collecting director-class code for one class
   * ========================================================================= */
  virtual int classDirectorInit(Node *n) {
    String *symname = Getattr(n, "sym:name");
    director_classname = NewStringf("SwigDirector_%s", symname);
    director_symname = Copy(symname);
    director_cb_struct_name = NewStringf("SwigSwiftCallbacks_%s", symname);
    director_cb_fields = NewString("");
    director_cpp_methods = NewString("");
    director_swift_dispatch_fns = NewString("");
    director_swift_open_methods = NewString("");
    director_swift_init_cb = NewString("");
    director_method_count = NewHash();
    return SWIG_OK;
  }

  /* =========================================================================
   * classDirectorDestructor() – suppress base-class output (it uses the
   * "director"/"director_h" handles we've redirected to f_header; the
   * virtual destructor is already emitted inline in classDirectorEnd).
   * ========================================================================= */
  virtual int classDirectorDestructor(Node *) {
    return SWIG_OK;
  }

  /* =========================================================================
   * classDirectorConstructors() – suppress lang.cxx's director-aware constructor
   * generation.  Swift creates directors via _wrap_new_SwigDirector_Foo (from
   * classDirectorEnd), so regular _wrap_new_Foo must stay plain.
   * ========================================================================= */
  virtual int classDirectorConstructors(Node *) {
    return SWIG_OK;
  }

  /* =========================================================================
   * classDirectorDisown() – suppress _wrap_disown_Foo generation.
   * Swift uses ARC for director lifetime; no disown is needed.
   * ========================================================================= */
  virtual int classDirectorDisown(Node *) {
    return SWIG_OK;
  }

  /* =========================================================================
   * classDirectorMethod() – process one virtual method for the director class
   * ========================================================================= */
  virtual int classDirectorMethod(Node *n, Node *parent, String *super) {

    String *c_symname = Getattr(n, "sym:name");
    String *cpp_name = Getattr(n, "name");
    SwigType *rettype = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *par_symname = Getattr(parent, "sym:name");

    bool is_void_ret = (SwigType_type(rettype) == T_VOID);

    /* Method name variations.
     * Overloaded virtual methods produce duplicate base names; append an index
     * (starting at 1 for the second overload) so C struct fields stay unique. */
    String *swift_mname = swiftMethodName(c_symname);
    String *prev_count_str = Getattr(director_method_count, swift_mname);
    int overload_idx = prev_count_str ? atoi(Char(prev_count_str)) : 0;
    String *new_count_str = NewStringf("%d", overload_idx + 1);
    Setattr(director_method_count, swift_mname, new_count_str);
    Delete(new_count_str);

    /* cb_field and dispatch_fn get a numeric suffix for all but the first overload */
    String *cb_field, *dispatch_fn;
    if (overload_idx == 0) {
      cb_field = NewStringf("swig_%s", swift_mname);
      dispatch_fn = NewStringf("_swift_director_%s_%s_dispatch", par_symname, swift_mname);
    } else {
      cb_field = NewStringf("swig_%s_%d", swift_mname, overload_idx);
      dispatch_fn = NewStringf("_swift_director_%s_%s_%d_dispatch", par_symname, swift_mname, overload_idx);
    }
    String *open_fn = Copy(swift_mname); /* override method keeps the C++ name */

    /* Attach typemaps needed for parameter iteration */
    Swig_typemap_attach_parms("in", l, NULL); /* for emit_num_arguments */
    Swig_typemap_attach_parms("ctype", l, NULL);
    Swig_typemap_attach_parms("imtype", l, NULL);
    Swig_typemap_attach_parms("swifttype", l, NULL);
    Swig_typemap_attach_parms("directorin", l, NULL);
    Swig_typemap_attach_parms("swiftdirectorin", l, NULL);
    int num_args = emit_num_arguments(l);

    /* --- Return type info --- */
    String *c_ret = NewString("void");
    String *im_ret = NewString("Void");
    String *swift_ret = NewString("Void");
    String *tm;

    if (!is_void_ret) {
      if ((tm = Swig_typemap_lookup("ctype", n, "", 0))) {
        Delete(c_ret);
        c_ret = NewString(tm);
      }
      if ((tm = Swig_typemap_lookup("imtype", n, "", 0))) {
        Delete(im_ret);
        im_ret = NewString(tm);
      }
      if ((tm = Swig_typemap_lookup("swifttype", n, "", 0))) {
        String *out_attr = Getattr(n, "tmap:swifttype:out");
        if (out_attr)
          tm = out_attr;
        Delete(swift_ret);
        swift_ret = NewString(tm);
        /* $swiftclassname substitution for return type.
         * Try symbol lookup first (works for direct class returns); fall back to
         * proxy_class_name for template instantiations where the lookup fails. */
        if (Strstr(swift_ret, "$swiftclassname")) {
          String *ret_cn = resolveSwiftClassName(rettype);
          if (Equal(ret_cn, "UnsafeMutableRawPointer?")) {
            /* proxy_class_name is not yet set when classDirectorMethod runs
             * (classDirector is called before classHandler); use director_symname. */
            if (director_symname)
              Replaceall(swift_ret, "$swiftclassname", director_symname);
          } else {
            Replaceall(swift_ret, "$swiftclassname", ret_cn);
          }
          Delete(ret_cn);
        }
      }
    }

    /* --- directorout / swiftdirectorout typemaps for return --- */
    String *directorout_code = NULL;
    String *swiftdirectorout_code = NULL;
    if (!is_void_ret) {
      if ((tm = Swig_typemap_lookup("directorout", n, "jresult", 0))) {
        directorout_code = NewString(tm);
        Replaceall(directorout_code, "$result", "jresult");
      }
      if ((tm = Swig_typemap_lookup("swiftdirectorout", n, "", 0))) {
        swiftdirectorout_code = NewString(tm);
        Replaceall(swiftdirectorout_code, "$input", "swresult");
      }
    }

    /* --- Parameter lists (built incrementally) --- */
    String *cb_params = NewString("void *swig_self");
    String *cpp_sig_params = NewString("");
    String *cpp_din_code = NewString("");
    String *cpp_cb_args = NewString("swig_self");
    String *cpp_base_args = NewString(""); /* for base-class fallback call */
    String *dispatch_params = NewString("_ swig_self: UnsafeMutableRawPointer?");
    String *dispatch_body = NewString("");
    String *dispatch_ca = NewString("");
    String *open_params = NewString("");
    int gencomma = 0;

    Parm *p = l;
    for (int i = 0; i < num_args; i++) {
      while (checkAttribute(p, "tmap:in:numinputs", "0"))
        p = Getattr(p, "tmap:in:next");

      SwigType *pt = Getattr(p, "type");
      String *pname = Getattr(p, "name");
      String *lname = Getattr(p, "lname");
      String *arg_name = lowercaseFirst((pname && Len(pname) > 0) ? pname : lname);
      String *cpp_var = NewStringf("arg_%d", i + 1);
      String *j_var = NewStringf("jarg%d", i + 1);
      String *sw_var = NewStringf("swarg%d", i + 1);

      /* C type for callback */
      String *ct = NewStringf("void *");
      if ((tm = Getattr(p, "tmap:ctype"))) {
        Delete(ct);
        ct = NewString(tm);
      }

      /* Swift imtype for dispatch param */
      String *imt = NewStringf("UnsafeMutableRawPointer?");
      if ((tm = Getattr(p, "tmap:imtype"))) {
        Delete(imt);
        imt = NewString(tm);
      }

      /* Swift swifttype for open func param */
      String *swt = NewStringf("UnsafeMutableRawPointer?");
      if ((tm = Getattr(p, "tmap:swifttype"))) {
        Delete(swt);
        swt = NewString(tm);
        if (Strstr(swt, "$swiftclassname")) {
          String *cn = paramSwiftClassName(p);
          Replaceall(swt, "$swiftclassname", cn);
          Delete(cn);
        }
      }

      /* directorin: C++ param → C type for callback.
       * directorin typemaps are not accessible from classDirectorMethod via
       * Swig_typemap_lookup, so we derive the conversion inline:
       * - SWIGTYPE* (pointer, ct=="void*"): cast the pointer to void*
       * - SWIGTYPE& / SWIGTYPE (ref/value, ct=="void*") with %shared_ptr: wrap in
       *   aliased shared_ptr so the Swift side receives a shared_ptr<T>* as expected
       *   by shared_ptr typemaps.
       * - SWIGTYPE& / SWIGTYPE (ref/value, ct=="void*") plain: take address via addressof
       * - primitives (ct != "void*"): identity
       * This matches what the directorin typemaps in swiftswigtype.swg would produce. */
      String *din;
      String *din_pre = NewString(""); /* optional extra line(s) before jarg assignment */
      if (Strcmp(ct, "void *") == 0) {
        if (SwigType_ispointer(pt)) {
          din = NewStringf("(void *)(%s)", cpp_var);
        } else {
          /* Check if the base type uses %shared_ptr — need aliased shared_ptr. */
          String *base_t = SwigType_base(pt);
          Node *tn = base_t ? Swig_symbol_clookup(base_t, 0) : NULL;
          bool is_sp = tn && Getattr(tn, "feature:smartptr");
          if (is_sp) {
            /* Build inner type as "<BaseClass> const" — always const regardless
             * of the param's actual cv-qualification, matching the shared_ptr
             * typemap convention (which uses const shared_ptr<T>& everywhere). */
            String *base_str = SwigType_str(base_t, 0);
            String *sp_type = NewStringf("%s const", base_str);
            Delete(base_str);
            String *sp_var = NewStringf("%s_sp", j_var);
            Printf(din_pre, "    std::shared_ptr<%s> %s(std::shared_ptr<%s>{}, std::addressof(%s));\n", sp_type, sp_var, sp_type, cpp_var);
            din = NewStringf("(void *)&%s", sp_var);
            Delete(sp_var);
            Delete(sp_type);
          } else {
            din = NewStringf("(void *)std::addressof(%s)", cpp_var);
          }
          Delete(base_t);
        }
      } else if (Strcmp(ct, "const char *") == 0 && !SwigType_ispointer(pt)) {
        /* std::string const& or std::string value: call .c_str() to get const char* */
        din = NewStringf("%s.c_str()", cpp_var);
      } else {
        din = Copy(cpp_var);
      }

      /* swiftdirectorin: C dispatch param → Swift open-func param.
       * Same issue: fall back to inline logic based on ct / Swift type. */
      String *sdin;
      if ((tm = Getattr(p, "tmap:swiftdirectorin"))) {
        sdin = NewString(tm);
        Replaceall(sdin, "$input", j_var);
        if (Strstr(sdin, "$swiftclassname")) {
          String *cn = paramSwiftClassName(p);
          Replaceall(sdin, "$swiftclassname", cn);
          Delete(cn);
        }
      } else {
        sdin = Copy(j_var); /* identity fallback */
      }

      /* C++ param type string for override signature */
      String *cpp_type_str = SwigType_str(pt, 0);

      /* Accumulate */
      Printf(cb_params, ", %s %s", ct, j_var);
      if (gencomma)
        Append(cpp_sig_params, ", ");
      Printf(cpp_sig_params, "%s %s", cpp_type_str, cpp_var);
      Printf(cpp_din_code, "%s    %s %s = %s;\n", din_pre, ct, j_var, din);
      Delete(din_pre);
      Printf(cpp_cb_args, ", %s", j_var);
      if (gencomma)
        Append(cpp_base_args, ", ");
      Append(cpp_base_args, cpp_var);
      Printf(dispatch_params, ", _ %s: %s", j_var, imt);
      Printf(dispatch_body, "    let %s: %s = %s\n", sw_var, swt, sdin);
      if (gencomma) {
        Append(dispatch_ca, ", ");
        Append(open_params, ", ");
      }
      Printf(dispatch_ca, "%s: %s", arg_name, sw_var);
      Printf(open_params, "%s: %s", arg_name, swt);
      gencomma = 1;

      Delete(cpp_type_str);
      Delete(ct);
      Delete(imt);
      Delete(swt);
      Delete(din);
      Delete(sdin);
      Delete(arg_name);
      Delete(cpp_var);
      Delete(j_var);
      Delete(sw_var);

      p = Getattr(p, "tmap:in:next") ? Getattr(p, "tmap:in:next") : nextSibling(p);
    }

    /* ---- 1. Callback struct field ----------------------------------------- */
    Printf(director_cb_fields, "    %s (*%s)(%s);\n", c_ret, cb_field, cb_params);

    /* ---- 2. C++ director virtual override ---------------------------------- */
    String *cpp_ret_str = SwigType_str(rettype, 0);
    /* Detect const method.  SWIG's declarator notation has two forms:
     *  - Original declaration: "f(params).q(const)." (const at end)
     *  - Vtable/director entries: "q(const).f(params)." (const at start)
     * Check both; also ensure "q(const)" is NOT only inside f(...) params
     * (which would mean a const parameter, not a const method). */
    String *decl = Getattr(n, "decl");
    bool is_const_method = false;
    if (decl) {
      const char *ds = Char(decl);
      /* Form 1: vtable entries — const at start */
      if (strncmp(ds, "q(const).", 9) == 0)
        is_const_method = true;
      /* Form 2: original declarations — const after closing ')' of f(...) */
      else if (strstr(ds, ").q(const)") != NULL)
        is_const_method = true;
    }
    if (is_const_method)
      Printf(director_cpp_methods, "  virtual %s %s(%s) const override {\n", cpp_ret_str, cpp_name, cpp_sig_params);
    else
      Printf(director_cpp_methods, "  virtual %s %s(%s) override {\n", cpp_ret_str, cpp_name, cpp_sig_params);
    Printf(director_cpp_methods, "    if (swig_callbacks.%s) {\n", cb_field);
    Printv(director_cpp_methods, cpp_din_code, NIL);
    if (is_void_ret) {
      Printf(director_cpp_methods, "      swig_callbacks.%s(%s);\n", cb_field, cpp_cb_args);
      /* canthrow: re-raise any Swift exception as a C++ DirectorException */
      Printf(director_cpp_methods,
             "      if (const char *_e = swig_swift_get_pending_exception()) {\n"
             "        std::string _m(_e); swig_swift_clear_pending_exception();\n"
             "        throw Swig::DirectorException(_m.c_str());\n"
             "      }\n"
             "      return;\n");
    } else {
      Printf(director_cpp_methods, "      %s jresult = swig_callbacks.%s(%s);\n", c_ret, cb_field, cpp_cb_args);
      /* canthrow: re-raise any Swift exception as a C++ DirectorException */
      Printf(director_cpp_methods,
             "      if (const char *_e = swig_swift_get_pending_exception()) {\n"
             "        std::string _m(_e); swig_swift_clear_pending_exception();\n"
             "        throw Swig::DirectorException(_m.c_str());\n"
             "      }\n");
      if (directorout_code) {
        Printf(director_cpp_methods, "      return %s;\n", directorout_code);
      } else if (Strcmp(c_ret, "void *") == 0) {
        /* directorout typemap unavailable — derive inline.
         * For pointer return types: cast void* to T*.
         * For value/reference return types: dereference a heap-allocated T*. */
        if (SwigType_ispointer(rettype))
          Printf(director_cpp_methods, "      return (%s)jresult;\n", cpp_ret_str);
        else
          Printf(director_cpp_methods, "      return *(%s *)jresult;\n", cpp_ret_str);
      } else {
        /* Primitive return: callback returns the value directly. */
        Printf(director_cpp_methods, "      return jresult;\n");
      }
    }
    Printf(director_cpp_methods, "    }\n");
    /* Default: delegate to base class (super is already "ClassName::methodName") */
    if (is_void_ret)
      Printf(director_cpp_methods, "    this->%s(%s);\n", super, cpp_base_args);
    else
      Printf(director_cpp_methods, "    return this->%s(%s);\n", super, cpp_base_args);
    Printf(director_cpp_methods, "  }\n");
    Delete(cpp_ret_str);
    Delete(cpp_base_args);

    /* ---- 3. Swift dispatch function --------------------------------------- */
    String *im_def = imtypeDefault(im_ret);
    if (is_void_ret) {
      Printf(director_swift_dispatch_fns, "\nprivate func %s(%s) {\n", dispatch_fn, dispatch_params);
      Printf(director_swift_dispatch_fns, "    guard let swig_self else { return }\n");
    } else {
      Printf(director_swift_dispatch_fns, "\nprivate func %s(%s) -> %s {\n", dispatch_fn, dispatch_params, im_ret);
      if (Len(im_def) > 0)
        Printf(director_swift_dispatch_fns, "    guard let swig_self else { return %s }\n", im_def);
      else
        Printf(director_swift_dispatch_fns, "    guard let swig_self else { return }\n");
    }
    Printf(director_swift_dispatch_fns, "    let obj = Unmanaged<%s>.fromOpaque(swig_self).takeUnretainedValue()\n", director_symname);
    Printv(director_swift_dispatch_fns, dispatch_body, NIL);
    /* Wrap the upcall in do/try/catch so Swift throws propagate to C++ via the
     * thread-local pending-exception mechanism (canthrow support). */
    if (is_void_ret) {
      Printf(director_swift_dispatch_fns,
             "    do { try obj.%s(%s) } catch {\n"
             "        \"\\(error)\".withCString { SWIG_Swift_SetPendingException($0) }\n"
             "    }\n}\n",
             open_fn,
             dispatch_ca);
    } else {
      Printf(director_swift_dispatch_fns, "    do {\n");
      Printf(director_swift_dispatch_fns, "        let swresult = try obj.%s(%s)\n", open_fn, dispatch_ca);
      if (swiftdirectorout_code)
        Printf(director_swift_dispatch_fns, "        return %s\n", swiftdirectorout_code);
      else
        Printf(director_swift_dispatch_fns, "        return swresult\n");
      Printf(director_swift_dispatch_fns,
             "    } catch {\n"
             "        \"\\(error)\".withCString { SWIG_Swift_SetPendingException($0) }\n");
      if (Len(im_def) > 0)
        Printf(director_swift_dispatch_fns, "        return %s\n", im_def);
      else
        Printf(director_swift_dispatch_fns, "        fatalError(\"SwigDirector: exception in non-optional return\")\n");
      Printf(director_swift_dispatch_fns, "    }\n}\n");
    }
    Delete(im_def);

    /* ---- 4. open func declaration ---------------------------------------- */
    String *sw_def = swifttypeDefault(swift_ret);
    if (is_void_ret) {
      Printf(director_swift_open_methods, "    open func %s(%s) throws {}\n", open_fn, open_params);
    } else if (Len(sw_def) > 0) {
      Printf(director_swift_open_methods, "    open func %s(%s) throws -> %s { %s }\n", open_fn, open_params, swift_ret, sw_def);
    } else {
      Printf(director_swift_open_methods, "    open func %s(%s) throws -> %s {}\n", open_fn, open_params, swift_ret);
    }
    Delete(sw_def);

    /* ---- 5. Init callback assignment -------------------------------------- */
    Printf(director_swift_init_cb, "        cbs.%s = %s\n", cb_field, dispatch_fn);

    Delete(swift_mname);
    Delete(cb_field);
    Delete(dispatch_fn);
    Delete(open_fn);
    Delete(c_ret);
    Delete(im_ret);
    Delete(swift_ret);
    Delete(directorout_code);
    Delete(swiftdirectorout_code);
    Delete(cb_params);
    Delete(cpp_sig_params);
    Delete(cpp_din_code);
    Delete(cpp_cb_args);
    Delete(dispatch_params);
    Delete(dispatch_body);
    Delete(dispatch_ca);
    Delete(open_params);

    return SWIG_OK;
  }

  /* =========================================================================
   * classDirectorEnd() – finalize and emit the complete director class
   * ========================================================================= */
  virtual int classDirectorEnd(Node *n) {
    String *symname = Getattr(n, "sym:name");
    String *cname = Getattr(n, "name"); /* fully-qualified C++ class name */

    /* ---- C header: callback struct + factory declaration ------------------ */
    Printf(swift_header_code, "/* Director callbacks for %s */\n", symname);
    Printf(swift_header_code, "typedef struct {\n");
    Printv(swift_header_code, director_cb_fields, NIL);
    Printf(swift_header_code, "} %s;\n\n", director_cb_struct_name);
    Printf(swift_header_code, "SWIGEXPORT void *_wrap_new_%s(void *swig_self, %s cbs);\n\n", director_classname, director_cb_struct_name);

    /* ---- f_header: callback struct (needed in .cxx before director class) - */
    Printf(f_header, "\n/* Director callback struct for %s */\n", symname);
    Printf(f_header, "typedef struct {\n");
    Printv(f_header, director_cb_fields, NIL);
    Printf(f_header, "} %s;\n", director_cb_struct_name);

    /* ---- f_header: C++ director class definition -------------------------- */
    Printf(f_header, "\n/* C++ director class for %s */\n", symname);
    Printf(f_header, "class %s : public %s {\npublic:\n", director_classname, cname);
    Printf(f_header, "  void *swig_self;\n");
    Printf(f_header, "  %s swig_callbacks;\n", director_cb_struct_name);
    Printf(f_header, "  explicit %s(void *s, %s cbs)\n", director_classname, director_cb_struct_name);
    Printf(f_header, "      : swig_self(s), swig_callbacks(cbs) {}\n");
    /* Default and copy constructors: lang.cxx generates _wrap_new_X() and
     * _wrap_new_X(const BaseClass&) wrappers for every director class.
     * These constructors make that code compile; the constructed objects have
     * swig_self=nullptr and are not usable from Swift (Swift creates directors
     * exclusively via _wrap_new_SwigDirector_X(swiftSelf, cbs)). */
    Printf(f_header, "  %s() : %s(), swig_self(nullptr), swig_callbacks({}) {}\n", director_classname, cname);
    Printf(f_header, "  %s(const %s&) : %s(), swig_self(nullptr), swig_callbacks({}) {}\n", director_classname, cname, cname);
    Printf(f_header, "  virtual ~%s() {}\n", director_classname);
    Printv(f_header, director_cpp_methods, NIL);
    Printf(f_header, "};\n\n");

    /* ---- f_wrappers: extern "C" factory function (inside extern "C" block) */
    /* When the class uses %shared_ptr, return a heap-allocated shared_ptr so that
     * the Swift-side swigCPtr holds a shared_ptr<T>* as expected by all shared_ptr
     * typemaps (e.g. _wrap_GlobalFileAccess__SwigSet). */
    if (Getattr(n, "feature:smartptr")) {
      Printf(f_wrappers,
             "SWIGEXPORT void *_wrap_new_%s(void *swig_self, %s cbs) {\n"
             "    return new std::shared_ptr< %s >(new %s(swig_self, cbs));\n"
             "}\n\n",
             director_classname,
             director_cb_struct_name,
             cname,
             director_classname);
    } else {
      Printf(f_wrappers,
             "SWIGEXPORT void *_wrap_new_%s(void *swig_self, %s cbs) {\n"
             "    return new %s(swig_self, cbs);\n"
             "}\n\n",
             director_classname,
             director_cb_struct_name,
             director_classname);
    }

    /* Swift open class and dispatch functions are emitted by classHandler so that
     * they land inside the proxy class (open class Logger) rather than a separate
     * SwigDirector_Logger class.  Leave the Swift strings alive here; classHandler
     * will consume and delete them. */

    /* cleanup C-only strings — Swift strings are handled by classHandler */
    Delete(director_cb_fields);
    director_cb_fields = NULL;
    Delete(director_cpp_methods);
    director_cpp_methods = NULL;
    Delete(director_method_count);
    director_method_count = NULL;

    return SWIG_OK;
  }

  /* =========================================================================
   * classHandler() – open/close a Swift proxy class
   * ========================================================================= */
  virtual int classHandler(Node *n) {
    String *cn = Getattr(n, "sym:name");

    bool old_director_flag = director_flag;
    director_flag = Swig_directorclass(n) ? true : false;

    /* Save outer class state (nested classes) */
    String *old_proxy_class_name = proxy_class_name;
    String *old_proxy_class_def = proxy_class_def;
    String *old_proxy_class_code = proxy_class_code;
    String *old_proxy_class_constants_code = proxy_class_constants_code;
    String *old_destructor_call = destructor_call;
    String *old_vector_element_swifttype = vector_element_swifttype;
    bool old_current_class_has_base = current_class_has_base;

    proxy_class_name = NewString(cn);
    proxy_class_def = NewString("");
    proxy_class_code = NewString("");
    proxy_class_constants_code = NewString("");
    destructor_call = NewString("");
    vector_element_swifttype = NULL;
    current_class_has_base = false;

    if (!addSymbol(cn, n, old_proxy_class_name))
      return SWIG_ERROR;

    /* ----- Build class header line ----------------------------------------
     * Check for base classes. We pick the first SWIG-wrapped base.           */
    String *baseclass_name = NULL;
    List *baselist = Getattr(n, "bases");
    if (baselist) {
      for (Iterator b = First(baselist); b.item; b = Next(b)) {
        if (!GetFlag(b.item, "feature:ignore")) {
          String *bname = Getattr(b.item, "sym:name");
          if (bname) {
            baseclass_name = Copy(bname);
            break;
          }
        }
      }
    }

    /* Warn about multiple inheritance */
    if (baselist && Len(baselist) > 1) {
      bool first = true;
      for (Iterator b = First(baselist); b.item; b = Next(b)) {
        if (!GetFlag(b.item, "feature:ignore")) {
          if (first) {
            first = false;
            continue;
          }
          Swig_warning(WARN_SWIFT_MULTIPLE_INHERITANCE,
                       input_file,
                       line_number,
                       "Swift does not support multiple inheritance. Ignoring base %s.\n",
                       Getattr(b.item, "sym:name"));
        }
      }
    }

    /* Class modifiers typemap.
     * Use classtypeobj (the canonical SwigType for this class) for typemap matching;
     * this lets SWIGTYPE catch-all typemaps resolve against concrete class types. */
    SwigType *typemap_lookup_type = Getattr(n, "classtypeobj");
    if (!typemap_lookup_type)
      typemap_lookup_type = Getattr(n, "name");
    const String *class_mods = typemapLookup(n, "swiftclassmodifiers", typemap_lookup_type, WARN_SWIFT_TYPEMAP_CLASSMOD_UNDEF);

    current_class_has_base = (baseclass_name != NULL);
    emitDoxygenComment(n, proxy_class_def, 0);

    /* Director classes must be open so Swift code can subclass them directly.
     * Swift's 'open' already implies public access, so we use it instead of
     * the class_mods modifier (which is 'public' from the swiftclassmodifiers
     * typemap). */
    if (director_flag) {
      if (baseclass_name)
        Printf(proxy_class_def, "\nopen class %s: %s {\n", cn, baseclass_name);
      else
        Printf(proxy_class_def, "\nopen class %s {\n", cn);
    } else if (baseclass_name) {
      Printf(proxy_class_def, "\n%s class %s: %s {\n", class_mods, cn, baseclass_name);
    } else {
      Printf(proxy_class_def, "\n%s class %s {\n", class_mods, cn);
    }

    /* Standard class body (swiftbody typemap) */
    String *swiftbody = NewString("");
    if (baseclass_name) {
      const String *derived_body = typemapLookup(n, "swiftbody_derived", typemap_lookup_type, WARN_NONE);
      if (Len(derived_body) > 0) {
        Printv(swiftbody, derived_body, NIL);
      } else {
        const String *base_body = typemapLookup(n, "swiftbody", typemap_lookup_type, WARN_SWIFT_TYPEMAP_SWIFTBODY_UNDEF);
        Printv(swiftbody, base_body, NIL);
      }
    } else {
      const String *base_body = typemapLookup(n, "swiftbody", typemap_lookup_type, WARN_SWIFT_TYPEMAP_SWIFTBODY_UNDEF);
      Printv(swiftbody, base_body, NIL);
    }
    Replaceall(swiftbody, "$swiftclassname", cn);
    Printv(proxy_class_code, swiftbody, NIL);
    Delete(swiftbody);

    /* ----- Process class members ------------------------------------------ */
    Language::classHandler(n);

    /* ----- Director: public init() + open func stubs ---------------------- */
    /* classDirectorEnd (called from inside Language::classHandler above) left
     * director_swift_* strings alive for us to consume here. */
    if (director_flag && director_swift_init_cb) {
      /* director public init — initialises swigCPtr via the C++ director ctor */
      Printf(proxy_class_code, "    public init() throws {\n");
      Printf(proxy_class_code, "        var cbs = %s()\n", director_cb_struct_name);
      Printv(proxy_class_code, director_swift_init_cb, NIL);
      if (baseclass_name)
        Printf(proxy_class_code, "        super.init(nil, false)\n");
      else {
        Printf(proxy_class_code, "        swigCPtr = nil\n");
        Printf(proxy_class_code, "        swigCMemOwn = false\n");
      }
      Printf(proxy_class_code, "        let selfPtr = Unmanaged.passUnretained(self).toOpaque()\n");
      Printf(proxy_class_code, "        swigCPtr = _wrap_new_%s(selfPtr, cbs)\n", director_classname);
      Printf(proxy_class_code, "        swigCMemOwn = true\n");
      Printf(proxy_class_code, "        try swigCheckException()\n");
      Printf(proxy_class_code, "    }\n");
      /* open func stubs for each virtual method */
      Printv(proxy_class_code, director_swift_open_methods, NIL);
    }

    /* ----- deinit / destructor -------------------------------------------- */
    {
      const String *swiftdestruct = typemapLookup(n, baseclass_name ? "swiftdestruct_derived" : "swiftdestruct", typemap_lookup_type, WARN_NONE);
      String *destruct_code = NewString(swiftdestruct);
      Replaceall(destruct_code, "$swiftclassname", cn);
      Replaceall(destruct_code, "$imcall", destructor_call);
      if (Len(destructor_call) > 0)
        Printv(proxy_class_code, "\n", destruct_code, NIL);
      Delete(destruct_code);
    }

    /* ----- Write the class to the Swift output buffer --------------------- */
    /* old_proxy_class_code is non-NULL when this class is being processed
     * inside another class's classHandler (i.e. it is a C++ nested class and
     * flatnested is NOT in effect).  In that case write it directly into the
     * outer class body so it becomes a proper Swift inner type.
     * When flatnested IS in effect SWIG hoists the class to module scope
     * before calling classHandler, so old_proxy_class_code is NULL and the
     * class lands at module level — which is also correct. */
    String *class_dest = old_proxy_class_code ? old_proxy_class_code : swift_module_code;

    /* Director dispatch functions are module-level private funcs; emit them
     * before the class regardless of nesting. */
    if (director_flag && director_swift_dispatch_fns)
      Printv(swift_module_code, director_swift_dispatch_fns, NIL);

    Printv(class_dest, proxy_class_def, proxy_class_code, NIL);

    /* Add constants/nested enums */
    if (Len(proxy_class_constants_code))
      Printv(class_dest, proxy_class_constants_code, NIL);

    Printv(class_dest, "}\n", NIL);

    /* Auto-emit RandomAccessCollection conformance for std::vector wrappers.
     * A getElement(i:) accessor is defined only by Lib/swift/std_vector.i, so its
     * presence marks this class as a wrapped vector; vector_element_swifttype holds
     * the exact Swift type getElement returns, so the subscript type always matches.
     * This replaces the old SWIFT_VECTOR_COLLECTION(name, elem) macro — callers no
     * longer pass the element type, and it can never drift from getElement's type. */
    if (vector_element_swifttype) {
      Printv(swift_module_code, "\nextension ", cn, ": RandomAccessCollection {\n", NIL);
      Printv(swift_module_code, "    public typealias Element = ", vector_element_swifttype, "\n", NIL);
      Printv(swift_module_code, "    public typealias Index = Int\n", NIL);
      Printv(swift_module_code, "    public var startIndex: Int { 0 }\n", NIL);
      Printv(swift_module_code, "    public var endIndex: Int { (try? Int(size())) ?? 0 }\n", NIL);
      Printv(swift_module_code, "    public subscript(position: Int) -> ", vector_element_swifttype, " {\n", NIL);
      Printv(swift_module_code, "        // swiftlint:disable:next force_try\n", NIL);
      Printv(swift_module_code, "        return try! getElement(i: Int32(position))\n", NIL);
      Printv(swift_module_code, "    }\n}\n", NIL);
    }

    /* ----- Clean up director Swift strings (left alive by classDirectorEnd) */
    if (director_flag) {
      Delete(director_classname);
      director_classname = NULL;
      Delete(director_symname);
      director_symname = NULL;
      Delete(director_cb_struct_name);
      director_cb_struct_name = NULL;
      Delete(director_swift_dispatch_fns);
      director_swift_dispatch_fns = NULL;
      Delete(director_swift_open_methods);
      director_swift_open_methods = NULL;
      Delete(director_swift_init_cb);
      director_swift_init_cb = NULL;
    }

    /* ----- Restore outer class state -------------------------------------- */
    Delete(proxy_class_name);
    proxy_class_name = old_proxy_class_name;
    Delete(proxy_class_def);
    proxy_class_def = old_proxy_class_def;
    Delete(proxy_class_code);
    proxy_class_code = old_proxy_class_code;
    Delete(proxy_class_constants_code);
    proxy_class_constants_code = old_proxy_class_constants_code;
    Delete(destructor_call);
    destructor_call = old_destructor_call;
    Delete(vector_element_swifttype);
    vector_element_swifttype = old_vector_element_swifttype;
    current_class_has_base = old_current_class_has_base;
    Delete(baseclass_name);

    director_flag = old_director_flag;

    return SWIG_OK;
  }

  /* =========================================================================
   * nestedClassesSupport() / nestedClassDeclaration()
   * ========================================================================= */
  virtual NestedClassSupport nestedClassesSupport() const {
    return NCS_Full;
  }

  virtual int nestedClassDeclaration(Node *n) {
    return classHandler(n);
  }

  /* =========================================================================
   * memberfunctionHandler()
   * ========================================================================= */
  virtual int memberfunctionHandler(Node *n) {
    static_flag = false;
    variable_wrapper_flag = false;

    Language::memberfunctionHandler(n);

    /* Virtual methods in director classes are exposed as open func overrides
     * (emitted by classDirectorMethod / classHandler).  Emitting a second
     * proxy method with the same name would create a duplicate-declaration
     * error in Swift, so skip it here.
     * Also skip virtual methods in non-director classes that derive from a
     * director class when no C wrapper was generated for this class specifically
     * (the method's wrap:name starts with _wrap_ but not with _wrap_<ClassName>_). */
    if (Getattr(n, "storage") && !Cmp(Getattr(n, "storage"), "virtual")) {
      if (director_flag)
        return SWIG_OK;
      String *wn = Getattr(n, "wrap:name");
      if (wn && proxy_class_name) {
        /* Use substring search for _{classname}_ to handle nested classes.
         * Nested classes like Image::ImageResampler get wrap name
         * _wrap_Image_ImageResampler_Method, so a startswith check fails. */
        String *expected_infix = NewStringf("_%s_", proxy_class_name);
        bool found = (Strstr(wn, expected_infix) != NULL);
        Delete(expected_infix);
        if (!found)
          return SWIG_OK;
      }
    }

    /* Skip overloads that SWIG decided not to wrap (no C wrapper generated) */
    if (Getattr(n, "overload:ignore")) {
      return SWIG_OK;
    }

    /* Generate the Swift proxy method */
    emitSwiftProxyMethod(n, proxy_class_code, false);

    return SWIG_OK;
  }

  /* =========================================================================
   * staticmemberfunctionHandler()
   * ========================================================================= */
  virtual int staticmemberfunctionHandler(Node *n) {
    static_flag = true;

    Language::staticmemberfunctionHandler(n);

    if (Getattr(n, "overload:ignore")) {
      static_flag = false;
      return SWIG_OK;
    }

    /* Build full selector "MethodName:label1:label2:..." for this static method.
     * Using the full selector (not just method name) means that derived-class methods
     * with different parameter labels are not treated as overrides of the base method. */
    String *msym = Getattr(n, "sym:name");
    if (msym && proxy_class_name) {
      /* Build selector by iterating visible params (skip numinputs=0). */
      ParmList *pl = Getattr(n, "parms");
      String *selector = NewStringf("%s:", msym);
      for (Parm *sp = pl; sp;) {
        while (sp && checkAttribute(sp, "tmap:in:numinputs", "0"))
          sp = Getattr(sp, "tmap:in:next");
        if (!sp)
          break;
        String *pname = Getattr(sp, "name");
        String *lname = Getattr(sp, "lname");
        if (pname && Len(pname))
          Printf(selector, "%s:", pname);
        else if (lname && Len(lname))
          Printf(selector, "%s:", lname);
        else
          Append(selector, "arg:");
        Parm *nxt = Getattr(sp, "tmap:in:next");
        sp = nxt ? nxt : nextSibling(sp);
      }

      /* Check if any ancestor class recorded the same selector. */
      Node *cls_node = parentNode(n);
      if (cls_node) {
        List *bases = Getattr(cls_node, "bases");
        if (bases) {
          for (Iterator b = First(bases); b.item; b = Next(b)) {
            if (GetFlag(b.item, "feature:ignore"))
              continue;
            String *bsym = Getattr(b.item, "sym:name");
            String *recorded = bsym ? Getattr(class_static_methods, bsym) : NULL;
            if (bsym && recorded) {
              String *target = NewStringf("|%s|", selector);
              String *padded = NewStringf("|%s|", recorded);
              if (Strstr(padded, target))
                Setattr(n, "swift:static_override", "1");
              Delete(target);
              Delete(padded);
            }
          }
        }
      }

      /* Record this selector for descendant classes */
      String *current = Getattr(class_static_methods, proxy_class_name);
      if (!current) {
        Setattr(class_static_methods, proxy_class_name, selector);
      } else {
        String *merged = NewStringf("%s|%s", current, selector);
        Setattr(class_static_methods, proxy_class_name, merged);
        Delete(merged);
      }
      Delete(selector);
    }

    emitSwiftProxyMethod(n, proxy_class_code, true);

    Delattr(n, "swift:static_override");
    static_flag = false;
    return SWIG_OK;
  }

  /* =========================================================================
   * globalvariableHandler() – wraps global C++ variables as Swift module-level
   * properties (getter/setter).
   * ========================================================================= */
  virtual int globalvariableHandler(Node *n) {
    static_flag = false;
    variable_wrapper_flag = true;

    Language::globalvariableHandler(n);

    variable_wrapper_flag = false;
    return SWIG_OK;
  }

  /* =========================================================================
   * membervariableHandler() – wraps C++ member variables as Swift properties.
   * ========================================================================= */
  virtual int membervariableHandler(Node *n) {
    variable_wrapper_flag = true;

    Language::membervariableHandler(n);

    variable_wrapper_flag = false;
    return SWIG_OK;
  }

  /* =========================================================================
   * staticmembervariableHandler()
   * ========================================================================= */
  virtual int staticmembervariableHandler(Node *n) {
    static_flag = true;
    variable_wrapper_flag = true;

    Language::staticmembervariableHandler(n);

    static_flag = false;
    variable_wrapper_flag = false;
    return SWIG_OK;
  }

  /* =========================================================================
   * memberconstantHandler()
   * ========================================================================= */
  virtual int memberconstantHandler(Node *n) {
    Language::memberconstantHandler(n);
    return SWIG_OK;
  }

  /* Check if the DIRECT parent class actually generated an init with matching
   * num_args AND the same first parameter label (to avoid false overrides when
   * a derived class introduces a new init with the same arg count but different
   * parameter names).
   * Key format: "num_args:label1:label2:..." (all param labels, colon-separated).
   * Director base classes always contribute a zero-arg init ("0:"). */
  bool ancestorHasGeneratedInitWith(Node *cls, const String *key, bool check_director = true) {
    List *bases = Getattr(cls, "bases");
    if (!bases)
      return false;
    for (Iterator b = First(bases); b.item; b = Next(b)) {
      if (GetFlag(b.item, "feature:ignore"))
        continue;
      String *bsym = Getattr(b.item, "sym:name");
      if (bsym) {
        String *recorded = Getattr(class_generated_inits, bsym);
        if (recorded) {
          String *target = NewStringf("|%s|", key);
          String *padded = NewStringf("|%s|", recorded);
          bool found = (Strstr(padded, target) != NULL);
          Delete(target);
          Delete(padded);
          if (found)
            return true;
        }
        /* Director base (direct only) always emits a zero-arg init */
        if (check_director && Cmp(key, "0:") == 0 && Swig_directorclass(b.item))
          return true;
      }
      /* A base wrapped in another module (%import) never ran through constructorHandler, so it is
       * absent from class_generated_inits. Match against its constructor declarations directly so a
       * constructor inherited across the module boundary is still emitted with 'override'. */
      if (classNodeHasCtorWithKey(b.item, key))
        return true;
      /* Recurse without director check so only immediate director parents trigger it */
      if (ancestorHasGeneratedInitWith(b.item, key, false))
        return true;
    }
    return false;
  }

  /* Compute the init-dispatch key "{num}:{label1}:{label2}:..." for a constructor parameter list.
   * Shared by constructorHandler (derived class, wrap:parms carrying typemaps) and
   * classNodeHasCtorWithKey (base class AST, raw parms) so the two keys are directly comparable. */
  String *ctorInitKey(ParmList *l) {
    int num = emit_num_arguments(l);
    String *key;
    if (num == 0) {
      key = NewStringf("0:");
    } else {
      key = NewStringf("%d", num);
      Parm *fp = l;
      while (fp) {
        while (fp && checkAttribute(fp, "tmap:in:numinputs", "0"))
          fp = Getattr(fp, "tmap:in:next");
        if (!fp)
          break;
        String *fpname = Getattr(fp, "name");
        String *flname = Getattr(fp, "lname");
        if (fpname && Len(fpname) > 0)
          Printf(key, ":%s", fpname);
        else if (flname && Len(flname) > 0)
          Printf(key, ":%s", flname);
        else
          Printf(key, ":arg");
        fp = Getattr(fp, "tmap:in:next") ? Getattr(fp, "tmap:in:next") : nextSibling(fp);
      }
    }
    return key;
  }

  /* True if class node 'cls' declares a constructor whose init key equals 'key'. Used to detect
   * constructors inherited from an %import-ed base (which are not in class_generated_inits).
   *
   * A single C++ constructor with default arguments expands into one Swift init per arity (from the
   * number of required parameters up to the total), so this matches 'key' against every such arity
   * rather than only the full parameter list. (On the imported base the constructor is a single AST
   * node with the defaulted params still present, whereas the derived class emits a separate init
   * per overload - so without this the shorter overloads would never match.) */
  bool classNodeHasCtorWithKey(Node *cls, const String *key) {
    for (Node *c = firstChild(cls); c; c = nextSibling(c)) {
      String *nt = Getattr(c, "nodeType");
      if (!nt || !Equal(nt, "constructor"))
        continue;
      if (GetFlag(c, "feature:ignore"))
        continue;

      /* Collect the parameter labels and how many are required (i.e. precede the first defaulted
       * parameter), mirroring ctorInitKey's label selection (name, else lname, else "arg"). */
      List *labels = NewList();
      int required = 0;
      bool seen_default = false;
      for (Parm *p = Getattr(c, "parms"); p; p = nextSibling(p)) {
        if (checkAttribute(p, "tmap:in:numinputs", "0"))
          continue;
        String *pn = Getattr(p, "name");
        String *ln = Getattr(p, "lname");
        String *label = (pn && Len(pn) > 0) ? Copy(pn) : ((ln && Len(ln) > 0) ? Copy(ln) : NewString("arg"));
        Append(labels, label);
        Delete(label);
        if (Getattr(p, "value"))
          seen_default = true;
        if (!seen_default)
          required = Len(labels);
      }

      int total = Len(labels);
      for (int arity = required; arity <= total; arity++) {
        String *ck;
        if (arity == 0) {
          ck = NewStringf("0:");
        } else {
          ck = NewStringf("%d", arity);
          for (int i = 0; i < arity; i++)
            Printf(ck, ":%s", Getitem(labels, i));
        }
        bool match = Equal(ck, key);
        Delete(ck);
        if (match) {
          Delete(labels);
          return true;
        }
      }
      Delete(labels);
    }
    return false;
  }

  void recordGeneratedInit(const String *class_sym, const String *key) {
    String *current = Getattr(class_generated_inits, class_sym);
    if (!current) {
      Setattr(class_generated_inits, class_sym, key);
    } else {
      String *merged = NewStringf("%s|%s", current, key);
      Setattr(class_generated_inits, class_sym, merged);
      Delete(merged);
    }
  }

  /* =========================================================================
   * constructorHandler() – generates init() for the proxy class.
   * ========================================================================= */
  virtual int constructorHandler(Node *n) {
    String *tm;
    Parm *p;
    int i;

    /* Let the base class call functionWrapper to get the C wrapper and attach typemaps */
    Language::constructorHandler(n);

    /* For director classes the public init() is injected by classHandler (it creates a
     * C++ SwigDirector_Foo object with the callback struct).  Suppress the plain
     * _wrap_new_Foo proxy init here to avoid a duplicate-signature compile error. */
    if (director_flag)
      return SWIG_OK;

    /* Skip overloads that SWIG decided not to wrap (no C wrapper generated) */
    if (Getattr(n, "overload:ignore"))
      return SWIG_OK;

    /* Fetch parms AFTER base call so typemap attachments from functionWrapper are present */
    ParmList *l = Getattr(n, "wrap:parms");
    if (!l)
      l = Getattr(n, "parms");

    String *wname = Getattr(n, "wrap:name");
    if (!wname)
      return SWIG_OK;

    /* Build Swift init() */
    String *swift_params = NewString("");
    String *c_args = NewString("");
    int num_args = emit_num_arguments(l);
    int gencomma = 0, swift_comma = 0;

    for (i = 0, p = l; i < num_args; i++) {
      while (checkAttribute(p, "tmap:in:numinputs", "0"))
        p = Getattr(p, "tmap:in:next");

      String *pname = Getattr(p, "name");
      String *lname = Getattr(p, "lname");
      String *swift_arg_name;
      if (pname && Len(pname) > 0)
        swift_arg_name = Copy(pname);
      else if (lname && Len(lname) > 0)
        swift_arg_name = Copy(lname);
      else
        swift_arg_name = NewStringf("arg%d", i + 1);
      swift_arg_name = swiftEscapeIdentifier(swift_arg_name);

      String *swift_param_type = NewString("");
      if ((tm = Getattr(p, "tmap:swifttype"))) {
        Printv(swift_param_type, tm, NIL);
        String *pcn = paramSwiftClassName(p);
        pcn = selfClassNameIfOpaque(pcn);
        Replaceall(swift_param_type, "$swiftclassname", pcn);
        Replaceall(swift_param_type, "$module", moduleName());
        Delete(pcn);
      } else {
        Printv(swift_param_type, "/* UNKNOWN */", NIL);
      }

      String *swiftin_tm = NewString("");
      if ((tm = Getattr(p, "tmap:swiftin"))) {
        Printv(swiftin_tm, tm, NIL);
        Replaceall(swiftin_tm, "$swiftinput", swift_arg_name);
        String *pcn = paramSwiftClassName(p);
        pcn = selfClassNameIfOpaque(pcn);
        Replaceall(swiftin_tm, "$swiftclassname", pcn);
        Replaceall(swiftin_tm, "$module", moduleName());
        Delete(pcn);
      } else {
        Printv(swiftin_tm, swift_arg_name, NIL);
      }

      if (swift_comma)
        Printf(swift_params, ", ");
      Printf(swift_params, "%s: %s", swift_arg_name, swift_param_type);
      swift_comma = 1;

      if (gencomma)
        Printf(c_args, ", ");
      Printf(c_args, "%s", swiftin_tm);
      gencomma = 1;

      p = Getattr(p, "tmap:in:next") ? Getattr(p, "tmap:in:next") : nextSibling(p);
      Delete(swift_arg_name);
      Delete(swift_param_type);
      Delete(swiftin_tm);
    }

    /* If this is a base class with swiftbody providing swigCPtr, we set it here.
     * For derived classes, super.init is called with the C pointer.
     * Check if there's a base class: if proxy_class_def contains ": " */
    /* Whether the current class has a wrapped base, as decided by classHandler.
     * Use that class-level flag rather than scanning proxy_class_def for ':' --
     * the doxygen doc comment emitted into proxy_class_def can itself contain
     * colons (e.g. "- Returns:"), and parentNode() of a %extend constructor is
     * not the class node, so neither heuristic is reliable on its own. */
    bool has_base = current_class_has_base;
    /* Use l (= wrap:parms, has typemaps) for override tracking.
     * Swig_restore() in Language::constructorHandler strips typemaps from "parms". */
    /* Build full init key: "{num}:{label1}:{label2}:..." from wrap:parms (has typemaps).
     * Using all labels (not just the first) distinguishes e.g. init(d:fp:) from init(d:executor:).
     * Computed via the shared ctorInitKey() so it matches the key derived from a base class' raw
     * constructor AST in classNodeHasCtorWithKey() (cross-module override detection). */
    String *init_key = ctorInitKey(l);
    Node *cls_node = parentNode(n);
    /* Skip override check for class-specific constructors (e.g. copy ctors) where
     * a parameter type is the class itself — the base's copy ctor takes a different
     * type so they're distinct Swift signatures even with the same label. */
    bool is_class_specific_ctor = false;
    if (num_args > 0 && cls_node) {
      String *class_ctype = Getattr(cls_node, "name");
      Parm *fp = l;
      while (fp && !is_class_specific_ctor) {
        while (fp && checkAttribute(fp, "tmap:in:numinputs", "0"))
          fp = Getattr(fp, "tmap:in:next");
        if (!fp)
          break;
        SwigType *ptype = Getattr(fp, "type");
        if (ptype) {
          String *base_type = SwigType_base(ptype);
          if (class_ctype && Cmp(base_type, class_ctype) == 0)
            is_class_specific_ctor = true;
          Delete(base_type);
        }
        fp = Getattr(fp, "tmap:in:next") ? Getattr(fp, "tmap:in:next") : nextSibling(fp);
      }
    }
    bool is_override = !is_class_specific_ctor && cls_node && has_base && ancestorHasGeneratedInitWith(cls_node, init_key);
    emitDoxygenComment(n, proxy_class_code, "    ");
    Printf(proxy_class_code, "\n    %spublic init(%s) throws {\n", is_override ? "override " : "", swift_params);

    if (has_base) {
      Printf(proxy_class_code, "        guard let ptr = %s(%s) else {\n", wname, c_args);
      Printf(proxy_class_code, "            try swigCheckException()\n");
      Printf(proxy_class_code, "            fatalError(\"Constructor returned nil\")\n");
      Printf(proxy_class_code, "        }\n");
      Printf(proxy_class_code, "        super.init(ptr, true)\n");
    } else {
      Printf(proxy_class_code, "        swigCPtr = %s(%s)\n", wname, c_args);
      Printf(proxy_class_code, "        swigCMemOwn = true\n");
    }

    Printf(proxy_class_code, "        try swigCheckException()\n");
    Printf(proxy_class_code, "    }\n");

    /* Record this init so derived classes can detect needed "override" */
    if (proxy_class_name)
      recordGeneratedInit(proxy_class_name, init_key);

    Delete(init_key);
    Delete(swift_params);
    Delete(c_args);

    return SWIG_OK;
  }

  /* =========================================================================
   * destructorHandler() – records the C destructor call for use in deinit.
   * ========================================================================= */
  virtual int destructorHandler(Node *n) {
    Language::destructorHandler(n);

    String *wname = Getattr(n, "wrap:name");
    if (wname) {
      /* destructor_call is substituted into the swiftdestruct typemap */
      Printf(destructor_call, "%s(swigCPtr)", wname);
    }
    return SWIG_OK;
  }

  /* =========================================================================
   * enumDeclaration() – generates a Swift enum.
   * ========================================================================= */
  virtual int enumDeclaration(Node *n) {
    if (!ImportMode) {
      if (getCurrentClass() && (cplus_mode != PUBLIC))
        return SWIG_NOWRAP;

      String *symname = Getattr(n, "sym:name");
      if (!symname || Getattr(n, "unnamedinstance"))
        return Language::enumDeclaration(n);

      /* Nested enums named "Type" get a class-prefixed name to avoid Swift metatype conflict. */
      String *enum_display_name;
      if (is_wrapping_class() && proxy_class_name && Equal(symname, "Type"))
        enum_display_name = NewStringf("%s_Type", proxy_class_name);
      else
        enum_display_name = Copy(symname);

      /* Target: module-level code or nested in the current class */
      String *constants_dest = is_wrapping_class() ? proxy_class_constants_code : swift_module_code;

      enum_code = NewString("");
      emitDoxygenComment(n, enum_code, is_wrapping_class() ? "    " : 0);
      Printf(enum_code, "\npublic enum %s: Int32 {\n", enum_display_name);
      Delete(enum_display_name);

      Language::enumDeclaration(n);

      Printf(enum_code, "}\n");

      Printv(constants_dest, enum_code, NIL);
      Delete(enum_code);
      enum_code = NULL;
    }
    return SWIG_OK;
  }

  /* =========================================================================
   * enumvalueDeclaration() – generates one Swift enum case.
   * ========================================================================= */
  virtual int enumvalueDeclaration(Node *n) {
    if (!ImportMode && enum_code) {
      String *symname = Getattr(n, "sym:name");
      /* Use only enumvalue (explicit literal). enumvalueex contains C++
       * expressions like "PREV_CASE + 1" or "Foo::BAR" that are invalid
       * as Swift enum raw values. */
      String *value = Getattr(n, "enumvalue");

      emitDoxygenComment(n, enum_code, "    ", /*nextLeadsNewline=*/false);

      if (value && !Strstr(value, "::")) {
        /* Check if value is a numeric literal or a symbolic alias (another case name).
         * Swift cannot have two cases with the same raw value; emit 'static let' instead. */
        const char *vstart = Char(value);
        bool is_numeric = (vstart && (*vstart == '-' || isdigit((unsigned char)*vstart)));
        if (is_numeric) {
          Printf(enum_code, "    case %s = %s\n", symname, value);
        } else {
          Printf(enum_code, "    public static let %s: Self = .%s\n", symname, value);
        }
      } else {
        Printf(enum_code, "    case %s\n", symname);
      }
    }
    return Language::enumvalueDeclaration(n);
  }

  /* =========================================================================
   * constantWrapper() – emits a Swift static constant or global let.
   * ========================================================================= */
  virtual int constantWrapper(Node *n) {
    /* Enum values are emitted by enumvalueDeclaration; skip them here. */
    if (Cmp(nodeType(n), "enumitem") == 0)
      return SWIG_OK;

    String *symname = Getattr(n, "sym:name");
    String *value = Getattr(n, "rawval");
    if (!value)
      value = Getattr(n, "value");
    /* No value to emit (would otherwise produce an uncompilable "= (null)"). */
    if (!value)
      return SWIG_OK;

    /* Skip C++ scoped enum constants (e.g. "inno::ImageType::UNKNOWN") — they
     * are already emitted as enum cases by enumvalueDeclaration. */
    if (value && Strstr(value, "::"))
      return SWIG_OK;
    SwigType *type = Getattr(n, "type");

    String *constants_dest = is_wrapping_class() ? proxy_class_constants_code : swift_module_code;

    /* Determine Swift type */
    String *swift_type = NewString("");
    int tt = SwigType_type(type);
    if (tt == T_BOOL || tt == T_SCHAR || tt == T_UCHAR || tt == T_SHORT || tt == T_USHORT || tt == T_INT || tt == T_UINT || tt == T_LONG || tt == T_ULONG ||
        tt == T_LONGLONG || tt == T_ULONGLONG || tt == T_CHAR) {
      Printv(swift_type, "Int32", NIL);
    } else if (tt == T_FLOAT || tt == T_DOUBLE) {
      Printv(swift_type, "Double", NIL);
    } else if (tt == T_STRING) {
      Printv(swift_type, "String", NIL);
    } else {
      Printv(swift_type, "Int32", NIL);
    }

    if (is_wrapping_class()) {
      Printf(constants_dest, "    public static let %s: %s = %s\n", symname, swift_type, value);
    } else {
      Printf(constants_dest, "\npublic let %s: %s = %s\n", symname, swift_type, value);
    }

    Delete(swift_type);
    return SWIG_OK;
  }

  /* =========================================================================
   * insertDirective() – handle %insert(swift) { … }
   * ========================================================================= */
  virtual int insertDirective(Node *n) {
    String *code = Getattr(n, "code");
    String *section = Getattr(n, "section");
    if (!ImportMode && Cmp(section, "swift") == 0) {
      if (proxy_class_code)
        Printv(proxy_class_code, code, NIL);
      else
        Printv(swift_module_code, code, NIL);
      return SWIG_OK;
    }
    return Language::insertDirective(n);
  }

}; /* class SWIFT */

/* =========================================================================
 * Usage string
 * ========================================================================= */
const char *SWIFT::usage = "\
Swift Options (available with -swift)\n\
     -outfile <file>  - Override the name of the output .swift file\n\
     -autorename      - Rename wrapped methods to Swift's lowerCamelCase convention\n\
     -doxygen         - Convert C++ Doxygen comments to Swift documentation comments\n\
\n";

/* =========================================================================
 * Factory function
 * ========================================================================= */
static Language *new_swig_swift() {
  return new SWIFT();
}

extern "C" Language *swig_swift(void) {
  return new_swig_swift();
}

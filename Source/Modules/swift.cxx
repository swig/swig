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
static bool isSwiftKeyword(const char *name) {
  static const char *keywords[] = {
    "associatedtype",  "class",    "deinit", "enum",        "extension", "func",  "import", "init",     "inout",  "let",      "operator",
    "precedencegroup", "protocol", "struct", "subscript",   "typealias", "var",   "break",  "case",     "catch",  "continue", "default",
    "defer",           "do",       "else",   "fallthrough", "for",       "guard", "if",     "in",       "repeat", "return",   "throw",
    "switch",          "where",    "while",  "Any",         "false",     "is",    "nil",    "rethrows", "self",   "Self",     "super",
    "throws",          "true",     "try",    NULL};
  for (int i = 0; keywords[i]; i++)
    if (strcmp(name, keywords[i]) == 0)
      return true;
  return false;
}

/* Backtick-escape a single leaf identifier when it collides with a Swift
 * keyword (e.g. a type/enum named "repeat").  Non-destructive: returns a new
 * string and leaves the argument untouched. */
static String *swiftKeywordEscape(const String *name) {
  if (name && Len(name) > 0 && isSwiftKeyword(Char(name)))
    return NewStringf("`%s`", name);
  return Copy(name);
}

static String *swiftEscapeIdentifier(String *name) {
  if (!name || Len(name) == 0)
    return name;
  /* A Swift identifier can never contain a C++ qualifier.  A namespace
   * variable's generated setter parameter arrives qualified (e.g. "ns::var"),
   * which would emit an invalid Swift parameter name; keep the tail only. */
  {
    const char *s = Char(name);
    const char *tail = s;
    const char *sep;
    while ((sep = strstr(tail, "::")))
      tail = sep + 2;
    if (tail != s) {
      String *stripped = NewString(tail);
      Delete(name);
      name = stripped;
    }
  }
  if (isSwiftKeyword(Char(name))) {
    String *escaped = NewStringf("`%s`", name);
    Delete(name);
    return escaped;
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
      /* Nested types are emitted nested in Swift, so qualify with the FULL
       * enclosing-class path (recurse up the parent chain) - a one-level name
       * resolves inside the enclosing class but not from module scope.
       * A nested enum named "Type" uses an underscore to avoid a Swift metatype
       * conflict; keep that immediate-parent form (rare, single-level only). */
      String *pn = Getattr(parent, "sym:name");
      if (pn && Len(pn) > 0) {
        String *ntype = Getattr(n, "nodeType");
        if (ntype && Equal(ntype, "enum") && Equal(cn, "Type"))
          return NewStringf("%s_Type", pn);
        String *pfull = swiftNestedName(parent);
        String *cesc = swiftKeywordEscape(cn);
        String *result = NewStringf("%s.%s", pfull, cesc);
        Delete(pfull);
        Delete(cesc);
        return result;
      }
    }
  }
  return swiftKeywordEscape(cn);
}

/* A class known only by a forward declaration (never defined where SWIG can see
 * it, e.g. defined in a plain %{ %} block) has no Swift proxy, so its name must
 * not be used as a type; treat it as opaque and let it route to a SWIGTYPE_*
 * wrapper.  A class that IS wrapped resolves to its "class" node, not this. */
static bool swiftNodeIsOpaqueForward(Node *n) {
  String *nt = Getattr(n, "nodeType");
  return nt && Equal(nt, "classforward");
}

static String *resolveSwiftClassName(SwigType *t) {
  Node *n = Language::classLookup(t);
  if (n) {
    String *cn = Getattr(n, "sym:name");
    if (cn && Len(cn) > 0 && Strncmp(cn, "__dummy_", 8) != 0 && !swiftNodeIsOpaqueForward(n))
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
      String *snt = Getattr(sn, "nodeType");
      /* An enum VALUE is not a type: a non-type template argument such as
       * Bar<Enum17::Val1> resolves the symbol Val1 (an enumitem), whose name
       * must never be used as a Swift class name (it would leak the enumerator
       * into a template instantiation's element type). */
      if (cn && Len(cn) > 0 && Strncmp(cn, "__dummy_", 8) != 0 && !(snt && Equal(snt, "enumitem")) && !swiftNodeIsOpaqueForward(sn)) {
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
  File *f_directors;    /* C++ director class definitions (dumped after f_header so a
                           director base class defined in a trailing %{ } block, which
                           lands in f_header, precedes the SwigDirector_ subclass) */
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
  bool enum_as_struct;                /* current enum uses the struct fallback (duplicate values) */
  String *enum_type_name;             /* display name of the current enum (for struct member refs) */
  long enum_next_value;               /* running C auto-increment value for the struct fallback */
  bool enum_value_known;              /* whether enum_next_value is currently trustworthy */
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
  String *director_using_code;         /* "using Base::member;" lines for the director class body */
  String *director_cb_fields;          /* struct body: one fn-ptr field per method */
  String *director_cpp_methods;        /* C++ virtual override bodies */
  String *director_swift_dispatch_fns; /* module-level Swift @convention(c) dispatch fns */
  String *director_swift_open_methods; /* open func swig_* declarations */
  String *director_swift_init_cb;      /* cbs.swig_* = fn; lines in Swift init body */
  String *director_cpp_ctors;          /* per-base-constructor C++ forwarding ctors */
  String *director_factory_decls;      /* per-ctor factory bridging-header declarations */
  String *director_swift_inits;        /* per-base-constructor Swift init(...) bodies */
  Hash *director_method_count;         /* base-name → seen-count, for overload dedup */
  Hash *class_generated_inits;         /* class sym:name → comma-list of arg counts actually emitted */
  Hash *class_generated_methods;       /* class sym:name → |-list of method Swift signatures emitted */
  Hash *class_processed;               /* class sym:name → "1" if wrapped in this run (same-module) */
  Hash *class_static_methods;          /* class sym:name → pipe-delimited list of static method names */
  Hash *director_base_classes;         /* sym:name → "1" for every (transitive) base of a director class */
  Hash *swift_types_hash;              /* SWIGTYPE_p_* wrapper class name → SwigType, for pointers/refs
                                          to non-wrapped types; emitted as opaque proxy classes in top() */
  Hash *swift_enum_wrapper_names;      /* subset of swift_types_hash whose type is an enum SWIG does not
                                          wrap (in %{ }, forward-declared or %ignore'd); emitted as a
                                          rawValue struct (not a swigCPtr proxy) so the enum typemaps work */

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

  /* Mark every (transitive) base of a director class as needing 'open'. */
  void markDirectorBases(Node *cls) {
    List *baselist = Getattr(cls, "bases");
    if (!baselist)
      return;
    for (Iterator b = First(baselist); b.item; b = Next(b)) {
      String *bname = Getattr(b.item, "sym:name");
      if (bname)
        Setattr(director_base_classes, bname, "1");
      markDirectorBases(b.item); /* transitive: ancestors of the base too */
    }
  }

  /* Pre-pass: Swift forbids an 'open' class (every director proxy is 'open')
   * from having a non-open superclass.  Record the ancestors of each director
   * class so classHandler can emit them 'open' as well. */
  void collectDirectorBases(Node *n) {
    for (Node *c = firstChild(n); c; c = nextSibling(c)) {
      String *nt = Getattr(c, "nodeType");
      /* Mirror lang.cxx's director decision.  Swig_directorclass() can't be used
       * here: it tests the "vtable" attribute, which is only built later during
       * Language::top(), whereas this pre-pass runs before it.  The feature flags
       * are already set, so replicate the same enablement test. */
      if (nt && Equal(nt, "class") && Swig_directors_enabled() && GetFlag(c, "feature:director") && !GetFlag(c, "feature:nodirector"))
        markDirectorBases(c);
      collectDirectorBases(c);
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

  /* True when a type (after resolving typedefs and stripping pointer/reference/
   * qualifier constructors) is a C/C++ enum.  Used to pick the enum director
   * conversion (C++ enum <-> int) since a scoped enum has no implicit int
   * conversion. */
  bool swiftTypeIsEnum(SwigType *t) {
    SwigType *r = SwigType_typedef_resolve_all(t);
    SwigType *b = SwigType_base(r);
    bool result = SwigType_isenum(b) ? true : false;
    Delete(b);
    Delete(r);
    return result;
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

  /* A pointer/reference/array to a type SWIG does not wrap (int*, void*, a function
   * pointer, an opaque struct) resolves to the opaque sentinel.  Rather than leak that
   * into the Swift signature, generate a SWIGTYPE_p_* wrapper class name (mangled from
   * the type, as Java/C# do) and record the type so the class is emitted in top().
   * Consumes and replaces the passed string; no-op if cn is already a real class name. */
  String *swiftWrapperNameIfOpaque(String *cn, SwigType *t) {
    if (!Equal(cn, "UnsafeMutableRawPointer?"))
      return cn;
    SwigType *resolved = SwigType_typedef_resolve_all(t);
    String *mangled = SwigType_manglestr(resolved);
    String *name = NewStringf("SWIGTYPE%s", mangled);
    if (!Getattr(swift_types_hash, name))
      Setattr(swift_types_hash, name, resolved);
    /* An enum SWIG does not wrap must be marshalled through its rawValue, not a
     * swigCPtr proxy, so record it for the struct form of the wrapper. */
    if (swiftTypeIsEnum(t))
      Setattr(swift_enum_wrapper_names, name, "1");
    Delete(mangled);
    Delete(resolved);
    Delete(cn);
    return name;
  }

  /* Resolve $swiftclassname for a type: a real proxy-class name, else the enclosing
   * class (self-reference), else a generated SWIGTYPE_p_* wrapper.  Returns owned.
   * An unwrapped enum skips the self-reference step: it must never resolve to the
   * enclosing class (the enum typemaps use .rawValue, which the class lacks) - it
   * falls through to a rawValue-struct wrapper instead. */
  String *swiftClassNameFor(SwigType *t) {
    String *cn = resolveSwiftClassName(t);
    if (!swiftTypeIsEnum(t))
      cn = selfClassNameIfOpaque(cn);
    cn = swiftWrapperNameIfOpaque(cn, t);
    return cn;
  }

  /* Emit a minimal opaque proxy class for one SWIGTYPE_p_* wrapper, reusing the same
   * swiftbody typemap the real proxy classes use so the marshalling stays consistent
   * (holds swigCPtr / swigCMemOwn, provides init(ptr, own) and swigGetCPtr). */
  void emitTypeWrapperClass(String *classname, SwigType *type) {
    /* An unwrapped enum is marshalled by value through its rawValue (the enum
     * typemaps read .rawValue and construct via init?(rawValue:)), so emit the
     * same rawValue struct used as the duplicate-value enum fallback rather than
     * a swigCPtr proxy. */
    if (Getattr(swift_enum_wrapper_names, classname)) {
      Printf(swift_module_code, "\npublic struct %s: Equatable {\n", classname);
      Printf(swift_module_code, "    public let rawValue: Int32\n");
      Printf(swift_module_code, "    public init?(rawValue: Int32) { self.rawValue = rawValue }\n");
      Printf(swift_module_code, "}\n");
      return;
    }

    Node *n = NewHash();
    Setfile(n, input_file);
    Setline(n, line_number);
    Setattr(n, "sym:name", classname);

    const String *class_mods = typemapLookup(n, "swiftclassmodifiers", type, WARN_NONE);
    const char *mods = (class_mods && Len(class_mods) > 0) ? Char(class_mods) : "public";
    String *body = NewString(typemapLookup(n, "swiftbody", type, WARN_NONE));
    Replaceall(body, "$swiftclassname", classname);

    Printf(swift_module_code, "\n%s class %s {\n", mods, classname);
    Printv(swift_module_code, body, NIL);
    Printf(swift_module_code, "}\n");

    Delete(body);
    Delete(n);
  }

  void emitTypeWrapperClasses() {
    for (Iterator it = First(swift_types_hash); it.key; it = Next(it))
      emitTypeWrapperClass(it.key, it.item);
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
    f_directors(NULL),
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
    enum_as_struct(false),
    enum_type_name(NULL),
    enum_next_value(0),
    enum_value_known(true),
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
    director_cpp_ctors(NULL),
    director_factory_decls(NULL),
    director_swift_inits(NULL),
    director_method_count(NULL),
    class_generated_inits(NewHash()),
    class_generated_methods(NewHash()),
    class_processed(NewHash()),
    class_static_methods(NewHash()),
    swift_types_hash(NULL),
    swift_enum_wrapper_names(NULL),
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
    Delete(class_generated_methods);
    Delete(class_processed);
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

    /* Record ancestors of director classes so they are emitted 'open' too. */
    director_base_classes = NewHash();
    collectDirectorBases(n);

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
    f_directors = NewString("");
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
    swift_types_hash = NewHash();
    swift_enum_wrapper_names = NewHash();

    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("init", f_init);

    /* classDirector() in lang.cxx writes using_protected_members_code (the
     * "using Base::member;" lines that expose protected members in allprotected
     * mode) to the "director_h" handle, just before calling classDirectorEnd.
     * Those declarations are only valid inside the director class body, so route
     * both handles to a dedicated buffer that classDirectorEnd splices into the
     * class definition (and clears afterwards for the next class). */
    director_using_code = NewString("");
    Swig_register_filebyname("director", director_using_code);
    Swig_register_filebyname("director_h", director_using_code);

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
    if (Swig_directors_enabled()) {
      /* Suppress the core's dummy Swig::DirectorException stub (emitted under
       * #ifndef SWIG_DIRECTORS for non-director languages); swift/director.swg
       * defines the real one, so without this the two clash (redefinition). */
      Printf(f_runtime, "#define SWIG_DIRECTORS\n");
      Swig_insert_file("swift/director.swg", f_runtime);
    }

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

    /* Opaque wrapper classes for pointers/refs to non-wrapped types (SWIGTYPE_p_*),
     * collected during code generation.  Appended to the module code before it is dumped. */
    emitTypeWrapperClasses();

    /* --- emit module-level Swift code (module imports + helper + global fns) --- */
    if (Len(swift_module_imports))
      Printv(f_swift, swift_module_imports, "\n", NIL);
    /* Default typed-exception builder.  swigCheckException() (from swift.swg)
     * calls swigBuildTypedException(); a module may supply a richer one from its
     * own %pragma(swift) modulecode (e.g. an Exceptions.i dispatching to typed
     * Swift error classes).  Emit the nil-returning default only when it did
     * not, so the two definitions do not collide. */
    if (!swift_module_code || !Strstr(swift_module_code, "func swigBuildTypedException"))
      Printv(f_swift,
             "@inline(__always)\n"
             "private func swigBuildTypedException() -> Error? { return nil }\n\n",
             NIL);
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
    Dump(f_directors, f_begin);
    Dump(f_wrappers, f_begin);
    Wrapper_pretty_print(f_init, f_begin);

    Delete(f_runtime);
    Delete(f_header);
    Delete(f_directors);
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
    Delete(swift_types_hash);
    swift_types_hash = NULL;
    Delete(swift_enum_wrapper_names);
    swift_enum_wrapper_names = NULL;
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
    if (Strstr(actioncode, "darg") && director_flag && proxy_class_name) {
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
    Replaceall(f->code, "$symname", symname);
    /* %contract asserts are emitted as the 2-arg SWIG_contract_assert(expr, msg);
     * inject the method's null return so the macro can return it on violation
     * (mirrors java.cxx / d.cxx).  Must run before $null is expanded below. */
    Replaceall(f->code, "SWIG_contract_assert(", "SWIG_contract_assert($null, ");
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

    if (Strstr(swift_return_type, "$swiftclassname")) {
      String *ret_cn = swiftClassNameFor(rettype);
      Replaceall(swift_return_type, "$swiftclassname", ret_cn);
      Delete(ret_cn);
    }
    Replaceall(swift_return_type, "$module", moduleName());
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

    /* C++ allows repeated parameter names (e.g. f(int argx, int argx)); Swift
     * rejects the duplicate internal names.  Track names seen in this signature
     * and suffix any collision so the emitted parameter list stays valid. */
    Hash *seen_arg_names = NewHash();

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
      if (Getattr(seen_arg_names, swift_arg_name)) {
        String *unique = NewStringf("%s_%d", swift_arg_name, i + 1);
        Delete(swift_arg_name);
        swift_arg_name = unique;
      }
      Setattr(seen_arg_names, swift_arg_name, "1");

      /* Swift parameter type */
      String *swift_param_type = NewString("");
      if ((tm = Getattr(p, "tmap:swifttype"))) {
        Printv(swift_param_type, tm, NIL);
        if (Strstr(swift_param_type, "$swiftclassname")) {
          String *pcn = swiftClassNameFor(Getattr(p, "type"));
          Replaceall(swift_param_type, "$swiftclassname", pcn);
          Delete(pcn);
        }
        Replaceall(swift_param_type, "$module", moduleName());
      } else {
        Swig_warning(WARN_SWIFT_TYPEMAP_SWIFTTYPE_UNDEF, input_file, line_number, "No swifttype for %s\n", SwigType_str(pt, 0));
        Printv(swift_param_type, "/* UNKNOWN */", NIL);
      }

      /* swiftin typemap – how to convert the Swift arg to a C arg */
      String *swiftin_tm = NewString("");
      if ((tm = Getattr(p, "tmap:swiftin"))) {
        Printv(swiftin_tm, tm, NIL);
        Replaceall(swiftin_tm, "$swiftinput", swift_arg_name);
        if (Strstr(swiftin_tm, "$swiftclassname")) {
          String *pcn = swiftClassNameFor(Getattr(p, "type"));
          Replaceall(swiftin_tm, "$swiftclassname", pcn);
          Delete(pcn);
        }
        Replaceall(swiftin_tm, "$module", moduleName());
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
    Delete(seen_arg_names);

    /* Build $imcall: the actual C function call */
    String *imcall = NewStringf("%s(%s)", wname, c_args);

    /* Build the swiftout body, substituting $imcall and class name */
    String *body = Copy(swiftout);
    Replaceall(body, "$imcall", imcall);
    /* Detect value-type member getter: the SWIGTYPE* swiftout carries the $owner
     * marker.  The by-value SWIGTYPE and shared_ptr swiftouts instead hardcode 'true':
     * their C 'out' typemap always heap-allocates the returned object (new T(...) or
     * new shared_ptr<T>(...)), so the proxy must own and free it - that 'true' must be
     * preserved, otherwise the allocation leaks (deinit skips delete when own is false).
     * Only class members (is_wrapping_class) can be value-type getters; global vars stay optional. */
    bool is_value_type_getter = variable_wrapper_flag && is_wrapping_class() && !is_static && !is_void && (Strstr(body, "$owner") != NULL);
    /* A $owner (raw SWIGTYPE* pointer return) is owned only when the method is %newobject. */
    Replaceall(body, "$owner", GetFlag(n, "feature:new") ? "true" : "false");
    if (Strstr(body, "$swiftclassname")) {
      String *ret_cn = swiftClassNameFor(rettype);
      Replaceall(body, "$swiftclassname", ret_cn);
      Delete(ret_cn);
    }
    Replaceall(body, "$module", moduleName());

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
    /* Signature-based override detection: Swift requires 'override' for any member
     * that shadows a superclass member - including a non-virtual one, and cases the
     * C++ "override" attribute misses (templated bases, using-declarations, access
     * changes).  Match this method's Swift signature (name + argument labels)
     * against methods already emitted for an ancestor proxy class, and record this
     * one so further-derived classes can do the same. */
    if (in_class && proxy_class_name) {
      /* Key on the full Swift signature (name + argument labels AND types): Swift
       * treats a method with a different parameter type as an overload, not an
       * override (e.g. a covariant parameter foxy(BaseInt) vs foxy(DerivedInt)).
       * Return type is excluded, since Swift permits a covariant return override.
       * Static (class) methods are keyed separately - a static cannot override an
       * instance method and vice versa. */
      String *method_key = NewStringf("%s%s(%s)", is_static ? "static:" : "", swift_name, swift_params);
      Node *cls_node = getCurrentClass();
      if (cls_node && current_class_has_base && ancestorHasGeneratedMethodWith(cls_node, method_key))
        is_override = true;
      else if (is_override && cls_node && swiftSuperclassProcessed(cls_node))
        /* The core marked this an override, but the same-module Swift superclass
         * exposes no method with this exact signature (a covariant parameter makes
         * it a distinct Swift overload), so it is not a Swift override. */
        is_override = false;
      recordGeneratedMethod(proxy_class_name, method_key);
      Delete(method_key);
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
     * whose subscript return type matches getElement by construction.  The vector
     * accessor takes an index argument; require at least one parameter so an unrelated
     * getElement() (e.g. a plain getter returning a member) does not falsely mark the
     * class as a collection. */
    if (!is_void && is_wrapping_class() && Equal(symname, "getElement") && !vector_element_swifttype && l && ParmList_len(l) >= 1) {
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
   * substituting $swiftclassname in typemaps).  Uses the full swiftClassNameFor
   * path so a pointer/reference to a non-wrapped type gets a distinct SWIGTYPE_*
   * wrapper name - director method overloads on distinct opaque pointers (e.g.
   * method(int*) vs method(double*)) must not collapse to one Swift signature. */
  String *paramSwiftClassName(Parm *p) {
    return swiftClassNameFor(Getattr(p, "type"));
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
    director_cpp_ctors = NewString("");
    director_factory_decls = NewString("");
    director_swift_inits = NewString("");
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
   * classDirectorConstructors() – emit one forwarding constructor + factory +
   * Swift init per wrapped base constructor.  Runs after classDirectorInit, so
   * the director buffers exist.  constructorHandler ran earlier (member emission)
   * and stashed the Swift init parameter / C argument lists on each ctor node.
   * A director class with no wrapped constructor leaves the buffers empty and
   * falls back to the single default factory in classDirectorEnd / classHandler.
   * ========================================================================= */
  virtual int classDirectorConstructors(Node *n) {
    /* Does the director class have a wrapped base? (mirrors the baseclass_name
     * detection in classHandler; current_class_has_base is not yet valid here,
     * as the director pass runs before classHandler.) */
    bool has_base = false;
    List *baselist = Getattr(n, "bases");
    if (baselist) {
      for (Iterator b = First(baselist); b.item; b = Next(b)) {
        if (!GetFlag(b.item, "feature:ignore") && Getattr(b.item, "sym:name")) {
          has_base = true;
          break;
        }
      }
    }

    for (Node *ni = firstChild(n); ni; ni = nextSibling(ni)) {
      String *nt = Getattr(ni, "nodeType");
      if (!nt)
        continue;
      /* Inherited constructors ("using Base::Base;") appear as a "using" node
       * (usingctor set) wrapping one synthesized "constructor" child per inherited
       * signature.  Descend into it and forward those ctors too - otherwise a
       * class whose base has no default constructor gets a director subclass that
       * default-constructs the (deleted) base. */
      if (Equal(nt, "using") && Getattr(ni, "usingctor")) {
        for (Node *ci = firstChild(ni); ci; ci = nextSibling(ci)) {
          String *cnt = Getattr(ci, "nodeType");
          if (!cnt || !Equal(cnt, "constructor") || Getattr(ci, "overload:ignore") || GetFlag(ci, "feature:ignore"))
            continue;
          String *caccess = Getattr(ci, "access");
          if (caccess && Equal(caccess, "private"))
            continue;
          emitDirectorConstructor(ci, has_base);
        }
        continue;
      }
      if (!Equal(nt, "constructor"))
        continue;
      /* Skip an %ignore'd constructor (feature:ignore): it is not wrapped, and the
       * real definition may even hide it (e.g. made private in a %{ } block). */
      if (Getattr(ni, "overload:ignore") || GetFlag(ni, "feature:ignore"))
        continue;
      /* Forward public and protected base constructors: the SwigDirector_
       * subclass can call a protected base ctor, and a director base often has
       * only protected constructors (e.g. an abstract class). Skip private. */
      String *access = Getattr(ni, "access");
      if (access && Equal(access, "private"))
        continue;
      emitDirectorConstructor(ni, has_base);
    }
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

    /* A virtual method with default arguments (e.g. f(int i=0)) is expanded by
     * SWIG into the full-signature node plus synthetic reduced-parameter copies
     * (f(int) and f()).  Emit the director override only for the full signature;
     * a copy would generate a mismatched 'override' (int f() over base f(int)).
     * The 'defaultargs' attribute is set only on the copies (matches java.cxx). */
    if (Getattr(n, "defaultargs"))
      return SWIG_OK;

    String *c_symname = Getattr(n, "sym:name");
    String *cpp_name = Getattr(n, "name");
    SwigType *rettype = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *par_symname = Getattr(parent, "sym:name");

    bool is_void_ret = (SwigType_type(rettype) == T_VOID);

    /* A %ignore'd virtual method has no target-language symbol (sym:name is null)
     * and no Swift callback.  The C++ director subclass must still override it so
     * it is not left abstract, but that override simply delegates to the base
     * (or, for a pure virtual, throws) - none of the sym:name-derived callback
     * machinery below applies.  Mirrors java.cxx's ignored_method handling. */
    bool ignored_method = GetFlag(n, "feature:ignore") ? true : false;

    /* Method name variations.
     * Overloaded virtual methods produce duplicate base names; append an index
     * (starting at 1 for the second overload) so C struct fields stay unique. */
    String *swift_mname = NULL;
    String *cb_field = NULL;
    String *dispatch_fn = NULL;
    String *open_fn = NULL;
    if (!ignored_method) {
      swift_mname = swiftMethodName(c_symname);
      String *prev_count_str = Getattr(director_method_count, swift_mname);
      int overload_idx = prev_count_str ? atoi(Char(prev_count_str)) : 0;
      String *new_count_str = NewStringf("%d", overload_idx + 1);
      Setattr(director_method_count, swift_mname, new_count_str);
      Delete(new_count_str);

      /* cb_field and dispatch_fn get a numeric suffix for all but the first overload */
      if (overload_idx == 0) {
        cb_field = NewStringf("swig_%s", swift_mname);
        dispatch_fn = NewStringf("_swift_director_%s_%s_dispatch", par_symname, swift_mname);
      } else {
        cb_field = NewStringf("swig_%s_%d", swift_mname, overload_idx);
        dispatch_fn = NewStringf("_swift_director_%s_%s_%d_dispatch", par_symname, swift_mname, overload_idx);
      }
      open_fn = Copy(swift_mname); /* override method keeps the C++ name */
    }

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
        /* A reference to a const-qualified pointer (e.g. Element *const *&): the
         * generic SWIGTYPE& directorout casts through $1_ltype, which strips the
         * embedded const, so the dereferenced lvalue (Element**) cannot bind to
         * the const-qualified reference return.  Rebuild the cast from the actual
         * return type to preserve the const. */
        if (SwigType_isreference(rettype)) {
          SwigType *referenced = Copy(rettype);
          SwigType_del_reference(referenced);
          String *rstr = SwigType_str(referenced, 0);
          if (SwigType_ispointer(referenced) && Strstr(rstr, "const")) {
            SwigType_add_pointer(referenced);
            String *cast = SwigType_str(referenced, 0);
            Delete(directorout_code);
            directorout_code = NewStringf("*(%s)jresult", cast);
            Delete(cast);
          }
          Delete(rstr);
          Delete(referenced);
        }
      }
      if ((tm = Swig_typemap_lookup("swiftdirectorout", n, "", 0))) {
        swiftdirectorout_code = NewString(tm);
        Replaceall(swiftdirectorout_code, "$input", "swresult");
        /* An opaque pointer return has no proxy class: swresult is already the raw
         * UnsafeMutableRawPointer?, so return it directly rather than dereferencing
         * a non-existent .swigCPtr (mirrors the opaque swiftdirectorin case). */
        if (Equal(swift_ret, "UnsafeMutableRawPointer?")) {
          Delete(swiftdirectorout_code);
          swiftdirectorout_code = NewString("swresult");
        }
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

      /* Swift swifttype for open func param.  swt_uses_classname records whether
       * the open-func param type is a proxy/wrapper class (its swifttype typemap
       * referenced $swiftclassname) rather than a raw Swift type (void* →
       * UnsafeMutableRawPointer?, a primitive pointer/ref → Int32, ...); the
       * swiftdirectorin conversion below must stay consistent with it. */
      String *swt = NewStringf("UnsafeMutableRawPointer?");
      bool swt_uses_classname = false;
      if ((tm = Getattr(p, "tmap:swifttype"))) {
        Delete(swt);
        swt = NewString(tm);
        if (Strstr(swt, "$swiftclassname")) {
          String *cn = paramSwiftClassName(p);
          Replaceall(swt, "$swiftclassname", cn);
          Delete(cn);
          swt_uses_classname = true;
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
      } else if (swiftTypeIsEnum(pt)) {
        /* enum (value or reference): the callback ABI is int; a scoped enum has
         * no implicit int conversion, so cast explicitly. */
        din = NewStringf("(int)%s", cpp_var);
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
          /* Keep the conversion consistent with the open-func param type (swt).
           * When swt is a raw Swift type (not a proxy/wrapper class - void*,
           * primitive pointer/ref, ...) the incoming dispatch arg already IS that
           * type, so pass it through; building a proxy over it would both mismatch
           * swt and emit invalid "UnsafeMutableRawPointer?(x, false)". */
          if (!swt_uses_classname) {
            Delete(sdin);
            sdin = Copy(j_var);
          } else {
            String *cn = paramSwiftClassName(p);
            Replaceall(sdin, "$swiftclassname", cn);
            Delete(cn);
          }
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
      /* An unnamed C++ parameter has no Swift argument label: use the '_' (no
       * external label) form in the open-func declaration and omit the label at
       * the call site.  Emitting "%s:" with an empty name would be invalid Swift. */
      if (Len(arg_name) > 0) {
        Printf(dispatch_ca, "%s: %s", arg_name, sw_var);
        Printf(open_params, "%s: %s", arg_name, swt);
      } else {
        Printf(dispatch_ca, "%s", sw_var);
        Printf(open_params, "_ %s: %s", sw_var, swt);
      }
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
    if (!ignored_method)
      Printf(director_cb_fields, "    %s (*%s)(%s);\n", c_ret, cb_field, cb_params);

    /* ---- 2. C++ director virtual override ---------------------------------- */
    String *cpp_ret_str = SwigType_str(rettype, 0);
    /* 'super' is the vtable fqdname, which uses SWIG's internal template notation
     * (e.g. "Foo<(int)>::bar").  Convert it to valid C++ ("Foo< int >::bar") for
     * the base-class delegate call, matching Swig_method_call().  Idempotent for
     * non-template names. */
    String *super_name = SwigType_namestr(super);
    /* Detect a const *member function*.  In SWIG's declarator notation the const
     * method qualifier is applied to the function, so it appears immediately
     * before "f(" - "q(const).f()." (or "q(const).f(params).").  A const applied
     * to the RETURN type instead sits AFTER the function, e.g. "int *const f()" →
     * "f().q(const).p.", which must NOT be treated as a const method (that would
     * emit an "() const" override that does not match the base). */
    String *decl = Getattr(n, "decl");
    bool is_const_method = decl && Strstr(decl, "q(const).f(") != NULL;
    /* A conversion operator ("operator int", "operator Foo") encodes its result
     * type in the name and must NOT have a separate return type in the
     * declaration ("virtual operator int()", not "virtual int operator int()"). */
    const char *ret_prefix = Getattr(n, "conversion_operator") ? "" : Char(cpp_ret_str);
    const char *ret_sep = Getattr(n, "conversion_operator") ? "" : " ";
    if (is_const_method)
      Printf(director_cpp_methods, "  virtual %s%s%s(%s) const override {\n", ret_prefix, ret_sep, cpp_name, cpp_sig_params);
    else
      Printf(director_cpp_methods, "  virtual %s%s%s(%s) override {\n", ret_prefix, ret_sep, cpp_name, cpp_sig_params);
    if (ignored_method) {
      /* No Swift callback: an ignored non-pure virtual delegates straight to the
       * base; an ignored pure virtual has no base implementation, so throw the
       * standard director pure-virtual exception (raise() is [[noreturn]]). */
      String *ig_storage = Getattr(n, "storage");
      String *ig_value = Getattr(n, "value");
      bool ig_pure_virtual = (!Cmp(ig_storage, "virtual") && !Cmp(ig_value, "0"));
      if (ig_pure_virtual) {
        String *pname = SwigType_namestr(Getattr(parent, "name"));
        Printf(director_cpp_methods, "    Swig::DirectorPureVirtualException::raise(\"%s::%s\");\n", pname, cpp_name);
        Delete(pname);
      } else if (is_void_ret)
        Printf(director_cpp_methods, "    this->%s(%s);\n", super_name, cpp_base_args);
      else
        Printf(director_cpp_methods, "    return this->%s(%s);\n", super_name, cpp_base_args);
      Printf(director_cpp_methods, "  }\n");
      Delete(cpp_ret_str);
      Delete(super_name);
      Delete(cpp_base_args);
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
    /* Default: delegate to base class (super_name is "ClassName::methodName") */
    if (is_void_ret)
      Printf(director_cpp_methods, "    this->%s(%s);\n", super_name, cpp_base_args);
    else
      Printf(director_cpp_methods, "    return this->%s(%s);\n", super_name, cpp_base_args);
    Printf(director_cpp_methods, "  }\n");
    /* Protected virtual methods are not accessible through a base-class pointer,
     * so the C wrapper cannot upcall them directly.  Mirror java.cxx/csharp.cxx:
     * in dirprot mode expose a public inline "<name>SwigPublic" that makes the
     * non-virtual base call, which the wrapper invokes via the darg director
     * pointer.  Pure virtuals have no base implementation, so skip them. */
    {
      String *storage = Getattr(n, "storage");
      String *value = Getattr(n, "value");
      bool pure_virtual = (!Cmp(storage, "virtual") && !Cmp(value, "0"));
      if (dirprot_mode() && !is_public(n) && !pure_virtual) {
        const char *qual = is_const_method ? " const" : "";
        Printf(director_cpp_methods, "  %s %sSwigPublic(%s)%s {\n", cpp_ret_str, cpp_name, cpp_sig_params, qual);
        if (is_void_ret)
          Printf(director_cpp_methods, "    %s(%s);\n  }\n", super_name, cpp_base_args);
        else
          Printf(director_cpp_methods, "    return %s(%s);\n  }\n", super_name, cpp_base_args);
      }
    }
    Delete(cpp_ret_str);
    Delete(super_name);
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
    /* Mark 'override' when a superclass already exposes this virtual - whether as
     * a director open-func stub or a regular proxy method (in Swift an 'open func'
     * and a 'func' with the same signature are the same overridable member, so
     * they share one key).  Record it for further-derived classes. */
    String *of_sig = NewStringf("%s(%s)", open_fn, open_params);
    bool of_override = parent && ancestorHasGeneratedMethodWith(parent, of_sig, /*recurse=*/true);
    if (par_symname)
      recordGeneratedMethod(par_symname, of_sig);
    Delete(of_sig);
    const char *of_kw = of_override ? "override " : "";
    if (is_void_ret) {
      Printf(director_swift_open_methods, "    %sopen func %s(%s) throws {}\n", of_kw, open_fn, open_params);
    } else if (Len(sw_def) > 0) {
      Printf(director_swift_open_methods, "    %sopen func %s(%s) throws -> %s { %s }\n", of_kw, open_fn, open_params, swift_ret, sw_def);
    } else {
      Printf(director_swift_open_methods, "    %sopen func %s(%s) throws -> %s {}\n", of_kw, open_fn, open_params, swift_ret);
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
    /* Fully-qualified C++ class name.  SwigType_namestr converts SWIG's internal
     * template notation ("Foo<(int)>") to valid C++ ("Foo< int >"); idempotent
     * for non-template names. */
    String *cname = SwigType_namestr(Getattr(n, "name"));

    /* ---- C header: callback struct + factory declaration ------------------ */
    Printf(swift_header_code, "/* Director callbacks for %s */\n", symname);
    Printf(swift_header_code, "typedef struct {\n");
    Printv(swift_header_code, director_cb_fields, NIL);
    Printf(swift_header_code, "} %s;\n\n", director_cb_struct_name);
    /* Factory declarations reference the callback struct, so they must follow the
     * typedef above.  Per-constructor factories were buffered by
     * emitDirectorConstructor; otherwise declare the single default factory. */
    if (Len(director_cpp_ctors) > 0)
      Printv(swift_header_code, director_factory_decls, "\n", NIL);
    else if (Getattr(n, "allocate:default_constructor"))
      Printf(swift_header_code, "SWIGEXPORT void *_wrap_new_%s(void *swig_self, %s cbs);\n\n", director_classname, director_cb_struct_name);

    /* The director class is written to f_directors (dumped after all of f_header,
     * so a base class defined in a trailing %{ } block precedes it). */
    /* ---- callback struct (needed before the director class) --------------- */
    Printf(f_directors, "\n/* Director callback struct for %s */\n", symname);
    Printf(f_directors, "typedef struct {\n");
    Printv(f_directors, director_cb_fields, NIL);
    Printf(f_directors, "} %s;\n", director_cb_struct_name);

    /* ---- C++ director class definition ------------------------------------ */
    Printf(f_directors, "\n/* C++ director class for %s */\n", symname);
    Printf(f_directors, "class %s : public %s {\npublic:\n", director_classname, cname);
    Printf(f_directors, "  void *swig_self;\n");
    Printf(f_directors, "  %s swig_callbacks;\n", director_cb_struct_name);
    if (Len(director_cpp_ctors) > 0) {
      /* Per-base-constructor forwarding ctors (supports a base with no default
       * constructor); emitted by emitDirectorConstructor. */
      Printv(f_directors, director_cpp_ctors, NIL);
    } else if (Getattr(n, "allocate:default_constructor")) {
      /* Base is default-constructible with no wrapped constructor: a single
       * factory ctor plus default/copy ctors to satisfy any lang.cxx-generated
       * _wrap_new_X() / _wrap_new_X(const BaseClass&) references.  The default and
       * copy objects have swig_self=nullptr and are not usable from Swift (Swift
       * creates directors exclusively via _wrap_new_SwigDirector_X). */
      Printf(f_directors, "  explicit %s(void *s, %s cbs)\n", director_classname, director_cb_struct_name);
      Printf(f_directors, "      : swig_self(s), swig_callbacks(cbs) {}\n");
      Printf(f_directors, "  %s() : %s(), swig_self(nullptr), swig_callbacks({}) {}\n", director_classname, cname);
      Printf(f_directors, "  %s(const %s&) : %s(), swig_self(nullptr), swig_callbacks({}) {}\n", director_classname, cname, cname);
    }
    Printf(f_directors, "  virtual ~%s() {}\n", director_classname);
    Printv(f_directors, director_cpp_methods, NIL);
    /* allprotected mode: "using Base::member;" lines exposing protected members,
     * written to the "director_h" handle by lang.cxx before this call.  They are
     * only legal inside the class body, so splice them in here, then clear the
     * buffer for the next director class. */
    if (Len(director_using_code) > 0) {
      Printv(f_directors, director_using_code, NIL);
      Clear(director_using_code);
    }
    Printf(f_directors, "};\n\n");

    /* ---- f_wrappers: extern "C" factory function (inside extern "C" block) */
    /* When the class uses %shared_ptr, return a heap-allocated shared_ptr so that
     * the Swift-side swigCPtr holds a shared_ptr<T>* as expected by all shared_ptr
     * typemaps (e.g. _wrap_GlobalFileAccess__SwigSet). */
    if (Len(director_cpp_ctors) == 0 && Getattr(n, "allocate:default_constructor")) {
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
    Delete(director_cpp_ctors);
    director_cpp_ctors = NULL;
    Delete(director_factory_decls);
    director_factory_decls = NULL;
    Delete(director_method_count);
    director_method_count = NULL;
    Delete(cname);

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
    /* Mark this class as processed in this run, so override detection can tell a
     * same-module superclass (authoritative: no recorded init => not inherited)
     * from a cross-module %import base we never saw. */
    if (Getattr(n, "sym:name"))
      Setattr(class_processed, Getattr(n, "sym:name"), "1");
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
     * A base of a director must also be open, since Swift forbids an 'open'
     * subclass of a non-open class (recorded by the collectDirectorBases
     * pre-pass).  Swift's 'open' already implies public access, so we use it
     * instead of the class_mods modifier (which is 'public' from the
     * swiftclassmodifiers typemap). */
    bool needs_open = director_flag || Getattr(director_base_classes, cn);
    if (needs_open) {
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
      if (Len(director_swift_inits) > 0) {
        /* One init(...) per wrapped base constructor (emitDirectorConstructor).
         * Each calls swigDirectorCallbacks() to build the callback struct; emit
         * that helper here, where the dispatch functions are known. */
        Printf(proxy_class_code, "    private func swigDirectorCallbacks() -> %s {\n", director_cb_struct_name);
        /* 'var' only when there are callback fields to assign; a director with
         * no dispatched methods leaves cbs unmutated (Swift warns on var then). */
        Printf(proxy_class_code, "        %s cbs = %s()\n", Len(director_swift_init_cb) > 0 ? "var" : "let", director_cb_struct_name);
        Printv(proxy_class_code, director_swift_init_cb, NIL);
        Printf(proxy_class_code, "        return cbs\n");
        Printf(proxy_class_code, "    }\n");
        Printv(proxy_class_code, director_swift_inits, NIL);
      } else if (Getattr(n, "allocate:default_constructor")) {
        /* No wrapped constructor: a single argument-less init via the default
         * factory (base must be default-constructible). */
        Printf(proxy_class_code, "    public init() throws {\n");
        Printf(proxy_class_code, "        %s cbs = %s()\n", Len(director_swift_init_cb) > 0 ? "var" : "let", director_cb_struct_name);
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
      }
      /* else: base is not default-constructible and no constructor is wrapped
       * (all %ignore'd) - the director is abstract, so emit no Swift init. */
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

    /* ----- User-supplied extra class code (swiftcode typemap) ------------- */
    /* Mirrors cscode/javacode: injected verbatim into the class body, e.g. to
     * declare a stored property that swiftconstruct assigns.  No default. */
    {
      String *swiftcode = NewString(typemapLookup(n, "swiftcode", typemap_lookup_type, WARN_NONE));
      if (Len(swiftcode) > 0) {
        Replaceall(swiftcode, "$swiftclassname", cn);
        Replaceall(swiftcode, "$module", moduleName());
        Printv(proxy_class_code, "\n", swiftcode, NIL);
      }
      Delete(swiftcode);
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
      Delete(director_swift_inits);
      director_swift_inits = NULL;
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

  /* Record a method's Swift signature (name#labelkey) for the given proxy class,
   * so a derived class can tell whether it is shadowing/overriding it. */
  void recordGeneratedMethod(const String *class_sym, const String *key) {
    String *current = Getattr(class_generated_methods, class_sym);
    if (!current) {
      Setattr(class_generated_methods, class_sym, key);
    } else {
      String *merged = NewStringf("%s|%s", current, key);
      Setattr(class_generated_methods, class_sym, merged);
      Delete(merged);
    }
  }

  /* Was the Swift superclass (first non-ignored base) processed in this run?
   * If so, its emitted methods/inits are recorded, so a missing signature match
   * is authoritative (rather than a cross-module base we never saw). */
  bool swiftSuperclassProcessed(Node *cls) {
    List *bases = Getattr(cls, "bases");
    if (!bases)
      return false;
    for (Iterator b = First(bases); b.item; b = Next(b)) {
      if (GetFlag(b.item, "feature:ignore"))
        continue;
      String *bsym = Getattr(b.item, "sym:name");
      if (!bsym)
        return false;
      return (Getattr(class_processed, bsym) != NULL);
    }
    return false;
  }

  /* Does any ancestor proxy class expose a method with this Swift signature?
   * Swift requires 'override' on a member that shadows one from a superclass,
   * even a non-virtual one, which the C++ "override" attribute does not capture. */
  bool ancestorHasGeneratedMethodWith(Node *cls, const String *key, bool recurse = true) {
    List *bases = Getattr(cls, "bases");
    if (!bases)
      return false;
    /* Swift is single-inheritance: only the first non-ignored base becomes the
     * superclass, so follow just that chain (a method in a second, dropped base
     * is not overridable from Swift).  recurse=false checks only the direct
     * superclass: used for initializers, which - unlike methods - are not
     * inherited down the chain because every proxy declares a designated
     * init(_:_:), disabling Swift's automatic initializer inheritance. */
    for (Iterator b = First(bases); b.item; b = Next(b)) {
      if (GetFlag(b.item, "feature:ignore"))
        continue;
      String *bsym = Getattr(b.item, "sym:name");
      if (!bsym)
        return false; /* first base not wrapped => no Swift superclass */
      String *recorded = Getattr(class_generated_methods, bsym);
      if (recorded) {
        String *target = NewStringf("|%s|", key);
        String *padded = NewStringf("|%s|", recorded);
        bool found = (Strstr(padded, target) != NULL);
        Delete(target);
        Delete(padded);
        if (found)
          return true;
      }
      return recurse ? ancestorHasGeneratedMethodWith(b.item, key, true) : false;
    }
    return false;
  }

  /* =========================================================================
   * emitDirectorConstructor() – for one wrapped base constructor of a director
   * class, emit a C++ forwarding ctor (into director_cpp_ctors), an extern "C"
   * factory (into f_wrappers + a bridging-header decl), and a Swift init(...)
   * (into director_swift_inits).  This lets a director subclass a C++ base with
   * no default constructor: the base ctor arguments are threaded through the
   * factory alongside the Swift self pointer and the callback struct.
   *
   * Called from classDirectorConstructors (the director pass), which runs before
   * constructorHandler, so the Swift parameter / C argument lists are built here
   * from the raw parms rather than reused from constructorHandler.
   * ========================================================================= */
  void emitDirectorConstructor(Node *n, bool has_base) {
    ParmList *l = Getattr(n, "parms");
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("ctype", l, NULL);
    Swig_typemap_attach_parms("imtype", l, NULL);
    Swig_typemap_attach_parms("swifttype", l, NULL);
    Swig_typemap_attach_parms("swiftin", l, NULL);

    /* SwigType_namestr converts SWIG's template notation ("Foo<(int)>") to valid
     * C++ ("Foo< int >") for the base-class initializer; idempotent otherwise. */
    String *cname = SwigType_namestr(Getattr(Swig_methodclass(n), "name"));
    String *overname = Getattr(n, "sym:overname");
    String *factory = NewStringf("_wrap_new_%s%s", director_classname, overname ? overname : "");

    /* Single pass building, per parameter:
     * - swift_params / c_args : the Swift init signature and the C call args
     * - ctype_params          : the factory/ctor C-ABI parameter signature
     * - base_args             : C->C++ conversion for the base ctor call
     * - call_args             : plain arg names forwarded factory -> ctor */
    String *swift_params = NewString("");
    String *c_args = NewString("");
    String *ctype_params = NewString("");
    String *base_args = NewString("");
    String *call_args = NewString("");
    int num_args = emit_num_arguments(l);
    Parm *p = l;
    int idx = 0, comma = 0;
    String *tm;
    for (int i = 0; i < num_args; i++) {
      while (checkAttribute(p, "tmap:in:numinputs", "0"))
        p = Getattr(p, "tmap:in:next");
      idx++;
      SwigType *pt = Getattr(p, "type");
      String *pname = Getattr(p, "name");
      String *lname = Getattr(p, "lname");
      String *aname = NewStringf("a%d", idx);

      /* Swift init parameter name + type */
      String *swift_arg_name;
      if (pname && Len(pname) > 0)
        swift_arg_name = Copy(pname);
      else if (lname && Len(lname) > 0)
        swift_arg_name = Copy(lname);
      else
        swift_arg_name = NewStringf("arg%d", idx);
      swift_arg_name = swiftEscapeIdentifier(swift_arg_name);

      String *swift_param_type = NewString("");
      if ((tm = Getattr(p, "tmap:swifttype"))) {
        Printv(swift_param_type, tm, NIL);
        if (Strstr(swift_param_type, "$swiftclassname")) {
          String *pcn = swiftClassNameFor(Getattr(p, "type"));
          Replaceall(swift_param_type, "$swiftclassname", pcn);
          Delete(pcn);
        }
        Replaceall(swift_param_type, "$module", moduleName());
      } else {
        Printv(swift_param_type, "/* UNKNOWN */", NIL);
      }

      String *swiftin_tm = NewString("");
      if ((tm = Getattr(p, "tmap:swiftin"))) {
        Printv(swiftin_tm, tm, NIL);
        Replaceall(swiftin_tm, "$swiftinput", swift_arg_name);
        if (Strstr(swiftin_tm, "$swiftclassname")) {
          String *pcn = swiftClassNameFor(Getattr(p, "type"));
          Replaceall(swiftin_tm, "$swiftclassname", pcn);
          Delete(pcn);
        }
        Replaceall(swiftin_tm, "$module", moduleName());
      } else {
        Printv(swiftin_tm, swift_arg_name, NIL);
      }

      /* ctype param + C->C++ conversion for the base ctor call */
      String *ct = Getattr(p, "tmap:ctype") ? Copy(Getattr(p, "tmap:ctype")) : NewString("void *");
      String *conv;
      if (Strcmp(ct, "void *") == 0) {
        if (SwigType_ispointer(pt)) {
          String *ts = SwigType_str(pt, 0);
          conv = NewStringf("(%s)%s", ts, aname);
          Delete(ts);
        } else {
          SwigType *bare = Copy(pt);
          if (SwigType_isreference(bare))
            SwigType_del_reference(bare);
          if (SwigType_isqualifier(bare))
            SwigType_del_qualifier(bare);
          String *ts = SwigType_str(bare, 0);
          conv = NewStringf("*(%s *)%s", ts, aname);
          Delete(ts);
          Delete(bare);
        }
      } else if (Strcmp(ct, "const char *") == 0 && !SwigType_ispointer(pt)) {
        conv = NewStringf("std::string(%s)", aname);
      } else if (swiftTypeIsEnum(pt)) {
        /* Enum ctor param: the C ABI is int; cast back to the enum type for the
         * base-class constructor call (a scoped enum has no implicit conversion). */
        String *ts = SwigType_str(pt, 0);
        conv = NewStringf("(%s)%s", ts, aname);
        Delete(ts);
      } else {
        conv = Copy(aname);
      }

      if (comma) {
        Printf(swift_params, ", ");
        Printf(c_args, ", ");
        Printf(ctype_params, ", ");
        Printf(base_args, ", ");
        Printf(call_args, ", ");
      }
      Printf(swift_params, "%s: %s", swift_arg_name, swift_param_type);
      Printv(c_args, swiftin_tm, NIL);
      Printf(ctype_params, "%s %s", ct, aname);
      Printv(base_args, conv, NIL);
      Printv(call_args, aname, NIL);
      comma = 1;

      Delete(swift_arg_name);
      Delete(swift_param_type);
      Delete(swiftin_tm);
      Delete(aname);
      Delete(conv);
      Delete(ct);
      p = Getattr(p, "tmap:in:next") ? Getattr(p, "tmap:in:next") : nextSibling(p);
    }

    const char *sep = Len(ctype_params) ? ", " : "";
    const char *csep = Len(call_args) ? ", " : "";

    /* C++ forwarding constructor (emitted inside the director class body). */
    Printf(director_cpp_ctors, "  %s(void *s, %s cbs%s%s)\n", director_classname, director_cb_struct_name, sep, ctype_params);
    Printf(director_cpp_ctors, "      : %s(%s), swig_self(s), swig_callbacks(cbs) {}\n", cname, base_args);

    /* extern "C" factory: bridging-header declaration + definition.  The
     * declaration is buffered and flushed by classDirectorEnd after the callback
     * struct typedef, since it references that struct by name. */
    String *factory_params = NewStringf("void *s, %s cbs%s%s", director_cb_struct_name, sep, ctype_params);
    Printf(director_factory_decls, "SWIGEXPORT void *%s(%s);\n", factory, factory_params);
    if (Getattr(Swig_methodclass(n), "feature:smartptr"))
      Printf(f_wrappers,
             "SWIGEXPORT void *%s(%s) {\n    return new std::shared_ptr< %s >(new %s(s, cbs%s%s));\n}\n\n",
             factory,
             factory_params,
             cname,
             director_classname,
             csep,
             call_args);
    else
      Printf(f_wrappers, "SWIGEXPORT void *%s(%s) {\n    return new %s(s, cbs%s%s);\n}\n\n", factory, factory_params, director_classname, csep, call_args);

    /* Swift init(...) that constructs the director through the factory.  The
     * callback struct is built by swigDirectorCallbacks() (emitted by classHandler
     * once the dispatch functions are known — classDirectorMethods runs after this
     * constructor pass, so director_swift_init_cb is not yet populated here). */
    /* Mark 'override' when the (direct) director superclass exposes an init with
     * the same signature; record this one for further-derived directors. */
    String *dinit_sig = NewStringf("init(%s)", swift_params);
    Node *dcls = Swig_methodclass(n);
    bool dinit_override = has_base && dcls && ancestorHasGeneratedMethodWith(dcls, dinit_sig, /*recurse=*/false);
    if (director_symname)
      recordGeneratedMethod(director_symname, dinit_sig);
    Delete(dinit_sig);
    Printf(director_swift_inits, "\n    %spublic init(%s) throws {\n", dinit_override ? "override " : "", swift_params);
    /* Initialise stored properties (or the base) before any use of self, so the
     * swigDirectorCallbacks() instance-method call below is legal. */
    if (has_base)
      Printf(director_swift_inits, "        super.init(nil, false)\n");
    else {
      Printf(director_swift_inits, "        swigCPtr = nil\n");
      Printf(director_swift_inits, "        swigCMemOwn = false\n");
    }
    Printf(director_swift_inits, "        let cbs = swigDirectorCallbacks()\n");
    Printf(director_swift_inits, "        let selfPtr = Unmanaged.passUnretained(self).toOpaque()\n");
    Printf(director_swift_inits, "        swigCPtr = %s(selfPtr, cbs%s%s)\n", factory, Len(c_args) ? ", " : "", c_args);
    Printf(director_swift_inits, "        swigCMemOwn = true\n");
    Printf(director_swift_inits, "        try swigCheckException()\n");
    Printf(director_swift_inits, "    }\n");

    Delete(factory);
    Delete(factory_params);
    Delete(swift_params);
    Delete(c_args);
    Delete(ctype_params);
    Delete(base_args);
    Delete(call_args);
    Delete(cname);
  }

  /* =========================================================================
   * constructorHandler() – generates init() for the proxy class.
   * ========================================================================= */
  virtual int constructorHandler(Node *n) {
    String *tm;
    Parm *p;
    int i;

    /* Director classes are constructed via the per-constructor factory emitted in
     * classDirectorConstructors (which builds the SwigDirector_ subclass).  Skip
     * the plain _wrap_new_Foo wrapper entirely: it is never called from Swift and
     * would not compile for an abstract or non-default-constructible base. */
    if (director_flag)
      return SWIG_OK;

    /* Let the base class call functionWrapper to get the C wrapper and attach typemaps */
    Language::constructorHandler(n);

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
        if (Strstr(swift_param_type, "$swiftclassname")) {
          String *pcn = swiftClassNameFor(Getattr(p, "type"));
          Replaceall(swift_param_type, "$swiftclassname", pcn);
          Delete(pcn);
        }
        Replaceall(swift_param_type, "$module", moduleName());
      } else {
        Printv(swift_param_type, "/* UNKNOWN */", NIL);
      }

      String *swiftin_tm = NewString("");
      if ((tm = Getattr(p, "tmap:swiftin"))) {
        Printv(swiftin_tm, tm, NIL);
        Replaceall(swiftin_tm, "$swiftinput", swift_arg_name);
        if (Strstr(swiftin_tm, "$swiftclassname")) {
          String *pcn = swiftClassNameFor(Getattr(p, "type"));
          Replaceall(swiftin_tm, "$swiftclassname", pcn);
          Delete(pcn);
        }
        Replaceall(swiftin_tm, "$module", moduleName());
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
    /* Detect whether this init overrides a superclass init.  Prefer a type-exact
     * match on the full Swift signature (a differently-typed parameter makes it a
     * distinct init, not an override); fall back to the label-based key only for a
     * cross-module (%import) base that was never processed in this run.  Use
     * getCurrentClass() for the ancestor walk since parentNode() of a %extend
     * constructor is not the class node. */
    Node *ctor_cls = getCurrentClass() ? getCurrentClass() : cls_node;
    String *init_sig = NewStringf("init(%s)", swift_params);
    bool is_override;
    if (is_class_specific_ctor || !ctor_cls || !has_base) {
      is_override = false;
    } else if (ancestorHasGeneratedMethodWith(ctor_cls, init_sig, /*recurse=*/false)) {
      is_override = true;
    } else if (swiftSuperclassProcessed(ctor_cls)) {
      is_override = false;
    } else {
      is_override = ancestorHasGeneratedInitWith(ctor_cls, init_key);
    }
    emitDoxygenComment(n, proxy_class_code, "    ");

    /* Init body comes from the swiftconstruct[_derived] typemap so a user can
     * override it (e.g. to pin a constructor argument for the object's lifetime).
     * The default typemaps in swiftswigtype.swg reproduce the standard body. */
    SwigType *cons_lookup_type = getCurrentClass() ? Getattr(getCurrentClass(), "classtypeobj") : 0;
    String *construct_tm = NewString(typemapLookup(n, has_base ? "swiftconstruct_derived" : "swiftconstruct", cons_lookup_type, WARN_NONE));
    String *imcall = NewStringf("%s(%s)", wname, c_args);
    Replaceall(construct_tm, "$imcall", imcall);
    Replaceall(construct_tm, "$module", moduleName());
    Printf(proxy_class_code, "\n    %spublic init(%s) throws %s\n", is_override ? "override " : "", swift_params, construct_tm);
    Delete(imcall);
    Delete(construct_tm);

    /* Record this init so derived classes can detect needed "override": the
     * type-exact signature for same-module matching and the label key for the
     * cross-module path. */
    if (proxy_class_name) {
      recordGeneratedInit(proxy_class_name, init_key);
      recordGeneratedMethod(proxy_class_name, init_sig);
    }

    Delete(init_sig);
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
        enum_display_name = swiftKeywordEscape(symname); /* e.g. an enum named `repeat` */

      /* Target: module-level code or nested in the current class */
      String *constants_dest = is_wrapping_class() ? proxy_class_constants_code : swift_module_code;

      /* Decide the representation.  A native Swift `enum X: Int32` needs unique,
       * compile-time raw values; C/C++ enums may repeat a value (e.g. several
       * enumerators all equal to 10) or use constant expressions.  SWIG evaluates
       * each enumerator to `enumnumval`, so when those are all present and unique
       * we emit a native enum, otherwise a struct with static-let members (which
       * allow duplicate values).  Both expose `rawValue` and `init?(rawValue:)`,
       * so the enum typemaps work unchanged for either form. */
      /* An enum with no wrappable cases (forward-declared, defined in %{ } or
       * fully %ignore'd) cannot be a native Swift enum - an empty enum is not
       * constructible, so `X(rawValue:)!` in the enum typemaps would not compile.
       * Emit the rawValue struct form, which is constructible from any Int32. */
      enum_as_struct = enumHasDuplicateValues(n) || enumHasNoWrappableItems(n) || enumHasUnresolvedValues(n);
      enum_type_name = Copy(enum_display_name);
      enum_next_value = 0; /* C enumerators start at 0 unless initialised */
      enum_value_known = true;

      enum_code = NewString("");
      emitDoxygenComment(n, enum_code, is_wrapping_class() ? "    " : 0);
      if (enum_as_struct) {
        Printf(enum_code, "\npublic struct %s: Equatable {\n", enum_display_name);
        Printf(enum_code, "    public let rawValue: Int32\n");
        Printf(enum_code, "    public init?(rawValue: Int32) { self.rawValue = rawValue }\n");
      } else {
        Printf(enum_code, "\npublic enum %s: Int32 {\n", enum_display_name);
      }
      Delete(enum_display_name);

      Language::enumDeclaration(n);

      Printf(enum_code, "}\n");

      /* A forward-declared / opaque / fully-ignored native enum yields no cases;
       * Swift forbids a raw type on an empty enum, so drop the ": Int32". */
      if (!enum_as_struct && !Strstr(enum_code, "\n    case ") && !Strstr(enum_code, "\n        case "))
        Replaceall(enum_code, ": Int32 {", " {");

      Printv(constants_dest, enum_code, NIL);
      Delete(enum_code);
      enum_code = NULL;
      Delete(enum_type_name);
      enum_type_name = NULL;
      enum_as_struct = false;
    }
    return SWIG_OK;
  }

  /* True when an enum has no non-ignored enumerators (a forward declaration, an
   * enum defined only inside %{ }, or one whose items are all %ignore'd). */
  bool enumHasNoWrappableItems(Node *n) {
    for (Node *c = firstChild(n); c; c = nextSibling(c)) {
      if (Equal(nodeType(c), "enumitem") && !GetFlag(c, "feature:ignore"))
        return false;
    }
    return true;
  }

  /* True when a (non-ignored) enumerator has an explicit initialiser that SWIG
   * could not fold to a literal (enumvalue set but no enumnumval), e.g. one
   * defined as another enumerator `A = B`.  A native Swift enum would then
   * auto-increment such a case to the wrong value (and possibly collide with a
   * later explicit one), so the struct form is used instead, where a case can
   * reference its sibling.  Implicit enumerators (no initialiser) carry
   * enumvalueex, not enumvalue, and auto-increment correctly - they are fine. */
  bool enumHasUnresolvedValues(Node *n) {
    for (Node *c = firstChild(n); c; c = nextSibling(c)) {
      if (!Equal(nodeType(c), "enumitem") || GetFlag(c, "feature:ignore"))
        continue;
      if (Getattr(c, "enumvalue") && !Getattr(c, "enumnumval"))
        return true;
    }
    return false;
  }

  /* Find a sibling enumerator (by C name) of the given enumitem, for aliases
   * like `A = B`; returns NULL when the value is not a plain sibling name. */
  Node *enumSiblingNamed(Node *item, String *cname) {
    if (!cname)
      return NULL;
    Node *e = parentNode(item);
    if (!e)
      return NULL;
    for (Node *c = firstChild(e); c; c = nextSibling(c)) {
      if (c == item || !Equal(nodeType(c), "enumitem"))
        continue;
      if (Equal(Getattr(c, "name"), cname) || Equal(Getattr(c, "sym:name"), cname))
        return c;
    }
    return NULL;
  }

  /* True when two (non-ignored) enumerators share the same evaluated value, which
   * a native Swift enum cannot represent (raw values must be unique). */
  bool enumHasDuplicateValues(Node *n) {
    Hash *seen = NewHash();
    bool dup = false;
    for (Node *c = firstChild(n); c && !dup; c = nextSibling(c)) {
      if (!Equal(nodeType(c), "enumitem") || GetFlag(c, "feature:ignore"))
        continue;
      String *numval = Getattr(c, "enumnumval");
      if (!numval)
        continue;
      if (Getattr(seen, numval))
        dup = true;
      else
        Setattr(seen, numval, "1");
    }
    Delete(seen);
    return dup;
  }

  /* =========================================================================
   * enumvalueDeclaration() – generates one Swift enum case.
   * ========================================================================= */
  virtual int enumvalueDeclaration(Node *n) {
    if (!ImportMode && enum_code) {
      String *symname = Getattr(n, "sym:name");
      /* SWIG evaluates each enumerator to a plain integer in "enumnumval"
       * (e.g. "(mytype0)10" -> "10"), which is the only form usable as a Swift
       * raw value; the raw "enumvalue" holds the original C++ expression. */
      String *numval = Getattr(n, "enumnumval");

      emitDoxygenComment(n, enum_code, "    ", /*nextLeadsNewline=*/false);

      if (enum_as_struct) {
        /* Struct fallback: static-let members allow duplicate values.  Track the
         * C auto-increment value so implicit members (which carry no enumnumval)
         * still get their correct value, mirroring native-enum auto-increment. */
        Node *alias;
        if (numval) {
          Printf(enum_code, "    public static let %s = %s(rawValue: %s)!\n", symname, enum_type_name, numval);
          enum_next_value = strtol(Char(numval), 0, 0) + 1;
          enum_value_known = true;
        } else if ((alias = enumSiblingNamed(n, Getattr(n, "enumvalue")))) {
          /* No folded value (e.g. `A = B`, an alias of another enumerator).  A
           * static let can reference its sibling by name and inherit its value. */
          Printf(enum_code, "    public static let %s = %s\n", symname, Getattr(alias, "sym:name"));
          String *anum = Getattr(alias, "enumnumval");
          if (anum) {
            enum_next_value = strtol(Char(anum), 0, 0) + 1;
            enum_value_known = true;
          } else {
            enum_value_known = false;
          }
        } else if (!Getattr(n, "enumvalue") && enum_value_known) {
          /* Implicit member (no initialiser): use the running counter. */
          Printf(enum_code, "    public static let %s = %s(rawValue: %ld)!\n", symname, enum_type_name, enum_next_value);
          enum_next_value++;
        } else {
          /* An explicit initialiser SWIG could not fold and is not a plain alias:
           * emit a compilable placeholder and stop trusting the counter. */
          Printf(enum_code, "    public static let %s = %s(rawValue: 0)!\n", symname, enum_type_name);
          enum_value_known = false;
        }
      } else if (numval) {
        Printf(enum_code, "    case %s = %s\n", symname, numval);
      } else {
        Printf(enum_code, "    case %s\n", symname);
      }
    }
    return Language::enumvalueDeclaration(n);
  }

  /* =========================================================================
   * constantWrapper() – emits a Swift static constant or global let.
   * ========================================================================= */
  /* Integer code of a C character-literal body starting at p (the first char
   * after the opening quote), handling the escape sequences that may appear in
   * a constant expression.  strtol self-terminates at the closing quote. */
  int charLiteralCode(const char *p) {
    if (p[0] != '\\')
      return (unsigned char)p[0];
    switch (p[1]) {
    case 'n':
      return '\n';
    case 't':
      return '\t';
    case 'r':
      return '\r';
    case 'a':
      return 7;
    case 'b':
      return 8;
    case 'f':
      return 12;
    case 'v':
      return 11;
    case '\\':
      return '\\';
    case '\'':
      return '\'';
    case '"':
      return '"';
    case 'x':
      return (int)strtol(p + 2, NULL, 16);
    default:
      if (p[1] >= '0' && p[1] <= '7')
        return (int)strtol(p + 1, NULL, 8);
      return (unsigned char)p[1];
    }
  }

  /* Replace every C character literal embedded in a constant expression with its
   * integer code (Swift has no character type in an Int32 context), dropping a
   * wide/unicode prefix (L, u, U) directly before the quote.  Text outside char
   * literals is copied verbatim.  Used for expressions like 'A'+12 or ('d')<<24
   * that the whole-token char handling in swiftConstantValue does not reach. */
  String *replaceCharLiterals(String *value) {
    const char *s = Char(value);
    int n = Len(value);
    String *out = NewString("");
    int i = 0;
    while (i < n) {
      if ((s[i] == 'L' || s[i] == 'u' || s[i] == 'U') && i + 1 < n && s[i + 1] == '\'') {
        i++; /* drop wide/unicode char-literal prefix */
        continue;
      }
      if (s[i] == '\'') {
        int j = i + 1;
        if (j < n && s[j] == '\\')
          j += 2; /* skip backslash + first escape char before scanning */
        while (j < n && s[j] != '\'')
          j++;
        Printf(out, "%d", charLiteralCode(s + i + 1));
        i = (j < n) ? j + 1 : j;
        continue;
      }
      Putc(s[i], out);
      i++;
    }
    return out;
  }

  /* A C constant expression that cannot be represented as a Swift constant: it
   * contains a function-style call — the sizeof operator, a cast, or a macro
   * that did not expand (e.g. sizeof(int), cat(1,2)).  Emitting such a value
   * verbatim would produce Swift that does not compile, so the caller skips it. */
  bool constantValueRepresentable(String *value) {
    const char *s = Char(value);
    int n = Len(value);
    for (int i = 0; i < n; i++) {
      if (isalpha((unsigned char)s[i]) || s[i] == '_') {
        int j = i;
        while (j < n && (isalnum((unsigned char)s[j]) || s[j] == '_'))
          j++;
        int k = j;
        while (k < n && isspace((unsigned char)s[k]))
          k++;
        if (k < n && s[k] == '(') /* identifier followed by '(' => call/sizeof/cast */
          return false;
        i = j - 1;
      }
    }
    return true;
  }

  /* True if the constant value is a boolean-valued expression: it uses a
   * comparison or logical operator that yields int in C but Bool in Swift, so
   * it cannot be emitted as an integer Swift 'let' (Swift rejects Bool vs
   * Int32).  Bit shifts (<<, >>) are integer operators and are deliberately not
   * treated as comparisons; content inside char/string literals is skipped. */
  bool constantValueIsBoolean(String *value) {
    const char *s = Char(value);
    int n = Len(value);
    for (int i = 0; i < n; i++) {
      char c = s[i];
      if (c == '\'' || c == '"') { /* skip over a char/string literal */
        char q = c;
        for (i++; i < n && s[i] != q; i++)
          if (s[i] == '\\')
            i++;
        continue;
      }
      char nx = (i + 1 < n) ? s[i + 1] : '\0';
      if (c == '<' || c == '>') {
        if (nx == c) { /* << or >> : shift, not a comparison */
          i++;
          continue;
        }
        return true; /* < > <= >= */
      }
      if ((c == '=' || c == '!') && nx == '=') /* == or != */
        return true;
      if (c == '&' && nx == '&') /* && */
        return true;
      if (c == '|' && nx == '|') /* || */
        return true;
      if (c == '!' && nx != '=') /* unary logical not */
        return true;
    }
    return false;
  }

  /* Re-encode a C string literal (with its surrounding quotes) as a Swift string
   * literal.  C octal (\ooo), hex (\xHH) and the \a \b \f \v escapes have no
   * Swift form, so the C escapes are decoded to bytes and re-emitted: \0 \t \n
   * \r \\ \" as Swift escapes, other control bytes as \u{..}, printable ASCII
   * verbatim, and bytes >= 0x80 passed through unchanged (the Swift source is
   * UTF-8, so a multibyte UTF-8 sequence reproduces its character). */
  String *swiftStringLiteral(String *value) {
    const char *s = Char(value);
    int n = Len(value);
    if (n < 2 || s[0] != '"' || s[n - 1] != '"')
      return Copy(value);
    String *out = NewString("\"");
    for (int i = 1; i < n - 1; i++) {
      unsigned char b;
      if (s[i] == '\\' && i + 1 < n - 1) {
        char e = s[++i];
        if (e == 'x') {
          int v = 0, k = 0;
          while (i + 1 < n - 1 && isxdigit((unsigned char)s[i + 1]) && k < 2) {
            char h = s[++i];
            v = v * 16 + (h <= '9' ? h - '0' : (tolower(h) - 'a' + 10));
            k++;
          }
          b = (unsigned char)v;
        } else if (e >= '0' && e <= '7') {
          int v = e - '0', k = 1;
          while (i + 1 < n - 1 && s[i + 1] >= '0' && s[i + 1] <= '7' && k < 3) {
            v = v * 8 + (s[++i] - '0');
            k++;
          }
          b = (unsigned char)v;
        } else {
          switch (e) {
          case 'n':
            b = '\n';
            break;
          case 't':
            b = '\t';
            break;
          case 'r':
            b = '\r';
            break;
          case 'a':
            b = 7;
            break;
          case 'b':
            b = 8;
            break;
          case 'f':
            b = 12;
            break;
          case 'v':
            b = 11;
            break;
          default:
            b = (unsigned char)e;
            break; /* \\ \' \" \? and unknowns */
          }
        }
      } else {
        b = (unsigned char)s[i];
      }
      if (b == '\0')
        Printv(out, "\\0", NIL);
      else if (b == '\t')
        Printv(out, "\\t", NIL);
      else if (b == '\n')
        Printv(out, "\\n", NIL);
      else if (b == '\r')
        Printv(out, "\\r", NIL);
      else if (b == '\\')
        Printv(out, "\\\\", NIL);
      else if (b == '"')
        Printv(out, "\\\"", NIL);
      else if ((b >= 0x20 && b < 0x7F) || b >= 0x80) {
        char t[2] = {(char)b, 0};
        Printv(out, t, NIL);
      } else {
        Printf(out, "\\u{%x}", (int)b);
      }
    }
    Printv(out, "\"", NIL);
    return out;
  }

  /* Convert a C constant literal to an equivalent Swift literal.  Handles the
   * cases that otherwise emit invalid Swift: integer/float literals carrying
   * a C suffix (1234LL, 1.5f) which Swift rejects, character literals ('x',
   * '\n', '\341') which Swift has no equivalent for in an Int32 context, and
   * character literals embedded in an expression ('A'+12).  Any other value
   * (a non-char expression, a macro reference, a string) is returned unchanged. */
  String *swiftConstantValue(String *value, int tt) {
    const char *s = Char(value);
    int n = Len(value);
    if (n == 0)
      return Copy(value);

    /* Strip a single layer of surrounding parentheses (SWIG wraps some constant
     * expressions, e.g. (';') or (42)) and re-process the inner literal. */
    if (n >= 3 && s[0] == '(' && s[n - 1] == ')') {
      String *inner = NewStringWithSize((void *)(s + 1), n - 2);
      String *r = swiftConstantValue(inner, tt);
      String *wrapped = NewStringf("(%s)", r);
      Delete(inner);
      Delete(r);
      return wrapped;
    }

    /* String literal: re-encode C escapes that Swift does not accept. */
    if (s[0] == '"' && s[n - 1] == '"')
      return swiftStringLiteral(value);

    /* Character literal: translate to its integer code (Swift has no char type
     * in an Int32 context).  Covers a printable char and the common escapes. */
    if (s[0] == '\'' && s[n - 1] == '\'' && n >= 3) {
      int code;
      if (s[1] == '\\') {
        char e = s[2];
        switch (e) {
        case 'n':
          code = '\n';
          break;
        case 't':
          code = '\t';
          break;
        case 'r':
          code = '\r';
          break;
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
          code = (int)strtol(s + 2, NULL, 8);
          break; /* octal escape */
        case 'x':
          code = (int)strtol(s + 3, NULL, 16);
          break; /* hex escape */
        case '\\':
          code = '\\';
          break;
        case '\'':
          code = '\'';
          break;
        case '"':
          code = '"';
          break;
        case 'a':
          code = 7;
          break;
        case 'b':
          code = 8;
          break;
        case 'f':
          code = 12;
          break;
        case 'v':
          code = 11;
          break;
        default:
          code = (unsigned char)e;
          break;
        }
      } else {
        code = (unsigned char)s[1];
      }
      return NewStringf("%d", code);
    }

    /* Numeric literal with a C suffix: strip the trailing [uUlLfF] run, but only
     * for a clean literal (leave hex digits, expressions and macros untouched). */
    if (isdigit((unsigned char)s[0])) {
      bool hex = (n > 1 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X'));
      int i = 0;
      if (hex) {
        i = 2;
        while (i < n && isxdigit((unsigned char)s[i]))
          i++;
      } else {
        while (i < n && (isdigit((unsigned char)s[i]) || s[i] == '.' || s[i] == 'e' || s[i] == 'E' ||
                         ((s[i] == '+' || s[i] == '-') && i > 0 && (s[i - 1] == 'e' || s[i - 1] == 'E'))))
          i++;
      }
      int j = i;
      while (j < n && strchr("uUlLfF", s[j]))
        j++;
      if (i < n && j == n) /* had a suffix and nothing else trailing */
        return NewStringWithSize((void *)s, i);
    }

    /* Expression (not a plain literal): translate any embedded character
     * literals to their integer codes so it type-checks in Swift; other tokens
     * are copied unchanged. */
    if (strchr(s, '\''))
      return replaceCharLiterals(value);

    return Copy(value);
  }

  /* Value for a Swift Bool constant: map the C integer forms 0/1 to false/true;
   * true/false and boolean expressions are already valid Swift and pass through. */
  String *swiftBoolConstant(String *value) {
    if (Equal(value, "0"))
      return NewString("false");
    if (Equal(value, "1"))
      return NewString("true");
    return Copy(value);
  }

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
    int tt = SwigType_type(type);

    /* Skip constants whose value is a C construct with no Swift equivalent
     * (sizeof, a cast, or an unexpanded function-style macro): emitting it
     * verbatim would produce Swift that does not compile. */
    if (!constantValueRepresentable(value))
      return SWIG_OK;

    /* A constant whose value is a boolean expression generally does not
     * type-check in Swift: C treats int operands as booleans (1 && 0), allows
     * chained comparisons (2 < (2 < 2)) and yields int from a comparison, none
     * of which Swift accepts.  Skip such constants, as with the sizeof/cast
     * constants above; a bare true/false bool literal is kept. */
    if (constantValueIsBoolean(value) && !Equal(value, "true") && !Equal(value, "false"))
      return SWIG_OK;

    String *constants_dest = is_wrapping_class() ? proxy_class_constants_code : swift_module_code;

    /* Determine Swift type */
    String *swift_type = NewString("");
    if (tt == T_BOOL) {
      Printv(swift_type, "Bool", NIL);
    } else if (tt == T_SCHAR || tt == T_UCHAR || tt == T_SHORT || tt == T_USHORT || tt == T_INT || tt == T_UINT || tt == T_LONG || tt == T_ULONG ||
               tt == T_LONGLONG || tt == T_ULONGLONG || tt == T_CHAR) {
      Printv(swift_type, "Int32", NIL);
    } else if (tt == T_FLOAT || tt == T_DOUBLE) {
      Printv(swift_type, "Double", NIL);
    } else if (tt == T_STRING) {
      Printv(swift_type, "String", NIL);
    } else {
      Printv(swift_type, "Int32", NIL);
    }

    String *emit_value = (tt == T_BOOL) ? swiftBoolConstant(value) : swiftConstantValue(value, tt);
    if (is_wrapping_class()) {
      Printf(constants_dest, "    public static let %s: %s = %s\n", symname, swift_type, emit_value);
    } else {
      Printf(constants_dest, "\npublic let %s: %s = %s\n", symname, swift_type, emit_value);
    }

    Delete(emit_value);
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

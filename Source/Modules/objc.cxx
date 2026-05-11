#include "swigmod.h"
#include <ctype.h>
#include <string.h>

static const char *objc_wrapper_declarations = "\
#import <objc/NSObject.h>\n\
\n\
#ifdef nil\n\
#undef nil\n\
#endif\n\
#ifdef Nil\n\
#undef Nil\n\
#endif\n\
\n\
@class NSString;\n\
@class NSArray;\n\
@class NSMutableArray;\n\
@class NSData;\n\
@class NSAutoreleasePool;\n\
@class NSException;\n\
\n";

static const char *objc_proxy_declarations = "\
#import <objc/NSObject.h>\n\
\n\
#ifndef SWIG_OBJC_RUNTIME_DECLARATIONS\n\
#define SWIG_OBJC_RUNTIME_DECLARATIONS\n\
typedef unsigned long NSUInteger;\n\
typedef unsigned short unichar;\n\
struct objc_object;\n\
typedef struct objc_object *SWIGObjectiveCId;\n\
#endif\n\
\n\
@class NSString;\n\
@class NSArray;\n\
@class NSMutableArray;\n\
@class NSData;\n\
@class NSAutoreleasePool;\n\
@class NSException;\n\
\n\
#ifdef __cplusplus\n\
extern \"C\" {\n\
#endif\n\
extern void NSLog(NSString *format, ...);\n\
#ifdef __cplusplus\n\
}\n\
#endif\n\
\n";

static int objc_skip_spaces(const char *s, int pos, int end) {
  while (pos < end && isspace((unsigned char)s[pos]))
    ++pos;
  return pos;
}

static int objc_trim_end(const char *s, int start, int end) {
  while (end > start && isspace((unsigned char)s[end - 1]))
    --end;
  return end;
}

static String *objc_copy_trimmed_range(const char *s, int start, int end) {
  start = objc_skip_spaces(s, start, end);
  end = objc_trim_end(s, start, end);
  return NewStringWithSize(s + start, end - start);
}

static bool objc_identifier_start(char c) {
  return isalpha((unsigned char)c) || c == '_';
}

static bool objc_identifier_char(char c) {
  return isalnum((unsigned char)c) || c == '_';
}

static bool objc_type_name_chars(const char *s, int start, int end) {
  bool saw_identifier = false;
  for (int i = start; i < end; ++i) {
    char c = s[i];
    if (objc_identifier_start(c))
      saw_identifier = true;
    if (!(objc_identifier_char(c) || c == ':' || c == ' ' || c == '\t'))
      return false;
  }
  return saw_identifier;
}

static String *objc_selector_component_from_type(String *type_name) {
  String *component = NewString("");
  bool capitalize_next = true;

  if (type_name) {
    const char *s = Char(type_name);
    for (int i = 0; s[i]; ++i) {
      unsigned char c = (unsigned char)s[i];
      if (isalnum(c) || c == '_') {
        if (Len(component) == 0 && !isalpha(c) && c != '_')
          Printf(component, "Arg");
        Putc(capitalize_next ? toupper(c) : c, component);
        capitalize_next = false;
      } else {
        capitalize_next = true;
      }
    }
  }

  if (Len(component) == 0)
    Printf(component, "Arg");
  return component;
}

static bool objc_is_reserved_method_family_name(String *name) {
  return name && (Cmp(name, "alloc") == 0 || Cmp(name, "new") == 0 || Cmp(name, "copy") == 0 || Cmp(name, "mutableCopy") == 0 || Cmp(name, "init") == 0);
}

static String *objc_swig_method_name(String *name) {
  String *renamed = NewString("swig");
  if (name && Len(name) > 0) {
    Putc(toupper((int)*Char(name)), renamed);
    Printf(renamed, "%s", Char(name) + 1);
  } else {
    Printf(renamed, "Method");
  }
  return renamed;
}

static String *objc_cptr_method_name(String *class_name) {
  return NewStringf("swigCPtrFor%s", class_name);
}

static String *objc_cptr_ivar_name(String *class_name, bool derived) {
  return derived ? NewStringf("swigCPtr_%s", class_name) : NewString("swigCPtr");
}

static String *objc_cast_function_name(SwigType *derived_type, SwigType *base_type) {
  String *derived_mangled = SwigType_manglestr(derived_type);
  String *base_mangled = SwigType_manglestr(base_type);
  String *name = NewStringf("SWIG_ObjectiveC_cast_%s_to_%s", derived_mangled, base_mangled);
  Delete(derived_mangled);
  Delete(base_mangled);
  return name;
}

static String *objc_director_flag_name(String *method_name, String *decl) {
  String *empty = 0;
  if (!decl)
    empty = NewString("");
  String *mangled = SwigType_manglestr(decl ? decl : empty);
  String *flag = NewStringf("swig_override_%s_%s", method_name, mangled);
  Delete(empty);
  Delete(mangled);
  return flag;
}

static String *objc_sanitize_cast_value(String *value, bool strip_qualified_name) {
  if (!value)
    return NewString("");

  const char *s = Char(value);
  int len = Len(value);
  int start = objc_skip_spaces(s, 0, len);
  int end = objc_trim_end(s, start, len);

  const char *static_cast_prefix = "static_cast<";
  int static_cast_len = 12;
  if (end - start > static_cast_len && strncmp(s + start, static_cast_prefix, static_cast_len) == 0) {
    const char *gt = strchr(s + start + static_cast_len, '>');
    if (gt) {
      const char *open = strchr(gt + 1, '(');
      if (open && end > 0 && s[end - 1] == ')')
        return objc_copy_trimmed_range(s, (int)(open - s) + 1, end - 1);
    }
  }

  if (start < end && s[start] == '(') {
    int depth = 0;
    for (int i = start; i < end; ++i) {
      if (s[i] == '(')
        ++depth;
      else if (s[i] == ')') {
        --depth;
        if (depth == 0) {
          if (objc_type_name_chars(s, start + 1, i) && i + 1 < end)
            return objc_copy_trimmed_range(s, i + 1, end);
          break;
        }
      }
    }
  }

  if (start < end && objc_identifier_start(s[start])) {
    int open = start + 1;
    while (open < end && (objc_identifier_char(s[open]) || s[open] == ':' || isspace((unsigned char)s[open])))
      ++open;
    if (open < end && s[open] == '(' && end > open + 1 && s[end - 1] == ')' && objc_type_name_chars(s, start, open)) {
      int ident_end = start + 1;
      while (ident_end < end && objc_identifier_char(s[ident_end]))
        ++ident_end;
      if ((ident_end - start == 6 && strncmp(s + start, "sizeof", 6) == 0) || (ident_end - start == 7 && strncmp(s + start, "alignof", 7) == 0))
        return objc_copy_trimmed_range(s, start, end);
      return objc_copy_trimmed_range(s, open + 1, end - 1);
    }
  }

  if (strip_qualified_name) {
    const char *last_scope = 0;
    for (const char *p = s + start; p + 1 < s + end; ++p) {
      if (p[0] == ':' && p[1] == ':')
        last_scope = p;
    }
    if (last_scope)
      return objc_copy_trimmed_range(s, (int)(last_scope - s) + 2, end);
  }

  return objc_copy_trimmed_range(s, start, end);
}

static String *objc_last_qualified_component(String *value) {
  if (!value)
    return 0;

  const char *s = Char(value);
  int len = Len(value);
  int start = objc_skip_spaces(s, 0, len);
  int end = objc_trim_end(s, start, len);
  int component_start = start;
  for (int i = start; i + 1 < end; ++i) {
    if (s[i] == ':' && s[i + 1] == ':') {
      component_start = i + 2;
      ++i;
    }
  }

  if (component_start == start)
    return 0;

  int component_end = component_start;
  while (component_end < end && objc_identifier_char(s[component_end]))
    ++component_end;
  return objc_copy_trimmed_range(s, component_start, component_end);
}

static bool objc_is_plain_identifier(String *value) {
  if (!value)
    return false;

  const char *s = Char(value);
  int len = Len(value);
  int start = objc_skip_spaces(s, 0, len);
  int end = objc_trim_end(s, start, len);
  if (start >= end || !objc_identifier_start(s[start]))
    return false;
  for (int i = start + 1; i < end; ++i) {
    if (!objc_identifier_char(s[i]))
      return false;
  }
  return true;
}

class OBJECTIVEC : public Language {
private:
  /* Files and file sections containing generated code. */
  File *f_wrap_h;    // Wrapper header file
  File *f_wrap_mm;   // Wrapper source file
  File *f_proxy_h;   // Proxy header file
  File *f_proxy_mm;  // Proxy source file
  File *f_runtime;
  File *f_header; /* General DOH objects used for holding the sections of wrapper source */
  File *f_wrappers;
  File *f_init;

  /* Strings temporarily holding the generated C++ code. */
  String *wrap_h_code;                // Code to be written in wrap_h.
  String *wrap_mm_code;               // Code to be written in wrap_mm.
  String *director_h_code;            // C++ director class declarations.
  String *director_mm_code;           // C++ director class definitions.
  String *proxy_h_code;               // Code to be written in proxy_h.
  String *proxy_mm_code;              // Code to be written in proxy_mm.
  String *proxy_imports;              // Proxy header imports required by %imported modules.
  String *proxy_enums_code;           // Objective-C enum declarations emitted before declarations that may use them.
  String *swigtypes_h_code;           // Code for Objective-C typewrapper classes header.
  String *swigtypes_mm_code;          // Code for Objective-C typewrapper classes implementation.
  String *proxy_class_forward_decls;  // Forward declarations for Objective-C proxy classes.

  /* Various flags controlling the code generation. */
  bool proxy_flag;  // flag: determine should the proxy files be generated or not

  /* State variables which indicate what is being wrapped at the moment. */
  bool member_variable_flag;         // flag: wrapping member variables
  bool static_member_variable_flag;  // flag: wrapping static member variables
  bool global_variable_flag;         // flag: wrapping global variables
  bool global_func_flag;             // flag: wrapping global functions
  bool static_member_func_flag;      // flag: wrapping static member functions
  bool member_func_flag;             // flag: wrapping member functions
  bool member_constant_flag;         // flag: wrapping member constants

  /* Helper strings used in the code */
  String *variable_name;  // String representing the current variable name.
  String *proxyfuncname;  // String representing the current memberfunction name.

  /* ObjectiveC data for the current proxy class:
   * These strings are mainly used to temporarily accumulate code from the
   * various member handling functions while a single class is processed and are
   * no longer relevant once that class has been finished, i.e. after
   * classHandler() has returned. */
  String *proxy_class_name;   // The unqualified name of the current proxy class.
  String *proxy_class_qname;  // The name of the current proxy class, qualified with the name of the namespace it is in, if any.
  // Objective-C proxy declarations use the unqualified symbol name, matching
  // the other single-inheritance proxy backends.

  String *proxy_class_decl_code;  // The proxy class declaration code.This goes in the proxy_h file if proxy_flag is true.
  String *proxy_class_defn_code;  // The proxy class definition code.This goes in the proxy_mm file if proxy_flag is true.
  String *proxy_class_imports;    // The import directives for the current proxy class. This goes in the proxy_h file if proxy_flag is true.

  String *proxy_class_enums_code;  // Code for enumerations nested in the current proxy class. Is emitted globally and earlier
  // than the rest of the body to work around forward referencing-issues.

  String *proxy_class_function_decls;   // Code for the proxy class member functions declaration.
  String *proxy_class_function_defns;   // Code for the proxy class member functions definition.
  Hash *proxy_class_selectors;          // Objective-C selectors already emitted for the current proxy class.
  String *proxy_global_function_decls;  // Code for the proxy class member functions declaration.
  String *proxy_global_function_defns;  // Code for the proxy class member functions definition.
  String *destrcutor_call;              // Contains an ObjectiveC call to the function wrapping the C++  destructor of the
  // current class (if there is a public C++ destructor).

  /* SWIG types data: Collects information about encountered types SWIG does not know about (e.g.
   * incomplete types). This is used later to generate type wrapper proxy.
   * classes for the unknown types. */
  Hash *unknown_types;
  Hash *proxy_imported_modules;
  Hash *proxy_constant_names;
  Hash *proxy_enum_constant_names;
  String *director_connect_code;

  /* Strings used at different places in the code. */
  static const char *const usage;  // Usage message
  const String *empty_string;      // Empty string used at different places in the code

public:
  OBJECTIVEC() :
    f_wrap_h(NULL),
    f_wrap_mm(NULL),
    f_proxy_h(NULL),
    f_proxy_mm(NULL),
    f_runtime(NULL),
    f_header(NULL),
    f_wrappers(NULL),
    f_init(NULL),
    wrap_h_code(NULL),
    wrap_mm_code(NULL),
    director_h_code(NULL),
    director_mm_code(NULL),
    proxy_h_code(NULL),
    proxy_mm_code(NULL),
    proxy_imports(NULL),
    proxy_enums_code(NULL),
    swigtypes_h_code(NULL),
    swigtypes_mm_code(NULL),
    proxy_class_forward_decls(NULL),
    proxy_flag(true),
    member_variable_flag(false),
    static_member_variable_flag(false),
    global_variable_flag(false),
    global_func_flag(false),
    static_member_func_flag(false),
    member_func_flag(false),
    member_constant_flag(false),
    variable_name(NULL),
    proxyfuncname(NULL),
    proxy_class_name(NULL),
    proxy_class_qname(NULL),
    proxy_class_decl_code(NULL),
    proxy_class_defn_code(NULL),
    proxy_class_imports(NULL),
    proxy_class_enums_code(NULL),
    proxy_class_function_decls(NULL),
    proxy_class_function_defns(NULL),
    proxy_class_selectors(NULL),
    proxy_global_function_decls(NULL),
    proxy_global_function_defns(NULL),
    destrcutor_call(NULL),
    unknown_types(NULL),
    proxy_imported_modules(NULL),
    proxy_constant_names(NULL),
    proxy_enum_constant_names(NULL),
    director_connect_code(NULL),
    empty_string(NewString("")) {
  }
  virtual void main(int argc, char *argv[]);
  virtual int top(Node *n);
  virtual int importDirective(Node *n);

  /* Function handlers */
  virtual int functionHandler(Node *n);
  virtual int globalfunctionHandler(Node *n);
  virtual int memberfunctionHandler(Node *n);
  virtual int staticmemberfunctionHandler(Node *n);
  virtual int callbackfunctionHandler(Node *n);

  /* Variable handlers */
  virtual int variableHandler(Node *n);
  virtual int globalvariableHandler(Node *n);
  virtual int membervariableHandler(Node *n);
  virtual int staticmembervariableHandler(Node *n);

  /* C++ handlers */
  virtual int memberconstantHandler(Node *n);
  virtual int constructorHandler(Node *n);
  virtual int copyconstructorHandler(Node *n);
  virtual int destructorHandler(Node *n);
  virtual int classHandler(Node *n);
  virtual int classDirectorInit(Node *n);
  virtual int classDirectorConstructor(Node *n);
  virtual int classDirectorDefaultConstructor(Node *n);
  virtual int classDirectorMethod(Node *n, Node *parent, String *super);
  virtual int classDirectorEnd(Node *n);
  virtual int classDirectorDisown(Node *n);

  /* C/C++ Parsing */
  virtual int enumDeclaration(Node *n);
  virtual int enumvalueDeclaration(Node *n);

  /* Low-level code generation */
  virtual int constantWrapper(Node *n);
  virtual int variableWrapper(Node *n);
  virtual int functionWrapper(Node *n);
  virtual int nativeWrapper(Node *n);

  /* Proxy class code generators */
  void emitProxyGlobalFunctions(Node *n);
  void emitProxyClassFunction(Node *n);
  void emitProxyClassConstructor(Node *n);
  void emitProxyClass(Node *n);
  void emitTypeWrapperClass(String *classname, SwigType *type);

  /* Helper functions */
  bool substituteClassname(String *tm, SwigType *pt);
  void substituteClassnameVariable(String *tm, const char *classnamevariable, SwigType *type);
  String *proxyEnumValue(String *value);
  String *proxyConstantValue(String *value);
  String *proxyConstantExpression(String *value);
  bool proxyConstantExpressionNeedsAccessor(String *value);
  String *objcStringLiteral(String *value);
  String *objcSelectorForMethod(Node *n, ParmList *parmlist);
  void objcDirectorPrefixArgs(Node *n);
  String *objcDirectorConnectWrapperName(Node *n);
  bool isVarargs(Parm *p) const;
  Parm *skipIgnoredArgs(Parm *p);
  Parm *nextInputArg(Parm *p) const;
  void marshalInputArgs(ParmList *parmlist, Wrapper *wrapper);
  void makeParameterList(ParmList *parmlist, Wrapper *wrapper);
  String *makeParameterName(Node *n, Parm *p, int arg_num, bool setter) const;
  void marshalOutput(Node *n, String *actioncode, Wrapper *wrapper);
  String *createProxyName(SwigType *t);
  const String *typemapLookup(Node *n, const_String_or_char_ptr tmap_method, SwigType *type, int warning, Node *typemap_attributes = 0);
};

/* ---------------------------------------------------------------------
 * main()
 *
 * Entry point for the Objective-C module.
 * --------------------------------------------------------------------- */

void OBJECTIVEC::main(int argc, char *argv[]) {
  // Set language-specific subdirectory in SWIG library
  SWIG_library_directory("objc");
  directorLanguage();

  // Process command line options
  for (int i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i], "-noproxy") == 0) {
        Swig_mark_arg(i);
        proxy_flag = false;
      } else if (strcmp(argv[i], "-help") == 0) {
        Printf(stdout, "%s\n", usage);
      }
    }
  }

  // Set language-specific preprocessing symbol
  Preprocessor_define("SWIGOBJECTIVEC 1", 0);

  // Set language-specific configuration file
  SWIG_config_file("objc.swg");
}

/* ---------------------------------------------------------------------
 * top()
 *
 * Function handler for processing top node of the parse tree
 * Wrapper code generation starts from here.
 * --------------------------------------------------------------------- */

int OBJECTIVEC::top(Node *n) {
  /* Get the module name */
  String *module = Getattr(n, "name");
  Node *optionsnode = Getattr(Getattr(n, "module"), "options");
  if (optionsnode && Getattr(optionsnode, "directors"))
    allow_directors();

  /* Initialize I/O */

  // Create the _wrap files
  String *wrapfile_h = NewStringf("%s_wrap.h", module);
  f_wrap_h = NewFile(wrapfile_h, "w", SWIG_output_files());
  if (!f_wrap_h) {
    FileErrorDisplay(wrapfile_h);
    Exit(EXIT_FAILURE);
  }
  String *wrapfile_mm = NewStringf("%s_wrap.mm", module);
  f_wrap_mm = NewFile(wrapfile_mm, "w", SWIG_output_files());
  if (!f_wrap_mm) {
    FileErrorDisplay(wrapfile_mm);
    Exit(EXIT_FAILURE);
  }
  Delete(wrapfile_h);
  Delete(wrapfile_mm);

  // Create the _proxy files if proxy flag is true
  if (proxy_flag) {
    String *proxyfile_h = NewStringf("%s_proxy.h", module);
    f_proxy_h = NewFile(proxyfile_h, "w", SWIG_output_files());
    if (!f_proxy_h) {
      FileErrorDisplay(proxyfile_h);
      Exit(EXIT_FAILURE);
    }
    String *proxyfile_mm = NewStringf("%s_proxy.mm", module);
    f_proxy_mm = NewFile(proxyfile_mm, "w", SWIG_output_files());
    if (!f_proxy_mm) {
      FileErrorDisplay(proxyfile_mm);
      Exit(EXIT_FAILURE);
    }
    Delete(proxyfile_h);
    Delete(proxyfile_mm);
  }

  f_runtime = NewString("");
  Swig_obligatory_macros(f_runtime, "OBJECTIVEC");
  f_init = NewString("");
  f_header = NewString("");
  f_wrappers = NewString("");

  // Register file targets with the SWIG file handler
  Swig_register_filebyname("begin", f_wrap_mm);
  Swig_register_filebyname("header", f_header);
  Swig_register_filebyname("wrapper", f_wrappers);
  Swig_register_filebyname("runtime", f_runtime);
  Swig_register_filebyname("init", f_init);
  if (Swig_directors_enabled())
    Printf(f_runtime, "#define SWIG_DIRECTORS\n");

  // Output module initialization code
  Swig_banner(f_wrap_h);
  Printf(f_wrap_h, "\n");
  Printf(f_wrap_h, "%s", objc_wrapper_declarations);
  Printf(f_wrap_h, "#ifndef %(upper)s_WRAP_H\n", module);
  Printf(f_wrap_h, "#define %(upper)s_WRAP_H\n\n", module);
  Printf(f_wrap_h, "\n#ifdef __cplusplus\n");
  Printf(f_wrap_h, "extern \"C\" {\n");
  Printf(f_wrap_h, "#endif\n\n");

  Swig_banner(f_wrap_mm);
  Printf(f_header, "#include \"%s_wrap.h\"\n", module);

  if (proxy_flag) {
    Swig_banner(f_proxy_h);
    Printf(f_proxy_h, "\n%s", objc_proxy_declarations);

    Swig_banner(f_proxy_mm);
    Printf(f_proxy_mm, "#include \"%s_proxy.h\"\n", module);
    Printf(f_proxy_mm, "#include \"%s_wrap.h\"\n\n", module);
  }
  // Create strings for holding the generated code. These will be dumped
  // to the generated files at the end of the top function.
  wrap_h_code = NewString("");
  wrap_mm_code = NewString("");
  director_h_code = NewString("");
  director_mm_code = NewString("");
  Swig_register_filebyname("director", director_mm_code);
  Swig_register_filebyname("director_h", director_h_code);
  if (proxy_flag) {
    proxy_h_code = NewString("");
    proxy_mm_code = NewString("");
    proxy_imports = NewString("");
    proxy_enums_code = NewString("");
    swigtypes_h_code = NewString("");
    swigtypes_mm_code = NewString("");
    proxy_class_forward_decls = NewString("");

    proxy_class_decl_code = NewString("");
    proxy_class_defn_code = NewString("");
    proxy_class_enums_code = NewString("");
    proxy_class_function_decls = NewString("");
    proxy_class_function_defns = NewString("");
    proxy_class_selectors = NewHash();
    proxy_global_function_decls = NewString("");
    proxy_global_function_defns = NewString("");
    proxy_class_imports = NewString("");

    destrcutor_call = NewString("");
    unknown_types = NewHash();
    proxy_imported_modules = NewHash();
    proxy_constant_names = NewHash();
    proxy_enum_constant_names = NewHash();
  }

  /* Emit code for children */
  Language::top(n);

  Swig_insert_file("swigrun.swg", f_runtime);

  /* Emit the SWIG runtime type table used by $descriptor, $mangle and dynamic casts. */
  SwigType_emit_type_table(f_runtime, f_wrappers);

  // Write to the wrap_h
  Dump(wrap_h_code, f_wrap_h);
  Printf(f_wrap_h, "\n#ifdef __cplusplus\n");
  Printf(f_wrap_h, "}\n");
  Printf(f_wrap_h, "#endif\n");
  if (Len(director_h_code)) {
    Printf(f_wrap_h, "\n#ifdef __cplusplus\n");
    Dump(director_h_code, f_wrap_h);
    Printf(f_wrap_h, "#endif\n");
  }
  Printf(f_wrap_h, "\n#endif\n\n");

  // Write to the wrap_mm
  Dump(f_runtime, f_wrap_mm);
  Dump(f_header, f_wrap_mm);
  Printf(f_wrap_mm, "\n#ifdef __cplusplus\n");
  Printf(f_wrap_mm, "extern \"C\" {\n");
  Printf(f_wrap_mm, "#endif\n\n");
  Dump(f_wrappers, f_wrap_mm);
  Dump(wrap_mm_code, f_wrap_mm);
  if (Len(f_init)) {
    String *init_func = NewString("");
    Printf(init_func, "static void SWIG_ObjectiveC_%s_Init(void) {\n", module);
    Printv(init_func, f_init, NIL);
    Printf(init_func, "}\n");
    Printf(init_func, "#if defined(__GNUC__)\n");
    Printf(init_func, "__attribute__((constructor))\n");
    Printf(init_func, "#endif\n");
    Printf(init_func, "static void SWIG_ObjectiveC_%s_AutoInit(void) {\n", module);
    Printf(init_func, "SWIG_ObjectiveC_%s_Init();\n", module);
    Printf(init_func, "}\n");
    Wrapper_pretty_print(init_func, f_wrap_mm);
    Delete(init_func);
  }
  Printf(f_wrap_mm, "\n#ifdef __cplusplus\n");
  Printf(f_wrap_mm, "}\n");
  Printf(f_wrap_mm, "#endif\n");
  if (Len(director_mm_code)) {
    Printf(f_wrap_mm, "\n#ifdef __cplusplus\n");
    Dump(director_mm_code, f_wrap_mm);
    Printf(f_wrap_mm, "#endif\n");
  }

  // Write to the proxy.h, if required
  if (proxy_flag) {

    for (Iterator swig_type = First(unknown_types); swig_type.key; swig_type = Next(swig_type)) {
      emitTypeWrapperClass(swig_type.key, swig_type.item);
    }

    Dump(proxy_imports, f_proxy_h);
    if (Len(proxy_imports))
      Printf(f_proxy_h, "\n");
    // Objective-C will understand the C code.
    Printf(f_proxy_h, "\n#ifdef __cplusplus\n");
    Printf(f_proxy_h, "extern \"C\" {\n");
    Printf(f_proxy_h, "#endif\n\n");
    Dump(proxy_class_forward_decls, f_proxy_h);
    Printf(f_proxy_h, "\n");
    Dump(swigtypes_h_code, f_proxy_h);
    Dump(proxy_enums_code, f_proxy_h);
    Dump(proxy_h_code, f_proxy_h);
    Printf(f_proxy_h, "\n#ifdef __cplusplus\n");
    Printf(f_proxy_h, "}\n");
    Printf(f_proxy_h, "#endif\n\n");
  }
  // Write to proxy.mm, if required
  if (proxy_flag) {
    //        Printf(f_proxy_mm, "\n#ifdef __cplusplus\n");
    //        Printf(f_proxy_mm, "extern \"C\" {\n");
    //        Printf(f_proxy_mm, "#endif\n\n");
    Dump(swigtypes_mm_code, f_proxy_mm);
    Dump(proxy_mm_code, f_proxy_mm);
    //        Printf(f_proxy_mm, "\n#ifdef __cplusplus\n");
    //        Printf(f_proxy_mm, "}\n");
    //        Printf(f_proxy_mm, "#endif\n");
  }
  // Cleanup
  Delete(wrap_h_code);
  Delete(wrap_mm_code);
  Delete(director_h_code);
  Delete(director_mm_code);
  Delete(f_runtime);
  Delete(f_init);
  Delete(f_header);
  Delete(f_wrappers);
  Delete(f_wrap_h);
  Delete(f_wrap_mm);

  if (proxy_flag) {
    Delete(proxy_class_decl_code);
    Delete(proxy_class_defn_code);
    Delete(proxy_class_enums_code);
    Delete(proxy_class_function_decls);
    Delete(proxy_class_function_defns);
    Delete(proxy_class_selectors);
    Delete(proxy_global_function_decls);
    Delete(proxy_global_function_defns);
    Delete(proxy_class_imports);
    Delete(destrcutor_call);
    Delete(unknown_types);
    Delete(proxy_imported_modules);
    Delete(proxy_constant_names);
    Delete(proxy_enum_constant_names);

    Delete(proxy_imports);
    Delete(proxy_enums_code);
    Delete(swigtypes_h_code);
    Delete(swigtypes_mm_code);
    Delete(proxy_class_forward_decls);
    Delete(proxy_h_code);
    Delete(proxy_mm_code);
    Delete(f_proxy_h);
    Delete(f_proxy_mm);
  }

  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * importDirective()
 *
 * Do not eagerly include proxy headers for every %import. Some imports are
 * used only to make fragments or declarations visible and are not built as
 * separate Objective-C proxy modules.
 * --------------------------------------------------------------------- */

int OBJECTIVEC::importDirective(Node *n) {
  if (proxy_flag) {
    String *modname = Getattr(n, "module");
    if (modname && !Getattr(proxy_imported_modules, modname)) {
      String *proxy_header = NewStringf("%s%s_proxy.h", SWIG_output_directory(), modname);
      FILE *fp = fopen(Char(proxy_header), "r");
      if (fp) {
        fclose(fp);
        Setattr(proxy_imported_modules, modname, modname);
        Printf(proxy_imports, "#import \"%s_proxy.h\"\n", modname);
      }
      Delete(proxy_header);
    }
  }
  return Language::importDirective(n);
}

/* ---------------------------------------------------------------------
 * functionHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::functionHandler(Node *n) {
  Language::functionHandler(n);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * globalfunctionHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::globalfunctionHandler(Node *n) {
  global_func_flag = true;
  Language::globalfunctionHandler(n);
  global_func_flag = false;

  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * memberfunctionHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::memberfunctionHandler(Node *n) {
  String *symname = Getattr(n, "sym:name");
  proxyfuncname = symname;
  member_func_flag = true;
  Language::memberfunctionHandler(n);
  member_func_flag = false;

  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * staticmemberfunctionHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::staticmemberfunctionHandler(Node *n) {
  String *symname = Getattr(n, "sym:name");
  proxyfuncname = symname;
  static_member_func_flag = true;
  Language::staticmemberfunctionHandler(n);
  static_member_func_flag = false;

  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * callbackfunctionHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::callbackfunctionHandler(Node *n) {
  Swig_require("callbackfunctionHandler", n, "name", "*sym:name", "*type", "?value", NIL);
  String *type = Getattr(n, "type");
  String *name = Getattr(n, "name");
  String *parms = Getattr(n, "parms");
  String *cbname = Getattr(n, "feature:callback:name");
  String *calltype = NewStringf("(%s (*)(%s))(%s)", SwigType_str(type, 0), ParmList_str(parms), SwigType_namestr(name));
  SwigType *cbty = Copy(type);
  SwigType_add_function(cbty, parms);
  SwigType_add_pointer(cbty);

  Node *ns = symbolLookup(cbname);
  if (!ns) {
    Swig_save("objc:callbackfunctionHandler", n, "sym:name", "type", "value", "parms", "wrap:action", "wrap:name", NIL);
    Setattr(n, "sym:name", cbname);
    Setattr(n, "type", cbty);
    Setattr(n, "value", calltype);
    Delattr(n, "parms");
    Delattr(n, "wrap:action");
    Delattr(n, "wrap:name");
    constantWrapper(n);
    Swig_restore(n);
  }

  Delete(cbty);
  Delete(calltype);
  Swig_restore(n);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * variableHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::variableHandler(Node *n) {
  Language::variableHandler(n);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * globalvariableHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::globalvariableHandler(Node *n) {
  String *symname = Getattr(n, "sym:name");
  variable_name = symname;
  global_variable_flag = true;

  Language::globalvariableHandler(n);

  global_variable_flag = false;
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * membervariableHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::membervariableHandler(Node *n) {
  String *symname = Getattr(n, "sym:name");
  variable_name = symname;
  member_variable_flag = true;

  Language::membervariableHandler(n);

  member_variable_flag = false;
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * staticmembervariableHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::staticmembervariableHandler(Node *n) {
  String *symname = Getattr(n, "sym:name");
  variable_name = symname;
  static_member_variable_flag = true;

  Language::staticmembervariableHandler(n);

  static_member_variable_flag = false;
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * memberconstantHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::memberconstantHandler(Node *n) {
  String *symname = Getattr(n, "sym:name");
  variable_name = symname;
  member_constant_flag = true;

  Language::memberconstantHandler(n);

  member_constant_flag = false;
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * constructorHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::constructorHandler(Node *n) {
  Language::constructorHandler(n);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * copyconstructorHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::copyconstructorHandler(Node *n) {
  Language::copyconstructorHandler(n);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * destructorHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::destructorHandler(Node *n) {
  Language::destructorHandler(n);
  String *symname = Getattr(n, "sym:name");
  Printv(destrcutor_call, Swig_name_wrapper(Swig_name_destroy(getNSpace(), symname)), "((void*)[self getCptr])", NIL);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * classHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int OBJECTIVEC::classHandler(Node *n) {
  if (proxy_flag) {
    proxy_class_name = Copy(Getattr(n, "sym:name"));

    if (!addSymbol(proxy_class_name, n))
      return SWIG_ERROR;

    Clear(proxy_class_imports);
    Clear(proxy_class_function_decls);
    Clear(proxy_class_function_defns);
    Clear(proxy_class_selectors);
    Clear(proxy_global_function_decls);
    Clear(proxy_global_function_defns);
    Clear(proxy_class_enums_code);
    Clear(proxy_class_decl_code);
    Clear(proxy_class_defn_code);
    Clear(destrcutor_call);
  }

  Language::classHandler(n);

  if (proxy_flag) {
    // Write the code for proxy class
    emitProxyClass(n);

    // Apply the necessary substitutions
    Replaceall(proxy_class_decl_code, "$objcclassname", proxy_class_name);
    Replaceall(proxy_class_defn_code, "$objcclassname", proxy_class_name);

    // And, dump everything to the proxy files
    Printv(proxy_h_code, proxy_class_decl_code, NIL);
    Printv(proxy_mm_code, proxy_class_defn_code, NIL);
    Printv(proxy_h_code, proxy_global_function_decls, NIL);
    Printv(proxy_mm_code, proxy_global_function_defns, NIL);
    // Tidy up
    Delete(proxy_class_qname);
    proxy_class_qname = NULL;
    Delete(proxy_class_name);
    proxy_class_name = NULL;
  }

  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * enumDeclaration()
 *
 * Wraps C/C++ enums as Objective C enums
 * ---------------------------------------------------------------------- */

int OBJECTIVEC::enumDeclaration(Node *n) {
  if (ImportMode)
    return SWIG_OK;

  if (getCurrentClass() && (cplus_mode != PUBLIC))
    return SWIG_NOWRAP;

  String *typemap_lookup_type = Getattr(n, "name");
  String *symname = Getattr(n, "sym:name");
  String *enumname;

  Node *p = parentNode(n);
  if (p && !Strcmp(nodeType(p), "class")) {  // This is a nested enum, prefix the class name
    String *parentname = Getattr(p, "sym:name");
    enumname = NewStringf("%s_%s", parentname, symname);
  } else {
    enumname = Copy(symname);
  }

  String *old_proxy_h_code = 0;
  String *enumitems_code = 0;
  if (proxy_flag) {
    old_proxy_h_code = proxy_h_code;
    enumitems_code = NewString("");
    proxy_h_code = enumitems_code;
  }

  // Emit each enum item.
  Language::enumDeclaration(n);

  if (proxy_flag)
    proxy_h_code = old_proxy_h_code;

  if (!GetFlag(n, "nonempty")) {
    // Do not wrap empty enums;
    Delete(enumitems_code);
    Delete(enumname);
    return SWIG_NOWRAP;
  }

  if (proxy_flag) {
    String *enum_output = proxy_enums_code ? proxy_enums_code : proxy_h_code;
    if (typemap_lookup_type) {
      // Copy-paste the C/C++ enum as an Objective-C enum.
      Printv(enum_output, "enum ", enumname, " {\n", enumitems_code, "\n};\n\n", NIL);
    } else {
      // Handle anonymous enums.
      Printv(enum_output, "\nenum {\n", enumitems_code, "\n};\n\n", NIL);
    }
  }

  Delete(enumitems_code);
  Delete(enumname);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------------
 * enumvalueDeclaration()
 *
 * Genrerates the enum item for the Objective C enums
 * --------------------------------------------------------------------------- */
int OBJECTIVEC::enumvalueDeclaration(Node *n) {
  if (getCurrentClass() && (cplus_mode != PUBLIC))
    return SWIG_NOWRAP;

  Swig_require("enumvalueDeclaration", n, "*name", "?value", NIL);
  String *symname = Getattr(n, "sym:name");
  String *value = Getattr(n, "enumvalue");
  Node *parent = parentNode(n);
  Node *pparent = parentNode(parent);
  String *enumname;
  if (pparent && !Strcmp(nodeType(pparent), "class")) {  // This is a nested enum, prefix the class name
    String *classname = Getattr(pparent, "sym:name");
    enumname = NewStringf("%s_%s", classname, symname);
  } else {
    enumname = Copy(symname);
  }
  if (proxy_flag) {  // Emit the enum item
    if (!GetFlag(n, "firstenumitem"))
      Printf(proxy_h_code, ",\n");
    Printf(proxy_h_code, "  %s", enumname);
    if (value) {
      value = Getattr(n, "enumvalue") ? proxyEnumValue(Getattr(n, "enumvalue")) : proxyEnumValue(Getattr(n, "enumvalueex"));
      String *mapped_value = Getattr(proxy_enum_constant_names, value);
      if (mapped_value) {
        Delete(value);
        value = Copy(mapped_value);
      }
      Printf(proxy_h_code, " = %s", value);
      Delete(value);
    }
    Setattr(proxy_enum_constant_names, symname, enumname);
  }
  // Keep track that the currently processed enum has at least one value
  SetFlag(parent, "nonempty");

  Swig_restore(n);
  Delete(enumname);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * constantWrapper()
 *
 * Low level code generator for constants
 * --------------------------------------------------------------------- */

int OBJECTIVEC::constantWrapper(Node *n) {
  SwigType *type = Getattr(n, "type");
  String *symname = Getattr(n, "sym:name");
  String *value = Getattr(n, "value");
  String *typestring = SwigType_str(type, 0);
  String *tm;

  String *crettype = NewString("");
  String *constants_h_code = NewString("");
  String *constants_mm_code = NewString("");
  bool is_func_ptr = SwigType_isfunctionpointer(type);

  if (!addSymbol(symname, n))
    return SWIG_ERROR;

  // Get the corresponding ObjectiveC type or the intermediate type. "imtype" if no proxy and "objctype" if proxy_flag is true.
  if (!is_func_ptr) {
    if (proxy_flag) {
      if ((tm = Swig_typemap_lookup("objctype", n, "", 0))) {
        substituteClassname(tm, type);
        Printf(crettype, "%s", tm);
      } else {
        Swig_warning(WARN_OBJC_TYPEMAP_OBJCTYPE_UNDEF, input_file, line_number, "No objctype typemap defined for %s\n", typestring);
      }
    } else {
      if ((tm = Swig_typemap_lookup("imtype", n, "", 0))) {
        Printf(crettype, "%s", tm);
      } else {
        Swig_warning(WARN_OBJC_TYPEMAP_IMTYPE_UNDEF, input_file, line_number, "No imtype typemap defined for %s\n", typestring);
      }
    }
  } else {
    if (proxy_flag) {
      if ((tm = Swig_typemap_lookup("objctype", n, "", 0))) {
        substituteClassname(tm, type);
        Printf(crettype, "%s", tm);
      } else {
        Swig_warning(WARN_OBJC_TYPEMAP_OBJCTYPE_UNDEF, input_file, line_number, "No objctype typemap defined for %s\n", typestring);
      }
    } else {
      Printf(crettype, "%s", SwigType_str(type, symname));
    }
  }
  bool objc_string_constant = Strstr(crettype, "NSString") != 0;

  SwigType *resolved_type = SwigType_typedef_resolve_all(type);
  int resolved_typecode = SwigType_type(resolved_type);
  String *constant_expr_value = Getattr(n, "wrappedasconstant") ? Getattr(n, "staticmembervariableHandler:value") : value;
  bool constant_expression_needs_accessor = constant_expr_value && (Strstr(constant_expr_value, "sizeof") || Strstr(constant_expr_value, "alignof") ||
                                                                    proxyConstantExpressionNeedsAccessor(constant_expr_value));
  bool constant_needs_accessor = !Getattr(n, "wrappedasconstant") && !SwigType_isenum(resolved_type) && resolved_typecode != T_BOOL &&
                                 resolved_typecode != T_CHAR && resolved_typecode != T_SCHAR && resolved_typecode != T_UCHAR && resolved_typecode != T_SHORT &&
                                 resolved_typecode != T_USHORT && resolved_typecode != T_INT && resolved_typecode != T_UINT && resolved_typecode != T_LONG &&
                                 resolved_typecode != T_ULONG && resolved_typecode != T_LONGLONG && resolved_typecode != T_ULONGLONG &&
                                 resolved_typecode != T_FLOAT && resolved_typecode != T_DOUBLE && resolved_typecode != T_STRING &&
                                 resolved_typecode != T_WSTRING && !objc_string_constant;
  String *objcvarout_tm = (constant_needs_accessor || constant_expression_needs_accessor) ? Swig_typemap_lookup("objcvarout", n, "", 0) : 0;
  Delete(resolved_type);

  if (objcvarout_tm || constant_expression_needs_accessor) {
    Swig_save("constantWrapper", n, "sym:overloaded", NIL);
    Setattr(n, "sym:overloaded", "1");
    SetFlag(n, "objc:constantWrapper");
    functionWrapper(n);
    Delattr(n, "objc:constantWrapper");
    Swig_restore(n);
    Printf(constants_h_code, "extern %s %s;\n", crettype, symname);
    String *wrapped_name = Swig_name_wrapper(symname);
    String *imcall = NewStringf("%s()", wrapped_name);
    if (objcvarout_tm && !constant_expression_needs_accessor) {
      tm = objcvarout_tm;
      substituteClassname(tm, type);
      Replaceall(tm, "$objcvarname", symname);
      Replaceall(tm, "$imcall", imcall);
      Printf(constants_mm_code, "%s\n", tm);
    } else {
      Printf(constants_mm_code, "%s %s;\n", crettype, symname);
      Printf(constants_mm_code, "#if defined(__GNUC__)\n");
      Printf(constants_mm_code, "__attribute__((constructor))\n");
      Printf(constants_mm_code, "#endif\n");
      Printf(constants_mm_code, "static void SWIG_ObjectiveC_init_%s(void) {\n", wrapped_name);
      Printf(constants_mm_code, "  %s = (%s)%s;\n", symname, crettype, imcall);
      Printf(constants_mm_code, "}\n");
    }
    Delete(wrapped_name);
    Delete(imcall);
  } else if (Getattr(n, "wrappedasconstant")) {
    String *constant_value = proxyConstantValue(Getattr(n, "staticmembervariableHandler:value"));
    if (SwigType_type(type) == T_CHAR) {
      Printf(constants_mm_code, "%s %s= (%s);\n", crettype, symname, constant_value);
    } else if (SwigType_type(type) == T_STRING || objc_string_constant) {
      String *literal = objcStringLiteral(Getattr(n, "staticmembervariableHandler:value"));
      Printf(constants_mm_code, "%s %s= @%s;\n", crettype, symname, literal);
      Delete(literal);
    } else {
      if (SwigType_isenum(type))
        Printf(constants_mm_code, "%s %s= (%s)(%s);\n", crettype, symname, crettype, constant_value);
      else
        Printf(constants_mm_code, "%s %s= (%s);\n", crettype, symname, constant_value);
    }
    Delete(constant_value);
  } else {
    if (SwigType_type(type) == T_STRING || objc_string_constant) {
      // http://stackoverflow.com/questions/538996/constants-in-objective-c/539191#539191
      String *literal = objcStringLiteral(value);
      Printf(constants_h_code, "extern %s %s;\n", crettype, symname);
      Printf(constants_mm_code, "%s %s= @%s;\n", crettype, symname, literal);
      Delete(literal);
    } else if (SwigType_type(type) == T_CHAR) {
      String *constant_value = proxyConstantValue(value);
      Printf(constants_h_code, "extern %s %s;\n", crettype, symname);
      Printf(constants_mm_code, "%s %s= (%s);\n", crettype, symname, constant_value);
      Delete(constant_value);
    } else {
      String *constant_value = proxyConstantValue(value);
      Printf(constants_h_code, "extern %s %s;\n", crettype, symname);
      if (SwigType_isenum(type))
        Printf(constants_mm_code, "%s %s= (%s)(%s);\n", crettype, symname, crettype, constant_value);
      else
        Printf(constants_mm_code, "%s %s= (%s);\n", crettype, symname, constant_value);
      Delete(constant_value);
    }
  }

  if (proxy_flag) {
    String *constant_name = Getattr(n, "name");
    String *constant_key = objc_last_qualified_component(constant_name ? constant_name : symname);
    if (!constant_key)
      constant_key = Copy(symname);
    Setattr(proxy_constant_names, constant_key, symname);
    Delete(constant_key);
  }

  // Dump to generated files
  if (proxy_flag) {  // write to the proxy files
    Printv(proxy_h_code, constants_h_code, NIL);
    Printv(proxy_mm_code, constants_mm_code, NIL);
  } else {  // write to the wrap files
    Printv(wrap_h_code, constants_h_code, NIL);
    Printv(wrap_mm_code, constants_mm_code, NIL);
  }

  // Cleanup
  Delete(crettype);
  Delete(constants_h_code);
  Delete(constants_mm_code);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * variableWrapper()
 *
 * Low level code generator for variables
 * --------------------------------------------------------------------- */

int OBJECTIVEC::variableWrapper(Node *n) {
  Language::variableWrapper(n);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * functionWrapper()
 *
 *
 * Generates the C wrapper code for a function and the corresponding
 * declaration in the wrap files
 * --------------------------------------------------------------------- */

int OBJECTIVEC::functionWrapper(Node *n) {
  // Get some useful attributes of this function
  String *symname = Getattr(n, "sym:name");
  SwigType *type = Getattr(n, "type");
  ParmList *parmlist = Getattr(n, "parms");
  String *crettype = SwigType_str(type, 0);
  String *imrettype = NewString("");
  String *tm;
  bool is_void_return = (Cmp(crettype, "void") == 0);
  bool is_constructor = (Cmp(nodeType(n), "constructor") == 0);
  bool is_destructor = (Cmp(nodeType(n), "destructor") == 0);
  bool is_constant = (Cmp(nodeType(n), "constant") == 0) || GetFlag(n, "objc:constantWrapper");

  if (!is_constant && !Getattr(n, "feature:action") && !Getattr(n, "wrap:action"))
    return SWIG_NOWRAP;

  if (!Getattr(n, "sym:overloaded")) {
    if (!addSymbol(Getattr(n, "sym:name"), n))
      return SWIG_ERROR;
  }
  // Create the function's wrappered name
  String *wname = Swig_name_wrapper(symname);

  // Create the wrapper function object
  Wrapper *wrapper = NewWrapper();

  // Retrieve the intermediate return type for this function
  if ((tm = Swig_typemap_lookup("imtype", n, "", 0))) {
    Printf(imrettype, "%s", tm);
  } else {
    Swig_warning(WARN_OBJC_TYPEMAP_IMTYPE_UNDEF, input_file, line_number, "No imtype typemap defined for %s\n", crettype);
  }

  // Deal with overloading

  /* Write the wrapper function declaration and definition */

  // Begin the first line of the function definition
  Printv(wrapper->def, imrettype, " ", wname, "(", NIL);

  // The parameter list generation needs "in" typemaps attached in order to
  // honor numinputs=0 typemaps such as grouped OUTPUT arguments and varargs.
  Swig_typemap_attach_parms("in", parmlist, wrapper);

  // Make the param list with the intermediate parameter types
  makeParameterList(parmlist, wrapper);

  // End the first line of the function definition
  Printv(wrapper->def, ")", NIL);

  // Write the function declaration to the wrap_h
  Printv(wrap_h_code, wrapper->def, ";\n", NIL);

  // Now write the function definition to the wrap_cpp
  Printv(wrapper->def, "\n{", NIL);

  // Emit all of the local variables for holding arguments
  emit_parameter_variables(parmlist, wrapper);

  // If any additional local variable needed, add them now
  if (!is_void_return)
    Wrapper_add_localv(wrapper, "imresult", imrettype, "imresult = 0", NIL);

  // Attach the standard typemaps to the parameter list
  emit_attach_parmmaps(parmlist, wrapper);
  Setattr(n, "wrap:parms", parmlist);

  // Now walk the function parameter list and generate code to get arguments.
  marshalInputArgs(parmlist, wrapper);

  // Emit the function call
  if (is_constant) {  // Wrapping a constant hack.
    Swig_save("functionWrapper", n, "wrap:action", NIL);

    // below based on Swig_VargetToFunction()
    SwigType *ty = Swig_wrapped_var_type(Getattr(n, "type"), use_naturalvar_mode(n));
    if (SwigType_type(type) == T_USER && !SwigType_ispointer(type) && !SwigType_isreference(type)) {
      Delete(ty);
      ty = Copy(type);
    }
    Setattr(n, "wrap:action", NewStringf("%s = (%s) %s;", Swig_cresult_name(), SwigType_lstr(ty, 0), Getattr(n, "value")));
    Delete(ty);
  }

  Setattr(n, "wrap:name", wname);
  if (Swig_director_emit_dynamic_cast(n, wrapper)) {
    Append(wrapper->code, "if (!darg) {\n");
    Append(wrapper->code, "  SWIG_ObjcThrowException(SWIG_ObjcNullPointerException, \"'self' is not a director\");\n");
    if (is_void_return)
      Append(wrapper->code, "  return;\n");
    else
      Append(wrapper->code, "  return imresult;\n");
    Append(wrapper->code, "}\n");
  }
  String *actioncode = emit_action(n);
  if (Strstr(actioncode, "upcall"))
    Wrapper_add_local(wrapper, "upcall", "bool upcall = false");

  if (Cmp(nodeType(n), "constant") == 0)
    Swig_restore(n);

  // Write typemaps(out) and return value if necessary.
  marshalOutput(n, actioncode, wrapper);

  if (GetFlag(n, "feature:new")) {
    if ((tm = Swig_typemap_lookup("newfree", n, Swig_cresult_name(), 0))) {
      Printf(wrapper->code, "%s\n", tm);
      Delete(tm);
    }
  }

  if ((tm = Swig_typemap_lookup("ret", n, Swig_cresult_name(), 0))) {
    Printf(wrapper->code, "%s\n", tm);
    Delete(tm);
  }

  // Close the function
  if (!is_void_return)
    Printv(wrapper->code, "return imresult;\n", NIL);
  Printv(wrapper->code, "}", NIL);

  // Final substititions if applicable.
  Replaceall(wrapper->code, "$isvoid", is_void_return ? "1" : "0");

  /* Contract macro modification */
  Replaceall(wrapper->code, "SWIG_contract_assert(", "SWIG_contract_assert($null, ");

  if (!is_void_return)
    Replaceall(wrapper->code, "$null", "0");
  else
    Replaceall(wrapper->code, "$null", "");

  // Dump the function out.
  Wrapper_print(wrapper, wrap_mm_code);

  /* Create the proxy functions if proxy_flag is true. */
  if (proxy_flag && is_constructor) {  // Handle constructor
    Setattr(n, "imfunctionname", wname);
    emitProxyClassConstructor(n);
  } else if (proxy_flag && is_destructor) {  // Handle destructor
    // Destructor proxy emission is completed when the class body is emitted.
  }
  // globalFunctionHandler is called for static member functions as well hence setting global_func_flag to true.
  // To route the call to the appropriate proxy generator, we check for !static_member_func_flag here.
  if (proxy_flag && !is_constant && (global_variable_flag || global_func_flag) && !static_member_func_flag) {  // Handle globals
    Setattr(n, "imfunctionname", wname);
    emitProxyGlobalFunctions(n);
  } else if (proxy_flag && !is_constant &&
             (member_variable_flag || static_member_variable_flag || member_constant_flag || member_func_flag || static_member_func_flag)) {  // Handle members
    Setattr(n, "imfunctionname", wname);
    emitProxyClassFunction(n);
  }
  // Tidy up
  Delete(imrettype);
  Delete(wname);
  DelWrapper(wrapper);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * nativeWrapper()
 *
 *
 * --------------------------------------------------------------------- */

int OBJECTIVEC::nativeWrapper(Node *n) {
  Language::nativeWrapper(n);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * emitProxyGlobalFunctions()
 *
 * C/C++ global functions and global variables are mapped to ObjectiveC global functions.
 * C/C++ types will be replaced with their equivalent ObjectiveC types (eg: char* --> NSString*)
 * A prefix 'Objc' will be added to counter linker redifiniton complains.
 *
 * ----------------------------------------------------------------------------- */

void OBJECTIVEC::emitProxyGlobalFunctions(Node *n) {
  if (!proxy_flag)
    return;

  // Get some useful attributes of this function
  String *symname = Getattr(n, "sym:name");
  SwigType *type = Getattr(n, "type");
  ParmList *parmlist = Getattr(n, "parms");
  String *crettype = SwigType_str(type, 0);
  String *storage = Getattr(n, "storage");
  String *objcrettype = NewString("");
  String *imcall = NewString("");
  String *function_defn = NewString("");
  String *function_decl = NewString("");
  String *tm;
  String *imfunctionname = Getattr(n, "imfunctionname");
  String *proxyfunctionname;
  bool setter_flag = false;

  // Retrieve the ObjectiveC return type for this function
  if ((tm = Swig_typemap_lookup("objctype", n, "", 0))) {
    substituteClassname(tm, type);
    Printf(objcrettype, "%s", tm);
  } else {
    Swig_warning(WARN_OBJC_TYPEMAP_OBJCTYPE_UNDEF, input_file, line_number, "No objctype typemap defined for %s\n", crettype);
  }

  // Deal with overloading

  // Change the function name for global variables
  if (proxy_flag && global_variable_flag) {
    proxyfunctionname = NewString("");
    setter_flag = (Cmp(symname, Swig_name_set(getNSpace(), variable_name)) == 0);
    if (setter_flag)
      Printf(proxyfunctionname, "set");
    else
      Printf(proxyfunctionname, "get");

    // Capitalize the first letter in the variable to create an ObjectiveC proxy function name
    Putc(toupper((int)*Char(variable_name)), proxyfunctionname);
    Printf(proxyfunctionname, "%s", Char(variable_name) + 1);
  } else {
    proxyfunctionname = NewString("Objc");
    // Capitalize the first letter
    Putc(toupper((int)*Char(symname)), proxyfunctionname);
    Printf(proxyfunctionname, "%s", Char(symname) + 1);
  }

  /* Write the proxy global function declaration and definition */

  // Begin the first line of the function
  Printv(function_decl, objcrettype, " ", proxyfunctionname, "(", NIL);

  // Prepare the call to intermediate function
  Printf(imcall, "%s(", imfunctionname);

  // The standard "in" typemap was already attached while generating the wrapper.
  // Keep its grouped-argument links intact for Objective-C proxy parameters.
  Swig_typemap_attach_parms("objctype", parmlist, NULL);
  Swig_typemap_attach_parms("objcin", parmlist, NULL);

  Parm *p;
  int i = 0;
  int gencomma = 0;

  for (p = parmlist; p; p = nextInputArg(p), i++) {
    p = skipIgnoredArgs(p);
    if (!p)
      break;
    SwigType *pt = Getattr(p, "type");

    String *objcparmtype = NewString("");

    // Get the ObjectiveC parameter type for this parameter
    if ((tm = Getattr(p, "tmap:objctype"))) {
      substituteClassname(tm, pt);
      Printf(objcparmtype, "%s", tm);
    } else {
      Swig_warning(WARN_OBJC_TYPEMAP_OBJCTYPE_UNDEF, input_file, line_number, "No objctype typemap defined for %s\n", SwigType_str(pt, 0));
    }

    if (gencomma)
      Printf(imcall, ", ");

    String *arg = makeParameterName(n, p, i, setter_flag);

    // Use typemaps to transform the type used in Objective-C proxy function to the one used in intermediate code.
    if ((tm = Getattr(p, "tmap:objcin"))) {
      substituteClassname(tm, pt);
      Replaceall(tm, "$objcinput", arg);
      Printv(imcall, tm, NIL);
    } else {
      Swig_warning(WARN_OBJC_TYPEMAP_OBJCIN_UNDEF, input_file, line_number, "No objcin typemap defined for %s\n", SwigType_str(pt, 0));
    }

    // Add parameter to proxy function
    if (gencomma >= 2)
      Printf(function_decl, ", ");
    gencomma = 2;
    Printf(function_decl, "%s %s", objcparmtype, arg);

    Delete(arg);
    Delete(objcparmtype);
  }

  // End the first line of the function
  Printv(function_decl, ")", NIL);  // or
  // Printv(function_decl, paramstring, ")", NIL);

  Printv(function_defn, function_decl, "\n{\n", NIL);
  Printf(function_decl, ";");

  // End the call to the intermediate function
  Printv(imcall, ")", NIL);

  // Transform return type used in low level accessor to type used in Objective-C proxy function
  if ((tm = Swig_typemap_lookup("objcout", n, "", 0))) {
    substituteClassname(tm, type);
    Replaceall(tm, "$imcall", imcall);
  } else {
    Swig_warning(WARN_OBJC_TYPEMAP_OBJCOUT_UNDEF, input_file, line_number, "No objcout typemap defined for %s\n", crettype);
  }

  Printf(function_defn, " %s\n}\n", tm ? (const String *)tm : empty_string);

  /* Write the function declaration to the proxy_h_code
     and function definition to the proxy_mm_code */
  if ((member_func_flag || member_constant_flag || (storage && Strcmp(storage, "friend") == 0) || (storage && Strcmp(storage, "typedef") == 0))) {
    Printv(proxy_global_function_decls, function_decl, "\n", NIL);
    Printv(proxy_global_function_defns, function_defn, "\n", NIL);
  } else {
    Printv(proxy_h_code, function_decl, "\n", NIL);
    Printv(proxy_mm_code, function_defn, "\n", NIL);
  }
  // Delete(paramstring);
  Delete(proxyfunctionname);
  Delete(objcrettype);
  Delete(imcall);
  Delete(function_decl);
  Delete(function_defn);
}

/* -----------------------------------------------------------------------------
 * emitProxyClassFunction()
 *
 * Function called for writing an Objective-C proxy function for static and non-static
 * C++ class functions, static and non-static member variables, member constants/enums.
 *
 * C++ class static functions map to Objective-C "+" functions.
 * C++ class non-static functions map to Objective-C "-" functions.
 * ----------------------------------------------------------------------------- */

void OBJECTIVEC::emitProxyClassFunction(Node *n) {
  if (!proxy_flag)
    return;

  // Get some useful attributes of this function
  String *symname = Getattr(n, "sym:name");
  SwigType *type = Getattr(n, "type");
  ParmList *parmlist = Getattr(n, "parms");
  String *crettype = SwigType_str(type, 0);
  String *objcrettype = NewString("");
  String *imcall = NewString("");
  String *function_defn = NewString("");
  String *function_decl = NewString("");
  String *tm;

  String *imfunctionname = Getattr(n, "imfunctionname");
  String *proxyfunctionname;

  bool setter_flag = false;
  bool static_flag = (static_member_func_flag || static_member_variable_flag);

  // Retrieve the ObjectiveC return type for this function
  if ((tm = Swig_typemap_lookup("objctype", n, "", 0))) {
    substituteClassname(tm, type);
    Printf(objcrettype, "%s", tm);
  } else {
    Swig_warning(WARN_OBJC_TYPEMAP_OBJCTYPE_UNDEF, input_file, line_number, "No objctype typemap defined for %s\n", crettype);
  }

  if (member_variable_flag || static_member_variable_flag || member_constant_flag) {
    proxyfunctionname = NewString("");
    setter_flag = Cmp(symname, Swig_name_set(getNSpace(), Swig_name_member(0, proxy_class_name, variable_name))) == 0;
    if (setter_flag)
      Printf(proxyfunctionname, "set");
    else
      Printf(proxyfunctionname, "get");
    // Capitalize the first letter in the variable to create an ObjectiveC proxy function name
    Putc(toupper((int)*Char(variable_name)), proxyfunctionname);
    Printf(proxyfunctionname, "%s", Char(variable_name) + 1);

  } else if (member_func_flag) {
    proxyfunctionname = Copy(proxyfuncname);
  } else {
    proxyfunctionname = Copy(proxyfuncname);
  }

  if ((member_func_flag || static_member_func_flag) && objc_is_reserved_method_family_name(proxyfunctionname)) {
    String *renamed = objc_swig_method_name(proxyfunctionname);
    Delete(proxyfunctionname);
    proxyfunctionname = renamed;
  }

  // Deal with overloading

  /* Write the proxy function declaration and definition */

  // Begin the first line of the function declaration
  if (static_flag)
    Printv(function_decl, "+(", objcrettype, ")", proxyfunctionname, NIL);
  else
    Printv(function_decl, "-(", objcrettype, ")", proxyfunctionname, NIL);

  // Prepare the call to intermediate function
  Printv(imcall, imfunctionname, "(", NIL);

  // The standard "in" typemap was already attached while generating the wrapper.
  // Keep its grouped-argument links intact for Objective-C proxy parameters.
  Swig_typemap_attach_parms("objctype", parmlist, NULL);
  Swig_typemap_attach_parms("objcin", parmlist, NULL);

  Parm *p;
  int i = 0;
  int gencomma = 0;

  for (p = parmlist; p; p = nextInputArg(p), i++) {
    p = skipIgnoredArgs(p);
    if (!p)
      break;
    SwigType *pt = Getattr(p, "type");
    String *objcparmtype = NewString("");

    // Get the ObjectiveC parameter type for this parameter
    if ((tm = Getattr(p, "tmap:objctype"))) {
      substituteClassname(tm, pt);
      Printf(objcparmtype, "%s", tm);
    } else {
      Swig_warning(WARN_OBJC_TYPEMAP_OBJCTYPE_UNDEF, input_file, line_number, "No objctype typemap defined for %s\n", SwigType_str(pt, 0));
    }

    if (gencomma)
      Printf(imcall, ", ");

    String *arg = makeParameterName(n, p, i, setter_flag);

    // Use the class-specific pointer accessor for the implicit C++ "this"
    // pointer so inherited Objective-C methods receive the correct base
    // subobject pointer even for virtual inheritance.
    if (!static_flag && gencomma == 0) {
      String *cptr_method = objc_cptr_method_name(proxy_class_name);
      Printf(imcall, "[self %s]", cptr_method);
      Delete(cptr_method);
    } else if ((tm = Getattr(p, "tmap:objcin"))) {
      substituteClassname(tm, pt);
      Replaceall(tm, "$objcinput", arg);
      Printv(imcall, tm, NIL);
    } else {
      Swig_warning(WARN_OBJC_TYPEMAP_OBJCIN_UNDEF, input_file, line_number, "No objcin typemap defined for %s\n", SwigType_str(pt, 0));
    }

    // Add parameter to proxy function
    if (static_flag) {
      if (gencomma == 0)
        Printf(function_decl, ": (%s)%s", objcparmtype, arg);
      else if (gencomma >= 1)
        Printf(function_decl, " %s: (%s)%s", arg, objcparmtype, arg);
    } else {
      if (gencomma == 1)
        Printf(function_decl, ": (%s)%s", objcparmtype, arg);
      else if (gencomma >= 2)
        Printf(function_decl, " %s: (%s)%s", arg, objcparmtype, arg);
    }
    gencomma++;

    Delete(arg);
    Delete(objcparmtype);
  }

  // First line of function definition
  Printv(function_defn, function_decl, "\n{\n", NIL);
  Printf(function_decl, ";");

  // End the call to the intermediate function
  Printv(imcall, ")", NIL);

  // Transform return type used in low level accessor to type used in Objective-C proxy function
  if ((tm = Swig_typemap_lookup("objcout", n, "", 0))) {
    substituteClassname(tm, type);
    Replaceall(tm, "$imcall", imcall);
  } else {
    Swig_warning(WARN_OBJC_TYPEMAP_OBJCOUT_UNDEF, input_file, line_number, "No objcout typemap defined for %s\n", crettype);
  }

  Printf(function_defn, " %s\n}\n", tm ? (const String *)tm : empty_string);

  /* Write the function declaration to the proxy_class_function_decls
     and function definition to the proxy_class_function_defns */
  Printv(proxy_class_function_decls, function_decl, "\n", NIL);
  Printv(proxy_class_function_defns, function_defn, "\n", NIL);

  // Delete(paramstring);
  Delete(proxyfunctionname);
  Delete(objcrettype);
  Delete(imcall);
  Delete(function_decl);
  Delete(function_defn);
}

/* -----------------------------------------------------------------------------
 * emitProxyClassConstructor()
 *
 * Function called for writing an Objective-C proxy class constructor a.k.a
 * init function(s).
 *
 * ----------------------------------------------------------------------------- */

void OBJECTIVEC::emitProxyClassConstructor(Node *n) {
  if (!proxy_flag)
    return;

  // Get some useful attributes of the constructor
  String *name = Getattr(n, "name");
  ParmList *parmlist = Getattr(n, "parms");
  String *imcall = NewString("");
  String *constructor_defn = NewString("");
  String *constructor_decl = NewString("");
  String *tm;
  String *objcrettype = NewString("id");

  String *imfunctionname = Getattr(n, "imfunctionname");
  String *proxyfunctionname = NewString("init");

  // Deal with overloading

  /* Write the proxy class constructor declaration and definition */

  // Begin the first line of the constructor
  Printv(constructor_decl, "-(", objcrettype, ")", proxyfunctionname, NIL);

  // Prepare the call to intermediate function
  Printv(imcall, imfunctionname, "(", NIL);

  // The standard "in" typemap was already attached while generating the wrapper.
  // Keep its grouped-argument links intact for Objective-C proxy parameters.
  Swig_typemap_attach_parms("objctype", parmlist, NULL);
  Swig_typemap_attach_parms("objcin", parmlist, NULL);

  String *selector_key = NewString("init");
  String *constructor_type_suffix = 0;
  int selector_arg_count = 0;
  for (Parm *selector_p = parmlist; selector_p; selector_p = nextInputArg(selector_p), selector_arg_count++) {
    selector_p = skipIgnoredArgs(selector_p);
    if (!selector_p)
      break;

    String *arg = makeParameterName(n, selector_p, selector_arg_count, false);
    if (selector_arg_count == 0) {
      Printf(selector_key, "With");
      Putc(toupper((int)*Char(arg)), selector_key);
      Printf(selector_key, "%s", (Char(arg) + 1));

      SwigType *pt = Getattr(selector_p, "type");
      if ((tm = Getattr(selector_p, "tmap:objctype"))) {
        substituteClassname(tm, pt);
        constructor_type_suffix = objc_selector_component_from_type(tm);
      }
    } else {
      Printf(selector_key, "%s", arg);
    }
    Printf(selector_key, ":");
    Delete(arg);
  }
  if (!constructor_type_suffix)
    constructor_type_suffix = objc_selector_component_from_type(imfunctionname);
  bool disambiguate_selector = Getattr(proxy_class_selectors, selector_key) ? true : false;
  Delete(selector_key);

  Parm *p;
  int i = 0;
  int gencomma = 0;
  String *final_selector_key = NewString("init");

  for (p = parmlist; p; p = nextInputArg(p), i++) {
    p = skipIgnoredArgs(p);
    if (!p)
      break;
    SwigType *pt = Getattr(p, "type");
    String *objcparmtype = NewString("");

    // Get the ObjectiveC parameter type for this parameter
    if ((tm = Getattr(p, "tmap:objctype"))) {
      substituteClassname(tm, pt);
      Printf(objcparmtype, "%s", tm);
    } else {
      Swig_warning(WARN_OBJC_TYPEMAP_OBJCTYPE_UNDEF, input_file, line_number, "No objctype typemap defined for %s\n", SwigType_str(pt, 0));
    }

    if (gencomma)
      Printf(imcall, ", ");

    String *arg = makeParameterName(n, p, i, false);

    // Use typemaps to transform type used in Objective-C proxy function to the one used in intermediate code.
    if ((tm = Getattr(p, "tmap:objcin"))) {
      substituteClassname(tm, pt);
      Replaceall(tm, "$objcinput", arg);
      Printv(imcall, tm, NIL);
    } else {
      Swig_warning(WARN_OBJC_TYPEMAP_OBJCIN_UNDEF, input_file, line_number, "No objcin typemap defined for %s\n", SwigType_str(pt, 0));
    }

    // Add parameter to proxy function
    if (gencomma >= 1) {  // Subsequent arguments.
      Printf(constructor_decl, " %s:", arg);
      Printf(final_selector_key, "%s:", arg);
    } else {  // First valid argument, prefix it with 'With' and capitalize the first letter
      Printf(constructor_decl, "With");
      Printf(final_selector_key, "With");
      Putc(toupper((int)*Char(arg)), constructor_decl);
      Putc(toupper((int)*Char(arg)), final_selector_key);
      Printf(constructor_decl, "%s", (Char(arg) + 1));
      Printf(final_selector_key, "%s", (Char(arg) + 1));
      if (disambiguate_selector) {
        Printf(constructor_decl, "As%s:", constructor_type_suffix);
        Printf(final_selector_key, "As%s:", constructor_type_suffix);
      } else {
        Printf(constructor_decl, ":");
        Printf(final_selector_key, ":");
      }
    }

    Printf(constructor_decl, " (%s)%s", objcparmtype, arg);
    gencomma++;

    Delete(arg);
    Delete(objcparmtype);
  }

  // First line of function definition
  Printv(constructor_defn, constructor_decl, "\n{\n", NIL);
  Printf(constructor_decl, ";");

  // End the call to the intermediate function
  Printv(imcall, ")", NIL);

  // Insert the objcconstructor typemap
  Hash *attributes = NewHash();
  String *constructor_code = NewString("");
  const String *construct_tm = typemapLookup(n, "objcconstructor", name, WARN_NONE, attributes);
  if (construct_tm) {
    Printv(constructor_code, construct_tm, NIL);
    Replaceall(constructor_code, "$imcall", imcall);
    Node *parent = Swig_methodclass(n);
    if (parent && Swig_directorclass(parent)) {
      String *connect_name = objcDirectorConnectWrapperName(parent);
      String *directorconnect = NewStringf("%s(cptr, self);\n        ", connect_name);
      Replaceall(constructor_code, "$directorconnect", directorconnect);
      Delete(directorconnect);
      Delete(connect_name);
    } else {
      Replaceall(constructor_code, "$directorconnect", "");
    }
  }
  Printf(constructor_defn, " %s\n}\n", constructor_code);

  Delete(attributes);
  Delete(constructor_code);

  /* Write the function declaration to the proxy_class_function_decls
     and function definition to the proxy_class_function_defns */
  Printv(proxy_class_function_decls, constructor_decl, "\n", NIL);
  Printv(proxy_class_function_defns, constructor_defn, "\n", NIL);
  Setattr(proxy_class_selectors, final_selector_key, "1");

  // Delete(paramstring);
  Delete(final_selector_key);
  Delete(constructor_type_suffix);
  Delete(proxyfunctionname);
  Delete(objcrettype);
  Delete(imcall);
  Delete(constructor_decl);
  Delete(constructor_defn);
}

/* ---------------------------------------------------------------------------
 * emitProxyClass()
 *
 * Collects all the code fragments generated by the handler function while
 * traversing the tree from the proxy_class_* variables and writes the
 * class definition (including any additional code) to proxy_h and proxy_mm files.
 *
 * Inputs:
 *  n – The class node currently processed.
 * --------------------------------------------------------------------------- */
void OBJECTIVEC::emitProxyClass(Node *n) {
  if (!proxy_flag)
    return;

  SwigType *typemap_lookup_type = Getattr(n, "classtypeobj");

  /*
   * Handle inheriting from ObjectiveC and C++ classes.
   */
  String *baseclass = NULL;
  String *c_baseclassname = NULL;

  // Inheritance from pure ObjectiveC classes.
  Node *attributes = NewHash();
  const String *pure_baseclass = typemapLookup(n, "objcbase", typemap_lookup_type, WARN_NONE, attributes);
  bool purebase_replace = GetFlag(attributes, "tmap:objcbase:replace") ? true : false;
  bool purebase_notderived = GetFlag(attributes, "tmap:objcbase:notderived") ? true : false;
  Delete(attributes);

  // C++ inheritance.
  if (!purebase_replace) {
    List *baselist = Getattr(n, "bases");
    if (baselist) {
      Iterator base = First(baselist);
      while (base.item && GetFlag(base.item, "feature:ignore")) {
        base = Next(base);
      }
      if (base.item) {
        c_baseclassname = Getattr(base.item, "name");
        baseclass = Copy(createProxyName(c_baseclassname));
      }
    }
  }

  bool derived = baseclass && createProxyName(c_baseclassname);
  if (derived && purebase_notderived) {
    pure_baseclass = empty_string;
  }
  const String *wanted_base = baseclass ? baseclass : pure_baseclass;

  if (purebase_replace) {
    wanted_base = pure_baseclass;
    derived = false;
    Delete(baseclass);
    baseclass = NULL;
    if (purebase_notderived) {
      Swig_error(
        Getfile(n), Getline(n), "The objcbase typemap for proxy %s must contain just one of the 'replace' or 'notderived' attributes.\n", typemap_lookup_type);
    }
  } else if (Len(pure_baseclass) > 0 && Len(baseclass) > 0) {
    Swig_warning(WARN_OBJC_MULTIPLE_INHERITANCE,
                 Getfile(n),
                 Getline(n),
                 "Warning for %s proxy: Base class %s is not used as the Objective-C superclass because Objective-C allows a single superclass. "
                 "Perhaps you need one of the 'replace' or 'notderived' attributes in the objcbase typemap?\n",
                 typemap_lookup_type,
                 pure_baseclass);
  }

  String *objcclasscptr = objc_cptr_ivar_name(proxy_class_name, derived);
  String *objccptrmethod = objc_cptr_method_name(proxy_class_name);
  String *objcbasecptrinit = NewString("");
  String *objcbasecptrclear = NewString("");

  if (!purebase_replace) {
    List *baselist = Getattr(n, "bases");
    bool saw_primary_base = false;
    if (baselist) {
      SwigType *derived_ptr_type = Copy(typemap_lookup_type);
      if (!SwigType_ispointer(derived_ptr_type))
        SwigType_add_pointer(derived_ptr_type);
      String *derived_type_str = SwigType_str(derived_ptr_type, 0);

      for (Iterator base = First(baselist); base.item; base = Next(base)) {
        if (GetFlag(base.item, "feature:ignore"))
          continue;
        if (!saw_primary_base) {
          saw_primary_base = true;
          continue;
        }

        String *base_proxy_name = createProxyName(Getattr(base.item, "name"));
        if (!base_proxy_name)
          continue;

        SwigType *base_type = Getattr(base.item, "classtypeobj");
        SwigType *base_ptr_type = base_type ? Copy(base_type) : Copy(Getattr(base.item, "name"));
        if (!SwigType_ispointer(base_ptr_type))
          SwigType_add_pointer(base_ptr_type);

        String *cast_func = objc_cast_function_name(derived_ptr_type, base_ptr_type);
        String *cast_needle = NewStringf("%s(", cast_func);
        String *base_type_str = SwigType_str(base_ptr_type, 0);
        if (!wrap_h_code || !Strstr(wrap_h_code, cast_needle)) {
          Printf(wrap_h_code, "void* %s(void* imarg1);\n", cast_func);
          Printf(wrap_mm_code, "void* %s(void* imarg1) {\n", cast_func);
          Printf(wrap_mm_code, "#ifdef __cplusplus\n");
          Printf(wrap_mm_code, "  return (void*)((%s)((%s)imarg1));\n", base_type_str, derived_type_str);
          Printf(wrap_mm_code, "#else\n");
          Printf(wrap_mm_code, "  return imarg1;\n");
          Printf(wrap_mm_code, "#endif\n");
          Printf(wrap_mm_code, "}\n");
        }

        String *accessor_name = NewStringf("as%s", base_proxy_name);
        if (Getattr(proxy_class_selectors, accessor_name)) {
          Delete(accessor_name);
          accessor_name = NewStringf("swigAs%s", base_proxy_name);
        }
        Setattr(proxy_class_selectors, accessor_name, "1");
        Printf(proxy_class_function_decls, "-(%s*)%s;\n", base_proxy_name, accessor_name);
        Printf(proxy_class_function_defns, "-(%s*)%s {\n", base_proxy_name, accessor_name);
        Printf(proxy_class_function_defns, "  void *cptr = %s([self %s]);\n", cast_func, objccptrmethod);
        Printf(proxy_class_function_defns, "  return cptr ? [[[%s alloc] initWithCptr:cptr swigOwnCObject:NO] autorelease] : 0;\n", base_proxy_name);
        Printf(proxy_class_function_defns, "}\n\n");

        Delete(accessor_name);
        Delete(base_type_str);
        Delete(cast_needle);
        Delete(cast_func);
        Delete(base_ptr_type);
      }

      Delete(derived_type_str);
      Delete(derived_ptr_type);
    }
  }

  if (derived) {
    SwigType *derived_ptr_type = Copy(typemap_lookup_type);
    if (!SwigType_ispointer(derived_ptr_type))
      SwigType_add_pointer(derived_ptr_type);
    String *derived_type_str = SwigType_str(derived_ptr_type, 0);
    String *cast_expr = NewStringf("((%s)imarg1)", derived_type_str);
    Delete(derived_type_str);

    Node *base_node = 0;
    List *baselist = Getattr(n, "bases");
    if (baselist) {
      Iterator base = First(baselist);
      while (base.item && GetFlag(base.item, "feature:ignore"))
        base = Next(base);
      base_node = base.item;
    }

    while (base_node) {
      String *base_proxy_name = createProxyName(Getattr(base_node, "name"));
      if (!base_proxy_name)
        break;

      bool base_is_derived = false;
      Node *next_base_node = 0;
      List *base_bases = Getattr(base_node, "bases");
      if (base_bases) {
        Iterator base = First(base_bases);
        while (base.item && GetFlag(base.item, "feature:ignore"))
          base = Next(base);
        next_base_node = base.item;
        base_is_derived = next_base_node && createProxyName(Getattr(next_base_node, "name"));
      }

      SwigType *base_type = Getattr(base_node, "classtypeobj");
      SwigType *base_ptr_type = base_type ? Copy(base_type) : Copy(Getattr(base_node, "name"));
      if (!SwigType_ispointer(base_ptr_type))
        SwigType_add_pointer(base_ptr_type);

      String *cast_func = objc_cast_function_name(derived_ptr_type, base_ptr_type);
      String *base_type_str = SwigType_str(base_ptr_type, 0);
      String *base_cptr_ivar = objc_cptr_ivar_name(base_proxy_name, base_is_derived);

      if (base_ptr_type && derived_ptr_type) {
        Printf(wrap_h_code, "void* %s(void* imarg1);\n", cast_func);
        Printf(wrap_mm_code, "void* %s(void* imarg1) {\n", cast_func);
        Printf(wrap_mm_code, "#ifdef __cplusplus\n");
        Printf(wrap_mm_code, "  return (void*)((%s)%s);\n", base_type_str, cast_expr);
        Printf(wrap_mm_code, "#else\n");
        Printf(wrap_mm_code, "  return imarg1;\n");
        Printf(wrap_mm_code, "#endif\n");
        Printf(wrap_mm_code, "}\n");
      }

      Printf(objcbasecptrinit, "%s = %s(cptr);\n        ", base_cptr_ivar, cast_func);
      Printf(objcbasecptrclear, "%s = NULL;\n    ", base_cptr_ivar);

      String *next_cast_expr = NewStringf("((%s)%s)", base_type_str, cast_expr);
      Delete(cast_expr);
      cast_expr = next_cast_expr;

      Delete(base_cptr_ivar);
      Delete(base_type_str);
      Delete(cast_func);
      Delete(base_ptr_type);

      base_node = next_base_node;
    }
    Delete(cast_expr);
    Delete(derived_ptr_type);
  }

  /* Destructor handling */
  // If the C++ destructor is accessible (public), it is wrapped by the
  // dealloc() method in ObjectiveC. If it is not accessible, dealloc() method is written and throws an exception.
  String *destructor_decl = NewString("");
  String *destructor_defn = NewString("");
  const String *tm = NULL;

  String *destructor_methodname;
  String *destructor_methodmodifiers;
  attributes = NewHash();

  tm = typemapLookup(n, "objcdestructor", typemap_lookup_type, WARN_NONE, attributes);
  destructor_methodname = Getattr(attributes, "tmap:objcdestructor:methodname");
  destructor_methodmodifiers = Getattr(attributes, "tmap:objcdestructor:methodmodifiers");

  if (tm && *Char(tm)) {
    if (!destructor_methodname) {
      Swig_error(Getfile(n), Getline(n), "No methodname attribute defined in the objcdestructor typemap for %s\n", proxy_class_name);
    }
    if (!destructor_methodmodifiers) {
      Swig_error(Getfile(n), Getline(n), "No methodmodifiers attribute defined in objcdestructor typemap for %s.\n", proxy_class_name);
    }
  }

  if (tm) {
    // Write the dealloc() method declaration for the proxy interface
    Printv(destructor_decl, "\n", "-(void)", destructor_methodname, ";\n", NIL);

    // And, the dealloc() method definition for the proxy implementation
    String *destructor_code = NewString("");
    Printv(destructor_code, tm, NIL);

    if (*Char(destrcutor_call)) {
      Replaceall(destructor_code, "$imcall", destrcutor_call);
    } else {
      Replaceall(destructor_code, "$imcall", "[NSException raise:@\"UnsupportedOperationException\" format: @\"%@\", \
                       @\"C++ destructor does not have public access\"]");
    }

    if (*Char(destructor_code)) {
      Printv(destructor_defn, "\n", "-(void)", destructor_methodname, "{\n", destructor_code, "\n}\n", NIL);
    }

    Delete(destructor_code);
  }

  /* Write the proxy class declaration */
  // Class modifiers.
  const String *objcinterfacemodifier = typemapLookup(n, "objcinterfacemodifier", typemap_lookup_type, WARN_OBJC_INTERFACE_MOD);

  // User-defined protocols.
  const String *protocols = typemapLookup(n, derived ? "objcprotocols_derived" : "objcprotocols", typemap_lookup_type, WARN_NONE);

  // Default interface code
  const String *objcinterfacecode;
  if (derived) {
    objcinterfacecode = typemapLookup(n, "objcinterfacecode_derived", typemap_lookup_type, WARN_NONE);
  } else {
    objcinterfacecode = typemapLookup(n, "objcinterfacecode", typemap_lookup_type, WARN_NONE);
  }

  // the class interface
  Printf(proxy_class_forward_decls, "@class %s;\n", proxy_class_name);
  Printv(proxy_class_decl_code,
         proxy_class_imports,
         proxy_class_enums_code,
         objcinterfacemodifier,
         " $objcclassname",
         (*Char(wanted_base) || *Char(protocols)) ? " : " : "",
         wanted_base,
         (*Char(wanted_base) && *Char(protocols)) ? ", " : "",
         protocols,
         objcinterfacecode,
         proxy_class_function_decls,
         destructor_decl,
         "\n",
         typemapLookup(n, "objcclassclose", typemap_lookup_type, WARN_NONE),
         "\n\n",
         NIL);

  /* Write the proxy class definition */
  // Class modifiers.
  const String *objccimplementationmodifier = typemapLookup(n, "objcimplementationmodifier", typemap_lookup_type, WARN_OBJC_IMPLEMENTATION_MOD);

  // Default implementationcode code
  const String *objcimplementationcode;
  if (derived) {
    objcimplementationcode = typemapLookup(n, "objcimplementationcode_derived", typemap_lookup_type, WARN_NONE);
  } else {
    objcimplementationcode = typemapLookup(n, "objcimplementationcode", typemap_lookup_type, WARN_NONE);
  }

  // the class implementation
  Printv(proxy_class_defn_code,
         "\n",
         objccimplementationmodifier,
         " $objcclassname",
         objcimplementationcode,
         "\n",
         proxy_class_function_defns,
         destructor_defn,
         "\n",
         typemapLookup(n, "objcclassclose", typemap_lookup_type, WARN_NONE),
         "\n\n",
         NIL);

  Replaceall(proxy_class_decl_code, "$objcbaseclass", proxy_class_name);
  Replaceall(proxy_class_defn_code, "$objcbaseclass", proxy_class_name);
  Replaceall(proxy_class_decl_code, "$objcclasscptr", objcclasscptr);
  Replaceall(proxy_class_defn_code, "$objcclasscptr", objcclasscptr);
  Replaceall(proxy_class_decl_code, "$objccptrmethod", objccptrmethod);
  Replaceall(proxy_class_defn_code, "$objccptrmethod", objccptrmethod);
  Replaceall(proxy_class_decl_code, "$objcbasecptrinit", objcbasecptrinit);
  Replaceall(proxy_class_defn_code, "$objcbasecptrinit", objcbasecptrinit);
  Replaceall(proxy_class_decl_code, "$objcbasecptrclear", objcbasecptrclear);
  Replaceall(proxy_class_defn_code, "$objcbasecptrclear", objcbasecptrclear);

  Delete(objcclasscptr);
  Delete(objccptrmethod);
  Delete(objcbasecptrinit);
  Delete(objcbasecptrclear);
  Delete(baseclass);
  Delete(destructor_decl);
  Delete(destructor_defn);
}

/* ---------------------------------------------------------------------------
 * emitTypeWrapperClass()
 * --------------------------------------------------------------------------- */
void OBJECTIVEC::emitTypeWrapperClass(String *classname, SwigType *type) {
  Node *n = NewHash();
  Setfile(n, input_file);
  Setline(n, line_number);

  // Pure ObjectiveC baseclass and interfaces.
  const String *pure_baseclass = typemapLookup(n, "objcbase", type, WARN_NONE);
  const String *pure_interfaces = typemapLookup(n, "objcprotocols", type, WARN_NONE);

  /* Write the type wrapper class declaration */
  // Class modifiers.
  const String *objcinterfacemodifier = typemapLookup(n, "objcinterfacemodifier", type, WARN_OBJC_INTERFACE_MOD);

  // Default interface code
  const String *objcinterfacecode = typemapLookup(n, "objcinterfacecode", type, WARN_NONE);

  Printf(proxy_class_forward_decls, "@class %s;\n", classname);

  Printv(swigtypes_h_code,
         objcinterfacemodifier,
         " $objcclassname",
         (*Char(pure_baseclass) || *Char(pure_interfaces)) ? " : " : "",
         pure_baseclass,
         (*Char(pure_baseclass) && *Char(pure_interfaces)) ? ", " : "",
         pure_interfaces,
         objcinterfacecode,
         "\n",
         typemapLookup(n, "objcclassclose", type, WARN_NONE),
         "\n\n",
         NIL);

  /* Write the type wrapper class definition */
  // Class modifiers.
  const String *objccimplementationmodifier = typemapLookup(n, "objcimplementationmodifier", type, WARN_OBJC_IMPLEMENTATION_MOD);

  // Default implementationcode code
  const String *objcimplementationcode = typemapLookup(n, "objcimplementationcode", type, WARN_NONE);

  Printv(swigtypes_mm_code,
         "\n",
         objccimplementationmodifier,
         " $objcclassname",
         objcimplementationcode,
         "\n",
         typemapLookup(n, "objcclassclose", type, WARN_NONE),
         "\n\n",
         NIL);

  String *objccptrmethod = objc_cptr_method_name(classname);
  Replaceall(swigtypes_h_code, "$objcclassname", classname);
  Replaceall(swigtypes_mm_code, "$objcclassname", classname);
  Replaceall(swigtypes_h_code, "$objcclasscptr", "swigCPtr");
  Replaceall(swigtypes_mm_code, "$objcclasscptr", "swigCPtr");
  Replaceall(swigtypes_h_code, "$objccptrmethod", objccptrmethod);
  Replaceall(swigtypes_mm_code, "$objccptrmethod", objccptrmethod);
  Replaceall(swigtypes_h_code, "$objcbasecptrinit", "");
  Replaceall(swigtypes_mm_code, "$objcbasecptrinit", "");
  Replaceall(swigtypes_h_code, "$objcbasecptrclear", "");
  Replaceall(swigtypes_mm_code, "$objcbasecptrclear", "");

  Delete(objccptrmethod);
  Delete(n);
}

/* ---------------------------------------------------------------------------
 * classDirectorInit()
 * --------------------------------------------------------------------------- */
int OBJECTIVEC::classDirectorInit(Node *n) {
  Delete(director_ctor_code);
  director_ctor_code = NewString("$director_new");

  Clear(director_h_code);
  Clear(director_mm_code);
  Delete(director_connect_code);
  director_connect_code = NewString("");

  String *dirclassname = directorClassName(n);
  String *classtype = SwigType_namestr(Getattr(n, "name"));

  Printf(director_h_code, "\n#ifndef SWIG_OBJC_DIRECTOR_HELPERS\n");
  Printf(director_h_code, "#define SWIG_OBJC_DIRECTOR_HELPERS\n");
  Printf(director_h_code, "static bool SWIG_ObjectiveC_HasOverride(Class actual_class, Class base_class, SEL selector) {\n");
  Printf(director_h_code, "  if (!actual_class || !base_class)\n");
  Printf(director_h_code, "    return false;\n");
  Printf(director_h_code, "  Method actual_method = class_getInstanceMethod(actual_class, selector);\n");
  Printf(director_h_code, "  Method base_method = class_getInstanceMethod(base_class, selector);\n");
  Printf(director_h_code, "  return actual_method && (!base_method || method_getImplementation(actual_method) != method_getImplementation(base_method));\n");
  Printf(director_h_code, "}\n");
  Printf(director_h_code, "#endif\n\n");
  Printf(director_h_code, "class %s : public %s {\n", dirclassname, classtype);
  Printf(director_h_code, "public:\n");
  Printf(director_h_code, "  void swig_connect_director(SWIGObjectiveCId obj);\n");
  Printf(director_h_code, "  SWIGObjectiveCId swig_objc_self;\n");

  Delete(classtype);
  Delete(dirclassname);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------------
 * classDirectorConstructor()
 * --------------------------------------------------------------------------- */
int OBJECTIVEC::classDirectorConstructor(Node *n) {
  Node *parent = parentNode(n);
  ParmList *superparms = Getattr(n, "parms");
  String *decl = Getattr(n, "decl");
  String *dirclassname = directorClassName(parent);
  String *basetype = Getattr(parent, "classtype");
  String *target = Swig_method_decl(0, decl, dirclassname, superparms, 0);
  String *call = Swig_csuperclass_call(0, basetype, superparms);

  Printf(director_mm_code, "%s::%s : %s {\n", dirclassname, target, call);
  Printf(director_mm_code, "  swig_connect_director(0);\n");
  Printf(director_mm_code, "}\n\n");

  String *declaration = Swig_method_decl(0, decl, dirclassname, superparms, 1);
  Printf(director_h_code, "  %s;\n", declaration);

  Delete(declaration);
  Delete(call);
  Delete(target);
  Delete(dirclassname);
  return Language::classDirectorConstructor(n);
}

/* ---------------------------------------------------------------------------
 * classDirectorDefaultConstructor()
 * --------------------------------------------------------------------------- */
int OBJECTIVEC::classDirectorDefaultConstructor(Node *n) {
  String *dirclassname = directorClassName(n);
  String *basetype = Getattr(n, "classtype");

  Printf(director_mm_code, "%s::%s() : %s() {\n", dirclassname, dirclassname, basetype);
  Printf(director_mm_code, "  swig_connect_director(0);\n");
  Printf(director_mm_code, "}\n\n");
  Printf(director_h_code, "  %s();\n", dirclassname);

  Delete(dirclassname);
  return Language::classDirectorDefaultConstructor(n);
}

/* ---------------------------------------------------------------------------
 * classDirectorMethod()
 * --------------------------------------------------------------------------- */
int OBJECTIVEC::classDirectorMethod(Node *n, Node *parent, String *super) {
  String *storage = Getattr(n, "storage");
  String *value = Getattr(n, "value");
  bool pure_virtual = (!(Cmp(storage, "virtual")) && !(Cmp(value, "0")));
  bool ignored_method = GetFlag(n, "feature:ignore") ? true : false;

  if (Getattr(n, "defaultargs") && !(ignored_method && pure_virtual))
    return SWIG_OK;
  if (ignored_method && !pure_virtual)
    return SWIG_OK;

  String *name = Getattr(n, "name");
  String *symname = Getattr(n, "sym:name");
  String *decl = Getattr(n, "decl");
  SwigType *returntype = Getattr(n, "type");
  ParmList *l = Getattr(n, "parms");
  bool is_void = Cmp(returntype, "void") == 0;
  String *dirclassname = directorClassName(parent);
  String *qualified_name = NewStringf("%s::%s", dirclassname, name);
  String *selector = ignored_method ? 0 : objcSelectorForMethod(n, l);
  String *flag = ignored_method ? 0 : objc_director_flag_name(symname, decl);
  String *inline_extra_method = NewString("");
  Wrapper *w = NewWrapper();
  bool output_director = true;

  Swig_director_parms_fixup(l);
  Swig_typemap_attach_parms("objctype", l, NULL);
  Swig_typemap_attach_parms("objcdirectorintype", l, NULL);
  Swig_typemap_attach_parms("objcdirectorin", l, NULL);

  SwigType *director_return_type = Getattr(n, "conversion_operator") ? 0 : Getattr(n, "classDirectorMethods:type");
  String *target = Swig_method_decl(director_return_type, decl, qualified_name, l, 0);
  Printf(w->def, "%s", target);
  Delete(target);
  target = Swig_method_decl(director_return_type, decl, name, l, 1);
  if (!ignored_method)
    Printf(director_h_code, "  bool %s;\n", flag);
  Printf(director_h_code, "  virtual %s", target);
  if (dirprot_mode() && !is_public(n) && !pure_virtual) {
    Printf(inline_extra_method, "  %s", target);
    String *extra_method_name = NewStringf("%sSwigPublic", name);
    Replaceall(inline_extra_method, name, extra_method_name);
    Append(inline_extra_method, " {\n    ");
    if (!is_void)
      Append(inline_extra_method, "return ");
    String *methodcall = Swig_method_call(super, l);
    Printv(inline_extra_method, methodcall, ";\n  }\n", NIL);
    Delete(methodcall);
    Delete(extra_method_name);
  }
  Delete(target);

  if (Getattr(n, "noexcept")) {
    Append(w->def, " noexcept");
    Append(director_h_code, " noexcept");
  }
  ParmList *throw_parm_list = NULL;
  if ((throw_parm_list = Getattr(n, "throws")) || Getattr(n, "throw")) {
    int gencomma = 0;
    Append(w->def, " throw(");
    Append(director_h_code, " throw(");
    if (throw_parm_list)
      Swig_typemap_attach_parms("throws", throw_parm_list, 0);
    for (Parm *p = throw_parm_list; p; p = nextSibling(p)) {
      if (Getattr(p, "tmap:throws")) {
        if (gencomma++) {
          Append(w->def, ", ");
          Append(director_h_code, ", ");
        }
        Printf(w->def, "%s", SwigType_str(Getattr(p, "type"), 0));
        Printf(director_h_code, "%s", SwigType_str(Getattr(p, "type"), 0));
      }
    }
    Append(w->def, ")");
    Append(director_h_code, ")");
  }
  Append(w->def, " {\n");
  Append(director_h_code, ";\n");
  Printv(director_h_code, inline_extra_method, NIL);

  if (!ignored_method)
    Printf(director_connect_code, "  %s = SWIG_ObjectiveC_HasOverride(actual_class, base_class, @selector(%s));\n", flag, selector);

  String *objc_return_type = 0;
  if (!is_void) {
    objc_return_type = Swig_typemap_lookup("objcdirectorouttype", n, "", 0);
    if (!objc_return_type)
      objc_return_type = Swig_typemap_lookup("objctype", n, "", 0);
    if (!objc_return_type) {
      Swig_warning(
        WARN_OBJC_TYPEMAP_OBJCTYPE_UNDEF, Getfile(n), Getline(n), "No objctype typemap defined for director return type %s\n", SwigType_str(returntype, 0));
      output_director = false;
    } else {
      substituteClassname(objc_return_type, returntype);
      String *ret_ltype = SwigType_lstr(returntype, "c_result");
      if (SwigType_ispointer(returntype) || SwigType_isreference(returntype)) {
        Wrapper_add_localv(w, "c_result", ret_ltype, "= 0", NIL);
      } else {
        String *ret_base = SwigType_lstr(returntype, 0);
        String *init = NewStringf("= SwigValueInit< %s >()", ret_base);
        Wrapper_add_localv(w, "c_result", ret_ltype, init, NIL);
        Delete(init);
        Delete(ret_base);
      }
      Delete(ret_ltype);
    }
  }

  if (ignored_method) {
    Printf(w->code,
           "  SWIG_ObjcThrowException(SWIG_ObjcDirectorPureVirtual, \"Attempted to invoke ignored pure virtual method %s::%s\");\n",
           SwigType_namestr(Getattr(parent, "name")),
           SwigType_namestr(name));
    if (!is_void) {
      String *qualified_return = SwigType_rcaststr(returntype, "c_result");
      Printf(w->code, "  return %s;\n", qualified_return);
      Delete(qualified_return);
    } else {
      Printf(w->code, "  return;\n");
    }
    Printf(w->code, "}\n");
    if (output_director)
      Wrapper_print(w, director_mm_code);
    Delete(inline_extra_method);
    Delete(objc_return_type);
    DelWrapper(w);
    Delete(flag);
    Delete(selector);
    Delete(qualified_name);
    Delete(dirclassname);
    return output_director ? SWIG_OK : SWIG_NOWRAP;
  }

  Printf(w->code, "  if (!swig_objc_self || !%s) {\n", flag);
  if (!pure_virtual) {
    String *super_call = Swig_method_call(super, l);
    if (is_void) {
      Printf(w->code, "    %s;\n", super_call);
      Printf(w->code, "    return;\n");
    } else {
      Printf(w->code, "    return %s;\n", super_call);
    }
    Delete(super_call);
  } else {
    Printf(w->code,
           "    SWIG_ObjcThrowException(SWIG_ObjcDirectorPureVirtual, \"Attempted to invoke pure virtual method %s::%s\");\n",
           SwigType_namestr(Getattr(parent, "name")),
           SwigType_namestr(name));
    if (!is_void) {
      String *qualified_return = SwigType_rcaststr(returntype, "c_result");
      Printf(w->code, "    return %s;\n", qualified_return);
      Delete(qualified_return);
    } else {
      Printf(w->code, "    return;\n");
    }
  }
  Printf(w->code, "  }\n");

  String *callback_typedef_parms = NewString("");
  String *callback_args = NewString("");
  int arg_index = 0;
  for (Parm *p = l; p; p = nextInputArg(p), arg_index++) {
    p = skipIgnoredArgs(p);
    if (!p)
      break;

    SwigType *pt = Getattr(p, "type");
    String *arg = makeParameterName(n, p, arg_index, false);
    String *objc_type = Getattr(p, "tmap:objcdirectorintype");
    if (!objc_type)
      objc_type = Getattr(p, "tmap:objctype");
    String *din = Getattr(p, "tmap:objcdirectorin");

    if (!objc_type || !din) {
      Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF,
                   Getfile(n),
                   Getline(n),
                   "No Objective-C director typemap defined for argument %s in %s::%s\n",
                   SwigType_str(pt, 0),
                   SwigType_namestr(Getattr(parent, "name")),
                   SwigType_namestr(name));
      output_director = false;
    } else {
      objc_type = Copy(objc_type);
      substituteClassname(objc_type, pt);
      din = Copy(din);
      substituteClassname(din, pt);
      Replaceall(din, "$input", arg);
      Printf(callback_typedef_parms, ", %s", objc_type);
      Printf(callback_args, ", %s", din);
      Delete(din);
      Delete(objc_type);
    }
    Delete(arg);
  }

  String *callback_type = NewStringf("SWIG_ObjCMsgSend_%s_t", flag);
  if (is_void)
    Printf(w->code, "  typedef void (*%s)(SWIGObjectiveCId, SEL%s);\n", callback_type, callback_typedef_parms);
  else
    Printf(w->code, "  typedef %s (*%s)(SWIGObjectiveCId, SEL%s);\n", objc_return_type, callback_type, callback_typedef_parms);

  if (is_void) {
    Printf(w->code, "  ((%s)objc_msgSend)(swig_objc_self, @selector(%s)%s);\n", callback_type, selector, callback_args);
    Printf(w->code, "  return;\n");
  } else {
    Wrapper_add_localv(w, "objc_result", NewStringf("%s objc_result", objc_return_type), NIL);
    Printf(w->code, "  objc_result = ((%s)objc_msgSend)(swig_objc_self, @selector(%s)%s);\n", callback_type, selector, callback_args);
    String *result_str = NewString("c_result");
    String *input_str = NewString("objc_result");
    String *tm = Swig_typemap_lookup("objcdirectorout", n, result_str, w);
    if (tm) {
      Replaceall(tm, "$input", input_str);
      Replaceall(tm, "$result", result_str);
      Printf(w->code, "%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF,
                   Getfile(n),
                   Getline(n),
                   "No Objective-C directorout typemap defined for return type %s in %s::%s\n",
                   SwigType_str(returntype, 0),
                   SwigType_namestr(Getattr(parent, "name")),
                   SwigType_namestr(name));
      output_director = false;
    }
    String *qualified_return = SwigType_rcaststr(returntype, "c_result");
    Printf(w->code, "  return %s;\n", qualified_return);
    Delete(qualified_return);
    Delete(input_str);
    Delete(result_str);
  }

  Printf(w->code, "}\n");

  if (output_director && !Getattr(n, "defaultargs"))
    Wrapper_print(w, director_mm_code);

  Delete(callback_type);
  Delete(callback_args);
  Delete(callback_typedef_parms);
  Delete(inline_extra_method);
  Delete(objc_return_type);
  DelWrapper(w);
  Delete(flag);
  Delete(selector);
  Delete(qualified_name);
  Delete(dirclassname);
  return output_director ? SWIG_OK : SWIG_NOWRAP;
}

/* ---------------------------------------------------------------------------
 * classDirectorEnd()
 * --------------------------------------------------------------------------- */
int OBJECTIVEC::classDirectorEnd(Node *n) {
  String *dirclassname = directorClassName(n);
  String *objcclassname = Getattr(n, "sym:name");
  String *wname = objcDirectorConnectWrapperName(n);
  String *classtype = SwigType_namestr(Getattr(n, "name"));

  Printf(director_h_code, "};\n\n");
  Printf(director_mm_code, "void %s::swig_connect_director(SWIGObjectiveCId obj) {\n", dirclassname);
  Printf(director_mm_code, "  swig_objc_self = obj;\n");
  Printf(director_mm_code, "  Class actual_class = obj ? ((Class (*)(SWIGObjectiveCId))object_getClass)(obj) : 0;\n");
  Printf(director_mm_code, "  Class base_class = objc_getClass(\"%s\");\n", objcclassname);
  Printv(director_mm_code, director_connect_code, NIL);
  Printf(director_mm_code, "}\n\n");

  Printv(f_wrappers, director_h_code, director_mm_code, NIL);
  Clear(director_h_code);
  Clear(director_mm_code);
  Delete(director_connect_code);
  director_connect_code = 0;

  Printf(wrap_h_code, "void %s(void* imarg1, void* imarg2);\n", wname);
  Printf(wrap_mm_code, "void %s(void* imarg1, void* imarg2) {\n", wname);
  Printf(wrap_mm_code, "#ifdef __cplusplus\n");
  Printf(wrap_mm_code, "  %s *director = dynamic_cast<%s *>((%s *)imarg1);\n", dirclassname, dirclassname, classtype);
  Printf(wrap_mm_code, "  if (director)\n");
  Printf(wrap_mm_code, "    director->swig_connect_director((SWIGObjectiveCId)imarg2);\n");
  Printf(wrap_mm_code, "#endif\n");
  Printf(wrap_mm_code, "}\n");

  Delete(classtype);
  Delete(wname);
  Delete(dirclassname);
  return SWIG_OK;
}

int OBJECTIVEC::classDirectorDisown(Node *n) {
  (void)n;
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * substituteClassname()
 *
 * Substitute $objcclassname with the proxy class name for classes/structs/unions that SWIG knows about.
 * Also substitutes enums with enum name.
 * Otherwise use the $descriptor name for the Objective-C class name. Note that the $&objcclassname substitution
 * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
 *
 * Inputs:
 *   tm - String to perform the substitution at (will usually come from a
 *        typemap.
 *   pt - The type to substitute for the variables.
 * Outputs:
 *   tm - String with the variables substituted.
 * Return:
 *   substitution_performed - flag indicating if a substitution was performed
 * ----------------------------------------------------------------------------- */

bool OBJECTIVEC::substituteClassname(String *tm, SwigType *pt) {
  bool substitution_performed = false;
  SwigType *type = Copy(SwigType_typedef_resolve_all(pt));
  SwigType *strippedtype = SwigType_strip_qualifiers(type);

  if (Strstr(tm, "$objcclassname")) {
    SwigType *type = Copy(strippedtype);
    substituteClassnameVariable(tm, "$objcclassname", type);
    substitution_performed = true;
    Delete(type);
  }
  if (Strstr(tm, "$*objcclassname")) {
    SwigType *type = Copy(strippedtype);
    Delete(SwigType_pop(type));
    substituteClassnameVariable(tm, "$*objcclassname", type);
    substitution_performed = true;
    Delete(type);
  }
  if (Strstr(tm, "$&objcclassname")) {
    SwigType *type = Copy(strippedtype);
    SwigType_add_pointer(type);
    substituteClassnameVariable(tm, "$&objcclassname", type);
    substitution_performed = true;
    Delete(type);
  }

  Delete(strippedtype);
  Delete(type);

  return substitution_performed;
}

/* -----------------------------------------------------------------------------
 * substituteClassnameVariable()
 * ----------------------------------------------------------------------------- */

void OBJECTIVEC::substituteClassnameVariable(String *tm, const char *classnamevariable, SwigType *type) {
  String *type_name;

  if (SwigType_isenum(type)) {
    Node *n = enumLookup(type);
    if (n && Equal(nodeType(n), "enum") && GetFlag(n, "nonempty")) {
      String *enum_name = Getattr(n, "sym:name");
      Node *p = parentNode(n);
      if (p && !Strcmp(nodeType(p), "class")) {
        // This is a nested enum.
        String *parent_name = Getattr(p, "sym:name");
        type_name = NewStringf("enum %s_%s", parent_name, enum_name);
      } else {
        type_name = NewStringf("enum %s", enum_name);
      }
    } else {
      // The enum was only seen as a type reference or as an incomplete
      // forward declaration. Use int so the proxy can still compile.
      type_name = NewString("int");
    }
  } else {
    String *class_name = createProxyName(type);
    if (class_name) {
      type_name = Copy(class_name);
    } else {
      // SWIG does not know anything about the type (after resolving typedefs).
      // Just mangle the type name string like $descriptor(type) would do.
      String *descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(type));
      type_name = Copy(descriptor);

      // Add to hash table so that the type wrapper classes can be created later
      Setattr(unknown_types, descriptor, type);
      Delete(descriptor);
    }
  }
  Replaceall(tm, classnamevariable, type_name);
  Delete(type_name);
}

/* -----------------------------------------------------------------------------
 * proxyEnumValue()
 *
 * Objective-C enum initializers are emitted into the proxy header, which must be
 * valid for both Objective-C and Objective-C++. Strip C++-only casts and scopes
 * that cannot be resolved from the proxy layer.
 * ----------------------------------------------------------------------------- */

String *OBJECTIVEC::proxyEnumValue(String *value) {
  return objc_sanitize_cast_value(value, true);
}

/* -----------------------------------------------------------------------------
 * proxyConstantValue()
 *
 * Constants live in the proxy implementation, not in the wrapper translation
 * unit where %inline declarations are compiled. Prefer generated wrapper
 * accessors for imported/global constants and otherwise strip C++ scopes/casts
 * to keep the proxy source compilable.
 * ----------------------------------------------------------------------------- */

String *OBJECTIVEC::proxyConstantValue(String *value) {
  String *sanitized = objc_sanitize_cast_value(value, false);
  String *last_component = objc_last_qualified_component(sanitized);
  String *accessor_candidate = last_component ? Copy(last_component) : (objc_is_plain_identifier(sanitized) ? Copy(sanitized) : 0);

  if (accessor_candidate) {
    String *getname = Swig_name_get(getNSpace(), accessor_candidate);
    String *wrapped_getname = Swig_name_wrapper(getname);
    String *needle = NewStringf("%s(", wrapped_getname);
    if (wrap_h_code && Strstr(wrap_h_code, needle)) {
      String *call = NewStringf("%s()", wrapped_getname);
      Delete(needle);
      Delete(wrapped_getname);
      Delete(getname);
      Delete(accessor_candidate);
      Delete(last_component);
      Delete(sanitized);
      return call;
    }
    Delete(needle);
    Delete(wrapped_getname);
    Delete(getname);
    String *mapped_constant = Getattr(proxy_constant_names, accessor_candidate);
    if (mapped_constant) {
      String *mapped = Copy(mapped_constant);
      Delete(accessor_candidate);
      Delete(last_component);
      Delete(sanitized);
      return mapped;
    }
    Delete(accessor_candidate);
  }

  String *expanded_expression = proxyConstantExpression(sanitized);
  if (expanded_expression) {
    Delete(last_component);
    Delete(sanitized);
    return expanded_expression;
  }

  if (last_component) {
    Delete(sanitized);
    return last_component;
  }

  return sanitized;
}

/* -----------------------------------------------------------------------------
 * proxyConstantExpression()
 *
 * Replace previously emitted proxy/wrapper constants inside a constant expression.
 * This keeps proxy implementation files independent from declarations that only
 * exist in the wrapper translation unit.
 * ----------------------------------------------------------------------------- */

String *OBJECTIVEC::proxyConstantExpression(String *value) {
  if (!value)
    return 0;

  const char *s = Char(value);
  int len = Len(value);
  String *expanded = NewString("");
  bool changed = false;

  for (int i = 0; i < len;) {
    if (objc_identifier_start(s[i])) {
      int start = i++;
      while (i < len && objc_identifier_char(s[i]))
        ++i;
      String *token = NewStringWithSize(s + start, i - start);
      String *replacement = 0;

      if (Cmp(token, "sizeof") != 0 && Cmp(token, "alignof") != 0 && Cmp(token, "true") != 0 && Cmp(token, "false") != 0) {
        String *getname = Swig_name_get(getNSpace(), token);
        String *wrapped_getname = Swig_name_wrapper(getname);
        String *needle = NewStringf("%s(", wrapped_getname);
        if (wrap_h_code && Strstr(wrap_h_code, needle)) {
          replacement = NewStringf("%s()", wrapped_getname);
        } else {
          String *mapped_constant = Getattr(proxy_constant_names, token);
          if (mapped_constant)
            replacement = Copy(mapped_constant);
        }
        Delete(needle);
        Delete(wrapped_getname);
        Delete(getname);
      }

      if (replacement) {
        Printv(expanded, replacement, NIL);
        changed = true;
        Delete(replacement);
      } else {
        Printv(expanded, token, NIL);
      }
      Delete(token);
    } else {
      Putc(s[i++], expanded);
    }
  }

  if (!changed) {
    Delete(expanded);
    return 0;
  }

  return expanded;
}

/* -----------------------------------------------------------------------------
 * proxyConstantExpressionNeedsAccessor()
 *
 * Return true when a proxy constant expression references a wrapped global that
 * is only available through a generated getter. Such expressions are valid in
 * wrapper code, but not as C global initializers in the proxy implementation.
 * ----------------------------------------------------------------------------- */

bool OBJECTIVEC::proxyConstantExpressionNeedsAccessor(String *value) {
  if (!value)
    return false;

  const char *s = Char(value);
  int len = Len(value);

  for (int i = 0; i < len;) {
    if (objc_identifier_start(s[i])) {
      int start = i++;
      while (i < len && objc_identifier_char(s[i]))
        ++i;
      String *token = NewStringWithSize(s + start, i - start);
      bool needs_accessor = false;

      if (Cmp(token, "sizeof") != 0 && Cmp(token, "alignof") != 0 && Cmp(token, "true") != 0 && Cmp(token, "false") != 0) {
        String *getname = Swig_name_get(getNSpace(), token);
        String *wrapped_getname = Swig_name_wrapper(getname);
        String *needle = NewStringf("%s(", wrapped_getname);
        needs_accessor = wrap_h_code && Strstr(wrap_h_code, needle);
        Delete(needle);
        Delete(wrapped_getname);
        Delete(getname);
      }

      Delete(token);

      if (needs_accessor)
        return true;
    } else {
      ++i;
    }
  }

  return false;
}

/* -----------------------------------------------------------------------------
 * objcStringLiteral()
 *
 * Objective-C string literals cannot use the C preprocessor form @("text").
 * Strip one harmless pair of outer parentheses around a string literal.
 * ----------------------------------------------------------------------------- */

String *OBJECTIVEC::objcStringLiteral(String *value) {
  if (!value)
    return NewString("\"\"");

  const char *s = Char(value);
  int len = Len(value);
  int start = objc_skip_spaces(s, 0, len);
  int end = objc_trim_end(s, start, len);
  if (start < end && s[start] == '(' && s[end - 1] == ')') {
    int inner_start = objc_skip_spaces(s, start + 1, end - 1);
    if (inner_start < end - 1 && s[inner_start] == '"')
      return objc_copy_trimmed_range(s, start + 1, end - 1);
  }
  return objc_copy_trimmed_range(s, start, end);
}

String *OBJECTIVEC::objcSelectorForMethod(Node *n, ParmList *parmlist) {
  String *selector = Copy(Getattr(n, "sym:name"));
  if (objc_is_reserved_method_family_name(selector)) {
    String *renamed = objc_swig_method_name(selector);
    Delete(selector);
    selector = renamed;
  }

  Swig_typemap_attach_parms("objctype", parmlist, NULL);
  int i = 0;
  int gencomma = 0;
  for (Parm *p = parmlist; p; p = nextInputArg(p), i++) {
    p = skipIgnoredArgs(p);
    if (!p)
      break;
    String *arg = makeParameterName(n, p, i, false);
    if (gencomma == 0) {
      Printf(selector, ":");
    } else {
      Printf(selector, "%s:", arg);
    }
    gencomma++;
    Delete(arg);
  }
  return selector;
}

String *OBJECTIVEC::objcDirectorConnectWrapperName(Node *n) {
  String *symname = Getattr(n, "sym:name");
  String *connect_name = Swig_name_member(getNSpace(), symname, "director_connect");
  String *wname = Swig_name_wrapper(connect_name);
  Delete(connect_name);
  return wname;
}

/* ---------------------------------------------------------------------
 * isVarargs()
 *
 * --------------------------------------------------------------------- */
bool OBJECTIVEC::isVarargs(Parm *p) const {
  if (!p)
    return false;

  SwigType *pt = Getattr(p, "type");
  if (!pt)
    return false;

  String *type = SwigType_str(pt, 0);
  bool result = Cmp(type, "...") == 0;
  Delete(type);
  return result;
}

/* ---------------------------------------------------------------------
 * skipIgnoredArgs()
 *
 * --------------------------------------------------------------------- */
Parm *OBJECTIVEC::skipIgnoredArgs(Parm *p) {
  while (p && checkAttribute(p, "tmap:in:numinputs", "0")) {
    p = Getattr(p, "tmap:in:next");
  }
  while (p && isVarargs(p)) {
    p = nextSibling(p);
  }
  return p;
}

/* ---------------------------------------------------------------------
 * nextInputArg()
 *
 * --------------------------------------------------------------------- */
Parm *OBJECTIVEC::nextInputArg(Parm *p) const {
  if (!p)
    return 0;
  if (Getattr(p, "tmap:in"))
    return Getattr(p, "tmap:in:next");
  return nextSibling(p);
}

/* ---------------------------------------------------------------------
 * marshalInputArgs()
 *
 * Process all of the arguments passed and convert them into C/C++
 * function arguments using the supplied typemaps.
 * --------------------------------------------------------------------- */

void OBJECTIVEC::marshalInputArgs(ParmList *parmlist, Wrapper *wrapper) {
  String *tm;
  Parm *p;
  int i = 0;

  for (p = parmlist; p; p = nextInputArg(p), i++) {
    p = skipIgnoredArgs(p);
    if (!p)
      break;
    SwigType *pt = Getattr(p, "type");

    String *arg = NewString("");
    Printf(arg, "imarg%d", i + 1);

    // Get the "in" typemap for this argument and add to the wrapper->code
    if ((tm = Getattr(p, "tmap:in"))) {
      Replaceall(tm, "$input", arg);
      Setattr(p, "emit:input", arg);
      Printf(wrapper->code, "%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
    }
    Delete(arg);
  }
}

/* ---------------------------------------------------------------------
 * makeParameterList()
 *
 * --------------------------------------------------------------------- */

void OBJECTIVEC::makeParameterList(ParmList *parmlist, Wrapper *wrapper) {

  // Attach the non-standard typemaps to the parameter list
  Swig_typemap_attach_parms("imtype", parmlist, wrapper);

  String *tm;
  Parm *p;
  int i = 0;
  int gencomma = 0;

  for (p = parmlist; p; p = nextInputArg(p), i++) {
    p = skipIgnoredArgs(p);
    if (!p)
      break;
    SwigType *pt = Getattr(p, "type");

    String *imparmtype = NewString("");
    String *arg = NewString("");

    Printf(arg, "imarg%d", i + 1);

    // Get the intermediate parameter type for this parameter
    if ((tm = Getattr(p, "tmap:imtype"))) {
      Printv(imparmtype, tm, NIL);
      if (gencomma)
        Printf(wrapper->def, ", ");
      Printv(wrapper->def, imparmtype, " ", arg, NIL);  // Add parameter to the function signature (wrapper->def)
      ++gencomma;
    } else {
      Swig_warning(WARN_OBJC_TYPEMAP_IMTYPE_UNDEF, input_file, line_number, "No imtype typemap defined for %s\n", SwigType_str(pt, 0));
    }

    Delete(imparmtype);
    Delete(arg);
  }
}

/* ---------------------------------------------------------------------
 * marshalOutput()
 *
 * Process the return value of the C/C++ function call
 * and convert it into the intermediate type using the
 * supplied typemaps.
 * --------------------------------------------------------------------- */

void OBJECTIVEC::marshalOutput(Node *n, String *actioncode, Wrapper *wrapper) {
  SwigType *type = Getattr(n, "type");
  // Emit the out typemap
  String *tm;
  if ((tm = Swig_typemap_lookup_out("out", n, "result", wrapper, actioncode))) {
    Replaceall(tm, "$result", "imresult");
    Printf(wrapper->code, "%s", tm);
    if (Len(tm))
      Printf(wrapper->code, "\n");
  } else {
    Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(type, 0), Getattr(n, "name"));
  }
  // Emits a variable declaration for a function return value
  emit_return_variable(n, type, wrapper);
}

/* ---------------------------------------------------------------------------
 * makeParameterName()
 *
 * Inputs:
 *   n - Node
 *   p - parameter node
 *   arg_num - parameter argument number
 *   setter  - set this flag when wrapping variables
 * Return:
 *   arg - a unique parameter name
 * --------------------------------------------------------------------------- */
String *OBJECTIVEC::makeParameterName(Node *n, Parm *p, int argnumber, bool setter) const {
  String *arg = 0;
  String *pn = Getattr(p, "name");

  // Use C parameter name unless it is a duplicate or an empty parameter name
  int count = 0;
  ParmList *plist = Getattr(n, "parms");
  while (plist) {
    if ((Cmp(pn, Getattr(plist, "name")) == 0))
      count++;
    plist = nextSibling(plist);
  }
  String *wrn = pn ? Swig_name_warning(p, 0, pn, 0) : 0;
  arg = (!pn || (count > 1) || wrn) ? NewStringf("arg%d", argnumber) : Copy(pn);

  if (setter && Cmp(arg, "self") != 0) {
    // In theory, we could use the normal parameter name for setter functions.
    // Unfortunately, it is set to "Class::VariableName" for static public
    // members by the parser, which is not legal ObjectiveC syntax. Thus, we just force
    // it to "value".
    Delete(arg);
    arg = NewString("value");
  }

  return arg;
}

/* -----------------------------------------------------------------------------
 * createProxyName()
 *
 * Returns the ObjectiveC class name if a type corresponds to something wrapped with a
 * proxy class, NULL otherwise.
 * ----------------------------------------------------------------------------- */

String *OBJECTIVEC::createProxyName(SwigType *t) {
  if (proxy_flag) {
    Node *n = classLookup(t);
    if (n) {
      return Getattr(n, "sym:name");
    }
  }
  return NULL;
}

/* -----------------------------------------------------------------------------
 * typemapLookup()
 * n - for input only and must contain info for Getfile(n) and Getline(n) to work
 * tmap_method - typemap method name
 * type - typemap type to lookup
 * warning - warning number to issue if no typemaps found
 * typemap_attributes - the typemap attributes are attached to this node and will
 *   also be used for temporary storage if non null
 * return is never NULL, unlike Swig_typemap_lookup()
 * ----------------------------------------------------------------------------- */

const String *OBJECTIVEC::typemapLookup(Node *n, const_String_or_char_ptr tmap_method, SwigType *type, int warning, Node *typemap_attributes) {
  Node *node = !typemap_attributes ? NewHash() : typemap_attributes;
  Setattr(node, "type", type);
  Setfile(node, Getfile(n));
  Setline(node, Getline(n));
  const String *tm = Swig_typemap_lookup(tmap_method, node, "", 0);
  if (!tm) {
    tm = empty_string;
    if (warning != WARN_NONE)
      Swig_warning(warning, Getfile(n), Getline(n), "No %s typemap defined for %s\n", tmap_method, SwigType_str(type, 0));
  }
  if (!typemap_attributes)
    Delete(node);
  return tm;
}

/* -----------------------------------------------------------------------------
 * swig_objectivec()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_objectivec() {
  return new OBJECTIVEC();
}
extern "C" Language *swig_objectivec(void) {
  return new_swig_objectivec();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

// Usage message.
const char *const OBJECTIVEC::usage = (char *)"\
ObjectiveC options (available with -objc)\n\
    -noproxy    - Do not generate proxy files (Only C wrappers will be generated) \n\
    -help       - This message \n\
\n";

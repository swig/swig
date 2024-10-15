/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * javascript.cxx
 *
 * Javascript language module for SWIG.
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"
#include "cparse.h"

/**
 * Enables extra debugging information in typemaps.
 */
static bool js_template_enable_debug = false;

/**
 * Create async wrappers by default (NAPI only) 
 */
static bool js_napi_default_is_async = false;
static bool js_napi_default_is_locked = false;

/**
 * Enable code splitting (NAPI only)
 */
static bool code_splitting = false;

/**
 * Generate an exports file (NAPI only)
 */
static String *js_napi_generate_exports = NULL;

/**
 * Enable debug
 */
static bool js_debug_tstypes = false;

#define ERR_MSG_ONLY_ONE_ENGINE_PLEASE "Only one engine can be specified at a time."

// keywords used for state variables
#define NAME "name"
#define NAME_MANGLED "name_mangled"
#define INDEX "idx"
#define TYPE "type"
#define TYPE_MANGLED "type_mangled"
#define WRAPPER_NAME "wrapper"
#define IS_IMMUTABLE "is_immutable"
#define IS_STATIC "is_static"
#define IS_ABSTRACT "is_abstract"
#define IS_WRAPPED "is_wrapped"
#define GETTER "getter"
#define SETTER "setter"
#define PARENT "parent"
#define PARENT_MANGLED "parent_mangled"
#define CTOR "ctor"
#define CTOR_WRAPPERS "ctor_wrappers"
#define CTOR_DISPATCHERS "ctor_dispatchers"
#define DTOR "dtor"
#define ARGCOUNT "wrap:argc"
#define ARGREQUIRED "wrap:argmin"
#define HAS_TEMPLATES "has_templates"
#define FORCE_CPP "force_cpp"
#define RESET true

// keys for global state variables
#define CREATE_NAMESPACES "create_namespaces"
#define REGISTER_NAMESPACES "register_namespaces"
#define INITIALIZER "initializer"

// keys for class scoped state variables
#define MEMBER_VARIABLES "member_variables"
#define MEMBER_FUNCTIONS "member_functions"
#define STATIC_FUNCTIONS "static_functions"
#define STATIC_VARIABLES "static_variables"

// the global wrappers
#define GLOBAL_WRAPPERS "global"


/**
 * A convenience class to manage state variables for emitters.
 * The implementation delegates to SWIG Hash DOHs and provides
 * named sub-hashes for class, variable, and function states.
 */
class JSEmitterState {

public:
  JSEmitterState();
  ~JSEmitterState();
  DOH *globals();
  DOH *globals(const char *key, DOH *initial = 0);
  DOH *types();
  DOH *types(DOH *key, DOH *initial = 0);
  DOH *clazz(bool reset = false);
  DOH *clazz(const char *key, DOH *initial = 0);
  DOH *function(bool reset = false);
  DOH *function(const char *key, DOH *initial = 0);
  DOH *variable(bool reset = false);
  DOH *variable(const char *key, DOH *initial = 0);
  static int IsSet(DOH *val, int def = 0);

private:
  DOH *getState(const char *key, bool reset = false);
  Hash *globalHash;
  Hash *typesHash;
};

/**
 * A convenience class that wraps a code snippet used as template
 * for code generation.
 */
class Template {

public:
  Template(const String *code);
  Template(const String *code, const String *templateName);
  Template(const Template & other);
  ~Template();
  String *str();
  Template & replace(const String *pattern, const String *repl);
  Template & print(DOH *doh);
  Template & pretty_print(DOH *doh);
  void operator=(const Template & t);
  Template & trim();

private:
  String *code;
  String *templateName;
};

/**
 * JSEmitter represents an abstraction of javascript code generators
 * for different javascript engines.
 **/
class JSEmitter {
  friend class TYPESCRIPT;

protected:

  typedef JSEmitterState State;

  enum MarshallingMode {
    Setter,
    Getter,
    Ctor,
    Function
  };

public:

   enum JSEngine {
     JavascriptCore,
     V8,
     NodeJS,
     NAPI
   };

   JSEmitter(JSEngine engine);

   virtual ~ JSEmitter();

  /**
   * Opens output files and temporary output DOHs.
   */
  virtual int initialize(Node *n);

  /**
   * Writes all collected code into the output file(s).
   */
  virtual int dump(Node *n) = 0;

  /**
   * Cleans up all open output DOHs.
   */
  virtual int close() = 0;

  /**
   * Switches the context for code generation.
   *
   * Classes, global variables and global functions may need to
   * be registered in certain static tables.
   * This method should be used to switch output DOHs correspondingly.
   */
  virtual int switchNamespace(Node *);

  /**
   * Invoked at the beginning of the classHandler.
   */
  virtual int enterClass(Node *);

  /**
   * Invoked at the end of the classHandler.
   */
  virtual int exitClass(Node *) {
    return SWIG_OK;
  }

  /**
   * Invoked at the beginning of the variableHandler.
   */
  virtual int enterVariable(Node *);

  /**
   * Invoked at the end of the variableHandler.
   */
  virtual int exitVariable(Node *) {
    return SWIG_OK;
  }

  /**
   * Invoked at the beginning of the functionHandler.
   */
  virtual int enterFunction(Node *);

  /**
   * Invoked at the end of the functionHandler.
   */
  virtual int exitFunction(Node *) {
    return SWIG_OK;
  }

  /**
   * Invoked by functionWrapper callback after call to Language::functionWrapper.
   */
  virtual int emitWrapperFunction(Node *n);

  /**
   * Invoked by nativeWrapper callback
   */
  virtual int emitNativeFunction(Node *n);

  /**
   * Invoked from constantWrapper after call to Language::constantWrapper.
   **/
  virtual int emitConstant(Node *n);

  /**
   * Registers a given code snippet for a given key name.
   *
   * This method is called by the fragmentDirective handler
   * of the JAVASCRIPT language module.
   **/
  int registerTemplate(const String *name, const String *code);

  /**
   * Retrieve the code template registered for a given name.
   */
  Template getTemplate(const String *name);

  State & getState();

protected:

  /**
   * Helper function for detecting if the constructor Node does not use a name that matches
   * the expected name for a constructor. Occurs when %rename is used for just a constructor
   * or %template instantiates a templated constructor with a different name to the class.
   */
  bool isRenamedConstructor(Node *n);

  /**
   * Generates code for a constructor function.
   */
  virtual int emitCtor(Node *n);

  /**
   * Generates code for a destructor function.
   */
  virtual int emitDtor(Node *n);

  /**
   * Identifies if a node represents a function
   */
  virtual bool isFunction(Node *);
  /**
   * Generates code for a function.
   */
  virtual int emitFunction(Node *n, bool is_member, bool is_static);

  virtual int emitFunctionDispatcher(Node *n, bool /*is_member */ );

  /**
   * Generates code for a getter function.
   */
  virtual int emitGetter(Node *n, bool is_member, bool is_static);

  /**
   * Generates code for a setter function.
   */
  virtual int emitSetter(Node *n, bool is_member, bool is_static);

  virtual void marshalInputArgs(Node *n, ParmList *parms, Wrapper *wrapper, MarshallingMode mode, bool is_member, bool is_static) = 0;

  virtual String *emitInputTypemap(Node *n, Parm *params, Wrapper *wrapper, String *arg);

  virtual String *emitCheckTypemap(Node *n, Parm *params, Wrapper *wrapper, String *arg);

  virtual void marshalOutput(Node *n, ParmList *params, Wrapper *wrapper, String *actioncode, const String *cresult = 0, bool emitReturnVariable = true);

  virtual String *emitCleanupCode(Node *n, ParmList *params);

  /**
   * Helper function to retrieve the first parent class node.
   */
  Node *getBaseClass(Node *n);

  virtual int createNamespace(String *scope);

  virtual Hash *createNamespaceEntry(Hash *, const char *name, const char *parent, const char *parent_mangled);

  virtual int emitNamespaces() = 0;

  /**
   * Return the full JS prefix of the current namespace
   * ie "Outer.Inner." or "" if it is the global one
   */
  virtual String* currentNamespacePrefix();

  virtual const char *getGetterTemplate(bool);

  /**
   * Identify if an argument is optional or not
   */
  bool isArgOptional(Node *, Parm *);

protected:

  JSEngine engine;
  Hash *templates;
  State state;

  // contains context specific data (DOHs)
  // to allow generation of namespace related code
  // which are switched on namespace change
  Hash *namespaces;
  Hash *current_namespace;
  String *defaultResultName;
  File *f_wrappers;
};

/* factory methods for concrete JSEmitters: */

JSEmitter *swig_javascript_create_JSCEmitter();
JSEmitter *swig_javascript_create_V8Emitter();
JSEmitter *swig_javascript_create_NodeJSEmitter();
JSEmitter *swig_javascript_create_NAPIEmitter();

/*
 * TYPESCRIPT handler : it is a semi-independent handler
 * used as an option by the JAVASCRIPT language
 * It does not inherit from Language, as there can be only one LANGUAGE
 * but uses the same interface
 */
class TYPESCRIPT {

public:
  TYPESCRIPT(JSEmitter *_parent);
  virtual ~TYPESCRIPT() {}

  virtual int functionHandler(Node *);
  virtual int variableHandler(Node *);
  virtual int constructorHandler(Node *);
  virtual int enumDeclaration(Node *);
  virtual int enterClass(Node *);
  virtual int exitClass(Node *);
  virtual int switchNamespace(Node *);
  virtual int top(Node *);
  virtual void main(int, char *[]);
  virtual String *expandTSvars(String *, DOH *);
  virtual void registerType(Node *);

protected:
  virtual String *emitArguments(Node *);
  virtual String *promisify(String *);
  virtual String *enumName(Node *);

private:
  String *f_declarations, *f_current_class;
  JSEmitter *parent;
  size_t enum_id;
};

TYPESCRIPT::TYPESCRIPT(JSEmitter *_parent) :
  f_declarations(NULL), f_current_class(NULL), parent(_parent), enum_id(1) {
}

void TYPESCRIPT::main(int, char *[]) {
  // Add a symbol to the parser for conditional compilation
  Preprocessor_define("SWIGTYPESCRIPT 1", 0);
}

/**
 * Expand the TS-specific typemap special variables
 * $jstype - the wrapped symbol name
 */
String *TYPESCRIPT::expandTSvars(String *tm, DOH *target) {
  if (!tm)
    return NULL;

  SwigType *ctype =
      SwigType_typedef_resolve_all(SwigType_base(Getattr(target, "type")));
  Hash *jstype = parent->state.types(ctype);
  String *jsname = jstype ? Getattr(jstype, "name") : NULL;
  String *r = Copy(tm);
  if (js_debug_tstypes) {
    Printf(stdout,
           "%s:%d resolving TypeScript type for %s\n  Found %s:%d -> %s "
           "($jstype = %s)%s\n",
           Getfile(target), Getline(target), ctype, Getfile(tm), Getline(tm), r,
           jsname ? jsname : "<none> -> any",
           jstype && GetFlag(jstype, "forward") ? " from forward declaration" : "");
  }
  if (Strstr(r, "$jstype")) {
    if (jsname) {
      Replace(r, "$jstype", jsname, 0);
      // We mark the types that have actually been used in TypeScript
      // The explanation is in TYPESCRIPT::top
      SetFlag(jstype, "ts_used");
    } else {
      Replace(r, "$jstype", "any", 0);
    }
  }
  return r;
}

/**
 * Return a new type that is a Promise of the given type
 */
String *TYPESCRIPT::promisify(String *type) {
  String *promise = NewString("");
  Printf(promise, "Promise<%s>", type);
  return promise;
}

/* ---------------------------------------------------------------------
 * top()
 *
 * Function handler for processing top node of the parse tree
 * Wrapper code generation essentially starts from here
 * --------------------------------------------------------------------- */
int TYPESCRIPT::top(Node *n) {
  String *infile = Getattr(n, "infile");
  String *infile_filename = Swig_file_filename(infile);
  String *basename = Swig_file_basename(infile_filename);
  String *typescript_filename = NewString("");
  if (Len(SWIG_output_directory()) > 0) {
    Printf(typescript_filename, "%s/", SWIG_output_directory());
  }
  Printf(typescript_filename, "%s.d.ts", basename);

  File *f_typescript = NewFile(typescript_filename, "w", SWIG_output_files());
  if (!f_typescript) {
    FileErrorDisplay(f_typescript);
    Exit(EXIT_FAILURE);
  }
  Swig_register_filebyname("typescript", f_typescript);
  Swig_banner(f_typescript);
  bool empty = true;

  String *module = Getattr(n, NAME);
  Template t_header(parent->getTemplate("ts_header"));
  t_header.replace("$jsmodule", module).print(f_typescript);

  Iterator it;
  // Emit all namespaces
  for (it = First(parent->namespaces); it.item; it = Next(it)) {
    Hash *nspace = it.item;

    // Emit successive begin namespace statements for
    // each level, going up the chain and concatenating backwards
    String *namespace_stmts = NewString("");
    while (nspace && !Equal(Getattr(nspace, NAME), "exports")) {
      Template t_nspace(parent->getTemplate("ts_nspace_header"));
      String *stmt = NewString("");
      t_nspace.replace("$jsname", Getattr(nspace, NAME)).print(stmt);
      Insert(namespace_stmts, 0, stmt);
      nspace = Getattr(nspace, "parent:nspace");
    }
    Printf(f_typescript, "%s", namespace_stmts);

    // Emit the namespace declarations
    nspace = it.item;
    String *f_namespace = Getattr(nspace, "typescript");
    if (Len(f_namespace) > 0) {
      Printv(f_typescript, f_namespace, "\n", 0);
      empty = false;
    }

    // Emit successive end namespace statements for
    // each level
    namespace_stmts = NewString("");
    while (nspace && !Equal(Getattr(nspace, NAME), "exports")) {
      Template t_nspace(parent->getTemplate("ts_nspace_footer"));
      String *stmt = NewString("");
      t_nspace.replace("$jsname", Getattr(nspace, NAME)).print(f_typescript);
      Insert(namespace_stmts, 0, stmt);
      nspace = Getattr(nspace, "parent:nspace");
    }
    Printf(f_typescript, "%s", namespace_stmts);
  }

  // If there any forward declarations left over, these
  // are opaque types unknown to SWIG JavaScript -
  // if they have actually been used, emit types that are symbols
  //
  // It is important to omit unused types since they might have been
  // eliminated - for example including <std_string.i> will add
  // a forward declaration for std::string, but then this type will
  // be eliminated as an std::string is not wrapped but rather converted
  for (it = First(parent->state.types()); it.item; it = Next(it)) {
    if (!GetFlag(it.item, "forward"))
      continue;
    if (!GetFlag(it.item, "ts_used"))
      continue;
    String *name = Getattr(it.item, "name");
    if (js_debug_tstypes) {
      Printf(stdout, "Emitting a symbol declaration for %s, found only a forward declaration\n", name);
    }
    List *namespaces = Split(name, '.', -1);
    int scopes = 0;
    for (Iterator n = First(namespaces); n.item; n = Next(n)) {
      if (Next(n).item) {
        Printf(f_typescript, "export namespace %s {\n", n.item);
        scopes++;
      } else {
        Printf(f_typescript, "%s type %s = symbol;\n", scopes > 0 ? "" : "declare", n.item);
      }
    }
    for (int i = 0; i < scopes; i++)
      Printf(f_typescript, "}\n");
    empty = false;
  }

  if (empty) {
    // They do this in the TypeScript project as well
    // https://github.com/microsoft/TypeScript/pull/20626
    Printf(f_typescript, "export {}\n");
  }

  Template t_footer(parent->getTemplate("ts_footer"));
  t_footer.replace("$jsmodule", module).print(f_typescript);

  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * switchNamespace()
 *
 * Every namespace has its own f_declarations that is
 * stored in the namespaces hash
 * this->f_declarations is always the current namespace
 * --------------------------------------------------------------------- */
int TYPESCRIPT::switchNamespace(Node *) {
  Hash *nspace = parent->current_namespace;
  if (!nspace)
    nspace = Getattr(parent->namespaces, "::");
  if (!Getattr(nspace, "typescript")) {
    Setattr(nspace, "typescript", NewString(""));
  }
  f_declarations = Getattr(nspace, "typescript");
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * functionHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */
int TYPESCRIPT::functionHandler(Node *n) {
  bool is_member = GetFlag(n, "ismember");

  String *args = emitArguments(n);
  
  String *ret_tm = Swig_typemap_lookup("ts", n, Getattr(n, NAME), NULL);
  String *ret_type = NULL;
  if (GetFlag(n, "ts:varargs")) {
    ret_type = NewString("any");
  } else if (GetFlag(n, "ts:out")) {
    ret_type = expandTSvars(Getattr(n, "ts:out"), n);
  } else {
    ret_type = expandTSvars(ret_tm, n);
  }
  Delete(ret_tm);

  const char *qualifier =
      Equal(Getattr(n, "storage"), "static") ? "static" : "";

  String *sync_name = parent->state.function("name:sync");
  String *async_name = parent->state.function("name:async");
  if (!sync_name && !async_name)
    sync_name = parent->state.function("name");

  switchNamespace(n);
  if (sync_name) {
    Template t_function(
        parent->getTemplate(is_member ? "ts_function" : "ts_global_function"));
    t_function.replace("$jsname", sync_name)
        .replace("$tsargs", args)
        .replace("$tsret", ret_type)
        .replace("$tsqualifier", qualifier)
        .print(is_member ? f_current_class : f_declarations);
  }
  if (async_name) {
    Template t_function(
        parent->getTemplate(is_member ? "ts_function" : "ts_global_function"));
    t_function.replace("$jsname", async_name)
        .replace("$tsargs", args)
        .replace("$tsret", promisify(ret_type))
        .replace("$tsqualifier", qualifier)
        .print(is_member ? f_current_class : f_declarations);
  }

  Delete(args);
  Delete(ret_type);
  return SWIG_OK;
}

String *TYPESCRIPT::enumName(Node *n) {
  bool is_member = GetFlag(n, "ismember");
  String *name = Getattr(n, "sym:name");

  if (name == NULL) {
    name = Getattr(n, "unnamed");
    if (name == NULL) {
      name = NewString("");
      Printf(name, "enum%u", enum_id++);
      Setattr(n, "sym:name", name);
    }
  }

  if (is_member) {
    // There are no class-local types in TypeScript
    // If we encounter a class-local enum, we must hoist it to the global scope
    // In this it will prefixed by the class name to avoid collisions
    String *qualified_name = NewString("");
    Node *parent = Getattr(n, "parentNode");
    Printf(qualified_name, "%s_%s", Getattr(parent, "sym:name"), name);
    name = qualified_name;
  }

  return name;
}

/* ---------------------------------------------------------------------
 * variableHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */
int TYPESCRIPT::variableHandler(Node *n) {
  const char *templ = NULL;
  String *target = NULL;
  String *type = NULL;

  bool is_member = GetFlag(n, "ismember");
  bool is_enumitem = Equal(Getattr(n, "nodeType"), "enumitem");
  bool is_static = GetFlag(parent->state.variable(), IS_STATIC);
  bool is_constant = GetFlag(n, "constant");

  switchNamespace(n);
  if (is_member) {
    templ = is_constant ? "ts_constant" : "ts_variable";
    target = f_current_class;
  } else {
    templ = is_constant ? "ts_global_constant" : "ts_global_variable";
    target = f_declarations;
  }
  Template t_variable(parent->getTemplate(templ));

  const char *qualifier = (is_static || is_enumitem) ? "static" : "";

  if (is_enumitem) {
    Node *enum_node = Getattr(n, "parentNode");
    type = enumName(enum_node);
  } else {
    String *tm = Swig_typemap_lookup("ts", n, Getattr(n, NAME), NULL);
    type = expandTSvars(tm, n);
    Delete(tm);
  }

  t_variable.replace("$jsname", parent->state.variable(NAME))
      .replace("$tstype", type)
      .replace("$tsqualifier", qualifier)
      .print(target);

  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * enumDeclaration()
 *
 * Handler for emitting an enum declaration
 * --------------------------------------------------------------------- */
int TYPESCRIPT::enumDeclaration(Node *n) {
  String *name = enumName(n);
  String *nspace = parent->currentNamespacePrefix();

  String *js_name = NewString("");
  Printf(js_name, "%s%s", nspace, name);
  switchNamespace(n);

  String *enum_name = NewString("");
  Printf(enum_name, "%s %s", Getattr(n, "enumkey"), Getattr(n, "enumtype"));
  parent->state.types(enum_name, js_name);

  Template t_enum(parent->getTemplate("ts_enum_declaration"));

  t_enum.replace("$jsname", name).print(f_declarations);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * enterClass()
 * exitClass()
 *
 * Handlers for generating wrappers for classes
 * --------------------------------------------------------------------- */
int TYPESCRIPT::enterClass(Node *n) {
  f_current_class = NewString("");
  Template t_class(parent->getTemplate("ts_class_header"));

  String *jsparent = NewString("");
  Node *jsbase = parent->getBaseClass(n);
  if (jsbase && Getattr(jsbase, "module")) {
    Hash *base_class = Getattr(jsbase, "classtype");
    String *base_jsname = Getattr(parent->state.types(base_class), "name");
    Printf(jsparent, " extends %s", base_jsname);
  }
  const char *qualifier = Getattr(n, "abstracts") ? "abstract" : "";

  switchNamespace(n);
  t_class.replace("$jsname", Getattr(parent->state.clazz(), NAME))
      .replace("$jsparent", jsparent)
      .replace("$tsqualifier", qualifier)
      .print(f_current_class);

  return SWIG_OK;
}
int TYPESCRIPT::exitClass(Node *n) {
  Template t_class(parent->getTemplate("ts_class_footer"));

  t_class.replace("$jsname", Getattr(n, NAME)).trim().pretty_print(f_current_class);
  Append(f_declarations, f_current_class);
  f_current_class = NULL;

  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * constructorHandler()
 *
 * Function handler for generating wrappers for variables
 * --------------------------------------------------------------------- */

int TYPESCRIPT::constructorHandler(Node *n) {
  Template t_function(parent->getTemplate("ts_ctor"));
  String *args = emitArguments(n);

  t_function.replace("$jsname", parent->state.clazz(NAME))
      .replace("$tsargs", args)
      .print(f_current_class);

  Delete(args);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * registerType()
 *
 * Track C/C++ types for resolving inverse equivalence
 * ($jsname in ts/tsout typemaps)
 * --------------------------------------------------------------------- */
void TYPESCRIPT::registerType(Node *n) {
  //Swig_print(n, 1);
  Hash *jsnode = NewHash();
  String *jsname = NewStringEmpty();
  bool forward = Equal(Getattr(n, "nodeType"), "classforward");
  String *nspace = parent->currentNamespacePrefix();

  Printf(jsname, "%s%s", nspace, Getattr(n, "sym:name"));
  Setattr(jsnode, "name", jsname);
  String *ctype = Copy(Getattr(n, "classtype"));
  if (forward) {
    SetFlag(jsnode, "forward");
  }

  if (js_debug_tstypes) {
    Printf(stdout, "%s:%d registering %s (C/C++) ==> %s (JS) (%s)\n",
           Getfile(n), Getline(n), ctype, jsname,
           forward ? "forward declaration" : "definition");
  }
  // Definitions replace the forward declaration
  // when they become available
  Hash *existing = parent->state.types(ctype);
  if (existing) {
    if (!GetFlag(existing, "forward")) {
      Swig_warning(WARN_PARSE_REDEFINED, input_file, line_number,
                   "Redefinition for %s: %s -> %s\n",
                   ctype, jsname, Getattr(existing, "name"));
    }
    if (!Equal(jsname, Getattr(existing, "name"))) {
      Swig_warning(WARN_PARSE_REDEFINED, input_file, line_number,
                   "JS type of definition for %s does not match forward "
                   "declaration: %s -> %s\n",
                   ctype, jsname, Getattr(existing, "name"));
    }
  }
  parent->state.types(ctype, jsnode);
}

/**********************************************************************
 * JAVASCRIPT: SWIG module implementation
 **********************************************************************/

class JAVASCRIPT:public Language {

  public:
    JAVASCRIPT() : emitter(NULL), ts_emitter(NULL) {}
    ~JAVASCRIPT() {
      delete emitter;
      delete ts_emitter;
    }

  virtual int functionHandler(Node *n);
  virtual int globalfunctionHandler(Node *n);
  virtual int variableHandler(Node *n);
  virtual int globalvariableHandler(Node *n);
  virtual int staticmemberfunctionHandler(Node *n);
  virtual int classHandler(Node *n);
  virtual int classforwardDeclaration(Node *n);
  virtual int enumDeclaration(Node *n);
  virtual int functionWrapper(Node *n);
  virtual int constantWrapper(Node *n);
  virtual int nativeWrapper(Node *n);
  virtual int constructorHandler(Node *);
  virtual void main(int argc, char *argv[]);
  virtual int top(Node *n);
  virtual void replaceSpecialVariables(String *method, String *tm, Parm *parm);

  /**
   *  Registers all %fragments assigned to section "templates".
   **/
  virtual int fragmentDirective(Node *n);

public:

  virtual String *getNSpace() const;
  virtual String *makeParameterName(Node *n, Parm *p, int arg_num,
                                    bool setter) const;

private:

  JSEmitter *emitter;
  TYPESCRIPT *ts_emitter;
};

/**
 * Transform the ParmList arguments to a string
 * of TypeScript typed arguments using the "ts" typemaps
 */
String *TYPESCRIPT::emitArguments(Node *n) {
  Parm *p;
  String *args = NewString("");
  ParmList *params = Getattr(n, "parms");
  int idx;

  if (GetFlag(n, "ts:varargs")) {
    return NewString("...args: any[]");
  }

  Swig_typemap_attach_parms("in", params, NULL);
  Swig_typemap_attach_parms("ts", params, NULL);
  Swig_typemap_attach_parms("tsout", params, NULL);
  Swig_typemap_attach_parms("default", params, NULL);

  for (idx = 0, p = params; p; idx++) {
    String *tm = Getattr(p, "tmap:ts");
    String *tm_out = Getattr(p, "tmap:tsout");
    if (tm_out) {
      Setattr(n, "ts:out", tm_out);
    }
    if (tm != NULL && Getattr(p, "tmap:in") &&
        !checkAttribute(p, "tmap:in:numinputs", "0")) {
      String *type = expandTSvars(tm, p);

      JAVASCRIPT *lang = static_cast<JAVASCRIPT *>(Language::instance());
      String *arg_name = lang->makeParameterName(n, p, idx, false);
      if (!arg_name) {
        arg_name = NewString("");
        Printf(arg_name, "arg%d", idx);
      }

      if (Len(args) > 0) {
        Append(args, ", ");
      }
      Append(args, arg_name);
      if (!Getattr(p, INDEX)) {
        SetInt(p, INDEX, idx);
      }
      if (parent->isArgOptional(n, p)) {
        Append(args, "?");
      }
      Append(args, ": ");
      Append(args, type);

      String *ctype = SwigType_base(Getattr(p, "type"));
      List *equiv_types = SwigType_get_equiv_types(ctype);
      if (equiv_types) {
        for (int i = 0; i < Len(equiv_types); i++) {
          SwigType *ctype = SwigType_base(Getitem(equiv_types, i));
          String *jstype = parent->state.types(ctype);
          if (jstype) {
            Printf(args, " | %s", Getattr(jstype, "name"));
          }
        }
        Delete(equiv_types);
      }
    }
    if (tm != NULL) {
      p = Getattr(p, "tmap:ts:next");
    } else {
      p = nextSibling(p);
    }
  }

  return args;
}

/* ---------------------------------------------------------------------
 * replaceSpecialVariables()
 *
 * Implement the JavaScript-specific special variables
 * (at the moment only when TypeScript is enabled)
 * This method is called only for explicit typemap expansion via $typemap
 * --------------------------------------------------------------------- */
void JAVASCRIPT::replaceSpecialVariables(String *method, String *tm, Parm *parm) {
  if (ts_emitter) {
    if (Equal(method, "ts") || Equal(method, "tsout")) {
      String *r = ts_emitter->expandTSvars(tm, parm);
      if (r) {
        Clear(tm);
        Append(tm, r);
        Delete(r);
      }
    }
  }
}

/* ---------------------------------------------------------------------
 * functionWrapper()
 *
 * Low level code generator for functions
 * --------------------------------------------------------------------- */

int JAVASCRIPT::functionWrapper(Node *n) {

  // note: the default implementation only prints a message
  // Language::functionWrapper(n);
  emitter->emitWrapperFunction(n);

  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * functionHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */
int JAVASCRIPT::functionHandler(Node *n) {

  if (GetFlag(n, "isextension") == 1) {
    SetFlag(n, "ismember");
  }

  if (GetFlag(n, "feature:del")) {
    Swig_warning(WARN_IGNORE_OPERATOR_DELETE, input_file, line_number,
                 "JavaScript does not have destructors, ignoring %s\n",
                 Getattr(n, "sym:name"));
    return SWIG_ERROR;
  }

  emitter->enterFunction(n);
  Language::functionHandler(n);
  emitter->exitFunction(n);

  if (ts_emitter) {
    ts_emitter->functionHandler(n);
  }
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * globalfunctionHandler()
 *
 * Function handler for generating wrappers for functions
 * --------------------------------------------------------------------- */

int JAVASCRIPT::globalfunctionHandler(Node *n) {
  emitter->switchNamespace(n);
  Language::globalfunctionHandler(n);

  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * staticmemberfunctionHandler()
 *
 * Function handler for generating wrappers for static member functions
 * --------------------------------------------------------------------- */

int JAVASCRIPT::staticmemberfunctionHandler(Node *n) {
  /*
   *  Note: storage=static is removed by Language::staticmemberfunctionHandler.
   *    So, don't rely on that after here. Instead use the state variable which is
   *    set by JSEmitter::enterFunction().
   */
  Language::staticmemberfunctionHandler(n);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * constructorHandler()
 *
 * Function handler for generating wrappers for variables
 * --------------------------------------------------------------------- */

int JAVASCRIPT::constructorHandler(Node *n) {
  int rc = Language::constructorHandler(n);
  if (rc != SWIG_OK) return rc;
  if (ts_emitter) {
    rc = ts_emitter->constructorHandler(n);
    if (rc != SWIG_OK) return rc;
  }
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * variableHandler()
 *
 * Function handler for generating wrappers for variables
 * --------------------------------------------------------------------- */

int JAVASCRIPT::variableHandler(Node *n) {

  emitter->enterVariable(n);
  Language::variableHandler(n);
  emitter->exitVariable(n);

  // the static const exception - it is a constant not a variable
  if (ts_emitter && !GetFlag(n, "constant")) {
    ts_emitter->variableHandler(n);
  }
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * globalvariableHandler()
 *
 * Function handler for generating wrappers for global variables
 * --------------------------------------------------------------------- */

int JAVASCRIPT::globalvariableHandler(Node *n) {
  emitter->switchNamespace(n);
  Language::globalvariableHandler(n);

  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * enumDeclaration()
 *
 * Function handler for declaring new enum types
 * (used only in TypeScript mode)
 * --------------------------------------------------------------------- */
int JAVASCRIPT::enumDeclaration(Node *n) {
  int rc = Language::enumDeclaration(n);
  if (rc != SWIG_OK) return rc;

  if (ts_emitter) {
    rc = ts_emitter->enumDeclaration(n);
  }
  return rc;
}

/* ---------------------------------------------------------------------
 * constantHandler()
 *
 * Function handler for generating wrappers for constants
 * --------------------------------------------------------------------- */

int JAVASCRIPT::constantWrapper(Node *n) {
  emitter->switchNamespace(n);

  // Note: callbacks trigger this wrapper handler
  // TODO: handle callback declarations
  if (Equal(Getattr(n, "kind"), "function")) {
    return SWIG_OK;
  }
  // TODO: the emitter for constants must be implemented in a cleaner way
  // currently we treat it like a read-only variable
  // however, there is a remaining bug with function pointer constants
  // which could be fixed with a cleaner approach
  emitter->emitConstant(n);

  if (ts_emitter) {
    ts_emitter->variableHandler(n);
  }
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * nativeWrapper()
 *
 * Function wrapper for generating placeholders for native functions
 * --------------------------------------------------------------------- */

int JAVASCRIPT::nativeWrapper(Node *n) {
  emitter->emitNativeFunction(n);
  if (ts_emitter) {
    SetFlag(n, "ts:varargs");
    ts_emitter->functionHandler(n);
  }
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * classHandler()
 *
 * Function handler for generating wrappers for class
 * --------------------------------------------------------------------- */

int JAVASCRIPT::classHandler(Node *n) {
  emitter->switchNamespace(n);

  emitter->enterClass(n);
  if (ts_emitter) {
    /* Remember the mapping for the TypeScript definitions */
    ts_emitter->registerType(n);
    ts_emitter->enterClass(n);
  }

  Language::classHandler(n);
  emitter->exitClass(n);

  if (ts_emitter) {
    ts_emitter->exitClass(n);
  }
  return SWIG_OK;
}

int JAVASCRIPT::classforwardDeclaration(Node *n) {
  emitter->switchNamespace(n);
  int r = Language::classforwardDeclaration(n);
  if (r != SWIG_OK)
    return r;
  if (ts_emitter) {
    /* In the case of a forward declaration we create
     * a temporary empty type that will be overwritten
     * when the full type becomes available
     */
    ts_emitter->registerType(n);
  }
  return SWIG_OK;
}

int JAVASCRIPT::fragmentDirective(Node *n) {

  // catch all fragment directives that have "templates" as location
  // and register them at the emitter.
  String *section = Getattr(n, "section");

  if (Equal(section, "templates") && !ImportMode) {
    emitter->registerTemplate(Getattr(n, "value"), Getattr(n, "code"));
  } else {
    return Language::fragmentDirective(n);
  }

  return SWIG_OK;
}

String *JAVASCRIPT::getNSpace() const {
  return Language::getNSpace();
}

String *JAVASCRIPT::makeParameterName(Node *n, Parm *p, int arg_num,
                                      bool setter) const {
  return Language::makeParameterName(n, p, arg_num, setter);
}

/* ---------------------------------------------------------------------
 * top()
 *
 * Function handler for processing top node of the parse tree
 * Wrapper code generation essentially starts from here
 * --------------------------------------------------------------------- */

int JAVASCRIPT::top(Node *n) {
  emitter->initialize(n);

  Language::top(n);

  if (ts_emitter) {
    ts_emitter->top(n);
  }
  emitter->dump(n);
  emitter->close();

  return SWIG_OK;
}

static const char *usage = (char *)"\
Javascript Options (available with -javascript)\n\
     -jsc                   - creates a JavascriptCore extension \n\
     -v8                    - creates a v8 extension \n\
     -node                  - creates a node.js extension \n\
     -napi                  - creates a NAPI extension \n\
     -sync                  - create sync wrappers by default (NAPI only, default) \n\
     -async                 - create async wrappers by default (NAPI only) \n\
     -async-locking         - add locking by default (NAPI only) \n\
     -typescript            - generates a TypeScript ambient module (d.ts file)\n\
     -exports <file>        - generate a .cjs exports file that can be used with both require and import,\n\
                                 <file> is the name of shared library binary (NAPI only)\n\
     -split                 - use code splitting, produce multiple compilation units (NAPI only)\n\
     -debug-codetemplates   - generates information about the origin of code templates\n\
     -debug-tstypes         - print debug information about TS types equivalence\n";

/* ---------------------------------------------------------------------
 * main()
 *
 * Entry point for the JAVASCRIPT module
 * --------------------------------------------------------------------- */

void JAVASCRIPT::main(int argc, char *argv[]) {
  bool ts_enabled = false;

  // Set javascript subdirectory in SWIG library
  SWIG_library_directory("javascript");

  int engine = -1;

  for (int i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i], "-v8") == 0) {
	if (engine != -1) {
	  Printf(stderr, ERR_MSG_ONLY_ONE_ENGINE_PLEASE);
	  Exit(EXIT_FAILURE);
	}
	Swig_mark_arg(i);
	engine = JSEmitter::V8;
      } else if (strcmp(argv[i], "-jsc") == 0) {
	if (engine != -1) {
	  Printf(stderr, ERR_MSG_ONLY_ONE_ENGINE_PLEASE);
	  Exit(EXIT_FAILURE);
	}
	Swig_mark_arg(i);
	engine = JSEmitter::JavascriptCore;
      } else if (strcmp(argv[i], "-node") == 0) {
	if (engine != -1) {
	  Printf(stderr, ERR_MSG_ONLY_ONE_ENGINE_PLEASE);
	  Exit(EXIT_FAILURE);
	}
	Swig_mark_arg(i);
	engine = JSEmitter::NodeJS;
      } else if (strcmp(argv[i], "-napi") == 0) {
	if (engine != -1) {
	  Printf(stderr, ERR_MSG_ONLY_ONE_ENGINE_PLEASE);
	  Exit(EXIT_FAILURE);
	}
	Swig_mark_arg(i);
	engine = JSEmitter::NAPI;
      } else if (strcmp(argv[i], "-debug-codetemplates") == 0) {
	Swig_mark_arg(i);
	js_template_enable_debug = true;
      } else if (strcmp(argv[i], "-async") == 0) {
        Swig_mark_arg(i);
        js_napi_default_is_async = true;
      } else if (strcmp(argv[i], "-sync") == 0) {
        Swig_mark_arg(i);
        js_napi_default_is_async = false;
      } else if (strcmp(argv[i], "-async-locking") == 0) {
        Swig_mark_arg(i);
        js_napi_default_is_locked = true;
      } else if (strcmp(argv[i], "-typescript") == 0) {
        Swig_mark_arg(i);
        ts_enabled = true;
      } else if (strcmp(argv[i], "-split") == 0) {
        Swig_mark_arg(i);
        code_splitting = true;
      } else if (strcmp(argv[i], "-exports") == 0) {
        if (argv[i + 1]) {
          js_napi_generate_exports = NewString(argv[i + 1]);
          Swig_mark_arg(i);
          Swig_mark_arg(i + 1);
          i++;
        } else {
          Swig_arg_error();
        }
      } else if (strcmp(argv[i], "-debug-tstypes") == 0) {
        Swig_mark_arg(i);
        js_debug_tstypes = true;
      } else if (strcmp(argv[i], "-help") == 0) {
        fputs(usage, stdout);
        return;
      }
    }
  }

  Preprocessor_define("SWIG_JAVASCRIPT_EVOLUTION 1", 0);
  switch (engine) {
  case JSEmitter::NodeJS:
  case JSEmitter::V8:
    {
      emitter = swig_javascript_create_V8Emitter();
      Preprocessor_define("SWIG_JAVASCRIPT_V8 1", 0);
      SWIG_library_directory("javascript/v8");
      // V8 API is C++, so output must be C++ compatible even when wrapping C code
      if (!cparse_cplusplus) {
	Swig_cparse_cplusplusout(1);
      }
      if (engine == JSEmitter::NodeJS) {
	Preprocessor_define("BUILDING_NODE_EXTENSION 1", 0);
      }
      break;
    }
  case JSEmitter::JavascriptCore:
    {
      emitter = swig_javascript_create_JSCEmitter();
      Preprocessor_define("SWIG_JAVASCRIPT_JSC 1", 0);
      SWIG_library_directory("javascript/jsc");
      break;
    }
  case JSEmitter::NAPI:
    {
      emitter = swig_javascript_create_NAPIEmitter();
      Preprocessor_define("SWIG_JAVASCRIPT_NAPI 1", 0);
      SWIG_library_directory("javascript/napi");
      Preprocessor_define("BUILDING_NODE_EXTENSION 1", 0);
      if (!cparse_cplusplus) {
	Swig_cparse_cplusplusout(1);
      }
      break;
    }
  default:
    {
      Printf(stderr, "SWIG Javascript: Unknown engine. Please specify one of '-jsc', '-v8', '-node' or '-napi'.\n");
      Exit(EXIT_FAILURE);
      break;
    }
  }

  // Add a symbol to the parser for conditional compilation
  Preprocessor_define("SWIGJAVASCRIPT 1", 0);

  // Add typemap definitions
  SWIG_typemap_lang("javascript");

  // Set configuration file
  SWIG_config_file("javascript.swg");

  allow_overloading();

  if (ts_enabled) {
    ts_emitter = new TYPESCRIPT(emitter);
    ts_emitter->main(argc, argv);
  }
}

/* -----------------------------------------------------------------------------
 * swig_javascript()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_javascript() {
  return new JAVASCRIPT();
}

extern "C" Language *swig_javascript(void) {
  return new_swig_javascript();
}

/**********************************************************************
 * Emitter implementations
 **********************************************************************/

/* -----------------------------------------------------------------------------
 * JSEmitter()
 * ----------------------------------------------------------------------------- */

JSEmitter::JSEmitter(JSEmitter::JSEngine engine)
:  engine(engine), templates(NewHash()), namespaces(NULL), current_namespace(NULL), defaultResultName(NewString("result")), f_wrappers(NULL) {
}

/* -----------------------------------------------------------------------------
 * ~JSEmitter()
 * ----------------------------------------------------------------------------- */

JSEmitter::~JSEmitter() {
  Delete(templates);
}

/* -----------------------------------------------------------------------------
 * JSEmitter::RegisterTemplate() :  Registers a code template
 *
 *  Note: this is used only by JAVASCRIPT::fragmentDirective().
 * ----------------------------------------------------------------------------- */

int JSEmitter::registerTemplate(const String *name, const String *code) {
  if (!State::IsSet(state.globals(HAS_TEMPLATES))) {
    SetFlag(state.globals(), HAS_TEMPLATES);
  }
  return Setattr(templates, name, code);
}

/* -----------------------------------------------------------------------------
 * JSEmitter::getTemplate() :  Provides a registered code template
 * ----------------------------------------------------------------------------- */

Template JSEmitter::getTemplate(const String *name) {
  String *templ = Getattr(templates, name);

  if (!templ) {
    Printf(stderr, "Could not find template %s\n.", name);
    Exit(EXIT_FAILURE);
  }

  Template t(templ, name);
  return t;
}

JSEmitterState & JSEmitter::getState() {
  return state;
}

int JSEmitter::initialize(Node * /*n */ ) {

  if (namespaces != NULL) {
    Delete(namespaces);
  }
  namespaces = NewHash();
  Hash *global_namespace = createNamespaceEntry(NULL, "exports", 0, 0);

  Setattr(namespaces, "::", global_namespace);
  current_namespace = global_namespace;

  f_wrappers = NewString("");

  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * JSEmitter::getBaseClass() :  the node of the base class or NULL
 *
 * Note: the first base class is provided. Multiple inheritance is not
 *       supported.
 * ----------------------------------------------------------------------------- */

Node *JSEmitter::getBaseClass(Node *n) {
  // retrieve the first base class that is not %ignored
  List *baselist = Getattr(n, "bases");
  if (baselist) {
    Iterator base = First(baselist);
    while (base.item && GetFlag(base.item, "feature:ignore")) {
      base = Next(base);
    }
    return base.item;
  }
  return NULL;
}

/* -----------------------------------------------------------------------------
 * JSEmitter::isFunction() :  identify the node as a function.
 *
 * This is more complicated than it seems because of typedef function
 * types
 * ----------------------------------------------------------------------------- */
bool JSEmitter::isFunction(Node *n) {
  String *kind = Getattr(n, "kind");
  return (Equal(kind, "function")
      // HACK: sneaky.ctest revealed that typedef'd (global) functions must be
      // detected via the 'view' attribute.
      || (Equal(kind, "variable") &&
          Equal(Getattr(n, "view"), "globalfunctionHandler")));
  }

 /* -----------------------------------------------------------------------------
  * JSEmitter::emitWrapperFunction() :  dispatches emitter functions.
  *
  * This allows having small sized, dedicated emitting functions.
  * All state dependent branching is done here.
  * ----------------------------------------------------------------------------- */

int JSEmitter::emitWrapperFunction(Node *n) {
  int ret = SWIG_OK;

  String *kind = Getattr(n, "kind");

  if (kind) {

    if (isFunction(n)) {
      bool is_member = GetFlag(n, "ismember") != 0 || GetFlag(n, "feature:extend") != 0;
      bool is_static = GetFlag(state.function(), IS_STATIC) != 0;
      ret = emitFunction(n, is_member, is_static);
    } else if (Cmp(kind, "variable") == 0) {
      bool is_static = GetFlag(state.variable(), IS_STATIC) != 0;
      bool is_member = GetFlag(n, "ismember") != 0;
      bool is_setter = GetFlag(n, "memberset") != 0 || GetFlag(n, "varset") != 0;
      bool is_getter = GetFlag(n, "memberget") != 0 || GetFlag(n, "varget") != 0;
      if (is_setter) {
	ret = emitSetter(n, is_member, is_static);
      } else if (is_getter) {
	ret = emitGetter(n, is_member, is_static);
      }

    } else {
      Printf(stderr, "Warning: unsupported wrapper function type\n");
      ret = SWIG_ERROR;
    }
  } else {
    String *view = Getattr(n, "view");

    if (Cmp(view, "constructorHandler") == 0) {
      ret = emitCtor(n);
    } else if (Cmp(view, "destructorHandler") == 0) {
      ret = emitDtor(n);
    } else {
      Printf(stderr, "Warning: unsupported wrapper function type");
      ret = SWIG_ERROR;
    }
  }

  return ret;
}

int JSEmitter::emitNativeFunction(Node *n) {
  String *wrapname = Getattr(n, "wrap:name");
  enterFunction(n);
  state.function(WRAPPER_NAME, wrapname);
  exitFunction(n);
  return SWIG_OK;
}

String *JSEmitter::currentNamespacePrefix() {
  String *name = NewString("");
  Hash *nspace = current_namespace;
  while (nspace && !Equal(Getattr(nspace, NAME), "exports")) {
    String *prefix = NewString("");
    Printf(prefix, "%s.", Getattr(nspace, NAME));
    Insert(name, 0, prefix);
    nspace = Getattr(nspace, "parent:nspace");
  }
  return name;
}

int JSEmitter::enterClass(Node *n) {
  state.clazz(RESET);
  state.clazz(NAME, Getattr(n, "sym:name"));
  state.clazz("nspace", current_namespace);

  // Creating a mangled name using the current namespace and the symbol name
  String *mangled_name = NewString("");
  Printf(mangled_name, "%s_%s", Getattr(current_namespace, NAME_MANGLED), Getattr(n, "sym:name"));
  state.clazz(NAME_MANGLED, SwigType_manglestr(mangled_name));
  Delete(mangled_name);

  state.clazz(TYPE, NewString(Getattr(n, "classtype")));

  String *type = SwigType_manglestr(Getattr(n, "classtypeobj"));
  String *classtype_mangled = NewString("");
  Printf(classtype_mangled, "p%s", type);
  state.clazz(TYPE_MANGLED, classtype_mangled);
  Delete(type);

  String *ctor_wrapper = NewString("_wrap_new_veto_");
  Append(ctor_wrapper, state.clazz(NAME));
  state.clazz(CTOR, ctor_wrapper);
  state.clazz(CTOR_DISPATCHERS, NewString(""));
  state.clazz(DTOR, NewString("0"));

  // HACK: assume that a class is abstract
  // this is resolved by emitCtor (which is only called for non abstract classes)
  SetFlag(state.clazz(), IS_ABSTRACT);

  return SWIG_OK;
}

int JSEmitter::enterFunction(Node *n) {
  state.function(RESET);
  state.function(NAME, Getattr(n, "sym:name"));
  if (Equal(Getattr(n, "storage"), "static")) {
    SetFlag(state.function(), IS_STATIC);
  }
  return SWIG_OK;
}

int JSEmitter::enterVariable(Node *n) {
  // reset the state information for variables.
  state.variable(RESET);

  // Retrieve a pure symbol name. Using 'sym:name' as a basis, as it considers %renamings.
  if (Equal(Getattr(n, "view"), "memberconstantHandler")) {
    // Note: this is kind of hacky/experimental
    // For constants/enums 'sym:name' contains e.g., 'Foo_Hello' instead of 'Hello'
    state.variable(NAME, Getattr(n, "memberconstantHandler:sym:name"));
  } else {
    state.variable(NAME, Swig_scopename_last(Getattr(n, "sym:name")));
  }

  if (Equal(Getattr(n, "storage"), "static")) {
    SetFlag(state.variable(), IS_STATIC);
  }

  if (Language::instance()->is_immutable(n)) {
    SetFlag(state.variable(), IS_IMMUTABLE);
  }
  // FIXME: test "arrays_global" does not compile with that as it is not allowed to assign to char[]
  if (Equal(Getattr(n, "type"), "a().char")) {
    SetFlag(state.variable(), IS_IMMUTABLE);
  }

  return SWIG_OK;
}

const char *JSEmitter::getGetterTemplate(bool) {
  return "js_getter";
}

bool JSEmitter::isRenamedConstructor(Node *n) {
  Node *cls = parentNode(n);
  if (!Equal(nodeType(cls), "class")) {
    cls = parentNode(cls);
    assert(Equal(nodeType(cls), "class"));
  }

  return !Equal(Getattr(n, "constructorHandler:sym:name"),
                Getattr(cls, "sym:name"));
}

int JSEmitter::emitCtor(Node *n) {

  // Constructor renaming does not work in JavaScript.
  // This allows us to slip past the unit tests which are broken for all JavaScript backends.
  // TODO: fix by correcting the bad constructor name - this is the approach used in the Java module.
  if (isRenamedConstructor(n))
    return SWIG_ERROR;

  Wrapper *wrapper = NewWrapper();

  bool is_overloaded = GetFlag(n, "sym:overloaded") != 0;

  Template t_ctor(getTemplate("js_ctor"));

  // prepare the function wrapper name
  String *iname = Getattr(n, "sym:name");
  SwigType *returntype = Getattr(n, "type");
  String *wrap_name = Swig_name_wrapper(iname);
  if (is_overloaded) {
    t_ctor = getTemplate("js_overloaded_ctor");
    Append(wrap_name, Getattr(n, "sym:overname"));
  }
  Setattr(n, "wrap:name", wrap_name);
  // note: we can remove the is_abstract flag now, as this
  //       is called for non-abstract classes only.
  Setattr(state.clazz(), IS_ABSTRACT, 0);

  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, wrapper);
  emit_attach_parmmaps(params, wrapper);

  Printf(wrapper->locals, "%sresult;", SwigType_str(Getattr(n, "type"), 0));

  marshalInputArgs(n, params, wrapper, Ctor, true, false);
  String *action = emit_action(n);
  Printv(wrapper->code, action, "\n", 0);

  String *cleanup = emitCleanupCode(n, params);

  bool isvoid = !Cmp(returntype, "void");

  t_ctor.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jswrapper", wrap_name)
      .replace("$jsmangledtype", state.clazz(TYPE_MANGLED))
      .replace("$jslocals", wrapper->locals)
      .replace("$jscode", wrapper->code)
      .replace("$jsargcount", Getattr(n, ARGCOUNT))
      .replace("$jsparent", state.clazz(PARENT_MANGLED))
      .replace("$jsargrequired", Getattr(n, ARGREQUIRED))
      .replace("$jscleanup", cleanup)
      .replace("$isvoid", isvoid ? "1" : "0")
      .replace("$symname", iname)
      .pretty_print(f_wrappers);

  Template t_ctor_case(getTemplate("js_ctor_dispatch_case"));
  t_ctor_case.replace("$jswrapper", wrap_name)
      .replace("$jsargcount", Getattr(n, ARGCOUNT))
      .replace("$jsargrequired", Getattr(n, ARGREQUIRED));
  Append(state.clazz(CTOR_DISPATCHERS), t_ctor_case.str());

  Delete(cleanup);
  DelWrapper(wrapper);

  // create a dispatching ctor
  if (is_overloaded) {
    if (!Getattr(n, "sym:nextSibling")) {
      String *wrap_name = Swig_name_wrapper(Getattr(n, "sym:name"));
      Template t_mainctor(getTemplate("js_ctor_dispatcher"));
      t_mainctor.replace("$jswrapper", wrap_name)
	  .replace("$jsmangledtype", state.clazz(TYPE_MANGLED))
	  .replace("$jsmangledname", state.clazz(NAME_MANGLED))
	  .replace("$jsdispatchcases", state.clazz(CTOR_DISPATCHERS))
	  .replace("$jsparent", state.clazz(PARENT_MANGLED))
	  .pretty_print(f_wrappers);
      state.clazz(CTOR, wrap_name);
    }
  } else {
    state.clazz(CTOR, wrap_name);
  }

  return SWIG_OK;
}

int JSEmitter::emitDtor(Node *n) {

  String *wrap_name = Swig_name_wrapper(Getattr(n, "sym:name"));

  SwigType *type = state.clazz(TYPE);
  String *p_classtype = SwigType_add_pointer(state.clazz(TYPE));
  String *ctype = SwigType_lstr(p_classtype, "");
  String *jsfree = NewString("");

  // (Taken from JSCore implementation.)
  /* The if (Extend) block was taken from the Ruby implementation.
   * The problem is that in the case of an %extend to create a destructor for a struct to coordinate automatic memory cleanup with the Javascript collector,
   * the SWIG function was not being generated. More specifically:
   struct MyData {
   %extend {
   ~MyData() {
   FreeData($self);
   }
   }
   };
   %newobject CreateData;
   struct MyData* CreateData(void);
   %delobject FreeData;
   void FreeData(struct MyData* the_data);

   where the use case is something like:
   var my_data = example.CreateData();
   my_data = null;

   This function was not being generated:
   SWIGINTERN void delete_MyData(struct MyData *self){
   FreeData(self);
   }

   I don't understand fully why it wasn't being generated. It just seems to happen in the Lua generator.
   There is a comment about staticmemberfunctionHandler having an inconsistency and I tracked down dome of the SWIGINTERN void delete_*
   code to that function in the Language base class.
   The Ruby implementation seems to have an explicit check for if(Extend) and explicitly generates the code, so that's what I'm doing here.
   The Ruby implementation does other stuff which I omit.
   */
  if (Extend) {
    String *wrap = Getattr(n, "wrap:code");
    if (wrap) {
      Printv(f_wrappers, wrap, NIL);
    }
  }
  // HACK: this is only for the v8 emitter. maybe set an attribute wrap:action of node
  // TODO: generate dtors more similar to other wrappers
  // EW: I think this is wrong. delete should only be used when new was used to create. If malloc was used, free needs to be used.
  if (SwigType_isarray(type)) {
    Printf(jsfree, "delete [] (%s)", ctype);
  } else {
    Printf(jsfree, "delete (%s)", ctype);
  }

  String *destructor_action = Getattr(n, "wrap:action");
  // Adapted from the JSCore implementation.
  /* The next challenge is to generate the correct finalize function for JavaScriptCore to call.
     Originally, it would use this fragment from javascriptcode.swg
     %fragment ("JS_destructordefn", "templates")
     %{
     void _wrap_${classname_mangled}_finalize(JSObjectRef thisObject)
     {
     SWIG_PRV_DATA* t = (SWIG_PRV_DATA*)JSObjectGetPrivate(thisObject);
     if(t && t->swigCMemOwn) free ((${type}*)t->swigCObject);
     free(t);
     }
     %}

     But for the above example case of %extend to define a destructor on a struct, we need to override the system to not call
     free ((${type}*)t->swigCObject);
     and substitute it with what the user has provided.
     To solve this, I created a variation fragment called JS_destructoroverridedefn:
     SWIG_PRV_DATA* t = (SWIG_PRV_DATA*)JSObjectGetPrivate(thisObject);
     if(t && t->swigCMemOwn) {
     ${type}* arg1 = (${type}*)t->swigCObject;
     ${destructor_action}
     }
     free(t);

     Based on what I saw in the Lua and Ruby modules, I use Getattr(n, "wrap:action")
     to decide if the user has a preferred destructor action.
     Based on that, I decide which fragment to use.
     And in the case of the custom action, I substitute that action in.
     I noticed that destructor_action has the form
     delete_MyData(arg1);
     The explicit arg1 is a little funny, so I structured the fragment to create a temporary variable called arg1 to make the generation easier.
     This might suggest this solution misunderstands a more complex case.

     Also, there is a problem where destructor_action is always true for me, even when not requesting %extend as above.
     So this code doesn't actually quite work as I expect. The end result is that the code still works because
     destructor_action calls free like the original template. The one caveat is the string in destructor_action casts to char* which is weird.
     I think there is a deeper underlying SWIG issue because I don't think it should be char*. However, it doesn't really matter for free.

     Maybe the fix for the destructor_action always true problem is that this is supposed to be embedded in the if(Extend) block above.
     But I don't fully understand the conditions of any of these things, and since it works for the moment, I don't want to break more stuff.
   */
  if (destructor_action) {
    Template t_dtor = getTemplate("js_dtoroverride");
    state.clazz(DTOR, wrap_name);
    t_dtor.replace("${classname_mangled}", state.clazz(NAME_MANGLED))
	.replace("$jswrapper", wrap_name)
	.replace("$jsfree", jsfree)
	.replace("$jstype", ctype);

    t_dtor.replace("${destructor_action}", destructor_action);
    Wrapper_pretty_print(t_dtor.str(), f_wrappers);
  } else {
    Template t_dtor = getTemplate("js_dtor");
    state.clazz(DTOR, wrap_name);
    t_dtor.replace("$jsmangledname", state.clazz(NAME_MANGLED))
	.replace("$jswrapper", wrap_name)
	.replace("$jsfree", jsfree)
	.replace("$jstype", ctype)
	.pretty_print(f_wrappers);
  }

  Delete(p_classtype);
  Delete(ctype);
  Delete(jsfree);

  return SWIG_OK;
}

int JSEmitter::emitGetter(Node *n, bool is_member, bool is_static) {
  Wrapper *wrapper = NewWrapper();
  Template t_getter(getTemplate("js_getter"));

  // prepare wrapper name
  String *wrap_name = Swig_name_wrapper(Getattr(n, "sym:name"));
  Setattr(n, "wrap:name", wrap_name);
  state.variable(GETTER, wrap_name);

  // prepare local variables
  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, wrapper);
  emit_attach_parmmaps(params, wrapper);

  // prepare code part
  String *action = emit_action(n);
  marshalInputArgs(n, params, wrapper, Getter, is_member, is_static);
  marshalOutput(n, params, wrapper, action);

  String *cleanup = emitCleanupCode(n, params);

  t_getter.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jswrapper", wrap_name)
      .replace("$jslocals", wrapper->locals)
      .replace("$jscode", wrapper->code)
      .replace("$jscleanup", cleanup)
      .pretty_print(f_wrappers);

  DelWrapper(wrapper);
  Delete(cleanup);

  return SWIG_OK;
}

int JSEmitter::emitSetter(Node *n, bool is_member, bool is_static) {

  // skip variables that are immutable
  if (State::IsSet(state.variable(IS_IMMUTABLE))) {
    return SWIG_OK;
  }

  Wrapper *wrapper = NewWrapper();

  Template t_setter(getTemplate("js_setter"));

  // prepare wrapper name
  String *wrap_name = Swig_name_wrapper(Getattr(n, "sym:name"));
  Setattr(n, "wrap:name", wrap_name);
  state.variable(SETTER, wrap_name);

  // prepare local variables
  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, wrapper);
  emit_attach_parmmaps(params, wrapper);

  // prepare code part
  String *action = emit_action(n);
  marshalInputArgs(n, params, wrapper, Setter, is_member, is_static);
  Append(wrapper->code, action);

  String *cleanup = emitCleanupCode(n, params);

  t_setter.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jswrapper", wrap_name)
      .replace("$jslocals", wrapper->locals)
      .replace("$jscode", wrapper->code)
      .replace("$jscleanup", cleanup)
      .pretty_print(f_wrappers);

  DelWrapper(wrapper);
  Delete(cleanup);

  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * JSEmitter::emitConstant() :  triggers code generation for constants
 * ----------------------------------------------------------------------------- */

int JSEmitter::emitConstant(Node *n) {
  // HACK: somehow it happened under Mac OS X that before everything started
  // a lot of SWIG internal constants were emitted
  // This didn't happen on other platforms yet...
  // we ignore those premature definitions
  if (!State::IsSet(state.globals(HAS_TEMPLATES))) {
    return SWIG_ERROR;
  }

  Wrapper *wrapper = NewWrapper();
  SwigType *type = Getattr(n, "type");
  String *iname = Getattr(n, "sym:name");
  String *wname = Swig_name_get(Getattr(current_namespace, NAME_MANGLED), iname);
  String *value = Getattr(n, "value");

  // HACK: forcing usage of cppvalue for v8 (which turned out to fix typedef_struct.i, et. al)
  if (State::IsSet(state.globals(FORCE_CPP)) && Getattr(n, "cppvalue") != NULL) {
    value = Getattr(n, "cppvalue");
  }

  bool is_member = GetFlag(n, "ismember");
  Template t_getter(getTemplate(getGetterTemplate(is_member)));

  // call the variable methods as a constants are
  // registered in same way
  enterVariable(n);
  state.variable(GETTER, wname);
  // TODO: why do we need this?
  Setattr(n, "wrap:name", wname);

  // special treatment of member pointers
  if (SwigType_type(type) == T_MPOINTER) {
    // TODO: this could go into a code-template
    String *mpointer_wname = NewString("");
    Printf(mpointer_wname, "_wrapConstant_%s", iname);
    Setattr(n, "memberpointer:constant:wrap:name", mpointer_wname);
    String *str = SwigType_str(type, mpointer_wname);
    Printf(f_wrappers, "static %s = %s;\n", str, value);
    Delete(str);
    value = mpointer_wname;
  }

  marshalOutput(n, 0, wrapper, NewString(""), value, false);

  t_getter.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jswrapper", wname)
      .replace("$jslocals", wrapper->locals)
      .replace("$jscode", wrapper->code)
      .replace("$jsaction", wrapper->code)
      .replace("$jsguard", "")
      .replace("$jslock", "")
      .replace("$jsinput", "")
      .replace("$jsoutput", "")
      .replace("$jscleanup", "")
      .pretty_print(f_wrappers);

  exitVariable(n);

  // This is the counterpart to the "constant" test in
  // exitVariable, it prevents double setting of
  // symbols that are both constants and variables
  SetFlag(n, "constant");

  DelWrapper(wrapper);

  return SWIG_OK;
}

int JSEmitter::emitFunction(Node *n, bool is_member, bool is_static) {
  Wrapper *wrapper = NewWrapper();
  Template t_function(getTemplate("js_function"));

  bool is_overloaded = GetFlag(n, "sym:overloaded") != 0;

  // prepare the function wrapper name
  String *iname = Getattr(n, "sym:name");
  SwigType *returntype = Getattr(n, "type");
  String *wrap_name = Swig_name_wrapper(iname);
  if (is_overloaded) {
    t_function = getTemplate("js_overloaded_function");
    Append(wrap_name, Getattr(n, "sym:overname"));
  }
  Setattr(n, "wrap:name", wrap_name);
  state.function(WRAPPER_NAME, wrap_name);

  // prepare local variables
  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, wrapper);
  emit_attach_parmmaps(params, wrapper);

  marshalInputArgs(n, params, wrapper, Function, is_member, is_static);
  String *action = emit_action(n);
  marshalOutput(n, params, wrapper, action);
  String *cleanup = emitCleanupCode(n, params);

  bool isvoid = !Cmp(returntype, "void");

  t_function.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jswrapper", wrap_name)
      .replace("$jslocals", wrapper->locals)
      .replace("$jscode", wrapper->code)
      .replace("$symname", iname)
      .replace("$jsargcount", Getattr(n, ARGCOUNT))
      .replace("$jsargrequired", Getattr(n, ARGREQUIRED))
      .replace("$jscleanup", cleanup)
      .replace("$isvoid", isvoid ? "1" : "0")
      .replace("$symname", iname)
      .pretty_print(f_wrappers);

  Delete(cleanup);
  DelWrapper(wrapper);

  return SWIG_OK;
}

int JSEmitter::emitFunctionDispatcher(Node *n, bool) {
  Wrapper *wrapper = NewWrapper();

  // Generate call list, go to first node
  Node *sibl = n;

  while (Getattr(sibl, "sym:previousSibling"))
    sibl = Getattr(sibl, "sym:previousSibling");	// go all the way up

  do {
    String *siblname = Getattr(sibl, "wrap:name");

    if (siblname) {
      // handle function overloading
      Template t_dispatch_case = getTemplate("js_function_dispatch_case");
      t_dispatch_case.replace("$jswrapper", siblname)
	  .replace("$jsargcount", Getattr(sibl, ARGCOUNT))
	  .replace("$jsargrequired", Getattr(sibl, ARGREQUIRED));

      Append(wrapper->code, t_dispatch_case.str());
    }

  } while ((sibl = Getattr(sibl, "sym:nextSibling")));

  Template t_function(getTemplate("js_function_dispatcher"));

  // Note: this dispatcher function gets called after the last overloaded function has been created.
  // At this time, n.wrap:name contains the name of the last wrapper function.
  // To get a valid function name for the dispatcher function we take the last wrapper name and
  // subtract the extension "sym:overname",
  String *wrap_name = NewString(Getattr(n, "wrap:name"));
  String *overname = Getattr(n, "sym:overname");

  Node *methodclass = Swig_methodclass(n);
  String *class_name = Getattr(methodclass, "sym:name");

  int l1 = Len(wrap_name);
  int l2 = Len(overname);
  Delslice(wrap_name, l1 - l2, l1);

  String *new_string = NewStringf("%s_%s", class_name, wrap_name);
  String *final_wrap_name = Swig_name_wrapper(new_string);

  Setattr(n, "wrap:name", final_wrap_name);
  state.function(WRAPPER_NAME, final_wrap_name);

  t_function.replace("$jslocals", wrapper->locals)
      .replace("$jscode", wrapper->code);

  // call this here, to replace all variables
  t_function.replace("$jswrapper", final_wrap_name)
      .replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsname", state.function(NAME))
      .pretty_print(f_wrappers);

  // Delete the state variable
  DelWrapper(wrapper);

  return SWIG_OK;
}

bool JSEmitter::isArgOptional(Node *n, Parm *p) {
  String *tm_def = Getattr(p, "tmap:default");
  int argmin = -1;
  int argidx = -1;

  if (Getattr(n, ARGREQUIRED)) {
    argmin = GetInt(n, ARGREQUIRED);
  }
  if (Getattr(p, INDEX)) {
    argidx = GetInt(p, INDEX);
  }

  if (tm_def != NULL) {
    return true;
  }
  if (argmin >= 0 && argidx >= 0 && argidx >= argmin) {
    return true;
  }

  return false;
}

String *JSEmitter::emitInputTypemap(Node *n, Parm *p, Wrapper *wrapper, String *arg) {
  String *code = NewString("");
  // Get input typemap for current param
  String *tm = Getattr(p, "tmap:in");
  SwigType *type = Getattr(p, "type");
  bool is_optional = isArgOptional(n, p);

  if (is_optional && Getattr(p, INDEX) == NULL) {
    Printf(stderr, "Argument %s in %s cannot be a default argument\n", Getattr(p, NAME), state.function(NAME));
    return SWIG_ERROR;
  }

  if (is_optional) {
    Template t_check_default(getTemplate("js_check_arg"));

    t_check_default.replace("$jsarg", Getattr(p, INDEX)).pretty_print(code);
    Printf(code, "{\n");
  }

  if (tm != NULL) {
    Replaceall(tm, "$input", arg);
    Setattr(p, "emit:input", arg);
    // do replacements for built-in variables
    if (Getattr(p, "wrap:disown") || (Getattr(p, "tmap:in:disown"))) {
      Replaceall(tm, "$disown", "SWIG_POINTER_DISOWN");
    } else {
      Replaceall(tm, "$disown", "0");
    }
    Replaceall(tm, "$symname", Getattr(n, "sym:name"));
    if (!checkAttribute(p, "tmap:in:noblock", "1")) {
      Printf(code, "{\n");
    }
    Printf(code, "%s", tm);
    if (!checkAttribute(p, "tmap:in:noblock", "1")) {
      Printf(code, "\n}\n");
    }
  } else {
    Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(type, 0));
    return NULL;
  }

  if (is_optional) {
    Printf(code, "}\n");
  }

  // numinputs=0 typemaps are emitted by the legacy code in
  // emit_attach_parmmaps() in emit.cxx, check the comment there
  // All generators work around this
  if (!checkAttribute(p, "tmap:in:numinputs", "0")) {
    Append(wrapper->code, code);
  }
  return code;
}

String *JSEmitter::emitCheckTypemap(Node *, Parm *p, Wrapper *wrapper, String *arg) {
  String *tm = Getattr(p, "tmap:check");

  if (tm != NULL) {
    Replaceall(tm, "$input", arg);
    Printf(wrapper->code, "%s\n", tm);
  }

  return tm;
}

void JSEmitter::marshalOutput(Node *n, ParmList *params, Wrapper *wrapper, String *actioncode, const String *cresult, bool emitReturnVariable) {
  SwigType *type = Getattr(n, "type");
  String *tm;
  Parm *p;

  // adds a declaration for the result variable
  if (emitReturnVariable)
    emit_return_variable(n, type, wrapper);
  // if not given, use default result identifier ('result') for output typemap
  if (cresult == 0)
    cresult = defaultResultName;

  tm = Swig_typemap_lookup_out("out", n, cresult, wrapper, actioncode);
  bool should_own = GetFlag(n, "feature:new") != 0;

  if (tm) {
    Replaceall(tm, "$objecttype", Swig_scopename_last(SwigType_str(SwigType_strip_qualifiers(type), 0)));

    if (should_own) {
      Replaceall(tm, "$owner", "SWIG_POINTER_OWN");
    } else {
      Replaceall(tm, "$owner", "0");
    }
    Append(wrapper->code, tm);

    if (Len(tm) > 0) {
      Printf(wrapper->code, "\n");
    }
  } else {
    Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(type, 0), Getattr(n, "name"));
  }

  if (params) {
    for (p = params; p;) {
      if ((tm = Getattr(p, "tmap:argout"))) {
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
        if (should_own) {
          Replaceall(tm, "$owner", "SWIG_POINTER_OWN");
        } else {
          Replaceall(tm, "$owner", "0");
        }
        Printv(wrapper->code, tm, "\n", NIL);
	p = Getattr(p, "tmap:argout:next");
      } else {
	p = nextSibling(p);
      }
    }
  }

  Replaceall(wrapper->code, "$result", "jsresult");
}

String *JSEmitter::emitCleanupCode(Node *n, ParmList *params) {
  Parm *p;
  String *tm;
  String *code = NewString("");

  for (p = params; p;) {
    if ((tm = Getattr(p, "tmap:freearg"))) {
      //addThrows(n, "tmap:freearg", p);
      Replaceall(tm, "$input", Getattr(p, "emit:input"));
      if (Len(tm) > 0) {
        Printv(code, tm, "\n", NIL);
      }
      p = Getattr(p, "tmap:freearg:next");
    } else {
      p = nextSibling(p);
    }
  }

  if (GetFlag(n, "feature:new")) {
    tm = Swig_typemap_lookup("newfree", n, Swig_cresult_name(), 0);
    if (Len(tm) > 0) {
      //addThrows(throws_hash, "newfree", n);
      Printv(code, tm, "\n", NIL);
    }
  }

  /* See if there is any return cleanup code */
  if ((tm = Swig_typemap_lookup("ret", n, Swig_cresult_name(), 0))) {
    if (Len(tm) > 0) {
      Printf(code, "%s\n", tm);
    }
    Delete(tm);
  }

  return code;
}

int JSEmitter::switchNamespace(Node *n) {
  // HACK: somehow this gets called for member functions.
  // We can safely ignore them, as members are not associated to a namespace (only their class)
  if (GetFlag(n, "ismember")) {
    return SWIG_OK;
  }
  // if nspace is deactivated, everything goes into the global scope
  if (!GetFlag(n, "feature:nspace")) {
    current_namespace = Getattr(namespaces, "::");
    return SWIG_OK;
  }
// EXPERIMENTAL: we want to use Language::getNSpace() here
// However, it is not working yet.
// For namespace functions Language::getNSpace() does not give a valid result
#if 0
  JAVASCRIPT *lang = static_cast<JAVASCRIPT*>(Language::instance());
  String *_nspace = lang->getNSpace();
  if (!Equal(nspace, _nspace)) {
    Printf(stdout, "##### Custom vs Language::getNSpace(): %s | %s\n", nspace, _nspace);
  }
#endif

  String *nspace = Getattr(n, "sym:nspace");

  if (nspace == NULL) {
    // It seems that only classes have 'sym:nspace' set.
    // We try to get the namespace from the qualified name (i.e., everything before the last '::')
    nspace = Swig_scopename_prefix(Getattr(n, "name"));
  }
  // If there is not even a scopename prefix then it must be global scope
  if (nspace == NULL) {
    current_namespace = Getattr(namespaces, "::");
    return SWIG_OK;
  }

  String *scope = NewString(nspace);
  // replace "." with "::" that we can use Swig_scopename_last
  Replaceall(scope, ".", "::");

  // if the scope is not yet registered
  // create (parent) namespaces recursively
  if (!Getattr(namespaces, scope)) {
    createNamespace(scope);
  }
  current_namespace = Getattr(namespaces, scope);

  return SWIG_OK;
}

int JSEmitter::createNamespace(String *scope) {

  String *parent_scope = Swig_scopename_prefix(scope);
  Hash *parent_namespace;
  if (parent_scope == 0) {
    parent_namespace = Getattr(namespaces, "::");
  } else if (!Getattr(namespaces, parent_scope)) {
    createNamespace(parent_scope);
    parent_namespace = Getattr(namespaces, parent_scope);
  } else {
    parent_namespace = Getattr(namespaces, parent_scope);
  }
  assert(parent_namespace != 0);

  Hash *new_namespace = createNamespaceEntry(parent_namespace, Char(scope),
    Char(Getattr(parent_namespace, "name")), Char(Getattr(parent_namespace, "name_mangled")));
  Setattr(namespaces, scope, new_namespace);

  Delete(parent_scope);
  return SWIG_OK;
}

Hash *JSEmitter::createNamespaceEntry(Hash *parent, const char *_name, const char *parent_name, const char *parent_mangled) {
  Hash *entry = NewHash();
  String *name = NewString(_name);
  Setattr(entry, "parent:nspace", parent);
  Setattr(entry, NAME, Swig_scopename_last(name));
  Setattr(entry, NAME_MANGLED, Swig_name_mangle_string(name));
  Setattr(entry, PARENT, NewString(parent_name));
  Setattr(entry, PARENT_MANGLED, NewString(parent_mangled));

  Delete(name);
  return entry;
}

/**********************************************************************
 * JavascriptCore: JSEmitter implementation for JavascriptCore engine
 **********************************************************************/

class JSCEmitter:public JSEmitter {

public:
  JSCEmitter();
  virtual ~ JSCEmitter();
  virtual int initialize(Node *n);
  virtual int dump(Node *n);
  virtual int close();

protected:
  virtual int enterVariable(Node *n);
  virtual int exitVariable(Node *n);
  virtual int enterFunction(Node *n);
  virtual int exitFunction(Node *n);
  virtual int enterClass(Node *n);
  virtual int exitClass(Node *n);
  virtual void marshalInputArgs(Node *n, ParmList *parms, Wrapper *wrapper, MarshallingMode mode, bool is_member, bool is_static);
  virtual Hash *createNamespaceEntry(Hash *, const char *name, const char *parent, const char *parent_mangled);
  virtual int emitNamespaces();

private:

  String *NULL_STR;
  String *VETO_SET;

  // output file and major code parts
  File *f_wrap_cpp;
  File *f_runtime;
  File *f_header;
  File *f_init;

};

JSCEmitter::JSCEmitter()
:  JSEmitter(JSEmitter::JavascriptCore), NULL_STR(NewString("NULL")), VETO_SET(NewString("JS_veto_set_variable")), f_wrap_cpp(NULL), f_runtime(NULL), f_header(NULL), f_init(NULL) {
}

JSCEmitter::~JSCEmitter() {
  Delete(NULL_STR);
  Delete(VETO_SET);
}


/* ---------------------------------------------------------------------
 * marshalInputArgs()
 *
 * Process all of the arguments passed into the argv array
 * and convert them into C/C++ function arguments using the
 * supplied typemaps.
 * --------------------------------------------------------------------- */

void JSCEmitter::marshalInputArgs(Node *n, ParmList *parms, Wrapper *wrapper, MarshallingMode mode, bool is_member, bool is_static) {
  Parm *p;
  String *tm = NULL;

  // determine an offset index, as members have an extra 'this' argument
  // except: static members and ctors.
  int startIdx = 0;
  if (is_member && !is_static && mode != Ctor) {
    startIdx = 1;
  }
  // store number of arguments for argument checks
  int num_args = emit_num_arguments(parms) - startIdx;
  String *argcount = NewString("");
  Printf(argcount, "%d", num_args);
  Setattr(n, ARGCOUNT, argcount);
  int num_required = emit_num_required(parms) - startIdx;
  SetInt(n, ARGREQUIRED, num_required);

  // process arguments
  int i = 0;
  for (p = parms; p;) {
    String *arg = NewString("");
    String *type = Getattr(p, "type");

    // ignore varargs
    if (SwigType_isvarargs(type))
      break;

    switch (mode) {
    case Getter:
      if (is_member && i == 0) {
        if (!is_static) {
          Printv(arg, "thisObject", 0);
        }
        i++;
      } else {
        Printf(arg, "argv[%d]", i - startIdx);
        SetInt(p, INDEX, i - startIdx);
        i += GetInt(p, "tmap:in:numinputs");
      }
      break;
    case Function:
      if (is_member && !is_static && i == 0) {
        Printv(arg, "thisObject", 0);
        i++;
      } else {
        Printf(arg, "argv[%d]", i - startIdx);
        SetInt(p, INDEX, i - startIdx);
        i += GetInt(p, "tmap:in:numinputs");
      }
      break;
    case Setter:
      if (is_member && !is_static && i == 0) {
	Printv(arg, "thisObject", 0);
	i++;
      } else {
	Printv(arg, "value", 0);
	i++;
      }
      break;
    case Ctor:
      Printf(arg, "argv[%d]", i);
      SetInt(p, INDEX, i);
      i += GetInt(p, "tmap:in:numinputs");
      break;
    default:
      Printf(stderr, "Illegal MarshallingMode.");
      Exit(EXIT_FAILURE);
    }

    if (Len(arg) > 0) {
      tm = emitInputTypemap(n, p, wrapper, arg);
    }
    Delete(arg);

    if (tm) {
      p = Getattr(p, "tmap:in:next");
    } else {
      p = nextSibling(p);
    }
  }

  for (p = parms; p;) {
    tm = emitCheckTypemap(n, p, wrapper, Getattr(p, "emit:input"));
    if (tm) {
      p = Getattr(p, "tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }
}

int JSCEmitter::initialize(Node *n) {

  JSEmitter::initialize(n);

  /* Get the output file name */
  String *outfile = Getattr(n, "outfile");

  /* Initialize I/O */
  f_wrap_cpp = NewFile(outfile, "w", SWIG_output_files());
  if (!f_wrap_cpp) {
    FileErrorDisplay(outfile);
    Exit(EXIT_FAILURE);
  }

  /* Initialization of members */
  f_runtime = NewString("");
  f_init = NewString("");
  f_header = NewString("");

  state.globals(CREATE_NAMESPACES, NewString(""));
  state.globals(REGISTER_NAMESPACES, NewString(""));
  state.globals(INITIALIZER, NewString(""));

  /* Register file targets with the SWIG file handler */
  Swig_register_filebyname("begin", f_wrap_cpp);
  Swig_register_filebyname("header", f_header);
  Swig_register_filebyname("wrapper", f_wrappers);
  Swig_register_filebyname("runtime", f_runtime);
  Swig_register_filebyname("init", f_init);

  Swig_banner(f_wrap_cpp);

  Swig_obligatory_macros(f_runtime, "JAVASCRIPT");

  return SWIG_OK;
}

int JSCEmitter::dump(Node *n) {
  /* Get the module name */
  String *module = Getattr(n, "name");

  Template initializer_define(getTemplate("js_initializer_define"));
  initializer_define.replace("$jsname", module).pretty_print(f_header);

  SwigType_emit_type_table(f_runtime, f_wrappers);

  Printv(f_wrap_cpp, f_runtime, "\n", 0);
  Printv(f_wrap_cpp, f_header, "\n", 0);
  Printv(f_wrap_cpp, f_wrappers, "\n", 0);

  emitNamespaces();

  // compose the initializer function using a template
  Template initializer(getTemplate("js_initializer"));
  initializer.replace("$jsname", module)
      .replace("$jsregisterclasses", state.globals(INITIALIZER))
      .replace("$jscreatenamespaces", state.globals(CREATE_NAMESPACES))
      .replace("$jsregisternamespaces", state.globals(REGISTER_NAMESPACES))
      .pretty_print(f_init);

  Printv(f_wrap_cpp, f_init, 0);

  return SWIG_OK;
}

int JSCEmitter::close() {
  Delete(f_runtime);
  Delete(f_header);
  Delete(f_wrappers);
  Delete(f_init);
  Delete(namespaces);
  Delete(f_wrap_cpp);
  return SWIG_OK;
}

int JSCEmitter::enterFunction(Node *n) {

  JSEmitter::enterFunction(n);

  return SWIG_OK;
}

int JSCEmitter::exitFunction(Node *n) {
  Template t_function = getTemplate("jsc_function_declaration");

  bool is_member = GetFlag(n, "ismember") != 0 || GetFlag(n, "feature:extend") != 0;
  bool is_overloaded = GetFlag(n, "sym:overloaded") != 0;

  // handle overloaded functions
  if (is_overloaded) {
    if (!Getattr(n, "sym:nextSibling")) {
      //state.function(WRAPPER_NAME, Swig_name_wrapper(Getattr(n, "name")));
      // create dispatcher
      emitFunctionDispatcher(n, is_member);
    } else {
      //don't register wrappers of overloaded functions in function tables
      return SWIG_OK;
    }
  }

  t_function.replace("$jsname", state.function(NAME))
      .replace("$jswrapper", state.function(WRAPPER_NAME));

  if (is_member) {
    if (GetFlag(state.function(), IS_STATIC)) {
      t_function.pretty_print(state.clazz(STATIC_FUNCTIONS));
    } else {
      t_function.pretty_print(state.clazz(MEMBER_FUNCTIONS));
    }
  } else {
    t_function.pretty_print(Getattr(current_namespace, "functions"));
  }

  return SWIG_OK;
}

int JSCEmitter::enterVariable(Node *n) {
  JSEmitter::enterVariable(n);
  state.variable(GETTER, NULL_STR);
  state.variable(SETTER, VETO_SET);
  return SWIG_OK;
}

int JSCEmitter::exitVariable(Node *n) {
  Template t_variable(getTemplate("jsc_variable_declaration"));
  t_variable.replace("$jsname", state.variable(NAME))
      .replace("$jsgetter", state.variable(GETTER))
      .replace("$jssetter", state.variable(SETTER));

  if (GetFlag(n, "ismember")) {
    if (GetFlag(state.variable(), IS_STATIC)
	|| Equal(Getattr(n, "nodeType"), "enumitem")) {
      t_variable.pretty_print(state.clazz(STATIC_VARIABLES));
    } else {
      t_variable.pretty_print(state.clazz(MEMBER_VARIABLES));
    }
  } else {
    t_variable.pretty_print(Getattr(current_namespace, "values"));
  }

  return SWIG_OK;
}

int JSCEmitter::enterClass(Node *n) {
  JSEmitter::enterClass(n);
  state.clazz(MEMBER_VARIABLES, NewString(""));
  state.clazz(MEMBER_FUNCTIONS, NewString(""));
  state.clazz(STATIC_VARIABLES, NewString(""));
  state.clazz(STATIC_FUNCTIONS, NewString(""));

  Template t_class_decl = getTemplate("jsc_class_declaration");
  t_class_decl.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .pretty_print(f_wrappers);

  return SWIG_OK;
}

int JSCEmitter::exitClass(Node *n) {
  Template t_class_tables(getTemplate("jsc_class_tables"));
  t_class_tables.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsclassvariables", state.clazz(MEMBER_VARIABLES))
      .replace("$jsclassfunctions", state.clazz(MEMBER_FUNCTIONS))
      .replace("$jsstaticclassfunctions", state.clazz(STATIC_FUNCTIONS))
      .replace("$jsstaticclassvariables", state.clazz(STATIC_VARIABLES))
      .pretty_print(f_wrappers);

  /* adds the ctor wrappers at this position */
  // Note: this is necessary to avoid extra forward declarations.
  //Append(f_wrappers, state.clazz(CTOR_WRAPPERS));

  // for abstract classes add a vetoing ctor
  if (GetFlag(state.clazz(), IS_ABSTRACT)) {
    Template t_veto_ctor(getTemplate("js_veto_ctor"));
    t_veto_ctor.replace("$jswrapper", state.clazz(CTOR))
	.replace("$jsname", state.clazz(NAME))
	.pretty_print(f_wrappers);
  }

  /* adds a class template statement to initializer function */
  Template t_classtemplate(getTemplate("jsc_class_definition"));

  /* prepare registration of base class */
  String *jsclass_inheritance = NewString("");
  Node *base_class = getBaseClass(n);
  if (base_class != NULL) {
    Template t_inherit(getTemplate("jsc_class_inherit"));
    t_inherit.replace("$jsmangledname", state.clazz(NAME_MANGLED))
	.replace("$jsbaseclassmangled", SwigType_manglestr(Getattr(base_class, "name")))
	.pretty_print(jsclass_inheritance);
  } else {
    Template t_inherit(getTemplate("jsc_class_noinherit"));
    t_inherit.replace("$jsmangledname", state.clazz(NAME_MANGLED))
	.pretty_print(jsclass_inheritance);
  }

  t_classtemplate.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsmangledtype", state.clazz(TYPE_MANGLED))
      .replace("$jsclass_inheritance", jsclass_inheritance)
      .replace("$jsctor", state.clazz(CTOR))
      .replace("$jsdtor", state.clazz(DTOR))
      .pretty_print(state.globals(INITIALIZER));
  Delete(jsclass_inheritance);

  /* Note: this makes sure that there is a swig_type added for this class */
  SwigType_remember_clientdata(state.clazz(TYPE_MANGLED), NewString("0"));

  /* adds a class registration statement to initializer function */
  Template t_registerclass(getTemplate("jsc_class_registration"));
  t_registerclass.replace("$jsname", state.clazz(NAME))
      .replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsnspace", Getattr(state.clazz("nspace"), NAME_MANGLED))
      .pretty_print(state.globals(INITIALIZER));

  return SWIG_OK;
}

Hash *JSCEmitter::createNamespaceEntry(Hash *parent_hash, const char *name, const char *parent, const char *parent_mangled) {
  Hash *entry = JSEmitter::createNamespaceEntry(parent_hash, name, parent, parent_mangled);
  Setattr(entry, "functions", NewString(""));
  Setattr(entry, "values", NewString(""));
  return entry;
}

int JSCEmitter::emitNamespaces() {
  Iterator it;
  for (it = First(namespaces); it.item; it = Next(it)) {
    Hash *entry = it.item;
    String *name = Getattr(entry, NAME);
    String *name_mangled = Getattr(entry, NAME_MANGLED);
    String *parent_mangled = Getattr(entry, PARENT_MANGLED);
    String *functions = Getattr(entry, "functions");
    String *variables = Getattr(entry, "values");

    // skip the global namespace which is given by the application

    Template namespace_definition(getTemplate("jsc_nspace_declaration"));
    namespace_definition.replace("$jsglobalvariables", variables)
	.replace("$jsglobalfunctions", functions)
	.replace("$jsnspace", name_mangled)
	.replace("$jsmangledname", name_mangled)
	.pretty_print(f_wrap_cpp);

    Template t_createNamespace(getTemplate("jsc_nspace_definition"));
    t_createNamespace.replace("$jsmangledname", name_mangled);
    Append(state.globals(CREATE_NAMESPACES), t_createNamespace.str());

    // Don't register 'exports' as namespace. It is return to the application.
    if (!Equal("exports", name)) {
      Template t_registerNamespace(getTemplate("jsc_nspace_registration"));
      t_registerNamespace.replace("$jsmangledname", name_mangled)
	  .replace("$jsname", name)
	  .replace("$jsparent", parent_mangled);
      Append(state.globals(REGISTER_NAMESPACES), t_registerNamespace.str());
    }
  }

  return SWIG_OK;
}

JSEmitter *swig_javascript_create_JSCEmitter() {
  return new JSCEmitter();
}

/**********************************************************************
 * V8: JSEmitter implementation for V8 engine
 **********************************************************************/

class V8Emitter:public JSEmitter {

public:
  V8Emitter();

  virtual ~ V8Emitter();
  virtual int initialize(Node *n);
  virtual int dump(Node *n);
  virtual int close();
  virtual int enterClass(Node *n);
  virtual int exitClass(Node *n);
  virtual int enterVariable(Node *n);
  virtual int exitVariable(Node *n);
  virtual int exitFunction(Node *n);

protected:
  virtual void marshalInputArgs(Node *n, ParmList *parms, Wrapper *wrapper, MarshallingMode mode, bool is_member, bool is_static);
  virtual int emitNamespaces();

protected:
  /* built-in parts */
  String *f_runtime;
  String *f_header;
  String *f_init;
  String *f_post_init;

  /* part for class templates */
  String *f_class_templates;

  /* parts for initilizer */
  String *f_init_namespaces;
  String *f_init_class_templates;
  String *f_init_wrappers;
  String *f_init_inheritance;
  String *f_init_class_instances;
  String *f_init_static_wrappers;
  String *f_init_register_classes;
  String *f_init_register_namespaces;

  // the output cpp file
  File *f_wrap_cpp;

  String *NULL_STR;
  String *VETO_SET;
  String *moduleName;

};

V8Emitter::V8Emitter()
:  JSEmitter(JSEmitter::V8), NULL_STR(NewString("0")), VETO_SET(NewString("JS_veto_set_variable")) {
}

V8Emitter::~V8Emitter() {
  Delete(NULL_STR);
  Delete(VETO_SET);
}

int V8Emitter::initialize(Node *n) {
  JSEmitter::initialize(n);

  moduleName = Getattr(n, "name");

  // Get the output file name
  String *outfile = Getattr(n, "outfile");
  f_wrap_cpp = NewFile(outfile, "w", SWIG_output_files());
  if (!f_wrap_cpp) {
    FileErrorDisplay(outfile);
    Exit(EXIT_FAILURE);
  }

  f_runtime = NewString("");
  f_header = NewString("");
  f_class_templates = NewString("");
  f_init = NewString("");
  f_post_init = NewString("");

  f_init_namespaces = NewString("");
  f_init_class_templates = NewString("");
  f_init_wrappers = NewString("");
  f_init_inheritance = NewString("");
  f_init_class_instances = NewString("");
  f_init_static_wrappers = NewString("");
  f_init_register_classes = NewString("");
  f_init_register_namespaces = NewString("");

  // note: this is necessary for built-in generation of SWIG runtime code
  Swig_register_filebyname("begin", f_wrap_cpp);
  Swig_register_filebyname("runtime", f_runtime);
  Swig_register_filebyname("header", f_header);
  Swig_register_filebyname("wrapper", f_wrappers);
  Swig_register_filebyname("init", f_init);
  Swig_register_filebyname("post-init", f_post_init);

  state.globals(FORCE_CPP, NewString("1"));

  Swig_banner(f_wrap_cpp);

  Swig_obligatory_macros(f_runtime, "JAVASCRIPT");

  return SWIG_OK;
}

int V8Emitter::dump(Node *n) {
  /* Get the module name */
  String *module = Getattr(n, "name");

  Template initializer_define(getTemplate("js_initializer_define"));
  initializer_define.replace("$jsname", module).pretty_print(f_header);

  SwigType_emit_type_table(f_runtime, f_wrappers);

  Printv(f_wrap_cpp, f_runtime, "\n", 0);
  Printv(f_wrap_cpp, f_header, "\n", 0);
  Printv(f_wrap_cpp, f_class_templates, "\n", 0);
  Printv(f_wrap_cpp, f_wrappers, "\n", 0);

  emitNamespaces();

  // compose the initializer function using a template
  // filled with sub-parts
  Template initializer(getTemplate("js_initializer"));
  initializer.replace("$jsname", moduleName)
      .replace("$jsv8nspaces", f_init_namespaces)
      .replace("$jsv8classtemplates", f_init_class_templates)
      .replace("$jsv8wrappers", f_init_wrappers)
      .replace("$jsv8inheritance", f_init_inheritance)
      .replace("$jsv8classinstances", f_init_class_instances)
      .replace("$jsv8staticwrappers", f_init_static_wrappers)
      .replace("$jsv8registerclasses", f_init_register_classes)
      .replace("$jsv8registernspaces", f_init_register_namespaces);
  Printv(f_init, initializer.str(), 0);

  Printv(f_wrap_cpp, f_init, 0);

  Printv(f_wrap_cpp, f_post_init, 0);

  return SWIG_OK;
}

int V8Emitter::close() {
  Delete(f_runtime);
  Delete(f_header);
  Delete(f_class_templates);
  Delete(f_init_namespaces);
  Delete(f_init_class_templates);
  Delete(f_init_wrappers);
  Delete(f_init_inheritance);
  Delete(f_init_class_instances);
  Delete(f_init_static_wrappers);
  Delete(f_init_register_classes);
  Delete(f_init_register_namespaces);
  Delete(f_init);
  Delete(f_post_init);
  Delete(f_wrap_cpp);
  return SWIG_OK;
}

int V8Emitter::enterClass(Node *n) {
  JSEmitter::enterClass(n);

  // emit declaration of a v8 class template
  Template t_decl_class(getTemplate("jsv8_declare_class_template"));
  t_decl_class.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .trim()
      .pretty_print(f_class_templates);

  return SWIG_OK;
}

int V8Emitter::exitClass(Node *n) {
  if (GetFlag(state.clazz(), IS_ABSTRACT)) {
    Template t_veto_ctor(getTemplate("js_veto_ctor"));
    t_veto_ctor.replace("$jswrapper", state.clazz(CTOR))
	.replace("$jsname", state.clazz(NAME))
	.pretty_print(f_wrappers);
  }

  /* Note: this makes sure that there is a swig_type added for this class */
  String *clientData = NewString("");
  Printf(clientData, "&%s_clientData", state.clazz(NAME_MANGLED));

  /* Note: this makes sure that there is a swig_type added for this class */
  SwigType_remember_clientdata(state.clazz(TYPE_MANGLED), NewString("0"));

  // emit definition of v8 class template
  Template t_def_class = getTemplate("jsv8_define_class_template");
  t_def_class.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsname", state.clazz(NAME))
      .replace("$jsmangledtype", state.clazz(TYPE_MANGLED))
      .replace("$jsdtor", state.clazz(DTOR))
      .trim()
      .pretty_print(f_init_class_templates);

  Template t_class_instance = getTemplate("jsv8_create_class_instance");
  t_class_instance.replace("$jsname", state.clazz(NAME))
      .replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsctor", state.clazz(CTOR))
      .trim()
      .pretty_print(f_init_class_instances);

  //  emit inheritance setup
  Node *baseClass = getBaseClass(n);
  if (baseClass) {
    String *base_name = Getattr(baseClass, "name");

    Template t_inherit = getTemplate("jsv8_inherit");

    String *base_name_mangled = SwigType_manglestr(base_name);
    t_inherit.replace("$jsmangledname", state.clazz(NAME_MANGLED))
	.replace("$jsbaseclass", base_name_mangled)
	.trim()
	.pretty_print(f_init_inheritance);
    Delete(base_name_mangled);
  }
  //  emit registration of class template
  Template t_register = getTemplate("jsv8_register_class");
  t_register.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsname", state.clazz(NAME))
      .replace("$jsparent", Getattr(state.clazz("nspace"), NAME_MANGLED))
      .trim()
      .pretty_print(f_init_register_classes);

  return SWIG_OK;
}

int V8Emitter::enterVariable(Node *n) {
  JSEmitter::enterVariable(n);

  state.variable(GETTER, NULL_STR);
  state.variable(SETTER, VETO_SET);

  return SWIG_OK;
}

int V8Emitter::exitVariable(Node *n) {
  if (GetFlag(n, "ismember")) {
    if (GetFlag(state.variable(), IS_STATIC) || Equal(Getattr(n, "nodeType"), "enumitem")) {
      Template t_register = getTemplate("jsv8_register_static_variable");
      t_register.replace("$jsparent", state.clazz(NAME_MANGLED))
	  .replace("$jsname", state.variable(NAME))
	  .replace("$jsgetter", state.variable(GETTER))
	  .replace("$jssetter", state.variable(SETTER))
	  .trim()
	  .pretty_print(f_init_static_wrappers);
    } else {
      Template t_register = getTemplate("jsv8_register_member_variable");
      t_register.replace("$jsmangledname", state.clazz(NAME_MANGLED))
	  .replace("$jsname", state.variable(NAME))
	  .replace("$jsgetter", state.variable(GETTER))
	  .replace("$jssetter", state.variable(SETTER))
	  .trim()
	  .pretty_print(f_init_wrappers);
    }
  } else {
    // Note: a global variable is treated like a static variable
    //       with the parent being a nspace object (instead of class object)
    Template t_register = getTemplate("jsv8_register_static_variable");
    t_register.replace("$jsparent", Getattr(current_namespace, NAME_MANGLED))
	.replace("$jsname", state.variable(NAME))
	.replace("$jsgetter", state.variable(GETTER))
	.replace("$jssetter", state.variable(SETTER))
	.trim()
	.pretty_print(f_init_wrappers);
  }

  return SWIG_OK;
}

int V8Emitter::exitFunction(Node *n) {
  bool is_member = GetFlag(n, "ismember") != 0 || GetFlag(n, "feature:extend") != 0;

  // create a dispatcher for overloaded functions
  bool is_overloaded = GetFlag(n, "sym:overloaded") != 0;
  if (is_overloaded) {
    if (!Getattr(n, "sym:nextSibling")) {
      //state.function(WRAPPER_NAME, Swig_name_wrapper(Getattr(n, "name")));
      emitFunctionDispatcher(n, is_member);
    } else {
      //don't register wrappers of overloaded functions in function tables
      return SWIG_OK;
    }
  }
  // register the function at the specific context
  if (is_member) {
    if (GetFlag(state.function(), IS_STATIC)) {
      Template t_register = getTemplate("jsv8_register_static_function");
      t_register.replace("$jsparent", state.clazz(NAME_MANGLED))
	  .replace("$jsname", state.function(NAME))
	  .replace("$jswrapper", state.function(WRAPPER_NAME))
	  .trim()
	  .pretty_print(f_init_static_wrappers);
    } else {
      Template t_register = getTemplate("jsv8_register_member_function");
      t_register.replace("$jsmangledname", state.clazz(NAME_MANGLED))
	  .replace("$jsname", state.function(NAME))
	  .replace("$jswrapper", state.function(WRAPPER_NAME))
	  .trim()
	  .pretty_print(f_init_wrappers);
    }
  } else {
    // Note: a global function is treated like a static function
    //       with the parent being a nspace object instead of class object
    Template t_register = getTemplate("jsv8_register_static_function");
    t_register.replace("$jsparent", Getattr(current_namespace, NAME_MANGLED))
	.replace("$jsname", state.function(NAME))
	.replace("$jswrapper", state.function(WRAPPER_NAME))
	.trim()
	.pretty_print(f_init_static_wrappers);
  }

  return SWIG_OK;
}

void V8Emitter::marshalInputArgs(Node *n, ParmList *parms, Wrapper *wrapper, MarshallingMode mode, bool is_member, bool is_static) {
  Parm *p;
  String *tm = NULL;

  int startIdx = 0;
  if (is_member && !is_static && mode != Ctor) {
    startIdx = 1;
  }
  // store number of arguments for argument checks
  int num_args = emit_num_arguments(parms) - startIdx;
  String *argcount = NewString("");
  Printf(argcount, "%d", num_args);
  Setattr(n, ARGCOUNT, argcount);
  int num_required = emit_num_required(parms) - startIdx;
  SetInt(n, ARGREQUIRED, num_required);

  int i = 0;
  for (p = parms; p;) {
    String *arg = NewString("");
    String *type = Getattr(p, "type");

    // ignore varargs
    if (SwigType_isvarargs(type))
      break;

    switch (mode) {
    case Getter:
      if (is_member && i == 0) {
        if (!is_static) {
          Printv(arg, "info.Holder()", 0);
        }
        i++;
      } else {
        Printf(arg, "args[%d]", i - startIdx);
	SetInt(p, INDEX, i - startIdx);
	i += GetInt(p, "tmap:in:numinputs");
      }
      break;
    case Function:
      if (is_member && !is_static && i == 0) {
	Printv(arg, "args.Holder()", 0);
	i++;
      } else {
	Printf(arg, "args[%d]", i - startIdx);
	SetInt(p, INDEX, i - startIdx);
	i += GetInt(p, "tmap:in:numinputs");
      }
      break;
    case Setter:
      if (is_member && !is_static && i == 0) {
	Printv(arg, "info.Holder()", 0);
	i++;
      } else {
	Printv(arg, "value", 0);
	i++;
      }
      break;
    case Ctor:
      Printf(arg, "args[%d]", i);
      SetInt(p, INDEX, i);
      i += GetInt(p, "tmap:in:numinputs");
      break;
    default:
      Printf(stderr, "Illegal MarshallingMode.");
      Exit(EXIT_FAILURE);
    }

    if (Len(arg) > 0) {
      tm = emitInputTypemap(n, p, wrapper, arg);
    }
    Delete(arg);

    if (tm) {
      p = Getattr(p, "tmap:in:next");
    } else {
      p = nextSibling(p);
    }
  }

  for (p = parms; p;) {
    tm = emitCheckTypemap(n, p, wrapper, Getattr(p, "emit:input"));
    if (tm) {
      p = Getattr(p, "tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }
}

int V8Emitter::emitNamespaces() {
  Iterator it;
  for (it = First(namespaces); it.item; it = Next(it)) {
    Hash *entry = it.item;
    String *name = Getattr(entry, NAME);
    String *name_mangled = Getattr(entry, NAME_MANGLED);
    String *parent = Getattr(entry, PARENT);
    String *parent_mangled = Getattr(entry, PARENT_MANGLED);

    bool do_create = true;
    bool do_register = true;

    if (Equal(parent, "")) {
      do_register = false;
    }
    // Note: 'exports' is by convention the name of the object where
    // globals are stored into
    if (Equal(name, "exports")) {
      do_create = false;
    }

    if (do_create) {
      // create namespace object and register it to the parent scope
      Template t_create_ns = getTemplate("jsv8_create_namespace");
      t_create_ns.replace("$jsmangledname", name_mangled)
	  .trim()
	  .pretty_print(f_init_namespaces);
    }

    if (do_register) {
      Template t_register_ns = getTemplate("jsv8_register_namespace");
      t_register_ns.replace("$jsmangledname", name_mangled)
	  .replace("$jsname", name)
	  .replace("$jsparent", parent_mangled)
	  .trim();

      // prepend in order to achieve reversed order of registration statements
      String *tmp_register_stmt = NewString("");
      t_register_ns.pretty_print(tmp_register_stmt);
      Insert(f_init_register_namespaces, 0, tmp_register_stmt);
      Delete(tmp_register_stmt);
    }
  }

  return SWIG_OK;
}

/**********************************************************************
 * NAPI: JSEmitter implementation for N-API
 **********************************************************************/

class NAPIEmitter:public JSEmitter {
public:
  NAPIEmitter();

  virtual ~NAPIEmitter();
  virtual int initialize(Node *n);
  virtual int dump(Node *n);
  virtual int close();
  virtual int enterClass(Node *n);
  virtual int exitClass(Node *n);
  virtual int enterVariable(Node *n);
  virtual int exitVariable(Node *n);
  virtual int exitFunction(Node *n);

protected:
  virtual void marshalInputArgs(Node *, ParmList *, Wrapper *, MarshallingMode,
                                bool, bool);
  virtual String *GetClassUnit(const void *);
  virtual int emitChecks(Node *, ParmList *, Wrapper *);
  virtual String *emitAsyncTypemaps(Node *, Parm *, Wrapper *, const char *);
  virtual String *emitLocking(Node *, Parm *, Wrapper *);
  virtual String *emitGuard(Node *);
  virtual int emitNamespaces();
  virtual int emitConstant(Node *n);
  virtual int emitGetter(Node *n, bool is_member, bool is_static);
  virtual int emitSetter(Node *n, bool is_member, bool is_static);
  virtual int emitCtor(Node *);
  virtual int emitFunction(Node *, bool, bool);
  virtual int emitFunctionDeclaration(Node *, bool);
  virtual int emitFunctionDefinition(Node *, bool, bool, bool);
  virtual int emitFunctionDispatcher(Node *, bool, bool);
  virtual int emitDtor(Node *);
  virtual int emitClassMethodDeclaration(Node *);
  virtual int emitNativeFunction(Node *);

  virtual const char *getFunctionTemplate(bool is_member, bool is_async);
  virtual const char *getFunctionDispatcherTemplate(bool is_member);
  virtual const char *getOverloadedFunctionTemplate(bool is_member, bool is_async);
  virtual const char *getSetterTemplate(bool is_member);
  virtual const char *getGetterTemplate(bool is_member);

protected:
  /* built-in parts */
  String *f_begin;
  String *f_runtime;
  String *f_header;
  String *f_init;
  String *f_post_init;

  /* class declarations */
  String *f_class_declarations;
  String *f_template_definitions;

  /* parts for initilizer */
  String *f_init_namespaces;
  String *f_init_wrappers;
  String *f_init_inheritance;
  String *f_init_static_wrappers;
  String *f_init_register_classes;
  String *f_init_register_namespaces;

  String *NULL_STR;
  String *moduleName;

  /* the global (top-level) symbols, used to generate the exports file */
  Hash *f_global_symbols;

  // The wrappers code, each class has its separate file and there is a global one
  Hash *f_split_wrappers;

  // the current index in the class table
  size_t class_idx;
};

NAPIEmitter::NAPIEmitter()
    : JSEmitter(JSEmitter::NAPI), NULL_STR(NewString("0")),
      f_global_symbols(NewHash()), f_split_wrappers(NewHash()), class_idx(0) {}

NAPIEmitter::~NAPIEmitter() {
  Delete(NULL_STR);
}

int NAPIEmitter::initialize(Node *n) {
  JSEmitter::initialize(n);

  moduleName = Getattr(n, "name");

  f_begin = NewString("");
  f_runtime = NewString("");
  f_header = NewString("");
  f_init = NewString("");
  f_post_init = NewString("");

  f_class_declarations = NewString("");
  f_template_definitions = NewString("");

  f_init_namespaces = NewString("");
  f_init_wrappers = NewString("");
  f_init_inheritance = NewString("");
  f_init_static_wrappers = NewString("");
  f_init_register_classes = NewString("");
  f_init_register_namespaces = NewString("");

  // note: this is necessary for built-in generation of SWIG runtime code
  Swig_register_filebyname("begin", f_begin);
  Swig_register_filebyname("runtime", f_runtime);
  Swig_register_filebyname("header", f_header);
  Swig_register_filebyname("wrapper", f_wrappers);
  Swig_register_filebyname("init", f_init);
  Swig_register_filebyname("post-init", f_post_init);

  state.globals(FORCE_CPP, NewString("1"));

  Swig_banner(f_begin);

  Swig_obligatory_macros(f_runtime, "JAVASCRIPT");

  return SWIG_OK;
}

String *NAPIEmitter::GetClassUnit(const void *name) {
  if (!Getattr(f_split_wrappers, name)) {
    Setattr(f_split_wrappers, name, NewString(""));
  }
  return Getattr(f_split_wrappers, name);
}

int NAPIEmitter::dump(Node *n) {
  /* Get the module name */
  String *module = Getattr(n, "name");

  List *file_parts = Split(Getattr(n, "outfile"), '.', 2);
  Iterator file_parts_it = First(file_parts);
  String *output_root = file_parts_it.item;
  String *output_ext = Next(file_parts_it).item;

  Template initializer_define(getTemplate("js_initializer_define"));
  initializer_define.replace("$jsname", module).pretty_print(f_header);

  SwigType_emit_type_table(f_runtime, GetClassUnit(GLOBAL_WRAPPERS));

  String *header_file = NewString("");
  Printf(header_file, "%s.h", output_root);

  File *f_main_file = NewFile(Getattr(n, "outfile"), "w", SWIG_output_files());
  Swig_banner(f_main_file);
  if (code_splitting) {
    Printf(f_main_file, "\n#include \"%s\"\n\n", header_file);
  }

  File *f_header_file;
  if (code_splitting) {
    f_header_file = NewFile(header_file, "w", SWIG_output_files());
  } else {
    f_header_file = f_main_file;
  }
  Printv(f_header_file, f_begin, "\n", 0);
  Printv(f_header_file, f_runtime, "\n", 0);
  Printv(f_header_file, f_header, "\n", 0);
  Printv(f_header_file, f_class_declarations, "\n", 0);
  Printv(f_header_file, f_template_definitions, "\n", 0);

  Printv(f_main_file, f_wrappers, "\n", 0);

  List *units = Keys(f_split_wrappers);
  File *file = f_main_file;
  for (Iterator it = First(units); it.item; it = Next(it)) {
    if (code_splitting) {
      String *file_name = NewString("");
      Printf(file_name, "%s_%s.%s", output_root, it.item, output_ext);
      file = NewFile(file_name, "w", SWIG_output_files());

      if (!file) {
        FileErrorDisplay(file_name);
        Exit(EXIT_FAILURE);
      }
      Swig_banner(file);
      Delete(file_name);
      Printf(file, "\n#include \"%s\"\n\n", header_file);
    }
    Printf(file, "%s\n", Getattr(f_split_wrappers, it.item));
  }

  emitNamespaces();

  // compose the initializer function using a template
  // filled with sub-parts
  Template initializer(getTemplate("js_initializer"));
  initializer.replace("$jsname", moduleName)
      .replace("$jsnapinspaces", f_init_namespaces)
      .replace("$jsnapiinitinheritance", f_init_inheritance)
      .replace("$jsnapiregisterclasses", f_init_register_classes)
      .replace("$jsnapiregisternspaces", f_init_register_namespaces);
  Printv(f_init, initializer.str(), 0);

  Printv(f_main_file, f_init, 0);
  Printv(f_main_file, f_post_init, 0);

  if (js_napi_generate_exports) {
    String *exports_file = NewString("");
    Printf(exports_file, "%s.cjs", output_root);
    File *f_exports = NewFile(exports_file, "w", SWIG_output_files());
    if (!f_exports) {
      FileErrorDisplay(exports_file);
      Exit(EXIT_FAILURE);
    }

    Swig_banner(f_exports);

    Template t_exports(getTemplate("jsnapi_exports"));
    String *exports = NewString("");
    List *global_symbols = Keys(f_global_symbols);
    for (Iterator it = First(global_symbols); it.item; it = Next(it)) {
      Printf(exports, "  %s,\n", it.item);
    }
    t_exports.replace("$jsexportlist", exports)
        .replace("$file", js_napi_generate_exports)
        .print(f_exports);

    Delete(global_symbols);
    Delete(exports);
    Delete(exports_file);
  }

  Delete(file_parts);
  return SWIG_OK;
}

int NAPIEmitter::close() {
  Delete(f_runtime);
  Delete(f_header);
  Delete(f_class_declarations);
  Delete(f_template_definitions);
  Delete(f_init_namespaces);
  Delete(f_init_wrappers);
  Delete(f_init_inheritance);
  Delete(f_init_static_wrappers);
  Delete(f_init_register_classes);
  Delete(f_init_register_namespaces);
  Delete(f_init);
  Delete(f_post_init);
  return SWIG_OK;
}

const char *NAPIEmitter::getFunctionTemplate(bool is_member, bool is_async) {
  if (is_async) {
    return is_member ? "js_function_async" : "js_global_function_async";
  }
  return is_member ? "js_function" : "js_global_function";
}

const char *NAPIEmitter::getFunctionDispatcherTemplate(bool is_member) {
  return is_member ? "js_function_dispatcher" : "js_global_function_dispatcher";
}

const char *NAPIEmitter::getOverloadedFunctionTemplate(bool is_member, bool is_async) {
  if (is_async) {
    return is_member ? "js_overloaded_function_async" : "js_global_overloaded_function_async";
  }
  return is_member ? "js_overloaded_function" : "js_global_overloaded_function";
}

const char *NAPIEmitter::getGetterTemplate(bool is_member) {
  return is_member ? "js_getter" : "js_global_getter";
}

const char *NAPIEmitter::getSetterTemplate(bool is_member) {
  return is_member ? "js_setter" : "js_global_setter";
}

int NAPIEmitter::enterClass(Node *n) {
  JSEmitter::enterClass(n);

  //  emit registration of class template
  String *idx = NewString("");
  Printf(idx, "%d", class_idx++);
  Template t_register = getTemplate("jsnapi_registerclass");
  String *nspace = Getattr(state.clazz("nspace"), NAME_MANGLED);
  t_register.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsname", state.clazz(NAME))
      .replace("$jsparent", nspace)
      .replace("$jsmangledtype", state.clazz(TYPE_MANGLED))
      .replace("$jsclassidx", idx)
      .trim()
      .pretty_print(f_init_register_classes);
  Delete(idx);
  if (Equal(nspace, "exports")) {
    SetFlag(f_global_symbols, state.clazz(NAME));
  }

  // emit inheritance
  String *baseMangled;
  Node *baseClass = getBaseClass(n);
  SetFlag(n, IS_WRAPPED);
  if (baseClass && GetFlag(baseClass, IS_WRAPPED)) {
    String *jsName = NewString("");
    String *nspace = Getattr(baseClass, "sym:nspace");
    if (Len(nspace) == 0)
      nspace = Getattr(current_namespace, NAME_MANGLED);
    Printf(jsName, "%s_%s", nspace, Getattr(baseClass, "sym:name"));
    baseMangled = SwigType_manglestr(jsName);
    Delete(jsName);

    f_init_wrappers = Copy(Getattr(baseClass, MEMBER_FUNCTIONS));
    f_init_static_wrappers = Copy(Getattr(baseClass, STATIC_FUNCTIONS));
  } else {
    baseMangled = NewString("SWIG_NAPI_ObjectWrap");
    f_init_wrappers = NewString("");
    f_init_static_wrappers = NewString("");
  }
  state.clazz(PARENT_MANGLED, baseMangled);

  Template t_setup_inheritance(getTemplate("jsnapi_setup_inheritance"));
  t_setup_inheritance.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jswrapper", state.clazz(CTOR))
      .replace("$jsname", state.clazz(NAME))
      .replace("$jsparent", baseMangled)
      .pretty_print(f_init_inheritance);

  // emit declaration of a NAPI class template
  Template t_decl_class(getTemplate("jsnapi_class_prologue_template"));
  t_decl_class.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsparent", baseMangled)
      .trim()
      .pretty_print(f_class_declarations);

  Delete(baseMangled);
  return SWIG_OK;
}

int NAPIEmitter::exitClass(Node *n) {
  if (GetFlag(state.clazz(), IS_ABSTRACT)) {
    Template t_veto_ctor(getTemplate("js_veto_ctor"));
    String *result = NewString("");
    t_veto_ctor.replace("$jsmangledname", state.clazz(NAME_MANGLED))
	.replace("$jswrapper", state.clazz(CTOR))
	.replace("$jsname", state.clazz(NAME))
	.replace("$jsparent", state.clazz(PARENT_MANGLED))
	.pretty_print(result);
    Append(f_template_definitions, result);
  }

  /* Note: this makes sure that there is a swig_type added for this class */
  String *clientData = NewString("");
  Printf(clientData, "&%s_clientData", state.clazz(NAME_MANGLED));

  /* Note: this makes sure that there is a swig_type added for this class */
  SwigType_remember_clientdata(state.clazz(TYPE_MANGLED), NewString("0"));

  /* emit definition of NAPI class template */
  Template t_def_class = getTemplate("jsnapi_class_epilogue_template");
  t_def_class.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsname", state.clazz(NAME))
      .replace("$jsmangledtype", state.clazz(TYPE_MANGLED))
      .replace("$jsdtor", state.clazz(DTOR))
      .trim()
      .pretty_print(f_class_declarations);

  Template t_class_instance = getTemplate("jsnapi_declare_class_instance");
  t_class_instance.replace("$jsname", state.clazz(NAME))
      .replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsmangledtype", state.clazz(TYPE_MANGLED))
      .trim()
      .pretty_print(f_class_declarations);

  Template t_class_template = getTemplate("jsnapi_getclass");
  t_class_template.replace("$jsname", state.clazz(NAME))
      .replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsnapiwrappers", f_init_wrappers)
      .replace("$jsnapistaticwrappers", f_init_static_wrappers)
      .replace("$jsparent", state.clazz(PARENT_MANGLED))
      .trim()
      .pretty_print(GetClassUnit(state.clazz(NAME_MANGLED)));

  /* Save these to be reused in the child classes */
  Setattr(n, MEMBER_FUNCTIONS, f_init_wrappers);
  Setattr(n, STATIC_FUNCTIONS, f_init_static_wrappers);
  return SWIG_OK;
}

int NAPIEmitter::enterVariable(Node *n) {
  // Somehow, this is not always reset
  // (some constructs like smart pointers reuse Nodes)
  UnsetFlag(n, "constant");

  JSEmitter::enterVariable(n);

  state.variable(GETTER, NULL);
  state.variable(SETTER, NULL);

  return SWIG_OK;
}

int NAPIEmitter::exitVariable(Node *n) {
  const char *templ = NULL;

  // Due to special handling of C++ "static const" member variables
  // (refer to the comment in lang.cxx:Language::staticmembervariableHandler)
  // a static const member variable may get transformed into a constant
  // and be emitted by emitConstant which will result calling exitVariable twice
  if (GetFlag(n, "constant")) {
    return SWIG_OK;
  }

  if (!state.variable(GETTER)) {
    return SWIG_ERROR;
  }

  if (GetFlag(n, "ismember")) {
    String *modifier = NewStringEmpty();
    String *target = NULL;

    if (GetFlag(state.variable(), IS_STATIC) ||
        Equal(Getattr(n, "nodeType"), "enumitem")) {
      templ = state.variable(SETTER) ? "jsnapi_register_static_variable"
                                     : "jsnapi_register_static_constant";
      Append(modifier, "static");
      target = f_init_static_wrappers;
    } else {
      templ = state.variable(SETTER) ? "jsnapi_register_member_variable"
                                     : "jsnapi_register_member_constant";
      target = f_init_wrappers;
    }
    Template t_register = getTemplate(templ);
    t_register.replace("$jsmangledname", state.clazz(NAME_MANGLED))
        .replace("$jsname", state.variable(NAME))
        .replace("$jsgetter", state.variable(GETTER));
    if (state.variable(SETTER) != NULL)
      t_register.replace("$jssetter", state.variable(SETTER));
    t_register.trim().pretty_print(target);

    // emit declaration of a class member function
    Template t_getter = getTemplate("jsnapi_class_method_declaration");
    t_getter.replace("$jsmangledname", state.clazz(NAME_MANGLED))
        .replace("$jsname", state.clazz(NAME))
        .replace("$jsmangledtype", state.clazz(TYPE_MANGLED))
        .replace("$jsdtor", state.clazz(DTOR))
        .replace("$jswrapper", state.variable(GETTER))
        .replace("$jsstatic", modifier)
        .trim()
        .pretty_print(f_class_declarations);

    if (state.variable(SETTER) != NULL) {
      Template t_setter = getTemplate("jsnapi_class_setter_declaration");
      t_setter.replace("$jsmangledname", state.clazz(NAME_MANGLED))
          .replace("$jsname", state.clazz(NAME))
          .replace("$jsmangledtype", state.clazz(TYPE_MANGLED))
          .replace("$jsdtor", state.clazz(DTOR))
          .replace("$jswrapper", state.variable(SETTER))
          .replace("$jsstatic", modifier)
          .trim()
          .pretty_print(f_class_declarations);
    }
    Delete(modifier);
  } else {
    templ = state.variable(SETTER) ? "jsnapi_register_global_variable"
                                   : "jsnapi_register_global_constant";

    Template t_register = getTemplate(templ);
    String *nspace = Getattr(current_namespace, NAME_MANGLED);
    t_register.replace("$jsparent", nspace)
        .replace("$jsname", state.variable(NAME))
        .replace("$jsgetter", state.variable(GETTER));

    if (state.variable(SETTER) != NULL)
      t_register.replace("$jssetter", state.variable(SETTER));

    t_register.trim().pretty_print(f_init_register_namespaces);
    if (Equal(nspace, "exports")) {
      SetFlag(f_global_symbols, state.variable(NAME));
    }
  }

  return SWIG_OK;
}

int NAPIEmitter::emitConstant(Node *n) {
  bool is_member = GetFlag(n, "ismember") != 0;

  File *wrappers;
  if (is_member) {
    wrappers = f_wrappers;
    f_wrappers = f_template_definitions;
  }
  int rc = JSEmitter::emitConstant(n);
  if (is_member) {
    f_wrappers = wrappers;
  }
  if (rc != SWIG_OK) return rc;

  if (!is_member) {
    String *wrap_name = state.variable(GETTER);
    Template t_declaration = getTemplate("js_global_declaration");
    t_declaration.replace("$jswrapper", wrap_name)
        .trim()
        .pretty_print(f_class_declarations);
  }
  return SWIG_OK;
}

static String *AsyncWorkerFragmentName = NewString("AsyncWorker");

String *NAPIEmitter::emitAsyncTypemaps(Node *, Parm *parms, Wrapper *,
                                   const char *tmname) {
  String *result = NewString("");
  String *tmcode = NewString("");
  String *tmnext = NewString("");
  Printf(tmcode, "tmap:%s", tmname);
  Printf(tmnext, "tmap:%s:next", tmname);

  for (Parm *p = parms; p;) {
    String *tm = Getattr(p, tmcode);

    if (tm != NULL) {
      String *arg = Getattr(p, "emit:input");

      // Do not emit typemaps for numinput=0 arguments
      if (arg != NULL) {
        Replaceall(tm, "$input", arg);
        Append(result, tm);
        Append(result, "\n");
      }
      p = Getattr(p, tmnext);
    } else {
      p = nextSibling(p);
    }
  }
  Delete(tmcode);
  Delete(tmnext);

  return result;
}

int NAPIEmitter::emitGetter(Node *n, bool is_member, bool is_static) {
  Wrapper *wrapper = NewWrapper();
  bool locking_enabled = State::IsSet(Getattr(n, "feature:async:locking"),
                                      js_napi_default_is_locked);
  Template t_getter(getTemplate(getGetterTemplate(is_member)));

  // prepare wrapper name
  String *wrap_name = Swig_name_wrapper(Getattr(n, "sym:name"));
  Setattr(n, "wrap:name", wrap_name);
  state.variable(GETTER, wrap_name);

  // prepare local variables
  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, wrapper);
  emit_attach_parmmaps(params, wrapper);
  if (locking_enabled) {
    Swig_typemap_attach_parms("lock", params, wrapper);
  }

  // prepare code part
  String *action = emit_action(n);
  marshalInputArgs(n, params, wrapper, Getter, is_member, is_static);
  emitChecks(n, params, wrapper);
  Append(wrapper->code, emitAsyncTypemaps(n, params, wrapper, "lock"));
  String *input = wrapper->code;

  wrapper->code = NewString("");
  marshalOutput(n, params, wrapper, NewString(""));
  String *output = wrapper->code;

  wrapper->code = NewString("");
  String *cleanup = emitCleanupCode(n, params);

  String *guard = emitGuard(n);
  String *locking = emitLocking(n, params, wrapper);

  String *result = NewString("");
  t_getter.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jswrapper", wrap_name)
      .replace("$jslocals", wrapper->locals)
      .replace("$jsguard", guard)
      .replace("$jsinput", input)
      .replace("$jslock", locking)
      .replace("$jsaction", action)
      .replace("$jsoutput", output)
      .replace("$jscleanup", cleanup)
      .pretty_print(result);
  Append(is_member ? f_template_definitions : GetClassUnit(GLOBAL_WRAPPERS), result);

  if (!is_member) {
    Template t_declaration = getTemplate("js_global_declaration");
    t_declaration.replace("$jswrapper", wrap_name)
        .trim()
        .pretty_print(f_class_declarations);
  }

  DelWrapper(wrapper);
  Delete(guard);
  Delete(locking);
  Delete(cleanup);

  return SWIG_OK;
}

int NAPIEmitter::emitSetter(Node *n, bool is_member, bool is_static) {

  // skip variables that are immutable
  if (State::IsSet(state.variable(IS_IMMUTABLE))) {
    return SWIG_OK;
  }

  Wrapper *wrapper = NewWrapper();
  bool locking_enabled = State::IsSet(Getattr(n, "feature:async:locking"),
                                      js_napi_default_is_locked);

  Template t_setter(getTemplate(getSetterTemplate(is_member)));

  // prepare wrapper name
  String *wrap_name = Swig_name_wrapper(Getattr(n, "sym:name"));
  Setattr(n, "wrap:name", wrap_name);
  state.variable(SETTER, wrap_name);

  // prepare local variables
  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, wrapper);
  emit_attach_parmmaps(params, wrapper);
  if (locking_enabled) {
    Swig_typemap_attach_parms("lock", params, wrapper);
  }

  // prepare code part
  String *action = emit_action(n);
  marshalInputArgs(n, params, wrapper, Setter, is_member, is_static);
  emitChecks(n, params, wrapper);
  Append(wrapper->code, emitAsyncTypemaps(n, params, wrapper, "lock"));
  String *input = wrapper->code;

  String *cleanup = emitCleanupCode(n, params);

  String *guard = emitGuard(n);
  String *locking = emitLocking(n, params, wrapper);

  String *result = NewString("");
  t_setter.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jswrapper", wrap_name)
      .replace("$jslocals", wrapper->locals)
      .replace("$jsinput", input)
      .replace("$jsguard", guard)
      .replace("$jslock", locking)
      .replace("$jsaction", action)
      .replace("$jscleanup", cleanup)
      .pretty_print(result);
  Append(is_member ? f_template_definitions : GetClassUnit(GLOBAL_WRAPPERS), result);

  if (!is_member) {
    Template t_declaration = getTemplate("js_global_setter_declaration");
    t_declaration.replace("$jswrapper", wrap_name)
        .trim()
        .pretty_print(f_class_declarations);
  }

  DelWrapper(wrapper);
  Delete(guard);
  Delete(locking);
  Delete(cleanup);

  return SWIG_OK;
}

int NAPIEmitter::emitFunctionDefinition(Node *n, bool is_member, bool is_static,
                                        bool is_async) {
  Wrapper *wrapper = NewWrapper();
  Template t_function(getTemplate(getFunctionTemplate(is_member, is_async)));

  bool is_overloaded = GetFlag(n, "sym:overloaded") != 0;
  bool locking_enabled = State::IsSet(Getattr(n, "feature:async:locking"),
                                      js_napi_default_is_locked);

  // prepare the function wrapper name
  String *iname;
  if (is_async)
    iname = Getattr(n, "sym:name:async");
  else
    iname = Getattr(n, "sym:name:sync");
  String *wrap_name = Swig_name_wrapper(iname);
  if (is_overloaded) {
    t_function =
        getTemplate(getOverloadedFunctionTemplate(is_member, is_async));
    Append(wrap_name, Getattr(n, "sym:overname"));
  }
  if (is_async)
    Setattr(n, "wrap:name:async", wrap_name);
  else
    Setattr(n, "wrap:name:sync", wrap_name);
  Setattr(n, "wrap:name", wrap_name);
  state.function(WRAPPER_NAME, wrap_name);

  if (is_async)
    Swig_fragment_emit(AsyncWorkerFragmentName);

  // prepare local variables
  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, wrapper);
  emit_attach_parmmaps(params, wrapper);
  if (locking_enabled) {
    Swig_typemap_attach_parms("lock", params, wrapper);
  } else if (is_async) {
    Swig_warning(WARN_TYPEMAP_THREAD_UNSAFE, input_file, line_number,
                 "Generating an asynchronous wrapper %s without locking.\n",
                 Getattr(n, "sym:name"));
  }

  // Historically, marshalInput/marshalOutput
  // return their output in wrapper->code
  // We need each part separately
  marshalInputArgs(n, params, wrapper, Function, is_member, is_static);
  String *input = wrapper->code;

  wrapper->code = NewString("");
  emitChecks(n, params, wrapper);
  Append(wrapper->code, emitAsyncTypemaps(n, params, wrapper, "lock"));
  String *checks = wrapper->code;

  // This must be done after input (which resolves the parameters)
  // but before emit_action (which emits the local variables)
  String *guard = emitGuard(n);
  String *locking = emitLocking(n, params, wrapper);

  Hash *action = emit_action_hash(n);

  String *rethrow = NewStringEmpty();
  if (is_async) {
    // In async mode %exception wraps around the rethrow statement
    String *rethrow_templ = NewStringEmpty();
    Template(getTemplate("js_rethrow_exception")).print(rethrow_templ);
    emit_action_code(n, rethrow, rethrow_templ);
  } else {
    // In sync mode %exception wraps around the action itself and becomes the
    // action
    emit_action_code(n, rethrow, Getattr(action, "action"));
    Delete(Getattr(action, "action"));
    Setattr(action, "action", rethrow);
    rethrow = NULL;
  }

  wrapper->code = NewString("");
  marshalOutput(n, params, wrapper, NewString(""));
  String *output = wrapper->code;

  String *cleanup = emitCleanupCode(n, params);

  String *jsasyncworker = NewString("");
  if (is_async) {
    Template t_worker(getTemplate("js_async_worker_local_class"));
    t_worker.print(jsasyncworker);
  }

  SwigType *returntype = Getattr(n, "type");
  bool isvoid = !Cmp(returntype, "void");

  String *result = NewString("");
  t_function.replace("$jsasyncworker", jsasyncworker)
      .replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jswrapper", wrap_name)
      .replace("$jslocals", wrapper->locals)
      .replace("$jsinput", input)
      .replace("$jschecks", checks)
      .replace("$jsguard", guard)
      .replace("$jslock", locking)
      .replace("$jspreaction", Getattr(action, "preaction"))
      .replace("$jstry", Getattr(action, "try"))
      .replace("$jsaction", Getattr(action, "action"))
      .replace("$jsrethrow", rethrow)
      .replace("$jscatch", Getattr(action, "catch"))
      .replace("$jspostaction", Getattr(action, "postaction"))
      .replace("$jsoutput", output)
      .replace("$jscleanup", cleanup)
      .replace("$symname", iname)
      .replace("$jsargcount", Getattr(n, ARGCOUNT))
      .replace("$jsargrequired", Getattr(n, ARGREQUIRED))
      .replace("$isvoid", isvoid ? "1" : "0");

  t_function.pretty_print(result);
  Append(is_member ? f_template_definitions : GetClassUnit(GLOBAL_WRAPPERS), result);

  DelWrapper(wrapper);
  Delete(input);
  Delete(action);
  Delete(jsasyncworker);
  Delete(rethrow);
  Delete(cleanup);

  return SWIG_OK;
}

int NAPIEmitter::emitFunction(Node *n, bool is_member, bool is_static) {
  int rc;

  // sync/async method handling
  // We reuse the same node twice
  String *async = Getattr(n, "feature:async");
  String *sync = Getattr(n, "feature:sync");
  String *name = state.function(NAME);
  String *symbol = Getattr(n, "sym:name");

  // By default async is off ("0") unless default is async
  // also ctors, getters, setters cannot be async
  if (State::IsSet(async, js_napi_default_is_async)) {
    String *symAsync = Copy(symbol);
    String *nameAsync = Copy(name);
    if (async && !Equal(async, "1")) {
      Append(symAsync, async);
      Append(nameAsync, async);
    }
    state.function("name:async", nameAsync);
    state.function(NAME, nameAsync);
    Setattr(n, "sym:name:async", symAsync);
    rc = emitFunctionDefinition(n, is_member, is_static, true);
    if (rc != SWIG_OK)
      return rc;
    rc = emitFunctionDeclaration(n, true);
    if (rc != SWIG_OK)
      return rc;
  }

  // By default sync is on w/o suffix ("1") unless default is async
  if (State::IsSet(sync, !js_napi_default_is_async)) {
    String *symSync = Copy(symbol);
    String *nameSync = Copy(name);
    if (sync && !Equal(sync, "1")) {
      Append(symSync, sync);
      Append(nameSync, sync);
    }
    state.function("name:sync", nameSync);
    state.function(NAME, nameSync);
    Setattr(n, "sym:name:sync", symSync);
    rc = emitFunctionDefinition(n, is_member, is_static, false);
    if (rc != SWIG_OK)
      return rc;
    rc = emitFunctionDeclaration(n, false);
    if (rc != SWIG_OK)
      return rc;
  }
  return SWIG_OK;
}

int NAPIEmitter::emitClassMethodDeclaration(Node *) {
  // emit declaration of a class member function
  Template t_def_class = getTemplate("jsnapi_class_method_declaration");
  t_def_class.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsname", state.clazz(NAME))
      .replace("$jsmangledtype", state.clazz(TYPE_MANGLED))
      .replace("$jsdtor", state.clazz(DTOR))
      .replace("$jswrapper", state.function(WRAPPER_NAME))
      .replace("$jsstatic", GetFlag(state.function(), IS_STATIC) ? "static" : "")
      .trim()
      .pretty_print(f_class_declarations);

  return SWIG_OK;
}

int NAPIEmitter::emitFunctionDeclaration(Node *n, bool is_async) {
  bool is_member =
      GetFlag(n, "ismember") != 0 || GetFlag(n, "feature:extend") != 0;

  // create a dispatcher for overloaded functions
  bool is_overloaded = GetFlag(n, "sym:overloaded") != 0;
  if (is_overloaded) {
    emitClassMethodDeclaration(n);
    if (!Getattr(n, "sym:nextSibling")) {
      emitFunctionDispatcher(n, is_member, is_async);
    } else {
      return SWIG_OK;
    }
  }
  // register the function at the specific context
  if (is_member) {
    if (GetFlag(state.function(), IS_STATIC)) {
      Template t_register = getTemplate("jsnapi_register_static_function");
      t_register.replace("$jsmangledname", state.clazz(NAME_MANGLED))
          .replace("$jsname",
                   state.function(is_async ? "name:async" : "name:sync"))
          .replace("$jswrapper", state.function(WRAPPER_NAME))
          .trim()
          .pretty_print(f_init_static_wrappers);
    } else {
      Template t_register = getTemplate("jsnapi_register_member_function");
      t_register.replace("$jsmangledname", state.clazz(NAME_MANGLED))
          .replace("$jsname",
                   state.function(is_async ? "name:async" : "name:sync"))
          .replace("$jswrapper", state.function(WRAPPER_NAME))
          .trim()
          .pretty_print(f_init_wrappers);
    }

    emitClassMethodDeclaration(n);
  } else {
    // Note: a global function is treated like a static function
    //       with the parent being a nspace object instead of class object
    Template t_register = getTemplate("jsnapi_register_global_function");
    String *nspace = Getattr(current_namespace, NAME_MANGLED);
    t_register.replace("$jsparent", nspace)
        .replace("$jsname",
                 state.function(is_async ? "name:async" : "name:sync"))
        .replace("$jswrapper", state.function(WRAPPER_NAME))
        .trim()
        .pretty_print(f_init_register_namespaces);

    if (Equal(nspace, "exports")) {
      SetFlag(f_global_symbols,
              state.function(is_async ? "name:async" : "name:sync"));
    }

    Template t_declaration = getTemplate("js_global_declaration");
    t_declaration
        .replace("$jswrapper", state.function(WRAPPER_NAME))
        .trim()
        .pretty_print(f_header);
  }

  return SWIG_OK;
}

int NAPIEmitter::exitFunction(Node *) {
  return SWIG_OK;
}

int NAPIEmitter::emitFunctionDispatcher(Node *n, bool is_member, bool is_async) {
  Wrapper *wrapper = NewWrapper();

  // Generate call list, go to first node
  Node *sibl = n;

  while (Getattr(sibl, "sym:previousSibling"))
    sibl = Getattr(sibl, "sym:previousSibling"); // go all the way up

  bool is_static_dispatcher = GetFlag(state.function(), IS_STATIC);

  do {
    String *siblname =
        Getattr(sibl, is_async ? "wrap:name:async" : "wrap:name:sync");
    if (!siblname)
      siblname = Getattr(sibl, "wrap:name");

    if (siblname) {
      bool is_static_case = Equal(Getattr(sibl, "storage"), "static") ||
        // The IS_STATIC flag is present only in the temporary state
        // of the dispatched case - however its handler sets this field
        Getattr(sibl, "staticmemberfunctionHandler:name");
      if (is_static_case == is_static_dispatcher || !is_member) {
        // handle function overloading
        Template t_dispatch_case = getTemplate("js_function_dispatch_case");
        t_dispatch_case.replace("$jswrapper", siblname)
            .replace("$jsargcount", Getattr(sibl, ARGCOUNT))
            .replace("$jsargrequired", Getattr(sibl, ARGREQUIRED));

        Append(wrapper->code, t_dispatch_case.str());
      } else {
        Swig_warning(WARN_LANG_OVERLOAD_IGNORED, input_file, line_number,
                     "JavaScript does not support overloading between"
                     " a static and a non-static member in %s for %s.\n",
                     state.clazz(NAME), Getattr(n, NAME));
      }
    }

  } while ((sibl = Getattr(sibl, "sym:nextSibling")));

  Template t_function(getTemplate(getFunctionDispatcherTemplate(is_member)));

  // Note: this dispatcher function gets called after the last overloaded
  // function has been created. At this time, n.wrap:name contains the name of
  // the last wrapper function. To get a valid function name for the dispatcher
  // function we take the last wrapper name and subtract the extension
  // "sym:overname",
  String *wrap_name;
  if (is_async) {
    wrap_name = NewString(Getattr(n, "wrap:name:async"));
  } else {
    wrap_name = NewString(Getattr(n, "wrap:name:sync"));
    if (!wrap_name) {
      wrap_name = NewString(Getattr(n, "wrap:name"));
    }
  }
  String *overname = Getattr(n, "sym:overname");

  Node *methodclass = Swig_methodclass(n);
  String *class_name = Getattr(methodclass, "sym:name");

  int l1 = Len(wrap_name);
  int l2 = Len(overname);
  Delslice(wrap_name, l1 - l2, l1);

  String *new_string = NewStringf("%s_%s", class_name, wrap_name);
  String *final_wrap_name = Swig_name_wrapper(new_string);

  Setattr(n, "wrap:name", final_wrap_name);
  state.function(WRAPPER_NAME, final_wrap_name);

  t_function.replace("$jslocals", wrapper->locals)
      .replace("$jscode", wrapper->code);

  String *result = NewString("");
  // call this here, to replace all variables
  t_function.replace("$jswrapper", final_wrap_name)
      .replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jsname", state.function(NAME))
      .pretty_print(result);
  Append(is_member ? f_template_definitions : GetClassUnit(GLOBAL_WRAPPERS), result);

  // Delete the state variable
  DelWrapper(wrapper);

  return SWIG_OK;
}

int NAPIEmitter::emitNativeFunction(Node *n) {
  String *wrapname = Getattr(n, "wrap:name");
  enterFunction(n);
  state.function(WRAPPER_NAME, wrapname);
  state.function("name:sync", state.function(NAME));
  emitFunctionDeclaration(n, false);
  exitFunction(n);
  return SWIG_OK;
}

void NAPIEmitter::marshalInputArgs(Node *n, ParmList *parms, Wrapper *wrapper,
                                 MarshallingMode mode, bool is_member,
                                 bool is_static) {
  Parm *p;
  String *tm = NULL;

  int startIdx = 0;
  if (is_member && !is_static && mode != Ctor) {
    startIdx = 1;
  }
  // store number of arguments for argument checks
  int num_args = emit_num_arguments(parms) - startIdx;
  String *argcount = NewString("");
  Printf(argcount, "%d", num_args);
  Setattr(n, ARGCOUNT, argcount);
  int num_required = emit_num_required(parms) - startIdx;
  SetInt(n, ARGREQUIRED, num_required);

  int i = 0;
  for (p = parms; p;) {
    String *arg = NewString("");
    String *type = Getattr(p, "type");

    // ignore varargs
    if (SwigType_isvarargs(type))
      break;

    switch (mode) {
    case Getter:
      if (is_member && i == 0) {
        // SWIG generates a this pointer dereference for static getters
        // It is not needed in JavaScript where this will be the class itself
        if (!is_static) {
	  Printv(arg, "info.This()", 0);
        }
	i++;
      } else {
	Printf(arg, "info[%d]", i - startIdx);
	SetInt(p, INDEX, i - startIdx);
	i += GetInt(p, "tmap:in:numinputs");
      }
      break;
    case Function:
      if (is_member && !is_static && i == 0) {
	Printv(arg, "info.This()", 0);
	i++;
      } else {
	Printf(arg, "info[%d]", i - startIdx);
	SetInt(p, INDEX, i - startIdx);
	i += GetInt(p, "tmap:in:numinputs");
      }
      break;
    case Setter:
      if (is_member && !is_static && i == 0) {
	Printv(arg, "info.This()", 0);
	i++;
      } else {
	Printv(arg, "value", 0);
	i++;
      }
      break;
    case Ctor:
      Printf(arg, "info[%d]", i);
      SetInt(p, INDEX, i - startIdx);
      i += GetInt(p, "tmap:in:numinputs");
      break;
    default:
      Printf(stderr, "Illegal MarshallingMode.");
      Exit(EXIT_FAILURE);
    }

    if (Len(arg) > 0) {
      tm = emitInputTypemap(n, p, wrapper, arg);
    }
    Delete(arg);

    if (tm) {
      p = Getattr(p, "tmap:in:next");
    } else {
      p = nextSibling(p);
    }
  }
}

int NAPIEmitter::emitChecks(Node *n, ParmList *parms, Wrapper *wrapper) {
  Parm *p;
  String *tm;

  for (p = parms; p;) {
    tm = emitCheckTypemap(n, p, wrapper, Getattr(p, "emit:input"));
    if (tm) {
      p = Getattr(p, "tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }
  return SWIG_OK;
}

String *NAPIEmitter::emitLocking(Node *n, ParmList *, Wrapper *wrapper) {
  bool locking_enabled = State::IsSet(Getattr(n, "feature:async:locking"),
                                      js_napi_default_is_locked);
  if (!locking_enabled)
    return 0;

  String *locks_list = NewString("");
  Template t_locks(getTemplate("js_local_locks_list"));
  t_locks.print(locks_list);
  Append(wrapper->locals, locks_list);

  String *locking = NewString("");
  Template t_lock(getTemplate("js_lock"));
  t_lock.print(locking);

  return locking;
}

String *NAPIEmitter::emitGuard(Node *n) {
  bool locking_enabled = State::IsSet(Getattr(n, "feature:async:locking"),
                                      js_napi_default_is_locked);

  String *guard = NewString("");
  if (locking_enabled) {
    Template t_guard(getTemplate("js_guard"));
    t_guard.print(guard);
  }

  return guard;
}

int NAPIEmitter::emitNamespaces() {
  Iterator it;
  for (it = First(namespaces); it.item; it = Next(it)) {
    Hash *entry = it.item;
    String *name = Getattr(entry, NAME);
    String *name_mangled = Getattr(entry, NAME_MANGLED);
    String *parent = Getattr(entry, PARENT);
    String *parent_mangled = Getattr(entry, PARENT_MANGLED);

    bool do_create = true;
    bool do_register = true;

    if (Equal(parent, "")) {
      do_register = false;
    }
    // Note: 'exports' is by convention the name of the object where
    // globals are stored into
    if (Equal(name, "exports")) {
      do_create = false;
    }

    if (do_create) {
      // create namespace object and register it to the parent scope
      Template t_create_ns = getTemplate("jsnapi_create_namespace");
      t_create_ns.replace("$jsmangledname", name_mangled)
	  .trim()
	  .pretty_print(f_init_namespaces);
    }

    if (do_register) {
      Template t_register_ns = getTemplate("jsnapi_register_namespace");
      t_register_ns.replace("$jsmangledname", name_mangled)
	  .replace("$jsname", name)
	  .replace("$jsparent", parent_mangled)
	  .trim();

      // prepend in order to achieve reversed order of registration statements
      String *tmp_register_stmt = NewString("");
      t_register_ns.pretty_print(tmp_register_stmt);
      Insert(f_init_register_namespaces, 0, tmp_register_stmt);
      SetFlag(f_global_symbols, name);
      Delete(tmp_register_stmt);
    }
  }

  return SWIG_OK;
}

int NAPIEmitter::emitCtor(Node *n) {
  // We reuse the shared JS code but everything is redirected
  // to f_template_definitions -> it is going in the header file
  File *wrappers = f_wrappers;
  f_wrappers = f_template_definitions;
  int r = JSEmitter::emitCtor(n);
  f_wrappers = wrappers;
  if (r != SWIG_OK)
    return r;

  Template t_getter = getTemplate("jsnapi_class_method_declaration");
  t_getter.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .replace("$jswrapper", Getattr(n, "wrap:name"))
      .replace("$jsmangledtype", state.clazz(TYPE_MANGLED))
      .replace("$jsstatic", "")
      .trim()
      .pretty_print(f_class_declarations);
  return SWIG_OK;
}

int NAPIEmitter::emitDtor(Node *n) {
  // NAPI destructors must have a class declaration
  Template t_getter = getTemplate("jsnapi_class_dtor_declaration");
  t_getter.replace("$jsmangledname", state.clazz(NAME_MANGLED))
      .trim()
      .pretty_print(f_class_declarations);

  // We reuse the shared JS code but everything is redirected
  // to f_template_definitions -> it is going in the header file
  File *wrappers = f_wrappers;
  f_wrappers = f_template_definitions;
  int rc = JSEmitter::emitDtor(n);
  f_wrappers = wrappers;
  return rc;
}

JSEmitter *swig_javascript_create_V8Emitter() {
  return new V8Emitter();
}

JSEmitter *swig_javascript_create_NAPIEmitter() {
  return new NAPIEmitter();
}

/**********************************************************************
 * Helper implementations
 **********************************************************************/

JSEmitterState::JSEmitterState()
:  globalHash(NewHash()), typesHash(NewHash()) {
  // initialize sub-hashes
  Setattr(globalHash, "class", NewHash());
  Setattr(globalHash, "function", NewHash());
  Setattr(globalHash, "variable", NewHash());
}

JSEmitterState::~JSEmitterState() {
  Delete(globalHash);
}

DOH *JSEmitterState::getState(const char *key, bool new_key) {
  if (new_key) {
    Hash *hash = NewHash();
    Setattr(globalHash, key, hash);
  }
  return Getattr(globalHash, key);
}

DOH *JSEmitterState::globals() {
  return globalHash;
}

DOH *JSEmitterState::globals(const char *key, DOH *initial) {
  if (initial != 0) {
    Setattr(globalHash, key, initial);
  }
  return Getattr(globalHash, key);
}

DOH *JSEmitterState::types() { return typesHash; }

DOH *JSEmitterState::types(DOH *key, DOH *initial) {
  if (initial != 0) {
    Setattr(typesHash, key, initial);
  }
  return Getattr(typesHash, key);
}

DOH *JSEmitterState::clazz(bool new_key) {
  return getState("class", new_key);
}

DOH *JSEmitterState::clazz(const char *key, DOH *initial) {
  DOH *c = clazz();
  if (initial != 0) {
    Setattr(c, key, initial);
  }
  return Getattr(c, key);
}

DOH *JSEmitterState::function(bool new_key) {
  return getState("function", new_key);
}

DOH *JSEmitterState::function(const char *key, DOH *initial) {
  DOH *f = function();
  if (initial != 0) {
    Setattr(f, key, initial);
  }
  return Getattr(f, key);
}

DOH *JSEmitterState::variable(bool new_key) {
  return getState("variable", new_key);
}

DOH *JSEmitterState::variable(const char *key, DOH *initial) {
  DOH *v = variable();
  if (initial != 0) {
    Setattr(v, key, initial);
  }
  return Getattr(v, key);
}

/*static*/
int JSEmitterState::IsSet(DOH *val, int def) {
  if (!val) {
    return def;
  } else {
    const char *cval = Char(val);
    if (!cval)
      return def;
    return (strcmp(cval, "0") != 0) ? 1 : 0;
  }
}

/* -----------------------------------------------------------------------------
 * Template::Template() :  creates a Template class for given template code
 * ----------------------------------------------------------------------------- */

Template::Template(const String *code_) {

  if (!code_) {
    Printf(stdout, "Template code was null. Illegal input for template.");
    Exit(EXIT_FAILURE);
  }
  code = NewString(code_);
  templateName = NewString("");
}

Template::Template(const String *code_, const String *templateName_) {

  if (!code_) {
    Printf(stdout, "Template code was null. Illegal input for template.");
    Exit(EXIT_FAILURE);
  }

  code = NewString(code_);
  templateName = NewString(templateName_);
}


/* -----------------------------------------------------------------------------
 * Template::~Template() :  cleans up of Template.
 * ----------------------------------------------------------------------------- */

Template::~Template() {
  Delete(code);
  Delete(templateName);
}

/* -----------------------------------------------------------------------------
 * String* Template::str() :  retrieves the current content of the template.
 * ----------------------------------------------------------------------------- */

String *Template::str() {
  if (js_template_enable_debug) {
    String *pre_code = NewString("");
    String *post_code = NewString("");
    String *debug_code = NewString("");
    Printf(pre_code, "/* begin fragment(\"%s\") */", templateName);
    Printf(post_code, "/* end fragment(\"%s\") */", templateName);
    Printf(debug_code, "%s\n%s\n%s\n", pre_code, code, post_code);

    Delete(code);
    Delete(pre_code);
    Delete(post_code);

    code = debug_code;
  }
  return code;
}

Template & Template::trim() {
  const char *str = Char(code);
  if (str == 0)
    return *this;

  int length = Len(code);
  if (length == 0)
    return *this;

  int idx;
  for (idx = 0; idx < length; ++idx) {
    if (str[idx] != ' ' && str[idx] != '\t' && str[idx] != '\r' && str[idx] != '\n')
      break;
  }
  int start_pos = idx;

  for (idx = length - 1; idx >= start_pos; --idx) {
    if (str[idx] != ' ' && str[idx] != '\t' && str[idx] != '\r' && str[idx] != '\n')
      break;
  }
  int end_pos = idx;

  int new_length = end_pos - start_pos + 1;
  char *newstr = new char[new_length + 1];
  memcpy(newstr, str + start_pos, new_length);
  newstr[new_length] = 0;

  Delete(code);
  code = NewString(newstr);
  delete[]newstr;

  return *this;
}

/* -----------------------------------------------------------------------------
 * Template&  Template::replace(const String* pattern, const String* repl) :
 *
 *  replaces all occurrences of a given pattern with a given replacement.
 *
 *  - pattern:  the pattern to be replaced
 *  - repl:     the replacement string
 *  - returns a reference to the Template to allow chaining of methods.
 * ----------------------------------------------------------------------------- */

Template & Template::replace(const String *pattern, const String *repl) {
  Replaceall(code, pattern, repl);
  return *this;
}

Template & Template::print(DOH *doh) {
  Printv(doh, str(), 0);
  return *this;
}

Template & Template::pretty_print(DOH *doh) {
  Wrapper_pretty_print(str(), doh);
  return *this;
}

Template::Template(const Template & t) {
  code = NewString(t.code);
  templateName = NewString(t.templateName);
}

void Template::operator=(const Template & t) {
  Delete(code);
  Delete(templateName);
  code = NewString(t.code);
  templateName = NewString(t.templateName);
}

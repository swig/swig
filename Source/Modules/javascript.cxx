#include "swigmod.h"

/**
 * Enables extra debugging information in typemaps.
 */
bool js_template_enable_debug = false;

// keywords used for state variables

#define NAME "name"
#define NAME_MANGLED "name_mangled"
#define TYPE "type"
#define TYPE_MANGLED "type_mangled"
#define WRAPPER_NAME "wrapper"
#define IS_IMMUTABLE "is_immutable"
#define IS_STATIC "is_static"

/**
 * A convenience class to manage state variables for emitters.
 * The implementation delegates to swig Hash DOHs and provides
 * named sub-hashes for class, variable, and function states.
 */
class JSEmitterState {
  
public:

  JSEmitterState();

  ~JSEmitterState();
    
  DOH *global();
  
  DOH *global(const char* key, DOH *initial = 0);
  
  DOH *clazz(bool reset = false);
  
  DOH *clazz(const char* key, DOH *initial = 0);

  DOH *function(bool reset = false);

  DOH *function(const char* key, DOH *initial = 0);

  DOH *variable(bool reset = false);

  DOH *variable(const char* key, DOH *initial = 0);
  
  static int IsSet(DOH *val);
  
private:

  DOH *getState(const char* key, bool reset = false);

  Hash *_global;
};

/**
 * A convenience class that wraps a code snippet used as template 
 * for code generation.
 */
class Template {

public:
  Template(const String *code);

  Template(const String *code, const String *templateName);

  ~Template();

  String *str();

  Template& replace(const String *pattern, const String *repl);

  Template& pretty_print(DOH *doh);

private:

  String *code;
  String *templateName;

};

/**
 * JSEmitter represents an abstraction of javascript code generators
 * for different javascript engines.
 **/
class JSEmitter {

protected:

  typedef JSEmitterState State;

public:

  enum JSEmitterType {
    JavascriptCore,
    V8,
    QtScript
  };

  JSEmitter();

  virtual ~JSEmitter();

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
  virtual int switchNamespace(Node *) {
    return SWIG_OK;
  };

  /**
   * Invoked at the beginning of the classHandler.
   */
  virtual int enterClass(Node *);

  /**
   * Invoked at the end of the classHandler.
   */
  virtual int exitClass(Node *) {
    return SWIG_OK;
  };

  /**
   * Invoked at the beginning of the variableHandler.
   */
  virtual int enterVariable(Node *);

  /**
   * Invoked at the end of the variableHandler.
   */
  virtual int exitVariable(Node *) {
    return SWIG_OK;
  };

  /**
   * Invoked at the beginning of the functionHandler.
   */
  virtual int enterFunction(Node *);

  /**
   * Invoked at the end of the functionHandler.
   */
  virtual int exitFunction(Node *) {
    return SWIG_OK;
  };

  /**
   * Invoked by functionWrapper callback after call to Language::functionWrapper.
   */
  virtual int emitWrapperFunction(Node *n);

  /**
   * Invoked from constantWrapper after call to Language::constantWrapper.
   **/
  virtual int emitConstant(Node *n) = 0;

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

  State &getState();

protected:

  /**
   * Generates code for a constructor function.
   */
  virtual int emitCtor(Node *n) = 0;

  /**
   * Generates code for a destructor function.
   */
  virtual int emitDtor(Node *n) = 0;

  /**
   * Generates code for a function.
   */
  virtual int emitFunction(Node *n, bool is_member) = 0;

  /**
   * Generates code for a getter function.
   */
  virtual int emitGetter(Node *n, bool is_member) = 0;

  /**
   * Generates code for a setter function.
   */
  virtual int emitSetter(Node *n, bool is_member) = 0;

  /**
   * Helper function to find out if a function is a setter or not.
   * TODO: there should be some kind of support in swig core for that?
   */
  bool isSetterMethod(Node *n);

  /**
   * Helper function to retrieve the first parent class node.
   */
  Node *getBaseClass(Node *n);
  
  /**
   * Helper function to retrieve a certain typemap.
   */
  const String *typemapLookup(Node *n, const_String_or_char_ptr tmap_method, SwigType *type, int warning, Node *typemap_attributes = 0);

  Parm *skipIgnoredArgs(Parm *p);

protected:

  // empty string used at different places in the code
  String *empty_string;

  Hash *templates;
  
  State state;
};

/**********************************************************************
 * JAVASCRIPT: swig module implementation
 **********************************************************************/

/* factory methods for concrete JSEmitters: */
JSEmitter *swig_javascript_create_JSCEmitter();
JSEmitter *swig_javascript_create_V8Emitter();

class JAVASCRIPT:public Language {

public:

  JAVASCRIPT(): emitter(NULL) {}
  
  ~JAVASCRIPT() {
    delete emitter;
  }

  virtual int functionHandler(Node *n);
  virtual int globalfunctionHandler(Node *n);
  virtual int variableHandler(Node *n);
  virtual int globalvariableHandler(Node *n);
  virtual int staticmemberfunctionHandler(Node *n);
  virtual int classHandler(Node *n);
  virtual int functionWrapper(Node *n);
  virtual int constantWrapper(Node *n);
  
  /**
   *  Registers all %fragments assigned to section "templates".
   **/
  virtual int fragmentDirective(Node *n);
  virtual void main(int argc, char *argv[]);
  virtual int top(Node *n);

private:

  JSEmitter *emitter;
};

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

  emitter->enterFunction(n);
  Language::functionHandler(n);
  emitter->exitFunction(n);

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
  // workaround: storage=static is not set for static member functions
  emitter->getState().function(IS_STATIC, NewString("1"));
  Language::staticmemberfunctionHandler(n);
  emitter->getState().function(IS_STATIC, NULL);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * variableHandler()
 *
 * Function handler for generating wrappers for variables 
 * --------------------------------------------------------------------- */

int JAVASCRIPT::variableHandler(Node *n) {

  if (!is_assignable(n)
      // FIXME: test "arrays_global" does not compile with that as it is not allowed to assign to char[]
      // probably some error in char[] typemap 
      || Equal(Getattr(n, "type"), "a().char")) {
    SetFlag(n, "wrap:immutable");
  }
  
  emitter->enterVariable(n);
  Language::variableHandler(n);
  emitter->exitVariable(n);

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
 * constantHandler()
 *
 * Function handler for generating wrappers for constants 
 * --------------------------------------------------------------------- */

int JAVASCRIPT::constantWrapper(Node *n) {

  // Note: callbacks trigger this wrapper handler
  // TODO: handle callback declarations
  if (Equal(Getattr(n, "kind"), "function")) {
    return SWIG_OK;
  }
  emitter->emitConstant(n);

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
  Language::classHandler(n);
  emitter->exitClass(n);

  return SWIG_OK;
}

int JAVASCRIPT::fragmentDirective(Node *n) {

  // catch all fragment directives that have "templates" as location
  // and register them at the emitter.
  String *section = Getattr(n, "section");

  if (Equal(section, "templates")) {
    emitter->registerTemplate(Getattr(n, "value"), Getattr(n, "code"));
  } else {
    Swig_fragment_register(n);
  }

  return SWIG_OK;
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

  emitter->dump(n);
  emitter->close();

  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * main()
 *
 * Entry point for the JAVASCRIPT module
 * --------------------------------------------------------------------- */

void JAVASCRIPT::main(int argc, char *argv[]) {

  // Set javascript subdirectory in SWIG library
  SWIG_library_directory("javascript");

  int mode = -1;

  bool debug_templates = false;
  for (int i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i], "-v8") == 0) {
        Swig_mark_arg(i);
        mode = JSEmitter::V8;
        SWIG_library_directory("javascript/v8");
      } else if (strcmp(argv[i], "-jsc") == 0) {
        Swig_mark_arg(i);
        mode = JSEmitter::JavascriptCore;
        SWIG_library_directory("javascript/jsc");
      } else if (strcmp(argv[i], "-qt") == 0) {
        Swig_mark_arg(i);
        mode = JSEmitter::QtScript;
        SWIG_library_directory("javascript/qt");
      } else if (strcmp(argv[i], "-debug-codetemplates") == 0) {
        Swig_mark_arg(i);
        debug_templates = true;
      }
    }
  }

  switch (mode) {
  case JSEmitter::V8:
    {
      emitter = swig_javascript_create_V8Emitter();
      break;
    }
  case JSEmitter::JavascriptCore:
    {
      emitter = swig_javascript_create_JSCEmitter();
      break;
    }
  case JSEmitter::QtScript:
    {
      Printf(stderr, "QtScript support is not yet implemented.");
      SWIG_exit(-1);
      break;
    }
  default:
    {
      Printf(stderr, "Unknown emitter type.");
      SWIG_exit(-1);
      break;
    }
  }

  if (debug_templates) {
    js_template_enable_debug = true;
  }

  // Add a symbol to the parser for conditional compilation
  Preprocessor_define("SWIGJAVASCRIPT 1", 0);

  // Add typemap definitions    
  SWIG_typemap_lang("javascript");

  // Set configuration file 
  SWIG_config_file("javascript.swg");

  allow_overloading();
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

JSEmitter::JSEmitter()
:  empty_string(NewString(""))
{
  templates = NewHash();
}

/* -----------------------------------------------------------------------------
 * ~JSEmitter()
 * ----------------------------------------------------------------------------- */

JSEmitter::~JSEmitter() {
  Delete(empty_string);
  Delete(templates);
}

/* -----------------------------------------------------------------------------
 * JSEmitter::RegisterTemplate() :  Registers a code template
 * ----------------------------------------------------------------------------- */

int JSEmitter::registerTemplate(const String *name, const String *code) {
  return Setattr(templates, name, code);
}

/* -----------------------------------------------------------------------------
 * JSEmitter::GetTemplate() :  Retrieves a registered a code template
 * ----------------------------------------------------------------------------- */

Template JSEmitter::getTemplate(const String *name) {
  String *templ = Getattr(templates, name);

  if (!templ) {
    Printf(stderr, "Could not find template %s\n.", name);
    SWIG_exit(EXIT_FAILURE);
  }

  Template t(templ, name);

  return t;
}

JSEmitterState &JSEmitter::getState() {
  return state;
}

int JSEmitter::initialize(Node *) {
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * JSEmitter::typemapLookup()
 * 
 *  n - for input only and must contain info for Getfile(n) and Getline(n) to work
 *  tmap_method - typemap method name
 *  type - typemap type to lookup
 *  warning - warning number to issue if no typemaps found
 *  typemap_attributes - the typemap attributes are attached to this node and will 
 *                       also be used for temporary storage if non null
 * return is never NULL, unlike Swig_typemap_lookup()
 * ----------------------------------------------------------------------------- */

const String *JSEmitter::typemapLookup(Node *n, const_String_or_char_ptr tmap_method, SwigType *type, int warning, Node *typemap_attributes) {
  Node *node = !typemap_attributes ? NewHash() : typemap_attributes;
  Setattr(node, "type", type);
  Setfile(node, Getfile(n));
  Setline(node, Getline(n));
  const String *tm = Swig_typemap_lookup(tmap_method, node, "", 0);
  if (!tm) {
    tm = empty_string;
    if (warning != WARN_NONE) {
      Swig_warning(warning, Getfile(n), Getline(n), "No %s typemap defined for %s\n", tmap_method, SwigType_str(type, 0));
    }
  }
  if (!typemap_attributes) {
    Delete(node);
  }
  return tm;
}

/* ---------------------------------------------------------------------
 * skipIgnoredArgs()
 * --------------------------------------------------------------------- */

Parm *JSEmitter::skipIgnoredArgs(Parm *p) {
  while (checkAttribute(p, "tmap:in:numinputs", "0")) {
    p = Getattr(p, "tmap:in:next");
  }
  return p;
}

/* -----------------------------------------------------------------------------
 * JSEmitter::getBaseClass() :  the node of the base class or NULL
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
  * JSEmitter::emitWrapperFunction() :  dispatches emitter functions
  * ----------------------------------------------------------------------------- */

int JSEmitter::emitWrapperFunction(Node *n) {
  int ret = SWIG_OK;

  String *kind = Getattr(n, "kind");

  if (kind) {
    bool is_member = GetFlag(n, "ismember");
    if (Cmp(kind, "function") == 0) {
      ret = emitFunction(n, is_member);

    } else if (Cmp(kind, "variable") == 0) {
      if (isSetterMethod(n)) {
        ret = emitSetter(n, is_member);

      } else {
        ret = emitGetter(n, is_member);

      }
    } else {
      Printf(stderr, "Warning: unsupported wrapper function type\n");
      Swig_print_node(n);

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
      Swig_print_node(n);
      ret = SWIG_ERROR;
    }
  }

  return ret;
}

int JSEmitter::enterClass(Node *n) {

  state.clazz(true);
  state.clazz(NAME, Getattr(n, "sym:name"));
  state.clazz(NAME_MANGLED, SwigType_manglestr(Getattr(n, "name")));
  state.clazz(TYPE, NewString(Getattr(n, "classtype")));

  String *type = SwigType_manglestr(Getattr(n, "classtypeobj"));
  String *classtype_mangled = NewString("");
  Printf(classtype_mangled, "p%s", type);
  Delete(type);
  state.clazz(TYPE_MANGLED, classtype_mangled);

  return SWIG_OK;
}

int JSEmitter::enterFunction(Node *n) {

  state.function(true);
  state.function(NAME, Getattr(n, "sym:name"));

  return SWIG_OK;
}

int JSEmitter::enterVariable(Node *n) {
  state.variable(true);
  state.variable(NAME, Swig_scopename_last(Getattr(n, "name")));
  state.variable(IS_IMMUTABLE, Getattr(n, "wrap:immutable"));
  return SWIG_OK;
}


/* -----------------------------------------------------------------------------
 * __swigjs_str_ends_with() :  c string helper to check suffix match
 * ----------------------------------------------------------------------------- */

int __swigjs_str_ends_with(const char *str, const char *suffix) {

  if (str == NULL || suffix == NULL)
    return 0;

  size_t str_len = strlen(str);
  size_t suffix_len = strlen(suffix);

  if (suffix_len > str_len)
    return 0;

  return 0 == strncmp(str + str_len - suffix_len, suffix, suffix_len);
}


/* -----------------------------------------------------------------------------
 * JSEmitter::isSetterMethod() :  helper to check if a method is a setter function
 * ----------------------------------------------------------------------------- */

bool JSEmitter::isSetterMethod(Node *n) {
  String *symname = Getattr(n, "sym:name");
  return (__swigjs_str_ends_with((char *) Data(symname), "_set") != 0);
}

/**********************************************************************
 * JavascriptCore: JSEmitter implementation for JavascriptCore engine
 **********************************************************************/
 
class JSCEmitter:public JSEmitter {

private:

  enum MarshallingMode {
    Setter,
    Getter,
    Ctor,
    Function
  };

public:

  JSCEmitter();

  virtual ~ JSCEmitter();

  virtual int initialize(Node *n);

  virtual int dump(Node *n);

  virtual int close();


protected:

  virtual int emitCtor(Node *n);

  virtual int emitDtor(Node *n);

  virtual int enterVariable(Node *n);

  virtual int exitVariable(Node *n);

  virtual int enterFunction(Node *n);

  virtual int exitFunction(Node *n);

  virtual int enterClass(Node *n);

  virtual int exitClass(Node *n);

  virtual int emitFunction(Node *n, bool is_member);

  virtual int emitFunctionDispatcher(Node *n, bool is_member);

  virtual int emitGetter(Node *n, bool is_member);

  virtual int emitSetter(Node *n, bool is_member);

  virtual int emitConstant(Node *n);

  void marshalInputArgs(Node *n, ParmList *parms, Wrapper *wrapper, MarshallingMode mode, bool is_member, bool is_static = false);

  void marshalOutput(Node *n, String *actioncode, Wrapper *wrapper);

  virtual int switchNamespace(Node *n);

  virtual int createNamespace(String *scope);

  virtual Hash *createNamespaceEntry(const char *name, const char *parent);

  virtual int emitNamespaces();

private:

  String *NULL_STR;
  String *VETO_SET;
  const char *GLOBAL_STR;

  // contains context specific structs
  // to allow generation of different class definition tables
  // which are switched on namespace change
  Hash *namespaces;
  Hash *current_namespace;

  // output file and major code parts
  File *f_wrap_cpp;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;

};

// keys for global state variables
#define CREATE_NAMESPACES "create_namespaces"
#define REGISTER_NAMESPACES "register_namespaces"
#define INITIALIZER "initializer"

// keys for class scoped state variables
#define MEMBER_VARIABLES "member_variables"
#define MEMBER_FUNCTIONS "member_functions"
#define STATIC_FUNCTIONS "static_functions"
#define STATIC_VARIABLES "static_variables"
#define CTORS "ctors"
#define CTOR_DISPATCHERS "ctor_dispatchers"

// keys for function scoped state variables
#define FUNCTION_DISPATCHERS "function_dispatchers"
#define GETTER "getter"
#define SETTER "setter"

JSCEmitter::JSCEmitter()
: JSEmitter(), 
  NULL_STR(NewString("NULL")),
  VETO_SET(NewString("JS_veto_set_variable")),
  GLOBAL_STR(NULL),
  namespaces(NULL), 
  current_namespace(NULL), 
  f_wrap_cpp(NULL),
  f_runtime(NULL), 
  f_header(NULL), 
  f_wrappers(NULL),
  f_init(NULL)
{
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
  String *tm;
  Parm *p;

  int startIdx = 0;
  if (is_member && !is_static) {
    startIdx = 1;
  }

  int i = 0;
  for (p = parms; p; p = nextSibling(p), i++) {
    SwigType *pt = Getattr(p, "type");
    String *arg = NewString("");

    switch (mode) {
    case Getter:
    case Function:
      if (is_member && !is_static && i == 0) {
        Printv(arg, "thisObject", 0);
      } else {
        Printf(arg, "argv[%d]", i - startIdx);
      }

      break;
    case Setter:
      if (is_member && !is_static && i == 0) {
        Printv(arg, "thisObject", 0);
      } else {
        Printv(arg, "value", 0);
      }
      break;
    case Ctor:
      Printf(arg, "argv[%d]", i);
      break;
    default:
      throw "Illegal state.";
    }

    tm = Getattr(p, "tmap:in");	// Get typemap for this argument
    if (tm != NULL) {
      Replaceall(tm, "$input", arg);
      Setattr(p, "emit:input", arg);

      if (Getattr(p, "wrap:disown") || (Getattr(p, "tmap:in:disown"))) {
        Replaceall(tm, "$disown", "SWIG_POINTER_DISOWN");
      } else {
        Replaceall(tm, "$disown", "0");
      }
      Replaceall(tm, "$symname", Getattr(n, "sym:name"));

      Printf(wrapper->code, "%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
    }
    Delete(arg);
  }
}

/* ---------------------------------------------------------------------
* marshalOutput()
*
* Process the return value of the C/C++ function call
* and convert them into the Javascript types using the
* supplied typemaps.
* --------------------------------------------------------------------- */

void JSCEmitter::marshalOutput(Node *n, String *actioncode, Wrapper *wrapper) {
  SwigType *type = Getattr(n, "type");
  Setattr(n, "type", type);
  String *tm;

  // HACK: output types are not registered as swig_types automatically
  if (SwigType_ispointer(type)) {
    SwigType_remember_clientdata(type, NewString("0"));
  }

  if ((tm = Swig_typemap_lookup_out("out", n, "result", wrapper, actioncode))) {
    Replaceall(tm, "$result", "jsresult");
    Replaceall(tm, "$objecttype", Swig_scopename_last(SwigType_str(SwigType_strip_qualifiers(type), 0)));

    if (GetFlag(n, "feature:new")) {
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
  emit_return_variable(n, type, wrapper);
}

int JSCEmitter::initialize(Node *n) {
  
  JSEmitter::initialize(n);

  /* Get the output file name */
  String *outfile = Getattr(n, "outfile");

  /* Initialize I/O */
  f_wrap_cpp = NewFile(outfile, "w", SWIG_output_files());
  if (!f_wrap_cpp) {
    FileErrorDisplay(outfile);
    SWIG_exit(EXIT_FAILURE);
  }

  /* Initialization of members */
  f_runtime = NewString("");
  f_init = NewString("");
  f_header = NewString("");
  f_wrappers = NewString("");

  state.global(CREATE_NAMESPACES, NewString(""));
  state.global(REGISTER_NAMESPACES, NewString(""));
  state.global(INITIALIZER, NewString(""));

  namespaces = NewHash();
  Hash *global_namespace = createNamespaceEntry(Char(Getattr(n, "name")), "global");
  Setattr(namespaces, "::", global_namespace);
  current_namespace = global_namespace;

  /* Register file targets with the SWIG file handler */
  Swig_register_filebyname("begin", f_wrap_cpp);
  Swig_register_filebyname("header", f_header);
  Swig_register_filebyname("wrapper", f_wrappers);
  Swig_register_filebyname("runtime", f_runtime);
  Swig_register_filebyname("init", f_init);

  return SWIG_OK;
}

int JSCEmitter::dump(Node *n) {
  /* Get the module name */
  String *module = Getattr(n, "name");

  // write the swig banner
  Swig_banner(f_wrap_cpp);

  SwigType_emit_type_table(f_runtime, f_wrappers);

  Printv(f_wrap_cpp, f_runtime, "\n", 0);
  Printv(f_wrap_cpp, f_header, "\n", 0);
  Printv(f_wrap_cpp, f_wrappers, "\n", 0);

  emitNamespaces();

  // compose the initializer function using a template
  Template initializer(getTemplate("JS_initializer"));
  initializer.replace("${modulename}", module)
      .replace("${initializercode}", state.global(INITIALIZER))
      .replace("${create_namespaces}", state.global(CREATE_NAMESPACES))
      .replace("${register_namespaces}", state.global(REGISTER_NAMESPACES))
      .pretty_print(f_init);

  Printv(f_wrap_cpp, f_init, 0);

  return SWIG_OK;
}

int JSCEmitter::close() {
  /* strings */
  Delete(f_runtime);
  Delete(f_header);
  Delete(f_wrappers);
  Delete(f_init);

  Delete(namespaces);

  /* files */
  Close(f_wrap_cpp);
  Delete(f_wrap_cpp);

  return SWIG_OK;
}

int JSCEmitter::enterFunction(Node *n) {

  JSEmitter::enterFunction(n);

  /* Initialize DOH for collecting function dispatchers */
  bool is_overloaded = GetFlag(n, "sym:overloaded");
  if (is_overloaded && state.function(FUNCTION_DISPATCHERS) == 0) {
    state.function(FUNCTION_DISPATCHERS, NewString(""));
  }

  return SWIG_OK;
}

int JSCEmitter::exitFunction(Node *n) {
  Template t_function = getTemplate("JS_functiondecl");

  bool is_member = GetFlag(n, "ismember");
  bool is_overloaded = GetFlag(n, "sym:overloaded");

  // handle overloaded functions
  if (is_overloaded) {
    if (!Getattr(n, "sym:nextSibling")) {
      state.function(WRAPPER_NAME, Swig_name_wrapper(Getattr(n, "name")));
      // create dispatcher
      emitFunctionDispatcher(n, is_member);
    } else {
      //don't register wrappers of overloaded functions in function tables
      return SWIG_OK;
    }
  }

  t_function.replace("${functionname}", state.function(NAME))
      .replace("${functionwrapper}", state.function(WRAPPER_NAME));

  if (is_member) {
    if (Equal(Getattr(n, "storage"), "static")) {
      Append(state.clazz(STATIC_FUNCTIONS), t_function.str());
    } else {
      Append(state.clazz(MEMBER_FUNCTIONS), t_function.str());
    }
  } else {
    Append(Getattr(current_namespace, "functions"), t_function.str());
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
  Template t_variable(getTemplate("JS_variabledecl"));
  t_variable.replace("${setname}", state.variable(SETTER))
      .replace("${getname}", state.variable(GETTER))
      .replace("${propertyname}", state.variable(NAME));

  if (GetFlag(n, "ismember")) {
    if (Equal(Getattr(n, "storage"), "static") || (Equal(Getattr(n, "nodeType"), "enumitem"))) {
      Append(state.clazz(STATIC_VARIABLES), t_variable.str());
    } else {
      Append(state.clazz(MEMBER_VARIABLES), t_variable.str());
    }
  } else {
    Append(Getattr(current_namespace, "values"), t_variable.str());
  }

  return SWIG_OK;
}

int JSCEmitter::enterClass(Node *n) {
  JSEmitter::enterClass(n);

  state.clazz(MEMBER_VARIABLES, NewString(""));
  state.clazz(MEMBER_FUNCTIONS, NewString(""));
  state.clazz(STATIC_VARIABLES, NewString(""));
  state.clazz(STATIC_FUNCTIONS, NewString(""));
  state.clazz(CTORS, NewString(""));
  state.clazz(CTOR_DISPATCHERS, NewString(""));

  Template t_class_defn = getTemplate("JS_class_definition");
  t_class_defn.replace("${classname_mangled}", state.clazz(NAME_MANGLED))
      .pretty_print(f_wrappers);

  return SWIG_OK;
}

int JSCEmitter::exitClass(Node *n) {

  Template t_class_tables(getTemplate("JS_class_tables"));
  t_class_tables.replace("${classname_mangled}", state.clazz(NAME_MANGLED))
      .replace("${jsclassvariables}", state.clazz(MEMBER_VARIABLES))
      .replace("${jsclassfunctions}", state.clazz(MEMBER_FUNCTIONS))
      .replace("${jsstaticclassfunctions}", state.clazz(STATIC_FUNCTIONS))
      .replace("${jsstaticclassvariables}", state.clazz(STATIC_VARIABLES))
      .pretty_print(f_wrappers);

  /* adds the ctor wrappers at this position */
  // Note: this is necessary to avoid extra forward declarations.
  Append(f_wrappers, state.clazz(CTORS));

  /* adds the main constructor wrapper function */
  Template t_mainctor(getTemplate("JS_mainctordefn"));
  t_mainctor.replace("${classname_mangled}", state.clazz(NAME_MANGLED))
      .replace("${DISPATCH_CASES}", state.clazz(CTOR_DISPATCHERS))
      .pretty_print(f_wrappers);

  /* adds a class template statement to initializer function */
  Template t_classtemplate(getTemplate("JS_create_class_template"));

  /* prepare registration of base class */
  String *base_name_mangled = NewString("_SwigObject");
  Node *base_class = getBaseClass(n);
  if (base_class != NULL) {
    Delete(base_name_mangled);
    base_name_mangled = SwigType_manglestr(Getattr(base_class, "name"));
  }
  t_classtemplate.replace("${classname_mangled}", state.clazz(NAME_MANGLED))
      .replace("${classtype_mangled}", state.clazz(TYPE_MANGLED))
      .replace("${base_classname}", base_name_mangled)
      .pretty_print(state.global(INITIALIZER));
  Delete(base_name_mangled);

  /* Note: this makes sure that there is a swig_type added for this class */
  SwigType_remember_clientdata(state.clazz(TYPE_MANGLED), NewString("0"));

  /* adds a class registration statement to initializer function */
  Template t_registerclass(getTemplate("JS_register_class"));
  t_registerclass.replace("${classname}", state.clazz(NAME))
      .replace("${classname_mangled}", state.clazz(NAME_MANGLED))
      .replace("${namespace_mangled}", Getattr(current_namespace, "name_mangled"))
      .pretty_print(state.global(INITIALIZER));

  return SWIG_OK;
}

int JSCEmitter::emitCtor(Node *n) {
  
  Wrapper *wrapper = NewWrapper();

  Template t_ctor(getTemplate("JS_ctordefn"));
  String *mangled_name = SwigType_manglestr(Getattr(n, "name"));

  String *overname = Getattr(n, "sym:overname");
  String *wrap_name = Swig_name_wrapper(Getattr(n, "wrap:name"));
  Setattr(n, "wrap:name", wrap_name);

  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, wrapper);
  emit_attach_parmmaps(params, wrapper);

  Printf(wrapper->locals, "%sresult;", SwigType_str(Getattr(n, "type"), 0));

  int num_args = emit_num_arguments(params);
  String *action = emit_action(n);
  marshalInputArgs(n, params, wrapper, Ctor, true);

  Printv(wrapper->code, action, "\n", 0);
  t_ctor.replace("${classname_mangled}", mangled_name)
      .replace("${overloadext}", overname)
      .replace("${LOCALS}", wrapper->locals)
      .replace("${CODE}", wrapper->code)
      .replace("${type_mangled}", state.clazz(TYPE_MANGLED))
      .pretty_print(state.clazz(CTORS));

  String *argcount = NewString("");
  Printf(argcount, "%d", num_args);
  Template t_ctor_case(getTemplate("JS_ctor_dispatch_case"));
  t_ctor_case.replace("${classname_mangled}", mangled_name)
      .replace("${overloadext}", overname)
      .replace("${argcount}", argcount);
  Append(state.clazz(CTOR_DISPATCHERS), t_ctor_case.str());
  Delete(argcount);
  
  DelWrapper(wrapper);

  return SWIG_OK;
}

int JSCEmitter::emitDtor(Node *) {

  Template t_dtor = getTemplate("JS_destructordefn");
  t_dtor.replace("${classname_mangled}", state.clazz(NAME_MANGLED))
      .replace("${type}", state.clazz(TYPE))
      .pretty_print(f_wrappers);

  return SWIG_OK;
}

int JSCEmitter::emitGetter(Node *n, bool is_member) {
  Wrapper *wrapper = NewWrapper();
  
  Template t_getter(getTemplate("JS_getproperty"));
  bool is_static = Equal(Getattr(n, "storage"), "static");

  String *wrap_name = Swig_name_wrapper(Getattr(n, "wrap:name"));
  Setattr(n, "wrap:name", wrap_name);
  state.variable(GETTER, wrap_name);

  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, wrapper);
  emit_attach_parmmaps(params, wrapper);
  Wrapper_add_local(wrapper, "jsresult", "JSValueRef jsresult");

  String *action = emit_action(n);
  marshalInputArgs(n, params, wrapper, Getter, is_member, is_static);
  marshalOutput(n, action, wrapper);

  t_getter.replace("${getname}", wrap_name)
      .replace("${LOCALS}", wrapper->locals)
      .replace("${CODE}", wrapper->code)
      .pretty_print(f_wrappers);

  DelWrapper(wrapper);

  return SWIG_OK;
}

int JSCEmitter::emitSetter(Node *n, bool is_member) {

  // skip variables that are immutable
  if (State::IsSet(state.variable(IS_IMMUTABLE))) {
    return SWIG_OK;
  }
  
  Wrapper *wrapper = NewWrapper();

  Template t_setter(getTemplate("JS_setproperty"));
  bool is_static = Equal(Getattr(n, "storage"), "static");

  String *wrap_name = Swig_name_wrapper(Getattr(n, "wrap:name"));
  Setattr(n, "wrap:name", wrap_name);
  state.variable(SETTER, wrap_name);

  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, wrapper);
  emit_attach_parmmaps(params, wrapper);

  String *action = emit_action(n);
  marshalInputArgs(n, params, wrapper, Setter, is_member, is_static);
  Append(wrapper->code, action);

  t_setter.replace("${setname}", wrap_name)
      .replace("${LOCALS}", wrapper->locals)
      .replace("${CODE}", wrapper->code)
      .pretty_print(f_wrappers);

  DelWrapper(wrapper);

  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * JSCEmitter::emitConstant() :  triggers code generation for constants
 * ----------------------------------------------------------------------------- */

int JSCEmitter::emitConstant(Node *n) {

  Wrapper *wrapper = NewWrapper();

  Template t_getter(getTemplate("JS_getproperty"));

  // call the variable methods as a constants are
  // registred in same way
  enterVariable(n);

  // prepare function wrapper name
  String *wrap_name = Swig_name_wrapper(Getattr(n, "name"));
  state.variable(GETTER, wrap_name);
  Setattr(n, "wrap:name", wrap_name);

  // prepare local variables
  Wrapper_add_local(wrapper, "jsresult", "JSValueRef jsresult");

  // prepare action
  String *action = NewString("");
  String *value = Getattr(n, "rawval");
  if (value == NULL) {
    value = Getattr(n, "rawvalue");
  }
  if (value == NULL) {
    value = Getattr(n, "value");
  }
  Printf(action, "result = %s;\n", value);
  Setattr(n, "wrap:action", action);

  marshalOutput(n, action, wrapper);

  t_getter.replace("${getname}", wrap_name)
      .replace("${LOCALS}", wrapper->locals)
      .replace("${CODE}", wrapper->code)
      .pretty_print(f_wrappers);

  exitVariable(n);

  DelWrapper(wrapper);

  return SWIG_OK;
}

int JSCEmitter::emitFunction(Node *n, bool is_member) {
  
  Wrapper *wrapper = NewWrapper();
  
  Template t_function(getTemplate("JS_functionwrapper"));

  // Note: there is an inconsistency in SWIG with static member functions
  //       that do not have storage:static
  //       in these cases the context (staticmemberfunctionHandler) is
  //       exploited and a flag is set temporarily
  //       TODO: this could be done in general with is_member and is_static
  bool is_static = State::IsSet(state.function(IS_STATIC)) || Equal(Getattr(n, "storage"), "static");
  bool is_overloaded = GetFlag(n, "sym:overloaded");

  // prepare the function wrapper name
  String *wrap_name = Swig_name_wrapper(Getattr(n, "sym:name"));
  if (is_overloaded) {
    Append(wrap_name, Getattr(n, "sym:overname"));
  }
  Setattr(n, "wrap:name", wrap_name);
  state.function(WRAPPER_NAME, wrap_name);

  // prepare local variables
  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, wrapper);
  emit_attach_parmmaps(params, wrapper);
  Wrapper_add_local(wrapper, "jsresult", "JSValueRef jsresult");

  // prepare code part
  String *action = emit_action(n);
  marshalInputArgs(n, params, wrapper, Function, is_member, is_static);
  marshalOutput(n, action, wrapper);

  t_function.replace("${functionname}", wrap_name)
      .replace("${LOCALS}", wrapper->locals)
      .replace("${CODE}", wrapper->code)
      .pretty_print(f_wrappers);

  // handle function overloading
  if (is_overloaded) {
    Template t_dispatch_case = getTemplate("JS_function_dispatch_case");

    int argc = emit_num_arguments(params);
    String *argcount = NewString("");
    Printf(argcount, "%d", argc);

    t_dispatch_case.replace("${functionwrapper}", wrap_name)
        .replace("${argcount}", argcount);

    Append(state.function(FUNCTION_DISPATCHERS), t_dispatch_case.str());

    Delete(argcount);
  }
  
  DelWrapper(wrapper);

  return SWIG_OK;
}

int JSCEmitter::emitFunctionDispatcher(Node *n, bool /*is_member */ ) {

  Template t_function(getTemplate("JS_functionwrapper"));

  Wrapper *wrapper = NewWrapper();
  String *wrap_name = Swig_name_wrapper(Getattr(n, "name"));
  Setattr(n, "wrap:name", wrap_name);

  Wrapper_add_local(wrapper, "jsresult", "JSValueRef jsresult");

  Append(wrapper->code, state.function(FUNCTION_DISPATCHERS));
  Append(wrapper->code, getTemplate("JS_function_dispatch_case_default").str());

  t_function.replace("${functionname}", wrap_name)
      .replace("${LOCALS}", wrapper->locals)
      .replace("${CODE}", wrapper->code)
      .pretty_print(f_wrappers);

  DelWrapper(wrapper);

  return SWIG_OK;
}

int JSCEmitter::switchNamespace(Node *n) {
  
  if (!GetFlag(n, "feature:nspace")) {
    current_namespace = Getattr(namespaces, "::");
  } else {
    String *scope = Swig_scopename_prefix(Getattr(n, "name"));
    if (scope) {
      // if the scope is not yet registered
      // create all scopes/namespaces recursively
      if (!Getattr(namespaces, scope)) {
        createNamespace(scope);
      }
      current_namespace = Getattr(namespaces, scope);
    } else {
      current_namespace = Getattr(namespaces, "::");
    }
  }

  return SWIG_OK;
}

int JSCEmitter::createNamespace(String *scope) {

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

  Hash *new_namespace = createNamespaceEntry(Char(scope), Char(Getattr(parent_namespace, "name")));
  Setattr(namespaces, scope, new_namespace);

  Delete(parent_scope);
  return SWIG_OK;
}

Hash *JSCEmitter::createNamespaceEntry(const char *name, const char *parent) {
  Hash *entry = NewHash();
  String *_name = NewString(name);
  Setattr(entry, "name", Swig_scopename_last(_name));
  Setattr(entry, "name_mangled", Swig_name_mangle(_name));
  Setattr(entry, "parent", NewString(parent));
  Setattr(entry, "functions", NewString(""));
  Setattr(entry, "values", NewString(""));
  
  Delete(_name);
  return entry;
}

int JSCEmitter::emitNamespaces() {
  Iterator it;
  for (it = First(namespaces); it.item; it = Next(it)) {
    Hash *entry = it.item;
    String *name = Getattr(entry, "name");
    String *parent = Getattr(entry, "parent");
    String *functions = Getattr(entry, "functions");
    String *variables = Getattr(entry, "values");
    String *name_mangled = Getattr(entry, "name_mangled");
    String *parent_mangled = Swig_name_mangle(parent);

    Template namespace_definition(getTemplate("JS_globaldefn"));
    namespace_definition.replace("${jsglobalvariables}", variables)
        .replace("${jsglobalfunctions}", functions)
        .replace("${namespace}", name_mangled)
        .pretty_print(f_wrap_cpp);

    Template t_createNamespace(getTemplate("JS_create_namespace"));
    t_createNamespace.replace("${namespace}", name_mangled);
    Append(state.global(CREATE_NAMESPACES), t_createNamespace.str());

    Template t_registerNamespace(getTemplate("JS_register_namespace"));
    t_registerNamespace.replace("${namespace_mangled}", name_mangled)
        .replace("${namespace}", name)
        .replace("${parent_namespace}", parent_mangled);
    Append(state.global(REGISTER_NAMESPACES), t_registerNamespace.str());
  }

  return SWIG_OK;
}

JSEmitter *swig_javascript_create_JSCEmitter() {
  return new JSCEmitter();
}

/*
class V8Emitter: public JSEmitter {
    
public:

    V8Emitter();

    virtual ~V8Emitter();
    
    virtual int Initialize(Node *n);

    virtual int Dump(Node *n);
    
    virtual int Close();

    virtual int SwitchContext(Node *n);
    
    virtual int EnterClass(Node *n);
    
    virtual int ExitClass(Node *n);

    virtual int EnterVariable(Node *n);

    virtual int ExitVariable(Node *n);

    virtual int EnterFunction(Node *n);

    virtual int ExitFunction(Node *n);
    
protected:

    int CreateNamespace(String* scope);

    virtual int EmitCtor(Node *n);
    
    virtual int EmitDtor(Node *n);

    virtual int EmitFunction(Node *n, bool is_member);

    virtual int EmitGetter(Node *n, bool is_member);

    virtual int EmitSetter(Node *n, bool is_member);

    void marshalInputArgs(Node *n, ParmList *parms, int numarg, Wrapper *wrapper);
    
    void marshalOutput(Node *n, String *actioncode, Wrapper *wrapper);  

    Parm *skipIgnoredArgs(Parm *p);

private:

    File *f_runtime;
    File *f_header;
    File *f_class_templates;
    File *f_wrapper;
    
    File *f_init_namespaces;
    File *f_init_class_templates;
    File *f_init_wrappers;
    File *f_init_inheritance;
    File *f_init_class_instances;
    File *f_init_static_wrappers;
    File *f_init_register_classes;
    File *f_init_register_namespaces;
    
    // the output cpp file
    File *f_wrap_cpp;

    // state variables
    String* current_context;
    String* current_class_type;
    String* current_classname_mangled;
    String* current_classname_unqualified;
    String* current_variable_mangled;
    String* current_variable_unqualified;
    String* current_getter;
    String* current_setter;
    String* current_function_mangled;
    String* current_function_unqualified;
        
    String* GLOBAL;
    String* NULL_STR;
    Hash* namespaces;
};
*/

/*
// name of templates
#define V8_INITIALIZER                              "v8_initializer"
#define V8_DECL_CLASSTEMPLATE                       "v8_declare_class_template"
#define V8_DEFINE_CLASSTEMPLATE                     "v8_define_class_template"
#define V8_CREATE_CLASS_INSTANCE                    "v8_create_class_instance"
#define V8_INHERIT                                  "v8_inherit"
#define V8_REGISTER_CLASS                           "v8_register_class"
#define V8_CTOR_WRAPPER                             "v8_ctor_wrapper"
#define V8_GETTER                                   "v8_getter"
#define V8_SETTER                                   "v8_setter"
#define V8_FUNCTION                                 "v8_function"
#define V8_RETRIEVE_THIS                            "v8_retrieve_this"
#define V8_REGISTER_MEMBER_FUNCTION                 "v8_register_member_function"
#define V8_REGISTER_GLOBAL_FUNCTION                 "v8_register_global_function"
#define V8_REGISTER_MEMBER_VARIABLE                 "v8_register_member_variable"
#define V8_REGISTER_GLOBAL_VARIABLE                 "v8_register_global_variable"
#define V8_CREATE_NAMESPACE                         "v8_create_namespace"
#define V8_REGISTER_NAMESPACE                       "v8_register_namespace"
#define V8_THIS_PTR                                 "v8_this_ptr"

// keywords used in templates
#define KW_MODULE_NAME                              "${MODULE}"
#define KW_MANGLED_NAME                             "${NAME_MANGLED}"
#define KW_UNQUALIFIED_NAME                         "${NAME_UNQUALIFIED}"
#define KW_CLASSNAME_MANGLED                        "${CLASSNAME_MANGLED}"
#define KW_BASE_CLASS                               "${BASE_CLASS}"
#define KW_CONTEXT                                  "${CONTEXT}"
#define KW_TYPE                                     "${TYPE}"
#define KW_ARG                                      "${ARG}"
#define KW_WRAPPER                                  "${WRAPPER}"
#define KW_GETTER                                   "${GETTER}"
#define KW_SETTER                                   "${SETTER}"

#define KW_NAME_SPACES                              "${PART_NAMESPACES}"
#define KW_CLASS_TEMPLATES                          "${PART_CLASS_TEMPLATES}"
#define KW_WRAPPERS                                 "${PART_WRAPPERS}"
#define KW_INHERITANCE                              "${PART_INHERITANCE}"
#define KW_CLASS_INSTANCES                          "${PART_CLASS_INSTANCES}"
#define KW_STATIC_WRAPPERS                          "${PART_STATIC_WRAPPERS}"
#define KW_REGISTER_CLASSES                         "${PART_REGISTER_CLASSES}"
#define KW_REGISTER_NS                              "${PART_REGISTER_NS}"

#define KW_LOCALS                                   "${LOCALS}"
#define KW_CODE                                     "${CODE}"
#define KW_MARSHAL_INPUT                            "${MARSHAL_INPUT}"
#define KW_ACTION                                   "${ACTION}"
#define KW_MARSHAL_OUTPUT                           "${MARSHAL_OUTPUT}"

V8Emitter::V8Emitter() 
    : JSEmitter(), 
      GLOBAL(NewString("global")),
      NULL_STR(NewString("0")),
      namespaces(NewHash())
{
}

V8Emitter::~V8Emitter()
{
    Delete(GLOBAL);
    Delete(NULL_STR);
    Delete(namespaces);
}

int V8Emitter::initialize(Node *n)
{
 
    // Get the output file name
    String *outfile = Getattr(n,"outfile");
    f_wrap_cpp = NewFile(outfile, "w", SWIG_output_files());
    if (!f_wrap_cpp) {
       FileErrorDisplay(outfile);
       SWIG_exit(EXIT_FAILURE);
    }

    f_runtime = NewString("");
    f_header = NewString("");
    f_class_templates = NewString("");
    f_wrapper = NewString("");
        
    f_init_namespaces = NewString("");
    f_init_class_templates = NewString("");
    f_init_wrappers = NewString("");
    f_init_inheritance = NewString("");
    f_init_class_instances = NewString("");
    f_init_static_wrappers = NewString("");
    f_init_register_classes = NewString("");
    f_init_register_namespaces = NewString("");

    // note: this is necessary for built-in generation of swig runtime code
    Swig_register_filebyname("runtime", f_runtime);

    return SWIG_OK;
}

int V8Emitter::dump(Node *n)
{
     // Get the module name
    String* module = Getattr(n,"name");

   // write the swig banner
    Swig_banner(f_wrap_cpp);

    Printv(f_wrap_cpp, f_runtime, "\n", 0);
    Printv(f_wrap_cpp, f_header, "\n", 0);
    Printv(f_wrap_cpp, f_class_templates, "\n", 0);
    Printv(f_wrap_cpp, f_wrapper, "\n", 0);

    // compose the initializer function using a template
    // filled with sub-parts
    Template initializer(GetTemplate(V8_INITIALIZER));
    initializer.Replace(KW_MODULE_NAME,       module)
               .Replace(KW_NAME_SPACES,       f_init_namespaces)
               .Replace(KW_CLASS_TEMPLATES,   f_init_class_templates)
               .Replace(KW_WRAPPERS,          f_init_wrappers)
               .Replace(KW_INHERITANCE,       f_init_inheritance)
               .Replace(KW_CLASS_INSTANCES,   f_init_class_instances)
               .Replace(KW_STATIC_WRAPPERS,   f_init_static_wrappers)
               .Replace(KW_REGISTER_CLASSES,  f_init_register_classes)
               .Replace(KW_REGISTER_NS,       f_init_register_namespaces);
    Wrapper_pretty_print(initializer.str(), f_wrap_cpp);

    return SWIG_OK;
}

int V8Emitter::close()
{
    // strings
    Delete(f_runtime);
    Delete(f_header);
    Delete(f_class_templates);
    Delete(f_wrapper);
    Delete(f_init_namespaces);
    Delete(f_init_class_templates);
    Delete(f_init_wrappers);
    Delete(f_init_inheritance);
    Delete(f_init_class_instances);
    Delete(f_init_static_wrappers);
    Delete(f_init_register_classes);
    Delete(f_init_register_namespaces);    
    
    // files
    Close(f_wrap_cpp);
    Delete(f_wrap_cpp);
    
    return SWIG_OK;
}

int V8Emitter::SwitchContext(Node *n)
{
    String* scope = Swig_scopename_prefix(Getattr(n, "name"));
    
    if (scope) {
        // if the scope is not yet registered
        // create all scopes/namespaces recursively
        if(!Getattr(namespaces, scope)) {
            CreateNamespace(scope);
        }
        current_context = Getattr(namespaces, scope);
    } else {
        current_context = GLOBAL;
    }
        
    return SWIG_OK;
}

int V8Emitter::CreateNamespace(String* scope) {
    String* parent_scope = Swig_scopename_prefix(scope);
    String* parent_scope_mangled = 0;

    if(!parent_scope) {
        parent_scope_mangled = NewString("global");
    } else {
        parent_scope_mangled = Swig_name_mangle(parent_scope);

    }
    
    if (parent_scope && !Getattr(namespaces, parent_scope)) {
        CreateNamespace(parent_scope);
    }
    
    String* scope_mangled = Swig_string_mangle(scope);
    String* scope_unqualified = Swig_scopename_last(scope);
    Setattr(namespaces, scope, scope_mangled);
    
    // create namespace object and register it to the parent scope
    Template t_create_ns(GetTemplate(V8_CREATE_NAMESPACE));
    t_create_ns.Replace(KW_MANGLED_NAME, scope_mangled);
    
    Template t_register_ns(GetTemplate(V8_REGISTER_NAMESPACE));
    t_register_ns.Replace(KW_MANGLED_NAME, scope_mangled)
        .Replace(KW_CONTEXT, parent_scope_mangled)
        .Replace(KW_UNQUALIFIED_NAME, scope_unqualified);

    Printv(f_init_namespaces, t_create_ns.str(), 0);
    // prepend in order to achieve reversed order of registration statements
    Insert(f_init_register_namespaces, 0, t_register_ns.str());

    Delete(parent_scope);
    Delete(parent_scope_mangled);
    Delete(scope_unqualified);
    return SWIG_OK;
}

int V8Emitter::EnterClass(Node *n)
{
    current_classname_mangled = Swig_string_mangle(Getattr(n, "name"));
    current_classname_unqualified = Swig_scopename_last(Getattr(n, "name"));
    current_class_type = Getattr(n, "classtype");
    
    // emit declaration of a v8 class template
    Template t_decl_class(GetTemplate(V8_DECL_CLASSTEMPLATE));
    t_decl_class.Replace(KW_MANGLED_NAME, current_classname_mangled);
    Printv(f_class_templates, t_decl_class.str(), 0);

    // emit definition of v8 class template
    Template t_def_class(GetTemplate(V8_DEFINE_CLASSTEMPLATE));
    t_def_class.Replace(KW_MANGLED_NAME, current_classname_mangled)
        .Replace(KW_UNQUALIFIED_NAME, current_classname_unqualified);
    Printv(f_init_class_templates, t_def_class.str(), 0);
    
    Template t_class_instance(GetTemplate(V8_CREATE_CLASS_INSTANCE));
    t_class_instance.Replace(KW_MANGLED_NAME, current_classname_mangled);
    Printv(f_init_class_instances, t_class_instance.str(), 0);

    return SWIG_OK;
}

int V8Emitter::ExitClass(Node *n)
{
    //  emit inheritance setup
    Node* baseClass = GetBaseClass(n);
    if(baseClass) {
        Template t_inherit(GetTemplate(V8_INHERIT));
        t_inherit.Replace(KW_MANGLED_NAME,  current_classname_mangled)
         .Replace(KW_BASE_CLASS,    Swig_string_mangle(Getattr(baseClass, "name")));
        Printv(f_init_inheritance, t_inherit.str(), 0);
    }
        
    //  emit registeration of class template
    Template t_register(GetTemplate(V8_REGISTER_CLASS));
    t_register.Replace(KW_MANGLED_NAME,      current_classname_mangled)
     .Replace(KW_UNQUALIFIED_NAME,  current_classname_unqualified)
     .Replace(KW_CONTEXT,           Swig_string_mangle(current_context));
    Printv(f_init_register_classes, t_register.str(), 0);

    Delete(current_classname_mangled);
    Delete(current_classname_unqualified);
    current_classname_mangled = 0;
    current_classname_unqualified = 0;
    current_class_type = 0;
    
    return SWIG_OK;
}

int V8Emitter::EnterVariable(Node* n)
{
    current_variable_unqualified = Swig_scopename_last(Getattr(n, "name"));
    if(GetFlag(n, "ismember")) {
        current_variable_mangled = NewString("");
        Printf(current_variable_mangled, "%s_%s", current_classname_mangled, current_variable_unqualified);
    } else {
        current_variable_mangled = Swig_string_mangle(Getattr(n, "name"));
    }
    
    current_getter = NULL_STR;
    current_setter = NULL_STR;
    
    return SWIG_OK;
}

int V8Emitter::ExitVariable(Node* n)
{
    if(GetFlag(n, "ismember")) {
        if(Equal(Getattr(n, "storage"), "static")) {
            Template t_register(GetTemplate(V8_REGISTER_GLOBAL_VARIABLE));
            String *class_instance = NewString("");
            Printf(class_instance, "class_%s", current_classname_mangled);
            t_register.Replace(KW_CONTEXT, class_instance)
                .Replace(KW_UNQUALIFIED_NAME, current_variable_unqualified)
                .Replace(KW_GETTER, current_getter)
                .Replace(KW_SETTER, current_setter);
            Printv(f_init_static_wrappers, t_register.str(), 0);
            Delete(class_instance);
        } else {
            Template t_register(GetTemplate(V8_REGISTER_MEMBER_VARIABLE));
            t_register.Replace(KW_CLASSNAME_MANGLED, current_classname_mangled)
                .Replace(KW_UNQUALIFIED_NAME, current_variable_unqualified)
                .Replace(KW_GETTER, current_getter)
                .Replace(KW_SETTER, current_setter);
            Printv(f_init_wrappers, t_register.str(), 0);
        }
    } else {
        Template t_register(GetTemplate(V8_REGISTER_GLOBAL_VARIABLE));
        t_register.Replace(KW_CONTEXT, current_context)
            .Replace(KW_UNQUALIFIED_NAME, current_variable_unqualified)
            .Replace(KW_GETTER, current_getter)
            .Replace(KW_SETTER, current_setter);
        Printv(f_init_wrappers, t_register.str(), 0);
    }
    
    Delete(current_variable_mangled);
    Delete(current_variable_unqualified);
    current_variable_mangled = 0;
    current_variable_unqualified = 0;
    
    return SWIG_OK;
}

int V8Emitter::EnterFunction(Node* n)
{
    current_function_unqualified = Swig_scopename_last(Getattr(n, "name"));
    if(GetFlag(n, "ismember")) {
        current_function_mangled = NewString("");
        Printf(current_function_mangled, "%s_%s", current_classname_mangled, current_function_unqualified);
    } else {
        current_function_mangled = Swig_string_mangle(Getattr(n, "name"));
    }
        
    return SWIG_OK;
}

int V8Emitter::ExitFunction(Node* n)
{    
    // register the function at the specific context
    if(GetFlag(n, "ismember")) {
        if(Equal(Getattr(n, "storage"), "static")) {
            Template t_register(GetTemplate(V8_REGISTER_GLOBAL_FUNCTION));
            String *class_instance = NewString("");
            Printf(class_instance, "class_%s", current_classname_mangled);
            t_register.Replace(KW_CONTEXT, class_instance)
                .Replace(KW_UNQUALIFIED_NAME, current_function_unqualified)
                .Replace(KW_MANGLED_NAME, Getattr(n, "wrap:name"));
            Printv(f_init_static_wrappers, t_register.str(), 0);
            Delete(class_instance);
        } else {
            Template t_register(GetTemplate(V8_REGISTER_MEMBER_FUNCTION));
            t_register.Replace(KW_CLASSNAME_MANGLED, current_classname_mangled)
            .Replace(KW_UNQUALIFIED_NAME, current_function_unqualified)
            .Replace(KW_MANGLED_NAME, Getattr(n, "wrap:name"));
            Printv(f_init_wrappers, t_register.str(), "\n", 0);
        }
    } else {
        Template t_register(GetTemplate(V8_REGISTER_GLOBAL_FUNCTION));
        t_register.Replace(KW_CONTEXT, current_context)
            .Replace(KW_UNQUALIFIED_NAME, current_function_unqualified)
            .Replace(KW_MANGLED_NAME, Getattr(n, "wrap:name"));
        Printv(f_init_wrappers, t_register.str(), 0);
    }
    
    
    Delete(current_function_mangled);
    Delete(current_function_unqualified);
    current_function_mangled = 0;
    current_function_unqualified = 0;
    
    return SWIG_OK;
}

int V8Emitter::EmitCtor(Node* n)
{
    // TODO: handle overloaded ctors using a dispatcher
    Template t(GetTemplate(V8_CTOR_WRAPPER));
        
    //HACK: manually add declaration of instance pointer
    Printf(wrapper->locals, "%sresult;", SwigType_str(Getattr(n, "type"),0));
    
    String* action = emit_action(n);
    Printv(wrapper->code, action, 0);

    t.Replace(KW_MANGLED_NAME,      current_classname_mangled)
     .Replace(KW_UNQUALIFIED_NAME,  current_classname_unqualified)
     .Replace(KW_LOCALS, wrapper->locals)
     .Replace(KW_CODE, wrapper->code);
     
    Wrapper_pretty_print(t.str(), f_wrapper);
    
    return SWIG_OK;
}

int V8Emitter::EmitDtor(Node* n)
{
    // TODO:
    //  find out how to register a dtor in v8
    return SWIG_OK;
}

int V8Emitter::EmitGetter(Node *n, bool is_member) {
    Template t_getter(GetTemplate(V8_GETTER));

    current_getter = Getattr(n,"wrap:name");

    ParmList *params  = Getattr(n,"parms");
    emit_parameter_variables(params, wrapper);
    emit_attach_parmmaps(params, wrapper);

    int num_args = emit_num_arguments(params);
    String* action = emit_action(n);
    marshalInputArgs(n, params, num_args, wrapper);
    marshalOutput(n, action, wrapper);
    
    t_getter.Replace(KW_MANGLED_NAME, current_variable_mangled)
     .Replace(KW_LOCALS, wrapper->locals)
     .Replace(KW_CODE, wrapper->code);

    Wrapper_pretty_print(t_getter.str(), f_wrapper);
        
    return SWIG_OK;
}

int V8Emitter::EmitSetter(Node* n, bool is_member)
{
    Template t_setter(GetTemplate(V8_SETTER));

    current_setter = Getattr(n,"wrap:name");
    
    ParmList *params  = Getattr(n,"parms");
    emit_parameter_variables(params, wrapper);
    emit_attach_parmmaps(params, wrapper);

    int num_args = emit_num_arguments(params);
    String* action = emit_action(n);
    marshalInputArgs(n, params, num_args, wrapper);
    Printv(wrapper->code, action, 0);
    
    t_setter.Replace(KW_MANGLED_NAME, current_variable_mangled)
     .Replace(KW_LOCALS, wrapper->locals)
     .Replace(KW_CODE, wrapper->code);

    Wrapper_pretty_print(t_setter.str(), f_wrapper);

    return SWIG_OK;
}


int V8Emitter::EmitFunction(Node* n, bool is_member)
{
    Template t_function(GetTemplate(V8_FUNCTION));

    String* wrap_name = NewString("");
    Printv(wrap_name, current_function_mangled, 0);
    Setattr(n, "wrap:name", wrap_name);
    
    ParmList *params  = Getattr(n,"parms");
    emit_parameter_variables(params, wrapper);
    emit_attach_parmmaps(params, wrapper);
       
    int num_args = emit_num_arguments(params);
    String* action = emit_action(n);
    marshalInputArgs(n, params, num_args, wrapper);
    marshalOutput(n, action, wrapper);
    
    t_function.Replace(KW_MANGLED_NAME, current_function_mangled)
     .Replace(KW_LOCALS, wrapper->locals)
     .Replace(KW_CODE, wrapper->code);
    Wrapper_pretty_print(t_function.str(), f_wrapper);

    return SWIG_OK;
}

void V8Emitter::marshalInputArgs(Node *n, ParmList *parms, int numarg, Wrapper *wrapper) {
    String *tm;
    Parm *p;
    
    bool is_member = (current_class_type != 0);
    bool is_setter = IsSetterMethod(n);
    bool is_function = (current_function_mangled != 0);

    int start_idx;
    if(is_member) {
        start_idx = 1;
    } else {
        start_idx = 0;
    }
    
    // retrieve this pointer for member functions
    if(is_member) {
        
        Template t_selfptr(GetTemplate(V8_THIS_PTR));
        String *type_str = SwigType_strip_qualifiers(SwigType_str(current_class_type,0));
        String *arg_str;
        if(is_function) {
            arg_str = NewString("args");
        } else {
            arg_str = NewString("info");
        }
        
        t_selfptr.Replace(KW_TYPE, type_str)
            .Replace(KW_ARG, arg_str);
        Printv(wrapper->code, t_selfptr.str(), 0);
        
        Delete(type_str);
        Delete(arg_str);        
    }
    
    int i = 0;
    for (i = 0, p = parms; i < numarg; i++)
    {
        p = skipIgnoredArgs(p);
        SwigType *pt = Getattr(p, "type");

        String *arg = NewString("");
        if (i == 0) {
            if(start_idx == 0) {
                Printv(arg, is_setter?"value":"args[0]", 0);
            } else {
                p = Getattr(p, "tmap:in:next");
                Delete(arg);    
                continue;       // special case: skip the typemaps for the first argument
            }
        } else {
            Printf(arg, is_setter?"value":"args[%d]", i - start_idx);
        }

        if ((tm = Getattr(p, "tmap:in")))  // Get typemap for this argument
        {
            Replaceall(tm, "$input", arg);
            Setattr(p, "emit:input", arg);
            Printf(wrapper->code, "%s\n", tm);
            p = Getattr(p, "tmap:in:next");
        } else {
            Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
            p = nextSibling(p);
        }
      Delete(arg);
    } 
}

void V8Emitter::marshalOutput(Node *n, String *actioncode, Wrapper *wrapper) {
    SwigType *type = Getattr(n, "type");
    Setattr(n, "type", type);
    String *tm;
    if ((tm = Swig_typemap_lookup_out("out", n, "result", wrapper, actioncode))) 
    {
        Replaceall(tm, "$result", "jsresult");
        // TODO: May not be the correct way
        Replaceall(tm, "$objecttype", Swig_scopename_last(SwigType_str(SwigType_strip_qualifiers(type), 0)));
        Printf(wrapper->code, "%s", tm);
        if (Len(tm))
          Printf(wrapper->code, "\n");
      } else {
        Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(type, 0), Getattr(n, "name"));
      }
      emit_return_variable(n, type, wrapper);
}

*/
JSEmitter *swig_javascript_create_V8Emitter() {
  return 0;
}


/**********************************************************************
 * Helper implementations
 **********************************************************************/

JSEmitterState::JSEmitterState() 
  : _global(NewHash()) 
{
  // initialize sub-hashes
  Setattr(_global, "class", NewHash());
  Setattr(_global, "function", NewHash());
  Setattr(_global, "variable", NewHash());
}

JSEmitterState::~JSEmitterState() 
{ 
  Delete(_global);
}
  
DOH *JSEmitterState::getState(const char* key, bool _new) 
{
  if (_new) {
    Hash *hash = NewHash();
    Setattr(_global, key, hash);
  }
  return Getattr(_global, key);
}
  
DOH *JSEmitterState::global() {
  return _global;
}

DOH *JSEmitterState::global(const char* key, DOH *initial)
{
  if(initial != 0) {
    Setattr(_global, key, initial);
  }
  return Getattr(_global, key);
}

DOH *JSEmitterState::clazz(bool _new)
{
  return getState("class", _new);
}
  
DOH *JSEmitterState::clazz(const char* key, DOH *initial)
{
  DOH *c = clazz();
  if(initial != 0) {
    Setattr(c, key, initial);
  }
  return Getattr(c, key);
}

DOH *JSEmitterState::function(bool _new)
{
  return getState("function", _new);
}

DOH *JSEmitterState::function(const char* key, DOH *initial)
{
  DOH *f = function();
  if(initial != 0) {
    Setattr(f, key, initial);
  }
  return Getattr(f, key);
}

DOH *JSEmitterState::variable(bool _new)
{
  return getState("variable", _new);
}

DOH *JSEmitterState::variable(const char* key, DOH *initial) 
{
  DOH *v = variable();
  if(initial != 0) {
    Setattr(v, key, initial);
  }
  return Getattr(v, key);
}
  
/*static*/
int JSEmitterState::IsSet(DOH *val) 
{
  if (!val) {
    return 0;
  } else {
    const char *cval = Char(val);
    if (!cval)
      return 0;
    return (strcmp(cval, "0") != 0) ? 1 : 0;
  }
}

/* -----------------------------------------------------------------------------
 * Template::Template() :  creates a Template class for given template code
 * ----------------------------------------------------------------------------- */

Template::Template(const String *code_) {

  if (!code_) {
    Printf(stdout, "Template code was null. Illegal input for template.");
    SWIG_exit(EXIT_FAILURE);
  }
  code = NewString(code_);
  templateName = NewString("");
}

Template::Template(const String *code_, const String *templateName_) {

  if (!code_) {
    Printf(stdout, "Template code was null. Illegal input for template.");
    SWIG_exit(EXIT_FAILURE);
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
    Printf(pre_code, "//begin fragment(\"%s\")\n", templateName);
    Printf(post_code, "//end fragment(\"%s\")\n", templateName);
    Printf(debug_code, "%s\n%s\n%s", pre_code, code, post_code);

    Delete(code);
    Delete(pre_code);
    Delete(post_code);

    code = debug_code;
  }
  return code;
}

/* -----------------------------------------------------------------------------
 * Template&  Template::replace(const String* pattern, const String* repl) :
 * 
 *  replaces all occurences of a given pattern with a given replacement.
 * 
 *  - pattern:  the pattern to be replaced
 *  - repl:     the replacement string
 *  - returns a reference to the Template to allow chaining of methods.
 * ----------------------------------------------------------------------------- */

Template& Template::replace(const String *pattern, const String *repl) {
  Replaceall(code, pattern, repl);
  return *this;
}

Template& Template::pretty_print(DOH *doh) {
  Wrapper_pretty_print(str(), doh);
  return *this;
}

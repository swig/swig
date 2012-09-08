#include "swigmod.h"

#include <cparse.h>
#include <parser.h>
#include <ctype.h>

/**
 *  A class that wraps a code snippet used as template for code generation.
 */
class Template {

public:
  Template(const String *code);

   Template(const String *code, const String *templateName, bool debug = false);

  ~Template();

  String *str();

   Template & replace(const String *pattern, const String *repl);

private:
  String *code;
  String *templateName;
  bool debug;
};

class JSEmitter {

public:

  enum JSEmitterType {
    JavascriptCore,
    V8,
    QtScript
  };

   JSEmitter();

   virtual ~ JSEmitter();

    /**
     * Opens output files and temporary output DOHs.
     */
  virtual int initialize(Node *n) = 0;

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
  virtual int enterClass(Node *) {
    return SWIG_OK;
  };

    /**
     * Invoked at the end of the classHandler.
     */
  virtual int exitClass(Node *) {
    return SWIG_OK;
  };

    /**
     * Invoked at the beginning of the variableHandler.
     */
  virtual int enterVariable(Node *) {
    return SWIG_OK;
  };

    /**
     * Invoked at the end of the variableHandler.
     */
  virtual int exitVariable(Node *) {
    return SWIG_OK;
  };

    /**
     * Invoked at the beginning of the functionHandler.
     */
  virtual int enterFunction(Node *) {
    return SWIG_OK;
  };

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

  void enableDebug();

  void setStaticFlag(bool is_static = false);

protected:

  virtual int emitCtor(Node *n) = 0;

  virtual int emitDtor(Node *n) = 0;

  virtual int emitFunction(Node *n, bool is_member) = 0;

  virtual int emitGetter(Node *n, bool is_member) = 0;

  virtual int emitSetter(Node *n, bool is_member) = 0;

  bool isSetterMethod(Node *n);

  Node *getBaseClass(Node *n);

  const String *typemapLookup(Node *n, const_String_or_char_ptr tmap_method, SwigType *type, int warning, Node *typemap_attributes = 0);

  void enableDebugTemplates();

protected:

  // empty string used at different places in the code
  String *empty_string;

  Hash *templates;

  Wrapper *current_wrapper;

  bool is_static;

  bool debug;
};

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

  void marshalInputArgs(Node *n, ParmList *parms, Wrapper *wrapper, MarshallingMode mode, bool is_member, bool is_static = false);

  void marshalOutput(Node *n, String *actioncode, Wrapper *wrapper);

  Parm *skipIgnoredArgs(Parm *p);

  virtual int switchNamespace(Node *n);

  virtual int createNamespace(String *scope);

  virtual Hash *createNamespaceEntry(const char *name, const char *parent);

  virtual int emitNamespaces();

  virtual int emitConstant(Node *n);

private:

  File *f_wrap_cpp;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;

  String *NULL_STR;
  String *VETO_SET;
  const char *GLOBAL_STR;

  // contains context specific structs
  // to allow generation different class definition tables
  // which are switched on namespace change
  Hash *namespaces;
  Hash *current_namespace;

  // dynamically filled code parts

  String *create_namespaces_code;
  String *register_namespaces_code;

  String *current_class_functions;
  String *class_variables_code;
  String *class_static_functions_code;
  String *class_static_variables_code;

  String *ctor_wrappers;
  String *ctor_dispatcher_code;

  String *initializer_code;
  String *function_dispatcher_code;

  // state variables
  String *current_propertyname;
  String *current_getter;
  String *current_setter;
  bool is_immutable;

  String *current_classname;
  String *current_classname_mangled;
  String *current_classtype;
  String *current_classtype_mangled;
  String *current_functionwrapper;
  String *current_functionname;
};

/* -----------------------------------------------------------------------------
 * JSEmitter()
 * ----------------------------------------------------------------------------- */

JSEmitter::JSEmitter()
:  empty_string(NewString("")), current_wrapper(NULL), is_static(false), debug(false) {
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

  Template t(templ, name, debug);

  return t;
}

void JSEmitter::enableDebug() {
  debug = true;
}

void JSEmitter::setStaticFlag(bool _is_static) {
  is_static = _is_static;
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

  current_wrapper = NewWrapper();
  Setattr(n, "wrap:name", Getattr(n, "sym:name"));

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

  DelWrapper(current_wrapper);
  current_wrapper = 0;

  return ret;
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

/* -----------------------------------------------------------------------------
 * Template::Template() :  creates a Template class for given template code
 * ----------------------------------------------------------------------------- */

Template::Template(const String *code_) {

  if (!code_) {
    Printf(stdout, "Template code was null. Illegal input for template.");
    SWIG_exit(EXIT_FAILURE);
  }
  debug = false;
  code = NewString(code_);
  templateName = NewString("");
}

Template::Template(const String *code_, const String *templateName_, bool debug_) {

  if (!code_) {
    Printf(stdout, "Template code was null. Illegal input for template.");
    SWIG_exit(EXIT_FAILURE);
  }

  code = NewString(code_);
  templateName = NewString(templateName_);
  debug = debug_;
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
  if (debug) {
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
 *  replaces all occurances of a given pattern with a given replacement.
 * 
 *  - pattern:  the pattern to be replaced
 *  - repl:     the replacement string
 *  - returns a reference to the Template to allow chaining of methods.
 * ----------------------------------------------------------------------------- */

Template & Template::replace(const String *pattern, const String *repl) {
  ::Replaceall(code, pattern, repl);
  return *this;
}

JSCEmitter::JSCEmitter()
:  
JSEmitter(), NULL_STR(NewString("NULL")), current_classname(NULL), f_header(NULL), current_classtype(NULL), f_runtime(NULL), current_class_functions(NULL),
f_wrappers(NULL), current_getter(NULL), is_immutable(NULL), create_namespaces_code(NULL), current_classname_mangled(NULL), initializer_code(NULL),
register_namespaces_code(NULL), f_wrap_cpp(NULL), current_setter(NULL), ctor_dispatcher_code(NULL), current_functionwrapper(NULL),
class_static_functions_code(NULL), namespaces(NULL), function_dispatcher_code(NULL), namespaces(NULL), GLOBAL_STR(NULL), current_propertyname(NULL),
current_namespace(NULL), ctor_wrappers(NULL), class_static_variables_code(NULL), class_variables_code(NULL), f_init(NULL), current_functionname(NULL),
current_classtype_mangled(NULL), VETO_SET(NewString("JS_veto_set_variable")) {
}

JSCEmitter::~JSCEmitter() {
  Delete(NULL_STR);
  Delete(VETO_SET);
}

/* ---------------------------------------------------------------------
 * skipIgnoredArgs()
 * --------------------------------------------------------------------- */

Parm *JSCEmitter::skipIgnoredArgs(Parm *p) {
  while (checkAttribute(p, "tmap:in:numinputs", "0")) {
    p = Getattr(p, "tmap:in:next");
  }
  return p;
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
  if (is_member && !is_static)
    startIdx = 1;


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
    // TODO: May not be the correct way
    Replaceall(tm, "$objecttype", Swig_scopename_last(SwigType_str(SwigType_strip_qualifiers(type), 0)));

    if (GetFlag(n, "feature:new")) {
      Replaceall(tm, "$owner", "SWIG_POINTER_OWN");
    } else {
      Replaceall(tm, "$owner", "0");
    }

    Printf(wrapper->code, "%s", tm);
    if (Len(tm))
      Printf(wrapper->code, "\n");
  } else {
    Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(type, 0), Getattr(n, "name"));
  }
  emit_return_variable(n, type, wrapper);
}

int JSCEmitter::initialize(Node *n) {

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

  create_namespaces_code = NewString("");
  register_namespaces_code = NewString("");
  initializer_code = NewString("");

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
      .replace("${initializercode}", initializer_code)
      .replace("${create_namespaces}", create_namespaces_code)
      .replace("${register_namespaces}", register_namespaces_code);
  Wrapper_pretty_print(initializer.str(), f_init);

  Printv(f_wrap_cpp, f_init, "\n", 0);

  return SWIG_OK;
}


int JSCEmitter::close() {
  /* strings */
  Delete(f_runtime);
  Delete(f_header);
  Delete(f_wrappers);
  Delete(f_init);

  Delete(create_namespaces_code);
  Delete(register_namespaces_code);
  Delete(initializer_code);

  Delete(namespaces);

  /* files */
  ::Close(f_wrap_cpp);
  Delete(f_wrap_cpp);

  return SWIG_OK;
}

int JSCEmitter::enterFunction(Node *n) {

  bool is_overloaded = GetFlag(n, "sym:overloaded");

  current_functionname = Getattr(n, "sym:name");

  if (is_overloaded && function_dispatcher_code == 0) {
    function_dispatcher_code = NewString("");
  }

  return SWIG_OK;
}

int JSCEmitter::exitFunction(Node *n) {
  Template t_function = getTemplate("JS_functiondecl");

  String *functionname = current_functionname;
  String *functionwrapper = current_functionwrapper;

  bool is_member = GetFlag(n, "ismember");

  // handle overloaded functions
  // Note: wrappers for overloaded functions are currently
  //       not made available (e.g., foo_double, foo_int)
  //       maybe this could be enabled by an extra feature flag 
  bool is_overloaded = GetFlag(n, "sym:overloaded");

  if (is_overloaded) {
    if (!Getattr(n, "sym:nextSibling")) {

      functionwrapper = Swig_name_wrapper(Getattr(n, "name"));
      // note: set this attribute to transfer ownership
      Setattr(n, "wrap:dispatcher", functionwrapper);

      // create dispatcher
      emitFunctionDispatcher(n, is_member);

      Delete(function_dispatcher_code);
      function_dispatcher_code = 0;

    } else {

      //don't register wrappers of overloaded functions in function tables
      return SWIG_OK;
    }
  }

  t_function.replace("${functionname}", functionname)
      .replace("${functionwrapper}", functionwrapper);

  if (is_member) {

    if (Equal(Getattr(n, "storage"), "static")) {
      Printv(class_static_functions_code, t_function.str(), 0);

    } else {
      Printv(current_class_functions, t_function.str(), 0);
    }

  } else {
    Printv(Getattr(current_namespace, "functions"), t_function.str(), 0);
  }

  return SWIG_OK;
}

int JSCEmitter::enterVariable(Node *n) {
  current_getter = NULL_STR;
  current_setter = VETO_SET;
  current_propertyname = Swig_scopename_last(Getattr(n, "name"));
  is_immutable = GetFlag(n, "wrap:immutable");

  return SWIG_OK;
}


int JSCEmitter::exitVariable(Node *n) {
  Template t_variable(getTemplate("JS_variabledecl"));
  t_variable.replace("${setname}", current_setter)
      .replace("${getname}", current_getter)
      .replace("${propertyname}", current_propertyname);

  if (GetFlag(n, "ismember")) {
    if (Equal(Getattr(n, "storage"), "static") || (Equal(Getattr(n, "nodeType"), "enumitem"))) {

      Printv(class_static_variables_code, t_variable.str(), 0);

    } else {
      Printv(class_variables_code, t_variable.str(), 0);
    }
  } else {
    Printv(Getattr(current_namespace, "values"), t_variable.str(), 0);
  }

  return SWIG_OK;
}

int JSCEmitter::enterClass(Node *n) {

  current_classname = Getattr(n, "sym:name");
  current_classname_mangled = SwigType_manglestr(Getattr(n, "name"));
  current_classtype = NewString(Getattr(n, "classtype"));

  String *type = SwigType_manglestr(Getattr(n, "classtypeobj"));
  current_classtype_mangled = NewString("");
  Printf(current_classtype_mangled, "p%s", type);
  Delete(type);

  Template t_class_defn = getTemplate("JS_class_definition");
  t_class_defn.replace("${classname_mangled}", current_classname_mangled);
  Wrapper_pretty_print(t_class_defn.str(), f_wrappers);

  class_variables_code = NewString("");
  current_class_functions = NewString("");
  class_static_variables_code = NewString("");
  class_static_functions_code = NewString("");
  ctor_wrappers = NewString("");
  ctor_dispatcher_code = NewString("");

  return SWIG_OK;
}

int JSCEmitter::exitClass(Node *n) {

  String *mangled_name = SwigType_manglestr(Getattr(n, "name"));

  Template t_class_tables(getTemplate("JS_class_tables"));
  t_class_tables.replace("${classname_mangled}", mangled_name)
      .replace("${jsclassvariables}", class_variables_code)
      .replace("${jsclassfunctions}", current_class_functions)
      .replace("${jsstaticclassfunctions}", class_static_functions_code)
      .replace("${jsstaticclassvariables}", class_static_variables_code);
  Wrapper_pretty_print(t_class_tables.str(), f_wrappers);

  /* adds the ctor wrappers at this position */
  // Note: this is necessary to avoid extra forward declarations.
  Printv(f_wrappers, ctor_wrappers, 0);

  /* adds the main constructor wrapper function */
  Template t_mainctor(getTemplate("JS_mainctordefn"));
  t_mainctor.replace("${classname_mangled}", mangled_name)
      .replace("${DISPATCH_CASES}", ctor_dispatcher_code);
  Wrapper_pretty_print(t_mainctor.str(), f_wrappers);

  /* adds a class template statement to initializer function */
  Template t_classtemplate(getTemplate("JS_create_class_template"));

  /* prepare registration of base class */
  String *base_name_mangled = NewString("_SwigObject");
  Node *base_class = getBaseClass(n);
  if (base_class != NULL) {
    Delete(base_name_mangled);
    base_name_mangled = SwigType_manglestr(Getattr(base_class, "name"));
  }

  t_classtemplate.replace("${classname_mangled}", mangled_name)
      .replace("${classtype_mangled}", current_classtype_mangled)
      .replace("${base_classname}", base_name_mangled);
  Wrapper_pretty_print(t_classtemplate.str(), initializer_code);

/*  
  String *clientdata = NewString("");
  Printv(clientdata, mangled_name, "_classRef", 0);
  SwigType_remember_clientdata(current_classtype_mangled, clientdata);
*/

  SwigType_remember_clientdata(current_classtype_mangled, NewString("0"));

  /* adds a class registration statement to initializer function */
  Template t_registerclass(getTemplate("JS_register_class"));
  t_registerclass.replace("${classname}", current_classname)
      .replace("${classname_mangled}", current_classname_mangled)
      .replace("${namespace_mangled}", Getattr(current_namespace, "name_mangled"));

  Wrapper_pretty_print(t_registerclass.str(), initializer_code);

  /* clean up all DOHs */
  Delete(class_variables_code);
  Delete(current_class_functions);
  Delete(class_static_variables_code);
  Delete(class_static_functions_code);
  Delete(ctor_wrappers);
  Delete(mangled_name);
  Delete(ctor_dispatcher_code);
  class_variables_code = 0;
  current_class_functions = 0;
  class_static_variables_code = 0;
  class_static_functions_code = 0;
  ctor_wrappers = 0;
  ctor_dispatcher_code = 0;

  Delete(current_classname);
  Delete(current_classname_mangled);
  Delete(current_classtype);
  Delete(current_classtype_mangled);

  return SWIG_OK;
}

int JSCEmitter::emitCtor(Node *n) {

  Template t_ctor(getTemplate("JS_ctordefn"));
  String *mangled_name = SwigType_manglestr(Getattr(n, "name"));

  String *name = (Getattr(n, "wrap:name"));
  String *overname = Getattr(n, "sym:overname");
  String *wrap_name = Swig_name_wrapper(name);
  Setattr(n, "wrap:name", wrap_name);

  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, current_wrapper);
  emit_attach_parmmaps(params, current_wrapper);

  Printf(current_wrapper->locals, "%sresult;", SwigType_str(Getattr(n, "type"), 0));

  int num_args = emit_num_arguments(params);
  String *action = emit_action(n);
  marshalInputArgs(n, params, current_wrapper, Ctor, true);

  Printv(current_wrapper->code, action, "\n", 0);
  t_ctor.replace("${classname_mangled}", mangled_name)
      .replace("${overloadext}", overname)
      .replace("${LOCALS}", current_wrapper->locals)
      .replace("${CODE}", current_wrapper->code)
      .replace("${type_mangled}", current_classtype_mangled);

  Wrapper_pretty_print(t_ctor.str(), ctor_wrappers);

  String *argcount = NewString("");
  Printf(argcount, "%d", num_args);

  Template t_ctor_case(getTemplate("JS_ctor_dispatch_case"));
  t_ctor_case.replace("${classname_mangled}", mangled_name)
      .replace("${overloadext}", overname)
      .replace("${argcount}", argcount);
  Printv(ctor_dispatcher_code, t_ctor_case.str(), 0);
  Delete(argcount);

  return SWIG_OK;

}

int JSCEmitter::emitDtor(Node *) {

  Template t_dtor = getTemplate("JS_destructordefn");
  t_dtor.replace("${classname_mangled}", current_classname_mangled)
      .replace("${type}", current_classtype);
  Wrapper_pretty_print(t_dtor.str(), f_wrappers);

  return SWIG_OK;
}

int JSCEmitter::emitGetter(Node *n, bool is_member) {
  Template t_getter(getTemplate("JS_getproperty"));
  bool is_static = Equal(Getattr(n, "storage"), "static");

  String *name = Getattr(n, "wrap:name");
  String *wrap_name = Swig_name_wrapper(name);
  current_getter = wrap_name;
  Setattr(n, "wrap:name", wrap_name);

  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, current_wrapper);
  emit_attach_parmmaps(params, current_wrapper);
  Wrapper_add_local(current_wrapper, "jsresult", "JSValueRef jsresult");

  String *action = emit_action(n);
  marshalInputArgs(n, params, current_wrapper, Getter, is_member, is_static);
  marshalOutput(n, action, current_wrapper);

  t_getter.replace("${getname}", wrap_name)
      .replace("${LOCALS}", current_wrapper->locals)
      .replace("${CODE}", current_wrapper->code);

  Wrapper_pretty_print(t_getter.str(), f_wrappers);

  return SWIG_OK;
}

int JSCEmitter::emitSetter(Node *n, bool is_member) {

  // skip variable that are immutable
  if (is_immutable)
    return SWIG_OK;

  Template t_setter(getTemplate("JS_setproperty"));
  bool is_static = Equal(Getattr(n, "storage"), "static");

  String *name = Getattr(n, "wrap:name");
  String *wrap_name = Swig_name_wrapper(name);
  current_setter = wrap_name;
  Setattr(n, "wrap:name", wrap_name);

  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, current_wrapper);
  emit_attach_parmmaps(params, current_wrapper);

  String *action = emit_action(n);
  marshalInputArgs(n, params, current_wrapper, Setter, is_member, is_static);
  Append(current_wrapper->code, action);

  t_setter.replace("${setname}", wrap_name)
      .replace("${LOCALS}", current_wrapper->locals)
      .replace("${CODE}", current_wrapper->code);

  Wrapper_pretty_print(t_setter.str(), f_wrappers);

  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * swig::JSEmitter::emitConstant() :  triggers code generation for constants
 * ----------------------------------------------------------------------------- */

int JSCEmitter::emitConstant(Node *n) {

  // call the variable methods as a constants are
  // registred in same way
  enterVariable(n);

  current_wrapper = NewWrapper();

  String *action = NewString("");

  String *name = Getattr(n, "name");
  String *wrap_name = Swig_name_wrapper(name);
  String *value = Getattr(n, "rawval");
  if (value == NULL) {
    value = Getattr(n, "rawvalue");
  }
  if (value == NULL) {
    value = Getattr(n, "value");
  }

  Template t_getter(getTemplate("JS_getproperty"));

  current_getter = wrap_name;
  Setattr(n, "wrap:name", wrap_name);

  Printf(action, "result = %s;\n", value);
  Setattr(n, "wrap:action", action);

  Wrapper_add_local(current_wrapper, "jsresult", "JSValueRef jsresult");
  marshalOutput(n, action, current_wrapper);

  t_getter.replace("${getname}", wrap_name)
      .replace("${LOCALS}", current_wrapper->locals)
      .replace("${CODE}", current_wrapper->code);

  Wrapper_pretty_print(t_getter.str(), f_wrappers);

  DelWrapper(current_wrapper);
  current_wrapper = 0;

  exitVariable(n);

  return SWIG_OK;
}

int JSCEmitter::emitFunction(Node *n, bool is_member) {
  Template t_function(getTemplate("JS_functionwrapper"));

  // Note: there is an inconsistency in SWIG with static member functions
  //       that do not have storage:static
  //       in these cases the context (staticmemberfunctionHandler) is
  //       exploited and a flag is set temporarily
  //       TODO: this could be done in general with is_member and is_static
  bool is_static = JSEmitter::is_static || Equal(Getattr(n, "storage"), "static");

  bool is_overloaded = GetFlag(n, "sym:overloaded");
  String *name = Getattr(n, "sym:name");
  String *wrap_name = Swig_name_wrapper(name);

  if (is_overloaded) {
    Append(wrap_name, Getattr(n, "sym:overname"));
  }

  current_functionwrapper = wrap_name;
  Setattr(n, "wrap:name", wrap_name);

  ParmList *params = Getattr(n, "parms");
  emit_parameter_variables(params, current_wrapper);
  emit_attach_parmmaps(params, current_wrapper);
  Wrapper_add_local(current_wrapper, "jsresult", "JSValueRef jsresult");

  String *action = emit_action(n);
  marshalInputArgs(n, params, current_wrapper, Function, is_member, is_static);
  marshalOutput(n, action, current_wrapper);

  t_function.replace("${functionname}", wrap_name)
      .replace("${LOCALS}", current_wrapper->locals)
      .replace("${CODE}", current_wrapper->code);
  Wrapper_pretty_print(t_function.str(), f_wrappers);

  if (is_overloaded) {
    Template t_dispatch_case = getTemplate("JS_function_dispatch_case");

    int argc = emit_num_arguments(params);
    String *argcount = NewString("");
    Printf(argcount, "%d", argc);

    t_dispatch_case.replace("${functionwrapper}", wrap_name)
	.replace("${argcount}", argcount);

    Printv(function_dispatcher_code, t_dispatch_case.str(), 0);

    Delete(argcount);
  }

  return SWIG_OK;
}

int JSCEmitter::emitFunctionDispatcher(Node *n, bool /*is_member */ ) {

  Template t_function(getTemplate("JS_functionwrapper"));

  Wrapper *wrapper = NewWrapper();
  String *wrap_name = Swig_name_wrapper(Getattr(n, "name"));
  Setattr(n, "wrap:name", wrap_name);

  Wrapper_add_local(wrapper, "jsresult", "JSValueRef jsresult");

  Append(wrapper->code, function_dispatcher_code);
  Append(wrapper->code, getTemplate("JS_function_dispatch_case_default").str());

  t_function.replace("${functionname}", wrap_name)
      .replace("${LOCALS}", wrapper->locals)
      .replace("${CODE}", wrapper->code);

  Wrapper_pretty_print(t_function.str(), f_wrappers);

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
	.replace("${namespace}", name_mangled);
    Wrapper_pretty_print(namespace_definition.str(), f_wrap_cpp);

    Template t_createNamespace(getTemplate("JS_create_namespace"));
    t_createNamespace.replace("${namespace}", name_mangled);
    Printv(create_namespaces_code, t_createNamespace.str(), 0);

    Template t_registerNamespace(getTemplate("JS_register_namespace"));
    t_registerNamespace.replace("${namespace_mangled}", name_mangled)
	.replace("${namespace}", name)
	.replace("${parent_namespace}", parent_mangled);
    Printv(register_namespaces_code, t_registerNamespace.str(), 0);
  }

  return SWIG_OK;
}

JSEmitter *swig_javascript_create_JSC_emitter() {
  return new JSCEmitter();
}

extern JSEmitter *swig_javascript_create_JSC_emitter();

/* ********************************************************************
 * JAVASCRIPT
 * ********************************************************************/

class JAVASCRIPT:public Language {

public:
  JAVASCRIPT() {
    emitter = NULL;
  } ~JAVASCRIPT() {
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
     *  Registers all %fragments assigned to section "templates" with the Emitter.
     **/
  virtual int fragmentDirective(Node *n);

  virtual int constantDirective(Node *n);

  virtual void main(int argc, char *argv[]);
  virtual int top(Node *n);

private:

  JSEmitter * emitter;
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

  if (GetFlag(n, "isextension") == 1)
    SetFlag(n, "ismember");

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

int JAVASCRIPT::staticmemberfunctionHandler(Node *n) {
  // workaround: storage=static is not set for static member functions
  emitter->setStaticFlag(true);
  Language::staticmemberfunctionHandler(n);
  emitter->setStaticFlag(false);
  return SWIG_OK;
}


/* ---------------------------------------------------------------------
 * variableHandler()
 *
 * Function handler for generating wrappers for variables 
 * --------------------------------------------------------------------- */

int JAVASCRIPT::variableHandler(Node *n) {

  if (!is_assignable(n)
      // HACK: don't know why this is assignable? But does not compile
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

  // TODO: handle callback declarations
  //Note: callbacks trigger this wrapper handler
  if (Equal(Getattr(n, "kind"), "function")) {
    return SWIG_OK;
  }
  //Language::constantWrapper(n);
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

  if (Cmp(section, "templates") == 0) {
    emitter->registerTemplate(Getattr(n, "value"), Getattr(n, "code"));
  } else {
    Swig_fragment_register(n);
  }

  return SWIG_OK;
}

int JAVASCRIPT::constantDirective(Node *n) {

  Language::constantDirective(n);

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

  delete emitter;

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
      } else if (strcmp(argv[i], "-debug-templates") == 0) {
	Swig_mark_arg(i);
	debug_templates = true;
      }
    }
  }

  switch (mode) {
  case JSEmitter::V8:
    {
      // TODO: emitter = create_v8_emitter();
      break;
    }
  case JSEmitter::JavascriptCore:
    {
      emitter = swig_javascript_create_JSC_emitter();
      break;
    }
  case JSEmitter::QtScript:
    {
      // TODO: emitter = create_qtscript_emitter();
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
    emitter->enableDebug();
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
 * swig_JAVASCRIPT()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_javascript() {
  return new JAVASCRIPT();
}

extern "C" Language *swig_javascript(void) {
  return new_swig_javascript();
}

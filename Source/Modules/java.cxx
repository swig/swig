/* -----------------------------------------------------------------------------
 * java.cxx
 *
 *     Java wrapper module.
 *
 * Author(s) : William Fulton
 *             Harco de Hilster
 *
 * Copyright (C) 1999-2002.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

char cvsroot_java_cxx[] = "$Header$";

#include <limits.h> // for INT_MAX
#include "swigmod.h"
#ifndef MACSWIG
#include "swigconfig.h"
#endif
#include <ctype.h>

class JAVA : public Language {
  static const char *usage;
  const  String *empty_string;

  Hash   *swig_types_hash;
  File   *f_runtime;
  File   *f_header;
  File   *f_wrappers;
  File   *f_init;

  bool   proxy_flag; // Flag for generating proxy classes
  bool   have_default_constructor_flag;
  bool   native_function_flag;     // Flag for when wrapping a native function
  bool   enum_constant_flag; // Flag for when wrapping an enum or constant
  bool   static_flag; // Flag for when wrapping a static functions or member variables
  bool   variable_wrapper_flag; // Flag for when wrapping a nonstatic member variable
  bool   wrapping_member_flag; // Flag for when wrapping a member variable/enum/const
  bool   global_variable_flag; // Flag for when wrapping a global variable

  String *imclass_name;  // intermediary class name
  String *module_class_name;  // module class name
  String *imclass_class_code; // intermediary class code
  String *proxy_class_def;
  String *proxy_class_code;
  String *module_class_code;
  String *proxy_class_name;
  String *variable_name; //Name of a variable being wrapped
  String *proxy_class_constants_code;
  String *module_class_constants_code;
  String *package; // Package name
  String *jnipackage; // Package name used in the JNI code
  String *imclass_imports; //intermediary class imports from %pragma
  String *module_imports; //module imports from %pragma
  String *imclass_baseclass; //inheritance for intermediary class class from %pragma
  String *module_baseclass; //inheritance for module class from %pragma
  String *imclass_interfaces; //interfaces for intermediary class class from %pragma
  String *module_interfaces; //interfaces for module class from %pragma
  String *imclass_class_modifiers; //class modifiers for intermediary class overriden by %pragma
  String *module_class_modifiers; //class modifiers for module class overriden by %pragma
  String *upcasts_code; //C++ casts for inheritance hierarchies C++ code
  String *imclass_cppcasts_code; //C++ casts up inheritance hierarchies intermediary class code
  String *destructor_call; //C++ destructor call if any
  String *outfile;

  enum type_additions {none, pointer, reference};

  public:

  /* -----------------------------------------------------------------------------
   * JAVA()
   * ----------------------------------------------------------------------------- */

  JAVA() : 
    empty_string(NewString("")),

    swig_types_hash(NULL),
    f_runtime(NULL),
    f_header(NULL),
    f_wrappers(NULL),
    f_init(NULL),

    proxy_flag(true),
    have_default_constructor_flag(false),
    native_function_flag(false),
    enum_constant_flag(false),
    static_flag(false),
    variable_wrapper_flag(false),
    wrapping_member_flag(false),
    global_variable_flag(false),

    imclass_name(NULL),
    module_class_name(NULL),
    imclass_class_code(NULL),
    proxy_class_def(NULL),
    proxy_class_code(NULL),
    module_class_code(NULL),
    proxy_class_name(NULL),
    variable_name(NULL),
    proxy_class_constants_code(NULL),
    module_class_constants_code(NULL),
    package(NULL),
    jnipackage(NULL),
    imclass_imports(NULL),
    module_imports(NULL),
    imclass_baseclass(NULL),
    module_baseclass(NULL),
    imclass_interfaces(NULL),
    module_interfaces(NULL),
    imclass_class_modifiers(NULL),
    module_class_modifiers(NULL),
    upcasts_code(NULL),
    imclass_cppcasts_code(NULL),
    destructor_call(NULL),
    outfile(NULL)

    {
    }

  /* -----------------------------------------------------------------------------
   * getProxyName()
   *
   * Test to see if a type corresponds to something wrapped with a proxy class
   * Return NULL if not otherwise the proxy class name
   * ----------------------------------------------------------------------------- */

  String *getProxyName(SwigType *t) {
    if (proxy_flag) {
      Node *n = classLookup(t);
      if (n) {
        return Getattr(n,"sym:name");
      }
    }
    return NULL;
  }

  /* -----------------------------------------------------------------------------
   * makeValidJniName()
   * ----------------------------------------------------------------------------- */

  String *makeValidJniName(const String *name) {
    String *valid_jni_name = NewString(name);
    Replaceall(valid_jni_name,"_","_1");
    return valid_jni_name;
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

    SWIG_library_directory("java");

    // Look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
        if (strcmp(argv[i],"-package") == 0) {
          if (argv[i+1]) {
            package = NewString("");
            Printf(package, argv[i+1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i+1);
            i++;
          } else {
            Swig_arg_error();
          }
        } else if ((strcmp(argv[i],"-shadow") == 0) || ((strcmp(argv[i],"-proxy") == 0))) {
          Printf(stderr,"Deprecated command line option: %s. Proxy classes are now generated by default.\n", argv[i]);
          Swig_mark_arg(i);
          proxy_flag = true;
        } else if ((strcmp(argv[i],"-noproxy") == 0)) {
          Swig_mark_arg(i);
          proxy_flag = false;
        } else if (strcmp(argv[i],"-jnic") == 0) {
          Swig_mark_arg(i);
          Printf(stderr,"Deprecated command line option: -jnic. C JNI calling convention now used when -c++ not specified.\n");
        } else if (strcmp(argv[i],"-nofinalize") == 0) {
          Swig_mark_arg(i);
          Printf(stderr,"Deprecated command line option: -nofinalize. Use the new javafinalize typemap instead.\n");
        } else if (strcmp(argv[i],"-jnicpp") == 0) {
          Swig_mark_arg(i);
          Printf(stderr,"Deprecated command line option: -jnicpp. C++ JNI calling convention now used when -c++ specified.\n");
        } else if (strcmp(argv[i],"-help") == 0) {
          Printf(stderr,"%s\n", usage);
        }
      }
    }

    // Add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGJAVA 1",0);

    // Add typemap definitions
    SWIG_typemap_lang("java");
    SWIG_config_file("java.swg");

    allow_overloading();
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {

    /* Initialize all of the output files */
    outfile = Getattr(n,"outfile");

    f_runtime = NewFile(outfile,"w");
    if (!f_runtime) {
      Printf(stderr,"Unable to open %s\n", outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header",f_header);
    Swig_register_filebyname("wrapper",f_wrappers);
    Swig_register_filebyname("runtime",f_runtime);
    Swig_register_filebyname("init",f_init);
    swig_types_hash = NewHash();

    // Make the intermediary class and module class names. The intermediary class name can be set in the module directive.
    Node* optionsnode = Getattr( Getattr(n,"module") ,"options");
    if (optionsnode)
        if (Getattr(optionsnode,"jniclassname"))
          imclass_name = Copy(Getattr(optionsnode,"jniclassname"));
    if (!imclass_name) {
      imclass_name = NewStringf("%sJNI", Getattr(n,"name"));
      module_class_name = Copy(Getattr(n,"name"));
    } else {
      // Rename the module name if it is the same as intermediary class name - a backwards compatibility solution
      if (Cmp(imclass_name, Getattr(n,"name")) == 0)
        module_class_name = NewStringf("%sModule", Getattr(n,"name"));
      else
        module_class_name = Copy(Getattr(n,"name"));
    }


    imclass_class_code = NewString("");
    proxy_class_def = NewString("");
    proxy_class_code = NewString("");
    module_class_constants_code = NewString("");
    imclass_baseclass = NewString("");
    imclass_interfaces = NewString("");
    imclass_class_modifiers = NewString(""); // package access only to the intermediary class by default
    module_class_code = NewString("");
    module_baseclass = NewString("");
    module_interfaces = NewString("");
    module_imports = NewString("");
    module_class_modifiers = NewString("public");
    imclass_imports = NewString("");
    imclass_cppcasts_code = NewString("");
    upcasts_code = NewString("");
    if (!package) package = NewString("");
    jnipackage = NewString("");

    Swig_banner(f_runtime);               // Print the SWIG banner message

    if (NoInclude) {
      Printf(f_runtime,"#define SWIG_NOINCLUDE\n");
    }

    String *wrapper_name = NewString("");

    if(Len(package)) {
      String *jniname = makeValidJniName(package);
      Printv(jnipackage, jniname, NIL);
      Delete(jniname);
      Replaceall(jnipackage,".","_");
      Append(jnipackage, "_");
    }
    String *jniname = makeValidJniName(imclass_name);
    Printf(wrapper_name, "Java_%s%s_%%f", Char(jnipackage), jniname);
    Delete(jniname);

    Swig_name_register((char*)"wrapper", Char(wrapper_name));
    Swig_name_register((char*)"set", (char*)"set_%v");
    Swig_name_register((char*)"get", (char*)"get_%v");
    Swig_name_register((char*)"member", (char*)"%c_%m");

    Delete(wrapper_name);

    Printf(f_wrappers,"\n#ifdef __cplusplus\n");
    Printf(f_wrappers,"extern \"C\" {\n");
    Printf(f_wrappers,"#endif\n\n");

    /* Emit code */
    Language::top(n);

    // Generate the intermediary class
    {
      String *filen = NewStringf("%s%s.java", Swig_file_dirname(outfile), imclass_name);
      File *f_im = NewFile(filen,"w");
      if(!f_im) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the intermediary class
      if(Len(package) > 0)
        Printf(f_im, "package %s;\n\n", package);

      emitBanner(f_im);
      if(imclass_imports)
        Printf(f_im, "%s\n", imclass_imports);

      if (Len(imclass_class_modifiers) > 0)
        Printf(f_im, "%s ", imclass_class_modifiers);
      Printf(f_im, "class %s ", imclass_name);

      if (imclass_baseclass && *Char(imclass_baseclass))
        Printf(f_im, "extends %s ", imclass_baseclass);
      if (Len(imclass_interfaces) > 0)
        Printv(f_im, "implements ", imclass_interfaces, " ", NIL);
      Printf(f_im, "{\n");

      // Add the intermediary class methods
      Printv(f_im, imclass_class_code, NIL);
      Printv(f_im, imclass_cppcasts_code, NIL);

      // Finish off the class
      Printf(f_im, "}\n");
      Close(f_im);
    }

    // Generate the Java module class
    {
      String *filen = NewStringf("%s%s.java", Swig_file_dirname(outfile), module_class_name);
      File *f_module = NewFile(filen,"w");
      if(!f_module) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the module class
      if(Len(package) > 0)
        Printf(f_module, "package %s;\n\n", package);

      emitBanner(f_module);
      if(module_imports)
        Printf(f_module, "%s\n", module_imports);

      if (Len(module_class_modifiers) > 0)
        Printf(f_module, "%s ", module_class_modifiers);
      Printf(f_module, "class %s ", module_class_name);

      if (module_baseclass && *Char(module_baseclass))
        Printf(f_module, "extends %s ", module_baseclass);
      if (Len(module_interfaces) > 0) {
        if (Len(module_class_constants_code) != 0 )
          Printv(f_module, "implements ", Getattr(n, "name"), "Constants, ", module_interfaces, " ", NIL);
        else
          Printv(f_module, "implements ", module_interfaces, " ", NIL);
      } else {
        if (Len(module_class_constants_code) != 0 )
          Printv(f_module, "implements ", Getattr(n, "name"), "Constants ", NIL);
      }
      Printf(f_module, "{\n");

      // Add the wrapper methods
      Printv(f_module, module_class_code, NIL);

      // Finish off the class
      Printf(f_module, "}\n");
      Close(f_module);
    }

    // Generate the Java constants interface
    if (Len(module_class_constants_code) != 0 ) {
      String *filen = NewStringf("%s%sConstants.java", Swig_file_dirname(outfile), module_class_name);
      File *f_module = NewFile(filen,"w");
      if(!f_module) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the Java constants interface
      if(Len(package) > 0)
        Printf(f_module, "package %s;\n\n", package);

      emitBanner(f_module);
      if(module_imports)
        Printf(f_module, "%s\n", module_imports);

      if (Len(module_class_modifiers) > 0)
        Printf(f_module, "%s ", module_class_modifiers);
      Printf(f_module, "interface %sConstants {\n", module_class_name);

      // Write out all the enums constants
      Printv(f_module, "  // enums and constants\n", module_class_constants_code, NIL);

      // Finish off the Java interface
      Printf(f_module, "}\n");
      Close(f_module);
    }

    if(upcasts_code)
      Printv(f_wrappers,upcasts_code,NIL);

    Printf(f_wrappers,"#ifdef __cplusplus\n");
    Printf(f_wrappers,"}\n");
    Printf(f_wrappers,"#endif\n");

    // Output a Java type wrapper class for each SWIG type
    for (String *swig_type = Firstkey(swig_types_hash); swig_type; swig_type = Nextkey(swig_types_hash)) {
      emitTypeWrapperClass(swig_type, Getattr(swig_types_hash, swig_type));
    }

    Delete(swig_types_hash); swig_types_hash = NULL;
    Delete(imclass_name); imclass_name = NULL;
    Delete(imclass_class_code); imclass_class_code = NULL;
    Delete(proxy_class_def); proxy_class_def = NULL;
    Delete(proxy_class_code); proxy_class_code = NULL;
    Delete(module_class_constants_code); module_class_constants_code = NULL;
    Delete(imclass_baseclass); imclass_baseclass = NULL;
    Delete(imclass_interfaces); imclass_interfaces = NULL;
    Delete(imclass_class_modifiers); imclass_class_modifiers = NULL;
    Delete(module_class_name); module_class_name = NULL;
    Delete(module_class_code); module_class_code = NULL;
    Delete(module_baseclass); module_baseclass = NULL;
    Delete(module_interfaces); module_interfaces = NULL;
    Delete(module_imports); module_imports = NULL;
    Delete(module_class_modifiers); module_class_modifiers = NULL;
    Delete(imclass_imports); imclass_imports = NULL;
    Delete(imclass_cppcasts_code); imclass_cppcasts_code = NULL;
    Delete(upcasts_code); upcasts_code = NULL;
    Delete(package); package = NULL;
    Delete(jnipackage); jnipackage = NULL;

    /* Close all of the files */
    Dump(f_header,f_runtime);
    Dump(f_wrappers,f_runtime);
    Wrapper_pretty_print(f_init,f_runtime);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Close(f_runtime);
    Delete(f_runtime);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * emitBanner()
   * ----------------------------------------------------------------------------- */

  void emitBanner(File *f) {
    Printf(f, "/* ----------------------------------------------------------------------------\n");
    Printf(f, " * This file was automatically generated by SWIG (http://www.swig.org).\n");
    Printf(f, " * Version: %s\n", PACKAGE_VERSION);
    Printf(f, " *\n");
    Printf(f, " * Do not make changes to this file unless you know what you are doing--modify\n");
    Printf(f, " * the SWIG interface file instead.\n");
    Printf(f, " * ----------------------------------------------------------------------------- */\n\n");
  }

  /* ----------------------------------------------------------------------
   * nativeWrapper()
   * ---------------------------------------------------------------------- */

  virtual int nativeWrapper(Node *n) {
    String *wrapname = Getattr(n,"wrap:name");

    if (!addSymbol(wrapname,n)) return SWIG_ERROR;

    if (Getattr(n,"type")) {
      Swig_save("nativeWrapper",n,"name",NIL);
      Setattr(n,"name", wrapname);
      native_function_flag = true;
      functionWrapper(n);
      Swig_restore(n);
      native_function_flag = false;
    } else {
      Printf(stderr,"%s : Line %d. No return type for %%native method %s.\n", input_file, line_number, Getattr(n,"wrap:name"));
    }

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * functionWrapper()
   * ---------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
    String   *symname = Getattr(n,"sym:name");
    SwigType *t = Getattr(n,"type");
    ParmList *l = Getattr(n,"parms");
    String    *tm;
    Parm      *p;
    int       i;
    String    *c_return_type = NewString("");
    String    *im_return_type = NewString("");
    String    *cleanup = NewString("");
    String    *outarg = NewString("");
    String    *body = NewString("");
    int       num_arguments = 0;
    int       num_required = 0;
    bool      is_void_return;
    String    *overloaded_name = getOverloadedName(n);

    if (!Getattr(n,"sym:overloaded")) {
      if (!addSymbol(Getattr(n,"sym:name"),n)) return SWIG_ERROR;
    }

    /* 
     * Generate the proxy class getters/setters for public member variables.
     * Not for enums and constants.
     */
    if(proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Capitalize the first letter in the variable to create a JavaBean type getter/setter function name
      bool getter_flag = Cmp(symname, Swig_name_set(Swig_name_member(proxy_class_name, variable_name))) != 0;

      String *getter_setter_name = NewString("");
      if(!getter_flag)
        Printf(getter_setter_name,"set");
      else 
        Printf(getter_setter_name,"get");
      Putc(toupper((int) *Char(variable_name)), getter_setter_name);
      Printf(getter_setter_name, "%s", Char(variable_name)+1);

      Setattr(n,"proxyfuncname", getter_setter_name);
      Setattr(n,"imfuncname", symname);

      proxyClassFunctionHandler(n);
      Delete(getter_setter_name);
    }

    /*
       The rest of this function deals with generating the intermediary class wrapper function (that wraps
       a c/c++ function) and generating the JNI c code. Each Java wrapper function has a 
       matching JNI c function call.
       */

    // A new wrapper function object
    Wrapper *f = NewWrapper();

    // Make a wrapper name for this function
    String *jniname = makeValidJniName(overloaded_name);
    String *wname = Swig_name_wrapper(jniname);
    Delete(jniname);

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("jni", l, f);
    Swig_typemap_attach_parms("jtype", l, f);

    /* Get return types */
    if ((tm = Swig_typemap_lookup_new("jni",n,"",0))) {
      Printf(c_return_type,"%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JNI_UNDEF, input_file, line_number, 
          "No jni typemap defined for %s\n", SwigType_str(t,0));
    }

    if ((tm = Swig_typemap_lookup_new("jtype",n,"",0))) {
      Printf(im_return_type,"%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JTYPE_UNDEF, input_file, line_number, 
          "No jtype typemap defined for %s\n", SwigType_str(t,0));
    }

    is_void_return = (Cmp(c_return_type, "void") == 0);
    if (!is_void_return)
      Wrapper_add_localv(f,"jresult", c_return_type, "jresult = 0",NIL);

    Printf(imclass_class_code, "  public final static native %s %s(", im_return_type, overloaded_name);

    Printv(f->def, "JNIEXPORT ", c_return_type, " JNICALL ", wname, "(JNIEnv *jenv, jclass jcls", NIL);

    // Usually these function parameters are unused - The code below ensures that compilers do not issue such a warning if configured to do so.
    Printv(f->code,"    (void)jenv;\n",NIL);
    Printv(f->code,"    (void)jcls;\n",NIL);

    // Emit all of the local variables for holding arguments.
    emit_args(t,l,f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l,f);
    Setattr(n,"wrap:parms",l);

    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required  = emit_num_required(l);
    int gencomma = 0;

    // Now walk the function parameter list and generate code to get arguments
    for (i = 0, p=l; i < num_arguments; i++) {

      while (checkAttribute(p,"tmap:in:numinputs","0")) {
        p = Getattr(p,"tmap:in:next");
      }

      SwigType *pt = Getattr(p,"type");
      String   *ln = Getattr(p,"lname");
      String   *im_param_type = NewString("");
      String   *c_param_type = NewString("");
      String   *arg = NewString("");

      Printf(arg,"j%s", ln);

      /* Get the JNI C types of the parameter */
      if ((tm = Getattr(p,"tmap:jni"))) {
        Printv(c_param_type, tm, NIL);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JNI_UNDEF, input_file, line_number, 
            "No jni typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Get the intermediary class parameter types of the parameter */
      if ((tm = Getattr(p,"tmap:jtype"))) {
        Printv(im_param_type, tm, NIL);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JTYPE_UNDEF, input_file, line_number, 
            "No jtype typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Add parameter to intermediary class method */
      if(gencomma) Printf(imclass_class_code, ", ");
      Printf(imclass_class_code, "%s %s", im_param_type, arg);

      gencomma = 1;

      // Add parameter to C function
      Printv(f->def, ", ", c_param_type, " ", arg, NIL);

      // Get typemap for this argument
      if ((tm = Getattr(p,"tmap:in"))) {
        addThrows(n, "tmap:in", p);
        Replaceall(tm,"$source",arg); /* deprecated */
        Replaceall(tm,"$target",ln); /* deprecated */
        Replaceall(tm,"$arg",arg); /* deprecated? */
        Replaceall(tm,"$input", arg);
        Setattr(p,"emit:input", arg);
        Printf(f->code,"%s\n", tm);
        p = Getattr(p,"tmap:in:next");
      } else {
        Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, 
            "Unable to use type %s as a function argument.\n",SwigType_str(pt,0));
        p = nextSibling(p);
      }
      Delete(im_param_type);
      Delete(c_param_type);
      Delete(arg);
    }

    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:check"))) {
        addThrows(n, "tmap:check", p);
        Replaceall(tm,"$target",Getattr(p,"lname")); /* deprecated */
        Replaceall(tm,"$arg",Getattr(p,"emit:input")); /* deprecated? */
        Replaceall(tm,"$input",Getattr(p,"emit:input"));
        Printv(f->code,tm,"\n",NIL);
        p = Getattr(p,"tmap:check:next");
      } else {
        p = nextSibling(p);
      }
    }

    /* Insert cleanup code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:freearg"))) {
        addThrows(n, "tmap:freearg", p);
        Replaceall(tm,"$source",Getattr(p,"emit:input")); /* deprecated */
        Replaceall(tm,"$arg",Getattr(p,"emit:input")); /* deprecated? */
        Replaceall(tm,"$input",Getattr(p,"emit:input"));
        Printv(cleanup,tm,"\n",NIL);
        p = Getattr(p,"tmap:freearg:next");
      } else {
        p = nextSibling(p);
      }
    }

    /* Insert argument output code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:argout"))) {
        addThrows(n, "tmap:argout", p);
        Replaceall(tm,"$source",Getattr(p,"emit:input")); /* deprecated */
        Replaceall(tm,"$target",Getattr(p,"lname")); /* deprecated */
        Replaceall(tm,"$arg",Getattr(p,"emit:input")); /* deprecated? */
        Replaceall(tm,"$result","jresult");
        Replaceall(tm,"$input",Getattr(p,"emit:input"));
        Printv(outarg,tm,"\n",NIL);
        p = Getattr(p,"tmap:argout:next");
      } else {
        p = nextSibling(p);
      }
    }

    // Get any Java exception classes in the throws typemap
    ParmList *throw_parm_list = NULL;
    if ((throw_parm_list = Getattr(n,"throws"))) {
      Swig_typemap_attach_parms("throws", throw_parm_list, f);
      for (p = throw_parm_list; p; p=nextSibling(p)) {
        if ((tm = Getattr(p,"tmap:throws"))) {
          addThrows(n, "tmap:throws", p);
        }
      }
    }

    if (Cmp(nodeType(n), "constant") == 0) {
      // Wrapping a constant hack
      Swig_save("functionWrapper",n,"wrap:action",NIL);

      // below based on Swig_VargetToFunction()
      SwigType *ty = Swig_wrapped_var_type(Getattr(n,"type"));
      Setattr(n,"wrap:action", NewStringf("result = (%s) %s;\n", SwigType_lstr(ty,0), Getattr(n, "value")));
    }

    // Now write code to make the function call
    if(!native_function_flag)
      emit_action(n,f);

    if (Cmp(nodeType(n), "constant") == 0)
      Swig_restore(n);

    /* Return value if necessary  */
    if(!native_function_flag) {
      if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
        addThrows(n, "tmap:out", n);
        Replaceall(tm,"$source", "result"); /* deprecated */
        Replaceall(tm,"$target", "jresult"); /* deprecated */
        Replaceall(tm,"$result","jresult");
        Printf(f->code,"%s", tm);
        if (Len(tm))
          Printf(f->code,"\n");
      } else {
        Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
            "Unable to use return type %s in function %s.\n", SwigType_str(t,0), Getattr(n,"name"));
      }
    }

    /* Output argument output code */
    Printv(f->code,outarg,NIL);

    /* Output cleanup code */
    Printv(f->code,cleanup,NIL);

    /* Look to see if there is any newfree cleanup code */
    if (Getattr(n,"feature:new")) {
      if ((tm = Swig_typemap_lookup_new("newfree",n,"result",0))) {
        Replaceall(tm,"$source","result"); /* deprecated */
        Printf(f->code,"%s\n",tm);
      }
    }

    /* See if there is any return cleanup code */
    if(!native_function_flag) {
      if ((tm = Swig_typemap_lookup_new("ret", n, "result", 0))) {
        Replaceall(tm,"$source","result"); /* deprecated */
        Printf(f->code,"%s\n",tm);
      }
    }

    /* Finish C function and intermediary class function definitions */
    Printf(imclass_class_code, ")");
    generateThrowsClause(n, imclass_class_code);
    Printf(imclass_class_code, ";\n");
    Printf(f->def,") {");

    if(!is_void_return)
      Printv(f->code, "    return jresult;\n", NIL);
    Printf(f->code, "}\n");

    /* Substitute the cleanup code */
    Replaceall(f->code,"$cleanup",cleanup);

    if(!is_void_return)
      Replaceall(f->code,"$null","0");
    else
      Replaceall(f->code,"$null","");

    /* Dump the function out */
    if(!native_function_flag)
      Wrapper_print(f,f_wrappers);

    Setattr(n,"wrap:name", wname);

    /* Emit warnings for the few cases that can't be overloaded in Java */
    if (Getattr(n,"sym:overloaded")) {
      if (!Getattr(n,"sym:nextSibling"))
        Swig_overload_rank(n);
    }

    if(!(proxy_flag && is_wrapping_class()) && !enum_constant_flag) {
      moduleClassFunctionHandler(n);
    }

    Delete(c_return_type);
    Delete(im_return_type);
    Delete(cleanup);
    Delete(outarg);
    Delete(body);
    Delete(overloaded_name);
    DelWrapper(f);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * variableWrapper()
   * ----------------------------------------------------------------------- */

  virtual int variableWrapper(Node *n) {
    Language::variableWrapper(n);           /* Default to functions */
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalvariableHandler(Node *n) {

    variable_name = Getattr(n,"sym:name");
    global_variable_flag = true;
    int ret = Language::globalvariableHandler(n);
    global_variable_flag = false;
    return ret;
  }

  /* -----------------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    String *symname = Getattr(n,"sym:name");
    SwigType *t     = Getattr(n,"type");
    ParmList  *l    = Getattr(n,"parms");
    String *tm;
    String *return_type = NewString("");
    String *constants_code = NewString("");
    SwigType *original_type = t;

    if (!addSymbol(symname,n)) return SWIG_ERROR;

    bool is_enum_item = (Cmp(nodeType(n), "enumitem") == 0);

    /* Adjust the enum type for the Swig_typemap_lookup. We want the same jstype typemap for all the enum items.
     * The type of each enum item depends on what value it is assigned, but is usually a C int. */
    if (is_enum_item) {
      t = NewStringf("enum %s", Getattr(parentNode(n), "sym:name"));
      Setattr(n,"type", t);
    }

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("jstype", l, NULL);

    /* Get Java return types */
    bool classname_substituted_flag = false;
    
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      classname_substituted_flag = substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    // Add the stripped quotes back in
    String *new_value = NewString("");
    Swig_save("constantWrapper",n,"value",NIL);
    if(SwigType_type(t) == T_STRING) {
      Printf(new_value, "\"%s\"", Copy(Getattr(n, "value")));
      Setattr(n, "value", new_value);
    }
    else if(SwigType_type(t) == T_CHAR) {
      Printf(new_value, "\'%s\'", Copy(Getattr(n, "value")));
      Setattr(n, "value", new_value);
    }

    // The %javaconst feature determines how the constant value is obtained
    String *const_feature = Getattr(n,"feature:java:const");
    bool const_feature_flag = const_feature && Cmp(const_feature, "0") != 0;

    // enums are wrapped using a public final static int in java.
    // Other constants are wrapped using a public final static [jstype] in Java.
    Printf(constants_code, "  public final static %s %s = ", return_type, ((proxy_flag && wrapping_member_flag) ? variable_name : symname));

    if ((is_enum_item && Getattr(n,"enumvalue") == 0) || !const_feature_flag) {
      // Enums without value and default constant handling will work with any type of C constant and initialises the Java variable from C through a JNI call.

      if(classname_substituted_flag) // This handles function pointers using the %constant directive
        Printf(constants_code, "new %s(%s.%s(), false);\n", return_type, imclass_name, Swig_name_get(symname));
      else
        Printf(constants_code, "%s.%s();\n", imclass_name, Swig_name_get(symname));

      // Each constant and enum value is wrapped with a separate JNI function call
      enum_constant_flag = true;
      variableWrapper(n);
      enum_constant_flag = false;
    } else if (is_enum_item) {
      // Alternative enum item handling will use the explicit value of the enum item and hope that it compiles as Java code
      Printf(constants_code, "%s;\n", Getattr(n,"enumvalue"));
    } else {
      // Alternative constant handling will use the C syntax to make a true Java constant and hope that it compiles as Java code
      Printf(constants_code, "%s;\n", Getattr(n,"value"));
    }

    if(proxy_flag && wrapping_member_flag)
      Printv(proxy_class_constants_code, constants_code, NIL);
    else
      Printv(module_class_constants_code, constants_code, NIL);

    Swig_restore(n);
    if (is_enum_item) {
      Delete(Getattr(n,"type"));
      Setattr(n,"type", original_type);
    }
    Delete(new_value);
    Delete(return_type);
    Delete(constants_code);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * pragmaDirective()
   *
   * Valid Pragmas:
   * jniclassbase            - base (extends) for the intermediary class
   * jniclassclassmodifiers  - class modifiers for the intermediary class
   * jniclasscode            - text (java code) is copied verbatim to the intermediary class
   * jniclassimports         - import statements for the intermediary class
   * jniclassinterfaces      - interface (implements) for the intermediary class
   *
   * modulebase              - base (extends) for the module class
   * moduleclassmodifiers    - class modifiers for the module class
   * modulecode              - text (java code) is copied verbatim to the module class
   * moduleimports           - import statements for the module class
   * moduleinterfaces        - interface (implements) for the module class
   *
   * ----------------------------------------------------------------------------- */

  virtual int pragmaDirective(Node *n) {
    if (!ImportMode) {
      String *lang = Getattr(n,"lang");
      String *code = Getattr(n,"name");
      String *value = Getattr(n,"value");

      if(Strcmp(lang, "java") == 0) {

        String *strvalue = NewString(value);
        Replaceall(strvalue,"\\\"", "\"");

        if(Strcmp(code, "jniclassbase") == 0) {
          Delete(imclass_baseclass);
          imclass_baseclass = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclassclassmodifiers") == 0) {
          Delete(imclass_class_modifiers);
          imclass_class_modifiers = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclasscode") == 0) {
          Printf(imclass_class_code, "%s\n", strvalue);
        } 
        else if(Strcmp(code, "jniclassimports") == 0) {
          Delete(imclass_imports);
          imclass_imports = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclassinterfaces") == 0) {
          Delete(imclass_interfaces);
          imclass_interfaces = Copy(strvalue);
        } 
        else if(Strcmp(code, "modulebase") == 0) {
          Delete(module_baseclass);
          module_baseclass = Copy(strvalue);
        } 
        else if(Strcmp(code, "moduleclassmodifiers") == 0) {
          Delete(module_class_modifiers);
          module_class_modifiers = Copy(strvalue);
        } 
        else if(Strcmp(code, "modulecode") == 0) {
          Printf(module_class_code, "%s\n", strvalue);
        } 
        else if(Strcmp(code, "moduleimports") == 0) {
          Delete(module_imports);
          module_imports = Copy(strvalue);
        } 
        else if(Strcmp(code, "moduleinterfaces") == 0) {
          Delete(module_interfaces);
          module_interfaces = Copy(strvalue);
        } 
        else if(Strcmp(code, "moduleimport") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use the moduleimports pragma.\n", input_file, line_number);
        } 
        else if(Strcmp(code, "moduleinterface") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use the moduleinterfaces pragma.\n", input_file, line_number);
        } 
        else if(Strcmp(code, "modulemethodmodifiers") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %javamethodmodifiers.\n", input_file, line_number);
        } 
        else if(Strcmp(code, "allshadowimport") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javaimports).\n", input_file, line_number);
        } 
        else if(Strcmp(code, "allshadowcode") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javacode).\n", input_file, line_number);
        } 
        else if(Strcmp(code, "allshadowbase") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javabase).\n", input_file, line_number);
        } 
        else if(Strcmp(code, "allshadowinterface") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javainterfaces).\n", input_file, line_number);
        } 
        else if(Strcmp(code, "allshadowclassmodifiers") == 0) {
          Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javaclassmodifiers).\n", input_file, line_number);
        } 
        else if (proxy_flag) {
          if (Strcmp(code,"shadowcode") == 0) {
            Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javacode).\n", input_file, line_number);
          } 
          else if (Strcmp(code,"shadowimport") == 0) {
            Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javaimports).\n", input_file, line_number);
          } 
          else if (Strcmp(code,"shadowbase") == 0) {
            Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javabase).\n", input_file, line_number);
          } 
          else if (Strcmp(code,"shadowinterface") == 0) {
            Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javainterfaces).\n", input_file, line_number);
          } 
          else if (Strcmp(code,"shadowclassmodifiers") == 0) {
            Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please use %typemap(javaclassmodifiers).\n", input_file, line_number);
          }  else {
            Printf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
          }
        } else {
          Printf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
        }
        Delete(strvalue);
      }
    }
    return Language::pragmaDirective(n);
  }

  /* -----------------------------------------------------------------------------
   * emitProxyClassDefAndCPPCasts()
   * ----------------------------------------------------------------------------- */

  void emitProxyClassDefAndCPPCasts(Node *n) {
    String *c_classname = SwigType_namestr(Getattr(n,"name"));
    String *c_baseclass = NULL;
    String *baseclass = NULL;
    String *c_baseclassname = NULL;
    String *classDeclarationName = Getattr(n,"classDeclaration:name");

    /* Deal with inheritance */
    List *baselist = Getattr(n,"bases");
    if (baselist) {
      Node *base = Firstitem(baselist);
      c_baseclassname = Getattr(base,"name");
      baseclass = Copy(getProxyName(c_baseclassname));
      if (baseclass){
        c_baseclass = SwigType_namestr(Getattr(base,"name"));
      }
      base = Nextitem(baselist);
      if (base) {
        Swig_warning(WARN_JAVA_MULTIPLE_INHERITANCE, input_file, line_number, 
            "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in Java.\n", classDeclarationName, Getattr(base,"name"));
      }
    }

    bool derived = baseclass && getProxyName(c_baseclassname);
    if (!baseclass)
      baseclass = NewString("");

    // Inheritance from pure Java classes
    const String *pure_baseclass = typemapLookup("javabase", classDeclarationName, WARN_NONE);
    if (Len(pure_baseclass) > 0 && Len(baseclass) > 0) {
      Swig_warning(WARN_JAVA_MULTIPLE_INHERITANCE, input_file, line_number, 
          "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in Java.\n", classDeclarationName, pure_baseclass);
    }

    // Pure Java interfaces
    const String *pure_interfaces = typemapLookup("javainterfaces", classDeclarationName, WARN_NONE);

    // Start writing the proxy class
    Printv(proxy_class_def,
        typemapLookup("javaimports", classDeclarationName, WARN_NONE), // Import statements
        "\n",
        typemapLookup("javaclassmodifiers", classDeclarationName, WARN_JAVA_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers
        " class $javaclassname",       // Class name and bases
        (derived || *Char(pure_baseclass)) ?
        " extends " : 
        "",
        baseclass,
        pure_baseclass,
        *Char(pure_interfaces) ?  // Pure Java interfaces
        " implements " :
        "",
        pure_interfaces,
        " {\n",
        "  private long swigCPtr;\n",  // Member variables for memory handling
        derived ? 
        "" : 
        "  protected boolean swigCMemOwn;\n",
        "\n",
        "  ",
        typemapLookup("javaptrconstructormodifiers", classDeclarationName, WARN_JAVA_TYPEMAP_PTRCONSTMOD_UNDEF), // pointer constructor modifiers
        " $javaclassname(long cPtr, boolean cMemoryOwn) {\n", // Constructor used for wrapping pointers
        derived ? 
        "    super($imclassname.SWIG$javaclassnameTo$baseclass(cPtr), cMemoryOwn);\n" : 
        "    swigCMemOwn = cMemoryOwn;\n",
        "    swigCPtr = cPtr;\n",
        "  }\n",
        NIL);

    if(!have_default_constructor_flag) { // All proxy classes need a constructor
      Printv(proxy_class_def, 
          "\n",
          "  protected $javaclassname() {\n",
          "    this(0, false);\n", 
          "  }\n",
          NIL);
    }

    // C++ destructor is wrapped by the delete method
    String *destruct = NewString("");
    const String *tm = NULL;
    if (derived)
      tm = typemapLookup("javadestruct_derived", classDeclarationName, WARN_NONE);
    else
      tm = typemapLookup("javadestruct", classDeclarationName, WARN_NONE);

    // Emit the finalize and delete methods
    if (tm) {
      // Finalize method
      if (*Char(destructor_call)) {
        Printv(proxy_class_def, 
            typemapLookup("javafinalize", classDeclarationName, WARN_NONE),
            NIL);
      }
      // delete method
      Printv(destruct, tm, NIL);
      if (*Char(destructor_call))
        Replaceall(destruct, "$jnicall", destructor_call);
      else
        Replaceall(destruct, "$jnicall", "");
      if (*Char(destruct))
        Printv(proxy_class_def, "\n  ", *Char(destructor_call) ? "public": "protected", " void delete() ", destruct, "\n", NIL);
    }
    Delete(destruct);

    // Emit various other methods
    Printv(proxy_class_def, 
        typemapLookup("javagetcptr", classDeclarationName, WARN_JAVA_TYPEMAP_GETCPTR_UNDEF), // getCPtr method
        typemapLookup("javacode", classDeclarationName, WARN_NONE), // extra Java code
        "\n",
        NIL);

    // Substitute various strings into the above template
    Replaceall(proxy_class_code, "$javaclassname", proxy_class_name);
    Replaceall(proxy_class_def,  "$javaclassname", proxy_class_name);

    Replaceall(proxy_class_def,  "$baseclass", baseclass);
    Replaceall(proxy_class_code, "$baseclass", baseclass);

    Replaceall(proxy_class_def,  "$imclassname", imclass_name);
    Replaceall(proxy_class_code, "$imclassname", imclass_name);

    // Add code to do C++ casting to base class (only for classes in an inheritance hierarchy)
    if(derived){
      Printv(imclass_cppcasts_code,"  public final static native long ",
          "SWIG$javaclassnameTo$baseclass(long jarg1);\n",
          NIL);

      Replaceall(imclass_cppcasts_code, "$javaclassname", proxy_class_name);
      Replaceall(imclass_cppcasts_code, "$baseclass", baseclass);

      Printv(upcasts_code,
          "JNIEXPORT jlong JNICALL Java_$jnipackage$imimclass_SWIG$imclazznameTo$imbaseclass",
          "(JNIEnv *jenv, jclass jcls, jlong jarg1) {\n",
          "    jlong baseptr = 0;\n"
          "    (void)jenv;\n"
          "    (void)jcls;\n"
          "    *($cbaseclass **)&baseptr = *($cclass **)&jarg1;\n"
          "    return baseptr;\n"
          "}\n",
          "\n",
          NIL); 

      String *imimclass  = makeValidJniName(imclass_name);
      String *imclazzname = makeValidJniName(proxy_class_name);
      String *imbaseclass = makeValidJniName(baseclass);
      Replaceall(upcasts_code, "$imbaseclass", imbaseclass);
      Replaceall(upcasts_code, "$cbaseclass",  c_baseclass);
      Replaceall(upcasts_code, "$imclazzname", imclazzname);
      Replaceall(upcasts_code, "$cclass",      c_classname);
      Replaceall(upcasts_code, "$jnipackage",  jnipackage);
      Replaceall(upcasts_code, "$imimclass",   imimclass);

      Delete(imbaseclass);
      Delete(imclazzname);
      Delete(imimclass);
    }
    Delete(baseclass);
  }

  /* ----------------------------------------------------------------------
   * classHandler()
   * ---------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {

    File *f_proxy = NULL;
    if (proxy_flag) {
      proxy_class_name = NewString(Getattr(n,"sym:name"));

      if (!addSymbol(proxy_class_name,n)) return SWIG_ERROR;

      if (Cmp(proxy_class_name, imclass_name) == 0) {
        Printf(stderr, "Class name cannot be equal to intermediary class name: %s\n", proxy_class_name);
        SWIG_exit(EXIT_FAILURE);
      }

      if (Cmp(proxy_class_name, module_class_name) == 0) {
        Printf(stderr, "Class name cannot be equal to module class name: %s\n", proxy_class_name);
        SWIG_exit(EXIT_FAILURE);
      }

      String *filen = NewStringf("%s%s.java", Swig_file_dirname(outfile), proxy_class_name);
      f_proxy = NewFile(filen,"w");
      if(!f_proxy) {
        Printf(stderr, "Unable to create proxy class file: %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      emitBanner(f_proxy);

      if(Len(package) > 0)
        Printf(f_proxy, "package %s;\n\n", package);

      Clear(proxy_class_def);
      Clear(proxy_class_code);

      have_default_constructor_flag = false;
      destructor_call = NewString("");
      proxy_class_constants_code = NewString("");
    }
    Language::classHandler(n);

    if (proxy_flag) {

      emitProxyClassDefAndCPPCasts(n);

      Printv(f_proxy, proxy_class_def, proxy_class_code, NIL);

      // Write out all the enums and constants
      if (Len(proxy_class_constants_code) != 0 )
        Printv(f_proxy, "  // enums and constants\n", proxy_class_constants_code, NIL);

      Printf(f_proxy, "}\n");
      Close(f_proxy);
      f_proxy = NULL;

      Delete(proxy_class_name); proxy_class_name = NULL;
      Delete(destructor_call); destructor_call = NULL;
      Delete(proxy_class_constants_code); proxy_class_constants_code = NULL;
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * memberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberfunctionHandler(Node *n) {
    Language::memberfunctionHandler(n);

    if (proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *intermediary_function_name = Swig_name_member(proxy_class_name, overloaded_name);
      Setattr(n,"proxyfuncname", Getattr(n, "sym:name"));
      Setattr(n,"imfuncname", intermediary_function_name);
      proxyClassFunctionHandler(n);
      Delete(overloaded_name);
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmemberfunctionHandler(Node *n) {

    static_flag = true;
    Language::staticmemberfunctionHandler(n);

    if (proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *intermediary_function_name = Swig_name_member(proxy_class_name, overloaded_name);
      Setattr(n,"proxyfuncname", Getattr(n,"sym:name"));
      Setattr(n,"imfuncname", intermediary_function_name);
      proxyClassFunctionHandler(n);
      Delete(overloaded_name);
    }
    static_flag = false;

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * proxyClassFunctionHandler()
   *
   * Function called for creating a Java wrapper function around a c++ function in the 
   * proxy class. Used for both static and non-static C++ class functions.
   * C++ class static functions map to Java static functions.
   * Two extra attributes in the Node must be available. These are "proxyfuncname" - 
   * the name of the Java class proxy function, which in turn will call "imfuncname" - 
   * the intermediary (JNI) function name in the intermediary class.
   * ----------------------------------------------------------------------------- */

  void proxyClassFunctionHandler(Node *n) {
    SwigType  *t = Getattr(n,"type");
    ParmList  *l = Getattr(n,"parms");
    String    *intermediary_function_name = Getattr(n,"imfuncname");
    String    *proxy_function_name = Getattr(n,"proxyfuncname");
    String    *tm;
    Parm      *p;
    int       i;
    String    *imcall = NewString("");
    String    *return_type = NewString("");
    String    *function_code = NewString("");

    if(!proxy_flag) return;

    if (l) {
      if (SwigType_type(Getattr(l,"type")) == T_VOID) {
        l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("jstype", l, NULL);
    Swig_typemap_attach_parms("javain", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    /* Start generating the proxy function */
    Printf(function_code, "  %s ", Getattr(n,"feature:java:methodmodifiers"));
    if (static_flag)
      Printf(function_code, "static ");
    Printf(function_code, "%s %s(", return_type, proxy_function_name);

    Printv(imcall, imclass_name, ".", intermediary_function_name, "(", NIL);
    if (!static_flag)
      Printv(imcall, "swigCPtr", NIL);

    emit_mark_varargs(l);

    int gencomma = !static_flag;

    /* Output each parameter */
    for (i = 0, p=l; p; i++) {

      /* Ignored varargs */
      if (checkAttribute(p,"varargs:ignore","1")) {
        p = nextSibling(p);
        continue;
      }

      /* Ignored parameters */
      if (checkAttribute(p,"tmap:in:numinputs","0")) {
        p = Getattr(p,"tmap:in:next");
        continue;
      }

      /* Ignore the 'this' argument for variable wrappers */
      if (!(variable_wrapper_flag && i==0)) 
      {
        SwigType *pt = Getattr(p,"type");
        String   *param_type = NewString("");

        /* Get the Java parameter type */
        if ((tm = Getattr(p,"tmap:jstype"))) {
          substituteClassname(pt, tm);
          Printf(param_type, "%s", tm);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
              "No jstype typemap defined for %s\n", SwigType_str(pt,0));
        }

        if (gencomma)
          Printf(imcall, ", ");

        String *arg = makeParameterName(n, p, i);

        // Use typemaps to transform type used in Java proxy wrapper (in proxy class) to type used in JNI function (in intermediary class)
        if ((tm = Getattr(p,"tmap:javain"))) {
          substituteClassname(pt, tm);
          Replaceall(tm, "$javainput", arg);
          Printv(imcall, tm, NIL);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JAVAIN_UNDEF, input_file, line_number, 
              "No javain typemap defined for %s\n", SwigType_str(pt,0));
        }

        /* Add parameter to proxy function */
        if (gencomma >= 2)
          Printf(function_code, ", ");
        gencomma = 2;
        Printf(function_code, "%s %s", param_type, arg);

        Delete(arg);
        Delete(param_type);
      }
      p = Getattr(p,"tmap:in:next");
    }

    Printf(imcall, ")");
    Printf(function_code, ")");
    generateThrowsClause(n, function_code);

    // Transform return type used in JNI function (in intermediary class) to type used in Java wrapper function (in proxy class)
    if ((tm = Swig_typemap_lookup_new("javaout",n,"",0))) {
      if (Getattr(n,"feature:new"))
        Replaceall(tm,"$owner","true");
      else
        Replaceall(tm,"$owner","false");
      substituteClassname(t, tm);
      Replaceall(tm, "$jnicall", imcall);
      Printf(function_code, " %s\n\n", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JAVAOUT_UNDEF, input_file, line_number, 
          "No javaout typemap defined for %s\n", SwigType_str(t,0));
    }

    Printv(proxy_class_code, function_code, NIL);

    Delete(function_code);
    Delete(return_type);
    Delete(imcall);
  }

  /* ----------------------------------------------------------------------
   * constructorHandler()
   * ---------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {

    ParmList *l = Getattr(n,"parms");
    String    *tm;
    Parm      *p;
    int       i;

    Language::constructorHandler(n);

    if(proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *imcall = NewString("");

      Printf(proxy_class_code, "  %s %s(", Getattr(n,"feature:java:methodmodifiers"), proxy_class_name);
      Printv(imcall, "this(", imclass_name, ".", Swig_name_construct(overloaded_name), "(", NIL);

      /* Attach the non-standard typemaps to the parameter list */
      Swig_typemap_attach_parms("in", l, NULL);
      Swig_typemap_attach_parms("jstype", l, NULL);
      Swig_typemap_attach_parms("javain", l, NULL);

      emit_mark_varargs(l);

      int gencomma = 0;

      /* Output each parameter */
      for (i = 0, p=l; p; i++) {

        /* Ignored varargs */
        if (checkAttribute(p,"varargs:ignore","1")) {
          p = nextSibling(p);
          continue;
        }

        /* Ignored parameters */
        if (checkAttribute(p,"tmap:in:numinputs","0")) {
          p = Getattr(p,"tmap:in:next");
          continue;
        }

        SwigType *pt = Getattr(p,"type");
        String   *param_type = NewString("");

        /* Get the Java parameter type */
        if ((tm = Getattr(p,"tmap:jstype"))) {
          substituteClassname(pt, tm);
          Printf(param_type, "%s", tm);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
              "No jstype typemap defined for %s\n", SwigType_str(pt,0));
        }

        if (gencomma)
          Printf(imcall, ", ");

        String *arg = makeParameterName(n, p, i);

        // Use typemaps to transform type used in Java wrapper function (in proxy class) to type used in JNI function (in intermediary class)
        if ((tm = Getattr(p,"tmap:javain"))) {
          substituteClassname(pt, tm);
          Replaceall(tm, "$javainput", arg);
          Printv(imcall, tm, NIL);
        } else {
          Swig_warning(WARN_JAVA_TYPEMAP_JAVAIN_UNDEF, input_file, line_number, 
              "No javain typemap defined for %s\n", SwigType_str(pt,0));
        }

        /* Add parameter to proxy function */
        if(gencomma)
          Printf(proxy_class_code, ", ");
        Printf(proxy_class_code, "%s %s", param_type, arg);
        gencomma = 1;

        Delete(arg);
        Delete(param_type);
        p = Getattr(p,"tmap:in:next");
      }

      Printf(imcall, "), true);\n");

      Printf(proxy_class_code, ")");
      generateThrowsClause(n, proxy_class_code);
      Printf(proxy_class_code, " {\n");
      Printf(proxy_class_code, "    %s", imcall);
      Printf(proxy_class_code, "  }\n\n");

      if(!gencomma)  // We must have a default constructor
        have_default_constructor_flag = true;

      Delete(overloaded_name);
      Delete(imcall);
    }

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * destructorHandler()
   * ---------------------------------------------------------------------- */

  virtual int destructorHandler(Node *n) {
    Language::destructorHandler(n);
    String *symname = Getattr(n,"sym:name");

    if(proxy_flag) {
      Printv(destructor_call, imclass_name, ".", Swig_name_destroy(symname), "(swigCPtr)", NIL);
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * membervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {
    variable_name = Getattr(n,"sym:name");
    wrapping_member_flag = true;
    variable_wrapper_flag = true;
    Language::membervariableHandler(n);
    wrapping_member_flag = false;
    variable_wrapper_flag = false;
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmembervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {
    variable_name = Getattr(n,"sym:name");
    wrapping_member_flag = true;
    static_flag = true;
    Language::staticmembervariableHandler(n);
    wrapping_member_flag = false;
    static_flag = false;
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * memberconstantHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberconstantHandler(Node *n) {
    variable_name = Getattr(n,"sym:name");
    wrapping_member_flag = true;
    Language::memberconstantHandler(n);
    wrapping_member_flag = false;
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * getOverloadedName()
   * ----------------------------------------------------------------------------- */

  String *getOverloadedName(Node *n) {

    /* Although JNI functions are designed to handle overloaded Java functions, a Java long is used for all classes in the SWIG
     * intermediary class. The intermediary class methods are thus mangled when overloaded to give a unique name. */
    String *overloaded_name = NewStringf("%s", Getattr(n,"sym:name"));

    if (Getattr(n,"sym:overloaded")) {
      Printv(overloaded_name, Getattr(n,"sym:overname"), NIL);
    }

    return overloaded_name;
  }

  /* -----------------------------------------------------------------------------
   * moduleClassFunctionHandler()
   * ----------------------------------------------------------------------------- */

  void moduleClassFunctionHandler(Node *n) {
    SwigType  *t = Getattr(n,"type");
    ParmList  *l = Getattr(n,"parms");
    String    *tm;
    Parm      *p;
    int       i;
    String    *imcall = NewString("");
    String    *return_type = NewString("");
    String    *function_code = NewString("");
    int       num_arguments = 0;
    int       num_required = 0;
    String    *overloaded_name = getOverloadedName(n);
    String    *func_name = NULL;
    bool      setter_flag = false;

    if (l) {
      if (SwigType_type(Getattr(l,"type")) == T_VOID) {
        l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("jstype", l, NULL);
    Swig_typemap_attach_parms("javain", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    /* Change function name for global variables */
    if (proxy_flag && global_variable_flag) {
      // Capitalize the first letter in the variable to create a JavaBean type getter/setter function name
      func_name = NewString("");
      setter_flag = (Cmp(Getattr(n,"sym:name"), Swig_name_set(variable_name)) == 0);
      if(setter_flag)
        Printf(func_name,"set");
      else 
        Printf(func_name,"get");
      Putc(toupper((int) *Char(variable_name)), func_name);
      Printf(func_name, "%s", Char(variable_name)+1);
    } else {
      func_name = Copy(Getattr(n,"sym:name"));
    }

    /* Start generating the function */
    Printf(function_code, "  %s static %s %s(", Getattr(n,"feature:java:methodmodifiers"), return_type, func_name);
    Printv(imcall, imclass_name, ".", overloaded_name, "(", NIL);

    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required  = emit_num_required(l);

    int gencomma = 0;

    /* Output each parameter */
    for (i = 0, p=l; i < num_arguments; i++) {

      /* Ignored parameters */
      while (checkAttribute(p,"tmap:in:numinputs","0")) {
        p = Getattr(p,"tmap:in:next");
      }

      SwigType *pt = Getattr(p,"type");
      String   *param_type = NewString("");

      /* Get the Java parameter type */
      if ((tm = Getattr(p,"tmap:jstype"))) {
        substituteClassname(pt, tm);
        Printf(param_type, "%s", tm);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
            "No jstype typemap defined for %s\n", SwigType_str(pt,0));
      }

      if (gencomma)
        Printf(imcall, ", ");

      String *arg = makeParameterName(n, p, i);

      // Use typemaps to transform type used in Java wrapper function (in proxy class) to type used in JNI function (in intermediary class)
      if ((tm = Getattr(p,"tmap:javain"))) {
        substituteClassname(pt, tm);
        Replaceall(tm, "$javainput", arg);
        Printv(imcall, tm, NIL);
      } else {
        Swig_warning(WARN_JAVA_TYPEMAP_JAVAIN_UNDEF, input_file, line_number, 
            "No javain typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Add parameter to module class function */
      if (gencomma >= 2)
        Printf(function_code, ", ");
      gencomma = 2;
      Printf(function_code, "%s %s", param_type, arg);

      p = Getattr(p,"tmap:in:next");
      Delete(arg);
      Delete(param_type);
    }

    Printf(imcall, ")");
    Printf(function_code, ")");
    generateThrowsClause(n, function_code);

    // Transform return type used in JNI function (in intermediary class) to type used in Java wrapper function (in module class)
    if ((tm = Swig_typemap_lookup_new("javaout",n,"",0))) {
      if (Getattr(n,"feature:new"))
        Replaceall(tm,"$owner","true");
      else
        Replaceall(tm,"$owner","false");
      substituteClassname(t, tm);
      Replaceall(tm, "$jnicall", imcall);
      Printf(function_code, " %s\n\n", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JAVAOUT_UNDEF, input_file, line_number, 
          "No javaout typemap defined for %s\n", SwigType_str(t,0));
    }

    Printv(module_class_code, function_code, NIL);

    Delete(function_code);
    Delete(return_type);
    Delete(imcall);
    Delete(func_name);
  }

  /* -----------------------------------------------------------------------------
   * substituteClassname()
   *
   * Substitute $javaclassname with the proxy class name for classes/structs/unions that SWIG knows about.
   * Otherwise use the $descriptor name for the Java class name. Note that the $&javaclassname substitution
   * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - jstype typemap
   * Outputs:
   *   tm - jstype typemap with $javaclassname substitution
   * Return:
   *   substitution_performed - flag indicating if a substitution was performed
   * ----------------------------------------------------------------------------- */

  bool substituteClassname(SwigType *pt, String *tm) {
    bool substitution_performed = false;
    if (Strstr(tm, "$javaclassname") || Strstr(tm,"$&javaclassname")) {
      String *classname = getProxyName(pt);
      if (classname) {
        Replaceall(tm,"$&javaclassname", classname); // getProxyName() works for pointers to classes too
        Replaceall(tm,"$javaclassname", classname);
      }
      else { // use $descriptor if SWIG does not know anything about this type. Note that any typedefs are resolved.
        String *descriptor = NULL;
        SwigType *type = Copy(SwigType_typedef_resolve_all(pt));

        if (Strstr(tm, "$&javaclassname")) {
          SwigType_add_pointer(type);
          descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(type));
          Replaceall(tm, "$&javaclassname", descriptor);
        }
        else { // $javaclassname
          descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(type));
          Replaceall(tm, "$javaclassname", descriptor);
        }

        // Add to hash table so that the type wrapper classes can be created later
        Setattr(swig_types_hash, descriptor, type);
        Delete(descriptor);
        Delete(type);
      }
      substitution_performed = true;
    }
    return substitution_performed;
  }

  /* -----------------------------------------------------------------------------
   * makeParameterName()
   *
   * Inputs: 
   *   n - Node
   *   p - parameter node
   *   arg_num - parameter argument number
   * Return:
   *   arg - a unique parameter name
   * ----------------------------------------------------------------------------- */

  String *makeParameterName(Node *n, Parm *p, int arg_num) {

    // Use C parameter name unless it is a duplicate or an empty parameter name
    String   *pn = Getattr(p,"name");
    int count = 0;
    ParmList *plist = Getattr(n,"parms");
    while (plist) {
      if ((Cmp(pn, Getattr(plist,"name")) == 0))
        count++;
      plist = nextSibling(plist);
    }
    String *arg = (!pn || (count > 1)) ? NewStringf("arg%d",arg_num) : Copy(Getattr(p,"name"));

    return arg;
  }

  /* -----------------------------------------------------------------------------
   * emitTypeWrapperClass()
   * ----------------------------------------------------------------------------- */

  void emitTypeWrapperClass(String *classname, SwigType *type) {
    String *filen = NewStringf("%s%s.java", Swig_file_dirname(outfile), classname);
    File *f_swigtype = NewFile(filen,"w");
    String *swigtype = NewString("");

    // Emit banner and package name
    emitBanner(f_swigtype);
    if(Len(package) > 0)
      Printf(f_swigtype, "package %s;\n\n", package);

    // Pure Java baseclass and interfaces
    const String *pure_baseclass = typemapLookup("javabase", type, WARN_NONE);
    const String *pure_interfaces = typemapLookup("javainterfaces", type, WARN_NONE);

    // Emit the class
    Printv(swigtype,
        typemapLookup("javaimports", type, WARN_NONE), // Import statements
        "\n",
        typemapLookup("javaclassmodifiers", type, WARN_JAVA_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers
        " class $javaclassname",       // Class name and bases
        *Char(pure_baseclass) ?
        " extends " : 
        "",
        pure_baseclass,
        *Char(pure_interfaces) ?  // Interfaces
        " implements " :
        "",
        pure_interfaces,
        " {\n",
        "  private long swigCPtr;\n",
        "\n",
        "  ",
        typemapLookup("javaptrconstructormodifiers", type, WARN_JAVA_TYPEMAP_PTRCONSTMOD_UNDEF), // pointer constructor modifiers
        " $javaclassname(long cPtr, boolean bFutureUse) {\n", // Constructor used for wrapping pointers
        "    swigCPtr = cPtr;\n",
        "  }\n",
        "\n",
        "  protected $javaclassname() {\n", // Default constructor
        "    swigCPtr = 0;\n",
        "  }\n",
        typemapLookup("javagetcptr", type, WARN_JAVA_TYPEMAP_GETCPTR_UNDEF), // getCPtr method
        typemapLookup("javacode", type, WARN_NONE), // extra Java code
        "}\n",
        "\n",
        NIL);

        Replaceall(swigtype, "$javaclassname", classname);
        Printv(f_swigtype, swigtype, NIL);

        Close(f_swigtype);
        Delete(filen);
        Delete(swigtype);
  }

  /* -----------------------------------------------------------------------------
   * typemapLookup()
   * ----------------------------------------------------------------------------- */

  const String *typemapLookup(const String *op, String *type, int warning) {
    String *tm = NULL;
    const String *code = NULL;

    if((tm = Swig_typemap_search(op, type, NULL, NULL))) {
      code = Getattr(tm,"code");
    }

    if (!code) {
      code = empty_string;
      if (warning != WARN_NONE)
        Swig_warning(warning, input_file, line_number, "No %s typemap defined for %s\n", op, type);
    }

    return code ? code : empty_string;
  }

  /* -----------------------------------------------------------------------------
   * addThrows()
   * ----------------------------------------------------------------------------- */

  void addThrows(Node *n, const String *typemap, Node *parameter) {
    // Get the comma separated throws clause - held in "throws" attribute in the typemap passed in
    String *throws_attribute = NewStringf("%s:throws", typemap);
    String *throws = Getattr(parameter,throws_attribute);

    if (throws) {
      String *throws_list = Getattr(n,"java:throwslist");
      if (!throws_list) {
        throws_list = NewList();
        Setattr(n,"java:throwslist", throws_list);
      }

      // Put the exception classes in the throws clause into a temporary List
      List *temp_classes_list = Split(throws,',',INT_MAX);

      // Add the exception classes to the node throws list, but don't duplicate if already in list
      if (temp_classes_list && Len(temp_classes_list) > 0) {
        for (String *cls = Firstitem(temp_classes_list); cls; cls = Nextitem(temp_classes_list)) {
          String *exception_class = NewString(cls);
          Replaceall(exception_class," ","");  // remove spaces
          Replaceall(exception_class,"\t",""); // remove tabs
          if (Len(exception_class) > 0) {
            // $javaclassname substitution
            SwigType *pt = Getattr(parameter,"type");
            substituteClassname(pt, exception_class);

            // Don't duplicate the Java exception class in the throws clause
            bool found_flag = false;
            for (String *item = Firstitem(throws_list); item; item = Nextitem(throws_list)) {
              if (Strcmp(item, exception_class) == 0)
                found_flag = true;
            }
            if (!found_flag)
              Append(throws_list, exception_class);
          }
          Delete(exception_class);
        } 
      }
      Delete(temp_classes_list);
    } 
    Delete(throws_attribute);
  }

  /* -----------------------------------------------------------------------------
   * generateThrowsClause()
   * ----------------------------------------------------------------------------- */

  void generateThrowsClause(Node *n, String *code) {
    // Add the throws clause into code
    List *throws_list = Getattr(n,"java:throwslist");
    if (throws_list) {
      String *cls = Firstitem(throws_list);
      Printf(code, " throws %s", cls);
      while ( (cls = Nextitem(throws_list)) )
        Printf(code, ", %s", cls);
    }
  }

};   /* class JAVA */

/* -----------------------------------------------------------------------------
 * swig_java()    - Instantiate module
 * ----------------------------------------------------------------------------- */

extern "C" Language *
swig_java(void) {
  return new JAVA();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *JAVA::usage = (char*)"\
Java Options (available with -java)\n\
     -package <name> - set name of the Java package\n\
     -noproxy        - Generate the low-level functional interface instead of proxy classes\n\
\n";


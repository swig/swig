/* -----------------------------------------------------------------------------
 * java.cxx
 *
 *     Java wrapper module.
 *
 * Copyright (C) 1999-2002.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

#include <ctype.h>

#include "swigmod.h"

class JAVA : public Language {
  static const char *usage;
  const  String *empty_string;

  Hash   *swig_types_hash;
  File   *f_runtime;
  File   *f_header;
  File   *f_wrappers;
  File   *f_init;

  bool   proxy_flag; // Flag for generating shadow classes
  bool   have_default_constructor_flag;
  bool   native_function_flag;     // Flag for when wrapping a native function
  bool   enum_constant_flag; // Flag for when wrapping an enum or constant
  bool   static_flag; // Flag for when wrapping a static functions or member variables
  bool   variable_wrapper_flag; // Flag for when wrapping a nonstatic member variable
  bool   wrapping_member_flag; // Flag for when wrapping a member variable/enum/const
  bool   global_variable_flag; // Flag for when wrapping a global variable

  String *jniclass;  // JNI class name
  String *module_class_name;  // module class name
  String *jniclass_class_code; // JNI class Java code - that is the native methods
  String *shadow_classdef;
  String *shadow_code;
  String *module_class_code;
  String *shadow_classname;
  String *variable_name; //Name of a variable being wrapped
  String *shadow_constants_code;
  String *module_constants_code;
  String *package; // Package name
  String *jnipackage; // JNI package name
  String *jniclass_imports; //jniclass import from %pragma
  String *module_imports; //module imports from %pragma
  String *jniclass_baseclass; //inheritance for jniclass class from %pragma
  String *module_baseclass; //inheritance for module class from %pragma
  String *jniclass_interfaces; //interfaces for jniclass class from %pragma
  String *module_interfaces; //interfaces for module class from %pragma
  String *jniclass_class_modifiers; //class modifiers for jniclass class overriden by %pragma
  String *module_class_modifiers; //class modifiers for module class overriden by %pragma
  String *wrapper_conversion_code; //C++ casts for inheritance hierarchies JNI code
  String *jniclass_cppcasts_code; //C++ casts up inheritance hierarchies JNI class Java code
  String *destructor_call; //Destructor (delete) call if any

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

    jniclass(NULL),
    module_class_name(NULL),
    jniclass_class_code(NULL),
    shadow_classdef(NULL),
    shadow_code(NULL),
    module_class_code(NULL),
    shadow_classname(NULL),
    variable_name(NULL),
    shadow_constants_code(NULL),
    module_constants_code(NULL),
    package(NULL),
    jnipackage(NULL),
    jniclass_imports(NULL),
    module_imports(NULL),
    jniclass_baseclass(NULL),
    module_baseclass(NULL),
    jniclass_interfaces(NULL),
    module_interfaces(NULL),
    jniclass_class_modifiers(NULL),
    module_class_modifiers(NULL),
    wrapper_conversion_code(NULL),
    jniclass_cppcasts_code(NULL),
    destructor_call(NULL)

    {
    }

  /* -----------------------------------------------------------------------------
   * is_shadow()
   *
   * Test to see if a type corresponds to something wrapped with a shadow/proxy class
   * Return NULL if not otherwise the shadow name
   * ----------------------------------------------------------------------------- */

  String *is_shadow(SwigType *t) {
    if (proxy_flag) {
      Node *n = classLookup(t);
      if (n) {
        if (!Getattr(n,"java:addedtypemaps")) addClassTypemaps(n);
        return Getattr(n,"java:proxy");
      }
    }
    return NULL;
  }

  /* -----------------------------------------------------------------------------
   * getArrayType()
   *
   * Return the type of the c array
   * ----------------------------------------------------------------------------- */

  SwigType *getArrayType(SwigType *t) {
    SwigType *ta = NULL;
    if (SwigType_isarray(t)) {
      SwigType *aop;
      ta = Copy(t);
      aop = SwigType_pop(ta);
    }
    return ta;
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
          Printf(stderr,"Deprecated command line option: -nofinalize. Use the new javafinalize typemaps instead.\n");
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
    String *outfile = Getattr(n,"outfile");

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

    jniclass = NewStringf("%sJNI", Getattr(n,"name"));
    jniclass_class_code = NewString("");
    shadow_classdef = NewString("");
    shadow_code = NewString("");
    module_constants_code = NewString("");
    jniclass_baseclass = NewString("");
    jniclass_interfaces = NewString("");
    jniclass_class_modifiers = NewString(""); // package access only to the JNI class by default
    module_class_name = Copy(Getattr(n,"name"));
    module_class_code = NewString("");
    module_baseclass = NewString("");
    module_interfaces = NewString("");
    module_imports = NewString("");
    module_class_modifiers = NewString("public");
    jniclass_imports = NewString("");
    jniclass_cppcasts_code = NewString("");
    wrapper_conversion_code = NewString("");
    if (!package) package = NewString("");
    jnipackage = NewString("");

    Swig_banner(f_runtime);               // Print the SWIG banner message

    if (NoInclude) {
      Printf(f_runtime,"#define SWIG_NOINCLUDE\n");
    }

    String *wrapper_name = NewString("");

    if(Len(package)) {
      String *jniname = makeValidJniName(package);
      Printv(jnipackage, jniname, NULL);
      Delete(jniname);
      Replaceall(jnipackage,".","_");
      Append(jnipackage, "_");
    }
    String *jniname = makeValidJniName(jniclass);
    Printf(wrapper_name, "Java_%s%s_%%f", Char(jnipackage), jniname);
    Delete(jniname);

    Swig_name_register((char*)"wrapper", Char(wrapper_name));
    Swig_name_register((char*)"set", (char*)"set_%v");
    Swig_name_register((char*)"get", (char*)"get_%v");
    Swig_name_register((char*)"member", (char*)"%c_%m");

    Delete(wrapper_name);

    Printf(f_wrappers,"#ifdef __cplusplus\n");
    Printf(f_wrappers,"extern \"C\" {\n");
    Printf(f_wrappers,"#endif\n");

    /* Emit code */
    Language::top(n);

    // Generate the Java JNI class
    {
      String *filen = NewStringf("%s.java", jniclass);
      File *f_java = NewFile(filen,"w");
      if(!f_java) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the Java JNI class
      if(Len(package) > 0)
        Printf(f_java, "package %s;\n\n", package);

      emitBanner(f_java);
      if(jniclass_imports)
        Printf(f_java, "%s\n", jniclass_imports);

      if (Len(jniclass_class_modifiers) > 0)
        Printf(f_java, "%s ", jniclass_class_modifiers);
      Printf(f_java, "class %s ", jniclass);

      if (jniclass_baseclass && *Char(jniclass_baseclass))
        Printf(f_java, "extends %s ", jniclass_baseclass);
      if (Len(jniclass_interfaces) > 0)
        Printv(f_java, "implements ", jniclass_interfaces, " ", NULL);
      Printf(f_java, "{\n");

      // Add the native methods
      Printv(f_java, jniclass_class_code, NULL);
      Printv(f_java, jniclass_cppcasts_code, NULL);

      // Finish off the Java class
      Printf(f_java, "}\n");
      Close(f_java);
    }

    // Generate the Java module class
    {
      String *filen = NewStringf("%s.java", module_class_name);
      File *f_module = NewFile(filen,"w");
      if(!f_module) {
        Printf(stderr,"Unable to open %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      // Start writing out the Java module class
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
      if (Len(module_interfaces) > 0)
        Printv(f_module, "implements ", module_interfaces, " ", NULL);
      Printf(f_module, "{\n");

      // Add the wrapper methods
      Printv(f_module, module_class_code, NULL);

      // Write out all the enums constants
      if (Len(module_constants_code) != 0 )
        Printv(f_module, "  // enums and constants\n", module_constants_code, NULL);

      // Finish off the Java class
      Printf(f_module, "}\n");
      Close(f_module);
    }

    if(wrapper_conversion_code)
      Printv(f_wrappers,wrapper_conversion_code,NULL);

    Printf(f_wrappers,"#ifdef __cplusplus\n");
    Printf(f_wrappers,"}\n");
    Printf(f_wrappers,"#endif\n");

    // Output a Java class for each SWIG type
    for (String *swig_type = Firstkey(swig_types_hash); swig_type; swig_type = Nextkey(swig_types_hash)) {
      emitJavaClass(swig_type, Getattr(swig_types_hash, swig_type));
    }

    Delete(swig_types_hash); swig_types_hash = NULL;
    Delete(jniclass_class_code); jniclass_class_code = NULL;
    Delete(shadow_classdef); shadow_classdef = NULL;
    Delete(shadow_code); shadow_code = NULL;
    Delete(module_constants_code); module_constants_code = NULL;
    Delete(jniclass_baseclass); jniclass_baseclass = NULL;
    Delete(jniclass_interfaces); jniclass_interfaces = NULL;
    Delete(jniclass_class_modifiers); jniclass_class_modifiers = NULL;
    Delete(module_class_name); module_class_name = NULL;
    Delete(module_class_code); module_class_code = NULL;
    Delete(module_baseclass); module_baseclass = NULL;
    Delete(module_interfaces); module_interfaces = NULL;
    Delete(module_imports); module_imports = NULL;
    Delete(module_class_modifiers); module_class_modifiers = NULL;
    Delete(jniclass_imports); jniclass_imports = NULL;
    Delete(jniclass_cppcasts_code); jniclass_cppcasts_code = NULL;
    Delete(wrapper_conversion_code); wrapper_conversion_code = NULL;
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
    Printf(f, " * Version: %s\n", SWIG_VERSION);
    Printf(f, " *\n");
    Printf(f, " * Do not make changes to this file unless you know what you are doing--modify\n");
    Printf(f, " * the SWIG interface file instead.\n");
    Printf(f, " * ----------------------------------------------------------------------------- */\n\n");
  }

  /* ----------------------------------------------------------------------
   * nativeWrapper()
   * ---------------------------------------------------------------------- */

  virtual int nativeWrapper(Node *n) {

    if (Getattr(n,"type")) {
      Swig_save(&n,"name",NULL);
      Setattr(n,"name", Getattr(n,"wrap:name"));
      native_function_flag = true;
      functionWrapper(n);
      Swig_restore(&n);
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
    Parm      *jnip;
    Parm      *jtypep;
    int       i;
    String    *jnirettype = NewString("");
    String    *javarettype = NewString("");
    String    *cleanup = NewString("");
    String    *outarg = NewString("");
    String    *body = NewString("");
    String    *javaParameterSignature = NewString("");
    int       num_arguments = 0;
    int       num_required = 0;
    String    *overloaded_name = getOverloadedName(n);

    /* This is a gross hack.  To get typemaps properly installed, we have to check for
       shadows on all types first */

    if (proxy_flag) {
      is_shadow(t);
      for (p = l; p; p = nextSibling(p)) {
        is_shadow(Getattr(p,"type"));
      }
    }

    /* 
       Generate the java class wrapper function ie the java shadow class. Only done for public
       member variables. That is this generates the getters/setters for member variables.
       Not for enums and constants.
       */
    if(proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Capitalize the first letter in the variable to create a JavaBean type getter/setter function name
      String *getter_setter_name = NewString("");
      if(Cmp(symname, Swig_name_set(Swig_name_member(shadow_classname, variable_name))) == 0)
        Printf(getter_setter_name,"set");
      else 
        Printf(getter_setter_name,"get");
      Putc(toupper((int) *Char(variable_name)), getter_setter_name);
      Printf(getter_setter_name, "%s", Char(variable_name)+1);

      Setattr(n,"java:shadowfuncname", getter_setter_name);
      Setattr(n,"java:funcname", symname);

      javaShadowFunctionHandler(n);

      Delete(getter_setter_name);
    }

    /*
       The rest of this function deals with generating the java wrapper function (that wraps
       a c/c++ function) and generating the JNI c code. Each java wrapper function has a 
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

    /* Get Java return types */
    if ((tm = Swig_typemap_lookup_new("jni",n,"",0))) {
      Printf(jnirettype,"%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JNI_UNDEF, input_file, line_number, 
          "No jni typemap defined for %s\n", SwigType_str(t,0));
    }

    if ((tm = Swig_typemap_lookup_new("jtype",n,"",0))) {
      Printf(javarettype,"%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JTYPE_UNDEF, input_file, line_number, 
          "No jtype typemap defined for %s\n", SwigType_str(t,0));
    }

    if (SwigType_type(t) != T_VOID) {
      Wrapper_add_localv(f,"jresult", jnirettype, "jresult = 0",NULL);
    }

    Printf(jniclass_class_code, "  public final static native %s %s(", javarettype, overloaded_name);

    Printv(f->def, "JNIEXPORT ", jnirettype, " JNICALL ", wname, "(JNIEnv *jenv, jclass jcls", NULL);

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
    for (i = 0, p=l, jnip=l, jtypep=l; i < num_arguments; i++) {

      while (Getattr(p,"tmap:ignore")) {
        p = Getattr(p,"tmap:ignore:next");
      }
      while (Getattr(jnip,"tmap:ignore")) {
        jnip = Getattr(jnip,"tmap:ignore:next");
      }
      while (Getattr(jtypep,"tmap:ignore")) {
        jtypep = Getattr(jtypep,"tmap:ignore:next");
      }

      SwigType *pt = Getattr(p,"type");
      String   *ln = Getattr(p,"lname");
      String   *javaparamtype = NewString("");
      String   *jni_param_type = NewString("");
      String   *arg = NewString("");

      Printf(arg,"j%s", ln);

      /* Get the jni types of the parameter */
      if ((tm = Getattr(jnip,"tmap:jni"))) {
        jnip = Getattr(jnip,"tmap:jni:next");
        Printv(jni_param_type, tm, NULL);
      } else {
        jnip = nextSibling(jnip);
        Swig_warning(WARN_JAVA_TYPEMAP_JNI_UNDEF, input_file, line_number, 
            "No jni typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Get the java types of the parameter */
      if ((tm = Getattr(jtypep,"tmap:jtype"))) {
        jtypep = Getattr(jtypep,"tmap:jtype:next");
        Printv(javaparamtype, tm, NULL);
      } else {
        jtypep = nextSibling(jtypep);
        Swig_warning(WARN_JAVA_TYPEMAP_JTYPE_UNDEF, input_file, line_number, 
            "No jtype typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Add to java function header */
      if(gencomma) Printf(jniclass_class_code, ", ");
      Printf(jniclass_class_code, "%s %s", javaparamtype, arg);

      gencomma = 1;

      // Add to Jni function header
      Printv(f->def, ", ", jni_param_type, " ", arg, NULL);

      // Get typemap for this argument
      if ((tm = Getattr(p,"tmap:in"))) {
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
      Delete(javaparamtype);
      Delete(jni_param_type);
      Delete(arg);
    }

    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:check"))) {
        Replaceall(tm,"$target",Getattr(p,"lname")); /* deprecated */
        Replaceall(tm,"$arg",Getattr(p,"emit:input")); /* deprecated? */
        Replaceall(tm,"$input",Getattr(p,"emit:input"));
        Printv(f->code,tm,"\n",NULL);
        p = Getattr(p,"tmap:check:next");
      } else {
        p = nextSibling(p);
      }
    }

    /* Insert cleanup code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:freearg"))) {
        Replaceall(tm,"$source",Getattr(p,"emit:input")); /* deprecated */
        Replaceall(tm,"$arg",Getattr(p,"emit:input")); /* deprecated? */
        Replaceall(tm,"$input",Getattr(p,"emit:input"));
        Printv(cleanup,tm,"\n",NULL);
        p = Getattr(p,"tmap:freearg:next");
      } else {
        p = nextSibling(p);
      }
    }

    /* Insert argument output code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:argout"))) {
        Replaceall(tm,"$source",Getattr(p,"emit:input")); /* deprecated */
        Replaceall(tm,"$target",Getattr(p,"lname")); /* deprecated */
        Replaceall(tm,"$arg",Getattr(p,"emit:input")); /* deprecated? */
        Replaceall(tm,"$result","jresult");
        Replaceall(tm,"$input",Getattr(p,"emit:input"));
        Printv(outarg,tm,"\n",NULL);
        p = Getattr(p,"tmap:argout:next");
      } else {
        p = nextSibling(p);
      }
    }

    Printf(jniclass_class_code, ");\n");
    Printf(f->def,") {");

    if (Cmp(nodeType(n), "constant") == 0) {
      // Wrapping a constant hack
      Swig_save(&n,"wrap:action",NULL);

      // below based on Swig_VargetToFunction()
      SwigType *ty = Swig_wrapped_var_type(Getattr(n,"type"));
      Setattr(n,"wrap:action", NewStringf("result = (%s) %s;\n", SwigType_lstr(ty,0), Getattr(n, "value")));
    }

    // Now write code to make the function call
    if(!native_function_flag)
      emit_action(n,f);

    if (Cmp(nodeType(n), "constant") == 0)
      Swig_restore(&n);

    /* Return value if necessary  */
    if((SwigType_type(t) != T_VOID) && !native_function_flag) {
      if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
        Replaceall(tm,"$source", "result"); /* deprecated */
        Replaceall(tm,"$target", "jresult"); /* deprecated */
        Replaceall(tm,"$result","jresult");
        Printf(f->code,"%s\n", tm);
      } else {
        Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
            "Unable to use return type %s in function %s.\n", SwigType_str(t,0), Getattr(n,"name"));
      }
    }

    /* Output argument output code */
    Printv(f->code,outarg,NULL);

    /* Output cleanup code */
    Printv(f->code,cleanup,NULL);

    /* Look to see if there is any newfree cleanup code */
    if (NewObject || (Getattr(n,"feature:new"))) {
      if ((tm = Swig_typemap_lookup_new("newfree",n,"result",0))) {
        Replaceall(tm,"$source","result"); /* deprecated */
        Printf(f->code,"%s\n",tm);
      }
    }

    /* See if there is any return cleanup code */
    if((SwigType_type(t) != T_VOID) && !native_function_flag) {
      if ((tm = Swig_typemap_lookup_new("ret", n, "result", 0))) {
        Replaceall(tm,"$source","result"); /* deprecated */
        Printf(f->code,"%s\n",tm);
      }
    }

    if(SwigType_type(t) != T_VOID)
      Printv(f->code, "    return jresult;\n", NULL);
    Printf(f->code, "}\n");

    /* Substitute the cleanup code */
    Replaceall(f->code,"$cleanup",cleanup);

    if(SwigType_type(t) != T_VOID)
      Replaceall(f->code,"$null","0");
    else
      Replaceall(f->code,"$null","");

    /* Dump the function out */
    if(!native_function_flag)
      Wrapper_print(f,f_wrappers);

    /* Emit warnings for the few cases that can't be overloaded in Java */
    if (Getattr(n,"sym:overloaded")) {
      if (!Getattr(n,"sym:nextSibling"))
        Swig_overload_rank(n);
    }

    if(!(proxy_flag && is_wrapping_class()) && !enum_constant_flag) {
      jniclassFunctionHandler(n);
    }

    Delete(jnirettype);
    Delete(javarettype);
    Delete(cleanup);
    Delete(outarg);
    Delete(body);
    Delete(javaParameterSignature);
    Delete(overloaded_name);
    DelWrapper(f);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * variableWrapper()
   *
   * Create a JAVA link to a C variable.
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
   * enumDeclaration()
   * ------------------------------------------------------------------------ */

  virtual int enumDeclaration(Node *n) {
    String *name = Getattr(n,"sym:name");
    String *s1 = NewStringf("enum %s", name);
    String *s2 = NewStringf("%s", name);
    String *swigtype = NewString("enum SWIGTYPE");

    /* Apply typemaps for handling arrays of enums and arrays of enum pointers for all known enums*/
    typemapApply(swigtype, NULL, s1, none, true);    //%apply enum SWIGTYPE[ANY] {enum name[ANY]};
    typemapApply(swigtype, NULL, s2, none, true);    //%apply enum SWIGTYPE[ANY] {name[ANY]};

    int ret = Language::enumDeclaration(n);

    Delete(s1);
    Delete(s2);
    Delete(swigtype);

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
    String *shadowrettype = NewString("");
    String *constants_code = NewString("");

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("jstype", l, NULL);

    /* Get Java return types */
    bool is_return_type_java_class = false;
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      is_return_type_java_class = substituteJavaclassname(t, tm);
      Printf(shadowrettype, "%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    // Add the stripped quotes back in
    String *new_value = NewString("");
    Swig_save(&n,"value",NULL);
    if(SwigType_type(t) == T_STRING) {
      Printf(new_value, "\"%s\"", Copy(Getattr(n, "value")));
      Setattr(n, "value", new_value);
    }
    else if(SwigType_type(t) == T_CHAR) {
      Printf(new_value, "\'%s\'", Copy(Getattr(n, "value")));
      Setattr(n, "value", new_value);
    }

    // enums are wrapped using a public final static int in java.
    // Other constants are wrapped using a public final static [jstype] in Java.
    Printf(constants_code, "  public final static %s %s = ", shadowrettype, ((proxy_flag && wrapping_member_flag) ? variable_name : symname));

    // The %javaconst directive determines how the constant value is obtained
    String *javaconst = Getattr(n,"feature:java:const");
    if (Cmp(nodeType(n), "enumitem") == 0 || !javaconst || Cmp(javaconst, "0") == 0) {
      // Enums and default constant handling will work with any type of C constant and initialises the Java variable from C through a JNI call.

      if(is_return_type_java_class) // This handles function pointers using the %constant directive
        Printf(constants_code, "new %s(%s.%s(), false);\n", shadowrettype, jniclass, Swig_name_get(symname));
      else
        Printf(constants_code, "%s.%s();\n", jniclass, Swig_name_get(symname));

      // Each constant and enum value is wrapped with a separate JNI function call
      enum_constant_flag = true;
      variableWrapper(n);
      enum_constant_flag = false;
    } else {
      // Alternative constant handling will use the C syntax to make a true Java constant and hope that it compiles as Java code
      Printf(constants_code, "%s;\n", Getattr(n,"value"));
    }

    if(proxy_flag && wrapping_member_flag)
      Printv(shadow_constants_code, constants_code, NULL);
    else
      Printv(module_constants_code, constants_code, NULL);

    Swig_restore(&n);
    Delete(new_value);
    Delete(shadowrettype);
    Delete(constants_code);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * pragmaDirective()
   *
   * Valid Pragmas:
   * jniclassbase            - base (extends) for the jniclass
   * jniclassclassmodifiers  - class modifiers for the jniclass
   * jniclasscode            - text (java code) is copied verbatim to the jniclass
   * jniclassimports         - import statements for the jniclass
   * jniclassinterfaces      - interface (implements) for the jniclass
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
          Delete(jniclass_baseclass);
          jniclass_baseclass = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclassclassmodifiers") == 0) {
          Delete(jniclass_class_modifiers);
          jniclass_class_modifiers = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclasscode") == 0) {
          Printf(jniclass_class_code, "%s\n", strvalue);
        } 
        else if(Strcmp(code, "jniclassimports") == 0) {
          Delete(jniclass_imports);
          jniclass_imports = Copy(strvalue);
        } 
        else if(Strcmp(code, "jniclassinterfaces") == 0) {
          Delete(jniclass_interfaces);
          jniclass_interfaces = Copy(strvalue);
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
   * emitShadowClassDefAndCPPCasts()
   * ----------------------------------------------------------------------------- */

  void emitShadowClassDefAndCPPCasts(Node *n) {
    String *c_classname = SwigType_namestr(Getattr(n,"name"));
    String *c_baseclass = NULL;
    String *baseclass = NULL;
    String *c_baseclassname = NULL;

    /* Deal with inheritance */
    List *baselist = Getattr(n,"bases");
    if (baselist) {
      Node *base = Firstitem(baselist);
      c_baseclassname = Getattr(base,"name");
      baseclass = Copy(is_shadow(c_baseclassname));
      if (baseclass){
        c_baseclass = SwigType_namestr(Getattr(base,"name"));
      }
      base = Nextitem(baselist);
      if (base) {
        Swig_warning(WARN_JAVA_MULTIPLE_INHERITANCE, input_file, line_number, 
            "Warning for %s: Base %s ignored. Multiple inheritance is not supported in Java.\n", shadow_classname, Getattr(base,"name"));
      }
    }

    bool derived = baseclass && is_shadow(c_baseclassname); 
    if (!baseclass)
      baseclass = NewString("");

    // Inheritance from pure Java classes
    const String *pure_java_baseclass = javaTypemapLookup("javabase", shadow_classname, WARN_NONE);
    if (Len(pure_java_baseclass) > 0 && Len(baseclass) > 0) {
      Swig_warning(WARN_JAVA_MULTIPLE_INHERITANCE, input_file, line_number, 
          "Warning for %s: Base %s ignored. Multiple inheritance is not supported in Java.\n", shadow_classname, pure_java_baseclass);
    }

    // Pure Java interfaces
    const String *pure_java_interfaces = javaTypemapLookup("javainterfaces", shadow_classname, WARN_NONE);

    // Start writing the shadow class
    Printv(shadow_classdef,
        javaTypemapLookup("javaimports", shadow_classname, WARN_NONE), // Import statements
        "\n",
        javaTypemapLookup("javaclassmodifiers", shadow_classname, WARN_JAVA_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers
        " class $javaclassname",       // Class name and bases
        (derived || *Char(pure_java_baseclass)) ?
        " extends " : 
        "",
        baseclass,
        pure_java_baseclass,
        *Char(pure_java_interfaces) ?  // Pure Java interfaces
        " implements " :
        "",
        pure_java_interfaces,
        " {\n",
        "  private long swigCPtr;\n",  // Member variables for memory handling
        derived ? 
        "" : 
        "  protected boolean swigCMemOwn;\n",
        "\n",
        "  protected $javaclassname(long cPtr, boolean cMemoryOwn) {\n", // Constructor used for wrapping pointers
        derived ? 
        "    super($jniclass.SWIG$javaclassnameTo$baseclass(cPtr), cMemoryOwn);\n" : 
        "    swigCMemOwn = cMemoryOwn;\n",
        "    swigCPtr = cPtr;\n",
        "  }\n",
        NULL);

    if(!have_default_constructor_flag) { // All Java classes need a constructor
      Printv(shadow_classdef, 
          "\n",
          "  protected $javaclassname() {\n",
          "    this(0, false);\n", 
          "  }\n",
          NULL);
    }

    Printv(shadow_classdef, 
        javaTypemapLookup("javafinalize", shadow_classname, WARN_NONE), // finalize method
        "\n",
        *Char(destructor_call) ? 
        "  public void _delete() {\n" :
        "  protected void _delete() {\n",
        "    if(swigCPtr != 0 && swigCMemOwn) {\n",
        destructor_call,
        "",
        "      swigCMemOwn = false;\n",
        derived ?    // Zero all pointers up any inheritance hierarchy
        "      super._delete();\n" : 
        "",
        "    }\n",
        "    swigCPtr = 0;\n",
        "  }\n",
        javaTypemapLookup("javagetcptr", shadow_classname, WARN_JAVA_TYPEMAP_GETCPTR_UNDEF), // getCPtr method
        javaTypemapLookup("javacode", shadow_classname, WARN_NONE), // extra Java code
        "\n",
        NULL);

    // Substitute various strings into the above template
    Replaceall(shadow_code,     "$javaclassname", shadow_classname);
    Replaceall(shadow_classdef, "$javaclassname", shadow_classname);

    Replaceall(shadow_classdef, "$baseclass", baseclass);
    Replaceall(shadow_code,     "$baseclass", baseclass);

    Replaceall(shadow_classdef, "$jniclass", jniclass);
    Replaceall(shadow_code,     "$jniclass", jniclass);

    // Add JNI code to do C++ casting to base class (only for classes in an inheritance hierarchy)
    if(derived){
      Printv(jniclass_cppcasts_code,"  public final static native long ",
          "SWIG$javaclassnameTo$baseclass(long jarg1);\n",
          NULL);

      Replaceall(jniclass_cppcasts_code, "$javaclassname", shadow_classname);
      Replaceall(jniclass_cppcasts_code, "$baseclass", baseclass);

      Printv(wrapper_conversion_code,
          "JNIEXPORT jlong JNICALL Java_$jnipackage$jnijniclass_SWIG$jniclazznameTo$jnibaseclass",
          "(JNIEnv *jenv, jclass jcls, jlong jarg1) {\n",
          "    jlong baseptr = 0;\n"
          "    *($cbaseclass **)&baseptr = ($cclass *)*(void**)&jarg1;\n"
          "    return baseptr;\n"
          "}\n",
          "\n",
          NULL); 

      String *jnijniclass  = makeValidJniName(jniclass);
      String *jniclazzname = makeValidJniName(shadow_classname);
      String *jnibaseclass = makeValidJniName(baseclass);
      Replaceall(wrapper_conversion_code, "$jnibaseclass",jnibaseclass);
      Replaceall(wrapper_conversion_code, "$cbaseclass",  c_baseclass);
      Replaceall(wrapper_conversion_code, "$jniclazzname",jniclazzname);
      Replaceall(wrapper_conversion_code, "$cclass",      c_classname);
      Replaceall(wrapper_conversion_code, "$jnipackage",  jnipackage);
      Replaceall(wrapper_conversion_code, "$jnijniclass", jnijniclass);

      /*
         if (!proxy_flag) {
         Printv(module_class_code, 
         "  public static $baseclass SWIG$javaclassnameTo$baseclass($javaclassname obj) {\n",
         "    return new $baseclass($jniclass.SWIG$javaclassnameTo$baseclass($javaclassname.getCPtr(obj)), false);\n",
         "  }\n",
         "\n",
         NULL);

         Replaceall(module_class_code, "$baseclass",   baseclass);
         Replaceall(module_class_code, "$javaclassname",       shadow_classname);
         Replaceall(module_class_code, "$jniclass",    jniclass);
         }
      */

      Delete(jnibaseclass);
      Delete(jniclazzname);
      Delete(jnijniclass);
    }
    Delete(baseclass);
  }

  /* ----------------------------------------------------------------------
   * classHandler()
   * ---------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {

    File *f_shadow = NULL;
    if (proxy_flag) {
      shadow_classname = NewString(Getattr(n,"sym:name"));

      if (Cmp(shadow_classname, jniclass) == 0) {
        Printf(stderr, "Class name cannot be equal to JNI class name: %s\n", shadow_classname);
        SWIG_exit(EXIT_FAILURE);
      }

      if (Cmp(shadow_classname, module_class_name) == 0) {
        Printf(stderr, "Class name cannot be equal to module class name: %s\n", shadow_classname);
        SWIG_exit(EXIT_FAILURE);
      }

      String *filen = NewStringf("%s.java", shadow_classname);
      f_shadow = NewFile(filen,"w");
      if(!f_shadow) {
        Printf(stderr, "Unable to create shadow class file: %s\n", filen);
        SWIG_exit(EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      emitBanner(f_shadow);

      if(Len(package) > 0)
        Printf(f_shadow, "package %s;\n\n", package);

      Clear(shadow_classdef);
      Clear(shadow_code);

      have_default_constructor_flag = false;
      destructor_call = NewString("");
      shadow_constants_code = NewString("");
    }
    Language::classHandler(n);

    if (proxy_flag) {

      emitShadowClassDefAndCPPCasts(n);

      Printv(f_shadow, shadow_classdef, shadow_code, NULL);

      // Write out all the enums and constants
      if (Len(shadow_constants_code) != 0 )
        Printv(f_shadow, "  // enums and constants\n", shadow_constants_code, NULL);

      Printf(f_shadow, "}\n");
      Close(f_shadow);
      f_shadow = NULL;

      Delete(shadow_classname); shadow_classname = NULL;
      Delete(destructor_call); destructor_call = NULL;
      Delete(shadow_constants_code); shadow_constants_code = NULL;
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
      String *java_function_name = Swig_name_member(shadow_classname, overloaded_name);
      Setattr(n,"java:shadowfuncname", Getattr(n, "sym:name"));
      Setattr(n,"java:funcname", java_function_name);
      javaShadowFunctionHandler(n);
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
      String *java_function_name = Swig_name_member(shadow_classname, overloaded_name);
      Setattr(n,"java:shadowfuncname", Getattr(n,"sym:name"));
      Setattr(n,"java:funcname", java_function_name);
      javaShadowFunctionHandler(n);
      Delete(overloaded_name);
    }
    static_flag = false;

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * javaShadowFunctionHandler()
   *
   * Function called for creating a java class wrapper function around a c++ function in the 
   * java wrapper class. Used for both static and non static functions.
   * C++ static functions map to java static functions.
   * Two extra attributes in the Node must be available. These are "java:shadowfuncname" - the name of the java class shadow 
   * function, which in turn will call "java:funcname" - the java native function name which wraps the c++ function.
   * ----------------------------------------------------------------------------- */

  void javaShadowFunctionHandler(Node *n) {
    SwigType  *t = Getattr(n,"type");
    ParmList  *l = Getattr(n,"parms");
    String    *java_function_name = Getattr(n,"java:funcname");
    String    *java_shadow_function_name = Getattr(n,"java:shadowfuncname");
    String    *tm;
    Parm      *jstypep;
    Parm      *p;
    int       i;
    String    *nativecall = NewString("");
    String    *shadowrettype = NewString("");
    String    *user_arrays = NewString("");
    int       num_arguments = 0;
    int       num_required = 0;

    if(!proxy_flag) return;

    if (l) {
      if (SwigType_type(Getattr(l,"type")) == T_VOID) {
        l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("jstype", l, NULL);
    Swig_typemap_attach_parms("ignore", l, NULL);

    /* Get Java return types */
    bool is_return_type_java_class = false;
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      is_return_type_java_class = substituteJavaclassname(t, tm);
      Printf(shadowrettype, "%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    Printf(shadow_code, "  %s ", Getattr(n,"feature:java:methodmodifiers"));
    if (static_flag)
      Printf(shadow_code, "static ");
    Printf(shadow_code, "%s %s(", shadowrettype, java_shadow_function_name);

    if(SwigType_isarray(t) && is_shadow(getArrayType(t))) {
      Printf(nativecall, "long[] cArray = ");
    }
    else {
      if(SwigType_type(t) != T_VOID)
        Printf(nativecall,"return ");
      if(is_return_type_java_class)
        Printv(nativecall, "new ", shadowrettype, "(", NULL);
    }

    Printv(nativecall, jniclass, ".", java_function_name, "(", NULL);
    if (!static_flag)
      Printv(nativecall, "swigCPtr", NULL);

    int gencomma = !static_flag;

    /* Output each parameter */
    for (i = 0, p=l, jstypep=l; p && jstypep; i++) {

      /* Ignored parameters */
      bool continue_flag = false;
      if (Getattr(p,"tmap:ignore")) {
        p = Getattr(p,"tmap:ignore:next");
        continue_flag = true;
      }
      if (Getattr(jstypep,"tmap:ignore")) {
        jstypep = Getattr(jstypep,"tmap:ignore:next");
        continue_flag = true;
      }
      if (continue_flag)
        continue;

      /* Ignore the 'this' argument for variable wrappers */
      if (!(variable_wrapper_flag && i==0)) 
      {
        SwigType *pt = Getattr(p,"type");
        String   *javaparamtype = NewString("");

        /* Get the java type of the parameter */
        bool is_java_class = false;
        if ((tm = Getattr(jstypep,"tmap:jstype"))) {
          is_java_class = substituteJavaclassname(pt, tm);
          Printf(javaparamtype, "%s", tm);
          jstypep = Getattr(jstypep,"tmap:jstype:next");
        } else {
          jstypep = nextSibling(jstypep);
          Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
              "No jstype typemap defined for %s\n", SwigType_str(pt,0));
        }

        if (gencomma)
          Printf(nativecall, ", ");

        String *arg = generateShadowParameters(n, p, i, is_java_class, user_arrays, nativecall, javaparamtype);

        /* Add to java shadow function header */
        if (gencomma >= 2)
          Printf(shadow_code, ", ");
        gencomma = 2;
        Printf(shadow_code, "%s %s", javaparamtype, arg);

        Delete(arg);
        Delete(javaparamtype);
      }
      else {
        jstypep = nextSibling(jstypep);
      }
      p = nextSibling(p);
    }

    if(SwigType_isarray(t) && is_shadow(getArrayType(t))) {
      String *array_ret = NewString("");
      Printf(array_ret,");\n");
      Printv(array_ret, "    $type[] arrayWrapper = new $type[cArray.length];\n", NULL);
      Printv(array_ret, "    for (int i=0; i<cArray.length; i++)\n", NULL);
      Printv(array_ret, "      arrayWrapper[i] = new $type(cArray[i], false);\n", NULL);
      Printv(array_ret, "    return arrayWrapper;\n", NULL);

      Replaceall(array_ret, "$type", is_shadow(getArrayType(t)));
      Printv(nativecall, array_ret, NULL);
      Delete(array_ret);
    }
    else {
      if(is_return_type_java_class) {
        switch(SwigType_type(t)) {
          case T_USER:
            Printf(nativecall, "), true");
            break;
          case T_ARRAY:
          case T_REFERENCE:
          case T_POINTER:
            if (NewObject || (Getattr(n,"feature:new"))) // %newobject indicating Java must take responsibility for memory ownership
              Printf(nativecall, "), true");
            else
              Printf(nativecall, "), false");
            break;
          default:
            Printf(stderr, "Internal Error: unknown shadow type: %s\n", SwigType_str(t,0));
            break;
        }
      }
      Printf(nativecall,");\n");
    }

    Printf(shadow_code, ") {\n");
    Printv(shadow_code, user_arrays, NULL);
    Printf(shadow_code, "    %s", nativecall);
    Printf(shadow_code, "  }\n\n");

    Delete(shadowrettype);
    Delete(nativecall);
    Delete(user_arrays);
  }

  /* ----------------------------------------------------------------------
   * constructorHandler()
   * ---------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {

    ParmList *l = Getattr(n,"parms");
    String    *tm;
    Parm      *jstypep;
    Parm      *p;
    int       i;
    String    *user_arrays = NewString("");
    int       num_arguments = 0;
    int       num_required = 0;

    Language::constructorHandler(n);

    if(proxy_flag) {
      String *overloaded_name = getOverloadedName(n);
      String *nativecall = NewString("");

      Printf(shadow_code, "  %s %s(", Getattr(n,"feature:java:methodmodifiers"), shadow_classname);
      Printv(nativecall, "this(", jniclass, ".", Swig_name_construct(overloaded_name), "(", NULL);

      /* Attach the non-standard typemaps to the parameter list */
      Swig_typemap_attach_parms("jstype", l, NULL);
      Swig_typemap_attach_parms("ignore", l, NULL);

      int gencomma = 0;

      /* Output each parameter */
      for (i = 0, p=l, jstypep=l; p && jstypep; i++) {

        /* Ignored parameters */
        bool continue_flag = false;
        if (Getattr(p,"tmap:ignore")) {
          p = Getattr(p,"tmap:ignore:next");
          continue_flag = true;
        }
        if (Getattr(jstypep,"tmap:ignore")) {
          jstypep = Getattr(jstypep,"tmap:ignore:next");
          continue_flag = true;
        }
        if (continue_flag)
          continue;

        SwigType *pt = Getattr(p,"type");
        String   *javaparamtype = NewString("");

        /* Get the java type of the parameter */
        bool is_java_class = false;
        if ((tm = Getattr(jstypep,"tmap:jstype"))) {
          is_java_class = substituteJavaclassname(pt, tm);
          Printf(javaparamtype, "%s", tm);
          jstypep = Getattr(jstypep,"tmap:jstype:next");
        } else {
          jstypep = nextSibling(jstypep);
          Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
              "No jstype typemap defined for %s\n", SwigType_str(pt,0));
        }

        if(gencomma)
          Printf(nativecall, ", ");

        String *arg = generateShadowParameters(n, p, i, is_java_class, user_arrays, nativecall, javaparamtype);

        /* Add to java shadow function header */
        if(gencomma)
          Printf(shadow_code, ", ");
        Printf(shadow_code, "%s %s", javaparamtype, arg);
        gencomma = 1;

        Delete(arg);
        Delete(javaparamtype);
        p = nextSibling(p);
      }

      Printf(nativecall, "), true);\n");

      Printf(shadow_code, ") {\n");
      Printv(shadow_code, user_arrays, NULL);
      Printf(shadow_code, "    %s", nativecall);
      Printf(shadow_code, "  }\n\n");

      if(!gencomma)  // We must have a default constructor
        have_default_constructor_flag = true;

      Delete(overloaded_name);
      Delete(nativecall);
    }

    Delete(user_arrays);

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * destructorHandler()
   * ---------------------------------------------------------------------- */

  virtual int destructorHandler(Node *n) {
    Language::destructorHandler(n);
    String *symname = Getattr(n,"sym:name");

    if(proxy_flag) {
      Printv(destructor_call, "      ", jniclass, ".", Swig_name_destroy(symname), "(swigCPtr);\n", NULL);
    }
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * typemapApply()
   *
   * This function does the equivalent of
   * %apply type *tmap { name * };  when additions=pointer or
   * %apply type &tmap { name & };  when additions=reference
   * %apply type tmap[ANY] { name [ANY] }; when array_flag set etc...
   * ----------------------------------------------------------------------------- */

  void typemapApply(String *type, String *tmap, String *name, type_additions additions, bool array_flag)
  {
    String *nametemp = Copy(name);
    String *swigtypetemp = Copy(type);

    if (additions == pointer) {
      SwigType_add_pointer(swigtypetemp);
      SwigType_add_pointer(nametemp);
    }
    if (additions == reference) {
      SwigType_add_reference(swigtypetemp);
      SwigType_add_reference(nametemp);
    }
    if (array_flag) {
      SwigType_add_array(swigtypetemp, (char *)"ANY");
      SwigType_add_array(nametemp, (char *)"ANY");
    }

    Parm *srcpat = NewParm(swigtypetemp,tmap);
    Parm *destpat = NewParm(nametemp,0);
    Swig_typemap_apply(srcpat,destpat);
    Delete(nametemp);
    Delete(swigtypetemp);
  }

  /* -----------------------------------------------------------------------------
   * addClassTypemaps()
   * ----------------------------------------------------------------------------- */

  void addClassTypemaps(Node *n) {
    if (proxy_flag) {
      String *name = Getattr(n,"name");
      String *kind = Getattr(n,"kind");
      String *array_tmap = NewString("ARRAYSOFCLASSPOINTERS");
      String *arrayclass_tmap = NewString("ARRAYSOFCLASSES");
      String *swigtype = NewString("SWIGTYPE");
      String *shadowclassname = Getattr(n,"sym:name");
      String *tdname = Getattr(n,"tdname");

      name = tdname ? tdname : name;

      Setattr(n,"java:proxy", shadowclassname);

      /* Apply typemaps for handling arrays of all known classes/structs/unions. This is a workaround because the SWIGTYPE [] typemap does 
       * not make it possible to distinguish between classes that SWIG has parsed (knows about) and those that have not been parsed. */
      typemapApply(swigtype, arrayclass_tmap, name, none, true); //%apply SWIGTYPE ARRAYSOFCLASSES[ANY] {name[ANY]};
      typemapApply(swigtype, array_tmap, name, pointer, true);   //%apply SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] {name*[ANY]};

      /* More typemap applying to match types declared with the kind eg struct, union or class.
         For example when type is declared as 'struct name'. */
      if (kind && (Len(kind) > 0)) {
        String *namewithkind = NewStringf("%s %s",kind, name);
        typemapApply(swigtype, arrayclass_tmap, namewithkind, none, true); //%apply SWIGTYPE ARRAYSOFCLASSES[ANY] {kind name[ANY]};
        typemapApply(swigtype, array_tmap, namewithkind, pointer, true);   //%apply SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] {kind name*[ANY]};
        Delete(namewithkind);
      }
      Delete(array_tmap);
      Delete(arrayclass_tmap);
      Delete(swigtype);
      Setattr(n,"java:addedtypemaps","1");
    }
  }

  /* ----------------------------------------------------------------------
   * classDeclaration()
   * ---------------------------------------------------------------------- */
  virtual int classDeclaration(Node *n) {
    if (!Getattr(n,"java:addedtypemaps")) addClassTypemaps(n);
    return Language::classDeclaration(n);
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

    /* Although the JNI is designed to handle overloaded Java functions, a Java long is used for all classes in the SWIG
     * JNI native interface. The JNI native interface function is thus mangled when overloaded to give a unique name. */
    String *overloaded_name = NewStringf("%s", Getattr(n,"sym:name"));

    if (Getattr(n,"sym:overloaded")) {
      Printv(overloaded_name, Getattr(n,"sym:overname"), NULL);
    }

    return overloaded_name;
  }

  /* -----------------------------------------------------------------------------
   * jniclassFunctionHandler()
   * ----------------------------------------------------------------------------- */

  void jniclassFunctionHandler(Node *n) {
    SwigType  *t = Getattr(n,"type");
    ParmList  *l = Getattr(n,"parms");
    String    *tm;
    Parm      *jstypep;
    Parm      *p;
    int       i;
    String    *nativecall = NewString("");
    String    *shadowrettype = NewString("");
    String    *user_arrays = NewString("");
    int       num_arguments = 0;
    int       num_required = 0;
    String    *overloaded_name = getOverloadedName(n);
    String    *func_name = NULL;

    if (l) {
      if (SwigType_type(Getattr(l,"type")) == T_VOID) {
        l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("jstype", l, NULL);

    /* Get Java return types */
    bool is_return_type_java_class = false;
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      is_return_type_java_class = substituteJavaclassname(t, tm);
      Printf(shadowrettype, "%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    /* Change function name for global variables */
    if (proxy_flag && global_variable_flag) {
      // Capitalize the first letter in the variable to create a JavaBean type getter/setter function name
      func_name = NewString("");
      if(Cmp(Getattr(n,"sym:name"), Swig_name_set(variable_name)) == 0)
        Printf(func_name,"set");
      else 
        Printf(func_name,"get");
      Putc(toupper((int) *Char(variable_name)), func_name);
      Printf(func_name, "%s", Char(variable_name)+1);
    } else {
      func_name = Copy(Getattr(n,"sym:name"));
    }

    Printf(module_class_code, "  %s static %s %s(", Getattr(n,"feature:java:methodmodifiers"), shadowrettype, func_name);

    if(SwigType_isarray(t) && is_shadow(getArrayType(t))) {
      Printf(nativecall, "long[] cArray = ");
    }
    else {
      if(SwigType_type(t) != T_VOID)
        Printf(nativecall,"return ");
      if(is_return_type_java_class)
        Printv(nativecall, "new ", shadowrettype, "(", NULL);
    }

    Printv(nativecall, jniclass, ".", overloaded_name, "(", NULL);

    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required  = emit_num_required(l);

    int gencomma = 0;

    /* Output each parameter */
    for (i = 0, p=l, jstypep=l; i < num_arguments; i++) {

      while (Getattr(p,"tmap:ignore")) {
        p = Getattr(p,"tmap:ignore:next");
      }
      while (Getattr(jstypep,"tmap:ignore")) {
        jstypep = Getattr(jstypep,"tmap:ignore:next");
      }

      SwigType *pt = Getattr(p,"type");
      String   *javaparamtype = NewString("");

      /* Get the java type of the parameter */
      bool is_java_class = false;
      if ((tm = Getattr(jstypep,"tmap:jstype"))) {
        is_java_class = substituteJavaclassname(pt, tm);
        Printf(javaparamtype, "%s", tm);
        jstypep = Getattr(jstypep,"tmap:jstype:next");
      } else {
        jstypep = nextSibling(jstypep);
        Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
            "No jstype typemap defined for %s\n", SwigType_str(pt,0));
      }

      if (gencomma)
        Printf(nativecall, ", ");

      String *arg = generateShadowParameters(n, p, i, is_java_class, user_arrays, nativecall, javaparamtype);

      /* Add to java shadow function header */
      if (gencomma >= 2)
        Printf(module_class_code, ", ");
      gencomma = 2;
      Printf(module_class_code, "%s %s", javaparamtype, arg);

      p = nextSibling(p);
      Delete(arg);
      Delete(javaparamtype);
    }

    if(SwigType_isarray(t) && is_shadow(getArrayType(t))) {
      String *array_ret = NewString("");
      Printf(array_ret,");\n");
      Printv(array_ret, "    $type[] arrayWrapper = new $type[cArray.length];\n", NULL);
      Printv(array_ret, "    for (int i=0; i<cArray.length; i++)\n", NULL);
      Printv(array_ret, "      arrayWrapper[i] = new $type(cArray[i], false);\n", NULL);
      Printv(array_ret, "    return arrayWrapper;\n", NULL);

      Replaceall(array_ret, "$type", is_shadow(getArrayType(t)));
      Printv(nativecall, array_ret, NULL);
      Delete(array_ret);
    }
    else {
      if(is_return_type_java_class) {
        switch(SwigType_type(t)) {
          case T_USER:
            Printf(nativecall, "), true");
            break;
          case T_ARRAY:
          case T_REFERENCE:
          case T_POINTER:
            if (NewObject || (Getattr(n,"feature:new"))) // %newobject indicating Java must take responsibility for memory ownership
              Printf(nativecall, "), true");
            else
              Printf(nativecall, "), false");
            break;
          default:
            Printf(stderr, "Internal Error: unknown shadow type: %s\n", SwigType_str(t,0));
            break;
        }
      }
      Printf(nativecall,");\n");
    }

    Printf(module_class_code, ") {\n");
    Printv(module_class_code, user_arrays, NULL);
    Printf(module_class_code, "    %s", nativecall);
    Printf(module_class_code, "  }\n\n");

    Delete(shadowrettype);
    Delete(nativecall);
    Delete(user_arrays);
    Delete(func_name);
  }

  /* -----------------------------------------------------------------------------
   * substituteJavaclassname()
   *
   * Substitute $javaclassname with either the shadow class name for classes/structs/unions that SWIG knows about
   * otherwise use the $descriptor name for the Java class name. Note that the $&javaclassname substition
   * is the same as a $&descriptor substition, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - jstype typemap
   * Outputs:
   *   tm - jstype typemap with $javaclassname substitution
   * Return:
   *   is_java_class - flag indicating if a substitution was performed
   * ----------------------------------------------------------------------------- */

  bool substituteJavaclassname(SwigType *pt, String *tm) {
    bool is_java_class = false;
    if (Strstr(tm, "$javaclassname") || Strstr(tm,"$&javaclassname")) {
      String *javaclassname = NULL;
      if(SwigType_isarray(pt) && is_shadow(getArrayType(pt)))
        javaclassname = is_shadow(getArrayType(pt));
      else
        javaclassname = is_shadow(pt);
      if (javaclassname) {
        Replaceall(tm,"$&javaclassname", javaclassname); // is shadow() works for pointers to classes too
        Replaceall(tm,"$javaclassname", javaclassname);
      }
      else { // use $descriptor if SWIG does not know anything about this type. Note that any typedefs are resolved.
        String *descriptor = NULL;
        SwigType *type = NULL;
        if(SwigType_isarray(pt)) {
          SwigType *temp_type = SwigType_typedef_resolve_all(getArrayType(pt));
          if (is_shadow(temp_type))
            type = Copy(is_shadow(temp_type));
          else
            type = Copy(SwigType_typedef_resolve_all(pt));
        }
        else
          type = Copy(SwigType_typedef_resolve_all(pt));

        if (Strstr(tm, "$&javaclassname")) {
          SwigType_add_pointer(type);
          descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(type));
          Replaceall(tm, "$&javaclassname", descriptor);
        }
        else { // $javaclassname
          descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(type));
          Replaceall(tm, "$javaclassname", descriptor);
        }

        // Add to hash table so that the SWIGTYPE Java classes can be created later
        Setattr(swig_types_hash, descriptor, type);
        Delete(descriptor);
        Delete(type);
      }
      is_java_class = true;
    }
    return is_java_class;
  }

  /* -----------------------------------------------------------------------------
   * generateShadowParameters()
   *
   * Helper function for generating the shadow / module class wrapper functions.
   * Inputs: 
   *   n - Node
   *   p - parameter node
   *   arg_num - parameter argument number
   *   is_java_class - flag indicating whether wrapped as a Java class or primitive type
   *   javaparamtype - Java parameter type
   * Outputs:
   *   user_arrays - any additional code for accessing arrays
   *   nativecall - the jni interface function call
   * Return:
   *   arg - a unique parameter name
   * ----------------------------------------------------------------------------- */

  String *generateShadowParameters(Node *n, Parm *p, int arg_num, bool is_java_class, String *user_arrays, String *nativecall, String *javaparamtype) {

    SwigType *pt = Getattr(p,"type");

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

    // Generate code which wraps the JNI long (c pointer) with a Java class
    if(SwigType_isarray(pt) && is_shadow(getArrayType(pt))) {
      Printv(user_arrays, "    long[] $arg_cArray = new long[$arg.length];\n", NULL);
      Printv(user_arrays, "    for (int i=0; i<$arg.length; i++)\n", NULL);
      Printv(user_arrays, "      $arg_cArray[i] = ",is_shadow(getArrayType(pt)),".getCPtr($arg[i]);\n", NULL);
      Replaceall(user_arrays, "$arg", arg);
      Printv(nativecall, arg, "_cArray", NULL);
    } else if (is_java_class) {
      Printv(nativecall, javaparamtype,".getCPtr(",arg,")", NULL);
    } else 
      Printv(nativecall, arg, NULL);

    return arg;
  }

  /* -----------------------------------------------------------------------------
   * emitJavaClass()
   * ----------------------------------------------------------------------------- */

  void emitJavaClass(String *javaclassname, SwigType *type) {
    String *filen = NewStringf("%s.java", javaclassname);
    File *f_swigtype = NewFile(filen,"w");
    String *swigtype = NewString("");

    // Emit banner and package name
    emitBanner(f_swigtype);
    if(Len(package) > 0)
      Printf(f_swigtype, "package %s;\n\n", package);

    // Pure Java baseclass and interfaces
    const String *pure_java_baseclass = javaTypemapLookup("javabase", type, WARN_NONE);
    const String *pure_java_interfaces = javaTypemapLookup("javainterfaces", type, WARN_NONE);

    // Emit the class
    Printv(swigtype,
        javaTypemapLookup("javaimports", type, WARN_NONE), // Import statements
        "\n",
        javaTypemapLookup("javaclassmodifiers", type, WARN_JAVA_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers
        " class $javaclassname",       // Class name and bases
        *Char(pure_java_baseclass) ?
        " extends " : 
        "",
        pure_java_baseclass,
        *Char(pure_java_interfaces) ?  // Pure Java interfaces
        " implements " :
        "",
        pure_java_interfaces,
        " {\n",
        "  private long swigCPtr;\n",
        "\n",
        "  protected $javaclassname(long cPtr, boolean bFutureUse) {\n", // Constructor used for wrapping pointers
        "    swigCPtr = cPtr;\n",
        "  }\n",
        "\n",
        "  protected $javaclassname() {\n", // Default constructor
        "    swigCPtr = 0;\n",
        "  }\n",
        javaTypemapLookup("javagetcptr", type, WARN_JAVA_TYPEMAP_GETCPTR_UNDEF), // getCPtr method
        javaTypemapLookup("javacode", type, WARN_NONE), // extra Java code
        "}\n",
        "\n",
        NULL);

        Replaceall(swigtype, "$javaclassname", javaclassname);
        Printv(f_swigtype, swigtype, NULL);

        Close(f_swigtype);
        Delete(filen);
        Delete(swigtype);
  }

  /* -----------------------------------------------------------------------------
   * javaTypemapLookup()
   * ----------------------------------------------------------------------------- */

  const String *javaTypemapLookup(const String *op, String *type, int warning) {
    String *tm = NULL;
    const String *code = NULL;

    if((tm = Swig_typemap_search(op, type, NULL))) {
      code = Getattr(tm,"code");
    }

    if (!code) {
      code = empty_string;
      if (warning != WARN_NONE)
        Swig_warning(warning, input_file, line_number, "No %s typemap defined for %s\n", op, type);
    }

    return code;
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
     -noproxy        - Generate the low-level functional interface instead of proxy classes\n";



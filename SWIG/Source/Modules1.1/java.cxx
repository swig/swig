/* -----------------------------------------------------------------------------
 * java.cxx
 *
 *     Java wrapper module.
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

#include <ctype.h>

#include "swigmod.h"

static char *usage = (char*)"\
Java Options\n\
     -package <name>  - set name of the package\n\
     -proxy           - generate proxy classes\n";

static  Hash  *swig_types_hash = 0;
static  File         *f_runtime = 0;
static  File         *f_header = 0;
static  File         *f_wrappers = 0;
static  File         *f_init = 0;

static int    shadow = 0; // Set to 1 when generating shadow classes
static int    have_default_constructor = 0;
static int    native_func = 0;     // Set to 1 when wrapping a native function
static int    enum_constant_flag = 0; // Set to 1 when wrapping an enum or constant
static int    static_flag = 0; // Set to 1 when wrapping a static functions or member variables
static int    variable_wrapper_flag = 0; // Set to 1 when wrapping a nonstatic member variable
static int    wrapping_member = 0; // Set to 1 when wrapping a member variable/enum/const

static String *jniclass = 0;  // JNI class name
static String *module_class_name = 0;  // module class name
static String *jniclass_class_code = 0; // JNI class Java code - that is the native methods
static String *shadow_classdef = 0;
static String *shadow_code = 0;
static String *module_class_code = 0;
static String *shadow_classname = 0;
static String *shadow_variable_name = 0; //Name of a c struct variable or c++ public member variable (may or may not be const)
static String *shadow_constants_code = 0;
static String *module_constants_code = 0;
static String *package = 0; // Package name
static String *jnipackage = 0; // JNI package name
static String *jniclass_import = 0; //jniclass import from %pragma
static String *module_import = 0; //module import from %pragma
static String *jniclass_baseclass = 0; //inheritance for jniclass class from %pragma
static String *module_baseclass = 0; //inheritance for module class from %pragma
static String *jniclass_interfaces = 0; //interfaces for jniclass class from %pragma
static String *module_interfaces = 0; //interfaces for module class from %pragma
static String *jniclass_class_modifiers = 0; //class modifiers for jniclass class overriden by %pragma
static String *module_class_modifiers = 0; //class modifiers for module class overriden by %pragma
static String *jniclass_method_modifiers = 0; //native method modifiers overridden by %pragma
static String *wrapper_conversion_code = 0; //C++ casts for inheritance hierarchies JNI code
static String *jniclass_cppcasts_code = 0; //C++ casts up inheritance hierarchies JNI class Java code
static String *destructor_call = 0; //Destructor (delete) call if any

enum type_additions {none, pointer, reference};

class JAVA : public Language {
    const String *empty_string;

public:
  JAVA() : 
      empty_string(NewString("")) {
  }

  /* Test to see if a type corresponds to something wrapped with a shadow class */
  /* Return NULL if not otherwise the shadow name */
  String *is_shadow(SwigType *t) {
    if (shadow) {
      Node *n = classLookup(t);
      if (n) {
	if (!Getattr(n,"java:addedtypemaps")) addclasstypemaps(n);
	return Getattr(n,"java:proxy");
      }
    }
    return 0;
  }

  // Return the type of the c array
  SwigType *getArrayType(SwigType *t) {
    SwigType *ta = 0;
    if (SwigType_type(t) == T_ARRAY) {
      SwigType *aop;
      ta = Copy(t);
      aop = SwigType_pop(ta);
    }
    return ta;
  }
  
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
	  Swig_mark_arg(i);
	  shadow = 1;
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
    jniclass_class_modifiers = NewString("");
    module_class_name = Copy(Getattr(n,"name"));
    module_class_code = NewString("");
    module_baseclass = NewString("");
    module_interfaces = NewString("");
    module_import = NewString("");
    module_class_modifiers = NewString("");
    jniclass_import = NewString("");
    jniclass_method_modifiers = NewString("public final static");
    jniclass_cppcasts_code = NewString("");
    wrapper_conversion_code = NewString("");
    if (!package) package = NewString("");
    jnipackage = NewString("");

    Swig_banner(f_runtime);               // Print the SWIG banner message

    if (NoInclude) {
      Printf(f_runtime,"#define SWIG_NOINCLUDE\n");
    }

    String* wrapper_name = NewString("");

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
    if(jniclass_import)
      Printf(f_java, "%s\n", jniclass_import);

    if (jniclass_class_modifiers && *Char(jniclass_class_modifiers))
      Printf(f_java, "%s", jniclass_class_modifiers);
    else
      Printf(f_java, "public");
    Printf(f_java, " class %s ", jniclass);

    if (jniclass_baseclass && *Char(jniclass_baseclass))
      Printf(f_java, "extends %s ", jniclass_baseclass);
    if (jniclass_interfaces)
      Printv(f_java, jniclass_interfaces, " ", NULL);
    Printf(f_java, "{\n");

    // Add the native methods
    Printv(f_java, jniclass_class_code, NULL);
    Printv(f_java,jniclass_cppcasts_code,NULL);

    // Finish off the Java class
    Printf(f_java, "}\n");
    Close(f_java);

    {
      // Generate the Java module class
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
      if(module_import)
        Printf(f_module, "%s\n", module_import);

      if (module_class_modifiers && *Char(module_class_modifiers))
        Printf(f_module, "%s", module_class_modifiers);
      else
        Printf(f_module, "public");
      Printf(f_module, " class %s ", module_class_name);

      if (module_baseclass && *Char(module_baseclass))
        Printf(f_module, "extends %s ", module_baseclass);
      if (module_interfaces)
        Printv(f_module, module_interfaces, " ", NULL);
      Printf(f_module, "{\n");

      // Add the wrapper methods
      Printv(f_module, module_class_code, NULL);

      // Write out all the enums constants
      if (strlen(Char(module_constants_code)) != 0 )
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
    Delete(module_import); module_import = NULL;
    Delete(module_class_modifiers); module_class_modifiers = NULL;
    Delete(jniclass_import); jniclass_import = NULL;
    Delete(jniclass_method_modifiers); jniclass_method_modifiers = NULL;
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
      native_func = 1;
      functionWrapper(n);
      Swig_restore(&n);
      native_func = 0;
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

    if (shadow) {
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
    if(shadow && wrapping_member && !enum_constant_flag) {
      String *member_function_name = NewString("");
      if(Cmp(symname, Swig_name_set(Swig_name_member(shadow_classname, shadow_variable_name))) == 0)
	Printf(member_function_name,"set");
      else 
	Printf(member_function_name,"get");
      Putc(toupper((int) *Char(shadow_variable_name)), member_function_name);
      Printf(member_function_name, "%s", Char(shadow_variable_name)+1);

      Setattr(n,"java:shadowfuncname", member_function_name);
      Setattr(n,"java:funcname", symname);

      javaShadowFunctionHandler(n);

      Delete(member_function_name);
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

    /* Get the jni and java types of the return. 
   * The non-standard typemaps must first be attached to the parameter list. */
    Swig_typemap_attach_parms("jni", l, f);
    Swig_typemap_attach_parms("jtype", l, f);
  
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

    Printf(jniclass_class_code, "  %s ", jniclass_method_modifiers);
    Printf(jniclass_class_code, "native %s %s(", javarettype, overloaded_name);

    Printv(f->def, "JNIEXPORT ", jnirettype, " JNICALL ", wname, "(JNIEnv *jenv, jclass jcls", NULL);

  // Emit all of the local variables for holding arguments.
    emit_args(t,l,f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l,f);

    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required  = emit_num_required(l);

    int gencomma = 0;

    // Now walk the function parameter list and generate code to get arguments
    for (i = 0, p=l, jnip=l, jtypep=l; i < num_arguments; i++) {
    
      while (Getattr(p,"tmap:ignore")) {
	p = Getattr(p,"tmap:ignore:next");
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
      while (Getattr(p,"tmap:ignore")) {
	p = Getattr(p,"tmap:ignore:next");
      }
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
      while (Getattr(p,"tmap:ignore")) {
	p = Getattr(p,"tmap:ignore:next");
      }
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

    if (Getattr(n, "value") && Cmp(Getattr(n, "storage"), "%constant") == 0)
      {
	// Wrapping a constant hack
	Swig_save(&n,"wrap:action",NULL);

    // below based on Swig_VargetToFunction()
	SwigType *ty = Swig_wrapped_var_type(Getattr(n,"type"));
	Setattr(n,"wrap:action", NewStringf("result = (%s) %s;\n", SwigType_lstr(ty,0), Getattr(n, "value")));
      }

    // Now write code to make the function call
    if(!native_func)
      emit_action(n,f);

    if (Getattr(n, "value") && Cmp(Getattr(n, "storage"), "%constant") == 0)
      Swig_restore(&n);

  /* Return value if necessary  */
    if((SwigType_type(t) != T_VOID) && !native_func) {
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
    if((SwigType_type(t) != T_VOID) && !native_func) {
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
    if(!native_func)
      Wrapper_print(f,f_wrappers);

    /* Emit warnings for the few cases that can't be overloaded in Java */
    if (Getattr(n,"sym:overloaded")) {
      if (!Getattr(n,"sym:nextSibling"))
        Swig_overload_rank(n);
    }

    if(!(shadow && is_wrapping_class()) && !enum_constant_flag) {
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

  virtual int variableWrapper(Node *n)
  {
    Language::variableWrapper(n);           /* Default to functions */
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * enumDeclaration()
   * ------------------------------------------------------------------------ */

  virtual int enumDeclaration(Node *n) {
    String *name = Getattr(n,"sym:name");
    String* s1 = NewStringf("enum %s", name);
    String* s2 = NewStringf("%s", name);
    String *swigtype = NewString("enum SWIGTYPE");
    
    /* Apply typemaps for handling arrays of enums and arrays of enum pointers for all known enums*/
    typemapApply(swigtype, NULL, s1, none, 1);    //%apply enum SWIGTYPE[ANY] {enum name[ANY]};
    typemapApply(swigtype, NULL, s2, none, 1);    //%apply enum SWIGTYPE[ANY] {name[ANY]};
    return Language::enumDeclaration(n);
    Delete(s1);
    Delete(s2);
    Delete(swigtype);
  }
  
  /* -----------------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    String *symname = Getattr(n,"sym:name");
    SwigType *t     = Getattr(n,"type");
    String *value   = Getattr(n,"value");
    ParmList  *l    = Getattr(n,"parms");
    String *tm;
    String *shadowrettype = NewString("");
    String *constants_code = NewString("");

    Swig_typemap_attach_parms("jstype", l, 0);

    int is_return_type_java_class = 0;
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
    Printf(constants_code, "  public final static %s %s = ", shadowrettype, ((shadow && wrapping_member) ? shadow_variable_name : symname));

    // The %javaconst directive determines how the constant value is obtained
    String *javaconst = Getattr(n,"feature:java:const");
    if (Cmp(nodeType(n), "enumitem") == 0 || !javaconst || Cmp(javaconst, "0") == 0) {
      // Enums and default constant handling will work with any type of C constant and initialises the Java variable from C through a JNI call.

      if(is_return_type_java_class) // This handles function pointers using the %constant directive
        Printf(constants_code, "new %s(%s.%s(), false);\n", shadowrettype, jniclass, Swig_name_get(symname));
      else
        Printf(constants_code, "%s.%s();\n", jniclass, Swig_name_get(symname));

      // Each constant and enum value is wrapped with a separate JNI function call
      enum_constant_flag = 1;
      variableWrapper(n);
      enum_constant_flag = 0;
    } else {
      // Alternative constant handling will use the C syntax to make a true Java constant and hope that it compiles as Java code
      Printf(constants_code, "%s;\n", Getattr(n,"value"));
    }

    if(shadow && wrapping_member)
      Printv(shadow_constants_code, constants_code, NULL);
    else
      Printv(module_constants_code, constants_code, NULL);

    Swig_restore(&n);
    Delete(new_value);
    Delete(shadowrettype);
    Delete(constants_code);
    return SWIG_OK;
  }

  /*
    Valid Pragmas:
    These pragmas start with 'allshadow' or 'jniclass'
    jniclassbase       - base (extends) for the java jniclass class
x   allshadowbase      - base (extends) for all java shadow classes
    jniclasscode       - text (java code) is copied verbatim to the java jniclass class
x   allshadowcode      - text (java code) is copied verbatim to all java shadow classes
    jniclassclassmodifiers   - class modifiers for the jniclass class
x   allshadowclassmodifiers  - class modifiers for all shadow classes
    jniclassimport     - import statement generation for the java jniclass class
x   allshadowimport    - import statement generation for all java shadow classes
    jniclassinterface  - interface (implements) for the jniclass class
x   allshadowinterface - interface (implements) for all shadow classes
    jniclassmethodmodifiers  - replaces the generated native calls' default modifiers
  */
  
  /* 
     C++ pragmas: pragmas declared within a class or c struct for the shadow class. 
     These pragmas start with 'shadow'
     Valid pragmas:
x    shadowbase      - base (extends) for all java shadow classes
x    shadowcode      - text (java code) is copied verbatim to the shadow class
x    shadowclassmodifiers  - class modifiers for the shadow class
x    shadowimport    - import statement generation for the shadow class
x    shadowinterface - interfaces (extends) for the shadow class
  */
  
  virtual int pragmaDirective(Node *n) {
    if (!ImportMode) {
      String *lang = Getattr(n,"lang");
      String *code = Getattr(n,"name");
      String *value = Getattr(n,"value");
      
      if(Strcmp(lang, "java") != 0) return Language::pragmaDirective(n);
      
      String *strvalue = NewString(value);
      Replaceall(strvalue,"\\\"", "\"");
      
      if(Strcmp(code, "jniclassimport") == 0) {
	Printf(jniclass_import, "import %s;\n", strvalue);
      } 
      else if(Strcmp(code, "allshadowimport") == 0) {
//	if(shadow && all_shadow_import)
//	  Printf(all_shadow_import, "import %s;\n", strvalue);
      } 
      else if(Strcmp(code, "import") == 0) {
	Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please replace with jniclassimport, shadowimport and/or allshadowimport pragmas.\n", input_file, line_number);
      }
      else if(Strcmp(code, "jniclasscode") == 0 || Strcmp(code, "jniclass") == 0) {
	if(Strcmp(code, "jniclass") == 0)
	  Printf(stderr,"%s : Line %d. Soon to be deprecated pragma. Please replace with jniclasscode pragma.\n", input_file, line_number);
	Printf(jniclass_class_code, "%s\n", strvalue);
      } 
      else if(Strcmp(code, "allshadowcode") == 0 || Strcmp(code, "shadow") == 0) {
//	if(shadow && all_shadow_extra_code) {
//	  if(Strcmp(code, "shadow") == 0)
//	    Printf(stderr,"%s : Line %d. Soon to be deprecated pragma. Please replace with allshadowcode pragma.\n", input_file, line_number);
//	  Printf(all_shadow_extra_code, "%s\n", strvalue);
//	}
      } 
      else if(Strcmp(code, "jniclassbase") == 0) {
	if(shadow && jniclass_baseclass)
	  Printf(jniclass_baseclass, "%s", strvalue);
      } 
      else if(Strcmp(code, "allshadowbase") == 0) {
//	if(shadow && all_shadow_baseclass)
//	  Printf(all_shadow_baseclass, "%s", strvalue);
      } 
      else if(Strcmp(code, "jniclassinterface") == 0) {
	if(shadow && jniclass_interfaces)
	  if (!*Char(jniclass_interfaces))
	    Printf(jniclass_interfaces, "implements %s", strvalue);
	  else
	    Printf(jniclass_interfaces, ", %s", strvalue);
      } 
      else if(Strcmp(code, "allshadowinterface") == 0) {
//	if(shadow && all_shadow_interfaces) {
//	  if (!*Char(all_shadow_interfaces))
//	    Printf(all_shadow_interfaces, " implements %s", strvalue);
//	  else
//	    Printf(all_shadow_interfaces, ", %s", strvalue);
//	}
      } 
      else if(Strcmp(code, "allshadowclassmodifiers") == 0) {
//	if(shadow && all_shadow_class_modifiers)
//	  Printv(all_shadow_class_modifiers, strvalue, NULL);
      } 
      else if(Strcmp(code, "jniclassclassmodifiers") == 0) {
	if(shadow && jniclass_class_modifiers)
	  Printv(jniclass_class_modifiers, strvalue, NULL);
      } 
      else if(Strcmp(code, "jniclassmethodmodifiers") == 0 || Strcmp(code, "modifiers") == 0) {
	if(Strcmp(code, "modifiers") == 0)
	  Printf(stderr,"%s : Line %d. Soon to be deprecated pragma. Please replace with jniclassmethodmodifiers pragma.\n", input_file, line_number);
	Clear(jniclass_method_modifiers);
	Printv(jniclass_method_modifiers, strvalue, NULL);
      } else if (shadow) {
	if (Strcmp(code,"shadowcode") == 0) {
	  if (shadow_code)
	    Printf(shadow_code, "%s\n", strvalue);
	  else
	    Printf(stderr,"%s : Line %d. Out of scope pragma.\n", input_file, line_number);
	} 
	else if (Strcmp(code,"shadowimport") == 0) {
//	  if (this_shadow_import)
//	    Printf(this_shadow_import, "import %s;\n", strvalue);
//	  else
//	    Printf(stderr,"%s : Line %d. Out of scope pragma.\n", input_file, line_number);
	} 
	else if (Strcmp(code,"shadowbase") == 0) {
//	  if (this_shadow_baseclass)
//	    Printf(this_shadow_baseclass, "%s", strvalue);
//	  else
//	    Printf(stderr,"%s : Line %d. Out of scope pragma.\n", input_file, line_number);
	} 
	else if (Strcmp(code,"shadowinterface") == 0) {
//	  if (this_shadow_interfaces) {
//	    if (!*Char(this_shadow_interfaces))
//	      Printf(this_shadow_interfaces, " implements %s", strvalue);
//	    else
//	      Printf(this_shadow_interfaces, ", %s", strvalue);
//	  }
//	  else
//	    Printf(stderr,"%s : Line %d. Out of scope pragma.\n", input_file, line_number);
	} 
	else if (Strcmp(code,"shadowclassmodifiers") == 0) {
//	  if (this_shadow_class_modifiers)
//	    Printv(this_shadow_class_modifiers, strvalue, NULL);
//	  else
//	    Printf(stderr,"%s : Line %d. Out of scope pragma.\n", input_file, line_number);
	}  else {
	  Printf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
	}
      } else {
	Printf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
      }
      Delete(strvalue);
    }
    return Language::pragmaDirective(n);
  }
  
  void emitShadowClassDefAndCPPCasts(Node *n) {
    String *c_classname = SwigType_namestr(Getattr(n,"name"));
    String *c_baseclass = 0;
    String *baseclass = 0;
    String *c_baseclassname = 0;

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

    int derived = baseclass && is_shadow(c_baseclassname); 
    if (!baseclass)
      baseclass = NewString("");

    // Inheritance from pure Java classes
    const String* pure_java_baseclass = javaTypemapLookup("javabase", shadow_classname, WARN_NONE);
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
	   "  public $javaclassname(long cPtr, boolean cMemoryOwn) {\n", // Constructor used for wrapping pointers
	   derived ? 
	   "    super($jniclass.SWIG$javaclassnameTo$baseclass(cPtr), cMemoryOwn);\n" : 
	   "    swigCMemOwn = cMemoryOwn;\n",
	   "    swigCPtr = cPtr;\n",
	   "  }\n",
	   NULL);

    if(!have_default_constructor) { // All Java classes need a constructor
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
      Printv(jniclass_cppcasts_code,"  ", jniclass_method_modifiers, " native long ",
	     "SWIG$javaclassnameTo$baseclass(long jarg1);\n",
	     NULL);
      Replaceall(jniclass_cppcasts_code, "$javaclassname", shadow_classname);
      Replaceall(jniclass_cppcasts_code, "$baseclass", baseclass);

      Printv(wrapper_conversion_code,
	     "extern \"C\" {\n",
	     "  JNIEXPORT jlong JNICALL",
	     " Java_$jnipackage$jnijniclass_SWIG$jniclazznameTo$jnibaseclass",
	     "(JNIEnv *jenv, jclass jcls, jlong jarg1) {\n",
	     "    jlong baseptr = 0;\n"
	     "    *($cbaseclass **)&baseptr = ($cclass *)*(void**)&jarg1;\n"
	     "    return baseptr;\n"
	     " }\n",
	     "}\n",
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
      if (!shadow) {
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
//    Delete(class_modifiers);
  }

  /* ----------------------------------------------------------------------
   * classHandler()
   * ---------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {

    File *f_shadow = NULL;
    if (shadow) {
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
    
      have_default_constructor = 0;
      destructor_call = NewString("");
      shadow_constants_code = NewString("");
    }
    Language::classHandler(n);

    if (shadow) {

      emitShadowClassDefAndCPPCasts(n);

      Printv(f_shadow, shadow_classdef, shadow_code, NULL);

      // Write out all the enums and constants
      if (strlen(Char(shadow_constants_code)) != 0 )
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
    
    if (shadow) {
      String* overloaded_name = getOverloadedName(n);
      String* java_function_name = Swig_name_member(shadow_classname, overloaded_name);
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

    static_flag = 1;
    Language::staticmemberfunctionHandler(n);
    
    if (shadow) {
      String* overloaded_name = getOverloadedName(n);
      String* java_function_name = Swig_name_member(shadow_classname, overloaded_name);
      Setattr(n,"java:shadowfuncname", Getattr(n,"sym:name"));
      Setattr(n,"java:funcname", java_function_name);
      javaShadowFunctionHandler(n);
      Delete(overloaded_name);
    }
    static_flag = 0;

    return SWIG_OK;
  }

  /* 
     Function called for creating a java class wrapper function around a c++ function in the 
     java wrapper class. Used for both static and non static functions.
     C++ static functions map to java static functions.
     Two extra attributes in the Node must be available. These are "java:shadowfuncname" - the name of the java class shadow 
     function, which in turn will call "java:funcname" - the java native function name which wraps the c++ function.
  */
  void javaShadowFunctionHandler(Node* n) {
    SwigType  *t = Getattr(n,"type");
    ParmList  *l = Getattr(n,"parms");
    String*   java_function_name = Getattr(n,"java:funcname");
    String*   java_shadow_function_name = Getattr(n,"java:shadowfuncname");
    String    *tm;
    Parm      *jstypep;
    Parm      *p;
    int       i;
    String    *nativecall = NewString("");
    String    *shadowrettype = NewString("");
    String    *user_arrays = NewString("");
    int       num_arguments = 0;
    int       num_required = 0;

    if(!shadow) return;

    if (l) {
      if (SwigType_type(Getattr(l,"type")) == T_VOID) {
	l = nextSibling(l);
      }
    }

    /* Get java shadow types of the return. 
     * The non-standard typemaps must first be attached to the parameter list. */
    Swig_typemap_attach_parms("jstype", l, 0);

    int is_return_type_java_class = 0;
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      is_return_type_java_class = substituteJavaclassname(t, tm);
      Printf(shadowrettype, "%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }

    Printf(shadow_code, "  public ");
    if (static_flag)
      Printf(shadow_code, "static ");
    Printf(shadow_code, "%s %s(", shadowrettype, java_shadow_function_name);

    if(SwigType_type(t) == T_ARRAY && is_shadow(getArrayType(t))) {
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

  /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required  = emit_num_required(l);

    int gencomma = !static_flag;

    /* Workaround to overcome Getignore(p) not working - p does not always have the Getignore 
attribute set. Noticeable when javaShadowFunctionHandler is called from memberfunctionHandler() */
/* maybe this will work if put below ?
    while (Getattr(p,"tmap:ignore")) {
      p = Getattr(p,"tmap:ignore:next");
    }
*/
    Wrapper* f = NewWrapper();
    emit_args(NULL, l, f);
    DelWrapper(f);
    /* Workaround end */

  /* Output each parameter */
    for (i = 0, p=l, jstypep=l; i < num_arguments; i++) {
      if(Getattr(p,"ignore")) continue;

      /* Ignore the 'this' argument for variable wrappers */
      if (!(variable_wrapper_flag && i==0)) 
      {
	  SwigType *pt = Getattr(p,"type");
	  String   *javaparamtype = NewString("");
  
	  /* Get the java type of the parameter */
      int is_java_class = 0;
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

    if(SwigType_type(t) == T_ARRAY && is_shadow(getArrayType(t))) {
      String* array_ret = NewString("");
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
	  if (NewObject) // %new indicating Java must take responsibility for memory ownership
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

    if(shadow) {
      String *overloaded_name = getOverloadedName(n);
      String *nativecall = NewString("");
  
      Printf(shadow_code, "  public %s(", shadow_classname);
      Printv(nativecall, "this(", jniclass, ".", Swig_name_construct(overloaded_name), "(", NULL);
    
      int pcount = ParmList_len(l);
      if(pcount == 0)  // We must have a default constructor
	have_default_constructor = 1;
  
      Swig_typemap_attach_parms("jstype", l, 0);

      /* Get number of required and total arguments */
      num_arguments = emit_num_arguments(l);
      num_required  = emit_num_required(l);
  
      for (i = 0, p=l, jstypep=l; i < num_arguments; i++) {
          /* need to check for ignore in here  and add in gencomma logic ***************************************************************************** */
	SwigType *pt = Getattr(p,"type");
	String   *javaparamtype = NewString("");
  
        /* Get the java type of the parameter */
        int is_java_class = 0;
        if ((tm = Getattr(jstypep,"tmap:jstype"))) {
            is_java_class = substituteJavaclassname(pt, tm);
            Printf(javaparamtype, "%s", tm);
            jstypep = Getattr(jstypep,"tmap:jstype:next");
        } else {
            jstypep = nextSibling(jstypep);
            Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
                    "No jstype typemap defined for %s\n", SwigType_str(pt,0));
        }

        String *arg = generateShadowParameters(n, p, i, is_java_class, user_arrays, nativecall, javaparamtype);

	/* Add to java shadow function header */
	Printf(shadow_code, "%s %s", javaparamtype, arg);
  
	if(i != pcount-1) {
	  Printf(nativecall, ", ");
	  Printf(shadow_code, ", ");
	}
    Delete(arg);
	Delete(javaparamtype);
        p = nextSibling(p);
      }

      Printf(nativecall, "), true);\n");
  
      Printf(shadow_code, ") {\n");
      Printv(shadow_code, user_arrays, NULL);
      Printf(shadow_code, "    %s", nativecall);
      Printf(shadow_code, "  }\n\n");

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
    
    if(shadow) {
      Printv(destructor_call, "      ", jniclass, ".", Swig_name_destroy(symname), "(swigCPtr);\n", NULL);
    }
    return SWIG_OK;
  }

  /* This function does the equivalent of
   * %apply type *tmap { name * };  when additions=pointer or
   * %apply type &tmap { name & };  when additions=reference
   * %apply type tmap[ANY] { name [ANY] }; when array_flag set etc... */

  void typemapApply(String *type, String *tmap, String *name, type_additions additions, int array_flag)
  {
    String* nametemp = Copy(name);
    String* swigtypetemp = Copy(type);
    
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
  
  void addclasstypemaps(Node *n) {
    if (shadow) {
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
      typemapApply(swigtype, arrayclass_tmap, name, none, 1); //%apply SWIGTYPE ARRAYSOFCLASSES[ANY] {name[ANY]};
      typemapApply(swigtype, array_tmap, name, pointer, 1);   //%apply SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] {name*[ANY]};

      /* More typemap applying to match types declared with the kind eg struct, union or class.
         For example when type is declared as 'struct name'. */
      if (kind && (Len(kind) > 0)) {
        String *namewithkind = NewStringf("%s %s",kind, name);
        typemapApply(swigtype, arrayclass_tmap, namewithkind, none, 1); //%apply SWIGTYPE ARRAYSOFCLASSES[ANY] {kind name[ANY]};
        typemapApply(swigtype, array_tmap, namewithkind, pointer, 1);   //%apply SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] {kind name*[ANY]};
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
    if (!Getattr(n,"java:addedtypemaps")) addclasstypemaps(n);
    return Language::classDeclaration(n);
  }
  
  /* ----------------------------------------------------------------------
   * membervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {
    shadow_variable_name = Getattr(n,"sym:name");
    wrapping_member = 1;
    variable_wrapper_flag = 1;
    Language::membervariableHandler(n);
    wrapping_member = 0;
    variable_wrapper_flag = 0;
    return SWIG_OK;
  }
  
  /* ----------------------------------------------------------------------
   * staticmembervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {
    shadow_variable_name = Getattr(n,"sym:name");
    wrapping_member = 1;
    static_flag = 1;
    Language::staticmembervariableHandler(n);
    wrapping_member = 0;
    static_flag = 0;
    return SWIG_OK;
  }
  
  /* ----------------------------------------------------------------------
   * memberconstantHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberconstantHandler(Node *n) {
    shadow_variable_name = Getattr(n,"sym:name");
    wrapping_member = 1;
    Language::memberconstantHandler(n);
    wrapping_member = 0;
    return SWIG_OK;
  }

  String * getOverloadedName(Node *n) {

    /* Although the JNI is designed to handle overloaded Java functions, a Java long is used for all classes in the SWIG
     * JNI native interface. The JNI native interface function is thus mangled when overloaded to give a unique name. */
    String *overloaded_name = NewStringf("%s", Getattr(n,"sym:name"));

    if (Getattr(n,"sym:overloaded")) {
        Printv(overloaded_name, Getattr(n,"sym:overname"), NULL);
    }

    return overloaded_name;
  }

  void JAVA::jniclassFunctionHandler(Node *n) {
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
  
    if (l) {
      if (SwigType_type(Getattr(l,"type")) == T_VOID) {
        l = nextSibling(l);
      }
    }
  
    /* Get java shadow types of the return. 
     * The non-standard typemaps must first be attached to the parameter list. */
    Swig_typemap_attach_parms("jstype", l, 0);

    int is_return_type_java_class = 0;
    if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
      is_return_type_java_class = substituteJavaclassname(t, tm);
      Printf(shadowrettype, "%s", tm);
    } else {
      Swig_warning(WARN_JAVA_TYPEMAP_JSTYPE_UNDEF, input_file, line_number, 
          "No jstype typemap defined for %s\n", SwigType_str(t,0));
    }
  
    Printf(module_class_code, "  public static %s %s(", shadowrettype, Getattr(n,"sym:name"));
  
    if(SwigType_type(t) == T_ARRAY && is_shadow(getArrayType(t))) {
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
  
  /* Workaround to overcome Getignore(p) not working - p does not always have the Getignore 
  attribute set. Noticeable when called from memberfunctionHandler() */
  /* maybe this will work if put below ?
      while (Getattr(p,"tmap:ignore")) {
        p = Getattr(p,"tmap:ignore:next");
      }
  */
  Wrapper* f = NewWrapper();
  emit_args(NULL, l, f);
  DelWrapper(f);
  /* Workaround end */
  
    /* Output each parameter */
    for (i = 0, p=l, jstypep=l; i < num_arguments; i++) {
      if(Getattr(p,"ignore")) continue;
      SwigType *pt = Getattr(p,"type");
      String   *javaparamtype = NewString("");

      /* Get the java type of the parameter */
      int is_java_class = 0;
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
  
    if(SwigType_type(t) == T_ARRAY && is_shadow(getArrayType(t))) {
      String* array_ret = NewString("");
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
          if (NewObject) // %new indicating Java must take responsibility for memory ownership
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
  }

  /* 
   * Substitute $javaclassname with either the shadow class name for classes/structs/unions that SWIG knows about
   * otherwise use the $descriptor name for the Java class name. Note that the $&javaclassname substition
   * is the same as a $&descriptor substition, ie one pointer added to descriptor name.
   * Inputs:
   * pt - parameter type
   * tm - jstype typemap
   * Outputs:
   * tm - jstype typemap with $javaclassname substitution
   * Return:
   * is_java_class - flag indicating if a substitution was performed
   */
  int substituteJavaclassname(SwigType *pt, String *tm) {
    int is_java_class = 0;
    if (Strstr(tm, "$javaclassname") || Strstr(tm,"$&javaclassname")) {
      String *javaclassname = NULL;
      if(SwigType_type(pt) == T_ARRAY && is_shadow(getArrayType(pt)))
        javaclassname = is_shadow(getArrayType(pt));
      else
        javaclassname = is_shadow(pt);
      if (javaclassname) {
        Replaceall(tm,"$&javaclassname", javaclassname); // is shadow() works for pointers to classes too
        Replaceall(tm,"$javaclassname", javaclassname);
      }
      else { // use $descriptor if SWIG does not know anything about this type. Note that any typedefs are resolved.
        String *descriptor = NULL;
        SwigType* type = NULL;
        if(SwigType_type(pt) == T_ARRAY) {
          SwigType* temp_type = SwigType_typedef_resolve_all(getArrayType(pt));
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
      is_java_class = 1;
    }
    return is_java_class;
  }

  /* Helper function for generating the shadow / module class wrapper functions.
   * Inputs: 
   * n - Node
   * p - parameter node
   * arg_num - parameter argument number
   * is_java_class - flag indicating whether wrapped as a Java class or primitive type
   * Outputs:
   * user_arrays - any additional code for accessing arrays
   * nativecall - the jni interface function call
   * Return:
   * arg - a unique parameter name
   */
  String *generateShadowParameters(Node *n, Parm *p, int arg_num, int is_java_class, String *user_arrays, String *nativecall, String* javaparamtype) {

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
    if(SwigType_type(pt) == T_ARRAY && is_shadow(getArrayType(pt))) {
      Printv(user_arrays, "    long[] $arg_cArray = new long[$arg.length];\n", NULL);
      Printv(user_arrays, "    for (int i=0; i<$arg.length; i++)\n", NULL);
      Printv(user_arrays, "      $arg_cArray[i] = ",is_shadow(getArrayType(pt)),".getCPtr($arg[i]);\n", NULL);
      Replace(user_arrays, "$arg", arg, DOH_REPLACE_ANY);
      Printv(nativecall, arg, "_cArray", NULL);
    } else if (is_java_class) {
        Printv(nativecall, javaparamtype,".getCPtr(",arg,")", NULL);
    } else 
      Printv(nativecall, arg, NULL);

    return arg;
  }
  
  void emitJavaClass(String *javaclassname, SwigType *type) {
    String *filen = NewStringf("%s.java", javaclassname);
    File *f_swigtype = NewFile(filen,"w");
    String *swigtype = NewString("");

    // Emit banner and package name
    emitBanner(f_swigtype);
    if(Len(package) > 0)
      Printf(f_swigtype, "package %s;\n\n", package);

    // Pure Java baseclass and interfaces
    const String* pure_java_baseclass = javaTypemapLookup("javabase", javaclassname, WARN_NONE);
    const String *pure_java_interfaces = javaTypemapLookup("javainterfaces", javaclassname, WARN_NONE);

    // Emit the class
    Printv(swigtype,
       javaTypemapLookup("javaimports", javaclassname, WARN_NONE), // Import statements
	   "\n",
       javaTypemapLookup("javaclassmodifiers", javaclassname, WARN_JAVA_TYPEMAP_CLASSMOD_UNDEF), // Class modifiers
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
	   "  public $javaclassname(long cPtr, boolean bFutureUse) {\n", // Constructor used for wrapping pointers
	   "    swigCPtr = cPtr;\n",
	   "  }\n",
       "\n",
       "  public $javaclassname() {\n", // Default constructor
       "    swigCPtr = 0;\n",
       "  }\n",
       javaTypemapLookup("javagetcptr", javaclassname, WARN_JAVA_TYPEMAP_GETCPTR_UNDEF), // getCPtr method
       javaTypemapLookup("javacode", javaclassname, WARN_NONE), // extra Java code
       "}\n",
       "\n",
       NULL);

    Replaceall(swigtype, "$javaclassname", javaclassname);
    Printv(f_swigtype, swigtype, NULL);

    Close(f_swigtype);
    Delete(filen);
    Delete(swigtype);
  }

  const String *javaTypemapLookup(const String *op, String *type, int warning) {
    String *tm = NULL;
    const String *code = NULL;

    if((tm = Swig_typemap_search(op, type, NULL))) {
      code = Getattr(tm,"code");
    }

    if (!code) {
      code = empty_string;
      if (warning)
        Swig_warning(warning, input_file, line_number, 
          "No %s typemap defined for %s\n", op, type);
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




/* TODO
 * strlen -> Len
 * fix arrays in constructor
 * change all 0 to NULL
 * use Replaceall and SwigType_isarray instead of T_ARRAY
 * SwigType *JAVA::getArrayType(SwigType *t) might be in the internals now
 * change name of is_shadow()??
 * Change variable names to reflect new names that will go in documentation - eg JNI interface class.
 * Make all variables private not file scope
 * Use nodeType(n), "constant") instead of other hack
 *
 * Generate SWIGAToB C++ casting functions for classes in inheritance chain when -noproxy being used. - tidy up emitShadowClassDefAndCPPCasts wrt shadow flag.
 *
 * change -shadow to -proxy (-noproxy) in all makefiles
 * fix comment in -nofinalize deprecated commandline option
 *
 * Sort out javaTypemapLookup warnings
 *
 *         Possible to remove is_shadow and replace with SwigType_isclass() or classLookup ??
 *
 * Should generate a non-wrapped base class to wrapped derived class c++ conversion function.
 *
 * Add comment into java.swg that the 2 ARRAYSOFCLASS typemaps only get applied for proxy classes.
 *
 * Check classes with underscores will work correctly, especially in inheritance chain, ie new SWIGAToB() calls.
 *
 * Think about using custom typemaps and whether it will all hang together - will the primitive and jni interface classes be okay?
 * module class needs changing to JNIinterface and primitive class needs changing to module class
 *
 * check pointer library
 *
 * Things to solve:
 * Backward compatibility - need pragmas to rename class
 * Single base class for all the SWIGTYPEs? - not possible with proxy classes.
 *
 * Document these fixes:
 *  Square** was incorrectly using a Square in shadow class, should be a long (or new SWIGTYPE_p_p_Square.)
 *  non-unique parameter names - only occurs when 2 typemaps of the same named typemaps are used, eg pointer example
 *
 *  Add to test-suite some of the tests out of javaclass, eg Class** cpp[] - could add a whole testcase full of not wrapped types, eg enums pointers references and combinations of these
 *  Add in a runtime typedef example, based on cpp_typedef.i - I reckon that python and other scripting langs won't work with this - check. It doesn't seem to like things that are not pointers.
 *  Explain what $javaclassname does now
 *  jstype typemaps now for SWIGTYPES and shadow classes
 *
 * Documentation:
 *  Memory leaks if not -proxy used.
 *  Because the shadow class is a wrapper around a pointer, a shadow class can be passed to a function that would take a class/struct by value or a pointer or a reference - SWIG treats references pointers.
 *  dynamic_cast - use helper function, mentioned in python section on pointers.
 *  void* pointers - use wrapper constructor -> new SWIGTYPE_p_void(cls.getCPtr(), false);
 *  null pointers - use wrapper constructor -> new cls(0, false);
 *  constants using %javaconst
 *
 *  the following pragmas have changed name from moduleXXX to jniclassXXX
    modulebase
    modulecode
    moduleclassmodifiers
    moduleimport
    moduleinterface
    modulemethodmodifiers

    Suggestions for documentation:
       public boolean equals($javaclassname obj) {
         return obj.swigCPtr == this.swigCPtr;
       }
       public int hashCode() {
       System.out.println(\"hashcode: \" + java.util.Integer.toHexString((int)(swigCPtr >> 32)));
         return (int)swigCPtr; // Little Endian
         return (int)(swigCPtr >> 32); // Big Endian
       }
 *
 * Incompatibilities:
 *  enums and constants in the module class have moved to the Primitive class
 *  If never defined a jstype and not using shadow classes, ie just a jtype then need to define one now.
 *  Some arrays are treated differently, eg arrays of int*, arrays of enum*, arrays of not wrapped* - but this last one was wrong anyway!
 *  %native - will have to change JNI function name to include modulenameJNI rather than just modulename [this falls under the pragma to change the JNI interface class name]
 *  eg JNIEXPORT jstring JNICALL Java_exampleJNI_point_1toString2(JNIEnv *jenv, jclass jcls, jlong jpoint);
 *     JNIEXPORT jstring JNICALL Java_example_point_1toString2(JNIEnv *jenv, jclass jcls, jlong jpoint);
 *
 *
 */




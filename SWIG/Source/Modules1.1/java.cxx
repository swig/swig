/* -----------------------------------------------------------------------------
 * java.cxx
 *
 *     Java wrapper module.
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

#include <ctype.h>

#include "mod11.h"
#include "java.h"

char bigbuf[1024];

static char *usage = (char*)"\
Java Options\n\
     -jnic            - use c syntax for JNI calls\n\
     -jnicpp          - use c++ syntax for JNI calls\n\
     -package <name>  - set name of the package\n\
     -shadow          - generate shadow classes\n\
     -nofinalize      - do not generate finalize methods in shadow classes\n\
     -rn              - generate register natives code\n\n";

static char   *module = 0;          // Name of the module
static char   *java_path = (char*)"java";
static char   *package = 0;         // Name of the package
static char   *c_pkgstr;         // Name of the package
static char   *jni_pkgstr;         // Name of the package
static char   *shadow_classname;
static FILE   *f_java = 0;
static FILE   *f_shadow = 0;

static  File         *f_runtime = 0;
static  File         *f_header = 0;
static  File         *f_wrappers = 0;
static  File         *f_init = 0;

static int    shadow = 0;
static Hash   *shadow_classes;
static String *shadow_classdef;
static String *shadow_code;
static char   *shadow_variable_name = 0; //Name of a c struct variable or c++ public member variable (may or may not be const)
static int    classdef_emitted = 0;
static int    have_default_constructor = 0;
static int    native_func = 0;     // Set to 1 when wrapping a native function
static int    enum_flag = 0; // Set to 1 when wrapping an enum
static int    static_flag = 0; // Set to 1 when wrapping a static functions or member variables
static int    variable_wrapper_flag = 0; // Set to 1 when wrapping a nonstatic member variable
static int    wrapping_member = 0; // Set to 1 when wrapping a member variable/enum/const
static int    abstract_class_flag = 0;
static int    jnic = -1;          // 1: use c syntax jni; 0: use c++ syntax jni
static int    nofinalize = 0;          // for generating finalize methods
static int    useRegisterNatives = 0;        // Set to 1 when doing stuff with register natives
static String *registerNativesList = 0;
static String *shadow_enum_code = 0;
static String *java_enum_code = 0;
static String *module_extra_code = 0; // Extra code for the module class from %pragma
static String *all_shadow_extra_code = 0; // Extra code for all shadow classes from %pragma
static String *this_shadow_extra_code = 0; // Extra code for current single shadow class from %pragma
static String *module_import = 0; //module import from %pragma
static String *all_shadow_import = 0; //import for all shadow classes from %pragma
static String *this_shadow_import = 0; //import for current shadow classes from %pragma
static String *module_baseclass = 0; //inheritance for module class from %pragma
static String *all_shadow_baseclass = 0; //inheritance for all shadow classes from %pragma
static String *this_shadow_baseclass = 0; //inheritance for shadow class from %pragma and cpp_inherit
static String *module_interfaces = 0; //interfaces for module class from %pragma
static String *all_shadow_interfaces = 0; //interfaces for all shadow classes from %pragma
static String *this_shadow_interfaces = 0; //interfaces for shadow class from %pragma
static String *module_class_modifiers = 0; //class modifiers for module class overriden by %pragma
static String *all_shadow_class_modifiers = 0; //class modifiers for all shadow classes overriden by %pragma
static String *this_shadow_class_modifiers = 0; //class modifiers for shadow class overriden by %pragma
static String *module_method_modifiers = 0; //native method modifiers overridden by %pragma

/* Test to see if a type corresponds to something wrapped with a shadow class */
/* Return NULL if not otherwise the shadow name */
static String *is_shadow(SwigType *t) {
  return Getattr(shadow_classes,SwigType_base(t));
}

// Return the type of the c array
static SwigType *get_array_type(SwigType *t) {
  SwigType *ta = 0;
  if (SwigType_type(t) == T_ARRAY) {
    SwigType *aop;
    ta = Copy(t);
    aop = SwigType_pop(ta);
  }
  return ta;
}

char *JAVA::SwigToJavaArrayType(SwigType *t) {
  switch(SwigType_type(t)) {
    case T_CHAR: return (char*)"Byte";
    case T_SCHAR: return (char*)"Byte";
    case T_UCHAR: return (char*)"Short";
    case T_SHORT: return (char*)"Short";
    case T_USHORT: return (char*)"Int";
    case T_INT: return (char*)"Int";
    case T_UINT: return (char*)"Long";
    case T_LONG: return (char*)"Long";
    case T_ULONG: return (char*)"Long";
    case T_FLOAT: return (char*)"Float";
    case T_DOUBLE: return (char*)"Double";
    case T_BOOL: return (char*)"Boolean";
    case T_STRING:	return (char*)"String";
    case T_POINTER:
    case T_REFERENCE:
    case T_ARRAY:
    case T_VOID:
    case T_USER:
    default : return (char*)"Long"; // Treat as a pointer
  }
}

/* JavaMethodSignature still needs updating for changes from SWIG1.3a3 to SWIG1.3a5 */
char *JAVA::JavaMethodSignature(SwigType *t, int ret, int inShadow) {
  if(SwigType_ispointer(t) == 1) {
	  switch(SwigType_type(t)) {
	    case T_CHAR:   return (char*)"Ljava/lang/String;";
	    case T_SCHAR:  return (char*)"[B";
	    case T_UCHAR:  return (char*)"[S";
	    case T_SHORT:  return (char*)"[S";
	    case T_USHORT: return (char*)"[I";
	    case T_INT:    return (char*)"[I";
	    case T_UINT:   return (char*)"[J";
	    case T_LONG:   return (char*)"[J";
	    case T_ULONG:  return (char*)"[J";
	    case T_FLOAT:  return (char*)"[F";
	    case T_DOUBLE: return (char*)"[D";
	    case T_BOOL:   return (char*)"[Z";
	    case T_STRING:	return (char*)"Ljava/lang/String;";
	    case T_POINTER:	return (char*)"[J";
	    case T_REFERENCE:	return (char*)"[J";
	    case T_ARRAY:	return (char*)"???";
	    case T_VOID:
        case T_USER:   if(inShadow && is_shadow(t))
                         return Char(is_shadow(t));
                       else return (char*)"J";
	  }
  } else if(SwigType_ispointer(t) > 1) {
    if(ret) return (char*)"J";
    else return (char*)"[J";
  } else {
	  switch(SwigType_type(t)) {
	    case T_CHAR: return (char*)"B";
	    case T_SCHAR: return (char*)"B";
	    case T_UCHAR: return (char*)"S";
	    case T_SHORT: return (char*)"S";
	    case T_USHORT: return (char*)"I";
	    case T_INT: return (char*)"I";
	    case T_UINT: return (char*)"J";
	    case T_LONG: return (char*)"J";
	    case T_ULONG: return (char*)"J";
	    case T_FLOAT: return (char*)"F";
	    case T_DOUBLE: return (char*)"D";
	    case T_BOOL: return (char*)"Z";
	    case T_STRING:	return (char*)"Ljava/lang/String;";
	    case T_POINTER:	return (char*)"J";
	    case T_REFERENCE:	return (char*)"J";
	    case T_ARRAY:	return (char*)"???";
	    case T_VOID: return (char*)"V";
	    case T_USER: return (char*)"J";
	  }
  }
  Printf(stderr, "JavaMethodSignature: unhandled SWIG type [%d] %s\n", SwigType_type(t), SwigType_str(t,0));
  return NULL;
}

char *JAVA::makeValidJniName(const char *name) {
  const char *c = name;
  char *b = bigbuf;

  while(*c) {
    *b++ = *c;
    if(*c == '_')
      *b++ = '1';
    c++;
  }
  *b = '\0';

  return Swig_copy_string(bigbuf);
}

// !! this approach fails for functions without arguments
char *JAVA::JNICALL(String_or_char *func) {
  if(jnic)
	sprintf(bigbuf, "(*jenv)->%s(jenv, ", Char(func));
  else
	sprintf(bigbuf, "jenv->%s(", Char(func));

  return Swig_copy_string(bigbuf);
}

void JAVA::writeRegisterNatives()
{
  if(Len(registerNativesList) == 0)
    return;

  Printf(f_wrappers,"\n");
  Printf(f_wrappers,"JNINativeMethod nativeMethods[] = {\n");
  Printv(f_wrappers, registerNativesList, 0);
  Printf(f_wrappers, "};\n");

  Printf(f_wrappers,"\nint numberOfNativeMethods=sizeof(nativeMethods)/sizeof(JNINativeMethod);\n\n");

  // The registerNatives function

  Printv(f_wrappers,
	 "jint registerNatives(JNIEnv *jenv) {", "\n",
	 tab4, "jclass nativeClass = ", JNICALL((char*)"FindClass"),
	 "\"", jni_pkgstr, module, "\");","\n",
	 0);

  Printv(f_wrappers,
	 tab4, "if (nativeClass == 0)", "\n", tab8, "return -1;", "\n",
	 tab4, "return ", JNICALL((char*)"RegisterNatives"), "nativeClass, nativeMethods, ", "numberOfNativeMethods);", "\n",
	 "}", "\n", "\n",
	 0);

  // The unregisterNatives function

  Printv(f_wrappers,
	 "jint unregisterNatives(JNIEnv *jenv) {", "\n",
	 tab4, "jclass nativeClass = ", JNICALL((char*)"FindClass"),
	 "\"", jni_pkgstr, module, "\");","\n",
	 0);

  Printv(f_wrappers,
	 tab4, "if (nativeClass == 0)", "\n", tab8, "return -1;", "\n",
	 tab4, "// Sun documentation suggests that this method should not be invoked in ",
	 "\"normal native code\".", "\n",
	 tab4, "// return ", JNICALL((char*)"UnregisterNatives"), "nativeClass);", "\n",
	 tab4, "return 0;", "\n",
	 "}", "\n",
	 0);
}

// ---------------------------------------------------------------------
// JAVA::main()
//
// Parse my command line options and initialize by variables.
// ---------------------------------------------------------------------

void JAVA::main(int argc, char *argv[]) {

  SWIG_library_directory("java");

  // Look for certain command line options
  for (int i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i],"-package") == 0) {
	if (argv[i+1]) {
	  package = new char[strlen(argv[i+1])+1];
          strcpy(package, argv[i+1]);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i+1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i],"-shadow") == 0) {
	    Swig_mark_arg(i);
        shadow = 1;
      } else if (strcmp(argv[i],"-jnic") == 0) {
	    Swig_mark_arg(i);
        jnic = 1;
      } else if (strcmp(argv[i],"-nofinalize") == 0) {
	    Swig_mark_arg(i);
        nofinalize = 1;
      } else if (strcmp(argv[i],"-rn") == 0) {
	    Swig_mark_arg(i);
        useRegisterNatives = 1;
      } else if (strcmp(argv[i],"-jnicpp") == 0) {
        Swig_mark_arg(i);
	    jnic = 0;
      } else if (strcmp(argv[i],"-help") == 0) {
	    Printf(stderr,"%s\n", usage);
      }
    }
  }

  if(jnic == -1) {
    if(CPlusPlus)
	jnic = 0;
    else jnic = 1;
  }

  // Add a symbol to the parser for conditional compilation
  Preprocessor_define((void *) "SWIGJAVA 1",0);

  // Add typemap definitions
  SWIG_typemap_lang("java");
  SWIG_config_file("java.swg");
}

// ---------------------------------------------------------------------
// void JAVA::top()
// ---------------------------------------------------------------------

int JAVA::top(Node *n) {

  /* Initialize all of the output files */
  String *outfile = Getattr(n,"outfile");

  f_runtime = NewFile(outfile,"w");
  if (!f_runtime) {
    Printf(stderr,"*** Can't open '%s'\n", outfile);
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

  shadow_classes = NewHash();
  shadow_classdef = NewString("");
  shadow_code = NewString("");
  registerNativesList = NewString("");
  java_enum_code = NewString("");
  module_extra_code = NewString("");
  module_baseclass = NewString("");
  module_interfaces = NewString("");
  module_class_modifiers = NewString("");
  all_shadow_extra_code = NewString("");
  all_shadow_import = NewString("");
  all_shadow_baseclass = NewString("");
  all_shadow_interfaces = NewString("");
  all_shadow_class_modifiers = NewString("");
  module_import = NewString("");
  module_method_modifiers = NewString("public final static");

  Swig_banner(f_runtime);               // Print the SWIG banner message
  Printf(f_runtime,"/* Implementation : Java */\n\n");

  set_module(Char(Getattr(n,"name")));

  String* wrapper_name = NewString("");

  if(package) {
    String *s = NewString(package);
    char *jniname = makeValidJniName(Char(s));
    Clear(s);
    Printv(s, jniname, 0);
    free(jniname);
    Replace(s,".","_", DOH_REPLACE_ANY);
    Append(s, "_");
    c_pkgstr = Swig_copy_string(Char(s));
    Delete(s);

    String *s2 = NewString(package);
    Replace(s2,".","/", DOH_REPLACE_ANY);
    Append(s2,"/");
    jni_pkgstr = Swig_copy_string(Char(s2));
    Delete(s2);
  } else {
    package = c_pkgstr = jni_pkgstr = (char*)"";
  }

  char *jniname = makeValidJniName(module);
  Printf(wrapper_name, "Java_%s%s_%%f", c_pkgstr, jniname);
  free(jniname);

  Swig_name_register((char*)"wrapper", Char(wrapper_name));
  Swig_name_register((char*)"set", (char*)"set_%v");
  Swig_name_register((char*)"get", (char*)"get_%v");
  Swig_name_register((char*)"member", (char*)"%c_%m");

  Delete(wrapper_name);

  // Generate the java class
  sprintf(bigbuf, "%s.java", module);
  if((f_java = fopen(bigbuf, "w")) == 0) {
    Printf(stderr,"Unable to open %s\n", bigbuf);
    SWIG_exit(1);
  }

  Printf(f_header, "#define J_CLASSNAME %s\n", module);
  if(package && *package) {
    Printf(f_java, "package %s;\n\n", package);
    Printf(f_header, "#define J_PACKAGE %s\n", package);
  } else {
    Printf(f_header, "#define J_PACKAGE\n");
  }

  /* Emit all nodes */
  Language::top(n);

  if(!classdef_emitted) emit_classdef();

  // Write the enum initialisation code in a static block.
  // These are all the enums defined in the global c context.
  if (strlen(Char(java_enum_code)) != 0 )
    Printv(f_java, "  static {\n  // Initialise java constants from c/c++ enums\n", java_enum_code, "  }\n",0);

  // Finish off the java class
  Printf(f_java, "}\n");
  fclose(f_java);

  if(useRegisterNatives)
	writeRegisterNatives();

  Delete(shadow_classes); shadow_classes = NULL;
  Delete(shadow_classdef); shadow_classdef = NULL;
  Delete(shadow_code); shadow_code = NULL;
  Delete(registerNativesList); registerNativesList = NULL;
  Delete(java_enum_code); java_enum_code = NULL;
  Delete(module_extra_code); module_extra_code = NULL;
  Delete(module_baseclass); module_baseclass = NULL;
  Delete(module_interfaces); module_interfaces = NULL;
  Delete(module_class_modifiers); module_class_modifiers = NULL;
  Delete(all_shadow_extra_code); all_shadow_extra_code = NULL;
  Delete(all_shadow_import); all_shadow_import = NULL;
  Delete(all_shadow_baseclass); all_shadow_baseclass = NULL;
  Delete(all_shadow_interfaces); all_shadow_interfaces = NULL;
  Delete(all_shadow_class_modifiers); all_shadow_class_modifiers = NULL;
  Delete(module_import); module_import = NULL;
  Delete(module_method_modifiers); module_method_modifiers = NULL;

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

// ---------------------------------------------------------------------
// JAVA::set_module(char *mod_name)
//
// Sets the module name.  Does nothing if it's already set (so it can
// be overriddent as a command line option).
//
//----------------------------------------------------------------------

void JAVA::set_module(char *mod_name) {
  if (module) return;
  module = new char[strlen(mod_name)+1];
  strcpy(module,mod_name);
}


static void emit_banner(FILE *f) {
  Printf(f, "/* ----------------------------------------------------------------------------\n");
  Printf(f, " * This file was automatically generated by SWIG (http://www.swig.org).\n");
  Printf(f, " * Version: %s\n", SWIG_VERSION);
  Printf(f, " *\n");
  Printf(f, " * Do not make changes to this file unless you know what you are doing--modify\n");
  Printf(f, " * the SWIG interface file instead.\n");
  Printf(f, " * ----------------------------------------------------------------------------- */\n\n");
}

void JAVA::emit_classdef() {
  if(!classdef_emitted) {
    emit_banner(f_java);
    if(module_import)
      Printf(f_java, "%s\n", module_import);

    if (module_class_modifiers && *Char(module_class_modifiers))
      Printf(f_java, "%s", module_class_modifiers);
    else
      Printf(f_java, "public");
    Printf(f_java, " class %s ", module);

    if (module_baseclass && *Char(module_baseclass))
      Printf(f_java, "extends %s ", module_baseclass);
    if (module_interfaces)
      Printv(f_java, module_interfaces, " ", 0);
    Printf(f_java, "{\n", module);
    if (module_extra_code)
      Printv(f_java, module_extra_code, 0);
  }
  classdef_emitted = 1;
}

int JAVA::nativeWrapper(Node *n) {

  Swig_save(&n,"name",0);
  Setattr(n,"name", Getattr(n,"wrap:name"));
  native_func = 1;
  functionWrapper(n);
  Swig_restore(&n);
  native_func = 0;
  return SWIG_OK;
}

// ----------------------------------------------------------------------
// JAVA::functionWrapper()
//
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

int JAVA::functionWrapper(Node *n) {
  char *name = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *t = Getattr(n,"type");
  ParmList *l = Getattr(n,"parms");
  char      source[256], target[256];
  String    *tm;
  Parm      *p;
  Parm      *jnip;
  Parm      *jtypep;
  int       i;
  char		*javaReturnSignature = 0;
  String    *jnirettype = NewString("");
  String    *javarettype = NewString("");
  String    *cleanup = NewString("");
  String    *outarg = NewString("");
  String    *body = NewString("");
  String    *javaParameterSignature = NewString("");
  int       num_arguments = 0;
  int       num_required = 0;

  /* 
  Generate the java class wrapper function ie the java shadow class. Only done for public
  member variables. That is this generates the getters/setters for member variables.
  */
  if(shadow && wrapping_member && !enum_flag) {
    String *member_function_name = NewString("");
    String *java_function_name = NewString(iname);
    if(strcmp(iname, Char(Swig_name_set(Swig_name_member(shadow_classname, shadow_variable_name)))) == 0)
      Printf(member_function_name,"set");
    else Printf(member_function_name,"get");
    Putc(toupper((int) *shadow_variable_name), member_function_name);
    Printf(member_function_name, "%s", shadow_variable_name+1);

    Setattr(n,"java:shadfuncname", member_function_name);
    Setattr(n,"java:funcname", iname);
    javashadowfunctionHandler(n, NOT_VIRTUAL);

    Delete(java_function_name);
    Delete(member_function_name);
  }

  /*
  The rest of this function deals with generating the java wrapper function (that wraps
  a c/c++ function) and generating the JNI c code. Each java wrapper function has a 
  matching JNI c function call.
  */

  // A new wrapper function object
  Wrapper *f = NewWrapper();

  if(!classdef_emitted) emit_classdef();

  // Make a wrapper name for this function
  char *jniname = makeValidJniName(iname);
  String *wname = Swig_name_wrapper(jniname);
  free(jniname);

  /* Get the jni and java types of the return. 
   * The non-standard typemaps must first be attached to the parameter list. */
  Swig_typemap_attach_parms("jni", l, f);
  Swig_typemap_attach_parms("jtype", l, f);
  
  if ((tm = Swig_typemap_lookup_new("jni",n,"",0))) {
    Printf(jnirettype,"%s", tm);
  } else {
    Printf(stderr, "No jni typemap defined for %s\n", SwigType_str(t,0));
  }

  if ((tm = Swig_typemap_lookup_new("jtype",n,"",0))) {
    Printf(javarettype,"%s", tm);
  } else {
    Printf(stderr, "No jtype typemap defined for %s\n", SwigType_str(t,0));
  }

  // If dumping the registerNative outputs, store the method return type
  // signature
  if (useRegisterNatives) {
      javaReturnSignature = JavaMethodSignature(t, 1, 0);
  }

  if (SwigType_type(t) != T_VOID) {
	 Wrapper_add_localv(f,"jresult", jnirettype, "jresult = 0",0);
  }

  Printf(f_java, "  %s ", module_method_modifiers);
  Printf(f_java, "native %s %s(", javarettype, iname);

  if(!jnic) 
    Printv(f->def, "extern \"C\"{\n", 0);
  Printv(f->def, "JNIEXPORT ", jnirettype, " JNICALL ", wname, "(JNIEnv *jenv, jclass jcls", 0);

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
    String   *pn = Getattr(p,"name");
    String   *ln = Getattr(p,"lname");
    String   *javaparamtype = NewString("");
    String   *jni_param_type = NewString("");

    sprintf(target,"%s", Char(ln));
    sprintf(source,"j%s", target);

    if (useRegisterNatives) {
      Printv(javaParameterSignature, JavaMethodSignature(pt, 0, 0), 0);
    }

    /* Get the jni types of the parameter */
    if ((tm = Getattr(jnip,"tmap:jni"))) {
      jnip = Getattr(jnip,"tmap:jni:next");
      Printv(jni_param_type, tm, 0);
    } else {
      jnip = nextSibling(jnip);
      Printf(stderr, "No jni typemap defined for %s\n", SwigType_str(pt,0));
    }

    /* Get the java types of the parameter */
    if ((tm = Getattr(jtypep,"tmap:jtype"))) {
      jtypep = Getattr(jtypep,"tmap:jtype:next");
      Printv(javaparamtype, tm, 0);
    } else {
      jtypep = nextSibling(jtypep);
      Printf(stderr, "No jtype typemap defined for %s\n", SwigType_str(pt,0));
    }

    /* Add to java function header */
      if(gencomma) Printf(f_java, ", ");
      Printf(f_java, "%s %s", javaparamtype, source);

      gencomma = 1;

      // Add to Jni function header
      Printv(f->def, ", ", jni_param_type, " ", source, 0);

      // Get typemap for this argument
      if ((tm = Getattr(p,"tmap:in"))) {
        Replaceall(tm,"$source",source);
        Replaceall(tm,"$target",ln);
        Replaceall(tm,"$input", source);
        Replaceall(tm,"$arg",source);
        Setattr(p,"emit:input", source);
        Printf(f->code,"%s\n", tm);
        p = Getattr(p,"tmap:in:next");
      } else {
        switch(SwigType_type(pt)) {
        case T_BOOL:
        case T_CHAR:
        case T_SCHAR:
        case T_UCHAR:
        case T_SHORT:
        case T_USHORT:
        case T_INT:
        case T_UINT:
        case T_LONG:
        case T_ULONG:
        case T_FLOAT:
        case T_DOUBLE:
          Printv(f->code, tab4, target, " = (", SwigType_lstr(pt,0), ") ", source, ";\n", 0);
          break;
        case T_STRING:
          Printv(f->code, tab4, target, " = (", source, ") ? (char *)", JNICALL((char*)"GetStringUTFChars"), source, ", 0) : NULL;\n", 0);
          break;
        case T_VOID:
          break;
        case T_USER:
	  {
	    char argp[20];
	    sprintf(argp,"argp%d",i);
	    SwigType_add_pointer(pt);
	    Wrapper_add_localv(f,argp, SwigType_lstr(pt,argp), 0);
	    SwigType_del_pointer(pt);
	    Printv(f->code, tab4, argp, " = (", SwigType_lstr(pt,0), "*)*(void**)&", source, ";\n", 0);
	    Printf(f->code, "%s = *%s;\n", target, argp);
	  }
          break;
        case T_POINTER:
        case T_REFERENCE:
          Printv(f->code, tab4, target, " = (", SwigType_lstr(pt,0), ")*(void**)&", source, ";\n", 0);
          break;
        case T_ARRAY:
          {
          SwigType *array_type = get_array_type(pt);
          char *java_array_type = SwigToJavaArrayType(array_type);
          String *ctype = SwigType_lstr(array_type, 0);

          // Get basic jni type (eg remove Array from jintArray). Maybe have a special typemap to get basic jni type of jni arrays... Deal with later.
          String *basic_jniptrtype = NewStringf("%s*", jni_param_type);
          Replaceall(basic_jniptrtype,"Array","");

          String *source_length = NewStringf("%s%s)", JNICALL((char*)"GetArrayLength"), source);
          String *c_array = NewStringf("%s_carray", source);
          String *array_len = NewStringf("%s_len", source);
          String *get_array_func = NewStringf("Get%sArrayElements", java_array_type);

          Wrapper_add_localv(f, "i", "int", "i", 0); // Only gets added once if called more than once
          Wrapper_add_localv(f, c_array, basic_jniptrtype, c_array, 0);
          Wrapper_add_localv(f, array_len, "jsize", array_len, "= ", source_length, 0);

          Printv(f->code, tab4, c_array, " = ", JNICALL(get_array_func), source, ", 0);\n", 0);
          Printv(f->code, tab4, target, " = (", SwigType_lstr(pt, 0), ") malloc(", array_len, " * sizeof(", ctype, "));\n", 0);
          Printv(f->code, tab4, "for(i=0; i<", array_len, "; i++)\n", 0);

            switch(SwigType_type(array_type)) {
            case T_USER:
              Printv(f->code, tab8, target, "[i] = **(", ctype, "**)&", c_array, "[i];\n", 0);
              break;
            case T_POINTER:
              Printv(f->code, tab8, target, "[i] = *(", ctype, "*)&", c_array, "[i];\n", 0);
              break;
            default:
              Printv(f->code, tab8, target, "[i] = (", ctype, ")", c_array, "[i];\n", 0);
            break;
            }

          Delete(basic_jniptrtype);
          Delete(source_length);
          Delete(c_array);
          Delete(array_len);
          Delete(get_array_func);
          }
          break;
        default:
          Printf(stderr,"%s : Line %d. Error: Unknown typecode for type %s\n", input_file,line_number,SwigType_str(pt,0));
          break;
        }
        p = nextSibling(p);
      }
    Delete(javaparamtype);
    Delete(jni_param_type);
  }

  /* Insert constraint checking code */
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:check"))) {
      Replaceall(tm,"$target",target);
      Replaceall(tm,"$arg",Getattr(p,"emit:input"));
      Printv(f->code,tm,"\n",0);
      p = Getattr(p,"tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }
  
  /* Insert cleanup code */
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:freearg"))) {
      Replaceall(tm,"$source",source);
      Replaceall(tm,"$arg",Getattr(p,"emit:input"));
      Printv(f->code,tm,"\n",0);
      p = Getattr(p,"tmap:freearg:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Insert argument output code */
  for (i = 0, p=l, jnip=l, jtypep=l; i < num_arguments; i++) {
    SwigType *pt = Getattr(p,"type");
    String   *pn = Getattr(p,"name");
    String   *ln = Getattr(p,"lname");
    String   *javaparamtype = NewString("");
    String   *jni_param_type = NewString("");

    // Produce string representation of source and target arguments
    sprintf(target,"%s", Char(ln));
    sprintf(source,"j%s", target);

    /* Get the jni types of the parameter */
    if ((tm = Getattr(jnip,"tmap:jni"))) {
      jnip = Getattr(jnip,"tmap:jni:next");
      Printv(jni_param_type, tm, 0);
    } else {
      jnip = nextSibling(jnip);
      Printf(stderr, "No jni typemap defined for %s\n", SwigType_str(pt,0));
    }

    /* Get the java types of the parameter */
    if ((tm = Getattr(jtypep,"tmap:jtype"))) {
      jtypep = Getattr(jtypep,"tmap:jtype:next");
      Printv(javaparamtype, tm, 0);
    } else {
      jtypep = nextSibling(jtypep);
      Printf(stderr, "No jtype typemap defined for %s\n", SwigType_str(pt,0));
    }

    if ((tm = Getattr(p,"tmap:argout"))) {
      Replaceall(tm,"$source",source);
      Replaceall(tm,"$target",target);
      Replaceall(tm,"$arg",Getattr(p,"emit:input"));
      Replaceall(tm,"$input",source);
      Printv(outarg,tm,"\n",0);
      p = Getattr(p,"tmap:argout:next");
    } else {
        switch(SwigType_type(pt)) {
        case T_BOOL:
        case T_CHAR:
        case T_SCHAR:
        case T_UCHAR:
        case T_SHORT:
        case T_USHORT:
        case T_INT:
        case T_UINT:
        case T_LONG:
        case T_ULONG:
        case T_FLOAT:
        case T_DOUBLE:
          // nothing to do
          break;
        case T_STRING:
          Printv(outarg, tab4, "if(", target,") ", JNICALL((char*)"ReleaseStringUTFChars"), source, ", ", target, ");\n", 0);
          break;
        case T_VOID:
        case T_USER:
        case T_POINTER:
        case T_REFERENCE:
          // nothing to do
          break;
        case T_ARRAY:
          {
          SwigType *array_type = get_array_type(pt);
          char *java_array_type = SwigToJavaArrayType(array_type);

          String *c_array = NewStringf("%s_carray", source);
          String *release_array_func = NewStringf("Release%sArrayElements", java_array_type);

          Printv(outarg, tab4, JNICALL(release_array_func), source, ", ", c_array, ", 0);\n", 0);
          Printv(outarg, tab4, "free(", target, ");\n", 0);

          Delete(c_array);
          Delete(release_array_func);
          }
          break;
        default:
          Printf(stderr,"%s : Line %d. Error: Unknown typecode for type %s\n", input_file,line_number,SwigType_str(pt,0));
          break;
        }
      p = nextSibling(p);
      }
    Delete(javaparamtype);
    Delete(jni_param_type);
    }

  Printf(f_java, ");\n");
  Printf(f->def,") {");

  // Now write code to make the function call
  if(!native_func)
	emit_action(n,f);

  /* Return value if necessary  */
  if((SwigType_type(t) != T_VOID) && !native_func) {
  if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
    Replaceall(tm,"$result", "jresult");
    Printf(f->code,"%s\n", tm);
  } else {
        switch(SwigType_type(t)) {
        case T_BOOL:
        case T_CHAR:
        case T_SCHAR:
        case T_UCHAR:
        case T_SHORT:
        case T_USHORT:
        case T_INT:
        case T_UINT:
        case T_LONG:
        case T_ULONG:
        case T_FLOAT:
        case T_DOUBLE:
          Printv(f->code, tab4, "jresult = (", jnirettype, ") result;\n", 0);
          break;
        case T_STRING:
          Printv(f->code, tab4, "if(result != NULL)\n", 0);
          Printv(f->code, tab8, "jresult = (jstring)", JNICALL((char*)"NewStringUTF"),  "result);\n", 0);
          break;
        case T_VOID:
          break;
        case T_USER:
	  
	  if (CPlusPlus) {
	    Printf(f->code,"resultobj = new %s(result);\n", SwigType_lstr(t,0));
	  } else {
	    Printf(f->code,"resultobj = (%s *) malloc(sizeof(%s));\n", SwigType_lstr(t,0), SwigType_str(t,0));
	    Printf(f->code,"memmove(resultobj,&result,sizeof(%s));\n", SwigType_str(t,0));
	  }
	  SwigType_add_pointer(t);
	  SwigType_remember(t);
	  Wrapper_add_local(f,"resultobj", SwigType_lstr(t,"resultobj"));
	  SwigType_del_pointer(t);
          Printv(f->code, tab4, "*(", SwigType_lstr(t,0), "**)&jresult = resultobj;\n", 0);
          break;
        case T_POINTER:
        case T_REFERENCE:
          // Nasty casting. This has proved to cover all pointer cases so far including a pointer to an array.
          Printv(f->code, tab4, "jresult = *(", jnirettype, "*)&result;\n", 0);
          break;
        case T_ARRAY:
            {
            // Handle return values that are one dimension arrays 
            // Todo: What about void pointers?
            // Todo: Check on array size - check user has passed correct size in

            const int dim_no = 0; // Dimension number (0 == 1st ) - currently only 1 supported
            String *jnitype_ptr = NewString("");
            String *jnicall_new = NewString("");
            String *jnicall_get = NewString("");
            String *jnicall_release = NewString("");
            String *jni_array_type = NewString("");
            SwigType *array_type = get_array_type(t);
            char *java_array_type = SwigToJavaArrayType(array_type);

            // Get basic jni type (eg remove Array from jintArray). Maybe have a special typemap to get basic jni type of jni arrays... Deal with later.
            Printf(jni_array_type, "%s", jnirettype);
            Replaceall(jni_array_type,"Array","");
            Printf(jnitype_ptr, "%s*", jni_array_type);

            Wrapper_add_localv(f, "jnitype_ptr", jnitype_ptr, "jnitype_ptr", "= 0", 0);
            Wrapper_add_localv(f, "k", "int", "k", 0);

            // Create a java array for return to Java subsystem, eg for int array
            // String jresult = (*jenv)->NewIntArray(jenv, array_size); 
            Printv(jnicall_new, "New", java_array_type, "Array", 0);
            Printv(f->code, tab4, "jresult = ", JNICALL((char*)jnicall_new), SwigType_array_getdim(t, dim_no), ");\n", 0);

            // Get the c memory pointer to the java array, eg for int array
            // jnitype_ptr = (*jenv)->GetIntArrayElements(jenv, jresult, 0);
            Printv(jnicall_get, "Get", java_array_type, "ArrayElements", 0);
            Printv(f->code, tab4, "jnitype_ptr = ", JNICALL((char*)jnicall_get), "jresult, 0);\n", 0);

            // Populate the java array from the c array
            Printv(f->code, tab4, "for (k=0; k<", SwigType_array_getdim(t, dim_no), "; k++)\n", 0);
            switch(SwigType_type(array_type)) {
            case T_USER:
                Printv(f->code, tab8, "*(", SwigType_lstr(array_type, 0), "**)&jnitype_ptr[k] = &result[k];\n", 0);
              break;
            case T_POINTER:
                Printv(f->code, tab8, "*(", SwigType_lstr(array_type, 0), "*)&jnitype_ptr[k] = result[k];\n", 0);
              break;
            default:
                Printv(f->code, tab8, "jnitype_ptr[k] = (", jni_array_type, ")result[k];\n", 0);
            break;
            }
            // Release reference to the array so that it may be garbage collected in the future
            // (*jenv)->ReleaseIntArrayElements(jenv, jresult, _arg00, 0);
            Printv(jnicall_release, "Release", java_array_type, "ArrayElements", 0);
            Printv(f->code, tab4, JNICALL((char*)jnicall_release), "jresult, ", "jnitype_ptr", ", 0);\n", 0);
            Delete(jnitype_ptr);
            Delete(jnicall_new);
            Delete(jnicall_get);
            Delete(jnicall_release);
            Delete(jni_array_type);
            }
          break;
        default:
          Printf(stderr,"%s : Line %d. Error: Unknown typecode for type %s\n", input_file,line_number,SwigType_str(t,0));
          break;
        }
      }
  }

  /* Output argument output code */
  Printv(f->code,outarg,0);

  /* Output cleanup code */
  Printv(f->code,cleanup,0);

  /* Look to see if there is any newfree cleanup code */
  if (NewObject || (Getattr(n,"feature:new"))) {
    if ((tm = Swig_typemap_lookup_new("newfree",n,"result",0))) {
      Replaceall(tm,"$source","result");
      Printf(f->code,"%s\n",tm);
    }
  }

  /* See if there is any return cleanup code */
  if((SwigType_type(t) != T_VOID) && !native_func) {
    if ((tm = Swig_typemap_lookup_new("ret", n, "result", 0))) {
      Replaceall(tm,"$source","result");
      Printf(f->code,"%s\n",tm);
    }
  }

  if(SwigType_type(t) != T_VOID)
    Printv(f->code, tab4, "return jresult;\n", 0);
  if(!jnic)
    Printf(f->code, "}");
  Printf(f->code, "}\n");

  /* Substitute the cleanup code */
  Replaceall(f->code,"$cleanup",cleanup);

  /* Dump the function out */
  if(!native_func)
	Wrapper_print(f,f_wrappers);

 // If registerNatives is active, store the table entry for this method
  if (useRegisterNatives) {
    Printv(registerNativesList,
	   tab4, "{",
	   "\"", name, "\", \"(", javaParameterSignature, ")", javaReturnSignature, "\", ", wname,
	   "},\n",
	   0);

  }

  Delete(jnirettype);
  Delete(javarettype);
  Delete(cleanup);
  Delete(outarg);
  Delete(body);
  Delete(javaParameterSignature);
  DelWrapper(f);
  return SWIG_OK;
}

// -----------------------------------------------------------------------
// JAVA::variableWrapper()
//
// Create a JAVA link to a C variable.
// -----------------------------------------------------------------------

int JAVA::variableWrapper(Node *n)
{
  Language::variableWrapper(n);           /* Default to functions */
  return SWIG_OK;
}


// -----------------------------------------------------------------------
// JAVA::enumDeclaration()
// ------------------------------------------------------------------------

int JAVA::enumDeclaration(Node *n) {
  String *name = Getattr(n,"sym:name");
  String* s1 = NewStringf("a(ANY).enum %s", name);
  String* s2 = NewStringf("a(ANY).%s", name);

  /* The Java typemaps need the following typemaps to exist for handling arrays of enums:
     %typemap(jstype) enum SWIGTYPE[ANY] " enum ... "
     %typemap(jstype) enum SWIGTYPE[ANY] " ... "
     Now we must apply these typemaps to all known enum declarations */
  TypemapApplyEnum(s1);
  TypemapApplyEnum(s2);
  return Language::enumDeclaration(n);
  Delete(s1);
  Delete(s2);
}

// -----------------------------------------------------------------------
// JAVA::constantWrapper()
// ------------------------------------------------------------------------

int JAVA::constantWrapper(Node *n) {
  char *name      = GetChar(n,"name");
  char *iname     = GetChar(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  char     *value = GetChar(n,"value");
  ParmList  *l    = Getattr(n,"parms");

  int OldReadOnly = ReadOnly;
  String *tm;
  char *jname;
  DOH *jout;
  ReadOnly = 1;
  String *java_type = NewString("");

  if(!classdef_emitted) emit_classdef();

  if(shadow && wrapping_member) {
    jout = shadow_code;
    jname = shadow_variable_name;
  } else {
    jout = f_java;
    jname = name;
  }

  if ((tm = Swig_typemap_lookup_new("const",n,"",0))) {
    String *str = tm;
    Replace(str,"$value",value, DOH_REPLACE_ANY);
    Printf(jout,"  %s\n\n", str);
    Delete(tm);
  } else {
    if (wrapping_member) {
      Swig_typemap_attach_parms("jstype", l, 0);
      if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
        String *javaclassname = is_shadow(SwigType_base(Getattr(n,"type")));
        Replaceall(javaclassname, "enum ", "");
        Replaceall(tm,"$javaclassname", javaclassname);
        Printf(java_type,"%s", tm);
      } else {
        Printf(stderr, "No jstype typemap defined for %s\n", SwigType_str(type,0));
      }
    } else {
      Swig_typemap_attach_parms("jtype", l, 0);
      if ((tm = Swig_typemap_lookup_new("jtype",n,"",0))) {
        Printf(java_type,"%s", tm);
      } else {
        Printf(stderr, "No jtype typemap defined for %s\n", SwigType_str(type,0));
      }
    }
    if(strcmp(jname, value) == 0 || strstr(value,"::") != NULL) {
      /* 
      We have found an enum. 
      The enum implementation is done using a public final static int
      in Java. They are then initialised through a JNI call to c in a Java static block.
      */
      Printf(jout, "  public final static %s %s;\n", java_type, jname, value);

      if(shadow && wrapping_member) {
        Printv(shadow_enum_code, tab4, jname, " = ", module, ".", Swig_name_get(iname), "();\n", 0);
        /* 
        The following is a work around for an apparent bug in the swig core.
        When an enum is defined in a c++ class the emit_func_call() should 
        output ClassName::EnumName, but instead it outputs ClassName_EnumName.
        */
        Printv(f_header, "#define ", iname, " ", value, "\n", 0);
      }
      else {
        Printv(java_enum_code, tab4, jname, " = ", Swig_name_get(iname), "();\n", 0);
      }
      enum_flag = 1;
      variableWrapper(n);
      enum_flag = 0;
    } else {
      if(SwigType_type(type) == T_STRING)
        Printf(jout, "  public final static %s %s = \"%s\";\n", java_type, jname, value);
      else if(SwigType_type(type) == T_CHAR)
        Printf(jout, "  public final static String %s = \"%s\";\n", jname, value);
      else
        Printf(jout, "  public final static %s %s = %s;\n", java_type, jname, value);
    }
  }
  Delete(java_type);
  ReadOnly = OldReadOnly;
  return SWIG_OK;
}
/*
Valid Pragmas:
These pragmas start with 'allshadow' or 'module'
 modulebase         - base (extends) for the java module class
 allshadowbase      - base (extends) for all java shadow classes
 modulecode         - text (java code) is copied verbatim to the java module class
 allshadowcode      - text (java code) is copied verbatim to all java shadow classes
 moduleclassmodifiers     - class modifiers for the module class
 allshadowclassmodifiers  - class modifiers for all shadow classes
 moduleimport       - import statement generation for the java module class
 allshadowimport    - import statement generation for all java shadow classes
 moduleinterface    - interface (implements) for the module class
 allshadowinterface - interface (implements) for all shadow classes
 modulemethodmodifiers    - replaces the generated native calls' default modifiers
*/

/* 
C++ pragmas: pragmas declared within a class or c struct for the shadow class. 
These pragmas start with 'shadow'
Valid pragmas:
 shadowbase      - base (extends) for all java shadow classes
 shadowcode      - text (java code) is copied verbatim to the shadow class
 shadowclassmodifiers  - class modifiers for the shadow class
 shadowimport    - import statement generation for the shadow class
 shadowinterface - interfaces (extends) for the shadow class
*/

void JAVA::pragma(char *lang, char *code, char *value) {
  if(strcmp(lang, "java") != 0) return;

  String *strvalue = NewString(value);
  Replace(strvalue,"\\\"", "\"", DOH_REPLACE_ANY);

  if(strcmp(code, "moduleimport") == 0) {
    Printf(module_import, "import %s;\n", strvalue);
  } 
  else if(strcmp(code, "allshadowimport") == 0) {
    if(shadow && all_shadow_import)
      Printf(all_shadow_import, "import %s;\n", strvalue);
  } 
  else if(strcmp(code, "import") == 0) {
    Printf(stderr,"%s : Line %d. Ignored: Deprecated pragma. Please replace with moduleimport, shadowimport and/or allshadowimport pragmas.\n", input_file, line_number);
  }
  else if(strcmp(code, "modulecode") == 0 || strcmp(code, "module") == 0) {
    if(strcmp(code, "module") == 0)
      Printf(stderr,"%s : Line %d. Soon to be deprecated pragma. Please replace with modulecode pragma.\n", input_file, line_number);
    Printf(module_extra_code, "%s\n", strvalue);
  } 
  else if(strcmp(code, "allshadowcode") == 0 || strcmp(code, "shadow") == 0) {
    if(shadow && all_shadow_extra_code) {
      if(strcmp(code, "shadow") == 0)
        Printf(stderr,"%s : Line %d. Soon to be deprecated pragma. Please replace with allshadowcode pragma.\n", input_file, line_number);
      Printf(all_shadow_extra_code, "%s\n", strvalue);
    }
  } 
  else if(strcmp(code, "modulebase") == 0) {
    if(shadow && module_baseclass)
      Printf(module_baseclass, "%s", strvalue);
  } 
  else if(strcmp(code, "allshadowbase") == 0) {
    if(shadow && all_shadow_baseclass)
      Printf(all_shadow_baseclass, "%s", strvalue);
  } 
  else if(strcmp(code, "moduleinterface") == 0) {
    if(shadow && module_interfaces)
      if (!*Char(module_interfaces))
        Printf(module_interfaces, "implements %s", strvalue);
      else
        Printf(module_interfaces, ", %s", strvalue);
  } 
  else if(strcmp(code, "allshadowinterface") == 0) {
    if(shadow && all_shadow_interfaces) {
      if (!*Char(all_shadow_interfaces))
        Printf(all_shadow_interfaces, "implements %s", strvalue);
      else
        Printf(all_shadow_interfaces, ", %s", strvalue);
    }
  } 
  else if(strcmp(code, "allshadowclassmodifiers") == 0) {
    if(shadow && all_shadow_class_modifiers)
      Printv(all_shadow_class_modifiers, strvalue, 0);
  } 
  else if(strcmp(code, "moduleclassmodifiers") == 0) {
    if(shadow && module_class_modifiers)
      Printv(module_class_modifiers, strvalue, 0);
  } 
  else if(strcmp(code, "modulemethodmodifiers") == 0 || strcmp(code, "modifiers") == 0) {
    if(strcmp(code, "modifiers") == 0)
      Printf(stderr,"%s : Line %d. Soon to be deprecated pragma. Please replace with modulemethodmodifiers pragma.\n", input_file, line_number);
    Clear(module_method_modifiers);
    Printv(module_method_modifiers, strvalue, 0);
  } else if (shadow) {
    if (strcmp(code,"shadowcode") == 0) {
      if (f_shadow && shadow_code)
        Printf(shadow_code, "%s\n", strvalue);
      else
        Printf(stderr,"%s : Line %d. Out of scope pragma.\n", input_file, line_number);
    } 
    else if (strcmp(code,"shadowimport") == 0) {
      if (this_shadow_import)
        Printf(this_shadow_import, "import %s;\n", strvalue);
      else
        Printf(stderr,"%s : Line %d. Out of scope pragma.\n", input_file, line_number);
    } 
    else if (strcmp(code,"shadowbase") == 0) {
      if (this_shadow_baseclass)
        Printf(this_shadow_baseclass, "%s", strvalue);
      else
        Printf(stderr,"%s : Line %d. Out of scope pragma.\n", input_file, line_number);
    } 
    else if (strcmp(code,"shadowinterface") == 0) {
      if (this_shadow_interfaces) {
        if (!*Char(this_shadow_interfaces))
          Printf(this_shadow_interfaces, "implements %s", strvalue);
        else
          Printf(this_shadow_interfaces, ", %s", strvalue);
      }
      else
        Printf(stderr,"%s : Line %d. Out of scope pragma.\n", input_file, line_number);
    } 
    else if (strcmp(code,"shadowclassmodifiers") == 0) {
      if (this_shadow_class_modifiers)
        Printv(this_shadow_class_modifiers, strvalue, 0);
      else
        Printf(stderr,"%s : Line %d. Out of scope pragma.\n", input_file, line_number);
    }  else {
      Printf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
    }
  } else {
    Printf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
  }
  Delete(strvalue);
}

void JAVA::emit_shadow_classdef() {
  String* baseclass = NULL;

  // Import statements
  if(all_shadow_import)
    Printf(shadow_classdef, "%s", all_shadow_import);
  if(this_shadow_import)
    Printf(shadow_classdef, "%s", this_shadow_import);
  Printf(shadow_classdef, "\n");

  // Class modifiers
  if (this_shadow_class_modifiers && *Char(this_shadow_class_modifiers))
    Printv(shadow_classdef, this_shadow_class_modifiers, 0);
  else if (all_shadow_class_modifiers && *Char(all_shadow_class_modifiers))
    Printv(shadow_classdef, all_shadow_class_modifiers, 0);
  else
    Printv(shadow_classdef, "public", 0);
  if (abstract_class_flag)
    Printv(shadow_classdef, " abstract", 0);
  Printf(shadow_classdef, " class $class ");

  // Inherited classes
  if(this_shadow_baseclass && *Char(this_shadow_baseclass)) {
    Printf(shadow_classdef, "extends %s ", this_shadow_baseclass);
    baseclass = this_shadow_baseclass;
  }
  if(all_shadow_baseclass && *Char(all_shadow_baseclass)) {
    Printf(shadow_classdef, "extends %s ", all_shadow_baseclass);
    baseclass = all_shadow_baseclass;
  }

  // Implemented interfaces
  if(this_shadow_interfaces && *Char(this_shadow_interfaces))
    Printv(shadow_classdef, this_shadow_interfaces, " ", 0);
  Printf(shadow_classdef, "{\n");

  //Display warning on attempt to use multiple inheritance
  char* search_str = Char(shadow_classdef);
  int count = 0;
  while((search_str = strstr(search_str, "extends"))) {
    search_str += strlen("extends");
    count++;
  }
  if (count > 1)
    Printf(stderr, "Warning for shadow class %s: Multiple inheritance is not supported in Java.\n", shadow_classname);

  // Different code depending on whether or not the base class is a SWIG shadow class
  if (baseclass && is_shadow(baseclass)) {
    Printv(shadow_classdef,
      "  public $class(long cPointer, boolean cMemoryOwn) {\n",
      "    super(cPointer, cMemoryOwn);\n",
      "  }\n",
      "\n", 0);

    if(!have_default_constructor) {
      Printv(shadow_classdef, 
        "  protected $class() {\n",
        "  }\n",
        "\n", 0);
    }
    // Control which super constructor is called - we don't want 2 malloc/new c/c++ calls
    Replace(shadow_code, "$superconstructorcall", "    super(0, false);\n", DOH_REPLACE_ANY);
  }
  else {
    Printv(shadow_classdef,
      "  protected long _cPtr;\n",
      "  protected boolean _cMemOwn;\n",
      "\n",
      "  public $class(long cPointer, boolean cMemoryOwn) {\n",
      "    _cPtr = cPointer;\n",
      "    _cMemOwn = cMemoryOwn;\n",
      "  }\n",
      "\n",
      "  public long getCPtr() {\n",
      "    return _cPtr;\n",
      "  }\n",
      "\n", 0);

    if(!have_default_constructor) {
      Printv(shadow_classdef, 
        "  protected $class() {\n",
        "    _cPtr = 0;\n",
        "    _cMemOwn = false;\n",
        "  }\n",
        "\n", 0);
    }
    // No explicit super constructor call as this class does not have a SWIG base class.
    Replace(shadow_code, "$superconstructorcall", "", DOH_REPLACE_ANY);
  }

  Replace(shadow_classdef, "$class", shadow_classname, DOH_REPLACE_ANY);

  if (all_shadow_extra_code)
    Printv(shadow_classdef, all_shadow_extra_code, 0);

  if (this_shadow_extra_code)
    Printv(shadow_classdef, this_shadow_extra_code, 0);
}

int JAVA::classHandler(Node *n) {

  if (shadow) {
    char *classname = GetChar(n,"name");
    char *rename = GetChar(n,"sym:name");
    char *ctype  = GetChar(n,"kind");
    
    shadow_classname = Swig_copy_string(rename);
    
    if (strcmp(shadow_classname, module) == 0) {
      Printf(stderr, "class name cannot be equal to module name: %s\n", shadow_classname);
      SWIG_exit(1);
    }
/*    
    Setattr(shadow_classes,classname, shadow_classname);
    if(ctype && strcmp(ctype, "struct") == 0) {
      sprintf(bigbuf, "struct %s", classname);
      Setattr(shadow_classes, bigbuf, shadow_classname);
    }
   */ 
    sprintf(bigbuf, "%s.java", shadow_classname);
    if(!(f_shadow = fopen(bigbuf, "w"))) {
      Printf(stderr, "Unable to create shadow class file: %s\n", bigbuf);
    }
    
    emit_banner(f_shadow);
    
    if(*package)
      Printf(f_shadow, "package %s;\n\n", package);
    else 
      Printf(f_shadow, "import %s;\n", module);
    
    Clear(shadow_classdef);
    Clear(shadow_code);
    
    abstract_class_flag = 0;
    have_default_constructor = 0;
    shadow_enum_code = NewString("");
    this_shadow_baseclass =  NewString("");
    this_shadow_extra_code = NewString("");
    this_shadow_interfaces = NewString("");
    this_shadow_import = NewString("");
    this_shadow_class_modifiers = NewString("");
    if(all_shadow_interfaces)
      Printv(this_shadow_interfaces, all_shadow_interfaces, 0);
  }
  Language::classHandler(n);

  if (shadow) {

    /* Deal with inheritance */
    List *baselist = Getattr(n,"bases");
    if (baselist) {
      Node *base = Firstitem(baselist);
      String *basename = is_shadow(Getattr(base,"name"));
      if (basename)
        Printv(this_shadow_baseclass, basename, 0);
      base = Nextitem(baselist);
      if (base) {
        Printf(stderr, "Warning: %s inherits from multiple base classes. Multiple inheritance is not supported.\n", shadow_classname);
      }
    }

    emit_shadow_classdef();

    Printv(f_shadow, shadow_classdef, shadow_code, 0);

    // Write the enum initialisation code in a static block.
    // These are all the enums defined within the c++ class.
    if (strlen(Char(shadow_enum_code)) != 0 )
      Printv(f_shadow, "  static {\n  // Initialise java constants from c++ enums\n", shadow_enum_code, "  }\n",0);

    Printf(f_shadow, "}\n");
    fclose(f_shadow);
    f_shadow = NULL;
    
    free(shadow_classname);
    shadow_classname = NULL;
    
    Delete(shadow_enum_code); shadow_enum_code = NULL;
    Delete(this_shadow_baseclass); this_shadow_baseclass = NULL;
    Delete(this_shadow_extra_code); this_shadow_extra_code = NULL;
    Delete(this_shadow_interfaces); this_shadow_interfaces = NULL;
    Delete(this_shadow_import); this_shadow_import = NULL;
    Delete(this_shadow_class_modifiers); this_shadow_class_modifiers = NULL;
  }
  return SWIG_OK;
}


int JAVA::memberfunctionHandler(Node *n) {
  Language::memberfunctionHandler(n);

  if (shadow) {
    String* java_function_name = Swig_name_member(shadow_classname, Getattr(n, "sym:name"));
    Setattr(n,"java:shadfuncname", Getattr(n, "sym:name"));
    Setattr(n,"java:funcname", java_function_name);
    javashadowfunctionHandler(n, IsVirtual);
  }
  return SWIG_OK;
}

int JAVA::staticmemberfunctionHandler(Node *n) {

  Language::staticmemberfunctionHandler(n);

  if (shadow) {
    String* java_function_name = Swig_name_member(shadow_classname, Getattr(n,"sym:name"));
    Setattr(n,"java:shadfuncname", Getattr(n,"sym:name"));
    Setattr(n,"java:funcname", java_function_name);
    static_flag = 1;
    javashadowfunctionHandler(n, NOT_VIRTUAL);
    static_flag = 0;
  }
  return SWIG_OK;
}

/* 
Function called for creating a java class wrapper function around a c++ function in the 
java wrapper class. Used for both static and non static functions.
C++ static functions map to java static functions.
Two extra attributes in the Node must be available. These are "java:shadfuncname" - the name of the java class shadow 
function, which in turn will call "java:funcname" - the java native function name which wraps the c++ function.
*/
void JAVA::javashadowfunctionHandler(Node* n, int is_virtual) {
  SwigType  *t = Getattr(n,"type");
  ParmList  *l = Getattr(n,"parms");
  String*   java_function_name = Getattr(n,"java:funcname");
  String*   java_shadow_function_name = Getattr(n,"java:shadfuncname");
  char      arg[256];
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

  if ((tm = Swig_typemap_lookup_new("jstype",n,"",0))) {
    String *javaclassname = is_shadow(SwigType_base(Getattr(n,"type")));
    Replaceall(tm,"$javaclassname", javaclassname);
    Printf(shadowrettype,"%s", tm);
  } else {
    Printf(stderr, "No jstype typemap defined for %s\n", SwigType_str(t,0));
  }

  Printf(shadow_code, "  public ");
  if (static_flag)
    Printf(shadow_code, "static ");
  if (is_virtual == PURE_VIRTUAL)
    Printf(shadow_code, "abstract ");
  Printf(shadow_code, "%s %s(", shadowrettype, java_shadow_function_name);

  if(SwigType_type(t) == T_ARRAY && is_shadow(get_array_type(t))) {
    Printf(nativecall, "long[] cArray = ");
  }
  else {
    if(SwigType_type(t) != T_VOID) {
      Printf(nativecall,"return ");
    }
    if(is_shadow(t)) {
      Printv(nativecall, "new ", shadowrettype, "(", 0);
    }
  }

  Printv(nativecall, module, ".", java_function_name, "(", 0);
  if (!static_flag)
    Printv(nativecall, "_cPtr", 0);

  /* Get number of required and total arguments */
  num_arguments = emit_num_arguments(l);
  num_required  = emit_num_required(l);

  int gencomma = !static_flag;

/* Workaround to overcome Getignore(p) not working - p does not always have the Getignore 
attribute set. Noticeable when javashadowfunctionHandlerk is called from memberfunctionHandler() */
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
      String   *pn = Getattr(p,"name");
      String   *javaparamtype = NewString("");
  
      /* Get the java type of the parameter */
      if ((tm = Getattr(jstypep,"tmap:jstype"))) {
        String *javaclassname = is_shadow(SwigType_base(pt));
        Replaceall(tm,"$javaclassname", javaclassname);
        jstypep = Getattr(jstypep,"tmap:jstype:next");
        Printv(javaparamtype, tm, 0);
      } else {
        jstypep = nextSibling(jstypep);
        Printf(stderr, "No jstype typemap defined for %s\n", SwigType_str(pt,0));
      }

      /* Produce string representation of source and target arguments */
      if(pn && *(Char(pn)))
        strcpy(arg,Char(pn));
      else {
        sprintf(arg,"arg%d",i);
      }
  
      if (gencomma)
        Printf(nativecall, ", ");

      if(SwigType_type(pt) == T_ARRAY && is_shadow(get_array_type(pt))) {
        Printv(user_arrays, tab4, "long[] $arg_cArray = new long[$arg.length];\n", 0);
        Printv(user_arrays, tab4, "for (int i=0; i<$arg.length; i++)\n", 0);
        Printv(user_arrays, tab4, "  $arg_cArray[i] = $arg[i].getCPtr();\n", 0);
        Replace(user_arrays, "$arg", pn, DOH_REPLACE_ANY);

        Printv(nativecall, arg, "_cArray", 0);
      } else if (is_shadow(pt)) {
        Printv(nativecall, arg, ".getCPtr()", 0);
      } else Printv(nativecall, arg, 0);
      /* Add to java shadow function header */
      if (gencomma >= 2)
        Printf(shadow_code, ", ");
      gencomma = 2;
      Printf(shadow_code, "%s %s", javaparamtype, arg);

      Delete(javaparamtype);
    }
    else {
      jstypep = nextSibling(jstypep);
    }

    p = nextSibling(p);
  }

  if(SwigType_type(t) == T_ARRAY && is_shadow(get_array_type(t))) {
    String* array_ret = NewString("");
    String* array_type = NewString("");
    Printf(array_ret,");\n");
    Printv(array_ret, tab4, "$type[] arrayWrapper = new $type[cArray.length];\n", 0);
    Printv(array_ret, tab4, "for (int i=0; i<cArray.length; i++)\n", 0);
    Printv(array_ret, tab4, "  arrayWrapper[i] = new $type(cArray[i], false);\n", 0);
    Printv(array_ret, tab4, "return arrayWrapper;\n", 0);

    // Hack the jstype typemap apart
    Printv(array_type, shadowrettype, 0);
    Replaceall(array_type,"[]", "");

    Replace(array_ret, "$type", array_type, DOH_REPLACE_ANY);
    Printv(nativecall, array_ret, 0);
    Delete(array_ret);
    Delete(array_type);
  }
  else {
    if(is_shadow(t)) {
      switch(SwigType_type(t)) {
      case T_USER:
        Printf(nativecall, "), true");
        break;
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

  if (is_virtual == PURE_VIRTUAL) {
    Printf(shadow_code, ");\n\n");
    abstract_class_flag = 1;
  }
  else {
    Printf(shadow_code, ") {\n");
    Printv(shadow_code, user_arrays, 0);
    Printf(shadow_code, "    %s", nativecall);
    Printf(shadow_code, "  }\n\n");
  }

  Delete(shadowrettype);
  Delete(nativecall);
  Delete(user_arrays);
}

int JAVA::constructorHandler(Node *n) {

  char *iname = GetChar(n,"sym:name");
  ParmList *l = Getattr(n,"parms");
  String    *tm;
  Parm      *jstypep;
  Parm      *p;
  int       i;
  int       num_arguments = 0;
  int       num_required = 0;

  Language::constructorHandler(n);

  if(shadow) {
    String *nativecall = NewString("");
    char arg[256];
  
    Printf(shadow_code, "  public %s(", shadow_classname);
  
    Printv(nativecall, "$superconstructorcall", 0); // Super call for filling in later.
    if (iname != NULL)
      Printv(nativecall, tab4, "_cPtr = ", module, ".", Swig_name_construct(iname), "(", 0);
    else
      Printv(nativecall, tab4, "_cPtr = ", module, ".", Swig_name_construct(shadow_classname), "(", 0);
  
    int pcount = ParmList_len(l);
    if(pcount == 0)  // We must have a default constructor
      have_default_constructor = 1;
  
    Swig_typemap_attach_parms("jstype", l, 0);

    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required  = emit_num_required(l);
  
    for (i = 0, p=l, jstypep=l; i < num_arguments; i++) {
      SwigType *pt = Getattr(p,"type");
      String   *pn = Getattr(p,"name");
      String   *javaparamtype = NewString("");
  
      /* Produce string representation of source and target arguments */
      if(pn && *(Char(pn)))
        strcpy(arg,Char(pn));
      else {
        sprintf(arg,"arg%d",i);
      }
  
      if(is_shadow(pt)) {
        Printv(nativecall, arg, ".getCPtr()", 0);
      } else Printv(nativecall, arg, 0);
  
      /* Get the java type of the parameter */
      if ((tm = Getattr(jstypep,"tmap:jstype"))) {
        String *javaclassname = is_shadow(SwigType_base(pt));
        Replaceall(tm,"$javaclassname", javaclassname);
        jstypep = Getattr(jstypep,"tmap:jstype:next");
        Printv(javaparamtype, tm, 0);
      } else {
        jstypep = nextSibling(jstypep);
        Printf(stderr, "No jstype typemap defined for %s\n", SwigType_str(pt,0));
      }
  
      /* Add to java shadow function header */
      Printf(shadow_code, "%s %s", javaparamtype, arg);
  
      if(i != pcount-1) {
        Printf(nativecall, ", ");
        Printf(shadow_code, ", ");
      }
      p = nextSibling(p);
      Delete(javaparamtype);
    }
  
    Printf(shadow_code, ") {\n");
    Printv(nativecall,
  	  ");\n",
  	  tab4, "_cMemOwn = true;\n",
  	  0);
  
    Printf(shadow_code, "%s", nativecall);
    Printf(shadow_code, "  }\n\n");
    Delete(nativecall);
  }
  return SWIG_OK;
}

int JAVA::destructorHandler(Node *n) {
  Language::destructorHandler(n);

  if(shadow) {
    if(!nofinalize) {
      Printf(shadow_code, "  protected void finalize() {\n");
      Printf(shadow_code, "    _delete();\n");
      Printf(shadow_code, "  }\n\n");
    }
  
    Printf(shadow_code, "  public void _delete() {\n");
    Printf(shadow_code, "    if(_cPtr!=0 && _cMemOwn) {\n");
    Printf(shadow_code, "      %s.%s(_cPtr);\n", module, Swig_name_destroy(shadow_classname));
    Printf(shadow_code, "      _cPtr = 0;\n");
    Printf(shadow_code, "    }\n");
    Printf(shadow_code, "  }\n\n");
  }
  return SWIG_OK;
}

/* This function does the equivalent to
 * %apply enum SWIGTYPE[ANY] {name[ANY]}; */
void JAVA::TypemapApplyEnum(String* name)
{
    SwigType* SWIGTYPE_type = NewStringf("a(ANY).enum SWIGTYPE");
    Parm *srcpat = NewParm(SWIGTYPE_type,0);
    Parm *destpat = NewParm(name,0);
    Swig_typemap_apply(srcpat,destpat);
    Delete(SWIGTYPE_type);
}

/* This function does the equivalent to
 * %apply SWIGTYPE *CLASS { name * };  when pointer_flag set or
 * %apply SWIGTYPE &CLASS { name & };  when pointer_flag unset  */
void JAVA::TypemapApplyClass(String* name, int pointer_flag)
{
    SwigType* SWIGTYPE_type = NewStringf("SWIGTYPE");
    SwigType* CLASS_type = NewString("CLASS");
    String* stype = Copy(name);

    if (pointer_flag) {
        SwigType_add_pointer(SWIGTYPE_type);
        SwigType_add_pointer(stype);
    }
    else {
        SwigType_add_reference(SWIGTYPE_type);
        SwigType_add_reference(stype);
    }

    Parm *srcpat = NewParm(SWIGTYPE_type,CLASS_type);
    Parm *destpat = NewParm(stype,0);
    Swig_typemap_apply(srcpat,destpat);
    Delete(SWIGTYPE_type);
    Delete(CLASS_type);
    Delete(stype);
}

int JAVA::classforwardDeclaration(Node *n) {
  String *name = Getattr(n,"name");
  String *kind   = Getattr(n,"kind");

  /* Add to the hash table of shadow classes */
  if (shadow) {
    String *shadowclassname = Getattr(n,"sym:name");
    Setattr(shadow_classes,name,shadowclassname);
    if (kind && (Len(kind) > 0)) {
      String *stype = NewStringf("%s %s",kind,name);
      Setattr(shadow_classes,stype,shadowclassname);
      Delete(stype);
    }
  }

  /* The Java typemaps need the following typemaps to exist for handling pointers
     and references to classes/structs/unions:
     %typemap(whatever)  SWIGTYPE *CLASS { ... }
     %typemap(whatever)  SWIGTYPE &CLASS { ... }
     Now we must apply these typemaps to all known classes */
  TypemapApplyClass(name, 1);
  TypemapApplyClass(name, 0);

  /* More typemap applying for types declared with the kind eg struct, union or class
     for example when type is declared as 'struct structname'
     %typemap(whatever)  SWIGTYPE *CLASS { kind ... }
     %typemap(whatever)  SWIGTYPE &CLASS { kind ... } */
  if (Cmp(Getattr(n,"storage"), "typedef") != 0) {
    String *namewithkind = NewString("");
    Printf(namewithkind, "%s %s", Getattr(n,"kind"), name);
    TypemapApplyClass(namewithkind, 1);
    TypemapApplyClass(namewithkind, 0);
    Delete(namewithkind);
  }
  return SWIG_OK;
}

int JAVA::membervariableHandler(Node *n) {
  shadow_variable_name = GetChar(n,"sym:name");
  wrapping_member = 1;
  variable_wrapper_flag = 1;
  Language::membervariableHandler(n);
  wrapping_member = 0;
  variable_wrapper_flag = 0;
  return SWIG_OK;
}

int JAVA::staticmembervariableHandler(Node *n) {
  shadow_variable_name = GetChar(n,"sym:name");
  wrapping_member = 1;
  static_flag = 1;
  Language::staticmembervariableHandler(n);
  wrapping_member = 0;
  static_flag = 0;
  return SWIG_OK;
}

int JAVA::memberconstantHandler(Node *n) {
  shadow_variable_name = GetChar(n,"sym:name");
  wrapping_member = 1;
  Language::memberconstantHandler(n);
  wrapping_member = 0;
  return SWIG_OK;
}







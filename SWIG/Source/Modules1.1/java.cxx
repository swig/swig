/*******************************************************************************
 * SWIG Java module
 * Author: Harco de Hilster
 *	   AT Consultancy
 *	   Toernooiveld 104
 *	   P.O. Box 1428
 *	   6501 BK Nijmegen
 *	   +31 24 3527282
 *	   harcoh@ATConsultancy.nl
 *
 * thanks to the following persons for submitting bug-reports:
 *
 *	James Hicks <jamey@crl.dec.com>
 *    	Lars Schmidt-Thieme <lschmidt@ix.urz.uni-heidelberg.de>
 *	Per OEyvind Hvidsten Per-Oyvind.Hvidsten@ffi.no
 *	Geoff Dillon <gdillon@pervasive.com>
 *    	Michael Haller <haller@lionbio.co.uk>
 *    	"Simon J. Julier" <sjulier@erols.com>
 *      "Pritam Kamat" <pritam@alier.com>
 *      Marc Hadley <marc_hadley@chrystal.co.uk>
 *******************************************************************************
*/

#include <ctype.h>

#include "mod11.h"
#include "java.h"

char bigbuf[1024];

static char *usage = "\
Java Options\n\
     -jnic            - use c syntax for jni calls\n\
     -jnicpp          - use c++ syntax for jni calls\n\
     -module name     - set name of module\n\
     -package name    - set name of package\n\
     -shadow          - enable shadow classes\n\
     -finalize        - generate finalize methods\n\
     -rn              - generate register natives code\n\n";

char *JAVA::SwigTcToJniType(DataType *t, int ret) {
  if(t->is_pointer == 1) {
	  switch(t->type) {
	    case T_INT:		return "jintArray";
	    case T_SHORT:	return "jshortArray";
	    case T_LONG:	return "jlongArray";
	    case T_CHAR:	return "jstring";
	    case T_FLOAT:	return "jfloatArray";
	    case T_DOUBLE:	return "jdoubleArray";
	    case T_UINT:	return "jintArray";
	    case T_USHORT:	return "jshortArray";
	    case T_ULONG:	return "jlongArray";
	    case T_UCHAR:	return "jbyteArray";
	    case T_SCHAR:	return "jbyteArray";
	    case T_BOOL:	return "jbooleanArray";
	    case T_VOID:	
	    case T_USER:	return "jlong";
	  }
  } else if(t->is_pointer > 1) {
    if(ret)
	return "jlong";
    else return "jlongArray";
  } else {
	  switch(t->type) {
	    case T_INT: return "jint";
	    case T_SHORT: return "jshort";
	    case T_LONG: return "jlong";
	    case T_CHAR: return "jbyte";
	    case T_FLOAT: return "jfloat";
	    case T_DOUBLE: return "jdouble";
	    case T_UINT: return "jint";
	    case T_USHORT: return "jshort";
	    case T_ULONG: return "jlong";
	    case T_UCHAR: return "jbyte";
	    case T_SCHAR: return "jbyte";
	    case T_BOOL: return "jboolean";
	    case T_VOID: return "void";
	    case T_USER: return "jlong";
	  }
  }
  fprintf(stderr, "SwigTcToJniType: unhandled SWIG type %d, %s\n", t->type, (char *) t->name);
  return NULL;
}

char *JAVA::SwigTcToJavaType(DataType *t, int ret, int inShadow) {
  if(t->is_pointer == 1) {
	  switch(t->type) {
	    case T_INT:    return "int []";
	    case T_SHORT:  return "short []";
	    case T_LONG:   return "long []";
	    case T_CHAR:   return "String";
	    case T_FLOAT:  return "float []";
	    case T_DOUBLE: return "double []";
	    case T_UINT:   return "int []";
	    case T_USHORT: return "short []";
	    case T_ULONG:  return "long []";
	    case T_UCHAR:  return "byte []";
	    case T_SCHAR:  return "byte []";
	    case T_BOOL:   return "boolean []";
	    case T_VOID:
        case T_USER:   if(inShadow && Getattr(shadow_classes,t->name))
                         return GetChar(shadow_classes,t->name);
                       else return "long";
	  }
  } else if(t->is_pointer > 1) {
    if(ret)
	  return "long";
    else return "long []";
  } else {
	  switch(t->type) {
	    case T_INT: return "int";
	    case T_SHORT: return "short";
	    case T_LONG: return "long";
	    case T_CHAR: return "byte";
	    case T_FLOAT: return "float";
	    case T_DOUBLE: return "double";
	    case T_UINT: return "int";
	    case T_USHORT: return "short";
	    case T_ULONG: return "long";
	    case T_UCHAR: return "byte";
	    case T_SCHAR: return "byte";
	    case T_BOOL: return "boolean";
	    case T_VOID: return "void";
	    case T_USER: return "long";
	  }
  }
  fprintf(stderr, "SwigTcToJavaType: unhandled SWIG type %d, %s\n", t->type, (char *) t->name);
  return NULL;
}

char *JAVA::SwigTcToJniScalarType(DataType *t) {
  if(t->is_pointer == 1) {
	  switch(t->type) {
	    case T_INT: return "Int";
	    case T_SHORT: return "Short";
	    case T_LONG: return "Long";
	    case T_CHAR: return "Byte";
	    case T_FLOAT: return "Float";
	    case T_DOUBLE: return "Double";
	    case T_UINT: return "Int";
	    case T_USHORT: return "Short";
	    case T_ULONG: return "Long";
	    case T_UCHAR: return "Byte";
	    case T_SCHAR: return "Byte";
	    case T_BOOL: return "Boolean";
            case T_VOID:
	    case T_USER: return "Long";
	  }
  } else {
    return "Long";
  }

  fprintf(stderr, "SwigTcToJniScalarType: unhandled SWIG type %d, %s\n", t->type, (char *) t->name);
  return NULL;
}

char *JAVA::JavaMethodSignature(DataType *t, int ret, int inShadow) {
  if(t->is_pointer == 1) {
	  switch(t->type) {
	   case T_INT:    return "[I";
	    case T_SHORT:  return "[S";
	    case T_LONG:   return "[J";
	    case T_CHAR:   return "Ljava/lang/String;";
	    case T_FLOAT:  return "[F";
	    case T_DOUBLE: return "[D";
	    case T_UINT:   return "[I";
	    case T_USHORT: return "[S";
	    case T_ULONG:  return "[J";
	    case T_UCHAR:  return "[B";
	    case T_SCHAR:  return "[B";
	    case T_BOOL:   return "[Z";
	    case T_VOID:
        case T_USER:   if(inShadow && Getattr(shadow_classes,t->name))
                         return GetChar(shadow_classes,t->name);
                       else return "J";
	  }
  } else if(t->is_pointer > 1) {
    if(ret) return "J";
    else return "[J";
  } else {
	  switch(t->type) {
	    case T_INT: return "I";
	    case T_SHORT: return "S";
	    case T_LONG: return "J";
	    case T_CHAR: return "B";
	    case T_FLOAT: return "F";
	    case T_DOUBLE: return "D";
	    case T_UINT: return "I";
	    case T_USHORT: return "S";
	    case T_ULONG: return "J";
	    case T_UCHAR: return "B";
	    case T_SCHAR: return "B";
	    case T_BOOL: return "Z";
	    case T_VOID: return "V";
	    case T_USER: return "J";
	  }
  }
  fprintf(stderr, "JavaMethodSignature: unhandled SWIG type %d, %s\n", t->type, (char *) t->name);
  return NULL;
}

char *JAVA::JavaTypeFromTypemap(char *op, char *lang, DataType *t, char *pname) {
  char *tm;
  char *c = bigbuf;
  if(!(tm = typemap_lookup(op, lang, t, pname, "", ""))) return NULL;
  while(*tm && (isspace(*tm) || *tm == '{')) tm++;
  while(*tm && *tm != '}') *c++ = *tm++;
  *c='\0';

  return strdup(bigbuf);
}

char *JAVA::makeValidJniName(char *name) {
  char *c = name;
  char *b = bigbuf;

  while(*c) {
    *b++ = *c;
    if(*c == '_') *b++ = '1';
    c++;
  }
  *b = '\0';

  return strdup(bigbuf);
}

// !! this approach fails for functions without arguments
char *JAVA::JNICALL(String& func) {
  if(jnic)
	sprintf(bigbuf, "(*jenv)->%s(jenv, ", (char *) func);
  else
	sprintf(bigbuf, "jenv->%s(", (char *) func);

  return strdup(bigbuf);
}

// !! this approach fails for functions without arguments
char *JAVA::JNICALL(char *func) {
  if(jnic)
	sprintf(bigbuf, "(*jenv)->%s(jenv, ", func);
  else
	sprintf(bigbuf, "jenv->%s(", func);

  return strdup(bigbuf);
}

void JAVA::writeRegisterNatives()
{
  if(strlen(registerNativesList.get()) == 0)
    return;

  fprintf(f_wrappers,"\n");
  fprintf(f_wrappers,"JNINativeMethod nativeMethods[] = {\n");
  fprintf(f_wrappers, registerNativesList.get());
  fprintf(f_wrappers, "};\n");
  
  fprintf(f_wrappers,"\nint numberOfNativeMethods=sizeof(nativeMethods)/sizeof(JNINativeMethod);\n\n");

  // The registerNatives function
  String registerFunction;

  registerFunction << "jint registerNatives(JNIEnv *jenv) {" << endl
                   << tab4 << "jclass nativeClass = " << JNICALL("FindClass")
                   << "\"" << jni_pkgstr << module << "\");" <<endl;
  registerFunction << tab4 << "if (nativeClass == 0)" << endl << tab8 << "return -1;" << endl;

  registerFunction << tab4 << "return " << JNICALL("RegisterNatives") << "nativeClass, nativeMethods, " << "numberOfNativeMethods);" << endl;
  registerFunction << "}" << endl << endl;

  // The unregisterNatives function

  registerFunction << "jint unregisterNatives(JNIEnv *jenv) {" << endl
                   << tab4 << "jclass nativeClass = " << JNICALL("FindClass")
                   << "\"" << jni_pkgstr << module << "\");" <<endl;
  registerFunction << tab4 << "if (nativeClass == 0)" << endl << tab8 << "return -1;" << endl;
  registerFunction << tab4 << "// Sun documentation suggests that this method should not be invoked in "
                   << "\"normal native code\"." << endl;
  registerFunction << tab4 << "// return " << JNICALL("UnregisterNatives") << "nativeClass);" << endl;
  registerFunction << tab4 << "return 0;" << endl;
  registerFunction << "}" << endl;

  // Now write the C function
  fprintf(f_wrappers,registerFunction.get());
}

// ---------------------------------------------------------------------
// JAVA::parse_args(int argc, char *argv[])
//
// Parse my command line options and initialize by variables.
// ---------------------------------------------------------------------

void JAVA::parse_args(int argc, char *argv[]) {

  // file::set_library(java_path);
  sprintf(LibDir,"%s", "java");


  // Look for certain command line options
  for (int i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i],"-module") == 0) {
	if (argv[i+1]) {
	  set_module(argv[i+1],0);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i+1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i],"-package") == 0) {
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
      } else if (strcmp(argv[i],"-finalize") == 0) {
	    Swig_mark_arg(i);
        finalize = 1;
      } else if (strcmp(argv[i],"-rn") == 0) {
	    Swig_mark_arg(i);
        useRegisterNatives = 1;
      } else if (strcmp(argv[i],"-jnicpp") == 0) {
        Swig_mark_arg(i);
	    jnic = 0;
      } else if (strcmp(argv[i],"-help") == 0) {
	    fprintf(stderr,"%s\n", usage);
      }
    }
  }

  if(jnic == -1) {
    if(CPlusPlus)
	jnic = 0;
    else jnic = 1;
  }

  // Add a symbol to the parser for conditional compilation
  // cpp::define("SWIGJAVA");
  Preprocessor_define((void *) "SWIGJAVA 1",0);

  // Add typemap definitions
  typemap_lang = "java";
}

// ---------------------------------------------------------------------
// void JAVA::parse()
//
// Start parsing an interface file for JAVA.
// ---------------------------------------------------------------------

void JAVA::parse() {

  fprintf(stderr,"Generating wrappers for Java\n");

  headers();       // Emit header files and other supporting code

/*
  // Tell the parser to first include a typemap definition file

  if (include_file("typemaps.i") == -1) {
    fprintf(stderr,"Unable to find typemaps.i!\n");
    SWIG_exit(1);
  }
*/
  yyparse();       // Run the SWIG parser
}

// ---------------------------------------------------------------------
// JAVA::set_module(char *mod_name,char **mod_list)
//
// Sets the module name.  Does nothing if it's already set (so it can
// be overriddent as a command line option).
//
// mod_list is a NULL-terminated list of additional modules.  This
// is really only useful when building static executables.
//----------------------------------------------------------------------

void JAVA::set_module(char *mod_name, char **mod_list) {
  if (module) return;
  module = new char[strlen(mod_name)+1];
  strcpy(module,mod_name);
}

// ---------------------------------------------------------------------
// JAVA::headers(void)
//
// Generate the appropriate header files for JAVA interface.
// ----------------------------------------------------------------------

void JAVA::headers(void)
{
  emit_banner(f_header);               // Print the SWIG banner message
  fprintf(f_header,"/* Implementation : Java */\n\n");

  // Include header file code fragment into the output
  // if (file::include("java.swg",f_header) == -1) {
  if (Swig_insert_file("java.swg",f_header) == -1) {
    fprintf(stderr,"Fatal Error. Unable to locate 'java.swg'.\n");
    SWIG_exit(1);
  }
}

// --------------------------------------------------------------------
// JAVA::initialize(void)
//
// Produces an initialization function.   Assumes that the init function
// name has already been specified.
// ---------------------------------------------------------------------

void JAVA::initialize() 
{
  if (!module) {
    fprintf(stderr,"*** Error. No module name specified.\n");
    SWIG_exit(1);
  }

  if(package) {
    String s = package;
    s.replace(".", "_");
    s << "_";
    c_pkgstr = copy_string(s.get());

    String s2 = package;
    s2.replace(".", "/");
    s2 << "/";
    jni_pkgstr = copy_string(s2.get());
  } else {
    package = c_pkgstr = jni_pkgstr = "";
  }
    
  sprintf(bigbuf, "Java_%s%s", c_pkgstr, module);
  c_pkgstr = copy_string(bigbuf);
  sprintf(bigbuf, "%s_%%f", c_pkgstr);
  name_register("wrapper", copy_string(bigbuf));
  name_register("set", "set_%v");
  name_register("get", "get_%v");
  name_register("member", "%c_%f"); 
 
  // Generate the java class
  sprintf(bigbuf, "%s.java", module);
  if((f_java = fopen(bigbuf, "w")) == 0) {
    fprintf(stderr,"Unable to open %s\n", bigbuf);
    SWIG_exit(1);
  }

  fprintf(f_header, "#define J_CLASSNAME %s\n", module);
  if(package && *package) {
    fprintf(f_java, "package %s;\n\n", package);
    fprintf(f_header, "#define J_PACKAGE %s\n", package);
  } else {
    fprintf(f_header, "#define J_PACKAGE\n");
  }
}

void JAVA::emit_classdef() {
  if(!classdef_emitted)
    fprintf(f_java, "public class %s {\n", module);
  classdef_emitted = 1;
}

// ---------------------------------------------------------------------
// JAVA::close(void)
//
// Wrap things up.  Close initialization function.
// ---------------------------------------------------------------------

void JAVA::close(void)
{
  if(!classdef_emitted) emit_classdef();

  // Finish off the java class
  fprintf(f_java, "}\n");
  fclose(f_java);

  if(useRegisterNatives)
	writeRegisterNatives();
}

// ----------------------------------------------------------------------
// JAVA::create_command(char *cname, char *iname)
//
// Creates a JAVA command from a C function.
// ----------------------------------------------------------------------

void JAVA::create_command(char *cname, char *iname) {
}

void JAVA::add_native(char *name, char *iname, DataType *t, ParmList *l) {
  native_func = 1;
  create_function(name, iname, t, l);
  native_func = 0;
}

// ----------------------------------------------------------------------
// JAVA::create_function(char *name, char *iname, DataType *d, ParmList *l)
//
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

void JAVA::create_function(char *name, char *iname, DataType *t, ParmList *l)
{
  String	source, target;
  char		*tm;
  String	cleanup, outarg;
  String	body;
  char		*javaReturnSignature;
  String	javaParameterSignature;

  // A new wrapper function object
  WrapperFunction  f;

  if(!classdef_emitted) emit_classdef();

  // Make a wrapper name for this function
  
  char *jniname = makeValidJniName(iname);
  char *wname = name_wrapper(jniname,package);
  free(jniname);

  char *jnirettype = JavaTypeFromTypemap("jni", typemap_lang, t, iname);
  if(!jnirettype) jnirettype = SwigTcToJniType(t, 1);
  char *javarettype = JavaTypeFromTypemap("jtype", typemap_lang, t, iname);
  if(!javarettype) javarettype = SwigTcToJavaType(t, 1, 0);

  // If dumping the registerNative outputs, store the method return type
  // signature
  if (useRegisterNatives) {
      javaReturnSignature = JavaMethodSignature(t, 1, 0);
  }

  if(t->type != T_VOID || t->is_pointer) {
	 f.add_local(jnirettype, "_jresult", "0");
  }

  fprintf(f_java, "  %s ", method_modifiers);
  fprintf(f_java, "native %s %s(", javarettype, iname);
  if(shadow && member_func) {
    String member_name = "";
    if(strcmp(iname, name_set(name_member(shadow_name, shadow_classname))) == 0)
	member_name << "set";
    else member_name << "get";
    member_name << (char) toupper((int) *shadow_name);
    member_name << shadow_name + 1;
    fprintf(f_shadow, "  public %s %s(", javarettype, (char *) member_name);
    body << tab4 << "return " << module << "." << iname << "(_self";
  }

  if(!jnic) f.def << "extern \"C\"\n";
  f.def << "JNIEXPORT " << jnirettype << " JNICALL " << wname << "(JNIEnv *jenv, jclass jcls";

  // Emit all of the local variables for holding arguments.
  int pcount = emit_args(t,l,f);

  int gencomma = 0;

  // Now walk the function parameter list and generate code to get arguments
  for (int i = 0; i < pcount ; i++) {
    Parm *p = l->get(i);         // Get the ith argument
    char *target_copy = NULL;
    char *target_length = NULL;
    char *local_i = NULL;
    source = "";
    target = "";

    // Produce string representation of source and target arguments
    source << "jarg" << i;
    target << "_arg" << i;

      char *jnitype = JavaTypeFromTypemap("jni", typemap_lang, p->t, p->name);
      if(!jnitype) jnitype = SwigTcToJniType(p->t, 0);
      char *jtype = JavaTypeFromTypemap("jtype", typemap_lang, p->t, p->name);
      if(!jtype) jtype = SwigTcToJavaType(p->t, 0, 0);
      if (useRegisterNatives) {
        javaParameterSignature << JavaMethodSignature(p->t, 0, 0);
      }

      if(p->ignore) continue;

      // Add to java function header
      if(shadow && member_func) {
        if(i > 0) {
          if(i>1) fprintf(f_shadow, ", ");
          fprintf(f_shadow, "%s %s", jtype, (char *) source);
          body << ", " << source;
        }
      }

      if(gencomma) fprintf(f_java, ", ");
      fprintf(f_java, "%s %s", jtype, (char *) source);

      gencomma = 1;

      // Add to Jni function header
      f.def << ", " << jnitype << " " << source;
  
      // Get typemap for this argument
      tm = typemap_lookup("in",typemap_lang,p->t,p->name,source,target,&f);
      if (tm) {
	      f.code << tm << "\n";
	      f.code.replace("$arg",source);   // Perform a variable replacement
      } else {
        if(!p->t->is_pointer)
          f.code << tab4 << target << " = " << p->t->print_cast() << source << ";\n";
        else if((p->t->type == T_VOID && p->t->is_pointer == 1) ||
	        (p->t->type == T_USER && p->t->is_pointer == 1)) {
            p->t->is_pointer++;
            f.code << tab4 << target << " = *" << p->t->print_cast() << "&" << source << ";\n";
            p->t->is_pointer--;
        } else {
          if(p->t->type == T_CHAR && p->t->is_pointer == 1) {
              f.code << tab4 << (char *) target << " = (" << source << ") ? (char *)" << JNICALL("GetStringUTFChars") << source << ", 0) : NULL;\n";
          } else {
            char *scalarType = SwigTcToJniScalarType(p->t);
            char *cptrtype = p->t->print_type();
            p->t->is_pointer--;
            const char *basic_jnitype = (p->t->is_pointer > 0) ? "jlong" : SwigTcToJniType(p->t, 0);
            char *ctype = p->t->print_type();
	    if(scalarType == NULL || basic_jnitype == NULL) {
	      fprintf(stderr, "\'%s\' does not have a in/jni typemap, and is not a basic type.\n", ctype);
    	      SWIG_exit(1);
	    };
            p->t->is_pointer++;

            String basic_jniptrtype = basic_jnitype;
            basic_jniptrtype << "*";
            String source_length = JNICALL("GetArrayLength");
	    source_length << source << ")";

            target_copy = copy_string(f.new_local((char *) basic_jniptrtype, target, NULL));
            target_length = copy_string(f.new_local("jsize", target, source_length));
            if(local_i == NULL) local_i = copy_string(f.new_local("int", "i", NULL));

            String scalarFunc = "Get";
            scalarFunc << scalarType << "ArrayElements";
	    f.code << tab4 << target_copy << " = " << JNICALL(scalarFunc) << source << ", 0);\n";
	    f.code << tab4 << target << " = " << p->t->print_cast() << " malloc(" << target_length << " * sizeof(" << ctype << "));\n";
	    f.code << tab4 << "for(i=0; i<" << target_length << "; i++)\n";
	    // if(p->t->is_pointer && ((p->t->type == T_VOID) || (p->t->type == T_USER))) {
	    if(p->t->is_pointer > 1) {
	      f.code << tab8 << target << "[i] = *" << p->t->print_cast() << "&" << target_copy << "[i];\n";
	    } else {
              p->t->is_pointer--;
	      f.code << tab8 << target << "[i] = " << p->t->print_cast() << target_copy << "[i];\n"; 
	      p->t->is_pointer++;
	    }
          }
        }
      }

    // Check to see if there was any sort of a constaint typemap
    if ((tm = typemap_lookup("check",typemap_lang,p->t,p->name,source,target))) {
      // Yep.  Use it instead of the default
      f.code << tm << "\n";
      f.code.replace("$arg",source);
    }

    // Check if there was any cleanup code (save it for later)
    if ((tm = typemap_lookup("freearg",typemap_lang,p->t,p->name,source,target))) {
      // Yep.  Use it instead of the default
      cleanup << tm << "\n";
      cleanup.replace("$arg",source);
    }

    if ((tm = typemap_lookup("argout",typemap_lang,p->t,p->name,source,target))) {
      // Yep.  Use it instead of the default
      outarg << tm << "\n";
      outarg.replace("$arg",source);
    } else {
       // if(p->t->is_pointer && p->t->type != T_USER &&  p->t->type != T_VOID) {
       if(p->t->is_pointer) {
         if(p->t->type == T_CHAR && p->t->is_pointer == 1) {
            outarg << tab4 << "if(" << target <<") " << JNICALL("ReleaseStringUTFChars") << source << ", " << target << ");\n";
         } else if((p->t->type == T_VOID && p->t->is_pointer == 1) ||
                (p->t->type == T_USER && p->t->is_pointer == 1)) {
	   // nothing to do
         } else {
            char *scalarType = SwigTcToJniScalarType(p->t);
            char *cptrtype = p->t->print_type();
            p->t->is_pointer--;
            const char *basic_jnitype = (p->t->is_pointer > 0) ? "jlong" : SwigTcToJniType(p->t, 0);
            char *ctype = p->t->print_type();
	    if(scalarType == NULL || basic_jnitype == NULL) {
	      fprintf(stderr, "\'%s\' does not have a argout/jni typemap, and is not a basic type.\n", ctype);
    	      SWIG_exit(1);
	    };
            p->t->is_pointer++;

	    outarg << tab4 << "for(i=0; i<" << target_length << "; i++)\n";
	    if(p->t->is_pointer > 1) {
	      outarg << tab8 << "*" << p->t->print_cast() << "&" << target_copy << "[i] = " <<  target << "[i];\n";
	    } else {
	      outarg << tab8 << target_copy << "[i] = (" << basic_jnitype << ") " << target << "[i];\n"; 
	    }
            String scalarFunc = "Release";
            scalarFunc << scalarType << "ArrayElements";
            outarg << tab4 << JNICALL(scalarFunc) << source << ", " << target_copy << ", 0);\n";
	    outarg << tab4 << "free(" << target << ");\n";

            free(target_copy);
            free(target_length);
            free(local_i);
         }
       }
    }
  }

  fprintf(f_java, ");\n");
  if(shadow && member_func) {
    fprintf(f_shadow, ") {\n");
    body << ")";
    fprintf(f_shadow, "%s;\n  }\n\n", (char *) body);
  }
  f.def << ") {";

  // Now write code to make the function call

  if(!native_func)
	emit_func_call(name,t,l,f);

  // Return value if necessary 

  if((t->type != T_VOID || t->is_pointer) && !native_func) {
    if ((tm = typemap_lookup("out",typemap_lang,t,iname,"_result","_jresult"))) {
      f.code << tm << "\n";
    } else {
      if(t->is_pointer == 0 && t->type == T_USER) { /* return by value */
	    t->is_pointer=2;
            f.code << tab4 << "*" << t->print_cast() << "&_jresult = _result;\n";
	    t->is_pointer=0;
      } else if(t->is_pointer == 0 && t->type != T_USER) {
          f.code << tab4 << "_jresult = (" << jnirettype << ") _result;\n";
      } else if((t->type == T_VOID && t->is_pointer == 1) ||
	        (t->type == T_USER && t->is_pointer == 1)) {
	    t->is_pointer++;
            f.code << tab4 << "*" << t->print_cast() << "&_jresult = _result;\n";
	    t->is_pointer--;
      } else {
        if(t->type == T_CHAR && t->is_pointer == 1) {
          f.code << tab4 << "if(_result != NULL)\n";
          f.code << tab8 << "_jresult = (jstring)" << JNICALL("NewStringUTF") <<  "_result);\n";
        } else {
             fprintf(stderr,"%s : Line %d. Warning: no return typemap for datatype %s\n", input_file,line_number,t->print_type());
	    t->is_pointer++;
  	    f.code << tab4 << "*" << t->print_cast() << "&_jresult = _result;\n";
	    t->is_pointer--;
        }
      }
    }
  }

  // Dump argument output code;
  f.code << outarg;

  // Dump the argument cleanup code
  f.code << cleanup;

  // Look for any remaining cleanup

  if (NewObject) {
    if ((tm = typemap_lookup("newfree",typemap_lang,t,iname,"_result",""))) {
      f.code << tm << "\n";
    }
  }

  if((t->type != T_VOID || t->is_pointer) && !native_func) {
    if ((tm = typemap_lookup("ret",typemap_lang,t,iname,"_result","_jresult", NULL))) {
      f.code << tm << "\n";
    }
  }

  // Wrap things up (in a manner of speaking)
  if(t->type != T_VOID || t->is_pointer)
    f.code << tab4 << "return _jresult;\n";
  f.code << "}\n";

  // Substitute the cleanup code (some exception handlers like to have this)
  f.code.replace("$cleanup",cleanup);
 
  // Emit the function
  
  if(!native_func)
	f.print(f_wrappers);
  
  
 // If registerNatives is active, store the table entry for this method
  if (useRegisterNatives) {
    String methodEntry;
    methodEntry << "\"" << name << "\", \"(" << javaParameterSignature << ")" << javaReturnSignature << "\", " << wname;
    registerNativesList << tab4 << "{" << methodEntry << "}," << "\n";
  }
}

// -----------------------------------------------------------------------
// JAVA::link_variable(char *name, char *iname, DataType *t)
//
// Create a JAVA link to a C variable.
// -----------------------------------------------------------------------

void JAVA::link_variable(char *name, char *iname, DataType *t)
{
  emit_set_get(name,iname, t);
}

// -----------------------------------------------------------------------
// JAVA::declare_const(char *name, char *iname, DataType *type, char *value)
// ------------------------------------------------------------------------

void JAVA::declare_const(char *name, char *iname, DataType *type, char *value) {
  char *tm;
  FILE *jfile;
  char *jname;

  if(!classdef_emitted) emit_classdef();

  if(shadow && member_func) {
    jfile = f_shadow;
    jname = shadow_name;
  } else {
    jfile = f_java;
    jname = name;
  }

  if ((tm = typemap_lookup("const",typemap_lang,type,name,name,iname))) {
    String str = tm;
    str.replace("$value",value);
    fprintf(jfile,"  %s\n\n", (char *) str);
  } else {
    if((type->is_pointer == 0)) {
      char *jtype = typemap_lookup("jtype", typemap_lang, type, name, name, iname);
      if(!jtype) jtype = SwigTcToJavaType(type, 0, 0);
      if(strcmp(jname, value) == 0 || strstr(value,"::") != NULL) {
        fprintf(stderr, "ignoring enum constant: %s\n", jname);
      } else 
        fprintf(jfile, "  public final static %s %s = %s;\n\n", jtype, jname, value);
    } else {
      if(type->type == T_CHAR && type->is_pointer == 1) {
        fprintf(jfile, "  public final static String %s = \"%s\";\n\n", jname, value);
      } else {
        emit_set_get(name,iname, type);
      }
    }
  }
}

void emit_shadow_banner(FILE *f) {
  fprintf(f, "/*\n");
  fprintf(f, " *\n");
  fprintf(f, " * This file was automatically generated by :\n");
  fprintf(f, " * Simplified Wrapper and Interface Generator (SWIG)\n");
  fprintf(f, " * Version 1.1  (Final)\n");
  fprintf(f, " *\n");
  fprintf(f, " * Portions Copyright (c) 1995-1997\n");
  fprintf(f, " * The University of Utah and The Regents of the University of California.\n");
  fprintf(f, " * Permission is granted to distribute this file in any manner provided\n");
  fprintf(f, " * this notice remains intact.\n");
  fprintf(f, " *\n");
  fprintf(f, " * Portions Copyright (c) 1997-1999\n");
  fprintf(f, " * Harco de Hilster, Harco.de.Hilster@ATConsultancy.nl\n");
  fprintf(f, " *\n");
  fprintf(f, " * Do not make changes to this file--changes will be lost!\n");
  fprintf(f, " *\n");
  fprintf(f, " */\n\n\n");
}

void JAVA::pragma(char *lang, char *code, char *value) {
  if(strcmp(lang, "java") != 0) return;

  String s = value;
  s.replace("\\\"", "\"");
  if(strcmp(code, "import") == 0) {
    jimport = copy_string((char *) s);
    fprintf(f_java, "// pragma\nimport %s;\n\n", jimport);
  } else if(strcmp(code, "module") == 0) {
    if(!classdef_emitted) emit_classdef();
    fprintf(f_java, "// pragma\n");
    fprintf(f_java, (char *) s);
    fprintf(f_java, "\n\n");
  } else if(strcmp(code, "shadow") == 0) {
    if(shadow && f_shadow) {
      fprintf(f_shadow, "// pragma\n");
      fprintf(f_shadow, (char *) s);
      fprintf(f_shadow, "\n\n");
    }
  } else if(strcmp(code, "modifiers") == 0) {
    method_modifiers = copy_string(value);
  } else {
    fprintf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file,line_number);
  }
}

// ---------------------------------------------------------------------
// C++ Handling
//
// The following functions provide some support for C++ classes and
// C structs.
// ---------------------------------------------------------------------

void JAVA::add_typedef(DataType *t, char *name) {
  if(!shadow) return;
  
  // First check to see if there aren't too many pointers

  if (t->is_pointer > 1) return;

  if(Getattr(shadow_classes,name)) return;      // Already added

  // Now look up the datatype in our shadow class hash table

  if (Getattr(shadow_classes,t->name)) {

    // Yep.   This datatype is in the hash
    // Put this types 'new' name into the hash
    Setattr(shadow_classes,name,GetChar(shadow_classes,t->name));
  }
}

void JAVA::cpp_open_class(char *classname, char *rename, char *ctype, int strip) {

  this->Language::cpp_open_class(classname,rename,ctype,strip);

  if(!shadow) return;

  if(rename)
    shadow_classname = copy_string(rename);
  else shadow_classname = copy_string(classname);

  if (strcmp(shadow_classname, module) == 0) {
    fprintf(stderr, "class name cannot be equal to module name: %s\n", shadow_classname);
    SWIG_exit(1);
  }

  Setattr(shadow_classes,classname, shadow_classname);
  if(ctype && strcmp(ctype, "struct") == 0) {
    sprintf(bigbuf, "struct %s", classname);
    Setattr(shadow_classes, bigbuf, shadow_classname);
  }

  sprintf(bigbuf, "%s.java", shadow_classname);
  if(!(f_shadow = fopen(bigbuf, "w"))) {
    fprintf(stderr, "Unable to create shadow class file: %s\n", bigbuf);
  }

  emit_shadow_banner(f_shadow);

  if(*package)
	fprintf(f_shadow, "package %s;\n\n", package);
  else fprintf(f_shadow, "import %s;\n\n", module);
  if(jimport != NULL)
	fprintf(f_shadow, "import %s;\n\n", jimport);

  shadow_classdef = "";
  shadow_classdef << "public class " << shadow_classname << " %BASECLASS% " << "{\n";

  shadow_baseclass = "";
  shadow_classdef_emitted = 0;
  have_default_constructor = 0;
}

void JAVA::emit_shadow_classdef() {
  if(*shadow_baseclass) {
    sprintf(bigbuf, "extends %s", shadow_baseclass);
    shadow_classdef.replace("%BASECLASS%", bigbuf);
  } else {
    shadow_classdef.replace("%BASECLASS%", "");

    shadow_classdef << "  public long _self = 0;\n";
    shadow_classdef << "  public boolean _selfown = false;\n\n";

    shadow_classdef << "  public static Object newInstance(long p) {\n";
    shadow_classdef << "    return new " << shadow_classname << "(new Long(p));\n";
    shadow_classdef << "  };\n\n";
    shadow_classdef << "  public " << shadow_classname << "(java.lang.Long obj) {\n" << tab4 << "_self = obj.longValue();\n  }\n\n";
  }

  shadow_classdef << "  public Class _selfClass() {\n" << tab4 << "return " << shadow_classname << ".class;\n" << "  };\n\n";

  fprintf(f_shadow, (char *) shadow_classdef);

  shadow_classdef_emitted = 1;
}

void JAVA::cpp_close_class() {
  this->Language::cpp_close_class();
  if(!shadow) return;

  if(!shadow_classdef_emitted) emit_shadow_classdef();

  if(have_default_constructor == 0) {
    fprintf(f_shadow, "  public %s() {}\n\n", shadow_classname);
  }

  fprintf(f_shadow, "}\n");
  fclose(f_shadow);
  f_shadow = NULL;

  free(shadow_classname);
  shadow_classname = NULL;
}

void JAVA::cpp_member_func(char *name, char *iname, DataType *t, ParmList *l) {
  String           arg;
  String           nativecall;

  this->Language::cpp_member_func(name,iname,t,l);

  if(!shadow) return;
  if(!shadow_classdef_emitted) emit_shadow_classdef();

  char *javarettype = JavaTypeFromTypemap("jtype", typemap_lang, t, iname);
  if(!javarettype) javarettype = SwigTcToJavaType(t, 1, 0);
  char *shadowrettype = JavaTypeFromTypemap("jstype", typemap_lang, t, iname);
  if(!shadowrettype && t->type == T_USER) {
    shadowrettype = GetChar(shadow_classes,t->name);
  }

  fprintf(f_shadow, "  public %s %s(", (shadowrettype) ? shadowrettype : javarettype, iname);

  if((t->type != T_VOID || t->is_pointer)) {
    nativecall << "return ";
    if(shadowrettype) {
      nativecall << "new " << shadowrettype << "(new Long(";
    }
  }
  nativecall << module << "." << name_member(iname, shadow_classname) << "(_self";

  int pcount = l->nparms;

  for (int i = 0; i < pcount ; i++) {
    Parm *p = l->get(i);         // Get the ith argument
    // Produce string representation of source and target arguments
    if(p->name && *(p->name))
	arg = p->name;
    else {
      arg = "arg";
      arg << i;
    }

      if(p->t->type == T_USER && Getattr(shadow_classes,p->t->name)) {
        nativecall << ", " << arg << "._self";
      } else nativecall << ", " << arg;

      char *jtype = JavaTypeFromTypemap("jtype", typemap_lang, p->t, p->name);
      if(!jtype) jtype = SwigTcToJavaType(p->t, 0, 0);

      char *jstype = JavaTypeFromTypemap("jstype", typemap_lang, p->t, p->name);
      if(!jstype && p->t->type == T_USER) {
	    jstype = GetChar(shadow_classes,p->t->name);
      }

      // Add to java function header
      fprintf(f_shadow, "%s %s", (jstype) ? jstype : jtype, (char *) arg);
      if(i != pcount-1) {
        fprintf(f_shadow, ", ");
      }
  }


  if((t->type != T_VOID || t->is_pointer) && shadowrettype) 
    nativecall << "))";

  nativecall << ");\n";

  fprintf(f_shadow, ") {\n");
  fprintf(f_shadow, "\t%s\n", (char *) nativecall);
  fprintf(f_shadow, "  }\n\n");
}

void JAVA::cpp_static_func(char *name, char *iname, DataType *t, ParmList *l) {
  String           arg;
  String           nativecall  = "";

  this->Language::cpp_static_func(name,iname,t,l);

  if(!shadow) return;
  if(!shadow_classdef_emitted) emit_shadow_classdef();

  char *javarettype = JavaTypeFromTypemap("jtype", typemap_lang, t, iname);
  if(!javarettype) javarettype = SwigTcToJavaType(t, 1, 0);
  char *shadowrettype = JavaTypeFromTypemap("jstype", typemap_lang, t, iname);
  if(!shadowrettype && t->type == T_USER) {
    shadowrettype = GetChar(shadow_classes,t->name);
  }

  fprintf(f_shadow, "  public static %s %s(", (shadowrettype) ? shadowrettype : javarettype, iname);

  if((t->type != T_VOID || t->is_pointer)) {
    nativecall << "return ";
    if(shadowrettype) {
      nativecall << "new " << shadowrettype << "(new Long(";
    }
  }
  nativecall << module << "." << name_member(iname, shadow_classname) << "(";

  int pcount = l->nparms;
  int gencomma = 0;

  for (int i = 0; i < pcount ; i++) {
    Parm *p = l->get(i);         // Get the ith argument
    // Produce string representation of source and target arguments
    if(p->name && *(p->name))
	  arg = p->name;
    else {
      arg = "arg";
      arg << i;
    }

    if(gencomma) nativecall << ", ";

    if(p->t->type == T_USER && Getattr(shadow_classes,p->t->name)) {
      nativecall << arg << "._self";
    } else nativecall << arg;

    gencomma = 1;

    char *jtype = JavaTypeFromTypemap("jtype", typemap_lang, p->t, p->name);
    if(!jtype) jtype = SwigTcToJavaType(p->t, 0, 0);

    char *jstype = JavaTypeFromTypemap("jstype", typemap_lang, p->t, p->name);
    if(!jstype && p->t->type == T_USER) {
	  jstype = GetChar(shadow_classes, p->t->name);
    }

    // Add to java function header
    fprintf(f_shadow, "%s %s", (jstype) ? jstype : jtype, (char *) arg);
    if(i != pcount-1) {
      fprintf(f_shadow, ", ");
    }
  }


  if((t->type != T_VOID || t->is_pointer) && shadowrettype) 
    nativecall << "))";

  nativecall << ");\n";

  fprintf(f_shadow, ") {\n");
  fprintf(f_shadow, "\t%s\n", (char *) nativecall);
  fprintf(f_shadow, "  }\n\n");
}

void JAVA::cpp_constructor(char *name, char *iname, ParmList *l) {
  this->Language::cpp_constructor(name,iname,l);

  if(!shadow) return;
  if(!shadow_classdef_emitted) emit_shadow_classdef();

  String nativecall;
  String arg;

  fprintf(f_shadow, "  public %s(", shadow_classname);

  nativecall << "    if(_self == 0 && " << shadow_classname << ".class == _selfClass()) {\n";
  if (iname != NULL)
      nativecall << tab8 << " _self = "  << module << "." << name_construct(iname) << "(";
  else
      nativecall << tab8 << " _self = "  << module << "." << name_construct(shadow_classname) << "(";

  int pcount = l->nparms;
  if(pcount == 0)  // We must have a default constructor
    have_default_constructor = 1;

  for (int i = 0; i < pcount ; i++) {
    Parm *p = l->get(i);         // Get the ith argument
    // Produce string representation of source and target arguments
    if(p->name && *(p->name))
	arg = p->name;
    else {
      arg = "arg";
      arg << i;
    }

      char *jtype = JavaTypeFromTypemap("jtype", typemap_lang, p->t, p->name);
      if(!jtype) jtype = SwigTcToJavaType(p->t, 0, 0);
      char *jstype = JavaTypeFromTypemap("jstype", typemap_lang, p->t, p->name);
      if(!jstype) jstype = SwigTcToJavaType(p->t, 0, 1);
      if(strcmp(jtype, jstype) == 0) jstype = NULL;

      // Add to java function header
      fprintf(f_shadow, "%s %s", (jstype) ? jstype : jtype, (char *) arg);

      if(p->t->type == T_USER && Getattr(shadow_classes,p->t->name)) {
        nativecall << arg << "._self";
      } else nativecall << arg;

      if(i != pcount-1) {
        nativecall << ", ";
        fprintf(f_shadow, ", ");
      }
  }


  fprintf(f_shadow, ") {\n");
  nativecall << ");\n";
  nativecall << tab8 << " _selfown = true;\n";
  nativecall << "    }\n";

  fprintf(f_shadow, "%s", (char *) nativecall);
  fprintf(f_shadow, "  }\n\n");
}

void JAVA::cpp_destructor(char *name, char *newname) {
  this->Language::cpp_destructor(name,newname);

  if(!shadow) return;
  if(!shadow_classdef_emitted) emit_shadow_classdef();

  char *realname = (newname) ? newname : name;

  if(finalize) {
    fprintf(f_shadow, "  protected void finalize() {\n");
    fprintf(f_shadow, "    _delete();\n");
    fprintf(f_shadow, "  };\n\n");
  }

  fprintf(f_shadow, "  public void _delete() {\n");
  fprintf(f_shadow, "    if(_self != 0 && _selfown && %s.class == _selfClass()) {\n", shadow_classname);
  fprintf(f_shadow, "\t%s.%s(_self);\n", module, name_destroy(realname));
  fprintf(f_shadow, "\t_self = 0;\n");
  fprintf(f_shadow, "    }\n");
  fprintf(f_shadow, "  }\n\n");
}

void JAVA::cpp_class_decl(char *name, char *rename, char *type) {
  this->Language::cpp_class_decl(name,rename, type);

  if(!shadow) return;

  char *realname = (rename) ? rename : name;

  Setattr(shadow_classes,name, realname);
  if(type && strcmp(type, "struct") == 0) {
    sprintf(bigbuf, "struct %s", name);
    Setattr(shadow_classes, bigbuf, rename);
  }
}

void JAVA::cpp_inherit(char **baseclass, int) {
  this->Language::cpp_inherit(baseclass, 0);

  if(!shadow) return;

  int cnt = 0;
  char **bc = baseclass;
  while(*bc++) cnt++;

  if(cnt > 1)
    fprintf(stderr, "Warning: %s inherits from multiple base classes. Multiple inheritance is not supported.\n", shadow_classname);
 
  shadow_baseclass = copy_string(*baseclass);
}

void JAVA::cpp_variable(char *name, char *iname, DataType *t) {
  if(shadow && !shadow_classdef_emitted) emit_shadow_classdef();

  if(shadow) member_func = 1;
  shadow_name = copy_string((iname) ? iname : name);
  this->Language::cpp_variable(name, iname, t);
  member_func = 0;
}

void JAVA::cpp_static_var(char *name, char *iname, DataType *t) {
  if(shadow) member_func = 1;
  shadow_name = copy_string((iname) ? iname : name);
  this->Language::cpp_static_var(name, iname, t);
  member_func = 0;
}

void JAVA::cpp_declare_const(char *name, char *iname, DataType *type, char *value) {
  if(shadow && !shadow_classdef_emitted) emit_shadow_classdef();

  if(shadow) member_func = 1;
  shadow_name = copy_string((iname) ? iname : name);
  this->Language::cpp_declare_const(name, iname, type, value);
  member_func = 0;
}


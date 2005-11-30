/*
 * PHP4 Support
 *
 * Richard Palmer
 * richard@magicality.org
 * Nov 2001
 *
 * Portions copyright Sun Microsystems (c) 2001
 * Tim Hockin <thockin@sun.com>
 *
 * Portions copyright Ananova Ltd (c) 2002
 * Sam Liddicott <sam@ananova.com>
 *
 * TODO: Replace stderr messages with Swig_warning
 *
 */

char cvsroot_php4_cxx[] = "$Header$";

#include "swigmod.h"

#include <ctype.h>


static const char *usage = (char*)"\
PHP4 Options (available with -php4)\n\
     -cppext         - cpp file extension (default to .cpp)\n\
     -noproxy        - Don't generate proxy classes.\n\
     -dlname <name>  - Set module prefix to <name>\n\
     -make           - Create simple makefile\n\
     -phpfull        - Create full make files\n\
     -withincs <libs>- With -phpfull writes needed incs in config.m4\n\
     -withlibs <libs>- With -phpfull writes needed libs in config.m4\n\
     -withc <libs>   - With -phpfull makes extra c files in Makefile.in\n\
     -withcxx <libs> - With -phpfull makes extra c++ files in Makefile.in\n\
\n";

static int constructors=0;
static String *NOTCLASS=NewString("Not a class");
static Node *classnode=0;
static String *module = 0;
static String *cap_module = 0;
static String *dlname = 0;
static String *withlibs = 0;
static String *withincs = 0;
static String *withc = 0;
static String *withcxx = 0;

static char *shadow_classname;

static int      gen_extra = 0;
static int      gen_make = 0;

static File       *f_runtime = 0;
static File       *f_h = 0;
static File       *f_phpcode = 0;
static String     *phpfilename =0;

static String     *s_header;
static String     *s_wrappers;
static String     *s_init;
static String     *r_init;       // RINIT user code
static String     *s_shutdown;   // MSHUTDOWN user code
static String     *r_shutdown;   // RSHUTDOWN user code
static String     *s_vinit;      // varinit initialization code.
static String     *s_vdecl;
static String     *s_cinit;      // consttab initialization code.
static String     *s_oinit;
static String     *s_entry;
static String     *cs_entry;
static String     *all_cs_entry;
static String     *pragma_incl;
static String     *pragma_code;
static String     *pragma_phpinfo;

/* Variables for using PHP classes */
static String     *class_name = 0;

static Hash     *shadow_get_vars;
static Hash     *shadow_set_vars;
#define NATIVE_CONSTRUCTOR 1
#define ALTERNATIVE_CONSTRUCTOR 2
static int      native_constructor=0;
static Hash     *zend_types = 0;

static int        shadow        = 1;

// These static variables are used to pass some state from Handlers into functionWrapper
static enum {
  standard = 0,
  memberfn,
  staticmemberfn,
  membervar,
  staticmembervar,
  constructor,
  destructor
} wrapperType = standard;

extern "C" {
static void (*r_prevtracefunc)(SwigType *t, String *mangled, String *clientdata) = 0;
}

static const char *php_header =
"/*"
"\n  +----------------------------------------------------------------------+"
"\n  | PHP version 4.0                                                      |"
"\n  +----------------------------------------------------------------------+"
"\n  | Copyright (c) 1997, 1998, 1999, 2000, 2001 The PHP Group             |"
"\n  +----------------------------------------------------------------------+"
"\n  | This source file is subject to version 2.02 of the PHP license,      |"
"\n  | that is bundled with this package in the file LICENSE, and is        |"
"\n  | available at through the world-wide-web at                           |"
"\n  | http://www.php.net/license/2_02.txt.                                 |"
"\n  | If you did not receive a copy of the PHP license and are unable to   |"
"\n  | obtain it through the world-wide-web, please send a note to          |"
"\n  | license@php.net so we can mail you a copy immediately.               |"
"\n  +----------------------------------------------------------------------+"
"\n  | Authors:                                                             |"
"\n  |                                                                      |"
"\n  +----------------------------------------------------------------------+"
"\n */\n";

void
SwigPHP_emit_resource_registrations() {
  DOH *key;
  Iterator ki;
  String *destructor=0;
  String *classname=0;
  String *shadow_classname=0;

  if (!zend_types) return;

  ki = First(zend_types);
  if (ki.key) Printf(s_oinit,"\n/* Register resource destructors for pointer types */\n");
  while (ki.key) if (1 /* is pointer type*/) {
    key = ki.key;
    Node *class_node;
    if ((class_node=Getattr(zend_types,key))) {
      // Write out destructor function header
      Printf(s_wrappers,"/* NEW Destructor style */\nstatic ZEND_RSRC_DTOR_FUNC(_wrap_destroy%s) {\n",key);

      // write out body
      if ((class_node!=NOTCLASS)) {
        classname = Getattr(class_node,"name");
        if (! (shadow_classname = Getattr(class_node,"sym:name"))) {
          shadow_classname=classname;
        }
        // Do we have a known destructor for this type?
        if ((destructor = Getattr(class_node,"destructor"))) {
          Printf(s_wrappers,"  /* has destructor: %s */\n",destructor);
          Printf(s_wrappers,"  %s(rsrc, SWIGTYPE%s->name TSRMLS_CC);\n",destructor,key);
        } else {
          Printf(s_wrappers,"  /* bah! No destructor for this wrapped class!! */\n");
        }
      } else {
          Printf(s_wrappers,"  /* bah! No destructor for this simple type!! */\n");
      }

      // close function
      Printf(s_wrappers,"}\n");

      // declare le_swig_<mangled> to store php registration
      Printf(s_vdecl,"static int le_swig_%s=0; /* handle for %s */\n", key, shadow_classname);

      // register with php
      Printf(s_oinit,"le_swig_%s=zend_register_list_destructors_ex"
             "(_wrap_destroy%s,NULL,(char *)(SWIGTYPE%s->name),module_number);\n",
             key,key,key);

      // store php type in class struct
      Printf(s_oinit,"SWIG_TypeClientData(SWIGTYPE%s,&le_swig_%s);\n",
             key,key);
    }
    ki = Next(ki);
  }
}

class PHP4 : public Language {
public:

  /* Test to see if a type corresponds to something wrapped with a shadow class. */
  
  String *is_shadow(SwigType *t) {
    String *r = 0;
    Node *n = classLookup(t);
    if (n) {
      r = Getattr(n,"php:proxy");   // Set by classDeclaration()
      if (!r) {
        r = Getattr(n,"sym:name");      // Not seen by classDeclaration yet, but this is the name
      }
    }
    return r;
  }
  
  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */
  
  virtual void main(int argc, char *argv[]) {
    int i;
    SWIG_library_directory("php4");
    SWIG_config_cppext("cpp");
    
    for(i = 1; i < argc; i++) {
      if (argv[i]) {
        if(strcmp(argv[i], "-phpfull") == 0) {
          gen_extra = 1;
          Swig_mark_arg(i);
        } else if(strcmp(argv[i], "-dlname") == 0) {
          if (argv[i+1]) {
            dlname = NewString(argv[i+1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i+1);
            i++;
          } else {
            Swig_arg_error();
          }
        } else if(strcmp(argv[i], "-withlibs") == 0) {
          if (argv[i+1]) {
            withlibs = NewString(argv[i+1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i+1);
            i++;
          } else {
            Swig_arg_error();
          }
        } else if(strcmp(argv[i], "-withincs") == 0) {
          if (argv[i+1]) {
            withincs = NewString(argv[i+1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i+1);
            i++;
          } else {
            Swig_arg_error();
          }
        } else if(strcmp(argv[i], "-withc") == 0) {
          if (argv[i+1]) {
            withc = NewString(argv[i+1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i+1);
            i++;
          } else {
            Swig_arg_error();
          }
        } else if(strcmp(argv[i], "-withcxx") == 0) {
          if (argv[i+1]) {
            withcxx = NewString(argv[i+1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i+1);
            i++;
          } else {
            Swig_arg_error();
          }
        } else if(strcmp(argv[i], "-cppext") == 0) {
          if (argv[i+1]) {
            SWIG_config_cppext(argv[i+1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i+1);
            i++;
          } else {
            Swig_arg_error();
          }
        }  else if((strcmp(argv[i], "-noshadow") == 0)
                   || (strcmp(argv[i],"-noproxy") == 0)) {
          shadow = 0;
          Swig_mark_arg(i);
        } else if(strcmp(argv[i], "-make") == 0) {
          gen_make = 1;
          Swig_mark_arg(i);
        } else if(strcmp(argv[i], "-help") == 0) {
          fputs(usage, stdout);
        }
      }
    }
    
    Preprocessor_define((void *) "SWIGPHP 1", 0);
    Preprocessor_define((void *) "SWIGPHP4 1", 0);
    SWIG_typemap_lang("php4");
    /* DB: Suggest using a language configuration file */
    SWIG_config_file("php4.swg");
    allow_overloading();
  }
  
  void create_simple_make(void) {
    File *f_make;
    
    f_make = NewFile((void *)"makefile", "w");
    Printf(f_make, "CC=gcc\n");
    Printf(f_make, "CXX=g++\n");
    Printf(f_make, "CXX_SOURCES=%s\n", withcxx );
    Printf(f_make, "C_SOURCES=%s\n", withc );
    Printf(f_make, "OBJS=%s_wrap.o $(C_SOURCES:.c=.o) $(CXX_SOURCES:.cxx=.o)\n", module );
    Printf(f_make, "PROG=%s\n", dlname);
    Printf(f_make, "CFLAGS=-fpic\n" );
    Printf(f_make, "LDFLAGS=-shared\n");
    Printf(f_make, "PHP_INC=`php-config --includes`\n");
    Printf(f_make, "EXTRA_INC=\n");
    Printf(f_make, "EXTRA_LIB=\n\n" );
    Printf(f_make, "$(PROG): $(OBJS)\n");
    if ( CPlusPlus || (withcxx != NULL) ) {
      Printf(f_make, "\t$(CXX) $(LDFLAGS) $(OBJS) -o $(PROG) $(EXTRA_LIB)\n\n");
    } else {
      Printf(f_make, "\t$(CC) $(LDFLAGS) $(OBJS) -o $(PROG) $(EXTRA_LIB)\n\n");
    }
    Printf(f_make, "%%.o: %%.cpp\n");
    Printf(f_make, "\t$(CXX) $(EXTRA_INC) $(PHP_INC) $(CFLAGS) -c $<\n");
    Printf(f_make, "%%.o: %%.cxx\n");
    Printf(f_make, "\t$(CXX) $(EXTRA_INC) $(PHP_INC) $(CFLAGS) -c $<\n");
    Printf(f_make, "%%.o: %%.c\n");
    Printf(f_make, "\t$(CC) $(EXTRA_INC) $(PHP_INC) $(CFLAGS) -c $<\n");

    Close(f_make);
  }
  
  void create_extra_files(String *outfile) {
    File *f_extra;
    
    static String *configm4=0;
    static String *makefilein=0;
    static String *credits=0;
    
    configm4=NewString("");
    Printv(configm4, SWIG_output_directory(), "config.m4", NIL);
    
    makefilein=NewString("");
    Printv(makefilein, SWIG_output_directory(), "Makefile.in", NIL);
    
    credits=NewString("");
    Printv(credits, SWIG_output_directory(), "CREDITS", NIL);
    
    // are we a --with- or --enable-
    int with=(withincs || withlibs)?1:0;
    
    // Note makefile.in only copes with one source file
    // also withincs and withlibs only take one name each now
    // the code they generate should be adapted to take multiple lines
    
    /* Write out Makefile.in */
    f_extra = NewFile(makefilein, "w");
    if (!f_extra) {
      FileErrorDisplay(makefilein);
      SWIG_exit(EXIT_FAILURE);
    }
    
    Printf(f_extra,
	   "# $Id$\n\n"
	   "LTLIBRARY_NAME          = php_%s.la\n",
	   module);
    
    // CPP has more and different entires to C in Makefile.in
    if (! CPlusPlus) {
      Printf(f_extra,"LTLIBRARY_SOURCES       = %s %s\n", Swig_file_filename(outfile),withc);
      Printf(f_extra,"LTLIBRARY_SOURCES_CPP   = %s\n", withcxx);
    } else {
      Printf(f_extra,"LTLIBRARY_SOURCES       = %s\n", withc );
      Printf(f_extra,"LTLIBRARY_SOURCES_CPP   = %s %s\n", Swig_file_filename(outfile),withcxx);
      Printf(f_extra,"LTLIBRARY_OBJECTS_X = $(LTLIBRARY_SOURCES_CPP:.cpp=.lo) $(LTLIBRARY_SOURCES_CPP:.cxx=.lo)\n");
      
    }
    Printf(f_extra,"LTLIBRARY_SHARED_NAME   = php_%s.la\n", module);
    Printf(f_extra,"LTLIBRARY_SHARED_LIBADD = $(%(upper)s_SHARED_LIBADD)\n\n",module);
    Printf(f_extra,"include $(top_srcdir)/build/dynlib.mk\n");
    
    Printf(f_extra,"\n# patch in .cxx support to php build system to work like .cpp\n");
    Printf(f_extra,".SUFFIXES: .cxx\n\n");
    
    Printf(f_extra,".cxx.o:\n");
    Printf(f_extra,"  $(CXX_COMPILE) -c $<\n\n");
    
    Printf(f_extra,".cxx.lo:\n");
    Printf(f_extra,"  $(CXX_PHP_COMPILE)\n\n");
    Printf(f_extra,".cxx.slo:\n");
    
    Printf(f_extra,"  $(CXX_SHARED_COMPILE)\n\n");
    
    Printf(f_extra,"\n# make it easy to test module\n");
    Printf(f_extra,"testmodule:\n");
    Printf(f_extra,"  php -q -d extension_dir=modules %s\n\n",Swig_file_filename(phpfilename));
    
    Close(f_extra);
      
    /* Now config.m4 */
    // Note: # comments are OK in config.m4 if you don't mind them
    // appearing in the final ./configure file 
    // (which can help with ./configure debugging)
    
    // NOTE2: phpize really ought to be able to write out a sample
    // config.m4 based on some simple data, I'll take this up with
    // the php folk!
    f_extra = NewFile(configm4, "w");
    if (!f_extra) {
      FileErrorDisplay(configm4);
      SWIG_exit(EXIT_FAILURE);
    }
    
    Printf(f_extra,"dnl $Id$\n");
    Printf(f_extra,"dnl ***********************************************************************\n");
    Printf(f_extra,"dnl ** THIS config.m4 is provided for PHPIZE and PHP's consumption NOT\n");
    Printf(f_extra,"dnl ** for any part of the rest of the %s build system\n",module);
    Printf(f_extra,"dnl ***********************************************************************\n\n");
    
    
    if (! with) { // must be enable then
      Printf(f_extra,"PHP_ARG_ENABLE(%s, whether to enable %s support,\n",module,module);
      Printf(f_extra,"[  --enable-%s             Enable %s support])\n\n",module,module);
    } else {
      Printf(f_extra,"PHP_ARG_WITH(%s, for %s support,\n",module,module);
      Printf(f_extra,"[  --with-%s[=DIR]             Include %s support.])\n\n",module,module);
      // These tests try and file the library we need
      Printf(f_extra,"dnl THESE TESTS try and find the library and header files\n");
      Printf(f_extra,"dnl your new php module needs. YOU MAY NEED TO EDIT THEM\n");
      Printf(f_extra,"dnl as written they assume your header files are all in the same place\n\n");
      
      Printf(f_extra,"dnl ** are we looking for %s_lib.h or something else?\n",module);
      if (withincs)
	Printf(f_extra,"HNAMES=\"%s\"\n\n",withincs);
      else
	Printf(f_extra,"HNAMES=\"\"; # %s_lib.h ?\n\n",module);
      
      Printf(f_extra,"dnl ** Are we looking for lib%s.a or lib%s.so or something else?\n",module,module);
      
      if (withlibs)
	Printf(f_extra,"LIBNAMES=\"%s\"\n\n",withlibs);
      else
	Printf(f_extra,"LIBNAMES=\"\"; # lib_%s.so ?\n\n",withlibs);
      
      Printf(f_extra,"dnl IF YOU KNOW one of the symbols in the library and you\n");
      Printf(f_extra,"dnl specify it below then we can have a link test to see if it works\n");
      Printf(f_extra,"LIBSYMBOL=\"\"\n\n");
    }
    
    // Now write out tests to find thing.. they may need to extend tests
    Printf(f_extra,"if test \"$PHP_%(upper)s\" != \"no\"; then\n\n",module);
    
    // Ready for when we add libraries as we find them
    Printf(f_extra,"  PHP_SUBST(%(upper)s_SHARED_LIBADD)\n\n",module);
    
    if (withlibs) { // find more than one library
      Printf(f_extra,"  for LIBNAME in $LIBNAMES ; do\n");
      Printf(f_extra,"    LIBDIR=\"\"\n");
      // For each path element to try...
      Printf(f_extra,"    for i in $PHP_%(upper)s $PHP_%(upper)s/lib /usr/lib /usr/local/lib ; do\n",module,module);
      Printf(f_extra,"      if test -r $i/lib$LIBNAME.a -o -r $i/lib$LIBNAME.so ; then\n");
      Printf(f_extra,"        LIBDIR=\"$i\"\n");
      Printf(f_extra,"        break\n");
      Printf(f_extra,"      fi\n");
      Printf(f_extra,"    done\n\n");
      Printf(f_extra,"    dnl ** and $LIBDIR should be the library path\n");
      Printf(f_extra,"    if test \"$LIBNAME\" != \"\" -a -z \"$LIBDIR\" ; then\n");
      Printf(f_extra,"      AC_MSG_RESULT(Library files $LIBNAME not found)\n");
      Printf(f_extra,"      AC_MSG_ERROR(Is the %s distribution installed properly?)\n",module);
      Printf(f_extra,"    else\n");
      Printf(f_extra,"      AC_MSG_RESULT(Library files $LIBNAME found in $LIBDIR)\n");
      Printf(f_extra,"      PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $LIBDIR, %(upper)s_SHARED_LIBADD)\n",module);
      Printf(f_extra,"    fi\n");
      Printf(f_extra,"  done\n\n");
    }
    
    if (withincs) {  // Find more than once include
      Printf(f_extra,"  for HNAME in $HNAMES ; do\n");
      Printf(f_extra,"    INCDIR=\"\"\n");
      // For each path element to try...
      Printf(f_extra,"    for i in $PHP_%(upper)s $PHP_%(upper)s/include $PHP_%(upper)s/includes $PHP_%(upper)s/inc $PHP_%(upper)s/incs /usr/local/include /usr/include; do\n",module,module,module,module,module);
      // Try and find header files
      Printf(f_extra,"      if test \"$HNAME\" != \"\" -a -r $i/$HNAME ; then\n");
      Printf(f_extra,"        INCDIR=\"$i\"\n");
      Printf(f_extra,"        break\n");
      Printf(f_extra,"      fi\n");
      Printf(f_extra,"    done\n\n");
      
      Printf(f_extra,"    dnl ** Now $INCDIR should be the include file path\n");
      Printf(f_extra,"    if test \"$HNAME\" != \"\" -a -z \"$INCDIR\" ; then\n");
      Printf(f_extra,"      AC_MSG_RESULT(Include files $HNAME not found)\n");
      Printf(f_extra,"      AC_MSG_ERROR(Is the %s distribution installed properly?)\n",module);
      Printf(f_extra,"    else\n");
      Printf(f_extra,"      AC_MSG_RESULT(Include files $HNAME found in $INCDIR)\n");
      Printf(f_extra,"      PHP_ADD_INCLUDE($INCDIR)\n");
      Printf(f_extra,"    fi\n\n");
      Printf(f_extra,"  done\n\n");
    }
    
    if (CPlusPlus) {
      Printf(f_extra,"  # As this is a C++ module..\n");
    }
    
    Printf(f_extra,"  PHP_REQUIRE_CXX\n");
    Printf(f_extra,"  AC_CHECK_LIB(stdc++, cin)\n");
    
    if (with) {
      Printf(f_extra,"  if test \"$LIBSYMBOL\" != \"\" ; then\n");
      Printf(f_extra,"    old_LIBS=\"$LIBS\"\n");
      Printf(f_extra,"    LIBS=\"$LIBS -L$TEST_DIR/lib -lm -ldl\"\n");
      Printf(f_extra,"    AC_CHECK_LIB($LIBNAME, $LIBSYMBOL, [AC_DEFINE(HAVE_TESTLIB,1,  [ ])],\n");
      Printf(f_extra,"    [AC_MSG_ERROR(wrong test lib version or lib not found)])\n");
      Printf(f_extra,"    LIBS=\"$old_LIBS\"\n");
      Printf(f_extra,"  fi\n\n");
    }
    
    Printf(f_extra,"  AC_DEFINE(HAVE_%(upper)s, 1, [ ])\n",module);
    Printf(f_extra,"dnl  AC_DEFINE_UNQUOTED(PHP_%(upper)s_DIR, \"$%(upper)s_DIR\", [ ])\n",module,module);
    Printf(f_extra,"  PHP_EXTENSION(%s, $ext_shared)\n",module);
    
    // and thats all!
    Printf(f_extra,"fi\n");
    
    Close(f_extra);
    
    /*  CREDITS */
    f_extra = NewFile(credits, "w");
    if (!f_extra) {
      FileErrorDisplay(credits);
      SWIG_exit(EXIT_FAILURE);
    }
    Printf(f_extra, "%s\n", module);
    Close(f_extra);
  }

  /* ------------------------------------------------------------
   * top()
   * ------------------------------------------------------------ */

  virtual int top(Node *n) {

    String *filen;
    String *s_type;
    
    /* Initialize all of the output files */
    String *outfile = Getattr(n,"outfile");
    
    /* main output file */
    f_runtime = NewFile(outfile,"w");
    if (!f_runtime) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    
    Swig_banner(f_runtime);
    
    /* sections of the output file */
    s_init = NewString("/* init section */\n");
    r_init = NewString("/* rinit section */\n");
    s_shutdown = NewString("/* shutdown section */\n");
    r_shutdown = NewString("/* rshutdown section */\n");
    s_header = NewString("/* header section */\n");
    s_wrappers = NewString("/* wrapper section */\n");
    s_type = NewString("");
    /* subsections of the init section */
    s_vinit = NewString("/* vinit subsection */\n");
    s_vdecl = NewString("/* vdecl subsection */\n");
    s_cinit = NewString("/* cinit subsection */\n");
    s_oinit = NewString("/* oinit subsection */\n");
    pragma_phpinfo = NewString("");
    
    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("runtime",f_runtime);
    Swig_register_filebyname("init",s_init);
    Swig_register_filebyname("rinit",r_init);
    Swig_register_filebyname("shutdown",s_shutdown);
    Swig_register_filebyname("rshutdown",r_shutdown);
    Swig_register_filebyname("header",s_header);
    Swig_register_filebyname("wrapper",s_wrappers);
    
    /* Set the module name */
    module = Copy(Getattr(n,"name"));
    cap_module = NewStringf("%(upper)s",module);
    
    /* Set the dlname */
    if (!dlname) {
#if defined(_WIN32) || defined(__WIN32__)
      dlname = NewStringf("php_%s.dll", module);
#else
      dlname = NewStringf("php_%s.so", module);
#endif
    }
    
    /* PHP module file */
    filen = NewString("");
    Printv(filen, SWIG_output_directory(), module, ".php", NIL);
    phpfilename = NewString(filen);
    
    f_phpcode = NewFile(filen, "w");
    if (!f_phpcode) {
      FileErrorDisplay(filen);
      SWIG_exit(EXIT_FAILURE);
    }
    
    Printf(f_phpcode, "<?php\n\n");
    
    Swig_banner(f_phpcode);
    
    Printf(f_phpcode,"global $%s_LOADED__;\n", cap_module);
    Printf(f_phpcode,"if ($%s_LOADED__) return;\n", cap_module);
    Printf(f_phpcode,"$%s_LOADED__ = true;\n\n", cap_module);
    Printf(f_phpcode,"/* if our extension has not been loaded, do what we can */\n");
    Printf(f_phpcode,"if (!extension_loaded(\"php_%s\")) {\n", module);
    Printf(f_phpcode,"  if (!dl(\"%s\")) return;\n", dlname);
    Printf(f_phpcode,"}\n\n");
    
    
    /* sub-sections of the php file */
    pragma_code = NewString("");
    pragma_incl = NewString("");
    
    /* Initialize the rest of the module */

    Printf(s_oinit, "ZEND_INIT_MODULE_GLOBALS(%s, %s_init_globals, %s_destroy_globals);\n",module,module,module);
    
    /* start the header section */
    Printf(s_header, php_header);
    Printf(s_header, "ZEND_BEGIN_MODULE_GLOBALS(%s)\n", module);
    Printf(s_header, "char *error_msg;\n");
    Printf(s_header, "int error_code;\n");
    Printf(s_header, "ZEND_END_MODULE_GLOBALS(%s)\n", module );
    Printf(s_header, "ZEND_DECLARE_MODULE_GLOBALS(%s)\n",module );
    Printf(s_header, "#ifdef ZTS\n" );
    Printf(s_header, "#define ErrorMsg() TSRMG(%s_globals_id, zend_%s_globals *, error_msg );\n",module,module);
    Printf(s_header, "#define ErrorCode() TSRMG(%s_globals_id, zend_%s_globals *, error_code );\n",module,module);
    Printf(s_header, "#else\n" );
    Printf(s_header, "#define ErrorMsg() (%s_globals.error_msg)\n",module);
    Printf(s_header, "#define ErrorCode() (%s_globals.error_code)\n",module);
    Printf(s_header, "#endif\n\n" );
    
    Printf(s_header, "static void %s_init_globals(zend_%s_globals *%s_globals ) {\n",module,module,module);
    Printf(s_header, "  %s_globals->error_msg = default_error_msg;\n", module);
    Printf(s_header, "  %s_globals->error_code = default_error_code;\n",module);
    Printf(s_header, "}\n");
    
    Printf(s_header, "static void %s_destroy_globals(zend_%s_globals *%s_globals) { }\n",module,module,module);

    Printf(s_header, "\n");
    Printf(s_header, "void SWIG_ResetError() {\n");
    Printf(s_header, "  ErrorMsg() = default_error_msg;\n");
    Printf(s_header, "  ErrorCode() = default_error_code;\n");
    Printf(s_header, "}\n");

    Printf(s_header,"#define SWIG_name  \"%s\"\n", module);
    /*     Printf(s_header,"#ifdef HAVE_CONFIG_H\n");
           Printf(s_header,"#include \"config.h\"\n");
           Printf(s_header,"#endif\n\n");
    */
    Printf(s_header,"#ifdef __cplusplus\n");
    Printf(s_header,"extern \"C\" {\n");
    Printf(s_header,"#endif\n");
    Printf(s_header,"#include \"php.h\"\n");
    Printf(s_header,"#include \"php_ini.h\"\n");
    Printf(s_header,"#include \"ext/standard/info.h\"\n");
    Printf(s_header,"#include \"php_%s.h\"\n", module);
    Printf(s_header,"#ifdef __cplusplus\n");
    Printf(s_header,"}\n");
    Printf(s_header,"#endif\n\n");
           
    /* Create the .h file too */
    filen = NewString("");
    Printv(filen, SWIG_output_directory(), "php_", module, ".h", NIL);
    f_h = NewFile(filen, "w");
    if (!f_h) {
      FileErrorDisplay(filen);
      SWIG_exit(EXIT_FAILURE);
    }
    
    Swig_banner(f_h);
    Printf(f_h, php_header);
    
    Printf(f_h, "\n\n");
    Printf(f_h, "#ifndef PHP_%s_H\n", cap_module );
    Printf(f_h, "#define PHP_%s_H\n\n", cap_module );
    Printf(f_h, "extern zend_module_entry %s_module_entry;\n", module );
    Printf(f_h, "#define phpext_%s_ptr &%s_module_entry\n\n", module, module );
    Printf(f_h, "#ifdef PHP_WIN32\n" );
    Printf(f_h, "# define PHP_%s_API __declspec(dllexport)\n", cap_module );
    Printf(f_h, "#else\n" );
    Printf(f_h, "# define PHP_%s_API\n", cap_module );
    Printf(f_h, "#endif\n\n" );
    Printf(f_h, "PHP_MINIT_FUNCTION(%s);\n", module );
    Printf(f_h, "PHP_MSHUTDOWN_FUNCTION(%s);\n", module );
    Printf(f_h, "PHP_RINIT_FUNCTION(%s);\n", module );
    Printf(f_h, "PHP_RSHUTDOWN_FUNCTION(%s);\n", module );
    Printf(f_h, "PHP_MINFO_FUNCTION(%s);\n\n", module );
    
    /* start the function entry section */
    s_entry = NewString("/* entry subsection */\n");

    /* holds all the per-class function entry sections */
    all_cs_entry = NewString("/* class entry subsection */\n");
    cs_entry = NULL;
    
    Printf(s_entry,"/* Every non-class user visible function must have an entry here */\n");
    Printf(s_entry,"function_entry %s_functions[] = {\n", module);
    
    /* start the init section */
    if (gen_extra) {
      Printf(s_init,"#ifdef COMPILE_DL_%s\n", cap_module);
    }
    Printf(s_init,"#ifdef __cplusplus\n");
    Printf(s_init,"extern \"C\" {\n");
    Printf(s_init,"#endif\n");
    Printf(s_init,"ZEND_GET_MODULE(%s)\n",module);
    Printf(s_init,"#ifdef __cplusplus\n");
    Printf(s_init,"}\n");
    Printf(s_init,"#endif\n\n");
           
    if (gen_extra) {
      Printf(s_init,"#endif\n\n");
    }
    
    /* We have to register the constants before they are (possibly) used
     * by the pointer typemaps. This all needs re-arranging really as
     * things are being called in the wrong order
     */
    
    Printf(s_init,"#define SWIG_php_minit PHP_MINIT_FUNCTION(%s)\n", module);

    /* Emit all of the code */
    Language::top(n);

    SwigPHP_emit_resource_registrations();    
    //    Printv(s_init,s_resourcetypes,NIL);
    /* We need this after all classes written out by ::top */
    Printf(s_oinit, "CG(active_class_entry) = NULL;\n");        
    Printf(s_oinit, "/* end oinit subsection */\n");
    Printf(s_init, "%s\n", s_oinit);
    
    /* Constants generated during top call */
    // But save them for RINIT
    Printf(s_cinit, "/* end cinit subsection */\n");
    
    /* finish our init section which will have been used by class wrappers */
    Printf(s_vinit, "/* end vinit subsection */\n");
    
    Printf(s_init, "    return SUCCESS;\n");
    Printf(s_init,"}\n");
    
    // Now do REQUEST init which holds cinit and vinit
    Printf(s_init,"PHP_RINIT_FUNCTION(%s)\n{\n",module);
    Printf(s_init,"%s\n",r_init);
    Printf(s_init,"%s\n",s_cinit); 
    Clear(s_cinit);
    Delete(s_cinit);
    
    Printf(s_init, "%s\n", s_vinit);
    Clear(s_vinit);
    Delete(s_vinit);
    
    Printf(s_init,"    return SUCCESS;\n");
    Printf(s_init,"}\n");
    
    
    Printf(s_init,"PHP_MSHUTDOWN_FUNCTION(%s)\n{\n",module);
    Printf(s_init,"%s\n",s_shutdown);
    Printf(s_init,"    return SUCCESS;\n");
    Printf(s_init,"}\n");
    
    Printf(s_init,"PHP_RSHUTDOWN_FUNCTION(%s)\n{\n",module);
    Printf(s_init,"%s\n",r_shutdown);
    Printf(s_init,"    return SUCCESS;\n");
    Printf(s_init,"}\n");
           
    
    Printf(s_init,"PHP_MINFO_FUNCTION(%s)\n{\n",module);
    Printf(s_init,"%s", pragma_phpinfo);
    Printf(s_init,"}\n");
    Printf(s_init,"/* end init section */\n");
           
    Printf(f_h, "#endif /* PHP_%s_H */\n",  cap_module);

    Close(f_h);

    Printf(s_header, "%s\n\n",all_cs_entry);
    Printf(s_header, "%s {NULL, NULL, NULL}\n};\n\n",s_entry);
    Printf(s_header, "zend_module_entry %s_module_entry = {\n", module );
    Printf(s_header, "#if ZEND_MODULE_API_NO > 20010900\n" );
    Printf(s_header, "    STANDARD_MODULE_HEADER,\n");
    Printf(s_header, "#endif\n");
    Printf(s_header, "    \"%s\",\n", module);
    Printf(s_header, "    %s_functions,\n", module);
    Printf(s_header, "    PHP_MINIT(%s),\n", module);
    Printf(s_header, "    PHP_MSHUTDOWN(%s),\n", module);
    Printf(s_header, "    PHP_RINIT(%s),\n", module);
    Printf(s_header, "    PHP_RSHUTDOWN(%s),\n", module);
    Printf(s_header, "    PHP_MINFO(%s),\n",module);
    Printf(s_header, "#if ZEND_MODULE_API_NO > 20010900\n");
    Printf(s_header, "    NO_VERSION_YET,\n");
    Printf(s_header, "#endif\n");
    Printf(s_header, "    STANDARD_MODULE_PROPERTIES\n");
    Printf(s_header, "};\nzend_module_entry* SWIG_module_entry = &%s_module_entry;\n\n",module);
    
    String *type_table = NewString("");
    SwigType_emit_type_table(f_runtime,type_table);
    Printf(s_header,"%s",type_table);
    Delete(type_table);
    
    /* Oh dear, more things being called in the wrong order. This whole
     * function really needs totally redoing.
     */
    
    Printf(s_header, "/* end header section */\n");
    Printf(s_wrappers, "/* end wrapper section */\n");
    Printf(s_vdecl, "/* end vdecl subsection */\n");
    
    Printv(f_runtime, s_header, s_vdecl, s_wrappers, s_init, NIL);
    Delete(s_header);
    Delete(s_wrappers);
    Delete(s_init);
    Delete(s_vdecl);
    Close(f_runtime);
    Printf(f_phpcode, "%s\n%s\n?>\n", pragma_incl, pragma_code);
    Close(f_phpcode); 
    
    if ( gen_extra ) {
      create_extra_files(outfile);
    }
    else if( gen_make ) {
      create_simple_make();
    }
    
    return SWIG_OK;
  }
  
/* Just need to append function names to function table to register with
   PHP
*/

  void create_command(String *cname, String *iname) {
    
    Printf(f_h, "ZEND_NAMED_FUNCTION(%s);\n", iname);
    
    // This is for the single main function_entry record
    if (cs_entry) {
      Printf(cs_entry," ZEND_NAMED_FE(%(lower)s,%s, NULL)\n", cname,iname );
    } else {
      Printf(s_entry,"  ZEND_NAMED_FE(%(lower)s,%s, NULL)\n", cname,iname );
    }
  }
  /* ------------------------------------------------------------
   * dispatchFunction()
   * ------------------------------------------------------------ */
  void dispatchFunction(Node *n) {
    /* Last node in overloaded chain */

    int maxargs;
    String *tmp = NewString("");
    String *dispatch = Swig_overload_dispatch(n,"return %s(INTERNAL_FUNCTION_PARAM_PASSTHRU);",&maxargs);
        
    /* Generate a dispatch wrapper for all overloaded functions */
    
    Wrapper *f       = NewWrapper();
    String  *symname = Getattr(n,"sym:name");
    String  *wname   = Swig_name_wrapper(symname);
    
    create_command( symname, wname );
    Printv(f->def, "ZEND_NAMED_FUNCTION(", wname, ") {\n", NIL );
    
    Wrapper_add_local(f,"argc","int argc");

    Printf(tmp,"zval **argv[%d]", maxargs);
    Wrapper_add_local(f,"argv",tmp);

    Wrapper_add_local(f,"ii","int ii");

    Printf(f->code,"argc = ZEND_NUM_ARGS();\n");
    Printf(f->code,"zend_get_parameters_array_ex(argc,argv);\n");
    
    Replaceall(dispatch,"$args","self,args");

    Printv(f->code,dispatch,"\n",NIL);

    Printf(f->code,"/*No matching function for overloaded '%s'*/\n", symname);
    Printf(f->code,"\n");

    Printv(f->code,"}\n",NIL);
    Wrapper_print(f,s_wrappers);

    DelWrapper(f);
    Delete(dispatch);
    Delete(tmp);
    Delete(wname);
  }

  /* ------------------------------------------------------------
   * functionWrapper()
   * ------------------------------------------------------------ */

  virtual int functionWrapper(Node *n) {
    String   *name  = GetChar(n,"name");
    String   *iname = GetChar(n,"sym:name");
    SwigType *d     = Getattr(n,"type");
    ParmList *l     = Getattr(n,"parms");
    String *nodeType = Getattr(n, "nodeType");
    int newobject   = GetFlag(n,"feature:new");

    Parm *p;
    char source[256];
    char argnum[32];
    char args[32];
    int i,numopt;
    String *tm;
    Wrapper *f;
    bool mvr=(shadow && wrapperType == membervar);
    bool mvrset=(mvr && (Strcmp(iname, Swig_name_set(Swig_name_member(shadow_classname, name)))==0) );

    char wname[256];
    int overloaded = 0;
    String *overname = 0;

    int destructor = ( Cmp(nodeType, "destructor") == 0 );
    if ( destructor ) {
      // We only generate the Zend List Destructor.  Have
      // Zend manage the reference counting.
      return CreateZendListDestructor(n);

#if 0
      //If a script accessible destructor is desired/required, this code needs to be
      //put back into play.
      // Then we modify the wrap_action so it nulls out the self variable.
      String *del = Getattr(n,"wrap:action");
      Printf(del,"\nRETVAL_NULL();\n");
      Setattr(n,"wrap:action",del);
#endif
    }

    // Test for overloading;
    if (Getattr(n,"sym:overloaded")) {
      overloaded = 1;
      overname = Getattr(n,"sym:overname");
    } else {
      if (!addSymbol(iname,n))
        return SWIG_ERROR;
    }

    strcpy(wname,Char(Swig_name_wrapper(iname)));
    if (overname) {
      strcat(wname,Char(overname));
    }

    // if shadow and variable wrapper we want to snag the main contents
    // of this function to stick in to the property handler....    
    if (mvr) {
      String *php_function_name = NewString(iname);
      if( Strcmp( iname, Swig_name_set(Swig_name_member(shadow_classname, name)))== 0) {
        Setattr(shadow_set_vars, php_function_name, name);
      }
      if( Strcmp(iname, Swig_name_get(Swig_name_member(shadow_classname, name))) == 0) {
        Setattr(shadow_get_vars, php_function_name, name);
      }

      Delete(php_function_name);
    }

    f   = NewWrapper();
    numopt = 0;
    
    String *outarg = NewString("");
    String *cleanup = NewString("");
    
    if (mvr) { // do prop[gs]et header
      if (mvrset) {
        Printf(f->def, "static int _wrap_%s(zend_property_reference *property_reference, pval *value) {\n",iname);
      }
      else {
        Printf(f->def, "static pval _wrap_%s(zend_property_reference *property_reference) {\n",iname);
      }
    } else {
      // regular header
      // We don't issue these for overloaded functions.
      // destructors when using shadows.
      // And for static member variables
      if (!overloaded &&
          !(destructor && shadow) &&
          wrapperType != staticmembervar ) {
        create_command( iname, wname );
      }
      Printv(f->def, "ZEND_NAMED_FUNCTION(" , wname, ") {\n", NIL);
    }

    emit_args(d, l, f);
    /* Attach standard typemaps */

    emit_attach_parmmaps(l,f);

    // wrap:parms is used by overload resolution.
    Setattr(n,"wrap:parms",l);

    int num_arguments = emit_num_arguments(l);
    int num_required  = emit_num_required(l);
    numopt = num_arguments - num_required;

    int has_this_ptr = (wrapperType==memberfn)?shadow:0;

    sprintf(args, "%s[%d]", "zval **args", num_arguments-has_this_ptr); 

    Wrapper_add_local(f, "args",args);

    // This generated code may be called 
    // 1) as an object method, or
    // 2) as a class-method/function (without a "this_ptr")
    // Option (1) has "this_ptr" for "this", option (2) needs it as
    // first parameter

    // NOTE: possible we ignore this_ptr as a param for native constructor

    Printf(f->code, "SWIG_ResetError();\n");

    if (has_this_ptr)
      Printf(f->code, "/* This function uses a this_ptr*/\n");

    if (native_constructor) {
      if (native_constructor==NATIVE_CONSTRUCTOR) {
        Printf(f->code, "/* NATIVE Constructor */\n");
      }
      else {
        Printf(f->code, "/* ALTERNATIVE Constructor */\n");
      }
    }

    if (mvr && ! mvrset) {
      Wrapper_add_local(f, "_return_value", "zval _return_value");
      Wrapper_add_local(f, "return_value", "zval *return_value=&_return_value");
    };

    if(numopt > 0) { // membervariable wrappers do not have optional args
      Wrapper_add_local(f, "arg_count", "int arg_count");
      Printf(f->code,"arg_count = ZEND_NUM_ARGS();\n");
      Printf(f->code,"if(arg_count<%d || arg_count>%d)\n",num_required, num_arguments);
      Printf(f->code,"\tWRONG_PARAM_COUNT;\n\n");
             
      
      /* Verified args, retrieve them... */
      Printf(f->code,"if(zend_get_parameters_array_ex(arg_count,args)!=SUCCESS)\n");
      Printf(f->code,"\t\tWRONG_PARAM_COUNT;\n\n");
      
    } else if (!mvr) {
      Printf(f->code, "if(((ZEND_NUM_ARGS() )!= %d) || (zend_get_parameters_array_ex(%d, args)",
             num_arguments-has_this_ptr, num_arguments-has_this_ptr);
      Printf(f->code, "!= SUCCESS)) {\n");
      Printf(f->code, "WRONG_PARAM_COUNT;\n}\n\n");     
    }
    
    /* Now convert from php to C variables */
    // At this point, argcount if used is the number of deliberatly passed args
    // not including this_ptr even if it is used.
    // It means error messages may be out by argbase with error
    // reports.  We can either take argbase into account when raising 
    // errors, or find a better way of dealing with _thisptr
    // I would like, if objects are wrapped, to assume _thisptr is always
    // _this and the and not the first argument
    // This may mean looking at Lang::memberfunctionhandler

    for (i = 0, p = l; i < num_arguments; i++) {
      /* Skip ignored arguments */
      //while (Getattr(p,"tmap:ignore")) { p = Getattr(p,"tmap:ignore:next");}
      while (checkAttribute(p,"tmap:in:numinputs","0")) {
        p = Getattr(p,"tmap:in:next");
      }

      SwigType *pt = Getattr(p,"type");
      
      if (mvr) { // do we assert that numargs=2, that i<2
        if (i==0) {
          sprintf(source,"&(property_reference->object)");
        }
        else {
          sprintf(source,"&value");
        }
      } else {
        if (i==0 && has_this_ptr ) {
          sprintf(source,"&this_ptr");
        } else {
          sprintf(source, "args[%d]", i-has_this_ptr);
        }
      }
      
      String *ln = Getattr(p,"lname");
      sprintf(argnum, "%d", i+1);
      
       /* Check if optional */
      
      if(i>= (num_required)) {
        Printf(f->code,"\tif(arg_count > %d) {\n", i);
      }
      
      if ((tm = Getattr(p,"tmap:in"))) {
        Replaceall(tm,"$source",source);
        Replaceall(tm,"$target",ln);
        Replaceall(tm,"$input", source);
        Setattr(p,"emit:input", source);
        Printf(f->code,"%s\n",tm);
        p = Getattr(p,"tmap:in:next");
        if (i >= num_required) {
          Printf(f->code,"}\n");
        }
        continue;
      } else {
        Printf(stderr,"%s : Line %d, Unable to use type %s as a function argument.\n",
               input_file, line_number, SwigType_str(pt,0));
      }
      if (i>= num_required) {
        Printf(f->code,"\t}\n");
      }
    }
    
    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:check"))) {
        Replaceall(tm,"$target",Getattr(p,"lname"));
        Printv(f->code,tm,"\n",NIL);
        p = Getattr(p,"tmap:check:next");
      } else {
        p = nextSibling(p);
      }
    }

    /* Insert cleanup code */
    for (i = 0, p = l; p; i++) {
      if ((tm = Getattr(p,"tmap:freearg"))) {
        Replaceall(tm,"$source",Getattr(p,"lname"));
        Printv(cleanup,tm,"\n",NIL);
        p = Getattr(p,"tmap:freearg:next");
      } else {
        p = nextSibling(p);
      }
    }
    
    /* Insert argument output code */
    for (i=0,p = l; p;i++) {
      if ((tm = Getattr(p,"tmap:argout"))) {
        Replaceall(tm,"$source",Getattr(p,"lname"));
        //      Replaceall(tm,"$input",Getattr(p,"lname"));
        Replaceall(tm,"$target","return_value");
        Replaceall(tm,"$result","return_value");
        Replaceall(tm,"$arg", Getattr(p,"emit:input"));
        Replaceall(tm,"$input", Getattr(p,"emit:input"));
        Printv(outarg,tm,"\n",NIL);
        p = Getattr(p,"tmap:argout:next");
      } else {
        p = nextSibling(p);
      }
    }
    
    /* emit function call*/
    emit_action(n,f);
    
    if((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
      Replaceall(tm, "$input", "result");
      Replaceall(tm, "$source", "result");
      Replaceall(tm, "$target", "return_value");
      Replaceall(tm, "$result", "return_value");
      Replaceall(tm,"$owner", newobject ? "1" : "0");
      Printf(f->code, "%s\n", tm);
      // are we returning a wrapable object?
      // I don't know if this test is comlete, I nicked it
      if(is_shadow(d) && (SwigType_type(d) != T_ARRAY)) {
        Printf(f->code,"/* Wrap this return value */\n");
        if (native_constructor==NATIVE_CONSTRUCTOR) {
          Printf(f->code, "if (this_ptr) {\n");
          Printf(f->code, "/* NATIVE Constructor, use this_ptr */\n");
          Printf(f->code, "zval *_cPtr; MAKE_STD_ZVAL(_cPtr);\n");
          Printf(f->code, "*_cPtr = *return_value;\n");
          Printf(f->code, "INIT_ZVAL(*return_value);\n");
          Printf(f->code, "add_property_zval(this_ptr,\"_cPtr\",_cPtr);\n");
          Printf(f->code, "} else if (! this_ptr) ");
        }
        { // THIS CODE only really needs writing out if the object to be returned
          // Is being shadow-wrap-thingied
          Printf(f->code, "{\n/* ALTERNATIVE Constructor, make an object wrapper */\n");
          // Make object 
          String *shadowrettype = NewString("");
          SwigToPhpType(d, iname, shadowrettype, shadow);
          
          Printf(f->code,"zval *obj, *_cPtr;\n");
          Printf(f->code,"MAKE_STD_ZVAL(obj);\n");
          Printf(f->code,"MAKE_STD_ZVAL(_cPtr);\n");
          Printf(f->code,"*_cPtr = *return_value;\n");
          Printf(f->code,"INIT_ZVAL(*return_value);\n");
          
          if (! shadow) {
            Printf(f->code,"*return_value=*_cPtr;\n");
          } else {
            Printf(f->code,"object_init_ex(obj,ptr_ce_swig_%s);\n",shadowrettype);
            Printf(f->code,"add_property_zval(obj,\"_cPtr\",_cPtr);\n");
            Printf(f->code,"*return_value=*obj;\n");
                   
          }
          Printf(f->code, "}\n");
        }
      } // end of if-shadow lark
    } else {
      Printf(stderr,"%s: Line %d, Unable to use return type %s in function %s.\n",
             input_file, line_number, SwigType_str(d,0), name);
    }
    
    if(outarg) {
      Printv(f->code,outarg,NIL);
    }
    
    if(cleanup) {
      Printv(f->code,cleanup,NIL);
    }
    
    // Whats this bit for?
    if((tm = Swig_typemap_lookup_new("ret",n,"result",0))) {
      Printf(f->code,"%s\n", tm);
    }

    if (mvr) {
      if (! mvrset) {
        Printf(f->code,"return _return_value;\n");    
      }
      else{
        Printf(f->code,"return SUCCESS;\n");
      }
    }
    else {
      Printf(f->code,"return;\n");
    }

    /* Error handling code */
    Printf(f->code,"fail:\n");
    Printv(f->code,cleanup,NIL);
    Printv(f->code,"zend_error(ErrorCode(),ErrorMsg());",NIL);

    Printf(f->code, "}\n");    

    // These were cribbed from python.cxx
    Replaceall(f->code,"$cleanup",cleanup);
    Replaceall(f->code,"$symname",iname);

    Wrapper_print(f,s_wrappers);

    // wrap:name is used by overload resolution
    Setattr(n,"wrap:name",wname);
    if (overloaded && !Getattr(n,"sym:nextSibling")) {
      dispatchFunction(n);
    }

    return SWIG_OK;
  }
  
  /* ------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------ */

  virtual int globalvariableHandler(Node *n) {
    char *name = GetChar(n,"name");
    char *iname = GetChar(n,"sym:name");
    SwigType *t = Getattr(n,"type");
    String *tm;

    /* First do the wrappers such as name_set(), name_get()
     * as provided by the baseclass's implementation of variableWrapper
     */
    if (Language::globalvariableHandler(n) == SWIG_NOWRAP ) {
      return SWIG_NOWRAP;
    }

    if (!addSymbol(iname,n))
      return SWIG_ERROR;

    SwigType_remember(t);

    /* First link C variables to PHP */

    tm = Swig_typemap_lookup_new("varinit", n, name, 0);
    if(tm) {
      Replaceall(tm, "$target", name);
      Printf(s_vinit, "%s\n", tm);
    } else {
      Printf(stderr,"%s: Line %d, Unable to link with type %s\n", 
             input_file, line_number, SwigType_str(t,0), name);
    }

    /* Now generate PHP -> C sync blocks */
    /*
    tm = Swig_typemap_lookup_new("varin", n, name, 0);
      if(tm) {
      Replaceall(tm, "$symname", iname);
      Printf(f_c->code, "%s\n", tm);
      } else {
      Printf(stderr,"%s: Line %d, Unable to link with type %s\n", 
      input_file, line_number, SwigType_str(t, 0), name);
      }
    */
    /* Now generate C -> PHP sync blocks */
    /*
      if(!GetFlag(n,"feature:immutable")) {
      
      tm = Swig_typemap_lookup_new("varout", n, name, 0);
      if(tm) {
      Replaceall(tm, "$symname", iname);
      Printf(f_php->code, "%s\n", tm);
      } else {
      Printf(stderr,"%s: Line %d, Unable to link with type %s\n", 
      input_file, line_number, SwigType_str(t, 0), name);
      }
      }
    */
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------ */
  
  virtual int constantWrapper(Node *n) {
    String *name = GetChar(n,"name");
    String *iname = GetChar(n,"sym:name");
    SwigType *type = Getattr(n,"type");
    String   *rawval = Getattr(n,"rawval");
    String   *value = rawval ? rawval : Getattr(n,"value");
    String  *tm;

    if (!addSymbol(iname,n)) return SWIG_ERROR;

    SwigType_remember(type);

    if((tm = Swig_typemap_lookup_new("consttab", n, name, 0))) {
      Replaceall(tm, "$source", value);
      Replaceall(tm, "$target", name);
      Replaceall(tm, "$value", value);
      Printf(s_cinit, "%s\n", tm);
    }
    return SWIG_OK;
  }

  /*
   * PHP4::pragma()
   *
   * Pragma directive.
   *
   * %pragma(php4) code="String"         # Includes a string in the .php file
   * %pragma(php4) include="file.pl"     # Includes a file in the .php file
   */
  
  virtual int pragmaDirective(Node *n) {
    if (!ImportMode) {
      String *lang = Getattr(n,"lang");
      String *type = Getattr(n,"name");
      String *value = Getattr(n,"value");

      if (Strcmp(lang,"php4") == 0) {
        
        if (Strcmp(type, "code") == 0) {
          if (value) {
            Printf(pragma_code, "%s\n", value);
          }
        } else if (Strcmp(type, "include") == 0) {
          if (value) {
            Printf(pragma_incl, "include \"%s\";\n", value);
          }
        } else if (Strcmp(type, "phpinfo") == 0) {
          if (value) {
            Printf(pragma_phpinfo, "%s\n", value);
          }
        } else {
          Printf(stderr, "%s : Line %d. Unrecognized pragma.\n",
                 input_file, line_number);
        }
      }
    }
    return Language::pragmaDirective(n);
  }

  /* ------------------------------------------------------------
   * classDeclaration()
   * ------------------------------------------------------------ */

  virtual int classDeclaration(Node *n) {
    if (!Getattr(n,"feature:onlychildren")) {
      String *symname = Getattr(n,"sym:name");
      Setattr(n,"php:proxy",symname);
    }
    
    return Language::classDeclaration(n);
  }
  
  /* ------------------------------------------------------------
   * classHandler()
   * ------------------------------------------------------------ */

  virtual int classHandler(Node *n) {
    constructors=0;
    //SwigType *t = Getattr(n, "classtype");
    class_name = Getattr(n, "sym:name");
    // String *use_class_name=SwigType_manglestr(SwigType_ltype(t));

    if(shadow) {
      char *rename = GetChar(n, "sym:name");

      if (!addSymbol(rename,n)) return SWIG_ERROR;
      shadow_classname = Swig_copy_string(rename);
      cs_entry = NewString("");
      Printf(cs_entry,"/* Function entries for %s */\n",shadow_classname);
      Printf(cs_entry,"static zend_function_entry %s_functions[] = {\n", shadow_classname);

      if(Strcmp(shadow_classname, module) == 0) {
        Printf(stderr, "class name cannot be equal to module name: %s\n", shadow_classname);
        SWIG_exit(1);
      }

      shadow_get_vars = NewHash();
      shadow_set_vars = NewHash();

      /* Deal with inheritance */
      List *baselist = Getattr(n,"bases");
      if (baselist) {
	Iterator base = First(baselist);
	while(base.item && GetFlag(base.item,"feature:ignore")) {
	  base = Next(base);
	}
	base = Next(base);
	if (base.item) {
	  /* Warn about multiple inheritance for additional base class(es) */
	  while (base.item) {
	    if (GetFlag(base.item,"feature:ignore")) {
	      base = Next(base);
	      continue;
	    }
	    String *proxyclassname = SwigType_str(Getattr(n,"classtypeobj"),0);
	    String *baseclassname = SwigType_str(Getattr(base.item,"name"),0);
	    Swig_warning(WARN_PHP4_MULTIPLE_INHERITANCE, input_file, line_number, 
		"Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in Php4.\n", proxyclassname, baseclassname);
	    base = Next(base);
	  }
	}
      }

      /* Write out class init code */
      Printf(s_vdecl,"static zend_class_entry ce_swig_%s;\n",shadow_classname);
      Printf(s_vdecl,"static zend_class_entry* ptr_ce_swig_%s=NULL;\n",shadow_classname);
    }

    classnode=n;
    Language::classHandler(n);
    classnode=0;

    if(shadow) {
      DOH *key;
      int gcount, scount;
      String      *s_propget=NewString("");
      String      *s_propset=NewString("");
      List *baselist = Getattr(n, "bases");
      Iterator ki, base;


      // If no constructor was generated (abstract class) we had better
      // generate a constructor that raises an error about instantiating
      // abstract classes
      if (Getattr(n,"abstract") && constructors==0 ) {
        // have to write out fake constructor which raises an error when called
        abstractConstructorHandler(n);
      }

      Printf(s_oinit,"/* Define class %s */\n",shadow_classname);
      Printf(s_oinit,"INIT_OVERLOADED_CLASS_ENTRY(ce_swig_%s,\"%(lower)s\",%s_functions,",
             shadow_classname,shadow_classname, shadow_classname);
      Printf(s_oinit,"NULL,_wrap_propget_%s,_wrap_propset_%s);\n",shadow_classname,shadow_classname);

      // ******** Write property SET handlers
      Printf(s_header,"static int _wrap_propset_%s(zend_property_reference *property_reference, pval *value);\n",
             shadow_classname);
      Printf(s_header,"static int _propset_%s(zend_property_reference *property_reference, pval *value);\n",
             shadow_classname);

      Printf(s_propset,"static int _wrap_propset_%s(zend_property_reference *property_reference, pval *value) { \n",
             shadow_classname);
      Printf(s_propset,"  zval * _value;\n");
      Printf(s_propset,"  zend_llist_element *element = property_reference->elements_list->head;\n");
      Printf(s_propset,"  zend_overloaded_element *property=(zend_overloaded_element *)element->data;\n");
      Printf(s_propset,"  if (_propset_%s(property_reference, value)==SUCCESS) return SUCCESS;\n", shadow_classname);
      Printf(s_propset,"  /* set it ourselves as it is %s */\n",shadow_classname);
      Printf(s_propset,"  MAKE_STD_ZVAL(_value);\n");
      Printf(s_propset,"  *_value=*value;\n");
      Printf(s_propset,"  INIT_PZVAL(_value);\n");
      Printf(s_propset,"  zval_copy_ctor(_value);\n");
      Printf(s_propset,"  return add_property_zval_ex(property_reference->object,Z_STRVAL_P(&(property->element)),1+Z_STRLEN_P(&(property->element)),_value);\n");
      Printf(s_propset,"}\n");
      Printf(s_propset,"static int _propset_%s(zend_property_reference *property_reference, pval *value) {\n",
             shadow_classname);


      if (baselist) {
        base=First(baselist);
      }
      else {
        base.item = NULL;
      }

      while(base.item && GetFlag(base.item,"feature:ignore")) {
        base = Next(base);
      }

      ki = First(shadow_set_vars);
      key = ki.key;

      // Print function header; we only need to find property name if there
      // are properties for this class to look up...
      if (key || ! base.item) { // or if we are base class and set it ourselves
        Printf(s_propset,"  /* get the property name */\n");
        Printf(s_propset,"  zend_llist_element *element = property_reference->elements_list->head;\n");
        Printf(s_propset,"  zend_overloaded_element *property=(zend_overloaded_element *)element->data;\n");
        Printf(s_propset,"  char *propname=Z_STRVAL_P(&(property->element));\n");
      } else {
        if (base.item) {
          Printf(s_propset,"  /* No extra properties for subclass %s */\n",shadow_classname);
        } else {
          Printf(s_propset,"  /* No properties for base class %s */\n",shadow_classname);
        }
      }

      scount=0;
      while (ki.key) {
        key = ki.key;
        if (scount++) {
          Printf(s_propset," else");
        }
        Printf(s_propset,"  if (strcmp(propname,\"%s\")==0) {\n",Getattr(shadow_set_vars,key) );
        Printf(s_propset,"    return _wrap_%s(property_reference, value);\n",key);
        Printf(s_propset,"  }");

        ki=Next(ki);
      }

      if (scount) {
        Printf(s_propset," else");
      }

      // If there is a base class then chain it's handler else set directly
      // try each base class handler, else set directly...
      if (base.item) {
        Printf(s_propset,  "  {\n    /* chain to base class */\n");
        while(base.item) {
          Printf(s_propset,"    if (_propset_%s(property_reference, value)==SUCCESS) return SUCCESS;\n",
                 GetChar(base.item, "sym:name"));
          
          base=Next(base);
          while (base.item && GetFlag(base.item,"feature:ignore")) {
            base=Next(base);
          }
        }
        Printf(s_propset,"  }\n");
      }
      Printf(s_propset,"  return FAILURE;\n}\n\n");

      // ******** Write property GET handlers
      Printf(s_header,"static pval _wrap_propget_%s(zend_property_reference *property_reference);\n",
             shadow_classname);
      Printf(s_header,"static int _propget_%s(zend_property_reference *property_reference, pval *value);\n",
             shadow_classname);

      Printf(s_propget,"static pval _wrap_propget_%s(zend_property_reference *property_reference) {\n",
             shadow_classname);
      Printf(s_propget,"  pval result;\n");
      Printf(s_propget,"  pval **_result;\n");
      Printf(s_propget,"  zend_llist_element *element = property_reference->elements_list->head;\n");
      Printf(s_propget,"  zend_overloaded_element *property=(zend_overloaded_element *)element->data;\n");
      Printf(s_propget,"  result.type = IS_NULL;\n");
      Printf(s_propget,"  if (_propget_%s(property_reference, &result)==SUCCESS) return result;\n", shadow_classname);
      Printf(s_propget,"  /* return it ourselves */\n");
      Printf(s_propget,"  if (zend_hash_find(Z_OBJPROP_P(property_reference->object),Z_STRVAL_P(&(property->element)),1+Z_STRLEN_P(&(property->element)),(void**)&_result)==SUCCESS) {\n");
      Printf(s_propget,"  zval *_value;\n");
      Printf(s_propget,"  MAKE_STD_ZVAL(_value);");
      Printf(s_propget,"  *_value=**_result;\n");
      Printf(s_propget,"  INIT_PZVAL(_value);\n");
      Printf(s_propget,"  zval_copy_ctor(_value);\n");
      Printf(s_propget,"  return *_value;\n");
      Printf(s_propget,"  }\n");
      Printf(s_propget,"  result.type = IS_NULL;\n");
      Printf(s_propget,"  return result;\n");
      Printf(s_propget,"}\n");
      Printf(s_propget,"static int _propget_%s(zend_property_reference *property_reference, pval *value) {\n",
             shadow_classname);

      if (baselist) {
        base=First(baselist); 
      } else {
        base.item=NULL;
      }
      while(base.item && GetFlag(base.item,"feature:ignore")) {
        base = Next(base);
      }
      ki = First(shadow_get_vars);

      key = ki.key;

      // Print function header; we only need to find property name if there
      // are properties for this class to look up...
      if (key || !base.item ) { // or if we are base class...
        Printf(s_propget,"  /* get the property name */\n");
        Printf(s_propget,"  zend_llist_element *element = property_reference->elements_list->head;\n");
        Printf(s_propget,"  zend_overloaded_element *property=(zend_overloaded_element *)element->data;\n");
        Printf(s_propget,"  char *propname=Z_STRVAL_P(&(property->element));\n");
      } else {
        if (base.item) {
          Printf(s_propget,"  /* No extra properties for subclass %s */\n",shadow_classname);
        } else {
          Printf(s_propget,"  /* No properties for base class %s */\n",shadow_classname);
        }
      }

      gcount=0;
      while (ki.key) {
        key = ki.key;
        if (gcount++) {
          Printf(s_propget," else");
        }
        Printf(s_propget,"  if (strcmp(propname,\"%s\")==0) {\n",Getattr(shadow_get_vars,key));
        Printf(s_propget,"    *value=_wrap_%s(property_reference);\n",key);
        Printf(s_propget,"    return SUCCESS;\n");
        Printf(s_propget,"  }");

        ki=Next(ki);
      }

      if (gcount) {
        Printf(s_propget," else");
      }

      // If there is a base class then chain it's handler else return null
      if (base.item) {
        Printf(s_propget,  "  {\n    /* chain to base class */\n");
        while(base.item) {
          Printf(s_propget,"    if (_propget_%s(property_reference,  value)==SUCCESS) return SUCCESS;\n",
               GetChar(base.item, "sym:name"));

          base=Next(base);
          while (base.item && GetFlag(base.item,"feature:ignore")) {
            base=Next(base);
          }
        }
        Printf(s_propget,"  }\n");
      }
      Printf(s_propget,"  return FAILURE;\n}\n\n");

      // wrappers generated now...

      // add wrappers to output code
      Printf(s_wrappers,"/* property handler for class %s */\n",shadow_classname);
      Printv(s_wrappers,s_propget,s_propset,NIL);

      // Save class in class table
      if (baselist) {
        base=First(baselist);
      }
      else {
        base.item=NULL;
      }
      while(base.item && GetFlag(base.item,"feature:ignore")) {
        base = Next(base);
      }

      if (base.item) {
        Printf(s_oinit,"if (! (ptr_ce_swig_%s=zend_register_internal_class_ex(&ce_swig_%s,&ce_swig_%s,NULL))) zend_error(E_ERROR,\"Error registering wrapper for class %s\");\n",
               shadow_classname,shadow_classname,GetChar(base.item, "sym:name"), shadow_classname);
      } else {
        Printf(s_oinit,"if (! (ptr_ce_swig_%s=zend_register_internal_class_ex(&ce_swig_%s,NULL,NULL))) zend_error(E_ERROR,\"Error registering wrapper for class %s\");\n",
               shadow_classname,shadow_classname, shadow_classname);
      }
      Printf(s_oinit,"\n");

      // Write the enum initialisation code in a static block
      // These are all the enums defined withing the c++ class.
      

      free(shadow_classname);
      shadow_classname = NULL;
      
      Delete(shadow_set_vars); shadow_set_vars = NULL;
      Delete(shadow_get_vars); shadow_get_vars = NULL;
      
      Printf(all_cs_entry,"%s   { NULL, NULL, NULL}\n};\n",cs_entry);
      //??delete cs_entry;
      cs_entry=NULL;
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int memberfunctionHandler(Node *n) {
    char *name = GetChar(n, "name");
    char *iname = GetChar(n, "sym:name");
    
    wrapperType = memberfn;
    this->Language::memberfunctionHandler(n);
    wrapperType = standard;
    
    if(shadow) {
      char *realname = iname ? iname : name;
      String *php_function_name = Swig_name_member(shadow_classname, realname);
      create_command(realname,Swig_name_wrapper(php_function_name));
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * membervariableHandler()
   * ------------------------------------------------------------ */

  virtual int membervariableHandler(Node *n) {
    
    wrapperType = membervar;
    Language::membervariableHandler(n);
    wrapperType = standard;
    
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * staticmembervariableHandler()
   * ------------------------------------------------------------ */

  virtual int staticmembervariableHandler(Node *n) {

    wrapperType = staticmembervar;
    Language::staticmembervariableHandler(n);
    wrapperType = standard;

    SwigType* type = Getattr(n, "type" );
    String *name  = Getattr(n, "name" );
    String *iname = Getattr(n, "sym:name" );

    /* A temporary(!) hack for static member variables.
     * Php currently supports class functions, but not class variables.
     * Until it does, we convert a class variable to a class function
     * that returns the current value of the variable. E.g.
     *
     * class Example {
     *  public:
     *          static int ncount;
     * };
     *
     * would be available in php as Example::ncount() 
     */

    // If the variable is const, then it's wrapped as a constant with set/get functions.
    if ( SwigType_isconst(type) )
      return SWIG_OK;

    // This duplicates the logic from Langauge::variableWrapper() to test if the set wrapper
    // is made.
    int assignable = is_assignable(n);
    if (assignable) {
      String *tm = Swig_typemap_lookup_new("globalin",n,name,0);
      if (!tm && SwigType_isarray(type)) {
        assignable = 0;
      }
    }

    create_command( iname, Swig_name_wrapper(iname) );

    Wrapper *f = NewWrapper();

    Printv(f->def, "ZEND_NAMED_FUNCTION(",Swig_name_wrapper(iname), ") {\n", NIL );
    String *mget = Swig_name_wrapper(Swig_name_get( Swig_name_member(class_name,iname)));
    String *mset = Swig_name_wrapper(Swig_name_set( Swig_name_member(class_name,iname)));

    if ( assignable ) {
      Printf(f->code, "if (ZEND_NUM_ARGS() > 0 ) {\n" );
      Printf(f->code, "  %s( INTERNAL_FUNCTION_PARAM_PASSTHRU );\n", mset );
      Printf(f->code, "  // need some error checking here?\n" );
      Printf(f->code, "  // Set the argument count to 0 for the get call\n");
      Printf(f->code, "  ht = 0;\n");
      Printf(f->code, "}\n" );
    }

    Printf(f->code, "%s( INTERNAL_FUNCTION_PARAM_PASSTHRU );\n",mget );
    Printf(f->code, "}\n");

    Wrapper_print(f, s_wrappers);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int staticmemberfunctionHandler(Node *n) {
    char *name = GetChar(n, "name");
    char *iname = GetChar(n, "sym:name");
    
    Language::staticmemberfunctionHandler(n);
    
    if(shadow) {
      String *symname = Getattr(n, "sym:name");
      char *realname = iname ? iname : name;
      String *php_function_name = Swig_name_member(shadow_classname, realname);
      create_command(symname, Swig_name_wrapper(php_function_name) );
    }
    
    return SWIG_OK;
  }

  
  void SwigToPhpType(SwigType *t, String_or_char *pname, String* php_type, int shadow_flag) {
    char *ptype = 0;
    
    if(shadow_flag) {
      ptype = PhpTypeFromTypemap((char*)"pstype", t, pname,(char*)"");
    }
    if(!ptype) {
      ptype = PhpTypeFromTypemap((char*)"ptype",t,pname,(char*)"");
    }
    
    
    if(ptype) {
      Printf(php_type, ptype);
      free(ptype);
    }
    else {
      /* Map type here */
      switch(SwigType_type(t)) {
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
      case T_BOOL:
      case T_STRING:
      case T_VOID:
        Printf(php_type, "");
        break;
      case T_POINTER:
      case T_REFERENCE:
      case T_USER:
        if(shadow_flag && is_shadow(t)) {
          Printf(php_type, Char(is_shadow(t)));
        }
        else {
          Printf(php_type, "");
        }
        break;
      case T_ARRAY:
        /* TODO */
        break;
      default:
        Printf(stderr, "SwigToPhpType: unhandled data type: %s\n", SwigType_str(t,0));
        break;
      }
    }
  }
  
  
  char *PhpTypeFromTypemap(char *op, SwigType *t, String_or_char *pname, String_or_char *lname) {
    String *tms;
    char bigbuf[1024];
    char *tm;
    char *c = bigbuf;
    if(!(tms = Swig_typemap_lookup(op, t, pname, lname, (char*)"", (char*)"", NULL))) {
      return NULL;
    }
    
    tm = Char(tms);
    while(*tm && (isspace(*tm) || *tm == '{')) {
      tm++;
    }
    while(*tm && *tm != '}') {
      *c++ = *tm++;
    }
    *c='\0';
    return Swig_copy_string(bigbuf);
  }
  
  int abstractConstructorHandler(Node *n) {
    String *iname = GetChar(n, "sym:name");
    if (shadow) {
      Wrapper *f;
      f   = NewWrapper();

      String *wname = NewStringf( "_wrap_new_%s", iname );
      create_command( iname, wname );

      Printf(f->def, "ZEND_NAMED_FUNCTION(_wrap_new_%s) {\n", iname );
      Printf(f->def, "zend_error(E_ERROR,\"Cannot create swig object type: %s as the underlying object is abstract\");\n",
             iname);
      Printf(f->def, "}\n\n");
      Wrapper_print(f,s_wrappers);
      DelWrapper(f);
    }
    return SWIG_OK;
  }
  /* ------------------------------------------------------------
   * constructorHandler()
   * ------------------------------------------------------------ */
  
  virtual int constructorHandler(Node *n) {
    char *iname = GetChar(n, "sym:name");

    if (shadow) {
      native_constructor = (strcmp(iname, shadow_classname) == 0)?\
        NATIVE_CONSTRUCTOR:ALTERNATIVE_CONSTRUCTOR;
    }
    else {
      native_constructor=0;
    }
    constructors++;
    Language::constructorHandler(n);
    
    if(shadow) {
      String *wname = NewStringf( "_wrap_new_%s", iname );
      create_command( iname, wname );
    }
    
    native_constructor = 0;
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constructorHandler()
   * ------------------------------------------------------------ */
  //virtual int destructorHandler(Node *n) {
  //}
  int CreateZendListDestructor(Node *n) {
    String *name    = GetChar(n,"name");
    String *iname   = GetChar(n,"sym:name");
    SwigType *d     = Getattr(n,"type");
    ParmList *l     = Getattr(n,"parms");
    
    String *destructorname=NewString("");
    Printf(destructorname,"_%s",Swig_name_wrapper(iname));
    Setattr(classnode,"destructor",destructorname);

    Wrapper *df = NewWrapper();
    Printf(df->def,"/* This function is designed to be called by the zend list destructors */\n");
    Printf(df->def,"/* to typecast and do the actual destruction */\n");
    Printf(df->def,"void %s(zend_rsrc_list_entry *rsrc, const char *type_name TSRMLS_DC) {\n",destructorname);

    Wrapper_add_localv(df, "value", "swig_object_wrapper *value=(swig_object_wrapper *) rsrc->ptr", NIL);
    Wrapper_add_localv(df, "ptr", "void *ptr=value->ptr", NIL);
    Wrapper_add_localv(df, "newobject", "int newobject=value->newobject", NIL);

    emit_args(d, l, df);
    emit_attach_parmmaps(l,df);

    // Get type of first arg, thing to be destructed
    // Skip ignored arguments
    Parm *p=l;
    //while (Getattr(p,"tmap:ignore")) {p = Getattr(p,"tmap:ignore:next");}
    while (checkAttribute(p,"tmap:in:numinputs","0")) {
      p = Getattr(p,"tmap:in:next");
    }
    SwigType *pt = Getattr(p,"type");

    Printf(df->code,"  efree(value);\n");
    Printf(df->code,"  if (! newobject) return; /* can't delete it! */\n");
    Printf(df->code,"  SWIG_ZTS_ConvertResourceData(ptr,rsrc->type,type_name,(void **) &arg1,SWIGTYPE%s TSRMLS_CC);\n",
           SwigType_manglestr(pt));
    Printf(df->code,"  if (! arg1) zend_error(E_ERROR, \"%s resource already free'd\");\n", Char(name));

    emit_action(n,df);
    
    Printf(df->code,"}\n");

    Wrapper_print(df,s_wrappers);

    return SWIG_OK;

  }
  
  /* ------------------------------------------------------------
   * memberconstantHandler()
   * ------------------------------------------------------------ */

  virtual int memberconstantHandler(Node *n) {
    Language::memberconstantHandler(n);
    return SWIG_OK;
  }

};  /* class PHP4 */

/* -----------------------------------------------------------------------------
 * swig_php()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static PHP4 *maininstance=0;

// We use this function to be able to write out zend_register_list_destructor_ex
// lines for most things in the type table
// NOTE: it's a function NOT A PHP4::METHOD
extern "C"
void typetrace(SwigType *ty, String *mangled, String *clientdata) {
  Node *class_node;
  if (!zend_types) {
    zend_types=NewHash();
  }
  // we want to know if the type which reduced to this has a constructor
  if ((class_node=maininstance->classLookup(ty))) {
    if (! Getattr(zend_types,mangled)) {
      // OK it may have been set before by a different SwigType but it would
      // have had the same underlying class node I think
      // - it is certainly required not to have different originating class
      // nodes for the same SwigType
      Setattr(zend_types,mangled,class_node);
    }
  } else { // a non-class pointer
    Setattr(zend_types,mangled,NOTCLASS);
  }
  if (r_prevtracefunc) (*r_prevtracefunc)(ty, mangled, (String *) clientdata);
}

static Language * new_swig_php() {
  maininstance=new PHP4();
  if (! r_prevtracefunc) {
    r_prevtracefunc=SwigType_remember_trace(typetrace);
  } else {
    Printf(stderr,"php4 Typetrace vector already saved!\n");
    assert(0);
  }
  return maininstance;
}
extern "C" Language * swig_php(void) {
  return new_swig_php();
}
 

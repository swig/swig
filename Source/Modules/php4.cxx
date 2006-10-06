/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * php4.cxx
 *
 * Php language module for SWIG.
 * -----------------------------------------------------------------------------
 */

/* FIXME: PHP5 OO wrapping TODO list:
 *
 * Short term (ideally before 1.3.30 is released):
 *
 * Sort out auto-renaming of method and class names which are reserved
 *   words (e.g. empty, clone, exception, etc.) vs -php4/-php5 in some
 *   sane way.
 *
 * Sort out wrapping of static member variables in OO PHP5 (which first may
 *   mean we need to sort them out for PHP4!)
 *
 * Medium term:
 *
 * Handle default parameters on overloaded methods in PHP where possible.
 *   (Mostly done - just need to handle cases of overloaded methods with
 *   default parameters...)
 *   This is an optimisation - we could handle this case using a PHP
 *   default value, but currently we treat it as we would for a default
 *   value which is a compound C++ expression (i.e. as if we had a
 *   a method with two overloaded forms instead of a single method with
 *   a default parameter value).
 *
 * Create __isset method for PHP 5.1 and later (we can probably just
 *   always generate as PHP 5.0 should just ignore it).
 *
 * Long term:
 *
 * Option to generate code to work with PHP4 instead ("public $_cPtr;" ->
 *   "var $_cPtr;", "abstract" -> "", no static class functions - but making
 *   these changes gives a segfault with make check...)
 * Sort out locale-dependent behaviour of strtod() - it's harmless unless
 *   SWIG ever sets the locale and DOH/base.c calls atof, so we're probably
 *   OK currently at least.
 */

/*
 * TODO: Replace remaining stderr messages with Swig_error or Swig_warning
 * (may need to add more WARN_PHP4_xxx codes...)
 */

char cvsroot_php4_cxx[] = "$Header$";

#include "swigmod.h"

#include <ctype.h>
#include <errno.h>

static const char *usage = (char*)"\
PHP Options (available with -php4 or -php5)\n\
     -cppext          - cpp file extension (default to .cpp)\n\
     -noproxy         - Don't generate proxy classes.\n\
     -prefix <prefix> - Prepend <prefix> to all class names in PHP5 wrappers\n\
     -make            - Create simple makefile\n\
     -phpfull         - Create full make files\n\
     -withincs <incs> - With -phpfull writes needed incs in config.m4\n\
     -withlibs <libs> - With -phpfull writes needed libs in config.m4\n\
     -withc <files>   - With -phpfull makes extra C files in Makefile.in\n\
     -withcxx <files> - With -phpfull makes extra C++ files in Makefile.in\n\
\n";

/* The original class wrappers for PHP4 store the pointer to the C++ class in
 * the object property _cPtr.  If we use the same name for the member variable
 * which we put the pointer to the C++ class in, then the flat function
 * wrappers will automatically pull it out without any changes being required.
 * FIXME: Isn't using a leading underscore a bit suspect here?
 */
#define SWIG_PTR "_cPtr"

static int constructors=0;
static String *NOTCLASS=NewString("Not a class");
static Node *classnode=0;
static String *module = 0;
static String *cap_module = 0;
static String *prefix = 0;
static String *withlibs = 0;
static String *withincs = 0;
static String *withc = 0;
static String *withcxx = 0;

static String *shadow_classname = 0;

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
static String     *s_oowrappers;
static String     *s_fakeoowrappers;
static String     *s_phpclasses;

/* Variables for using PHP classes */
static Node       *current_class = 0;

static Hash     *shadow_get_vars;
static Hash     *shadow_set_vars;
#define NATIVE_CONSTRUCTOR 1
#define ALTERNATIVE_CONSTRUCTOR 2
static int      native_constructor=0;
static Hash     *zend_types = 0;

static int      shadow = 1;

static bool     class_has_ctor = false;
static String * wrapping_member_constant = NULL;

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
  Iterator ki;

  if (!zend_types) return;

  ki = First(zend_types);
  if (ki.key) Printf(s_oinit,"\n/* Register resource destructors for pointer types */\n");
  while (ki.key) if (1 /* is pointer type*/) {
    DOH *key = ki.key;
    Node *class_node = ki.item;
    String *human_name = key;

    // Write out destructor function header
    Printf(s_wrappers,"/* NEW Destructor style */\nstatic ZEND_RSRC_DTOR_FUNC(_wrap_destroy%s) {\n",key);

    // write out body
    if ((class_node!=NOTCLASS)) {
      String *destructor = Getattr(class_node, "destructor");
      human_name = Getattr(class_node,"sym:name");
      if (!human_name) human_name = Getattr(class_node,"name");
      // Do we have a known destructor for this type?
      if (destructor) {
	Printf(s_wrappers,"  %s(rsrc, SWIGTYPE%s->name TSRMLS_CC);\n",destructor,key);
      } else {
	Printf(s_wrappers,"  /* No destructor for class %s */\n", human_name);
      }
    } else {
      Printf(s_wrappers,"  /* No destructor for simple type %s */\n", key);
    }

    // close function
    Printf(s_wrappers,"}\n");

    // declare le_swig_<mangled> to store php registration
    Printf(s_vdecl,"static int le_swig_%s=0; /* handle for %s */\n", key, human_name);

    // register with php
    Printf(s_oinit,"le_swig_%s=zend_register_list_destructors_ex"
	   "(_wrap_destroy%s,NULL,(char *)(SWIGTYPE%s->name),module_number);\n",
	   key,key,key);

    // store php type in class struct
    Printf(s_oinit,"SWIG_TypeClientData(SWIGTYPE%s,&le_swig_%s);\n",
	   key,key);

    ki = Next(ki);
  }
}

class PHP : public Language {
  int php_version;

public:
  PHP(int php_version_) : php_version(php_version_) { }

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
	  Printf(stderr,"*** -dlname is no longer supported\n*** if you want to change the module name, use -module instead.\n");
	  SWIG_exit(EXIT_FAILURE);
	} else if(strcmp(argv[i], "-prefix") == 0) {
	  if (argv[i+1]) {
	    prefix = NewString(argv[i+1]);
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
        } else if((strcmp(argv[i], "-noshadow") == 0) ||
                  (strcmp(argv[i], "-noproxy") == 0)) {
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
    if (php_version == 4) {
      Preprocessor_define((void *) "SWIGPHP4 1", 0);
    } else if (php_version == 5) {
      Preprocessor_define((void *) "SWIGPHP5 1", 0);
    }
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
    Printf(f_make, "MODULE=%s.`php -r 'switch(PHP_SHLIB_SUFFIX){case\"PHP_SHLIB_SUFFIX\":case\"dylib\":echo\"so\";break;default:echo PHP_SHLIB_SUFFIX;}'`\n", module);
    Printf(f_make, "CFLAGS=-fpic\n" );
    Printf(f_make, "LDFLAGS=-shared\n");
    Printf(f_make, "PHP_INC=`php-config --includes`\n");
    Printf(f_make, "EXTRA_INC=\n");
    Printf(f_make, "EXTRA_LIB=\n\n" );
    Printf(f_make, "$(MODULE): $(OBJS)\n");
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

    configm4 = NewStringEmpty();
    Printv(configm4, SWIG_output_directory(), "config.m4", NIL);

    makefilein = NewStringEmpty();
    Printv(makefilein, SWIG_output_directory(), "Makefile.in", NIL);

    credits = NewStringEmpty();
    Printv(credits, SWIG_output_directory(), "CREDITS", NIL);

    // are we a --with- or --enable-
    int with=(withincs || withlibs)?1:0;

    // Note Makefile.in only copes with one source file
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
	   "LTLIBRARY_NAME          = %s.la\n",
	   module);

    // C++ has more and different entries to C in Makefile.in
    if (! CPlusPlus) {
      Printf(f_extra,"LTLIBRARY_SOURCES       = %s %s\n", Swig_file_filename(outfile),withc);
      Printf(f_extra,"LTLIBRARY_SOURCES_CPP   = %s\n", withcxx);
    } else {
      Printf(f_extra,"LTLIBRARY_SOURCES       = %s\n", withc );
      Printf(f_extra,"LTLIBRARY_SOURCES_CPP   = %s %s\n", Swig_file_filename(outfile),withcxx);
      Printf(f_extra,"LTLIBRARY_OBJECTS_X = $(LTLIBRARY_SOURCES_CPP:.cpp=.lo) $(LTLIBRARY_SOURCES_CPP:.cxx=.lo)\n");
    }
    Printf(f_extra,"LTLIBRARY_SHARED_NAME   = %s.la\n", module);
    Printf(f_extra,"LTLIBRARY_SHARED_LIBADD = $(%s_SHARED_LIBADD)\n\n", cap_module);
    Printf(f_extra,"include $(top_srcdir)/build/dynlib.mk\n");

    Printf(f_extra,"\n# patch in .cxx support to php build system to work like .cpp\n");
    Printf(f_extra,".SUFFIXES: .cxx\n\n");

    Printf(f_extra,".cxx.o:\n");
    Printf(f_extra,"\t$(CXX_COMPILE) -c $<\n\n");

    Printf(f_extra,".cxx.lo:\n");
    Printf(f_extra,"\t$(CXX_PHP_COMPILE)\n\n");
    Printf(f_extra,".cxx.slo:\n");

    Printf(f_extra,"\t$(CXX_SHARED_COMPILE)\n\n");

    Printf(f_extra,"\n# make it easy to test module\n");
    Printf(f_extra,"testmodule:\n");
    Printf(f_extra,"\tphp -q -d extension_dir=modules %s\n\n",Swig_file_filename(phpfilename));

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
	Printf(f_extra,"LIBNAMES=\"\"; # lib%s.so ?\n\n",module);
      
      Printf(f_extra,"dnl IF YOU KNOW one of the symbols in the library and you\n");
      Printf(f_extra,"dnl specify it below then we can have a link test to see if it works\n");
      Printf(f_extra,"LIBSYMBOL=\"\"\n\n");
    }

    // Now write out tests to find thing.. they may need to extend tests
    Printf(f_extra,"if test \"$PHP_%s\" != \"no\"; then\n\n", cap_module);

    // Ready for when we add libraries as we find them
    Printf(f_extra,"  PHP_SUBST(%s_SHARED_LIBADD)\n\n", cap_module);

    if (withlibs) { // find more than one library
      Printf(f_extra,"  for LIBNAME in $LIBNAMES ; do\n");
      Printf(f_extra,"    LIBDIR=\"\"\n");
      // For each path element to try...
      Printf(f_extra,"    for i in $PHP_%s $PHP_%s/lib /usr/lib /usr/local/lib ; do\n", cap_module, cap_module);
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
      Printf(f_extra,"      PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $LIBDIR, %s_SHARED_LIBADD)\n", cap_module);
      Printf(f_extra,"    fi\n");
      Printf(f_extra,"  done\n\n");
    }
    
    if (withincs) {  // Find more than once include
      Printf(f_extra,"  for HNAME in $HNAMES ; do\n");
      Printf(f_extra,"    INCDIR=\"\"\n");
      // For each path element to try...
      Printf(f_extra,"    for i in $PHP_%s $PHP_%s/include $PHP_%s/includes $PHP_%s/inc $PHP_%s/incs /usr/local/include /usr/include; do\n", cap_module, cap_module, cap_module, cap_module, cap_module);
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

    Printf(f_extra,"  AC_DEFINE(HAVE_%s, 1, [ ])\n", cap_module);
    Printf(f_extra,"dnl  AC_DEFINE_UNQUOTED(PHP_%s_DIR, \"$%s_DIR\", [ ])\n", cap_module, cap_module);
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
    s_type = NewStringEmpty();
    /* subsections of the init section */
    s_vinit = NewString("/* vinit subsection */\n");
    s_vdecl = NewString("/* vdecl subsection */\n");
    s_cinit = NewString("/* cinit subsection */\n");
    s_oinit = NewString("/* oinit subsection */\n");
    pragma_phpinfo = NewStringEmpty();
    s_phpclasses = NewString("/* PHP Proxy Classes */\n");

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
    if (!prefix) prefix = NewStringEmpty();

    /* PHP module file */
    filen = NewStringEmpty();
    Printv(filen, SWIG_output_directory(), module, ".php", NIL);
    phpfilename = NewString(filen);

    f_phpcode = NewFile(filen, "w");
    if (!f_phpcode) {
      FileErrorDisplay(filen);
      SWIG_exit(EXIT_FAILURE);
    }

    Printf(f_phpcode, "<?php\n\n");

    Swig_banner(f_phpcode);

    Printf(f_phpcode,"// Try to load our extension if it's not already loaded.\n");
    Printf(f_phpcode,"if (!extension_loaded(\"%s\")) {\n", module);
    Printf(f_phpcode,"  if (strtolower(substr(PHP_OS, 0, 3)) === 'win') {\n");
    Printf(f_phpcode,"    if (!dl('php_%s.dll')) return;\n", module);
    Printf(f_phpcode,"  } else {\n");
    Printf(f_phpcode,"    // PHP_SHLIB_SUFFIX is available as of PHP 4.3.0, for older PHP assume 'so'.\n");
    Printf(f_phpcode,"    // It gives 'dylib' on MacOS X which is for libraries, modules are 'so'.\n");
    Printf(f_phpcode,"    if (PHP_SHLIB_SUFFIX === 'PHP_SHLIB_SUFFIX' || PHP_SHLIB_SUFFIX === 'dylib') {\n");
    Printf(f_phpcode,"      if (!dl('%s.so')) return;\n", module);
    Printf(f_phpcode,"    } else {\n");
    Printf(f_phpcode,"      if (!dl('%s.'.PHP_SHLIB_SUFFIX)) return;\n", module);
    Printf(f_phpcode,"    }\n");
    Printf(f_phpcode,"  }\n");
    Printf(f_phpcode,"}\n\n");

    /* sub-sections of the php file */
    pragma_code = NewStringEmpty();
    pragma_incl = NewStringEmpty();

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
    Printf(s_header, "#define SWIG_ErrorMsg() TSRMG(%s_globals_id, zend_%s_globals *, error_msg )\n",module,module);
    Printf(s_header, "#define SWIG_ErrorCode() TSRMG(%s_globals_id, zend_%s_globals *, error_code )\n",module,module);
    Printf(s_header, "#else\n" );
    Printf(s_header, "#define SWIG_ErrorMsg() (%s_globals.error_msg)\n",module);
    Printf(s_header, "#define SWIG_ErrorCode() (%s_globals.error_code)\n",module);
    Printf(s_header, "#endif\n\n" );

    Printf(s_header, "static void %s_init_globals(zend_%s_globals *globals ) {\n",module,module);
    Printf(s_header, "  globals->error_msg = default_error_msg;\n");
    Printf(s_header, "  globals->error_code = default_error_code;\n");
    Printf(s_header, "}\n");

    Printf(s_header, "static void %s_destroy_globals(zend_%s_globals * globals) { (void)globals; }\n",module,module);

    Printf(s_header, "\n");
    Printf(s_header, "static void SWIG_ResetError() {\n");
    Printf(s_header, "  TSRMLS_FETCH();\n");
    Printf(s_header, "  SWIG_ErrorMsg() = default_error_msg;\n");
    Printf(s_header, "  SWIG_ErrorCode() = default_error_code;\n");
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
    filen = NewStringEmpty();
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
    Printf(f_h, "#ifdef ZTS\n" );
    Printf(f_h, "#include \"TSRM.h\"\n" );
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
    Printf(s_entry,"static function_entry %s_functions[] = {\n", module);
    
    /* start the init section */
    Printv(s_init, "zend_module_entry ", module, "_module_entry = {\n"
		   "#if ZEND_MODULE_API_NO > 20010900\n"
		   "    STANDARD_MODULE_HEADER,\n"
		   "#endif\n", NIL);
    Printf(s_init, "    \"%s\",\n", module);
    Printf(s_init, "    %s_functions,\n", module);
    Printf(s_init, "    PHP_MINIT(%s),\n", module);
    Printf(s_init, "    PHP_MSHUTDOWN(%s),\n", module);
    Printf(s_init, "    PHP_RINIT(%s),\n", module);
    Printf(s_init, "    PHP_RSHUTDOWN(%s),\n", module);
    Printf(s_init, "    PHP_MINFO(%s),\n",module);
    Printf(s_init, "#if ZEND_MODULE_API_NO > 20010900\n");
    Printf(s_init, "    NO_VERSION_YET,\n");
    Printf(s_init, "#endif\n");
    Printf(s_init, "    STANDARD_MODULE_PROPERTIES\n");
    Printf(s_init, "};\n");
    Printf(s_init, "zend_module_entry* SWIG_module_entry = &%s_module_entry;\n\n",module);

    if (gen_extra) {
      Printf(s_init,"#ifdef COMPILE_DL_%s\n", cap_module);
    }
    Printf(s_init,"#ifdef __cplusplus\n");
    Printf(s_init,"extern \"C\" {\n");
    Printf(s_init,"#endif\n");
    // We want to write "SWIGEXPORT ZEND_GET_MODULE(%s)" but ZEND_GET_MODULE
    // in PHP5 has "extern "C" { ... }" around it so we can't do that.
    Printf(s_init,"SWIGEXPORT zend_module_entry *get_module(void) { return &%s_module_entry; }\n", module);
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
    Printf(s_cinit, "/* end cinit subsection */\n");
    Printf(s_init,"%s\n",s_cinit);
    Clear(s_cinit);
    Delete(s_cinit);

    Printf(s_init, "    return SUCCESS;\n");
    Printf(s_init,"}\n\n");

    // Now do REQUEST init which holds any user specified %rinit, and also vinit
    Printf(s_init,"PHP_RINIT_FUNCTION(%s)\n{\n",module);
    Printf(s_init,"%s\n",r_init);

    /* finish our init section which will have been used by class wrappers */
    Printf(s_vinit, "/* end vinit subsection */\n");
    Printf(s_init, "%s\n", s_vinit);
    Clear(s_vinit);
    Delete(s_vinit);

    Printf(s_init,"    return SUCCESS;\n");
    Printf(s_init,"}\n\n");

    Printf(s_init,"PHP_MSHUTDOWN_FUNCTION(%s)\n{\n",module);
    Printf(s_init,"%s\n",s_shutdown);
    Printf(s_init,"    return SUCCESS;\n");
    Printf(s_init,"}\n\n");

    Printf(s_init,"PHP_RSHUTDOWN_FUNCTION(%s)\n{\n",module);
    Printf(s_init,"%s\n",r_shutdown);
    Printf(s_init,"    return SUCCESS;\n");
    Printf(s_init,"}\n\n");

    Printf(s_init,"PHP_MINFO_FUNCTION(%s)\n{\n",module);
    Printf(s_init,"%s", pragma_phpinfo);
    Printf(s_init,"}\n");
    Printf(s_init,"/* end init section */\n");

    Printf(f_h, "#endif /* PHP_%s_H */\n",  cap_module);

    Close(f_h);

    String *type_table = NewStringEmpty();
    SwigType_emit_type_table(f_runtime,type_table);
    Printf(s_header,"%s",type_table);
    Delete(type_table);

    /* Oh dear, more things being called in the wrong order. This whole
     * function really needs totally redoing.
     */
    
    Printf(s_header, "/* end header section */\n");
    Printf(s_wrappers, "/* end wrapper section */\n");
    Printf(s_vdecl, "/* end vdecl subsection */\n");
    
    Printv(f_runtime, s_header, s_vdecl, s_wrappers, NIL);
    Printv(f_runtime, all_cs_entry, "\n\n",
		      s_entry,
		      "{NULL, NULL, NULL}\n};\n\n", NIL);
    Printv(f_runtime, s_init, NIL);
    Delete(s_header);
    Delete(s_wrappers);
    Delete(s_init);
    Delete(s_vdecl);
    Delete(all_cs_entry);
    Delete(s_entry);
    Close(f_runtime);

    Printf(f_phpcode, "%s\n%s\n", pragma_incl, pragma_code);
    if (s_fakeoowrappers) {
      Printf(f_phpcode, "abstract class %s {", Len(prefix) ? prefix : module);
      Printf(f_phpcode, "%s", s_fakeoowrappers);
      Printf(f_phpcode, "}\n\n");
      Delete(s_fakeoowrappers);
      s_fakeoowrappers = NULL;
    }
    Printf(f_phpcode, "%s\n?>\n", s_phpclasses);
    Close(f_phpcode);

    if ( gen_extra ) {
      create_extra_files(outfile);
    }
    else if( gen_make ) {
      create_simple_make();
    }
    
    return SWIG_OK;
  }

  /* Just need to append function names to function table to register with PHP. */
  void create_command(String *cname, String *iname) {
    // This is for the single main function_entry record
    if (shadow && php_version == 4) {
      if (wrapperType != standard) return;
    }
    Printf(f_h, "ZEND_NAMED_FUNCTION(%s);\n", iname);
    if (cs_entry) {
      Printf(cs_entry," ZEND_NAMED_FE(%(lower)s,%s,NULL)\n", cname, iname);
    } else {
      Printf(s_entry," ZEND_NAMED_FE(%(lower)s,%s,NULL)\n", cname, iname);
    }
  }

  /* ------------------------------------------------------------
   * dispatchFunction()
   * ------------------------------------------------------------ */
  void dispatchFunction(Node *n) {
    /* Last node in overloaded chain */

    int maxargs;
    String *tmp = NewStringEmpty();
    String *dispatch = Swig_overload_dispatch(n,"return %s(INTERNAL_FUNCTION_PARAM_PASSTHRU);",&maxargs);

    int has_this_ptr = (wrapperType==memberfn && shadow && php_version == 4);

    /* Generate a dispatch wrapper for all overloaded functions */
    
    Wrapper *f       = NewWrapper();
    String  *symname = Getattr(n,"sym:name");
    String  *wname   = Swig_name_wrapper(symname);
    
    create_command( symname, wname );
    Printv(f->def, "ZEND_NAMED_FUNCTION(", wname, ") {\n", NIL );
    
    Wrapper_add_local(f,"argc","int argc");

    Printf(tmp,"zval **argv[%d]", maxargs);
    Wrapper_add_local(f,"argv",tmp);

    Printf(f->code,"argc = ZEND_NUM_ARGS();\n");

    if ( has_this_ptr ) {
      Printf(f->code,"argv[0] = &this_ptr;\n");
      Printf(f->code,"zend_get_parameters_array_ex(argc,argv+1);\n");
      Printf(f->code,"argc++;\n");
    }
    else {
      Printf(f->code,"zend_get_parameters_array_ex(argc,argv);\n");
    }

    Replaceall(dispatch,"$args","self,args");

    Printv(f->code,dispatch,"\n",NIL);

    Printf(f->code,"SWIG_ErrorCode() = E_ERROR;\n");
    Printf(f->code,"SWIG_ErrorMsg() = \"No matching function for overloaded '%s'\";\n", symname);
    Printv(f->code,"zend_error(SWIG_ErrorCode(),SWIG_ErrorMsg());\n",NIL);

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

  /* Helper method for PHP::functionWrapper */
  bool is_class(SwigType *t) {
    Node *n = classLookup(t);
    if (n) {
      String *r = Getattr(n,"php:proxy");   // Set by classDeclaration()
      if (!r) r = Getattr(n,"sym:name");      // Not seen by classDeclaration yet, but this is the name
      if (r) return true;
    }
    return false;
  }

  virtual int functionWrapper(Node *n) {
    String   *name  = GetChar(n,"name");
    String   *iname = GetChar(n,"sym:name");
    SwigType *d     = Getattr(n,"type");
    ParmList *l     = Getattr(n,"parms");
    String *nodeType = Getattr(n, "nodeType");
    int newobject   = GetFlag(n,"feature:new");

    Parm *p;
    int i,numopt;
    String *tm;
    Wrapper *f;
    bool mvr=(shadow && php_version == 4 && wrapperType == membervar);
    bool mvrset=(mvr && (Strcmp(iname, Swig_name_set(Swig_name_member(shadow_classname, name)))==0) );

    String * wname;
    int overloaded = 0;
    String *overname = 0;

    if (Cmp(nodeType, "destructor") == 0) {
      // We just generate the Zend List Destructor and let Zend manage the
      // reference counting.  There's no explicit destructor, but the user can
      // just do `$obj = null;' to remove a reference to an object.
      return CreateZendListDestructor(n);
    }

    // Test for overloading;
    if (Getattr(n,"sym:overloaded")) {
      overloaded = 1;
      overname = Getattr(n,"sym:overname");
    } else {
      if (!addSymbol(iname,n))
        return SWIG_ERROR;
    }

    wname = Swig_name_wrapper(iname);
    if (overname) {
      Printf(wname, "%s", overname);
    }

    // if PHP4, shadow and variable wrapper we want to snag the main contents
    // of this function to stick in to the property handler...
    if (mvr) {
      String *php_function_name = NewString(iname);
      if (Strcmp(iname, Swig_name_set(Swig_name_member(shadow_classname, name)))== 0) {
        Setattr(shadow_set_vars, php_function_name, name);
      }
      if (Strcmp(iname, Swig_name_get(Swig_name_member(shadow_classname, name))) == 0) {
        Setattr(shadow_get_vars, php_function_name, name);
      }

      Delete(php_function_name);
    }

    f   = NewWrapper();
    numopt = 0;

    String *outarg = NewStringEmpty();
    String *cleanup = NewStringEmpty();

    if (mvr) { // do prop[gs]et header
      if (mvrset) {
        Printf(f->def, "static int _wrap_%s(zend_property_reference *property_reference, pval *value) {\n",iname);
      }
      else {
        Printf(f->def, "static pval _wrap_%s(zend_property_reference *property_reference) {\n",iname);
      }
    } else {
      // regular header
      // Not issued for overloaded functions or static member variables.
      if (!overloaded && wrapperType != staticmembervar ) {
        create_command(iname, wname);
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

    int has_this_ptr = (wrapperType==memberfn && shadow && php_version == 4);

    if (num_arguments-has_this_ptr > 0) {
      String * args = NewStringf("zval **args[%d]", num_arguments-has_this_ptr);
      Wrapper_add_local(f, "args",args);
      Delete(args); args = NULL;
    }

    // This generated code may be called:
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
    }

    if(numopt > 0) { // membervariable wrappers do not have optional args
      Wrapper_add_local(f, "arg_count", "int arg_count");
      Printf(f->code,"arg_count = ZEND_NUM_ARGS();\n");
      Printf(f->code,"if(arg_count<%d || arg_count>%d ||\n",num_required, num_arguments);
      Printf(f->code,"   zend_get_parameters_array_ex(arg_count,args)!=SUCCESS)\n");
      Printf(f->code,"\tWRONG_PARAM_COUNT;\n\n");
    } else if (!mvr) {
      int num = num_arguments - has_this_ptr;
      if (num == 0) {
	Printf(f->code, "if(ZEND_NUM_ARGS() != 0) {\n");
      } else {
	Printf(f->code, "if(ZEND_NUM_ARGS() != %d || zend_get_parameters_array_ex(%d, args) != SUCCESS) {\n",
	       num, num);
      }
      Printf(f->code, "WRONG_PARAM_COUNT;\n}\n\n");
    }

    /* Now convert from php to C variables */
    // At this point, argcount if used is the number of deliberately passed args
    // not including this_ptr even if it is used.
    // It means error messages may be out by argbase with error
    // reports.  We can either take argbase into account when raising
    // errors, or find a better way of dealing with _thisptr.
    // I would like, if objects are wrapped, to assume _thisptr is always
    // _this and not the first argument.
    // This may mean looking at Language::memberfunctionHandler

    for (i = 0, p = l; i < num_arguments; i++) {
      String * source;

      /* Skip ignored arguments */
      //while (Getattr(p,"tmap:ignore")) { p = Getattr(p,"tmap:ignore:next");}
      while (checkAttribute(p,"tmap:in:numinputs","0")) {
        p = Getattr(p,"tmap:in:next");
      }

      SwigType *pt = Getattr(p,"type");

      if (mvr) { // do we assert that numargs=2, that i<2
        if (i==0) {
          source = NewString("&(property_reference->object)");
        }
        else {
          source = NewString("&value");
        }
      } else {
        if (i==0 && has_this_ptr) {
          source = NewString("&this_ptr");
        } else {
          source = NewStringf("args[%d]", i-has_this_ptr);
        }
      }

      String *ln = Getattr(p,"lname");

      /* Check if optional */
      if(i >= num_required) {
        Printf(f->code,"\tif(arg_count > %d) {\n", i);
      }

      if ((tm = Getattr(p,"tmap:in"))) {
        Replaceall(tm,"$source", source);
        Replaceall(tm,"$target", ln);
        Replaceall(tm,"$input", source);
        Setattr(p,"emit:input", source);
        Printf(f->code,"%s\n",tm);
	if (i == 0 && HashGetAttr(p, k_self)) {
	  Printf(f->code,"\tif(!arg1) SWIG_PHP_Error(E_ERROR, \"this pointer is NULL\");\n");
	}
        p = Getattr(p,"tmap:in:next");
        if (i >= num_required) {
          Printf(f->code,"}\n");
        }
        continue;
      } else {
	Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number,
		     "Unable to use type %s as a function argument.\n",
		     SwigType_str(pt,0));
      }
      if (i>= num_required) {
        Printf(f->code,"\t}\n");
      }
      Delete(source);
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
      // I don't know if this test is complete, I nicked it
      if(is_shadow(d) && (SwigType_type(d) != T_ARRAY)) {
        Printf(f->code,"/* Wrap this return value */\n");
        if (native_constructor==NATIVE_CONSTRUCTOR) {
          Printf(f->code, "if (this_ptr) {\n");
          Printf(f->code, "/* NATIVE Constructor, use this_ptr */\n");
          Printf(f->code, "zval *_cPtr; MAKE_STD_ZVAL(_cPtr);\n");
          Printf(f->code, "*_cPtr = *return_value;\n");
          Printf(f->code, "INIT_ZVAL(*return_value);\n");
          Printf(f->code, "add_property_zval(this_ptr,\""SWIG_PTR"\",_cPtr);\n");
          Printf(f->code, "} else if (! this_ptr) ");
        }
        { // THIS CODE only really needs writing out if the object to be returned
          // Is being shadow-wrap-thingied
          Printf(f->code, "{\n/* ALTERNATIVE Constructor, make an object wrapper */\n");
          // Make object
          String *shadowrettype = NewStringEmpty();
          SwigToPhpType(d, iname, shadowrettype, (shadow && php_version == 4));

          Printf(f->code,"zval *obj, *_cPtr;\n");
          Printf(f->code,"MAKE_STD_ZVAL(obj);\n");
          Printf(f->code,"MAKE_STD_ZVAL(_cPtr);\n");
          Printf(f->code,"*_cPtr = *return_value;\n");
          Printf(f->code,"INIT_ZVAL(*return_value);\n");

          if (shadow && php_version == 4) {
            Printf(f->code,"object_init_ex(obj,ptr_ce_swig_%s);\n",shadowrettype);
            Printf(f->code,"add_property_zval(obj,\""SWIG_PTR"\",_cPtr);\n");
            Printf(f->code,"*return_value=*obj;\n");
          } else {
            Printf(f->code,"*return_value=*_cPtr;\n");
          }
          Printf(f->code, "}\n");
        }
      } // end of if-shadow lark
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
		   "Unable to use return type %s in function %s.\n",
		   SwigType_str(d,0), name);
    }
    
    if(outarg) {
      Printv(f->code,outarg,NIL);
    }
    
    if(cleanup) {
      Printv(f->code,cleanup,NIL);
    }

    // What's this bit for?
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
    Printv(f->code,"zend_error(SWIG_ErrorCode(),SWIG_ErrorMsg());",NIL);

    Printf(f->code, "}\n");

    Replaceall(f->code,"$cleanup",cleanup);
    Replaceall(f->code,"$symname",iname);

    Wrapper_print(f,s_wrappers);

    // wrap:name is used by overload resolution
    Setattr(n,"wrap:name",wname);
    if (overloaded && !Getattr(n,"sym:nextSibling")) {
      dispatchFunction(n);
    }

    Delete(wname); wname = NULL;

    if (!(shadow && php_version == 5)) return SWIG_OK;

    // Handle getters and setters.
    if (wrapperType == membervar) {
      const char * p = Char(iname);
      if (strlen(p) > 4) {
	p += strlen(p) - 4;
	String * varname = Getattr(n, "membervariableHandler:sym:name");
	if (strcmp(p, "_get") == 0) {
	  Setattr(shadow_get_vars, varname, iname);
	} else if (strcmp(p, "_set") == 0) {
	  Setattr(shadow_set_vars, varname, iname);
	}
      }
    }

    // Only look at non-overloaded methods and the last entry in each overload
    // chain (we check the last so that wrap:parms and wrap:name have been set
    // for them all).
    if (overloaded && Getattr(n,"sym:nextSibling") != 0) return SWIG_OK;

    if (!s_oowrappers) s_oowrappers = NewStringEmpty();
    if (newobject || wrapperType == memberfn || wrapperType == staticmemberfn || wrapperType == standard) {
      bool handle_as_overload = false;
      String ** arg_names;
      String ** arg_values;
      bool * arg_case = NULL;
      // Method or static method or plain function.
      const char * methodname = 0;
      String * output = s_oowrappers;
      if (newobject) {
	class_has_ctor = true;
	methodname = "__construct";
      } else if (wrapperType == memberfn) {
	methodname = Char(Getattr(n, "memberfunctionHandler:sym:name"));
      } else if (wrapperType == staticmemberfn) {
	methodname = Char(Getattr(n, "staticmemberfunctionHandler:sym:name"));
      } else { // wrapperType == standard
	methodname = Char(iname);
	if (!s_fakeoowrappers) s_fakeoowrappers = NewStringEmpty();
	output = s_fakeoowrappers;
      }

      bool really_overloaded = overloaded ? true : false;
      int min_num_of_arguments = emit_num_required(l);
      int max_num_of_arguments = emit_num_arguments(l);
      // For a function with default arguments, we end up with the fullest
      // parmlist in full_parmlist.
      ParmList * full_parmlist = l;
      Hash * ret_types = NewHash();
      Setattr(ret_types, d, d);

      if (overloaded) {
	// Look at all the overloaded versions of this method in turn to
	// decide if it's really an overloaded method, or just one where some
	// parameters have default values.
	Node * o = Getattr(n, "sym:overloaded");
	while (o) {
	  if (o == n) {
	    o = Getattr(o,"sym:nextSibling");
	    continue;
	  }

	  SwigType *d2 = Getattr(o, "type");
	  if (!d2) {
	    assert(constructor);
	  } else if (!Getattr(ret_types, d2)) {
	    Setattr(ret_types, d2, d2);
	  }

	  ParmList *l2 = Getattr(o,"wrap:parms");
	  int num_arguments = emit_num_arguments(l2);
	  int num_required  = emit_num_required(l2);
	  if (num_required < min_num_of_arguments)
	    min_num_of_arguments = num_required;

	  if (num_arguments > max_num_of_arguments) {
	    max_num_of_arguments = num_arguments;
	    full_parmlist = l2;
	  }
	  o = Getattr(o,"sym:nextSibling");
	}

	o = Getattr(n, "sym:overloaded");
	while (o) {
	  if (o == n) {
	    o = Getattr(o,"sym:nextSibling");
	    continue;
	  }

	  ParmList *l2 = Getattr(o,"wrap:parms");
	  Parm * p = l, * p2 = l2;
	  if (wrapperType == memberfn) {
	    p = nextSibling(p);
	    p2 = nextSibling(p2);
	  }
	  while (p && p2) {
	    if (Cmp(Getattr(p, "type"), Getattr(p2, "type")) != 0) break;
	    if (Cmp(Getattr(p, "name"), Getattr(p2, "name")) != 0) break;
	    String *value = Getattr(p, "value");
	    String *value2 = Getattr(p2, "value");
	    if (value && !value2) break;
	    if (!value && value2) break;
	    if (value) {
	      if (Cmp(value, value2) != 0) break;
	    }
	    p = nextSibling(p);
	    p2 = nextSibling(p2);
	  }
	  if (p && p2) break;
	  // One parameter list is a prefix of the other, so check that all
	  // remaining parameters of the longer list are optional.
	  if (p2) p = p2;
	  while (p && Getattr(p, "value")) p = nextSibling(p);
	  if (p) break;
	  o = Getattr(o,"sym:nextSibling");
	}
	if (!o) {
	  // This "overloaded method" is really just one with default args.
	  really_overloaded = false;
	  if (l != full_parmlist) {
	    l = full_parmlist;
	    if (wrapperType == memberfn) l = nextSibling(l);
	  }
	}

	arg_case = (bool*)malloc(max_num_of_arguments * sizeof(bool));
	if (!arg_case) {
	  /* FIXME: How should this be handled?  The rest of SWIG just seems
	   * to not bother checking for malloc failing! */
	  fprintf(stderr, "Malloc failed!\n");
	  exit(1);
	}
	for (int i = 0; i < max_num_of_arguments; ++i) {
	  arg_case[i] = false;
	}

	o = Getattr(n, "sym:overloaded");
	while (o) {
	  ParmList *l2 = Getattr(o,"wrap:parms");
	  int num_arguments = emit_num_arguments(l2);
	  int num_required  = emit_num_required(l2);
	  if (wrapperType == memberfn) {
	    --num_arguments;
	    --num_required;
	  }
	  for (int i = num_required; i <= num_arguments; ++i) {
	    arg_case[i] = true;
	  }
	  o = Getattr(o,"sym:nextSibling");
	}
      }

      if (wrapperType == memberfn) {
	// Allow for the "this" pointer.
	--min_num_of_arguments;
	--max_num_of_arguments;
      }

      arg_names = (String**)malloc(max_num_of_arguments * sizeof(String *));
      if (!arg_names) {
	/* FIXME: How should this be handled?  The rest of SWIG just seems
	 * to not bother checking for malloc failing! */
	fprintf(stderr, "Malloc failed!\n");
	exit(1);
      }
      for (int i = 0; i < max_num_of_arguments; ++i) {
	arg_names[i] = NULL;
      }

      arg_values = (String**)malloc(max_num_of_arguments * sizeof(String *));
      if (!arg_values) {
	/* FIXME: How should this be handled?  The rest of SWIG just seems
	 * to not bother checking for malloc failing! */
	fprintf(stderr, "Malloc failed!\n");
	exit(1);
      }
      for (int i = 0; i < max_num_of_arguments; ++i) {
	arg_values[i] = NULL;
      }

      Node * o;
      if (overloaded) {
	o = Getattr(n, "sym:overloaded");
      } else {
	o = n;
      }
      while (o) {
	int argno = 0;
	Parm *p = Getattr(o, "wrap:parms");
	if (wrapperType == memberfn) p = nextSibling(p);
	while (p) {
	  assert(0 <= argno && argno < max_num_of_arguments);
	  String * & pname = arg_names[argno];
	  const char *pname_cstr = GetChar(p, "name");
	  if (!pname_cstr) {
	    // Unnamed parameter, e.g. int foo(int);
	  } else if (pname == NULL) {
	    pname = NewString(pname_cstr);
	  } else {
	    size_t len = strlen(pname_cstr);
	    size_t spc = 0;
	    size_t len_pname = strlen(Char(pname));
	    while (spc + len <= len_pname) {
	      if (strncmp(pname_cstr, Char(pname) + spc, len) == 0) {
		char ch = ((char*)Char(pname))[spc + len];
		if (ch == '\0' || ch == ' ') {
		  // Already have this pname_cstr.
		  pname_cstr = NULL;
		  break;
		}
	      }
	      char * p = strchr(Char(pname) + spc, ' ');
	      if (!p) break;
	      spc = (p + 4) - Char(pname);
	    }
	    if (pname_cstr) {
	      Printf(pname, " or_%s", pname_cstr);
	    }
	  }
	  const char *value = GetChar(p,"value");
	  if (value) {
	    /* Check that value is a valid constant in PHP (and adjust it if
	     * necessary, or replace it with "?" if it's just not valid). */
	    SwigType *type = Getattr(p,"type");
	    switch (SwigType_type(type)) {
	      case T_BOOL: {
		if (strcmp(value, "true") == 0 || strcmp(value, "false") == 0)
		  break;
		char *p;
		errno = 0;
		int n = strtol(Char(value), &p, 0);
		if (errno || *p)
		  value = "?";
		else if (n)
		  value = "true";
		else
		  value = "false";
		break;
	      }
	      case T_CHAR:
	      case T_SCHAR:
	      case T_SHORT:
	      case T_INT:
	      case T_LONG: {
		char *p;
		errno = 0;
		(void)strtol(Char(value), &p, 0);
		if (errno || *p) value = "?";
		break;
	      }
	      case T_UCHAR:
	      case T_USHORT:
	      case T_UINT:
	      case T_ULONG: {
		char *p;
		errno = 0;
		(void)strtoul(Char(value), &p, 0);
		if (errno || *p) value = "?";
		break;
	      }
	      case T_FLOAT:
	      case T_DOUBLE: {
		char *p;
		errno = 0;
		/* FIXME: strtod is locale dependent... */
		(void)strtod(Char(value), &p);
		if (errno || *p) value = "?";
		break;
	      }
	      case T_REFERENCE:
	      case T_USER:
	      case T_ARRAY:
		value = "?";
		break;
	      case T_STRING:
		if (Len(value) < 2) {
		  // How can a string (including "" be less than 2 characters?)
		  value = "?";
		} else {
		  const char *v = Char(value);
		  if (v[0] != '"' || v[Len(value) - 1] != '"') value = "?";
		  // Strings containing "$" require special handling, but we do that later.
		}
		break;
	      case T_VOID:
		assert(false);
		break;
	      case T_POINTER: {
		const char * v = value;
		if (v[0] == '(') {
		  // Handle "(void*)0", "(TYPE*)0", "(char*)NULL", etc.
		  v += strcspn(v + 1, "*()") + 1;
		  if (*v == '*') {
		    do {
		      v++;
		      v += strspn(v, " \t");
		    } while (*v == '*');
		    if (*v++ == ')') {
		      v += strspn(v, " \t");
		      value = v;
		    }
		  }
		}
		if (strcmp(value, "NULL") == 0 ||
		    strcmp(value, "0") == 0 ||
		    strcmp(value, "0L") == 0) {
		  value = "null";
		} else {
		  value = "?";
		}
		break;
	      }
	    }

	    if (!arg_values[argno]) {
	      arg_values[argno] = NewString(value);
	    } else if (Cmp(arg_values[argno], value) != 0) {
	      // If a parameter has two different default values in
	      // different overloaded forms of the function, we can't
	      // set its default in PHP.  Flag this by setting its
	      // default to `?'.
	      Delete(arg_values[argno]);
	      arg_values[argno] = NewString("?");
	    }
	  }
	  p = nextSibling(p);
	  ++argno;
	}
	if (!really_overloaded) break;
	o = Getattr(o,"sym:nextSibling");
      }

      /* Clean up any parameters which haven't yet got names, or whose
       * names clash. */
      Hash * seen = NewHash();
      /* We need $this to refer to the current class, so can't allow it
       * to be used as a parameter. */
      Setattr(seen, "this", seen);
      /* We use $r to store the return value, so disallow that as a parameter
       * name in case the user uses the "call-time pass-by-reference" feature
       * (it's deprecated and off by default in PHP5 and even later PHP4
       * versions apparently, but we want to be maximally portable).
       */
      Setattr(seen, "r", seen);

      for (int argno = 0; argno < max_num_of_arguments; ++argno) {
	String * & pname = arg_names[argno];
	if (pname) {
	  Replaceall(pname, " ", "_");
	} else {
	  /* We get here if the SWIG .i file has "int foo(int);" */
	  pname = NewStringEmpty();
	  Printf(pname, "arg%d", argno + 1);
	}
	// Check if we've already used this parameter name.
	while (Getattr(seen, pname)) {
	  // Append "_" to clashing names until they stop clashing...
	  Printf(pname, "_");
	}
	Setattr(seen, Char(pname), seen);

	if (arg_values[argno] && Cmp(arg_values[argno], "?") == 0) {
	  handle_as_overload = true;
	}
      }
      Delete(seen);
      seen = NULL;

      String * invoke = NewStringEmpty();
      String * prepare = NewStringEmpty();
      String * args = NewStringEmpty();

      if (!handle_as_overload && !(really_overloaded && max_num_of_arguments > min_num_of_arguments)) {
	Printf(invoke, "%s(", iname);
	if (wrapperType == memberfn) {
	  Printf(invoke, "$this->%s", SWIG_PTR);
	}
	for (int i = 0; i < max_num_of_arguments; ++i) {
	  if (i) Printf(args, ",");
	  if (i || wrapperType == memberfn) Printf(invoke, ",");
	  String *value = arg_values[i];
	  if (value) {
	    const char *v = Char(value);
	    if (v[0] == '"') {
	      /* In a PHP double quoted string, $ needs to be escaped as \$. */
	      Replaceall(value, "$", "\\$");
	    }
	    Printf(args, "$%s=%s", arg_names[i], value);
	  } else {
	    Printf(args, "$%s", arg_names[i]);
	  }
	  Printf(invoke, "$%s", arg_names[i]);
	}
	Printf(invoke, ")");
      } else {
	int i;
	for (i = 0; i < min_num_of_arguments; ++i) {
	  if (i) Printf(args, ",");
	  Printf(args, "$%s", arg_names[i]);
	}
	String *invoke_args = NewStringEmpty();
	if (wrapperType == memberfn) {
	  Printf(invoke_args, "$this->%s", SWIG_PTR);
	  if (min_num_of_arguments > 0) Printf(invoke_args, ",");
	}
	Printf(invoke_args, "%s", args);
	bool had_a_case = false;
	int last_handled_i = i - 1;
	for ( ; i < max_num_of_arguments; ++i) {
	  if (i) Printf(args, ",");
	  const char *value = Char(arg_values[i]);
	  bool non_php_default = (!value || strcmp(value, "?") == 0);
	  if (non_php_default) value = "null";
	  Printf(args, "$%s=%s", arg_names[i], value);
	  if (non_php_default) {
	    if (!had_a_case) {
	      Printf(prepare, "\t\tswitch (func_num_args()) {\n");
	      had_a_case = true;
	    }
	    Printf(prepare, "\t\t");
	    while (last_handled_i < i) {
	      Printf(prepare, "case %d: ", ++last_handled_i);
	    }
	    if (Cmp(d, "void") != 0) Printf(prepare, "$r=");
	    Printf(prepare, "%s(%s); break;\n", iname, invoke_args);
	  }
	  if (i || wrapperType == memberfn) Printf(invoke_args, ",");
	  Printf(invoke_args, "$%s", arg_names[i]);
	}
	Printf(prepare, "\t\t");
	if (had_a_case) Printf(prepare, "default: ");
	if (Cmp(d, "void") != 0) Printf(prepare, "$r=");
	Printf(prepare, "%s(%s);\n", iname, invoke_args);
	if (had_a_case) Printf(prepare, "\t\t}\n");
	Delete(invoke_args);
	Printf(invoke, "$r");
      }

      Printf(output, "\n");
      if (wrapperType == memberfn || newobject) {
	Printf(output, "\tfunction %s(%s) {\n", methodname, args);
	// We don't need this code if the wrapped class has a copy ctor
	// since the flat function new_CLASSNAME will handle it for us.
	if (newobject && !Getattr(current_class, "allocate:copy_constructor")) {
	  SwigType *t = Getattr(current_class, "classtype");
	  String *mangled_type = SwigType_manglestr(SwigType_ltype(t));
	  Printf(s_oowrappers, "\t\tif (is_resource($%s) && get_resource_type($%s) == \"_p%s\") {\n", arg_names[0], arg_names[0], mangled_type);
	  Printf(s_oowrappers, "\t\t\t$this->%s=$%s;\n", SWIG_PTR, arg_names[0]);
	  Printf(s_oowrappers, "\t\t\treturn;\n");
	  Printf(s_oowrappers, "\t\t}\n");
	}
      } else {
	Printf(output, "\tstatic function %s(%s) {\n", methodname, args);
      }
      Delete(args);
      args = NULL;

      for (int i = 0; i < max_num_of_arguments; ++i) {
	Delete(arg_names[i]);
      }
      free(arg_names);
      arg_names = NULL;

      Printf(output, "%s", prepare);
      if (newobject) {
	Printf(output, "\t\t$this->%s=%s;\n", SWIG_PTR, invoke);
      } else if (Cmp(d, "void") == 0) {
	if (Cmp(invoke, "$r") != 0)
	  Printf(output, "\t\t%s;\n", invoke);
      } else if (is_class(d)) {
	if (Cmp(invoke, "$r") != 0)
	  Printf(output, "\t\t$r=%s;\n", invoke);
	if (Len(ret_types) == 1) {
	  Printf(output, "\t\treturn is_resource($r) ? new %s%s($r) : $r;\n", prefix, Getattr(classLookup(d), "sym:name"));
	} else {
	  Printf(output, "\t\tif (!is_resource($r)) return $r;\n");
	  Printf(output, "\t\tswitch (get_resource_type($r)) {\n");
	  Iterator i = First(ret_types);
	  while (i.item) {
	    SwigType * ret_type = i.item;
	    i = Next(i);
	    Printf(output, "\t\t");
	    String *mangled = NewString("_p");
	    Printf(mangled, "%s", SwigType_manglestr(ret_type));
	    Node *class_node = Getattr(zend_types, mangled);
	    if (i.item) {
	      Printf(output, "case \"%s\": ", mangled);
	    } else {
	      Printf(output, "default: ", mangled);
	    }
	    const char * classname = GetChar(class_node, "sym:name");
	    if (!classname) classname = GetChar(class_node, "name");
	    Printf(output, "return new %s%s($r);\n", prefix, classname);
	    Delete(mangled);
	  }
	  Printf(output, "\t\t}\n");
	}
      } else {
	Printf(output, "\t\treturn %s;\n", invoke);
      }
      Printf(output, "\t}\n");
      Delete(prepare);
      Delete(invoke);
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

    if (shadow && php_version == 5) {
      if (wrapping_member_constant) {
	if (!s_oowrappers) s_oowrappers = NewStringEmpty();
	Printf(s_oowrappers, "\n\tconst %s = %s;\n", wrapping_member_constant, iname);
      } else {
	if (!s_fakeoowrappers) s_fakeoowrappers = NewStringEmpty();
	Printf(s_fakeoowrappers, "\n\tconst %s = %s;\n", name, iname);
      }
    }

    return SWIG_OK;
  }

  /*
   * PHP::pragma()
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
          Swig_warning(WARN_PHP4_UNKNOWN_PRAGMA, input_file, line_number,
		       "Unrecognized pragma <%s>.\n", type);
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
    current_class = n;
    // String *use_class_name=SwigType_manglestr(SwigType_ltype(t));

    if (shadow && php_version == 4) {
      char *rename = GetChar(n, "sym:name");

      if (!addSymbol(rename,n)) return SWIG_ERROR;
      shadow_classname = NewStringf("%s", rename);
      cs_entry = NewStringEmpty();
      Printf(cs_entry, "/* Function entries for %s */\n", shadow_classname);
      Printf(cs_entry, "static zend_function_entry %s_functions[] = {\n", shadow_classname);

      if (Strcmp(shadow_classname, module) == 0) {
	Printf(stderr, "class name cannot be equal to module name: %s\n", module);
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
    } else if (shadow && php_version == 5) {
      char *rename = GetChar(n, "sym:name");

      if (!addSymbol(rename,n)) return SWIG_ERROR;
      shadow_classname = Swig_copy_string(rename);

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
    }

    classnode=n;
    Language::classHandler(n);
    classnode=0;

    if (shadow && php_version == 4) {
      DOH *key;
      String      *s_propget = NewStringEmpty();
      String      *s_propset = NewStringEmpty();
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

      while (ki.key) {
        key = ki.key;
        Printf(s_propset,"  if (strcmp(propname,\"%s\")==0) return _wrap_%s(property_reference, value);\n", ki.item, key);

        ki=Next(ki);
      }

      // If the property wasn't in this class, try the handlers of each base
      // class (if any) in turn until we succeed in setting the property or
      // have tried all base classes.
      if (base.item) {
        Printf(s_propset,  "  /* Try base class(es) */\n");
        while (base.item) {
          Printf(s_propset,"  if (_propset_%s(property_reference, value)==SUCCESS) return SUCCESS;\n",
                 GetChar(base.item, "sym:name"));

          base=Next(base);
          while (base.item && GetFlag(base.item,"feature:ignore")) {
            base=Next(base);
          }
        }
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

      while (ki.key) {
        key = ki.key;
        Printf(s_propget,"  if (strcmp(propname,\"%s\")==0) {\n", ki.item);
        Printf(s_propget,"    *value=_wrap_%s(property_reference);\n",key);
        Printf(s_propget,"    return SUCCESS;\n");
        Printf(s_propget,"  }\n");

        ki=Next(ki);
      }

      // If the property wasn't in this class, try the handlers of each base
      // class (if any) in turn until we succeed in setting the property or
      // have tried all base classes.
      if (base.item) {
        Printf(s_propget,  "  /* Try base class(es). */\n");
        while (base.item) {
          Printf(s_propget,"  if (_propget_%s(property_reference, value)==SUCCESS) return SUCCESS;\n",
                 GetChar(base.item, "sym:name"));

          base=Next(base);
          while (base.item && GetFlag(base.item,"feature:ignore")) {
            base=Next(base);
          }
        }
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
      // These are all the enums defined within the C++ class.

      Delete(shadow_classname);
      shadow_classname = NULL;

      Delete(shadow_set_vars); shadow_set_vars = NULL;
      Delete(shadow_get_vars); shadow_get_vars = NULL;

      Printv(all_cs_entry, cs_entry, " { NULL, NULL, NULL}\n};\n", NIL);
      Delete(cs_entry);
      cs_entry = NULL;
    } else if (shadow && php_version == 5) {
      DOH *key;
      List *baselist = Getattr(n, "bases");
      Iterator ki, base;

      if (baselist) {
        base = First(baselist);
	while (base.item && GetFlag(base.item,"feature:ignore")) {
	  base = Next(base);
	}
      } else {
        base.item = NULL;
      }

      if (Getattr(n, "abstract")) {
	Printf(s_phpclasses, "abstract ");
      }

      Printf(s_phpclasses, "class %s%s ", prefix, shadow_classname);
      if (base.item) {
	String *baseclass = Getattr(base.item, "sym:name");
	if (!baseclass) baseclass = Getattr(base.item, "name");
	Printf(s_phpclasses, "extends %s%s ", prefix, baseclass);
      }
      Printf(s_phpclasses, "{\n\tpublic $%s=null;\n", SWIG_PTR);

      // Write property SET handlers
      ki = First(shadow_set_vars);

      if (ki.key) {
	// This class has setters.
	// FIXME: just ignore setting an unknown property name for now.
	Printf(s_phpclasses, "\n\tfunction __set($var,$value) {\n");
	// FIXME: tune this threshold...
	if (Len(shadow_set_vars) <= 2) {
	  // Not many setters, so avoid call_user_func.
	  while (ki.key) {
	    key = ki.key;
	    Printf(s_phpclasses, "\t\tif ($var == '%s') return %s($this->%s,$value);\n",
		   key, ki.item, SWIG_PTR);
	    ki = Next(ki);
	  }
	} else {
	  Printf(s_phpclasses, "\t\t$func = '%s_'.$var.'_set';\n",
		 shadow_classname);
	  Printf(s_phpclasses, "\t\tif (function_exists($func) call_user_func($func,$this->%s,$value);\n",
		 SWIG_PTR);
	}
	Printf(s_phpclasses, "\t}\n");
	/* FIXME: also create __isset for PHP 5.1 and later? */
      }

      // Write property GET handlers
      ki = First(shadow_get_vars);

      if (ki.key) {
	// This class has getters.
	Printf(s_phpclasses, "\n\tfunction __get($var) {\n");
	// FIXME: tune this threshold...
	if (Len(shadow_get_vars) <= 2) {
	  // Not many getters, so avoid call_user_func.
	  while (ki.key) {
	    key = ki.key;
	    Printf(s_phpclasses, "\t\tif ($var == '%s') return %s($this->%s);\n",
		   key, ki.item, SWIG_PTR);
	    ki = Next(ki);
	  }
	} else {
	  Printf(s_phpclasses, "\t\t$func = '%s_'.$var.'_get';\n",
		 shadow_classname);
	  Printf(s_phpclasses, "\t\tif (function_exists($func) return call_user_func($func,$this->%s);\n",
		 SWIG_PTR);
	}
	// Reading an unknown property name gives null in PHP.
	Printf(s_phpclasses, "\t\treturn null;\n");
	Printf(s_phpclasses, "\t}\n");
      }

      if (!class_has_ctor) {
	Printf(s_phpclasses, "\tfunction __construct($h) {\n");
	Printf(s_phpclasses, "\t\t$this->%s=$h;\n", SWIG_PTR);
	Printf(s_phpclasses, "\t}\n");
      }

      if (s_oowrappers) {
	Printf(s_phpclasses, "%s", s_oowrappers);
	Delete(s_oowrappers);
	s_oowrappers = NULL;
      }
      class_has_ctor = false;

      Printf(s_phpclasses, "}\n\n");

      Delete(shadow_classname);
      shadow_classname = NULL;

      Delete(shadow_set_vars); shadow_set_vars = NULL;
      Delete(shadow_get_vars); shadow_get_vars = NULL;
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
    
    // Only declare the member function if
    // we are doing shadow classes, and the function
    // is not overloaded, or if it is overloaded, it is the dispatch function.
    if (shadow && php_version == 4 &&
	(!Getattr(n,"sym:overloaded") || !Getattr(n,"sym:nextSibling"))) {
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

    // This duplicates the logic from Language::variableWrapper() to test if the set wrapper
    // is made.
    int assignable = is_assignable(n);
    if (assignable) {
      String *tm = Swig_typemap_lookup_new("globalin",n,name,0);
      if (!tm && SwigType_isarray(type)) {
        assignable = 0;
      }
    }

    String *class_iname = Swig_name_member(Getattr(current_class, "sym:name"), iname);
    create_command( iname, Swig_name_wrapper(class_iname) );

    Wrapper *f = NewWrapper();

    Printv(f->def, "ZEND_NAMED_FUNCTION(",Swig_name_wrapper(class_iname), ") {\n", NIL );
    String *mget = Swig_name_wrapper(Swig_name_get(class_iname));
    String *mset = Swig_name_wrapper(Swig_name_set(class_iname));

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

    Delete(class_iname);
    Delete(mget);
    Delete(mset);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int staticmemberfunctionHandler(Node *n) {
    char *name = GetChar(n, "name");
    char *iname = GetChar(n, "sym:name");
    
    wrapperType = staticmemberfn;
    Language::staticmemberfunctionHandler(n);
    wrapperType = standard;

    if (shadow && php_version == 4) {
      String *symname = Getattr(n, "sym:name");
      char *realname = iname ? iname : name;
      String *php_function_name = Swig_name_member(shadow_classname, realname);
      create_command(symname, Swig_name_wrapper(php_function_name) );
    }
    
    return SWIG_OK;
  }

  
  void SwigToPhpType(SwigType *t, String_or_char *pname, String* php_type, int shadow_flag) {
    String *ptype = 0;

    if(shadow_flag) {
      ptype = PhpTypeFromTypemap((char*)"pstype", t, pname, (char*)"");
    }
    if(!ptype) {
      ptype = PhpTypeFromTypemap((char*)"ptype", t, pname, (char*)"");
    }

    if(ptype) {
      Printf(php_type, "%s", ptype);
      Delete(ptype);
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


  String *PhpTypeFromTypemap(char *op, SwigType *t, String_or_char *pname, String_or_char *lname) {
    String *tms;
    tms = Swig_typemap_lookup(op, t, pname, lname, (char*)"", (char*)"", NULL);
    if(!tms) {
      return NULL;
    }

    char * start = Char(tms);
    while(isspace(*start) || *start == '{') {
      start++;
    }
    char * end = start;
    while(*end && *end != '}') {
      end++;
    }
    return NewStringWithSize(start, end - start);
  }

  int abstractConstructorHandler(Node *n) {
    String *iname = GetChar(n, "sym:name");
    if (shadow && php_version == 4) {
      Wrapper *f = NewWrapper();

      String *wname = NewStringf( "_wrap_new_%s", iname );
      create_command( iname, wname );

      Printf(f->def, "ZEND_NAMED_FUNCTION(_wrap_new_%s) {\n", iname);
      Printf(f->def, "  zend_error(E_ERROR,\"Cannot create swig object type: %s as the underlying class is abstract\");\n",
             iname);
      Printf(f->def, "}\n\n");
      Wrapper_print(f,s_wrappers);
      DelWrapper(f);
      Delete(wname);
    }
    return SWIG_OK;
  }
  /* ------------------------------------------------------------
   * constructorHandler()
   * ------------------------------------------------------------ */

  virtual int constructorHandler(Node *n) {
    char *name = GetChar(n, "name");
    char *iname = GetChar(n, "sym:name");

    if (shadow && php_version == 4) {
      if (strcmp(iname, Char(shadow_classname)) == 0) {
	native_constructor = NATIVE_CONSTRUCTOR;
      } else {
	native_constructor = ALTERNATIVE_CONSTRUCTOR;
      }
    }
    else {
      native_constructor=0;
    }
    constructors++;
    wrapperType = constructor;
    Language::constructorHandler(n);
    wrapperType = standard;

    if (shadow && php_version == 4) {
      if(!Getattr(n,"sym:overloaded") || !Getattr(n,"sym:nextSibling")) {
        char *realname = iname ? iname : name;
        String *php_function_name = Swig_name_construct(realname);
        create_command(realname,Swig_name_wrapper(php_function_name));
      }
    }

    native_constructor = 0;
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * CreateZendListDestructor()
   * ------------------------------------------------------------ */
  //virtual int destructorHandler(Node *n) {
  //}
  int CreateZendListDestructor(Node *n) {
    String *name    = GetChar(Swig_methodclass(n),"name");
    String *iname   = GetChar(n,"sym:name");
    SwigType *d     = Getattr(n,"type");
    ParmList *l     = Getattr(n,"parms");

    String *destructorname = NewStringEmpty();
    Printf(destructorname,"_%s",Swig_name_wrapper(iname));
    Setattr(classnode,"destructor",destructorname);

    Wrapper *df = NewWrapper();
    Printf(df->def,"/* This function is designed to be called by the zend list destructors */\n");
    Printf(df->def,"/* to typecast and do the actual destruction */\n");
    Printf(df->def,"static void %s(zend_rsrc_list_entry *rsrc, const char *type_name TSRMLS_DC) {\n",destructorname);

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
    Printf(df->code,"  arg1 = (%s)SWIG_ZTS_ConvertResourceData(ptr,type_name,SWIGTYPE%s TSRMLS_CC);\n",
	SwigType_lstr(pt, 0), SwigType_manglestr(pt));
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
    wrapping_member_constant = Getattr(n, "name");
    Language::memberconstantHandler(n);
    wrapping_member_constant = NULL;
    return SWIG_OK;
  }

};  /* class PHP */

/* -----------------------------------------------------------------------------
 * swig_php()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static PHP *maininstance=0;

// We use this function to be able to write out zend_register_list_destructor_ex
// lines for most things in the type table
// NOTE: it's a function NOT A PHP::METHOD
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

static Language * new_swig_php(int php_version) {
  maininstance=new PHP(php_version);
  if (! r_prevtracefunc) {
    r_prevtracefunc=SwigType_remember_trace(typetrace);
  } else {
    Printf(stderr,"php Typetrace vector already saved!\n");
    assert(0);
  }
  return maininstance;
}
extern "C" Language * swig_php4(void) {
  return new_swig_php(4);
}
extern "C" Language * swig_php5(void) {
  return new_swig_php(5);
}

/*
 * PHP4 Support
 *
 * Richard Palmer
 * richard@magicality.org
 * Nov 2001
 */

#include "mod11.h"
#include "php4.h"
#include "swigconfig.h"

#define PHP_READONLY	1<<0

#define PHP_FULL	1<<0
#define PHP_IZE		1<<1

static String *module = 0;
static String *cap_module = 0;
static String *f_cinit = 0;
static String *f_init = 0;
static String *f_entry = 0;

static FILE	*f_h = 0;
static Wrapper	*f_c;
static Wrapper  *f_php;
static int	gen_extra = 1;

static File       *f_header  = 0;
static File       *f_wrappers = 0;
static File       *f_runtime = 0;
static File	  *f_vinit = 0;

static int make_method = PHP_IZE;

/* -----------------------------------------------------------------------------
 * get_pointer()
 * ----------------------------------------------------------------------------- */
static void
get_pointer(char *iname, char *srcname, char *src, char *dest,
            SwigType *t, String *f, char *ret) {

  SwigType_remember(t);
  SwigType *lt = SwigType_ltype(t);
  Printv(f, "if (SWIG_ConvertPtr(", src, ",(void **) &", dest, ",", 0);

  /* If we're passing a void pointer, we give the pointer conversion a NULL
     pointer, otherwise pass in the expected type. */

  if (Cmp(lt,"p.void") == 0) {
    Printf(f, " 0 ) < 0) {\n");
  } else {
    Printv(f, "SWIGTYPE", SwigType_manglestr(t), ") < 0) {\n",0);
  }

  Printv(f,
         "zend_error(E_ERROR, \"Type error in ", srcname, " of ", iname,". Expected %s\", SWIGTYPE",
         SwigType_manglestr(t), "->name);\n",
         ret, ";\n",
         "}\n",
         0);
  Delete(lt);
}


void
PHP4::main(int argc, char *argv[]) {
	int i;
	SWIG_library_directory("php4");
	for(i = 1; i < argc; i++) {
	  if (argv[i]) {
	    if(strcmp(argv[i], "-noextra") == 0) {
	      gen_extra = 0;
	      Swig_mark_arg(i);
	    } else if(strcmp(argv[i], "-phpize") == 0) {
		    make_method = PHP_IZE;
		    Swig_mark_arg(i);
 	    } else if(strcmp(argv[i], "-phpfull") == 0) {
		    make_method = PHP_FULL;
		    Swig_mark_arg(i);
	    }
	  }
	}
	  
	Preprocessor_define((void *) "SWIGPHP4", 0);
	SWIG_typemap_lang("php4");
	/* DB: Suggest using a language configuration file */
	SWIG_config_file("php4.swg");
}


static const char *php_header = "/*\
\n  +----------------------------------------------------------------------+\
\n  | PHP version 4.0                                                      |\
\n  +----------------------------------------------------------------------+\
\n  | Copyright (c) 1997, 1998, 1999, 2000, 2001 The PHP Group             |\
\n  +----------------------------------------------------------------------+\
\n  | This source file is subject to version 2.02 of the PHP license,      |\
\n  | that is bundled with this package in the file LICENSE, and is        |\
\n  | available at through the world-wide-web at                           |\
\n  | http://www.php.net/license/2_02.txt.                                 |\
\n  | If you did not receive a copy of the PHP license and are unable to   |\
\n  | obtain it through the world-wide-web, please send a note to          |\
\n  | license@php.net so we can mail you a copy immediately.               |\
\n  +----------------------------------------------------------------------+\
\n  | Authors:                                                             |\
\n  |                                                                      |\
\n  +----------------------------------------------------------------------+\
\n */\n";

int
PHP4::top(Node *n) {

  FILE *f_m4, *f_credits, *f_make;
  char filen[256];

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
  f_vinit = NewString("");
  
  /* Register file targets with the SWIG file handler */
  Swig_register_filebyname("header",f_header);
  Swig_register_filebyname("wrapper",f_wrappers);
  Swig_register_filebyname("runtime",f_runtime);
  Swig_register_filebyname("init",f_init);
  Swig_register_filebyname("vinit",f_vinit);

  Swig_banner(f_runtime);

  /* Set the module name */
  module = Copy(Getattr(n,"name"));
  cap_module = NewStringf("%(upper)s",module);

  /* Initialize the rest of the module */


  f_cinit = NewString("");

  f_c = NewWrapper();
  f_php = NewWrapper();

  Printf(f_c->def, "static void Swig_sync_c(void) {\n");
  Printf(f_php->def, "static void Swig_sync_php(void) {\n");
  
  Printf(f_header, php_header);

  Printf(f_header, "#define SWIG_init	init%s\n\n", module);
  Printf(f_header, "#define SWIG_name	\"%s\"\n", module);

  /* Create the .h file too */
  sprintf(filen,"%sphp_%s.h", Swig_file_dirname(outfile),Char(module));
  if((f_h = fopen(filen, "w")) == 0) {
	Printf(stderr,"Unable to open %s\n", filen);
	SWIG_exit(EXIT_FAILURE);
  }

  Swig_banner(f_h);
  Printf(f_h, php_header);

  Printf(f_h, "\n\n#ifndef PHP_%s_H\n", Char(cap_module));
  Printf(f_h, "#define PHP_%s_H\n\n", Char(cap_module));
  Printf(f_h, "extern zend_module_entry %s_module_entry;\n", module);
  Printf(f_h, "#define phpext_%s_ptr &%s_module_entry\n\n", module, module);
  Printf(f_h, "#ifdef PHP_WIN32\n");
  Printf(f_h, "#define PHP_%s_API __declspec(dllexport)\n", Char(cap_module));
  Printf(f_h, "#else\n");
  Printf(f_h, "#define PHP_%s_API\n", Char(cap_module));
  Printf(f_h, "#endif\n\n");

  Printf(f_h, "PHP_MINIT_FUNCTION(%s);\n", module);
  Printf(f_h, "PHP_MSHUTDOWN_FUNCTION(%s);\n", module);
  Printf(f_h, "PHP_RINIT_FUNCTION(%s);\n", module);
  Printf(f_h, "PHP_RSHUTDOWN_FUNCTION(%s);\n", module);
  Printf(f_h, "PHP_MINFO_FUNCTION(%s);\n\n", module);

  Printf(f_header, "#ifdef HAVE_CONFIG_H\n");
  Printf(f_header, "#include \"config.h\"\n");
  Printf(f_header, "#endif\n");
  
  Printf(f_header, "#include \"php.h\"\n");
  Printf(f_header, "#include \"php_ini.h\"\n");
  Printf(f_header, "#include \"php_%s.h\"\n", module);

  f_entry = NewString("");
  Printf(f_entry, "static void Swig_sync_c(void);\n");
  Printf(f_entry, "static void Swig_sync_php(void);\n");

  Printf(f_entry,"/*Every user visible function must have an entry in test_functions[] */\n\n");

  Printf(f_entry,"function_entry %s_functions[] = {\n", module);

  /* Start variable init function ( to be put in module init function */

  Printf(f_cinit, "int i;\n");
  Printv(f_cinit, "for (i = 0; swig_types_initial[i]; i++) {\n",
		  "swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);\n",
		  "}\n", 0);


  Printf(f_init,"#ifdef COMPILE_DL_%s\n", cap_module);
  Printf(f_init,"\tZEND_GET_MODULE(%s)\n", module);
  Printf(f_init,"#endif\n\n");

  Printf(f_init,"PHP_MINIT_FUNCTION(%s)\n{\n", module);
  Printf(f_init,"\treturn SUCCESS;\n");
  Printf(f_init, "}\n");

  Printf(f_init,"PHP_MSHUTDOWN_FUNCTION(%s)\n{\n", module);
  Printf(f_init,"\treturn SUCCESS;\n");
  Printf(f_init,"}\n");

  /* Emit all of the code */
  Language::top(n);

  Printf(f_init,"PHP_RINIT_FUNCTION(%s)\n{\n", module);
  Printf(f_init, "%s\n", f_cinit);
  Printf(f_init, "%s\n", f_vinit);


  /* Complete header file */

  Printf(f_h,"/*If you declare any globals in php_%s.h uncomment this:\n", module);
  Printf(f_h,"ZEND_BEGIN_MODULE_GLOBALS(%s)\n", module);
  Printf(f_h,"ZEND_END_MODULE_GLOBALS(%s)\n", module);
  Printf(f_h,"*/\n");

  Printf(f_h,"#ifdef ZTS\n");
  Printf(f_h,"#define %s_D  zend_%s_globals *%s_globals\n", cap_module, module, module);
  Printf(f_h,"#define %s_DC  , %s_D\n",  cap_module, cap_module);
  Printf(f_h,"#define %s_C  %s_globals\n", cap_module, module);
  Printf(f_h,"#define %s_CC  , %s_C\n", cap_module, cap_module);
  Printf(f_h,"#define %s_SG(v)  (%s_globals->v)\n", cap_module, module);
  Printf(f_h,"#define %s_FETCH()  zend_%s_globals *%s_globals = ts_resource(%s_globals_id)\n", cap_module, module, module, module);
  Printf(f_h,"#else\n");
  Printf(f_h,"#define %s_D\n", cap_module);  
  Printf(f_h,"#define %s_DC\n", cap_module);
  Printf(f_h,"#define %s_C\n", cap_module);
  Printf(f_h,"#define %s_CC\n", cap_module);
  Printf(f_h,"#define %s_SG(v)  (%s_globals.v)\n", cap_module, module);
  Printf(f_h,"#define %s_FETCH()\n", cap_module);
  Printf(f_h,"#endif\n\n");

  Printf(f_h,"#endif /* PHP_%s_H */\n", cap_module);
	
  fclose(f_h);


	/* Now finish structures in wrapper file */

	Printf(f_header, "%s", f_entry);

        Printf(f_header,"\t{NULL, NULL, NULL}\n};\n\n");
	Printf(f_header,"zend_module_entry %s_module_entry = {\n", module);
	Printf(f_header,"\t\"%s\",\n", module);
	Printf(f_header,"\t%s_functions,\n", module);
	Printf(f_header,"\tPHP_MINIT(%s),\n", module);
	Printf(f_header,"\tPHP_MSHUTDOWN(%s),\n", module);
	Printf(f_header,"\tPHP_RINIT(%s),\n", module);
	Printf(f_header,"\tPHP_RSHUTDOWN(%s),\n", module);
	Printf(f_header,"\tPHP_MINFO(%s),\n", module);
	Printf(f_header,"\tSTANDARD_MODULE_PROPERTIES\n");
	Printf(f_header,"};\n\n");

  	String *type_table = NewString("");
  	SwigType_emit_type_table(f_runtime,type_table);
  	Printf(f_runtime,"%s",type_table);
  	Delete(type_table);

	Printf(f_init, "return SUCCESS;\n");
	Printf(f_init,"}\n");

	Printf(f_init,"PHP_RSHUTDOWN_FUNCTION(%s)\n{\n", module);
	Printf(f_init,"\treturn SUCCESS;\n");
	Printf(f_init,"}\n");

	Printf(f_init,"PHP_MINFO_FUNCTION(%s)\n{\n", module);
	Printf(f_init,"\tphp_info_print_table_start();\n");
	Printf(f_init,"\tphp_info_print_table_header(2, \"test support\", \"enableed\");\n");
	Printf(f_init,"\tphp_info_print_table_end();\n");
	Printf(f_init,"}\n");

	Printf(f_c->code, "\n}\n");
	Printf(f_php->code, "\n}\n");

	Wrapper_print(f_c, f_wrappers);
	Wrapper_print(f_php, f_wrappers);

	Printv(f_runtime, f_header, f_wrappers,f_init,0);
	Delete(f_header);
	Delete(f_wrappers);
	Delete(f_init);
	Close(f_runtime);

	if(!gen_extra) { 
		return SWIG_OK;
	}

	if((make_method == PHP_FULL) || (make_method == PHP_IZE)) {
		/* Write out Makefile.in and the like */

       	  if((f_make = fopen("Makefile.in", "w")) == 0) {
		Printf(stderr,"Unable to open Makefile.in\n");
		SWIG_exit(EXIT_FAILURE);
  	  }

	  Printf(f_make, "# $Id$\n\n");
	  Printf(f_make, "LTLIBRARY_NAME\t\t\t= lib%s.la\n", module);
	  Printf(f_make, "LTLIBRARY_SOURCES\t\t= %s_wrap.c\n", module);
	  Printf(f_make, "LTLIBRARY_SHARED_NAME\t\t= %s.la\n", module);
	  Printf(f_make, "LTLIBRARY_SHARED_LIBADD\t\t= $(%s_SHARED_LIBADD)\n\n",
			cap_module);
	  Printf(f_make, "include $(top_srcdir)/build/dynlib.mk\n");

	  fclose(f_make);
	}
	/*
	} else if(make_method == PHP_DL) {
		if((f_make = fopen("Makefile", "w")) == 0) {
			Printf(stderr, "Unable to open Makefile\n");
			SWIG_exit(EXIT_FAILURE);
		}

		Printf(f_make, "CC = cc\n\n");
		Printf(f_make, "# Add any extra object files here\n");
		Printf(f_make, "OBJECTS = %s_wrap.o\n\n", module);
		Printf(f_make, "# Path to PHP directory\n");
		Printf(f_make, "PHP_INCLUDE = /usr/local/include\n\n");
		Printf(f_make, "# PHP include directories\n");
		Printf(f_make, "INCLUDES = -I. -I$(PHP_INCLUDE)/php -I$(PHP_INCLUDE)/php/main -I$(PHP_INCLUDE)/php/Zend -I$(PHP_INCLUDE)/php/TSRM\n\n");
		Printf(f_make, "# Path to extra libraries\n");
		Printf(f_make, "LIB_DIRS = -L/usr/local/lib\n\n");
		Printf(f_make, "# Extra libraries needed\n");
		Printf(f_make, "LIBS =\n\n");
		Printf(f_make, "%s.so:	$(OBJECTS)\n", module);
		Printf(f_make, "\t$(CC) -shared -rdynamic -o %s.so $(OBJECTS) $(LIB_DIRS) $(LIBS)\n\n", module);
		Printf(f_make, ".c.o:\n");
		Printf(f_make, "\t$(CC) -fpic -DCOMPILE_DL=1 $(INCLUDES) -c $<\n");
		fclose(f_make);
	}
	*/


	/* Now config.m4 */

	if((make_method == PHP_FULL) || (make_method == PHP_IZE)) {

	  if((f_m4 = fopen("config.m4", "w")) == 0) {
		Printf(stderr, "Unable to open config.m4\n");
		SWIG_exit(EXIT_FAILURE);
	  }

	  Printf(f_m4,"dnl $Id$\n");
	  Printf(f_m4,"dnl config.m4 for extension %s\n\n", module);
	  Printf(f_m4,"dnl Comments in this file start with the string 'dnl'.\n");
	  Printf(f_m4,"dnl Remove where necessary. This file will not work\n");
	  Printf(f_m4,"dnl without editing.\n\n");

	  Printf(f_m4,"dnl If your extension references somthing external, use with:\n\n");
	  Printf(f_m4,"dnl PHP_ARG_WITH(%s, for %s support,\n", module, module);
	  Printf(f_m4,"dnl Make sure that the comment is aligned:\n");
	  Printf(f_m4,"dnl [  --with-%s		Include %s support])\n\n", 
			module, module);

	  Printf(f_m4,"dnl Otherwise use enable:\n\n");
	  Printf(f_m4,"PHP_ARG_ENABLE(%s, whether to enable %s support,\n", module, module);
	  Printf(f_m4,"dnl Make sure that the comment is aligned:\n");
	  Printf(f_m4,"[  --enable-%s	Enable %s support])\n\n",
			module, module);

	  Printf(f_m4,"if test \"$PHP_%s\" != \"no\"; then\n", cap_module);
	  Printf(f_m4,"  dnl Write more examples of tests here\n\n");
	  Printf(f_m4,"  dnl # --with-%s -> check with-path\n", module);
	  Printf(f_m4,"  dnl SEARCH_PATH=\"/usr/local /usr\"  # you might want to change this\n");
	  Printf(f_m4,"  dnl SEARCH_FOR=\"/include/%s.h\"  # you most likely want to change this\n", module);
	  Printf(f_m4,"  dnl if test -r $PHP_%s/; then # path given as parameter\n", module);
	  Printf(f_m4,"  dnl   %s_DIR=$PHP_%s\n", cap_module, cap_module);
	  Printf(f_m4,"  dnl else # search default path list\n");
	  Printf(f_m4,"  dnl   AC_MSG_CHECKING(for %s files in default path)\n",
			module);
	  Printf(f_m4,"  dnl   for i in $SEARCH_PATH; do\n");
	  Printf(f_m4,"  dnl     if test -r $i/$SEARCH_FOR; then\n");
	  Printf(f_m4,"  dnl       %s_DIR=$i\n", cap_module);
	  Printf(f_m4,"  dnl       AC_MSG_RESULT(found in $i)\n");
	  Printf(f_m4,"  dnl     fi\n");
	  Printf(f_m4,"  dnl   done\n");
	  Printf(f_m4,"  dnl fi\n");
	  Printf(f_m4,"  dnl\n");
	  Printf(f_m4,"  dnl if test -z \"$%s_DIR\"; then\n", cap_module);
	  Printf(f_m4,"  dnl   AC_MSG_RESULT(not found)\n");
	  Printf(f_m4,"  dnl   AC_MSG_ERROR(Please reinstall the %s distribution)\n", module);
	  Printf(f_m4,"  dnl fi\n\n");
	  Printf(f_m4,"  dnl # --with-%s -> add include path\n", module);
	  Printf(f_m4,"  dnl PHP_ADD_INCLUDE($%s_DIR/include)\n\n", cap_module);
	  Printf(f_m4,"  dnl #--with-%s -> check for lib and symbol presence\n",
			module);
	  Printf(f_m4,"  dnl LIBNAME=%s # you may want to change this\n", module);
	  Printf(f_m4,"  dnl LIBSYMBOL=%s #  you most likely want to change this\n", module);
	  Printf(f_m4,"  dnl old_LIBS=$LIBS\n");
	  Printf(f_m4,"  dnl LIBS=\"$LIBS -L$%s_DIR/lib -lm -ldl\"\n",cap_module);
	  Printf(f_m4,"  dnl AC_CHECK_LIB($LIBNAME, $LIBSYMBOL, [AC_DEFINE(HAVE_%sLIB,1,[ ])],\n", cap_module);
	  Printf(f_m4,"  dnl [AC_MSG_ERROR(wrong %s lib version or lib not found)])\n", module);
	  Printf(f_m4,"  dnl LIBS=$old_LIBS\n");
	  Printf(f_m4,"  dnl\n");
	  Printf(f_m4,"  dnl PHP_SUBST(%s_SHARED_LIBADD)\n", cap_module);
	  Printf(f_m4,"  dnl PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $%s_DIR/lib, SAPRFC_SHARED_LIBADD)\n\n",cap_module);
	  Printf(f_m4,"  PHP_EXTENSION(%s, $ext_shared)\n", module);
	  Printf(f_m4,"fi\n");

	  fclose(f_m4);
	}

	/*  CREDITS */

	if((make_method == PHP_FULL) || (make_method == PHP_IZE)) {

          if((f_credits = fopen("CREDITS", "w")) == 0) {
		Printf(stderr,"Unable to open CREDITS\n");
		SWIG_exit(EXIT_FAILURE);
  	  }

	  Printf(f_credits, "%s\n", module);

	  fclose(f_credits);

	}
	return SWIG_OK;
}

#if 0
void
PHP4::set_module(char *mod_name) {
	char *c;
	if(module) return;
	module = NewString(mod_name);
	cap_module = Copy(module);
	for(c = Char(cap_module); *c != '\0'; c++) {
		if((*c >= 'a') && (*c <= 'z'))
			*c-=32;	
	}
}

#endif

/*
void
PHP4::add_method(char *name, char *function, int kw) {
	fprintf(stderr, "Would add method %s\n", name);
}
*/

/* Just need to append function names to function table to register with
   PHP
*/

void
PHP4::create_command(char *cname, char *iname) {
	char *lower_cname = strdup(cname);
	char *c;

	for(c = lower_cname; *c != '\0'; c++) {
		if(*c >= 'A' && *c <= 'Z')
			*c = *c + 32;
	}

	Printf(f_entry, "\tZEND_NAMED_FE(%s, %s, NULL)\n", lower_cname, iname);
	Printf(f_h, "ZEND_NAMED_FUNCTION(%s);\n", iname);

	free(lower_cname);
}

int
PHP4::functionWrapper(Node *n) {
  char *name = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *d = Getattr(n,"type");
  ParmList *l = Getattr(n,"parms");
  Parm *p;
  char source[256],target[256],temp[256],argnum[32],args[32];
  int pcount,i,j,numopt;
  String *tm;
  Wrapper *f;
  int need_save, num_saved = 0;
  String *cleanup, *outarg;


  create_command(name, Char(Swig_name_wrapper(iname)));
  outarg = cleanup = NULL;
  f 	= NewWrapper();
  numopt = 0;

  outarg = NewString("");

  Printv(f->def, "ZEND_NAMED_FUNCTION(" , Swig_name_wrapper(iname), ") {\n", 0);

  emit_args(d, l, f);
  /* Attach standard typemaps */
  emit_attach_parmmaps(l,f);

  int num_arguments = emit_num_arguments(l);
  int num_required  = emit_num_required(l);
  numopt = num_arguments - num_required;

  sprintf(args, "%s[%d]", "zval **args", num_arguments); 
  
  Wrapper_add_local(f, "args",args);

  Printf(f->code, "Swig_sync_c();\n\n");/* Keep PHP4 / C vars in sync */

  if(numopt > 0) {
    Wrapper_add_local(f, "arg_count", "int arg_count");
    Printf(f->code,"arg_count = ZEND_NUM_ARGS();\n");
    Printf(f->code,"if(arg_count<%d || arg_count>%d)\n",num_required,num_arguments);
    Printf(f->code,"\tWRONG_PARAM_COUNT;\n\n");

    /* Verified args, retrieve them... */
    Printf(f->code,"if(zend_get_parameters_array_ex(arg_count,args)!=SUCCESS)");
    Printf(f->code, "\n\t\tWRONG_PARAM_COUNT;\n\n");

  } else {
   Printf(f->code, "if((ZEND_NUM_ARGS() != %d) || (zend_get_parameters_array_ex(%d, args) != SUCCESS)) {\n", num_arguments, num_arguments);
   Printf(f->code, "WRONG_PARAM_COUNT;\n}\n\n");
  }
  
  /* Now convert from php to C variables */

  for (i = 0, p = l; i < num_arguments; i++) {
    /* Skip ignored arguments */
    while (Getattr(p,"tmap:ignore")) {
      p = Getattr(p,"tmap:ignore:next");
    }
    SwigType *pt = Getattr(p,"type");
    String   *pn = Getattr(p,"name");

    sprintf(source, "*(args[%d])", i);
    sprintf(target, "%s", Char(Getattr(p,"lname")));
    sprintf(argnum, "%d", i+1);

    /* Check if optional */
    
    if(i>= (num_required))
      Printf(f->code,"\tif(arg_count > %d) {\n", i);
    
    Setattr(p,"emit:input", source);

    if ((tm = Getattr(p,"tmap:in"))) {
      Replace(tm,"$target",target,DOH_REPLACE_ANY);
      Replace(tm,"$source",source,DOH_REPLACE_ANY);
      Replace(tm,"$input", source,DOH_REPLACE_ANY);
      Printf(f->code,"%s\n",tm);
      p = Getattr(p,"tmap:in:next");
      if (i >= num_required) {
	Printf(f->code,"}\n");
      }
      continue;
    } else {
      switch(SwigType_type(pt)) {
      case T_BOOL:
      case T_INT :
      case T_SHORT :
      case T_LONG :
      case T_SCHAR :
      case T_UINT :
      case T_USHORT :
      case T_ULONG :
      case T_UCHAR :
	Printf(f->code,"convert_to_long_ex(args[%d]);\n", i);
	Printf(f->code,"%s =(%s)Z_LVAL_PP(args[%d]);\n", target, SwigType_lstr(pt,0),i);
	break;
      case T_CHAR :
	Printf(f->code,"convert_to_string_ex(args[%d]);\n", i);
	Printf(f->code,"\t%s = (char) *Z_STRVAL_PP(args[%d]);\n", target, i);
	break;
      case T_DOUBLE :
      case T_FLOAT :
	Printf(f->code,"convert_to_double_ex(args[%d]);\n", i);
	Printf(f->code,"\t%s = (%s)Z_DVAL_PP(args[%d]);\n", target, SwigType_lstr(pt,0), i);
	break;
      case T_VOID :
	break;
      case T_USER :
	SwigType_add_pointer(pt);
	sprintf(temp,"argument %d", i+1);
	Printf(f->code,"convert_to_string_ex(args[%d]);\n", i);
	get_pointer(iname, temp, source, target, pt, f->code, (char *)"RETURN_FALSE");
	SwigType_del_pointer(pt);
	break;
      case T_POINTER: case T_ARRAY: case T_REFERENCE:
	sprintf(temp,"argument %d", i+1);
	Printf(f->code,"convert_to_string_ex(args[%d]);\n", i);
	get_pointer(iname,temp,source,target, pt, f->code, (char *)"");
	break;
      case T_STRING:
	Printf(f->code,"convert_to_string_ex(args[%d]);\n", i);
	Printf(f->code,"\t%s = (char *)Z_STRVAL_PP(args[%d]);\n", target, i);
	break;
	
      default :
	Printf(stderr,"%s : Line %d, Unable to use type %s as a function argument.\n", input_file, line_number, SwigType_str(pt,0));
	break;
      }
      p = nextSibling(p);
    }
    if (i>= num_required)
      Printf(f->code,"\t}\n");
  }

  /* Insert constraint checking code */
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:check"))) {
      Replace(tm,"$target",Getattr(p,"lname"),DOH_REPLACE_ANY);
      Printv(f->code,tm,"\n",0);
      p = Getattr(p,"tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }
  
  /* Insert cleanup code */
  for (i = 0, p = l; p; i++) {
    if ((tm = Getattr(p,"tmap:freearg"))) {
      Replace(tm,"$source",Getattr(p,"lname"),DOH_REPLACE_ANY);
      Printv(cleanup,tm,"\n",0);
      p = Getattr(p,"tmap:freearg:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Insert argument output code */
  num_saved = 0;
  for (i=0,p = l; p;i++) {
    if ((tm = Getattr(p,"tmap:argout"))) {
      Replace(tm,"$source",Getattr(p,"lname"),DOH_REPLACE_ANY);
      Replace(tm,"$target","return_value",DOH_REPLACE_ANY);
      Replace(tm,"$result","return_value",DOH_REPLACE_ANY);
      String *in = Getattr(p,"emit:input");
      if (in) {
	sprintf(temp,"_saved[%d]", num_saved);
	Replace(tm,"$arg",temp, DOH_REPLACE_ANY);
	Printf(f->code,"_saved[%d] = %s;\n", num_saved, in);
	num_saved++;
      }
      Printv(outarg,tm,"\n",0);
      p = Getattr(p,"tmap:argout:next");
    } else {
      p = nextSibling(p);
    }
  }

  if(num_saved) {
    sprintf(temp, "_saved[%d]",num_saved);
    Wrapper_add_localv(f,"_saved","zval *",temp,0);
  }

  /* emit function call*/
  
  emit_action(n,f);

  if((tm = Swig_typemap_lookup((char*)"out",d,iname,(char*)"result",(char*)"result",(char*)"return_value",0))) {
    Printf(f->code, "%s\n", tm);
  } else {
    if(SwigType_type(d) != T_VOID) {
      switch(SwigType_type(d)) {
      case T_INT:
      case T_BOOL:
      case T_UINT:
      case T_SHORT:
      case T_USHORT:
      case T_LONG:
      case T_ULONG:
      case T_SCHAR:
      case T_UCHAR:
	Printf(f->code,"RETURN_LONG((long)result);\n");
	break;
      case T_DOUBLE:
      case T_FLOAT:
	Printf(f->code,"RETURN_DOUBLE((double)result);\n");
	break;
      case T_CHAR:
	Wrapper_add_local(f,"_ctemp","char ctemp[2]");
	Printv(f->code,
	       tab4, "ctemp[0] = result;\n",
	       tab4, "ctemp[1] = 0;\n",
	       tab4, "RETURN_STRING(ctemp, 1);\n", 0);
	break;
      case T_USER:
	SwigType_add_pointer(d);
	SwigType_remember(d);
	Printv(f->code, "SWIG_SetPointerZval(return_value, (void *)result, SWIGTYPE", SwigType_manglestr(d), ");\n", 0);
	SwigType_del_pointer(d);
	break;
      case T_STRING:
	Printf(f->code,"RETURN_STRING(result, 1);\n");
	break;
	
      case T_POINTER:
	SwigType_remember(d);
	Printv(f->code, tab4, "SWIG_SetPointerZval(return_value, (void *)result, SWIGTYPE", SwigType_manglestr(d), ");\n", 0);
	break;
      default:
	Printf(stderr,"%s: Line %d, Unable to use return type %s in function %s.\n", input_file, line_number, SwigType_str(d,0), name);
	break;
	
      }
    }
  }
  
  
  if(outarg)
    Printv(f->code,outarg,0);
  
  if(cleanup)
    Printv(f->code,cleanup,0);
  
  if((tm = Swig_typemap_lookup((char*)"ret",d,iname,(char *)"result", (char*)"result",(char*)"",0))) {
    Printf(f->code,"%s\n", tm);
  }
  
  Replace(f->code,"$cleanup",cleanup,DOH_REPLACE_ANY);
  Replace(f->code,"$name",iname,DOH_REPLACE_ANY);
  
  Printf(f->code, "\nSwig_sync_php();\n");
  Printf(f->code, "\n}");
  
  Wrapper_print(f,f_wrappers);
  return SWIG_OK;
}

int
PHP4::variableWrapper(Node *n) {
  char *name = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *t = Getattr(n,"type");
  int flags = 0;

  if(ReadOnly) {
	  flags |= PHP_READONLY;
  }

  SwigType_remember(t);

  /* Write out initilization code */
  
  switch(SwigType_type(t)) {
  case T_INT:
  case T_BOOL:
  case T_UINT:
  case T_SHORT:
  case T_USHORT:
  case T_LONG:
  case T_ULONG:
  case T_SCHAR:
  case T_UCHAR:
	Printf(f_vinit,"{\n\tzval *z_var;\n");
	Printf(f_vinit, "\tMAKE_STD_ZVAL(z_var);\n");
	Printf(f_vinit, "\tz_var->type = IS_LONG;\n");
	Printf(f_vinit, "\tz_var->value.lval = %s;\n", name);
	Printf(f_vinit, "\tzend_hash_add(&EG(symbol_table), \"%s\", %d,(void *)&z_var,sizeof(zval *), NULL);\n}\n", name, strlen(name)+1);
	break;

  case T_DOUBLE:
  case T_FLOAT:
	Printf(f_vinit, "{\n\tzval *z_var;\n");
	Printf(f_vinit, "\tMAKE_STD_ZVAL(z_var);\n");
	Printf(f_vinit, "\tz_var->type = IS_DOUBLE;\n");
	Printf(f_vinit, "\tz_var->value.dval = %s;\n", name);
	Printf(f_vinit, "\tzend_hash_add(&EG(symbol_table), \"%s\", %d, (void *)&z_var,sizeof(zval *), NULL);\n}\n", name, strlen(name)+1);
	break;
  case T_CHAR:
	Printf(f_vinit, "{\n\tzval *z_var;\n");
	Printf(f_vinit, "\tchar c[2];\n");
	Printf(f_vinit, "\tMAKE_STD_ZVAL(z_var);\n");
	Printf(f_vinit, "\tc[0] = %s;\n", name);
	Printf(f_vinit, "\tc[1] = 0;\n");
	Printf(f_vinit, "\tz_var->type = IS_STRING;\n");
	Printf(f_vinit, "\tz_var->value.str.val = estrdup(c);\n");
	Printf(f_vinit, "\tz_var->value.str.len = 2;\n");
	Printf(f_vinit, "\tzend_hash_add(&EG(symbol_table), \"%s\", %d, (void *)&z_var,sizeof(zval *), NULL);\n}\n", name, strlen(name)+1);
	break;

  case T_STRING:
	Printf(f_vinit, "{\n\tzval *z_var;\n");
	Printf(f_vinit, "\tMAKE_STD_ZVAL(z_var);\n");
	Printf(f_vinit, "\tz_var->type = IS_STRING;\n");
	Printf(f_vinit, "\tif(%s) {\n", name);
	Printf(f_vinit, "\t\tz_var->value.str.val = estrdup(%s);\n", name);
	Printf(f_vinit, "\t\tz_var->value.str.len = strlen(%s)+1;\n", name);
	Printf(f_vinit, "\t} else {\n");
	Printf(f_vinit, "\t\tz_var->value.str.val = 0;\n");
	Printf(f_vinit, "\t\tz_var->value.str.len = 0;\n");
	Printf(f_vinit, "\t}\nzend_hash_add(&EG(symbol_table), \"%s\", %d, (void *)&z_var, sizeof(zval *), NULL);\n}\n", name, strlen(name)+1);
	break;

  case T_USER:
	SwigType_add_pointer(t);
	Printf(f_vinit, "{\n\tzval *z_var;\n");
	Printf(f_vinit, "MAKE_STD_ZVAL(z_var);\n");
	Printf(f_vinit, "\tSWIG_SetPointerZval(z_var, (void*)&%s, SWIGTYPE%s);\n", name, SwigType_manglestr(t));
	Printf(f_vinit, "\tzend_hash_add(&EG(symbol_table), \"%s\", %d, (void *)&z_var, sizeof(zval *), NULL);\n}\n", name, strlen(name)+1);
	SwigType_del_pointer(t);
	break;
  case T_ARRAY:
	{
	int setable = 0;
	SwigType *aop;
	SwigType *ta = Copy(t);
	aop = SwigType_pop(ta);
	if(SwigType_type(ta) == T_CHAR) {
		String *dim = SwigType_array_getdim(aop, 0);
		Printf(f_vinit, "{\nzval *z_var;\n");
		Printf(f_vinit, "MAKE_STD_ZVAL(z_var);\n");
		Printf(f_vinit, "z_var->type = IS_STRING;\n");
		Printf(f_vinit, "if(%s) {\n", name);
		Printf(f_vinit,"z_var->value.str.val = estrndup(%s, %s);\n", name, Char(dim));
		Printf(f_vinit, "z_var->value.str.len = strlen(%s)+1;\n}\n", name);
		Printf(f_vinit, "zend_hash_add(&EG(symbol_table), \"%s\", %d, (void *)&z_var, sizeof(zval *), NULL);\n}\n", name, strlen(name)+1);
	} else {
		Printf(f_vinit,"{\n\tzval *z_var;\n");
		Printf(f_vinit, "\tMAKE_STD_ZVAL(z_var);\n");
		Printf(f_vinit,"\tSWIG_SetPointerZval(z_var, (void *)%s, SWIGTYPE%s);\n", name, SwigType_manglestr(t));
		Printf(f_vinit, "\tzend_hash_add(&EG(symbol_table), \"%s\", %d, (void *)&z_var, sizeof(zval *), NULL);\n}\n", name, strlen(name)+1);
		Printf(f_vinit, "}\n");
	}
	Delete(ta);
	Delete(aop);
	}
	break;
  case T_POINTER:
  case T_REFERENCE:
	Printf(f_vinit, "{\n\tzval *z_var;\n");
	Printf(f_vinit, "\tMAKE_STD_ZVAL(z_var);\n");
	Printf(f_vinit, "\tSWIG_SetPointerZval(z_var, (void*)%s, SWIGTYPE%s);\n", name,SwigType_manglestr(t));
	Printf(f_vinit, "\tzend_hash_add(&EG(symbol_table), \"%s\", %d, (void *)&z_var, sizeof(zval *), NULL);\n}\n", name, strlen(name)+1);
	break;
  default:
	/* error */
	break;
  }


  /* Now code to set php values */

  switch(SwigType_type(t)) {
  case T_INT:
  case T_BOOL:
  case T_UINT:
  case T_SHORT:
  case T_USHORT:
  case T_LONG:
  case T_ULONG:
  case T_SCHAR:
  case T_UCHAR:
	Wrapper_add_local(f_php, "z_var", "zval **z_var");
	Printf(f_php->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void **)&z_var);\n", name, strlen(name)+1);
	Printf(f_php->code, "if(%s != (%s)((*z_var)->value.lval)) {\n", name, SwigType_lstr(t, 0));
	Printf(f_php->code, "(*z_var)->value.lval = (long)%s;\n", name);
	Printf(f_php->code, "}\n");
	break;

  case T_DOUBLE:
  case T_FLOAT:
	Wrapper_add_local(f_php, "z_var", "zval **z_var");
	Printf(f_php->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void **)&z_var);\n", name, strlen(name)+1);
	Printf(f_php->code, "if(%s != (%s)((*z_var)->value.dval)) {\n", name, SwigType_lstr(t, 0));
	Printf(f_php->code, "(*z_var)->value.dval = (double)%s;\n", name);
	Printf(f_php->code, "}\n");
	break;
  case T_CHAR:
	Wrapper_add_local(f_php, "z_var", "zval **z_var");
	Printf(f_php->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void *)&z_var);\n", name, strlen(name)+1);
	Printf(f_php->code, "if(%s != *((*z_var)->value.str.val)) {\n", name);
	Printf(f_php->code, "char c[2];\n");
	Printf(f_php->code, "efree((*z_var)->value.str.val);\n"); 
	Printf(f_php->code, "c[0] = %s;\n", name);
	Printf(f_php->code, "c[1] = 0;\n");
	Printf(f_php->code, "(*z_var)->value.str.val = estrdup(c);\n");
	Printf(f_php->code, "}\n");
	break;
  case T_STRING:
	Wrapper_add_local(f_php, "z_var", "zval **z_var");
	Wrapper_add_local(f_php, "s1", "char *s1");
	Printf(f_php->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void **)&z_var);\n", name, strlen(name)+1);
	Printf(f_php->code, "s1 = Z_STRVAL_PP(z_var);\n");
	Printf(f_php->code, "if((s1 == NULL) || (%s == NULL) || zend_binary_strcmp(s1, strlen(s1), %s, strlen(%s) )) {\n", name, name, name);
	Printf(f_php->code, "if(s1)\n");
	Printf(f_php->code, "efree(s1);\n");
	Printf(f_php->code, "if(%s) {\n", name);
	Printf(f_php->code, "(*z_var)->value.str.val = estrdup(%s);\n", name);
	Printf(f_php->code, "(*z_var)->value.str.len = strlen(%s)+1;\n", name);
	Printf(f_php->code, "} else {\n");
	Printf(f_php->code, "(*z_var)->value.str.val = 0;\n");
	Printf(f_php->code, "(*z_var)->value.str.len = 0;\n");
	Printf(f_php->code, "}\n}\n");
	break;
  case T_USER:
	SwigType_add_pointer(t);
	Wrapper_add_local(f_php, "z_var", "zval **z_var");
	Printf(f_php->code, "{\nzend_hash_find(&EG(symbol_table), \"%s\", %d, (void **)&z_var);\n", name, strlen(name)+1);
	Printf(f_php->code, "SWIG_SetPointerZval(*z_var, (void*)&%s, SWIGTYPE%s);\n", name, SwigType_manglestr(t));
	Printf(f_php->code, "}\n");
	SwigType_del_pointer(t);
	break;
  case T_ARRAY:
	{
	int setable = 0;
	SwigType *aop;
	SwigType *ta = Copy(t);
	aop = SwigType_pop(ta);
	if(SwigType_type(ta) == T_CHAR) {
		String *dim = SwigType_array_getdim(aop, 0);
		Wrapper_add_local(f_php, "z_var", "zval **z_var");
		Wrapper_add_local(f_php, "s1", "char *s1");
		Printf(f_php->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void **)&z_var);\n", name, strlen(name)+1);
		Printf(f_php->code, "s1 = Z_STRVAL_PP(z_var);\n");
		Printf(f_php->code, "if((s1 == NULL) || zend_binary_strcmp(s1, strlen(s1), %s, strlen(%s) )) {\n", name, name);
		Printf(f_php->code, "if(%s) {\n", name);
		Printf(f_php->code, "(*z_var)->value.str.val = estrdup(%s);\n", name);
		Printf(f_php->code, "(*z_var)->value.str.len = strlen(%s)+1;\n", name);
		Printf(f_php->code, "} else {\n");
		Printf(f_php->code, "(*z_var)->value.str.val = 0;\n");
		Printf(f_php->code, "(*z_var)->value.str.len = 0;\n");
		Printf(f_php->code, "}\n}\n");
	} else {
		Wrapper_add_local(f_php, "z_var", "zval **z_var");
		Printf(f_php->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void **)&z_var);\n", name, strlen(name)+1);
		Printf(f_php->code, "if(%s) {\n", name);
		Printf(f_php->code, "SWIG_SetPointerZval(*z_var, (void*)%s, SWIGTYPE);\n", name, SwigType_manglestr(t));
		/* Arrays are not modified directly by PHP vars */
	}
	Delete(ta);
	Delete(aop);
	}
	break;
  case T_POINTER:
  case T_REFERENCE:
	Wrapper_add_local(f_php, "z_var", "zval **z_var");
	Printf(f_php->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void **)&z_var);\n", name, strlen(name)+1);
	Printf(f_php->code, "SWIG_SetPointerZval(*z_var, (void *)%s, SWIGTYPE%s);\n", name, SwigType_manglestr(t));
	break;
  default:
	/* error */
	break;
  }
	
  /* Now code to set c values */

  if(!(flags & PHP_READONLY)) {

  switch(SwigType_type(t)) {
  case T_INT:
  case T_BOOL:
  case T_UINT:
  case T_SHORT:
  case T_USHORT:
  case T_LONG:
  case T_ULONG:
  case T_SCHAR:
  case T_UCHAR:
	Wrapper_add_local(f_c, "z_var", "zval **z_var");
	Printf(f_c->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void *)&z_var);\n", name, strlen(name)+1);
	Printf(f_c->code, "if(%s != (%s)((*z_var)->value.lval)) {\n", name, SwigType_lstr(t, 0));
	Printf(f_c->code, "%s = Z_LVAL_PP(z_var);\n", name);
	Printf(f_c->code, "}\n");
	break;
  case T_DOUBLE:
  case T_FLOAT:
	Wrapper_add_local(f_c, "z_var", "zval **z_var");
	Printf(f_c->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void *)&z_var);\n", name, strlen(name)+1);
	Printf(f_c->code, "if(%s != (%s)((*z_var)->value.dval)) {\n", name, SwigType_lstr(t, 0));
	Printf(f_c->code, "%s = Z_DVAL_PP(z_var);\n", name);
	Printf(f_c->code, "\n}\n");
	break;
  case T_CHAR:
	Wrapper_add_local(f_c, "z_var", "zval **z_var");
	Printf(f_c->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void *)&z_var);\n", name, strlen(name)+1);
	Printf(f_c->code, "if(%s != *((*z_var)->value.str.val)) {\n", name);
	Printf(f_c->code, "%s = *((*z_var)->value.str.val);\n", name);
	Printf(f_c->code, "\n}\n");
	break;

  case T_STRING:
	Wrapper_add_local(f_c, "z_var", "zval **z_var");
	Wrapper_add_local(f_c, "s1", "char *s1");
	Printf(f_c->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void *)&z_var);\n", name, strlen(name)+1);
	Printf(f_c->code, "s1 = Z_STRVAL_PP(z_var);\n");
	Printf(f_c->code, "if((s1 == NULL) || (%s == NULL) || zend_binary_strcmp(s1, strlen(s1), %s, strlen(%s) )) {\n", name, name, name);
	Printf(f_c->code, "if(s1)\n");
	Printf(f_c->code, "%s = estrdup(s1);\n", name, name);
	Printf(f_c->code, "else\n");
	Printf(f_c->code, "%s = NULL;\n", name);
	Printf(f_c->code, "}\n");
	break;

  case T_USER:
	SwigType_add_pointer(t);
	Wrapper_add_local(f_c, "z_var", "zval **z_var");
	Printf(f_c->code, "{\n %s _temp;\n", SwigType_lstr(t,0));
	Printf(f_c->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void *)&z_var);\n", name, strlen(name)+1);
	get_pointer(name, (char*)"value", (char*)"*z_var", (char*)"_temp", t, f_c->code,(char*)"return");
	Printv(f_c->code, tab4, name, " = *(", SwigType_str(t,0), ") _temp;\n", 0);
	Printf(f_c->code,"}\n");
	SwigType_del_pointer(t);
	break;
  case T_ARRAY:
	{
	int setable = 0;
	SwigType *aop;
	SwigType *ta = Copy(t);
	aop = SwigType_pop(ta);
	if(SwigType_type(ta) == T_CHAR) {
		String *dim = SwigType_array_getdim(aop, 0);
		Wrapper_add_local(f_c, "z_var", "zval **z_var");
		Wrapper_add_local(f_c, "s1", "char *s1");
		Printf(f_c->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void *)&z_var);\n", name, strlen(name)+1);
		Printf(f_c->code, "s1 = Z_STRVAL_PP(z_var);\n");
		Printf(f_c->code, "if((s1 == NULL) || (%s == NULL) || zend_binary_strcmp(s1, strlen(s1), %s, strlen(%s) )) {\n", name, name, name);
		Printf(f_c->code, "if(s1) {\n");
		Printf(f_c->code, "strncpy(%s, s1, %s);\n", name, Char(dim));
		Printf(f_c->code, "}\n}\n");
	} else {
		Wrapper_add_local(f_c, "z_var", "zval **z_var");
		Printf(f_c->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void *)&z_var);\n", name, strlen(name)+1);
		Printf(f_c->code, "if(%s) {\n", name);
		Printf(f_c->code, "SWIG_SetPointerZval(*z_var, (void*)%s, SWIGTYPE%s);\n", name, SwigType_manglestr(t));
		Printf(f_c->code, "}\n");
		/* Arrays are not modified directly by PHP vars */
	}
	Delete(ta);
	Delete(aop);
	}
	break;
  case T_POINTER:
  case T_REFERENCE:
	Printf(f_c->code, "{\n");
	Printf(f_c->code, "%s _temp;\n", SwigType_lstr(t,0));
	Wrapper_add_local(f_c, "z_var", "zval **z_var");
	Printf(f_c->code, "zend_hash_find(&EG(symbol_table), \"%s\", %d, (void **)&z_var);\n", name, strlen(name)+1);
	get_pointer(name, (char*)"value", (char*)"(*z_var)", (char*)"_temp", t,f_c->code, (char*)"return");
	Printv(f_c->code, tab4, name, " = (", SwigType_str(t,0), ") _temp;\n", 0);
	Printf(f_c->code, "}\n");
	break;
  default:
	/* error */
	break;
  }
  }
  return SWIG_OK;
}

int
PHP4::constantWrapper(Node *n) {
  char *name = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *type = Getattr(n,"type");
  char *value = GetChar(n,"value");
	String *rval;

	SwigType_remember(type);

	switch(SwigType_type(type)) {
	case T_STRING:
		rval = NewStringf("\"%s\"", value);
		break;
	case T_CHAR:
		rval = NewStringf("\'%s\'", value);
		break;
	default:
		rval = NewString(value);
	}

	switch(SwigType_type(type)) {
		case T_BOOL: 
		case T_INT :
		case T_SHORT :
		case T_SCHAR:
		case T_LONG:
			Printv(f_cinit, "REGISTER_LONG_CONSTANT(\"", name, "\", ", rval, ", CONST_CS);\n", 0);
			break;
		case T_DOUBLE: 
		case T_FLOAT:
			Printv(f_cinit, "REGISTER_DOUBLE_CONSTANT(\"", name, "\", ", rval, ", CONST_CS);\n", 0);
			break;
		case T_STRING:
			Printv(f_cinit, "REGISTER_STRING_CONSTANT(\"", name, "\", ", rval, ", CONST_CS | CONST_PERSISTENT);\n", 0);
			break;
		case T_POINTER:
		case T_ARRAY:
		case T_REFERENCE:
			Printf(f_cinit, "{\n\tchar *cp;\n");
			Printf(f_cinit, "\tSWIG_SetPointerChar(&cp, (void*)%s, SWIGTYPE%s);\n", value, SwigType_manglestr(type));
			Printv(f_cinit, "\tREGISTER_STRING_CONSTANT(\"", name, "\", cp,  CONST_CS | CONST_PERSISTENT);\n", 0);
			Printf(f_cinit, "}\n");
			break;
		default:
			break;
	}
	return SWIG_OK;

}
/*
void
PHP4::usage_func(char *iname, SwigType *, ParmList *l) {

	;
}
*/
int
PHP4::nativeWrapper(Node *) {

  return SWIG_OK;
}

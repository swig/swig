/* ----------------------------------------------------------------------------- 
 * perl5.cxx
 *
 *     Generate Perl5 wrappers
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *             Loic Dachary (loic@ceic.com)
 *             David Fletcher
 *             Gary Holt
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

/* DB: I had to take some features related to package naming out of this to
   get the new type system to work.   These need to be put back in at some point. */

static char cvsroot[] = "$Header$";

#include "mod11.h"
#include "perl5.h"

static char *usage = (char*)"\
Perl5 Options (available with -perl5)\n\
     -module name    - Set module name\n\
     -interface name - Set interface name\n\
     -package name   - Set package prefix\n\
     -static         - Omit code related to dynamic loading.\n\
     -shadow         - Create shadow classes.\n\
     -compat         - Compatibility mode.\n\n";

static String *import_file = 0;
static String *smodule = 0;
static int     compat = 0;

static int           export_all = 0;
static String       *package = 0;
static String       *module = 0;
static String       *interface = 0;
static String       *cmodule = 0;
static String       *vinit = 0;
static FILE         *f_pm = 0;
static String       *pm;             /* Package initialization code */
static String       *magic;          /* Magic variable wrappers     */

static int          is_static = 0;

/* The following variables are used to manage Perl5 classes */

static  int      blessed = 0;                /* Enable object oriented features */
static  Hash     *classes = 0;               /* A hash table for storing the classes we've seen so far */
static  Hash     *symbols = 0; 
static  int      have_constructor = 0;
static  int      have_destructor= 0;
static  int      have_data_members = 0;
static  String   *class_name = 0;            /* Name of the class (what Perl thinks it is) */
static  String   *class_type = 0;            /* Type of class "struct", "class", "union"   */
static  String   *real_classname = 0;        /* Real name of C/C++ class */
static  String   *base_class = 0;            /* Base class (if using inheritance) */
static  int class_renamed = 0;
static  String   *fullclassname = 0;

static  String   *pcode = 0;                 /* Perl code associated with each class */
static  String   *blessedmembers = 0;        /* Member data associated with each class */
static  int      member_func = 0;            /* Set to 1 when wrapping a member function */
static  String   *realpackage = 0;           /* Name of real module  */
static  String   *func_stubs = 0;         /* Function stubs */
static  String   *var_stubs = 0;          /* Variable stubs */
static  String   *member_keys = 0;        /* Keys for all member data */
static  String   *exported = 0;           /* Exported symbols */
static  String   *pragma_include = 0;


/* Test to see if a type corresponds to something wrapped with a shadow class */
static DOH *is_shadow(SwigType *t) {
  DOH *r;
  SwigType *lt = Swig_clocal_type(t);
  r = Getattr(classes,lt);
  Delete(lt);
  return r;
}

/* -----------------------------------------------------------------------------
 * PERL5::parse_args()
 * ----------------------------------------------------------------------------- */
void
PERL5::parse_args(int argc, char *argv[]) {
  int i = 1;

  cmodule = NewString("");
  strcpy(LibDir,"perl5");
  for (i = 1; i < argc; i++) {
      if (argv[i]) {
	  if(strcmp(argv[i],"-package") == 0) {
	    if (argv[i+1]) {
	      package = NewString(argv[i+1]);
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i++;
	    } else {
	      Swig_arg_error();
	    }
          } else if(strcmp(argv[i],"-interface") == 0) {
            if (argv[i+1]) {
              interface = NewString(argv[i+1]);
              Swig_mark_arg(i);
              Swig_mark_arg(i+1);
              i++;
            } else {
              Swig_arg_error();
            }
	  } else if (strcmp(argv[i],"-module") == 0) {
	    if (argv[i+1]) {
	      module = NewString(argv[i+1]);
	      Append(cmodule,module);
	      Replace(cmodule,":","_",DOH_REPLACE_ANY);
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i++;
	    } else {
	      Swig_arg_error();
	    }
	  } else if (strcmp(argv[i],"-exportall") == 0) {
	      export_all = 1;
	      Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-static") == 0) {
	      is_static = 1;
	      Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-shadow") == 0) {
	    blessed = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-compat") == 0) {
	    compat = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-help") == 0) {
	    fputs(usage,stderr);
	  }
      }
  }

  Preprocessor_define((void *) "SWIGPERL 1", 0);
  Preprocessor_define((void *) "SWIGPERL5 1", 0);
  typemap_lang = (char*)"perl5";
}

/* -----------------------------------------------------------------------------
 * PERL5::parse()
 * ----------------------------------------------------------------------------- */
void
PERL5::parse() {

  classes = NewHash();
  symbols = NewHash();
  
  vinit          = NewString("");
  pm             = NewString("");
  func_stubs     = NewString("");
  var_stubs      = NewString("");
  exported       = NewString("");
  magic          = NewString("");
  pragma_include = NewString("");

  Swig_banner(f_runtime);

  if (NoInclude) {
    Printf(f_header,"#define SWIG_NOINCLUDE\n");
  }

  if (Swig_insert_file("common.swg", f_runtime) == -1) {
    Printf(stderr,"SWIG : Fatal error.  Unable to locate 'common.swg' in SWIG library.\n");
    SWIG_exit(1);
  }

  if (Swig_insert_file("perl5.swg", f_runtime) == -1) {
    Printf(stderr,"SWIG : Fatal error.  Unable to locate 'perl5.swg' in SWIG library.\n");
    SWIG_exit(1);
  }
  yyparse();
}


/* -----------------------------------------------------------------------------
 * PERL5::set_module()
 * ----------------------------------------------------------------------------- */
void 
PERL5::set_module(char *mod_name) {
  if (import_file) {
    if (!(Cmp(import_file,input_file+strlen(input_file)-Len(import_file)))) {
      if (blessed) {
	Printf(f_pm,"require %s;\n", mod_name);
      }
      Delete(import_file);
      import_file = 0;
    }
  }

  if (module) return;
  
  module = NewString(mod_name);

  /* Create a C module name and put it in 'cmodule' */

  Clear(cmodule);
  Append(cmodule,module);
  Replace(cmodule,":","_",DOH_REPLACE_ANY);
}

/* -----------------------------------------------------------------------------
 * PERL5::initialize()
 * ----------------------------------------------------------------------------- */
void
PERL5::initialize()
{
  char filen[256];

  if (!module){
    Printf(stderr,"*** Error. No module name specified.\n");
    SWIG_exit(1);
  }

  if (!package) {
    package = NewString(module);
  }

  /* If we're in blessed mode, change the package name to "packagec" */

  if (blessed) {
    realpackage = package;
    package = interface ? interface : NewStringf("%sc",package);
  } else {
    realpackage = NewString(package);
  }

  /* Create a .pm file 
   * Need to strip off any prefixes that might be found in
   * the module name */

  {
    char *m = Char(module) + Len(module);
    while (m != Char(module)) {
      if (*m == ':') {
	m++;
	break;
      }
      m--;
    }
    sprintf(filen,"%s%s.pm", output_dir,m);
    if ((f_pm = fopen(filen,"w")) == 0) {
      Printf(stderr,"Unable to open %s\n", filen);
      SWIG_exit(0);
    }
  }
  if (!blessed) {
    smodule = NewString(module);
  } else if (is_static) {
    smodule = NewStringf("%sc",module);
    Append(cmodule,"c");
    Append(cmodule,"c");
  } else {
    smodule = NewString(module);
  }

  {
    String *tmp = NewString(realpackage);
    Replace(tmp,":","_", DOH_REPLACE_ANY);
    Printf(f_header,"#define SWIG_init    boot_%s\n\n", tmp);
    Printf(f_header,"#define SWIG_name   \"%s::boot_%s\"\n", package, tmp);
    Delete(tmp);
  }
  Printf(f_header,"#define SWIG_varinit \"%s::var_%s_init();\"\n", package, cmodule);
  Printf(f_header,"#ifdef __cplusplus\n");
  Printf(f_header,"extern \"C\"\n");
  Printf(f_header,"#endif\n");
  Printf(f_header,"#ifndef PERL_OBJECT\n");
  Printf(f_header,"SWIGEXPORT(void) SWIG_init (CV* cv);\n");
  Printf(f_header,"#else\n");
  Printf(f_header,"SWIGEXPORT(void) SWIG_init (CV *cv, CPerlObj *);\n");
  Printf(f_header,"#endif\n");
  Printf(f_init,"#ifdef __cplusplus\n");
  Printf(f_init,"extern \"C\"\n");
  Printf(f_init,"#endif\n");
  Printf(f_init,"XS(SWIG_init) {\n");
  Printf(f_init,"\t dXSARGS;\n");
  Printf(f_init,"\t int i;\n");
  Printf(f_init,"\t char *file = __FILE__;\n");
  Printf(f_init,"\t cv = cv; items = items;\n");
  Printv(f_init,
	 "for (i = 0; _swig_types_initial[i]; i++) {\n",
	 "_swig_types[i] = SWIG_TypeRegister(_swig_types_initial[i]);\n",
	 "}\n", 0);
  Printf(f_init,"\t newXS(\"%s::var_%s_init\", _wrap_perl5_%s_var_init, file);\n",package,cmodule, cmodule);

  Printv(vinit,
	 "XS(_wrap_perl5_", cmodule, "_var_init) {\n",
         tab4, "dXSARGS;\n",
	 tab4, "SV *sv;\n",
	 tab4, "cv = cv; items = items;\n",
	 0);

  Printf(f_pm,"# This file was automatically generated by SWIG\n");
  Printf(f_pm,"package %s;\n",realpackage);
  Printf(f_pm,"require Exporter;\n");
  if (!is_static) {
    Printf(f_pm,"require DynaLoader;\n");
    Printf(f_pm,"@ISA = qw(Exporter DynaLoader);\n");
  } else {
    Printf(f_pm,"@ISA = qw(Exporter);\n");
  }    

  /* Start creating magic code */

  Printv(magic,
	 "#ifdef PERL_OBJECT\n",
	 "#define MAGIC_CLASS _wrap_", module, "_var::\n",
	 "class _wrap_", module, "_var : public CPerlObj {\n",
	 "public:\n",
	 "#else\n",
	 "#define MAGIC_CLASS\n",
	 "#endif\n",
	 "SWIGCLASS_STATIC int swig_magic_readonly(SV *sv, MAGIC *mg) {\n",
	 tab4, "MAGIC_PPERL\n",
	 tab4, "sv = sv; mg = mg;\n",
	 tab4, "croak(\"Value is read-only.\");\n",
	 tab4, "return 0;\n",
	 "}\n",
	 0);
}

/* -----------------------------------------------------------------------------
 * PERL5::import()
 * ----------------------------------------------------------------------------- */
void
PERL5::import(char *filename) {
  if (import_file) Delete(import_file);
  import_file = NewString(filename);
}

/* -----------------------------------------------------------------------------
 * PERL5::close()
 * ----------------------------------------------------------------------------- */
void
PERL5::close(void) {
  String *base = NewString("");

  /* Dump out variable wrappers */

  Printv(magic,
	 "\n\n#ifdef PERL_OBJECT\n",
	 "};\n",
	 "#endif\n",
	 0);

  Printf(f_header,"%s\n", magic);
  
  String *type_table = NewString("");
  SwigType_emit_type_table(f_runtime,type_table);

  /* Patch the type table to reflect the names used by shadow classes */
  if (blessed) {
    SwigType *type;
    for (type = Firstkey(classes); type; type = Nextkey(classes)) {
      String *mangle = NewStringf("\"%s\"", SwigType_manglestr(type));
      String *rep = NewStringf("\"%s\"", Getattr(classes,type));
      Replace(type_table,mangle,rep,DOH_REPLACE_ANY);
      Delete(mangle);
      Delete(rep);
    }
  }

  Printf(f_wrappers,"%s",type_table);
  Delete(type_table);

  /*  Printf(stdout,"::: Perl shadow :::\n\n%s",classes); */

  Printf(f_init,"\t ST(0) = &PL_sv_yes;\n");
  Printf(f_init,"\t XSRETURN(1);\n");
  Printf(f_init,"}\n");

  Printv(vinit,tab4, "XSRETURN(1);\n", "}\n", 0);
  Printf(f_wrappers,"%s", vinit);

  Printf(f_pm,"package %s;\n", package);	

  if (!is_static) {
    Printf(f_pm,"bootstrap %s;\n", realpackage);
  } else {
    String *tmp = NewString(realpackage);
    Replace(tmp,":","_",DOH_REPLACE_ANY);
    Printf(f_pm,"boot_%s();\n", tmp);
    Delete(tmp);
  }
  Printf(f_pm,"var_%s_init();\n", cmodule);
  Printf(f_pm,"%s",pragma_include);
  Printf(f_pm,"package %s;\n", realpackage);
  Printf(f_pm,"@EXPORT = qw(%s );\n",exported);

  if (blessed) {

    Printv(base,
	   "\n# ---------- BASE METHODS -------------\n\n",
	   "package ", realpackage, ";\n\n",
	   0);

    /* Write out the TIE method */

    Printv(base,
	   "sub TIEHASH {\n",
	   tab4, "my ($classname,$obj) = @_;\n",
	   tab4, "return bless $obj, $classname;\n",
	   "}\n\n",
	   0);

    /* Output a CLEAR method.   This is just a place-holder, but by providing it we 
     * can make declarations such as
     *     %$u = ( x => 2, y=>3, z =>4 );
     *
     * Where x,y,z are the members of some C/C++ object. */

    Printf(base,"sub CLEAR { }\n\n");

    /* Output default firstkey/nextkey methods */

    Printf(base, "sub FIRSTKEY { }\n\n");
    Printf(base, "sub NEXTKEY { }\n\n");

    /* Output a 'this' method */

    Printv(base,
	   "sub this {\n",
	   tab4, "my $ptr = shift;\n",
	   tab4, "return tied(%$ptr);\n",
	   "}\n\n",
	   0);

    Printf(f_pm,"%s",base);

    /* Emit function stubs for stand-alone functions */

    Printf(f_pm,"\n# ------- FUNCTION WRAPPERS --------\n\n");
    Printf(f_pm,"package %s;\n\n",realpackage);
    Printf(f_pm,"%s",func_stubs);

    /* Emit package code for different classes */

    Printf(f_pm,"%s",pm);

    /* Emit variable stubs */

    Printf(f_pm,"\n# ------- VARIABLE STUBS --------\n\n");
    Printf(f_pm,"package %s;\n\n",realpackage);
    Printf(f_pm,"%s",var_stubs);
  }

  Printf(f_pm,"1;\n");
  fclose(f_pm);
  Delete(base);
}

/* -----------------------------------------------------------------------------
 * get_pointer()
 * ----------------------------------------------------------------------------- */
static void
get_pointer(char *iname, char *srcname, char *src, char *dest,
	    SwigType *t, String *f, char *ret) {

  SwigType_remember(t);
  Printv(f, "if (SWIG_ConvertPtr(", src, ",(void **) &", dest, ",", 0);

  /* If we're passing a void pointer, we give the pointer conversion a NULL
     pointer, otherwise pass in the expected type. */
  
  if (SwigType_type(t) == T_VOID) Printf(f, " 0 ) < 0) {\n");
  else 
    Printv(f, "SWIGTYPE", SwigType_manglestr(t), ") < 0) {\n",0);

  Printv(f,
	 "croak(\"Type error in ", srcname, " of ", iname,". Expected %s\", SWIGTYPE",
	 SwigType_manglestr(t), "->name);\n",
	 ret, ";\n",
	 "}\n",
	 0);
}

/* -----------------------------------------------------------------------------
 * PERL5::create_command()
 * ----------------------------------------------------------------------------- */
void
PERL5::create_command(char *cname, char *iname) {
  Printf(f_init,"\t newXS(\"%s::%s\", %s, file);\n", package, iname, Swig_name_wrapper(cname));
  if (export_all) {
    Printf(exported,"%s ",iname);
  }
}

/* ----------------------------------------------------------------------------- 
 * PERL5::create_function()
 * ----------------------------------------------------------------------------- */
void
PERL5::create_function(char *name, char *iname, SwigType *d, ParmList *l)
{
  Parm *p;
  int   pcount,i,j;
  Wrapper *f;
  char  source[256],target[256],temp[256], argnum[32];
  char  *tm;
  String *cleanup, *outarg;
  int    numopt = 0;
  int    need_save, num_saved = 0;          

  f       = NewWrapper();
  cleanup = NewString("");
  outarg  = NewString("");

  Printv(f->def, "XS(", Swig_name_wrapper(iname), ") {\n", 0);
  Printv(f->code, tab4, "cv = cv;\n", 0);

  pcount = emit_args(d, l, f);
  numopt = check_numopt(l);

  Wrapper_add_local(f,"argvi","int argvi = 0");

  /* Check the number of arguments */

  Printf(f->code,"    if ((items < %d) || (items > %d)) \n", pcount-numopt, ParmList_numarg(l));
  Printf(f->code,"        croak(\"Usage: %s\");\n", usage_func(iname,d,l));

  /* Write code to extract parameters. */
  i = 0;
  j = 0;
  for (p = l; p; p = Getnext(p)) {
    SwigType *pt = Gettype(p);
    String   *pn = Getname(p);

    /* Produce string representation of source and target arguments */
    sprintf(source,"ST(%d)",j);
    sprintf(target,"%s", Char(Getlname(p)));
    sprintf(argnum,"%d",j+1);

    /* Check to see if this argument is being ignored */
    if (!Getignore(p)) {
      /* Check for optional argument */
      if (j>= (pcount-numopt))
	Printf(f->code,"    if (items > %d) {\n", j);

      if ((tm = Swig_typemap_lookup((char*)"in",pt,pn,source,target,f))) {
	Printf(f->code,"%s\n",tm);
	Replace(f->code,"$argnum",argnum,DOH_REPLACE_ANY);
	Replace(f->code,"$arg",source,DOH_REPLACE_ANY);
      } else {
	switch(SwigType_type(pt)) {
	case T_BOOL:
	case T_INT :
	case T_SHORT :
	case T_LONG :
	case T_SCHAR:
	case T_UINT:
	case T_USHORT:
	case T_ULONG:
	case T_UCHAR:
	  Printf(f->code,"    %s = (%s)SvIV(ST(%d));\n", target, SwigType_lstr(pt,0),j);
	  break;
	case T_CHAR :
	  
	  Printf(f->code,"    %s = (char) *SvPV(ST(%d),PL_na);\n", target, j);
	  break;
	  
	case T_DOUBLE :
	case T_FLOAT :
	  Printf(f->code,"    %s = (%s)SvNV(ST(%d));\n", target, SwigType_lstr(pt,0), j);
	  break;
	  
	case T_VOID :
	  break;
	  
	case T_USER:
	  SwigType_add_pointer(pt);
	  sprintf(temp,"argument %d", i+1);
	  get_pointer(iname, temp, source, target, pt, f->code, (char *)"XSRETURN(1)");
	  SwigType_del_pointer(pt);
	  break;

	case T_STRING:
	  Printf(f->code,"    if (! SvOK((SV*) ST(%d))) { %s = 0; }\n", j, target);
	  Printf(f->code,"    else { %s = (char *) SvPV(ST(%d),PL_na); }\n", target,j);
	  break;

	case T_POINTER: case T_ARRAY: case T_REFERENCE:
	  sprintf(temp,"argument %d", i+1);
	  get_pointer(iname,temp,source,target, pt, f->code, (char*)"XSRETURN(1)");
	  break;

	default :
	  Printf(stderr,"%s : Line %d. Unable to use type %s as a function argument.\n",input_file, line_number, SwigType_str(pt,0));
	  break;
	}
      }
      /* The source is going to be an array of saved values. */
      sprintf(temp,"_saved[%d]",num_saved);      
      if (j>= (pcount-numopt))
	Printf(f->code,"    } \n");
      j++;
    } else {
      temp[0] = 0;
    }

    /* Check if there is any constraint code */
    if ((tm = Swig_typemap_lookup((char*)"check",pt,pn,source,target,0))) {
      Printf(f->code,"%s\n", tm);
      Replace(f->code,"$argnum",argnum, DOH_REPLACE_ANY);
    }
    need_save = 0;

    if ((tm = Swig_typemap_lookup((char*)"freearg",pt,pn,target,temp,0))) {
      Printf(cleanup,"%s\n", tm);
      Replace(cleanup,"$argnum",argnum,DOH_REPLACE_ANY);
      Replace(cleanup,"$arg",temp,DOH_REPLACE_ANY);
      need_save = 1;
    }
    if ((tm = Swig_typemap_lookup((char*)"argout",pt,pn,target,(char*)"ST(argvi)",0))) {
      String *tempstr = NewString(tm);
      Replace(tempstr,"$argnum",argnum, DOH_REPLACE_ANY);
      Replace(tempstr,"$arg",temp, DOH_REPLACE_ANY);
      Printf(outarg,"%s\n", tempstr);
      Delete(tempstr);
      need_save = 1;
    }
    /* If we need a saved variable, we need to emit to emit some code for that 
       This only applies if the argument actually existed (not ignore) */
    if ((need_save) && (!Getignore(p))) {
      Printv(f->code, tab4, temp, " = ", source, ";\n", 0);
      num_saved++;
    }
    i++;
  }

  /* If there were any saved arguments, emit a local variable for them */
  if (num_saved) {
    sprintf(temp,"_saved[%d]",num_saved);
    Wrapper_add_localv(f,"_saved","SV *",temp,0);
  }

  /* Now write code to make the function call */

  emit_func_call(name,d,l,f);

  if ((tm = Swig_typemap_lookup((char*)"out",d,iname,(char*)"result",(char*)"ST(argvi)",0))) {
    Printf(f->code, "%s\n", tm);
  } else {
    if (SwigType_type(d) != T_VOID) {
      Printf(f->code,"    ST(argvi) = sv_newmortal();\n");
      switch (SwigType_type(d)) {
      case T_INT: case T_BOOL: case T_UINT:
      case T_SHORT: case T_USHORT:
      case T_LONG : case T_ULONG:
      case T_SCHAR: case T_UCHAR :
	Printf(f->code,"    sv_setiv(ST(argvi++),(IV) result);\n");
	break;
      case T_DOUBLE :
      case T_FLOAT :
	Printf(f->code,"    sv_setnv(ST(argvi++), (double) result);\n");
	break;
      case T_CHAR :
	Wrapper_add_local(f,"_ctemp", "char ctemp[2]");
	Printv(f->code,
	       tab4, "ctemp[0] = result;\n",
	       tab4, "ctemp[1] = 0;\n",
	       tab4, "sv_setpv((SV*)ST(argvi++),ctemp);\n",
	       0);
	break;
	
      case T_USER:
	SwigType_add_pointer(d);
	SwigType_remember(d);
	Printv(f->code,
	       tab4, "SWIG_MakePtr(ST(argvi++), (void *) result, SWIGTYPE", SwigType_manglestr(d),");\n", 0);
	SwigType_del_pointer(d);
	break;
	
      case T_STRING:
	Printf(f->code,"    sv_setpv((SV*)ST(argvi++),(char *) result);\n");
	break;

      case T_POINTER: case T_ARRAY: case T_REFERENCE:
	SwigType_remember(d);
	Printv(f->code, tab4, "SWIG_MakePtr(ST(argvi++), (void *) result, SWIGTYPE", SwigType_manglestr(d), ");\n", 0);
	break;

      default :
	Printf(stderr,"%s: Line %d. Unable to use return type %s in function %s.\n", input_file, line_number, SwigType_str(d,0), name);
	break;
      }
    }
  }

  /* If there were any output args, take care of them. */
  
  Printv(f->code,outarg,0);

  /* If there was any cleanup, do that. */

  Printv(f->code,cleanup,0);

  if (NewObject) {
    if ((tm = Swig_typemap_lookup((char*)"newfree",d,iname,(char*)"result",(char*)"",0))) {
      Printf(f->code,"%s\n",tm);
    }
  }

  if ((tm = Swig_typemap_lookup((char*)"ret",d,iname,(char*)"result",(char*)"",0))) {
    Printf(f->code,"%s\n", tm);
  }

  Printf(f->code,"    XSRETURN(argvi);\n}\n");

  /* Add the dXSARGS last */

  Wrapper_add_local(f,"dXSARGS","dXSARGS");

  /* Substitute the cleanup code */
  Replace(f->code,"$cleanup",cleanup,DOH_REPLACE_ANY);
  Replace(f->code,"$name",iname,DOH_REPLACE_ANY);

  /* Dump the wrapper function */

  Wrapper_print(f,f_wrappers);

  /* Now register the function */

  Printf(f_init,"\t newXS(\"%s::%s\", %s, file);\n", package, iname, Swig_name_wrapper(iname));

  if (export_all) {
    Printf(exported,"%s ", iname);
  }


  /* --------------------------------------------------------------------
   * Create a stub for this function, provided it's not a member function
   *
   * Really we only need to create a stub if this function involves
   * complex datatypes.   If it does, we'll make a small wrapper to 
   * process the arguments.   If it doesn't, we'll just make a symbol
   * table entry.
   * -------------------------------------------------------------------- */

  if ((blessed) && (!member_func)) {
    int    need_stub = 0;
    String *func = NewString("");
    
    /* We'll make a stub since we may need it anyways */

    Printv(func, "sub ", iname, " {\n",
	   tab4, "my @args = @_;\n",
	   0);

    /* Now we have to go through and patch up the argument list.  If any
     * arguments to our function correspond to other Perl objects, we
     * need to extract them from a tied-hash table object.*/

    Parm *p = l;
    int i = 0;
    while(p) {
      SwigType *pt = Gettype(p);

      if (!Getignore(p)) {
	/* Look up the datatype name here */
	char sourceNtarget[256];
	sprintf(sourceNtarget,"$args[%d]",i);

	if ((tm = Swig_typemap_lookup((char*)"perl5in",pt,(char*)"",sourceNtarget,sourceNtarget,0))) {
	  Printf(func,"%s\n", tm);
	} else if (is_shadow(pt)) {
	  /*
	  if (i >= (pcount - numopt))
	    Printf(func,"    if (scalar(@args) >= %d) {\n    ", i);
	  Printf(func,"    $args[%d] = tied(%%{$args[%d]});\n", i, i);
	  if (i >= (pcount - numopt))
	    Printf(func,"    }\n");
	  need_stub = 1;
	  */
	}
	i++;
      }
      p = Getnext(p);
    }

    Printv(func, tab4, "my $result = ", package, "::", iname, "(@args);\n", 0);

    /* Now check to see what kind of return result was found.
     * If this function is returning a result by 'value', SWIG did an 
     * implicit malloc/new.   We'll mark the object like it was created
     * in Perl so we can garbage collect it. */

    if ((tm = Swig_typemap_lookup((char*)"perl5out",d,(char*)"",name,(char*)"sv",0))) {
      Printv(func,
	     tm, "\n",
	     tab4, "return $result;\n",
	     "}\n",
	     0);
      need_stub = 1;
    } else if (is_shadow(d)) {
      Printv(func, tab4, "return undef if (!defined($result));\n", 0);

      /* If we're returning an object by value, put it's reference
         into our local hash table */

      if ((!SwigType_ispointer(d)) || NewObject) {
	Printv(func, tab4, "$", is_shadow(d), "::OWNER{$result} = 1;\n", 0);
      }

      /* We're returning a Perl "object" of some kind.  Turn it into a tied hash */

      Printv(func,
	     tab4, "my %resulthash;\n",
	     tab4, "tie %resulthash, ref($result), $result;\n",
	     tab4, "return bless \\%resulthash, ref($result);\n",
	     "}\n",
	     0);

      need_stub = 1;
    } else {

      /* Hmmm.  This doesn't appear to be anything I know about */
      Printv(func, tab4, "return $result;\n", "}\n", 0);
    }

    /* Now check if we needed the stub.  If so, emit it, otherwise
     * Emit code to hack Perl's symbol table instead */

    if (need_stub) {
      Printf(func_stubs,"%s",func);
    } else {
      Printv(func_stubs,"*", iname, " = *", package, "::", iname, ";\n", 0);
    }
    Delete(func);
  }
  Delete(cleanup);
  Delete(outarg);
  DelWrapper(f);
}

/* ----------------------------------------------------------------------------- 
 * PERL5::link_variable()
 * ----------------------------------------------------------------------------- */

void PERL5::link_variable(char *name, char *iname, SwigType *t)
{
  char  set_name[256];
  char  val_name[256];
  Wrapper  *getf, *setf;
  char  *tm;
  int   setable = 1;

  sprintf(set_name,"_wrap_set_%s",iname);
  sprintf(val_name,"_wrap_val_%s",iname);

  getf = NewWrapper();
  setf = NewWrapper();

  /* Create a new scalar that we will attach magic to */

  Printv(vinit, tab4, "sv = perl_get_sv(\"", package, "::", iname, "\",TRUE | 0x2);\n", 0);

  /* Create a Perl function for setting the variable value */

  if (!(Status & STAT_READONLY)) {
    Printf(setf->def,"SWIGCLASS_STATIC int %s(SV* sv, MAGIC *mg) {\n", set_name);
    Printv(setf->code,
	   tab4, "MAGIC_PPERL\n",
	   tab4, "mg = mg;\n",
	   0);

    /* Check for a few typemaps */
    if ((tm = Swig_typemap_lookup((char*)"varin",t,(char*)"",(char*)"sv",name,0))) {
      Printf(setf->code,"%s\n", tm);
    } else if ((tm = Swig_typemap_lookup((char*)"in",t,(char*)"",(char*)"sv",name,0))) {
      Printf(setf->code,"%s\n", tm);
    } else {
      switch(SwigType_type(t)) {
      case T_INT : case T_BOOL: case T_UINT:
      case T_SHORT : case T_USHORT:
      case T_LONG : case T_ULONG:
      case T_UCHAR: case T_SCHAR:
	Printv(setf->code,tab4, name, " = (", SwigType_str(t,0), ") SvIV(sv);\n", 0);
	break;
      case T_DOUBLE :
      case T_FLOAT :
	Printv(setf->code, tab4, name, " = (", SwigType_str(t,0), ") SvNV(sv);\n", 0);
	break;
      case T_CHAR :
	Printv(setf->code, tab4, name, " = (char) *SvPV(sv,PL_na);\n", 0);
	break;
	
      case T_USER:
	
	SwigType_add_pointer(t);
	Wrapper_add_local(setf,"_temp", "void *_temp");
	get_pointer(iname,(char*)"value",(char*)"sv",(char*)"_temp", t, setf->code, (char*)"return(1)");
	Printv(setf->code, tab4, name, " = *((", SwigType_str(t,0), ") _temp);\n", 0);
	SwigType_del_pointer(t);
	break;

      case T_STRING:
	Wrapper_add_local(setf,"_a","char *_a");
	Printf(setf->code,"    _a = (char *) SvPV(sv,PL_na);\n");
	
	if (CPlusPlus)
	  Printv(setf->code,
		 tab4, "if (", name, ") delete [] ", name, ";\n",
		 tab4, name, " = new char[strlen(_a)+1];\n",
		 0);
	else
	  Printv(setf->code,
		 tab4, "if (", name, ") free((char*)", name, ");\n",
		 tab4, name, " = (char *) malloc(strlen(_a)+1);\n",
		 0);
	Printv(setf->code,"strcpy((char*)", name, ",_a);\n", 0);
	break;

      case T_ARRAY:
	  {
	    SwigType *aop;
	    SwigType *ta = Copy(t);
	    aop = SwigType_pop(ta);
	    if (SwigType_type(ta) == T_CHAR) {
	      String *dim = SwigType_array_getdim(aop,0);
	      if (dim && Len(dim)) {
		Printf(setf->code, "strncpy(%s,(char*) SvPV(sv,PL_na), %s);\n", name,dim);
		setable = 1;
	      } else {
		setable = 0;
	      }
	    }  else {
	      setable = 0;
	    }
	    Delete(ta);
	    Delete(aop);
	  }
	  break;

      case T_POINTER: case T_REFERENCE:
	Wrapper_add_local(setf,"_temp","void *_temp");
	get_pointer(iname,(char*)"value",(char*)"sv",(char*)"_temp", t, setf->code, (char*)"return(1)");
	Printv(setf->code,tab4, name, " = (", SwigType_str(t,0), ") _temp;\n", 0);
	break;

      default :
	Printf(stderr,"%s : Line %d.  Unable to link with datatype %s (ignored).\n", input_file, line_number, SwigType_str(t,0));
	return;
      }
    }
    Printf(setf->code,"    return 1;\n}\n");
    Replace(setf->code,"$name",iname, DOH_REPLACE_ANY);
    Wrapper_print(setf,magic);
    
  }

  /* Now write a function to evaluate the variable */
  
  Printf(getf->def,"SWIGCLASS_STATIC int %s(SV *sv, MAGIC *mg) {\n", val_name);
  Printv(getf->code,
	 tab4, "MAGIC_PPERL\n",
	 tab4, "mg = mg;\n",
	 0);

  if ((tm = Swig_typemap_lookup((char*)"varout",t,(char*)"",name, (char*)"sv",0))) {
    Printf(getf->code,"%s\n", tm);
  } else  if ((tm = Swig_typemap_lookup((char*)"out",t,(char*)"",name,(char*)"sv",0))) {
    Printf(getf->code,"%s\n", tm);
  } else {
    switch(SwigType_type(t)) {
      
    case T_INT : case T_BOOL: case T_UINT:
    case T_SHORT : case T_USHORT:
    case T_LONG : case T_ULONG:
    case T_UCHAR: case T_SCHAR:
      Printv(getf->code,tab4, "sv_setiv(sv, (IV) ", name, ");\n", 0);
      Printv(vinit, tab4, "sv_setiv(sv,(IV)", name, ");\n",0);
      break;
    case T_DOUBLE :
    case T_FLOAT :
      Printv(getf->code, tab4,"sv_setnv(sv, (double) ", name, ");\n", 0);
      Printv(vinit, tab4, "sv_setnv(sv,(double)", name, ");\n",0);
      break;
    case T_CHAR :
      Wrapper_add_local(getf,"_ptemp","char _ptemp[2]");
      Printv(getf->code,
	     tab4, "_ptemp[0] = ", name, ";\n",
	     tab4, "_ptemp[1] = 0;\n",
	     tab4, "sv_setpv((SV*) sv, _ptemp);\n",
	     0);
      break;
    case T_USER:
      SwigType_add_pointer(t);
      Printv(getf->code,
	     tab4, "rsv = SvRV(sv);\n",
	     tab4, "sv_setiv(rsv,(IV) &", name, ");\n",
	     0);
      
      Wrapper_add_local(getf,"rsv","SV *rsv");
      Printv(vinit, tab4, "SWIG_MakePtr(sv, (void *) &", name, ",SWIGTYPE", SwigType_manglestr(t), ");\n",0);
      SwigType_del_pointer(t);
      
      break;

    case T_STRING:
      Printv(getf->code, tab4, "sv_setpv((SV*) sv, ", name, ");\n", 0);
      break;

    case T_ARRAY:
	  {
	    SwigType *aop;
	    SwigType *ta = Copy(t);
	    aop = SwigType_pop(ta);
	    if (SwigType_type(ta) == T_CHAR) {
	      Printv(getf->code, "sv_setpv((SV*)sv, ", name, ");\n", 0);
	      Delete(ta);
	      Delete(aop);
	      break;
	    } 
	    Delete(ta);
	    Delete(aop);
	  }
	  /* No break here is intentional */
    case T_POINTER: case T_REFERENCE:
      Printv(getf->code,
	     tab4, "rsv = SvRV(sv);\n",
	     tab4, "sv_setiv(rsv,(IV) ", name, ");\n",
	     0);
      
      Wrapper_add_local(getf,"rsv","SV *rsv");
      Printv(vinit, tab4, "SWIG_MakePtr(sv,(void *) 1, SWIGTYPE", SwigType_manglestr(t), ");\n",0);
      break;

    default :
      break;
    }
  }
  Printf(getf->code,"    return 1;\n}\n");

  Replace(getf->code,"$name",iname, DOH_REPLACE_ANY);
  Wrapper_print(getf,magic);
  
  /* Now add symbol to the PERL interpreter */
  if ((Status & STAT_READONLY) || (!setable)) {
    Printv(vinit, tab4, "swig_create_magic(sv,\"", package, "::", iname, "\",MAGIC_CAST MAGIC_CLASS swig_magic_readonly, MAGIC_CAST MAGIC_CLASS ", val_name, ");\n",0);
  } else {
    Printv(vinit, tab4, "swig_create_magic(sv,\"", package, "::", iname, "\", MAGIC_CAST MAGIC_CLASS ", set_name, ", MAGIC_CAST MAGIC_CLASS ", val_name, ");\n",0);
  }      
  
  /* If we're blessed, try to figure out what to do with the variable
       1.  If it's a Perl object of some sort, create a tied-hash
           around it.
	   2.  Otherwise, just hack Perl's symbol table */
  
  if (blessed) {
    if (is_shadow(t)) {
      Printv(var_stubs,
	     "\nmy %__", iname, "_hash;\n",
	     "tie %__", iname, "_hash,\"", is_shadow(t), "\", $",
	     package, "::", iname, ";\n",
	     "$", iname, "= \\%__", iname, "_hash;\n",
	     "bless $", iname, ", ", is_shadow(t), ";\n",
	     0);
    } else {
      Printv(var_stubs, "*", iname, " = *", package, "::", iname, ";\n", 0);
    }
    if (export_all)
      Printf(exported,"$%s ", name);
  }
  DelWrapper(setf);
  DelWrapper(getf);
}

/* -----------------------------------------------------------------------------
 * PERL5::declare_const()
 * ----------------------------------------------------------------------------- */

/* Functions used to create constants */

static const char *setiv = "#ifndef PERL_OBJECT\
\n#define swig_setiv(a,b) _swig_setiv(a,b)\
\nstatic void _swig_setiv(char *name, long value) { \
\n#else\
\n#define swig_setiv(a,b) _swig_setiv(pPerl,a,b)\
\nstatic void _swig_setiv(CPerlObj *pPerl, char *name, long value) { \
\n#endif\
\n     SV *sv; \
\n     sv = perl_get_sv(name,TRUE | 0x2);\
\n     sv_setiv(sv, (IV) value);\
\n     SvREADONLY_on(sv);\
\n}\n";

static const char *setnv = "#ifndef PERL_OBJECT\
\n#define swig_setnv(a,b) _swig_setnv(a,b)\
\nstatic void _swig_setnv(char *name, double value) { \
\n#else\
\n#define swig_setnv(a,b) _swig_setnv(pPerl,a,b)\
\nstatic void _swig_setnv(CPerlObj *pPerl, char *name, double value) { \
\n#endif\
\n     SV *sv; \
\n     sv = perl_get_sv(name,TRUE | 0x2);\
\n     sv_setnv(sv, value);\
\n     SvREADONLY_on(sv);\
\n}\n";

static const char *setpv = "#ifndef PERL_OBJECT\
\n#define swig_setpv(a,b) _swig_setpv(a,b)\
\nstatic void _swig_setpv(char *name, char *value) { \
\n#else\
\n#define swig_setpv(a,b) _swig_setpv(pPerl,a,b)\
\nstatic void _swig_setpv(CPerlObj *pPerl, char *name, char *value) { \
\n#endif\
\n     SV *sv; \
\n     sv = perl_get_sv(name,TRUE | 0x2);\
\n     sv_setpv(sv, value);\
\n     SvREADONLY_on(sv);\
\n}\n";

static const char *setrv = "#ifndef PERL_OBJECT\
\n#define swig_setrv(a,b,c) _swig_setrv(a,b,c)\
\nstatic void _swig_setrv(char *name, void *value, char *type) { \
\n#else\
\n#define swig_setrv(a,b,c) _swig_setrv(pPerl,a,b,c)\
\nstatic void _swig_setrv(CPerlObj *pPerl, char *name, void *value, char *type) { \
\n#endif\
\n     SV *sv; \
\n     sv = perl_get_sv(name,TRUE | 0x2);\
\n     sv_setref_pv(sv, type, value);\
\n     SvREADONLY_on(sv);\
\n}\n";

void
PERL5::declare_const(char *name, char *, SwigType *type, char *value)
  {

  char   *tm;
  static  int have_int_func = 0;
  static  int have_double_func = 0;
  static  int have_char_func = 0;
  static  int have_ref_func = 0;

  if ((tm = Swig_typemap_lookup((char*)"const",type,name,value,name,0))) {
    Printf(f_init,"%s\n",tm);
  } else {
    switch(SwigType_type(type)) {
    case T_INT: case T_UINT: case T_BOOL:
    case T_SHORT: case T_USHORT:
    case T_LONG:  case T_ULONG:
    case T_SCHAR: case T_UCHAR:
      if (!have_int_func) {
	Printf(f_header,"%s\n",setiv);
	have_int_func = 1;
      }
      Printv(vinit, tab4, "swig_setiv(\"", package, "::", name, "\", (long) ", value, ");\n",0);
      break;
    case T_DOUBLE:
    case T_FLOAT:
      if (!have_double_func) {
	Printf(f_header,"%s\n",setnv);
	have_double_func = 1;
      }
      Printv(vinit, tab4, "swig_setnv(\"", package, "::", name, "\", (double) (", value, "));\n",0);
      break;
    case T_CHAR :
      if (!have_char_func) {
	Printf(f_header,"%s\n",setpv);
	have_char_func = 1;
      }
      Printf(vinit,"    swig_setpv(\"%s::%s\",\"%s\");\n", package, name, value);

      break;
    case T_STRING:
      if (!have_char_func) {
	Printf(f_header,"%s\n",setpv);
	have_char_func = 1;
      }
      Printf(vinit,"    swig_setpv(\"%s::%s\",\"%s\");\n", package, name, value);
      break;

    case T_POINTER: case T_ARRAY: case T_REFERENCE:
      if (!have_ref_func) {
	Printf(f_header,"%s\n",setrv);
	have_ref_func = 1;
      }
      Printv(vinit, tab4, "swig_setrv(\"", package, "::", name, "\", (void *) ", value, ", \"", 
	     SwigType_manglestr(type), "\");\n", 0);
      break;

    default:
      Printf(stderr,"%s : Line %d. Unsupported constant value.\n", input_file, line_number);
      break;
    }
  }

  if (blessed) {
    if (is_shadow(type)) {
      Printv(var_stubs,
	     "\nmy %__", name, "_hash;\n",
	     "tie %__", name, "_hash,\"", is_shadow(type), "\", $",
	     package, "::", name, ";\n",
	     "$", name, "= \\%__", name, "_hash;\n",
	     "bless $", name, ", ", is_shadow(type), ";\n",
	     0);
    } else {
      Printv(var_stubs, "*",name," = *", package, "::", name, ";\n", 0);
    }
  }
  if (export_all)
    Printf(exported,"$%s ",name);
}

/* -----------------------------------------------------------------------------
 * PERL5::usage_func() 
 * ----------------------------------------------------------------------------- */
char *
PERL5::usage_func(char *iname, SwigType *, ParmList *l) {
  static String *temp = 0;
  Parm  *p;
  int    i;

  if (!temp) temp = NewString("");
  Clear(temp);
  Printf(temp,"%s(",iname);
  
  /* Now go through and print parameters */
  p = l;
  i = 0;
  while (p != 0) {
    SwigType *pt = Gettype(p);
    String   *pn = Getname(p);
    if (!Getignore(p)) {
      /* If parameter has been named, use that.   Otherwise, just print a type  */
      if (SwigType_type(pt) != T_VOID) {
	if (Len(pn) > 0) {
	  Printf(temp,"%s",pn);
	} else {
	  Printf(temp,"%s",SwigType_str(pt,0));
	}
      }
      i++;
      p = Getnext(p);
      if (p)
	if (!Getignore(p))
	  Putc(',',temp);
    } else {
      p = Getnext(p);
      if (p) 
	if ((i>0) && (!Getignore(p)))
	  Putc(',',temp);
    }
  }
  Printf(temp,");");
  return Char(temp);
}

/* -----------------------------------------------------------------------------
 * PERL5::add_native()
 * ----------------------------------------------------------------------------- */
void
PERL5::add_native(char *name, char *funcname, SwigType *, ParmList *) {
  Printf(f_init,"\t newXS(\"%s::%s\", %s, file);\n", package,name, funcname);
  if (export_all)
    Printf(exported,"%s ",name);
  if (blessed) {
    Printv(func_stubs,"*", name, " = *", package, "::", name, ";\n", 0);
  }
}

/****************************************************************************
 ***                      OBJECT-ORIENTED FEATURES                        
 ****************************************************************************
 *** These extensions provide a more object-oriented interface to C++     
 *** classes and structures.    The code here is based on extensions      
 *** provided by David Fletcher and Gary Holt.
 ***                                                                      
 *** I have generalized these extensions to make them more general purpose   
 *** and to resolve object-ownership problems.                            
 ***
 *** The approach here is very similar to the Python module :             
 ***       1.   All of the original methods are placed into a single      
 ***            package like before except that a 'c' is appended to the  
 ***            package name.                                             
 ***
 ***       2.   All methods and function calls are wrapped with a new     
 ***            perl function.   While possibly inefficient this allows   
 ***            us to catch complex function arguments (which are hard to
 ***            track otherwise).
 ***
 ***       3.   Classes are represented as tied-hashes in a manner similar
 ***            to Gary Holt's extension.   This allows us to access
 ***            member data.
 ***
 ***       4.   Stand-alone (global) C functions are modified to take
 ***            tied hashes as arguments for complex datatypes (if
 ***            appropriate).
 ***
 ***       5.   Global variables involving a class/struct is encapsulated
 ***            in a tied hash.
 ***
 ***       6.   Object ownership is maintained by having a hash table
 ***            within in each package called "this".  It is unlikely
 ***            that C++ program will use this so it's a somewhat 
 ***            safe variable name.
 ***
 ****************************************************************************/

/* -----------------------------------------------------------------------------
 * PERL5::cpp_open_class()
 * ----------------------------------------------------------------------------- */
void
PERL5::cpp_open_class(char *classname, char *rname, char *ctype, int strip) {

  this->Language::cpp_open_class(classname, rname, ctype, strip);
  if (blessed) {
    have_constructor = 0;
    have_destructor = 0;
    have_data_members = 0;

    Delete(class_name);     class_name = 0;
    Delete(class_type);     class_type =0;
    Delete(real_classname); real_classname = 0;
    Delete(base_class);     base_class = 0;
    Delete(fullclassname);  fullclassname = 0;
    
    /* If the class is being renamed to something else, use the renaming */
    if (rname) {
      class_name = NewString(rname);
      class_renamed = 1;
    } else {
      class_name = NewString(classname);
      class_renamed = 0;
    }

    /* Use the fully qualified name of the Perl class */
    if (!compat) {
      fullclassname = NewStringf("%s::%s",realpackage,class_name);
    } else {
      fullclassname = NewString(class_name);
    }
    real_classname = NewString(classname);
    if (base_class) Delete(base_class);
    base_class =  0;
    class_type = NewString(ctype);
    pcode = NewString("");
    blessedmembers = NewString("");
    member_keys = NewString("");

    /* Add some symbols to the hash tables */
    cpp_class_decl(Char(classname),Char(fullclassname),Char(ctype));
  }
}

/* -----------------------------------------------------------------------------
 * PERL5::cpp_close_class()
 * ----------------------------------------------------------------------------- */
void
PERL5::cpp_close_class() {

  if (blessed) {
    Printv(pm,
	   "\n############# Class : ", fullclassname, " ##############\n",
	   "\npackage ", fullclassname, ";\n",
	   0);

    /* If we are inheriting from a base class, set that up */

    if (Cmp(class_name,realpackage))
      Printv(pm, "@ISA = qw( ",realpackage, 0);
    else 
      Printv(pm, "@ISA = qw( ", 0);

    if (base_class) {
      Printv(pm, " ", base_class, 0);
    }
    Printf(pm, " );\n");

    /* Dump out a hash table containing the pointers that we own */

    Printf(pm, "%%OWNER = ();\n");
    if (have_data_members) {
      Printv(pm, 
	     "%BLESSEDMEMBERS = (\n", blessedmembers, ");\n\n",
	     0);
    }
    if (have_data_members || have_destructor)
      Printf(pm, "%%ITERATORS = ();\n");


    /* Dump out the package methods */

    Printv(pm,pcode,0);
    Delete(pcode);

    /* Output methods for managing ownership */

    Printv(pm,
	   "sub DISOWN {\n",
	   tab4, "my $self = shift;\n",
	   tab4, "my $ptr = tied(%$self);\n",
	   tab4, "delete $OWNER{$ptr};\n",
	   tab4, "};\n\n",
	   "sub ACQUIRE {\n",
	   tab4, "my $self = shift;\n",
	   tab4, "my $ptr = tied(%$self);\n",
	   tab4, "$OWNER{$ptr} = 1;\n",
	   tab4, "};\n\n",
	   0);

    /* Only output the following methods if a class has member data */

    if (have_data_members) {

      /* Output a FETCH method.  This is actually common to all classes */
      Printv(pm,
	     "sub FETCH {\n",
	     tab4, "my ($self,$field) = @_;\n",
	     tab4, "my $member_func = \"", package, "::", Swig_name_get(Swig_name_member(class_name,(char*)"${field}")), "\";\n",
	     tab4, "my $val = &$member_func($self);\n",
	     tab4, "if (exists $BLESSEDMEMBERS{$field}) {\n",
	     tab8, "return undef if (!defined($val));\n",
	     tab8, "my %retval;\n",
	     tab8, "tie %retval,$BLESSEDMEMBERS{$field},$val;\n",
	     tab8, "return bless \\%retval, $BLESSEDMEMBERS{$field};\n",
	     tab4, "}\n",
	     tab4, "return $val;\n",
	     "}\n\n",
	     0);
      
      /* Output a STORE method.   This is also common to all classes (might move to base class) */

      Printv(pm,
	     "sub STORE {\n",
	     tab4, "my ($self,$field,$newval) = @_;\n",
	     tab4, "my $member_func = \"", package, "::", Swig_name_set(Swig_name_member(class_name,(char*)"${field}")), "\";\n",
	     tab4, "if (exists $BLESSEDMEMBERS{$field}) {\n",
	     tab8, "&$member_func($self,tied(%{$newval}));\n",
	     tab4, "} else {\n",
	     tab8, "&$member_func($self,$newval);\n",
	     tab4, "}\n",
	     "}\n\n",
	     0);

      /* Output a FIRSTKEY method.   This is to allow iteration over a structure's keys. */

      Printv(pm,
	     "sub FIRSTKEY {\n",
	     tab4, "my $self = shift;\n",
	     tab4, "$ITERATORS{$self} = [", member_keys, "];\n",
	     tab4, "my $first = shift @{$ITERATORS{$self}};\n",
	     tab4, "return $first;\n",
	     "}\n\n",
	     0);

      /* Output a NEXTKEY method.   This is the iterator so that each and keys works */

      Printv(pm,
	     "sub NEXTKEY {\n",
	     tab4, "my $self = shift;\n",
	     tab4, "$nelem = scalar @{$ITERATORS{$self}};\n",
	     tab4, "if ($nelem > 0) {\n",
	     tab8, "my $member = shift @{$ITERATORS{$self}};\n",
	     tab8, "return $member;\n",
	     tab4, "} else {\n",
	     tab8, "$ITERATORS{$self} = [", member_keys, "];\n",
	     tab8, "return ();\n",
	     tab4, "}\n",
	     "}\n\n",
	     0);
    }
  }
}

/* -----------------------------------------------------------------------------
 * PERL5::cpp_member_func()
 * ----------------------------------------------------------------------------- */
void
PERL5::cpp_member_func(char *name, char *iname, SwigType *t, ParmList *l) {
  String  *func;
  char    *realname;
  Parm    *p;
  int      i;
  String  *cname;
  int      pcount, numopt;
  char    *tm;
  int      need_wrapper = 0;

  member_func = 1;
  this->Language::cpp_member_func(name,iname,t,l);
  member_func = 0;

  if (!blessed) return;

  func = NewString("");
  cname = NewString("perl5:");

  /* Now emit a Perl wrapper function around our member function, we might need
     to patch up some arguments along the way */

  if (!iname)
    realname = name;
  else
    realname = iname;

  Printf(cname,"%s::%s",class_name,realname);
  if (Getattr(symbols,cname)) {
    return;   /* Forget it, we saw this already */
  }
  Setattr(symbols,cname,cname);

  Printv(func,
	 "sub ", realname, " {\n",
	 tab4, "my @args = @_;\n",
	 0);

  /* Now we have to go through and patch up the argument list.  If any
     arguments to our function correspond to other Perl objects, we
     need to extract them from a tied-hash table object. */

  p = l;
  pcount = ParmList_len(l);
  numopt = check_numopt(l);
  i = 1;
  while(p) {
    SwigType *pt = Gettype(p);
    if (!Getignore(p)) {
      char sourceNtarget[512];
      sprintf(sourceNtarget, "$args[%d]", i);

      if ((tm = Swig_typemap_lookup((char*)"perl5in",pt,(char*)"",sourceNtarget,sourceNtarget,0))) {
	Printf(func,"%s\n",tm);
	need_wrapper = 1;
      }
      i++;
    }
    p = Getnext(p);
  }
  
  /* Okay.  We've made argument adjustments, now call into the package */

  Printv(func,
	 tab4, "my $result = ", package, "::", Swig_name_member(class_name,realname),
        "(@args);\n",
	 0);
  
  /* Now check to see what kind of return result was found.
   * If this function is returning a result by 'value', SWIG did an 
   * implicit malloc/new.   We'll mark the object like it was created
   * in Perl so we can garbage collect it. */

  if ((tm = Swig_typemap_lookup((char*)"perl5out",t,(char*)"",name,(char*)"sv",0))) {
    Printv(func,
	   tm, "\n",
	   tab4,"return $result;\n",
	   "}\n",
	   0);
    need_wrapper = 1;

  } else if (is_shadow(t)) {
    
    Printv(func,tab4, "return undef if (!defined($result));\n", 0);

    /* If we're returning an object by value, put it's reference
       into our local hash table */

    if (!SwigType_ispointer(t) || NewObject) {
      Printv(func, tab4, "$", is_shadow(t), "::OWNER{$result} = 1; \n", 0);
    }

    /* We're returning a Perl "object" of some kind.  Turn it into
       a tied hash */

    Printv(func,
	   tab4, "my %resulthash;\n",
	   tab4, "tie %resulthash, ref($result), $result;\n",
	   tab4, "return bless \\%resulthash, ref($result);\n",
	   "}\n",
	   0);

    need_wrapper = 1;
  } else {

    /* Hmmm.  This doesn't appear to be anything I know about so just 
       return it unmodified */

    Printv(func, tab4,"return $result;\n", "}\n", 0);
  }

  if (need_wrapper) {
    Printv(pcode,func,0);
  } else {
    Printv(pcode,"*",realname," = *", package, "::", Swig_name_member(class_name,realname), ";\n", 0);
  }
  Delete(func);
  Delete(cname);
}

/* -----------------------------------------------------------------------------
 * PERL5::cpp_variable()
 *
 * Adds an instance member.   This is a little hairy because data members are
 * really added with a tied-hash table that is attached to the object.
 *
 * On the low level, we will emit a pair of get/set functions to retrieve
 * values just like before.    These will then be encapsulated in a FETCH/STORE
 * method associated with the tied-hash.
 *
 * In the event that a member is an object that we have already wrapped, then
 * we need to retrieve the data a tied-hash as opposed to what SWIG normally
 * returns.   To determine this, we build an internal hash called 'BLESSEDMEMBERS'
 * that contains the names and types of tied data members.  If a member name
 * is in the list, we tie it, otherwise, we just return the normal SWIG value.
 * ----------------------------------------------------------------------------- */

void PERL5::cpp_variable(char *name, char *iname, SwigType *t) {

  char *realname;
  String *cname;

  cname = NewString("perl5:");

  /* Emit a pair of get/set functions for the variable */

  member_func = 1;
  this->Language::cpp_variable(name, iname, t);  
  member_func = 0;

  if (iname) realname = iname;
  else realname = name;

  if (blessed) {
    Printf(cname,"%s::%s", class_name, realname);
    if (Getattr(symbols,cname)) {
      Delete(cname);
      return; 
    }
    Setattr(symbols,cname,cname);
	
    /* Store name of key for future reference */
    Printf(member_keys,"'%s', ", realname);

    /* Now we need to generate a little Perl code for this */

    if (is_shadow(t)) {

      /* This is a Perl object that we have already seen.  Add an 
	 entry to the members list*/
      Printv(blessedmembers,
	     tab4, realname, " => '", is_shadow(t), "',\n",
	     0);
      
     }
  }
  have_data_members++;
  Delete(cname);
}

/* -----------------------------------------------------------------------------
 * PERL5::cpp_constructor()
 *
 * Emits a blessed constructor for our class.    In addition to our construct
 * we manage a Perl hash table containing all of the pointers created by
 * the constructor.   This prevents us from accidentally trying to free 
 * something that wasn't necessarily allocated by malloc or new
 * ----------------------------------------------------------------------------- */
void
PERL5::cpp_constructor(char *name, char *iname, ParmList *l) {
  Parm *p;
  int   i;
  String *realname;
  String *cname;

  cname = NewString("perl5:constructor:");

  /* Emit an old-style constructor for this class */

  member_func = 1;
  this->Language::cpp_constructor(name, iname, l);

  if (blessed) {

    if (iname) 
      realname = iname;
    else {
      if (class_renamed) realname = class_name;
      else realname = class_name;
    }

    Printf(cname,"%s::%s", class_name, realname);
    if (Getattr(symbols,cname)) {
      Delete(cname);
      return;
    }
    Setattr(symbols,cname, cname);
    if ((Cmp(realname,class_name) == 0) || ((!iname) && (ObjCClass)) ){
      
      /* Emit a blessed constructor  */

      Printf(pcode, "sub new {\n");

    } else {
      
      /* Constructor doesn't match classname so we'll just use the normal name  */

      Printv(pcode, "sub ", Swig_name_construct(realname), " () {\n", 0);
	
    }

    Printv(pcode, tab4, "my $self = shift;\n",
	   tab4, "my @args = @_;\n", 0);

    /* We are going to need to patch up arguments here if necessary
     * Now we have to go through and patch up the argument list.  If any
     * arguments to our function correspond to other Perl objects, we
     * need to extract them from a tied-hash table object. */
    
    p = l;
    i = 0;
    while(p) {
      SwigType *pt = Gettype(p);
      
      if (is_shadow(pt)) {
	/* Yep.   This smells alot like an object, patch up the arguments */
	Printf(pcode, "    $args[%d] = tied(%%{$args[%d]});\n", i, i);
      }
      p = Getnext(p);
      i++;
    }
    
    Printv(pcode,
	   tab4, "$self = ", package, "::", Swig_name_construct(realname), "(@args);\n",
	   tab4, "return undef if (!defined($self));\n",
	   tab4, "bless $self, \"", fullclassname, "\";\n",
	   tab4, "$OWNER{$self} = 1;\n",
	   tab4, "my %retval;\n",
	   tab4, "tie %retval, \"", fullclassname, "\", $self;\n",
	   tab4, "return bless \\%retval,\"", fullclassname, "\";\n",
	   "}\n\n",
	   0);

    have_constructor = 1;

  }
  Delete(cname);
  member_func = 0;
}

/* -----------------------------------------------------------------------------
 * PERL5::cpp_destructor()
 * ----------------------------------------------------------------------------- */
void 
PERL5::cpp_destructor(char *name, char *newname) {
  String *realname;
  member_func = 1;
  this->Language::cpp_destructor(name, newname);

  if (blessed) {
    if (newname) realname = newname;
    else {
      if (class_renamed) realname = class_name;
      else realname = name;
    }

    /* Emit a destructor for this object*/

    Printv(pcode,
	   "sub DESTROY {\n",
           tab4, "return unless $_[0]->isa('HASH');\n",   
	   tab4, "my $self = tied(%{$_[0]});\n",
           tab4, "delete $ITERATORS{$self};\n",
	   tab4, "if (exists $OWNER{$self}) {\n",
	   tab8,  package, "::", Swig_name_destroy(realname), "($self);\n",
	   tab8, "delete $OWNER{$self};\n",
	   tab4, "}\n}\n\n",
	   0);
    
    have_destructor = 1;
    
  }
  member_func = 0;
}

/* -----------------------------------------------------------------------------
 * PERL5::cpp_static_func()
 * ----------------------------------------------------------------------------- */
void 
PERL5::cpp_static_func(char *name, char *iname, SwigType *t, ParmList *l) {
  this->Language::cpp_static_func(name,iname,t,l);
  char *realname;
  if (iname) realname = name;
  else realname = iname;

  if (blessed) {
    Printv(pcode, "*", realname, " = *", realpackage, "::", Swig_name_member(class_name,realname), ";\n", 0);
  }
}
  
/* -----------------------------------------------------------------------------
 * PERL5::cpp_inherit()
 * ------------------------------------------------------------------------------ */
void 
PERL5::cpp_inherit(char **baseclass, int) {
  char *bc;
  int  i = 0, have_first = 0;
  if (!blessed) {
    this->Language::cpp_inherit(baseclass);
    return;
  }

  /* Inherit variables and constants from base classes, but not 
     functions (since Perl can handle that okay). */

  this->Language::cpp_inherit(baseclass, INHERIT_CONST | INHERIT_VAR);

  /* Now tell the Perl5 module that we're inheriting from base classes */

  base_class = NewString("");
  while (baseclass[i]) {
    /* See if this is a class we know about */
    bc = Char(is_shadow(baseclass[i]));
    if (bc) {
      if (have_first) Putc(' ', base_class);
      Printf(base_class,bc);
      have_first = 1;
    }
    i++;
  }
  if (!have_first) {
    Delete(base_class);
    base_class = 0;
  }
}

/* ----------------------------------------------------------------------------- 
 * PERL5::cpp_declare_const()
 * ----------------------------------------------------------------------------- */
void
PERL5::cpp_declare_const(char *name, char *iname, SwigType *type, char *value) {
  String *realname;
  int   oldblessed = blessed;
  char  cname[256];
  
  /* Create a normal constant */
  blessed = 0;
  this->Language::cpp_declare_const(name, iname, type, value);
  blessed = oldblessed;

  if (blessed) {
    if (!iname)
      realname = name;
    else
      realname = iname;
    
    sprintf(cname,"%s::%s",Char(class_name),Char(realname));
    if (Getattr(symbols, cname)) {
      return; 
    }
    Setattr(symbols, cname,cname);

    /* Create a symbol table entry for it */
    Printv(pcode, "*", realname, " = *", package, "::", Swig_name_member(class_name,realname), ";\n", 0);
  }
}

/* -----------------------------------------------------------------------------
 * PERL5::cpp_class_decl()
 * ----------------------------------------------------------------------------- */
void 
PERL5::cpp_class_decl(char *name, char *rename, char *type) {
  String *stype;
  if (blessed) {
    stype = NewString(name);
    SwigType_add_pointer(stype);
    Setattr(classes,stype,rename);
    Delete(stype);
    if (strlen(type) > 0) {
      stype = NewStringf("%s %s",type,name);
      SwigType_add_pointer(stype);
      Setattr(classes,stype,rename);
      Delete(stype);
    }
  }
}

/* -----------------------------------------------------------------------------
 * PERL5::add_typedef()
 * ----------------------------------------------------------------------------- */
void 
PERL5::add_typedef(SwigType *t, char *name) {

  if (!blessed) return;
  if (is_shadow(t)) {
    cpp_class_decl(name,Char(is_shadow(t)),"");    
  }
}


/* -----------------------------------------------------------------------------
 * PERL5::pragma()
 *
 * Pragma directive.
 *
 * %pragma(perl5) code="String"              # Includes a string in the .pm file
 * %pragma(perl5) include="file.pl"          # Includes a file in the .pm file
 * ----------------------------------------------------------------------------- */

void PERL5::pragma(char *lang, char *code, char *value) {
  if (strcmp(lang,"perl5") == 0) {
    if (strcmp(code,"code") == 0) {
      /* Dump the value string into the .pm file */
      if (value) {
	Printf(pragma_include, "%s\n", value);
      }
    } else if (strcmp(code,"include") == 0) {
      /* Include a file into the .pm file */
      if (value) {
	FILE *f = Swig_open(value);
	if (!f) {
	  Printf(stderr,"%s : Line %d. Unable to locate file %s\n", input_file, line_number,value);
	} else {
	  char buffer[4096];
	  while (fgets(buffer,4095,f)) {
	    Printf(pragma_include,"%s",buffer);
	  }
	}
      }
    } else {
      Printf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file,line_number);
    }
  }
}




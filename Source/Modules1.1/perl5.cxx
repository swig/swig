/*******************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 *******************************************************************************/

static char cvsroot[] = "$Header$";

/***********************************************************************
 * $Header$
 *
 * perl5.c
 *
 * Definitions for adding functions to Perl 5
 *
 * How to extend perl5 (note : this is totally different in Perl 4) :
 *
 * 1.   Variable linkage
 *
 *      Must declare two functions :
 *
 *          _var_set(SV *sv, MAGIC *mg);
 *          _var_get(SV *sv, MAGIC *mg);
 *
 *      These functions must set/get the values of a variable using
 *      Perl5 internals.
 *
 *      To add these to Perl5 (which isn't entirely clear), need to
 *      do the following :
 *
 *            SV  *sv;
 *            MAGIC  *m;
 *            sv = perl_get_sv("varname",TRUE);
 *            sv_magic(sv,sv, 'U', "varname", strlen("varname));
 *            m = mg_find(sv, 'U');
 *            m->mg_virtual = (MGVTBL *) malloc(sizeof(MGVTBL));
 *            m->mg_virtual.svt_get = _var_set;
 *            m->mg_virtual.svt_set = _var_get;
 *            m->mg_virtual.svt_len = 0;
 *            m->mg_virtual.svt_free = 0;
 *            m->mg_virtual.svt_clear = 0;
 *
 *
 * 2.   Function extension
 *
 *      Functions are declared as :
 *             XS(_wrap_func) {
 *                 dXSARGS;
 *                 if (items != parmcount) {
 *                     croak("Usage :");
 *                 }
 *              ... get arguments ...
 *
 *              ... call function ...
 *              ... set return value in ST(0) 
 *                 XSRETURN(1);
 *              }
 *      To extract function arguments, use the following :
 *              _arg = (int) SvIV(ST(0))
 *              _arg = (double) SvNV(ST(0))
 *              _arg = (char *) SvPV(ST(0),na);
 *
 *      For return values, use :
 *              ST(0) = sv_newmortal();
 *              sv_setiv(ST(0), (IV) RETVAL);     // Integers
 *              sv_setnv(ST(0), (double) RETVAL); // Doubles
 *              sv_setpv((SV*) ST(0), RETVAL);    // Strings
 *
 *      New functions are added using 
 *              newXS("name", _wrap_func, file)
 *
 *    
 * 3.   Compilation.
 *
 *      Code should be compiled into an object file for dynamic
 *      loading into Perl.
 ***********************************************************************/

#include "mod11.h"
#include "perl5.h"



static char *usage = (char*)"\
Perl5 Options (available with -perl5)\n\
     -module name    - Set module name\n\
     -package name   - Set package prefix\n\
     -hide name      - Set hide package name.\n\
     -static         - Omit code related to dynamic loading.\n\
     -shadow         - Create shadow classes.\n\
     -compat         - Compatibility mode.\n\
     -alt-header file- Use an alternate header.\n\n";

static char *import_file = 0;
static char *smodule = 0;
static int   compat = 0;

static int           export_all;
static char         *package = 0;
static char         *module = 0;
static DOHString    *cmodule = 0;
static char         *hide = 0;
static DOHString    *vinit = 0;
static FILE         *f_pm = 0;
static DOHString    *pm;                      // Package initialization code
static DOHString    *magic;                   // Magic variable wrappers

static char   *perl_path = (char*)"perl5";
static int    is_static = 0;
static char   *alt_header = 0;   

// The following variables are used to manage Perl5 classes

static  int      blessed = 0;                // Enable object oriented features
static  int      hidden = 0;                 // Every symbol hidden in <hide> package name
static  DOH     *classes = 0;                // A hash table for storing the classes we've seen so far
static  DOH     *symbols = 0; 
static  int      have_constructor = 0;
static  int      have_destructor= 0;
static  int      have_data_members = 0;
static  char     *class_name = 0;            // Name of the class (what Perl thinks it is)
static  char     *class_type = 0;            // Type of class "struct", "class", "union"
static  char     *real_classname = 0;        // Real name of C/C++ class
static  DOHString   *base_class = 0;            // Base class (if using inheritance)
static  DOHString   *pcode = 0;                 // Perl code associated with each class
static  DOHString   *blessedmembers = 0;        // Member data associated with each class
static  int      member_func = 0;            // Set to 1 when wrapping a member function
static  char     *realpackage = 0;           // Name of real module 
static  DOHString   *func_stubs = 0;         // Function stubs
static  DOHString   *var_stubs = 0;          // Variable stubs
static  DOHString   *member_keys = 0;        // Keys for all member data
static  DOHString   *exported = 0;           // Exported symbols
static  DOHString   *modinit = 0;
static  DOHString   *modextern = 0;
static  DOHString   *pragma_include = 0;

// ---------------------------------------------------------------------
// PERL5::parse_args(int argc, char *argv[])
//
// Parse command line options.
// ---------------------------------------------------------------------

void
PERL5::parse_args(int argc, char *argv[]) {

  int i = 1;

  cmodule = NewString("");
  export_all = 0;
  sprintf(LibDir,"%s", perl_path);

  // Look for certain command line options

  // Get options
  for (i = 1; i < argc; i++) {
      if (argv[i]) {
	  if(strcmp(argv[i],"-package") == 0) {
	    if (argv[i+1]) {
	      package = new char[strlen(argv[i+1])+1];
	      strcpy(package, argv[i+1]);
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i++;
	    } else {
	      Swig_arg_error();
	    }
	  } else if (strcmp(argv[i],"-module") == 0) {
	    if (argv[i+1]) {
	      module = new char[strlen(argv[i+1])+1];
	      strcpy(module, argv[i+1]);
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
	  } else if (strcmp(argv[i],"-hide") == 0) {
	    if (argv[i+1]) {
	      hide = new char[strlen(argv[i+1])+1];
	      strcpy(hide, argv[i+1]);
	      hidden = 1;
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i++;
	    } else {
	      Swig_arg_error();
	    }
	  } else if (strcmp(argv[i],"-alt-header") == 0) {
	    if (argv[i+1]) {
	      alt_header = Swig_copy_string(argv[i+1]);
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i++;
	    } else {
	      Swig_arg_error();
	    }
	  } else if (strcmp(argv[i],"-compat") == 0) {
	    compat = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-help") == 0) {
	    fputs(usage,stderr);
	  }
      }
  }
  // Add a symbol for this module

  Preprocessor_define((void *) "SWIGPERL 1", 0);
  Preprocessor_define((void *) "SWIGPERL5 1", 0);

  // Set name of typemaps

  typemap_lang = (char*)"perl5";

}

// ------------------------------------------------------------------
// PERL5::parse()
//
// Parse an interface file
// ------------------------------------------------------------------

void
PERL5::parse() {


  printf("Generating wrappers for Perl 5\n");

  classes = NewHash();
  symbols = NewHash();
  
  vinit = NewString("");
  pm    = NewString("");
  func_stubs = NewString("");
  var_stubs = NewString("");
  exported = NewString("");
  magic = NewString("");
  modinit = NewString("");
  modextern = NewString("");
  pragma_include = NewString("");

  // Print out PERL5 specific headers
  
  headers();
  
  // Run the parser
  
  yyparse();

}


// ---------------------------------------------------------------------
// PERL5::set_module(char *mod_name, char **mod_list)
//
// Sets the module name.
// Does nothing if it's already set (so it can be overridden as a command
// line option).
//
//----------------------------------------------------------------------

void PERL5::set_module(char *mod_name, char **mod_list) {
  int i;
  if (import_file) {
    if (!(strcmp(import_file,input_file+strlen(input_file)-strlen(import_file)))) {
      if (blessed) {
	Printf(f_pm,"require %s;\n", mod_name);
      }
      free(import_file);
      import_file = 0;
    }
  }

  if (module) return;
  
  module = new char[strlen(mod_name)+1];
  strcpy(module,mod_name);

  // if there was a mod_list specified, make this big hack
  if (mod_list) {
    Printf(modinit,"#define SWIGMODINIT ");
    Printv(modextern,
	   "#ifdef __cplusplus\n",
	   "extern \"C\" {\n",
	   "#endif\n",
	   0);

    i = 0;
    while(mod_list[i]) {
      Printv(modinit,"newXS(\"", mod_list[i], "::boot_", mod_list[i], "\", boot_", mod_list[i], ", file);\\\n", 0);
      Printv(modextern, "extern void boot_", mod_list[i], "(CV *);\n",0);
      i++;
    }
    Printv(modextern,
	   "#ifdef __cplusplus\n",
	   "}\n",
	   "#endif\n",
	   0);
    Printf(modinit,"/* End of extern module initialization */\n");
  }

  // Create a C module name and put it in 'cmodule'

  Clear(cmodule);
  Append(cmodule,module);
  Replace(cmodule,":","_",DOH_REPLACE_ANY);
}

// ---------------------------------------------------------------------
// PERL5::set_init(char *iname)
//
// Sets the initialization function name.
// Does nothing if it's already set
//
//----------------------------------------------------------------------

void PERL5::set_init(char *iname) {
  set_module(iname,0);
}

// ---------------------------------------------------------------------
// PERL5::headers(void)
//
// Generate the appropriate header files for PERL5 interface.
// ----------------------------------------------------------------------

void PERL5::headers(void)
{

  Swig_banner(f_header);

  if (!alt_header) {
    if (Swig_insert_file("headers.swg", f_header) == -1) {
      Printf(stderr,"Perl5 : Fatal error. Unable to locate headers.swg. Possible installation problem.\n");
      SWIG_exit(1);
    }
  } else {
    if (Swig_insert_file(alt_header, f_header) == -1) {
      Printf(stderr,"SWIG : Fatal error.  Unable to locate %s.\n",alt_header);
      SWIG_exit(1);
    }
  }

  if (NoInclude) {
    Printf(f_header,"#define SWIG_NOINCLUDE\n");
  }

  // Get special SWIG related declarations
  if (Swig_insert_file("perl5.swg", f_header) == -1) {
    Printf(stderr,"SWIG : Fatal error.  Unable to locate 'perl5.swg' in SWIG library.\n");
    SWIG_exit(1);
  }

  // Get special SWIG related declarations
  if (Swig_insert_file("perl5mg.swg", f_header) == -1) {
    Printf(stderr,"SWIG : Fatal error.  Unable to locate 'perl5mg.swg' in SWIG library.\n");
    SWIG_exit(1);
  }

}

// --------------------------------------------------------------------
// PERL5::initialize()
//
// Output initialization code that registers functions with the
// interface.
// ---------------------------------------------------------------------

void PERL5::initialize()
{

  char filen[256];

  if (!module){
    Printf(stderr,"*** Error. No module name specified.\n");
    SWIG_exit(1);
  }

  if (!package) {
    package = new char[strlen(module)+1];
    strcpy(package,module);
  }

  // If we're in blessed mode, change the package name to "packagec"

  if (blessed) {
    char *newpackage = new char[strlen(package)+2];
    sprintf(newpackage,"%sc",package);
    realpackage = package;
    package = newpackage;
  } else {
    realpackage = package;
  }

  // Create a .pm file 
  // Need to strip off any prefixes that might be found in
  // the module name

  {
    char *m = module + strlen(module);
    while (m != module) {
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
    smodule = module;
  } else if (is_static) {
    smodule = new char[strlen(module)+2];
    strcpy(smodule,module);
    strcat(smodule,"c");
    Append(cmodule,"c");
  } else {
    smodule = module;
  }

  //
  // Fully qualifies package and realpackage
  //
  if(hidden) {
    char* tmp = new char[strlen(package) + strlen(hide) + 3];
    sprintf(tmp, "%s::%s", hide, realpackage);
    delete [] realpackage;
    realpackage = tmp;
    if(blessed) {
      delete [] package;
      tmp = new char[strlen(realpackage) + 2];
      sprintf(tmp, "%sc", realpackage);
      package = tmp;
    } else {
      package = realpackage;
    }
  }
  
  {
    DOHString *tmp = NewString(realpackage);
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
  Printf(f_init,"\t char *file = __FILE__;\n");
  Printf(f_init,"\t cv = cv; items = items;\n");
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

  // Start creating magic code

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
  
  /* Process additional initialization files here */

  if (Len(modinit) > 0) {
    Printf(f_header,"%s\n",modinit);
  }
  if (Len(modextern) > 0) {
    Printf(f_header,"%s\n",modextern);
  }
}

// ---------------------------------------------------------------------
// PERL5::import(char *filename)
//
// Import directive
// ---------------------------------------------------------------------

void PERL5::import(char *filename) {
  if (import_file) free(import_file);
  import_file = Swig_copy_string(filename);
}


// ---------------------------------------------------------------------
// PERL5::close(void)
//
// Wrap things up.  Close initialization function.
// ---------------------------------------------------------------------

void PERL5::close(void)
{
  DOHString *base = NewString("");

  // Dump out variable wrappers

  Printv(magic,
	 "\n\n#ifdef PERL_OBJECT\n",
	 "};\n",
	 "#endif\n",
	 0);

  Printf(f_header,"%s\n", magic);
  
  emit_ptr_equivalence(f_init);

  Printf(f_init,"\t ST(0) = &PL_sv_yes;\n");
  Printf(f_init,"\t XSRETURN(1);\n");
  Printf(f_init,"}\n");

  Printv(vinit,tab4, "XSRETURN(1);\n", "}\n", 0);
  Printf(f_wrappers,"%s", vinit);

  Printf(f_pm,"package %s;\n", package);	

  if (!is_static) {
    Printf(f_pm,"bootstrap %s;\n", realpackage);
  } else {
    DOHString *tmp = NewString(realpackage);
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

    // Write out the TIE method

    Printv(base,
	   "sub TIEHASH {\n",
	   tab4, "my ($classname,$obj) = @_;\n",
	   tab4, "return bless $obj, $classname;\n",
	   "}\n\n",
	   0);

    // Output a CLEAR method.   This is just a place-holder, but by providing it we 
    // can make declarations such as
    //     %$u = ( x => 2, y=>3, z =>4 );
    //
    // Where x,y,z are the members of some C/C++ object.

    Printf(base,"sub CLEAR { }\n\n");

    // Output default firstkey/nextkey methods

    Printf(base, "sub FIRSTKEY { }\n\n");
    Printf(base, "sub NEXTKEY { }\n\n");

    // Output a 'this' method

    Printv(base,
	   "sub this {\n",
	   tab4, "my $ptr = shift;\n",
	   tab4, "return tied(%$ptr);\n",
	   "}\n\n",
	   0);

    Printf(f_pm,"%s",base);

    // Emit function stubs for stand-alone functions

    Printf(f_pm,"\n# ------- FUNCTION WRAPPERS --------\n\n");
    Printf(f_pm,"package %s;\n\n",realpackage);
    Printf(f_pm,"%s",func_stubs);

    // Emit package code for different classes

    Printf(f_pm,"%s",pm);

    // Emit variable stubs

    Printf(f_pm,"\n# ------- VARIABLE STUBS --------\n\n");
    Printf(f_pm,"package %s;\n\n",realpackage);
    Printf(f_pm,"%s",var_stubs);

  }

  Printf(f_pm,"1;\n");
  fclose(f_pm);
  Delete(base);
}

// ----------------------------------------------------------------------
// char *PERL5::type_mangle(DataType *t)
//
// Mangles a datatype into a Perl5 name compatible with xsubpp type
// T_PTROBJ.
// ----------------------------------------------------------------------

char *
PERL5::type_mangle(DataType *t) {
  static char result[128];
  int   i;
  char *r, *c;

  if (blessed) {

    // Check to see if we've blessed this datatype

    if ((Getattr(classes,t->name)) && (t->is_pointer <= 1)) {

      // This is a blessed class.  Return just the type-name 
      strcpy(result, GetChar(classes,t->name));
      return result;
    }
  }
      
  r = result;
  c = t->name;

  for ( c = t->name; *c; c++,r++) {
      *r = *c;
  }
  for (i = 0; i < (t->is_pointer-t->implicit_ptr); i++, r++) {
    strcpy(r,"Ptr");
    r+=2;
  }
  *r = 0;
  return result;
}

// ----------------------------------------------------------------------
// PERL5::get_pointer(char *iname, char *srcname, char *src, char *target,
//                     DataType *t, String &f, char *ret)
//
// Emits code to get a pointer from a parameter and do type checking.
// ----------------------------------------------------------------------

void PERL5::get_pointer(char *iname, char *srcname, char *src, char *dest,
			DataType *t, DOHString *f, char *ret) {

  // Now get the pointer value from the string and save in dest

  Printv(f, tab4, "if (SWIG_GetPtr(", src, ",(void **) &", dest, ",", 0);

  // If we're passing a void pointer, we give the pointer conversion a NULL
  // pointer, otherwise pass in the expected type.
  
  if (t->type == T_VOID) Printf(f, "(char *) 0 )) {\n");
  else 
    Printv(f, "\"", (hidden ? realpackage : ""), (hidden ? "::" : ""), t->print_mangle(), "\")) {\n", 0);

  // Change this part to return an error.
  Printv(f,
	 tab8, "croak(\"Type error in ", srcname,
	 " of ", iname, ". Expected ", (hidden ? realpackage : ""), (hidden ? "::" : ""), t->print_mangle(), ".\");\n",
	 tab8, ret, ";\n",
	 tab4, "}\n",
	 0);
}

// ----------------------------------------------------------------------
// PERL5::create_command(char *cname, char *iname)
//
// Create a command and register it with the interpreter
// ----------------------------------------------------------------------

void PERL5::create_command(char *cname, char *iname) {
  Printf(f_init,"\t newXS(\"%s::%s\", %s, file);\n", package, iname, Swig_name_wrapper(cname));
  if (export_all) {
    Printf(exported,"%s ",iname);
  }
}

// ----------------------------------------------------------------------
// PERL5::create_function(char *name, char *iname, DataType *d,
//                             ParmList *l)
//
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

void PERL5::create_function(char *name, char *iname, DataType *d, ParmList *l)
{
  Parm *p;
  int   pcount,i,j;
  char  *wname;
  char *usage = 0;
  Wrapper *f;
  char  source[256],target[256],temp[256], argnum[32];
  char  *tm;
  DOHString *cleanup, *outarg;
  int    numopt = 0;
  int    need_save, num_saved = 0;             // Number of saved arguments.

  f = NewWrapper();
  cleanup = NewString("");
  outarg = NewString("");

  // Make a wrapper name for this

  wname = Swig_name_wrapper(iname);
  
  // Now write the wrapper function itself....this is pretty ugly

  Printv(f->def, "XS(", wname, ") {\n", 0);
  Printv(f->code, tab4, "cv = cv;\n", 0);

  pcount = emit_args(d, l, f);
  numopt = l->numopt();

  Wrapper_add_local(f,"argvi","int argvi = 0");

  // Check the number of arguments

  usage = usage_func(iname,d,l);
  Printf(f->code,"    if ((items < %d) || (items > %d)) \n", pcount-numopt, l->numarg());
  Printf(f->code,"        croak(\"Usage: %s\");\n", usage);

  // Write code to extract parameters.
  // This section should be able to extract virtually any kind 
  // parameter, represented as a string

  i = 0;
  j = 0;
  p = l->get_first();
  while (p != 0) {
    // Produce string representation of source and target arguments
    sprintf(source,"ST(%d)",j);
    sprintf(target,"_arg%d",i);
    sprintf(argnum,"%d",j+1);

    // Check to see if this argument is being ignored

    if (!p->ignore) {
      
      // If there are optional arguments, check for this

      if (j>= (pcount-numopt))
	Printf(f->code,"    if (items > %d) {\n", j);

      // See if there is a type-map
      if ((tm = typemap_lookup((char*)"in",(char*)"perl5",p->t,p->name,source,target,f))) {
	Printf(f->code,"%s\n",tm);
	Replace(f->code,"$argnum",argnum,DOH_REPLACE_ANY);
	Replace(f->code,"$arg",source,DOH_REPLACE_ANY);
      } else {

	if (!p->t->is_pointer) {
	  
	  // Extract a parameter by "value"
	  
	  switch(p->t->type) {
	    
	    // Integers
	    
	  case T_BOOL:
	  case T_INT :
	  case T_SHORT :
	  case T_LONG :
	  case T_SINT :
	  case T_SSHORT:
	  case T_SLONG:
	  case T_SCHAR:
	  case T_UINT:
	  case T_USHORT:
	  case T_ULONG:
	  case T_UCHAR:
	    Printf(f->code,"    _arg%d = %sSvIV(ST(%d));\n", i, p->t->print_cast(),j);
	    break;
	  case T_CHAR :


	    Printf(f->code,"    _arg%d = (char) *SvPV(ST(%d),PL_na);\n", i, j);
	    break;
	  
	  // Doubles
	  
	  case T_DOUBLE :
	  case T_FLOAT :
	    Printf(f->code,"    _arg%d = %s SvNV(ST(%d));\n", i, p->t->print_cast(), j);
	    break;
	  
	  // Void.. Do nothing.
	  
	  case T_VOID :
	    break;
	  
	    // User defined.   This is invalid here.   Note, user-defined types by
	    // value are handled in the parser.
	    
	  case T_USER:
	    
	    // Unsupported data type
	    
	  default :
	    Printf(stderr,"%s : Line %d. Unable to use type %s as a function argument.\n",input_file, line_number, p->t->print_type());
	    break;
	  }
	} else {
	  
	  // Argument is a pointer type.   Special case is for char *
	  // since that is usually a string.
	  
	  if ((p->t->type == T_CHAR) && (p->t->is_pointer == 1)) {
	    Printf(f->code,"    if (! SvOK((SV*) ST(%d))) { _arg%d = 0; }\n", j, i);
	    Printf(f->code,"    else { _arg%d = (char *) SvPV(ST(%d),PL_na); }\n", i,j);
	  } else {
	    
	    // Have a generic pointer type here.    Read it in as a swig
	    // typed pointer.
	    
	    sprintf(temp,"argument %d", i+1);
	    get_pointer(iname,temp,source,target, p->t, f->code, (char*)"XSRETURN(1)");
	  }
	}
      }
      // The source is going to be an array of saved values.

      sprintf(temp,"_saved[%d]",num_saved);
      if (j>= (pcount-numopt))
	Printf(f->code,"    } \n");
      j++;
    } else {
      temp[0] = 0;
    }

    // Check if there is any constraint code
    if ((tm = typemap_lookup((char*)"check",(char*)"perl5",p->t,p->name,source,target))) {
      Printf(f->code,"%s\n", tm);
      Replace(f->code,"$argnum",argnum, DOH_REPLACE_ANY);
    }
    need_save = 0;

    if ((tm = typemap_lookup((char*)"freearg",(char*)"perl5",p->t,p->name,target,temp))) {
      Printf(cleanup,"%s\n", tm);
      Replace(cleanup,"$argnum",argnum,DOH_REPLACE_ANY);
      Replace(cleanup,"$arg",temp,DOH_REPLACE_ANY);
      need_save = 1;
    }
    if ((tm = typemap_lookup((char*)"argout",(char*)"perl5",p->t,p->name,target,(char*)"ST(argvi)"))) {
      DOHString *tempstr = NewString(tm);
      Replace(tempstr,"$argnum",argnum, DOH_REPLACE_ANY);
      Replace(tempstr,"$arg",temp, DOH_REPLACE_ANY);
      Printf(outarg,"%s\n", tempstr);
      Delete(tempstr);
      need_save = 1;
    }
    // If we needed a saved variable, we need to emit to emit some code for that
    // This only applies if the argument actually existed (not ignore)
    if ((need_save) && (!p->ignore)) {
      Printv(f->code, tab4, temp, " = ", source, ";\n", 0);
      num_saved++;
    }
    p = l->get_next();
    i++;
  }

  // If there were any saved arguments, emit a local variable for them

  if (num_saved) {
    sprintf(temp,"_saved[%d]",num_saved);
    Wrapper_add_localv(f,"_saved","SV *",temp,0);
  }

  // Now write code to make the function call

  emit_func_call(name,d,l,f);

  // See if there was a typemap
  if ((tm = typemap_lookup((char*)"out",(char*)"perl5",d,iname,(char*)"_result",(char*)"ST(argvi)"))) {
    // Yep.  Use it instead of the default
    Printf(f->code, "%s\n", tm);
  } else if ((d->type != T_VOID) || (d->is_pointer)) {
    if (!d->is_pointer) {
      
      // Function returns a "value"
      Printf(f->code,"    ST(argvi) = sv_newmortal();\n");
      switch(d->type) {
      case T_INT: case T_BOOL: case T_SINT: case T_UINT:
      case T_SHORT: case T_SSHORT: case T_USHORT:
      case T_LONG : case T_SLONG : case T_ULONG:
      case T_SCHAR: case T_UCHAR :
	Printf(f->code,"    sv_setiv(ST(argvi++),(IV) _result);\n");
	break;
      case T_DOUBLE :
      case T_FLOAT :
	Printf(f->code,"    sv_setnv(ST(argvi++), (double) _result);\n");
	break;
      case T_CHAR :
	Wrapper_add_local(f,"_ctemp", "char _ctemp[2]");
	Printv(f->code,
	       tab4, "_ctemp[0] = _result;\n",
	       tab4, "_ctemp[1] = 0;\n",
	       tab4, "sv_setpv((SV*)ST(argvi++),_ctemp);\n",
	       0);
	break;
	
	// Return a complex type by value
	
      case T_USER:
	d->is_pointer++;
	Printv(f->code,
	       tab4, "sv_setref_pv(ST(argvi++),\"",(hidden ? realpackage : ""), (hidden ? "::" : ""), d->print_mangle(),
	       "\", (void *) _result);\n", 0);
	d->is_pointer--;
	break;
	
      default :
	Printf(stderr,"%s: Line %d. Unable to use return type %s in function %s.\n", input_file, line_number, d->print_type(), name);
	break;
      }
    } else {
      
      // Is a pointer return type
      Printf(f->code,"    ST(argvi) = sv_newmortal();\n");
      if ((d->type == T_CHAR) && (d->is_pointer == 1)) {
	
	// Return a character string
	Printf(f->code,"    sv_setpv((SV*)ST(argvi++),(char *) _result);\n");
	
      } else {
	// Is an ordinary pointer type.
	Printv(f->code, tab4, "sv_setref_pv(ST(argvi++),\"", (hidden ? realpackage : ""), (hidden ? "::" : ""), d->print_mangle(),
	       "\", (void *) _result);\n", 0);
      }
    }
  }

  // If there were any output args, take care of them.
  
  Printv(f->code,outarg,0);

  // If there was any cleanup, do that.

  Printv(f->code,cleanup,0);

  if (NewObject) {
    if ((tm = typemap_lookup((char*)"newfree",(char*)"perl5",d,iname,(char*)"_result",(char*)""))) {
      Printf(f->code,"%s\n",tm);
    }
  }

  if ((tm = typemap_lookup((char*)"ret",(char*)"perl5",d,iname,(char*)"_result",(char*)""))) {
      // Yep.  Use it instead of the default
    Printf(f->code,"%s\n", tm);
  }

  // Wrap things up (in a manner of speaking)

  Printf(f->code,"    XSRETURN(argvi);\n}\n");

  // Add the dXSARGS last

  Wrapper_add_local(f,"dXSARGS","dXSARGS");

  // Substitute the cleanup code
  Replace(f->code,"$cleanup",cleanup,DOH_REPLACE_ANY);
  Replace(f->code,"$name",iname,DOH_REPLACE_ANY);

  // Dump this function out

  Wrapper_print(f,f_wrappers);

  // Now register the function

  Printf(f_init,"\t newXS(\"%s::%s\", %s, file);\n", package, iname, wname);

  if (export_all) {
    Printf(exported,"%s ", iname);
  }


  // --------------------------------------------------------------------
  // Create a stub for this function, provided it's not a member function
  //
  // Really we only need to create a stub if this function involves
  // complex datatypes.   If it does, we'll make a small wrapper to 
  // process the arguments.   If it doesn't, we'll just make a symbol
  // table entry.
  // --------------------------------------------------------------------

  if ((blessed) && (!member_func)) {
    int    need_stub = 0;
    DOHString *func = NewString("");
    
    // We'll make a stub since we may need it anyways

    Printv(func, "sub ", iname, " {\n",
	   tab4, "my @args = @_;\n",
	   0);

    // Now we have to go through and patch up the argument list.  If any
    // arguments to our function correspond to other Perl objects, we
    // need to extract them from a tied-hash table object.

    Parm *p = l->get_first();
    int i = 0;
    while(p) {

      if (!p->ignore) {
	// Look up the datatype name here
	char sourceNtarget[256];
	sprintf(sourceNtarget,"$args[%d]",i);

	if ((tm = typemap_lookup((char*)"perl5in",(char*)"perl5",p->t,(char*)"",sourceNtarget,sourceNtarget))) {
	  Printf(func,"%s\n", tm);
	} else if ((Getattr(classes,p->t->name)) && (p->t->is_pointer <= 1)) {
	  if (i >= (pcount - numopt))
	    Printf(func,"    if (scalar(@args) >= %d) {\n    ", i);
	  Printf(func,"    $args[%d] = tied(%%{$args[%d]});\n", i, i);
	  if (i >= (pcount - numopt))
	    Printf(func,"    }\n");

	  need_stub = 1;
	}
	i++;
      }
      p = l->get_next();
    }

    Printv(func, tab4, "my $result = ", package, "::", iname, "(@args);\n", 0);

    // Now check to see what kind of return result was found.
    // If this function is returning a result by 'value', SWIG did an 
    // implicit malloc/new.   We'll mark the object like it was created
    // in Perl so we can garbage collect it.

    if ((tm = typemap_lookup((char*)"perl5out",(char*)"perl5",d,(char*)"",name,(char*)"sv"))) {
      Printv(func,
	     tm, "\n",
	     tab4, "return $result;\n",
	     "}\n",
	     0);

    } else if ((Getattr(classes,d->name)) && (d->is_pointer <=1)) {

      Printv(func, tab4, "return undef if (!defined($result));\n", 0);

      // If we're returning an object by value, put it's reference
      // into our local hash table

      if ((d->is_pointer == 0) || ((d->is_pointer == 1) && NewObject)) {
	char *name = GetChar(classes,d->name);
	if (hidden) 
	  Printv(func, tab4, "$", realpackage, "::", name, "::OWNER{$result} = 1;\n", 0);
	else
	  Printv(func, tab4, "$", name, "::OWNER{$result} = 1;\n", 0);
      }

      // We're returning a Perl "object" of some kind.  Turn it into
      // a tied hash

      Printv(func,
	     tab4, "my %resulthash;\n",
	     tab4, "tie %resulthash, ref($result), $result;\n",
	     tab4, "return bless \\%resulthash, ref($result);\n",
	     "}\n",
	     0);

      need_stub = 1;
    } else {

      // Hmmm.  This doesn't appear to be anything I know about so just 
      // return it unmolested.

      Printv(func, tab4, "return $result;\n", "}\n", 0);
    }

    // Now check if we needed the stub.  If so, emit it, otherwise
    // Emit code to hack Perl's symbol table instead

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

// -----------------------------------------------------------------------
// PERL5::link_variable(char *name, char *iname, DataType *d)
//
// Create a link to a C variable.
// -----------------------------------------------------------------------

void PERL5::link_variable(char *name, char *iname, DataType *t)
{
  char  set_name[256];
  char  val_name[256];
  Wrapper  *getf, *setf;
  char  *tm;
  sprintf(set_name,"_wrap_set_%s",iname);
  sprintf(val_name,"_wrap_val_%s",iname);

  getf = NewWrapper();
  setf = NewWrapper();

  // Create a new scalar that we will attach magic to

  Printv(vinit, tab4, "sv = perl_get_sv(\"", package, "::", iname, "\",TRUE | 0x2);\n", 0);

  // Create a Perl function for setting the variable value

  if (!(Status & STAT_READONLY)) {
    Printf(setf->def,"SWIGCLASS_STATIC int %s(SV* sv, MAGIC *mg) {\n", set_name);
    Printv(setf->code,
	   tab4, "MAGIC_PPERL\n",
	   tab4, "mg = mg;\n",
	   0);

    /* Check for a few typemaps */
    if ((tm = typemap_lookup((char*)"varin",(char*)"perl5",t,(char*)"",(char*)"sv",name))) {
      Printf(setf->code,"%s\n", tm);
    } else if ((tm = typemap_lookup((char*)"in",(char*)"perl5",t,(char*)"",(char*)"sv",name))) {
      Printf(setf->code,"%s\n", tm);
    } else {
      if (!t->is_pointer) {
	
	// Set the value to something 
	
	switch(t->type) {
	case T_INT : case T_BOOL: case T_SINT : case T_UINT:
	case T_SHORT : case T_SSHORT : case T_USHORT:
	case T_LONG : case T_SLONG : case T_ULONG:
	case T_UCHAR: case T_SCHAR:
	  Printv(setf->code,tab4, name, " = ", t->print_cast(), " SvIV(sv);\n", 0);
	  break;
	case T_DOUBLE :
	case T_FLOAT :
	  Printv(setf->code, tab4, name, " = ", t->print_cast(), " SvNV(sv);\n", 0);
	  break;
	case T_CHAR :
	  Printv(setf->code, tab4, name, " = (char) *SvPV(sv,PL_na);\n", 0);
	  break;
	  
	case T_USER:
	  
	  // Add support for User defined type here
	  // Get as a pointer value
	  
	  t->is_pointer++;
	  Wrapper_add_local(setf,"_temp", "void *_temp");
	  get_pointer(iname,(char*)"value",(char*)"sv",(char*)"_temp", t, setf->code, (char*)"return(1)");
	  Printv(setf->code, tab4, name, " = *(", t->print_cast(), " _temp);\n", 0);
	  t->is_pointer--;
	  break;
	  
	default :
	  Printf(stderr,"%s : Line %d.  Unable to link with datatype %s (ignored).\n", input_file, line_number, t->print_type());
	  return;
	}
      } else {
	// Have some sort of pointer type here, Process it differently
	if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
	  Wrapper_add_local(setf,"_a","char *_a");
	  Printf(setf->code,"    _a = (char *) SvPV(sv,PL_na);\n");
	  
	  if (CPlusPlus)
	    Printv(setf->code,
		   tab4, "if (", name, ") delete [] ", name, ";\n",
		   tab4, name, " = new char[strlen(_a)+1];\n",
		   0);
	  else
	    Printv(setf->code,
		   tab4, "if (", name, ") free(", name, ");\n",
		   tab4, name, " = (char *) malloc(strlen(_a)+1);\n",
		   0);
	  Printv(setf->code,"strcpy(", name, ",_a);\n", 0);
	} else {
	  // Set the value of a pointer
	  
	  Wrapper_add_local(setf,"_temp","void *_temp");
	  get_pointer(iname,(char*)"value",(char*)"sv",(char*)"_temp", t, setf->code, (char*)"return(1)");
	  Printv(setf->code,tab4, name, " = ", t->print_cast(), " _temp;\n", 0);
	}
      }
    }
    Printf(setf->code,"    return 1;\n}\n");
    Replace(setf->code,"$name",iname, DOH_REPLACE_ANY);
    Wrapper_print(setf,magic);
    
  }

  // Now write a function to evaluate the variable
  
  Printf(getf->def,"SWIGCLASS_STATIC int %s(SV *sv, MAGIC *mg) {\n", val_name);
  Printv(getf->code,
	 tab4, "MAGIC_PPERL\n",
	 tab4, "mg = mg;\n",
	 0);

  // Check for a typemap
  
  if ((tm = typemap_lookup((char*)"varout",(char*)"perl5",t,(char*)"",name, (char*)"sv"))) {
    Printf(getf->code,"%s\n", tm);
  } else  if ((tm = typemap_lookup((char*)"out",(char*)"perl5",t,(char*)"",name,(char*)"sv"))) {
    Printf(getf->code,"%s\n", tm);
  } else {
    if (!t->is_pointer) {
      switch(t->type) {
      case T_INT : case T_BOOL: case T_SINT: case T_UINT:
      case T_SHORT : case T_SSHORT: case T_USHORT:
      case T_LONG : case T_SLONG : case T_ULONG:
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
	t->is_pointer++;
	Printv(getf->code,
	       tab4, "rsv = SvRV(sv);\n",
	       tab4, "sv_setiv(rsv,(IV) &", name, ");\n",
	       0);

	Wrapper_add_local(getf,"rsv","SV *rsv");
	Printv(vinit, tab4, "sv_setref_pv(sv,\"", t->print_mangle(), "\",(void *) &", name, ");\n",0);
	t->is_pointer--;
	
	break;
      default :
	break;
      }
    } else {
      
      // Have some sort of arbitrary pointer type.  Return it as a string
      
      if ((t->type == T_CHAR) && (t->is_pointer == 1))
	Printv(getf->code, tab4, "sv_setpv((SV*) sv, ", name, ");\n", 0);
      else {
	Printv(getf->code,
	       tab4, "rsv = SvRV(sv);\n",
	       tab4, "sv_setiv(rsv,(IV) ", name, ");\n",
	       0);

	Wrapper_add_local(getf,"rsv","SV *rsv");
	Printv(vinit, tab4, "sv_setref_pv(sv,\"", t->print_mangle(), "\",(void *) 1);\n",0);
      }
    }
  }
  Printf(getf->code,"    return 1;\n}\n");

  Replace(getf->code,"$name",iname, DOH_REPLACE_ANY);
  Wrapper_print(getf,magic);
  
  // Now add symbol to the PERL interpreter
  if (Status & STAT_READONLY) {
    Printv(vinit, tab4, "swig_create_magic(sv,\"", package, "::", iname, "\",MAGIC_CAST MAGIC_CLASS swig_magic_readonly, MAGIC_CAST MAGIC_CLASS ", val_name, ");\n",0);
  } else {
    Printv(vinit, tab4, "swig_create_magic(sv,\"", package, "::", iname, "\", MAGIC_CAST MAGIC_CLASS ", set_name, ", MAGIC_CAST MAGIC_CLASS ", val_name, ");\n",0);
  }      
  
  // If we're blessed, try to figure out what to do with the variable
  //     1.  If it's a Perl object of some sort, create a tied-hash
  //         around it.
  //     2.  Otherwise, just hack Perl's symbol table
  
  if (blessed) {
    if ((Getattr(classes,t->name)) && (t->is_pointer <= 1)) {
      Printv(var_stubs,
	     "\nmy %__", iname, "_hash;\n",
	     "tie %__", iname, "_hash,\"", GetChar(classes,t->name), "\", $",
	     package, "::", iname, ";\n",
	     "$", iname, "= \\%__", iname, "_hash;\n",
	     "bless $", iname, ", ", GetChar(classes,t->name), ";\n",
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

// -----------------------------------------------------------------------
// PERL5::declare_const(char *name, char *iname, DataType *type, char *value)
//
// Makes a constant.  Really just creates a variable and creates a read-only
// link to it.
// ------------------------------------------------------------------------

// Functions used to create constants

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
PERL5::declare_const(char *name, char *, DataType *type, char *value)
  {

  char   *tm;
  static  int have_int_func = 0;
  static  int have_double_func = 0;
  static  int have_char_func = 0;
  static  int have_ref_func = 0;

  if ((tm = typemap_lookup((char*)"const",(char*)"perl5",type,name,value,name))) {
    Printf(f_init,"%s\n",tm);
  } else {
    if ((type->type == T_USER) && (!type->is_pointer)) {
      Printf(stderr,"%s : Line %d.  Unsupported constant value.\n", input_file, line_number);
      return;
    }
    // Generate a constant 
    if (type->is_pointer == 0) {
      switch(type->type) {
      case T_INT:case T_SINT: case T_UINT: case T_BOOL:
      case T_SHORT: case T_SSHORT: case T_USHORT:
      case T_LONG: case T_SLONG: case T_ULONG:
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
	Printv(vinit, tab4, "swig_setpv(\"", package, "::", name, "\", \"", value, "\");\n",0);
	break;
      default:
	Printf(stderr,"%s : Line %d. Unsupported constant value.\n", input_file, line_number);
	break;
      }
    } else {
      if ((type->type == T_CHAR) && (type->is_pointer == 1)) {
	if (!have_char_func) {
	  Printf(f_header,"%s\n",setpv);
	  have_char_func = 1;
	}
	Printv(vinit, tab4, "swig_setpv(\"", package, "::", name, "\", \"", value, "\");\n",0);
      } else {
	// A user-defined type.  We're going to munge it into a string pointer value
	if (!have_ref_func) {
	  Printf(f_header,"%s\n",setrv);
	  have_ref_func = 1;
	}
	Printv(vinit, tab4, "swig_setrv(\"", package, "::", name, "\", (void *) ", value, ", \"", 
	      type->print_mangle(), "\");\n", 0);
      }
    }
  }

  if (blessed) {
    if ((Getattr(classes,type->name)) && (type->is_pointer <= 1)) {
      Printv(var_stubs,
	     "\nmy %__", name, "_hash;\n",
	     "tie %__", name, "_hash,\"", GetChar(classes,type->name), "\", $",
	     package, "::", name, ";\n",
	     "$", name, "= \\%__", name, "_hash;\n",
	     "bless $", name, ", ", GetChar(classes,type->name), ";\n",
	     0);
    } else {
      Printv(var_stubs, "*",name," = *", package, "::", name, ";\n", 0);
    }
  }
  if (export_all)
    Printf(exported,"$%s ",name);
}

// ----------------------------------------------------------------------
// PERL5::usage_var(char *iname, DataType *t)
//
// Produces a usage string for a Perl 5 variable.
// ----------------------------------------------------------------------

char *PERL5::usage_var(char *iname, DataType *) {

  static char temp[1024];
  char *c;

  sprintf(temp,"$%s", iname);
  c = temp + strlen(temp);
  return temp;
}

// ---------------------------------------------------------------------------
// char *PERL5::usage_func(pkg, char *iname, DataType *t, ParmList *l)
// 
// Produces a usage string for a function in Perl
// ---------------------------------------------------------------------------

char *PERL5::usage_func(char *iname, DataType *, ParmList *l) {

  static DOHString *temp = 0;
  Parm  *p;
  int    i;

  if (!temp) temp = NewString("");

  Clear(temp);
  Printf(temp,"%s(",iname);
  
  /* Now go through and print parameters */

  p = l->get_first();
  i = 0;
  while (p != 0) {
    if (!p->ignore) {
      /* If parameter has been named, use that.   Otherwise, just print a type  */

      if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
	if (strlen(p->name) > 0) {
	  Printf(temp,"%s",p->name);
	} else {
	  Printf(temp,"%s",p->t->print_type());
	}
      }
      i++;
      p = l->get_next();
      if (p)
	if (!p->ignore)
	  Putc(',',temp);
    } else {
      p = l->get_next();
      if (p) 
	if ((i>0) && (!p->ignore))
	  Putc(',',temp);
    }
  }
  Printf(temp,");");
  return Char(temp);
}

// ----------------------------------------------------------------------
// PERL5::usage_const(char *iname, DataType *type, char *value)
//
// Produces a usage string for a Perl 5 constant
// ----------------------------------------------------------------------

char *PERL5::usage_const(char *iname, DataType *, char *value) {

  static char temp[1024];
  if (value) {
    sprintf(temp,"$%s = %s", iname, value);
  } else {
    sprintf(temp,"$%s", iname);
  }
  return temp;
}

// -----------------------------------------------------------------------
// PERL5::add_native(char *name, char *funcname, DataType *, ParmList *)
//
// Add a native module name to Perl5.
// -----------------------------------------------------------------------

void PERL5::add_native(char *name, char *funcname, DataType *, ParmList *) {
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

static int class_renamed = 0;
static char fullclassname[1024] = "";

// --------------------------------------------------------------------------
// PERL5::cpp_open_class(char *classname, char *rname, int strip)
//
// Opens a new C++ class or structure.   Basically, this just records
// the class name and clears a few variables.
// --------------------------------------------------------------------------

void PERL5::cpp_open_class(char *classname, char *rname, char *ctype, int strip) {

  char temp[256];
  extern void typeeq_addtypedef(char *, char *, DataType *);

  // Register this with the default class handler

  this->Language::cpp_open_class(classname, rname, ctype, strip);
  
  if (blessed) {
    have_constructor = 0;
    have_destructor = 0;
    have_data_members = 0;

    // If the class is being renamed to something else, use the renaming

    if (rname) {
      class_name = Swig_copy_string(rname);
      class_renamed = 1;
      // Now things get even more hideous.   Need to register an equivalence
      // between the renamed name and the new name. Yuck!
      //      printf("%s %s\n", classname, rname);
        typeeq_addtypedef(classname,rname,0);
        typeeq_addtypedef(rname,classname,0);
     /*
      Printf(f_init,"\t SWIG_RegisterMapping(\"%s\",\"%s\",0);\n",classname,rname);
      Printf(f_init,"\t SWIG_RegisterMapping(\"%s\",\"%s\",0);\n",rname,classname);
      */
    } else {
      class_name = Swig_copy_string(classname);
      class_renamed = 0;
    }

    // A highly experimental feature.  This is the fully qualified
    // name of the Perl class

    if (!compat) {
      sprintf(fullclassname,"%s::%s", realpackage,class_name);
    } else {
      strcpy(fullclassname,class_name);
    }

    if(!hidden) {
      strcpy(fullclassname, class_name);
    }

    real_classname = Swig_copy_string(classname);
    if (base_class) Delete(base_class);
    base_class =  0;
    class_type = Swig_copy_string(ctype);
    pcode = NewString("");
    blessedmembers = NewString("");
    member_keys = NewString("");

    // Add some symbols to the hash tables

    //    classes.add(real_classname,Swig_copy_string(class_name));   /* Map original classname to class */
    Setattr(classes,real_classname,fullclassname);

    // Add full name of datatype to the hash table just in case the user uses it

    sprintf(temp,"%s %s", class_type, fullclassname);
  }
}

// -------------------------------------------------------------------------------
// PERL5::cpp_close_class()
//
// These functions close a class definition.   
//
// This also sets up the hash table of classes we've seen go by.
// -------------------------------------------------------------------------------

void PERL5::cpp_close_class() {

  // We need to check to make sure we got constructors, and other
  // stuff here.

  if (blessed) {
    Printv(pm,
	   "\n############# Class : ", fullclassname, " ##############\n",
	   "\npackage ", fullclassname, ";\n",
	   0);

    // If we are inheriting from a base class, set that up

    if (strcmp(class_name,realpackage))
      Printv(pm, "@ISA = qw( ",realpackage, 0);
    else 
      Printv(pm, "@ISA = qw( ", 0);

    if (base_class) {
      Printv(pm, " ", (hidden ? realpackage : ""), (hidden ? "::" : ""), base_class, 0);
    }
    Printf(pm, " );\n");

    // Dump out a hash table containing the pointers that we own

    Printf(pm, "%OWNER = ();\n");
    if (have_data_members) {
      Printv(pm, 
	     "%BLESSEDMEMBERS = (\n", blessedmembers, ");\n\n",
	     0);
    }
    if (have_data_members || have_destructor)
      Printf(pm, "%ITERATORS = ();\n");


    // Dump out the package methods

    Printv(pm,pcode,0);
    Delete(pcode);

    // Output methods for managing ownership


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

    // Only output the following methods if a class has member data

    if (have_data_members) {

      // Output a FETCH method.  This is actually common to all classes
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
      
      // Output a STORE method.   This is also common to all classes (might move to base class)

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

      // Output a FIRSTKEY method.   This is to allow iteration over a structure's keys.

      Printv(pm,
	     "sub FIRSTKEY {\n",
	     tab4, "my $self = shift;\n",
	     tab4, "$ITERATORS{$self} = [", member_keys, "];\n",
	     tab4, "my $first = shift @{$ITERATORS{$self}};\n",
	     tab4, "return $first;\n",
	     "}\n\n",
	     0);

      // Output a NEXTKEY method.   This is the iterator so that each and keys works

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

// --------------------------------------------------------------------------
// PERL5::cpp_member_func(char *name, char *iname, DataType *t, ParmList *l)
//
// Handles a C++ member function.    This basically does the same thing as
// the non-C++ version, but we set up a few status variables that affect
// the function generation function.
//
// --------------------------------------------------------------------------

void PERL5::cpp_member_func(char *name, char *iname, DataType *t, ParmList *l) {

  DOHString  *func;
  char    *realname;
  Parm    *p;
  int      i;
  DOHString  *cname;
  int      pcount, numopt;
  char    *tm;

  // First emit normal member function

  member_func = 1;
  this->Language::cpp_member_func(name,iname,t,l);
  member_func = 0;

  if (!blessed) return;

  func = NewString("");
  cname = NewString("perl5:");

  // Now emit a Perl wrapper function around our member function, we might need
  // to patch up some arguments along the way

  if (!iname)
    realname = name;
  else
    realname = iname;

  Printf(cname,"%s::%s",class_name,realname);
  if (Getattr(symbols,cname)) {
    return;   // Forget it, we saw this already
  }
  Setattr(symbols,cname,cname);

  Printv(func,
	 "sub ", realname, " {\n",
	 tab4, "my @args = @_;\n",
         tab4, "$args[0] = tied(%{$args[0]});\n",
	 0);

  // Now we have to go through and patch up the argument list.  If any
  // arguments to our function correspond to other Perl objects, we
  // need to extract them from a tied-hash table object.

  p = l->get_first();
  pcount = l->nparms;
  numopt = l->numopt();
  i = 1;
  while(p) {
    if (!p->ignore) {
      char sourceNtarget[512];
      sprintf(sourceNtarget, "$args[%d]", i);

      if ((tm = typemap_lookup((char*)"perl5in",(char*)"perl5",p->t,(char*)"",sourceNtarget,sourceNtarget))) {
	Printf(func,"%s\n",tm);
      }
      // Look up the datatype name here
      else if ((Getattr(classes,p->t->name)) && (p->t->is_pointer <= 1)) {
	// Yep.   This smells alot like an object, patch up the arguments

	if (i >= (pcount - numopt))
	  Printf(func,"    if (scalar(@args) >= %d) {\n", i);

	Printf(func,"    $args[%d] = tied(%%{$args[%d]});\n", i, i);
	if (i >= (pcount - numopt))
	  Printf(func,"    }\n");
      }
      i++;
    }
    p = l->get_next();
  }
  
  // Okay.  We've made argument adjustments, now call into the package

  Printv(func,
	 tab4, "my $result = ", package, "::", Swig_name_member(class_name,realname),
        "(@args);\n",
	 0);
  
  // Now check to see what kind of return result was found.
  // If this function is returning a result by 'value', SWIG did an 
  // implicit malloc/new.   We'll mark the object like it was created
  // in Perl so we can garbage collect it.

  if ((tm = typemap_lookup((char*)"perl5out",(char*)"perl5",t,(char*)"",name,(char*)"sv"))) {
    Printv(func,
	   tm, "\n",
	   tab4,"return $result;\n",
	   "}\n",
	   0);

  } else if ((Getattr(classes,t->name)) && (t->is_pointer <=1)) {
    
    Printv(func,tab4, "return undef if (!defined($result));\n", 0);

    // If we're returning an object by value, put it's reference
    // into our local hash table

    if ((t->is_pointer == 0) || ((t->is_pointer == 1) && NewObject)) {
      char *name = GetChar(classes,t->name);
      if (hidden)
	Printv(func, tab4, "$", realpackage, "::", name, "::OWNER{$result} = 1;\n", 0);
      else
	Printv(func, tab4, "$", name, "::OWNER{$result} = 1; \n", 0);
    }

    // We're returning a Perl "object" of some kind.  Turn it into
    // a tied hash

    Printv(func,
	   tab4, "my %resulthash;\n",
	   tab4, "tie %resulthash, ref($result), $result;\n",
	   tab4, "return bless \\%resulthash, ref($result);\n",
	   "}\n",
	   0);

  } else {

    // Hmmm.  This doesn't appear to be anything I know about so just 
    // return it unmolested.

    Printv(func, tab4,"return $result;\n", "}\n", 0);
  }

  // Append our function to the pcode segment
  Printv(pcode,func,0);
  Delete(func);
  Delete(cname);
}

// --------------------------------------------------------------------------------
// PERL5::cpp_variable(char *name, char *iname, DataType *t)
//
// Adds an instance member.   This is a little hairy because data members are
// really added with a tied-hash table that is attached to the object.
//
// On the low level, we will emit a pair of get/set functions to retrieve
// values just like before.    These will then be encapsulated in a FETCH/STORE
// method associated with the tied-hash.
//
// In the event that a member is an object that we have already wrapped, then
// we need to retrieve the data a tied-hash as opposed to what SWIG normally
// returns.   To determine this, we build an internal hash called 'BLESSEDMEMBERS'
// that contains the names and types of tied data members.  If a member name
// is in the list, we tie it, otherwise, we just return the normal SWIG value.
// --------------------------------------------------------------------------------

void PERL5::cpp_variable(char *name, char *iname, DataType *t) {

  char *realname;
  DOHString *cname;

  cname = NewString("perl5:");

  // Emit a pair of get/set functions for the variable

  member_func = 1;
  this->Language::cpp_variable(name, iname, t);  
  member_func = 0;

  if (iname) realname = iname;
  else realname = name;

  if (blessed) {
    Printf(cname,"%s::%s", class_name, realname);
    if (Getattr(symbols,cname)) {
      Delete(cname);
      return;    // Forget it, we saw this already
    }
    Setattr(symbols,cname,cname);
	
    // Store name of key for future reference
    Printf(member_keys,"'%s', ", realname);

    // Now we need to generate a little Perl code for this

    if ((Getattr(classes,t->name)) && (t->is_pointer <= 1)) {

      // This is a Perl object that we have already seen.  Add an
      // entry to the members list
      Printv(blessedmembers,
	     tab4, realname, " => '", (hidden ? realpackage : ""), (hidden ? "::" : ""), GetChar(classes,t->name), "',\n",
	     0);
      
     }
  }
  have_data_members++;
  Delete(cname);
}

// -----------------------------------------------------------------------------
// void PERL5::cpp_constructor(char *name, char *iname, ParmList *l)
//
// Emits a blessed constructor for our class.    In addition to our construct
// we manage a Perl hash table containing all of the pointers created by
// the constructor.   This prevents us from accidentally trying to free 
// something that wasn't necessarily allocated by malloc or new
// -----------------------------------------------------------------------------

void PERL5::cpp_constructor(char *name, char *iname, ParmList *l) {
  Parm *p;
  int   i;
  char  *realname;
  DOHString *cname;

  cname = NewString("perl5:constructor:");

  // Emit an old-style constructor for this class

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
      return;    // Forget it, we saw this already
    }
    Setattr(symbols,cname, cname);
    if ((strcmp(realname,class_name) == 0) || ((!iname) && (ObjCClass)) ){
      
      // Emit a blessed constructor 

      Printf(pcode, "sub new {\n");

    } else {
      
      // Constructor doesn't match classname so we'll just use the normal name 

      Printv(pcode, "sub ", Swig_name_construct(realname), " () {\n", 0);
	
    }

    Printv(pcode, tab4, "my $self = shift;\n",
	   tab4, "my @args = @_;\n", 0);

    // We are going to need to patch up arguments here if necessary
    // Now we have to go through and patch up the argument list.  If any
    // arguments to our function correspond to other Perl objects, we
    // need to extract them from a tied-hash table object.
    
    p = l->get_first();
    i = 0;
    while(p) {
      
      // Look up the datatype name here
      
      if ((Getattr(classes,p->t->name)) && (p->t->is_pointer <= 1)) {
	
	// Yep.   This smells alot like an object, patch up the arguments
	Printf(pcode, "    $args[%d] = tied(%%{$args[%d]});\n", i, i);
      }
      p = l->get_next();
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


// ------------------------------------------------------------------------------
// void PERL5::cpp_destructor(char *name, char *newname)
//
// Creates a destructor for a blessed object
// ------------------------------------------------------------------------------

void PERL5::cpp_destructor(char *name, char *newname) {

  char *realname;
  member_func = 1;
  this->Language::cpp_destructor(name, newname);

  if (blessed) {
    if (newname) realname = newname;
    else {
      if (class_renamed) realname = class_name;
      else realname = name;
    }

    // Emit a destructor for this object

    Printv(pcode,
	   "sub DESTROY {\n",
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
// -----------------------------------------------------------------------------
// void PERL5::cpp_static_func(char *name, char *iname, DataType *t, ParmList *l)
//
// Emits a wrapper for a static class function.   Basically, we just call the
// appropriate method in the module package.
// ------------------------------------------------------------------------------
void PERL5::cpp_static_func(char *name, char *iname, DataType *t, ParmList *l) {
  this->Language::cpp_static_func(name,iname,t,l);
  char *realname;
  if (iname) realname = name;
  else realname = iname;

  if (blessed) {
    Printv(pcode, "*", realname, " = *", realpackage, "::", Swig_name_member(class_name,realname), ";\n", 0);
  }
}
  
// ------------------------------------------------------------------------------
// void PERL5::cpp_inherit(char **baseclass, int mode) 
//
// This sets the Perl5 baseclass (if possible).
// ------------------------------------------------------------------------------

void PERL5::cpp_inherit(char **baseclass, int) {

  char *bc;
  int  i = 0, have_first = 0;
  if (!blessed) {
    this->Language::cpp_inherit(baseclass);
    return;
  }

  // Inherit variables and constants from base classes, but not 
  // functions (since Perl can handle that okay).

  this->Language::cpp_inherit(baseclass, INHERIT_CONST | INHERIT_VAR);

  // Now tell the Perl5 module that we're inheriting from base classes

  base_class = NewString("");
  while (baseclass[i]) {
    // See if this is a class we know about
    bc = GetChar(classes,baseclass[i]);
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

// --------------------------------------------------------------------------------
// PERL5::cpp_declare_const(char *name, char *iname, DataType *type, char *value)
//
// Add access to a C++ constant.  We can really just do this by hacking
// the symbol table
// --------------------------------------------------------------------------------

void PERL5::cpp_declare_const(char *name, char *iname, DataType *type, char *value) {
  char *realname;
  int   oldblessed = blessed;
  char cname[256];
  
  // Create a normal constant
  blessed = 0;
  this->Language::cpp_declare_const(name, iname, type, value);
  blessed = oldblessed;

  if (blessed) {
    if (!iname)
      realname = name;
    else
      realname = iname;

    sprintf(cname,"%s::%s",class_name,realname);
    if (Getattr(symbols, cname)) {
      return;    // Forget it, we saw this already
    }
    Setattr(symbols, cname,cname);

    // Create a symbol table entry for it
    Printv(pcode, "*", realname, " = *", package, "::", Swig_name_member(class_name,realname), ";\n", 0);
  }
}

// -----------------------------------------------------------------------
// PERL5::cpp_class_decl(char *name, char *rename, char *type)
//
// Treatment of an empty class definition.    Used to handle
// shadow classes across modules.
// -----------------------------------------------------------------------

void PERL5::cpp_class_decl(char *name, char *rename, char *type) {
    char temp[256];
    if (blessed) {
	Setattr(classes, name, rename);
	// Add full name of datatype to the hash table
	if (strlen(type) > 0) {
	  sprintf(temp,"%s %s", type, name);
	  Setattr(classes,temp,rename);
	}
    }
}

// --------------------------------------------------------------------------------
// PERL5::add_typedef(DataType *t, char *name)
//
// This is called whenever a typedef is encountered.   When shadow classes are
// used, this function lets us discovered hidden uses of a class.  For example :
//
//     struct FooBar {
//            ...
//     }
//
// typedef FooBar *FooBarPtr;
//
// --------------------------------------------------------------------------------

void PERL5::add_typedef(DataType *t, char *name) {

  if (!blessed) return;

  // First check to see if there aren't too many pointers

  if (t->is_pointer > 1) return;

  if (Getattr(classes,name)) return;      // Already added

  // Now look up the datatype in our shadow class hash table

  if (Getattr(classes,t->name)) {

    // Yep.   This datatype is in the hash
    
    // Put this types 'new' name into the hash

    Setattr(classes,name,GetChar(classes,t->name));
  }
}


// --------------------------------------------------------------------------------
// PERL5::pragma(char *, char *, char *)
//
// Pragma directive.
//
// %pragma(perl5) code="String"              # Includes a string in the .pm file
// %pragma(perl5) include="file.pl"          # Includes a file in the .pm file
// 
// --------------------------------------------------------------------------------

void PERL5::pragma(char *lang, char *code, char *value) {
  if (strcmp(lang,"perl5") == 0) {
    if (strcmp(code,"code") == 0) {
      // Dump the value string into the .pm file
      if (value) {
	Printf(pragma_include, "%s\n", value);
      }
    } else if (strcmp(code,"include") == 0) {
      // Include a file into the .pm file
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




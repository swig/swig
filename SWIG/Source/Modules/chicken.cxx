/********************************************************************
 * CHICKEN module for SWIG
 *
 * Author : Jonah Beckford
 *
 * Modified from mzscheme.cxx, guile.cxx and python.cxx : David
 * Beazley
 *
 * Please read the file LICENSE for the copyright and terms by which
 * SWIG can be used and distributed.
 *
 ********************************************************************/

char cvsroot_chicken_cxx[] = "$Header$";

/***********************************************************************
 * $Header$
 *
 * chicken.cxx
 *
 * Definitions for adding functions to CHICKEN
 ***********************************************************************/

#include "swigmod.h"

#include <ctype.h>

static const char *chicken_usage = (char*)"\
\
CHICKEN Options (available with -chicken)\n\
     -prefix <name>  - Set a prefix <name> to be prepended to all names\n\
                       Defaults to the name of the module\n\
     -noprefix       - Don't use a prefix\n\
     -mixed          - Convert mixed case (ex. aMethodName) into\n\
                       dash seperated, lower case (ex. a-method-name)\n\
     -noclos         - Don't generate clos TinyCLOS code\n\
     -nogeneric      - Don't generate (make-generic) definitions\n\
\n"
;

#define SCMCLOS_MEMBER         0x2
#define SCMCLOS_STATIC_MEMBER  0x4

static String        *prefix=0;
static int           noprefix=0;
static String        *module=0;
static String        *realmodule=0;
static char          *chicken_path=(char*)"chicken";
static int           clos = 1;
static int           generic = 1;
static int           mixed = 0;
static int           num_methods = 0;

static  File         *f_runtime = 0;
static  File         *f_header = 0;
static  File         *f_wrappers = 0;
static  File         *f_sym_size = 0;
static  File         *f_init = 0;
static  File         *f_scm = 0;
static  File         *f_scm_stubs = 0;
static  File         *f_clos = 0;
static  File         *f_generic = 0;

static  String       *clos_indent = 0;

/* C++ Support + Clos Classes */
static  int          in_class = 0;
static  int          classic = 0;
static  int          have_constructor;

static  String       *class_name  = 0;
static  String       *short_class_name  = 0;
static  String       *real_classname;

static  Hash         *known_classes = 0;

class CHICKEN : public Language {
public:

  virtual void main(int argc, char *argv[]);
  virtual int  top(Node *n);
  virtual int  importDirective(Node *n); 
  virtual int  insertDirective(Node *n); 
  virtual int  functionWrapper(Node *n); 
  /* ------------------------------------------------------------
   * variableWrapper()
   *
   * Create a link to a C variable.  This creates a single function
   * _wrap_swig_var_varname().  This function takes a single optional
   * argument.  If supplied, it means we are setting this variable to
   * some value.  If omitted, it means we are simply evaluating this
   * variable.  Either way, we return the variables value.
   * ------------------------------------------------------------ */
  virtual int  variableWrapper(Node *n);
  virtual int  constantWrapper(Node *n);
  virtual int  classDeclaration(Node *n);
  virtual int  classHandler(Node *n);
  virtual int  memberfunctionHandler(Node *n);
  virtual int  membervariableHandler(Node *n);
  virtual int  memberconstantHandler(Node *n);
  virtual int  staticmemberfunctionHandler(Node *n);
  virtual int  staticmembervariableHandler(Node *n); 
  virtual int  destructorHandler(Node *n);
  virtual int  constructorHandler(Node *n);
  virtual int  validIdentifier(String *s);

protected:
  void    addMethod(String *, String *scheme_name, String *function);
  void    throwUnhandledChickenTypeError(SwigType *d);
  /* Return true iff T is a pointer type */
  int     isPointer(SwigType *t);
  void    dispatchFunction(Node *n);
  /* Output CHICKEN code into the clos file */
  String* chickenCode(String *code, const String *indent);
  void    namify(String *scmname);
  /* search for a typemap("TYPEMAP") SEARCHCLASS */
  String* singleSearch(const char *typemap, char *argname, 
		       SwigType *searchClass);
  /* do a recursive search for a typemap("TYPEMAP") SEARCHCLASS.
     example: typename can be "in" or "out"; argname can be "result"
     for output typemaps or Getattr(parm, "name") for an input
     parameter, and 'n' may be a class definition or anything else. */
  String* recurseSearch(const char *typemap, char *argname, Node *n);
};

/* -----------------------------------------------------------------------
 * swig_chicken()    - Instantiate module
 * ----------------------------------------------------------------------- */

static Language * new_swig_chicken() {
  return new CHICKEN();
}
extern "C" Language * swig_chicken(void) {
  return new_swig_chicken();
}

void 
CHICKEN::main(int argc, char *argv[])
{
  int i;
    
  SWIG_library_directory(chicken_path);
    
  // Look for certain command line options
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i], "-help") == 0) {
	fputs(chicken_usage, stderr);
	SWIG_exit(0);
      } 
      else if (strcmp(argv[i], "-prefix") == 0) {
	if (argv[i + 1]) {
	  prefix = NewString(argv [i + 1]);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i + 1);
	  i++;
	} 
	else {
	  Swig_arg_error();
	}
      } 
      else if (strcmp(argv[i],"-noprefix") == 0) {
	noprefix = 1;
	Swig_mark_arg(i);
      }
      else if (strcmp(argv[i],"-mixed") == 0) {
	mixed = 1;
	Swig_mark_arg(i);
      }
      else if (strcmp(argv[i],"-noclos") == 0) {
	clos = 0;
	Swig_mark_arg(i);
      }
      else if (strcmp(argv[i],"-nogeneric") == 0) {
	generic = 0;
	Swig_mark_arg(i);
      }
    }
  }
    
  // Add a symbol for this module
    
  Preprocessor_define("SWIGCHICKEN 1",0);
    
  // Set name of typemaps
    
  SWIG_typemap_lang("chicken");

  // Read in default typemaps */
  SWIG_config_file("chicken.swg");
  allow_overloading();
}
  
int
CHICKEN::top(Node *n)
{
  String *chicken_filename;
  String *clos_filename;
  String *generic_filename;

  if (!CPlusPlus) {
    clos = 0;
    generic = 0;
  }

  known_classes = NewHash();

  /* Initialize all of the output files */
  String *outfile = Getattr(n,"outfile");
    
  f_runtime = NewFile(outfile,"w");
  if (!f_runtime) {
    Printf(stderr,"*** Can't open '%s'\n", outfile);
    SWIG_exit(EXIT_FAILURE);
  }
  f_sym_size = NewString("");
  f_init = NewString("");
  f_header = NewString("");
  f_wrappers = NewString("");
  chicken_filename = NewString("");
  clos_filename = NewString("");
  generic_filename = NewString("");
    
  /* Register file targets with the SWIG file handler */
  Swig_register_filebyname("header",f_header);
  Swig_register_filebyname("wrapper",f_wrappers);
  Swig_register_filebyname("runtime",f_runtime);
  Swig_register_filebyname("init",f_init);
    
  Printf(f_runtime, "/* -*- buffer-read-only: t -*- vi: set ro: */\n");
  Swig_banner(f_runtime);
    
  if (NoInclude) {
    Printf(f_runtime, "#define SWIG_NOINCLUDE\n");
  }
    
  /* Set module name */
  realmodule = Copy(Getattr(n,"name"));
  module = Copy(realmodule);
  namify(module);
    
  /* Set prefix.  If a prefix has been specified make sure it ends
     in a '-' */
  if (noprefix) {
    prefix = NewString("");
  }
  else {
    if (!prefix) {
      prefix = Copy(module);
    }
    if (Len(prefix) && ((Char(prefix)) [Len(prefix) - 1] != ':')) {
      Append(prefix, ":");
    }
  }
    
  Printf(chicken_filename,"%s%s.scm", SWIG_output_directory(), module);
  if ((f_scm = NewFile(chicken_filename,"w")) == 0) {
    Printf(stderr,"Unable to open %s\n", chicken_filename);
    SWIG_exit(EXIT_FAILURE);
  }
  f_scm_stubs = NewString("");

  Swig_register_filebyname("chicken",f_scm);

  Printv(f_scm,
	 ";; -*- buffer-read-only: t -*- vi: set ro:\n",
	 ";; This file was created automatically by SWIG.\n",
	 ";; Don't modify this file, modify the SWIG interface instead.\n",
	 NIL);
  Printv(f_scm,"(cond-expand ((or chicken-compile-shared shared)) (else (declare (unit ", module, "))))\n\n", NIL);
#ifndef INIT_BINDING
  Printv(f_scm,"(declare \n",
	 tab4, "(hide swig-init)\n",
	 tab4, "(foreign-declare \"C_extern void ", realmodule, 
	 "_swig_init(int,C_word,C_word) C_noret;\"))\n", NIL);
  Printv(f_scm,"(define swig-init (##core#primitive \"", realmodule,
	 "_swig_init\"))\n", NIL);
  Printv(f_scm,"(swig-init)\n\n", NIL);
#endif

  // Include some information in the code
  Printf(f_header,"\n/*-----------------------------------------------\n              @(target):= %s.so\n\
  ------------------------------------------------*/\n", module);


  if (generic) {
    Printf(generic_filename,"%s%s-generic.scm", 
	   SWIG_output_directory(), module);
    if ((f_generic = NewFile(generic_filename,"w")) == 0) {
      Printf(stderr,"Unable to open %s\n", generic_filename);
      SWIG_exit (EXIT_FAILURE);
    }

    Swig_register_filebyname("generic",f_generic);

    Printv(f_generic,
	   ";; -*- buffer-read-only: t -*- vi: set ro:\n",
	   ";; This file was created automatically by SWIG.\n",
	   ";; Don't modify this file, modify the SWIG interface instead.\n",
	   NIL);
  }

  if (clos) {
    Printf(clos_filename,"%s%s-clos.scm", SWIG_output_directory(), module);
    if ((f_clos = NewFile(clos_filename,"w")) == 0) {
      Printf(stderr,"Unable to open %s\n", clos_filename);
      SWIG_exit (EXIT_FAILURE);
    }

    Swig_register_filebyname("clos",f_clos);

    Printv(f_clos,
	   ";; -*- buffer-read-only: t -*- vi: set ro:\n",
	   ";; This file was created automatically by SWIG.\n",
	   ";; Don't modify this file, modify the SWIG interface instead.\n",
	   NIL);
    Printf (f_clos, "(declare (uses extras))\n");
  }

  Printf(f_header,"#define SWIG_name    \"%s\"\n", realmodule);

  Printf(f_wrappers,"#ifdef __cplusplus\n");
  Printf(f_wrappers,"extern \"C\" {\n");
  Printf(f_wrappers,"#endif\n\n");

#ifdef INIT_BINDING
  {
    String *tmp = NewString("");
    String *tmp2 = NewString("swig-init");
    Printv(tmp, realmodule, "_swig_init", NIL);
    addMethod(tmp, tmp2, tmp);
    Delete(tmp);
    Delete(tmp2);
  }
#endif

  /* emit code */
  Language::top(n);

  /* Close language module */

  SwigType_emit_type_table(f_runtime, f_wrappers);

  Printf(f_wrappers,"#ifdef __cplusplus\n");
  Printf(f_wrappers,"}\n");
  Printf(f_wrappers,"#endif\n");

  Printf(f_init, "C_kontinue (continuation, ret);\n");
  Printf(f_init, "}\n\n");

  char buftmp[20];
  sprintf(buftmp, "%d", num_methods);
  Replaceall(f_init, "$nummethods", buftmp);
  Replaceall(f_init, "$symsize", f_sym_size);

  Delete(chicken_filename);
  Delete(clos_filename);
  Delete(generic_filename);

  Printv(f_scm, f_scm_stubs, "\n",NIL);
  Close(f_scm);
  Delete(f_scm);

  if (clos) {
    Close(f_clos);
    Delete(f_clos);
  }

  if (generic) {
    Close(f_generic);
    Delete(f_generic);
  }

  Delete(prefix);
  Delete(known_classes);

  /* Close all of the files */
  Dump(f_header,f_runtime);
  Dump(f_wrappers,f_runtime);
  Wrapper_pretty_print(f_init,f_runtime);
  Delete(f_header);
  Delete(f_wrappers);
  Delete(f_sym_size);
  Delete(f_init);
  Close(f_runtime);
  Delete(f_runtime);
  return SWIG_OK;
}
  
int
CHICKEN::importDirective(Node *n)
{
  String *modname = Getattr(n,"module");
  if (modname) {
    Printf(f_scm,"(declare (uses %s))\n", modname);
  }
  return Language::importDirective(n);
}

int
CHICKEN::insertDirective(Node *n)
{
  String *code = Getattr(n,"code");
  Replaceall(code, "$module", module);
  Replaceall(code, "$realmodule", realmodule);
  return Language::insertDirective(n);
}

int
CHICKEN::functionWrapper(Node *n)
{
  
  String  *name  = Getattr(n,"name");
  String  *iname = Getattr(n,"sym:name");
  SwigType *d    = Getattr(n,"type");
  ParmList *l    = Getattr(n,"parms");

  Parm    *p;
  int     i;
  String *wname;
  char    source[64];
  Wrapper *f;
  String *mangle = NewString("");
  String *get_pointers;
  String *cleanup;
  String *outarg;
  String *tm;
  String *overname = 0;
  String *declfunc = 0;
  String *scmname;
  String *closparam;
  String *closargs;
  String *closwrapargs;

  int     num_required;
  int     num_arguments;

  Printf(mangle, "\"%s\"", SwigType_manglestr(d));

  if (Getattr(n,"sym:overloaded")) {
    overname = Getattr(n,"sym:overname");
  } else {
    if (!addSymbol(iname,n)) return SWIG_ERROR;
  }

  f = NewWrapper();
  wname        = NewString("");
  get_pointers = NewString("");
  cleanup      = NewString("");
  outarg       = NewString("");
  declfunc     = NewString("");
  closargs     = NewString("");
  closwrapargs = NewString("");
  scmname      = NewString(iname);
  namify(scmname);

  /* Local vars */
  Wrapper_add_local(f,"resultobj", "C_word resultobj");
  Wrapper_add_local(f,"resultobjlast", "C_word resultobjlast");
  Wrapper_add_local(f,"gswig_list_p", "int gswig_list_p = 0");

  /* Write code to extract function parameters. */
  emit_args(d, l, f);

  /* Attach the standard typemaps */
  emit_attach_parmmaps(l,f);
  Setattr(n,"wrap:parms",l);

  /* Get number of required and total arguments */
  num_arguments = emit_num_arguments(l);
  num_required  = emit_num_required(l);

  Append(wname, realmodule);
  Append(wname, Swig_name_wrapper(iname));
  if (overname) {
    Append(wname, overname);
  }

  // Check for interrupts
  Printv (f->code, "C_trace(\"",scmname,"\");\n", NIL);

  Printv(f->def,
#ifndef BINDING
	 "static ",
#endif
	 "void ", wname,
	 " (int argc, C_word closure, C_word continuation",
	 NIL);
  Printv(declfunc,
	 "void ", wname,
	 "(int,C_word,C_word",
	 NIL);

  /* Generate code for argument marshalling */
  for (i = 0, p=l; i < num_arguments; i++) {
    
    while (checkAttribute(p,"tmap:in:numinputs","0")) {
      p = Getattr(p,"tmap:in:next");
    }

    SwigType *pt = Getattr(p,"type");
    String   *pn = Getattr(p,"name");
    String   *ln = Getattr(p,"lname");
    SwigType *pb = SwigType_base(pt);

    sprintf(source,"scm%d",i+1);

    Printf(f->def, ", C_word scm%d", i+1);
    Printf(declfunc,",C_word");

    closparam = NewString("");
    Printf(closparam, "%%%d", i+1);
    Printv(closargs, " ", closparam, NIL);

    /* Look for an clos input conversion */
    int gotwrap = 0;
    Node *search;
    String *tm = 0;
    if ((search = Getattr(known_classes, pb)) || 
	(tm = singleSearch("clos_in", Char(pn), pb))) {
      /* search for typemap("clos_in") CLASS_OR_BASE_CLASS */
      if (tm || (tm = recurseSearch("clos_in", Char(pn), search))) {
	String *cn = NewString("");
	Printv(cn, "<", prefix, pb, ">", NIL);
	namify(cn);

	Replaceall(tm, "$class", cn);
	Replaceall(tm, "$input", closparam);

	Printv(closwrapargs, " ", tm, NIL);

	gotwrap = 1;
	Delete(cn);
      }
      else {
	/*Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number,
		     "Unable to find \"%%typemap(clos_in) %s *\" "
		     "or typemaps for any superclasses.\n", 
		     SwigType_str(pb,0));*/
      }
    }
    if (!gotwrap) {
      Printv(closwrapargs, " ", closparam, NIL);
    }
    Delete(closparam);

    /* Look for an input typemap */
    if ((tm = Getattr(p,"tmap:in"))) {
      String *parse = Getattr(p,"tmap:in:parse");
      if (!parse) {
	Replaceall(tm,"$source",source);
	Replaceall(tm,"$target",ln);
	Replaceall(tm,"$input", source);
	Setattr(p,"emit:input", source);   /* Save the location of
					      the object */
	  
	if (Getattr(p,"wrap:disown") || (Getattr(p,"tmap:in:disown"))) {
	  Replaceall(tm,"$disown","SWIG_POINTER_DISOWN");
	} else {
	  Replaceall(tm,"$disown","0");
	}

	if (i >= num_required)
	  Printv(get_pointers, "if (", source, ") {\n", NIL);
	Printv(get_pointers,tm,"\n", NIL);
	if (i >= num_required)
	  Printv(get_pointers, "}\n", NIL);

      } else {
      }
      p = Getattr(p,"tmap:in:next");
      continue;
    } else {
      Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, 
		   "Unable to use type %s as a function argument.\n",
		   SwigType_str(pt,0));
      break;
    }
    p = nextSibling(p);
  }

  /* finish argument marshalling */

  Printf(f->def,  ") {");
  Printf(declfunc, ")");

  /* Now piece together the first part of the wrapper function */
  Printv(f->code, get_pointers, NIL);

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
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:freearg"))) {
      Replaceall(tm,"$source",Getattr(p,"lname"));
      Printv(cleanup,tm,"\n",NIL);
      p = Getattr(p,"tmap:freearg:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Emit the function call */
  emit_action(n,f);

  /* Return the function value */
  if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
    Replaceall(tm,"$source", "result");
    Replaceall(tm,"$target", "resultobj");
    Replaceall(tm,"$result", "resultobj");
    if (Getattr(n,"feature:new")) {
      Replaceall(tm,"$owner","1");
    } else {
      Replaceall(tm,"$owner","0");
    }
    Printf(f->code, "%s", tm);
  } else {
    Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
		 "Unable to use return type %s in function %s.\n", 
		 SwigType_str(d,0), name);
  }

  /* Insert argument output code */
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:argout"))) {
      Replaceall(tm,"$source",Getattr(p,"lname"));
      Replaceall(tm,"$target","resultobj");
      Replaceall(tm,"$arg",Getattr(p,"emit:input"));
      Replaceall(tm,"$input",Getattr(p,"emit:input"));
      Printf(f->code, "%s", tm);
      p = Getattr(p,"tmap:argout:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Output cleanup code */
  Printv(f->code,cleanup,NIL);

  /* Look to see if there is any newfree cleanup code */
  if (Getattr(n,"feature:new")) {
    if ((tm = Swig_typemap_lookup_new("newfree",n,"result",0))) {
      Replaceall(tm,"$source","result");
      Printf(f->code,"%s\n",tm);
    }
  }

  /* See if there is any return cleanup code */
  if ((tm = Swig_typemap_lookup_new("ret", n, "result", 0))) {
    Replaceall(tm,"$source","result");
    Printf(f->code,"%s\n",tm);
  }

  Printf(f->code,"    C_kontinue (continuation, resultobj);\n");

  /* Error handling code */
#ifdef USE_FAIL
  Printf(f->code,"fail:\n");
  Printv(f->code,cleanup,NIL);
  Printf(f->code,"swig_panic (\"failure in "
	 "'$symname' SWIG function wrapper\");\n");
#endif
  Printf(f->code,"}\n");

  /* Substitute the cleanup code */
  Replaceall(f->code,"$cleanup",cleanup);

  /* Substitute the function name */
  Replaceall(f->code,"$symname",iname);
  Replaceall(f->code,"$result","resultobj");

  /* Dump the function out */
  Printv(f_wrappers, 
#ifndef BINDING
	  "static ",
#endif
	  declfunc, " C_noret;\n", NIL);
  Wrapper_print(f,f_wrappers);

  Setattr(n,"wrap:name", wname);

  /* Now register the function with the interpreter.   */
  if (!Getattr(n,"sym:overloaded")) {
    addMethod(iname, scmname, wname);

    /* Create a binding for this function */
#ifdef BINDING
    Printv(f_scm, "(declare (foreign-declare \"C_extern ", 
	   declfunc, " C_noret;\"))\n", NIL);	  
    Printv(f_scm, "(define ", prefix, scmname, 
	   " (##core#primitive \"", realmodule, "_wrap_", iname, 
	   "\"))\n\n", NIL);	  
#endif
  }
  else {
    if (!Getattr(n,"sym:nextSibling")) {
      dispatchFunction(n);
    }
  }

  /* Look for typemap(clos_out) */
  closparam = NewString("");
  Printv(closparam, "(", prefix, scmname, closwrapargs, ")", NIL);
  Node *search;
  String   *pb = SwigType_base(d);
  tm = 0;
  if ((search = Getattr(known_classes, pb)) || 
      (tm = singleSearch("clos_out", Char(closparam), pb))) {
    /* search for typemap("clos_out") CLASS_OR_BASE_CLASS */
    if (tm || (tm = recurseSearch("clos_out", Char(closparam), search))) {
      String *cn = NewString("");
      Printv(cn, "<", prefix, pb, ">", NIL);
      namify(cn);

      Replaceall(tm, "$class", cn);
	
      Delete(closparam);
      Delete(cn);

      closparam = Copy(tm);
    }
    else {
      /*Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number,
		   "Unable to find \"%%typemap(clos_out) %s *\" "
		   "or typemaps for any superclasses.\n", 
		   SwigType_str(pb,0));*/
    }
  }

  /* Dump clos code if enabled and not in a non-static member function */
  if (!Getattr(n,"sym:overloaded")) {
    if (clos && 
	(!(clos & SCMCLOS_MEMBER) || (clos & SCMCLOS_STATIC_MEMBER))) {
      Printv(f_clos, "(define (+", prefix, scmname, "+", closargs, ")\n",
	      tab4, closparam, ")\n", NIL);
    }
  }
  Delete(closparam);

  Delete(wname);
  Delete(get_pointers);
  Delete(cleanup);
  Delete(outarg);
  Delete(declfunc);
  Delete(mangle);
  Delete(closwrapargs);
  Delete(closargs);
  DelWrapper(f);
  return SWIG_OK;
}

int
CHICKEN::variableWrapper(Node *n)  {
  char *name  = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *t = Getattr(n,"type");
  SwigType *pb = SwigType_base(t);
  ParmList *l    = Getattr(n,"parms");

  String *proc_name = NewString("");
  char  var_name[256];
  String *wname = NewString("");
  String *mangle = NewString("");
  String *tm;
  String *tm2 = NewString("");;
  String *argnum = NewString("0");
  String *arg = NewString("argv[0]");
  Wrapper *f;    
  String *overname = 0;
  String *scmname;
  String *closparam;
  String *closargs;
  String *closwrapargs;

  int     num_required;
  int     num_arguments;

  scmname      = NewString(iname);
  namify(scmname);

  Printf(mangle, "\"%s\"", SwigType_manglestr(t));

  if (Getattr(n,"sym:overloaded")) {
    overname = Getattr(n,"sym:overname");
  } else {
    if (!addSymbol(iname,n)) return SWIG_ERROR;
  }

  f = NewWrapper();
    
  /* Attach the standard typemaps */
  emit_attach_parmmaps(l,f);
  Setattr(n,"wrap:parms",l);

  /* Get number of required and total arguments */
  num_arguments = emit_num_arguments(l);
  num_required  = emit_num_required(l);

  // evaluation function names
  Append(wname, realmodule);
  Append(wname, Swig_name_wrapper(iname));
  if (overname) {
    Append(wname, overname);
  }

  strcpy(var_name, Char(Swig_name_wrapper(iname)));
    
  // Build the name for scheme.
  Printv(proc_name, iname,NIL);
  namify(proc_name);

  // Check for interrupts
  Printv (f->code, "C_trace(\"",scmname,"\");\n", NIL);

  closargs     = NewString("");
  closwrapargs = NewString("");
    
  if (1 || (SwigType_type(t) != T_USER) || (isPointer(t))) {
      
    closparam = NewString("(car %value)");
    Printv(closargs, " . %value", NIL);
      
    Printv(f->def, 
#ifndef BINDING
	    "static ",
#endif
	    "void ",wname,"(int, C_word, C_word, C_word) C_noret;\n", 
	    NIL);
    Printv(f->def, 
#ifndef BINDING
	    "static "
#endif
	    "void ",wname,"(int argc, C_word closure, "
	    "C_word continuation, C_word value) {\n", 
	    NIL);
      
    Wrapper_add_local(f, "resultobj", "C_word resultobj");

    /* Check for a setting of the variable value */
    if (!Getattr(n,"feature:immutable")) {
      Printf(f->code, "if (argc > 2) {\n");
      if ((tm = Swig_typemap_lookup_new("varin",n,name,0))) {
	Replaceall(tm,"$source","value");
	Replaceall(tm,"$target",name);
	Replaceall(tm,"$input","value");
	Printv(f->code, tm, "\n",NIL);
      }
      else {
	Swig_warning(WARN_TYPEMAP_VARIN_UNDEF, input_file, line_number, 
		     "Unable to set variable of type %s.\n", 
		     SwigType_str(t,0));
      }
      Printf(f->code, "}\n");
    }
      
    /* Look for an clos input conversion */
    int gotwrap = 0;
    Node *search;
    String *tm = 0;
    if ((search = Getattr(known_classes, pb)) || 
	(tm = singleSearch("clos_in", Char(name), pb))) {
      /* search for typemap("clos_in") CLASS_OR_BASE_CLASS */
      if (tm || (tm = recurseSearch("clos_in", Char(name), search))) {
	String *cn = NewString("");
	Printv(cn, "<", prefix, pb, ">", NIL);
	namify(cn);

	Replaceall(tm, "$class", cn);
	Replaceall(tm, "$input", closparam);

	Printv(closwrapargs, " ", tm, NIL);

	gotwrap = 1;
	Delete(cn);
      }
      else {
	Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number,
		     "Unable to find \"%%typemap(clos_in) %s *\" "
		     "or typemaps for any superclasses.\n", 
		     SwigType_str(pb,0));
      }
    }
    if (!gotwrap) {
      Printv(closwrapargs, " ", closparam, NIL);
    }
    Delete(closparam);

    // Now return the value of the variable - regardless
    // of evaluating or setting.
    if ((tm = Swig_typemap_lookup_new("varout",n,name,0))) {

      Replaceall(tm,"$source",name);
      Replaceall(tm,"$varname",name);
      Replaceall(tm,"$target","resultobj");
      Replaceall(tm,"$result","resultobj");
      Printf(f->code, "%s\n", tm);
    }
    else {
      Swig_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number,
		   "Unable to read variable of type %s\n", SwigType_str(t,0));
    }
    Printf(f->code,"\nC_kontinue (continuation, resultobj);\n");
      
    /* Error handling code */
#ifdef USE_FAIL
    Printf(f->code,"fail:\n");
    Printf(f->code,"swig_panic (\"failure in "
	   "'%s' SWIG wrapper\");\n", proc_name);
#endif
    Printf(f->code,"}\n");

    Wrapper_print(f, f_wrappers);
      
    /* Now register the variable with the interpreter.   */
    addMethod(iname, scmname, wname);

    /* Look for typemap(clos_out) */
    closparam = NewString("");
    Printv(closparam, "(if (= (length %value) 0)\n", 
	   tab4, "(", prefix, scmname, ")\n",
	   tab4, "(", prefix, scmname, closwrapargs, "))", NIL);
    tm = 0;
    if ((search = Getattr(known_classes, pb)) || 
	(tm = singleSearch("clos_out", Char(closparam), pb))) {
      /* search for typemap("clos_out") CLASS_OR_BASE_CLASS */
      if (tm || (tm = recurseSearch("clos_out", 
				     Char(closparam), search))) {
	String *cn = NewString("");
	Printv(cn, "<", prefix, pb, ">", NIL);
	namify(cn);

	Replaceall(tm, "$class", cn);
	
	Delete(closparam);
	Delete(cn);

	closparam = Copy(tm);
      }
      else {
	Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number,
		     "Unable to find \"%%typemap(clos_out) %s *\" "
		     "or typemaps for any superclasses.\n", 
		     SwigType_str(pb,0));
      }
    }

    /* Create a binding for this variable */
#ifdef BINDING
    Printv(f_scm, "(declare (foreign-declare \"C_extern ", 
	   wname, "(int,C_word,C_word,C_word)"
	   " C_noret;\"))\n", NIL);
    Printv(f_scm, "(define ", prefix,  scmname, 
	   " (##core#primitive \"", realmodule, "_wrap_", iname, 
	   "\"))\n\n", NIL);	  
#endif

    /* Create a clos for this variable (if enabled and not in a
       non-static member variable) */
    if (clos && 
	(!(clos & SCMCLOS_MEMBER) || (clos & SCMCLOS_STATIC_MEMBER))) {
      Printv(f_clos, "(define (+", prefix, scmname, "+", closargs, ")\n",
	      tab4, closparam, ")\n", NIL);
    }
    Delete(closparam);
  } else {
    Swig_warning(WARN_TYPEMAP_VAR_UNDEF, input_file, line_number,
		 "Unsupported variable type %s (ignored).\n", 
		 SwigType_str(t,0));
  }

  Delete(wname);
  Delete(proc_name);
  Delete(argnum);
  Delete(arg);
  Delete(tm2);
  Delete(mangle);
  Delete(closwrapargs);
  Delete(closargs);
  DelWrapper(f);
  return SWIG_OK;
}

/* ------------------------------------------------------------
 * constantWrapper()
 * ------------------------------------------------------------ */

int
CHICKEN::constantWrapper(Node *n)
{

  char *name  = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *t = Getattr(n,"type");
  ParmList *l    = Getattr(n,"parms");
  String   *value = Getattr(n,"value");

  String *proc_name = NewString("");
  char  var_name[256];
  String *wname = NewString("");
  String *mangle = NewString("");
  String *tm;
  String *tm2 = NewString("");
  String *source = NewString("");
  String *argnum = NewString("0");
  String *arg = NewString("argv[0]");
  Wrapper *f;    
  String *overname = 0;
  String *scmname;

  int     num_required;
  int     num_arguments;

  scmname      = NewString(iname);
  namify(scmname);

  Printf(mangle, "\"%s\"", SwigType_manglestr(t));
  Printf(source, "swig_const_%s", name);
  Replaceall(source, "::", "__");

  if (Getattr(n,"sym:overloaded")) {
    overname = Getattr(n,"sym:overname");
  } else {
    if (!addSymbol(iname,n)) return SWIG_ERROR;
  }

  Append(wname, realmodule);
  Append(wname, Swig_name_wrapper(iname));
  if (overname) {
    Append(wname, overname);
  }

  /* Special hook for member pointer */
  if (SwigType_type(t) == T_MPOINTER) {
    Printf(f_header, "static %s = %s;\n", SwigType_str(t,wname), value);
    value = wname;
  }
  if ((tm = Swig_typemap_lookup_new("constcode", n, name, 0))) {
    Replaceall(tm,"$source",value);
    Replaceall(tm,"$target",source);
    Replaceall(tm,"$result",source);
    Replaceall(tm,"$value",value);
    Printf(f_header, "%s\n", tm);
  } 
  else {
    Swig_warning(WARN_TYPEMAP_CONST_UNDEF, input_file, line_number,
		 "Unsupported constant value.\n");
    return SWIG_NOWRAP;
  }

  f = NewWrapper();
    
  /* Attach the standard typemaps */
  emit_attach_parmmaps(l,f);
  Setattr(n,"wrap:parms",l);

  /* Get number of required and total arguments */
  num_arguments = emit_num_arguments(l);
  num_required  = emit_num_required(l);

  // evaluation function names
    
  strcpy(var_name, Char(Swig_name_wrapper(iname)));
    
  // Build the name for scheme.
  Printv(proc_name, iname,NIL);
  namify(proc_name);
    
  // Check for interrupts
  Printv (f->code, "C_trace(\"",scmname,"\");\n", NIL);

  if (1 || (SwigType_type(t) != T_USER) || (isPointer(t))) {
      
    Printv(f->def, 
#ifndef BINDING
	    "static ",
#endif
	    "void ",wname,"(int, C_word, C_word) C_noret;\n", 
	   NIL);

    Printv(f->def, 
#ifndef BINDING
	    "static ",
#endif
	    "void ",wname,"(int argc, C_word closure, "
	    "C_word continuation) {\n", 
	   NIL);
      
    Wrapper_add_local(f, "resultobj", "C_word resultobj");

    // Return the value of the variable
    if ((tm = Swig_typemap_lookup_new("varout",n,name,0))) {

      Replaceall(tm,"$source",source);
      Replaceall(tm,"$varname",source);
      Replaceall(tm,"$target","resultobj");
      Replaceall(tm,"$result","resultobj");
      Printf(f->code, "%s\n", tm);
    }
    else {
      Swig_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number,
		   "Unable to read variable of type %s\n", SwigType_str(t,0));
    }
    Printf(f->code,"\nC_kontinue (continuation, resultobj);\n");
      
    /* Error handling code */
#ifdef USE_FAIL
    Printf(f->code,"fail:\n");
    Printf(f->code,"swig_panic (\"failure in "
	   "'%s' SWIG wrapper\");\n", proc_name);
#endif
    Printf(f->code,"}\n");

    Wrapper_print(f, f_wrappers);
      
    /* Now register the variable with the interpreter.   */
    addMethod(iname, scmname, wname);

    /* Create a binding for this variable */
#ifdef BINDING
    Printv(f_scm, "(declare (foreign-declare \"C_extern ", 
	   wname, "(int argc, C_word closure, C_word continuation, "
	   "C_word value)"
	   " C_noret;\"))\n", NIL);	  
    Printv(f_scm, "(define ", prefix, scmname, 
	   " (##core#primitive \"", realmodule, "_wrap_", iname, 
	   "\"))\n\n", NIL);	  
#endif

  } else {
    Swig_warning(WARN_TYPEMAP_VAR_UNDEF, input_file, line_number,
		 "Unsupported variable type %s (ignored).\n", 
		 SwigType_str(t,0));
  }

  Delete(wname);
  Delete(proc_name);
  Delete(argnum);
  Delete(arg);
  Delete(tm2);
  Delete(mangle);
  Delete(source);
  DelWrapper(f);
  return SWIG_OK;
}

int
CHICKEN::classDeclaration(Node *n)
{
  String *importname;
  Node   *mod;
  if (clos) {
    mod = Getattr(n,"module");
    if (mod) {
      String *iname = Getattr(n, "sym:name");
      importname = NewString(prefix);
      Printv(importname, iname, NIL);
      Setattr(n,"chicken:proxy",importname);
      Setattr(known_classes, iname, n);
    }
  }
  return Language::classDeclaration(n);
}

int
CHICKEN::classHandler(Node *n)
{
  int oldclassic = classic;

  /* Create new strings for building up a wrapper function */
  have_constructor = 0;
      
  if (Getattr(n,"feature:exceptionclass")) {
    classic = 1;
  }

  clos_indent = (String *) tab4;
      
  class_name = NewString("");
  short_class_name = NewString("");
  Printv(class_name, "<", prefix, Getattr(n,"sym:name"), ">", NIL);
  namify(class_name);
  Printv(short_class_name, Getattr(n,"sym:name"), NIL);
  namify(short_class_name);
  real_classname = Getattr(n,"name");
      
  if (!addSymbol(class_name,n)) return SWIG_ERROR;

#ifdef JONAH_IS_CRAZY
  Printv(f_scm,"(set! swig-",prefix,"tag:",Getattr(n,"sym:name"),"\n",
	 tab4,"(make-swig-",prefix,"tag ",
	 "1000 \"_p_",Getattr(n,"sym:name"),"\"\n",
	 tab8,"((foreign-lambda* c-pointer ()\n",
	 tab8, tab4, "\"return (",realmodule,
	 "_swig_get_type (\\\"_p_",Getattr(n,"sym:name"),"\\\"));\"))\n",
	 tab8, "\"",Getattr(n,"sym:name")," *\"))\n", NIL);
#endif

  if (clos) {

    /* Handle inheritance */
    String *base_class = NewString("<");
    List *baselist = Getattr(n,"bases");
    if (baselist && Len(baselist)) {
      Iterator base = First(baselist);
      while (base.item) {
	String *bname = Copy(Getattr(base.item, "chicken:proxy"));
	if (!bname) {
	  base = Next(base);
	  continue;
	}
	namify(bname);
	Printv(base_class,bname,NIL);
	Delete(bname);
	base = Next(base);
	if (base.item) {
	  Printf(base_class, "> <");
	}
      }
    }
    Printf(base_class, ">");

    Printv(f_clos,"\n(define-class ", class_name, " ", NIL);

    if (Len(base_class) > 2) {
      Printv(f_clos,"(", base_class, ") ())\n", NIL);
    } else {
      Printv(f_clos,"(<object>) (this))\n", NIL);
    }

  }

  /* Emit all of the members */

  in_class = 1;
  Language::classHandler(n);
  in_class = 0;

  if (clos) {
    char apply[] = "apply ";

    if (have_constructor) {
      Printv(f_clos, "(define-method (initialize (obj ", class_name,
	     ") initargs)\n",
	     tab4, "(call-next-method)\n",
	     tab4, "(if (and (list? initargs) (= (length initargs) 2) (eq? (car initargs) (quote this)))\n",
	     tab8, "(slot-set! obj (quote this) (cadr initargs))\n",
	     tab8, "(begin\n",
	     tab8, tab4, "(slot-set! obj (quote this) (", apply, prefix, "new-", short_class_name, "\n",
	     tab8, tab8, " (map (lambda (arg) (if (instance? arg) (slot-ref arg (quote this)) arg)) initargs)))\n",
	     tab8, tab4, "(set-finalizer! obj\n",
	     tab8, tab8, "(lambda (deadobj) (", prefix, "delete-", short_class_name,
	     " (slot-ref deadobj (quote this))))))))\n",
	     NIL);
    }
    else {
      Printv(f_clos, "(define-method (initialize (obj ", class_name,
	     ") initargs)\n",
	     tab4, "(call-next-method)\n",
	     tab4, "(if (and (list? initargs) (= (length initargs) 2) (eq? (car initargs) (quote this)))\n",
	     tab8, "(slot-set! obj (quote this) (cadr initargs))\n",
	     tab8, "(slot-set! obj (quote this) #f)))\n",
	     NIL);
    }
  }

  Delete(class_name);
  Delete(short_class_name);
  class_name = 0;
  short_class_name = 0;

  classic = oldclassic;
  return SWIG_OK;
}

int
CHICKEN::memberfunctionHandler(Node *n)
{
  String *iname = Getattr(n,"sym:name");
  SwigType *d     = Getattr(n,"type");
  ParmList *l     = Getattr(n,"parms");
  int   oldclos;
  String *scmname;
  String *args;
  String *wrapargs;
  String *closparam;
  int     i;
  Parm      *p;
  String *tm;

  scmname      = NewString(iname);
  namify(scmname);

  /* input arguments */
  args = NewString("");
  wrapargs = NewString("");
  for (i=0, p=l; p; i++) {
    while (checkAttribute(p,"tmap:in:numinputs","0")) {
      p = Getattr(p,"tmap:in:next");
    }

    SwigType *pt = Getattr(p,"type");
    String   *pn = Getattr(p,"name");
    SwigType *pb = SwigType_base(pt);

    if (strcmp("void", Char(pt)) != 0) {
      String   *arg = NewString("");

      /* make name of argument */
      if (pn && Len(pn)) {
	Printf(arg, "%%%s", pn);
      }
      else {
	Printf(arg, "%%%d", i+1);
      }

      Printv(args, " ", arg, NIL);

      /* do input conversion */
      int gotwrap = 0;
      Node *search;
      String *tm = 0;
      if ((search = Getattr(known_classes, pb)) || 
	  (tm = singleSearch("clos_in", Char(pn), pb))) {
	/* search for typemap("clos_in") CLASS_OR_BASE_CLASS */
	if (tm || (tm = recurseSearch("clos_in", Char(pn), search))) {
	  String *cn = NewString("");
	  Printv(cn, "<", prefix, pb, ">", NIL);
	  namify(cn);

	  Replaceall(tm, "$class", cn);
	  Replaceall(tm, "$input", arg);

	  Printv(wrapargs, " ", tm, NIL);

	  gotwrap = 1;
	  Delete(cn);
	}
	else {
	  Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number,
		       "Unable to find \"%%typemap(clos_in) %s *\" "
		       "or typemaps for any superclasses.\n", 
		       SwigType_str(pb,0));
	}
      }
      if (!gotwrap) {
	Printv(wrapargs, " ", arg, NIL);
      }

      Delete(arg);
    }

    p = nextSibling(p);
  }

  /* Create the default member function */
  oldclos = clos;    /* Disable clos'ing when wrapping member
			functions */
  if (clos) clos = clos | SCMCLOS_MEMBER;
  Language::memberfunctionHandler(n);
  clos = oldclos;

  /* return value */
  closparam = NewString("");
  if (Getattr(n,"sym:overloaded")) {
    Printv(closparam, "(apply ", prefix, short_class_name, "-", scmname, "\n",
	   tab8, "(cons (slot-ref obj (quote this))\n",
	   tab8, tab4, "(map (lambda (arg) (if (instance? arg) (slot-ref arg (quote this)) arg)) args)))", NIL);
  }
  else {
    Printv(closparam, "(", prefix, short_class_name, "-", scmname,
	   " (slot-ref obj (quote this))", wrapargs, ")", NIL);
  }
  Node *search;
  String   *pb = SwigType_base(d);
  tm = 0;
  if ((search = Getattr(known_classes, pb)) || 
      (tm = singleSearch("clos_out", Char(closparam), pb))) {
    /* search for typemap("clos_out") CLASS_OR_BASE_CLASS */
    if (tm || (tm = recurseSearch("clos_out", Char(closparam), search))) {
      String *cn = NewString("");
      Printv(cn, "<", prefix, pb, ">", NIL);
      namify(cn);

      Replaceall(tm, "$class", cn);
	
      Delete(closparam);
      Delete(cn);

      closparam = Copy(tm);
    }
    else {
      Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number,
		   "Unable to find \"%%typemap(clos_out) %s *\" "
		   "or typemaps for any superclasses.\n", 
		   SwigType_str(pb,0));
    }
  }

  /* print */
  if (!Getattr(n,"sym:nextSibling")) {
    if (clos) {	
      if (Getattr(n,"feature:clos")) {
	String *scmcode = chickenCode(Getattr(n,"feature:clos"),tab4);
	Printv(f_clos,scmcode,"\n",NIL);
      } 
      else if (Getattr(n,"sym:overloaded")) {
	Printv(f_clos, "(define-method (-", iname, 
	       "- (obj ", class_name, ") . args)\n", 
	       tab4, closparam, ")\n", NIL);
      }
      else {
	Printv(f_clos, "(define-method (-", iname, 
	       "- (obj ", class_name, ")", args, ")\n", 
	       tab4, closparam, ")\n", NIL);
      }
    }
    if (generic) {
      Printv(f_generic, "(define -", iname, 
	     "- (make-generic \"", iname, "\")) ;; class ",
	     class_name, "\n", NIL);
    }
  }

  Delete(closparam);
  Delete(wrapargs);
  Delete(args);
  Delete(scmname);
  return SWIG_OK;
}

int
CHICKEN::membervariableHandler(Node *n)
{
  String *iname = Getattr(n,"sym:name");

  int   oldclos = clos;
  if (clos) clos = clos | SCMCLOS_MEMBER;
  Language::membervariableHandler(n);
  clos = oldclos;

  if (clos) {
    int immutable = 0;
    if (!Getattr(n,"feature:immutable")) {
      Printv(f_clos, "(define-method (-set-", iname, 
	     "!- (obj ", class_name, ") %value)\n", 
	     tab4, "(", prefix, real_classname, "-", iname,
	     "-set (slot-ref obj (quote this)) %value))\n", NIL);
      if (generic) {
	Printv(f_generic, "(define -set-", iname, 
	       "!- (make-generic \"set-", iname, "!\")) ;; class ", 
	       class_name, "\n", NIL);
      }
    } else {
      immutable = 1;
    }
    Printv(f_clos, "(define-method (-get-", iname, 
	   "- (obj ", class_name, "))\n", 
	   tab4, "(", prefix, real_classname, "-", iname,
	   "-get (slot-ref obj (quote this))))\n", NIL);
    if (generic) {
      Printv(f_generic, "(define -get-", iname, 
	     "- (make-generic \"get-", iname, "\")) ;; class ", 
	     class_name, "\n", NIL);
    }
  }
  return SWIG_OK;
}

int
CHICKEN::memberconstantHandler(Node *n)
{
  int   oldclos = clos;
  if (clos) clos = clos | SCMCLOS_MEMBER;
  Language::memberconstantHandler(n);
  clos = oldclos;

  return SWIG_OK;
}

int
CHICKEN::staticmemberfunctionHandler(Node *n)
{
  int   oldclos = clos;
  if (clos) clos = clos | SCMCLOS_STATIC_MEMBER;
  Language::staticmemberfunctionHandler(n);
  clos = oldclos;

  return SWIG_OK;
}

int
CHICKEN::staticmembervariableHandler(Node *n)
{
  int   oldclos = clos;
  if (clos) clos = clos | SCMCLOS_STATIC_MEMBER;
  Language::staticmembervariableHandler(n);
  clos = oldclos;

  return SWIG_OK;

}

int
CHICKEN::destructorHandler(Node *n)
{
  int oldclos = clos;
    
  if (clos) clos = clos | SCMCLOS_MEMBER;
  Language::destructorHandler(n);
  clos = oldclos;

  return SWIG_OK;
}

int
CHICKEN::constructorHandler(Node *n)
{
  int   oldclos = clos;

  if (clos) clos = clos | SCMCLOS_MEMBER;
  Language::constructorHandler(n);
  clos = oldclos;

  if (clos) {
    have_constructor = 1;
  }

  return SWIG_OK;
}

void 
CHICKEN::dispatchFunction(Node *n)
{
  /* Last node in overloaded chain */

  int maxargs;
  String *tmp = NewString("");
  String *dispatch = 
    Swig_overload_dispatch(n,"%s (2+argc,closure,"
			   "continuation$commaargs);", &maxargs);
	
  /* Generate a dispatch wrapper for all overloaded functions */

  Wrapper *f       = NewWrapper();
  String  *iname = Getattr(n,"sym:name");
  String  *wname   = NewString("");
  String  *scmname = NewString(iname);

  namify(scmname);
  Append(wname, realmodule);
  Append(wname, Swig_name_wrapper(iname));

#ifndef BINDING
  Printv(f->def, "static void real_", wname, 
	 "(int, C_word, C_word, C_word) C_noret;\n", NIL);
#endif

  Printv(f->def, 
#ifdef BINDING
	 "void ",
#else
	 "static void real_",
#endif
	 wname,
	 "(int, C_word closure, C_word continuation, C_word args) {",
	 NIL);
    
  Wrapper_add_local(f,"argc","int argc");
  Printf(tmp,"C_word argv[%d]", maxargs+1);
  Wrapper_add_local(f,"argv",tmp);
  Wrapper_add_local(f,"ii","int ii");
  Wrapper_add_local(f,"t","C_word t = args");
  Printf(f->code,"if (!C_swig_is_list (args)) {\n");
  Printf(f->code,"  swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "
	 "\"Argument #1 must be a list of overloaded arguments\");\n");
  Printf(f->code,"}\n");
  Printf(f->code,"argc = C_unfix (C_i_length (args));\n");
  Printf(f->code,"for (ii = 0; (ii < argc) && (ii < %d); ii++, t = C_block_item (t, 1)) {\n",maxargs);
  Printf(f->code,"argv[ii] = C_block_item (t, 0);\n");
  Printf(f->code,"}\n");
    
  Printv(f->code,dispatch,"\n",NIL);
  Printf(f->code,"swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE,"
	 "\"No matching function for overloaded '%s'\");\n", iname);
  Printv(f->code,"}\n",NIL);
  Wrapper_print(f,f_wrappers);
  addMethod(iname,scmname, wname);

  /* Create a binding for this function */
#ifdef BINDING
  Printv(f_scm, "(declare (foreign-declare \"C_extern ", 
	 realmodule, wname, "(int, C_word, C_word, C_word) C_noret;\"))\n", NIL);	  
  Printv(f_scm, "(define swig-", prefix, scmname, 
	 "-prim (##core#primitive \"", realmodule, "_wrap_", iname, 
	 "\"))\n", NIL);	  
  Printv(f_scm, "(define (", prefix, scmname, 
	 " . args) (swig-", prefix, scmname, "-prim args))\n\n", NIL);	  
#else

  DelWrapper(f);
  f = NewWrapper();

  /* varargs */
  Printv(f->def, "void ", wname, 
	 "(int, C_word, C_word, ...) C_noret;\n", NIL);
  Printv(f->def, "void ", wname,
	 "(int c, C_word t0, C_word t1, ...) {",
	 NIL);
  Printv(f->code, 
	 "C_word t2;\n",
	 "va_list v;\n",
	 "C_word *a, c2 = c;\n",
	 "C_save_rest (t1, c2, 2);\n",
	 "a = C_alloc((c-2)*3);\n",
	 "t2 = C_restore_rest (a, C_rest_count (0));\n",
	 "real_", wname, " (3, t0, t1, t2);\n", NIL);
  Printv(f->code,"}\n",NIL);
  Wrapper_print(f,f_wrappers);
#endif

  /* Create a clos for this function (if enabled and not in a
     non-static member function) */
  if (clos && 
      (!(clos & SCMCLOS_MEMBER) || (clos & SCMCLOS_STATIC_MEMBER))) {
    Printv(f_clos, "(define (+", prefix, scmname, "+ . args)\n",
	    tab4, "(apply ", prefix, scmname, " args))\n", NIL);
  }
  DelWrapper(f);
  Delete(dispatch);
  Delete(tmp);
  Delete(wname);
}

void 
CHICKEN::throwUnhandledChickenTypeError(SwigType *d)
{
  Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number,
	       "Unable to handle type %s.\n", SwigType_str(d,0));
}

int
CHICKEN::isPointer(SwigType *t)
{
  return SwigType_ispointer(SwigType_typedef_resolve_all(t));
}

void 
CHICKEN::addMethod(String *, String *scheme_name, String *function) 
{
#ifndef BINDING
  /* The symbols need the prefix. */
  String *sym = NewString(prefix);
  Append(sym, scheme_name);

  /* add symbol to Chicken internal symbol table */
  Printf(f_sym_size, "+C_SIZEOF_INTERNED_SYMBOL(%d)", Len(sym));    
  Printf(f_init, "sym = C_intern (&a, %d, \"%s\");\n", 
	 Len(sym), sym);
  Printv(f_init, 
	 "C_mutate ((C_word*)sym+1, (*a=C_CLOSURE_TYPE|1, a[1]=(C_word)", 
	 function, ", tmp=(C_word)a, a+=2, tmp));\n", NIL);
  num_methods++;
  Delete(sym);
#endif
}
  
int
CHICKEN::validIdentifier(String *s) 
{
  char *c = Char(s);
  /* Check whether we have an R5RS identifier.*/
  /* <identifier> --> <initial> <subsequent>* | <peculiar identifier> */
  /* <initial> --> <letter> | <special initial> */
  if (!(isalpha(*c) || (*c == '!') || (*c == '$') || (*c == '%')
	|| (*c == '&') || (*c == '*') || (*c == '/') || (*c == ':')
	|| (*c == '<') || (*c == '=') || (*c == '>') || (*c == '?')
	|| (*c == '^') || (*c == '_') || (*c == '~'))) {
    /* <peculiar identifier> --> + | - | ... */
    if ((strcmp(c, "+") == 0)
	|| strcmp(c, "-") == 0
	|| strcmp(c, "...") == 0) return 1;
    else return 0;
  }
  /* <subsequent> --> <initial> | <digit> | <special subsequent> */
  while (*c) {
    if (!(isalnum(*c) || (*c == '!') || (*c == '$') || (*c == '%')
	  || (*c == '&') || (*c == '*') || (*c == '/') || (*c == ':')
	  || (*c == '<') || (*c == '=') || (*c == '>') || (*c == '?')
	  || (*c == '^') || (*c == '_') || (*c == '~') || (*c == '+')
	  || (*c == '-') || (*c == '.') || (*c == '@'))) return 0;
    c++;
  }
  return 1;
}

String *
CHICKEN::chickenCode(String *code, const String *indent) {
  String *out = NewString("");
  String *temp;
  if (!indent) indent = "";

  temp = NewString(code);

  /* Split the input text into lines */
  List *clist = DohSplit(temp,'\n',-1);
  Delete(temp);
  int   initial = 0;
  Iterator s;

  /* Get the initial indentation */
  for (s = First(clist); s.item; s = Next(s)) {
    if (Len(s.item)) {
      char *c = Char(s.item);
      while (*c) {
	if (!isspace(*c)) break;
	initial++;
	c++;
      }
      if (*c && !isspace(*c)) break;
      else {
	initial = 0;
      }
    }
  }
  while (s.item) {
    if (Len(s.item) > initial) {
      char *c = Char(s.item);
      c += initial;
      Printv(out,indent,c,"\n",NIL);
    } else {
      Printv(out,"\n",NIL);
    }
    s = Next(s);
  }
  Delete(clist);
  return out;
}
  
String *
CHICKEN::singleSearch(const char *typemap, char *argname, 
		       SwigType *searchClass)
{
  String *tm;
  char *source = (char*)"$input";
  char *target = (char*)"$1";
  /* search for search-class typemap */
  SwigType *type = Copy(searchClass);
  SwigType_add_pointer(type);
  tm = Swig_typemap_lookup(typemap, type, argname, argname, 
			    source, target, 0);
  Delete(type);

  return tm;
}

String *
CHICKEN::recurseSearch(const char *typemap, char *argname, Node *n)
{
  String *tm;
  tm = singleSearch(typemap, argname, Getattr(n, "name"));
  if (tm) {
    return tm;
  }

  /* recurse through base classes */
  List *baselist = Getattr(n,"bases");
  if (baselist && Len(baselist)) {
    Iterator base = First(baselist);
    while (base.item) {
      tm = recurseSearch(typemap, argname, base.item);
      if (tm) break;
      base = Next(base);
    }
  }
  return tm;
}

void 
CHICKEN::namify(String *scmname)
{
  Replaceall(scmname,"_to_", "->");
  Replaceall(scmname,"_", "-");

  /* Convert mixed-case to lower case with dashes */
  if (mixed) {
    int changedcase;
    int i;

    /* insert "-" in all places with switches in case, and lowercase
       any upcase chars */
    do {
      char *s = Char(scmname);
      const int l = Len(scmname);
      int case_is_set = 0;
      int was_uppercase = 0;
      int pseudo_first = 0;

      changedcase = 0;
      for (i=0; i < l; ++i, ++s) {
	int is_uppercase = -1; /* -1 = neither, 0 = lower, 1 = upper */
	if (isalpha(*s) && !isdigit(*s)) {
	  is_uppercase = ((*s) >= 'A' && (*s) <= 'Z') ? 1 : 0;
	}
	if (i == 0 || !isalpha(*s) || isdigit(*s)) {
	  case_is_set = 0;
	  pseudo_first = 1;
	}
	if (case_is_set) {
	  if (is_uppercase >= 0 && was_uppercase != is_uppercase) {
	    *s = tolower(*s);
	    Insert(scmname, i, "-");
	    changedcase = 1;
	    break;
	  }
	}
	else if (is_uppercase >= 0) {
	  /* use currentcase, or lowercase if first char */
	  if (pseudo_first) {
	    pseudo_first = 0;
	    /* only if first two chars are upper case will we say that
	       the first char is upper case (like JavaBean property
	       naming rules) */
	    was_uppercase = 0;
	    const char *t = s + 1;
	    if (l >= i+2 && isalpha(*t) && !isdigit(*t) &&
		((*t) >= 'A' && (*t) <= 'Z')) {
	      was_uppercase = 1;
	    }
	  }
	  else {
	    was_uppercase = is_uppercase; 
	  }
	  case_is_set = 1;
	}
	if (is_uppercase == 1) {
	  *s = tolower(*s);
	}
      }
    }
    while (changedcase);
  }
}

/********************************************************************
 * CHICKEN module for SWIG
 *
 * Author : Jonah Beckford
 * 
 * Major restructuring: John Lenz
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
     -proxy                 - Export TinyCLOS class definitions\n\
     -closprefix <prefix>   - Prepend <prefix> to all clos identifiers\n\
     -useclassprefix        - Prepend the class name to all clos identifiers\n\
     -unhideprimitive       - Unhide the primitive: symbols\n\
     -nounit                - Do not (declare (unit ...)) in scheme file\n\
\n"
;

static char          *module = 0;
static char          *chicken_path=(char*)"chicken";
static int           num_methods = 0;

static  File         *f_runtime = 0;
static  File         *f_header = 0;
static  File         *f_wrappers = 0;
static  File         *f_init = 0;
static  String       *chickentext = 0;
static  String       *closhelpers;
static String        *swigtype_ptr = 0;


static  String       *f_sym_size = 0;
static  String       *closcode = 0;

/* C++ Support + Clos Classes */
static int           clos = 0;
static  String       *class_name  = 0;
static  String       *short_class_name  = 0;
static  String       *clos_class_methods = 0;
static  int          in_class = 0;
static  int          have_constructor = 0;
static int           useclassprefix = 0;
static String        *closprefix = 0;
static String        *memberfunction_name = 0;
static  int          hide_primitive = 1;
static Hash          *primitive_names = 0;
static int           declare_unit = 1;

class CHICKEN : public Language {
public:

  virtual void main(int argc, char *argv[]);
  virtual int  top(Node *n);
  virtual int  functionWrapper(Node *n); 
  virtual int  variableWrapper(Node *n);
  virtual int  constantWrapper(Node *n);
  virtual int  classDeclaration(Node *n);
  virtual int  classHandler(Node *n);
  virtual int  memberfunctionHandler(Node *n);
  virtual int  membervariableHandler(Node *n);
  virtual int  constructorHandler(Node *n);
  virtual int  validIdentifier(String *s);
  virtual int  staticmembervariableHandler(Node *n);
  virtual int  staticmemberfunctionHandler(Node *n);

protected:
  void    addMethod(String *scheme_name, String *function);
  /* Return true iff T is a pointer type */
  int     isPointer(SwigType *t);
  void    dispatchFunction(Node *n);

  String *chickenNameMapping(String *, String_or_char *);
  String *chickenPrimitiveName(String *);

  String *runtimeCode();
  String *defaultExternalRuntimeFilename();
};

/* -----------------------------------------------------------------------
static  String       *closhelpers;
 * swig_chicken()    - Instantiate module
 * ----------------------------------------------------------------------- */

static Language * new_swig_chicken() {
  return new CHICKEN();
}

extern "C"  {
  Language * swig_chicken(void) {
    return new_swig_chicken();
  }

  static int checkNodeClass(Node *n) {
    String *kind = Getattr(n, "kind");
    if (kind && Strcmp(kind, "class") == 0)
        return 1;
    else
        return 0;
  }
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
	fputs(chicken_usage, stdout);
	SWIG_exit(0);
      } 
      else if (strcmp(argv[i],"-proxy") == 0) {
	clos = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-closprefix") == 0) {
          if (argv[i+1]) {
              closprefix = NewString(argv[i+1]);
              Swig_mark_arg(i);
              Swig_mark_arg(i+1);
              i++;
          } else {
              Swig_arg_error();
          }
      } else if (strcmp(argv[i],"-useclassprefix") == 0) {
          useclassprefix = 1;
          Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-unhideprimitive") == 0) {
          hide_primitive = 0;
          Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-nounit") == 0) {
	  declare_unit = 0;
	  Swig_mark_arg(i);
      }
    }
  }

  if (!clos) hide_primitive = 0;

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
  String *chicken_filename = NewString("");
  File *f_scm;
  String *scmmodule;
  
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
  chickentext = NewString("");
  closhelpers = NewString("");
  f_sym_size = NewString("");
  primitive_names = NewHash();
    
  /* Register file targets with the SWIG file handler */
  Swig_register_filebyname("header",f_header);
  Swig_register_filebyname("wrapper",f_wrappers);
  Swig_register_filebyname("runtime",f_runtime);
  Swig_register_filebyname("init",f_init);

  Swig_register_filebyname("chicken", chickentext);
  Swig_register_filebyname("closprefix", closhelpers);
    
  closcode = NewString("");

  Printf(f_runtime, "/* -*- buffer-read-only: t -*- vi: set ro: */\n");
  Swig_banner(f_runtime);

  Printf(f_runtime, "/* Implementation : CHICKEN */\n\n");
    
  /* Set module name */
  module = Swig_copy_string(Char(Getattr(n, "name")));
  scmmodule = NewString(module);
  Replaceall(scmmodule, "_", "-");
 
  Printf(f_header,"#define SWIG_init swig_%s_init\n", module);
  Printf(f_header,"#define SWIG_name \"%s\"\n", scmmodule);

  Printf(f_wrappers,"#ifdef __cplusplus\n");
  Printf(f_wrappers,"extern \"C\" {\n");
  Printf(f_wrappers,"#endif\n\n");

  Language::top(n);

  SwigType_emit_type_table(f_runtime, f_wrappers);

  Printf(f_wrappers,"#ifdef __cplusplus\n");
  Printf(f_wrappers,"}\n");
  Printf(f_wrappers,"#endif\n");

  Printf(f_init, "C_kontinue (continuation, ret);\n");
  Printf(f_init, "}\n\n");

  Printf(chicken_filename,"%s%s.scm", SWIG_output_directory(), module);
  if ((f_scm = NewFile(chicken_filename,"w")) == 0) {
    Printf(stderr,"Unable to open %s\n", chicken_filename);
    SWIG_exit(EXIT_FAILURE);
  }

  Printv(f_scm,
	 ";; -*- buffer-read-only: t -*- vi: set ro:\n",
	 ";; This file was created automatically by SWIG.\n",
	 ";; Don't modify this file, modify the SWIG interface instead.\n",
	 NIL);
  if (declare_unit)
    Printv(f_scm,"(declare (unit ", scmmodule, "))\n\n", NIL);
  Printv(f_scm,"(declare \n",
	 tab4, "(hide swig-init)\n",
	 tab4, "(foreign-declare \"C_extern void swig_", module, "_init(C_word,C_word,C_word) C_noret;\"))\n", NIL);
  Printv(f_scm,"(define swig-init (##core#primitive \"swig_", module,
	 "_init\"))\n", NIL);
  Printv(f_scm,"(define swig-init-return (swig-init))\n\n", NIL);

  if (clos) {
    Printf (f_scm, "(declare (uses tinyclos))\n");
    Replaceall(closhelpers,"$module", scmmodule);
    Printf (f_scm, "%s\n", closhelpers);
    Printf (f_scm, "%s\n", closcode);
  }

  Printf(f_scm, "%s\n", chickentext);


  Close(f_scm);
  Delete(f_scm);

  char buftmp[20];
  sprintf(buftmp, "%d", num_methods);
  Replaceall(f_init, "$nummethods", buftmp);
  Replaceall(f_init, "$symsize", f_sym_size);

  if (hide_primitive)
    Replaceall(f_init, "$veclength", buftmp);
  else
    Replaceall(f_init, "$veclength", "0");

  Delete(chicken_filename);
  Delete(chickentext);
  Delete(closhelpers);

  /* Close all of the files */
  Delete(primitive_names);
  Delete(scmmodule);
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
  int scheme_argnum = 0;
  bool any_specialized_arg = false;
  Hash *scheme_arg_names = NewHash();
  String *method_signature = NewString("");
  String *primitive_args = NewString("");

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
  scmname      = NewString(iname);
  Replaceall(scmname, "_", "-");

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

  Append(wname, Swig_name_wrapper(iname));
  if (overname) {
    Append(wname, overname);
  }

  // Check for interrupts
  Printv (f->code, "C_trace(\"",scmname,"\");\n", NIL);

  Printv(f->def,
	 "static ",
	 "void ", wname,
	 " (C_word argc, C_word closure, C_word continuation",
	 NIL);
  Printv(declfunc,
	 "void ", wname,
	 "(C_word,C_word,C_word",
	 NIL);

  /* Generate code for argument marshalling */
  for (i = 0, p=l; i < num_arguments; i++) {
    
    while (checkAttribute(p,"tmap:in:numinputs","0")) {
      p = Getattr(p,"tmap:in:next");
    }

    SwigType *pt = Getattr(p,"type");
    String   *pn = Getattr(p,"name");
    String   *ln = Getattr(p,"lname");
    SwigType *pb = SwigType_typedef_resolve_all(SwigType_base(pt));

    sprintf(source,"scm%d",i+1);

    Printf(f->def, ", C_word scm%d", i+1);
    Printf(declfunc,",C_word");

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

        String *argname;
        scheme_argnum++;
        if (pn && !Getattr(scheme_arg_names, pn))
            argname = pn;
        else {
            /* Anonymous arg or re-used argument name -- choose a name that cannot clash */
            argname = NewStringf("%%arg%d", scheme_argnum);
        }

          if (clos) {
              if (i < num_required) {
                  if (strcmp("void", Char(pt)) != 0) {
                      Node *class_node = Swig_symbol_clookup_check(pb, Getattr(n, "sym:symtab"), checkNodeClass);
                      String *closclassname = (class_node == NULL) ? NULL : Getattr(class_node, "chicken:closclassname");
                      if (closclassname) {
                          Printv(method_signature, " (", argname, " ", closclassname, ")", NIL);
                          Printv(primitive_args, " (slot-ref ", argname, " 'swig-this)", NIL);
                          any_specialized_arg = true;
                      } else {
                          Printv(method_signature, " ", argname, NIL);
                          Printv(primitive_args, " ", argname, NIL);
                      }
                      Setattr(scheme_arg_names, argname, p);
                  }
              }
          }

          if (!pn) Delete(argname);
          
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
	  "static ",
	  declfunc, " C_noret;\n", NIL);
  Wrapper_print(f,f_wrappers);

  Setattr(n,"wrap:name", wname);

  /* Now register the function with the interpreter.   */
  int exportclos = 0;
  if (!Getattr(n,"sym:overloaded")) {
    addMethod(scmname, wname);
    exportclos = 1;
  }
  else {
    if (!Getattr(n,"sym:nextSibling")) {
      dispatchFunction(n);
      exportclos = 1;
    }
  }

  /* only export the clos function if sym:overloaded is false or last function in list of overloaded members
   * also only export if we are not in a class, or if in a class memberfunction (this protects against member variables
   * and static functions and so forth, which are generated seperatly */
  if (exportclos && (!in_class || memberfunction_name)) {
      String *method_def = NewString("");
      String *clos_name;
      if (in_class)
          clos_name = NewString(memberfunction_name);
      else
          clos_name = chickenNameMapping(scmname, (char *)"");
      Replaceall(method_signature, "_", "-");
      Replaceall(method_signature, "_", "-");
      if (!any_specialized_arg) {
          Printv(method_def, "(define ", clos_name, " ", chickenPrimitiveName(scmname), ")\n", NIL);
      } else if (num_required == num_arguments) {
          Printv(method_def, "(define-method (", clos_name, method_signature, ")\n", NIL);
          Printv(method_def, "  (", chickenPrimitiveName(scmname), primitive_args, "))\n", NIL);
      } else {
          Printv(method_def, "(define-method (", clos_name, method_signature, " . %args)\n", NIL);
          Printv(method_def, "  (apply ", chickenPrimitiveName(scmname), primitive_args, " %args))\n", NIL);
      }
      if (in_class) {
          Printv(clos_class_methods, method_def, NIL);
      } else {
          Printv(closcode, method_def, NIL);
      }
      Delete(clos_name);
      Delete(method_def);
  }

  Delete(wname);
  Delete(get_pointers);
  Delete(cleanup);
  Delete(outarg);
  Delete(declfunc);
  Delete(mangle);
  DelWrapper(f);
  return SWIG_OK;
}

int
CHICKEN::variableWrapper(Node *n)  {
  char *name  = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *t = Getattr(n,"type");
  ParmList *l    = Getattr(n,"parms");

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

  int     num_required;
  int     num_arguments;

  scmname      = NewString(iname);
  Replaceall(scmname, "_", "-");

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
  Append(wname, Swig_name_wrapper(iname));
  if (overname) {
    Append(wname, overname);
  }

  strcpy(var_name, Char(Swig_name_wrapper(iname)));
    
  // Check for interrupts
  Printv (f->code, "C_trace(\"",scmname,"\");\n", NIL);

  if (1 || (SwigType_type(t) != T_USER) || (isPointer(t))) {
      
    Printv(f->def, 
	    "static ",
	    "void ",wname,"(C_word, C_word, C_word, C_word) C_noret;\n", 
	    NIL);
    Printv(f->def, 
	    "static "
	    "void ",wname,"(C_word argc, C_word closure, "
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
    addMethod(scmname, wname);

    if (!in_class) {
        String *class_name = SwigType_typedef_resolve_all(SwigType_base(t));
        String *clos_name = chickenNameMapping(scmname, (char *)"");
        /* Simply re-export the procedure */
        Printv(closcode, "(define ", clos_name, " ", chickenPrimitiveName(scmname), ")\n", NIL);
        Delete(class_name);
        Delete(clos_name);
    }
  } else {
    Swig_warning(WARN_TYPEMAP_VAR_UNDEF, input_file, line_number,
		 "Unsupported variable type %s (ignored).\n", 
		 SwigType_str(t,0));
  }

  Delete(wname);
  Delete(argnum);
  Delete(arg);
  Delete(tm2);
  Delete(mangle);
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
  Replaceall(scmname, "_", "-");

  Printf(mangle, "\"%s\"", SwigType_manglestr(t));
  Printf(source, "swig_const_%s", name);
  Replaceall(source, "::", "__");

  if (Getattr(n,"sym:overloaded")) {
    overname = Getattr(n,"sym:overname");
  } else {
    if (!addSymbol(iname,n)) return SWIG_ERROR;
  }

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
    
  // Check for interrupts
  Printv (f->code, "C_trace(\"",scmname,"\");\n", NIL);

  if (1 || (SwigType_type(t) != T_USER) || (isPointer(t))) {
      
    Printv(f->def, 
	    "static ",
	    "void ",wname,"(C_word, C_word, C_word) C_noret;\n", 
	   NIL);

    Printv(f->def, 
	    "static ",
	    "void ",wname,"(C_word argc, C_word closure, "
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
    addMethod(scmname, wname);

    if (!in_class) {
      String *clos_name = chickenNameMapping(scmname, (char *)"");
      Printv(closcode, "(define ", clos_name, " ", chickenPrimitiveName(scmname), ")\n", NIL);
      Delete(clos_name);
    }

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
  String *class_name = NewStringf("<%s>", Getattr(n, "sym:name"));
  Setattr(n, "chicken:closclassname", class_name);
  return Language::classDeclaration(n);
}

int
CHICKEN::classHandler(Node *n)
{
  /* Create new strings for building up a wrapper function */
  have_constructor = 0;
      
  class_name = NewString("");
  short_class_name = NewString("");
  Printv(class_name, "<", Getattr(n,"sym:name"), ">", NIL);
  Printv(short_class_name, Getattr(n,"sym:name"), NIL);
  Replaceall(class_name, "_", "-");
  Replaceall(short_class_name, "_", "-");
      
  if (!addSymbol(class_name,n)) return SWIG_ERROR;

  /* Handle inheritance */
  String *base_class = NewString("<");
  List *baselist = Getattr(n,"bases");
  if (baselist && Len(baselist)) {
    Iterator base = First(baselist);
    while (base.item) {
        Printv(base_class, Getattr(base.item, "sym:name"),NIL);
        base = Next(base);
	if (base.item) {
	  Printf(base_class, "> <");
	}
      }
    }
    Printf(base_class, ">");
    Replaceall(base_class, "_", "-");

    String *scmmod = NewString(module);
    Replaceall(scmmod, "_", "-");

    Printv(closcode,"(define ", class_name, "\n",
                    "  (make <swig-metaclass-", scmmod, "> 'name '", class_name, "\n", NIL);
    Delete(scmmod);

    if (Len(base_class) > 2) {
      Printv(closcode,"    'direct-supers (list ", base_class, ")\n", NIL);
    } else {
      Printv(closcode,"    'direct-supers (list <object>)\n", NIL);
    }

    Printf(closcode, "    'direct-slots (list 'swig-this\n");

    String *mangled_classname = Swig_name_mangle(Getattr(n, "sym:name"));

    SwigType *ct = NewStringf("p.%s", Getattr(n, "name"));
    swigtype_ptr = SwigType_manglestr(ct);

    Printf(f_runtime, "static swig_chicken_clientdata _swig_chicken_clientdata%s = { 0 };\n",
            mangled_classname);
    Printv(f_init, "SWIG_TypeClientData(SWIGTYPE", swigtype_ptr,", (void *) &_swig_chicken_clientdata", mangled_classname, ");\n", NIL);
    SwigType_remember(ct);

  /* Emit all of the members */
  clos_class_methods = NewString("");

  in_class = 1;
  Language::classHandler(n);
  in_class = 0;

  Printf(closcode, ")))\n");

  String *newmethod = NewStringf("new-%s", short_class_name);
  String *delmethod = NewStringf("delete-%s", short_class_name);

  if (have_constructor) {
      Printv(closcode, "(define-method (initialize (obj ", class_name, ") initargs)\n",
                       "  (call-next-method)\n",
		       "  (swig-initialize obj initargs ", chickenPrimitiveName(newmethod), ")\n",
                       //"  (set-finalizer! obj (lambda (x) (", chickenPrimitiveName(delmethod), " (slot-ref x 'swig-this))))",
		       ")\n",
                       NIL);
  } else {
      Printv(closcode, "(define-method (initialize (obj ", class_name, ") initargs)\n",
                       "  (call-next-method)\n",
		       "  (swig-initialize obj initargs (lambda x #f)))\n",
		       NIL);
  }

  Delete(newmethod);
  Delete(delmethod);

  Printf(closcode, "%s\n", clos_class_methods);
  Delete(clos_class_methods);
  clos_class_methods = 0;
  
  /* export class initialization function */
  if (clos) {
      String *funcname = NewString(mangled_classname);
      Printf(funcname, "_swig_chicken_setclosclass");
      String *closfuncname = NewString(funcname);
      Replaceall(closfuncname, "_", "-");

      Printv(f_wrappers, "static void ", funcname, "(C_word,C_word,C_word,C_word) C_noret;\n",
                         "static void ", funcname, "(C_word argc, C_word closure, C_word continuation, C_word cl) {\n",
                         "  C_trace(\"", funcname, "\");\n",
			 "  swig_chicken_clientdata *cdata = (swig_chicken_clientdata *) SWIGTYPE", swigtype_ptr,"->clientdata;\n",
			 "  cdata->gc_proxy_create = CHICKEN_new_gc_root();\n",
                         "  CHICKEN_gc_root_set(cdata->gc_proxy_create, cl);\n",
                         "  C_kontinue(continuation, C_SCHEME_UNDEFINED);\n",
                         "}\n", NIL);
      addMethod(closfuncname, funcname);

      Printv(closcode, "(", chickenPrimitiveName(closfuncname), " (lambda (x) (make ", class_name, " 'swig-this x)))\n", NIL);

      Delete(closfuncname);
      Delete(funcname);
  }

  Delete(mangled_classname);
  Delete(swigtype_ptr);
  swigtype_ptr = 0;
                           
  Delete(class_name);
  Delete(short_class_name);
  class_name = 0;
  short_class_name = 0;

  return SWIG_OK;
}

int
CHICKEN::memberfunctionHandler(Node *n)
{
    String *iname = Getattr(n, "sym:name");
    String *proc = NewString(iname);
    Replaceall(proc, "_", "-");

    memberfunction_name = chickenNameMapping(proc, short_class_name);
    Language::memberfunctionHandler(n);
    Delete(memberfunction_name);
    memberfunction_name = NULL;
    Delete(proc);

    return SWIG_OK;
}

int
CHICKEN::staticmemberfunctionHandler(Node *n)
{
    String *iname = Getattr(n, "sym:name");
    String *proc = NewString(iname);
    Replaceall(proc, "_", "-");

    memberfunction_name = chickenNameMapping(proc, short_class_name);
    Language::staticmemberfunctionHandler(n);
    Delete(memberfunction_name);
    memberfunction_name = NULL;
    Delete(proc);

    return SWIG_OK;
}

int
CHICKEN::membervariableHandler(Node *n)
{
  String *iname = Getattr(n,"sym:name");
  String *pb = SwigType_typedef_resolve_all(SwigType_base(Getattr(n, "type")));

  Language::membervariableHandler(n);

  String *proc = NewString(iname);
  Replaceall(proc,"_","-");

  Node *class_node = Swig_symbol_clookup(pb, Getattr(n, "sym:symtab"));
  String *closclassname = (class_node == NULL) ? NULL : Getattr(class_node, "chicken:closclassname");

  String *getfunc = NewStringf("%s-%s-get", short_class_name, proc);
  String *setfunc = NewStringf("%s-%s-set", short_class_name, proc);

  Printv(closcode,"        (list '", proc, " ':swig-virtual ':swig-get ", chickenPrimitiveName(getfunc), NIL);

  if (!Getattr(n,"feature:immutable")) {
      if (closclassname) {
          Printv(closcode, " ':swig-set (lambda (x y) (", chickenPrimitiveName(setfunc), " x (slot-ref y 'swig-this))))\n", NIL);
      } else {
          Printv(closcode, " ':swig-set ", chickenPrimitiveName(setfunc), ")\n", NIL);
      }
  } else {
      Printf(closcode, ")\n");
  }

  Delete(proc);
  return SWIG_OK;
}

int
CHICKEN::staticmembervariableHandler(Node *n)
{
  String *iname = Getattr(n, "sym:name");
  String *pb = SwigType_typedef_resolve_all(SwigType_base(Getattr(n, "type")));

  Language::staticmembervariableHandler(n);

  String *proc = NewString(iname);
  Replaceall(proc, "_", "-");

  String *closprocname = chickenNameMapping(proc, short_class_name);

  Node *class_node = Swig_symbol_clookup(pb, Getattr(n, "sym:symtab"));
  String *closclassname = (class_node == NULL) ? NULL : Getattr(class_node, "chicken:closclassname");

  String *primfunc = NewStringf("%s-%s", short_class_name, proc);

  if (closclassname) {
    Printv(clos_class_methods, "(define (", closprocname, " . lst) (if (null? lst) (", chickenPrimitiveName(primfunc), ") (",
	             chickenPrimitiveName(primfunc), " (slot-ref (car lst) 'swig-this))))\n", NIL);
  } else {
    Printv(clos_class_methods, "(define ", closprocname, " ", chickenPrimitiveName(primfunc), ")\n", NIL);
  }

  Delete(closprocname);

  return SWIG_OK;
}

int
CHICKEN::constructorHandler(Node *n)
{
  Language::constructorHandler(n);
  have_constructor = 1;
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
  Replaceall(scmname, "_", "-");

  Append(wname, Swig_name_wrapper(iname));

  Printv(f->def, "static void real_", wname, 
	 "(C_word, C_word, C_word, C_word) C_noret;\n", NIL);

  Printv(f->def, 
	 "static void real_",
	 wname,
	 "(C_word oldargc, C_word closure, C_word continuation, C_word args) {",
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
  addMethod(scmname, wname);

  DelWrapper(f);
  f = NewWrapper();

  /* varargs */
  Printv(f->def, "void ", wname, 
	 "(C_word, C_word, C_word, ...) C_noret;\n", NIL);
  Printv(f->def, "void ", wname,
	 "(C_word c, C_word t0, C_word t1, ...) {",
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

  DelWrapper(f);
  Delete(dispatch);
  Delete(tmp);
  Delete(wname);
}

int
CHICKEN::isPointer(SwigType *t)
{
  return SwigType_ispointer(SwigType_typedef_resolve_all(t));
}

void 
CHICKEN::addMethod(String *scheme_name, String *function) 
{
  String *sym = NewString("");
  if (clos) {
      Append(sym, "primitive:");
  }
  Append(sym, scheme_name);

  /* add symbol to Chicken internal symbol table */
  if (hide_primitive) {
    Printv(f_init, "{\n",
                   "  C_word *p0 = a;\n",
                   "  *(a++)=C_CLOSURE_TYPE|1;\n",
                   "  *(a++)=(C_word)", function, ";\n",
		   "  C_mutate(return_vec++, (C_word)p0);\n",
		   "}\n", NIL);
  } else {
    Printf(f_sym_size, "+C_SIZEOF_INTERNED_SYMBOL(%d)", Len(sym));    
    Printf(f_init, "sym = C_intern (&a, %d, \"%s\");\n", 
	   Len(sym), sym);
    Printv(f_init, 
	   "C_mutate ((C_word*)sym+1, (*a=C_CLOSURE_TYPE|1, a[1]=(C_word)", 
	   function, ", tmp=(C_word)a, a+=2, tmp));\n", NIL);
  } 

  if (hide_primitive) {
    Setattr(primitive_names, scheme_name, NewStringf("(vector-ref swig-init-return %i)", num_methods));
  } else {
    Setattr(primitive_names, scheme_name, Copy(sym));
  }

  num_methods++;

  Delete(sym);
}

String *
CHICKEN::chickenPrimitiveName(String *name) {
  String *value = Getattr(primitive_names, name);
  if (value)
    return value;
  else {
    Swig_error(input_file, line_number, "Internal Error: attempting to reference non-existant primitive name %s\n", name);
    return NewString("#f");
  }
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

  /* ------------------------------------------------------------
   * closNameMapping()
   * Maps the identifier from C++ to the CLOS based on command 
   * line paramaters and such.
   * If class_name = "" that means the mapping is for a function or
   * variable not attached to any class.
   * ------------------------------------------------------------ */
  String *CHICKEN::chickenNameMapping(String *name, String_or_char *class_name) {
    String *n = NewString("");
    
    if (Strcmp(class_name, "") == 0) {
      // not part of a class, so no class name to prefix
      if (closprefix) {
        Printf(n, "%s%s", closprefix, name);
      } else {
        Printf(n, "%s", name);
      }
    } else {
      if (useclassprefix) {
        Printf(n, "%s-%s", class_name, name);
      } else {
        if (closprefix) {
          Printf(n, "%s%s", closprefix, name);
        } else {
          Printf(n, "%s", name);
        }
      }
    }
    return n;
  }

  String *CHICKEN::runtimeCode() {
    String *s = Swig_include_sys("chickenrun.swg");
    if (!s) {
      Printf(stderr, "*** Unable to open 'chickenrun.swg'\n");
      s = NewString("");
    }
    return s;
  }

  String *CHICKEN::defaultExternalRuntimeFilename() {
    return NewString("swigchickenrun.h");
  }

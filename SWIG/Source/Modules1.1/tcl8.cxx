/* -----------------------------------------------------------------------------
 * tcl8.cxx
 *
 *     Tcl8.0 wrapper module.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "mod11.h"
#include "tcl8.h"
#ifndef MACSWIG
#include "swigconfig.h"
#endif

static char *usage = (char*)"\
Tcl 8 Options (available with -tcl)\n\
     -ldflags        - Print runtime libraries to link with\n\
     -prefix name    - Set a prefix to be appended to all names\n\
     -namespace      - Build module into a Tcl 8 namespace. \n\
     -pkgversion     - Set package version.\n\n";

static String     *cmd_tab = 0;                    /* Table of command names    */
static String     *var_tab = 0;                    /* Table of global variables */
static String     *const_tab = 0;                  /* Constant table            */
static String     *methods_tab = 0;                /* Methods table             */
static String     *attr_tab = 0;                   /* Attribute table           */
static String     *prefix = 0;
static String     *module = 0;
static int         nspace = 0;
static String     *init_name = 0;
static String     *ns_name = 0;
static int         have_constructor;
static int         have_destructor;
static String     *destructor_action = 0;

static String     *version = (String *) "0.0";

static String     *class_name = 0;


static File       *f_header  = 0;
static File       *f_wrappers = 0;
static File       *f_init = 0;
static File       *f_runtime = 0;

/* -----------------------------------------------------------------------------
 * TCL8::main()
 * ----------------------------------------------------------------------------- */

void
TCL8::main(int argc, char *argv[]) {
  
  SWIG_library_directory("tcl");

  for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	  if (strcmp(argv[i],"-prefix") == 0) {
	    if (argv[i+1]) {
	      prefix = NewString(argv[i+1]);
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i++;
	    } else Swig_arg_error();
	  } else if (strcmp(argv[i],"-pkgversion") == 0) {
	    if (argv[i+1]) {
	      version = NewString(argv[i+1]);
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i++;
	    }
	  } else if (strcmp(argv[i],"-namespace") == 0) {
	    nspace = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-help") == 0) {
	    fputs(usage,stderr);
	  } else if (strcmp (argv[i], "-ldflags") == 0) {
	    printf("%s\n", SWIG_TCL_RUNTIME);
	    SWIG_exit (EXIT_SUCCESS);
	  }
      }
  }
  Preprocessor_define((void *) "SWIGTCL 1",0);
  Preprocessor_define((void *) "SWIGTCL8 1", 0);
  SWIG_typemap_lang("tcl8");
  SWIG_config_file("tcl8.swg");
}

/* -----------------------------------------------------------------------------
 * TCL8::top()
 * ----------------------------------------------------------------------------- */

int
TCL8::top(Node *n) {

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

  /* Initialize some variables for the object interface */

  cmd_tab        = NewString("");
  var_tab        = NewString("");
  methods_tab    = NewString("");
  const_tab      = NewString("");

  Swig_banner(f_runtime);

  /* Include a Tcl configuration file */
  if (NoInclude) {
    Printf(f_runtime,"#define SWIG_NOINCLUDE\n");
  }

  /* Set the module name, namespace, and prefix */

  module = NewStringf("%(lower)s", Getattr(n,"name"));
  init_name = NewStringf("%(title)s_Init",module);

  ns_name = prefix ? Copy(prefix) : Copy(module);
  if (prefix) Append(prefix,"_");
 
  /* Generate some macros used throughout code generation */

  Printf(f_header,"#define SWIG_init    %s\n", init_name);
  Printf(f_header,"#define SWIG_name    \"%s\"\n", module);
  if (nspace) {
    Printf(f_header,"#define SWIG_prefix  \"%s::\"\n", ns_name);
    Printf(f_header,"#define SWIG_namespace \"%s\"\n\n", ns_name);
  } else {
    Printf(f_header,"#define SWIG_prefix  \"%s\"\n", prefix);
  }
  Printf(f_header,"#define SWIG_version \"%s\"\n", version);

  Printf(cmd_tab,   "\nstatic swig_command_info swig_commands[] = {\n");
  Printf(var_tab,   "\nstatic swig_var_info swig_variables[] = {\n");
  Printf(const_tab, "\nstatic swig_const_info swig_constants[] = {\n");

  Printf(f_wrappers,"#ifdef __cplusplus\nextern \"C\" {\n#endif\n");

  /* Start emitting code */
  Language::top(n);

  /* Done.  Close up the module */
  Printv(cmd_tab,   tab4, "{0, 0, 0}\n", "};\n",NULL);
  Printv(var_tab,   tab4, "{0,0,0,0}\n", "};\n",NULL);
  Printv(const_tab, tab4, "{0,0,0,0,0,0}\n", "};\n", NULL);

  Printv(f_wrappers, cmd_tab, var_tab, const_tab,NULL);

  /* Dump the pointer equivalency table */
  SwigType_emit_type_table(f_runtime, f_wrappers);

  Printf(f_wrappers,"#ifdef __cplusplus\n}\n#endif\n");

  /* Close the init function and quit */
  Printf(f_init,"return TCL_OK;\n}\n");

  /* Close all of the files */
  Printv(f_runtime, f_header, f_wrappers,NULL);
  Wrapper_pretty_print(f_init,f_runtime);
  Delete(f_header);
  Delete(f_wrappers);
  Delete(f_init);
  Close(f_runtime);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * TCL8::functionWrapper()
 * ----------------------------------------------------------------------------- */

int
TCL8::functionWrapper(Node *n) {
  String   *name  = Getattr(n,"name");       /* Like to get rid of this */
  String   *iname = Getattr(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  ParmList *parms = Getattr(n,"parms");

  Parm            *p;
  int              i;
  String          *tm;
  Wrapper         *f;
  String          *incode, *cleanup, *outarg, *argstr, *args;
  int              num_arguments = 0;
  int              num_required = 0;
  int              varargs = 0;

  char             source[64];

  if (!addSymbol(iname,n)) return SWIG_ERROR;

  incode  = NewString("");
  cleanup = NewString("");
  outarg  = NewString("");
  argstr  = NewString("\"");
  args    = NewString("");

  f = NewWrapper();
  Printv(f->def,
	 "static int\n ", Swig_name_wrapper(iname), "(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {",
	 NULL);

  /* Print out variables for storing arguments. */
  emit_args(type,parms, f);
  
  /* Attach standard typemaps */
  emit_attach_parmmaps(parms,f);

  /* Get number of require and total arguments */
  num_arguments = emit_num_arguments(parms);
  num_required  = emit_num_required(parms);
  varargs       = emit_isvarargs(parms);

  /* Unmarshal parameters */

  for (i = 0, p = parms; i < num_arguments; i++) {
    /* Skip ignored arguments */
    while (Getattr(p,"tmap:ignore")) {
      p = Getattr(p,"tmap:ignore:next");
    }

    SwigType *pt = Getattr(p,"type");
    String   *ln = Getattr(p,"lname");

    /* Produce string representations of the source and target arguments */
    sprintf(source,"objv[%d]",i+1);

    if (i == num_required) Putc('|',argstr);
    if ((tm = Getattr(p,"tmap:in"))) {
      String *parse = Getattr(p,"tmap:in:parse");
      if (!parse) {
	Replaceall(tm,"$target",ln);
	Replaceall(tm,"$source",source);
	Replaceall(tm,"$input",source);
	Setattr(p,"emit:input",source);
	Putc('o',argstr);
	Printf(args,",0");
	if (i >= num_required)
	  Printf(incode, "if (objc > %d)\n", i+1);
	Printf(incode,"%s\n", tm);
      } else {
	Printf(argstr,"%s",parse);
	Printf(args,",&%s",ln);
	if (Strcmp(parse,"p") == 0) {
	  SwigType *lt = SwigType_ltype(pt);
	  SwigType_remember(pt);
	  if (Cmp(lt,"p.void") == 0) {
	    Printf(args,",0");
	  } else {
	    Printf(args,",SWIGTYPE%s", SwigType_manglestr(pt));
	  }
	  Delete(lt);
	}
      }
      p = Getattr(p,"tmap:in:next");
      continue;
    } else {
      Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number,
		   "Unable to use type %s as a function argument.\n", SwigType_str(pt,0));
    }
    p = nextSibling(p);
  }

  if (!varargs) {
    Putc(':',argstr);
  } else {
    Putc(';',argstr);
    /* If variable length arguments we need to emit the in typemap here */
    if (p && (tm = Getattr(p,"tmap:in"))) {
      String *ln = Getattr(p,"lname");
      sprintf(source,"objv[%d]", i+1);
      Printf(incode,"if (objc > %d) {\n", i);
      Replaceall(tm,"$input",source);
      Printv(incode,tm,"\n", NULL);
      Printf(incode,"}\n");
    }
  }

  Printf(argstr,"%s\"",usage_string(Char(iname),type,parms));

  Printv(f->code,
	 "if (SWIG_GetArgs(interp, objc, objv,", argstr, args, ") == TCL_ERROR) return TCL_ERROR;\n",
	 NULL);

  Printv(f->code,incode,NULL);

  /* Insert constraint checking code */
  for (p = parms; p;) {
    if ((tm = Getattr(p,"tmap:check"))) {
      Replaceall(tm,"$target",Getattr(p,"lname"));
      Printv(f->code,tm,"\n",NULL);
      p = Getattr(p,"tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }
  
  /* Insert cleanup code */
  for (i = 0, p = parms; p; i++) {
    if ((tm = Getattr(p,"tmap:freearg"))) {
      Replaceall(tm,"$source",Getattr(p,"lname"));
      Printv(cleanup,tm,"\n",NULL);
      p = Getattr(p,"tmap:freearg:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Insert argument output code */
  for (i=0,p = parms; p;i++) {
    if ((tm = Getattr(p,"tmap:argout"))) {
      Replaceall(tm,"$source",Getattr(p,"lname"));
      Replaceall(tm,"$target","(Tcl_GetObjResult(interp))");
      Replaceall(tm,"$result","(Tcl_GetObjResult(interp))");
      Replaceall(tm,"$arg",Getattr(p,"emit:input"));
      Replaceall(tm,"$input",Getattr(p,"emit:input"));
      Printv(outarg,tm,"\n",NULL);
      p = Getattr(p,"tmap:argout:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Now write code to make the function call */
  emit_action(n,f);

  /* Need to redo all of this code (eventually) */

  /* Return value if necessary  */
  if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
    Replaceall(tm,"$source", "result");
    Replaceall(tm,"$target", "Tcl_GetObjResult(interp)");
    Replaceall(tm,"$result", "Tcl_GetObjResult(interp)");
    Printf(f->code,"%s\n", tm);
  } else {
    Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
		 "Unable to use return type %s in function %s.\n", SwigType_str(type,0), name);
  }

  /* Dump output argument code */
  Printv(f->code,outarg,NULL);

  /* Dump the argument cleanup code */
  Printv(f->code,cleanup,NULL);

  /* Look for any remaining cleanup */
  if ((NewObject) || (Getattr(n,"feature:new"))) {
    if ((tm = Swig_typemap_lookup_new("newfree",n,"result",0))) {
      Replaceall(tm,"$source","result");
      Printf(f->code,"%s\n", tm);
    }
  }

  if ((tm = Swig_typemap_lookup_new("ret",n,"result",0))) {
    Replaceall(tm,"$source","result");
    Printf(f->code,"%s\n", tm);
  }
  Printv(f->code, "return TCL_OK;\n}", NULL);

  /* Substitute the cleanup code */
  Replaceall(f->code,"$cleanup",cleanup);
  Replaceall(f->code,"$symname", iname);

  /* Dump out the function */
  Wrapper_print(f,f_wrappers);

  /* Register the function with Tcl */
  Printv(cmd_tab, tab4, "{ SWIG_prefix \"", iname, "\", (swig_wrapper_func) ", Swig_name_wrapper(iname), ", NULL},\n", NULL);


  Delete(incode);
  Delete(cleanup);
  Delete(outarg);
  Delete(argstr);
  Delete(args);
  DelWrapper(f);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * TCL8::variableWrapper()
 * ----------------------------------------------------------------------------- */

int
TCL8::variableWrapper(Node *n) {

  char *name  = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *t = Getattr(n,"type");

  String *setname = 0;
  String *getname = 0;
  Wrapper *setf = 0, *getf = 0;
  int readonly = 0;
  String *tm;

  if (!addSymbol(iname,n)) return SWIG_ERROR;

  /* Create a function for getting a variable */
  getf = NewWrapper();
  getname = Swig_name_wrapper(Swig_name_get(iname));
  Printv(getf->def,"static char *",getname,"(ClientData clientData, Tcl_Interp *interp, char *name1, char *name2, int flags) {",NULL);
  Wrapper_add_local(getf,"value", "Tcl_Obj *value = 0");

  if ((tm = Swig_typemap_lookup_new("varout",n,name,0))) {
    Replaceall(tm,"$source", name);
    Replaceall(tm,"$target","value");
    Replaceall(tm,"$result", "value");
    Printf(getf->code, "%s\n",tm);
    Printf(getf->code, "if (value) {\n");
    Printf(getf->code, "Tcl_SetVar2(interp,name1,name2,Tcl_GetStringFromObj(value,NULL), flags);\n");
    Printf(getf->code, "Tcl_DecrRefCount(value);\n");
    Printf(getf->code, "}\n");
    Printf(getf->code, "return NULL;\n");
    Printf(getf->code,"}\n");
    Wrapper_print(getf,f_wrappers);
  } else {
    Swig_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number, 
		 "Can't link to variable of type %s\n", SwigType_str(t,0));
    DelWrapper(getf);
    return SWIG_NOWRAP;
  }
  DelWrapper(getf);

  /* Try to create a function setting a variable */
  if (!Getattr(n,"feature:immutable")) {
    setf = NewWrapper();
    setname = Swig_name_wrapper(Swig_name_set(iname));
    Printv(setf->def,"static char *",setname, "(ClientData clientData, Tcl_Interp *interp, char *name1, char *name2, int flags) {",NULL);
    Wrapper_add_local(setf,"value", "Tcl_Obj *value = 0");
    Wrapper_add_local(setf,"name1o", "Tcl_Obj *name1o = 0");

    if ((tm = Swig_typemap_lookup_new("varin", n, name, 0))) {
      Replaceall(tm,"$source","value");
      Replaceall(tm,"$target",name);
      Replaceall(tm,"$input", "value");
      Printf(setf->code,"name1o = Tcl_NewStringObj(name1,-1);\n");
      Printf(setf->code,"value = Tcl_ObjGetVar2(interp, name1o, 0, flags);\n");
      Printf(setf->code,"Tcl_DecrRefCount(name1o);\n");
      Printf(setf->code,"if (!value) return NULL;\n");
      Printf(setf->code,"%s\n", tm);
      Printf(setf->code,"return NULL;\n");
      Printf(setf->code,"}\n");
      if (setf) Wrapper_print(setf,f_wrappers);  
    } else {
      Swig_warning(WARN_TYPEMAP_VARIN_UNDEF,input_file, line_number,
		   "Variable %s will be read-only without a varin typemap.\n", name);
      readonly = 1;
    }
    DelWrapper(setf);
  } 

  Printv(var_tab, tab4,"{ SWIG_prefix \"", iname, "\", 0, (swig_variable_func) ", getname, ",", NULL);
  if (readonly || Getattr(n,"feature:immutable")) {
    static int readonlywrap = 0;
    if (!readonlywrap) {
      Wrapper *ro = NewWrapper();
      Printf(ro->def, "static const char *swig_readonly(ClientData clientData, Tcl_Interp *interp, char *name1, char *name2, int flags) {");
      Printv(ro->code, "return (char*) \"Variable is read-only\";\n", "}\n", NULL);
      Wrapper_print(ro,f_wrappers);
      readonlywrap = 1;
      DelWrapper(ro);
    }
    Printf(var_tab, "(swig_variable_func) swig_readonly},\n");
  } else {
    Printv(var_tab, "(swig_variable_func) ", setname, "},\n",NULL);
  }
  
  Delete(setname);
  Delete(getname);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * TCL8::constantWrapper()
 * ----------------------------------------------------------------------------- */

int
TCL8::constantWrapper(Node *n) {
  char *name      = GetChar(n,"name");
  char *iname     = GetChar(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  String   *value = Getattr(n,"value");
  String *tm;

  if (!addSymbol(iname,n)) return SWIG_ERROR;

  /* Special hook for member pointer */
  if (SwigType_type(type) == T_MPOINTER) {
    String *wname = Swig_name_wrapper(iname);
    Printf(f_wrappers, "static %s = %s;\n", SwigType_str(type,wname), value);
    value = Char(wname);
  }
  if ((tm = Swig_typemap_lookup_new("consttab",n,name,0))) {
    Replaceall(tm,"$source",value);
    Replaceall(tm,"$target",name);
    Replaceall(tm,"$value",value);
    Printf(const_tab,"%s,\n", tm);
  } else if ((tm = Swig_typemap_lookup_new("constcode", n, name, 0))) {
    Replaceall(tm,"$source", value);
    Replaceall(tm,"$target", name);
    Replaceall(tm,"$value",value);
    Printf(f_init, "%s\n", tm);
  } else {
    Swig_warning(WARN_TYPEMAP_CONST_UNDEF,
		 input_file, line_number, "Unsupported constant value.\n");
    return SWIG_NOWRAP;
  }
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * TCL8::usage_string()
 * ----------------------------------------------------------------------------- */

char *
TCL8::usage_string(char *iname, SwigType *, ParmList *l) {
  static String *temp = 0;
  Parm  *p;
  int   i, numopt,pcount;

  if (!temp) temp = NewString("");
  Clear(temp);
  if (nspace) {
    Printf(temp,"%s::%s", ns_name,iname);
  } else {
    Printf(temp,"%s ", iname);
  }
  /* Now go through and print parameters */
  i = 0;
  pcount = ParmList_len(l);
  numopt = 0; /*check_numopt(l); */
  for (p = l; p; p = nextSibling(p)) {
    
    SwigType  *pt = Getattr(p,"type");
    String    *pn = Getattr(p,"name");

    /* Only print an argument if not ignored */
    if (!Swig_typemap_search((char*)"ignore",pt,pn)) {
      if (i >= (pcount-numopt))
	Putc('?',temp);
      if (Len(pn) > 0) {
	Printf(temp, "%s",pn);
      } else {
	Printf(temp,"%s", SwigType_str(pt,0));
      }
      if (i >= (pcount-numopt))	Putc('?',temp);
      Putc(' ',temp);
      i++;
    }
  }
  return Char(temp);
}

/* -----------------------------------------------------------------------------
 * TCL8::nativeWrapper()
 * ----------------------------------------------------------------------------- */

int
TCL8::nativeWrapper(Node *n) {
  String *name = Getattr(n,"sym:name");
  String *funcname = Getattr(n,"wrap:name");
  if (!addSymbol(funcname,n)) return SWIG_ERROR;

  Printf(f_init,"\t Tcl_CreateObjCommand(interp, SWIG_prefix \"%s\", (swig_wrapper_func) %s, (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL);\n",name, funcname);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * classHandler()
 * ----------------------------------------------------------------------------- */

int
TCL8::classHandler(Node *n) {
  
  String     *mangled_classname = 0;
  String     *real_classname = 0;

  have_constructor = 0;
  have_destructor = 0;
  destructor_action = 0;

  class_name = Getattr(n,"sym:name");
  if (!addSymbol(class_name,n)) return SWIG_ERROR;

  real_classname = Getattr(n,"name");
  mangled_classname = Swig_name_mangle(real_classname);

  attr_tab = NewString("");
  Printf(attr_tab, "static swig_attribute swig_");
  Printv(attr_tab, mangled_classname, "_attributes[] = {\n", NULL);
  
  methods_tab = NewStringf("");
  Printf(methods_tab,"static swig_method swig_");
  Printv(methods_tab, mangled_classname, "_methods[] = {\n", NULL);

  /* Generate normal wrappers */
  Language::classHandler(n);

  SwigType *t = Copy(Getattr(n,"classtype"));
  SwigType_add_pointer(t);
  
  // Catch all: eg. a class with only static functions and/or variables will not have 'remembered'
  SwigType_remember(t);

  // Register the class structure with the type checker
  Printf(f_init,"SWIG_TypeClientData(SWIGTYPE%s, (void *) &_wrap_class_%s);\n", SwigType_manglestr(t), mangled_classname);
  if (have_destructor) {
    Printv(f_wrappers, "static void swig_delete_", class_name, "(void *obj) {\n", NULL);
    if (destructor_action) {
      Printv(f_wrappers, SwigType_str(t,"arg1"), " = (", SwigType_str(t,0), ") obj;\n", NULL);
      Printv(f_wrappers, destructor_action, NULL);
    } else {
      if (CPlusPlus) {
	Printv(f_wrappers,"    delete (", SwigType_str(t,0), ") obj;\n",NULL);
      } else {
	Printv(f_wrappers,"    free((char *) obj);\n",NULL);
      }
    }
    Printf(f_wrappers,"}\n");
  }
  
  Printf(methods_tab, "    {0,0}\n};\n");
  Printv(f_wrappers,methods_tab,NULL);
  
  Printf(attr_tab, "    {0,0,0}\n};\n");
  Printv(f_wrappers,attr_tab,NULL);
  
  /* Handle inheritance */
  
  String *base_class = NewString("");
  List *baselist = Getattr(n,"bases");
  if (baselist && Len(baselist)) {
    Node *base = Firstitem(baselist);
    while (base) {
      String *bname = Getattr(base, "name");

      if (!bname) {
	base = Nextitem(baselist);
	continue;
      }
      String *bmangle = Swig_name_mangle(bname);
      Printv(f_wrappers,"extern swig_class _wrap_class_", bmangle, ";\n", NULL);
      Printf(base_class,"&_wrap_class_%s",bmangle);
      base = Nextitem(baselist);
      Putc(',',base_class);
      Delete(bmangle);
    }
  }

  Printv(f_wrappers,"static swig_class *swig_",mangled_classname,"_bases[] = {", base_class,"0};\n", NULL);
  Delete(base_class);

  Printv(f_wrappers, "swig_class _wrap_class_", mangled_classname, " = { \"", class_name,
	 "\", &SWIGTYPE", SwigType_manglestr(t), ",",NULL);
  
  if (have_constructor) {
    Printf(f_wrappers,"%s", Swig_name_wrapper(Swig_name_construct(class_name)));
  } else {
    Printf(f_wrappers,"0");
  }
  if (have_destructor) {
    Printv(f_wrappers, ", swig_delete_", class_name,NULL);
  } else {
    Printf(f_wrappers,",0");
  }
  Printv(f_wrappers, ", swig_", mangled_classname, "_methods, swig_", mangled_classname, "_attributes, swig_", mangled_classname,"_bases };\n", NULL);
  Printv(cmd_tab, tab4, "{ SWIG_prefix \"", class_name, "\", (swig_wrapper_func) SWIG_ObjectConstructor, &_wrap_class_", mangled_classname, "},\n", NULL);
  Delete(t);
  Delete(mangled_classname);
  return SWIG_OK;
}


/* -----------------------------------------------------------------------------
 * memberfunctionHandler()
 * ----------------------------------------------------------------------------- */

int TCL8::memberfunctionHandler(Node *n) {
  char *name = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");

  char *realname;
  String  *rname;

  Language::memberfunctionHandler(n);

  realname = iname ? iname : name;
  rname = Swig_name_wrapper(Swig_name_member(class_name, realname));
  Printv(methods_tab, tab4, "{\"", realname, "\", ", rname, "}, \n", NULL);
  Delete(rname);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * membervariableHandler()
 * ----------------------------------------------------------------------------- */

int TCL8::membervariableHandler(Node *n) {
    String   *symname = Getattr(n,"sym:name");
    String *rname;

    Language::membervariableHandler(n);
    Printv(attr_tab, tab4, "{ \"-", symname, "\",", NULL);
    rname = Swig_name_wrapper(Swig_name_get(Swig_name_member(class_name,symname)));
    Printv(attr_tab, rname, ", ", NULL);
    Delete(rname);
    if (!Getattr(n,"feature:immutable")) {
      rname = Swig_name_wrapper(Swig_name_set(Swig_name_member(class_name,symname)));
      Printv(attr_tab, rname, "},\n",NULL);
      Delete(rname);
    } else {
      Printf(attr_tab, "0 },\n");
    }
    return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * constructorHandler()
 * ----------------------------------------------------------------------------- */

int
TCL8::constructorHandler(Node *n) {
  Language::constructorHandler(n);
  have_constructor = 1;
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * destructorHandler()
 * ----------------------------------------------------------------------------- */

int
TCL8::destructorHandler(Node *n) {
  Language::destructorHandler(n);
  have_destructor = 1;
  destructor_action = Getattr(n,"wrap:action");
  return SWIG_OK;
}


int TCL8::validIdentifier(String *s) {
  if (Strchr(s,' ')) return 0;
  return 1;
}






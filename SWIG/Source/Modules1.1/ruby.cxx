/********************************************************************
 * Ruby module for SWIG
 *
 * $Header$
 *
 * Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
 * Copyright (C) 2000  Information-technology Promotion Agency, Japan
 *
 * Masaki Fukushima
 *
 ********************************************************************/

static char cvsroot[] = "$Header$";

#include "mod11.h"
#include "ruby.h"
#ifndef MACSWIG
#include "swigconfig.h"
#endif

#include <ctype.h>
#include <string.h>

static  File         *f_runtime = 0;
static  File         *f_header = 0;
static  File         *f_wrappers = 0;
static  File         *f_init = 0;

class RClass {
 private:
  String *temp;
 public:
  String *name;    /* class name (renamed) */
  String *cname;   /* original C class/struct name */
  String *vname;   /* variable name */
  String *type;
  String *prefix;
  String *header;
  String *init;

  String *aliases;
  String *includes;
  Hash *freemethods;
  Hash *predmethods;
  int constructor_defined;
  int destructor_defined;

  RClass() {
    temp = NewString("");
    name = NewString("");
    cname = NewString("");
    vname = NewString("");
    type = NewString("");
    prefix = NewString("");
    header = NewString("");
    init = NewString("");
    aliases = NewString("");
    includes = NewString("");
    freemethods = NewHash();
    predmethods = NewHash();
    constructor_defined = 0;
    destructor_defined = 0;
  }
  ~RClass() {
    Delete(name);
    Delete(cname);
    Delete(vname);
    Delete(type);
    Delete(prefix);
    Delete(header);
    Delete(init);
    Delete(aliases);
    Delete(includes);
    Delete(freemethods);
    Delete(predmethods);
    Delete(temp);
  }

  void set_name(char *cn, char *rn, char *valn) {
    Clear(cname);
    Append(cname,cn);
    Clear(name);
    Append(name,valn);
    Clear(vname);
    Printf(vname,"c%s.klass",name);
    Clear(prefix);
    Printv(prefix,(rn ? rn : cn), "_", 0);
  }

  char *strip(char *s) {
    if (strncmp(s, Char(prefix), Len(prefix)) != 0)
      return s;
    Clear(temp);
    Append(temp,s);
    Replace(temp,prefix,"",DOH_REPLACE_ANY);
    return Char(temp);
  }
};


static char *usage = (char*)"\
Ruby Options (available with -ruby)\n\
     -ldflags        - Print runtime libraries to link with\n\
     -feature name   - Set feature name (used by `require')\n";

static  char *module;
static  char *modvar;
static  char *feature;
static  String *other_extern = 0;
static  String *other_init = 0;
static  char *import_file;

static int current;

enum {
  NO_CPP,
  MEMBER_FUNC,
  CONSTRUCTOR_NEW,
  CONSTRUCTOR_INITIALIZE,
  DESTRUCTOR,
  MEMBER_VAR,
  CLASS_CONST,
  STATIC_FUNC,
  STATIC_VAR
};

static  Hash *classes;		/* key=cname val=RClass */
static  RClass *klass;		/* Currently processing class */
static  Hash *special_methods;	/* Python style special method name table */


#define RCLASS(hash, name) (RClass*)(Getattr(hash, name) ? Data(Getattr(hash, name)) : 0)
#define SET_RCLASS(hash, name, klass) Setattr(hash, name, NewVoid(klass, 0))

/* ---------------------------------------------------------------------
 * RUBY::main()
 *
 * Parse command line options and initializes variables.
 * --------------------------------------------------------------------- */

void RUBY::main(int argc, char *argv[]) {
  /* Look for certain command line options */
  for (int i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i],"-feature") == 0) {
	if (argv[i+1]) {
	  char *name = argv[i+1];
	  feature = new char [strlen(name)+1];
	  strcpy(feature, name);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i+1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i],"-help") == 0) {
	Printf(stderr,"%s\n", usage);
      } else if (strcmp (argv[i], "-ldflags") == 0) {
	printf("%s\n", SWIG_RUBY_RUNTIME);
	SWIG_exit (EXIT_SUCCESS);
      }
    }
  }
  /* Set location of SWIG library */
  SWIG_library_directory("ruby");

  /* Add a symbol to the parser for conditional compilation */
  Preprocessor_define((void *) "SWIGRUBY", 0);

  /* Add typemap definitions */
  SWIG_typemap_lang("ruby");
  SWIG_config_file("ruby.swg");
}

/* ---------------------------------------------------------------------
 * RUBY::top()
 * --------------------------------------------------------------------- */

int RUBY::top(Node *n) {

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

  module = 0;
  modvar = 0;
  feature = 0;
  import_file = 0;
  current = NO_CPP;
  klass = 0;
  classes = NewHash();
  special_methods = NewHash();
  other_extern = NewString("");
  other_init = NewString("");

  /* Python style special method name. */
  /* Basic */
  Setattr(special_methods, "__repr__", "inspect");
  Setattr(special_methods, "__str__", "to_s");
  Setattr(special_methods, "__cmp__", "<=>");
  Setattr(special_methods, "__hash__", "hash");
  Setattr(special_methods, "__nonzero__", "nonzero?");
  
  /* Callable */
  Setattr(special_methods, "__call__", "call");
  
  /* Collection */
  Setattr(special_methods, "__len__", "length");
  Setattr(special_methods, "__getitem__", "[]");
  Setattr(special_methods, "__setitem__", "[]=");
  
  /* Operators */
  Setattr(special_methods, "__add__", "+");
  Setattr(special_methods, "__pos__", "+@");
  Setattr(special_methods, "__sub__", "-");
  Setattr(special_methods, "__neg__", "-@");
  Setattr(special_methods, "__mul__", "*");
  Setattr(special_methods, "__div__", "/");
  Setattr(special_methods, "__mod__", "%");
  Setattr(special_methods, "__lshift__", "<<");
  Setattr(special_methods, "__rshift__", ">>");
  Setattr(special_methods, "__and__", "&");
  Setattr(special_methods, "__or__", "|");
  Setattr(special_methods, "__xor__", "^");
  Setattr(special_methods, "__invert__", "~");
  Setattr(special_methods, "__lt__", "<");
  Setattr(special_methods, "__le__", "<=");
  Setattr(special_methods, "__gt__", ">");
  Setattr(special_methods, "__ge__", ">=");
  Setattr(special_methods, "__eq__", "==");

  /* Other numeric */
  Setattr(special_methods, "__divmod__", "divmod");
  Setattr(special_methods, "__pow__", "**");
  Setattr(special_methods, "__abs__", "abs");
  Setattr(special_methods, "__int__", "to_i");
  Setattr(special_methods, "__float__", "to_f");
  Setattr(special_methods, "__coerce__", "coerce");

  Swig_banner(f_runtime);

  if (NoInclude) {
    Printf(f_runtime, "#define SWIG_NOINCLUDE\n");
  }

  /* typedef void *VALUE */
  SwigType *value = NewSwigType(T_VOID);
  SwigType_add_pointer(value);
  SwigType_typedef(value,(char*)"VALUE");
  Delete(value);

  set_module(Char(Getattr(n,"name")));

  Printf(f_header,"#define SWIG_init    Init_%s\n", feature);
  Printf(f_header,"#define SWIG_name    \"%s\"\n\n", module);
  Printf(f_header,"static VALUE %s;\n", modvar);
  Printf(f_header,"\n%s\n", other_extern);

  /* Start generating the initialization function */
  Printv(f_init,
	 "\n",
	 "#ifdef __cplusplus\n",
	 "extern \"C\"\n",
	 "#endif\n",
	 "void Init_", feature, "(void) {\n",
	 "int i;\n",
	 other_init,
	 "\n",
	 0);

  Printv(f_init, tab4, "SWIG_InitRuntime();\n", 0);
  
  Printv(f_init, tab4, modvar, " = rb_define_module(\"", module, "\");\n",
	 0);
  Printv(f_init,
	 "\n",
	 "for (i = 0; swig_types_initial[i]; i++) {\n",
	 "swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);\n",
	 "SWIG_define_class(swig_types[i]);\n",
	 "}\n",
	 0);
  Printf(f_init,"\n");
  klass = new RClass();

  Language::top(n);

  /* Finish off our init function */
  Printf(f_init,"}\n");
  SwigType_emit_type_table(f_header,f_wrappers);

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

/* ---------------------------------------------------------------------
 * RUBY::set_module(char *mod_name)
 *
 * Sets the module name.  Does nothing if it's already set (so it can
 * be overridden as a command line option).
 *---------------------------------------------------------------------- */


void RUBY::set_module(char *mod_name) {
  if (import_file) {
    Printf(f_init, "%srb_f_require(Qnil, rb_str_new2(\"%s\"));\n", tab4, mod_name);
    free(import_file);  /* Note: was allocated from C */
    import_file = 0;
  }

  if (module) return;

  if (!feature) {
    feature = new char[strlen(mod_name)+1];
    strcpy(feature, mod_name);
  }

  module = new char[strlen(mod_name)+1];
  strcpy(module, mod_name);
  /* module name must be a constant. */
  module[0] = toupper(module[0]);

  modvar = new char[1+strlen(module)+1];
  modvar[0] = 'm';
  strcpy(modvar+1, module);
}

/* --------------------------------------------------------------------------
 * RUBY::nativeWrapper()
 * -------------------------------------------------------------------------- */
int
RUBY::nativeWrapper(Node *n) {
  String *funcname = Getattr(n,"wrap:name");
  Printf(stderr,"%s : Line %d.  Adding native function %s not supported (ignored).\n", input_file, line_number, funcname);
  return SWIG_NOWRAP;
}

/* ---------------------------------------------------------------------
 * RUBY::make_wrapper_name(char *cname)
 *
 * Creates a name for a wrapper function
 *              iname = Name of the function in scripting language
 * --------------------------------------------------------------------- */

String *RUBY::make_wrapper_name(char *iname) {
  String *wname = Swig_name_wrapper(iname);
  Replace(wname, "?", "_p", DOH_REPLACE_ANY);
  Replace(wname, "!", "_bang", DOH_REPLACE_ANY);
  return wname;
}

/* ---------------------------------------------------------------------
 * RUBY::create_command(char *cname, char *iname)
 *
 * Creates a new command from a C function.
 *              cname = Name of the C function
 *              iname = Name of function in scripting language
 *              argc  = Number of arguments
 * --------------------------------------------------------------------- */

void RUBY::create_command(char *cname, char *iname, int argc) {
  String *wname = make_wrapper_name(iname);
  if (CPlusPlus) {
    Insert(wname,0,"VALUEFUNC(");
    Append(wname,")");
  }
  if (current != NO_CPP)
    iname = klass->strip(iname);
  if (Getattr(special_methods, iname)) {
    iname = GetChar(special_methods, iname);
  }

  String *s = NewString("");
  String *temp = NewString("");
  char argcs[32];
  sprintf(argcs,"%d",argc);

  switch (current) {
  case MEMBER_FUNC:
    Printv(klass->init, tab4, "rb_define_method(", klass->vname, ", \"",
	   iname, "\", ", wname, ", ", argcs, ");\n", 0);

    break;
  case CONSTRUCTOR_NEW:
    Printv(s, tab4, "rb_define_singleton_method(", klass->vname,
	   ", \"new\", ", wname, ", -1);\n", 0);
    Replace(klass->init,"$constructor", s, DOH_REPLACE_ANY);
    break;
  case CONSTRUCTOR_INITIALIZE:
    Printv(s, tab4, "rb_define_method(", klass->vname,
	   ", \"initialize\", ", wname, ", ", argcs, ");\n", 0);
    Replace(klass->init,"$initializer", s, DOH_REPLACE_ANY);
    break;
  case MEMBER_VAR:
    Append(temp,iname);
    Replace(temp,"_set", "=", DOH_REPLACE_ANY);
    Replace(temp,"_get", "", DOH_REPLACE_ANY);
    Printv(klass->init, tab4, "rb_define_method(", klass->vname, ", \"",
	   temp, "\", ", wname, ", ", argcs, ");\n", 0);
    break;
  case STATIC_FUNC:
    Printv(klass->init, tab4, "rb_define_singleton_method(", klass->vname,
	   ", \"", iname, "\", ", wname, ", ", argcs, ");\n", 0);
    break;
  default:
    Printv(s, tab4, "rb_define_module_function(", modvar, ", \"",
	   iname, "\", ", wname, ", ", argcs, ");\n",0);
    Printv(f_init,s,0);
    break;
  }
  Delete(s);
  Delete(temp);
}

/* ---------------------------------------------------------------------
 * RUBY::marshalInputArgs(int numarg, int numreq, int start, Wrapper *f)
 *
 * Checks each of the parameters in the parameter list for a "check"
 * typemap and (if it finds one) inserts the typemapping code into
 * the function wrapper.
 * --------------------------------------------------------------------- */

void RUBY::marshalInputArgs(ParmList *l, int numarg, int numreq, int start, Wrapper *f) {
  int i;
  Parm *p;
  String *tm;
  char source[256], target[256];
  
  int use_self = (current == MEMBER_FUNC || current == MEMBER_VAR) ? 1 : 0;

  for (i = 0, p = l; i < numarg; i++) {
    /* Skip ignored arguments */
    while (Getattr(p,"tmap:ignore")) {
      p = Getattr(p,"tmap:ignore:next");
    }

    SwigType *pt = Getattr(p,"type");
    String   *ln = Getattr(p,"lname");

    /* Produce string representation of source and target arguments */
    int selfp = (use_self && i == 0);
    if (selfp)
      strcpy(source,"self");
    else
      sprintf(source,"argv[%d]",i-start);

    sprintf(target,"%s", Char(ln));

    if (i >= (numreq)) { /* Check if parsing an optional argument */
	Printf(f->code,"    if (argc > %d) {\n", i -  start);
    }

    if ((tm = Getattr(p,"tmap:in"))) {
      Replace(tm,"$target",ln,DOH_REPLACE_ANY);
      Replace(tm,"$source",source,DOH_REPLACE_ANY);
      Replace(tm,"$input",source,DOH_REPLACE_ANY);
      Setattr(p,"emit:input",source);
      Printf(f->code,"%s\n", tm);
      p = Getattr(p,"tmap:in:next");
    } else {
      Printf(stderr,"%s:%d.  Unsupported datatype %s\n", input_file, line_number, SwigType_str(pt,0));
      p = nextSibling(p);
    }
    if (i >= numreq) {
      Printf(f->code,"}\n");
    }
  }
}

/* ---------------------------------------------------------------------
 * RUBY::insertConstraintCheckingCode(ParmList *l, Wrapper *f)
 *
 * Checks each of the parameters in the parameter list for a "check"
 * typemap and (if it finds one) inserts the typemapping code into
 * the function wrapper.
 * --------------------------------------------------------------------- */

void RUBY::insertConstraintCheckingCode(ParmList *l, Wrapper *f) {
  Parm *p;
  String *tm;
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:check"))) {
      Replace(tm,"$target",Getattr(p,"lname"),DOH_REPLACE_ANY);
      Printv(f->code,tm,"\n",0);
      p = Getattr(p,"tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }
}

/* ---------------------------------------------------------------------
 * RUBY::insertCleanupCode(ParmList *l, String *cleanup)
 *
 * Checks each of the parameters in the parameter list for a "freearg"
 * typemap and (if it finds one) inserts the typemapping code into
 * the function wrapper.
 * --------------------------------------------------------------------- */

void RUBY::insertCleanupCode(ParmList *l, String *cleanup) {
  String *tm;
  for (Parm *p = l; p; ) {
    if ((tm = Getattr(p,"tmap:freearg"))) {
      Replace(tm,"$source",Getattr(p,"lname"),DOH_REPLACE_ANY);
      Printv(cleanup,tm,"\n",0);
      p = Getattr(p,"tmap:freearg:next");
    } else {
      p = nextSibling(p);
    }
  }
}

/* ---------------------------------------------------------------------
 * RUBY::insertCleanupCode(ParmList *l, String *cleanup)
 *
 * Checks each of the parameters in the parameter list for a "argout"
 * typemap and (if it finds one) inserts the typemapping code into
 * the function wrapper.
 * --------------------------------------------------------------------- */

void RUBY::insertArgOutputCode(ParmList *l, String *outarg, int& need_result) {
  Parm *p;
  String *tm;
  for (Parm *p = l; p; ) {
    if ((tm = Getattr(p,"tmap:argout"))) {
      Replace(tm,"$source",Getattr(p,"lname"),DOH_REPLACE_ANY);
      Replace(tm,"$target","vresult",DOH_REPLACE_ANY);
      Replace(tm,"$result","vresult",DOH_REPLACE_ANY);
      Replace(tm,"$arg",Getattr(p,"emit:input"), DOH_REPLACE_ANY);
      Replace(tm,"$input",Getattr(p,"emit:input"), DOH_REPLACE_ANY);
      Printv(outarg,tm,"\n",0);
      need_result = 1;
      p = Getattr(p,"tmap:argout:next");
    } else {
      p = nextSibling(p);
    }
  }
}

/* ---------------------------------------------------------------------
 * RUBY::functionWrapper()
 *
 * Create a function declaration and register it with the interpreter.
 * --------------------------------------------------------------------- */

int RUBY::functionWrapper(Node *n) {
  char *name = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *t = Getattr(n,"type");
  ParmList *l = Getattr(n,"parms");
  String *tm;
  String *cleanup, *outarg;
  Wrapper *f;
  int i;
  Parm *p;

  /* Ruby needs no destructor wrapper */
  if (current == DESTRUCTOR)
    return SWIG_NOWRAP;

  char mname[256], inamebuf[256];
  int predicate = 0, need_result = 0;

  cleanup = NewString("");
  outarg = NewString("");
  f = NewWrapper();

  switch (current) {
  case MEMBER_FUNC:
  case MEMBER_VAR:
  case STATIC_FUNC:
    strcpy(mname, klass->strip(iname));
    if (Getattr(klass->predmethods, mname)) {
      predicate = 1;
      sprintf(inamebuf,"%s?",iname);
      iname = inamebuf;
    }
    break;
  }
  String *wname = make_wrapper_name(iname);

  /* Emit arguments */
  if (current != CONSTRUCTOR_NEW) {
    emit_args(t,l,f);
  }

  /* Calculate number of arguments */

  /* Attach standard typemaps */
  emit_attach_parmmaps(l,f);

  /* Get number of arguments */
  int numarg = emit_num_arguments(l);
  int numreq = emit_num_required(l);
  int start = (current == MEMBER_FUNC || current == MEMBER_VAR) ? 1 : 0;

  /* Generate wrapper safe for all argument list sizes */
  
  /* Now write the wrapper function itself */
  Printv(f->def, "static VALUE\n", wname, "(int argc, VALUE *argv, VALUE self) {", 0);

  if (current != CONSTRUCTOR_NEW) {
    Printf(f->code,"if ((argc < %d) || (argc > %d))\n", numreq-start, numarg-start);
    Printf(f->code,"rb_raise(rb_eArgError, \"wrong # of arguments(%%d for %d)\",argc);\n",numreq-start);
  }

  /* Now walk the function parameter list and generate code */
  /* to get arguments */
  if (current != CONSTRUCTOR_NEW) {
    marshalInputArgs(l, numarg, numreq, start, f);
  }

  /* Insert constraint checking code */
  insertConstraintCheckingCode(l, f);
  
  /* Insert cleanup code */
  insertCleanupCode(l, cleanup);

  /* Insert argument output code */
  insertArgOutputCode(l, outarg, need_result);

  /* Now write code to make the function call */
  if (current != CONSTRUCTOR_NEW) {
    emit_action(n, f);
  }

  int newobj = 0;
  if (NewObject || (Getattr(n,"feature:new"))) newobj = 1;

  /* Return value if necessary */
  if (SwigType_type(t) != T_VOID && current != CONSTRUCTOR_NEW && current != CONSTRUCTOR_INITIALIZE) {
    need_result = 1;
    if (predicate) {
      Printv(f->code, tab4, "vresult = (result ? Qtrue : Qfalse);\n", 0);
    } else {
      tm = Swig_typemap_lookup_new("out",n,"result",0);
      if (tm) {
        Replaceall(tm,"$result","vresult");
	Replaceall(tm,"$source","result");
	Replaceall(tm,"$target","vresult");
	Replaceall(tm,"$owner", newobj ? "1" : "0");
        Printv(f->code, tm, "\n", 0);
      } else {
	Printf(stderr,"%s : Line %d. No return typemap for datatype %s\n",
	       input_file,line_number,SwigType_str(t,0));
      }
    }
  }

  /* Extra code needed for new and initialize methods */  
  if (current == CONSTRUCTOR_NEW) {
    need_result = 1;
    Printf(f->code, "VALUE vresult = SWIG_NewClassInstance(self, SWIGTYPE%s);\n", Char(SwigType_manglestr(t)));
    Printf(f->code, "rb_obj_call_init(vresult, argc, argv);\n");
  } else if (current == CONSTRUCTOR_INITIALIZE) {
    need_result = 1;
    Printf(f->code, "DATA_PTR(self) = result;\n");
  }

  /* Dump argument output code; */
  Printv(f->code,outarg,0);

  /* Dump the argument cleanup code */
  Printv(f->code,cleanup,0);

  /* Look for any remaining cleanup.  This processes the %new directive */
  if (newobj) {
    tm = Swig_typemap_lookup_new("newfree",n,"result",0);
    if (tm) {
      Replaceall(tm,"$source","result");
      Printv(f->code,tm, "\n",0);
    }
  }

  /* free pragma */
  if (current == MEMBER_FUNC && Getattr(klass->freemethods, mname)) {
    Printv(f->code, tab4, "DATA_PTR(self) = 0;\n", 0);
  }

  /* Special processing on return value. */
  tm = Swig_typemap_lookup_new("ret",n,"result",0);
  if (tm) {
    Replaceall(tm,"$source","result");
    Printv(f->code,tm, 0);
  }

  /* Wrap things up (in a manner of speaking) */
  if (need_result) {
    if (current == CONSTRUCTOR_NEW) {
      Printv(f->code, tab4, "return vresult;\n}\n", 0);
    } else if (current == CONSTRUCTOR_INITIALIZE) {
      Printv(f->code, tab4, "return self;\n}\n", 0);
    } else {
      Wrapper_add_local(f,"vresult","VALUE vresult = Qnil");
      Printv(f->code, tab4, "return vresult;\n}\n", 0);
    }
  } else {
    Printv(f->code, tab4, "return Qnil;\n}\n", 0);
  }

  /* Substitute the cleanup code */
  Replace(f->code,"$cleanup",cleanup, DOH_REPLACE_ANY);

  /* Emit the function */
  Wrapper_print(f, f_wrappers);

  /* Now register the function with the language */
  create_command(name, iname, -1);
  Delete(cleanup);
  Delete(outarg);
  DelWrapper(f);
  
  /* Done */
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * RUBY::variableWrapper()
 * --------------------------------------------------------------------- */

int RUBY::variableWrapper(Node *n) {

  char *name  = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *t = Getattr(n,"type");
  String *tm;
  String *getfname, *setfname;
  Wrapper *getf, *setf;

  getf = NewWrapper();
  setf = NewWrapper();

  /* create getter */
  getfname = NewString(Swig_name_get(name));
  Printv(getf->def, "static VALUE\n", getfname, "(", 0);
  Printf(getf->def, "VALUE self");
  Printf(getf->def, ") {");
  Wrapper_add_local(getf,"_val","VALUE _val");

  tm = Swig_typemap_lookup_new("varout",n, name, 0);
  if (tm) {
    Replaceall(tm,"$result","_val");
    Replaceall(tm,"$target","_val");
    Replaceall(tm,"$source",name);
    Printv(getf->code,tm, 0);
  } else {
    Printf(stderr,"%s : Line %d. Unable to link with variable type %s\n",
	   input_file,line_number,SwigType_str(t,0));
  }
  Printv(getf->code, tab4, "return _val;\n}\n", 0);
  Wrapper_print(getf,f_wrappers);

  if (ReadOnly) {
    setfname = NewString("NULL");
  } else {
    /* create setter */
    setfname = NewString(Swig_name_set(name));
    Printv(setf->def, "static VALUE\n", setfname, "(VALUE self, ", 0);
    Printf(setf->def, "VALUE _val) {");
    
    tm = Swig_typemap_lookup_new("varin",n,name,0);
    if (tm) {
      Replaceall(tm,"$input","_val");
      Replaceall(tm,"$source","_val");
      Replaceall(tm,"$target",name);
      Printv(setf->code,tm,"\n",0);
    } else {
      Printf(stderr,"%s:%d.  Unable to link with variable type %s\n", input_file, line_number, SwigType_str(t,0));
    }
    Printv(setf->code, tab4, "return _val;\n",0);
    Printf(setf->code,"}\n");
    Wrapper_print(setf,f_wrappers);
  }

  /* define accessor method */
  if (CPlusPlus) {
    Insert(getfname,0,"VALUEFUNC(");
    Append(getfname,")");
    Insert(setfname,0,"VALUEFUNC(");
    Append(setfname,")");
  }

  String *s = NewString("");
  switch (current) {
  case STATIC_VAR:
    /* C++ class variable */
    Printv(s,
	   tab4, "rb_define_singleton_method(", klass->vname, ", \"",
	   klass->strip(iname), "\", ", getfname, ", 0);\n",
	   0);
    if (!ReadOnly) {
      Printv(s,
	     tab4, "rb_define_singleton_method(", klass->vname, ", \"",
	     klass->strip(iname), "=\", ", setfname, ", 1);\n",
	     0);
    }
    Printv(klass->init,s,0);
    break;
  default:
    /* C global variable */
    /* wrapped in Ruby module attribute */
    Printv(s,
	   tab4, "rb_define_singleton_method(", modvar, ", \"",
	   iname, "\", ", getfname, ", 0);\n",
	   0);
    if (!ReadOnly) {
      Printv(s,
	     tab4, "rb_define_singleton_method(", modvar, ", \"",
	     iname, "=\", ", setfname, ", 1);\n",
	     0);
    }
    Printv(f_init,s,0);
    Delete(s);
    break;
  }
  Delete(getfname);
  Delete(setfname);
  DelWrapper(setf);
  DelWrapper(getf);
  return SWIG_OK;
}


/* ---------------------------------------------------------------------
 * RUBY::validate_const_name(char *name)
 *
 * Validate constant name.
 * --------------------------------------------------------------------- */

char *RUBY::validate_const_name(char *name) {
  if (!name || name[0] == '\0')
    return name;

  if (isupper(name[0]))
    return name;

  if (islower(name[0])) {
    name[0] = toupper(name[0]);
    Printf(stderr,"%s : Line %d. Wrong constant/class/module name "
	    "(corrected to `%s')\n", input_file, line_number, name);
    return name;
  }

  Printf(stderr,"%s : Line %d. Wrong constant/class/module name\n",
	  input_file, line_number);
  return name;
}

/* ---------------------------------------------------------------------
 * RUBY::constantWrapper()
 * --------------------------------------------------------------------- */

int RUBY::constantWrapper(Node *n) {
  Swig_require(&n, "*sym:name", "type", "value", 0);

  char *iname     = GetChar(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  char  *value    = GetChar(n,"value");

  if (current == CLASS_CONST) {
    iname = klass->strip(iname);
  }
  SetChar(n, "sym:name", iname);

  String *tm = Swig_typemap_lookup_new("constant",n,value,0);
  if (tm) {
    Replaceall(tm,"$source",value);
    Replaceall(tm,"$target",iname);
    Replaceall(tm,"$symname",iname);
    Replaceall(tm,"$value",value);
    if (current == CLASS_CONST) {
      Replaceall(tm,"$module", klass->vname);
      Printv(klass->init, tm, "\n", 0);
    } else {
      Replaceall(tm,"$module", modvar);
      Printf(f_init,"%s\n", tm);
    }
  } else {
    Printf(stderr,"%s : Line %d. Unable to create constant %s = %s\n",
	   input_file, line_number, SwigType_str(type,0), value);
  }
  Swig_restore(&n);
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * RUBY::classHandler()
 * ---------------------------------------------------------------------- */

int RUBY::classHandler(Node *n) {

  char *cname = GetChar(n,"name");
  char *rename = GetChar(n,"sym:name");
  klass = RCLASS(classes, cname);

  /* !!! Added by beazley. 8/29/01 */
  if (!klass) {
    klass = new RClass();
    SET_RCLASS(classes,cname,klass);
  }
  String *valid_name = NewString(rename);
  validate_const_name(Char(valid_name));
  klass->set_name(cname,rename,Char(valid_name));

  Clear(klass->type);
  Printv(klass->type, Getattr(n,"classtype"), 0);
  Printv(klass->header, "\nswig_class c", valid_name, ";\n", 0);
  Printv(klass->init, "\n", tab4, 0);
  Printv(klass->init, klass->vname, " = rb_define_class_under(", modvar,
	 ", \"", klass->name, "\", $super);\n", 0);

  {
    SwigType *tt = NewString(klass->name);
    SwigType_add_pointer(tt);
    SwigType_remember(tt);
    Printf(klass->init, "SWIG_TypeClientData(SWIGTYPE%s, (void *) &c%s);\n", SwigType_manglestr(tt), valid_name);
    Delete(tt);
  }

  Replace(klass->includes,"$class", klass->vname, DOH_REPLACE_ANY);
  Printv(klass->init, klass->includes,0);
  Printv(klass->init, "$constructor",0);
  Printv(klass->init, "$initializer",0);

  Printv(klass->header,
	 "$freeproto",
	 0);

  Language::classHandler(n);

  /* Handle inheritance */
  List *baselist = Getattr(n,"bases");
  if (baselist && Len(baselist)) {
    Node *base = Firstitem(baselist);
    while (base) {
      RClass *super = RCLASS(classes, Getattr(base,"name"));
      if (super) {
        Printv(f_wrappers,"extern swig_class c", super->name, ";\n", 0);
	Replaceall(klass->init,"$super",super->vname);
	break;
      }
      base = Nextitem(baselist);
    }
  }

  /* Check to see if a %markfunc was specified */
  String *markfunc = Getattr(n, "feature:markfunc");
  if (markfunc) {
    Printf(klass->init, "c%s.mark = (void (*)(void *)) %s;\n", klass->name, markfunc);
  } else {
    Printf(klass->init, "c%s.mark = 0;\n", klass->name);
  }

  if (klass->destructor_defined) {
    Printf(klass->init, "c%s.destroy = (void (*)(void *)) free_%s;\n", klass->name, klass->cname);
  }
  Replace(klass->header,"$freeproto", "", DOH_REPLACE_ANY);

  Printv(f_header, klass->header,0);

  Replace(klass->aliases,"$class", klass->vname, DOH_REPLACE_ANY);
  Printv(klass->init, klass->aliases,0);

  String *s = NewString("");
  Printv(s, tab4, "rb_undef_method(CLASS_OF(", klass->vname,
	 "), \"new\");\n", 0);
  Replace(klass->init,"$constructor", s, DOH_REPLACE_ANY);
  Replace(klass->init,"$initializer", "", DOH_REPLACE_ANY);
  Replace(klass->init,"$super", "rb_cObject", DOH_REPLACE_ANY);

  Printv(f_init,klass->init,0);
  klass = 0;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * void RUBY::memberfunctionHandler()
 *
 * Method for adding C++ member function
 *
 * By default, we're going to create a function of the form :
 *
 *         Foo_bar(this,args)
 *
 * Where Foo is the classname, bar is the member name and the this pointer
 * is explicitly attached to the beginning.
 *
 * The renaming only applies to the member function part, not the full
 * classname.
 *
 * --------------------------------------------------------------------- */

int RUBY::memberfunctionHandler(Node *n) {
  current = MEMBER_FUNC;
  Language::memberfunctionHandler(n);
  current = NO_CPP;
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * void RUBY::constructorHandler()
 *
 * Method for adding C++ member constructor
 * -------------------------------------------------------------------- */

int RUBY::constructorHandler(Node *n) {
  if (!klass->constructor_defined) {
    /* First wrap the new singleton method */
    current = CONSTRUCTOR_NEW;
    Swig_name_register((String_or_char *) "construct", (String_or_char *) "new_%c");
    Language::constructorHandler(n);
    
    /* Now do the instance initialize method */
    current = CONSTRUCTOR_INITIALIZE;
    Swig_name_register((String_or_char *) "construct", (String_or_char *) "%c_initialize");
    Language::constructorHandler(n);
    
    /* Done */
    current = NO_CPP;
    klass->constructor_defined = 1;
  } else {
    char *symname = GetChar(n,"sym:name");
    fprintf(stderr, "Warning: Overloaded constructor \"%s\" ignored.\n", symname);
  }
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * RUBY::destructorHandler()
 * -------------------------------------------------------------------- */

int RUBY::destructorHandler(Node *n) {
  char *name = GetChar(n,"name");
  current = DESTRUCTOR;
  Language::destructorHandler(n);

  String *freefunc = NewString("");
  String *freeproto = NewString("");
  String *freebody = NewString("");
  
  Printv(freefunc, "free_", klass->cname, 0);
  Printv(freeproto, "static void ", freefunc, "(", klass->type, " *);\n", 0);
  Printv(freebody, "static void\n",
	 freefunc, "(", klass->type, " *", Swig_cparm_name(0,0), ") {\n",
  	 tab4, 0);
  if (AddMethods) {
    Printv(freebody, Swig_name_destroy(name), "(", Swig_cparm_name(0,0), ")", 0);
  } else {
    /* When no addmethods mode, swig emits no destroy function. */
    if (CPlusPlus)
      Printf(freebody, "delete %s", Swig_cparm_name(0,0));
    else
      Printf(freebody, "free((char*) %s)", Swig_cparm_name(0,0));
  }
  Printv(freebody, ";\n}\n", 0);
  
  Replace(klass->header,"$freeproto", freeproto, DOH_REPLACE_ANY);
  Printv(f_wrappers, freebody, 0);
  
  klass->destructor_defined = 1;
  current = NO_CPP;
  Delete(freefunc);
  Delete(freeproto);
  Delete(freebody);
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * void RUBY::membervariableHandler()
 *
 * This creates a pair of functions to set/get the variable of a member.
 * -------------------------------------------------------------------- */

int
RUBY::membervariableHandler(Node *n) {
  current = MEMBER_VAR;
  Language::membervariableHandler(n);
  current = NO_CPP;
  return SWIG_OK;
}

/* -----------------------------------------------------------------------
 * void RUBY::staticmemberfunctionHandler()
 *
 * Wrap a static C++ function
 * ---------------------------------------------------------------------- */

int RUBY::staticmemberfunctionHandler(Node *n) {
  current = STATIC_FUNC;
  Language::staticmemberfunctionHandler(n);
  current = NO_CPP;
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * void RUBY::memberconstantHandler()
 *
 * Create a C++ constant
 * --------------------------------------------------------------------- */


int RUBY::memberconstantHandler(Node *n) {

  current = CLASS_CONST;
  Language::memberconstantHandler(n);
  current = NO_CPP;
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * void RUBY::staticmembervariableHandler()
 * --------------------------------------------------------------------- */

int RUBY::staticmembervariableHandler(Node *n) {
  current = STATIC_VAR;
  Language::staticmembervariableHandler(n);
  current = NO_CPP;
  return SWIG_OK;
}

/* -----------------------------------------------------------------------
 * RUBY::classforwardDeclaration()
 *
 * A forward class declaration
 * ----------------------------------------------------------------------- */

int RUBY::classforwardDeclaration(Node *n) {
  char *cname  = GetChar(n,"name");
  char *rename = GetChar(n,"sym:name");
  char *type   = GetChar(n,"kind");

  RClass *kls;
  kls = RCLASS(classes,cname);
  if (!kls) {
    kls = new RClass();
    String *valid_name = NewString((rename ? rename : cname));
    validate_const_name(Char(valid_name));
    kls->set_name(cname, rename, Char(valid_name));
    SET_RCLASS(classes, cname, kls);
    Delete(valid_name);
  } 
  if (type && strlen(type) > 0) {
    char temp[256];
    sprintf(temp,"%s %s", type, cname);
    SET_RCLASS(classes,temp,kls);
  }
  return SWIG_OK;
}


/* --------------------------------------------------------------------
 * void RUBY::pragma(char *target, char *var, char *value)
 *
 * A pragma declaration
 * -------------------------------------------------------------------- */

void RUBY::pragma(char *lang, char *cmd, char *value) {
  if (strcmp(lang, "ruby") != 0)
    return;

  if (strcmp(cmd, "free") == 0) {
    char name[64];
    if (sscanf(value, " %s ", name) != 1) {
      Printf(stderr, "%s : Line %d. Invalid free pragma.\n",
	      input_file, line_number);
      return;
    }
    Setattr(klass->freemethods, name, name);
  } else if (strcmp(cmd, "include") == 0) {
    char name[64];
    if (sscanf(value, " %s ", name) != 1) {
      Printf(stderr, "%s : Line %d. Invalid include pragma.\n",
	      input_file, line_number);
      return;
    }
    Printv(klass->includes,tab4, "rb_include_module($class, ",
	   "rb_eval_string(\"", name, "\"));\n", 0);
  } else if (strcmp(cmd, "alias") == 0) {
    char alias[64], name[64];
    if (sscanf(value, " %s %s ", alias, name) != 2) {
      Printf(stderr, "%s : Line %d. Invalid alias pragma.\n",
	      input_file, line_number);
      return;
    }
    Printv(klass->aliases, tab4, "rb_define_alias($class, ",
	   "\"", alias, "\", \"", name, "\");\n", 0);
  } else if (strcmp(cmd, "pred") == 0) {
    char *tok;
    tok = strtok(value, " \t");
    while (tok) {
      Setattr(klass->predmethods, tok, tok);
      tok = strtok(0, " \t");
    }
  } else if (strcmp(cmd, "debug") == 0) {
    Printf(f_header, "/* %s */\n", value);
    Printf(f_wrappers, "/* %s */\n", value);
    Printf(f_init, "/* %s */\n", value);
    Printf(stderr, "%s\n", value);
  } else {
    Printf(stderr, "%s : Line %d. Unrecognized pragma.\n",
	    input_file, line_number);
  }
}

/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */

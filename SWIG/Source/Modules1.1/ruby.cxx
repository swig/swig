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
  String *mname;   /* Mangled name */
  String *vname;   /* variable name */
  String *type;
  String *prefix;
  String *header;
  String *init;

  int constructor_defined;
  int destructor_defined;

  RClass() {
    temp = NewString("");
    name = NewString("");
    cname = NewString("");
    mname = NewString("");
    vname = NewString("");
    type = NewString("");
    prefix = NewString("");
    header = NewString("");
    init = NewString("");
    constructor_defined = 0;
    destructor_defined = 0;
  }
  ~RClass() {
    Delete(name);
    Delete(cname);
    Delete(vname);
    Delete(mname);
    Delete(type);
    Delete(prefix);
    Delete(header);
    Delete(init);
    Delete(temp);
  }

  void set_name(char *cn, char *rn, char *valn) {
    Clear(cname);
    Append(cname,cn);
    Delete(mname);
    mname = Swig_name_mangle(cname);
    Clear(name);
    Append(name,valn);
    Clear(vname);
    Printf(vname,"c%s.klass",name);
    Clear(prefix);
    Printv(prefix,(rn ? rn : cn), "_", NULL);
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

void
RUBY::main(int argc, char *argv[]) {
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
  Preprocessor_define((void *) "SWIGRUBY 1", 0);

  /* Add typemap definitions */
  SWIG_typemap_lang("ruby");
  SWIG_config_file("ruby.swg");
}

/* ---------------------------------------------------------------------
 * RUBY::top()
 * --------------------------------------------------------------------- */

int
RUBY::top(Node *n) {

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

  modvar = 0;
  feature = 0;
  current = NO_CPP;
  klass = 0;
  classes = NewHash();
  special_methods = NewHash();

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

  /* Set module name */
  set_module(Char(Getattr(n,"name")));

  Printf(f_header,"#define SWIG_init    Init_%s\n", feature);
  Printf(f_header,"#define SWIG_name    \"%s\"\n\n", module);
  Printf(f_header,"static VALUE %s;\n", modvar);

  /* Start generating the initialization function */
  Printv(f_init,
	 "\n",
	 "#ifdef __cplusplus\n",
	 "extern \"C\"\n",
	 "#endif\n",
	 "void Init_", feature, "(void) {\n",
	 "int i;\n",
	 "\n",
	 NULL);

  Printv(f_init, tab4, "SWIG_InitRuntime();\n", NULL);
  
  Printv(f_init, tab4, modvar, " = rb_define_module(\"", module, "\");\n",
	 NULL);
  Printv(f_init,
	 "\n",
	 "for (i = 0; swig_types_initial[i]; i++) {\n",
	 "swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);\n",
	 "SWIG_define_class(swig_types[i]);\n",
	 "}\n",
	 NULL);
  Printf(f_init,"\n");

  Language::top(n);

  /* Finish off our init function */
  Printf(f_init,"}\n");
  SwigType_emit_type_table(f_runtime,f_wrappers);

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

/* -----------------------------------------------------------------------------
 * RUBY::importDirective()
 * ----------------------------------------------------------------------------- */

int
RUBY::importDirective(Node *n) {
  String *modname = Getattr(n,"module");
  if (modname) {
    Printf(f_init,"rb_require(\"%s\");\n", modname);
  }
  return Language::importDirective(n);
}

/* ---------------------------------------------------------------------
 * RUBY::set_module(const char *mod_name)
 *
 * Sets the module name.  Does nothing if it's already set (so it can
 * be overridden as a command line option).
 *---------------------------------------------------------------------- */


void
RUBY::set_module(const char *mod_name) {
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
  Swig_warning(WARN_LANG_NATIVE_UNIMPL, input_file, line_number, 
	       "Adding native function %s not supported (ignored).\n", funcname);
  return SWIG_NOWRAP;
}

/* ---------------------------------------------------------------------
 * RUBY::create_command(Node *n, char *iname)
 *
 * Creates a new command from a C function.
 *              iname = Name of function in scripting language
 * --------------------------------------------------------------------- */

void
RUBY::create_command(Node *n, char *iname) {

  String *wname = Swig_name_wrapper(iname);
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
  
  const char *alias = GetChar(n,"feature:alias");

  switch (current) {
  case MEMBER_FUNC:
    Printv(klass->init, tab4, "rb_define_method(", klass->vname, ", \"",
	   iname, "\", ", wname, ", -1);\n", NULL);
    if (alias) {
      Printv(klass->init, tab4, "rb_define_alias(", klass->vname, ", \"", alias, "\", \"", iname, "\");\n", NULL);
    }
    break;
  case CONSTRUCTOR_NEW:
    Printv(s, tab4, "rb_define_singleton_method(", klass->vname,
	   ", \"new\", ", wname, ", -1);\n", NULL);
    Replace(klass->init,"$constructor", s, DOH_REPLACE_ANY);
    break;
  case CONSTRUCTOR_INITIALIZE:
    Printv(s, tab4, "rb_define_method(", klass->vname,
	   ", \"initialize\", ", wname, ", -1);\n", NULL);
    Replace(klass->init,"$initializer", s, DOH_REPLACE_ANY);
    break;
  case MEMBER_VAR:
    Append(temp,iname);
    Replace(temp,"_set", "=", DOH_REPLACE_ANY);
    Replace(temp,"_get", "", DOH_REPLACE_ANY);
    Printv(klass->init, tab4, "rb_define_method(", klass->vname, ", \"",
	   temp, "\", ", wname, ", -1);\n", NULL);
    break;
  case STATIC_FUNC:
    Printv(klass->init, tab4, "rb_define_singleton_method(", klass->vname,
	   ", \"", iname, "\", ", wname, ", -1);\n", NULL);
    break;
  default:
    Printv(s, tab4, "rb_define_module_function(", modvar, ", \"",
	   iname, "\", ", wname, ", -1);\n",NULL);
    Printv(f_init,s,NULL);
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

void
RUBY::marshalInputArgs(ParmList *l, int numarg, int numreq, int start, Wrapper *f) {
  int i;
  Parm *p;
  String *tm;
  char source[256], target[256];
  
  int use_self = (current == MEMBER_FUNC || current == MEMBER_VAR) ? 1 : 0;
  int varargs = emit_isvarargs(l);

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
      Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number,
		   "Unable to use type %s as a function argument.\n", SwigType_str(pt,0));
      p = nextSibling(p);
    }
    if (i >= numreq) {
      Printf(f->code,"}\n");
    }
  }
  /* Trailing varargs */
  if (varargs) {
    if (p && (tm = Getattr(p,"tmap:in"))) {
      sprintf(source,"argv[%d]",i-start);
      Replaceall(tm,"$input",source);
      Setattr(p,"emit:input",source);
      Printf(f->code,"if (argc > %d) {\n", i-start);
      Printv(f->code,tm,"\n",NULL);
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

void
RUBY::insertConstraintCheckingCode(ParmList *l, Wrapper *f) {
  Parm *p;
  String *tm;
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:check"))) {
      Replace(tm,"$target",Getattr(p,"lname"),DOH_REPLACE_ANY);
      Printv(f->code,tm,"\n",NULL);
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

void
RUBY::insertCleanupCode(ParmList *l, String *cleanup) {
  String *tm;
  for (Parm *p = l; p; ) {
    if ((tm = Getattr(p,"tmap:freearg"))) {
      Replace(tm,"$source",Getattr(p,"lname"),DOH_REPLACE_ANY);
      Printv(cleanup,tm,"\n",NULL);
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

void
RUBY::insertArgOutputCode(ParmList *l, String *outarg, int& need_result) {
  String *tm;
  for (Parm *p = l; p; ) {
    if ((tm = Getattr(p,"tmap:argout"))) {
      Replace(tm,"$source",Getattr(p,"lname"),DOH_REPLACE_ANY);
      Replace(tm,"$target","vresult",DOH_REPLACE_ANY);
      Replace(tm,"$result","vresult",DOH_REPLACE_ANY);
      Replace(tm,"$arg",Getattr(p,"emit:input"), DOH_REPLACE_ANY);
      Replace(tm,"$input",Getattr(p,"emit:input"), DOH_REPLACE_ANY);
      Printv(outarg,tm,"\n",NULL);
      need_result = 1;
      p = Getattr(p,"tmap:argout:next");
    } else {
      p = nextSibling(p);
    }
  }
}

/* ---------------------------------------------------------------------
 * RUBY::validIdentifier()
 *
 * Is this a valid identifier in the scripting language?
 * Ruby method names can include any combination of letters, numbers
 * and underscores. A Ruby method name may optionally end with
 * a question mark ("?"), exclamation point ("!") or equals sign ("=").
 *
 * Methods whose names end with question marks are, by convention,
 * predicate methods that return true or false (e.g. Array#empty?).
 *
 * Methods whose names end with exclamation points are, by convention,
 * "mutators" that modify the instance in place (e.g. Array#sort!).
 *
 * Methods whose names end with an equals sign are attribute setters
 * (e.g. Thread#critical=).
 * --------------------------------------------------------------------- */

int
RUBY::validIdentifier(String *s) {
  char *c = Char(s);
  while (*c) {
    if ( !( isalnum(*c) || (*c == '_') || (*c == '?') || (*c == '!') || (*c == '=') ) ) return 0;
    c++;
  }
  return 1;
}

/* ---------------------------------------------------------------------
 * RUBY::functionWrapper()
 *
 * Create a function declaration and register it with the interpreter.
 * --------------------------------------------------------------------- */

int
RUBY::functionWrapper(Node *n) {
  char *iname = GetChar(n,"sym:name");
  SwigType *t = Getattr(n,"type");
  ParmList *l = Getattr(n,"parms");
  String *tm;
  String *cleanup, *outarg;
  Wrapper *f;

  char mname[256], inamebuf[256];
  int need_result = 0;

  /* Ruby needs no destructor wrapper */
  if (current == DESTRUCTOR)
      return SWIG_NOWRAP;

  cleanup = NewString("");
  outarg = NewString("");
  f = NewWrapper();

  switch (current) {
  case MEMBER_FUNC:
  case MEMBER_VAR:
  case STATIC_FUNC:
    strcpy(mname, klass->strip(iname));
    break;
  }
  
  // Rename predicate methods
  if (Getattr(n, "feature:predicate")) {
    sprintf(inamebuf,"%s?",iname);
    iname = inamebuf;
  }

  String *wname = Swig_name_wrapper(iname);
  
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
  int varargs = emit_isvarargs(l);

  int start = (current == MEMBER_FUNC || current == MEMBER_VAR) ? 1 : 0;

  /* Generate wrapper safe for all argument list sizes */
  
  /* Now write the wrapper function itself */
  Printv(f->def, "static VALUE\n", wname, "(int argc, VALUE *argv, VALUE self) {", NULL);

  if (current != CONSTRUCTOR_NEW) {
    if (!varargs) {
      Printf(f->code,"if ((argc < %d) || (argc > %d))\n", numreq-start, numarg-start);
    } else {
      Printf(f->code,"if (argc < %d)\n", numreq-start);
    }
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
    if (Getattr(n, "feature:predicate")) {
      Printv(f->code, tab4, "vresult = (result ? Qtrue : Qfalse);\n", NULL);
    } else {
      tm = Swig_typemap_lookup_new("out",n,"result",0);
      if (tm) {
        Replaceall(tm,"$result","vresult");
	Replaceall(tm,"$source","result");
	Replaceall(tm,"$target","vresult");
	Replaceall(tm,"$owner", newobj ? "1" : "0");
        Printv(f->code, tm, "\n", NULL);
      } else {
	Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
		     "Unable to use return type %s.\n", SwigType_str(t,0));
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
  Printv(f->code,outarg,NULL);

  /* Dump the argument cleanup code */
  if (current != CONSTRUCTOR_NEW)
    Printv(f->code,cleanup,NULL);

  /* Look for any remaining cleanup.  This processes the %new directive */
  if (newobj) {
    tm = Swig_typemap_lookup_new("newfree",n,"result",0);
    if (tm) {
      Replaceall(tm,"$source","result");
      Printv(f->code,tm, "\n",NULL);
    }
  }

  /* Special processing on return value. */
  tm = Swig_typemap_lookup_new("ret",n,"result",0);
  if (tm) {
    Replaceall(tm,"$source","result");
    Printv(f->code,tm, NULL);
  }

  /* Wrap things up (in a manner of speaking) */
  if (need_result) {
    if (current == CONSTRUCTOR_NEW) {
      Printv(f->code, tab4, "return vresult;\n}\n", NULL);
    } else if (current == CONSTRUCTOR_INITIALIZE) {
      Printv(f->code, tab4, "return self;\n}\n", NULL);
    } else {
      Wrapper_add_local(f,"vresult","VALUE vresult = Qnil");
      Printv(f->code, tab4, "return vresult;\n}\n", NULL);
    }
  } else {
    Printv(f->code, tab4, "return Qnil;\n}\n", NULL);
  }

  /* Substitute the cleanup code */
  Replace(f->code,"$cleanup",cleanup, DOH_REPLACE_ANY);

  /* Emit the function */
  Wrapper_print(f, f_wrappers);

  /* Now register the function with the language */
  create_command(n, iname);
  Delete(cleanup);
  Delete(outarg);
  DelWrapper(f);
  
  /* Done */
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * RUBY::variableWrapper()
 * --------------------------------------------------------------------- */

int
RUBY::variableWrapper(Node *n) {

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
  Printv(getf->def, "static VALUE\n", getfname, "(", NULL);
  Printf(getf->def, "VALUE self");
  Printf(getf->def, ") {");
  Wrapper_add_local(getf,"_val","VALUE _val");

  tm = Swig_typemap_lookup_new("varout",n, name, 0);
  if (tm) {
    Replaceall(tm,"$result","_val");
    Replaceall(tm,"$target","_val");
    Replaceall(tm,"$source",name);
    Printv(getf->code,tm, NULL);
  } else {
    Swig_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number,
		 "Unable to read variable of type %s\n", SwigType_str(t,0));
  }
  Printv(getf->code, tab4, "return _val;\n}\n", NULL);
  Wrapper_print(getf,f_wrappers);

  if (Getattr(n,"feature:immutable")) {
    setfname = NewString("NULL");
  } else {
    /* create setter */
    setfname = NewString(Swig_name_set(name));
    Printv(setf->def, "static VALUE\n", setfname, "(VALUE self, ", NULL);
    Printf(setf->def, "VALUE _val) {");
    
    tm = Swig_typemap_lookup_new("varin",n,name,0);
    if (tm) {
      Replaceall(tm,"$input","_val");
      Replaceall(tm,"$source","_val");
      Replaceall(tm,"$target",name);
      Printv(setf->code,tm,"\n",NULL);
    } else {
      Swig_warning(WARN_TYPEMAP_VARIN_UNDEF, input_file, line_number,
		 "Unable to set variable of type %s\n", SwigType_str(t,0));
    }
    Printv(setf->code, tab4, "return _val;\n",NULL);
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
	   NULL);
    if (!Getattr(n,"feature:immutable")) {
      Printv(s,
	     tab4, "rb_define_singleton_method(", klass->vname, ", \"",
	     klass->strip(iname), "=\", ", setfname, ", 1);\n",
	     NULL);
    }
    Printv(klass->init,s,NULL);
    break;
  default:
    /* C global variable */
    /* wrapped in Ruby module attribute */
    Printv(s,
	   tab4, "rb_define_singleton_method(", modvar, ", \"",
	   iname, "\", ", getfname, ", 0);\n",
	   NULL);
    if (!Getattr(n,"feature:immutable")) {
      Printv(s,
	     tab4, "rb_define_singleton_method(", modvar, ", \"",
	     iname, "=\", ", setfname, ", 1);\n",
	     NULL);
    }
    Printv(f_init,s,NULL);
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

char *
RUBY::validate_const_name(char *name, const char *reason) {
  if (!name || name[0] == '\0')
    return name;

  if (isupper(name[0]))
    return name;

  if (islower(name[0])) {
    name[0] = toupper(name[0]);
    Swig_warning(WARN_RUBY_WRONG_NAME, input_file, line_number,
		 "Wrong %s name (corrected to `%s')\n", reason, name);
    return name;
  }

  Swig_warning(WARN_RUBY_WRONG_NAME, input_file, line_number,
	       "Wrong %s name\n", reason);

  return name;
}

/* ---------------------------------------------------------------------
 * RUBY::constantWrapper()
 * --------------------------------------------------------------------- */

int
RUBY::constantWrapper(Node *n) {
  Swig_require(&n, "*sym:name", "type", "value", NULL);
  
  char *iname     = GetChar(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  char *value     = GetChar(n,"value");

  if (current == CLASS_CONST) {
    iname = klass->strip(iname);
  }
  validate_const_name(iname, "constant");
  SetChar(n, "sym:name", iname);

  /* Special hook for member pointer */
  if (SwigType_type(type) == T_MPOINTER) {
    String *wname = Swig_name_wrapper(iname);
    Printf(f_header, "static %s = %s;\n", SwigType_str(type, wname), value);
    value = Char(wname);
  }
  String *tm = Swig_typemap_lookup_new("constant", n, value, 0);
  if (tm) {
    Replaceall(tm, "$source", value);
    Replaceall(tm, "$target", iname);
    Replaceall(tm, "$symname", iname);
    Replaceall(tm, "$value", value);
    if (current == CLASS_CONST) {
      Replaceall(tm, "$module", klass->vname);
      Printv(klass->init, tm, "\n", NULL);
    } else {
      Replaceall(tm,"$module", modvar);
      Printf(f_init, "%s\n", tm);
    }
  } else {
    Swig_warning(WARN_TYPEMAP_CONST_UNDEF, input_file, line_number,
		 "Unsupported constant value %s = %s\n", SwigType_str(type, 0), value);
  }
  Swig_restore(&n);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * RUBY::classDeclaration() 
 *
 * Records information about classes---even classes that might be defined in
 * other modules referenced by %import.
 * ----------------------------------------------------------------------------- */

int
RUBY::classDeclaration(Node *n) {
  char *cname = GetChar(n,"name");
  char *rename = GetChar(n,"sym:name");
  char *tdname = GetChar(n,"tdname");
  
  cname = tdname ? tdname : cname;

  if (SwigType_istemplate(cname)) {
    cname = Char(SwigType_namestr(cname));
  }
  klass = RCLASS(classes, cname);
  if (!klass) {
    klass = new RClass();
    String *valid_name = NewString((rename ? rename : cname));
    validate_const_name(Char(valid_name), "class");
    klass->set_name(cname, rename, Char(valid_name));
    SET_RCLASS(classes, cname, klass);
    Delete(valid_name);
  }
  return Language::classDeclaration(n);
}

/* ----------------------------------------------------------------------
 * RUBY::classHandler()
 * ---------------------------------------------------------------------- */

int
RUBY::classHandler(Node *n) {

  char *cname = GetChar(n,"name");
  char *rename = GetChar(n,"sym:name");
  
  if (SwigType_istemplate(cname)) {
    cname = Char(SwigType_namestr(cname));
  }

  klass = RCLASS(classes, cname);
  assert(klass);
  String *valid_name = NewString(rename);
  validate_const_name(Char(valid_name), "class");

  Clear(klass->type);
  Printv(klass->type, Getattr(n,"classtype"), NULL);
  Printv(klass->header, "\nswig_class c", valid_name, ";\n", NULL);
  Printv(klass->init, "\n", tab4, NULL);
  Printv(klass->init, klass->vname, " = rb_define_class_under(", modvar,
	 ", \"", klass->name, "\", $super);\n", NULL);

  {
    SwigType *tt = NewString(cname);
    SwigType_add_pointer(tt);
    SwigType_remember(tt);
    String *tm = SwigType_manglestr(tt);
    Printf(klass->init, "SWIG_TypeClientData(SWIGTYPE%s, (void *) &c%s);\n", tm, valid_name);
    Delete(tm);
    Delete(tt);    
  }

  Printv(klass->init, "$constructor",NULL);
  Printv(klass->init, "$initializer",NULL);

  Printv(klass->header,
	 "$freeproto",
	 NULL);

  Language::classHandler(n);

  /* Handle inheritance */
  List *baselist = Getattr(n,"bases");
  if (baselist && Len(baselist)) {
    Node *base = Firstitem(baselist);
    while (base) {
      char *basename = Char(Getattr(base,"name"));
      if (SwigType_istemplate(basename)) {
        basename = Char(SwigType_namestr(basename));
      }
      RClass *super = RCLASS(classes, basename);
      if (super) {

	/* [DB] This code is experimental.   Rather than creating a link-dependency to the
           base class, you can actually obtain the base class through the SWIG run-time 
           type checker.  This is because proxy classes register a data structure using
           SWIG_TypeClientdata().  
          
           Caveat: This only works if base classes are defined before derived classes.
           Unlikely to be a problem since I don't think the Ruby module would work
           otherwise.

        */

	SwigType *btype = NewString(basename);
	SwigType_add_pointer(btype);
	SwigType_remember(btype);
	String   *bmangle = SwigType_manglestr(btype);
	Insert(bmangle,0,"((swig_class *) SWIGTYPE");
	Append(bmangle,"->clientdata)->klass");
	Replaceall(klass->init,"$super", bmangle);
	Delete(btype);
	Delete(bmangle);

	/* [DB] Old code 
        Printv(f_wrappers,"extern swig_class c", super->name, ";\n", NULL);
	Replaceall(klass->init,"$super",super->vname);
	*/

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

  String *freefunc = Getattr(n, "feature:freefunc");
  if (freefunc) {
    Printf(klass->init, "c%s.destroy = (void (*)(void *)) %s;\n", klass->name, freefunc);
  } else {
    if (klass->destructor_defined) {
      Printf(klass->init, "c%s.destroy = (void (*)(void *)) free_%s;\n", klass->name, klass->mname);
    }
  }
  Replace(klass->header,"$freeproto", "", DOH_REPLACE_ANY);

  Printv(f_header, klass->header,NULL);

  String *s = NewString("");
  Printv(s, tab4, "rb_undef_method(CLASS_OF(", klass->vname,
	 "), \"new\");\n", NULL);
  Replace(klass->init,"$constructor", s, DOH_REPLACE_ANY);
  Replace(klass->init,"$initializer", "", DOH_REPLACE_ANY);
  Replace(klass->init,"$super", "rb_cObject", DOH_REPLACE_ANY);

  Printv(f_init,klass->init,NULL);
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

int
RUBY::memberfunctionHandler(Node *n) {
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

int
RUBY::constructorHandler(Node *n) {
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
    Swig_name_unregister((String_or_char *) "construct");
    current = NO_CPP;
    klass->constructor_defined = 1;
  } else {
    Swig_require(&n,"?name","*sym:name","?type","?parms",NULL);
    String *classname = Getattr(n,"name");
    String *symname = Getattr(n,"sym:name");
    String *mrename = Swig_name_member(classname, symname);
    Setattr(n, "sym:name", mrename);
    Swig_ConstructorToFunction(n, classname, CPlusPlus, Extend);
    current = STATIC_FUNC;
    functionWrapper(n);
    current = NO_CPP;
    Swig_restore(&n);
  }
  return SWIG_OK;
}

/* ----------------------------------------------------------------------
 * RUBY::copyconstructorHandler()
 * ---------------------------------------------------------------------- */

int
RUBY::copyconstructorHandler(Node *n) {
  Swig_require(&n,"?name","*sym:name","?type","?parms", NULL);
  
  String *classname = Getattr(n, "name");
  String *symname = Getattr(n, "sym:name");
  Swig_name_register((String_or_char *) "construct", (String_or_char *) "%c_clone");
  String *mrename = Swig_name_copyconstructor(symname);
  Swig_name_unregister((String_or_char *) "construct");

  Setattr(n, "sym:name", mrename);
  Swig_ConstructorToFunction(n, classname, CPlusPlus, Extend);
  current = MEMBER_FUNC;
  functionWrapper(n);
  current = NO_CPP;
  Delete(mrename);
  
  Swig_restore(&n);
  
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * RUBY::destructorHandler()
 * -------------------------------------------------------------------- */

int
RUBY::destructorHandler(Node *n) {
  char *name = GetChar(n,"name");
  current = DESTRUCTOR;
  Language::destructorHandler(n);

  String *freefunc = NewString("");
  String *freeproto = NewString("");
  String *freebody = NewString("");
  
  Printv(freefunc, "free_", klass->mname, NULL);
  Printv(freeproto, "static void ", freefunc, "(", klass->type, " *);\n", NULL);
  Printv(freebody, "static void\n",
	 freefunc, "(", klass->type, " *", Swig_cparm_name(0,0), ") {\n",
  	 tab4, NULL);
  if (Extend) {
    String *wrap = Getattr(n, "wrap:code");
    if (wrap) {
      File *f_code = Swig_filebyname("header");
      if (f_code) {
        Printv(f_code, wrap, NULL);
      }
    }
    /*    Printv(freebody, Swig_name_destroy(name), "(", Swig_cparm_name(0,0), ")", NULL); */
    Printv(freebody,Getattr(n,"wrap:action"), NULL);
  } else {
    /* When no extend mode, swig emits no destroy function. */
    if (CPlusPlus)
      Printf(freebody, "delete %s", Swig_cparm_name(0,0));
    else
      Printf(freebody, "free((char*) %s)", Swig_cparm_name(0,0));
  }
  Printv(freebody, ";\n}\n", NULL);
  
  Replace(klass->header,"$freeproto", freeproto, DOH_REPLACE_ANY);
  Printv(f_wrappers, freebody, NULL);
  
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

int
RUBY::staticmemberfunctionHandler(Node *n) {
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


int
RUBY::memberconstantHandler(Node *n) {
  current = CLASS_CONST;
  Language::memberconstantHandler(n);
  current = NO_CPP;
  return SWIG_OK;
}

/* ---------------------------------------------------------------------
 * void RUBY::staticmembervariableHandler()
 * --------------------------------------------------------------------- */

int
RUBY::staticmembervariableHandler(Node *n) {
  current = STATIC_VAR;
  Language::staticmembervariableHandler(n);
  current = NO_CPP;
  return SWIG_OK;
}


/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */

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

#include <ctype.h>
#include <string.h>

/* for debug */
#define P(obj) printf("\"%s\"\n", Char(Str(obj)))

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
  int destructor_defined;

  RClass(void) {
    freemethods = NewHash();
    predmethods = NewHash();
    destructor_defined = 0;
    name = NewString("");
    cname = NewString("");
    vname = NewString("");
    type = NewString("");
    prefix = NewString("");
    header = NewString("");
    init = NewString("");
    aliases = NewString("");
    includes = NewString("");
    temp = NewString("");
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
    Printf(vname,"c%s",name);
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
     -module name    - Set module name\n\
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
  CONSTRUCTOR,
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
 * RUBY::parse_args(int argc, char *argv[])
 *
 * Parse command line options and initializes variables.
 * --------------------------------------------------------------------- */

void RUBY::parse_args(int argc, char *argv[]) {
  /* Look for certain command line options */
  for (int i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i],"-module") == 0) {
	if (argv[i+1]) {
	  set_module(argv[i+1]);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i+1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i],"-feature") == 0) {
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
      }
    }
  }
  /* Set location of SWIG library */
  strcpy(LibDir,"ruby");

  /* Add a symbol to the parser for conditional compilation */
  Preprocessor_define((void *) "SWIGRUBY", 0);

  /* Add typemap definitions */
  typemap_lang = (char*)"ruby";

  SWIG_config_file("ruby.i");
}


static void insert_file(char *filename, File *file) {
  if (Swig_insert_file(filename, file) == -1) {
    Printf(stderr,
	    "SWIG : Fatal error. "
	    "Unable to locate %s. (Possible installation problem).\n",
	    filename);
    SWIG_exit (EXIT_FAILURE);
  }
}

/* ---------------------------------------------------------------------
 * RUBY::parse()
 *
 * Start parsing an interface file.
 * --------------------------------------------------------------------- */

void RUBY::parse() {
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
  /* Numeric */
  Setattr(special_methods, "__add__", "+");
  Setattr(special_methods, "__sub__", "-");
  Setattr(special_methods, "__mul__", "*");
  Setattr(special_methods, "__div__", "/");
  Setattr(special_methods, "__mod__", "%");
  Setattr(special_methods, "__divmod__", "divmod");
  Setattr(special_methods, "__pow__", "**");
  Setattr(special_methods, "__lshift__", "<<");
  Setattr(special_methods, "__rshift__", ">>");
  Setattr(special_methods, "__and__", "&");
  Setattr(special_methods, "__xor__", "^");
  Setattr(special_methods, "__or__", "|");
  Setattr(special_methods, "__neg__", "-@");
  Setattr(special_methods, "__pos__", "+@");
  Setattr(special_methods, "__abs__", "abs");
  Setattr(special_methods, "__invert__", "~");
  Setattr(special_methods, "__int__", "to_i");
  Setattr(special_methods, "__float__", "to_f");
  Setattr(special_methods, "__coerce__", "coerce");

  Swig_banner(f_header);

  Printf(f_header,"/* Implementation : RUBY */\n\n");
  Printf(f_header,"#define SWIGRUBY\n");

  insert_file((char*)"common.swg", f_header);
  insert_file((char*)"ruby.swg", f_header);
  if (NoInclude) {
    insert_file((char*)"rubydec.swg", f_header);
  } else {
    insert_file((char*)"rubydef.swg", f_header);
  }

  /* typedef void *VALUE */
  SwigType *value = NewSwigType(T_VOID);
  SwigType_setbase(value,(char*)"void");
  SwigType_add_pointer(value);
  SwigType_typedef(value,(char*)"VALUE");

  yyparse();       /* Run the SWIG parser */
  Delete(value);
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


/* ---------------------------------------------------------------------
 * RUBY::initialize(void)
 *
 * Produces an initialization function.   Assumes that the module
 * name has already been specified.
 * --------------------------------------------------------------------- */

void RUBY::initialize() {
  if (!module) {
    Printf(stderr,"SWIG : *** Warning. No module name specified.\n");
    set_module((char*)"swig");         /* Pick a default name */
  }

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

  Printv(f_init, tab4, modvar, " = rb_define_module(\"", module, "\");\n",
	 "_mSWIG = rb_define_module_under(", modvar, ", \"SWIG\");\n",
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
}

/* ---------------------------------------------------------------------
 * RUBY::close(void)
 *
 * Finish the initialization function. Close any additional files and
 * resources in use.
 * --------------------------------------------------------------------- */

void RUBY::close(void) {
  /* Finish off our init function */
  Printf(f_init,"}\n");
  SwigType_emit_type_table(f_header,f_wrappers);
}

/* --------------------------------------------------------------------------
 * RUBY::add_native()
 * -------------------------------------------------------------------------- */
void
RUBY::add_native(char *name, char *funcname, SwigType *, ParmList *) {
  Printf(stderr,"%s : Line %d.  Adding native function %s not supported (ignored).\n", input_file, line_number, funcname);
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
  case CONSTRUCTOR:
    Printv(s, tab4, "rb_define_singleton_method(", klass->vname,
	   ", \"new\", ", wname,  ", ", argcs, ");\n", 0);
    Replace(klass->init,"$constructor", s, DOH_REPLACE_ANY);
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
 * RUBY::create_function(char *name, char *iname, SwigType *d, ParmList *l)
 *
 * Create a function declaration and register it with the interpreter.
 *              name = Name of real C function
 *              iname = Name of function in scripting language
 *              t = Return datatype
 *              l = Function parameters
 * --------------------------------------------------------------------- */

void RUBY::create_function(char *name, char *iname, SwigType *t, ParmList *l) {
  char source[256], target[256];
  char *tm;
  String *cleanup, *outarg;
  Wrapper *f;
  int i;

  /* Ruby needs no destructor wrapper */
  if (current == DESTRUCTOR)
    return;

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

  /* Get number of arguments */
  int numarg = ParmList_numarg(l);
  int numopt = check_numopt(l);

  int start = 0;
  int use_self = 0;
  switch (current) {
  case MEMBER_FUNC:
  case MEMBER_VAR:
    numarg--;
    start++;
    use_self = 1;
    break;
  }

  int numreq = 0;
  int numoptreal = 0;
  Parm *p = l;
  for (i = 0; i < start; i++) p = Getnext(p);
  for (i = start; p; i++, p = Getnext(p)) {
    if (!Getignore(p)) {
      if (i >= ParmList_len(l) - numopt) numoptreal++;
      else numreq++;
    }
  }
  int vararg = (numoptreal != 0);

  /* Now write the wrapper function itself */
  Printv(f->def, "static VALUE\n", wname, "(", 0);
  if (vararg) {
    Printv(f->def, "int argc, VALUE *argv, VALUE self",0);
  } else {
    Printv(f->def, "VALUE self", 0);
    p = l;
    for (i = 0; i < start; i++) p = Getnext(p);
    for (i = start; p; i++, p = Getnext(p)) {
      if (!Getignore(p)) {
	Printf(f->def,", VALUE varg%d", i);
      }
    }
  }
  Printf(f->def,") {");

  /* Emit all of the local variables for holding arguments. */
  if (vararg) {
    p = l;
    for (i = 0; i < start; i++) p = Getnext(p);
    for (i = start; p; i++, p = Getnext(p)) {
      if (!Getignore(p)) {
	char s[256];
	sprintf(s,"varg%d",i);
	Wrapper_add_localv(f,s,"VALUE",s,0);
      }
    }
  }
  int pcount = emit_args(t,l,f);

  /* Emit count to check the number of arguments */
  if (vararg) {
    int numscan = 0;
    for (p = l, i = 0; i < start; i++) p = Getnext(p);
    for (i = start; p; i++, p = Getnext(p)) {
      if (!Getignore(p)) numscan++;
    }
    Printf(f->code,"rb_scan_args(argc, argv, \"%d%d\"", (numarg-numoptreal), numscan - (numarg-numoptreal));
    for (p = l, i = 0; i < start; i++) p = Getnext(p);
    for (i = start; p; i++, p = Getnext(p)) {
      if (!Getignore(p)) {
	Printf(f->code,", &varg%d", i);
      }
    }
    Printf(f->code,");\n");
  }

  /* Now walk the function parameter list and generate code */
  /* to get arguments */
  int j = 0;                /* Total number of non-optional arguments */

  p = l;
  for (i = 0; i < pcount ; i++, p = Getnext(p)) {
    SwigType *pt = Gettype(p);
    String   *pn = Getname(p);

    /* Produce string representation of source and target arguments */
    int selfp = (use_self && i == 0);
    if (selfp)
      strcpy(source,"self");
    else
      sprintf(source,"varg%d",i);

    sprintf(target,"%s", Char(Getlname(p)));

    if (!Getignore(p)) {
      char *tab = (char*)tab4;
      if (j >= (pcount-numopt)) { /* Check if parsing an optional argument */
	Printf(f->code,"    if (argc > %d) {\n", j -  start);
	tab = (char*)tab8;
      }

      /* Get typemap for this argument */
      tm = ruby_typemap_lookup((char*)"in",pt,pn,source,target,f);
      if (tm) {
	String *s = NewString(tm);
	Printv(f->code, s, 0);
	Replace(f->code, "$arg", source, DOH_REPLACE_ANY);
	Delete(s);
      } else {
	Printf(stderr,"%s : Line %d. No typemapping for datatype %s\n",
		input_file,line_number, SwigType_str(pt,0));
      }
      if (j >= (pcount-numopt))
	Printv(f->code, tab4, "} \n", 0);
      j++;
    }

    /* Check to see if there was any sort of a constaint typemap */
    tm = ruby_typemap_lookup((char*)"check",pt,pn,source,target);
    if (tm) {
      String *s = NewString(tm);
      Printv(f->code, s, 0);
      Replace(f->code, "$arg", source, DOH_REPLACE_ANY);
      Delete(s);
    }

    /* Check if there was any cleanup code (save it for later) */
    tm = ruby_typemap_lookup((char*)"freearg",pt,pn,target,source);
    if (tm) {
      String *s = NewString(tm);
      Printv(cleanup,s,0);
      Replace(cleanup,"$arg",source, DOH_REPLACE_ANY);
      Delete(s);
    }

    tm = ruby_typemap_lookup((char*)"argout",pt,pn,target,(char*)"vresult");
    if (tm) {
      String *s = NewString(tm);
      need_result = 1;
      Printv(outarg, s, 0);
      Replace(outarg, "$arg", source, DOH_REPLACE_ANY);
      Delete(s);
    }
  }

  /* Now write code to make the function call */
  emit_func_call(name,t,l,f);


  /* Return value if necessary */
  if (SwigType_type(t) != T_VOID) {
    need_result = 1;
    if (predicate) {
      Printv(f->code, tab4, "vresult = (result ? Qtrue : Qfalse);\n", 0);
    } else {
      tm = ruby_typemap_lookup((char*)"out",t,name,(char*)"result",(char*)"vresult");
      if (tm) {
	String *s = NewString(tm);
	Printv(f->code, s, 0);
	Delete(s);
      } else {
	Printf(stderr,"%s : Line %d. No return typemap for datatype %s\n",
		input_file,line_number,SwigType_str(t,0));
      }
    }
  }

  /* Dump argument output code; */
  Printv(f->code,outarg,0);

  /* Dump the argument cleanup code */
  Printv(f->code,cleanup,0);

  /* Look for any remaining cleanup.  This processes the %new directive */
  if (NewObject) {
    tm = ruby_typemap_lookup((char*)"newfree",t,name,(char*)"result",(char*)"");
    if (tm) {
      String *s = NewString(tm);
      Printv(f->code,s, 0);
      Delete(s);
    }
  }

  /* free pragma */
  if (current == MEMBER_FUNC && Getattr(klass->freemethods, mname)) {
    Printv(f->code, tab4, "DATA_PTR(self) = 0;\n", 0);
  }

  /* Special processing on return value. */
  tm = ruby_typemap_lookup((char*)"ret",t,name,(char*)"result",(char*)"");
  if (tm) {
    String *s = NewString(tm);
    Printv(f->code,s, 0);
  }

  /* Wrap things up (in a manner of speaking) */
  if (need_result) {
    Wrapper_add_local(f,"vresult","VALUE vresult = Qnil");
    Printv(f->code, tab4, "return vresult;\n}\n", 0);
  } else {
    Printv(f->code, tab4, "return Qnil;\n}\n", 0);
  }

  /* Substitute the cleanup code */
  Replace(f->code,"$cleanup",cleanup, DOH_REPLACE_ANY);

  /* Emit the function */
  Wrapper_print(f,f_wrappers);

  /* Now register the function with the language */
  create_command(name, iname, (vararg ? -1 : numarg));
  Delete(cleanup);
  Delete(outarg);
  DelWrapper(f);
}

/* ---------------------------------------------------------------------
 * RUBY::link_variable(char *name, char *iname, SwigType *t)
 *
 * Create a link to a C variable.
 *              name = Name of C variable
 *              iname = Name of variable in scripting language
 *              t = Datatype of the variable
 * --------------------------------------------------------------------- */

void RUBY::link_variable(char *name, char *iname, SwigType *t) {
  char *tm, *source;

  String *getfname, *setfname;
  Wrapper *getf, *setf;

  getf = NewWrapper();
  setf = NewWrapper();

  /* create getter */
  getfname = NewString(Swig_name_get(name));
  Replace(getfname,"::", "_", DOH_REPLACE_ANY); /* FIXME: Swig_name_get bug? */
  Printv(getf->def, "static VALUE\n", getfname, "(", 0);
  Printf(getf->def, "VALUE self");
  Printf(getf->def, ") {");
  Wrapper_add_local(getf,"_val","VALUE _val");

  if (SwigType_type(t) == T_USER) {
    /* Hack this into a pointer */
    String *pname = NewString("");
    Printv(pname, "&", name, 0);
    source = Char(pname);
  } else {
    source = name;
  }

  tm = ruby_typemap_lookup((char*)"varout",t,name,source,(char*)"_val");
  if (!tm)
    tm = ruby_typemap_lookup((char*)"out",t,name,source,(char*)"_val");
  if (tm) {
    String *s = NewString(tm);
    Printv(getf->code,s, 0);
    Delete(s);
  } else {
    Printf(stderr,"%s: Line %d. Unable to link with variable type %s\n",
	    input_file,line_number,SwigType_str(t,0));
  }
  Printv(getf->code, tab4, "return _val;\n}\n", 0);
  Wrapper_print(getf,f_wrappers);

  if (Status & STAT_READONLY) {
    setfname = NewString("NULL");
  } else {
    /* create setter */
    char *target;

    setfname = NewString(Swig_name_set(name));
    Replace(setfname,"::", "_", DOH_REPLACE_ANY); /* FIXME: Swig_name_get bug? */
    Printv(setf->def, "static VALUE\n", setfname, "(VALUE self, ", 0);
    Printf(setf->def, "VALUE _val) {");

    if (SwigType_type(t) == T_USER) {
      SwigType_add_pointer(t);
      Wrapper_add_localv(setf,"temp",SwigType_lstr(t,0), "temp",0);
      SwigType_del_pointer(t);
      target = "temp";
    } else {
      target = name;
    }

    tm = ruby_typemap_lookup((char*)"varin",t,name,(char*)"_val",target);
    if (!tm)
      tm = ruby_typemap_lookup((char*)"in",t,name,(char*)"_val",target);
    if (tm) {
      String *s = NewString(tm);
      Printv(setf->code,s,0);
      Delete(s);
    } else {
      Printf(stderr,"%s: Line %d. Unable to link with variable type %s\n",
	      input_file,line_number,SwigType_str(t,0));
    }
    if (SwigType_type(t) == T_USER) {
      Printv(setf->code, name, " = *temp;\n",0);
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
    if (!(Status & STAT_READONLY)) {
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
    if (!(Status & STAT_READONLY)) {
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
 * RUBY::declare_const(char *name, char *iname, SwigType *type, char *value)
 *
 * Makes a constant.
 *              name = Name of the constant
 *              iname = Scripting language name of constant
 *              type = Datatype of the constant
 *              value = Constant value (as a string)
 * --------------------------------------------------------------------- */

void RUBY::declare_const(char *name, char *iname, SwigType *type, char *value) {
  char *tm;

  if (current == CLASS_CONST)
    iname = klass->strip(iname);

  tm = ruby_typemap_lookup((char*)"const",type,name,value,iname);
  if (tm) {
    String *str = NewString(tm);
    Replace(str,"$value",value, DOH_REPLACE_ANY);
    if (current == CLASS_CONST) {
      Replace(str,"$module", klass->vname, DOH_REPLACE_ANY);
      Printv(klass->init, str, 0);
    } else {
      Replace(str,"$module", modvar, DOH_REPLACE_ANY);
      Printf(f_init,"%s", str);
    }
    Delete(str);
  } else {
    Printf(stderr,"%s : Line %d. Unable to create constant %s = %s\n",
	    input_file, line_number, SwigType_str(type,0), value);
  }
}

/* ---------------------------------------------------------------------
 * RUBY::ruby_typemap_lookup(char *op, SwigType *type, char *pname, char *source, char *target, WrapperFunction *f = 0)
 *
 * Ruby specific typemap_lookup.
 *              op     = string code for type of mapping
 *              type   = the datatype
 *              pname  = an optional parameter name
 *              source = a string with the source variable
 *              target = a string containing the target value
 *              f      = a wrapper function object (optional)
 * --------------------------------------------------------------------- */

char *RUBY::ruby_typemap_lookup(char *op, SwigType *type, String_or_char *pname, char *source, char *target, Wrapper *f) {
  static String *s = 0;
  char *tm;
  String *target_replace = NewString(target);
  target = Char(target_replace);
  int type_code, add_pointer = 0;

  if (SwigType_type(type) == T_USER)
    add_pointer = 1;
  if (add_pointer)
    SwigType_add_pointer(type);
  type_code = SwigType_type(type);

  RClass *cls = RCLASS(classes, SwigType_base(type));

  if (!s) s = NewString("");
  Clear(s);

  if ((strcmp("out", op) == 0 || strcmp("in", op) == 0)
      && Cmp(SwigType_base(type), "VALUE") == 0) {
    Printf(s,"$target = $source;\n");
  } else if (strcmp("out", op) == 0
	     && (type_code == T_POINTER || type_code == T_REFERENCE)
	     && cls) {
    const char *vname = (current == CONSTRUCTOR ? "self" : Char(cls->vname));
    Printv(s, "$target = Wrap_", cls->cname, "(", vname, ", $source);\n",0);
  } else if (strcmp("in", op)==0
	     && (type_code == T_POINTER || type_code == T_REFERENCE)
	     && cls) {
    Printv(s, "Get_", cls->cname, "($source, $target);\n", 0);
  } else {
    if (add_pointer) {
      SwigType_del_pointer(type);
      add_pointer = 0;
    }

    tm = Swig_typemap_lookup(op, type, pname, source, target, f);
    if (tm) {
      Delete(target_replace);
      Printv(s, tm, "\n", 0);
    } else {
      Clear(s);
      if (strcmp("in", op) == 0) {
	String *v = NewString("");
	if (from_VALUE(type, (char*)"$source", (char*)"$target", v))
	  Printv(s, v, "\n", 0);
	Delete(v);
      } else if (strcmp("out", op) == 0) {
	String *v = NewString("");
	if (to_VALUE(type, (char*)"$source", v))
	  Printv(s, "$target = ", v, ";\n", 0);
	Delete(v);
      } else if (strcmp("const", op) == 0) {
	String *v = NewString("");
	if (to_VALUE(type, (char*)"$value", v, 1)) {
	  Printv(s, "rb_define_const($module, \"$target\", ", v, ");\n", 0);
	  validate_const_name(target);
	}
	Delete(v);
      }
    }
  }
  if (source && strlen(source) > 0)
    Replace(s,"$source",source, DOH_REPLACE_ANY);
  if (target && strlen(target) > 0)
    Replace(s,"$target",target, DOH_REPLACE_ANY);
  Replace(s,"$type", SwigType_str(type,0), DOH_REPLACE_ANY);

  if (add_pointer) {
    SwigType_del_pointer(type);
    add_pointer = 0;
  }

  if (Len(s) == 0)
    return NULL;
  return Char(s);
}


static void
convert_pointer(char *src, SwigType *t, String *f) {
  SwigType_remember(t);
  Printv(f, "SWIG_NewPointerObj((void *)", src, ", SWIGTYPE", SwigType_manglestr(t), ")", 0);
}

/* ---------------------------------------------------------------------
 * RUBY::to_VALUE(SwigType *type, char *value, literal)
 *
 * Makes a VALUE (as a string)
 *              type = Datatype of the C value
 *              value = C value (as a string)
 *              str = resulting code (as a string)
 *              raw = value is raw string (not quoted) ?
 * --------------------------------------------------------------------- */

int RUBY::to_VALUE(SwigType *type, char *value, String *str, int raw) {
  Clear(str);
  switch(SwigType_type(type)) {
  case T_INT:
  case T_SHORT:
  case T_LONG:
  case T_SCHAR:
    Printv(str, "INT2NUM(", value, ")", 0);
    break;
  case T_UINT:
  case T_USHORT:
  case T_ULONG:
  case T_UCHAR:
    Printv(str,"UINT2NUM(", value, ")", 0);
    break;
  case T_DOUBLE:
  case T_FLOAT:
    Printv(str, "rb_float_new(", value, ")", 0);
    break;
  case T_CHAR:
    Printv(str, "rb_str_new(&", value, ", 1)", 0);
    break;
  case T_BOOL:
    Printv(str, "(", value, " ? Qtrue : Qfalse)", 0);
    break;
  case T_STRING:
    if (raw)
      Printv(str, "rb_str_new2(\"", value, "\")", 0);
    else
      Printv(str, "rb_str_new2(", value, ")", 0);
    break;
  case T_ARRAY:
    {
      SwigType *aop;
      SwigType *ta = Copy(type);
      aop = SwigType_pop(ta);
      if (SwigType_type(ta) == T_CHAR) {
	Printf(str, "rb_str_new2(%s)", value);
	break;
      }
      convert_pointer(value, type, str);
      break;
    }
  case T_POINTER: case T_REFERENCE:
    convert_pointer(value, type, str);
    break;
  case T_USER:
    SwigType_add_pointer(type);
    convert_pointer(value, type, str);
    SwigType_del_pointer(type);
    break;
  default:
    break;
  }
  if (Len(str) == 0)
    return 0;
  return 1;
}


static void
get_pointer(char *src, char *dest, SwigType *t, String *f) {
  SwigType *lt;

  SwigType_remember(t);
  Printv(f, dest, " = (", SwigType_lstr(t,0), ")SWIG_ConvertPtr(", src, ", ", 0);

  lt = Swig_clocal_type(t);
  if (Cmp(lt,"p.void") == 0) {
    Printv(f, "0);", 0);
  } else {
    Printv(f, "SWIGTYPE", SwigType_manglestr(t), ");", 0);
  }
  Delete(lt);
}

/* ---------------------------------------------------------------------
 * RUBY::from_VALUE(SwigType *type, char *value)
 *
 * extract VALUE
 *              type  = Datatype of the C value
 *              value = Ruby VALUE (as a string)
 *              target= target C variable (as a string)
 *              str   = resulting code (as a string)
 * --------------------------------------------------------------------- */

int RUBY::from_VALUE(SwigType *type, char *value, char *target, String *str) {
  Clear(str);
  switch(SwigType_type(type)) {
  case T_INT:
    Printv(str, target, " = NUM2INT(", value, ");", 0);
    break;
  case T_LONG:
    Printv(str, target, " = NUM2LONG(", value, ");", 0);
    break;
  case T_SHORT:
    Printv(str, target, " = NUM2SHRT(", value, ");", 0);
    break;
  case T_UINT:
    Printv(str, target, " = NUM2UINT(", value, ");", 0);
    break;
  case T_ULONG:
    Printv(str, target, " = NUM2ULONG(", value, ");", 0);
    break;
  case T_USHORT:
    Printv(str, target, " = NUM2USHRT(", value, ");", 0);
    break;
  case T_DOUBLE:
  case T_FLOAT:
    Printv(str, target, " = NUM2DBL(", value, ");", 0);
    break;
  case T_CHAR: case T_SCHAR: case T_UCHAR:
    Printv(str, target, " = NUM2CHR(", value, ");", 0);
    break;
  case T_BOOL:
    Printv(str, target, " = RTEST(", value, ");", 0);
    break;
  case T_STRING:
    Printv(str, target, " = STR2CSTR(", value, ");", 0);
    break;
  case T_ARRAY:
    {
      SwigType *aop;
      SwigType *ta = Copy(type);
      aop = SwigType_pop(ta);
      if (SwigType_type(ta) == T_CHAR) {
	String *dim = SwigType_array_getdim(aop,0);
	if (dim && Len(dim)) {
	  Printf(str, "strncpy(%s, STR2CSTR(%s), %s);", target, value, dim);
	}
	break;
      }
      get_pointer(value, target, type, str);
      break;
    }
  case T_POINTER: case T_REFERENCE:
    get_pointer(value, target, type, str);
    break;
  case T_USER:
    SwigType_add_pointer(type);
    get_pointer(value, target, type, str);
    SwigType_del_pointer(type);
    break;
  default:
    break;
  }
  if (Len(str) == 0) return 0;
  return 1;
}

/* ----------------------------------------------------------------------
 * void RUBY::cpp_open_class(char *classname, char *classrename, char *ctype, int strip)
 *
 * Open a new C++ class.
 *
 * INPUTS:
 *      name   = Real name of the C++ class
 *      rename = New name of the class (if %name was used)
 *      ctype  = Class type (struct, class, union, etc...)
 *      strip  = Flag indicating whether we should strip the
 *               class type off
 *
 * This function is in charge of creating a new class.  The SWIG parser has
 * already processed the entire class definition prior to calling this
 * function (which should simplify things considerably).
 *
 * ---------------------------------------------------------------------- */

void RUBY::cpp_open_class(char *cname, char *rename, char *ctype, int strip) {
  this->Language::cpp_open_class(cname, rename, ctype, strip);

  klass = RCLASS(classes, cname);

  if (strip) {
    Clear(klass->type);
    Append(klass->type, klass->cname);
  } else {
    Clear(klass->type);
    Printv(klass->type, ctype, " ", klass->cname,0);
  }

  Printv(klass->header, "\nstatic VALUE ", klass->vname, ";\n", 0);
  Printv(klass->init, "\n", tab4, 0);
  Printv(klass->init, klass->vname, " = rb_define_class_under(", modvar,
	 ", \"", klass->name, "\", $super);\n", 0);
  Replace(klass->includes,"$class", klass->vname, DOH_REPLACE_ANY);
  Printv(klass->init, klass->includes,0);
  Printv(klass->init, "$constructor",0);

  Printv(klass->header,
	 "$markproto",
	 "$freeproto",
	 "#define Wrap_", klass->cname, "(klass, ptr) (\\\n",
	 tab4, "(ptr) ? Data_Wrap_Struct(klass",
	 ", $markfunc, $freefunc, ptr) : Qnil )\n",
	 "#define Get_", klass->cname, "(val, ptr) {\\\n",
	 tab4, "if (NIL_P(val)) ptr = NULL;\\\n",
	 tab4, "else {\\\n",
	 tab8, "if (!rb_obj_is_kind_of(val, ", klass->vname, "))\\\n",
	 tab8, tab4, "rb_raise(rb_eTypeError, \"wrong argument type",
	                 " (expected ", klass->name, ")\");\\\n",
	 tab8, "Data_Get_Struct(val, ", klass->type, ", ptr);\\\n",
	 tab8, "if (!ptr) rb_raise(rb_eRuntimeError, \"",
	         "This ", klass->name, " already released\");\\\n",
	 tab4, "}\\\n",
	 "}\n",
	 0);

}

/* ---------------------------------------------------------------------
 * void RUBY::cpp_close_class()
 *
 * Close the current class
 * --------------------------------------------------------------------- */

void RUBY::cpp_close_class() {
  this->Language::cpp_close_class();

  Replace(klass->header,"$markfunc", "0", DOH_REPLACE_ANY);
  Replace(klass->header,"$markproto", "", DOH_REPLACE_ANY);
  if (!klass->destructor_defined) {
    Replace(klass->header,"$freefunc", "0", DOH_REPLACE_ANY);
    Replace(klass->header,"$freeproto", "", DOH_REPLACE_ANY);
  }
  Printv(f_header, klass->header,0);

  Replace(klass->aliases,"$class", klass->vname, DOH_REPLACE_ANY);
  Printv(klass->init, klass->aliases,0);

  String *s = NewString("");
  Printv(s, tab4, "rb_undef_method(CLASS_OF(", klass->vname,
	 "), \"new\");\n", 0);
  Replace(klass->init,"$constructor", s, DOH_REPLACE_ANY);
  Replace(klass->init,"$super", "rb_cObject", DOH_REPLACE_ANY);

  Printv(f_init,klass->init,0);
  klass = 0;
}

/* ----------------------------------------------------------------------
 * void RUBY::cpp_inherit(char **baseclass, int mode)
 *
 * Inherit attributes from given baseclass.
 *
 * INPUT:
 *     baseclass       = NULL terminate list of baseclasses
 *
 * --------------------------------------------------------------------- */


void RUBY::cpp_inherit(char **baseclass, int mode) {
  if (!baseclass)
    return;

  for (int i = 0; baseclass[i]; i++) {
    RClass *super = RCLASS(classes, baseclass[i]);
    if (super) {
      Replace(klass->init,"$super", super->vname, DOH_REPLACE_ANY);
      break; /* ignore multiple inheritance */
    }
  }
}

/* ----------------------------------------------------------------------
 * void RUBY::cpp_member_func(char *name, char *iname, SwigType *t, ParmList *l)
 *
 * Method for adding C++ member function
 *
 * INPUTS:
 *      name        - name of the member function
 *      iname       - renaming (if given)
 *      t           - Return datatype
 *      l           - Parameter list
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

void RUBY::cpp_member_func(char *name, char *iname, SwigType *t, ParmList *l) {
  current = MEMBER_FUNC;
  this->Language::cpp_member_func(name, iname, t, l);
  current = NO_CPP;
}

/* ---------------------------------------------------------------------
 * void RUBY::cpp_constructor(char *name, char *iname, ParmList *l)
 *
 * Method for adding C++ member constructor
 *
 * INPUTS:
 *      name     - Name of the constructor (usually same as classname)
 *      iname    - Renamed version
 *      l        - parameters
 * -------------------------------------------------------------------- */

void RUBY::cpp_constructor(char *name, char *iname, ParmList *l) {
  current = CONSTRUCTOR;
  this->Language::cpp_constructor(name, iname, l);
  current = NO_CPP;
}

/* ---------------------------------------------------------------------
 * void RUBY::cpp_destructor(char *name, char *iname)
 *
 * Method for adding C++ member destructor
 *
 * INPUT:
 *     name        -  Name of the destructor (classname)
 *     iname       -  Renamed destructor
 *
 * -------------------------------------------------------------------- */

void RUBY::cpp_destructor(char *name, char *newname) {
  current = DESTRUCTOR;
  this->Language::cpp_destructor(name, newname);

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
      Printv(freebody, Swig_cppdestructor_call(), 0);
    else
      Printv(freebody, Swig_cdestructor_call(), 0);
  }
  Printv(freebody, ";\n}\n", 0);
  if (CPlusPlus) {
    Insert(freefunc,0,"VOIDFUNC(");
    Append(freefunc,")");
  }

  Replace(klass->header,"$freefunc", freefunc, DOH_REPLACE_ANY);
  Replace(klass->header,"$freeproto", freeproto, DOH_REPLACE_ANY);
  Printv(f_wrappers, freebody, 0);

  klass->destructor_defined = 1;
  current = NO_CPP;
  Delete(freefunc);
  Delete(freeproto);
  Delete(freebody);
}

/* ---------------------------------------------------------------------
 * void RUBY::cpp_variable(char *name, char *iname, SwigType *t)
 *
 * Wrap a C++ data member
 *
 * INPUTS :
 *      name       = Name of the C++ member
 *     iname       = Name as used in the interpreter
 *         t       = Datatype
 *
 * This creates a pair of functions to set/get the variable of a member.
 * -------------------------------------------------------------------- */

void RUBY::cpp_variable(char *name, char *iname, SwigType *t) {
  current = MEMBER_VAR;
  this->Language::cpp_variable(name, iname, t);
  current = NO_CPP;
}

/* -----------------------------------------------------------------------
 * void RUBY::cpp_static_func(char *name, char *iname, SwigType *t, ParmList *l)
 *
 * Wrap a static C++ function
 *
 * INPUTS:
 *      name           = Real name of the function
 *     iname           = New name in interpreter
 *      t              = Return datatype
 *      l              = Parameters
 * ---------------------------------------------------------------------- */

void RUBY::cpp_static_func(char *name, char *iname, SwigType *t, ParmList *l) {
  current = STATIC_FUNC;
  this->Language::cpp_static_func(name, iname, t, l);
  current = NO_CPP;
}

/* ----------------------------------------------------------------------
 * void RUBY::cpp_declare_const(char *name, char *iname, SwigType *t, char *value)
 *
 * Create a C++ constant
 *
 * INPUTS :
 *       name          = Real name of the constant
 *       iname         = new name
 *       t             = Datatype
 *       value         = value as a string
 *
 * --------------------------------------------------------------------- */


void RUBY::cpp_declare_const(char *name, char *iname, SwigType *type, char *value) {
  current = CLASS_CONST;
  this->Language::cpp_declare_const(name, iname, type, value);
  current = NO_CPP;
}

/* ---------------------------------------------------------------------
 * void RUBY::cpp_static_var(char *name, char *iname, SwigType *t)
 *
 * Wrap a static C++ variable
 *
 * INPUT :
 *      name        = name of the variable
 *     iname        = interpreter name
 *         t        = Datatype
 *
 * --------------------------------------------------------------------- */

void RUBY::cpp_static_var(char *name, char *iname, SwigType *t) {
  current = STATIC_VAR;
  this->Language::cpp_static_var(name, iname, t);
  current = NO_CPP;
}

/* -----------------------------------------------------------------------
 * RUBY::cpp_class_decl(char *name, char *rename, char *type)
 *
 * A forward class declaration
 * ----------------------------------------------------------------------- */

void RUBY::cpp_class_decl(char *cname, char *rename, char *type) {
  String *valid_name = NewString((rename ? rename : cname));
  validate_const_name(Char(valid_name));
  klass->set_name(cname, rename, Char(valid_name));
  SET_RCLASS(classes, cname, klass);
  if (type && strlen(type) > 0) {
    char temp[256];
    sprintf(temp,"%s %s", type, cname);
    SET_RCLASS(classes, temp, klass);
  }
  /*
  char s[256];
  sprintf(s,"extern VALUE %s;\n", Char(klass->vname));
  Printf(f_header, s);
  */
  klass = new RClass();
  Delete(valid_name);
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

/* -----------------------------------------------------------------------------
 * RUBY::cpp_pragma(Pragma *plist)
 *
 * Handle C++ pragmas
 * ----------------------------------------------------------------------------- */


void RUBY::cpp_pragma(Pragma *plist) {
  while (plist) {
    pragma(Char(plist->lang), Char(plist->name), Char(plist->value));
    plist = plist->next;
  }
}

/* ---------------------------------------------------------------------
 * RUBY::import(char *filename)
 *
 * Imports a SWIG module as a separate file.
 *---------------------------------------------------------------------- */


void RUBY::import(char *filename) {
  if (import_file) free(import_file);
  import_file = Swig_copy_string(filename);
}

/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */

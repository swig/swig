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

char cvsroot_ruby_cxx[] = "$Header$";

#include "swigmod.h"

#ifndef MACSWIG
#include "swigconfig.h"
#endif

#include <ctype.h>
#include <string.h>
#include <limits.h> /* for INT_MAX */

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

  void set_name(const String_or_char *cn, const String_or_char *rn, const String_or_char *valn) {
    Clear(cname);
    Append(cname,cn);
    Delete(mname);
    mname = Swig_name_mangle(cname);
    Clear(name);
    Append(name,valn);
    Clear(vname);
    Printf(vname,"c%s.klass",name);
    Clear(prefix);
    Printv(prefix,(rn ? rn : cn), "_", NIL);
  }

  char *strip(const String_or_char *s) {
    Clear(temp);
    Append(temp, s);
    if (Strncmp(s, prefix, Len(prefix)) == 0) {
      Replaceall(temp,prefix,"");
    }
    return Char(temp);
  }
};


#ifdef RUBY_SUPPORTS_KEYWORD_ARGS
static const char *
usage = "\
Ruby Options (available with -ruby)\n\
     -ldflags        - Print runtime libraries to link with\n\
     -feature name   - Set feature name (used by `require')\n\
     -keyword        - Use keyword arguments\n";
#else
static const char *
usage = "\
Ruby Options (available with -ruby)\n\
     -ldflags        - Print runtime libraries to link with\n\
     -feature name   - Set feature name (used by `require')\n";
#endif

#define RCLASS(hash, name) (RClass*)(Getattr(hash, name) ? Data(Getattr(hash, name)) : 0)
#define SET_RCLASS(hash, name, klass) Setattr(hash, name, NewVoid(klass, 0))


class RUBY : public Language {
private:

  String *module;
  String *modvar;
  String *feature;
  int current;
  Hash *classes;		/* key=cname val=RClass */
  RClass *klass;		/* Currently processing class */
  Hash *special_methods;	/* Python style special method name table */
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  bool use_kw;

  // Wrap modes
  enum {
    NO_CPP,
    MEMBER_FUNC,
    CONSTRUCTOR_ALLOCATE,
    CONSTRUCTOR_INITIALIZE,
    DESTRUCTOR,
    MEMBER_VAR,
    CLASS_CONST,
    STATIC_FUNC,
    STATIC_VAR
  };

public:

  /* ---------------------------------------------------------------------
   * RUBY()
   *
   * Initialize member data
   * --------------------------------------------------------------------- */

  RUBY() {
    module = 0;
    modvar = 0;
    feature = 0;
    current = NO_CPP;
    classes = 0;
    klass = 0;
    special_methods = 0;
    f_runtime = 0;
    f_header = 0;
    f_wrappers = 0;
    f_init = 0;
    use_kw = false;
  }
  
  /* ---------------------------------------------------------------------
   * main()
   *
   * Parse command line options and initializes variables.
   * --------------------------------------------------------------------- */

  virtual void main(int argc, char *argv[]) {

    /* Set location of SWIG library */
    SWIG_library_directory("ruby");
    
    /* Look for certain command line options */
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp(argv[i],"-feature") == 0) {
	  if (argv[i+1]) {
	    char *name = argv[i+1];
	    feature = NewString(name);
	    Swig_mark_arg(i);
	    Swig_mark_arg(i+1);
	    i++;
	  } else {
	    Swig_arg_error();
	  }
	} else if (strcmp(argv[i],"-help") == 0) {
	  Printf(stderr,"%s\n", usage);
	} else if (strcmp (argv[i],"-ldflags") == 0) {
	  printf("%s\n", SWIG_RUBY_RUNTIME);
	  SWIG_exit (EXIT_SUCCESS);
	} else if (strcmp(argv[i],"-keyword") == 0) {
	  use_kw = true;
	  Swig_mark_arg(i);
	}
      }
    }

    /* Add a symbol to the parser for conditional compilation */
    Preprocessor_define("SWIGRUBY 1", 0);
    
    /* Add typemap definitions */
    SWIG_typemap_lang("ruby");
    SWIG_config_file("ruby.swg");
    allow_overloading();
  }

  /**
   * Generate initialization code to define the Ruby module(s),
   * accounting for nested modules as necessary.
   */
  void defineRubyModule() {
    List *modules = Split(module,':',INT_MAX);
    if (modules != 0 && Len(modules) > 0) {
      String *mv = 0;
      String *m = Firstitem(modules);
      while (m != 0) {
        if (Len(m) > 0) {
	  if (mv != 0) {
            Printv(f_init, tab4, modvar,
	      " = rb_define_module_under(", modvar, ", \"", m, "\");\n", NIL);
	  } else {
            Printv(f_init, tab4, modvar,
	      " = rb_define_module(\"", m, "\");\n", NIL);
	    mv = NewString(modvar);
	  }
	}
	m = Nextitem(modules);
      }
      Delete(mv);
      Delete(modules);
    }
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {

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
	   NIL);

    Printv(f_init, tab4, "SWIG_InitRuntime();\n", NIL);

    defineRubyModule();

    Printv(f_init,
	   "\n",
	   "for (i = 0; swig_types_initial[i]; i++) {\n",
	   "swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);\n",
	   "SWIG_define_class(swig_types[i]);\n",
	   "}\n",
	   NIL);
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
   * importDirective()
   * ----------------------------------------------------------------------------- */
  
  virtual int importDirective(Node *n) {
    String *modname = Getattr(n,"module");
    if (modname) {
      Printf(f_init,"rb_require(\"%s\");\n", modname);
    }
    return Language::importDirective(n);
  }

  /* ---------------------------------------------------------------------
   * set_module(const char *mod_name)
   *
   * Sets the module name.  Does nothing if it's already set (so it can
   * be overridden as a command line option).
   *---------------------------------------------------------------------- */

  void set_module(const char *s) {
    String *mod_name = NewString(s);
    if (module == 0) {
      /* Start with the empty string */
      module = NewString("");
      
      /* Account for nested modules */
      List *modules = Split(mod_name,':',INT_MAX);
      if (modules != 0 && Len(modules) > 0) {
        String *last = 0;
	String *m = Firstitem(modules);
	while (m != 0) {
	  if (Len(m) > 0) {
	    String *cap = NewString(m);
	    (Char(cap))[0] = toupper((Char(cap))[0]);
	    if (last != 0) {
	      Append(module, "::");
	    }
	    Append(module, cap);
	    last = m;
	  }
	  m = Nextitem(modules);
	}
	if (feature == 0) {
	  feature = Copy(last);
	}
	(Char(last))[0] = toupper((Char(last))[0]);
	modvar = NewStringf("m%s", last);
	Delete(modules);
      }
    }
    Delete(mod_name);
  }
  
  /* --------------------------------------------------------------------------
   * nativeWrapper()
   * -------------------------------------------------------------------------- */
  virtual int nativeWrapper(Node *n) {
    String *funcname = Getattr(n,"wrap:name");
    Swig_warning(WARN_LANG_NATIVE_UNIMPL, input_file, line_number, 
		 "Adding native function %s not supported (ignored).\n", funcname);
    return SWIG_NOWRAP;
  }

  /**
   * Process the comma-separated list of aliases (if any).
   */
  void defineAliases(Node *n, const String_or_char *iname) {
    String *aliasv = Getattr(n,"feature:alias");
    if (aliasv) {
      List *aliases = Split(aliasv,',',INT_MAX);
      if (aliases && Len(aliases) > 0) {
	String *alias = Firstitem(aliases);
	while (alias) {
          if (Len(alias) > 0) {
            Printv(klass->init, tab4, "rb_define_alias(", klass->vname, ", \"", alias, "\", \"", iname, "\");\n", NIL);
	  }
	  alias = Nextitem(aliases);
	}
      }
      Delete(aliases);
    }
  }
  
  /* ---------------------------------------------------------------------
   * create_command(Node *n, char *iname)
   *
   * Creates a new command from a C function.
   *              iname = Name of function in scripting language
   * --------------------------------------------------------------------- */

  void create_command(Node *n, const String_or_char *iname) {

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
    
    switch (current) {
    case MEMBER_FUNC:
      Printv(klass->init, tab4, "rb_define_method(", klass->vname, ", \"",
	     iname, "\", ", wname, ", -1);\n", NIL);
      break;
    case CONSTRUCTOR_ALLOCATE:
      Printv(s, tab4, "rb_define_singleton_method(", klass->vname,
	     ", \"new\", ", wname, ", -1);\n", NIL);
      Replaceall(klass->init,"$allocator", s);
      break;
    case CONSTRUCTOR_INITIALIZE:
      Printv(s, tab4, "rb_define_method(", klass->vname,
	     ", \"initialize\", ", wname, ", -1);\n", NIL);
      Replaceall(klass->init,"$initializer", s);
      break;
    case MEMBER_VAR:
      Append(temp,iname);
      Replaceall(temp,"_set", "=");
      Replaceall(temp,"_get", "");
      Printv(klass->init, tab4, "rb_define_method(", klass->vname, ", \"",
	     temp, "\", ", wname, ", -1);\n", NIL);
      break;
    case STATIC_FUNC:
      Printv(klass->init, tab4, "rb_define_singleton_method(", klass->vname,
	     ", \"", iname, "\", ", wname, ", -1);\n", NIL);
      break;
    default:
      Printv(s, tab4, "rb_define_module_function(", modvar, ", \"",
	     iname, "\", ", wname, ", -1);\n",NIL);
      Printv(f_init,s,NIL);
      break;
    }
    
    defineAliases(n, iname);

    Delete(temp);
    Delete(s);
    Delete(wname);
  }
  
  /* ---------------------------------------------------------------------
   * marshalInputArgs(int numarg, int numreq, int start, Wrapper *f)
   *
   * Checks each of the parameters in the parameter list for a "check"
   * typemap and (if it finds one) inserts the typemapping code into
   * the function wrapper.
   * --------------------------------------------------------------------- */
  
  void marshalInputArgs(ParmList *l, int numarg, int numreq, int start, String *kwargs, bool allow_kwargs, Wrapper *f) {
    int i;
    Parm *p;
    String *tm;
    char source[256], target[256];
  
    int use_self = (current == MEMBER_FUNC || current == MEMBER_VAR) ? 1 : 0;
    int varargs = emit_isvarargs(l);

    Printf(kwargs,"{ ");
    for (i = 0, p = l; i < numarg; i++) {

      /* Skip ignored arguments */
      while (checkAttribute(p,"tmap:in:numinputs","0")) {
	p = Getattr(p,"tmap:in:next");
      }

      SwigType *pt = Getattr(p,"type");
      String   *pn = Getattr(p,"name");
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
      
      /* Record argument name for keyword argument handling */
      if (Len(pn)) {
        Printf(kwargs,"\"%s\",", pn);
      } else {
	Printf(kwargs,"\"arg%d\",", i+1);
      }

      /* Look for an input typemap */
      if ((tm = Getattr(p,"tmap:in"))) {
	Replaceall(tm,"$target",ln);
	Replaceall(tm,"$source",source);
	Replaceall(tm,"$input",source);
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
    
    /* Finish argument marshalling */
    Printf(kwargs," NULL }");
    if (allow_kwargs) {
      Printv(f->locals, tab4, "char *kwnames[] = ", kwargs, ";\n", NIL);
    }
    
    /* Trailing varargs */
    if (varargs) {
      if (p && (tm = Getattr(p,"tmap:in"))) {
	sprintf(source,"argv[%d]",i-start);
	Replaceall(tm,"$input",source);
	Setattr(p,"emit:input",source);
	Printf(f->code,"if (argc > %d) {\n", i-start);
	Printv(f->code,tm,"\n",NIL);
	Printf(f->code,"}\n");
      }
    }
  }

  /* ---------------------------------------------------------------------
   * insertConstraintCheckingCode(ParmList *l, Wrapper *f)
   *
   * Checks each of the parameters in the parameter list for a "check"
   * typemap and (if it finds one) inserts the typemapping code into
   * the function wrapper.
   * --------------------------------------------------------------------- */
  
  void insertConstraintCheckingCode(ParmList *l, Wrapper *f) {
    Parm *p;
    String *tm;
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:check"))) {
	Replaceall(tm,"$target",Getattr(p,"lname"));
	Printv(f->code,tm,"\n",NIL);
	p = Getattr(p,"tmap:check:next");
      } else {
	p = nextSibling(p);
      }
    }
  }

  /* ---------------------------------------------------------------------
   * insertCleanupCode(ParmList *l, String *cleanup)
   *
   * Checks each of the parameters in the parameter list for a "freearg"
   * typemap and (if it finds one) inserts the typemapping code into
   * the function wrapper.
   * --------------------------------------------------------------------- */
  
  void insertCleanupCode(ParmList *l, String *cleanup) {
    String *tm;
    for (Parm *p = l; p; ) {
      if ((tm = Getattr(p,"tmap:freearg"))) {
	Replaceall(tm,"$source",Getattr(p,"lname"));
	Printv(cleanup,tm,"\n",NIL);
	p = Getattr(p,"tmap:freearg:next");
      } else {
	p = nextSibling(p);
      }
    }
  }

  /* ---------------------------------------------------------------------
   * insertCleanupCode(ParmList *l, String *cleanup)
   *
   * Checks each of the parameters in the parameter list for a "argout"
   * typemap and (if it finds one) inserts the typemapping code into
   * the function wrapper.
   * --------------------------------------------------------------------- */
  
  void insertArgOutputCode(ParmList *l, String *outarg, int& need_result) {
    String *tm;
    for (Parm *p = l; p; ) {
      if ((tm = Getattr(p,"tmap:argout"))) {
	Replaceall(tm,"$source",Getattr(p,"lname"));
	Replaceall(tm,"$target","vresult");
	Replaceall(tm,"$result","vresult");
	Replaceall(tm,"$arg",Getattr(p,"emit:input"));
	Replaceall(tm,"$input",Getattr(p,"emit:input"));
	Printv(outarg,tm,"\n",NIL);
	need_result = 1;
	p = Getattr(p,"tmap:argout:next");
      } else {
	p = nextSibling(p);
      }
    }
  }
  
  /* ---------------------------------------------------------------------
   * validIdentifier()
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

  virtual int validIdentifier(String *s) {
    char *c = Char(s);
    while (*c) {
      if ( !( isalnum(*c) || (*c == '_') || (*c == '?') || (*c == '!') || (*c == '=') ) ) return 0;
      c++;
    }
    return 1;
  }
  
  /* ---------------------------------------------------------------------
   * functionWrapper()
   *
   * Create a function declaration and register it with the interpreter.
   * --------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
    String *symname = Copy(Getattr(n,"sym:name"));
    SwigType *t = Getattr(n,"type");
    ParmList *l = Getattr(n,"parms");
    String *tm;
    
    int need_result = 0;
    
    /* Ruby needs no destructor wrapper */
    if (current == DESTRUCTOR)
      return SWIG_NOWRAP;
    
    /* If the C++ class constructor is overloaded, we only want to
     * write out the "new" singleton method once since it is always
     * the same. (It's the "initialize" method that will handle the
     * overloading). */

    if (current == CONSTRUCTOR_ALLOCATE &&
        Swig_symbol_isoverloaded(n) &&
	Getattr(n, "sym:nextSibling") != 0) return SWIG_OK;
    
    String *overname = 0;
    if (Getattr(n, "sym:overloaded")) {
      overname = Getattr(n, "sym:overname");
    } else {
      if (!addSymbol(symname, n))
        return SWIG_ERROR;
    }

    String *cleanup = NewString("");
    String *outarg = NewString("");
    String *kwargs = NewString("");
    Wrapper *f = NewWrapper();

    /* Rename predicate methods */
    if (Getattr(n, "feature:predicate")) {
      Append(symname, "?");
    }

    /* Determine the name of the SWIG wrapper function */
    String *wname = Swig_name_wrapper(symname);
    if (overname && current != CONSTRUCTOR_ALLOCATE) {
      Append(wname,overname);
    }
  
    /* Emit arguments */
    if (current != CONSTRUCTOR_ALLOCATE) {
      emit_args(t,l,f);
    }

    /* Attach standard typemaps */
    if (current != CONSTRUCTOR_ALLOCATE) {
      emit_attach_parmmaps(l, f);
    }
    Setattr(n, "wrap:parms", l);

    /* Get number of arguments */
    int  numarg = emit_num_arguments(l);
    int  numreq = emit_num_required(l);
    int  varargs = emit_isvarargs(l);
    bool allow_kwargs = use_kw || Getattr(n,"feature:kwargs");

    int start = (current == MEMBER_FUNC || current == MEMBER_VAR) ? 1 : 0;

    /* Now write the wrapper function itself */
    Printv(f->def, "static VALUE\n", wname, "(int argc, VALUE *argv, VALUE self) {", NIL);

    if (current != CONSTRUCTOR_ALLOCATE) {
      if (!varargs) {
	Printf(f->code,"if ((argc < %d) || (argc > %d))\n", numreq-start, numarg-start);
      } else {
	Printf(f->code,"if (argc < %d)\n", numreq-start);
      }
      Printf(f->code,"rb_raise(rb_eArgError, \"wrong # of arguments(%%d for %d)\",argc);\n",numreq-start);
    }

    /* Now walk the function parameter list and generate code */
    /* to get arguments */
    if (current != CONSTRUCTOR_ALLOCATE) {
      marshalInputArgs(l, numarg, numreq, start, kwargs, allow_kwargs, f);
    }

    /* Insert constraint checking code */
    insertConstraintCheckingCode(l, f);
  
    /* Insert cleanup code */
    insertCleanupCode(l, cleanup);

    /* Insert argument output code */
    insertArgOutputCode(l, outarg, need_result);

    /* Now write code to make the function call */
    if (current != CONSTRUCTOR_ALLOCATE) {
      if (current == CONSTRUCTOR_INITIALIZE) {
	String *action = Getattr(n,"wrap:action");
	if (action) {
	  Append(action,"DATA_PTR(self) = result;");
	}
      }
      emit_action(n,f);
    }

    int newobj = 0;
    if (Getattr(n,"feature:new")) newobj = 1;

    /* Return value if necessary */
    if (SwigType_type(t) != T_VOID && current != CONSTRUCTOR_ALLOCATE && current != CONSTRUCTOR_INITIALIZE) {
      need_result = 1;
      if (Getattr(n, "feature:predicate")) {
	Printv(f->code, tab4, "vresult = (result ? Qtrue : Qfalse);\n", NIL);
      } else {
	tm = Swig_typemap_lookup_new("out",n,"result",0);
	if (tm) {
	  Replaceall(tm,"$result","vresult");
	  Replaceall(tm,"$source","result");
	  Replaceall(tm,"$target","vresult");
	  Replaceall(tm,"$owner", newobj ? "1" : "0");
	  Printv(f->code, tm, "\n", NIL);
	} else {
	  Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
		       "Unable to use return type %s.\n", SwigType_str(t,0));
	}
      }
    }

    /* Extra code needed for new and initialize methods */  
    if (current == CONSTRUCTOR_ALLOCATE) {
      need_result = 1;
      Printf(f->code, "VALUE vresult = SWIG_NewClassInstance(self, SWIGTYPE%s);\n", Char(SwigType_manglestr(t)));
      Printf(f->code, "rb_obj_call_init(vresult, argc, argv);\n");
    } else if (current == CONSTRUCTOR_INITIALIZE) {
      need_result = 1;
      // Printf(f->code, "DATA_PTR(self) = result;\n");
    }

    /* Dump argument output code; */
    Printv(f->code,outarg,NIL);

    /* Dump the argument cleanup code */
    if (current != CONSTRUCTOR_ALLOCATE)
      Printv(f->code,cleanup,NIL);

    /* Look for any remaining cleanup.  This processes the %new directive */
    if (newobj) {
      tm = Swig_typemap_lookup_new("newfree",n,"result",0);
      if (tm) {
	Replaceall(tm,"$source","result");
	Printv(f->code,tm, "\n",NIL);
      }
    }

    /* Special processing on return value. */
    tm = Swig_typemap_lookup_new("ret",n,"result",0);
    if (tm) {
      Replaceall(tm,"$source","result");
      Printv(f->code,tm, NIL);
    }

    /* Wrap things up (in a manner of speaking) */
    if (need_result) {
      if (current == CONSTRUCTOR_ALLOCATE) {
	Printv(f->code, tab4, "return vresult;\n}\n", NIL);
      } else if (current == CONSTRUCTOR_INITIALIZE) {
	Printv(f->code, tab4, "return self;\n}\n", NIL);
      } else {
	Wrapper_add_local(f,"vresult","VALUE vresult = Qnil");
	Printv(f->code, tab4, "return vresult;\n}\n", NIL);
      }
    } else {
      Printv(f->code, tab4, "return Qnil;\n}\n", NIL);
    }

    /* Substitute the cleanup code */
    Replaceall(f->code,"$cleanup",cleanup);

    /* Emit the function */
    Wrapper_print(f, f_wrappers);

    /* Now register the function with the interpreter */
    if (!Swig_symbol_isoverloaded(n)) {
      create_command(n, symname);
    } else {
      if (current == CONSTRUCTOR_ALLOCATE) {
        create_command(n, symname);
      } else {
	Setattr(n, "wrap:name", wname);
	if (!Getattr(n, "sym:nextSibling"))
          dispatchFunction(n);
      }
    }
    
    Delete(kwargs);
    Delete(cleanup);
    Delete(outarg);
    DelWrapper(f);
    Delete(symname);
  
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * dispatchFunction()
   * ------------------------------------------------------------ */
   
  void dispatchFunction(Node *n) {
    /* Last node in overloaded chain */

    int maxargs;
    String *tmp = NewString("");
    String *dispatch = Swig_overload_dispatch(n, "return %s(nargs, args, self);", &maxargs);
	
    /* Generate a dispatch wrapper for all overloaded functions */

    Wrapper *f       = NewWrapper();
    String  *symname = Getattr(n, "sym:name");
    String  *wname   = Swig_name_wrapper(symname);

    Printv(f->def,	
	   "static VALUE ", wname,
	   "(int nargs, VALUE *args, VALUE self) {",
	   NIL);
    
    Wrapper_add_local(f, "argc", "int argc");
    if (current == MEMBER_FUNC || current == MEMBER_VAR) {
      Printf(tmp, "VALUE argv[%d]", maxargs+1);
    } else {
      Printf(tmp, "VALUE argv[%d]", maxargs);
    }
    Wrapper_add_local(f, "argv", tmp);
    Wrapper_add_local(f, "ii", "int ii");
    if (current == MEMBER_FUNC || current == MEMBER_VAR) {
      Printf(f->code, "argc = nargs + 1;\n");
      Printf(f->code, "argv[0] = self;\n");
      Printf(f->code, "for (ii = 1; (ii < argc) && (ii < %d); ii++) {\n", maxargs);
      Printf(f->code, "argv[ii] = args[ii-1];\n");
      Printf(f->code, "}\n");
    } else {
      Printf(f->code, "argc = nargs;\n");
      Printf(f->code, "for (ii = 0; (ii < argc) && (ii < %d); ii++) {\n", maxargs);
      Printf(f->code, "argv[ii] = args[ii];\n");
      Printf(f->code, "}\n");
    }
    
    Replaceall(dispatch, "$args", "nargs, args, self");
    Printv(f->code, dispatch, "\n", NIL);
    Printf(f->code, "rb_raise(rb_eArgError, \"No matching function for overloaded '%s'\");\n", symname);
    Printf(f->code,"return Qnil;\n");
    Printv(f->code, "}\n", NIL);
    Wrapper_print(f, f_wrappers);
    create_command(n, Char(symname));

    DelWrapper(f);
    Delete(dispatch);
    Delete(tmp);
    Delete(wname);
  }
  
  /* ---------------------------------------------------------------------
   * variableWrapper()
   * --------------------------------------------------------------------- */

  virtual int variableWrapper(Node *n) {

    char *name  = GetChar(n,"name");
    char *iname = GetChar(n,"sym:name");
    SwigType *t = Getattr(n,"type");
    String *tm;
    String *getfname, *setfname;
    Wrapper *getf, *setf;

    getf = NewWrapper();
    setf = NewWrapper();

    /* create getter */
    getfname = NewString(Swig_name_get(iname));
    Printv(getf->def, "static VALUE\n", getfname, "(", NIL);
    Printf(getf->def, "VALUE self");
    Printf(getf->def, ") {");
    Wrapper_add_local(getf,"_val","VALUE _val");

    tm = Swig_typemap_lookup_new("varout",n, name, 0);
    if (tm) {
      Replaceall(tm,"$result","_val");
      Replaceall(tm,"$target","_val");
      Replaceall(tm,"$source",name);
      Printv(getf->code,tm, NIL);
    } else {
      Swig_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number,
		   "Unable to read variable of type %s\n", SwigType_str(t,0));
    }
    Printv(getf->code, tab4, "return _val;\n}\n", NIL);
    Wrapper_print(getf,f_wrappers);

    if (Getattr(n,"feature:immutable")) {
      setfname = NewString("NULL");
    } else {
      /* create setter */
      setfname = NewString(Swig_name_set(iname));
      Printv(setf->def, "static VALUE\n", setfname, "(VALUE self, ", NIL);
      Printf(setf->def, "VALUE _val) {");
    
      tm = Swig_typemap_lookup_new("varin",n,name,0);
      if (tm) {
	Replaceall(tm,"$input","_val");
	Replaceall(tm,"$source","_val");
	Replaceall(tm,"$target",name);
	Printv(setf->code,tm,"\n",NIL);
      } else {
	Swig_warning(WARN_TYPEMAP_VARIN_UNDEF, input_file, line_number,
		     "Unable to set variable of type %s\n", SwigType_str(t,0));
      }
      Printv(setf->code, tab4, "return _val;\n",NIL);
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
	     NIL);
      if (!Getattr(n,"feature:immutable")) {
	Printv(s,
	       tab4, "rb_define_singleton_method(", klass->vname, ", \"",
	       klass->strip(iname), "=\", ", setfname, ", 1);\n",
	       NIL);
      }
      Printv(klass->init,s,NIL);
      break;
    default:
      /* C global variable */
      /* wrapped in Ruby module attribute */
      Printv(s,
	     tab4, "rb_define_singleton_method(", modvar, ", \"",
	     iname, "\", ", getfname, ", 0);\n",
	     NIL);
      if (!Getattr(n,"feature:immutable")) {
	Printv(s,
	       tab4, "rb_define_singleton_method(", modvar, ", \"",
	       iname, "=\", ", setfname, ", 1);\n",
	       NIL);
      }
      Printv(f_init,s,NIL);
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
   * validate_const_name(char *name)
   *
   * Validate constant name.
   * --------------------------------------------------------------------- */

  char *
  validate_const_name(char *name, const char *reason) {
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
   * constantWrapper()
   * --------------------------------------------------------------------- */

  virtual int constantWrapper(Node *n) {
    Swig_require(&n, "*sym:name", "type", "value", NIL);
    
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
	Printv(klass->init, tm, "\n", NIL);
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
   * classDeclaration() 
   *
   * Records information about classes---even classes that might be defined in
   * other modules referenced by %import.
   * ----------------------------------------------------------------------------- */

  virtual int classDeclaration(Node *n) {
    String *name = Getattr(n,"name");
    String *symname = Getattr(n,"sym:name");
    String *tdname = Getattr(n,"tdname");
  
    name = tdname ? tdname : name;
    String *namestr = SwigType_namestr(name);
    klass = RCLASS(classes, Char(namestr));
    if (!klass) {
      klass = new RClass();
      String *valid_name = NewString(symname ? symname : namestr);
      validate_const_name(Char(valid_name), "class");
      klass->set_name(namestr, symname, valid_name);
      SET_RCLASS(classes, Char(namestr), klass);
      Delete(valid_name);
    }
    Delete(namestr);
    return Language::classDeclaration(n);
  }

  /**
   * Process the comma-separated list of mixed-in module names (if any).
   */
  void includeRubyModules(Node *n) {
    String *mixin = Getattr(n,"feature:mixin");
    if (mixin) {
      List *modules = Split(mixin,',',INT_MAX);
      if (modules && Len(modules) > 0) {
	String *mod = Firstitem(modules);
	while (mod) {
          if (Len(mod) > 0) {
            Printf(klass->init, "rb_include_module(%s, rb_eval_string(\"%s\"));\n", klass->vname, mod);
	  }
	  mod = Nextitem(modules);
	}
      }
      Delete(modules);
    }
  }

  void handleBaseClasses(Node *n) {
    List *baselist = Getattr(n,"bases");
    if (baselist && Len(baselist)) {
      Node *base = Firstitem(baselist);
      String *basename = Getattr(base,"name");
      String *basenamestr = SwigType_namestr(basename);
      RClass *super = RCLASS(classes, Char(basenamestr));
      Delete(basenamestr);
      if (super) {
	SwigType *btype = NewString(basename);
	SwigType_add_pointer(btype);
	SwigType_remember(btype);
	String *bmangle = SwigType_manglestr(btype);
	Insert(bmangle,0,"((swig_class *) SWIGTYPE");
	Append(bmangle,"->clientdata)->klass");
	Replaceall(klass->init,"$super",bmangle);
	Delete(bmangle);
	Delete(btype);
      }
    
      /* Warn about multiple inheritance if additional base class(es) listed */
      base = Nextitem(baselist);
      while (base) {
	basename = Getattr(n,"name");
	Swig_warning(WARN_RUBY_MULTIPLE_INHERITANCE, input_file, line_number, 
		     "Warning for %s: Base %s ignored. Multiple inheritance is not supported in Ruby.\n", basename, basename);
	base = Nextitem(baselist);
      }
    }
  }

  /**
   * Check to see if a %markfunc was specified.
   */
  void handleMarkFuncDirective(Node *n) {
    String *markfunc = Getattr(n, "feature:markfunc");
    if (markfunc) {
      Printf(klass->init, "c%s.mark = (void (*)(void *)) %s;\n", klass->name, markfunc);
    } else {
      Printf(klass->init, "c%s.mark = 0;\n", klass->name);
    }
  }

  /**
   * Check to see if a %freefunc was specified.
   */
  void handleFreeFuncDirective(Node *n) {
    String *freefunc = Getattr(n, "feature:freefunc");
    if (freefunc) {
      Printf(klass->init, "c%s.destroy = (void (*)(void *)) %s;\n", klass->name, freefunc);
    } else {
      if (klass->destructor_defined) {
	Printf(klass->init, "c%s.destroy = (void (*)(void *)) free_%s;\n", klass->name, klass->mname);
      }
    }
    Replaceall(klass->header,"$freeproto", "");
  }

  /* ----------------------------------------------------------------------
   * classHandler()
   * ---------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {

    String *name = Getattr(n,"name");
    String *symname = Getattr(n,"sym:name");
    String *namestr = SwigType_namestr(name); // does template expansion

    klass = RCLASS(classes, Char(namestr));
    assert(klass != 0);
    Delete(namestr);
    String *valid_name = NewString(symname);
    validate_const_name(Char(valid_name), "class");

    Clear(klass->type);
    Printv(klass->type, Getattr(n,"classtype"), NIL);
    Printv(klass->header, "\nswig_class c", valid_name, ";\n", NIL);
    Printv(klass->init, "\n", tab4, NIL);
    Printv(klass->init, klass->vname, " = rb_define_class_under(", modvar,
	   ", \"", klass->name, "\", $super);\n", NIL);

    SwigType *tt = NewString(name);
    SwigType_add_pointer(tt);
    SwigType_remember(tt);
    String *tm = SwigType_manglestr(tt);
    Printf(klass->init, "SWIG_TypeClientData(SWIGTYPE%s, (void *) &c%s);\n", tm, valid_name);
    Delete(tm);
    Delete(tt);
    Delete(valid_name);
    
    includeRubyModules(n);

    Printv(klass->init, "$allocator",NIL);
    Printv(klass->init, "$initializer",NIL);

    Printv(klass->header,
	   "$freeproto",
	   NIL);

    Language::classHandler(n);

    handleBaseClasses(n);
    handleMarkFuncDirective(n);
    handleFreeFuncDirective(n);

    Printv(f_header, klass->header,NIL);

    String *s = NewString("");
    Printv(s, tab4, "rb_undef_method(CLASS_OF(", klass->vname,
	   "), \"new\");\n", NIL);
    Replaceall(klass->init,"$allocator", s);
    Replaceall(klass->init,"$initializer", "");
    Replaceall(klass->init,"$super", "rb_cObject");
    Delete(s);

    Printv(f_init,klass->init,NIL);
    klass = 0;
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * memberfunctionHandler()
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
  
  virtual int memberfunctionHandler(Node *n) {
    current = MEMBER_FUNC;
    Language::memberfunctionHandler(n);
    current = NO_CPP;
    return SWIG_OK;
  }
  
  /* ---------------------------------------------------------------------
   * constructorHandler()
   *
   * Method for adding C++ member constructor
   * -------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {
    /* First wrap the new singleton method */
    current = CONSTRUCTOR_ALLOCATE;
    Swig_name_register((String_or_char *) "construct", (String_or_char *) "%c_allocate");
    Language::constructorHandler(n);

    /* Now do the instance initialize method */
    current = CONSTRUCTOR_INITIALIZE;
    Swig_name_register((String_or_char *) "construct", (String_or_char *) "new_%c");
    Language::constructorHandler(n);

    /* Done */
    Swig_name_unregister((String_or_char *) "construct");
    current = NO_CPP;
    klass->constructor_defined = 1;
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * destructorHandler()
   * -------------------------------------------------------------------- */

  virtual int destructorHandler(Node *n) {
    current = DESTRUCTOR;
    Language::destructorHandler(n);

    String *freefunc = NewString("");
    String *freeproto = NewString("");
    String *freebody = NewString("");
  
    Printv(freefunc, "free_", klass->mname, NIL);
    Printv(freeproto, "static void ", freefunc, "(", klass->type, " *);\n", NIL);
    Printv(freebody, "static void\n",
	   freefunc, "(", klass->type, " *", Swig_cparm_name(0,0), ") {\n",
	   tab4, NIL);
    if (Extend) {
      String *wrap = Getattr(n, "wrap:code");
      if (wrap) {
	File *f_code = Swig_filebyname("header");
	if (f_code) {
	  Printv(f_code, wrap, NIL);
	}
      }
      /*    Printv(freebody, Swig_name_destroy(name), "(", Swig_cparm_name(0,0), ")", NIL); */
      Printv(freebody,Getattr(n,"wrap:action"), NIL);
    } else {
      /* When no extend mode, swig emits no destroy function. */
      if (CPlusPlus)
	Printf(freebody, "delete %s", Swig_cparm_name(0,0));
      else
	Printf(freebody, "free((char*) %s)", Swig_cparm_name(0,0));
    }
    Printv(freebody, ";\n}\n", NIL);
  
    Replaceall(klass->header,"$freeproto", freeproto);
    Printv(f_wrappers, freebody, NIL);
  
    klass->destructor_defined = 1;
    current = NO_CPP;
    Delete(freefunc);
    Delete(freeproto);
    Delete(freebody);
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * membervariableHandler()
   *
   * This creates a pair of functions to set/get the variable of a member.
   * -------------------------------------------------------------------- */

  virtual int
  membervariableHandler(Node *n) {
    current = MEMBER_VAR;
    Language::membervariableHandler(n);
    current = NO_CPP;
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * staticmemberfunctionHandler()
   *
   * Wrap a static C++ function
   * ---------------------------------------------------------------------- */

  virtual int
  staticmemberfunctionHandler(Node *n) {
    current = STATIC_FUNC;
    Language::staticmemberfunctionHandler(n);
    current = NO_CPP;
    return SWIG_OK;
  }
  
  /* ----------------------------------------------------------------------
   * memberconstantHandler()
   *
   * Create a C++ constant
   * --------------------------------------------------------------------- */

  virtual int
  memberconstantHandler(Node *n) {
    current = CLASS_CONST;
    Language::memberconstantHandler(n);
    current = NO_CPP;
    return SWIG_OK;
  }
  
  /* ---------------------------------------------------------------------
   * staticmembervariableHandler()
   * --------------------------------------------------------------------- */

  virtual int
  staticmembervariableHandler(Node *n) {
    current = STATIC_VAR;
    Language::staticmembervariableHandler(n);
    current = NO_CPP;
    return SWIG_OK;
  }

};  /* class RUBY */
  
/* -----------------------------------------------------------------------------
 * swig_ruby()    - Instantiate module
 * ----------------------------------------------------------------------------- */

extern "C" Language *
swig_ruby(void) {
  return new RUBY();
}


/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */


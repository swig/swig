/***********************************************************************
 * Pike language module for SWIG
 ***********************************************************************/
 
static char cvsroot[] = "$Header$";

#include "swigmod.h"
#ifndef MACSWIG
#include "swigconfig.h"
#endif

class PIKE : public Language {
private:

  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  String *PrefixPlusUnderscore;
  int current;
  
  // Wrap modes
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

public:

  /* ---------------------------------------------------------------------
   * PIKE()
   *
   * Initialize member data
   * --------------------------------------------------------------------- */

  PIKE() {
    f_runtime = 0;
    f_header = 0;
    f_wrappers = 0;
    f_init = 0;
    PrefixPlusUnderscore = 0;
    current = NO_CPP;
  }

  /* ---------------------------------------------------------------------
   * main()
   *
   * Parse command line options and initializes variables.
   * --------------------------------------------------------------------- */

  virtual void main(int argc, char *argv[]) {
    /* Set location of SWIG library */
    SWIG_library_directory("pike");

    /* Look for certain command line options */
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
        if (strcmp (argv[i], "-ldflags") == 0) {
	  printf("%s\n", SWIG_PIKE_RUNTIME);
	  SWIG_exit(EXIT_SUCCESS);
	}
      }
    }

    /* Add a symbol to the parser for conditional compilation */
    Preprocessor_define("SWIGPIKE 1", 0);

    /* Set language-specific configuration file */    
    SWIG_config_file("pike.swg");

    /* Set typemap language */
    SWIG_typemap_lang("pike");
    
    /* Enable overloaded methods support */
    allow_overloading();
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {
    /* Get the module name */
    String *module = Getattr(n, "name");
    
    /* Get the output file name */
    String *outfile = Getattr(n, "outfile");
    
    /* Open the output file */
    f_runtime = NewFile(outfile, "w");
    if (!f_runtime) {
      Printf(stderr, "*** Can't open '%s'\n", outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    /* Standard stuff for the SWIG runtime section */    
    Swig_banner(f_runtime);
    if (NoInclude) {
      Printf(f_runtime, "#define SWIG_NOINCLUDE\n");
    }

    Printf(f_header, "#define SWIG_init    pike_module_init\n");
    Printf(f_header, "#define SWIG_name    \"%s\"\n\n", module);
    
    /* Change naming scheme for constructors and destructors */
    Swig_name_register((char *)"construct",(char *)"%c_create");
    Swig_name_register((char *)"destroy",(char *)"%c_destroy");
    
    /* Current wrap type */
    current = NO_CPP;

    /* Emit code for children */
    Language::top(n);
    
    /* Close the initialization function */
    Printf(f_init, "}\n");
    SwigType_emit_type_table(f_runtime, f_wrappers);
    
    /* Close all of the files */
    Dump(f_header, f_runtime);
    Dump(f_wrappers, f_runtime);
    Wrapper_pretty_print(f_init, f_runtime);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Close(f_runtime);
    Delete(f_runtime);

    /* Done */
    return SWIG_OK;
  }
  
  /* ------------------------------------------------------------
   * importDirective()
   * ------------------------------------------------------------ */

  virtual int importDirective(Node *n) {
    String *modname = Getattr(n,"module");
    if (modname) {
      Printf(f_init,"pike_require(\"%s\");\n", modname);
    }
    return Language::importDirective(n);
  }
  
  /* ------------------------------------------------------------
   * strip()
   *
   * For names that begin with the current class prefix plus an
   * underscore (e.g. "Foo_enum_test"), return the base function
   * name (i.e. "enum_test").
   * ------------------------------------------------------------ */

  String *strip(const DOHString_or_char *name) {
    String *s = Copy(name);
    if (Strncmp(name, PrefixPlusUnderscore, Len(PrefixPlusUnderscore)) != 0) {
      return s;
    }
    Replaceall(s, PrefixPlusUnderscore, "");
    return s;
  }

  /* ------------------------------------------------------------
   * add_method()
   * ------------------------------------------------------------ */

  void add_method(Node *n, const DOHString_or_char *name, const DOHString_or_char *function, const DOHString_or_char *description) {
    String *rename;
    if (current != NO_CPP) {
      rename = strip(name);
    } else {
      rename = NewString(name);
    }
    Printf(f_init, "ADD_FUNCTION(\"%s\", %s, tFunc(%s), 0);\n", rename, function, description);
    Delete(rename);
  }

  /* ---------------------------------------------------------------------
   * functionWrapper()
   *
   * Create a function declaration and register it with the interpreter.
   * --------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {

    String  *name  = Getattr(n,"name");
    String  *iname = Getattr(n,"sym:name");
    SwigType *d    = Getattr(n,"type");
    ParmList *l    = Getattr(n,"parms");

    Parm *p;
    String *tm;    
    int i;

    String *overname = 0;
    if (Getattr(n,"sym:overloaded")) {
      overname = Getattr(n,"sym:overname");
    } else {
      if (!addSymbol(iname,n)) return SWIG_ERROR;
    }

    Wrapper *f = NewWrapper();
    
    /* Write code to extract function parameters. */
    emit_args(d, l, f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l,f);
    Setattr(n,"wrap:parms",l);

    /* Get number of required and total arguments */
    int num_arguments = emit_num_arguments(l);
    int num_required  = emit_num_required(l);
    int varargs = emit_isvarargs(l);
    
    /* Which input argument to start with? */
    int start = (current == MEMBER_FUNC || current == MEMBER_VAR || current == DESTRUCTOR) ? 1 : 0;

    String *wname = Swig_name_wrapper(iname);
    if (overname) {
      Append(wname,overname);
    }
    
    Printv(f->def, "static void ", wname, "(INT32 args) {", NULL);
    
    /* Generate code for argument marshalling */
    String *description = NewString("");
    char source[64];
    for (i = 0, p = l; i < num_arguments; i++) {

      while (Getattr(p,"tmap:ignore")) {
	p = Getattr(p,"tmap:ignore:next");
      }
      
      SwigType *pt = Getattr(p,"type");
      String   *pn = Getattr(p,"name");
      String   *ln = Getattr(p,"lname");

      if (i < start) {
        String *lstr = SwigType_lstr(pt,0);
        Printf(f->code, "%s = (%s) THIS;\n", ln, lstr);
	Delete(lstr);
      } else {      
	/* Look for an input typemap */
	sprintf(source, "sp[%d-args]", i-start);
	if ((tm = Getattr(p,"tmap:in"))) {
          Replaceall(tm, "$source", source);
	  Replaceall(tm, "$target", ln);
	  Replaceall(tm, "$input", source);
	  Setattr(p, "emit:input", source);
	  Printf(f->code, "%s\n", tm);
          String *pikedesc = Getattr(p, "tmap:in:pikedesc");
	  if (pikedesc) {
	    Printv(description, pikedesc, " ", NULL);
	  }
	  p = Getattr(p,"tmap:in:next");
	  continue;
	} else {
	  Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, 
		       "Unable to use type %s as a function argument.\n",SwigType_str(pt,0));
	  break;
	}
      }
      p = nextSibling(p);
    }

    /* Check for trailing varargs */
    if (varargs) {
      if (p && (tm = Getattr(p,"tmap:in"))) {
	Replaceall(tm,"$input", "varargs");
	Printv(f->code,tm,"\n",NULL);
      }
    }

    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:check"))) {
	Replaceall(tm,"$target",Getattr(p,"lname"));
	Printv(f->code,tm,"\n",NULL);
	p = Getattr(p,"tmap:check:next");
      } else {
	p = nextSibling(p);
      }
    }
  
    /* Insert cleanup code */
    String *cleanup = NewString("");
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:freearg"))) {
	Replaceall(tm,"$source",Getattr(p,"lname"));
	Printv(cleanup,tm,"\n",NULL);
	p = Getattr(p,"tmap:freearg:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Insert argument output code */
    String *outarg = NewString("");
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:argout"))) {
	Replaceall(tm,"$source",Getattr(p,"lname"));
	Replaceall(tm,"$target","resultobj");
	Replaceall(tm,"$arg",Getattr(p,"emit:input"));
	Replaceall(tm,"$input",Getattr(p,"emit:input"));
	Printv(outarg,tm,"\n",NULL);
	p = Getattr(p,"tmap:argout:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Emit the function call */
    emit_action(n,f);

    /* Clear the return stack */
    Printf(f->code, "pop_n_elems(args);\n");

    /* Return the function value */
    if (current == CONSTRUCTOR) {
      Printv(f->code, "THIS = (void *) result;\n", NULL);
      Printv(description, ", tVoid", NULL);
    } else if (current == DESTRUCTOR) {
      Printv(description, ", tVoid", NULL);
    } else {
      Wrapper_add_local(f, "resultobj", "struct object *resultobj");
      Printv(description, ", ", NULL);
      if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
	Replaceall(tm,"$source", "result");
	Replaceall(tm,"$target", "resultobj");
	Replaceall(tm,"$result", "resultobj");
	if (Getattr(n,"feature:new")) {
	  Replaceall(tm,"$owner","1");
	} else {
	  Replaceall(tm,"$owner","0");
	}
	String *pikedesc = Getattr(n, "tmap:out:pikedesc");
	if (pikedesc) {
	  Printv(description, pikedesc, NULL);
	}
	Printf(f->code,"%s\n", tm);
      } else {
	Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
		     "Unable to use return type %s in function %s.\n", SwigType_str(d,0), name);
      }
    }

    /* Output argument output code */
    Printv(f->code,outarg,NULL);

    /* Output cleanup code */
    Printv(f->code,cleanup,NULL);

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
    
    /* Close the function */
    Printf(f->code, "}\n");

    /* Substitute the cleanup code */
    Replaceall(f->code,"$cleanup",cleanup);
    
    /* Substitute the function name */
    Replaceall(f->code,"$symname",iname);
    Replaceall(f->code,"$result","resultobj");

    /* Dump the function out */
    Wrapper_print(f,f_wrappers);

    /* Now register the function with the interpreter. */
    if (current != MEMBER_VAR) {
      if (!Getattr(n,"sym:overloaded")) {
	add_method(n, iname, wname, description);
      } else {
	Setattr(n,"wrap:name", wname);
	if (!Getattr(n,"sym:nextSibling")) {
	  dispatchFunction(n);
	}
      }
    }

    Delete(cleanup);
    Delete(outarg);
    Delete(description);
    Delete(wname);
    DelWrapper(f);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * dispatchFunction()
   *
   * Emit overloading dispatch function
   * ------------------------------------------------------------ */

  void dispatchFunction(Node *n) {
    /* Last node in overloaded chain */

    int maxargs;
    String *tmp = NewString("");
    String *dispatch = Swig_overload_dispatch(n,"return %s(self,args);",&maxargs);
	
    /* Generate a dispatch wrapper for all overloaded functions */

    Wrapper *f       = NewWrapper();
    String  *symname = Getattr(n,"sym:name");
    String  *wname   = Swig_name_wrapper(symname);
  

    Printv(f->def,	
	   "struct array *", wname,
	   "(struct array *self, struct array *args) {",
	   NULL);
    
    Wrapper_add_local(f,"argc","INT32 argc");
    Printf(tmp,"struct array *argv[%d]", maxargs+1);
    Wrapper_add_local(f,"argv",tmp);
    Wrapper_add_local(f,"ii","INT32 ii");
    Printf(f->code,"argc = sizeof(args);\n");
    Printf(f->code,"for (ii = 0; (ii < argc) && (ii < %d); ii++) {\n",maxargs);
    Printf(f->code,"argv[ii] = array_index(args,&argv[ii],ii);\n");
    Printf(f->code,"}\n");
    
    Replaceall(dispatch,"$args","self,args");
    Printv(f->code,dispatch,"\n",NULL);
    Printf(f->code,"No matching function for overloaded '%s'\n", symname);
    Printf(f->code,"return NULL;\n");
    Printv(f->code,"}\n",NULL);
    Wrapper_print(f,f_wrappers);
    add_method(n,symname,wname,0);

    DelWrapper(f);
    Delete(dispatch);
    Delete(tmp);
    Delete(wname);
  }

  /* ------------------------------------------------------------
   * variableWrapper()
   * ------------------------------------------------------------ */

  virtual int variableWrapper(Node *n) {
    return Language::variableWrapper(n);
  }

  /* ------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {

    Swig_require(&n, "*sym:name", "type", "value", NULL);
    
    String *symname = Getattr(n, "sym:name");
    SwigType *type  = Getattr(n, "type");
    String *value   = Getattr(n, "value");
    
    /* Special hook for member pointer */
    if (SwigType_type(type) == T_MPOINTER) {
      String *wname = Swig_name_wrapper(symname);
      Printf(f_header, "static %s = %s;\n", SwigType_str(type, wname), value);
      value = wname;
    }

    /* Perform constant typemap substitution */
    String *tm = Swig_typemap_lookup_new("constant", n, value, 0);
    if (tm) {
      Replaceall(tm, "$source", value);
      Replaceall(tm, "$target", symname);
      Replaceall(tm, "$symname", symname);
      Replaceall(tm, "$value", value);
      Printf(f_init, "%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_CONST_UNDEF, input_file, line_number,
		   "Unsupported constant value %s = %s\n", SwigType_str(type, 0), value);
    }

    Swig_restore(&n);
    
    return SWIG_OK;
  }

  /* ------------------------------------------------------------ 
   * nativeWrapper()
   * ------------------------------------------------------------ */

  virtual int nativeWrapper(Node *n) {
    //   return Language::nativeWrapper(n);
    String *name     = Getattr(n,"sym:name");
    String *wrapname = Getattr(n,"wrap:name");

    if (!addSymbol(wrapname,n)) return SWIG_ERROR;

    add_method(n, name, wrapname,0);
    return SWIG_OK;
  }  

  /* ------------------------------------------------------------
   * enumDeclaration()
   * ------------------------------------------------------------ */
  
  virtual int enumDeclaration(Node *n) {
    return Language::enumDeclaration(n);
  }

  /* ------------------------------------------------------------
   * enumvalueDeclaration()
   * ------------------------------------------------------------ */
   
  virtual int enumvalueDeclaration(Node *n) {
    return Language::enumvalueDeclaration(n);
  }

  /* ------------------------------------------------------------
   * classDeclaration()
   * ------------------------------------------------------------ */

  virtual int classDeclaration(Node *n) {
    return Language::classDeclaration(n);
  }
  
  /* ------------------------------------------------------------
   * classHandler()
   * ------------------------------------------------------------ */

  virtual int classHandler(Node *n) {

    String *name = Getattr(n, "name");
    String *symname = Getattr(n, "sym:name");
    if (!addSymbol(symname, n))
      return SWIG_ERROR;
      
    PrefixPlusUnderscore = NewStringf("%s_", getClassPrefix());

    Printv(f_init, "start_new_program();\n", "ADD_STORAGE(swig_object_wrapper);\n", NULL);

    /* Handle inheritance */
    List *baselist = Getattr(n,"bases");
    if (baselist && Len(baselist) > 0) {
      Node *base = Firstitem(baselist);
      while (base) {
        char *basename = Char(Getattr(base,"name"));
        if (SwigType_istemplate(basename)) {
          basename = Char(SwigType_namestr(basename));
        }
        SwigType *basetype = NewString(basename);
        SwigType_add_pointer(basetype);
        SwigType_remember(basetype);
        String *basemangle = SwigType_manglestr(basetype);
        Printf(f_init, "low_inherit((struct program *) SWIGTYPE%s->clientdata, 0, 0, 0, 0, 0);\n", basemangle);
	Delete(basemangle);
	Delete(basetype);
        base = Nextitem(baselist);
      }
    }
        
    Language::classHandler(n);
    
    /* Accessors for member variables */
    List *membervariables = Getattr(n,"membervariables");
    if (membervariables && Len(membervariables) > 0) {
      membervariableAccessors(membervariables);
    }
    
    /* Done, close the class */
    Printf(f_init, "add_program_constant(\"%s\", pr = end_program(), 0);\n", symname);
    
    SwigType *tt = NewString(symname);
    SwigType_add_pointer(tt);
    SwigType_remember(tt);
    String *tm = SwigType_manglestr(tt);
    Printf(f_init, "SWIG_TypeClientData(SWIGTYPE%s, (void *) pr);\n", tm);
    Delete(tm);
    Delete(tt);
    
    Delete(PrefixPlusUnderscore); PrefixPlusUnderscore = 0;

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberfunctionHandler()
   *
   * Method for adding C++ member function
   * ------------------------------------------------------------ */

  virtual int memberfunctionHandler(Node *n) {
    current = MEMBER_FUNC;
    Language::memberfunctionHandler(n);
    current = NO_CPP;
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constructorHandler()
   *
   * Method for adding C++ member constructor
   * ------------------------------------------------------------ */

  virtual int constructorHandler(Node *n) {
    current = CONSTRUCTOR;
    Language::constructorHandler(n);
    current = NO_CPP;
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * destructorHandler()
   * ------------------------------------------------------------ */

  virtual int destructorHandler(Node *n) {
    current = DESTRUCTOR;
    Language::destructorHandler(n);
    current = NO_CPP;
    return SWIG_OK;
  }
  
  /* ------------------------------------------------------------
   * membervariableAccessors()
   * ------------------------------------------------------------ */

  void membervariableAccessors(List *membervariables) {
    String *name;
    String *symname;
    SwigType *type;
    ParmList *parms;
    Node *n;
    int need_setter;
    String *funcname;
    
    /* If at least one of them is mutable, we need a setter */
    need_setter = 0;
    n = Firstitem(membervariables);
    while (n) {
      if (!Getattr(n, "feature:immutable")) {
        need_setter = 1;
	break;
      }
      n = Nextitem(membervariables);
    }
    
    /* Create a function to set the values of the (mutable) variables */
    if (need_setter) {
      Wrapper *wrapper = NewWrapper();
      String *setter = Swig_name_member(getClassPrefix(), (char *) "`->=");
      String *wname = Swig_name_wrapper(setter);
      Printv(wrapper->def, "static void ", wname, "(INT32 args) {", NULL);
      Printf(wrapper->locals, "char *name = (char *) STR0(sp[0-args].u.string);\n");
      
      n = Firstitem(membervariables);
      while (n) {
	if (!Getattr(n, "feature:immutable")) {
	  name = Getattr(n, "name");
	  funcname = Swig_name_wrapper(Swig_name_set(Swig_name_member(getClassPrefix(), name)));
	  Printf(wrapper->code, "if (!strcmp(name, \"%s\")) {\n", name);
	  Printf(wrapper->code, "stack_dup();\n");
	  Printf(wrapper->code, "stack_unlink(args);\n");
	  Printf(wrapper->code, "%s(1);\n", funcname);
	  Printf(wrapper->code, "return;\n");
	  Printf(wrapper->code, "}\n");
	  Delete(funcname);
	}
	n = Nextitem(membervariables);
      }

      /* Close the function */
      Printf(wrapper->code, "pop_n_elems(args);\n");
      Printf(wrapper->code, "}\n");

      /* Dump wrapper code to the output file */
      Wrapper_print(wrapper, f_wrappers);
      
      /* Register it with Pike */
      String *description = NewString("tStr tFloat, tVoid");
      add_method(Firstitem(membervariables), "`->=", wname, description);
      Delete(description);

      /* Clean up */
      Delete(wname);
      Delete(setter);
      DelWrapper(wrapper);
    }
    
    /* Create a function to get the values of the (mutable) variables */
    Wrapper *wrapper = NewWrapper();
    String *getter = Swig_name_member(getClassPrefix(), (char *) "`->");
    String *wname = Swig_name_wrapper(getter);
    Printv(wrapper->def, "static void ", wname, "(INT32 args) {", NULL);
    Printf(wrapper->locals, "char *name = (char *) STR0(sp[0-args].u.string);\n");

    n = Firstitem(membervariables);
    while (n) {
      name = Getattr(n, "name");
      funcname = Swig_name_wrapper(Swig_name_get(Swig_name_member(getClassPrefix(), name)));
      Printf(wrapper->code, "if (!strcmp(name, \"%s\")) {\n", name);
      Printf(wrapper->code, "%s(args);\n", funcname);
      Printf(wrapper->code, "return;\n");
      Printf(wrapper->code, "}\n");
      Delete(funcname);
      n = Nextitem(membervariables);
    }

    /* Close the function */
    Printf(wrapper->code, "pop_n_elems(args);\n");
    Printf(wrapper->code, "}\n");

    /* Dump wrapper code to the output file */
    Wrapper_print(wrapper, f_wrappers);
    
    /* Register it with Pike */
    String *description = NewString("tStr, tMix");
    add_method(Firstitem(membervariables), "`->", wname, description);
    Delete(description);
    
    /* Clean up */
    Delete(wname);
    Delete(getter);
    DelWrapper(wrapper);
  }

  /* ------------------------------------------------------------
   * membervariableHandler()
   * ------------------------------------------------------------ */

  virtual int membervariableHandler(Node *n) {
    List *membervariables = Getattr(getCurrentClass(),"membervariables");
    if (!membervariables) {
      membervariables = NewList();
      Setattr(getCurrentClass(),"membervariables",membervariables);
    }
    Append(membervariables,n);
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

  virtual int staticmemberfunctionHandler(Node *n) {
    current = STATIC_FUNC;
    Language::staticmemberfunctionHandler(n);
    current = NO_CPP;
    return SWIG_OK;
  }
  
  /* ------------------------------------------------------------
   * memberconstantHandler()
   *
   * Create a C++ constant
   * ------------------------------------------------------------ */

  virtual int memberconstantHandler(Node *n) {
    current = CLASS_CONST;
    constantWrapper(n);
    current = NO_CPP;
    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * staticmembervariableHandler()
   * --------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {
    current = STATIC_VAR;
    Language::staticmembervariableHandler(n);
    current = NO_CPP;
    return SWIG_OK;
  }
};

/* -----------------------------------------------------------------------------
 * swig_pike()    - Instantiate module
 * ----------------------------------------------------------------------------- */

extern "C" Language *
swig_pike(void) {
  return new PIKE();
}

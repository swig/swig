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
	  printf("%s\n", SWIG_RUBY_RUNTIME);
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
    return Language::importDirective(n);
  }

  /* ------------------------------------------------------------
   * add_method()
   * ------------------------------------------------------------ */

  void add_method(Node *n, String *name, String *function, String *description) {
    Printf(f_init, "ADD_FUNCTION(\"%s\", %s, tFunc(%s), 0);\n", name, function, description);
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

    char wname[256];
    strcpy(wname,Char(Swig_name_wrapper(iname)));
    if (overname) {
      strcat(wname,Char(overname));
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
      
      /* Look for an input typemap */
      sprintf(source, "sp[%d-args]", i);
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

    /* Now register the function with the interpreter.   */
    if (!Getattr(n,"sym:overloaded")) {
      add_method(n, iname, wname, description);
    } else {
      Setattr(n,"wrap:name", wname);
      if (!Getattr(n,"sym:nextSibling")) {
	dispatchFunction(n);
      }
    }

    Delete(cleanup);
    Delete(outarg);
    Delete(description);
    DelWrapper(f);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * dispatchFunction()
   * ------------------------------------------------------------ */

  void dispatchFunction(Node *n) {
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
    return Language::nativeWrapper(n);
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

    Printv(f_init, "start_new_program();\n", "ADD_STORAGE(swig_object_wrapper);\n", NULL);
    Language::classHandler(n);
    Printf(f_init, "add_program_constant(\"%s\", pr = end_program(), 0);\n", symname);
    
    SwigType *tt = NewString(symname);
    SwigType_add_pointer(tt);
    SwigType_remember(tt);
    String *tm = SwigType_manglestr(tt);
    Printf(f_init, "SWIG_TypeClientData(SWIGTYPE%s, (void *) pr);\n", tm);
    Delete(tm);
    Delete(tt);    

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int memberfunctionHandler(Node *n) {
    return Language::memberfunctionHandler(n);
  }

  /* ------------------------------------------------------------
   * constructorHandler()
   * ------------------------------------------------------------ */

  virtual int constructorHandler(Node *n) {
    return Language::constructorHandler(n);
  }

  /* ------------------------------------------------------------
   * destructorHandler()
   * ------------------------------------------------------------ */

  virtual int destructorHandler(Node *n) {
    return Language::destructorHandler(n);
  }

  /* ------------------------------------------------------------
   * membervariableHandler()
   * ------------------------------------------------------------ */

  virtual int membervariableHandler(Node *n) {
    return Language::membervariableHandler(n);
  }

  /* ------------------------------------------------------------
   * memberconstantHandler()
   * ------------------------------------------------------------ */

  virtual int memberconstantHandler(Node *n) {
    return constantWrapper(n);
  }
};

/* -----------------------------------------------------------------------------
 * swig_pike()    - Instantiate module
 * ----------------------------------------------------------------------------- */

extern "C" Language *
swig_pike(void) {
  return new PIKE();
}

/* -----------------------------------------------------------------------------
 * python.cxx
 *
 *     Python module.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "swig11.h"
#include "python.h"
#ifndef MACSWIG
#include "swigconfig.h"
#endif

static  String       *const_code = 0;
static  String       *shadow_methods = 0;
static  String       *module = 0;
static  String       *interface = 0;
static  String       *global_name = 0;
static  int           shadow = 0;
static  int           use_kw = 0;

static  File         *f_runtime = 0;
static  File         *f_header = 0;
static  File         *f_wrappers = 0;
static  File         *f_init = 0;
static  File         *f_shadow = 0;

static  Hash         *hash;
static  String       *import_file = 0;
static  List         *import_stack = 0;
static  String       *methods;
static  char         *class_name;

static char *usage = (char *)"\
Python Options (available with -python)\n\
     -ldflags        - Print runtime libraries to link with\n\
     -globals name   - Set name used to access C global variable ('cvar' by default).\n\
     -interface name - Set the lib name\n\
     -keyword        - Use keyword arguments\n\
     -shadow         - Generate shadow classes. \n\n";

/* -----------------------------------------------------------------------------
 * PYTHON::main()
 * ----------------------------------------------------------------------------- */
void
PYTHON::main(int argc, char *argv[]) {

  SWIG_library_directory("python");

  for (int i = 1; i < argc; i++) {
      if (argv[i]) {
          if(strcmp(argv[i],"-interface") == 0) {
            if (argv[i+1]) {
              interface = NewString(argv[i+1]);
              Swig_mark_arg(i);
              Swig_mark_arg(i+1);
              i++;
            } else {
              Swig_arg_error();
            }
	  /* end added */
	  } else if (strcmp(argv[i],"-globals") == 0) {
	    if (argv[i+1]) {
	      global_name = NewString(argv[i+1]);
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i++;
	    } else {
	      Swig_arg_error();
	    }
	  } else if (strcmp(argv[i],"-shadow") == 0) {
	    shadow = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-keyword") == 0) {
	    use_kw = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-help") == 0) {
	    fputs(usage,stderr);
	  } else if (strcmp (argv[i], "-ldflags") == 0) {
	    printf("%s\n", SWIG_PYTHON_RUNTIME);
	    SWIG_exit (EXIT_SUCCESS);
	  }
      }
  }
  if (!global_name) global_name = NewString("cvar");
  Preprocessor_define((void *) "SWIGPYTHON", 0);
  SWIG_typemap_lang("python");
  SWIG_config_file("python.swg");
}

/* -----------------------------------------------------------------------------
 * PYTHON::top()
 * ----------------------------------------------------------------------------- */
int
PYTHON::top(Node *n) {

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

  hash           = NewHash();
  const_code     = NewString("");
  shadow_methods = NewString("");
  methods        = NewString("");
  import_stack   = NewList();

  Swig_banner(f_runtime);

  Printf(f_runtime,"#define SWIGPYTHON\n");
  if (NoInclude)
    Printf(f_runtime,"#define SWIG_NOINCLUDE\n");

  /* Set module name */
  module = Copy(Getattr(n,"name"));

  char  filen[256];

  /* If shadow classing is enabled, we're going to change the module name to "modulec" */
  if (shadow) {
    sprintf(filen,"%s%s.py", Swig_file_dirname(outfile), Char(module));
    // If we don't have an interface then change the module name X to Xc
    if (interface) module = interface;
    else Append(module,"c");
    if ((f_shadow = NewFile(filen,"w")) == 0) {
      Printf(stderr,"Unable to open %s\n", filen);
      SWIG_exit (EXIT_FAILURE);
    }
    Swig_register_filebyname("shadow",f_shadow);
    Printf(f_shadow,"# This file was created automatically by SWIG.\n");
    Printf(f_shadow,"import %s\n", module);

    // Include some information in the code
    Printf(f_header,"\n/*-----------------------------------------------\n              @(target):= %s.so\n\
  ------------------------------------------------*/\n", module);

  }

  Printf(f_header,"#define SWIG_init    init%s\n\n", module);
  Printf(f_header,"#define SWIG_name    \"%s\"\n", module);

  Printf(f_wrappers,"#ifdef __cplusplus\n");
  Printf(f_wrappers,"extern \"C\" {\n");
  Printf(f_wrappers,"#endif\n");
  Printf(const_code,"static swig_const_info swig_const_table[] = {\n");
  Printf(methods,"static PyMethodDef SwigMethods[] = {\n");

  /* emit code */
  Language::top(n);

  /* Close language module */
  Printf(methods,"\t { NULL, NULL }\n");
  Printf(methods,"};\n");
  Printf(f_wrappers,"%s\n",methods);
  Printf(f_wrappers,"#ifdef __cplusplus\n");
  Printf(f_wrappers,"}\n");
  Printf(f_wrappers,"#endif\n");

  SwigType_emit_type_table(f_runtime,f_wrappers);

  Printf(const_code, "{0}};\n");
  Printf(f_wrappers,"%s\n",const_code);
  Printf(f_init,"}\n");

  if (shadow) {
    Close(f_shadow);
    Delete(f_shadow);
  }

  /* Close all of the files */
  Dump(f_header,f_runtime);
  Dump(f_wrappers,f_runtime);
  Wrapper_pretty_print(f_init,f_runtime);
  Delete(f_header);
  Delete(f_wrappers);
  Delete(f_init);
  Close(f_runtime);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * PYTHON::import_start(char *modname)
 * ----------------------------------------------------------------------------- */

void
PYTHON::import_start(char *modname) {
  if (shadow) {
    Printf(f_shadow,"import %s\n", modname);
  }
  /* Save the old module */
  if (import_file) {
    Append(import_stack,import_file);
  }
  import_file = NewString(modname);
}

void 
PYTHON::import_end() {
  Delete(import_file);
  if (Len(import_stack)) {
    import_file = Copy(Getitem(import_stack,Len(import_stack)-1));
    Delitem(import_stack,Len(import_stack)-1);
  } else {
    import_file = 0;
  }
}

/* -----------------------------------------------------------------------------
 * PYTHON::add_method()
 * ----------------------------------------------------------------------------- */
void
PYTHON::add_method(char *name, char *function, int kw) {
  if (!kw)
    Printf(methods,"\t { (char *)\"%s\", %s, METH_VARARGS },\n", name, function);
  else
    Printf(methods,"\t { (char *)\"%s\", (PyCFunction) %s, METH_VARARGS | METH_KEYWORDS },\n", name, function);
}

/* -----------------------------------------------------------------------------
 * PYTHON::functionWrapper()
 * ----------------------------------------------------------------------------- */
int
PYTHON::functionWrapper(Node *n) {
  
  char   *name  = GetChar(n,"name");
  char   *iname = GetChar(n,"sym:name");
  SwigType *d   = Getattr(n,"type");
  ParmList *l   = Getattr(n,"parms");

  Parm    *p;
  int     i;
  char    wname[256];
  char    source[64];
  Wrapper *f;
  String *parse_args;
  String *arglist;
  String *get_pointers;
  String *cleanup;
  String *outarg;
  String *kwargs;
  String *tm;

  int     num_required;
  int     num_arguments;
  
  f = NewWrapper();
  parse_args   = NewString("");
  arglist      = NewString("");
  get_pointers = NewString("");
  cleanup      = NewString("");
  outarg       = NewString("");
  kwargs       = NewString("");

  strcpy(wname,Char(Swig_name_wrapper(iname)));

  if (!use_kw) {
    Printv(f->def,
	   "static PyObject *", wname,
	   "(PyObject *self, PyObject *args) {",
	   0);
  } else {
    Printv(f->def,
	   "static PyObject *", wname,
	   "(PyObject *self, PyObject *args, PyObject *kwargs) {",
	   0);
  }

  Wrapper_add_local(f,"resultobj", "PyObject *resultobj");

  /* Write code to extract function parameters. */
  emit_args(d, l, f);

  /* Attach the standard typemaps */
  emit_attach_parmmaps(l,f);

  if (!use_kw) {
    Printf(parse_args,"    if(!PyArg_ParseTuple(args,(char *)\"");
  } else {
    Printf(parse_args,"    if(!PyArg_ParseTupleAndKeywords(args,kwargs,(char *)\"");
    Printf(arglist,",kwnames");
  }

  /* Get number of required and total arguments */
  num_arguments = emit_num_arguments(l);
  num_required  = emit_num_required(l);

  /* Generate code for argument marshalling */

  Printf(kwargs,"{ ");  
  for (i = 0, p=l; i < num_arguments; i++) {
    
    while (Getattr(p,"tmap:ignore")) {
      p = Getattr(p,"tmap:ignore:next");
    }

    SwigType *pt = Getattr(p,"type");
    String   *pn = Getattr(p,"name");
    String   *ln = Getattr(p,"lname");

    sprintf(source,"obj%d",i);

    Putc(',',arglist);
    if (i == num_required) Putc('|', parse_args);    /* Optional argument separator */

    /* Keyword argument handling */
    if (Len(pn)) {
      Printf(kwargs,"\"%s\",", pn);
    } else {
      Printf(kwargs,"\"arg%d\",", i+1);
    }

    /* Look for an input typemap */
    if ((tm = Getattr(p,"tmap:in"))) {
      String *parse = Getattr(p,"tmap:in:parse");
      if (!parse) {
	Replaceall(tm,"$source",source);
	Replaceall(tm,"$target",ln);
	Replaceall(tm,"$input", source);
	Setattr(p,"emit:input", source);   /* Save the location of the object */
	Putc('O',parse_args);
	Wrapper_add_localv(f, source, "PyObject *",source, " = 0", 0);
	Printf(arglist,"&%s",source);
	if (i >= num_required)
	  Printv(get_pointers, "if (", source, ")\n", 0);
	Printv(get_pointers,tm,"\n", 0);
      } else {
	Printf(parse_args,"%s",parse);
	Printf(arglist,"&%s", ln);
      }
      p = Getattr(p,"tmap:in:next");
      continue;
    } else {
      Printf(stderr,"%s : Line %d. Unable to use type %s as a function argument.\n",input_file, line_number, SwigType_str(pt,0));
      break;
    }
    p = nextSibling(p);
  }

  /* finish argument marshalling */
  Printf(kwargs," NULL }");
  if (use_kw) {
    Printv(f->locals,tab4, "char *kwnames[] = ", kwargs, ";\n", 0);
  }

  Printf(parse_args,":%s\"", iname);
  Printv(parse_args,
	 arglist, ")) return NULL;\n",
	 0);

  /* Now piece together the first part of the wrapper function */
  Printv(f->code, parse_args, get_pointers, 0);

  /* Insert constraint checking code */
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:check"))) {
      Replaceall(tm,"$target",Getattr(p,"lname"));
      Printv(f->code,tm,"\n",0);
      p = Getattr(p,"tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }
  
  /* Insert cleanup code */
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:freearg"))) {
      Replaceall(tm,"$source",Getattr(p,"lname"));
      Printv(cleanup,tm,"\n",0);
      p = Getattr(p,"tmap:freearg:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Insert argument output code */
  for (p = l; p;) {
    if ((tm = Getattr(p,"tmap:argout"))) {
      Replaceall(tm,"$source",Getattr(p,"lname"));
      Replaceall(tm,"$target","resultobj");
      Replaceall(tm,"$arg",Getattr(p,"emit:input"));
      Replaceall(tm,"$input",Getattr(p,"emit:input"));
      Printv(outarg,tm,"\n",0);
      p = Getattr(p,"tmap:argout:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Emit the function call */
  emit_action(n,f);

  /* This part below still needs cleanup */

  /* Return the function value */
  if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
    Replaceall(tm,"$source", "result");
    Replaceall(tm,"$target", "resultobj");
    Replaceall(tm,"$result", "resultobj");
    Printf(f->code,"%s\n", tm);
  } else {
    Printf(stderr,"%s: Line %d. Unable to use return type %s in function %s.\n", input_file, line_number, SwigType_str(d,0), name);
  }

  /* Output argument output code */
  Printv(f->code,outarg,0);

  /* Output cleanup code */
  Printv(f->code,cleanup,0);

  /* Look to see if there is any newfree cleanup code */
  if (NewObject) {
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

  Printf(f->code,"    return resultobj;\n}\n");

  /* Substitute the cleanup code */
  Replaceall(f->code,"$cleanup",cleanup);

  /* Substitute the function name */
  Replaceall(f->code,"$symname",iname);
  Replaceall(f->code,"$result","resultobj");

  /* Dump the function out */
  Wrapper_print(f,f_wrappers);

  /* Now register the function with the interpreter.   */
  add_method(iname, wname, use_kw);

  /* Create a shadow for this function (if enabled and not in a member function) */
  if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
    Printv(f_shadow,iname, " = ", module, ".", iname, "\n\n", 0);
  }

  Delete(parse_args);
  Delete(arglist);
  Delete(get_pointers);
  Delete(cleanup);
  Delete(outarg);
  Delete(kwargs);
  DelWrapper(f);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * PYTHON::variableWrapper()
 * ----------------------------------------------------------------------------- */
int
PYTHON::variableWrapper(Node *n) {

  char *name  = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *t = Getattr(n,"type");

    char   *wname;
    static int have_globals = 0;
    String  *tm;
    Wrapper *getf, *setf;

    getf = NewWrapper();
    setf = NewWrapper();

    /* If this is our first call, add the globals variable to the
       Python dictionary. */

    if (!have_globals) {
      Printf(f_init,"\t PyDict_SetItemString(d,(char*)\"%s\", SWIG_globals);\n",global_name);
      have_globals=1;
      if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
	Printv(f_shadow, global_name, " = ", module, ".", global_name, "\n", 0);
      }
    }

    wname = Char(Swig_name_wrapper(name));

    /* Create a function for setting the value of the variable */

    Printf(setf->def,"static int %s_set(PyObject *_val) {", wname);
    if (!ReadOnly) {
      if ((tm = Swig_typemap_lookup_new("varin",n,name,0))) {
	Replaceall(tm,"$source","_val");
	Replaceall(tm,"$target",name);
	Replaceall(tm,"$input","_val");
	Printf(setf->code,"%s\n",tm);
	Delete(tm);
      } else {
	Printf(stderr,"%s : Line %d. Unable to link with type %s.\n", input_file, line_number, SwigType_str(t,0));
      }
      Printf(setf->code,"    return 0;\n");
    } else {
      /* Is a readonly variable.  Issue an error */
      Printv(setf->code,
	     tab4, "PyErr_SetString(PyExc_TypeError,\"Variable ", iname,
	     " is read-only.\");\n",
	     tab4, "return 1;\n",
	     0);
    }

    Printf(setf->code,"}\n");
    Wrapper_print(setf,f_wrappers);

    /* Create a function for getting the value of a variable */
    Printf(getf->def,"static PyObject *%s_get() {", wname);
    Wrapper_add_local(getf,"pyobj", "PyObject *pyobj");
    if ((tm = Swig_typemap_lookup_new("varout",n,name,0))) {
      Replaceall(tm,"$source",name);
      Replaceall(tm,"$target","pyobj");
      Replaceall(tm,"$result","pyobj");
      Printf(getf->code,"%s\n", tm);
    } else {
      Printf(stderr,"Unable to link with type %s\n", SwigType_str(t,0));
    }
    
    Printf(getf->code,"    return pyobj;\n}\n");
    Wrapper_print(getf,f_wrappers);

    /* Now add this to the variable linking mechanism */
    Printf(f_init,"\t SWIG_addvarlink(SWIG_globals,(char*)\"%s\",%s_get, %s_set);\n", iname, wname, wname);

    DelWrapper(setf);
    DelWrapper(getf);
    return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * PYTHON::constantWrapper()
 * ----------------------------------------------------------------------------- */
int
PYTHON::constantWrapper(Node *n) {
  char *name      = GetChar(n,"name");
  char *iname     = GetChar(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  String   *value = Getattr(n,"value");
  String  *tm;
  int     have_tm = 0;

  /* Special hook for member pointer */
  if (SwigType_type(type) == T_MPOINTER) {
    String *wname = Swig_name_wrapper(iname);
    Printf(f_wrappers, "static %s = %s;\n", SwigType_str(type,wname), value);
    value = Char(wname);
  }
  if ((tm = Swig_typemap_lookup_new("consttab",n,name,0))) {
    Replaceall(tm,"$source",value);
    Replaceall(tm,"$target",name);
    Replaceall(tm,"$value", value);
    Printf(const_code,"%s,\n", tm);
    have_tm = 1;
  }
  if ((tm = Swig_typemap_lookup_new("constcode", n, name, 0))) {
    Replaceall(tm,"$source",value);
    Replaceall(tm,"$target",name);
    Replaceall(tm,"$value",value);
    Printf(f_init, "%s\n", tm);
    have_tm = 1;
  }
  if (!have_tm) {
    Printf(stderr,"%s : Line %d. Unsupported constant value.\n", input_file, line_number);
    return SWIG_NOWRAP;
  }
  if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
    Printv(f_shadow,iname, " = ", module, ".", iname, "\n", 0);
  }
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * PYTHON::add_native()
 * ----------------------------------------------------------------------------- */
void
PYTHON::add_native(char *name, char *funcname, SwigType *, ParmList *) {
  add_method(name, funcname,0);
  if (shadow) {
    Printv(f_shadow, name, " = ", module, ".", name, "\n\n", 0);
  }
}

/* -----------------------------------------------------------------------------
 * PYTHON::cpp_class_decl() - Register a class definition
 * ----------------------------------------------------------------------------- */
void
PYTHON::cpp_class_decl(char *name, char *rename, char *type) {
    String *stype;
    String *importname;
    if (shadow) {
      if ((import_file) && (!strchr(rename,'.'))) {
	importname = NewStringf("%s.%s", import_file, rename);
      } else {
	importname = NewString(rename);
      }
      stype = NewString(name);
      SwigType_add_pointer(stype);
      Setattr(hash,stype,importname);
      Delete(stype);
      Setattr(hash,name,importname);  /* Added */
      /* Printf(stdout,"cpp_class_decl: %s %s %s\n", name,importname,type); */
      /* Add full name of datatype to the hash table */
      if (strlen(type) > 0) {
	stype = NewStringf("%s %s", type, name);
	SwigType_add_pointer(stype);
	Setattr(hash,stype,importname);
	Delete(stype);
      }
    }
}

/* C++ Support + Shadow Classes */

static  String   *setattr = 0;
static  String   *getattr = 0;
static  String   *pyclass = 0;
static  String   *construct = 0;
static  String   *cinit = 0;
static  String   *additional = 0;
static  int       have_constructor;
static  int       have_destructor;
static  int       have_getattr;
static  int       have_setattr;
static  int       have_repr;
static  char     *real_classname;
static  String   *base_class = 0;

/* -----------------------------------------------------------------------------
 * PYTHON::cpp_open_class()
 * ----------------------------------------------------------------------------- */
void
PYTHON::cpp_open_class(char *classname, char *rname, char *ctype, int strip) {
  this->Language::cpp_open_class(classname, rname, ctype, strip);

  if (shadow) {
    /* Create new strings for building up a wrapper function */
    setattr   = NewString("");
    getattr   = NewString("");
    pyclass   = NewString("");
    construct = NewString("");
    cinit     = NewString("");
    additional= NewString("");
    base_class = 0;
    have_constructor = 0;
    have_destructor = 0;
    have_getattr = 0;
    have_setattr = 0;
    have_repr = 0;
    if (rname) {
      class_name = Swig_copy_string(rname);
    } else {
      class_name = Swig_copy_string(classname);
    }
  }

  real_classname = Swig_copy_string(classname);

  cpp_class_decl(real_classname,class_name,ctype);

  if (shadow) {
    Printv(setattr,
	   tab4, "def __setattr__(self,name,value):\n",
	   tab8, "if (name == \"this\") or (name == \"thisown\"): self.__dict__[name] = value; return\n",
	   tab8, "method = ", class_name, ".__setmethods__.get(name,None)\n",
	   tab8, "if method: return method(self,value)\n",
	   tab8, "self.__dict__[name] = value\n",
	   0);

    Printv(getattr, tab4, "def __getattr__(self,name):\n",
           tab8, "method = ", class_name, ".__getmethods__.get(name,None)\n",
	   tab8, "if method: return method(self)\n",
	   tab8, "raise AttributeError,name\n",
	   0);

    Printv(setattr, tab4, "__setmethods__.update({\n", 0);
    Printv(getattr, tab4, "__getmethods__.update({\n", 0);
  }
}

/* -----------------------------------------------------------------------------
 * PYTHON::memberfunctionHandler()
 * ----------------------------------------------------------------------------- */
int
PYTHON::memberfunctionHandler(Node *n) {
  char *symname = GetChar(n,"sym:name");
  int   oldshadow;

  /* Create the default member function */
  oldshadow = shadow;    /* Disable shadowing when wrapping member functions */
  if (shadow) shadow = shadow | PYSHADOW_MEMBER;
  Language::memberfunctionHandler(n);
  shadow = oldshadow;

  if (shadow) {
    if (strcmp(symname,"__repr__") == 0)
      have_repr = 1;

    if (use_kw) {
      Printv(pyclass,tab4, "def ", symname, "(*args, **kwargs): ", 0);
      Printv(pyclass, "return apply(", module, ".", Swig_name_member(class_name,symname), ",args, kwargs)\n", 0);
    } else {
      Printv(pyclass, tab4, "def ", symname, "(*args): ", 0);
      Printv(pyclass, "return apply(", module, ".", Swig_name_member(class_name,symname), ",args)\n",0);
    }
  }
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * PYTHON::constructorDeclaration()
 * ----------------------------------------------------------------------------- */
int
PYTHON::constructorHandler(Node *n) {
  char *symname = GetChar(n,"sym:name");
  int   oldshadow = shadow;

  if (shadow) shadow = shadow | PYSHADOW_MEMBER;
  Language::constructorHandler(n);
  shadow = oldshadow;

  if (shadow) {
    if (!have_constructor) {
      if (use_kw) {
	Printv(construct, tab4, "def __init__(self,*args,**kwargs):\n", 0);
	Printv(construct, tab8, "this = apply(", module, ".", Swig_name_construct(symname), ",args,kwargs)\n", 0);
      }  else {
	Printv(construct, tab4, "def __init__(self,*args):\n",0);
	Printv(construct, tab8, "this = apply(", module, ".", Swig_name_construct(symname), ",args)\n", 0);
      }
      Printv(construct,
	     tab8,"try: self.this = this.this; this.thisown=0\n",
	     tab8,"except AttributeError: self.this = this\n",0);
      
      Printv(construct, tab8, "self.thisown = 1\n", 0);
      have_constructor = 1;
    } else {
      /* Hmmm. We seem to be creating a different constructor.  We're just going to create a
	 function for it. */
      if (use_kw)
	Printv(additional, "def ", symname, "(*args,**kwargs):\n", 0);
      else
	Printv(additional, "def ", symname, "(*args):\n", 0);

      Printv(additional, tab4, "val = ", class_name, "Ptr(apply(", 0);
      if (use_kw)
	Printv(additional, module, ".", Swig_name_construct(symname), ",args,kwargs))\n", 0);
      else
	Printv(additional, module, ".", Swig_name_construct(symname), ",args))\n", 0);
      Printv(additional,tab4, "val.thisown = 1\n",
	     tab4, "return val\n\n", 0);
    }
  }
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * PYTHON::cpp_destructor()
 * ----------------------------------------------------------------------------- */
int
PYTHON::destructorHandler(Node *n) {
  char *symname = GetChar(n,"sym:name");
  int oldshadow = shadow;

  if (shadow) shadow = shadow | PYSHADOW_MEMBER;
  Language::destructorHandler(n);
  shadow = oldshadow;
  if (shadow) {
    Printv(pyclass, tab4, "def __del__(self,", module, "=", module, "):\n", 0);
    Printv(pyclass, tab8, "if getattr(self,'thisown',0):\n",
	   tab8, tab4, module, ".", Swig_name_destroy(symname), "(self)\n", 0);

    have_destructor = 1;
  }
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * PYTHON::cpp_close_class() - Close a class and write wrappers
 * ----------------------------------------------------------------------------- */
void
PYTHON::cpp_close_class() {
  String    *ptrclass;
  String    *repr;
  String    *attrpatch;

  /* Generate a class registration function */

  ptrclass = NewString("");
  repr =  NewString("");
  attrpatch = NewString("");
  if (shadow) {
    {
      SwigType  *ct = NewStringf("p.%s", real_classname);
      SwigType_remember(ct);
      Printv(f_wrappers,
	     "static PyObject * ", class_name, "_swigregister(PyObject *self, PyObject *args) {\n",
	     tab4, "PyObject *obj;\n",
	     tab4, "if (!PyArg_ParseTuple(args,(char*)\"O\", &obj)) return NULL;\n",
	     tab4, "SWIG_TypeClientData(SWIGTYPE", SwigType_manglestr(ct),", obj);\n",
	     tab4, "Py_INCREF(obj);\n",
	     tab4, "return Py_BuildValue(\"\");\n",
	     "}\n",0);
      String *cname = NewStringf("%s_swigregister", class_name);
      add_method(Char(cname), Char(cname), 0);
      Delete(cname);
      Delete(ct);
    }
    if (!have_constructor) {
      Printv(construct,tab4,"def __init__(self): raise RuntimeError, \"No constructor defined\"\n",0);
    }
    /* First, build the pointer base class */
    if (base_class) {
      Printv(ptrclass, "class ", class_name, "(", base_class, "):\n", 0);
    } else {
      Printv(ptrclass, "class ", class_name, ":\n", 0);
    }
    Printv(getattr, tab4, "})\n", 0);
    Printv(setattr, tab4, "})\n", 0);
    Printv(ptrclass,cinit,construct,"\n",0);
    Printv(f_shadow,ptrclass,pyclass,0);
    Printv(f_shadow,tab4,"__setmethods__ = {}\n",0);
    Printf(f_shadow,"%sfor _s in [%s]: __setmethods__.update(_s.__setmethods__)\n",tab4,base_class);
    Printv(f_shadow,tab4,"__getmethods__ = {}\n",0);
    Printf(f_shadow,"%sfor _s in [%s]: __getmethods__.update(_s.__getmethods__)\n",tab4,base_class);
    if (have_setattr) {
      Printv(f_shadow, setattr, 0);
    }
    if (have_getattr) {
      Printv(f_shadow,getattr,0);
    }
    if (!have_repr) {
      /* Supply a repr method for this class  */
      Printv(repr,
	     tab4, "def __repr__(self):\n",
	     tab8, "return \"<C ", class_name," instance at %s>\" % (self.this,)\n",
	     0);

      Printv(f_shadow,repr,0);
    }
    /* Now build the real class with a normal constructor */
    Printv(f_shadow,
	   "class ", class_name, "Ptr(", class_name, "):\n",
	   tab4, "def __init__(self,this):\n",
	   tab8,"try: self.this = this.this; self.thisown = getattr(this,'thisown',0); this.thisown=0\n",
	   tab8,"except AttributeError: self.this = this; self.thisown = 0\n"
	   tab8, "self.__class__ = ", class_name, "\n",
	   "\n", additional, "\n",
	   0);

    Printf(f_shadow,"%s.%s_swigregister(%s)\n", module, class_name, class_name,0);
    Delete(pyclass);
    Delete(setattr);
    Delete(getattr);
    Delete(additional);
  }
  Delete(ptrclass);
  Delete(repr);
}

/* -----------------------------------------------------------------------------
 * PYTHON::cpp_inherit() - Handle inheritance
 * ----------------------------------------------------------------------------- */
void
PYTHON::cpp_inherit(char **baseclass,int) {
  char *bc;
  int   i = 0, first_base = 0;

  if (!shadow) {
    this->Language::cpp_inherit(baseclass);
    return;
  }

  /* We'll inherit variables and constants, but not methods */
  this->Language::cpp_inherit(baseclass, 0);

  if (!baseclass) return;
  base_class = NewString("");

  /* Now tell the Python module that we're inheriting from a base class */
  while (baseclass[i]) {
    String *bs = NewString(baseclass[i]);
    SwigType_add_pointer(bs);
    bc = GetChar(hash,bs);
    if (bc) {
      if (first_base) Putc(',',base_class);
      Printv(base_class,bc,0);
      first_base = 1;
    }
    Delete(bs);
    i++;
  }
  if (!first_base) {
    Delete(base_class);
    base_class = 0;
  }
}

/* -----------------------------------------------------------------------------
 * PYTHON::membervariableHandler()
 * ----------------------------------------------------------------------------- */
int
PYTHON::membervariableHandler(Node *n) {
  char *symname = GetChar(n,"sym:name");

  int   oldshadow = shadow;
  if (shadow) shadow = shadow | PYSHADOW_MEMBER;
  Language::membervariableHandler(n);
  shadow = oldshadow;

  if (shadow) {
    have_getattr = 1;
    if (!ReadOnly) {
      have_setattr = 1;
      Printv(setattr, tab8, "\"", symname, "\" : ", module, ".", Swig_name_set(Swig_name_member(class_name,symname)), ",\n", 0);
    }
    Printv(getattr, tab8, "\"", symname, "\" : ", module, ".", Swig_name_get(Swig_name_member(class_name,symname)),",\n", 0);
  }
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * PYTHON::memberconstantHandler()
 * ----------------------------------------------------------------------------- */
int
PYTHON::memberconstantHandler(Node *n) {
  char *symname = GetChar(n,"sym:name");
  int   oldshadow = shadow;
  if (shadow) shadow = shadow | PYSHADOW_MEMBER;
  Language::memberconstantHandler(n);
  shadow = oldshadow;

  if (shadow) {
     Printv(cinit, tab4, symname, " = ", module, ".", Swig_name_member(class_name,symname), "\n", 0);
  }
  return SWIG_OK;
}

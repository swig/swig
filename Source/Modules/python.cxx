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

char cvsroot_python_cxx[] = "$Header$";

#include "swigmod.h"

#ifndef MACSWIG
#include "swigconfig.h"
#endif

#include <ctype.h>

#define PYSHADOW_MEMBER  0x2

static  String       *const_code = 0;
static  String       *shadow_methods = 0;
static  String       *module = 0;
static  String       *mainmodule = 0;
static  String       *interface = 0;
static  String       *global_name = 0;
static  int           shadow = 1;
static  int           use_kw = 0;

static  File         *f_runtime = 0;
static  File         *f_header = 0;
static  File         *f_wrappers = 0;
static  File         *f_init = 0;
static  File         *f_shadow = 0;
static  File         *f_shadow_stubs = 0;

static  String       *methods;
static  String       *class_name;
static  String       *shadow_indent = 0;
static  int           in_class = 0;
static  int           classic = 0;

/* C++ Support + Shadow Classes */

static  int       have_constructor;
static  int       have_repr;
static  String   *real_classname;

static const char *usage = (char *)"\
Python Options (available with -python)\n\
     -ldflags        - Print runtime libraries to link with\n\
     -globals name   - Set name used to access C global variable ('cvar' by default).\n\
     -interface name - Set the lib name\n\
     -keyword        - Use keyword arguments\n\
     -classic        - Use classic classes only\n\
     -noexcept       - No automatic exception handling.\n\
     -noproxy        - Don't generate proxy classes. \n\n";

class PYTHON : public Language {
public:

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */
  
  virtual void main(int argc, char *argv[]) {

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
	} else if ((strcmp(argv[i],"-shadow") == 0) || ((strcmp(argv[i],"-proxy") == 0))) {
	  shadow = 1;
	  Swig_mark_arg(i);
	} else if ((strcmp(argv[i],"-noproxy") == 0)) {
	  shadow = 0;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-keyword") == 0) {
	  use_kw = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-classic") == 0) {
	  classic = 1;
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
    Preprocessor_define("SWIGPYTHON 1", 0);
    SWIG_typemap_lang("python");
    SWIG_config_file("python.swg");
    allow_overloading();
  }


  /* ------------------------------------------------------------
   * top()
   * ------------------------------------------------------------ */

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

    const_code     = NewString("");
    shadow_methods = NewString("");
    methods        = NewString("");

    Swig_banner(f_runtime);

    Printf(f_runtime,"#define SWIGPYTHON\n");
    if (NoInclude)
      Printf(f_runtime,"#define SWIG_NOINCLUDE\n");

  /* Set module name */
    module = Copy(Getattr(n,"name"));
    mainmodule = Getattr(n,"name");

    char  filen[256];

    /* If shadow classing is enabled, we're going to change the module name to "_module" */
    if (shadow) {
      sprintf(filen,"%s%s.py", Swig_file_dirname(outfile), Char(module));
      // If we don't have an interface then change the module name X to _X
      if (interface) module = interface;
      else Insert(module,0,"_");
      if ((f_shadow = NewFile(filen,"w")) == 0) {
	Printf(stderr,"Unable to open %s\n", filen);
	SWIG_exit (EXIT_FAILURE);
      }
      f_shadow_stubs = NewString("");

      Swig_register_filebyname("shadow",f_shadow);
      Swig_register_filebyname("python",f_shadow);

      Printv(f_shadow,
	     "# This file was created automatically by SWIG.\n",
	     "# Don't modify this file, modify the SWIG interface instead.\n",
	     "# This file is compatible with both classic and new-style classes.\n",
	     NIL);

      Printf(f_shadow,"import %s\n", module);

      // Python-2.2 object hack


      Printv(f_shadow,
	     "def _swig_setattr(self,class_type,name,value):\n",
	     tab4, "if (name == \"this\"):\n",
	     tab4, tab4, "if isinstance(value, class_type):\n",
	     tab4, tab8, "self.__dict__[name] = value.this\n",
	     tab4, tab8, "if hasattr(value,\"thisown\"): self.__dict__[\"thisown\"] = value.thisown\n",
	     tab4, tab8, "del value.thisown\n",
	     tab4, tab8, "return\n",
	     //	   tab8, "if (name == \"this\") or (name == \"thisown\"): self.__dict__[name] = value; return\n",
	     tab4, "method = class_type.__swig_setmethods__.get(name,None)\n",
	     tab4, "if method: return method(self,value)\n",
	     tab4, "self.__dict__[name] = value\n\n",
	     NIL);

      Printv(f_shadow,
	     "def _swig_getattr(self,class_type,name):\n",
	     tab4, "method = class_type.__swig_getmethods__.get(name,None)\n",
	     tab4, "if method: return method(self)\n",
	     tab4, "raise AttributeError,name\n\n",
	     NIL);

      if (!classic) {
	Printv(f_shadow,
	       "import types\n",
	       "try:\n",
	       "    _object = types.ObjectType\n",
	       "    _newclass = 1\n",
	       "except AttributeError:\n",
	       "    class _object : pass\n",
	       "    _newclass = 0\n",
	       "\n\n",
	       NIL);
      }

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

    SwigType_emit_type_table(f_runtime,f_wrappers);

    Printf(const_code, "{0}};\n");
    Printf(f_wrappers,"%s\n",const_code);
    Printf(f_init,"}\n");

    Printf(f_wrappers,"#ifdef __cplusplus\n");
    Printf(f_wrappers,"}\n");
    Printf(f_wrappers,"#endif\n");

    if (shadow) {
      Printv(f_shadow, f_shadow_stubs, "\n",NIL);
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

  /* ------------------------------------------------------------
   * importDirective()
   * ------------------------------------------------------------ */

  virtual int importDirective(Node *n) {
    if (shadow) {
      String *modname = Getattr(n,"module");
      if (modname) {
	Printf(f_shadow,"import %s\n", modname);
      }
    }
    return Language::importDirective(n);
  }

  /* ------------------------------------------------------------
   * add_method()
   * ------------------------------------------------------------ */

  void add_method(String *name, String *function, int kw) {
    if (!kw)
      Printf(methods,"\t { (char *)\"%s\", %s, METH_VARARGS },\n", name, function);
    else
      Printf(methods,"\t { (char *)\"%s\", (PyCFunction) %s, METH_VARARGS | METH_KEYWORDS },\n", name, function);
  }
  
  /* ------------------------------------------------------------
   * functionWrapper()
   * ------------------------------------------------------------ */

  virtual int functionWrapper(Node *n) {
  
    String  *name  = Getattr(n,"name");
    String  *iname = Getattr(n,"sym:name");
    SwigType *d    = Getattr(n,"type");
    ParmList *l    = Getattr(n,"parms");

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
    String *overname = 0;

    int     num_required;
    int     num_arguments;
    int     varargs = 0;
    int     allow_kwargs = (use_kw || Getattr(n,"feature:kwargs")) ? 1 : 0;

    if (Getattr(n,"sym:overloaded")) {
      overname = Getattr(n,"sym:overname");
    } else {
      if (!addSymbol(iname,n)) return SWIG_ERROR;
    }

    f = NewWrapper();
    parse_args   = NewString("");
    arglist      = NewString("");
    get_pointers = NewString("");
    cleanup      = NewString("");
    outarg       = NewString("");
    kwargs       = NewString("");
    
    Wrapper_add_local(f,"resultobj", "PyObject *resultobj");

  /* Write code to extract function parameters. */
    emit_args(d, l, f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l,f);
    Setattr(n,"wrap:parms",l);
    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required  = emit_num_required(l);
    varargs = emit_isvarargs(l);

    strcpy(wname,Char(Swig_name_wrapper(iname)));
    if (overname) {
      strcat(wname,Char(overname));
    }

    if (!allow_kwargs || Getattr(n,"sym:overloaded")) {
      if (!varargs) {
	Printv(f->def,
	       "static PyObject *", wname,
	       "(PyObject *self, PyObject *args) {",
	       NIL);
      } else {
	Printv(f->def,
	       "static PyObject *", wname, "__varargs__", 
	       "(PyObject *self, PyObject *args, PyObject *varargs) {",
	       NIL);
      }
      if (allow_kwargs) {
	Swig_warning(WARN_LANG_OVERLOAD_KEYWORD, input_file, line_number,
		     "Can't use keyword arguments with overloaded functions.\n");
	allow_kwargs = 0;
      }
    } else {
      if (varargs) {
	Swig_warning(WARN_LANG_VARARGS_KEYWORD, input_file, line_number,
		     "Can't wrap varargs with keyword arguments enabled\n");
	varargs = 0;
      }
      Printv(f->def,
	     "static PyObject *", wname,
	     "(PyObject *self, PyObject *args, PyObject *kwargs) {",
	     NIL);
    }
    if (!allow_kwargs) {
      Printf(parse_args,"    if(!PyArg_ParseTuple(args,(char *)\"");
    } else {
      Printf(parse_args,"    if(!PyArg_ParseTupleAndKeywords(args,kwargs,(char *)\"");
      Printf(arglist,",kwnames");
    }

    /* Generate code for argument marshalling */

    Printf(kwargs,"{ ");  
    for (i = 0, p=l; i < num_arguments; i++) {
    
      while (checkAttribute(p,"tmap:in:numinputs","0")) {
	p = Getattr(p,"tmap:in:next");
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
	  
	  if (Getattr(p,"wrap:disown") || (Getattr(p,"tmap:in:disown"))) {
	    Replaceall(tm,"$disown","SWIG_POINTER_DISOWN");
	  } else {
	    Replaceall(tm,"$disown","0");
	  }

	  Putc('O',parse_args);
	  Wrapper_add_localv(f, source, "PyObject *",source, " = 0", NIL);
	  Printf(arglist,"&%s",source);
	  if (i >= num_required)
	    Printv(get_pointers, "if (", source, ") {\n", NIL);
	  Printv(get_pointers,tm,"\n", NIL);
	  if (i >= num_required)
	    Printv(get_pointers, "}\n", NIL);

	} else {
	  Printf(parse_args,"%s",parse);
	  Printf(arglist,"&%s", ln);
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

    /* finish argument marshalling */
    Printf(kwargs," NULL }");
    if (allow_kwargs) {
      Printv(f->locals,tab4, "char *kwnames[] = ", kwargs, ";\n", NIL);
    }

    Printf(parse_args,":%s\"", iname);
    Printv(parse_args,
	   arglist, ")) goto fail;\n",
	   NIL);

    /* Now piece together the first part of the wrapper function */
    Printv(f->code, parse_args, get_pointers, NIL);

    /* Check for trailing varargs */
    if (varargs) {
      if (p && (tm = Getattr(p,"tmap:in"))) {
	Replaceall(tm,"$input", "varargs");
	Printv(f->code,tm,"\n",NIL);
      }
    }

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

    /* Insert argument output code */
    for (p = l; p;) {
      if ((tm = Getattr(p,"tmap:argout"))) {
	Replaceall(tm,"$source",Getattr(p,"lname"));
	Replaceall(tm,"$target","resultobj");
	Replaceall(tm,"$arg",Getattr(p,"emit:input"));
	Replaceall(tm,"$input",Getattr(p,"emit:input"));
	Printv(outarg,tm,"\n",NIL);
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
      if (Getattr(n,"feature:new")) {
	Replaceall(tm,"$owner","1");
      } else {
	Replaceall(tm,"$owner","0");
      }
      Printf(f->code,"%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
		   "Unable to use return type %s in function %s.\n", SwigType_str(d,0), name);
    }

    /* Output argument output code */
    Printv(f->code,outarg,NIL);

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

    Printf(f->code,"    return resultobj;\n");

    /* Error handling code */

    Printf(f->code,"fail:\n");
    Printv(f->code,cleanup,NIL);
    Printf(f->code,"return NULL;\n");
    Printf(f->code,"}\n");

    /* Substitute the cleanup code */
    Replaceall(f->code,"$cleanup",cleanup);

    /* Substitute the function name */
    Replaceall(f->code,"$symname",iname);
    Replaceall(f->code,"$result","resultobj");

    /* Dump the function out */
    Wrapper_print(f,f_wrappers);

    /* If varargs.  Need to emit a varargs stub */
    if (varargs) {
      DelWrapper(f);
      f = NewWrapper();
      Printv(f->def,
	     "static PyObject *", wname,
	     "(PyObject *self, PyObject *args) {",
	     NIL);
      Wrapper_add_local(f,"resultobj", "PyObject *resultobj");
      Wrapper_add_local(f,"varargs", "PyObject *varargs");
      Wrapper_add_local(f,"newargs", "PyObject *newargs");
      Printf(f->code,"newargs = PyTuple_GetSlice(args,0,%d);\n", num_arguments);
      Printf(f->code,"varargs = PyTuple_GetSlice(args,%d,PyTuple_Size(args)+1);\n", num_arguments);
      Printf(f->code,"resultobj = %s__varargs__(self,newargs,varargs);\n", wname);
      Printf(f->code,"Py_XDECREF(newargs);\n");
      Printf(f->code,"Py_XDECREF(varargs);\n");
      Printf(f->code,"return resultobj;\n");
      Printf(f->code,"}\n");
      Wrapper_print(f,f_wrappers);
    }

    Setattr(n,"wrap:name", wname);

    /* Now register the function with the interpreter.   */
    if (!Getattr(n,"sym:overloaded")) {
      add_method(iname, wname, allow_kwargs);

      /* Create a shadow for this function (if enabled and not in a member function) */
      if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
	if (in_class) {
	  Printv(f_shadow_stubs,iname, " = ", module, ".", iname, "\n\n", NIL);
	} else {
	  Printv(f_shadow,iname, " = ", module, ".", iname, "\n\n", NIL);	  
	}
      }
    } else {
      if (!Getattr(n,"sym:nextSibling")) {
	dispatchFunction(n);
      }
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

  /* ------------------------------------------------------------
   * dispatchFunction()
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
	   "static PyObject *", wname,
	   "(PyObject *self, PyObject *args) {",
	   NIL);
    
    Wrapper_add_local(f,"argc","int argc");
    Printf(tmp,"PyObject *argv[%d]", maxargs+1);
    Wrapper_add_local(f,"argv",tmp);
    Wrapper_add_local(f,"ii","int ii");
    Printf(f->code,"argc = PyObject_Length(args);\n");
    Printf(f->code,"for (ii = 0; (ii < argc) && (ii < %d); ii++) {\n",maxargs);
    Printf(f->code,"argv[ii] = PyTuple_GetItem(args,ii);\n");
    Printf(f->code,"}\n");
    
    Replaceall(dispatch,"$args","self,args");
    Printv(f->code,dispatch,"\n",NIL);
    Printf(f->code,"PyErr_SetString(PyExc_TypeError,\"No matching function for overloaded '%s'\");\n", symname);
    Printf(f->code,"return NULL;\n");
    Printv(f->code,"}\n",NIL);
    Wrapper_print(f,f_wrappers);
    add_method(symname,wname,0);

    /* Create a shadow for this function (if enabled and not in a member function) */
    if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
      Printv(f_shadow_stubs,symname, " = ", module, ".", symname, "\n\n", NIL);
    }
    DelWrapper(f);
    Delete(dispatch);
    Delete(tmp);
    Delete(wname);
  }

  /* ------------------------------------------------------------
   * variableWrapper()
   * ------------------------------------------------------------ */

  virtual int variableWrapper(Node *n) {

    String *name  = Getattr(n,"name");
    String *iname = Getattr(n,"sym:name");
    SwigType *t = Getattr(n,"type");
    
    String *wname;
    static int have_globals = 0;
    String  *tm;
    Wrapper *getf, *setf;

    if (!addSymbol(iname,n)) return SWIG_ERROR;

    getf = NewWrapper();
    setf = NewWrapper();

   /* If this is our first call, add the globals variable to the
      Python dictionary. */

    if (!have_globals) {
      Printf(f_init,"\t PyDict_SetItemString(d,(char*)\"%s\", SWIG_globals);\n",global_name);
      have_globals=1;
      if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
	Printf(f_shadow_stubs,"%s = %s.%s\n", global_name, module, global_name);
      }
    }

    if ((shadow) && (SwigType_isconst(t))) {
	if (!in_class) {
	  Printf(f_shadow_stubs,"%s = %s.%s\n", iname, global_name, iname);
	}
    }

    wname = Swig_name_wrapper(iname);

    /* Create a function for setting the value of the variable */

    Printf(setf->def,"static int %s_set(PyObject *_val) {", wname);
    if (!Getattr(n,"feature:immutable")) {
      if ((tm = Swig_typemap_lookup_new("varin",n,name,0))) {
	Replaceall(tm,"$source","_val");
	Replaceall(tm,"$target",name);
	Replaceall(tm,"$input","_val");
	Printf(setf->code,"%s\n",tm);
	Delete(tm);
      } else {
	Swig_warning(WARN_TYPEMAP_VARIN_UNDEF, input_file, line_number, 
		     "Unable to set variable of type %s.\n", SwigType_str(t,0));
      }
      Printf(setf->code,"    return 0;\n");
    } else {
      /* Is a readonly variable.  Issue an error */
      Printv(setf->code,
	     tab4, "PyErr_SetString(PyExc_TypeError,\"Variable ", iname,
	     " is read-only.\");\n",
	     tab4, "return 1;\n",
	     NIL);
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
      Swig_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number,
		   "Unable to link with type %s\n", SwigType_str(t,0));
    }
    
    Printf(getf->code,"    return pyobj;\n}\n");
    Wrapper_print(getf,f_wrappers);

    /* Now add this to the variable linking mechanism */
    Printf(f_init,"\t SWIG_addvarlink(SWIG_globals,(char*)\"%s\",%s_get, %s_set);\n", iname, wname, wname);

    DelWrapper(setf);
    DelWrapper(getf);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    String *name    = Getattr(n,"name");
    String *iname   = Getattr(n,"sym:name");
    SwigType *type  = Getattr(n,"type");
    String   *value = Getattr(n,"value");
    String  *tm;
    int     have_tm = 0;

    if (!addSymbol(iname,n)) return SWIG_ERROR;

  /* Special hook for member pointer */
    if (SwigType_type(type) == T_MPOINTER) {
      String *wname = Swig_name_wrapper(iname);
      Printf(f_header, "static %s = %s;\n", SwigType_str(type,wname), value);
      value = wname;
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
      Swig_warning(WARN_TYPEMAP_CONST_UNDEF, input_file, line_number,
		   "Unsupported constant value.\n");
      return SWIG_NOWRAP;
    }
    if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
      if (!in_class) {
	Printv(f_shadow,iname, " = ", module, ".", iname, "\n", NIL);
      } else {
	Printv(f_shadow_stubs,iname, " = ", module, ".", iname, "\n", NIL);      
      }
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------ 
   * nativeWrapper()
   * ------------------------------------------------------------ */

  virtual int nativeWrapper(Node *n) {
    String *name     = Getattr(n,"sym:name");
    String *wrapname = Getattr(n,"wrap:name");

    if (!addSymbol(wrapname,n)) return SWIG_ERROR;

    add_method(name, wrapname,0);
    if (shadow) {
      Printv(f_shadow_stubs, name, " = ", module, ".", name, "\n\n", NIL);
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * classDeclaration()
   * ------------------------------------------------------------ */

  virtual int classDeclaration(Node *n) {
    String *importname;
    Node   *mod;
    if (shadow) {
      mod = Getattr(n,"module");
      if (mod) {
	String *modname = Getattr(mod,"name");
	if (Strcmp(modname,mainmodule) != 0) {
	  importname = NewStringf("%s.%s", modname, Getattr(n,"sym:name"));
	} else {
	  importname = NewString(Getattr(n,"sym:name"));
	}
	Setattr(n,"python:proxy",importname);
      }
    }
    return Language::classDeclaration(n);
  }

  /* ------------------------------------------------------------
   * classHandler()
   * ------------------------------------------------------------ */

  virtual int classHandler(Node *n) {
    int oldclassic = classic;

    if (shadow) {

      /* Create new strings for building up a wrapper function */
      have_constructor = 0;
      have_repr = 0;
      
      if (Getattr(n,"cplus:exceptionclass")) {
	classic = 1;
      }
      if (Getattr(n,"feature:classic")) classic = 1;

      shadow_indent = (String *) tab4;
      
      class_name = Getattr(n,"sym:name");
      real_classname = Getattr(n,"name");
      
      if (!addSymbol(class_name,n)) return SWIG_ERROR;
      
      /* Handle inheritance */
      String *base_class = NewString("");
      List *baselist = Getattr(n,"bases");
      if (baselist && Len(baselist)) {
	Node *base = Firstitem(baselist);
	while (base) {
	  String *bname = Getattr(base, "python:proxy");
	  if (!bname) {
	    base = Nextitem(baselist);
	    continue;
	  }
	  Printv(base_class,bname,NIL);
	  base = Nextitem(baselist);
	  if (base) {
	    Putc(',',base_class);
	  }
	}
      }
      Printv(f_shadow,"class ", class_name, NIL);

      if (Len(base_class)) {
	Printf(f_shadow,"(%s)", base_class);
      } else {
	if (!classic) {
	  Printf(f_shadow,"(_object)");
	}
      }
      Printf(f_shadow,":\n");

      Printv(f_shadow,tab4,"__swig_setmethods__ = {}\n",NIL);
      if (Len(base_class)) {
	Printf(f_shadow,"%sfor _s in [%s]: __swig_setmethods__.update(_s.__swig_setmethods__)\n",tab4,base_class);
      }
      
      Printv(f_shadow,
	     tab4, "__setattr__ = lambda self, name, value: _swig_setattr(self, ", class_name, ", name, value)\n",
	     NIL);

      Printv(f_shadow,tab4,"__swig_getmethods__ = {}\n",NIL);
      if (Len(base_class)) {
	Printf(f_shadow,"%sfor _s in [%s]: __swig_getmethods__.update(_s.__swig_getmethods__)\n",tab4,base_class);
      }
      
      Printv(f_shadow,
	     tab4, "__getattr__ = lambda self, name: _swig_getattr(self, ", class_name, ", name)\n",
	     NIL);
    }

    /* Emit all of the members */

    in_class = 1;
    Language::classHandler(n);
    in_class = 0;

    /* Complete the class */
    if (shadow) {
      /* Generate a class registration function */
      {
	SwigType  *ct = NewStringf("p.%s", real_classname);
	SwigType_remember(ct);
	Printv(f_wrappers,
	       "static PyObject * ", class_name, "_swigregister(PyObject *self, PyObject *args) {\n",
	       tab4, "PyObject *obj;\n",
	       tab4, "if (!PyArg_ParseTuple(args,(char*)\"O\", &obj)) return NULL;\n",
	       tab4, "SWIG_TypeClientData(SWIGTYPE", SwigType_manglestr(ct),", obj);\n",
	       tab4, "Py_INCREF(obj);\n",
	       tab4, "return Py_BuildValue((char *)\"\");\n",
	       "}\n",NIL);
	String *cname = NewStringf("%s_swigregister", class_name);
	add_method(cname, cname, 0);
	Delete(cname);
	Delete(ct);
      }
      if (!have_constructor) {
	Printv(f_shadow,tab4,"def __init__(self): raise RuntimeError, \"No constructor defined\"\n",NIL);
      }

      if (!have_repr) {
	/* Supply a repr method for this class  */
	Printv(f_shadow,
	       tab4, "def __repr__(self):\n",
	       tab8, "return \"<C ", class_name," instance at %s>\" % (self.this,)\n",
	       NIL);
      }
      /* Now build the real class with a normal constructor */
      Printv(f_shadow,
	     "\nclass ", class_name, "Ptr(", class_name, "):\n",
	     tab4, "def __init__(self,this):\n",
	     tab8, "self.this = this\n",
	     tab8, "if not hasattr(self,\"thisown\"): self.thisown = 0\n",
	     //	   tab8,"try: self.this = this.this; self.thisown = getattr(this,'thisown',0); this.thisown=0\n",
	     //	   tab8,"except AttributeError: self.this = this\n"
	     tab8, "self.__class__ = ", class_name, "\n",
	     NIL);

      Printf(f_shadow,"%s.%s_swigregister(%sPtr)\n", module, class_name, class_name,0);
      shadow_indent = 0;
      Printf(f_shadow,"%s\n", f_shadow_stubs);
      Clear(f_shadow_stubs);
    }
    classic = oldclassic;
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int memberfunctionHandler(Node *n) {
    String *symname = Getattr(n,"sym:name");
    int   oldshadow;

    /* Create the default member function */
    oldshadow = shadow;    /* Disable shadowing when wrapping member functions */
    if (shadow) shadow = shadow | PYSHADOW_MEMBER;
    Language::memberfunctionHandler(n);
    shadow = oldshadow;

    if (!Getattr(n,"sym:nextSibling")) {
      if (shadow) {
	int allow_kwargs = (use_kw || Getattr(n,"feature:kwargs")) ? 1 : 0;
	if (Strcmp(symname,"__repr__") == 0)
	  have_repr = 1;
	
	if (Getattr(n,"feature:shadow")) {
	  String *pycode = pythoncode(Getattr(n,"feature:shadow"),tab4);
	  Printv(f_shadow,pycode,"\n",NIL);
	} else {
	  if (allow_kwargs && !Getattr(n,"sym:overloaded")) {
	    Printv(f_shadow,tab4, "def ", symname, "(*args, **kwargs): ", NIL);
	    Printv(f_shadow, "return apply(", module, ".", Swig_name_member(class_name,symname), ",args, kwargs)\n", NIL);
	  } else {
	    Printv(f_shadow, tab4, "def ", symname, "(*args): ", NIL);
	    Printv(f_shadow, "return apply(", module, ".", Swig_name_member(class_name,symname), ",args)\n",NIL);
	  }
	}
      }
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ------------------------------------------------------------ */
  
  virtual int staticmemberfunctionHandler(Node *n) {
    String *symname = Getattr(n,"sym:name");
    Language::staticmemberfunctionHandler(n);
    if (shadow) {
      Printv(f_shadow, tab4, "__swig_getmethods__[\"", symname, "\"] = lambda x: ", module, ".", Swig_name_member(class_name, symname), "\n",  NIL);
      if (!classic) {
	Printv(f_shadow, tab4, "if _newclass:",  symname, " = staticmethod(", module, ".",
	       Swig_name_member(class_name, symname), ")\n", NIL);
      }
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constructorDeclaration()
   * ------------------------------------------------------------ */

  virtual int constructorHandler(Node *n) {
    String *symname = Getattr(n,"sym:name");
    int   oldshadow = shadow;

    if (shadow) shadow = shadow | PYSHADOW_MEMBER;
    Language::constructorHandler(n);
    shadow = oldshadow;

    if (!Getattr(n,"sym:nextSibling")) {
      if (shadow) {
	int allow_kwargs = (use_kw || Getattr(n,"feature:kwargs")) ? 1 : 0;
	if (!have_constructor) {
	  if (Getattr(n,"feature:shadow")) {
	    String *pycode = pythoncode(Getattr(n,"feature:shadow"),tab4);
	    Printv(f_shadow,pycode,"\n",NIL);
	  } else {
	    if ((allow_kwargs) && (!Getattr(n,"sym:overloaded"))) {
	      Printv(f_shadow, tab4, "def __init__(self,*args,**kwargs):\n", NIL);
	      Printv(f_shadow, tab8, "self.this = apply(", module, ".", Swig_name_construct(symname), ",args,kwargs)\n", NIL);
	    }  else {
	      Printv(f_shadow, tab4, "def __init__(self,*args):\n",NIL);
	      Printv(f_shadow, tab8, "self.this = apply(", module, ".", Swig_name_construct(symname), ",args)\n", NIL);
	    }
	    Printv(f_shadow,
		   tab8, "self.thisown = 1\n",
		   NIL);
	  }
	  have_constructor = 1;
	} else {
	  /* Hmmm. We seem to be creating a different constructor.  We're just going to create a
	     function for it. */

	  if (Getattr(n,"feature:shadow")) {
	    String *pycode = pythoncode(Getattr(n,"feature:shadow"),"");
	    Printv(f_shadow_stubs,pycode,"\n",NIL);
	  } else {
	    if ((allow_kwargs) && (!Getattr(n,"sym:overloaded"))) 
	      Printv(f_shadow_stubs, "def ", symname, "(*args,**kwargs):\n", NIL);
	    else
	      Printv(f_shadow_stubs, "def ", symname, "(*args):\n", NIL);
	    
	    Printv(f_shadow_stubs, tab4, "val = apply(", NIL);
	    if ((allow_kwargs) && (!Getattr(n,"sym:overloaded"))) 
	      Printv(f_shadow_stubs, module, ".", Swig_name_construct(symname), ",args,kwargs)\n", NIL);
	    else
	      Printv(f_shadow_stubs, module, ".", Swig_name_construct(symname), ",args)\n", NIL);
	    Printv(f_shadow_stubs,tab4, "val.thisown = 1\n",
		   tab4, "return val\n\n", NIL);
	  }
	}
      }
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * destructorHandler()
   * ------------------------------------------------------------ */

  virtual int destructorHandler(Node *n) {
    String *symname = Getattr(n,"sym:name");
    int oldshadow = shadow;
    
    if (shadow) shadow = shadow | PYSHADOW_MEMBER;
    Language::destructorHandler(n);
    shadow = oldshadow;
    if (shadow) {
      Printv(f_shadow, tab4, "def __del__(self, destroy= ", module, ".", Swig_name_destroy(symname), "):\n", NIL);
      Printv(f_shadow, tab8, "try:\n", NIL);
      Printv(f_shadow, tab4, tab8, "if self.thisown: destroy(self)\n", NIL);
      Printv(f_shadow, tab8, "except: pass\n", NIL);
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * membervariableHandler()
   * ------------------------------------------------------------ */

  virtual int membervariableHandler(Node *n) {
    String *symname = Getattr(n,"sym:name");

    int   oldshadow = shadow;
    if (shadow) shadow = shadow | PYSHADOW_MEMBER;
    Language::membervariableHandler(n);
    shadow = oldshadow;

    if (shadow) {
      int immutable = 0;
      if (!Getattr(n,"feature:immutable")) {
	Printv(f_shadow, tab4, "__swig_setmethods__[\"", symname, "\"] = ", module, ".", Swig_name_set(Swig_name_member(class_name,symname)), "\n", NIL);
      } else {
	immutable = 1;
      }
      Printv(f_shadow, tab4, "__swig_getmethods__[\"", symname, "\"] = ", module, ".", Swig_name_get(Swig_name_member(class_name,symname)),"\n", NIL);

      if (!classic) {
	if (immutable) {
	  Printv(f_shadow,tab4,"if _newclass:", symname," = property(", module, ".", 
		 Swig_name_get(Swig_name_member(class_name,symname)),")\n", NIL);
	} else {
	  Printv(f_shadow,tab4,"if _newclass:", symname," = property(", 
		 module, ".", Swig_name_get(Swig_name_member(class_name,symname)),",",
		 module, ".", Swig_name_set(Swig_name_member(class_name,symname)),")\n", NIL);
	}
      }
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * staticmembervariableHandler()
   * ------------------------------------------------------------ */

  virtual int staticmembervariableHandler(Node *n) {
    String *symname;
    SwigType *t;
    
    Language::staticmembervariableHandler(n);
    if (shadow) {
      t = Getattr(n,"type");
      symname = Getattr(n,"sym:name");
      if (SwigType_isconst(t) && !Getattr(n, "value")) {
	Printf(f_shadow,"%s%s = %s.%s.%s\n", tab4, symname, module, global_name, Swig_name_member(class_name,symname));      
      }
    }
    return SWIG_OK;

  }

  /* ------------------------------------------------------------
   * memberconstantHandler()
   * ------------------------------------------------------------ */

  virtual int memberconstantHandler(Node *n) {
    String *symname = Getattr(n,"sym:name");
    int   oldshadow = shadow;
    if (shadow) shadow = shadow | PYSHADOW_MEMBER;
    Language::memberconstantHandler(n);
    shadow = oldshadow;

    if (shadow) {
      Printv(f_shadow, tab4, symname, " = ", module, ".", Swig_name_member(class_name,symname), "\n", NIL);
    }
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * pythoncode()     - Output python code into the shadow file
   * ------------------------------------------------------------ */

  String *pythoncode(String *code, const String *indent) {
    String *out = NewString("");
    String *temp;
    char   *t;
    if (!indent) indent = "";

    temp = NewString(code);

    t = Char(temp);
    if (*t == '{') {
      Delitem(temp,0);
      Delitem(temp,DOH_END);
    }
    /* Split the input text into lines */
    List *clist = DohSplit(temp,'\n',-1);
    Delete(temp);
    int   initial = 0;
    String *s;

  /* Get the initial indentation */
    for (s = Firstitem(clist); s; s = Nextitem(clist)) {
      if (Len(s)) {
	char *c = Char(s);
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
    while (s) {
      if (Len(s) > initial) {
	char *c = Char(s);
	c += initial;
	Printv(out,indent,c,"\n",NIL);
      } else {
	Printv(out,"\n",NIL);
      }
      s = Nextitem(clist);
    }
    Delete(clist);
    return out;
  }

  /* ------------------------------------------------------------
   * insertDirective()
   * 
   * Hook for %insert directive.   We're going to look for special %shadow inserts
   * as a special case so we can do indenting correctly
   * ------------------------------------------------------------ */

  virtual int insertDirective(Node *n) {
    String *code = Getattr(n,"code");
    String *section = Getattr(n,"section");

    if ((!ImportMode) && ((Cmp(section,"python") == 0) || (Cmp(section,"shadow") == 0))) {
      if (shadow) {
	String *pycode = pythoncode(code,shadow_indent);
	Printv(f_shadow, pycode, "\n", NIL);
	Delete(pycode);
      }
    } else {
      Language::insertDirective(n);
    }
    return SWIG_OK;
  }
};

/* -----------------------------------------------------------------------------
 * swig_python()    - Instantiate module
 * ----------------------------------------------------------------------------- */

extern "C" Language *
swig_python(void) {
  return new PYTHON();
}

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
#include "cparse.h"
static int treduce = SWIG_cparse_template_reduce(0);

#include <ctype.h>

#define PYSHADOW_MEMBER  0x2

static  String       *const_code = 0;
static  String       *module = 0;
static  String       *package = 0;
static  String       *mainmodule = 0;
static  String       *interface = 0;
static  String       *global_name = 0;
static  int           shadow = 1;
static  int           use_kw = 0;
static  int           director_method_index = 0;

static  File         *f_runtime = 0;
static  File         *f_runtime_h = 0;
static  File         *f_header = 0;
static  File         *f_wrappers = 0;
static  File         *f_directors = 0;
static  File         *f_directors_h = 0;
static  File         *f_init = 0;
static  File         *f_shadow_py = 0;
static  String       *f_shadow = 0;
static  String       *f_shadow_imports = 0;
static  String       *f_shadow_stubs = 0;

static  String       *methods;
static  String       *class_name;
static  String       *shadow_indent = 0;
static  int           in_class = 0;
static  int           classic = 0;
static  int           modern = 0;
static  int           apply = 0;
static  int           new_repr = 1;
static  int           no_header_file = 0;

/* C++ Support + Shadow Classes */

static  int       have_constructor;
static  int       have_repr;
static  String   *real_classname;

/* Thread Support */
static  int       threads = 0;
static  int       nothreads = 0;
static  int       classptr = 0;
/* Other options */
static  int       shadowimport = 1;
static  int       safecstrings = 0;
static  int       dirvtable = 0;
static  int       proxydel = 1;

/* flags for the make_autodoc function */
enum autodoc_t {
  AUTODOC_CLASS,
  AUTODOC_CTOR,
  AUTODOC_DTOR,
  AUTODOC_STATICFUNC,
  AUTODOC_FUNC,
  AUTODOC_METHOD
};

static const char *usage = (char *)"\
Python Options (available with -python)\n\
     -globals <name> - Set <name> used to access C global variable [default: 'cvar']\n\
     -interface <lib>- Set the lib name to <lib>\n\
     -keyword        - Use keyword arguments\n\
     -classic        - Use classic classes only\n\
     -cppcast        - Enable C++ casting operators (default) \n\
     -nocppcast      - Disable C++ casting operators, useful for generating bugs\n\
     -nortti         - Disable the use of the native C++ RTTI with directors\n\
     -modern         - Use modern python features only, without compatibility code\n\
     -nomodern       - Don't use modern python features which are not back compatible \n\
     -apply          - Use apply() in proxy classes\n\
     -new_vwm        - New value wrapper mode, use only when everything else fails \n\
     -new_repr       - Use more informative version of __repr__ in proxy classes (default) \n\
     -old_repr       - Use shorter and old version of __repr__ in proxy classes\n\
     -classptr       - Generate shadow 'ClassPtr' as in older swig versions\n\
     -threads        - Add thread support for all the interface\n\
     -nothreads      - Disable thread support for all the interface\n\
     -noexcept       - No automatic exception handling\n\
     -noh            - Don't generate the output header file\n\
     -noproxy        - Don't generate proxy classes \n\
     -noproxyimport  - Don't insert proxy import statements derived from the %import directive \n\
     -safecstrings   - Use safer (but slower) C string mapping, generating copies from Python -> C/C++\n\
     -nosafecstrings - Avoid extra strings copies when possible (default)\n\
     -dirvtable      - Generate a pseudo virtual table for directors for faster dispatch \n\
     -nodirvtable    - Don't use the virtual table feature, resolve the python method each time (default)\n\
     -proxydel       - Generate a __del__ method even when now is redundant (default) \n\
     -noproxydel     - Don't generate the redundant __del__ method \n\
     -O              - Enable several old and new optimizations options: \n\
                         -modern -fastdispatch -dirvtable -nosafecstrings -fvirtual -noproxydel \n\
\n";

class PYTHON : public Language {
public:
  PYTHON() 
  {
    /* Add code to manage protected constructors and directors */
    director_prot_ctor_code = NewString("");    
    Printv(director_prot_ctor_code,
	   "if ( $comparison ) { /* subclassed */\n",
	   "  $director_new \n",
	   "} else {\n",
	   "  SWIG_SetErrorMsg(PyExc_RuntimeError,\"accessing abstract class or protected constructor\"); \n",
	   "  SWIG_fail;\n",
	   "}\n", NIL);
    director_multiple_inheritance = 1;
    director_language = 1;
  }

  /* ------------------------------------------------------------
   * Thread Implementation
   * ------------------------------------------------------------ */

  int threads_enable(Node *n) const {
    return threads && !GetFlagAttr(n, "feature:nothread");
  }
   
  int initialize_threads(String *f_init) {
    if (!threads) {
      return SWIG_OK;
    }
    Printf(f_init,"\n");
    Printf(f_init,"/* Initialize threading */\n");
    Printf(f_init,"SWIG_PYTHON_INITIALIZE_THREADS;\n");
    
    return SWIG_OK;
  }
  
  virtual void thread_begin_block(Node *n, String *f) {
    if (!GetFlag(n, "feature:nothreadblock")) {
      String *bb = Getattr(n,"feature:threadbeginblock");
      if (bb) {
	Append(f, bb);
      } else {
	Append(f,"SWIG_PYTHON_THREAD_BEGIN_BLOCK;\n");
      }      
    }
  }
  
  virtual void thread_end_block(Node *n, String *f) {
    if (!GetFlag(n, "feature:nothreadblock")) {
      String *eb = Getattr(n, "feature:threadendblock");
      if (eb) {
	Append(f, eb);
      } else {
	Append(f, "SWIG_PYTHON_THREAD_END_BLOCK;\n");
      }
    }
  }

  virtual void thread_begin_allow(Node *n, String *f) {
    if (!GetFlag(n, "feature:nothreadallow")) {
      String *bb = Getattr(n, "feature:threadbeginallow");
      if (bb) {
	Append(f, bb);
      } else {
	Append(f, "SWIG_PYTHON_THREAD_BEGIN_ALLOW;\n");
      }
    }
  }
  
  virtual void thread_end_allow(Node *n, String *f) {
    if (!GetFlag(n, "feature:nothreadallow")) {
      String *eb = Getattr(n, "feature:threadendallow");
      if (eb) {
	Append(f, eb);
      } else {
	Append(f, "SWIG_PYTHON_THREAD_END_ALLOW;\n");
      }
    }
  }
  
  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */
  
  virtual void main(int argc, char *argv[]) {
    int cppcast = 1;

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
        } else if (strcmp(argv[i],"-apply") == 0) {
          apply = 1;
          Swig_mark_arg(i);
        } else if (strcmp(argv[i],"-new_repr") == 0) {
          new_repr = 1;
          Swig_mark_arg(i);
        } else if (strcmp(argv[i],"-old_repr") == 0) {
          new_repr = 0;
          Swig_mark_arg(i);
        } else if (strcmp(argv[i],"-classptr") == 0) {
          classptr = 1;
          Swig_mark_arg(i);
	} else if ((strcmp(argv[i],"-noproxy") == 0)) {
	  shadow = 0;
	  Swig_mark_arg(i);
	} else if ((strcmp(argv[i],"-noproxyimport") == 0)) {
	  shadowimport = 0;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-keyword") == 0) {
	  use_kw = 1;
          SWIG_cparse_set_compact_default_args(1);
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-classic") == 0) {
	  classic = 1;
	  apply = 1;
	  modern = 0;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-cppcast") == 0) {
	  cppcast = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-nocppcast") == 0) {
	  cppcast = 0;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-nortti") == 0) {
	  /* Turn on no-RTTI mode */
	  Preprocessor_define((DOH *) "SWIG_NORTTI", 0);
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-threads") == 0) {
	  threads = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-nothreads") == 0) {
	  /* Turn off thread suppor mode */
	  nothreads = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-safecstrings") == 0) {
	  safecstrings = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-nosafecstrings") == 0) {
	  safecstrings = 0;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-dirvtable") == 0) {
	  dirvtable = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-nodirvtable") == 0) {
	  dirvtable = 0;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-proxydel") == 0) {
	  proxydel = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-noproxydel") == 0) {
	  proxydel = 0;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-modern") == 0) {
	  apply = 0;
	  classic = 0;
          modern = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-nomodern") == 0) {
          modern = 0;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-noh") == 0) {
	  no_header_file = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-new_vwm") == 0) {
	  /* Turn on new value wrapper mpde */
	  Swig_value_wrapper_mode(1); 
	  no_header_file = 1;
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-O") == 0) {
	  apply = 0;
	  classic = 0;
	  modern = 1;
	  dirvtable = 1;
	  safecstrings = 0;
	  classptr = 0;
	  proxydel = 0;
	  Wrapper_fast_dispatch_mode_set(1);
	  Wrapper_virtual_elimination_mode_set(1);
	  Swig_mark_arg(i);
	} else if (strcmp(argv[i],"-help") == 0) {
	  fputs(usage,stdout);
	}
      }
    }

    if (cppcast) {
      Preprocessor_define((DOH *) "SWIG_CPLUSPLUS_CAST", 0);
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
    /* check if directors are enabled for this module.  note: this 
     * is a "master" switch, without which no director code will be
     * emitted.  %feature("director") statements are also required
     * to enable directors for individual classes or methods.
     *
     * use %module(directors="1") modulename at the start of the 
     * interface file to enable director generation.
     */
    String* mod_docstring = NULL;
    {
      Node *mod = Getattr(n, "module");
      if (mod) {
        Node *options = Getattr(mod, "options");
        if (options) {
	  int dirprot = 0;	  
          if (Getattr(options, "dirprot")) {
	    dirprot = 1;
          }
          if (Getattr(options, "nodirprot")) {
	    dirprot = 0;
          }
          if (Getattr(options, "directors")) {
            allow_directors();
	    if (dirprot) allow_dirprot();
          }
          if (Getattr(options, "threads")) {
            threads = 1;
          }
          mod_docstring = Getattr(options, "docstring");
          package = Getattr(options, "package");
        }
      }
    }

    /* Set comparison with none for ConstructorToFunction */
    setSubclassInstanceCheck(NewString("$arg != SWIG_Py_None()"));

    /* Initialize all of the output files */
    String *outfile = Getattr(n,"outfile");
    String *outfile_h = !no_header_file ? Getattr(n, "outfile_h"): 0;

    f_runtime = NewFile(outfile,"w");
    if (!f_runtime) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    
    if (directorsEnabled()) {
      if (!no_header_file) {
	f_runtime_h = NewFile(outfile_h,"w");
	if (!f_runtime_h) {
	  FileErrorDisplay(outfile_h);
	  SWIG_exit(EXIT_FAILURE);
	}
      } else {
	f_runtime_h = f_runtime;
      }
    }

    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_directors_h = NewString("");
    f_directors = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header",f_header);
    Swig_register_filebyname("wrapper",f_wrappers);
    Swig_register_filebyname("runtime",f_runtime);
    Swig_register_filebyname("init",f_init);
    Swig_register_filebyname("director",f_directors);
    Swig_register_filebyname("director_h",f_directors_h);

    const_code     = NewString("");
    methods        = NewString("");

    Swig_banner(f_runtime);

    Printf(f_runtime,"#define SWIGPYTHON\n");

    if (directorsEnabled()) {
      Printf(f_runtime,"#define SWIG_DIRECTORS\n");
    }

    if (nothreads) {
      Printf(f_runtime,"#define SWIG_PYTHON_NO_THREADS\n");
    } else if (threads) {
      Printf(f_runtime,"#define SWIG_PYTHON_THREADS\n");
    }

    if (safecstrings) {
      Printf(f_runtime,"#define SWIG_PYTHON_SAFE_CSTRINGS\n");
    }

    if (!dirvtable) {
      Printf(f_runtime,"#define SWIG_DIRECTOR_NO_VTABLE\n");
    }
    

    /* Set module name */
    module = Copy(Getattr(n,"name"));
    mainmodule = Getattr(n,"name");

    if (directorsEnabled()) {
      Swig_banner(f_directors_h);
      Printf(f_directors_h, "#ifndef SWIG_%s_WRAP_H_\n", module);
      Printf(f_directors_h, "#define SWIG_%s_WRAP_H_\n\n", module);
      if (dirprot_mode()) {
	Printf(f_directors_h, "#include <map>\n");
	Printf(f_directors_h, "#include <string>\n\n");
      }
      /* Printf(f_directors_h, "class Swig::Director;\n\n"); */
      Swig_insert_file("director_h.swg", f_directors_h);
      Printf(f_directors, "\n\n");
      Printf(f_directors, "/* ---------------------------------------------------\n");
      Printf(f_directors, " * C++ director class methods\n");
      Printf(f_directors, " * --------------------------------------------------- */\n\n");
      if (outfile_h) {
	Printf(f_directors, "#include \"%s\"\n\n",Swig_file_filename(outfile_h));
      }
      Swig_insert_file("director.swg", f_directors);
    }

    /* If shadow classing is enabled, we're going to change the module name to "_module" */
    if (shadow) {
      String *filen = NewStringf("%s%s.py", SWIG_output_directory(), Char(module));
      // If we don't have an interface then change the module name X to _X
      if (interface) module = interface;
      else Insert(module,0,"_");
      if ((f_shadow_py = NewFile(filen,"w")) == 0) {
	FileErrorDisplay(filen);
	SWIG_exit (EXIT_FAILURE);
      }
      Delete(filen); filen = NULL;

      f_shadow = NewString("");
      f_shadow_imports = NewString("");
      f_shadow_stubs = NewString("");

      Swig_register_filebyname("shadow",f_shadow);
      Swig_register_filebyname("python",f_shadow);

      Printv(f_shadow_py,
	     "# This file was created automatically by SWIG ", PACKAGE_VERSION, ".\n",
	     "# Don't modify this file, modify the SWIG interface instead.\n",
	     NIL);

      if (! modern) {
          Printv(f_shadow,
                 "# This file is compatible with both classic and new-style classes.\n",
                 NIL);
      }

      if (mod_docstring && Len(mod_docstring)) {
        Printv(f_shadow, "\n\"\"\"\n", mod_docstring, "\n\"\"\"\n", NIL);
        Delete(mod_docstring); mod_docstring = NULL;
      }
      
      Printv(f_shadow,"import new\n",NULL);
      Printv(f_shadow,"new_instancemethod = new.instancemethod\n",NULL);
      /* if (!modern) */
      /* always needed, a class can be forced to be no-modern, such as an exception */
      { 
        // Python-2.2 object hack
        Printv(f_shadow,
               "def _swig_setattr_nondynamic(self,class_type,name,value,static=1):\n",
               tab4, "if (name == \"thisown\"): return self.this.own(value)\n",
               tab4, "if (name == \"this\"):\n",
               tab4, tab4, "if type(value).__name__ == 'PySwigObject':\n",
               tab4, tab8, "self.__dict__[name] = value\n",
#ifdef USE_THISOWN
               tab4, tab8, "if hasattr(value,\"thisown\"): self.__dict__[\"thisown\"] = value.thisown\n",
               tab4, tab8, "del value.thisown\n",
#endif
               tab4, tab8, "return\n",
               tab4, "method = class_type.__swig_setmethods__.get(name,None)\n",
               tab4, "if method: return method(self,value)\n",
#ifdef USE_THISOWN
	       tab4, "if (not static) or hasattr(self,name) or (name == \"thisown\"):\n",
#else
	       tab4, "if (not static) or hasattr(self,name):\n",
#endif
               tab4, tab4, "self.__dict__[name] = value\n",
	       tab4, "else:\n",
	       tab4, tab4, "raise AttributeError(\"You cannot add attributes to %s\" % self)\n\n",
               "def _swig_setattr(self,class_type,name,value):\n",
               tab4, "return _swig_setattr_nondynamic(self,class_type,name,value,0)\n\n",
               NIL);

        Printv(f_shadow,
               "def _swig_getattr(self,class_type,name):\n",
               tab4, "if (name == \"thisown\"): return self.this.own()\n",
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
                 "del types\n",
                 "\n\n",
                 NIL);
        }
      }
      if (modern) {
        Printv(f_shadow,
	       "def _swig_setattr_nondynamic_method(set):\n",
	       tab4, "def set_attr(self,name,value):\n",
#ifdef USE_THISOWN
	       tab4, tab4, "if hasattr(self,name) or (name in (\"this\", \"thisown\")):\n",
#else
	       tab4, tab4, "if (name == \"thisown\"): return self.this.own(value)\n",
	       tab4, tab4, "if hasattr(self,name) or (name == \"this\"):\n",
#endif
	       tab4, tab4, tab4, "set(self,name,value)\n",
	       tab4, tab4, "else:\n",
	       tab4, tab4, tab4, "raise AttributeError(\"You cannot add attributes to %s\" % self)\n",
	       tab4, "return set_attr\n\n\n",
	       NIL);
      }
	
      if (directorsEnabled()) {
        // Try loading weakref.proxy, which is only available in Python 2.1 and higher
        Printv(f_shadow,
               "try:\n",
	       tab4, "import weakref\n",
	       tab4, "weakref_proxy = weakref.proxy\n",
	       "except:\n",
	       tab4, "weakref_proxy = lambda x: x\n",
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
    Printf(methods,"\t { NULL, NULL, 0, NULL }\n");
    Printf(methods,"};\n");
    Printf(f_wrappers,"%s\n",methods);

    SwigType_emit_type_table(f_runtime,f_wrappers);

    Printf(const_code, "{0, 0, 0, 0.0, 0, 0}};\n");
    Printf(f_wrappers,"%s\n",const_code);
    initialize_threads(f_init);
    Printf(f_init,"}\n");

    Printf(f_wrappers,"#ifdef __cplusplus\n");
    Printf(f_wrappers,"}\n");
    Printf(f_wrappers,"#endif\n");

    if (shadow) {
      /*
      Printf(f_shadow_imports,"\nimport %s\n", module);
      Printv(f_shadow_py, f_shadow_imports, "\n",NIL);
      */
      Printf(f_shadow_py,"\nimport %s\n", module);
      Printv(f_shadow_py, f_shadow, "\n",NIL);
      Printv(f_shadow_py, f_shadow_stubs, "\n",NIL);

      Close(f_shadow_py);
      Delete(f_shadow_py);
    }

    /* Close all of the files */
    Dump(f_header,f_runtime);

    if (directorsEnabled()) {
      Dump(f_directors_h, f_runtime_h);
      Printf(f_runtime_h, "\n");
      Printf(f_runtime_h, "#endif\n");
      if (f_runtime_h != f_runtime) Close(f_runtime_h);
      Dump(f_directors, f_runtime);
    }

    Dump(f_wrappers,f_runtime);
    Wrapper_pretty_print(f_init,f_runtime);

    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Delete(f_directors);
    Delete(f_directors_h);

    Close(f_runtime);
    Delete(f_runtime);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * importDirective()
   * ------------------------------------------------------------ */

  virtual int importDirective(Node *n) {
    if (shadow) {
      String *modname = Getattr(n,"module");

      if (modname) {
        String *import = NewString("import ");

        // Find the module node for this imported module.  It should be the
        // first child but search just in case.
        Node* mod = firstChild(n);
        while (mod && Strcmp(nodeType(mod), "module") != 0)
          mod = nextSibling(mod);
          
        // Is the imported module in another package?  (IOW, does it use the
        // %module(package="name") option and it's different than the package
        // of this module.)
        Node *options = Getattr(mod, "options");
        String* pkg = options ? Getattr(options, "package") : 0;
	if (pkg && (!package || Strcmp(pkg, package) != 0)) {
	  Printf(import, "%s.", pkg);
        }

        // finally, output the name of the imported module
	if (shadowimport) {
	  if (!options || (!Getattr(options, "noshadow") && !Getattr(options, "noproxy"))) {	    
	    Printf(import, "_%s\n", modname);
	    if (!Strstr(f_shadow_imports, import)) {
	      Printf(f_shadow, "import %s\n", modname);
	      Printf(f_shadow_imports, "%s", import);
	    }
	  }
	}
	
	Delete(import);
      }
    }
    return Language::importDirective(n);
  }


  /* ------------------------------------------------------------
   * emitFuncCallHelper()
   *    Write the shadow code to call a function in the extension
   *    module.  Takes into account the -apply flag and whether
   *    to use keyword args or not.
   * ------------------------------------------------------------ */

  String *funcCallHelper(String *name, int kw) {
    String *str;
    
    str = NewString("");
    if (apply) {
      Printv(str, "apply(", module, ".", name, ", args", (kw ? ", kwargs" : ""), ")", NIL);
    } else {
      Printv(str, module, ".", name, "(*args", (kw ? ", **kwargs" : ""), ")", NIL);
    }
    return str;
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
    List *clist = DohSplitLines(temp);
    Delete(temp);
    int   initial = 0;
    String *s = 0;
    Iterator si;
    /* Get the initial indentation */
    
    for (si = First(clist); si.item; si = Next(si)) {
      s = si.item;
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
    while (si.item) {
      s = si.item;
      if (Len(s) > initial) {
	char *c = Char(s);
	c += initial;
	Printv(out,indent,c,"\n",NIL);
      } else {
	Printv(out,"\n",NIL);
      }
      si = Next(si);
    }
    Delete(clist);
    return out;
  }


  /* ------------------------------------------------------------
   * autodoc level declarations
   * ------------------------------------------------------------ */

  enum autodoc_l {
    NO_AUTODOC           = -2, // no autodoc
    STRING_AUTODOC       = -1, // use provided string
    NAMES_AUTODOC        =  0, // only parameter names
    TYPES_AUTODOC        =  1, // parameter names and types
    EXTEND_AUTODOC       =  2, // extended documentation and parameter names
    EXTEND_TYPES_AUTODOC =  3  // extended documentation and parameter types + names
  };
  
  
  autodoc_l autodoc_level(String *autodoc) {
    autodoc_l dlevel = NO_AUTODOC;
    if (autodoc) {
      char  *c = Char(autodoc);
      if (c && isdigit(c[0])) {
	dlevel = (autodoc_l) atoi(c);
      } else {
	if (strcmp(c,"extended")== 0) {
	  dlevel = EXTEND_AUTODOC; 
	} else {
	  dlevel = STRING_AUTODOC;
	}
      }
    }
    return dlevel;
  }
  

  /* ------------------------------------------------------------
   * have_docstring()
   *    Check if there is a docstring directive and it has text,
   *    or there is an autodoc flag set
   * ------------------------------------------------------------ */

  bool have_docstring(Node *n) {
    String* str = Getattr(n, "feature:docstring");
    return (str != NULL && Len(str) > 0) ||
        (Getattr(n,"feature:autodoc") && !GetFlag(n, "feature:noautodoc"));
  }
  
  /* ------------------------------------------------------------
   * docstring()
   *    Get the docstring text, stripping off {} if neccessary,
   *    and enclose in triple double quotes.  If autodoc is also
   *    set then it will build a combined docstring.
   * ------------------------------------------------------------ */

  String *docstring(Node *n, autodoc_t ad_type, const String* indent,
    bool use_triple = true) {
    String* str = Getattr(n, "feature:docstring");
    bool have_ds = (str != NULL && Len(str) > 0);
    bool have_auto = (Getattr(n,"feature:autodoc") && !GetFlag(n, "feature:noautodoc"));
    const char* triple_double = use_triple ? "\"\"\"" : "";
    String* autodoc = NULL;
    String* doc = NULL;

    if ( have_ds ) {
      char* t = Char(str);
      if (*t == '{') {
        Delitem(str ,0);
        Delitem(str,DOH_END);
      }
    }

    if ( have_auto ) {
      autodoc = make_autodoc(n, ad_type);
      have_auto = (autodoc != NULL && Len(autodoc) > 0);
    }
    
    // If there is more than one line then make docstrings like this:
    //
    //      """
    //      This is line1
    //      And here is line2 followed by the rest of them
    //      """
    //
    // otherwise, put it all on a single line
    //
    if ( have_auto && have_ds ) {       // Both autodoc and docstring are present
      doc = NewString("");
      Printv(doc, triple_double, "\n",
                  pythoncode(autodoc, indent), "\n",
                  pythoncode(str, indent), 
                  indent, triple_double, NIL);
    }
    else if ( !have_auto && have_ds ) { // only docstring
      if (Strchr(str, '\n') == NULL) {
        doc = NewStringf("%s%s%s", triple_double, str, triple_double);
      }
      else {
      doc = NewString("");
      Printv(doc, triple_double, "\n",
                  pythoncode(str, indent),
                  indent, triple_double, NIL);
      }
    }
    else if ( have_auto && !have_ds ) { // only autodoc
      if (Strchr(autodoc, '\n') == NULL) {
        doc = NewStringf("%s%s%s", triple_double, autodoc, triple_double);
      }
      else {
      doc = NewString("");
      Printv(doc, triple_double, "\n",
                  pythoncode(autodoc, indent),
                  indent, triple_double, NIL);
      }
    }
    else
      doc = NewString("");

    // Save the generated strings in the parse tree in case they are used later
    // by post processing tools
    Setattr(n, "python:docstring", doc);
    Setattr(n, "python:autodoc", autodoc);
    return doc;
  }

  /* ------------------------------------------------------------
   * make_autodocParmList()
   *   Generate the documentation for the function parameters
   * ------------------------------------------------------------ */

  String* make_autodocParmList(Node* n, bool showTypes) {
    String*   doc = NewString(""); 
    String*   pdocs = Copy(Getattr(n,"feature:pdocs")); 
    ParmList* plist = CopyParmList(Getattr(n,"parms"));
    Parm*     p;
    Parm*     pnext;
    Node*     lookup;
    int       lines = 0;
    const int maxwidth = 50;

    if (pdocs) Printf(pdocs, "\n");


    Swig_typemap_attach_parms("in",plist,0);
    Swig_typemap_attach_parms("doc",plist,0);
    
    for (p = plist; p; p = pnext) {
      String*   name  = 0;
      String*   type  = 0;
      String*   value = 0;      
      String*   ptype = 0;
      String*   pdoc  = Getattr(p, "tmap:doc");
      if (pdoc) {
	name = Getattr(p, "tmap:doc:name");
	type = Getattr(p, "tmap:doc:type");
	value = Getattr(p, "tmap:doc:value");
	ptype = Getattr(p, "tmap:doc:pytype");
      }
    
      name = name ? name : Getattr(p,"name");
      type = type ? type : Getattr(p, "type");
      value = value ? value : Getattr(p, "value");

      String* tm = Getattr(p,"tmap:in");
      if (tm) {
	pnext = Getattr(p,"tmap:in:next");
      } else {
	pnext = nextSibling(p);
      }

      if ( Len(doc) ) {
        // add a comma to the previous one if any
        Printf(doc, ", ");

        // Do we need to wrap a long line?
        if ((Len(doc) - lines*maxwidth) > maxwidth) {
          Printf(doc, "\n%s", tab4);
          lines += 1;
        }
      }
        
      // Do the param type too?
      if (showTypes) {
        type =  SwigType_base(type);
	lookup = Swig_symbol_clookup(type, 0);
	if (lookup) type = Getattr(lookup, "sym:name");
        Printf(doc, "%s ", type);
      }

      if (name) {
        Printf(doc, "%s", name);
	if (pdoc) {
	  if (!pdocs) pdocs = NewString("Parameters:\n");
	  Printf(pdocs, "   %s\n", pdoc);
	}
      } else {
        Printf(doc, "?");
      }

      if (value) {
        if (Strcmp(value, "NULL") == 0)
          value = NewString("None");
        else if (Strcmp(value, "true") == 0 || Strcmp(value, "TRUE") == 0)
          value = NewString("True");
	else if (Strcmp(value, "false") == 0 || Strcmp(value, "FALSE") == 0)
          value = NewString("False");        
	else {
          lookup = Swig_symbol_clookup(value, 0);
          if (lookup)
            value = Getattr(lookup, "sym:name");
        }
        Printf(doc, "=%s", value);
      }
    }
    if (pdocs) Setattr(n,"feature:pdocs", pdocs);
    Delete(plist);
    return doc;
  }

  /* ------------------------------------------------------------
   * make_autodoc()
   *    Build a docstring for the node, using parameter and other
   *    info in the parse tree.  If the value of the autodoc
   *    attribute is "0" then do not include parameter types, if
   *    it is "1" (the default) then do.  If it has some other
   *    value then assume it is supplied by the extension writer
   *    and use it directly.
   * ------------------------------------------------------------ */

  String* make_autodoc(Node *n, autodoc_t ad_type) {
    int extended = 0;
    // If the function is overloaded then this funciton is called
    // for the last one.  Rewind to the first so the docstrings are
    // in order.
    while ( Getattr(n, "sym:previousSibling") )
      n = Getattr(n, "sym:previousSibling");
    
    String* doc  = NewString("");
    while (n) {
      bool showTypes = false;
      bool skipAuto = false;
      String *autodoc =  Getattr(n,"feature:autodoc");
      autodoc_l dlevel = autodoc_level(autodoc);
      switch (dlevel) {
      case NO_AUTODOC:
	break;
      case NAMES_AUTODOC:
        showTypes = false;
	break;
      case TYPES_AUTODOC:
        showTypes = true;
	break;
      case EXTEND_AUTODOC:
	extended = 1;
        showTypes = false;
	break;
      case EXTEND_TYPES_AUTODOC:
	extended = 1;
        showTypes = true;
	break;
      case STRING_AUTODOC:
        Printf(doc, "%s", autodoc);
        skipAuto = true;
	break;
      }

      if (!skipAuto) {
        String*   symname = Getattr(n, "sym:name");
        SwigType* type    = Getattr(n, "type");
      
        if (type) {
          if (Strcmp(type, "void") == 0)
            type = NULL;
          else {
            SwigType* qt = SwigType_typedef_resolve_all(type);
            if (SwigType_isenum(qt))
              type = NewString("int");
            else {
              type = SwigType_base(type);
              Node* lookup = Swig_symbol_clookup(type, 0);
              if (lookup)
                type = Getattr(lookup, "sym:name");
            }
          }     
        }
        
        switch ( ad_type ) {
        case AUTODOC_CLASS:
          {
            // Only do the autodoc if there isn't a docstring for the class
            String* str = Getattr(n, "feature:docstring");
            if  (str == NULL || Len(str) == 0) {
              if (CPlusPlus) {
                Printf(doc, "Proxy of C++ %s class", class_name);
              } else {
                Printf(doc, "Proxy of C %s struct", class_name);
              }
            }
          }
	  break;
        case AUTODOC_CTOR:
          if ( Strcmp(class_name, symname) == 0) {
            String* paramList = make_autodocParmList(n, showTypes);
            if (Len(paramList))
              Printf(doc, "__init__(self, %s) -> %s", paramList, class_name);
            else
              Printf(doc, "__init__(self) -> %s", class_name);
          }              
          else
            Printf(doc, "%s(%s) -> %s", symname, make_autodocParmList(n, showTypes), class_name);
          break;
          
        case AUTODOC_DTOR:
          Printf(doc, "__del__(self)");
          break;
        
        case AUTODOC_STATICFUNC:
          Printf(doc, "%s(%s)", symname, make_autodocParmList(n, showTypes));
          if (type) Printf(doc, " -> %s", type);
          break;
                      
        case AUTODOC_FUNC:
          Printf(doc, "%s(%s)", symname, make_autodocParmList(n, showTypes));
          if (type) Printf(doc, " -> %s", type);
          break;            

        case AUTODOC_METHOD:
          String* paramList = make_autodocParmList(n, showTypes);
          if (Len(paramList))
            Printf(doc, "%s(self, %s)", symname, paramList);
          else
            Printf(doc, "%s(self)", symname);
          if (type) Printf(doc, " -> %s", type);
          break;            
        }
      }
      if (extended) {
	String *pdocs = Getattr(n,"feature:pdocs");
	if (pdocs) {
	  Printv(doc, "\n", pdocs,NULL);
	}
      }
      
      
      // if it's overloaded then get the next decl and loop around again
      n = Getattr(n, "sym:nextSibling");
      if (n)
        Printf(doc, "\n");
    }
          
    return doc;
  }

  /* ------------------------------------------------------------
   * have_pythonprepend()
   *    Check if there is a %pythonprepend directive and it has text
   * ------------------------------------------------------------ */

  bool have_pythonprepend(Node *n) {
    String* str = Getattr(n, "feature:pythonprepend");
    return (str != NULL && Len(str) > 0);
  }
  
  /* ------------------------------------------------------------
   * pythonprepend()
   *    Get the %pythonprepend code, stripping off {} if neccessary
   * ------------------------------------------------------------ */

  String *pythonprepend(Node *n) {
    String* str = Getattr(n, "feature:pythonprepend");
    char* t = Char(str);
    if (*t == '{') {
      Delitem(str ,0);
      Delitem(str,DOH_END);
    }
    return str;
  }
    
  /* ------------------------------------------------------------
   * have_pythonappend()
   *    Check if there is a %pythonappend directive and it has text
   * ------------------------------------------------------------ */

  bool have_pythonappend(Node *n) {
    String* str = Getattr(n, "feature:pythonappend");
    if (!str) str = Getattr(n, "feature:addtofunc");
    return (str != NULL && Len(str) > 0);
  }
  
  /* ------------------------------------------------------------
   * pythonappend()
   *    Get the %pythonappend code, stripping off {} if neccessary
   * ------------------------------------------------------------ */

  String *pythonappend(Node *n) {
    String* str = Getattr(n, "feature:pythonappend");
    if (!str) str = Getattr(n, "feature:addtofunc");
    
    char* t = Char(str);
    if (*t == '{') {
      Delitem(str ,0);
      Delitem(str,DOH_END);
    }
    return str;
  }

  /* ------------------------------------------------------------
   * have_addtofunc()
   *    Check if there is a %addtofunc directive and it has text
   * ------------------------------------------------------------ */

  bool have_addtofunc(Node *n) {
    return have_pythonappend(n) || have_pythonprepend(n) || have_docstring(n);
  }
  

  /* ------------------------------------------------------------
   * emitFunctionShadowHelper()
   *    Refactoring some common code out of functionWrapper and
   *    dispatchFunction that writes the proxy code for non-member
   *    functions.
   * ------------------------------------------------------------ */

  void emitFunctionShadowHelper(Node *n, File *f_dest, String *name, int kw) {
    if (Getattr(n,"feature:python:callback") || ! have_addtofunc(n) ) {
      /* If there is no addtofunc directive then just assign from the extension module */
      Printv(f_dest, "\n", name, " = ", module, ".", name, "\n", NIL);
    } else {
      /* Otherwise make a wrapper function to insert the code into */
      Printv(f_dest, "\ndef ", name, "(*args", (kw ? ", **kwargs" : ""), "):\n", NIL);
      if ( have_docstring(n) )
        Printv(f_dest, tab4, docstring(n, AUTODOC_FUNC, tab4), "\n", NIL);
      if ( have_pythonprepend(n) )
        Printv(f_dest, tab4, pythonprepend(n), "\n", NIL);
      if ( have_pythonappend(n) ) {
        Printv(f_dest, tab4, "val = ", funcCallHelper(name, kw), "\n", NIL);
        Printv(f_dest, tab4, pythonappend(n), "\n", NIL);
        Printv(f_dest, tab4, "return val\n", NIL);
      } else {
        Printv(f_dest, tab4, "return ", funcCallHelper(name, kw), "\n", NIL);
      }        
    }
  }


  /* ------------------------------------------------------------
   * check_kwargs()
   *    check if using kwargs is allowed for this Node
   * ------------------------------------------------------------ */

  int check_kwargs(Node *n) {
    return (use_kw || GetFlag(n,"feature:kwargs"));
  }


    
  /* ------------------------------------------------------------
   * add_method()
   * ------------------------------------------------------------ */

  void add_method(String *name, String *function, int kw, Node *n = 0) {
    if (!kw) 
      Printf(methods,"\t { (char *)\"%s\", %s, METH_VARARGS, ", name, function);
    else
      Printf(methods,"\t { (char *)\"%s\", (PyCFunction) %s, METH_VARARGS | METH_KEYWORDS, ", name, function);
    
    if (n && GetFlag(n,"feature:callback")) {
      if (have_docstring(n)) {
        String* ds = docstring(n, AUTODOC_FUNC, "", false);
        Replaceall(ds, "\n", "\\n");
	Printf(methods,"(char *)\"%s\\nswig_ptr: %s\"",
	       ds,
	       Getattr(n,"feature:callback:name"));
      } else {
	Printf(methods,"(char *)\"swig_ptr: %s\"",Getattr(n,"feature:callback:name"));
      }
    } else {
      Printf(methods,"NULL");
    }
    

    Printf(methods,"},\n");
  }

  /* ------------------------------------------------------------
   * dispatchFunction()
   * ------------------------------------------------------------ */
  void dispatchFunction(Node *n) {
    /* Last node in overloaded chain */

    int maxargs;
    int allow_thread = threads_enable(n);

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

    if (allow_thread) thread_begin_block(n, f->code);

    Printf(f->code,"argc = PyObject_Length(args);\n");
    Printf(f->code,"for (ii = 0; (ii < argc) && (ii < %d); ii++) {\n",maxargs);
    Printf(f->code,"argv[ii] = PyTuple_GetItem(args,ii);\n");
    Printf(f->code,"}\n");
    
    Replaceall(dispatch,"$args","self,args");

    if (allow_thread) {
      String *ret = NewStringEmpty();
      thread_end_block(n, ret);
      Append(ret, "return ");
      Replaceall(dispatch,"return ",ret);
      Delete(ret);
    }

    Printv(f->code,dispatch,"\n",NIL);

    if (allow_thread) thread_end_block(n, f->code);

    if (GetFlag(n,"feature:python:maybecall")) {
      Printf(f->code,"Py_INCREF(Py_NotImplemented);\n");
      Printf(f->code,"return Py_NotImplemented;\n");
    } else {
      Printf(f->code,"SWIG_SetErrorMsg(PyExc_NotImplementedError,\"No matching function for overloaded '%s'\");\n", symname);
      Printf(f->code,"return NULL;\n");
    }
    Printv(f->code,"}\n",NIL);
    Wrapper_print(f,f_wrappers);
    Node *p = Getattr(n, "sym:previousSibling");
    add_method(symname,wname,0,p);

    /* Create a shadow for this function (if enabled and not in a member function) */
    if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
      emitFunctionShadowHelper(n, f_shadow_stubs, symname, 0);
    }
    DelWrapper(f);
    Delete(dispatch);
    Delete(tmp);
    Delete(wname);
  }

  /* ------------------------------------------------------------
   * functionWrapper()
   * ------------------------------------------------------------ */

  virtual int functionWrapper(Node *n) {
  
    String  *name  = Getattr(n,"name");
    String  *iname = Getattr(n,"sym:name");
    SwigType *d    = Getattr(n,"type");
    ParmList *l    = Getattr(n,"parms");
    int director_method = 0;

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
    int     allow_kwargs = check_kwargs(n);

    String *nodeType = Getattr(n, "nodeType");
    int constructor = (!Cmp(nodeType, "constructor")); 
    int destructor = (!Cmp(nodeType, "destructor")); 
    String *storage   = Getattr(n,"storage");
    int isVirtual = (Cmp(storage,"virtual") == 0);
    /* Only the first constructor is handled as init method. Others
       constructor can be emitted via %rename */
    int handled_as_init = !have_constructor &&(constructor || Getattr(n,"handled_as_constructor"))
      && ((shadow & PYSHADOW_MEMBER));
      
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

    int allow_thread = threads_enable(n);
    if (allow_thread) thread_begin_block(n, f->code);
    
    Wrapper_add_local(f,"resultobj", "PyObject *resultobj = 0");

  /* Write code to extract function parameters. */
    emit_args(d, l, f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l,f);
    Setattr(n,"wrap:parms",l);
    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required  = emit_num_required(l);
    varargs = emit_isvarargs(l);
    
    String *nw = Swig_name_wrapper(iname);
    strcpy(wname,Char(nw));
    Delete(nw);
    if (overname) {
      strcat(wname,Char(overname));
    }

    if (!allow_kwargs || Getattr(n,"sym:overloaded")) {
      if (!varargs) {
	Printv(f->def,
	       "SWIGINTERN PyObject *", wname,
	       "(PyObject *SWIGUNUSEDPARM(self), PyObject *args) {",
	       NIL);
      } else {
	Printv(f->def,
	       "SWIGINTERN PyObject *", wname, "__varargs__", 
	       "(PyObject *SWIGUNUSEDPARM(self), PyObject *args, PyObject *varargs) {",
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
	     "SWIGINTERN PyObject *", wname,
	     "(PyObject *SWIGUNUSEDPARM(self), PyObject *args, PyObject *kwargs) {",
	     NIL);
    }
    if (!allow_kwargs) {
      Printf(parse_args,"    if(!PyArg_ParseTuple(args,(char *)\"");
    } else {
      Printf(parse_args,"    if(!PyArg_ParseTupleAndKeywords(args,kwargs,(char *)\"");
      Printf(arglist,",kwnames");
    }

    /* Generate code for argument marshalling */
    int use_parse = 0;
    Printf(kwargs,"{");  
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
      String *wrn = (allow_kwargs && pn) ? Swig_name_object_get(Swig_cparse_namewarn(),0,pn,0) : 0; 
      if (!wrn && Len(pn)) {
	Printf(kwargs,"(char *) \"%s\",", pn);
      } else {
	if (wrn) {
	  /*
	    we change the parameter name just a little.
	    do we need to emit a warning?
	  */
	  Printf(kwargs,"(char *) \"_%s\",", pn);
	  Swig_warning(0,Getfile(n),Getline(n), "%s, renaming parameter to _%s\n", wrn, pn);
	} else {
	  Printf(kwargs,"(char *)\"arg%d\",", i+1);
	}
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
	  Wrapper_add_localv(f, source, "PyObject *",source, "= 0", NIL);
	  Printf(arglist,"&%s",source);
	  if (i >= num_required)
	    Printv(get_pointers, "if (", source, ") {\n", NIL);
	  Printv(get_pointers,tm,"\n", NIL);
	  if (i >= num_required)
	    Printv(get_pointers, "}\n", NIL);

	} else {
	  use_parse = 1;
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
      Printv(f->locals,tab4, "char *  kwnames[] = ", kwargs, ";\n", NIL);
    }

    if (use_parse || allow_kwargs) {
      Printf(parse_args,":%s\"", iname);
      Printv(parse_args,arglist, ")) goto fail;\n",NIL);
    } else {
      Clear(parse_args);
      Printf(parse_args,"if(!PyArg_UnpackTuple(args,(char *)\"%s\",%d,%d", iname, num_required, num_arguments);
      Printv(parse_args,arglist, ")) goto fail;\n",NIL);
    }
    
    

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
      if (!checkAttribute(p,"tmap:in:numinputs","0") && 
	  !Getattr(p,"tmap:in:parse") && (tm = Getattr(p,"tmap:freearg"))) {
	if (Len(tm) != 0) {
	  Replaceall(tm,"$source",Getattr(p,"lname"));
	  Printv(cleanup,tm,"\n",NIL);
	}
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
      
    /* if the object is a director, and the method call originated from its
     * underlying python object, resolve the call by going up the c++ 
     * inheritance chain.  otherwise try to resolve the method in python.  
     * without this check an infinite loop is set up between the director and 
     * shadow class method calls.
     */

    // NOTE: this code should only be inserted if this class is the
    // base class of a director class.  however, in general we haven't
    // yet analyzed all classes derived from this one to see if they are
    // directors.  furthermore, this class may be used as the base of
    // a director class defined in a completely different module at a
    // later time, so this test must be included whether or not directorbase
    // is true.  we do skip this code if directors have not been enabled
    // at the command line to preserve source-level compatibility with
    // non-polymorphic swig.  also, if this wrapper is for a smart-pointer
    // method, there is no need to perform the test since the calling object
    // (the smart-pointer) and the director object (the "pointee") are
    // distinct.

    if (directorsEnabled()) {
      if (!is_smart_pointer()) {
        if (/*directorbase &&*/ !constructor && !destructor 
	    && isVirtual  && !Getattr(n,"feature:nodirector")) {
	  director_method = 1;
          Wrapper_add_local(f, "director", "Swig::Director *director = 0");
          Printf(f->code, "director = SWIG_DIRECTOR_CAST(arg1);\n");
	  if (dirprot_mode() && !is_public(n)) {      
            Printf(f->code, "if (!director || !(director->swig_get_inner(\"%s\"))) {\n", name);
	    Printf(f->code, "SWIG_SetErrorMsg(PyExc_RuntimeError,\"accessing protected member %s\");\n", name);
	    Printf(f->code, "SWIG_fail;\n");
	    Printf(f->code, "}\n");
	  }
          Printf(f->code, "if (director && (director->swig_get_self()==obj0)) director->swig_set_up();\n");
	}
      }
    }

    /* for constructor, determine if Python class has been subclassed.
     * if so, create a director instance.  otherwise, just create a normal instance.
     */
    /* MOVED TO Swig_ConstructorToFunction() */
    /*
    if (constructor && (Getattr(n, "wrap:self") != 0)) {
      Wrapper_add_local(f, "subclassed", "int subclassed = 0");
      Printf(f->code, "subclassed = (arg1 != SWIG_Py_None());\n");
    }
    */
     
    /* Emit the function call */
    if (director_method) {
      Printf(f->code, "try {\n");
      Printf(f->code, "  Swig::UnknownExceptionHandler dh;\n");
    } else {
      if (allow_thread) {
	Printf(f->code, "{\n");
	thread_begin_allow(n, f->code);
      }
    }
    
    emit_action(n,f);

    if (director_method) {
      Printf(f->code, "} catch (Swig::DirectorException&) {\n");
      Printf(f->code, "  SWIG_fail;\n");
      Printf(f->code, "}\n");
    } else {
      if (allow_thread) {
	thread_end_allow(n, f->code);
	Printf(f->code, "}\n");
      }
    }

    /* This part below still needs cleanup */

    /* Return the function value */
    if ((tm = Swig_typemap_lookup_new("out",n,"result",0))) {
      Replaceall(tm,"$source", "result");
      Replaceall(tm,"$target", "resultobj");
      Replaceall(tm,"$result", "resultobj");
      if (handled_as_init) {
	Replaceall(tm,"$owner","SWIG_POINTER_NEW");
      } else {      
	if (GetFlag(n,"feature:new")) {
	  Replaceall(tm,"$owner","SWIG_POINTER_OWN");
	} else {
	  Replaceall(tm,"$owner","0");
	}
      }
      // FIXME: this will not try to unwrap directors returned as non-director
      //        base class pointers!

      /* New addition to unwrap director return values so that the original
       * python object is returned instead. 
       */
#if 1
      int unwrap = 0;
      String *decl = Getattr(n, "decl");
      int is_pointer = SwigType_ispointer_return(decl);
      int is_reference = SwigType_isreference_return(decl);
      if (is_pointer || is_reference) {
        String *type = Getattr(n, "type");
  	//Node *classNode = Swig_methodclass(n);
        //Node *module = Getattr(classNode, "module");
	Node *parent   = Getattr(n,"parentNode");
        Node *module = Getattr(parent, "module");
        Node *target = Swig_directormap(module, type);
	if (target) unwrap = 1;
      }
      if (unwrap) {
      	Wrapper_add_local(f, "director", "Swig::Director *director = 0");
	Printf(f->code, "director = SWIG_DIRECTOR_CAST(result);\n");
	Printf(f->code, "if (director) {\n");
	Printf(f->code, "  resultobj = director->swig_get_self();\n");
	Printf(f->code, "  Py_INCREF(resultobj);\n");
	Printf(f->code, "} else {\n"); 
        Printf(f->code,"%s\n", tm);
        Printf(f->code, "}\n");
      } else {
        Printf(f->code,"%s\n", tm);
      }
#else
      Printf(f->code,"%s\n", tm);
#endif
      Delete(tm);
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number,
		   "Unable to use return type %s in function %s.\n", SwigType_str(d,0), name);
    }

    /* Output argument output code */
    Printv(f->code,outarg,NIL);

    /* Output cleanup code */
    int need_cleanup = Len(cleanup) != 0;
    if (need_cleanup) {
      Printv(f->code,cleanup,NIL);
    }

    /* Look to see if there is any newfree cleanup code */
    if (GetFlag(n,"feature:new")) {
      if ((tm = Swig_typemap_lookup_new("newfree",n,"result",0))) {
	Replaceall(tm,"$source","result");
	Printf(f->code,"%s\n",tm);
	Delete(tm);
      }
    }

    /* See if there is any return cleanup code */
    if ((tm = Swig_typemap_lookup_new("ret", n, "result", 0))) {
      Replaceall(tm,"$source","result");
      Printf(f->code,"%s\n",tm);
      Delete(tm);
    }

    if (director_method) {
      if ((tm = Swig_typemap_lookup_new("directorfree",n,"result",0))) {
	Replaceall(tm,"$input","result");
	Replaceall(tm,"$result","resultobj");
	Printf(f->code,"%s\n",tm);
	Delete(tm);
      }
    }

    if (allow_thread) thread_end_block(n, f->code);
    Printf(f->code,"    return resultobj;\n");

    /* Error handling code */

    Printf(f->code,"fail:\n");
    if (need_cleanup) {
      Printv(f->code,cleanup,NIL);
    }
    if (allow_thread) thread_end_block(n, f->code);
    Printv(f->code,tab4,"return NULL;\n",NIL);
    
    
    
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
	     "SWIGINTERN PyObject *", wname,
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
      add_method(iname, wname, allow_kwargs, n);

      /* Create a shadow for this function (if enabled and not in a member function) */
      if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
        emitFunctionShadowHelper(n, in_class ? f_shadow_stubs : f_shadow, iname, allow_kwargs);
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
   * variableWrapper()
   * ------------------------------------------------------------ */

  virtual int variableWrapper(Node *n) {
    String *name  = Getattr(n,"name");
    String *iname = Getattr(n,"sym:name");
    SwigType *t = Getattr(n,"type");
    
    String *getnamef;
    String *setnamef;
    static int have_globals = 0;
    String  *tm;
    Wrapper *getf, *setf;

    if (!addSymbol(iname,n)) return SWIG_ERROR;

    getf = NewWrapper();
    setf = NewWrapper();

   /* If this is our first call, add the globals variable to the
      Python dictionary. */

    if (!have_globals) {
      Printf(f_init,"\t PyDict_SetItemString(d,(char*)\"%s\", SWIG_globals());\n",global_name);
      have_globals=1;
      if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
	Printf(f_shadow_stubs,"%s = %s.%s\n", global_name, module, global_name);
      }
    }
    int assignable = is_assignable(n);

    if ((shadow) && !assignable) {
      if (!in_class) {
	Printf(f_shadow_stubs,"%s = %s.%s\n", iname, global_name, iname);
      }
    }

    getnamef = Swig_name_get(iname);
    setnamef = Swig_name_set(iname);

    /* Create a function for setting the value of the variable */

    if (assignable) {
      Printf(setf->def,"SWIGINTERN int %s(PyObject *_val) {", setnamef);
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
      Printv(setf->code,tab4,"return 0;\n",NULL);
      Printf(setf->code,"fail:\n");
      Printv(setf->code,tab4,"return 1;\n",NULL);
    } else {
      /* Is a readonly variable.  Issue an error */
      if (CPlusPlus) {
	Printf(setf->def,"SWIGINTERN int %s(PyObject *) {", setnamef);
      } else {
	Printf(setf->def,"SWIGINTERN int %s(PyObject *_val SWIGUNUSED) {", setnamef);
      }
      Printv(setf->code,
	     tab4, "SWIG_Error(SWIG_AttributeError,\"Variable ", iname," is read-only.\");\n",
	     tab4, "return 1;\n",
	     NIL);
    }

    Printf(setf->code,"}\n");
    Wrapper_print(setf,f_wrappers);

    /* Create a function for getting the value of a variable */
    Printf(getf->def,"SWIGINTERN PyObject *%s(void) {", getnamef);
    Wrapper_add_local(getf,"pyobj", "PyObject *pyobj = 0");
    if ((tm = Swig_typemap_lookup_new("varout",n,name,0))) {
      Replaceall(tm,"$source",name);
      Replaceall(tm,"$target","pyobj");
      Replaceall(tm,"$result","pyobj");
      Printf(getf->code,"%s\n", tm);
      Delete(tm);
    } else {
      Swig_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number,
		   "Unable to read variable of type %s\n", SwigType_str(t,0));
    }
    
    Printf(getf->code,"    return pyobj;\n}\n");
    Wrapper_print(getf,f_wrappers);

    /* Now add this to the variable linking mechanism */
    Printf(f_init,"\t SWIG_addvarlink(SWIG_globals(),(char*)\"%s\",%s, %s);\n", iname, getnamef, setnamef);

    Delete(getnamef);
    Delete(setnamef);
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
    String   *rawval = Getattr(n,"rawval");
    String   *value = rawval ? rawval : Getattr(n,"value");
    String  *tm;
    int     have_tm = 0;

    if (!addSymbol(iname,n)) return SWIG_ERROR;

  /* Special hook for member pointer */
    if (SwigType_type(type) == T_MPOINTER) {
      String *wname = Swig_name_wrapper(iname);
      String *str = SwigType_str(type,wname);
      Printf(f_header, "static %s = %s;\n", str, value);
      Delete(str);
      value = wname;
    }
    if ((tm = Swig_typemap_lookup_new("consttab",n,name,0))) {
      Replaceall(tm,"$source",value);
      Replaceall(tm,"$target",name);
      Replaceall(tm,"$value", value);
      Printf(const_code,"%s,\n", tm);
      Delete(tm);
      have_tm = 1;
    }
    if ((tm = Swig_typemap_lookup_new("constcode", n, name, 0))) {
      Replaceall(tm,"$source",value);
      Replaceall(tm,"$target",name);
      Replaceall(tm,"$value",value);
      Printf(f_init, "%s\n", tm);
      Delete(tm);
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
	if (!(Getattr(n,"feature:python:callback"))) {
	  Printv(f_shadow_stubs,iname, " = ", module, ".", iname, "\n", NIL);      
	}
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



/*************************************************************************************
 * BEGIN C++ Director Class modifications
 ************************************************************************************/

/* C++/Python polymorphism demo code, copyright (C) 2002 Mark Rose <mrose@stm.lbl.gov>
 *
 * TODO
 *
 * Move some boilerplate code generation to Swig_...() functions.
 *
 */

  /* ---------------------------------------------------------------
   * classDirectorMethod()
   *
   * Emit a virtual director method to pass a method call on to the 
   * underlying Python object.
   * ** Moved down due to gcc-2.96 internal error **
   * --------------------------------------------------------------- */

  int classDirectorMethods(Node *n);

  int classDirectorMethod(Node *n, Node *parent, String *super);
  
  /* ------------------------------------------------------------
   * classDirectorConstructor()
   * ------------------------------------------------------------ */

  int classDirectorConstructor(Node *n) {
    Node *parent = Getattr(n, "parentNode");
    String *sub = NewString("");
    String *decl = Getattr(n, "decl");
    String *supername = Swig_class_name(parent);
    String *classname = NewString("");
    Printf(classname, "SwigDirector_%s", supername);

    /* insert self parameter */
    Parm *p;
    ParmList *superparms = Getattr(n, "parms");
    ParmList *parms = CopyParmList(superparms);
    String *type = NewString("PyObject");
    SwigType_add_pointer(type);
    p = NewParm(type, NewString("self"));
    set_nextSibling(p, parms);
    parms = p;

    if (!Getattr(n,"defaultargs")) {
      /* constructor */
      {
        Wrapper *w = NewWrapper();
        String *call;
        String *basetype = Getattr(parent, "classtype");
        String *target = Swig_method_decl(decl, classname, parms, 0, 0);
        call = Swig_csuperclass_call(0, basetype, superparms);
        Printf(w->def, "%s::%s: %s, Swig::Director(self) { \n", classname, target, call);
        Printf(w->def, "   SWIG_DIRECTOR_RGTR((%s *)this, this); \n", basetype);
        Printf(w->def, "}\n");
        Delete(target);
        Wrapper_print(w, f_directors);
        Delete(call);
        DelWrapper(w);
      }

      /* constructor header */
      {
        String *target = Swig_method_decl(decl, classname, parms, 0, 1);
        Printf(f_directors_h, "    %s;\n", target);
        Delete(target);
      }
    }

    Delete(sub);
    Delete(classname);
    Delete(supername);
    Delete(parms);
    return Language::classDirectorConstructor(n);
  }

  /* ------------------------------------------------------------
   * classDirectorDefaultConstructor()
   * ------------------------------------------------------------ */

  int classDirectorDefaultConstructor(Node *n) {
    String *classname = Swig_class_name(n);
    {
      Node *parent = Swig_methodclass(n);
      String *basetype = Getattr(parent, "classtype");
      Wrapper *w = NewWrapper();
      Printf(w->def, "SwigDirector_%s::SwigDirector_%s(PyObject* self) : Swig::Director(self) { \n", classname, classname);
      Printf(w->def, "   SWIG_DIRECTOR_RGTR((%s *)this, this); \n", basetype);
      Printf(w->def, "}\n");
      Wrapper_print(w, f_directors);
      DelWrapper(w);
    }
    Printf(f_directors_h, "    SwigDirector_%s(PyObject* self);\n", classname);
    Delete(classname);
    return Language::classDirectorDefaultConstructor(n);
  }


  /* ------------------------------------------------------------
   * classDirectorInit()
   * ------------------------------------------------------------ */

  int classDirectorInit(Node *n) {
    String *declaration = Swig_director_declaration(n);
    Printf(f_directors_h, "\n");
    Printf(f_directors_h, "%s\n", declaration);
    Printf(f_directors_h, "public:\n");
    Delete(declaration);
    return Language::classDirectorInit(n);
  }

  /* ------------------------------------------------------------
   * classDirectorEnd()
   * ------------------------------------------------------------ */

  int classDirectorEnd(Node *n) {
    String *classname = Swig_class_name(n);

    if (dirprot_mode()) {
      /*
	This implementation uses a std::map<std::string,int>.

	It should be possible to rewrite it using a more elegant way,
	like copying the Java approach for the 'override' array.

	But for know, this seems to be the least intrusive way.
      */
      Printf(f_directors_h,"\n\n");
      Printf(f_directors_h,"/* Internal Director utilities */\n");
      Printf(f_directors_h,"public:\n");
      Printf(f_directors_h,"    bool swig_get_inner(const char* name) const {\n");
      Printf(f_directors_h,"      std::map<std::string, bool>::const_iterator iv = inner.find(name);\n");
      Printf(f_directors_h,"      return (iv != inner.end() ? iv->second : false);\n");
      Printf(f_directors_h,"    }\n\n");
      
      Printf(f_directors_h,"    void swig_set_inner(const char* name, bool val) const\n");
      Printf(f_directors_h,"    { inner[name] = val;}\n\n");
      Printf(f_directors_h,"private:\n");
      Printf(f_directors_h,"    mutable std::map<std::string, bool> inner;\n");

    }

    Printf(f_directors_h,"\n\n");
    Printf(f_directors_h,"public:\n");
    Printf(f_directors_h,"#if defined(SWIG_DIRECTOR_VTABLE)\n");
    Printf(f_directors_h,"/* VTable implementation */\n");
    Printf(f_directors_h,"    PyObject *swig_get_method(size_t method_index, const char *method_name) const {\n");
    Printf(f_directors_h,"      PyObject *method = vtable[method_index];\n");
    Printf(f_directors_h,"      if (!method) {\n");
    Printf(f_directors_h,"        swig::PyObject_var name = PyString_FromString(method_name);\n");
    Printf(f_directors_h,"        method = PyObject_GetAttr(swig_get_self(), name);\n");
    Printf(f_directors_h,"        if (method == NULL) {\n");
    Printf(f_directors_h,"          std::string msg = \"Method in class %s doesn't exist, undefined \";\n", classname);
    Printf(f_directors_h,"          msg += method_name;\n");
    Printf(f_directors_h,"          Swig::DirectorMethodException::raise(msg.c_str());\n");
    Printf(f_directors_h,"        }\n");
    Printf(f_directors_h,"        Py_DECREF(swig_get_self());\n");
    Printf(f_directors_h,"        vtable[method_index] = method;\n");
    Printf(f_directors_h,"      };\n");
    Printf(f_directors_h,"      return method;\n");
    Printf(f_directors_h,"    }\n");
    Printf(f_directors_h,"private:\n");
    Printf(f_directors_h,"    mutable swig::PyObject_var vtable[%d];\n", director_method_index);
    Printf(f_directors_h,"#endif\n\n");
      
    Printf(f_directors_h, "};\n\n");
    return Language::classDirectorEnd(n);
  }
  
  
  /* ------------------------------------------------------------
   * classDirectorDisown()
   * ------------------------------------------------------------ */

  int classDirectorDisown(Node *n) {
    int result;
    int oldshadow = shadow;
    /* disable shadowing */
    if (shadow) shadow = shadow | PYSHADOW_MEMBER;
    result = Language::classDirectorDisown(n);
    shadow = oldshadow;
    if (shadow) {
      String *symname = Getattr(n,"sym:name");
      String *mrename = Swig_name_disown(symname); //Getattr(n, "name"));
      Printv(f_shadow, tab4, "def __disown__(self):\n", NIL);
#ifdef USE_THISOWN
      Printv(f_shadow, tab8, "self.thisown = 0\n", NIL);
#else
      Printv(f_shadow, tab8, "self.this.disown()\n", NIL);
#endif
      Printv(f_shadow, tab8, module, ".", mrename,"(self)\n", NIL);
      Printv(f_shadow, tab8, "return weakref_proxy(self)\n", NIL);
      Delete(mrename);
    }
    return result;
  }

/*************************************************************************************
 * END of C++ Director Class modifications
 ************************************************************************************/
 

  /* ------------------------------------------------------------
   * classDeclaration()
   * ------------------------------------------------------------ */

  virtual int classDeclaration(Node *n) {
    if (shadow && !Getattr(n,"feature:onlychildren")) {
      Node   *mod = Getattr(n,"module");
      if (mod) {
	String *importname = NewString("");
	String *modname = Getattr(mod,"name");
	if (Strcmp(modname,mainmodule) != 0) {
          // check if the module has a package option
          Node *options = Getattr(mod, "options");
          String* pkg = options ? Getattr(options, "package") : 0;
          if (pkg && (!package || Strcmp(pkg, package) != 0)) {
            Printf(importname,"%s.", pkg);
	  }
	  Printf(importname,"%s.", modname);
	}
	Printf(importname,"%s", Getattr(n,"sym:name"));
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
    int oldmodern  = modern;
    File   *f_shadow_file = f_shadow;

    if (shadow) {

      /* Create new strings for building up a wrapper function */
      have_constructor = 0;
      have_repr = 0;
      
      if (GetFlag(n,"feature:classic")) {
        classic = 1;
        modern  = 0;
      }
      if (GetFlag(n,"feature:modern")) {
        classic = 0;
        modern = 1;
      }
      if (GetFlag(n,"feature:exceptionclass")) {
	classic = 1;
        modern  = 0;
      }

      shadow_indent = (String *) tab4;
      
      class_name = Getattr(n,"sym:name");
      real_classname = Getattr(n,"name");
      
      if (!addSymbol(class_name,n)) return SWIG_ERROR;
      
      /* Handle inheritance */
      String *base_class = NewString("");
      List *baselist = Getattr(n,"bases");
      if (baselist && Len(baselist)) {
	Iterator b;
	b = First(baselist);
	while (b.item) {
	  String *bname = Getattr(b.item, "python:proxy");
	  if (!bname || GetFlag(b.item,"feature:ignore")) {
	    b = Next(b);
	    continue;
	  }
	  Printv(base_class,bname,NIL);
	  b = Next(b);
	  if (b.item) {
	    Putc(',',base_class);
	  }
	}
      }
      Printv(f_shadow,"class ", class_name, NIL);

      if (Len(base_class)) {
	Printf(f_shadow,"(%s)", base_class);
      } else {
	if (!classic) {
	  Printf(f_shadow, modern ? "(object)" : "(_object)");
	}
      }
      Printf(f_shadow,":\n");
      if ( have_docstring(n) ) {
        String* str = docstring(n, AUTODOC_CLASS, tab4);
        if (str != NULL && Len(str)) 
          Printv(f_shadow, tab4, str, "\n", NIL);
      }
      if (!modern) {
        Printv(f_shadow,tab4,"__swig_setmethods__ = {}\n",NIL);
        if (Len(base_class)) {
          Printf(f_shadow,"%sfor _s in [%s]: __swig_setmethods__.update(_s.__swig_setmethods__)\n",tab4,base_class);
        }

	if (!GetFlag(n,"feature:python:nondynamic")) {
	  Printv(f_shadow,
		 tab4, "__setattr__ = lambda self, name, value: _swig_setattr(self, ", class_name, ", name, value)\n",
		 NIL);
	} else {
	  Printv(f_shadow,
		 tab4, "__setattr__ = lambda self, name, value: _swig_setattr_nondynamic(self, ", class_name, ", name, value)\n",
		 NIL);
	}	

        Printv(f_shadow,tab4,"__swig_getmethods__ = {}\n",NIL);
        if (Len(base_class)) {
          Printf(f_shadow,"%sfor _s in [%s]: __swig_getmethods__.update(_s.__swig_getmethods__)\n",tab4,base_class);
        }
      
        Printv(f_shadow,
               tab4, "__getattr__ = lambda self, name: _swig_getattr(self, ", class_name, ", name)\n",
               NIL);
      } else {
	Printv(f_shadow, tab4, "if _newclass: thisown = property(lambda x: x.this.own(), ",
	       "lambda x, v: x.this.own(v), doc='The membership flag')\n", NIL);
	/* Add static attribute */
	if (GetFlag(n,"feature:python:nondynamic")) {
	  Printv(f_shadow_file,
		 tab4, "__setattr__ = _swig_setattr_nondynamic_method(object.__setattr__)\n",
		 tab4, "class __metaclass__(type):\n",
		 tab4, tab4, "__setattr__ = _swig_setattr_nondynamic_method(type.__setattr__)\n",
		 NIL);
	}	
      }
    }
    
    /* Emit all of the members */

    in_class = 1;

    /* Overide the shadow file so we can capture its methods */
    f_shadow = NewString(""); 

    Language::classHandler(n);
    in_class = 0;

    /* Complete the class */
    if (shadow) {
      /* Generate a class registration function */
      {
	SwigType  *ct = NewStringf("p.%s", real_classname);
	SwigType_remember(ct);
	Printv(f_wrappers,
	       "SWIGINTERN PyObject * ", class_name, "_swigregister(PyObject *SWIGUNUSEDPARM(self), PyObject *args) {\n", NIL);
	Printv(f_wrappers,
	       tab4, "PyObject *obj;\n",
	       tab4, "if (!PyArg_UnpackTuple(args,(char*)\"swigregister\", 1, 1,&obj)) return NULL;\n",
	       tab4, "SWIG_TypeNewClientData(SWIGTYPE", SwigType_manglestr(ct),", SWIG_NewClientData(obj));\n",
	       tab4, "return SWIG_Py_Void();\n",
	       "}\n",NIL);
	String *cname = NewStringf("%s_swigregister", class_name);
	add_method(cname, cname, 0);
	Delete(cname);
	Delete(ct);
      }
      if (!have_constructor) {
	Printv(f_shadow_file, tab4,"def __init__(self): raise AttributeError, \"No constructor defined\"\n", NIL);
      }

      if (!have_repr) {
	/* Supply a repr method for this class  */
	String *rname = SwigType_namestr(real_classname);
	if (new_repr) {
	  Printv(f_shadow_file,
                 tab4, "def __repr__(self):\n",
		 tab8, "try: strthis = \"at 0x%x\" %( self.this, ) \n",
		 tab8, "except: strthis = \"\" \n",
                 tab8, "return \"<%s.%s; proxy of ", CPlusPlus ? "C++ " : "C ", rname," instance %s>\" % (self.__class__.__module__, self.__class__.__name__, strthis,)\n",
                 NIL);
	}
	else {
	  Printv(f_shadow_file,
	         tab4, "def __repr__(self):\n",
  	         tab8, "return \"<C ", rname," instance at 0x%x>\" % (self.this,)\n",
	         NIL);
	}
	Delete(rname);
      }


      /* Now emit methods */
      Printv(f_shadow_file, f_shadow, NIL);

      /* Now the Ptr class */
      if (classptr) {
	Printv(f_shadow_file,
	       "\nclass ", class_name, "Ptr(", class_name, "):\n",
	       tab4, "def __init__(self, this):\n", NIL);
	if (!modern) {
	  Printv(f_shadow_file,
		 tab8, "try: self.this.append(this)\n",
		 tab8, "except: self.this = this\n",
#ifdef USE_THISOWN
		 tab8, "if not hasattr(self,\"thisown\"): _swig_setattr(self, ", class_name, ", 'thisown', 0)\n",
#else
		 tab8, "self.this.own(0)\n",
#endif
		 tab8, "self.__class__ = ", class_name, "\n\n", NIL);
	} else {
	  Printv(f_shadow_file,
		 tab8, "try: self.this.append(this)\n",
		 tab8, "except: self.this = this\n",
#ifdef USE_THISOWN
		 tab8, "if not hasattr(self,\"thisown\"): self.thisown = 0\n",
#else
		 tab8, "self.this.own(0)\n",
#endif
		 tab8, "self.__class__ = ", class_name, "\n\n", NIL);
	}
      }
      
      
      List *shadow_list = Getattr(n,"shadow_methods");
      for (int i = 0; i < Len(shadow_list); ++i) {
	String *symname = Getitem(shadow_list,i);
	Printf(f_shadow_file,"%s.%s = new_instancemethod(%s.%s,None,%s)\n", 
	       class_name, symname, module, Swig_name_member(class_name,symname), class_name,0);
      }
      Printf(f_shadow_file,"%s.%s_swigregister(%s)\n", module, class_name, class_name,0);
      
      shadow_indent = 0;
      Printf(f_shadow_file,"%s\n", f_shadow_stubs);
      Clear(f_shadow_stubs);
    }
    classic = oldclassic;
    modern  = oldmodern;

    /* Restore shadow file back to original version */
    Delete(f_shadow);
    f_shadow = f_shadow_file;

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * functionHandler()  -  Mainly overloaded for callback handling
   * ------------------------------------------------------------ */

  virtual int functionHandler(Node *n) {
    String *pcb = GetFlagAttr(n,"feature:python:callback");
    if (pcb) {
      if (Strcmp(pcb,"1") == 0) {
	SetFlagAttr(n,"feature:callback","%s_cb_ptr");
      } else {
	SetFlagAttr(n,"feature:callback",pcb);
      }
      autodoc_l dlevel = autodoc_level(Getattr(n, "feature:autodoc"));
      if (dlevel != NO_AUTODOC && dlevel > TYPES_AUTODOC) {
	Setattr(n,"feature:autodoc","1");
      }
    }
    return Language::functionHandler(n);
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
	int allow_kwargs = (check_kwargs(n) && !Getattr(n,"sym:overloaded")) ? 1 : 0;
	if (Strcmp(symname,"__repr__") == 0)
	  have_repr = 1;
	
	if (Getattr(n,"feature:shadow")) {
	  String *pycode = pythoncode(Getattr(n,"feature:shadow"),tab4);
	  String *pyaction = NewStringf("%s.%s", module, Swig_name_member(class_name,symname));
	  Replaceall(pycode,"$action", pyaction);
	  Delete(pyaction);
	  Printv(f_shadow,pycode,"\n",NIL);
	  Delete(pycode);
	} else {
	  if (!have_addtofunc(n)) {
	    if (!allow_kwargs) {
	      List *shadow_list = Getattr(getCurrentClass(),"shadow_methods");
	      if (!shadow_list) {
		shadow_list = NewList();
		Setattr(getCurrentClass(),"shadow_methods", shadow_list);
		Delete(shadow_list);
	      }
	      Append(shadow_list, symname);
	    } else {
	      Printv(f_shadow, tab4, "def ", symname, "(*args", (allow_kwargs ? ", **kwargs" : ""), "):", NIL);
	      Printv(f_shadow, " return ", funcCallHelper(Swig_name_member(class_name,symname), allow_kwargs), "\n", NIL);
	    }
	  } else {
	    Printv(f_shadow, tab4, "def ", symname, "(*args", (allow_kwargs ? ", **kwargs" : ""), "):", NIL);
            Printv(f_shadow, "\n", NIL);
            if ( have_docstring(n) )
              Printv(f_shadow, tab8, docstring(n, AUTODOC_METHOD, tab8), "\n", NIL);
            if ( have_pythonprepend(n) )
              Printv(f_shadow, tab8, pythonprepend(n), "\n", NIL);
            if ( have_pythonappend(n) ) {
              Printv(f_shadow, tab8, "val = ", funcCallHelper(Swig_name_member(class_name,symname), allow_kwargs), "\n", NIL);
              Printv(f_shadow, tab8, pythonappend(n), "\n", NIL);
              Printv(f_shadow, tab8, "return val\n\n", NIL);
            } else {
              Printv(f_shadow, tab8, "return ", funcCallHelper(Swig_name_member(class_name,symname), allow_kwargs), "\n\n", NIL);
            }
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

    if (Getattr(n,"sym:nextSibling")) {
      return SWIG_OK;
    }
    
    if (shadow) {
      if ( !classic && !Getattr(n,"feature:python:callback") && have_addtofunc(n)) {
        int kw = (check_kwargs(n) && !Getattr(n,"sym:overloaded")) ? 1 : 0;
        Printv(f_shadow, tab4, "def ", symname, "(*args", (kw ? ", **kwargs" : ""), "):\n", NIL);
        if ( have_docstring(n) )
          Printv(f_shadow, tab8, docstring(n, AUTODOC_STATICFUNC, tab8), "\n", NIL);
        if ( have_pythonprepend(n) )
          Printv(f_shadow, tab8, pythonprepend(n), "\n", NIL);
        if ( have_pythonappend(n) ) {
          Printv(f_shadow, tab8, "val = ", funcCallHelper(Swig_name_member(class_name, symname), kw), "\n", NIL);
          Printv(f_shadow, tab8, pythonappend(n), "\n", NIL);
          Printv(f_shadow, tab8, "return val\n\n", NIL);
        } else {
          Printv(f_shadow, tab8, "return ", funcCallHelper(Swig_name_member(class_name, symname), kw), "\n\n", NIL);
        }
        Printv(f_shadow, tab4, modern ? "" : "if _newclass:",  symname,
               " = staticmethod(", symname, ")\n", NIL);

        if (!modern) {
          Printv(f_shadow, tab4, "__swig_getmethods__[\"", symname, "\"] = lambda x: ", symname, "\n",  NIL);
        }
       
      } else {
        if (!modern) {
          Printv(f_shadow, tab4, "__swig_getmethods__[\"", symname, "\"] = lambda x: ", module, ".", Swig_name_member(class_name, symname), "\n",  NIL);
        }
        if (!classic) {
	  Printv(f_shadow, tab4, modern ? "" : "if _newclass:",  symname,
		 " = staticmethod(", module, ".",
		 Swig_name_member(class_name, symname), ")\n", NIL);
	}
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
    int   use_director = Swig_directorclass(n);

    /* 
     * If we're wrapping the constructor of a C++ director class, prepend a new parameter
     * to receive the scripting language object (e.g. 'self')
     *
     */
    Swig_save("python:constructorHandler",n,"parms",NIL);
    if (use_director) {
          Parm *parms = Getattr(n, "parms");
	  Parm *self;
	  String *name = NewString("self");
          String *type = NewString("PyObject");
          SwigType_add_pointer(type);
	  self = NewParm(type, name);
	  Delete(type);
	  Delete(name);
	  Setattr(self, "lname", "O");
	  if (parms) set_nextSibling(self, parms);
	  Setattr(n, "parms", self);
	  Setattr(n, "wrap:self", "1");
	  Delete(self);
    }
  
    if (shadow) shadow = shadow | PYSHADOW_MEMBER;
    Language::constructorHandler(n);
    shadow = oldshadow;

    Delattr(n, "wrap:self");
    Swig_restore(n);

    if (!Getattr(n,"sym:nextSibling")) {
      if (shadow) {
	int allow_kwargs = (check_kwargs(n) && (!Getattr(n,"sym:overloaded"))) ? 1 : 0;
	if (!have_constructor) {
	  if (Getattr(n,"feature:shadow")) {
	    String *pycode = pythoncode(Getattr(n,"feature:shadow"),tab4);
	    String *pyaction = NewStringf("%s.%s",module, Swig_name_construct(symname));
	    Replaceall(pycode,"$action", pyaction);
	    Delete(pyaction);
	    Printv(f_shadow,pycode,"\n",NIL);
	    Delete(pycode);
	  } else {
	    String *pass_self = NewString("");
	    Node *parent = Swig_methodclass(n);
	    String *classname = Swig_class_name(parent);
	    String *rclassname = Swig_class_name(getCurrentClass());
	    assert(rclassname);
	    if (use_director) {	      
 	      Printv(pass_self, tab8, NIL);
	      Printf(pass_self, "if self.__class__ == %s:\n", classname);
	      Printv(pass_self, tab8, tab4, "args = (None,) + args\n",
	                        tab8, "else:\n",
		                tab8, tab4, "args = (self,) + args\n",
                                NIL);
 	    }

            Printv(f_shadow, tab4, "def __init__(self, *args",
		   (allow_kwargs ? ", **kwargs" : ""),"):\n", NIL);
            if ( have_docstring(n) )
              Printv(f_shadow, tab8, docstring(n, AUTODOC_CTOR, tab8), "\n", NIL);
            if ( have_pythonprepend(n) )
              Printv(f_shadow, tab8, pythonprepend(n), "\n", NIL);
            Printv(f_shadow, pass_self, NIL);
	    Printv(f_shadow, tab8, "this = ", funcCallHelper(Swig_name_construct(symname), allow_kwargs),"\n", NIL);
            if (!modern) {
              Printv(f_shadow, tab8, "try: self.this.append(this)\n", NIL);
              Printv(f_shadow, tab8, "except: self.this = this\n", NIL);
              Printv(f_shadow, 
#ifdef USE_THISOWN
                     tab8, "_swig_setattr(self, ", rclassname, ", 'thisown', 1)\n",
#endif
                     NIL);
            } else {
              Printv(f_shadow, tab8, "try: self.this.append(this)\n", NIL);
              Printv(f_shadow, tab8, "except: self.this = this\n", NIL);
#ifdef USE_THISOWN
              Printv(f_shadow, tab8, "self.thisown = 1\n", NIL);
              Printv(f_shadow, tab8, "del newobj.thisown\n", NIL);
#endif
            }
            if ( have_pythonappend(n) )
              Printv(f_shadow, tab8, pythonappend(n), "\n\n", NIL);
  	    Delete(pass_self);
  	  }
	  have_constructor = 1;
	} else {
	  /* Hmmm. We seem to be creating a different constructor.  We're just going to create a
	     function for it. */

	  if (Getattr(n,"feature:shadow")) {
	    String *pycode = pythoncode(Getattr(n,"feature:shadow"),"");
	    String *pyaction = NewStringf("%s.%s", module, Swig_name_construct(symname));
	    Replaceall(pycode,"$action", pyaction);
	    Delete(pyaction);
	    Printv(f_shadow_stubs,pycode,"\n",NIL);
	    Delete(pycode);
	  } else {

            Printv(f_shadow_stubs, "\ndef ", symname, "(*args",
                   (allow_kwargs ? ", **kwargs" : ""), "):\n", NIL);
            if ( have_docstring(n) )
              Printv(f_shadow_stubs, tab4, docstring(n, AUTODOC_CTOR, tab4), "\n", NIL);
            if ( have_pythonprepend(n) )
              Printv(f_shadow_stubs, tab4, pythonprepend(n), "\n", NIL);
            Printv(f_shadow_stubs, tab4, "val = ",
                   funcCallHelper(Swig_name_construct(symname), allow_kwargs), "\n", NIL);
#ifdef USE_THISOWN
	    Printv(f_shadow_stubs, tab4, "val.thisown = 1\n", NIL);
#endif
            if ( have_pythonappend(n) )
              Printv(f_shadow_stubs, tab4, pythonappend(n), "\n", NIL);
            Printv(f_shadow_stubs, tab4, "return val\n", NIL);
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
    //Setattr(n,"emit:dealloc","1");
    Language::destructorHandler(n);
    shadow = oldshadow;
    if (shadow) {
      if (Getattr(n,"feature:shadow")) {
	String *pycode = pythoncode(Getattr(n,"feature:shadow"), tab4);
	String *pyaction = NewStringf("%s.%s", module, Swig_name_destroy(symname));
	Replaceall(pycode, "$action", pyaction);
	Delete(pyaction);
	Printv(f_shadow,pycode,"\n", NIL);
	Delete(pycode);
      } else {
	Printv(f_shadow, tab4, "__swig_destroy__ = ", module, ".", Swig_name_destroy(symname), "\n", NIL);
	if (!have_pythonprepend(n) && !have_pythonappend(n)) {
	  if (proxydel) {
	    Printv(f_shadow, tab4, "__del__ = lambda self : None;\n", NIL);
	  }
	  return SWIG_OK;
	}
	Printv(f_shadow, tab4, "def __del__(self):\n", NIL);
        if ( have_docstring(n) )
	  Printv(f_shadow, tab8, docstring(n, AUTODOC_DTOR, tab8), "\n", NIL);
	if ( have_pythonprepend(n) )
	  Printv(f_shadow, tab8, pythonprepend(n), "\n", NIL);
#ifdef USE_THISOWN
	Printv(f_shadow, tab8, "try:\n", NIL);
	Printv(f_shadow, tab8, tab4, "if self.thisown: ", module, ".", Swig_name_destroy(symname),"(self)\n", NIL);
	Printv(f_shadow, tab8, "except: pass\n", NIL);
#else
#endif
	if ( have_pythonappend(n) )
	  Printv(f_shadow, tab8, pythonappend(n), "\n", NIL);
	Printv(f_shadow, tab8, "pass\n", NIL);
        Printv(f_shadow, "\n", NIL);
      }
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

    String *mname = Swig_name_member(class_name,symname);
    String *sname = Swig_name_set(mname);
    String *gname = Swig_name_get(mname);
    if (shadow) {
      int assignable = is_assignable(n);
      if (!modern) {
        if (assignable) {
          Printv(f_shadow, tab4, "__swig_setmethods__[\"", symname, "\"] = ", module, ".", sname, "\n", NIL); 
        } 
        Printv(f_shadow, tab4, "__swig_getmethods__[\"", symname, "\"] = ", module, ".", gname,"\n", NIL);
      }
      if (!classic) {
	if (!assignable) {
	  Printv(f_shadow, tab4, modern ? "" : "if _newclass:", symname," = property(", module, ".",  gname,")\n", NIL);
	} else {
	  Printv(f_shadow, tab4, modern ? "" : "if _newclass:", symname," = property(",  module, ".", gname,", ", module, ".", sname,")\n", NIL);
	}
      }
    }
    Delete(mname);
    Delete(sname);
    Delete(gname);

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
	String *mname = Swig_name_member(class_name,symname);
	Printf(f_shadow_stubs,"%s.%s = %s.%s.%s\n", class_name, symname, module, global_name, mname);
	Delete(mname);
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
	Printv(f_shadow, pycode, NIL);
	Delete(pycode);
      }
    } else {
      Language::insertDirective(n);
    }
    return SWIG_OK;
  }

  virtual String *runtimeCode() {
    String *s = Swig_include_sys("pyrun.swg");
    if (!s) {
      Printf(stderr, "*** Unable to open 'pyrun.swg'\n");
      s = NewString("");
    }
    return s;
  }

  virtual String *defaultExternalRuntimeFilename() {
    return NewString("swigpyrun.h");
  }
  
};

/* ---------------------------------------------------------------
 * classDirectorMethod()
 *
 * Emit a virtual director method to pass a method call on to the 
 * underlying Python object.
 *
 * ** Moved it here due to internal error on gcc-2.96 **
 * --------------------------------------------------------------- */
int PYTHON::classDirectorMethods(Node *n) {
  director_method_index = 0;  
  return Language::classDirectorMethods(n);
}


int PYTHON::classDirectorMethod(Node *n, Node *parent, String *super) {
  int is_void = 0;
  int is_pointer = 0;
  String *decl;
  String *type;
  String *name;
  String *classname;
  String *declaration;
  ParmList *l;
  Wrapper *w;
  String *tm;
  String *wrap_args;
  String *return_type;
  String *value = Getattr(n, "value");
  String *storage = Getattr(n,"storage");
  bool pure_virtual = false;
  int status = SWIG_OK;
  int idx;

  if (Cmp(storage,"virtual") == 0) {
    if (Cmp(value,"0") == 0) {
      pure_virtual = true;
    }
  }

  classname = Getattr(parent, "sym:name");
  type = Getattr(n, "type");
  name = Getattr(n, "name");

  w = NewWrapper();
  declaration = NewString("");
	
  /* determine if the method returns a pointer */
  decl = Getattr(n, "decl");
  is_pointer = SwigType_ispointer_return(decl);
  is_void = (!Cmp(type, "void") && !is_pointer);

  /* form complete return type */
  return_type = Copy(type);
  {
    SwigType *t = Copy(decl);
    SwigType *f = 0;
    f = SwigType_pop_function(t);
    SwigType_push(return_type, t);
    Delete(f);
    Delete(t);
  }

  /* virtual method definition */
  l = Getattr(n, "parms");
  String *target;
  String *pclassname = NewStringf("SwigDirector_%s", classname);
  String *qualified_name = NewStringf("%s::%s", pclassname, name);
  target = Swig_method_decl(decl, qualified_name, l, 0, 0);
  String *rtype = SwigType_str(type, 0);
  Printf(w->def, "%s %s", rtype, target);
  Delete(qualified_name);
  Delete(target);
  /* header declaration */
  target = Swig_method_decl(decl, name, l, 0, 1);
  Printf(declaration, "    virtual %s %s", rtype, target);
  Delete(target);
    
  // Get any exception classes in the throws typemap
  ParmList *throw_parm_list = 0;

  if ((throw_parm_list = Getattr(n,"throws")) || Getattr(n,"throw")) {
    Parm      *p;
    int       gencomma = 0;

    Append(w->def, " throw(");
    Append(declaration, " throw(");

    if (throw_parm_list) Swig_typemap_attach_parms("throws", throw_parm_list, 0);
    for (p = throw_parm_list; p; p=nextSibling(p)) {
      if ((tm = Getattr(p,"tmap:throws"))) {
	if (gencomma++) {
	  Append(w->def, ", ");
	  Append(declaration, ", ");
	}
	String *str = SwigType_str(Getattr(p, "type"),0);
	Printf(w->def, "%s", str);
	Printf(declaration, "%s", str);
	Delete(str);
      }
    }

    Append(w->def, ")");
    Append(declaration, ")");
  }


  Append(w->def, " {");
  Append(declaration, ";\n");

  /* attach typemaps to arguments (C/C++ -> Python) */
  String *arglist = NewString("");
  String* parse_args = NewString("");

  /* remove the wrapper 'w' since it was producing spurious temps */
  Swig_typemap_attach_parms("in", l, 0);
  Swig_typemap_attach_parms("directorin", l, 0);
  Swig_typemap_attach_parms("directorargout", l, w);

  Parm* p;
  char source[256];

  wrap_args = NewString("");
  int outputs = 0;
  if (!is_void) outputs++;
	
  /* build argument list and type conversion string */
  idx = 0;
  p = l;
  int use_parse = 0;
  while (p != NULL) {
    if (checkAttribute(p,"tmap:in:numinputs","0")) {
      p = Getattr(p,"tmap:in:next");
      continue;
    }

    /* old style?  caused segfaults without the p!=0 check
       in the for() condition, and seems dangerous in the
       while loop as well.
       while (Getattr(p, "tmap:ignore")) {
       p = Getattr(p, "tmap:ignore:next");
       }
    */

    if (Getattr(p, "tmap:directorargout") != 0) outputs++;
      
    String* pname = Getattr(p, "name");
    String* ptype = Getattr(p, "type");
      
    Putc(',',arglist);
    if ((tm = Getattr(p, "tmap:directorin")) != 0) {
      String* parse = Getattr(p, "tmap:directorin:parse");
      if (!parse) {
	sprintf(source, "obj%d", idx++);
	String *input = NewStringf("%s", source);	
	Replaceall(tm, "$input", input);
	Delete(input);
	Replaceall(tm, "$owner", "0");
	/* Wrapper_add_localv(w, source, "swig::PyObject_var", source, "= 0", NIL);*/
	Printv(wrap_args, "swig::PyObject_var ", source, ";\n", NIL);
	
	Printv(wrap_args, tm, "\n", NIL);
	Printv(arglist, "(PyObject *)",source, NIL);
	Putc('O', parse_args);
      } else {
	use_parse = 1;
	Printf(parse_args, "%s", parse);
	Replaceall(tm, "$input", pname);
	Replaceall(tm, "$owner", "0");
	if (Len(tm) == 0) Append(tm, pname);
	Printf(arglist, "%s", tm);
      }
      p = Getattr(p, "tmap:directorin:next");
      continue;
    } else
      if (Cmp(ptype, "void")) {
	/* special handling for pointers to other C++ director classes.
	 * ideally this would be left to a typemap, but there is currently no
	 * way to selectively apply the dynamic_cast<> to classes that have
	 * directors.  in other words, the type "SwigDirector_$1_lname" only exists
	 * for classes with directors.  we avoid the problem here by checking
	 * module.wrap::directormap, but it's not clear how to get a typemap to
	 * do something similar.  perhaps a new default typemap (in addition
	 * to SWIGTYPE) called DIRECTORTYPE?
	 */
	if (SwigType_ispointer(ptype) || SwigType_isreference(ptype)) {
	  Node *module = Getattr(parent, "module");
	  Node *target = Swig_directormap(module, ptype);
	  sprintf(source, "obj%d", idx++);
	  String *nonconst = 0;
	  /* strip pointer/reference --- should move to Swig/stype.c */
	  String *nptype = NewString(Char(ptype)+2);
	  /* name as pointer */
	  String *ppname = Copy(pname);
	  if (SwigType_isreference(ptype)) {
	    Insert(ppname,0,"&");
	  }
	  /* if necessary, cast away const since Python doesn't support it! */
	  if (SwigType_isconst(nptype)) {
	    nonconst = NewStringf("nc_tmp_%s", pname);
	    String *nonconst_i = NewStringf("= const_cast<%s>(%s)", SwigType_lstr(ptype, 0), ppname);
	    Wrapper_add_localv(w, nonconst, SwigType_lstr(ptype, 0), nonconst, nonconst_i, NIL);
	    Delete(nonconst_i);
	    Swig_warning(WARN_LANG_DISCARD_CONST, input_file, line_number,
		         "Target language argument '%s' discards const in director method %s::%s.\n", 
			 SwigType_str(ptype, pname), classname, name);
	  } else {
	    nonconst = Copy(ppname);
	  }
	  Delete(nptype);
	  Delete(ppname);
	  String *mangle = SwigType_manglestr(ptype);
	  if (target) {
	    String *director = NewStringf("director_%s", mangle);
	    Wrapper_add_localv(w, director, "Swig::Director *", director, "= 0", NIL);
	    Wrapper_add_localv(w, source, "swig::PyObject_var", source, "= 0", NIL);
	    Printf(wrap_args, "%s = SWIG_DIRECTOR_CAST(%s);\n", director, nonconst);
	    Printf(wrap_args, "if (!%s) {\n", director);
	    Printf(wrap_args,   "%s = SWIG_NewPointerObj(%s, SWIGTYPE%s, 0);\n", source, nonconst, mangle);
	    Printf(wrap_args, "} else {\n");
	    Printf(wrap_args,   "%s = %s->swig_get_self();\n", source, director);
	    Printf(wrap_args,   "Py_INCREF((PyObject *)%s);\n", source);
	    Printf(wrap_args, "}\n");
	    Delete(director);
	    Printv(arglist, source, NIL);
	  } else {
	    Wrapper_add_localv(w, source, "swig::PyObject_var", source, "= 0", NIL);
	    Printf(wrap_args, "%s = SWIG_NewPointerObj(%s, SWIGTYPE%s, 0);\n", 
	           source, nonconst, mangle); 
	    //Printf(wrap_args, "%s = SWIG_NewPointerObj(%s, SWIGTYPE_p_%s, 0);\n", 
	    //       source, nonconst, base);
	    Printv(arglist, source, NIL);
	  }
	  Putc('O', parse_args);
	  Delete(mangle);
	  Delete(nonconst);
	} else {
	  Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF, input_file, line_number,
		       "Unable to use type %s as a function argument in director method %s::%s (skipping method).\n", SwigType_str(ptype, 0), classname, name);
          status = SWIG_NOWRAP;
	  break;
	}
      }
    p = nextSibling(p);
  }


/* add the method name as a PyString */
  String *pyname = Getattr(n,"sym:name");

  int allow_thread = threads_enable(n);

  /* direct call to superclass if _up is set */
  if (allow_thread) thread_begin_block(n, w->code);
  Printf(w->code, "if (swig_get_up()) {\n");
  if (pure_virtual) {
    Printf(w->code,
	   "Swig::DirectorPureVirtualException::raise(\"%s.\");\n",Swig_method_call(super,l));
  } else { 
    if (allow_thread) thread_begin_allow(n, w->code);
    if (is_void) {
      Printf(w->code, "%s;\n", Swig_method_call(super,l));
      Printf(w->code, "return;\n");
    } else {
      Printf(w->code, "return %s;\n", Swig_method_call(super,l));
    }
    if (allow_thread) thread_end_allow(n, w->code);
  }
  Printf(w->code, "}\n");

  /* declare method return value 
   * if the return value is a reference or const reference, a specialized typemap must
   * handle it, including declaration of c_result ($result).
   */
  if (!is_void) {
    String *cres = SwigType_lstr(return_type, "swig_c_result");
    Printf(w->code, "%s;\n", cres);
    Delete(cres);
  }
  if (allow_thread) {
    Printf(w->code, "{\n");
  }
    
  /* wrap complex arguments to PyObjects */
  Printv(w->code, wrap_args, NIL);

  /* pass the method call on to the Python object */
  if (dirprot_mode() && !is_public(n)) {
    Printf(w->code, "swig_set_inner(\"%s\", true);\n", name);
  }
  

  Printf(w->code, "if (!swig_get_self()) {\n");
  Printf(w->code, "  Swig::DirectorException::raise(\"'self' unitialized, maybe you forgot to call %s.__init__.\");\n", classname);
  Printf(w->code, "}\n");  
  Printf(w->code,"#if defined(SWIG_DIRECTOR_VTABLE)\n");
  Printf(w->code, "const size_t swig_method_index = %d;\n", director_method_index++);
  Printf(w->code, "const char * const swig_method_name = \"%s\";\n", pyname);

  Printf(w->code, "PyObject* method = swig_get_method(swig_method_index, swig_method_name);\n");
  if (Len(parse_args) > 0) {
    if (use_parse) {
      Printf(w->code, "swig::PyObject_var result = PyObject_CallFunction(method, (char *)\"(%s)\" %s);\n", parse_args, arglist);
    } else {
      Printf(w->code, "swig::PyObject_var result = PyObject_CallFunctionObjArgs(method %s, NULL);\n", arglist);
    }
  } else {
    Printf(w->code, "swig::PyObject_var args = PyTuple_New(0);\n");
    Printf(w->code, "swig::PyObject_var result = PyObject_Call(method, (PyObject*) args, NULL);\n");
  }
  Printf(w->code,"#else\n");
  if (Len(parse_args) > 0) {
    if (use_parse) {
      Printf(w->code, "swig::PyObject_var result = PyObject_CallMethod(swig_get_self(), (char *)\"%s\", (char *)\"(%s)\" %s);\n", 
	     pyname, parse_args, arglist);
    } else {
      Printf(w->code, "swig::PyObject_var swig_method_name = PyString_FromString((char *)\"%s\");\n", pyname);
      Printf(w->code, "swig::PyObject_var result = PyObject_CallMethodObjArgs(swig_get_self(), (PyObject *) swig_method_name %s, NULL);\n", 
	     arglist);
    }
  } else {
    Printf(w->code, "swig::PyObject_var swig_method_name = PyString_FromString((char *)\"%s\");\n", pyname);
    Printf(w->code, "swig::PyObject_var result = PyObject_CallMethodObjArgs(swig_get_self(), (PyObject *) swig_method_name, NULL);\n");
  }
  Printf(w->code,"#endif\n");

  if (dirprot_mode() && !is_public(n))
    Printf(w->code, "swig_set_inner(\"%s\", false);\n", name);

  /* exception handling */
  tm = Swig_typemap_lookup_new("director:except", n, "result", 0);
  if (!tm) {
    tm = Getattr(n, "feature:director:except");
    if (tm) tm = Copy(tm);
  }
  Printf(w->code, "if (result == NULL) {\n");
  Printf(w->code, "  PyObject *error = PyErr_Occurred();\n");
  if ((tm) && Len(tm) && (Strcmp(tm, "1") != 0)) {
    Replaceall(tm, "$error", "error");
    Printv(w->code, Str(tm), "\n", NIL);
  } else {
    Printf(w->code, "  if (error != NULL) {\n");
    Printf(w->code, "    Swig::DirectorMethodException::raise(\"Error detected when calling '%s.%s'\");\n", 
	   classname, pyname);
    Printf(w->code, "  }\n");
  }
  Printf(w->code, "}\n");
  Delete(tm);

  /*
   * Python method may return a simple object, or a tuple.
   * for in/out aruments, we have to extract the appropriate PyObjects from the tuple,
   * then marshal everything back to C/C++ (return value and output arguments).
   *
   */

  /* marshal return value and other outputs (if any) from PyObject to C/C++ type */

  String* cleanup = NewString("");
  String* outarg = NewString("");

  if (outputs > 1) {
    Wrapper_add_local(w, "output", "PyObject *output");
    Printf(w->code, "if (!PyTuple_Check(result)) {\n");
    Printf(w->code, "  Swig::DirectorTypeMismatchException::raise(\"Python method %s.%sfailed to return a tuple.\");\n",
	   classname, pyname);
    Printf(w->code, "}\n");
  }

  idx = 0;

  /* marshal return value */
  if (!is_void) {
    /* this seems really silly.  the node's type excludes
     * qualifier/pointer/reference markers, which have to be retrieved
     * from the decl field to construct return_type.  but the typemap
     * lookup routine uses the node's type, so we have to swap in and
     * out the correct type.  it's not just me, similar silliness also
     * occurs in Language::cDeclaration().
     */
    Setattr(n, "type", return_type);
    tm = Swig_typemap_lookup_new("directorout", n, "result", w);
    Setattr(n, "type", type);
    if (tm == 0) {
      String *name = NewString("result");
      tm = Swig_typemap_search("directorout", return_type, name, NULL);
      Delete(name);
    }
    if (tm != 0) {
      if (outputs > 1) {
	Printf(w->code, "output = PyTuple_GetItem(result, %d);\n", idx++);
	Replaceall(tm, "$input", "output");
      } else {
	Replaceall(tm, "$input", "result");
      }
      char temp[24];
      sprintf(temp,"%d",idx);
      Replaceall(tm,"$argnum",temp);

      /* TODO check this */
      if (Getattr(n,"wrap:disown")) {
	Replaceall(tm,"$disown","SWIG_POINTER_DISOWN");
      } else {
	Replaceall(tm,"$disown","0");
      }
      Replaceall(tm, "$result", "swig_c_result");
      Printv(w->code, tm, "\n", NIL);
      Delete(tm);
    } else {
      Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF, input_file, line_number,
		   "Unable to use return type %s in director method %s::%s (skipping method).\n", SwigType_str(return_type, 0), classname, name);
      status = SWIG_ERROR;
    }
  }
	  
  /* marshal outputs */
  for (p = l; p; ) {
    if ((tm = Getattr(p, "tmap:directorargout")) != 0) {
      if (outputs > 1) {
	Printf(w->code, "output = PyTuple_GetItem(result, %d);\n", idx++);
	Replaceall(tm, "$input", "output");
      } else {
	Replaceall(tm, "$input", "result");
      }
      Replaceall(tm, "$result", Getattr(p, "name"));
      Printv(w->code, tm, "\n", NIL);
      p = Getattr(p, "tmap:directorargout:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* any existing helper functions to handle this? */
  if (allow_thread) {
    Printf(w->code, "}\n");
    thread_end_block(n, w->code);
  }
  
  if (!is_void) {
    String* rettype = SwigType_str(return_type, 0);      
    if (!SwigType_isreference(return_type)) {
      Printf(w->code, "return (%s) swig_c_result;\n", rettype);
    } else {
      Printf(w->code, "return (%s) *swig_c_result;\n", rettype);
    }
    Delete(rettype);
  }
  Printf(w->code, "}\n");

  /* emit the director method */
  if (status == SWIG_OK) {
    if (!Getattr(n,"defaultargs")) {
      Wrapper_print(w, f_directors);
      Printv(f_directors_h, declaration, NIL);
    }
  }

  /* clean up */
  Delete(wrap_args);
  Delete(parse_args);
  Delete(arglist);
  Delete(rtype);
  Delete(return_type);
  Delete(pclassname);
  Delete(cleanup);
  Delete(outarg);
  DelWrapper(w);
  return status;
}

/* -----------------------------------------------------------------------------
 * swig_python()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language * new_swig_python() {
  return new PYTHON();
}
extern "C" Language * swig_python(void) {
  return new_swig_python();
}


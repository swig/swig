/*******************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 *******************************************************************************/

static char cvsroot[] = "$Header$";

/**********************************************************************
 * $Header$
 *
 * python.cxx
 *
 * Python module.
 **************************************************************************/


#include "mod11.h"
#include "python.h"

struct Method {               // Methods list.  Needed to build methods
  char   *name;               // Array at very end.
  char   *function;
  int     kw;
  Method *next;
};

static Method  *head = 0;

static  DOHString       *const_code = 0;
static  DOHString       *shadow_methods = 0;

static  char   *module = 0;               // Module name
static  char   *path = (char*)"python";   // Pathname of where to look for library files
static  char   *methods;              // Method table name
static  char   *global_name = (char*)"cvar";          // Name of global variables.
static  int     shadow = 0;
static  int     have_defarg = 0;
static  int     docstring;
static  int     have_output;
static  int     use_kw = 0;     
static  int     noopt = 1; 
static  FILE    *f_shadow;
static  DOHHash     *hash;
static  DOHHash     *symbols;
static  DOHString   *classes;
static  DOHString   *func;
static  DOHString   *vars;
static  DOHString   *modinit;
static  DOHString   *modextern;

static  char     *import_file = 0;
static  char     *class_name;

static char *usage = (char *)"\
Python Options (available with -python)\n\
     -globals name   - Set name used to access C global variable ('cvar' by default).\n\
     -module name    - Set module name\n\
     -keyword        - Use keyword arguments\n\
     -noopt          - No optimized shadows (pre 1.5.2)\n\
     -opt            - Optimized shadow classes (1.5.2 or later)\n\
     -shadow         - Generate shadow classes. \n\n";

static DOHString *pragma_include = 0;

// ---------------------------------------------------------------------
// PYTHON::parse_args(int argc, char *argv[])
//
// ---------------------------------------------------------------------

void PYTHON::parse_args(int argc, char *argv[]) {

  int i = 1;

  sprintf(LibDir,"%s",path);

  // Look for additional command line options.
  for (i = 1; i < argc; i++) {	
      if (argv[i]) {
	  if(strcmp(argv[i],"-module") == 0) {
	    if (argv[i+1]) {
	      module = new char[strlen(argv[i+1])+2];
	      strcpy(module, argv[i+1]);
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i+=1;
	    } else {
	      Swig_arg_error();
	    } 
	  } else if (strcmp(argv[i],"-globals") == 0) {
	    if (argv[i+1]) {
	      global_name = new char[strlen(argv[i+1])+1];
	      strcpy(global_name, argv[i+1]);
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i++;
	    } else {
	      Swig_arg_error();
	    }
	  } else if (strcmp(argv[i],"-shadow") == 0) {
	    shadow = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-noopt") == 0) {
	    noopt = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-opt") == 0) {
	    noopt = 0;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-keyword") == 0) {
	    use_kw = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-help") == 0) {
	    fputs(usage,stderr);
	  }
      }
  }
  // Create a symbol for this language
  Preprocessor_define((void *) "SWIGPYTHON", 0);

  // Set name of typemaps

  typemap_lang = (char*)"python";

}

// ---------------------------------------------------------------------
// PYTHON::parse()
//
// Parse the interface file
// ---------------------------------------------------------------------

void
PYTHON::parse() {
  
  printf("Generating wrappers for Python\n"); 

  hash = NewHash();
  symbols = NewHash();

  const_code = NewString("");
  shadow_methods = NewString("");
  classes = NewString("");
  func = NewString("");
  vars = NewString("");
  modinit = NewString("");
  modextern = NewString("");
  pragma_include = NewString("");

  headers();
  
  // Run the SWIG parser
  
  yyparse();
}

// ---------------------------------------------------------------------
// PYTHON::set_module(char *mod_name, char **mod_list)
//
// Sets the module name.
// Does nothing if it's already set (so it can be overridden as a command
// line option).
//
//----------------------------------------------------------------------

void PYTHON::set_module(char *mod_name, char **mod_list) {
  int i;

  // If an "import" method has been set and we're in shadow class mode,
  // output a python command to load the module

  if (import_file) {
    if (!(strcmp(import_file,input_file+strlen(input_file)-strlen(import_file)))) {
      if (shadow) {
	Printf(f_shadow,"\nfrom %s import *\n", mod_name);
      }
      free(import_file);
      import_file = 0;
    }
  }

  if (module) return;

  module = new char[strlen(mod_name)+1];
  strcpy(module,mod_name);

  // If there was a mod_list specified, make this incredible hack
  if  (mod_list) {
    Printf(modinit, "#define SWIGMODINIT ");
    Printv(modextern,
	   "#ifdef __cplusplus\n",
	   "extern \"C\" {\n",
	   "#endif\n",
	   0);
    i = 0;
    while(mod_list[i]) {
      Printv(modinit, "swig_add_module(\"", mod_list[i], "\",init", mod_list[i], "); \\\n", 0);
      
      Printv(modextern, "extern void init", mod_list[i], "();\n", 0);
      i++;
    }
    Printv(modextern,
	   "#ifdef __cplusplus\n",
	   "}\n",
	   "#endif\n",
	   0);
    Printf(modinit,"/* End of extern module initialization */\n");
  }
}

// ---------------------------------------------------------------------
// PYTHON::set_init(char *iname)
//
// Sets the initialization function name.
// Does nothing if it's already set
//
//----------------------------------------------------------------------

void PYTHON::set_init(char *iname) {
  set_module(iname,0);
}


// ---------------------------------------------------------------------
// PYTHON::import(char *filename)
//
// Imports a SWIG module as a separate file.
//----------------------------------------------------------------------

void PYTHON::import(char *filename) {
  if (import_file) free(import_file);
  import_file = Swig_copy_string(filename);
}

// ----------------------------------------------------------------------
// PYTHON::add_method(char *name, char *function, int kw)
//
// Add some symbols to the methods table
// ----------------------------------------------------------------------

void PYTHON::add_method(char *name, char *function, int kw) {

  Method *n;

  n = new Method;
  n->name = new char[strlen(name)+1];
  strcpy(n->name,name);
  n->function = new char[strlen(function)+1];
  strcpy(n->function, function);
  n->kw = kw;
  n->next = head;
  head = n;
}

// ---------------------------------------------------------------------
// PYTHON::print_methods()
//
// Prints out the method array.
// ---------------------------------------------------------------------

void PYTHON::print_methods() {

  Method *n;

  Printf(f_wrappers,"static PyMethodDef %sMethods[] = {\n", module);
  n = head;
  while (n) {
    if (!n->kw) {
      Printf(f_wrappers,"\t { \"%s\", %s, METH_VARARGS },\n", n->name, n->function);
    } else {
      Printf(f_wrappers,"\t { \"%s\", (PyCFunction) %s, METH_VARARGS | METH_KEYWORDS },\n", n->name, n->function);
    }
    n = n->next;
  }
  Printf(f_wrappers,"\t { NULL, NULL }\n");
  Printf(f_wrappers,"};\n");
  Printf(f_wrappers,"#ifdef __cplusplus\n");
  Printf(f_wrappers,"}\n");
  Printf(f_wrappers,"#endif\n");
}

// ---------------------------------------------------------------------
// PYTHON::headers(void)
//
// ----------------------------------------------------------------------

void PYTHON::headers(void)
{

  Swig_banner(f_runtime);

  Printf(f_runtime,"/* Implementation : PYTHON */\n\n");
  Printf(f_runtime,"#define SWIGPYTHON\n");

  if (NoInclude) 
    Printf(f_runtime,"#define SWIG_NOINCLUDE\n");

  if (Swig_insert_file("python.swg", f_runtime) == -1) {
    Printf(stderr,"SWIG : Fatal error. Unable to locate python.swg. (Possible installation problem).\n");
    SWIG_exit(1);
  }
}


// --------------------------------------------------------------------
// PYTHON::initialize(void)
//
// This function outputs the starting code for a function to initialize
// your interface.   It is only called once by the parser.
//
// ---------------------------------------------------------------------

void PYTHON::initialize(void)
{

  char  filen[256];
  char  *temp;
  char  *oldmodule = 0;

  if (!module) {
    Printf(stderr,"*** Error. No module name specified.\n");
    SWIG_exit(1);
  }

  // If shadow classing is enabled, we're going to change the module
  // name to "modulec"

  if (shadow) {
    temp = new char[strlen(module)+2];
    sprintf(temp,"%sc",module);
    oldmodule = module;
    module = temp;
  } 
  /* Initialize the C code for the module */
  initialize_cmodule();
  /* Create a shadow file (if enabled).*/
  if (shadow) {
    sprintf(filen,"%s%s.py", output_dir, oldmodule);
    if ((f_shadow = fopen(filen,"w")) == 0) {
      Printf(stderr,"Unable to open %s\n", filen);
      SWIG_exit(0);
    }
    Printf(f_shadow,"# This file was created automatically by SWIG.\n");
    Printf(f_shadow,"import %s\n", module);
    if (!noopt)
      Printf(f_shadow,"import new\n");
  }

  // Dump out external module declarations

  if (Len(modinit) > 0) {
    Printf(f_header,"%s\n",modinit);
  }
  if (Len(modextern) > 0) {
    Printf(f_header,"%s\n",modextern);
  }
  Printf(f_wrappers,"#ifdef __cplusplus\n");
  Printf(f_wrappers,"extern \"C\" {\n");
  Printf(f_wrappers,"#endif\n");

  Printf(const_code,"static _swig_const_info _swig_const_table[] = {\n");
}

// ---------------------------------------------------------------------
// PYTHON::initialize_cmodule(void)
//
// Initializes the C module.
// 
// ---------------------------------------------------------------------
void PYTHON::initialize_cmodule(void)
{
  int i;
  Printf(f_header,"#define SWIG_init    init%s\n\n", module);
  Printf(f_header,"#define SWIG_name    \"%s\"\n", module);	

  // Output the start of the init function.  
  // Modify this to use the proper return type and arguments used
  // by the target Language

  Printf(f_init,"static PyObject *SWIG_globals;\n");

  Printf(f_init,"#ifdef __cplusplus\n");
  Printf(f_init,"extern \"C\" \n");
  Printf(f_init,"#endif\n");

  Printf(f_init,"SWIGEXPORT(void) init%s(void) {\n",module);
  Printf(f_init,"\t PyObject *m, *d;\n");
  Printf(f_init,"\t SWIG_globals = SWIG_newvarlink();\n");
  Printf(f_init,"\t m = Py_InitModule(\"%s\", %sMethods);\n", module, module);
  Printf(f_init,"\t d = PyModule_GetDict(m);\n");

  Printv(f_init,
	 tab4, "{\n",
	 tab8, "int i;\n",
	 tab8, "for (i = 0; _swig_types_initial[i]; i++) {\n",
	 tab8, tab4, "_swig_types[i] = SWIG_TypeRegister(_swig_types_initial[i]);\n",
	 tab8, "}\n",
	 tab4, "}\n",
	 0);

#ifdef SHADOW_METHODS
  if (shadow) {
    Printv(shadow_methods,
	   "static struct { \n",
	   tab4, "char *name;\n",
	   tab4, "char *classname;\n",
	   "} _swig_shadow_methods[] = {\n",
	   0);
  }
#endif
}


// ---------------------------------------------------------------------
// PYTHON::close(void)
//
// Called when the end of the interface file is reached.  Closes the
// initialization function and performs cleanup as necessary.
// ---------------------------------------------------------------------

void PYTHON::close(void)
{
  print_methods();
  close_cmodule();
  if (shadow) {
    Printv(f_shadow,
	   classes,
	   "\n\n#-------------- FUNCTION WRAPPERS ------------------\n\n",
	   func,
	   "\n\n#-------------- VARIABLE WRAPPERS ------------------\n\n",
	   vars,
	   0);

    if (Len(pragma_include) > 0) {
      Printv(f_shadow,
	     "\n\n#-------------- USER INCLUDE -----------------------\n\n",
             pragma_include,
	     0);
    }
    fclose(f_shadow);
  }
}

// --------------------------------------------------------------------
// PYTHON::close_cmodule(void)
//
// Called to cleanup the C module code
// --------------------------------------------------------------------
void PYTHON::close_cmodule(void)
{
  extern void emit_type_table();
  emit_type_table();
  /*  emit_ptr_equivalence(f_init); */
  Printf(const_code, "{0}};\n");
  
  Printf(f_wrappers,"%s\n",const_code);
#ifdef SHADOW_METHODS
  if (shadow) {
    Printv(shadow_methods, tab4, "{0, 0}\n", "};\n", 0);
    Printf(f_wrappers,"%s\n", shadow_methods);
  }
#endif
  Printv(f_init, tab4, "SWIG_InstallConstants(d,_swig_const_table);\n", 0);

#ifdef SHADOW_METHODS
  // Not done yet.  If doing shadows, create a bunch of instancemethod objects for use
  if (shadow) {
    Printv(f_init,
	   tab4, "{\n",
	   tab8, "PyObject *sd, *im, *co, *sclass;\n",
	   tab8, "int i;\n",
	   tab8, "sd = PyDict_New();\n",
	   tab8, "sclass = PyClass_New(NULL, sd, PyString_FromString(\"__shadow__\"));\n",
	   tab8, "for (i = 0; _swig_shadow_methods[i].name; i++) {\n",
	   tab8, tab4, "char *name;\n",
	   tab8, tab4, "name = _swig_shadow_methods[i].name;\n",
	   tab8, tab4, "co = PyDict_GetItemString(d,name);\n",
	   tab8, tab4, "im = PyMethod_New(co, NULL, sclass);\n",
	   tab8, tab4, "PyDict_SetItemString(sd,name,im);\n",
	   tab8, tab4, "}\n",
	   tab8, "PyDict_SetItemString(d,\"__shadow__\", sclass);\n",
	   tab4, "}\n",
	   0);
  }
#endif
  Printf(f_init,"}\n");
}

// ----------------------------------------------------------------------
// PYTHON::get_pointer(char *iname, char *srcname, char *src, char *target,
//                     DataType *t, DOHString *f, char *ret)
//
// Emits code to get a pointer and do type checking.
//      iname = name of the function/method  (used for error messages)
//      srcname = Name of source (used for error message reporting).
//      src   = name of variable where source string is located.
//      dest  = name of variable where pointer value is stored.
//      t     = Expected datatype of the parameter
//      f     = Wrapper function object being used to generate code.
//      ret   = return code upon failure.
//
// Note : pointers are stored as strings so you first need to get
// a string and then call _swig_get_hex() to extract a point.
//
// This module is pretty ugly, but type checking is kind of nasty
// anyways.
// ----------------------------------------------------------------------

void
PYTHON::get_pointer(char *iname, char *srcname, char *src, char *dest,
		    DataType *t, DOHString *f, char *ret)
{
  t->remember();
  
  // Now get the pointer value from the string and save in dest
  
  Printv(f,tab4, "if ((SWIG_ConvertPtr(", src, ",(void **) &", dest, ",", 0);

  // If we're passing a void pointer, we give the pointer conversion a NULL
  // pointer, otherwise pass in the expected type.
  
  if (t->type == T_VOID) Printv(f, "0,1)) == -1) return ", ret, ";\n", 0);
  else
    Printv(f,"SWIGTYPE", t->print_mangle(), ",1)) == -1) return ", ret, ";\n", 0);
}

// ----------------------------------------------------------------------
// PYTHON::emit_function_header()
//
// Return the code to be used as a function header
// ----------------------------------------------------------------------
void PYTHON::emit_function_header(Wrapper *emit_to, char *wname)
{
  if (!use_kw) {
    Printv(emit_to->def,
	   "static PyObject *", wname,
	   "(PyObject *self, PyObject *args) {",
	   0);
  } else {
    Printv(emit_to->def,
	   "static PyObject *", wname,
	   "(PyObject *self, PyObject *args, PyObject *kwargs) {",
	   0);
  }
  Printf(emit_to->code,"    self = self;\n");
}

// ----------------------------------------------------------------------
// PYTHON::convert_self()
//
// Called during the function generation process, to determine what to
// use as the "self" variable during the call.  Derived classes may emit code
// to convert the real self pointer into a usable pointer.
//
// Returns the name of the variable to use as the self pointer
// ----------------------------------------------------------------------
char *PYTHON::convert_self(Wrapper *f)
{
  // Default behaviour is no translation
  return (char*)"";
}

// ----------------------------------------------------------------------
// PYTHON::make_funcname_wrapper()
//
// Called to create a name for a wrapper function
// ----------------------------------------------------------------------
char *PYTHON::make_funcname_wrapper(char *fnName)
{
  return Swig_name_wrapper(fnName);
}

// ----------------------------------------------------------------------
// PYTHON::create_command(char *cname, char *iname)
//
// Create a new command in the interpreter.  Used for C++ inheritance 
// stuff.
// ----------------------------------------------------------------------

void PYTHON::create_command(char *cname, char *iname) {

  // Create the name of the wrapper function

  char *wname = Swig_name_wrapper(cname);

  // Now register the function with the interpreter.  

  add_method(iname, wname, use_kw);

}

// ----------------------------------------------------------------------
// PYTHON::create_function(char *name, char *iname, DataType *d,
//                             ParmList *l)
//
// This function creates a wrapper function and registers it with the
// interpreter.   
//  
// Inputs :
//     name  = actual name of the function that's being wrapped
//    iname  = name of the function in the interpreter (may be different)
//        d  = Return datatype of the functions.
//        l  = A linked list containing function parameter information.
//
// ----------------------------------------------------------------------

void PYTHON::create_function(char *name, char *iname, DataType *d, ParmList *l)
{
  Parm    *p;
  int     pcount,i,j;
  char    wname[256], self_name[256], call_name[256];
  char    source[64], target[64], temp[256], argnum[20];
  char    *usage = 0;
  Wrapper *f;
  DOHString *parse_args;
  DOHString *arglist;
  DOHString *get_pointers;
  DOHString *cleanup;
  DOHString *outarg;
  DOHString *check;
  DOHString *kwargs;

  char     *tm;
  int      numopt = 0;

  f = NewWrapper();
  parse_args = NewString("");
  arglist = NewString("");
  get_pointers = NewString("");
  cleanup = NewString("");
  outarg = NewString("");
  check = NewString("");
  kwargs = NewString("");

  have_output = 0;

  // Make a valid name for this function.   This removes special symbols
  // that would cause problems in the C compiler.

  strcpy(wname,make_funcname_wrapper(iname));

  // Now emit the function declaration for the wrapper function.  You
  // should modify this to return the appropriate types and use the
  // appropriate parameters.

  emit_function_header(f, wname);

  Wrapper_add_local(f,"_resultobj", "PyObject *_resultobj");

  // Get the function usage string for later use
  
  usage = usage_func(iname,d,l);   

  // Write code to extract function parameters.
  // This is done in one pass, but we need to construct three independent
  // pieces.
  //      1.    Python format string such as "iis"
  //      2.    The actual arguments to put values into
  //      3.    Pointer conversion code.
  //
  // If there is a type mapping, we will extract the Python argument
  // as a raw PyObject and let the user deal with it.
  //

  pcount = emit_args(d, l, f);
  if (!use_kw) {
    Printf(parse_args,"    if(!PyArg_ParseTuple(args,\"");
  } else {
    Printf(parse_args,"    if(!PyArg_ParseTupleAndKeywords(args,kwargs,\"");
    Printf(arglist,",_kwnames");
  }
  
  i = 0;
  j = 0;
  numopt = ParmList_numopt(l);        // Get number of optional arguments
  if (numopt) have_defarg = 1;
  p = ParmList_first(l);

  Printf(kwargs,"{ ");
  while (p != 0) {
    
    // Generate source and target strings
    sprintf(source,"_obj%d",i);
    sprintf(target,"_arg%d",i);
    sprintf(argnum,"%d",j+1);

    // Only consider this argument if it's not ignored

    if (!p->ignore) {
      Putc(',',arglist);
      // Add an optional argument separator if needed
    
      if (j == pcount-numopt) {  
	Putc('|',parse_args);
      }

      if (strlen(p->name)) {
	Printf(kwargs,"\"%s\",", p->name);
      } else {
	Printf(kwargs,"\"arg%d\",", j+1);
      }

      // Look for input typemap
      
      if ((tm = typemap_lookup((char*)"in",(char*)"python",p->t,p->name,source,target,f))) {
	Putc('O',parse_args);
	Wrapper_add_localv(f, source, "PyObject *",source,0);
	Printf(arglist,"&%s",source);
	if (i >= (pcount-numopt))
	  Printv(get_pointers, tab4, "if (", source, ")\n",
		 tm, "\n",
		 0);
	Replace(get_pointers,"$argnum", argnum, DOH_REPLACE_ANY);
	Replace(get_pointers,"$arg",source, DOH_REPLACE_ANY);
      } else {

	// Check if this parameter is a pointer.  If not, we'll get values

	if (!p->t->is_pointer) {
	  // Extract a parameter by "value"
	
	  switch(p->t->type) {
	  
	    // Handle integers here.  Usually this can be done as a single
	    // case if you appropriate cast things.   However, if you have
	    // special cases, you'll need to add more code.  
	    
	  case T_INT : case T_UINT: case T_SINT: 
	    Putc('i',parse_args);
	    break;
	  case T_SHORT: case T_USHORT: case T_SSHORT:
	    Putc('h',parse_args);
	    break;
	  case T_LONG : case T_ULONG: case T_SLONG :
	    Putc('l',parse_args);
	    break;
	  case T_SCHAR : case T_UCHAR :
	    Putc('b',parse_args);
	    break;
	  case T_CHAR:
	    Putc('c',parse_args);
	    break;
	  case T_FLOAT :
	    Putc('f',parse_args);
	    break;
	  case T_DOUBLE:
	    Putc('d',parse_args);
	    break;
	    
	  case T_BOOL:
	    {
	      char tempb[128];
	      char tempval[128];
	      if (p->defvalue) {
		sprintf(tempval, "(int) %s", p->defvalue);
	      }
	      sprintf(tempb,"tempbool%d",i);
	      Putc('i',parse_args);
	      if (!p->defvalue)
		Wrapper_add_localv(f,tempb,"int",tempb,0);
	      else
		Wrapper_add_localv(f,tempb,"int",tempb, "=",tempval,0);
	      Printv(get_pointers, tab4, target, " = ", p->t->print_cast(), " ", tempb, ";\n", 0);
	      Printf(arglist,"&%s",tempb);
	    }
	  break;

	    // Void.. Do nothing.
	    
	  case T_VOID :
	    break;
	    
	    // User defined.   This is usually invalid.   No way to pass a
	    // complex type by "value".  We'll just pass into the unsupported
	    // datatype case.
	    
	  case T_USER:
	    
	    // Unsupported data type
	    
	  default :
	    Printf(stderr,"%s : Line %d. Unable to use type %s as a function argument.\n",input_file, line_number, p->t->print_type());
	    break;
	  }
	  
	  // Emit code for parameter list
	  
	  if ((p->t->type != T_VOID) && (p->t->type != T_BOOL))
	    Printf(arglist,"&_arg%d",i);
	  
	} else {
	  
	  // Is some other kind of variable.   
	  
	  if ((p->t->type == T_CHAR) && (p->t->is_pointer == 1)) {
	    Putc('s',parse_args);
	    Printf(arglist,"&_arg%d",i);
	  } else {
	    
	    // Have some sort of pointer variable.  Create a temporary local
	    // variable for the string and read the pointer value into it.
	    
	    Putc('O',parse_args);
	    sprintf(source,"_argo%d", i);
	    sprintf(target,"_arg%d", i);
	    sprintf(temp,"argument %d",i+1);
	    
	    Wrapper_add_localv(f,source,"PyObject *",source,"=0",0);
	    Printf(arglist,"&%s",source);
	    get_pointer(iname, temp, source, target, p->t, get_pointers, (char*)"NULL");
	  }
	}
      }
      j++;
    }
    // Check if there was any constraint code
    if ((tm = typemap_lookup((char*)"check",(char*)"python",p->t,p->name,source,target))) {
      Printf(check,"%s\n",tm);
      Replace(check,"$argnum", argnum, DOH_REPLACE_ANY);
    }
    // Check if there was any cleanup code
    if ((tm = typemap_lookup((char*)"freearg",(char*)"python",p->t,p->name,target,source))) {
      Printf(cleanup,"%s\n",tm);
      Replace(cleanup,"$argnum", argnum, DOH_REPLACE_ANY);
      Replace(cleanup,"$arg",source, DOH_REPLACE_ANY);
    }
    if ((tm = typemap_lookup((char*)"argout",(char*)"python",p->t,p->name,target,(char*)"_resultobj"))) {
      Printf(outarg,"%s\n", tm);
      Replace(outarg,"$argnum",argnum,DOH_REPLACE_ANY);
      Replace(outarg,"$arg",source, DOH_REPLACE_ANY);
      have_output++;
    } 
    p = ParmList_next(l);
    i++;
  }

  Printf(kwargs," NULL }");
  if (use_kw) {
    Printv(f->locals,tab4, "char *_kwnames[] = ", kwargs, ";\n", 0);
  }

  Printf(parse_args,":%s\"", iname);
  Printv(parse_args,
	 arglist, ")) return NULL;\n",
	 0);
  
  strcpy(self_name,convert_self(f));

  /* Now slap the whole first part of the wrapper function together */
  Printv(f->code, parse_args, get_pointers, check, 0);

  // This function emits code to call the real function.  Assuming you read
  // the parameters in correctly, this will work.

  sprintf(call_name,"%s%s",self_name,name);
  emit_func_call(call_name,d,l,f);

  // Now emit code to return the functions return value (if any).
  // If there was a result, it was saved in _result.
  // If the function is a void type, don't do anything.
  
  if ((tm = typemap_lookup((char*)"out",(char*)"python",d,iname,(char*)"_result",(char*)"_resultobj"))) {
    // Yep.  Use it instead of the default
    Printf(f->code,"%s\n", tm);
  } else {

    if ((d->type != T_VOID) || (d->is_pointer)) {
      // Now have return value, figure out what to do with it.
      
      if (!d->is_pointer) {
	
	// Function returns a "value"
	
	switch(d->type) {
	  
	  // Return an integer type
	  
	case T_INT: case T_SINT: case T_UINT: case T_BOOL:
	  Printf(f->code,"    _resultobj = Py_BuildValue(\"i\",_result);\n");
	  break;
	case T_SHORT: case T_SSHORT: case T_USHORT:
	  Printf(f->code,"    _resultobj = Py_BuildValue(\"h\",_result);\n");
	  break;
	case T_LONG : case T_SLONG : case T_ULONG:
	  Printf(f->code,"    _resultobj = Py_BuildValue(\"l\",_result);\n");
	  break;
	case T_SCHAR: case T_UCHAR :
	  Printf(f->code,"    _resultobj = Py_BuildValue(\"b\",_result);\n");
	  break;
	  
	  // Return a floating point value
	  
	case T_DOUBLE :
	  Printf(f->code,"    _resultobj = Py_BuildValue(\"d\",_result);\n");
	  break;
	case T_FLOAT :
	  Printf(f->code,"    _resultobj = Py_BuildValue(\"f\",_result);\n");
	  break;
	  
	  // Return a single ASCII value.  Usually we need to convert
	  // it to a NULL-terminate string and return that instead.
	  
	case T_CHAR :
	  Printf(f->code,"    _resultobj = Py_BuildValue(\"c\",_result);\n");
	  break;
	  
	case T_USER :
	  d->is_pointer++;
	  d->remember();
	  Printv(f->code,tab4, "_resultobj = SWIG_NewPointerObj((void *)_result, SWIGTYPE", d->print_mangle(), ");\n",0);
	  d->is_pointer--;
	  break;
	default :
	  Printf(stderr,"%s: Line %d. Unable to use return type %s in function %s.\n", input_file, line_number, d->print_type(), name);
	  break;
	}
      } else {
	
	// Return type is a pointer.   We'll see if it's a char * and return
	// a string. Otherwise, we'll convert it into a SWIG pointer and return
	// that.
	
	if ((d->type == T_CHAR) && (d->is_pointer == 1)) {
	  
	  // Return a character string
	  Printf(f->code,"    _resultobj = Py_BuildValue(\"s\", _result);\n");

	  // If declared as a new object, free the result

	} else {
	  // Build a SWIG pointer.
	  d->remember();
	  Printv(f->code, tab4, "_resultobj = SWIG_NewPointerObj((void *) _result, SWIGTYPE", d->print_mangle(), ");\n", 0);
	}
      }
    } else {
      Printf(f->code,"    Py_INCREF(Py_None);\n");
      Printf(f->code,"    _resultobj = Py_None;\n");
    }
  }

  // Check to see if there were any output arguments, if so we're going to
  // create a Python list object out of the current result

  Printv(f->code,outarg,0);

  // If there was any other cleanup needed, do that

  Printv(f->code,cleanup,0);

  // Look to see if there is any newfree cleanup code

  if (NewObject) {
    if ((tm = typemap_lookup((char*)"newfree",(char*)"python",d,iname,(char*)"_result",(char*)""))) {
      Printf(f->code,"%s\n",tm);
    }
  }

  // See if there is any argument cleanup code

  if ((tm = typemap_lookup((char*)"ret",(char*)"python",d,iname,(char*)"_result",(char*)""))) {
    // Yep.  Use it instead of the default
    Printf(f->code,"%s\n",tm);
  }
  
  Printf(f->code,"    return _resultobj;\n}\n");

  // Substitute the cleanup code
  Replace(f->code,"$cleanup",cleanup, DOH_REPLACE_ANY);

  // Substitute the function name
  Replace(f->code,"$name",iname, DOH_REPLACE_ANY);

  // Dump the function out
  Wrapper_print(f,f_wrappers);

  // Now register the function with the interpreter.  

  add_method(iname, wname, use_kw);

#ifdef SHADOW_METHODS
  if (shadow && (shadow & PYSHADOW_MEMBER)) {
    Printv(shadow_methods, tab4, "{ \"", iname, "\", \"", class_name, "\" },\n", 0);
  }
#endif

  // ---------------------------------------------------------------------------
  // Create a shadow for this function (if enabled and not in a member function)
  // ---------------------------------------------------------------------------

  if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {

    int need_wrapper = 0;
    int munge_return = 0;
    int have_optional = 0;
    
    // Check return code for modification
    if ((Getattr(hash,d->name)) && (d->is_pointer <=1)) {
      need_wrapper = 1;
      munge_return = 1;
    }

    // If no modification is needed. We're just going to play some
    // symbol table games instead

    if (!need_wrapper) {
      Printv(func,iname, " = ", module, ".", iname, "\n\n", 0);
    } else {
      Printv(func,"def ", iname, "(*args, **kwargs):\n", 0);

      Printv(func, tab4, "val = apply(", module, ".", iname, ",args,kwargs)\n",0);

      if (munge_return) {
	//  If the output of this object has been remapped in any way, we're
	//  going to return it as a bare object.
	
	if (!typemap_check((char*)"out",typemap_lang,d,iname)) {

	  // If there are output arguments, we are going to return the value
          // unchanged.  Otherwise, emit some shadow class conversion code.

	  if (!have_output) {
	    Printv(func, tab4, "if val: val = ", GetChar(hash,d->name), "Ptr(val)", 0);
	    if (((Getattr(hash,d->name)) && (d->is_pointer < 1)) ||
		((Getattr(hash,d->name)) && (d->is_pointer == 1) && NewObject))
	      Printf(func, "; val.thisown = 1\n");
	    else
	      Printf(func,"\n");
	  } else {
	    // Does nothing--returns the value unmolested
	  }
	}
      }
      Printv(func, tab4, "return val\n\n", 0);
    }
  }
  Delete(parse_args);
  Delete(arglist);
  Delete(get_pointers);
  Delete(cleanup);
  Delete(outarg);
  Delete(check);
  Delete(kwargs);
  DelWrapper(f);
}

// -----------------------------------------------------------------------
// PYTHON::link_variable(char *name, char *iname, DataType *d)
//
// Input variables:
//     name = the real name of the variable being linked
//    iname = Name of the variable in the interpreter (may be different)
//        d = Datatype of the variable.
//
// This creates a pair of functions for evaluating/setting the value
// of a variable.   These are then added to the special SWIG global
// variable type.
// -----------------------------------------------------------------------

void PYTHON::link_variable(char *name, char *iname, DataType *t) {

    char   *wname;
    static int have_globals = 0;
    char   *tm;

    Wrapper *getf, *setf;

    getf = NewWrapper();
    setf = NewWrapper();

    // If this is our first call, add the globals variable to the
    // Python dictionary.

    if (!have_globals) {
      Printf(f_init,"\t PyDict_SetItemString(d,\"%s\", SWIG_globals);\n",global_name);
      have_globals=1;
      if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
	Printv(vars, global_name, " = ", module, ".", global_name, "\n", 0);
      }
    }
    // First make a sanitized version of the function name (in case it's some
    // funky C++ thing).
    
    wname = Swig_name_wrapper(name);

    // ---------------------------------------------------------------------
    // Create a function for setting the value of the variable
    // ---------------------------------------------------------------------

    Printf(setf->def,"static int %s_set(PyObject *val) {", wname);
    if (!(Status & STAT_READONLY)) {
      if ((tm = typemap_lookup((char*)"varin",(char*)"python",t,name,(char*)"val",name))) {
	Printf(setf->code,"%s\n",tm);
	Replace(setf->code,"$name",iname, DOH_REPLACE_ANY);
      } else {
	if ((t->type != T_VOID) || (t->is_pointer)) {
	  if (!t->is_pointer) {
	    
	    // Have a real value here 
	    
	    switch(t->type) {
	    case T_INT: case T_SHORT: case T_LONG :
	    case T_UINT: case T_USHORT: case T_ULONG:
	    case T_SINT: case T_SSHORT: case T_SLONG:
	    case T_SCHAR: case T_UCHAR: case T_BOOL:
	      // Get an integer value
	      Wrapper_add_localv(setf,"tval",t->print_type(),"tval",0);
	      Printv(setf->code,
		     tab4, "tval = ", t->print_cast(), "PyInt_AsLong(val);\n",
		     tab4, "if (PyErr_Occurred()) {\n",
		     tab8, "PyErr_SetString(PyExc_TypeError,\"C variable '",
		     iname, "'(", t->print_type(), ")\");\n",
		     tab8, "return 1; \n",
		     tab4, "}\n",
		     tab4, name, " = tval;\n",
		     0);
	      break;
	      
	    case T_FLOAT: case T_DOUBLE:
	      // Get a floating point value
	      Wrapper_add_localv(setf,"tval",t->print_type(), "tval",0);
	      Printv(setf->code,
		     tab4, "tval = ", t->print_cast(), "PyFloat_AsDouble(val);\n",
		     tab4, "if (PyErr_Occurred()) {\n",
		     tab8, "PyErr_SetString(PyExc_TypeError,\"C variable '",
		     iname, "'(", t->print_type(), ")\");\n",
		     tab8, "return 1; \n",
		     tab4, "}\n",
		     tab4, name, " = tval;\n",
		     0);
	      break;
	      
	      // A single ascii character
	      
	    case T_CHAR:
	      Wrapper_add_local(setf,"tval","char * tval");
	      Printv(setf->code,
		     tab4, "tval = (char *) PyString_AsString(val);\n",
		     tab4, "if (PyErr_Occurred()) {\n",
		     tab8, "PyErr_SetString(PyExc_TypeError,\"C variable '",
		     iname, "'(", t->print_type(), ")\");\n",
		     tab8, "return 1; \n",
		     tab4, "}\n",
		     tab4, name, " = *tval;\n",
		     0);
	      break;
	    case T_USER:
	      t->is_pointer++;
	      Wrapper_add_localv(setf,"temp",t->print_type(),"temp",0);
	      get_pointer(iname,(char*)"value",(char*)"val",(char*)"temp",t,setf->code,(char*)"1");
	      Printv(setf->code, tab4, name, " = *temp;\n", 0);
	      t->is_pointer--;
	      break;
	    default:
	      Printf(stderr,"%s : Line %d. Unable to link with type %s.\n", input_file, line_number, t->print_type());
	    }
	  } else {
	    
	    // Parse a pointer value
	    
	    if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
	      Wrapper_add_local(setf,"tval","char * tval");
	      Printv(setf->code,
		     tab4, "tval = (char *) PyString_AsString(val);\n",
		     tab4, "if (PyErr_Occurred()) {\n",
		     tab8, "PyErr_SetString(PyExc_TypeError,\"C variable '",
		     iname, "'(", t->print_type(), ")\");\n",
		     tab8, "return 1; \n",
		     tab4, "}\n",
		     0);
	      
	      if (CPlusPlus) {
		Printv(setf->code,
		       tab4, "if (", name, ") delete [] ", name, ";\n",
		       tab4, name, " = new char[strlen(tval)+1];\n",
		       tab4, "strcpy((char *)", name, ",tval);\n",
		       0);
	      } else {
		Printv(setf->code,
		       tab4, "if (", name, ") free(", name, ");\n",
		       tab4, name, " = (char *) malloc(strlen(tval)+1);\n",
		       tab4, "strcpy((char *)", name, ",tval);\n",
		       0);
	      }
	    } else {
	      
	      // Is a generic pointer value.
	      
	      Wrapper_add_localv(setf,"temp", t->print_type(), "temp",0);
	      get_pointer(iname,(char*)"value",(char*)"val",(char*)"temp",t,setf->code,(char*)"1");
	      Printv(setf->code,tab4, name, " = temp;\n", 0);
	    }
	  }
	}
      }
      Printf(setf->code,"    return 0;\n");
    } else {
      // Is a readonly variable.  Issue an error
      Printv(setf->code,
	     tab4, "PyErr_SetString(PyExc_TypeError,\"Variable ", iname,
	     " is read-only.\");\n",
	     tab4, "return 1;\n",
	     0);
    }
    
    Printf(setf->code,"}\n");
    
    // Dump out function for setting value
    
    Wrapper_print(setf,f_wrappers);
    
    // ----------------------------------------------------------------
    // Create a function for getting the value of a variable
    // ----------------------------------------------------------------
    
    Printf(getf->def,"static PyObject *%s_get() {", wname);
    Wrapper_add_local(getf,"pyobj", "PyObject *pyobj");
    if ((tm = typemap_lookup((char*)"varout",(char*)"python",t,name,name,(char*)"pyobj"))) {
      Printf(getf->code,"%s\n",tm);
      Replace(getf->code,"$name",iname, DOH_REPLACE_ANY);
    } else if ((tm = typemap_lookup((char*)"out",(char*)"python",t,name,name,(char*)"pyobj"))) {
      Printf(getf->code,"%s\n",tm);
      Replace(getf->code,"$name",iname, DOH_REPLACE_ANY);
    } else {
      if ((t->type != T_VOID) || (t->is_pointer)) {
	if (!t->is_pointer) {
	  
	  /* Is a normal datatype */
	  switch(t->type) {
	  case T_INT: case T_SINT: case T_UINT: 
	  case T_SHORT: case T_SSHORT: case T_USHORT:
	  case T_LONG: case T_SLONG: case T_ULONG:
	  case T_SCHAR: case T_UCHAR: case T_BOOL:
	    Printv(getf->code, tab4, "pyobj = PyInt_FromLong((long) ", name, ");\n", 0);
	    break;
	  case T_FLOAT: case T_DOUBLE:
	    Printv(getf->code, tab4, "pyobj = PyFloat_FromDouble((double) ", name, ");\n", 0);
	    break;
	  case T_CHAR:
	    Wrapper_add_local(getf,"ptemp","char ptemp[2]");
	    Printv(getf->code,
		   tab4, "ptemp[0] = ", name, ";\n",
		   tab4, "ptemp[1] = 0;\n",
		   tab4, "pyobj = PyString_FromString(ptemp);\n",
		   0);
	    break;
	  case T_USER:
	    // Hack this into a pointer
	    t->is_pointer++;
	    t->remember();
	    Printv(getf->code,
		   tab4, "pyobj = SWIG_NewPointerObj((void *) &", name ,
		   ", SWIGTYPE", t->print_mangle(), ");\n",
		   0);
	    t->is_pointer--;
	    break;
	  default:
	    Printf(stderr,"Unable to link with type %s\n", t->print_type());
	    break;
	  }
	} else {
	  
	  // Is some sort of pointer value
	  if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
	    Printv(getf->code,
		   tab4, "if (", name, ")\n",
		   tab8, "pyobj = PyString_FromString(", name, ");\n",
		   tab4, "else pyobj = PyString_FromString(\"(NULL)\");\n",
		   0);
	  } else {
	    t->remember();
	    Printv(getf->code,
		   tab4, "pyobj = SWIG_NewPointerObj((void *)", name,
		   ", SWIGTYPE", t->print_mangle(), ");\n",
		   0);
	  }
	}
      }
    }
    
    Printf(getf->code,"    return pyobj;\n}\n");
    
    Wrapper_print(getf,f_wrappers);
    
    // Now add this to the variable linking mechanism

    Printf(f_init,"\t SWIG_addvarlink(SWIG_globals,\"%s\",%s_get, %s_set);\n", iname, wname, wname);

    // ----------------------------------------------------------
    // Output a shadow variable.  (If applicable and possible)
    // ----------------------------------------------------------
    if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
      if ((Getattr(hash,t->name)) && (t->is_pointer <= 1)) {
	Printv(vars,
	       iname, " = ", GetChar(hash,t->name), "Ptr(", module, ".", global_name,
	       ".", iname, ")\n",
	       0);
      }
    }
    DelWrapper(setf);
    DelWrapper(getf);
}

// -----------------------------------------------------------------------
// PYTHON::declare_const(char *name, char *iname, DataType *type, char *value)
//
// Makes a constant as defined with #define.  Constants are added to the
// module's dictionary and are **NOT** guaranteed to be read-only,
// sorry.
//
// ------------------------------------------------------------------------

void PYTHON::declare_const(char *name, char *, DataType *type, char *value) {

  char   *tm;

  // Make a static python object

  if ((tm = typemap_lookup((char*)"const",(char*)"python",type,name,value,name))) {
    Printf(const_code,"%s\n", tm);
  } else {

    if ((type->type == T_USER) && (!type->is_pointer)) {
      Printf(stderr,"%s : Line %d.  Unsupported constant value.\n", input_file, line_number);
      return;
    }
    
    if (type->is_pointer == 0) {
      switch(type->type) {
      case T_INT:case T_SINT: case T_UINT: case T_BOOL:
      case T_SHORT: case T_SSHORT: case T_USHORT:
      case T_LONG: case T_SLONG: case T_ULONG:
      case T_SCHAR: case T_UCHAR:
	Printv(const_code, tab4, "{ SWIG_PY_INT,     \"", name, "\", (long) ", value, ", 0, 0, 0},\n", 0);
	break;
      case T_DOUBLE:
      case T_FLOAT:
	Printv(const_code, tab4, "{ SWIG_PY_FLOAT,   \"", name, "\", 0, (double) ", value, ", 0,0},\n", 0);
	break;
      case T_CHAR :
	Printv(const_code, tab4, "{ SWIG_PY_STRING,  \"", name, "\", 0, 0, (void *) \"", value, "\", 0},\n", 0);
	break;
      default:
	Printf(stderr,"%s : Line %d. Unsupported constant value.\n", input_file, line_number);
	break;
      }
    } else {
      if ((type->type == T_CHAR) && (type->is_pointer == 1)) {
	Printv(const_code,tab4, "{ SWIG_PY_STRING,  \"", name, "\", 0, 0, (void *) \"", value, "\", 0},\n", 0);
      } else {
	// A funky user-defined type.  We're going to munge it into a string pointer value
	type->remember();
	Printv(const_code, tab4, "{ SWIG_PY_POINTER, \"", name, "\", 0, 0, (void *) ", value, ", &SWIGTYPE", type->print_mangle(), "}, \n", 0);

      }
    }
  }
  if ((shadow) && (!(shadow & PYSHADOW_MEMBER))) {
    Printv(vars,name, " = ", module, ".", name, "\n", 0);
  }    
}

// ----------------------------------------------------------------------
// PYTHON::usage_var(char *iname, DataType *t)
//
// This function produces a string indicating how to use a variable.
// It is called by the documentation system to produce syntactically
// correct documentation entires.
//
// s is a pointer to a character pointer.   You should create
// a string and set this pointer to point to it.
// ----------------------------------------------------------------------

char *PYTHON::usage_var(char *iname, DataType *) {

  static char temp[512];
  sprintf(temp,"%s.%s", global_name,iname);

  // Create result.  Don't modify this
  return temp;
}

// ---------------------------------------------------------------------------
// PYTHON::usage_func(char *iname, DataType *t, ParmList *l)
// 
// Produces a string indicating how to call a function in the target
// language.
//
// ---------------------------------------------------------------------------

char *PYTHON::usage_func(char *iname, DataType *, ParmList *l) {

  static DOHString *temp = 0;
  Parm  *p;
  int    i;
  if (!temp) temp = NewString("");

  Clear(temp);

  Printf(temp,"%s(", iname);
  
  // Now go through and print parameters 
  // You probably don't need to change this

  i = 0;
  p = ParmList_first(l);
  while (p != 0) {
    if (!p->ignore) {
      i++;
      /* If parameter has been named, use that.   Otherwise, just print a type  */

      if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
	if (strlen(p->name) > 0) {
	  Printf(temp,"%s",p->name);
	} else {
	  Printf(temp,"%s", p->t->print_type());
	}
      }
      p = ParmList_next(l);
      if (p != 0) {
	if (!p->ignore)
	  Putc(',',temp);
      }
    } else {
      p = ParmList_next(l);
      if (p) {
	if ((!p->ignore) && (i > 0))
	  Putc(',',temp);
      }
    }
  }

  Putc(')',temp);
  return Char(temp);
}


// ----------------------------------------------------------------------
// PYTHON::usage_const(char *iname, DataType *type, char *value)
//
// Produces a string for a constant.   Really about the same as
// usage_var() except we'll indicate the value of the constant.
// ----------------------------------------------------------------------

char *PYTHON::usage_const(char *iname, DataType *, char *value) {
  static char temp[1024];
  sprintf(temp,"%s = %s", iname, value);
  return temp;
}

// -----------------------------------------------------------------------
// PYTHON::add_native(char *name, char *funcname, DataType *, ParmList *)
//
// Add a native module name to the methods list.
// -----------------------------------------------------------------------

void PYTHON::add_native(char *name, char *funcname, DataType *, ParmList *) {
  add_method(name, funcname,0);
  if (shadow) {
    Printv(func, name, " = ", module, ".", name, "\n\n", 0);
  }
}

// -----------------------------------------------------------------------
// PYTHON::cpp_class_decl(char *name, char *rename, char *type)
//
// Treatment of an empty class definition.    Used to handle
// shadow classes across modules.
// -----------------------------------------------------------------------

void PYTHON::cpp_class_decl(char *name, char *rename, char *type) {
    char temp[256];
    if (shadow) {
	Setattr(hash,name,rename);
	// Add full name of datatype to the hash table
	if (strlen(type) > 0) {
	  sprintf(temp,"%s %s", type, name);
	  Setattr(hash,temp,rename);
	}
    }
}

// -----------------------------------------------------------------------
// PYTHON::pragma(char *name, char *type)
//
// Pragma directive. Used to do various python specific things
// -----------------------------------------------------------------------

void PYTHON::pragma(char *lang, char *cmd, char *value) {

    if (strcmp(lang,(char*)"python") == 0) {
	if (strcmp(cmd,"CODE") == 0) {
	  if (shadow) {
	    Printf(f_shadow,"%s\n",value);
	  }
	} else if (strcmp(cmd,"code") == 0) {
	  if (shadow) {
	    Printf(f_shadow,"%s\n",value);
	  }
	} else if (strcmp(cmd,"include") == 0) {
	  if (shadow) {
	    if (value) {
	      FILE *f = Swig_open(value);
	      if (!f) {
		Printf(stderr,"%s : Line %d. Unable to locate file %s\n", input_file, line_number,value);
	      } else {
		char buffer[4096];
		while (fgets(buffer,4095,f)) {
		  Printv(pragma_include,buffer,0);
		}
	      }
	    }
	  }
	} else {
	  Printf(stderr,"%s : Line %d. Unrecognized pragma.\n", input_file, line_number);
	}
    }
}


struct PyPragma {
  DOHString  *m_method;
  DOHString  *m_text;
  PyPragma  *next;
  PyPragma(char *method, char *text) {
    m_method = NewString(method);
    m_text = NewString(text);
    next = 0;
  }
  ~PyPragma() { 
    Delete(m_method);
    Delete(m_text);
    if (next) delete next;
  }
};

static PyPragma *pragmas = 0;

// -----------------------------------------------------------------------------
// PYTHON::cpp_pragma(Pragma *plist)
//
// Handle C++ pragmas
// -----------------------------------------------------------------------------

void PYTHON::cpp_pragma(Pragma *plist) {
  PyPragma *pyp1 = 0, *pyp2 = 0;
  if (pragmas) {
    delete pragmas;
    pragmas = 0;
  }
  while (plist) {
    if (strcmp(Char(plist->lang),(char*)"python") == 0) {
      if (strcmp(Char(plist->name),"addtomethod") == 0) {
            // parse value, expected to be in the form "methodName:line"
	DOHString *temp = NewString(plist->value);
	char* txtptr = strchr(Char(temp), ':');
	if (txtptr) {
	  // add name and line to a list in current_class
	  *txtptr = 0;
	  txtptr++;
	  pyp1 = new PyPragma(Char(temp),txtptr);
	  pyp1->next = 0;
	  if (pyp2) {
	      pyp2->next = pyp1;
	      pyp2 = pyp1;
	  } else {
	    pragmas = pyp1;
	    pyp2 = pragmas;
	  }
	} else {
	  Printf(stderr,"%s : Line %d. Malformed addtomethod pragma.  Should be \"methodName:text\"\n",
		  Char(plist->filename),plist->lineno);
	}
	Delete(temp);
      } else if (strcmp(Char(plist->name), "addtoclass") == 0) {
	pyp1 = new PyPragma((char*)"__class__",Char(plist->value));
	pyp1->next = 0;
	if (pyp2) {
	  pyp2->next = pyp1;
	  pyp2 = pyp1;
	} else {
	  pragmas = pyp1;
	  pyp2 = pragmas;
	}
      }
    }
    plist = plist->next;
  }
}
 
// --------------------------------------------------------------------------------
// PYTHON::emitAddPragmas(String& output, char* name, char* spacing);
//
// Search the current class pragma for any text belonging to name.
// Append the text properly spaced to the output string.
// --------------------------------------------------------------------------------

void PYTHON::emitAddPragmas(DOHString *output, char* name, char* spacing)
{
  PyPragma *p = pragmas;
  while (p) {
    if (strcmp(Char(p->m_method),name) == 0) {
      Printv(output,spacing,p->m_text,"\n",0);
    }
    p = p->next;
  }
}

/**********************************************************************
 * C++ Support + Shadow Classes
 **************************************************************************/

static  DOHString   *setattr = 0;
static  DOHString   *getattr = 0;
static  DOHString   *csetattr = 0;
static  DOHString   *cgetattr = 0;
static  DOHString   *pyclass = 0;
static  DOHString   *imethod = 0;
static  DOHString   *construct = 0;
static  DOHString   *cinit = 0;
static  DOHString   *additional = 0;
static  int       have_constructor;
static  int       have_destructor;
static  int       have_getattr;
static  int       have_setattr;
static  int       have_repr;
static  char     *class_type;
static  char     *real_classname;
static  DOHString   *base_class = 0;
static  int       class_renamed = 0;

// --------------------------------------------------------------------------
// PYTHON::cpp_open_class(char *classname, char *rname, char *ctype, int strip)
//
// Opens a new C++ class or structure.
// --------------------------------------------------------------------------

void PYTHON::cpp_open_class(char *classname, char *rname, char *ctype, int strip) {

  char  temp[256];

  this->Language::cpp_open_class(classname, rname, ctype, strip);
  
  if (shadow) {
    /* Create new strings for building up a wrapper function */
    
    setattr   = NewString("");
    getattr   = NewString("");
    csetattr  = NewString("");
    cgetattr  = NewString("");
    pyclass   = NewString("");
    imethod   = NewString("");
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
      class_renamed = 1;
    } else {
      class_name = Swig_copy_string(classname);
      class_renamed = 0;
    }
  }

  real_classname = Swig_copy_string(classname);
  class_type = Swig_copy_string(ctype);

  // Build up the hash table
  Setattr(hash,real_classname,class_name);

  sprintf(temp,"%s %s", class_type, real_classname);
  Setattr(hash,temp,class_name);

  if (shadow) {
    Printv(setattr,
	   tab4, "def __setattr__(self,name,value):\n",
	   tab8, "if (name == \"this\") or (name == \"thisown\"): self.__dict__[name] = value; return\n",
	   tab8, "method = ", class_name, ".__setmethods__.get(name,None)\n",
	   tab8, "if method: return method(self,value)\n",
	   0);
    
    Printv(getattr, tab4, "def __getattr__(self,name):\n", 0);

    Printv(csetattr, tab4, "__setmethods__ = {\n", 0);
    Printv(cgetattr, tab4, "__getmethods__ = {\n", 0);
  }

}

// --------------------------------------------------------------------------
// PYTHON::cpp_member_func(char *name, char *iname, DataType *t, ParmList *l)
//
// Creates a C++ member function
// --------------------------------------------------------------------------

void PYTHON::cpp_member_func(char *name, char *iname, DataType *t, ParmList *l) {

  Parm *p;
  int   i;
  char *realname;
  int   oldshadow;
  int   pcount;
  int   numopt;
  int   have_optional;

  char  cname[1024];

  // Create the default member function
  
  oldshadow = shadow;    // Disable shadowing when wrapping member functions
  if (shadow) shadow = shadow | PYSHADOW_MEMBER;
  this->Language::cpp_member_func(name,iname,t,l);
  shadow = oldshadow;
  if (shadow) {
    if (!iname)
      realname = name;
    else
      realname = iname;
    
    // Check to see if we've already seen this
    sprintf(cname,"python:%s::%s",class_name,realname);
    if (Getattr(symbols,cname)) {
      return;   // Forget it, already saw it
    }
    Setattr(symbols,cname,cname);
    
    if (strcmp(realname,"__repr__") == 0) 
      have_repr = 1;

    if (!((Getattr(hash,t->name)) && (t->is_pointer <=1)) && !noopt) {
      Printv(imethod,
	     class_name, ".", realname, " = new.instancemethod(", module, ".", Swig_name_member(class_name,realname), ", None, ", class_name, ")\n",
	     0);
      /*       *pyclass << tab4 << realname << " = " << module << ".__shadow__." << Swig_name_member(class_name,realname) << "\n"; */
    } else {

      // Now add it to the class
    
      if (use_kw)
	Printv(pyclass,tab4, "def ", realname, "(*args, **kwargs):\n", 0);
      else
	Printv(pyclass, tab4, "def ", realname, "(*args):\n", 0);
      
      if (use_kw)
	Printv(pyclass, tab8, "val = apply(", module, ".", Swig_name_member(class_name,realname), ",args, kwargs)\n", 0);
      else
	Printv(pyclass, tab8, "val = apply(", module, ".", Swig_name_member(class_name,realname), ",args)\n",0);
      
      // Check to see if the return type is an object
      if ((Getattr(hash,t->name)) && (t->is_pointer <= 1)) {
	if (!typemap_check((char*)"out",typemap_lang,t,Swig_name_member(class_name,realname))) {
	  if (!have_output) {
	    Printv(pyclass, tab8, "if val: val = ", GetChar(hash,t->name), "Ptr(val) ", 0);
	    if (((Getattr(hash,t->name)) && (t->is_pointer < 1)) ||
		((Getattr(hash,t->name)) && (t->is_pointer == 1) && NewObject))
	      Printf(pyclass, "; val.thisown = 1\n");
	    else 
	      Printf(pyclass,"\n");
	  } else {
	    // Do nothing!
	  }
	}
      }
      Printv(pyclass, tab8, "return val\n", 0);
    }
    //    emitAddPragmas(*pyclass, realname, tab8);
    //    *pyclass << tab8 << "return val\n";
  }
}

// -----------------------------------------------------------------------------
// void PYTHON::cpp_constructor(char *name, char *iname, ParmList *l)
//
// Make a constructor for our class
// -----------------------------------------------------------------------------

void PYTHON::cpp_constructor(char *name, char *iname, ParmList *l) {
  char *realname;
  Parm *p;
  int   i;
  int   oldshadow = shadow;
  char  cname[1024];
  int   pcount, numopt;
  int   have_optional;

  if (shadow) shadow = shadow | PYSHADOW_MEMBER;
  this->Language::cpp_constructor(name,iname,l);
  shadow = oldshadow;

  if (shadow) {
    if (iname)
      realname = iname;
    else {
      if (class_renamed) realname = class_name;
      else realname = class_name;
    }
    
    // Check to see if we've already seen this
    sprintf(cname,":python:constructor:%s::%s",class_name,realname);
    if (Getattr(symbols,cname)) {
      return;   // Forget it, already seen it
    }
    Setattr(symbols,cname,cname);

    if (!have_constructor) { 

      // Create a new constructor 

      if (use_kw)
	Printv(construct, tab4, "def __init__(self,*args,**kwargs):\n", 0);
      else
	Printv(construct, tab4, "def __init__(self,*args):\n",0);

      if (use_kw)
	Printv(construct, tab8, "self.this = apply(", module, ".", Swig_name_construct(realname), ",args,kwargs)\n", 0);
      else
	Printv(construct, tab8, "self.this = apply(", module, ".", Swig_name_construct(realname), ",args)\n", 0);
      Printv(construct, tab8, "self.thisown = 1\n", 0);
      emitAddPragmas(construct,(char*)"__init__",(char*)tab8);
      have_constructor = 1;
    } else {

      // Hmmm. We seem to be creating a different constructor.  We're just going to create a
      // function for it.

      if (use_kw)
	Printv(additional, "def ", realname, "(*args,**kwargs):\n", 0);
      else
	Printv(additional, "def ", realname, "(*args):\n", 0);

      Printv(additional, tab4, "val = ", class_name, "Ptr(apply(", 0);
      if (use_kw)
	Printv(additional, module, ".", Swig_name_construct(realname), ",args,kwargs))\n", 0);
      else
	Printv(additional, module, ".", Swig_name_construct(realname), ",args))\n", 0);
      Printv(additional,tab4, "val.thisown = 1\n",
	     tab4, "return val\n\n", 0);
    }
  }
}

// ------------------------------------------------------------------------------
// void PYTHON::cpp_destructor(char *name, char *newname)
//
// Creates a destructor for this object
// ------------------------------------------------------------------------------

void PYTHON::cpp_destructor(char *name, char *newname) {
  char *realname;
  int oldshadow = shadow;

  if (shadow) shadow = shadow | PYSHADOW_MEMBER;
  this->Language::cpp_destructor(name,newname);
  shadow = oldshadow;
  if (shadow) {
    if (newname) realname = newname;
    else {
      if (class_renamed) realname = class_name;
      else realname = name;
    }
    
    Printv(pyclass, tab4, "def __del__(self,", module, "=", module, "):\n", 0);
    emitAddPragmas(pyclass,(char*)"__del__",(char*)tab8);
    Printv(pyclass, tab8, "if self.thisown == 1 :\n",
	   tab8, tab4, module, ".", Swig_name_destroy(realname), "(self)\n", 0);
    
    have_destructor = 1;
  }
}

// -------------------------------------------------------------------------------
// PYTHON::cpp_close_class()
//
// Closes a Python class and writes out a wrapper
// -------------------------------------------------------------------------------
    
void PYTHON::cpp_close_class() {
  DOHString    *ptrclass;
  DOHString    *repr;
  
  ptrclass = NewString("");
  repr =  NewString("");

  if (shadow) {

    if (!have_constructor) {
      // Build a constructor that takes a pointer to this kind of object
      Printv(construct,
	     tab4, "def __init__(self,this):\n",
	     tab8, "self.this = this\n",
	     0);
    }

    // First, build the pointer base class
    if (base_class) {
      Printv(ptrclass, "class ", class_name, "(", base_class, "):\n", 0);
    } else {
      Printv(ptrclass, "class ", class_name, ":\n", 0);
    }

    Printv(getattr,
	   tab8, "method = ", class_name, ".__getmethods__.get(name,None)\n",
	   tab8, "if method: return method(self)\n",
	   tab8, "raise AttributeError,name\n",
	   0);
    Printv(setattr, tab8, "self.__dict__[name] = value\n",0);
    Printv(cgetattr, tab4, "}\n", 0);
    Printv(csetattr, tab4, "}\n", 0);
    Printv(ptrclass,cinit,construct,"\n",0);

    Printv(classes,ptrclass,pyclass,0);

    if (have_setattr) {
      Printv(classes, csetattr, setattr, 0);
    }
    if (have_getattr) {
      Printv(classes,cgetattr,getattr,0);
    }
    
    if (!have_repr) {
      // Supply a repr method for this class 
      Printv(repr,
	     tab4, "def __repr__(self):\n",
	     tab8, "return \"<C ", class_name," instance at %s>\" % (self.this,)\n",
	     0);

      Printv(classes,repr,0);
      emitAddPragmas(classes,(char*)"__class__",(char*)tab4);
    }

    // Now build the real class with a normal constructor

    Printv(classes,
	   "class ", class_name, "Ptr(", class_name, "):\n",
	   tab4, "def __init__(self,this):\n",
	   tab8, "self.this = this\n",
	   tab8, "self.thisown = 0\n",
	   tab8, "self.__class__ = ", class_name, "\n",
	   "\n", additional, "\n",
	   0);

    Printv(classes,imethod,"\n",0);
    Delete(pyclass);
    Delete(imethod);
    Delete(setattr);
    Delete(getattr);
    Delete(additional);
  }
  Delete(ptrclass);
  Delete(repr);
}

void PYTHON::cpp_cleanup() { };

void PYTHON::cpp_inherit(char **baseclass,int) {

  char *bc;
  int   i = 0, first_base = 0;

  if (!shadow) {
    this->Language::cpp_inherit(baseclass);
    return;
  }

  // We'll inherit variables and constants, but not methods

  this->Language::cpp_inherit(baseclass, INHERIT_VAR);

  if (!baseclass) return;
  base_class = NewString("");

  // Now tell the Python module that we're inheriting from a base class

  while (baseclass[i]) {
    bc = GetChar(hash,baseclass[i]);
    if (bc) {
      if (first_base) Putc(',',base_class);
      Printv(base_class,bc,0);
      first_base = 1;
    }
    i++;
  }
  if (!first_base) {
    Delete(base_class);
    base_class = 0;
  }
}

// --------------------------------------------------------------------------------
// PYTHON::cpp_variable(char *name, char *iname, DataType *t)
//
// Adds an instance member.
// --------------------------------------------------------------------------------

void PYTHON::cpp_variable(char *name, char *iname, DataType *t) {
  char *realname;
  int   inhash = 0;
  int   oldshadow = shadow;
  char  cname[512];

  if (shadow) shadow = shadow | PYSHADOW_MEMBER;
  this->Language::cpp_variable(name,iname,t);
  shadow = oldshadow;

  if (shadow) {
    have_getattr = 1;
    have_setattr = 1;
    if (!iname)
      realname = name;
    else
      realname = iname;

    // Check to see if we've already seen this
    sprintf(cname,"python:%s::%s:",class_name,realname);
    if (Getattr(symbols,cname)) {
      return;   // Forget it, already seen it
    }
    Setattr(symbols,cname,cname);
    
    // Figure out if we've seen this datatype before
    
    if ((Getattr(hash,t->name)) && (t->is_pointer <= 1)) inhash = 1;
    
    // Now write some code to set the variable
    if (Status & STAT_READONLY) {
      //      *setattr << tab8 << tab4 << "raise RuntimeError, \'Member is read-only\'\n";
    } else {
      Printv(csetattr, tab8, "\"", realname, "\" : ", module, ".", Swig_name_set(Swig_name_member(class_name,realname)), ",\n", 0);
    }
    // Write some code to get the variable
    if (inhash) {
      Printv(cgetattr, tab8, "\"", realname, "\" : lambda x : ", GetChar(hash,t->name), "Ptr(", module, ".", Swig_name_get(Swig_name_member(class_name,realname)), "(x)),\n", 0);

    } else {
      Printv(cgetattr, tab8, "\"", realname, "\" : ", module, ".", Swig_name_get(Swig_name_member(class_name,realname)),",\n", 0);
    }
  }
}

// --------------------------------------------------------------------------------
// PYTHON::cpp_declare_const(char *name, char *iname, DataType *type, char *value)
//
// Add access to a C++ constant
// --------------------------------------------------------------------------------

void PYTHON::cpp_declare_const(char *name, char *iname, DataType *type, char *value) {
  char *realname;
  int   oldshadow = shadow;
  char  cname[512];

  if (shadow) shadow = shadow | PYSHADOW_MEMBER;
  this->Language::cpp_declare_const(name,iname,type,value);
  shadow = oldshadow;

  if (shadow) {
    if (!iname)
      realname = name;
    else
      realname = iname;

    // Check to see if we've already seen this
    
    sprintf(cname,"python:%s::%s", class_name, realname);
    if (Getattr(symbols,cname)) {
      return;   // Forget it, already seen it
    }
    Setattr(symbols,cname,cname);
    Printv(cinit, tab4, realname, " = ", module, ".", Swig_name_member(class_name,realname), "\n", 0);
  }
}
 
// --------------------------------------------------------------------------------
// PYTHON::add_typedef(DataType *t, char *name)
//
// This is called whenever a typedef is encountered.   When shadow classes are
// used, this function lets us discovered hidden uses of a class.  For example :
//
//     struct FooBar {
//            ...
//     }
//
// typedef FooBar *FooBarPtr;
//
// --------------------------------------------------------------------------------

void PYTHON::add_typedef(DataType *t, char *name) {

  if (!shadow) return;

  // First check to see if there aren't too many pointers

  if (t->is_pointer > 1) return;

  if (Getattr(hash,name)) return;      // Already added

  // Now look up the datatype in our shadow class hash table

  if (Getattr(hash,t->name)) {

    // Yep.   This datatype is in the hash
    
    // Put this types 'new' name into the hash

    Setattr(hash,name, GetChar(hash,t->name));
  }
}

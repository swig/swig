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

/***********************************************************************
 * $Header$
 *
 * tcl8.cxx
 *
 * Module for creating Tcl 8.0 native wrapper functions. 
 ***********************************************************************/

#include "mod11.h"
#include "tcl8.h"
#include <ctype.h>

static char *Tcl_config=(char*)"swigtcl.swg";
static char *usage = (char*)"\
Tcl 8.0 Options (available with -tcl)\n\
     -module name    - Set name of module\n\
     -prefix name    - Set a prefix to be appended to all names\n\
     -namespace      - Build module into a Tcl 8 namespace. \n\
     -noobject       - Omit code for object oriented interface.\n\
     -old            - Use old SWIG interface (same as -noobject).\n\n";

static char *ns_name = 0;

static DOHString *mod_init = 0;
static DOHString *mod_extern = 0;
static DOHString *cmd_info = 0;
static DOHString *var_info = 0;
static DOHString *methods = 0;
static DOHString *attributes = 0;

/* Various parameters */

static char *prefix = 0;
static char *module = 0;
static int  nspace = 0;
static int  shadow = 1;
static char *tcl_path = (char*)"tcl";
static char interp_name[256] = "interp";
static char  *init_name = 0;
static char  *char_result = (char *)"TCL_VOLATILE";

static int    have_constructor;
static int    have_destructor;

static char   *class_name = 0;
static char   *class_type = 0;
static char   *real_classname = 0;
static char   *base_class = 0;
static DOHHash   *hash = 0;
static DOHHash   *repeatcmd = 0; 
static DOHHash   *setget = 0;

// ---------------------------------------------------------------------
// TCL8::parse_args(int argc, char *argv[])
//
// Parse tcl specific command line options
// ---------------------------------------------------------------------

void TCL8::parse_args(int argc, char *argv[]) {
  
  int i = 1;
  sprintf(LibDir,"%s",tcl_path);

  // Look for certain command line options

  for (i = 1; i < argc; i++) {
      if (argv[i]) {
	  if (strcmp(argv[i],"-prefix") == 0) {
	    if (argv[i+1]) {
	      prefix = new char[strlen(argv[i+1])+2];
	      strcpy(prefix, argv[i+1]);
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i++;
	    } else {
	      Swig_arg_error();
	    }
	  } else if (strcmp(argv[i],"-module") == 0) {
	    if (argv[i+1]) {
	      set_module(argv[i+1],0);
	      Swig_mark_arg(i);
	      Swig_mark_arg(i+1);
	      i++;
	    } else {
	      Swig_arg_error();
	    }
	  } else if (strcmp(argv[i],"-namespace") == 0) {
	    nspace = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-old") == 0) {
	    shadow = 0;
	    Swig_mark_arg(i);
          } else if (strcmp(argv[i],"-noobject") == 0) {
	    shadow = 0;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-help") == 0) {
	    fputs(usage,stderr);
	  }
      }
  }

  // If a package has been specified, make sure it ends with a '_'

  if (prefix) {
    ns_name = Swig_copy_string(prefix);
    if (prefix[strlen(prefix)] != '_') {
      prefix[strlen(prefix)+1] = 0;
      prefix[strlen(prefix)] = '_';
    }
  } else 
    prefix = (char*)"";

  // Create a symbol SWIGTCL

  Preprocessor_define((void *) "SWIGTCL 1",0);
  Preprocessor_define((void *) "SWIGTCL8 1", 0);

  // Set name of typemaps

  typemap_lang = (char*)"tcl8";

}

// ---------------------------------------------------------------------
// void TCL8::parse()
//
// Start parsing an interface file for Tcl.
// ---------------------------------------------------------------------

void TCL8::parse() {

  Printf(stderr,"Making wrappers for Tcl 8.x\n");

  mod_init = NewString("");
  mod_extern = NewString("");
  cmd_info = NewString("");
  var_info = NewString("");
  methods = NewString("");
  attributes = NewString("");

  hash = NewHash();
  repeatcmd = NewHash();
  setget = NewHash();

  // Print out TCL specific headers
  
  headers();
  
  // Run the parser
  
  yyparse();

}

// ---------------------------------------------------------------------
// TCL8::set_module(char *mod_name,char **mod_list)
//
// Sets the module name.
// Does nothing if it's already set (so it can be overridden as a command
// line option).
//
// mod_list is a NULL-terminated list of additional modules.  This
// is really only useful when building static executables and other
// things.
//----------------------------------------------------------------------

void TCL8::set_module(char *mod_name, char **mod_list) {

  char temp[256], *c;
  int  i;

  if (module) return;
  
  module = new char[strlen(mod_name)+1];
  strcpy(module,mod_name);

  // Fix capitalization for Tcl 

  c = module;
  while (*c) {
    *c = (char) tolower(*c);
    c++;
  }

  // Now create an initialization function

  sprintf(temp,"%s_Init", module);
  init_name = new char[strlen(temp) + 1];
  strcpy(init_name, temp);
  *init_name = toupper(*init_name);

  if (!ns_name) ns_name = Swig_copy_string(module);

  // If namespaces have been specified, set the prefix to the module name

  if ((nspace) && (strlen(prefix) < 1)) {
    prefix = new char[strlen(module)+2];
    strcpy(prefix,module);
    prefix[strlen(module)] = '_';
    prefix[strlen(module)+1] = 0;
  }

  // If additional modules have been specified, create some code for
  // initializing them.

  if (mod_list) {
    i = 0;
    while (mod_list[i]) {
      c = mod_list[i];
      while (*c) {
	*c = (char) tolower(*c);
	c++;
      }
      sprintf(temp,"%s_Init",mod_list[i]);
      temp[0] = toupper(temp[0]);
      
      // Dump out some initialization code
      
      Printv(mod_init,
	     tab4, "if (", temp, "(", interp_name, ") == TCL_ERROR) {\n",
	     tab8, "return TCL_ERROR;\n",
	     tab4, "}\n\n",
	     0);
      Printv(mod_extern, "extern int ", temp, "(Tcl_Interp *);\n", 0);
      i++;
    }
  }
}


// ---------------------------------------------------------------------
// TCL8::set_init(char *iname)
//
// Sets the initialization function name.
// Does nothing if it's already set
//
//----------------------------------------------------------------------

void TCL8::set_init(char *iname) {

  if (init_name) return;
  init_name = new char[strlen(iname)+1];
  strcpy(init_name, iname);

}

// ---------------------------------------------------------------------
// TCL8::headers(void)
//
// Generate the appropriate header files for TCL interface.
// ----------------------------------------------------------------------

void TCL8::headers(void)
{

  Swig_banner(f_runtime);
  
  // Include a Tcl configuration file for Unix,Mac,Wintel.

  if (NoInclude) {
    Printf(f_runtime,"#define SWIG_NOINCLUDE\n");
  }

  if (Swig_insert_file("swigtcl8.swg",f_runtime) == -1) {
    Printf(stderr,"SWIG : Fatal error. Unable to locate 'swigtcl8.swg' in SWIG library.\n");
    SWIG_exit(1);
  }
}

// --------------------------------------------------------------------
// TCL8::initialize(void)
//
// Produces an initialization function.   Assumes that the init function
// name has already been specified.
// ---------------------------------------------------------------------

void TCL8::initialize() 
{

  if ((!ns_name) && (nspace)) {
    Printf(stderr,"Tcl error.   Must specify a namespace.\n");
    SWIG_exit(1);
  }

  if (!init_name) {
    Printf(stderr,"*** Error. No module name specified.\n");
    SWIG_exit(1);
  }

  Printf(f_header,"#define SWIG_init    %s\n", init_name);
  if (!module) module = (char*)"swig";
  Printf(f_header,"#define SWIG_name    \"%s\"\n", module);
  if (nspace) {
    Printf(f_header,"#define SWIG_prefix  \"%s::\"\n", ns_name);
    Printf(f_header,"#define SWIG_namespace \"%s\"\n\n", ns_name);
  } else {
    Printf(f_header,"#define SWIG_prefix  \"%s\"\n", prefix);
    Printf(f_header,"#define SWIG_namespace \"\"\n\n");
  }
  Printf(f_header,"#ifdef __cplusplus\n");
  Printf(f_header,"extern \"C\" {\n");
  Printf(f_header,"#endif\n");
  Printf(f_header,"#ifdef MAC_TCL\n");
  Printf(f_header,"#pragma export on\n");
  Printf(f_header,"#endif\n");
  Printf(f_header,"SWIGEXPORT(int) %s(Tcl_Interp *);\n", init_name);
  Printf(f_header,"#ifdef MAC_TCL\n");
  Printf(f_header,"#pragma export off\n");
  Printf(f_header,"#endif\n");
  Printf(f_header,"#ifdef __cplusplus\n");
  Printf(f_header,"}\n");
  Printf(f_header,"#endif\n");
  

  Printf(f_init,"SWIGEXPORT(int) %s(Tcl_Interp *%s) {\n", init_name, interp_name);
  Printf(f_init,"\t int i;\n");
  if (nspace) {
    Printf(f_init,"#ifdef ITCL_NAMESPACES\n");
    Printf(f_init,"\t Itcl_Namespace spaceId;\n");
    Printf(f_init,"#endif\n");
  }
  
  Printf(f_init,"\t if (%s == 0) \n", interp_name);
  Printf(f_init,"\t\t return TCL_ERROR;\n");

  /* Check to see if other initializations need to be performed */

  if (Len(mod_extern)) {
    Printf(f_init,"%s\n",mod_init);
    Printf(f_header,"#ifdef __cplusplus\n");
    Printf(f_header,"extern \"C\" {\n");
    Printf(f_header,"#endif\n");
    Printf(f_header,"%s\n",mod_extern);
    Printf(f_header,"#ifdef __cplusplus\n");
    Printf(f_header,"}\n");
    Printf(f_header,"#endif\n");
  }

  /* Check to see if we're adding support for Tcl8 nspaces */
  if (nspace) {
    Printf(f_init,"#if (TCL_MAJOR_VERSION >= 8)\n");
    Printf(f_init,"\t Tcl_Eval(%s,\"namespace eval %s { }\");\n", interp_name, ns_name);
    Printf(f_init,"#endif\n");
  }
  
  Printf(cmd_info, "\nstatic _swig_command_info _swig_commands[] = {\n");
  Printf(var_info, "\nstatic _swig_var_info _swig_variables[] = {\n");
  Printv(f_init,
	 tab4, "{\n",
	 tab8, "int i;\n",
	 tab8, "for (i = 0; _swig_types_initial[i]; i++) {\n",
	 tab8, tab4, "_swig_types[i] = SWIG_TypeRegister(_swig_types_initial[i]);\n",
	 tab8, "}\n",
	 tab4, "}\n",
	 0);
}

// ---------------------------------------------------------------------
// TCL8::close(void)
//
// Wrap things up.  Close initialization function.
// ---------------------------------------------------------------------

void TCL8::close(void)
{
  Printv(cmd_info, tab4, "{0, 0, 0}\n", "};\n",0);

  Printv(var_info, tab4, "{0,0,0,0}\n", "};\n",0);

  Printf(f_wrappers,"%s", cmd_info);
  Printf(f_wrappers,"%s", var_info);

  Printf(f_init,"\tfor (i = 0; _swig_commands[i].name; i++) {\n");
  Printf(f_init,"\t     Tcl_CreateObjCommand(interp, (char *) _swig_commands[i].name, _swig_commands[i].wrapper, _swig_commands[i].clientdata, NULL);\n");
  Printf(f_init,"\t}\n");

  Printf(f_init,"\tfor (i = 0; _swig_variables[i].name; i++) {\n");
  Printf(f_init,"\t     Tcl_SetVar(interp, (char *) _swig_variables[i].name, \"\", TCL_GLOBAL_ONLY);\n");
  Printf(f_init,"\t     Tcl_TraceVar(interp, (char *) _swig_variables[i].name, TCL_TRACE_READS | TCL_GLOBAL_ONLY, _swig_variables[i].get, (ClientData) _swig_variables[i].addr);\n");
  Printf(f_init,"\t     Tcl_TraceVar(interp, (char *) _swig_variables[i].name, TCL_TRACE_WRITES | TCL_GLOBAL_ONLY, _swig_variables[i].set, (ClientData) _swig_variables[i].addr);\n");
  Printf(f_init,"\t}\n");

  // Dump the pointer equivalency table

  emit_type_table(f_runtime);

  //  emit_ptr_equivalence(f_init);

  // Close the init file and quit

  Printf(f_init,"\t return TCL_OK;\n");
  Printf(f_init,"}\n");

}

// ----------------------------------------------------------------------
// TCL8::get_pointer(char *iname, char *srcname, char *src, char *dest,
//                  DataType *t, String &f, char *ret)
//
// iname     = name of function or variable
// srcname   = name of source
// src       = source variable in wrapper code
// dest      = destination variable in wrapper code
// t         = Datatype 
// f         = String where output is going to go
// ret       = Return action
// ----------------------------------------------------------------------

void TCL8::get_pointer(char *iname, char *srcname, char *src, char *dest,
		      DataType *t, DOHString *f, char *ret) {

  // Pointers are read as hex-strings with encoded type information
  
  DataType_remember(t);
  Printv(f, tab4, "if ((SWIG_ConvertPtr(interp,", src, ",(void **) &", dest, ",",0);

  if (t->type == T_VOID) Printf(f, "0)) == TCL_ERROR) { return TCL_ERROR; }\n");
  else 
    Printv(f, "SWIGTYPE", DataType_manglestr(t), ")) == TCL_ERROR) { return TCL_ERROR; }\n", 0);
}

// ----------------------------------------------------------------------
// TCL8::create_command(char *cname, char *iname)
//
// Creates a Tcl command from a C function.
// ----------------------------------------------------------------------

void TCL8::create_command(char *cname, char *iname) {

  char *wname = Swig_name_wrapper(cname);

  Printv(cmd_info, tab4, "{ SWIG_prefix \"", iname, "\", ", wname, ", NULL},\n", 0);
  
  // Add interpreter name to repeatcmd hash table.  This hash is used in C++ code
  // generation to try and find repeated wrapper functions.

  Setattr(repeatcmd,iname,wname);
}

// ----------------------------------------------------------------------
// TCL8::create_function(char *name, char *iname, DataType *d, ParmList *l)
//
// Create a function declaration and register it with the interpreter.
// ----------------------------------------------------------------------

void TCL8::create_function(char *name, char *iname, DataType *d, ParmList *l)
{
  Parm            *p;
  int              pcount,i,j;
  char            *wname;
  char            *usage = 0, *tm;
  char             source[64];
  char             target[64];
  char             argnum[32];
  Wrapper         *f;
  DOHString       *incode, *cleanup, *outarg, *argstr, *args;
  int              numopt= 0;

  f = NewWrapper();
  incode = NewString("");
  cleanup = NewString("");
  outarg = NewString("");
  argstr = NewString("\"");
  args = NewString("");

  // Make a wrapper name for this function

  wname = Swig_name_wrapper(iname);

  // Now write the wrapper function itself....this is pretty ugly

  Printv(f->def,
	 "static int\n ", wname, "(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {",
	 0);

  // Print out variables for storing arguments.

  pcount = emit_args(d, l, f);
  numopt = check_numopt(l);

  // Create a local variable for holding the interpreter result value

  // Check the number of arguments

  usage = usage_func(iname,d,l);       // Create a usage string

  // Extract parameters.    This case statement should be used to extract
  // Function parameters.   Add more cases if you want to do more.

  i = 0;
  j = 0;
  p = ParmList_first(l);
  while (p != 0) {
    DataType *pt = Parm_Gettype(p);
    char     *pn = Parm_Getname(p);
    char     *pv = Parm_Getvalue(p);
    // Produce string representations of the source and target arguments
    sprintf(source,"objv[%d]",j+1);
    sprintf(target,"%s", Parm_Getlname(p));
    sprintf(argnum,"%d",j+1);

    // See if this argument is being ignored
    
    if (!p->ignore) {
      if (j == (pcount-numopt)) 
	Putc('|',argstr);

      if ((tm = typemap_lookup((char*)"in",(char*)"tcl8",pt,pn,source,target,f))) {
	Putc('o',argstr);
	Printf(args,",0");

	// Yep.  Use it instead of the default
	Printf(incode,"%s\n", tm);
	Replace(incode,"$argnum",argnum, DOH_REPLACE_ANY);
	Replace(incode,"$arg",source, DOH_REPLACE_ANY);
      } else {
	if (!pt->is_pointer) {
	
	  // Extract a parameter by value.
	
	  switch(pt->type) {
	    
	    // Signed Integers
	  
	  case T_INT:
	  case T_SINT:
	  case T_UINT:
	    Putc('i', argstr);
	    Printf(args,",&%s",target);
	    break;
	  case T_BOOL:
	    Putc('i',argstr);
	    {
	      char tb[32];
	      sprintf(tb,"tempb%d",i);
	      Wrapper_add_localv(f,tb,"int",tb,0);
	      Printf(args,",&%s",tb);
	      Printv(incode, tab4, target, " = (bool) ", tb, ";\n", 0);
	    }
	    break;
	  case T_SHORT:
	  case T_SSHORT:
	  case T_USHORT:
	    Putc('h',argstr);
	    Printf(args,",&%s",target);
	    break;
	  case T_LONG:
	  case T_SLONG:
	  case T_ULONG:
	    Putc('l',argstr);
	    Printf(args,",&%s",target);
	    break;
	  case T_SCHAR:
	  case T_UCHAR:
	    Putc('b',argstr);
	    Printf(args,",&%s", target);
	    break;
	  
	  // Floating point

	  case T_FLOAT:
	    Putc('f',argstr);
	    Printf(args,",&%s", target);
	    break;

	  case T_DOUBLE:
	    Putc('d',argstr);
	    Printf(args,",&%s", target);
	    break;
	  
	    // A single character
	  case T_CHAR :
	    Putc('c',argstr);
	    Printf(args,",&%s",target);
	    break;
	  
	    // Void.. Do nothing.
	  
	  case T_VOID :
	    break;
	    // User defined.   This is an error.
	    
	  case T_USER:
	    // Unsupported data type
	    
	  default :
	    Printf(stderr,"%s : Line %d: Unable to use type %s as a function argument.\n",
		    input_file, line_number, DataType_str(pt,0));
	    break;
	  }
	} else {
	  
	  // Function argument is some sort of pointer
	  // Look for a string.   Otherwise, just pull off a pointer.
	  
	  if ((pt->type == T_CHAR) && (pt->is_pointer == 1)) {
	    Putc('s',argstr);
	    Printf(args,",&%s",target);
	  } else {
	    DataType_remember(pt);
	    Putc('p',argstr);
	    Printv(args, ",&", target, ", SWIGTYPE", DataType_manglestr(pt), 0);
	  }
	}
      }
      j++;
    }

    // Check to see if there was any sort of a constaint typemap
    if ((tm = typemap_lookup((char*)"check",(char*)"tcl8",pt,pn,source,target))) {
      // Yep.  Use it instead of the default
      Printf(incode,"%s\n", tm);
      Replace(incode,"$argnum",argnum, DOH_REPLACE_ANY);
      Replace(incode,"$arg",source, DOH_REPLACE_ANY);
    }

    // Check if there was any cleanup code (save it for later)
    if ((tm = typemap_lookup((char*)"freearg",(char*)"tcl8",pt,pn,target,(char*)"tcl_result"))) {
      // Yep.  Use it instead of the default
      Printf(cleanup,"%s\n", tm);
      Replace(cleanup,"$argnum",argnum, DOH_REPLACE_ANY);
      Replace(cleanup,"$arg",source,DOH_REPLACE_ANY);
    }
    // Look for output arguments
    if ((tm = typemap_lookup((char*)"argout",(char*)"tcl8",pt,pn,target,(char*)"tcl_result"))) {
      Printf(outarg,"%s\n", tm);
      Replace(outarg,"$argnum",argnum, DOH_REPLACE_ANY);
      Replace(outarg,"$arg",source, DOH_REPLACE_ANY);
    }
    i++;
    p = ParmList_next(l);   // Get next parameter and continue
  }
  Printf(argstr,":%s\"",usage);
  Printv(f->code,
	 tab4, "if (SWIG_GetArgs(interp, objc, objv,", argstr, args, ") == TCL_ERROR) return TCL_ERROR;\n",
	 0);

  Printv(f->code,incode,0);

  // Now write code to make the function call

  emit_func_call(name,d,l,f);

  // Return value if necessary 

  if ((tm = typemap_lookup((char*)"out",(char*)"tcl8",d,name,(char*)"result",(char*)"tcl_result"))) {
    // Yep.  Use it instead of the default
    Printf(f->code,"%s\n", tm);
  } else if ((d->type != T_VOID) || (d->is_pointer)) {
    if (!d->is_pointer) {
	
      // Function returns a "value"
	
      switch(d->type) {
	// Is an integer
      case T_BOOL:
      case T_INT:
      case T_SINT:
      case T_SHORT:
      case T_SSHORT:
      case T_LONG :
      case T_SLONG:
      case T_SCHAR:
      case T_UINT:
      case T_USHORT:
      case T_ULONG:
      case T_UCHAR:
	Printv(f->code, tab4, "Tcl_SetObjResult(interp,Tcl_NewIntObj((long) result));\n",0);
	break;
	
	// Is a single character.  Assume we return it as a string
      case T_CHAR :
	Printv(f->code, tab4, "Tcl_SetObjResult(interp,Tcl_NewStringObj(&result,1));\n",0);
	break;
	
	// Floating point number
      case T_DOUBLE :
      case T_FLOAT :
	Printv(f->code, tab4, "Tcl_SetObjResult(interp,Tcl_NewDoubleObj((double) result));\n",0);
	break;
	
	// User defined type
      case T_USER :
	
	// Okay. We're returning malloced memory at this point.
	// Probably dangerous, but who said safety was a good thing?
	
	d->is_pointer++;
	DataType_remember(d);
	Printv(f->code, tab4, "Tcl_SetObjResult(interp,SWIG_NewPointerObj((void *) result,SWIGTYPE",
	       DataType_manglestr(d), "));\n", 0);
	
	d->is_pointer--;
	break;
	
	// Unknown type
      default :
	Printf(stderr,"%s : Line %d: Unable to use return type %s in function %s.\n",
		input_file, line_number, DataType_str(d,0), name);
	break;
      }
    } else {
	
      // Is a pointer return type
      
      if ((d->type == T_CHAR) && (d->is_pointer == 1)) {
	// Return a character string
	Printv(f->code, tab4, "Tcl_SetObjResult(interp,Tcl_NewStringObj(result,-1));\n",0);
      } else {
	DataType_remember(d);
	Printv(f->code, tab4, "Tcl_SetObjResult(interp,SWIG_NewPointerObj((void *) result,SWIGTYPE",
	       DataType_manglestr(d), "));\n",
	       0);
      }
    }
  }

  // Dump output argument code
  Printv(f->code,outarg,0);

  // Dump the argument cleanup code
  Printv(f->code,cleanup,0);

  // Look for any remaining cleanup

  if (NewObject) {
    if ((tm = typemap_lookup((char*)"newfree",(char*)"tcl8",d,iname,(char*)"result",(char*)""))) {
      Printf(f->code,"%s\n", tm);
    }
  }

  if ((tm = typemap_lookup((char*)"ret",(char*)"tcl8",d,name,(char*)"result",(char*)""))) {
    // Yep.  Use it instead of the default
    Printf(f->code,"%s\n", tm);
  }
  Printv(f->code,tab4, "return TCL_OK;\n}", 0);

  // Substitute the cleanup code
  Replace(f->code,"$cleanup",cleanup,DOH_REPLACE_ANY);
  Replace(f->code,"$name", iname, DOH_REPLACE_ANY);

  // Dump out the function

  Wrapper_print(f,f_wrappers);

  // Now register the function with Tcl

  Printv(cmd_info, tab4, "{ SWIG_prefix \"", iname, "\", ", wname, ", NULL},\n", 0);

  Delete(incode);
  Delete(cleanup);
  Delete(outarg);
  Delete(argstr);
  Delete(args);
  DelWrapper(f);
}

// -----------------------------------------------------------------------
// TCL8::link_variable(char *name, char *iname, DataType *t, int ex)
//
// Create a TCL link to a variable.
// -----------------------------------------------------------------------

void TCL8::link_variable(char *name, char *iname, DataType *t)
{
  char      *tm, *tm1;

  // See if there were any typemaps

  tm = typemap_lookup((char*)"varin",(char*)"tcl8",t,name,(char*)"",(char*)"");
  tm1 = typemap_lookup((char*)"varout",(char*)"tcl8",t,name,(char*)"",(char*)"");
  if (tm || tm1) {
    Printf(stderr,"%s : Line %d. Warning. varin/varout typemap methods not supported.",
	    input_file, line_number);
  }

  // Dump a collection of set/get functions suitable for variable tracing
  if (!Getattr(setget,DataType_str(t,0))) {
    Setattr(setget,DataType_str(t,0),"1");
    Wrapper *get, *set;
    get = NewWrapper();
    set = NewWrapper();
    Printv(set->def, "static char *_swig_", DataType_manglestr(t), "_set(ClientData clientData, Tcl_Interp *interp, char *name1, char *name2, int flags) {",0);

    Printv(get->def, "static char *_swig_", DataType_manglestr(t), "_get(ClientData clientData, Tcl_Interp *interp, char *name1, char *name2, int flags) {",0);
    t->is_pointer++;
    Wrapper_add_localv(get,"addr",DataType_str(t,0),"addr",0);
    Wrapper_add_localv(set,"addr",DataType_str(t,0),"addr",0);
    Printv(set->code, tab4, "addr = (", DataType_lstr(t,0), ") clientData;\n", 0);
    Printv(get->code, tab4, "addr = (", DataType_lstr(t,0), ") clientData;\n", 0);
    t->is_pointer--;
    Wrapper_add_local(set, "value", "char *value");
    Wrapper_add_local(get, "value", "Tcl_Obj *value");

    Printv(set->code, tab4, "value = Tcl_GetVar2(interp, name1, name2, flags);\n",
	   tab4, "if (!value) return NULL;\n", 0);

    if (!t->is_pointer) {
      switch(t->type) {
      case T_INT:
      case T_SINT:
      case T_SHORT:
      case T_USHORT:
      case T_SSHORT:
      case T_LONG:
      case T_SLONG:
      case T_UCHAR:
      case T_SCHAR:
      case T_BOOL:
	Printv(set->code, tab4, "*(addr) = (", DataType_str(t,0), ") atol(value);\n", 0);
	break;
      case T_UINT:
      case T_ULONG:
	Printv(set->code, tab4, "*(addr) = (", DataType_str(t,0), ") strtoul(value,0,0);\n",0);
	break;
      case T_FLOAT:
      case T_DOUBLE:
	Printv(set->code, tab4, "*(addr) = (", DataType_str(t,0), ") atof(value);\n",0);
	break;
      case T_CHAR:  /* Single character. */
	Printv(set->code, tab4, "*(addr) = *value;\n",0);
	break;
      case T_USER:
	// User defined type.  We return it as a pointer
	t->is_pointer++;
	DataType_remember(t);
	Printv(set->code, tab4, "{\n",
	       tab8, "void *ptr;\n",
	       tab8, "if (SWIG_ConvertPtrFromString(interp,value,&ptr,SWIGTYPE", DataType_manglestr(t), ") != TCL_OK) {\n",
	       tab8, tab4, "return \"Type Error\";\n",
	       tab8, "}\n",
	       tab8, "*(addr) = *((", DataType_lstr(t,0), ") ptr);\n",
	       tab4, "}\n",
	       0);

	t->is_pointer--;
	break;
      default:
	Printf(stderr,"Unknown type %d!\n", t->type);
	break;
      }
    } else {
      if ((t->is_pointer == 1) && (t->type == T_CHAR)) {
	Printv(set->code, tab4, "if (*addr) free(*addr);\n",
	       tab4, "*addr = (char *) malloc(strlen(value)+1);\n",
	       tab4, "strcpy(*addr,value);\n",
	       0);
      } else {
	// User defined type.  We return it as a pointer
	DataType_remember(t);
	Printv(set->code, tab4, "{\n",
	       tab8, "void *ptr;\n",
	       tab8, "if (SWIG_ConvertPtrFromString(interp,value,&ptr,SWIGTYPE", DataType_manglestr(t), ") != TCL_OK) {\n",
	       tab8, tab4, "return \"Type Error\";\n",
	       tab8, "}\n",
	       tab8, "*(addr) = (", DataType_lstr(t,0), ") ptr;\n",
	       tab4, "}\n",
	       0);

	/* A Pointer */
      }
    }
    Printv(set->code, tab4, "return NULL;\n", "}\n",0);

    if (!t->is_pointer) {
      switch(t->type) {
      case T_INT:
      case T_SINT:
      case T_UINT:
      case T_SHORT:
      case T_USHORT:
      case T_SSHORT:
      case T_LONG:
      case T_ULONG:
      case T_SLONG:
      case T_UCHAR:
      case T_SCHAR:
      case T_BOOL:
	Wrapper_add_local(get,"value","Tcl_Obj *value");
	Printv(get->code,
	       tab4, "value = Tcl_NewIntObj((int) *addr);\n",
	       tab4, "Tcl_SetVar2(interp,name1,name2,Tcl_GetStringFromObj(value,NULL), flags);\n",
	       tab4, "Tcl_DecrRefCount(value);\n",
	       0);
	break;
      case T_FLOAT:
      case T_DOUBLE:
	Wrapper_add_local(get,"value","Tcl_Obj *value");
	Printv(get->code,
	       tab4, "value = Tcl_NewDoubleObj((double) *addr);\n",
	       tab4, "Tcl_SetVar2(interp,name1,name2,Tcl_GetStringFromObj(value,NULL), flags);\n",
	       tab4, "Tcl_DecrRefCount(value);\n",
	       0);
	break;

      case T_CHAR:
	Wrapper_add_local(get,"temp", "char temp[2]");
	Printv(get->code,tab4, "temp[0] = *addr; temp[1] = 0;\n",
	       tab4, "Tcl_SetVar2(interp,name1,name2,temp,flags);\n",
	       0);
	break;

      case T_USER:
	Wrapper_add_local(get,"value", "Tcl_Obj *value");
	t->is_pointer++;
	DataType_remember(t);
	Printv(get->code, tab4, "value = SWIG_NewPointerObj(addr, SWIGTYPE", DataType_manglestr(t), ");\n",
	       tab4, "Tcl_SetVar2(interp,name1,name2,Tcl_GetStringFromObj(value,NULL), flags);\n",
	       tab4, "Tcl_DecrRefCount(value);\n",0);
	t->is_pointer--;
	break;

      default:
	break;
      }
    } else {
      if ((t->is_pointer == 1) && (t->type == T_CHAR)) {
	Printv(get->code, tab4, "Tcl_SetVar2(interp,name1,name2,*addr, flags);\n",0);
      } else {
	Wrapper_add_local(get,"value","Tcl_Obj *value");
	DataType_remember(t);
	Printv(get->code,
	       tab4, "value = SWIG_NewPointerObj(*addr, SWIGTYPE", DataType_manglestr(t), ");\n",
	       tab4, "Tcl_SetVar2(interp,name1,name2,Tcl_GetStringFromObj(value,NULL), flags);\n",
	       tab4, "Tcl_DecrRefCount(value);\n",
	       0);
      }
    }

    Printv(get->code, tab4, "return NULL;\n", "}\n",0);
    Wrapper_print(get,f_wrappers);
    Wrapper_print(set,f_wrappers);
    DelWrapper(get);
    DelWrapper(set);
  }
  Printv(var_info, tab4,"{ SWIG_prefix \"", iname, "\", (void *) &", name, ", _swig_", DataType_manglestr(t), "_get,", 0);
  
  if (Status & STAT_READONLY) {
    static int readonly = 0;
    if (!readonly) {
      Wrapper *ro = NewWrapper();
      Printf(ro->def, "static char *_swig_readonly(ClientData clientData, Tcl_Interp *interp, char *name1, char *name2, int flags) {");
      Printv(ro->code, tab4, "return \"Variable is read-only\";\n", "}\n", 0);
      Wrapper_print(ro,f_wrappers);
      readonly = 1;
      DelWrapper(ro);
    }
    Printf(var_info, "_swig_readonly},\n");
  } else {
    Printv(var_info, "_swig_", DataType_manglestr(t), "_set},\n",0);
  }
}

// -----------------------------------------------------------------------
// TCL8::declare_const(char *name, char *iname, DataType *type, char *value)
//
// Makes a constant.  Really just creates a variable and links to it.
// Tcl variable linkage allows read-only variables so we'll use that
// instead of just creating a Tcl variable.
// ------------------------------------------------------------------------

void TCL8::declare_const(char *name, char *, DataType *type, char *value) {

  int OldStatus = Status;      // Save old status flags
  DataType *t; 
  char   var_name[256];
  char     *tm;
  DOHString *rvalue;
  Status = STAT_READONLY;      // Enable readonly mode.

  // Make a static variable;

  sprintf(var_name,"_wrap_const_%s",name);
  
  // See if there's a typemap
  if ((type->type == T_CHAR) && (type->is_pointer == 1)) {
    rvalue = NewStringf("\"%s\"",value);
  } else if ((type->type == T_CHAR) && (type->is_pointer == 0)) {
    rvalue = NewStringf("\'%s\'",value);
  } else {
    rvalue = NewString(value);
  }
  if ((tm = typemap_lookup((char*)"const",(char*)"tcl8",type,name,Char(rvalue),name))) {
    // Yep.  Use it instead of the default
    Printf(f_init,"%s\n",tm);
  } else {

    // Create variable and assign it a value
    
    if (type->is_pointer == 0) {
      switch(type->type) {
      case T_BOOL: case T_INT: case T_SINT: case T_DOUBLE:
	Printf(f_header,"static %s %s = %s;\n", DataType_str(type,0), var_name, value);
	link_variable(var_name,name,type);
	break;
      case T_SHORT:
      case T_LONG:
      case T_SSHORT:
      case T_SCHAR:
      case T_SLONG:
	Printf(f_header,"static %s %s = %s;\n", DataType_str(type,0), var_name, value);
	Printf(f_header,"static char *%s_char;\n", var_name);
	if (CPlusPlus)
	  Printf(f_init,"\t %s_char = new char[32];\n",var_name);
	else
	  Printf(f_init,"\t %s_char = (char *) malloc(32);\n",var_name);
	
	Printf(f_init,"\t sprintf(%s_char,\"%%ld\", (long) %s);\n", var_name, var_name);
	sprintf(var_name,"%s_char",var_name);
	t = NewDataType(T_CHAR);
	t->is_pointer = 1;
	link_variable(var_name,name,t);
	DelDataType(t);
	break;
      case T_UINT:
      case T_USHORT:
      case T_ULONG:
      case T_UCHAR:
	Printf(f_header,"static %s %s = %s;\n", DataType_str(type,0), var_name, value);
	Printf(f_header,"static char *%s_char;\n", var_name);
	if (CPlusPlus)
	  Printf(f_init,"\t %s_char = new char[32];\n",var_name);
	else
	  Printf(f_init,"\t %s_char = (char *) malloc(32);\n",var_name);
	
	Printf(f_init,"\t sprintf(%s_char,\"%%lu\", (unsigned long) %s);\n", var_name, var_name);
	sprintf(var_name,"%s_char",var_name);
	t = NewDataType(T_CHAR);
	t->is_pointer = 1;
	link_variable(var_name,name,t);
	DelDataType(t);
	break;
      case T_FLOAT:
	type->type = T_DOUBLE;
	strcpy(type->name,"double");
	Printf(f_header,"static %s %s = (%s) (%s);\n", DataType_lstr(type,0), var_name, DataType_lstr(type,0), value);
	link_variable(var_name,name,type);
	break;
	
      case T_CHAR:
	type->is_pointer++;
	Printf(f_header,"static %s %s = \"%s\";\n", DataType_lstr(type,0), var_name, value);
	link_variable(var_name,name,type);
	type->is_pointer--;
	break;
      default:
	Printf(stderr,"%s : Line %d. Unsupported constant value.\n", input_file, line_number);
	break;
      }
    } else {
      // Have some sort of pointer value here
      if ((type->type == T_CHAR) && (type->is_pointer == 1)) {
	// Character string
	Printf(f_header,"static %s %s = \"%s\";\n", DataType_lstr(type,0), var_name, value);
	link_variable(var_name,name,type);
      } else {
	// Something else.   Some sort of pointer value
	Printf(f_header,"static %s %s = %s;\n", DataType_lstr(type,0), var_name, value);
	Printf(f_header,"static char *%s_char;\n", var_name);
	if (CPlusPlus)
	  Printf(f_init,"\t %s_char = new char[%d];\n",var_name,(int) strlen(DataType_manglestr(type))+ 20);
	else
	  Printf(f_init,"\t %s_char = (char *) malloc(%d);\n",var_name, (int) strlen(DataType_manglestr(type))+ 20);
	
	t = NewDataType(T_CHAR);
        t->is_pointer = 1;
        DataType_remember(type);
	Printf(f_init,"\t SWIG_MakePtr(%s_char, (void *) %s, SWIGTYPE%s);\n",
		var_name, var_name, DataType_manglestr(type));
	sprintf(var_name,"%s_char",var_name);
	link_variable(var_name,name,t);
	DelDataType(t);
      }
    }
  }
  Delete(rvalue);
  Status = OldStatus;
}

// ----------------------------------------------------------------------
// TCL8::usage_var(char *iname, DataType *t, char **s)
//
// Produces a usage string for a tcl variable.  Stores it in s
// ----------------------------------------------------------------------

char *TCL8::usage_var(char *iname, DataType *t) {

  static char temp[2048];

  if (!nspace) {
    sprintf(temp,"$%s%s", prefix, iname);
  } else { 
    sprintf(temp,"%s::%s", ns_name, iname);
  }
  if (!(((t->type == T_INT) && (!t->is_pointer)) ||
	((t->type == T_UINT) && (!t->is_pointer)) ||
	((t->type == T_DOUBLE) && (!t->is_pointer)) ||
	((t->type == T_BOOL) && (!t->is_pointer)) ||
	((t->type == T_CHAR) && (t->is_pointer)))) {
    /* We emitted a pair of set/get functions instead.  Doc will be generated for that */
    return temp;
  }
  return temp;
}



// ---------------------------------------------------------------------------
// char *TCL8::usage_string(char *iname, DataType *t, ParmList *l),
// 
// Generates a generic usage string for a Tcl function.
// ---------------------------------------------------------------------------

char * TCL8::usage_string(char *iname, DataType *, ParmList *l) {

  static DOHString *temp = 0;
  Parm  *p;
  int   i, numopt,pcount;

  if (!temp) temp = NewString("");
  Clear(temp);
  Printf(temp,"%s ",iname);
  
  /* Now go through and print parameters */
  i = 0;
  pcount = l->nparms;
  numopt = check_numopt(l);
  p = ParmList_first(l);
  while (p != 0) {

    DataType *pt = Parm_Gettype(p);
    char     *pn = Parm_Getname(p);

    // Only print an argument if not ignored

    if (!typemap_check((char*)"ignore",(char*)"tcl8",pt,pn)) {
      if (i >= (pcount-numopt))
	Putc('?',temp);

      /* If parameter has been named, use that.   Otherwise, just print a type  */

      if ((pt->type != T_VOID) || (pt->is_pointer)) {
	if (strlen(pn) > 0) {
	  Printf(temp,pn);
	}
	else {
	  Printf(temp,"{ %s }", DataType_str(pt,0));
	}
      }
      if (i >= (pcount-numopt))
	Putc('?',temp);
      Putc(' ',temp);
      i++;
    }
    p = ParmList_next(l);
  }
  return Char(temp);
}

// ---------------------------------------------------------------------------
// char *TCL8::usage_func(char *iname, DataType *t, ParmList *l),
// 
// Produces a usage string for a function in Tcl
// ---------------------------------------------------------------------------

char * TCL8::usage_func(char *iname, DataType *t, ParmList *l) {
  char temp[1024];

  if (nspace) {
    sprintf(temp,"%s::%s",ns_name,iname);
  } else {
    sprintf(temp,"%s%s",prefix,iname);
  }
  return usage_string(temp,t,l);
}

// -----------------------------------------------------------------
// TCL8::usage_const(char *name, DataType *type, char *value)
//                         char **s)
//
// Makes a usage string and returns it
// -----------------------------------------------------------------

char *TCL8::usage_const(char *name, DataType *, char *value) {
  static char temp[1024];
  if (nspace) {
    sprintf(temp,"%s::%s = %s", ns_name,name,value);
  } else {
    sprintf(temp,"$%s%s = %s", prefix,name,value);
  }
  return temp;
}
    
// -------------------------------------------------------------------
// TCL8::add_native(char *name, char *funcname, DataType *t, ParmList *l)
//
// This adds an already written Tcl wrapper function to our
// initialization function.
// -------------------------------------------------------------------


void TCL8::add_native(char *name, char *funcname, DataType *, ParmList *) {

  Printf(f_init,"\t Tcl_CreateObjCommand(%s, SWIG_prefix \"%s\", %s, (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL);\n",interp_name, name, funcname);
    
}
 
// -------------------------------------------------------------------
// TCL8::pragma(char *lname, char *name, char *value)
//
// Handle pragmas.
// --------------------------------------------------------------------

void TCL8::pragma(char *, char *, char *) {

}

// ---------------------------------------------------------------------
// C++ Handling
//
// The following functions provide some support for C++ classes and
// C structs.   
// ---------------------------------------------------------------------

void TCL8::cpp_open_class(char *classname, char *rename, char *ctype, int strip) {

  this->Language::cpp_open_class(classname,rename,ctype,strip);

  if (shadow) {
    static int included_object = 0;
    if (!included_object) {
      if (Swig_insert_file("object.swg",f_header) == -1) {
	Printf(stderr,"SWIG : Fatal error. Unable to locate 'object.swg' in SWIG library.\n");
	SWIG_exit(1);
      }
      included_object = 1;
    }
  
    Clear(attributes);
    Printf(attributes, "static _swig_attribute _swig_");
    Printv(attributes, classname, "_attributes[] = {\n", 0);

    Clear(methods);
    Printf(methods,"static _swig_method _swig_");
    Printv(methods, classname, "_methods[] = {\n", 0);

    have_constructor = 0;
    have_destructor = 0;

    if (rename)
      class_name = Swig_copy_string(rename);
    else
      class_name = Swig_copy_string(classname);
  
    base_class = (char *) 0;
    if (!strip) {
      class_type = new char[strlen(ctype)+2];
      sprintf(class_type,"%s ", ctype);
    } else
      class_type = (char*)"";

    real_classname = Swig_copy_string(classname);
  }
}

void TCL8::cpp_close_class() {
  DOHString *code;
  DataType *t;
  
  code = NewString("");

  this->Language::cpp_close_class();
  if (shadow) {

    t = NewDataType(0);
    sprintf(t->name,"%s%s", class_type, real_classname);
    t->type = T_USER;
    t->is_pointer = 1;

    if (have_destructor) {
      Printv(code, "static void _swig_delete_", class_name, "(void *obj) {\n",
	     tab4, Swig_name_destroy(real_classname), "((", DataType_str(t,0), ") obj);\n",
	     "}\n",0);
    }

    Printf(methods, "    {0,0}\n};\n");
    Printv(code,methods,0);

    Printf(attributes, "    {0,0,0}\n};\n");
    Printv(code,attributes,0);

    Printv(code, "static _swig_class _wrap_class_", class_name, " = { \"", class_name, 
	   "\", &SWIGTYPE", DataType_manglestr(t), ",",0);

    if (have_constructor) {
      Printf(code, Swig_name_wrapper(Swig_name_construct(class_name)));
    } else {
      Printf(code,"0");
    }
    if (have_destructor) {
      Printv(code, ", _swig_delete_", class_name,0);
    } else {
      Printf(code,",0");
    }
    Printv(code, ", _swig_", real_classname, "_methods, _swig_", real_classname, "_attributes };\n", 0);
    Printf(f_wrappers,"%s",code);

    Printv(cmd_info, tab4, "{ SWIG_prefix \"", class_name, "\", SwigObjectCmd, &_wrap_class_", class_name, "},\n", 0);
  }
  Delete(code);

}

void TCL8::cpp_member_func(char *name, char *iname, DataType *t, ParmList *l) {

  char *realname;
  char temp[1024];
  char  *rname;

  this->Language::cpp_member_func(name,iname,t,l);

  if (shadow) {
    if (iname) 
      realname = iname;
    else
      realname = name;
    
    // Add stubs for this member to our class handler function

    strcpy(temp, Swig_name_member(class_name,realname));
    rname = GetChar(repeatcmd,temp);
    if (!rname)
      rname = Swig_name_wrapper(temp);
    
    Printv(methods, tab4, "{\"", realname, "\", ", rname, "}, \n", 0);
  }
}

void TCL8::cpp_variable(char *name, char *iname, DataType *t) {
  char *realname;
  char temp[1024];
  char *rname;

  this->Language::cpp_variable(name, iname, t);

  if (shadow) {
    if (iname)
      realname = iname;
    else
      realname = name;
    
    char *bc = class_name;

    Printv(attributes, tab4, "{ \"-", realname, "\",", 0);

    // Try to figure out if there is a wrapper for this function
    strcpy(temp, Swig_name_get(Swig_name_member(bc,realname)));
    rname = GetChar(repeatcmd,temp);
    if (!rname) 
      rname = Swig_name_wrapper(temp);
    Printv(attributes, rname, ", ", 0);

    if (!(Status & STAT_READONLY)) {
      strcpy(temp, Swig_name_set(Swig_name_member(bc,realname)));
      rname = GetChar(repeatcmd,temp);
      if (!rname) 
	rname = Swig_name_wrapper(temp);
      Printv(attributes, rname, "},\n",0);
    } else {
      Printf(attributes, "0 },\n");
    }
  }
}

void TCL8::cpp_constructor(char *name, char *iname, ParmList *l) {
  this->Language::cpp_constructor(name,iname,l);

  if (shadow) {
    have_constructor = 1;
  }
}
void TCL8::cpp_destructor(char *name, char *newname) {
  this->Language::cpp_destructor(name,newname);
  if (shadow) {
    have_destructor = 1;
  }
}

void TCL8::cpp_inherit(char **baseclass, int) {
  this->Language::cpp_inherit(baseclass);
}

void TCL8::cpp_declare_const(char *name, char *iname, DataType *type, char *value) {
  this->Language::cpp_declare_const(name,iname,type,value);
}

// --------------------------------------------------------------------------------
// TCL8::add_typedef(DataType *t, char *name)
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

void TCL8::add_typedef(DataType *t, char *name) {

  if (!shadow) return;

  // First check to see if there aren't too many pointers

  if (t->is_pointer > 1) return;
  if (Getattr(hash,name)) return;      // Already added

  // Now look up the datatype in our shadow class hash table

  if (Getattr(hash,t->name)) {

    // Yep.   This datatype is in the hash
    // Put this types 'new' name into the hash
    Setattr(hash,name,GetChar(hash,t->name));
  }
}

// -----------------------------------------------------------------------
// TCL8::cpp_class_decl(char *name, char *rename, char *type)
//
// Treatment of an empty class definition.    Used to handle
// shadow classes across modules.
// -----------------------------------------------------------------------

void TCL8::cpp_class_decl(char *name, char *rename, char *type) {
  char temp[256];
  this->Language::cpp_class_decl(name,rename, type);

  if (shadow) {
    Setattr(hash,name,rename);
    // Add full name of datatype to the hash table
    if (strlen(type) > 0) {
      sprintf(temp,"%s %s", type, name);
      Setattr(hash,temp,rename);
    }
  }
}









/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * lua.cxx
 *
 * Lua language module for SWIG.
 * ----------------------------------------------------------------------------- */

/* NEW LANGUAGE NOTE:
 * ver001
   this is simply a copy of tcl8.cxx, which has been renamed
 * ver002
   all non essential code commented out, program now does virtually nothing
   it prints to stderr the list of functions to wrap, but does not create
   the XXX_wrap.c file
 * ver003
   added back top(), still prints the list of fns to stderr
   but now creates a rather empty XXX_wrap.c with some basic boilerplate code
 * ver004
   very basic version of functionWrapper()
   also uncommented usage_string() to keep compiler happy
   this will start producing proper looking code soon (I hope)
   produced the wrapper code, but without any type conversion (in or out)
   generates a few warning because of no wrappering
   does not generate SWIG_init()
   reason for this is that lua.swg is empty
   we will need to add code into this to make it work
 * ver005/6
   massive rework, basing work on the pike module instead of tcl
   (pike module it only 1/3 of the size)(though not as complete)
 * ver007
   added simple type checking
 * ver008
   INPUT, OUTPUT, INOUT typemaps handled (though not all types yet)
 * ver009
   class support: ok for basic types, but methods still TDB
   (code is VERY messed up & needs to be cleaned)


*/

char cvsroot_lua_cxx[] = "$Id$";

#include "swigmod.h"

/**** Diagnostics:
  With the #define REPORT(), you can change the amount of diagnostics given
  This helps me search the parse tree & figure out what is going on inside SWIG
  (because its not clear or documented)
*/
#define REPORT(T,D)		// no info:
//#define REPORT(T,D)   {Printf(stdout,T"\n");} // only title
//#define REPORT(T,D)   {Printf(stdout,T"\n");display_mapping(D);}      // the works
//#define REPORT(T,D)   {Printf(stdout,T"\n");if(D)Swig_print_node(D);}      // the works

void display_mapping(DOH *d) {
  if (d == 0 || !DohIsMapping(d))
    return;
  for (DohIterator it = DohFirst(d); it.item; it = DohNext(it)) {
    if (DohIsString(it.item))
      Printf(stdout, "  %s = %s\n", it.key, it.item);
    else if (DohIsMapping(it.item))
      Printf(stdout, "  %s = <mapping>\n", it.key);
    else if (DohIsSequence(it.item))
      Printf(stdout, "  %s = <sequence>\n", it.key);
    else
      Printf(stdout, "  %s = <unknown>\n", it.key);
  }
}



/* NEW LANGUAGE NOTE:***********************************************
 most of the default options are handled by SWIG
 you can add new ones here
 (though for now I have not bothered)
NEW LANGUAGE NOTE:END ************************************************/
static const char *usage = (char *) "\
Lua Options (available with -lua)\n\
     (coming soon.)\n\n";



/* NEW LANGUAGE NOTE:***********************************************
 To add a new language, you need to derive your class from
 Language and the overload various virtual functions
 (more on this as I figure it out)
NEW LANGUAGE NOTE:END ************************************************/

class LUA:public Language {
private:

  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  File *f_initbeforefunc;
  String *PrefixPlusUnderscore;
  String *s_cmd_tab;		// table of command names
  String *s_var_tab;		// table of global variables
  String *s_const_tab;		// table of global constants
  String *s_methods_tab;	// table of class methods
  String *s_attr_tab;		// table of class atributes

  int have_constructor;
  int have_destructor;
  String *destructor_action;
  String *class_name;
  String *constructor_name;

  enum {
    NO_CPP,
    VARIABLE,	  
    MEMBER_FUNC,
    CONSTRUCTOR,
    DESTRUCTOR,
    MEMBER_VAR,
    CLASS_CONST,
    STATIC_FUNC,
    STATIC_VAR
  }current;

public:

  /* ---------------------------------------------------------------------
   * LUA()
   *
   * Initialize member data
   * --------------------------------------------------------------------- */

   LUA() {
    f_runtime = 0;
    f_header = 0;
    f_wrappers = 0;
    f_init = 0;
    f_initbeforefunc = 0;
    PrefixPlusUnderscore = 0;

    s_cmd_tab = s_var_tab = s_const_tab = 0;
    current=NO_CPP;   
  }

  /* NEW LANGUAGE NOTE:***********************************************
     This is called to initalise the system & read any command line args
     most of this is boilerplate code, except the command line args
     which depends upon what args your code supports
     NEW LANGUAGE NOTE:END ************************************************/

   /* ---------------------------------------------------------------------
   * main()
   *
   * Parse command line options and initializes variables.
   * --------------------------------------------------------------------- */
  
   virtual void main(int argc, char *argv[]) {

    /* Set location of SWIG library */
    SWIG_library_directory("lua");

    /* Look for certain command line options */
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp(argv[i], "-help") == 0) {	// usage flags
	  fputs(usage, stderr);
	}
      }
    }

/* NEW LANGUAGE NOTE:***********************************************
 This is the boilerplate code, setting a few #defines
 and which lib directory to use
 the SWIG_library_directory() is also boilerplate code
 but it always seems to be the first line of code
NEW LANGUAGE NOTE:END ************************************************/
    /* Add a symbol to the parser for conditional compilation */
    Preprocessor_define("SWIGLUA 1", 0);

    /* Set language-specific configuration file */
    SWIG_config_file("lua.swg");

    /* Set typemap language */
    SWIG_typemap_lang("lua");

    /* Enable overloaded methods support */
    allow_overloading();
  }




/* NEW LANGUAGE NOTE:***********************************************
 After calling main, SWIG parses the code to wrap (I believe)
 then calls top()
 in this is more boilerplate code to set everything up
 and a call to Language::top()
 which begins the code generations by calling the member fns
 after all that is more boilerplate code to close all down
 (overall there is virtually nothing here that needs to be edited
 just use as is)
NEW LANGUAGE NOTE:END ************************************************/
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
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_initbeforefunc = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);
    Swig_register_filebyname("initbeforefunc", f_initbeforefunc);

/* NEW LANGUAGE NOTE:***********************************************
 s_cmd_tab,s_var_tab & s_const_tab hold the names of the fns for
 registering with SWIG.
 These will be filled in when the functions/variables are wrapped &
 then added to the end of the wrappering code
 just before it is written to file
NEW LANGUAGE NOTE:END ************************************************/
    // Initialize some variables for the object interface
    s_cmd_tab = NewString("");
    s_var_tab = NewString("");
//    s_methods_tab    = NewString("");
    s_const_tab = NewString("");
    current=NO_CPP;   

    /* Standard stuff for the SWIG runtime section */
    Swig_banner(f_runtime);
//    if (NoInclude) {
//      Printf(f_runtime, "#define SWIG_NOINCLUDE\n");
//    }

    //String *init_name = NewStringf("%(title)s_Init", module);
    //Printf(f_header, "#define SWIG_init    %s\n", init_name);
    //Printf(f_header, "#define SWIG_name    \"%s\"\n", module);
    /* SWIG_import is a special function name for importing within Lua5.1 */
    //Printf(f_header, "#define SWIG_import  luaopen_%s\n\n", module);
    Printf(f_header, "#define SWIG_name      \"%s\"\n", module);
    Printf(f_header, "#define SWIG_init      luaopen_%s\n", module);
    Printf(f_header, "#define SWIG_init_user luaopen_%s_user\n\n", module);

    Printf(s_cmd_tab, "\nstatic const struct luaL_reg swig_commands[] = {\n");
    Printf(s_var_tab, "\nstatic swig_lua_var_info swig_variables[] = {\n");
    Printf(s_const_tab, "\nstatic swig_lua_const_info swig_constants[] = {\n");
    Printf(f_wrappers, "#ifdef __cplusplus\nextern \"C\" {\n#endif\n");

    /* %init code inclusion, effectively in the SWIG_init function */
    Printf(f_init, "void SWIG_init_user(lua_State* L)\n{\n");
    Language::top(n);
    Printf(f_init, "}\n");

    Printf(f_wrappers, "#ifdef __cplusplus\n}\n#endif\n");

    // Done.  Close up the module & write to the wrappers
    Printv(s_cmd_tab, tab4, "{0,0}\n", "};\n", NIL);
    Printv(s_var_tab, tab4, "{0,0,0}\n", "};\n", NIL);
    Printv(s_const_tab, tab4, "{0,0,0,0,0,0}\n", "};\n", NIL);
    Printv(f_wrappers, s_cmd_tab, s_var_tab, s_const_tab, NIL);
    SwigType_emit_type_table(f_runtime, f_wrappers);

/* NEW LANGUAGE NOTE:***********************************************
 this basically combines several of the strings together
 and then writes it all to a file
NEW LANGUAGE NOTE:END ************************************************/
    /* Close all of the files */
    Delete(s_cmd_tab);
    Delete(s_var_tab);
    Delete(s_const_tab);
    Dump(f_header, f_runtime);
    Dump(f_wrappers, f_runtime);
    Dump(f_initbeforefunc, f_runtime);
    Wrapper_pretty_print(f_init, f_runtime);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Delete(f_initbeforefunc);
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

/* NEW LANGUAGE NOTE:***********************************************
 This is it!
 you get this one right, and most of your work is done
 but its going to take soem file to get it working right
 quite a bit of this is generally boilerplate code
 (or stuff I dont understand)
 that which matters will have extra added comments
NEW LANGUAGE NOTE:END ************************************************/
  /* ---------------------------------------------------------------------
   * functionWrapper()
   *
   * Create a function declaration and register it with the interpreter.
   * --------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
//    REPORT("functionWrapper",n);

    String *name = Getattr(n, "name");
    String *iname = Getattr(n, "sym:name");
    SwigType *d = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
//Printf(stdout,"functionWrapper %s %s\n",name,iname);
    Parm *p;
    String *tm;
    int i;
//Printf(stdout,"functionWrapper %s %s %d\n",name,iname,current);
//    int returnval=0;  // number of arguments returned

    String *overname = 0;
    if (Getattr(n, "sym:overloaded")) {
      overname = Getattr(n, "sym:overname");
    } else {
      if (!addSymbol(iname, n))
      {
	Printf(stderr,"addSymbol(%s) failed\n",iname);
	return SWIG_ERROR;
      }
    }

/* NEW LANGUAGE NOTE:***********************************************
   the wrapper object holds all the wrappering code
    we need to add a couple of local variables
NEW LANGUAGE NOTE:END ************************************************/
    Wrapper *f = NewWrapper();
    Wrapper_add_local(f, "SWIG_arg", "int SWIG_arg = -1");


    String *wname = Swig_name_wrapper(iname);
    if (overname) {
      Append(wname, overname);
    }

/* NEW LANGUAGE NOTE:***********************************************
   the format of a lua fn is:
     static int wrap_XXX(lua_State* L){...}
   this line adds this into the wrappering code
NEW LANGUAGE NOTE:END ************************************************/
    Printv(f->def, "static int ", wname, "(lua_State* L) {", NIL);

/* NEW LANGUAGE NOTE:***********************************************
   this prints the list of args, eg for a C fn
   int gcd(int x,int y);
   it will print
     int arg1;
     int arg2;
     int result;
NEW LANGUAGE NOTE:END ************************************************/
    /* Write code to extract function parameters. */
    emit_args(d, l, f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l, f);
    Setattr(n, "wrap:parms", l);

    /* Get number of required and total arguments */
    int num_arguments = emit_num_arguments(l);
    int num_required = emit_num_required(l);
    int varargs = emit_isvarargs(l);

    /* Which input argument to start with? */
//    int start = (current == MEMBER_FUNC || current == MEMBER_VAR || current == DESTRUCTOR) ? 1 : 0;

    /* Offset to skip over the attribute name */
    // int offset = (current == MEMBER_VAR) ? 1 : 0;

/* NEW LANGUAGE NOTE:***********************************************
   from here on in, it gets rather hairy
   this is the code to convert from the scripting language to C/C++
   some of the stuff will refer to the typemaps code written in your swig file
   (lua.swg), and some is done in the code here
   I suppose you could do all the conversion on C, but it would be a nightmare to do
NEW LANGUAGE NOTE:END ************************************************/
    /* Generate code for argument marshalling */
//    String *description = NewString("");
/* NEW LANGUAGE NOTE:***********************************************
   argument_check is a new feature I added to check types of arguments:
   eg for int gcd(int,int)
   I want to check that arg1 & arg2 really are integers
NEW LANGUAGE NOTE:END ************************************************/
    String *argument_check = NewString("");
    String *argument_parse = NewString("");
    String *checkfn = NULL;
//    String *numoutputs=NULL;
    char source[64];
    //Printf(argument_check, "//args must be %d..%d\n",num_required,num_arguments);
    Printf(argument_check, "SWIG_check_num_args(\"%s\",%d,%d)\n",name,num_required,num_arguments);
    for (i = 0, p = l; i < num_arguments; i++) {

      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");
      String *ln = Getattr(p, "lname");

      /* Look for an input typemap */
      sprintf(source, "%d", i + 1);
      if ((tm = Getattr(p, "tmap:in"))) {
	Replaceall(tm, "$source", source);
	Replaceall(tm, "$target", ln);
	Replaceall(tm, "$input", source);
	Setattr(p, "emit:input", source);

/* NEW LANGUAGE NOTE:***********************************************
   look for a 'checkfn' typemap
   this an additional parameter added to the in typemap
   if found the type will be tested for
   this will result in code either in the
   argument_check or argument_parse string
NEW LANGUAGE NOTE:END ************************************************/
	if ((checkfn = Getattr(p, "tmap:in:checkfn"))) {
	  if (i < num_required) {
	    Printf(argument_check, "if(!%s(L,%s))", checkfn, source);
	  } else {
	    Printf(argument_check, "if(lua_gettop(L)>=%s && !%s(L,%s))", source, checkfn, source);
	  }
	  Printf(argument_check, " SWIG_fail_arg(\"%s\",%s,\"%s\");\n", name, source, SwigType_str(pt, 0));
	}
/* NEW LANGUAGE NOTE:***********************************************
   lua states the number of arguments passed to a function using the fn
   lua_gettop()
   we can use this to deal with default arguments
NEW LANGUAGE NOTE:END ************************************************/
	if (i < num_required) {
	  Printf(argument_parse, "%s\n", tm);
	} else {
	  Printf(argument_parse, "if(lua_gettop(L)>=%s){%s}\n", source, tm);
	}
	p = Getattr(p, "tmap:in:next");
	continue;
      } else {
/* NEW LANGUAGE NOTE:***********************************************
		   // why is this code not called when I dont have a typemap?
		   // instead of giving a warning, no code is generated
NEW LANGUAGE NOTE:END ************************************************/
	Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
	break;
      }

      p = nextSibling(p);
    }

    // add all argcheck code
    Printv(f->code, argument_check, argument_parse, NIL);

    /* Check for trailing varargs */
    if (varargs) {
      if (p && (tm = Getattr(p, "tmap:in"))) {
	Replaceall(tm, "$input", "varargs");
	Printv(f->code, tm, "\n", NIL);
      }
    }

    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:check"))) {
	Replaceall(tm, "$target", Getattr(p, "lname"));
	Printv(f->code, tm, "\n", NIL);
	p = Getattr(p, "tmap:check:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Insert cleanup code */
    String *cleanup = NewString("");
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:freearg"))) {
	Replaceall(tm, "$source", Getattr(p, "lname"));
	Printv(cleanup, tm, "\n", NIL);
	p = Getattr(p, "tmap:freearg:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Insert argument output code */
    String *outarg = NewString("");
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:argout"))) {
//          // managing the number of returning variables
//        if (numoutputs=Getattr(p,"tmap:argout:numoutputs")){
//                      int i=GetInt(p,"tmap:argout:numoutputs");
//                      printf("got argout:numoutputs of %d\n",i);
//                      returnval+=GetInt(p,"tmap:argout:numoutputs");
//        }
//        else returnval++;
	Replaceall(tm, "$source", Getattr(p, "lname"));
	Replaceall(tm, "$target", "result");
	Replaceall(tm, "$arg", Getattr(p, "emit:input"));
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(outarg, tm, "\n", NIL);
	p = Getattr(p, "tmap:argout:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Emit the function call */
    emit_action(n, f);

/* NEW LANGUAGE NOTE:***********************************************
FIXME:
returns 1 if there is a void return type
this is because there is a typemap for void
NEW LANGUAGE NOTE:END ************************************************/
    Printv(f->code, "SWIG_arg=0;\n", NIL);
    // Return value if necessary
    if ((tm = Swig_typemap_lookup_new("out", n, "result", 0))) {
      // managing the number of returning variables
//      if (numoutputs=Getattr(tm,"numoutputs")){
//              int i=GetInt(tm,"numoutputs");
//              printf("return numoutputs %d\n",i);
//              returnval+=GetInt(tm,"numoutputs");
//      }
//        else returnval++;
      Replaceall(tm, "$source", "result");
      if (GetFlag(n, "feature:new")) {
	Replaceall(tm, "$owner", "1");
      } else {
	Replaceall(tm, "$owner", "0");
      }
      Printf(f->code, "%s\n", tm);
//      returnval++;
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(d, 0), name);
    }

    /* Output argument output code */
    Printv(f->code, outarg, NIL);

    /* Output cleanup code */
    Printv(f->code, cleanup, NIL);

    /* Look to see if there is any newfree cleanup code */
    if (GetFlag(n, "feature:new")) {
      if ((tm = Swig_typemap_lookup_new("newfree", n, "result", 0))) {
	Replaceall(tm, "$source", "result");
	Printf(f->code, "%s\n", tm);
      }
    }

    /* See if there is any return cleanup code */
    if ((tm = Swig_typemap_lookup_new("ret", n, "result", 0))) {
      Replaceall(tm, "$source", "result");
      Printf(f->code, "%s\n", tm);
    }


    /* Close the function */
    Printv(f->code, "return SWIG_arg;\n", NIL);
    // add the failure cleanup code:
    Printv(f->code, "\nif(0) SWIG_fail;\n", NIL);
    Printv(f->code, "\nfail:\n", NIL);
    Printv(f->code, "$cleanup", "lua_error(L);\n", NIL);
    Printv(f->code, "return SWIG_arg;\n", NIL);
    Printf(f->code, "}\n");

    /* Substitute the cleanup code */
    Replaceall(f->code, "$cleanup", cleanup);

    /* Substitute the function name */
    Replaceall(f->code, "$symname", iname);
    Replaceall(f->code, "$result", "result");

    /* Dump the function out */
    Wrapper_print(f, f_wrappers);

    Setattr(n, "wrap:name", wname);	// you need this to make the overloading work

/* NEW LANGUAGE NOTE:***********************************************
register the function in SWIG
different language mappings seem to use different ideas
NEW LANGUAGE NOTE:END ************************************************/
    /* Now register the function with the interpreter. */
    if (!Getattr(n, "sym:overloaded")) {
//      add_method(n, iname, wname, description);
      if (current==NO_CPP || current==STATIC_FUNC) // emit normal fns & static fns
        Printv(s_cmd_tab, tab4, "{ \"", iname, "\", ", Swig_name_wrapper(iname), "},\n", NIL);
//      Printv(s_cmd_tab, tab4, "{ SWIG_prefix \"", iname, "\", (swig_wrapper_func) ", Swig_name_wrapper(iname), "},\n", NIL);
    } else {
//      Setattr(n,"wrap:name", wname);
      if (!Getattr(n, "sym:nextSibling")) {
	dispatchFunction(n);
      }
    }

    Delete(argument_check);
    Delete(argument_parse);

    Delete(cleanup);
    Delete(outarg);
//    Delete(description);
    Delete(wname);
    DelWrapper(f);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * dispatchFunction()
   *
   * Emit overloading dispatch function
   * ------------------------------------------------------------ */

/* NEW LANGUAGE NOTE:***********************************************
This is an extra function used for overloading of functions
it checks the args & then calls the relevant fn
nost of the real work in again typemaps:
look for %typecheck(SWIG_TYPECHECK_*) in the .swg file
NEW LANGUAGE NOTE:END ************************************************/
  void dispatchFunction(Node *n) {
    /* Last node in overloaded chain */

    int maxargs;
    String *tmp = NewString("");
    String *dispatch = Swig_overload_dispatch(n, "return %s(L);", &maxargs);

    /* Generate a dispatch wrapper for all overloaded functions */

    Wrapper *f = NewWrapper();
    String *symname = Getattr(n, "sym:name");
    String *wname = Swig_name_wrapper(symname);

//Printf(stdout,"Swig_overload_dispatch %s %s '%s' %d\n",symname,wname,dispatch,maxargs);

    Printv(f->def, "static int ", wname, "(lua_State* L) {", NIL);
    Wrapper_add_local(f, "argc", "int argc");
    Printf(tmp, "int argv[%d]={1", maxargs + 1);
    for (int i = 1; i <= maxargs; i++) {
      Printf(tmp, ",%d", i + 1);
    }
    Printf(tmp, "}");
    Wrapper_add_local(f, "argv", tmp);
    Printf(f->code, "argc = lua_gettop(L);\n");

    Replaceall(dispatch, "$args", "self,args");
    Printv(f->code, dispatch, "\n", NIL);
    Printf(f->code, "lua_pushstring(L,\"No matching function for overloaded '%s'\");\n", symname);
    Printf(f->code, "lua_error(L);return 0;\n");
    Printv(f->code, "}\n", NIL);
    Wrapper_print(f, f_wrappers);
    //add_method(symname,wname,0);
    if (current==NO_CPP || current==STATIC_FUNC) // emit normal fns & static fns
      Printv(s_cmd_tab, tab4, "{ \"", symname, "\",", wname, "},\n", NIL);

    DelWrapper(f);
    Delete(dispatch);
    Delete(tmp);
    Delete(wname);
  }


  /* ------------------------------------------------------------
   * variableWrapper()
   * ------------------------------------------------------------ */

  virtual int variableWrapper(Node *n) {
/* NEW LANGUAGE NOTE:***********************************************
Language::variableWrapper(n) will generate two wrapper fns
Foo_get & Foo_set by calling functionWrapper()
so we will just add these into the variable lists
ideally we should not have registered these as functions,
only WRT this variable will look into this later.
NEW LANGUAGE NOTE:END ************************************************/
//    REPORT("variableWrapper", n);
    String *iname = Getattr(n, "sym:name");
    current=VARIABLE;
    // let SWIG generate the wrappers
    int result = Language::variableWrapper(n);
    current=NO_CPP;
    // normally SWIG will generate 2 wrappers, a get and a set
    // but in certain scenarios (immutable, or if its arrays), it will not
    String *getName = Swig_name_wrapper(Swig_name_get(iname));
    String *setName = 0;
    // checking whether it can be set to or not appears to be a very error prone issue
    // I refered to the Language::variableWrapper() to find this out
    bool assignable=is_assignable(n) ? true : false;
    SwigType *type = Getattr(n, "type");
    String *tm = Swig_typemap_lookup_new("globalin", n, iname, 0);
    if (!tm && SwigType_isarray(type))
      assignable=false;
    Delete(tm);
   
    if (assignable) {
      setName = Swig_name_wrapper(Swig_name_set(iname));
    } else {
      // how about calling a 'this is not settable' error message?
      setName = NewString("SWIG_Lua_set_immutable"); // error message
      //setName = NewString("0");
    }
    // register the variable
    Printf(s_var_tab, "%s{ \"%s\", %s, %s },\n", tab4, iname, getName, setName);
    Delete(getName);
    Delete(setName);
    return result;
  }

  /* ------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------ */
  virtual int constantWrapper(Node *n) {
//    REPORT("constantWrapper", n);
    String *name = Getattr(n, "name");
    String *iname = Getattr(n, "sym:name");
    //String *nsname    = !nspace ? Copy(iname) : NewStringf("%s::%s",ns_name,iname);
    String *nsname = Copy(iname);
    SwigType *type = Getattr(n, "type");
    String *rawval = Getattr(n, "rawval");
    String *value = rawval ? rawval : Getattr(n, "value");
    String *tm;

    if (!addSymbol(iname, n))
      return SWIG_ERROR;
    //if (nspace) Setattr(n,"sym:name",nsname);

    /* Special hook for member pointer */
    if (SwigType_type(type) == T_MPOINTER) {
      String *wname = Swig_name_wrapper(iname);
      Printf(f_wrappers, "static %s = %s;\n", SwigType_str(type, wname), value);
      value = Char(wname);
    }

    if ((tm = Swig_typemap_lookup_new("consttab", n, name, 0))) {
      Replaceall(tm, "$source", value);
      Replaceall(tm, "$target", name);
      Replaceall(tm, "$value", value);
      Replaceall(tm, "$nsname", nsname);
      Printf(s_const_tab, "%s,\n", tm);
    } else if ((tm = Swig_typemap_lookup_new("constcode", n, name, 0))) {
      Replaceall(tm, "$source", value);
      Replaceall(tm, "$target", name);
      Replaceall(tm, "$value", value);
      Replaceall(tm, "$nsname", nsname);
      Printf(f_init, "%s\n", tm);
    } else {
      Delete(nsname);
      Swig_warning(WARN_TYPEMAP_CONST_UNDEF, input_file, line_number, "Unsupported constant value.\n");
      return SWIG_NOWRAP;
    }
    Delete(nsname);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * nativeWrapper()
   * ------------------------------------------------------------ */

  virtual int nativeWrapper(Node *n) {
//    REPORT("nativeWrapper", n);
    String *symname = Getattr(n, "sym:name");
    String *wrapname = Getattr(n, "wrap:name");
    if (!addSymbol(wrapname, n))
      return SWIG_ERROR;

    Printv(s_cmd_tab, tab4, "{ \"", symname, "\",", wrapname, "},\n", NIL);
    //   return Language::nativeWrapper(n); // this does nothing...
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
    REPORT("classHandler", n);

    String *mangled_classname = 0;
    String *real_classname = 0;

    constructor_name = 0;
    have_constructor = 0;
    have_destructor = 0;
    destructor_action = 0;

    class_name = Getattr(n, "sym:name");
    if (!addSymbol(class_name, n))
      return SWIG_ERROR;

    real_classname = Getattr(n, "name");
    mangled_classname = Swig_name_mangle(real_classname);

    // not sure exactly how this workswhat this works,
    // but tcl has a static hashtable of all classes emitted and then only emits code for them once.
    // this fixes issues in test suites: template_default2 & template_specialization
    static Hash *emitted = NewHash();
    if (Getattr(emitted, mangled_classname))
      return SWIG_NOWRAP;
    Setattr(emitted, mangled_classname, "1");

    s_attr_tab = NewString("");
    Printf(s_attr_tab, "static swig_lua_attribute swig_");
    Printv(s_attr_tab, mangled_classname, "_attributes[] = {\n", NIL);

    s_methods_tab = NewString("");
    Printf(s_methods_tab, "static swig_lua_method swig_");
    Printv(s_methods_tab, mangled_classname, "_methods[] = {\n", NIL);

    // Generate normal wrappers
    Language::classHandler(n);

    SwigType *t = Copy(Getattr(n, "name"));
    SwigType_add_pointer(t);

    // Catch all: eg. a class with only static functions and/or variables will not have 'remembered'
    String *wrap_class = NewStringf("&_wrap_class_%s", mangled_classname);
    SwigType_remember_clientdata(t, wrap_class);

    String *rt = Copy(Getattr(n, "classtype"));
    SwigType_add_pointer(rt);

    // Register the class structure with the type checker
    //    Printf(f_init,"SWIG_TypeClientData(SWIGTYPE%s, (void *) &_wrap_class_%s);\n", SwigType_manglestr(t), mangled_classname);
    if (have_destructor) {
      Printv(f_wrappers, "static void swig_delete_", class_name, "(void *obj) {\n", NIL);
      if (destructor_action) {
	Printv(f_wrappers, SwigType_str(rt, "arg1"), " = (", SwigType_str(rt, 0), ") obj;\n", NIL);
	Printv(f_wrappers, destructor_action, NIL);
      } else {
	if (CPlusPlus) {
	  Printv(f_wrappers, "    delete (", SwigType_str(rt, 0), ") obj;\n", NIL);
	} else {
	  Printv(f_wrappers, "    free((char *) obj);\n", NIL);
	}
      }
      Printf(f_wrappers, "}\n");
    }

    Printf(s_methods_tab, "    {0,0}\n};\n");
    Printv(f_wrappers, s_methods_tab, NIL);

    Printf(s_attr_tab, "    {0,0,0}\n};\n");
    Printv(f_wrappers, s_attr_tab, NIL);

    Delete(s_methods_tab);
    Delete(s_attr_tab);

    // Handle inheritance
    // note: with the idea of class hireachied spread over multiple modules
    // cf test-suite: imports.i
    // it is not possible to just add the pointers to the base classes to the code
    // (as sometimes these classes are not present)
    // therefore we instead hold the name of the base class and a null pointer
    // at runtime: we can query the swig type manager & see if the class exists
    // if so, we can get the pointer to the base class & replace the null pointer
    // if the type does not exist, then we cannot...    
    String *base_class = NewString("");
    String *base_class_names = NewString("");

    List *baselist = Getattr(n, "bases");
    if (baselist && Len(baselist)) {
      Iterator b;
      int index = 0;
      b = First(baselist);
      while (b.item) {
	String *bname = Getattr(b.item, "name");
	if ((!bname) || GetFlag(b.item, "feature:ignore") || (!Getattr(b.item, "module"))) {
	  b = Next(b);
	  continue;
	}
	// old code: (used the pointer to the base class)
	//String *bmangle = Swig_name_mangle(bname);
	//Printf(base_class, "&_wrap_class_%s", bmangle);
	//Putc(',', base_class);
	//Delete(bmangle);
	// new code: stores a null pointer & the name
	Printf(base_class, "0,");
	Printf(base_class_names, "\"%s *\",", SwigType_namestr(bname));

	b = Next(b);
	index++;
      }
    }

    Printv(f_wrappers, "static swig_lua_class *swig_", mangled_classname, "_bases[] = {", base_class, "0};\n", NIL);
    Delete(base_class);
    Printv(f_wrappers, "static const char *swig_", mangled_classname, "_base_names[] = {", base_class_names, "0};\n", NIL);
    Delete(base_class_names);

    Printv(f_wrappers, "static swig_lua_class _wrap_class_", mangled_classname, " = { \"", class_name, "\", &SWIGTYPE", SwigType_manglestr(t), ",", NIL);

    if (have_constructor) {
      Printf(f_wrappers, "%s", Swig_name_wrapper(Swig_name_construct(constructor_name)));
      Delete(constructor_name);
      constructor_name = 0;
    } else {
      Printf(f_wrappers, "0");
    }

    if (have_destructor) {
      Printv(f_wrappers, ", swig_delete_", class_name, NIL);
    } else {
      Printf(f_wrappers, ",0");
    }
    Printf(f_wrappers, ", swig_%s_methods, swig_%s_attributes, swig_%s_bases, swig_%s_base_names };\n\n", mangled_classname, mangled_classname, mangled_classname, mangled_classname);
    
//    Printv(f_wrappers, ", swig_", mangled_classname, "_methods, swig_", mangled_classname, "_attributes, swig_", mangled_classname, "_bases };\n\n", NIL);
//    Printv(s_cmd_tab, tab4, "{ SWIG_prefix \"", class_name, "\", (swig_wrapper_func) SWIG_ObjectConstructor, &_wrap_class_", mangled_classname, "},\n", NIL);
    Delete(t);
    Delete(mangled_classname);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int memberfunctionHandler(Node *n) {
    String *name = Getattr(n, "name");
    String *iname = GetChar(n, "sym:name");
//Printf(stdout,"memberfunctionHandler %s %s\n",name,iname);

    String *realname, *rname;

    current = MEMBER_FUNC;
    Language::memberfunctionHandler(n);
    current = NO_CPP;

    realname = iname ? iname : name;
    rname = Swig_name_wrapper(Swig_name_member(class_name, realname));
    if (!Getattr(n, "sym:nextSibling")) {
      Printv(s_methods_tab, tab4, "{\"", realname, "\", ", rname, "}, \n", NIL);
    }
    Delete(rname);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * membervariableHandler()
   * ------------------------------------------------------------ */

  virtual int membervariableHandler(Node *n) {
//    REPORT("membervariableHandler",n);
    String *symname = Getattr(n, "sym:name");
    String *gname, *sname;

    current = MEMBER_VAR;
    Language::membervariableHandler(n);
    current = NO_CPP;
    gname = Swig_name_wrapper(Swig_name_get(Swig_name_member(class_name, symname)));
    if (!GetFlag(n, "feature:immutable")) {
      sname = Swig_name_wrapper(Swig_name_set(Swig_name_member(class_name, symname)));
    } else {
      //sname = NewString("0");
      sname = NewString("SWIG_Lua_set_immutable"); // error message
    }
    Printf(s_attr_tab,"%s{ \"%s\", %s, %s},\n",tab4,symname,gname,sname);
    Delete(gname);
    Delete(sname);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constructorHandler()
   *
   * Method for adding C++ member constructor
   * ------------------------------------------------------------ */

  virtual int constructorHandler(Node *n) {
//    REPORT("constructorHandler", n);
    current = CONSTRUCTOR;
    Language::constructorHandler(n);
    current = NO_CPP;
    constructor_name = NewString(Getattr(n, "sym:name"));
    have_constructor = 1;
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * destructorHandler()
   * ------------------------------------------------------------ */

  virtual int destructorHandler(Node *n) {
    current = DESTRUCTOR;
    Language::destructorHandler(n);
    current = NO_CPP;
    have_destructor = 1;
    destructor_action = Getattr(n, "wrap:action");
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * staticmemberfunctionHandler()
   *
   * Wrap a static C++ function
   * ---------------------------------------------------------------------- */

  virtual int staticmemberfunctionHandler(Node *n) {
    current = STATIC_FUNC;
    return Language::staticmemberfunctionHandler(n);
    current = NO_CPP;
  }

  /* ------------------------------------------------------------
   * memberconstantHandler()
   *
   * Create a C++ constant
   * ------------------------------------------------------------ */

  virtual int memberconstantHandler(Node *n) {
//    REPORT("memberconstantHandler",n);
    return Language::memberconstantHandler(n);
  }

  /* ---------------------------------------------------------------------
   * staticmembervariableHandler()
   * --------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {
//    REPORT("staticmembervariableHandler",n);
    current = STATIC_VAR;
    return Language::staticmembervariableHandler(n);
    current = NO_CPP;
  }

  /* ---------------------------------------------------------------------
   * external runtime generation
   * --------------------------------------------------------------------- */

  /* This is to support the usage
     SWIG -external-runtime <filename>
     The code consists of two functions:
     String *runtimeCode()  // returns a large string with all the runtimes in
     String *defaultExternalRuntimeFilename() // returns the default filename
     I am writing a generic solution, even though SWIG-Lua only has one file right now...
   */
  String *runtimeCode() {
    String *s = NewString("");
    const char *filenames[] = { "luarun.swg", 0 };	// must be 0 termiated
    String *sfile;
    for (int i = 0; filenames[i] != 0; i++) {
      sfile = Swig_include_sys(filenames[i]);
      if (!sfile) {
	Printf(stderr, "*** Unable to open '%s'\n", filenames[i]);
      } else {
	Append(s, sfile);
	Delete(sfile);
      }
    }

    return s;
  }

  String *defaultExternalRuntimeFilename() {
    return NewString("swigluarun.h");
  }
};

/* NEW LANGUAGE NOTE:***********************************************
 in order to add you language into swig, you need to make the following changes:
 - write this file (obviously)
 - add into the makefile (not 100% clear on how to do this)
 - edit swigmain.cxx to add your module

near the top of swigmain.cxx, look for this code & add you own codes
======= begin change ==========
extern "C" {
  Language *swig_tcl(void);
  Language *swig_python(void);
  //etc,etc,etc...
  Language *swig_lua(void);	// this is my code
}

  //etc,etc,etc...

swig_module  modules[] = {
  {"-guile",     swig_guile,     "Guile"},
  {"-java",      swig_java,      "Java"},
  //etc,etc,etc...
  {"-Lua",       swig_lua,       "Lua"},	// this is my code
  {NULL, NULL, NULL}	// this must come at the end of the list
};
======= end change ==========

This is all that is needed

NEW LANGUAGE NOTE:END ************************************************/

/* -----------------------------------------------------------------------------
 * swig_lua()    - Instantiate module
 * ----------------------------------------------------------------------------- */

extern "C" Language *swig_lua(void) {
  return new LUA();
}

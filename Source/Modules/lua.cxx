/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
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
 * ver010
   Added support for embedded Lua. Try swig -lua -help for more information
*/

#include "swigmod.h"
#include "cparse.h"

/**** Diagnostics:
  With the #define REPORT(), you can change the amount of diagnostics given
  This helps me search the parse tree & figure out what is going on inside SWIG
  (because its not clear or documented)
*/
#define REPORT(T,D)		// no info:
//#define REPORT(T,D)   {Printf(stdout,T"\n");} // only title
//#define REPORT(T,D)		{Printf(stdout,T" %p\n",n);} // title & pointer
//#define REPORT(T,D)   {Printf(stdout,T"\n");display_mapping(D);}      // the works
//#define REPORT(T,D)   {Printf(stdout,T"\n");if(D)Swig_print_node(D);}      // the works

void display_mapping(DOH *d) {
  if (d == 0 || !DohIsMapping(d))
    return;
  for (Iterator it = First(d); it.item; it = Next(it)) {
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
     -elua           - Generates LTR compatible wrappers for smaller devices running elua\n\
     -eluac          - LTR compatible wrappers in \"crass compress\" mode for elua\n\
     -nomoduleglobal - Do not register the module name as a global variable \n\
                       but return the module table from calls to require.\n\
\n";

static int nomoduleglobal = 0;
static int elua_ltr = 0;
static int eluac_ltr = 0;

/* NEW LANGUAGE NOTE:***********************************************
 To add a new language, you need to derive your class from
 Language and the overload various virtual functions
 (more on this as I figure it out)
NEW LANGUAGE NOTE:END ************************************************/

class LUA:public Language {
private:

  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_wrappersForward; // forward declarations for wrappers, TODO: REMOVE
  File *f_init;
  File *f_initbeforefunc;
  /*
  String *s_ns_methods_tab;		// table of namespace methods
  String *s_ns_var_tab;		// Lua only:table of namespace variables
  String *s_ns_dot_get;		// eLua only:table of variable 'get' functions
  String *s_ns_dot_set;		// eLua only:table of variable 'set' functions
  String *s_ns_const_tab;		// table of namespace constants
  */
  String *s_methods_tab;	// table of class methods
  String *s_attr_tab;		// table of class attributes
  String *s_luacode;		// luacode to be called during init
  String *module;		//name of the module
  //String *s_vars_meta_tab;      // metatable for variables
  Hash* namespaces_hash;

  // Parameters for current class. NIL if not parsing class
  int have_constructor;
  int have_destructor;
  String *destructor_action;
  String *class_symname;
  String *class_fq_symname; // Fully qualified symname - NSpace + '.' + class_symname
  String *class_static_nspace;
  String *constructor_name;

  // Many wrappers forward calls to each other, for example staticmembervariableHandler
  // forwards call to variableHandler, which, in turn, makes to call to functionWrapper.
  // In order to access information about whether it is static member of class or just 
  // plain old variable an array current is kept and used as 'log' of call stack.
  enum TState {
    NO_CPP,
    VARIABLE,
    MEMBER_FUNC,
    CONSTRUCTOR,
    DESTRUCTOR,
    MEMBER_VAR,
    CLASS_CONST,
    STATIC_FUNC,
    STATIC_VAR,
    STATIC_CONST, // enums and things like static const int x = 5;

    STATES_COUNT
  };
  bool current[STATES_COUNT];

public:

  /* ---------------------------------------------------------------------
   * LUA()
   *
   * Initialize member data
   * --------------------------------------------------------------------- */

  LUA() :
    f_begin(0),
    f_runtime(0),
    f_header(0),
    f_wrappers(0),
    f_wrappersForward(0),
    f_init(0),
    f_initbeforefunc(0),
    /*
    s_cmd_tab(0),
    s_var_tab(0),
    s_const_tab(0),
    s_cls_attr_tab(0),
    s_cls_methods_tab(0),
    s_cls_const_tab(0),
    */
    s_methods_tab(0),
    s_attr_tab(0),
    s_luacode(0),
    module(0),
    //s_dot_get(0),
    //s_dot_set(0),
    //s_vars_meta_tab(0),
    have_constructor(0),
    have_destructor(0),
    destructor_action(0),
    class_symname(0),
    class_fq_symname(0),
    class_static_nspace(0),
    constructor_name(0)  {
      namespaces_hash = NewHash();
      for(int i = 0; i < STATES_COUNT; i++ )
        current[i] = false;
  }

  ~LUA() {
    if(namespaces_hash)
      Delete(namespaces_hash);
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
          fputs(usage, stdout);
        } else if (strcmp(argv[i], "-nomoduleglobal") == 0) {
          nomoduleglobal = 1;
          Swig_mark_arg(i);
        } else if(strcmp(argv[i], "-elua") == 0) {
          elua_ltr = 1;
          Swig_mark_arg(i);
        } else if(strcmp(argv[i], "-eluac") == 0) {
          eluac_ltr = 1;
          Swig_mark_arg(i);
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
    module = Getattr(n, "name");

    /* Get the output file name */
    String *outfile = Getattr(n, "outfile");

    /* Open the output file */
    f_begin = NewFile(outfile, "w", SWIG_output_files());
    if (!f_begin) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_runtime = NewString("");
    f_init = NewString("");
    f_header = NewString("");
    f_wrappersForward = NewString("");
    f_wrappers = NewString("");
    f_initbeforefunc = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("begin", f_begin);
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
    // TODO: Replace with call to getNamespaceHash(0)
    /*
    s_cmd_tab = NewString("");
    s_var_tab = NewString("");
    //    s_methods_tab    = NewString("");
    s_const_tab = NewString("");

    s_dot_get = NewString("");
    s_dot_set = NewString("");
    s_vars_meta_tab = NewString("");
    */
    
    s_luacode = NewString("");
    Swig_register_filebyname("luacode", s_luacode);
    
    current[NO_CPP] = true;
    // Registering names schemes
    Swig_name_register("member", "%m");

    /* Standard stuff for the SWIG runtime section */
    Swig_banner(f_begin);

    Printf(f_runtime, "\n");
    Printf(f_runtime, "#define SWIGLUA\n");

    emitLuaFlavor(f_runtime);

    if (nomoduleglobal) {
      Printf(f_runtime, "#define SWIG_LUA_NO_MODULE_GLOBAL\n");
    } else {
      Printf(f_runtime, "#define SWIG_LUA_MODULE_GLOBAL\n");
    }

    //    if (NoInclude) {
    //      Printf(f_runtime, "#define SWIG_NOINCLUDE\n");
    //    }

    Printf(f_runtime, "\n");

    //String *init_name = NewStringf("%(title)s_Init", module);
    //Printf(f_header, "#define SWIG_init    %s\n", init_name);
    //Printf(f_header, "#define SWIG_name    \"%s\"\n", module);
    /* SWIG_import is a special function name for importing within Lua5.1 */
    //Printf(f_header, "#define SWIG_import  luaopen_%s\n\n", module);
    Printf(f_header, "#define SWIG_name      \"%s\"\n", module);
    Printf(f_header, "#define SWIG_init      luaopen_%s\n", module);
    Printf(f_header, "#define SWIG_init_user luaopen_%s_user\n\n", module);
    Printf(f_header, "#define SWIG_LUACODE   luaopen_%s_luacode\n", module);

    /*
    if (elua_ltr || eluac_ltr)
      Printf(f_header, "#define swig_commands  %s_map\n\n", module);
      */

    if (elua_ltr || eluac_ltr) {
      Printf(f_header, "\n#define MIN_OPT_LEVEL 2\n#include \"lrodefs.h\"\n");
      Printf(f_header, "#include \"lrotable.h\"\n");
      //Printf(s_cmd_tab, "\nconst LUA_REG_TYPE swig_constants[];\n");
      /*if (elua_ltr)
        Printf(s_cmd_tab, "const LUA_REG_TYPE mt[];\n");*/

      //Printf(s_cmd_tab, "\nconst LUA_REG_TYPE swig_commands[] = {\n");
      //Printf(s_const_tab, "\nconst LUA_REG_TYPE swig_constants[] = {\n");
      Printf(f_wrappers, "#ifdef __cplusplus\nextern \"C\" {\n#endif\n");
      Printf(f_wrappersForward, "#ifdef __cplusplus\nextern \"C\" {\n#endif\n");
      /*if (elua_ltr) {
        Printf(s_dot_get, "\nconst LUA_REG_TYPE dot_get[] = {\n");
        Printf(s_dot_set, "\nconst LUA_REG_TYPE dot_set[] = {\n");
      }*/
    } else {
      /*
      Printf(s_cmd_tab, "\nstatic const struct luaL_Reg swig_commands[] = {\n");
      Printf(s_var_tab, "\nstatic swig_lua_var_info swig_variables[] = {\n");
      Printf(s_const_tab, "\nstatic swig_lua_const_info swig_constants[] = {\n");
      */
      Printf(f_wrappers, "#ifdef __cplusplus\nextern \"C\" {\n#endif\n");
      Printf(f_wrappersForward, "#ifdef __cplusplus\nextern \"C\" {\n#endif\n");
    }

    /* %init code inclusion, effectively in the SWIG_init function */
    Printf(f_init, "void SWIG_init_user(lua_State* L)\n{\n");
    Language::top(n);
    Printf(f_init,"/* exec Lua code if applicable */\nSWIG_Lua_dostring(L,SWIG_LUACODE);\n");
    Printf(f_init, "}\n");

    Printf(f_wrappers, "#ifdef __cplusplus\n}\n#endif\n");
    Printf(f_wrappersForward, "#ifdef __cplusplus\n}\n#endif\n");

    // Done.  Close up the module & write to the wrappers
#if 0
    if (elua_ltr || eluac_ltr) {
      Printv(s_cmd_tab, tab4, "{LSTRKEY(\"const\"), LROVAL(swig_constants)},\n", NIL);
      if (elua_ltr)
        Printv(s_cmd_tab, tab4, "{LSTRKEY(\"__metatable\"), LROVAL(mt)},\n", NIL);
      Printv(s_cmd_tab, tab4, "{LNILKEY, LNILVAL}\n", "};\n", NIL);
      Printv(s_const_tab, tab4, "{LNILKEY, LNILVAL}\n", "};\n", NIL);
    } else {
      Printv(s_cmd_tab, tab4, "{0,0}\n", "};\n", NIL);
      Printv(s_var_tab, tab4, "{0,0,0}\n", "};\n", NIL);
      Printv(s_const_tab, tab4, "{0,0,0,0,0,0}\n", "};\n", NIL);
    }
#endif

#if 0
    if (elua_ltr) {
      /* Generate the metatable */
      Printf(s_vars_meta_tab, "\nconst LUA_REG_TYPE mt[] = {\n");
      Printv(s_vars_meta_tab, tab4, "{LSTRKEY(\"__index\"), LFUNCVAL(SWIG_Lua_module_get)},\n", NIL);
      Printv(s_vars_meta_tab, tab4, "{LSTRKEY(\"__newindex\"), LFUNCVAL(SWIG_Lua_module_set)},\n", NIL);
      Printv(s_vars_meta_tab, tab4, "{LSTRKEY(\".get\"), LROVAL(dot_get)},\n", NIL);
      Printv(s_vars_meta_tab, tab4, "{LSTRKEY(\".set\"), LROVAL(dot_set)},\n", NIL);
      Printv(s_vars_meta_tab, tab4, "{LNILKEY, LNILVAL}\n};\n", NIL);

      Printv(s_dot_get, tab4, "{LNILKEY, LNILVAL}\n};\n", NIL);
      Printv(s_dot_set, tab4, "{LNILKEY, LNILVAL}\n};\n", NIL);
    }
#endif

    if (elua_ltr || eluac_ltr) {
      /* Final close up of wrappers */
      //Printv(f_wrappers, s_cmd_tab, s_dot_get, s_dot_set, s_vars_meta_tab, s_var_tab, s_const_tab, NIL);
      closeNamespaces(f_wrappers, f_wrappersForward);
      SwigType_emit_type_table(f_runtime, f_wrappers);
    } else {
      //Printv(f_wrappers, s_cmd_tab, s_var_tab, s_const_tab, NIL);
      closeNamespaces(f_wrappers, f_wrappersForward);
      SwigType_emit_type_table(f_runtime, f_wrappers);
    }

    /* NEW LANGUAGE NOTE:***********************************************
     this basically combines several of the strings together
     and then writes it all to a file
    NEW LANGUAGE NOTE:END ************************************************/
    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    Dump(f_wrappersForward, f_begin);
    Dump(f_wrappers, f_begin);
    Dump(f_initbeforefunc, f_begin);
    /* for the Lua code it needs to be properly excaped to be added into the C/C++ code */
    EscapeCode(s_luacode);
    Printf(f_begin, "const char* SWIG_LUACODE=\n  \"%s\";\n\n",s_luacode);
    Wrapper_pretty_print(f_init, f_begin);
    /* Close all of the files */
    Delete(s_luacode);
    //Delete(s_cmd_tab);
    //Delete(s_var_tab);
    //Delete(s_const_tab);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_wrappersForward);
    Delete(f_init);
    Delete(f_initbeforefunc);
    Delete(f_runtime);
    Delete(f_begin);
    //Delete(s_dot_get);
    //Delete(s_dot_set);
    //Delete(s_vars_meta_tab);

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

  // Helper function. Remembers wrap name
  void rememberWrapName(Node *n, String *wrapname) {
    Setattr(n, "wrap:name", wrapname);
    // If it is getter/setter, then write wrapname under
    // wrap:memberset/wrap:memberget accordingly
    if( Getattr(n, "memberset") )
      Setattr(n, "memberset:wrap:name", wrapname);
    if( Getattr(n, "varset") )
      Setattr(n, "varset:wrap:name", wrapname);
    if( Getattr(n, "memberget") )
      Setattr(n, "memberget:wrap:name", wrapname);
    if( Getattr(n, "varget") )
      Setattr(n, "varget:wrap:name", wrapname);
  }

  virtual int functionWrapper(Node *n) {
    REPORT("functionWrapper",n);

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
      if (!luaAddSymbol(iname, n)) {
        Printf(stderr,"addSymbol(%s) failed\n",iname);
        return SWIG_ERROR;
      }
    }

    /* NEW LANGUAGE NOTE:***********************************************
       the wrapper object holds all the wrappering code
        we need to add a couple of local variables
    NEW LANGUAGE NOTE:END ************************************************/
    Wrapper *f = NewWrapper();
    Wrapper_add_local(f, "SWIG_arg", "int SWIG_arg = 0");


    String* fqname = fully_qualified_name(iname);
    String *wname = Swig_name_wrapper(fqname);
    Delete(fqname);
    if (overname) {
      Append(wname, overname);
    }
    if (current[CONSTRUCTOR]) {
      if( constructor_name != 0)
        Delete(constructor_name);
      constructor_name = Copy(wname);
    }
    //Printf(stdout , "Function wrapper, name %s\n", wname); // TODO:REMOVE

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
    NEW LANGUAGE NOTE:END ************************************************/
    /* Write code to extract function parameters. */
    emit_parameter_variables(l, f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l, f);
    Setattr(n, "wrap:parms", l);

    /* Get number of required and total arguments */
    int num_arguments = emit_num_arguments(l);
    int num_required = emit_num_required(l);
    int varargs = emit_isvarargs(l);

    // Check if we have to ignore arguments that are passed by LUA.
    // Needed for unary minus, where lua passes two arguments and
    // we have to ignore the second.

    int args_to_ignore = 0;
    if (Getattr(n, "lua:ignore_args")) {
      args_to_ignore = GetInt(n, "lua:ignore_args");
    }


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
    char source[64];
    Printf(argument_check, "SWIG_check_num_args(\"%s\",%d,%d)\n",Swig_name_str(n),num_required+args_to_ignore,num_arguments+args_to_ignore);

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
        if (Getattr(p, "wrap:disown") || (Getattr(p, "tmap:in:disown"))) {
          Replaceall(tm, "$disown", "SWIG_POINTER_DISOWN");
        } else {
          Replaceall(tm, "$disown", "0");
        }
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
          Printf(argument_check, " SWIG_fail_arg(\"%s\",%s,\"%s\");\n", Swig_name_str(n), source, SwigType_str(pt, 0));
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
        Replaceall(tm, "$target", Swig_cresult_name());
        Replaceall(tm, "$arg", Getattr(p, "emit:input"));
        Replaceall(tm, "$input", Getattr(p, "emit:input"));
        Printv(outarg, tm, "\n", NIL);
        p = Getattr(p, "tmap:argout:next");
      } else {
        p = nextSibling(p);
      }
    }

    // Remember C name of the wrapping function
    rememberWrapName(n, wname);

    /* Emit the function call */
    String *actioncode = emit_action(n);

    /* NEW LANGUAGE NOTE:***********************************************
    FIXME:
    returns 1 if there is a void return type
    this is because there is a typemap for void
    NEW LANGUAGE NOTE:END ************************************************/
    // Return value if necessary
    if ((tm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), f, actioncode))) {
      // managing the number of returning variables
      //      if (numoutputs=Getattr(tm,"numoutputs")){
      //              int i=GetInt(tm,"numoutputs");
      //              printf("return numoutputs %d\n",i);
      //              returnval+=GetInt(tm,"numoutputs");
      //      }
      //        else returnval++;
      Replaceall(tm, "$source", Swig_cresult_name());
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
    emit_return_variable(n, d, f);

    /* Output argument output code */
    Printv(f->code, outarg, NIL);

    /* Output cleanup code */
    Printv(f->code, cleanup, NIL);

    /* Look to see if there is any newfree cleanup code */
    if (GetFlag(n, "feature:new")) {
      if ((tm = Swig_typemap_lookup("newfree", n, Swig_cresult_name(), 0))) {
        Replaceall(tm, "$source", Swig_cresult_name());
        Printf(f->code, "%s\n", tm);
      }
    }

    /* See if there is any return cleanup code */
    if ((tm = Swig_typemap_lookup("ret", n, Swig_cresult_name(), 0))) {
      Replaceall(tm, "$source", Swig_cresult_name());
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
    Replaceall(f->code, "$result", Swig_cresult_name());

    /* Dump the function out */
    /* in Lua we will not emit the destructor as a wrappered function,
    Lua will automatically call the destructor when the object is free'd
    However: you cannot just skip this function as it will not emit
    any custom destructor (using %extend), as you need to call emit_action()
    Therefore we go though the whole function, 
    but do not write the code into the wrapper
    */
    if(!current[DESTRUCTOR]) {
       Wrapper_print(f, f_wrappers);
    }
    
    /* NEW LANGUAGE NOTE:***********************************************
    register the function in SWIG
    different language mappings seem to use different ideas
    NEW LANGUAGE NOTE:END ************************************************/
    /* Now register the function with the interpreter. */
    if (!Getattr(n, "sym:overloaded")) {
      //REPORT("dispatchFunction", n);
      //      add_method(n, iname, wname, description);
      if (current[NO_CPP] || current[STATIC_FUNC]) { // emit normal fns & static fns
        Hash* nspaceHash = getNamespaceHash( getNSpace() );
        String* s_ns_methods_tab = Getattr(nspaceHash, "methods");
        if(elua_ltr || eluac_ltr)
          Printv(s_ns_methods_tab, tab4, "{LSTRKEY(\"", iname, "\")", ", LFUNCVAL(", wname, ")", "},\n", NIL);
        else
          Printv(s_ns_methods_tab, tab4, "{ \"", iname, "\", ", wname, "},\n", NIL);
      //      Printv(s_cmd_tab, tab4, "{ SWIG_prefix \"", iname, "\", (swig_wrapper_func) ", Swig_name_wrapper(iname), "},\n", NIL);
        if (getCurrentClass()) {
          Setattr(n,"luaclassobj:wrap:name", wname);
        }
      }
    } else {
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
    //REPORT("dispatchFunction", n);
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
    
    Node *sibl = n;
    while (Getattr(sibl, "sym:previousSibling"))
      sibl = Getattr(sibl, "sym:previousSibling");	// go all the way up
    String *protoTypes = NewString("");
    do {
      String *fulldecl = Swig_name_decl(sibl);
      Printf(protoTypes, "\n\"    %s\\n\"", fulldecl);
      Delete(fulldecl);
    } while ((sibl = Getattr(sibl, "sym:nextSibling")));
    Printf(f->code, "SWIG_Lua_pusherrstring(L,\"Wrong arguments for overloaded function '%s'\\n\"\n"
        "\"  Possible C/C++ prototypes are:\\n\"%s);\n",symname,protoTypes);
    Delete(protoTypes);

    Printf(f->code, "lua_error(L);return 0;\n");
    Printv(f->code, "}\n", NIL);
    Wrapper_print(f, f_wrappers);
    //add_method(symname,wname,0);
    if (current[NO_CPP] || current[STATIC_FUNC]) { // emit normal fns & static fns
      Hash* nspaceHash = getNamespaceHash( getNSpace() );
      String* s_ns_methods_tab = Getattr(nspaceHash, "methods");
      Printv(s_ns_methods_tab, tab4, "{ \"", symname, "\",", wname, "},\n", NIL);
    }
    if (current[CONSTRUCTOR]) {
      if( constructor_name != 0 )
        Delete(constructor_name);
      constructor_name = Copy(wname);
    }

    // Remember C name of the wrapping function
    rememberWrapName(n, wname);

    DelWrapper(f);
    Delete(dispatch);
    Delete(tmp);
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
    String *unassignable = NewString("SWIG_Lua_set_immutable");
    current[VARIABLE] = true;
    // let SWIG generate the wrappers
    int result = Language::variableWrapper(n);
    current[VARIABLE] = false;
    // normally SWIG will generate 2 wrappers, a get and a set
    // but in certain scenarios (immutable, or if its arrays), it will not
    String *getName = Getattr(n,"varget:wrap:name");
    String *setName = 0;
    // checking whether it can be set to or not appears to be a very error prone issue
    // I referred to the Language::variableWrapper() to find this out
    bool assignable=is_assignable(n) ? true : false;
    SwigType *type = Getattr(n, "type");
    String *tm = Swig_typemap_lookup("globalin", n, iname, 0);
    if (!tm && SwigType_isarray(type))
      assignable=false;
    Delete(tm);

    if (assignable) {
      setName = Getattr(n,"varset:wrap:name");
    } else {
      // how about calling a 'this is not settable' error message?
      setName =  unassignable;// error message
    }

    // register the variable
    assert(setName != 0);
    assert(getName != 0);
    Hash* nspaceHash = getNamespaceHash( getNSpace() );
    String* s_ns_methods_tab = Getattr(nspaceHash, "methods");
    String* s_ns_var_tab = Getattr(nspaceHash, "attributes");
    if (elua_ltr) {
      String* s_ns_dot_get = Getattr(nspaceHash, "get");
      String* s_ns_dot_set = Getattr(nspaceHash, "set");
      Printf(s_ns_dot_get, "%s{LSTRKEY(\"%s\"), LFUNCVAL(%s)},\n", tab4, iname, getName);
      Printf(s_ns_dot_set, "%s{LSTRKEY(\"%s\"), LFUNCVAL(%s)},\n", tab4, iname, setName);
    } else if (eluac_ltr) {
      Printv(s_ns_methods_tab, tab4, "{LSTRKEY(\"", iname, "_get", "\")", ", LFUNCVAL(", getName, ")", "},\n", NIL);
      Printv(s_ns_methods_tab, tab4, "{LSTRKEY(\"", iname, "_set", "\")", ", LFUNCVAL(", setName, ")", "},\n", NIL);
    } else {
      Printf(s_ns_var_tab, "%s{ \"%s\", %s, %s },\n", tab4, iname, getName, setName);
    }
    if (getCurrentClass()) { // TODO: REMOVE
      Setattr(n, "luaclassobj:wrap:get", getName);
      Setattr(n, "luaclassobj:wrap:set", setName);
    } else {
      Delete(unassignable);
    }
    return result;
  }

  /* ------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------ */
  virtual int constantWrapper(Node *n) {
    REPORT("constantWrapper", n);
    String *name = Getattr(n, "name");
    String *iname = Getattr(n, "sym:name");
    String *nsname = Copy(iname);
    SwigType *type = Getattr(n, "type");
    String *rawval = Getattr(n, "rawval");
    String *value = rawval ? rawval : Getattr(n, "value");
    String *tm;
    //Printf( stdout, "Add constant %s, ns %s\n", iname, getNSpace() );// TODO: REMOVE

    if (!luaAddSymbol(iname, n))
      return SWIG_ERROR;

    /* Special hook for member pointer */
    if (SwigType_type(type) == T_MPOINTER) {
      String *wname = Swig_name_wrapper(iname);
      Printf(f_wrappers, "static %s = %s;\n", SwigType_str(type, wname), value);
      value = Char(wname);
    }

    if ((tm = Swig_typemap_lookup("consttab", n, name, 0))) {
      Replaceall(tm, "$source", value);
      Replaceall(tm, "$target", name);
      Replaceall(tm, "$value", value);
      Replaceall(tm, "$nsname", nsname);
      Hash *nspaceHash = getNamespaceHash( getNSpace() );
      String *s_const_tab = Getattr(nspaceHash, "constants");
      Printf(s_const_tab, "    %s,\n", tm);
    } else if ((tm = Swig_typemap_lookup("constcode", n, name, 0))) {
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
    /* TODO: Fix
    if (cparse_cplusplus && getCurrentClass()) {
      // Additionally add to class constants
      Swig_require("luaclassobj_constantWrapper", n, "*sym:name", "luaclassobj:symname", NIL);
      Setattr(n, "sym:name", Getattr(n, "luaclassobj:symname"));
      String *cls_nsname = Getattr(n, "sym:name");
      if ((tm = Swig_typemap_lookup("consttab", n, name, 0))) {
        Replaceall(tm, "$source", value);
        Replaceall(tm, "$target", name);
        Replaceall(tm, "$value", value);
        Replaceall(tm, "$nsname", cls_nsname);
        Printf(s_cls_const_tab, "    %s,\n", tm);
      }
      Swig_restore(n);
    }*/
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
    if (!luaAddSymbol(wrapname, n))
      return SWIG_ERROR;

    Hash *nspaceHash = getNamespaceHash( getNSpace() );
    String* s_ns_methods_tab = Getattr(nspaceHash, "methods");
    Printv(s_ns_methods_tab, tab4, "{ \"", symname, "\",", wrapname, "},\n", NIL);
    //   return Language::nativeWrapper(n); // this does nothing...
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * enumDeclaration()
   * ------------------------------------------------------------ */

  virtual int enumDeclaration(Node *n) {
    // enumDeclaration supplied by Language is messing with NSpace.
    // So this is the exact copy of function from Language with
    // correct handling of namespaces
      String *oldNSpace = getNSpace();
      if( getCurrentClass() == 0 ) {
        setNSpace(Getattr(n, "sym:nspace"));
      }

      if (!ImportMode) {
        current[STATIC_CONST] = true;
        emit_children(n);
        current[STATIC_CONST] = false;
      }

      setNSpace(oldNSpace);

      return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * enumvalueDeclaration()
   * ------------------------------------------------------------ */

  virtual int enumvalueDeclaration(Node *n) {
    if (getCurrentClass() && (cplus_mode != PUBLIC))
      return SWIG_NOWRAP;

    Swig_require("enumvalueDeclaration", n, "*name", "?value", NIL);
    String *value = Getattr(n, "value");
    String *name = Getattr(n, "name");
    String *tmpValue;

    if (value)
      tmpValue = NewString(value);
    else
      tmpValue = NewString(name);
    Setattr(n, "value", tmpValue);

    Setattr(n, "name", tmpValue);	/* for wrapping of enums in a namespace when emit_action is used */
    constantWrapper(n);

    Delete(tmpValue);
    Swig_restore(n);
    // TODO: Backward compatibility: add ClassName_ConstantName member
    return SWIG_OK;
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
    //REPORT("classHandler", n);

    String *mangled_class_fq_symname = 0;
    String* nspace = getNSpace();
    String* destructor_name = 0;

    constructor_name = 0;
    have_constructor = 0;
    have_destructor = 0;
    destructor_action = 0;
    assert(class_static_nspace == 0);
    assert(class_fq_symname == 0);
    assert(class_symname == 0);

    current[NO_CPP] = false;

    class_symname = Getattr(n, "sym:name");
    // We have to enforce nspace here, because technically we are already
    // inside class parsing (getCurrentClass != 0), but we should register
    // class in the it's parent namespace
    if (!luaAddSymbol(class_symname, n, nspace))
      return SWIG_ERROR;

    if (nspace == 0)
      class_fq_symname = NewStringf("%s", class_symname);
    else
      class_fq_symname = NewStringf("%s.%s", nspace, class_symname);

    assert(class_fq_symname != 0);
    mangled_class_fq_symname = Swig_name_mangle(class_fq_symname);
    Printf( stdout, "Mangled class symname %s\n", mangled_class_fq_symname );

    // not sure exactly how this works,
    // but tcl has a static hashtable of all classes emitted and then only emits code for them once.
    // this fixes issues in test suites: template_default2 & template_specialization

    // * if i understand correctly, this is a bug.
    // * consider effect on template_specialization_defarg

    static Hash *emitted = NewHash();
    if (Getattr(emitted, mangled_class_fq_symname))
      return SWIG_NOWRAP;
    Setattr(emitted, mangled_class_fq_symname, "1");

    // We treat class T as both 'class' and 'namespace'. All static members, attributes
    // and constants are considered part of namespace T, all members - part of the 'class'
    // Now, here is a trick. Static methods, attributes and non-static methods and attributes
    // are described with same structures - swig_lua_attribute/swig_lua_method. Instead of calling
    // getNamespaceHash(class name) to initialize things for static methods/attributes and then
    // manually doing same initialization for non-static methods, we call getNamespaceHash 2 times:
    // 1) With name "class name" + "." + "__Static" to initialize static things
    // 2) With "class name" to initialize non-static things
    // And we can guarantee that there will not be any name collision because names starting with 2 underscores
    // and capital letter are forbiden to use in C++. So, under know circumstances could our class contain
    // any member or subclass with name "__Static". Thus, never any name clash.
    Hash* non_static_cls = getNamespaceHash(class_fq_symname, false);
    assert(non_static_cls != 0);
    s_attr_tab = Getattr(non_static_cls, "attributes");
    s_methods_tab = Getattr(non_static_cls, "methods");
    String* s_attr_tab_name = Getattr(non_static_cls, "attributes:name");
    String* s_methods_tab_name = Getattr(non_static_cls, "methods:name");
    Setattr(non_static_cls, "lua:no_namespaces", "1");
    Setattr(non_static_cls, "lua:no_classes", "1");

    /* There is no use for "constants", "classes" and "namespaces" arrays.
     * All constants are considered part of static part of class.
     */

    class_static_nspace = NewStringf("%s%s__Static", class_fq_symname, NSPACE_SEPARATOR);
    Hash *static_cls = getNamespaceHash(class_static_nspace, false);
    assert(static_cls != 0);
    Setattr(static_cls, "lua:no_namespaces", "1");
    /* TODO: REMOVE
    s_cls_methods_tab = Getattr(static_cls, "methods");
    s_cls_attr_tab = Getattr(static_cls, "attributes");
    s_cls_const_tab = Getattr(static_cls, "constants");
    */

    /* There is no use for "classes" and "namespaces" arrays. Subclasses are not supported
     * by SWIG and namespaces couldn't be nested inside classes (C++ Standard)
     */
    assert(s_attr_tab != 0);
    assert(s_methods_tab != 0);
    /*
    assert(s_cls_methods_tab != 0);
    assert(s_cls_attr_tab != 0);
    assert(s_cls_const_tab != 0);
    */

    // Replacing namespace with namespace + class in order to static
    // member be put inside class static area
    setNSpace(class_static_nspace);
    // Generate normal wrappers
    Language::classHandler(n);
    // Restore correct nspace
    setNSpace(nspace);
    //Printf( stdout, "Class finished\n" ); TODO:REMOVE

    SwigType *t = Copy(Getattr(n, "name"));
    SwigType_add_pointer(t);

    // Catch all: eg. a class with only static functions and/or variables will not have 'remembered'
    String *wrap_class = NewStringf("&_wrap_class_%s", mangled_class_fq_symname);
    SwigType_remember_clientdata(t, wrap_class);

    String *rt = Copy(getClassType());
    SwigType_add_pointer(rt);

    // Adding class to apropriate namespace
    Hash *nspaceHash = getNamespaceHash(nspace);
    String *ns_classes = Getattr(nspaceHash, "classes");
    Printv( ns_classes, wrap_class, ",\n", NIL );

    // Register the class structure with the type checker
    //    Printf(f_init,"SWIG_TypeClientData(SWIGTYPE%s, (void *) &_wrap_class_%s);\n", SwigType_manglestr(t), mangled_class_fq_symname);
 
    // emit a function to be called to delete the object 
    // TODO: class_name -> full_class_name || mangled full_class_name
    if (have_destructor) {
      destructor_name = NewStringf("swig_delete_%s", mangled_class_fq_symname);
      Printv(f_wrappers, "static void ", destructor_name, "(void *obj) {\n", NIL);
      if (destructor_action) {
        Printv(f_wrappers, SwigType_str(rt, "arg1"), " = (", SwigType_str(rt, 0), ") obj;\n", NIL);
        Printv(f_wrappers, destructor_action, "\n", NIL);
      } else {
        if (CPlusPlus) {
          Printv(f_wrappers, "    delete (", SwigType_str(rt, 0), ") obj;\n", NIL);
        } else {
          Printv(f_wrappers, "    free((char *) obj);\n", NIL);
        }
      }
      Printf(f_wrappers, "}\n");
    }
    // Wrap constructor wrapper into one more proxy function. It will be used as class namespace __call method, thus
    // allowing both
    // Module.ClassName.StaticMethod to access static method/variable/constant
    // Module.ClassName() to create new object
    if (have_constructor) {
      String* constructor_proxy_name = NewStringf("_proxy_%s", constructor_name);
      Printv(f_wrappers, "static int ", constructor_proxy_name, "(lua_State *L) {\n", NIL);
      Printv(f_wrappers,
        tab4, "assert(lua_istable(L,1));\n",
        tab4, "lua_pushcfunction(L,", constructor_name, ");\n",
        tab4, "assert(!lua_isnil(L,-1));\n",
        tab4, "lua_replace(L,1); /* replace our table with real constructor */\n",
        tab4, "lua_call(L,lua_gettop(L)-1,1);\n",
        tab4, "return 1;\n}\n", NIL);
      Delete(constructor_name);
      constructor_name = constructor_proxy_name;
    }

    closeNamespaceHash(class_fq_symname, f_wrappers);
    closeNamespaceHash(class_static_nspace, f_wrappers);


    /* TODO: REMOVE
    Delete(s_methods_tab);
    Delete(s_attr_tab);
    Delete(s_cls_methods_tab);
    Delete(s_cls_attr_tab);
    Delete(s_cls_const_tab);
    */

    // Handle inheritance
    // note: with the idea of class hierarchies spread over multiple modules
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
        // old code: (used the pointer to the base class) TODO:REMOVE
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

    Printv(f_wrappers, "static swig_lua_class *swig_", mangled_class_fq_symname, "_bases[] = {", base_class, "0};\n", NIL);
    Delete(base_class);
    Printv(f_wrappers, "static const char *swig_", mangled_class_fq_symname, "_base_names[] = {", base_class_names, "0};\n", NIL);
    Delete(base_class_names);

    Printv(f_wrappers, "static swig_lua_class _wrap_class_", mangled_class_fq_symname, " = { \"", class_symname, "\", \"", class_fq_symname,"\", &SWIGTYPE", SwigType_manglestr(t), ",", NIL);

    // TODO: Replace with constructor_name
    if (have_constructor) {
      if (elua_ltr) {
        String* ns_methods_tab = Getattr(nspaceHash, "methods");
        // TODO: Contructor should be moved to __call method of static part of class
        Printf(ns_methods_tab, "    {LSTRKEY(\"%s\"), LFUNCVAL(%s)},\n", class_symname, \
        Swig_name_wrapper(Swig_name_construct(nspace, constructor_name)));
        Printf(f_wrappers, "%s", Swig_name_wrapper(Swig_name_construct(nspace, constructor_name)));
      } else if (eluac_ltr) {
        String* ns_methods_tab = Getattr(nspaceHash, "methods");
        Printv(ns_methods_tab, tab4, "{LSTRKEY(\"", "new_", class_symname, "\")", ", LFUNCVAL(", \
        Swig_name_wrapper(Swig_name_construct(nspace, constructor_name)), ")", "},\n", NIL);
        Printf(f_wrappers, "%s", Swig_name_wrapper(Swig_name_construct(nspace, constructor_name)));
      } else {
        //Printf( stdout, "Constructor.name %s declaration: %s\n", constructor_name, Swig_name_wrapper(Swig_name_construct(nspace, constructor_name)));
        //Printf(f_wrappers, "%s", Swig_name_wrapper(Swig_name_construct(nspace, constructor_name)));
        Printv(f_wrappers, constructor_name, NIL);
      }
      Delete(constructor_name);
      constructor_name = 0;
    } else {
      Printf(f_wrappers, "0");
    }

    if (have_destructor) {
      if (eluac_ltr) {
        String* ns_methods_tab = Getattr(nspaceHash, "methods");
        Printv(ns_methods_tab, tab4, "{LSTRKEY(\"", "free_", mangled_class_fq_symname, "\")", ", LFUNCVAL(", destructor_name, ")", "},\n", NIL);
        Printv(f_wrappers, ", ", destructor_name, NIL);
      } else {
         Printv(f_wrappers, ", ", destructor_name, NIL);
      }
    } else {
      Printf(f_wrappers, ",0");
    }
    Printf(f_wrappers, ", %s, %s, ", s_methods_tab_name, s_attr_tab_name );
    // TODO: Replace class_symname with class_name
    printNamespaceDefinition(class_static_nspace, class_symname, f_wrappers);
    Printf(f_wrappers, ", swig_%s_bases, swig_%s_base_names };\n\n",
        mangled_class_fq_symname, mangled_class_fq_symname);

    //    Printv(f_wrappers, ", swig_", mangled_class_fq_symname, "_methods, swig_", mangled_class_fq_symname, "_attributes, swig_", mangled_class_fq_symname, "_bases };\n\n", NIL);
    //    Printv(s_cmd_tab, tab4, "{ SWIG_prefix \"", class_name, "\", (swig_wrapper_func) SWIG_ObjectConstructor, &_wrap_class_", mangled_class_fq_symname, "},\n", NIL);

    current[NO_CPP] = true;
    Delete(t);
    Delete(mangled_class_fq_symname);
    Delete(class_static_nspace);
    class_static_nspace = 0;
    Delete(class_fq_symname);
    class_fq_symname = 0;
    class_symname = 0;
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int memberfunctionHandler(Node *n) {
    String *name = Getattr(n, "name");
    String *iname = GetChar(n, "sym:name");
    //Printf(stdout,"memberfunctionHandler %s %s\n",name,iname);

    // Special case unary minus: LUA passes two parameters for the
    // wrapper function while we want only one. Tell our
    // functionWrapper to ignore a parameter.

    if (Cmp(Getattr(n, "sym:name"), "__unm") == 0) {
      //Printf(stdout, "unary minus: ignore one argument\n");
      SetInt(n, "lua:ignore_args", 1);
    }

    String *realname, *rname;

    current[MEMBER_FUNC] = true;
    Language::memberfunctionHandler(n);
    current[MEMBER_FUNC] = false;

    realname = iname ? iname : name;
    rname = Getattr(n, "wrap:name");
    assert(rname != 0);
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
    String *getter_name, *setter_name;

    current[MEMBER_VAR] = true;
    Language::membervariableHandler(n);
    current[MEMBER_VAR] = false;
    getter_name = Getattr(n, "memberget:wrap:name");
    assert(getter_name != 0);
    if (!GetFlag(n, "feature:immutable")) {
      setter_name = Getattr(n, "memberset:wrap:name");
      assert(setter_name != 0);
    } else {
      //setter_name = NewString("0");
      setter_name = NewString("SWIG_Lua_set_immutable"); // error message
    }
    Printf(s_attr_tab,"%s{ \"%s\", %s, %s},\n",tab4,symname,getter_name,setter_name);
    /*if (eluac_ltr) { TODO: FIX for eluac and uncomments
      Printv(s_cmd_tab, tab4, "{LSTRKEY(\"", class_name, "_", symname, "_get", "\")", \
      ", LFUNCVAL(", getter_name, ")", "},\n", NIL);
      Printv(s_cmd_tab, tab4, "{LSTRKEY(\"", class_name, "_", symname, "_set", "\")", \
      ", LFUNCVAL(", setter_name, ")", "},\n", NIL);
    }*/
    Delete(getter_name);
    Delete(setter_name);
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constructorHandler()
   *
   * Method for adding C++ member constructor
   * ------------------------------------------------------------ */

  virtual int constructorHandler(Node *n) {
    //    REPORT("constructorHandler", n);
    current[CONSTRUCTOR] = true;
    Language::constructorHandler(n);
    current[CONSTRUCTOR] = false;
    //constructor_name = NewString(Getattr(n, "sym:name"));
    have_constructor = 1;
    //Printf( stdout, "Constructor %s\n", constructor_name); TODO: REMOVE
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * destructorHandler()
   * ------------------------------------------------------------ */

  virtual int destructorHandler(Node *n) {
    REPORT("destructorHandler", n);
    current[DESTRUCTOR] = true;
    Language::destructorHandler(n);
    current[DESTRUCTOR] = false;
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
    REPORT("staticmemberfunctionHandler", n);
    current[STATIC_FUNC] = true;
    //String *symname = Getattr(n, "sym:name");
    int result = Language::staticmemberfunctionHandler(n);

    if (cparse_cplusplus && getCurrentClass()) {
      Swig_restore(n);
    }
    current[STATIC_FUNC] = false;;
    if (result != SWIG_OK)
      return result;

    if (Getattr(n, "sym:nextSibling"))
      return SWIG_OK;

    //Swig_require("luaclassobj_staticmemberfunctionHandler", n, "luaclassobj:wrap:name", NIL);
    //String *name = Getattr(n, "name");
    //String *rname, *realname;
    //realname = symname ? symname : name;
    //rname = Getattr(n, "luaclassobj:wrap:name");
    // TODO: Add backward compatibility here: add "ClassName_FuncName" to global table
    //Printv(s_cls_methods_tab, tab4, "{\"", realname, "\", ", rname, "}, \n", NIL);
    //Swig_restore(n);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberconstantHandler()
   *
   * Create a C++ constant
   * ------------------------------------------------------------ */

  virtual int memberconstantHandler(Node *n) {
    REPORT("memberconstantHandler",n);
    String *symname = Getattr(n, "sym:name");
    if (cparse_cplusplus && getCurrentClass()) {
      Swig_save("luaclassobj_memberconstantHandler", n, "luaclassobj:symname", NIL);
      Setattr(n, "luaclassobj:symname", symname);
    }
    int result = Language::memberconstantHandler(n);
    if (cparse_cplusplus && getCurrentClass())
      Swig_restore(n); // TODO: WTF ?

    return result;
  }

  /* ---------------------------------------------------------------------
   * staticmembervariableHandler()
   * --------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {
    REPORT("staticmembervariableHandler",n);
    current[STATIC_VAR] = true;
    //String *symname = Getattr(n, "sym:name");
    int result = Language::staticmembervariableHandler(n);
    current[STATIC_VAR] = false;

    if (result != SWIG_OK)
      return result;


    if (Getattr(n, "wrappedasconstant"))
      return SWIG_OK;

    /* TODO: Add backward compatibility here: add "ClassName_AttributeName" to class scope
    Swig_require("luaclassobj_staticmembervariableHandler", n, "luaclassobj:wrap:get", "luaclassobj:wrap:set", NIL);
    Printf(s_cls_attr_tab,"%s{ \"%s\", %s, %s},\n",tab4,symname,Getattr(n,"luaclassobj:wrap:get"), Getattr(n,"luaclassobj:wrap:set"));
    Swig_restore(n);
    */
    return SWIG_OK;
  }

  /* TODO: REMOVE
  virtual int namespaceDeclaration(Node *n) {
    // Register namespace
    String* name = Getattr(n, "sym:name");
    Hash* parent = getNamespaceHash( getNSpace() );
    String *parent_namespaces_tab = Getattr(parent, "namespaces");
    String *mangled_name = Swig_name_mangle(name);
    String *full_name = NewString("");
    if (getNSpace() == 0)
      Printv(full_name, name);
    else
      Printv(full_name, getNSpace(), NSPACE_SEPARATOR, name);
    Hash *nspace = getNamespaceHash(full_name);
    Setattr(nspace, "name", Copy(name));
    Printv(parent_namespaces_tab, mangled_name, ",\n", NIL);
    Printf(stdout, "NamespaceDeclaration %s, Parent %s, FQN %s\n", name, getNSpace(), full_name);
    Delete(mangled_name);
    Delete(full_name);
    return Language::namespaceDeclaration(n);
  }
  */
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
    const char *filenames[] = { "luarun.swg", 0 } ; // must be 0 terminated

    emitLuaFlavor(s);

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
  
  /* ---------------------------------------------------------------------
   * helpers
   * --------------------------------------------------------------------- */

  void emitLuaFlavor(String *s) {
    if (elua_ltr)
      Printf(s, "#define SWIG_LUA_TARGET SWIG_LUA_FLAVOR_ELUA\n");
    else if (eluac_ltr)
      Printf(s, "#define SWIG_LUA_TARGET SWIG_LUA_FLAVOR_ELUAC\n");
    else
      Printf(s, "#define SWIG_LUA_TARGET SWIG_LUA_FLAVOR_LUA\n");
  }
  

  /* This is to convert the string of Lua code into a proper string, which can then be
     emitted into the C/C++ code.
     Basically is is a lot of search & replacing of odd sequences
   */
  void EscapeCode(String* str)
  {
    //Printf(f_runtime,"/* original luacode:[[[\n%s\n]]]\n*/\n",str);
    Chop(str); // trim
    Replace(str,"\\","\\\\",DOH_REPLACE_ANY); // \ to \\ (this must be done first)
    Replace(str,"\"","\\\"",DOH_REPLACE_ANY); // " to \"
    Replace(str,"\n","\\n\"\n  \"",DOH_REPLACE_ANY); // \n to \n"\n" (ie quoting every line)
    //Printf(f_runtime,"/* hacked luacode:[[[\n%s\n]]]\n*/\n",str);
  } 

  /* Each namespace can be described with hash that stores C arrays
   where members of the namespace should be added. All these hashes are stored
   inside namespaces_hash.
   nspace could be NULL (NSPACE_TODO), that means functions and variables and classes
   that are not in any namespace (this is default for SWIG unless %nspace feature is used)
   You can later set some attributes that will affect behaviour of functions that use this hash:
   "lua:no_namespaces" will disable "namespaces" array.
   "lua:no_classes" will disable "classes" array.
   For every component ("attributes", "methods", etc) there are subcomponents:
   * XXX:name - name of the C array that stores data for component
   * XXX:decl - statement with forward declaration of this array;
   */
  Hash* getNamespaceHash(String *nspace, bool reg = true)
  {
    //Printf( stdout, "Request for %s. register: %d\n", nspace?nspace:"<global>", int(reg));
    Hash* nspace_hash = Getattr(namespaces_hash, nspace?nspace:"" );
    if (nspace_hash != 0)
      return nspace_hash;
    nspace_hash = NewHash();
    String* mangled_name = 0;
    if (nspace == 0 || Len(nspace) == 0)
      mangled_name = NewString("__Global"); // C++ names can't start with "__ + capital letter"
    else
      mangled_name = Swig_name_mangle(nspace);
    String* cname = NewStringf("swig_%s", mangled_name);

    if (reg && nspace != 0 && Len(nspace) != 0 && Getattr(nspace_hash, "lua:no_reg") == 0) {
      // Split names into components
      List* components = Split(nspace, '.', -1);
      String *parent_path = NewString("");
      int len = Len(components);
      String* name = Copy(Getitem(components, len-1));
      for( int i = 0; i < len-1; i++ ) {
        if (i > 0)
          Printv(parent_path, NSPACE_SEPARATOR, NIL);
        String* item = Getitem(components, i);
        Printv(parent_path, item, NIL);
      }
      Printf(stdout, "Registering %s. User name %s. C-name %s, Parent is %s\n", mangled_name, name, cname, parent_path);
      Hash* parent = getNamespaceHash(parent_path, true);
      String* namespaces_tab = Getattr(parent, "namespaces");
      Printv(namespaces_tab, "&", cname, ",\n", NIL);
      Setattr(nspace_hash, "name", name);

      Delete(components);
      Delete(parent_path);
    } else if (!reg) // This namespace shouldn't be registered. Lets remember it
      Setattr(nspace_hash, "lua:no_reg", "1");


    Setattr(nspace_hash, "cname", cname);

    String *attr_tab = NewString("");
    String *attr_tab_name = NewStringf("swig_%s_attributes", mangled_name );
    String *attr_tab_decl = NewString("");
    Printv(attr_tab, "static swig_lua_attribute ", NIL);
    Printv(attr_tab, attr_tab_name, "[]", NIL);
    Printv(attr_tab_decl, attr_tab, ";\n", NIL);
    Printv(attr_tab, " = {\n", NIL);
    Setattr(nspace_hash, "attributes", attr_tab);
    Setattr(nspace_hash, "attributes:name", attr_tab_name);
    Setattr(nspace_hash, "attributes:decl", attr_tab_decl);

    String *methods_tab = NewString("");
    String *methods_tab_name = NewStringf("swig_%s_methods", mangled_name );
    String *methods_tab_decl = NewString("");
    if (elua_ltr || eluac_ltr) // In this case methods array also acts as namespace rotable
      Printf(methods_tab, "static LUA_REG_TYPE ");
    else
      Printf(methods_tab, "static swig_lua_method ");
    Printv(methods_tab, methods_tab_name, "[]");
    Printv(methods_tab_decl, methods_tab, ";\n", NIL);
    Printv(methods_tab, "= {\n", NIL);
    Setattr(nspace_hash, "methods", methods_tab );
    Setattr(nspace_hash, "methods:name", methods_tab_name );
    Setattr(nspace_hash, "methods:decl", methods_tab_decl );

    String *const_tab = NewString("");
    String *const_tab_name = NewStringf("swig_%s_constants", mangled_name );
    String *const_tab_decl = NewString("");
    if (elua_ltr || eluac_ltr) // In this case const array holds rotable with namespace constants
      Printf(const_tab, "static LUA_REG_TYPE ");
    else
      Printf(const_tab, "static swig_lua_const_info ");
    Printv(const_tab, const_tab_name, "[]", NIL);
    Printv(const_tab_decl, const_tab, ";", NIL);
    Printv(const_tab, "= {\n", NIL);
    Setattr(nspace_hash, "constants", const_tab );
    Setattr(nspace_hash, "constants:name", const_tab_name );
    Setattr(nspace_hash, "constants:decl", const_tab_decl );

    String *classes_tab = NewString("");
    String *classes_tab_name = NewStringf("swig_%s_classes", mangled_name );
    String *classes_tab_decl = NewString("");
    Printf(classes_tab, "static swig_lua_class* ");
    Printv(classes_tab, classes_tab_name, "[]");
    Printv(classes_tab_decl, classes_tab, ";", NIL);
    Printv(classes_tab, "= {\n", NIL);
    Setattr(nspace_hash, "classes", classes_tab );
    Setattr(nspace_hash, "classes:name", classes_tab_name );
    Setattr(nspace_hash, "classes:decl", classes_tab_decl );

    String* namespaces_tab = NewString("");
    String* namespaces_tab_name = NewStringf("swig_%s_namespaces", mangled_name );
    String* namespaces_tab_decl = NewString("");
    Printf(namespaces_tab, "static swig_lua_namespace* ");
    Printv(namespaces_tab, namespaces_tab_name, "[]");
    Printv(namespaces_tab_decl, namespaces_tab, ";", NIL);
    Printv(namespaces_tab, " = {\n", NIL);
    Setattr(nspace_hash, "namespaces", namespaces_tab );
    Setattr(nspace_hash, "namespaces:name", namespaces_tab_name );
    Setattr(nspace_hash, "namespaces:decl", namespaces_tab_decl );

    if (elua_ltr) {
      // TODO: add xxx:decl here too
      String *get_tab = NewString("");
      String *get_tab_name = NewStringf("swig_%s_get", mangled_name);
      Printv(get_tab, "const LUA_REG_TYPE ", get_tab_name, "[] = {\n", NIL);
      Setattr(nspace_hash, "get", get_tab);
      Setattr(nspace_hash, "get:name", get_tab_name);

      String *set_tab = NewString("");
      String *set_tab_name = NewStringf("swig_%s_set", mangled_name);
      Printv(set_tab, "const LUA_REG_TYPE ", set_tab_name, "[] = {\n", NIL);
      Setattr(nspace_hash, "set", set_tab);
      Setattr(nspace_hash, "set:name", set_tab_name);

      if (!eluac_ltr) {
        String* metatable_tab = NewString("");
        String* metatable_tab_name = NewStringf("swig_%s_meta", mangled_name);
        Printv(metatable_tab, "const LUA_REG_TYPE ", metatable_tab_name, "[] = {\n");
        Setattr(nspace_hash, "metatable", metatable_tab);
        Setattr(nspace_hash, "metatable:name", metatable_tab_name);
      }
    }
    String* key = 0;
    if (nspace != 0)
      key = Copy(nspace);
    Setattr(namespaces_hash, key?key:"", nspace_hash);

    Delete(mangled_name);
    return nspace_hash;
  }

  /* Functions add end markers {0,0,...,0} to all arrays, prints them to
   * output and marks hash as closed (lua:closed). Consequent attempts to
   * close same hash will result in error
   * closeNamespaceHash DOES NOT print structure that describes namespace, it only
   * prints array. You can use printNamespaceDefinition to print structure.
   * if "lua:no_namespaces" is set, then array for "namespaces" won't be printed
   * if "lua:no_classes" is set, then array for "classes" won't be printed
   * */
  void closeNamespaceHash(String *nspace, File *output)
  {
    Hash* nspace_hash = Getattr(namespaces_hash, nspace );
    assert(nspace_hash != 0);
    assert(Getattr(nspace_hash, "lua:closed") == 0);

    Setattr(nspace_hash, "lua:closed", "1");

    String* attr_tab = Getattr(nspace_hash, "attributes");
    Printf(attr_tab, "    {0,0,0}\n};\n");
    Printv(output, attr_tab, NIL);

    String* const_tab = Getattr(nspace_hash, "constants");
    String* const_tab_name = Getattr(nspace_hash, "constants:name");
    if (elua_ltr || eluac_ltr)
      Printv(const_tab, tab4, "{LNILKEY, LNILVAL}\n", "};\n", NIL);
    else
      Printf(const_tab, "    {0,0,0,0,0,0}\n};\n");
    Printv(output, const_tab, NIL);

    String* methods_tab = Getattr(nspace_hash, "methods");
    String* metatable_tab_name = Getattr(nspace_hash, "metatable:name");
    if (elua_ltr || eluac_ltr) {
      Printv(methods_tab, tab4, "{LSTRKEY(\"const\"), LROVAL(", const_tab_name, ")},\n", NIL);
      if (elua_ltr)
        Printv(methods_tab, tab4, "{LSTRKEY(\"__metatable\"), LROVAL(", metatable_tab_name, ")},\n", NIL);
    } else
      Printf(methods_tab, "    {0,0}\n};\n");
    Printv(output, methods_tab, NIL);

    if (!Getattr(nspace_hash, "lua:no_classes") ) {
      String* classes_tab = Getattr(nspace_hash, "classes");
      Printf(classes_tab, "    0\n};\n");
      Printv(output, classes_tab, NIL);
    }

    if (!Getattr(nspace_hash, "lua:no_namespaces") ) {
      String* namespaces_tab = Getattr(nspace_hash, "namespaces");
      Printf(namespaces_tab, "    0\n};\n");
      Printv(output, namespaces_tab, NIL);
    }
    if (elua_ltr) {
      String *get_tab = Getattr(nspace_hash, "get");
      String *get_tab_name = Getattr(nspace_hash, "get:name");
      String *set_tab = Getattr(nspace_hash, "set");
      String *set_tab_name = Getattr(nspace_hash, "set:name");
      Printv(get_tab, tab4, "{LNILKEY, LNILVAL}\n};\n", NIL);
      Printv(set_tab, tab4, "{LNILKEY, LNILVAL}\n};\n", NIL);
      Printv(output, get_tab, NIL);
      Printv(output, set_tab, NIL);

      String *metatable_tab = Getattr(nspace_hash, "metatable");
      assert(metatable_tab != 0);
      Printv(metatable_tab, tab4, "{LSTRKEY(\"__index\"), LFUNCVAL(SWIG_Lua_module_get)},\n", NIL);
      Printv(metatable_tab, tab4, "{LSTRKEY(\"__newindex\"), LFUNCVAL(SWIG_Lua_module_set)},\n", NIL);
      Printv(metatable_tab, tab4, "{LSTRKEY(\".get\"), LROVAL(", get_tab_name, ")},\n", NIL);
      Printv(metatable_tab, tab4, "{LSTRKEY(\".set\"), LROVAL(", set_tab_name, ")},\n", NIL);
      Printv(metatable_tab, tab4, "{LNILKEY, LNILVAL}\n};\n", NIL);
      Printv(output, metatable_tab, NIL);
    }
    Printv(output, "\n", NIL);
  }

  static int compareByLen( const DOH* f, const DOH* s) { return Len(s) - Len(f); }
  // Recursively close all non-closed namespaces. Prints data to dataOutput,
  // forward declaration to declOutput
  void closeNamespaces(File *dataOutput, File *declOutput)
  {
    Iterator ki = First(namespaces_hash);
    List* to_close = NewList();
    while (ki.key) {
      if (Getattr(ki.item, "lua:closed") == 0)
        Append(to_close, ki.key);
      ki = Next(ki);
    }
    SortList(to_close, &compareByLen);
    int len = Len(to_close);
    for( int i = 0; i < len; i++ ) {
      String* key = Getitem(to_close,i);
      closeNamespaceHash(key, dataOutput);
      Hash* nspace = Getattr(namespaces_hash, key);
      String* cname = Getattr(nspace, "cname"); // cname - name of the C structure that describes namespace
      assert(cname != 0);
      Printf( stdout, "Closing namespace %s\n", cname );
      //printNamespaceForwardDeclaration( ki.key, declOutput ); TODO: REMOVE
      Printv(dataOutput, "static swig_lua_namespace ", cname, " = ", NIL);
      String *name = 0; // name - name of the namespace as it should be visible in Lua
      if (DohLen(key) == 0) // This is global module
        name = module;
      else
        name = Getattr(nspace, "name");
      assert(name != 0);
      printNamespaceDefinition( key, name, dataOutput );
      Printv(dataOutput, ";\n\n", NIL);
    }
    Delete(to_close);
  }

  // This function prints to output a definition of namespace in
  // form of swig_lua_namespace: { attr_array, methods_array, ... , namespaces_array }.
  // You can call this function as many times as necessary.
  // 'name' is a user-visible name that this namespace will have in Lua. It shouldn't
  // be fully qualified name, just it's own name.
  void printNamespaceDefinition(String *nspace, String* name, File *output)
  {
    // TODO: Fix for get_tab/set_tab things (elua_ltr)
    Hash *nspace_hash = getNamespaceHash(nspace, false);
    String *null_string = NewString("0");
    String *attr_tab_name = Getattr(nspace_hash, "attributes:name");
    String *methods_tab_name = Getattr(nspace_hash, "methods:name");
    String *const_tab_name = Getattr(nspace_hash, "constants:name");
    String *classes_tab_name = Getattr(nspace_hash, "classes:name");
    String *namespaces_tab_name = Getattr(nspace_hash, "namespaces:name");
    bool has_classes = Getattr(nspace_hash, "lua:no_classes") == 0;
    bool has_namespaces = Getattr(nspace_hash, "lua:no_namespaces") == 0;

    Printf(output, "{\"%s\", %s, %s, %s, %s, %s}",
        name,
        methods_tab_name,
        attr_tab_name,
        const_tab_name,
        (has_classes)?classes_tab_name:null_string,
        (has_namespaces)?namespaces_tab_name:null_string
        );
  }

  // This function prints forward declaration of namespace itself and all its arrays
  // TODO: REMOVE
  void printNamespaceForwardDeclaration(String* nspace, File* output)
  {
    Hash *nspace_hash = getNamespaceHash(nspace, false);
    String *attr_tab_decl = Getattr(nspace_hash, "attributes:decl");
    String *methods_tab_decl = Getattr(nspace_hash, "methods:decl");
    String *const_tab_decl = Getattr(nspace_hash, "constants:decl");
    String *classes_tab_decl = Getattr(nspace_hash, "classes:decl");
    String *namespaces_tab_decl = Getattr(nspace_hash, "declspaces:decl");
    bool has_classes = Getattr(nspace_hash, "lua:no_classes") == 0;
    bool has_namespaces = Getattr(nspace_hash, "lua:no_namespaces") == 0;
    Printv( output, attr_tab_decl, "\n", NIL );
    Printv( output, methods_tab_decl, "\n", NIL );
    Printv( output, const_tab_decl, "\n", NIL );
    if( has_classes )
      Printv( output, classes_tab_decl, "\n", NIL );
    if( has_namespaces )
      Printv( output, namespaces_tab_decl, "\n", NIL );

    Printf( output, "static swig_lua_namespace %s;\n", Getattr(nspace_hash, "cname") );
  }

  // Our implementation of addSymbol. Determines scope correctly, then calls Language::addSymbol
  int luaAddSymbol(const String *s, const Node *n) {
    String* scope = 0;
    // If ouside class, than NSpace is used.
    if( !getCurrentClass())
      scope = getNSpace();
    else {
      // If inside class, then either class static namespace or class fully qualified name is used
      assert(!current[NO_CPP]);
      if(current[STATIC_FUNC] || current[STATIC_VAR] || current[STATIC_CONST] ) {
          scope = class_static_nspace;
      } else if(current[MEMBER_VAR] || current[CLASS_CONST] ||  current[CONSTRUCTOR] || current[DESTRUCTOR]
          || current[MEMBER_FUNC] ) {
          scope = class_fq_symname;
      } else {
          assert(0); // Can't be. Implementation error
      }
      assert(scope != 0);
    }
    return Language::addSymbol(s,n,scope);
  }

  // Overload. Enforces given scope. Actually, it simply forwards call to Language::addSymbol
  int luaAddSymbol(const String*s, const Node*n,  const_String_or_char_ptr scope) {
    return Language::addSymbol(s,n,scope);
  }

  // Function creates fully qualified name of given symbol. Current NSpace and current class
  // are used
  String* fully_qualified_name(const_String_or_char_ptr name)
  {
    assert(name != 0);
    String* scope= 0;
    if( getCurrentClass() )
      scope = class_fq_symname;
    else
      scope = getNSpace();

    String *fqname = 0;
    if( scope )
      fqname = NewStringf("%s::%s",scope,name);
    else
      fqname = Copy(name);

    return fqname;
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
  {"-lua",       swig_lua,       "Lua"},	// this is my code
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

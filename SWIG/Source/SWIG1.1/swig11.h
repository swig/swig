/* -----------------------------------------------------------------------------
 * swig11.h
 *
 *     Main header file for the SWIG1.1 core.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2000.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.
 *
 * $Header$
 * ----------------------------------------------------------------------------- */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "swigver.h"

extern "C" {
#include "swig.h"
}

/* Global variables.   Needs to be cleaned up */

#ifdef MACSWIG
#define Status Swig_Status
#undef stderr
#define stderr swig_log
extern  FILE   *swig_log;
#endif

extern  FILE      *f_runtime;                       // Runtime code
extern  FILE      *f_header;                        // Headers
extern  FILE      *f_wrappers;                      // Wrappers
extern  FILE      *f_init;                          // Initialization code
extern  FILE      *f_input;
extern  char      InitName[256];
extern  char      LibDir[512];                      // Library directory
//extern  char     **InitNames;                       // List of other init functions
extern  int       Status;                           // Variable creation status
extern  int       yyparse();
extern  int       line_number;
extern  int       start_line;
extern  char     *input_file;                       // Current input file
extern  int       CPlusPlus;                        // C++ mode
extern  int       ObjC;                             // Objective-C mode
extern  int       ObjCClass;                        // Objective-C style class
extern  int       AddMethods;                       // AddMethods mode
extern  int       NewObject;                        // NewObject mode
extern  int       Inline;                           // Inline mode
extern  int       NoInclude;                        // NoInclude flag
extern  char     *typemap_lang;                     // Current language name
extern  int       error_count;
extern  char      output_dir[512];                  // Output directory
extern  int       Verbose;
extern  int       IsVirtual;

#define FatalError()   if ((error_count++) > 20) { fprintf(stderr,"Confused by earlier errors. Bailing out\n"); SWIG_exit(1); }

/* Miscellaneous stuff */

#define  STAT_READONLY  1
#define  MAXSCOPE       16

#define  tab2   "  "
#define  tab4   "    "
#define  tab8   "        "

// Modes for different types of inheritance

#define INHERIT_FUNC       0x1
#define INHERIT_VAR        0x2
#define INHERIT_CONST      0x4
#define INHERIT_ALL        (INHERIT_FUNC | INHERIT_VAR | INHERIT_CONST)

struct Pragma {
  void  *filename;
  int   lineno;
  void  *lang;
  void  *name;
  void  *value;
  Pragma  *next;
};

/************************************************************************
 * class language:
 *
 * This class defines the functions that need to be supported by the
 * scripting language being used.    The translator calls these virtual
 * functions to output different types of code for different languages.
 *
 * By implementing this using virtual functions, hopefully it will be
 * easy to support different types of scripting languages.
 *
 * The following functions are used :
 *
 *    parse_args(argc, argv)
 *           Parse the arguments used by this language.
 *
 *    parse()
 *           Entry function that starts parsing of a particular language
 *
 *    create_function(fname, iname, rtype, parmlist)
 *           Creates a function wrappper.
 *
 *    link_variable(vname, iname, type)
 *           Creates a link to a variable.
 *
 *    declare_const(cname, type, value)
 *           Creates a constant (for #define).
 *
 *    initialize(char *fn)
 *           Produces initialization code.
 *
 *    headers()
 *           Produce code for headers
 *
 *    close()
 *           Close up files
 *
 *    usage_var(iname,type,string)
 *           Produces usage string for variable declaration.
 *
 *    usage_func(iname,rttype, parmlist, string)
 *           Produces usage string for function declaration.
 *
 *    usage_const(iname, type, value, string)
 *           Produces usage string for constants
 *
 *    set_module(char *modname)
 *           Sets the name of the module (%module directive)
 *
 *    set_init(char *initname)
 *           Sets name of initialization function (an alternative to set_module)
 *    add_native(char *name, char *funcname);
 *           Adds a native wrapper function to the initialize process
 *
 * --- C++ Functions ---
 *
 *    These functions are optional additions to any of the target
 *    languages.   SWIG handles inheritance, symbol tables, and other
 *    information.
 *
 *    cpp_open_class(char *classname, char *rname)
 *          Open a new C++ class definition.
 *    cpp_close_class(char *)
 *          Close current C++ class
 *    cpp_member_func(char *name, char *rname, DataType *rt, ParmList *l)
 *          Create a C++ member function
 *    cpp_constructor(char *name, char *iname, ParmList *l)
 *          Create a C++ constructor.
 *    cpp_destructor(char *name, char *iname)
 *          Create a C++ destructor
 *    cpp_variable(char *name, char *iname, DataType *t)
 *          Create a C++ member data item.
 *    cpp_declare_const(char *name, char *iname, int type, char *value)
 *          Create a C++ constant.
 *    cpp_inherit(char *baseclass)
 *          Inherit data from baseclass.
 *    cpp_static_func(char *name, char *iname, DataType *t, ParmList *l)
 *          A C++ static member function.
 *    cpp_static_var(char *name, char *iname, DataType *t)
 *          A C++ static member data variable.
 *
 *************************************************************************/

class Language {
public:
  virtual void parse_args(int argc, char *argv[]) = 0;
  virtual void parse() = 0;
  virtual void create_function(char *, char *, DataType *, ParmList *) = 0;
  virtual void link_variable(char *, char *, DataType *)  = 0;
  virtual void declare_const(char *, char *, DataType *, char *) = 0;
  virtual void initialize(void) = 0;
  virtual void headers(void) = 0;
  virtual void close(void) = 0;
  virtual void set_module(char *mod_name,char **mod_list) = 0;
  virtual void set_init(char *init_name);
  virtual void add_native(char *name, char *iname, DataType *t, ParmList *l);
  virtual void add_typedef(DataType *t, char *name);
  virtual void create_command(char *cname, char *iname);

  //
  // C++ language extensions.
  // You can redefine these, or use the defaults below
  //

  virtual void cpp_member_func(char *name, char *iname, DataType *t, ParmList *l);
  virtual void cpp_constructor(char *name, char *iname, ParmList *l);
  virtual void cpp_destructor(char *name, char *newname);
  virtual void cpp_open_class(char *name, char *rename, char *ctype, int strip);
  virtual void cpp_close_class();
  virtual void cpp_cleanup();
  virtual void cpp_inherit(char **baseclass, int mode = INHERIT_ALL);
  virtual void cpp_variable(char *name, char *iname, DataType *t);
  virtual void cpp_static_func(char *name, char *iname, DataType *t, ParmList *l);
  virtual void cpp_declare_const(char *name, char *iname, DataType *type, char *value);
  virtual void cpp_static_var(char *name, char *iname, DataType *t);
  virtual void cpp_pragma(Pragma *plist);

  // Pragma directive

  virtual void pragma(char *, char *, char *);

  // Declaration of a class, but not a full definition

  virtual void cpp_class_decl(char *, char *, char *);

  // Import directive

  virtual void import(char *filename);

};

/* Emit functions */

extern  void  emit_func_call(char *, DataType *, ParmList *, FILE *);
extern  void  emit_set_get(char *, char *, DataType *);
extern  void  emit_set_action(DOHString_or_char *decl);

extern  int   SWIG_main(int, char **, Language *);

// Some functions for emitting some C++ helper code

extern void cplus_emit_member_func(char *classname, char *classtype, char *classrename,
                                   char *mname, char *mrename, DataType *type, ParmList *l,
                                   int mode);

extern void cplus_emit_static_func(char *classname, char *classtype, char *classrename,
                                   char *mname, char *mrename, DataType *type, ParmList *l,
                                   int mode);

extern void cplus_emit_destructor(char *classname, char *classtype, char *classrename,
                                  char *name, char *iname, int mode);

extern void cplus_emit_constructor(char *classname, char *classtype, char *classrename,
                                   char *name, char *iname, ParmList *l, int mode);

extern void cplus_emit_variable_get(char *classname, char *classtype, char *classrename,
				    char *name, char *iname, DataType *type, int mode);

extern void cplus_emit_variable_set(char *classname, char *classtype, char *classrename,
				    char *name, char *iname, DataType *type, int mode);

extern char *cplus_base_class(char *name);

/* These are in the new core */

extern "C" {
  /* Option processing */
  extern void Swig_init_args(int argc, char **);
  extern void Swig_mark_arg(int n);
  extern void Swig_check_options();
  extern void Swig_arg_error();
  extern void *Preprocessor_define(void *, int);
  extern int  Swig_insert_file(const void *filename, void *outfile);
  extern FILE *Swig_open(const void *filename);
  extern char *Swig_copy_string(const char *s);
}

// Misc

extern  int   emit_args(DataType *, ParmList *, Wrapper *f);
extern  void  emit_func_call(char *, DataType *, ParmList *, Wrapper *f);
extern  void  SWIG_exit(int);

// -----------------------------------------------------------------------
// Typemap support
// -----------------------------------------------------------------------

extern void    typemap_register(char *op, char *lang, DataType *type, char *pname, char *code, ParmList *l = 0);
extern void    typemap_register(char *op, char *lang, char *type, char *pname, char *code,ParmList *l = 0);
extern void    typemap_register_default(char *op, char *lang, int type, int ptr, char *arraystr, char *code, ParmList *l = 0);
extern char   *typemap_lookup(char *op, char *lang, DataType *type, char *pname, char *source, char *target,
                              Wrapper *f = 0);
extern void    typemap_clear(char *op, char *lang, DataType *type, char *pname);
extern void    typemap_copy(char *op, char *lang, DataType *stype, char *sname, DataType *ttype, char *tname);
extern char   *typemap_check(char *op, char *lang, DataType *type, char *pname);
extern void    typemap_apply(DataType *tm_type, char *tmname, DataType *type, char *pname);
extern void    typemap_clear_apply(DataType *type, char *pname);
extern int     check_numopt(ParmList *);


// -----------------------------------------------------------------------
// Code fragment support
// -----------------------------------------------------------------------

extern void    fragment_register(char *op, char *lang, char *code);
extern char   *fragment_lookup(char *op, char *lang, int age);
extern void    fragment_clear(char *op, char *lang);



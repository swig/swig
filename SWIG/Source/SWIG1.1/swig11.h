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
extern  char     *copy_string(char *);
extern  char      output_dir[512];                  // Output directory
extern  int       Verbose;

#define FatalError()   if ((error_count++) > 20) { fprintf(stderr,"Confused by earlier errors. Bailing out\n"); SWIG_exit(1); }

/* Miscellaneous stuff */

#define  STAT_READONLY  1
#define  MAXSCOPE       16

// -----------------------------------------------------------------------
// String class
// -----------------------------------------------------------------------

class String {
private:
  void  *str;               // String object
public:
  String();
  String(const char *s);
  ~String();
  char  *get() const;
  friend String& operator<<(String&,const char *s);
  friend String& operator<<(String&,const int);
  friend String& operator<<(String&,const char);
  friend String& operator<<(String&,const String&);
  friend String& operator>>(const char *s, String&);
  friend String& operator>>(const String&,String&);
  String& operator=(const char *);
  void   replace(const char *token, const char *rep);
  void   replaceid(const char *id, const char *rep);
  void   strip();
};

#define  tab2   "  "
#define  tab4   "    "
#define  tab8   "        "

/************************************************************************
 * class DataType
 *
 * Defines the basic datatypes supported by the translator.
 *
 ************************************************************************/

#define    T_INT       1
#define    T_SHORT     2
#define    T_LONG      3
#define    T_UINT      4
#define    T_USHORT    5
#define    T_ULONG     6
#define    T_UCHAR     7
#define    T_SCHAR     8
#define    T_BOOL      9
#define    T_DOUBLE    10
#define    T_FLOAT     11
#define    T_CHAR      12
#define    T_USER      13
#define    T_VOID      14
#define    T_SYMBOL    98
#define    T_ERROR     99

// These types are now obsolete, but defined for backwards compatibility

#define    T_SINT      90
#define    T_SSHORT    91
#define    T_SLONG     92

// Class for storing data types

#define MAX_NAME 96

class DataType {
public:
  int         type;          // SWIG Type code
  char        name[MAX_NAME];      // Name of type
  char        is_pointer;    // Is this a pointer?
  char        implicit_ptr;  // Implicit ptr
  char        is_reference;  // A C++ reference type
  char        status;        // Is this datatype read-only?
  char        *qualifier;    // A qualifier string (ie. const).
  char        *arraystr;     // String containing array part
  int         id;            // type identifier (unique for every type).
  DataType();
  DataType(DataType *);
  DataType(int type);
  ~DataType();
  void        primitive();   // Turn a datatype into its primitive type
  char       *print_type();  // Return string containing datatype
  char       *print_full();  // Return string with full datatype
  char       *print_cast();  // Return string for type casting
  char       *print_mangle();// Return mangled version of type
  char       *print_real(char *local=0);  // Print the real datatype (as far as we can determine)
  char       *print_arraycast(); // Prints an array cast
  char       *print_mangle_default(); // Default mangling scheme

  // Array query functions
  int        array_dimensions();   // Return number of array dimensions (if any)
  char       *get_dimension(int);  // Return string containing a particular dimension
  char       *get_array();         // Returns the array string for a datatype

  // typedef support

  void       typedef_add(char *name, int mode = 0); // Add this type to typedef list
  void       typedef_resolve(int level = 0);        // See if this type has been typedef'd
  void       typedef_replace();                     // Replace this type with it's original type
static int   is_typedef(char *name);                // See if this is a typedef
  void       typedef_updatestatus(int newstatus);   // Change status of a typedef
static void  init_typedef(void);                    // Initialize typedef manager
static void  merge_scope(void *h);                  // Functions for managing scoping of datatypes
static void  new_scope(void *h = 0);
static void  *collapse_scope(char *);
  void       remember();
static void       record_base(char *derived, char *base);
};

#define STAT_REPLACETYPE   2

/************************************************************************
 * class Parm
 *
 * Structure for holding information about function parameters
 *
 *      CALL_VALUE  -->  Call by value even though function parameter
 *                       is a pointer.
 *                          ex :   foo(&_arg0);
 *      CALL_REF    -->  Call by reference even though function parameter
 *                       is by value
 *                          ex :   foo(*_arg0);
 *
 ************************************************************************/

#define CALL_VALUE      0x01
#define CALL_REFERENCE  0x02
#define CALL_OUTPUT     0x04

struct Parm {
  DataType   *t;                // Datatype of this parameter
  int        call_type;         // Call type (value or reference or value)
  char       *name;             // Name of parameter (optional)
  char       *defvalue;         // Default value (as a string)
  int        ignore;            // Ignore flag
  char       *objc_separator;   // Parameter separator for Objective-C
  Parm(DataType *type, char *n);
  Parm(Parm *p);
  ~Parm();
};

// -------------------------------------------------------------
// class ParmList
//
// This class is used for manipulating parameter lists in
// function and type declarations.
// -------------------------------------------------------------

#define MAXPARMS   16

class ParmList {
private:
  int   maxparms;                 // Max parms possible in current list
  Parm  **parms;                  // Pointer to parms array
  void  moreparms();              // Increase number of stored parms
  int    current_parm;            // Internal state for get_first,get_next
public:
  int   nparms;                   // Number of parms in list
  void  append(Parm *p);          // Append a parameter to the end
  void  insert(Parm *p, int pos); // Insert a parameter into the list
  void  del(int pos);             // Delete a parameter at position pos
  int   numopt();                 // Get number of optional arguments
  int   numarg();                 // Get number of active arguments
  Parm *get(int pos);             // Get the parameter at position pos
  Parm &operator[](int);          // An alias for get().
  ParmList();
  ParmList(ParmList *l);
  ~ParmList();

  // Keep this for backwards compatibility

  Parm  *get_first();              // Get first parameter from list
  Parm  *get_next();               // Get next parameter from list
  void   print_types(FILE *f);     // Print list of datatypes
  void   print_types(String &f);   // Generate list of datatypes.
  void   print_args(FILE *f);      // Print argument list
  void   sub_parmnames(String &s); // Remaps real parameter names in code fragment
};

// Modes for different types of inheritance

#define INHERIT_FUNC       0x1
#define INHERIT_VAR        0x2
#define INHERIT_CONST      0x4
#define INHERIT_ALL        (INHERIT_FUNC | INHERIT_VAR | INHERIT_CONST)

struct Pragma {
  Pragma() { next = 0; }
  String  filename;
  int     lineno;
  String  lang;
  String  name;
  String  value;
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
 *    type_mangle(DataType *t);
 *           Mangles the name of a datatype.
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
  virtual char *type_mangle(DataType *t) {
    return t->print_mangle_default();
  }
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

extern  void  emit_extern_var(char *, DataType *, int, FILE *);
extern  void  emit_extern_func(char *, DataType *, ParmList *, int, FILE *);
extern  void  emit_func_call(char *, DataType *, ParmList *, FILE *);

extern  void  emit_set_get(char *, char *, DataType *);
extern  void  emit_ptr_equivalence(FILE *);
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
}

// -----------------------------------------------------------------------
//  Class for Creating Wrapper Functions
// -----------------------------------------------------------------------

class WrapperFunction {
private:
  void    *h;
  void    *localh;
public:
  WrapperFunction();
  ~WrapperFunction();
  String  def;
  String  locals;
  String  code;
  String  init;
  void    print(FILE *f);
  void    print(String &f);
  void    add_local(char *type, char *name, char *defvalue = 0);
  char   *new_local(char *type, char *name, char *defvalue = 0);
static    void    del_type(void *obj);
};

extern  int   emit_args(DataType *, ParmList *, WrapperFunction &f);
extern  void  emit_func_call(char *, DataType *, ParmList *, WrapperFunction &f);
extern  void  SWIG_exit(int);

// -----------------------------------------------------------------------
// Typemap support
// -----------------------------------------------------------------------

extern void    typemap_register(char *op, char *lang, DataType *type, char *pname, char *code, ParmList *l = 0);
extern void    typemap_register(char *op, char *lang, char *type, char *pname, char *code,ParmList *l = 0);
extern void    typemap_register_default(char *op, char *lang, int type, int ptr, char *arraystr, char *code, ParmList *l = 0);
extern char   *typemap_lookup(char *op, char *lang, DataType *type, char *pname, char *source, char *target,
                              WrapperFunction *f = 0);
extern void    typemap_clear(char *op, char *lang, DataType *type, char *pname);
extern void    typemap_copy(char *op, char *lang, DataType *stype, char *sname, DataType *ttype, char *tname);
extern char   *typemap_check(char *op, char *lang, DataType *type, char *pname);
extern void    typemap_apply(DataType *tm_type, char *tmname, DataType *type, char *pname);
extern void    typemap_clear_apply(DataType *type, char *pname);


// -----------------------------------------------------------------------
// Code fragment support
// -----------------------------------------------------------------------

extern void    fragment_register(char *op, char *lang, char *code);
extern char   *fragment_lookup(char *op, char *lang, int age);
extern void    fragment_clear(char *op, char *lang);


extern  void  emit_ptr_equivalence(WrapperFunction &);






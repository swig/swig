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
#endif

#define PLAIN_VIRTUAL   1
#define PURE_VIRTUAL    2
#define SUPER_VIRTUAL   3

extern  FILE      *f_runtime;                       // Runtime code
extern  DOH       *f_header;                        // Headers
extern  DOH       *f_wrappers;                      // Wrappers
extern  DOH       *f_init;                          // Initialization code
extern  FILE      *f_input;
extern  char      LibDir[512];                      // Library directory
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

#define FatalError()   if ((error_count++) > 20) { fprintf(stderr,"Confused by earlier errors. Bailing out\n"); SWIG_exit (EXIT_FAILURE); }

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

/* Language Class */
class Language {
public:
  virtual void parse_args(int argc, char *argv[]) = 0;
  virtual void parse() = 0;

  /* NEW API */
  virtual void function(DOH *node) = 0;
  virtual void variable(DOH *node) = 0;
  virtual void constant(DOH *node) = 0;
  virtual void nativefunction(DOH *node);

  /* C++ handling */
  virtual void cpp_memberfunction(DOH *node);
  virtual void cpp_constructor(DOH *node);
  virtual void cpp_destructor(DOH *node);
  virtual void cpp_variable(DOH *node);
  virtual void cpp_staticfunction(DOH *node);
  virtual void cpp_constant(DOH *node);
  virtual void cpp_staticvariable(DOH *node);

  /* OLD API */

  virtual void initialize(void) = 0;
  virtual void close(void) = 0;
  virtual void set_module(char *mod_name) = 0;
  virtual void add_typedef(SwigType *t, char *name);
  virtual void create_command(char *cname, char *iname);

  virtual void cpp_open_class(char *name, char *rename, char *ctype, int strip);
  virtual void cpp_close_class();
  virtual void cpp_cleanup();
  virtual void cpp_inherit(char **baseclass, int mode = INHERIT_ALL);
  virtual void cpp_pragma(Pragma *plist);
  virtual void pragma(char *, char *, char *);

  // Declaration of a class, but not a full definition

  virtual void cpp_class_decl(char *, char *, char *);

  // Import directive
  virtual void import(char *filename);

};

/* Emit functions */

extern  void  new_create_function(char *, char *, SwigType *, ParmList *);
extern  void  emit_set_get(DOH *node);
extern  void  emit_set_action(DOHString_or_char *decl);

extern  int   SWIG_main(int, char **, Language *);

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

extern  int   emit_args(DOH *node, Wrapper *f);
extern  void  emit_func_call(DOH *node, Wrapper *f);
extern  void  SWIG_exit(int);           /* use EXIT_{SUCCESS,FAILURE} */
extern  int   check_numopt(ParmList *);
extern  void  SWIG_config_file(const String_or_char *);

/* swig11.h ends here */









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

/* Global variables.  */

extern  FILE      *f_runtime;                       // Runtime code
extern  DOH       *f_header;                        // Headers
extern  DOH       *f_wrappers;                      // Wrappers
extern  DOH       *f_init;                          // Initialization code
extern  FILE      *f_input;
extern  int       CPlusPlus;                        // C++ mode
extern  int       AddMethods;                       // AddMethods mode
extern  int       NewObject;                        // NewObject mode
extern  int       NoInclude;                        // NoInclude flag
extern  char      output_dir[512];                  // Output directory
extern  int       Verbose;
extern  int       ReadOnly;                         // Read only mode
extern  int       Native;                           // Native mode

/* Miscellaneous stuff */

#define  tab4   "    "
#define  tab8   "        "

// Modes for different types of inheritance

#define INHERIT_FUNC       0x1
#define INHERIT_VAR        0x2
#define INHERIT_CONST      0x4
#define INHERIT_ALL        (INHERIT_FUNC | INHERIT_VAR | INHERIT_CONST)

/* Language Class */
class Language {
public:
  virtual void parse_args(int argc, char *argv[]) = 0;
  virtual void initialize(String *modname) = 0;
  virtual void close(void) = 0;
  virtual void import(String *modname);

  /* Basic function, variable, constant API (required) */
  virtual void function(DOH *node) = 0;
  virtual void variable(DOH *node) = 0;
  virtual void constant(DOH *node) = 0;
  virtual void nativefunction(DOH *node);
  virtual void create_command(String *cname, String *iname);

  /* Optional C++ handling */
  virtual void cpp_open_class(DOH *node);
  virtual void cpp_memberfunction(DOH *node);
  virtual void cpp_constructor(DOH *node);
  virtual void cpp_destructor(DOH *node);
  virtual void cpp_variable(DOH *node);
  virtual void cpp_staticfunction(DOH *node);
  virtual void cpp_constant(DOH *node);
  virtual void cpp_staticvariable(DOH *node);
  virtual void cpp_close_class();

  virtual void cpp_class_decl(DOH *node);
  virtual void cpp_inherit(List *bases, int mode = INHERIT_ALL);

  /* Miscellaneous features */

  virtual void add_typedef(SwigType *t, String *name);
  virtual void pragma(DOH *node);

};

/* Emit functions */

extern  void  new_create_function(char *, char *, SwigType *, ParmList *);
extern  void  emit_set_get(DOH *node);
extern  void  emit_set_action(DOHString_or_char *decl);

/* These are in the new core */
extern "C" void *Preprocessor_define(void *, int);

// Misc

extern  int   emit_args(DOH *node, Wrapper *f);
extern  void  emit_func_call(DOH *node, Wrapper *f);
extern  int   check_numopt(ParmList *);
extern  void  SWIG_config_file(const String_or_char *);

/* C++ utility functions */
extern int cplus_check_abstract(DOH *node);

extern Language *lang;

/* swig11.h ends here */









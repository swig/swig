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
extern DOH  *Preprocessor_define(DOHString_or_char *str, int swigmacro);
}

#define NOT_VIRTUAL     0
#define PLAIN_VIRTUAL   1
#define PURE_VIRTUAL    2

extern  int       ReadOnly;
extern  char     *input_file;
extern  int       line_number;
extern  int       start_line;
extern  int       CPlusPlus;                        // C++ mode
extern  int       AddMethods;                       // AddMethods mode
extern  int       NewObject;                        // NewObject mode
extern  int       NoInclude;                        // NoInclude flag
extern  int       error_count;
extern  int       Verbose;
extern  int       IsVirtual;
extern  int       Overloaded;

#define FatalError()   if ((error_count++) > 20) { fprintf(stderr,"Confused by earlier errors. Bailing out\n"); SWIG_exit (EXIT_FAILURE); }

/* Miscellaneous stuff */

#define  tab2   "  "
#define  tab4   "    "
#define  tab8   "        "

/************************************************************************
 * class language:
 *
 * This class defines the functions that need to be supported by the
 * scripting language being used.    The translator calls these virtual
 * functions to output different types of code for different languages.
 *************************************************************************/

class Language {
public:

  /* ----------------------------------------------------------------------
   * New interface.  SWIG-1.3.7 and newer versions
   * ---------------------------------------------------------------------- */

  virtual void main(int argc, char *argv[]) = 0;
  virtual void top(Node *n);
  
  /* SWIG directives */
  
  virtual void addmethodsDirective(Node *n);
  virtual void applyDirective(Node *n);
  virtual void clearDirective(Node *n);
  virtual void constantDirective(Node *n);
  virtual void exceptDirective(Node *n);
  virtual void importDirective(Node *n);
  virtual void includeDirective(Node *n);
  virtual void insertDirective(Node *n);
  virtual void moduleDirective(Node *n);
  virtual void nativeDirective(Node *n);
  virtual void newDirective(Node *n);
  virtual void pragmaDirective(Node *n);
  virtual void typemapDirective(Node *n);
  virtual void typemapcopyDirective(Node *n);
  virtual void typesDirective(Node *n);

  /* C/C++ parsing */
  
  virtual void cDeclaration(Node *n);
  virtual void externDeclaration(Node *n);
  virtual void enumDeclaration(Node *n);
  virtual void enumvalueDeclaration(Node *n);
  virtual void classDeclaration(Node *n);
  virtual void classforwardDeclaration(Node *n);
  virtual void constructorDeclaration(Node *n);
  virtual void destructorDeclaration(Node *n);
  virtual void operatorDeclaration(Node *n);
  virtual void accessDeclaration(Node *n);

  /* Low-level code generation */
  
  virtual void constantWrapper(Node *n);
  virtual void variableWrapper(Node *n);
  virtual void functionWrapper(Node *n);

  /* ----------------------------------------------------------------------
   !! Deprecated interface.   It is only provided for backwards
   !! compatibility with old language modules.  Use the functions above
   !! instead
   * ----------------------------------------------------------------------*/

  virtual void create_function(char *, char *, SwigType *, ParmList *);
  virtual void link_variable(char *, char *, SwigType *);
  virtual void declare_const(char *, char *, SwigType *, char *);
  virtual void create_command(char *cname, char *iname);

  virtual void add_native(char *name, char *iname, SwigType *t, ParmList *l);
  virtual void add_typedef(SwigType *t, char *name);

  virtual void cpp_member_func(char *name, char *iname, SwigType *t, ParmList *l);
  virtual void cpp_constructor(char *name, char *iname, ParmList *l);
  virtual void cpp_destructor(char *name, char *newname);
  virtual void cpp_open_class(char *name, char *rename, char *ctype, int strip);
  virtual void cpp_close_class();
  virtual void cpp_inherit(char **baseclass, int mode = 0);
  virtual void cpp_variable(char *name, char *iname, SwigType *t);
  virtual void cpp_static_func(char *name, char *iname, SwigType *t, ParmList *l);
  virtual void cpp_declare_const(char *name, char *iname, SwigType *type, char *value);
  virtual void cpp_static_var(char *name, char *iname, SwigType *t);

  // Pragma directive

  virtual void pragma(char *, char *, char *);

  // Declaration of a class, but not a full definition
  virtual void cpp_class_decl(char *, char *, char *);

  // Import directive

  virtual void import_start(char *modulename);    /* Import a new module */
  virtual void import_end();                      /* Done with import    */
  virtual int  validIdentifier(String *s);        /* valid identifier? */
};

/* Emit functions */

extern  void  emit_func_call(char *, SwigType *, ParmList *, FILE *);
extern  void  emit_set_get(char *, char *, SwigType *);
extern  void  emit_set_action(DOHString_or_char *decl);
extern  int   SWIG_main(int, char **, Language *);

// Misc

extern  int   emit_args(SwigType *, ParmList *, Wrapper *f);
extern  void  emit_func_call(char *, SwigType *, ParmList *, Wrapper *f);
extern  void  SWIG_exit(int);           /* use EXIT_{SUCCESS,FAILURE} */
extern int    check_numopt(ParmList *);
extern void   SWIG_config_file(const String_or_char *);
extern "C" void  SWIG_typemap_lang(const char *);
extern void   SWIG_library_directory(const char *);

extern int    emit_num_arguments(ParmList *);
extern int    emit_num_required(ParmList *);
extern void   emit_attach_parmmaps(ParmList *, Wrapper *f);

/* swig11.h ends here */



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
extern  int       Abstract;

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

  /* Parse command line options */

  virtual void main(int argc, char *argv[]);

  /* Top of the parse tree */

  virtual int  top(Node *n);
  
  /* SWIG directives */
  
  virtual int addmethodsDirective(Node *n);
  virtual int applyDirective(Node *n);
  virtual int clearDirective(Node *n);
  virtual int constantDirective(Node *n);
  virtual int exceptDirective(Node *n);
  virtual int importDirective(Node *n);
  virtual int includeDirective(Node *n);
  virtual int insertDirective(Node *n);
  virtual int moduleDirective(Node *n);
  virtual int nativeDirective(Node *n);
  virtual int newDirective(Node *n);
  virtual int pragmaDirective(Node *n);
  virtual int typemapDirective(Node *n);
  virtual int typemapcopyDirective(Node *n);
  virtual int typesDirective(Node *n);

  /* C/C++ parsing */
  
  virtual int cDeclaration(Node *n);
  virtual int externDeclaration(Node *n);
  virtual int enumDeclaration(Node *n);
  virtual int enumvalueDeclaration(Node *n);
  virtual int classDeclaration(Node *n);
  virtual int classforwardDeclaration(Node *n);
  virtual int constructorDeclaration(Node *n);
  virtual int destructorDeclaration(Node *n);
  virtual int accessDeclaration(Node *n);

  /* Function events */

  virtual int functionDeclaration(Node *n);
  virtual int globalfunctionDeclaration(Node *n);
  virtual int memberfunctionDeclaration(Node *n);
  virtual int staticmemberfunctionDeclaration(Node *n);
  virtual int callbackfunctionDeclaration(Node *n);

  /* Variable events */

  virtual int variableDeclaration(Node *n);
  virtual int globalvariableDeclaration(Node *n);
  virtual int membervariableDeclaration(Node *n);
  virtual int staticmembervariableDeclaration(Node *n);

  /* Miscellaneous C++ */

  virtual int memberconstantDeclaration(Node *n);
  virtual int publicconstructorDeclaration(Node *n);
  virtual int publicdestructorDeclaration(Node *n);

  /* Low-level code generation */

  virtual int constantWrapper(Node *n);
  virtual int variableWrapper(Node *n);
  virtual int functionWrapper(Node *n);
  virtual int nativeWrapper(Node *n);

  /* ----------------------------------------------------------------------
   !! Deprecated interface.   It is only provided for backwards
   !! compatibility with old language modules.  Use the functions above
   !! instead
   * ----------------------------------------------------------------------*/

  virtual void add_native(char *name, char *iname, SwigType *t, ParmList *l);
  virtual void add_typedef(SwigType *t, char *name);

  virtual void cpp_open_class(char *name, char *rename, char *ctype, int strip);
  virtual void cpp_close_class();
  virtual void cpp_inherit(char **baseclass, int mode = 0);

  // Pragma directive

  virtual void pragma(char *, char *, char *);

  // Declaration of a class, but not a full definition
  virtual void cpp_class_decl(char *, char *, char *);

  // Import directive

  virtual void import_start(char *modulename);    /* Import a new module */
  virtual void import_end();                      /* Done with import    */
  virtual int  validIdentifier(String *s);        /* valid identifier? */


};

extern  int   SWIG_main(int, char **, Language *);
extern  void  emit_args(SwigType *, ParmList *, Wrapper *f);
extern  void  SWIG_exit(int);           /* use EXIT_{SUCCESS,FAILURE} */
extern  void  SWIG_config_file(const String_or_char *);
extern "C"    void  SWIG_typemap_lang(const char *);
extern void   SWIG_library_directory(const char *);
extern int    emit_num_arguments(ParmList *);
extern int    emit_num_required(ParmList *);
extern void   emit_attach_parmmaps(ParmList *, Wrapper *f);
extern void   emit_action(Node *n, Wrapper *f);

/* swig11.h ends here */










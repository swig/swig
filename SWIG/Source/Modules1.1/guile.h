/*****************************************************************************
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
 *****************************************************************************/

/**************************************************************************
 * $Header$
 *
 * class GUILE
 *
 * Guile implementation
 *
 **************************************************************************/

#include "swig.h"

class GUILE : public Language
{
private:
  char   *prefix;
  char   *module;
  char   *package;
  enum {
    GUILE_LSTYLE_SIMPLE,                // call `SWIG_init()'
    GUILE_LSTYLE_LTDLMOD,               // "native" guile?
    GUILE_LSTYLE_HOBBIT                 // use (hobbit4d link)
  } linkage;
  File  *procdoc;
  int	 emit_setters;
  int    struct_member;
  void   emit_linkage(char *module_name);

public :
  GUILE ();
  void parse_args (int, char *argv[]);
  void parse ();
  void create_function (char *, char *, SwigType *, ParmList *);
  void link_variable (char *, char *, SwigType *);
  void declare_const (char *, char *, SwigType *, char *);
  void initialize ();
  void headers (void);
  void close (void);
  void set_module(char *);
  void set_init (char *);
  void create_command (char *, char *) { };
  void cpp_variable(char *name, char *iname, SwigType *t);
};

/* guile.h ends here */

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
  void initialize(String *module);
  void function (DOH *node);
  void variable (DOH *node);
  void constant (DOH *node);
  void close (void);
  void create_command (String *, String *) { };
  void cpp_variable(DOH *node);
};

/* guile.h ends here */

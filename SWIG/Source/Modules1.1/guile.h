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
 * (Caution : This is *somewhat* experimental)
 *
 **************************************************************************/

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
  int	 with_smobs;
  void   get_pointer(char *iname, int parm, DataType *t,
		     WrapperFunction &f, const String &proc_name,
		     int num_scheme_parm);
  void   usage_var(char *, DataType *, String &usage);
  void   usage_func(char *, DataType *, ParmList *, String &usage);
  void   usage_returns(char *, DataType *, ParmList *, String &usage);
  void   usage_const(char *, DataType *, char *, String &usage);
  void   emit_linkage(String &module_name);

public :
  GUILE ();
  void parse_args (int, char *argv[]);
  void parse ();
  void create_function (char *, char *, DataType *, ParmList *);
  void link_variable (char *, char *, DataType *);
  void declare_const (char *, char *, DataType *, char *);
  void initialize ();
  void headers (void);
  void close (void);
  void set_module (char *, char **);
  void set_init (char *);
  void create_command (char *, char *) { };
};

/* guile.h ends here */

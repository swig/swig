/*******************************************************************************
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
 *******************************************************************************/

/**************************************************************************
 * $Header$
 *
 * class MZSCHEME
 *
 * Mzscheme implementation
 * (Caution : This is *somewhat* experimental)
 *
 **************************************************************************/

class MZSCHEME : public Language
{
private:
  void   get_pointer(DOHString_or_char *name, int parm, SwigType *t, Wrapper *f);
  void   usage_var(char *, SwigType *, DOHString *usage);
  void   usage_func(char *, SwigType *, ParmList *, DOHString *usage);
  void   usage_returns(char *, SwigType *, ParmList *, DOHString *usage);
  void   usage_const(char *, SwigType *, char *, DOHString *usage);

public :
  void parse_args (int, char *argv[]);
  void initialize(String *module);
  void function (DOH *node);
  void variable (DOH *node);
  void constant (DOH *node);
  void close (void);
  void create_command (String *, String *) { };
};

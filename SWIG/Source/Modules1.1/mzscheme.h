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
public :
  void main (int, char *argv[]);
  void top(Node *); 
  void create_function (char *, char *, SwigType *, ParmList *);
  void link_variable (char *, char *, SwigType *);
  void declare_const (char *, char *, SwigType *, char *);



  void set_module (char *);

  void create_command (char *, char *) { };
  void import_start(char *modname);
  void import_end();
};

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
  virtual void main (int, char *argv[]);
  virtual int top(Node *); 
  virtual int functionWrapper(Node *);
  virtual int constantWrapper(Node *);
  virtual int variableWrapper(Node *);

  void set_module (char *);
  int  validIdentifier(String *s);
};


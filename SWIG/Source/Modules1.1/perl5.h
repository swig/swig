/****************************************************************************
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
 ****************************************************************************/

/**************************************************************************
 * class PERL5
 *
 * A Perl 5 implementation
 **************************************************************************/

class PERL5 : public Language {
private:
  char     *usage_func(char *, SwigType *, ParmList *);
  DOH      *is_shadow(SwigType *t);
  void      setclassname(Node *);
public :
  virtual void main(int, char *argv[]);
  virtual int top(Node *);
  virtual int functionWrapper(Node *);
  virtual int constantWrapper(Node *);
  virtual int variableWrapper(Node *);
  virtual int nativeWrapper(Node *);

  virtual int staticmemberfunctionHandler(Node *);
  virtual int staticmembervariableHandler(Node *);
  virtual int membervariableHandler(Node *);
  virtual int memberconstantHandler(Node *);
  virtual int memberfunctionHandler(Node *);
  virtual int constructorHandler(Node *n);
  virtual int destructorHandler(Node *n);

  virtual int classHandler(Node *n);
  virtual int classDeclaration(Node *n);

  virtual void pragma(char *, char *, char *);
  virtual void import_start(char *filename);
};




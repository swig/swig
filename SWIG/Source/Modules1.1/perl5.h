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
public :
  virtual void main(int, char *argv[]);
  virtual int top(Node *);
  virtual int functionWrapper(Node *);
  virtual int constantWrapper(Node *);
  virtual int variableWrapper(Node *);

  virtual int staticmemberfunctionDeclaration(Node *);
  virtual int staticmembervariableDeclaration(Node *);
  virtual int membervariableDeclaration(Node *);
  virtual int memberconstantDeclaration(Node *);
  virtual int memberfunctionDeclaration(Node *);
  virtual int publicconstructorDeclaration(Node *n);
  virtual int publicdestructorDeclaration(Node *n);

  virtual void add_native(char *, char *, SwigType *, ParmList *);

  // Support for blessed perl thingies....

  virtual void cpp_open_class(char *classname, char *rename, char *ctype, int strip);
  virtual void cpp_close_class();


  virtual void cpp_inherit(char **baseclass, int mode = 0);

  virtual void cpp_class_decl(char *, char *, char *);
 virtual  void add_typedef(SwigType *t, char *name);
  virtual void pragma(char *, char *, char *);
  virtual void import_start(char *filename);
  virtual void import_end();
};




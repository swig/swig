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
 * class TCL8
 *
 * A TCL implementation for Tcl 8.0.  Basically the same as the other
 * Tcl module, but with different code generation.
 **************************************************************************/

class TCL8 : public Language {
private:
  char  *usage_string(char *, SwigType *, ParmList *);

public :
  virtual void main(int, char *argv[]);

  virtual int top(Node *); 
  virtual int functionWrapper(Node *n);
  virtual int constantWrapper(Node *n);
  virtual int variableWrapper(Node *n);
  virtual int membervariableDeclaration(Node *n);
  virtual int memberfunctionDeclaration(Node *n);
  virtual int publicconstructorDeclaration(Node *n);
  virtual int publicdestructorDeclaration(Node *n);

  virtual void add_native(char *, char *, SwigType *, ParmList *);

  // Stubs for processing C++ classes in Tcl

  virtual void cpp_open_class(char *classname, char *rename, char *ctype, int strip);
  virtual void cpp_close_class();
  
  virtual void cpp_inherit(char **bases, int);

  virtual int  validIdentifier(String *);
};







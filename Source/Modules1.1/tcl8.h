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
  virtual void parse_args(int, char *argv[]);
  virtual void parse();
  virtual void create_function(char *, char *, SwigType *, ParmList *);
  virtual void link_variable(char *, char *, SwigType *);
  virtual void declare_const(char *, char *, SwigType *, char *);
  virtual void initialize(void);
  virtual void close(void);
  virtual void set_module(char *,char **);
  virtual void add_native(char *, char *, SwigType *, ParmList *);
  virtual void create_command(char *, char *);

  // Stubs for processing C++ classes in Tcl

  virtual void cpp_open_class(char *classname, char *rename, char *ctype, int strip);
  virtual void cpp_close_class();
  virtual void cpp_member_func(char *name, char *iname, SwigType *t, ParmList *l);
  virtual void cpp_variable(char *name, char *iname, SwigType *t);
  virtual void cpp_constructor(char *name, char *iname, ParmList *l);
  virtual void cpp_destructor(char *name, char *newname);
};







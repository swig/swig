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
  virtual void initialize(String *);
  virtual void function(DOH *node);
  virtual void variable(DOH *node);
  virtual void constant(DOH *node);
  virtual void close(void);
  virtual void nativefunction(DOH *);
  virtual void create_command(String *, String *);

  // Stubs for processing C++ classes in Tcl

  virtual void cpp_open_class(DOH *node);
  virtual void cpp_close_class();
  virtual void cpp_memberfunction(DOH *);
  virtual void cpp_variable(DOH *);
  virtual void cpp_constructor(DOH *);
  virtual void cpp_destructor(DOH *);
};







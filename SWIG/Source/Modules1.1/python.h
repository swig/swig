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
 * python.h
 *
 * Header file for Python module.   Warning ; this is work in progress.
 **************************************************************************/

class PYTHON : public Language {
protected:
  void    get_pointer(char *src, char *dest, SwigType *t, String *f, char *ret);
  void add_method(String *name, String *function, int kw);
  char *usage_func(char *, SwigType *, ParmList *);

public :

  // Don't change any of this
  virtual void parse_args(int, char *argv[]);
  virtual void initialize(String *); 
  virtual void function(DOH *node);
  virtual void variable(DOH *node);
  virtual void constant(DOH *node); 
  virtual void nativefunction(DOH *);
  virtual void close(void);
  virtual void create_command(String *, String *);
  virtual void import(String *modname);

  // C++ extensions---for creating shadow classes
  
  virtual void cpp_memberfunction(DOH *);
  virtual void cpp_constructor(DOH *);
  virtual void cpp_destructor(DOH *);
  virtual void cpp_open_class(DOH *);
  virtual void cpp_close_class();
  virtual void cpp_inherit(List *bases);
  virtual void cpp_variable(DOH *);
  virtual void cpp_constant(DOH *);
  virtual void cpp_class_decl(DOH *);
  virtual void pragma(DOH *node);
  virtual void add_typedef(SwigType *t, String *name);
};

#define PYSHADOW_MEMBER  0x2





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
  void   get_pointer(char *iname, char *srcname, char *src, char *dest,
			DataType *t, DOHString *f, char *ret);
  char     *usage_var(char *, DataType *);
  char     *usage_func(char *, DataType *, ParmList *);
  char     *usage_const(char *, DataType *, char *);

public :
  virtual void parse_args(int, char *argv[]);
  virtual void parse();
  virtual void create_function(char *, char *, DataType *, ParmList *);
  virtual void link_variable(char *, char *, DataType *);
  virtual void declare_const(char *, char *, DataType *, char *);
  virtual void initialize(void);
  virtual void headers(void);
  virtual void close(void);
  virtual void set_module(char *, char **);
  virtual void set_init(char *);
  virtual void add_native(char *, char *, DataType *, ParmList *);
  virtual void create_command(char *, char *);
  virtual char *type_mangle(DataType *);

  // Support for blessed perl thingies....

  virtual void cpp_open_class(char *classname, char *rename, char *ctype, int strip);
  virtual void cpp_close_class();
  virtual void cpp_member_func(char *name, char *iname, DataType *t, ParmList *l);
  virtual void cpp_static_func(char *name, char *iname, DataType *t, ParmList *l);
  virtual void cpp_variable(char *name, char *iname, DataType *t);
  virtual void cpp_constructor(char *name, char *iname, ParmList *l);
  virtual void cpp_destructor(char *name, char *newname);
  virtual void cpp_inherit(char **baseclass, int mode = INHERIT_ALL);
  virtual void cpp_declare_const(char *name, char *iname, DataType *type, char *value);
  virtual void cpp_class_decl(char *, char *, char *);
 virtual  void add_typedef(DataType *t, char *name);
  virtual void pragma(char *, char *, char *);
  virtual void import(char *filename);
};




/********************************************************************
 * Ruby module for SWIG
 *
 * $Header$
 *
 * Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
 * Copyright (C) 2000  Information-technology Promotion Agency, Japan
 *
 * Masaki Fukushima
 *
 ********************************************************************/

class RUBY : public Language {
 protected:
  virtual String *make_wrapper_name(char *cname);
  virtual char *validate_const_name(char *name);
  virtual char *ruby_typemap_lookup(char *, SwigType *, String_or_char *, char *, char *, Wrapper * = 0);
  virtual int to_VALUE(SwigType *, char *, DOHString *, int = 0);
  virtual int from_VALUE(SwigType *, char *, char *, DOHString *);
 public:
  /* Virtual functions required by the SWIG parser */
  virtual void parse_args(int, char *argv[]);
  virtual void initialize(String *module);
  virtual void function(DOH *node);
  virtual void variable(DOH *node);
  virtual void constant(DOH *node);
  virtual void close(void);
  virtual void nativefunction(DOH *);
  virtual void create_command(String *, String *);
  virtual void import(String *);

  /* C++ language extensions. */
  virtual void cpp_memberfunction(DOH *);
  virtual void cpp_constructor(DOH *);
  virtual void cpp_destructor(DOH *);
  virtual void cpp_open_class(DOH *);
  virtual void cpp_close_class();
  virtual void cpp_inherit(List *bases, int mode = INHERIT_ALL);
  virtual void cpp_variable(DOH *);
  virtual void cpp_staticfunction(DOH *);
  virtual void cpp_constant(DOH *);
  virtual void cpp_staticvariable(DOH *);

  /* Declaration of a class, but not a full definition */
  virtual void cpp_class_decl(DOH *);

  /* Pragma directive  */
  virtual void pragma(DOH *node);
};

/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */

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
  //  virtual String *ruby_typemap_lookup(char *, SwigType *, String_or_char *, String_or_char *, char *, char *, Wrapper * = 0);
  virtual int to_VALUE(SwigType *, char *, DOHString *, int = 0);
  virtual int from_VALUE(SwigType *, char *, char *, DOHString *);
 public:
  /* Virtual functions required by the SWIG parser */
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
  virtual int publicconstructorDeclaration(Node *);
  virtual int publicdestructorDeclaration(Node *);

  virtual void set_module(char *);
  virtual void add_native(char *, char *, SwigType *, ParmList *);
  virtual void create_command(char *, char *, int);

  /* C++ language extensions. */

  virtual void cpp_open_class(char *classname, char *rname, char *ctype, int strip);
  virtual void cpp_close_class();
  virtual void cpp_inherit(char **baseclass, int mode = 0);

  /* Declaration of a class, but not a full definition */
  virtual void cpp_class_decl(char *, char *, char *);

  /* Pragma directive  */
  virtual void pragma(char *, char *, char *);
};

/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */

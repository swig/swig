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

class RClass {
 private:
  String temp;
 public:
  String name;	// class name (renamed)
  String cname; // original C class/struct name
  String vname; // variable name
  String type;
  String prefix;
  String header;
  String init;

  String aliases;
  String includes;
  DOH *freemethods;
  DOH *predmethods;
  int destructor_defined;

  RClass(void) {
    freemethods = NewHash();
    predmethods = NewHash();
    destructor_defined = 0;
  }
  void set_name(char *cn, char *rn, char *valn) {
    cname = cn;
    name = valn;
    vname << "c" << name;
    prefix <<  (rn ? rn : cn) << "_";
  }
  char *strip(char *s) {
    if (strncmp(s, prefix.get(), strlen(prefix.get())) != 0)
      return s;
    temp = s;
    temp.replace(prefix.get(), "");
    return temp.get();
  }
};

class RUBY : public Language {
 private:
  char *module;
  char *modvar;
  char *feature;
  int toplevel;
  String other_extern;
  String other_init;
  char *import_file;

  int current;
  enum {
    NO_CPP,
    MEMBER_FUNC,
    CONSTRUCTOR,
    DESTRUCTOR,
    MEMBER_VAR,
    CLASS_CONST,
    STATIC_FUNC,
    STATIC_VAR
  };

  DOH *classes;		// key=cname val=RClass
  RClass *klass;	// Currently processing class
  DOH *special_methods;	// Python style special method name table

  virtual char *make_wrapper_name(char *cname);
  virtual char *validate_const_name(char *name);
  virtual char *ruby_typemap_lookup(char *, DataType *, char *, char *, char *, WrapperFunction * = 0);
  virtual int to_VALUE(DataType *, char *, String&, int = 0);
  virtual int from_VALUE(DataType *, char *, String&);
 public:
  RUBY();

  // Virtual functions required by the SWIG parser
  virtual void parse_args(int, char *argv[]);
  virtual void parse();
  virtual void create_function(char *, char *, DataType *, ParmList *);
  virtual void link_variable(char *, char *, DataType *);
  virtual void declare_const(char *, char *, DataType *, char *);
  virtual void initialize(void);
  virtual void headers(void);
  virtual void close(void);
  virtual void set_module(char *,char **);
  virtual void create_command(char *, char *, int);

  // C++ language extensions.
  virtual void cpp_member_func(char *name, char *iname, DataType *t, ParmList *l);
  virtual void cpp_constructor(char *name, char *iname, ParmList *l);
  virtual void cpp_destructor(char *name, char *newname);
  virtual void cpp_open_class(char *classname, char *rname, char *ctype, int strip);
  virtual void cpp_close_class();
  virtual void cpp_inherit(char **baseclass, int mode = INHERIT_ALL);
  virtual void cpp_variable(char *name, char *iname, DataType *t);
  virtual void cpp_static_func(char *name, char *iname, DataType *t, ParmList *l);
  virtual void cpp_declare_const(char *name, char *iname, DataType *type, char *value);
  virtual void cpp_static_var(char *name, char *iname, DataType *t);

  // Declaration of a class, but not a full definition
  virtual void cpp_class_decl(char *, char *, char *);

  // Pragma directive 
  virtual void pragma(char *, char *, char *);
  virtual void cpp_pragma(Pragma *);

  // Import directive
  virtual void import(char *filename);

};

/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */

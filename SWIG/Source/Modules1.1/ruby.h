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
  DOHString *temp;
 public:
  DOHString *name;    // class name (renamed)
  DOHString *cname;   // original C class/struct name
  DOHString *vname;   // variable name
  DOHString *type;
  DOHString *prefix;
  DOHString *header;
  DOHString *init;

  DOHString *aliases;
  DOHString *includes;
  DOH *freemethods;
  DOH *predmethods;
  int destructor_defined;

  RClass(void) {
    freemethods = NewHash();
    predmethods = NewHash();
    destructor_defined = 0;
    name = NewString("");
    cname = NewString("");
    vname = NewString("");
    type = NewString("");
    prefix = NewString("");
    header = NewString("");
    init = NewString("");
    aliases = NewString("");
    includes = NewString("");
    temp = NewString("");
  }
  ~RClass() {
    Delete(name);
    Delete(cname);
    Delete(vname);
    Delete(type);
    Delete(prefix);
    Delete(header);
    Delete(init);
    Delete(aliases);
    Delete(includes);
    Delete(freemethods);
    Delete(predmethods);
    Delete(temp);
  }

  void set_name(char *cn, char *rn, char *valn) {
    Clear(cname);
    Append(cname,cn);
    Clear(name);
    Append(name,valn);
    Clear(vname);
    Printf(vname,"c%s",name);
    Printv(prefix,(rn ? rn : cn), "_", 0);
  }

  char *strip(char *s) {
    if (strncmp(s, Char(prefix), Len(prefix)) != 0)
      return s;
    Clear(temp);
    Append(temp,s);
    Replace(temp,prefix,"",DOH_REPLACE_ANY);
    return Char(temp);
  }
};

class RUBY : public Language {
 private:
  virtual char *make_wrapper_name(char *cname);
  virtual char *validate_const_name(char *name);
  virtual char *ruby_typemap_lookup(char *, SwigType *, char *, char *, char *, Wrapper * = 0);
  virtual int to_VALUE(SwigType *, char *, DOHString *, int = 0);
  virtual int from_VALUE(SwigType *, char *, DOHString *);
 public:
  RUBY();
  // Virtual functions required by the SWIG parser
  virtual void parse_args(int, char *argv[]);
  virtual void parse();
  virtual void create_function(char *, char *, SwigType *, ParmList *);
  virtual void link_variable(char *, char *, SwigType *);
  virtual void declare_const(char *, char *, SwigType *, char *);
  virtual void initialize(void);
  virtual void headers(void);
  virtual void close(void);
  virtual void set_module(char *,char **);
  virtual void create_command(char *, char *, int);

  // C++ language extensions.
  virtual void cpp_member_func(char *name, char *iname, SwigType *t, ParmList *l);
  virtual void cpp_constructor(char *name, char *iname, ParmList *l);
  virtual void cpp_destructor(char *name, char *newname);
  virtual void cpp_open_class(char *classname, char *rname, char *ctype, int strip);
  virtual void cpp_close_class();
  virtual void cpp_inherit(char **baseclass, int mode = INHERIT_ALL);
  virtual void cpp_variable(char *name, char *iname, SwigType *t);
  virtual void cpp_static_func(char *name, char *iname, SwigType *t, ParmList *l);
  virtual void cpp_declare_const(char *name, char *iname, SwigType *type, char *value);
  virtual void cpp_static_var(char *name, char *iname, SwigType *t);

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

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

class RClass;

class RUBY : public Language {
private:
  RUBY(const RUBY&);
  RUBY& operator=(const RUBY&);

private:
  static const char *usage;
  char *module;
  char *modvar;
  char *feature;
  int current;
  Hash *classes;		/* key=cname val=RClass */
  RClass *klass;		/* Currently processing class */
  Hash *special_methods;	/* Python style special method name table */
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;

private:
  // Wrap modes
  enum {
    NO_CPP,
    MEMBER_FUNC,
    CONSTRUCTOR_ALLOCATE,
    CONSTRUCTOR_INITIALIZE,
    DESTRUCTOR,
    MEMBER_VAR,
    CLASS_CONST,
    STATIC_FUNC,
    STATIC_VAR
  };

protected:
  virtual char *validate_const_name(char *name, const char *reason);
  void marshalInputArgs(ParmList *l, int numarg, int numreq, int start, Wrapper *f);
  void insertConstraintCheckingCode(ParmList *l, Wrapper *f);
  void insertCleanupCode(ParmList *l, String *cleanup);
  void insertArgOutputCode(ParmList *l, String *outarg, int& need_result);
  void create_command(Node *, char *);
  void set_module(const char *module_name);

public:
  // Constructor
  RUBY();
  
  /* Parse command line options */
  
  virtual void main(int argc, char *argv[]);
  
  /* Top of the parse tree */
  
  virtual int top(Node *n);
  
  /* Function handlers */

  virtual int memberfunctionHandler(Node *n);
  virtual int staticmemberfunctionHandler(Node *n);

  /* Variable handlers */
  
  virtual int membervariableHandler(Node *n);
  virtual int staticmembervariableHandler(Node *n);
  
  /* C++ handlers */
  
  virtual int memberconstantHandler(Node *n);
  virtual int constructorHandler(Node *n);
  virtual int copyconstructorHandler(Node *n);
  virtual int destructorHandler(Node *n);
  virtual int classHandler(Node *n);
  virtual int classDeclaration(Node *n);

  /* Miscellaneous */

  virtual int validIdentifier(String *s);

  /* Low-level code generation */

  virtual int constantWrapper(Node *n);
  virtual int variableWrapper(Node *n);
  virtual int functionWrapper(Node *n);
  virtual int nativeWrapper(Node *n);

  // Import directive

  virtual int importDirective(Node *n);   /* Import a new module */  
};

/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */

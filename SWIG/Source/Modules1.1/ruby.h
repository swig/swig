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
  virtual char *validate_const_name(char *name, const char *reason);
  void marshalInputArgs(ParmList *l, int numarg, int numreq, int start, Wrapper *f);
  void insertConstraintCheckingCode(ParmList *l, Wrapper *f);
  void insertCleanupCode(ParmList *l, String *cleanup);
  void insertArgOutputCode(ParmList *l, String *outarg, int& need_result);
  void create_command(Node *, char *);
  void set_module(const char *module_name);

 public:
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
};

/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */

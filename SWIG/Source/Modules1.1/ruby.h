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
  void marshalInputArgs(ParmList *l, int numarg, int numreq, int start, Wrapper *f);
  void insertConstraintCheckingCode(ParmList *l, Wrapper *f);
  void insertCleanupCode(ParmList *l, String *cleanup);
  void insertArgOutputCode(ParmList *l, String *outarg, int& need_result);
 public:
  /* Virtual functions required by the SWIG parser */
  virtual void main(int, char *argv[]);
  virtual int top(Node *);
  virtual int functionWrapper(Node *);
  virtual int constantWrapper(Node *);
  virtual int variableWrapper(Node *);
  virtual int nativeWrapper(Node *);

  virtual int staticmemberfunctionHandler(Node *);
  virtual int staticmembervariableHandler(Node *);
  virtual int membervariableHandler(Node *);
  virtual int memberconstantHandler(Node *);
  virtual int memberfunctionHandler(Node *);
  virtual int constructorHandler(Node *);
  virtual int destructorHandler(Node *);
  virtual int classHandler(Node *);
  virtual int classforwardDeclaration(Node *);

  virtual void set_module(char *);          /* Deprecated */

  virtual void create_command(char *, char *, int);   /* Deprecated */

  /* Pragma directive  */
  virtual void pragma(char *, char *, char *);
};

/*
 * Local Variables:
 * c-basic-offset: 2
 * End:
 */

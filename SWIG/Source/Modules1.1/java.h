
// ------------------------------------------------------------------------
// A Java SWIG Language module
//
// ------------------------------------------------------------------------

class JAVA : public Language {
public :

  // Virtual functions required by the SWIG parser

  virtual void main(int, char *argv[]);
  virtual int top(Node *); 
  virtual int functionWrapper(Node *);
  virtual int constantWrapper(Node *);
  virtual int variableWrapper(Node *);
  virtual int nativeWrapper(Node *);
  virtual int staticmemberfunctionHandler(Node *);
  virtual int staticmembervariableHandler(Node *);
  virtual int membervariableHandler(Node *);
  virtual int enumDeclaration(Node *n);
  virtual int memberconstantHandler(Node *);
  virtual int memberfunctionHandler(Node *);
  virtual int constructorHandler(Node *);
  virtual int destructorHandler(Node *);
  virtual int classHandler(Node *);
  virtual int classDeclaration(Node *);

  virtual void pragma(char *lang, char *code, char *value);

private:
  String *is_shadow(SwigType *ty);

  /* Java module enums */
  enum type_additions {none, pointer, reference};

  /* Java module methods */
  void emitClassDef();
  void emitShadowClassDef(Node *);
  char *jniCall(DOHString_or_char *func);
  String *makeValidJniName(const String *name);
  char *javaMethodSignature(SwigType *t, int ret, int inShadow);
  void writeRegisterNatives();
  void javaShadowFunctionHandler(Node* n, int is_virtual);
  void typemapApply(String *swigtype, String *tmap, String *name, type_additions additions, int array_flag);
  void addclasstypemaps(Node *n);
};

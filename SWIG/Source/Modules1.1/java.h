
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


  virtual int staticmemberfunctionDeclaration(Node *);
  virtual int staticmembervariableDeclaration(Node *);
  virtual int membervariableDeclaration(Node *);
  virtual int memberconstantDeclaration(Node *);
  virtual int memberfunctionDeclaration(Node *);
  virtual int publicconstructorDeclaration(Node *);
  virtual int publicdestructorDeclaration(Node *);

  virtual void add_native(char *, char *, SwigType *, ParmList *);

  virtual void set_module(char *);
  virtual void create_command(char *, char *);

  virtual void pragma(char *lang, char *code, char *value);
  virtual void add_typedef(SwigType *t, char *name);
  virtual void cpp_open_class(char *classname, char *rename, char *ctype, int strip);
  virtual void cpp_close_class();

  virtual void cpp_class_decl(char *name, char *rename, char *type);
  virtual void cpp_inherit(char **baseclass, int);

  virtual void import_start(char *modulename);
  virtual void import_end();

  /* Java Module methods */
  void emit_classdef();
  void emit_shadow_classdef();
  char *JNICALL(DOHString_or_char *func);
  void SwigToJNIType(SwigType *t, String_or_char *pname, String* jni_type);
  void SwigToJavaType(SwigType *t, String_or_char *pname, String* java_type, int shadow_flag);
  char *SwigToJavaArrayType(SwigType *t);
  char *JavaTypeFromTypemap(char *op, SwigType *t, String_or_char *pname, String_or_char *lname);
  char *makeValidJniName(const char *name);
  char *JavaMethodSignature(SwigType *t, int ret, int inShadow);
  void writeRegisterNatives();
  void cpp_func(char *iname, SwigType *t, ParmList *l, String* java_function_name, int is_virtual);
};

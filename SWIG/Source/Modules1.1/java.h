
// ------------------------------------------------------------------------
// A Java SWIG Language module
//
// ------------------------------------------------------------------------

class JAVA : public Language {
public :

  // Virtual functions required by the SWIG parser

  void parse_args(int, char *argv[]);
  void parse();
  void add_native(char *, char *, SwigType *, ParmList *);
  void create_function(char *, char *, SwigType *, ParmList *);
  void link_variable(char *, char *, SwigType *);
  void declare_const(char *, char *, SwigType *, char *);
  void initialize(void);
  void headers(void);
  void close(void);
  void set_module(char *);
  void create_command(char *, char *);

  void pragma(char *lang, char *code, char *value);
  void add_typedef(SwigType *t, char *name);
  void cpp_pragma(Pragma *plist);
  void cpp_open_class(char *classname, char *rename, char *ctype, int strip);
  void cpp_close_class();
  void cpp_member_func(char *name, char *iname, SwigType *t, ParmList *l); 
  void cpp_static_func(char *name, char *iname, SwigType *t, ParmList *l);
  void cpp_constructor(char *name, char *iname, ParmList *l);
  void cpp_destructor(char *name, char *newname);
  void cpp_class_decl(char *name, char *rename, char *type);
  void cpp_inherit(char **baseclass, int);
  void cpp_variable(char *name, char *iname, SwigType *t);
  void cpp_static_var(char *, char *, SwigType *);
  void cpp_declare_const(char *name, char *iname, SwigType *type, char *value);

  /* Java Module methods */
  void emit_classdef();
  void emit_shadow_classdef();
  char *JNICALL(DOHString_or_char *func);
  void SwigToJNIType(SwigType *t, String_or_char *pname, String* jni_type);
  void SwigToJavaType(SwigType *t, String_or_char *pname, String* java_type, int shadow_flag);
  char *SwigToJavaArrayType(SwigType *t);
  char *JavaTypeFromTypemap(char *op, SwigType *t, String_or_char *pname);
  char *makeValidJniName(char *name);
  char *JavaMethodSignature(SwigType *t, int ret, int inShadow);
  void writeRegisterNatives();
  void cpp_func(char *iname, SwigType *t, ParmList *l, String* java_function_name);
};

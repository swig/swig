
// ------------------------------------------------------------------------
// A Java SWIG Language module
//
// ------------------------------------------------------------------------

class JAVA : public Language {
private:
  char         *module;          // Name of the module
  char         *java_path;
  char         *package;         // Name of the package
  char         *c_pkgstr;         // Name of the package
  char         *jni_pkgstr;         // Name of the package
  char         *shadow_classname;
  char         *jimport;
  char         *method_modifiers;
  FILE         *f_java;
  FILE         *f_shadow;
  int          shadow;
  Hash         shadow_classes;
  String       shadow_classdef;
  char         *shadow_name;
  char         *shadow_baseclass;
  int          classdef_emitted;
  int          shadow_classdef_emitted;
  int          have_default_constructor;
  int          native_func;           // Set to 1 when wrapping a native function
  int          member_func;           // Set to 1 when wrapping a member function
  int          jnic;          // 1: use c syntax jni; 0: use c++ syntax jni
  int          finalize;          // generate finalize methods
  int          useRegisterNatives;        // Set to 1 when doing stuff with register natives
  String       registerNativesList;


public :
  JAVA() {
    module = NULL;
    package = NULL;
    java_path = "java";
    f_java = f_shadow = NULL;
    native_func = shadow = member_func = 0;
    jimport = shadow_name = shadow_baseclass = NULL;
    method_modifiers = "public final static";
    jnic = -1;
    useRegisterNatives=0;
    finalize=0;
  };

  // Virtual functions required by the SWIG parser

  void parse_args(int, char *argv[]);
  void parse();
  void add_native(char *, char *, DataType *, ParmList *);
  void create_function(char *, char *, DataType *, ParmList *);
  void link_variable(char *, char *, DataType *);
  void declare_const(char *, char *, DataType *, char *);
  void initialize(void);
  void headers(void);
  void close(void);
  void set_module(char *,char **);
  void create_command(char *, char *);

  void pragma(char *lang, char *code, char *value);
  void add_typedef(DataType *t, char *name);
  void cpp_open_class(char *classname, char *rename, char *ctype, int strip);
  void cpp_close_class();
  void cpp_member_func(char *name, char *iname, DataType *t, ParmList *l); 
  void cpp_static_func(char *name, char *iname, DataType *t, ParmList *l);
  void cpp_constructor(char *name, char *iname, ParmList *l);
  void cpp_destructor(char *name, char *newname);
  void cpp_class_decl(char *name, char *rename, char *type);
  void cpp_inherit(char **baseclass, int);
  void cpp_variable(char *name, char *iname, DataType *t);
  void cpp_static_var(char *, char *, class DataType *);
  void cpp_declare_const(char *name, char *iname, DataType *type, char *value);

  /* Java Module methods */
  void emit_classdef();
  void emit_shadow_classdef();
  char *JNICALL(char *func);
  char *JNICALL(String& func);
  char *SwigTcToJniType(DataType *t, int ret);
  char *SwigTcToJavaType(DataType *t, int ret, int inShadow);
  char *SwigTcToJniScalarType(DataType *t);
  char *JavaTypeFromTypemap(char *op, char *lang, DataType *t, char *pname);
  char *makeValidJniName(char *name);
  char *JavaMethodSignature(DataType *t, int ret, int inShadow);
  void writeRegisterNatives();
};

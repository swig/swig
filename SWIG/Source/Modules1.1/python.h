/*******************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 *******************************************************************************/

/**************************************************************************
 * $Header$
 *
 * python.h
 *
 * Header file for Python module.   Warning ; this is work in progress.
 **************************************************************************/

class PYTHON : public Language {
protected:
  char   *module;               // Module name
  char   *path;                 // Pathname of where to look for library files
  char   *methods;              // Method table name
  char   *global_name;          // Name of global variables.
  void    get_pointer(char *iname, char *srcname, char *src, char *dest, DataType *t, String &f, char *ret);
  int     shadow;
  int     have_defarg;
  int     docstring;
  int     have_output;
  int     use_kw;     
  int     noopt; 
  FILE    *f_shadow;
  Hash     hash;
  String   classes;
  String   func;
  String   vars;
  String   modinit;
  String   modextern;

  char     *import_file;
  char     *class_name;
  void add_method(char *name, char *function, int kw);
  void print_methods();
  char *usage_var(char *, DataType *);
  char *usage_func(char *, DataType *, ParmList *);
  char *usage_const(char *, DataType *, char *);

  // Add for Python-COM support
  virtual void initialize_cmodule();
  virtual void close_cmodule();
  virtual void emit_function_header(WrapperFunction &emit_to, char *wname);
  virtual char *convert_self(WrapperFunction &f);
  virtual char *make_funcname_wrapper(char *fnName);
  void emitAddPragmas(String& output, char* name, char* spacing);
public :
  PYTHON() {
    module = (char *) 0;
    path = "python";     // Set this to subdirectory where language
                                  // Dependent library files will be stored
    global_name = "cvar";
    shadow = 0;
    have_defarg = 0;
    import_file = 0;
    use_kw = 0;
    noopt = 0;
  };

  // Don't change any of this
  virtual void parse_args(int, char *argv[]);
  virtual void parse();
  virtual void create_function(char *, char *, DataType *, ParmList *);
  virtual void link_variable(char *, char *, DataType *);
  virtual void declare_const(char *, char *, DataType *, char *);
  virtual void initialize(void);
  virtual void headers(void);
  virtual void close(void);
  virtual void set_module(char *, char **);
  virtual void set_init(char *);
  virtual void add_native(char *, char *, DataType *, ParmList *);
  virtual void create_command(char *, char *);
  virtual void import(char *);

  // C++ extensions---for creating shadow classes
  
  virtual void cpp_member_func(char *name, char *iname, DataType *t, ParmList *l);
  virtual void cpp_constructor(char *name, char *iname, ParmList *l);
  virtual void cpp_destructor(char *name, char *newname);
  virtual void cpp_open_class(char *classname, char *rname, char *ctype, int strip);
  virtual void cpp_close_class();
  virtual void cpp_cleanup();
  virtual void cpp_inherit(char **baseclass, int mode = INHERIT_ALL);
  virtual void cpp_variable(char *name, char *iname, DataType *t);
  virtual void cpp_declare_const(char *name, char *iname, DataType *type, char *value);
  virtual void cpp_class_decl(char *, char *,char *);
  virtual void pragma(char *, char *, char *);
  virtual void cpp_pragma(Pragma *);
  virtual void add_typedef(DataType *t, char *name);
};

#define PYSHADOW_MEMBER  0x2


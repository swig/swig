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
 * class TCL8
 *
 * A TCL implementation for Tcl 8.0.  Basically the same as the other
 * Tcl module, but with different code generation.
 **************************************************************************/

class TCL8 : public Language {
private:
  char   interp_name[256];
  char  *prefix;                   // Package prefix
  char  *module;                   // Name of the module
  char  *tcl_path;
  char  *init_name;
  int    nspace;
  void   get_pointer(char *iname, char *srcname, char *src, char *dest, DataType *t,
		     String &f, char *ret);
  char  *char_result;
  char  *usage_func(char *, DataType *, ParmList *);
  char  *usage_string(char *, DataType *, ParmList *);
  char  *usage_var(char *, DataType *);
  char  *usage_const(char *, DataType *, char *);

  // C++ handling

  int    have_constructor;
  int    have_destructor;
  String methods;
  String attributes;
  String postinit;
  int    shadow;
  char   *class_name;
  char   *class_type;
  char   *real_classname;
  char   *base_class;
  Hash   hash;
  Hash   repeatcmd;

public :
    TCL8() {
    prefix = 0;
    module = 0;
    init_name = 0;
    nspace = 0;
    shadow = 1;
    char_result = "TCL_VOLATILE";
    tcl_path = "tcl";
    sprintf(interp_name,"interp");
    class_name = 0;
    class_type = 0;
    real_classname = 0;
    base_class = 0;
  };
  virtual void parse_args(int, char *argv[]);
  virtual void parse();
  virtual void create_function(char *, char *, DataType *, ParmList *);
  virtual void link_variable(char *, char *, DataType *);
  virtual void declare_const(char *, char *, DataType *, char *);
  virtual void initialize(void);
  virtual void headers(void);
  virtual void close(void);
  virtual void set_module(char *,char **);
  virtual void set_init(char *);
  virtual void add_native(char *, char *, DataType *, ParmList *);
  virtual void pragma(char *,char *, char *);
  virtual void create_command(char *, char *);

  // Stubs for processing C++ classes in Tcl

  virtual void cpp_open_class(char *classname, char *rename, char *ctype, int strip);
  virtual void cpp_close_class();
  virtual void cpp_member_func(char *name, char *iname, DataType *t, ParmList *l);
  virtual void cpp_variable(char *name, char *iname, DataType *t);
  virtual void cpp_constructor(char *name, char *iname, ParmList *l);
  virtual void cpp_destructor(char *name, char *newname);
  virtual void cpp_inherit(char **baseclass, int mode = INHERIT_ALL);
  virtual void cpp_declare_const(char *name, char *iname, DataType *type, char *value);
  virtual void add_typedef(DataType *, char *);
  virtual void cpp_class_decl(char *, char *, char *);

};







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
 * class GUILE
 *
 * Guile implementation
 * (Caution : This is *somewhat* experimental)
 *
 * Seeking : highly motivated individual with plenty of spare time and
 *           a love of Guile.   Must be willing to modify this code and
 *           make it better.
 **************************************************************************/

class GUILE : public Language {
private:
  char   *guile_path;
  char   *module;
  void   get_pointer(char *iname, int parm, DataType *t);
  void   usage_var(char *, DataType *, char **);
  void   usage_func(char *, DataType *, ParmList *, char **);
  void   usage_const(char *, DataType *, char *, char **);
public :
  GUILE() {
     module = 0;
     guile_path = "guile";
  }
  virtual void parse_args(int, char *argv[]);
  virtual void parse();
  virtual void create_function(char *, char *, DataType *, ParmList *);
  virtual void link_variable(char *, char *, DataType *);
  virtual void declare_const(char *, char *, DataType *, char *);
  virtual void initialize();
  virtual void headers(void);
  virtual void close(void);
  virtual void set_module(char *, char **);
  virtual void set_init(char *);
  virtual void create_command(char *, char *) { };
};





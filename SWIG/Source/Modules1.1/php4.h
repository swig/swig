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

class PHP4 : public Language {
public :
	virtual void main(int, char *argv[]);
	virtual int top(Node *n);
	virtual int functionWrapper(Node *n);
	virtual int variableWrapper(Node *n);
	virtual int constantWrapper(Node *n);
	virtual int nativeWrapper(Node *n);
	virtual void create_command(char *, char *);

	// Modular Support
	
	/*
	virtual void cpp_open_class(char *classname, char *rename, char *ctype, int strip);
	virtual void cpp_close_class();
	virtual void cpp_member_func(char *name, char *iname, SwigType *t, ParmList *;);
	virtual void cpp_static_func(char *name, char *iname, SwigType *t, ParmList *l);
	virtual void cpp_variable(char *name, char *iname, SwigType *t);
	virtual void cpp_constructor(char *name, char *iname, ParmList *l);
	virtual void cpp_destuctor(char *name, char *newname);
	virtual void cpp_inherit(char **baseclass, int mode = INHERIT_ALL);
	virtual void cpp_declare_const(char *name, char *iname, SwigType *type, char *value);
	virtual void cpp_class_descl(char *, char *, char *);
	virtual void add_typedef(SwigType *t, char *name);
	*/
};

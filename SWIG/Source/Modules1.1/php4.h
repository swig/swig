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
        String *is_shadow(SwigType *t);
public :
	virtual void main(int, char *argv[]);
	virtual int top(Node *n);
	virtual int functionWrapper(Node *n);
	virtual int variableWrapper(Node *n);
	virtual int constantWrapper(Node *n);
	virtual void create_command(char *, char *);

	// Modular Support
	
	virtual int  staticmembervariableHandler(Node *);
	virtual int  staticmemberfunctionHandler(Node *);
	virtual int  membervariableHandler(Node *);
	virtual int  memberfunctionHandler(Node *);
	virtual int  memberconstantHandler(Node *);
	virtual int  constructorHandler(Node *n);
	virtual int  destructorHandler(Node *n);

	virtual int  classHandler(Node *n);
	virtual int  classDeclaration(Node *n);

#ifdef DEPRECATED
	virtual int  classforwardDeclaration(Node *n);
	virtual int  typedefHandler(Node *);
#endif
	virtual void pragma(char *lang, char *code, char *value);


	void emit_classdef();
	void emit_shadow_classdef();
	void SwigToPhpType(SwigType *t, String_or_char *pname, String *php_type, int shadow_flag);
	char *PhpTypeFromTypemap(char *op, SwigType *t, String_or_char *pname, String_or_char *iname);
	void cpp_func(char *iname, SwigType *t, ParmList *l, String *php_function_name, String *handler_name = NULL);
};

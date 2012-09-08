#ifndef JAVASCRIPT_V8_H
#define JAVASCRIPT_V8_H

#include "javascript_emitter.h"

class V8Emitter: public JSEmitter {
    
public:

    V8Emitter();

    virtual ~V8Emitter();
    
    virtual int Initialize(Node *n);

    virtual int Dump(Node *n);
    
    virtual int Close();

    virtual int SwitchContext(Node *n);
    
    virtual int EnterClass(Node *n);
    
    virtual int ExitClass(Node *n);

    virtual int EnterVariable(Node *n);

    virtual int ExitVariable(Node *n);

    virtual int EnterFunction(Node *n);

    virtual int ExitFunction(Node *n);
    
protected:

    int CreateNamespace(String* scope);

    virtual int EmitCtor(Node *n);
    
    virtual int EmitDtor(Node *n);

    virtual int EmitFunction(Node *n, bool is_member);

    virtual int EmitGetter(Node *n, bool is_member);

    virtual int EmitSetter(Node *n, bool is_member);

private:

    File *f_runtime;
    File *f_header;
    File *f_class_templates;
    File *f_wrapper;
    
    File *f_init_namespaces;
    File *f_init_class_templates;
    File *f_init_wrappers;
    File *f_init_inheritance;
    File *f_init_register_classes;
    File *f_init_register_namespaces;
    
    // the output cpp file
    File *f_wrap_cpp;

    // state variables
    String* current_context;
    String* current_classname_mangled;
    String* current_classname_unqualified;
    String* current_variable_mangled;
    String* current_variable_unqualified;
    String* current_getter;
    String* current_setter;
    String* current_function_mangled;
    String* current_function_unqualified;
        
    String* GLOBAL;
    String* NULL_STR;
    Hash* namespaces;
};

#endif // JAVASCRIPT_V8_H

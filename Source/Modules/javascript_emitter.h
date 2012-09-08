#ifndef JAVASCRIPT_EMITTER_H
#define JAVASCRIPT_EMITTER_H

#include "swigmod.h"

/**
 *  A class that wraps a code snippet used as template for code generation.
 */
class Template {
    
public:
    Template(const String* code);
    
    ~Template();
        
    String* str();
    
    Template& Replace(const String* pattern, const String* repl);
    
private:
    String* m_code;
};

class JSEmitter {

public:
    
    enum JSEmitterType {
        JavascriptCore,
        V8,
        QtScript
    };    

    JSEmitter();
    
    virtual ~JSEmitter();

    /**
     * Opens output files and temporary output DOHs.
     */
    virtual int Initialize(Node *n) = 0;
    
    /**
     * Writes all collected code into the output file(s).
     */
    virtual int Dump(Node *n) = 0;
    
    /**
     * Cleans up all open output DOHs.
     */
    virtual int Close() = 0;
    
    /**
     * Switches the context for code generation.
     * 
     * Classes, global variables and global functions may need to
     * be registered in certain static tables.
     * This method should be used to switch output DOHs correspondingly.
     */
    virtual int SwitchContext(Node *n) { return SWIG_OK; };

    /**
     * Invoked at the beginning of the classHandler.
     */
    virtual int EnterClass(Node *n) { return SWIG_OK; };
    
    /**
     * Invoked at the end of the classHandler.
     */
    virtual int ExitClass(Node *n) { return SWIG_OK; };

    /**
     * Invoked at the beginning of the variableHandler.
     */
    virtual int EnterVariable(Node *n) { return SWIG_OK; };

    /**
     * Invoked at the end of the variableHandler.
     */
    virtual int ExitVariable(Node *n) { return SWIG_OK; };

    /**
     * Invoked at the beginning of the functionHandler.
     */
    virtual int EnterFunction(Node *n) { return SWIG_OK; };

    /**
     * Invoked at the end of the functionHandler.
     */
    virtual int ExitFunction(Node *n) { return SWIG_OK; };
    
    /**
     * Invoked by functionWrapper callback after call to Language::functionWrapper.
     */
    virtual int EmitWrapperFunction(Node *n);
    
    /**
     * Registers a given code snippet for a given key name.
     * 
     * This method is called by the fragmentDirective handler
     * of the JAVASCRIPT language module.
     */
    int RegisterTemplate(const String *name, const String *code);

    /**
     * Retrieve the code template registered for a given name.
     */
    const String* GetTemplate(const String *name);

protected:
    
    virtual int EmitCtor(Node *n) = 0;
    
    virtual int EmitDtor(Node *n) = 0;

    virtual int EmitFunction(Node *n, bool is_member) = 0;

    virtual int EmitGetter(Node *n, bool is_member) = 0;

    virtual int EmitSetter(Node *n, bool is_member) = 0;

    bool IsSetterMethod(Node *n);

    Node* GetBaseClass(Node *n);                            

    const String* typemapLookup(Node *n, const_String_or_char_ptr tmap_method, 
                            SwigType *type, int warning, Node *typemap_attributes = 0);
    
protected:

    // empty string used at different places in the code
    String *empty_string;
    
    Hash *templates;
    
    Wrapper* current_wrapper;
};

#endif // JAVASCRIPT_EMITTER_H

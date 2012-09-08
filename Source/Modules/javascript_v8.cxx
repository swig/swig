#include "javascript_v8.h"
#include "swigmod.h"

/* -----------------------------------------------------------------------
 * String constants that are used in Lib/javascript/v8/javascriptcode.swg
 *------------------------------------------------------------------------ */

// name of templates
#define V8_INITIALIZER                              "v8_initializer"
#define V8_DECL_CLASSTEMPLATE                       "v8_declare_class_template"
#define V8_DEFINE_CLASSTEMPLATE                     "v8_define_class_template"
#define V8_INHERIT                                  "v8_inherit"
#define V8_REGISTER_CLASS                           "v8_register_class"
#define V8_CTOR_WRAPPER                             "v8_ctor_wrapper"
#define V8_GETTER                                   "v8_getter"
#define V8_SETTER                                   "v8_setter"
#define V8_FUNCTION                                 "v8_function"
#define V8_RETRIEVE_THIS                            "v8_retrieve_this"
#define V8_REGISTER_MEMBER_FUNCTION                 "v8_register_member_function"
#define V8_CREATE_NAMESPACE                         "v8_create_namespace"
#define V8_REGISTER_NAMESPACE                       "v8_register_namespace"


// keywords used in templates
#define KW_MODULE_NAME                              "${MODULE}"
#define KW_MANGLED_NAME                             "${NAME_MANGLED}"
#define KW_UNQUALIFIED_NAME                         "${NAME_UNQUALIFIED}"
#define KW_CLASSNAME_MANGLED                        "${CLASSNAME_MANGLED}"
#define KW_BASE_CLASS                               "${BASE_CLASS}"
#define KW_CONTEXT                                  "${CONTEXT}"
#define KW_WRAPPER                                  "${WRAPPER}"

#define KW_NAME_SPACES                              "${PART_NAMESPACES}"
#define KW_CLASS_TEMPLATES                          "${PART_CLASS_TEMPLATES}"
#define KW_WRAPPERS                                 "${PART_WRAPPERS}"
#define KW_INHERITANCE                              "${PART_INHERITANCE}"
#define KW_REGISTER_CLASSES                         "${PART_REGISTER_CLASSES}"
#define KW_REGISTER_NS                              "${PART_REGISTER_NS}"

#define KW_LOCALS                                   "${LOCALS}"
#define KW_MARSHAL_INPUT                            "${MARSHAL_INPUT}"
#define KW_ACTION                                   "${ACTION}"
#define KW_MARSHAL_OUTPUT                           "${MARSHAL_OUTPUT}"

V8Emitter::V8Emitter() 
    : JSEmitter(), 
      GLOBAL(NewString("global")),
      namespaces(NewHash())
{
}

V8Emitter::~V8Emitter()
{
    Delete(GLOBAL);
    Delete(namespaces);
}

int V8Emitter::Initialize(Node *n)
{
 
    /* Get the output file name */
    String *outfile = Getattr(n,"outfile");
    f_wrap_cpp = NewFile(outfile, "w", SWIG_output_files());
    if (!f_wrap_cpp) {
       FileErrorDisplay(outfile);
       SWIG_exit(EXIT_FAILURE);
    }

    f_runtime = NewString("");
    f_header = NewString("");
    f_class_templates = NewString("");
    f_wrapper = NewString("");
        
    f_init_namespaces = NewString("");
    f_init_class_templates = NewString("");
    f_init_wrappers = NewString("");
    f_init_inheritance = NewString("");
    f_init_register_classes = NewString("");
    f_init_register_namespaces = NewString("");

    // note: this is necessary for built-in generation of swig runtime code
    Swig_register_filebyname("runtime", f_runtime);

    return SWIG_OK;
}

int V8Emitter::Dump(Node *n)
{
     /* Get the module name */
    String* module = Getattr(n,"name");

   // write the swig banner
    Swig_banner(f_wrap_cpp);

    Printv(f_wrap_cpp, f_runtime, "\n", 0);
    Printv(f_wrap_cpp, f_header, "\n", 0);
    Printv(f_wrap_cpp, f_class_templates, "\n", 0);
    Printv(f_wrap_cpp, f_wrapper, "\n", 0);

    // compose the initializer function using a template
    // filled with sub-parts
    Template initializer(GetTemplate(V8_INITIALIZER));
    initializer.Replace(KW_MODULE_NAME,       module)
               .Replace(KW_NAME_SPACES,       f_init_namespaces)
               .Replace(KW_CLASS_TEMPLATES,   f_init_class_templates)
               .Replace(KW_WRAPPERS,          f_init_wrappers)
               .Replace(KW_INHERITANCE,       f_init_inheritance)
               .Replace(KW_REGISTER_CLASSES,  f_init_register_classes)
               .Replace(KW_REGISTER_NS,       f_init_register_namespaces);
    Wrapper_pretty_print(initializer.str(), f_wrap_cpp);

    return SWIG_OK;
}

int V8Emitter::Close()
{
    Delete(f_runtime);
    Delete(f_header);
    Delete(f_class_templates);
    Delete(f_wrapper);
    Delete(f_init_namespaces);
    Delete(f_init_class_templates);
    Delete(f_init_wrappers);
    Delete(f_init_inheritance);
    Delete(f_init_register_classes);
    Delete(f_init_register_namespaces);    
    ::Close(f_wrap_cpp);
    Delete(f_wrap_cpp);
    
    return SWIG_OK;
}

int V8Emitter::SwitchContext(Node *n)
{
    String* scope = Swig_scopename_prefix(Getattr(n, "name"));
    
    if (scope) {
        // if the scope is not yet registered
        // create all scopes/namespaces recursively
        if(!Getattr(namespaces, scope)) {
            CreateNamespace(scope);
        }
        current_context = Getattr(namespaces, scope);
    } else {
        current_context = GLOBAL;
    }
        
    return SWIG_OK;
}

int V8Emitter::CreateNamespace(String* scope) {
    String* parent_scope = Swig_scopename_prefix(scope);
    String* parent_scope_mangled = 0;

    if(!parent_scope) {
        parent_scope_mangled = NewString("global");
    } else {
        parent_scope_mangled = Swig_name_mangle(parent_scope);

    }
    
    if (parent_scope && !Getattr(namespaces, parent_scope)) {
        CreateNamespace(parent_scope);
    }
    
    String* scope_mangled = Swig_string_mangle(scope);
    String* scope_unqualified = Swig_scopename_last(scope);
    Setattr(namespaces, scope, scope_mangled);
    
    // create namespace object and register it to the parent scope
    Template t_create_ns(GetTemplate(V8_CREATE_NAMESPACE));
    t_create_ns.Replace(KW_MANGLED_NAME, scope_mangled);
    Template t_register_ns(GetTemplate(V8_REGISTER_NAMESPACE));
    t_register_ns.Replace(KW_MANGLED_NAME, scope_mangled)
        .Replace(KW_CONTEXT, parent_scope_mangled)
        .Replace(KW_UNQUALIFIED_NAME, scope_unqualified);

    Printv(f_init_namespaces, t_create_ns.str(), 0);
    // prepend in order to achieve reversed order of registration statements
    Insert(f_init_register_namespaces, 0, t_register_ns.str());

    Delete(parent_scope);
    Delete(parent_scope_mangled);
    Delete(scope_unqualified);
    return SWIG_OK;
}

int V8Emitter::EnterClass(Node *n)
{
    current_classname_mangled = Swig_string_mangle(Getattr(n, "name"));
    current_classname_unqualified = Swig_scopename_last(Getattr(n, "name"));

    // emit declaration of a v8 class template
    Template t_decl_class(GetTemplate(V8_DECL_CLASSTEMPLATE));
    t_decl_class.Replace(KW_MANGLED_NAME, current_classname_mangled);
    Printv(f_class_templates, t_decl_class.str(), 0);

    // emit definition of v8 class template
    Template t_def_class(GetTemplate(V8_DEFINE_CLASSTEMPLATE));
    t_def_class.Replace(KW_MANGLED_NAME,     current_classname_mangled)
        .Replace(KW_UNQUALIFIED_NAME, current_classname_unqualified);
    Printv(f_init_class_templates, t_def_class.str(), 0);

    return SWIG_OK;
}

int V8Emitter::ExitClass(Node *n)
{
    //  emit inheritance setup
    Node* baseClass = GetBaseClass(n);
    if(baseClass) {
        Template t_inherit(GetTemplate(V8_INHERIT));
        t_inherit.Replace(KW_MANGLED_NAME,  current_classname_mangled)
         .Replace(KW_BASE_CLASS,    Swig_string_mangle(Getattr(baseClass, "name")));
        Printv(f_init_inheritance, t_inherit.str(), 0);
    }
        
    //  emit registeration of class template
    Template t_register(GetTemplate(V8_REGISTER_CLASS));
    t_register.Replace(KW_MANGLED_NAME,      current_classname_mangled)
     .Replace(KW_UNQUALIFIED_NAME,  current_classname_unqualified)
     .Replace(KW_CONTEXT,           Swig_string_mangle(current_context));
    Printv(f_init_register_classes, t_register.str(), 0);

    Delete(current_classname_mangled);
    Delete(current_classname_unqualified);
    current_classname_mangled = 0;
    current_classname_unqualified = 0;
    
    return SWIG_OK;
}

int V8Emitter::EnterVariable(Node* n)
{
    current_variable_unqualified = Swig_scopename_last(Getattr(n, "name"));
    if(GetFlag(n, "ismember")) {
        current_variable_mangled = NewString("");
        Printf(current_variable_mangled, "%s_%s", current_classname_mangled, current_variable_unqualified);
    } else {
        current_variable_mangled = Swig_string_mangle(Getattr(n, "name"));
    }
        
    return SWIG_OK;
}

int V8Emitter::ExitVariable(Node* n)
{
 
    // TODO: Register variable in context
    
    Delete(current_variable_mangled);
    Delete(current_variable_unqualified);
    current_variable_mangled = 0;
    current_variable_unqualified = 0;
    
    return SWIG_OK;
}

int V8Emitter::EnterFunction(Node* n)
{
    current_function_unqualified = Swig_scopename_last(Getattr(n, "name"));

    if(GetFlag(n, "ismember")) {
        current_function_mangled = NewString("");
        Printf(current_function_mangled, "%s_%s", current_classname_mangled, current_function_unqualified);
    } else {
        current_function_mangled = Swig_string_mangle(Getattr(n, "name"));
    }
        
    return SWIG_OK;
}

int V8Emitter::ExitFunction(Node* n)
{
    // TODO: Register function in context
    
    Delete(current_function_mangled);
    Delete(current_function_unqualified);
    current_function_mangled = 0;
    current_function_unqualified = 0;
    
    return SWIG_OK;
}

int V8Emitter::EmitCtor(Node* n)
{
    // TODO: 
    //  - handle overloaded ctors using a dispatcher
    //  - marshal inputs
    Template t(GetTemplate(V8_CTOR_WRAPPER));
    
    ParmList *params  = Getattr(n,"parms");
    emit_parameter_variables(params, current_wrapper);
    emit_attach_parmmaps(params, current_wrapper);
    
    String* action = Getattr(n, "wrap:action");
    String* input = NewString("");

    t.Replace(KW_MANGLED_NAME,      current_classname_mangled)
     .Replace(KW_UNQUALIFIED_NAME,  current_classname_unqualified)
     .Replace(KW_LOCALS, current_wrapper->locals)
     .Replace(KW_ACTION, action)
     .Replace(KW_MARSHAL_INPUT, input);
     
    Wrapper_pretty_print(t.str(), f_wrapper);
    
    return SWIG_OK;
}

int V8Emitter::EmitDtor(Node* n)
{
    // TODO:
    //  find out how to register a dtor in v8

    Printv(f_wrapper, "/* TODO: Wrap dtor */\n", 0);

    return SWIG_OK;
}

int V8Emitter::EmitGetter(Node *n, bool is_member) {
    Template t_getter(GetTemplate(V8_GETTER));

    Printf(current_wrapper->locals, "%s result;\n", SwigType_str(Getattr(n, "type"), 0));
    
    String* action = emit_action(n);
    String* output = NewString("// TODO: marshal output.\n    ret = v8::Undefined();");
    
    t_getter.Replace(KW_MANGLED_NAME, current_variable_mangled)
     .Replace(KW_LOCALS, current_wrapper->locals)
     .Replace(KW_ACTION, action)
     .Replace(KW_MARSHAL_OUTPUT, output);

    Wrapper_pretty_print(t_getter.str(), f_wrapper);
    
    // clean up
    Delete(output);
    
    return SWIG_OK;
}

int V8Emitter::EmitSetter(Node* n, bool is_member)
{
    Template t_setter(GetTemplate(V8_SETTER));
    
    ParmList *params  = Getattr(n,"parms");
    emit_parameter_variables(params, current_wrapper);
    emit_attach_parmmaps(params, current_wrapper);

    String* action = emit_action(n);
    String* input = NewString("// TODO: marshal input.\n");
    
    t_setter.Replace(KW_MANGLED_NAME, current_variable_mangled)
     .Replace(KW_LOCALS, current_wrapper->locals)
     .Replace(KW_ACTION, action)
     .Replace(KW_MARSHAL_INPUT, input);

    Wrapper_pretty_print(t_setter.str(), f_wrapper);

    // clean up
    Delete(input);

    return SWIG_OK;
}


int V8Emitter::EmitFunction(Node* n, bool is_member)
{
    Template t_function(GetTemplate(V8_FUNCTION));

    String* wrap_name = NewString("");
    Printv(wrap_name, current_function_mangled, 0);
    Setattr(n, "wrap:name", wrap_name);
    
    ParmList *params  = Getattr(n,"parms");
    emit_parameter_variables(params, current_wrapper);
    emit_attach_parmmaps(params, current_wrapper);
    Printf(current_wrapper->locals, "%s result;\n", SwigType_str(Getattr(n, "type"), 0));
       
    String* input = NewString("// TODO: marshal input");
    String* action = emit_action(n);
    String* output = NewString("// TODO: marshal output.\n    ret = v8::Undefined();");
    
    t_function.Replace(KW_MANGLED_NAME, current_function_mangled)
     .Replace(KW_LOCALS, current_wrapper->locals)
     .Replace(KW_ACTION, action)
     .Replace(KW_MARSHAL_INPUT, input)
     .Replace(KW_MARSHAL_OUTPUT, output);

    Wrapper_pretty_print(t_function.str(), f_wrapper);

    // register the function at the specific context
    if (is_member) {
        Template t_register(GetTemplate(V8_REGISTER_MEMBER_FUNCTION));
        t_register.Replace(KW_UNQUALIFIED_NAME, current_function_unqualified)
          .Replace(KW_WRAPPER, wrap_name)
          .Replace(KW_CLASSNAME_MANGLED, current_classname_mangled);
        Printv(f_init_wrappers, t_register.str(), "\n", 0);
    } else {
        // TODO
    }

    // clean up
    Delete(input);
    Delete(output);
    Delete(wrap_name);

    return SWIG_OK;
}

JSEmitter* create_v8_emitter() 
{
    return new V8Emitter();
}

Javascript: Specification of a Code Generator for V8
====================================================

The aim of this is to evolve a specification for a code generator.

## Top Level structure

The generated code consists of the following blocks:

~~~~
<HELPER_FUNCTIONS>

<INCLUDES>

<CLASS_TEMPLATES>

<FUNCTION_WRAPPERS>

<INITIALIZER>

~~~~

- `HELPER_FUNCTIONS`: static, from swg-file
- `INCLUDES`: static, module property
- `CLASS_TEMPLATES`: dynamically growing, on class declarations
- `FUNCTION_WRAPPERS`: dynamically growing, on method declarations
- `INITIALIZER`: dynamically growing, aggregates everything (to be specified in more detail)

## INCLUDES

~~~~
#include <v8.h>

<USER_DEFINED_INCLUDES>
~~~~

`USER_DEFINED_INCLUDES`: a module property

## CLASS_TEMPLATES

Static references to class templates which are (should be) read-only and can be reused.

~~~~
v8::Persistent<v8::FunctionTemplate> SWIGV8_$CLASSNAME;
~~~~

Notes:
 - it is very important to consider namespaces from the beginning.
   `CLASSNAME` should be fully canonical, e.g., `foo_bar_MyClass` for `foo::bar::MyClass`
 - namespaces do not need a function template, as they will not be
   instantiated

## FUNCTION_WRAPPERS

There are different types of function wrappers:

 - Static Functions (global/namespace/class) 
 - Constructors / Destructors
 - Getters / Settters
 - Member Functions

## Static Functions

TODO

## Constructors

~~~~
v8::Handle<v8::Value> $CLASSNAME_new(const v8::Arguments& args) {
    v8::HandleScope scope;
    
    // retrieve the instance
    v8::Handle<v8::Object> self = args.Holder();
    
    // TODO: declare arguments

    //convert JS arguments to C++
    // TODO: apply input typemaps

    $CLASS_LVAL* ptr = new $CLASS_LVAL($ARGS);
    self->SetInternalField(0, v8::External::New(ptr));
    
    return self;        
}
~~~~

- `$CLASS_LVAL`: should be the canonical name of the class, e.g. `ns1::ns2::MyClass`
- `$ARGS`: arguments should be declared at the beginning and checked and set in the
   input typemap block

## Destructors

TODO

## Getters

~~~~
v8::Handle<v8::Value> $CLASSNAME_get$VARNAME(v8::Local<v8::String> property, const v8::AccessorInfo& info) {
    v8::HandleScope scope;

    // retrieve pointer to C++-this
    $CLASS_LVAL* self = SWIGV8_UnwrapThisPointer<$CLASS_LVAL>(info.Holder());
    $RET_LVAL retval = self->$VARNAME;
    
    v8::Handle<v8::Value> ret = <output_mapping(retval)>;
    return scope.Close(ret);
}
~~~~

- TODO: output typemapping

## Setters

~~~~
void $CLASSNAME_set$VARNAME(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info) {
    v8::HandleScope scope;

    // retrieve pointer to this
    $CLASS_LVAL* self = SWIGV8_UnwrapThisPointer<$CLASS_LVAL>(info.Holder());

    // TODO: declare input arg
    
    // map java-script type to C++ type    
    self->$VARNAME = <input_typemapping>;

}
~~~~

TODO: 
 - input type mapping should be addressed in extra step, together with type check

## Member functions

~~~~
v8::Handle<v8::Value> $CLASSNAME_$FUNCTIONNAME(const v8::Arguments& args)
{
    v8::HandleScope scope;

    $CLASS_LVAL* self = SWIGV8_UnwrapThisPointer<$CLASS_LVAL>(args.Holder());

    // TODO: declare input args

    //convert JS arguments to C++
    // TODO: input typemappings and type checking

    //call C++ method
    $RET_LTYPE result = self->$FUNCTIONNAME($ARGS);

    //convert C++ JS arguments to C++
    v8::Handle<v8::Value> ret = <output_typemapping>;

    return scope.Close(ret);
}
~~~~

- if the function does not have a return value, return v8::Undefined

## Initializer

~~~~
void $MODULENAME_Initialize(v8::Handle<v8::Context> context)
{
    v8::HandleScope scope;

    // register the module in globale context
    v8::Local<v8::Object> global = context->Global();

    <CREATE_NAME_SPACES>
    
    <CREATE_CLASS_TEMPLATES>

    <ADD_CLASS_METHODS>

    <INHERITANCES>

    <REGISTER_CLASSES>
}
~~~~

## Namespaces

Namespaces are objects without class templates. I.e., instances are created,
referenced locally, used as contexts for other registrations, and stored
in the according parent contexts.

## Create Class Template

~~~~
    SWIGV8_$CLASSNAME = SWIGV8_CreateClassTemplate("$LOCAL_CLASSNAME" , $CLASSNAME_new);
~~~~

- `LOCAL_CLASSNAME`: the class name without context, i.e., namespaces

## Add Member Function

~~~~
    SWIGV8_AddClassMethod(SWIGV8_$CLASSNAME, "$METHODNAME", $METHOD_WRAPPER);
~~~~

- `METHODNAME`: the name of the function as in C++
- `METHOD_WRAPPER`: the name of the generated wrapper function
   TODO: specify different versions

## Add Property

~~~~
    SWIGV8_AddProperty(SWIGV8_$CLASSNAME, "$VARNAME", $GET_WRAPPER, $SET_WRAPPER);
~~~~

- `GET_WRAPPER`: the name of the generated wrapper for the property getter
- `SET_WRAPPER`: the name of the generated wrapper for property setter; optional (i.e., maybe `NULL`)

## Inheritance

~~~~
    SWIGV8_$CLASSNAME->Inherit(SWIGV8_$SUPERCLASS);
~~~~

- Note: multiple inheritance is not possible; thus we will always take the first parent class

## Register class

~~~~
    $CONTEXT->Set(v8::String::NewSymbol("$LOCAL_CLASSNAME"), SWIGV8_$CLASSNAME->GetFunction());
~~~~

- Note: every class template has an associated ctor function wrapper, which is registered here
- `CONTEXT`: either global, or the according namespace instance

## HELPER_FUNCTIONS

A lot of boiler-plate code can be shifted into static helper functions:

~~~~

/**
 * Creates a class template for a class without extra initialization function. 
 */
v8::Persistent<v8::FunctionTemplate> SWIGV8_CreateClassTemplate(const char* symbol) {
    v8::Local<v8::FunctionTemplate> class_templ = v8::FunctionTemplate::New();
    class_templ->SetClassName(v8::String::NewSymbol(symbol));

    v8::Handle<v8::ObjectTemplate> inst_templ = class_templ->InstanceTemplate();
    inst_templ->SetInternalFieldCount(1);

    return v8::Persistent<v8::FunctionTemplate>::New(class_templ);
}

/**
 * Creates a class template for a class with specified initialization function. 
 */
v8::Persistent<v8::FunctionTemplate> SWIGV8_CreateClassTemplate(const char* symbol, v8::InvocationCallback _func) {
    v8::Local<v8::FunctionTemplate> class_templ = v8::FunctionTemplate::New(_func);
    class_templ->SetClassName(v8::String::NewSymbol(symbol));

    v8::Handle<v8::ObjectTemplate> inst_templ = class_templ->InstanceTemplate();
    inst_templ->SetInternalFieldCount(1);

    return v8::Persistent<v8::FunctionTemplate>::New(class_templ);
}

/**
 * Sets the pimpl data of a V8 class. 
 */
v8::Handle<v8::Value> V8GeneratorUtils::SetInstance(const v8::Arguments& args, void* data) {
    v8::HandleScope scope;

    v8::Handle<v8::Object> self = args.Holder();
    self->SetInternalField(0, v8::External::New(data));

    return self;
}

/**
 * Registers a class method with given name for a given class template. 
 */
void V8GeneratorUtils::AddClassMethod(v8::Handle<v8::FunctionTemplate> class_templ, const char* symbol, v8::InvocationCallback _func) {
    v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->PrototypeTemplate();
    proto_templ->Set(v8::String::NewSymbol(symbol), v8::FunctionTemplate::New(_func));    
}

/**
 * Registers a class property with given name for a given class template. 
 */
void V8GeneratorUtils::AddProperty(v8::Handle<v8::FunctionTemplate> class_templ, const char* varname, v8::AccessorGetter getter, v8::AccessorSetter setter) {
    v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->InstanceTemplate();
    proto_templ->SetAccessor(v8::String::New(varname), getter, setter);
}

~~~~

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

### INCLUDES

~~~~
#include <v8.h>

<USER_DEFINED_INCLUDES>
~~~~

`USER_DEFINED_INCLUDES`: a module property

### CLASS_TEMPLATES

Static references to class templates which are (should be) read-only and can be reused.

~~~~
v8::Persistent<v8::FunctionTemplate> SWIGV8_${NAME_MANGLED};
~~~~

Notes:
 - it is very important to consider namespaces from the beginning.
   `NAME_MANGLED` is the mangled qualified class name, e.g., `foo_bar_MyClass` for `foo::bar::MyClass`,
   which is retrieved ny `Swig_string_mangle(Getattr(n, "name"))`
 - namespaces do not need a function template, as they will not be
   instantiated

## FUNCTION_WRAPPERS

There are different types of function wrappers:

 - Global Functions (global/namespace/class) 
 - Constructors / Destructors
 - Getters / Settters
 - Member Functions

### Global Functions

~~~~
v8::Handle<v8::Value> wrap_${NAME_MANGLED}(const v8::Arguments &args) {
    v8::HandleScope scope;
    v8::Handle<v8::Value> ret;
    ${LOCALS}
    ${CODE}
    return scope.Close(ret);
}
~~~~

- `LOCALS`: declarations for input and output arguments
- `CODE` contains input marshalling, the action, and output marshalling

### Constructors

~~~~
v8::Handle<v8::Value> ${NAME_MANGLED}_new(const v8::Arguments& args) {
    v8::HandleScope scope;
    v8::Handle<v8::Object> self = args.Holder();
    ${LOCALS}
    ${CODE}
    self->SetInternalField(0, v8::External::New(ptr));
    return self;
}
~~~~

- `LOCALS`: declarations for input arguments
- `CODE` contains input marshalling, and the action

### Destructors

TODO: I haven't found out yet how a descrtuctor can be registered

### Getters

~~~~
v8::Handle<v8::Value> ${NAME_MANGLED}_get(v8::Local<v8::String> property, const v8::AccessorInfo& info) {
    v8::HandleScope scope;
    v8::Handle<v8::Object> ret;
    ${LOCALS}
    ${CODE}
    return scope.Close(ret);
}
~~~~

- `NAME_MANGLED`: the qualified mangled name of the variable, E.g., `foo::x -> foo_x`,  `A.x -> A_x`
- `LOCALS`: declarations for output arguments
- `CODE` contains the action, and output marshalling

### Setters

~~~~
void ${NAME_MANGLED}_set(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info) {
    ${LOCALS}
    ${CODE}
}
~~~~
- `NAME_MANGLED`: the qualified mangled name of the variable, E.g., `foo::x -> foo_x`,  `A.x -> A_x`
- `LOCALS`: declarations for input arguments
- `CODE` contains input marshalling, and the action

### Functions

~~~~
v8::Handle<v8::Value> ${NAME_MANGLED}(const Arguments &args) {
    v8::HandleScope scope;
    v8::Handle<v8::Object> ret;
    ${LOCALS}
    ${CODE}
    return scope.Close(ret);
}
~~~~

- `NAME_MANGLED`: the qualified mangled name of the variable, E.g., `foo::x -> foo_x`,  `A.x -> A_x`
- `LOCALS`: declarations for input arguments
- `CODE` contains input marshalling, the action, and output marshalling


### Overloading

TODO: if a function or a ctor is overloaded, a dispatcher function
must be generated which calls overloading wrappers depending on number
and type of input arguments.


## Initializer

~~~~
void ${MODULE}_Initialize(v8::Handle<v8::Context> context)
{
    v8::HandleScope scope;

    // register the module in globale context
    v8::Local<v8::Object> global = context->Global();

    ${PART_NAMESPACES}

    ${PART_CLASS_TEMPLATES}

    ${PART_WRAPPERS}

    ${PART_INHERITANCE}

    ${PART_REGISTER_CLASSES}
    
    ${PART_REGISTER_NS}
}
~~~~

### Namespaces

Namespaces are objects without class templates. I.e., instances are created,
referenced locally, used as contexts for other registrations, and stored
in the according parent contexts.

~~~~~
v8::Handle<v8::ObjectTemplate> ${NAME_MANGLED} = v8::ObjectTemplate::New();
~~~~~

### Class Templates

~~~~
SWIGV8_${NAME_MANGLED} = SWIGV8_CreateClassTemplate("${NAME_UNQUALIFIED}" , ${NAME_MANGLED}_new);
~~~~

- `NAME_UNQUALIFIED`: the class name without context, i.e., namespaces

### Inheritance

~~~~
SWIGV8_${NAME_MANGLED}->Inherit(SWIGV8_${BASE_CLASS});
~~~~

- Note: multiple inheritance is not possible; thus we will always take the first parent class

### Registration

The registration part consists of registering classes at contexts (i.e., global or namespace),
methods and properties at classes or contexts, and namespaces as objects at
parent contexts. 

#### Global Variable

~~~~
${CONTEXT}->SetAccessor(v8::String::NewSymbol("${NAME_UNQUALIFIED}"), ${GETTER}, ${SETTER});
~~~~

- `CONTEXT`: either global, or the according namespace template
- `${SETTER} = 0` for read-only variables

#### Global Function

~~~~
SWIGV8_AddGlobalFunction(${CONTEXT}, "${NAME_UNQUALIFIED}", wrap_${NAME_QUALIFIED});
~~~~

- `CONTEXT`: either global, or the according namespace template

#### Class

~~~~
${CONTEXT}->Set(v8::String::NewSymbol("${NAME_UNQUALIFIED}", SWIGV8_${NAME_MANGLED}->GetFunction()));
~~~~

- Note: every class template has an associated ctor function wrapper, which is registered here
- `CONTEXT`: either global, or the according namespace instance

#### Class method

~~~~
SWIGV8_AddClassMethod(SWIGV8_${CLASSNAME_MANGLED}, "${NAME_UNQUALIFIED}", wrap_${NAME_MANGLED});
~~~~

Note: implemented in static helper function

#### Class variable

~~~~
SWIGV8_AddProperty(SWIGV8_${CLASSNAME_MANGLED}, "${NAME_UNQUALIFIED}", ${GETTER}, ${SETTER});
~~~~

- `GETTER`: the name of the generated wrapper for the property getter
- `SETTER`: the name of the generated wrapper for property setter; optional (i.e., maybe `NULL`)

### Namespace

~~~~
${CONTEXT}->Set(v8::String::NewSymbol("${NAME_UNQUALIFIED}", ${NAME_MANGLED}->NewInstance()));
~~~~

Note: it is important to register the namespace objects in reverse order,
e.g.,

~~~~
namespace foo { 
    namespace bar {}
}
~~~~

would be registered in this order:

~~~~
foo->Set(v8::String::NewSymbol("bar", bar->NewInstance()));
global->Set(v8::String::NewSymbol("foo", foo->NewInstance()));
~~~~

## HELPER_FUNCTIONS

A lot of boiler-plate code can be shifted into static helper functions:

~~~~

/**
 * Creates a class template for a class without extra initialization function. 
 */
v8::Persistent<v8::FunctionTemplate> SWIGV8_CreateClassTemplate(const char* symbol, v8::InvocationCallback func)
{
    v8::Local<v8::FunctionTemplate> class_templ = v8::FunctionTemplate::New(func);
    class_templ->SetClassName(v8::String::NewSymbol(symbol));

    v8::Handle<v8::ObjectTemplate> inst_templ = class_templ->InstanceTemplate();
    inst_templ->SetInternalFieldCount(1);

    return v8::Persistent<v8::FunctionTemplate>::New(class_templ);
}

/**
 * Registers a class method with given name for a given class template. 
 */
void SWIGV8_AddMemberFunction(v8::Handle<v8::FunctionTemplate> class_templ, 
                              const char* symbol, 
                              v8::InvocationCallback func) 
{
    v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->PrototypeTemplate();
    proto_templ->Set(v8::String::NewSymbol(symbol), v8::FunctionTemplate::New(func));
}

/**
 * Registers a class property with given name for a given class template. 
 */
void SWIGV8_AddMemberVariable(v8::Handle<v8::FunctionTemplate> class_templ, 
                              const char* varname, 
                              v8::AccessorGetter getter, 
                              v8::AccessorSetter setter) 
{
    v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->InstanceTemplate();
    proto_templ->SetAccessor(v8::String::New(varname), getter, setter);
}


/**
 * Adds a property with given name to a given context. 
 */
void SWIGV8_AddGlobalVariable(v8::Handle<v8::Object> context, 
                              const char* varname, 
                              v8::AccessorGetter getter, 
                              v8::AccessorSetter setter) 
{
    context->SetAccessor(v8::String::NewSymbol(varname), getter, setter);
}

/**
 * Adds a function with given name to a given context. 
 */
void SWIGV8_AddGlobalFunction(v8::Handle<v8::Object> context, 
                              const char* symbol, 
                              v8::InvocationCallback func) 
{
    context->Set(v8::String::NewSymbol(symbol), v8::FunctionTemplate::New(func)->GetFunction());
}

template <class T>
static T* SWIGV8_UnwrapThisPointer (v8::Handle<v8::Object> handle)
{
    // assert(!handle.IsEmpty());
    // assert(handle->InternalFieldCount() > 0);
    v8::Local<v8::External> wrap = v8::Local<v8::External>::Cast(handle->GetInternalField(0));
    return static_cast<T*>(wrap->Value());
}

~~~~

-------------------------

Examples
========

In this chapter manually coded wrappers are presented.
This has been useful for studying the addressed code generation on basis
of examples.

## Global variable

~~~~~
static double Foo = 42.0;

void Foo_set(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info) {
    v8::HandleScope scope;
    double arg1 ;
    arg1 = value->NumberValue();
    Foo = arg1;
}

v8::Handle<v8::Value> Foo_get(v8::Local<v8::String> property, const v8::AccessorInfo& info) {
  v8::HandleScope scope;
  v8::Handle<v8::Value> ret;
  double result;

  result = Foo;
  
  ret = v8::Number::New(result);
  return scope.Close(ret);
}

int GlobalVar_Initialize(v8::Handle<v8::Context> context) {
    
    v8::Local<v8::Object> global = context->Global();
    global->SetAccessor(v8::String::New("Foo"), Foo_get, Foo_set);

    return 0;
}
~~~~~

## Global functions

~~~~~

static double foo(int bla) {
    return (bla * 2.1);
}

v8::Handle<v8::Value> wrap_foo(const v8::Arguments &args) {
    v8::HandleScope scope;
    v8::Handle<v8::Value> ret;

    int arg1 ;
    double result;
    
    arg1 = args[0]->Int32Value();

    result = foo(arg1);

    ret = v8::Number::New(result);
    
    return scope.Close(ret);
}

int GlobalFunc_Initialize(v8::Handle<v8::Context> context) {
    
    v8::Local<v8::Object> global = context->Global();
        
    global->Set(v8::String::NewSymbol("foo"), v8::FunctionTemplate::New(wrap_foo)->GetFunction());

    return 0;
}
~~~~~


## Namespaces

~~~~~

namespace foo {
    static double bar = 42.0;
}

void foo_bar_set(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info) {
    v8::HandleScope scope;

    double arg1 ;
    arg1 = value->NumberValue();
    foo::bar = arg1;

}

v8::Handle<v8::Value> foo_bar_get(v8::Local<v8::String> property, const v8::AccessorInfo& info) {
  v8::HandleScope scope;
  v8::Handle<v8::Value> ret;
  double result;

  result = foo::bar;
  
  ret = v8::Number::New(result);
  return scope.Close(ret);
}

int Namespace_Initialize(v8::Handle<v8::Context> context) {
    
    v8::Local<v8::Object> global = context->Global();
    
    v8::Handle<v8::ObjectTemplate> foo = v8::ObjectTemplate::New();

    foo->SetAccessor(v8::String::New("bar"), foo_bar_get, foo_bar_set);
    
    global->Set(v8::String::New("foo"), foo->NewInstance());
    return 0;
}

~~~~~

## Class

~~~~~

class A {
public:
    A() {
        x = 42;
    }
    
    ~A() {}

    double foo(bool a) {
        if(a)
            return 11.11;
        else
            return 22.22;
    }
    
    int x;
};

v8::Handle<v8::Value> A_new(const v8::Arguments& args) {
    v8::HandleScope scope;
    v8::Handle<v8::Object> self = args.Holder();
    A *result;
    result = new A();
    self->SetInternalField(0, v8::External::New(result));
    return self;        
}

void A_x_set(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info) {
    v8::HandleScope scope;
    A *arg1;
    int arg2;
    
    arg1 = SWIGV8_UnwrapThisPointer<A>(info.Holder());
    arg2 = value->Int32Value();
    
    arg1->x = arg2;

}

v8::Handle<v8::Value> A_x_get(v8::Local<v8::String> property, const v8::AccessorInfo& info) {
    v8::HandleScope scope;
    v8::Handle<v8::Value> jsresult;
    A *arg1;
    int result;

    arg1 = SWIGV8_UnwrapThisPointer<A>(info.Holder());
    result = arg1->x;
  
    jsresult = v8::Int32::New(result);
    return scope.Close(jsresult);
}

v8::Handle<v8::Value> wrap_A_foo(const v8::Arguments& args)
{
    v8::HandleScope scope;
    v8::Handle<v8::Value> jsresult;
    A *arg1;
    double arg2;
    double result;

    arg1 = SWIGV8_UnwrapThisPointer<A>(args.Holder());
    arg2 = args[0]->NumberValue();
    
    result = arg1->foo(arg2);
    
    jsresult = v8::Number::New(result);
    return scope.Close(jsresult);
}

int Class_Initialize(v8::Handle<v8::Context> context) {
    
    v8::Local<v8::Object> global = context->Global();
    
    v8::Persistent<v8::FunctionTemplate> class_A = SWIGV8_CreateClassTemplate("A", A_new);
    SWIGV8_AddMemberVariable(class_A, "x", A_x_get, A_x_set);
    SWIGV8_AddMemberFunction(class_A, "foo", wrap_A_foo);
    
    global->Set(v8::String::NewSymbol("A"), class_A->GetFunction());
    
    return 0;
}

~~~~~

## Static variables and functions

Static variables and functions are implemented similar to global ones.
They are added to the class object instead of the class template.
Therefore, these are only accessible via the class object and not via
instances of this class.

~~~~~

class A {
public:
    A() {
        x = 7;
    }
    
    ~A() {}

    static int foo() {
        return 42;
    }
    
    static int x;
};

int A::x = 7;

v8::Handle<v8::Value> A_new(const v8::Arguments& args) {
    v8::HandleScope scope;
    v8::Handle<v8::Object> self = args.Holder();
    A *result;
    result = new A();
    self->SetInternalField(0, v8::External::New(result));
    return self;
}

void A_x_set(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info) {
    v8::HandleScope scope;
    int arg1;
    
    arg1 = value->Int32Value();
    
    A::x = arg1;

}

v8::Handle<v8::Value> A_x_get(v8::Local<v8::String> property, const v8::AccessorInfo& info) {
    v8::HandleScope scope;
    v8::Handle<v8::Value> jsresult;
    int result;

    result = A::x;
  
    jsresult = v8::Int32::New(result);
    return scope.Close(jsresult);
}

v8::Handle<v8::Value> wrap_A_foo(const v8::Arguments& args)
{
    v8::HandleScope scope;
    v8::Handle<v8::Value> jsresult;
    int result;

    result = A::foo();
    
    jsresult = v8::Number::New(result);
    return scope.Close(jsresult);
}

int Class_Initialize(v8::Handle<v8::Context> context) {
    
    v8::Local<v8::Object> global = context->Global();
    
    v8::Persistent<v8::FunctionTemplate> classtempl_A = SWIGV8_CreateClassTemplate("A", A_new);
        
    v8::Handle<v8::Object> class_A = classtempl_A->GetFunction();

    SWIGV8_AddGlobalVariable(class_A, "x", A_x_get, A_x_set);
    SWIGV8_AddGlobalFunction(class_A, "foo", wrap_A_foo);
    
    global->Set(v8::String::NewSymbol("A"), class_A);
    
    return 0;
}

~~~~~

## Inheritance

~~~~~
class A {
public:
    A() {}
    
    ~A() {}

    double foo() {
        return 11.11;
    }
};

class B: public A {
public:
    B() {}
    ~B() {}
    
    int bar() {
        return 7;
    }
};

... (left out function wrappers) ... 

int Class_Initialize(v8::Handle<v8::Context> context) {
    
    v8::Local<v8::Object> global = context->Global();
    
    v8::Persistent<v8::FunctionTemplate> class_A = SWIGV8_CreateClassTemplate("A", A_new);
    v8::Persistent<v8::FunctionTemplate> class_B = SWIGV8_CreateClassTemplate("B", B_new);

    SWIGV8_AddMemberFunction(class_A, "foo", wrap_A_foo);
    SWIGV8_AddMemberFunction(class_B, "bar", wrap_B_bar);
    
    class_B->Inherit(class_A);
    
    global->Set(v8::String::NewSymbol("A"), class_A->GetFunction());
    global->Set(v8::String::NewSymbol("B"), class_B->GetFunction());
    
    return 0;
}
~~~~~

## String arguments

At a first stage all strings are treated as Utf8.
For proper handling strings as return values I have to study
other modules.

~~~~~
int my_strlen(const char* s) {
    return strlen(s);
}

// creates a new string
const char* foo(int a) {
    char* result = new char[a+1];
    result[a] = 0;
    memset(result, 'a', a);
    return result;
}

v8::Handle<v8::Value> wrap_my_strlen(const v8::Arguments& args)
{
    v8::HandleScope scope;
    v8::Handle<v8::Value> jsresult;
    const char* arg1;
    int result;

    v8::String::Utf8Value utf8(args[0]);
    
    result = my_strlen(*utf8);
    
    jsresult = v8::Number::New(result);
    return scope.Close(jsresult);
}

v8::Handle<v8::Value> wrap_foo(const v8::Arguments& args)
{
    v8::HandleScope scope;
    v8::Handle<v8::Value> jsresult;
    int arg1;
    const char* result;

    arg1 = args[0]->Int32Value();
    result = foo(arg1);
    
    jsresult = v8::String::New(result);
    
    return scope.Close(jsresult);
}

int Strings_Initialize(v8::Handle<v8::Context> context) {
    
    v8::Local<v8::Object> global = context->Global();
    
    SWIGV8_AddGlobalFunction(global, "strlen", wrap_my_strlen);
    SWIGV8_AddGlobalFunction(global, "foo", wrap_foo);
    
    return 0;
}
~~~~~

-------------------------

Control flow analysis
=====================

## Global variables

### Example:
~~~~
int x;

namespace foo {
    double y;
}
~~~~

### Control flow:
Command:
~~~~
swig -analyze -c++ functionWrapper +before globalvariableHandler +before example.i
~~~~

~~~~
enter top() of example
enter variableHandler() of x
enter globalvariableHandler() of x
    | sym:name     - "x"
    | name         - "x"
    | type         - "int"

    enter variableWrapper() of x
    
        enter functionWrapper() of x
            | name         - "x"
            | sym:name     - "x_set"
            | parms        - int
            | wrap:action  - "x = arg1;"
            | type         - "void"
        exit functionWrapper() of x

        enter functionWrapper() of x
            | name         - "x"
            | sym:name     - "x_get"
            | type         - "int"
        exit functionWrapper() of x
    exit variableWrapper() of x
exit globalvariableHandler() of x
exit variableHandler() of x

enter variableHandler() of foo::y
enter globalvariableHandler() of foo::y
    | sym:name     - "y"
    | name         - "foo::y"
    | type         - "double"

    enter variableWrapper() of foo::y
        enter functionWrapper() of foo::y
            | name         - "foo::y"
            | sym:name     - "y_set"
            | parms        - double
            | wrap:action  - "foo::y = arg1;"
            | type         - "void"
        exit functionWrapper() of foo::y
        
        enter functionWrapper() of foo::y
            | name         - "foo::y"
            | sym:name     - "y_get"
            | wrap:action  - "result = (double)foo::y;"
            | type         - "double"
        exit functionWrapper() of foo::y
    exit variableWrapper() of foo::y
exit globalvariableHandler() of foo::y
exit variableHandler() of foo::y
exit top() of example

~~~~

## Simple class

### Example:

~~~~
class A {
public:
    A();
    ~A();
};

namespace foo {
    class B {
    };
}
~~~~

### Control flow:

~~~~
enter top() of example
    enter classHandler() of A
    enter constructorHandler() of A
        enter functionWrapper() of A
            | name         - "A"
            | sym:name     - "new_A"
            | access       - "public"
            | wrap:action  - "result = (A *)new A();"
            | type         - "p.A"
        exit functionWrapper() of A
    exit constructorHandler() of A
    enter destructorHandler() of ~A
        enter functionWrapper() of ~A
            | name         - "~A"
            | sym:name     - "delete_A"
            | parms        - A *
            | wrap:action  - "delete arg1;"
        exit functionWrapper() of ~A
    exit destructorHandler() of ~A
exit classHandler() of A
enter classHandler() of foo::B
    enter constructorHandler() of foo::B::B
        enter functionWrapper() of foo::B::B
            | name         - "foo::B::B"
            | sym:name     - "new_B"
            | access       - "public"
            | wrap:action  - "result = (foo::B *)new foo::B();"
            | type         - "p.foo::B"
        exit functionWrapper() of foo::B::B
    exit constructorHandler() of foo::B::B
    enter destructorHandler() of foo::B::~B
        enter functionWrapper() of foo::B::~B
            | name         - "foo::B::~B"
            | sym:name     - "delete_B"
            | parms        - foo::B *
            | wrap:action  - "delete arg1;"
            | type         - "void"
        exit functionWrapper() of foo::B::~B
    exit destructorHandler() of foo::B::~B
exit classHandler() of foo::B
exit top() of example

~~~~

### Example

~~~~
class A {
public:
    int x;
};
~~~~


### Control flow

~~~~
enter top() of example
enter classHandler() of A
    enter variableHandler() of x
        enter membervariableHandler() of x
            enter functionWrapper() of x
                | name         - "x"
                | sym:name     - "A_x_set"
                | access       - "public"
                | parms        - A *,int
                | wrap:action  - "if (arg1) (arg1)->x = arg2;"
                | type         - "void"
                | memberset    - "1"
            exit functionWrapper() of x
            enter functionWrapper() of x
                | name         - "x"
                | sym:name     - "A_x_get"
                | access       - "public"
                | parms        - A *
                | wrap:action  - "result = (int) ((arg1)->x);"
                | type         - "int"
                | memberset    - "1"
                | memberget    - "1"
            exit functionWrapper() of x
        exit membervariableHandler() of x
    exit variableHandler() of x    
    enter constructorHandler() of A::A
        enter functionWrapper() of A::A
        exit functionWrapper() of A::A
    exit constructorHandler() of A::A
    enter destructorHandler() of A::~A
        enter functionWrapper() of A::~A
        exit functionWrapper() of A::~A
    exit destructorHandler() of A::~A
exit classHandler() of A
exit top() of example
~~~~

## Class method

### Example

~~~~
class A {
public:
    void foo(int x, double y);
private:
    void bar();
};
~~~~

### Control flow

~~~~
enter top() of example
enter classHandler() of A
    enter functionHandler() of foo
        enter memberfunctionHandler() of foo
            enter functionWrapper() of foo
                | name         - "foo"
                | sym:name     - "A_foo"
                | access       - "public"
                | parms        - A *,int,double
                | wrap:action  - "(arg1)->foo(arg2,arg3);"
                | type         - "void"
            exit functionWrapper() of foo
        exit memberfunctionHandler() of foo
    exit functionHandler() of foo
...
exit classHandler() of A
exit top() of example
~~~~

## Static class variable and method

### Example

~~~~
class A {
public:
    static int x;
    
    static void foo();
};
~~~~

### Control flow

~~~~
enter top() of example
enter classHandler() of A
    enter variableHandler() of x
        enter staticmembervariableHandler() of x
            enter variableWrapper() of A::x
                enter functionWrapper() of A::x
                    | name         - "A::x"
                    | sym:name     - "A_x_set"
                    | parms        - int
                    | wrap:action  - "A::x = arg1;"
                    | type         - "void"
                exit functionWrapper() of A::x
                enter functionWrapper() of A::x
                    +++ cdecl ----------------------------------------
                    | name         - "A::x"
                    | ismember     - "1"
                    | sym:name     - "A_x_get"
                    | variableWrapper:sym:name - "A_x"
                    | wrap:action  - "result = (int)A::x;"
                    | type         - "int"
                exit functionWrapper() of A::x
            exit variableWrapper() of A::x
        exit staticmembervariableHandler() of x
    exit variableHandler() of x
    enter functionHandler() of foo
        enter staticmemberfunctionHandler() of foo
            enter globalfunctionHandler() of A::foo
                enter functionWrapper() of A::foo
                    | name         - "A::foo"
                    | sym:name     - "A_foo"
                    | wrap:action  - "A::foo();"
                    | type         - "void"
                exit functionWrapper() of A::foo
            exit globalfunctionHandler() of A::foo
        exit staticmemberfunctionHandler() of foo
    exit functionHandler() of foo
    enter constructorHandler() of A::A
    exit constructorHandler() of A::A
    enter destructorHandler() of A::~A
    exit destructorHandler() of A::~A
exit classHandler() of A
exit top() of example
~~~~

## Inheritance

### Example

~~~~
class A {
};

class B: public A {
};
~~~~

### Control flow

~~~~
enter top() of example
enter classHandler() of A
    +++ class ----------------------------------------
    | name         - "A"
    | sym:name     - "A"
...
exit classHandler() of A
enter classHandler() of B
    | name         - "B"
    | sym:name     - "B"
    | privatebaselist - 0xf1238f10
    | protectedbaselist - 0xf1238ef0
    | baselist     - 0xf1238ed0
    | bases        - 0xf1239830
    | allbases     - 0xf1239c30
...
exit classHandler() of B
exit top() of example
~~~~

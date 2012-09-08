% SWIG AND JAVASCRIPT
  
# Overview

This chapter describes SWIG support for Javascript.
The module is designed to support JavascriptCore and V8 as target engine.
Currently only JavascriptCore support is implemented.
JavaScriptCore is the built-in JavaScript engine for WebKit, whereas V8 is the engine used by Chromium.

JavaScript is a prototype-based scripting language that is dynamic, weakly typed and has first-class functions. Its arguably the most popular language for web development. C++, on the other hand, is statically typed, compiled, general purpose programming language.
The approach I followed here is "Test driven" where I have written the examples/test-cases to be supported for Javascript one-by-one and implemented the required module files in parallel. 
The support for Javascript would be added similar to other supported target languages in swig. Swig comes with an "Examples" directory for Javascript like other supported language. The directory contains examples for every supported feature of the target language.  There is also a test-suite directory for javascript which contains additional tests. 

# Preliminaries

In order to use this module, you will need to have installed javascriptcore and you can install it by installing package libwebkit-dev 
You can find out some necessary compiler/linker flag by

    pkg-config javascriptcoregtk-1.0 --cflags --libs

## Using the module

To generate an extension for JavascriptCore one would call swig as follows

~~~~

swig -c++ -javascript -jsc example.i

~~~~

This generates a C++ source file containing the wrapper.

##  How does Javascript talk to C++?

JavascriptCore provides a C-API which allows to extend a Javascript interpreter with native methods and structures. Normally, this is used to implement the builtin features of the language. However, by extending the interpreter, it is also possible to add your own commands and variables. A reference manual of this API can be found 
[here](http://developer.apple.com/library/mac/#documentation/Carbon/Reference/WebKit_JavaScriptCore_Ref/_index.html).

Typically, when you add a new command to the javascript interpreter you need to do two things: first you need to write a special "wrapper" function that serves as the glue between the interpreter and the underlying C function. Then you need to give the interpreter information about the wrapper by providing details about the name of the function, arguments, and so forth. The next few sections illustrate the process.

##  Wrapper functions

Suppose you have an ordinary C function like this :

~~~~

int fact(int n) {
	if (n <= 1) return 1;
	else return n*fact(n-1);
}

~~~~

In order to access this function from a scripting language, it is necessary to write a special "wrapper" function that serves as the glue between the scripting language and the underlying C function. A wrapper function must do three things :

   - Gather function arguments and make sure they are valid.
   - Call the C function.
   - Convert the return value into a form recognized by the javascript. 

As an example, the javascript wrapper function for the fact() function above example might look like the following :

~~~~

JSValueRef wrap_fact(JSContextRef context, JSObjectRef function, JSObjectRef globalobj, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
  int arg1 = (int)JSValueToNumber(context, argv[0], NULL); 
  int arg2 = (int)JSValueToNumber(context, argv[1], NULL); 
  int result = (int)fact(arg1,arg2);
  JSValueRef jsresult = JSValueMakeNumber(context, result); 
  return jsresult;
}

~~~~

Once you have created a wrapper function, the final step is to tell the javascript about the new function. This is done by register function called by the javascript when the module is loaded. For example, adding the above function to the javascript interpreter requires code like the following :

~~~~

bool jsc_registerFunction(JSGlobalContextRef context, JSObjectRef object, 
                        const char* functionName, JSObjectCallAsFunctionCallback callback)
{
  JSStringRef js_globalvarsclassname = JSStringCreateWithUTF8CString(globalvarsclassname);
  JSObjectSetProperty(context,js_globalvarsclassname,JSObjectMakeFunctionWithCallback(context,
  js_globalvarsclassname, callback), kJSPropertyAttributeNone,NULL);  
  JSStringRelease(jsstring);
  return true;
}

int example_init(JSContextRef context) {
  JSObjectRef global;
  ...
  jsc_registerFunction(context, global,  "fact", wrap_fact);
  ...
}

~~~~

When executed, javascript will now have a new command called "fact" that you can use like any other Javascript command.
Although the process of adding a new function to javascript has been illustrated, the procedure is almost identical for Perl and Python. Both require special wrappers to be written and both need additional initialization code. 

## Variable Linking

Variable linking refers to the problem of mapping a C/C++ global variable to a variable in the scripting language interpreter. For example, suppose you had the following variable:

~~~~

double Foo = 3.5;

~~~~

To provide such access, variables are commonly manipulated using a pair of get/set functions. For example, whenever the value of a variable is read, a "get" function is invoked. Similarly, whenever the value of a variable is changed, a "set" function is called.

~~~~

bool Foo_set(JSContextRef context, JSObjectRef globalobj, JSStringRef propertyName, JSValueRef value, 
  JSValueRef* exception)
{
  JSValueRef jsresult;
  double arg1 = (double)JSValueToNumber(context, value, NULL); 
  Foo = arg1;
  jscresult = JSValueMakeUndefined(context); 
  return jsresult;
}

JSValueRef Foo_get(JSContextRef context, JSObjectRef globalobj, JSStringRef propertyName, JSValueRef* exception)
{
  JSValueRef jsresult;
  double result = (double)Foo;
  jsresult = JSValueMakeNumber(context, result); 
  return jsresult;
}

~~~~

In many languages, calls to the get/set functions can be attached to evaluation and assignment operators. Therefore, evaluating a variable such as Foo might implicitly call the get function. Similarly, typing Foo = 4 would call the underlying set function to change the value. 

# A tour of basic C/C++ wrapping

By default, SWIG tries to build a very natural javascript interface to your C/C++ code. Functions are wrapped as functions, classes are wrapped as classes, and so forth. This section briefly covers the essential aspects of this wrapping.

## Modules

The SWIG %module directive specifies the name of the Javascript module. If you specify `%module example`, then everything is wrapped into a Javascript 'example' module. Underneath the covers, this module consists of a cpp source file example.cpp. When choosing a module name, make sure you don't use the same name as a built-in Javascript command or standard module name.

## Global variables

C/C++ global variables are fully supported by SWIG. However, the underlying mechanism is somewhat different than you might expect due to the way that javascript works.

~~~~

// SWIG interface file with global variables
%module example
...
%inline %{
extern double Foo;
extern int  gcd(int x, int y);
%}
...

~~~~

Now look at the javascript:

~~~~

print("Global variable Foo=" + example.Foo);
example.Foo = 3.1415926;
print("Variable Foo changed to=" + example.Foo);
print("GCD of x and y is=" + example.gcd(x,y));

~~~~

## Constants and enums

C/C++ constants are installed as javascript objects containing the appropriate value. To create a constant, use #define, enum, or the %constant directive. For example:

~~~~

#define    ICONST      42
#define    FCONST      2.1828
%constant int iconst = 37;

~~~~

In javascript they are treated as:

~~~~

print("ICONST  = " + example.ICONST  + " (should be 42)\n");
print("FCONST  = " + example.FCONST  + " (should be 2.1828)\n");
print("iconst  = " + example.iconst  + " (should be 37)\n"); 

~~~~

For enums, make sure that the definition of the enumeration actually appears in a header file or in the wrapper file somehow---if you just stick an enum in a SWIG interface without also telling the C compiler about it, the wrapper code won't compile.
Enums are treated as constants.So if we have enums in c++ as:

~~~~

void enum_test(color c, Foo::speed s);

~~~~

In javascript they are treated as:

~~~~

example.enum_test(example.RED, example.Foo.IMPULSE);
example.enum_test(example.BLUE,  example.Foo.WARP);
example.enum_test(example.GREEN, example.Foo.LUDICROUS);

~~~~

### Inside the class
For class enums as below:

~~~~

class Foo {
public:
Foo() { }
enum speed { IMPULSE, WARP, LUDICROUS };
}

~~~~

In javascript they are treated as:

~~~~

print("    Foo_IMPULSE   =" + example.Foo.IMPULSE);
print("    Foo_WARP      =" + example.Foo.WARP);
print("    Foo_LUDICROUS =" + example.Foo.LUDICROUS);

~~~~

## Pointers

C/C++ pointers are fully supported by SWIG. Furthermore, SWIG has no problem working with incomplete type information. Here is a rather simple interface

~~~~

/* File : example.i */
%module example
%{
extern void add(int *, int *, int *);
%}

~~~~

When wrapped, you will be able to use the functions in a natural way from javascript. For example:

~~~~

// Call the add() function with some pointers
example.add(a, b, c);

~~~~

// In javascript the code look like as:

~~~~

a = example.new_intp();
example.intp_assign(a,37);

~~~~

- The first one creates an int-pointer instance.
- The second one assigns it the value 37.

### C++ classes

C++ classes are wrapped by javascript classes as well. For example, if you have this class,

~~~~

class Circle
{
public:
    Circle();    
    Circle(double r);    
    double area();
    double radius;
};

~~~~

you can use it in javascript like this:

~~~~

print("Creating some objects:");
c = new example.Circle(10);
print("area = " + c.area());

~~~~

Class data members are accessed in the same manner as C structures.

Static class members and functions are mapped to javascript in a straight-forward manner:

~~~~

class Spam {
public:
   static void foo();
   static int bar;
};

~~~~

In javascript, the static member can be access in this way:

~~~~

// ----- Access a static member -----
print("\nA access of static member is" + example.Spam.Foo); // access static member as properties of the class object.

~~~~

## C++ inheritance

SWIG is fully aware of issues related to C++ inheritance. Therefore, if you have classes like this

~~~~

class A {
public:
    void foo();
    virtual void bar();
};
class B: public A {
public:
    virtual void bar();
};

~~~~

Those classes are wrapped into a hierarchy of javascript classes that reflect the same inheritance structure. All of the usual javascript utility functions work normally:

~~~~

var a = new example.A();
a.foo();
a.bar();
var b = new example.B();
b.foo();
b.bar();
print("b.cPtr = " + b.getCPtr());

~~~~

## C++ overloaded functions

C++ overloaded functions, methods, and constructors are mostly supported by SWIG. For example, if you have two functions like this:

~~~~

void f(int val) {
  std::cout << "Called f(int)." << std::endl;
}
void f(int val1, int val2) {
  std::cout << "Called f(int, int)." << std::endl;
}
void f(const char* s) {
  std::cout << "Called f(const char*)." << std::endl;
}

~~~~

You can use them in javascript in a straightforward manner:

~~~~

example.f(1);
example.f(1, 2);
example.f("bla");

~~~~

## C++ operators

Certain C++ overloaded operators can be handled automatically by SWIG. Though, in javascript operator overloading is not possible. Instead one has to make use of the `%rename` feature.
 
For example, consider a class like this:

~~~~

/* File : example.h */
#include <math.h>
class Complex {
private:
  double rpart, ipart;
public:
  Complex(double r = 0, double i = 0) : rpart(r), ipart(i) { }
  Complex(const Complex &c) : rpart(c.rpart), ipart(c.ipart) { }
  Complex &operator=(const Complex &c) {
    rpart = c.rpart;
    ipart = c.ipart;
    return *this;
  }
  Complex operator+(const Complex &c) const {
    return Complex(rpart+c.rpart, ipart+c.ipart);
  }
  Complex operator-(const Complex &c) const {
    return Complex(rpart-c.rpart, ipart-c.ipart);
  }
  Complex operator*(const Complex &c) const {
    return Complex(rpart*c.rpart - ipart*c.ipart,
		   rpart*c.ipart + c.rpart*ipart);
  }
  Complex operator-() const {
    return Complex(-rpart, -ipart);
  }
  
  double re() const { return rpart; }
  double im() const { return ipart; }
};

~~~~

When wrapped, it works like you expect:

~~~~

a = new example.Complex(2,3);
b = new example.Complex(-5,10);

print ("a   =" + a);
print ("b   =" + b);

c = a.plus(b);

print("c   =" + c);
print("a*b =" + a.times(b));
print("a-c =" + a.minus(c));

e = example.Complex.copy(a.minus(c));
print("e   =" + e);

// Big expression
f = a.plus(b).times(c.plus(b.times(e))).plus(a.uminus());
print("f   =" + f);

~~~~

One restriction with operator overloading support is that SWIG is not able to fully handle operators that aren't defined as part of the class. For example, if you had code like this

~~~~

class Complex {
...
friend Complex operator+(double, const Complex &c);
...
};

~~~~

then SWIG ignores it and issues a warning. You can still wrap the operator, but you may have to encapsulate it in a special function. For example:

%rename(Complex_add_dc) operator+(double, const Complex &);

There are ways to make this operator appear as part of the class using the %extend directive. 

## C++ namespaces:

SWIG is aware of C++ namespaces, but namespace names do not appear in the module nor do namespaces result in a module that is broken up into submodules or packages. For example, if you have a file like this,

~~~~

%module example
namespace nspace {
extern int    gcd(int x, int y);
extern double Foo;
class Circle
{
public:
   Circle();
   Circle(double r);
   double area();
   double radius;
   };
}

~~~~

for namespaces, you use the %feature directive in interface file. %feature attaches a new attribute to any parse tree node that matches given prototype.

~~~~

/* File : example.i */
%module example
%{
#include "example.h"
%}
%feature("nspace", 1);
%include "example.h"

~~~~

it works in javascript as follows:

~~~~

print("Global variable Foo=" + example.nspace.Foo);
example.nspace.Foo = 5;
print("Variable Foo changed to " + example.nspace.Foo);
print("GCD of number 6,18 is " + example.nspace.gcd(6,18));
print("Creating some objects:");
c = new example.nspace.Circle(10);
print("area = " + c.area());

~~~~

If your program has more than one namespace, name conflicts (if any) can be resolved using %rename For example:

~~~~

%rename(Bar_spam) Bar::spam;
namespace Foo {
    int spam();
}
namespace Bar {
    int spam();
}

~~~~

If you have more than one namespace and your want to keep their symbols separate, consider wrapping them as separate SWIG modules. For example, make the module name the same as the namespace and create extension modules for each namespace separately. If your program utilizes thousands of small deeply nested namespaces each with identical symbol names, well, then you get what you deserve. 
SWIG resolves overloaded functions and methods using a disambiguation scheme that ranks and sorts declarations according to a set of type-precedence rules. The order in which declarations appear in the input does not matter except in situations where ambiguity arises--in this case, the first declaration takes precedence.

## C++ templates

C++ templates don't present a huge problem for SWIG. However, in order to create wrappers, you have to tell SWIG to create wrappers for a particular template instantiation. To do this, you use the %template directive. For example:

~~~~

/* File : example.i */
%module example
%{
#include "example.h"
%}
/* Let's just grab the original header file here */
%include "example.h"

/* Now instantiate some specific template declarations */
%template(maxint) max<int>;
%template(maxdouble) max<double>;
%template(vecint) vector<int>;
%template(vecdouble) vector<double>;

~~~~

In javascript:

~~~~

//Call some templated functions
print(example.maxint(3,7));
print(example.maxdouble(3.14,2.18));

// Create some class

iv = new example.vecint(100);
dv = new example.vecdouble(1000);

for(i=0;i<=100;i++)
      iv.setitem(i,2*i);

for(i=0;i<=1000;i++)
      dv.setitem(i, 1.0/(i+1));

sum = 0;
for(i=0;i<=100;i++)
      sum = sum + iv.getitem(i);

print(sum);

sum = 0.0;
for(i=0;i<=1000;i++)
      sum = sum + dv.getitem(i);
print(sum);

~~~~

## Exception handling

The SWIG %exception directive can be used to create a user-definable exception handler for converting exceptions in your C/C++ program into javascript exceptions. The chapter on customization features contains more details, but suppose you have a C++ class like the following:

Since several methods in this class can throw an exception for an out-of-bounds access, you might want to catch this in the javascript extension by writing the following in an interface file:

~~~~

/* File : example.i */
%module example
%{
#include "example.h"
%}
%include "std_string.i"

/* Let's just grab the original header file here */
%include "example.h"

~~~~

Actually in JS there is no support for typed exceptions.For now there is support for integer and string
exception. Example for integer exception

~~~~

JSValueRef jsc_gcd(JSContextRef context, JSObjectRef function, JSObjectRef globalobj, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
int arg1 = (int)JSValueToNumber(context, argv[0], NULL);
int arg2 = (int)JSValueToNumber(context, argv[1], NULL);
*exception = JSValueMakeNumber(context, 13);
int result = (int)gcd(arg1,arg2);
JSValueRef jsresult = JSValueMakeNumber(context, result); 

~~~~

and for string exception:

~~~~

JSValueRef wrap_gcd(JSContextRef context, JSObjectRef function, JSObjectRef globalobj, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
int arg1 = (int)JSValueToNumber(context, argv[0], NULL);
int arg2 = (int)JSValueToNumber(context, argv[1], NULL);
JSStringRef message = JSStringCreateWithUTF8CString("This is a test error.");
*exception = JSValueMakeString(context, message);
JSStringRelease(message);
int result = (int)gcd(arg1,arg2);
JSValueRef jscresult = JSValueMakeNumber(context, result);
return jsresult;
}

~~~~

## How to use generated modules?

Basically there is no standard extension mechanism in Javascript. We provided a custom interpreter with extension abilities. If JSC is embedded into a custom application, one has to make use of a generated module initializer function that allows easy extension of interpreter.
The basic approach is as follows:

### Basic Mechanism
- Creating the context
- Calling module initializer
- Evaluate Javascript

#### Creating the context

~~~~

JSGlobalContextRef context = JSGlobalContextCreate(NULL);
JSObjectRef globalObject = JSContextGetGlobalObject(context);
...

~~~~

### Calling module initializer

~~~~

 extern int example_init(JSGlobalContextRef context);
 ...
 example_init(context);
 ...

~~~~

### Evaluate Javascript

~~~~

// Evaluate the javascript
char* scriptContent = jsccreateStringWithContentsOfFile(scriptPath.c_str());
JSStringRef jsScript;    
if(!scriptContent) {
   printf("FAIL: runme script could not be loaded.\n");
        failed = 1;
    }
    else {
        JSValueRef ex;
        jsScript = JSStringCreateWithUTF8CString(scriptContent);
        JSValueRef jsResult = JSEvaluateScript(context, jsScript, 0, 0, 0, &ex);        
        if (!jsResult && ex) {
            jsc_printError(context, ex, scriptPath);
            failed = 1;
        }
    }
    if (scriptContent != NULL) {
        free(scriptContent);
    }        
    JSStringRelease(jsScript);
    JSGlobalContextRelease(context);
    globalObject = 0;
    for(std::vector<HANDLE>::iterator it = loaded_modules.begin();
      it != loaded_modules.end(); ++it) {
        HANDLE handle = *it;
        dlclose(handle);
    }    
    if (failed) {
        printf("FAIL: Some tests failed.\n");
        return 1;
    }
}

~~~~

## Typemaps

A typemap is nothing more than a code generation rule that is attached to a specific C datatype. For example, to convert integers from javascript to C, you might define a typemap like this:

~~~~

%typemap(in) int {
        $1 = ($1_ltype)JSValueToNumber(context, $input, NULL); %}
        printf("Received an integer : %d\n",$1);
}

~~~~

Typemaps are always associated with some specific aspect of code generation. In this case, the "in" method refers to the conversion of input arguments to C/C++. The datatype int is the datatype to which the typemap will be applied. The supplied C code is used to convert values. In this code a number of special variable prefaced by a $ are used. The $1 variable is placeholder for a local variable of type int. 

## Javascript typemaps

The previous section illustrated an "in" typemap for converting javascript objects to C. A variety of different typemap methods are defined by the javascript module. For example, to convert a C integer back into a javascript object, you might define an "out" typemap like this:

~~~~

%typemap(out) int {
  $result = JSValueMakeNumber(context, $1);
}

~~~~

The Javascript module makes use of Swig's unified template library. 

## Typemap variables

Within typemap code, a number of special variables prefaced with a $ may appear. A full list of variables can be found in the "Typemaps" chapter. This is a list of the most common variables:

`$1`:
A C local variable corresponding to the actual type specified in the %typemap directive. For input values, this is a C local variable that's supposed to hold an argument value. For output values, this is the raw result that's supposed to be returned to Javascript.

`$input`:
A javascript Object * holding a raw javascript object with an argument or variable value.

`$result`:
A javascript Object * that holds the result to be returned to javascript.

`$1_name`:
The parameter name that was matched.

`$1_type`:
The actual C datatype matched by the typemap.

`$1_ltype`:
An assignable version of the datatype matched by the typemap (a type that can appear on the left-hand-side of a C assignment operation). This type is stripped of qualifiers and may be an altered version of `$1_type`. All arguments and local variables in wrapper functions are declared using this type so that their values can be properly assigned.

`$symname`:
The javascript name of the wrapper function being created.

# Javascript: Specification of a Code Generator for JSC

The module implementation tries to accomplish a separation of logic and code generation by making
use of code templates. In the following, the templates are explained.

# Top Level structure

The generated code consists of the following blocks:

~~~~

<RUNTIME>
<INCLUDES>
<HELPER_FUNCTIONS>
<FUNCTION_WRAPPERS>
<INITIALIZER>

~~~~

- `RUNTIME`: runtime code generated by swig
- `HELPER_FUNCTIONS`: static, from swg-file
- `INCLUDES`: static, module property
- `FUNCTION_WRAPPERS`: dynamically growing, on method declarations
- `INITIALIZER`: dynamically growing, aggregates everything 

## INCLUDES

~~~~

#include <JavaScriptCore/JavaScript.h>
<USER_DEFINED_INCLUDES>

~~~~

`USER_DEFINED_INCLUDES`: a module property

## `HELPER_FUNCTIONS`

A lot of boiler-plate code can be shifted into static helper functions:

~~~~

bool JS_registerClass(JSGlobalContextRef& context, JSObjectRef& parentObject,const char* className,
                             JSClassDefinition* definition) {
    JSStringRef js_className = JSStringCreateWithUTF8CString(className);
    JSObjectRef classObject = JSObjectMake(context, JSClassCreate(definition), NULL);
    JSObjectSetProperty(context, parentObject,js_className, classObject,kJSPropertyAttributeNone, NULL);
    JSStringRelease(js_className);
    return true;
}

bool JS_registerNamespace(JSGlobalContextRef& context,JSObjectRef& namespaceObj,JSObjectRef& parentNamespace,const char* name)
{
    JSStringRef js_name = JSStringCreateWithUTF8CString(name);
    JSObjectSetProperty(context, parentNamespace,js_name, namespaceObj,kJSPropertyAttributeNone, NULL);
    JSStringRelease(js_name);
    return true;
}

bool JS_registerFunction(JSGlobalContextRef context, JSObjectRef object, const char* functionName, JSObjectCallAsFunctionCallback callback)
{
    JSStringRef js_functionName = JSStringCreateWithUTF8CString(functionName);                  
    JSObjectSetProperty(context,object,js_functionName,JSObjectMakeFunctionWithCallback(context,
    js_functionName, callback), kJSPropertyAttributeNone, NULL);
    JSStringRelease(js_functionName);
    return true;
}
bool JS_veto_set_variable(JSContextRef context, JSObjectRef thisObject, JSStringRef propertyName, JSValueRef value, JSValueRef* exception)
{
    char buffer[256];
    char msg[512];
    int res;
    JSStringGetUTF8CString(propertyName, buffer, 256);
    res = sprintf(msg, "Tried to write read-only variable: %s.", buffer);
    if(res<0) {
      SWIG_exception(SWIG_ERROR, "Tried to write read-only variable.");
    } else {
      SWIG_exception(SWIG_ERROR, msg);
    }
    return false;
}

JSValueRef JS_CharPtrToJSValue(JSContextRef context, char* cstr) {
  JSValueRef val;
  JSStringRef jsstring = JSStringCreateWithUTF8CString((char*) cstr);
  val = JSValueMakeString(context, jsstring);
  JSStringRelease(jsstring);
  return val;
}

~~~~

## `FUNCTION_WRAPPERS`

There are different types of function wrappers:
- Member Functions 
- Getproperty / Setproperty 
- Global Functions (global/namespace/class) 
- Constructors / Destructors 


## Member Functions

~~~~

JSValueRef ${functionname}(JSContextRef context, JSObjectRef function, JSObjectRef thisObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
  ${LOCALS}
  ${CODE}
  return jsresult;
  
  goto fail;
  fail:
  return NULL;  
}

~~~~

- `functionname`: the name of generated wrapper for function
- `LOCALS`: declarations for input arguments 
- `CODE`: contains input marshalling, the action, and output marshalling 

## Setproperty

~~~~

bool ${setname}(JSContextRef context, JSObjectRef thisObject, JSStringRef propertyName, JSValueRef value, JSValueRef* exception)
{
   ${LOCALS}
   ${CODE}
   return jsresult;
  
   goto fail;
   fail:
   return NULL;  
}

~~~~

- `setname`: the name of the generated wrapper for setproperty.
- `LOCALS`: declarations for input arguments 
- `CODE`: contains input marshalling, and the action 

## Getproperty

~~~~

JSValueRef ${getname}(JSContextRef context, JSObjectRef thisObject, JSStringRef propertyName, JSValueRef* exception)
{
  ${LOCALS}
  ${CODE}
  return jsresult;
  
  goto fail;
  fail:
  return NULL;  
}

~~~~

- `getname`: the name of the generated wrapper for the getproperty 
- `LOCALS`: declarations for output arguments 
- `CODE`: contains the action, and output marshalling 


## Global Functions

~~~~

JSStaticValue ${namespace}_values[] = {
  ${jsglobalvariables}
  { 0, 0, 0, 0 }
};
JSStaticFunction ${namespace}_functions[] = {
  ${jsglobalfunctions}
  { 0, 0, 0 }
};
JSClassDefinition ${namespace}_classDefinition;

~~~~

## Variable declaration

~~~~

{"${propertyname}",${getname}, ${setname}, kJSPropertyAttributeNone}

~~~~

This is used to fill variable definition tables.
`kJSPropertyAttributeNone` is JSC specific and means that the variable has a getter and setter.
Even for read-only variables a setter is used which throws an exception.

## Constructor

~~~~

JSObjectRef _wrap_create_${classname_mangled}${overloadext}(JSContextRef context, JSObjectRef thisObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    ${LOCALS}
    ${CODE}
    return SWIG_JSC_NewPointerObj(context, result, SWIGTYPE_${type_mangled}, SWIG_POINTER_OWN);    

    goto fail;
    fail:
    return NULL;
}

~~~~
- `classname_mangled` is the mangled qualified class name,   e.g., `foo::A -> foo_A`
- `LOCALS`: declarations for input arguments 
- `CODE`: contains input marshalling, and the action 

## Destructors

~~~~

void _wrap_${classname_mangled}_finalize(JSObjectRef thisObject)
{
  SWIG_PRV_DATA* t = (SWIG_PRV_DATA*)JSObjectGetPrivate(thisObject);
  if(t && t->swigCMemOwn) delete (${type}*)(t->swigCObject);
  if(t) delete t;
}

~~~~

- `classname_mangled` is the mangled qualified class name,   e.g., `foo::A -> foo_A`

## Initializer

~~~~

bool ${modulename}_initialize(JSGlobalContextRef context) {
    SWIG_InitializeModule(0);

    JSObjectRef global_object = JSContextGetGlobalObject(context);
    
    /* Initialize the base swig type object */
    _SwigObject_objectDefinition.staticFunctions = _SwigObject_functions;
    _SwigObject_objectDefinition.staticValues = _SwigObject_values;
    _SwigObject_classRef = JSClassCreate(&_SwigObject_objectDefinition);
    
    /* Create objects for namespaces */
    ${create_namespaces}

    /* Create classes */
    ${initializercode}

    /* Register namespaces */
    ${register_namespaces}

    return true;
}

~~~~

## Class template defintions

A class is specified by a static part (`*_classDefinition`) and a dynamic part (`*_objectDefinition`).

~~~~

${classname_mangled}_classDefinition.staticFunctions = ${classname_mangled}_staticFunctions;
    ${classname_mangled}_classDefinition.staticValues = ${classname_mangled}_staticValues;
    ${classname_mangled}_classDefinition.callAsConstructor = _wrap_create_${classname_mangled};
    ${classname_mangled}_objectDefinition.staticValues = ${classname_mangled}_values;
    ${classname_mangled}_objectDefinition.staticFunctions = ${classname_mangled}_functions;
    ${classname_mangled}_objectDefinition.parentClass = ${base_classname}_classRef;
    JSClassRef ${classname_mangled}_classRef = JSClassCreate(&${classname_mangled}_objectDefinition);
    SWIGTYPE_${classtype_mangled}->clientdata = ${classname_mangled}_classRef;%}

~~~~

Notes:
- `classname_mangled` is the mangled qualified class name,   e.g., `foo::A -> foo_A`
  which is retrieved by `Swig_name_mangle(Getattr(n, "name"))` 
- ClassDefinitions are built using the staticValues array and the staticFunction array. The staticValues and  staticFunctions arrays are the simplest and most efficient means for vending custom properties to the class object.

## Inheritance

~~~~

{${classname_mangled}_objectDefinition.parentClass = ${base_classname}_classRef};

~~~~

- `classname_mangled` is the mangled qualified class name,   e.g., `foo::A -> foo_A`
- Note: multiple inheritance is not possible; thus we will always take the first parent class 

## Namespaces

Namespaces are objects without class templates. i.e., instances are created, referenced locally, used as contexts for other registrations, and stored in the according parent contexts.

~~~~

 ${namespace}_classDefinition.staticFunctions = ${namespace}_functions;
    ${namespace}_classDefinition.staticValues = ${namespace}_values;
    JSObjectRef ${namespace}_object = JSObjectMake(context, JSClassCreate(&${namespace}_classDefinition), NULL);

~~~~

## Registration

The registration part consists of registering classes at contexts (i.e., global or namespace), methods and properties at classes or contexts, and namespaces as objects at parent contexts. 

* Global functions

~~~~

JS_registerFunction(${context}, ${context_object}, "${functionname}", ${functionwrapper}

~~~~

* Classes

~~~~

JS_registerClass(context, ${namespace}_object, "${classname}", &${classname_mangled}_classDefinition)

~~~~

Note: every class template has an associated constructor function wrapper, which is registered here 

* Namespaces

~~~~

${namespace}_classDefinition.staticFunctions = ${namespace}_functions;
${namespace}_classDefinition.staticValues = ${namespace}_values;
JSObjectRef ${namespace}_object = JSObjectMake(context, JSClassCreate(&${namespace}_classDefinition), NULL);

~~~~

Namespaces are registered using:

~~~~

JS_registerNamespace(context, ${namespace}_object, ${parent_namespace}_object, "${namespace}");

~~~~


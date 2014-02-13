# SWIG and Javascript

This chapter describes SWIG's support of Javascript.
It does not cover SWIG basics only information that is specific to this module.

## Overview

JavaScript is a prototype-based scripting language that is dynamic, weakly typed
and has first-class functions. Its arguably the most popular language for web development.
Beyond of being a browser-based scripting language, with [node.js](http://nodejs.org)
Javascript has found its way to a backend development language, too.

Native Javascript extensions can be used for applications that embed a web-browser view or
that embed a Javascript engine (such as *node.js*).
Extending a general purpose web-browser is not possible as this would be severe security issue.

SWIG Javasript currently supports **JavascriptCore**, the Javascript engine used by `Safari`,
and **v8**, which is used by `Chromium` and `node.js`.

With [WebKit](http://www.webkit.org/) there is a modern browser
implementation available as open-source which can be embedded into an application.
Unfortunately, [Chromium Embedded Framework](http://code.google.com/p/chromiumembedded/)
does not provide access to the native V8 engine, making it impossible to extend the engine
using the Javascript module.

## Preliminaries

### Running SWIG

Suppose that you defined a SWIG module such as the following:

    %module example
    %{
    #include "example.h"
    %}
    int gcd(int x, int y);
    extern double Foo;

To build a Javascript module, run SWIG using the `-javascript` option
and a desired target engine `-jsc` or `-v8`.

    $ swig -javascript -jsc example.i

If building a C++ extension, add the -c++ option:

    $ swig -c++ -javascript -jsc example.i

This creates a C/C++ source file example_wrap.c or example_wrap.cxx. The generated C source file contains the low-level wrappers that need to be compiled and linked with the rest of your C/C++ application to create an extension module.

The name of the wrapper file is derived from the name of the input file.
For example, if the input file is example.i, the name of the wrapper file is example_wrap.c.
To change this, you can use the -o option.
The wrapped module will export one function which must be called to register the module with the Javascript interpreter.
For example, if your module is named `example` the corresponding initializer for JavascriptCore would be

    bool example_initialize(JSGlobalContextRef context, JSObjectRef *exports)

and for v8:

    void example_initialize (v8::Handle<v8::Object> exports)

## Missing features

The Javascript module is not yet as mature as other modules and some things are still missing.
As it makes use of Swigs Unified typemap library (UTL), many typemaps are inherited.

- Director support
- TODO: hmpf... I suppose there is more

## Compilation and Linking

### Installation

### Dealing with `v8` version incompatibilities

Unfortunately, v8 does not provide pre-processor macros do detect which version you link to.
Therefore, you have to provide this information manually.

## Integration

This should give a short overview how to integrate your module in different environments: as a `node.js` module, and as an extension for an embedded Chromium.

### Creating `node.js` Extensions

As `v8` is written in C++ and comes as a C++ library it is crucial to compile your module using the
same compiler flags as used for building v8. To make things easier, `node.js` provides a build tool called `node-gyp`.

This expects configuration file named `binding.gyp` which is basically in JSON format and
conforms to the same format that is used with Google's build-tool `gyp`.

`binding.gyp`:

    {
      "targets": [
        {
          "target_name": "example",
          "sources": [ "example.cxx", "example_wrap.cxx" ]
        }
      ]
    }

First you would create the wrapper using SWIG:


### Embedded Webkit

TODO: Here a minimal example of how to implement

## Implementation

The Javascript Module implementation has take a very different approach than other modules
to be able to generate code for different Javascript interpreters.


### Module Source Code

The Javascript module is implemented in `Source/Modules/javascript.cxx`.
It dispatches the code generation to a `JSEmitter` instance, `V8Emitter` or `JSCEmitter`. Additionally there are some helpers: `Template`, for templated code generation, and `JSEmitterState`, which is used to manage state information during AST traversal.
This is a rough map shall make it easier to find a way through this huge source file:

    // module wide defines

    #define NAME "name"

    ...

    // Helper class declarations
    class JSEmitterState { ... };

    class Template { ... };


    // JSEmitter declaration

    class JSEmitter { ... };


    // Emitter factory declarations

    JSEmitter *swig_javascript_create_JSCEmitter();
    JSEmitter *swig_javascript_create_V8Emitter();


    // Javascript module class declaration

    class JAVASCRIPT:public Language { ... };


    // Javascript module function definitions

    int JAVASCRIPT::functionWrapper(Node *n) { ... }

    ...


    // Module factory implementations

    static Language *new_swig_javascript() { ... }

    extern "C" Language *swig_javascript(void) { ... }


    // JSEmitter implementation

    JSEmitter::JSEmitter() { ... }

    Template JSEmitter::getTemplate(const String *name) { ... }

    ...


    // JSCEmitter declaration

    class JSCEmitter: public JSEmitter { ... };


    // JSCEmitter implementation

    JSCEmitter::JSCEmitter() { ... }

    void JSCEmitter::marshalInputArgs(Node *n, ParmList *parms, Wrapper *wrapper, MarshallingMode mode, bool is_member, bool is_static) { ... }

    ...


    // JSCEmitter factory

    JSEmitter *swig_javascript_create_JSCEmitter() { ... }


    // V8Emitter declaration

    class V8Emitter: public JSEmitter { ... };


    // V8Emitter implementation

    V8Emitter::V8Emitter() { ... }

    int V8Emitter::initialize(Node *n) { ... }


    // V8Emitter factory

    JSEmitter *swig_javascript_create_V8Emitter() { ... }


    // Helper implementation (JSEmitterState, Template)

    JSEmitterState::JSEmitterState() { ... }

    ...

    Template::Template(const String *code_) { ... }


### Code Templates

All generated code is created on the basis of code templates.
The templates for *JavascriptCore* can be found in `Lib/javascript/jsc/javascriptcode.swg`,
for *v8* in `Lib/javascript/v8/javascriptcode.swg`.

To track the originating code template for generated code you can run

    $ swig -javascript -jsc -debug-codetemplates

which wraps generated code with a descriptive comment

    /* begin fragment("temlate_name") */

    ...generated code ...

    /* end fragment("temlate_name") */

The Template class is used like this:

    Template t_register = getTemplate("jsv8_register_static_variable");
    t_register.replace("$jsparent", state.clazz(NAME_MANGLED))
        .replace("$jsname", state.variable(NAME))
        .replace("$jsgetter", state.variable(GETTER))
        .replace("$jssetter", state.variable(SETTER))
        .trim().
        print(f_init_static_wrappers);

A code template is registered with the *JSEmitter* via `fragment(name, "template")`, e.g.,

    %fragment ("jsc_variable_declaration", "templates")
    %{
      {"$jsname", $jsgetter, $jssetter, kJSPropertyAttributeNone},
    %}

`Template` creates a copy of that string and `Template::replace` uses Swig's `Replaceall`
to replace variables in the template. `Template::trim` can be used to eliminate
leading and trailing whitespaces. `Template::print` is used to write the final template string
to a Swig `DOH` (based on `Printv`). All methods allow chaining.

### Emitter

The Javascript module delegates code generation to a `JSEmitter` instance.
The following extract shows the essential interface:

    class JSEmitter {
      ...

      /**
       * Opens output files and temporary output DOHs.
       */
      virtual int initialize(Node *n);

      /**
       * Writes all collected code into the output file(s).
       */
      virtual int dump(Node *n) = 0;

      /**
       * Cleans up all open output DOHs.
       */
      virtual int close() = 0;

      ...

      /**
       * Invoked at the beginning of the classHandler.
       */
      virtual int enterClass(Node *);

      /**
       * Invoked at the end of the classHandler.
       */
      virtual int exitClass(Node *) {
        return SWIG_OK;
      };

      /**
       * Invoked at the beginning of the variableHandler.
       */
      virtual int enterVariable(Node *);

      /**
       * Invoked at the end of the variableHandler.
       */
      virtual int exitVariable(Node *) {
        return SWIG_OK;
      };

      /**
       * Invoked at the beginning of the functionHandler.
       */
      virtual int enterFunction(Node *);

      /**
       * Invoked at the end of the functionHandler.
       */
      virtual int exitFunction(Node *) {
        return SWIG_OK;
      };

      /**
       * Invoked by functionWrapper callback after call to Language::functionWrapper.
       */
      virtual int emitWrapperFunction(Node *n);

      /**
       * Invoked from constantWrapper after call to Language::constantWrapper.
       **/
      virtual int emitConstant(Node *n);

      /**
       * Registers a given code snippet for a given key name.
       *
       * This method is called by the fragmentDirective handler
       * of the JAVASCRIPT language module.
       **/
      int registerTemplate(const String *name, const String *code);

      /**
       * Retrieve the code template registered for a given name.
       */
      Template getTemplate(const String *name);

      State &getState();

      ...

    }

The module calls `initialize`,  `dump`, and `close` from within the `top` method:

    int JAVASCRIPT::top(Node *n) {
      emitter->initialize(n);

      Language::top(n);

      emitter->dump(n);
      emitter->close();

      return SWIG_OK;
    }

The methods `enterClass` and `exitClass` are called from within the `classHandler` method:

    int JAVASCRIPT::classHandler(Node *n) {

      emitter->enterClass(n);
      Language::classHandler(n);
      emitter->exitClass(n);

      return SWIG_OK;
    }

In `enterClass` the emitter stores state information that is necessary when processing class members. In `exitClass` the wrapper code for the whole class is generated.


### Emitter states

For storing information during the AST traversal the emitter provides a `JSEmitterState` with
different slots to store data representing the scopes global, class, function, and variable.

    class JSEmitterState {

    public:

      JSEmitterState();

      ~JSEmitterState();

      DOH *global();

      DOH *global(const char* key, DOH *initial = 0);

      DOH *clazz(bool reset = false);

      DOH *clazz(const char* key, DOH *initial = 0);

      DOH *function(bool reset = false);

      DOH *function(const char* key, DOH *initial = 0);

      DOH *variable(bool reset = false);

      DOH *variable(const char* key, DOH *initial = 0);

      static int IsSet(DOH *val);

      ...
    };

When entering a scope, such as in `enterClass`, the corresponding state is reset and new data
is stored:

    state.clazz(RESET);
    state.clazz(NAME, Getattr(n, "sym:name"));

State information can be retrieved using `state.clazz(NAME)` or
with `Getattr` on `state.clazz()` which actually returns a `Hash` instance.

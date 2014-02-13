% SWIG and Javascript

This chapter describes SWIG's support of Javascript.


# Overview

JavaScript is a prototype-based scripting language that is dynamic, weakly typed
and has first-class functions. Its arguably the most popular language for web development.
Beyond of being a browser-based scripting language, with [node.js](http://nodejs.org)
Javascript has found its way to a backend development language, too.

Native Javascript extensions can be used for applications that embed a web-browser view or
that embed a Javascript engine (such as *node.js*).
Extending a general purpose web-browser is not possible as this would be severe security issue.

With [WebKit](http://www.webkit.org/) there is an modern and open-source browser
implementations available which can be embedded into an application.
At the moment, [Chromium Embedded Framework](http://code.google.com/p/chromiumembedded/)
can not extended as CEF does not provide access to the V8 engine, but instead comes with
its own extension mechanism.

SWIG Javasript currently supports **JavascriptCore**, the Javascript engine used by `Safari`,
and **v8**, which is used by `Chromium` and `node.js`.

# Preliminaries

# Running SWIG

Suppose that you defined a SWIG module such as the following:

```code
%module example
%{
#include "example.h"
%}
int gcd(int x, int y);
extern double Foo;
```

To build a Javascript module, run SWIG using the `-javascript` option
and a desired target engine `-jsc` or `-v8`.

```shell
$ swig -javascript -jsc example.i
```

If building a C++ extension, add the -c++ option:

```shell
$ swig -c++ -javascript -jsc example.i
```

This creates a C/C++ source file example_wrap.c or example_wrap.cxx. The generated C source file contains the low-level wrappers that need to be compiled and linked with the rest of your C/C++ application to create an extension module.

The name of the wrapper file is derived from the name of the input file.
For example, if the input file is example.i, the name of the wrapper file is example_wrap.c.
To change this, you can use the -o option.
The wrapped module will export one function which must be called to register the module with the Javascript interpreter.
For example, if your module is named `example` the corresponding initializer for JavascriptCore would be

```code
bool example_initialize(JSGlobalContextRef context, JSObjectRef *exports)
```

and for v8:

```code
void example_initialize (v8::Handle<v8::Object> exports)
```

# Compilation and Linking

## Installation



## Dealing with `v8` version incompatibilities

Unfortunately, v8 does not provide pre-processor macros do detect which version you link to.
Therefore, you have to provide this information manually.


# Integration

This should give a short overview how to integrate your module in different environments: as a `node.js` module, and as an extension for an embedded Chromium.

## Creating `node.js` Extensions

As `v8` is written in C++ and comes as a C++ library it is crucial to compile your module using the
same compiler flags as used for building v8. To make things easier, `node.js` provides a build tool called `node-gyp`.

This expects configuration file named `binding.gyp` which is basically in JSON format and
conforms to the same format that is used with Google's build-tool `gyp`.

`binding.gyp`:
```code
{
  "targets": [
    {
      "target_name": "example",
      "sources": [ "example.cxx", "example_wrap.cxx" ]
    }
  ]
}
```

First you would create the wrapper using SWIG:

```shell

```

## Embedded Webkit


# Implementation

The Javascript Module implementation has take a very different approach than other modules
to be able to generate code for different Javascript interpreters.


## Module Source Code

The Javascript module is implemented in `Source/Modules/javascript.cxx`. It contains a SWIG Language class which does represents the module's entry point to the swig engine.
It implements the `Language` interface and dispatches the code generation to a `JSEmitter` instance, `V8Emitter` or `JSCEmitter`. Additionally there are some helpers: `Template`, for templated code generation, and `JSEmitterState`, which is used to manage state information during AST traversal. To find your way through this huge source file, here is a rough map:

```code
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

```

## Code Templates

All generated code is created on the basis of code templates.
The templates for *JavascriptCore* can be found in `Lib/javascript/jsc/javascriptcode.swg`,
for *v8* in `Lib/javascript/v8/javascriptcode.swg`.

To track the originating code template for generated code you can run

```shell
swig -javascript -jsc -debug-codetemplates
```

which wraps generated code with a descriptive comment

```code
/* begin fragment("temlate_name") */

...generated code ...

/* end fragment("temlate_name") */
```

The Template class is used like this:

```code
  Template t_register = getTemplate("jsv8_register_static_variable");
  t_register.replace("$jsparent", state.clazz(NAME_MANGLED))
      .replace("$jsname", state.variable(NAME))
      .replace("$jsgetter", state.variable(GETTER))
      .replace("$jssetter", state.variable(SETTER))
      .trim().
      print(f_init_static_wrappers);
```

The code template is registered to the *JSEmitter* via
`Template::replace` does simple


## Emitter

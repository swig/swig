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

SWIG Javasript currently supports **JavascriptCore**, the Javascript engine used by `Safari/Webkit`, and **v8**, which is used by `Chromium` and `node.js`.

[WebKit](http://www.webkit.org/) is a modern browser
implementation available as open-source which can be embedded into an application.

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

### Future work

The Javascript module is not yet as mature as other modules and some things are still missing.
As it makes use of Swigs Unified typemap library (UTL), many typemaps are inherited.
We could work on that if requested:

- More typemaps: compared to other modules there are only a few typemaps implemented.
  For instance a lot of the `std_*.i` typemaps are missing, such as `std_iostream`, for instance.

- Director support: this would allow to extend a C++ abstract base class in Javascript.
  A pragmatic intermediate step for the most important usecase
  would be to support Javascript callbacks as arguments.

- We will try to find a way into
  [Chromium Embedded Framework (CEF)](http://code.google.com/p/chromiumembedded/).
  CEF is also open-source and available for all platforms.
  However, at the moment it does not provide access to the native V8 engine,
  making it impossible to extend the engine using the extensions created with this module.


## Integration

This should give a short introduction to integrating your module in different environments: as a `node.js` module, and as an extension for an embedded Webkit.


### Creating `node.js` Extensions

To install `node.js` you can download an installer from their
[web-site](https://launchpad.net/~chris-lea/+archive/node.js) for OSX and Windows.
For Linux you can either build the source yourself and to a `sudo checkinstall`
or stick to the (probably stone-age) packaged version.
For Ubuntu there is a [PPA](https://launchpad.net/~chris-lea/+archive/node.js/) available.

    $ sudo add-apt-repository ppa:chris-lea/node.js
    $ sudo apt-get update
    $ sudo apt-get install nodejs

As `v8` is written in C++ and comes as a C++ library it is crucial to compile your module
using the same compiler flags as used for building v8.
To make things easier, `node.js` provides a build tool called `node-gyp`.

You have to install it using `npm`:

    $ npm install -g node-gyp


`node-gyp` expects a configuration file named `binding.gyp` which is basically in JSON
format and conforms to the same format that is used with Google's build-tool `gyp`.

`binding.gyp`:

    {
      "targets": [
        {
          "target_name": "example",
          "sources": [ "example.cxx", "example_wrap.cxx" ]
        }
      ]
    }

First create the wrapper using SWIG:

    $ swig -javascript -node -c++ example.cxx

Then run `node-gyp`

    $ node-gyp

This will create a `build` folder containing the native module.
To use the extension you have to require it in your javascript source file.

    require("./build/Release/example")


A more detailed exlanation is given in section `Examples`.


#### Troubleshooting

- *'module' object has no attribute 'script_main'*

  This happened when `gyp` was installed as distribution package.
  It seems to be outdated. Removing it resolves the problem.

    $ sudo apt-get remove gyp


### Embedded Webkit

Webkit is built-in for OSX and available as library for GTK.


#### OSX

There is general information about programming with WebKit on
[Apple Developer Documentation](https://developer.apple.com/library/mac/documentation/cocoa/conceptual/DisplayWebContent/DisplayWebContent.html).
Details about `Cocoa` programming are not covered here.

An integration of a native extension 'example' would look like this:

    #import "appDelegate.h"

    extern bool example_initialize(JSGlobalContextRef context);


    @implementation ExampleAppDelegate

    @synthesize webView;


    - (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

      // Start a webview with the bundled index.html file
      NSString *path = [[NSBundle mainBundle] bundlePath];
      NSString *url =  [NSString stringWithFormat: @"file://%@/Contents/Assets/index.html", path];

      WebFrame *webframe = [webView mainFrame];
      JSGlobalContextRef context = [webframe globalContext];

      example_initialize(context);

      [ [webView mainFrame] loadRequest:
        [NSURLRequest requestWithURL: [NSURL URLWithString:url] ]
      ];
    }

    @end

#### GTK

There is general information about programming GTK on the
[GTK documentation](https://developer.gnome.org/gtk2/), in the
[GTK tutorial](https://developer.gnome.org/gtk-tutorial),
and for Webkit there is a [Webkit GTK+ API Reference](http://webkitgtk.org/reference/webkitgtk/stable/index.html).

An integration of a native extension 'example' would look like this:

    #include <gtk/gtk.h>
    #include <webkit/webkit.h>

    extern bool example_initialize(JSGlobalContextRef context);

    int main(int argc, char* argv[])
    {
        // Initialize GTK+
        gtk_init(&argc, &argv);

        ...

        // Create a browser instance
        WebKitWebView *webView = WEBKIT_WEB_VIEW(webkit_web_view_new());
        WebFrame *webframe = webkit_web_view_get_main_frame(webView);
        JSGlobalContextRef context = webkit_web_frame_get_global_context(webFrame);
        example_initialize(context);

        ...

        // Load a web page into the browser instance
        webkit_web_view_load_uri(webView, "http://www.webkitgtk.org/");

        ...

        // Run the main GTK+ event loop
        gtk_main();

        return 0;
    }


### Embedded V8

It is possible to create a custom application like `node.js` embedding a v8 engine.

TODO:
- how to install v8
- v8 version issues: command-line switch, pre-processor macro
- sample integration code


## Examples

Some basic examples are shown here in more detail.

### Simple

The common example `simple` looks like this:

    /* File : example.i */
    %module example

    %inline %{
    extern int    gcd(int x, int y);
    extern double Foo;
    %}

To make this available as node extension a `binding.gyp` has to be created:

    {
      "targets": [
        {
          "target_name": "example",
          "sources": [ "example.cxx", "example_wrap.cxx" ]
        }
      ]
    }

Then `node-gyp` is used to build the extension:

    $ node-gyp configure build


From a 'nodejs` application this would be used this way:

    // import the extension via require
    var example = require("./build/Release/example");

    // calling the global method
    var x = 42;
    var y = 105;
    var g = example.gcd(x,y);

    // Accessing the globak variable
    var f = example.Foo;
    example.Foo = 3.1415926;

First the module `example` is loaded from the previously built extension.
Global methods and variables are available in the scope of the module.

> Note: ECMAScript 5, the currently implemented Javascript standard, does not have modules.
> `node.js` and other implementations provide this mechanism defined by the
> [CommonJS](http://wiki.commonjs.org/wiki/CommonJS) group.
> For browsers this is provided by [Browserify](http://browserify.org), for instance.

### Class

The common example `class` looks defines three classes, `Shape`, `Circle`, and `Square`:

    class Shape {
    public:
      Shape() {
        nshapes++;
      }
      virtual ~Shape() {
        nshapes--;
      };
      double  x, y;
      void    move(double dx, double dy);
      virtual double area(void) = 0;
      virtual double perimeter(void) = 0;
      static  int nshapes;
    };

    class Circle : public Shape {
    private:
      double radius;
    public:
      Circle(double r) : radius(r) { };
      virtual double area(void);
      virtual double perimeter(void);
    };

    class Square : public Shape {
    private:
      double width;
    public:
      Square(double w) : width(w) { };
      virtual double area(void);
      virtual double perimeter(void);
    };

`Circle` and `Square` inherit from `Shape`. `Shape` has a static variable a function `move`
that can't be overridden (non-virtual) and two abstract functions `area` and `perimeter` (pure virtual) that must be overridden by the sub-classes.

A `nodejs` extension is built the same way as for the `simple` example.

From Javascript this extension can be used this way:


    var example = require("./build/Release/example");

    // local aliases for convenience
    var Shape = example.Shape;
    var Circle = example.Circle;
    var Square = example.Square;

    // Creating new instances using the 'new' operator
    var c = new Circle(10);
    var s = new Square(10);

    // Accessing a static member
    var nshapes = Shape.nshapes;

    // Accessing member variables
    c.x = 20;
    c.y = 30;
    s.x = -10;
    s.y = 5;

    // Calling some methods -----
    c.area();
    c.perimeter();
    s.area();
    s.perimeter();


Running these commands in an interactive node shell result in this output:

    $ node -i
    > var example = require("./build/Release/example");
    undefined
    > var Shape = example.Shape;
    undefined
    > var Circle = example.Circle;
    undefined
    > var Square = example.Square;
    undefined
    > var c = new Circle(10);
    undefined
    > var s = new Square(10);
    undefined
    > var nshapes = Shape.nshapes;
    undefined
    > Shape.nshapes;
    2
    > c.x = 20;
    20
    > c.y = 30;
    30
    > s.x = -10;
    -10
    > s.y = 5;
    5
    > c.area();
    314.1592653589793
    > c.perimeter();
    62.83185307179586
    > s.area();
    100
    > s.perimeter();
    40
    > c.move(40, 40)
    undefined
    > c.x
    60
    > c.y
    70
    >

> Note: In ECMAScript 5 there is no concept for classes.
  Instead each function can be used as a constructor function which is executed by the 'new'
  operator. Furthermore, during construction the key property `prototype` of the constructor function is used to attach a prototype instance to the created object.
  A prototype is essentially an object itself that is the first-class delegate of a class
  used whenever the access to a property of an object fails.
  The very same prototype instance is shared among all instances of one type.
  Prototypal inheritance is explained in more detail on in
  [Inheritance and the prototype chain](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Inheritance_and_the_prototype_chain), for instance.


## Implementation

The Javascript Module implementation has take a very different approach than other modules
to be able to generate code for different Javascript interpreters.

### Source Code

The Javascript module is implemented in `Source/Modules/javascript.cxx`.
It dispatches the code generation to a `JSEmitter` instance, `V8Emitter` or `JSCEmitter`. Additionally there are some helpers: `Template`, for templated code generation, and `JSEmitterState`, which is used to manage state information during AST traversal.
This rough map shall make it easier to find a way through this huge source file:

    // module wide defines

    #define NAME "name"
    ...

    // ###############################
    // #  Helper class declarations

    class JSEmitterState { ... };

    class Template { ... };

    // ###############################
    // # JSEmitter declaration

    class JSEmitter { ... };

    // Emitter factory declarations

    JSEmitter *swig_javascript_create_JSCEmitter();
    JSEmitter *swig_javascript_create_V8Emitter();

    // ###############################
    // # Javascript module

    // Javascript module declaration

    class JAVASCRIPT:public Language { ... };

    // Javascript module implementation

    int JAVASCRIPT::functionWrapper(Node *n) { ... }
    ...

    // Module factory implementation

    static Language *new_swig_javascript() { ... }

    extern "C" Language *swig_javascript(void) { ... }

    // ###############################
    // # JSEmitter base implementation

    JSEmitter::JSEmitter() { ... }

    Template JSEmitter::getTemplate(const String *name) { ... }
    ...

    // ###############################
    // # JSCEmitter

    // JSCEmitter declaration

    class JSCEmitter: public JSEmitter { ... };

    // JSCEmitter implementation

    JSCEmitter::JSCEmitter() { ... }

    void JSCEmitter::marshalInputArgs(Node *n, ParmList *parms, Wrapper *wrapper, MarshallingMode mode, bool is_member, bool is_static) { ... }
    ...

    // JSCEmitter factory

    JSEmitter *swig_javascript_create_JSCEmitter() { ... }


    // ###############################
    // # V8Emitter

    // V8Emitter declaration

    class V8Emitter: public JSEmitter { ... };

    // V8Emitter implementation

    V8Emitter::V8Emitter() { ... }

    int V8Emitter::initialize(Node *n) { ... }

    // V8Emitter factory

    JSEmitter *swig_javascript_create_V8Emitter() { ... }


    // ###############################
    // # Helper implementation (JSEmitterState, Template)

    JSEmitterState::JSEmitterState() { ... }
    ...

    Template::Template(const String *code_) { ... }
    ...


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

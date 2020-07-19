SWIG and Javascript
======================

This chapter describes SWIG's support of Javascript. It does not cover
SWIG basics, but only information that is specific to this module.

Overview
-------------

Javascript is a prototype-based scripting language that is dynamic,
weakly typed and has first-class functions. Its arguably the most
popular language for web development. Javascript has gone beyond being a
browser-based scripting language and with
`node.js <https://nodejs.org>`__, it is also used as a backend
development language.

Native Javascript extensions can be used for applications that embed a
web-browser view or that embed a Javascript engine (such as *node.js*).
Extending a general purpose web-browser is not possible as this would be
a severe security issue.

SWIG Javascript currently supports **JavascriptCore**, the Javascript
engine used by ``Safari/Webkit``, and `v8 <https://v8.dev/>`__, which is
used by ``Chromium`` and ``node.js``.

`WebKit <https://webkit.org/>`__ is a modern browser implementation
available as open-source which can be embedded into an application. With
`node-webkit <https://github.com/rogerwang/node-webkit>`__ there is a
platform which uses Google's ``Chromium`` as Web-Browser widget and
``node.js`` for javascript extensions.

Preliminaries
------------------

Running SWIG
~~~~~~~~~~~~~~~~~~~

Suppose that you defined a SWIG module such as the following:

.. container:: code

   ::

      %module example
      %{
      #include "example.h"
      %}
      int gcd(int x, int y);
      extern double Foo;

To build a Javascript module, run SWIG using the ``-javascript`` option
and a desired target engine ``-jsc``, ``-v8``, or ``-node``. The
generator for ``node`` is essentially delegating to the ``v8`` generator
and adds some necessary preprocessor definitions.

.. container:: shell

   ::

      $ swig -javascript -jsc example.i

If building a C++ extension, add the -c++ option:

.. container:: shell

   ::

      $ swig -c++ -javascript -jsc example.i

The V8 code that SWIG generates should work with most versions from
up to 3.29.14 and later.

The API headers for V8 >= 4.3.0 define constants which SWIG can use to
determine the V8 version it is compiling for. For versions < 4.3.0, you
need to specify the V8 version when running SWIG. This is specified as a
hex constant, but the constant is read as pairs of decimal digits, so
for V8 3.25.30 use constant 0x032530. This scheme can't represent
components > 99, but this constant is only useful for V8 < 4.3.0, and no
V8 versions from that era had a component > 99. For example:

.. container:: shell

   ::

      $ swig -c++ -javascript -v8 -DV8_VERSION=0x032530 example.i

If you're targeting V8 >= 4.3.0, you would just run swig like so:

.. container:: shell

   ::

      $ swig -c++ -javascript -v8 example.i

This creates a C/C++ source file ``example_wrap.c`` or
``example_wrap.cxx``. The generated C source file contains the low-level
wrappers that need to be compiled and linked with the rest of your C/C++
application to create an extension module.

The name of the wrapper file is derived from the name of the input file.
For example, if the input file is ``example.i``, the name of the wrapper
file is ``example_wrap.c``. To change this, you can use the -o option.
The wrapped module will export one function which must be called to
register the module with the Javascript interpreter. For example, if
your module is named ``example`` the corresponding initializer for
JavascriptCore would be

.. container:: code

   ::

      bool example_initialize(JSGlobalContextRef context, JSObjectRef *exports)

and for v8:

.. container:: code

   ::

      void example_initialize(v8::Handle<v8::Object> exports)

**Note**: be aware that ``v8`` has a C++ API, and thus, the generated
modules must be compiled as C++.

Running Tests and Examples
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The configuration for tests and examples currently supports Linux and
Mac only and not MinGW (Windows) yet.

The default interpreter is ``node.js`` as it is available on all
platforms and convenient to use.

Running the examples with JavascriptCore requires
``libjavascriptcoregtk-1.0`` to be installed, e.g., under Ubuntu with

.. container:: shell

   ::

      $ sudo apt-get install libjavascriptcoregtk-1.0-dev

Running with ``V8`` requires ``libv8``:

.. container:: shell

   ::

      $ sudo apt-get install libv8-dev

Examples can be run using

.. container:: shell

   ::

      $ make check-javascript-examples ENGINE=jsc

``ENGINE`` can be ``node``, ``jsc``, or ``v8``.

The test-suite can be run using

.. container:: shell

   ::

      $ make check-javascript-test-suite ENGINE=jsc

You can specify a specific ``V8`` version for running the examples and
tests

.. container:: shell

   ::

      $ make check-javascript-examples V8_VERSION=0x032530 ENGINE=v8

Known Issues
~~~~~~~~~~~~~~~~~~~

At the moment, the Javascript generators pass all tests syntactically,
i.e., the generated source code compiles. However, there are still
remaining runtime issues.

-  Default optional arguments do not work for all targeted interpreters

-  Multiple output arguments do not work for JSC

-  C89 incompatibility: the JSC generator might still generate C89
   violating code

-  ``long long`` is not supported

-  Javascript callbacks are not supported

-  ``instanceOf`` does not work under JSC

The primary development environment has been Linux (Ubuntu 12.04).
Windows and Mac OS X have been tested sporadically. Therefore, the
generators might have more issues on those platforms. Please report back
any problem you observe to help us improving this module quickly.

Integration
----------------

This chapter gives a short introduction how to use a native Javascript
extension: as a ``node.js`` module, and as an extension for an embedded
Webkit.

Creating node.js Extensions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To install ``node.js`` you can download an installer from their
`web-site <https://launchpad.net/~chris-lea/+archive/node.js>`__ for Mac
OS X and Windows. For Linux you can either build the source yourself and
run ``sudo checkinstall`` or keep to the (probably stone-age) packaged
version. For Ubuntu there is a
`PPA <https://launchpad.net/~chris-lea/+archive/ubuntu/node.js/>`__
available.

.. container:: shell

   ::

      $ sudo add-apt-repository ppa:chris-lea/node.js
      $ sudo apt-get update
      $ sudo apt-get install nodejs

As ``v8`` is written in C++ and comes as a C++ library it is crucial to
compile your module using the same compiler flags as used for building
v8. To make things easier, ``node.js`` provides a build tool called
``node-gyp``.

You have to install it using ``npm``:

.. container:: shell

   ::

      $ sudo npm install -g node-gyp

``node-gyp`` expects a configuration file named ``binding.gyp`` which is
basically in JSON format and conforms to the same format that is used
with Google's build-tool ``gyp``.

``binding.gyp``:

.. container:: code

   ::

      {
        "targets": [
          {
            "target_name": "example",
            "sources": [ "example.cxx", "example_wrap.cxx" ]
          }
        ]
      }

First create the wrapper using SWIG:

.. container:: shell

   ::

      $ swig -javascript -node -c++ example.i

Then run ``node-gyp build`` to actually create the module:

.. container:: shell

   ::

      $ node-gyp build

This will create a ``build`` folder containing the native module. To use
the extension you need to 'require' it in your Javascript source file:

.. container:: code

   ::

      require("./build/Release/example")

A more detailed explanation is given in the
`Examples <#Javascript_examples>`__ section.

Troubleshooting
^^^^^^^^^^^^^^^^^^^^^^^^

-  *'module' object has no attribute 'script_main'*

This error happens when ``gyp`` is installed as a distribution package.
It seems to be outdated. Removing it resolves the problem.

.. container:: shell

   ::

      $ sudo apt-get remove gyp

Embedded Webkit
~~~~~~~~~~~~~~~~~~~~~~

Webkit is pre-installed on Mac OS X and available as a library for GTK.

Mac OS X
^^^^^^^^^^^^^^^^^

There is general information about programming with WebKit on `Apple
Developer
Documentation <https://developer.apple.com/library/mac/documentation/cocoa/conceptual/DisplayWebContent/DisplayWebContent.html>`__.
Details about ``Cocoa`` programming are not covered here.

An integration of a native extension 'example' would look like this:

.. container:: code

   ::

      #import "appDelegate.h"

      extern bool example_initialize(JSGlobalContextRef context, JSObjectRef* exports);


      @implementation ExampleAppDelegate

      @synthesize webView;

      - (void)addGlobalObject:(JSContextRef) context:(NSString *)objectName:(JSObjectRef) theObject {
        JSObjectRef global = JSContextGetGlobalObject(context);
        JSStringRef objectJSName = JSStringCreateWithCFString( (CFStringRef) objectName )
        if ( objectJSName != NULL ) {
          JSObjectSetProperty(context, global, objectJSName, theObject, kJSPropertyAttributeReadOnly, NULL);
          JSStringRelease( objectJSName );
        }
      }

      - (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

        // Start a webview with the bundled index.html file
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *url =  [NSString stringWithFormat: @"file://%@/Contents/Assets/index.html", path];

        WebFrame *webframe = [webView mainFrame];
        JSGlobalContextRef context = [webframe globalContext];

        JSObjectRef example;
        example_initialize(context, &example);
        [self addGlobalObject:context:@"example":example]

        JSObjectSetProperty(context, global, JSStringRef propertyName, example, JSPropertyAttributes attributes, NULL);

        [ [webView mainFrame] loadRequest:
          [NSURLRequest requestWithURL: [NSURL URLWithString:url] ]
        ];
      }

      @end

GTK
^^^^^^^^^^^^

There is general information about programming GTK at `GTK
documentation <https://developer.gnome.org/gtk2/>`__ and in the `GTK
tutorial <https://developer.gnome.org/gtk-tutorial/>`__, and for Webkit
there is a `Webkit GTK+ API
Reference <http://webkitgtk.org/reference/webkitgtk/stable/index.html>`__.

An integration of a native extension 'example' would look like this:

.. container:: code

   ::

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
        JSObjectRef global = JSContextGetGlobalObject(context);

        JSObjectRef exampleModule;
        example_initialize(context, &exampleModule);
        JSStringRef jsName = JSStringCreateWithUTF8CString("example");
        JSObjectSetProperty(context, global, jsName, exampleModule, kJSPropertyAttributeReadOnly, NULL);
        JSStringRelease(jsName);

        ...

        // Load a web page into the browser instance
        webkit_web_view_load_uri(webView, "http://www.webkitgtk.org/");

        ...

        // Run the main GTK+ event loop
        gtk_main();

        return 0;
      }

Creating Applications with node-webkit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To get started with ``node-webkit`` there is a very informative set of
`wiki pages <https://github.com/rogerwang/node-webkit/wiki>`__.

Similar to ``node.js``, ``node-webkit`` is started from command line
within a ``node.js`` project directory. Native extensions are created in
the very same way as for ``node.js``, except that a customized ``gyp``
derivate has to be used:
`nw-gyp <https://github.com/rogerwang/nw-gyp>`__.

A simple example would have the following structure:

.. container:: code

   ::

      - package.json
      - app.html
      - app.js
      - node_modules
        / example
        ... (as known from node.js)

The configuration file essentially conforms to ``node.js`` syntax. It
has some extras to configure ``node-webkit``. See the
`Manifest <https://github.com/rogerwang/node-webkit/wiki/Manifest-format>`__
specification for more details.

``package.json``:

.. container:: code

   ::

      {
        "name": "example",
        "main": "app.html",
        "window": {
          "show": true,
          "width": 800,
          "height": 600
        }
      }

The ``'main'`` property of ``package.json`` specifies a web-page to be
rendered in the main window.

``app.html``:

.. container:: code

   ::

      <html>
        <head>
          <script src="app.js"></script>
        </head>
        <body>
          <div>
            The greatest common divisor of
            <span id="x"></span> and
            <span id="y"></span> is
            <span id="z"></span>.
          </div>
        </body>
      </html>

As known from ``node.js`` one can use ``require`` to load javascript
modules. Additionally, ``node-webkit`` provides an API that allows to
manipulate the window's menu, open new windows, and many more things.

``app.js``:

.. container:: code

   ::

      window.onload = function() {
        var example = require("example");
        var x = 18;
        var y = 24;
        var z = example.gcd(x, y);
        document.querySelector('#x').innerHTML = x;
        document.querySelector('#y').innerHTML = y;
        document.querySelector('#z').innerHTML = z;
      };

Examples
-------------

Some basic examples are shown here in more detail.

Simple
~~~~~~~~~~~~~

The common example ``simple`` looks like this:

.. container:: code

   ::

      /* File : example.i */
      %module example

      %inline %{
      extern int    gcd(int x, int y);
      extern double Foo;
      %}

To make this available as a node extension a ``binding.gyp`` has to be
created:

.. container:: code

   ::

      {
        "targets": [
          {
            "target_name": "example",
            "sources": [ "example.cxx", "example_wrap.cxx" ]
          }
        ]
      }

Then ``node-gyp`` is used to build the extension:

.. container:: shell

   ::

      $ node-gyp configure build

From a 'nodejs\` application the extension would be used like this:

.. container:: code

   ::

      // import the extension via require
      var example = require("./build/Release/example");

      // calling the global method
      var x = 42;
      var y = 105;
      var g = example.gcd(x, y);

      // Accessing the global variable
      var f = example.Foo;
      example.Foo = 3.1415926;

First the module ``example`` is loaded from the previously built
extension. Global methods and variables are available in the scope of
the module.

**Note**: ECMAScript 5, the currently implemented Javascript standard,
does not have modules. ``node.js`` and other implementations provide
this mechanism defined by the
`CommonJS <http://wiki.commonjs.org/wiki/CommonJS>`__ group. For
browsers this is provided by `Browserify <http://browserify.org>`__, for
instance.

Class
~~~~~~~~~~~~

The common example ``class`` defines three classes, ``Shape``,
``Circle``, and ``Square``:

.. container:: code

   ::

      class Shape {
      public:
        Shape() {
          nshapes++;
        }
        virtual ~Shape() {
          nshapes--;
        }
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
        Circle(double r) : radius(r) { }
        virtual double area(void);
        virtual double perimeter(void);
      };

      class Square : public Shape {
      private:
        double width;
      public:
        Square(double w) : width(w) { }
        virtual double area(void);
        virtual double perimeter(void);
      };

``Circle`` and ``Square`` inherit from ``Shape``. ``Shape`` has a static
variable ``nshapes``, a function ``move`` that can't be overridden
(non-virtual), and two abstract functions ``area`` and ``perimeter``
(pure virtual) that must be overridden by the sub-classes.

A ``nodejs`` extension is built the same way as for the ``simple``
example.

In Javascript it can be used as follows:

.. container:: code

   ::

      var example = require("./build/Release/example");

      // local aliases for convenience
      var Shape = example.Shape;
      var Circle = example.Circle;
      var Square = example.Square;

      // creating new instances using the 'new' operator
      var c = new Circle(10);
      var s = new Square(10);

      // accessing a static member
      Shape.nshapes;

      // accessing member variables
      c.x = 20;
      c.y = 30;
      s.x = -10;
      s.y = 5;

      // calling some methods
      c.area();
      c.perimeter();
      s.area();
      s.perimeter();

      // instantiation of Shape is not permitted
      new Shape();

Running these commands in an interactive node shell results in the
following output:

.. container:: shell

   ::

      $ node -i
      & var example = require("./build/Release/example");
      undefined
      & var Shape = example.Shape;
      undefined
      & var Circle = example.Circle;
      undefined
      & var Square = example.Square;
      undefined
      & var c = new Circle(10);
      undefined
      & var s = new Square(10);
      undefined
      & Shape.nshapes;
      2
      & c.x = 20;
      20
      & c.y = 30;
      30
      & s.x = -10;
      -10
      & s.y = 5;
      5
      & c.area();
      314.1592653589793
      & c.perimeter();
      62.83185307179586
      & s.area();
      100
      & s.perimeter();
      40
      & c.move(40, 40)
      undefined
      & c.x
      60
      & c.y
      70
      & new Shape()
      Error: Class Shape can not be instantiated
      at repl:1:2
      at REPLServer.self.eval (repl.js:110:21)
      at Interface.<anonymous> (repl.js:239:12)
      at Interface.EventEmitter.emit (events.js:95:17)
      at Interface._onLine (readline.js:202:10)
      at Interface._line (readline.js:531:8)
      at Interface._ttyWrite (readline.js:760:14)
      at ReadStream.onkeypress (readline.js:99:10)
      at ReadStream.EventEmitter.emit (events.js:98:17)
      at emitKey (readline.js:1095:12)

**Note**: In ECMAScript 5 there is no concept for classes. Instead each
function can be used as a constructor function which is executed by the
'new' operator. Furthermore, during construction the key property
``prototype`` of the constructor function is used to attach a prototype
instance to the created object. A prototype is essentially an object
itself that is the first-class delegate of a class used whenever the
access to a property of an object fails. The very same prototype
instance is shared among all instances of one type. Prototypal
inheritance is explained in more detail on in `Inheritance and the
prototype
chain <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Inheritance_and_the_prototype_chain>`__,
for instance.

Implementation
-------------------

The Javascript Module implementation has taken a very different approach
compared to other language modules in order to support different
Javascript interpreters.

Source Code
~~~~~~~~~~~~~~~~~~

The Javascript module is implemented in
``Source/Modules/javascript.cxx``. It dispatches the code generation to
a ``JSEmitter`` instance, ``V8Emitter`` or ``JSCEmitter``. Additionally
there are some helpers: ``Template``, for templated code generation, and
``JSEmitterState``, which is used to manage state information during AST
traversal. This rough map shall make it easier to find a way through
this huge source file:

.. container:: code

   ::

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

Code Templates
~~~~~~~~~~~~~~~~~~~~~

All generated code is created on the basis of code templates. The
templates for *JavascriptCore* can be found in
``Lib/javascript/jsc/javascriptcode.swg``, for *v8* in
``Lib/javascript/v8/javascriptcode.swg``.

To track the originating code template for generated code you can run

.. container:: shell

   ::

      $ swig -javascript -jsc -debug-codetemplates

which wraps generated code with a descriptive comment

.. container:: code

   ::

      /* begin fragment("template_name") */

      ...generated code ...

      /* end fragment("template_name") */

The Template class is used like this:

.. container:: code

   ::

      Template t_register = getTemplate("jsv8_register_static_variable");
      t_register.replace("$jsparent", state.clazz(NAME_MANGLED))
          .replace("$jsname", state.variable(NAME))
          .replace("$jsgetter", state.variable(GETTER))
          .replace("$jssetter", state.variable(SETTER))
          .trim().
          print(f_init_static_wrappers);

A code template is registered with the *JSEmitter* via
``fragment(name, "template")``, e.g.,

.. container:: code

   ::

      %fragment ("jsc_variable_declaration", "templates")
      %{
        {"$jsname", $jsgetter, $jssetter, kJSPropertyAttributeNone},
      %}

``Template`` creates a copy of that string and ``Template::replace``
uses Swig's ``Replaceall`` to replace variables in the template.
``Template::trim`` can be used to eliminate leading and trailing
whitespaces. ``Template::print`` is used to write the final template
string to a Swig ``DOH`` (based on ``Printv``). All methods allow
chaining.

Emitter
~~~~~~~~~~~~~~

The Javascript module delegates code generation to a ``JSEmitter``
instance. The following extract shows the essential interface:

.. container:: code

   ::

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
        }

        /**
         * Invoked at the beginning of the variableHandler.
         */
        virtual int enterVariable(Node *);

        /**
         * Invoked at the end of the variableHandler.
         */
        virtual int exitVariable(Node *) {
          return SWIG_OK;
        }

        /**
         * Invoked at the beginning of the functionHandler.
         */
        virtual int enterFunction(Node *);

        /**
         * Invoked at the end of the functionHandler.
         */
        virtual int exitFunction(Node *) {
          return SWIG_OK;
        }

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

The module calls ``initialize``, ``dump``, and ``close`` from within the
``top`` method:

.. container:: code

   ::

      int JAVASCRIPT::top(Node *n) {
        emitter->initialize(n);

        Language::top(n);

        emitter->dump(n);
        emitter->close();

        return SWIG_OK;
      }

The methods ``enterClass`` and ``exitClass`` are called from within the
``classHandler`` method:

.. container:: code

   ::

      int JAVASCRIPT::classHandler(Node *n) {

        emitter->enterClass(n);
        Language::classHandler(n);
        emitter->exitClass(n);

        return SWIG_OK;
      }

In ``enterClass`` the emitter stores state information that is necessary
when processing class members. In ``exitClass`` the wrapper code for the
whole class is generated.

Emitter states
~~~~~~~~~~~~~~~~~~~~~

For storing information during the AST traversal the emitter provides a
``JSEmitterState`` with different slots to store data representing the
scopes global, class, function, and variable.

.. container:: code

   ::

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

When entering a scope, such as in ``enterClass``, the corresponding
state is reset and new data is stored:

.. container:: code

   ::

      state.clazz(RESET);
      state.clazz(NAME, Getattr(n, "sym:name"));

State information can be retrieved using ``state.clazz(NAME)`` or with
``Getattr`` on ``state.clazz()`` which actually returns a ``Hash``
instance.

Handling Exceptions in JavascriptCore
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Applications with an embedded JavascriptCore should be able to present
detailed exception messages that occur in the Javascript engine. Below
is an example derived from code provided by Brian Barnes on how these
exception details can be extracted.

.. container:: code

   ::

      void script_exception_to_string(JSContextRef js_context, JSValueRef exception_value_ref, char* return_error_string, int return_error_string_max_length)
      {
        JSObjectRef exception_object;
        JSValueRef value_ref;
        JSStringRef jsstring_property_name = NULL;
        JSValueRef temporary_exception = NULL;
        JSStringRef js_return_string = NULL;
        size_t bytes_needed;
        char* c_result_string = NULL;
        exception_object = JSValueToObject(js_context, exception_value_ref, NULL);

        /* source url */
        strcpy(return_error_string, "[");
        jsstring_property_name = JSStringCreateWithUTF8CString("sourceURL");
        value_ref = JSObjectGetProperty(js_context, exception_object, jsstring_property_name, &temporary_exception);
        JSStringRelease(jsstring_property_name);
        js_return_string = JSValueToStringCopy(js_context, value_ref, NULL);
        bytes_needed = JSStringGetMaximumUTF8CStringSize(js_return_string);
        c_result_string = (char*)calloc(bytes_needed, sizeof(char));
        JSStringGetUTF8CString(js_return_string, c_result_string, bytes_needed);
        JSStringRelease(js_return_string);
        strncat(return_error_string, c_result_string, return_error_string_max_length-1);
        free(c_result_string);

        strncat(return_error_string, ":", return_error_string_max_length-1);

        /* line number */

        jsstring_property_name = JSStringCreateWithUTF8CString("line");
        value_ref = JSObjectGetProperty(js_context, exception_object, jsstring_property_name, &temporary_exception);
        JSStringRelease(jsstring_property_name);
        js_return_string = JSValueToStringCopy(js_context, value_ref, NULL);
        bytes_needed = JSStringGetMaximumUTF8CStringSize(js_return_string);
        c_result_string = (char*)calloc(bytes_needed, sizeof(char));
        JSStringGetUTF8CString(js_return_string, c_result_string, bytes_needed);
        JSStringRelease(js_return_string);
        strncat(return_error_string, c_result_string, return_error_string_max_length-1);
        free(c_result_string);

        strncat(return_error_string, "]", return_error_string_max_length-1);

        /* error message */

        jsstring_property_name = JSStringCreateWithUTF8CString("message");
        value_ref = JSObjectGetProperty(js_context, exception_object, jsstring_property_name, &temporary_exception);
        JSStringRelease(jsstring_property_name);
        if(NULL == value_ref)
        {
          strncat(return_error_string, "Unknown Error", return_error_string_max_length-1);
        }
        else
        {
          js_return_string = JSValueToStringCopy(js_context, value_ref, NULL);
          bytes_needed = JSStringGetMaximumUTF8CStringSize(js_return_string);
          c_result_string = (char*)calloc(bytes_needed, sizeof(char));
          JSStringGetUTF8CString(js_return_string, c_result_string, bytes_needed);
          JSStringRelease(js_return_string);
          strncat(return_error_string, c_result_string, return_error_string_max_length-1);
          free(c_result_string);
        }
      }

It would be used in the following way:

.. container:: code

   ::

      if(js_exception)
      {
        char return_error_string[256];
        script_exception_to_string(js_context, js_exception, return_error_string, 256);
        printf("Compile error is %s", return_error_string);
      }

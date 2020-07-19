SWIG and Ruby
================

This chapter describes SWIG's support of Ruby.

Preliminaries
------------------

SWIG 4.0 is known to work with Ruby versions 1.9 and later. Given the
choice, you should use the latest stable version of Ruby. You should
also determine if your system supports shared libraries and dynamic
loading. SWIG will work with or without dynamic loading, but the
compilation process will vary.

This chapter covers most SWIG features, but in less depth than is found
in earlier chapters. At the very least, make sure you also read the
"`SWIG Basics <SWIG.html#SWIG>`__" chapter. It is also assumed that the
reader has a basic understanding of Ruby.

Running SWIG
~~~~~~~~~~~~~~~~~~~

To build a Ruby module, run SWIG using the ``-ruby`` option:

.. container:: code shell

   ::

      $ swig -ruby example.i

If building a C++ extension, add the ``-c++`` option:

.. container:: code shell

   ::

      $ swig -c++ -ruby example.i

This creates a file ``example_wrap.c`` (``example_wrap.cxx`` if
compiling a C++ extension) that contains all of the code needed to build
a Ruby extension module. To finish building the module, you need to
compile this file and link it with the rest of your program.

Getting the right header files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to compile the wrapper code, the compiler needs the ``ruby.h``
header file and its dependencies, notably ``ruby/config.h`` which is
found in a different, architecture-dependent, directory. The best way to
find the compiler options needed to compile the code is to ask Ruby
itself:

.. container:: code shell

   ::

      $ ruby -rrbconfig -e 'puts "-I#{RbConfig::CONFIG[%q{rubyhdrdir}]} -I#{RbConfig::CONFIG[%q{rubyarchhdrdir}]}"'
      -I/usr/include/ruby-2.1.0 -I/usr/include/x86_64-linux-gnu/ruby-2.1.0

Compiling a dynamic module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ruby extension modules are typically compiled into shared libraries that
the interpreter loads dynamically at runtime. Since the exact commands
for doing this vary from platform to platform, your best bet is to
follow the steps described in the ``README.EXT`` file from the Ruby
distribution:

#. Create a file called ``extconf.rb`` that looks like the following:

   .. container:: code targetlang

      ::

         require 'mkmf'
         create_makefile('example')

#. Type the following to build the extension:

   .. container:: code shell

      ::

         $ ruby extconf.rb
         $ make
         $ make install
             

Of course, there is the problem that mkmf does not work correctly on all
platforms, e.g, HPUX. If you need to add your own make rules to the file
that ``extconf.rb`` produces, you can add this:

.. container:: code targetlang

   ::

      open("Makefile", "a") { |mf|
       puts <<EOM
       # Your make rules go here
       EOM
      }

to the end of the ``extconf.rb`` file. If for some reason you don't want
to use the standard approach, you'll need to determine the correct
compiler and linker flags for your build platform. For example, assuming
you have code you need to link to in a file called ``example.c``, a
typical sequence of commands for the Linux operating system would look
something like this:

.. container:: code shell

   ::

      $ swig -ruby example.i
      $ gcc -O2 -fPIC -c example.c
      $ gcc -O2 -fPIC -c example_wrap.c -I/usr/include/ruby-2.1.0
      $ gcc -shared example.o example_wrap.o -o example.so

The -fPIC option tells GCC to generate position-independent code (PIC)
which is required for most architectures (it's not vital on x86, but
still a good idea as it allows code pages from the library to be shared
between processes). Other compilers may need a different option
specified instead of -fPIC.

If in doubt, consult the manual pages for your compiler and linker to
determine the correct set of options. You might also check the `SWIG
Wiki <https://github.com/swig/swig/wiki>`__ for additional information.

Using your module
~~~~~~~~~~~~~~~~~~~~~~~~

Ruby *module* names must be capitalized, but the convention for Ruby
*feature* names is to use lowercase names. So, for example, the **Etc**
extension module is imported by requiring the **etc** feature:

.. container:: code targetlang

   ::

      # The feature name begins with a lowercase letter...
      require 'etc'

      # ... but the module name begins with an uppercase letter
      puts "Your login name: #{Etc.getlogin}"

To stay consistent with this practice, you should always specify a
**lowercase** module name with SWIG's ``%module`` directive. SWIG will
automatically correct the resulting Ruby module name for your extension.
So for example, a SWIG interface file that begins with:

.. container:: code

   ::

      %module example

will result in an extension module using the feature name "example" and
Ruby module name "Example".

Static linking
~~~~~~~~~~~~~~~~~~~~~

An alternative approach to dynamic linking is to rebuild the Ruby
interpreter with your extension module added to it. In the past, this
approach was sometimes necessary due to limitations in dynamic loading
support on certain machines. However, the situation has improved greatly
over the last few years and you should not consider this approach unless
there is really no other option.

The usual procedure for adding a new module to Ruby involves finding the
Ruby source, adding an entry to the ``ext/Setup`` file, adding your
directory to the list of extensions in the file, and finally rebuilding
Ruby.

Compilation of C++ extensions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On most machines, C++ extension modules should be linked using the C++
compiler. For example:

.. container:: code shell

   ::

      $ swig -c++ -ruby example.i
      $ g++ -fPIC -c example.cxx
      $ g++ -fPIC -c example_wrap.cxx -I/usr/include/ruby-2.1.0
      $ g++ -shared example.o example_wrap.o -o example.so

If you've written an ``extconf.rb`` script to automatically generate a
``Makefile`` for your C++ extension module, keep in mind that (as of
this writing) Ruby still uses ``gcc`` and not ``g++`` as its linker. As
a result, the required C++ runtime library support will not be
automatically linked into your extension module and it may fail to load
on some platforms. A workaround for this problem is use the ``mkmf``
module's ``append_library()`` method to add one of the C++ runtime
libraries to the list of libraries linked into your extension, e.g.

.. container:: code targetlang

   ::

      require 'mkmf'
      $libs = append_library($libs, "supc++")
      create_makefile('example')

Building Ruby Extensions under Windows 95/NT
-------------------------------------------------

Building a SWIG extension to Ruby under Windows 95/NT is roughly similar
to the process used with Unix. Normally, you will want to produce a DLL
that can be loaded into the Ruby interpreter. For all recent versions of
Ruby, the procedure described above (i.e. using an ``extconf.rb``
script) will work with Windows as well; you should be able to build your
code into a DLL by typing:

.. container:: code shell

   ::

      C:\swigtest> ruby extconf.rb
      C:\swigtest> nmake
      C:\swigtest> nmake install

The remainder of this section covers the process of compiling
SWIG-generated Ruby extensions with Microsoft Visual C++ 6 (i.e. within
the Developer Studio IDE, instead of using the command line tools). In
order to build extensions, you may need to download the source
distribution to the Ruby package, as you will need the Ruby header
files.

Running SWIG from Developer Studio
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are developing your application within Microsoft developer
studio, SWIG can be invoked as a custom build option. The process
roughly follows these steps :

-  Open up a new workspace and use the AppWizard to select a DLL
   project.
-  Add both the SWIG interface file (the .i file), any supporting C
   files, and the name of the wrapper file that will be created by SWIG
   (i.e. ``example_wrap.c``). Note : If using C++, choose a different
   suffix for the wrapper file such as ``example_wrap.cxx``. Don't worry
   if the wrapper file doesn't exist yet--Developer Studio will keep a
   reference to it around.
-  Select the SWIG interface file and go to the settings menu. Under
   settings, select the "Custom Build" option.
-  Enter "SWIG" in the description field.
-  Enter "``swig -ruby -o $(ProjDir)\$(InputName)_wrap.c $(InputPath)``"
   in the "Build command(s) field". You may have to include the path to
   swig.exe.
-  Enter "``$(ProjDir)\$(InputName)_wrap.c``" in the "Output files(s)
   field".
-  Next, select the settings for the entire project and go to the C/C++
   tab and select the Preprocessor category. Add NT=1 to the
   Preprocessor definitions. This must be set else you will get
   compilation errors. Also add IMPORT to the preprocessor definitions,
   else you may get runtime errors. Also add the include directories for
   your Ruby installation under "Additional include directories".
-  Next, select the settings for the entire project and go to the Link
   tab and select the General category. Set the name of the output file
   to match the name of your Ruby module (i.e.. example.dll). Next add
   the Ruby library file to your link libraries under Object/Library
   modules. For example "mswin32-ruby16.lib. You also need to add the
   path to the library under the Input tab - Additional library path.
-  Build your project.

Now, assuming all went well, SWIG will be automatically invoked when you
build your project. Any changes made to the interface file will result
in SWIG being automatically invoked to produce a new version of the
wrapper file. To run your new Ruby extension, simply run Ruby and use
the ``require`` command as normal. For example if you have this ruby
file run.rb:

.. container:: code targetlang

   ::

      # file: run.rb
      require 'Example'

      # Call a c function
      print "Foo = ", Example.Foo, "\n"

Ensure the dll just built is in your path or current directory, then run
the Ruby script from the DOS/Command prompt:

.. container:: code shell

   ::

      C:\swigtest> ruby run.rb
      Foo = 3.0

The Ruby-to-C/C++ Mapping
------------------------------

This section describes the basics of how SWIG maps C or C++ declarations
in your SWIG interface files to Ruby constructs.

Modules
~~~~~~~~~~~~~~

The SWIG ``%module`` directive specifies the name of the Ruby module. If
you specify:

.. container:: code

   ::

      %module example

then everything is wrapped into a Ruby module named ``Example`` that is
nested directly under the global module. You can specify a more deeply
nested module by specifying the fully-qualified module name in quotes,
e.g.

.. container:: code

   ::

      %module "foo::bar::spam"

An alternate method of specifying a nested module name is to use the
``-prefix`` option on the SWIG command line. The prefix that you specify
with this option will be prepended to the module name specified with the
``%module`` directive in your SWIG interface file. So for example, this
declaration at the top of your SWIG interface file:

.. container:: code

   ::

      %module "foo::bar::spam"

will result in a nested module name of ``Foo::Bar::Spam``, but you can
achieve the same effect by specifying:

.. container:: code

   ::

      %module spam

and then running SWIG with the ``-prefix`` command line option:

.. container:: code shell

   ::

      $ swig -ruby -prefix "foo::bar::" example.i

Starting with SWIG 1.3.20, you can also choose to wrap everything into
the global module by specifying the ``-globalmodule`` option on the SWIG
command line, i.e.

.. container:: code shell

   ::

      $ swig -ruby -globalmodule example.i

Note that this does not relieve you of the requirement of specifying the
SWIG module name with the ``%module`` directive (or the ``-module``
command-line option) as described earlier.

When choosing a module name, do not use the same name as a built-in Ruby
command or standard module name, as the results may be unpredictable.
Similarly, if you're using the ``-globalmodule`` option to wrap
everything into the global module, take care that the names of your
constants, classes and methods don't conflict with any of Ruby's
built-in names.

Functions
~~~~~~~~~~~~~~~~

Global functions are wrapped as Ruby module methods. For example, given
the SWIG interface file ``example.i``:

.. container:: code

   ::

      %module example

      int fact(int n);

and C source file ``example.c``:

.. container:: code

   ::

      int fact(int n) {
        if (n == 0)
        return 1;
        return (n * fact(n-1));
      }

SWIG will generate a method *fact* in the *Example* module that can be
used like so:

.. container:: code targetlang

   ::

      $ irb
      irb(main):001:0> require 'example'
      true
      irb(main):002:0> Example.fact(4)
      24

Variable Linking
~~~~~~~~~~~~~~~~~~~~~~~

C/C++ global variables are wrapped as a pair of singleton methods for
the module: one to get the value of the global variable and one to set
it. For example, the following SWIG interface file declares two global
variables:

.. container:: code

   ::

      // SWIG interface file with global variables
      %module example
      ...
      %inline %{
        extern int variable1;
        extern double Variable2;
      %}
      ...

Now look at the Ruby interface:

.. container:: code targetlang

   ::

      $ irb
      irb(main):001:0> require 'Example'
      true
      irb(main):002:0> Example.variable1 = 2
      2
      irb(main):003:0> Example.Variable2 = 4 * 10.3
      41.2
      irb(main):004:0> Example.Variable2
      41.2

If you make an error in variable assignment, you will receive an error
message. For example:

.. container:: code targetlang

   ::

      irb(main):005:0> Example.Variable2 = "hello"
      TypeError: no implicit conversion to float from string
      from (irb):5:in `Variable2='
      from (irb):5

If a variable is declared as ``const``, it is wrapped as a read-only
variable. Attempts to modify its value will result in an error.

To make ordinary variables read-only, you can also use the
``%immutable`` directive. For example:

.. container:: code

   ::

      %immutable;
      %inline %{
        extern char *path;
      %}
      %mutable;

The ``%immutable`` directive stays in effect until it is explicitly
disabled using ``%mutable``.

Note: When SWIG is invoked with the ``-globalmodule`` option in effect,
the C/C++ global variables will be translated into Ruby global
variables. Type-checking and the optional read-only characteristic are
available in the same way as described above. However the example would
then have to be modified and executed in the following way:

.. container:: code targetlang

   ::

      $ irb
      irb(main):001:0> require 'Example'
      true
      irb(main):002:0> $variable1 = 2
      2
      irb(main):003:0> $Variable2 = 4 * 10.3
      41.2
      irb(main):004:0> $Variable2
      41.2

Constants
~~~~~~~~~~~~~~~~

C/C++ constants are wrapped as module constants initialized to the
appropriate value. To create a constant, use ``#define`` or the
``%constant`` directive. For example:

.. container:: code

   ::

      #define PI 3.14159
      #define VERSION "1.0"

      %constant int FOO = 42;
      %constant const char *path = "/usr/local";

      const int BAR = 32;

Remember to use the :: operator in Ruby to get at these constant values,
e.g.

.. container:: code targetlang

   ::

      $ irb
      irb(main):001:0> require 'Example'
      true
      irb(main):002:0> Example::PI
      3.14159

Pointers
~~~~~~~~~~~~~~~

"Opaque" pointers to arbitrary C/C++ types (i.e. types that aren't
explicitly declared in your SWIG interface file) are wrapped as data
objects. So, for example, consider a SWIG interface file containing only
the declarations:

.. container:: code

   ::

      Foo *get_foo();
      void set_foo(Foo *foo);

For this case, the *get_foo()* method returns an instance of an
internally generated Ruby class:

.. container:: code targetlang

   ::

      irb(main):001:0> foo = Example::get_foo()
      #<SWIG::TYPE_p_Foo:0x402b1654>

A ``NULL`` pointer is always represented by the Ruby ``nil`` object.

Structures
~~~~~~~~~~~~~~~~~

C/C++ structs are wrapped as Ruby classes, with accessor methods (i.e.
"getters" and "setters") for all of the struct members. For example,
this struct declaration:

.. container:: code

   ::

      struct Vector {
        double x, y;
      };

gets wrapped as a ``Vector`` class, with Ruby instance methods ``x``,
``x=``, ``y`` and ``y=``. These methods can be used to access structure
data from Ruby as follows:

.. container:: code targetlang

   ::

      $ irb
      irb(main):001:0> require 'Example'
      true
      irb(main):002:0> f = Example::Vector.new
      #<Example::Vector:0x4020b268>
      irb(main):003:0> f.x = 10
      nil
      irb(main):004:0> f.x
      10.0

Similar access is provided for unions and the public data members of C++
classes.

``const`` members of a structure are read-only. Data members can also be
forced to be read-only using the ``%immutable`` directive (in C++,
``private`` may also be used). For example:

.. container:: code

   ::

      struct Foo {
        ...
        %immutable;
        int x; /* Read-only members */
        char *name;
        %mutable;
        ...
      };

When ``char *`` members of a structure are wrapped, the contents are
assumed to be dynamically allocated using ``malloc`` or ``new``
(depending on whether or not SWIG is run with the ``-c++`` option). When
the structure member is set, the old contents will be released and a new
value created. If this is not the behavior you want, you will have to
use a typemap (described shortly).

Array members are normally wrapped as read-only. For example, this code:

.. container:: code

   ::

      struct Foo {
        int x[50];
      };

produces a single accessor function like this:

.. container:: code

   ::

      int *Foo_x_get(Foo *self) {
        return self->x;
      };

If you want to set an array member, you will need to supply a "memberin"
typemap described in the `section on
typemaps <#Ruby_memberin_typemap>`__. As a special case, SWIG does
generate code to set array members of type ``char`` (allowing you to
store a Ruby string in the structure).

When structure members are wrapped, they are handled as pointers. For
example,

.. container:: code

   ::

      struct Foo {
        ...
      };

      struct Bar {
        Foo f;
      };

generates accessor functions such as this:

.. container:: code

   ::

      Foo *Bar_f_get(Bar *b) {
        return &b->f;
      }

      void Bar_f_set(Bar *b, Foo *val) {
        b->f = *val;
      }

C++ classes
~~~~~~~~~~~~~~~~~~

Like structs, C++ classes are wrapped by creating a new Ruby class of
the same name with accessor methods for the public class member data.
Additionally, public member functions for the class are wrapped as Ruby
instance methods, and public static member functions are wrapped as Ruby
singleton methods. So, given the C++ class declaration:

.. container:: code

   ::

      class List {
      public:
        List();
        ~List();
        int search(char *item);
        void insert(char *item);
        void remove(char *item);
        char *get(int n);
        int length;
        static void print(List *l);
      };

SWIG would create a ``List`` class with:

-  instance methods *search*, *insert*, *remove*, and *get*;
-  instance methods *length* and *length=* (to get and set the value of
   the *length* data member); and,
-  a *print* singleton method for the class.

In Ruby, these functions are used as follows:

.. container:: code targetlang

   ::

      require 'Example'

      l = Example::List.new

      l.insert("Ale")
      l.insert("Stout")
      l.insert("Lager")
      Example.print(l)
      l.length()
      ----- produces the following output 
      Lager
      Stout
      Ale
      3

C++ Inheritance
~~~~~~~~~~~~~~~~~~~~~~

The SWIG type-checker is fully aware of C++ inheritance. Therefore, if
you have classes like this:

.. container:: code

   ::

      class Parent {
        ...
      };

      class Child : public Parent {
        ...
      };

those classes are wrapped into a hierarchy of Ruby classes that reflect
the same inheritance structure. All of the usual Ruby utility methods
work normally:

.. container:: code

   ::

      irb(main):001:0> c = Child.new
      #<Bar:0x4016efd4>
      irb(main):002:0> c.instance_of? Child
      true
      irb(main):003:0> b.instance_of? Parent
      false
      irb(main):004:0> b.is_a? Child
      true
      irb(main):005:0> b.is_a? Parent
      true
      irb(main):006:0> Child < Parent
      true
      irb(main):007:0> Child > Parent
      false

Furthermore, if you have a function like this:

.. container:: code

   ::

      void spam(Parent *f);

then the function ``spam()`` accepts ``Parent``\ \* or a pointer to any
class derived from ``Parent``.

Until recently, the Ruby module for SWIG didn't support multiple
inheritance, and this is still the default behavior. This doesn't mean
that you can't wrap C++ classes which inherit from multiple base
classes; it simply means that only the **first** base class listed in
the class declaration is considered, and any additional base classes are
ignored. As an example, consider a SWIG interface file with a
declaration like this:

.. container:: code

   ::

      class Derived : public Base1, public Base2
      {
        ...
      };

For this case, the resulting Ruby class (``Derived``) will only consider
``Base1`` as its superclass. It won't inherit any of ``Base2``'s member
functions or data and it won't recognize ``Base2`` as an "ancestor" of
``Derived`` (i.e. the *is_a?* relationship would fail). When SWIG
processes this interface file, you'll see a warning message like:

.. container:: code shell

   ::

      example.i:5: Warning 802: Warning for Derived: Base Base2 ignored.
      Multiple inheritance is not supported in Ruby.

Starting with SWIG 1.3.20, the Ruby module for SWIG provides limited
support for multiple inheritance. Because the approach for dealing with
multiple inheritance introduces some limitations, this is an optional
feature that you can activate with the ``-minherit`` command-line
option:

.. container:: code shell

   ::

      $ swig -c++ -ruby -minherit example.i

Using our previous example, if your SWIG interface file contains a
declaration like this:

.. container:: code

   ::

      class Derived : public Base1, public Base2
      {
        ...
      };

and you run SWIG with the ``-minherit`` command-line option, then you
will end up with a Ruby class ``Derived`` that appears to "inherit" the
member data and functions from both ``Base1`` and ``Base2``. What
actually happens is that three different top-level classes are created,
with Ruby's ``Object`` class as their superclass. Each of these classes
defines a nested module named ``Impl``, and it's in these nested
``Impl`` modules that the actual instance methods for the classes are
defined, i.e.

.. container:: code targetlang

   ::

      class Base1
        module Impl
        # Define Base1 methods here
        end
        include Impl
      end

      class Base2
        module Impl
        # Define Base2 methods here
        end
        include Impl
      end

      class Derived
        module Impl
        include Base1::Impl
        include Base2::Impl
        # Define Derived methods here
        end
        include Impl
      end

Observe that after the nested ``Impl`` module for a class is defined, it
is mixed-in to the class itself. Also observe that the ``Derived::Impl``
module first mixes-in its base classes' ``Impl`` modules, thus
"inheriting" all of their behavior.

The primary drawback is that, unlike the default mode of operation,
neither ``Base1`` nor ``Base2`` is a true superclass of ``Derived``
anymore:

.. container:: code targetlang

   ::

      obj = Derived.new
      obj.is_a? Base1 # this will return false...
      obj.is_a? Base2 # ... and so will this

In most cases, this is not a serious problem since objects of type
``Derived`` will otherwise behave as though they inherit from both
``Base1`` and ``Base2`` (i.e. they exhibit `"Duck
Typing" <http://c2.com/cgi/wiki?DuckTyping>`__).

C++ Overloaded Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C++ overloaded functions, methods, and constructors are mostly supported
by SWIG. For example, if you have two functions like this:

.. container:: code

   ::

      void foo(int);
      void foo(char *c);

You can use them in Ruby in a straightforward manner:

.. container:: code targetlang

   ::

      irb(main):001:0> foo(3) # foo(int)
      irb(main):002:0> foo("Hello") # foo(char *c)

Similarly, if you have a class like this,

.. container:: code

   ::

      class Foo {
      public:
        Foo();
        Foo(const Foo &);
        ...
      };

you can write Ruby code like this:

.. container:: code targetlang

   ::

      irb(main):001:0> f = Foo.new # Create a Foo
      irb(main):002:0> g = Foo.new(f) # Copy f

Overloading support is not quite as flexible as in C++. Sometimes there
are methods that SWIG can't disambiguate. For example:

.. container:: code

   ::

      void spam(int);
      void spam(short);

or

.. container:: code

   ::

      void foo(Bar *b);
      void foo(Bar &b);

If declarations such as these appear, you will get a warning message
like this:

.. container:: code shell

   ::

      example.i:12: Warning 509: Overloaded method spam(short) effectively ignored,
      example.i:11: Warning 509: as it is shadowed by spam(int).

To fix this, you either need to ignore or rename one of the methods. For
example:

.. container:: code

   ::

      %rename(spam_short) spam(short);
      ...
      void spam(int); 
      void spam(short); // Accessed as spam_short

or

.. container:: code

   ::

      %ignore spam(short);
      ...
      void spam(int); 
      void spam(short); // Ignored

SWIG resolves overloaded functions and methods using a disambiguation
scheme that ranks and sorts declarations according to a set of
type-precedence rules. The order in which declarations appear in the
input does not matter except in situations where ambiguity arises--in
this case, the first declaration takes precedence.

Please refer to the `"SWIG and C++" <SWIGPlus.html#SWIGPlus>`__ chapter
for more information about overloading.

C++ Operators
~~~~~~~~~~~~~~~~~~~~~

For the most part, overloaded operators are handled automatically by
SWIG and do not require any special treatment on your part. So if your
class declares an overloaded addition operator, e.g.

.. container:: code

   ::

      class Complex {
        ...
        Complex operator+(Complex &);
        ...
      };

the resulting Ruby class will also support the addition (+) method
correctly.

For cases where SWIG's built-in support is not sufficient, C++ operators
can be wrapped using the ``%rename`` directive (available on SWIG 1.3.10
and later releases). All you need to do is give the operator the name of
a valid Ruby identifier. For example:

.. container:: code

   ::

      %rename(add_complex) operator+(Complex &, Complex &);
      ...
      Complex operator+(Complex &, Complex &);

Now, in Ruby, you can do this:

.. container:: code targetlang

   ::

      a = Example::Complex.new(2, 3)
      b = Example::Complex.new(4, -1)
      c = Example.add_complex(a, b)

More details about wrapping C++ operators into Ruby operators is
discussed in the `section on operator
overloading <#Ruby_operator_overloading>`__.

C++ namespaces
~~~~~~~~~~~~~~~~~~~~~~

SWIG is aware of C++ namespaces, but namespace names do not appear in
the module nor do namespaces result in a module that is broken up into
submodules or packages. For example, if you have a file like this,

.. container:: code

   ::

      %module example

      namespace foo {
        int fact(int n);
        struct Vector {
          double x, y, z;
        };
      };

it works in Ruby as follows:

.. container:: code targetlang

   ::

      irb(main):001:0> require 'example'
      true
      irb(main):002:0> Example.fact(3)
      6
      irb(main):003:0> v = Example::Vector.new
      #<Example::Vector:0x4016f4d4>
      irb(main):004:0> v.x = 3.4
      3.4
      irb(main):004:0> v.y
      0.0

If your program has more than one namespace, name conflicts (if any) can
be resolved using ``%rename`` For example:

.. container:: code

   ::

      %rename(Bar_spam) Bar::spam;

      namespace Foo {
        int spam();
      }

      namespace Bar {
        int spam();
      }

If you have more than one namespace and your want to keep their symbols
separate, consider wrapping them as separate SWIG modules. For example,
make the module name the same as the namespace and create extension
modules for each namespace separately. If your program utilizes
thousands of small deeply nested namespaces each with identical symbol
names, well, then you get what you deserve.

C++ templates
~~~~~~~~~~~~~~~~~~~~~

C++ templates don't present a huge problem for SWIG. However, in order
to create wrappers, you have to tell SWIG to create wrappers for a
particular template instantiation. To do this, you use the ``%template``
directive. For example:

.. container:: code

   ::

      %module example

      %{
      #include "pair.h"
      %}

      template<class T1, class T2>
      struct pair {
        typedef T1 first_type;
        typedef T2 second_type;
        T1 first;
        T2 second;
        pair();
        pair(const T1&, const T2&);
        ~pair();
      };

      %template(Pairii) pair<int, int>;

In Ruby:

.. container:: code targetlang

   ::

      irb(main):001:0> require 'example'
      true
      irb(main):002:0> p = Example::Pairii.new(3, 4)
      #<Example:Pairii:0x4016f4df>
      irb(main):003:0> p.first
      3
      irb(main):004:0> p.second
      4

C++ Standard Template Library (STL)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On a related note, the standard SWIG library contains a number of
modules that provide typemaps for standard C++ library classes (such as
``std::pair``, ``std::string`` and ``std::vector``). These library
modules don't provide wrappers around the templates themselves, but they
do make it convenient for users of your extension module to pass Ruby
objects (such as arrays and strings) to wrapped C++ code that expects
instances of standard C++ templates. For example, suppose the C++
library you're wrapping has a function that expects a vector of floats:

.. container:: code

   ::

      %module example

      float sum(const std::vector<float>& values);

Rather than go through the hassle of writing an "in" typemap to convert
an array of Ruby numbers into a std::vector<float>, you can just use the
``std_vector.i`` module from the standard SWIG library:

.. container:: code

   ::

      %module example

      %include std_vector.i
      float sum(const std::vector<float>& values);

Ruby's STL wrappings provide additional methods to make them behave more
similarly to Ruby's native classes.

Thus, you can do, for example:

.. container:: targetlang

   ::

      v = IntVector.new
      v << 2
      v << 3
      v << 4
      v.each { |x| puts x }

      => 2
      3
      4
      v.delete_if { |x| x == 3 }
      => [2, 4]

The SWIG Ruby module provides also the ability for all the STL
containers to carry around Ruby native objects (Fixnum, Classes, etc)
making them act almost like Ruby's own Array, Hash, etc. To do that, you
need to define a container that contains a swig::GC_VALUE, like:

.. container:: code

   ::

      %module nativevector

      %{
      std::vector< swig::GC_VALUE > NativeVector;
      %}

      %template(NativeVector) std::vector< swig::GC_VALUE >;

This vector can then contain any Ruby object, making them almost
identical to Ruby's own Array class.

.. container:: targetlang

   ::

      require 'nativevector'
      include NativeVector

      v = NativeVector.new
      v << 1
      v << [1, 2]
      v << 'hello'

      class A; end

      v << A.new

      puts v
      => [1, [1, 2], 'hello', #<A:0x245325>]

Obviously, there is a lot more to template wrapping than shown in these
examples. More details can be found in the `SWIG and
C++ <SWIGPlus.html#SWIGPlus>`__ chapter.

C++ STL Functors
~~~~~~~~~~~~~~~~~~~~~~~~

Some containers in the STL allow you to modify their default behavior by
using so called functors or function objects. Functors are often just a
very simple struct with ``operator()`` redefined or an actual C/C++
function. This allows you, for example, to always keep the sort order of
a STL container to your liking.

The Ruby STL mappings allows you to modify those containers that support
functors using Ruby procs or methods, instead. Currently, this includes
``std::set``, ``set::map``, ``std::multiset`` and ``std::multimap``.

The functors in swig are called ``swig::UnaryFunction`` and
``swig::BinaryFunction``. For C++ predicates (ie. functors that must
return bool as a result) ``swig::UnaryPredicate`` and
``swig::BinaryPredicate`` are provided.

As an example, if given this swig file:

.. container:: code

   ::

      %module intset;

      %include <std_set.i>

      %template(IntSet) std::set< int, swig::BinaryPredicate >;

You can then use the set from Ruby with or without a proc object as a
predicate:

.. container:: targetlang

   ::

      require 'intset'
      include Intset

      # Default sorting behavior defined in C++
      a = IntSet.new
      a << 1
      a << 2
      a << 3
      a
      => [1, 2, 3]

      # Custom sorting behavior defined by a Ruby proc
      b = IntSet.new( proc { |a, b| a > b } )
      b << 1
      b << 2
      b << 3
      b
      =>  [3, 2, 1]

C++ STL Iterators
~~~~~~~~~~~~~~~~~~~~~~~~~

The STL is well known for the use of iterators. There are a number of
iterators possible with different properties, but in general there are
two main categories: const iterators and non-const iterators. The const
iterators can access and not modify the values they point at, while the
non-const iterators can both read and modify the values.

The Ruby STL wrappings support both type of iterators by using a proxy
class in-between. This proxy class is ``swig::Iterator`` or
``swig::ConstIterator``. Derived from them are template classes that
need to be initialized with the actual iterator for the container you
are wrapping and often times with the beginning and ending points of the
iteration range.

The SWIG STL library already provides typemaps to all the standard
containers to do this wrapping automatically for you, but if you have
your own STL-like iterator, you will need to write your own typemap for
them. For out typemaps, the special functions ``make_const_iterator``
and ``make_nonconst_iterator`` are provided.

These can be used either like:

.. container:: code

   ::

      make_const_iterator( iterator, rubyclass );
      make_const_iterator( iterator, iterator_begin, iterator_end, rubyclass );

The iterators support a ``next()`` and ``previous()`` member function to
just change the iterator without returning anything. ``previous()``
should obviously only be used for bidirectional iterators. You can also
advance the iterator multiple steps by using standard math operations
like ``+=``.

The value the iterator points at can be accessed with ``value()`` --
this is equivalent to dereferencing it with ``*i``. For non-const
iterators, a ``value=()`` function is also provided which allows you to
change the value pointed by the iterator. This is equivalent to the C++
construct of dereferencing and assignment, like ``*i = something``.

Thus, given say a vector class of doubles defined as:

.. container:: code

   ::

      %module doublevector

      %include std_vector.i

      %template(DoubleVector) std::vector<double>;

Its iterator can then be used from Ruby like:

.. container:: targetlang

   ::

      require 'doublevector'
      include Doublevector

      v = DoubleVector.new
      v << 1
      v << 2
      v << 3

      #
      # an elaborate and less efficient way of doing v.map! { |x| x+2 }
      #
      i = v.begin
      e = v.end
      while i != e
        val = i.value
        val += 2
        i.value = val
        i.next
      end
      i
      >> [3, 4, 5 ]

If you'd rather have STL classes without any iterators, you should
define ``-DSWIG_NO_EXPORT_ITERATOR_METHODS`` when running swig.

C++ Smart Pointers
~~~~~~~~~~~~~~~~~~~~~~~~~~

The shared_ptr Smart Pointer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The C++11 standard provides ``std::shared_ptr`` which was derived from
the Boost implementation, ``boost::shared_ptr``. Both of these are
available for Ruby in the SWIG library and usage is outlined in the
`shared_ptr smart pointer <Library.html#Library_std_shared_ptr>`__
library section.

Generic Smart Pointers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In certain C++ programs, it is common to use classes that have been
wrapped by so-called "smart pointers." Generally, this involves the use
of a template class that implements ``operator->()`` like this:

.. container:: code

   ::

      template<class T> class SmartPtr {
        ...
        T *operator->();
        ...
      }

Then, if you have a class like this,

.. container:: code

   ::

      class Foo {
      public:
        int x;
        int bar();
      };

A smart pointer would be used in C++ as follows:

.. container:: code

   ::

      SmartPtr<Foo> p = CreateFoo(); // Created somehow (not shown)
      ...
      p->x = 3; // Foo::x
      int y = p->bar(); // Foo::bar

To wrap this in Ruby, simply tell SWIG about the ``SmartPtr`` class and
the low-level ``Foo`` object. Make sure you instantiate ``SmartPtr``
using ``%template`` if necessary. For example:

.. container:: code

   ::

      %module example
      ...
      %template(SmartPtrFoo) SmartPtr<Foo>;
      ...

Now, in Ruby, everything should just "work":

.. container:: code targetlang

   ::

      irb(main):001:0> p = Example::CreateFoo() # Create a smart-pointer somehow
      #<Example::SmartPtrFoo:0x4016f4df>
      irb(main):002:0> p.x = 3 # Foo::x
      3
      irb(main):003:0> p.bar() # Foo::bar

If you ever need to access the underlying pointer returned by
``operator->()`` itself, simply use the ``__deref__()`` method. For
example:

.. container:: code targetlang

   ::

      irb(main):004:0> f = p.__deref__() # Returns underlying Foo *

Cross-Language Polymorphism
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG's Ruby module supports cross-language polymorphism (a.k.a. the
"directors" feature) similar to that for SWIG's Python module. Rather
than duplicate the information presented in the
`Python <Python.html#Python>`__ chapter, this section just notes the
differences that you need to be aware of when using this feature with
Ruby.

Exception Unrolling
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Whenever a C++ director class routes one of its virtual member function
calls to a Ruby instance method, there's always the possibility that an
exception will be raised in the Ruby code. By default, those exceptions
are ignored, which simply means that the exception will be exposed to
the Ruby interpreter. If you would like to change this behavior, you can
use the ``%feature("director:except")`` directive to indicate what
action should be taken when a Ruby exception is raised. The following
code should suffice in most cases:

.. container:: code

   ::

      %feature("director:except") {
        throw Swig::DirectorMethodException($error);
      }

When this feature is activated, the call to the Ruby instance method is
"wrapped" using the ``rb_rescue2()`` function from Ruby's C API. If any
Ruby exception is raised, it will be caught here and a C++ exception is
raised in its place.

Naming
-----------

Ruby has several common naming conventions. Constants are generally in
upper case, module and class names are in camel case and methods are in
lower case with underscores. For example:

.. container:: code

   -  **MATH::PI** is a constant name
   -  **MyClass** is a class name
   -  **my_method** is a method name

Prior to version 1.3.28, SWIG did not support these Ruby conventions.
The only modifications it made to names was to capitalize the first
letter of constants (which includes module and class names).

SWIG 1.3.28 introduces the new -autorename command line parameter. When
this parameter is specified, SWIG will automatically change constant,
class and method names to conform with the standard Ruby naming
conventions. For example:

.. container:: code shell

   ::

      $ swig -ruby -autorename example.i

To disable renaming use the -noautorename command line option.

Since this change significantly changes the wrapper code generated by
SWIG, it is turned off by default in SWIG 1.3.28. However, it is planned
to become the default option in future releases.

Defining Aliases
~~~~~~~~~~~~~~~~~~~~~~~

It's a fairly common practice in the Ruby built-ins and standard library
to provide aliases for method names. For example, *Array#size* is an
alias for *Array#length*. If you would like to provide an alias for one
of your class' instance methods, one approach is to use SWIG's
``%extend`` directive to add a new method of the aliased name that calls
the original function. For example:

.. container:: code

   ::

      class MyArray {
      public:
        // Construct an empty array
        MyArray();

        // Return the size of this array
        size_t length() const;
      };

      %extend MyArray {
        // MyArray#size is an alias for MyArray#length
        size_t size() const {
          return $self->length();
        }
      }
       

A better solution is to use the ``%alias`` directive (unique to SWIG's
Ruby module). The previous example could then be rewritten as:

.. container:: code

   ::

      // MyArray#size is an alias for MyArray#length
      %alias MyArray::length "size";

      class MyArray {
      public:
        // Construct an empty array
        MyArray();
       
        // Return the size of this array
        size_t length() const;
      };

Multiple aliases can be associated with a method by providing a
comma-separated list of aliases to the ``%alias`` directive, e.g.

.. container:: code

   ::

      %alias MyArray::length "amount, quantity, size";

From an end-user's standpoint, there's no functional difference between
these two approaches; i.e. they should get the same result from calling
either *MyArray#size* or *MyArray#length*. However, when the ``%alias``
directive is used, SWIG doesn't need to generate all of the wrapper code
that's usually associated with added methods like our *MyArray::size()*
example.

Note that the ``%alias`` directive is implemented using SWIG's
"features" mechanism and so the same name matching rules used for other
kinds of features apply (see the chapter on `"Customization
Features" <Customization.html#Customization>`__) for more details).

Predicate Methods
~~~~~~~~~~~~~~~~~~~~~~~~

Ruby methods that return a boolean value and end in a question mark are
known as predicate methods. Examples of predicate methods in standard
Ruby classes include *Array#empty?* (which returns ``true`` for an array
containing no elements) and *Object#instance_of?* (which returns
``true`` if the object is an instance of the specified class). For
consistency with Ruby conventions, methods that return boolean values
should be marked as predicate methods.

One cumbersome solution to this problem is to rename the method (using
SWIG's ``%rename`` directive) and provide a custom typemap that converts
the function's actual return type to Ruby's ``true`` or ``false``. For
example:

.. container:: code

   ::

      %rename("is_it_safe?") is_it_safe();

      %typemap(out) int is_it_safe "$result = ($1 != 0) ? Qtrue : Qfalse;";

      int is_it_safe();

A better solution is to use the ``%predicate`` directive (unique to
SWIG's Ruby module) to designate a method as a predicate method. For the
previous example, this would look like:

.. container:: code

   ::

      %predicate is_it_safe();

      int is_it_safe();

This method would be invoked from Ruby code like this:

.. container:: code targetlang

   ::

      irb(main):001:0> Example::is_it_safe?
      true

The ``%predicate`` directive is implemented using SWIG's "features"
mechanism and so the same name matching rules used for other kinds of
features apply (see the chapter on `"Customization
Features" <Customization.html#Customization>`__) for more details).

Bang Methods
~~~~~~~~~~~~~~~~~~~

Ruby methods that modify an object in-place and end in an exclamation
mark are known as bang methods. An example of a bang method is
*Array#sort!* which changes the ordering of items in an array. Contrast
this with *Array#sort*, which returns a copy of the array with the items
sorted instead of modifying the original array. For consistency with
Ruby conventions, methods that modify objects in place should be marked
as bang methods.

Bang methods can be marked using the ``%bang`` directive which is unique
to the Ruby module and was introduced in SWIG 1.3.28. For example:

.. container:: code

   ::

      %bang sort(int arr[]);

      int sort(int arr[]); 

This method would be invoked from Ruby code like this:

.. container:: code

   ::

      irb(main):001:0> Example::sort!(arr)

The ``%bang`` directive is implemented using SWIG's "features" mechanism
and so the same name matching rules used for other kinds of features
apply (see the chapter on `"Customization
Features" <Customization.html#Customization>`__) for more details).

Getters and Setters
~~~~~~~~~~~~~~~~~~~~~~~~~~

Often times a C++ library will expose properties through getter and
setter methods. For example:

.. container:: code

   ::

      class Foo {
        Foo() {}
        int getValue() { return value_; }
        void setValue(int value) { value_ = value; }

      private:
        int value_;
      };

By default, SWIG will expose these methods to Ruby as ``get_value`` and
``set_value.`` However, it more natural for these methods to be exposed
in Ruby as ``value`` and ``value=.`` That allows the methods to be used
like this:

.. container:: code

   ::

      irb(main):001:0> foo = Foo.new()
      irb(main):002:0> foo.value = 5
      irb(main):003:0> puts foo.value

This can be done by using the %rename directive:

.. container:: code

   ::

      %rename("value") Foo::getValue();
      %rename("value=") Foo::setValue(int value);

Input and output parameters
--------------------------------

A common problem in some C programs is handling parameters passed as
simple pointers. For example:

.. container:: code

   ::

      void add(int x, int y, int *result) {
        *result = x + y;
      }

or

.. container:: code

   ::

      int sub(int *x, int *y) {
        return *x-*y;
      }

The easiest way to handle these situations is to use the ``typemaps.i``
file. For example:

.. container:: code

   ::

      %module Example
      %include "typemaps.i"

      void add(int, int, int *OUTPUT);
      int sub(int *INPUT, int *INPUT);

In Ruby, this allows you to pass simple values. For example:

.. container:: code targetlang

   ::

      a = Example.add(3, 4)
      puts a
      7
      b = Example.sub(7, 4)
      puts b
      3

Notice how the ``INPUT`` parameters allow integer values to be passed
instead of pointers and how the ``OUTPUT`` parameter creates a return
result.

If you don't want to use the names ``INPUT`` or ``OUTPUT``, use the
``%apply`` directive. For example:

.. container:: code

   ::

      %module Example
      %include "typemaps.i"

      %apply int *OUTPUT { int *result };
      %apply int *INPUT { int *x, int *y};

      void add(int x, int y, int *result);
      int sub(int *x, int *y);

If a function mutates one of its parameters like this,

.. container:: code

   ::

      void negate(int *x) {
       *x = -(*x);
      }

you can use ``INOUT`` like this:

.. container:: code

   ::

      %include "typemaps.i"
      ...
      void negate(int *INOUT);

In Ruby, a mutated parameter shows up as a return value. For example:

.. container:: code targetlang

   ::

      a = Example.negate(3)
      print a
      -3

The most common use of these special typemap rules is to handle
functions that return more than one value. For example, sometimes a
function returns a result as well as a special error code:

.. container:: code

   ::

      /* send message, return number of bytes sent, success code, and error_code */
      int send_message(char *text, int *success, int *error_code);

To wrap such a function, simply use the ``OUTPUT`` rule above. For
example:

.. container:: code

   ::

      %module example
      %include "typemaps.i"
      ...
      int send_message(char *, int *OUTPUT, int *OUTPUT);

When used in Ruby, the function will return an array of multiple values.

.. container:: code targetlang

   ::

      bytes, success, error_code = send_message("Hello World")
      if not success
        print "error #{error_code} : in send_message"
      else
        print "Sent", bytes
      end

Another way to access multiple return values is to use the ``%apply``
rule. In the following example, the parameters rows and columns are
related to SWIG as ``OUTPUT`` values through the use of ``%apply``

.. container:: code

   ::

      %module Example
      %include "typemaps.i"
      %apply int *OUTPUT { int *rows, int *columns };
      ...
      void get_dimensions(Matrix *m, int *rows, int*columns);

In Ruby:

.. container:: code targetlang

   ::

      r, c = Example.get_dimensions(m)

Exception handling
-----------------------

Using the %exception directive
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The SWIG ``%exception`` directive can be used to define a user-definable
exception handler that can convert C/C++ errors into Ruby exceptions.
The chapter on `Customization
Features <Customization.html#Customization>`__ contains more details,
but suppose you have a C++ class like the following :

.. container:: code

   ::

      class DoubleArray {
      private:
        int n;
        double *ptr;
      public:
        // Create a new array of fixed size
        DoubleArray(int size) {
          ptr = new double[size];
          n = size;
        }
       
        // Destroy an array
        ~DoubleArray() {
          delete ptr;
        } 
       
        // Return the length of the array
        int length() {
          return n;
        }
       
        // Get an array item and perform bounds checking.
        double getitem(int i) {
          if ((i >= 0) && (i < n))
            return ptr[i];
          else
            throw RangeError();
        }
       
        // Set an array item and perform bounds checking.
        void setitem(int i, double val) {
          if ((i >= 0) && (i < n))
            ptr[i] = val;
          else {
            throw RangeError();
          }
        }
      };

Since several methods in this class can throw an exception for an
out-of-bounds access, you might want to catch this in the Ruby extension
by writing the following in an interface file:

.. container:: code

   ::

      %exception {
        try {
          $action
        }
        catch (const RangeError&) {
          static VALUE cpperror = rb_define_class("CPPError", rb_eStandardError);
          rb_raise(cpperror, "Range error.");
        }
      }

      class DoubleArray {
        ...
      };

The exception handling code is inserted directly into generated wrapper
functions. When an exception handler is defined, errors can be caught
and used to gracefully raise a Ruby exception instead of forcing the
entire program to terminate with an uncaught error.

As shown, the exception handling code will be added to every wrapper
function. Because this is somewhat inefficient, you might consider
refining the exception handler to only apply to specific methods like
this:

.. container:: code

   ::

      %exception getitem {
        try {
          $action
        } catch (const RangeError&) {
          static VALUE cpperror = rb_define_class("CPPError", rb_eStandardError);
          rb_raise(cpperror, "Range error in getitem.");
        }
      }
       
      %exception setitem {
        try {
          $action
        } catch (const RangeError&) {
          static VALUE cpperror = rb_define_class("CPPError", rb_eStandardError);
          rb_raise(cpperror, "Range error in setitem.");
        }
      }

In this case, the exception handler is only attached to methods and
functions named ``getitem`` and ``setitem``.

Since SWIG's exception handling is user-definable, you are not limited
to C++ exception handling. See the chapter on `Customization
Features <Customization.html#Customization>`__ for more examples.

Handling Ruby Blocks
~~~~~~~~~~~~~~~~~~~~~~~~~~~

One of the highlights of Ruby and most of its standard library is the
use of blocks, which allow the easy creation of continuations and other
niceties. Blocks in ruby are also often used to simplify the passing of
many arguments to a class.

In order to make your class constructor support blocks, you can take
advantage of the %exception directive, which will get run after the C++
class' constructor was called.

For example, this yields the class over after its construction:

.. container:: code

   ::

      class Window
      {
      public:
        Window(int x, int y, int w, int h);
        // .... other methods here ....
      };

      // Add support for yielding self in the Class' constructor.
      %exception Window::Window {
        $action
        if (rb_block_given_p()) {
          rb_yield(self);
        }
      }

Then, in ruby, it can be used like:

.. container:: targetlang

   ::

      Window.new(0, 0, 360, 480) { |w|
        w.color = Fltk::RED
        w.border = false
      }

For other methods, you can usually use a dummy parameter with a special
in typemap, like:

.. container:: code

   ::

      //
      // original function was:
      //
      // void func(int x);

      %typemap(in, numinputs=0) int RUBY_YIELD_SELF {
        if ( !rb_block_given_p() )
          rb_raise("No block given");
        return rb_yield(self);
      }

      %extend {
        void func(int x, int RUBY_YIELD_SELF );
      }

For more information on typemaps, see `Typemaps <#Ruby_nn37>`__.

Raising exceptions
~~~~~~~~~~~~~~~~~~~~~~~~~

There are three ways to raise exceptions from C++ code to Ruby.

The first way is to use ``SWIG_exception(int code, const char *msg)``.
The following table shows the mappings from SWIG error codes to Ruby
exceptions:

.. container:: diagram

   .. container::

      SWIG_MemoryError

.. container::

   rb_eNoMemError

.. container::

   SWIG_IOError

.. container::

   rb_eIOError

.. container::

   SWIG_RuntimeError

.. container::

   rb_eRuntimeError

.. container::

   SWIG_IndexError

.. container::

   rb_eIndexError

.. container::

   SWIG_TypeError

.. container::

   rb_eTypeError

.. container::

   SWIG_DivisionByZero

.. container::

   rb_eZeroDivError

.. container::

   SWIG_OverflowError

.. container::

   rb_eRangeError

.. container::

   SWIG_SyntaxError

.. container::

   rb_eSyntaxError

.. container::

   SWIG_ValueError

.. container::

   rb_eArgError

.. container::

   SWIG_SystemError

.. container::

   rb_eFatal

.. container::

   SWIG_AttributeError

.. container::

   rb_eRuntimeError

.. container::

   SWIG_NullReferenceError

.. container::

   rb_eNullReferenceError\*

.. container::

   SWIG_ObjectPreviouslyDeletedError

.. container::

   rb_eObjectPreviouslyDeleted\*

.. container::

   SWIG_UnknownError

.. container::

   rb_eRuntimeError

.. container::

   \* These error classes are created by SWIG and are not built-in Ruby
   exception classes

The second way to raise errors is to use
``SWIG_Raise(obj, type, desc)``. Obj is a C++ instance of an exception
class, type is a string specifying the type of exception (for example,
"MyError") and desc is the SWIG description of the exception class. For
example:

.. container:: code

   ::

      %raise(SWIG_NewPointerObj(e, SWIGTYPE_p_AssertionFailedException, 0), ":AssertionFailedException", SWIGTYPE_p_AssertionFailedException);

This is useful when you want to pass the current exception object
directly to Ruby, particularly when the object is an instance of class
marked as an ``%exceptionclass`` (see the next section for more
information).

Last, you can raise an exception by directly calling Ruby's C api. This
is done by invoking the ``rb_raise()`` function. The first argument
passed to ``rb_raise()`` is the exception type. You can raise a custom
exception type or one of the built-in Ruby exception types.

Exception classes
~~~~~~~~~~~~~~~~~~~~~~~~

Starting with SWIG 1.3.28, the Ruby module supports the
``%exceptionclass`` directive, which is used to identify C++ classes
that are used as exceptions. Classes that are marked with the
``%exceptionclass`` directive are exposed in Ruby as child classes of
``rb_eRuntimeError``. This allows C++ exceptions to be directly mapped
to Ruby exceptions, providing for a more natural integration between C++
code and Ruby code.

.. container:: code

   ::

      %exceptionclass CustomError;

      %inline %{
        class CustomError { };

        class Foo { 
        public:
          void test() { throw CustomError; }
        };
      %}

From Ruby you can now call this method like this:

.. container:: code targetlang

   ::

      foo = Foo.new
      begin
        foo.test()
      rescue CustomError => e
        puts "Caught custom error"
      end 

For another example look at swig/Examples/ruby/exception_class.

Typemaps
-------------

This section describes how you can modify SWIG's default wrapping
behavior for various C/C++ datatypes using the ``%typemap`` directive.
This is an advanced topic that assumes familiarity with the Ruby C API
as well as the material in the "`Typemaps <Typemaps.html#Typemaps>`__"
chapter.

Before proceeding, it should be stressed that typemaps are not a
required part of using SWIG---the default wrapping behavior is enough in
most cases. Typemaps are only used if you want to change some aspect of
the primitive C-Ruby interface.

What is a typemap?
~~~~~~~~~~~~~~~~~~~~~~~~~

A typemap is nothing more than a code generation rule that is attached
to a specific C datatype. The general form of this declaration is as
follows ( parts enclosed in [...] are optional ):

.. container:: code

   ::

      %typemap( method [, modifiers...] ) typelist code;

*method* is a simply a name that specifies what kind of typemap is being
defined. It is usually a name like ``"in"``, ``"out"``, or ``"argout"``
(or its director variations). The purpose of these methods is described
later.

*modifiers* is an optional comma separated list of ``name="value"``
values. These are sometimes to attach extra information to a typemap and
is often target-language dependent.

*typelist* is a list of the C++ type patterns that the typemap will
match. The general form of this list is as follows:

.. container:: diagram

   ::

      typelist : typepattern [, typepattern, typepattern, ... ] ;

      typepattern : type [ (parms) ]
        | type name [ (parms) ]
        | ( typelist ) [ (parms) ]

Each type pattern is either a simple type, a simple type and argument
name, or a list of types in the case of multi-argument typemaps. In
addition, each type pattern can be parameterized with a list of
temporary variables (parms). The purpose of these variables will be
explained shortly.

*code* specifies the C code used in the typemap. It can take any one of
the following forms:

.. container:: diagram

   ::

      code : { ... }
        | " ... "
        | %{ ... %}

For example, to convert integers from Ruby to C, you might define a
typemap like this:

.. container:: code

   ::

      %module example

      %typemap(in) int {
        $1 = (int) NUM2INT($input);
        printf("Received an integer : %d\n", $1);
      }

      %inline %{
        extern int fact(int n);
      %}

Typemaps are always associated with some specific aspect of code
generation. In this case, the "in" method refers to the conversion of
input arguments to C/C++. The datatype ``int`` is the datatype to which
the typemap will be applied. The supplied C code is used to convert
values. In this code a number of special variables prefaced by a ``$``
are used. The ``$1`` variable is placeholder for a local variable of
type ``int``. The ``$input`` variable is the input Ruby object.

When this example is compiled into a Ruby module, the following sample
code:

.. container:: code targetlang

   ::

      require 'example'

      puts Example.fact(6)

prints the result:

.. container:: code shell

   ::

      Received an integer : 6
      720

In this example, the typemap is applied to all occurrences of the
``int`` datatype. You can refine this by supplying an optional parameter
name. For example:

.. container:: code

   ::

      %module example

      %typemap(in) int n {
        $1 = (int) NUM2INT($input);
        printf("n = %d\n", $1);
      }

      %inline %{
        extern int fact(int n);
      %}

In this case, the typemap code is only attached to arguments that
exactly match "``int n``".

The application of a typemap to specific datatypes and argument names
involves more than simple text-matching--typemaps are fully integrated
into the SWIG type-system. When you define a typemap for ``int``, that
typemap applies to ``int`` and qualified variations such as
``const int``. In addition, the typemap system follows ``typedef``
declarations. For example:

.. container:: code

   ::

      %typemap(in) int n {
        $1 = (int) NUM2INT($input);
        printf("n = %d\n", $1);
      }

      typedef int Integer;
      extern int fact(Integer n); // Above typemap is applied

However, the matching of ``typedef`` only occurs in one direction. If
you defined a typemap for ``Integer``, it is not applied to arguments of
type ``int``.

Typemaps can also be defined for groups of consecutive arguments. For
example:

.. container:: code

   ::

      %typemap(in) (char *str, int len) {
        $1 = StringValuePtr($input);
        $2 = (int) RSTRING($input)->len;
      };

      int count(char c, char *str, int len);

When a multi-argument typemap is defined, the arguments are always
handled as a single Ruby object. This allows the function ``count`` to
be used as follows (notice how the length parameter is omitted):

.. container:: code targetlang

   ::

      puts Example.count('o', 'Hello World')
      2

Typemap scope
~~~~~~~~~~~~~~~~~~~~

Once defined, a typemap remains in effect for all of the declarations
that follow. A typemap may be redefined for different sections of an
input file. For example:

.. container:: code

   ::

      // typemap1
      %typemap(in) int {
        ...
      }

      int fact(int); // typemap1
      int gcd(int x, int y); // typemap1

      // typemap2
      %typemap(in) int {
        ...
      }

      int isprime(int); // typemap2

One exception to the typemap scoping rules pertains to the ``%extend``
declaration. ``%extend`` is used to attach new declarations to a class
or structure definition. Because of this, all of the declarations in an
``%extend`` block are subject to the typemap rules that are in effect at
the point where the class itself is defined. For example:

.. container:: code

   ::

      class Foo {
        ...
      };

      %typemap(in) int {
        ...
      }

      %extend Foo {
        int blah(int x); // typemap has no effect. Declaration is attached to Foo which 
        // appears before the %typemap declaration.
      };

Copying a typemap
~~~~~~~~~~~~~~~~~~~~~~~~

A typemap is copied by using assignment. For example:

.. container:: code

   ::

      %typemap(in) Integer = int;

or this:

.. container:: code

   ::

      %typemap(in) Integer, Number, int32_t = int;

Types are often managed by a collection of different typemaps. For
example:

.. container:: code

   ::

      %typemap(in) int { ... }
      %typemap(out) int { ... }
      %typemap(varin) int { ... }
      %typemap(varout) int { ... }

To copy all of these typemaps to a new type, use ``%apply``. For
example:

.. container:: code

   ::

      %apply int { Integer }; // Copy all int typemaps to Integer
      %apply int { Integer, Number }; // Copy all int typemaps to both Integer and Number

The patterns for ``%apply`` follow the same rules as for ``%typemap``.
For example:

.. container:: code

   ::

      %apply int *output { Integer *output }; // Typemap with name
      %apply (char *buf, int len) { (char *buffer, int size) }; // Multiple arguments

Deleting a typemap
~~~~~~~~~~~~~~~~~~~~~~~~~

A typemap can be deleted by simply defining no code. For example:

.. container:: code

   ::

      %typemap(in) int; // Clears typemap for int
      %typemap(in) int, long, short; // Clears typemap for int, long, short
      %typemap(in) int *output; 

The ``%clear`` directive clears all typemaps for a given type. For
example:

.. container:: code

   ::

      %clear int; // Removes all types for int
      %clear int *output, long *output;

**Note:** Since SWIG's default behavior is defined by typemaps, clearing
a fundamental type like ``int`` will make that type unusable unless you
also define a new set of typemaps immediately after the clear operation.

Placement of typemaps
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Typemap declarations can be declared in the global scope, within a C++
namespace, and within a C++ class. For example:

.. container:: code

   ::

      %typemap(in) int {
        ...
      }

      namespace std {
        class string;
        %typemap(in) string {
          ...
        }
      }

      class Bar {
      public:
        typedef const int & const_reference;
        %typemap(out) const_reference {
          ...
        }
      };

When a typemap appears inside a namespace or class, it stays in effect
until the end of the SWIG input (just like before). However, the typemap
takes the local scope into account. Therefore, this code

.. container:: code

   ::

      namespace std {
        class string;
        %typemap(in) string {
          ...
        }
      }

is really defining a typemap for the type ``std::string``. You could
have code like this:

.. container:: code

   ::

      namespace std {
        class string;
        %typemap(in) string { /* std::string */
        ...
        }
      }

      namespace Foo {
        class string;
        %typemap(in) string { /* Foo::string */
        ...
        }
      }

In this case, there are two completely distinct typemaps that apply to
two completely different types (``std::string`` and ``Foo::string``).

It should be noted that for scoping to work, SWIG has to know that
``string`` is a typename defined within a particular namespace. In this
example, this is done using the class declaration ``class string`` .

Ruby typemaps
~~~~~~~~~~~~~~~~~~~~

The following list details all of the typemap methods that can be used
by the Ruby module:

"in" typemap
^^^^^^^^^^^^^^^^^^^^^

Converts Ruby objects to input function arguments. For example:

.. container:: code

   ::

      %typemap(in) int {
        $1 = NUM2INT($input);
      }

The following special variables are available:

.. container:: diagram

   +----------+------------------------------------------------------------------+
   | $input   | Input object holding value to be converted.                      |
   +----------+------------------------------------------------------------------+
   | $symname | Name of function/method being wrapped                            |
   +----------+------------------------------------------------------------------+
   | $1...n   | Argument being sent to the function                              |
   +----------+------------------------------------------------------------------+
   | $1_name  | Name of the argument (if provided)                               |
   +----------+------------------------------------------------------------------+
   | $1_type  | The actual C datatype matched by the typemap.                    |
   +----------+------------------------------------------------------------------+
   | $1_ltype | The assignable version of the C datatype matched by the typemap. |
   +----------+------------------------------------------------------------------+

This is probably the most commonly redefined typemap because it can be
used to implement customized conversions.

In addition, the "in" typemap allows the number of converted arguments
to be specified. For example:

.. container:: code

   ::

      // Ignored argument.
      %typemap(in, numinputs=0) int *out (int temp) {
        $1 = &temp;
      }

At this time, only zero or one arguments may be converted.

"typecheck" typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The "typecheck" typemap is used to support overloaded functions and
methods. It merely checks an argument to see whether or not it matches a
specific type. For example:

.. container:: code

   ::

      %typemap(typecheck, precedence=SWIG_TYPECHECK_INTEGER) int {
        $1 = FIXNUM_P($input) ? 1 : 0;
      }

For typechecking, the $1 variable is always a simple integer that is set
to 1 or 0 depending on whether or not the input argument is the correct
type.

If you define new "in" typemaps *and* your program uses overloaded
methods, you should also define a collection of "typecheck" typemaps.
More details about this follow in a later section on "Typemaps and
Overloading."

"out" typemap
^^^^^^^^^^^^^^^^^^^^^^

Converts return value of a C function to a Ruby object.

.. container:: code

   ::

      %typemap(out) int {
        $result = INT2NUM( $1 );
      }

The following special variables are available.

.. container:: diagram

   +----------+------------------------------------------------------------------+
   | $result  | Result object returned to target language.                       |
   +----------+------------------------------------------------------------------+
   | $symname | Name of function/method being wrapped                            |
   +----------+------------------------------------------------------------------+
   | $1...n   | Argument being wrapped                                           |
   +----------+------------------------------------------------------------------+
   | $1_name  | Name of the argument (if provided)                               |
   +----------+------------------------------------------------------------------+
   | $1_type  | The actual C datatype matched by the typemap.                    |
   +----------+------------------------------------------------------------------+
   | $1_ltype | The assignable version of the C datatype matched by the typemap. |
   +----------+------------------------------------------------------------------+

"arginit" typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^

The "arginit" typemap is used to set the initial value of a function
argument--before any conversion has occurred. This is not normally
necessary, but might be useful in highly specialized applications. For
example:

.. container:: code

   ::

      // Set argument to NULL before any conversion occurs
      %typemap(arginit) int *data {
        $1 = NULL;
      }

"default" typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^

The "default" typemap is used to turn an argument into a default
argument. For example:

.. container:: code

   ::

      %typemap(default) int flags {
        $1 = DEFAULT_FLAGS;
      }
      ...
      int foo(int x, int y, int flags);

The primary use of this typemap is to either change the wrapping of
default arguments or specify a default argument in a language where they
aren't supported (like C). Target languages that do not support optional
arguments, such as Java and C#, effectively ignore the value specified
by this typemap as all arguments must be given.

Once a default typemap has been applied to an argument, all arguments
that follow must have default values. See the `Default/optional
arguments <SWIG.html#SWIG_default_args>`__ section for further
information on default argument wrapping.

"check" typemap
^^^^^^^^^^^^^^^^^^^^^^^^

The "check" typemap is used to supply value checking code during
argument conversion. The typemap is applied *after* arguments have been
converted. For example:

.. container:: code

   ::

      %typemap(check) int positive {
        if ($1 <= 0) {
          SWIG_exception(SWIG_ValueError, "Expected positive value.");
        }
      }

"argout" typemap
^^^^^^^^^^^^^^^^^^^^^^^^^

The "argout" typemap is used to return values from arguments. This is
most commonly used to write wrappers for C/C++ functions that need to
return multiple values. The "argout" typemap is almost always combined
with an "in" typemap---possibly to ignore the input value. For example:

.. container:: code

   ::

      /* Set the input argument to point to a temporary variable */
      %typemap(in, numinputs=0) int *out (int temp) {
        $1 = &temp;
      }

      %typemap(argout, fragment="output_helper") int *out {
        // Append output value $1 to $result (assuming a single integer in this case)
        $result = output_helper( $result, INT2NUM(*$1) );
      }

The following special variables are available.

.. container:: diagram

   ======== ==========================================
   $result  Result object returned to target language.
   $input   The original input object passed.
   $symname Name of function/method being wrapped.
   ======== ==========================================

The code supplied to the "argout" typemap is always placed after the
"out" typemap. If multiple return values are used, the extra return
values are often appended to return value of the function.

Output helper is a fragment that usually defines a macro to some
function like SWIG_Ruby_AppendOutput.

See the ``typemaps.i`` library for examples.

"freearg" typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^

The "freearg" typemap is used to cleanup argument data. It is only used
when an argument might have allocated resources that need to be cleaned
up when the wrapper function exits. The "freearg" typemap usually cleans
up argument resources allocated by the "in" typemap. For example:

.. container:: code

   ::

      // Get a list of integers
      %typemap(in) int *items {
        int nitems = Length($input); 
        $1 = (int *) malloc(sizeof(int)*nitems);
      }
      // Free the list 
      %typemap(freearg) int *items {
        free($1);
      }

The "freearg" typemap inserted at the end of the wrapper function, just
before control is returned back to the target language. This code is
also placed into a special variable ``$cleanup`` that may be used in
other typemaps whenever a wrapper function needs to abort prematurely.

"newfree" typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^

The "newfree" typemap is used in conjunction with the ``%newobject``
directive and is used to deallocate memory used by the return result of
a function. For example:

.. container:: code

   ::

      %typemap(newfree) string * {
        delete $1;
      }
      %typemap(out) string * {
        $result = PyString_FromString($1->c_str());
      }
      ...

      %newobject foo;
      ...
      string *foo();

See `Object ownership and
%newobject <Customization.html#Customization_ownership>`__ for further
details.

"memberin" typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The "memberin" typemap is used to copy data from *an already converted
input value* into a structure member. It is typically used to handle
array members and other special cases. For example:

.. container:: code

   ::

      %typemap(memberin) int [4] {
        memmove($1, $input, 4*sizeof(int));
      }

It is rarely necessary to write "memberin" typemaps---SWIG already
provides a default implementation for arrays, strings, and other
objects.

"varin" typemap
^^^^^^^^^^^^^^^^^^^^^^^^^

The "varin" typemap is used to convert objects in the target language to
C for the purposes of assigning to a C/C++ global variable. This is
implementation specific.

"varout" typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^

The "varout" typemap is used to convert a C/C++ object to an object in
the target language when reading a C/C++ global variable. This is
implementation specific.

"throws" typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^

The "throws" typemap is only used when SWIG parses a C++ method with an
exception specification or has the ``%catches`` feature attached to the
method. It provides a default mechanism for handling C++ methods that
have declared the exceptions they will throw. The purpose of this
typemap is to convert a C++ exception into an error or exception in the
target language. It is slightly different to the other typemaps as it is
based around the exception type rather than the type of a parameter or
variable. For example:

.. container:: code

   ::

      %typemap(throws) const char * %{
        rb_raise(rb_eRuntimeError, $1);
        SWIG_fail;
      %}
      void bar() throw (const char *);

As can be seen from the generated code below, SWIG generates an
exception handler with the catch block comprising the "throws" typemap
content.

.. container:: code

   ::

      ...
      try {
        bar();
      }
      catch(char const *_e) {
        rb_raise(rb_eRuntimeError, _e);
        SWIG_fail;
      }
      ...

Note that if your methods do not have an exception specification yet
they do throw exceptions, SWIG cannot know how to deal with them. For a
neat way to handle these, see the `Exception handling with
%exception <Customization.html#Customization_exception>`__ section.

directorin typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Converts C++ objects in director member functions to ruby objects. It is
roughly the opposite of the "in" typemap, making its typemap rule often
similar to the "out" typemap.

.. container:: code

   ::

      %typemap(directorin) int {
        $result = INT2NUM($1);
      }

The following special variables are available.

.. container:: diagram

   +----------+------------------------------------------------------------------+
   | $result  | Result object returned to target language.                       |
   +----------+------------------------------------------------------------------+
   | $symname | Name of function/method being wrapped                            |
   +----------+------------------------------------------------------------------+
   | $1...n   | Argument being wrapped                                           |
   +----------+------------------------------------------------------------------+
   | $1_name  | Name of the argument (if provided)                               |
   +----------+------------------------------------------------------------------+
   | $1_type  | The actual C datatype matched by the typemap.                    |
   +----------+------------------------------------------------------------------+
   | $1_ltype | The assignable version of the C datatype matched by the typemap. |
   +----------+------------------------------------------------------------------+
   | this     | C++ this, referring to the class itself.                         |
   +----------+------------------------------------------------------------------+

directorout typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Converts Ruby objects in director member functions to C++ objects. It is
roughly the opposite of the "out" typemap, making its rule often similar
to the "in" typemap.

.. container:: code

   ::

      %typemap(directorout) int {
        $result = NUM2INT($1);
      }

The following special variables are available:

.. container:: diagram

   +----------+------------------------------------------------------------------+
   | $input   | Ruby object being sent to the function                           |
   +----------+------------------------------------------------------------------+
   | $symname | Name of function/method being wrapped                            |
   +----------+------------------------------------------------------------------+
   | $1...n   | Argument being sent to the function                              |
   +----------+------------------------------------------------------------------+
   | $1_name  | Name of the argument (if provided)                               |
   +----------+------------------------------------------------------------------+
   | $1_type  | The actual C datatype matched by the typemap.                    |
   +----------+------------------------------------------------------------------+
   | $1_ltype | The assignable version of the C datatype matched by the typemap. |
   +----------+------------------------------------------------------------------+
   | this     | C++ this, referring to the class itself.                         |
   +----------+------------------------------------------------------------------+

Currently, the directorout nor the out typemap support the option
``numoutputs``, but the Ruby module provides that functionality through
a %feature directive. Thus, a function can be made to return "nothing"
if you do:

.. container:: code

   ::

      %feature("numoutputs", "0") MyClass::function;

This feature can be useful if a function returns a status code, which
you want to discard but still use the typemap to raise an exception.

directorargout typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Output argument processing in director member functions.

.. container:: code

   ::

      %typemap(directorargout,
      fragment="output_helper") int {
        $result = output_helper( $result, NUM2INT($1) );
      }

The following special variables are available:

.. container:: diagram

   ======== ===============================================================
   $result  Result that the director function returns
   $input   Ruby object being sent to the function
   $symname name of the function/method being wrapped
   $1...n   Argument being sent to the function
   $1_name  Name of the argument (if provided)
   $1_type  The actual C datatype matched by the typemap
   $1_ltype The assignable version of the C datatype matched by the typemap
   this     C++ this, referring to the instance of the class itself
   ======== ===============================================================

ret typemap
^^^^^^^^^^^^^^^^^^^^^

Cleanup of function return values

globalin typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^

Setting of C global variables

Typemap variables
~~~~~~~~~~~~~~~~~~~~~~~~

Within a typemap, a number of special variables prefaced with a ``$``
may appear. A full list of variables can be found in the
"`Typemaps <Typemaps.html#Typemaps>`__" chapter. This is a list of the
most common variables:

``$1``

.. container:: indent

   A C local variable corresponding to the actual type specified in the
   ``%typemap`` directive. For input values, this is a C local variable
   that is supposed to hold an argument value. For output values, this
   is the raw result that is supposed to be returned to Ruby.

``$input``

.. container:: indent

   A ``VALUE`` holding a raw Ruby object with an argument or variable
   value.

``$result``

.. container:: indent

   A ``VALUE`` that holds the result to be returned to Ruby.

``$1_name``

.. container:: indent

   The parameter name that was matched.

``$1_type``

.. container:: indent

   The actual C datatype matched by the typemap.

``$1_ltype``

.. container:: indent

   An assignable version of the datatype matched by the typemap (a type
   that can appear on the left-hand-side of a C assignment operation).
   This type is stripped of qualifiers and may be an altered version of
   ``$1_type``. All arguments and local variables in wrapper functions
   are declared using this type so that their values can be properly
   assigned.

``$symname``

.. container:: indent

   The Ruby name of the wrapper function being created.

Useful Functions
~~~~~~~~~~~~~~~~~~~~~~~

When you write a typemap, you usually have to work directly with Ruby
objects. The following functions may prove to be useful. (These
functions plus many more can be found in *Programming Ruby* book, by
David Thomas and Andrew Hunt.)

In addition, we list equivalent functions that SWIG defines, which
provide a language neutral conversion (these functions are defined for
each swig language supported). If you are trying to create a swig file
that will work under multiple languages, it is recommended you stick to
the swig functions instead of the native Ruby functions. That should
help you avoid having to rewrite a lot of typemaps across multiple
languages.

C Datatypes to Ruby Objects
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. container:: diagram

   +-----------------------+-----------------------+-----------------------+
   | **RUBY**              | **SWIG**              |                       |
   +-----------------------+-----------------------+-----------------------+
   | INT2NUM(long or int)  | SWIG_From_int(int x)  | int to Fixnum or      |
   |                       |                       | Bignum                |
   +-----------------------+-----------------------+-----------------------+
   | INT2FIX(long or int)  |                       | int to Fixnum (faster |
   |                       |                       | than INT2NUM)         |
   +-----------------------+-----------------------+-----------------------+
   | CHR2FIX(char)         | SWIG_From_char(char   | char to Fixnum        |
   |                       | x)                    |                       |
   +-----------------------+-----------------------+-----------------------+
   | rb_str_new2(char*)    | SWIG_From             | char\* to String      |
   |                       | CharPtrAndSize(char*, |                       |
   |                       | size_t)               |                       |
   +-----------------------+-----------------------+-----------------------+
   | rb_float_new(double)  | SWIG                  | float/double to Float |
   |                       | _From_double(double), |                       |
   |                       | S                     |                       |
   |                       | WIG_From_float(float) |                       |
   +-----------------------+-----------------------+-----------------------+

Ruby Objects to C Datatypes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Here, while the Ruby versions return the value directly, the SWIG
versions do not, but return a status value to indicate success
(``SWIG_OK``). While more awkward to use, this allows you to write
typemaps that report more helpful error messages, like:

.. container:: code

   ::

      %typemap(in) size_t (int ok)
        ok = SWIG_AsVal_size_t($input, &$1);
        if (!SWIG_IsOK(ok)) {
          SWIG_exception_fail(SWIG_ArgError(ok), Ruby_Format_TypeError( "$1_name", "$1_type", "$symname", $argnum, $input));
        }
      }

.. container:: diagram

   +----------------------------------+----------------------------------+
   | int NUM2INT(Numeric)             | SWIG_AsVal_int(VALUE, int*)      |
   +----------------------------------+----------------------------------+
   | int FIX2INT(Numeric)             | SWIG_AsVal_int(VALUE, int*)      |
   +----------------------------------+----------------------------------+
   | unsigned int NUM2UINT(Numeric)   | S                                |
   |                                  | WIG_AsVal_unsigned_SS_int(VALUE, |
   |                                  | int*)                            |
   +----------------------------------+----------------------------------+
   | unsigned int FIX2UINT(Numeric)   | S                                |
   |                                  | WIG_AsVal_unsigned_SS_int(VALUE, |
   |                                  | int*)                            |
   +----------------------------------+----------------------------------+
   | long NUM2LONG(Numeric)           | SWIG_AsVal_long(VALUE, long*)    |
   +----------------------------------+----------------------------------+
   | long FIX2LONG(Numeric)           | SWIG_AsVal_long(VALUE, long*)    |
   +----------------------------------+----------------------------------+
   | unsigned long FIX2ULONG(Numeric) | SW                               |
   |                                  | IG_AsVal_unsigned_SS_long(VALUE, |
   |                                  | unsigned long*)                  |
   +----------------------------------+----------------------------------+
   | char NUM2CHR(Numeric or String)  | SWIG_AsVal_char(VALUE, int*)     |
   +----------------------------------+----------------------------------+
   | char \* StringValuePtr(String)   | SWIG_AsCharPtrAndSize(VALUE,     |
   |                                  | char*, size_t, int\* alloc)      |
   +----------------------------------+----------------------------------+
   | char \* rb_str2cstr(String,      |                                  |
   | int*length)                      |                                  |
   +----------------------------------+----------------------------------+
   | double NUM2DBL(Numeric)          | (double) SWIG_AsVal_int(VALUE)   |
   |                                  | or similar                       |
   +----------------------------------+----------------------------------+

Macros for VALUE
^^^^^^^^^^^^^^^^^^^^^^^^^

``RSTRING_LEN(str)``

.. container:: indent

   length of the Ruby string

``RSTRING_PTR(str)``

.. container:: indent

   pointer to string storage

``RARRAY_LEN(arr)``

.. container:: indent

   length of the Ruby array

``RARRAY(arr)->capa``

.. container:: indent

   capacity of the Ruby array

``RARRAY_PTR(arr)``

.. container:: indent

   pointer to array storage

Exceptions
^^^^^^^^^^^^^^^^^^^

``void rb_raise(VALUE exception, const char *fmt, ...)``

.. container:: indent

   Raises an exception. The given format string *fmt* and remaining
   arguments are interpreted as with ``printf()``.

``void rb_fatal(const char *fmt, ...)``

.. container:: indent

   Raises a fatal exception, terminating the process. No rescue blocks
   are called, but ensure blocks will be called. The given format string
   *fmt* and remaining arguments are interpreted as with ``printf()``.

``void rb_bug(const char *fmt, ...)``

.. container:: indent

   Terminates the process immediately -- no handlers of any sort will be
   called. The given format string *fmt* and remaining arguments are
   interpreted as with ``printf()``. You should call this function only
   if a fatal bug has been exposed.

``void rb_sys_fail(const char *msg)``

.. container:: indent

   Raises a platform-specific exception corresponding to the last known
   system error, with the given string *msg*.

``VALUE rb_rescue(VALUE (*body)(VALUE), VALUE args, VALUE(*rescue)(VALUE, VALUE), VALUE rargs)``

.. container:: indent

   Executes *body* with the given *args*. If a ``StandardError``
   exception is raised, then execute *rescue* with the given *rargs*.

``VALUE rb_ensure(VALUE(*body)(VALUE), VALUE args, VALUE(*ensure)(VALUE), VALUE eargs)``

.. container:: indent

   Executes *body* with the given *args*. Whether or not an exception is
   raised, execute *ensure* with the given *rargs* after *body* has
   completed.

``VALUE rb_protect(VALUE (*body)(VALUE), VALUE args, int *result)``

.. container:: indent

   Executes *body* with the given *args* and returns nonzero in result
   if any exception was raised.

``void rb_notimplement()``

.. container:: indent

   Raises a ``NotImpError`` exception to indicate that the enclosed
   function is not implemented yet, or not available on this platform.

``void rb_exit(int status)``

.. container:: indent

   Exits Ruby with the given *status*. Raises a ``SystemExit`` exception
   and calls registered exit functions and finalizers.

``void rb_warn(const char *fmt, ...)``

.. container:: indent

   Unconditionally issues a warning message to standard error. The given
   format string *fmt* and remaining arguments are interpreted as with
   ``printf()``.

``void rb_warning(const char *fmt, ...)``

.. container:: indent

   Conditionally issues a warning message to standard error if Ruby was
   invoked with the ``-w`` flag. The given format string *fmt* and
   remaining arguments are interpreted as with ``printf()``.

Iterators
^^^^^^^^^^^^^^^^^^

``void rb_iter_break()``

.. container:: indent

   Breaks out of the enclosing iterator block.

``VALUE rb_each(VALUE obj)``

.. container:: indent

   Invokes the ``each`` method of the given *obj*.

``VALUE rb_yield(VALUE arg)``

.. container:: indent

   Transfers execution to the iterator block in the current context,
   passing *arg* as an argument. Multiple values may be passed in an
   array.

``int rb_block_given_p()``

.. container:: indent

   Returns ``true`` if ``yield`` would execute a block in the current
   context; that is, if a code block was passed to the current method
   and is available to be called.

``VALUE rb_iterate(VALUE (*method)(VALUE), VALUE args, VALUE (*block)(VALUE, VALUE), VALUE arg2)``

.. container:: indent

   Invokes *method* with argument *args* and block *block*. A ``yield``
   from that method will invoke *block* with the argument given to
   ``yield``, and a second argument *arg2*.

``VALUE rb_catch(const char *tag, VALUE (*proc)(VALUE, VALUE), VALUE value)``

.. container:: indent

   Equivalent to Ruby's ``catch``.

``void rb_throw(const char *tag, VALUE value)``

.. container:: indent

   Equivalent to Ruby's ``throw``.

Typemap Examples
~~~~~~~~~~~~~~~~~~~~~~~

This section includes a few examples of typemaps. For more examples, you
might look at the examples in the ``Example/ruby`` directory.

Converting a Ruby array to a char \*\*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A common problem in many C programs is the processing of command line
arguments, which are usually passed in an array of ``NULL`` terminated
strings. The following SWIG interface file allows a Ruby Array instance
to be used as a ``char **`` object.

.. container:: code

   ::

      %module argv

      // This tells SWIG to treat char ** as a special case
      %typemap(in) char ** {
        /* Get the length of the array */
        int size = RARRAY($input)->len; 
        int i;
        $1 = (char **) malloc((size+1)*sizeof(char *));
        /* Get the first element in memory */
        VALUE *ptr = RARRAY($input)->ptr; 
        for (i=0; i < size; i++, ptr++) {
          /* Convert Ruby Object String to char* */
          $1[i]= StringValuePtr(*ptr); 
        }
        $1[i]=NULL; /* End of list */
      }

      // This cleans up the char ** array created before 
      // the function call

      %typemap(freearg) char ** {
        free((char *) $1);
      }

      // Now a test function
      %inline %{
      int print_args(char **argv) {
        int i = 0;
        while (argv[i]) {
          printf("argv[%d] = %s\n", i, argv[i]);
          i++;
        }
        return i;
      }
      %}

When this module is compiled, the wrapped C function now operates as
follows :

.. container:: code targetlang

   ::

      require 'Argv'
      Argv.print_args(["Dave", "Mike", "Mary", "Jane", "John"])
      argv[0] = Dave
      argv[1] = Mike
      argv[2] = Mary
      argv[3] = Jane
      argv[4] = John

In the example, two different typemaps are used. The "in" typemap is
used to receive an input argument and convert it to a C array. Since
dynamic memory allocation is used to allocate memory for the array, the
"freearg" typemap is used to later release this memory after the
execution of the C function.

Collecting arguments in a hash
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ruby's solution to the "keyword arguments" capability of some other
languages is to allow the programmer to pass in one or more key-value
pairs as arguments to a function. All of those key-value pairs are
collected in a single ``Hash`` argument that's presented to the
function. If it makes sense, you might want to provide similar
functionality for your Ruby interface. For example, suppose you'd like
to wrap this C function that collects information about people's vital
statistics:

.. container:: code

   ::

      void setVitalStats(const char *person, int nattributes, const char **names, int *values);

and you'd like to be able to call it from Ruby by passing in an
arbitrary number of key-value pairs as inputs, e.g.

.. container:: code targetlang

   ::

      setVitalStats("Fred", 
        'weight' => 270, 
        'age' => 42 
      )

To make this work, you need to write a typemap that expects a Ruby
``Hash`` as its input and somehow extracts the last three arguments
(*nattributes*, *names* and *values*) needed by your C function. Let's
start with the basics:

.. container:: code

   ::

      %typemap(in) (int nattributes, const char **names, const int *values)
        (VALUE keys_arr, int i, VALUE key, VALUE val) {
      }
       

This ``%typemap`` directive tells SWIG that we want to match any
function declaration that has the specified types and names of arguments
somewhere in the argument list. The fact that we specified the argument
names (*nattributes*, *names* and *values*) in our typemap is
significant; this ensures that SWIG won't try to apply this typemap to
*other* functions it sees that happen to have a similar declaration with
different argument names. The arguments that appear in the second set of
parentheses (*keys_arr*, *i*, *key* and *val*) define local variables
that our typemap will need.

Since we expect the input argument to be a ``Hash``, let's next add a
check for that:

.. container:: code

   ::

      %typemap(in) (int nattributes, const char **names, const int *values)
        (VALUE keys_arr, int i, VALUE key, VALUE val) {
          Check_Type($input, T_HASH);
      }

``Check_Type()`` is just a macro (defined in the Ruby header files) that
confirms that the input argument is of the correct type; if it isn't, an
exception will be raised.

The next task is to determine how many key-value pairs are present in
the hash; we'll assign this number to the first typemap argument
(``$1``). This is a little tricky since the Ruby/C API doesn't provide a
public function for querying the size of a hash, but we can get around
that by calling the hash's *size* method directly and converting its
result to a C ``int`` value:

.. container:: code

   ::

      %typemap(in) (int nattributes, const char **names, const int *values)
        (VALUE keys_arr, int i, VALUE key, VALUE val) {
          Check_Type($input, T_HASH);
          $1 = NUM2INT(rb_funcall($input, rb_intern("size"), 0, Qnil));
      }

So now we know the number of attributes. Next we need to initialize the
second and third typemap arguments (i.e. the two C arrays) to ``NULL``
and set the stage for extracting the keys and values from the hash:

.. container:: code

   ::

      %typemap(in) (int nattributes, const char **names, const int *values)
        (VALUE keys_arr, int i, VALUE key, VALUE val) {
          Check_Type($input, T_HASH);
          $1 = NUM2INT(rb_funcall($input, rb_intern("size"), 0, Qnil));
          $2 = NULL;
          $3 = NULL;
          if ($1 > 0) {
            $2 = (char **) malloc($1*sizeof(char *));
            $3 = (int *) malloc($1*sizeof(int));
          }
      }

There are a number of ways we could extract the keys and values from the
input hash, but the simplest approach is to first call the hash's *keys*
method (which returns a Ruby array of the keys) and then start looping
over the elements in that array:

.. container:: code

   ::

      %typemap(in) (int nattributes, const char **names, const int *values)
        (VALUE keys_arr, int i, VALUE key, VALUE val) {
          Check_Type($input, T_HASH);
          $1 = NUM2INT(rb_funcall($input, rb_intern("size"), 0, Qnil));
          $2 = NULL;
          $3 = NULL;
          if ($1 > 0) {
            $2 = (char **) malloc($1*sizeof(char *));
            $3 = (int *) malloc($1*sizeof(int));
            keys_arr = rb_funcall($input, rb_intern("keys"), 0, Qnil);
            for (i = 0; i < $1; i++) {
            }
          }
      }

Recall that *keys_arr* and *i* are local variables for this typemap. For
each element in the *keys_arr* array, we want to get the key itself, as
well as the value corresponding to that key in the hash:

.. container:: code

   ::

      %typemap(in) (int nattributes, const char **names, const int *values)
        (VALUE keys_arr, int i, VALUE key, VALUE val) {
          Check_Type($input, T_HASH);
          $1 = NUM2INT(rb_funcall($input, rb_intern("size"), 0, Qnil));
          $2 = NULL;
          $3 = NULL;
          if ($1 > 0) {
            $2 = (char **) malloc($1*sizeof(char *));
            $3 = (int *) malloc($1*sizeof(int));
            keys_arr = rb_funcall($input, rb_intern("keys"), 0, Qnil);
            for (i = 0; i < $1; i++) {
              key = rb_ary_entry(keys_arr, i);
              val = rb_hash_aref($input, key);
            }
          }
      }

To be safe, we should again use the ``Check_Type()`` macro to confirm
that the key is a ``String`` and the value is a ``Fixnum``:

.. container:: code

   ::

      %typemap(in) (int nattributes, const char **names, const int *values)
        (VALUE keys_arr, int i, VALUE key, VALUE val) {
          Check_Type($input, T_HASH);
          $1 = NUM2INT(rb_funcall($input, rb_intern("size"), 0, Qnil));
          $2 = NULL;
          $3 = NULL;
          if ($1 > 0) {
            $2 = (char **) malloc($1*sizeof(char *));
            $3 = (int *) malloc($1*sizeof(int));
            keys_arr = rb_funcall($input, rb_intern("keys"), 0, Qnil);
            for (i = 0; i < $1; i++) {
              key = rb_ary_entry(keys_arr, i);
              val = rb_hash_aref($input, key);
              Check_Type(key, T_STRING);
              Check_Type(val, T_FIXNUM);
            }
          }
      }

Finally, we can convert these Ruby objects into their C equivalents and
store them in our local C arrays:

.. container:: code

   ::

      %typemap(in) (int nattributes, const char **names, const int *values)
        (VALUE keys_arr, int i, VALUE key, VALUE val) {
        Check_Type($input, T_HASH);
        $1 = NUM2INT(rb_funcall($input, rb_intern("size"), 0, Qnil));
        $2 = NULL;
        $3 = NULL;
        if ($1 > 0) {
          $2 = (char **) malloc($1*sizeof(char *));
          $3 = (int *) malloc($1*sizeof(int));
          keys_arr = rb_funcall($input, rb_intern("keys"), 0, Qnil);
          for (i = 0; i < $1; i++) {
            key = rb_ary_entry(keys_arr, i);
            val = rb_hash_aref($input, key);
            Check_Type(key, T_STRING);
            Check_Type(val, T_FIXNUM);
            $2[i] = StringValuePtr(key);
            $3[i] = NUM2INT(val);
          }
        }
      }

We're not done yet. Since we used ``malloc()`` to dynamically allocate
the memory used for the *names* and *values* arguments, we need to
provide a corresponding "freearg" typemap to free that memory so that
there is no memory leak. Fortunately, this typemap is a lot easier to
write:

.. container:: code

   ::

      %typemap(freearg) (int nattributes, const char **names, const int *values) {
        free((void *) $2);
        free((void *) $3);
      }

All of the code for this example, as well as a sample Ruby program that
uses the extension, can be found in the ``Examples/ruby/hashargs``
directory of the SWIG distribution.

Pointer handling
~~~~~~~~~~~~~~~~~~~~~~~~

Occasionally, it might be necessary to convert pointer values that have
been stored using the SWIG typed-pointer representation. Since there are
several ways in which pointers can be represented, the following two
functions are used to safely perform this conversion:

``int SWIG_ConvertPtr(VALUE obj, void **ptr, swig_type_info *ty, int flags)``

.. container:: indent

   Converts a Ruby object *obj* to a C pointer whose address is *ptr*
   (i.e. *ptr* is a pointer to a pointer). The third argument, *ty*, is
   a pointer to a SWIG type descriptor structure. If *ty* is not
   ``NULL``, that type information is used to validate type
   compatibility and other aspects of the type conversion. If *flags* is
   non-zero, any type errors encountered during this validation result
   in a Ruby ``TypeError`` exception being raised; if *flags* is zero,
   such type errors will cause ``SWIG_ConvertPtr()`` to return -1 but
   not raise an exception. If *ty* is ``NULL``, no type-checking is
   performed.

``VALUE SWIG_NewPointerObj(void *ptr, swig_type_info *ty, int own)``

.. container:: indent

   Creates a new Ruby pointer object. Here, *ptr* is the pointer to
   convert, *ty* is the SWIG type descriptor structure that describes
   the type, and *own* is a flag that indicates whether or not Ruby
   should take ownership of the pointer (i.e. whether Ruby should free
   this data when the corresponding Ruby instance is garbage-collected).

Both of these functions require the use of a special SWIG
type-descriptor structure. This structure contains information about the
mangled name of the datatype, type-equivalence information, as well as
information about converting pointer values under C++ inheritance. For a
type of ``Foo *``, the type descriptor structure is usually accessed as
follows:

.. container:: indent code

   ::

      Foo *foo;
      SWIG_ConvertPtr($input, (void **) &foo, SWIGTYPE_p_Foo, 1);

      VALUE obj;
      obj = SWIG_NewPointerObj(f, SWIGTYPE_p_Foo, 0);

In a typemap, the type descriptor should always be accessed using the
special typemap variable ``$1_descriptor``. For example:

.. container:: indent code

   ::

      %typemap(in) Foo * {
        SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, 1);
      }

Ruby Datatype Wrapping
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``VALUE Data_Wrap_Struct(VALUE class, void (*mark)(void *), void (*free)(void *), void *ptr)``

.. container:: indent

   Given a pointer *ptr* to some C data, and the two garbage collection
   routines for this data (*mark* and *free*), return a ``VALUE`` for
   the Ruby object.

``VALUE Data_Make_Struct(VALUE class, c-type, void (*mark)(void *), void (*free)(void *), c-type *ptr)``

.. container:: indent

   Allocates a new instance of a C data type *c-type*, assigns it to the
   pointer *ptr*, then wraps that pointer with ``Data_Wrap_Struct()`` as
   above.

``Data_Get_Struct(VALUE obj, c-type, c-type *ptr)``

.. container:: indent

   Retrieves the original C pointer of type *c-type* from the data
   object *obj* and assigns that pointer to *ptr*.

Example: STL Vector to Ruby Array
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Another use for macros and type maps is to create a Ruby array from a
STL vector of pointers. In essence, copy of all the pointers in the
vector into a Ruby array. The use of the macro is to make the typemap so
generic that any vector with pointers can use the type map. The
following is an example of how to construct this type of macro/typemap
and should give insight into constructing similar typemaps for other STL
structures:

.. container:: code

   ::

      %define PTR_VECTOR_TO_RUBY_ARRAY(vectorclassname, classname)
      %typemap(out) vectorclassname &, const vectorclassname & {
        VALUE arr = rb_ary_new2($1->size());
        vectorclassname::iterator i = $1->begin(), iend = $1->end();
        for ( ; i!=iend; i++ )
          rb_ary_push(arr, Data_Wrap_Struct(c ## classname.klass, 0, 0, *i));
        $result = arr;
      }
      %typemap(out) vectorclassname, const vectorclassname {
        VALUE arr = rb_ary_new2($1.size());
        vectorclassname::iterator i = $1.begin(), iend = $1.end();
        for ( ; i!=iend; i++ )
          rb_ary_push(arr, Data_Wrap_Struct(c ## classname.klass, 0, 0, *i));
        $result = arr;
      }
      %enddef

Note, that the "``c ## classname.klass"`` is used in the preprocessor
step to determine the actual object from the class name.

To use the macro with a class Foo, the following is used:

.. container:: code

   ::

      PTR_VECTOR_TO_RUBY_ARRAY(vector<foo *="">, Foo)

It is also possible to create a STL vector of Ruby objects:

.. container:: code

   ::

      %define RUBY_ARRAY_TO_PTR_VECTOR(vectorclassname, classname)
      %typemap(in) vectorclassname &, const vectorclassname & {
        Check_Type($input, T_ARRAY);
        vectorclassname *vec = new vectorclassname;
        int len = RARRAY($input)->len;
        for (int i=0; i!=len; i++) {
          VALUE inst = rb_ary_entry($input, i);
          //The following _should_ work but doesn't on HPUX
          // Check_Type(inst, T_DATA);
          classname *element = NULL;
          Data_Get_Struct(inst, classname, element);
          vec->push_back(element);
        }
        $1 = vec;
      }

      %typemap(freearg) vectorclassname &, const vectorclassname & {
        delete $1;
      }
      %enddef

It is also possible to create a Ruby array from a vector of static data
types:

.. container:: code

   ::

      %define VECTOR_TO_RUBY_ARRAY(vectorclassname, classname)
      %typemap(out) vectorclassname &, const vectorclassname & {
        VALUE arr = rb_ary_new2($1->size()); 
        vectorclassname::iterator i = $1->begin(), iend = $1->end();
        for ( ; i!=iend; i++ )
          rb_ary_push(arr, Data_Wrap_Struct(c ## classname.klass, 0, 0, &(*i)));
        $result = arr;
      }
      %typemap(out) vectorclassname, const vectorclassname {
        VALUE arr = rb_ary_new2($1.size()); 
        vectorclassname::iterator i = $1.begin(), iend = $1.end();
        for ( ; i!=iend; i++ )
          rb_ary_push(arr, Data_Wrap_Struct(c ## classname.klass, 0, 0, &(*i)));
        $result = arr;
      }
      %enddef

Note that this is mostly an example of typemaps. If you want to use the
STL with ruby, you are advised to use the standard swig STL library,
which does much more than this. Refer to the section called the `C++
Standard Template Library <#Ruby_nn23_1>`__.

Docstring Features
-----------------------

Using ri and rdoc web pages in Ruby libraries is a common practice.
Given the way that SWIG generates the extensions by default, your users
will normally not get any documentation for it, even if they run 'rdoc'
on the resulting .c or .cxx file.

The features described in this section make it easy for you to add rdoc
strings to your modules, functions and methods that can then be read by
Ruby's rdoc tool to generate html web pages, ri documentation, Windows
chm file and an .xml description.

rdoc can then be run from a console or shell window on a swig generated
file.

For example, to generate html web pages from a C++ file, you'd do:

.. container:: code shell

   ::

      $ rdoc -E cxx=c -f html file_wrap.cxx

To generate ri documentation from a c wrap file, you could do:

.. container:: code shell

   ::

      $ rdoc -r file_wrap.c

Module docstring
~~~~~~~~~~~~~~~~~~~~~~~

Ruby allows a docstring at the beginning of the file before any other
statements, and it is typically used to give a general description of
the entire module. SWIG supports this by setting an option of the
``%module`` directive. For example:

.. container:: code

   ::

      %module(docstring="This is the example module's docstring") example

When you have more than just a line or so then you can retain the easy
readability of the ``%module`` directive by using a macro. For example:

.. container:: code

   ::

      %define DOCSTRING
      "The `XmlResource` class allows program resources defining menus, 
      layout of controls on a panel, etc. to be loaded from an XML file."
      %enddef

      %module(docstring=DOCSTRING) xrc

%feature("autodoc")
~~~~~~~~~~~~~~~~~~~~~~~~~~

Since SWIG does know everything about the function it wraps, it is
possible to generate an rdoc containing the parameter types, names and
default values. Since Ruby ships with one of the best documentation
systems of any language, it makes sense to take advantage of it.

SWIG's Ruby module provides support for the "autodoc" feature, which
when attached to a node in the parse tree will cause an rdoc comment to
be generated in the wrapper file that includes the name of the function,
parameter names, default values if any, and return type if any. There
are also several options for autodoc controlled by the value given to
the feature, described below.

%feature("autodoc", "0")
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When the "0" option is given then the types of the parameters will *not*
be included in the autodoc string. For example, given this function
prototype:

.. container:: code

   ::

      %feature("autodoc", "0");
      bool function_name(int x, int y, Foo* foo=NULL, Bar* bar=NULL);

Then Ruby code like this will be generated:

.. container:: targetlang

   ::

      function_name(x, y, foo=nil, bar=nil) -> bool
        ...

%feature("autodoc", "1")
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When the "1" option is used then the parameter types *will* be used in
the rdoc string. In addition, an attempt is made to simplify the type
name such that it makes more sense to the Ruby user. Pointer, reference
and const info is removed, ``%rename``'s are evaluated, etc. (This is
not always successful, but works most of the time. See the next section
for what to do when it doesn't.) Given the example above, then turning
on the parameter types with the "1" option will result in rdoc code like
this:

.. container:: targetlang

   ::

      function_name(int x, int y, Foo foo=nil, Bar bar=nil) -> bool
        ...

%feature("autodoc", "2")
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When the "2" option is used then the parameter types will not be used in
the rdoc string. However, they will be listed in full after the
function. Given the example above, then turning on the parameter types
with the "2" option will result in Ruby code like this:

%feature("autodoc", "3")
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When the "3" option is used then the function will be documented using a
combination of "1" and "2" above. Given the example above, then turning
on the parameter types with the "2" option will result in Ruby code like
this:

.. container:: targetlang

   ::

      function_name(int x, int y, Foo foo=nil, Bar bar=nil) -> bool

      Parameters:
              x - int
              y - int
              foo - Foo
              bar - Bar

%feature("autodoc", "docstring")
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Finally, there are times when the automatically generated autodoc string
will make no sense for a Ruby programmer, particularly when a typemap is
involved. So if you give an explicit value for the autodoc feature then
that string will be used in place of the automatically generated string.
For example:

.. container:: code

   ::

      %feature("autodoc", "GetPosition() -> (x, y)") GetPosition;
      void GetPosition(int* OUTPUT, int* OUTPUT);

%feature("docstring")
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to the autodoc strings described above, you can also attach
any arbitrary descriptive text to a node in the parse tree with the
"docstring" feature. When the proxy module is generated then any
docstring associated with classes, function or methods are output. If an
item already has an autodoc string then it is combined with the
docstring and they are output together.

Advanced Topics
--------------------

Operator overloading
~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG allows operator overloading with, by using the ``%extend`` or
``%rename`` commands in SWIG and the following operator names (derived
from Python):

.. container:: code diagram

   ======================= ========
   **General**                      
   \__repr_\_              inspect  
   \__str_\_               to_s     
   \__cmp_\_               <=>      
   \__hash_\_              hash     
   \__nonzero_\_           nonzero? 
   \                                
   **Callable**                     
   \__call_\_              call     
   \                                
   **Collection**                   
   \__len_\_               length   
   \__getitem_\_           []       
   \__setitem_\_           []=      
   \                                
   **Numeric**                      
   \__add_\_               +        
   \__sub_\_               -        
   \__mul_\_               \*       
   \__div_\_               /        
   \__mod_\_               %        
   \__divmod_\_            divmod   
   \__pow_\_               \*\*     
   \__lshift_\_            <<       
   \__rshift_\_            >>       
   \__and_\_               &        
   \__xor_\_               ^        
   \__or_\_                \|       
   \__neg_\_               -@       
   \__pos_\_               +@       
   \__abs_\_               abs      
   \__invert_\_            ~        
   \__int_\_               to_i     
   \__float_\_             to_f     
   \__coerce_\_            coerce   
   \                                
   **Additions in 1.3.13**          
   \__lt_\_                <        
   \__le_\_                <=       
   \__eq_\_                ==       
   \__gt_\_                >        
   \__ge_\_                >=       
   ======================= ========

Note that although SWIG supports the ``__eq__`` magic method name for
defining an equivalence operator, there is no separate method for
handling *inequality* since Ruby parses the expression *a != b* as *!(a
== b)*.

Creating Multi-Module Packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The chapter on `Working with Modules <Modules.html#Modules>`__ discusses
the basics of creating multi-module extensions with SWIG, and in
particular the considerations for sharing runtime type information among
the different modules.

As an example, consider one module's interface file (``shape.i``) that
defines our base class:

.. container:: code

   ::

      %module shape

      %{
      #include "Shape.h"
      %}

      class Shape {
      protected:
        double xpos;
        double ypos;
      protected:
        Shape(double x, double y);
      public:
        double getX() const;
        double getY() const;
      };

We also have a separate interface file (``circle.i``) that defines a
derived class:

.. container:: code

   ::

      %module circle

      %{
      #include "Shape.h"
      #include "Circle.h"
      %}

      // Import the base class definition from Shape module
      %import shape.i

      class Circle : public Shape {
      protected:
        double radius;
      public:
        Circle(double x, double y, double r);
        double getRadius() const;
      };

We'll start by building the **Shape** extension module:

.. container:: code shell

   ::

      $ swig -c++ -ruby shape.i

SWIG generates a wrapper file named ``shape_wrap.cxx``. To compile this
into a dynamically loadable extension for Ruby, prepare an
``extconf.rb`` script using this template:

.. container:: code targetlang

   ::

      require 'mkmf'

      # Since the SWIG runtime support library for Ruby
      # depends on the Ruby library, make sure it's in the list
      # of libraries.
      $libs = append_library($libs, Config::CONFIG['RUBY_INSTALL_NAME'])

      # Create the makefile
      create_makefile('shape')

Run this script to create a ``Makefile`` and then type ``make`` to build
the shared library:

.. container:: code targetlang

   ::

      $ ruby extconf.rb
      creating Makefile
      $ make
      g++ -fPIC -g -O2 -I. -I/usr/include/ruby-2.1.0 \
      -I. -c shape_wrap.cxx
      gcc -shared -L/usr/local/lib -o shape.so shape_wrap.o -L. \
      -lruby -lruby -lc

Note that depending on your installation, the outputs may be slightly
different; these outputs are those for a Linux-based development
environment. The end result should be a shared library (here,
``shape.so``) containing the extension module code. Now repeat this
process in a separate directory for the **Circle** module:

#. Run SWIG to generate the wrapper code (``circle_wrap.cxx``);
#. Write an ``extconf.rb`` script that your end-users can use to create
   a platform-specific ``Makefile`` for the extension;
#. Build the shared library for this extension by typing ``make``.

Once you've built both of these extension modules, you can test them
interactively in IRB to confirm that the ``Shape`` and ``Circle``
modules are properly loaded and initialized:

.. container:: code targetlang

   ::

      $ irb
      irb(main):001:0> require 'shape'
      true
      irb(main):002:0> require 'circle'
      true
      irb(main):003:0> c = Circle::Circle.new(5, 5, 20)
      #<Circle::Circle:0xa097208>
      irb(main):004:0> c.kind_of? Shape::Shape
      true
      irb(main):005:0> c.getX()
      5.0

Specifying Mixin Modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Ruby language doesn't support multiple inheritance, but it does
allow you to mix one or more modules into a class using Ruby's
``include`` method. For example, if you have a Ruby class that defines
an *each* instance method, e.g.

.. container:: code targetlang

   ::

      class Set
        def initialize
        @members = []
        end
       
        def each
        @members.each { |m| yield m }
        end
      end

then you can mix-in Ruby's ``Enumerable`` module to easily add a lot of
functionality to your class:

.. container:: code targetlang

   ::

      class Set
        include Enumerable
        def initialize
          @members = []
        end
        def each
          @members.each { |m| yield m }
        end
      end

To get the same benefit for your SWIG-wrapped classes, you can use the
``%mixin`` directive to specify the names of one or more modules that
should be mixed-in to a class. For the above example, the SWIG interface
specification might look like this:

.. container:: code

   ::

      %mixin Set "Enumerable";

      class Set {
      public:
        // Constructor
        Set();
       
        // Iterates through set members
        void each();
      };

Multiple modules can be mixed into a class by providing a
comma-separated list of module names to the ``%mixin`` directive, e.g.

.. container:: code

   ::

      %mixin Set "Fee, Fi, Fo, Fum";

Note that the ``%mixin`` directive is implemented using SWIG's
"features" mechanism and so the same name matching rules used for other
kinds of features apply (see the chapter on `"Customization
Features" <Customization.html#Customization>`__) for more details).

Memory Management
-----------------------

One of the most common issues in generating SWIG bindings for Ruby is
proper memory management. The key to proper memory management is clearly
defining whether a wrapper Ruby object owns the underlying C struct or
C++ class. There are two possibilities:

-  The Ruby object is responsible for freeing the C struct or C++ object
-  The Ruby object should not free the C struct or C++ object because it
   will be freed by the underlying C or C++ code

To complicate matters, object ownership may transfer from Ruby to C++
(or vice versa) depending on what function or methods are invoked.
Clearly, developing a SWIG wrapper requires a thorough understanding of
how the underlying library manages memory.

Mark and Sweep Garbage Collector
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ruby uses a mark and sweep garbage collector. When the garbage collector
runs, it finds all the "root" objects, including local variables, global
variables, global constants, hardware registers and the C stack. For
each root object, the garbage collector sets its mark flag to true and
calls ``rb_gc_mark`` on the object. The job of ``rb_gc_mark`` is to
recursively mark all the objects that a Ruby object has a reference to
(ignoring those objects that have already been marked). Those objects,
in turn, may reference other objects. This process will continue until
all active objects have been "marked." After the mark phase comes the
sweep phase. In the sweep phase, all objects that have not been marked
will be garbage collected.

The Ruby C/API provides extension developers two hooks into the garbage
collector - a "mark" function and a "sweep" function. By default these
functions are set to NULL.

If a C struct or C++ class references any other Ruby objects, then it
must provide a "mark" function. The "mark" function should identify any
referenced Ruby objects by calling the rb_gc_mark function for each one.
Unsurprisingly, this function will be called by the Ruby garbage during
the "mark" phase.

During the sweep phase, Ruby destroys any unused objects. If any memory
has been allocated in creating the underlying C struct or C++ struct,
then a "free" function must be defined that deallocates this memory.

Object Ownership
~~~~~~~~~~~~~~~~~~~~~~~~

As described above, memory management depends on clearly defining who is
responsible for freeing the underlying C struct or C++ class. If the
Ruby object is responsible for freeing the C++ object, then a "free"
function must be registered for the object. If the Ruby object is not
responsible for freeing the underlying memory, then a "free" function
must not be registered for the object.

For the most part, SWIG takes care of memory management issues. The
rules it uses are:

-  When calling a C++ object's constructor from Ruby, SWIG will assign a
   "free" function thereby making the Ruby object responsible for
   freeing the C++ object
-  When calling a C++ member function that returns a pointer, SWIG will
   not assign a "free" function thereby making the underlying library
   responsible for freeing the object.

To make this clearer, let's look at an example. Assume we have a Foo and
a Bar class.

.. container:: code

   ::

      /* File "RubyOwernshipExample.h" */

      class Foo
      {
      public:
        Foo() {}
        ~Foo() {}
      };

      class Bar
      {
        Foo *foo_;
      public:
        Bar(): foo_(new Foo) {}
        ~Bar() { delete foo_; }
        Foo* get_foo() { return foo_; }
        Foo* get_new_foo() { return new Foo; }
        void set_foo(Foo *foo) { delete foo_; foo_ = foo; }
      };

First, consider this Ruby code:

.. container:: code targetlang

   ::

      foo = Foo.new

In this case, the Ruby code calls the underlying ``Foo`` C++
constructor, thus creating a new ``foo`` object. By default, SWIG will
assign the new Ruby object a "free" function. When the Ruby object is
garbage collected, the "free" function will be called. It in turn will
call ``Foo``'s destructor.

Next, consider this code:

.. container:: code targetlang

   ::

      bar = Bar.new
      foo = bar.get_foo()

In this case, the Ruby code calls a C++ member function, ``get_foo``. By
default, SWIG will not assign the Ruby object a "free" function. Thus,
when the Ruby object is garbage collected the underlying C++ ``foo``
object is not affected.

Unfortunately, the real world is not as simple as the examples above.
For example:

.. container:: code targetlang

   ::

      bar = Bar.new
      foo = bar.get_new_foo()

In this case, the default SWIG behavior for calling member functions is
incorrect. The Ruby object should assume ownership of the returned
object. This can be done by using the %newobject directive. See `Object
ownership and %newobject <Customization.html#Customization_ownership>`__
for more information.

The SWIG default mappings are also incorrect in this case:

.. container:: code targetlang

   ::

      foo = Foo.new
      bar = Bar.new
      bar.set_foo(foo)

Without modification, this code will cause a segmentation fault. When
the Ruby ``foo`` object goes out of scope, it will free the underlying
C++ ``foo`` object. However, when the Ruby bar object goes out of scope,
it will call the C++ bar destructor which will also free the C++ ``foo``
object. The problem is that object ownership is transferred from the
Ruby object to the C++ object when the ``set_foo`` method is called.
This can be done by using the special DISOWN type map, which was added
to the Ruby bindings in SWIG-1.3.26.

Thus, a correct SWIG interface file correct mapping for these classes
is:

.. container:: code

   ::

      /* File RubyOwnershipExample.i */

      %module RubyOwnershipExample

      %{
      #include "RubyOwnershipExample.h"
      %}

      class Foo
      {
      public:
        Foo();
        ~Foo();
      };

      class Bar
      {
        Foo *foo_;
      public:
        Bar();
        ~Bar();
        Foo* get_foo();

        %newobject get_new_foo;
        Foo* get_new_foo();

        %apply SWIGTYPE *DISOWN {Foo *foo};
        void set_foo(Foo *foo);
        %clear Foo *foo;
      };

This code can be seen in swig/examples/ruby/tracking.

Object Tracking
~~~~~~~~~~~~~~~~~~~~~~~

The remaining parts of this section will use the class library shown
below to illustrate different memory management techniques. The class
library models a zoo and the animals it contains.

.. container:: code

   ::

      %module zoo

      %{
      #include <string>
      #include <vector>

      #include "zoo.h"
      %}

      class Animal
      {
      private:
        typedef std::vector<Animal*> AnimalsType;
        typedef AnimalsType::iterator IterType;
      protected:
        AnimalsType animals;
      protected:
        std::string name_;
      public:
        // Construct an animal with this name
        Animal(const char* name) : name_(name) {}
       
        // Return the animal's name
        const char* get_name() const { return name.c_str(); }
      };

      class Zoo
      {
      protected:
       std::vector<Animal *> animals;
       
      public:
        // Construct an empty zoo
        Zoo() {}
        
        /* Create a new animal. */
        static Animal* Zoo::create_animal(const char* name) {
          return new Animal(name);
        }
       
        // Add a new animal to the zoo
        void add_animal(Animal* animal) {
          animals.push_back(animal); 
        }
       
        Animal* remove_animal(size_t i) {
          Animal* result = this->animals[i];
          IterType iter = this->animals.begin();
          std::advance(iter, i);
          this->animals.erase(iter);
         
          return result;
        }
        
        // Return the number of animals in the zoo
        size_t get_num_animals() const {
          return animals.size(); 
        }
        
        // Return a pointer to the ith animal
        Animal* get_animal(size_t i) const {
          return animals[i]; 
        }
      };

Let's say you SWIG this code and then run IRB:

.. container:: code targetlang

   ::

      $ irb
      irb(main):001:0> require 'example'
      => true

      irb(main):002:0> tiger1 = Example::Animal.new("tiger1")
      => #<Example::Animal:0x2be3820>

      irb(main):004:0> tiger1.get_name()
      => "tiger1"

      irb(main):003:0> zoo = Example::Zoo.new()
      => #<Example::Zoo:0x2be0a60>

      irb(main):006:0> zoo.add_animal(tiger)
      => nil

      irb(main):007:0> zoo.get_num_animals()
      => 1

      irb(main):007:0> tiger2 = zoo.remove_animal(0)
      => #<Example::Animal:0x2bd4a18>

      irb(main):008:0> tiger2.get_name()
      => "tiger1"

      irb(main):009:0> tiger1.equal?(tiger2)
      => false

Pay particular attention to the code ``tiger1.equal?(tiger2)``. Note
that the two Ruby objects are not the same - but they reference the same
underlying C++ object. This can cause problems. For example:

.. container:: code targetlang

   ::

      irb(main):010:0> tiger1 = nil
      => nil

      irb(main):011:0> GC.start
      => nil

      irb(main):012:0> tiger2.get_name()
      (irb):12: [BUG] Segmentation fault

After the garbage collector runs, as a result of our call to
``GC.start``, calling\ ``tiger2.get_name()`` causes a segmentation
fault. The problem is that when ``tiger1`` is garbage collected, it
frees the underlying C++ object. Thus, when ``tiger2`` calls the
``get_name()`` method it invokes it on a destroyed object.

This problem can be avoided if SWIG enforces a one-to-one mapping
between Ruby objects and C++ classes. This can be done via the use of
the ``%trackobjects`` functionality available in SWIG-1.3.26. and later.

When the ``%trackobjects`` is turned on, SWIG automatically keeps track
of mappings between C++ objects and Ruby objects. Note that enabling
object tracking causes a slight performance degradation. Test results
show this degradation to be about 3% to 5% when creating and destroying
100,000 animals in a row.

Since ``%trackobjects`` is implemented as a ``%feature``, it uses the
same name matching rules as other kinds of features (see the chapter on
`"Customization Features" <Customization.html#Customization>`__) . Thus
it can be applied on a class-by-class basis if needed. To fix the
example above:

.. container:: code

   ::

      %module example

      %{
      #include "example.h"
      %}

      /* Tell SWIG that create_animal creates a new object */
      %newobject Zoo::create_animal;

      /* Tell SWIG to keep track of mappings between C/C++ structs/classes. */
      %trackobjects;

      %include "example.h"

When this code runs we see:

.. container:: code targetlang

   ::

      $ irb
      irb(main):001:0> require 'example'
      => true

      irb(main):002:0> tiger1 = Example::Animal.new("tiger1")
      => #<Example::Animal:0x2be37d8>

      irb(main):003:0> zoo = Example::Zoo.new()
      => #<Example::Zoo:0x2be0a18>

      irb(main):004:0> zoo.add_animal(tiger1)
      => nil

      irb(main):006:0> tiger2 = zoo.remove_animal(0)
      => #<Example::Animal:0x2be37d8>

      irb(main):007:0> tiger1.equal?(tiger2)
      => true

      irb(main):008:0> tiger1 = nil
      => nil

      irb(main):009:0> GC.start
      => nil

      irb(main):010:0> tiger.get_name()
      => "tiger1"
      irb(main):011:0>

For those who are interested, object tracking is implemented by storing
Ruby objects in a hash table and keying them on C++ pointers. The
underlying API is:

.. container:: code

   ::

      static void SWIG_RubyAddTracking(void* ptr, VALUE object);
      static VALUE SWIG_RubyInstanceFor(void* ptr) ;
      static void SWIG_RubyRemoveTracking(void* ptr);
      static void SWIG_RubyUnlinkObjects(void* ptr);

When an object is created, SWIG will automatically call the
``SWIG_RubyAddTracking`` method. Similarly, when an object is deleted,
SWIG will call the ``SWIG_RubyRemoveTracking``. When an object is
returned to Ruby from C++, SWIG will use the ``SWIG_RubyInstanceFor``
method to ensure a one-to-one mapping from Ruby to C++ objects. Last,
the ``RubyUnlinkObjects`` method unlinks a Ruby object from its
underlying C++ object.

In general, you will only need to use the ``SWIG_RubyInstanceFor``,
which is required for implementing mark functions as shown below.
However, if you implement your own free functions (see below) you may
also have to call the ``SWIG_RubyRemoveTracking`` and
``RubyUnlinkObjects`` methods.

Mark Functions
~~~~~~~~~~~~~~~~~~~~~~

With a bit more testing, we see that our class library still has
problems. For example:

.. container:: targetlang

   ::

      $ irb
      irb(main):001:0> require 'example'
      => true

      irb(main):002:0> tiger1 = Example::Animal.new("tiger1")
      => #<Example::Animal:0x2bea6a8>

      irb(main):003:0> zoo = Example::Zoo.new()
      => #<Example::Zoo:0x2be7960>

      irb(main):004:0> zoo.add_animal(tiger1)
      => nil

      irb(main):007:0> tiger1 = nil
      => nil

      irb(main):007:0> GC.start
      => nil

      irb(main):005:0> tiger2 = zoo.get_animal(0)
      (irb):12: [BUG] Segmentation fault

The problem is that Ruby does not know that the ``zoo`` object contains
a reference to a Ruby object. Thus, when Ruby garbage collects
``tiger1`` it frees the underlying C++ object.

This can be fixed by implementing a ``mark`` function as described above
in the `Mark and Sweep Garbage Collector <Ruby.html#Ruby_nn52>`__
section. You can specify a mark function by using the ``%markfunc``
directive. Since the ``%markfunc`` directive is implemented using
SWIG's' "features" mechanism it uses the same name matching rules as
other kinds of features (see the chapter on `"Customization
Features" <Customization.html#Customization>`__ for more details).

A ``mark`` function takes a single argument, which is a pointer to the
C++ object being marked; it should, in turn, call ``rb_gc_mark()`` for
any instances that are reachable from the current object. The mark
function for our ``Zoo`` class should therefore loop over all of the C++
animal objects in the zoo object, look up their Ruby object equivalent,
and then call ``rb_gc_mark()``. One possible implementation is:

.. container:: code

   ::

      %module example

      %{
      #include "example.h"
      %}

      /* Keep track of mappings between C/C++ structs/classes
       and Ruby objects so we can implement a mark function. */
      %trackobjects;

      /* Specify the mark function */
      %markfunc Zoo "mark_Zoo";

      %include "example.h"

      %header %{

      static void mark_Zoo(void* ptr) {
        Zoo* zoo = (Zoo*) ptr;
       
        /* Loop over each object and tell the garbage collector
        that we are holding a reference to them. */
        int count = zoo->get_num_animals();
       
        for(int i = 0; i < count; ++i) {
          Animal* animal = zoo->get_animal(i);
          VALUE object = SWIG_RubyInstanceFor(animal);
       
          if (object != Qnil) {
            rb_gc_mark(object);
          }
        }
      }
      %}

Note the ``mark`` function is dependent on the ``SWIG_RUBY_InstanceFor``
method, and thus requires that ``%trackobjects`` is enabled. For more
information, please refer to the ruby_track_objects.i test case in the
SWIG test suite.

When this code is compiled we now see:

.. container:: targetlang

   ::

      $ irb
      irb(main):002:0> tiger1=Example::Animal.new("tiger1")
      => #<Example::Animal:0x2be3bf8>

      irb(main):003:0> Example::Zoo.new()
      => #<Example::Zoo:0x2be1780>

      irb(main):004:0> zoo = Example::Zoo.new()
      => #<Example::Zoo:0x2bde9c0>

      irb(main):005:0> zoo.add_animal(tiger1)
      => nil

      irb(main):009:0> tiger1 = nil
      => nil

      irb(main):010:0> GC.start
      => nil
      irb(main):014:0> tiger2 = zoo.get_animal(0)
      => #<Example::Animal:0x2be3bf8>

      irb(main):015:0> tiger2.get_name()
      => "tiger1"
      irb(main):016:0>

This code can be seen in swig/examples/ruby/mark_function.

Free Functions
~~~~~~~~~~~~~~~~~~~~~~

By default, SWIG creates a "free" function that is called when a Ruby
object is garbage collected. The free function simply calls the C++
object's destructor.

However, sometimes an appropriate destructor does not exist or special
processing needs to be performed before the destructor is called.
Therefore, SWIG allows you to manually specify a "free" function via the
use of the ``%freefunc`` directive. The ``%freefunc`` directive is
implemented using SWIG's' "features" mechanism and so the same name
matching rules used for other kinds of features apply (see the chapter
on `"Customization Features" <Customization.html#Customization>`__) for
more details).

IMPORTANT ! - If you define your own free function, then you must ensure
that you call the underlying C++ object's destructor. In addition, if
object tracking is activated for the object's class, you must also call
the ``SWIG_RubyRemoveTracking`` function (of course call this before you
destroy the C++ object). Note that it is harmless to call this method if
object tracking if off so it is advised to always call it.

Note there is a subtle interaction between object ownership and free
functions. A custom defined free function will only be called if the
Ruby object owns the underlying C++ object. This also to Ruby objects
which are created, but then transfer ownership to C++ objects via the
use of the ``disown`` typemap described above.

To show how to use the ``%freefunc`` directive, let's slightly change
our example. Assume that the zoo object is responsible for freeing any
animal that it contains. This means that the ``Zoo::add_animal``
function should be marked with a ``DISOWN`` typemap and the destructor
should be updated as below:

.. container:: code

   ::

      Zoo::~Zoo() {
        IterType iter = this->animals.begin();
        IterType end = this->animals.end();
       
        for(iter; iter != end; ++iter) {
          Animal* animal = *iter;
          delete animal;
        }
      }

When we use these objects in IRB we see:

.. container:: code targetlang

   .. code:: targetlang

      $irb
      irb(main):002:0> require 'example'
      => true

      irb(main):003:0> zoo = Example::Zoo.new()
      => #<Example::Zoo:0x2be0fe8>

      irb(main):005:0> tiger1 = Example::Animal.new("tiger1")
      => #<Example::Animal:0x2bda760>

      irb(main):006:0> zoo.add_animal(tiger1)
      => nil

      irb(main):007:0> zoo = nil
      => nil

      irb(main):008:0> GC.start
      => nil

      irb(main):009:0> tiger1.get_name()
      (irb):12: [BUG] Segmentation fault

The error happens because the C++ ``animal`` object is freed when the
``zoo`` object is freed. Although this error is unavoidable, we can at
least prevent the segmentation fault. To do this requires enabling
object tracking and implementing a custom free function that calls the
``SWIG_RubyUnlinkObjects`` function for each animal object that is
destroyed. The ``SWIG_RubyUnlinkObjects`` function notifies SWIG that a
Ruby object's underlying C++ object is no longer valid. Once notified,
SWIG will intercept any calls from the existing Ruby object to the
destroyed C++ object and raise an exception.

.. container:: code

   ::

      %module example

      %{
      #include "example.h"
      %}

      /* Specify that ownership is transferred to the zoo when calling add_animal */
      %apply SWIGTYPE *DISOWN { Animal* animal };

      /* Track objects */
      %trackobjects;

      /* Specify the mark function */
      %freefunc Zoo "free_Zoo";

      %include "example.h"

      %header %{
        static void free_Zoo(void* ptr) {
          Zoo* zoo = (Zoo*) ptr;

          /* Loop over each animal */
          int count = zoo->get_num_animals();

          for(int i = 0; i < count; ++i) {
            /* Get an animal */
            Animal* animal = zoo->get_animal(i);

            /* Unlink the Ruby object from the C++ object */
            SWIG_RubyUnlinkObjects(animal);

            /* Now remove the tracking for this animal */
            SWIG_RubyRemoveTracking(animal);
          }

          /* Now call SWIG_RubyRemoveTracking for the zoo */
          SWIG_RubyRemoveTracking(ptr);
          /* Now free the zoo which will free the animals it contains */
          delete zoo;
        }
      %} 

Now when we use these objects in IRB we see:

.. container:: code targetlang

   ::

      $irb
      irb(main):002:0> require 'example'
      => true

      irb(main):003:0> zoo = Example::Zoo.new()
      => #<Example::Zoo:0x2be0fe8>

      irb(main):005:0> tiger1 = Example::Animal.new("tiger1")
      => #<Example::Animal:0x2bda760>

      irb(main):006:0> zoo.add_animal(tiger1)
      => nil

      irb(main):007:0> zoo = nil
      => nil

      irb(main):008:0> GC.start
      => nil

      irb(main):009:0> tiger1.get_name()
      RuntimeError: This Animal * already released
       from (irb):10:in `get_name'
       from (irb):10
      irb(main):011:0>

Notice that SWIG can now detect the underlying C++ object has been
freed, and thus raises a runtime exception.

This code can be seen in swig/examples/ruby/free_function.

Embedded Ruby and the C++ Stack
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As has been said, the Ruby GC runs and marks objects before its sweep
phase. When the garbage collector is called, it will also try to mark
any Ruby objects (VALUE) it finds in the machine registers and in the
C++ stack.

The stack is basically the history of the functions that have been
called and also contains local variables, such as the ones you define
whenever you do inside a function:

.. container:: diagram

   VALUE obj;

For ruby to determine where its stack space begins, during
initialization a normal Ruby interpreter will call the ruby_init()
function which in turn will call a function called Init_stack or
similar. This function will store a pointer to the location where the
stack points at that point in time.

ruby_init() is presumed to always be called within the main() function
of your program and whenever the GC is called, ruby will assume that the
memory between the current location in memory and the pointer that was
stored previously represents the stack, which may contain local (and
temporary) VALUE ruby objects. Ruby will then be careful not to remove
any of those objects in that location.

So far so good. For a normal Ruby session, all the above is completely
transparent and magic to the extensions developer.

However, with an embedded Ruby, it may not always be possible to modify
main() to make sure ruby_init() is called there. As such, ruby_init()
will likely end up being called from within some other function. This
can lead Ruby to measure incorrectly where the stack begins and can
result in Ruby incorrectly collecting those temporary VALUE objects that
are created once another function is called. The end result: random
crashes and segmentation faults.

This problem will often be seen in director functions that are used for
callbacks, for example.

To solve the problem, SWIG can now generate code with director functions
containing the optional macros SWIG_INIT_STACK and SWIG_RELEASE_STACK.
These macros will try to force Ruby to reinitialize the beginning of the
stack the first time a director function is called. This will lead Ruby
to measure and not collect any VALUE objects defined from that point on.

To mark functions to either reset the ruby stack or not, you can use:

.. container:: code

   ::

      %initstack Class::memberfunction;   // only re-init the stack in this director method
      %ignorestack Class::memberfunction; // do not re-init the stack in this director method
      %initstack Class;                   // init the stack on all the methods of this class
      %initstack;                         // all director functions will re-init the stack

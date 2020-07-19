SWIG and Chicken
===================

This chapter describes SWIG's support of CHICKEN. CHICKEN is a
Scheme-to-C compiler supporting most of the language features as defined
in the *Revised^5 Report on Scheme*. Its main attributes are that it

#. generates portable C code
#. includes a customizable interpreter
#. links to C libraries with a simple Foreign Function Interface
#. supports full tail-recursion and first-class continuations

When confronted with a large C library, CHICKEN users can use SWIG to
generate CHICKEN wrappers for the C library. However, the real
advantages of using SWIG with CHICKEN are its **support for C++** --
object-oriented code is difficult to wrap by hand in CHICKEN -- and its
**typed pointer representation**, essential for C and C++ libraries
involving structures or classes.

Preliminaries
------------------

CHICKEN support was introduced to SWIG in version 1.3.18. SWIG relies on
some recent additions to CHICKEN, which are only present in releases of
CHICKEN with version number **greater than or equal to 1.89**. To use a
chicken version between 1.40 and 1.89, see the `Garbage
collection <#Chicken_collection>`__ section below.

You may want to look at any of the examples in Examples/chicken/
directory for the basic steps to run SWIG CHICKEN.

Running SWIG in C mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To run SWIG CHICKEN in C mode, use the -chicken option.

.. container:: shell

   ::

      % swig -chicken example.i

To allow the wrapper to take advantage of future CHICKEN code generation
improvements, part of the wrapper is direct CHICKEN function calls
(``example_wrap.c``) and part is CHICKEN Scheme (``example.scm``). The
basic Scheme code must be compiled to C using your system's CHICKEN
compiler or both files can be compiled directly using the much simpler
``csc``.

.. container:: shell

   ::

      % chicken example.scm -output-file oexample.c

So for the C mode of SWIG CHICKEN, ``example_wrap.c`` and ``oexample.c``
are the files that must be compiled to object files and linked into your
project.

.. _running-swig-in-c-mode-1:

Running SWIG in C++ mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To run SWIG CHICKEN in C++ mode, use the -chicken -c++ option.

.. container:: shell

   ::

      % swig -chicken -c++ example.i

This will generate ``example_wrap.cxx`` and ``example.scm``. The basic
Scheme code must be compiled to C using your system's CHICKEN compiler
or both files can be compiled directly using the much simpler ``csc``.

.. container:: shell

   ::

      % chicken example.scm -output-file oexample.c

So for the C++ mode of SWIG CHICKEN, ``example_wrap.cxx`` and
``oexample.c`` are the files that must be compiled to object files and
linked into your project.

Code Generation
--------------------

Naming Conventions
~~~~~~~~~~~~~~~~~~~~~~~~~

Given a C variable, function or constant declaration named ``Foo_Bar``,
the declaration will be available in CHICKEN as an identifier ending
with ``Foo-Bar``. That is, an underscore is converted to a dash.

You may control what the CHICKEN identifier will be by using the
``%rename`` SWIG directive in the SWIG interface file.

Modules
~~~~~~~~~~~~~~

The name of the module must be declared one of two ways:

-  Placing ``%module example`` in the SWIG interface file.
-  Using ``-module example`` on the SWIG command line.

The generated example.scm file then exports
``(declare (unit modulename))``. If you do not want SWIG to export the
``(declare (unit modulename))``, pass the -nounit option to SWIG.

CHICKEN will be able to access the module using the
``(declare         (uses modulename))`` CHICKEN Scheme form.

Constants and Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Constants may be created using any of the four constructs in the
interface file:

#. ``#define MYCONSTANT1 ...``
#. ``%constant int MYCONSTANT2 = ...``
#. ``const int MYCONSTANT3 = ...``
#. ``enum { MYCONSTANT4  = ... };``

In all cases, the constants may be accessed from within CHICKEN using
the form ``(MYCONSTANT1)``; that is, the constants may be accessed using
the read-only parameter form.

Variables are accessed using the full parameter form. For example, to
set the C variable "int my_variable;", use the Scheme form
``(my-variable 2345)``. To get the C variable, use ``(my-variable)``.

The ``%feature("constasvar")`` can be applied to any constant or
immutable variable. Instead of exporting the constant as a function that
must be called, the constant will appear as a scheme variable. This
causes the generated .scm file to just contain the code
``(set! MYCONSTANT1 (MYCONSTANT1))``. See `Features and the %feature
directive <Customization.html#Customization_features>`__ for info on how
to apply the %feature.

Functions
~~~~~~~~~~~~~~~~

C functions declared in the SWIG interface file will have corresponding
CHICKEN Scheme procedures. For example, the C function "int sqrt(double
x);" will be available using the Scheme form ``(sqrt 2345.0)``. A
``void`` return value will give C_SCHEME_UNDEFINED as a result.

A function may return more than one value by using the ``OUTPUT``
specifier (see Lib/chicken/typemaps.i). They will be returned as
multiple values using ``(values)`` if there is more than one result
(that is, a non-void return value and at least one argout parameter, or
a void return value and at least two argout parameters). The return
values can then be accessed with ``(call-with-values)``.

Exceptions
~~~~~~~~~~~~~~~~~

The SWIG chicken module has support for exceptions thrown from C or C++
code to be caught in scheme. See `Exception handling with
%exception <Customization.html#Customization_exception>`__ for more
information about declaring exceptions in the interface file.

Chicken supports both the ``SWIG_exception(int code, const char *msg)``
interface as well as a ``SWIG_ThrowException(C_word val)`` function for
throwing exceptions from inside the %exception blocks.
``SWIG_exception`` will throw a list consisting of the code (as an
integer) and the message. Both of these will throw an exception using
``(abort)``, which can be handled by ``(handle-exceptions)``. See the
Chicken manual on Exceptions and
`SFRI-12 <http://srfi.schemers.org/srfi-12/srfi-12.html>`__. Since the
exception values are thrown directly, if ``(condition-case)`` is used to
catch an exception the exception will come through in the ``val ()``
case.

The following simple module

.. container:: code

   ::

      %module exception_test

      %inline %{
        void test_throw(int i) throws (int) { 
          if (i == 1) throw 15; 
        }
      %}

could be run with

.. container:: targetlang

   ::

      (handle-exceptions exvar 
        (if (= exvar 15)
          (print "Correct!") 
          (print "Threw something else " exvar))
        (test-throw 1))

TinyCLOS
-------------

The author of TinyCLOS, Gregor Kiczales, describes TinyCLOS as: "Tiny
CLOS is a Scheme implementation of a 'kernelized' CLOS, with a
metaobject protocol. The implementation is even simpler than the simple
CLOS found in 'The Art of the Metaobject Protocol', weighing in at
around 850 lines of code, including (some) comments and documentation."

Almost all good Scheme books describe how to use metaobjects and generic
procedures to implement an object-oriented Scheme system. Please consult
a Scheme book if you are unfamiliar with the concept.

CHICKEN has a modified version of TinyCLOS, which SWIG CHICKEN uses if
the -proxy argument is given. If -proxy is passed, then the generated
example.scm file will contain TinyCLOS class definitions. A class named
Foo is declared as <Foo>, and each member variable is allocated a slot.
Member functions are exported as generic functions.

Primitive symbols and functions (the interface that would be presented
if -proxy was not passed) are hidden and no longer accessible. If the
-unhideprimitive command line argument is passed to SWIG, then the
primitive symbols will be available, but each will be prefixed by the
string "primitive:"

The exported symbol names can be controlled with the -closprefix and
-useclassprefix arguments. If -useclassprefix is passed to SWIG, every
member function will be generated with the class name as a prefix. If
the -closprefix mymod: argument is passed to SWIG, then the exported
functions will be prefixed by the string "mymod:". If -useclassprefix is
passed, -closprefix is ignored.

Linkage
------------

Please refer to *CHICKEN - A practical and portable Scheme system -
User's manual* for detailed help on how to link object files to create a
CHICKEN Scheme program. Briefly, to link object files, be sure to add
:literal:`\`chicken-config       -extra-libs -libs\`` or
:literal:`\`chicken-config -shared       -extra-libs -libs\``\ to your
linker options. Use the ``-shared`` option if you want to create a
dynamically loadable module. You might also want to use the much simpler
``csc`` or ``csc.bat``.

Each scheme file that is generated by SWIG contains
``(declare (uses modname))``. This means that to load the module from
scheme code, the code must include ``(declare (uses modname))``.

Static binary or shared library linked at compile time
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We can easily use csc to build a static binary.

.. container:: shell

   ::

      $ swig -chicken example.i
      $ csc -v example.scm example_impl.c example_wrap.c test_script.scm -o example
      $ ./example

Similar to the above, any number of ``module.scm`` files could be
compiled into a shared library, and then that shared library linked when
compiling the main application.

.. container:: shell

   ::

      $ swig -chicken example.i
      $ csc -sv example.scm example_wrap.c example_impl.c -o example.so

The ``example.so`` file can then linked with ``test_script.scm`` when it
is compiled, in which case ``test_script.scm`` must have
``(declare (uses example))``. Multiple SWIG modules could have been
linked into ``example.so`` and each one accessed with a
``(declare (uses ... ))``.

.. container:: shell

   ::

      $ csc -v test_script.scm -lexample

An alternative is that the test_script.scm can have the code
``(load-library 'example "example.so")``, in which case the test script
does not need to be linked with example.so. The test_script.scm file can
then be run with ``csi``.

Building chicken extension libraries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Building a shared library like in the above section only works if the
library is linked at compile time with a script containing
``(declare (uses ...))`` or is loaded explicitly with
``(load-library 'example "example.so")``. It is not the format that
CHICKEN expects for extension libraries and eggs. The problem is the
``(declare (unit modname))`` inside the ``modname.scm`` file. There are
two possible solutions to this.

First, SWIG accepts a ``-nounit`` argument, in which case the
``(declare (unit modname))`` is not generated. Then, the ``modname.scm``
and ``modname_wrap.c`` files **must** be compiled into their own shared
library.

.. container:: shell

   ::

      $ csc -sv modname.scm modname_wrap.c modname_impl.c -o modname.so

This library can then be loaded by scheme code with the
``(require 'modname)`` function. See the Loading-extension-libraries in
the eval unit inside the CHICKEN manual for more information.

Another alternative is to run SWIG normally and create a scheme file
that contains ``(declare (uses modname))`` and then compile that file
into the shared library as well. For example, inside the
``mod_load.scm`` file,

.. container:: targetlang

   ::

      (declare (uses mod1))
      (declare (uses mod2))

Which would then be compiled with

.. container:: shell

   ::

      $ swig -chicken mod1.i
      $ swig -chicken mod2.i
      $ csc -sv mod_load.scm mod1.scm mod2.scm mod1_wrap.c mod2_wrap.c mod1_impl.c mod2_impl.c -o mod.so

Then the extension library can be loaded with ``(require 'mod)``. As we
can see here, ``mod_load.scm`` contains the code that gets executed when
the module is loaded. All this code does is load both mod1 and mod2. As
we can see, this technique is more useful when you want to combine a few
SWIG modules into one chicken extension library, especially if modules
are related by ``%import``

In either method, the files that are compiled into the shared library
could also be packaged into an egg. The ``mod1_wrap.c`` and
``mod2_wrap.c`` files that are created by SWIG are stand alone and do
not need SWIG to be installed to be compiled. Thus the egg could be
distributed and used by anyone, even if SWIG is not installed.

See the ``Examples/chicken/egg`` directory in the SWIG source for an
example that builds two eggs, one using the first method and one using
the second method.

Linking multiple SWIG modules with TinyCLOS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Linking together multiple modules that share type information using the
``%import`` directive while also using ``-proxy`` is more complicated.
For example, if ``mod2.i`` imports ``mod1.i``, then the ``mod2.scm``
file contains references to symbols declared in ``mod1.scm``, and thus a
``(declare (uses mod1))`` or ``(require 'mod1)`` must be exported to the
top of ``mod2.scm``. By default, when SWIG encounters an
``%import "modname.i"`` directive, it exports
``(declare (uses modname))`` into the scm file. This works fine unless
mod1 was compiled with the ``-nounit`` argument or was compiled into an
extension library with other modules under a different name.

One option is to override the automatic generation of
``(declare (uses mod1))`` by passing the ``-noclosuses`` option to SWIG
when compiling ``mod2.i``. SWIG then provides the
``%insert(closprefix) %{ %}`` directive. Any scheme code inside that
directive is inserted into the generated .scm file, and if ``mod1`` was
compiled with ``-nounit``, the directive should contain
``(require 'mod1)``. This option allows for mixed loading as well, where
some modules are imported with ``(declare (uses modname))`` (which means
they were compiled without -nounit) and some are imported with
``(require 'modname)``.

The other option is to use the second idea in the above section. Compile
all the modules normally, without any ``%insert(closprefix)``,
``-nounit``, or ``-noclosuses``. Then the modules will import each other
correctly with ``(declare (uses ...))``. To create an extension library
or an egg, just create a ``module_load.scm`` file that
``(declare (uses ...))`` all the modules.

Typemaps
-------------

The Chicken module handles all types via typemaps. This information is
read from ``Lib/chicken/typemaps.i`` and ``Lib/chicken/chicken.swg``.

Pointers
-------------

For pointer types, SWIG uses CHICKEN tagged pointers. A tagged pointer
is an ordinary CHICKEN pointer with an extra slot for a void \*. With
SWIG CHICKEN, this void \* is a pointer to a type-info structure. So
each pointer used as input or output from the SWIG-generated CHICKEN
wrappers will have type information attached to it. This will let the
wrappers correctly determine which method should be called according to
the object type hierarchy exposed in the SWIG interface files.

To construct a Scheme object from a C pointer, the wrapper code calls
the function
``SWIG_NewPointerObj(void *ptr, swig_type_info *type, int owner)``, The
function that calls ``SWIG_NewPointerObj`` must have a variable declared
``C_word *known_space = C_alloc(C_SIZEOF_SWIG_POINTER);`` It is ok to
call ``SWIG_NewPointerObj`` more than once, just make sure known_space
has enough space for all the created pointers.

To get the pointer represented by a CHICKEN tagged pointer, the wrapper
code calls the function
``SWIG_ConvertPtr(C_word s, void **result, swig_type_info *type, int flags)``,
passing a pointer to a struct representing the expected pointer type.
flags is either zero or SWIG_POINTER_DISOWN (see below).

Garbage collection
~~~~~~~~~~~~~~~~~~~~~~~~~

If the owner flag passed to ``SWIG_NewPointerObj`` is 1,
``NewPointerObj`` will add a finalizer to the type which will call the
destructor or delete method of that type. The destructor and delete
functions are no longer exported for use in scheme code, instead SWIG
and chicken manage pointers. In situations where SWIG knows that a
function is returning a type that should be garbage collected, SWIG will
automatically set the owner flag to 1. For other functions, the
``%newobject`` directive must be specified for functions whose return
values should be garbage collected. See `Object ownership and
%newobject <Customization.html#Customization_ownership>`__ for more
information.

In situations where a C or C++ function will assume ownership of a
pointer, and thus chicken should no longer garbage collect it, SWIG
provides the ``DISOWN`` input typemap. After applying this typemap (see
the `Typemaps chapter <Typemaps.html#Typemaps>`__ for more information
on how to apply typemaps), any pointer that gets passed in will no
longer be garbage collected. An object is disowned by passing the
``SWIG_POINTER_DISOWN`` flag to ``SWIG_ConvertPtr``. **Warning:** Since
the lifetime of the object is now controlled by the underlying code, the
object might get deleted while the scheme code still holds a pointer to
it. Further use of this pointer can lead to a crash.

Adding a finalizer function from C code was added to chicken in the 1.89
release, so garbage collection does not work for chicken versions below
If you would like the SWIG generated code to work with chicken
to 1.89, pass the ``-nocollection`` argument to SWIG. This will not
export code inside the \_wrap.c file to register finalizers, and will
then export destructor functions which must be called manually.

Unsupported features and known problems
--------------------------------------------

-  No director support.
-  No support for c++ standard types like std::vector.
-  The TinyCLOS wrappers for overloaded functions will not work
   correctly when using
   `%feature(compactdefaultargs) <SWIGPlus.html#SWIGPlus_default_args>`__.

TinyCLOS problems with Chicken version <= 1.92
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In Chicken versions equal to or below 1.92, TinyCLOS has a limitation
such that generic methods do not properly work on methods with different
number of specializers: TinyCLOS assumes that every method added to a
generic function will have the same number of specializers. SWIG
generates functions with different lengths of specializers when C/C++
functions are overloaded. For example, the code

.. container:: code

   ::

      class Foo {};
      int foo(int a, Foo *b);
      int foo(int a);

will produce scheme code

.. container:: targetlang

   ::

      (define-method (foo (arg0 <top>) (arg1 <Foo>)) (call primitive function))
      (define-method (foo (arg0 <top>)) (call primitive function))

Using unpatched TinyCLOS, the second ``(define-method)`` will replace
the first one, so calling ``(foo 3 f)`` will produce an error.

There are three solutions to this. The easist is to upgrade to the
latest Chicken version. Otherwise, the file
``Lib/chicken/tinyclos-multi-generic.patch`` in the SWIG source contains
a patch against tinyclos.scm inside the 1.92 chicken source to add
support into TinyCLOS for multi-argument generics. (This patch was
accepted into Chicken) This requires chicken to be rebuilt and custom
install of chicken. An alternative is the
``Lib/chicken/multi-generic.scm`` file in the SWIG source. This file can
be loaded after TinyCLOS is loaded, and it will override some functions
inside TinyCLOS to correctly support multi-argument generics. Please see
the comments at the top of both files for more information.

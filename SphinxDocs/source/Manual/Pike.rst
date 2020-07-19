SWIG and Pike
================

This chapter describes SWIG support for Pike. As of this writing, the
SWIG Pike module is still under development and is not considered ready
for prime time. The Pike module is being developed against the Pike
release and may not be compatible with previous versions of Pike.

| This chapter covers most SWIG features, but certain low-level details
  are covered in less depth than in earlier chapters. At the very least,
  make sure you read the "`SWIG Basics <SWIG.html#SWIG>`__" chapter.

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

      int fact(int n);

To build a C extension module for Pike, run SWIG using the ``-pike``
option :

.. container:: code

   ::

      $ swig -pike example.i

If you're building a C++ extension, be sure to add the ``-c++`` option:

.. container:: code

   ::

      $ swig -c++ -pike example.i

This creates a single source file named ``example_wrap.c`` (or
``example_wrap.cxx``, if you ran SWIG with the ``-c++`` option). The
SWIG-generated source file contains the low-level wrappers that need to
be compiled and linked with the rest of your C/C++ application to create
an extension module.

The name of the wrapper file is derived from the name of the input file.
For example, if the input file is ``example.i``, the name of the wrapper
file is ``example_wrap.c``. To change this, you can use the ``-o``
option:

.. container:: code

   ::

      $ swig -pike -o pseudonym.c example.i

Getting the right header files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to compile the C/C++ wrappers, the compiler needs to know the
path to the Pike header files. These files are usually contained in a
directory such as

.. container:: code

   ::

      /usr/local/pike/7.4.10/include/pike

There doesn't seem to be any way to get Pike itself to reveal the
location of these files, so you may need to hunt around for them. You're
looking for files with the names ``global.h``, ``program.h`` and so on.

Using your module
~~~~~~~~~~~~~~~~~~~~~~~~

To use your module, simply use Pike's ``import`` statement:

.. container:: code

   ::

      $ pike
      Pike v7.4 release 10 running Hilfe v3.5 (Incremental Pike Frontend)
      > import example;
      > fact(4);
      (1) Result: 24

Basic C/C++ Mapping
------------------------

Modules
~~~~~~~~~~~~~~

All of the code for a given SWIG module is wrapped into a single Pike
module. Since the name of the shared library that implements your module
ultimately determines the module's name (as far as Pike is concerned),
SWIG's ``%module`` directive doesn't really have any significance.

Functions
~~~~~~~~~~~~~~~~

Global functions are wrapped as new Pike built-in functions. For
example,

.. container:: code

   ::

      %module example

      int fact(int n);

creates a new built-in function ``example.fact(n)`` that works exactly
as you'd expect it to:

.. container:: code

   ::

      > import example;
      > fact(4);
      (1) Result: 24

Global variables
~~~~~~~~~~~~~~~~~~~~~~~

Global variables are currently wrapped as a pair of functions, one to
get the current value of the variable and another to set it. For
example, the declaration

.. container:: code

   ::

      %module example

      double Foo;

will result in two functions, ``Foo_get()`` and ``Foo_set()``:

.. container:: code

   ::

      > import example;
      > Foo_get();
      (1) Result: 3.000000
      > Foo_set(3.14159);
      (2) Result: 0
      > Foo_get();
      (3) Result: 3.141590

Constants and enumerated types
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enumerated types in C/C++ declarations are wrapped as Pike constants,
not as Pike enums.

Constructors and Destructors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Constructors are wrapped as ``create()`` methods, and destructors are
wrapped as ``destroy()`` methods, for Pike classes.

Static Members
~~~~~~~~~~~~~~~~~~~~~

Since Pike doesn't support static methods or data for Pike classes,
static member functions in your C++ classes are wrapped as regular
functions and static member variables are wrapped as pairs of functions
(one to get the value of the static member variable, and another to set
it). The names of these functions are prepended with the name of the
class. For example, given this C++ class declaration:

.. container:: code

   ::

      class Shape
      {
      public:
        static void print();
        static int nshapes;
      };

SWIG will generate a ``Shape_print()`` method that invokes the static
``Shape::print()`` member function, as well as a pair of methods,
``Shape_nshapes_get()`` and ``Shape_nshapes_set()``, to get and set the
value of ``Shape::nshapes``.

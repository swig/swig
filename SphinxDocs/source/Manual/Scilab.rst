SWIG and Scilab
==================

Scilab is a scientific software package for numerical computations
providing a powerful open computing environment for engineering and
scientific applications that is mostly compatible with MATLAB. More
information can be found at `www.scilab.org <http://www.scilab.org>`__.

This chapter explains how to use SWIG for Scilab. After this
introduction, you should be able to generate with SWIG a Scilab external
module from a C/C++ library.

Preliminaries
------------------

SWIG for Scilab supports Linux. Other operating systems haven't been
tested.

Scilab is supported from version 5.3.3 onwards. The forthcoming version
6, as of January 2015, is also supported.

SWIG for Scilab supports C language. C++ is partially supported. See `A
basic tour of C/C++ wrapping <#Scilab_wrapping>`__ for further details.

Running SWIG
-----------------

| Let's see how to use SWIG for Scilab on a small example.
| In this example we bind from C a function and a global variable into
  Scilab. The SWIG interface (stored in a file named ``example.i``), is
  the following:

.. container:: code

   ::

      %module example

      %inline %{
      double Foo = 3.0;

      int fact(int n) {
        if (n < 0) {
          return 0;
        }
        else if (n == 0) {
          return 1;
        }
        else {
          return n * fact(n-1);
        }
      }
      %}

Note: a code in an ``%inline`` section is both parsed and wrapped by
SWIG, and inserted as is in the wrapper source file.

Generating the module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The module is generated using the ``swig`` executable and its
``-scilab`` option.

.. container:: shell

   ::

      $ swig -scilab example.i

This command generates two files:

-  ``example_wrap.c``: a C source file containing the wrapping code and
   also here the wrapped code (the ``fact()`` and ``Foo`` definitions)
-  ``loader.sce``: a Scilab script used to load the module into Scilab

Note: if the following error is returned:

.. container:: shell

   ::

      :1: Error: Unable to find 'swig.swg'
      :3: Error: Unable to find 'scilab.swg'

it may be because the SWIG library is not found. Check the ``SWIG_LIB``
environment variable or your SWIG installation.

Note: SWIG for Scilab can work in two modes related to the way the
module is built, see the `Building modes <#Scilab_building_modes>`__
section for details. This example uses the ``builder`` mode.

The ``swig`` executable has several other command line options you can
use. See `Scilab command line options <#Scilab_running_swig_options>`__
for further details.

Building the module
~~~~~~~~~~~~~~~~~~~~~~~~~~

To be loaded in Scilab, the wrapper has to be built into a dynamic
module (or shared library).

The commands to compile and link the wrapper (with ``gcc``) into the
shared library ``libexample.so`` are:

.. container:: shell

   ::

      $ gcc -fPIC -c -I/usr/local/include/scilab example_wrap.c
      $ gcc -shared example_wrap.o -o libexample.so

Note: we supposed in this example that the path to the Scilab include
directory is ``/usr/local/include/scilab`` (which is the case in a
Debian environment), this should be changed for another environment.

Loading the module
~~~~~~~~~~~~~~~~~~~~~~~~~

Loading a module is done by running the loader script in Scilab:

.. container:: targetlang

   ::

      --> exec loader.sce

Scilab should output the following messages:

.. container:: targetlang

   ::

      Shared archive loaded.
      Link done.

which means that Scilab has successfully loaded the shared library. The
module functions and other symbols are now available in Scilab.

Using the module
~~~~~~~~~~~~~~~~~~~~~~~

In Scilab, the function ``fact()`` is simply called as following:

.. container:: targetlang

   ::

      --> fact(5)
      ans  =

          120.

For the ``Foo`` global variable, the accessors need to be used:

.. container:: targetlang

   ::

      --> Foo_get
      ans  =

          3.

      --> Foo_set(4);

      --> Foo_get
      ans  =

          4.

Note: for conciseness, we assume in the subsequent Scilab code examples
that the modules have been beforehand built and loaded in Scilab.

Scilab command line options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following table lists the Scilab specific command line options in
addition to the generic SWIG options:

..  list-table::
    :widths: 25 25
    :header-rows: 0

    *
     - ``-builder``
     - Generate the Scilab builder
       script
    *
      - ``-buildercflags <cflags>``
      - Add <cflags> to the builder
        compiler flags
    *
      - ``-builderldflags <ldflags>``
      - Add <ldlags> to the builder
        linker flags
    *
      - ``-buildersources <files>``
      - Add the (comma separated) files
        <files> to the builder sources
    *                                  
      - ``-builderverbositylevel <level>``
      - Set the build verbosity level to
        <level> (default 0: off, 2:high)
    *
      - ``-builderflagscript <file>``
      - Use the Scilab script <file> to
        configure the compiler and
        linker flags
    *
      - ``-gatewayxml <gateway_id>``
      - Generate the gateway XML with
        the given <gateway_id>
    *
      - ``-targetversion``
      - Generate for Scilab target
        (major) version

These options can be displayed with:

.. container:: shell

   ::

      $ swig -scilab -help

A basic tour of C/C++ wrapping
-----------------------------------

Overview
~~~~~~~~~~~~~~~

SWIG for Scilab provides only a low-level C interface for Scilab (see
`Scripting Languages <Scripting.html#Scripting>`__ for the general
approach to wrapping). This means that functions, structs, classes,
variables, etc... are interfaced through C functions. These C functions
are mapped as Scilab functions. There are a few exceptions, such as
constants and enumerations, which can be wrapped directly as Scilab
variables.

Identifiers
~~~~~~~~~~~~~~~~~~

| In Scilab 5.x, identifier names are composed of 24 characters maximum
  (this limitation disappears from Scilab 6.0 onwards).
| By default, variable, member, and function names longer than 24
  characters are truncated, and a warning is produced for each
  truncation.

This can cause ambiguities, especially when wrapping structs/classes,
for which the wrapped function name is composed of the struct/class name
and field names. In these cases, the `%rename
directive <SWIG.html#SWIG_rename_ignore>`__ can be used to choose a
different Scilab name.

Note: truncations can be disabled by specifying the target version 6 of
Scilab in the ``targetversion`` argument (i.e. ``-targetversion 6``).

Functions
~~~~~~~~~~~~~~~~

Functions are wrapped as new Scilab built-in functions. For example:

.. container:: code

   ::

      %module example

      %inline %{
      int fact(int n) {
        if (n > 1)
          return n * fact(n - 1);
        else
          return 1;
      }
      %}

creates a built-in function ``fact(n)`` in Scilab:

.. container:: targetlang

   ::

      --> fact(4)
      ans  =

          24.

Argument passing
^^^^^^^^^^^^^^^^^^^^^^^^^

In the above example, the function parameter is a primitive type and is
marshalled by value. So this function is wrapped without any additional
customization. Argument values are converted between C types and Scilab
types through type mappings. There are several default type mappings for
primitive and complex types, described later in the `Scilab
typemaps <#Scilab_typemaps>`__ section.

When a parameter is not passed by value, such as a pointer or reference,
SWIG does not know if it is an input, output (or both) parameter. The
INPUT, OUTPUT, INOUT typemaps defined in the ``typemaps.i`` library can
be used to specify this.

Let's see this on two simple functions: ``sub()`` which has an output
parameter, and ``inc()``, which as input/output parameter:

.. container:: code

   ::

      %module example

      %include <typemaps.i>

      extern void sub(int *INPUT, int *INPUT, int *OUTPUT);
      extern void inc(int *INOUT, int *INPUT);

      %{
      void sub(int *x, int *y, int *result) {
        *result = *x - *y;
      }
      void inc(int *x, int *delta) {
        *x = *x + *delta;
      }
      %}

In Scilab, parameters are passed by value. The output (and inout)
parameters are returned as the result of the functions:

.. container:: targetlang

   ::

      --> sub(5, 3)
       ans  =

          2.

      --> inc(4, 3)
       ans  =

          7.

Multiple output arguments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A C function can have several output parameters. They can all be
returned as results of the wrapped function as Scilab supports multiple
return values from a function when using the ``typemaps.i`` library. If
the C function itself returns a result, this is returned first before
the parameter outputs.

The example below shows this for a C function returning 2 values and a
result:

.. container:: code

   ::

      %module example

      %include <typemaps.i>

      int divide(int n, int d, int *OUTPUT, int *OUTPUT);

      %{
        int divide(int n, int d, int q*, int *r) {
          if (d != 0) {
            *q = n / d;
            *r = n % d;
            return 1;
          } else {
            return 0;
          }
        }
      %}

| 

.. container:: targetlang

   ::

      --> [ret, q, r] = divide(20, 6)
       r  =

          2.
       q  =

          3.
       ret  =

          1.

Global variables
~~~~~~~~~~~~~~~~~~~~~~~

Global variables are manipulated through generated accessor functions.
For example, for a given ``Foo`` global variable, SWIG actually
generates two functions: ``Foo_get()`` to get the value of ``Foo``, and
``Foo_set()`` to set the value. These functions are used as following:

.. container:: targetlang

   ::

      --> exec loader.sce;
      --> c = Foo_get();

      --> Foo_set(4);

      --> c
      c =

          3.

      --> Foo_get()
      ans  =

          4.

It works for variables of primitive type, but also for non-primitive
types: arrays, and structs/classes which are described later. For now,
an example with two global primitive arrays x and y is shown:

.. container:: code

   ::

      %module example

      %inline %{
      int x[10];
      double y[7];

      void initArrays()
      {
        int i;
        for (i = 0; i < 10; i++)
          x[i] = 1;
        for (i = 0; i < 7; i++)
          y[i] = 1.0f;
      }
      %}

It works the same:

.. container:: targetlang

   ::

      --> exec loader.sce

      --> initArrays();
      --> x_get()
       ans  =

          1.    1.    1.    1.    1.    1.    1.    1.    1.    1.

      --> y_set([0:6] / 10);
      --> y_get()
       ans  =

          0.    0.1    0.2    0.3    0.4    0.5    0.6

Constants and enumerations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Constants
^^^^^^^^^^^^^^^^^^

There is not any constant in Scilab. By default, C/C++ constants are
wrapped as getter functions. For example, for the following constants:

.. container:: code

   ::

      %module example
      #define    ICONST      42
      #define    FCONST      2.1828
      #define    CCONST      'x'
      #define    CCONST2     '\n'
      #define    SCONST      "Hello World"
      #define    SCONST2     "\"Hello World\""

the following getter functions are generated:

.. container:: targetlang

   ::

      --> exec loader.sce;
      --> ICONST_get();
       ans  =

          42.

      --> FCONST_get();
       ans  =

          2.1828

      --> CCONST_get();
       ans  =

          x

      --> CCONST2_get();
       ans  =

      --> SCONST_get();
       ans  =

          Hello World

      --> SCONST2_get();
       ans  =

          "Hello World"

      --> EXPR_get();
       ans  =

          48.5484

      --> iconst_get();
       ans  =

          37.

      --> fconst_get();
       ans  =

          3.14

There is another mode in which constants are wrapped as Scilab
variables. The variables are easier to use than functions, but the
drawback is that variables are not constant and so can be modified.

This mode can be enabled/disabled at any time in the interface file with
``%scilabconst()``, which works like all the other `%feature
directives <Customization.html#Customization_features>`__. Use the
argument value "1" to enable and "0" to disable this mode. For example
in this mode the previous constants:

.. container:: code

   ::

      %module example

      %scilabconst(1);
      #define    ICONST      42
      #define    FCONST      2.1828
      #define    CCONST      'x'
      #define    CCONST2     '\n'
      #define    SCONST      "Hello World"
      #define    SCONST2     "\"Hello World\""

are mapped to Scilab variables, with the same name:

.. container:: targetlang

   ::

      --> exec loader.sce;
      --> ICONST
       ans  =

          42

      --> FCONST
       ans  =

          2.1828

      --> CCONST
       ans  =

          x

      --> CCONST2
       ans  =

      --> SCONST
       ans  =

          Hello World

      --> SCONST2
       ans  =

          "Hello World"

      --> EXPR
       ans  =

          48.5484

      --> iconst
       ans  =

          37

      --> fconst
       ans  =

          3.14

Enumerations
^^^^^^^^^^^^^^^^^^^^^

The wrapping of enums is the same as for constants. By default, enums
are wrapped as getter functions. For example, with the following
enumeration:

.. container:: code

   ::

      %module example
      typedef enum { RED, BLUE, GREEN } color;

a getter function will be generated for each value of the enumeration:

.. container:: targetlang

   ::

      --> exec loader.sce;
      --> RED_get()
       ans  =

          0.

      --> BLUE_get()
       ans  =

          1.

      --> GREEN_get()
       ans  =

          2.

The ``%scilabconst()`` feature is also available for enumerations:

.. container:: code

   ::

      %module example
      %scilabconst(1) color;
      typedef enum { RED, BLUE, GREEN } color;

| 

.. container:: targetlang

   ::

      --> exec loader.sce;
      --> RED
       ans  =

          0.

      --> BLUE
       ans  =

          1.

      --> GREEN
       ans  =

          2.

Pointers
~~~~~~~~~~~~~~~

Pointers are supported by SWIG. A pointer can be returned from a wrapped
C/C++ function, stored in a Scilab variable, and used in input argument
of another C/C++ function.

| Also, thanks to the SWIG runtime which stores information about types,
  pointer types are tracked between exchanges Scilab and the native
  code. Indeed pointer types are stored alongside the pointer address. A
  pointer is mapped to a Scilab structure
  (`tlist <https://help.scilab.org/docs/5.5.2/en_US/tlist.html>`__),
  which contains as fields the pointer address and the pointer type (in
  fact a pointer to the type information structure in the SWIG runtime).
| Why a native pointer is not mapped to a Scilab pointer (type name:
  "pointer", type ID: 128) ? The big advantage of mapping to a ``tlist``
  is that it exposes a new type for the pointer in Scilab, type which
  can be acessed in Scilab with the
  `typeof <https://help.scilab.org/docs/5.5.2/en_US/typeof.html>`__
  function, and manipulated using the
  `overloading <https://help.scilab.org/docs/5.5.2/en_US/overloading.html>`__
  mechanism.

Notes:

-  type tracking needs the SWIG runtime to be first initialized with the
   appropriate function (see the `Module
   initialization <#Scilab_module_initialization>`__ section).
-  for any reason, if a wrapped pointer type is unknown (or if the SWIG
   runtime is not initialized), SWIG maps it to a Scilab pointer. Also,
   a Scilab pointer is always accepted as a pointer argument of a
   wrapped function. The drawaback is that pointer type is lost.

Following is an example of the wrapping of the C ``FILE*`` pointer:

.. container:: code

   ::

      %module example

      %{
      #include <stdio.h>
      %}

      FILE *fopen(const char *filename, const char *mode);
      int fputs(const char *, FILE *);
      int fclose(FILE *);

These functions can be used the same way as in C from Scilab:

.. container:: targetlang

   ::

      --> example_Init();

      --> f = fopen("junk", "w");
      --> typeof(f)
       ans  =

        _p_FILE

      --> fputs("Hello World", f);
      --> fclose(f);

Note: the type name ``_p_FILE`` which means "pointer to FILE".

The user of a pointer is responsible for freeing it or, like in the
example, closing any resources associated with it (just as is required
in a C program).

Utility functions
^^^^^^^^^^^^^^^^^^^^^^^^^^

As a scripting language, Scilab does not provide functions to manipulate
pointers. However, in some cases it can be useful, such as for testing
or debugging.

SWIG comes with two pointer utility functions:

-  ``SWIG_this()``: returns the address value of a pointer
-  ``SWIG_ptr()``: creates a pointer from an address value

Note: a pointer created by ``SWIG_ptr()`` does not have any type and is
mapped as a Scilab pointer.

Following we use the utility functions on the previous example:

.. container:: targetlang

   ::

      --> f = fopen("junk", "w");
      --> fputs("Hello", f);
      --> addr = SWIG_this(f)
       ans  =

          8219088.

      --> p = SWIG_ptr(addr);
      --> typeof(p)
      ans  =

        pointer

      --> fputs(" World", p);
      --> fclose(f);

Null pointers:
^^^^^^^^^^^^^^^^^^^^^^^

Using the previous ``SWIG_this()`` and ``SWIG_ptr()``, it is possible to
create and check null pointers:

.. container:: targetlang

   ::

      --> p = SWIG_ptr(0);
      --> SWIG_this(p) == 0
       ans  =

          T

Structures
~~~~~~~~~~~~~~~~~

Structs exist in Scilab, but C structs are not (at least in this version
of SWIG) mapped to Scilab structs. A C structure is wrapped through
low-level accessor functions, i.e. functions that give access to the
member variables of this structure. In Scilab, a structure is
manipulated through a pointer which is passed as an argument to the
accessor functions.

Let's see it on an example of a struct with two members:

.. container:: code

   ::

      %module example

      %inline %{

      typedef struct {
        int x;
        int arr[4];
      } Foo;

      %}

Several functions are generated:

-  a constructor function ``new_Foo()`` which returns a pointer to a
   newly created struct ``Foo``.
-  two member getter functions ``Foo_x_get()``, ``Foo_arr_get()``, to
   get the values of ``x`` and ``y`` for the struct pointer (provided as
   the first parameter to these functions)
-  two member setter functions ``Foo_x_set()``, ``Foo_arr_set()``, to
   set the values of ``x`` and ``y`` for the struct pointer (provided as
   the first parameter to these functions).
-  a destructor function ``delete_Foo()`` to release the struct pointer.

Usage example:

.. container:: targetlang

   ::

      --> f = new_Foo();
      --> Foo_x_set(f, 100);
      --> Foo_x_get(f)
      ans  =

          100.

      --> Foo_arr_set(f, [0:3]);
      --> Foo_arr_get(f)
      ans  =

          0.    1.    2.    3.

      --> delete_Foo(f);

Members of a structure that are also structures are also accepted and
wrapped as a pointer:

.. container:: code

   ::

      %module example

      %inline %{

      typedef struct {
        int x;
      } Bar;

      typedef struct {
        Bar b;
      } Foo;

      %}

| 

.. container:: targetlang

   ::

      --> b = new_Bar();
      --> Bar_x_set(b, 20.);

      --> f = new_Foo();
      --> Foo_b_set(f, b);

      --> b2 = Foo_b_get(f);
      --> Bar_x_get(b2);
      ans  =

          20.

Note: the pointer to the struct works as described in
`Pointers <#Scilab_wrapping_pointers>`__. For example, the type of the
struct pointer can be get with ``typeof``, as following:

.. container:: targetlang

   ::

      --> example_Init();
      --> b = new_Bar();
      --> typeof(b)
       ans  =

          _p_Bar
      --> delete_Bar(b);

C++ classes
~~~~~~~~~~~~~~~~~~

Classes do not exist in Scilab. The classes are wrapped the same way as
structs. Low-level accessor functions are generated for class members.
Also, constructor and destructor functions are generated to create and
destroy an instance of the class.

For example, the following class:

.. container:: code

   ::

      %module example

      %inline %{

      class Point {
      public:
        int x, y;
        Point(int _x, int _y) : x(_x), y(_y) {}
        double distance(const Point& rhs) {
          return sqrt(pow(x-rhs.x, 2) + pow(y-rhs.y, 2));
        }
        void set(int _x, int _y) {
          x=_x;
          y=_y;
        }
      };

      %}

can be used in Scilab like this:

.. container:: targetlang

   ::

      --> p1 = Point_new(3, 5);
      --> p2 = Point_new(1, 2);
      --> p1.distance(p2)
      ans  =

          3.6056

      --> delete_Point(p1);
      --> delete_Point(p2);

Note: like structs, class pointers are mapped as described in
`Pointers <#Scilab_wrapping_pointers>`__. Let's give an example which
shows that each class pointer type is a new type in Scilab that can be
used for example (through
`overloading <https://help.scilab.org/docs/5.5.2/en_US/overloading.html>`__)
to implement a custom print for the ``Point`` class:

.. container:: targetlang

   ::

      --> function %_p_Point_p(p)
      -->     mprintf('[%d, %d]\n', Point_x_get(p), Point_y_get(p));
      --> endfunction

      --> example_Init();
      --> p = new_Point(1, 2)
       p  =

      [1, 2]

      --> delete_Point(p);

C++ inheritance
~~~~~~~~~~~~~~~~~~~~~~

Inheritance is supported. SWIG knows the inheritance relationship
between classes.

A function is only generated for the class in which it is actually
declared. But if one of its parameters is a class, any instance of a
derived class is accepted as the argument.

This mechanism also applies for accessor functions: they are generated
only in the class in which they are defined. But any instance of a
derived class can be used as the argument to these accessor functions.

For example, let's take a base class ``Shape`` and two derived classes
``Circle`` and ``Square``:

.. container:: code

   ::

      %module example

      %inline %{

      class Shape {
      public:
        double x, y;
        void set_location(double _x, double _y) { x = _x; y = _y; }
        virtual double get_perimeter() { return 0; };
      };

      class Circle : public Shape {
      public:
        int radius;
        Circle(int _radius): radius(_radius) {};
        virtual double get_perimeter() { return 6.28 * radius; }
      };

      class Square : public Shape {
      public:
        int size;
        Square(int _size): size(_size) {};
        virtual double get_perimeter() { return 4 * size; }
      };

      %}

To set the location of the ``Circle``, we have to use the function
``set_location()`` of the parent ``Shape``. But we can use either use
the ``get_perimeter()`` function of the parent class or the derived
class:

.. container:: targetlang

   ::

      --> c = new_Circle(3);

      --> Shape_set_location(c, 2, 3);
      --> Shape_x_get(c)
       ans  =

          2.

      --> Circle_get_perimeter(c)
       ans  =

          18.84

      --> Shape_get_perimeter(c)
       ans  =

          18.84

C++ overloading
~~~~~~~~~~~~~~~~~~~~~~~

As explained in `Overloaded functions and
methods <SWIGPlus.html#SWIGPlus_overloaded_methods>`__ SWIG provides
support for overloaded functions and constructors.

As SWIG knows pointer types, the overloading works also with pointer
types, here is an example with a function ``magnify`` overloaded for the
previous classes ``Shape`` and ``Circle``:

.. container:: code

   ::

      %module example

      void magnify(Square *square, double factor) {
        square->size *= factor;
      };

      void magnify(Circle *circle, double factor) {
        square->radius *= factor;
      };

.. container:: targetlang

   ::

      --> example_Init();
      --> c = new_Circle(3);
      --> s = new_Square(2);

      --> magnify(c, 10);
      --> Circle_get_radius(c)
       ans  =

         30;
      --> magnify(s, 10);
      --> Square_get_size(s)
       ans  =

         20;

Pointers, references, values, and arrays
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In C++ objects can be passed by value, pointer, reference, or by an
array:

.. container:: code

   ::

      %module example

      %{
      #include <sciprint.h>
      %}

      %inline %{

      class Foo {
      public:
        Foo(int _x) : x(_x) {}
        int x;
      };

      void spam1(Foo *f)  { sciprint("%d\n", f->x); }   // Pass by pointer
      void spam2(Foo &f)  { sciprint("%d\n", f.x); }    // Pass by reference
      void spam3(Foo f)   { sciprint("%d\n", f.x); }    // Pass by value
      void spam4(Foo f[]) { sciprint("%d\n", f[0].x); } // Array of objects

      %}

In SWIG, there is no real distinction between these. So in Scilab, it is
perfectly legal to do this:

.. container:: targetlang

   ::

      --> f = new_Foo()
      --> spam1(f)
      3
      --> spam2(f)
      3
      --> spam3(f)
      3
      --> spam4(f)
      3

Similar behaviour occurs for return values. For example, if you had
functions like this:

.. container:: code

   ::

      Foo *spam5();
      Foo &spam6();
      Foo  spam7();

All these functions will return a pointer to an instance of ``Foo``. As
the function ``spam7`` returns a value, new instance of ``Foo`` has to
be allocated, and a pointer on this instance is returned.

C++ templates
~~~~~~~~~~~~~~~~~~~~~

As in other languages, function and class templates are supported in
SWIG Scilab.

You have to tell SWIG to create wrappers for a particular template
instantiation. The ``%template`` directive is used for this purpose. For
example:

.. container:: code

   ::

      %module example

      template<class T1, class T2, class T3>
      struct triplet {
        T1 first;
        T2 second;
        T3 third;
        triplet(const T1& a, const T2& b, const T3& c) {
          third = a; second = b; third = c;
        }
      };

      %template(IntTriplet) triplet<int, int, int>;

Then in Scilab:

.. container:: targetlang

   ::

      --> t = new_IntTriplet(3, 4, 1);

      --> IntTriplet_first_get(t)
       ans  =

          3.

      --> IntTriplet_second_get(t)
       ans  =

          4.

      --> IntTriplet_third_get(t)
       ans  =

          1.

      --> delete_IntTriplet(t);

More details on template support can be found in the
`templates <SWIGPlus.html#SWIGPlus_nn30>`__ documentation.

C++ operators
~~~~~~~~~~~~~~~~~~~~~

C++ operators are partially supported. Operator overloading exists in
Scilab, but a C++ operator is not (in this version) wrapped by SWIG as a
Scilab operator, but as a function. It is not automatic, you have to
rename each operator (with the instruction ``%rename``) with the
suitable wrapper name.

Let's see it with an example of class with two operators ``+`` and
``double()``:

.. container:: code

   ::

      %module example

      %rename(plus) operator +;
      %rename(toDouble) operator double();

      %inline %{

      class Complex {
      public:
        Complex(double re, double im) : real(re), imag(im) {};

        Complex operator+(const Complex& other) {
          double result_real = real + other.real;
          double result_imaginary = imag + other.imag;
          return Complex(result_real, result_imaginary);
        }
        operator double() { return real; }
      private:
        double real;
        double imag;
      };

      %}

| 

.. container:: targetlang

   ::

      --> c1 = new_Complex(3, 7);

      --> c2 = Complex_plus(c, new_Complex(1, 1));

      --> Complex_toDouble(c2)
       ans  =

          4.

C++ namespaces
~~~~~~~~~~~~~~~~~~~~~~

SWIG is aware of C++ namespaces, but does not use it for wrappers. The
module is not broken into submodules, nor do namespace appear in
functions names. All the namespaces are all flattened in the module. For
example with one namespace ``Foo``:

.. container:: code

   ::

      %module example

      %inline %{

      namespace foo {
        int fact(int n) {
          if (n > 1)
            return n * fact(n-1);
          else
            return 1;
        }

        struct Vector {
          double x, y, z;
        };
      };

      %}

In Scilab, there is no need to the specify the ``Foo`` namespace:

.. container:: targetlang

   ::

      --> fact(3)
       ans  =

         6.

      --> v = new_Vector();
      --> Vector_x_set(v, 3.4);
      --> Vector_y_get(v)
       ans  =

         0.

If your program has more than one namespace, name conflicts can be
resolved using ``%rename``. For example:

.. container:: code

   ::

      %rename(Bar_spam) Bar::spam;

      namespace Foo {
        int spam();
      }

      namespace Bar {
        int spam();
      }

Note: the `nspace <SWIGPlus.html#SWIGPlus_nspace>`__ feature is not
supported.

C++ exceptions
~~~~~~~~~~~~~~~~~~~~~~

Scilab does not natively support exceptions, but has errors. When an
exception is thrown, SWIG catches it, and sets a Scilab error. An error
message is displayed in Scilab. For example:

.. container:: code

   ::

      %module example

      %inline %{
      void throw_exception() throw(char const *) {
        throw "Bye world !";
      }
      %}

| 

.. container:: targetlang

   ::

      -->throw_exception()
        !--error 999
      SWIG/Scilab: Exception (char const *) occurred: Bye world !

Scilab has a ``try-catch`` mechanism (and a similar instruction
``execstr()``) to handle exceptions. It can be used with the
``lasterror()`` function as following:

.. container:: targetlang

   ::

      --> execstr('throw_exception()', 'errcatch');
       ans  =

          999.

      --> lasterror()
       ans  =

          SWIG/Scilab: Exception (char const *) occurred: Bye world !

If the function has a ``throw`` exception specification, SWIG can
automatically map the exception type and set an appropriate Scilab error
message. It works for a few primitive types, and also for STL exceptions
(the library ``std_except.i`` has to be included to get the STL
exception support):

.. container:: code

   ::

      %module example

      %include <std_except.i>

      %inline %{
      void throw_int() throw(int) {
        throw 12;
      }

      void throw_stl_invalid_arg(int i) throw(std::invalid_argument) {
        if (i < 0)
          throw std::invalid_argument("argument is negative.");
      }
      %}

| 

.. container:: targetlang

   ::

      --> throw_int();
                  !--error 999
      SWIG/Scilab: Exception (int) occurred: 12

      -->throw_stl_invalid_arg(-1);
                                !--error 999
      SWIG/Scilab: ValueError: argument is negative.

More complex or custom exception types require specific exception
typemaps to be implemented in order to specifically handle a thrown
type. See the `SWIG C++ documentation <SWIGPlus.html#SWIGPlus>`__ for
more details.

C++ STL
~~~~~~~~~~~~~~~

The Standard Template Library (STL) is partially supported. See
`STL <#Scilab_typemaps_stl>`__ for more details.

Type mappings and libraries
--------------------------------

Default primitive type mappings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following table provides the equivalent Scilab type for C/C++
primitive types.

.. container:: table

   ================== ===========================
   **C/C++ type**     **Scilab type**
   bool               boolean
   char               string
   signed char        double or int8
   unsigned char      double or uint8
   short              double or int16
   unsigned short     double or uint16
   int                double or int32
   unsigned int       double or uint32
   long               double or int32
   unsigned long      double or uint32
   signed long long   not supported in Scilab 5.x
   unsigned long long not supported in Scilab 5.x
   float              double
   double             double
   char \* or char[]  string
   ================== ===========================

Notes:

-  In Scilab the ``double`` type is far more used than any integer type.
   This is why integer values (``int32``, ``uint32``, ...) are
   automatically converted to Scilab ``double`` values when marshalled
   from C into Scilab. Additionally on input to a C function, Scilab
   ``double`` values are converted into the related integer type.
-  When an integer is expected, if the input is a double, the value must
   be an integer, i.e. it must not have any decimal part, otherwise a
   SWIG value error occurs.
-  In SWIG for Scilab 5.x, the ``long long`` type is not supported,
   since Scilab 5.x does not have a 64-bit integer type. The default
   behaviour is for SWIG to generate code that will give a runtime error
   if ``long long`` type arguments are used from Scilab.

Arrays
~~~~~~~~~~~~~

Typemaps are available by default for arrays. Primitive type arrays are
automatically converted to/from Scilab matrices. Typemaps are also
provided to handle members of a struct or class that are arrays.

In input, the matrix is usually one-dimensional (it can be either a row
or column vector). But it can also be a two-dimensional matrix. Warning:
in Scilab, the values are column-major ordered, unlike in C, which is
row-major ordered.

The type mappings used for arrays is the same for primitive types,
described `earlier <#Scilab_typemaps_primitive_types>`__. This means
that, if needed, a Scilab ``double`` vector is converted in input into
the related C integer array and this C integer array is automatically
converted on output into a Scilab ``double`` vector. Note that unlike
scalars, no control is done for arrays when a ``double`` is converted
into an integer.

The following example illustrates all this:

.. container:: code

   ::

      %module example

      %#include <stdio.h>

      %inline %{

      void printArray(int values[], int len) {
        int i = 0;
        for (i = 0; i < len; i++) {
          printf("%s %d %s", i==0?"[":"", values[i], i==len-1?"]\n":"");
        }
      }
      %}

| 

.. container:: targetlang

   ::

      --> printArray([0 1 2 3], 4)
      [ 0  1  2  3 ]

      --> printArray([0.2; -1.8; 2; 3.7], 4)
      [ 0  -1  2  3 ]

      --> printArray([0 1; 2 3], 4)
      [ 0  2  1  3 ]

      --> printArray([0; 1; 2; 3], 4)
      [ 0  1  2  3 ]

Pointer-to-pointers
~~~~~~~~~~~~~~~~~~~~~~~~~~

There are no specific typemaps for pointer-to-pointers, they are mapped
as pointers in Scilab.

Pointer-to-pointers are sometimes used to implement matrices in C. The
following is an example of this:

.. container:: code

   ::

      %module example
      %inline %{

      // Returns the matrix [1 2; 3 4];
      double **create_matrix() {
        double **M;
        int i;
        M = (double **) malloc(2 * sizeof(double *));
        for (i = 0; i < 2; i++) {
          M[i] = (double *) malloc(2 * sizeof(double));
          M[i][0] = 2 * i + 1;
          M[i][1] = 2 * i + 2;
        }
        return M;
      }

      // Gets the item M(i, j) value
      double get_matrix(double **M, int i, int j) {
        return M[i][j];
      }

      // Sets the item M(i, j) value to be val
      void set_matrix(double **M, int i, int j, double val) {
        M[i][j] = val;
      }

      // Prints a matrix (2, 2) to console
      void print_matrix(double **M, int nbRows, int nbCols) {
        int i, j;
        for (i = 0; i < 2; i++) {
          for (j = 0; j < 2; j++) {
            printf("%3g ", M[i][j]);
          }
          printf("\n");
        }
      }

      %}

These functions are used like this in Scilab:

.. container:: targetlang

   ::

      --> m = create_matrix();

      --> print_matrix(m);
         1.   2.
         3.   4.

      --> set_matrix(m, 1, 1, 5.);

      --> get_matrix(m, 1, 1)
       ans  =

          5.

Matrices
~~~~~~~~~~~~~~~

The ``matrix.i`` library provides a set of typemaps which can be useful
when working with one-dimensional and two-dimensional matrices.

In order to use this library, just include it in the interface file:

.. container:: code

   ::

        %include <matrix.i>

Several typemaps are available for the common Scilab matrix types:

-  ``double``
-  ``int``
-  ``char *``
-  ``bool``

For example: for a matrix of ``int``, we have the typemaps, for input:

-  ``(int *IN, int IN_ROWCOUNT, int IN_COLCOUNT)``
-  ``(int IN_ROWCOUNT, int IN_COLCOUNT, int *IN)``
-  ``(int *IN, int IN_SIZE)``
-  ``(int IN_SIZE, int *IN)``

and output:

-  ``(int **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)``
-  ``(int *OUT_ROWCOUNT, int *OUT_COLCOUNT, int **OUT)``
-  ``(int **OUT, int *OUT_SIZE)``
-  ``(int *OUT_SIZE, int **OUT)``

They marshall a Scilab matrix type into the appropriate 2 or 3 C
parameters. The following is an example using the typemaps in this
library:

.. container:: code

   ::

      %module example

      %include <matrix.i>

      %apply (int *IN, int IN_ROWCOUNT, int IN_COLCOUNT) { (int *matrix, int matrixNbRow, int matrixNbCol) };
      %apply (int **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT) { (int **outMatrix, int *outMatrixNbRow, int *outMatrixNbCol) };

      %inline %{

      void absolute(int *matrix, int matrixNbRow, int matrixNbCol,
        int **outMatrix, int *outMatrixNbRow, int *outMatrixNbCol) {
        int i, j;
        *outMatrixNbRow = matrixNbRow;
        *outMatrixNbCol = matrixNbCol;
        *outMatrix = malloc(matrixNbRow * matrixNbCol * sizeof(int));
        for (i=0; i < matrixNbRow * matrixNbCol; i++) {
          (*outMatrix)[i] = matrix[i] > 0 ? matrix[i]:-matrix[i];
        }
      }

      %}

| 

.. container:: targetlang

   ::

      --> absolute([-0 1 -2; 3 4 -5])
       ans  =

          0.    1.    2.
          3.    4.    5.

The remarks made earlier for arrays also apply here:

-  The values of matrices in Scilab are column-major orderered,
-  There is no control while converting ``double`` values to integers,
   ``double`` values are truncated without any checking or warning.

STL
~~~~~~~~~~

The STL library wraps some containers defined in the STL (Standard
Template Library), so that they can be manipulated in Scilab. This
library also provides the appropriate typemaps to use the containers in
functions and variables.

The list of wrapped sequence containers are:

-  ``std::vector``
-  ``std::list``
-  ``std::deque``

And associative containers are:

-  ``std::set``
-  ``std::multiset``

Typemaps are available for the following container types:

-  ``double``
-  ``float``
-  ``int``
-  ``string``
-  ``bool``
-  ``pointer``

Containers of other item types are not supported. Using them does not
break compilation, but provokes a runtime error. Containers of enum are
not supported yet.

In order to use the STL, the library must first be included in the SWIG
interface file:

.. container:: code

   ::

      %include <stl.i>

Then for each container used, the appropriate template must be
instantiated, in the ``std`` namespace:

.. container:: code

   ::

      namespace std {
          %template(IntVector)    vector<int>;
          %template(DoubleVector) vector<double>;
      }

Additionally, the module initialization function has to be executed
first in Scilab, so that all the types are known to Scilab. See the
`Module initialization <#Scilab_module_initialization>`__ section for
more details.

Because in Scilab matrices exist for basic types only, a sequence
container of pointers is mapped to a Scilab list. For other item types
(double, int, string...) the sequence container is mapped to a Scilab
matrix.

The first example below shows how to create a vector (of ``int``) in
Scilab, add some values to the vector and pass it as an argument of a
function. It also shows, thanks to the typemaps, that we can also pass a
Scilab matrix of values directly into the function:

.. container:: code

   ::

      %module example

      %include <stl.i>

      namespace std {
        %template(IntVector) vector<int>;
      }

      %{
      #include <numeric>
      %}

      %inline %{

      double average(std::vector<int> v) {
        return std::accumulate(v.begin(), v.end(), 0.0) / v.size();
      }

      %}

| 

.. container:: targetlang

   ::

      --> example_Init();

      --> v = new_IntVector();

      --> for i = 1:4
      -->     IntVector_push_back(v, i);
      --> end;

      --> average(v)
       ans  =

          2.5

      --> average([0 1 2 3])
       ans  =

          2.5

      --> delete_IntVector();

In the second example, a set of struct (``Person``) is wrapped. A
function performs a search in this set, and returns a subset. As one can
see, the result in Scilab is a list of pointers:

.. container:: code

   ::

      %module example

      %include <stl.i>

      %{
      #include <string>
      %}

      %inline %{

      struct Person {
        Person(std::string _name, int _age) : name(_name), age(_age) {};
        std::string name;
        int age;
      };
      typedef Person * PersonPtr;

      %}

      namespace std {
        %template(PersonPtrSet) set<PersonPtr>;
      }

      %inline %{

      std::set<PersonPtr> findPersonsByAge(std::set<PersonPtr> persons, int minAge, int maxAge) {
        std::set<PersonPtr> foundPersons;
        for (std::set<PersonPtr>::iterator it = persons.begin(); it != persons.end(); it++) {
          if (((*it)->age >= minAge) && ((*it)->age <= maxAge)) {
            foundPersons.insert(*it);
          }
        }
        return foundPersons;
      }

      %}

| 

.. container:: targetlang

   ::

      --> example_Init();

      --> joe = new_Person("Joe", 25);
      --> susan = new_Person("Susan", 32);
      --> bill = new_Person("Bill", 50);

      --> p = new_PersonPtrSet();
      --> PersonPtrSet_insert(p, susan);
      --> PersonPtrSet_insert(p, joe);
      --> PersonPtrSet_insert(p, bill);

      --> l = findPersonsByAge(p, 20, 40);

      --> size(l)
       ans  =

          2.

      --> Person_name_get(l(1))
      ans  =

          Susan

      --> Person_name_get(l(2))
       ans  =

          Joe

      --> delete_PersonPtrSet(p);

Module initialization
--------------------------

The wrapped module contains an initialization function to:

-  initialize the SWIG runtime, needed for pointer type tracking or when
   working with the STL
-  initialize the module constants and enumerations declared with
   ``%scilabconst()``

This initialization function should be executed at the start of a
script, before the wrapped library has to be used.

The function has the name of the module suffixed by ``_Init``. For
example, to initialize the module ``example``:

.. container:: targetlang

   ::

      --> example_Init();

Building modes
-------------------

The mechanism to load an external module in Scilab is called *Dynamic
Link* and works with dynamic modules (or shared libraries, ``.so``
files).

To produce a dynamic module, when generating the wrapper, there are two
possibilities, or build modes:

-  the ``nobuilder`` mode, this is the default mode in SWIG. The user is
   responsible of the build.
-  the ``builder`` mode. In this mode, Scilab is responsible of
   building.

No-builder mode
~~~~~~~~~~~~~~~~~~~~~~

In this mode, used by default, SWIG generates the wrapper sources, which
have to be manually compiled and linked. A loader script ``loader.sce``
is also produced, this one is executed further in Scilab to load the
module.

This mode is the best option to use when you have to integrate the
module build into a larger build process.

Builder mode
~~~~~~~~~~~~~~~~~~~

In this mode, in addition to the wrapper sources, SWIG produces a
builder Scilab script (``builder.sce``), which is executed in Scilab to
build the module. In a few words, the Scilab ``ilib_build()`` command is
used, which produces the shared library file, and the loader script
``loader.sce`` (and also a cleaner script ``cleaner.sce``).

An advantage of this mode is that it hides all the complexity of the
build and other platform issues. Also it allows the module to conform to
a Scilab external module convention which is that an external module
should be simply built by calling a builder script.

The builder mode is activated with the ``-builder`` SWIG option. In this
mode, the following SWIG options may be used to setup the build:

-  ``-buildersources``: to add sources to the build (several files must
   be separated by a comma)
-  ``-buildercflags``: to add flags to the builder compiler flags, for
   example to set library dependencies include paths
-  ``-builderldflags``: to add flags to the linker flags, for example to
   set library dependency names and paths

Let's give an example how to build a module ``example``, composed of two
sources, and using a library dependency:

-  the sources are ``baa1.c`` and ``baa2.c`` (and are stored in the
   current directory)
-  the library is ``libfoo`` in ``/opt/foo`` (headers stored in
   ``/opt/foo/include``, and shared library in ``/opt/foo/lib``)

The command is:

.. container:: shell

   ::

      $ swig -scilab -builder -buildercflags -I/opt/foo/include -builderldflags "-L/opt/foo/lib -lfoo" -buildersources baa1.cxx, baa2.cxx example.i

Generated scripts
----------------------

In this part we give some details about the generated Scilab scripts.

Builder script
~~~~~~~~~~~~~~~~~~~~~

``builder.sce`` is the name of the builder script generated by SWIG in
``builder`` mode. It contains code like this:

.. container:: code

   ::

      ilib_name = "examplelib";
      files = ["example_wrap.c"];
      libs = [];
      table = ["fact", "_wrap_fact";"Foo_set", "_wrap_Foo_set";"Foo_get", "_wrap_Foo_get";];
      ilib_build(ilib_name, table, files, libs);

``ilib_build(lib_name, table, files, libs)`` is used to create shared
libraries, and to generate a loader file used to dynamically load the
shared library into Scilab.

-  ``ilib_name``: a character string, the generic name of the library
   without path and extension.
-  ``files``: string matrix containing objects files needed for shared
   library creation.
-  ``libs``: string matrix containing extra libraries needed for shared
   library creation.
-  ``table``: two column string matrix containing a table of pairs of
   'scilab function name', 'C function name'.

Loader script
~~~~~~~~~~~~~~~~~~~~

The loader script is used to load in Scilab all the module functions.
When loaded, these functions can be used as other Scilab functions.

The loader script ``loader.sce`` contains code similar to:

.. container:: code

   ::

      // ------------------------------------------------------
      // generated by builder.sce: Please do not edit this file
      // ------------------------------------------------------

      libexamplelib_path = get_file_path('loader.sce');
      list_functions = [             'fact';
                  'Foo_set';
                  'Foo_get';
      ];
      addinter(libexamplelib_path+'/libexamplelib.so', 'libexamplelib', list_functions);
      // remove temp. variables on stack
      clear libexamplelib_path;
      clear list_functions;
      clear get_file_path;
      // ------------------------------------------------------

``addinter(files, spname, fcts)`` performs dynamic linking of a compiled
C interface function.

-  ``files``: a character string or a vector of character strings
   defining the object files (containing the C interface functions) to
   link with.
-  ``spname``: a character string. Name of interface routine entry
   point.
-  ``fcts``: vector of character strings. The name of new Scilab
   function.

Other resources
--------------------

-  Example use cases can be found in the ``Examples/scilab`` directory.
-  The test suite in the ``Examples/test-suite/scilab`` can be another
   source of useful use cases.
-  The `Scilab
   API <http://help.scilab.org/docs/5.5.0/en_US/api_scilab.html>`__ is
   used in the generated code and is a useful reference when examining
   the output.
-  This `guide <http://wiki.scilab.org/howto/Create%20a%20toolbox>`__
   describes the Scilab external modules structure and files, in
   particular the files that are generated by SWIG for Scilab.

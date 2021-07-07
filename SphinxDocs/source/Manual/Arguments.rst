Argument Handling
====================

In Chapter 5, SWIG's treatment of basic datatypes and pointers was
described. In particular, primitive types such as ``int`` and ``double``
are mapped to corresponding types in the target language. For everything
else, pointers are used to refer to structures, classes, arrays, and
other user-defined datatypes. However, in certain applications it is
desirable to change SWIG's handling of a specific datatype. For example,
you might want to return multiple values through the arguments of a
function. This chapter describes some of the techniques for doing this.

The typemaps.i library
---------------------------

This section describes the ``typemaps.i`` library file--commonly used to
change certain properties of argument conversion.

Introduction
~~~~~~~~~~~~~~~~~~~

Suppose you had a C function like this:

.. container:: code

   ::

      void add(double a, double b, double *result) {
        *result = a + b;
      }

From reading the source code, it is clear that the function is storing a
value in the ``double *result`` parameter. However, since SWIG does not
examine function bodies, it has no way to know that this is the
underlying behavior.

One way to deal with this is to use the ``typemaps.i`` library file and
write interface code like this:

.. container:: code

   ::

      // Simple example using typemaps
      %module example
      %include "typemaps.i"

      %apply double *OUTPUT { double *result };
      %inline %{
      extern void add(double a, double b, double *result);
      %}

The ``%apply`` directive tells SWIG that you are going to apply a
special type handling rule to a type. The "``double *OUTPUT``"
specification is the name of a rule that defines how to return an output
value from an argument of type ``double *``. This rule gets applied to
all of the datatypes listed in curly braces-- in this case
"``double *result``".

When the resulting module is created, you can now use the function like
this (shown for Python):

.. container:: targetlang

   ::

      >>> a = add(3, 4)
      >>> print a
      7
      >>>

In this case, you can see how the output value normally returned in the
third argument has magically been transformed into a function return
value. Clearly this makes the function much easier to use since it is no
longer necessary to manufacture a special ``double *`` object and pass
it to the function somehow.

Once a typemap has been applied to a type, it stays in effect for all
future occurrences of the type and name. For example, you could write
the following:

.. container:: code

   ::

      %module example
      %include "typemaps.i"

      %apply double *OUTPUT { double *result };

      %inline %{
      extern void add(double a, double b, double *result);
      extern void sub(double a, double b, double *result);
      extern void mul(double a, double b, double *result);
      extern void div(double a, double b, double *result);
      %}
      ...

In this case, the ``double *OUTPUT`` rule is applied to all of the
functions that follow.

Typemap transformations can even be extended to multiple return values.
For example, consider this code:

.. container:: code

   ::

      %include "typemaps.i"
      %apply int *OUTPUT { int *width, int *height };

      // Returns a pair (width, height)
      void getwinsize(int winid, int *width, int *height);

In this case, the function returns multiple values, allowing it to be
used like this:

.. container:: targetlang

   ::

      >>> w, h = genwinsize(wid)
      >>> print w
      400
      >>> print h
      300
      >>>

It should also be noted that although the ``%apply`` directive is used
to associate typemap rules to datatypes, you can also use the rule names
directly in arguments. For example, you could write this:

.. container:: code

   ::

      // Simple example using typemaps
      %module example
      %include "typemaps.i"

      %{
      extern void add(double a, double b, double *OUTPUT);
      %}
      extern void add(double a, double b, double *OUTPUT);

Typemaps stay in effect until they are explicitly deleted or redefined
to something else. To clear a typemap, the ``%clear`` directive should
be used. For example:

.. container:: code

   ::

      %clear double *result;      // Remove all typemaps for double *result

Input parameters
~~~~~~~~~~~~~~~~~~~~~~~

The following typemaps instruct SWIG that a pointer really only holds a
single input value:

.. container:: code

   ::

      int *INPUT
      short *INPUT
      long *INPUT
      unsigned int *INPUT
      unsigned short *INPUT
      unsigned long *INPUT
      double *INPUT
      float *INPUT

When used, it allows values to be passed instead of pointers. For
example, consider this function:

.. container:: code

   ::

      double add(double *a, double *b) {
        return *a+*b;
      }

Now, consider this SWIG interface:

.. container:: code

   ::

      %module example
      %include "typemaps.i"
      ...
      %{
      extern double add(double *, double *);
      %}
      extern double add(double *INPUT, double *INPUT);

When the function is used in the scripting language interpreter, it will
work like this:

.. container:: targetlang

   ::

      result = add(3, 4)

Output parameters
~~~~~~~~~~~~~~~~~~~~~~~~

The following typemap rules tell SWIG that pointer is the output value
of a function. When used, you do not need to supply the argument when
calling the function. Instead, one or more output values are returned.

.. container:: code

   ::

      int *OUTPUT
      short *OUTPUT
      long *OUTPUT
      unsigned int *OUTPUT
      unsigned short *OUTPUT
      unsigned long *OUTPUT
      double *OUTPUT
      float *OUTPUT

These methods can be used as shown in an earlier example. For example,
if you have this C function :

.. container:: code

   ::

      void add(double a, double b, double *c) {
        *c = a+b;
      }

A SWIG interface file might look like this :

.. container:: code

   ::

      %module example
      %include "typemaps.i"
      ...
      %inline %{
      extern void add(double a, double b, double *OUTPUT);
      %}

In this case, only a single output value is returned, but this is not a
restriction. An arbitrary number of output values can be returned by
applying the output rules to more than one argument (as shown
previously).

If the function also returns a value, it is returned along with the
argument. For example, if you had this:

.. container:: code

   ::

      extern int foo(double a, double b, double *OUTPUT);

The function will return two values like this:

.. container:: targetlang

   ::

      iresult, dresult = foo(3.5, 2)

Input/Output parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When a pointer serves as both an input and output value you can use the
following typemaps :

.. container:: code

   ::

      int *INOUT
      short *INOUT
      long *INOUT
      unsigned int *INOUT
      unsigned short *INOUT
      unsigned long *INOUT
      double *INOUT
      float *INOUT

A C function that uses this might be something like this:

.. container:: code

   ::

      void negate(double *x) {
        *x = -(*x);
      }

To make x function as both and input and output value, declare the
function like this in an interface file :

.. container:: code

   ::

      %module example
      %include "typemaps.i"
      ...
      %{
      extern void negate(double *);
      %}
      extern void negate(double *INOUT);

Now within a script, you can simply call the function normally :

.. container:: targetlang

   ::

      a = negate(3);         # a = -3 after calling this

One subtle point of the ``INOUT`` rule is that many scripting languages
enforce mutability constraints on primitive objects (meaning that simple
objects like integers and strings aren't supposed to change). Because of
this, you can't just modify the object's value in place as the
underlying C function does in this example. Therefore, the ``INOUT``
rule returns the modified value as a new object rather than directly
overwriting the value of the original input object.

**Compatibility note :** The ``INOUT`` rule used to be known as ``BOTH``
in earlier versions of SWIG. Backwards compatibility is preserved, but
deprecated.

Using different names
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As previously shown, the ``%apply`` directive can be used to apply the
``INPUT``, ``OUTPUT``, and ``INOUT`` typemaps to different argument
names. For example:

.. container:: code

   ::

      // Make double *result an output value
      %apply double *OUTPUT { double *result };

      // Make Int32 *in an input value
      %apply int *INPUT { Int32 *in };

      // Make long *x inout
      %apply long *INOUT {long *x};

To clear a rule, the ``%clear`` directive is used:

.. container:: code

   ::

      %clear double *result;
      %clear Int32 *in, long *x;

Typemap declarations are lexically scoped so a typemap takes effect from
the point of definition to the end of the file or a matching ``%clear``
declaration.

Applying constraints to input values
-----------------------------------------

In addition to changing the handling of various input values, it is also
possible to use typemaps to apply constraints. For example, maybe you
want to insure that a value is positive, or that a pointer is non-NULL.
This can be accomplished including the ``constraints.i`` library file.

Simple constraint example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The constraints library is best illustrated by the following interface
file :

.. container:: code

   ::

      // Interface file with constraints
      %module example
      %include "constraints.i"

      double exp(double x);
      double log(double POSITIVE);         // Allow only positive values
      double sqrt(double NONNEGATIVE);     // Non-negative values only
      double inv(double NONZERO);          // Non-zero values
      void   free(void *NONNULL);          // Non-NULL pointers only

The behavior of this file is exactly as you would expect. If any of the
arguments violate the constraint condition, a scripting language
exception will be raised. As a result, it is possible to catch bad
values, prevent mysterious program crashes and so on.

Constraint methods
~~~~~~~~~~~~~~~~~~~~~~~~~

The following constraints are currently available

.. container:: code

   ::

      POSITIVE                     Any number > 0 (not zero)
      NEGATIVE                     Any number < 0 (not zero)
      NONNEGATIVE                  Any number >= 0
      NONPOSITIVE                  Any number <= 0
      NONZERO                      Nonzero number
      NONNULL                      Non-NULL pointer (pointers only).

Applying constraints to new datatypes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The constraints library only supports the primitive C datatypes, but it
is easy to apply it to new datatypes using ``%apply``. For example :

.. container:: code

   ::

      // Apply a constraint to a Real variable
      %apply Number POSITIVE { Real in };

      // Apply a constraint to a pointer type
      %apply Pointer NONNULL { Vector * };

The special types of "Number" and "Pointer" can be applied to any
numeric and pointer variable type respectively. To later remove a
constraint, the ``%clear`` directive can be used :

.. container:: code

   ::

      %clear Real in;
      %clear Vector *;

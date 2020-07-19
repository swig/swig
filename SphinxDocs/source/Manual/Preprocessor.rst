Preprocessing
================

SWIG includes its own enhanced version of the C preprocessor. The
preprocessor supports the standard preprocessor directives and macro
expansion rules. However, a number of modifications and enhancements
have been made. This chapter describes some of these modifications.

File inclusion
-------------------

To include another file into a SWIG interface, use the ``%include``
directive like this:

.. container:: code

   ::

      %include "pointer.i"

Unlike, ``#include``, ``%include`` includes each file once (and will not
reload the file on subsequent ``%include`` declarations). Therefore, it
is not necessary to use include-guards in SWIG interfaces.

By default, the ``#include`` is ignored unless you run SWIG with the
``-includeall`` option. The reason for ignoring traditional includes is
that you often don't want SWIG to try and wrap everything included in
standard header system headers and auxiliary files.

File imports
-----------------

SWIG provides another file inclusion directive with the ``%import``
directive. For example:

.. container:: code

   ::

      %import "foo.i"

The purpose of ``%import`` is to collect certain information from
another SWIG interface file or a header file without actually generating
any wrapper code. Such information generally includes type declarations
(e.g., ``typedef``) as well as C++ classes that might be used as
base-classes for class declarations in the interface. The use of
``%import`` is also important when SWIG is used to generate extensions
as a collection of related modules. This is an advanced topic and is
described in later in the `Working with
Modules <Modules.html#Modules>`__ chapter.

The ``-importall`` directive tells SWIG to follow all ``#include``
statements as imports. This might be useful if you want to extract type
definitions from system header files without generating any wrappers.

Conditional Compilation
----------------------------

SWIG fully supports the use of ``#if``, ``#ifdef``, ``#ifndef``,
``#else``, ``#endif`` to conditionally include parts of an interface.
The following symbols are predefined by SWIG when it is parsing the
interface:

.. container:: code

   ::

      SWIG                            Always defined when SWIG is processing a file
      SWIGIMPORTED                    Defined when SWIG is importing a file with %import
      SWIG_VERSION                    Hexadecimal (binary-coded decimal) number containing SWIG version,
                                      such as 0x010311 (corresponding to SWIG-1.3.11).

      SWIGCSHARP                      Defined when using C#
      SWIGD                           Defined when using D
      SWIGGO                          Defined when using Go
      SWIGGUILE                       Defined when using Guile
      SWIGJAVA                        Defined when using Java
      SWIGJAVASCRIPT                  Defined when using Javascript
      SWIG_JAVASCRIPT_JSC             Defined when using Javascript with -jsc
      SWIG_JAVASCRIPT_V8              Defined when using Javascript with -v8 or -node
      SWIGLUA                         Defined when using Lua
      SWIGMZSCHEME                    Defined when using Mzscheme
      SWIGOCAML                       Defined when using OCaml
      SWIGOCTAVE                      Defined when using Octave
      SWIGPERL                        Defined when using Perl
      SWIGPHP                         Defined when using PHP (any version)
      SWIGPHP7                        Defined when using PHP7
      SWIGPYTHON                      Defined when using Python
      SWIGR                           Defined when using R
      SWIGRUBY                        Defined when using Ruby
      SWIGSCILAB                      Defined when using Scilab
      SWIGTCL                         Defined when using Tcl
      SWIGXML                         Defined when using XML

In addition, SWIG defines the following set of standard C/C++ macros:

.. container:: code

   ::

      __LINE__                        Current line number
      __FILE__                        Current file name
      __STDC__                        Defined to indicate ISO C
      __cplusplus                     Defined when -c++ option used

The following are language specific symbols that might be defined:

.. container:: code

   ::

      SWIG_D_VERSION                  Unsigned integer target version when using D
      SWIGGO_CGO                      Defined when using Go for cgo
      SWIGGO_GCCGO                    Defined when using Go for gccgo
      SWIGGO_INTGO_SIZE               Size of the Go type int when using Go (32 or 64)
      SWIGPYTHON_PY3                  Defined when using Python with -py3
      SWIGPYTHON_BUILTIN              Defined when using Python with -builtin
      SWIG_RUBY_AUTORENAME            Defined when using Ruby with -autorename

Interface files can look at these symbols as necessary to change the way
in which an interface is generated or to mix SWIG directives with C
code.

Macro Expansion
--------------------

Traditional preprocessor macros can be used in SWIG interfaces. Be aware
that the ``#define`` statement is also used to try and detect constants.
Therefore, if you have something like this in your file,

.. container:: code

   ::

      #ifndef _FOO_H 1
      #define _FOO_H 1
      ...
      #endif

you may get some extra constants such as ``_FOO_H`` showing up in the
scripting interface.

More complex macros can be defined in the standard way. For example:

.. container:: code

   ::

      #define EXTERN extern
      #ifdef __STDC__
      #define ISOC_(args)   (args)
      #else
      #define ISOC_(args) ()
      #endif

The following operators can appear in macro definitions:

-  ``#x``
   Converts macro argument ``x`` to a string surrounded by double quotes
   ("x").
-  ``x ## y``
   Concatenates x and y together to form ``xy``.
-  :literal:`\`x\``
   If ``x`` is a string surrounded by double quotes, do nothing.
   Otherwise, turn into a string like ``#x``. This is a non-standard
   SWIG extension.

SWIG Macros
----------------

SWIG provides an enhanced macro capability with the ``%define`` and
``%enddef`` directives. For example:

.. container:: code

   ::

      %define ARRAYHELPER(type, name)
      %inline %{
      type *new_ ## name (int nitems) {
        return (type *) malloc(sizeof(type)*nitems);
      }
      void delete_ ## name(type *t) {
        free(t);
      }
      type name ## _get(type *t, int index) {
        return t[index];
      }
      void name ## _set(type *t, int index, type val) {
        t[index] = val;
      }
      %}
      %enddef

      ARRAYHELPER(int, IntArray)
      ARRAYHELPER(double, DoubleArray)

The primary purpose of ``%define`` is to define large macros of code.
Unlike normal C preprocessor macros, it is not necessary to terminate
each line with a continuation character (\)--the macro definition
extends to the first occurrence of ``%enddef``. Furthermore, when such
macros are expanded, they are reparsed through the C preprocessor. Thus,
SWIG macros can contain all other preprocessor directives except for
nested ``%define`` statements.

The SWIG macro capability is a very quick and easy way to generate large
amounts of code. In fact, many of SWIG's advanced features and libraries
are built using this mechanism (such as C++ template support).

C99 and GNU Extensions
---------------------------

SWIG-1.3.12 and newer releases support variadic preprocessor macros. For
example:

.. container:: code

   ::

      #define DEBUGF(fmt, ...)   fprintf(stderr, fmt, __VA_ARGS__)

When used, any extra arguments to ``...`` are placed into the special
variable ``__VA_ARGS__``. This also works with special SWIG macros
defined using ``%define``.

SWIG allows a variable number of arguments to be empty. However, this
often results in an extra comma (, ) and syntax error in the resulting
expansion. For example:

.. container:: code

   ::

      DEBUGF("hello");   --> fprintf(stderr, "hello", );

To get rid of the extra comma, use ``##`` like this:

.. container:: code

   ::

      #define DEBUGF(fmt, ...)   fprintf(stderr, fmt, ##__VA_ARGS__)

SWIG also supports GNU-style variadic macros. For example:

.. container:: code

   ::

      #define DEBUGF(fmt, args...)  fprintf(stdout, fmt, args)

**Comment:** It's not entirely clear how variadic macros might be useful
to interface building. However, they are used internally to implement a
number of SWIG directives and are provided to make SWIG more compatible
with C99 code.

Preprocessing and delimiters
---------------------------------

The preprocessor handles { }, " " and %{ %} delimiters differently.

Preprocessing and %{ ... %} & " ... " delimiters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The SWIG preprocessor does not process any text enclosed in a code block
%{ ... %}. Therefore, if you write code like this,

.. container:: code

   ::

      %{
      #ifdef NEED_BLAH
      int blah() {
        ...
      }
      #endif
      %}

the contents of the ``%{ ... %}`` block are copied without modification
to the output (including all preprocessor directives).

Preprocessing and { ... } delimiters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG always runs the preprocessor on text appearing inside ``{ ... }``.
However, sometimes it is desirable to make a preprocessor directive pass
through to the output file. For example:

.. container:: code

   ::

      %extend Foo {
        void bar() {
          #ifdef DEBUG
            printf("I'm in bar\n");
          #endif
        }
      }

By default, SWIG will interpret the ``#ifdef DEBUG`` statement. However,
if you really wanted that code to actually go into the wrapper file,
prefix the preprocessor directives with ``%`` like this:

.. container:: code

   ::

      %extend Foo {
        void bar() {
          %#ifdef DEBUG
            printf("I'm in bar\n");
          %#endif
        }
      }

SWIG will strip the extra ``%`` and leave the preprocessor directive in
the code.

Preprocessor and Typemaps
------------------------------

`Typemaps <Typemaps.html#Typemaps>`__ support a special attribute called
``noblock`` where the { ... } delimiters can be used, but the delimiters
are not actually generated into the code. The effect is then similar to
using "" or %{ %} delimiters but the code **is** run through the
preprocessor. For example:

.. container:: code

   ::

      #define SWIG_macro(CAST) (CAST)$input
      %typemap(in) Int {$1= SWIG_macro(int);}

might generate

.. container:: code

   ::

        {
          arg1=(int)jarg1;
        }

whereas

.. container:: code

   ::

      #define SWIG_macro(CAST) (CAST)$input
      %typemap(in, noblock=1) Int {$1= SWIG_macro(int);}

might generate

.. container:: code

   ::

        arg1=(int)jarg1;

and

.. container:: code

   ::

      #define SWIG_macro(CAST) (CAST)$input
      %typemap(in) Int %{$1=SWIG_macro(int);%}

would generate

.. container:: code

   ::

        arg1=SWIG_macro(int);

Viewing preprocessor output
--------------------------------

Like many compilers, SWIG supports a ``-E`` command line option to
display the output from the preprocessor. When the ``-E`` option is
used, SWIG will not generate any wrappers. Instead the results after the
preprocessor has run are displayed. This might be useful as an aid to
debugging and viewing the results of macro expansions.

The #error and #warning directives
----------------------------------------

SWIG supports the commonly used ``#warning`` and ``#error`` preprocessor
directives. The ``#warning`` directive will cause SWIG to issue a
warning then continue processing. The ``#error`` directive will cause
SWIG to exit with a fatal error. Example usage:

.. container:: code

   ::

      #error "This is a fatal error message"
      #warning "This is a warning message"

The ``#error`` behaviour can be made to work like ``#warning`` if the
``-cpperraswarn`` commandline option is used. Alternatively, the
``#pragma`` directive can be used to the same effect, for example:

.. container:: code

   ::

        /* Modified behaviour: #error does not cause SWIG to exit with error */
        #pragma SWIG cpperraswarn=1
        /* Normal behaviour: #error does cause SWIG to exit with error */
        #pragma SWIG cpperraswarn=0

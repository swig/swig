Wrapper Objects
===============

| David M. Beazley
| dave-swig@dabeaz.com
| January 15, 2007

Introduction
------------

This document describes the functions related to management of wrapper
objects. A wrapper object is a low-level data structure used to contain
the C/C++ code that is emitted during the wrapping process. It contains
not only the emitted code, but information about local variables. These
objects are a critical component of almost all SWIG target language
modules.

The functions described here are declared in ``Source/Swig/swigwrap.h``.
This API is considered to be stable.

Creating and Destroying Wrappers
--------------------------------

The following functions create and destroy wrapper objects.

**``Wrapper *NewWrapper()``**

   Creates a new wrapper object.

**``void DelWrapper(Wrapper *w)``**

   Destroys a wrapper object.

.. _wrapper-objects-1:

Wrapper Objects
---------------

The ``Wrapper`` object returned by ``NewWrapper()`` has three public
attributes.

   ::

      typedef struct Wrapper {
          String *def;
          String *locals;
          String *code;
      } Wrapper;

The ``def`` attribute is a string that holds the function definition
line. This line declares the function name, return type, and parameters.
Language modules create this declaration by simply printing the
appropriate text into this attribute.

The ``locals`` attribute is a string that holds the code related to any
local variables declaration. Normally, language modules do not emit code
to this string directly. They use ``Wrapper_add_local()`` or
``Wrapper_new_local()`` to do this.

The ``code`` attribute is a string that holds code related to the body
of the function. Almost all code emitted by SWIG language modules is
printed into this attribute.

Creating Local Variables
------------------------

Perhaps the most useful aspect of ``Wrapper`` objects is the management
of local variables. When creating a wrapper, it is often necessary to
emit local variables related to the API of the target language. In
addition to this, typemaps and other aspects of SWIG rely upon their own
local variables. The following functions are used to create local
variables, but also provide support for renaming variables in order to
avoid name clashes.

**``int Wrapper_add_local(Wrapper *w, const String_or_char *name, const String_or_char *decl)``**

   Adds a new local variable to the wrapper object. ``name`` is the name
   of the local variable. ``decl`` is a string containing the actual
   variable declaration code. For example, if you wanted to declare a
   variable "``int x = 42;``", you would set ``name`` to ``"x"`` and
   ``decl`` to ``"int x = 42;"``. On success, the text in ``decl`` is
   added to the ``locals`` attribute of ``w`` and 0 is returned. -1 is
   returned if a variable with the given name has already been declared.

**``int Wrapper_add_localv(Wrapper *w, const String_or_char *name, ...)``**

   The same as ``Wrapper_add_local()`` except that instead of passing a
   single string for the declaration, a NULL-terminated list of strings
   can be passed. These strings are joined together when producing the
   output. This convention turns out to be fairly useful since language
   modules often create their output into pieces.

**``char * Wrapper_new_local(Wrapper *w, const String_or_char *name, const String_or_char *decl)``**

   The same as ``Wrapper_add_local()`` except that if a local variable
   with the given name already exists, this function picks a new name
   and adds the declaration using the new name. The actual name used for
   the variable is returned. This function is used when generating code
   originating from typemaps. For instance, if a typemap declares a
   local variable, that variable might have to be renamed if the same
   typemap is used more than once in the same function.

**``char * Wrapper_new_localv(Wrapper *w, const String_or_char *name,...)``**

   The same as ``Wrapper_new_localv()``, but accepts a NULL-terminated
   list of strings as code output.

**``int Wrapper_check_local(Wrapper *w, const String_or_char *name)``**

   Checks to see if a local variable with name ``name`` has been
   declared. Returns 1 if the local is defined, 0 otherwise.

Output
------

**``void Wrapper_print(Wrapper *w, File *f)``**

   This function is used to format a wrapper function for output. The
   formatted wrapper function is emitted to ``f`` which may be any
   file-like object including a ``FILE *`` object or a ``String *``
   object. When emitting the wrapper, the code printed to the wrapper
   object is automatically formatted. By default, the formatting is done
   according to a "pretty printing" style in which lines are split onto
   multiple lines and indented according to reasonable C formatting
   rules. This produces code that is moderately readable should you want
   to look at the wrapper code output. An alternative output mode is
   "compact printing" in which lines are collected and compacted. This
   may result in multiple C statements appearing on the same line. This
   mode is sometimes used when the size of a wrapper file is too large
   for certain compilers. For example, some compilers might impose a
   limit of 65536 lines per source file.

**``void Wrapper_compact_print_mode_set(int flag)``**

   Sets the output mode of the ``Wrapper_print()`` function. If ``flag``
   is set to 1, then wrapper code is formatted to be compact.

**``void Wrapper_pretty_print(String *str, File *f)``**

   Utility function that reformats a string containing C/C++ code and
   outputs it to the file-like object ``f``. The formatting process
   indents the code and structures it according to reasonable C
   formatting rules.

**``void Wrapper_compact_print(String *str, File *f)``**

   Utility function that reformats a string containing C/C++ code and
   outputs it to the file-like object ``f``. The formatting process
   tries to make the code as compact as possible, without going
   completely overboard. For example, multiple C statements may be
   combined onto a single line and braces may be aligned to not use up
   extra lines.

An Example
----------

Here is a simple example of how these functions are used. Suppose you
wanted to emit the following C function:

   ::

      void foo(int n) {
         int i;
         for (i = 0; i < n; i++) {
             printf("%d\n", i);
         }
      }

Here is code that generates the above function:

   ::

      Wrapper *w = NewWrapper();
      Printf(w->def,"void foo(int n) {");
      Wrapper_add_local(w,"n","");         /* parameter n */
      Wrapper_add_local(w,"i", "int i;");  /* local i */
      Printv(w->code,"for (i = 0; i < n; i++) {",
                     "printf(\"%d\n",i);",
                     "}\n", NIL);
      Printf(w->code,"}\n");

      /* Emit wrapper code */
      Wrapper_print(w,outf);
      DelWrapper(w);

Within different language modules, this process is obviously much more
involved. However, this example shows the basic idea of how C/C++ code
is prepared for output.

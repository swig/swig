Scripting Languages
=====================

This chapter provides a brief overview of scripting language extension
programming and the mechanisms by which scripting language interpreters
access C and C++ code.

The two language view of the world
--------------------------------------

When a scripting language is used to control a C program, the resulting
system tends to look as follows:

|Scripting language input - C/C++ functions output|

In this programming model, the scripting language interpreter is used
for high level control whereas the underlying functionality of the C/C++
program is accessed through special scripting language "commands." If
you have ever tried to write your own simple command interpreter, you
might view the scripting language approach to be a highly advanced
implementation of that. Likewise, If you have ever used a package such
as MATLAB or IDL, it is a very similar model--the interpreter executes
user commands and scripts. However, most of the underlying functionality
is written in a low-level language like C or Fortran.

The two-language model of computing is extremely powerful because it
exploits the strengths of each language. C/C++ can be used for maximal
performance and complicated systems programming tasks. Scripting
languages can be used for rapid prototyping, interactive debugging,
scripting, and access to high-level data structures such associative
arrays.

How does a scripting language talk to C?
--------------------------------------------

Scripting languages are built around a parser that knows how to execute
commands and scripts. Within this parser, there is a mechanism for
executing commands and accessing variables. Normally, this is used to
implement the builtin features of the language. However, by extending
the interpreter, it is usually possible to add new commands and
variables. To do this, most languages define a special API for adding
new commands. Furthermore, a special foreign function interface defines
how these new commands are supposed to hook into the interpreter.

Typically, when you add a new command to a scripting interpreter you
need to do two things; first you need to write a special "wrapper"
function that serves as the glue between the interpreter and the
underlying C function. Then you need to give the interpreter information
about the wrapper by providing details about the name of the function,
arguments, and so forth. The next few sections illustrate the process.

Wrapper functions
~~~~~~~~~~~~~~~~~~~~~~~

Suppose you have an ordinary C function like this :

.. container:: code

   ::

      int fact(int n) {
        if (n <= 1)
          return 1;
        else
          return n*fact(n-1);
      }

In order to access this function from a scripting language, it is
necessary to write a special "wrapper" function that serves as the glue
between the scripting language and the underlying C function. A wrapper
function must do three things :

-  Gather function arguments and make sure they are valid.
-  Call the C function.
-  Convert the return value into a form recognized by the scripting
   language.

As an example, the Tcl wrapper function for the ``fact()`` function
above example might look like the following :

.. container:: code

   ::

      int wrap_fact(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
        int result;
        int arg0;
        if (argc != 2) {
          interp->result = "wrong # args";
          return TCL_ERROR;
        }
        arg0 = atoi(argv[1]);
        result = fact(arg0);
        sprintf(interp->result, "%d", result);
        return TCL_OK;
      }

Once you have created a wrapper function, the final step is to tell the
scripting language about the new function. This is usually done in an
initialization function called by the language when the module is
loaded. For example, adding the above function to the Tcl interpreter
requires code like the following :

.. container:: code

   ::

      int Wrap_Init(Tcl_Interp *interp) {
        Tcl_CreateCommand(interp, "fact", wrap_fact, (ClientData) NULL,
                          (Tcl_CmdDeleteProc *) NULL);
        return TCL_OK;
      }

When executed, Tcl will now have a new command called "``fact``" that
you can use like any other Tcl command.

Although the process of adding a new function to Tcl has been
illustrated, the procedure is almost identical for Perl and Python. Both
require special wrappers to be written and both need additional
initialization code. Only the specific details are different.

Variable linking
~~~~~~~~~~~~~~~~~~~~~~

Variable linking refers to the problem of mapping a C/C++ global
variable to a variable in the scripting language interpreter. For
example, suppose you had the following variable:

.. container:: code

   ::

      double Foo = 3.5;

It might be nice to access it from a script as follows (shown for Perl):

.. container:: targetlang

   ::

      $a = $Foo * 2.3;   # Evaluation
      $Foo = $a + 2.0;   # Assignment

To provide such access, variables are commonly manipulated using a pair
of get/set functions. For example, whenever the value of a variable is
read, a "get" function is invoked. Similarly, whenever the value of a
variable is changed, a "set" function is called.

In many languages, calls to the get/set functions can be attached to
evaluation and assignment operators. Therefore, evaluating a variable
such as ``$Foo`` might implicitly call the get function. Similarly,
typing ``$Foo = 4`` would call the underlying set function to change the
value.

Constants
~~~~~~~~~~~~~~~

In many cases, a C program or library may define a large collection of
constants. For example:

.. container:: code

   ::

      #define RED   0xff0000
      #define BLUE  0x0000ff
      #define GREEN 0x00ff00

To make constants available, their values can be stored in scripting
language variables such as ``$RED``, ``$BLUE``, and ``$GREEN``.
Virtually all scripting languages provide C functions for creating
variables so installing constants is usually a trivial exercise.

Structures and classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Although scripting languages have no trouble accessing simple functions
and variables, accessing C/C++ structures and classes present a
different problem. This is because the implementation of structures is
largely related to the problem of data representation and layout.
Furthermore, certain language features are difficult to map to an
interpreter. For instance, what does C++ inheritance mean in a Perl
interface?

The most straightforward technique for handling structures is to
implement a collection of accessor functions that hide the underlying
representation of a structure. For example,

.. container:: code

   ::

      struct Vector {
        Vector();
        ~Vector();
        double x, y, z;
      };

can be transformed into the following set of functions :

.. container:: code

   ::

      Vector *new_Vector();
      void delete_Vector(Vector *v);
      double Vector_x_get(Vector *v);
      double Vector_y_get(Vector *v);
      double Vector_z_get(Vector *v);
      void Vector_x_set(Vector *v, double x);
      void Vector_y_set(Vector *v, double y);
      void Vector_z_set(Vector *v, double z);

Now, from an interpreter these function might be used as follows:

.. container:: targetlang

   ::

      % set v [new_Vector]
      % Vector_x_set $v 3.5
      % Vector_y_get $v
      % delete_Vector $v
      % ...

Since accessor functions provide a mechanism for accessing the internals
of an object, the interpreter does not need to know anything about the
actual representation of a ``Vector``.

Proxy classes
~~~~~~~~~~~~~~~~~~~

In certain cases, it is possible to use the low-level accessor functions
to create a proxy class, also known as a shadow class. A proxy class is
a special kind of object that gets created in a scripting language to
access a C/C++ class (or struct) in a way that looks like the original
structure (that is, it proxies the real C++ class). For example, if you
have the following C++ definition :

.. container:: code

   ::

      class Vector {
      public:
        Vector();
        ~Vector();
        double x, y, z;
      };

A proxy classing mechanism would allow you to access the structure in a
more natural manner from the interpreter. For example, in Python, you
might want to do this:

.. container:: targetlang

   ::

      >>> v = Vector()
      >>> v.x = 3
      >>> v.y = 4
      >>> v.z = -13
      >>> ...
      >>> del v

Similarly, in Perl5 you may want the interface to work like this:

.. container:: targetlang

   ::

      $v = new Vector;
      $v->{x} = 3;
      $v->{y} = 4;
      $v->{z} = -13;

Finally, in Tcl :

.. container:: targetlang

   ::

      Vector v
      v configure -x 3 -y 4 -z -13

When proxy classes are used, two objects are really at work--one in the
scripting language, and an underlying C/C++ object. Operations affect
both objects equally and for all practical purposes, it appears as if
you are simply manipulating a C/C++ object.

Building scripting language extensions
------------------------------------------

The final step in using a scripting language with your C/C++ application
is adding your extensions to the scripting language itself. There are
two primary approaches for doing this. The preferred technique is to
build a dynamically loadable extension in the form of a shared library.
Alternatively, you can recompile the scripting language interpreter with
your extensions added to it.

Shared libraries and dynamic loading
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To create a shared library or DLL, you often need to look at the manual
pages for your compiler and linker. However, the procedure for a few
common platforms is shown below:

.. container:: shell

   ::

      # Build a shared library for Solaris
      gcc -fpic -c example.c example_wrap.c -I/usr/local/include
      ld -G example.o example_wrap.o -o example.so

      # Build a shared library for Linux
      gcc -fpic -c example.c example_wrap.c -I/usr/local/include
      gcc -shared example.o example_wrap.o -o example.so

To use your shared library, you simply use the corresponding command in
the scripting language (load, import, use, etc...). This will import
your module and allow you to start using it. For example:

.. container:: targetlang

   ::

      % load ./example.so
      % fact 4
      24
      %

When working with C++ codes, the process of building shared libraries
may be more complicated--primarily due to the fact that C++ modules may
need additional code in order to operate correctly. On many machines,
you can build a shared C++ module by following the above procedures, but
changing the link line to the following :

.. container:: shell

   ::

      c++ -shared example.o example_wrap.o -o example.so

Linking with shared libraries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When building extensions as shared libraries, it is not uncommon for
your extension to rely upon other shared libraries on your machine. In
order for the extension to work, it needs to be able to find all of
these libraries at run-time. Otherwise, you may get an error such as the
following :

.. container:: targetlang

   ::

      >>> import graph
      Traceback (innermost last):
        File "<stdin>", line 1, in ?
        File "/home/sci/data1/beazley/graph/graph.py", line 2, in ?
          import graphc
      ImportError:  1101:/home/sci/data1/beazley/bin/python: rld: Fatal Error: cannot 
      successfully map soname 'libgraph.so' under any of the filenames /usr/lib/libgraph.so:/
      lib/libgraph.so:/lib/cmplrs/cc/libgraph.so:/usr/lib/cmplrs/cc/libgraph.so:
      >>>

What this error means is that the extension module created by SWIG
depends upon a shared library called "``libgraph.so``" that the system
was unable to locate. To fix this problem, there are a few approaches
you can take.

-  Link your extension and explicitly tell the linker where the required
   libraries are located. Often times, this can be done with a special
   linker flag such as ``-R``, ``-rpath``, etc. This is not implemented
   in a standard manner so read the man pages for your linker to find
   out more about how to set the search path for shared libraries.
-  Put shared libraries in the same directory as the executable. This
   technique is sometimes required for correct operation on non-Unix
   platforms.
-  Set the UNIX environment variable ``LD_LIBRARY_PATH`` to the
   directory where shared libraries are located before running Python.
   Although this is an easy solution, it is not recommended. Consider
   setting the path using linker options instead.

Static linking
~~~~~~~~~~~~~~~~~~~~

With static linking, you rebuild the scripting language interpreter with
extensions. The process usually involves compiling a short main program
that adds your customized commands to the language and starts the
interpreter. You then link your program with a library to produce a new
scripting language executable.

Although static linking is supported on all platforms, this is not the
preferred technique for building scripting language extensions. In fact,
there are very few practical reasons for doing this--consider using
shared libraries instead.

.. |Scripting language input - C/C++ functions output| image:: ch2.1.png

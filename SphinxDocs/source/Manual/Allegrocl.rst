SWIG and Allegro Common Lisp
===============================

This chapter describes SWIG's support of Allegro Common Lisp. Allegro CL
is a full-featured implementation of the Common Lisp language standard
that includes many vendor-specific enhancements and add-on modules for
increased usability.

One such module included in Allegro CL is the Foreign Functions
Interface (FFI). This module, tailored primarily toward interfacing with
C/C++ and, historically, Fortran, provides a means by which compiled
foreign code can be loaded into a running lisp environment and executed.
The interface supports the calling of foreign functions and methods,
allows for executing lisp routines from foreign code (callbacks), and
the passing of data between foreign and lisp code.

The goal of this module is to make it possible to quickly generate the
necessary foreign function definitions so one can make use of C/C++
foreign libraries directly from lisp without the tedium of having to
code them by hand. When necessary, it will also generate further C/C++
code that will need to be linked with the intended library for proper
interfacing from lisp. It has been designed with an eye toward
flexibility. Some foreign function calls may release the heap, while
other should not. Some foreign functions should automatically convert
lisp strings into native strings, while others should not. These
adjustments and many more are possible with the current module.

It is significant to note that, while this is a vendor-specific module,
we would like to acknowledge the current and ongoing work by developers
in the open source lisp community that are working on similar interfaces
to implementation-independent foreign function interfaces (CFFI, for
example). Such work can only benefit the lisp community, and we would
not be unhappy to see some enterprising folk use this work to add to it.

Basics
-----------

Running SWIG
~~~~~~~~~~~~~~~~~~~

If you're reading this, you must have some library you need to generate
an interface for. In order for SWIG to do this work, however, it needs a
bit of information about how it should go about creating your interface,
and what you are interfacing to.

SWIG expects a description of what in the foreign interface you wish to
connect to. It must consisting of C/C++ declarations and special SWIG
directives. SWIG can be furnished with a header file, but an interface
can also be generated without library headers by supplying a simple text
file--called the interface file, which is typically named with a ``.i``
extension--containing any foreign declarations of identifiers you wish
to use. The most common approach is to use an interface file with
directives to parse the needed headers. A straight parse of library
headers will result in usable code, but SWIG directives provides much
freedom in how a user might tailor the generated code to their needs or
style of coding.

Note that SWIG does not require any function definitions; the
declarations of those functions is all that is necessary. Be careful
when tuning the interface as it is quite possible to generate code that
will not load or compile.

An example interface file is shown below. It makes use of two SWIG
directives, one of which requests that the declarations in a header file
be used to generate part of the interface, and also includes an
additional declaration to be added.

.. container:: code

   example.i
   ::

      %module example

      %include "header.h"

      int fact(int n);

The contents of header.h are very simple:

.. container:: code

   header.h
   ::

      int fact(char *statement);   // pass it a fact, and it will rate it.

The contents of example.cl will look like this:

.. container:: targetlang

   example.cl
   ::

      (defpackage :example
        (:use :common-lisp :swig :ff :excl))

        ... helper routines for defining the interface ...

      (swig-in-package ())

      (swig-defun ("fact")
        ((PARM0_statement cl:string (* :char) ))
        (:returning (:int )
         :strings-convert t)
        (let ((SWIG_arg0 PARM0_statement))
        (swig-ff-call SWIG_arg0)))

      (swig-defun ("fact")
        ((PARM0_n cl:integer :int ))
        (:returning (:int )
         :strings-convert t)
        (let ((SWIG_arg0 PARM0_n))
        (swig-ff-call SWIG_arg0)))

      (swig-dispatcher ("fact" :type :function :arities (1)))

The generated file contains calls to internal swig helper functions. In
this case there are two calls to swig-defun. These calls will expand
into code that will make the appropriate definitions using the Allegro
FFI. Note also, that this code is **erroneous**. Function overloading is
not supported in C, and this code will not compile even though SWIG did
not complain.

In order to generate a C interface to Allegro CL using this code run
swig using the ``-allegrocl`` option, as below:

.. container:: shell

   ::

      % swig -allegrocl example.i

When building an interface to C++ code, include the ``-c++`` option:

.. container:: shell

   ::

      % swig -allegrocl -c++ example.i

As a result of running one of the above commands, a file named
``example.cl`` will be generated containing the lisp side of the
interface. As well, a file ``example_wrap.cxx`` is also generated,
containing C/C++ wrapper code to facilitate access to C++ methods,
enumeration values, and constant values. Wrapper functions are necessary
in C++ due to the lack of a standard for mangling the names of symbols
across all C++ compilers. These wrapper functions are exported from the
shared library as appropriate, using the C name mangling convention. The
lisp code that is generated will interface to your foreign library
through these wrappers.

It is possible to disable the creation of the .cxx file when generating
a C interface by using the -nocwrap command-line argument. For
interfaces that don't contain complex enum or constant expressions,
contain nested struct/union declarations, or doesn't need to use many of
the SWIG customization featuers, this will result in a more streamlined,
direct interface to the intended module.

The generated wrapper file is below. It contains very simple wrappers by
default, that simply pass the arguments to the actual function.

.. container:: code

   example_wrap.i
   ::

        ... lots of SWIG internals ...

      EXPORT int ACL___fact__SWIG_0 (char *larg1) {
        int lresult = (int)0 ;
        char *arg1 = (char *) 0 ;
        int result;

        arg1 = larg1;
        try {
          result = (int)fact(arg1);

          lresult = result;
          return lresult;
        } catch (...) {
          return (int)0;
        }
      }


      EXPORT int ACL___fact__SWIG_1 (int larg1) {
        int lresult = (int)0 ;
        int arg1 ;
        int result;

        arg1 = larg1;
        try {
          result = (int)fact(arg1);

          lresult = result;
          return lresult;
        } catch (...) {
          return (int)0;
        }
      }

And again, the generated lisp code. Note that it differs from what is
generated when parsing C code:

.. container:: targetlang

   ::

        ...

      (swig-in-package ())

      (swig-defmethod ("fact" "ACL___fact__SWIG_0" :type :function :arity 1)
        ((PARM0_statement cl:string (* :char) ))
        (:returning (:int )
         :strings-convert t)
        (let ((SWIG_arg0 PARM0_statement))
        (swig-ff-call SWIG_arg0)))

      (swig-defmethod ("fact" "ACL___fact__SWIG_1" :type :function :arity 1)
        ((PARM0_n cl:integer :int ))
        (:returning (:int )
         :strings-convert t)
        (let ((SWIG_arg0 PARM0_n))
        (swig-ff-call SWIG_arg0)))

      (swig-dispatcher ("fact" :type :function :arities (1)))

In this case, the interface generates two swig-defmethod forms and a
swig-dispatcher form. This provides a single functional interface for
all overloaded routines. A more detailed description of this features is
to be found in the section titled **Function overloading/Parameter
defaulting**.

In order to load a C++ interface, you will need to build a shared
library from example_wrap.cxx. Be sure to link in the actual library you
created the interface for, as well as any other dependent shared
libraries. For example, if you intend to be able to call back into lisp,
you will also need to link in the Allegro shared library. The library
you create from the C++ wrapper will be what you then load into Allegro
CL.

Command Line Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are three Allegro CL specific command-line option:

.. container:: shell

   ::

      swig -allegrocl [ options ] filename

         -identifier-converter [name] - Binds the variable swig:*swig-identifier-convert* 
                                        in the generated .cl file to name.
                                        This function is used to generate symbols
                                        for the lisp side of the interface.

         -cwrap - [default] Generate a .cxx file containing C wrapper function when
                  wrapping C code. The interface generated is similar to what is
                  done for C++ code.
         -nocwrap - Explicitly turn off generation of .cxx wrappers for C code. Reasonable
                    for modules with simple interfaces. Can not handle all legal enum
                    and constant constructs, or take advantage of SWIG customization features.

         -isolate - With this command-line argument, all lisp helper functions are defined
                    in a unique package named swig.<module-name> rather than
                    swig. This prevents conflicts when the module is
                    intended to be used with other swig generated interfaces that may,
                    for instance, make use of different identifier converters.

See `Section 17.5 Identifier converter functions <#Allegrocl_nn47>`__
for more details.

Inserting user code into generated files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is often necessary to include user-defined code into the
automatically generated interface files. For example, when building a
C++ interface, example_wrap.cxx will likely not compile unless you add a
``#include "header.h"`` directive. This can be done using the SWIG
``%insert(section) %{ ...code... %}`` directive:

.. container:: code

   ::

      %module example

      %{
      #include "header.h"
      %}

      %include "header.h"

      int fact(int n);

Additional sections have been added for inserting into the generated
lisp interface file

-  ``lisphead`` - inserts before type declarations
-  ``lisp`` - inserts after type declarations according to where it
   appears in the .i file

Note that the block ``%{ ... %}`` is effectively a shortcut for
``%insert("header") %{ ... %}``.

Wrapping Overview
----------------------

New users to SWIG are encouraged to read `SWIG
Basics <SWIG.html#SWIG>`__, and `SWIG and
C++ <SWIGPlus.html#SWIGPlus>`__, for those interested in generating an
interface to C++.

Function Wrapping
~~~~~~~~~~~~~~~~~~~~~~~~

Writing lisp code that directly invokes functions at the foreign
function interface level can be cumbersome. Data must often be
translated between lisp and foreign types, data extracted from objects,
foreign objects allocated and freed upon completion of the foreign call.
Dealing with pointers can be unwieldy when it comes to keeping them
distinct from other valid integer values.

We make an attempt to ease some of these burdens by making the interface
to foreign code much more lisp-like, rather than C like. How this is
done is described in later chapters. The layers themselves, appear as
follows:

.. container:: diagram

   ::

              ______________
             |              |  (foreign side)
             | Foreign Code |  What we're generating an interface to.
             |______________|
                     |
                     |
              _______v______
             |              |  (foreign side)
             | Wrapper code |  extern "C" wrappers calling C++ 
             |______________|  functions and methods.
                     |
          .  . . - - + - - . .  .
              _______v______
             |              |  (lisp side)
             |  FFI Layer   |  Low level lisp interface. ff:def-foreign-call,
             |______________|  ff:def-foreign-variable
                     |
                     +----------------------------
              _______v______              _______v______
             |              |            |              | (lisp side)    
             |    Defuns    |            |  Defmethods  | wrapper for overloaded
             |______________|            |______________| functions or those with
              (lisp side)                        |        defaulted arguments
              Wrapper for non-overloaded         |
              functions and methods       _______v______
                                         |              | (lisp side)
                                         |    Defuns    | dispatch function
                                         |______________| to overloads based
                                                          on arity
        

Foreign Wrappers
~~~~~~~~~~~~~~~~~~~~~~~

These wrappers are as generated by SWIG default. The types of function
parameters can be transformed in place using the CTYPE typemap. This is
use for converting pass-by-value parameters to pass-by-reference where
necessary. All wrapper parameters are then bound to local variables for
possible transformation of values (see LIN typemap). Return values can
be transformed via the OUT typemap.

FFI Wrappers
~~~~~~~~~~~~~~~~~~~

These are the generated ff:def-foreign-call forms. No typemaps are
applicable to this layer, but the ``%ffargs`` directive is available for
use in .i files, to specify which keyword arguments should be specified
for a given function.

.. container:: code

   ffargs.i:
   ::

      %module ffargs

      %ffargs(strings_convert="nil", call_direct="t") foo;
      %ffargs(strings_convert="nil", release_heap=":never", optimize_for_space="t") bar;

      int foo(float f1, float f2);
      int foo(float f1, char c2);

      void bar(void *lisp_fn);

      char *xxx();
        

Generates:

.. container:: targetlang

   ffargs.cl:
   ::

      (swig-in-package ())

      (swig-defmethod ("foo" "ACL___foo__SWIG_0" :type :function :arity 2)
        ((PARM0_f1 cl:single-float :float )
         (PARM1_f2 cl:single-float :float ))
        (:returning (:int )
         :call-direct t
         :strings-convert nil)
        (let ((SWIG_arg0 PARM0_f1))
        (let ((SWIG_arg1 PARM1_f2))
        (swig-ff-call SWIG_arg0 SWIG_arg1))))

      (swig-defmethod ("foo" "ACL___foo__SWIG_1" :type :function :arity 2)
        ((PARM0_f1 cl:single-float :float )
         (PARM1_c2 cl:character :char character))
        (:returning (:int )
         :call-direct t
         :strings-convert nil)
        (let ((SWIG_arg0 PARM0_f1))
        (let ((SWIG_arg1 PARM1_c2))
        (swig-ff-call SWIG_arg0 SWIG_arg1))))

      (swig-dispatcher ("foo" :type :function :arities (2)))
      (swig-defun ("bar" "ACL___bar__SWIG_0" :type :function)
        ((PARM0_lisp_fn  (* :void) ))
        (:returning (:void )
         :release-heap :never
         :optimize-for-space t
         :strings-convert nil)
        (let ((SWIG_arg0 PARM0_lisp_fn))
        (swig-ff-call SWIG_arg0)))


      (swig-defun ("xxx" "ACL___xxx__SWIG_0" :type :function)
        (:void)
        (:returning ((* :char) )
         :strings-convert t)
        (swig-ff-call))
        

.. container:: code

   ::

      %ffargs(strings_convert="t");

Is the only default value specified in ``allegrocl.swg`` to force the
muffling of warnings about automatic string conversion when defining
ff:def-foreign-call's.

Non-overloaded Defuns
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These are simple defuns. There is no typechecking of arguments.
Parameters are bound to local variables for possible transformation of
values, such as pulling values out of instance slots or allocating
temporary stack allocated structures, via the ``lin`` typemap. These
arguments are then passed to the foreign-call (where typechecking may
occur). The return value from this function can be manipulated via the
``lout`` typemap.

Overloaded Defuns
~~~~~~~~~~~~~~~~~~~~~~~~

In the case of overloaded functions, multiple layers are generated.
First, all the overloads for a given name are separated out into groups
based on arity, and are wrapped in defmethods. Each method calls a
distinct wrapper function, but are themselves distinguished by the types
of their arguments (see ``lispclass`` typemap). These are further
wrapped in a dispatching function (defun) which will invoke the
appropriate generic-function based on arity. This provides a single
functional interface to all overloads. The return value from this
function can be manipulated via the ``lout`` typemap.

What about constant and variable access?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Along with the described functional layering, when creating a .cxx
wrapper, this module will generate getter and--if not immutable--setter,
functions for variables and constants. If the -nocwrap option is used,
``defconstant`` and ``ff:def-foreign-variable`` forms will be generated
for accessing constants and global variables. These, along with the
``defuns`` listed above are the intended API for calling into the
foreign module.

Object Wrapping
~~~~~~~~~~~~~~~~~~~~~~

All non-primitive types (Classes, structs, unions, and typedefs
involving same) have a corresponding foreign-type defined on the lisp
side via ff:def-foreign-type.

All non-primitive types are further represented by a CLOS class, created
via defclass. An attempt is made to create the same class hierarchy,
with all classes inheriting directly or indirectly from
ff:foreign-pointer. Further, wherever it is apparent, all pointers
returned from foreign code are wrapped in a CLOS instance of the
appropriate class. For ff:def-foreign-calls that have been defined to
expect a :foreign-address type as argument, these CLOS instances can
legally be passed and the pointer to the C++ object automatically
extracted. This is a natural feature of Allegro's foreign function
interface.

Wrapping Details
---------------------

In this section is described how particular C/C++ constructs are
translated into lisp.

Namespaces
~~~~~~~~~~~~~~~~~

C++ namespaces are translated into Lisp packages by SWIG. The Global
namespace is mapped to a package named by the ``%module`` directive or
the ``-module`` command-line argument. Further namespaces are generated
by the ``swig-defpackage`` utility function and given names based on
Allegro CLs nested namespace convention. For example:

.. container:: code

   foo.i:
   ::

      %module foo

      %{
      #include "foo.h"
      %}

      %include "foo.h"

      namespace car {
        ...
        namespace tires {
          int do_something(int n);
        }
      }
          

Generates the following code.

.. container:: targetlang

   foo.cl
   ::

      (defpackage :foo
        (:use :common-lisp :swig :ff :excl))

      ...

      (swig-defpackage ("car"))
      (swig-defpackage ("car" "tires"))

      ...

      (swig-in-package ("car" "tires"))
      (swig-defun ("do_something" "ACL_car_tires__do_something__SWIG_0" :type :function)
        ((PARM0_n  :int ))
        (:returning (:int )
         :strings-convert t)
        (let ((SWIG_arg0 PARM0_n))
        (swig-ff-call SWIG_arg0)))
          

The above interface file would cause packages foo, foo.car, and
foo.car.tires to be created. One would find the function wrapper for
do_something defined in the foo.car.tires package(*).

(**\***) Except for the package named by the module, all namespace names
are passed to the identifier-converter-function as strings with a
``:type`` of ``:namespace``. It is the job of this function to generate
the desired symbol, accounting for case preferences, additional naming
cues, etc.

Note that packages created by ``swig-defpackage`` do not use the
COMMON-LISP or EXCL package. This reduces possible conflicts when
defining foreign types via the SWIG interface in **all but the toplevel
modules package**. This may lead to confusion if, for example, the
current package is ``foo.car.tires`` and you attempt to use a
common-lisp function such as ``(car '(1 2 3)``.

Constants
~~~~~~~~~~~~~~~~

Constants, as declared by the preprocessor #define macro or SWIG
``%constant`` directive, are included in SWIG's parse tree when it can
be determined that they are, or could be reduced to, a literal value.
Such values are translated into defconstant forms in the generated lisp
wrapper when the -nocwrap command-line options is used. Else, wrapper
functions are generated as in the case of variable access (see section
below).

Here are examples of simple preprocessor constants when using -nocwrap.

.. container:: code

   ::

      #define A 1                    => (swig-defconstant "A" 1)  
      #define B 'c'                  => (swig-defconstant "B" #\c)
      #define C B                    => (swig-defconstant "C" #\c)
      #define D 1.0e2                => (swig-defconstant "D" 1.0d2)
      #define E 2222                 => (swig-defconstant "E" 2222)
      #define F (unsigned int)2222   => no code generated
      #define G 1.02e2f              => (swig-defconstant "G" 1.02f2)
      #define H foo                  => no code generated
            

Note that where SWIG is unable to determine if a constant is a literal,
no node is added to the SWIG parse tree, and so no values can be
generated.

For preprocessor constants containing expressions which can be reduced
to literal values, nodes are created, but with no simplification of the
constant value. A very very simple infix to prefix converter has been
implemented that tries to do the right thing for simple cases, but does
not for more complex expressions. If the literal parser determines that
something is wrong, a warning will be generated and the literal
expression will be included in the generated code, but commented out.

.. container:: code

   ::

      #define I A + E                => (swig-defconstant "I" (+ 1 2222))
      #define J 1|2                  => (swig-defconstant "J" (logior 1 2))
      #define Y 1 + 2 * 3 + 4        => (swig-defconstant "Y" (* (+ 1 2) (+ 3 4)))
      #define Y1 (1 + 2) * (3 + 4)   => (swig-defconstant "Y1" (* (+ 1 2) (+ 3 4)))
      #define Y2 1 * 2 + 3 * 4       => (swig-defconstant "Y2" (* 1 (+ 2 3) 4))  ;; WRONG
      #define Y3 (1 * 2) + (3 * 4)   => (swig-defconstant "Y3" (* 1 (+ 2 3) 4))  ;; WRONG
      #define Z 1 + 2 - 3 + 4 * 5    => (swig-defconstant "Z" (* (+ 1 (- 2 3) 4) 5)) ;; WRONG
            

Users are cautioned to get to know their constants before use, or not
use the ``-nocwrap`` command-line option.

Variables
~~~~~~~~~~~~~~~~

For C wrapping, a def-foreign-variable call is generated for access to
global variables.

When wrapping C++ code, both global and member variables, getter
wrappers are generated for accessing their value, and if not immutable,
setter wrappers as well. In the example below, note the lack of a setter
wrapper for global_var, defined as const.

.. container:: code

   vars.h
   ::

      namespace nnn {
        int const global_var = 2;
        float glob_float = 2.0;
      }
          

Generated code:

.. container:: targetlang

   vars.cl
   ::

      (swig-in-package ("nnn"))
      (swig-defun ("global_var" "ACL_nnn__global_var_get__SWIG_0" :type :getter)
        (:void)
        (:returning (:int )
         :strings-convert t)
        (swig-ff-call))


      (swig-defun ("glob_float" "ACL_nnn__glob_float_set__SWIG_0" :type :setter)
        ((PARM0_glob_float  :float ))
        (:returning (:void )
         :strings-convert t)
        (let ((SWIG_arg0 PARM0_glob_float))
        (swig-ff-call SWIG_arg0)))


      (swig-defun ("glob_float" "ACL_nnn__glob_float_get__SWIG_0" :type :getter)
        (:void)
        (:returning (:float )
         :strings-convert t)
        (swig-ff-call))
          

Note also, that where applicable, setter wrappers are implemented as
setf methods on the getter function, providing a lispy interface to the
foreign code.

.. container:: targetlang

   ::

      user> (load "globalvar.dll")
      ; Foreign loading globalvar.dll.
      t
      user> (load "globalvar.cl")
      ; Loading c:\mikel\src\swig\test\globalvar.cl
      t
      user> 
      globalvar> (globalvar.nnn::global_var)
      2
      globalvar> (globalvar.nnn::glob_float)
      2.0
      globalvar> (setf (globalvar.nnn::glob_float) 3.0)
      3.0
      globalvar> (globalvar.nnn::glob_float)
      3.0
          

Enumerations
~~~~~~~~~~~~~~~~~~~

In C, an enumeration value is an integer value, while in C++ an
enumeration value is implicitly convertible to an integer value, but can
also be distinguished by its enum type. For each enum declaration a
def-foreign-type is generated, assigning the enum a default type of
:int. Users may adjust the foreign type of enums via SWIG ``typemaps``.

Enum values are a bit trickier as they can be initialized using any
valid C/C++ expression. In C with the -nocwrap command-line option, we
handle the typical cases (simple integer initialization) and generate a
defconstant form for each enum value. This has the advantage of it not
being necessary to probe into foreign space to retrieve enum values.
When generating a .cxx wrapper file, a more general solution is
employed. A wrapper variable is created in the module_wrap.cxx file, and
a ff:def-foreign-variable call is generated to retrieve its value into
lisp.

For example, the following header file

.. container:: code

   enum.h:
   ::

      enum COL { RED, GREEN, BLUE };
      enum FOO { FOO1 = 10, FOO2, FOO3 };
            

In -nocwrap mode, generates

.. container:: targetlang

   enum.cl:
   ::

      (swig-def-foreign-type "COL" :int)
      (swig-defconstant "RED" 0)
      (swig-defconstant "GREEN" (+ #.(swig-insert-id "RED" () :type :constant) 1))
      (swig-defconstant "BLUE" (+ #.(swig-insert-id "GREEN" () :type :constant) 1))

      (swig-def-foreign-type "FOO" :int)
      (swig-defconstant "FOO1" 10)
      (swig-defconstant "FOO2" (+ #.(swig-insert-id "FOO1" () :type :constant) 1))
      (swig-defconstant "FOO3" (+ #.(swig-insert-id "FOO2" () :type :constant) 1))
            

And when generating a .cxx wrapper

.. container:: code

   enum_wrap.cxx:
   ::

      EXPORT const int ACL_ENUM___RED__SWIG_0 = RED;
      EXPORT const int ACL_ENUM___GREEN__SWIG_0 = GREEN;
      EXPORT const int ACL_ENUM___BLUE__SWIG_0 = BLUE;
      EXPORT const int ACL_ENUM___FOO1__SWIG_0 = FOO1;
      EXPORT const int ACL_ENUM___FOO2__SWIG_0 = FOO2;
      EXPORT const int ACL_ENUM___FOO3__SWIG_0 = FOO3;
            

and

.. container:: targetlang

   enum.cl:
   ::

      (swig-def-foreign-type "COL" :int)
      (swig-defvar "RED" "ACL_ENUM___RED__SWIG_0" :type :constant)
      (swig-defvar "GREEN" "ACL_ENUM___GREEN__SWIG_0" :type :constant)
      (swig-defvar "BLUE" "ACL_ENUM___BLUE__SWIG_0" :type :constant)

      (swig-def-foreign-type "FOO" :int)
      (swig-defvar "FOO1" "ACL_ENUM___FOO1__SWIG_0" :type :constant)
      (swig-defvar "FOO2" "ACL_ENUM___FOO2__SWIG_0" :type :constant)
      (swig-defvar "FOO3" "ACL_ENUM___FOO3__SWIG_0" :type :constant)

            

Arrays
~~~~~~~~~~~~~

One limitation in the Allegro CL foreign-types module, is that, without
macrology, expressions may not be used to specify the dimensions of an
array declaration. This is not a horrible drawback unless it is
necessary to allocate foreign structures based on the array declaration
using ff:allocate-fobject. When it can be determined that an array bound
is a valid numeric value, SWIG will include this in the generated array
declaration on the lisp side, otherwise the value will be included, but
commented out.

Below is a comprehensive example, showing a number of legal C/C++ array
declarations and how they are translated into foreign-type
specifications in the generated lisp code.

.. container:: code

   array.h
   ::

      #define MAX_BUF_SIZE 1024

      namespace FOO {
        int global_var1[13];
        float global_var2[MAX_BUF_SIZE];

      }

      enum COLOR { RED = 10, GREEN = 20, BLUE, PURPLE = 50, CYAN };

      namespace BAR {
        char global_var3[MAX_BUF_SIZE + 1];
        float global_var4[MAX_BUF_SIZE][13];
        signed short global_var5[MAX_BUF_SIZE + MAX_BUF_SIZE];

        int enum_var5[GREEN];
        int enum_var6[CYAN];

        COLOR enum_var7[CYAN][MAX_BUF_SIZE];
      }
          

Generates:

.. container:: targetlang

   array.cl
   ::

      (in-package #.*swig-module-name*)

      (swig-defpackage ("FOO"))
      (swig-defpackage ("BAR"))

      (swig-in-package ())
      (swig-def-foreign-type "COLOR" :int)
      (swig-defvar "RED" "ACL_ENUM___RED__SWIG_0" :type :constant)
      (swig-defvar "GREEN" "ACL_ENUM___GREEN__SWIG_0" :type :constant)
      (swig-defvar "BLUE" "ACL_ENUM___BLUE__SWIG_0" :type :constant)
      (swig-defvar "PURPLE" "ACL_ENUM___PURPLE__SWIG_0" :type :constant)
      (swig-defvar "CYAN" "ACL_ENUM___CYAN__SWIG_0" :type :constant)

      (swig-in-package ())

      (swig-defconstant "MAX_BUF_SIZE" 1024)
      (swig-in-package ("FOO"))

      (swig-defun ("global_var1" "ACL_FOO__global_var1_get__SWIG_0" :type :getter)
        (:void)
        (:returning ((* :int) )
         :strings-convert t)
        (make-instance 'ff:foreign-pointer :foreign-address (swig-ff-call)))


      (swig-defun ("global_var2" "ACL_FOO__global_var2_set__SWIG_0" :type :setter)
        ((global_var2  (:array :float 1024) ))
        (:returning (:void )
         :strings-convert t)
        (let ((SWIG_arg0 global_var2))
        (swig-ff-call SWIG_arg0)))


      (swig-in-package ())
      (swig-in-package ("BAR"))
      (swig-defun ("global_var3" "ACL_BAR__global_var3_set__SWIG_0" :type :setter)
        ((global_var3  (:array :char #|1024+1|#) ))
        (:returning (:void )
         :strings-convert t)
        (let ((SWIG_arg0 global_var3))
        (swig-ff-call SWIG_arg0)))


      (swig-defun ("global_var4" "ACL_BAR__global_var4_set__SWIG_0" :type :setter)
        ((global_var4  (:array (:array :float 13) 1024) ))
        (:returning (:void )
         :strings-convert t)
        (let ((SWIG_arg0 global_var4))
        (swig-ff-call SWIG_arg0)))


      (swig-defun ("global_var4" "ACL_BAR__global_var4_get__SWIG_0" :type :getter)
        (:void)
        (:returning ((* (:array :float 13)) )
         :strings-convert t)
        (make-instance 'ff:foreign-pointer :foreign-address (swig-ff-call)))


      (swig-defun ("global_var5" "ACL_BAR__global_var5_set__SWIG_0" :type :setter)
        ((global_var5  (:array :short #|1024+1024|#) ))
        (:returning (:void )
         :strings-convert t)
        (let ((SWIG_arg0 global_var5))
        (swig-ff-call SWIG_arg0)))


      (swig-defun ("enum_var5" "ACL_BAR__enum_var5_set__SWIG_0" :type :setter)
        ((enum_var5  (:array :int #|GREEN|#) ))
        (:returning (:void )
         :strings-convert t)
        (let ((SWIG_arg0 enum_var5))
        (swig-ff-call SWIG_arg0)))


      (swig-defun ("enum_var6" "ACL_BAR__enum_var6_set__SWIG_0" :type :setter)
        ((enum_var6  (:array :int #|CYAN|#) ))
        (:returning (:void )
         :strings-convert t)
        (let ((SWIG_arg0 enum_var6))
        (swig-ff-call SWIG_arg0)))


      (swig-defun ("enum_var7" "ACL_BAR__enum_var7_set__SWIG_0" :type :setter)
        ((enum_var7  (:array (:array #.(swig-insert-id "COLOR" ()) 1024) #|CYAN|#) ))
        (:returning (:void )
         :strings-convert t)
        (let ((SWIG_arg0 enum_var7))
        (swig-ff-call SWIG_arg0)))


      (swig-defun ("enum_var7" "ACL_BAR__enum_var7_get__SWIG_0" :type :getter)
        (:void)
        (:returning ((* (:array #.(swig-insert-id "COLOR" ()) 1024)) )
         :strings-convert t)
        (make-instance 'ff:foreign-pointer :foreign-address (swig-ff-call)))
          

Classes and Structs and Unions (oh my!)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CLOS wrapping of
^^^^^^^^^^^^^^^^^^^^^^^^^

Classes, unions, and structs are all treated the same way by the
interface generator. For any of these objects, a def-foreign-type and a
defclass form are generated. For every function that returns an object
(or pointer/reference) of C/C++ type ``X``, the wrapping defun (or
defmethod) on the Lisp side will automatically wrap the pointer returned
in an instance of the appropriate class. This makes it much easier to
write and debug code than if pointers were passed around as a jumble of
integer values.

CLOS Inheritance
^^^^^^^^^^^^^^^^^^^^^^^^^

The CLOS class schema generated by the interface mirrors the inheritance
of the classes in foreign code, with the ff:foreign-pointer class at its
root. ff:foreign-pointer is a thin wrapper for pointers that is made
available by the foreign function interface. Its key benefit is that it
may be passed as an argument to any ff:def-foreign-call that is
expecting a pointer as the parameter.

Member fields and functions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All public fields will have accessor getter/setter functions generated
for them, as appropriate. All public member functions will have wrapper
functions generated.

We currently ignore anything that isn't ``public`` (i.e. ``private`` or
``protected``), because the C++ compiler won't allow the wrapper
functions to access such fields. Likewise, the interface does nothing
for ``friend`` directives,

Why not directly access C++ classes using foreign types?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The def-foreign-type generated by the SWIG interface is currently
incomplete. We can reliably generate the object layout of simple structs
and unions; they can be allocated via ff:allocate-fobject, and their
member variables accessed directly using the various ff:fslot-value-\*
functions. However, the layout of C++ classes is more complicated.
Different compilers adjust class layout based on inheritance patterns,
and the presence of virtual member functions. The size of member
function pointers vary across compilers as well. As a result, it is
recommended that users of any generated interface not attempt to access
C++ instances via the foreign type system, but instead use the more
robust wrapper functions.

Templates
~~~~~~~~~~~~~~~~

Generating wrapper code for templates
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

SWIG provides support for dealing with templates, but by default, it
will not generate any member variable or function wrappers for templated
classes. In order to create these wrappers, you need to explicitly tell
SWIG to instantiate them. This is done via the
:doc:```%template``<SWIGPlus>` directive.

Implicit Template instantiation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

While no wrapper code is generated for accessing member variables, or
calling member functions, type code is generated to include these
templated classes in the foreign-type and CLOS class schema.

Typedef, Templates, and Synonym Types
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In C/C++ it is possible, via typedef, to have many names refer to the
same ``type``. In general, this is not a problem, though it can lead to
confusion. Assume the below C++ header file:

.. container:: code

   synonyms.h
   ::

      class A { 
        int x;
        int y;
      };

      typedef A Foo;

      A *xxx(int i);         /* sets A->x = A->y = i */
      Foo *yyy(int i);       /* sets Foo->x = Foo->y = i */

      int zzz(A *inst = 0);  /* return inst->x + inst->y */
          

The function ``zzz`` is an overloaded functions; the foreign function
call to it will be wrapped in a generic-function whose argument will be
checked against a type of ``A``. Assuming a simple implementation, a
call to ``xxx(1)`` will return a pointer to an A object, which will be
wrapped in a CLOS instance of class ``A``, and a call to ``yyy(1)`` will
result in a CLOS instance of type ``Foo`` being returned. Without
establishing a clear type relationship between ``Foo`` and ``A``, an
attempt to call ``zzz(yyy(1))`` will result in an error.

We resolve this issue, by noting synonym relationships between types
while generating the interface. A Primary type is selected (more on this
below) from the candidate list of synonyms. For all other synonyms,
instead of generating a distinct CLOS class definition, we generate a
form that expands to:

.. container:: targetlang

   ``(setf (find-class <synonym>) <primary>)``

The result is that all references to synonym types in foreign code, are
wrapped in the same CLOS wrapper, and, in particular, method
specialization in wrapping generic functions works as expected.

Given the above header file, synonym.h, a Lisp session would appear as
follows:

.. container:: targetlang

   ::

      CL-USER> (load "synonym.dll")
      ; Foreign loading synonym.dll.
      t
      CL-USER> (load "synonym.cl")
      ; Loading c:\mikel\src\swig\test\synonym.cl
      t
      CL-USER> 
      synonym> (setf a (xxx 3))
      #<A nil #x3261a0 @ #x207299da>
      synonym> (setf foo (yyy 10))
      #<A nil #x3291d0 @ #x2072e982>
      synonym> (zzz a)
      6
      synonym> (zzz foo)
      20
      synonym> 
          

Choosing a primary type
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The choice of a primary type is selected by the following criteria from
a set of synonym types.

-  If a synonym type has a class definition, it is the primary type.
-  If a synonym type is a class template and has been explicitly
   instantiated via ``%template``, it is the primary type.
-  For all other sets of synonymous types, the synonym which is parsed
   first becomes the primary type.

Function overloading/Parameter defaulting
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For each possible argument combination, a distinct wrapper function is
created in the .cxx file. On the Lisp side, a generic functions is
defined for each possible arity the overloaded/defaulted call may have.
Each distinct wrapper is then called from within a defmethod on the
appropriate generic function. These are further wrapped inside a
dispatch function that checks the number of arguments it is called with
and passes them via apply to the appropriate generic-function. This
allows for a single entry point to overloaded functions on the lisp
side.

Example:

.. container:: code

   overload.h:
   ::


      class A {
       public:
        int x;
        int y;
      };

      float xxx(int i, int x = 0);   /* return i * x */
      float xxx(A *inst, int x);     /* return x + A->x + A->y */
          

Creates the following three wrappers, for each of the possible argument
combinations

.. container:: code

   overload_wrap.cxx
   ::

      EXPORT void ACL___delete_A__SWIG_0 (A *larg1) {
        A *arg1 = (A *) 0 ;

        arg1 = larg1;
        try {
          delete arg1;

        } catch (...) {

        }
      }


      EXPORT float ACL___xxx__SWIG_0 (int larg1, int larg2) {
        float lresult = (float)0 ;
        int arg1 ;
        int arg2 ;
        float result;

        arg1 = larg1;
        arg2 = larg2;
        try {
          result = (float)xxx(arg1, arg2);

          lresult = result;
          return lresult;
        } catch (...) {
          return (float)0;
        }
      }


      EXPORT float ACL___xxx__SWIG_1 (int larg1) {
        float lresult = (float)0 ;
        int arg1 ;
        float result;

        arg1 = larg1;
        try {
          result = (float)xxx(arg1);

          lresult = result;
          return lresult;
        } catch (...) {
          return (float)0;
        }
      }


      EXPORT float ACL___xxx__SWIG_2 (A *larg1, int larg2) {
        float lresult = (float)0 ;
        A *arg1 = (A *) 0 ;
        int arg2 ;
        float result;

        arg1 = larg1;
        arg2 = larg2;
        try {
          result = (float)xxx(arg1, arg2);

          lresult = result;
          return lresult;
        } catch (...) {
          return (float)0;
        }
      }
          

And the following foreign-function-call and method definitions on the
lisp side:

.. container:: targetlang

   overload.cl
   ::

      (swig-defmethod ("xxx" "ACL___xxx__SWIG_0" :type :function :arity 2)
        ((PARM0_i cl:integer :int )
         (PARM1_x cl:integer :int ))
        (:returning (:float )
         :strings-convert t)
        (let ((SWIG_arg0 PARM0_i))
        (let ((SWIG_arg1 PARM1_x))
        (swig-ff-call SWIG_arg0 SWIG_arg1))))

      (swig-defmethod ("xxx" "ACL___xxx__SWIG_1" :type :function :arity 1)
        ((PARM0_i cl:integer :int ))
        (:returning (:float )
         :strings-convert t)
        (let ((SWIG_arg0 PARM0_i))
        (swig-ff-call SWIG_arg0)))

      (swig-defmethod ("xxx" "ACL___xxx__SWIG_2" :type :function :arity 2)
        ((PARM0_inst #.(swig-insert-id "A" () :type :class) (* #.(swig-insert-id "A" ())) )
         (PARM1_x cl:integer :int ))
        (:returning (:float )
         :strings-convert t)
        (let ((SWIG_arg0 PARM0_inst))
        (let ((SWIG_arg1 PARM1_x))
        (swig-ff-call SWIG_arg0 SWIG_arg1))))

      (swig-dispatcher ("xxx" :type :function :arities (1 2)))
          

And their usage in a sample lisp session:

.. container:: targetlang

   ::

      overload> (setf a (new_A))
      #<A nil #x329268 @ #x206cf612>
      overload> (setf (A_x a) 10)
      10
      overload> (setf (A_y a) 20)
      20
      overload> (xxx 1)
      0.0
      overload> (xxx 3 10)
      30.0
      overload> (xxx a 1)
      31.0
      overload> (xxx a 2)
      32.0
      overload> 
          

Operator wrapping and Operator overloading
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wrappers to defined C++ Operators are automatically renamed, using
``%rename``, to the following defaults:

.. container:: code

   ::

      /* name conversion for overloaded operators. */
      #ifdef __cplusplus
      %rename(__add__)             *::operator+;
      %rename(__pos__)             *::operator+();
      %rename(__pos__)             *::operator+() const;

      %rename(__sub__)             *::operator-;
      %rename(__neg__)             *::operator-() const;
      %rename(__neg__)             *::operator-();

      %rename(__mul__)             *::operator*;
      %rename(__deref__)           *::operator*();
      %rename(__deref__)           *::operator*() const;

      %rename(__div__)             *::operator/;
      %rename(__mod__)             *::operator%;
      %rename(__logxor__)          *::operator^;
      %rename(__logand__)          *::operator&;
      %rename(__logior__)          *::operator|;
      %rename(__lognot__)          *::operator~();
      %rename(__lognot__)          *::operator~() const;

      %rename(__not__)             *::operator!();
      %rename(__not__)             *::operator!() const;

      %rename(__assign__)          *::operator=;

      %rename(__add_assign__)      *::operator+=;
      %rename(__sub_assign__)      *::operator-=;
      %rename(__mul_assign__)      *::operator*=;
      %rename(__div_assign__)      *::operator/=;
      %rename(__mod_assign__)      *::operator%=;
      %rename(__logxor_assign__)   *::operator^=;
      %rename(__logand_assign__)   *::operator&=;
      %rename(__logior_assign__)   *::operator|=;

      %rename(__lshift__)          *::operator<<;
      %rename(__lshift_assign__)   *::operator<<=;
      %rename(__rshift__)          *::operator>>;
      %rename(__rshift_assign__)   *::operator>>=;

      %rename(__eq__)              *::operator==;
      %rename(__ne__)              *::operator!=;
      %rename(__lt__)              *::operator<;
      %rename(__gt__)              *::operator>;
      %rename(__lte__)             *::operator<=;
      %rename(__gte__)             *::operator>=;

      %rename(__and__)             *::operator&&;
      %rename(__or__)              *::operator||;

      %rename(__preincr__)         *::operator++();
      %rename(__postincr__)        *::operator++(int);
      %rename(__predecr__)         *::operator--();
      %rename(__postdecr__)        *::operator--(int);

      %rename(__comma__)           *::operator,();
      %rename(__comma__)           *::operator,() const;

      %rename(__member_ref__)      *::operator->;
      %rename(__member_func_ref__) *::operator->*;

      %rename(__funcall__)         *::operator();
      %rename(__aref__)            *::operator[];
          

Name mangling occurs on all such renamed identifiers, so that wrapper
name generated by ``B::operator=`` will be ``B___eq__``, i.e.
``<class-or-namespace>_`` has been added. Users may modify these default
names by adding ``%rename`` directives in their own .i files.

Operator overloading can be achieved by adding functions based on the
mangled names of the function. In the following example, a class B is
defined with a Operator== method defined. The swig ``%extend`` directive
is used to add an overload method on Operator==.

.. container:: code

   opoverload.h
   ::

      class B {
       public:
        int x;
        int y;
        bool operator==(B const& other) const;
      };
          

and

.. container:: code

   opoverload.i
   ::

      %module opoverload

      %{
      #include <fstream>
      #include "opoverload.h"
      %}

      %{
      bool B___eq__(B const *inst, int const x)
      {
        // insert the function definition into the wrapper code before
        // the wrapper for it.
        // ... do stuff ...
      }
      %}

      %include "opoverload.h"

      %extend B {
       public:
        bool __eq__(int const x) const;
      };
          

Either operator can be called via a single call to the dispatch
function:

.. container:: targetlang

   ::

      opoverload> (B___eq__ x1 x2)
      nil
      opoverload> (B___eq__ x1 3)
      nil
      opoverload> 
          

Varargs
~~~~~~~~~~~~~~~

Variable length argument lists are not supported, by default. If such a
function is encountered, a warning will generated to stderr. Varargs are
supported via the SWIG ``%varargs`` directive. This directive allows you
to specify a (finite) argument list which will be inserted into the
wrapper in place of the variable length argument indicator. As an
example, consider the function ``printf()``. Its declaration would
appear as follows:

See the following section on `Variable Length
arguments <Varargs.html#Varargs>`__ provides examples on how
``%varargs`` can be used, along with other ways such functions can be
wrapped.

C++ Exceptions
~~~~~~~~~~~~~~~~~~~~~~

Each C++ wrapper includes a handler to catch any exceptions that may be
thrown while in foreign code. This helps prevent simple C++ errors from
killing the entire lisp process. There is currently no mechanism to have
these exceptions forwarded to the lisp condition system, nor has any
explicit support of the exception related SWIG typemaps been
implemented.

Pass by value, pass by reference
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Allegro CL does not support the passing of non-primitive foreign
structures by value. As a result, SWIG must automatically detect and
convert function parameters and return values to pointers whenever
necessary. This is done via the use of ``typemaps``, and should not
require any fine tuning by the user, even for newly defined types.

Typemaps
-------------

SWIG Typemaps provide a powerful tool for automatically generating code
to handle various menial tasks required of writing an interface to
foreign code. The purpose of this section is to describe each of the
typemaps used by the Allegro CL module. Please read the chapter on
:doc:`Typemaps` for more information.

Code Generation in the C++ Wrapper
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Every C++ wrapper generated by SWIG takes the following form:

.. container:: diagram

   ::

      return-val wrapper-name(parm0, parm1, ..., parmN)
      {
        return-val lresult;   /* return value from wrapper */
        <local-declaration>
        ... results;          /* return value from function call */

        <binding locals to parameters>

        try {
          result = function-name(local0, local1, ..., localN);

          <convert and bind result to lresult>

          return lresult;
        catch (...) {
          return (int)0;
        }
          

IN Typemap
^^^^^^^^^^^^^^^^^^^

the ``in`` typemap is used to generate code to convert parameters passed
to C++ wrapper functions into the arguments desired for the call being
wrapped. That is, it fills in the code for the
``<binding locals to parameters>`` section above. We use this map to
automatically convert parameters passed by reference to the wrapper
function into by-value arguments for the wrapped call, and also to
convert boolean values, which are passed as integers from lisp (by
default), into the appropriate type for the language of code being
wrapped.

These are the default specifications for the IN typemap. Here,
``$input`` refers to the parameter code is being generated for, and
``$1`` is the local variable to which it is being assigned. The default
settings of this typemap are as follows:

.. container:: code

   ::

      %typemap(in) bool                          "$1 = (bool)$input;";
      %typemap(in) char, unsigned char, signed char,
                   short, signed short, unsigned short,
                   int, signed int, unsigned int,
                   long, signed long, unsigned long,
                   float, double, long double, char *, void *, void,
                   enum SWIGTYPE, SWIGTYPE *,
                   SWIGTYPE[ANY], SWIGTYPE &     "$1 = $input;";
      %typemap(in) SWIGTYPE                      "$1 = *$input;";
          

OUT Typemap
^^^^^^^^^^^^^^^^^^^^

The ``out`` typemap is used to generate code to form the return value of
the wrapper from the return value of the wrapped function. This code is
placed in the <convert and bind result to lresult> section of the above
code diagram. Its default mapping is as follows:

.. container:: code

   ::

      %typemap(out) bool                          "$result = (int)$1;";
      %typemap(out) char, unsigned char, signed char,
                    short, signed short, unsigned short,
                    int, signed int, unsigned int,
                    long, signed long, unsigned long,
                    float, double, long double, char *, void *, void,
                    enum SWIGTYPE, SWIGTYPE *,
                    SWIGTYPE[ANY], SWIGTYPE &    "$result = $1;";
      %typemap(out) SWIGTYPE                     "$result = new $1_type($1);";
          

CTYPE Typemap
^^^^^^^^^^^^^^^^^^^^^^

This typemap is not used for code generation, but purely for the
transformation of types in the parameter list of the wrapper function.
Its primary use is to handle by-value to by-reference conversion in the
wrappers parameter list. Its default settings are:

.. container:: code

   ::

      %typemap(ctype) bool                       "int";
      %typemap(ctype) char, unsigned char, signed char,
                      short, signed short, unsigned short,
                      int, signed int, unsigned int,
                      long, signed long, unsigned long,
                      float, double, long double, char *, void *, void,
                      enum SWIGTYPE, SWIGTYPE *,
                      SWIGTYPE[ANY], SWIGTYPE &  "$1_ltype";
      %typemap(ctype) SWIGTYPE                   "$&1_type";
          

These three typemaps are specifically employed by the Allegro CL
interface generator. SWIG also implements a number of other typemaps
that can be used for generating code in the C/C++ wrappers. You can read
about these `common typemaps <Typemaps.html#Typemaps_nn25>`__ here.

Code generation in Lisp wrappers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A number of custom typemaps have also been added to facilitate the
generation of code in the lisp side of the interface. These are
described below. The basic code generation structure is applied as a
series of nested expressions, one for each parameter, then one for
manipulating the return value, and last, the foreign function call
itself.

Note that the typemaps below use fully qualified symbols where
necessary. Users writing their own typemaps should do likewise. See the
explanation in the last paragraph of `16.3.1
Namespaces <#Allegrocl_nn15>`__ for details.

LIN Typemap
^^^^^^^^^^^^^^^^^^^^

The LIN typemap allows for the manipulating the lisp objects passed as
arguments to the wrapping defun before passing them to the foreign
function call. For example, when passing lisp strings to foreign code,
it is often necessary to copy the string into a foreign structure of
type (:char \*) of appropriate size, and pass this copy to the foreign
call. Using the LIN typemap, one could arrange for the stack-allocation
of a foreign char array, copy your string into it, and not have to worry
about freeing the copy after the function returns.

The LIN typemap accepts the following ``$variable`` references.

-  ``$in`` - expands to the name of the parameter being applied to this
   typemap
-  ``$out`` - expands to the name of the local variable assigned to this
   typemap
-  ``$in_fftype`` - the foreign function type of the C type.
-  ``$*in_fftype`` - the foreign function type of the C type with one
   pointer removed. If there is no pointer, then $*in_fftype is the same
   as $in_fftype.
-  ``$body`` - very important. Instructs SWIG where subsequent code
   generation steps should be inserted into the current typemap. Leaving
   out a ``$body`` reference will result in lisp wrappers that do very
   little by way of calling into foreign code. Not recommended.

.. container:: code

   ::

      %typemap(lin) SWIGTYPE "(cl:let (($out $in))\n  $body)";
          

LOUT Typemap
^^^^^^^^^^^^^^^^^^^^^

The LOUT typemap is the means by which we effect the wrapping of foreign
pointers in CLOS instances. It is applied after all LIN typemaps, and
immediately before the actual foreign-call.

The LOUT typemap uses the following $variable

-  ``$lclass`` - Expands to the CLOS class that represents
   foreign-objects of the return type matching this typemap.
-  ``$body`` - Same as for the LIN map. Place this variable where you
   want the foreign-function call to occur.
-  ``$ldestructor`` - Expands to the symbol naming the destructor for
   this class ($lclass) of object. Allows you to insert finalization or
   automatic garbage collection into the wrapper code (see default
   mappings below).

.. container:: code

   ::

      %typemap(lout) bool, char, unsigned char, signed char,
                     short, signed short, unsigned short,
                     int, signed int, unsigned int,
                     long, signed long, unsigned long,
                     float, double, long double, char *, void *, void,
                     enum SWIGTYPE    "$body";
      %typemap(lout) SWIGTYPE[ANY], SWIGTYPE *,
                     SWIGTYPE &       "(cl:make-instance '$lclass :foreign-address $body)";
      %typemap(lout) SWIGTYPE    "(cl:let* ((address $body)\n
                                  (ACL_result (cl:make-instance '$lclass :foreign-address address)))\n
                                  (cl:unless (cl::zerop address)\n
                                  (excl:schedule-finalization ACL_result #'$ldestructor))\n
                                   ACL_result)";
          

FFITYPE Typemap
^^^^^^^^^^^^^^^^^^^^^^^^

The FFITYPE typemap works as a helper for a body of code that converts
C/C++ type specifications into Allegro CL foreign-type specifications.
These foreign-type specifications appear in ff:def-foreing-type
declarations, and in the argument list and return values of
ff:def-foreign-calls. You would modify this typemap if you want to
change how the FFI passes through arguments of a given type. For
example, if you know that a particular compiler represents booleans as a
single byte, you might add an entry for:

.. container:: code

   ::

      %typemap(ffitype) bool ":unsigned-char";
          

Note that this typemap is pure type transformation, and is not used in
any code generations step the way the LIN and LOUT typemaps are. The
default mappings for this typemap are:

.. container:: code

   ::

      %typemap(ffitype) bool ":int";
      %typemap(ffitype) char ":char";
      %typemap(ffitype) unsigned char ":unsigned-char";
      %typemap(ffitype) signed char ":char";
      %typemap(ffitype) short, signed short ":short";
      %typemap(ffitype) unsigned short ":unsigned-short";
      %typemap(ffitype) int, signed int ":int";
      %typemap(ffitype) unsigned int ":unsigned-int";
      %typemap(ffitype) long, signed long ":long";
      %typemap(ffitype) unsigned long ":unsigned-long";
      %typemap(ffitype) float ":float";
      %typemap(ffitype) double ":double";
      %typemap(ffitype) char * "(* :char)";
      %typemap(ffitype) void * "(* :void)";
      %typemap(ffitype) void ":void";
      %typemap(ffitype) enum SWIGTYPE ":int";
      %typemap(ffitype) SWIGTYPE & "(* :void)";
          

LISPTYPE Typemap
^^^^^^^^^^^^^^^^^^^^^^^^^

This is another type only transformation map, and is used to provide the
lisp-type, which is the optional third argument in argument specifier in
a ff:def-foreign-call form. Specifying a lisp-type allows the foreign
call to perform type checking on the arguments passed in. The default
entries in this typemap are:

.. container:: code

   ::

      %typemap(lisptype) bool "cl:boolean";
      %typemap(lisptype) char "cl:character";
      %typemap(lisptype) unsigned char "cl:integer";
      %typemap(lisptype) signed char "cl:integer";
          

LISPCLASS Typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^

The LISPCLASS typemap is used to generate the method signatures for the
generic-functions which wrap overloaded functions and functions with
defaulted arguments. The default entries are:

.. container:: code

   ::

      %typemap(lispclass) bool "t";
      %typemap(lispclass) char "cl:character";
      %typemap(lispclass) unsigned char, signed char,
                          short, signed short, unsigned short,
                          int, signed int, unsigned int,
                          long, signed long, unsigned long,
                          enum SWIGTYPE       "cl:integer";
      %typemap(lispclass) float "cl:single-float";
      %typemap(lispclass) double "cl:double-float";
      %typemap(lispclass) char * "cl:string";
          

Modifying SWIG behavior using typemaps
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following example shows how we made use of the above typemaps to add
support for the wchar_t type.

.. container:: code

   ::

      %typecheck(SWIG_TYPECHECK_UNICHAR) wchar_t { $1 = 1; };

      %typemap(in)        wchar_t "$1 = $input;";
      %typemap(lin)       wchar_t "(cl:let (($out (cl:char-code $in)))\n  $body)";
      %typemap(lin)       wchar_t* "(excl:with-native-string
                                               ($out $in
                                                :external-format #+little-endian :fat-le 
                                                                 #-little-endian :fat)\n
                                       $body)"

      %typemap(out)       wchar_t "$result = $1;";
      %typemap(lout)      wchar_t "(cl:code-char $body)";
      %typemap(lout)      wchar_t* "(excl:native-to-string $body
                                                :external-format #+little-endian :fat-le
                                                                 #-little-endian :fat)";

      %typemap(ffitype)   wchar_t ":unsigned-short";
      %typemap(lisptype)  wchar_t "";
      %typemap(ctype)     wchar_t "wchar_t";
      %typemap(lispclass) wchar_t "cl:character";
      %typemap(lispclass) wchar_t* "cl:string";
          

Identifier Converter functions
-----------------------------------

Creating symbols in the lisp environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Various symbols must be generated in the lisp environment to which class
definitions, functions, constants, variables, etc. must be bound. Rather
than force a particular convention for naming these symbols, an
identifier (to symbol) conversion function is used. A user-defined
identifier-converter can then implement any symbol naming,
case-modifying, scheme desired.

In generated SWIG code, whenever some interface object must be
referenced by its lisp symbol, a macro is inserted that calls the
identifier-converter function to generate the appropriate symbol
reference. It is therefore expected that the identifier-converter
function reliably return the same (eq) symbol given the same set of
arguments.

Existing identifier-converter functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Two basic identifier routines have been defined.

identifier-convert-null
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

No modification of the identifier string is performed. Based on other
arguments, the identifier may be concatenated with other strings, from
which a symbol will be created.

identifier-convert-lispify
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All underscores in the identifier string are converted to hyphens.
Otherwise, identifier-convert-lispify performs the same symbol
transformations.

Default identifier to symbol conversions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Check the definitions of the above two default identifier-converters in
``Lib/allegrocl/allegrocl.swg`` for default naming conventions.

Defining your own identifier-converter
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A user-defined identifier-converter function should conform to the
following specification:

.. container:: targetlang

   ::

      (defun identifier-convert-fn (id &key type class arity) ...body...)
      result ==> symbol or (setf symbol)

The ``ID`` argument is a string representing an identifier in the
foreign environment.

The :type keyword argument provides more information on the type of
identifier. Its value is a symbol. This allows the identifier-converter
to apply different heuristics when mapping different types of
identifiers to symbols. SWIG will generate calls to your
identifier-converter using the following types.

-  :class - names a CLOS class.
-  :constant - names a defconstant
-  :constructor - names a function for creating a foreign object
-  :destructor - names a function for freeing a foreign object
-  :function - names a CLOS wrapping defmethod or defun.
-  :ff-operator - names a foreign call defined via ff:def-foreign-call
-  :getter - getter function
-  :namespace - names a C++ namespace
-  :setter - names a setter function. May return a (setf symbol)
   reference
-  :operator - names a C++ operator, such as Operator=, Operator*.
-  :slot - names a slot in a struct/class/union declaration.
-  :type - names a foreign-type defined via ff:def-foreign-type.
-  :variable - names a variable defined via ff:def-foreign-variable.

The :class keyword argument is a string naming a foreign class. When
non-nil, it indicates that the current identifier has scope in the
specified class.

The :arity keyword argument only appears in swig:swig-defmethod forms
generated for overloaded functions. Its value is an integer indicating
the number of arguments passed to the routine indicated by this
identifier.

Instructing SWIG to use a particular identifier-converter
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, SWIG will use identifier-converter-null. To specify another
convert function, use the ``-identifier-converter`` command-line
argument. The value should be a string naming the function you wish the
interface to use instead, when generating symbols. ex:

.. container:: code

   ::

      % swig -allegrocl -c++ -module mymodule -identifier-converter my-identifier-converter

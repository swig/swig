SWIG and Modula-3
====================

This chapter describes SWIG's support for
`Modula-3 <http://modula3.org/>`__. You should be familiar with the
`basics <SWIG.html#SWIG>`__ of SWIG, especially
`typemaps <Typemaps.html#Typemaps>`__.

Overview
-------------

Modula-3 is a compiled language in the tradition of Niklaus Wirth's
Modula 2, which is in turn a successor to Pascal.

SWIG's Modula-3 support is currently very basic and highly experimental!
Many features are still not designed satisfyingly and I need more
discussion about the odds and ends. Don't rely on any feature,
incompatible changes are likely in the future! However, the Modula-3
generator was already useful for interfacing to the libraries:

#. `PLPlot <http://www.elegosoft.com/cgi-bin/cvsweb.cgi/cm3/m3-libs/plplot/>`__
#. `FFTW <http://www.elegosoft.com/cgi-bin/cvsweb.cgi/cm3/m3-libs/fftw/>`__

Motivation
~~~~~~~~~~~~~~~~~

Although it is possible to write Modula-3 code that performs as well as
C/C++ most existing libraries are not written in Modula-3 but in C or
C++, and even libraries in other languages may provide C header files.

Fortunately Modula-3 can call C functions, but you have to write
Modula-3 interfaces to them, and to make things comfortable you will
also need wrappers that convert between high-level features of Modula-3
(garbage collecting, exceptions) and the explicit tracking of allocated
memory and exception codes used by C APIs.

SWIG converts C headers to Modula-3 interfaces for you, and using
typemaps you can pass ``TEXT``\ s or open arrays, and convert error
return codes into exceptions.

If the library API is ill designed writing appropriate typemaps can
still be time-consuming. E.g. C programmers are very creative to
work-around missing data types like (real) enumerations and sets. You
should turn such work-arounds back to the Modula-3 way otherwise you
lose static safety and consistency.

Without SWIG you would probably never consider trying to call C++
libraries from Modula-3, but with SWIG this is becomes feasible. SWIG
can generate C wrappers to C++ functions and object methods that may
throw exceptions, and then wrap these C wrappers for Modula-3. To make
it complete you can then hide the C interface with Modula-3 classes and
exceptions.

SWIG allows you to call C and C++ libraries from Modula-3 (even with
call back functions), but it doesn't allow you to easily integrate a
Modula-3 module into a C/C++ project.

Conception
---------------

Interfaces to C libraries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Modula-3 has integrated support for calling C functions. This is also
extensively used by the standard Modula-3 libraries to call OS
functions. The Modula-3 part of SWIG and the corresponding SWIG library
modula3.swg contain code that uses these features. Because of the
built-in support there is no need for calling the SWIG kernel to
generate wrappers written in C. All conversion and argument checking can
be done in Modula-3 and the interfacing is quite efficient. All you have
to do is to write pieces of Modula-3 code that SWIG puts together.

.. list-table::
    :widths: 25 50
    :header-rows: 1

    *
      - C library support integrated in Modula-3
      -
    *
      - Pragma <\* EXTERNAL \*>
      - Precedes a declaration of a PROCEDURE that is implemented in an external library instead of a
        Modula-3 module.                               
    *
      - Pragma <\* CALLBACK \*>
      - Precedes a declaration of a PROCEDURE that should be called by external library code.
    *
      - Module Ctypes
      - Contains Modula-3 types that match some basic C types.
    *
      - Module M3toC
      - Contains routines that convert between Modula-3's TEXT type and C's char * type.

In each run of SWIG the Modula-3 part generates several files:

.. list-table::
    :widths: 25 25 50
    :header-rows: 1

    *
      - Module name scheme
      - Identifier for ``%insert``
      - Description
    *
      - Module\ ``Raw.i3``
      - ``m3rawintf``
      - Declaration of types that are equivalent to those of the C library, ``EXTERNAL`` 
        procedures as interface to the C library functions.
    *
      - Module\ ``Raw.m3``
      - ``m3rawimpl``
      - Almost empty.
    *
      - Module\ ``.i3``
      - ``m3wrapintf``
      - Declaration of comfortable wrappers to the C library functions.
    *
      - Module\ ``.m3`` 
      - ``m3wrapimpl``
      - Implementation of the wrappers that convert between Modula-3 and C types, check for
        validity of values, hand-over resource management to the garbage collector using ``WeakRef``\ s
        and raises exceptions.
    *
      - ``m3makefile``
      - ``m3makefile``
      - Add the modules above to the Modula-3 project and specify the name of the Modula-3 wrapper
        library to be generated. Today I'm not sure if it is a good idea to create a ``m3makefile`` in
        each run, because SWIG must be started for each Modula-3 module it creates. Thus the m3makefile
        is overwritten each time. :-(

Here's a scheme of how the function calls to Modula-3 wrappers are
redirected to C library functions:

.. list-table::
    :widths: 40 20 40
    :header-rows: 0 
    :align: center

    *
      - | Modula-3 wrapper     
        | Module\ ``.i3``      
        | generated by Modula-3
        | part of SWIG         
      -
      -
    *
      - |  |
        |  v
      -
      -
    *
      - | Modula-3 interface to 
        | C                    
        | Module\ ``Raw.i3``   
        | generated by Modula-3
        | part of SWIG
      - -->
      - C library

I have still no good conception how one can split C library interfaces
into type oriented interfaces. A Module in Modula-3 represents an
Abstract DataType (or call it a static classes, i.e. a class without
virtual methods). E.g. if you have a principal type, say ``Database``,
it is good Modula-3 style to set up one Module with the name
``Database`` where the database type is declared with the name ``T`` and
where all functions are declared that operates on it.

The normal operation of SWIG is to generate a fixed set of files per
call. To generate multiple modules one has to write one SWIG interface
(different SWIG interfaces can share common data) per module.
Identifiers belonging to a different module may ignored (``%ignore``)
and the principal type must be renamed (``%typemap``).

.. _interfaces-to-c-libraries-1:

Interfaces to C++ libraries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Interfaces to C++ files are much more complicated and there are some
more design decisions that are not made, yet. Modula-3 has no support
for C++ functions but C++ compilers should support generating C++
functions with a C interface.

Here's a scheme of how the function calls to Modula-3 wrappers are
redirected to C library functions:

.. list-table::
    :widths: 40 20 40
    :header-rows: 0 
    :align: center

    *
      - | Modula-3 wrapper                       
        | Module ``.i3``                        
        | generated by Modula-3                      
        | part of SWIG                           
      - 
      - C++ library     
    *
      - | \|
        | v 
      -
      - | ^
        | \|
    *
      - | Modula-3 interface to 
        |  C                    
        | Module ``Raw.i3`` 
        | generated by Modula-3
        | part of SWIG             
      - -->
      - | C interface to C++ 
        | module ``_wrap.cxx``
        | generated by the   
        | SWIG core            
                       

Wrapping C++ libraries arises additional problems:

-  Is it sensible to wrap C++ classes with Modula-3 classes?
-  How to find the wrapping Modula-3 class for a class pointer that is
   returned by a C++ routine?
-  How to deal with multiple inheritance which was neglected for
   Modula-3 for good reasons?
-  Is it possible to sub-class C++ classes with Modula-3 code? This
   issue is addressed by directors, a feature that was experimentally
   added to some Language modules like
   `Java <Java.html#Java_directors>`__ and
   `Python <Python.html#Python_directors>`__.
-  How to manage storage with the garbage collector of Modula-3? Support
   for `%newobject and \
   %typemap(newfree) <Customization.html#Customization_ownership>`__
   isn't implemented, yet. What's about resources that are managed by
   the garbage collector but shall be passed back to the storage
   management of the C++ library? This is a general issue which is not
   solved in a satisfying fashion as far as I know.
-  How to turn C++ exceptions into Modula-3 exceptions? There's also no
   support for
   `%exception <Customization.html#Customization_exception>`__, yet.

Be warned: There is no C++ library I wrote a SWIG interface for, so I'm
not sure if this is possible or sensible, yet.

Preliminaries
------------------

Compilers
~~~~~~~~~~~~~~~~

There are different Modula-3 compilers around: cm3, pm3, ezm3,
Klagenfurth Modula-3, Cambridge Modula-3. SWIG itself does not contain
compiler specific code but the modula3.swg library file may do so. For
testing examples I use Critical Mass cm3.

Additional Commandline Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are some experimental command line options that prevent SWIG from
generating interface files. Instead files are emitted that may assist
you when writing SWIG interface files.

.. list-table::
    :widths: 25 75
    :header-rows: 1

    *
      - Modula-3 specific options
      - Description
    *
      - -generateconst <file>
      - Disable generation of interfaces and wrappers. Instead write code for 
        computing numeric values of constants to the specified file. 
        C code may contain several constant definitions written as preprocessor macros. 
        Other language modules of SWIG use compute-once-use-readonly variables or functions to wrap
        such definitions.
        All of them can invoke C code dynamically for computing the macro values. 
        But if one wants to turn them into Modula-3 integer constants, enumerations or set 
        types, the values of these  expressions has to be known statically. 
        Although definitions like ``(1 << FLAG_MAXIMIZEWINDOW)`` must be considered as good 
        C style they are hard to convert to Modula-3 since the value computation can use every feature of C.
        Thus I implemented these switch to extract all constant definitions and write 
        a C program that output the values of them.
        It works for numeric constants only and treats all of them as ``double``.
        Future versions may generate a C++ program that can detect the type of the macros by output functions.
        Then strings can also be processed.
    *
      - -generaterename <file>
      - Disable generation of interfaces and wrappers. Instead generate suggestions for ``%rename``.
        C libraries use a naming style that is neither homogeneous nor similar to that of Modula-3. 
        C function names often contain a prefix denoting the library and some name components 
        separated by underscores or capitalization changes. 
        To get library interfaces that are really Modula-3 like you should rename 
        the function names with the ``%rename``directive. 
        This switch outputs a list of such directives with a name suggestion generated by a simple heuristic.
    *
      - -generatetypemap <file>
      - Disable generation of interfaces and wrappers. Instead generate templates for 
        some basic typemaps.


Modula-3 typemaps
----------------------

Inputs and outputs
~~~~~~~~~~~~~~~~~~~~~~~~~

Each C procedure has a bunch of inputs and outputs. Inputs are passed as
function arguments, outputs are updated referential arguments and the
function value.

Each C type can have several typemaps that apply only in case if a type
is used for an input argument, for an output argument, or for a return
value. A further typemap may specify the direction that is used for
certain parameters. I have chosen this separation in order to be able to
write general typemaps for the modula3.swg typemap library. In the
library code the final usage of the type is not known. Using separate
typemaps for each possible use allows appropriate definitions for each
case. If these pre-definitions are fine then the direction of the
function parameter is the only hint the user must give.

The typemaps specific to Modula-3 have a common name scheme: A typemap
name starts with "m3", followed by "raw" or "wrap" depending on whether
it controls the generation of the Module\ ``Raw.i3`` or the
Module\ ``.i3``, respectively. It follows an "in" for typemaps applied
to input argument, "out" for output arguments, "arg" for all kind of
arguments, "ret" for returned values.

The main task of SWIG is to build wrapper function, i.e. functions that
convert values between C and Modula-3 and call the corresponding C
function. Modula-3 wrapper functions generated by SWIG consist of the
following parts:

-  Generate ``PROCEDURE`` signature.
-  Declare local variables.
-  Convert input values from Modula-3 to C.
-  Check for input value integrity.
-  Call the C function.
-  Check returned values, e.g. error codes.
-  Convert and write back values into Modula-3 records.
-  Free temporary storage.
-  Return values.

.. list-table::
    :widths: 25 25 50
    :header-rows: 1

    *
      - Typemap
      - Example
      - Description
    *
      - m3wrapargvar
      - ``$1: INTEGER := $1_name;``
      - Declaration of some variables needed for temporary results.  
    *
      - m3wrapargconst
      - ``$1 = "$1_name";``
      - Declaration of some constant, maybe for debug purposes.    
    *
      - m3wrapargraw
      - ``ORD($1_name)``
      - The expression that should be passed as argument to the raw Modula-3 interface function.
    *
      - m3wrapargdir
      - ``out``
      - Referential arguments can be used for input, output, update. ???
    *
      - m3wrapinmode
      - ``READONLY``
      - One of Modula-3 parameter modes ``VALUE`` (or empty), ``VAR``, ``READONLY``
    *
      - m3wrapinname
      -
      - New name of the input argument.
    *
      - m3wrapintype 
      -
      - Modula-3 type of the input argument.
    *
      - m3wrapindefault
      -
      - Default value of the input argument.
    *
      - m3wrapinconv
      -  $1 := M3toC.SharedTtoS($1_name);
      - Statement for converting the Modula-3 input value to C compliant value.
    *
      - m3wrapincheck
      - IF Text.Length($1_name) > 10 THEN RAISE E("str too long"); END;
      - Check the integrity of the input value.
    *
      - m3wrapoutname
      -
      - Name of the ``RECORD`` field to be used for returning multiple values.
        This applies to referential output arguments that shall be turned into return values.
    *
      - m3wrapouttype
      -
      - Type of the value that is returned instead of a referential output argument.
    *
      - m3wrapoutconv
      -
      -
    *
      - m3wrapoutcheck
      -
      -
    *
      - m3wrapretraw
      -
      -
    *
      - m3wrapretname
      -
      -
    *
      - m3wraprettype
      -
      -
    *
      - m3wrapretvar
      -
      -
    *
      - m3wrapretconv
      -
      -
    *
      - m3wrapretcheck
      -  
      - 
    *
      - m3wrapfreearg   
      - M3toC.FreeSharedS(str, arg1);
      - Free resources that were temporarily used in the wrapper.
        Since this step should never be skipped, SWIG will put it in the ``FINALLY`` branch of
        a ``TRY .. FINALLY`` structure.

Subranges, Enumerations, Sets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Subranges, enumerations, and sets are machine oriented types that make
Modula very strong and expressive compared with the type systems of many
other languages.

-  Subranges are used for statically restricted choices of integers.
-  Enumerations are used for named choices.
-  Sets are commonly used for flag (option) sets.

Using them extensively makes Modula code very safe and readable.

C supports enumerations, too, but they are not as safe as the ones of
Modula. Thus they are abused for many things: For named choices, for
integer constant definitions, for sets. To make it complete every way of
defining a value in C (``#define``, ``const int``, ``enum``) is
somewhere used for defining something that must be handled completely
different in Modula-3 (``INTEGER``, enumeration, ``SET``).

I played around with several ``%feature``\ s and ``%pragma``\ s that
split the task up into converting the C bit patterns (integer or bit
set) into Modula-3 bit patterns (integer or bit set) and change the type
as requested. See the corresponding example in the
Examples/modula3/enum/example.i file. This is quite messy and not
satisfying. So the best what you can currently do is to rewrite constant
definitions manually. Though this is a tedious work that I'd like to
automate.

Objects
~~~~~~~~~~~~~~

Declarations of C++ classes are mapped to ``OBJECT`` types while it is
tried to retain the access hierarchy "public - protected - private"
using partial revelation. Though the example in
Examples/modula3/class/example.i is not really useful, yet.

Imports
~~~~~~~~~~~~~~

Pieces of Modula-3 code provided by typemaps may contain identifiers
from foreign modules. If the typemap ``m3wrapinconv`` for ``blah *``
contains code using the function ``M3toC.SharedTtoS`` you may declare
``%typemap("m3wrapinconv:import") blah * %{M3toC%}``. Then the module
``M3toC`` is imported if the ``m3wrapinconv`` typemap for ``blah *`` is
used at least once. Use
``%typemap("m3wrapinconv:import") blah * %{MyConversions AS M3toC%}`` if
you need module renaming. Unqualified import is not supported.

It is cumbersome to add this typemap to each piece of Modula-3 code. It
is especially useful when writing general typemaps for the modula3.swg
typemap library. For a monolithic module you might be better off if you
add the imports directly:

.. container:: code

   ::

      %insert(m3rawintf) %{
      IMPORT M3toC;
      %}

Exceptions
~~~~~~~~~~~~~~~~~

Modula-3 provides another possibility of an output of a function:
exceptions.

Any piece of Modula-3 code that SWIG inserts due to a typemap can raise
an exception. This way you can also convert an error code from a C
function into a Modula-3 exception.

The ``RAISES`` clause is controlled by typemaps with the ``throws``
extension. If the typemap ``m3wrapinconv`` for ``blah *`` contains code
that may raise the exceptions ``OSError.E`` you should declare
``%typemap("m3wrapinconv:throws") blah * %{OSError.E%}``.

Example
~~~~~~~~~~~~~~

The generation of wrappers in Modula-3 needs very fine control to take
advantage of the language features. Here is an example of a generated
wrapper where almost everything is generated by a typemap:

.. container:: code

   ::

               (* %relabel  m3wrapinmode m3wrapinname m3wrapintype  m3wrapindefault *)
        PROCEDURE Name     (READONLY       str       :    TEXT    :=      ""       )
                    (* m3wrapoutcheck:throws *)
           : NameResult RAISES {E} =
          CONST
            arg1name = "str";                  (* m3wrapargconst *)
          VAR
            arg0   : C.char_star;              (* m3wrapretvar *)
            arg1   : C.char_star;              (* m3wrapargvar *)
            arg2   : C.int;
            result : RECORD
                 (*m3wrapretname  m3wraprettype*)
                       unixPath : TEXT;
                 (*m3wrapoutname  m3wrapouttype*)
                       checksum : CARDINAL;
                     END;
          BEGIN
            TRY
              arg1 := M3toC.SharedTtoS(str);   (* m3wrapinconv *)
              IF Text.Length(arg1) > 10 THEN   (* m3wrapincheck *)
                RAISE E("str too long");
              END;
       (* m3wrapretraw           m3wrapargraw *)
              arg0 := MessyToUnix  (arg1,   arg2);
              result.unixPath := M3toC.CopyStoT(arg0);  (* m3wrapretconv *)
              result.checksum := arg2;         (* m3wrapoutconv *)
              IF result.checksum = 0 THEN      (* m3wrapoutcheck *)
                RAISE E("invalid checksum");
              END;
            FINALLY
              M3toC.FreeSharedS(str, arg1);     (* m3wrapfreearg *)
            END;
          END Name;

More hints to the generator
--------------------------------

Features
~~~~~~~~~~~~~~~

.. list-table::
    :widths: 25 25 50
    :header-rows: 1

    *
      - Feature
      - Example
      - Description
    *
      - multiretval                           
      - %m3multiretval get_box; or 
        %feature("modula3:multiretval")     
        get_box;                   
      - Let the denoted function return a ``RECORD`` rather than a plain value.
        This ``RECORD`` contains all arguments with "out" direction including the return value of the C function
        (if there is one). 
        If more than one argument is "out" then the function **must** have the ``multiretval`` feature activated, but it is explicitly requested from the user to prevent mistakes.
    *
      - constnumeric
      - %constnumeric(12) twelve;  
        or                        
        %feature("constnumeric", "12") twelve;              
      - This feature can be used to tell Modula-3's back-end of SWIG the value of an identifier.  
        This is necessary in the cases where it was defined by a non-trivial C expression. 
        This feature is used by the ``-generateconst`` `option <#Modula3_commandline>`__.
        In future it may be generalized to other kind of values such as strings. 

Pragmas
~~~~~~~~~~~~~~

.. list-table::
    :widths: 25 25 50
    :header-rows: 1

    *
      - Pragma
      - Example
      - Description
    *
      - unsafe
      - ``%pragma(modula3) unsafe="true";``
      - Mark the raw interface modules as ``UNSAFE``. 
        This will be necessary in many cases.
    *
      - library
      - ``%pragma(modula3) library="m3fftw";``
      - Specifies the library name for the wrapper library to be created.
        It should be distinct from the name of the library to be wrapped.    

Remarks
------------

-  The Modula-3 part of SWIG doesn't try to generate nicely formatted
   code. If you need to read the generated code, use ``m3pp`` to
   postprocess the Modula files.

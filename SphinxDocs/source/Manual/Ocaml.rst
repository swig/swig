SWIG and OCaml
=================

This chapter describes SWIG's support of Ocaml.

Ocaml is a relatively recent addition to the ML family, and is a recent
addition to SWIG. It's the second compiled, typed language to be added.
Ocaml has widely acknowledged benefits for engineers, mostly derived
from a sophisticated type system, compile-time checking which eliminates
several classes of common programming errors, and good native
performance. While all of this is wonderful, there are well-written C
and C++ libraries that Ocaml users will want to take advantage of as
part of their arsenal (such as SSL and gdbm), as well as their own
mature C and C++ code. SWIG allows this code to be used in a natural,
type-safe way with Ocaml, by providing the necessary, but repetitive
glue code which creates and uses Ocaml values to communicate with C and
C++ code. In addition, SWIG also produces the needed Ocaml source that
binds variants, functions, classes, etc.

If you're not familiar with the Objective Caml language, you can visit
`The Ocaml Website <http://ocaml.org/>`__.

Preliminaries
------------------

SWIG is compatible with OCaml 3.12.0 and above. Given the choice, you
should use the latest stable release. The SWIG Ocaml module has been
tested on Linux (x86, PPC, Sparc) and Cygwin on Windows. The best way to
determine whether your system will work is to compile the examples and
test-suite which come with SWIG. You can do this by running
``make check`` from the SWIG root directory after installing SWIG. The
Ocaml module has been tested using the system's dynamic linking (the
usual -lxxx against libxxx.so, as well as with Gerd Stolpmann's `Dl
package <http://download.camlcity.org/download/>`__. The ocaml_dynamic
and ocaml_dynamic_cpp targets in the file Examples/Makefile illustrate
how to compile and link SWIG modules that will be loaded dynamically.
This has only been tested on Linux so far.

Running SWIG
~~~~~~~~~~~~~~~~~~~

The basics of getting a SWIG Ocaml module up and running can be seen
from one of SWIG's example Makefiles, but is also described here. To
build an Ocaml module, run SWIG using the ``-ocaml`` option.

.. container:: code

   ::

      %swig -ocaml example.i

This will produce 3 files. The file ``example_wrap.c`` contains all of
the C code needed to build an Ocaml module. To build the module, you
will compile the file ``example_wrap.c`` with ``ocamlc`` or ``ocamlopt``
to create the needed .o file. You will need to compile the resulting .ml
and .mli files as well, and do the final link with -custom (not needed
for native link).

Compiling the code
~~~~~~~~~~~~~~~~~~~~~~~~~

The OCaml SWIG module now requires you to compile a module (``Swig``)
separately. In addition to aggregating common SWIG functionality, the
Swig module contains the data structure that represents C/C++ values.
This allows easier data sharing between modules if two or more are
combined, because the type of each SWIG'ed module's c_obj is derived
from Swig.c_obj_t. This also allows SWIG to acquire new conversions
painlessly, as well as giving the user more freedom with respect to
custom typing. Use ``ocamlc`` or ``ocamlopt`` to compile your SWIG
interface like:

.. container:: code

   ::

      % swig -ocaml -co swig.mli ; swig -ocaml -co swig.ml
      % ocamlc -c swig.mli ; ocamlc -c swig.ml
      % ocamlc -c -ccopt "-I/usr/include/foo" example_wrap.c
      % ocamlc -c example.mli
      % ocamlc -c example.ml

``ocamlc`` is aware of .c files and knows how to handle them.
Unfortunately, it does not know about .cxx, .cc, or .cpp files, so when
SWIG is invoked in C++ mode, you must:

.. container:: code

   ::

      % cp example_wrap.cxx example_wrap.cxx.c
      % ocamlc -c ... -ccopt -xc++ example_wrap.cxx.c
      % ...

The camlp4 module
~~~~~~~~~~~~~~~~~~~~~~~~

The camlp4 module (swigp4.ml -> swigp4.cmo) contains a simple rewriter
which makes C++ code blend more seamlessly with objective caml code. Its
use is optional, but encouraged. The source file is included in the
Lib/ocaml directory of the SWIG source distribution. You can checkout
this file with ``"swig -ocaml -co swigp4.ml"``. You should compile the
file with
:literal:`"ocamlc -I \`camlp4 -where\` -pp 'camlp4o pa_extend.cmo q_MLast.cmo' -c swigp4.ml"`

The basic principle of the module is to recognize certain non-caml
expressions and convert them for use with C++ code as interfaced by
SWIG. The camlp4 module is written to work with generated SWIG
interfaces, and probably isn't great to use with anything else.

Here are the main rewriting rules:

.. list-table::
    :widths: 25 50
    :header-rows: 1 


    *
      - Input                             
      - Rewritten_to
    *
      - f'( ... ) as in                   
      - f(C_list [ ... ]) as in                
    *
      - atoi'("0") or _exit'(0)                    
      - atoi (C_list [ C_string "0" ]) or _exit (C_list [ C_int 0 ])
    *
      - object -> method ( ... )
      - (invoke object) "method" (C_list [ ...])
    *
      - object 'binop argument as in a \'+=_b
      - (invoke object) "+=" argument as in (invoke_a) "+="_b
    *
      - Note that because camlp4 always recognizes << and >>, they are replaced by
        lsl_and_lsr_in_operator_names. 
      -
    *
      - 'unop object as in ! a'
      - (invoke a) "!" C_void                  
    *
      - Smart pointer access like this  
        object '->_method_(_args_)      
      - (invoke (invoke object "->" C_void))
    *
      - Invoke syntax                   
        object ._'(_..._)               
      - (invoke object) "()" (C_list [ ... ])
    *
      - Array syntax                    
        object '[_10_]                  
      - (invoke object) "[]" (C_int 10)
    *
      - Assignment syntax              
        let a = '10 and b = '"foo" and
        c = '1.0_and_d_=_'true          
      - let a = C_int 10 and b = C_string "foo"
        and c = C_double 1.0 and d = C_bool
        true
    * 
      - Cast syntax                     
        let a = _atoi '("2") as int    
        let b = (getenv "PATH") to  
        string                         
        This works for int, string,   
        float, bool                     
      - let a = get_int (_atoi (C_string "2"))
        let b = C_string (getenv "PATH")

Using your module
~~~~~~~~~~~~~~~~~~~~~~~~

You can test-drive your module by building a toplevel ocaml interpreter.
Consult the ocaml manual for details.

When linking any ocaml bytecode with your module, use the -custom option
to build your functions into the primitive list. This option is not
needed when you build native code.

Compilation problems and compiling with C++
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As mentioned above, .cxx files need special handling to be compiled with
``ocamlc``. Other than that, C code that uses ``class`` as a
non-keyword, and C code that is too liberal with pointer types may not
compile under the C++ compiler. Most code meant to be compiled as C++
will not have problems.

The low-level Ocaml/C interface
------------------------------------

In order to provide access to overloaded functions, and provide sensible
outputs from them, all C entities are represented as members of the
c_obj type:

In the code as seen by the typemap writer, there is a value,
swig_result, that always contains the current return data. It is a list,
and must be appended with the caml_list_append function, or with
functions and macros provided by objective caml.

.. container:: code

   ::

      type c_obj =
          C_void
        | C_bool of bool
        | C_char of char
        | C_uchar of char
        | C_short of int
        | C_ushort of int
        | C_int of int
        | C_uint of int32
        | C_int32 of int32
        | C_int64 of int64
        | C_float of float
        | C_double of float
        | C_ptr of int64 * int64
        | C_array of c_obj array
        | C_list of c_obj list
        | C_obj of (string -> c_obj -> c_obj)
        | C_string of string
        | C_enum of c_enum_t

A few functions exist which generate and return these:

-  caml_ptr_val receives a c_obj and returns a void \*. This should be
   used for all pointer purposes.
-  caml_long_val receives a c_obj and returns a long. This should be
   used for most integral purposes.
-  caml_val_ptr receives a void \* and returns a c_obj.
-  caml_val_bool receives a C int and returns a c_obj representing its
   bool value.
-  caml_val_(u)?(char|short|int|long|float|double) receives an
   appropriate C value and returns a c_obj representing it.
-  caml_val_string receives a char \* and returns a string value.
-  caml_val_string_len receives a char \* and a length and returns a
   string value.
-  caml_val_obj receives a void \* and an object type and returns a
   C_obj, which contains a closure giving method access.

Because of this style, a typemap can return any kind of value it wants
from a function. This enables out typemaps and inout typemaps to work
well. The one thing to remember about outputting values is that you must
append them to the return list with swig_result =
caml_list_append(swig_result, v).

This function will return a new list that has your element appended.
Upon return to caml space, the fnhelper function beautifies the result.
A list containing a single item degrades to only that item (i.e. [ C_int
3 ] -> C_int 3), and a list containing more than one item is wrapped in
C_list (i.e. [ C_char 'a' ; C_char 'b' ] -> C_list [ C_char 'a' ; C_char
'b' ]). This is in order to make return values easier to handle when
functions have only one return value, such as constructors, and
operators. In addition, string, pointer, and object values are
interchangeable with respect to caml_ptr_val, so you can allocate memory
as caml strings and still use the resulting pointers for C purposes,
even using them to construct simple objects on. Note, though, that
foreign C++ code does not respect the garbage collector, although the
SWIG interface does.

The wild card type that you can use in lots of different ways is C_obj.
It allows you to wrap any type of thing you like as an object using the
same mechanism that the ocaml module does. When evaluated in
caml_ptr_val, the returned value is the result of a call to the object's
"&" operator, taken as a pointer.

You should only construct values using objective caml, or using the
functions caml_val_* functions provided as static functions to a SWIG
ocaml module, as well as the caml_list_* functions. These functions
provide everything a typemap needs to produce values. In addition, value
items pass through directly, but you must make your own type signature
for a function that uses value in this way.

The generated module
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The SWIG ``%module`` directive specifies the name of the Ocaml module to
be generated. If you specified \`\ ``%module example``', then your Ocaml
code will be accessible in the module Example. The module name is always
capitalized as is the ocaml convention. Note that you must not use any
Ocaml keyword to name your module. Remember that the keywords are not
the same as the C++ ones.

You can introduce extra code into the output wherever you like with
SWIG. These are the places you can introduce code:

.. list-table::
    :widths: 25 50
    :header-rows: 1


    *
      - "header"
      - This code is inserted near the beginning of the C 
        wrapper file, before any function definitions.    
    *
      - "wrapper"
      - This code is inserted in the function definition
        section.
    *
      - "runtime"
      - This code is inserted near the end of the C
        wrapper file.
    *
      - "mli"
      - This code is inserted into the caml interface
        file. Special signatures should be inserted here.
    *
      - "ml"
      - This code is inserted in the caml code defining
        the interface to your C code. Special caml code, 
        as well as any initialization which should run
        when the module is loaded may be inserted here.
    *
      - "classtemplate"
      - The "classtemplate" place is special because it
        describes the output SWIG will generate for class
        definitions.

Enums
~~~~~~~~~~~~

SWIG will wrap enumerations as polymorphic variants in the output Ocaml
code, as above in C_enum. In order to support all C++-style uses of
enums, the function int_to_enum and enum_to_int are provided for ocaml
code to produce and consume these values as integers. Other than that,
correct uses of enums will not have a problem. Since enum labels may
overlap between enums, the enum_to_int and int_to_enum functions take an
enum type label as an argument. Example:

.. container:: code

   ::

      %module enum_test
      %{
      enum c_enum_type { a = 1, b, c = 4, d = 8 };
      %}
      enum c_enum_type { a = 1, b, c = 4, d = 8 };

The output mli contains:

.. container:: code

   ::

      type c_enum_type = [
        `unknown
      | `c_enum_type
      ]
      type c_enum_tag = [
        `int of int
      | `a
      | `b
      | `c
      | `d
      ]
      val int_to_enum c_enum_type -> int -> c_obj
      val enum_to_int c_enum_type -> c_obj -> c_obj

So it's possible to do this:

.. container:: code

   ::

      bash-2.05a$ ocamlmktop -custom enum_test_wrap.o enum_test.cmo -o enum_test_top
      bash-2.05a$ ./enum_test_top
              Objective Caml version 3.04

      # open Enum_test ;;
      # let x = C_enum `a ;;
      val x : Enum_test.c_obj = C_enum `a
      # enum_to_int `c_enum_type x ;;
      - : Enum_test.c_obj = C_int 1
      # int_to_enum `c_enum_type 4 ;;
      - : Enum_test.c_obj = C_enum `c

Enum typing in Ocaml
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ocaml SWIG module now has support for loading and using multiple
SWIG modules at the same time. This enhances modularity, but presents
problems when used with a language which assumes that each module's
types are complete at compile time. In order to achieve total soundness
enum types are now isolated per-module. The type issue matters when
values are shared between functions imported from different modules. You
must convert values to master values using the swig_val function before
sharing them with another module.

Arrays
~~~~~~~~~~~~~

Simple types of bounded arrays
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

SWIG has support for array types, but you generally will need to provide
a typemap to handle them. You can currently roll your own, or expand
some of the macros provided (but not included by default) with the SWIG
distribution.

By including "carray.i", you will get access to some macros that help
you create typemaps for array types fairly easily.

``%make_simple_array_typemap`` is the easiest way to get access to
arrays of simple types with known bounds in your code, but this only
works for arrays whose bounds are completely specified.

Complex and unbounded arrays
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Unfortunately, unbounded arrays and pointers can't be handled in a
completely general way by SWIG, because the end-condition of such an
array can't be predicted. In some cases, it will be by consent (e.g. an
array of four or more chars), sometimes by explicit length (char
\*buffer, int len), and sometimes by sentinel value (0, -1, etc.). SWIG
can't predict which of these methods will be used in the array, so you
have to specify it for yourself in the form of a typemap.

Using an object
^^^^^^^^^^^^^^^^^^^^^^^^

It's possible to use C++ to your advantage by creating a simple object
that provides access to your array. This may be more desirable in some
cases, since the object can provide bounds checking, etc., that prevents
crashes.

Consider writing an object when the ending condition of your array is
complex, such as using a required sentinel, etc.

Example typemap for a function taking float \* and int
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is a simple example ``in`` typemap for an array of float, where the
length of the array is specified as an extra parameter. Other such
typemaps will work similarly. In the example, the function printfloats
is called with a float array, and specified length. The actual length
reported in the len argument is the length of the array passed from
ocaml, making passing an array into this type of function convenient.


+---------------------------------------------------------------------------------+
|tarray.i                                                                         |
+=================================================================================+
| ::                                                                              |
|                                                                                 |
|    %module tarray                                                               |
|    %{                                                                           |
|    #include <stdio.h>                                                           |
|                                                                                 |
|    void printfloats( float *tab, int len ) {                                    |
|      int i;                                                                     |
|                                                                                 |
|      for( i = 0; i < len; i++ ) {                                               |
|        printf( "%f ", tab[i] );                                                 |
|      }                                                                          |
|                                                                                 |
|      printf( "\n" );                                                            |
|    }                                                                            |
|    %}                                                                           |
|                                                                                 |
|    %typemap(in) (float *tab, int len) {                                         |
|      int i;                                                                     |
|      /* $*1_type */                                                             |
|      $2 = caml_array_len($input);                                               |
|      $1 = ($*1_type *)malloc( $2 * sizeof( float ) );                           |
|      for( i = 0; i < $2; i++ ) {                                                |
|        $1[i] = caml_double_val(caml_array_nth($input, i));                      |
|      }                                                                          |
|    }                                                                            |
|                                                                                 |
|    void printfloats( float *tab, int len );                                     |
+---------------------------------------------------------------------------------+
| Sample Run                                                                      |
+---------------------------------------------------------------------------------+
| ::                                                                              |
|                                                                                 |
|    # open Tarray ;;                                                             |
|    # _printfloats (C_array [| C_double 1.0 ; C_double 3.0 ; C_double 5.6666 |]) |
|    ;;                                                                           |
|    1.000000 3.000000 5.666600                                                   |
|    - : Tarray.c_obj = C_void                                                    |
|                                                                                 |
+---------------------------------------------------------------------------------+          

C++ Classes
~~~~~~~~~~~~~~~~~~

C++ classes, along with structs and unions are represented by C_obj
(string -> c_obj -> c_obj) wrapped closures. These objects contain a
method list, and a type, which allow them to be used like C++ objects.
When passed into typemaps that use pointers, they degrade to pointers
through their "&" method. Every method an object has is represented as a
string in the object's method table, and each method table exists in
memory only once. In addition to any other operators an object might
have, certain builtin ones are provided by SWIG: (all of these take no
arguments (C_void))

.. list-table::
    :widths: 25 50
    :header-rows: 1

    *
      - "~"
      - Delete this object
    *
      - "&"                 
      - Return an ordinary C_ptr value representing   
        this object's address
    *
      - "sizeof"
      - If enabled with ("sizeof"="1") on the module 
        node, return the object's size in char.
    *
      - ":methods"          
      - Returns a list of strings containing the
        names of the methods this object contains
    *
      - ":classof"
      - Returns the name of the class this object
        belongs to.
    *
      - ":parents"
      - Returns a list of all direct parent classes
        which have been wrapped by SWIG.
    *
      - "::[parent-class]"
      - Returns a view of the object as the indicated
        parent class. This is mainly used internally  
        by the SWIG module, but may be useful to
        client programs.
    *
      - "[member-variable]"
      - Each member variable is wrapped as a method   
        with an optional parameter. Called with one
        argument, the member variable is set to the
        value of the argument. With zero arguments,
        the value is returned.


Note that this string belongs to the wrapper object, and not the
underlying pointer, so using create_[x]_from_ptr alters the returned
value for the same object.

STL vector and string Example
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Standard typemaps are now provided for STL vector and string. More are
in the works. STL strings are passed just like normal strings, and
returned as strings. STL string references don't mutate the original
string, (which might be surprising), because Ocaml strings are mutable
but have fixed length. Instead, use multiple returns, as in the
argout_ref example.

+-----------------------------------------------------------------------+
| example.i                                                             |
+=======================================================================+
| ::                                                                    |
|                                                                       |
|    %module example                                                    |
|    %{                                                                 |
|    #include "example.h"                                               |
|    %}                                                                 |
|                                                                       |
|    %include <stl.i>                                                   |
|                                                                       |
|    namespace std {                                                    |
|      %template(StringVector) std::vector < string >;                  |
|    };                                                                 |
|                                                                       |
|    %include "example.h"                                               |
+-----------------------------------------------------------------------+
| *This example is in Examples/ocaml/stl*                               |
+-----------------------------------------------------------------------+

Since there's a makefile in that directory, the example is easy to
build.

Here's a sample transcript of an interactive session using a string
vector after making a toplevel (make toplevel). This example uses the
camlp4 module.

.. container:: code

   ::

      bash-2.05a$ ./runme_top
              Objective Caml version 3.06

              Camlp4 Parsing version 3.06

      # open Swig ;;
      # open Example ;;
      # let x = new_StringVector '() ;;
      val x : Example.c_obj = C_obj <fun>
      # x -> ":methods" () ;;
      - : Example.c_obj =
      C_list
       [C_string "nop"; C_string "size"; C_string "empty"; C_string "clear";
        C_string "push_back"; C_string "[]"; C_string "="; C_string "set";
        C_string "~"; C_string "&"; C_string ":parents"; C_string ":classof";
        C_string ":methods"]
      # x -> push_back ("foo") ;;
      - : Example.c_obj = C_void
      # x -> push_back ("bar") ;;
      - : Example.c_obj = C_void
      # x -> push_back ("baz") ;;
      - : Example.c_obj = C_void
      # x '[1] ;;
      - : Example.c_obj = C_string "bar"
      # x -> set (1, "spam") ;;
      - : Example.c_obj = C_void
      # x '[1] ;;
      - : Example.c_obj = C_string "spam"
      # for i = 0 to (x -> size() as int) - 1 do
          print_endline ((x '[i to int]) as string)
        done ;;
      foo
      bar
      baz
      - : unit = ()
      #

C++ Class Example
^^^^^^^^^^^^^^^^^^^^^^^^^^

Here's a simple example using Trolltech's Qt Library:

+-----------------------------------------------------------------------+
| qt.i                                                                  |
+=======================================================================+
| ::                                                                    |
|                                                                       |
|    %module qt                                                         |
|    %{                                                                 |
|    #include <qapplication.h>                                          |
|    #include <qpushbutton.h>                                           |
|    %}                                                                 |
|    class QApplication {                                               |
|    public:                                                            |
|      QApplication( int argc, char **argv );                           |
|      void setMainWidget( QWidget *widget );                           |
|      void exec();                                                     |
|    };                                                                 |
|                                                                       |
|    class QPushButton {                                                |
|    public:                                                            |
|      QPushButton( char *str, QWidget *w );                            |
|      void resize( int x, int y );                                     |
|      void show();                                                     |
|    };                                                                 |
+-----------------------------------------------------------------------+

Compiling the example
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. container:: code

   ::

      bash-2.05a$ QTPATH=/your/qt/path
      bash-2.05a$ for file in swig.mli swig.ml swigp4.ml ; do swig -ocaml -co $file ; done
      bash-2.05a$ ocamlc -c swig.mli ; ocamlc -c swig.ml
      bash-2.05a$ ocamlc -I `camlp4 -where` -pp "camlp4o pa_extend.cmo q_MLast.cmo" -c swigp4.ml
      bash-2.05a$ swig -ocaml -c++ -I$QTPATH/include qt.i
      bash-2.05a$ mv qt_wrap.cxx qt_wrap.c
      bash-2.05a$ ocamlc -c -ccopt -xc++ -ccopt -g -g -ccopt -I$QTPATH/include qt_wrap.c
      bash-2.05a$ ocamlc -c qt.mli
      bash-2.05a$ ocamlc -c qt.ml
      bash-2.05a$ ocamlmktop -custom swig.cmo -I `camlp4 -where` \
        camlp4o.cma swigp4.cmo qt_wrap.o qt.cmo -o qt_top -cclib \
        -L$QTPATH/lib -cclib -lqt

Sample Session
^^^^^^^^^^^^^^^^^^^^^^^

.. container:: code

   ::

      bash-2.05a$ ./qt_top
              Objective Caml version 3.06

              Camlp4 Parsing version 3.06

      # open Swig ;;
      # open Qt ;;
      # let a = new_QApplication '(0, 0) ;;
      val a : Qt.c_obj = C_obj <fun>
      # let hello = new_QPushButton '("hi", 0) ;;
      val hello : Qt.c_obj = C_obj <fun>
      # hello -> resize (100, 30) ;;
      - : Qt.c_obj = C_void
      # hello -> show () ;;
      - : Qt.c_obj = C_void
      # a -> exec () ;;

Assuming you have a working installation of QT, you will see a window
containing the string "hi" in a button.

Director Classes
~~~~~~~~~~~~~~~~~~~~~~~

Director Introduction
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Director classes are classes which allow Ocaml code to override the
public methods of a C++ object. This facility allows the user to use C++
libraries that require a derived class to provide application specific
functionality in the context of an application or utility framework.

You can turn on director classes by using an optional module argument
like this:

.. container:: code

   ::

      %module(directors="1")

      ...

      // Turn on the director class for a specific class like this:
      %feature("director")
      class foo {
        ...
      };

Overriding Methods in Ocaml
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Because the Ocaml language module treats C++ method calls as calls to a
certain function, all you need to do is to define the function that will
handle the method calls in terms of the public methods of the object,
and any other relevant information. The function ``new_derived_object``
uses a stub class to call your methods in place of the ones provided by
the underlying implementation. The object you receive is the underlying
object, so you are free to call any methods you want from within your
derived method. Note that calls to the underlying object do not invoke
Ocaml code. You need to handle that yourself.

``new_derived_object`` receives your function, the function that creates
the underlying object, and any constructor arguments, and provides an
object that you can use in any usual way. When C++ code calls one of the
object's methods, the object invokes the Ocaml function as if it had
been invoked from Ocaml, allowing any method definitions to override the
C++ ones.

In this example, I'll examine the objective caml code involved in
providing an overloaded class. This example is contained in
Examples/ocaml/shapes.

Director Usage Example
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

+-----------------------------------------------------------------------+
| runme.ml                                                              |
+=======================================================================+
| ::                                                                    |
|                                                                       |
|    open Swig                                                          |
|    open Example                                                       |
|                                                                       |
|    ...                                                                |
|                                                                       |
|    let triangle_class pts ob meth args =                              |
|      match meth with                                                  |
|          "cover" ->                                                   |
|            (match args with                                           |
|                 C_list [ x_arg ; y_arg ] ->                           |
|                 let xa = x_arg as float                               |
|                 and ya = y_arg as float in                            |
|                   (point_in_triangle pts xa ya) to bool               |
|           | _ -> raise (Failure "cover needs two double arguments.")) |
|        | _ -> (invoke ob) meth args ;;                                |
|                                                                       |
|    ...                                                                |
|                                                                       |
|    let triangle =                                                     |
|      new_derived_object                                               |
|        new_shape                                                      |
|        (triangle_class ((0.0, 0.0), (0.5, 1.0), (1.0, 0.6)))          |
|        '() ;;                                                         |
|                                                                       |
|    let _ = _draw_shape_coverage '(triangle, 60, 20) ;;                |
+-----------------------------------------------------------------------+

This is the meat of what you need to do. The actual "class" definition
containing the overloaded method is defined in the function
triangle_class. This is a lot like the class definitions emitted by
SWIG, if you look at example.ml, which is generated when SWIG consumes
example.i. Basically, you are given the arguments as a c_obj and the
method name as a string, and you must intercept the method you are
interested in and provide whatever return value you need. Bear in mind
that the underlying C++ code needs the right return type, or an
exception will be thrown. This exception will generally be Failure, or
NotObject. You must call other ocaml methods that you rely on yourself.
Due to the way directors are implemented, method calls on your object
from with ocaml code will always invoke C++ methods even if they are
overridden in ocaml.

In the example, the draw_shape_coverage function plots the indicated
number of points as either covered (``x``) or uncovered ( ) between 0
and 1 on the X and Y axes. Your shape implementation can provide any
coverage map it likes, as long as it responds to the "cover" method call
with a boolean return (the underlying method returns bool). This might
allow a tricky shape implementation, such as a boolean combination, to
be expressed in a more effortless style in ocaml, while leaving the
"engine" part of the program in C++.

Creating director objects
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The definition of the actual object triangle can be described this way:

.. container:: code

   ::

      let triangle =
        new_derived_object
          new_shape
          (triangle_class ((0.0, 0.0), (0.5, 1.0), (1.0, 0.0)))
          '()

The first argument to ``new_derived_object``, new_shape is the method
which returns a shape instance. This function will be invoked with the
third argument will be appended to the argument list [ C_void ]. In the
example, the actual argument list is sent as (C_list [ C_void ; C_void
]). The augmented constructor for a director class needs the first
argument to determine whether it is being constructed as a derived
object, or as an object of the indicated type only (in this case
``shape``). The Second argument is a closure that will be added to the
final C_obj.

The actual object passed to the self parameter of the director object
will be a C_director_core, containing a c_obj option ref and a c_obj.
The c_obj provided is the same object that will be returned from
new_derived object, that is, the object exposing the overridden methods.
The other part is an option ref that will have its value extracted
before becoming the ``ob`` parameter of your class closure. This ref
will contain ``None`` if the C++ object underlying is ever destroyed,
and will consequently trigger an exception when any method is called on
the object after that point (the actual raise is from an inner function
used by new_derived_object, and throws NotObject). This prevents a
deleted C++ object from causing a core dump, as long as the object is
destroyed properly.

Typemaps for directors, directorin, directorout, directorargout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Special typemaps exist for use with directors, the
``directorin, directorout, directorargout`` are used in place of
``in, out, argout`` typemaps, except that their direction is reversed.
They provide for you to provide argout values, as well as a function
return value in the same way you provide function arguments, and to
receive arguments the same way you normally receive function returns.

directorin typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``directorin`` typemap is used when you will receive arguments from
a call made by C++ code to you, therefore, values will be translated
from C++ to ocaml. You must provide some valid C_obj value. This is the
value your ocaml code receives when you are called. In general, a simple
``directorin`` typemap can use the same body as a simple ``out``
typemap.

directorout typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``directorout`` typemap is used when you will send an argument from
your code back to the C++ caller. That is; directorout specifies a
function return conversion. You can usually use the same body as an
``in`` typemap for the same type, except when there are special
requirements for object ownership, etc.

directorargout typemap
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

C++ allows function arguments which are by pointer (*) and by reference
(&) to receive a value from the called function, as well as sending one
there. Sometimes, this is the main purpose of the argument given.
``directorargout`` typemaps allow your caml code to emulate this by
specifying additional return values to be put into the output
parameters. The SWIG ocaml module is a bit loose in order to make code
easier to write. In this case, your return to the caller must be a list
containing the normal function return first, followed by any argout
values in order. These argout values will be taken from the list and
assigned to the values to be returned to C++ through directorargout
typemaps. In the event that you don't specify all of the necessary
values, integral values will read zero, and struct or object returns
have undefined results.

Exceptions
~~~~~~~~~~~~~~~~~

If an error occurs in a C or C++ function, you may want to convert that
error into an OCaml exception. To do this, you can use the
``%exception`` directive. The ``%exception`` directive simply lets you
rewrite part of the generated wrapper code to include an error check. It
is detailed in full in the `Exception handling with
%exception <Customization.html#Customization_exception>`__ section.

In C, a function often indicates an error by returning a status code
(e.g. a negative number or a NULL pointer). Here is a simple example of
how you might handle that:

.. container:: code

   ::

      %exception malloc {
        $action
        if (result == NULL) {
          caml_failwith("Not enough memory");
        }
      }
      void *malloc(size_t nbytes);

In OCaml:

.. container:: code

   ::

      # let a = _malloc (C_int 20000000000);;
      Exception: Failure "Not enough memory".
      #

If a library provides some kind of general error handling framework, you
can also use that. For example:

.. container:: code

   ::

      %exception {
        $action
        if (err_occurred()) {
          caml_failwith(err_message());
        }
      }

If no declaration name is given to ``%exception``, it is applied to all
wrapper functions. ``$action`` is a SWIG special variable and is
replaced by the C/C++ function call being wrapped.

C++ exceptions are also easy to handle. We can catch a C++ exception and
rethrow it as an OCaml exception like this:

.. container:: code

   ::

      %exception getitem {
        try {
          $action
        } catch (std::out_of_range &e) {
          caml_failwith(e.what());
        }
      }

      class FooClass {
        public:
          int getitem(int index);      // Exception handling added
          ...
      };

The language-independent ``exception.i`` library file can also be used
to raise exceptions. See the `SWIG Library <Library.html#Library>`__
chapter.

Documentation Features
---------------------------

The features described in this section can be used to generate
documentation comments (colloquially referred to as "docstrings") that
can be read by
`OCamldoc <https://caml.inria.fr/pub/docs/manual-ocaml/ocamldoc.html>`__.

Module docstring
~~~~~~~~~~~~~~~~~~~~~~~

The first documentation comment of an ``mli`` file is the comment
associated with the entire module. SWIG supports this by setting an
option of the ``%module`` directive. For example:

.. container:: code

   ::

      %module(docstring="This is the example module's docstring") example

When you have more than just a line or so, you can retain the
readability of the ``%module`` directive by using a macro. For example:

.. container:: code

   ::

      %define DOCSTRING
      "The `XmlResource` class allows program resources defining menus,
      controls on a panel, etc. to be loaded from an XML file."
      %enddef

      %module(docstring=DOCSTRING) xrc

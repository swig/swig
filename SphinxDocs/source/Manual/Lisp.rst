SWIG and Common Lisp
=======================

Common Lisp is a high-level, all-purpose, object-oriented, dynamic,
functional programming language with long history. Common Lisp is used
in many fields, ranging from web development to finance, and also common
in computer science education. There are more than 9 different
implementations of common lisp which are available, all have different
foreign function interfaces. SWIG currently supports the Common Foreign
Function Interface(CFFI).

Common Foreign Function Interface(CFFI)
--------------------------------------------

CFFI, the Common Foreign Function Interface, is a portable foreign
function interface for ANSI Common Lisp systems. CFFI requires only a
small set of low-level functionality from the Lisp implementation, such
as calling a foreign function by name, allocating foreign memory, and
dereferencing pointers.

To run the cffi module of SWIG requires very little effort, you just
need to run:

.. container:: code

   ::

      swig -cffi -module module-name   file-name 

But a better was of using all the power of SWIG is to write SWIG
interface files. Below we will explain how to write interface files and
the various things which you can do with them.

Additional Commandline Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
    :widths: 25 50
    :header-rows: 1

    *
      - CFFI specific options
      -
    *
      - -generate-typedef
      - If this option is given then defctype will be used to generate shortcuts according to the typedefs
        in the input.
    *
      - -[no]cwrap
      - Turn on or turn off generation of an intermediate C file when creating a C interface. By default
        this is only done for C++ code.                                                    
    *
      - -[no]swig-lisp
      - Turns on or off generation of code for helper lisp macro,functions, etc. 
        which SWIG uses while generating wrappers. These macros, functions may still be used by generated wrapper code.                                      

Generating CFFI bindings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As we mentioned earlier the ideal way to use SWIG is to use interface
files. To illustrate the use of it, let's assume that we have a file
named *test.h* with the following C code:

.. container:: code

   ::

      #define y 5
      #define x (y >>  1)

      typedef int days;

      struct bar {
        short p, q;
        char a, b;
        int *z[1000];
        struct bar * n;
      };
        
      struct   bar * my_struct;

      struct foo {
        int a;
        struct foo * b[100];
      };

      int pointer_func(void (*ClosureFun)( void* _fun, void* _data, void* _evt ), int p);

      int func123(div_t * p, int **q[100], int r[][1000][10]);

      void lispsort_double (int n, double * array);

      enum color { RED, BLUE, GREEN};

Corresponding to this we will write a simple interface file:

.. container:: code

   ::

      %module test

      %include "test.h"

The generated SWIG Code will be:

.. container:: targetlang

   ::

      ;;;SWIG wrapper code starts here

      (cl:defmacro defanonenum (&body enums)
         "Converts anonymous enums to defconstants."
        `(cl:progn , @(cl:loop for value in enums
                              for index = 0 then (cl:1+ index)
                              when (cl:listp value) do (cl:setf index (cl:second value)
                                                                value (cl:first value))
                              collect `(cl:defconstant , value , index))))

      (cl:eval-when (:compile-toplevel :load-toplevel)
        (cl:unless (cl:fboundp 'swig-lispify)
          (cl:defun swig-lispify (name flag cl:&optional (package cl:*package*))
            (cl:labels ((helper (lst last rest cl:&aux (c (cl:car lst)))
                          (cl:cond
                            ((cl:null lst)
                             rest)
                            ((cl:upper-case-p c)
                             (helper (cl:cdr lst) 'upper
                                     (cl:case last
                                       ((lower digit) (cl:list* c #\- rest))
                                       (cl:t (cl:cons c rest)))))
                            ((cl:lower-case-p c)
                             (helper (cl:cdr lst) 'lower (cl:cons (cl:char-upcase c) rest)))
                            ((cl:digit-char-p c)
                             (helper (cl:cdr lst) 'digit 
                                     (cl:case last
                                       ((upper lower) (cl:list* c #\- rest))
                                       (cl:t (cl:cons c rest)))))
                            ((cl:char-equal c #\_)
                             (helper (cl:cdr lst) '_ (cl:cons #\- rest)))
                            (cl:t
                             (cl:error "Invalid character: ~A" c)))))
              (cl:let ((fix (cl:case flag
                              ((constant enumvalue) "+")
                              (variable "*")
                              (cl:t ""))))
                (cl:intern
                 (cl:concatenate
                  'cl:string
                  fix
                  (cl:nreverse (helper (cl:concatenate 'cl:list name) cl:nil cl:nil))
                  fix)
                 package))))))

      ;;;SWIG wrapper code ends here


      (cl:defconstant y 5)

      (cl:defconstant x (cl:ash 5 -1))

      (cffi:defcstruct bar
              (p :short)
              (q :short)
              (a :char)
              (b :char)
              (z :pointer)
              (n :pointer))

      (cffi:defcvar ("my_struct" my_struct)
       :pointer)

      (cffi:defcstruct foo
              (a :int)
              (b :pointer))

      (cffi:defcfun ("pointer_func" pointer_func) :int
        (ClosureFun :pointer)
        (p :int))

      (cffi:defcfun ("func123" func123) :int
        (p :pointer)
        (q :pointer)
        (r :pointer))

      (cffi:defcfun ("lispsort_double" lispsort_double) :void
        (n :int)
        (array :pointer))

      (cffi:defcenum color
              :RED
              :BLUE
              :GREEN)

The *SWIG wrapper* code refers to the special code which SWIG may need
to use while wrapping C code. You can turn on/off the generation of this
code by using the *-[no]swig-lisp* option. You must have noticed that
SWIG goes one extra step to ensure that CFFI does not do automatic
lispification of the C function names. The reason SWIG does this is
because quite often developers want to build a nice CLOS based lispy
API, and this one to one correspondence between C function names and
lisp function name helps.

Maybe you want to have your own convention for generating lisp function
names for corresponding C function names, or you just want to lispify
the names, also, before we forget you want to export the generated lisp
names. To do this, we will use the SWIG `feature
directive <Customization.html#Customization_features>`__. Let's edit the
interface file such that the C type "div_t*" is changed to Lisp type
":my-pointer", we lispify all names, export everything, and do some more
stuff.

.. container:: code

   ::

      %module test

      %typemap(cin) div_t* ":my-pointer";

      %feature("intern_function", "1");
      %feature("export");

      %feature("inline") lispsort_double;
      %feature("intern_function", "my-lispify") lispsort_double;
      %feature("export", package="'some-other-package") lispsort_double;

      %rename func123 renamed_cool_func;

      %ignore "pointer_func";

      %include "test.h"

The *typemap(cin)* ensures that for all arguments which are input to C
with the type "div_t*", the ":my-pointer" type be used. Similarly
*typemap(cout)* are used for all types which are returned from C.

The feature *intern_function* ensures that all C names are interned
using the **swig-lispify** function. The "1" given to the feature is
optional. The use of feature like *%feature("intern_function", "1");*
globally enables interning for everything. If you want to target a
single function, or declaration then use the targeted version of
feature, *%feature("intern_function", "my-lispify") lispsort_double;*,
here we are using an additional feature which allows us to use our
lispify function.

The *export* feature allows us to export the symbols. If the *package*
argument is given, then the symbol will be exported to the specified
Lisp package. The *inline* feature declaims the declared function as
inline. The *rename* directive allows us to change the name(it is useful
when generating C wrapper code for handling overloaded functions). The
*ignore* directive ignores a certain declaration.

There are several other things which are possible, to see some example
of usage of SWIG look at the Lispbuilder and wxCL projects. The
generated code with 'noswig-lisp' option is:

.. container:: targetlang

   ::

      (cl:defconstant #.(swig-lispify "y" 'constant) 5)

      (cl:export '#.(swig-lispify "y" 'constant))

      (cl:defconstant #.(swig-lispify "x" 'constant) (cl:ash 5 -1))

      (cl:export '#.(swig-lispify "x" 'constant))

      (cffi:defcstruct #.(swig-lispify "bar" 'classname)
              (#.(swig-lispify "p" 'slotname) :short)
              (#.(swig-lispify "q" 'slotname) :short)
              (#.(swig-lispify "a" 'slotname) :char)
              (#.(swig-lispify "b" 'slotname) :char)
              (#.(swig-lispify "z" 'slotname) :pointer)
              (#.(swig-lispify "n" 'slotname) :pointer))

      (cl:export '#.(swig-lispify "bar" 'classname))

      (cl:export '#.(swig-lispify "p" 'slotname))

      (cl:export '#.(swig-lispify "q" 'slotname))

      (cl:export '#.(swig-lispify "a" 'slotname))

      (cl:export '#.(swig-lispify "b" 'slotname))

      (cl:export '#.(swig-lispify "z" 'slotname))

      (cl:export '#.(swig-lispify "n" 'slotname))

      (cffi:defcvar ("my_struct" #.(swig-lispify "my_struct" 'variable))
       :pointer)

      (cl:export '#.(swig-lispify "my_struct" 'variable))

      (cffi:defcstruct #.(swig-lispify "foo" 'classname)
              (#.(swig-lispify "a" 'slotname) :int)
              (#.(swig-lispify "b" 'slotname) :pointer))

      (cl:export '#.(swig-lispify "foo" 'classname))

      (cl:export '#.(swig-lispify "a" 'slotname))

      (cl:export '#.(swig-lispify "b" 'slotname))

      (cffi:defcfun ("renamed_cool_func" #.(swig-lispify "renamed_cool_func" 'function)) :int
        (p :my-pointer)
        (q :pointer)
        (r :pointer))

      (cl:export '#.(swig-lispify "renamed_cool_func" 'function))

      (cl:declaim (cl:inline #.(my-lispify "lispsort_double" 'function)))

      (cffi:defcfun ("lispsort_double" #.(my-lispify "lispsort_double" 'function)) :void
        (n :int)
        (array :pointer))

      (cl:export '#.(my-lispify "lispsort_double" 'function) 'some-other-package)

      (cffi:defcenum #.(swig-lispify "color" 'enumname)
              #.(swig-lispify "RED" 'enumvalue :keyword)
              #.(swig-lispify "BLUE" 'enumvalue :keyword)
              #.(swig-lispify "GREEN" 'enumvalue :keyword))

      (cl:export '#.(swig-lispify "color" 'enumname))

Generating CFFI bindings for C++ code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This feature to SWIG (for CFFI) is very new and still far from complete.
Pitch in with your patches, bug reports and feature requests to improve
it.

Generating bindings for C++ code, requires *-c++* option to be present
and it first generates C binding which will wrap the C++ code, and then
generates the corresponding CFFI wrapper code. In the generated C
wrapper code, you will often want to put your own C code, such as the
code to include various files. This can be done by making use of "%{"
and "%}" as shown below.

.. container:: code

   ::

      %{
       #include "Test/test.h"
      %}

Also, while parsing the C++ file and generating C wrapper code SWIG may
need to be able to understand various symbols used in other header
files. To help SWIG in doing this while ensuring that wrapper code is
generated for the target file, use the "import" directive. The "include"
directive specifies the target file for which wrapper code will be
generated.

.. container:: code

   ::


      %import "ancillary/header.h"

      %include "target/header.h"

Various features which were available for C headers can also be used
here. The target header which we are going to use here is:

.. container:: code

   ::

      namespace OpenDemo {
        class Test
        {
          public:
            float x;
            // constructors
            Test (void) {x = 0;}
            Test (float X) {x = X;}

            // vector addition
            Test operator+ (const Test& v) const {return Test (x+v.x);}

            // length squared
            float lengthSquared (void) const {return this->dot (*this);}

            static float distance (const Test& a, const Test& b){return(a-b).length();}

            inline Test parallelComponent (const Test& unitBasis) const {
              return unitBasis * projection;
            }

            Test setYtoZero (void) const {return Test (this->x);}

            static const Test zero;
        };

        inline Test operator* (float s, const Test& v) {return v*s;}

        inline std::ostream& operator<< (std::ostream& o, const Test& v)
        {
          return o << "(" << v.x << ")";
        }

        inline Test RandomUnitVectorOnXZPlane (void)
        {
          return RandomVectorInUnitRadiusSphere().setYtoZero().normalize();
        }
      }

The interface used is:

.. container:: code

   ::

      %module test
      %include "test.cpp"

SWIG generates 3 files, the first one is a C wrap which we don't show,
the second is the plain CFFI wrapper which is as shown below:

.. container:: targetlang

   ::

      (cffi:defcfun ("_wrap_Test_x_set" Test_x_set) :void
        (self :pointer)
        (x :float))

      (cffi:defcfun ("_wrap_Test_x_get" Test_x_get) :float
        (self :pointer))

      (cffi:defcfun ("_wrap_new_Test__SWIG_0" new_Test) :pointer)

      (cffi:defcfun ("_wrap_new_Test__SWIG_1" new_Test) :pointer
        (X :float))

      (cffi:defcfun ("_wrap_Test___add__" Test___add__) :pointer
        (self :pointer)
        (v :pointer))

      (cffi:defcfun ("_wrap_Test_lengthSquared" Test_lengthSquared) :float
        (self :pointer))

      (cffi:defcfun ("_wrap_Test_distance" Test_distance) :float
        (a :pointer)
        (b :pointer))

      (cffi:defcfun ("_wrap_Test_parallelComponent" Test_parallelComponent) :pointer
        (self :pointer)
        (unitBasis :pointer))

      (cffi:defcfun ("_wrap_Test_setYtoZero" Test_setYtoZero) :pointer
        (self :pointer))

      (cffi:defcvar ("Test_zero" Test_zero)
       :pointer)

      (cffi:defcfun ("_wrap_delete_Test" delete_Test) :void
        (self :pointer))

      (cffi:defcfun ("_wrap___mul__" __mul__) :pointer
        (s :float)
        (v :pointer))

      (cffi:defcfun ("_wrap___lshift__" __lshift__) :pointer
        (o :pointer)
        (v :pointer))

      (cffi:defcfun ("_wrap_RandomUnitVectorOnXZPlane" RandomUnitVectorOnXZPlane) :pointer)

The output is pretty good but it fails in disambiguating overloaded
functions such as the constructor, in this case. One way of resolving
this problem is to make the interface use the rename directiv, but
hopefully there are better solutions. In addition SWIG also generates, a
CLOS file

.. container:: targetlang

   ::

      (clos:defclass test()
        ((ff :reader ff-pointer)))

      (clos:defmethod (cl:setf x) (arg0 (obj test))
        (Test_x_set (ff-pointer obj) arg0))

      (clos:defmethod x ((obj test))
        (Test_x_get (ff-pointer obj)))

      (cl:shadow "+")
      (clos:defmethod + ((obj test) (self test) (v test))
        (Test___add__ (ff-pointer obj) (ff-pointer self) (ff-pointer v)))

      (clos:defmethod length-squared ((obj test) (self test))
        (Test_lengthSquared (ff-pointer obj) (ff-pointer self)))

      (clos:defmethod parallel-component ((obj test) (self test) (unitBasis test))
        (Test_parallelComponent (ff-pointer obj) (ff-pointer self) (ff-pointer unitBasis)))

      (clos:defmethod set-yto-zero ((obj test) (self test))
        (Test_setYtoZero (ff-pointer obj) (ff-pointer self)))

I agree that the CFFI C++ module needs lot more work. But I hope it
provides a starting point, on which you can base your work of importing
C++ libraries to Lisp.

If you have any questions, suggestions, patches, etc., related to CFFI
module feel free to contact us on the SWIG mailing list, and also please
add a "[CFFI]" tag in the subject line.

Inserting user code into generated files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is often necessary to `include user-defined
code <SWIG.html#SWIG_nn40>`__ into the automatically generated interface
files. For example, when building a C++ interface, example_wrap.cxx will
likely not compile unless you add a ``#include "header.h"`` directive.
This can be done using the SWIG ``%insert(section) %{ ...code... %}``
directive:

.. container:: code

   ::

      %module example

      %{
      #include "header.h"
      %}

      %include "header.h"

      int fact(int n);

Additional sections have been added for inserting into the generated
lisp interface file:

-  ``lisphead`` - inserts before type declarations
-  ``swiglisp`` - inserts after type declarations according to where it
   appears in the .i file

Note that the block ``%{ ... %}`` is effectively a shortcut for
``%insert("header") %{ ... %}``.

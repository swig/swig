SWIG and PHP
===============

In this chapter, we discuss SWIG's support of PHP. SWIG currently
supports generating wrappers for PHP7. Support for PHP5 was removed in
SWIG 4.0.0 and support for PHP4 was removed in SWIG 1.3.37.

Currently any PHP7 release should work.

In order to use this module, you will need to have a copy of the PHP
include files to compile the SWIG generated files. If you installed PHP
from a binary package, you may need to install a "php-dev" or
"php-devel" package for these to be installed. You can find out where
these files are by running ``php-config --includes``. To use the built
PHP module you will need either the php binary or the Apache php module.
If you want to build your extension into php directly, you will need the
complete PHP source tree available.

Generating PHP Extensions
------------------------------

To build a PHP extension, run swig using the ``-php7`` option as follows
(``-php`` is also supported and currently is an alias for ``-php7`` but
prior to SWIG 4.0.0 it was an alias for ``-php5``):

.. container:: code

   ::

      swig -php7 example.i

This will produce 3 files example_wrap.c, php_example.h and example.php.
The first file, ``example_wrap.c`` contains all of the C code needed to
build a PHP extension. The second file, ``php_example.h`` contains the
header information needed if you wish to statically link the extension
into the php interpreter. The third file, ``example.php`` can be
included by PHP scripts. It attempts to dynamically load the extension
and contains extra php code specified in the interface file. If wrapping
C++ code with PHP classes, it will also contain PHP class wrappers.

SWIG can generate PHP extensions from C++ libraries as well when given
the ``-c++`` option. The support for C++ is discussed in more detail in
`section 27.2.6 <#Php_nn2_6>`__. The generated C++ wrapper will be
called example_wrap.cxx. You can specify a different extension for the
C++ wrapper using ``-cppext`` - e.g. if you want example_wrap.cc use
``-cppext cc``.

The usual (and recommended) way is to build the extension as a separate
dynamically loaded module (which is supported by all modern operating
systems).

It is also possible to rebuild PHP from source so that your module is
statically linked into the php executable/library. This is a lot more
work, and also requires a full rebuild of PHP to update your module, and
it doesn't play nicely with package system. We don't recommend this
approach, or provide explicit support for it.

Building a loadable extension
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To build your module as a dynamically loadable extension, use
compilation commands like these (if you aren't using GCC, the commands
will be different, and there may be some variation between platforms -
these commands should at least work for Linux though):

.. container:: code

   ::

              gcc `php-config --includes` -fpic -c example_wrap.c example.c
              gcc -shared example_wrap.o example.o -o example.so

Using PHP Extensions
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To test the extension from a PHP script, you first need to tell PHP to
load it. To do this, add a line like this to the ``[PHP]`` section of
``php.ini``:

.. container:: code

   ::

              extension=/path/to/modulename.so

If the module is in PHP's default extension directory, you can omit the
path.

For some SAPIs (for example, the CLI SAPI) you can instead use the `dl()
function <https://www.php.net/manual/en/function.dl.php>`__ to load an
extension at run time, by adding a line like this to the start of each
PHP script which uses your extension:

.. container:: code

   ::

              dl("/path/to/modulename.so"); // Load the module

But note that ``dl()`` isn't supported when running PHP through a
webserver - you'll need to use ``extension`` in ``php.ini`` as described
above.

The PHP module which SWIG generates will also attempt to do the ``dl()``
call for you if the extension isn't already loaded:

.. container:: code

   ::

              include("example.php");

This PHP module also defines the PHP classes for the wrapped API, so
you'll almost certainly want to include it anyway.

Basic PHP interface
------------------------

It is important to understand that PHP uses a single global namespace
into which all symbols from extension modules are loaded. It is quite
possible for names of symbols in one extension module to clash with
other symbols unless care is taken to ``%rename`` them. At present SWIG
doesn't have support for generating wrappers which make use of PHP's
namespace feature.

Constants
~~~~~~~~~~~~~~~~

These work in much the same way as in C/C++. Constants can be defined by
using either the normal C pre-processor declarations, or the
``%constant`` SWIG directive. These will then be available from your PHP
script as a PHP constant, (i.e. no dollar sign is needed to access
them.) For example, with a swig interface file like this,

.. container:: code

   ::

      %module example

      #define PI 3.14159

      %constant int E  = 2.71828

you can access the constants in your PHP script like this,

.. container:: code

   ::

      include("example.php");

      echo "PI = " . PI . "\n";

      echo "E = " . E . "\n";

There's one peculiarity of how constants work in PHP which it is useful
to note (this is not specific to SWIG though) - if you try to use an
undeclared constant, PHP will emit a warning (or a notice in PHP 7.1 and
earlier) and then expand the constant to a string version of the
constant's name. Unfortunately it is easy to miss the warning message if
you're using PHP in a webserver as it will probably end up in error.log
or similar. Apparently this will throw an Error in a future version of
PHP, but until then it's something to be aware of.

For example,

.. container:: code

   ::

      %module example

      #define EASY_TO_MISPELL 0

accessed incorrectly in PHP,

.. container:: code

   ::

      include("example.php");

      if(EASY_TO_MISPEL) {
        ...
      } else {
        ...
      }

The mis-spelled constant will become the string 'EASY_TO_MISPEL', which
is treated as true by the if test, when the value of the intended
constant would be treated as false!

Global Variables
~~~~~~~~~~~~~~~~~~~~~~~

Because PHP does not provide a mechanism to intercept access and
assignment of global variables, global variables are supported through
the use of automatically generated accessor functions.

.. container:: code

   ::

      %module example;

      %inline %{
        double seki = 2;
        void print_seki() {
          zend_printf("seki is now %f\n", seki);
        }
      %}

is accessed as follows:

.. container:: code

   ::

      include("example.php");
      print seki_get();
      seki_set( seki_get() * 2); # The C variable is now 4.
      print seki_get();

SWIG supports global variables of all C datatypes including pointers and
complex objects. Additional types can be supported by using the
``varinit`` typemap.

SWIG honors the ``%immutable`` modifier by not generating code for the
``_set`` method. This provides read-only access to the variable from the
php script. Attempting to access the ``_set`` method will result in a
php fatal error because the function is undefined.

At this time SWIG does not support custom accessor methods.

Functions
~~~~~~~~~~~~~~~~

C functions are converted into PHP functions. Default/optional arguments
are also allowed. An interface file like this :

.. container:: code

   ::

      %module example
      int foo(int a);
      double bar(double, double b = 3.0);
      ...

Will be accessed in PHP like this :

.. container:: code

   ::

      include("example.php");
      $a = foo(2);
      $b = bar(3.5, -1.5);
      $c = bar(3.5);  # Use default argument for 2nd parameter

Overloading
~~~~~~~~~~~~~~~~~~

Although PHP does not support overloading functions natively, swig will
generate dispatch functions which will use ``%typecheck`` typemaps to
allow overloading. This dispatch function's operation and precedence is
described in `Overloaded functions and
methods <SWIGPlus.html#SWIGPlus_overloaded_methods>`__.

Pointers and References
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Pointers to C/C++ objects are represented as PHP resources, rather like
MySQL connection handles.

There are multiple ways to wrap pointers to simple types. Given the
following C method:

.. container:: code

   ::

        void add( int *in1, int *in2, int *result);

One can include **cpointer.i** to generate PHP wrappers to ``int *``.

.. container:: code

   ::

      %module example
      %include "cpointer.i"
      %pointer_functions(int, intp)

      void add( int *in1, int *in2, int *result);

This will result in the following usage in PHP:

.. container:: code

   ::

      <?php

      include("example.php");

      $in1=copy_intp(3);
      $in2=copy_intp(5);
      $result=new_intp();

      add( $in1, $in2, $result );

      echo "The sum " . intp_value($in1) . " + " . intp_value($in2) . " = " . intp_value( $result) . "\n";
      ?>

An alternative would be to use the include **typemaps.i** which defines
named typemaps for INPUT, OUTPUT and INOUT variables. One needs to
either ``%apply`` the appropriate typemap or adjust the parameter names
as appropriate.

.. container:: code

   ::

      %module example
      %include "typemaps.i"

      void add( int *INPUT, int *INPUT, int *OUTPUT);

This will result in the following usage in PHP:

.. container:: code

   ::

      <?php

      include("example.php");

      $in1 = 3;
      $in2 = 5;
      $result= add($in1, $in2);  # Note using variables for the input is unnecessary.

      echo "The sum $in1 + $in2 = $result\n";
      ?>

Because PHP has a native concept of reference, it may seem more natural
to the PHP developer to use references to pass pointers. To enable this,
one needs to include **phppointers.i** which defines the named typemap
REF.

In case you write your own typemaps, SWIG supports an attribute called
``byref``: if you set that, then SWIG will make sure that the generated
wrapper function will want the input parameter as a reference.

.. container:: code

   ::

      %module example
      %include "phppointers.i"

      void add( int *REF, int *REF, int *REF);

This will result in the following usage in PHP:

.. container:: code

   ::

      <?php

      include("example.php");

      $in1 = 3;
      $in2 = 5;
      $result = 0;
      add($in1, $in2, $result);

      echo "The sum $in1 + $in2 = $result\n";
      ?>

It is important to note that a php variable which is NULL when passed by
reference would end up passing a NULL pointer into the function. In PHP,
an unassigned variable (i.e. where the first reference to the variable
is not an assignment) is NULL. In the above example, if any of the three
variables had not been assigned, a NULL pointer would have been passed
into ``add``. Depending on the implementation of the function, this may
or may not be a good thing.

We chose to allow passing NULL pointers into functions because that is
sometimes required in C libraries. A NULL pointer can be created in PHP
in a number of ways: by using ``unset`` on an existing variable, or
assigning ``NULL`` to a variable.

Structures and C++ classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG defaults to wrapping C++ structs and classes with PHP classes -
this is done by generating a PHP wrapper script which defines proxy
classes which calls a set of flat functions which actually wrap the C++
class. You can disable this wrapper layer by passing the command-line
option "-noproxy" in which case you'll just get the flat functions.

This interface file

.. container:: code

   ::

      %module vector

      class Vector {
      public:
        double x, y, z;
        Vector();
        ~Vector();
        double magnitude();
      };

      struct Complex {
       double re, im;
      };

Would be used in the following way from PHP:

.. container:: code

   ::

      <?php
        require "vector.php";

        $v = new Vector();
        $v->x = 3;
        $v->y = 4;
        $v->z = 5;

        echo "Magnitude of ($v->x, $v->y, $v->z) = " . $v->magnitude() . "\n";

        $v = NULL;   # destructor called.

        $c = new Complex();

        $c->re = 0;
        $c->im = 0;

        # $c destructor called when $c goes out of scope.
      ?>

Member variables and methods are accessed using the ``->`` operator.

Using -noproxy
^^^^^^^^^^^^^^^^^^^^^^^

The ``-noproxy`` option flattens the object structure and generates
collections of named functions (these are the functions which the PHP
class wrappers call). The above example results in the following PHP
functions:

.. container:: code

   ::

      new_Vector();
      Vector_x_set($obj, $d);
      Vector_x_get($obj);
      Vector_y_set($obj, $d);
      Vector_y_get($obj);
      Vector_z_set($obj, $d);
      Vector_z_get($obj);
      Vector_magnitude($obj);
      new_Complex();
      Complex_re_set($obj, $d);
      Complex_re_get($obj);
      Complex_im_set($obj, $d);
      Complex_im_get($obj);

Constructors and Destructors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The constructor is called when ``new Object()`` (or ``new_Object()`` if
using ``-noproxy``) is used to create an instance of the object. If
multiple constructors are defined for an object, function overloading
will be used to determine which constructor to execute.

Because PHP uses reference counting to manage resources, simple
assignment of one variable to another such as:

.. container:: code

   ::

      $ref = $v;

causes the symbol ``$ref`` to refer to the same underlying object as
``$v``. This does not result in a call to the C++ copy constructor or
copy assignment operator.

One can force execution of the copy constructor by using:

.. container:: code

   ::

      $o_copy = new Object($o);

Destructors are automatically called when all variables referencing the
instance are reassigned or go out of scope. The destructor is not
available to be called manually. To force a destructor to be called the
programmer can either reassign the variable or call ``unset($v)``

Static Member Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Static member variables in C++ are not wrapped as such in PHP as it does
not appear to be possible to intercept accesses to such variables.
Therefore, static member variables are wrapped using a class function
with the same name, which returns the current value of the class
variable. For example

.. container:: code

   ::

      %module example

      class Ko {
        static int threats;
      };

would be accessed in PHP as,

.. container:: code

   ::

      include("example.php");

      echo "There have now been " . Ko::threats() . " threats\n";

To set the static member variable, pass the value as the argument to the
class function, e.g.

.. container:: code

   ::


      Ko::threats(10);

      echo "There have now been " . Ko::threats() . " threats\n";

Static Member Functions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Static member functions are supported in PHP using the
``class::function()`` syntax. For example

.. container:: code

   ::

      %module example
      class Ko {
        static void threats();
      };

would be executed in PHP as,

.. container:: code

   ::

      include("example.php");
      Ko::threats();

Specifying Implemented Interfaces
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

PHP supports the concept of abstract interfaces which a class can
implement. Since SWIG 3.0.3, you can tell SWIG that a wrapped class (for
example ``MyIterator``) implements the ``Iterator`` interface like so:

.. container:: code

   ::

      %typemap("phpinterfaces") MyIterator "Iterator";

If there are multiple interfaces, just list them separated by commas.

PHP Pragmas, Startup and Shutdown code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To place PHP code in the generated "example.php" file one can use the
**code** pragma. The code is inserted after loading the shared object.

.. container:: code

   ::

      %module example
      %pragma(php) code="
      # This code is inserted into example.php
      echo \"example.php execution\\n\";
      "

Results in the following in "example.php"

.. container:: code

   ::

      # This code is inserted into example.php
      echo "example.php execution\n";

The **version** pragma can be used to add version to generated PHP
extension module. The version is inserted in the zend_module_entry
block.

.. container:: code

   ::

      %module example
      %pragma(php) version="1.5"

The **include** pragma is a short cut to add include statements to the
example.php file.

.. container:: code

   ::

      %module example
      %pragma(php) code="
      include \"include.php\";
      "
      %pragma(php) include="include.php"   // equivalent.

The **phpinfo** pragma inserts code in the ``PHP_MINFO_FUNCTION`` which
is called from PHP's phpinfo() function.

.. container:: code

   ::

      %module example;
      %pragma(php) phpinfo="
        zend_printf("An example of PHP support through SWIG\n");
        php_info_print_table_start();
        php_info_print_table_header(2, \"Directive\", \"Value\");
        php_info_print_table_row(2, \"Example support\", \"enabled\");
        php_info_print_table_end();
      "

To insert code into the ``PHP_MINIT_FUNCTION``, one can use either
``%init`` or ``%minit``.

.. container:: code

   ::

      %module example;
      %init {
        zend_printf("Inserted into PHP_MINIT_FUNCTION\n");
      }
      %minit {
        zend_printf("Inserted into PHP_MINIT_FUNCTION\n");
      }

To insert code into the ``PHP_MSHUTDOWN_FUNCTION``, one can use either
``%shutdown`` or ``%mshutdown``.

.. container:: code

   ::

      %module example;
      %mshutdown {
        zend_printf("Inserted into PHP_MSHUTDOWN_FUNCTION\n");
      }

The ``%rinit`` and ``%rshutdown`` statements are very similar but insert
code into the request init (PHP_RINIT_FUNCTION) and request shutdown
(PHP_RSHUTDOWN_FUNCTION) code respectively.

Cross language polymorphism
--------------------------------

Proxy classes provide a more natural, object-oriented way to access
extension classes. As described above, each proxy instance has an
associated C++ instance, and method calls to the proxy are passed to the
C++ instance transparently via C wrapper functions.

This arrangement is asymmetric in the sense that no corresponding
mechanism exists to pass method calls down the inheritance chain from
C++ to PHP. In particular, if a C++ class has been extended in PHP (by
extending the proxy class), these extensions will not be visible from
C++ code. Virtual method calls from C++ are thus not able access the
lowest implementation in the inheritance chain.

Changes have been made to SWIG 1.3.18 to address this problem and make
the relationship between C++ classes and proxy classes more symmetric.
To achieve this goal, new classes called directors are introduced at the
bottom of the C++ inheritance chain. Support for generating PHP classes
has been added in SWIG 1.3.40. The job of the directors is to route
method calls correctly, either to C++ implementations higher in the
inheritance chain or to PHP implementations lower in the inheritance
chain. The upshot is that C++ classes can be extended in PHP and from
C++ these extensions look exactly like native C++ classes. Neither C++
code nor PHP code needs to know where a particular method is
implemented: the combination of proxy classes, director classes, and C
wrapper functions takes care of all the cross-language method routing
transparently.

Enabling directors
~~~~~~~~~~~~~~~~~~~~~~~~~

The director feature is disabled by default. To use directors you must
make two changes to the interface file. First, add the "directors"
option to the %module directive, like this:

.. container:: code

   ::

      %module(directors="1") modulename

Without this option no director code will be generated. Second, you must
use the %feature("director") directive to tell SWIG which classes and
methods should get directors. The %feature directive can be applied
globally, to specific classes, and to specific methods, like this:

.. container:: code

   ::

      // generate directors for all classes that have virtual methods
      %feature("director");         

      // generate directors for the virtual methods in class Foo
      %feature("director") Foo;      

You can use the %feature("nodirector") directive to turn off directors
for specific classes or methods. So for example,

.. container:: code

   ::

      %feature("director") Foo;
      %feature("nodirector") Foo::bar;

will generate directors for the virtual methods of class Foo except
bar().

Directors can also be generated implicitly through inheritance. In the
following, class Bar will get a director class that handles the methods
one() and two() (but not three()):

.. container:: code

   ::

      %feature("director") Foo;
      class Foo {
      public:
        Foo(int foo);
        virtual void one();
        virtual void two();
      };

      class Bar: public Foo {
      public:
        virtual void three();
      };

then at the PHP side you can define

.. container:: targetlang

   ::

      require("mymodule.php");

      class MyFoo extends Foo {
        function one() {
          print "one from php\n";
        }
      }

Director classes
~~~~~~~~~~~~~~~~~~~~~~~

For each class that has directors enabled, SWIG generates a new class
that derives from both the class in question and a special
``Swig::Director`` class. These new classes, referred to as director
classes, can be loosely thought of as the C++ equivalent of the PHP
proxy classes. The director classes store a pointer to their underlying
PHP object. Indeed, this is quite similar to the "_cPtr" and "thisown"
members of the PHP proxy classes.

For simplicity let's ignore the ``Swig::Director`` class and refer to
the original C++ class as the director's base class. By default, a
director class extends all virtual methods in the inheritance chain of
its base class (see the preceding section for how to modify this
behavior). Virtual methods that have a final specifier are
unsurprisingly excluded. Thus the virtual method calls, whether they
originate in C++ or in PHP via proxy classes, eventually end up in at
the implementation in the director class. The job of the director
methods is to route these method calls to the appropriate place in the
inheritance chain. By "appropriate place" we mean the method that would
have been called if the C++ base class and its extensions in PHP were
seamlessly integrated. That seamless integration is exactly what the
director classes provide, transparently skipping over all the messy
extension API glue that binds the two languages together.

In reality, the "appropriate place" is one of only two possibilities:
C++ or PHP. Once this decision is made, the rest is fairly easy. If the
correct implementation is in C++, then the lowest implementation of the
method in the C++ inheritance chain is called explicitly. If the correct
implementation is in PHP, the Zend API is used to call the method of the
underlying PHP object (after which the usual virtual method resolution
in PHP automatically finds the right implementation).

Now how does the director decide which language should handle the method
call? The basic rule is to handle the method in PHP, unless there's a
good reason not to. The reason for this is simple: PHP has the most
"extended" implementation of the method. This assertion is guaranteed,
since at a minimum the PHP proxy class implements the method. If the
method in question has been extended by a class derived from the proxy
class, that extended implementation will execute exactly as it should.
If not, the proxy class will route the method call into a C wrapper
function, expecting that the method will be resolved in C++. The wrapper
will call the virtual method of the C++ instance, and since the director
extends this the call will end up right back in the director method. Now
comes the "good reason not to" part. If the director method were to
blindly call the PHP method again, it would get stuck in an infinite
loop. We avoid this situation by adding special code to the C wrapper
function that tells the director method to not do this. The C wrapper
function compares the called and the declaring class name of the given
method. If these are not the same, then the C wrapper function tells the
director to resolve the method by calling up the C++ inheritance chain,
preventing an infinite loop.

One more point needs to be made about the relationship between director
classes and proxy classes. When a proxy class instance is created in
PHP, SWIG creates an instance of the original C++ class and assigns it
to ``->_cPtr``. This is exactly what happens without directors and is
true even if directors are enabled for the particular class in question.
When a class *derived* from a proxy class is created, however, SWIG then
creates an instance of the corresponding C++ director class. The reason
for this difference is that user-defined subclasses may override or
extend methods of the original class, so the director class is needed to
route calls to these methods correctly. For unmodified proxy classes,
all methods are ultimately implemented in C++ so there is no need for
the extra overhead involved with routing the calls through PHP.

Ownership and object destruction
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Memory management issues are slightly more complicated with directors
than for proxy classes alone. PHP instances hold a pointer to the
associated C++ director object, and the director in turn holds a pointer
back to the PHP object. By default, proxy classes own their C++ director
object and take care of deleting it when they are garbage collected.

This relationship can be reversed by calling the special ``->thisown``
property of the proxy class. After setting this property to ``0``, the
director class no longer destroys the PHP object. Assuming no
outstanding references to the PHP object remain, the PHP object will be
destroyed at the same time. This is a good thing, since directors and
proxies refer to each other and so must be created and destroyed
together. Destroying one without destroying the other will likely cause
your program to segfault.

Here is an example:

.. container:: code

   ::

      class Foo {
      public:
        ...
      };
      class FooContainer {
      public:
        void addFoo(Foo *);
        ...
      };

| 

.. container:: targetlang

   ::

      $c = new FooContainer();
      $a = new Foo();
      $a->thisown = 0;
      $c->addFoo($a);

In this example, we are assuming that FooContainer will take care of
deleting all the Foo pointers it contains at some point.

Exception unrolling
~~~~~~~~~~~~~~~~~~~~~~~~~~

With directors routing method calls to PHP, and proxies routing them to
C++, the handling of exceptions is an important concern. By default, an
exception thrown in PHP code called from C++ causes the PHP interpreter
to flag that an exception is thrown, then return passes to C++ as if the
PHP function had returned ``Null``. Assuming the directorout typemaps
handle this (those SWIG defines by default should) then once control
returns to PHP code again, the PHP exception will actually propagate.

Sometimes this control flow is problematic, and you want to skip any
handling in the C++ code. To achieve this, it is necessary to
temporarily translate the PHP exception into a C++ exception. This can
be achieved using the %feature("director:except") directive. The
following code should suffice in most cases:

.. container:: code

   ::

      %feature("director:except") {
        if ($error == FAILURE) {
          throw Swig::DirectorMethodException();
        }
      }

This code will check the PHP error state after each method call from a
director into PHP, and throw a C++ exception if an error occurred. This
exception can be caught in C++ to implement an error handler. Currently
no information about the PHP error is stored in the
Swig::DirectorMethodException object, but this will likely change in the
future.

It may be the case that a method call originates in PHP, travels up to
C++ through a proxy class, and then back into PHP via a director method.
If an exception occurs in PHP at this point, it would be nice for that
exception to find its way back to the original caller. This can be done
by combining a normal %exception directive with the ``director:except``
handler shown above. Here is an example of a suitable exception handler:

.. container:: code

   ::

      %exception {
        try { $action }
        catch (Swig::DirectorException &e) { SWIG_fail; }
      }

The class Swig::DirectorException used in this example is actually a
base class of Swig::DirectorMethodException, so it will trap this
exception. Because the PHP error state is still set when
Swig::DirectorMethodException is thrown, PHP will register the exception
as soon as the C wrapper function returns.

Overhead and code bloat
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enabling directors for a class will generate a new director method for
every virtual method in the class' inheritance chain. This alone can
generate a lot of code bloat for large hierarchies. Method arguments
that require complex conversions to and from target language types can
result in large director methods. For this reason it is recommended that
you selectively enable directors only for specific classes that are
likely to be extended in PHP and used in C++.

Compared to classes that do not use directors, the call routing in the
director methods does add some overhead. In particular, at least one
dynamic cast and one extra function call occurs per method call from
PHP. Relative to the speed of PHP execution this is probably completely
negligible. For worst case routing, a method call that ultimately
resolves in C++ may take one extra detour through PHP in order to ensure
that the method does not have an extended PHP implementation. This could
result in a noticeable overhead in some cases.

Although directors make it natural to mix native C++ objects with PHP
objects (as director objects) via a common base class pointer, one
should be aware of the obvious fact that method calls to PHP objects
will be much slower than calls to C++ objects. This situation can be
optimized by selectively enabling director methods (using the %feature
directive) for only those methods that are likely to be extended in PHP.

Typemaps
~~~~~~~~~~~~~~~

Typemaps for input and output of most of the basic types from director
classes have been written. These are roughly the reverse of the usual
input and output typemaps used by the wrapper code. The typemap
operation names are 'directorin', 'directorout', and 'directorargout'.
The director code does not currently use any of the other kinds of
typemaps. It is not clear at this point which kinds are appropriate and
need to be supported.

Miscellaneous
~~~~~~~~~~~~~~~~~~~~

Director typemaps for STL classes are mostly in place, and hence you
should be able to use std::string, etc., as you would any other type.

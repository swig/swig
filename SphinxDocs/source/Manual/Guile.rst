SWIG and Guile
=================

This section details guile-specific support in SWIG.

Supported Guile Versions
-----------------------------

SWIG works with Guile versions 1.8.x and 2.0.x. Support for version
1.6.x has been dropped. The last version of SWIG that still works with
Guile version 1.6.x is SWIG 2.0.9.

Note that starting with guile 2.0, the guile sources can be compiled for
improved performance. This is currently not tested with swig so your
mileage may vary. To be safe set environment variable GUILE_AUTO_COMPILE
to 0 when using swig generated guile code.

Meaning of "Module"
------------------------

There are three different concepts of "module" involved, defined
separately for SWIG, Guile, and Libtool. To avoid horrible confusion, we
explicitly prefix the context, e.g., "guile-module".

Old GH Guile API
---------------------

Guile 1.8 and older could be interfaced using two different api's, the
SCM or the GH API. The GH interface to guile is deprecated. Read more
about why in the `Guile
manual <http://www.gnu.org/software/guile/docs/docs-1.6/guile-ref/GH.html#GH>`__.

Support for the guile GH wrapper code generation has been dropped from
SWIG. The last version of SWIG that can still generate guile GH wrapper
code is 2.0.9. Please use that version if you really need the GH wrapper
code.

Linkage
------------

Guile support is complicated by a lack of user community cohesiveness,
which manifests in multiple shared-library usage conventions. A set of
policies implementing a usage convention is called a **linkage**.

Simple Linkage
~~~~~~~~~~~~~~~~~~~~~

The default linkage is the simplest; nothing special is done. In this
case the function ``SWIG_init()`` is exported. Simple linkage can be
used in several ways:

-  **Embedded Guile, no modules.** You want to embed a Guile interpreter
   into your program; all bindings made by SWIG shall show up in the
   root module. Then call ``SWIG_init()`` in the ``inner_main()``
   function. See the "simple" and "matrix" examples under
   ``Examples/guile``.

-  **Dynamic module mix-in.** You want to create a Guile module using
   ``define-module``, containing both Scheme code and bindings made by
   SWIG; you want to load the SWIG modules as shared libraries into
   Guile.

   .. container:: targetlang

      ::

         (define-module (my module))
         (define my-so (dynamic-link "./libexample.so"))
         (dynamic-call "SWIG_init" my-so) ; make SWIG bindings
         ;; Scheme definitions can go here

   Newer Guile versions provide a shorthand for ``dynamic-link`` and
   ``dynamic-call``:

   .. container:: targetlang

      ::

         (load-extension "./libexample.so" "SWIG_init")

   A more portable approach would be to drop the shared library
   extension:

   .. container:: targetlang

      ::

         (load-extension "./libexample" "SWIG_init")

   You need to explicitly export those bindings made by SWIG that you
   want to import into other modules:

   .. container:: targetlang

      ::

         (export foo bar)

   In this example, the procedures ``foo`` and ``bar`` would be
   exported. Alternatively, you can export all bindings with the
   following module-system hack:

   .. container:: targetlang

      ::

         (module-map (lambda (sym var)
                       (module-export! (current-module) (list sym)))
                     (current-module))

   SWIG can also generate this Scheme stub (from ``define-module`` up to
   ``export``) semi-automagically if you pass it the command-line
   argument ``-scmstub``. The code will be exported in a file called
   ``module.scm`` in the directory specified by ``-outdir`` or the
   current directory if ``-outdir`` is not specified. Since SWIG doesn't
   know how to load your extension module (with ``dynamic-link`` or
   ``load-extension``), you need to supply this information by including
   a directive like this in the interface file:

   .. container:: code

      ::

         %scheme %{ (load-extension "./libexample.so" "SWIG_init") %}

   (The ``%scheme`` directive allows to insert arbitrary Scheme code
   into the generated file ``module.scm``; it is placed between the
   ``define-module`` form and the ``export`` form.)

If you want to include several SWIG modules, you would need to rename
``SWIG_init`` via a preprocessor define to avoid symbol clashes. For
this case, however, passive linkage is available.

Passive Linkage
~~~~~~~~~~~~~~~~~~~~~~

Passive linkage is just like simple linkage, but it generates an
initialization function whose name is derived from the module and
package name (see below).

You should use passive linkage rather than simple linkage when you are
using multiple modules.

Native Guile Module Linkage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG can also generate wrapper code that does all the Guile module
declarations on its own if you pass it the ``-Linkage module``
command-line option.

The module name is set with the ``-package`` and ``-module``
command-line options. Suppose you want to define a module with name
``(my lib foo)``; then you would have to pass the options
``-package my/lib -module foo``. Note that the last part of the name can
also be set via the SWIG directive ``%module``.

You can use this linkage in several ways:

-  **Embedded Guile with SWIG modules.** You want to embed a Guile
   interpreter into your program; the SWIG bindings shall be put into
   different modules. Simply call the function
   ``scm_init_my_modules_foo_module`` in the ``inner_main()`` function.
-  **Dynamic Guile modules.** You want to load the SWIG modules as
   shared libraries into Guile; all bindings are automatically put in
   newly created Guile modules.

   .. container:: targetlang

      ::

         (define my-so (dynamic-link "./libfoo"))
         ;; create new module and put bindings there:
         (dynamic-call "scm_init_my_modules_foo_module" my-so) 

   Newer Guile versions have a shorthand procedure for this:

   .. container:: targetlang

      ::

         (load-extension "./libfoo.so" "scm_init_my_modules_foo_module")

Old Auto-Loading Guile Module Linkage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Guile used to support an autoloading facility for object-code modules.
This support has been marked deprecated in version 1.4.1 and is going to
disappear sooner or later. SWIG still supports building auto-loading
modules if you pass it the ``-Linkage ltdlmod`` command-line option.

Auto-loading worked like this: Suppose a module with name
``(my lib foo)`` is required and not loaded yet. Guile will then search
all directories in its search path for a Scheme file
``my/modules/foo.scm`` or a shared library ``my/modules/libfoo.so`` (or
``my/modules/libfoo.la``; see the GNU libtool documentation). If a
shared library is found that contains the symbol
``scm_init_my_modules_foo_module``, the library is loaded, and the
function at that symbol is called with no arguments in order to
initialize the module.

When invoked with the ``-Linkage ltdlmod`` command-line option, SWIG
generates an exported module initialization function with an appropriate
name.

Hobbit4D Linkage
~~~~~~~~~~~~~~~~~~~~~~~

The only other linkage supported at this time creates shared object
libraries suitable for use by hobbit's ``(hobbit4d link)`` guile module.
This is called the "hobbit" linkage, and requires also using the
"-package" command line option to set the part of the module name before
the last symbol. For example, both command lines:

.. container:: shell

   ::

      swig -guile -package my/lib foo.i
      swig -guile -package my/lib -module foo foo.i

would create module ``(my lib foo)`` (assuming in the first case foo.i
declares the module to be "foo"). The installed files are
my/lib/libfoo.so.X.Y.Z and friends. This scheme is still very
experimental; the (hobbit4d link) conventions are not well understood.

Underscore Folding
-----------------------

Underscores are converted to dashes in identifiers. Guile support may
grow an option to inhibit this folding in the future, but no one has
complained so far.

You can use the SWIG directives ``%name`` and ``%rename`` to specify the
Guile name of the wrapped functions and variables (see CHANGES).

Typemaps
-------------

The Guile module handles all types via typemaps. This information is
read from ``Lib/guile/typemaps.i``. Some non-standard typemap
substitutions are supported:

-  ``$descriptor`` expands to a type descriptor for use with the
   ``SWIG_NewPointerObj()`` and ``SWIG_ConvertPtr`` functions.
-  For pointer types, ``$*descriptor`` expands to a descriptor for the
   direct base type (i.e., one pointer is stripped), whereas
   ``$basedescriptor`` expands to a descriptor for the base type (i.e.,
   all pointers are stripped).

A function returning ``void`` (more precisely, a function whose ``out``
typemap returns ``SCM_UNSPECIFIED``) is treated as returning no values.
In ``argout`` typemaps, one can use the macro ``GUILE_APPEND_RESULT`` in
order to append a value to the list of function return values.

Multiple values can be passed up to Scheme in one of three ways:

-  *Multiple values as lists.* By default, if more than one value is to
   be returned, a list of the values is created and returned; to switch
   back to this behavior, use

   .. container:: code

      ::

         %values_as_list;

-  *Multiple values as vectors.* By issuing

   .. container:: code

      ::

         %values_as_vector;

   vectors instead of lists will be used.

-  *Multiple values for multiple-value continuations.* **This is the
   most elegant way.** By issuing

   .. container:: code

      ::

         %multiple_values;

   multiple values are passed to the multiple-value continuation, as
   created by ``call-with-values`` or the convenience macro ``receive``.
   The latter is available if you issue ``(use-modules (srfi srfi-8))``.
   Assuming that your ``divide`` function wants to return two values, a
   quotient and a remainder, you can write:

   .. container:: targetlang

      ::

         (receive (quotient remainder)
             (divide 35 17)
           body...)

   In ``body``, the first result of ``divide`` will be bound to the
   variable ``quotient``, and the second result to ``remainder``.

See also the "multivalue" example.

Constants are exported as a function that returns the value. The
%feature("constasvar") can be applied to any constant, immutable
variable, or enum. Instead of exporting the constant as a function that
must be called, the constant will appear as a scheme variable. See
`Features and the %feature
directive <Customization.html#Customization_features>`__ for info on how
to apply the %feature.

Representation of pointers as smobs
----------------------------------------

For pointer types, SWIG uses Guile smobs. SWIG smobs print like this:
``#<swig struct xyzzy * 0x1234affe>`` Two of them are ``equal?`` if and
only if they have the same type and value.

To construct a Scheme object from a C pointer, the wrapper code calls
the function ``SWIG_NewPointerObj()``, passing a pointer to a struct
representing the pointer type. The type index to store in the upper half
of the CAR is read from this struct. To get the pointer represented by a
smob, the wrapper code calls the function ``SWIG_ConvertPtr()``, passing
a pointer to a struct representing the expected pointer type. See also
`The run-time type
checker <Typemaps.html#Typemaps_runtime_type_checker>`__. If the Scheme
object passed was not a SWIG smob representing a compatible pointer, a
``wrong-type-arg`` exception is raised.

Smobs
~~~~~~~~~~~~

In earlier versions of SWIG, C pointers were represented as Scheme
strings containing a hexadecimal rendering of the pointer value and a
mangled type name. As Guile allows registering user types, so-called
"smobs" (small objects), a much cleaner representation has been
implemented now. The details will be discussed in the following.

The whole type system, when it is first initialized, creates two smobs
named "swig" and "collected_swig". The swig smob is used for non-garbage
collected smobs, while the collected_swig smob is used as described
below. Each smob has the same format, which is a double cell created by
SCM_NEWSMOB2() The first word of data is the pointer to the object and
the second word of data is the swig_type_info \* structure describing
this type. If a generated GOOPS module has been loaded, smobs will be
wrapped by the corresponding GOOPS class.

Garbage Collection
~~~~~~~~~~~~~~~~~~~~~~~~~

Garbage collection is a feature of Guile since version 1.6. As SWIG now
requires Guile > 1.8, it is automatically included. Garbage collection
works like this. Every swig_type_info structure stores in its clientdata
field a pointer to the destructor for this type. The destructor is the
generated wrapper around the delete function. So swig still exports a
wrapper for the destructor, it just does not call scm_c_define_gsubr()
for the wrapped delete function. So the only way to delete an object is
from the garbage collector, since the delete function is not available
to scripts. How swig determines if a type should be garbage collected is
exactly like described in `Object ownership and
%newobject <Customization.html#Customization_ownership>`__ in the SWIG
manual. All typemaps use an $owner var, and the guile module replaces
$owner with 0 or 1 depending on feature:new.

Native Guile pointers
--------------------------

In addition to SWIG smob pointers, `Guile's native pointer
type <https://www.gnu.org/software/guile/manual/html_node/Foreign-Pointers.html>`__
are accepted as arguments to wrapped SWIG functions. This can be useful
for passing `pointers to bytevector
data <https://www.gnu.org/software/guile/manual/html_node/Void-Pointers-and-Byte-Access.html#>`__
to wrapped functions.

Exception Handling
-----------------------

SWIG code calls ``scm_error`` on exception, using the following mapping:

.. container:: code

   ::

            MAP(SWIG_MemoryError,     "swig-memory-error");
            MAP(SWIG_IOError,         "swig-io-error");
            MAP(SWIG_RuntimeError,    "swig-runtime-error");
            MAP(SWIG_IndexError,      "swig-index-error");
            MAP(SWIG_TypeError,       "swig-type-error");
            MAP(SWIG_DivisionByZero,  "swig-division-by-zero");
            MAP(SWIG_OverflowError,   "swig-overflow-error");
            MAP(SWIG_SyntaxError,     "swig-syntax-error");
            MAP(SWIG_ValueError,      "swig-value-error");
            MAP(SWIG_SystemError,     "swig-system-error");

The default when not specified here is to use "swig-error". See
Lib/exception.i for details.

Procedure documentation
-----------------------------

If invoked with the command-line option ``-procdoc file``, SWIG creates
documentation strings for the generated wrapper functions, describing
the procedure signature and return value, and writes them to ``file``.

SWIG can generate documentation strings in three formats, which are
selected via the command-line option ``-procdocformat format``:

-  ``guile-1.4`` (default): Generates a format suitable for Guile 1.4.
-  ``plain``: Generates a format suitable for Guile 1.4.1 and later.
-  ``texinfo``: Generates texinfo source, which must be run through
   texinfo in order to get a format suitable for Guile 1.4.1 and later.

You need to register the generated documentation file with Guile like
this:

.. container:: targetlang

   ::

      (use-modules (ice-9 documentation))
      (set! documentation-files 
            (cons "file" documentation-files))

Documentation strings can be configured using the Guile-specific typemap
argument ``doc``. See ``Lib/guile/typemaps.i`` for details.

Procedures with setters
-----------------------------

For global variables, SWIG creates a single wrapper procedure
``(variable :optional value)``, which is used for both getting and
setting the value. For struct members, SWIG creates two wrapper
procedures ``(struct-member-get pointer)`` and
``(struct-member-set pointer value)``.

If invoked with the command-line option ``-emit-setters``
(*recommended*), SWIG will additionally create procedures with setters.
For global variables, the procedure-with-setter ``variable`` is created,
so you can use ``(variable)`` to get the value and
``(set! (variable) value)`` to set it. For struct members, the
procedure-with-setter ``struct-member`` is created, so you can use
``(struct-member pointer)`` to get the value and
``(set! (struct-member pointer) value)`` to set it.

If invoked with the command-line option ``-only-setters``, SWIG will
*only* create procedures with setters, i.e., for struct members, the
procedures ``(struct-member-get pointer)`` and
``(struct-member-set pointer value)`` are *not* generated.

GOOPS Proxy Classes
-------------------------

SWIG can also generate classes and generic functions for use with
Guile's Object-Oriented Programming System (GOOPS). GOOPS is a
sophisticated object system in the spirit of the Common Lisp Object
System (CLOS).

To enable GOOPS support, pass the ``-proxy`` argument to swig. This will
export the GOOPS wrapper definitions into the ``module.scm`` file in the
directory specified by -outdir or the current directory. GOOPS support
requires either passive or module linkage.

The generated file will contain definitions of GOOPS classes mimicking
the C++ class hierarchy.

Enabling GOOPS support implies ``-emit-setters``.

If ``-emit-slot-accessors`` is also passed as an argument, then the
generated file will contain accessor methods for all the slots in the
classes and for global variables. The input class

.. container:: code

   ::

        class Foo {
          public:
            Foo(int i) : a(i) {}
            int a;
            int getMultBy(int i) { return a * i; }
            Foo getFooMultBy(int i) { return Foo(a * i); }
        }; 
        Foo getFooPlus(int i) { return Foo(a + i); }

will produce (if ``-emit-slot-accessors`` is not passed as a parameter)

.. container:: targetlang

   ::

      (define-class <Foo> (<swig>)
        (a #:allocation #:swig-virtual 
           #:slot-ref primitive:Foo-a-get 
           #:slot-set! primitive:Foo-a-set)
        #:metaclass <swig-metaclass>
        #:new-function primitive:new-Foo
      )
      (define-method (getMultBy (swig_smob <Foo>) i)
        (primitive:Foo-getMultBy  (slot-ref swig_smob 'smob) i))
      (define-method (getFooMultBy (swig_smob <Foo>) i)
        (make <Foo> #:init-smob (primitive:Foo-getFooMultBy  (slot-ref swig_smob 'smob) i)))

      (define-method (getFooPlus i)
        (make <Foo> #:init-smob (primitive:getFooPlus i)))

      (export <Foo> getMultBy getFooMultBy getFooPlus )

and will produce (if ``-emit-slot-accessors`` is passed as a parameter)

.. container:: targetlang

   ::

      (define-class <Foo> (<swig>)
        (a #:allocation #:swig-virtual 
           #:slot-ref primitive:Foo-a-get 
           #:slot-set! primitive:Foo-a-set 
           #:accessor a)
        #:metaclass <swig-metaclass>
        #:new-function primitive:new-Foo
      )
      (define-method (getMultBy (swig_smob <Foo>) i)
        (primitive:Foo-getMultBy  (slot-ref swig_smob 'smob) i))
      (define-method (getFooMultBy (swig_smob <Foo>) i)
        (make <Foo> #:init-smob (primitive:Foo-getFooMultBy  (slot-ref swig_smob 'smob) i)))

      (define-method (getFooPlus i)
        (make <Foo> #:init-smob (primitive:getFooPlus i)))

      (export <Foo> a getMultBy getFooMultBy getFooPlus )

which can then be used by this code

.. container:: targetlang

   ::

      ;; not using getters and setters
      (define foo (make <Foo> #:args '(45)))
      (slot-ref foo 'a)
      (slot-set! foo 'a 3)
      (getMultBy foo 4)
      (define foo2 (getFooMultBy foo 7))
      (slot-ref foo 'a)
      (slot-ref (getFooPlus foo 4) 'a)

      ;; using getters and setters
      (define foo (make <Foo> #:args '(45)))
      (a foo)
      (set! (a foo) 5)
      (getMultBy foo 4)
      (a (getFooMultBy foo 7))

Notice that constructor arguments are passed as a list after the
``#:args`` keyword. Hopefully in the future the following will be valid
``(make <Foo> #:a 5 #:b 4)``

Also note that the order the declarations occur in the .i file make a
difference. For example,

.. container:: code

   ::

      %module test

      %{ #include "foo.h" %}

      %inline %{
        int someFunc(Foo &a) {
          ...
        }
      %}

      %include "foo.h"

This is a valid SWIG file it will work as you think it will for
primitive support, but the generated GOOPS file will be broken. Since
the ``someFunc`` definition is parsed by SWIG before all the
declarations in foo.h, the generated GOOPS file will contain the
definition of ``someFunc()`` before the definition of <Foo>. The
generated GOOPS file would look like

.. container:: targetlang

   ::

      ;;...

      (define-method (someFunc (swig_smob <Foo>))
        (primitive:someFunc (slot-ref swig_smob 'smob)))

      ;;...

      (define-class <Foo> (<swig>)
        ;;...
      )

      ;;...

Notice that <Foo> is used before it is defined. The fix is to just put
the ``%import "foo.h"`` before the ``%inline`` block.

Naming Issues
~~~~~~~~~~~~~~~~~~~~~

As you can see in the example above, there are potential naming
conflicts. The default exported accessor for the ``Foo::a`` variable is
named ``a``. The name of the wrapper global function is ``getFooPlus``.
If the ``-useclassprefix`` option is passed to swig, the name of all
accessors and member functions will be prepended with the class name. So
the accessor will be called ``Foo-a`` and the member functions will be
called ``Foo-getMultBy``. Also, if the ``-goopsprefix goops:`` argument
is passed to swig, every identifier will be prefixed by ``goops:``

Two guile-modules are created by SWIG. The first module contains the
primitive definitions of all the wrapped functions and variables, and is
located either in the \_wrap.cxx file (with ``-Linkage module``) or in
the scmstub file (if ``-Linkage passive -scmstub``). The name of this
guile-module is the swig-module name (given on the command line with the
-module argument or with the %module directive) concatenated with the
string "-primitive". For example, if ``%module Test`` is set in the swig
interface file, the name of the guile-module in the scmstub or
``-Linkage module`` will be ``Test-primitive``. Also, the scmstub file
will be named ``Test-primitive.scm``. The string "primitive" can be
changed by the ``-primsuffix`` swig argument. So the same interface,
with the ``-primsuffix base`` will produce a module called
``Test-base``. The second generated guile-module contains all the GOOPS
class definitions and is located in a file named *module*.scm in the
directory specified with -outdir or the current directory. The name of
this guile-module is the name of the swig-module (given on the command
line or with the ``%module`` directive). In the previous example, the
GOOPS definitions will be in a file named Test.scm.

Because of the naming conflicts, you can't in general use both the
``-primitive`` and the GOOPS guile-modules at the same time. To do this,
you need to rename the exported symbols from one or both guile-modules.
For example,

.. container:: targetlang

   ::

      (use-modules ((Test-primitive) #:renamer (symbol-prefix-proc 'primitive:)))
      (use-modules ((Test) #:renamer (symbol-prefix-proc 'goops:)))

Linking
~~~~~~~~~~~~~~~

The guile-modules generated above all need to be linked together. GOOPS
support requires either passive or module linkage. The exported GOOPS
guile-module will be the name of the swig-module and should be located
in a file called *Module*.scm. This should be installed on the autoload
path for guile, so that ``(use-modules (Package Module))`` will load
everything needed. Thus, the top of the GOOPS guile-module will contain
code to load everything needed by the interface (the shared library, the
scmstub module, etc.). The ``%goops`` directive inserts arbitrary code
into the generated GOOPS guile-module, and should be used to load the
dependent libraries.

This breaks up into three cases

-  **Passive Linkage without -scmstub**: Note that this linkage style
   has the potential for naming conflicts, since the primitive exported
   function and variable names are not wrapped in a guile-module and
   might conflict with names from the GOOPS guile-module (see above).
   Pass the -goopsprefix argument to solve this problem. If the
   ``-exportprimitive`` option is passed to SWIG the ``(export ...)``
   code that would be exported into the scmstub file is exported at the
   bottom of the generated GOOPS guile-module. The ``%goops`` directive
   should contain code to load the shared library.

   .. container:: code

      ::

         %goops %{ (load-extension "./libfoo.so" "scm_init_my_modules_foo_module") %}

   Produces the following code at the top of the generated GOOPS
   guile-module (with the ``-package my/modules -module foo`` command
   line arguments)

   .. container:: targetlang

      ::

         (define-module (my modules foo))

         ;; %goops directive goes here
         (load-extension "./libfoo.so" "scm_init_my_modules_foo_module") 

         (use-modules (oop goops) (Swig common))

-  **Passive Linkage with -scmstub**: Here, the name of the scmstub file
   should be ``Module-primitive.scm`` (with *primitive* replaced with
   whatever is given with the ``-primsuffix`` argument. The code to load
   the shared library should be located in the ``%scheme`` directive,
   which will then be added to the scmstub file. SWIG will automatically
   generate the line ``(use-modules (Package Module-primitive))`` into
   the GOOPS guile-module. So if *Module-primitive.scm* is on the
   autoload path for guile, the ``%goops`` directive can be empty.
   Otherwise, the ``%goops`` directive should contain whatever code is
   needed to load the *Module-primitive.scm* file into guile.

   .. container:: targetlang

      ::

         %scheme %{ (load-extension "./libfoo.so" "scm_init_my_modules_foo_module") %}
         // only include the following definition if (my modules foo) cannot
         // be loaded automatically
         %goops %{ 
           (primitive-load "/path/to/foo-primitive.scm") 
           (primitive-load "/path/to/Swig/common.scm")
         %}

   Produces the following code at the top of the generated GOOPS
   guile-module

   .. container:: targetlang

      ::

         (define-module (my modules foo))

         ;; %goops directive goes here (if any)
         (primitive-load "/path/to/foo-primitive.scm")
         (primitive-load "/path/to/Swig/common.scm")

         (use-modules (oop goops) (Swig common))
         (use-modules ((my modules foo-primitive) :renamer (symbol-prefix-proc
                                                                'primitive:)))

-  **Module Linkage**: This is very similar to passive linkage with a
   scmstub file. SWIG will also automatically generate the line
   ``(use-modules  (Package Module-primitive))`` into the GOOPS
   guile-module. Again the ``%goops`` directive should contain whatever
   code is needed to get that module loaded into guile.

   .. container:: code

      ::

         %goops %{ (load-extension "./libfoo.so" "scm_init_my_modules_foo_module") %}

   Produces the following code at the top of the generated GOOPS
   guile-module

   .. container:: targetlang

      ::

         (define-module (my modules foo))

         ;; %goops directive goes here (if any)
         (load-extension "./libfoo.so" "scm_init_my_modules_foo_module") 

         (use-modules (oop goops) (Swig common))
         (use-modules ((my modules foo-primitive) :renamer (symbol-prefix-proc
                                                                  'primitive:)))

**(Swig common)**: The generated GOOPS guile-module also imports
definitions from the (Swig common) guile-module. This module is included
with SWIG and should be installed by SWIG into the autoload path for
guile (based on the configure script and whatever arguments are passed).
If it is not, then the ``%goops`` directive also needs to contain code
to load the ``common.scm`` file into guile. Also note that if you are
trying to install the generated wrappers on a computer without SWIG
installed, you will need to include the common.swg file along with the
install.

**Multiple Modules**: Type dependencies between modules is supported.
For example, if ``mod1`` includes definitions of some classes, and
``mod2`` includes some classes derived from classes in ``mod1``, the
generated GOOPS file for ``mod2`` will declare the correct superclasses.
The only problem is that since ``mod2`` uses symbols from ``mod1``, the
``mod2`` GOOPS file must include a ``(use-modules (mod2))``. Currently,
SWIG does not automatically export this line; it must be included in the
``%goops`` directive of ``mod2``. Maybe in the future SWIG can detect
dependencies and export this line. (how do other language modules handle
this problem?)

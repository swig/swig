SWIG and D
=============

Introduction
-----------------

From the `D Programming Language <http://www.digitalmars.com/d/>`__ web
site: *D is a systems programming language. Its focus is on combining
the power and high performance of C and C++ with the programmer
productivity of modern languages like Ruby and Python. [...] The D
language is statically typed and compiles directly to machine code.* As
such, it is not very surprising that D is able to directly `interface
with C
libraries <http://www.digitalmars.com/d/1.0/interfaceToC.html>`__. Why
would a SWIG module for D be needed then in the first place?

Well, besides the obvious downside that the C header files have to be
manually converted to D modules for this to work, there is one major
inconvenience with this approach: D code usually is on a higher
abstraction level than C, and many of the features that make D
interesting are simply not available when dealing with C libraries,
requiring you e.g. to manually convert strings between pointers to
``\0``-terminated char arrays and D char arrays, making the algorithms
from the D2 standard library unusable with C arrays and data structures,
and so on.

While these issues can be worked around relatively easy by hand-coding a
thin wrapper layer around the C library in question, there is another
issue where writing wrapper code per hand is not feasible: C++
libraries. D did not support interfacing to C++ in version 1 at all, and
even if ``extern(C++)`` has been added to D2, the support is still very
limited, and a custom wrapper layer is still required in many cases.

To help addressing these issues, the SWIG C# module has been forked to
support D. Is has evolved quite a lot since then, but there are still
many similarities, so if you do not find what you are looking for on
this page, it might be worth having a look at the chapter on
`C# <CSharp.html#CSharp>`__ (and also on `Java <Java.html#Java>`__,
since the C# module was in turn forked from it).

Command line invocation
----------------------------

To activate the D module, pass the ``-d`` option to SWIG at the command
line. The same standard command line options as with any other language
module are available, plus the following D specific ones:

``-d2``
   By default, SWIG generates code for D1/Tango. Use the ``-d2`` flag to
   target D2/Phobos instead.

``-splitproxy``
   By default, SWIG generates two D modules: the *proxy* module, named
   like the source module (either specified via the ``%module``
   directive or via the ``module`` command line option), which contains
   all the proxy classes, functions, enums, etc., and the *intermediary*
   module (named like the proxy module, but suffixed with ``_im``),
   which contains all the ``extern(C)`` function declarations and other
   private parts only used internally by the proxy module.

   If the split proxy mode is enabled by passing this option at the
   command line, all proxy classes and enums are emitted to their own D
   module instead. The main proxy module only contains free functions
   and constants in this case.

``-package <pkg>``
   By default, the proxy D modules and the intermediary D module are
   written to the root package. Using this option, you can specify
   another target package instead.

``-wrapperlibrary <wl>``
   The code SWIG generates to dynamically load the C/C++ wrapper layer
   looks for a library called ``$module_wrap`` by default. With this
   option, you can override the name of the file the wrapper code loads
   at runtime (the ``lib`` prefix and the suffix for shared libraries
   are appended automatically, depending on the OS).

   This might especially be useful if you want to invoke SWIG several
   times on separate modules, but compile the resulting code into a
   single shared library.

Typemaps
-------------

C# <-> D name comparison
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you already know the SWIG C# module, you might find the following
name comparison table useful:

.. container:: diagram

   ::

       ctype                  <->  ctype
       imtype                 <->  imtype
       cstype                 <->  dtype
       csin                   <->  din
       csout                  <->  dout
       csdirectorin           <->  ddirectorin
       csdirectorout          <->  ddirectorout
       csinterfaces           <->  dinterfaces
       csinterfaces_derived   <->  dinterfaces_derived
       csbase                 <->  dbase
       csclassmodifiers       <->  dclassmodifiers
       cscode                 <->  dcode
       csimports              <->  dimports
       csbody                 <->  dbody
       csfinalize             <->  ddestructor
       csdisposing            <->  ddispose
       csdisposing_derived    <->  ddispose_derived

ctype, imtype, dtype
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mapping of types between the C/C++ library, the C/C++ library wrapper
exposing the C functions, the D wrapper module importing these functions
and the D proxy code.

The ``ctype`` typemap is used to determine the types to use in the C
wrapper functions. The types from the ``imtype`` typemap are used in the
extern(C) declarations of these functions in the intermediary D module.
The ``dtype`` typemap contains the D types used in the D proxy
module/class.

.. _D_ddirectorinout:

in, out, directorin, directorout
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used for converting between the types for C/C++ and D when generating
the code for the wrapper functions (on the C++ side).

The code from the ``in`` typemap is used to convert arguments to the C
wrapper function to the type used in the wrapped code
(``ctype``->original C++ type), the ``out`` typemap is utilized to
convert values from the wrapped code to wrapper function return types
(original C++ type->\ ``ctype``).

The ``directorin`` typemap is used to convert parameters to the type
used in the D director callback function, its return value is processed
by ``directorout`` (see below).

din, dout, ddirectorin, ddirectorout
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Typemaps for code generation in D proxy and type wrapper classes.

The ``din`` typemap is used for converting function parameter types from
the type used in the proxy module or class to the type used in the
intermediary D module (the `$dinput <D.html#D_dinput>`__ macro is
replaced). To inject further parameter processing code before or after
the call to the intermediary layer, the ``pre``, ``post`` and
``terminator`` attributes can be used (please refer to the `C# date
marshalling example <CSharp.html#CSharp_date_marshalling>`__ for more
information on these).

The ``dout`` typemap is used for converting function return values from
the return type used in the intermediary D module to the type returned
by the proxy function. The ``$excode`` special variable in ``dout``
typemaps is replaced by the ``excode`` typemap attribute code if the
method can throw any exceptions from unmanaged code, otherwise by
nothing (the `$imcall and $owner <D_imcall_>`_ macros are
replaced).

The code from the ``ddirectorin`` and ``ddirectorout`` typemaps is used
for conversion in director callback functions. Arguments are converted
to the type used in the proxy class method they are calling by using the
code from ``ddirectorin``, the proxy class method return value is
converted to the type the C++ code expects via the ``ddirectorout``
typemap (the ```$dcall`` and ``$winput`` <D.html#D_dpcall>`__ macros are
replaced).

The full chain of type conversions when a director callback is invoked
looks like this:

.. container:: diagram

   ::

            type              CPPClass::method(type a)
              ↑                       ↓
         <directorout>          <directorin>
              ↑                       ↓
            ctype             methodCallback(ctype a)           C++
       :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            imtype            methodCallback(imtype a)           D
              ↑                       ↓
        <ddirectorout>          <ddirectorin>
              ↑                       ↓
            dtype             DClass.method(dtype a)

typecheck typemaps
~~~~~~~~~~~~~~~~~~~~~~~~~

Because, unlike many scripting languages supported by SWIG, D does not
need any dynamic dispatch helper to access an overloaded function, the
purpose of these is merely to issue a warning for overloaded C++
functions that cannot be overloaded in D (as more than one C++ type maps
to a single D type).

Code injection typemaps
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These typemaps are used for generating the skeleton of proxy classes for
C++ types.

By overriding ``dbase``, ``dinterfaces`` or ``dinterfaces_derived``, the
inheritance chain of the generated proxy class for a type can be
modified. ``dclassmodifiers`` allows you to add any custom modifiers
around the class keyword.

Using ``dcode`` and ``dimports``, you can specify additional D code
which will be emitted into the class body respectively the imports
section of the D module the class is written to.

``dconstructor``, ``ddestructor``, ``ddispose`` and ``ddispose_derived``
are used to generate the class constructor, destructor and ``dispose()``
method, respectively. The auxiliary code for handling the pointer to the
C++ object is stored in ``dbody`` and ``dbody_derived``. You can
override them for specific types.

Code can also be injected into the D proxy class using ``%proxycode``.

Special variable macros
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The standard SWIG special variables are available for use within
typemaps as described in the `Typemaps
documentation <Typemaps.html#Typemaps>`__, for example ``$1``,
``$input``, ``$result`` etc.

When generating D wrappers, a few additional macros are available:

``$dclassname`` (C#: ``$csclassname``)
   This special variable works similar to
   ```$n_type`` <Typemaps.html#Typemaps_special_variables>`__ in that it
   returns the name of a type - it expands to the D proxy class name of
   the type being wrapped. If the type does not have an associated proxy
   class, it expands to the type wrapper class name, for example,
   ``SWIGTYPE_p_p_SomeCppClass`` is generated when wrapping
   ``SomeCppClass **``.

   There are two other variants available, ``$&dclassname`` and
   ``$*dclassname``. The former adds a level of indirection, while the
   latter removes one. For instance, when wrapping ``Foo **``,
   ``$*dclassname`` would be replaced by the proxy class name
   corresponding to ``Foo *``.

``$dclazzname`` (C#: ``$csclazzname``)
   This special variable expands the fully qualified C++ class into the
   package name, if used by the `nspace
   feature <SWIGPlus.html#the-nspace-feature-for-namespaces>`__, and the proxy class name,
   mangled for use as a function name. For example,
   ``Namespace1::Namespace2::Klass`` is expanded into
   ``Namespace1_Namespace2_Klass_``.

   This special variable might be useful for calling certain functions
   in the wrapper layer (e.g. upcast wrappers) which are mangled like
   this.

``$null``
   In code inserted into the generated C/C++ wrapper functions, this
   variable is replaced by either ``0`` or nothing at all, depending on
   whether the function has a return value or not. It can be used to
   bail out early e.g. in case of errors (``return $null;``).

``$dinput`` (C#: ``$csinput``)
   This variable is used in ``din`` typemaps and is replaced by the
   expression which is to be passed to C/C++.

   For example, this input

   .. container:: code

      ::

         %typemap(din) SomeClass * "SomeClass.getCPointer($dinput)"

         %inline %{
           class SomeClass {};
           void foo(SomeClass *arg);
         %}

   leads to the following D proxy code being generated:

   .. container:: targetlang

      ::

         void foo(SomeClass arg) {
           example_im.foo(SomeClass.getCPointer(arg));
         }

.. _D_imcall:

``$imcall`` and ``$owner`` (C#: ``$imcall``)
   These variables are used in ``dout`` typemaps. ``$imcall`` contains
   the call to the intermediary module which provides the value to be
   used, and ``$owner`` signals if the caller is responsible for
   managing the object lifetime (that is, if the called method is a
   constructor or has been marked via ``%newobject``).

   Consider the following example:

   .. container:: code

      ::

         %typemap(dout) SomeClass * {
           return new SomeClass($imcall, $owner);
         }

         %inline %{
           class SomeClass;
           SomeClass *foo();

           %newobject bar();
           SomeClass *bar();
         %}

   The code generated for ``foo()`` and ``bar()`` looks like this:

   .. container:: targetlang

      ::

         SomeClass foo() {
           return new SomeClass(example_im.foo(), false);
         }

         SomeClass bar() {
           return new SomeClass(example_im.bar(), true);
         }

``$dcall`` and ``$winput`` (C#: ``$cscall``, ``$iminput``)
   These variables are used in the director-specific typemaps
   :ref: `ddirectorin<D_ddirectorinout>` and
   :ref: `ddirectorout<D_ddirectorinout>`. They are more or less
   the reverse of the ``$imcall`` and ``$dinput`` macros: ``$dcall``
   contains the invocation of the D proxy method of which the return
   value is to be passed back to C++, ``$winput`` contains the parameter
   value from C++.

``$excode``
   This variable is used in ``dout`` and ``dconstructor`` typemaps and
   is filled with the contents of the ``excode`` typemap attribute if an
   exception could be thrown from the C++ side. See the `C#
   documentation <CSharp.html#CSharp_exceptions>`__ for details.

``$dbaseclass``
   Currently for internal use only, it contains the D name of the C++
   base class (if any) inside proxy classes.

``$directorconnect``
   This macro is only valid inside the ``dconstructor`` typemap and
   contains the value of the ``dconstructor`` typemap attribute if the
   currently wrapped class has directors enabled.

   This is how the default ``dconstructor`` typemap looks like (you
   usually do not want to specify a custom one):

   .. container:: code

      ::

         %typemap(dconstructor, excode=SWIGEXCODE,
                  directorconnect="\n  swigDirectorConnect();") SWIGTYPE {
           this($imcall, true);$excode$directorconnect
         }

``$importtype(SomeDType)``
   This macro is used in the ``dimports`` typemap if a dependency on
   another D type generated by SWIG is added by a custom typemap.

   Consider the following code snippet:

   .. container:: code

      ::

         %typemap(dinterfaces) SomeClass "AnInterface, AnotherInterface";

   This causes SWIG to add ``AnInterface`` and ``AnotherInterface`` to
   the base class list of ``SomeClass``:

   .. container:: targetlang

      ::

         class SomeClass : AnInterface, AnotherInterface {
           ...
         }

   For this to work, ``AnInterface`` and ``AnotherInterface`` have to be
   in scope. If SWIG is not in split proxy mode, this is already the
   case, but if it is, they have to be added to the import list via the
   ``dimports`` typemap. Additionally, the import statement depends on
   the package SWIG is configured to emit the modules to.

   The ``$importtype`` macro helps you to elegantly solve this problem:

   .. container:: code

      ::

         %typemap(dimports) RemoteMpe %{
         $importtype(AnInterface)
         $importtype(AnotherInterface)
         %}

   If SWIG is in split proxy mode, it expands to an ``import`` statement
   for the specified type, to nothing if not.

``$module``
   Expands to the name of the main proxy D module.

``$imdmodule``
   Contains the fully qualified name of the intermediary D module.

D and %feature
-------------------

The D module defines a number of directives which modify the `SWIG
features <Customization.html#Customization_features>`__ set globally or
for a specific declaration:

``%dmanifestconst`` and ``%dconstvalue(value)``
   Out of the box, SWIG generates accessor methods for C ``#defines``
   and C++ constants. The ``%dmanifestconst`` directive enables wrapping
   these constants as D manifest constants (``const`` in D1, ``enum`` in
   D2).

   For this to work, the C/C++ code for the constant value must directly
   compile as D code, though. If this is not the case, you can manually
   override the expression written to the D proxy module using the
   ``%dconstvalue`` directive, passing the new value as parameter.

   For ``enum``\ s, again ``%dconstvalue`` can be used to override the
   value of an enum item if the initializer should not compile in D.

``%dmethodmodifiers``
   This directive can be used to override the modifiers for a proxy
   function. For instance, you could make a ``public`` C++ member
   function ``private`` in D like this:

   .. container:: code

      ::

         %dmethodmodifiers A::foo "private";

         %inline %{
         struct A {
           void foo();
         };
         %}

Pragmas
------------

There are a few SWIG pragmas specific to the D module, which you can use
to influence the D code SWIG generates:

``%pragma(d) imdmodulecode``
   The passed text (D code) is copied verbatim to the intermediary D
   module. For example, it can be (and is, internally) used to emit
   additional private helper code for the use by proxy typemaps.

``%pragma(d) imdmoduleimports``
   Additional code to be emitted to the imports section of the
   intermediary D module (the `$importtype <D.html#D_importtype>`__
   macro can be used here). You probably want to use this in conjunction
   with the ``imdmodulecode`` pragma.

``%pragma(d) proxydmodulecode``
   Just like ``proxydmodulecode``, the argument is copied to the proxy D
   module (if SWIG is in `split proxy mode <D.html#D_splitproxy>`__
   and/or the ``nspace`` feature is used, it is emitted to the main
   proxy D module only).

``%pragma(d) globalproxyimports``
   The D module currently does not support specifying dependencies on
   external modules (e.g. from the standard library) for the D typemaps.
   To add the import statements to the proxy modules (resp. to *all*
   proxy modules if in split proxy mode), you can use the
   ``globalproxyimports`` directive.

   For example:

   .. container:: code

      ::

         %typemap(din) char[] "($dinput ? tango.stdc.stringz.toStringz($dinput) : null)"
         %pragma(d) globalproxyimports = "static import tango.stdc.stringz;";

``%pragma(d) wrapperloadercode``
   The D code for loading the wrapper library (it is copied to the
   intermediary D module). The ``$wrapperloaderbindcode`` variable is
   replaced by the list of commands for binding the functions from the
   wrapper library to the symbols in the intermediary D module.

   Each time this pragma is specified, the previous value is
   overwritten.

``%pragma(d) wrapperloaderbindcommand``
   The D command to use for binding the wrapper functions from the C/C++
   library to the symbols in the intermediary D module. The
   ``$function`` variable contains the name of the D function in the
   wrap module, the ``$symbol`` variable is replaced by the name of the
   symbol in the library.

   Each time this pragma is specified, the previous value is
   overwritten.

D Exceptions
-----------------

Out of the box, C++ exceptions are fundamentally incompatible to their
equivalent in the D world and cannot simply be propagated to a calling D
method. There is, however, an easy way to solve this problem: Just catch
the exception in the C/C++ wrapper layer, pass the contents to D, and
make the wrapper code rethrow the exception in the D world.

The implementation details of this are a bit crude, but the SWIG D
module automatically takes care of this, as long as it is able to detect
that an exception could potentially be thrown (e.g. because the C++
method has a ``throw(...)`` exception specification).

As this feature is implemented in exactly the same way it is for C#,
please see the `C# documentation <CSharp.html#CSharp_exceptions>`__ for
a more detailed explanation.

D Directors
----------------

When the directors feature is activated, SWIG generates extra code on
both the C++ and the D side to enable cross-language polymorphism.
Essentially, this means that if you subclass a proxy class in D, C++
code can access any overridden virtual methods just as if you created a
derived class in C++.

There is no D specific documentation yet, but the way the feature is
implemented is very similar to how it is done in
`Java <Java.html#Java_directors>`__ and
`C# <CSharp.html#CSharp_directors>`__.

Other features
-------------------

Extended namespace support (nspace)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, SWIG flattens all C++ namespaces into a single target
language namespace, but as for Java and C#, the
`nspace <SWIGPlus.html#SWIGPlus_nspace>`__ feature is supported for
D. If it is active, C++ namespaces are mapped to D packages/modules.
Note, however, that like for the other languages, *free* variables and
functions are not supported yet; currently, they are all allows written
to the main proxy D module.

Native pointer support
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Contrary to many of the scripting languages supported by SWIG, D fully
supports C-style pointers. The D module thus includes a custom mechanism
to wrap C pointers directly as D pointers where applicable, that is, if
the type that is pointed to is represented the same in C and D (on the
bit-level), dubbed a *primitive type* below.

Central to this custom pointer handling scheme are two typemap
attributes: the ``cprimitive`` attribute on the ``dtype`` typemap and
the ``nativepointer`` attribute on all the typemaps which influence the
D side of the code (``dtype``, ``din``, ``dout``, ...). When a D typemap
is looked up, the following happens behind the scenes:

First, the matching typemap is determined by the usual typemap lookup
rules. Then, it is checked if the result has the ``nativepointer``
attribute set. If it is present, it means that its value should replace
the typemap value *if and only if* the actual type the typemap is looked
up for is a primitive type, a pointer to a primitive type (through an
arbitrary level of indirections), or a function pointer with only
primitive types in its signature.

To determine if a type should be considered primitive, the
``cprimitive`` attribute on its ``dtype`` attribute is used. For
example, the ``dtype`` typemap for ``float`` has ``cprimitive="1"``, so
the code from the ``nativepointer`` attribute is taken into account e.g.
for ``float **`` or the function pointer ``float (*)(float *)``.

Operator overloading
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The D module comes with basic operator overloading support for both D1
and D2. There are, however, a few limitations arising from conceptual
differences between C++ and D:

The first key difference is that C++ supports free functions as
operators (along with argument-dependent lookup), while D requires
operators to be member functions of the class they are operating on.
SWIG can only automatically generate wrapping code for member function
operators; if you want to use operators defined as free functions in D,
you need to handle them manually.

Another set of differences between C++ and D concerns individual
operators. For example, there are quite a few operators which are
overloadable in C++, but not in D, for example ``&&`` and ``||``, but
also ``!``, and prefix increment/decrement operators in
`D1 <http://www.digitalmars.com/d/1.0/operatoroverloading.html>`__ resp.
their postfix pendants in
`D2 <http://www.digitalmars.com/d/2.0/operatoroverloading.html>`__.

There are also some cases where the operators can be translated to D,
but the differences in the implementation details are big enough that a
rather involved scheme would be required for automatic wrapping them,
which has not been implemented yet. This affects, for example, the array
subscript operator, ``[]``, in combination with assignments - while
``operator []`` in C++ simply returns a reference which is then written
to, D resorts to a separate ``opIndexAssign`` method -, or implicit
casting (which was introduced in D2 via ``alias this``). Despite the
lack of automatic support, manually handling these cases should be
perfectly possible.

Running the test-suite
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As with any other language, the SWIG test-suite can be built for D using
the ``*-d-test-suite`` targets of the top-level Makefile. By default, D1
is targeted, to build it with D2, use the optional ``D_VERSION``
variable, e.g. ``make check-d-test-suite D_VERSION=2``.

Note: If you want to use GDC on Linux or another platform which requires
you to link ``libdl`` for dynamically loading the shared library, you
might have to add ``-ldl`` manually to the ``d_compile`` target in
``Examples/Makefile``, because GDC does not currently honor the
``pragma(lib, ...)`` statement.

D Typemap examples
-----------------------

There are no D-specific typemap examples yet. However, with the above
`name comparison table <D.html#D_typemap_name_comparison>`__, you should
be able to get an idea what can be done by looking at the `corresponding
C# section <CSharp.html#CSharp_typemap_examples>`__.

Work in progress and planned features
-------------------------------------------

There are a couple of features which are not implemented yet, but would
be very useful and might be added in the near future:

-  *Static linking:* Currently, the C wrapper code is compiled into a
   dynamic library, out of which the symbol addresses are looked up at
   runtime by the D part. If statically linking the different languages
   into one binary was supported, a tool-chain capable of performing IPO
   at link time could inline the wrapping code, effectively reducing the
   overhead for simple calls to zero.
-  *C array handling:* Many data structures in some C/C++ libraries
   contain array containing of a pointer to the first element and the
   element count. Currently, one must manually writing wrapper code to
   be able to access these from D. It should be possible to add a set of
   SWIG macros to semi-automatically generate conversion code.

Some generated code might also be a bit rough around the edges,
particularly in the following areas:

-  *Memory management:* Although the currently generated wrapper code
   works fine with regard to the GC for the test-suite, there might be
   issues coming up in real-world multi-threaded usage.
-  *D2 support*: Originally, the module has been developed for the use
   with D1, D2/Phobos support has been added in later. The basic
   features should work equally well for both, but there *could* be
   issues concerning const-correctness etc.

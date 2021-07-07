Working with Modules
=======================

Modules Introduction
-------------------------

Each invocation of SWIG requires a module name to be specified. The
module name is used to name the resulting target language extension
module. Exactly what this means and what the name is used for depends on
the target language, for example the name can define a target language
namespace or merely be a useful name for naming files or helper classes.
Essentially, a module comprises target language wrappers for a chosen
collection of global variables/functions, structs/classes and other
C/C++ types.

The module name can be supplied in one of two ways. The first is to
specify it with the special ``%module`` directive. This directive must
appear at the beginning of the interface file. The general form of this
directive is:

.. container:: code

   ::

      %module(option1="value1", option2="value2", ...) modulename

where the modulename is mandatory and the options add one or more
optional additional features. Typically no options are specified, for
example:

.. container:: code

   ::

      %module mymodule

The second way to specify the module name is with the ``-module``
command line option, for example ``-module mymodule``. If the module
name is supplied on the command line, it overrides the name specified by
the ``%module`` directive.

When first working with SWIG, users commonly start by creating a single
module. That is, you might define a single SWIG interface that wraps
some set of C/C++ code. You then compile all of the generated wrapper
code together and use it. For large applications, however, this approach
is problematic---the size of the generated wrapper code can be rather
large. Moreover, it is probably easier to manage the target language
interface when it is broken up into smaller pieces.

This chapter describes the problem of using SWIG in programs where you
want to create a collection of modules. Each module in the collection is
created via separate invocations of SWIG.

Basics
-----------

The basic usage case with multiple modules is when modules do not have
cross-references (ie. when wrapping multiple independent C APIs). In
that case, swig input files should just work out of the box - you simply
create multiple wrapper .cxx files, link them into your application, and
insert/load each in the scripting language runtime as you would do for
the single module case.

A bit more complex is the case in which modules need to share
information. For example, when one module extends the class of another
by deriving from it:

.. container:: code

   ::

      // File: base.h
      class base {
      public:
        int foo();
      };

 

.. container:: code

   ::

      // File: base_module.i
      %module base_module

      %{
      #include "base.h"
      %}
      %include "base.h"

 

.. container:: code

   ::

      // File: derived_module.i
      %module derived_module

      %import "base_module.i"

      %inline %{
      class derived : public base {
      public:
        int bar();
      };
      %}

To create the wrapper properly, module ``derived_module`` needs to know
about the ``base`` class and that its interface is covered in another
module. The line ``%import "base_module.i"`` lets SWIG know exactly
that. Often the ``.h`` file is passed to ``%import`` instead of the
``.i``, which unfortunately doesn't work for all language modules. For
example, Python requires the name of module that the base class exists
in so that the proxy classes can fully inherit the base class's methods.
Typically you will get a warning when the module name is missing, eg:

.. container:: shell

   ::

      derived_module.i:8: Warning 401: Base class 'base' ignored - unknown module name for base. Either
      import
      the appropriate module interface file or specify the name of the module in the %import directive.

It is sometimes desirable to import the header file rather than the
interface file and overcome the above warning. For example in the case
of the imported interface being quite large, it may be desirable to
simplify matters and just import a small header file of dependent types.
This can be done by specifying the optional ``module`` attribute in the
``%import`` directive. The ``derived_module.i`` file shown above could
be replaced with the following:

.. container:: code

   ::

      // File: derived_module.i
      %module derived_module

      %import(module="base_module") "base.h"

      %inline %{
      class derived : public base {
      public:
        int bar();
      };

Note that "base_module" is the module name and is the same as that
specified in ``%module`` in ``base_module.i`` as well as the ``%import``
in ``derived_module.i``.

Another issue to beware of is that multiple dependent wrappers should
not be linked/loaded in parallel from multiple threads as SWIG provides
no locking - for more on that issue, read on.

The SWIG runtime code
--------------------------

Many of SWIG's target languages generate a set of functions commonly
known as the "SWIG runtime." These functions are primarily related to
the runtime type system which checks pointer types and performs other
tasks such as proper casting of pointer values in C++. As a general
rule, the statically typed target languages, such as Java, use the
language's built in static type checking and have no need for a SWIG
runtime. All the dynamically typed / interpreted languages rely on the
SWIG runtime.

The runtime functions are private to each SWIG-generated module. That
is, the runtime functions are declared with "static" linkage and are
visible only to the wrapper functions defined in that module. The only
problem with this approach is that when more than one SWIG module is
used in the same application, those modules often need to share type
information. This is especially true for C++ programs where SWIG must
collect and share information about inheritance relationships that cross
module boundaries.

To solve the problem of sharing information across modules, a pointer to
the type information is stored in a global variable in the target
language namespace. During module initialization, type information is
loaded into the global data structure of type information from all
modules.

There are a few trade offs with this approach. This type information is
global across all SWIG modules loaded, and can cause type conflicts
between modules that were not designed to work together. To solve this
approach, the SWIG runtime code uses a define SWIG_TYPE_TABLE to provide
a unique type table. This behavior can be enabled when compiling the
generated \_wrap.cxx or \_wrap.c file by adding
-DSWIG_TYPE_TABLE=myprojectname to the command line argument.

Then, only modules compiled with SWIG_TYPE_TABLE set to myprojectname
will share type information. So if your project has three modules, all
three should be compiled with -DSWIG_TYPE_TABLE=myprojectname, and then
these three modules will share type information. But any other project's
types will not interfere or clash with the types in your module.

Another issue relating to the global type table is thread safety. If two
modules try and load at the same time, the type information can become
corrupt. SWIG currently does not provide any locking, and if you use
threads, you must make sure that modules are loaded serially. Be careful
if you use threads and the automatic module loading that some scripting
languages provide. One solution is to load all modules before spawning
any threads, or use SWIG_TYPE_TABLE to separate type tables so they do
not clash with each other.

Lastly, SWIG uses a #define SWIG_RUNTIME_VERSION, located in
Lib/swigrun.swg and near the top of every generated module. This number
gets incremented when the data structures change, so that SWIG modules
generated with different versions can peacefully coexist. So the type
structures are separated by the (SWIG_TYPE_TABLE, SWIG_RUNTIME_VERSION)
pair, where by default SWIG_TYPE_TABLE is empty. Only modules compiled
with the same pair will share type information.

External access to the runtime
-----------------------------------

As described in `The run-time type
checker <Typemaps.html#Typemaps_runtime_type_checker>`__, the functions
``SWIG_TypeQuery``, ``SWIG_NewPointerObj``, and others sometimes need to
be called. Calling these functions from a typemap is supported, since
the typemap code is embedded into the ``_wrap.c`` file, which has those
declarations available. If you need to call the SWIG run-time functions
from another C file, there is one header you need to include. To
generate the header that needs to be included, SWIG can be run in a
different mode via ``-external-runtime`` to generate the run-time
instead of the normal mode of processing an input interface file. For
example:

.. container:: shell

   ::

      $ swig -python -external-runtime <filename>

The filename argument is optional and if it is not passed, then the
default filename will be something like ``swigpyrun.h``, depending on
the language. This header file should be treated like any of the other
\_wrap.c output files, and should be regenerated when the \_wrap files
are. After including this header, your code will be able to call
``SWIG_TypeQuery``, ``SWIG_NewPointerObj``, ``SWIG_ConvertPtr`` and
others. The exact argument parameters for these functions might differ
between language modules; please check the language module chapters for
more information.

Inside this header the functions are declared static and are included
inline into the file, and thus the file does not need to be linked
against any SWIG libraries or code (you might still need to link against
the language libraries like libpython-2.3). Data is shared between this
file and the \_wrap.c files through a global variable in the scripting
language. It is also possible to copy this header file along with the
generated wrapper files into your own package, so that you can
distribute a package that can be compiled without SWIG installed (this
works because the header file is self-contained, and does not need to
link with anything).

This header will also use the -DSWIG_TYPE_TABLE described above, so when
compiling any code which includes the generated header file should
define the SWIG_TYPE_TABLE to be the same as the module whose types you
are trying to access.

A word of caution about static libraries
---------------------------------------------

When working with multiple SWIG modules, you should take care not to use
static libraries. For example, if you have a static library ``libfoo.a``
and you link a collection of SWIG modules with that library, each module
will get its own private copy of the library code inserted into it. This
is very often **NOT** what you want and it can lead to unexpected or
bizarre program behavior. When working with dynamically loadable
modules, you should try to work exclusively with shared libraries.

References
---------------

Due to the complexity of working with shared libraries and multiple
modules, it might be a good idea to consult an outside reference. John
Levine's "Linkers and Loaders" is highly recommended.

Reducing the wrapper file size
-----------------------------------

Using multiple modules with the ``%import`` directive is the most common
approach to modularising large projects. In this way a number of
different wrapper files can be generated, thereby avoiding the
generation of a single large wrapper file. There are a couple of
alternative solutions for reducing the size of a wrapper file through
the use of command line options and features.

| **-fcompact**
| This command line option will compact the size of the wrapper file
  without changing the code generated into the wrapper file. It simply
  removes blank lines and joins lines of code together. This is useful
  for compilers that have a maximum file size that can be handled.

| **-fvirtual**
| This command line option will remove the generation of superfluous
  virtual method wrappers. Consider the following inheritance hierarchy:

.. container:: code

   ::

      struct Base {
        virtual void method();
        ...
      };

      struct Derived : Base {
        virtual void method();
        ...
      };

Normally wrappers are generated for both methods, whereas this command
line option will suppress the generation of a wrapper for
``Derived::method``. Normal polymorphic behaviour remains as
``Derived::method`` will still be called should you have a ``Derived``
instance and call the wrapper for ``Base::method``.

| **%feature("compactdefaultargs")**
| This feature can reduce the number of wrapper methods when wrapping
  methods with default arguments. The section on `default
  arguments <SWIGPlus.html#SWIGPlus_default_args>`__ discusses the
  feature and its limitations.

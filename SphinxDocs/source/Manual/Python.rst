SWIG and Python
==================

**Caution: This chapter is under repair!**

This chapter describes SWIG's support of Python. SWIG is compatible with
all recent Python versions (Python 2.7 and Python >= 3.2). If you still
need to generate bindings which work with older versions of Python,
you'll have to use SWIG 3.0.x.

This chapter covers most SWIG features, but certain low-level details
are covered in less depth than in earlier chapters. At the very least,
make sure you read the "`SWIG Basics <SWIG.html#SWIG>`__" chapter.

Overview
-------------

To build Python extension modules, SWIG uses a layered approach in which
parts of the extension module are defined in C and other parts are
defined in Python. The C layer contains low-level wrappers whereas
Python code is used to define high-level features.

This layered approach recognizes the fact that certain aspects of
extension building are better accomplished in each language (instead of
trying to do everything in C or C++). Furthermore, by generating code in
both languages, you get a lot more flexibility since you can enhance the
extension module with support code in either language.

In describing the Python interface, this chapter starts by covering the
basics of configuration, compiling, and installing Python modules. Next,
the Python interface to common C and C++ programming features is
described. Advanced customization features such as typemaps are then
described followed by a discussion of low-level implementation details.

Preliminaries
------------------

Running SWIG
~~~~~~~~~~~~~~~~~~~

Suppose that you defined a SWIG module such as the following:

.. container:: code

   ::

      /* File: example.i */
      %module example

      %{
      #define SWIG_FILE_WITH_INIT
      #include "example.h"
      %}

      int fact(int n);

The ``#define SWIG_FILE_WITH_INIT`` line inserts a macro that specifies
that the resulting C file should be built as a Python extension,
inserting the module ``init`` code. This ``.i`` file wraps the following
simple C file:

.. container:: code

   ::

      /* File: example.c */

      #include "example.h"

      int fact(int n) {
        if (n < 0) { /* This should probably return an error, but this is simpler */
          return 0;
        }
        if (n == 0) {
          return 1;
        } else {
          /* testing for overflow would be a good idea here */
          return n * fact(n-1);
        }
      }

With the header file:

.. container:: code

   ::

      /* File: example.h */

      int fact(int n);

To build a Python module, run SWIG using the ``-python`` option:

.. container:: shell

   ::

      $ swig -python example.i

If building a C++ extension, add the ``-c++`` option:

.. container:: shell

   ::

      $ swig -c++ -python example.i

This creates two different files; a C/C++ source file ``example_wrap.c``
or ``example_wrap.cxx`` and a Python source file ``example.py``. The
generated C source file contains the low-level wrappers that need to be
compiled and linked with the rest of your C/C++ application to create an
extension module. The Python source file contains high-level support
code. This is the file that you will import to use the module.

The name of the wrapper file is derived from the name of the input file.
For example, if the input file is ``example.i``, the name of the wrapper
file is ``example_wrap.c``. To change this, you can use the ``-o``
option. The name of the Python file is derived from the module name
specified with ``%module``. If the module name is ``example``, then a
file ``example.py`` is created.

The following sections have further practical examples and details on
how you might go about compiling and using the generated files.

Using distutils
~~~~~~~~~~~~~~~~~~~~~~

The preferred approach to building an extension module for Python is to
compile it with distutils, which comes with all recent versions of
Python (`Distutils
Docs <https://docs.python.org/3/library/distutils.html>`__).

Distutils takes care of making sure that your extension is built with
all the correct flags, headers, etc. for the version of Python it is run
with. Distutils will compile your extension into a shared object file or
DLL (``.so`` on Linux, ``.pyd`` on Windows, etc). In addition, distutils
can handle installing your package into site-packages, if that is
desired. A configuration file (conventionally called: ``setup.py``)
describes the extension (and related Python modules). The distutils will
then generate all the right compiler directives to build it for you.

Here is a sample ``setup.py`` file for the above example:

.. container:: code

   ::

      #!/usr/bin/env python

      """
      setup.py file for SWIG example
      """

      from distutils.core import setup, Extension


      example_module = Extension('_example',
                                 sources=['example_wrap.c', 'example.c'],
                                 )

      setup (name = 'example',
             version = '0.1',
             author      = "SWIG Docs",
             description = """Simple swig example from docs""",
             ext_modules = [example_module],
             py_modules = ["example"],
             )

In this example, the line: ``example_module = Extension(....)`` creates
an Extension module object, defining the name as ``_example``, and using
the source code files: ``example_wrap.c``, generated by swig, and
``example.c``, your original c source. The swig (and other Python
extension modules) tradition is for the compiled extension to have the
name of the Python portion, prefixed by an underscore. If the name of
your Python module is "``example.py``", then the name of the
corresponding object file will be"``_example.so``"

The ``setup`` call then sets up distutils to build your package,
defining some meta data, and passing in your extension module object.
Once this is saved as ``setup.py``, you can build your extension with
these commands:

.. container:: shell

   ::

      $ swig -python example.i
      $ python setup.py build_ext --inplace

And a .so, or .pyd or... will be created for you. It will build a
version that matches the Python that you run the command with. Taking
apart the command line:

-  ``python`` -- the version of Python you want to build for
-  ``setup.py`` -- the name of your setup script (it can be called
   anything, but setup.py is the tradition)
-  ``build_ext`` -- telling distutils to build extensions
-  ``--inplace`` -- this tells distutils to put the extension lib in the
   current dir. Otherwise, it will put it inside a build hierarchy, and
   you'd have to move it to use it.

The distutils have many other features, consult the Python distutils
docs for details.

This same approach works on all platforms if the appropriate compiler is
installed. (it can even build extensions to the standard Windows Python
using MingGW)

Hand compiling a dynamic module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While the preferred approach to building an extension module is to use
the distutils, some people like to integrate building extensions with a
larger build system, and thus may wish to compile their modules without
the distutils. To do this, you need to compile your program using
commands like this (shown for Linux):

.. container:: shell

   ::

      $ swig -python example.i
      $ gcc -O2 -fPIC -c example.c
      $ gcc -O2 -fPIC -c example_wrap.c -I/usr/local/include/python2.5
      $ gcc -shared example.o example_wrap.o -o _example.so

The exact commands for doing this vary from platform to platform.
However, SWIG tries to guess the right options when it is installed.
Therefore, you may want to start with one of the examples in the
``SWIG/Examples/python`` directory. If that doesn't work, you will need
to read the man-pages for your compiler and linker to get the right set
of options. You might also check the `SWIG
Wiki <https://github.com/swig/swig/wiki>`__ for additional information.

When linking the module, **the name of the output file has to match the
name of the module prefixed by an underscore**. If the name of your
module is "``example``", then the name of the corresponding object file
should be "``_example.so``" or "``_examplemodule.so``". The name of the
module is specified using the ``%module`` directive or the ``-module``
command line option.

**Compatibility Note:** In SWIG-1.3.13 and earlier releases, module
names did not include the leading underscore. This is because modules
were normally created as C-only extensions without the extra Python
support file (instead, creating Python code was supported as an optional
feature). This has been changed in SWIG-1.3.14 and is consistent with
other Python extension modules. For example, the ``socket`` module
actually consists of two files; ``socket.py`` and ``_socket.so``. Many
other built-in Python modules follow a similar convention.

Static linking
~~~~~~~~~~~~~~~~~~~~~

An alternative approach to dynamic linking is to rebuild the Python
interpreter with your extension module added to it. In the past, this
approach was sometimes necessary due to limitations in dynamic loading
support on certain machines. However, the situation has improved greatly
over the last few years and you should not consider this approach unless
there is really no other option.

The usual procedure for adding a new module to Python involves finding
the Python source, adding an entry to the ``Modules/Setup`` file, and
rebuilding the interpreter using the Python Makefile. However, newer
Python versions have changed the build process. You may need to edit the
'setup.py' file in the Python distribution instead.

In earlier versions of SWIG, the ``embed.i`` library file could be used
to rebuild the interpreter. For example:

.. container:: code

   ::

      %module example

      %inline %{
      extern int fact(int);
      extern int mod(int, int);
      extern double My_variable;
      %}

      %include "embed.i"       // Include code for a static version of Python

The ``embed.i`` library file includes supporting code that contains
everything needed to rebuild Python. To rebuild the interpreter, you
simply do something like this:

.. container:: shell

   ::

      $ swig -python -lembed.i example.i
      $ gcc example.c example_wrap.c \
              -Xlinker -export-dynamic \
              -DHAVE_CONFIG_H -I/usr/include/python2.7 \
              -I/usr/lib/python2.7/config-x86_64-linux-gnu \
              -I/usr/lib/python2.7/config \
              -L/usr/lib/python2.7/config -lpython2.7 -lm -ldl \
              -o mypython

You will need to supply the same libraries that were used to build
Python the first time. This may include system libraries such as
``-lsocket``, ``-lnsl``, and ``-lpthread``. Assuming this actually
works, the new version of Python should be identical to the default
version except that your extension module will be a built-in part of the
interpreter.

**Comment:** In practice, you should probably try to avoid static
linking if possible. Some programmers may be inclined to use static
linking in the interest of getting better performance. However, the
performance gained by static linking tends to be rather minimal in most
situations (and quite frankly not worth the extra hassle in the opinion
of this author).

**Compatibility note:** The ``embed.i`` library file is deprecated and
has not been actively maintained for many years. Even though it appears
to "work" with Python 2.7, no future support is guaranteed. If using
static linking, you might want to rely on a different approach (perhaps
using distutils).

Using your module
~~~~~~~~~~~~~~~~~~~~~~~~

To use your module, simply use the Python ``import`` statement. If all
goes well, you will be able to run this:

.. container:: targetlang

   ::

      $ python
      >>> import example
      >>> example.fact(4)
      24
      >>>

A common error received by first-time users is the following:

.. container:: targetlang

   ::

      >>> import example
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
        File "example.py", line 2, in ?
          import _example
      ImportError: No module named _example

If you get this message, it means that you either forgot to compile the
wrapper code into an extension module or you didn't give the extension
module the right name. Make sure that you compiled the wrappers into a
module called ``_example.so``. And don't forget the leading underscore
(_).

Another possible error is the following:

.. container:: targetlang

   ::

      >>> import example
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      ImportError: dynamic module does not define init function (init_example)
      >>>

This error is almost always caused when a bad name is given to the
shared object file. For example, if you created a file ``example.so``
instead of ``_example.so`` you would get this error. Alternatively, this
error could arise if the name of the module is inconsistent with the
module name supplied with the ``%module`` directive. Double-check the
interface to make sure the module name and the shared object filename
match. Another possible cause of this error is forgetting to link the
SWIG-generated wrapper code with the rest of your application when
creating the extension module.

Another common error is something similar to the following:

.. container:: targetlang

   ::

      Traceback (most recent call last):
        File "example.py", line 3, in ?
          import example
      ImportError: ./_example.so: undefined symbol: fact

This error usually indicates that you forgot to include some object
files or libraries in the linking of the shared library file. Make sure
you compile both the SWIG wrapper file and your original program into a
shared library file. Make sure you pass all of the required libraries to
the linker.

Sometimes unresolved symbols occur because a wrapper has been created
for a function that doesn't actually exist in a library. This usually
occurs when a header file includes a declaration for a function that was
never actually implemented or it was removed from a library without
updating the header file. To fix this, you can either edit the SWIG
input file to remove the offending declaration or you can use the
``%ignore`` directive to ignore the declaration.

Finally, suppose that your extension module is linked with another
library like this:

.. container:: shell

   ::

      $ gcc -shared example.o example_wrap.o -L/home/beazley/projects/lib -lfoo \
            -o _example.so

If the ``foo`` library is compiled as a shared library, you might
encounter the following problem when you try to use your module:

.. container:: targetlang

   ::

      >>> import example
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      ImportError: libfoo.so: cannot open shared object file: No such file or directory
      >>>

This error is generated because the dynamic linker can't locate the
``libfoo.so`` library. When shared libraries are loaded, the system
normally only checks a few standard locations such as ``/usr/lib`` and
``/usr/local/lib``. To fix this problem, there are several things you
can do. First, you can recompile your extension module with extra path
information. For example, on Linux you can do this:

.. container:: shell

   ::

      $ gcc -shared example.o example_wrap.o -L/home/beazley/projects/lib -lfoo \
            -Xlinker -rpath /home/beazley/projects/lib  \
            -o _example.so

Alternatively, you can set the ``LD_LIBRARY_PATH`` environment variable
to include the directory with your shared libraries. If setting
``LD_LIBRARY_PATH``, be aware that setting this variable can introduce a
noticeable performance impact on all other applications that you run. To
set it only for Python, you might want to do this instead:

.. container:: shell

   ::

      $ env LD_LIBRARY_PATH=/home/beazley/projects/lib python

Finally, you can use a command such as ``ldconfig`` (Linux) or ``crle``
(Solaris) to add additional search paths to the default system
configuration (this requires root access and you will need to read the
man pages).

Compilation of C++ extensions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Compilation of C++ extensions has traditionally been a tricky problem.
Since the Python interpreter is written in C, you need to take steps to
make sure C++ is properly initialized and that modules are compiled
correctly. This should be a non-issue if you're using distutils, as it
takes care of all that for you. The following is included for historical
reasons, and in case you need to compile on your own.

On most machines, C++ extension modules should be linked using the C++
compiler. For example:

.. container:: shell

   ::

      $ swig -c++ -python example.i
      $ g++ -O2 -fPIC -c example.cxx
      $ g++ -O2 -fPIC -c example_wrap.cxx -I/usr/local/include/python2.5
      $ g++ -shared example.o example_wrap.o -o _example.so

The -fPIC option tells GCC to generate position-independent code (PIC)
which is required for most architectures (it's not vital on x86, but
still a good idea as it allows code pages from the library to be shared
between processes). Other compilers may need a different option
specified instead of -fPIC.

In addition to this, you may need to include additional library files to
make it work. For example, if you are using the Sun C++ compiler on
Solaris, you often need to add an extra library ``-lCrun`` like this:

.. container:: shell

   ::

      $ swig -c++ -python example.i
      $ CC -c example.cxx
      $ CC -c example_wrap.cxx -I/usr/local/include/python2.5
      $ CC -G example.o example_wrap.o -L/opt/SUNWspro/lib -o _example.so -lCrun

Of course, the extra libraries to use are completely non-portable---you
will probably need to do some experimentation.

Sometimes people have suggested that it is necessary to relink the
Python interpreter using the C++ compiler to make C++ extension modules
work. In the experience of this author, this has never actually appeared
to be necessary. Relinking the interpreter with C++ really only includes
the special run-time libraries described above---as long as you link
your extension modules with these libraries, it should not be necessary
to rebuild Python.

If you aren't entirely sure about the linking of a C++ extension, you
might look at an existing C++ program. On many Unix machines, the
``ldd`` command will list library dependencies. This should give you
some clues about what you might have to include when you link your
extension module. For example:

.. container:: shell

   ::

      $ ldd swig
              libstdc++-libc6.1-1.so.2 => /usr/lib/libstdc++-libc6.1-1.so.2 (0x40019000)
              libm.so.6 => /lib/libm.so.6 (0x4005b000)
              libc.so.6 => /lib/libc.so.6 (0x40077000)
              /lib/ld-linux.so.2 => /lib/ld-linux.so.2 (0x40000000)

As a final complication, a major weakness of C++ is that it does not
define any sort of standard for binary linking of libraries. This means
that C++ code compiled by different compilers will not link together
properly as libraries nor is the memory layout of classes and data
structures implemented in any kind of portable manner. In a monolithic
C++ program, this problem may be unnoticed. However, in Python, it is
possible for different extension modules to be compiled with different
C++ compilers. As long as these modules are self-contained, this
probably won't matter. However, if these modules start sharing data, you
will need to take steps to avoid segmentation faults and other erratic
program behavior. If working with lots of software components, you might
want to investigate using a more formal standard such as COM.

Compiling for 64-bit platforms
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On platforms that support 64-bit applications (Solaris, Irix, etc.),
special care is required when building extension modules. On these
machines, 64-bit applications are compiled and linked using a different
set of compiler/linker options. In addition, it is not generally
possible to mix 32-bit and 64-bit code together in the same application.

To utilize 64-bits, the Python executable will need to be recompiled as
a 64-bit application. In addition, all libraries, wrapper code, and
every other part of your application will need to be compiled for
64-bits. If you plan to use other third-party extension modules, they
will also have to be recompiled as 64-bit extensions.

If you are wrapping commercial software for which you have no source
code, you will be forced to use the same linking standard as used by
that software. This may prevent the use of 64-bit extensions. It may
also introduce problems on platforms that support more than one linking
standard (e.g., -o32 and -n32 on Irix).

On the Linux x86_64 platform (Opteron or EM64T), besides of the required
compiler option -fPIC discussed above, you will need to be careful about
the libraries you link with or the library path you use. In general, a
Linux distribution will have two set of libraries, one for native x86_64
programs (under /usr/lib64), and another for 32 bits compatibility
(under /usr/lib). Also, the compiler options -m32 and -m64 allow you to
choose the desired binary format for your Python extension.

Building Python extensions under Windows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Building a SWIG extension to Python under Windows is roughly similar to
the process used with Unix. Using the distutils, it is essentially
identical. If you have the same version of the MS compiler that Python
was built with (the python2.4 and python2.5 distributed by python.org
are built with Visual Studio 2003), the standard
``python setup.py build`` should just work.

As of python2.5, the distutils support building extensions with MingGW
out of the box. Following the instruction here: `Building Python
extensions for Windows with only free
tools <http://boodebr.org/main/python/build-windows-extensions>`__
should get you started.

If you need to build it on your own, the following notes are provided:

You will need to create a DLL that can be loaded into the interpreter.
This section briefly describes the use of SWIG with Microsoft Visual
C++. As a starting point, many of SWIG's examples include project files
(.dsp files) for Visual C++ 6. These can be opened by more recent
versions of Visual Studio. You might want to take a quick look at these
examples in addition to reading this section.

In Developer Studio, SWIG should be invoked as a custom build option.
This is usually done as follows:

-  Open up a new workspace and use the AppWizard to select a DLL
   project.
-  Add both the SWIG interface file (the .i file), any supporting C
   files, and the name of the wrapper file that will be created by SWIG
   (ie. ``example_wrap.c``). Note : If using C++, choose a different
   suffix for the wrapper file such as ``example_wrap.cxx``. Don't worry
   if the wrapper file doesn't exist yet--Developer Studio keeps a
   reference to it.
-  Select the SWIG interface file and go to the settings menu. Under
   settings, select the "Custom Build" option.
-  Enter "SWIG" in the description field.
-  Enter
   "``swig -python -o $(ProjDir)\$(InputName)_wrap.c $(InputPath)``" in
   the "Build command(s) field"
-  Enter "``$(ProjDir)\$(InputName)_wrap.c``" in the "Output files(s)
   field".
-  Next, select the settings for the entire project and go to
   "C++:Preprocessor". Add the include directories for your Python
   installation under "Additional include directories".
-  Define the symbol \__WIN32_\_ under preprocessor options.
-  Finally, select the settings for the entire project and go to "Link
   Options". Add the Python library file to your link libraries. For
   example "python27.lib". Also, set the name of the output file to
   match the name of your Python module, i.e. ``_example.pyd``
-  Build your project.

If all went well, SWIG will be automatically invoked whenever you build
your project. Any changes made to the interface file will result in SWIG
being automatically executed to produce a new version of the wrapper
file.

To run your new Python extension, simply run Python and use the
``import`` command as normal. For example :

.. container:: targetlang

   ::

      $ python
      >>> import example
      >>> print example.fact(4)
      24
      >>>

If you get an ``ImportError`` exception when importing the module, you
may have forgotten to include additional library files when you built
your module. If you get an access violation or some kind of general
protection fault immediately upon import, you have a more serious
problem. This is often caused by linking your extension module against
the wrong set of Win32 debug or thread libraries. You will have to
fiddle around with the build options of project to try and track this
down.

A 'Debug' build of the wrappers requires a debug build of the Python
interpreter. This normally requires building the Python interpreter from
source, which is not a job for the feint-hearted. Alternatively you can
use the 'Release' build of the Python interpreter with a 'Debug' build
of your wrappers by defining the ``SWIG_PYTHON_INTERPRETER_NO_DEBUG``
symbol under the preprocessor options. Or you can ensure this macro is
defined at the beginning of the wrapper code using the following in your
interface file, where ``_MSC_VER`` ensures it is only used by the Visual
Studio compiler:

.. container:: code

   ::

      %begin %{
      #ifdef _MSC_VER
      #define SWIG_PYTHON_INTERPRETER_NO_DEBUG
      #endif
      %}

Some users have reported success in building extension modules using
Cygwin and other compilers. However, the problem of building usable DLLs
with these compilers tends to be rather problematic. For the latest
information, you may want to consult the `SWIG
Wiki <https://github.com/swig/swig/wiki>`__.

Additional Python commandline options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following table lists the additional commandline options available
for the Python module. They can also be seen by using:

.. container:: code

   ::

      swig -python -help


.. list-table::
    :widths: 25 50
    :header-rows: 1

    *
      - Python specific options
      -                                                    
    *
      - -builtin
      - Create Python built-in types rather than proxy       
        classes, for better performance
    *
      - -castmode                
      - Enable the casting mode, which allows implicit cast  
        between types in Python
    *                          
      - -debug-doxygen-parser
      - Display doxygen parser module debugging information
    *
      - -debug-doxygen-translator
      - Display doxygen translator module debugging
        information
    *
      - -dirvtable
      - Generate a pseudo virtual table for directors for
        faster dispatch
    *
      - -doxygen
      - Convert C++ doxygen comments to pydoc comments in
        proxy classes
    *
      - -extranative
      - Return extra native wrappers for C++ std containers
        wherever possible
    *
      - -fastproxy
      - Use fast proxy mechanism for member methods          
    *
      - -globals <name>
      - Set <name> used to access C global variable ( 
        default:'cvar')
    *
      - -interface <mod>
      - Set low-level C/C++ module name to <mod> (default:   
        module name prefixed by '_')                         
    *
      - -keyword                 
      - Use keyword arguments
    *
      - -nofastunpack            
      - Use traditional UnpackTuple method to parse the
        argument functions     
    *
      - -noh
      - Don't generate the output header file                
    *
      - -noproxy                 
      - Don't generate proxy classes                         
    *
      - -nortti
      -  Disable the use of the native C++ RTTI with directors
    *
      - -nothreads               
      - Disable thread support for the entire interface      
    *
      - -olddefs
      - Keep the old method definitions when using -fastproxy
    *
      - -py3
      - Generate code with Python 3 specific features and
        syntax
    *
      - -relativeimport
      - Use relative Python imports
    *
      - -threads                 
      - Add thread support for all the interface
    *
      - -O                       
      - Enable the following optimization options: -
        fastdispatch -fastproxy -fvirtual
    


Many of these options are covered later on and their use should become
clearer by the time you have finished reading this section on SWIG and
Python.

A tour of basic C/C++ wrapping
-----------------------------------

By default, SWIG tries to build a very natural Python interface to your
C/C++ code. Functions are wrapped as functions, classes are wrapped as
classes, and so forth. This section briefly covers the essential aspects
of this wrapping.

Modules
~~~~~~~~~~~~~~

The SWIG ``%module`` directive specifies the name of the Python module.
If you specify \`\ ``%module example``', then everything is wrapped into
a Python '``example``' module. Underneath the covers, this module
consists of a Python source file ``example.py`` and a low-level
extension module ``_example.so``. When choosing a module name, make sure
you don't use the same name as a built-in Python command or standard
module name.

Functions
~~~~~~~~~~~~~~~~

Global functions are wrapped as new Python built-in functions. For
example,

.. container:: code

   ::

      %module example
      int fact(int n);

creates a built-in function ``example.fact(n)`` that works exactly like
you think it does:

.. container:: targetlang

   ::

      >>> import example
      >>> print example.fact(4)
      24
      >>>

Global variables
~~~~~~~~~~~~~~~~~~~~~~~

C/C++ global variables are fully supported by SWIG. However, the
underlying mechanism is somewhat different than you might expect due to
the way that Python assignment works. When you type the following in
Python

.. container:: targetlang

   ::

      a = 3.4

"a" becomes a name for an object containing the value 3.4. If you later
type

.. container:: targetlang

   ::

      b = a

then "a" and "b" are both names for the object containing the value 3.4.
Thus, there is only one object containing 3.4 and "a" and "b" are both
names that refer to it. This is quite different than C where a variable
name refers to a memory location in which a value is stored (and
assignment copies data into that location). Because of this, there is no
direct way to map variable assignment in C to variable assignment in
Python.

To provide access to C global variables, SWIG creates a special object
called \`\ ``cvar``' that is added to each SWIG generated module. Global
variables are then accessed as attributes of this object. For example,
consider this interface

.. container:: code

   ::

      // SWIG interface file with global variables
      %module example
      ...
      %inline %{
      extern int My_variable;
      extern double density;
      %}
      ...

Now look at the Python interface:

.. container:: targetlang

   ::

      >>> import example
      >>> # Print out value of a C global variable
      >>> print example.cvar.My_variable
      4
      >>> # Set the value of a C global variable
      >>> example.cvar.density = 0.8442
      >>> # Use in a math operation
      >>> example.cvar.density = example.cvar.density*1.10

If you make an error in variable assignment, you will receive an error
message. For example:

.. container:: targetlang

   ::

      >>> example.cvar.density = "Hello"
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      TypeError: C variable 'density (double )'
      >>>

If a variable is declared as ``const``, it is wrapped as a read-only
variable. Attempts to modify its value will result in an error.

To make ordinary variables read-only, you can use the ``%immutable``
directive. For example:

.. container:: code

   ::

      %{
      extern char *path;
      %}
      %immutable;
      extern char *path;
      %mutable;

The ``%immutable`` directive stays in effect until it is explicitly
disabled or cleared using ``%mutable``. See the `Creating read-only
variables <SWIG.html#SWIG_readonly_variables>`__ section for further
details.

If you just want to make a specific variable immutable, supply a
declaration name. For example:

.. container:: code

   ::

      %{
      extern char *path;
      %}
      %immutable path;
      ...
      extern char *path;      // Read-only (due to %immutable)

If you would like to access variables using a name other than
"``cvar``", it can be changed using the ``-globals`` option :

.. container:: shell

   ::

      $ swig -python -globals myvar example.i

Some care is in order when importing multiple SWIG modules. If you use
the "``from <file> import *``" style of importing, you will get a name
clash on the variable \`\ ``cvar``' and you will only be able to access
global variables from the last module loaded. To prevent this, you might
consider renaming ``cvar`` or making it private to the module by giving
it a name that starts with a leading underscore. SWIG does not create
``cvar`` if there are no global variables in a module.

Constants and enums
~~~~~~~~~~~~~~~~~~~~~~~~~~

C/C++ constants are installed as Python objects containing the
appropriate value. To create a constant, use ``#define``, ``enum``, or
the ``%constant`` directive. For example:

.. container:: code

   ::

      #define PI 3.14159
      #define VERSION "1.0"

      enum Beverage { ALE, LAGER, STOUT, PILSNER };

      %constant int FOO = 42;
      %constant const char *path = "/usr/local";

For enums, make sure that the definition of the enumeration actually
appears in a header file or in the wrapper file somehow---if you just
stick an enum in a SWIG interface without also telling the C compiler
about it, the wrapper code won't compile.

Note: declarations declared as ``const`` are wrapped as read-only
variables and will be accessed using the ``cvar`` object described in
the previous section. They are not wrapped as constants. For further
discussion about this, see the `SWIG Basics <SWIG.html#SWIG>`__ chapter.

Constants are not guaranteed to remain constant in Python---the name of
the constant could be accidentally reassigned to refer to some other
object. Unfortunately, there is no easy way for SWIG to generate code
that prevents this. You will just have to be careful.

Pointers
~~~~~~~~~~~~~~~

C/C++ pointers are fully supported by SWIG. Furthermore, SWIG has no
problem working with incomplete type information. Here is a rather
simple interface:

.. container:: code

   ::

      %module example

      FILE *fopen(const char *filename, const char *mode);
      int fputs(const char *, FILE *);
      int fclose(FILE *);

When wrapped, you will be able to use the functions in a natural way
from Python. For example:

.. container:: targetlang

   ::

      >>> import example
      >>> f = example.fopen("junk", "w")
      >>> example.fputs("Hello World\n", f)
      >>> example.fclose(f)

If this makes you uneasy, rest assured that there is no deep magic
involved. Underneath the covers, pointers to C/C++ objects are simply
represented as opaque values using an especial Python container object:

.. container:: targetlang

   ::

      >>> print f
      <Swig Object of type 'FILE *' at 0xb7d6f470>

This pointer value can be freely passed around to different C functions
that expect to receive an object of type ``FILE *``. The only thing you
can't do is dereference the pointer from Python. Of course, that isn't
much of a concern in this example.

In older versions of SWIG (1.3.22 or older), pointers were represented
using a plain string object. If you have an old package that still
requires that representation, or you just feel nostalgic, you can always
retrieve it by casting the pointer object to a string:

.. container:: targetlang

   ::

      >>> print str(f)
      _c0671108_p_FILE

Also, if you need to pass the raw pointer value to some external Python
library, you can do it by casting the pointer object to an integer:

.. container:: targetlang

   ::

      >>> print int(f)
      135833352

However, the inverse operation is not possible, i.e., you can't build a
SWIG pointer object from a raw integer value.

Note also that the '0' or NULL pointer is always represented by
``None``, no matter what type swig is addressing. In the previous
example, you can call:

.. container:: targetlang

   ::

      >>> example.fclose(None)

and that will be equivalent to the following, but not really useful, C
code:

.. container:: code

   ::

      FILE *f = NULL;
      fclose(f);

As much as you might be inclined to modify a pointer value directly from
Python, don't. The hexadecimal encoding is not necessarily the same as
the logical memory address of the underlying object. Instead it is the
raw byte encoding of the pointer value. The encoding will vary depending
on the native byte-ordering of the platform (i.e., big-endian vs.
little-endian). Similarly, don't try to manually cast a pointer to a new
type by simply replacing the type-string. This may not work like you
expect, it is particularly dangerous when casting C++ objects. If you
need to cast a pointer or change its value, consider writing some helper
functions instead. For example:

.. container:: code

   ::

      %inline %{
      /* C-style cast */
      Bar *FooToBar(Foo *f) {
        return (Bar *) f;
      }

      /* C++-style cast */
      Foo *BarToFoo(Bar *b) {
        return dynamic_cast<Foo*>(b);
      }

      Foo *IncrFoo(Foo *f, int i) {
        return f+i;
      }
      %}

Also, if working with C++, you should always try to use the new C++
style casts. For example, in the above code, the C-style cast may return
a bogus result whereas as the C++-style cast will return ``None`` if the
conversion can't be performed.

Structures
~~~~~~~~~~~~~~~~~

If you wrap a C structure, it is wrapped by a Python class. This
provides a very natural interface. For example,

.. container:: code

   ::

      struct Vector {
        double x, y, z;
      };

is used as follows:

.. container:: targetlang

   ::

      >>> v = example.Vector()
      >>> v.x = 3.5
      >>> v.y = 7.2
      >>> print v.x, v.y, v.z
      3.5 7.2 0.0
      >>>

Similar access is provided for unions and the data members of C++
classes.

If you print out the value of ``v`` in the above example, you will see
something like this:

.. container:: targetlang

   ::

      >>> print v
      <C Vector instance at _18e31408_p_Vector>

This object is actually a Python instance that has been wrapped around a
pointer to the low-level C structure. This instance doesn't actually do
anything--it just serves as a proxy. The pointer to the C object can be
found in the ``.this`` attribute. For example:

.. container:: targetlang

   ::

      >>> print v.this
      _18e31408_p_Vector
      >>>

Further details about the Python proxy class are covered a little later.

``const`` members of a structure are read-only. Data members can also be
forced to be read-only using the ``%immutable`` directive. For example:

.. container:: code

   ::

      struct Foo {
        ...
        %immutable;
        int x;        /* Read-only members */
        char *name;
        %mutable;
        ...
      };

When ``char *`` members of a structure are wrapped, the contents are
assumed to be dynamically allocated using ``malloc`` or ``new``
(depending on whether or not SWIG is run with the -c++ option). When the
structure member is set, the old contents will be released and a new
value created. If this is not the behavior you want, you will have to
use a typemap (described later).

If a structure contains arrays, access to those arrays is managed
through pointers. For example, consider this:

.. container:: code

   ::

      struct Bar {
        int  x[16];
      };

If accessed in Python, you will see behavior like this:

.. container:: targetlang

   ::

      >>> b = example.Bar()
      >>> print b.x
      _801861a4_p_int
      >>>

This pointer can be passed around to functions that expect to receive an
``int *`` (just like C). You can also set the value of an array member
using another pointer. For example:

.. container:: targetlang

   ::

      >>> c = example.Bar()
      >>> c.x = b.x             # Copy contents of b.x to c.x

For array assignment, SWIG copies the entire contents of the array
starting with the data pointed to by ``b.x``. In this example, 16
integers would be copied. Like C, SWIG makes no assumptions about bounds
checking---if you pass a bad pointer, you may get a segmentation fault
or access violation.

When a member of a structure is itself a structure, it is handled as a
pointer. For example, suppose you have two structures like this:

.. container:: code

   ::

      struct Foo {
        int a;
      };

      struct Bar {
        Foo f;
      };

Now, suppose that you access the ``f`` attribute of ``Bar`` like this:

.. container:: targetlang

   ::

      >>> b = Bar()
      >>> x = b.f

In this case, ``x`` is a pointer that points to the ``Foo`` that is
inside ``b``. This is the same value as generated by this C code:

.. container:: code

   ::

      Bar b;
      Foo *x = &b->f;       /* Points inside b */

Because the pointer points inside the structure, you can modify the
contents and everything works just like you would expect. For example:

.. container:: targetlang

   ::

      >>> b = Bar()
      >>> b.f.a = 3               # Modify attribute of structure member
      >>> x = b.f
      >>> x.a = 3                 # Modifies the same structure

Note that there is a limitation with structs within structs that will
cause a problem if the outer struct is not a named variable in Python.
The following will cause a segfault:

.. container:: targetlang

   ::

      Bar().f.a = 3

because the unnamed Python proxy class for ``Bar()`` has its reference
count decremented by the Python interpreter after ``f`` has been
obtained from it and before ``f`` is used to obtain ``a``. This results
in the underlying ``Bar`` instance being deleted, which of course also
deletes ``f`` inside it. Hence the pointer to ``f`` points to deleted
memory and use of it results in a segfault or some sort of other
undefined behaviour.

C++ classes
~~~~~~~~~~~~~~~~~~

C++ classes are wrapped by Python classes as well. For example, if you
have this class,

.. container:: code

   ::

      class List {
      public:
        List();
        ~List();
        int  search(char *item);
        void insert(char *item);
        void remove(char *item);
        char *get(int n);
        int  length;
      };

you can use it in Python like this:

.. container:: targetlang

   ::

      >>> l = example.List()
      >>> l.insert("Ale")
      >>> l.insert("Stout")
      >>> l.insert("Lager")
      >>> l.get(1)
      'Stout'
      >>> print l.length
      3
      >>>

Class data members are accessed in the same manner as C structures.

Static class members present a special problem for Python. Prior to
Python-2.2, Python classes had no support for static methods and no
version of Python supports static member variables in a manner that SWIG
can utilize. Therefore, SWIG generates wrappers that try to work around
some of these issues. To illustrate, suppose you have a class like this:

.. container:: code

   ::

      class Spam {
      public:
        static void foo();
        static int bar;
      };

In Python, the static member can be access in three different ways:

.. container:: targetlang

   ::

      >>> example.Spam_foo()    # Spam::foo()
      >>> s = example.Spam()
      >>> s.foo()               # Spam::foo() via an instance
      >>> example.Spam.foo()    # Spam::foo(). Python-2.2 only

The first two methods of access are supported in all versions of Python.
The last technique is only available in Python-2.2 and later versions.

Static member variables are currently accessed as global variables. This
means, they are accessed through ``cvar`` like this:

.. container:: targetlang

   ::

      >>> print example.cvar.Spam_bar
      7

C++ inheritance
~~~~~~~~~~~~~~~~~~~~~~

SWIG is fully aware of issues related to C++ inheritance. Therefore, if
you have classes like this

.. container:: code

   ::

      class Foo {
      ...
      };

      class Bar : public Foo {
      ...
      };

those classes are wrapped into a hierarchy of Python classes that
reflect the same inheritance structure. All of the usual Python utility
functions work normally:

.. container:: targetlang

   ::

      >>> b = Bar()
      >>> instance(b, Foo)
      1
      >>> issubclass(Bar, Foo)
      1
      >>> issubclass(Foo, Bar)
      0

Furthermore, if you have functions like this

.. container:: code

   ::

      void spam(Foo *f);

then the function ``spam()`` accepts ``Foo *`` or a pointer to any class
derived from ``Foo``.

It is safe to use multiple inheritance with SWIG.

Pointers, references, values, and arrays
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In C++, there are many different ways a function might receive and
manipulate objects. For example:

.. container:: code

   ::

      void spam1(Foo *x);      // Pass by pointer
      void spam2(Foo &x);      // Pass by reference
      void spam3(const Foo &x);// Pass by const reference
      void spam4(Foo x);       // Pass by value
      void spam5(Foo x[]);     // Array of objects

In Python, there is no detailed distinction like this--specifically,
there are only "objects". There are no pointers, references, arrays, and
so forth. Because of this, SWIG unifies all of these types together in
the wrapper code. For instance, if you actually had the above functions,
it is perfectly legal to do this:

.. container:: targetlang

   ::

      >>> f = Foo()           # Create a Foo
      >>> spam1(f)            # Ok. Pointer
      >>> spam2(f)            # Ok. Reference
      >>> spam3(f)            # Ok. Const reference
      >>> spam4(f)            # Ok. Value.
      >>> spam5(f)            # Ok. Array (1 element)

Similar behavior occurs for return values. For example, if you had
functions like this,

.. container:: code

   ::

      Foo *spam6();
      Foo &spam7();
      Foo  spam8();
      const Foo &spam9();

then all three functions will return a pointer to some ``Foo`` object.
Since the third function (spam8) returns a value, newly allocated memory
is used to hold the result and a pointer is returned (Python will
release this memory when the return value is garbage collected). The
fourth case (spam9) which returns a const reference, in most of the
cases will be treated as a returning value, and it will follow the same
allocation/deallocation process.

C++ overloaded functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C++ overloaded functions, methods, and constructors are mostly supported
by SWIG. For example, if you have two functions like this:

.. container:: code

   ::

      void foo(int);
      void foo(char *c);

You can use them in Python in a straightforward manner:

.. container:: targetlang

   ::

      >>> foo(3)           # foo(int)
      >>> foo("Hello")     # foo(char *c)

Similarly, if you have a class like this,

.. container:: code

   ::

      class Foo {
      public:
        Foo();
        Foo(const Foo &);
        ...
      };

you can write Python code like this:

.. container:: targetlang

   ::

      >>> f = Foo()          # Create a Foo
      >>> g = Foo(f)         # Copy f

Overloading support is not quite as flexible as in C++. Sometimes there
are methods that SWIG can't disambiguate. For example:

.. container:: code

   ::

      void spam(int);
      void spam(short);

or

.. container:: code

   ::

      void foo(Bar *b);
      void foo(Bar &b);

If declarations such as these appear, you will get a warning message
like this:

.. container:: shell

   ::

      example.i:12: Warning 509: Overloaded method spam(short) effectively ignored,
      example.i:11: Warning 509: as it is shadowed by spam(int).

To fix this, you either need to ignore or rename one of the methods. For
example:

.. container:: code

   ::

      %rename(spam_short) spam(short);
      ...
      void spam(int);
      void spam(short);   // Accessed as spam_short

or

.. container:: code

   ::

      %ignore spam(short);
      ...
      void spam(int);
      void spam(short);   // Ignored

SWIG resolves overloaded functions and methods using a disambiguation
scheme that ranks and sorts declarations according to a set of
type-precedence rules. The order in which declarations appear in the
input does not matter except in situations where ambiguity arises--in
this case, the first declaration takes precedence.

Please refer to the "SWIG and C++" chapter for more information about
overloading.

C++ operators
~~~~~~~~~~~~~~~~~~~~~

Certain C++ overloaded operators can be handled automatically by SWIG.
For example, consider a class like this:

.. container:: code

   ::

      class Complex {
      private:
        double rpart, ipart;
      public:
        Complex(double r = 0, double i = 0) : rpart(r), ipart(i) { }
        Complex(const Complex &c) : rpart(c.rpart), ipart(c.ipart) { }
        Complex &operator=(const Complex &c);

        Complex operator+=(const Complex &c) const;
        Complex operator+(const Complex &c) const;
        Complex operator-(const Complex &c) const;
        Complex operator*(const Complex &c) const;
        Complex operator-() const;

        double re() const { return rpart; }
        double im() const { return ipart; }
      };

When wrapped, it works like you expect:

.. container:: targetlang

   ::

      >>> c = Complex(3, 4)
      >>> d = Complex(7, 8)
      >>> e = c + d
      >>> e.re()
      10.0
      >>> e.im()
      12.0
      >>> c += d
      >>> c.re()
      10.0
      >>> c.im()
      12.0

One restriction with operator overloading support is that SWIG is not
able to fully handle operators that aren't defined as part of the class.
For example, if you had code like this

.. container:: code

   ::

      class Complex {
      ...
      friend Complex operator+(double, const Complex &c);
      ...
      };

then SWIG ignores it and issues a warning. You can still wrap the
operator, but you may have to encapsulate it in a special function. For
example:

.. container:: code

   ::

      %rename(Complex_add_dc) operator+(double, const Complex &);

There are ways to make this operator appear as part of the class using
the ``%extend`` directive. Keep reading.

Also, be aware that certain operators don't map cleanly to Python. For
instance, overloaded assignment operators don't map to Python semantics
and will be ignored.

Operator overloading is implemented in the ``pyopers.swg`` library file.
In particular overloaded operators are marked with the
``python:maybecall`` feature, also known as ``%pythonmaybecall``. This
feature forces SWIG to generate code that return an instance of Python's
``NotImplemented`` instead of raising an exception when the comparison
fails, that is, on any kind of error. This follows the guidelines in
`PEP 207 - Rich
Comparisons <https://www.python.org/dev/peps/pep-0207/>`__ and
`NotImplemented Python
constant <https://docs.python.org/3/library/constants.html#NotImplemented>`__.

C++ namespaces
~~~~~~~~~~~~~~~~~~~~~~

SWIG is aware of C++ namespaces, but namespace names do not appear in
the module nor do namespaces result in a module that is broken up into
submodules or packages. For example, if you have a file like this,

.. container:: code

   ::

      %module example

      namespace foo {
        int fact(int n);
        struct Vector {
          double x, y, z;
        };
      };

it works in Python as follows:

.. container:: targetlang

   ::

      >>> import example
      >>> example.fact(3)
      6
      >>> v = example.Vector()
      >>> v.x = 3.4
      >>> print v.y
      0.0
      >>>

If your program has more than one namespace, name conflicts (if any) can
be resolved using ``%rename`` For example:

.. container:: code

   ::

      %rename(Bar_spam) Bar::spam;

      namespace Foo {
        int spam();
      }

      namespace Bar {
        int spam();
      }

If you have more than one namespace and your want to keep their symbols
separate, consider wrapping them as separate SWIG modules. For example,
make the module name the same as the namespace and create extension
modules for each namespace separately. If your program utilizes
thousands of small deeply nested namespaces each with identical symbol
names, well, then you get what you deserve.

C++ templates
~~~~~~~~~~~~~~~~~~~~~

C++ templates don't present a huge problem for SWIG. However, in order
to create wrappers, you have to tell SWIG to create wrappers for a
particular template instantiation. To do this, you use the ``%template``
directive. For example:

.. container:: code

   ::

      %module example
      %{
      #include "pair.h"
      %}

      template<class T1, class T2>
      struct pair {
        typedef T1 first_type;
        typedef T2 second_type;
        T1 first;
        T2 second;
        pair();
        pair(const T1&, const T2&);
       ~pair();
      };

      %template(pairii) pair<int, int>;

In Python:

.. container:: targetlang

   ::

      >>> import example
      >>> p = example.pairii(3, 4)
      >>> p.first
      3
      >>> p.second
      4

Obviously, there is more to template wrapping than shown in this
example. More details can be found in the `SWIG and
C++ <SWIGPlus.html#SWIGPlus>`__ chapter. Some more complicated examples
will appear later.

C++ Smart Pointers
~~~~~~~~~~~~~~~~~~~~~~~~~~

The shared_ptr Smart Pointer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The C++11 standard provides ``std::shared_ptr`` which was derived from
the Boost implementation, ``boost::shared_ptr``. Both of these are
available for Python in the SWIG library and usage is outlined in the
`shared_ptr smart pointer <Library.html#Library_std_shared_ptr>`__
library section.

Generic Smart Pointers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In certain C++ programs, it is common to use classes that have been
wrapped by so-called "smart pointers." Generally, this involves the use
of a template class that implements ``operator->()`` like this:

.. container:: code

   ::

      template<class T> class SmartPtr {
        ...
        T *operator->();
        ...
      }

Then, if you have a class like this,

.. container:: code

   ::

      class Foo {
      public:
        int x;
        int bar();
      };

A smart pointer would be used in C++ as follows:

.. container:: code

   ::

      SmartPtr<Foo> p = CreateFoo();   // Created somehow (not shown)
      ...
      p->x = 3;                        // Foo::x
      int y = p->bar();                // Foo::bar

To wrap this in Python, simply tell SWIG about the ``SmartPtr`` class
and the low-level ``Foo`` object. Make sure you instantiate ``SmartPtr``
using ``%template`` if necessary. For example:

.. container:: code

   ::

      %module example
      ...
      %template(SmartPtrFoo) SmartPtr<Foo>;
      ...

Now, in Python, everything should just "work":

.. container:: targetlang

   ::

      >>> p = example.CreateFoo()          # Create a smart-pointer somehow
      >>> p.x = 3                          # Foo::x
      >>> p.bar()                          # Foo::bar

If you ever need to access the underlying pointer returned by
``operator->()`` itself, simply use the ``__deref__()`` method. For
example:

.. container:: targetlang

   ::

      >>> f = p.__deref__()     # Returns underlying Foo *

C++ reference counted objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The `C++ reference counted objects <SWIGPlus.html#SWIGPlus_ref_unref>`__
section contains Python examples of memory management using referencing
counting.

Further details on the Python class interface
--------------------------------------------------

In the previous section, a high-level view of Python wrapping was
presented. A key component of this wrapping is that structures and
classes are wrapped by Python proxy classes. This provides a very
natural Python interface and allows SWIG to support a number of advanced
features such as operator overloading. However, a number of low-level
details were omitted. This section provides a brief overview of how the
proxy classes work.

**New in SWIG version 2.0.4:** The use of Python proxy classes has
performance implications that may be unacceptable for a high-performance
library. The new ``-builtin`` option instructs SWIG to forego the use of
proxy classes, and instead create wrapped types as new built-in Python
types. When this option is used, the following section ("Proxy classes")
does not apply. Details on the use of the ``-builtin`` option are in the
`Built-in Types <#Python_builtin_types>`__ section.

Proxy classes
~~~~~~~~~~~~~~~~~~~~

In the `"SWIG basics" <SWIG.html#SWIG>`__ and `"SWIG and
C++" <SWIGPlus.html#SWIGPlus>`__ chapters, details of low-level
structure and class wrapping are described. To summarize those chapters,
if you have a class like this

.. container:: code

   ::

      class Foo {
      public:
        int x;
        int spam(int);
        ...

then SWIG transforms it into a set of low-level procedural wrappers. For
example:

.. container:: code

   ::

      Foo *new_Foo() {
        return new Foo();
      }
      void delete_Foo(Foo *f) {
        delete f;
      }
      int Foo_x_get(Foo *f) {
        return f->x;
      }
      void Foo_x_set(Foo *f, int value) {
        f->x = value;
      }
      int Foo_spam(Foo *f, int arg1) {
        return f->spam(arg1);
      }

These wrappers can be found in the low-level extension module (e.g.,
``_example``).

Using these wrappers, SWIG generates a high-level Python proxy class
(also known as a shadow class) like this (shown for Python 2.2):

.. container:: targetlang

   ::

      import _example

      class Foo(object):
          def __init__(self):
              self.this = _example.new_Foo()
              self.thisown = 1
          def __del__(self):
              if self.thisown:
                  _example.delete_Foo(self.this)
          def spam(self, arg1):
              return _example.Foo_spam(self.this, arg1)
          x = property(_example.Foo_x_get, _example.Foo_x_set)

This class merely holds a pointer to the underlying C++ object
(``.this``) and dispatches methods and member variable access to that
object using the low-level accessor functions. From a user's point of
view, it makes the class work normally:

.. container:: targetlang

   ::

      >>> f = example.Foo()
      >>> f.x = 3
      >>> y = f.spam(5)

The fact that the class has been wrapped by a real Python class offers
certain advantages. For instance, you can attach new Python methods to
the class and you can even inherit from it (something not supported by
Python built-in types until Python 2.2).

Built-in Types
~~~~~~~~~~~~~~~~~~~~~

The ``-builtin`` option provides a significant performance improvement
in the wrapped code. To understand the difference between proxy classes
and built-in types, let's take a look at what a wrapped object looks
like under both circumstances.

When proxy classes are used, each wrapped object in Python is an
instance of a pure Python class. As a reminder, here is what the
``__init__`` method looks like in a proxy class:

.. container:: targetlang

   ::

      class Foo(object):
          def __init__(self):
              self.this = _example.new_Foo()
              self.thisown = 1

When a ``Foo`` instance is created, the call to ``_example.new_Foo()``
creates a new C++ ``Foo`` instance; wraps that C++ instance inside an
instance of a Python built-in type called ``SwigPyObject``; and stores
the ``SwigPyObject`` instance in the 'this' field of the Python Foo
object. Did you get all that? So, the Python ``Foo`` object is composed
of three parts:

-  The Python ``Foo`` instance, which contains...
-  ... an instance of ``struct SwigPyObject``, which contains...
-  ... a C++ ``Foo`` instance

When ``-builtin`` is used, the pure Python layer is stripped off. Each
wrapped class is turned into a new Python built-in type which inherits
from ``SwigPyObject``, and ``SwigPyObject`` instances are returned
directly from the wrapped methods. For more information about Python
built-in extensions, please refer to the Python documentation:

https://docs.python.org/3/extending/newtypes.html

Limitations
^^^^^^^^^^^^^^^^^^^^

Use of the ``-builtin`` option implies a couple of limitations:

-  Some legacy syntax is no longer supported; in particular:

   -  The functional interface is no longer exposed. For example, you
      may no longer call ``Whizzo.new_CrunchyFrog()``. Instead, you must
      use ``Whizzo.CrunchyFrog()``.
   -  Static member variables are no longer accessed through the 'cvar'
      field (e.g., ``Dances.cvar.FishSlap``). They are instead accessed
      in the idiomatic way (``Dances.FishSlap``).

-  Wrapped types may not be raised as Python exceptions. Here's why: the
   Python internals expect that all sub-classes of Exception will have
   this struct layout:

   .. container:: code

      ::

         typedef struct {
           PyObject_HEAD
           PyObject *dict;
           PyObject *args;
           PyObject *message;
         } PyBaseExceptionObject;

   But swig-generated wrappers expect that all swig-wrapped classes will
   have this struct layout:

   .. container:: code

      ::

         typedef struct {
           PyObject_HEAD
           void *ptr;
           swig_type_info *ty;
           int own;
           PyObject *next;
           PyObject *dict;
         } SwigPyObject;

   There are workarounds for this. For example, if you wrap this class:

   .. container:: code

      ::

         class MyException {
         public:
           MyException (const char *msg_);
           ~MyException ();

           const char *what () const;

         private:
           char *msg;
         };

   ... you can define this Python class, which may be raised as an
   exception:

   .. container:: targetlang

      ::

         class MyPyException(Exception):
             def __init__(self, msg, *args):
                 Exception.__init__(self, *args)
                 self.myexc = MyException(msg)
             def what(self):
                 return self.myexc.what()

-  Reverse binary operators (e.g., ``__radd__``) are not supported.

   To illustrate this point, if you have a wrapped class called
   ``MyString``, and you want to use instances of ``MyString``
   interchangeably with native Python strings, you can define an
   ``'operator+ (const char*)'`` method :

   .. container:: code

      ::

         class MyString {
         public:
           MyString (const char *init);
           MyString operator+ (const char *other) const;
           ...
         };

   SWIG will automatically create an operator overload in Python that
   will allow this:

   .. container:: targetlang

      ::

         from MyModule import MyString

         mystr = MyString("No one expects")
         episode = mystr + " the Spanish Inquisition"

   This works because the first operand (``mystr``) defines a way to add
   a native string to itself. However, the following will **not** work:

   .. container:: targetlang

      ::

         from MyModule import MyString

         mystr = MyString("Parrot")
         episode = "Dead " + mystr

   The above code fails, because the first operand -- a native Python
   string -- doesn't know how to add an instance of ``MyString`` to
   itself.

-  If you have multiple SWIG modules that share type information (`more
   info <Modules.html#Modules_nn2>`__), the ``-builtin`` option requires
   a bit of extra discipline to ensure that base classes are initialized
   before derived classes. Specifically:

   -  There must be an unambiguous dependency graph for the modules.

   -  Module dependencies must be explicitly stated with ``%import``
      statements in the SWIG interface file.

   As an example, suppose module ``A`` has this interface in ``A.i`` :

   .. container:: code

      ::

         %module "A";

         class Base {
         ...
         };

   If you want to wrap another module containing a class that inherits
   from ``A``, this is how it would look :

   .. container:: code

      ::

         %module "B";

         %import "A.i"

         class Derived : public Base {
         ...
         };

   The ``import "A.i"`` statement is required, because module ``B``
   depends on module ``A``.

   As long as you obey these requirements, your Python code may import
   the modules in any order :

   .. container:: targetlang

      ::

         import B
         import A

         assert(issubclass(B.Derived, A.Base))

Operator overloads and slots -- use them!
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The entire justification for the ``-builtin`` option is improved
performance. To that end, the best way to squeeze maximum performance
out of your wrappers is to **use operator overloads.** Named method
dispatch is slow in Python, even when compared to other scripting
languages. However, Python built-in types have a large number of
"slots", analogous to C++ operator overloads, which allow you to
short-circuit named method dispatch for certain common operations.

By default, SWIG will translate most C++ arithmetic operator overloads
into Python slot entries. For example, suppose you have this class:

.. container:: code

   ::

      class Twit {
      public:
        Twit operator+ (const Twit& twit) const;

        // Forward to operator+
        Twit add (const Twit& twit) const {
          return *this + twit;
        }
      };

SWIG will automatically register ``operator+`` as a Python slot operator
for addition. You may write Python code like this:

.. container:: targetlang

   ::

      from MyModule import Twit

      nigel = Twit()
      emily = Twit()
      percival = nigel + emily
      percival = nigel.add(emily)

The last two lines of the Python code are equivalent, but **the line
that uses the '+' operator is much faster**.

In-place operators (e.g., ``operator+=``) and comparison operators
(``operator==, operator<``, etc.) are also converted to Python slot
operators. For a complete list of C++ operators that are automatically
converted to Python slot operators, refer to the file
``python/pyopers.swg`` in the SWIG library.

Read about all of the available Python slots here:
https://docs.python.org/3/c-api/typeobj.html

There are two ways to define a Python slot function: dispatch to a
statically defined function; or dispatch to a method defined on the
operand.

To dispatch to a statically defined function, use
%feature("python:<slot>"), where <slot> is the name of a field in a
``PyTypeObject, PyNumberMethods, PyMappingMethods, PySequenceMethods``
or ``PyBufferProcs``. You may override (almost) all of these slots.

Let's consider an example setting the ``tp_hash`` slot for the
``MyClass`` type. This is akin to providing a ``__hash__`` method (for
non-builtin types) to make a type hashable. The hashable type can then
for example be added to a Python ``dict``.

.. container:: code

   ::

      %feature("python:tp_hash") MyClass "myHashFunc";

      class MyClass {
      public:
        long field1;
        long field2;
        ...
      };

      %{
      #if PY_VERSION_HEX >= 0x03020000
        static Py_hash_t myHashFunc(PyObject *pyobj)
      #else
        static long myHashFunc(PyObject *pyobj)
      #endif
        {
          MyClass *cobj;
          // Convert pyobj to cobj
          return (cobj->field1 * (cobj->field2 << 7));
        }
      %}

If you examine the generated code, the supplied hash function will now
be the function callback in the tp_hash slot for the builtin type for
``MyClass``:

.. container:: code

   ::

      static PyHeapTypeObject SwigPyBuiltin__MyClass_type = {
        ...
        (hashfunc) myHashFunc,       /* tp_hash */
        ...

NOTE: It is the responsibility of the programmer (that's you!) to ensure
that a statically defined slot function has the correct signature, the
``hashfunc`` typedef in this case.

If, instead, you want to dispatch to an instance method, you can use
%feature("python:slot"). For example:

.. container:: code

   ::

      %feature("python:slot", "tp_hash", functype="hashfunc") MyClass::myHashFunc;

      #if PY_VERSION_HEX < 0x03020000
        #define Py_hash_t long
      #endif

      class MyClass {
        public:
          Py_hash_t myHashFunc() const;
          ...
      };

NOTE: Some Python slots use a method signature which does not match the
signature of SWIG-wrapped methods. For those slots, SWIG will
automatically generate a "closure" function to re-marshal the arguments
before dispatching to the wrapped method. Setting the "functype"
attribute of the feature enables SWIG to generate the chosen closure
function.

There is further information on ``%feature("python:slot")`` in the file
``python/pyopers.swg`` in the SWIG library.

Memory management
~~~~~~~~~~~~~~~~~~~~~~~~

NOTE: Although this section refers to proxy objects, everything here
also applies when the ``-builtin`` option is used.

Associated with proxy object, is an ownership flag ``.thisown`` The
value of this flag determines who is responsible for deleting the
underlying C++ object. If set to 1, the Python interpreter will destroy
the C++ object when the proxy class is garbage collected. If set to 0
(or if the attribute is missing), then the destruction of the proxy
class has no effect on the C++ object.

When an object is created by a constructor or returned by value, Python
automatically takes ownership of the result. For example:

.. container:: code

   ::

      class Foo {
      public:
        Foo();
        Foo bar();
      };

In Python:

.. container:: targetlang

   ::

      >>> f = Foo()
      >>> f.thisown
      1
      >>> g = f.bar()
      >>> g.thisown
      1

On the other hand, when pointers are returned to Python, there is often
no way to know where they came from. Therefore, the ownership is set to
zero. For example:

.. container:: code

   ::

      class Foo {
      public:
        ...
        Foo *spam();
        ...
      };

| 

.. container:: targetlang

   ::

      >>> f = Foo()
      >>> s = f.spam()
      >>> print s.thisown
      0
      >>>

This behavior is especially important for classes that act as
containers. For example, if a method returns a pointer to an object that
is contained inside another object, you definitely don't want Python to
assume ownership and destroy it!

A good way to indicate that ownership should be set for a returned
pointer is to use the `%newobject
directive <Library.html#Library_nn11>`__.

Related to containers, ownership issues can arise whenever an object is
assigned to a member or global variable. For example, consider this
interface:

.. container:: code

   ::

      %module example

      struct Foo {
        int  value;
        Foo  *next;
      };

      Foo *head = 0;

When wrapped in Python, careful observation will reveal that ownership
changes whenever an object is assigned to a global variable. For
example:

.. container:: targetlang

   ::

      >>> f = example.Foo()
      >>> f.thisown
      1
      >>> example.cvar.head = f
      >>> f.thisown
      0
      >>>

In this case, C is now holding a reference to the object---you probably
don't want Python to destroy it. Similarly, this occurs for members. For
example:

.. container:: targetlang

   ::

      >>> f = example.Foo()
      >>> g = example.Foo()
      >>> f.thisown
      1
      >>> g.thisown
      1
      >>> f.next = g
      >>> g.thisown
      0
      >>>

For the most part, memory management issues remain hidden. However,
there are occasionally situations where you might have to manually
change the ownership of an object. For instance, consider code like
this:

.. container:: code

   ::

      class Node {
        Object *value;
      public:
        void set_value(Object *v) { value = v; }
        ...
      };

Now, consider the following Python code:

.. container:: targetlang

   ::

      >>> v = Object()           # Create an object
      >>> n = Node()             # Create a node
      >>> n.set_value(v)         # Set value
      >>> v.thisown
      1
      >>> del v

In this case, the object ``n`` is holding a reference to ``v``
internally. However, SWIG has no way to know that this has occurred.
Therefore, Python still thinks that it has ownership of the object.
Should the proxy object be destroyed, then the C++ destructor will be
invoked and ``n`` will be holding a stale-pointer. If you're lucky, you
will only get a segmentation fault.

To work around this, it is always possible to flip the ownership flag.
For example,

.. container:: targetlang

   ::

      >>> v.thisown = 0

It is also possible to deal with situations like this using typemaps--an
advanced topic discussed later.

Cross language polymorphism
--------------------------------

Proxy classes provide a more natural, object-oriented way to access
extension classes. As described above, each proxy instance has an
associated C++ instance, and method calls to the proxy are passed to the
C++ instance transparently via C wrapper functions.

This arrangement is asymmetric in the sense that no corresponding
mechanism exists to pass method calls down the inheritance chain from
C++ to Python. In particular, if a C++ class has been extended in Python
(by extending the proxy class), these extensions will not be visible
from C++ code. Virtual method calls from C++ are thus not able access
the lowest implementation in the inheritance chain.

Changes have been made to SWIG 1.3.18 to address this problem and make
the relationship between C++ classes and proxy classes more symmetric.
To achieve this goal, new classes called directors are introduced at the
bottom of the C++ inheritance chain. The job of the directors is to
route method calls correctly, either to C++ implementations higher in
the inheritance chain or to Python implementations lower in the
inheritance chain. The upshot is that C++ classes can be extended in
Python and from C++ these extensions look exactly like native C++
classes. Neither C++ code nor Python code needs to know where a
particular method is implemented: the combination of proxy classes,
director classes, and C wrapper functions takes care of all the
cross-language method routing transparently.

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
        virtual ~Foo();
        virtual void one();
        virtual void two();
      };

      class Bar: public Foo {
      public:
        virtual void three();
      };

then at the Python side you can define

.. container:: targetlang

   ::

      import mymodule

      class MyFoo(mymodule.Foo):
          def __init__(self, foo):
              mymodule.Foo.__init__(self, foo)
      #       super().__init__(foo) # Alternative construction for Python3

          def one(self):
              print "one from Python"

Director classes
~~~~~~~~~~~~~~~~~~~~~~~

For each class that has directors enabled, SWIG generates a new class
that derives from both the class in question and a special
``Swig::Director`` class. These new classes, referred to as director
classes, can be loosely thought of as the C++ equivalent of the Python
proxy classes. The director classes store a pointer to their underlying
Python object and handle various issues related to object ownership.
Indeed, this is quite similar to the "this" and "thisown" members of the
Python proxy classes.

For simplicity let's ignore the ``Swig::Director`` class and refer to
the original C++ class as the director's base class. By default, a
director class extends all virtual methods in the inheritance chain of
its base class (see the preceding section for how to modify this
behavior). Virtual methods that have a final specifier are
unsurprisingly excluded. Thus the virtual method calls, whether they
originate in C++ or in Python via proxy classes, eventually end up in at
the implementation in the director class. The job of the director
methods is to route these method calls to the appropriate place in the
inheritance chain. By "appropriate place" we mean the method that would
have been called if the C++ base class and its extensions in Python were
seamlessly integrated. That seamless integration is exactly what the
director classes provide, transparently skipping over all the messy
extension API glue that binds the two languages together.

In reality, the "appropriate place" is one of only two possibilities:
C++ or Python. Once this decision is made, the rest is fairly easy. If
the correct implementation is in C++, then the lowest implementation of
the method in the C++ inheritance chain is called explicitly. If the
correct implementation is in Python, the Python API is used to call the
method of the underlying Python object (after which the usual virtual
method resolution in Python automatically finds the right
implementation).

Now how does the director decide which language should handle the method
call? The basic rule is to handle the method in Python, unless there's a
good reason not to. The reason for this is simple: Python has the most
"extended" implementation of the method. This assertion is guaranteed,
since at a minimum the Python proxy class implements the method. If the
method in question has been extended by a class derived from the proxy
class, that extended implementation will execute exactly as it should.
If not, the proxy class will route the method call into a C wrapper
function, expecting that the method will be resolved in C++. The wrapper
will call the virtual method of the C++ instance, and since the director
extends this the call will end up right back in the director method. Now
comes the "good reason not to" part. If the director method were to
blindly call the Python method again, it would get stuck in an infinite
loop. We avoid this situation by adding special code to the C wrapper
function that tells the director method to not do this. The C wrapper
function compares the pointer to the Python object that called the
wrapper function to the pointer stored by the director. If these are the
same, then the C wrapper function tells the director to resolve the
method by calling up the C++ inheritance chain, preventing an infinite
loop.

One more point needs to be made about the relationship between director
classes and proxy classes. When a proxy class instance is created in
Python, SWIG creates an instance of the original C++ class and assigns
it to ``.this``. This is exactly what happens without directors and is
true even if directors are enabled for the particular class in question.
When a class *derived* from a proxy class is created, however, SWIG then
creates an instance of the corresponding C++ director class. The reason
for this difference is that user-defined subclasses may override or
extend methods of the original class, so the director class is needed to
route calls to these methods correctly. For unmodified proxy classes,
all methods are ultimately implemented in C++ so there is no need for
the extra overhead involved with routing the calls through Python.

Ownership and object destruction
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Memory management issues are slightly more complicated with directors
than for proxy classes alone. Python instances hold a pointer to the
associated C++ director object, and the director in turn holds a pointer
back to the Python object. By default, proxy classes own their C++
director object and take care of deleting it when they are garbage
collected.

This relationship can be reversed by calling the special
``__disown__()`` method of the proxy class. After calling this method,
the ``.thisown`` flag is set to zero, and the director class increments
the reference count of the Python object. When the director class is
deleted it decrements the reference count. Assuming no outstanding
references to the Python object remain, the Python object will be
destroyed at the same time. This is a good thing, since directors and
proxies refer to each other and so must be created and destroyed
together. Destroying one without destroying the other will likely cause
your program to segfault.

To help ensure that no references to the Python object remain after
calling ``__disown__()``, this method returns a weak reference to the
Python object. Weak references are only available in Python versions 2.1
and higher, so for older versions you must explicitly delete all
references. Here is an example:

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

      >>> c = FooContainer()
      >>> a = Foo().__disown__()
      >>> c.addFoo(a)
      >>> b = Foo()
      >>> b = b.__disown__()
      >>> c.addFoo(b)
      >>> c.addFoo(Foo().__disown__())

In this example, we are assuming that FooContainer will take care of
deleting all the Foo pointers it contains at some point. Note that no
hard references to the Foo objects remain in Python.

Exception unrolling
~~~~~~~~~~~~~~~~~~~~~~~~~~

With directors routing method calls to Python, and proxies routing them
to C++, the handling of exceptions is an important concern. By default,
the directors ignore exceptions that occur during method calls that are
resolved in Python. To handle such exceptions correctly, it is necessary
to temporarily translate them into C++ exceptions. This can be done with
the %feature("director:except") directive. The following code should
suffice in most cases:

.. container:: code

   ::

      %feature("director:except") {
        if ($error != NULL) {
          throw Swig::DirectorMethodException();
        }
      }

This code will check the Python error state after each method call from
a director into Python, and throw a C++ exception if an error occurred.
This exception can be caught in C++ to implement an error handler.
Currently no information about the Python error is stored in the
Swig::DirectorMethodException object, but this will likely change in the
future.

It may be the case that a method call originates in Python, travels up
to C++ through a proxy class, and then back into Python via a director
method. If an exception occurs in Python at this point, it would be nice
for that exception to find its way back to the original caller. This can
be done by combining a normal %exception directive with the
``director:except`` handler shown above. Here is an example of a
suitable exception handler:

.. container:: code

   ::

      %exception {
        try { $action }
        catch (Swig::DirectorException &e) { SWIG_fail; }
      }

The class Swig::DirectorException used in this example is actually a
base class of Swig::DirectorMethodException, so it will trap this
exception. Because the Python error state is still set when
Swig::DirectorMethodException is thrown, Python will register the
exception as soon as the C wrapper function returns.

Overhead and code bloat
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enabling directors for a class will generate a new director method for
every virtual method in the class' inheritance chain. This alone can
generate a lot of code bloat for large hierarchies. Method arguments
that require complex conversions to and from target language types can
result in large director methods. For this reason it is recommended that
you selectively enable directors only for specific classes that are
likely to be extended in Python and used in C++.

Compared to classes that do not use directors, the call routing in the
director methods does add some overhead. In particular, at least one
dynamic cast and one extra function call occurs per method call from
Python. Relative to the speed of Python execution this is probably
completely negligible. For worst case routing, a method call that
ultimately resolves in C++ may take one extra detour through Python in
order to ensure that the method does not have an extended Python
implementation. This could result in a noticeable overhead in some
cases.

Although directors make it natural to mix native C++ objects with Python
objects (as director objects) via a common base class pointer, one
should be aware of the obvious fact that method calls to Python objects
will be much slower than calls to C++ objects. This situation can be
optimized by selectively enabling director methods (using the %feature
directive) for only those methods that are likely to be extended in
Python.

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

Director typemaps for STL classes are in place, and hence you should be
able to use std::vector, std::string, etc., as you would any other type.

**Note:** The director typemaps for return types based in const
references, such as

.. container:: code

   ::

      class Foo {
      …
        virtual const int& bar();
      …
      };

will work only for simple call scenarios. Usually the resulting code is
neither thread or reentrant safe. Hence, the user is advised to avoid
returning const references in director methods. For example, the user
could modify the method interface to use lvalue return types, wherever
possible, for example

.. container:: code

   ::

      class Foo {
      …
        virtual int bar();
      …
      };

If that is not possible, the user should avoid enabling the director
feature for reentrant, recursive or threaded member methods that return
const references.

Common customization features
----------------------------------

The last section presented the absolute basics of C/C++ wrapping. If you
do nothing but feed SWIG a header file, you will get an interface that
mimics the behavior described. However, sometimes this isn't enough to
produce a nice module. Certain types of functionality might be missing
or the interface to certain functions might be awkward. This section
describes some common SWIG features that are used to improve your the
interface to an extension module.

C/C++ helper functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes when you create a module, it is missing certain bits of
functionality. For example, if you had a function like this

.. container:: code

   ::

      void set_transform(Image *im, double m[4][4]);

it would be accessible from Python, but there may be no easy way to call
it. For example, you might get errors like this:

.. container:: targetlang

   ::

      >>> a = [
      ...   [1, 0, 0, 0],
      ...   [0, 1, 0, 0],
      ...   [0, 0, 1, 0],
      ...   [0, 0, 0, 1]]
      >>> set_transform(im, a)
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      TypeError: Type error. Expected _p_a_4__double

The problem here is that there is no easy way to construct and
manipulate a suitable ``double [4][4]`` value to use. To fix this, you
can write some extra C helper functions. Just use the ``%inline``
directive. For example:

.. container:: code

   ::

      %inline %{
      /* Note: double[4][4] is equivalent to a pointer to an array double (*)[4] */
      double (*new_mat44())[4] {
        return (double (*)[4]) malloc(16*sizeof(double));
      }
      void free_mat44(double (*x)[4]) {
        free(x);
      }
      void mat44_set(double x[4][4], int i, int j, double v) {
        x[i][j] = v;
      }
      double mat44_get(double x[4][4], int i, int j) {
        return x[i][j];
      }
      %}

From Python, you could then write code like this:

.. container:: targetlang

   ::

      >>> a = new_mat44()
      >>> mat44_set(a, 0, 0, 1.0)
      >>> mat44_set(a, 1, 1, 1.0)
      >>> mat44_set(a, 2, 2, 1.0)
      ...
      >>> set_transform(im, a)
      >>>

Admittedly, this is not the most elegant looking approach. However, it
works and it wasn't too hard to implement. It is possible to clean this
up using Python code, typemaps, and other customization features as
covered in later sections.

Adding additional Python code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If writing support code in C isn't enough, it is also possible to write
code in Python. This code gets inserted in to the ``.py`` file created
by SWIG. One use of Python code might be to supply a high-level
interface to certain functions. For example:

.. container:: code

   ::

      void set_transform(Image *im, double x[4][4]);

      ...
      /* Rewrite the high level interface to set_transform */
      %pythoncode %{
      def set_transform(im, x):
          a = new_mat44()
          for i in range(4):
              for j in range(4):
                  mat44_set(a, i, j, x[i][j])
          _example.set_transform(im, a)
          free_mat44(a)
      %}

In this example, ``set_transform()`` provides a high-level Python
interface built on top of low-level helper functions. For example, this
code now seems to work:

.. container:: targetlang

   ::

      >>> a = [
      ...   [1, 0, 0, 0],
      ...   [0, 1, 0, 0],
      ...   [0, 0, 1, 0],
      ...   [0, 0, 0, 1]]
      >>> set_transform(im, a)
      >>>

Admittedly, this whole scheme for wrapping the two-dimension array
argument is rather ad-hoc. Besides, shouldn't a Python list or a Numeric
Python array just work normally? We'll get to those examples soon
enough. For now, think of this example as an illustration of what can be
done without having to rely on any of the more advanced customization
features.

There is also ``%pythonbegin`` which is another directive very similar
to ``%pythoncode``, but generates the given Python code at the beginning
of the ``.py`` file. This directive works in the same way as
``%pythoncode``, except the code is copied just after the SWIG banner
(comment) at the top of the file, before any real code. This provides an
opportunity to add your own description in a comment near the top of the
file as well as Python imports that have to appear at the top of the
file, such as "``from __future__ import``" statements.

The following example for Python 2.x shows how to insert code into the
generated wrapper to enable ``print`` to be used as a Python3-compatible
function instead of a statement:

.. container:: code

   ::

      %pythonbegin %{
      # This module provides wrappers to the Whizz Bang library
      %}

      %pythonbegin %{
      from __future__ import print_function
      print("Loading", "Whizz", "Bang", sep=' ... ')
      %}

The insert code can be seen at the start of the generated ``.py`` file:

.. container:: code

   ::

      # This file was automatically generated by SWIG (http://www.swig.org).
      # Version 4.0.0
      #
      # Do not make changes to this file unless you know what you are doing--modify
      # the SWIG interface file instead.

      # This module provides wrappers to the Whizz Bang library

      from __future__ import print_function
      print("Loading", "Whizz", "Bang", sep=' ... ')

When using ``%pythoncode`` and ``%pythonbegin`` you generally want to
make sure that the block is delimited by ``%{`` and ``%}``. If you
delimit it with ``{`` and ``}`` then any lines with a leading ``#`` will
be handled by SWIG as preprocessor directives, when you probably meant
them as Python comments. Prior to SWIG 3.0.3, invalid preprocessor
directives were silently ignored, so generally using the wrong
delimiters resulted in such comments not appearing in the generated
output (though a comment starting with a valid preprocessor directive
could cause problems, for example: ``# error handling``). SWIG 3.0.3 and
later report an error for invalid preprocessor directives, so you may
have to update existing interface files to delimit blocks of Python code
correctly.

As an alternative to providing a block containing Python code, you can
include Python code from a file. The code is inserted exactly as in the
file, so this avoids any issues with the SWIG preprocessor. It's a good
approach if you have a non-trivial chunk of Python code to insert. To
use this feature you specify a filename in double quotes, for example:

.. container:: code

   ::

      %pythoncode "somecode.py"

Sometimes you may want to replace or modify the wrapper function that
SWIG creates in the proxy ``.py`` file. The Python module in SWIG
provides some features that enable you to do this. First, to entirely
replace a proxy function you can use ``%feature("shadow")``. For
example:

.. container:: code

   ::

      %module example

      // Rewrite bar() Python code

      %feature("shadow") Foo::bar(int) %{
      def bar(*args):
          #do something before
          $action
          #do something after
      %}

      class Foo {
      public:
        int bar(int x);
      };

where ``$action`` will be replaced by the call to the C/C++ proper
method.

Often the proxy function created by SWIG is fine, but you simply want to
add code to it without touching the rest of the generated function body.
For these cases SWIG provides the ``pythonprepend`` and ``pythonappend``
features which do exactly as their names suggest. The ``pythonprepend``
feature will insert its value at the beginning of the proxy function,
and ``pythonappend`` will insert code at the end of the proxy, just
before the return statement.

.. container:: code

   ::

      %module example

      // Add Python code to bar()

      %feature("pythonprepend") Foo::bar(int) %{
          #do something before C++ call
      %}

      %feature("pythonappend") Foo::bar(int) %{
          #do something after C++ call
          #the 'val' variable holds the return value
      %}


      class Foo {
      public:
        int bar(int x);
      };

Notes: Usually the ``pythonappend`` and ``pythonprepend`` features are
safer to use than the ``shadow`` feature. Also, from SWIG version 1.3.28
you can use the directive forms ``%pythonappend`` and ``%pythonprepend``
as follows:

.. container:: code

   ::

      %module example

      // Add Python code to bar()

      %pythonprepend Foo::bar(int) %{
          #do something before C++ call
      %}

      %pythonappend Foo::bar(int) %{
          #do something after C++ call
          #the 'val' variable holds the return value
      %}


      class Foo {
      public:
        int bar(int x);
      };

Note that when the underlying C++ method is overloaded, there is only
one proxy Python method for multiple C++ methods. In this case, only one
of parsed methods is examined for the feature. You are better off
specifying the feature without the argument list to ensure it will get
used, as it will then get attached to all the overloaded C++ methods.
For example:

.. container:: code

   ::

      %module example

      // Add Python code to bar()

      %pythonprepend Foo::bar %{
          #do something before C++ call
      %}

      %pythonappend Foo::bar %{
          #do something after C++ call
      %}


      class Foo {
      public:
        int bar(int x);
        int bar();
      };

The same applies for overloaded constructors.

Class extension with %extend
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

One of the more interesting features of SWIG is that it can extend
structures and classes with new methods--at least in the Python
interface. Here is a simple example:

.. container:: code

   ::

      %module example
      %{
      #include "someheader.h"
      %}

      struct Vector {
        double x, y, z;
      };

      %extend Vector {
        char *__str__() {
          static char tmp[1024];
          sprintf(tmp, "Vector(%g, %g, %g)", $self->x, $self->y, $self->z);
          return tmp;
        }
        Vector(double x, double y, double z) {
          Vector *v = (Vector *) malloc(sizeof(Vector));
          v->x = x;
          v->y = y;
          v->z = z;
          return v;
        }
      };

Now, in Python

.. container:: targetlang

   ::

      >>> v = example.Vector(2, 3, 4)
      >>> print v
      Vector(2, 3, 4)
      >>>

``%extend`` can be used for many more tasks than this. For example, if
you wanted to overload a Python operator, you might do this:

.. container:: code

   ::

      %extend Vector {
        Vector __add__(Vector *other) {
          Vector v;
          v.x = $self->x + other->x;
          v.y = $self->y + other->y;
          v.z = $self->z + other->z;
          return v;
        }
      };

Use it like this:

.. container:: targetlang

   ::

      >>> import example
      >>> v = example.Vector(2, 3, 4)
      >>> w = example.Vector(10, 11, 12)
      >>> print v+w
      Vector(12, 14, 16)
      >>>

``%extend`` works with both C and C++ code. It does not modify the
underlying object in any way---the extensions only show up in the Python
interface.

Exception handling with %exception
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If a C or C++ function throws an error, you may want to convert that
error into a Python exception. To do this, you can use the
``%exception`` directive. ``%exception`` simply lets you rewrite part of
the generated wrapper code to include an error check.

In C, a function often indicates an error by returning a status code (a
negative number or a NULL pointer perhaps). Here is a simple example of
how you might handle that:

.. container:: code

   ::

      %exception malloc {
        $action
        if (!result) {
          PyErr_SetString(PyExc_MemoryError, "Not enough memory");
          SWIG_fail;
        }
      }
      void *malloc(size_t nbytes);

In Python,

.. container:: targetlang

   ::

      >>> a = example.malloc(2000000000)
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      MemoryError: Not enough memory
      >>>

If a library provides some kind of general error handling framework, you
can also use that. For example:

.. container:: code

   ::

      %exception {
        $action
        if (err_occurred()) {
          PyErr_SetString(PyExc_RuntimeError, err_message());
          SWIG_fail;
        }
      }

No declaration name is given to ``%exception``, it is applied to all
wrapper functions.

C++ exceptions are also easy to handle. For example, you can write code
like this:

.. container:: code

   ::

      %exception getitem {
        try {
          $action
        } catch (std::out_of_range &e) {
          PyErr_SetString(PyExc_IndexError, const_cast<char*>(e.what()));
          SWIG_fail;
        }
      }

      class Base {
      public:
        Foo *getitem(int index);      // Exception handled added
        ...
      };

When raising a Python exception from C, use the ``PyErr_SetString()``
function as shown above followed by ``SWIG_fail``. The following
exception types can be used as the first argument.

.. container:: code

   ::

      PyExc_ArithmeticError
      PyExc_AssertionError
      PyExc_AttributeError
      PyExc_EnvironmentError
      PyExc_EOFError
      PyExc_Exception
      PyExc_FloatingPointError
      PyExc_ImportError
      PyExc_IndexError
      PyExc_IOError
      PyExc_KeyError
      PyExc_KeyboardInterrupt
      PyExc_LookupError
      PyExc_MemoryError
      PyExc_NameError
      PyExc_NotImplementedError
      PyExc_OSError
      PyExc_OverflowError
      PyExc_RuntimeError
      PyExc_StandardError
      PyExc_SyntaxError
      PyExc_SystemError
      PyExc_TypeError
      PyExc_UnicodeError
      PyExc_ValueError
      PyExc_ZeroDivisionError

``SWIG_fail`` is a C macro which when called within the context of SWIG
wrapper function, will jump to the error handler code. This will call
any cleanup code (freeing any temp variables) and then return from the
wrapper function so that the Python interpreter can raise the Python
exception. This macro should always be called after setting a Python
error in code snippets, such as typemaps and ``%exception``, that are
ultimately generated into the wrapper function.

The language-independent ``exception.i`` library file can also be used
to raise exceptions. See the `SWIG Library <Library.html#Library>`__
chapter.

Optimization options
~~~~~~~~~~~~~~~~~~~~~~~~~~~

-fastproxy
^^^^^^^^^^^^^^^^^^^

The ``-fastproxy`` command line option enables faster method calling as
the call is made directly into the C/C++ layer rather than going through
a method wrapper.

Consider wrapping a C++ class:

.. container:: code

   ::

      struct Go {
        void callme0() {}
        void callme4(int a, int b, int c, int d) {}
        void callme8(double a, double b, double c, double d, double e, double f, double g, double i) {}
      };

The default generated proxy class is:

.. container:: targetlang

   ::

      class Go(object):
          def callme0(self):
              return _example.Go_callme0(self)

          def callme4(self, a, b, c, d):
              return _example.Go_callme4(self, a, b, c, d)

          def callme8(self, a, b, c, d, e, f, g, i):
              return _example.Go_callme8(self, a, b, c, d, e, f, g, i)
          ...

Each method in the Python class contains a Python proxy method which
passes the arguments on to the underlying function in the low-level
C/C++ module (_example in this case). The generated proxy class when
using ``-fastproxy`` is:

.. container:: targetlang

   ::

      %module example
      class Go(object):
          callme0 = _swig_new_instance_method(_example.Go_callme0)
          callme4 = _swig_new_instance_method(_example.Go_callme4)
          callme8 = _swig_new_instance_method(_example.Go_callme8)
          ...

where ``_swig_new_instance_method`` adds the method to the proxy class
via C API calls for direct access to the underlying function in the
low-level C/C++ module. Note that for some methods it is not possible to
generate the direct access call and so ``-fastproxy`` is ignored. This
happens, for example, when adding `additional code <#Python_nn42>`__ to
Python proxy methods, such as using ``%pythonprepend``.

The overhead calling into C/C++ from Python is reduced slightly using
``-fastproxy``. Below are some timings in microseconds calling the 3
functions in the example above. Also included in the table for
comparison is using the ``-builtin`` option covered in the `Built-in
Types <#Python_builtin_types>`__.

=========== ======= ========== ========
Method name Default -fastproxy -builtin
=========== ======= ========== ========
callme0     0.15    0.09       0.07
callme4     0.26    0.16       0.14
callme8     0.32    0.20       0.17
=========== ======= ========== ========

Although the ``-fastproxy`` option results in faster code over the
default, the generated proxy code is not as user-friendly as
docstring/doxygen comments and functions with default values are not
visible in the generated Python proxy class. The ``-olddefs`` option can
rectify this.

The generated proxy class for the example above when using
``-fastproxy -olddefs`` is:

.. container:: targetlang

   ::

      class Go(object):
          def callme0(self):
              return _example.Go_callme0(self)
          callme0 = _swig_new_instance_method(_example.Go_callme0)

          def callme4(self, a, b, c, d):
              return _example.Go_callme4(self, a, b, c, d)
          callme4 = _swig_new_instance_method(_example.Go_callme4)

          def callme8(self, a, b, c, d, e, f, g, i):
              return _example.Go_callme8(self, a, b, c, d, e, f, g, i)
          callme8 = _swig_new_instance_method(_example.Go_callme8)
          ...

The class defines each method in two different ways. The first
definition is replaced by the second definition and so the second
definition is the one used when the method is called. While this
possibly provides the best of both worlds, the time to import the module
will be slightly slower when the class is defined due to the additional
method definitions.

The command line options mentioned above also apply to wrapped C/C++
global functions, not just class methods.

Tips and techniques
------------------------

Although SWIG is largely automatic, there are certain types of wrapping
problems that require additional user input. Examples include dealing
with output parameters, strings, binary data, and arrays. This chapter
discusses the common techniques for solving these problems.

Input and output parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A common problem in some C programs is handling parameters passed as
simple pointers. For example:

.. container:: code

   ::

      void add(int x, int y, int *result) {
        *result = x + y;
      }

or perhaps

.. container:: code

   ::

      int sub(int *x, int *y) {
        return *x-*y;
      }

The easiest way to handle these situations is to use the ``typemaps.i``
file. For example:

.. container:: code

   ::

      %module example
      %include "typemaps.i"

      void add(int, int, int *OUTPUT);
      int  sub(int *INPUT, int *INPUT);

In Python, this allows you to pass simple values. For example:

.. container:: targetlang

   ::

      >>> a = add(3, 4)
      >>> print a
      7
      >>> b = sub(7, 4)
      >>> print b
      3
      >>>

Notice how the ``INPUT`` parameters allow integer values to be passed
instead of pointers and how the ``OUTPUT`` parameter creates a return
result.

If you don't want to use the names ``INPUT`` or ``OUTPUT``, use the
``%apply`` directive. For example:

.. container:: code

   ::

      %module example
      %include "typemaps.i"

      %apply int *OUTPUT { int *result };
      %apply int *INPUT  { int *x, int *y};

      void add(int x, int y, int *result);
      int  sub(int *x, int *y);

If a function mutates one of its parameters like this,

.. container:: code

   ::

      void negate(int *x) {
        *x = -(*x);
      }

you can use ``INOUT`` like this:

.. container:: code

   ::

      %include "typemaps.i"
      ...
      void negate(int *INOUT);

In Python, a mutated parameter shows up as a return value. For example:

.. container:: targetlang

   ::

      >>> a = negate(3)
      >>> print a
      -3
      >>>

Note: Since most primitive Python objects are immutable, it is not
possible to perform in-place modification of a Python object passed as a
parameter.

The most common use of these special typemap rules is to handle
functions that return more than one value. For example, sometimes a
function returns a result as well as a special error code:

.. container:: code

   ::

      /* send message, return number of bytes sent, along with success code */
      int send_message(char *text, int len, int *success);

To wrap such a function, simply use the ``OUTPUT`` rule above. For
example:

.. container:: code

   ::

      %module example
      %include "typemaps.i"
      %apply int *OUTPUT { int *success };
      ...
      int send_message(char *text, int *success);

When used in Python, the function will return multiple values.

.. container:: targetlang

   ::

      bytes, success = send_message("Hello World")
      if not success:
          print "Whoa!"
      else:
          print "Sent", bytes

Another common use of multiple return values are in query functions. For
example:

.. container:: code

   ::

      void get_dimensions(Matrix *m, int *rows, int *columns);

To wrap this, you might use the following:

.. container:: code

   ::

      %module example
      %include "typemaps.i"
      %apply int *OUTPUT { int *rows, int *columns };
      ...
      void get_dimensions(Matrix *m, int *rows, *columns);

Now, in Python:

.. container:: targetlang

   ::

      >>> r, c = get_dimensions(m)

Be aware that the primary purpose of the ``typemaps.i`` file is to
support primitive datatypes. Writing a function like this

.. container:: code

   ::

      void foo(Bar *OUTPUT);

may not have the intended effect since ``typemaps.i`` does not define an
OUTPUT rule for ``Bar``.

Simple pointers
~~~~~~~~~~~~~~~~~~~~~~

If you must work with simple pointers such as ``int *`` or ``double *``
and you don't want to use ``typemaps.i``, consider using the
``cpointer.i`` library file. For example:

.. container:: code

   ::

      %module example
      %include "cpointer.i"

      %inline %{
      extern void add(int x, int y, int *result);
      %}

      %pointer_functions(int, intp);

The ``%pointer_functions(type, name)`` macro generates five helper
functions that can be used to create, destroy, copy, assign, and
dereference a pointer. In this case, the functions are as follows:

.. container:: code

   ::

      int  *new_intp();
      int  *copy_intp(int *x);
      void  delete_intp(int *x);
      void  intp_assign(int *x, int value);
      int   intp_value(int *x);

In Python, you would use the functions like this:

.. container:: targetlang

   ::

      >>> result = new_intp()
      >>> print result
      _108fea8_p_int
      >>> add(3, 4, result)
      >>> print intp_value(result)
      7
      >>>

If you replace ``%pointer_functions()`` by
``%pointer_class(type, name)``, the interface is more class-like.

.. container:: targetlang

   ::

      >>> result = intp()
      >>> add(3, 4, result)
      >>> print result.value()
      7

See the `SWIG Library <Library.html#Library>`__ chapter for further
details.

Unbounded C Arrays
~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes a C function expects an array to be passed as a pointer. For
example,

.. container:: code

   ::

      int sumitems(int *first, int nitems) {
        int i, sum = 0;
        for (i = 0; i < nitems; i++) {
          sum += first[i];
        }
        return sum;
      }

To wrap this into Python, you need to pass an array pointer as the first
argument. A simple way to do this is to use the ``carrays.i`` library
file. For example:

.. container:: code

   ::

      %include "carrays.i"
      %array_class(int, intArray);

The ``%array_class(type, name)`` macro creates wrappers for an unbounded
array object that can be passed around as a simple pointer like
``int *`` or ``double *``. For instance, you will be able to do this in
Python:

.. container:: targetlang

   ::

      >>> a = intArray(10000000)         # Array of 10-million integers
      >>> for i in xrange(10000):        # Set some values
      ...     a[i] = i
      >>> sumitems(a, 10000)
      49995000
      >>>

The array "object" created by ``%array_class()`` does not encapsulate
pointers inside a special array object. In fact, there is no bounds
checking or safety of any kind (just like in C). Because of this, the
arrays created by this library are extremely low-level indeed. You can't
iterate over them nor can you even query their length. In fact, any
valid memory address can be accessed if you want (negative indices,
indices beyond the end of the array, etc.). Needless to say, this
approach is not going to suit all applications. On the other hand, this
low-level approach is extremely efficient and well suited for
applications in which you need to create buffers, package binary data,
etc.

String handling
~~~~~~~~~~~~~~~~~~~~~~

If a C function has an argument of ``char *``, then a Python string can
be passed as input. For example:

.. container:: code

   ::

      // C
      void foo(char *s);

.. container:: targetlang

   ::

      # Python
      >>> foo("Hello")

When a Python string is passed as a parameter, the C function receives a
pointer to the raw data contained in the string. Since Python strings
are immutable, it is illegal for your program to change the value. In
fact, doing so will probably crash the Python interpreter.

If your program modifies the input parameter or uses it to return data,
consider using the ``cstring.i`` library file described in the `SWIG
Library <Library.html#Library>`__ chapter.

When functions return a ``char *``, it is assumed to be a
NULL-terminated string. Data is copied into a new Python string and
returned.

If your program needs to work with binary data, you can use a typemap to
expand a Python string into a pointer/length argument pair. As luck
would have it, just such a typemap is already defined. Just do this:

.. container:: code

   ::

      %apply (char *STRING, int LENGTH) { (char *data, int size) };
      ...
      int parity(char *data, int size, int initial);

Now in Python:

.. container:: targetlang

   ::

      >>> parity("e\x09ffss\x00\x00\x01\nx", 0)

If you need to return binary data, you might use the ``cstring.i``
library file. The ``cdata.i`` library can also be used to extra binary
data from arbitrary pointers.

Default arguments
~~~~~~~~~~~~~~~~~~~~~~~~

C++ default argument code generation is documented in the main `Default
arguments <SWIGPlus.html#SWIGPlus_default_args>`__ section. There is
also an optional Python specific feature that can be used called the
``python:cdefaultargs`` `feature
flag <Customization.html#Customization_feature_flags>`__. By default,
SWIG attempts to convert C++ default argument values into Python values
and generates code into the Python layer containing these values. For
example:

.. container:: code

   ::

      struct CDA {
        int fff(int a = 1, bool b = false);
      };

From Python this can be called as follows:

.. container:: targetlang

   ::

      >>> CDA().fff()        # C++ layer receives a=1 and b=false
      >>> CDA().fff(2)       # C++ layer receives a=2 and b=false
      >>> CDA().fff(3, True) # C++ layer receives a=3 and b=true

The default code generation in the Python layer is:

.. container:: targetlang

   ::

      class CDA(object):
          ...
          def fff(self, a=1, b=False):
              return _default_args.CDA_fff(self, a, b)

Adding the feature:

.. container:: code

   ::

      %feature("python:cdefaultargs") CDA::fff;
      struct CDA {
        int fff(int a = 1, bool b = false);

results in identical behaviour when called from Python, however, it
results in different code generation:

.. container:: targetlang

   ::

      class CDA(object):
          ...
          def fff(self, *args):
              return _default_args.CDA_fff(self, *args)

The default arguments are obtained in the C++ wrapper layer instead of
the Python layer. Some code generation modes are quite different, eg
``-builtin`` and ``-fastproxy``, and are unaffected by
``python:cdefaultargs`` as the default values are always obtained from
the C++ layer.

Note that not all default arguments can be converted into a Python
equivalent. When SWIG does not convert them, it will generate code to
obtain them from the C++ layer as if ``python:cdefaultargs`` was
specified. This will happen if just one argument cannot be converted
into a Python equivalent. This occurs typically when the argument is not
fully numeric, such as ``int(1)``:

.. container:: code

   ::

      struct CDA {
        int fff(int a = int(1), bool b = false);
      };

**Compatibility Note:** SWIG-3.0.6 introduced the
``python:cdefaultargs`` feature. Versions of SWIG prior to this varied
in their ability to convert C++ default values into equivalent Python
default argument values.

.. _typemaps-1:

Typemaps
-------------

This section describes how you can modify SWIG's default wrapping
behavior for various C/C++ datatypes using the ``%typemap`` directive.
This is an advanced topic that assumes familiarity with the Python C API
as well as the material in the "`Typemaps <Typemaps.html#Typemaps>`__"
chapter.

Before proceeding, it should be stressed that typemaps are not a
required part of using SWIG---the default wrapping behavior is enough in
most cases. Typemaps are only used if you want to change some aspect of
the primitive C-Python interface or if you want to elevate your guru
status.

What is a typemap?
~~~~~~~~~~~~~~~~~~~~~~~~~

A typemap is nothing more than a code generation rule that is attached
to a specific C datatype. For example, to convert integers from Python
to C, you might define a typemap like this:

.. container:: code

   ::

      %module example

      %typemap(in) int {
        $1 = (int) PyLong_AsLong($input);
        printf("Received an integer : %d\n", $1);
      }
      %inline %{
      extern int fact(int n);
      %}

Typemaps are always associated with some specific aspect of code
generation. In this case, the "in" method refers to the conversion of
input arguments to C/C++. The datatype ``int`` is the datatype to which
the typemap will be applied. The supplied C code is used to convert
values. In this code a number of special variable prefaced by a ``$``
are used. The ``$1`` variable is placeholder for a local variable of
type ``int``. The ``$input`` variable is the input object of type
``PyObject *``.

When this example is compiled into a Python module, it operates as
follows:

.. container:: targetlang

   ::

      >>> from example import *
      >>> fact(6)
      Received an integer : 6
      720

In this example, the typemap is applied to all occurrences of the
``int`` datatype. You can refine this by supplying an optional parameter
name. For example:

.. container:: code

   ::

      %module example

      %typemap(in) int nonnegative {
        $1 = (int) PyLong_AsLong($input);
        if ($1 < 0) {
          PyErr_SetString(PyExc_ValueError, "Expected a nonnegative value.");
          SWIG_fail;
        }
      }
      %inline %{
      extern int fact(int nonnegative);
      %}

In this case, the typemap code is only attached to arguments that
exactly match ``int nonnegative``.

The application of a typemap to specific datatypes and argument names
involves more than simple text-matching--typemaps are fully integrated
into the SWIG C++ type-system. When you define a typemap for ``int``,
that typemap applies to ``int`` and qualified variations such as
``const int``. In addition, the typemap system follows ``typedef``
declarations. For example:

.. container:: code

   ::

      %typemap(in) int n {
        $1 = (int) PyLong_AsLong($input);
        printf("n = %d\n", $1);
      }
      %inline %{
      typedef int Integer;
      extern int fact(Integer n);    // Above typemap is applied
      %}

Typemaps can also be defined for groups of consecutive arguments. For
example:

.. container:: code

   ::

      %typemap(in) (char *str, int len) {
        $1 = PyString_AsString($input);
        $2 = PyString_Size($input);
      };

      int count(char c, char *str, int len);

When a multi-argument typemap is defined, the arguments are always
handled as a single Python object. This allows the function to be used
like this (notice how the length parameter is omitted):

.. container:: targetlang

   ::

      >>> example.count('e', 'Hello World')
      1
      >>>

Python typemaps
~~~~~~~~~~~~~~~~~~~~~~

The previous section illustrated an "in" typemap for converting Python
objects to C. A variety of different typemap methods are defined by the
Python module. For example, to convert a C integer back into a Python
object, you might define an "out" typemap like this:

.. container:: code

   ::

      %typemap(out) int {
          $result = PyInt_FromLong((long) $1);
      }

A detailed list of available methods can be found in the
"`Typemaps <Typemaps.html#Typemaps>`__" chapter.

However, the best source of typemap information (and examples) is
probably the Python module itself. In fact, all of SWIG's default type
handling is defined by typemaps. You can view these typemaps by looking
at the files in the SWIG library. Just take into account that in the
latest versions of swig (1.3.22+), the library files are not very
pristine clear for the casual reader, as they used to be. The extensive
use of macros and other ugly techniques in the latest version produce a
very powerful and consistent Python typemap library, but at the cost of
simplicity and pedagogic value.

To learn how to write a simple or your first typemap, you better take a
look at the SWIG library version 1.3.20 or so.

Typemap variables
~~~~~~~~~~~~~~~~~~~~~~~~

Within typemap code, a number of special variables prefaced with a ``$``
may appear. A full list of variables can be found in the
"`Typemaps <Typemaps.html#Typemaps>`__" chapter. This is a list of the
most common variables:

``$1``

.. container:: indent

   A C local variable corresponding to the actual type specified in the
   ``%typemap`` directive. For input values, this is a C local variable
   that's supposed to hold an argument value. For output values, this is
   the raw result that's supposed to be returned to Python.

``$input``

.. container:: indent

   A ``PyObject *`` holding a raw Python object with an argument or
   variable value.

``$result``

.. container:: indent

   A ``PyObject *`` that holds the result to be returned to Python.

``$1_name``

.. container:: indent

   The parameter name that was matched.

``$1_type``

.. container:: indent

   The actual C datatype matched by the typemap.

``$1_ltype``

.. container:: indent

   An assignable version of the datatype matched by the typemap (a type
   that can appear on the left-hand-side of a C assignment operation).
   This type is stripped of qualifiers and may be an altered version of
   ``$1_type``. All arguments and local variables in wrapper functions
   are declared using this type so that their values can be properly
   assigned.

``$symname``

.. container:: indent

   The Python name of the wrapper function being created.

Useful Python Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When you write a typemap, you usually have to work directly with Python
objects. The following functions may prove to be useful.

**Python Integer Functions**

.. container:: code

   ::

      PyObject *PyInt_FromLong(long l);
      long      PyInt_AsLong(PyObject *);
      int       PyInt_Check(PyObject *);

**Python Floating Point Functions**

.. container:: code

   ::

      PyObject *PyFloat_FromDouble(double);
      double    PyFloat_AsDouble(PyObject *);
      int       PyFloat_Check(PyObject *);

**Python String Functions**

.. container:: code

   ::

      PyObject *PyString_FromString(char *);
      PyObject *PyString_FromStringAndSize(char *, lint len);
      int       PyString_Size(PyObject *);
      char     *PyString_AsString(PyObject *);
      int       PyString_Check(PyObject *);

**Python List Functions**

.. container:: code

   ::

      PyObject *PyList_New(int size);
      int       PyList_Size(PyObject *list);
      PyObject *PyList_GetItem(PyObject *list, int i);
      int       PyList_SetItem(PyObject *list, int i, PyObject *item);
      int       PyList_Insert(PyObject *list, int i, PyObject *item);
      int       PyList_Append(PyObject *list, PyObject *item);
      PyObject *PyList_GetSlice(PyObject *list, int i, int j);
      int       PyList_SetSlice(PyObject *list, int i, int , PyObject *list2);
      int       PyList_Sort(PyObject *list);
      int       PyList_Reverse(PyObject *list);
      PyObject *PyList_AsTuple(PyObject *list);
      int       PyList_Check(PyObject *);

**Python Tuple Functions**

.. container:: code

   ::

      PyObject *PyTuple_New(int size);
      int       PyTuple_Size(PyObject *);
      PyObject *PyTuple_GetItem(PyObject *, int i);
      int       PyTuple_SetItem(PyObject *, int i, PyObject *item);
      PyObject *PyTuple_GetSlice(PyObject *t, int i, int j);
      int       PyTuple_Check(PyObject *);

**Python Dictionary Functions**

.. container:: code

   ::

      PyObject *PyDict_New();
      int       PyDict_Check(PyObject *);
      int       PyDict_SetItem(PyObject *p, PyObject *key, PyObject *val);
      int       PyDict_SetItemString(PyObject *p, const char *key, PyObject *val);
      int       PyDict_DelItem(PyObject *p, PyObject *key);
      int       PyDict_DelItemString(PyObject *p, char *key);
      PyObject* PyDict_Keys(PyObject *p);
      PyObject* PyDict_Values(PyObject *p);
      PyObject* PyDict_GetItem(PyObject *p, PyObject *key);
      PyObject* PyDict_GetItemString(PyObject *p, const char *key);
      int       PyDict_Next(PyObject *p, Py_ssize_t *ppos, PyObject **pkey, PyObject **pvalue);
      Py_ssize_t PyDict_Size(PyObject *p);
      int       PyDict_Update(PyObject *a, PyObject *b);
      int       PyDict_Merge(PyObject *a, PyObject *b, int override);
      PyObject* PyDict_Items(PyObject *p);

**Python File Conversion Functions**

.. container:: code

   ::

      PyObject *PyFile_FromFile(FILE *f);
      FILE     *PyFile_AsFile(PyObject *);
      int       PyFile_Check(PyObject *);

**Abstract Object Interface**

.. container:: code

   ::

      write me

Typemap Examples
---------------------

This section includes a few examples of typemaps. For more examples, you
might look at the files "``python.swg``" and "``typemaps.i``" in the
SWIG library.

Converting Python list to a char \*\*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A common problem in many C programs is the processing of command line
arguments, which are usually passed in an array of NULL terminated
strings. The following SWIG interface file allows a Python list object
to be used as a ``char **`` object.

.. container:: code

   ::

      %module argv

      // This tells SWIG to treat char ** as a special case
      %typemap(in) char ** {
        /* Check if is a list */
        if (PyList_Check($input)) {
          int size = PyList_Size($input);
          int i = 0;
          $1 = (char **) malloc((size+1)*sizeof(char *));
          for (i = 0; i < size; i++) {
            PyObject *o = PyList_GetItem($input, i);
            if (PyString_Check(o)) {
              $1[i] = PyString_AsString(PyList_GetItem($input, i));
            } else {
              free($1);
              PyErr_SetString(PyExc_TypeError, "list must contain strings");
              SWIG_fail;
            }
          }
          $1[i] = 0;
        } else {
          PyErr_SetString(PyExc_TypeError, "not a list");
          SWIG_fail;
        }
      }

      // This cleans up the char ** array we malloc'd before the function call
      %typemap(freearg) char ** {
        free((char *) $1);
      }

      // Now a test function
      %inline %{
      int print_args(char **argv) {
        int i = 0;
        while (argv[i]) {
          printf("argv[%d] = %s\n", i, argv[i]);
          i++;
        }
        return i;
      }
      %}

When this module is compiled, the wrapped C function now operates as
follows :

.. container:: targetlang

   ::

      >>> from argv import *
      >>> print_args(["Dave", "Mike", "Mary", "Jane", "John"])
      argv[0] = Dave
      argv[1] = Mike
      argv[2] = Mary
      argv[3] = Jane
      argv[4] = John
      5

In the example, two different typemaps are used. The "in" typemap is
used to receive an input argument and convert it to a C array. Since
dynamic memory allocation is used to allocate memory for the array, the
"freearg" typemap is used to later release this memory after the
execution of the C function.

Expanding a Python object into multiple arguments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Suppose that you had a collection of C functions with arguments such as
the following:

.. container:: code

   ::

      int foo(int argc, char **argv);

In the previous example, a typemap was written to pass a Python list as
the ``char **argv``. This allows the function to be used from Python as
follows:

.. container:: targetlang

   ::

      >>> foo(4, ["foo", "bar", "spam", "1"])

Although this works, it's a little awkward to specify the argument
count. To fix this, a multi-argument typemap can be defined. This is not
very difficult--you only have to make slight modifications to the
previous example:

.. container:: code

   ::

      %typemap(in) (int argc, char **argv) {
        /* Check if is a list */
        if (PyList_Check($input)) {
          int i;
          $1 = PyList_Size($input);
          $2 = (char **) malloc(($1+1)*sizeof(char *));
          for (i = 0; i < $1; i++) {
            PyObject *o = PyList_GetItem($input, i);
            if (PyString_Check(o)) {
              $2[i] = PyString_AsString(PyList_GetItem($input, i));
            } else {
              free($2);
              PyErr_SetString(PyExc_TypeError, "list must contain strings");
              SWIG_fail;
            }
          }
          $2[i] = 0;
        } else {
          PyErr_SetString(PyExc_TypeError, "not a list");
          SWIG_fail;
        }
      }

      %typemap(freearg) (int argc, char **argv) {
        free((char *) $2);
      }

When writing a multiple-argument typemap, each of the types is
referenced by a variable such as ``$1`` or ``$2``. The typemap code
simply fills in the appropriate values from the supplied Python object.

With the above typemap in place, you will find it no longer necessary to
supply the argument count. This is automatically set by the typemap
code. For example:

.. container:: targetlang

   ::

      >>> foo(["foo", "bar", "spam", "1"])

If your function is overloaded in C++, for example:

.. container:: code

   ::

      int foo(int argc, char **argv);
      int foo();

don't forget to also provide a suitable `typecheck typemap for
overloading <Typemaps.html#Typemaps_overloading>`__ such as:

.. container:: code

   ::

      %typecheck(SWIG_TYPECHECK_STRING_ARRAY) (int argc, char **argv) {
        $1 = PyList_Check($input) ? 1 : 0;
      }

If you don't you'll get an error message along the lines of:

.. container:: shell

   ::

      Traceback (most recent call last):
        File "runme.py", line 3, in >module<
          example.foo(["foo", "bar", "spam", "1"])
      TypeError: Wrong number or type of arguments for overloaded function 'foo'.
        Possible C/C++ prototypes are:
          foo(int, char **)
          foo()

Using typemaps to return arguments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A common problem in some C programs is that values may be returned in
arguments rather than in the return value of a function. For example:

.. container:: code

   ::

      /* Returns a status value and two values in out1 and out2 */
      int spam(double a, double b, double *out1, double *out2) {
        ... Do a bunch of stuff ...
        *out1 = result1;
        *out2 = result2;
        return status;
      }

A typemap can be used to handle this case as follows :

.. container:: code

   ::

      %module outarg

      // This tells SWIG to treat an double * argument with name 'OutValue' as
      // an output value.  We'll append the value to the current result which
      // is guaranteed to be a List object by SWIG.

      %typemap(argout) double *OutValue {
        PyObject *o, *o2, *o3;
        o = PyFloat_FromDouble(*$1);
        if ((!$result) || ($result == Py_None)) {
          $result = o;
        } else {
          if (!PyTuple_Check($result)) {
            PyObject *o2 = $result;
            $result = PyTuple_New(1);
            PyTuple_SetItem($result, 0, o2);
          }
          o3 = PyTuple_New(1);
          PyTuple_SetItem(o3, 0, o);
          o2 = $result;
          $result = PySequence_Concat(o2, o3);
          Py_DECREF(o2);
          Py_DECREF(o3);
        }
      }

      int spam(double a, double b, double *OutValue, double *OutValue);

The typemap works as follows. First, a check is made to see if any
previous result exists. If so, it is turned into a tuple and the new
output value is concatenated to it. Otherwise, the result is returned
normally. For the sample function ``spam()``, there are three output
values--meaning that the function will return a 3-tuple of the results.

As written, the function must accept 4 arguments as input values, last
two being pointers to doubles. If these arguments are only used to hold
output values (and have no meaningful input value), an additional
typemap can be written. For example:

.. container:: code

   ::

      %typemap(in, numinputs=0) double *OutValue(double temp) {
        $1 = &temp;
      }

By specifying numinputs=0, the input value is ignored. However, since
the argument still has to be set to some meaningful value before calling
C, it is set to point to a local variable ``temp``. When the function
stores its output value, it will simply be placed in this local
variable. As a result, the function can now be used as follows:

.. container:: targetlang

   ::

      >>> a = spam(4, 5)
      >>> print a
      (0, 2.45, 5.0)
      >>> x, y, z = spam(4, 5)
      >>>

Mapping Python tuples into small arrays
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In some applications, it is sometimes desirable to pass small arrays of
numbers as arguments. For example :

.. container:: code

   ::

      extern void set_direction(double a[4]);       // Set direction vector

This too, can be handled used typemaps as follows :

.. container:: code

   ::

      // Grab a 4 element array as a Python 4-tuple
      %typemap(in) double[4](double temp[4]) {   // temp[4] becomes a local variable
        int i;
        if (PyTuple_Check($input)) {
          if (!PyArg_ParseTuple($input, "dddd", temp, temp+1, temp+2, temp+3)) {
            PyErr_SetString(PyExc_TypeError, "tuple must have 4 elements");
            SWIG_fail;
          }
          $1 = &temp[0];
        } else {
          PyErr_SetString(PyExc_TypeError, "expected a tuple.");
          SWIG_fail;
        }
      }

This allows our ``set_direction`` function to be called from Python as
follows :

.. container:: targetlang

   ::

      >>> set_direction((0.5, 0.0, 1.0, -0.25))

Since our mapping copies the contents of a Python tuple into a C array,
such an approach would not be recommended for huge arrays, but for small
structures, this approach works fine.

Mapping sequences to C arrays
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Suppose that you wanted to generalize the previous example to handle C
arrays of different sizes. To do this, you might write a typemap as
follows:

.. container:: code

   ::

      // Map a Python sequence into any sized C double array
      %typemap(in) double[ANY](double temp[$1_dim0]) {
        int i;
        if (!PySequence_Check($input)) {
          PyErr_SetString(PyExc_TypeError, "Expecting a sequence");
          SWIG_fail;
        }
        if (PyObject_Length($input) != $1_dim0) {
          PyErr_SetString(PyExc_ValueError, "Expecting a sequence with $1_dim0 elements");
          SWIG_fail;
        }
        for (i =0; i < $1_dim0; i++) {
          PyObject *o = PySequence_GetItem($input, i);
          if (!PyFloat_Check(o)) {
            Py_XDECREF(o);
            PyErr_SetString(PyExc_ValueError, "Expecting a sequence of floats");
            SWIG_fail;
          }
          temp[i] = PyFloat_AsDouble(o);
          Py_DECREF(o);
        }
        $1 = &temp[0];
      }

In this case, the variable ``$1_dim0`` is expanded to match the array
dimensions actually used in the C code. This allows the typemap to be
applied to types such as:

.. container:: code

   ::

      void foo(double x[10]);
      void bar(double a[4], double b[8]);

Since the above typemap code gets inserted into every wrapper function
where used, it might make sense to use a helper function instead. This
will greatly reduce the amount of wrapper code. For example:

.. container:: code

   ::

      %{
      static int convert_darray(PyObject *input, double *ptr, int size) {
        int i;
        if (!PySequence_Check(input)) {
          PyErr_SetString(PyExc_TypeError, "Expecting a sequence");
          return 0;
        }
        if (PyObject_Length(input) != size) {
          PyErr_SetString(PyExc_ValueError, "Sequence size mismatch");
          return 0;
        }
        for (i =0; i < size; i++) {
          PyObject *o = PySequence_GetItem(input, i);
          if (!PyFloat_Check(o)) {
            Py_XDECREF(o);
            PyErr_SetString(PyExc_ValueError, "Expecting a sequence of floats");
            return 0;
          }
          ptr[i] = PyFloat_AsDouble(o);
          Py_DECREF(o);
        }
        return 1;
      }
      %}

      %typemap(in) double [ANY](double temp[$1_dim0]) {
        if (!convert_darray($input, temp, $1_dim0)) {
          SWIG_fail;
        }
        $1 = &temp[0];
      }

Pointer handling
~~~~~~~~~~~~~~~~~~~~~~~

Occasionally, it might be necessary to convert pointer values that have
been stored using the SWIG typed-pointer representation. Since there are
several ways in which pointers can be represented, the following two
functions are used to safely perform this conversion:

``int SWIG_ConvertPtr(PyObject *obj, void **ptr, swig_type_info *ty, int flags)``

.. container:: indent

   Converts a Python object ``obj`` to a C pointer. The result of the
   conversion is placed into the pointer located at ``ptr``. ``ty`` is a
   SWIG type descriptor structure. ``flags`` is used to handle error
   checking and other aspects of conversion. It is the bitwise-or of
   several flag values including ``SWIG_POINTER_EXCEPTION`` and
   ``SWIG_POINTER_DISOWN``. The first flag makes the function raise an
   exception on type error. The second flag additionally steals
   ownership of an object. Returns 0 on success and -1 on error.

``PyObject *SWIG_NewPointerObj(void *ptr, swig_type_info *ty, int own)``

.. container:: indent

   Creates a new Python pointer object. ``ptr`` is the pointer to
   convert, ``ty`` is the SWIG type descriptor structure that describes
   the type, and ``own`` is a flag that indicates whether or not Python
   should take ownership of the pointer.

Both of these functions require the use of a special SWIG
type-descriptor structure. This structure contains information about the
mangled name of the datatype, type-equivalence information, as well as
information about converting pointer values under C++ inheritance. For a
type of ``Foo *``, the type descriptor structure is usually accessed as
follows:

.. container:: code

   ::

      Foo *f;
      if (!SWIG_IsOK(SWIG_ConvertPtr($input, (void **) &f, SWIGTYPE_p_Foo, 0))) {
        SWIG_exception_fail(SWIG_TypeError, "in method '$symname', expecting type Foo");
      }

      PyObject *obj;
      obj = SWIG_NewPointerObj(f, SWIGTYPE_p_Foo, 0);

In a typemap, the type descriptor should always be accessed using the
special typemap variable ``$1_descriptor``. For example:

.. container:: code

   ::

      %typemap(in) Foo * {
        if (!SWIG_IsOK(SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, 0))) {
          SWIG_exception_fail(SWIG_TypeError, "in method '$symname', expecting type Foo");
        }
      }

If necessary, the descriptor for any type can be obtained using the
``$descriptor()`` macro in a typemap. For example:

.. container:: code

   ::

      %typemap(in) Foo * {
        if (!SWIG_IsOK(SWIG_ConvertPtr($input, (void **) &$1, $descriptor(Foo *), 0))) {
          SWIG_exception_fail(SWIG_TypeError, "in method '$symname', expecting type Foo");
        }
      }

Although the pointer handling functions are primarily intended for
manipulating low-level pointers, both functions are fully aware of
Python proxy classes. Specifically, ``SWIG_ConvertPtr()`` will retrieve
a pointer from any object that has a ``this`` attribute. In addition,
``SWIG_NewPointerObj()`` can automatically generate a proxy class object
(if applicable).

Memory management when returning references to member variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This example shows how to prevent premature garbage collection of
objects when the underlying C++ class returns a pointer or reference to
a member variable. The example is a direct equivalent to this `Java
equivalent <Java.html#Java_memory_management_objects>`__.

Consider the following C++ code:

.. container:: code

   ::

      #include <iostream>
      struct Wheel {
        int size;
        Wheel(int sz = 0) : size(sz) {}
        ~Wheel() { std::cout << "~Wheel" << std::endl; }
      };

      class Bike {
        Wheel wheel;
      public:
        Bike(int val) : wheel(val) {}
        Wheel& getWheel() { return wheel; }
      };

and the following usage from Python after running the code through SWIG:

.. container:: code

   ::

      bike = Bike(10)
      wheel = bike.getWheel()
      print("wheel size: {}".format(wheel.size))

      del bike  # Allow bike to be garbage collected
      print("wheel size: {}".format(wheel.size))

Don't be surprised that if the resulting output gives strange results
such as...

.. container:: shell

   ::

      wheel size: 10
      ~Wheel
      wheel size: 135019664

What has happened here is the garbage collector has collected the
``Bike`` instance as it doesn't think it is needed any more. The proxy
instance, ``wheel``, contains a reference to memory that was deleted
when the ``Bike`` instance was collected. In order to prevent the
garbage collector from collecting the ``Bike`` instance, a reference to
the ``Bike`` must be added to the ``wheel`` instance.

You can do this by adding the reference when the ``getWheel()`` method
is called using one of three approaches:

The easier, but less optimized, way is to use the ``%pythonappend``
directive (see `Adding additional Python code <#Python_nn42>`__):

.. container:: code

   ::

      %pythonappend getWheel %{
        # val is the Wheel proxy, self is the Bike instance
        val.__bike_reference = self
      %}

The code gets appended to the Python code generated for the
``Bike::getWheel`` wrapper function, where we store the ``Bike`` proxy
instance onto the ``Wheel`` proxy instance before it is returned to the
caller as follows.

.. container:: targetlang

   ::

      class Bike(object):
          ...
          def getWheel(self):
              val = _example.Bike_getWheel(self)

              # val is the Wheel proxy, self is the Bike instance
              val.__bike_reference = self

              return val

The second option, which performs better and is required if you use the
``-builtin`` option, is to set the reference in the CPython
implementation:

.. container:: code

   ::

      %extend Wheel {
      // A reference to the parent class is added to ensure the underlying C++
      // object is not deleted while the item is in use
      %typemap(ret) Wheel& getWheel {
        PyObject *bike_reference_string = SWIG_Python_str_FromChar("__bike_reference");
        PyObject_SetAttr($result, bike_reference_string, $self);
        Py_DecRef(bike_reference_string);
      }
      }

The third approach, shown below, is an optimization of the above
approach and creates the "__bike_reference" Python string object just
once. While this looks more complex, it is just a small variation on the
above typemap plus a support function ``bike_reference()`` in a fragment
called ``bike_reference_function``. The ``bike_reference_init`` typemap
generates code into the "init" section for an initial call to
``bike_reference()`` when the module is initialized and is done to
create the "__bike_reference" Python string singleton in a thread-safe
manner.

.. container:: code

   ::

      %fragment("bike_reference_init", "init") {
        // Thread-safe initialization - initialize during Python module initialization
        bike_reference();
      }

      %fragment("bike_reference_function", "header", fragment="bike_reference_init") {

      static PyObject *bike_reference() {
        static PyObject *bike_reference_string = SWIG_Python_str_FromChar("__bike_reference");
        return bike_reference_string;
      }

      }

      %extend Wheel {
      // A reference to the parent class is added to ensure the underlying C++
      // object is not deleted while the item is in use
      %typemap(ret, fragment="bike_reference_function") Wheel& getWheel %{
        PyObject_SetAttr($result, bike_reference(), $self);
      %}
      }

Docstring Features
------------------------

Using docstrings in Python code is becoming more and more important and
more tools are coming on the scene that take advantage of them,
everything from full-blown documentation generators to class browsers
and popup call-tips in Python-aware IDEs. Given the way that SWIG
generates the proxy code by default, your users will normally get
something like ``"function_name(*args)"`` in the popup calltip of their
IDE which is next to useless when the real function prototype might be
something like this:

.. container:: code

   ::

      bool function_name(int x, int y, Foo* foo=NULL, Bar* bar=NULL);

The features described in this section make it easy for you to add
docstrings to your modules, functions and methods that can then be used
by the various tools out there to make the programming experience of
your users much simpler.

Module docstring
~~~~~~~~~~~~~~~~~~~~~~~~

Python allows a docstring at the beginning of the ``.py`` file before
any other statements, and it is typically used to give a general
description of the entire module. SWIG supports this by setting an
option of the ``%module`` directive. For example:

.. container:: code

   ::

      %module(docstring="This is the example module's docstring") example

When you have more than just a line or so then you can retain the easy
readability of the ``%module`` directive by using a macro. For example:

.. container:: code

   ::

      %define DOCSTRING
      "The `XmlResource` class allows program resources defining menus,
      layout of controls on a panel, etc. to be loaded from an XML file."
      %enddef

      %module(docstring=DOCSTRING) xrc

%feature("autodoc")
~~~~~~~~~~~~~~~~~~~~~~~~~~~

As alluded to above SWIG will generate all the function and method proxy
wrappers with just "``*args``" (or "``*args, **kwargs``" if the -keyword option
is used) for a parameter list and will then sort out the individual
parameters in the C wrapper code. This is nice and simple for the
wrapper code, but makes it difficult to be programmer and tool friendly
as anyone looking at the ``.py`` file will not be able to find out
anything about the parameters that the functions accept.

But since SWIG does know everything about the function it is possible to
generate a docstring containing the parameter types, names and default
values. Since many of the docstring tools are adopting a standard of
recognizing if the first thing in the docstring is a function prototype
then using that instead of what they found from introspection, then life
is good once more.

SWIG's Python module provides support for the "autodoc" feature, which
when attached to a node in the parse tree will cause a docstring to be
generated that includes the name of the function, parameter names,
default values if any, and return type if any. There are also four
levels for autodoc controlled by the value given to the feature,
``%feature("autodoc", "level")``. The four values for *level* are
covered in the following sub-sections.

%feature("autodoc", "0")
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When level "0" is used then the types of the parameters will *not* be
included in the autodoc string. For example, given this function
prototype:

.. container:: code

   ::

      %feature("autodoc", "0");
      bool function_name(int x, int y, Foo* foo=NULL, Bar* bar=NULL);

Then Python code like this will be generated:

.. container:: targetlang

   ::

      def function_name(*args, **kwargs):
          """function_name(x, y, foo=None, bar=None) -> bool"""
          ...

%feature("autodoc", "1")
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When level "1" is used then the parameter types *will* be used in the
autodoc string. In addition, an attempt is made to simplify the type
name such that it makes more sense to the Python user. Pointer,
reference and const info is removed if the associated type is has an
associated Python type (``%rename``'s are thus shown correctly). This
works most of the time, otherwise a C/C++ type will be used. See the
next section for the "docstring" feature for tweaking the docstrings to
your liking. Given the example above, then turning on the parameter
types with level "1" will result in Python code like this:

.. container:: targetlang

   ::

      def function_name(*args, **kwargs):
          """function_name(int x, int y, Foo foo=None, Bar bar=None) -> bool"""
          ...

%feature("autodoc", "2")
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Level "2" results in the function prototype as per level "0". In
addition, a line of documentation is generated for each parameter using
`numpydoc <https://github.com/numpy/numpy/blob/master/doc/HOWTO_DOCUMENT.rst.txt>`__
style. Using the previous example, the generated code will be:

.. container:: targetlang

   ::

      def function_name(*args, **kwargs):
          """
          function_name(x, y, foo=None, bar=None) -> bool

          Parameters
          ----------
          x: int
          y: int
          foo: Foo *
          bar: Bar *

          """
          ...

Note that the documentation for each parameter is sourced from the "doc"
typemap which by default shows the C/C++ type rather than the simplified
Python type name described earlier for level "1". Typemaps can of course
change the output for any particular type, for example the ``int x``
parameter:

.. container:: code

   ::

      %feature("autodoc", "2");
      %typemap("doc") int x "$1_name (C++ type: $1_type) -- Input $1_name dimension"
      bool function_name(int x, int y, Foo* foo=NULL, Bar* bar=NULL);

resulting in

.. container:: targetlang

   ::

      def function_name(*args, **kwargs):
          """
          function_name(x, y, foo=None, bar=None) -> bool

          Parameters
          ----------
          x (C++ type: int) -- Input x dimension
          y: int
          foo: Foo *
          bar: Bar *

          """

%feature("autodoc", "3")
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Level "3" results in the function prototype as per level "1" but also
contains the same additional line of documentation for each parameter as
per level "2". Using our earlier example again, the generated code will
be:

.. container:: targetlang

   ::

      def function_name(*args, **kwargs):
          """
          function_name(int x, int y, Foo foo=None, Bar bar=None) -> bool

          Parameters
          ----------
          x: int
          y: int
          foo: Foo *
          bar: Bar *

          """
          ...

%feature("autodoc", "docstring")
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Finally, there are times when the automatically generated autodoc string
will make no sense for a Python programmer, particularly when a typemap
is involved. So if you give an explicit value for the autodoc feature
then that string will be used in place of the automatically generated
string. For example:

.. container:: code

   ::

      %feature("autodoc", "GetPosition() -> (x, y)") GetPosition;
      void GetPosition(int* OUTPUT, int* OUTPUT);

%feature("docstring")
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to the autodoc strings described above, you can also attach
any arbitrary descriptive text to a node in the parse tree with the
"docstring" feature. When the proxy module is generated then any
docstring associated with classes, function or methods are output. If an
item already has an autodoc string then it is combined with the
docstring and they are output together. If the docstring is all on a
single line then it is output like this:

.. container:: targetlang

   ::

      """This is the docstring"""

Otherwise, to aid readability it is output like this:

.. container:: targetlang

   ::

      """
      This is a multi-line docstring
      with more than one line.
      """

Python Packages
---------------------

Python has concepts of modules and packages. Modules are separate units
of code and may be grouped together to form a package. Packages may be
nested, that is they may contain subpackages. This leads to tree-like
hierarchy, with packages as intermediate nodes and modules as leaf
nodes.

The hierarchy of Python packages/modules follows the hierarchy of
``*.py`` files found in a source tree (or, more generally, in the Python
path). Normally, the developer creates new module by placing a ``*.py``
file somewhere under Python path; the module is then named after that
``*.py`` file. A package is created by placing an ``__init__.py`` file
within a directory; the package is then named after that directory. For
example, the following source tree:

.. container:: diagram

   ::

      mod1.py
      pkg1/__init__.py
      pkg1/mod2.py
      pkg1/pkg2/__init__.py
      pkg1/pkg2/mod3.py

defines the following Python packages and modules:

.. container:: diagram

   ::

      pkg1            # package
      pkg1.pkg2       # package
      mod1            # module
      pkg1.mod2       # module
      pkg1.pkg2.mod3  # module

The purpose of an ``__init__.py`` file is two-fold. First, the existence
of ``__init__.py`` in a directory informs the Python interpreter that
this directory contains a Python package. Second, the code in
``__init__.py`` is loaded/executed automatically when the package is
initialized (when it or its submodule/subpackage gets ``import``'ed). By
default, SWIG generates proxy Python code – one ``*.py`` file for each
``*.i`` interface. The ``__init__.py`` files, however, are not generated
by SWIG. They should be created by other means. Both files (module
``*.py`` and ``__init__.py``) should be installed in appropriate
destination directories in order to obtain a desirable package/module
hierarchy.

Python3 adds another option for packages with `PEP 0420
<https://www.python.org/dev/peps/pep-0420/>`__ (implicit namespace
packages). Implicit namespace packages no longer use \__init__.py files.
SWIG generated Python modules support implicit namespace packages. See
`Implicit namespace packages <#Python_implicit_namespace_packages>`__
for more information.

You can place a SWIG generated module into a Python package or keep as a
global module, details are covered a little later in `Location of
modules <#Python_package_search>`__.

The way Python defines its modules and packages impacts SWIG users. Some
users may need to use special features such as the ``package`` option in
the ``%module`` directive or import related command line options. These
are explained in the following sections.

Setting the Python package
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Using the ``package`` option in the ``%module`` directive allows you to
specify a Python package that the module will be in when installed.

.. container:: code

   ::

      %module(package="wx") xrc

This is useful when the ``.i`` file is ``%import``\ ed by another ``.i``
file. By default SWIG will assume that the importer is able to find the
importee with just the module name, but if they live in separate Python
packages then this won't work. However if the importee specifies what
its package is with the ``%module`` option then the Python code
generated for the importer will use that package name when importing the
other module and in base class declarations, etc..

SWIG assumes that the ``package`` option provided to ``%module``
together with the ``module`` name (that is, ``wx.xrc`` in the above
example) forms a fully qualified (absolute) name of a module (in Python
terms). This is important especially for Python 3, where absolute
imports are used by default. It's up to you to place the generated
module files (``.py``, ``.so``) in appropriate subdirectories. For
example, if you have an interface file ``foo.i`` with:

.. container:: code

   ::

      %module(package="pkg1.pkg2") foo

then the resulting directory layout should be

.. container:: diagram

   ::

      pkg1/
      pkg1/__init__.py
      pkg1/pkg2/__init__.py
      pkg1/pkg2/foo.py        # (generated by SWIG)
      pkg1/pkg2/_foo.so       # (shared library built from C/C++ code generated by SWIG)

Absolute and relative imports
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Suppose, we have the following hierarchy of files:

.. container:: diagram

   ::

      pkg1/
      pkg1/__init__.py
      pkg1/mod2.py
      pkg1/pkg2/__init__.py
      pkg1/pkg2/mod3.py

Let the contents of ``pkg1/pkg2/mod3.py`` be

.. container:: targetlang

   ::

      class M3: pass

We edit ``pkg1/mod2.py`` and want to import module ``pkg1/pkg2/mod3.py``
in order to derive from class ``M3``. We can write appropriate Python
code in several ways, for example:

#. Using "``import <>``" syntax with absolute package name:

   .. container:: targetlang

      ::

         # pkg1/mod2.py
         import pkg1.pkg2.mod3
         class M2(pkg1.pkg2.mod3.M3): pass

#. Using "``import <>``" syntax with package name relative to ``pkg1``
   (only in Python 2.7 and earlier):

   .. container:: targetlang

      ::

         # pkg1/mod2.py
         import pkg2.mod3
         class M2(pkg2.mod3.M3): pass

#. Using "``from <> import <>``" syntax (relative import syntax, only in
   Python 2.5 and later):

   .. container:: targetlang

      ::

         # pkg1/mod2.py
         from .pkg2 import mod3
         class M2(mod3.M3): pass

#. Other variants, for example the following construction in order to
   have the ``pkg2.mod3.M3`` symbol available in ``mod2`` as in point 2
   above (but now under Python 3):

   .. container:: targetlang

      ::

         # pkg1/mod2.py
         from . import pkg2
         from .pkg2 import mod3
         class M2(pkg2.mod3.M3): pass

Now suppose we have ``mod2.i`` with

.. container:: code

   ::

      // mod2.i
      %module (package="pkg1") mod2
      %import "mod3.i"
      // ...

and ``mod3.i`` with

.. container:: code

   ::

      // mod3.i
      %module (package="pkg1.pkg2") mod3
      // ...

By default, SWIG will generate ``mod2.py`` proxy file with ``import``
directive as in point 1. This can be changed with the
``-relativeimport`` command line option. The ``-relativeimport``
instructs SWIG to organize imports as in point 4 for Python 2.7.0 and
newer.

**Compatibility Note:** Versions of SWIG prior to SWIG-4.0.0 supported
Python < 2.7.0 and would organize the imports as in point 2 if an older
version of Python was detected at runtime.

In short, if you have ``mod2.i`` and ``mod3.i`` as above, then without
``-relativeimport`` SWIG will write

.. container:: targetlang

   ::

      import pkg1.pkg2.mod3

to ``mod2.py`` proxy file, and with ``-relativeimport`` it will write

.. container:: targetlang

   ::

      from . import pkg2
      from .pkg2 import mod3

You should avoid using relative imports and use absolute ones whenever
possible. There are some cases, however, when relative imports may be
necessary. The first example is, when some (legacy) Python code refers
entities imported by proxy files generated by SWIG, and it assumes that
the proxy file uses relative imports. Second case is, when one puts
import directives in ``__init__.py`` to import symbols from submodules
or subpackages and the submodule depends on other submodules (discussed
later).

Enforcing absolute import semantics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As you may know, there is an incompatibility in import semantics (for
the ``import <>`` syntax) between Python 2 and 3. In Python 2.4 and
earlier it is not clear whether

.. container:: targetlang

   ::

      import foo

refers to a top-level module or to another module inside the current
package. In Python 3 it always refers to a top-level module (see `PEP 328
<https://www.python.org/dev/peps/pep-0328/>`__). To instruct Python 2.5
through 2.7 to use new semantics (that is ``import foo`` is
interpreted as absolute import), one has to put the following line

.. container:: targetlang

   ::

      from __future__ import absolute_import

at the very beginning of your proxy ``*.py`` file. In SWIG, it may be
accomplished with ``%pythonbegin`` directive as follows:

.. container:: code

   ::

      %pythonbegin %{
      from __future__ import absolute_import
      %}

Importing from \__init__.py
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Imports in ``__init__.py`` are handy when you want to populate a
package's namespace with names imported from other modules. In SWIG
based projects this approach may also be used to split large pieces of
code into smaller modules, compile them in parallel and then re-assemble
everything at runtime by importing submodules' contents in
``__init__.py``, for example.

Unfortunately import directives in ``__init__.py`` may cause problems,
especially if they refer to a package's submodules. This is caused by
the way Python initializes packages. If you spot problems with imports
from ``__init__.py`` try using ``-relativeimport`` option. Below we
explain in detail one issue, for which the ``-relativeimport``
workaround may be helpful.

Consider the following example (Python 3):

.. container:: diagram

   ::

      pkg1/__init__.py        # (empty)
      pkg1/pkg2/__init__.py   # (imports something from bar.py)
      pkg1/pkg2/foo.py
      pkg1/pkg2/bar.py        # (imports foo.py)

If the file contents are:

-  ``pkg1/pkg2/__init__.py:``

   .. container:: targetlang

      ::

         # pkg1/pkg2/__init__.py
         from .bar import Bar

-  ``pkg1/pkg2/foo.py:``

   .. container:: targetlang

      ::

         # pkg1/pkg2/foo.py
         class Foo: pass

-  ``pkg1/pkg2/bar.py:``

   .. container:: targetlang

      ::

         # pkg1/pkg2/bar.py
         import pkg1.pkg2.foo
         class Bar(pkg1.pkg2.foo.Foo): pass

Now if one simply used ``import pkg1.pkg2``, it will usually fail:

.. container:: diagram

   ::

      >>> import pkg1.pkg2
      Traceback (most recent call last):
        File "<stdin>", line 1, in <module>
        File "./pkg1/pkg2/__init__.py", line 2, in <module>
          from .bar import Bar
        File "./pkg1/pkg2/bar.py", line 3, in <module>
          class Bar(pkg1.pkg2.foo.Foo): pass
      AttributeError: 'module' object has no attribute 'pkg2'

Surprisingly, if we execute the ``import pkg1.pkg2`` directive for the
second time, it succeeds. The reason seems to be following: when Python
spots the ``from .bar import Bar`` directive in
``pkg1/pkg2/__init__.py`` it starts loading ``pkg1/pkg2/bar.py``. This
module imports ``pkg1.pkg2.foo`` in turn and tries to use
``pkg1.pkg2.foo.Foo``, but the package ``pkg1`` is not fully initialized
yet (the initialization procedure is actually in progress) and it seems
like the effect of the already seen ``import pkg1.pkg2.pkg3.foo`` is
"delayed" or ignored. Exactly the same may happen to a proxy module
generated by SWIG.

One workaround for this case is to use a relative import in
``pkg1/pkg2/bar.py``. If we change ``bar.py`` to be:

.. container:: targetlang

   ::

      from .pkg3 import foo
      class Bar(foo.Foo): pass

or

.. container:: targetlang

   ::

      from . import pkg3
      from .pkg3 import foo
      class Bar(pkg3.foo.Foo): pass

then the example works again. With SWIG, you need to enable the
``-relativeimport`` option in order to have the above workaround in
effect (note, that the Python 2 case also needs the ``-relativeimport``
workaround).

Implicit namespace packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Python 3.3 introduced `PEP 0420
<https://www.python.org/dev/peps/pep-0420/>`__ which implements
implicit namespace packages. In a nutshell, implicit namespace packages
remove the requirement of an \__init__.py file and allow packages to be
split across multiple PATH elements.

For example:

.. container:: diagram

   ::

      /fragment1/pkg1/mod1.py
      /fragment2/pkg1/mod2.py
      /fragment3/pkg1/mod3.py

If PYTHONPATH is set to "/fragment1:/fragment2:/fragment3", then mod1,
mod2 and mod3 will be part of pkg1. This allows for splitting of
packages into separate pieces. This can be useful for SWIG generated
wrappers in the following way.

Suppose you create a SWIG wrapper for a module called robin. The SWIG
generated code consists of two files robin.py and \_robin.so. You wish
to make these modules part of a subpackage (brave.sir). With implicit
namespace packages you can place these files in the following
configurations:

Using PYTHONPATH="/some/path"

.. container:: diagram

   ::

      /some/path/brave/sir/robin.py
      /some/path/brave/sir/_robin.so

Using PYTHONPATH="/some/path:/some/other/path"

.. container:: diagram

   ::

      /some/path/brave/sir/robin.py
      /some/other/path/brave/sir/_robin.so

Finally suppose that your pure Python code is stored in a .zip file or
some other way (database, web service connection, etc). Python can load
the robin.py module using a custom importer. But the \_robin.so module
will need to be located on a file system. Implicit namespace packages
make this possible. For example, using
PYTHONPATH="/some/path/foo.zip:/some/other/path"

Contents of foo.zip

.. container:: diagram

   ::

      brave/
      brave/sir/
      brave/sir/robin.py

File system contents

.. container:: diagram

   ::

      /some/other/path/brave/sir/_robin.so

Support for implicit namespace packages was added to python-3.3. The
zipimporter requires python-3.5.1 or newer to work with subpackages.

**Compatibility Note:** Support for implicit namespace packages was
added in SWIG-3.0.9.

Location of modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~

When SWIG creates wrappers from an interface file, say foo.i, two Python
modules are created. There is a pure Python module (foo.py) and C/C++
code which is compiled and linked into a dynamically (or statically)
loaded low-level module \_foo (see the `Preliminaries
section <#Python_nn3>`__ for details). So, the interface file really
defines two Python modules. How these two modules are loaded is covered
next.

The pure Python module needs to load the C/C++ module in order to call
the wrapped C/C++ methods. To do this it must make some assumptions
about the location of the C/C++ module. There are two configurations
that are supported by default.

#. Both modules in the same package

#. Both modules are global

Additional configurations are supported but require custom import code.

The following sub-sections look more closely at the two default
configurations as well as some customized configurations. An input
interface file, foo.i, results in the two modules foo.py and \_foo.so
for each of the configurations.

Both modules in the same package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this configuration, the pure Python module, foo.py, tries to load the
C/C++ module, \_foo, from the same package foo.py is located in. The
package name is determined from the ``__package__`` attribute if
available, see `PEP 366 <https://www.python.org/dev/peps/pep-0366/>`__.
Otherwise it is derived from the ``__name__`` attribute given to foo.py
by the Python loader that imported foo.py. The interface file for this
configuration would contain:

.. container:: code

   ::

      %module(package="mypackage") foo

The location of the files could be as follows:

.. container:: diagram

   ::

      /dir/mypackage/foo.py
      /dir/mypackage/__init__.py
      /dir/mypackage/_foo.so

Assuming /dir/ is in PYTHONPATH, the module can be imported using

.. container:: targetlang

   ::

      from mypackage import foo

Both modules are global
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this configuration, there are no packages. If foo.py is not in a
package, that is, it is a global module, then \_foo is loaded as a
global module. The interface file for this configuration would contain:

.. container:: code

   ::

      %module foo

The location of the files could be as follows:

.. container:: diagram

   ::

      /dir/foo.py
      /dir/_foo.so

Assuming /dir/ is in PYTHONPATH, the module can be imported using

.. container:: targetlang

   ::

      import foo

Split modules custom configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this non-standard 'split module' configuration, the pure Python
module is in a package and the low level C/C++ module is global. This
configuration is not generally recommended and is not supported by
default as it needs a custom configuration. The module import code
customization required is via the ``moduleimport`` attribute in the
``%module`` directive. The next sub-section elaborates further on this.
The interface file for this split module configuration would contain:

.. container:: code

   ::

      %module(package="mypackage", moduleimport="import _foo") foo

When using ``-builtin``, use the following instead (the reasons are also
covered shortly in the next sub-section):

.. container:: code

   ::

      %module(package="mypackage", moduleimport="from _foo import *") foo

The location of the files could be as follows:

.. container:: diagram

   ::

      /dir/mypackage/foo.py
      /dir/mypackage/__init__.py
      /dir/_foo.so

Assuming /dir/ is in PYTHONPATH, the module can be imported using

.. container:: targetlang

   ::

      from mypackage import foo

**Compatibility Note:** Versions of SWIG prior to SWIG-4.0.0 supported
split modules without the above customization. However, this had to be
removed as the default import code often led to confusion due to
obfuscation of genuine Python ``ImportError`` problems. Using one of the
two default configurations is the recommended approach now.

More on customizing the module import code
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Python code implementing the default import logic is shown below. It
supports the two configurations described earlier, that is, either both
modules are in a package or loading both as global modules. The code is
generated into the pure Python module, foo.py, and merely imports the
low-level \_foo module.

.. container:: targetlang

   ::

      if __package__ or '.' in __name__:
          from . import _foo
      else:
          import _foo

This import code implementation is non-trivial but it can be replaced
with custom code providing opportunities to make it simpler and/or more
flexible. This is not normally recommended though unless you have a good
understanding of the intricacies of importing Python modules. The custom
code can be specified by setting the ``moduleimport`` option of the
``%module`` directive with the appropriate import code. For example:

.. container:: code

   ::

      %module(moduleimport="import _foo") foo

This will replace the default import logic above and generate the
following into the pure Python module, foo.py:

.. container:: targetlang

   ::

      import _foo

In fact the above is a simplification customization for the
configuration where both modules are global; it removes the logic for
also handling the modules being in a package.

There is a special variable, ``$module``, which is expanded into the
low-level C/C++ module name, ``_foo`` in the case above. The identical
output would be generated if instead the following had been used:

.. container:: code

   ::

      %module(moduleimport="import $module") foo

When you have many lines you can retain the easy readability of the
``%module`` directive by using a macro. For example:

.. container:: code

   ::

      %define MODULEIMPORT
      "
      print 'Loading low-level module $module'
      import $module
      print 'Module has loaded'
      "
      %enddef

      %module(moduleimport=MODULEIMPORT) foo

This will of course generate the following into the pure Python module:

.. container:: targetlang

   ::

      print 'Loading low-level module $module'
      import _foo
      print 'Module has loaded'

When using the ``-builtin`` option, the link between the pure Python
module and the low-level C/C++ module is slightly different as all the
objects from the low-level module are imported directly into the pure
Python module. The default import loading code is thus different:

.. container:: targetlang

   ::

      if __package__ or '.' in __name__:
          from ._foo import *
      else:
          from _foo import *

Any customizations must import the code in a similar manner. The best
way to support both with and without ``-builtin`` is to make use of the
``SWIGPYTHON_BUILTIN`` macro which is defined when ``-builtin`` is
specified. The following will do this for the `split
modules <#Python_package_search_wrapper_split>`__ case above.

.. container:: code

   ::

      #if defined(SWIGPYTHON_BUILTIN) /* defined when using -builtin */
      %module(package="mypackage", moduleimport="from $module import *") foo
      #else
      %module(package="mypackage", moduleimport="import $module") foo
      #endif

Statically linked C modules
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is strongly recommended to use dynamically linked modules for the C
portion of your pair of Python modules. If for some reason you still
need to link the C module of the pair of Python modules generated by
SWIG into your interpreter, then this section provides some details on
how this impacts the pure Python modules ability to locate the other
part of the pair. Please also see the `Static Linking <#Python_nn8>`__
section.

When Python is extended with C code the Python interpreter needs to be
informed about details of the new C functions that have been linked into
the executable. The code to do this is created by SWIG and is
automatically called in the correct way when the module is dynamically
loaded. However when the code is not dynamically loaded (because it is
statically linked) Then the initialization method for the module created
by SWIG is not called automatically and the Python interpreter has no
idea that the new SWIG C module exists.

Before Python 3, one could simply call the init method created by SWIG
which would have normally been called when the shared object was
dynamically loaded. The specific name of this method is not given here
because statically linked modules are not encouraged with SWIG (`Static
Linking <#Python_nn8>`__). However one can find this init function in
the C file generated by SWIG.

If you are really keen on static linking there are two ways to
initialize the SWIG generated C module with the init method. Which way
you use depends on what version of Python your module is being linked
with. Python 2 and Python 3 treat this init function differently. And
the way they treat it affects how the pure Python module will be able to
locate the C module.

The details concerning this are covered completely in the documentation
for Python itself. Links to the relevant sections follow:

-  `Extending in
   python2 <https://docs.python.org/2/extending/extending.html#methodtable>`__
-  `Extending in
   python3 <https://docs.python.org/3.6/extending/extending.html#the-module-s-method-table-and-initialization-function>`__

There are two keys things to understand. The first is that in Python 2
the init() function returns void. In Python 3 the init() function
returns a ``PyObject *`` which points to the new module. Secondly, when
you call the init() method manually, you are the Python importer. So,
you determine which package the C module will be located in.

So, if you are using Python 3 it is important that you follow what is
described in the Python documentation linked above. In particular, you
can't simply call the init() function generated by SWIG and cast the
``PyObject`` pointer it returns over the side. If you do then Python 3
will have no idea that your C module exists and the pure Python half of
your wrapper will not be able to find it. You need to register your
module with the Python interpreter as described in the Python docs.

With Python 2 things are somewhat more simple. In this case the init()
function returns void. Calling it will register your new C module as a
**global** module. The pure Python part of the SWIG wrapper will be able
to find it because it tries both the pure Python module it is part of
and the global module. If you wish not to have the statically linked
module be a global module then you will either need to refer to the
Python documentation on how to do this (remember you are now the Python
importer) or use dynamic linking.

Python 3 Support
----------------------

SWIG is able to support Python 3.x. The wrapper code generated by SWIG
can be compiled with both Python 2.x or 3.x. Further more, by passing
the ``-py3`` command line option to SWIG, wrapper code with some Python
3 specific features can be generated (see below subsections for details
of these features).

There is a list of known-to-be-broken features in Python 3:

-  No more support for FILE\* typemaps, because PyFile_AsFile has been
   dropped in Python 3.
-  The ``-apply`` command line option is removed and generating code
   using apply() is no longer supported.

The following are Python 3 new features that are currently supported by
SWIG.

Function annotation
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``-py3`` option will enable function annotation support. When used
SWIG is able to generate proxy method definitions like this:

.. container:: code

   ::

        def foo(self, bar : "int"=0) -> "void" : ...

Also, even if without passing SWIG the ``-py3`` option, the parameter
list still could be generated:

.. container:: code

   ::

        def foo(self, bar=0): ...

But for overloaded function or method, the parameter list would fallback
to ``*args`` or ``self, *args``, and ``**kwargs`` may be append depend
on whether you enabled the keyword argument. This fallback is due to all
overloaded functions share the same function in SWIG generated proxy
class.

For detailed usage of function annotation, see `PEP 3107
<https://www.python.org/dev/peps/pep-3107/>`__.

Buffer interface
~~~~~~~~~~~~~~~~~~~~~~~~

SWIG has a series of typemaps to support buffer interfaces. These
typemap macros are defined in ``pybuffer.i``, which must be included in
order to use them. By using these typemaps, your wrapped function will
be able to accept any Python object that exposes a suitable buffer
interface.

For example, the ``get_path()`` function puts the path string into the
memory pointed to by its argument:

.. container:: code

   ::

      void get_path(char *s);

Then you can write a typemap like this: (the following example is
applied to both Python 2 and 3, since the ``bytearray`` type was
backported to 2.6.

.. container:: code

   ::

      %include <pybuffer.i>
      %pybuffer_mutable_string(char *str);
      void get_path(char *str);

And then on the Python side the wrapped ``get_path`` could be used in
this way:

.. container:: targetlang

   ::

      >>> p = bytearray(10)
      >>> get_path(p)
      >>> print(p)
      bytearray(b'/Foo/Bar/\x00')

The macros defined in ``pybuffer.i`` are similar to those in
``cstring.i``:

**%pybuffer_mutable_binary(parm, size_parm)**

.. container:: indent

   The macro can be used to generate a typemap which maps a buffer of an
   object to a pointer provided by ``parm`` and a size argument provided
   by ``size_parm``. For example:

   .. container:: code

      ::

         %pybuffer_mutable_binary(char *str, size_t size);
         ...
         int snprintf(char *str, size_t size, const char *format, ...);

   In Python:

   .. container:: targetlang

      ::

         >>> buf = bytearray(6)
         >>> snprintf(buf, "Hello world!")
         >>> print(buf)
         bytearray(b'Hello\x00')
         >>>

**%pybuffer_mutable_string(parm)**

.. container:: indent

   This typemap macro requires the buffer to be a zero terminated
   string, and maps the pointer of the buffer to ``parm``. For example:

   .. container:: code

      ::

         %pybuffer_mutable_string(char *str);
         ...
         size_t make_upper(char *str);

   In Python:

   .. container:: targetlang

      ::

         >>> buf = bytearray(b'foo\x00')
         >>> make_upper(buf)
         >>> print(buf)
         bytearray(b'FOO\x00')
         >>>

   Both ``%pybuffer_mutable_binary`` and ``%pybuffer_mutable_string``
   require the provided buffer to be mutable, eg. they can accept a
   ``bytearray`` type but can't accept an immutable ``byte`` type.

**%pybuffer_binary(parm, size_parm)**

.. container:: indent

   This macro maps an object's buffer to a pointer ``parm`` and a size
   ``size_parm``. It is similar to ``%pybuffer_mutable_binary``, except
   the ``%pybuffer_binary`` can accept both mutable and immutable
   buffers. As a result, the wrapped function should not modify the
   buffer.

**%pybuffer_string(parm)**

.. container:: indent

   This macro maps an object's buffer as a string pointer ``parm``. It
   is similar to ``%pybuffer_mutable_string`` but the buffer could be
   both mutable and immutable. And your function should not modify the
   buffer.

Abstract base classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By including ``pyabc.i`` and using the ``-py3`` command line option when
calling SWIG, the proxy classes of the STL containers will automatically
gain an appropriate abstract base class from the ``collections.abc``
module. For example, the following SWIG interface:

.. container:: code

   ::

      %include <pyabc.i>
      %include <std_map.i>
      %include <std_list.i>

      namespace std {
        %template(Mapii) map<int, int>;
        %template(IntList) list<int>;
      }

will generate a Python proxy class ``Mapii`` inheriting from
``collections.abc.MutableMap`` and a proxy class ``IntList`` inheriting
from ``collections.abc.MutableSequence``.

``pyabc.i`` also provides a macro ``%pythonabc`` that could be used to
define an abstract base class for your own C++ class:

.. container:: code

   ::

      %pythonabc(MySet, collections.abc.MutableSet);

For details of abstract base class, please see `PEP 3119
<https://www.python.org/dev/peps/pep-3119/>`__.

**Compatibility Note:** SWIG-4.0.0 changed the base classes to use the
``collections.abc`` module instead of ``collections`` due to the
deprecation of the classes in the ``collections`` module in Python 3.7.
The ``collections.abc`` module was introduced in Python 3.3 and hence
this feature requires Python 3.3 or later.

Byte string output conversion
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, any byte string (``char*`` or ``std::string``) returned from
C or C++ code is decoded to text as UTF-8. This decoding uses the
``surrogateescape`` error handler under Python 3.1 or higher -- this
error handler decodes invalid byte sequences to high surrogate
characters in the range U+DC80 to U+DCFF. As an example, consider the
following SWIG interface, which exposes a byte string that cannot be
completely decoded as UTF-8:

.. container:: code

   ::

      %module example

      %inline %{

      const char * non_utf8_c_str(void) {
        return "h\xe9llo w\xc3\xb6rld";
      }

      void instring(const char *s) {
        ...
      }

      %}

Note that "``\xe9``" is an invalid UTF-8 encoding, but "``\xc3\xb6``" is valid.
When this method is called from Python 3, the return value is the
following text string:

.. container:: targetlang

   ::

      >>> s = example.non_utf8_c_str()
      >>> s
      'h\udce9llo wörld'

Since the C string contains bytes that cannot be decoded as UTF-8, those
raw bytes are represented as high surrogate characters that can be used
to obtain the original byte sequence:

.. container:: targetlang

   ::

      >>> b = s.encode('utf-8', errors='surrogateescape')
      >>> b
      b'h\xe9llo w\xc3\xb6rld'

One can then attempt a different encoding, if desired (or simply leave
the byte string as a raw sequence of bytes for use in binary protocols):

.. container:: targetlang

   ::

      >>> b.decode('latin-1')
      'héllo wÃ¶rld'

Note, however, that text strings containing surrogate characters are
rejected with the default ``strict`` codec error handler. For example:

.. container:: targetlang

   ::

      >>> with open('test', 'w') as f:
      ...     print(s, file=f)
      ...
      Traceback (most recent call last):
        File "<stdin>", line 2, in <module>
      UnicodeEncodeError: 'utf-8' codec can't encode character '\udce9' in position 1: surrogates not allowed

This requires the user to check most strings returned by SWIG bindings,
but the alternative is for a non-UTF8 byte string to be completely
inaccessible in Python 3 code.

For more details about the ``surrogateescape`` error handler, please see
`PEP 383 <https://www.python.org/dev/peps/pep-0383/>`__.

When Python 3 strings are passed to the C/C++ layer, they are expected
to be valid UTF8 Unicode strings too. For example, when the ``instring``
method above is wrapped and called, any invalid UTF8 Unicode code
strings will result in a TypeError because the attempted conversion
fails:

.. container:: targetlang

   ::

      >>> example.instring('h\xe9llo')
      >>> example.instring('h\udce9llo')
      Traceback (most recent call last):
        File "<stdin>", line 1, in <module>
      TypeError: in method 'instring', argument 1 of type 'char const *'

In some cases, users may wish to instead handle all byte strings as
bytes objects in Python 3. This can be accomplished by adding
``SWIG_PYTHON_STRICT_BYTE_CHAR`` to the generated code:

.. container:: code

   ::

      %module char_to_bytes
      %begin %{
      #define SWIG_PYTHON_STRICT_BYTE_CHAR
      %}

      char *charstring(char *s) {
        return s;
      }

This will modify the behavior so that only Python 3 bytes objects will
be accepted and converted to a C/C++ string, and any string returned
from C/C++ will be converted to a bytes object in Python 3:

.. container:: targetlang

   ::

      >>> from char_to_bytes import *
      >>> charstring(b"hi") # Byte string
      b'hi'
      >>> charstring("hi")  # Unicode string
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      TypeError: in method 'charstring', argument 1 of type 'char *'

Note that in Python 2, defining ``SWIG_PYTHON_STRICT_BYTE_CHAR`` has no
effect, since strings in Python 2 are equivalent to Python 3 bytes
objects. However, there is a similar capability to force unicode-only
handling for wide characters C/C++ strings (``wchar_t *`` or
``std::wstring`` types) in Python 2. By default, in Python 2 both
strings and unicode strings are converted to C/C++ wide strings, and
returned wide strings are converted to a Python unicode string. To
instead only convert unicode strings to wide strings, users can add
``SWIG_PYTHON_STRICT_UNICODE_WCHAR`` to the generated code:

.. container:: code

   ::

      %module wchar_to_unicode
      %begin %{
      #define SWIG_PYTHON_STRICT_UNICODE_WCHAR
      %}

      wchar_t *wcharstring(wchar_t *s) {
        return s;
      }

This ensures that only unicode strings are accepted by wcharstring in
both Python 2 and Python 3:

.. container:: targetlang

   ::

      >>> from wchar_to_unicode import *
      >>> wcharstring(u"hi") # Unicode string
      u'hi'
      >>> wcharstring(b"hi") # Byte string
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      TypeError: in method 'charstring', argument 1 of type 'wchar_t *'

By defining both ``SWIG_PYTHON_STRICT_BYTE_CHAR`` and
``SWIG_PYTHON_STRICT_UNICODE_WCHAR``, Python wrapper code can support
overloads taking both std::string (as Python bytes) and std::wstring (as
Python unicode).

Python 2 Unicode
~~~~~~~~~~~~~~~~~~~~~~~~

A Python 3 string is a Unicode string so by default a Python 3 string
that contains Unicode characters passed to C/C++ will be accepted and
converted to a C/C++ string (``char *`` or ``std::string`` types). A
Python 2 string is not a unicode string by default and should a Unicode
string be passed to C/C++ it will fail to convert to a C/C++ string
(``char *`` or ``std::string`` types). The Python 2 behavior can be made
more like Python 3 by defining ``SWIG_PYTHON_2_UNICODE`` when compiling
the generated C/C++ code. By default when the following is wrapped:

.. container:: code

   ::

      %module unicode_strings
      char *charstring(char *s) {
        return s;
      }

An error will occur when using Unicode strings in Python 2:

.. container:: targetlang

   ::

      >>> from unicode_strings import *
      >>> charstring("hi")
      'hi'
      >>> charstring(u"hi")
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      TypeError: in method 'charstring', argument 1 of type 'char *'

When the ``SWIG_PYTHON_2_UNICODE`` macro is added to the generated code:

.. container:: code

   ::

      %module unicode_strings
      %begin %{
      #define SWIG_PYTHON_2_UNICODE
      %}

      char *charstring(char *s) {
        return s;
      }

Unicode strings will be successfully accepted and converted from UTF-8,
but note that they are returned as a normal Python 2 string:

.. container:: targetlang

   ::

      >>> from unicode_strings import *
      >>> charstring("hi")
      'hi'
      >>> charstring(u"hi")
      'hi'
      >>>

Note that defining both ``SWIG_PYTHON_2_UNICODE`` and
``SWIG_PYTHON_STRICT_BYTE_CHAR`` at the same time is not allowed, since
the first is allowing unicode conversion and the second is explicitly
prohibiting it.

Support for Multithreaded Applications
--------------------------------------------

By default, SWIG does not enable support for multithreaded Python
applications. More specifically, the Python wrappers generated by SWIG
will not release the Python's interpreter's Global Interpreter Lock
(GIL) when wrapped C/C++ code is entered. Hence, while any of the
wrapped C/C++ code is executing, the Python interpreter will not be able
to run any other threads, even if the wrapped C/C++ code is waiting in a
blocking call for something like network or disk IO. Fortunately, SWIG
does have the ability to enable multithreaded support and automatic
release of the GIL either for all wrapped code in a module or on a more
selective basis. The user interface for this is described in the next
section.

UI for Enabling Multithreading Support
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The user interface is as follows:

#. Module thread support can be enabled in two ways:

   -  The ``-threads`` SWIG Python option at the command line (or in
      ``setup.py``):

      .. container:: shell

         ::

            $ swig -python -threads example.i

   -  The ``threads`` module option in the \*.i template file:

      .. container:: code

         ::

            %module("threads"=1)

#. You can disable thread support for a given method:

   .. container:: code

      ::

         %feature("nothread") method;

   or

   .. container:: code

      ::

         %nothread method;

#. You can partially disable thread support for a given method:

   -  To disable the C++/Python thread protection:

      .. container:: code

         ::

            %feature("nothreadblock") method;

      or

      .. container:: code

         ::

            %nothreadblock method;

   -  To disable the Python/C++ thread protection

      .. container:: code

         ::

            %feature("nothreadallow") method;

      or

      .. container:: code

         ::

            %nothreadallow method;

Multithread Performance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For the curious about performance, here are some numbers for the
profiletest.i test, which is used to check the speed of the wrapped
code:

.. list-table::
    :widths: 25 25 25
    :header-rows: 1

    *
      - Thread Mode
      - Execution Time (sec)
      - Comment
    *
      - Single Threaded
      - 9.6
      - no "-threads" option given
    *
      - Fully Multithreaded 
      - 15.5                 
      - "-threads" option = 'allow' + 'block'
    *
      - No Thread block     
      - 12.2                 
      - only 'allow'         
    *
      - No Thread Allow     
      - 13.6                 
      - only block'          
    

Fully threaded code decreases the wrapping performance by around 60%. If
that is important to your application, you can tune each method using
the different 'nothread', 'nothreadblock' or 'nothreadallow' features as
needed. Note that for some methods deactivating the 'thread block' or
'thread allow' code is not an option, so, be careful.

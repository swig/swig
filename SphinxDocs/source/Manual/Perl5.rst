SWIG and Perl5
=================

**Caution: This chapter is under repair!**

This chapter describes SWIG's support of Perl5. Although the Perl5
module is one of the earliest SWIG modules, it has continued to evolve
and has been improved greatly with the help of SWIG users. For the best
results, it is recommended that SWIG be used with Perl 5.8 or later.
We're no longer testing regularly with older versions, but Perl 5.6
seems to mostly work, while older versions don't.

Overview
-------------

To build Perl extension modules, SWIG uses a layered approach. At the
lowest level, simple procedural wrappers are generated for functions,
classes, methods, and other declarations in the input file. Then, for
structures and classes, an optional collection of Perl proxy classes can
be generated in order to provide a more natural object oriented Perl
interface. These proxy classes simply build upon the low-level
interface.

In describing the Perl interface, this chapter begins by covering the
essentials. First, the problem of configuration, compiling, and
installing Perl modules is discussed. Next, the low-level procedural
interface is presented. Finally, proxy classes are described. Advanced
customization features, typemaps, and other options are found near the
end of the chapter.

Preliminaries
------------------

To build a Perl5 module, run SWIG using the ``-perl`` or ``-perl5``
option as follows:

.. container:: code

   ::

      swig -perl example.i

This produces two files. The first file, ``example_wrap.c`` contains all
of the C code needed to build a Perl5 module. The second file,
``example.pm`` contains supporting Perl code needed to properly load the
module.

To build the module, you will need to compile the file
``example_wrap.c`` and link it with the rest of your program.

Getting the right header files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to compile, SWIG extensions need the following Perl5 header
files:

.. container:: code

   ::

      #include "Extern.h"
      #include "perl.h"
      #include "XSUB.h"

These are typically located in a directory like this

.. container:: code

   ::

      /usr/lib/perl/5.14/CORE

The SWIG configuration script automatically tries to locate this
directory so that it can compile examples. However, if you need to find
out where the directory is located, an easy way to find out is to ask
Perl itself:

.. container:: code

   ::

      $ perl -e 'use Config; print "$Config{archlib}\n";'
      /usr/lib/perl/5.14

Compiling a dynamic module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The preferred approach to building an extension module is to compile it
into a shared object file or DLL. Assuming you have code you need to
link to in a file called ``example.c``, you will need to compile your
program using commands like this (shown for Linux):

.. container:: code

   ::

      $ swig -perl example.i
      $ gcc -fPIC example.c
      $ gcc -fPIC -c example_wrap.c -I/usr/lib/perl/5.14/CORE -Dbool=char
      $ gcc -shared example.o example_wrap.o -o example.so

The exact compiler options vary from platform to platform. SWIG tries to
guess the right options when it is installed. Therefore, you may want to
start with one of the examples in the ``SWIG/Examples/perl5`` directory.
If that doesn't work, you will need to read the man-pages for your
compiler and linker to get the right set of options. You might also
check the `SWIG Wiki <https://github.com/swig/swig/wiki>`__ for
additional information.

When linking the module, the name of the shared object file must match
the module name used in the SWIG interface file. If you used
\`\ ``%module example``', then the target should be named
\`\ ``example.so``', \`\ ``example.sl``', or the appropriate dynamic
module name on your system.

Building a dynamic module with MakeMaker
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is also possible to use Perl to build dynamically loadable modules
for you using the MakeMaker utility. To do this, write a Perl script
such as the following:

.. container:: targetlang

   ::

      # File : Makefile.PL
      use ExtUtils::MakeMaker;
      WriteMakefile(
              `NAME'    => `example',                  # Name of package
              `LIBS'    => [`-lm'],                    # Name of custom libraries
              `OBJECT'  => `example.o example_wrap.o'  # Object files
      );

Now, to build a module, simply follow these steps:

.. container:: code

   ::

      $ perl Makefile.PL
      $ make
      $ make install

If you are planning to distribute a SWIG-generated module, this is the
preferred approach to compilation. More information about MakeMaker can
be found in "Programming Perl, 2nd ed." by Larry Wall, Tom Christiansen,
and Randal Schwartz.

Building a static version of Perl
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you machine does not support dynamic loading or if you've tried to
use it without success, you can build a new version of the Perl
interpreter with your SWIG extensions added to it. To build a static
extension, you first need to invoke SWIG as follows:

.. container:: code

   ::

      $ swig -perl -static example.i

By default SWIG includes code for dynamic loading, but the ``-static``
option takes it out.

Next, you will need to supply a ``main()`` function that initializes
your extension and starts the Perl interpreter. While, this may sound
daunting, SWIG can do this for you automatically as follows:

.. container:: targetlang

   ::

      %module example

      %inline %{
      extern double My_variable;
      extern int fact(int);
      %}

      // Include code for rebuilding Perl
      %include <perlmain.i>

The same thing can be accomplished by running SWIG as follows:

.. container:: code

   ::

      $ swig -perl -static -lperlmain.i example.i

The ``perlmain.i`` file inserts Perl's ``main()`` function into the
wrapper code and automatically initializes the SWIG generated module. If
you just want to make a quick a dirty module, this may be the easiest
way. By default, the ``perlmain.i`` code does not initialize any other
Perl extensions. If you need to use other packages, you will need to
modify it appropriately. You can do this by just copying ``perlmain.i``
out of the SWIG library, placing it in your own directory, and modifying
it to suit your purposes.

To build your new Perl executable, follow the exact same procedure as
for a dynamic module, but change the link line to something like this:

.. container:: code

   ::

      $ gcc example.o example_wrap.o -L/usr/lib/perl/5.14/CORE \
              -lperl -lsocket -lnsl -lm -o myperl

This will produce a new version of Perl called ``myperl``. It should be
functionality identical to Perl with your C/C++ extension added to it.
Depending on your machine, you may need to link with additional
libraries such as ``-lsocket, -lnsl, -ldl``, etc.

Using the module
~~~~~~~~~~~~~~~~~~~~~~~

To use the module, simply use the Perl ``use`` statement. If all goes
well, you will be able to do this:

.. container:: targetlang

   ::

      $ perl
      use example;
      print example::fact(4), "\n";
      24

A common error received by first-time users is the following:

.. container:: targetlang

   ::

      use example;
      Can't locate example.pm in @INC (@INC contains: /etc/perl /usr/local/lib/perl/5.14.2 /usr/local/share/perl/5.14.2 /usr/lib/perl5 /usr/share/perl5 /usr/lib/perl/5.14 /usr/share/perl/5.14 /usr/local/lib/site_perl .) at - line 1.
      BEGIN failed--compilation aborted at - line 1.

This error is almost caused when the name of the shared object file you
created doesn't match the module name you specified with the ``%module``
directive.

A somewhat related, but slightly different error is this:

.. container:: targetlang

   ::

      use example;
      Can't find 'boot_example' symbol in ./example.so
       at - line 1
      BEGIN failed--compilation aborted at - line 1.

This error is generated because Perl can't locate the module bootstrap
function in the SWIG extension module. This could be caused by a
mismatch between the module name and the shared library name. However,
another possible cause is forgetting to link the SWIG-generated wrapper
code with the rest of your application when you linked the extension
module.

Another common error is the following:

.. container:: targetlang

   ::

      use example;
      Can't load './example.so' for module example: ./example.so: 
      undefined symbol: Foo at /usr/lib/perl/5.14/i386-linux/DynaLoader.pm line 169.

       at - line 1
      BEGIN failed--compilation aborted at - line 1.

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
``%ignore`` directive to ignore the declaration. Better yet, update the
header file so that it doesn't have an undefined declaration.

Finally, suppose that your extension module is linked with another
library like this:

.. container:: code

   ::

      $ gcc -shared example.o example_wrap.o -L/home/beazley/projects/lib -lfoo \
            -o example.so

If the ``foo`` library is compiled as a shared library, you might get
the following error when you try to use your module:

.. container:: targetlang

   ::

      use example;
      Can't load './example.so' for module example: libfoo.so: cannot open shared object file: 
      No such file or directory at /usr/lib/perl/5.14/i386-linux/DynaLoader.pm line 169.

       at - line 1
      BEGIN failed--compilation aborted at - line 1.
      >>>                 

This error is generated because the dynamic linker can't locate the
``libfoo.so`` library. When shared libraries are loaded, the system
normally only checks a few standard locations such as ``/usr/lib`` and
``/usr/local/lib``. To get the loader to look in other locations, there
are several things you can do. First, you can recompile your extension
module with extra path information. For example, on Linux you can do
this:

.. container:: code

   ::

      $ gcc -shared example.o example_wrap.o -L/home/beazley/projects/lib -lfoo \
            -Xlinker -rpath /home/beazley/projects/lib \
            -o example.so

Alternatively, you can set the ``LD_LIBRARY_PATH`` environment variable
to include the directory with your shared libraries. If setting
``LD_LIBRARY_PATH``, be aware that setting this variable can introduce a
noticeable performance impact on all other applications that you run. To
set it only for Perl, you might want to do this instead:

.. container:: code

   ::

      $ env LD_LIBRARY_PATH=/home/beazley/projects/lib perl

Finally, you can use a command such as ``ldconfig`` (Linux) or ``crle``
(Solaris) to add additional search paths to the default system
configuration (this requires root access and you will need to read the
man pages).

Compilation problems and compiling with C++
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Compilation of C++ extensions has traditionally been a tricky problem.
Since the Perl interpreter is written in C, you need to take steps to
make sure C++ is properly initialized and that modules are compiled
correctly.

On most machines, C++ extension modules should be linked using the C++
compiler. For example:

.. container:: code

   ::

      $ swig -c++ -perl example.i
      $ g++ -fPIC -c example.cxx
      $ g++ -fPIC -c example_wrap.cxx -I/usr/lib/perl/5.14/i386-linux/CORE
      $ g++ -shared example.o example_wrap.o -o example.so

In addition to this, you may need to include additional library files to
make it work. For example, if you are using the Sun C++ compiler on
Solaris, you often need to add an extra library ``-lCrun`` like this:

.. container:: code

   ::

      $ swig -c++ -perl example.i
      $ CC -Kpic -c example.cxx
      $ CC -Kpic -c example_wrap.cxx -I/usr/lib/perl/5.14/i386-linux/CORE
      $ CC -shared example.o example_wrap.o -o example.so -lCrun

Of course, the names of the extra libraries are completely
non-portable---you will probably need to do some experimentation.

Another possible compile problem comes from recent versions of Perl
(5.8.0) and the GNU tools. If you see errors having to do with
\_crypt_struct, that means \_GNU_SOURCE is not defined and it needs to
be. So you should compile the wrapper like:

.. container:: code

   ::

      $ g++ -fPIC -c example_wrap.cxx -I/usr/lib/perl/5.8.0/CORE -D_GNU_SOURCE

-D_GNU_SOURCE is also included in the Perl ccflags, which can be found
by running

.. container:: code

   ::

      $ perl -e 'use Config; print "$Config{ccflags}\n";'

So you could also compile the wrapper like

.. container:: code

   ::

      $ g++ -fPIC -c example_wrap.cxx -I/usr/lib/perl/5.8.0/CORE \
      `perl -MConfig -e 'print $Config{ccflags}'`

Sometimes people have suggested that it is necessary to relink the Perl
interpreter using the C++ compiler to make C++ extension modules work.
In the experience of this author, this has never actually appeared to be
necessary on most platforms. Relinking the interpreter with C++ really
only includes the special run-time libraries described above---as long
as you link your extension modules with these libraries, it should not
be necessary to rebuild Perl.

If you aren't entirely sure about the linking of a C++ extension, you
might look at an existing C++ program. On many Unix machines, the
``ldd`` command will list library dependencies. This should give you
some clues about what you might have to include when you link your
extension module. For example, notice the first line of output here:

.. container:: code

   ::

      $ ldd swig
              libstdc++-libc6.1-1.so.2 => /usr/lib/libstdc++-libc6.1-1.so.2 (0x40019000)
              libm.so.6 => /lib/libm.so.6 (0x4005b000)
              libc.so.6 => /lib/libc.so.6 (0x40077000)
              /lib/ld-linux.so.2 => /lib/ld-linux.so.2 (0x40000000)
      $

If linking wasn't enough of a problem, another major complication of C++
is that it does not define any sort of standard for binary linking of
libraries. This means that C++ code compiled by different compilers will
not link together properly as libraries nor is the memory layout of
classes and data structures implemented in any kind of portable manner.
In a monolithic C++ program, this problem may be unnoticed. However, in
Perl, it is possible for different extension modules to be compiled with
different C++ compilers. As long as these modules are self-contained,
this probably won't matter. However, if these modules start sharing
data, you will need to take steps to avoid segmentation faults and other
erratic program behavior. Also, be aware that certain C++ features,
especially RTTI, can behave strangely when working with multiple
modules.

It should be noted that you may get a lot of error messages about the
'``bool``' datatype when compiling a C++ Perl module. If you experience
this problem, you can try the following:

-  Use ``-DHAS_BOOL`` when compiling the SWIG wrapper code
-  Or use ``-Dbool=char`` when compiling.

Finally, recent versions of Perl (5.8.0) have namespace conflict
problems. Perl defines a bunch of short macros to make the Perl API
function names shorter. For example, in /usr/lib/perl/5.8.0/CORE/embed.h
there is a line:

.. container:: code

   ::

      #define do_open Perl_do_open

The problem is, in the <iostream> header from GNU libstdc++v3 there is a
private function named do_open. If <iostream> is included after the perl
headers, then the Perl macro causes the iostream do_open to be renamed,
which causes compile errors. Hopefully in the future Perl will support a
PERL_NO_SHORT_NAMES flag, but for now the only solution is to undef the
macros that conflict. Lib/perl5/noembed.h in the SWIG source has a list
of macros that are known to conflict with either standard headers or
other headers. But if you get macro type conflicts from other macros not
included in Lib/perl5/noembed.h while compiling the wrapper, you will
have to find the macro that conflicts and add an #undef into the .i
file. Please report any conflicting macros you find to `swig-user
mailing list <http://www.swig.org/mail.html>`__.

Compiling for 64-bit platforms
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On platforms that support 64-bit applications (Solaris, Irix, etc.),
special care is required when building extension modules. On these
machines, 64-bit applications are compiled and linked using a different
set of compiler/linker options. In addition, it is not generally
possible to mix 32-bit and 64-bit code together in the same application.

To utilize 64-bits, the Perl executable will need to be recompiled as a
64-bit application. In addition, all libraries, wrapper code, and every
other part of your application will need to be compiled for 64-bits. If
you plan to use other third-party extension modules, they will also have
to be recompiled as 64-bit extensions.

If you are wrapping commercial software for which you have no source
code, you will be forced to use the same linking standard as used by
that software. This may prevent the use of 64-bit extensions. It may
also introduce problems on platforms that support more than one linking
standard (e.g., -o32 and -n32 on Irix).

Building Perl Extensions under Windows
-------------------------------------------

Building a SWIG extension to Perl under Windows is roughly similar to
the process used with Unix. Normally, you will want to produce a DLL
that can be loaded into the Perl interpreter. This section assumes you
are using SWIG with Microsoft Visual C++ although the procedure may be
similar with other compilers.

Running SWIG from Developer Studio
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are developing your application within Microsoft developer
studio, SWIG can be invoked as a custom build option. The process
roughly requires these steps:

-  Open up a new workspace and use the AppWizard to select a DLL
   project.
-  Add both the SWIG interface file (the .i file), any supporting C
   files, and the name of the wrapper file that will be created by SWIG
   (ie. ``example_wrap.c``). Note: If using C++, choose a different
   suffix for the wrapper file such as ``example_wrap.cxx``. Don't worry
   if the wrapper file doesn't exist yet--Developer studio will keep a
   reference to it around.
-  Select the SWIG interface file and go to the settings menu. Under
   settings, select the "Custom Build" option.
-  Enter "SWIG" in the description field.
-  Enter
   "``swig -perl5 -o $(ProjDir)\$(InputName)_wrap.cxx $(InputPath)``" in
   the "Build command(s) field"
-  Enter "``$(ProjDir)\$(InputName)_wrap.c``\ xx" in the "Output
   files(s) field".
-  Next, select the settings for the entire project and go to
   "C++:Preprocessor". Add the include directories for your Perl 5
   installation under "Additional include directories".
-  Define the symbols WIN32 and MSWIN32 under preprocessor options. If
   using the ActiveWare port, also define the symbol PERL_OBJECT. Note
   that all extensions to the ActiveWare port must be compiled with the
   C++ compiler since Perl has been encapsulated in a C++ class.
-  Finally, select the settings for the entire project and go to "Link
   Options". Add the Perl library file to your link libraries. For
   example "perl.lib". Also, set the name of the output file to match
   the name of your Perl module (ie. example.dll).
-  Build your project.

Now, assuming you made it this far, SWIG will be automatically invoked
when you build your project. Any changes made to the interface file will
result in SWIG being automatically invoked to produce a new version of
the wrapper file. To run your new Perl extension, simply run Perl and
use the use command as normal. For example:

.. container:: targetlang

   ::

      DOS > perl
      use example;
      $a = example::fact(4);
      print "$a\n";

Using other compilers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG is known to work with Cygwin and may work with other compilers on
Windows. For general hints and suggestions refer to the
`Windows <Windows.html#Windows>`__ chapter.

The low-level interface
----------------------------

At its core, the Perl module uses a simple low-level interface to C
function, variables, constants, and classes. This low-level interface
can be used to control your application. However, it is also used to
construct more user-friendly proxy classes as described in the next
section.

Functions
~~~~~~~~~~~~~~~~

C functions are converted into new Perl built-in commands (or
subroutines). For example:

.. container:: targetlang

   ::

      %module example
      int fact(int a);
      ...

Now, in Perl:

.. container:: targetlang

   ::

      use example;
      $a = &example::fact(2);

Global variables
~~~~~~~~~~~~~~~~~~~~~~~

Global variables are handled using Perl's magic variable mechanism. SWIG
generates a pair of functions that intercept read/write operations and
attaches them to a Perl variable with the same name as the C global
variable. Thus, an interface like this

.. container:: targetlang

   ::

      %module example;
      ...
      double Spam;
      ...

is accessed as follows:

.. container:: targetlang

   ::

      use example;
      print $example::Spam, "\n";
      $example::Spam = $example::Spam + 4
      # ... etc ...

If a variable is declared as ``const``, it is wrapped as a read-only
variable. Attempts to modify its value will result in an error.

To make ordinary variables read-only, you can also use the
``%immutable`` directive. For example:

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

It is also possible to tag a specific variable as read-only like this:

.. container:: code

   ::

      %{
      extern char *path;
      %}
      %immutable path; 
      ...
      ...
      extern char *path;       // Declared later in the input

Constants
~~~~~~~~~~~~~~~~

By default, constants are wrapped as read-only Perl variables. For
example:

.. container:: code

   ::

      %module example

      #define FOO 42

In Perl:

.. container:: targetlang

   ::

      use example;
      print $example::FOO, "\n";   # OK
      $example::FOO = 2;           # Error

Alternatively, if you use swig's ``-const`` option, constants are
wrapped such that the leading $ isn't required (by using a constant
subroutine), which usually gives a more natural Perl interface, for
example:

.. container:: targetlang

   ::

      use example;
      print example::FOO, "\n";

Pointers
~~~~~~~~~~~~~~~

SWIG represents pointers as blessed references. A blessed reference is
the same as a Perl reference except that it has additional information
attached to it indicating what kind of reference it is. That is, if you
have a C declaration like this:

.. container:: code

   ::

      Matrix *new_Matrix(int n, int m);

The module returns a value generated as follows:

.. container:: targetlang

   ::

      $ptr = new_Matrix(int n, int m);     # Save pointer return result
      bless $ptr, "p_Matrix";              # Bless it as a pointer to Matrix

SWIG uses the "blessing" to check the datatype of various pointers. In
the event of a mismatch, an error or warning message is generated.

To check to see if a value is the NULL pointer, use the ``defined()``
command:

.. container:: targetlang

   ::

      if (defined($ptr)) {
        print "Not a NULL pointer.";
      } else {
        print "Is a NULL pointer.";
      }

To create a NULL pointer, you should pass the ``undef`` value to a
function.

The "value" of a Perl reference is not the same as the underlying C
pointer that SWIG wrapper functions return. Suppose that ``$a`` and
``$b`` are two references that point to the same C object. In general,
``$a`` and ``$b`` will be different--since they are different
references. Thus, it is a mistake to check the equality of ``$a`` and
``$b`` to check the equality of two C pointers. The correct method to
check equality of C pointers is to dereference them as follows:

.. container:: targetlang

   ::

      if ($$a == $$b) {
        print "a and b point to the same thing in C";
      } else {
        print "a and b point to different objects.";
      }

As much as you might be inclined to modify a pointer value directly from
Perl, don't. Manipulating pointer values is architecture dependent and
could cause your program to crash. Similarly, don't try to manually cast
a pointer to a new type by reblessing a pointer. This may not work like
you expect and it is particularly dangerous when casting C++ objects. If
you need to cast a pointer or change its value, consider writing some
helper functions instead. For example:

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
a bogus result whereas as the C++-style cast will return ``NULL`` if the
conversion can't be performed.

**Compatibility Note:** In earlier versions, SWIG tried to preserve the
same pointer naming conventions as XS and ``xsubpp``. Given the
advancement of the SWIG typesystem and the growing differences between
SWIG and XS, this is no longer supported.

Structures
~~~~~~~~~~~~~~~~~

Access to the contents of a structure are provided through a set of
low-level accessor functions as described in the "SWIG Basics" chapter.
For example,

.. container:: code

   ::

      struct Vector {
        double x, y, z;
      };

gets mapped into the following collection of accessor functions:

.. container:: code

   ::

      struct Vector *new_Vector();
      void           delete_Vector(Vector *v);
      double         Vector_x_get(Vector *obj)
      void           Vector_x_set(Vector *obj, double x)
      double         Vector_y_get(Vector *obj)
      void           Vector_y_set(Vector *obj, double y)
      double         Vector_z_get(Vector *obj)
      void           Vector_z_set(Vector *obj, double z)

These functions are then used to access structure data from Perl as
follows:

.. container:: targetlang

   ::

      $v = example::new_Vector();
      print example::Vector_x_get($v), "\n";   # Get x component
      example::Vector_x_set($v, 7.8);          # Change x component

Similar access is provided for unions and the data members of C++
classes.

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

Array members are normally wrapped as read-only. For example,

.. container:: code

   ::

      struct Foo {
        int x[50];
      };

produces a single accessor function like this:

.. container:: code

   ::

      int *Foo_x_get(Foo *self) {
        return self->x;
      };

If you want to set an array member, you will need to supply a "memberin"
typemap described later in this chapter. As a special case, SWIG does
generate code to set array members of type ``char`` (allowing you to
store a Python string in the structure).

When structure members are wrapped, they are handled as pointers. For
example,

.. container:: code

   ::

      struct Foo {
        ...
      };

      struct Bar {
        Foo f;
      };

generates accessor functions such as this:

.. container:: code

   ::

      Foo *Bar_f_get(Bar *b) {
        return &b->f;
      }

      void Bar_f_set(Bar *b, Foo *val) {
        b->f = *val;
      }

C++ classes
~~~~~~~~~~~~~~~~~~

C++ classes are wrapped by building a set of low level accessor
functions. Consider the following class:

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
      static void print(List *l);
      };

When wrapped by SWIG, the following functions are created:

.. container:: code

   ::

      List    *new_List();
      void     delete_List(List *l);
      int      List_search(List *l, char *item);
      void     List_insert(List *l, char *item);
      void     List_remove(List *l, char *item);
      char    *List_get(List *l, int n);
      int      List_length_get(List *l);
      void     List_length_set(List *l, int n);
      void     List_print(List *l);

In Perl, these functions are used in a straightforward manner:

.. container:: targetlang

   ::

      use example;
      $l = example::new_List();
      example::List_insert($l, "Ale");
      example::List_insert($l, "Stout");
      example::List_insert($l, "Lager")
      example::List_print($l)
      Lager
      Stout
      Ale
      print example::List_length_get($l), "\n";
      3

At this low level, C++ objects are really just typed pointers. Member
functions are accessed by calling a C-like wrapper with an instance
pointer as the first argument. Although this interface is fairly
primitive, it provides direct access to C++ objects. A higher level
interface using Perl proxy classes can be built using these low-level
accessors. This is described shortly.

C++ classes and type-checking
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The SWIG type-checker is fully aware of C++ inheritance. Therefore, if
you have classes like this

.. container:: code

   ::

      class Foo {
      ...
      };

      class Bar : public Foo {
      ...
      };

and a function

.. container:: code

   ::

      void spam(Foo *f);

then the function ``spam()`` accepts ``Foo *`` or a pointer to any class
derived from ``Foo``. If necessary, the type-checker also adjusts the
value of the pointer (as is necessary when multiple inheritance is
used).

C++ overloaded functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have a C++ program with overloaded functions or methods, you will
need to disambiguate those methods using ``%rename``. For example:

.. container:: code

   ::

      /* Forward renaming declarations */
      %rename(foo_i) foo(int); 
      %rename(foo_d) foo(double);
      ...
      void foo(int);           // Becomes 'foo_i'
      void foo(char *c);       // Stays 'foo' (not renamed)

      class Spam {
      public:
        void foo(int);      // Becomes 'foo_i'
        void foo(double);   // Becomes 'foo_d'
        ...
      };

Now, in Perl, the methods are accessed as follows:

.. container:: targetlang

   ::

      use example;
      example::foo_i(3);
      $s = example::new_Spam();
      example::Spam_foo_i($s, 3);
      example::Spam_foo_d($s, 3.14);

Please refer to the "SWIG Basics" chapter for more information.

Operators
~~~~~~~~~~~~~~~~

As of version 1.3.27 SWIG automatically renames the most common C++
operators, and maps them into the perl module with the proper 'use
overload ...' so you don't need to do any work.

The following C++ operators are currently supported by the Perl module:

-  operator++
-  operator--
-  operator+
-  operator-
-  operator\*
-  operator/
-  operator==
-  operator!=
-  operator%
-  operator>
-  operator<
-  operator and
-  operator or

Modules and packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When you create a SWIG extension, everything gets placed into a single
Perl module. The name of the module is determined by the ``%module``
directive. To use the module, do the following:

.. container:: targetlang

   ::

      $ perl5
      use example;                      # load the example module
      print example::fact(4), "\n"      # Call a function in it
      24

Usually, a module consists of a collection of code that is contained
within a single file. A package, on the other hand, is the Perl
equivalent of a namespace. A package is a lot like a module, except that
it is independent of files. Any number of files may be part of the same
package--or a package may be broken up into a collection of modules if
you prefer to think about it in this way.

SWIG installs its functions into a package with the same name as the
module.

**Incompatible Change:** previous versions of SWIG enabled you to change
the name of the package by using the -package option, this feature has
been removed in order to properly support modules that used nested
namespaces, e.g. Foo::Bar::Baz. To give your module a nested namespace
simply provide the fully qualified name in your %module directive:

.. container:: code

   ::

      %module "Foo::Bar::Baz"

**NOTE:** the double quotes are necessary.

Using the ``package`` option of the ``%module`` directive allows you to
specify what Perl namespace that the module will be living in when
installed. This is useful in the situation where a module maintainer
wants to split a large module into smaller pieces to make maintenance
easier, but doesn't want to have that affect the module name used by
applications. So for example, if I wanted to split ``XML::Xerces`` into
``XML::Xerces::SAX``, etc. , but I wanted all the applications to be
able to access the classes using the ``XML::Xerces`` namespace I could
use:

.. container:: code

   ::

      %module(package="XML::Xerces") "XML::Xerces::SAX

And now all the applications could use the class
``XML::Xerces::SAXParser``. Without the ``package`` directive splitting
the module would force applications to use the class
``XML::Xerces::SAX::SAXParser``. This could break compatibility for
existing applications that are already using the class under the name
``XML::Xerces::SAXParser``.

Input and output parameters
--------------------------------

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
        return *x+*y;
      }

The easiest way to handle these situations is to use the ``typemaps.i``
file. For example:

.. container:: code

   ::

      %module example
      %include "typemaps.i"

      void add(int, int, int *OUTPUT);
      int  sub(int *INPUT, int *INPUT);

In Perl, this allows you to pass simple values. For example:

.. container:: targetlang

   ::

      $a = example::add(3, 4);
      print "$a\n";
      7
      $b = example::sub(7, 4);
      print "$b\n";
      3

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

In Perl, a mutated parameter shows up as a return value. For example:

.. container:: targetlang

   ::

      $a = example::negate(3);
      print "$a\n";
      -3

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

When used in Perl, the function will return multiple values.

.. container:: targetlang

   ::

      ($bytes, $success) = example::send_message("Hello World");

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

Now, in Perl:

.. container:: targetlang

   ::

      ($r, $c) = example::get_dimensions($m);

In certain cases, it is possible to treat Perl references as C pointers.
To do this, use the ``REFERENCE`` typemap. For example:

.. container:: code

   ::

      %module example
      %include "typemaps.i"

      void add(int x, int y, int *REFERENCE);

In Perl:

.. container:: targetlang

   ::

      use example;
      $c = 0.0;
      example::add(3, 4, \$c);
      print "$c\n";
      7

**Note:** The ``REFERENCE`` feature is only currently supported for
numeric types (integers and floating point).

Exception handling
-----------------------

The SWIG ``%exception`` directive can be used to create a user-definable
exception handler for converting exceptions in your C/C++ program into
Perl exceptions. The chapter on customization features contains more
details, but suppose you have a C++ class like the following:

.. container:: code

   ::

      class RangeError {};   // Used for an exception

      class DoubleArray {
        private:
          int n;
          double *ptr;
        public:
          // Create a new array of fixed size
          DoubleArray(int size) {
            ptr = new double[size];
            n = size;
          }
          // Destroy an array
          ~DoubleArray() {
            delete ptr;
          }
          // Return the length of the array
          int   length() {
            return n;
          }

          // Get an item from the array and perform bounds checking.
          double getitem(int i) {
            if ((i >= 0) && (i < n))
              return ptr[i];
            else
              throw RangeError();
          }

          // Set an item in the array and perform bounds checking.
          void setitem(int i, double val) {
            if ((i >= 0) && (i < n))
              ptr[i] = val;
            else
              throw RangeError();
          }
        };

Since several methods in this class can throw an exception for an
out-of-bounds access, you might want to catch this in the Perl extension
by writing the following in an interface file:

.. container:: code

   ::

      %exception {
        try {
          $action
        }
        catch (RangeError) {
          croak("Array index out-of-bounds");
        }
      }

      class DoubleArray {
      ...
      };

The exception handling code is inserted directly into generated wrapper
functions. The ``$action`` variable is replaced with the C/C++ code
being executed by the wrapper. When an exception handler is defined,
errors can be caught and used to gracefully generate a Perl error
instead of forcing the entire program to terminate with an uncaught
error.

As shown, the exception handling code will be added to every wrapper
function. Since this is somewhat inefficient. You might consider
refining the exception handler to only apply to specific methods like
this:

.. container:: code

   ::

      %exception getitem {
        try {
          $action
        }
        catch (RangeError) {
          croak("Array index out-of-bounds");
        }
      }

      %exception setitem {
        try {
          $action
        }
        catch (RangeError) {
          croak("Array index out-of-bounds");
        }
      }

In this case, the exception handler is only attached to methods and
functions named ``getitem`` and ``setitem``.

If you had a lot of different methods, you can avoid extra typing by
using a macro. For example:

.. container:: code

   ::

      %define RANGE_ERROR
      {
        try {
          $action
        }
        catch (RangeError) {
          croak("Array index out-of-bounds");
        }
      }
      %enddef

      %exception getitem RANGE_ERROR;
      %exception setitem RANGE_ERROR;

Since SWIG's exception handling is user-definable, you are not limited
to C++ exception handling. See the chapter on "`Customization
features <Customization.html#Customization>`__" for more examples.

**Compatibility note:** In SWIG1.1, exceptions were defined using the
older ``%except`` directive:

.. container:: code

   ::

      %except(python) {
        try {
          $function
        }
        catch (RangeError) {
          croak("Array index out-of-bounds");
        }
      }

This is still supported, but it is deprecated. The newer ``%exception``
directive provides the same functionality, but it has additional
capabilities that make it more powerful.

Remapping datatypes with typemaps
--------------------------------------

This section describes how you can modify SWIG's default wrapping
behavior for various C/C++ datatypes using the ``%typemap`` directive.
This is an advanced topic that assumes familiarity with the Perl C API
as well as the material in the "`Typemaps <Typemaps.html#Typemaps>`__"
chapter.

Before proceeding, it should be stressed that typemaps are *not* a
required part of using SWIG---the default wrapping behavior is enough in
most cases. Typemaps are only used if you want to change some aspect of
the primitive C-Perl interface.

A simple typemap example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A typemap is nothing more than a code generation rule that is attached
to a specific C datatype. For example, to convert integers from Perl to
C, you might define a typemap like this:

.. container:: code

   ::

      %module example

      %typemap(in) int {
        $1 = (int) SvIV($input);
        printf("Received an integer : %d\n", $1);
      }
      ...
      %inline %{
      extern int fact(int n);
      %}

Typemaps are always associated with some specific aspect of code
generation. In this case, the "in" method refers to the conversion of
input arguments to C/C++. The datatype ``int`` is the datatype to which
the typemap will be applied. The supplied C code is used to convert
values. In this code a number of special variable prefaced by a ``$``
are used. The ``$1`` variable is placeholder for a local variable of
type ``int``. The ``$input`` variable is the input object (usually a
``SV *``).

When this example is used in Perl5, it will operate as follows:

.. container:: targetlang

   ::

      use example;
      $n = example::fact(6);
      print "$n\n";
      ...

      Output:
      Received an integer : 6
      720

The application of a typemap to specific datatypes and argument names
involves more than simple text-matching--typemaps are fully integrated
into the SWIG type-system. When you define a typemap for ``int``, that
typemap applies to ``int`` and qualified variations such as
``const int``. In addition, the typemap system follows ``typedef``
declarations. For example:

.. container:: targetlang

   ::

      %typemap(in) int n {
        $1 = (int) SvIV($input);
        printf("n = %d\n", $1);
      }
      %inline %{
      typedef int Integer;
      extern int fact(Integer n);    // Above typemap is applied
      %}

It should be noted that the matching of ``typedef`` only occurs in one
direction. If you defined a typemap for ``Integer``, it is not applied
to arguments of type ``int``.

Typemaps can also be defined for groups of consecutive arguments. For
example:

.. container:: targetlang

   ::

      %typemap(in) (char *str, unsigned len) {
          $1 = SvPV($input, $2);
      };

      int count(char c, char *str, unsigned len);

When a multi-argument typemap is defined, the arguments are always
handled as a single Perl object. This allows the function to be used
like this (notice how the length parameter is omitted):

.. container:: targetlang

   ::

      example::count("e", "Hello World");
      1
      >>>

Perl5 typemaps
~~~~~~~~~~~~~~~~~~~~~

The previous section illustrated an "in" typemap for converting Perl
objects to C. A variety of different typemap methods are defined by the
Perl module. For example, to convert a C integer back into a Perl
object, you might define an "out" typemap like this:

.. container:: targetlang

   ::

      %typemap(out) int {
        $result = sv_newmortal();
        sv_setiv($result, (IV) $1);
        argvi++;
      }

The following typemap methods are available:

``%typemap(in)``

.. container:: indent

   Converts Perl5 object to input function arguments.

``%typemap(out)``

.. container:: indent

   Converts function return value to a Perl5 value.

``%typemap(varin)``

.. container:: indent

   Converts a Perl5 object to a global variable.

``%typemap(varout)``

.. container:: indent

   Converts a global variable to a Perl5 object.

``%typemap(freearg)``

.. container:: indent

   Cleans up a function argument after a function call

``%typemap(argout)``

.. container:: indent

   Output argument handling

``%typemap(ret)``

.. container:: indent

   Clean up return value from a function.

``%typemap(memberin)``

.. container:: indent

   Setting of C++ member data (all languages).

``%typemap(memberout)``

.. container:: indent

   Return of C++ member data (all languages).

``%typemap(check)``

.. container:: indent

   Check value of input parameter.

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
   the raw result that's supposed to be returned to Perl.

``$input``

.. container:: indent

   A Perl object holding the value of an argument of variable value.

``$result``

.. container:: indent

   A Perl object that holds the result to be returned to Perl.

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

   The Perl name of the wrapper function being created.

Useful functions
~~~~~~~~~~~~~~~~~~~~~~~

When writing typemaps, it is necessary to work directly with Perl5
objects. This, unfortunately, can be a daunting task. Consult the
"perlguts" man-page for all of the really ugly details. A short summary
of commonly used functions is provided here for reference. It should be
stressed that SWIG can be used quite effectively without knowing any of
these details--especially now that there are typemap libraries that can
already been written.

**Perl Integer Functions**

.. container:: code

   ::

      int   SvIV(SV *);
      void  sv_setiv(SV *sv, IV value);
      SV   *newSViv(IV value);
      int   SvIOK(SV *);

**Perl Floating Point Functions**

.. container:: code

   ::

      double SvNV(SV *);
      void   sv_setnv(SV *, double value);
      SV    *newSVnv(double value);
      int    SvNOK(SV *);

**Perl String Functions**

.. container:: code

   ::

      char     *SvPV(SV *, STRLEN len);
      void      sv_setpv(SV *, char *val);
      void      sv_setpvn(SV *, char *val, STRLEN len);
      SV       *newSVpv(char *value, STRLEN len);
      int       SvPOK(SV *);
      void      sv_catpv(SV *, char *);
      void      sv_catpvn(SV *, char *, STRLEN);

**Perl References**

.. container:: code

   ::

      void      sv_setref_pv(SV *, char *, void *ptr);
      int       sv_isobject(SV *);
      SV       *SvRV(SV *);
      int       sv_isa(SV *, char *0;

Typemap Examples
---------------------

This section includes a few examples of typemaps. For more examples, you
might look at the files "``perl5.swg``" and "``typemaps.i``" in the SWIG
library.

Converting a Perl5 array to a char \*\*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A common problem in many C programs is the processing of command line
arguments, which are usually passed in an array of NULL terminated
strings. The following SWIG interface file allows a Perl5 array
reference to be used as a char \*\* datatype.

.. container:: code

   ::

      %module argv

      // This tells SWIG to treat char ** as a special case
      %typemap(in) char ** {
        AV *tempav;
        I32 len;
        int i;
        SV  **tv;
        if (!SvROK($input))
          croak("Argument $argnum is not a reference.");
        if (SvTYPE(SvRV($input)) != SVt_PVAV)
          croak("Argument $argnum is not an array.");
        tempav = (AV*)SvRV($input);
        len = av_len(tempav);
        $1 = (char **) malloc((len+2)*sizeof(char *));
        for (i = 0; i <= len; i++) {
          tv = av_fetch(tempav, i, 0);
          $1[i] = (char *) SvPV(*tv, PL_na);
        }
        $1[i] = NULL;
      };

      // This cleans up the char ** array after the function call
      %typemap(freearg) char ** {
        free($1);
      }

      // Creates a new Perl array and places a NULL-terminated char ** into it
      %typemap(out) char ** {
        AV *myav;
        SV **svs;
        int i = 0, len = 0;
        /* Figure out how many elements we have */
        while ($1[len])
          len++;
        svs = (SV **) malloc(len*sizeof(SV *));
        for (i = 0; i < len ; i++) {
          svs[i] = sv_newmortal();
          sv_setpv((SV*)svs[i], $1[i]);
        };
        myav = av_make(len, svs);
        free(svs);
        $result = newRV_noinc((SV*)myav);
        sv_2mortal($result);
        argvi++;
      }

      // Now a few test functions
      %inline %{
        int print_args(char **argv) {
          int i = 0;
          while (argv[i]) {
            printf("argv[%d] = %s\n", i, argv[i]);
            i++;
          }
          return i;
        }

        // Returns a char ** list
        char **get_args() {
          static char *values[] = { "Dave", "Mike", "Susan", "John", "Michelle", 0};
          return &values[0];
        }
      %}

When this module is compiled, the wrapped C functions can be used in a
Perl script as follows:

.. container:: targetlang

   ::

      use argv;
      @a = ("Dave", "Mike", "John", "Mary");           # Create an array of strings
      argv::print_args(\@a);                           # Pass it to our C function
      $b = argv::get_args();                           # Get array of strings from C
      print @$b, "\n";                                 # Print it out

Return values
~~~~~~~~~~~~~~~~~~~~

Return values are placed on the argument stack of each wrapper function.
The current value of the argument stack pointer is contained in a
variable ``argvi``. Whenever a new output value is added, it is critical
that this value be incremented. For multiple output values, the final
value of ``argvi`` should be the total number of output values.

The total number of return values should not exceed the number of input
values unless you explicitly extend the argument stack. This can be done
using the ``EXTEND()`` macro as in:

.. container:: code

   ::

      %typemap(argout) int *OUTPUT {
        if (argvi >= items) {
          EXTEND(sp, 1);              /* Extend the stack by 1 object */
        }
        $result = sv_newmortal();
        sv_setiv($target, (IV) *($1));
        argvi++;
      }

Returning values from arguments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes it is desirable for a function to return a value in one of its
arguments. This example describes the implementation of the ``OUTPUT``
typemap.

.. container:: code

   ::

      %module return

      // This tells SWIG to treat an double * argument with name 'OutDouble' as
      // an output value.  

      %typemap(argout) double *OUTPUT {
        $result = sv_newmortal();
        sv_setnv($result, *$input);
        argvi++;                     /* Increment return count -- important! */
      }

      // We don't care what the input value is. Ignore, but set to a temporary variable

      %typemap(in, numinputs=0) double *OUTPUT(double junk) {
        $1 = &junk;
      }

      // Now a function to test it
      %{
      /* Returns the first two input arguments */
      int multout(double a, double b, double *out1, double *out2) {
        *out1 = a;
        *out2 = b;
        return 0;
      };
      %}

      // If we name both parameters OutDouble both will be output

      int multout(double a, double b, double *OUTPUT, double *OUTPUT);
      ...

When this function is called, the output arguments are appended to the
stack used to return results. This shows up an array in Perl. For
example:

.. container:: targetlang

   ::

      @r = multout(7, 13);
      print "multout(7, 13) = @r\n";
      ($x, $y) = multout(7, 13);

Accessing array structure members
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Consider the following data structure:

.. container:: code

   ::

      #define SIZE  8
      typedef struct {
        int   values[SIZE];
        ...
      } Foo;

By default, SWIG doesn't know how to the handle the values structure
member it's an array, not a pointer. In this case, SWIG makes the array
member read-only. Reading will simply return a pointer to the first item
in the array. To make the member writable, a "memberin" typemap can be
used.

.. container:: code

   ::

      %typemap(memberin) int [SIZE] {
        int i;
        for (i = 0; i < SIZE; i++) {
          $1[i] = $input[i];
        }
      }

Whenever a ``int [SIZE]`` member is encountered in a structure or class,
this typemap provides a safe mechanism for setting its value.

As in the previous example, the typemap can be generalized for any
dimension. For example:

.. container:: code

   ::

      %typemap(memberin) int [ANY] {
        int i;
        for (i = 0; i < $1_dim0; i++) {
          $1[i] = $input[i];
        }
      }

When setting structure members, the input object is always assumed to be
a C array of values that have already been converted from the target
language. Because of this, the ``memberin`` typemap is almost always
combined with the use of an "in" typemap. For example, the "in" typemap
in the previous section would be used to convert an ``int[]`` array to C
whereas the "memberin" typemap would be used to copy the converted array
into a C data structure.

Turning Perl references into C pointers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A frequent confusion on the SWIG mailing list is errors caused by the
mixing of Perl references and C pointers. For example, suppose you have
a C function that modifies its arguments like this:

.. container:: code

   ::

      void add(double a, double b, double *c) {
        *c = a + b;
      }

A common misinterpretation of this function is the following Perl
script:

.. container:: targetlang

   ::

      # Perl script
      $a = 3.5;
      $b = 7.5;
      $c = 0.0;          # Output value
      add($a, $b, \$c);    # Place result in c (Except that it doesn't work)

To make this work with a reference, you can use a typemap such as this:

.. container:: code

   ::

      %typemap(in) double * (double dvalue) {
        SV* tempsv;
        if (!SvROK($input)) {
          croak("expected a reference\n");
        }
        tempsv = SvRV($input);
        if ((!SvNOK(tempsv)) && (!SvIOK(tempsv))) {
          croak("expected a double reference\n");
        }
        dvalue = SvNV(tempsv);
        $1 = &dvalue;
      }

      %typemap(argout) double * {
        SV *tempsv;
        tempsv = SvRV($input);
        sv_setnv(tempsv, *$1);
      }

Now, if you place this before the add function, you can do this:

.. container:: targetlang

   ::

      $a = 3.5;
      $b = 7.5;
      $c = 0.0;
      add($a, $b, \$c);            # Now it works!
      print "$c\n";

Pointer handling
~~~~~~~~~~~~~~~~~~~~~~~

Occasionally, it might be necessary to convert pointer values that have
been stored using the SWIG typed-pointer representation. To convert a
pointer from Perl to C, the following function is used:

``int SWIG_ConvertPtr(SV *obj, void **ptr, swig_type_info *ty, int flags)``

.. container:: indent

   Converts a Perl object ``obj`` to a C pointer. The result of the
   conversion is placed into the pointer located at ``ptr``. ``ty`` is a
   SWIG type descriptor structure. ``flags`` is used to handle error
   checking and other aspects of conversion. ``flags`` is currently
   undefined and reserved for future expansion. Returns 0 on success and
   -1 on error.

``void *SWIG_MakePtr(SV *obj, void *ptr, swig_type_info *ty, int flags)``

.. container:: indent

   Creates a new Perl pointer object. ``obj`` is a Perl SV that has been
   initialized to hold the result, ``ptr`` is the pointer to convert,
   ``ty`` is the SWIG type descriptor structure that describes the type,
   and ``flags`` is a flag that controls properties of the conversion.
   ``flags`` is currently undefined and reserved.

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

      SV *sv = sv_newmortal();
      SWIG_MakePtr(sv, f, SWIGTYPE_p_Foo, 0);

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

Proxy classes
------------------

**Out of date. Needs update.**

Using the low-level procedural interface, SWIG can also construct a
high-level object oriented interface to C structures and C++ classes.
This is done by constructing a Perl proxy class (also known as a shadow
class) that provides an OO wrapper to the underlying code. This section
describes the implementation details of the proxy interface.

.. _preliminaries-1:

Preliminaries
~~~~~~~~~~~~~~~~~~~~

Proxy classes, are generated by default. If you want to turn them off,
use the ``-noproxy`` command line option. For example:

.. container:: code

   ::

      $ swig -c++ -perl -noproxy example.i

When proxy classes are used, SWIG moves all of the low-level procedural
wrappers to another package name. By default, this package is named
'modulec' where 'module' is the name of the module you provided with the
``%module`` directive. Then, in place of the original module, SWIG
creates a collection of high-level Perl wrappers. In your scripts, you
will use these high level wrappers. The wrappers, in turn, interact with
the low-level procedural module.

Structure and class wrappers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Suppose you have the following SWIG interface file:

.. container:: code

   ::

      %module example
      struct Vector {
        Vector(double x, double y, double z);
        ~Vector();
        double x, y, z;
      };

When wrapped, SWIG creates the following set of low-level accessor
functions as described in previous sections.

.. container:: code

   ::

      Vector *new_Vector(double x, double y, double z);
      void    delete_Vector(Vector *v);
      double  Vector_x_get(Vector *v);
      double  Vector_x_set(Vector *v, double value);
      double  Vector_y_get(Vector *v);
      double  Vector_y_set(Vector *v, double value);
      double  Vector_z_get(Vector *v);
      double  Vector_z_set(Vector *v, double value);

However, when proxy classes are enabled, these accessor functions are
wrapped inside a Perl class like this:

.. container:: targetlang

   ::

      package example::Vector;
      @ISA = qw( example );
      %OWNER = ();
      %BLESSEDMEMBERS = ();

      sub new () {
        my $self = shift;
        my @args = @_;
        $self = vectorc::new_Vector(@args);
        return undef if (!defined($self));
        bless $self, "example::Vector";
        $OWNER{$self} = 1;
        my %retval;
        tie %retval, "example::Vector", $self;
        return bless \%retval, "Vector";
      }

      sub DESTROY {
        return unless $_[0]->isa('HASH');
        my $self = tied(%{$_[0]});
        delete $ITERATORS{$self};
        if (exists $OWNER{$self}) {
          examplec::delete_Vector($self));
          delete $OWNER{$self};
        }
      }

      sub FETCH {
        my ($self, $field) = @_;
        my $member_func = "vectorc::Vector_${field}_get";
        my $val = &$member_func($self);
        if (exists $BLESSEDMEMBERS{$field}) {
          return undef if (!defined($val));
          my %retval;
          tie %retval, $BLESSEDMEMBERS{$field}, $val;
          return bless \%retval, $BLESSEDMEMBERS{$field};
        }
        return $val;
      }

      sub STORE {
        my ($self, $field, $newval) = @_;
        my $member_func = "vectorc::Vector_${field}_set";
        if (exists $BLESSEDMEMBERS{$field}) {
          &$member_func($self, tied(%{$newval}));
        } else {
          &$member_func($self, $newval);
        }
      }

Each structure or class is mapped into a Perl package of the same name.
The C++ constructors and destructors are mapped into constructors and
destructors for the package and are always named "new" and "DESTROY".
The constructor always returns a tied hash table. This hash table is
used to access the member variables of a structure in addition to being
able to invoke member functions. The ``%OWNER`` and ``%BLESSEDMEMBERS``
hash tables are used internally and described shortly.

To use our new proxy class we can simply do the following:

.. container:: targetlang

   ::

      # Perl code using Vector class
      $v = new Vector(2, 3, 4);
      $w = Vector->new(-1, -2, -3);

      # Assignment of a single member
      $v->{x} = 7.5;

      # Assignment of all members
      %$v = ( x=>3,
              y=>9,
              z=>-2);

      # Reading members
      $x = $v->{x};

      # Destruction
      $v->DESTROY();

Object Ownership
~~~~~~~~~~~~~~~~~~~~~~~

In order for proxy classes to work properly, it is necessary for Perl to
manage some mechanism of object ownership. Here's the crux of the
problem---suppose you had a function like this:

.. container:: code

   ::

      Vector *Vector_get(Vector *v, int index) {
        return &v[i];
      }

This function takes a Vector pointer and returns a pointer to another
Vector. Such a function might be used to manage arrays or lists of
vectors (in C). Now contrast this function with the constructor for a
Vector object:

.. container:: code

   ::

      Vector *new_Vector(double x, double y, double z) {
        Vector *v;
        v = new Vector(x, y, z);        // Call C++ constructor
        return v;
      }

Both functions return a Vector, but the constructor is returning a
brand-new Vector while the other function is returning a Vector that was
already created (hopefully). In Perl, both vectors will be
indistinguishable---clearly a problem considering that we would probably
like the newly created Vector to be destroyed when we are done with it.

To manage these problems, each class contains two methods that access an
internal hash table called ``%OWNER``. This hash keeps a list of all of
the objects that Perl knows that it has created. This happens in two
cases: (1) when the constructor has been called, and (2) when a function
implicitly creates a new object (as is done when SWIG needs to return a
complex datatype by value). When the destructor is invoked, the Perl
proxy class module checks the ``%OWNER`` hash to see if Perl created the
object. If so, the C/C++ destructor is invoked. If not, we simply
destroy the Perl object and leave the underlying C object alone (under
the assumption that someone else must have created it).

This scheme works remarkably well in practice but it isn't foolproof. In
fact, it will fail if you create a new C object in Perl, pass it on to a
C function that remembers the object, and then destroy the corresponding
Perl object (this situation turns out to come up frequently when
constructing objects like linked lists and trees). When C takes
possession of an object, you can change Perl's ownership by simply
deleting the object from the ``%OWNER`` hash. This is done using the
``DISOWN`` method.

.. container:: targetlang

   ::

      # Perl code to change ownership of an object
      $v = new Vector(x, y, z);
      $v->DISOWN();     

To acquire ownership of an object, the ``ACQUIRE`` method can be used.

.. container:: targetlang

   ::

      # Given Perl ownership of a file
      $u = Vector_get($v);
      $u->ACQUIRE();

As always, a little care is in order. SWIG does not provide reference
counting, garbage collection, or advanced features one might find in
sophisticated languages.

Nested Objects
~~~~~~~~~~~~~~~~~~~~~

Suppose that we have a new object that looks like this:

.. container:: code

   ::

      struct Particle {
        Vector r;
        Vector v;
        Vector f;
        int type;
      }

In this case, the members of the structure are complex objects that have
already been encapsulated in a Perl proxy class. To handle these
correctly, we use the ``%BLESSEDMEMBERS`` hash which would look like
this (along with some supporting code):

.. container:: targetlang

   ::

      package Particle;
      ...
      %BLESSEDMEMBERS = (
              r => `Vector',
              v => `Vector',
              f => `Vector',
      );

When fetching members from the structure, ``%BLESSEDMEMBERS`` is
checked. If the requested field is present, we create a tied-hash table
and return it. If not, we just return the corresponding member
unmodified.

This implementation allows us to operate on nested structures as
follows:

.. container:: targetlang

   ::

      # Perl access of nested structure
      $p = new Particle();
      $p->{f}->{x} = 0.0;
      %${$p->{v}} = ( x=>0, y=>0, z=>0);         

Proxy Functions
~~~~~~~~~~~~~~~~~~~~~~

When functions take arguments involving a complex object, it is
sometimes necessary to write a proxy function. For example:

.. container:: code

   ::

      double dot_product(Vector *v1, Vector *v2);

Since Vector is an object already wrapped into a proxy class, we need to
modify this function to accept arguments that are given in the form of
tied hash tables. This is done by creating a Perl function like this:

.. container:: targetlang

   ::

      sub dot_product {
        my @args = @_;
        $args[0] = tied(%{$args[0]});         # Get the real pointer values
        $args[1] = tied(%{$args[1]});
        my $result = vectorc::dot_product(@args);
        return $result;
      }

This function replaces the original function, but operates in an
identical manner.

Inheritance
~~~~~~~~~~~~~~~~~~

Simple C++ inheritance is handled using the Perl ``@ISA`` array in each
class package. For example, if you have the following interface file:

.. container:: code

   ::

      // shapes.i
      // SWIG interface file for shapes class
      %module shapes
      %{
      #include "shapes.h"
      %}

      class Shape {
      public:
        virtual double area() = 0;
        virtual double perimeter() = 0;
        void    set_location(double x, double y);
      };
      class Circle : public Shape {
      public:
        Circle(double radius);
        ~Circle();
        double area();
        double perimeter();
      };
      class Square : public Shape {
      public:
        Square(double size);
        ~Square();
        double area();
        double perimeter();
      }

The resulting, Perl wrapper class will create the following code:

.. container:: targetlang

   ::

      Package Shape;
      @ISA = (shapes);
      ...
      Package Circle;
      @ISA = (shapes Shape);
      ...
      Package Square;
      @ISA = (shapes Shape);

The ``@ISA`` array determines where to look for methods of a particular
class. In this case, both the ``Circle`` and ``Square`` classes inherit
functions from ``Shape`` so we'll want to look in the ``Shape`` base
class for them. All classes also inherit from the top-level module
``shapes``. This is because certain common operations needed to
implement proxy classes are implemented only once and reused in the
wrapper code for various classes and structures.

Since SWIG proxy classes are implemented in Perl, it is easy to subclass
from any SWIG generated class. To do this, simply put the name of a SWIG
class in the ``@ISA`` array for your new class. However, be forewarned
that this is not a trivial problem. In particular, inheritance of data
members is extremely tricky (and I'm not even sure if it really works).

Modifying the proxy methods
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is possible to override the SWIG generated proxy/shadow methods,
using ``%feature("shadow")``. It works like all the other `%feature
directives <Customization.html#Customization_features>`__. Here is a
simple example showing how to add some Perl debug code to the
constructor:

.. container:: targetlang

   ::

      /* Let's make the constructor of the class Square more verbose */
      %feature("shadow") Square(double w)
      %{
        sub new {
          my $pkg = shift;
          my $self = examplec::new_Square(@_);
          print STDERR "Constructed an @{[ref($self)]}\n";
          bless $self, $pkg if defined($self);
        }
      %}

      class Square {
      public:
        Square(double w);
        ...
      };

Adding additional Perl code
---------------------------------

If writing support code in C isn't enough, it is also possible to write
code in Perl. This code gets inserted in to the ``.pm`` file created by
SWIG. One use of Perl code might be to supply a high-level interface to
certain functions. For example:

.. container:: code

   ::

      void set_transform(Image *im, double x[4][4]);

      ...
      /* Rewrite the high level interface to set_transform */
      %perlcode %{
      sub set_transform
      {
        my ($im, $x) = @_;
        my $a = new_mat44();
        for (my $i = 0; $i < 4, $i++)
        {
          for (my $j = 0; $j < 4, $j++)
          {
            mat44_set($a, $i, $j, $x->[i][j])
          }
        }
        example.set_transform($im, $a);
        free_mat44($a);
      }
      %}

In this example, ``set_transform()`` provides a high-level Perl
interface built on top of low-level helper functions. For example, this
code now seems to work:

.. container:: targetlang

   ::

      my $a =
        [[1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]];
      set_transform($im, $a);

Cross language polymorphism
---------------------------------

Proxy classes provide a more natural, object-oriented way to access
extension classes. As described above, each proxy instance has an
associated C++ instance, and method calls to the proxy are passed to the
C++ instance transparently via C wrapper functions.

This arrangement is asymmetric in the sense that no corresponding
mechanism exists to pass method calls down the inheritance chain from
C++ to Perl. In particular, if a C++ class has been extended in Perl (by
extending the proxy class), these extensions will not be visible from
C++ code. Virtual method calls from C++ are thus not able access the
lowest implementation in the inheritance chain.

Changes have been made to SWIG to address this problem and make the
relationship between C++ classes and proxy classes more symmetric. To
achieve this goal, new classes called directors are introduced at the
bottom of the C++ inheritance chain. The job of the directors is to
route method calls correctly, either to C++ implementations higher in
the inheritance chain or to Perl implementations lower in the
inheritance chain. The upshot is that C++ classes can be extended in
Perl and from C++ these extensions look exactly like native C++ classes.
Neither C++ code nor Perl code needs to know where a particular method
is implemented: the combination of proxy classes, director classes, and
C wrapper functions takes care of all the cross-language method routing
transparently.

Enabling directors
~~~~~~~~~~~~~~~~~~~~~~~~~~

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

then at the Perl side you can define

.. container:: targetlang

   ::

      use mymodule;

      package MyFoo;
      use base 'mymodule::Foo';

      sub one {
        print "one from Perl\n";
      }

Director classes
~~~~~~~~~~~~~~~~~~~~~~~~

For each class that has directors enabled, SWIG generates a new class
that derives from both the class in question and a special
``Swig::Director`` class. These new classes, referred to as director
classes, can be loosely thought of as the C++ equivalent of the Perl
proxy classes. The director classes store a pointer to their underlying
Perl object and handle various issues related to object ownership.

For simplicity let's ignore the ``Swig::Director`` class and refer to
the original C++ class as the director's base class. By default, a
director class extends all virtual methods in the inheritance chain of
its base class (see the preceding section for how to modify this
behavior). Virtual methods that have a final specifier are
unsurprisingly excluded. Thus the virtual method calls, whether they
originate in C++ or in Perl via proxy classes, eventually end up in at
the implementation in the director class. The job of the director
methods is to route these method calls to the appropriate place in the
inheritance chain. By "appropriate place" we mean the method that would
have been called if the C++ base class and its extensions in Perl were
seamlessly integrated. That seamless integration is exactly what the
director classes provide, transparently skipping over all the messy
extension API glue that binds the two languages together.

In reality, the "appropriate place" is one of only two possibilities:
C++ or Perl. Once this decision is made, the rest is fairly easy. If the
correct implementation is in C++, then the lowest implementation of the
method in the C++ inheritance chain is called explicitly. If the correct
implementation is in Perl, the Perl API is used to call the method of
the underlying Perl object (after which the usual virtual method
resolution in Perl automatically finds the right implementation).

Now how does the director decide which language should handle the method
call? The basic rule is to handle the method in Perl, unless there's a
good reason not to. The reason for this is simple: Perl has the most
"extended" implementation of the method. This assertion is guaranteed,
since at a minimum the Perl proxy class implements the method. If the
method in question has been extended by a class derived from the proxy
class, that extended implementation will execute exactly as it should.
If not, the proxy class will route the method call into a C wrapper
function, expecting that the method will be resolved in C++. The wrapper
will call the virtual method of the C++ instance, and since the director
extends this the call will end up right back in the director method. Now
comes the "good reason not to" part. If the director method were to
blindly call the Perl method again, it would get stuck in an infinite
loop. We avoid this situation by adding special code to the C wrapper
function that tells the director method to not do this. The C wrapper
function compares the pointer to the Perl object that called the wrapper
function to the pointer stored by the director. If these are the same,
then the C wrapper function tells the director to resolve the method by
calling up the C++ inheritance chain, preventing an infinite loop.

One more point needs to be made about the relationship between director
classes and proxy classes. When a proxy class instance is created in
Perl, SWIG creates an instance of the original C++ class. This is
exactly what happens without directors and is true even if directors are
enabled for the particular class in question. When a class *derived*
from a proxy class is created, however, SWIG then creates an instance of
the corresponding C++ director class. The reason for this difference is
that user-defined subclasses may override or extend methods of the
original class, so the director class is needed to route calls to these
methods correctly. For unmodified proxy classes, all methods are
ultimately implemented in C++ so there is no need for the extra overhead
involved with routing the calls through Perl.

Ownership and object destruction
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Memory management issues are slightly more complicated with directors
than for proxy classes alone. Perl instances hold a pointer to the
associated C++ director object, and the director in turn holds a pointer
back to a Perl object. By default, proxy classes own their C++ director
object and take care of deleting it when they are garbage collected.

This relationship can be reversed by calling the special ``DISOWN()``
method of the proxy class. After calling this method the director class
increments the reference count of the Perl object. When the director
class is deleted it decrements the reference count. Assuming no
outstanding references to the Perl object remain, the Perl object will
be destroyed at the same time. This is a good thing, since directors and
proxies refer to each other and so must be created and destroyed
together. Destroying one without destroying the other will likely cause
your program to segfault.

Also note that due to the proxy implementation, the ``DESTROY()`` method
on directors can be called for several reasons, many of which have
little to do with the teardown of an object instance. To help
disambiguate this, a second argument is added to the ``DESTROY()`` call
when a C++ director object is being released. So, to avoid running your
clean-up code when an object is not really going away, or after it has
already been reclaimed, it is suggested that custom destructors in Perl
subclasses looks something like:

.. container:: targetlang

   ::

      sub DESTROY {
        my($self, $final) = @_;
        if($final) {
          # real teardown code
        }
        shift->SUPER::DESTROY(@_);
      }

Exception unrolling
~~~~~~~~~~~~~~~~~~~~~~~~~~~

With directors routing method calls to Perl, and proxies routing them to
C++, the handling of exceptions is an important concern. By default, the
directors ignore exceptions that occur during method calls that are
resolved in Perl. To handle such exceptions correctly, it is necessary
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

This code will check the Perl error state after each method call from a
director into Perl, and throw a C++ exception if an error occurred. This
exception can be caught in C++ to implement an error handler.

It may be the case that a method call originates in Perl, travels up to
C++ through a proxy class, and then back into Perl via a director
method. If an exception occurs in Perl at this point, it would be nice
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
exception. Because the Perl error state is still set when
Swig::DirectorMethodException is thrown, Perl will register the
exception as soon as the C wrapper function returns.

Overhead and code bloat
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enabling directors for a class will generate a new director method for
every virtual method in the class' inheritance chain. This alone can
generate a lot of code bloat for large hierarchies. Method arguments
that require complex conversions to and from target language types can
result in large director methods. For this reason it is recommended that
you selectively enable directors only for specific classes that are
likely to be extended in Perl and used in C++.

Compared to classes that do not use directors, the call routing in the
director methods does add some overhead. In particular, at least one
dynamic cast and one extra function call occurs per method call from
Perl. Relative to the speed of Perl execution this is probably
completely negligible. For worst case routing, a method call that
ultimately resolves in C++ may take one extra detour through Perl in
order to ensure that the method does not have an extended Perl
implementation. This could result in a noticeable overhead in some
cases.

Although directors make it natural to mix native C++ objects with Perl
objects (as director objects) via a common base class pointer, one
should be aware of the obvious fact that method calls to Perl objects
will be much slower than calls to C++ objects. This situation can be
optimized by selectively enabling director methods (using the %feature
directive) for only those methods that are likely to be extended in
Perl.

Typemaps
~~~~~~~~~~~~~~~~

Typemaps for input and output of most of the basic types from director
classes have been written. These are roughly the reverse of the usual
input and output typemaps used by the wrapper code. The typemap
operation names are 'directorin', 'directorout', and 'directorargout'.
The director code does not currently use any of the other kinds of
typemaps. It is not clear at this point which kinds are appropriate and
need to be supported.

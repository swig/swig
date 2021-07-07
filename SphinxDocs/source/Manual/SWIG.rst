5 SWIG Basics
=============

This chapter describes the basic operation of SWIG, the structure of its
input files, and how it handles standard ISO C declarations. C++ support
is described in the next chapter. However, C++ programmers should still
read this chapter to understand the basics. Specific details about each
target language are described in later chapters.

Running SWIG
----------------

To run SWIG, use the ``swig`` command with options and a filename like
this:

.. container:: shell

   ::

      swig [ options ] filename

where ``filename`` is a SWIG interface file or a C/C++ header file. Full
help can be seen by running ``swig -help``. Below is the common set of
options that can be used. Additional options are also defined for each
target language. A full list can be obtained by running
``swig -<lang> -help`` for language *<lang>* specific options, for
example, ``swig -ruby -help`` for Ruby.

.. container:: shell

   ::

      Supported Target Language Options
           -csharp         - Generate C# wrappers
           -d              - Generate D wrappers
           -go             - Generate Go wrappers
           -guile          - Generate Guile wrappers
           -java           - Generate Java wrappers
           -javascript     - Generate Javascript wrappers
           -lua            - Generate Lua wrappers
           -octave         - Generate Octave wrappers
           -perl5          - Generate Perl 5 wrappers
           -php7           - Generate PHP 7 wrappers
           -python         - Generate Python wrappers
           -r              - Generate R (aka GNU S) wrappers
           -ruby           - Generate Ruby wrappers
           -scilab         - Generate Scilab wrappers
           -tcl8           - Generate Tcl 8 wrappers
           -xml            - Generate XML wrappers

      Experimental Target Language Options
           -mzscheme       - Generate MzScheme/Racket wrappers
           -ocaml          - Generate OCaml wrappers

      General Options
           -addextern      - Add extra extern declarations
           -c++            - Enable C++ processing
           -co <file>      - Check <file> out of the SWIG library
           -copyctor       - Automatically generate copy constructors wherever possible
           -cpperraswarn   - Treat the preprocessor #error statement as #warning (default)
           -cppext <ext>   - Change file extension of generated C++ files to <ext>
                             (default is cxx)
           -copyright      - Display copyright notices
           -debug-classes  - Display information about the classes found in the interface
           -debug-module <n>- Display module parse tree at stages 1-4, <n> is a csv list of stages
           -debug-symtabs  - Display symbol tables information
           -debug-symbols  - Display target language symbols in the symbol tables
           -debug-csymbols - Display C symbols in the symbol tables
           -debug-lsymbols - Display target language layer symbols
           -debug-tags     - Display information about the tags found in the interface
           -debug-template - Display information for debugging templates
           -debug-top <n>  - Display entire parse tree at stages 1-4, <n> is a csv list of stages
           -debug-typedef  - Display information about the types and typedefs in the interface
           -debug-typemap  - Display typemap debugging information
           -debug-tmsearch - Display typemap search debugging information
           -debug-tmused   - Display typemaps used debugging information
           -directors      - Turn on director mode for all the classes, mainly for testing
           -dirprot        - Turn on wrapping of protected members for director classes (default)
           -D<symbol>      - Define a symbol <symbol> (for conditional compilation)
           -E              - Preprocess only, does not generate wrapper code
           -external-runtime [file] - Export the SWIG runtime stack
           -fakeversion <v>- Make SWIG fake the program version number to <v>
           -fcompact       - Compile in compact mode
           -features <list>- Set global features, where <list> is a comma separated list of
                             features, eg -features directors,autodoc=1
                             If no explicit value is given to the feature, a default of 1 is used
           -fastdispatch   - Enable fast dispatch mode to produce faster overload dispatcher code
           -Fmicrosoft     - Display error/warning messages in Microsoft format
           -Fstandard      - Display error/warning messages in commonly used format
           -fvirtual       - Compile in virtual elimination mode
           -help           - Display help
           -I-             - Don't search the current directory
           -I<dir>         - Look for SWIG files in directory <dir>
           -ignoremissing  - Ignore missing include files
           -importall      - Follow all #include statements as imports
           -includeall     - Follow all #include statements
           -l<ifile>       - Include SWIG library file <ifile>
           -macroerrors    - Report errors inside macros
           -makedefault    - Create default constructors/destructors (the default)
           -M              - List all dependencies
           -MD             - Is equivalent to `-M -MF <file>', except `-E' is not implied
           -MF <file>      - Generate dependencies into <file> and continue generating wrappers
           -MM             - List dependencies, but omit files in SWIG library
           -MMD            - Like `-MD', but omit files in SWIG library
           -module <name>  - Set module name to <name>
           -MP             - Generate phony targets for all dependencies
           -MT <target>    - Set the target of the rule emitted by dependency generation
           -nocontract     - Turn off contract checking
           -nocpperraswarn - Do not treat the preprocessor #error statement as #warning
           -nodefault      - Do not generate default constructors nor default destructors
           -nodefaultctor  - Do not generate implicit default constructors
           -nodefaultdtor  - Do not generate implicit default destructors
           -nodirprot      - Do not wrap director protected members
           -noexcept       - Do not wrap exception specifiers
           -nofastdispatch - Disable fast dispatch mode (default)
           -nopreprocess   - Skip the preprocessor step
           -notemplatereduce - Disable reduction of the typedefs in templates
           -O              - Enable the optimization options:
                              -fastdispatch -fvirtual
           -o <outfile>    - Set name of C/C++ output file to <outfile>
           -oh <headfile>  - Set name of C++ output header file for directors to <headfile>
           -outcurrentdir  - Set default output dir to current dir instead of input file's path
           -outdir <dir>   - Set language specific files output directory to <dir>
           -pcreversion    - Display PCRE version information
           -small          - Compile in virtual elimination and compact mode
           -swiglib        - Report location of SWIG library and exit
           -templatereduce - Reduce all the typedefs in templates
           -v              - Run in verbose mode
           -version        - Display SWIG version number
           -Wall           - Remove all warning suppression, also implies -Wextra
           -Wallkw         - Enable keyword warnings for all the supported languages
           -Werror         - Treat warnings as errors
           -Wextra         - Adds the following additional warnings: 202,309,403,405,512,321,322
           -w<list>        - Suppress/add warning messages, eg -w401,+321 - see Warnings.html
           -xmlout <file>  - Write XML version of the parse tree to <file> after normal processing

Arguments may also be passed in a command-line options file (also known
as a response file) which is useful if they exceed the system command
line length limit. To do this, put the arguments in a file, then provide
the file name prefixed with ``@`` like so:

.. container:: shell

   ::

      swig @file

The options read from the file are inserted in place of the file option.
If the file does not exist, or cannot be read, then the option will be
treated literally and not removed.

Options in the file are separated by whitespace. A whitespace character
may be included in an option by surrounding the entire option in either
single or double quotes. Any character (including a backslash) may be
included by prefixing the character to be included with a backslash. The
file may itself contain additional ``@file`` options; any such options
will be processed recursively.

Input format
~~~~~~~~~~~~~~~~~~

As input, SWIG expects a file containing ISO C/C++ declarations and
special SWIG directives. More often than not, this is a special SWIG
interface file which is usually denoted with a special ``.i`` or
``.swg`` suffix. In certain cases, SWIG can be used directly on raw
header files or source files. However, this is not the most typical case
and there are several reasons why you might not want to do this
(described later).

The most common format of a SWIG interface is as follows:

.. container:: code

   ::

      %module mymodule 
      %{
      #include "myheader.h"
      %}
      // Now list ISO C/C++ declarations
      int foo;
      int bar(int x);
      ...

The module name is supplied using the special ``%module`` directive.
Modules are described further in the `Modules
Introduction <Modules.html#Modules_introduction>`__ section.

Everything in the ``%{ ... %}`` block is simply copied verbatim to the
resulting wrapper file created by SWIG. This section is almost always
used to include header files and other declarations that are required to
make the generated wrapper code compile. It is important to emphasize
that just because you include a declaration in a SWIG input file, that
declaration does *not* automatically appear in the generated wrapper
code---therefore you need to make sure you include the proper header
files in the ``%{ ... %}`` section. It should be noted that the text
enclosed in ``%{ ... %}`` is not parsed or interpreted by SWIG. The
``%{...%}`` syntax and semantics in SWIG is analogous to that of the
declarations section used in input files to parser generation tools such
as yacc or bison.

SWIG Output
~~~~~~~~~~~~~~~~~

The output of SWIG is a C/C++ file that contains all of the wrapper code
needed to build an extension module. SWIG may generate some additional
files depending on the target language. By default, an input file with
the name ``file.i`` is transformed into a file ``file_wrap.c`` or
``file_wrap.cxx`` (depending on whether or not the ``-c++`` option has
been used). The name of the output C/C++ file can be changed using the
``-o`` option. In certain cases, file suffixes are used by the compiler
to determine the source language (C, C++, etc.). Therefore, you have to
use the ``-o`` option to change the suffix of the SWIG-generated wrapper
file if you want something different than the default. For example:

.. container:: shell

   ::

      $ swig -c++ -python -o example_wrap.cpp example.i

The C/C++ output file created by SWIG often contains everything that is
needed to construct an extension module for the target scripting
language. SWIG is not a stub compiler nor is it usually necessary to
edit the output file (and if you look at the output, you probably won't
want to). To build the final extension module, the SWIG output file is
compiled and linked with the rest of your C/C++ program to create a
shared library.

For many target languages SWIG will also generate proxy class files in
the target language. The default output directory for these language
specific files is the same directory as the generated C/C++ file. This
can be modified using the ``-outdir`` option. For example:

.. container:: shell

   ::

      $ swig -c++ -python -outdir pyfiles -o cppfiles/example_wrap.cpp example.i

If the directories ``cppfiles`` and ``pyfiles`` exist, the following
will be generated:

.. container:: shell

   ::

      cppfiles/example_wrap.cpp
      pyfiles/example.py

If the ``-outcurrentdir`` option is used (without ``-o``) then SWIG
behaves like a typical C/C++ compiler and the default output directory
is then the current directory. Without this option the default output
directory is the path to the input file. If ``-o`` and
``-outcurrentdir`` are used together, ``-outcurrentdir`` is effectively
ignored as the output directory for the language files is the same
directory as the generated C/C++ file if not overridden with
``-outdir``.

Comments
~~~~~~~~~~~~~~

C and C++ style comments may appear anywhere in interface files. In
previous versions of SWIG, comments were used to generate documentation
files. However, this feature is currently under repair and will reappear
in a later SWIG release.

C Preprocessor
~~~~~~~~~~~~~~~~~~~~

Like C, SWIG preprocesses all input files through an enhanced version of
the C preprocessor. All standard preprocessor features are supported
including file inclusion, conditional compilation and macros. However,
``#include`` statements are ignored unless the ``-includeall`` command
line option has been supplied. The reason for disabling includes is that
SWIG is sometimes used to process raw C header files. In this case, you
usually only want the extension module to include functions in the
supplied header file rather than everything that might be included by
that header file (i.e., system headers, C library functions, etc.).

It should also be noted that the SWIG preprocessor skips all text
enclosed inside a ``%{...%}`` block. In addition, the preprocessor
includes a number of macro handling enhancements that make it more
powerful than the normal C preprocessor. These extensions are described
in the "`Preprocessor <Preprocessor.html#Preprocessor>`__" chapter.

SWIG Directives
~~~~~~~~~~~~~~~~~~~~~

Most of SWIG's operation is controlled by special directives that are
always preceded by a "``%``" to distinguish them from normal C
declarations. These directives are used to give SWIG hints or to alter
SWIG's parsing behavior in some manner.

Since SWIG directives are not legal C syntax, it is generally not
possible to include them in header files. However, SWIG directives can
be included in C header files using conditional compilation like this:

.. container:: code

   ::

      /* header.h  --- Some header file */

      /* SWIG directives -- only seen if SWIG is running */ 
      #ifdef SWIG
      %module foo
      #endif

``SWIG`` is a special preprocessing symbol defined by SWIG when it is
parsing an input file.

Parser Limitations
~~~~~~~~~~~~~~~~~~~~~~~~

Although SWIG can parse most C/C++ declarations, it does not provide a
complete C/C++ parser implementation. Most of these limitations pertain
to very complicated type declarations and certain advanced C++ features.
Specifically, the following features are not currently supported:

-  Non-conventional type declarations. For example, SWIG does not
   support declarations such as the following (even though this is legal
   C):

   .. container:: code

      ::

         /* Non-conventional placement of storage specifier (extern) */
         const int extern Number;

         /* Extra declarator grouping */
         Matrix (foo);    // A global variable

         /* Extra declarator grouping in parameters */
         void bar(Spam (Grok)(Doh));

   In practice, few (if any) C programmers actually write code like this
   since this style is never featured in programming books. However, if
   you're feeling particularly obfuscated, you can certainly break SWIG
   (although why would you want to?).

-  Running SWIG on C++ source files (the code in a .C, .cpp or .cxx
   file) is not recommended. The usual approach is to feed SWIG header
   files for parsing C++ definitions and declarations. The main reason
   is if SWIG parses a scoped definition or declaration (as is normal
   for C++ source files), it is ignored, unless a declaration for the
   symbol was parsed earlier. For example

   .. container:: code

      ::

         /* bar not wrapped unless foo has been defined and 
            the declaration of bar within foo has already been parsed */
         int foo::bar(int) {
           ... whatever ...
         }

-  Certain advanced features of C++ such as nested classes are not yet
   fully supported. Please see the C++ `Nested
   classes <SWIGPlus.html#SWIGPlus_nested_classes>`__ section for more
   information.

In the event of a parsing error, conditional compilation can be used to
skip offending code. For example:

.. container:: code

   ::

      #ifndef SWIG
      ... some bad declarations ...
      #endif

Alternatively, you can just delete the offending code from the interface
file.

One of the reasons why SWIG does not provide a full C++ parser
implementation is that it has been designed to work with incomplete
specifications and to be very permissive in its handling of C/C++
datatypes (e.g., SWIG can generate interfaces even when there are
missing class declarations or opaque datatypes). Unfortunately, this
approach makes it extremely difficult to implement certain parts of a
C/C++ parser as most compilers use type information to assist in the
parsing of more complex declarations (for the truly curious, the primary
complication in the implementation is that the SWIG parser does not
utilize a separate *typedef-name* terminal symbol as described on p. 234
of K&R).

Wrapping Simple C Declarations
----------------------------------

SWIG wraps simple C declarations by creating an interface that closely
matches the way in which the declarations would be used in a C program.
For example, consider the following interface file:

.. container:: code

   ::

      %module example

      %inline %{
      extern double sin(double x);
      extern int strcmp(const char *, const char *);
      extern int Foo;
      %}
      #define STATUS 50
      #define VERSION "1.1"

In this file, there are two functions ``sin()`` and ``strcmp()``, a
global variable ``Foo``, and two constants ``STATUS`` and ``VERSION``.
When SWIG creates an extension module, these declarations are accessible
as scripting language functions, variables, and constants respectively.
For example, in Tcl:

.. container:: targetlang

   ::

      % sin 3
      5.2335956
      % strcmp Dave Mike
      -1
      % puts $Foo
      42
      % puts $STATUS
      50
      % puts $VERSION
      1.1

Or in Python:

.. container:: targetlang

   ::

      >>> example.sin(3)
      5.2335956
      >>> example.strcmp('Dave', 'Mike')
      -1
      >>> print example.cvar.Foo
      42
      >>> print example.STATUS
      50
      >>> print example.VERSION
      1.1

Whenever possible, SWIG creates an interface that closely matches the
underlying C/C++ code. However, due to subtle differences between
languages, run-time environments, and semantics, it is not always
possible to do so. The next few sections describe various aspects of
this mapping.

Basic Type Handling
~~~~~~~~~~~~~~~~~~~~~~~~~

In order to build an interface, SWIG has to convert C/C++ datatypes to
equivalent types in the target language. Generally, scripting languages
provide a more limited set of primitive types than C. Therefore, this
conversion process involves a certain amount of type coercion.

Most scripting languages provide a single integer type that is
implemented using the ``int`` or ``long`` datatype in C. The following
list shows all of the C datatypes that SWIG will convert to and from
integers in the target language:

.. container:: code

   ::

      int
      short
      long
      unsigned
      signed
      unsigned short
      unsigned long
      unsigned char
      signed char
      bool

When an integral value is converted from C, a cast is used to convert it
to the representation in the target language. Thus, a 16 bit short in C
may be promoted to a 32 bit integer. When integers are converted in the
other direction, the value is cast back into the original C type. If the
value is too large to fit, it is silently truncated.

``unsigned char`` and ``signed char`` are special cases that are handled
as small 8-bit integers. Normally, the ``char`` datatype is mapped as a
one-character ASCII string.

The ``bool`` datatype is cast to and from an integer value of 0 and 1
unless the target language provides a special boolean type.

Some care is required when working with large integer values. Most
scripting languages use 32-bit integers so mapping a 64-bit long integer
may lead to truncation errors. Similar problems may arise with 32 bit
unsigned integers (which may appear as large negative numbers). As a
rule of thumb, the ``int`` datatype and all variations of ``char`` and
``short`` datatypes are safe to use. For ``unsigned int`` and ``long``
datatypes, you will need to carefully check the correct operation of
your program after it has been wrapped with SWIG.

Although the SWIG parser supports the ``long long`` datatype, not all
language modules support it. This is because ``long long`` usually
exceeds the integer precision available in the target language. In
certain modules such as Tcl and Perl5, ``long long`` integers are
encoded as strings. This allows the full range of these numbers to be
represented. However, it does not allow ``long long`` values to be used
in arithmetic expressions. It should also be noted that although
``long long`` is part of the ISO C99 standard, it is not universally
supported by all C compilers. Make sure you are using a compiler that
supports ``long long`` before trying to use this type with SWIG.

SWIG recognizes the following floating point types :

.. container:: code

   ::

      float
      double

Floating point numbers are mapped to and from the natural representation
of floats in the target language. This is almost always a C ``double``.
The rarely used datatype of ``long double`` is not supported by SWIG.

The ``char`` datatype is mapped into a NULL terminated ASCII string with
a single character. When used in a scripting language it shows up as a
tiny string containing the character value. When converting the value
back into C, SWIG takes a character string from the scripting language
and strips off the first character as the char value. Thus if the value
"foo" is assigned to a ``char`` datatype, it gets the value \`f'.

The ``char *`` datatype is handled as a NULL-terminated ASCII string.
SWIG maps this into a 8-bit character string in the target scripting
language. SWIG converts character strings in the target language to NULL
terminated strings before passing them into C/C++. The default handling
of these strings does not allow them to have embedded NULL bytes.
Therefore, the ``char *`` datatype is not generally suitable for passing
binary data. However, it is possible to change this behavior by defining
a SWIG typemap. See the chapter on `Typemaps <Typemaps.html#Typemaps>`__
for details about this.

At this time, SWIG provides limited support for Unicode and
wide-character strings (the C ``wchar_t`` type). Some languages provide
typemaps for wchar_t, but bear in mind these might not be portable
across different operating systems. This is a delicate topic that is
poorly understood by many programmers and not implemented in a
consistent manner across languages. For those scripting languages that
provide Unicode support, Unicode strings are often available in an 8-bit
representation such as UTF-8 that can be mapped to the ``char *`` type
(in which case the SWIG interface will probably work). If the program
you are wrapping uses Unicode, there is no guarantee that Unicode
characters in the target language will use the same internal
representation (e.g., UCS-2 vs. UCS-4). You may need to write some
special conversion functions.

Global Variables
~~~~~~~~~~~~~~~~~~~~~~

Whenever possible, SWIG maps C/C++ global variables into scripting
language variables. For example,

.. container:: code

   ::

      %module example
      double foo;

results in a scripting language variable like this:

.. container:: code

   ::

      # Tcl
      set foo [3.5]                   ;# Set foo to 3.5
      puts $foo                       ;# Print the value of foo

      # Python
      cvar.foo = 3.5                  # Set foo to 3.5
      print cvar.foo                  # Print value of foo

      # Perl
      $foo = 3.5;                     # Set foo to 3.5
      print $foo, "\n";               # Print value of foo

      # Ruby
      Module.foo = 3.5               # Set foo to 3.5
      print Module.foo, "\n"         # Print value of foo

Whenever the scripting language variable is used, the underlying C
global variable is accessed. Although SWIG makes every attempt to make
global variables work like scripting language variables, it is not
always possible to do so. For instance, in Python, all global variables
must be accessed through a special variable object known as ``cvar``
(shown above). In Ruby, variables are accessed as attributes of the
module. Other languages may convert variables to a pair of accessor
functions. For example, the Java module generates a pair of functions
``double get_foo()`` and ``set_foo(double val)`` that are used to
manipulate the value.

Finally, if a global variable has been declared as ``const``, it only
supports read-only access. Note: this behavior is new to SWIG-1.3.
Earlier versions of SWIG incorrectly handled ``const`` and created
constants instead.

Constants
~~~~~~~~~~~~~~~

Constants can be created using ``#define``, enumerations, or a special
``%constant`` directive. The following interface file shows a few valid
constant declarations :

.. container:: code

   ::

      #define I_CONST       5               // An integer constant
      #define PI            3.14159         // A Floating point constant
      #define S_CONST       "hello world"   // A string constant
      #define NEWLINE       '\n'            // Character constant

      enum boolean {NO=0, YES=1};
      enum months {JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG,
                   SEP, OCT, NOV, DEC};
      %constant double BLAH = 42.37;
      #define PI_4 PI/4
      #define FLAGS 0x04 | 0x08 | 0x40

In ``#define`` declarations, the type of a constant is inferred by
syntax. For example, a number with a decimal point is assumed to be
floating point. In addition, SWIG must be able to fully resolve all of
the symbols used in a ``#define`` in order for a constant to actually be
created. This restriction is necessary because ``#define`` is also used
to define preprocessor macros that are definitely not meant to be part
of the scripting language interface. For example:

.. container:: code

   ::

      #define EXTERN extern

      EXTERN void foo();

In this case, you probably don't want to create a constant called
``EXTERN`` (what would the value be?). In general, SWIG will not create
constants for macros unless the value can be completely determined by
the preprocessor. For instance, in the above example, the declaration

.. container:: code

   ::

      #define PI_4  PI/4

defines a constant because ``PI`` was already defined as a constant and
the value is known. However, for the same conservative reasons even a
constant with a simple cast will be ignored, such as

.. container:: code

   ::

      #define F_CONST (double) 5            // A floating point constant with cast

This logic can lead to false attempts at converting ``#define`` into
``%constant`` though. For example the following case does not have any
undefined symbols within the macro:

.. container:: code

   ::

      // For indicating pure virtual functions such as: virtual void f() PURE;
      #define PURE = 0

A warning is issued:

.. container:: shell

   ::

      pure.h:1: Warning 305: Bad constant value (ignored).

In such cases simply ignore the warning or suppress it using the normal
warning suppression techniques.

The use of constant expressions is allowed, but SWIG does not evaluate
them. Rather, it passes them through to the output file and lets the C
compiler perform the final evaluation (SWIG does perform a limited form
of type-checking however).

For enumerations, it is critical that the original enum definition be
included somewhere in the interface file (either in a header file or in
the ``%{ %}`` block). SWIG only translates the enumeration into code
needed to add the constants to a scripting language. It needs the
original enumeration declaration in order to get the correct enum values
as assigned by the C compiler.

The ``%constant`` directive is used to more precisely create constants
corresponding to different C datatypes. Although it is not usually
needed for simple values, it is more useful when working with pointers
and other more complex datatypes. Typically, ``%constant`` is only used
when you want to add constants to the scripting language interface that
are not defined in the original header file.

A brief word about const
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A common confusion with C programming is the semantic meaning of the
``const`` qualifier in declarations--especially when it is mixed with
pointers and other type modifiers. In fact, previous versions of SWIG
handled ``const`` incorrectly--a situation that SWIG-1.3.7 and newer
releases have fixed.

Starting with SWIG-1.3, all variable declarations, regardless of any use
of ``const``, are wrapped as global variables. If a declaration happens
to be declared as ``const``, it is wrapped as a read-only variable. To
tell if a variable is ``const`` or not, you need to look at the
right-most occurrence of the ``const`` qualifier (that appears before
the variable name). If the right-most ``const`` occurs after all other
type modifiers (such as pointers), then the variable is ``const``.
Otherwise, it is not.

Here are some examples of ``const`` declarations.

.. container:: code

   ::

      const char a;           // A constant character
      char const b;           // A constant character (the same)
      char *const c;          // A constant pointer to a character
      const char *const d;    // A constant pointer to a constant character

Here is an example of a declaration that is not ``const``:

.. container:: code

   ::

      const char *e;          // A pointer to a constant character.  The pointer
                              // may be modified.

In this case, the pointer ``e`` can change---it's only the value being
pointed to that is read-only.

Please note that for const parameters or return types used in a
function, SWIG pretty much ignores the fact that these are const, see
the section on `const-correctness <SWIGPlus.html#SWIGPlus_const>`__ for
more information.

**Compatibility Note:** One reason for changing SWIG to handle ``const``
declarations as read-only variables is that there are many situations
where the value of a ``const`` variable might change. For example, a
library might export a symbol as ``const`` in its public API to
discourage modification, but still allow the value to change through
some other kind of internal mechanism. Furthermore, programmers often
overlook the fact that with a constant declaration like ``char *const``,
the underlying data being pointed to can be modified--it's only the
pointer itself that is constant. In an embedded system, a ``const``
declaration might refer to a read-only memory address such as the
location of a memory-mapped I/O device port (where the value changes,
but writing to the port is not supported by the hardware). Rather than
trying to build a bunch of special cases into the ``const`` qualifier,
the new interpretation of ``const`` as "read-only" is simple and exactly
matches the actual semantics of ``const`` in C/C++. If you really want
to create a constant as in older versions of SWIG, use the ``%constant``
directive instead. For example:

.. container:: code

   ::

      %constant double PI = 3.14159;

or

.. container:: code

   ::

      #ifdef SWIG
      #define const %constant
      #endif
      const double foo = 3.4;
      const double bar = 23.4;
      const int    spam = 42;
      #ifdef SWIG
      #undef const
      #endif
      ...

A cautionary tale of char \*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before going any further, there is one bit of caution involving
``char *`` that must now be mentioned. When strings are passed from a
scripting language to a C ``char *``, the pointer usually points to
string data stored inside the interpreter. It is almost always a really
bad idea to modify this data. Furthermore, some languages may explicitly
disallow it. For instance, in Python, strings are supposed to be
immutable. If you violate this, you will probably receive a vast amount
of wrath when you unleash your module on the world.

The primary source of problems are functions that might modify string
data in place. A classic example would be a function like this:

.. container:: code

   ::

      char *strcat(char *s, const char *t)

Although SWIG will certainly generate a wrapper for this, its behavior
will be undefined. In fact, it will probably cause your application to
crash with a segmentation fault or other memory related problem. This is
because ``s`` refers to some internal data in the target language---data
that you shouldn't be touching.

The bottom line: don't rely on ``char *`` for anything other than
read-only input values. However, it must be noted that you could change
the behavior of SWIG using `typemaps <Typemaps.html#Typemaps>`__.

Pointers and complex objects
--------------------------------

Most C programs manipulate arrays, structures, and other types of
objects. This section discusses the handling of these datatypes.

Simple pointers
~~~~~~~~~~~~~~~~~~~~~

Pointers to primitive C datatypes such as

.. container:: code

   ::

      int *
      double ***
      char **

are fully supported by SWIG. Rather than trying to convert the data
being pointed to into a scripting representation, SWIG simply encodes
the pointer itself into a representation that contains the actual value
of the pointer and a type-tag. Thus, the SWIG representation of the
above pointers (in Tcl), might look like this:

.. container:: targetlang

   ::

      _10081012_p_int
      _1008e124_ppp_double
      _f8ac_pp_char

A NULL pointer is represented by the string "NULL" or the value 0
encoded with type information.

All pointers are treated as opaque objects by SWIG. Thus, a pointer may
be returned by a function and passed around to other C functions as
needed. For all practical purposes, the scripting language interface
works in exactly the same way as you would use the pointer in a C
program. The only difference is that there is no mechanism for
dereferencing the pointer since this would require the target language
to understand the memory layout of the underlying object.

The scripting language representation of a pointer value should never be
manipulated directly. Even though the values shown look like hexadecimal
addresses, the numbers used may differ from the actual machine address
(e.g., on little-endian machines, the digits may appear in reverse
order). Furthermore, SWIG does not normally map pointers into high-level
objects such as associative arrays or lists (for example, converting an
``int *`` into an list of integers). There are several reasons why SWIG
does not do this:

-  There is not enough information in a C declaration to properly map
   pointers into higher level constructs. For example, an ``int *`` may
   indeed be an array of integers, but if it contains ten million
   elements, converting it into a list object is probably a bad idea.
-  The underlying semantics associated with a pointer is not known by
   SWIG. For instance, an ``int *`` might not be an array at
   all--perhaps it is an output value!
-  By handling all pointers in a consistent manner, the implementation
   of SWIG is greatly simplified and less prone to error.

Run time pointer type checking
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By allowing pointers to be manipulated from a scripting language,
extension modules effectively bypass compile-time type checking in the
C/C++ compiler. To prevent errors, a type signature is encoded into all
pointer values and is used to perform run-time type checking. This
type-checking process is an integral part of SWIG and can not be
disabled or modified without using typemaps (described in later
chapters).

Like C, ``void *`` matches any kind of pointer. Furthermore, ``NULL``
pointers can be passed to any function that expects to receive a
pointer. Although this has the potential to cause a crash, ``NULL``
pointers are also sometimes used as sentinel values or to denote a
missing/empty value. Therefore, SWIG leaves NULL pointer checking up to
the application.

Derived types, structs, and classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For everything else (structs, classes, arrays, etc...) SWIG applies a
very simple rule :

**Everything else is a pointer**

In other words, SWIG manipulates everything else by reference. This
model makes sense because most C/C++ programs make heavy use of pointers
and SWIG can use the type-checked pointer mechanism already present for
handling pointers to basic datatypes.

Although this probably sounds complicated, it's really quite simple.
Suppose you have an interface file like this :

.. container:: code

   ::

      %module fileio
      FILE *fopen(char *, char *);
      int fclose(FILE *);
      unsigned fread(void *ptr, unsigned size, unsigned nobj, FILE *);
      unsigned fwrite(void *ptr, unsigned size, unsigned nobj, FILE *);
      void *malloc(int nbytes);
      void free(void *);

In this file, SWIG doesn't know what a ``FILE`` is, but since it's used
as a pointer, so it doesn't really matter what it is. If you wrapped
this module into Python, you can use the functions just like you expect
:

.. container:: targetlang

   ::

      # Copy a file 
      def filecopy(source, target):
          f1 = fopen(source, "r")
          f2 = fopen(target, "w")
          buffer = malloc(8192)
          nbytes = fread(buffer, 8192, 1, f1)
          while (nbytes > 0):
              fwrite(buffer, 8192, 1, f2)
                  nbytes = fread(buffer, 8192, 1, f1)
          free(buffer)

In this case ``f1``, ``f2``, and ``buffer`` are all opaque objects
containing C pointers. It doesn't matter what value they contain--our
program works just fine without this knowledge.

Undefined datatypes
~~~~~~~~~~~~~~~~~~~~~~~~~

When SWIG encounters an undeclared datatype, it automatically assumes
that it is a structure or class. For example, suppose the following
function appeared in a SWIG input file:

.. container:: code

   ::

      void matrix_multiply(Matrix *a, Matrix *b, Matrix *c);

SWIG has no idea what a "``Matrix``" is. However, it is obviously a
pointer to something so SWIG generates a wrapper using its generic
pointer handling code.

Unlike C or C++, SWIG does not actually care whether ``Matrix`` has been
previously defined in the interface file or not. This allows SWIG to
generate interfaces from only partial or limited information. In some
cases, you may not care what a ``Matrix`` really is as long as you can
pass an opaque reference to one around in the scripting language
interface.

An important detail to mention is that SWIG will gladly generate
wrappers for an interface when there are unspecified type names.
However, **all unspecified types are internally handled as pointers to
structures or classes!** For example, consider the following
declaration:

.. container:: code

   ::

      void foo(size_t num);

If ``size_t`` is undeclared, SWIG generates wrappers that expect to
receive a type of ``size_t *`` (this mapping is described shortly). As a
result, the scripting interface might behave strangely. For example:

.. container:: code

   ::

      foo(40);
      TypeError: expected a _p_size_t.

The only way to fix this problem is to make sure you properly declare
type names using ``typedef``.

Typedef
~~~~~~~~~~~~~

Like C, ``typedef`` can be used to define new type names in SWIG. For
example:

.. container:: code

   ::

      typedef unsigned int size_t;

``typedef`` definitions appearing in a SWIG interface are not propagated
to the generated wrapper code. Therefore, they either need to be defined
in an included header file or placed in the declarations section like
this:

.. container:: code

   ::

      %{
      /* Include in the generated wrapper file */
      typedef unsigned int size_t;
      %}
      /* Tell SWIG about it */
      typedef unsigned int size_t;

or

.. container:: code

   ::

      %inline %{
      typedef unsigned int size_t;
      %}

In certain cases, you might be able to include other header files to
collect type information. For example:

.. container:: code

   ::

      %module example
      %import "sys/types.h"

In this case, you might run SWIG as follows:

.. container:: shell

   ::

      $ swig -I/usr/include -includeall example.i

It should be noted that your mileage will vary greatly here. System
headers are notoriously complicated and may rely upon a variety of
non-standard C coding extensions (e.g., such as special directives to
GCC). Unless you exactly specify the right include directories and
preprocessor symbols, this may not work correctly (you will have to
experiment).

SWIG tracks ``typedef`` declarations and uses this information for
run-time type checking. For instance, if you use the above ``typedef``
and had the following function declaration:

.. container:: code

   ::

      void foo(unsigned int *ptr);

The corresponding wrapper function will accept arguments of type
``unsigned int *`` or ``size_t *``.

Other Practicalities
------------------------

So far, this chapter has presented almost everything you need to know to
use SWIG for simple interfaces. However, some C programs use idioms that
are somewhat more difficult to map to a scripting language interface.
This section describes some of these issues.

Passing structures by value
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes a C function takes structure parameters that are passed by
value. For example, consider the following function:

.. container:: code

   ::

      double dot_product(Vector a, Vector b);

To deal with this, SWIG transforms the function to use pointers by
creating a wrapper equivalent to the following:

.. container:: code

   ::

      double wrap_dot_product(Vector *a, Vector *b) {
        Vector x = *a;
        Vector y = *b;
        return dot_product(x, y);
      }

In the target language, the ``dot_product()`` function now accepts
pointers to Vectors instead of Vectors. For the most part, this
transformation is transparent so you might not notice.

Return by value
~~~~~~~~~~~~~~~~~~~~~

C functions that return structures or classes datatypes by value are
more difficult to handle. Consider the following function:

.. container:: code

   ::

      Vector cross_product(Vector v1, Vector v2);

This function wants to return ``Vector``, but SWIG only really supports
pointers. As a result, SWIG creates a wrapper like this:

.. container:: code

   ::

      Vector *wrap_cross_product(Vector *v1, Vector *v2) {
        Vector x = *v1;
        Vector y = *v2;
        Vector *result;
        result = (Vector *) malloc(sizeof(Vector));
        *(result) = cross(x, y);
        return result;
      }

or if SWIG was run with the ``-c++`` option:

.. container:: code

   ::

      Vector *wrap_cross(Vector *v1, Vector *v2) {
        Vector x = *v1;
        Vector y = *v2;
        Vector *result = new Vector(cross(x, y)); // Uses default copy constructor
        return result;
      }

In both cases, SWIG allocates a new object and returns a reference to
it. It is up to the user to delete the returned object when it is no
longer in use. Clearly, this will leak memory if you are unaware of the
implicit memory allocation and don't take steps to free the result. That
said, it should be noted that some language modules can now
automatically track newly created objects and reclaim memory for you.
Consult the documentation for each language module for more details.

It should also be noted that the handling of pass/return by value in C++
has some special cases. For example, the above code fragments don't work
correctly if ``Vector`` doesn't define a default constructor. The
section on SWIG and C++ has more information about this case.

Linking to structure variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When global variables or class members involving structures are
encountered, SWIG handles them as pointers. For example, a global
variable like this

.. container:: code

   ::

      Vector unit_i;

gets mapped to an underlying pair of set/get functions like this :

.. container:: code

   ::

      Vector *unit_i_get() {
        return &unit_i;
      }
      void unit_i_set(Vector *value) {
        unit_i = *value;
      }

Again some caution is in order. A global variable created in this manner
will show up as a pointer in the target scripting language. It would be
an extremely bad idea to free or destroy such a pointer. Also, C++
classes must supply a properly defined copy constructor in order for
assignment to work correctly.

Linking to char \*
~~~~~~~~~~~~~~~~~~~~~~~~

When a global variable of type ``char *`` appears, SWIG uses
``malloc()`` or ``new`` to allocate memory for the new value.
Specifically, if you have a variable like this

.. container:: code

   ::

      char *foo;

SWIG generates the following code:

.. container:: code

   ::

      /* C mode */
      void foo_set(char *value) {
        if (foo) free(foo);
        foo = (char *) malloc(strlen(value)+1);
        strcpy(foo, value);
      }

      /* C++ mode.  When -c++ option is used */
      void foo_set(char *value) {
        if (foo) delete [] foo;
        foo = new char[strlen(value)+1];
        strcpy(foo, value);
      }

If this is not the behavior that you want, consider making the variable
read-only using the ``%immutable`` directive. Alternatively, you might
write a short assist-function to set the value exactly like you want.
For example:

.. container:: code

   ::

      %inline %{
        void set_foo(char *value) {
          strncpy(foo, value, 50);
        }
      %}

Note: If you write an assist function like this, you will have to call
it as a function from the target scripting language (it does not work
like a variable). For example, in Python you will have to write:

.. container:: targetlang

   ::

      >>> set_foo("Hello World")

A common mistake with ``char *`` variables is to link to a variable
declared like this:

.. container:: code

   ::

      char *VERSION = "1.0";

In this case, the variable will be readable, but any attempt to change
the value results in a segmentation or general protection fault. This is
due to the fact that SWIG is trying to release the old value using
``free`` or ``delete`` when the string literal value currently assigned
to the variable wasn't allocated using ``malloc()`` or ``new``. To fix
this behavior, you can either mark the variable as read-only, write a
typemap (as described in Chapter 6), or write a special set function as
shown. Another alternative is to declare the variable as an array:

.. container:: code

   ::

      char VERSION[64] = "1.0";

When variables of type ``const char *`` are declared, SWIG still
generates functions for setting and getting the value. However, the
default behavior does *not* release the previous contents (resulting in
a possible memory leak). In fact, you may get a warning message such as
this when wrapping such a variable:

.. container:: shell

   ::

      example.i:20. Typemap warning. Setting const char * variable may leak memory

The reason for this behavior is that ``const char *`` variables are
often used to point to string literals. For example:

.. container:: code

   ::

      const char *foo = "Hello World\n";

Therefore, it's a really bad idea to call ``free()`` on such a pointer.
On the other hand, it *is* legal to change the pointer to point to some
other value. When setting a variable of this type, SWIG allocates a new
string (using malloc or new) and changes the pointer to point to the new
value. However, repeated modifications of the value will result in a
memory leak since the old value is not released.

Arrays
~~~~~~~~~~~~

Arrays are fully supported by SWIG, but they are always handled as
pointers instead of mapping them to a special array object or list in
the target language. Thus, the following declarations :

.. container:: code

   ::

      int foobar(int a[40]);
      void grok(char *argv[]);
      void transpose(double a[20][20]);

are processed as if they were really declared like this:

.. container:: code

   ::

      int foobar(int *a);
      void grok(char **argv);
      void transpose(double (*a)[20]);

Like C, SWIG does not perform array bounds checking. It is up to the
user to make sure the pointer points to a suitably allocated region of
memory.

Multi-dimensional arrays are transformed into a pointer to an array of
one less dimension. For example:

.. container:: code

   ::

      int [10];         // Maps to int *
      int [10][20];     // Maps to int (*)[20]
      int [10][20][30]; // Maps to int (*)[20][30]

It is important to note that in the C type system, a multidimensional
array ``a[][]`` is **NOT** equivalent to a single pointer ``*a`` or a
double pointer such as ``**a``. Instead, a pointer to an array is used
(as shown above) where the actual value of the pointer is the starting
memory location of the array. The reader is strongly advised to dust off
their C book and re-read the section on arrays before using them with
SWIG.

Array variables are supported, but are read-only by default. For
example:

.. container:: code

   ::

      int   a[100][200];

In this case, reading the variable 'a' returns a pointer of type
``int (*)[200]`` that points to the first element of the array
``&a[0][0]``. Trying to modify 'a' results in an error. This is because
SWIG does not know how to copy data from the target language into the
array. To work around this limitation, you may want to write a few
simple assist functions like this:

.. container:: code

   ::

      %inline %{
      void a_set(int i, int j, int val) {
        a[i][j] = val;
      }
      int a_get(int i, int j) {
        return a[i][j];
      }
      %}

To dynamically create arrays of various sizes and shapes, it may be
useful to write some helper functions in your interface. For example:

.. container:: code

   ::

      // Some array helpers
      %inline %{
        /* Create any sort of [size] array */
        int *int_array(int size) {
          return (int *) malloc(size*sizeof(int));
        }
        /* Create a two-dimension array [size][10] */
        int (*int_array_10(int size))[10] {
          return (int (*)[10]) malloc(size*10*sizeof(int));
        }
      %}

Arrays of ``char`` are handled as a special case by SWIG. In this case,
strings in the target language can be stored in the array. For example,
if you have a declaration like this,

.. container:: code

   ::

      char pathname[256];

SWIG generates functions for both getting and setting the value that are
equivalent to the following code:

.. container:: code

   ::

      char *pathname_get() {
        return pathname;
      }
      void pathname_set(char *value) {
        strncpy(pathname, value, 256);
      }

In the target language, the value can be set like a normal variable.

Creating read-only variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A read-only variable can be created by using the ``%immutable``
directive as shown :

.. container:: code

   ::

      // File : interface.i

      int a;       // Can read/write
      %immutable;
      int b, c, d;   // Read only variables
      %mutable;
      double x, y;  // read/write

The ``%immutable`` directive enables read-only mode until it is
explicitly disabled using the ``%mutable`` directive. As an alternative
to turning read-only mode off and on like this, individual declarations
can also be tagged as immutable. For example:

.. container:: code

   ::

      %immutable x;                   // Make x read-only
      ...
      double x;                       // Read-only (from earlier %immutable directive)
      double y;                       // Read-write
      ...

The ``%mutable`` and ``%immutable`` directives are actually `%feature
directives <Customization.html#Customization_features>`__ defined like
this:

.. container:: code

   ::

      #define %immutable   %feature("immutable")
      #define %mutable     %feature("immutable", "")

If you wanted to make all wrapped variables read-only, barring one or
two, it might be easier to take this approach:

.. container:: code

   ::

      %immutable;                     // Make all variables read-only
      %feature("immutable", "0") x;   // except, make x read/write
      ...
      double x;
      double y;
      double z;
      ...

Read-only variables are also created when declarations are declared as
``const``. For example:

.. container:: code

   ::

      const int foo;               /* Read only variable */
      char * const version="1.0";  /* Read only variable */

**Compatibility note:** Read-only access used to be controlled by a pair
of directives ``%readonly`` and ``%readwrite``. Although these
directives still work, they generate a warning message. Simply change
the directives to ``%immutable;`` and ``%mutable;`` to silence the
warning. Don't forget the extra semicolon!

Renaming and ignoring declarations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Simple renaming of specific identifiers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Normally, the name of a C declaration is used when that declaration is
wrapped into the target language. However, this may generate a conflict
with a keyword or already existing function in the scripting language.
To resolve a name conflict, you can use the ``%rename`` directive as
shown :

.. container:: code

   ::

      // interface.i

      %rename(my_print) print;
      extern void print(const char *);

      %rename(foo) a_really_long_and_annoying_name;
      extern int a_really_long_and_annoying_name;

SWIG still calls the correct C function, but in this case the function
``print()`` will really be called "``my_print()``" in the target
language.

The placement of the ``%rename`` directive is arbitrary as long as it
appears before the declarations to be renamed. A common technique is to
write code for wrapping a header file like this:

.. container:: code

   ::

      // interface.i

      %rename(my_print) print;
      %rename(foo) a_really_long_and_annoying_name;

      %include "header.h"

``%rename`` applies a renaming operation to all future occurrences of a
name. The renaming applies to functions, variables, class and structure
names, member functions, and member data. For example, if you had
two-dozen C++ classes, all with a member function named \`print' (which
is a keyword in Python), you could rename them all to \`output' by
specifying :

.. container:: code

   ::

      %rename(output) print; // Rename all `print' functions to `output'

SWIG does not normally perform any checks to see if the functions it
wraps are already defined in the target scripting language. However, if
you are careful about namespaces and your use of modules, you can
usually avoid these problems.

When wrapping C code, simple use of identifiers/symbols with ``%rename``
usually suffices. When wrapping C++ code, simple use of simple
identifiers/symbols with ``%rename`` might be too limiting when using
C++ features such as function overloading, default arguments,
namespaces, template specialization etc. If you are using the
``%rename`` directive and C++, make sure you read the `SWIG and
C++ <SWIGPlus.html#SWIGPlus>`__ chapter and in particular the section on
`Renaming and ambiguity
resolution <SWIGPlus.html#SWIGPlus_ambiguity_resolution_renaming>`__ for
method overloading and default arguments.

Closely related to ``%rename`` is the ``%ignore`` directive. ``%ignore``
instructs SWIG to ignore declarations that match a given identifier. For
example:

.. container:: code

   ::

      %ignore print;         // Ignore all declarations named print
      %ignore MYMACRO;       // Ignore a macro
      ...
      #define MYMACRO 123
      void print(const char *);
      ...

Any function, variable etc which matches ``%ignore`` will not be wrapped
and therefore will not be available from the target language. A common
usage of ``%ignore`` is to selectively remove certain declarations from
a header file without having to add conditional compilation to the
header. However, it should be stressed that this only works for simple
declarations. If you need to remove a whole section of problematic code,
the SWIG preprocessor should be used instead.

**Compatibility note:** Older versions of SWIG provided a special
``%name`` directive for renaming declarations. For example:

.. container:: code

   ::

      %name(output) extern void print(const char *);

This directive is still supported, but it is deprecated and should
probably be avoided. The ``%rename`` directive is more powerful and
better supports wrapping of raw header file information.

Advanced renaming support
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

While writing ``%rename`` for specific declarations is simple enough,
sometimes the same renaming rule needs to be applied to many, maybe all,
identifiers in the SWIG input. For example, it may be necessary to apply
some transformation to all the names in the target language to better
follow its naming conventions, like adding a specific prefix to all
wrapped functions. Doing it individually for each function is
impractical so SWIG supports applying a renaming rule to all
declarations if the name of the identifier to be renamed is not
specified:

.. container:: code

   ::

      %rename("myprefix_%s") ""; // print -> myprefix_print

This also shows that the argument of ``%rename`` doesn't have to be a
literal string but can be a ``printf()``-like format string. In the
simplest form, ``"%s"`` is replaced with the name of the original
declaration, as shown above. However this is not always enough and SWIG
provides extensions to the usual format string syntax to allow applying
a (SWIG-defined) function to the argument. For example, to wrap all C
functions ``do_something_long()`` as more Java-like
``doSomethingLong()`` you can use the ``"lowercamelcase"`` extended
format specifier like this:

.. container:: code

   ::

      %rename("%(lowercamelcase)s") ""; // foo_bar -> fooBar; FooBar -> fooBar

Some functions can be parametrized, for example the ``"strip"`` one
strips the provided prefix from its argument. The prefix is specified as
part of the format string, following a colon after the function name:

.. container:: code

   ::

      %rename("%(strip:[wx])s") ""; // wxHello -> Hello; FooBar -> FooBar

Below is the table summarizing all currently defined functions with an
example of applying each one. Note that some of them have two names, a
shorter one and a more descriptive one, but the two functions are
otherwise equivalent:

..  list-table:: \ 
    :widths: 25 25 25 25
    :header-rows: 1

    *
      - Function      
      - Returns                                                                  
      - Example (in/out)
      - \ 
    *
      - uppercase or upper  
      - Upper case version of the string.
      - Print
      - PRINT
    * 
      - lowercase or lower  
      - Lower case version of the string.
      - Print
      - print
    * 
      - title
      - String_with_first_letter_capitalized_and_the_rest_in_lower_case.
      - print
      - Print
    *      
      - firstuppercase
      - String_with_the_first_letter_capitalized_and_the_rest_unchanged.
      - printIt
      - PrintIt
    * 
      - firstlowercase
      - String_with_the_first_letter_in_lower_case_and_the_rest_unchanged.
      - PrintIt
      - printIt
    * 
      - camelcase or ctitle
      - String with capitalized first letter and any letter following an 
        underscore_(which_are_removed_in_the_process)_and_rest_in_lower_case.
      - print_it    
      - PrintIt
    *
      - lowercamelcase or lctitle
      - String with every letter following an underscore (which is removed in
        the process) capitalized and rest, including the first letter, in lower
        case.
      - print_it
      - printIt
    *
      - undercase or utitle
      - Lower case string with underscores inserted before every upper case
        letter in the original string and any number not at the end of string.
        Logically,_this_is_the_reverse_of_camelcase.
      - PrintIt
      - print_it
    *
      - schemify
      - String with all underscores replaced with dashes, resulting in more
        Lispers/Schemers-pleasing_name.
      - print_it    
      - print-it
    * 
      - strip:[prefix]
      - String without the given prefix or the original string if it doesn't
        start with this prefix. Note that square brackets should be used
        literally,_e.g._%rename("strip:[wx]")
      - wxPrint
      - Print
    * 
      - rstrip:[suffix]      
      - String without the given suffix or the original string if it doesn't
        end with this suffix. Note that square brackets should be used           
        literally,_e.g._%rename("rstrip:[Cls]")
      - PrintCls
      - Print                            
    * 
      - regex:/pattern/subst/
      - String after (Perl-like) regex substitution operation. This function
        allows to apply arbitrary regular expressions to the identifier names.    
        The pattern part is a regular expression in Perl syntax (as supported     
        by the Perl_Compatible_Regular_Expressions_(PCRE)) library and the        
        subst string can contain back-references of the form \\N where N is a     
        digit from 0 to 9, or one of the following escape sequences: \\l, \\L,    
        \\u, \\U or \\E. The back-references are replaced with the contents of    
        the corresponding capture group while the escape sequences perform the    
        case conversion in the substitution string: \\l and \\L convert to the    
        lower case, while \\u and \\U convert to the upper case. The difference   
        between the elements of each pair is that \\l and \\u change the case of  
        the next character only, while \\L and \\U do it for all the remaining    
        characters or until \\E is encountered. Finally please notice that        
        backslashes need to be escaped in C strings, so in practice "\\\\" must   
        be used in all these escape sequences. For example, to remove any         
        alphabetic prefix before an underscore and capitalize the remaining part  
        you could use the_following_directive:\                                   
        _%rename("regex:/(\\\\w+)_(.*)/\\\\u\\\\2/")  
      - prefix_print
      - Print                            
    *
      - command:cmd
      - Output of an external command cmd with the string passed to it as      
        input. Notice that this function is extremely slow compared to all the 
        other ones as it involves spawning a separate process and using it for 
        many declarations is not recommended. The cmd is not enclosed in square
        brackets but must be terminated with a triple '<' sign, e.g. %rename   
        ("command:tr -d aeiou_<<<")_(nonsensical_example_removing_all_vowels)
      - Print
      - Prnt

The most general function of all of the above ones (not counting
``command`` which is even more powerful in principle but which should
generally be avoided because of performance considerations) is the
``regex`` one. Here are some more examples of its use:

.. container:: code

   ::

      // Strip the wx prefix from all identifiers except those starting with wxEVT
      %rename("%(regex:/wx(?!EVT)(.*)/\\1/)s") ""; // wxSomeWidget -> SomeWidget
                                                   // wxEVT_PAINT -> wxEVT_PAINT

      // Apply a rule for renaming the enum elements to avoid the common prefixes
      // which are redundant in C#/Java
      %rename("%(regex:/^([A-Z][a-z]+)+_(.*)/\\2/)s", %$isenumitem) ""; // Colour_Red -> Red

      // Remove all "Set/Get" prefixes.
      %rename("%(regex:/^(Set|Get)(.*)/\\2/)s") ""; // SetValue -> Value
                                                    // GetValue -> Value

As before, everything that was said above about ``%rename`` also applies
to ``%ignore``. In fact, the latter is just a special case of the former
and ignoring an identifier is the same as renaming it to the special
``"$ignore"`` value. So the following snippets

.. container:: code

   ::

      %ignore print;

and

.. container:: code

   ::

      %rename("$ignore") print;

are exactly equivalent and ``%rename`` can be used to selectively ignore
multiple declarations using the previously described matching
possibilities.

Limiting global renaming rules
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As explained in the previous sections, it is possible to either rename
individual declarations or apply a rename rule to all of them at once.
In practice, the latter is however rarely appropriate as there are
always some exceptions to the general rules. To deal with them, the
scope of an unnamed ``%rename`` can be limited using subsequent
``match`` parameters. They can be applied to any of the attributes
associated by SWIG with the declarations appearing in its input. For
example:

.. container:: code

   ::

      %rename("foo", match$name="bar") "";

can be used to achieve the same effect as the simpler

.. container:: code

   ::

      %rename("foo") bar;

and so is not very interesting on its own. However ``match`` can also be
applied to the declaration type, for example ``match="class"`` restricts
the match to class declarations only (in C++) and ``match="enumitem"``
restricts it to the enum elements. SWIG also provides convenience macros
for such match expressions, for example

.. container:: code

   ::

      %rename("%(title)s", %$isenumitem) "";

will capitalize the names of all the enum elements but not change the
case of the other declarations. Similarly, ``%$isclass``,
``%$isfunction``, ``%$isconstructor``, ``%$isunion``, ``%$istemplate``,
and ``%$isvariable`` can be used. Many other checks are possible and
this documentation is not exhaustive, see the "%rename predicates"
section in ``swig.swg`` for the full list of supported match
expressions.

In addition to literally matching some string with ``match`` you can
also use ``regexmatch`` or ``notregexmatch`` to match a string against a
regular expression. For example, to ignore all functions having "Old" as
a suffix you could use

.. container:: code

   ::

      %rename("$ignore", regexmatch$name="Old$") "";

For simple cases like this, specifying the regular expression for the
declaration name directly can be preferable and can also be done using
``regextarget``:

.. container:: code

   ::

      %rename("$ignore", regextarget=1) "Old$";

Notice that the check is done only against the name of the declaration
itself, if you need to match the full name of a C++ declaration you must
use ``fullname`` attribute:

.. container:: code

   ::

      %rename("$ignore", regextarget=1, fullname=1) "NameSpace::ClassName::.*Old$";

As for ``notregexmatch``, it restricts the match only to the strings not
matching the specified regular expression. So to rename all declarations
to lower case except those consisting of capital letters only:

.. container:: code

   ::

      %rename("$(lower)s", notregexmatch$name="^[A-Z]+$") "";

Finally, variants of ``%rename`` and ``%ignore`` directives can be used
to help wrap C++ overloaded functions and methods or C++ methods which
use default arguments. This is described in the `Renaming and ambiguity
resolution <SWIGPlus.html#SWIGPlus_ambiguity_resolution_renaming>`__
section in the C++ chapter.

Ignoring everything then wrapping a few selected symbols
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Using the techniques described above it is possible to ignore everything
in a header and then selectively wrap a few chosen methods or classes.
For example, consider a header, ``myheader.h`` which has many classes in
it and just the one class called ``Star`` is wanted within this header,
the following approach could be taken:

.. container:: code

   ::

      %ignore ""; // Ignore everything

      // Unignore chosen class 'Star'
      %rename("%s") Star;

      // As the ignore everything will include the constructor, destructor, methods etc
      // in the class, these have to be explicitly unignored too:
      %rename("%s") Star::Star;
      %rename("%s") Star::~Star;
      %rename("%s") Star::shine; // named method

      %include "myheader.h"

Another approach which might be more suitable as it does not require
naming all the methods in the chosen class is to begin by ignoring just
the classes. This does not add an explicit ignore to any members of the
class, so when the chosen class is unignored, all of its methods will be
wrapped.

.. container:: code

   ::

      %rename($ignore, %$isclass) ""; // Only ignore all classes
      %rename("%s") Star; // Unignore 'Star'
      %include "myheader.h"

Default/optional arguments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG supports default arguments in both C and C++ code. For example:

.. container:: code

   ::

      int plot(double x, double y, int color=WHITE);

In this case, SWIG generates wrapper code where the default arguments
are optional in the target language. For example, this function could be
used in Tcl as follows :

.. container:: targetlang

   ::

      % plot -3.4 7.5    # Use default value
      % plot -3.4 7.5 10 # set color to 10 instead

Although the ISO C standard does not allow default arguments, default
arguments specified in a SWIG interface work with both C and C++.

**Note:** There is a subtle semantic issue concerning the use of default
arguments and the SWIG generated wrapper code. When default arguments
are used in C code, the default values are emitted into the wrappers and
the function is invoked with a full set of arguments. This is different
to when wrapping C++ where an overloaded wrapper method is generated for
each defaulted argument. Please refer to the section on `default
arguments <SWIGPlus.html#SWIGPlus_default_args>`__ in the C++ chapter
for further details.

Pointers to functions and callbacks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Occasionally, a C library may include functions that expect to receive
pointers to functions--possibly to serve as callbacks. SWIG provides
full support for function pointers when the callback functions are
defined in C and not in the target language. For example, consider a
function like this:

.. container:: code

   ::

      int binary_op(int a, int b, int (*op)(int, int));

When you first wrap something like this into an extension module, you
may find the function to be impossible to use. For instance, in Python:

.. container:: targetlang

   ::

      >>> def add(x, y):
      ...     return x+y
      ...
      >>> binary_op(3, 4, add)
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      TypeError: Type error. Expected _p_f_int_int__int
      >>>

The reason for this error is that SWIG doesn't know how to map a
scripting language function into a C callback. However, existing C
functions can be used as arguments provided you install them as
constants. One way to do this is to use the ``%constant`` directive like
this:

.. container:: code

   ::

      /* Function with a callback */
      int binary_op(int a, int b, int (*op)(int, int));

      /* Some callback functions */
      %constant int add(int, int);
      %constant int sub(int, int);
      %constant int mul(int, int);

In this case, ``add``, ``sub``, and ``mul`` become function pointer
constants in the target scripting language. This allows you to use them
as follows:

.. container:: targetlang

   ::

      >>> binary_op(3, 4, add)
      7
      >>> binary_op(3, 4, mul)
      12
      >>>

Unfortunately, by declaring the callback functions as constants, they
are no longer accessible as functions. For example:

.. container:: targetlang

   ::

      >>> add(3, 4)
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      TypeError: object is not callable: '_ff020efc_p_f_int_int__int'
      >>>

If you want to make a function available as both a callback function and
a function, you can use the ``%callback`` and ``%nocallback`` directives
like this:

.. container:: code

   ::

      /* Function with a callback */
      int binary_op(int a, int b, int (*op)(int, int));

      /* Some callback functions */
      %callback("%s_cb");
      int add(int, int);
      int sub(int, int);
      int mul(int, int);
      %nocallback;

The argument to ``%callback`` is a printf-style format string that
specifies the naming convention for the callback constants (``%s`` gets
replaced by the function name). The callback mode remains in effect
until it is explicitly disabled using ``%nocallback``. When you do this,
the interface now works as follows:

.. container:: targetlang

   ::

      >>> binary_op(3, 4, add_cb)
      7
      >>> binary_op(3, 4, mul_cb)
      12
      >>> add(3, 4)
      7
      >>> mul(3, 4)
      12

Notice that when the function is used as a callback, special names such
as ``add_cb`` are used instead. To call the function normally, just use
the original function name such as ``add()``.

SWIG provides a number of extensions to standard C printf formatting
that may be useful in this context. For instance, the following
variation installs the callbacks as all upper case constants such as
``ADD``, ``SUB``, and ``MUL``:

.. container:: code

   ::

      /* Some callback functions */
      %callback("%(uppercase)s");
      int add(int, int);
      int sub(int, int);
      int mul(int, int);
      %nocallback;

A format string of ``"%(lowercase)s"`` converts all characters to lower
case. A string of ``"%(title)s"`` capitalizes the first character and
converts the rest to lower case.

And now, a final note about function pointer support. Although SWIG does
not normally allow callback functions to be written in the target
language, this can be accomplished with the use of typemaps and other
advanced SWIG features. See the `Typemaps
chapter <Typemaps.html#Typemaps>`__ for more about typemaps and
individual target language chapters for more on callbacks. The
'director' feature can be used to make callbacks from C/C++ into the
target language, see `Callbacks to the target
language <SWIGPlus.html#SWIGPlus_target_language_callbacks>`__.

Structures and unions
-------------------------

This section describes the behavior of SWIG when processing ISO C
structures and union declarations. Extensions to handle C++ are
described in the next section.

If SWIG encounters the definition of a structure or union, it creates a
set of accessor functions. Although SWIG does not need structure
definitions to build an interface, providing definitions makes it
possible to access structure members. The accessor functions generated
by SWIG simply take a pointer to an object and allow access to an
individual member. For example, the declaration :

.. container:: code

   ::

      struct Vector {
        double x, y, z;
      }

gets transformed into the following set of accessor functions :

.. container:: code

   ::

      double Vector_x_get(struct Vector *obj) {
        return obj->x;
      }
      double Vector_y_get(struct Vector *obj) { 
        return obj->y;
      }
      double Vector_z_get(struct Vector *obj) { 
        return obj->z;
      }
      void Vector_x_set(struct Vector *obj, double value) {
        obj->x = value;
      }
      void Vector_y_set(struct Vector *obj, double value) {
        obj->y = value;
      }
      void Vector_z_set(struct Vector *obj, double value) {
        obj->z = value;
      }

In addition, SWIG creates default constructor and destructor functions
if none are defined in the interface. For example:

.. container:: code

   ::

      struct Vector *new_Vector() {
        return (Vector *) calloc(1, sizeof(struct Vector));
      }
      void delete_Vector(struct Vector *obj) {
        free(obj);
      }

Using these low-level accessor functions, an object can be minimally
manipulated from the target language using code like this:

.. container:: code

   ::

      v = new_Vector()
      Vector_x_set(v, 2)
      Vector_y_set(v, 10)
      Vector_z_set(v, -5)
      ...
      delete_Vector(v)

However, most of SWIG's language modules also provide a high-level
interface that is more convenient. Keep reading.

Typedef and structures
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG supports the following construct which is quite common in C
programs :

.. container:: code

   ::

      typedef struct {
        double x, y, z;
      } Vector;

When encountered, SWIG assumes that the name of the object is \`Vector'
and creates accessor functions like before. The only difference is that
the use of ``typedef`` allows SWIG to drop the ``struct`` keyword on its
generated code. For example:

.. container:: code

   ::

      double Vector_x_get(Vector *obj) {
        return obj->x;
      }

If two different names are used like this :

.. container:: code

   ::

      typedef struct vector_struct {
        double x, y, z;
      } Vector;

the name ``Vector`` is used instead of ``vector_struct`` since this is
more typical C programming style. If declarations defined later in the
interface use the type ``struct vector_struct``, SWIG knows that this is
the same as ``Vector`` and it generates the appropriate type-checking
code.

Character strings and structures
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Structures involving character strings require some care. SWIG assumes
that all members of type ``char *`` have been dynamically allocated
using ``malloc()`` and that they are NULL-terminated ASCII strings. When
such a member is modified, the previous contents will be released, and
the new contents allocated. For example :

.. container:: code

   ::

      %module mymodule
      ...
      struct Foo {
        char *name;
        ...
      }

This results in the following accessor functions :

.. container:: code

   ::

      char *Foo_name_get(Foo *obj) {
        return Foo->name;
      }

      char *Foo_name_set(Foo *obj, char *c) {
        if (obj->name)
          free(obj->name);
        obj->name = (char *) malloc(strlen(c)+1);
        strcpy(obj->name, c);
        return obj->name;
      }

If this behavior differs from what you need in your applications, the
SWIG "memberin" typemap can be used to change it. See the typemaps
chapter for further details.

Note: If the ``-c++`` option is used, ``new`` and ``delete`` are used to
perform memory allocation.

Array members
~~~~~~~~~~~~~~~~~~~

Arrays may appear as the members of structures, but they will be
read-only. SWIG will write an accessor function that returns the pointer
to the first element of the array, but will not write a function to
change the contents of the array itself. When this situation is
detected, SWIG may generate a warning message such as the following :

.. container:: shell

   ::

      interface.i:116. Warning. Array member will be read-only

To eliminate the warning message, typemaps can be used, but this is
discussed in a later chapter. In many cases, the warning message is
harmless.

Structure data members
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Occasionally, a structure will contain data members that are themselves
structures. For example:

.. container:: code

   ::

      typedef struct Foo {
        int x;
      } Foo;

      typedef struct Bar {
        int y;
        Foo f;           /* struct member */
      } Bar;

When a structure member is wrapped, it is handled as a pointer, unless
the ``%naturalvar`` directive is used where it is handled more like a
C++ reference (see `C++ Member
data <SWIGPlus.html#SWIGPlus_member_data>`__). The accessors to the
member variable as a pointer are effectively wrapped as follows:

.. container:: code

   ::

      Foo *Bar_f_get(Bar *b) {
        return &b->f;
      }
      void Bar_f_set(Bar *b, Foo *value) {
        b->f = *value;
      }

The reasons for this are somewhat subtle but have to do with the problem
of modifying and accessing data inside the data member. For example,
suppose you wanted to modify the value of ``f.x`` of a ``Bar`` object
like this:

.. container:: code

   ::

      Bar *b;
      b->f.x = 37;

Translating this assignment to function calls (as would be used inside
the scripting language interface) results in the following code:

.. container:: code

   ::

      Bar *b;
      Foo_x_set(Bar_f_get(b), 37);

In this code, if the ``Bar_f_get()`` function were to return a ``Foo``
instead of a ``Foo *``, then the resulting modification would be applied
to a *copy* of ``f`` and not the data member ``f`` itself. Clearly
that's not what you want!

It should be noted that this transformation to pointers only occurs if
SWIG knows that a data member is a structure or class. For instance, if
you had a structure like this,

.. container:: code

   ::

      struct Foo {
        WORD   w;
      };

and nothing was known about ``WORD``, then SWIG will generate more
normal accessor functions like this:

.. container:: code

   ::

      WORD Foo_w_get(Foo *f) {
        return f->w;
      }
      void Foo_w_set(FOO *f, WORD value) {
        f->w = value;
      }

**Compatibility Note:** SWIG-1.3.11 and earlier releases transformed all
non-primitive member datatypes to pointers. Starting in SWIG-1.3.12,
this transformation *only* occurs if a datatype is known to be a
structure, class, or union. This is unlikely to break existing code.
However, if you need to tell SWIG that an undeclared datatype is really
a struct, simply use a forward struct declaration such as
``"struct Foo;"``.

C constructors and destructors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When wrapping structures, it is generally useful to have a mechanism for
creating and destroying objects. If you don't do anything, SWIG will
automatically generate functions for creating and destroying objects
using ``malloc()`` and ``free()``. Note: the use of ``malloc()`` only
applies when SWIG is used on C code (i.e., when the ``-c++`` option is
*not* supplied on the command line). C++ is handled differently.

If you don't want SWIG to generate default constructors for your
interfaces, you can use the ``%nodefaultctor`` directive or the
``-nodefaultctor`` command line option. For example:

.. container:: shell

   ::

      swig -nodefaultctor example.i 

or

.. container:: code

   ::

      %module foo
      ...
      %nodefaultctor;        // Don't create default constructors
      ... declarations ...
      %clearnodefaultctor;   // Re-enable default constructors

If you need more precise control, ``%nodefaultctor`` can selectively
target individual structure definitions. For example:

.. container:: code

   ::

      %nodefaultctor Foo;      // No default constructor for Foo
      ...
      struct Foo {             // No default constructor generated.
      };

      struct Bar {             // Default constructor generated.
      };

Since ignoring the implicit or default destructors most of the time
produces memory leaks, SWIG will always try to generate them. If needed,
however, you can selectively disable the generation of the
default/implicit destructor by using ``%nodefaultdtor``

.. container:: code

   ::

      %nodefaultdtor Foo; // No default/implicit destructor for Foo
      ...
      struct Foo {              // No default destructor is generated.
      };

      struct Bar {              // Default destructor generated.
      };

**Compatibility note:** Prior to SWIG-1.3.7, SWIG did not generate
default constructors or destructors unless you explicitly turned them on
using ``-make_default``. However, it appears that most users want to
have constructor and destructor functions so it has now been enabled as
the default behavior.

**Note:** There are also the ``-nodefault`` option and ``%nodefault``
directive, which disable both the default or implicit destructor
generation. This could lead to memory leaks across the target languages,
and it is highly recommended you don't use them.

Adding member functions to C structures
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Most languages provide a mechanism for creating classes and supporting
object oriented programming. From a C standpoint, object oriented
programming really just boils down to the process of attaching functions
to structures. These functions normally operate on an instance of the
structure (or object). Although there is a natural mapping of C++ to
such a scheme, there is no direct mechanism for utilizing it with C
code. However, SWIG provides a special ``%extend`` directive that makes
it possible to attach methods to C structures for purposes of building
an object oriented interface. Suppose you have a C header file with the
following declaration :

.. container:: code

   ::

      /* file : vector.h */
      ...
      typedef struct Vector {
        double x, y, z;
      } Vector;

You can make a ``Vector`` look a lot like a class by writing a SWIG
interface like this:

.. container:: code

   ::

      // file : vector.i
      %module mymodule
      %{
      #include "vector.h"
      %}

      %include "vector.h"          // Just grab original C header file
      %extend Vector {             // Attach these functions to struct Vector
        Vector(double x, double y, double z) {
          Vector *v;
          v = (Vector *) malloc(sizeof(Vector));
          v->x = x;
          v->y = y;
          v->z = z;
          return v;
        }
        ~Vector() {
          free($self);
        }
        double magnitude() {
          return sqrt($self->x*$self->x+$self->y*$self->y+$self->z*$self->z);
        }
        void print() {
          printf("Vector [%g, %g, %g]\n", $self->x, $self->y, $self->z);
        }
      };

Note the usage of the ``$self`` special variable. Its usage is identical
to a C++ 'this' pointer and should be used whenever access to the struct
instance is required. Also note that C++ constructor and destructor
syntax has been used to simulate a constructor and destructor, even for
C code. There is one subtle difference to a normal C++ constructor
implementation though and that is although the constructor declaration
is as per a normal C++ constructor, the newly constructed object must be
returned **as if** the constructor declaration had a return value, a
``Vector *`` in this case.

Now, when used with proxy classes in Python, you can do things like this
:

.. container:: targetlang

   ::

      >>> v = Vector(3, 4, 0)                 # Create a new vector
      >>> print v.magnitude()                # Print magnitude
      5.0
      >>> v.print()                  # Print it out
      [ 3, 4, 0 ]
      >>> del v                      # Destroy it

The ``%extend`` directive can also be used inside the definition of the
Vector structure. For example:

.. container:: code

   ::

      // file : vector.i
      %module mymodule
      %{
      #include "vector.h"
      %}

      typedef struct Vector {
        double x, y, z;
        %extend {
          Vector(double x, double y, double z) { ... }
          ~Vector() { ... }
          ...
        }
      } Vector;

Note that ``%extend`` can be used to access externally written functions
provided they follow the naming convention used in this example :

.. container:: code

   ::

      /* File : vector.c */
      /* Vector methods */
      #include "vector.h"
      Vector *new_Vector(double x, double y, double z) {
        Vector *v;
        v = (Vector *) malloc(sizeof(Vector));
        v->x = x;
        v->y = y;
        v->z = z;
        return v;
      }
      void delete_Vector(Vector *v) {
        free(v);
      }

      double Vector_magnitude(Vector *v) {
        return sqrt(v->x*v->x+v->y*v->y+v->z*v->z);
      }

      // File : vector.i
      // Interface file
      %module mymodule
      %{
      #include "vector.h"
      %}

      typedef struct Vector {
        double x, y, z;
        %extend {
          Vector(int, int, int); // This calls new_Vector()
          ~Vector();           // This calls delete_Vector()
          double magnitude();  // This will call Vector_magnitude()
          ...
        }
      } Vector;

The name used for %extend should be the name of the struct and not the
name of any typedef to the struct. For example:

.. container:: code

   ::

      typedef struct Integer {
        int value;
      } Int;
      %extend Integer { ...  } /* Correct name */
      %extend Int { ...  } /* Incorrect name */

      struct Float {
        float value;
      };
      typedef struct Float FloatValue;
      %extend Float { ...  } /* Correct name */
      %extend FloatValue { ...  } /* Incorrect name */

There is one exception to this rule and that is when the struct is
anonymously named such as:

.. container:: code

   ::

      typedef struct {
        double value;
      } Double;
      %extend Double { ...  } /* Okay */

A little known feature of the ``%extend`` directive is that it can also
be used to add synthesized attributes or to modify the behavior of
existing data attributes. For example, suppose you wanted to make
``magnitude`` a read-only attribute of ``Vector`` instead of a method.
To do this, you might write some code like this:

.. container:: code

   ::

      // Add a new attribute to Vector
      %extend Vector {
        const double magnitude;
      }
      // Now supply the implementation of the Vector_magnitude_get function
      %{
      const double Vector_magnitude_get(Vector *v) {
        return (const double) sqrt(v->x*v->x+v->y*v->y+v->z*v->z);
      }
      %}

Now, for all practical purposes, ``magnitude`` will appear like an
attribute of the object.

A similar technique can also be used to work with data members that you
want to process. For example, consider this interface:

.. container:: code

   ::

      typedef struct Person {
        char name[50];
        ...
      } Person;

Say you wanted to ensure ``name`` was always upper case, you can rewrite
the interface as follows to ensure this occurs whenever a name is read
or written to:

.. container:: code

   ::

      typedef struct Person {
        %extend {
          char name[50];
        }
        ...
      } Person;

      %{
      #include <string.h>
      #include <ctype.h>

      void make_upper(char *name) {
        char *c;
        for (c = name; *c; ++c)
          *c = (char)toupper((int)*c);
      }

      /* Specific implementation of set/get functions forcing capitalization */

      char *Person_name_get(Person *p) {
        make_upper(p->name);
        return p->name;
      }

      void Person_name_set(Person *p, char *val) {
        strncpy(p->name, val, 50);
        make_upper(p->name);
      }
      %}

Finally, it should be stressed that even though ``%extend`` can be used
to add new data members, these new members can not require the
allocation of additional storage in the object (e.g., their values must
be entirely synthesized from existing attributes of the structure or
obtained elsewhere).

**Compatibility note:** The ``%extend`` directive is a new name for the
``%addmethods`` directive. Since ``%addmethods`` could be used to extend
a structure with more than just methods, a more suitable directive name
has been chosen.

Nested structures
~~~~~~~~~~~~~~~~~~~~~~~

Occasionally, a C program will involve structures like this :

.. container:: code

   ::

      typedef struct Object {
        int objtype;
        union {
          int ivalue;
          double dvalue;
          char *strvalue;
          void *ptrvalue;
        } intRep;
      } Object;

When SWIG encounters this, it performs a structure splitting operation
that transforms the declaration into the equivalent of the following:

.. container:: code

   ::

      typedef union {
        int ivalue;
        double dvalue;
        char *strvalue;
        void *ptrvalue;
      } Object_intRep;

      typedef struct Object {
        int objType;
        Object_intRep intRep;
      } Object;

SWIG will then create an ``Object_intRep`` structure for use inside the
interface file. Accessor functions will be created for both structures.
In this case, functions like this would be created :

.. container:: code

   ::

      Object_intRep *Object_intRep_get(Object *o) {
        return (Object_intRep *) &o->intRep;
      }
      int Object_intRep_ivalue_get(Object_intRep *o) {
        return o->ivalue;
      }
      int Object_intRep_ivalue_set(Object_intRep *o, int value) {
        return (o->ivalue = value);
      }
      double Object_intRep_dvalue_get(Object_intRep *o) {
        return o->dvalue;
      }
      ... etc ...

Although this process is a little hairy, it works like you would expect
in the target scripting language--especially when proxy classes are
used. For instance, in Perl:

.. container:: targetlang

   ::

      # Perl5 script for accessing nested member
      $o = CreateObject();                    # Create an object somehow
      $o->{intRep}->{ivalue} = 7              # Change value of o.intRep.ivalue

If you have a lot of nested structure declarations, it is advisable to
double-check them after running SWIG. Although, there is a good chance
that they will work, you may have to modify the interface file in
certain cases.

Finally, note that nesting is handled differently in C++ mode, see
`Nested classes <SWIGPlus.html#SWIGPlus_nested_classes>`__.

Other things to note about structure wrapping
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG doesn't care if the declaration of a structure in a ``.i`` file
exactly matches that used in the underlying C code (except in the case
of nested structures). For this reason, there are no problems omitting
problematic members or simply omitting the structure definition
altogether. If you are happy passing pointers around, this can be done
without ever giving SWIG a structure definition.

Starting with SWIG1.3, a number of improvements have been made to SWIG's
code generator. Specifically, even though structure access has been
described in terms of high-level accessor functions such as this,

.. container:: code

   ::

      double Vector_x_get(Vector *v) {
        return v->x;
      }

most of the generated code is actually inlined directly into wrapper
functions. Therefore, no function ``Vector_x_get()`` actually exists in
the generated wrapper file. For example, when creating a Tcl module, the
following function is generated instead:

.. container:: code

   ::

      static int
      _wrap_Vector_x_get(ClientData clientData, Tcl_Interp *interp, 
                         int objc, Tcl_Obj *CONST objv[]) {
        struct Vector *arg1 ;
        double result ;

        if (SWIG_GetArgs(interp, objc, objv, "p:Vector_x_get self ", &arg0,
                         SWIGTYPE_p_Vector) == TCL_ERROR)
          return TCL_ERROR;
        result = (double ) (arg1->x);
        Tcl_SetObjResult(interp, Tcl_NewDoubleObj((double) result));
        return TCL_OK;
      }

The only exception to this rule are methods defined with ``%extend``. In
this case, the added code is contained in a separate function.

Finally, it is important to note that most language modules may choose
to build a more advanced interface. Although you may never use the
low-level interface described here, most of SWIG's language modules use
it in some way or another.

Code Insertion
------------------

Sometimes it is necessary to insert special code into the resulting
wrapper file generated by SWIG. For example, you may want to include
additional C code to perform initialization or other operations. There
are four common ways to insert code, but it's useful to know how the
output of SWIG is structured first.

The output of SWIG
~~~~~~~~~~~~~~~~~~~~~~~~

When SWIG creates its output C/C++ file, it is broken up into five
sections corresponding to runtime code, headers, wrapper functions, and
module initialization code (in that order).

-  | **Begin section**.
   | A placeholder for users to put code at the beginning of the C/C++
     wrapper file. This is most often used to define preprocessor macros
     that are used in later sections.
-  | **Runtime code**.
   | This code is internal to SWIG and is used to include type-checking
     and other support functions that are used by the rest of the module.
-  | **Header section**.
   | This is user-defined support code that has been included by the
     ``%{ ... %}`` directive. Usually this consists of header files and
     other helper functions.
-  | **Wrapper code**.
   | These are the wrappers generated automatically by SWIG.
-  | **Module initialization**.
   | The function generated by SWIG to initialize the module upon loading.

Code insertion blocks
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``%insert`` directive enables inserting blocks of code into a given
section of the generated code. It can be used in one of two ways:

.. container:: code

   ::

      %insert("section") "filename"
      %insert("section") %{ ... %}

The first will dump the contents of the file in the given ``filename``
into the named ``section``. The second inserts the code between the
braces into the named ``section``. For example, the following adds code
into the runtime section:

.. container:: code

   ::

      %insert("runtime") %{
        ... code in runtime section ...
      %}

There are the 5 sections, however, some target languages add in
additional sections and some of these result in code being generated
into a target language file instead of the C/C++ wrapper file. These are
documented when available in the target language chapters. Macros named
after the code sections are available as additional directives and these
macro directives are normally used instead of ``%insert``. For example,
``%runtime`` is used instead of ``%insert("runtime")``. The valid
sections and order of the sections in the generated C/C++ wrapper file
is as shown:

.. container:: code

   ::

      %begin %{
        ... code in begin section ...
      %}

      %runtime %{
        ... code in runtime section ...
      %}

      %header %{
        ... code in header section ...
      %}

      %wrapper %{
        ... code in wrapper section ...
      %}

      %init %{
        ... code in init section ...
      %}

The bare ``%{ ... %}`` directive is a shortcut that is the same as
``%header %{ ... %}``.

The ``%begin`` section is effectively empty as it just contains the SWIG
banner by default. This section is provided as a way for users to insert
code at the top of the wrapper file before any other code is generated.
Everything in a code insertion block is copied verbatim into the output
file and is not parsed by SWIG. Most SWIG input files have at least one
such block to include header files and support C code. Additional code
blocks may be placed anywhere in a SWIG file as needed.

.. container:: code

   ::

      %module mymodule
      %{
      #include "my_header.h"
      %}
      ... Declare functions here
      %{

      void some_extra_function() {
        ...
      }
      %}

A common use for code blocks is to write "helper" functions. These are
functions that are used specifically for the purpose of building an
interface, but which are generally not visible to the normal C program.
For example :

.. container:: code

   ::

      %{
      /* Create a new vector */
      static Vector *new_Vector() {
        return (Vector *) malloc(sizeof(Vector));
      }

      %}
      // Now wrap it 
      Vector *new_Vector();

Inlined code blocks
~~~~~~~~~~~~~~~~~~~~~~~~~

Since the process of writing helper functions is fairly common, there is
a special inlined form of code block that is used as follows :

.. container:: code

   ::

      %inline %{
      /* Create a new vector */
      Vector *new_Vector() {
        return (Vector *) malloc(sizeof(Vector));
      }
      %}

This is the same as writing:

.. container:: code

   ::

      %{
      /* Create a new vector */
      Vector *new_Vector() {
        return (Vector *) malloc(sizeof(Vector));
      }
      %}

      /* Create a new vector */
      Vector *new_Vector() {
        return (Vector *) malloc(sizeof(Vector));
      }

In other words, the ``%inline`` directive inserts all of the code that
follows verbatim into the header portion of an interface file. The code
is then parsed by both the SWIG preprocessor and parser. Thus, the above
example creates a new command ``new_Vector`` using only one declaration.
Since the code inside an ``%inline %{ ... %}`` block is given to both
the C compiler and SWIG, it is illegal to include any SWIG directives
inside a ``%{ ... %}`` block.

**Note:** The usual SWIG C preprocessor rules apply to code in
``%apply`` blocks when SWIG parses this code. For example, as mentioned
earlier, `SWIG's C Preprocessor <SWIG.html#SWIG_nn6>`__ does not follow
``#include`` directives by default.

Initialization blocks
~~~~~~~~~~~~~~~~~~~~~~~~~~~

When code is included in the ``%init`` section, it is copied directly
into the module initialization function. For example, if you needed to
perform some extra initialization on module loading, you could write
this:

.. container:: code

   ::

      %init %{
        init_variables();
      %}

Please note that some language backends (e.g. C# or Java) don't have any
initialization function, hence you should define a global object
performing the necessary initialization for them instead:

.. container:: code

   ::

      %init %{
        static struct MyInit { MyInit() { init_variables(); } } myInit;
      %}

An Interface Building Strategy
----------------------------------

This section describes the general approach for building interfaces with
SWIG. The specifics related to a particular scripting language are found
in later chapters.

Preparing a C program for SWIG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG doesn't require modifications to your C code, but if you feed it a
collection of raw C header files or source code, the results might not
be what you expect---in fact, they might be awful. Here's a series of
steps you can follow to make an interface for a C program :

-  Identify the functions that you want to wrap. It's probably not
   necessary to access every single function of a C program--thus, a
   little forethought can dramatically simplify the resulting scripting
   language interface. C header files are a particularly good source for
   finding things to wrap.
-  Create a new interface file to describe the scripting language
   interface to your program.
-  Copy the appropriate declarations into the interface file or use
   SWIG's ``%include`` directive to process an entire C source/header
   file.
-  Make sure everything in the interface file uses ISO C/C++ syntax.
-  Make sure all necessary \`\ ``typedef``' declarations and
   type-information is available in the interface file. In particular,
   ensure that the type information is specified in the correct order as
   required by a C/C++ compiler. Most importantly, define a type before
   it is used! A C compiler will tell you if the full type information
   is not available if it is needed, whereas SWIG will usually not warn
   or error out as it is designed to work without full type information.
   However, if type information is not specified correctly, the wrappers
   can be sub-optimal and even result in uncompilable C/C++ code.
-  If your program has a main() function, you may need to rename it
   (read on).
-  Run SWIG and compile.

Although this may sound complicated, the process turns out to be fairly
easy once you get the hang of it.

In the process of building an interface, SWIG may encounter syntax
errors or other problems. The best way to deal with this is to simply
copy the offending code into a separate interface file and edit it.
However, the SWIG developers have worked very hard to improve the SWIG
parser--you should report parsing errors to the `swig-devel mailing
list <http://www.swig.org/mail.html>`__ or to the `SWIG bug
tracker <http://www.swig.org/bugs.html>`__.

The SWIG interface file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The preferred method of using SWIG is to generate a separate interface
file. Suppose you have the following C header file :

.. container:: code

   ::

      /* File : header.h */

      #include <stdio.h>
      #include <math.h>

      extern int foo(double);
      extern double bar(int, int);
      extern void dump(FILE *f);

A typical SWIG interface file for this header file would look like the
following :

.. container:: code

   ::

      /* File : interface.i */
      %module mymodule
      %{
      #include "header.h"
      %}
      extern int foo(double);
      extern double bar(int, int);
      extern void dump(FILE *f);

Of course, in this case, our header file is pretty simple so we could
use a simpler approach and use an interface file like this:

.. container:: code

   ::

      /* File : interface.i */
      %module mymodule
      %{
      #include "header.h"
      %}
      %include "header.h"

The main advantage of this approach is minimal maintenance of an
interface file for when the header file changes in the future. In more
complex projects, an interface file containing numerous ``%include`` and
``#include`` statements like this is one of the most common approaches
to interface file design due to lower maintenance overhead.

Why use separate interface files?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Although SWIG can parse many header files, it is more common to write a
special ``.i`` file defining the interface to a package. There are
several reasons why you might want to do this:

-  It is rarely necessary to access every single function in a large
   package. Many C functions might have little or no use in a scripted
   environment. Therefore, why wrap them?
-  Separate interface files provide an opportunity to provide more
   precise rules about how an interface is to be constructed.
-  Interface files can provide more structure and organization.
-  SWIG can't parse certain definitions that appear in header files.
   Having a separate file allows you to eliminate or work around these
   problems.
-  Interface files provide a more precise definition of what the
   interface is. Users wanting to extend the system can go to the
   interface file and immediately see what is available without having
   to dig it out of header files.

Getting the right header files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes, it is necessary to use certain header files in order for the
code generated by SWIG to compile properly. Make sure you include
certain header files by using a ``%{ %}`` block like this:

.. container:: code

   ::

      %module graphics
      %{
      #include <GL/gl.h>
      #include <GL/glu.h>
      %}

      // Put the rest of the declarations here
      ...

What to do with main()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If your program defines a ``main()`` function, you may need to get rid
of it or rename it in order to use a scripting language. Most scripting
languages define their own ``main()`` procedure that is called instead.
``main()`` also makes no sense when working with dynamic loading. There
are a few approaches to solving the ``main()`` conflict :

-  Get rid of ``main()`` entirely.
-  Rename ``main()`` to something else. You can do this by compiling
   your C program with an option like ``-Dmain=oldmain``.
-  Use conditional compilation to only include ``main()`` when not using
   a scripting language.

Getting rid of ``main()`` may cause potential initialization problems of
a program. To handle this problem, you may consider writing a special
function called ``program_init()`` that initializes your program upon
startup. This function could then be called either from the scripting
language as the first operation, or when the SWIG generated module is
loaded.

As a general note, many C programs only use the ``main()`` function to
parse command line options and to set parameters. However, by using a
scripting language, you are probably trying to create a program that is
more interactive. In many cases, the old ``main()`` program can be
completely replaced by a Perl, Python, or Tcl script.

**Note:** In some cases, you might be inclined to create a scripting
language wrapper for ``main()``. If you do this, the compilation will
probably work and your module might even load correctly. The only
trouble is that when you call your ``main()`` wrapper, you will find
that it actually invokes the ``main()`` of the scripting language
interpreter itself! This behavior is a side effect of the symbol binding
mechanism used in the dynamic linker. The bottom line: don't do this.

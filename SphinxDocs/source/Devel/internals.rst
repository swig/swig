SWIG Internals Manual
=====================

(Note : This is a work in progress.)


Introduction
---------------

This document details SWIG internals: architecture and sometimes
implementation. The first few sections concentrate on data structures,
interfaces, conventions and code shared by all language targets.
Subsequent sections focus on a particular language.

The audience is assumed to be SWIG developers (who should also read the
`SWIG Engineering Manual <engineering.html>`__ before starting to code).
` <#i1.1>`__

Directory Guide
~~~~~~~~~~~~~~~~~~~

`Doc <index.html>`__

HTML documentation. If you find a documentation bug, please `let us
know <mailto:bug-swig-doc@glug.org>`__.

Examples

This subdir tree contains examples of using SWIG w/ different scripting
languages, including makefiles. Typically, there are the "simple" and
"class" examples, w/ some languages offering additional examples. See
the README more index.html file in each directory for more info. [FIXME:
Ref SWIG user manual.]

Lib

These are the ``.i`` (interface) files that form the SWIG installed
library. Language-specific files are in subdirectories (for example,
guile/typemaps.i). Each language also has a ``.swg`` file implementing
runtime type support for that language. The SWIG library is not
versioned.

Misc

Currently this subdir only contains file ``fileheader``. See the
`Engineering Manual <engineering.html>`__ for more info.

Source

The C and C++ source code for the ``swig`` executable is in this subdir
tree.

+--------------+------------------------------------------------------+
| DOH          | C library providing memory allocation, file access   |
|              | and generic containers.                              |
+--------------+------------------------------------------------------+
| Include      | Configuration .h files                               |
+--------------+------------------------------------------------------+
| CParse       | Parser (lex / yacc) files and support                |
+--------------+------------------------------------------------------+
| Modules      | Language-specific callbacks that does actual code    |
|              | generation (each language has a .cxx and a .h file). |
+--------------+------------------------------------------------------+
| Preprocessor | SWIG-specialized C/C++ preprocessor.                 |
+--------------+------------------------------------------------------+
| Swig         | This directory contains the ANSI C core of the       |
|              | system and contains generic functions related to     |
|              | types, file handling, scanning, and so forth.        |
+--------------+------------------------------------------------------+

Tools

The mkdist.py script and other tools.

Win

This improperly-named (spit spit) subdir only has README.txt.

` <#1.2>`__

Overall Program Flow
~~~~~~~~~~~~~~~~~~~~~~~~

Here is the general control flow and where under subdir ``Source`` to
look for code:

-  ``Modules/swigmain.cxx:main()`` is the program entry point. It parses
   the language-specifying command-line option (for example, ``-java``),
   creating a new language-specific wrapping object (each language is a
   C++ class derived from base class ``Language``). This object and the
   command-line is passed to ``SWIG_main()``, whose return value is the
   program exit value.
-  ``Modules/main.cxx:SWIG_main()`` is the "real" main. It initializes
   the preprocessor and typemap machinery, defines some preprocessor
   symbols, locates the SWIG library, processes common command-line
   options, and then calls the language-specific command-line parser.
   From here there are three paths: "help", "checkout" and everything
   else.

   -  In "help" mode, clean up open files and exit.
   -  In "checkout" mode, copy specified files from the SWIG library to
      the current directory. Errors cause error messages but no
      non-local exits.
   -  Otherwise, do wrapping: determine output file name(s), define some
      preprocessor symbols and run the preprocessor, initialize the
      interface-definition parser, set up the typemap for handling new
      return strings, and finally do the language-specific parse (by
      calling the language object's ``parse()`` method), which creates
      output files by side-effect.

   Afterwards, remove temporary files, and clean up. If the command-line
   included ``-freeze``, go into an infinite loop; otherwise return the
   error count.
-  The language-specific ``parse()`` (and all other language-specific
   code) lives in ``Modules/foo.{h,cxx}`` for language Foo. Typically,
   ``FOO::parse()`` calls ``FOO::headers()`` and then the global
   function ``yyparse()``, which uses the callbacks registered by
   ``SWIG_main()`` above.

` <#i2>`__

DOH
------

DOH is a collection of low-level objects such as strings, lists, and
hash tables upon which the rest of SWIG is built. The name 'DOH'
unofficially stands for "Dave's Object Hack", but it's also a good
expletive to use when things don't work (as in "SWIG core
dumped---DOH!"). ` <#2.1>`__

Motivation and Background
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The development of DOH is influenced heavily by the problems encountered
during earlier attempts to create a C++ based version of SWIG2.0. In
each of these attempts (over a 3 year period), the resulting system
always ended up growing into a colossal nightmare of large inheritance
hierarchies and dozens of specialized classes for different types of
objects (functions, variables, constants, etc.). The end result was that
the system was tremendously complicated, difficult to understand,
difficult to maintain, and fairly inflexible in the grand scheme of
things.

DOH takes a different approach to tackling the complexity problem.
First, rather than going overboard with dozens of types and class
definitions, DOH only defines a handful of simple yet very useful
objects that are easy to remember. Second, DOH uses dynamic typing---one
of the features that make scripting languages so useful and which make
it possible to accomplish things with much less code. Finally, DOH
utilizes a few coding tricks that allow it to perform a limited form of
function overloading for certain C datatypes (more on that a little
later).

The key point to using DOH is that instead of thinking about code in
terms of highly specialized C data structures, just about everything
ends up being represented in terms of a just a few datatypes. For
example, structures are replaced by DOH hash tables whereas arrays are
replaced by DOH lists. At first, this is probably a little strange to
most C/C++ programmers, but in the long run in makes the system
extremely flexible and highly extensible. Also, in terms of coding, many
of the newly DOH-based subsystems are less than half the size (in lines
of code) of the earlier C++ implementation. ` <#i2.2>`__

Basic Types
~~~~~~~~~~~~~~~

The following built-in types are currently provided by DOH:

-  **String**. A string of characters with automatic memory management
   and high-level operations such as string replacement. In addition,
   strings support file I/O operations that make it possible to use them
   just about anyplace a file can be used.
-  **List**. A list of arbitrary DOH objects (of possibly mixed types).
-  **Hash**. A hash table that maps a set of string keys to a set of
   arbitrary DOH objects. The DOH version of an associative array for
   all of you Perl fans.
-  **File**. A DOH wrapper around the C FILE \* structure. This is
   provided since other objects sometimes want to behave like files
   (strings for instance).
-  **Void**. A DOH wrapper around an arbitrary C pointer. This can be
   used if you want to place arbitrary C data structures in DOH lists
   and hash tables.

Due to dynamic typing, all of the objects in DOH are represented by
pointers of type ``DOH *``. Furthermore, all objects are completely
opaque--that means that the only way to access the internals of an
object is through a well-defined public API. For convenience, the
following symbolic names are sometimes used to improve readability:

-  ``DOHString *``. A String object.
-  ``DOHList *``. A list object.
-  ``DOHHash *``. A hash object.
-  ``DOHFile *``. A file object.
-  ``DOHVoid *``. A void object.
-  ``DOHString_or_char *``. A DOH String object or a raw C "char \*".

It should be stressed that all of these names are merely symbolic
aliases to the type ``DOH *`` and that no compile-time type checking is
performed (of course, a runtime error may occur if you screw up).
` <#i2.3>`__

Creating, Copying, and Destroying Objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following functions can be used to create new DOH objects

-  ``NewString(DOHString_or_char *value)``
   Create a new string object with contents initially set to value.
   value can be either a C string or a DOH string object.
-  ``NewStringf(char *fmt, ...)``
   Create a new string object with contents initially set to a formatted
   string. Think of this as being sprintf() combined with an object
   constructor.
-  ``NewList()``
   Create a new list object that is initially empty.
-  ``NewHash()``
   Create a new hash object that is initially empty.
-  ``NewFile(DOHString_or_char *filename, char *mode)``
   Open a file and return a file object. This is a wrapper around the C
   ``fopen()`` library call.
-  ``NewFileFromFile(FILE *f)``
   Create a new file object given an already opened ``FILE *`` object.
-  ``NewVoid(void *obj, void (*del)(void *))``
   Create a new DOH object that is a wrapper around an arbitrary C
   pointer. ``del`` is an optional destructor function that will be
   called when the object is destroyed.

Any object can be copied using the ``Copy()`` function. For example:

   ::

      DOH *a, *b, *c, *d;
      a = NewString("Hello World");
      b = NewList();
      c = Copy(a);         /* Copy the string a */
      d = Copy(b);         /* Copy the list b */

Copies of lists and hash tables are shallow. That is, their contents are
only copied by reference.

Objects can be deleted using the ``Delete()`` function. For example:

   ::

      DOH *a = NewString("Hello World");
      ...
      Delete(a);              /* Destroy a */

All objects are referenced counted and given a reference count of 1 when
initially created. The ``Delete()`` function only destroys an object
when the reference count reaches zero. When an object is placed in a
list or hash table, its reference count is automatically increased. For
example:

   ::

      DOH *a, *b;
      a = NewString("Hello World");
      b = NewList();
      Append(b,a);         /* Increases refcnt of a to 2 */
      Delete(a);           /* Decreases refcnt of a to 1 */
      Delete(b);           /* Destroys b, and destroys a */

Should it ever be necessary to manually increase the reference count of
an object, the DohIncref() function can be used:

   ::

      DOH *a = NewString("Hello");
      DohIncref(a);

` <#i2.4>`__

A Word About Mutability and Copying
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All DOH objects are mutable regardless of their current reference count.
For example, if you create a string and then create a 1000 references to
it (in lists and hash tables), changes to the string will be reflected
in all of the references. Therefore, if you need to make any kind of
local change, you should first make a copy using the Copy() function.
Caveat: when copying lists and hash tables, elements are copied by
reference. ` <#i2.5>`__

Strings
~~~~~~~~~~~

The DOH String type is perhaps the most flexible object. First, it
supports a variety of string-oriented operations. Second, it supports
many of the same operations as lists. Finally, strings provide file I/O
operations that allow them to be used interchangeably with DOH file
objects. [ TODO ] ` <#i2.6>`__

Lists
~~~~~~~~~

Example usage of lists:

   ::

      /* Create and populate */
      List *list = NewList();
      Append(list, NewString("listval1"));
      Append(list, NewString("listval2"));
      Append(list, NewString("listval3"));
      Append(list, NewString("listval4"));
      Append(list, NewString("listval5"));

      /* Size */
      Printf(stdout, "list len: %d\n", Len(list));

      /* Delete */
      Delitem(list, 3);

      /* Replace */
      Setitem(list, 0, NewString("newlistval1"));

      /* Get */
      String *item = Getitem(list,1);
      if (item)
        Printf(stdout, "get: %s\n", item);
      else
        Printf(stdout, "get: [non-existent]\n");

      /* Iterate through the container */
      int len = Len(list);
      for (int i=0; i<len; i++) {
        String *item = Getitem(list,i);
        Printf(stdout, "list item: %s\n", item);
      }

   Resulting output:

      ::

         hash len: 5
         get: hashval2
         hash item: hashval5 [h5]
         hash item: hashval1 [h1]
         hash item: hashval2 [h2]
         hash item: hashval3 [h3]

   ` <#i2.7>`__

   .. rubric:: 2.7 Hash tables
      :name: hash-tables

   Example usage of hash tables:

      ::

         /* Create and populate */
         Hash *hash = NewHash();
         Setattr(hash, "h1", NewString("hashval1"));
         Setattr(hash, "h2", NewString("hashval2"));
         Setattr(hash, "h3", NewString("hashval3"));
         Setattr(hash, "h4", NewString("hashval4"));
         Setattr(hash, "h5", NewString("hashval5"));

         /* Size */
         Printf(stdout, "hash len: %d\n", Len(hash));

         /* Delete */
         Delattr(hash, "h4");

         /* Get */
         String *item = Getattr(hash, "h2");
         if (item)
           Printf(stdout, "get: %s\n", item);
         else
           Printf(stdout, "get: [non-existent]\n");

         /* Iterate through the container */
         Iterator it;
         for (it = First(hash); it.key; it= Next(it))
           Printf(stdout, "hash item: %s [%s]\n", (it.item), (it.key));

   Resulting output:

      ::

         list len: 5
         get: listval2
         list item: newlistval1
         list item: listval2
         list item: listval3
         list item: listval5

   ` <#i2.8>`__

   .. rubric:: 2.8 Files
      :name: files

   [ TODO ] ` <#i2.9>`__

   .. rubric:: 2.9 Void objects
      :name: void-objects

   [ TODO ] ` <#i2.10>`__

   .. rubric:: 2.10 Utility functions
      :name: utility-functions

   [ TODO ] ` <#i3>`__

   .. rubric:: 3. Types and Typemaps
      :name: types-and-typemaps

   The representation and manipulation of types is currently in the
   process of being reorganized and (hopefully) simplified. The
   following list describes the current set of functions that are used
   to manipulate datatypes.

   -  ``SwigType_str(SwigType *t, char *name)``.
      This function produces the exact string representation of the
      datatype ``t``. ``name`` is an optional parameter that specifies a
      declaration name. This is used when dealing with more complicated
      datatypes such as arrays and pointers to functions where the
      output might look something like "``int (*name)(int, double)``".

   -  | ``SwigType_lstr(SwigType *t, char *name)``.
      | This function produces a string representation of a datatype
        that can be safely be assigned a value (i.e., can be used as the
        "lvalue" of an expression). To do this, qualifiers such as
        "const", arrays, and references are stripped away or converted
        into pointers. For example:

         ::

            Original Datatype              lstr()
            ------------------             --------
            const char *a                  char *a
            double a[20]                   double *a
            double a[20][30]               double *a
            double &a                      double *a

      The intent of the lstr() function is to produce local variables
      inside wrapper functions--all of which must be reassignable types
      since they are the targets of conversions from a scripting
      representation.

   -  | ``SwigType_rcaststr(SwigType *t, char *name)``.
      | This function produces a string that casts a type produced by
        the ``lstr()`` function to the type produced by the ``str()``
        function. You might view it as the inverse of lstr(). This
        function only produces output when it needs to (when str() and
        lstr() produce different results). Furthermore, an optional name
        can be supplied when the cast is to be applied to a specific
        name. Examples:

         ::

            Original Datatype             rcaststr()
            ------------------            ---------
            char *a                       
            const char *a                 (const char *) name
            double a[20]                  (double *) name
            double a[20][30]              (double (*)[30]) name
            double &a                     (double &) *name

   -  | ``SwigType_lcaststr(SwigType *t, char *name)``.
      | This function produces a string that casts a type produced by
        the ``str()`` function to the type produced by the ``lstr()``
        function. This function only produces output when it needs to
        (when str() and lstr() produce different results). Furthermore,
        an optional name can be supplied when the cast is to be applied
        to a specific name.

         ::

            Original Datatype             lcaststr()
            ------------------            ---------
            char *a                       
            const char *a                 (char *) name
            double a[20]                  (double *) name
            double a[20][30]              (double *) name
            double &a                     (double *) &name

   -  ``SwigType_manglestr(SwigType *t)``.
      Produces a type-string that is used to identify this datatype in
      the target scripting language. Usually this string looks something
      like "``_p_p_double``" although the target language may redefine
      the output for its own purposes. Normally this function strips all
      qualifiers, references, and arrays---producing a mangled version
      of the type produced by the ``lstr()`` function.

   The following example illustrates the intended use of the above
   functions when creating wrapper functions using shorthand pseudocode.
   Suppose you had a function like this:

      ::

         int foo(int a, double b[20][30], const char *c, double &d);

   Here's how a wrapper function would be generated using the type
   generation functions above:

      ::

         wrapper_foo() {
            lstr("int","result")
            lstr("int","arg0")
            lstr("double [20][30]", "arg1")
            lstr("const char *", "arg2")
            lstr("double &", "arg3")
            ...
            get arguments
            ...
            result = (lcaststr("int"))  foo(rcaststr("int","arg0"),
                                        rcaststr("double [20][30]","arg1"),
                                        rcaststr("const char *", "arg2"),
                                        rcaststr("double &", "arg3"))
            ...
         }

   Here's how it would look with the corresponding output filled in:

      ::

         wrapper_foo() {
            int      result;
            int      arg0;
            double  *arg1;
            char    *arg2;
            double  *arg3;
            ...
            get arguments
            ...
            result = (int) foo(arg0,
                               (double (*)[30]) arg1,
                               (const char *) arg2,
                               (double &) *arg3);
            ...
         }

   **Notes:**

   -  For convenience, the string generation functions return a
      "``char *``" that points to statically allocated memory living
      inside the type library. Therefore, it is never necessary (and
      it's an error) to free the pointer returned by the functions.
      Also, if you need to save the result, you should make a copy of
      it. However, with that said, it is probably worth nothing that
      these functions do cache the last 8 results. Therefore, it's
      fairly safe to make a handful of repeated calls without making any
      copies.

   [TODO] ` <#i4>`__

   .. rubric:: 4. Parsing
      :name: parsing

   [TODO] ` <#i5>`__

   .. rubric:: 5. The C/C++ Wrapping Layer
      :name: the-cc-wrapping-layer

   Added: Dave Beazley (July 22, 2000)

   When SWIG generates wrappers, it tries to provide a mostly seamless
   integration with the original code. However, there are a number of
   problematic features of C/C++ programs that complicate this
   interface.

   -  **Passing and returning structures by value.** When used, SWIG
      converts all pass-by-value functions into wrappers that pass by
      reference. For example:

         ::

            double dot_product(Vector a, Vector b);

      gets turned into a wrapper like this:

         ::

            double wrap_dot_product(Vector *a, Vector *b) {
                 return dot_product(*a,*b);
            }

      Functions that return by value require a memory allocation to
      store the result. For example:

         ::

            Vector cross_product(Vector *a, Vector *b);

      become

         ::

            Vector *wrap_cross_product(Vector *a, Vector *b) {
               Vector *result = (Vector *) malloc(sizeof(Vector));
               *result = cross_product(a,b);
               return result;
            }

      Note: If C++ is being wrapped, the default copy constructor is
      used instead of malloc() to create a copy of the return result.

   -  **C++ references**. C++ references are handled exactly the same as
      pass/return by value except that a memory allocation is not made
      for functions that return a reference.

   -  **Qualifiers such as "const" and "volatile".** SWIG strips all
      qualifiers from the interface presented to the target language.
      Besides, what in the heck is "const" in Perl anyways?

   -  **Instance Methods**. Method invocations are handled as a function
      call in which a pointer to the object (the "this" pointer) appears
      as the first argument. For example, in the following class:

         ::

            class Foo {
            public:
                double bar(double);
            };

      The "bar" method is wrapped by a function like this:

         ::

            double Foo_bar(Foo *self, double arg0) {
               return self->bar(arg0);
            }

   -  **Structure/class data members**. Data members are handled by
      creating a pair of wrapper functions that set and get the value
      respectively. For example:

         ::

            struct Foo {
                int x;
            };

      gets wrapped as follows:

         ::

            int Foo_x_get(Foo *self) {
                return self->x;
            }
            int Foo_x_set(Foo *self, int value) {
                return (self->x = value);
            }

   -  **Constructors**. Constructors for C/C++ data structures are
      wrapped by a function like this:

         ::

            Foo *new_Foo() {
                return new Foo;
            }

      Note: For C, new objects are created using the calloc() function.

   -  **Destructors**. Destructors for C/C++ data structures are wrapper
      like this:

         ::

            void delete_Foo(Foo *self) {
                delete self;
            }

      Note: For C, objects are destroyed using free().

   The creation of wrappers and various type transformations are handled
   by a collection of functions found in the file
   ``Source/Swig/cwrap.c``.

   -  ``char *Swig_clocal(DataType *t, char *name, char *value)``
      This function creates a string containing the declaration of a
      local variable with type ``t``, name ``name``, and default value
      ``value``. This local variable is stripped of all qualifiers and
      will be a pointer if the type is a reference or user defined type.
   -  ``DataType *Swig_clocal_type(DataType *t)``
      Returns a type object corresponding to the type string produced by
      the Swig_clocal() function.
   -  ``char *Swig_clocal_deref(DataType *t, char *name)``
      This function is the inverse of the ``clocal()`` function. Given a
      type and a name, it produces a string containing the code needed
      to cast/convert the type produced by ``Swig_clocal()`` back into
      its original type.
   -  ``char *Swig_clocal_assign(DataType *t, char *name)``
      Given a type and name, this produces a string containing the code
      (and an optional cast) needed to make an assignment from the real
      datatype to the local datatype produced by ``Swig_clocal()``. Kind
      of the opposite of deref().
   -  ``int Swig_cargs(Wrapper *w, ParmList *l)``
      Given a wrapper function object and a list of parameters, this
      function declares a set of local variables for holding all of the
      parameter values (using Swig_clocal()). Returns the number of
      parameters. In addition, this function sets the local name of each
      parameter which can be retrieved using the ``Parm_Getlname()``
      function.
   -  ``void Swig_cresult(Wrapper *w, DataType *t, char *resultname, char *decl)``
      Generates the code needed to set the result of a wrapper function
      and performs all of the needed memory allocations for ANSI C (if
      necessary). ``t`` is the type of the result, ``resultname`` is the
      name of the result variable, and ``decl`` is a string that
      contains the C code which produces the result.
   -  ``void Swig_cppresult(Wrapper *w, DataType *t, char *resultname, char *decl)``
      Generates the code needed to set the result of a wrapper function
      and performs all of the needed memory allocations for C++ (if
      necessary). ``t`` is the type of the result, ``resultname`` is the
      name of the result variable, and ``decl`` is a string that
      contains the C code which produces the result.
   -  ``Wrapper *Swig_cfunction_wrapper(char *fname, DataType *rtype, ParmList *parms, char *code)``
      Create a wrapper around a normal function declaration. ``fname``
      is the name of the wrapper, ``rtype`` is the return type,
      ``parms`` are the function parameters, and ``code`` is a string
      containing the code in the function body.
   -  ``Wrapper *Swig_cmethod_wrapper(char *classname, char *methodname, DataType *rtype, DataType *parms, char *code)``
   -  ``char *Swig_cfunction_call(char *name, ParmList *parms)`` This
      function produces a string containing the code needed to call a C
      function. The string that is produced contains all of the
      transformations needed to convert pass-by-value into
      pass-by-reference as well as handle C++ references. Produces a
      string like "name(arg0, arg1, ..., argn)".

   Here is a short example showing how these functions could be used.
   Suppose you had a C function like this:

      ::

         double dot_product(Vector a, Vector b);

   Here's how you might write a really simple wrapper function

      ::

         ParmList *l = ... parameter list of the function ...
         DataType *t = ... return type of the function ...
         char     *name = ... name of the function ...
         Wrapper *w = NewWrapper();
         Printf(w->def,"void wrap_%s() {\n", name);

         /* Declare all of the local variables */
         Swig_cargs(w, l);

         /* Convert all of the arguments */
         ...

         /* Make the function call and declare the result variable */
         Swig_cresult(w,t,"result",Swig_cfunction(name,l));

         /* Convert the result into whatever */
         ...

         Printf(w->code,"}\n");
         Wrapper_print(w,out);

   The output of this would appear as follows:

      ::

         void wrap_dot_product() {
             Vector *arg0;
             Vector *arg1;
             double  result;

             ...
             result = dot_product(*arg0, *arg1);
             ...
         }

   Notice that the ``Swig_cargs()``, ``Swig_cresult()``, and
   ``Swig_cfunction()`` functions have taken care of the type
   conversions for the ``Vector`` type automatically.

   **Notes:**

   -  The intent of these functions is to provide *consistent* handling
      of function parameters and return values so that language module
      writers don't have to worry about it too much.
   -  These functions may be superseded by features in the new typemap
      system which provide hooks for specifying local variable
      declarations and argument conversions.

   ` <#i6>`__

   .. rubric:: 6. Symbol Naming Guidelines for Generated C/C++ Code
      :name: symbol-naming-guidelines-for-generated-cc-code

   The C++ standard (ISO/IEC 14882:1998(E)) states:

      ::


         17.4.3.1.2 Global names [lib.global.names]

         1 Certain sets of names and function signatures are always reserved to the implementation:

             * Each name that contains a double underscore (__) or begins with an underscore followed 
               by an upper case letter (2.11) is reserved to the implementation for any use.
             * Each name that begins with an underscore is reserved to the implementation for use as 
               a name in the global namespace.165)

             165) Such names are also reserved in namespace ::std (17.4.3.1). [back to text] 

   When generating code it is important not to generate symbols that
   might clash with the code being wrapped. It is tempting to flout the
   standard or just use a symbol which starts with a single underscore
   followed by a lowercase letter in order to avoid name clashes.
   However even these legal symbols can also clash with symbols being
   wrapped. The following guidelines should be used when generating code
   in order to meet the standard and make it highly unlikely that symbol
   clashes will occur:

   For C++ code that doesn't attempt to mangle a symbol being wrapped
   (for example SWIG convenience functions):

   -  Put symbols in the ``Swig`` namespace, for example class
      ``Swig::Director``. Qualify using the ``Swig`` namespace whenever
      the symbol is referenced, even within the ``Swig`` namespace, for
      example ``new Swig::Director()`` not ``new Director()``.
   -  Use ``swig_`` as a prefix for all member variables and member
      functions that are involved in an inheritance chain with wrapped
      classes, for example ``Swig::Director::swig_get_up()`` and
      ``bool Swig::Director::swig_up``.
   -  Alternatively class names can be prefixed with ``Swig`` in the
      global namespace for example
      ``template<class T> class SwigValueWrapper``.

   For code compiled as C or C++ that doesn't attempt to mangle a symbol
   being wrapped (for example SWIG convenience functions):

   -  Use ``SWIG_`` as a prefix for structures for example
      ``SWIG_JavaExceptions_t``.
   -  Use ``SWIG_`` as a prefix for global functions for example
      ``SWIG_TypeRegister``.
   -  Use ``SWIG_`` as a prefix for macros for example
      ``#define SWIG_PY_INT 1``

   For code compiled as C or C++ that attempts to mangle a wrapped
   symbol:

   -  Use ``SWIGxxx`` or ``Swigxxx`` as a prefix where xxx is chosen
      which would make ``SWIGxxx``/``Swigxxx`` a unique symbol in the
      global namespace, for example ``class SwigDirectorFoo`` when
      wrapping ``class Foo``. Don't use a trailing underscore for the
      prefix as this may generate a double underscore when wrapping a
      symbol which starts with a single underscore.

   In the past SWIG has generated many symbols which flout the standard
   especially double underscores. In fact they may not all be rooted out
   yet, so please fix them when you see them. ` <#i7>`__

   .. rubric:: 7. Debugging SWIG
      :name: debugging-swig

   The DOH types used in the SWIG source code are all typedefined to
   void. Consequently, it is impossible for debuggers to automatically
   extract any information about DOH objects. The easiest approach to
   debugging and viewing the contents of DOH objects is to make a call
   into one of the family of SWIG print functions from the debugger. The
   "Debugging Functions" section in `SWIG Parse Tree
   Handling <tree.html>`__ lists them. It is sometimes easier to debug
   by placing a few calls to these functions in code of interest and
   recompile, especially if your debugger cannot easily make calls into
   functions within a debugged binary.

   The SWIG distribution comes with some additional support for the gdb
   debugger in the ``Tools/swig.gdb`` file. Follow the instructions in
   this file for 'installing'. This support file provides an easy way to
   call into some of the family of SWIG print functions via additional
   user-defined gdb commands. Some usage of the ``swigprint`` and
   ``locswigprint`` user-defined commands are demonstrated below.

   More often than not, a parse tree node needs to be examined. The
   session below displays the node ``n`` in one of the Java language
   module wrapper functions. The ``swigprint`` method is used to show
   the symbol name (``symname`` - a DOH String type) and the node (``n``
   - a DOH Hash type).

      ::

         Breakpoint 1, JAVA::functionWrapper (this=0x97ea5f0, n=0xb7d2afc8) at Modules/java.cxx:799
         799     String *symname = Getattr(n, "sym:name");
         (gdb) next
         800     SwigType *t = Getattr(n, "type");
         (gdb) swigprint symname
         Shape_x_set
         (gdb) swigprint n
         Hash(0xb7d2afc8) {
           'membervariableHandler:view' : variableHandler, 
           'feature:except' : 0, 
           'name' : x, 
           'ismember' : 1, 
           'sym:symtab' : Hash(0xb7d2aca8) {......}, 
           'nodeType' : cdecl, 
           'nextSibling' : Hash(0xb7d2af98) {.............}, 
           'kind' : variable, 
           'variableHandler:feature:immutable' : <Object 'VoidObj' at 0xb7cfa008>, 
           'sym:name' : Shape_x_set, 
           'view' : membervariableHandler, 
           'membervariableHandler:sym:name' : x, 
           'membervariableHandler:type' : double, 
           'membervariableHandler:parms' : <Object 'VoidObj' at 0xb7cfa008>, 
           'parentNode' : Hash(0xb7d2abc8) {..............................}, 
           'feature:java:enum' : typesafe, 
           'access' : public, 
           'parms' : Hash(0xb7cb9408) {......}, 
           'wrap:action' : if (arg1) (arg1)->x = arg2;, 
           'type' : void, 
           'memberset' : 1, 
           'sym:overname' : __SWIG_0, 
           'membervariableHandler:name' : x, 
         }

   Note that all the attributes in the Hash are shown, including the
   'sym:name' attribute which was assigned to the ``symname`` variable.

   Hash types can be shown either expanded or collapsed. When a Hash is
   shown expanded, all the attributes are displayed along with their
   values, otherwise a '.' replaces each attribute when collapsed.
   Therefore a count of the dots provides the number of attributes
   within an unexpanded Hash. Below shows the 'parms' Hash being
   displayed with the default Hash expansion of 1, then with 2 provided
   as the second argument to ``swigprint`` to expand to two Hash levels
   in order to view the contents of the collapsed 'nextSibling' Hash.

      ::

         (gdb) swigprint 0xb7cb9408
         Hash(0xb7cb9408) {
           'name' : self, 
           'type' : p.Shape, 
           'self' : 1, 
           'nextSibling' : Hash(0xb7cb9498) {...}, 
           'hidden' : 1, 
           'nodeType' : parm, 
         }
         (gdb) swigprint 0xb7cb9408 2
         Hash(0xb7cb9408) {
           'name' : self, 
           'type' : p.Shape, 
           'self' : 1, 
           'nextSibling' : Hash(0xb7cb9498) {
             'name' : x, 
             'type' : double, 
             'nodeType' : parm, 
           }, 
           'hidden' : 1, 
           'nodeType' : parm, 
         }

   The same Hash can also be displayed with file and line location
   information via the ``locswigprint`` command.

      ::

         (gdb) locswigprint 0xb7cb9408
         example.h:11: [Hash(0xb7cb9408) {
         Hash(0xb7cb9408) {
           'name' : self, 
           'type' : p.Shape, 
           'self' : 1, 
           'nextSibling' : Hash(0xb7cb9498) {...}, 
           'hidden' : 1, 
           'nodeType' : parm, 
         }]

   **Tip**: Commands in gdb can be shortened with whatever makes them
   unique and can be command completed with the tab key. Thus
   ``swigprint`` can usually be shortened to ``sw`` and ``locswigprint``
   to ``loc``. The help for each command can also be obtained within the
   debugging session, for example, 'help swigprint'.

   The sub-section below gives pointers for debugging DOH objects using
   casts and provides an insight into why it can be hard to debug SWIG
   without the family of print functions.

   ` <#i7.1>`__

   .. rubric:: 7.1 Debugging DOH Types The Hard Way
      :name: debugging-doh-types-the-hard-way

   The DOH types used in SWIG are all typedefined to void and hence the
   lack of type information for inspecting types within a debugger. Most
   debuggers will however be able to display useful variable information
   when an object is cast to the appropriate type. Getting at the
   underlying C string within DOH types is cumbersome, but possible with
   appropriate casts. The casts below can be used in a debugger windows,
   but be sure to compile with compiler optimisations turned off before
   attempting the casts else they are unlikely to work. Even displaying
   the underlying string in a String \* doesn't work straight off in all
   debuggers due to the multiple definitions of String as a struct and a
   void.

   Below are a list of common SWIG types. With each is the cast that can
   be used in the debugger to extract the underlying type information
   and the underlying char \* string.

   -  String \*s;
   -  SwigType \*t;
   -  const_String_or_char_ptr sc;

   ` <#i7.2>`__

   .. rubric:: 7.2 Debugging DOH memory allocation problems
      :name: debugging-doh-memory-allocation-problems

   The DOH objects are reference counted and use pools for memory
   allocation. The implementation is in ``memory.c``. When there are
   memory corruption problems, various memory allocator tools are
   normally used to diagnose problems. These can be used on SWIG and can
   be very useful. However, they won't necessarily find use of stale DOH
   objects, that is, DOH objects that are used after they have been
   deleted. This is because the DOH memory allocator grabs a chunk of
   memory from the C memory allocator and manages the usage internally.
   Stale DOH object usage can be checked for by defining
   ``DOH_DEBUG_MEMORY_POOLS`` in ``memory.c``. If an attempt to use an
   object is made after the reference count is zero, an assertion is
   triggered instead of quietly re-using the stale object...

      ::

         swig: DOH/memory.c:91: DohCheck: Assertion `!DOH_object_already_deleted' failed.

   This can be memory intensive as previously used memory in the pool is
   not re-used so is only recommended for diagnosing memory corruption
   problems.

   --------------

   Copyright (C) 1999-2010 SWIG Development Team.

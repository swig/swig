SWIG library
===============

To help build extension modules, SWIG is packaged with a library of
support files that you can include in your own interfaces. These files
often define new SWIG directives or provide utility functions that can
be used to access parts of the standard C and C++ libraries. This
chapter provides a reference to the current set of supported library
files.

**Compatibility note:** Older versions of SWIG included a number of
library files for manipulating pointers, arrays, and other structures.
Most these files are now deprecated and have been removed from the
distribution. Alternative libraries provide similar functionality.
Please read this chapter carefully if you used the old libraries.

The %include directive and library search path
---------------------------------------------------

Library files are included using the ``%include`` directive. When
searching for files, directories are searched in the following order:

#. The current directory
#. Directories specified with the ``-I`` command line option
#. .\ ``/swig_lib``
#. SWIG library install location as reported by ``swig -swiglib``, for
   example ``/usr/local/share/swig/1.3.30``
#. On Windows, a directory ``Lib`` relative to the location of
   ``swig.exe`` is also searched.

Within directories mentioned in points 3-5, SWIG first looks for a
subdirectory corresponding to a target language (e.g., ``python``,
``tcl``, etc.). If found, SWIG will search the language specific
directory first. This allows for language-specific implementations of
library files.

You can ignore the installed SWIG library by setting the ``SWIG_LIB``
environment variable. Set the environment variable to hold an
alternative library directory.

The directories that are searched are displayed when using ``-verbose``
commandline option.

C arrays and pointers
--------------------------

This section describes library modules for manipulating low-level C
arrays and pointers. The primary use of these modules is in supporting C
declarations that manipulate bare pointers such as ``int *``,
``double *``, or ``void *``. The modules can be used to allocate memory,
manufacture pointers, dereference memory, and wrap pointers as
class-like objects. Since these functions provide direct access to
memory, their use is potentially unsafe and you should exercise caution.

cpointer.i
~~~~~~~~~~~~~~~~~

The ``cpointer.i`` module defines macros that can be used to used to
generate wrappers around simple C pointers. The primary use of this
module is in generating pointers to primitive datatypes such as ``int``
and ``double``.

**``%pointer_functions(type, name)``**

.. container:: indent

   Generates a collection of four functions for manipulating a pointer
   ``type *``:

   ``type *new_name()``

   .. container:: indent

      Creates a new object of type ``type`` and returns a pointer to it.
      In C, the object is created using ``calloc()``. In C++, ``new`` is
      used.

   ``type *copy_name(type value)``

   .. container:: indent

      Creates a new object of type ``type`` and returns a pointer to it.
      An initial value is set by copying it from ``value``. In C, the
      object is created using ``calloc()``. In C++, ``new`` is used.

   ``type *delete_name(type *obj)``

   .. container:: indent

      Deletes an object type ``type``.

   ``void name_assign(type *obj, type value)``

   .. container:: indent

      Assigns ``*obj = value``.

   ``type name_value(type *obj)``

   .. container:: indent

      Returns the value of ``*obj``.

   When using this macro, ``type`` may be any type and ``name`` must be
   a legal identifier in the target language. ``name`` should not
   correspond to any other name used in the interface file.

   Here is a simple example of using ``%pointer_functions()``:

   .. container:: code

      ::

         %module example
         %include "cpointer.i"

         /* Create some functions for working with "int *" */
         %pointer_functions(int, intp);

         /* A function that uses an "int *" */
         void add(int x, int y, int *result);

   Now, in Python:

   .. container:: targetlang

      ::

         >>> import example
         >>> c = example.new_intp()     # Create an "int" for storing result
         >>> example.add(3, 4, c)       # Call function
         >>> example.intp_value(c)      # Dereference
         7
         >>> example.delete_intp(c)     # Delete

**``%pointer_class(type, name)``**

.. container:: indent

   Wraps a pointer of ``type *`` inside a class-based interface. This
   interface is as follows:

   .. container:: code

      ::

         struct name {
           name();                            // Create pointer object
           ~name();                           // Delete pointer object
           void assign(type value);           // Assign value
           type value();                      // Get value
           type *cast();                      // Cast the pointer to original type
           static name *frompointer(type *);  // Create class wrapper from existing
                                              // pointer
         };

   When using this macro, ``type`` is restricted to a simple type name
   like ``int``, ``float``, or ``Foo``. Pointers and other complicated
   types are not allowed. ``name`` must be a valid identifier not
   already in use. When a pointer is wrapped as a class, the "class" may
   be transparently passed to any function that expects the pointer.

   If the target language does not support proxy classes, the use of
   this macro will produce the example same functions as
   ``%pointer_functions()`` macro.

   It should be noted that the class interface does introduce a new
   object or wrap a pointer inside a special structure. Instead, the raw
   pointer is used directly.

   Here is the same example using a class instead:

   .. container:: code

      ::

         %module example
         %include "cpointer.i"

         /* Wrap a class interface around an "int *" */
         %pointer_class(int, intp);

         /* A function that uses an "int *" */
         void add(int x, int y, int *result);

   Now, in Python (using proxy classes)

   .. container:: targetlang

      ::

         >>> import example
         >>> c = example.intp()         # Create an "int" for storing result
         >>> example.add(3, 4, c)       # Call function
         >>> c.value()                  # Dereference
         7

   Of the two macros, ``%pointer_class`` is probably the most convenient
   when working with simple pointers. This is because the pointers are
   access like objects and they can be easily garbage collected
   (destruction of the pointer object destroys the underlying object).

**``%pointer_cast(type1, type2, name)``**

.. container:: indent

   Creates a casting function that converts ``type1`` to ``type2``. The
   name of the function is ``name``. For example:

   .. container:: code

      ::

         %pointer_cast(int *, unsigned int *, int_to_uint);

   In this example, the function ``int_to_uint()`` would be used to cast
   types in the target language.

**Note:** None of these macros can be used to safely work with strings
(``char *`` or ``char **``).

**Note:** When working with simple pointers, typemaps can often be used
to provide more seamless operation.

carrays.i
~~~~~~~~~~~~~~~~

This module defines macros that assist in wrapping ordinary C pointers
as arrays. The module does not provide any safety or an extra layer of
wrapping--it merely provides functionality for creating, destroying, and
modifying the contents of raw C array data.

**``%array_functions(type, name)``**

.. container:: indent

   Creates four functions.

   ``type *new_name(int nelements)``

   .. container:: indent

      Creates a new array of objects of type ``type``. In C, the array
      is allocated using ``calloc()``. In C++, ``new []`` is used.

   ``type *delete_name(type *ary)``

   .. container:: indent

      Deletes an array. In C, ``free()`` is used. In C++, ``delete []``
      is used.

   ``type name_getitem(type *ary, int index)``

   .. container:: indent

      Returns the value ``ary[index]``.

   ``void name_setitem(type *ary, int index, type value)``

   .. container:: indent

      Assigns ``ary[index] = value``.

   When using this macro, ``type`` may be any type and ``name`` must be
   a legal identifier in the target language. ``name`` should not
   correspond to any other name used in the interface file.

   Here is an example of ``%array_functions()``. Suppose you had a
   function like this:

   .. container:: code

      ::

         void print_array(double x[10]) {
           int i;
           for (i = 0; i < 10; i++) {
             printf("[%d] = %g\n", i, x[i]);
           }
         }

   To wrap it, you might write this:

   .. container:: code

      ::

         %module example

         %include "carrays.i"
         %array_functions(double, doubleArray);

         void print_array(double x[10]);

   Now, in a scripting language, you might write this:

   .. container:: targetlang

      ::

         a = new_doubleArray(10)               # Create an array
         for i in range(0, 10):
             doubleArray_setitem(a, i, 2 * i)  # Set a value
         print_array(a)                        # Pass to C
         delete_doubleArray(a)                 # Destroy array

**``%array_class(type, name)``**

.. container:: indent

   Wraps a pointer of ``type *`` inside a class-based interface. This
   interface is as follows:

   .. container:: code

      ::

         struct name {
           name(int nelements);                  // Create an array
           ~name();                              // Delete array
           type getitem(int index);              // Return item
           void setitem(int index, type value);  // Set item
           type *cast();                         // Cast to original type
           static name *frompointer(type *);     // Create class wrapper from
                                                 // existing pointer
         };

   When using this macro, ``type`` is restricted to a simple type name
   like ``int`` or ``float``. Pointers and other complicated types are
   not allowed. ``name`` must be a valid identifier not already in use.
   When a pointer is wrapped as a class, it can be transparently passed
   to any function that expects the pointer.

   When combined with proxy classes, the ``%array_class()`` macro can be
   especially useful. For example:

   .. container:: code

      ::

         %module example
         %include "carrays.i"
         %array_class(double, doubleArray);

         void print_array(double x[10]);

   Allows you to do this:

   .. container:: targetlang

      ::

         import example
         c = example.doubleArray(10)  # Create double[10]
         for i in range(0, 10):
             c[i] = 2 * i             # Assign values
         example.print_array(c)       # Pass to C

**Note:** These macros do not encapsulate C arrays inside a special data
structure or proxy. There is no bounds checking or safety of any kind.
If you want this, you should consider using a special array object
rather than a bare pointer.

**Note:** ``%array_functions()`` and ``%array_class()`` should not be
used with types of ``char`` or ``char *``. SWIG's default handling of
these types is to handle them as character strings and the two macros do
not do enough to change this.

cmalloc.i
~~~~~~~~~~~~~~~~

This module defines macros for wrapping the low-level C memory
allocation functions ``malloc()``, ``calloc()``, ``realloc()``, and
``free()``.

**``%malloc(type [, name=type])``**

.. container:: indent

   Creates a wrapper around ``malloc()`` with the following prototype:

   .. container:: code

      ::

         type *malloc_name(int nbytes = sizeof(type));

   If ``type`` is ``void``, then the size parameter ``nbytes`` is
   required. The ``name`` parameter only needs to be specified when
   wrapping a type that is not a valid identifier (e.g., "``int *``",
   "``double **``", etc.).

**``%calloc(type [, name=type])``**

.. container:: indent

   Creates a wrapper around ``calloc()`` with the following prototype:

   .. container:: code

      ::

         type *calloc_name(int nobj =1, int sz = sizeof(type));

   If ``type`` is ``void``, then the size parameter ``sz`` is required.

**``%realloc(type [, name=type])``**

.. container:: indent

   Creates a wrapper around ``realloc()`` with the following prototype:

   .. container:: code

      ::

         type *realloc_name(type *ptr, int nitems);

   Note: unlike the C ``realloc()``, the wrapper generated by this macro
   implicitly includes the size of the corresponding type. For example,
   ``realloc_int(p, 100)`` reallocates ``p`` so that it holds 100
   integers.

**``%free(type [, name=type])``**

.. container:: indent

   Creates a wrapper around ``free()`` with the following prototype:

   .. container:: code

      ::

         void free_name(type *ptr);

**``%sizeof(type [, name=type])``**

.. container:: indent

   Creates the constant:

   .. container:: code

      ::

         %constant int sizeof_name = sizeof(type);

**``%allocators(type [, name=type])``**

.. container:: indent

   Generates wrappers for all five of the above operations.

Here is a simple example that illustrates the use of these macros:

.. container:: code

   ::

      // SWIG interface
      %module example
      %include "cmalloc.i"

      %malloc(int);
      %free(int);

      %malloc(int *, intp);
      %free(int *, intp);

      %allocators(double);

Now, in a script:

.. container:: targetlang

   ::

      >>> from example import *
      >>> a = malloc_int()
      >>> a
      '_000efa70_p_int'
      >>> free_int(a)
      >>> b = malloc_intp()
      >>> b
      '_000efb20_p_p_int'
      >>> free_intp(b)
      >>> c = calloc_double(50)
      >>> c
      '_000fab98_p_double'
      >>> c = realloc_double(100000)
      >>> free_double(c)
      >>> print sizeof_double
      8
      >>>

cdata.i
~~~~~~~~~~~~~~

The ``cdata.i`` module defines functions for converting raw C data to
and from strings in the target language. The primary applications of
this module would be packing/unpacking of binary data structures---for
instance, if you needed to extract data from a buffer. The target
language must support strings with embedded binary data in order for
this to work.

**``const char *cdata(void *ptr, size_t nbytes)``**

.. container:: indent

   Converts ``nbytes`` of data at ``ptr`` into a string. ``ptr`` can be
   any pointer.

**``void memmove(void *ptr, const char *s)``**

.. container:: indent

   Copies all of the string data in ``s`` into the memory pointed to by
   ``ptr``. The string may contain embedded NULL bytes. This is actually
   a wrapper to the standard C library ``memmove`` function, which is
   declared as
   **``void memmove(void *ptr, const void *src, size_t n)``**. The
   ``src`` and length ``n`` parameters are extracted from the language
   specific string ``s`` in the underlying wrapper code.

One use of these functions is packing and unpacking data from memory.
Here is a short example:

.. container:: code

   ::

      // SWIG interface
      %module example
      %include "carrays.i"
      %include "cdata.i"

      %array_class(int, intArray);

Python example:

.. container:: targetlang

   ::

      >>> a = intArray(10)
      >>> for i in range(0, 10):
      ...    a[i] = i
      >>> b = cdata(a, 40)
      >>> b
      '\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x02\x00\x00\x00\x03\x00\x00\x00\x04
      \x00\x00\x00\x05\x00\x00\x00\x06\x00\x00\x00\x07\x00\x00\x00\x08\x00\x00\x00\t'
      >>> c = intArray(10)
      >>> memmove(c, b)
      >>> print c[4]
      4
      >>>

Since the size of data is not always known, the following macro is also
defined:

**``%cdata(type [, name=type])``**

.. container:: indent

   Generates the following function for extracting C data for a given
   type.

   .. container:: code

      ::

         char *cdata_name(type* ptr, int nitems)

   ``nitems`` is the number of items of the given type to extract.

**Note:** These functions provide direct access to memory and can be
used to overwrite data. Clearly they are unsafe.

C string handling
----------------------

A common problem when working with C programs is dealing with functions
that manipulate raw character data using ``char *``. In part, problems
arise because there are different interpretations of ``char *``---it
could be a NULL-terminated string or it could point to binary data.
Moreover, functions that manipulate raw strings may mutate data, perform
implicit memory allocations, or utilize fixed-sized buffers.

The problems (and perils) of using ``char *`` are well-known. However,
SWIG is not in the business of enforcing morality. The modules in this
section provide basic functionality for manipulating raw C strings.

Default string handling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Suppose you have a C function with this prototype:

.. container:: code

   ::

      char *foo(char *s);

The default wrapping behavior for this function is to set ``s`` to a raw
``char *`` that refers to the internal string data in the target
language. In other words, if you were using a language like Tcl, and you
wrote this,

.. container:: targetlang

   ::

      % foo Hello

then ``s`` would point to the representation of "Hello" inside the Tcl
interpreter. When returning a ``char *``, SWIG assumes that it is a
NULL-terminated string and makes a copy of it. This gives the target
language its own copy of the result.

There are obvious problems with the default behavior. First, since a
``char *`` argument points to data inside the target language, it is
**NOT** safe for a function to modify this data (doing so may corrupt
the interpreter and lead to a crash). Furthermore, the default behavior
does not work well with binary data. Instead, strings are assumed to be
NULL-terminated.

Passing binary data
~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have a function that expects binary data,

.. container:: code

   ::

      size_t parity(char *str, size_t len, size_t initial);

you can wrap the parameters ``(char *str, size_t len)`` as a single
argument using a typemap. Just do this:

.. container:: code

   ::

      %apply (char *STRING, size_t LENGTH) { (char *str, size_t len) };
      ...
      size_t parity(char *str, size_t len, size_t initial);

Now, in the target language, you can use binary string data like this:

.. container:: targetlang

   ::

      >>> s = "H\x00\x15eg\x09\x20"
      >>> parity(s, 0)

In the wrapper function, the passed string will be expanded to a pointer
and length parameter. The ``(char *STRING, int LENGTH)`` multi-argument
typemap is also available in addition to
``(char *STRING, size_t LENGTH)``.

Using %newobject to release memory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have a function that allocates memory like this,

.. container:: code

   ::

      char *foo() {
        char *result = (char *) malloc(...);
        ...
        return result;
      }

then the SWIG generated wrappers will have a memory leak--the returned
data will be copied into a string object and the old contents ignored.

To fix the memory leak, use the ``%newobject`` directive.

.. container:: code

   ::

      %newobject foo;
      ...
      char *foo();

This will release the result if the appropriate target language support
is available. SWIG provides the appropriate "newfree" typemap for
``char *`` so that the memory is released, however, you may need to
provide your own "newfree" typemap for other types. See `Object
ownership and %newobject <Customization.html#Customization_ownership>`__
for more details.

cstring.i
~~~~~~~~~~~~~~~~

The ``cstring.i`` library file provides a collection of macros for
dealing with functions that either mutate string arguments or which try
to output string data through their arguments. An example of such a
function might be this rather questionable implementation:

.. container:: code

   ::

      void get_path(char *s) {
        // Potential buffer overflow---uh, oh.
        sprintf(s, "%s/%s", base_directory, sub_directory);
      }
      ...
      // Somewhere else in the C program
      {
        char path[1024];
        ...
        get_path(path);
        ...
      }

(Off topic rant: If your program really has functions like this, you
would be well-advised to replace them with safer alternatives involving
bounds checking).

The macros defined in this module all expand to various combinations of
typemaps. Therefore, the same pattern matching rules and ideas apply.

**%cstring_bounded_output(parm, maxsize)**

.. container:: indent

   Turns parameter ``parm`` into an output value. The output string is
   assumed to be NULL-terminated and smaller than ``maxsize``
   characters. Here is an example:

   .. container:: code

      ::

         %cstring_bounded_output(char *path, 1024);
         ...
         void get_path(char *path);

   In the target language:

   .. container:: targetlang

      ::

         >>> get_path()
         /home/beazley/packages/Foo/Bar
         >>>

   Internally, the wrapper function allocates a small buffer (on the
   stack) of the requested size and passes it as the pointer value. Data
   stored in the buffer is then returned as a function return value. If
   the function already returns a value, then the return value and the
   output string are returned together (multiple return values). **If
   more than ``maxsize`` bytes are written, your program will crash with
   a buffer overflow!**

**%cstring_chunk_output(parm, chunksize)**

.. container:: indent

   Turns parameter ``parm`` into an output value. The output string is
   always ``chunksize`` and may contain binary data. Here is an example:

   .. container:: code

      ::

         %cstring_chunk_output(char *packet, PACKETSIZE);
         ...
         void get_packet(char *packet);

   In the target language:

   .. container:: targetlang

      ::

         >>> get_packet()
         '\xa9Y:\xf6\xd7\xe1\x87\xdbH;y\x97\x7f\xd3\x99\x14V\xec\x06\xea\xa2\x88'
         >>>

   This macro is essentially identical to ``%cstring_bounded_output``.
   The only difference is that the result is always ``chunksize``
   characters. Furthermore, the result can contain binary data. **If
   more than ``maxsize`` bytes are written, your program will crash with
   a buffer overflow!**

**%cstring_bounded_mutable(parm, maxsize)**

.. container:: indent

   Turns parameter ``parm`` into a mutable string argument. The input
   string is assumed to be NULL-terminated and smaller than ``maxsize``
   characters. The output string is also assumed to be NULL-terminated
   and less than ``maxsize`` characters.

   .. container:: code

      ::

         %cstring_bounded_mutable(char *ustr, 1024);
         ...
         void make_upper(char *ustr);

   In the target language:

   .. container:: targetlang

      ::

         >>> make_upper("hello world")
         'HELLO WORLD'
         >>>

   Internally, this macro is almost exactly the same as
   ``%cstring_bounded_output``. The only difference is that the
   parameter accepts an input value that is used to initialize the
   internal buffer. It is important to emphasize that this function does
   not mutate the string value passed---instead it makes a copy of the
   input value, mutates it, and returns it as a result. **If more than
   ``maxsize`` bytes are written, your program will crash with a buffer
   overflow!**

**%cstring_mutable(parm [, expansion])**

.. container:: indent

   Turns parameter ``parm`` into a mutable string argument. The input
   string is assumed to be NULL-terminated. An optional parameter
   ``expansion`` specifies the number of extra characters by which the
   string might grow when it is modified. The output string is assumed
   to be NULL-terminated and less than the size of the input string plus
   any expansion characters.

   .. container:: code

      ::

         %cstring_mutable(char *ustr);
         ...
         void make_upper(char *ustr);

         %cstring_mutable(char *hstr, HEADER_SIZE);
         ...
         void attach_header(char *hstr);

   In the target language:

   .. container:: targetlang

      ::

         >>> make_upper("hello world")
         'HELLO WORLD'
         >>> attach_header("Hello world")
         'header: Hello world'
         >>>

   This macro differs from ``%cstring_bounded_mutable()`` in that a
   buffer is dynamically allocated (on the heap using ``malloc/new``).
   This buffer is always large enough to store a copy of the input value
   plus any expansion bytes that might have been requested. It is
   important to emphasize that this function does not directly mutate
   the string value passed---instead it makes a copy of the input value,
   mutates it, and returns it as a result. **If the function expands the
   result by more than ``expansion`` extra bytes, then the program will
   crash with a buffer overflow!**

**%cstring_output_maxsize(parm, maxparm)**

.. container:: indent

   This macro is used to handle bounded character output functions where
   both a ``char *`` and a maximum length parameter are provided. As
   input, a user simply supplies the maximum length. The return value is
   assumed to be a NULL-terminated string.

   .. container:: code

      ::

         %cstring_output_maxsize(char *path, int maxpath);
         ...
         void get_path(char *path, int maxpath);

   In the target language:

   .. container:: targetlang

      ::

         >>> get_path(1024)
         '/home/beazley/Packages/Foo/Bar'
         >>>

   This macro provides a safer alternative for functions that need to
   write string data into a buffer. User supplied buffer size is used to
   dynamically allocate memory on heap. Results are placed into that
   buffer and returned as a string object.

**%cstring_output_withsize(parm, maxparm)**

.. container:: indent

   This macro is used to handle bounded character output functions where
   both a ``char *`` and a pointer ``int *`` are passed. Initially, the
   ``int *`` parameter points to a value containing the maximum size. On
   return, this value is assumed to contain the actual number of bytes.
   As input, a user simply supplies the maximum length. The output value
   is a string that may contain binary data.

   .. container:: code

      ::

         %cstring_output_withsize(char *data, int *maxdata);
         ...
         void get_data(char *data, int *maxdata);

   In the target language:

   .. container:: targetlang

      ::

         >>> get_data(1024)
         'x627388912'
         >>> get_data(1024)
         'xyzzy'
         >>>

   This macro is a somewhat more powerful version of
   ``%cstring_output_chunk()``. Memory is dynamically allocated and can
   be arbitrary large. Furthermore, a function can control how much data
   is actually returned by changing the value of the ``maxparm``
   argument.

**%cstring_output_allocate(parm, release)**

.. container:: indent

   This macro is used to return strings that are allocated within the
   program and returned in a parameter of type ``char **``. For example:

   .. container:: code

      ::

         void foo(char **s) {
           *s = (char *) malloc(64);
           sprintf(*s, "Hello world\n");
         }

   The returned string is assumed to be NULL-terminated. ``release``
   specifies how the allocated memory is to be released (if applicable).
   Here is an example:

   .. container:: code

      ::

         %cstring_output_allocate(char **s, free(*$1));
         ...
         void foo(char **s);

   In the target language:

   .. container:: targetlang

      ::

         >>> foo()
         'Hello world\n'
         >>>

**%cstring_output_allocate_size(parm, szparm, release)**

.. container:: indent

   This macro is used to return strings that are allocated within the
   program and returned in two parameters of type ``char **`` and
   ``int *``. For example:

   .. container:: code

      ::

         void foo(char **s, int *sz) {
           *s = (char *) malloc(64);
           *sz = 64;
           // Write some binary data
           ...
         }

   The returned string may contain binary data. ``release`` specifies
   how the allocated memory is to be released (if applicable). Here is
   an example:

   .. container:: code

      ::

         %cstring_output_allocate_size(char **s, int *slen, free(*$1));
         ...
         void foo(char **s, int *slen);

   In the target language:

   .. container:: targetlang

      ::

         >>> foo()
         '\xa9Y:\xf6\xd7\xe1\x87\xdbH;y\x97\x7f\xd3\x99\x14V\xec\x06\xea\xa2\x88'
         >>>

   This is the safest and most reliable way to return binary string data
   in SWIG. If you have functions that conform to another prototype, you
   might consider wrapping them with a helper function. For example, if
   you had this:

   .. container:: code

      ::

         char  *get_data(int *len);

   You could wrap it with a function like this:

   .. container:: code

      ::

         void my_get_data(char **result, int *len) {
           *result = get_data(len);
         }

**Comments:**

-  Support for the ``cstring.i`` module depends on the target language.
   Not all SWIG modules currently support this library.
-  Reliable handling of raw C strings is a delicate topic. There are
   many ways to accomplish this in SWIG. This library provides support
   for a few common techniques.
-  If used in C++, this library uses ``new`` and ``delete []`` for
   memory allocation. If using C, the library uses ``malloc()`` and
   ``free()``.
-  Rather than manipulating ``char *`` directly, you might consider
   using a special string structure or class instead.

STL/C++ library
--------------------

The library modules in this section provide access to parts of the
standard C++ library including the STL. SWIG support for the STL is an
ongoing effort. Support is quite comprehensive for some language modules
but some of the lesser used modules do not have quite as much library
code written.

The following table shows which C++ classes are supported and the
equivalent SWIG interface library file for the C++ library.

+----------------------+----------------------+----------------------+
| **C++ class**        | **C++ Library file** | **SWIG Interface     |
|                      |                      | library file**       |
+----------------------+----------------------+----------------------+
| std::array (C++11)   | array                | std_array.i          |
+----------------------+----------------------+----------------------+
| std::auto_ptr        | memory               | std_auto_ptr.i       |
+----------------------+----------------------+----------------------+
| std::complex         | complex              | std_complex.i        |
+----------------------+----------------------+----------------------+
| std::deque           | deque                | std_deque.i          |
+----------------------+----------------------+----------------------+
| std::list            | list                 | std_list.i           |
+----------------------+----------------------+----------------------+
| std::map             | map                  | std_map.i            |
+----------------------+----------------------+----------------------+
| std::multimap        | multimap             | std_multimap.i       |
| (C++11)              |                      |                      |
+----------------------+----------------------+----------------------+
| std::multiset        | multiset             | std_multiset.i       |
| (C++11)              |                      |                      |
+----------------------+----------------------+----------------------+
| std::pair            | utility              | std_pair.i           |
+----------------------+----------------------+----------------------+
| std::set             | set                  | std_set.i            |
+----------------------+----------------------+----------------------+
| std::string          | string               | std_string.i         |
+----------------------+----------------------+----------------------+
| std::unordered_map   | unordered_map        | std_unordered_map.i  |
| (C++11)              |                      |                      |
+----------------------+----------------------+----------------------+
| std                  | unordered_multimap   | std_                 |
| ::unordered_multimap |                      | unordered_multimap.i |
| (C++11)              |                      |                      |
+----------------------+----------------------+----------------------+
| std                  | unordered_multiset   | std_                 |
| ::unordered_multiset |                      | unordered_multiset.i |
| (C++11)              |                      |                      |
+----------------------+----------------------+----------------------+
| std::unordered_set   | unordered_set        | std_unordered_set.i  |
| (C++11)              |                      |                      |
+----------------------+----------------------+----------------------+
| std::vector          | vector               | std_vector.i         |
+----------------------+----------------------+----------------------+
| std::wstring         | wstring              | std_wstring.i        |
+----------------------+----------------------+----------------------+
| std::shared_ptr      | shared_ptr           | std_shared_ptr.i     |
| (C++11)              |                      |                      |
+----------------------+----------------------+----------------------+

The list is by no means complete; some language modules support a subset
of the above and some support additional STL classes. Please look for
the library files in the appropriate language library directory.

std::string
~~~~~~~~~~~~~~~~~~

The ``std_string.i`` library provides typemaps for converting C++
``std::string`` objects to and from strings in the target scripting
language. For example:

.. container:: code

   ::

      %module example
      %include "std_string.i"

      std::string foo();
      void        bar(const std::string &x);

In the target language:

.. container:: targetlang

   ::

      x = foo();                # Returns a string object
      bar("Hello World");       # Pass string as std::string

A common problem that people encounter is that of classes/structures
containing a ``std::string``. This can be overcome by defining a
typemap. For example:

.. container:: code

   ::

      %module example
      %include "std_string.i"

      %apply const std::string& {std::string* foo};

      struct my_struct
      {
        std::string foo;
      };

In the target language:

.. container:: targetlang

   ::

      x = my_struct();
      x.foo = "Hello World";    # assign with string
      print x.foo;              # print as string

This module only supports types ``std::string`` and
``const std::string &``. Pointers and non-const references are left
unmodified and returned as SWIG pointers.

This library file is fully aware of C++ namespaces. If you export
``std::string`` or rename it with a typedef, make sure you include those
declarations in your interface. For example:

.. container:: code

   ::

      %module example
      %include "std_string.i"

      using namespace std;
      typedef std::string String;
      ...
      void foo(string s, const String &t);     // std_string typemaps still applied

std::vector
~~~~~~~~~~~~~~~~~~

The ``std_vector.i`` library provides support for the C++
``std::vector`` class in the STL. Using this library involves the use of
the ``%template`` directive. All you need to do is to instantiate
different versions of ``vector`` for the types that you want to use. For
example:

.. container:: code

   ::

      %module example
      %include "std_vector.i"

      namespace std {
        %template(vectori) vector<int>;
        %template(vectord) vector<double>;
      };

When a template ``vector<X>`` is instantiated a number of things happen:

-  A class that exposes the C++ API is created in the target language .
   This can be used to create objects, invoke methods, etc. This class
   is currently a subset of the real STL vector class.
-  Input typemaps are defined for ``vector<X>``, ``const vector<X> &``,
   and ``const vector<X> *``. For each of these, a pointer
   ``vector<X> *`` may be passed or a native list object in the target
   language.
-  An output typemap is defined for ``vector<X>``. In this case, the
   values in the vector are expanded into a list object in the target
   language.
-  For all other variations of the type, the wrappers expect to receive
   a ``vector<X> *`` object in the usual manner.
-  An exception handler for ``std::out_of_range`` is defined.
-  Optionally, special methods for indexing, item retrieval, slicing,
   and element assignment may be defined. This depends on the target
   language.

To illustrate the use of this library, consider the following functions:

.. container:: code

   ::

      /* File : example.h */

      #include <vector>
      #include <algorithm>
      #include <functional>
      #include <numeric>

      double average(std::vector<int> v) {
        return std::accumulate(v.begin(), v.end(), 0.0)/v.size();
      }

      std::vector<double> half(const std::vector<double>& v) {
        std::vector<double> w(v);
        for (unsigned int i=0; i<w.size(); i++)
          w[i] /= 2.0;
        return w;
      }

      void halve_in_place(std::vector<double>& v) {
        for (std::vector<double>::iterator it = v.begin(); it != v.end(); ++it)
          *it /= 2.0;
      }

To wrap with SWIG, you might write the following:

.. container:: code

   ::

      %module example
      %{
      #include "example.h"
      %}

      %include "std_vector.i"
      // Instantiate templates used by example
      namespace std {
        %template(IntVector) vector<int>;
        %template(DoubleVector) vector<double>;
      }

      // Include the header file with above prototypes
      %include "example.h"

Now, to illustrate the behavior in the scripting interpreter, consider
this Python example:

.. container:: targetlang

   ::

      >>> from example import *
      >>> iv = IntVector(4)         # Create an vector<int>
      >>> for i in range(0, 4):
      ...      iv[i] = i
      >>> average(iv)               # Call method
      1.5
      >>> average([0, 1, 2, 3])        # Call with list
      1.5
      >>> half([1, 2, 3])             # Half a list
      (0.5, 1.0, 1.5)
      >>> halve_in_place([1, 2, 3])   # Oops
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      TypeError: Type error. Expected _p_std__vectorTdouble_t
      >>> dv = DoubleVector(4)
      >>> for i in range(0, 4):
      ...       dv[i] = i
      >>> halve_in_place(dv)       # Ok
      >>> for i in dv:
      ...       print i
      ...
      0.0
      0.5
      1.0
      1.5
      >>> dv[20] = 4.5
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
        File "example.py", line 81, in __setitem__
          def __setitem__(*args): return apply(examplec.DoubleVector___setitem__, args)
      IndexError: vector index out of range
      >>>

This library module is fully aware of C++ namespaces. If you use vectors
with other names, make sure you include the appropriate ``using`` or
typedef directives. For example:

.. container:: code

   ::

      %include "std_vector.i"

      namespace std {
        %template(IntVector) vector<int>;
      }

      using namespace std;
      typedef std::vector Vector;

      void foo(vector<int> *x, const Vector &x);

**Note:** This module makes use of several advanced SWIG features
including templatized typemaps and template partial specialization. If
you are trying to wrap other C++ code with templates, you might look at
the code contained in ``std_vector.i``. Alternatively, you can show them
the code if you want to make their head explode.

**Note:** This module is defined for all SWIG target languages. However
argument conversion details and the public API exposed to the
interpreter vary.

STL exceptions
~~~~~~~~~~~~~~~~~~~~~

Many of the STL wrapper functions add parameter checking and will throw
a language dependent error/exception should the values not be valid. The
classic example is array bounds checking. The library wrappers are
written to throw a C++ exception in the case of error. The C++ exception
in turn gets converted into an appropriate error/exception for the
target language. By and large this handling should not need customising,
however, customisation can easily be achieved by supplying appropriate
"throws" typemaps. For example:

.. container:: code

   ::

      %module example
      %include "std_vector.i"
      %typemap(throws) std::out_of_range {
        // custom exception handler
      }
      %template(VectInt) std::vector<int>;

The custom exception handler might, for example, log the exception then
convert it into a specific error/exception for the target language.

When using the STL it is advisable to add in an exception handler to
catch all STL exceptions. The ``%exception`` directive can be used by
placing the following code before any other methods or libraries to be
wrapped:

.. container:: code

   ::

      %include "exception.i"

      %exception {
        try {
          $action
        } catch (const std::exception& e) {
          SWIG_exception(SWIG_RuntimeError, e.what());
        }
      }

Any thrown STL exceptions will then be gracefully handled instead of
causing a crash.

shared_ptr smart pointer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

shared_ptr basics
^^^^^^^^^^^^^^^^^^^^^^^^^^

Some target languages have support for handling the shared_ptr reference
counted smart pointer. This smart pointer is available in the standard
C++11 library as ``std::shared_ptr``. It was also in TR1 as
``std::tr1::shared_ptr`` before it was fully standardized. Support for
the widely used ``boost::shared_ptr`` is also available.

In order to use ``std::shared_ptr``, the ``std_shared_ptr.i`` library
file should be included:

.. container:: code

   ::

      %include <std_shared_ptr.i>

The pre-standard ``std::tr1::shared_ptr`` can be used by including the
following macro before including the ``std_shared_ptr.i`` library file:

.. container:: code

   ::

      #define SWIG_SHARED_PTR_SUBNAMESPACE tr1
      %include <std_shared_ptr.i>

In order to use ``boost::shared_ptr``, the ``boost_shared_ptr.i``
library file should be included:

.. container:: code

   ::

      %include <boost_shared_ptr.i>

You can only use one of these variants of shared_ptr in your interface
file at a time. and all three variants must be used in conjunction with
the ``%shared_ptr(T)`` macro, where ``T`` is the underlying pointer type
equating to usage ``shared_ptr<T>``. The type ``T`` must be
non-primitive. A simple example demonstrates usage:

.. container:: code

   ::

      %module example
      %include <boost_shared_ptr.i>
      %shared_ptr(IntValue)

      %inline %{
      #include <boost/shared_ptr.hpp>

      struct IntValue {
        int value;
        IntValue(int v) : value(v) {}
      };

      static int extractValue(const IntValue &t) {
        return t.value;
      }

      static int extractValueSmart(boost::shared_ptr<IntValue> t) {
        return t->value;
      }
      %}

Note that the ``%shared_ptr(IntValue)`` declaration occurs after the
inclusion of the ``boost_shared_ptr.i`` library which provides the macro
and, very importantly, before any usage or declaration of the type,
``IntValue``. The ``%shared_ptr`` macro provides, a few things for
handling this smart pointer, but mostly a number of typemaps. These
typemaps override the default typemaps so that the underlying proxy
class is stored and passed around as a pointer to a ``shared_ptr``
instead of a plain pointer to the underlying type. This approach means
that any instantiation of the type can be passed to methods taking the
type by value, reference, pointer or as a smart pointer. The interested
reader might want to look at the generated code, however, usage is
simple and no different handling is required from the target language.
For example, a simple use case of the above code from Java would be:

.. container:: targetlang

   ::

      IntValue iv = new IntValue(1234);
      int val1 = example.extractValue(iv);
      int val2 = example.extractValueSmart(iv);
      System.out.println(val1 + " " + val2);

shared_ptr and inheritance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The shared_ptr library works quite differently to SWIG's normal, but
somewhat limited, `smart pointer
handling <SWIGPlus.html#SWIGPlus_smart_pointers>`__. The shared_ptr
library does not generate extra wrappers, just for smart pointer
handling, in addition to the proxy class. The normal proxy class
including inheritance relationships is generated as usual. The only real
change introduced by the ``%shared_ptr`` macro is that the proxy class
stores a pointer to the shared_ptr instance instead of a raw pointer to
the instance. A proxy class derived from a base which is being wrapped
with shared_ptr can and **must** be wrapped as a shared_ptr too. In
other words all classes in an inheritance hierarchy must all be used
with the ``%shared_ptr`` macro. For example the following code can be
used with the base class shown earlier:

.. container:: code

   ::

      %shared_ptr(DerivedIntValue)
      %inline %{
      struct DerivedIntValue : IntValue {
        DerivedIntValue(int value) : IntValue(value) {}
        ...
      };
      %}

A shared_ptr of the derived class can now be passed to a method where
the base is expected in the target language, just as it can in C++:

.. container:: targetlang

   ::

      DerivedIntValue div = new DerivedIntValue(5678);
      int val3 = example.extractValue(div);
      int val4 = example.extractValueSmart(div);

If the ``%shared_ptr`` macro is omitted for any class in the inheritance
hierarchy, SWIG will warn about this and the generated code may or may
not result in a C++ compilation error. For example, the following input:

.. container:: code

   ::

      %include "boost_shared_ptr.i"
      %shared_ptr(Parent);

      %inline %{
        #include <boost/shared_ptr.hpp>
        struct GrandParent {
          virtual ~GrandParent() {}
        };

        struct Parent : GrandParent {
          virtual ~Parent() {}
        };

        struct Child : Parent {
          virtual ~Child() {}
        };
      %}

warns about the missing smart pointer information:

.. container:: shell

   ::

      example.i:12: Warning 520: Base class 'GrandParent' of 'Parent' is not similarly marked as a smart pointer.
      example.i:16: Warning 520: Derived class 'Child' of 'Parent' is not similarly marked as a smart pointer.

Adding the missing ``%shared_ptr`` macros will fix this:

.. container:: code

   ::

      %include <boost_shared_ptr.i>
      %shared_ptr(GrandParent);
      %shared_ptr(Parent);
      %shared_ptr(Child);

      ... as before ...

shared_ptr and method overloading
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A C++ compiler can disambiguate a method overloaded by a shared_ptr and
one using the raw underlying type. For example, either one of these
methods can be called in C++:

.. container:: code

   ::

      int age(std::shared_ptr<GrandParent> num);
      int age(GrandParent& num);

When wrapped by SWIG, disambiguation is not possible using the
overloaded names as there is just one equivalent type (``GrandParent``)
in the target language. SWIG will choose to wrap just the first method
by default. `Ambiguity in overloading <SWIGPlus.html#SWIGPlus_nn25>`__
discusses ways to control which method(s) gets wrapped using ``%ignore``
or ``%rename``. For the interested reader, SWIG detects that they are
equivalent types via the `typecheck
typemaps <Typemaps.html#Typemaps_typecheck_pointer>`__ in the shared_ptr
library.

shared_ptr and templates
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``%shared_ptr`` macro should be used for all the required
instantiations of the template before each of the ``%template``
instantiations. For example, consider ``number.h`` containing the
following illustrative template:

.. container:: code

   ::

      #include <memory>

      template<int N> struct Number {
        int num;
        Number() : num(N) {}
        static std::shared_ptr<Number<N>> make() { return std::make_shared<Number<N>>(); }
      };

The SWIG code below shows the required ordering:

.. container:: code

   ::

      %include <std_shared_ptr.i>

      %shared_ptr(Number<10>);
      %shared_ptr(Number<42>);

      %{
        #include "number.h"
      %}
      %include "number.h"

      %template(Number10) Number<10>;
      %template(Number42) Number<42>;

shared_ptr and directors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The languages that support shared_ptr also have support for using
shared_ptr with directors.

auto_ptr smart pointer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While ``std::auto_ptr`` is deprecated in C++11, some existing code may
still be using it, so SWIG provides limited support for this class:
``std_auto_ptr.i`` defines the typemaps which apply to the functions
returning objects of this type. Any other use of ``std_auto_ptr.i`` is
not directly supported.

A typical example of use would be

.. container:: code

   ::

      %include <std_auto_ptr.i>

      %auto_ptr(Klass)
      %inline %{
      class Klass {
      public:
        // Factory function creating objects of this class:
        static std::auto_ptr<Klass> Create(int value) {
          return std::auto_ptr<Klass>(new Klass(value));
        }

        int getValue() const { return m_value; }

      private:
        DerivedIntValue(int value) : m_value(value) {}
        int m_value;
      };
      %}

The returned objects can be used naturally from the target language,
e.g. from C#:

.. container:: targetlang

   ::

      Klass k = Klass.Create(17);
      int value = k.getValue();

Utility Libraries
----------------------

exception.i
~~~~~~~~~~~~~~~~~~

The ``exception.i`` library provides a language-independent function for
raising a run-time exception in the target language. This library is
largely used by the SWIG library writers. If possible, use the error
handling scheme available to your target language as there is greater
flexibility in what errors/exceptions can be thrown.

**``SWIG_exception(int code, const char *message)``**

.. container:: indent

   Raises an exception in the target language. ``code`` is one of the
   following symbolic constants:

   .. container:: code

      ::

         SWIG_MemoryError
         SWIG_IOError
         SWIG_RuntimeError
         SWIG_IndexError
         SWIG_TypeError
         SWIG_DivisionByZero
         SWIG_OverflowError
         SWIG_SyntaxError
         SWIG_ValueError
         SWIG_SystemError

   ``message`` is a string indicating more information about the
   problem.

The primary use of this module is in writing language-independent
exception handlers. For example:

.. container:: code

   ::

      %include "exception.i"
      %exception std::vector::getitem {
        try {
          $action
        } catch (std::out_of_range& e) {
          SWIG_exception(SWIG_IndexError, const_cast<char*>(e.what()));
        }
      }

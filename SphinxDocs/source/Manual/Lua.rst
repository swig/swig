SWIG and Lua
===============

Lua is an extension programming language designed to support general
procedural programming with data description facilities. It also offers
good support for object-oriented programming, functional programming,
and data-driven programming. Lua is intended to be used as a powerful,
light-weight configuration language for any program that needs one. Lua
is implemented as a library, written in clean C (that is, in the common
subset of ISO C and C++). It's also a *really* tiny language, less than
lines of code, which compiles to <100 kilobytes of binary code. It
can be found at http://www.lua.org

eLua stands for Embedded Lua (can be thought of as a flavor of Lua) and
offers the full implementation of the Lua programming language to the
embedded world, extending it with specific features for efficient and
portable software embedded development. eLua runs on smaller devices
like microcontrollers and provides the full features of the regular Lua
desktop version. More information on eLua can be found here:
http://www.eluaproject.net

Preliminaries
------------------

The current SWIG implementation is designed to work with Lua 5.0.x,
5.1.x and 5.2.x. It should work with later versions of Lua, but
certainly not with Lua 4.0 due to substantial API changes. It is
possible to either static link or dynamic link a Lua module into the
interpreter (normally Lua static links its libraries, as dynamic linking
is not available on all platforms). SWIG also has support for eLua
starting from eLua 0.8. Due to substantial changes between SWIG 2.x and
SWIG 3.0 and unavailability of testing platform, eLua status was
downgraded to 'experimental'.

Running SWIG
-----------------

Suppose that you defined a SWIG module such as the following:

.. container:: code

   ::

      %module example
      %{
      #include "example.h"
      %}
      int gcd(int x, int y);
      extern double Foo;

To build a Lua module, run SWIG using the ``-lua`` option.

.. container:: shell

   ::

      $ swig -lua example.i

If building a C++ extension, add the ``-c++`` option:

.. container:: shell

   ::

      $ swig -c++ -lua example.i

This creates a C/C++ source file ``example_wrap.c`` or
``example_wrap.cxx``. The generated C source file contains the low-level
wrappers that need to be compiled and linked with the rest of your C/C++
application to create an extension module.

The name of the wrapper file is derived from the name of the input file.
For example, if the input file is ``example.i``, the name of the wrapper
file is ``example_wrap.c``. To change this, you can use the -o option.
The wrapped module will export one function
``"int luaopen_example(lua_State* L)"`` which must be called to register
the module with the Lua interpreter. The name "luaopen_example" depends
upon the name of the module.

To build an eLua module, run SWIG using ``-lua`` and add either
``-elua`` or ``-eluac``.

.. container:: shell

   ::

      $ swig -lua -elua example.i

or

.. container:: shell

   ::

      $ swig -lua -eluac example.i

The ``-elua`` option puts all the C function wrappers and variable
get/set wrappers in rotables. It also generates a metatable which will
control the access to these variables from eLua. It also offers a
significant amount of module size compression. On the other hand, the
``-eluac`` option puts all the wrappers in a single rotable. With this
option, no matter how huge the module, it will consume no additional
microcontroller SRAM (crass compression). There is a catch though:
Metatables are not generated with ``-eluac``. To access any value from
eLua, one must directly call the wrapper function associated with that
value.

Additional command line options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following table list the additional commandline options available
for the Lua module. They can also be seen by using:

.. container:: shell

   ::

      swig -lua -help 

+----------------------------+
| Lua specific options       |
+============================+
| -elua                      |
+----------------------------+
| -eluac                     |
+----------------------------+
| -nomoduleglobal            |
+----------------------------+
| -no-old-metatable-bindings |
+----------------------------+
| -squash-bases              |
+----------------------------+

Compiling and Linking and Interpreter
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Normally Lua is embedded into another program and will be statically
linked. An extremely simple stand-alone interpreter (``min.c``) is given
below:

.. container:: code

   ::

      #include <stdio.h>
      #include "lua.h"
      #include "lualib.h"
      #include "lauxlib.h"

      extern int luaopen_example(lua_State* L); // declare the wrapped module

      int main(int argc, char* argv[])
      {
       lua_State *L;
       if (argc<2)
       {
        printf("%s: <filename.lua>\n", argv[0]);
        return 0;
       }
       L=lua_open();
       luaopen_base(L);       // load basic libs (eg. print)
       luaopen_example(L);    // load the wrapped module
       if (luaL_loadfile(L, argv[1])==0) // load and run the file
        lua_pcall(L, 0, 0, 0);
       else
        printf("unable to load %s\n", argv[1]);
       lua_close(L);
       return 0;
      }

A much improved set of code can be found in the Lua distribution
``src/lua/lua.c``. Include your module, just add the external
declaration & add a
``#define LUA_EXTRALIBS {"example", luaopen_example}``, at the relevant
place.

The exact commands for compiling and linking vary from platform to
platform. Here is a possible set of commands of doing this:

.. container:: shell

   ::

      $ swig -lua example.i -o example_wrap.c
      $ gcc -I/usr/include/lua -c min.c -o min.o
      $ gcc -I/usr/include/lua -c example_wrap.c -o example_wrap.o
      $ gcc -c example.c -o example.o
      $ gcc -I/usr/include/lua -L/usr/lib/lua min.o example_wrap.o example.o -o my_lua

For eLua, the source must be built along with the wrappers generated by
SWIG. Make sure the eLua source files ``platform_conf.h`` and
``auxmods.h`` are updated with the entries of your new module. Please
note: ``"mod"`` is the module name.

.. container:: code

   ::

      /* Sample platform_conf.h */
      #define LUA_PLATFORM_LIBS_ROM\
        _ROM( AUXLIB_PIO, luaopen_pio, pio_map )\
        _ROM( AUXLIB_TMR, luaopen_tmr, tmr_map )\
        _ROM( AUXLIB_MOD, luaopen_mod, mod_map )\
        ....

.. container:: code

   ::

      /* Sample auxmods.h */
      #define AUXLIB_PIO       "pio"
      LUALIB_API int ( luaopen_pio )(lua_State *L );

      #define AUXLIB_MOD       "mod"
      LUALIB_API int ( luaopen_mod )(lua_State *L );
      ....

More information on building and configuring eLua can be found here:
http://www.eluaproject.net/doc/v0.8/en_building.html

Compiling a dynamic module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Most, but not all platforms support the dynamic loading of modules
(Windows & Linux do). Refer to the Lua manual to determine if your
platform supports it. For compiling a dynamically loaded module the same
wrapper can be used. Assuming you have code you need to link to in a
file called ``example.c``, the commands will be something like this:

.. container:: shell

   ::

      $ swig -lua example.i -o example_wrap.c
      $ gcc -fPIC -I/usr/include/lua -c example_wrap.c -o example_wrap.o
      $ gcc -fPIC -c example.c -o example.o
      $ gcc -shared -I/usr/include/lua -L/usr/lib/lua example_wrap.o example.o -o example.so

The wrappers produced by SWIG can be compiled and linked with Lua 5.1.x
and later. The loading is extremely simple.

.. container:: targetlang

   ::

      require("example")

For those using Lua 5.0.x, you will also need an interpreter with the
loadlib function (such as the default interpreter compiled with Lua). In
order to dynamically load a module you must call the loadlib function
with two parameters: the filename of the shared library, and the
function exported by SWIG. Calling loadlib should return the function,
which you then call to initialise the module

.. container:: targetlang

   ::

      my_init=loadlib("example.so", "luaopen_example") -- for Unix/Linux
      --my_init=loadlib("example.dll", "luaopen_example") -- for Windows
      assert(my_init) -- make sure it's not nil
      my_init()       -- call the init fn of the lib

Or can be done in a single line of Lua code

.. container:: targetlang

   ::

      assert(loadlib("example.so", "luaopen_example"))()

If the code didn't work, don't panic. The best thing to do is to copy
the module and your interpreter into a single directory and then execute
the interpreter and try to manually load the module (take care, all this
code is case sensitive).

.. container:: targetlang

   ::

      a, b, c=package.loadlib("example.so", "luaopen_example") -- for Unix/Linux
      --a, b, c=package.loadlib("example.dll", "luaopen_example") -- for Windows
      print(a, b, c)

| Note: for Lua 5.0:
| The loadlib() function is in the global namespace, not in a package.
  So it's just loadlib().

if 'a' is a function, this is all working fine, all you need to do is
call it

.. container:: targetlang

   ::

        a()

to load your library which will add a table 'example' with all the
functions added.

| If it doesn't work, look at the error messages, in particular message
  'b'
| ``The specified module could not be found.``
| Means that is cannot find the module, check your the location and
  spelling of the module.
| ``The specified procedure could not be found.``
| Means that it loaded the module, but cannot find the named function.
  Again check the spelling, and if possible check to make sure the
  functions were exported correctly.
| ``'loadlib' not installed/supported``
| Is quite obvious (Go back and consult the Lua documents on how to
  enable loadlib for your platform).

Using your module
~~~~~~~~~~~~~~~~~~~~~~~~

Assuming all goes well, you will be able to this:

.. container:: targetlang

   ::

      $ ./my_lua
      > print(example.gcd(4, 6))
      2
      > print(example.Foo)
      3
      > example.Foo=4
      > print(example.Foo)
      4
      >

A tour of basic C/C++ wrapping
-----------------------------------

By default, SWIG tries to build a very natural Lua interface to your
C/C++ code. This section briefly covers the essential aspects of this
wrapping.

Modules
~~~~~~~~~~~~~~

The SWIG module directive specifies the name of the Lua module. If you
specify \`module example', then everything is wrapped into a Lua table
'example' containing all the functions and variables. When choosing a
module name, make sure you don't use the same name as a built-in Lua
command or standard module name.

Functions
~~~~~~~~~~~~~~~~

Global functions are wrapped as new Lua built-in functions. For example,

.. container:: code

   ::

      %module example
      int fact(int n);

creates a built-in function ``example.fact(n)`` that works exactly like
you think it does:

.. container:: targetlang

   ::

      > print example.fact(4)
      24
      >

To avoid name collisions, SWIG create a Lua table which keeps all the
functions, constants, classes and global variables in. It is possible to
copy the functions, constants and classes (but not variables) out of
this and into the global environment with the following code. This can
easily overwrite existing functions, so this must be used with care.
This option is considered deprecated and will be removed in the near
future.

.. container:: targetlang

   ::

      > for k, v in pairs(example) do _G[k]=v end
      > print(fact(4))
      24
      >

It is also possible to rename the module with an assignment.

.. container:: targetlang

   ::

      > e=example
      > print(e.fact(4))
      24
      > print(example.fact(4))
      24

Global variables
~~~~~~~~~~~~~~~~~~~~~~~

Global variables (which are linked to C code) are supported, and appear
to be just another variable in Lua. However the actual mechanism is more
complex. Given a global variable:

.. container:: code

   ::

      %module example
      extern double Foo;

SWIG will effectively generate two functions ``example.Foo_set()`` and
``example.Foo_get()``. It then adds a metatable to the table 'example'
to call these functions at the correct time (when you attempt to set or
get examples.Foo). Therefore if you were to attempt to assign the global
to another variable, you will get a local copy within the interpreter,
which is no longer linked to the C code.

.. container:: targetlang

   ::

      > print(example.Foo)
      3
      > c=example.Foo   -- c is a COPY of example.Foo, not the same thing
      > example.Foo=4
      > print(c)
      3
      > c=5 -- this will not effect the original example.Foo
      > print(example.Foo, c)
      4    5

It is therefore not possible to 'move' the global variable into the
global namespace as it is with functions. It is however, possible to
rename the module with an assignment, to make it more convenient.

.. container:: targetlang

   ::

      > e=example
      > -- e and example are the same table
      > -- so e.Foo and example.Foo are the same thing
      > example.Foo=4
      > print(e.Foo)
      4

If a variable is marked with the %immutable directive then any attempts
to set this variable will cause a Lua error. Given a global variable:

.. container:: code

   ::

      %module example
      %immutable;
      extern double Foo;
      %mutable;

SWIG will allow the reading of ``Foo`` but when a set attempt is made,
an error function will be called.

.. container:: targetlang

   ::

      > print(e.Foo) -- reading works ok
      4
      > example.Foo=40 -- but writing does not
      This variable is immutable
      stack traceback:
              [C]: ?
              [C]: ?
              stdin:1: in main chunk
              [C]: ?

For those people who would rather that SWIG silently ignore the setting
of immutables (as previous versions of the Lua bindings did), adding a
``-DSWIGLUA_IGNORE_SET_IMMUTABLE`` compile option will remove this.

Unlike earlier versions of the binding, it is now possible to add new
functions or variables to the module, just as if it were a normal table.
This also allows the user to rename/remove existing functions and
constants (but not linked variables, mutable or immutable). Therefore
users are recommended to be careful when doing so.

.. container:: targetlang

   ::

      > -- example.PI does not exist
      > print(example.PI)
      nil
      > example.PI=3.142 -- new value added
      > print(example.PI)
      3.142

If you have used the ``-eluac`` option for your eLua module, you will
have to follow a different approach while manipulating global variables.
(This is not applicable for wrappers generated with ``-elua``)

.. container:: targetlang

   ::

      > -- Applicable only with -eluac. (num is defined)
      > print(example.num_get())
      20
      > example.num_set(50) -- new value added
      > print(example.num_get())
      50

In general, functions of the form ``"variable_get()"`` and
``"variable_set()"`` are automatically generated by SWIG for use with
``-eluac``.

Constants and enums
~~~~~~~~~~~~~~~~~~~~~~~~~~

Because Lua doesn't really have the concept of constants, C/C++
constants are not really constant in Lua. They are actually just a copy
of the value into the Lua interpreter. Therefore they can be changed
just as any other value. For example given some constants:

.. container:: code

   ::

      %module example
      %constant int ICONST=42;
      #define    SCONST      "Hello World"
      enum Days{SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY};

This is 'effectively' converted into the following Lua code:

.. container:: targetlang

   ::

      example.ICONST=42
      example.SCONST="Hello World"
      example.SUNDAY=0
      ....

Constants are not guaranteed to remain constant in Lua. The name of the
constant could be accidentally reassigned to refer to some other object.
Unfortunately, there is no easy way for SWIG to generate code that
prevents this. You will just have to be careful.

If you're using eLua and have used ``-elua`` or ``-eluac`` to generate
your wrapper, macro constants and enums should be accessed through a
rotable called ``"const"``. In eLua, macro constants and enums are
guaranteed to remain constants since they are all contained within a
rotable. A regular C constant is accessed from eLua just as if it were a
regular global variable, just that the property of value immutability is
demonstrated if an attempt at modifying a C constant is made.

.. container:: targetlang

   ::

      > print(example.ICONST)
      10
      > print(example.const.SUNDAY)
      0
      > print(example.const.SCONST)
      Hello World

Constants/enums and classes/structures
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Enums are exported into a class table. For example, given some enums:

.. container:: code

   ::

      %module example
      enum Days { SUNDAY = 0, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY };
      struct Test {
        enum { TEST1 = 10, TEST2 = 20 };
      #ifdef __cplusplus // There are no static members in C
        static const int ICONST = 12;
      #endif
      };

There is a slight difference in behaviour wrapping C and C++ code due to
the different scoping rules of C and C++. The wrapped C++ code is used
as follows from Lua code:

.. container:: targetlang

   ::

      > print(example.SUNDAY)
      0
      > print(example.Test.TEST1)
      10
      > print(example.Test.ICONST)
      12

Enums within a C struct are in the global namespace and are used as
follows from Lua

.. container:: targetlang

   ::

      > print(example.SUNDAY)
      0
      > -- See the difference here
      > print(example.TEST1)
      10

**Compatibility Note:** Versions of SWIG prior to SWIG-3.0.0 did not
generate the class table members above. There is no change in the C
wrappers, but the following code was the only way to access these
constants/enums when wrapping C++ member constants:

.. container:: targetlang

   ::

      > print(example.Test_TEST1)
      10
      > print(example.Test_ICONST)
      12

The old-style bindings are still generated in addition to the new ones.
If the ``-no-old-metatable-bindings`` option is used, then these
old-style bindings are not generated.

It is worth mentioning, that ``example.Test.TEST1`` and
``example.Test_TEST1`` are different entities and changing one does not
change the other. Given the fact that these are constantes and they are
not supposed to be changed, it is up to you to avoid such issues.

Pointers
~~~~~~~~~~~~~~~

C/C++ pointers are fully supported by SWIG. Furthermore, SWIG has no
problem working with incomplete type information. Given a wrapping of
the <file.h> interface:

.. container:: code

   ::

      %module example

      FILE *fopen(const char *filename, const char *mode);
      int fputs(const char *, FILE *);
      int fclose(FILE *);

When wrapped, you will be able to use the functions in a natural way
from Lua. For example:

.. container:: targetlang

   ::

      > f=example.fopen("junk", "w")
      > example.fputs("Hello World", f)
      > example.fclose(f)

Unlike many scripting languages, Lua has had support for pointers to
C/C++ object built in for a long time. They are called 'userdata'.
Unlike many other SWIG versions which use some kind of encoded character
string, all objects will be represented as a userdata. The SWIG-Lua
bindings provides a special function ``swig_type()``, which if given a
userdata object will return the type of object pointed to as a string
(assuming it was a SWIG wrapped object).

.. container:: targetlang

   ::

      > print(f)
      userdata: 003FDA80
      > print(swig_type(f))
      FILE * -- it's a FILE*

Lua enforces the integrity of its userdata, so it is virtually
impossible to corrupt the data. But as the user of the pointer, you are
responsible for freeing it, or closing any resources associated with it
(just as you would in a C program). This does not apply so strictly to
classes & structs (see below). One final note: if a function returns a
NULL pointer, this is not encoded as a userdata, but as a Lua nil.

.. container:: targetlang

   ::

      > f=example.fopen("not there", "r") -- this will return a NULL in C
      > print(f)
      nil

Structures
~~~~~~~~~~~~~~~~~

If you wrap a C structure, it is also mapped to a Lua userdata. By
adding a metatable to the userdata, this provides a very natural
interface. For example,

.. container:: code

   ::

      struct Point{
        int x, y;
      };

is used as follows:

.. container:: targetlang

   ::

      > p=example.new_Point()
      > p.x=3
      > p.y=5
      > print(p.x, p.y)
      3       5
      >

| Similar access is provided for unions and the data members of C++
  classes.
| C structures can be created using a function ``new_Point()``, and both
  C structures and C++ classes can be created using just the name
  ``Point()``.

If you print out the value of p in the above example, you will see
something like this:

.. container:: targetlang

   ::

      > print(p)
      userdata: 003FA320

Like the pointer in the previous section, this is held as a userdata.
However, additional features have been added to make this more usable.
SWIG effectively creates some accessor/mutator functions to get and set
the data. These functions will be added to the userdata's metatable.
This provides the natural access to the member variables that were shown
above (see end of the document for full details).

``const`` members of a structure are read-only. Data members can also be
forced to be read-only using the immutable directive. As with other
immutables, setting attempts will be cause an error. For example:

.. container:: code

   ::

      struct Foo {
        ...
        %immutable;
        int x;        // Read-only members
        char *name;
        %mutable;
        ...
      };

The mechanism for managing char\* members as well as array members is
similar to other languages. It is somewhat cumbersome and should
probably be better handled by defining of typemaps (described later).

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

Now, suppose that you access the f attribute of Bar like this:

.. container:: targetlang

   ::

      > b = Bar()
      > x = b.f

In this case, x is a pointer that points to the Foo that is inside b.
This is the same value as generated by this C code:

.. container:: code

   ::

      Bar b;
      Foo *x = &b->f;       // Points inside b

Because the pointer points inside the structure, you can modify the
contents and everything works just like you would expect. For example:

.. container:: targetlang

   ::

      > b = Bar()
      > b.f.a = 3               -- Modify attribute of structure member
      > x = b.f
      > x.a = 3                 -- Modifies the same structure

For eLua with the ``-eluac`` option, structure manipulation has to be
performed with specific structure functions generated by SWIG. Let's say
you have the following structure definition:

.. container:: code

   ::

      struct data {
        int x, y;
        double z;
      };

      > --From eLua
      > a = example.new_data()
      > example.data_x_set(a, 10)
      > example.data_y_set(a, 20)
      > print(example.data_x_get(a), example.data_y_get(a))
      10 20

In general, functions of the form ``"new_struct()"``,
``"struct_member_get()"``, ``"struct_member_set()"`` and
``"free_struct()"`` are automatically generated by SWIG for each
structure defined in C. (Please note: This doesn't apply for modules
generated with the ``-elua`` option)

C++ classes
~~~~~~~~~~~~~~~~~~

C++ classes are wrapped by a Lua userdata as well. For example, if you
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

you can use it in Lua like this:

.. container:: targetlang

   ::

      > l = example.List()
      > l:insert("Ale")
      > l:insert("Stout")
      > l:insert("Lager")
      > print(l:get(1))
      Stout
      > print(l:length)
      3
      >

(Note: for calling methods of a class, you use ``class:method(args)``,
not ``class.method(args)``, it's an easy mistake to make. However for
data attributes it is ``class.attribute``)

Class data members are accessed in the same manner as C structures.
Static class members present a special problem for Lua, as Lua doesn't
have support for such features. Therefore, SWIG generates wrappers that
try to work around some of these issues. To illustrate, suppose you have
a class like this:

.. container:: code

   ::

      class Spam {
      public:
        static void foo();
        static int bar;
      };

In Lua, C++ static members can be accessed as follows:

.. container:: targetlang

   ::

      > example.Spam.foo()            -- calling Spam::foo()
      > a=example.Spam.bar            -- reading Spam::bar 
      > example.Spam.bar=b            -- writing to Spam::bar

It is not (currently) possible to access static members of an instance:

.. container:: targetlang

   ::

      > s=example.Spam()              -- s is a Spam instance
      > s.foo()                       -- Spam::foo() via an instance
                                      -- does NOT work

**Compatibility Note:** In versions prior to SWIG-3.0.0 only the
following names would work:

.. container:: targetlang

   ::

      > example.Spam_foo()            -- calling Spam::foo()
      > a=example.Spam_bar            -- reading Spam::bar 
      > example.Spam_bar=b            -- writing to Spam::bar

Both style names are generated by default now. However, if the
``-no-old-metatable-bindings`` option is used, then the backward
compatible names are not generated in addition to ordinary ones.

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

And if you have functions like this

.. container:: code

   ::

      void spam(Foo *f);

then the function ``spam()`` accepts a Foo pointer or a pointer to any
class derived from Foo.

It is safe to use multiple inheritance with SWIG.

Pointers, references, values, and arrays
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In C++, there are many different ways a function might receive and
manipulate objects. For example:

.. container:: code

   ::

      void spam1(Foo *x);      // Pass by pointer
      void spam2(Foo &x);      // Pass by reference
      void spam3(Foo x);       // Pass by value
      void spam4(Foo x[]);     // Array of objects

In SWIG, there is no detailed distinction like this--specifically, there
are only "objects". There are no pointers, references, arrays, and so
forth. Because of this, SWIG unifies all of these types together in the
wrapper code. For instance, if you actually had the above functions, it
is perfectly legal to do this:

.. container:: targetlang

   ::

      > f = Foo()           -- Create a Foo
      > spam1(f)            -- Ok. Pointer
      > spam2(f)            -- Ok. Reference
      > spam3(f)            -- Ok. Value.
      > spam4(f)            -- Ok. Array (1 element)

Similar behaviour occurs for return values. For example, if you had
functions like this,

.. container:: code

   ::

      Foo *spam5();
      Foo &spam6();
      Foo  spam7();

then all three functions will return a pointer to some Foo object. Since
the third function (spam7) returns a value, newly allocated memory is
used to hold the result and a pointer is returned (Lua will release this
memory when the return value is garbage collected). The other two are
pointers which are assumed to be managed by the C code and so will not
be garbage collected.

C++ overloaded functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C++ overloaded functions, methods, and constructors are mostly supported
by SWIG. For example, if you have two functions like this:

.. container:: code

   ::

      void foo(int);
      void foo(char *c);

You can use them in Lua in a straightforward manner:

.. container:: targetlang

   ::

      > foo(3)           -- foo(int)
      > foo("Hello")     -- foo(char *c)

However due to Lua's coercion mechanism is can sometimes do strange
things.

.. container:: targetlang

   ::

      > foo("3")           -- "3" can be coerced into an int, so it calls foo(int)!

As this coercion mechanism is an integral part of Lua, there is no easy
way to get around this other than renaming of functions (see below).

Similarly, if you have a class like this,

.. container:: code

   ::

      class Foo {
      public:
        Foo();
        Foo(const Foo &);
        ...
      };

you can write Lua code like this:

.. container:: targetlang

   ::

      > f = Foo()          -- Create a Foo
      > g = Foo(f)         -- Copy f

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

Dealing with the Lua coercion mechanism, the priority is roughly
(integers, floats, strings, userdata). But it is better to rename the
functions rather than rely upon the ordering.

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

      > c = Complex(3, 4)
      > d = Complex(7, 8)
      > e = c + d
      > e:re()
      10.0
      > e:im()
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

then SWIG doesn't know what to do with the friend function--in fact, it
simply ignores it and issues a warning. You can still wrap the operator,
but you may have to encapsulate it in a special function. For example:

.. container:: code

   ::

      %rename(Complex_add_dc) operator+(double, const Complex &);
      ...
      Complex operator+(double, const Complex &c);

There are ways to make this operator appear as part of the class using
the ``%extend`` directive. Keep reading.

Also, be aware that certain operators don't map cleanly to Lua, and some
Lua operators don't map cleanly to C++ operators. For instance,
overloaded assignment operators don't map to Lua semantics and will be
ignored, and C++ doesn't support Lua's concatenation operator (``..``).

In order to keep maximum compatibility within the different languages in
SWIG, the Lua bindings uses the same set of operator names as Python.
Although internally it renames the functions to something else (on order
to work with Lua).

The current list of operators which can be overloaded (and the
alternative function names) are:

-  ``__add__`` operator+
-  ``__sub__`` operator-
-  ``__mul__`` operator \*
-  ``__div__`` operator/
-  ``__unm__`` unary minus
-  ``__call__`` operator\ ``()`` (often used in functor classes)
-  ``__pow__`` the exponential fn (no C++ equivalent, Lua uses ``^``)
-  ``__concat__`` the concatenation operator (Lua's ``..``)
-  ``__eq__`` operator\ ``==``
-  ``__lt__`` operator\ ``<``
-  ``__le__`` operator\ ``<=``

Note: in Lua, only the equals, less than, and less than equals operators
are defined. The other operators (!=, >, >=) are achieved by using a
logical not applied to the results of other operators.

The following operators cannot be overloaded (mainly because they are
not supported in Lua)

-  ++ and --
-  +=, -=, \*= etc
-  % operator (you have to use math.mod)
-  assignment operator
-  all bitwise/logical operations

SWIG also accepts the ``__str__()`` member function which converts an
object to a string. This function should return a const char*,
preferably to static memory. This will be used for the ``print()`` and
``tostring()`` functions in Lua. Assuming the complex class has a
function

.. container:: code

   ::

      const char* __str__() {
        static char buffer[255];
        sprintf(buffer, "Complex(%g, %g)", this->re(), this->im());
        return buffer;
      }

Then this will support the following code in Lua

.. container:: targetlang

   ::

      > c = Complex(3, 4)
      > d = Complex(7, 8)
      > e = c + d
      > print(e)
      Complex(10, 12)
      > s=tostring(e) -- s is the number in string form
      > print(s)
      Complex(10, 12)

It is also possible to overload the operator\ ``[]``, but currently this
cannot be automatically performed. To overload the operator\ ``[]`` you
need to provide two functions, ``__getitem__()`` and ``__setitem__()``

.. container:: code

   ::

      class Complex {
        //....
        double __getitem__(int i)const; // i is the index, returns the data
        void __setitem__(int i, double d); // i is the index, d is the data
      };

C++ operators are mapped to Lua predefined metafunctions. Class inherits
from its bases the following list of metafunctions ( thus inheriting the
folloging operators and pseudo-operators):

-  ``__add__``
-  ``__sub__``
-  ``__mul__``
-  ``__div__``
-  ``__unm__``
-  ``__mod__``
-  ``__call__``
-  ``__pow__``
-  ``__concat__``
-  ``__eq__``
-  ``__lt__``
-  ``__le__``
-  ``__len__``
-  ``__getitem__``
-  ``__setitem__``
-  ``__tostring`` used internally by Lua for tostring() function.
   \__str_\_ is mapped to this function

No other lua metafunction is inherited. For example, \__gc is not
inherited and must be redefined in every class. ``__tostring`` is
subject to a special handling. If absent in class and in class bases, a
default one will be provided by SWIG.

Class extension with %extend
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

One of the more interesting features of SWIG is that it can extend
structures and classes with new methods. In the previous section, the
Complex class would have benefited greatly from an \__str__() method as
well as some repairs to the operator overloading. It can also be used to
add additional functions to the class if they are needed.

Take the original Complex class

.. container:: code

   ::

      class Complex {
      private:
        double rpart, ipart;
      public:
        Complex(double r = 0, double i = 0) : rpart(r), ipart(i) { }
        Complex(const Complex &c) : rpart(c.rpart), ipart(c.ipart) { }
        Complex &operator=(const Complex &c);
        Complex operator+(const Complex &c) const;
        Complex operator-(const Complex &c) const;
        Complex operator*(const Complex &c) const;
        Complex operator-() const;

        double re() const { return rpart; }
        double im() const { return ipart; }
      };

Now we extend it with some new code

.. container:: code

   ::

      %extend Complex {
        const char *__str__() {
          static char tmp[1024];
          sprintf(tmp, "Complex(%g, %g)", $self->re(), $self->im());
          return tmp;
        }
        bool operator==(const Complex& c) {
          return ($self->re()==c.re() && $self->im()==c.im());
        }
      };

Now, in Lua

.. container:: targetlang

   ::

      > c = Complex(3, 4)
      > d = Complex(7, 8)
      > e = c + d
      > print(e)      -- print uses __str__ to get the string form to print
      Complex(10, 12)
      > print(e==Complex(10, 12))  -- testing the == operator
      true
      > print(e!=Complex(12, 12))  -- the != uses the == operator
      true

Extend works with both C and C++ code, on classes and structs. It does
not modify the underlying object in any way---the extensions only show
up in the Lua interface. The only item to take note of is the code has
to use the '$self' instead of 'this', and that you cannot access
protected/private members of the code (as you are not officially part of
the class).

Using %newobject to release memory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

To fix the memory leak, use the `%newobject
directive <Customization.html#Customization_ownership>`__.

.. container:: code

   ::

      %newobject foo;
      ...
      char *foo();

This will release the allocated memory.

C++ templates
~~~~~~~~~~~~~~~~~~~~~

C++ templates don't present a huge problem for SWIG. However, in order
to create wrappers, you have to tell SWIG to create wrappers for a
particular template instantiation. To do this, you use the template
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

In Lua:

.. container:: targetlang

   ::

      > p = example.pairii(3, 4)
      > print(p.first, p.second)
      3    4

Obviously, there is more to template wrapping than shown in this
example. More details can be found in the SWIG and C++ chapter. Some
more complicated examples will appear later.

C++ Smart Pointers
~~~~~~~~~~~~~~~~~~~~~~~~~~

In certain C++ programs, it is common to use classes that have been
wrapped by so-called "smart pointers." Generally, this involves the use
of a template class that implements operator->() like this:

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

To wrap this, simply tell SWIG about the SmartPtr class and the
low-level Foo object. Make sure you instantiate SmartPtr using template
if necessary. For example:

.. container:: code

   ::

      %module example
      ...
      %template(SmartPtrFoo) SmartPtr<Foo>;
      ...

Now, in Lua, everything should just "work":

.. container:: targetlang

   ::

      > p = example.CreateFoo()          -- Create a smart-pointer somehow
      > p.x = 3                          -- Foo::x
      > print(p:bar())                   -- Foo::bar

If you ever need to access the underlying pointer returned by
``operator->()`` itself, simply use the ``__deref__()`` method. For
example:

.. container:: targetlang

   ::

      > f = p:__deref__()     -- Returns underlying Foo *

C++ Exceptions
~~~~~~~~~~~~~~~~~~~~~~

Lua does not natively support exceptions, but it has errors which are
similar. When a Lua function terminates with an error it returns one
value back to the caller. SWIG automatically maps any basic type which
is thrown into a Lua error. Therefore for a function:

.. container:: code

   ::

      int message() throw(const char *) {
        throw("I died.");
        return 1;
      }

SWIG will automatically convert this to a Lua error.

.. container:: targetlang

   ::

      > message()
      I died.
      stack traceback:
              [C]: in function 'message'
              stdin:1: in main chunk
              [C]: ?
      >

If you want to catch an exception, you must use either pcall() or
xpcall(), which are documented in the Lua manual. Using xpcall will
allow you to obtain additional debug information (such as a stacktrace).

.. container:: targetlang

   ::

      > function a() b() end -- function a() calls function b()
      > function b() message() end -- function b() calls C++ function message(), which throws 
      > ok, res=pcall(a)  -- call the function
      > print(ok, res)
      false   I died.
      > ok, res=xpcall(a, debug.traceback)  -- call the function
      > print(ok, res)
      false   I died.
      stack traceback:
              [C]: in function 'message'
              runme.lua:70: in function 'b'
              runme.lua:67: in function <runme.lua:66>
              [C]: in function 'xpcall'
              runme.lua:95: in main chunk
              [C]: ?

SWIG is able to throw numeric types, enums, chars, char*'s and
std::string's without problem. It has also written typemaps for
std::exception and its derived classes, which convert the exception into
an error string.

However it's not so simple to throw other types of objects. Thrown
objects are not valid outside the 'catch' block. Therefore they cannot
be returned to the interpreter. The obvious ways to overcome this would
be to either return a copy of the object, or to convert the object to a
string and return that. Though it seems obvious to perform the former,
in some cases this is not possible, most notably when SWIG has no
information about the object, or the object is not copyable/creatable.

Therefore by default SWIG converts all thrown object into strings and
returns them. So given a function:

.. container:: code

   ::

      void throw_A() throw(A*) {
        throw new A();
      }

SWIG will just convert it (poorly) to a string and use that as its
error. (This is not that useful, but it always works).

.. container:: targetlang

   ::

      > throw_A()
      object exception:A *
      stack traceback:
              [C]: in function 'unknown'
              stdin:1: in main chunk
              [C]: ?
      >

To get a more useful behaviour out of SWIG you must either: provide a
way to convert your exceptions into strings, or throw objects which can
be copied.

If you have your own class which you want output as a string you will
need to add a typemap something like this:

.. container:: code

   ::

      %typemap(throws) my_except
      %{ 
        lua_pushstring(L, $1.what()); // assuming my_except::what() returns a const char* message
        SWIG_fail; // trigger the error handler
      %}

If you wish your exception to be returned to the interpreter, it must
firstly be copyable. Then you must have an additional ``%apply``
statement, to tell SWIG to return a copy of this object to the
interpreter. For example:

.. container:: code

   ::

      %apply SWIGTYPE EXCEPTION_BY_VAL {Exc}; // tell SWIG to return Exc by value to interpreter

      class Exc {
      public:
        Exc(int c, const char *m) {
          code = c;
          strncpy(msg, m, 256);
        }
        int code;
        char msg[256];
      };

      void throw_exc() throw(Exc) {
        throw(Exc(42, "Hosed"));
      } 

Then the following code can be used (note: we use pcall to catch the
error so we can process the exception).

.. container:: targetlang

   ::

      > ok, res=pcall(throw_exc)
      > print(ok)
      false
      > print(res)
      userdata: 0003D880
      > print(res.code, res.msg)
      42      Hosed
      >

Note: it is also possible (though tedious) to have a function throw
several different kinds of exceptions. To process this will require a
pcall, followed by a set of if statements checking the type of the
error.

All of this code assumes that your C++ code uses exception specification
(which a lot doesn't). If it doesn't consult the "`Exception handling
with %catches <SWIGPlus.html#SWIGPlus_catches>`__" section and the
"`Exception handling with
%exception <Customization.html#Customization_exception>`__" section, for
more details on how to add exception specification to functions or
globally (respectively).

Namespaces
~~~~~~~~~~~~~~~~~~

Since SWIG-3.0.0 C++ namespaces are supported via the %nspace feature.

Namespaces are mapped into Lua tables. Each of those tables contains
names that were defined within appropriate namespace. Namespaces
structure (a.k.a nested namespaces) is preserved. Consider the following
C++ code:

.. container:: code

   ::

      %module example
      %nspace MyWorld::Nested::Dweller;
      %nspace MyWorld::World;

      int module_function() { return 7; }
      int module_variable = 9;

      namespace MyWorld {
        class World {
        public:
          World() : world_max_count(9) {}
          int create_world() { return 17; }
          const int world_max_count; // = 9
        };
        namespace Nested {
          class Dweller {
            public:
              enum Gender { MALE = 0, FEMALE = 1 };
              static int count() { return 19; }
          };
        }
      }

Now, from Lua usage is as follows:

.. container:: targetlang

   ::

      > print(example.module_function())
      7
      > print(example.module_variable)
      9
      > print(example.MyWorld.World():create_world())
      17
      > print(example.MyWorld.World.world_max_count)
      9
      > print(example.MyWorld.Nested.Dweller.MALE)
      0
      > print(example.MyWorld.Nested.Dweller.count())
      19
      >

Compatibility Note
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If SWIG is running in a backwards compatible way, i.e. without the
``-no-old-metatable-bindings`` option, then additional old-style names
are generated (notice the underscore):

.. container:: targetlang

   ::

      9
      > print(example.MyWorld.Nested.Dweller_MALE)
      0
      > print(example.MyWorld.Nested.Dweller_count())
      11
      >

Names
^^^^^^^^^^^^^^^

If SWIG is launched without ``-no-old-metatable-bindings`` option, then
it enters backward-compatible mode. While in this mode, it tries to
generate additional names for static functions, class static constants
and class enums. Those names are in a form ``$classname_$symbolname``
and are added to the scope surrounding the class. If %nspace is enabled,
then class namespace is taken as scope. If there is no namespace, or
%nspace is disabled, then module is considered a class namespace.

Consider the following C++ code

.. container:: code

   ::

      %module example
      %nspace MyWorld::Test;
      namespace MyWorld {
      class Test {
        public:
        enum { TEST1 = 10, TEST2 }
        static const int ICONST = 12;
      };
      class Test2 {
        public:
        enum { TEST3 = 20, TEST4 }
        static const int ICONST2 = 23;
      }

When in backward compatible mode, in addition to the usual names, the
following ones will be generated (notice the underscore):

.. container:: targetlang

   ::

      9
      > print(example.MyWorld.Test_TEST1) -- Test has %nspace enabled
      10
      > print(example.MyWorld.Test_ICONST) -- Test has %nspace enabled
      12
      > print(example.Test2_TEST3) -- Test2 doesn't have %nspace enabled
      20
      > print(example.Test2_ICONST2) -- Test2 doesn't have %nspace enabled
      23
      >

There is a slight difference with enums when in C mode. As per C
standard, enums from C structures are exported to surrounding scope
without any prefixing. Pretending that Test2 is a struct, not class,
that would be:

.. container:: targetlang

   ::

      > print(example.TEST3) -- NOT Test2_TEST3
      20
      >

Inheritance
^^^^^^^^^^^^^^^^^^^^^

The internal organization of inheritance has changed. Consider the
following C++ code:

.. container:: code

   ::

      %module example
      class Base {
        public:
        int base_func()
      };
      class Derived : public Base {
        public:
        int derived_func()
      }

Lets assume for a moment that class member functions are stored in
``.fn`` table. Previously, when classes were exported to Lua during
module initialization, for every derived class all service tables
``ST(i.e. ".fn")`` were squashed and added to corresponding derived
class ``ST``: Everything from ``.fn`` table of class Base was copied to
``.fn`` table of class Derived and so on. This was a recursive
procedure, so in the end the whole inheritance tree of derived class was
squashed into derived class.

That means that any changes done to class Base after module
initialization wouldn't affect class Derived:

.. container:: targetlang

   ::

      base = example.Base()
      der = example.Derived()
      > print(base.base_func)
      function: 0x1367940
      > getmetatable(base)[".fn"].new_func = function (x) return x -- Adding new function to class Base (to class, not to an instance!)
      > print(base.new_func) -- Checking this function
      function
      > print(der.new_func) -- Wouldn't work. Derived doesn't check Base any more.
      nil
      >

This behaviour was changed. Now unless -squash-bases option is provided,
Derived store a list of it's bases and if some symbol is not found in
it's own service tables then its bases are searched for it. Option
-squash-bases will effectively return old behaviour.

.. container:: targetlang

   ::

      > print(der.new_func) -- Now it works
      function
      >

Typemaps
-------------

This section explains what typemaps are and how to use them. The default
wrapping behaviour of SWIG is enough in most cases. However sometimes
SWIG may need a little additional assistance to know which typemap to
apply to provide the best wrapping. This section will be explaining how
to use typemaps to best effect

What is a typemap?
~~~~~~~~~~~~~~~~~~~~~~~~~

A typemap is nothing more than a code generation rule that is attached
to a specific C datatype. For example, to convert integers from Lua to
C, you might define a typemap like this:

.. container:: code

   ::

      %module example

      %typemap(in) int {
        $1 = (int) lua_tonumber(L, $input);
        printf("Received an integer : %d\n", $1);
      }
      %inline %{
      extern int fact(int n);
      %}

*Note: you shouldn't use this typemap, as SWIG already has a typemap for
this task. This is purely for example.*

Typemaps are always associated with some specific aspect of code
generation. In this case, the "in" method refers to the conversion of
input arguments to C/C++. The datatype int is the datatype to which the
typemap will be applied. The supplied C code is used to convert values.
In this code a number of special variable prefaced by a $ are used. The
$1 variable is placeholder for a local variable of type int. The $input
is the index on the Lua stack for the value to be used.

When this example is compiled into a Lua module, it operates as follows:

.. container:: targetlang

   ::

      > require "example"
      > print(example.fact(6))
      Received an integer : 6
      720

Using typemaps
~~~~~~~~~~~~~~~~~~~~~

There are many ready written typemaps built into SWIG for all common
types (int, float, short, long, char*, enum and more), which SWIG uses
automatically, with no effort required on your part.

However for more complex functions which use input/output parameters or
arrays, you will need to make use of <typemaps.i>, which contains
typemaps for these situations. For example, consider these functions:

.. container:: code

   ::

      void add(int x, int y, int *result) {
        *result = x + y;
      }

      int sub(int *x1, int *y1) {
        return *x1-*y1;
      }

      void swap(int *sx, int *sy) {
        int t=*sx;
        *sx=*sy;
        *sy=t;
      }

It is clear to the programmer, that 'result' is an output parameter,
'x1' and 'y1' are input parameters and 'sx' and 'sy' are input/output
parameters. However is not apparent to SWIG, so SWIG must to informed
about which kind they are, so it can wrapper accordingly.

One means would be to rename the argument name to help SWIG, eg
``void add(int x, int y, int *OUTPUT)``, however it is easier to use the
``%apply`` to achieve the same result, as shown below.

.. container:: code

   ::

      %include <typemaps.i>
      %apply int* OUTPUT {int *result}; // int *result is output
      %apply int* INPUT {int *x1, int *y1}; // int *x1 and int *y1 are input
      %apply int* INOUT {int *sx, int *sy}; // int *sx and int *sy are input and output

      void add(int x, int y, int *result);
      int sub(int *x1, int *y1);
      void swap(int *sx, int *sy);

When wrapped, it gives the following results:

.. container:: targetlang

   ::

      > require "example"
      > print(example.add(1, 2))
      3
      > print(demo.sub(1, 2))
      -1
      > a, b=1, 2
      > c, d=demo.swap(a, b)
      > print(a, b, c, d)
      1       2       2       1

Notice, that 'result' is not required in the arguments to call the
function, as it an output parameter only. For 'sx' and 'sy' they must be
passed in (as they are input), but the original value is not modified
(Lua does not have a pass by reference feature). The modified results
are then returned as two return values. All INPUT/OUTPUT/INOUT arguments
will behave in a similar manner.

Note: C++ references must be handled exactly the same way. However SWIG
will automatically wrap a ``const int&`` as an input parameter (since
that it obviously input).

Typemaps and arrays
~~~~~~~~~~~~~~~~~~~~~~~~~~

Arrays present a challenge for SWIG, because like pointers SWIG does not
know whether these are input or output values, nor does SWIG have any
indication of how large an array should be. However with the proper
guidance SWIG can easily wrapper arrays for convenient usage.

Given the functions:

.. container:: code

   ::

      extern void sort_int(int* arr, int len);
      extern void sort_double(double* arr, int len);

There are basically two ways that SWIG can deal with this. The first
way, uses the ``<carrays.i>`` library to create an array in C/C++ then
this can be filled within Lua and passed into the function. It works,
but it's a bit tedious. More details can be found in the
`carrays.i <Library.html#Library_carrays>`__ documentation.

The second and more intuitive way, would be to pass a Lua table directly
into the function, and have SWIG automatically convert between Lua-table
and C-array. Within the ``<typemaps.i>`` file there are typemaps ready
written to perform this task. To use them is again a matter of using
%apply in the correct manner.

The wrapper file below, shows both the use of carrays as well as the use
of the typemap to wrap arrays.

.. container:: code

   ::

      // using the C-array
      %include <carrays.i>
      // this declares a batch of function for manipulating C integer arrays
      %array_functions(int, int)

      extern void sort_int(int* arr, int len); // the function to wrap

      // using typemaps
      %include <typemaps.i>
      %apply (double *INOUT, int) {(double* arr, int len)};

      extern void sort_double(double* arr, int len); // the function to wrap

Once wrapped, the functions can both be called, though with different
ease of use:

.. container:: targetlang

   ::

      require "example"
      ARRAY_SIZE=10

      -- passing a C array to the sort_int()
      arr=example.new_int(ARRAY_SIZE) -- create the array
      for i=0, ARRAY_SIZE-1 do -- index 0..9 (just like C)
          example.int_setitem(arr, i, math.random(1000))
      end
      example.sort_int(arr, ARRAY_SIZE)  -- call the function
      example.delete_int(arr) -- must delete the allocated memory

      -- use a typemap to call with a Lua-table
      -- one item of note: the typemap creates a copy, rather than edit-in-place
      t={} -- a Lua table
      for i=1, ARRAY_SIZE do -- index 1..10 (Lua style)
          t[i]=math.random(1000)/10
      end
      t=example.sort_double(t) -- replace t with the result

Obviously the first version could be made less tedious by writing a Lua
function to perform the conversion from a table to a C-array. The
``%luacode`` directive is good for this. See SWIG\Examples\lua\arrays
for an example of this.

**Warning:** in C indexes start at ZERO, in Lua indexes start at ONE.
SWIG expects C-arrays to be filled for 0..N-1 and Lua tables to be 1..N,
(the indexing follows the norm for the language). In the typemap when it
converts the table to an array it quietly changes the indexing
accordingly. Take note of this behaviour if you have a C function which
returns indexes.

Note: SWIG also can support arrays of pointers in a similar manner.

Typemaps and pointer-pointer functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Several C++ libraries use a pointer-pointer functions to create its
objects. These functions require a pointer to a pointer which is then
filled with the pointer to the new object. Microsoft's COM and DirectX
as well as many other libraries have this kind of function. An example
is given below:

.. container:: code

   ::

      struct iMath;    // some structure
      int Create_Math(iMath** pptr); // its creator (assume it mallocs)

Which would be used with the following C code:

.. container:: code

   ::

      iMath* ptr;
      int ok;
      ok=Create_Math(&ptr);
      // do things with ptr
      //...
      free(ptr); // dispose of iMath

SWIG has a ready written typemap to deal with such a kind of function in
<typemaps.i>. It provides the correct wrapping as well as setting the
flag to inform Lua that the object in question should be garbage
collected. Therefore the code is simply:

.. container:: code

   ::

      %include <typemaps.i>
      %apply SWIGTYPE** OUTPUT{iMath **pptr }; // tell SWIG it's an output

      struct iMath;    // some structure
      int Create_Math(iMath** pptr); // its creator (assume it mallocs)

The usage is as follows:

.. container:: targetlang

   ::

      ok, ptr=Create_Math() -- ptr is an iMath* which is returned with the int (ok)
      ptr=nil -- the iMath* will be GC'ed as normal

Writing typemaps
---------------------

This section describes how you can modify SWIG's default wrapping
behavior for various C/C++ datatypes using the ``%typemap`` directive.
This is an advanced topic that assumes familiarity with the Lua C API as
well as the material in the "`Typemaps <Typemaps.html#Typemaps>`__"
chapter.

Before proceeding, it should be stressed that writing typemaps is rarely
needed unless you want to change some aspect of the wrapping, or to
achieve an effect which in not available with the default bindings.

Before proceeding, you should read the previous section on using
typemaps, and look at the existing typemaps found in luatypemaps.swg and
typemaps.i. These are both well documented and fairly easy to read. You
should not attempt to write your own typemaps until you have read and
can understand both of these files (they may well also give you an idea
to base your work on).

Typemaps you can write
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are many different types of typemap that can be written, the full
list can be found in the "`Typemaps <Typemaps.html#Typemaps>`__"
chapter. However the following are the most commonly used ones.

-  ``in`` this is for input arguments to functions
-  ``out`` this is for return types from functions
-  ``argout`` this is for a function argument which is actually
   returning something
-  ``typecheck`` this is used to determine which overloaded function
   should be called (the syntax for the typecheck is different from the
   typemap, see typemaps for details).

SWIG's Lua-C API
~~~~~~~~~~~~~~~~~~~~~~~

This section explains the SWIG specific Lua-C API. It does not cover the
main Lua-C api, as this is well documented and not worth covering.

``int SWIG_ConvertPtr(lua_State* L, int index, void** ptr, swig_type_info *type, int flags);``

.. container:: indent

   This is the standard function used for converting a Lua userdata to a
   void*. It takes the value at the given index in the Lua state and
   converts it to a userdata. It will then provide the necessary type
   checks, confirming that the pointer is compatible with the type given
   in 'type'. Then finally setting '*ptr' to the pointer. If flags is
   set to SWIG_POINTER_DISOWN, this is will clear any ownership flag set
   on the object.
   This returns a value which can be checked with the macro SWIG_IsOK()

``void SWIG_NewPointerObj(lua_State* L, void* ptr, swig_type_info *type, int own);``

.. container:: indent

   This is the opposite of SWIG_ConvertPtr, as it pushes a new userdata
   which wrappers the pointer 'ptr' of type 'type'. The parameter 'own'
   specifies if the object is owned be Lua and if it is 1 then Lua will
   GC the object when the userdata is disposed of.

``void* SWIG_MustGetPtr(lua_State* L, int index, swig_type_info *type, int flags, int argnum, const char* func_name);``

.. container:: indent

   This function is a version of SWIG_ConvertPtr(), except that it will
   either work, or it will trigger a lua_error() with a text error
   message. This function is rarely used, and may be deprecated in the
   future.

``SWIG_fail``

.. container:: indent

   This macro, when called within the context of a SWIG wrapped
   function, will jump to the error handler code. This will call any
   cleanup code (freeing any temp variables) and then triggers a
   lua_error.
   A common use for this code is:
   ::

      if (!SWIG_IsOK(SWIG_ConvertPtr( .....)){
       lua_pushstring(L, "something bad happened");
       SWIG_fail;
      }

``SWIG_fail_arg(char* func_name, int argnum, char* type)``

.. container:: indent

   This macro, when called within the context of a SWIG wrapped
   function, will display the error message and jump to the error
   handler code. The error message is of the form
   ::

      "Error in func_name (arg argnum), expected 'type' got 'whatever the type was'"

``SWIG_fail_ptr(const char* fn_name, int argnum, swig_type_info* type);``

.. container:: indent

   Similar to SWIG_fail_arg, except that it will display the
   swig_type_info information instead.

Customization of your Bindings
-----------------------------------

This section covers adding of some small extra bits to your module to
add the last finishing touches.

Writing your own custom wrappers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes, it may be necessary to add your own special functions, which
bypass the normal SWIG wrapper method, and just use the native Lua API
calls. These 'native' functions allow direct adding of your own code
into the module. This is performed with the ``%native`` directive as
follows:

.. container:: code

   ::

      %native(my_func) int native_function(lua_State*L);  // registers native_function() with SWIG
      ...
      %{
      int native_function(lua_State*L) // my native code
      {
       ...
      }
      %}

The ``%native`` directive in the above example, tells SWIG that there is
a function ``int native_function(lua_State*L);`` which is to be added
into the module under the name '``my_func``'. SWIG will not add any
wrapper for this function, beyond adding it into the function table. How
you write your code is entirely up to you.

Adding additional Lua code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As well as adding additional C/C++ code, it's also possible to add your
own Lua code to the module as well. This code is executed once all other
initialisation, including the %init code has been called.

The directive ``%luacode`` adds code into the module which is executed
upon loading. Normally you would use this to add your own functions to
the module. Though you could easily perform other tasks.

.. container:: code

   ::

      %module example;

      %luacode {
        function example.greet() 
          print "hello world" 
        end

        print "Module loaded ok"
      }
      ...
      %}

Notice that the code is not part of the module table. Therefore any
references to the module must have the module name added.

Should there be an error in the Lua code, this will *not* stop loading
of the module. The default behaviour of SWIG is to print an error
message to stderr and then continue. It is possible to change this
behaviour by using a ``#define SWIG_DOSTRING_FAIL(STR)`` to define a
different behaviour should the code fail.

Good uses for this feature is adding of new code, or writing helper
functions to simplify some of the code. See Examples/lua/arrays for an
example of this code.

Details on the Lua binding
-------------------------------

In the previous section, a high-level view of Lua wrapping was
presented. Obviously a lot of stuff happens behind the scenes to make
this happen. This section will explain some of the low-level details on
how this is achieved.

*If you just want to use SWIG and don't care how it works, then stop
reading here. This is going into the guts of the code and how it works.
It's mainly for people who need to know what's going on within the
code.*

Binding global data into the module.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Assuming that you had some global data that you wanted to share between
C and Lua. How does SWIG do it?

.. container:: code

   ::

      %module example;
      extern double Foo;

SWIG will effectively generate the pair of functions

.. container:: code

   ::

      void Foo_set(double);
      double Foo_get();

At initialisation time, it will then add to the interpreter a table
called 'example', which represents the module. It will then add all its
functions to the module. (Note: older versions of SWIG actually added
the Foo_set() and Foo_get() functions, current implementation does not
add these functions any more.) But it also adds a metatable to this
table, which has two functions (``__index`` and ``__newindex``) as well
as two tables (``.get`` and ``.set``) The following Lua code will show
these hidden features.

.. container:: targetlang

   ::

      > print(example)
      table: 003F8F90
      > m=getmetatable(example)
      > table.foreach(m, print)
      .set    table: 003F9088
      .get    table: 003F9038
      __index function: 003F8FE0
      __newindex      function: 003F8FF8
      > g=m['.get']
      > table.foreach(g, print)
      Foo     function: 003FAFD8
      >

The .get and .set tables are lookups connecting the variable name 'Foo'
to the accessor/mutator functions (Foo_set, Foo_get)

The Lua equivalent of the code for the ``__index`` and ``__newindex``
looks a bit like this

.. container:: targetlang

   ::

      function __index(mod, name)
              local g=getmetatable(mod)['.get'] -- gets the table
              if not g then return nil end
              local f=g[name] -- looks for the function
              -- calls it & returns the value
              if type(f)=="function" then return f() end
              return nil
      end

      function __newindex(mod, name, value)
              local s=getmetatable(mod)['.set'] -- gets the table
              if not s then return end
              local f=s[name] -- looks for the function
              -- calls it to set the value
              if type(f)=="function" then f(value)
              else rawset(mod, name, value) end
      end

That way when you call '``a=example.Foo``', the interpreter looks at the
table 'example' sees that there is no field 'Foo' and calls \__index.
This will in turn check in '.get' table and find the existence of 'Foo'
and then return the value of the C function call 'Foo_get()'. Similarly
for the code '``example.Foo=10``', the interpreter will check the table,
then call the \__newindex which will then check the '.set' table and
call the C function 'Foo_set(10)'.

Userdata and Metatables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As mentioned earlier, classes and structures, are all held as pointer,
using the Lua 'userdata' structure. This structure is actually a pointer
to a C structure 'swig_lua_userdata', which contains the pointer to the
data, a pointer to the swig_type_info (an internal SWIG struct) and a
flag which marks if the object is to be disposed of when the interpreter
no longer needs it. The actual accessing of the object is done via the
metatable attached to this userdata.

The metatable is a Lua 5.0 feature (which is also why SWIG cannot wrap
Lua 4.0). It's a table which holds a list of functions, operators and
attributes. This is what gives the userdata the feeling that it is a
real object and not just a hunk of memory.

Given a class

.. container:: code

   ::

      %module excpp;

      class Point
      {
      public:
       int x, y;
       Point(){x=y=0;}
       ~Point(){}
       virtual void Print(){printf("Point @%p (%d, %d)\n", this, x, y);}
      };

SWIG will create a module excpp, with all the various functions inside.
However to allow the intuitive use of the userdata, SWIG also creates up
a set of metatables. As seen in the above section on global variables,
use of the metatables allows for wrappers to be used intuitively. To
save effort, the code creates one metatable per class and stores it
inside Lua's registry. Then when a new object is instantiated, the
metatable is found in the registry and the userdata associated with the
metatable. Currently, derived classes make a complete copy of the base
class' table and then add on their own additional functions.

Some of the internals can be seen by looking at the metatable of a
class:

.. container:: targetlang

   ::

      > p=excpp.Point()
      > print(p)
      userdata: 003FDB28
      > m=getmetatable(p)
      > table.foreach(m, print)
      .type   Point
      __gc    function: 003FB6C8
      __newindex      function: 003FB6B0
      __index function: 003FB698
      .get    table: 003FB4D8
      .set    table: 003FB500
      .fn     table: 003FB528

The '.type' attribute is the name of the class. The '.get' and '.set'
tables work in a similar manner to the modules, the main difference is
the '.fn' table which also holds all the member functions. (The '__gc'
function is the class' destructor function)

The Lua equivalent of the code for enabling functions looks a little
like this

.. container:: targetlang

   ::

      function __index(obj, name)
              local m=getmetatable(obj) -- gets the metatable
              if not m then return nil end
              local g=m['.get'] -- gets the attribute table
              if not g then return nil end
              local f=g[name] -- looks for the get_attribute function
              -- calls it & returns the value
              if type(f)=="function" then return f() end
              -- ok, so it not an attribute, maybe it's a function
              local fn=m['.fn'] -- gets the function table
              if not fn then return nil end
              local f=fn[name] -- looks for the function
              -- if found the fn then return the function
              -- so the interpreter can call it
              if type(f)=="function" then return f end
              return nil
      end

So when 'p:Print()' is called, the \__index looks on the object
metatable for a 'Print' attribute, then looks for a 'Print' function.
When it finds the function, it returns the function, and then
interpreter can call 'Point_Print(p)'

In theory, you can play with this usertable & add new features, but
remember that it is a shared table between all instances of one class,
and you could very easily corrupt the functions in all the instances.

Note: Both the opaque structures (like the FILE*) and normal wrapped
classes/structs use the same 'swig_lua_userdata' structure. Though the
opaque structures has do not have a metatable attached, or any
information on how to dispose of them when the interpreter has finished
with them.

Note: Operator overloads are basically done in the same way, by adding
functions such as '__add' & '__call' to the class' metatable. The
current implementation is a bit rough as it will add any member function
beginning with '__' into the metatable too, assuming its an operator
overload.

Memory management
~~~~~~~~~~~~~~~~~~~~~~~~

Lua is very helpful with the memory management. The 'swig_lua_userdata'
is fully managed by the interpreter itself. This means that neither the
C code nor the Lua code can damage it. Once a piece of userdata has no
references to it, it is not instantly collected, but will be collected
when Lua deems is necessary. (You can force collection by calling the
Lua function ``collectgarbage()``). Once the userdata is about to be
free'ed, the interpreter will check the userdata for a metatable and for
a function '__gc'. If this exists this is called. For all complete types
(ie normal wrapped classes & structs) this should exist. The '__gc'
function will check the 'swig_lua_userdata' to check for the 'own' field
and if this is true (which is will be for all owned data) it will then
call the destructor on the pointer.

It is currently not recommended to edit this field or add some user
code, to change the behaviour. Though for those who wish to try, here is
where to look.

It is also currently not possible to change the ownership flag on the
data (unlike most other scripting languages, Lua does not permit access
to the data from within the interpreter).

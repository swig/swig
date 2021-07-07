SWIG and C++
============

This chapter describes SWIG's support for wrapping C++. It is mostly
concerned about C++ as defined by the C++ 98 and 03 standards. For
additions to the original C++ standard, please read the `SWIG and
C++11 <CPlusPlus11.html#CPlusPlus11>`__, `SWIG and
C++14 <CPlusPlus14.html#CPlusPlus14>`__ and `SWIG and
C++17 <CPlusPlus17.html#CPlusPlus17>`__ chapters. `SWIG and
C++20 <CPlusPlus20.html#CPlusPlus20>`__ chapters. As a prerequisite, you
should first read the chapter `SWIG Basics <SWIG.html#SWIG>`__ to see
how SWIG wraps ISO C. Support for C++ builds upon ISO C wrapping and
that material will be useful in understanding this chapter.

Comments on C++ Wrapping
----------------------------

Because of its complexity and the fact that C++ can be difficult to
integrate with itself let alone other languages, SWIG only provides
support for a subset of C++ features. Fortunately, this is now a rather
large subset.

In part, the problem with C++ wrapping is that there is no semantically
obvious (or automatic ) way to map many of its advanced features into
other languages. As a simple example, consider the problem of wrapping
C++ multiple inheritance to a target language with no such support.
Similarly, the use of overloaded operators and overloaded functions can
be problematic when no such capability exists in a target language.

A more subtle issue with C++ has to do with the way that some C++
programmers think about programming libraries. In the world of SWIG, you
are really trying to create binary-level software components for use in
other languages. In order for this to work, a "component" has to contain
real executable instructions and there has to be some kind of binary
linking mechanism for accessing its functionality. In contrast, C++ has
increasingly relied upon generic programming and templates for much of
its functionality. Although templates are a powerful feature, they are
largely orthogonal to the whole notion of binary components and
libraries. For example, an STL ``vector`` does not define any kind of
binary object for which SWIG can just create a wrapper. To further
complicate matters, these libraries often utilize a lot of behind the
scenes magic in which the semantics of seemingly basic operations (e.g.,
pointer dereferencing, procedure call, etc.) can be changed in dramatic
and sometimes non-obvious ways. Although this "magic" may present few
problems in a C++-only universe, it greatly complicates the problem of
crossing language boundaries and provides many opportunities to shoot
yourself in the foot. You will just have to be careful.

Approach
------------

To wrap C++, SWIG uses a layered approach to code generation. At the
lowest level, SWIG generates a collection of procedural ISO C style
wrappers. These wrappers take care of basic type conversion, type
checking, error handling, and other low-level details of the C++
binding. These wrappers are also sufficient to bind C++ into any target
language that supports built-in procedures. In some sense, you might
view this layer of wrapping as providing a C library interface to C++.
On top of the low-level procedural (flattened) interface, SWIG generates
proxy classes that provide a natural object-oriented (OO) interface to
the underlying code. The proxy classes are typically written in the
target language itself. For instance, in Python, a real Python class is
used to provide a wrapper around the underlying C++ object.

It is important to emphasize that SWIG takes a deliberately conservative
and non-intrusive approach to C++ wrapping. SWIG does not encapsulate
C++ classes inside a special C++ adaptor, it does not rely upon
templates, nor does it add in additional C++ inheritance when generating
wrappers. The last thing that most C++ programs need is even more
compiler magic. Therefore, SWIG tries to maintain a very strict and
clean separation between the implementation of your C++ application and
the resulting wrapper code. You might say that SWIG has been written to
follow the principle of least surprise--it does not play sneaky tricks
with the C++ type system, it doesn't mess with your class hierarchies,
and it doesn't introduce new semantics. Although this approach might not
provide the most seamless integration with C++, it is safe, simple,
portable, and debuggable.

Some of this chapter focuses on the low-level procedural interface to
C++ that is used as the foundation for all language modules. Keep in
mind that the target languages also provide the high-level OO interface
via proxy classes. More detailed coverage can be found in the
documentation for each target language.

Supported C++ features
--------------------------

SWIG currently supports most C++ features including the following:

-  Classes
-  Constructors and destructors
-  Virtual functions
-  Public inheritance (including multiple inheritance)
-  Static functions
-  Function and method overloading
-  Operator overloading for many standard operators
-  References
-  Templates (including specialization and member templates)
-  Pointers to members
-  Namespaces
-  Default parameters
-  Smart pointers

The following C++ features are not currently supported:

-  Overloaded versions of certain operators (new, delete, etc.)

As a rule of thumb, SWIG should not be used on raw C++ source files, use
header files only.

SWIG's C++ support is an ongoing project so some of these limitations
may be lifted in future releases. However, we make no promises. Also,
submitting a bug report is a very good way to get problems fixed (wink).

Command line options and compilation
----------------------------------------

When wrapping C++ code, it is critical that SWIG be called with the
\`\ ``-c++``' option. This changes the way a number of critical features
such as memory management are handled. It also enables the recognition
of C++ keywords. Without the ``-c++`` flag, SWIG will either issue a
warning or a large number of syntax errors if it encounters C++ code in
an interface file.

When compiling and linking the resulting wrapper file, it is normal to
use the C++ compiler. For example:

.. container:: shell

   ::

      $ swig -c++ -tcl example.i
      $ c++ -fPIC -c example_wrap.cxx 
      $ c++ example_wrap.o $(OBJS) -o example.so

Unfortunately, the process varies slightly on each platform. Make sure
you refer to the documentation on each target language for further
details. The SWIG Wiki also has further details.

**Compatibility Note:** Early versions of SWIG generated just a
flattened low-level C style API to C++ classes by default. The
``-noproxy`` commandline option is recognised by many target languages
and will generate just this interface as in earlier versions.

Proxy classes
-----------------

In order to provide a natural mapping from C++ classes to the target
language classes, SWIG's target languages mostly wrap C++ classes with
special proxy classes. These proxy classes are typically implemented in
the target language itself. For example, if you're building a Python
module, each C++ class is wrapped by a Python proxy class. Or if you're
building a Java module, each C++ class is wrapped by a Java proxy class.

Construction of proxy classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Proxy classes are always constructed as an extra layer of wrapping that
uses low-level accessor functions. To illustrate, suppose you had a C++
class like this:

.. container:: code

   ::

      class Foo {
        public:
          Foo();
          ~Foo();
          int  bar(int x);
          int  x;
      };

Using C++ as pseudocode, a proxy class looks something like this:

.. container:: code

   ::

      class FooProxy {
        private:
          Foo    *self;
        public:
          FooProxy() {
            self = new_Foo();
          }
          ~FooProxy() {
            delete_Foo(self);
          }
          int bar(int x) {
            return Foo_bar(self, x);
          }
          int x_get() {
            return Foo_x_get(self);
          }
          void x_set(int x) {
            Foo_x_set(self, x);
          }
      };

Of course, always keep in mind that the real proxy class is written in
the target language. For example, in Python, the proxy might look
roughly like this:

.. container:: targetlang

   ::

      class Foo:
          def __init__(self):
              self.this = new_Foo()
          def __del__(self):
              delete_Foo(self.this)
          def bar(self, x):
              return Foo_bar(self.this, x)
          def __getattr__(self, name):
              if name == 'x':
                  return Foo_x_get(self.this)
              ...
          def __setattr__(self, name, value):
              if name == 'x':
                  Foo_x_set(self.this, value)
              ...

Again, it's important to emphasize that the low-level accessor functions
are always used by the proxy classes. Whenever possible, proxies try to
take advantage of language features that are similar to C++. This might
include operator overloading, exception handling, and other features.

Resource management in proxies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A major issue with proxies concerns the memory management of wrapped
objects. Consider the following C++ code:

.. container:: code

   ::

      class Foo {
      public:
        Foo();
        ~Foo();
        int bar(int x);
        int x;
      };

      class Spam {
      public:
        Foo *value;
        ...
      };

Consider some script code that uses these classes:

.. container:: targetlang

   ::

      f = Foo()               # Creates a new Foo
      s = Spam()              # Creates a new Spam
      s.value = f             # Stores a reference to f inside s
      g = s.value             # Returns stored reference
      g = 4                   # Reassign g to some other value
      del f                   # Destroy f 

Now, ponder the resulting memory management issues. When objects are
created in the script, the objects are wrapped by newly created proxy
classes. That is, there is both a new proxy class instance and a new
instance of the underlying C++ class. In this example, both ``f`` and
``s`` are created in this way. However, the statement ``s.value`` is
rather curious---when executed, a pointer to ``f`` is stored inside
another object. This means that the scripting proxy class *AND* another
C++ class share a reference to the same object. To make matters even
more interesting, consider the statement ``g = s.value``. When executed,
this creates a new proxy class ``g`` that provides a wrapper around the
C++ object stored in ``s.value``. In general, there is no way to know
where this object came from---it could have been created by the script,
but it could also have been generated internally. In this particular
example, the assignment of ``g`` results in a second proxy class for
``f``. In other words, a reference to ``f`` is now shared by two proxy
classes *and* a C++ class.

Finally, consider what happens when objects are destroyed. In the
statement, ``g=4``, the variable ``g`` is reassigned. In many languages,
this makes the old value of ``g`` available for garbage collection.
Therefore, this causes one of the proxy classes to be destroyed. Later
on, the statement ``del f`` destroys the other proxy class. Of course,
there is still a reference to the original object stored inside another
C++ object. What happens to it? Is the object still valid?

To deal with memory management problems, proxy classes provide an API
for controlling ownership. In C++ pseudocode, ownership control might
look roughly like this:

.. container:: code

   ::

      class FooProxy {
        public:
          Foo    *self;
          int     thisown;

          FooProxy() {
            self = new_Foo();
            thisown = 1;       // Newly created object
          }
          ~FooProxy() {
            if (thisown) delete_Foo(self);
          }
          ...
          // Ownership control API
          void disown() {
            thisown = 0;
          }
          void acquire() {
            thisown = 1;
          }
      };

      class FooPtrProxy: public FooProxy {
      public:
        FooPtrProxy(Foo *s) {
          self = s;
          thisown = 0;
        }
      };

      class SpamProxy {
        ...
        FooProxy *value_get() {
          return FooPtrProxy(Spam_value_get(self));
        }
        void value_set(FooProxy *v) {
          Spam_value_set(self, v->self);
          v->disown();
        }
        ...
      };

Looking at this code, there are a few central features:

-  Each proxy class keeps an extra flag to indicate ownership. C++
   objects are only destroyed if the ownership flag is set.
-  When new objects are created in the target language, the ownership
   flag is set.
-  When a reference to an internal C++ object is returned, it is wrapped
   by a proxy class, but the proxy class does not have ownership.
-  In certain cases, ownership is adjusted. For instance, when a value
   is assigned to the member of a class, ownership is lost.
-  Manual ownership control is provided by special ``disown()`` and
   ``acquire()`` methods.

Given the tricky nature of C++ memory management, it is impossible for
proxy classes to automatically handle every possible memory management
problem. However, proxies do provide a mechanism for manual control that
can be used (if necessary) to address some of the more tricky memory
management problems.

Language specific details
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Language specific details on proxy classes are contained in the chapters
describing each target language. This chapter has merely introduced the
topic in a very general way.

Simple C++ wrapping
-----------------------

The following code shows a SWIG interface file for a simple C++ class.

.. container:: code

   ::

      %module list
      %{
      #include "list.h"
      %}

      // Very simple C++ example for linked list

      class List {
      public:
        List();
        ~List();
        int  search(char *value);
        void insert(char *);
        void remove(char *);
        char *get(int n);
        int  length;
      static void print(List *l);
      };

To generate wrappers for this class, SWIG first reduces the class to a
collection of low-level C-style accessor functions which are then used
by the proxy classes.

Constructors and destructors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C++ constructors and destructors are translated into accessor functions
such as the following :

.. container:: code

   ::

      List * new_List(void) {
        return new List;
      }
      void delete_List(List *l) {
        delete l;
      }

Default constructors, copy constructors and implicit destructors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Following the C++ rules for implicit constructor and destructors, SWIG
will automatically assume there is one even when they are not explicitly
declared in the class interface.

In general then:

-  If a C++ class does not declare any explicit constructor, SWIG will
   automatically generate a wrapper for one.
-  If a C++ class does not declare an explicit copy constructor, SWIG
   will automatically generate a wrapper for one if the ``%copyctor`` is
   used.
-  If a C++ class does not declare an explicit destructor, SWIG will
   automatically generate a wrapper for one.

And as in C++, a few rules that alters the previous behavior:

-  A default constructor is not created if a class already defines a
   constructor with arguments.
-  Default constructors are not generated for classes with pure virtual
   methods or for classes that inherit from an abstract class, but don't
   provide definitions for all of the pure methods.
-  A default constructor is not created unless all base classes support
   a default constructor.
-  Default constructors and implicit destructors are not created if a
   class defines them in a ``private`` or ``protected`` section.
-  Default constructors and implicit destructors are not created if any
   base class defines a non-public default constructor or destructor.

SWIG should never generate a default constructor, copy constructor or
default destructor wrapper for a class in which it is illegal to do so.
In some cases, however, it could be necessary (if the complete class
declaration is not visible from SWIG, and one of the above rules is
violated) or desired (to reduce the size of the final interface) by
manually disabling the implicit constructor/destructor generation.

To manually disable these, the ``%nodefaultctor`` and ``%nodefaultdtor``
`feature flag <Customization.html#Customization_feature_flags>`__
directives can be used. Note that these directives only affects the
implicit generation, and they have no effect if the default/copy
constructors or destructor are explicitly declared in the class
interface.

For example:

.. container:: code

   ::

      %nodefaultctor Foo;  // Disable the default constructor for class Foo.
      class Foo {          // No default constructor is generated, unless one is declared
      ...
      };
      class Bar {          // A default constructor is generated, if possible
      ...
      };

The directive ``%nodefaultctor`` can also be applied "globally", as in:

.. container:: code

   ::

      %nodefaultctor; // Disable creation of default constructors
      class Foo {     // No default constructor is generated, unless one is declared
      ...
      };
      class Bar {   
      public:
        Bar();        // The default constructor is generated, since one is declared
      };
      %clearnodefaultctor; // Enable the creation of default constructors again

The corresponding ``%nodefaultdtor`` directive can be used to disable
the generation of the default or implicit destructor, if needed. Be
aware, however, that this could lead to memory leaks in the target
language. Hence, it is recommended to use this directive only in well
known cases. For example:

.. container:: code

   ::

      %nodefaultdtor Foo;   // Disable the implicit/default destructor for class Foo.
      class Foo {           // No destructor is generated, unless one is declared
      ...
      };

**Compatibility Note:** The generation of default constructors/implicit
destructors was made the default behavior in SWIG 1.3.7. This may break
certain older modules, but the old behavior can be easily restored using
``%nodefault`` or the ``-nodefault`` command line option. Furthermore,
in order for SWIG to properly generate (or not generate) default
constructors, it must be able to gather information from both the
``private`` and ``protected`` sections (specifically, it needs to know
if a private or protected constructor/destructor is defined). In older
versions of SWIG, it was fairly common to simply remove or comment out
the private and protected sections of a class due to parser limitations.
However, this removal may now cause SWIG to erroneously generate
constructors for classes that define a constructor in those sections.
Consider restoring those sections in the interface or using
``%nodefault`` to fix the problem.

**Note:** The ``%nodefault`` directive/``-nodefault`` options described
above, which disable both the default constructor and the implicit
destructors, could lead to memory leaks, and so it is strongly
recommended to not use them.

When constructor wrappers aren't created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If a class defines a constructor, SWIG normally tries to generate a
wrapper for it. However, SWIG will not generate a constructor wrapper if
it thinks that it will result in illegal wrapper code. There are really
two cases where this might show up.

First, SWIG won't generate wrappers for protected or private
constructors. For example:

.. container:: code

   ::

      class Foo {
      protected:
        Foo();         // Not wrapped.
      public:
        ...
      };

Next, SWIG won't generate wrappers for a class if it appears to be
abstract--that is, it has undefined pure virtual methods. Here are some
examples:

.. container:: code

   ::

      class Bar {
      public:
        Bar();               // Not wrapped.  Bar is abstract.
        virtual void spam(void) = 0;
      };

      class Grok : public Bar {
      public:
        Grok();              // Not wrapped. No implementation of abstract spam().
      };

Some users are surprised (or confused) to find missing constructor
wrappers in their interfaces. In almost all cases, this is caused when
classes are determined to be abstract. To see if this is the case, run
SWIG with all of its warnings turned on:

.. container:: shell

   ::

      % swig -Wall -python module.i

In this mode, SWIG will issue a warning for all abstract classes. It is
possible to force a class to be non-abstract using this:

.. container:: code

   ::

      %feature("notabstract") Foo;

      class Foo : public Bar {
      public:
        Foo();    // Generated no matter what---not abstract.
        ...
      };

More information about ``%feature`` can be found in the `Customization
features <Customization.html#Customization>`__ chapter.

Copy constructors
~~~~~~~~~~~~~~~~~~~~~~~

If a class defines more than one constructor, its behavior depends on
the capabilities of the target language. If overloading is supported,
the copy constructor is accessible using the normal constructor
function. For example, if you have this:

.. container:: code

   ::

      class List {
      public:
        List();    
        List(const List &);      // Copy constructor
        ...
      };

then the copy constructor can be used as follows:

.. container:: targetlang

   ::

      x = List()               # Create a list
      y = List(x)              # Copy list x

If the target language does not support overloading, then the copy
constructor is available through a special function like this:

.. container:: code

   ::

      List *copy_List(List *f) {
        return new List(*f);
      }

**Note:** For a class ``X``, SWIG only treats a constructor as a copy
constructor if it can be applied to an object of type ``X`` or ``X *``.
If more than one copy constructor is defined, only the first definition
that appears is used as the copy constructor--other definitions will
result in a name-clash. Constructors such as ``X(const X &)``,
``X(X &)``, and ``X(X *)`` are handled as copy constructors in SWIG.

**Note:** SWIG does *not* generate a copy constructor wrapper unless one
is explicitly declared in the class. This differs from the treatment of
default constructors and destructors. However, copy constructor wrappers
can be generated if using the ``copyctor`` `feature
flag <Customization.html#Customization_feature_flags>`__. For example:

.. container:: code

   ::

      %copyctor List;

      class List {
      public:
        List();    
      };

Will generate a copy constructor wrapper for ``List``.

**Compatibility note:** Special support for copy constructors was not
added until SWIG-1.3.12. In previous versions, copy constructors could
be wrapped, but they had to be renamed. For example:

.. container:: code

   ::

      class Foo {
      public:
        Foo();
        %name(CopyFoo) Foo(const Foo &);
        ...
      };

For backwards compatibility, SWIG does not perform any special
copy-constructor handling if the constructor has been manually renamed.
For instance, in the above example, the name of the constructor is set
to ``new_CopyFoo()``. This is the same as in older versions.

Member functions
~~~~~~~~~~~~~~~~~~~~~~

All member functions are roughly translated into accessor functions like
this :

.. container:: code

   ::

      int List_search(List *obj, char *value) {
        return obj->search(value);
      }

This translation is the same even if the member function has been
declared as ``virtual``.

It should be noted that SWIG does not *actually* create a C accessor
function in the code it generates. Instead, member access such as
``obj->search(value)`` is directly inlined into the generated wrapper
functions. However, the name and calling convention of the low-level
procedural wrappers match the accessor function prototype described
above.

Static members
~~~~~~~~~~~~~~~~~~~~

Static member functions are called directly without making any special
transformations. For example, the static member function
``print(List *l)`` directly invokes ``List::print(List *l)`` in the
generated wrapper code.

Member data
~~~~~~~~~~~~~~~~~

Member data is handled in exactly the same manner as for C structures. A
pair of accessor functions are effectively created. For example :

.. container:: code

   ::

      int List_length_get(List *obj) {
        return obj->length;
      }
      int List_length_set(List *obj, int value) {
        obj->length = value;
        return value;
      }

A read-only member can be created using the ``%immutable`` and
``%mutable`` `feature
flag <Customization.html#Customization_feature_flags>`__ directive. For
example, we probably wouldn't want the user to change the length of a
list so we could do the following to make the value available, but
read-only.

.. container:: code

   ::

      class List {
      public:
      ...
      %immutable;
        int length;
      %mutable;
      ...
      };

Alternatively, you can specify an immutable member in advance like this:

.. container:: code

   ::

      %immutable List::length;
      ...
      class List {
        ...
        int length;         // Immutable by above directive
        ...
      };

Similarly, all data attributes declared as ``const`` are wrapped as
read-only members.

By default, SWIG uses the const reference typemaps for members that are
primitive types. There are some subtle issues when wrapping data members
that are not primitive types, such as classes. For instance, if you had
another class like this,

.. container:: code

   ::

      class Foo {
      public:
        List items;
        ...

then the low-level accessor to the ``items`` member actually uses
pointers. For example:

.. container:: code

   ::

      List *Foo_items_get(Foo *self) {
        return &self->items;
      }
      void Foo_items_set(Foo *self, List *value) {
        self->items = *value;
      }

More information about this can be found in the SWIG Basics chapter,
`Structure data members <SWIG.html#SWIG_structure_data_members>`__
section.

The wrapper code to generate the accessors for classes comes from the
pointer typemaps. This can be somewhat unnatural for some types. For
example, a user would expect the STL std::string class member variables
to be wrapped as a string in the target language, rather than a pointer
to this class. The const reference typemaps offer this type of
marshalling, so there is a feature to tell SWIG to use the const
reference typemaps rather than the pointer typemaps. It is the
naturalvar feature and can be used to effectively change the way
accessors are generated to the following:

.. container:: code

   ::

      const List &Foo_items_get(Foo *self) {
        return self->items;
      }
      void Foo_items_set(Foo *self, const List &value) {
        self->items = value;
      }

The ``%naturalvar`` directive is a macro for, and hence equivalent to,
``%feature("naturalvar")``. It can be used as follows:

.. container:: code

   ::

      // All List variables will use const List& typemaps
      %naturalvar List;

      // Only Foo::myList will use const List& typemaps
      %naturalvar Foo::myList;
      struct Foo {
        List myList;
      };

      // All non-primitive types will use const reference typemaps
      %naturalvar;

The observant reader will notice that ``%naturalvar`` works like any
other `feature flag <Customization.html#Customization_feature_flags>`__
directive but with some extra flexibility. The first of the example
usages above shows ``%naturalvar`` attaching to the ``myList``'s
variable type, that is the ``List`` class. The second usage shows
``%naturalvar`` attaching to the variable name. Hence the naturalvar
feature can be used on either the variable's name or type. Note that
using the naturalvar feature on a variable's name overrides any
naturalvar feature attached to the variable's type.

It is generally a good idea to use this feature globally as the
reference typemaps have extra NULL checking compared to the pointer
typemaps. A pointer can be NULL, whereas a reference cannot, so the
extra checking ensures that the target language user does not pass in a
value that translates to a NULL pointer and thereby preventing any
potential NULL pointer dereferences. The ``%naturalvar`` feature will
apply to global variables in addition to member variables in some
language modules, eg C# and Java.

The naturalvar behavior can also be turned on as a global setting via
the ``-naturalvar`` commandline option or the module mode option,
``%module(naturalvar=1)``. However, any use of
``%feature("naturalvar")`` will override the global setting.

**Compatibility note:** The ``%naturalvar`` feature was introduced in
SWIG-1.3.28, prior to which it was necessary to manually apply the const
reference typemaps, eg ``%apply const std::string & { std::string * }``,
but this example would also apply the typemaps to methods taking a
``std::string`` pointer.

**Compatibility note:** Read-only access used to be controlled by a pair
of directives ``%readonly`` and ``%readwrite``. Although these
directives still work, they generate a warning message. Simply change
the directives to ``%immutable;`` and ``%mutable;`` to silence the
warning. Don't forget the extra semicolon!

**Compatibility note:** Prior to SWIG-1.3.12, all members of unknown
type were wrapped into accessor functions using pointers. For example,
if you had a structure like this

.. container:: code

   ::

      struct Foo {
        size_t  len;
      };

and nothing was known about ``size_t``, then accessors would be written
to work with ``size_t *``. Starting in SWIG-1.3.12, this behavior has
been modified. Specifically, pointers will *only* be used if SWIG knows
that a datatype corresponds to a structure or class. Therefore, the
above code would be wrapped into accessors involving ``size_t``. This
change is subtle, but it smooths over a few problems related to
structure wrapping and some of SWIG's customization features.

Protection
--------------

SWIG wraps class members that are public following the C++ conventions,
i.e., by explicit public declaration or by the use of the ``using``
directive. In general, anything specified in a private or protected
section will be ignored, although the internal code generator sometimes
looks at the contents of the private and protected sections so that it
can properly generate code for default constructors and destructors.
Directors could also modify the way non-public virtual protected members
are treated.

By default, members of a class definition are assumed to be private
until you explicitly give a \`\ ``public:``' declaration (This is the
same convention used by C++).

Enums and constants
-----------------------

Enumerations and constants are handled differently by the different
language modules and are described in detail in the appropriate language
chapter. However, many languages map enums and constants in a class
definition into constants with the classname as a prefix. For example :

.. container:: code

   ::

      class Swig {
      public:
        enum {ALE, LAGER, PORTER, STOUT};
      };

Generates the following set of constants in the target scripting
language :

.. container:: targetlang

   ::

      Swig_ALE = Swig::ALE
      Swig_LAGER = Swig::LAGER
      Swig_PORTER = Swig::PORTER
      Swig_STOUT = Swig::STOUT

Members declared as ``const`` are wrapped as read-only members and do
not create constants.

Friends
-----------

Friend declarations are recognised by SWIG. For example, if you have
this code:

.. container:: code

   ::

      class Foo {
      public:
        ...
        friend void blah(Foo *f);
        ...
      };

then the ``friend`` declaration does result in a wrapper code equivalent
to one generated for the following declaration

.. container:: code

   ::

      class Foo {
      public:
        ...
      };

      void blah(Foo *f);    

A friend declaration, as in C++, is understood to be in the same scope
where the class is declared, hence, you can have

.. container:: code

   ::


      %ignore bar::blah(Foo *f);

      namespace bar {

        class Foo {
        public:
          ...
          friend void blah(Foo *f);
          ...
        };
      }

and a wrapper for the method 'blah' will not be generated.

References and pointers
----------------------------

C++ references are supported, but SWIG transforms them back into
pointers. For example, a declaration like this :

.. container:: code

   ::

      class Foo {
      public:
        double bar(double &a);
      }

has a low-level accessor

.. container:: code

   ::

      double Foo_bar(Foo *obj, double *a) {
        obj->bar(*a);
      }

As a special case, most language modules pass ``const`` references to
primitive datatypes (``int``, ``short``, ``float``, etc.) by value
instead of pointers. For example, if you have a function like this,

.. container:: code

   ::

      void foo(const int &x);

it is called from a script as follows:

.. container:: targetlang

   ::

      foo(3)              # Notice pass by value

Functions that return a reference are remapped to return a pointer
instead. For example:

.. container:: code

   ::

      class Bar {
      public:
        Foo &spam();
      };

Generates an accessor like this:

.. container:: code

   ::

      Foo *Bar_spam(Bar *obj) {
        Foo &result = obj->spam();
        return &result;
      }

However, functions that return ``const`` references to primitive
datatypes (``int``, ``short``, etc.) normally return the result as a
value rather than a pointer. For example, a function like this,

.. container:: code

   ::

      const int &bar();

will return integers such as 37 or 42 in the target scripting language
rather than a pointer to an integer.

Don't return references to objects allocated as local variables on the
stack. SWIG doesn't make a copy of the objects so this will probably
cause your program to crash.

**Note:** The special treatment for references to primitive datatypes is
necessary to provide more seamless integration with more advanced C++
wrapping applications---especially related to templates and the STL.
This was first added in SWIG-1.3.12.

Pass and return by value
-----------------------------

Occasionally, a C++ program will pass and return class objects by value.
For example, a function like this might appear:

.. container:: code

   ::

      Vector cross_product(Vector a, Vector b);

If no information is supplied about ``Vector``, SWIG creates a wrapper
function similar to the following:

.. container:: code

   ::

      Vector *wrap_cross_product(Vector *a, Vector *b) {
        Vector x = *a;
        Vector y = *b;
        Vector r = cross_product(x, y);
        return new Vector(r);
      }

In order for the wrapper code to compile, ``Vector`` must define a copy
constructor and a default constructor.

If ``Vector`` is defined as a class in the interface, but it does not
support a default constructor, SWIG changes the wrapper code by
encapsulating the arguments inside a special C++ template wrapper class,
through a process called the "Fulton Transform". This produces a wrapper
that looks like this:

.. container:: code

   ::

      Vector cross_product(Vector *a, Vector *b) {
        SwigValueWrapper<Vector> x = *a;
        SwigValueWrapper<Vector> y = *b;
        SwigValueWrapper<Vector> r = cross_product(x, y);
        return new Vector(r);
      }

This transformation is a little sneaky, but it provides support for
pass-by-value even when a class does not provide a default constructor
and it makes it possible to properly support a number of SWIG's
customization options. The definition of ``SwigValueWrapper`` can be
found by reading the SWIG wrapper code. This class is really nothing
more than a thin wrapper around a pointer.

Although SWIG usually detects the classes to which the Fulton Transform
should be applied, in some situations it's necessary to override it.
That's done with ``%feature("valuewrapper")`` to ensure it is used and
``%feature("novaluewrapper")`` to ensure it is not used:

.. container:: code

   ::

      %feature("novaluewrapper") A;    
      class A;

      %feature("valuewrapper") B;
      struct B { 
        B();
        // ....
      };   

It is well worth considering turning this feature on for classes that do
have a default constructor. It will remove a redundant constructor call
at the point of the variable declaration in the wrapper, so will
generate notably better performance for large objects or for classes
with expensive construction. Alternatively consider returning a
reference or a pointer.

**Note:** this transformation has no effect on typemaps or any other
part of SWIG---it should be transparent except that you may see this
code when reading the SWIG output file.

**Note:** This template transformation is new in SWIG-1.3.11 and may be
refined in future SWIG releases. In practice, it is only absolutely
necessary to do this for classes that don't define a default
constructor.

**Note:** The use of this template only occurs when objects are passed
or returned by value. It is not used for C++ pointers or references.

Inheritance
----------------

SWIG supports C++ inheritance of classes and allows both single and
multiple inheritance, as limited or allowed by the target language. The
SWIG type-checker knows about the relationship between base and derived
classes and allows pointers to any object of a derived class to be used
in functions of a base class. The type-checker properly casts pointer
values and is safe to use with multiple inheritance.

SWIG treats private or protected inheritance as close to the C++ spirit,
and target language capabilities, as possible. In most cases, this means
that SWIG will parse the non-public inheritance declarations, but that
will have no effect in the generated code, besides the implicit policies
derived for constructors and destructors.

The following example shows how SWIG handles inheritance. For clarity,
the full C++ code has been omitted.

.. container:: code

   ::

      // shapes.i
      %module shapes
      %{
      #include "shapes.h"
      %}

      class Shape {
      public:
        double x, y;
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

When wrapped into Python, we can perform the following operations (shown
using the low level Python accessors):

.. container:: targetlang

   ::

      $ python
      >>> import shapes
      >>> circle = shapes.new_Circle(7)
      >>> square = shapes.new_Square(10)
      >>> print shapes.Circle_area(circle)
      153.93804004599999757
      >>> print shapes.Shape_area(circle)
      153.93804004599999757
      >>> print shapes.Shape_area(square)
      100.00000000000000000
      >>> shapes.Shape_set_location(square, 2, -3)
      >>> print shapes.Shape_perimeter(square)
      40.00000000000000000
      >>>

In this example, Circle and Square objects have been created. Member
functions can be invoked on each object by making calls to
``Circle_area``, ``Square_area``, and so on. However, the same results
can be accomplished by simply using the ``Shape_area`` function on
either object.

One important point concerning inheritance is that the low-level
accessor functions are only generated for classes in which they are
actually declared. For instance, in the above example, the method
``set_location()`` is only accessible as ``Shape_set_location()`` and
not as ``Circle_set_location()`` or ``Square_set_location()``. Of
course, the ``Shape_set_location()`` function will accept any kind of
object derived from Shape. Similarly, accessor functions for the
attributes ``x`` and ``y`` are generated as ``Shape_x_get()``,
``Shape_x_set()``, ``Shape_y_get()``, and ``Shape_y_set()``. Functions
such as ``Circle_x_get()`` are not available--instead you should use
``Shape_x_get()``.

Note that there is a one to one correlation between the low-level
accessor functions and the proxy methods and therefore there is also a
one to one correlation between the C++ class methods and the generated
proxy class methods.

**Note:** For the best results, SWIG requires all base classes to be
defined in an interface. Otherwise, you may get a warning message like
this:

.. container:: shell

   ::

      example.i:18: Warning 401: Nothing known about base class 'Foo'. Ignored.

If any base class is undefined, SWIG still generates correct type
relationships. For instance, a function accepting a ``Foo *`` will
accept any object derived from ``Foo`` regardless of whether or not SWIG
actually wrapped the ``Foo`` class. If you really don't want to generate
wrappers for the base class, but you want to silence the warning, you
might consider using the ``%import`` directive to include the file that
defines ``Foo``. ``%import`` simply gathers type information, but
doesn't generate wrappers. Alternatively, you could just define ``Foo``
as an empty class in the SWIG interface or use `warning
suppression <Warnings.html#Warnings_suppression>`__.

**Note:** ``typedef``-names *can* be used as base classes. For example:

.. container:: code

   ::

      class Foo {
      ...
      };

      typedef Foo FooObj;
      class Bar : public FooObj {     // Ok.  Base class is Foo
      ...
      };

Similarly, ``typedef`` allows unnamed structures to be used as base
classes. For example:

.. container:: code

   ::

      typedef struct {
        ...
      } Foo;

      class Bar : public Foo {    // Ok. 
      ...
      };

**Compatibility Note:** Starting in version 1.3.7, SWIG only generates
low-level accessor wrappers for the declarations that are actually
defined in each class. This differs from SWIG1.1 which used to inherit
all of the declarations defined in base classes and regenerate
specialized accessor functions such as ``Circle_x_get()``,
``Square_x_get()``, ``Circle_set_location()``, and
``Square_set_location()``. This behavior resulted in huge amounts of
replicated code for large class hierarchies and made it awkward to build
applications spread across multiple modules (since accessor functions
are duplicated in every single module). It is also unnecessary to have
such wrappers when advanced features like proxy classes are used.
**Note:** Further optimizations are enabled when using the ``-fvirtual``
option, which avoids the regenerating of wrapper functions for virtual
members that are already defined in a base class.

A brief discussion of multiple inheritance, pointers, and type checking
----------------------------------------------------------------------------

When a target scripting language refers to a C++ object, it normally
uses a tagged pointer object that contains both the value of the pointer
and a type string. For example, in Tcl, a C++ pointer might be encoded
as a string like this:

.. container:: diagram

   ::

      _808fea88_p_Circle

A somewhat common question is whether or not the type-tag could be
safely removed from the pointer. For instance, to get better
performance, could you strip all type tags and just use simple integers
instead?

In general, the answer to this question is no. In the wrappers, all
pointers are converted into a common data representation in the target
language. Typically this is the equivalent of casting a pointer to
``void *``. This means that any C++ type information associated with the
pointer is lost in the conversion.

The problem with losing type information is that it is needed to
properly support many advanced C++ features--especially multiple
inheritance. For example, suppose you had code like this:

.. container:: code

   ::

      class A {
      public:
        int x;
      };

      class B {
      public:
        int y;
      };

      class C : public A, public B {
      };

      int A_function(A *a) {
        return a->x;
      }

      int B_function(B *b) {
        return b->y;
      }

Now, consider the following code that uses ``void *``.

.. container:: code

   ::

      C *c = new C();
      void *p = (void *) c;
      ...
      int x = A_function((A *) p);
      int y = B_function((B *) p);

In this code, both ``A_function()`` and ``B_function()`` may legally
accept an object of type ``C *`` (via inheritance). However, one of the
functions will always return the wrong result when used as shown. The
reason for this is that even though ``p`` points to an object of type
``C``, the casting operation doesn't work like you would expect.
Internally, this has to do with the data representation of ``C``. With
multiple inheritance, the data from each base class is stacked together.
For example:

.. container:: diagram

   ::

                   ------------    <--- (C *),  (A *)
                  |     A      |
                  |------------|   <--- (B *)
                  |     B      |
                   ------------   

Because of this stacking, a pointer of type ``C *`` may change value
when it is converted to a ``A *`` or ``B *``. However, this adjustment
does *not* occur if you are converting from a ``void *``.

The use of type tags marks all pointers with the real type of the
underlying object. This extra information is then used by SWIG generated
wrappers to correctly cast pointer values under inheritance (avoiding
the above problem).

Some of the language modules are able to solve the problem by storing
multiple instances of the pointer, for example, ``A *``, in the A proxy
class as well as ``C *`` in the C proxy class. The correct cast can then
be made by choosing the correct ``void *`` pointer to use and is
guaranteed to work as the cast to a void pointer and back to the same
type does not lose any type information:

.. container:: code

   ::

      C *c = new C();
      void *p = (void *) c;
      void *pA = (void *) c;
      void *pB = (void *) c;
      ...
      int x = A_function((A *) pA);
      int y = B_function((B *) pB);

In practice, the pointer is held as an integral number in the target
language proxy class.

Default arguments
----------------------

SWIG will wrap all types of functions that have default arguments. For
example member functions:

.. container:: code

   ::

      class Foo {
      public:
        void bar(int x, int y = 3, int z = 4);
      };

SWIG handles default arguments by generating an extra overloaded method
for each defaulted argument. SWIG is effectively handling methods with
default arguments as if it was wrapping the equivalent overloaded
methods. Thus for the example above, it is as if we had instead given
the following to SWIG:

.. container:: code

   ::

      class Foo {
      public:
        void bar(int x, int y, int z);
        void bar(int x, int y);
        void bar(int x);
      };

The wrappers produced are exactly the same as if the above code was
instead fed into SWIG. Details of this are covered in the next section
`Overloaded functions and methods <#SWIGPlus_overloaded_methods>`__.
This approach allows SWIG to wrap all possible default arguments, but
can be verbose. For example if a method has ten default arguments, then
eleven wrapper methods are generated.

Please see the `Features and default
arguments <Customization.html#Customization_features_default_args>`__
section for more information on using ``%feature`` with functions with
default arguments. The `Renaming and ambiguity
resolution <#SWIGPlus_ambiguity_resolution_renaming>`__ section also
deals with using ``%rename`` and ``%ignore`` on methods with default
arguments. If you are writing your own typemaps for types used in
methods with default arguments, you may also need to write a
``typecheck`` typemap. See the `Typemaps and
overloading <Typemaps.html#Typemaps_overloading>`__ section for details
or otherwise use the ``compactdefaultargs`` feature flag as mentioned
below.

**Compatibility note:** Versions of SWIG prior to SWIG-1.3.23 wrapped
default arguments slightly differently. Instead a single wrapper method
was generated and the default values were copied into the C++ wrappers
so that the method being wrapped was then called with all the arguments
specified. If the size of the wrappers are a concern then this approach
to wrapping methods with default arguments can be re-activated by using
the ``compactdefaultargs`` `feature
flag <Customization.html#Customization_feature_flags>`__.

.. container:: code

   ::

      %feature("compactdefaultargs") Foo::bar;
      class Foo {
      public:
        void bar(int x, int y = 3, int z = 4);
      };

This is great for reducing the size of the wrappers, but the caveat is
it does not work for the statically typed languages, such as C# and
Java, which don't have optional arguments in the language, Another
restriction of this feature is that it cannot handle default arguments
that are not public. The following example illustrates this:

.. container:: code

   ::

      class Foo {
      private:
        static const int spam;
      public:
        void bar(int x, int y = spam);   // Won't work with %feature("compactdefaultargs") -
                                         // private default value
      };

This produces uncompilable wrapper code because default values in C++
are evaluated in the same scope as the member function whereas SWIG
evaluates them in the scope of a wrapper function (meaning that the
values have to be public).

The ``compactdefaultargs`` feature is automatically turned on when
wrapping `C code with default
arguments <SWIG.html#SWIG_default_args>`__. Some target languages will
also automatically turn on this feature if the keyword arguments feature
(kwargs) is specified for either C or C++ functions, and the target
language supports kwargs, the ``compactdefaultargs`` feature is also
automatically turned on. Keyword arguments are a language feature of
some scripting languages, for example Ruby and Python. SWIG is unable to
support kwargs when wrapping overloaded methods, so the default approach
cannot be used.

Overloaded functions and methods
-------------------------------------

In many language modules, SWIG provides partial support for overloaded
functions, methods, and constructors. For example, if you supply SWIG
with overloaded functions like this:

.. container:: code

   ::

      void foo(int x) {
        printf("x is %d\n", x);
      }
      void foo(char *x) {
        printf("x is '%s'\n", x);
      }

The function is used in a completely natural way. For example:

.. container:: targetlang

   ::

      >>> foo(3)
      x is 3
      >>> foo("hello")
      x is 'hello'
      >>>

Overloading works in a similar manner for methods and constructors. For
example if you have this code,

.. container:: code

   ::

      class Foo {
      public:
        Foo();
        Foo(const Foo &);   // Copy constructor
        void bar(int x);
        void bar(char *s, int y);
      };

it might be used like this

.. container:: targetlang

   ::

      >>> f = Foo()          # Create a Foo
      >>> f.bar(3)
      >>> g = Foo(f)         # Copy Foo
      >>> f.bar("hello", 2)

Dispatch function generation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The implementation of overloaded functions and methods is somewhat
complicated due to the dynamic nature of scripting languages. Unlike
C++, which binds overloaded methods at compile time, SWIG must determine
the proper function as a runtime check for scripting language targets.
This check is further complicated by the typeless nature of certain
scripting languages. For instance, in Tcl, all types are simply strings.
Therefore, if you have two overloaded functions like this,

.. container:: code

   ::

      void foo(char *x);
      void foo(int x);

the order in which the arguments are checked plays a rather critical
role.

For statically typed languages, SWIG uses the language's method
overloading mechanism. To implement overloading for the scripting
languages, SWIG generates a dispatch function that checks the number of
passed arguments and their types. To create this function, SWIG first
examines all of the overloaded methods and ranks them according to the
following rules:

#. **Number of required arguments.** Methods are sorted by increasing
   number of required arguments.

#. **Argument type precedence.** All C++ datatypes are assigned a
   numeric type precedence value (which is determined by the language
   module).

   .. container:: diagram

      ::

         Type              Precedence
         ----------------  ----------
         TYPE *            0     (High)
         void *            20
         Integers          40
         Floating point    60
         char              80
         Strings           100   (Low)

   Using these precedence values, overloaded methods with the same
   number of required arguments are sorted in increased order of
   precedence values.

This may sound very confusing, but an example will help. Consider the
following collection of overloaded methods:

.. container:: code

   ::

      void foo(double);
      void foo(int);
      void foo(Bar *);
      void foo();
      void foo(int x, int y, int z, int w);
      void foo(int x, int y, int z = 3);
      void foo(double x, double y);
      void foo(double x, Bar *z);

The first rule simply ranks the functions by required argument count.
This would produce the following list:

.. container:: diagram

   ::

      rank
      -----
      [0]   foo()
      [1]   foo(double);
      [2]   foo(int);
      [3]   foo(Bar *);
      [4]   foo(int x, int y, int z = 3);
      [5]   foo(double x, double y)
      [6]   foo(double x, Bar *z)
      [7]   foo(int x, int y, int z, int w);

The second rule, simply refines the ranking by looking at argument type
precedence values.

.. container:: diagram

   ::

      rank
      -----
      [0]   foo()
      [1]   foo(Bar *);
      [2]   foo(int);
      [3]   foo(double);
      [4]   foo(int x, int y, int z = 3);
      [5]   foo(double x, Bar *z)
      [6]   foo(double x, double y)
      [7]   foo(int x, int y, int z, int w);

Finally, to generate the dispatch function, the arguments passed to an
overloaded method are simply checked in the same order as they appear in
this ranking.

If you're still confused, don't worry about it---SWIG is probably doing
the right thing.

Ambiguity in overloading
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Regrettably, SWIG is not able to support every possible use of valid C++
overloading. Consider the following example:

.. container:: code

   ::

      void foo(int x);
      void foo(long x);

In C++, this is perfectly legal. However, in a scripting language, there
is generally only one kind of integer object. Therefore, which one of
these functions do you pick? Clearly, there is no way to truly make a
distinction just by looking at the value of the integer itself (``int``
and ``long`` may even be the same precision). Therefore, when SWIG
encounters this situation, it may generate a warning message like this
for scripting languages:

.. container:: shell

   ::

      example.i:4: Warning 509: Overloaded method foo(long) effectively ignored,
      example.i:3: Warning 509: as it is shadowed by foo(int).

or for statically typed languages like Java:

.. container:: shell

   ::

      example.i:4: Warning 516: Overloaded method foo(long) ignored,
      example.i:3: Warning 516: using foo(int) instead.
      at example.i:3 used.

This means that the second overloaded function will be inaccessible from
a scripting interface or the method won't be wrapped at all. This is
done as SWIG does not know how to disambiguate it from an earlier
method.

Ambiguity problems are known to arise in the following situations:

-  Integer conversions. Datatypes such as ``int``, ``long``, and
   ``short`` cannot be disambiguated in some languages. Shown above.
-  Floating point conversion. ``float`` and ``double`` can not be
   disambiguated in some languages.
-  Pointers and references. For example, ``Foo *`` and ``Foo &``.
-  Pointers and arrays. For example, ``Foo *`` and ``Foo [4]``.
-  Pointers and instances. For example, ``Foo`` and ``Foo *``. Note:
   SWIG converts all instances to pointers.
-  Qualifiers. For example, ``const Foo *`` and ``Foo *``.
-  Default vs. non default arguments. For example, ``foo(int a, int b)``
   and ``foo(int a, int b = 3)``.

When an ambiguity arises, methods are checked in the same order as they
appear in the interface file. Therefore, earlier methods will shadow
methods that appear later.

When wrapping an overloaded function, there is a chance that you will
get a warning message like this:

.. container:: shell

   ::

      example.i:3: Warning 467: Overloaded foo(int) not supported (incomplete type checking rule - 
      no precedence level in typecheck typemap for 'int').

This error means that the target language module supports overloading,
but for some reason there is no type-checking rule that can be used to
generate a working dispatch function. The resulting behavior is then
undefined. You should report this as a bug to the `SWIG bug tracking
database <http://www.swig.org/bugs.html>`__ if this is due to one of the
typemaps supplied with SWIG.

If you get an error message such as the following,

.. container:: shell

   ::

      foo.i:6. Overloaded declaration ignored.  Spam::foo(double )
      foo.i:5. Previous declaration is Spam::foo(int )
      foo.i:7. Overloaded declaration ignored.  Spam::foo(Bar *, Spam *, int )
      foo.i:5. Previous declaration is Spam::foo(int )

it means that the target language module has not yet implemented support
for overloaded functions and methods. The only way to fix the problem is
to read the next section.

Renaming and ambiguity resolution
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If an ambiguity in overload resolution occurs or if a module doesn't
allow overloading, there are a few strategies for dealing with the
problem. First, you can tell SWIG to ignore one of the methods. This is
easy---simply use the ``%ignore`` directive. For example:

.. container:: code

   ::

      %ignore foo(long);

      void foo(int);
      void foo(long);       // Ignored.  Oh well.

The other alternative is to rename one of the methods. This can be done
using ``%rename``. For example:

.. container:: code

   ::

      %rename("foo_short") foo(short);
      %rename(foo_long) foo(long);

      void foo(int);
      void foo(short);      // Accessed as foo_short()
      void foo(long);       // Accessed as foo_long()

Note that the quotes around the new name are optional, however, should
the new name be a C/C++ keyword they would be essential in order to
avoid a parsing error. The ``%ignore`` and ``%rename`` directives are
both rather powerful in their ability to match declarations. When used
in their simple form, they apply to both global functions and methods.
For example:

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

If you only want the renaming to apply to a certain scope, the C++ scope
resolution operator (::) can be used. For example:

.. container:: code

   ::

      %rename(foo_i) ::foo(int);      // Only rename foo(int) in the global scope.
                                      // (will not rename class members)

      %rename(foo_i) Spam::foo(int);  // Only rename foo(int) in class Spam

When a renaming operator is applied to a class as in ``Spam::foo(int)``,
it is applied to that class and all derived classes. This can be used to
apply a consistent renaming across an entire class hierarchy with only a
few declarations. For example:

.. container:: code

   ::

      %rename(foo_i) Spam::foo(int);
      %rename(foo_d) Spam::foo(double);

      class Spam {
      public:
        virtual void foo(int);      // Renamed to foo_i
        virtual void foo(double);   // Renamed to foo_d
        ...
      };

      class Bar : public Spam {
      public:
        virtual void foo(int);      // Renamed to foo_i
        virtual void foo(double);   // Renamed to foo_d
        ...
      };

      class Grok : public Bar {
      public:
        virtual void foo(int);      // Renamed to foo_i
        virtual void foo(double);   // Renamed to foo_d
        ...
      };

It is also possible to include ``%rename`` specifications in the class
definition itself. For example:

.. container:: code

   ::

      class Spam {
        %rename(foo_i) foo(int);
        %rename(foo_d) foo(double);
      public:
        virtual void foo(int);      // Renamed to foo_i
        virtual void foo(double);   // Renamed to foo_d
        ...
      };

      class Bar : public Spam {
      public:
        virtual void foo(int);      // Renamed to foo_i
        virtual void foo(double);   // Renamed to foo_d
      ...
      };

In this case, the ``%rename`` directives still get applied across the
entire inheritance hierarchy, but it's no longer necessary to explicitly
specify the class prefix ``Spam::``.

A special form of ``%rename`` can be used to apply a renaming just to
class members (of all classes):

.. container:: code

   ::

      %rename(foo_i) *::foo(int);   // Only rename foo(int) if it appears in a class.

Note: the ``*::`` syntax is non-standard C++, but the '*' is meant to be
a wildcard that matches any class name (we couldn't think of a better
alternative so if you have a better idea, send email to the `swig-devel
mailing list <http://www.swig.org/mail.html>`__.

Although this discussion has primarily focused on ``%rename`` all of the
same rules also apply to ``%ignore``. For example:

.. container:: code

   ::

      %ignore foo(double);          // Ignore all foo(double)
      %ignore Spam::foo;            // Ignore foo in class Spam
      %ignore Spam::foo(double);    // Ignore foo(double) in class Spam
      %ignore *::foo(double);       // Ignore foo(double) in all classes

When applied to a base class, ``%ignore`` forces all definitions in
derived classes to disappear. For example, ``%ignore Spam::foo(double)``
will eliminate ``foo(double)`` in ``Spam`` and all classes derived from
``Spam``.

**Notes on %rename and %ignore:**

-  Since, the ``%rename`` declaration is used to declare a renaming in
   advance, it can be placed at the start of an interface file. This
   makes it possible to apply a consistent name resolution without
   having to modify header files. For example:

   .. container:: code

      ::

         %module foo

         /* Rename these overloaded functions */
         %rename(foo_i) foo(int); 
         %rename(foo_d) foo(double);

         %include "header.h"

-  The scope qualifier (::) can also be used on simple names. For
   example:

   .. container:: code

      ::

         %rename(bar) ::foo;       // Rename foo to bar in global scope only
         %rename(bar) Spam::foo;   // Rename foo to bar in class Spam only
         %rename(bar) *::foo;      // Rename foo in classes only

-  Name matching tries to find the most specific match that is defined.
   A qualified name such as ``Spam::foo`` always has higher precedence
   than an unqualified name ``foo``. ``Spam::foo`` has higher precedence
   than ``*::foo`` and ``*::foo`` has higher precedence than ``foo``. A
   parameterized name has higher precedence than an unparameterized name
   within the same scope level. However, an unparameterized name with a
   scope qualifier has higher precedence than a parameterized name in
   global scope (e.g., a renaming of ``Spam::foo`` takes precedence over
   a renaming of ``foo(int)``).

-  The order in which ``%rename`` directives are defined does not matter
   as long as they appear before the declarations to be renamed. Thus,
   there is no difference between saying:

   .. container:: code

      ::

         %rename(bar) foo;
         %rename(foo_i) Spam::foo(int);
         %rename(Foo) Spam::foo;

   and this

   .. container:: code

      ::

         %rename(Foo) Spam::foo;
         %rename(bar) foo;
         %rename(foo_i) Spam::foo(int);

   (the declarations are not stored in a linked list and order has no
   importance). Of course, a repeated ``%rename`` directive will change
   the setting for a previous ``%rename`` directive if exactly the same
   name, scope, and parameters are supplied.

-  For multiple inheritance where renaming rules are defined for
   multiple base classes, the first renaming rule found on a depth-first
   traversal of the class hierarchy is used.

-  The name matching rules strictly follow member qualifier rules. For
   example, if you have a class and member with a member that is const
   qualified like this:

   .. container:: code

      ::

         class Spam {
         public:
           ...
           void bar() const;
           ...
         };

   the declaration

   .. container:: code

      ::

         %rename(name) Spam::bar();

   will not apply as there is no unqualified member ``bar()``. The
   following will apply the rename as the qualifier matches correctly:

   .. container:: code

      ::

         %rename(name) Spam::bar() const;

   Similarly for combinations of cv-qualifiers and ref-qualifiers, all
   the qualifiers must be specified to match correctly:

   .. container:: code

      ::

         %rename(name) Jam::bar();          // will not match
         %rename(name) Jam::bar() &;        // will not match
         %rename(name) Jam::bar() const;    // will not match
         %rename(name) Jam::bar() const &;  // ok, will match

         class Jam {
         public:
           ...
           void bar() const &;
           ...
         };

   An often overlooked C++ feature is that classes can define two
   different overloaded members that differ only in their qualifiers,
   like this:

   .. container:: code

      ::

         class Spam {
         public:
           ...
           void bar();         // Unqualified member
           void bar() const;   // Qualified member
           ...
         };

   %rename can then be used to target each of the overloaded methods
   individually. For example we can give them separate names in the
   target language:

   .. container:: code

      ::

         %rename(name1) Spam::bar();
         %rename(name2) Spam::bar() const;

   Similarly, if you merely wanted to ignore one of the declarations,
   use ``%ignore`` with the full qualifier. For example, the following
   directive would tell SWIG to ignore the ``const`` version of
   ``bar()`` above:

   .. container:: code

      ::

         %ignore Spam::bar() const;   // Ignore bar() const, but leave other bar() alone

-  Currently no resolution is performed in order to match function
   parameters. This means function parameter types must match exactly.
   For example, namespace qualifiers and typedefs will not work. The
   following usage of typedefs demonstrates this:

   .. container:: code

      ::

         typedef int Integer;

         %rename(foo_i) foo(int);

         class Spam {
         public:
           void foo(Integer);  // Stays 'foo' (not renamed)
         };
         class Ham {
         public:
           void foo(int);      // Renamed to foo_i
         };

-  The name matching rules also use default arguments for finer control
   when wrapping methods that have default arguments. Recall that
   methods with default arguments are wrapped as if the equivalent
   overloaded methods had been parsed (`Default
   arguments <#SWIGPlus_default_args>`__ section). Let's consider the
   following example class:

   .. container:: code

      ::

         class Spam {
         public:
           ...
           void bar(int i=-1, double d=0.0);
           ...
         };

   The following ``%rename`` will match exactly and apply to all the
   target language overloaded methods because the declaration with the
   default arguments exactly matches the wrapped method:

   .. container:: code

      ::

         %rename(newbar) Spam::bar(int i=-1, double d=0.0);

   The C++ method can then be called from the target language with the
   new name no matter how many arguments are specified, for example:
   ``newbar(2, 2.0)``, ``newbar(2)`` or ``newbar()``. However, if the
   ``%rename`` does not contain the default arguments:

   .. container:: code

      ::

         %rename(newbar) Spam::bar(int i, double d);

   then only one of the three equivalent overloaded methods will be
   renamed and wrapped as if SWIG parsed:

   .. container:: code

      ::

         void Spam::newbar(int i, double d);
         void Spam::bar(int i);
         void Spam::bar();

   The C++ method must then be called from the target language with the
   new name ``newbar(2, 2.0)`` when both arguments are supplied or with
   the original name as ``bar(2)`` (one argument) or ``bar()`` (no
   arguments).

   In fact it is possible to use ``%rename`` on the equivalent
   overloaded methods, to rename all the equivalent overloaded methods:

   .. container:: code

      ::

         %rename(bar_2args)   Spam::bar(int i, double d);
         %rename(bar_1arg)    Spam::bar(int i);
         %rename(bar_default) Spam::bar();

   Similarly, the extra overloaded methods can be selectively ignored
   using ``%ignore``.

   **Compatibility note:** The ``%rename`` directive introduced the
   default argument matching rules in SWIG-1.3.23 at the same time as
   the changes to wrapping methods with default arguments was
   introduced.

Comments on overloading
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Support for overloaded methods was first added in SWIG-1.3.14. The
implementation is somewhat unusual when compared to similar tools. For
instance, the order in which declarations appear is largely irrelevant
in SWIG. Furthermore, SWIG does not rely upon trial execution or
exception handling to figure out which method to invoke.

Internally, the overloading mechanism is completely configurable by the
target language module. Therefore, the degree of overloading support may
vary from language to language. As a general rule, statically typed
languages like Java are able to provide more support than dynamically
typed languages like Perl, Python, Ruby, and Tcl.

Overloaded operators
-------------------------

C++ overloaded operator declarations can be wrapped. For example,
consider a class like this:

.. container:: code

   ::

      class Complex {
      private:
        double rpart, ipart;
      public:
        Complex(double r = 0, double i = 0) : rpart(r), ipart(i) { }
        Complex(const Complex &c) : rpart(c.rpart), ipart(c.ipart) { }
        Complex &operator=(const Complex &c) {
          rpart = c.rpart;
          ipart = c.ipart;
          return *this;
        }
        Complex operator+(const Complex &c) const {
          return Complex(rpart+c.rpart, ipart+c.ipart);
        }
        Complex operator-(const Complex &c) const {
          return Complex(rpart-c.rpart, ipart-c.ipart);
        }
        Complex operator*(const Complex &c) const {
          return Complex(rpart*c.rpart - ipart*c.ipart,
                         rpart*c.ipart + c.rpart*ipart);
        }
        Complex operator-() const {
          return Complex(-rpart, -ipart);
        }
        double re() const { return rpart; }
        double im() const { return ipart; }
      };

When operator declarations appear, they are handled in *exactly* the
same manner as regular methods. However, the names of these methods are
set to strings like "``operator +``" or "``operator -``". The problem
with these names is that they are illegal identifiers in most scripting
languages. For instance, you can't just create a method called
"``operator +``" in Python--there won't be any way to call it.

Some language modules already know how to automatically handle certain
operators (mapping them into operators in the target language). However,
the underlying implementation of this is really managed in a very
general way using the ``%rename`` directive. For example, in Python a
declaration similar to this is used:

.. container:: code

   ::

      %rename(__add__) Complex::operator+;

This binds the + operator to a method called ``__add__`` (which is
conveniently the same name used to implement the Python + operator).
Internally, the generated wrapper code for a wrapped operator will look
something like this pseudocode:

.. container:: code

   ::

      _wrap_Complex___add__(args) {
        ... get args ...
        obj->operator+(args);
        ...
      }

When used in the target language, it may now be possible to use the
overloaded operator normally. For example:

.. container:: targetlang

   ::

      >>> a = Complex(3, 4)
      >>> b = Complex(5, 2)
      >>> c = a + b           # Invokes __add__ method

It is important to realize that there is nothing magical happening here.
The ``%rename`` directive really only picks a valid method name. If you
wrote this:

.. container:: code

   ::

      %rename(add) operator+;

The resulting scripting interface might work like this:

.. container:: targetlang

   ::

      a = Complex(3, 4)
      b = Complex(5, 2)
      c = a.add(b)      # Call a.operator+(b)

All of the techniques described to deal with overloaded functions also
apply to operators. For example:

.. container:: code

   ::

      %ignore Complex::operator=;             // Ignore = in class Complex
      %ignore *::operator=;                   // Ignore = in all classes
      %ignore operator=;                      // Ignore = everywhere.

      %rename(__sub__) Complex::operator-; 
      %rename(__neg__) Complex::operator-();  // Unary - 

The last part of this example illustrates how multiple definitions of
the ``operator-`` method might be handled.

Handling operators in this manner is mostly straightforward. However,
there are a few subtle issues to keep in mind:

-  In C++, it is fairly common to define different versions of the
   operators to account for different types. For example, a class might
   also include a friend function like this:

   .. container:: code

      ::

         class Complex {
         public:
           friend Complex operator+(Complex &, double);
         };
         Complex operator+(Complex &, double);

   SWIG simply ignores all ``friend`` declarations. Furthermore, it
   doesn't know how to associate the associated ``operator+`` with the
   class (because it's not a member of the class).

   It's still possible to make a wrapper for this operator, but you'll
   have to handle it like a normal function. For example:

   .. container:: code

      ::

         %rename(add_complex_double) operator+(Complex &, double);

-  Certain operators are ignored by default. For instance, ``new`` and
   ``delete`` operators are ignored as well as conversion and index
   operators. A warning such as the one below is shown:

   .. container:: shell

      ::

         example.i:12: Warning 503: Can't wrap 'operator []' unless renamed to a valid identifier.

-  The index operator, ``operator[]``, is particularly difficult to
   overload due to differences in C++ implementations. Specifically, the
   get and set operators in other languages typically are separated into
   two methods such that additional logic can be packed into the
   operations; C# uses ``this[type key] { get { ... } set { ... }}``,
   Python uses ``__getitem__`` and ``__setitem__``, etc. In C++ if the
   return type of ``operator[]`` is a reference and the method is const,
   it is often indicative of the *setter*, and the *getter* is usually a
   const function return an object by value. In the absence of any hard
   and fast rules and the fact that there may be multiple index
   operators, it is up to the user to choose the getter and setter to
   use by using %rename as shown earlier.

-  The semantics of certain C++ operators may not match those in the
   target language.

Class extension
--------------------

New methods can be added to a class using the ``%extend`` directive.
This directive is primarily used in conjunction with proxy classes to
add additional functionality to an existing class. For example :

.. container:: code

   ::

      %module vector
      %{
      #include "vector.h"
      %}

      class Vector {
      public:
        double x, y, z;
        Vector();
        ~Vector();
        ... bunch of C++ methods ...
        %extend {
          char *__str__() {
            static char temp[256];
            sprintf(temp, "[ %g, %g, %g ]", $self->x, $self->y, $self->z);
            return &temp[0];
          }
        }
      };

This code adds a ``__str__`` method to our class for producing a string
representation of the object. In Python, such a method would allow us to
print the value of an object using the ``print`` command.

.. container:: targetlang

   ::

      >>>
      >>> v = Vector();
      >>> v.x = 3
      >>> v.y = 4
      >>> v.z = 0
      >>> print(v)
      [ 3.0, 4.0, 0.0 ]
      >>>

The C++ 'this' pointer is often needed to access member variables,
methods etc. The ``$self`` special variable should be used wherever you
could use 'this'. The example above demonstrates this for accessing
member variables. Note that the members dereferenced by ``$self`` must
be public members as the code is ultimately generated into a global
function and so will not have any access to non-public members. The
implicit 'this' pointer that is present in C++ methods is not present in
``%extend`` methods. In order to access anything in the extended class
or its base class, an explicit 'this' is required. The following example
shows how one could access base class members:

.. container:: code

   ::

      struct Base {
        virtual void method(int v) {
          ...
        }
        int value;
      };
      struct Derived : Base {
      };
      %extend Derived {
        virtual void method(int v) {
          $self->Base::method(v); // akin to this->Base::method(v);
          $self->value = v;       // akin to this->value = v;
          ...
        }
      }

The following special variables are expanded if used within a %extend
block: $name, $symname, $overname, $decl, $fulldecl, $parentclassname
and $parentclasssymname. The `Special
variables <Customization.html#Customization_exception_special_variables>`__
section provides more information each of these special variables.

The ``%extend`` directive follows all of the same conventions as its use
with C structures. Please refer to the `Adding member functions to C
structures <SWIG.html#SWIG_adding_member_functions>`__ section for
further details.

**Compatibility note:** The ``%extend`` directive is a new name for the
``%addmethods`` directive in SWIG1.1. Since ``%addmethods`` could be
used to extend a structure with more than just methods, a more suitable
directive name has been chosen.

Templates
--------------

Template type names may appear anywhere a type is expected in an
interface file. For example:

.. container:: code

   ::

      void foo(vector<int> *a, int n);
      void bar(list<int, 100> *x);

There are some restrictions on the use of non-type arguments. Simple
literals are supported, and so are some constant expressions. However,
use of '<' and '>' within a constant expressions currently is not
supported by SWIG ('<=' and '>=' are though). For example:

.. container:: code

   ::

      void bar(list<int, 100> *x);                // OK
      void bar(list<int, 2*50> *x);               // OK
      void bar(list<int, (2>1 ? 100 : 50)> *x)    // Not supported

The type system is smart enough to figure out clever games you might try
to play with ``typedef``. For instance, consider this code:

.. container:: code

   ::

      typedef int Integer;
      void foo(vector<int> *x, vector<Integer> *y);

In this case, ``vector<Integer>`` is exactly the same type as
``vector<int>``. The wrapper for ``foo()`` will accept either variant.

The %template directive
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are a couple of important points about template wrapping. First, a
bare C++ template does not define any sort of runnable object-code for
which SWIG can normally create a wrapper. Therefore, in order to wrap a
template, you need to give SWIG information about a particular template
instantiation (e.g., ``vector<int>``, ``array<double>``, etc.). Second,
an instantiation name such as ``vector<int>`` is generally not a valid
identifier name in most target languages. Thus, you will need to give
the template instantiation a more suitable name such as ``intvector``.

To illustrate, consider the following class template definition:

.. container:: code

   ::

      template<class T> class List {
      private:
        T *data;
        int nitems;
        int maxitems;
      public:
        List(int max) {
          data = new T [max];
          nitems = 0;
          maxitems = max;
        }
        ~List() {
          delete [] data;
        };
        void append(T obj) {
          if (nitems < maxitems) {
            data[nitems++] = obj;
          }
        }
        int length() {
          return nitems;
        }
        T get(int n) {
          return data[n];
        }
      };

By itself, this class template is useless--SWIG simply ignores it
because it doesn't know how to generate any code unless a definition of
``T`` is provided. The ``%template`` directive is required to
instantiate the template for use in a target language. The directive
requires an identifier name for use in the target language plus the
template for instantiation. The example below instantiates ``List<int>``
for use as a class named ``intList``:

.. container:: code

   ::

      %template(intList) List<int>;

The instantiation expands the template code as a C++ compiler would do
and then makes it available under the given identifier name. Essentially
it is the same as wrapping the following concept code where the class
template definition has ``T`` expanded to ``int`` (note that this is not
entirely valid syntax):

.. container:: code

   ::

      %rename(intList) List<int>;       // Rename to a suitable identifier
      class List<int> {
      private:
        int *data;
        int nitems;
        int maxitems;
      public:
        List(int max);
        ~List();
        void append(int obj);
        int length();
        int get(int n);
      };

The argument to ``%template()`` is the name of the instantiation in the
target language. The name you choose should not conflict with any other
declarations in the interface file with one exception---it is okay for
the template name to match that of a typedef declaration. For example:

.. container:: code

   ::

      %template(intList) List<int>;
      ...
      typedef List<int> intList;    // OK

The ``%template`` directive must always appear *after* the definition of
the template to be expanded, so the following will work:

.. container:: code

   ::

      template<class T> class List { ... };
      %template(intList) List<int>;

but if %template is used before the template definition, such as:

.. container:: code

   ::

      %template(intList) List<int>;
      template<class T> class List { ... };

SWIG will generate an error:

.. container:: shell

   ::

      example.i:3: Error: Template 'List' undefined.

Since the type system knows how to handle ``typedef``, it is generally
not necessary to instantiate different versions of a template for
typenames that are equivalent. For instance, consider this code:

.. container:: code

   ::

      %template(intList) List<int>;
      typedef int Integer;
      ...
      void foo(List<Integer> *x);

In this case, ``List<Integer>`` is exactly the same type as
``List<int>``. Any use of ``List<Integer>`` is mapped back to the
instantiation of ``List<int>`` created earlier. Therefore, it is not
necessary to instantiate a new class for the type ``Integer`` (doing so
is redundant and will simply result in code bloat).

The template provided to ``%template`` for instantiation must be the
actual template and not a typedef to a template.

.. container:: code

   ::

      typedef List<int> ListOfInt;

      %template(intList) List<int>; // ok
      %template(intList) ListOfInt; // illegal - Syntax error

Function templates
~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG can also generate wrappers for function templates using a similar
technique to that shown above for class templates. For example:

.. container:: code

   ::

      // Function template
      template<class T> T max(T a, T b) { return a > b ? a : b; }

      // Make some different versions of this function
      %template(maxint) max<int>;
      %template(maxdouble) max<double>;

In this case, ``maxint`` and ``maxdouble`` become unique names for
specific instantiations of the function.

SWIG even supports overloaded templated functions. As usual the
``%template`` directive is used to wrap templated functions. For
example:

.. container:: code

   ::

      template<class T> void foo(T x) { };
      template<class T> void foo(T x, T y) { };

      %template(foo) foo<int>;

This will generate two overloaded wrapper methods, the first will take a
single integer as an argument and the second will take two integer
arguments.

Default template arguments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The number of arguments supplied to ``%template`` should match that in
the original template definition. Template default arguments are
supported. For example:

.. container:: code

   ::

      template vector<typename T, int max=100> class vector {
      ...
      };

      %template(intvec) vector<int>;           // OK
      %template(vec1000) vector<int, 1000>;     // OK

The ``%template`` directive should not be used to wrap the same template
instantiation more than once in the same scope. This will generate an
error. For example:

.. container:: code

   ::

      %template(intList) List<int>;
      %template(Listint) List<int>;    // Error.   Template already wrapped.

This error is caused because the template expansion results in two
identical classes with the same name. This generates a symbol table
conflict. Besides, it probably more efficient to only wrap a specific
instantiation only once in order to reduce the potential for code bloat.

Template base classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When a template is instantiated using ``%template``, information about
that class is saved by SWIG and used elsewhere in the program. For
example, if you wrote code like this,

.. container:: code

   ::

      ...
      %template(intList) List<int>;
      ...
      class UltraList : public List<int> {
        ...
      };

then SWIG knows that ``List<int>`` was already wrapped as a class called
``intList`` and arranges to handle the inheritance correctly. If, on the
other hand, nothing is known about ``List<int>``, you will get a warning
message similar to this:

.. container:: shell

   ::

      example.h:42: Warning 401. Nothing known about class 'List< int >'. Ignored. 
      example.h:42: Warning 401. Maybe you forgot to instantiate 'List< int >' using %template. 

If a class template inherits from another class template, you need to
make sure that base classes are instantiated before derived classes. For
example:

.. container:: code

   ::

      template<class T> class Foo {
      ...
      };

      template<class T> class Bar : public Foo<T> {
      ...
      };

      // Instantiate base classes first 
      %template(intFoo) Foo<int>;
      %template(doubleFoo) Foo<double>;

      // Now instantiate derived classes
      %template(intBar) Bar<int>;
      %template(doubleBar) Bar<double>;

The order is important since SWIG uses the instantiation names to
properly set up the inheritance hierarchy in the resulting wrapper code
(and base classes need to be wrapped before derived classes). Don't
worry--if you get the order wrong, SWIG should generate a warning
message.

Occasionally, you may need to tell SWIG about base classes that are
defined by templates, but which aren't supposed to be wrapped. Since
SWIG is not able to automatically instantiate templates for this
purpose, you must do it manually. To do this, simply use the empty
template instantiation, that is, ``%template`` with no name. For
example:

.. container:: code

   ::

      // Instantiate traits<double, double>, but don't wrap it.
      %template() traits<double, double>;

If you have to instantiate a lot of different classes for many different
types, you might consider writing a SWIG macro. For example:

.. container:: code

   ::

      %define TEMPLATE_WRAP(prefix, T...) 
      %template(prefix ## Foo) Foo<T >;
      %template(prefix ## Bar) Bar<T >;
      ...
      %enddef

      TEMPLATE_WRAP(int, int)
      TEMPLATE_WRAP(double, double)
      TEMPLATE_WRAP(String, char *)
      TEMPLATE_WRAP(PairStringInt, std::pair<string, int>)
      ...

Note the use of a vararg macro for the type T. If this wasn't used, the
comma in the templated type in the last example would not be possible.

Template specialization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The SWIG template mechanism *does* support specialization. For instance,
if you define a class like this,

.. container:: code

   ::

      template<> class List<int> {
      private:
        int *data;
        int nitems;
        int maxitems;
      public:
        List(int max);
        ~List();
        void append(int obj);
        int length();
        int get(int n);
      };

then SWIG will use this code whenever the user expands ``List<int>``. In
practice, this may have very little effect on the underlying wrapper
code since specialization is often used to provide slightly modified
method bodies (which are ignored by SWIG). However, special SWIG
directives such as ``%typemap``, ``%extend``, and so forth can be
attached to a specialization to provide customization for specific
types.

Partial template specialization is partially supported by SWIG. For
example, this code defines a template that is applied when the template
argument is a pointer.

.. container:: code

   ::

      template<class T> class List<T*> {
      private:
        T *data;
        int nitems;
        int maxitems;
      public:
        List(int max);
        ~List();
        void append(T obj);
        int length();
        T get(int n);
      };

SWIG supports both template explicit specialization and partial
specialization. Consider:

.. container:: code

   ::

      template<class T1, class T2> class Foo { };                     // (1) primary template
      template<>                   class Foo<double *, int *> { };    // (2) explicit specialization
      template<class T1, class T2> class Foo<T1, T2 *> { };           // (3) partial specialization

SWIG is able to properly match explicit instantiations:

.. container:: code

   ::

      Foo<double *, int *>     // explicit specialization matching (2)

SWIG implements template argument deduction so that the following
partial specialization examples work just like they would with a C++
compiler:

.. container:: code

   ::

      Foo<int *, int *>        // partial specialization matching (3)
      Foo<int *, const int *>  // partial specialization matching (3)
      Foo<int *, int **>       // partial specialization matching (3)

Member templates
~~~~~~~~~~~~~~~~~~~~~~~

Member templates are supported. The underlying principle is the same as
for normal templates--SWIG can't create a wrapper unless you provide
more information about types. For example, a class with a member
function template might look like this:

.. container:: code

   ::

      class Foo {
      public:
        template<class T> void bar(T x, T y) { ... };
        ...
      };

To expand the template, simply use ``%template`` inside the class.

.. container:: code

   ::

      class Foo {
      public:
        template<class T> void bar(T x, T y) { ... };
        ...
        %template(barint)    bar<int>;
        %template(bardouble) bar<double>;
      };

Or, if you want to leave the original class definition alone, just do
this:

.. container:: code

   ::

      class Foo {
      public:
        template<class T> void bar(T x, T y) { ... };
        ...
      };
      ...
      %extend Foo {
        %template(barint)    bar<int>;
        %template(bardouble) bar<double>;
      };

or simply

.. container:: code

   ::

      class Foo {
      public:
        template<class T> void bar(T x, T y) { ... };
        ...
      };
      ...

      %template(bari) Foo::bar<int>;
      %template(bard) Foo::bar<double>;

In this case, the ``%extend`` directive is not needed, and ``%template``
does exactly the same job, i.e., it adds two new methods to the Foo
class.

Now, if your target language supports overloading, you can even try

.. container:: code

   ::

      %template(bar) Foo::bar<int>;
      %template(bar) Foo::bar<double>;

and since the two new wrapped methods have the same name 'bar', they
will be overloaded, and when called, the correct method will be
dispatched depending on the argument type.

When used with members, the ``%template`` directive may be placed in
another class template. Here is a slightly perverse example:

.. container:: code

   ::

      // A template
      template<class T> class Foo {
      public:
        // A member template
        template<class S> T bar(S x, S y) { ... };
        ...
      };

      // Expand a few member templates
      %extend Foo {
        %template(bari) bar<int>;
        %template(bard) bar<double>;
      }

      // Create some wrappers for the template
      %template(Fooi) Foo<int>;
      %template(Food) Foo<double>;

Miraculously, you will find that each expansion of ``Foo`` has member
functions ``bari()`` and ``bard()`` added.

A common use of member templates is to define constructors for copies
and conversions. For example:

.. container:: code

   ::

      template<class T1, class T2> struct pair {
        T1 first;
        T2 second;
        pair() : first(T1()), second(T2()) { }
        pair(const T1 &x, const T2 &y) : first(x), second(y) { }
        template<class U1, class U2> pair(const pair<U1, U2> &x)
                                             : first(x.first), second(x.second) { }
      };

This declaration is perfectly acceptable to SWIG, but the constructor
template will be ignored unless you explicitly expand it. To do that,
you could expand a few versions of the constructor in the class template
itself. For example:

.. container:: code

   ::

      %extend pair {
        %template(pair) pair<T1, T2>;        // Generate default copy constructor
      };

When using ``%extend`` in this manner, notice how you can still use the
template parameters in the original template definition.

Alternatively, you could expand the constructor template in selected
instantiations. For example:

.. container:: code

   ::

      // Instantiate a few versions
      %template(pairii) pair<int, int>;
      %template(pairdd) pair<double, double>;

      // Create a default constructor only 
      %extend pair<int, int> {
        %template(paird) pair<int, int>;         // Default constructor
      };

      // Create default and conversion constructors 
      %extend pair<double, double> {
        %template(paird) pair<double, dobule>;   // Default constructor
        %template(pairc) pair<int, int>;         // Conversion constructor
      };

And if your target language supports overloading, then you can try
instead:

.. container:: code

   ::

      // Create default and conversion constructors 
      %extend pair<double, double> {
        %template(pair) pair<double, dobule>;   // Default constructor
        %template(pair) pair<int, int>;         // Conversion constructor
      };

In this case, the default and conversion constructors have the same
name. Hence, SWIG will overload them and define an unique visible
constructor, that will dispatch the proper call depending on the
argument type.

Scoping and templates
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``%template`` directive for a class template is the equivalent to an
explicit instantiation of a C++ class template. The scope for a valid
``%template`` instantiation is the same as the scope required for a
valid explicit instantiation of a C++ template. A definition of the
template for the explicit instantiation must be in scope where the
instantiation is declared and must not be enclosed within a different
namespace.

For example, a few ``%template`` instantiations and C++ explicit
instantiations are shown below:

.. container:: code

   ::

      namespace N {
        template<typename T> class C {};
      }

      // valid
      %template(cin) N::C<int>;
      template class N::C<int>;

      // valid
      namespace N {
        %template(cin) C<int>;
        template class C<int>;
      }

      // valid
      using namespace N;
      %template(cin) C<int>;
      template class C<int>;

      // valid
      using N::C;
      %template(cin) C<int>;
      template class C<int>;

      // ill-formed
      namespace unrelated {
        using N::C;
        %template(cin) C<int>;
        template class C<int>;
      }

      // ill-formed
      namespace unrelated {
        using namespace N;
        %template(cin) C<int>;
        template class C<int>;
      }

      // ill-formed
      namespace unrelated {
        namespace N {
          %template(cin) C<int>;
          template class C<int>;
        }
      }

      // ill-formed
      namespace unrelated {
        %template(cin) N::C<int>;
        template class N::C<int>;
      }

When the scope is incorrect, such as for the ill-formed examples above,
an error occurs:

.. container:: shell

   ::

      cpp_template_scope.i:34: Error: 'C' resolves to 'N::C' and was incorrectly instantiated
      in scope 'unrelated' instead of within scope 'N'.

A note for the C++ standard geeks out there; a valid instantiation is
one which conforms to the C++03 standard as C++11 made a change to
disallow using declarations and using directives to find a template.

.. container:: code

   ::

      // valid C++03, ill-formed C++11
      using N::C;
      template class C<int>;

**Compatibility Note**: Versions prior to SWIG-4.0.0 did not error out
with incorrectly scoped ``%template`` declarations, but this led to
numerous subtle template scope problems.

More on templates
~~~~~~~~~~~~~~~~~~~~~~~~

If all of this isn't quite enough and you really want to make someone's
head explode, SWIG directives such as ``%rename``, ``%extend``, and
``%typemap`` can be included directly in template definitions. For
example:

.. container:: code

   ::

      // File : list.h
      template<class T> class List {
        ...
      public:
        %rename(__getitem__) get(int);
        List(int max);
        ~List();
        ...
        T get(int index);
        %extend {
          char *__str__() {
            /* Make a string representation */
            ...
          }
        }
      };

In this example, the extra SWIG directives are propagated to *every*
template instantiation.

It is also possible to separate these declarations from the class
template. For example:

.. container:: code

   ::

      %rename(__getitem__) List::get;
      %extend List {
        char *__str__() {
          /* Make a string representation */
          ...
        }
        /* Make a copy */
        T *__copy__() {
          return new List<T>(*$self);
        }
      };

      ...
      template<class T> class List {
        ...
        public:
        List() { }
        T get(int index);
        ...
      };

When ``%extend`` is decoupled from the class definition, it is legal to
use the same template parameters as provided in the class definition.
These are replaced when the template is expanded. In addition, the
``%extend`` directive can be used to add additional methods to a
specific instantiation. For example:

.. container:: code

   ::

      %template(intList) List<int>;

      %extend List<int> {
        void blah() {
          printf("Hey, I'm an List<int>!\n");
        }
      };

It is even possible to extend a class via ``%extend`` with template
methods, for example:

.. container:: code

   ::

      %include <std_string.i>

      %inline %{
      class ExtendMe {
      public:
        template <typename T>
        T do_stuff_impl(int a, T b, double d) {
          return b;
        }
      };
      %}

      %extend ExtendMe {
        template<typename T>
        T do_overloaded_stuff(T b) {
          return $self->do_stuff_impl(0, b, 4.0);
        }
      }
      %template(do_overloaded_stuff) ExtendMe::do_overloaded_stuff<std::string>;
      %template(do_overloaded_stuff) ExtendMe::do_overloaded_stuff<double>;

The wrapped ``ExtendMe`` class will then have two (overloaded) methods
called ``do_overloaded_stuff``.

**Compatibility Note**: Extending a class with template methods was
added in version 3.0.12

Needless to say, SWIG's template support provides plenty of
opportunities to break the universe. That said, an important final point
is that **SWIG does not perform extensive error checking of templates!**
Specifically, SWIG does not perform type checking nor does it check to
see if the actual contents of the template declaration make any sense.
Since the C++ compiler checks this when it compiles the resulting
wrapper file, there is no practical reason for SWIG to duplicate this
functionality.

As SWIG's template support does not perform type checking ``%template``
can be used as early as after a template declaration. You can, and
rarely have to, use ``%template`` before the template parameters have
been declared. For example:

.. container:: code

   ::

      template <class T> class OuterTemplateClass {};

      // The nested class OuterClass::InnerClass inherits from the class template
      // OuterTemplateClass<OuterClass::InnerStruct> and thus the template needs
      // to be expanded with %template before the OuterClass declaration.
      %template(OuterTemplateClass_OuterClass__InnerStruct)
        OuterTemplateClass<OuterClass::InnerStruct>


      // Don't forget to use %feature("flatnested") for OuterClass::InnerStruct and
      // OuterClass::InnerClass if the target language doesn't support nested classes.
      class OuterClass {
        public:
          // Forward declarations:
          struct InnerStruct;
          class InnerClass;
      };

      struct OuterClass::InnerStruct {};

      // Expanding the template at this point with %template is too late as the
      // OuterClass::InnerClass declaration is processed inside OuterClass.

      class OuterClass::InnerClass : public OuterTemplateClass<InnerStruct> {};

**Compatibility Note**: The first implementation of template support
relied heavily on macro expansion in the preprocessor. Templates have
been more tightly integrated into the parser and type system in
SWIG-1.3.12 and the preprocessor is no longer used. Code that relied on
preprocessing features in template expansion will no longer work.
However, SWIG still allows the # operator to be used to generate a
string from a template argument.

**Compatibility Note**: In earlier versions of SWIG, the ``%template``
directive introduced a new class name. This name could then be used with
other directives. For example:

.. container:: code

   ::

      %template(vectori) vector<int>;
      %extend vectori {
        void somemethod() { }
      };

This behavior is no longer supported. Instead, you should use the
original template name as the class name. For example:

.. container:: code

   ::

      %template(vectori) vector<int>;
      %extend vector<int> {
        void somemethod() { }
      };

Similar changes apply to typemaps and other customization features.

Namespaces
---------------

Support for C++ namespaces is comprehensive, but by default simple,
however, some target languages can turn on more advanced namespace
support via the `nspace feature <#SWIGPlus_nspace>`__, described later.
Code within unnamed namespaces is ignored as there is no external access
to symbols declared within the unnamed namespace. Before detailing the
default implementation for named namespaces, it is worth noting that the
semantics of C++ namespaces is extremely non-trivial--especially with
regard to the C++ type system and class machinery. At a most basic
level, namespaces are sometimes used to encapsulate common
functionality. For example:

.. container:: code

   ::

      namespace math {
        double sin(double);
        double cos(double);

        class Complex {
          double im, re;
        public:
          ...
        };
        ...
      };

Members of the namespace are accessed in C++ by prepending the namespace
prefix to names. For example:

.. container:: code

   ::

      double x = math::sin(1.0);
      double magnitude(math::Complex *c);
      math::Complex c;
      ...

At this level, namespaces are relatively easy to manage. However, things
start to get very ugly when you throw in the other ways a namespace can
be used. For example, selective symbols can be exported from a namespace
with ``using``.

.. container:: code

   ::

      using math::Complex;
      double magnitude(Complex *c);       // Namespace prefix stripped

Similarly, the contents of an entire namespace can be made available
like this:

.. container:: code

   ::

      using namespace math;
      double x = sin(1.0);
      double magnitude(Complex *c);

Alternatively, a namespace can be aliased:

.. container:: code

   ::

      namespace M = math;
      double x = M::sin(1.0);
      double magnitude(M::Complex *c);

Using combinations of these features, it is possible to write
head-exploding code like this:

.. container:: code

   ::

      namespace A {
        class Foo {
        };
      }

      namespace B {
        namespace C {
          using namespace A;
        }
        typedef C::Foo FooClass;
      }

      namespace BIGB = B;

      namespace D {
        using BIGB::FooClass;
        class Bar : public FooClass {
        }
      };

      class Spam : public D::Bar {
      };

      void evil(A::Foo *a, B::FooClass *b, B::C::Foo *c, BIGB::FooClass *d,
                BIGB::C::Foo *e, D::FooClass *f);

Given the possibility for such perversion, it's hard to imagine how
every C++ programmer might want such code wrapped into the target
language. Clearly this code defines three different classes. However,
one of those classes is accessible under at least six different names!

SWIG fully supports C++ namespaces in its internal type system and class
handling code. If you feed SWIG the above code, it will be parsed
correctly, it will generate compilable wrapper code, and it will produce
a working scripting language module. However, the default wrapping
behavior is to flatten namespaces in the target language. This means
that the contents of all namespaces are merged together in the resulting
scripting language module. For example, if you have code like this,

.. container:: code

   ::

      %module foo
      namespace foo {
        void bar(int);
        void spam();
      }

      namespace bar {
        void blah();
      }

then SWIG simply creates three wrapper functions ``bar()``, ``spam()``,
and ``blah()`` in the target language. SWIG does not prepend the names
with a namespace prefix nor are the functions packaged in any kind of
nested scope. Note that the default handling of flattening all the
namespace scopes in the target language can be changed via the `nspace
feature <#SWIGPlus_nspace>`__.

There is some rationale for taking this approach. Since C++ namespaces
are often used to define modules in C++, there is a natural correlation
between the likely contents of a SWIG module and the contents of a
namespace. For instance, it would not be unreasonable to assume that a
programmer might make a separate extension module for each C++
namespace. In this case, it would be redundant to prepend everything
with an additional namespace prefix when the module itself already
serves as a namespace in the target language. Or put another way, if you
want SWIG to keep namespaces separate, simply wrap each namespace with
its own SWIG interface.

Because namespaces are flattened, it is possible for symbols defined in
different namespaces to generate a name conflict in the target language.
For example:

.. container:: code

   ::

      namespace A {
        void foo(int);
      }
      namespace B {
        void foo(double);
      }

When this conflict occurs, you will get an error message that resembles
this:

.. container:: shell

   ::

      example.i:26. Error. 'foo' is multiply defined in the generated target language module.
      example.i:23. Previous declaration of 'foo'

To resolve this error, simply use ``%rename`` to disambiguate the
declarations. For example:

.. container:: code

   ::

      %rename(B_foo) B::foo;
      ...
      namespace A {
        void foo(int);
      }
      namespace B {
        void foo(double);     // Gets renamed to B_foo
      }

Similarly, ``%ignore`` can be used to ignore declarations.

``using`` declarations do not have any effect on the generated wrapper
code. They are ignored by SWIG language modules and they do not result
in any code. However, these declarations *are* used by the internal type
system to track type-names. Therefore, if you have code like this:

.. container:: code

   ::

      namespace A {
        typedef int Integer;
      }
      using namespace A;
      void foo(Integer x);

SWIG knows that ``Integer`` is the same as ``A::Integer`` which is the
same as ``int``.

Namespaces may be combined with templates. If necessary, the
``%template`` directive can be used to expand a template defined in a
different namespace. For example:

.. container:: code

   ::

      namespace foo {
        template<typename T> T max(T a, T b) { return a > b ? a : b; }
      }

      using foo::max;

      %template(maxint)   max<int>;           // Okay.
      %template(maxfloat) foo::max<float>;    // Okay (qualified name).

      namespace bar {
        using namespace foo;
        %template(maxdouble)  max<double>;    // Okay.
      }

The combination of namespaces and other SWIG directives may introduce
subtle scope-related problems. The key thing to keep in mind is that all
SWIG generated wrappers are produced in the *global* namespace. Symbols
from other namespaces are always accessed using fully qualified
names---names are never imported into the global space unless the
interface happens to do so with a ``using`` declaration. In almost all
cases, SWIG adjusts typenames and symbols to be fully qualified.
However, this is not done in code fragments such as function bodies,
typemaps, exception handlers, and so forth. For example, consider the
following:

.. container:: code

   ::

      namespace foo {
        typedef int Integer;
        class bar {
          public:
          ...
        };
      }

      %extend foo::bar {
        Integer add(Integer x, Integer y) {
          Integer r = x + y;        // Error. Integer not defined in this scope
          return r;
        }
      };

In this case, SWIG correctly resolves the added method parameters and
return type to ``foo::Integer``. However, since function bodies aren't
parsed and such code is emitted in the global namespace, this code
produces a compiler error about ``Integer``. To fix the problem, make
sure you use fully qualified names. For example:

.. container:: code

   ::

      %extend foo::bar {
        Integer add(Integer x, Integer y) {
          foo::Integer r = x + y;        // Ok.
          return r;
        }
      };

**Note:** SWIG does *not* propagate ``using`` declarations to the
resulting wrapper code. If these declarations appear in an interface,
they should *also* appear in any header files that might have been
included in a ``%{ ... %}`` section. In other words, don't insert extra
``using`` declarations into a SWIG interface unless they also appear in
the underlying C++ code.

**Note:** Code inclusion directives such as ``%{ ... %}`` or
``%inline %{ ... %}`` should not be placed inside a namespace
declaration. The code emitted by these directives will not be enclosed
in a namespace and you may get very strange results. If you need to use
namespaces with these directives, consider the following:

.. container:: code

   ::

      // Good version
      %inline %{
      namespace foo {
        void bar(int) { ... }
        ...
      }
      %}

      // Bad version.  Emitted code not placed in namespace.
      namespace foo {
      %inline %{
        void bar(int) { ... }   /* I'm bad */
        ...
        %}
      }

**Note:** When the ``%extend`` directive is used inside a namespace, the
namespace name is included in the generated functions. For example, if
you have code like this,

.. container:: code

   ::

      namespace foo {
        class bar {
          public:
            %extend {
              int blah(int x);
            };
        };
      }

the added method ``blah()`` is mapped to a function
``int foo_bar_blah(foo::bar *self, int x)``. This function resides in
the global namespace.

**Note:** Although namespaces are flattened in the target language, the
SWIG generated wrapper code observes the same namespace conventions as
used in the input file. Thus, if there are no symbol conflicts in the
input, there will be no conflicts in the generated code.

**Note:** In the same way that no resolution is performed on parameters,
a conversion operator name must match exactly to how it is defined. Do
not change the qualification of the operator. For example, suppose you
had an interface like this:

.. container:: code

   ::

      namespace foo {
        class bar;
        class spam {
          public:
          ...
          operator bar();      // Conversion of spam -> bar
          ...
        };
      }

The following is how the feature is expected to be written for a
successful match:

.. container:: code

   ::

      %rename(tofoo) foo::spam::operator bar();

The following does not work as no namespace resolution is performed in
the matching of conversion operator names:

.. container:: code

   ::

      %rename(tofoo) foo::spam::operator foo::bar();

Note, however, that if the operator is defined using a qualifier in its
name, then the feature must use it too...

.. container:: code

   ::

      %rename(tofoo) foo::spam::operator bar();      // will not match
      %rename(tofoo) foo::spam::operator foo::bar(); // will match
      namespace foo {
        class bar;
        class spam {
          public:
          ...
          operator foo::bar();
          ...
        };
      }

**Compatibility Note:** Versions of SWIG prior to 1.3.32 were
inconsistent in this approach. A fully qualified name was usually
required, but would not work in some situations.

**Note:** The flattening of namespaces is only intended to serve as a
basic namespace implementation. More advanced handling of namespaces is
discussed next.

The nspace feature for namespaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some target languages provide support for the ``nspace``
`feature <Customization.html#Customization_features>`__. The feature can
be applied to any class, struct, union or enum declared within a named
namespace. The feature wraps the type within the target language
specific concept of a namespace, for example, a Java package or C#
namespace. Please see the language specific sections to see if the
target language you are interested in supports the nspace feature.

The feature is demonstrated below for C# using the following example:

.. container:: code

   ::

      %feature("nspace") MyWorld::Material::Color;
      %nspace MyWorld::Wrapping::Color; // %nspace is a macro for %feature("nspace")

      namespace MyWorld {
        namespace Material {
          class Color {
          ...
          };
        }
        namespace Wrapping {
          class Color {
          ...
          };
        }
      }

Without the ``nspace`` feature directives above or ``%rename``, you
would get the following warning resulting in just one of the ``Color``
classes being available for use from the target language:

.. container:: shell

   ::

      example.i:9: Error: 'Color' is multiply defined in the generated target language module.
      example.i:5: Error: Previous declaration of 'Color'

With the ``nspace`` feature the two ``Color`` classes are wrapped into
the equivalent C# namespaces. A fully qualified constructor call of each
these two types in C# is then:

.. container:: targetlang

   ::

      MyWorld.Material.Color materialColor = new MyWorld.Material.Color();
      MyWorld.Wrapping.Color wrappingColor = new MyWorld.Wrapping.Color();

Note that the ``nspace`` feature does not apply to variables and
functions simply declared in a namespace. For example, the following
symbols cannot co-exist in the target language without renaming. This
may change in a future version.

.. container:: code

   ::

      namespace MyWorld {
        namespace Material {
          int quantity;
          void dispatch();
        }
        namespace Wrapping {
          int quantity;
          void dispatch();
        }
      }

**Compatibility Note:** The nspace feature was first introduced in
SWIG-2.0.0.

Renaming templated types in namespaces
-------------------------------------------

As has been mentioned, when %rename includes parameters, the parameter
types must match exactly (no typedef or namespace resolution is
performed). SWIG treats templated types slightly differently and has an
additional matching rule so unlike non-templated types, an exact match
is not always required. If the fully qualified templated type is
specified, it will have a higher precedence over the generic template
type. In the example below, the generic template type is used to rename
to ``bbb`` and the fully qualified type is used to rename to ``ccc``.

.. container:: code

   ::

      %rename(bbb) Space::ABC::aaa(T t);                     // will match but with lower precedence than ccc
      %rename(ccc) Space::ABC<Space::XYZ>::aaa(Space::XYZ t);// will match but with higher precedence
                                                             // than bbb

      namespace Space {
        class XYZ {};
        template<typename T> struct ABC {
          void aaa(T t) {}
        };
      }
      %template(ABCXYZ) Space::ABC<Space::XYZ>;

It should now be apparent that there are many ways to achieve a renaming
with %rename. This is demonstrated by the following two examples, which
are effectively the same as the above example. Below shows how %rename
can be placed inside a namespace.

.. container:: code

   ::

      namespace Space {
        %rename(bbb) ABC::aaa(T t);                     // will match but with lower precedence than ccc
        %rename(ccc) ABC<Space::XYZ>::aaa(Space::XYZ t);// will match but with higher precedence than bbb
        %rename(ddd) ABC<Space::XYZ>::aaa(XYZ t);       // will not match
      }

      namespace Space {
        class XYZ {};
        template<typename T> struct ABC {
          void aaa(T t) {}
        };
      }
      %template(ABCXYZ) Space::ABC<Space::XYZ>;

Note that ``ddd`` does not match as there is no namespace resolution for
parameter types and the fully qualified type must be specified for
template type expansion. The following example shows how %rename can be
placed within %extend.

.. container:: code

   ::

      namespace Space {
        %extend ABC {
          %rename(bbb) aaa(T t);         // will match but with lower precedence than ccc
        }
        %extend ABC<Space::XYZ> {
          %rename(ccc) aaa(Space::XYZ t);// will match but with higher precedence than bbb
          %rename(ddd) aaa(XYZ t);       // will not match
        }
      }

      namespace Space {
        class XYZ {};
        template<typename T> struct ABC {
          void aaa(T t) {}
        };
      }
      %template(ABCXYZ) Space::ABC<Space::XYZ>;

Exception specifications
-----------------------------

When C++ programs utilize exceptions, exceptional behavior is sometimes
specified as part of a function or method declaration. For example:

.. container:: code

   ::

      class Error { };

      class Foo {
      public:
        ...
        void blah() throw(Error);
        ...
      };

If an exception specification is used, SWIG automatically generates
wrapper code for catching the indicated exception and, when possible,
rethrowing it into the target language, or converting it into an error
in the target language otherwise. For example, in Python, you can write
code like this:

.. container:: targetlang

   ::

      f = Foo()
      try:
          f.blah()
      except Error, e:
          # e is a wrapped instance of "Error"

Details of how to tailor code for handling the caught C++ exception and
converting it into the target language's exception/error handling
mechanism is outlined in the `"throws"
typemap <Typemaps.html#Typemaps_throws_typemap>`__ section.

Since exception specifications are sometimes only used sparingly, this
alone may not be enough to properly handle C++ exceptions. To do that, a
different set of special SWIG directives are used. Consult the
"`Exception handling with
%exception <Customization.html#Customization_exception>`__" section for
details. The next section details a way of simulating an exception
specification or replacing an existing one.

Exception handling with %catches
-------------------------------------

Exceptions are automatically handled for methods with an exception
specification. Similar handling can be achieved for methods without
exception specifications through the ``%catches`` feature. It is also
possible to replace any declared exception specification using the
``%catches`` feature. In fact, ``%catches`` uses the same `"throws"
typemaps <Typemaps.html#Typemaps_throws_typemap>`__ that SWIG uses for
exception specifications in handling exceptions. The ``%catches``
feature must contain a list of possible types that can be thrown. For
each type that is in the list, SWIG will generate a catch handler, in
the same way that it would for types declared in the exception
specification. Note that the list can also include the catch all
specification "...". For example,

.. container:: code

   ::

      struct EBase { virtual ~EBase(); };
      struct Error1 : EBase { };
      struct Error2 : EBase { };
      struct Error3 : EBase { };
      struct Error4 : EBase { };

      %catches(Error1, Error2, ...) Foo::bar();
      %catches(EBase) Foo::blah();

      class Foo {
      public:
        ...
        void bar();
        void blah() throw(Error1, Error2, Error3, Error4);
        ...
      };

For the ``Foo::bar()`` method, which can throw anything, SWIG will
generate catch handlers for ``Error1``, ``Error2`` as well as a catch
all handler (...). Each catch handler will convert the caught exception
and convert it into a target language error/exception. The catch all
handler will convert the caught exception into an unknown
error/exception.

Without the ``%catches`` feature being attached to ``Foo::blah()``, SWIG
will generate catch handlers for all of the types in the exception
specification, that is, ``Error1, Error2, Error3, Error4``. However,
with the ``%catches`` feature above, just a single catch handler for the
base class, ``EBase`` will be generated to convert the C++ exception
into a target language error/exception.

Pointers to Members
------------------------

Starting with SWIG-1.3.7, there is limited parsing support for pointers
to C++ class members. For example:

.. container:: code

   ::

      double do_op(Object *o, double (Object::*callback)(double, double));
      extern double (Object::*fooptr)(double, double);
      %constant double (Object::*FOO)(double, double) = &Object::foo;

Although these kinds of pointers can be parsed and represented by the
SWIG type system, few language modules know how to handle them due to
implementation differences from standard C pointers. Readers are
*strongly* advised to consult an advanced text such as the "The
Annotated C++ Manual" for specific details.

When pointers to members are supported, the pointer value might appear
as a special string like this:

.. container:: targetlang

   ::

      >>> print example.FOO
      _ff0d54a800000000_m_Object__f_double_double__double
      >>>

In this case, the hexadecimal digits represent the entire value of the
pointer which is usually the contents of a small C++ structure on most
machines.

SWIG's type-checking mechanism is also more limited when working with
member pointers. Normally SWIG tries to keep track of inheritance when
checking types. However, no such support is currently provided for
member pointers.

Smart pointers and operator->()
------------------------------------

In some C++ programs, objects are often encapsulated by smart-pointers
or proxy classes. This is sometimes done to implement automatic memory
management (reference counting) or persistence. Typically a
smart-pointer is defined by a class template where the ``->`` operator
has been overloaded. This class is then wrapped around some other class.
For example:

.. container:: code

   ::

      // Smart-pointer class
      template<class T> class SmartPtr {
        T *pointee;
      public:
        SmartPtr(T *p) : pointee(p) { ... }
        T *operator->() {
          return pointee;
        }
        ...
      };

      // Ordinary class
      class Foo_Impl {
      public:
        int x;
        virtual void bar();
        ...
      };

      // Smart-pointer wrapper
      typedef SmartPtr<Foo_Impl> Foo;

      // Create smart pointer Foo
      Foo make_Foo() {
        return SmartPtr<Foo_Impl>(new Foo_Impl());
      }

      // Do something with smart pointer Foo
      void do_something(Foo f) {
        printf("x = %d\n", f->x);
        f->bar();
      }

      // Call the wrapped smart pointer proxy class in the target language 'Foo'
      %template(Foo) SmartPtr<Foo_Impl>;

A key feature of this approach is that by defining ``operator->`` the
methods and attributes of the object wrapped by a smart pointer are
transparently accessible. For example, expressions such as these (from
the previous example),

.. container:: code

   ::

      f->x
      f->bar()

are transparently mapped to the following

.. container:: code

   ::

      (f.operator->())->x;
      (f.operator->())->bar();

When generating wrappers, SWIG tries to emulate this functionality to
the extent that it is possible. To do this, whenever ``operator->()`` is
encountered in a class, SWIG looks at its returned type and uses it to
generate wrappers for accessing attributes of the underlying object. For
example, wrapping the above code produces wrappers like this:

.. container:: code

   ::

      int Foo_x_get(Foo *f) {
        return (*f)->x;
      }
      void Foo_x_set(Foo *f, int value) {
        (*f)->x = value;
      }
      void Foo_bar(Foo *f) {
        (*f)->bar();
      }

These wrappers take a smart-pointer instance as an argument, but
dereference it in a way to gain access to the object returned by
``operator->()``. You should carefully compare these wrappers to those
in the first part of this chapter (they are slightly different).

The end result is that access looks very similar to C++. For example,
you could do this in Python:

.. container:: targetlang

   ::

      >>> f = make_Foo()
      >>> print f.x
      0
      >>> f.bar()
      >>>

When generating wrappers through a smart-pointer, SWIG tries to generate
wrappers for all methods and attributes that might be accessible through
``operator->()``. This includes any methods that might be accessible
through inheritance. However, there are a number of restrictions:

-  Member variables and methods are wrapped through a smart pointer.
   Enumerations, constructors, and destructors are not wrapped.

-  If the smart-pointer class and the underlying object both define a
   method or variable of the same name, then the smart-pointer version
   has precedence. For example, if you have this code

   .. container:: code

      ::

         class Foo {
         public:
           int x;
         };

         class Bar {
         public:
           int x;       
           Foo *operator->();
         };

   then the wrapper for ``Bar::x`` accesses the ``x`` defined in
   ``Bar``, and not the ``x`` defined in ``Foo``.

If your intent is to only expose the smart-pointer class in the
interface, it is not necessary to wrap both the smart-pointer class and
the class for the underlying object. However, you must still tell SWIG
about both classes if you want the technique described in this section
to work. To only generate wrappers for the smart-pointer class, you can
use the %ignore directive. For example:

.. container:: code

   ::

      %ignore Foo;
      class Foo {       // Ignored
      };

      class Bar {
      public:
        Foo *operator->();
        ...
      };

Alternatively, you can import the definition of ``Foo`` from a separate
file using ``%import``.

**Note:** When a class defines ``operator->()``, the operator itself is
wrapped as a method ``__deref__()``. For example:

.. container:: targetlang

   ::

      f = Foo()               # Smart-pointer
      p = f.__deref__()       # Raw pointer from operator->

**Note:** To disable the smart-pointer behavior, use ``%ignore`` to
ignore ``operator->()``. For example:

.. container:: code

   ::

      %ignore Bar::operator->;

**Note:** Smart pointer support was first added in SWIG-1.3.14.

C++ reference counted objects - ref/unref feature
------------------------------------------------------

Another similar idiom in C++ is the use of reference counted objects.
Consider for example:

.. container:: code

   ::

      class RCObj  {
        // implement the ref counting mechanism
        int add_ref();
        int del_ref();
        int ref_count();

      public:
        virtual ~RCObj() = 0;

        int ref() const {
          return add_ref();
        }

        int unref() const {
          if (ref_count() == 0 || del_ref() == 0 ) {
            delete this;
            return 0;
          }
          return ref_count();
        }
      };


      class A : RCObj {
      public:
        A();
        int foo();
      };


      class B {
        A *_a;

      public:
        B(A *a) : _a(a) { 
          a->ref(); 
        }

        ~B() { 
          a->unref(); 
        }
      };

      int main() {
        A *a  = new A();       // (count: 0)
        a->ref();           // 'a' ref here (count: 1)

        B *b1 = new B(a);   // 'a' ref here (count: 2)
        if (1 + 1 == 2) {
          B *b2 = new B(a); // 'a' ref here (count: 3)
          delete b2;        // 'a' unref, but not deleted (count: 2)
        }

        delete b1;          // 'a' unref, but not deleted (count: 1)
        a->unref();         // 'a' unref and deleted (count: 0)
      }

In the example above, the 'A' class instance 'a' is a reference counted
object, which can't be deleted arbitrarily since it is shared between
the objects 'b1' and 'b2'. 'A' is derived from a *Reference Counted
Object* 'RCObj', which implements the ref/unref idiom.

To tell SWIG that 'RCObj' and all its derived classes are reference
counted objects, use the "ref" and "unref"
`features <Customization.html#Customization_features>`__. These are also
available as ``%refobject`` and ``%unrefobject``, respectively. For
example:

.. container:: code

   ::

      %module example
      ...

      %feature("ref")   RCObj "$this->ref();"
      %feature("unref") RCObj "$this->unref();"

      %include "rcobj.h"
      %include "A.h"
      ...

where the code passed to the "ref" and "unref" features will be executed
as needed whenever a new object is passed to Python, or when Python
tries to release the proxy object instance, respectively.

On the Python side, the use of a reference counted object is no
different to any other regular instance:

.. container:: targetlang

   ::

      def create_A():
          a = A()         # SWIG ref 'a' - new object is passed to Python (count: 1)
          b1 = B(a)       # C++ ref 'a (count: 2)
          if 1 + 1 == 2:
              b2 = B(a)   # C++ ref 'a' (count: 3)
          return a        # 'b1' and 'b2' are released and deleted, C++ unref 'a' twice (count: 1)

      a = create_A()      # (count: 1)
      exit                # 'a' is released, SWIG unref 'a' called in the destructor wrapper (count: 0)

Note that the user doesn't explicitly need to call 'a->ref()' nor
'a->unref()' (and neither 'delete a'). Instead, SWIG takes cares of
executing the "ref" and "unref" calls as needed. If the user doesn't
specify the "ref/unref" feature for a type, SWIG will produce code
equivalent to defining these features:

.. container:: code

   ::

      %feature("ref")   ""
      %feature("unref") "delete $this;"

In other words, SWIG will not do anything special when a new object is
passed to Python, and it will always 'delete' the underlying object when
Python releases the proxy instance.

The `%newobject feature <Customization.html#Customization_ownership>`__
is designed to indicate to the target language that it should take
ownership of the returned object. When used in conjunction with a type
that has the "ref" feature associated with it, it additionally emits the
code in the "ref" feature into the C++ wrapper. Consider wrapping the
following factory function in addition to the above:

.. container:: code

   ::

      %newobject AFactory;
      A *AFactory() {
        return new A();
      }

The ``AFactory`` function now acts much like a call to the ``A``
constructor with respect to memory handling:

.. container:: targetlang

   ::

      a = AFactory()    # SWIG ref 'a' due to %newobject (count: 1)
      exit              # 'a' is released, SWIG unref 'a' called in the destructor wrapper (count: 0)

Using declarations and inheritance
---------------------------------------

``using`` declarations are sometimes used to adjust access to members of
base classes. For example:

.. container:: code

   ::

      class Foo {
      public:
        int  blah(int x);
      };

      class Bar {
      public:
        double blah(double x);
      };

      class FooBar : public Foo, public Bar {
      public:
        using Foo::blah;
        using Bar::blah;
        char *blah(const char *x);
      };

In this example, the ``using`` declarations make different versions of
the overloaded ``blah()`` method accessible from the derived class. For
example:

.. container:: code

   ::

      FooBar *f;
      f->blah(3);         // Ok. Invokes Foo::blah(int)
      f->blah(3.5);       // Ok. Invokes Bar::blah(double)
      f->blah("hello");   // Ok. Invokes FooBar::blah(const char *);

SWIG emulates the same functionality when creating wrappers. For
example, if you wrap this code in Python, the module works just like you
would expect:

.. container:: targetlang

   ::

      >>> import example
      >>> f = example.FooBar()
      >>> f.blah(3)
      >>> f.blah(3.5)
      >>> f.blah("hello")

``using`` declarations can also be used to change access when
applicable. For example:

.. container:: code

   ::

      class Foo {
      protected:
        int x;
        int blah(int x);
      };

      class Bar : public Foo {
      public:
        using Foo::x;       // Make x public
        using Foo::blah;    // Make blah public
      };

This also works in SWIG---the exposed declarations will be wrapped
normally.

When ``using`` declarations are used as shown in these examples,
declarations from the base classes are copied into the derived class and
wrapped normally. When copied, the declarations retain any properties
that might have been attached using ``%rename``, ``%ignore``, or
``%feature``. Thus, if a method is ignored in a base class, it will also
be ignored by a ``using`` declaration.

Because a ``using`` declaration does not provide fine-grained control
over the declarations that get imported, it may be difficult to manage
such declarations in applications that make heavy use of SWIG
customization features. If you can't get ``using`` to work correctly,
you can always change the interface to the following:

.. container:: code

   ::


      class FooBar : public Foo, public Bar {
      public:
      #ifndef SWIG
        using Foo::blah;
        using Bar::blah;
      #else
        int blah(int x);         // explicitly tell SWIG about other declarations
        double blah(double x);
      #endif

        char *blah(const char *x);
      };

**Notes:**

-  If a derived class redefines a method defined in a base class, then a
   ``using`` declaration won't cause a conflict. For example:

   .. container:: code

      ::

         class Foo {
         public:
           int blah(int );
           double blah(double);
         };

         class Bar : public Foo {
         public:
           using Foo::blah;    // Only imports blah(double);
           int blah(int);
         };

-  Resolving ambiguity in overloading may prevent declarations from
   being imported by ``using``. For example:

   .. container:: code

      ::

         %rename(blah_long) Foo::blah(long);
         class Foo {
         public:
           int blah(int);
           long blah(long);  // Renamed to blah_long
         };

         class Bar : public Foo {
         public:
           using Foo::blah;     // Only imports blah(int)
           double blah(double x);
         };

Nested classes
-------------------

If the target language supports the nested classes concept (like Java),
the nested C++ classes are wrapped as nested target language proxy
classes. (In case of Java - "static" nested classes.) Only public nested
classes are wrapped. Otherwise there is little difference between nested
and normal classes.

If the target language doesn't support nested classes directly, or the
support is not implemented in the language module (like for Python
currently), then the visible nested classes are moved to the same name
space as the containing class (nesting hierarchy is "flattened"). The
same behaviour may be turned on for C# and Java by the %feature
("flatnested"); If there is a class with the same name in the outer
namespace the inner class (or the global one) may be renamed or ignored:

.. container:: code

   ::

      %rename (Bar_Foo) Bar::Foo;
      class Foo {};
      class Bar {
        public:
        class Foo {};
      };

If a nested class, within an outer class, has to be used as a template
parameter within the outer class, then the template will have to be
instantiated with ``%template`` before the beginning of the outer class.
An example can be found in the
`Templates <#SWIGPlus_template_nested_class_example>`__ section.

**Compatibility Note:** Prior to SWIG-3.0.0, there was limited nested
class support. Nested classes were treated as opaque pointers. However,
there was a workaround for nested class support in these older versions
requiring the user to replicate the nested class in the global scope,
adding in a typedef for the nested class in the global scope and using
the "nestedworkaround" feature on the nested class. This resulted in
approximately the same behaviour as the "flatnested" feature. With
proper nested class support now available in SWIG-3.0.0, this feature
has been deprecated and no longer works requiring code changes. If you
see the following warning:

.. container:: shell

   ::

      example.i:8: Warning 126: The nestedworkaround feature is deprecated

consider using the "flatnested" feature discussed above which generates
a non-nested proxy class, like the "nestedworkaround" feature did.
Alternatively, use the default nested class code generation, which may
generate an equivalent to a nested proxy class in the target language,
depending on the target language support.

SWIG-1.3.40 and earlier versions did not have the ``nestedworkaround``
feature and the generated code resulting from parsing nested classes did
not always compile. Nested class warnings could also not be suppressed
using %warnfilter.

A brief rant about const-correctness
-----------------------------------------

A common issue when working with C++ programs is dealing with all
possible ways in which the ``const`` qualifier (or lack thereof) will
break your program, all programs linked against your program, and all
programs linked against those programs.

Although SWIG knows how to correctly deal with ``const`` in its internal
type system and it knows how to generate wrappers that are free of
const-related warnings, SWIG does not make any attempt to preserve
const-correctness in the target language. Thus, it is possible to pass
``const`` qualified objects to non-const methods and functions. For
example, consider the following code in C++:

.. container:: code

   ::

      const Object * foo();
      void bar(Object *);

      ...
      // C++ code
      void blah() {
        bar(foo());         // Error: bar discards const
      };

Now, consider the behavior when wrapped into a Python module:

.. container:: targetlang

   ::

      >>> bar(foo())         # Okay
      >>> 

Although this is clearly a violation of the C++ type-system, fixing the
problem doesn't seem to be worth the added implementation complexity
that would be required to support it in the SWIG run-time type system.
There are no plans to change this in future releases (although we'll
never rule anything out entirely).

The bottom line is that this particular issue does not appear to be a
problem for most SWIG projects. Of course, you might want to consider
using another tool if maintaining constness is the most important part
of your project.

Callbacks to the target language
-------------------------------------

C/C++ function pointers are often used for callbacks and this is
discussed in the `Pointers to functions and
callbacks <SWIG.html#SWIG_nn30>`__ section. The callback techniques
described therein provide a way to control callbacks to a C/C++ function
but not callbacks into the target language. The techniques described
below show how the director feature can be used to support callbacks
from C/C++ to the target language.

Introduction to director classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The director feature enables the ability for a target language class to
derive from a wrapped C++ class. The target language can override
virtual methods of a wrapped C++ class, thereby supporting
cross-language polymorphism. Code can 'call up' from C++ into the target
language by simply calling a virtual method overridden in a derived
class in the target language. The wrapped C++ classes that have this
ability are termed 'director' classes. The director feature is
documented individually in each target language and the reader should
locate and read this to obtain a full understanding of directors.

Using directors and target language callbacks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG's primary goal is to make it possible to call C/C++ code from a
target language, however, the director feature enables the reverse.
While there isn't simple direct support for calling target language code
from C, the director feature makes this possible. It does require some
work and additional wrapper code to be provided by the user. The
additional code required must be C++ and not C code and hence may
introduce a small dependency on C++ if using a pure C project. In a
nutshell, the user must create a C++ base class and turn it into a
director class. A virtual method in the director base class is required.
SWIG generates the code to call up into the target language when
wrapping the director virtual method.

Let's look at some details next. Consider the same function pointer for
a callback called ``binary_op`` from the `Pointers to functions and
callbacks <SWIG.html#SWIG_nn30>`__ section. For completeness, the code
required for the module and director feature is also shown:

.. container:: code

   ::

      %module(directors="1") example

      %{
      int binary_op(int a, int b, int (*op)(int, int)) {
        return op(a, b);
      }
      %}

The goal is to have a target language function that gets called by
``binary_op``. The target language function should have the equivalent
signature as the C/C++ function pointer ``int (*op)(int, int)``. As we
are using directors, we need a C++ virtual method with this signature,
so let's define the C++ class and pure virtual method first and make it
a director class via the director feature:

.. container:: code

   ::

      %feature("director") BinaryOp;

      %inline %{
      struct BinaryOp {
        virtual int handle(int a, int b) = 0;
        virtual ~BinaryOp() {}
      };
      %}

The following ``handler_helper`` function and ``binary_op_wrapper``
function completes the code needed in the C++/SWIG layer. The
``binary_op_wrapper`` function is wrapped by SWIG and is very similar to
the ``binary_op`` function, however, it takes a pointer to the director
base class ``BinaryOp`` instead of a C/C++ function pointer.

.. container:: code

   ::

      %{
      static BinaryOp *handler_ptr = NULL;
      static int handler_helper(int a, int b) {
        // Make the call up to the target language when handler_ptr
        // is an instance of a target language director class
        return handler_ptr->handle(a, b);
      }
      // If desired, handler_ptr above could be changed to a thread-local variable in order to make thread-safe
      %}

      %inline %{
      int binary_op_wrapper(int a, int b, BinaryOp *handler) {
        handler_ptr = handler;
        int result = binary_op(a, b, &handler_helper);
        handler = NULL;
        return result;
      }
      %}

On the target language side, we need to derive a class from ``BinaryOp``
and override the ``handle`` method. In Python this could be as simple
as:

.. container:: targetlang

   ::

      import example

      # PythonBinaryOp class is defined and derived from C++ class BinaryOp
      class PythonBinaryOp(example.BinaryOp):

          # Define Python class 'constructor'
          def __init__(self):
              # Call C++ base class constructor
              example.BinaryOp.__init__(self)

          # Override C++ method: virtual int handle(int a, int b) = 0;
          def handle(self, a, b):
              # Return the product
              return a * b

For this to work from Python, an instance of the ``PythonBinaryOp``
class is created and then passed to ``binary_op_wrapper``. The net
result is the ``binary_op`` function will in turn be called which will
call ``handler_helper`` which will call the virtual ``handle`` method,
that is, the Python method ``handle`` in the PythonBinaryOp class. The
result will be the product of 10 and 20 and make its way back to Python
and hence 200 will be printed with the following code:

.. container:: targetlang

   ::

      handler = PythonBinaryOp()
      result = example.binary_op_wrapper(10, 20, handler)
      print result

This has thus demonstrated a C/C++ function pointer calling back into a
target language function. The code could be made a little more user
friendly by using ``%rename`` to provide the original ``binary_op`` name
from the target language instead of ``binary_op_wrapper``. A C++ functor
base class and Python functor class could also be used instead, but
these are left as exercises for the reader.

Where to go for more information
-------------------------------------

If you're wrapping serious C++ code, you might want to pick up a copy of
"The Annotated C++ Reference Manual" by Ellis and Stroustrup. This is
the reference document we use to guide a lot of SWIG's C++ support.

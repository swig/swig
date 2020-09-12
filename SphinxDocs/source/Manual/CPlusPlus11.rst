SWIG and C++11
================

Introduction
----------------

This chapter gives you a brief overview about the SWIG implementation of
the C++11 standard. This part of SWIG is still a work in progress.

SWIG supports the new C++ syntax changes with some minor limitations in
some areas such as decltype expressions and variadic templates. Wrappers
for the new STL types (unordered\_ containers, result_of, tuples) are
incomplete. The wrappers for the new containers would work much like the
C++03 containers and users are welcome to help by adapting the existing
container interface files and submitting them as a patch for inclusion
in future versions of SWIG.

Core language changes
-------------------------

Rvalue reference and move semantics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG correctly parses the rvalue reference syntax '&&', for example the
typical usage of it in the move constructor and move assignment operator
below:

.. container:: code

   ::

      class MyClass {
      ...
        std::vector<int> numbers;
      public:
        MyClass(MyClass &&other) : numbers(std::move(other.numbers)) {}
        MyClass & operator=(MyClass &&other) {
          numbers = std::move(other.numbers);
          return *this;
        }
      };

Rvalue references are designed for C++ temporaries and so are not very
useful when used from non-C++ target languages. Generally you would just
ignore them via ``%ignore`` before parsing the class. For example,
ignore the move constructor:

.. container:: code

   ::

      %ignore MyClass::MyClass(MyClass &&);

The plan is to ignore move constructors by default in a future version
of SWIG. Note that both normal assignment operators as well as move
assignment operators are ignored by default in most target languages
with the following warning:

.. container:: shell

   ::

      example.i:18: Warning 503: Can't wrap 'operator =' unless renamed to a valid identifier.

Generalized constant expressions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG parses and identifies the keyword ``constexpr``, but cannot fully
utilise it. These C++ compile time constants are usable as runtime
constants from the target languages. Below shows example usage for
assigning a C++ compile time constant from a compile time constant
function:

.. container:: code

   ::

      constexpr int XXX() { return 10; }
      constexpr int YYY = XXX() + 100;

When either of these is used from a target language, a runtime call is
made to obtain the underlying constant.

Extern template
~~~~~~~~~~~~~~~~~~~~~

SWIG correctly parses the keywords ``extern template``. However, this
template instantiation suppression in a translation unit has no
relevance outside of the C++ compiler and so is not used by SWIG. SWIG
only uses ``%template`` for instantiating and wrapping templates.

.. container:: code

   ::

      template class std::vector<int>;        // C++03 explicit instantiation in C++
      extern template class std::vector<int>; // C++11 explicit instantiation suppression in C++
      %template(VectorInt) std::vector<int>;  // SWIG instantiation

Initializer lists
~~~~~~~~~~~~~~~~~~~~~~~

Initializer lists are very much a C++ compiler construct and are not
very accessible from wrappers as they are intended for compile time
initialization of classes using the special ``std::initializer_list``
type. SWIG detects usage of initializer lists and will emit a special
informative warning each time one is used:

.. container:: shell

   ::

      example.i:33: Warning 476: Initialization using std::initializer_list.

Initializer lists usually appear in constructors but can appear in any
function or method. They often appear in constructors which are
overloaded with alternative approaches to initializing a class, such as
the std container's push_back method for adding elements to a container.
The recommended approach then is to simply ignore the initializer-list
constructor, for example:

.. container:: code

   ::

      %ignore Container::Container(std::initializer_list<int>);
      class Container {
      public:
        Container(std::initializer_list<int>); // initializer-list constructor
        Container();
        void push_back(const int &);
        ...
      };

Alternatively you could modify the class and add another constructor for
initialization by some other means, for example by a ``std::vector``:

.. container:: code

   ::

      %include <std_vector.i>
      class Container {
      public:
        Container(const std::vector<int> &);
        Container(std::initializer_list<int>); // initializer-list constructor
        Container();
        void push_back(const int &);
        ...
      };

And then call this constructor from your target language, for example,
in Python, the following will call the constructor taking the
``std::vector``:

.. container:: targetlang

   ::

      >>> c = Container( [1, 2, 3, 4] )

If you are unable to modify the class being wrapped, consider ignoring
the initializer-list constructor and using %extend to add in an
alternative constructor:

.. container:: code

   ::

      %include <std_vector.i>
      %extend Container {
        Container(const std::vector<int> &elements) {
          Container *c = new Container();
          for (int element : elements)
            c->push_back(element);
          return c;
        }
      }

      %ignore Container::Container(std::initializer_list<int>);

      class Container {
      public:
        Container(std::initializer_list<int>); // initializer-list constructor
        Container();
        void push_back(const int &);
        ...
      };

The above makes the wrappers look is as if the class had been declared
as follows:

.. container:: code

   ::

      %include <std_vector.i>
      class Container {
      public:
        Container(const std::vector<int> &);
      //  Container(std::initializer_list<int>); // initializer-list constructor (ignored)
        Container();
        void push_back(const int &);
        ...
      };

``std::initializer_list`` is simply a container that can only be
initialized at compile time. As it is just a C++ type, it is possible to
write typemaps for a target language container to map onto
``std::initializer_list``. However, this can only be done for a fixed
number of elements as initializer lists are not designed to be
constructed with a variable number of arguments at runtime. The example
below is a very simple approach which ignores any parameters passed in
and merely initializes with a fixed list of fixed integer values chosen
at compile time:

.. container:: code

   ::

      %typemap(in) std::initializer_list<int> {
        $1 = {10, 20, 30, 40, 50};
      }
      class Container {
      public:
        Container(std::initializer_list<int>); // initializer-list constructor
        Container();
        void push_back(const int &);
        ...
      };

Any attempt at passing in values from the target language will be
ignored and be replaced by ``{10, 20, 30, 40, 50}``. Needless to say,
this approach is very limited, but could be improved upon, but only
slightly. A typemap could be written to map a fixed number of elements
on to the ``std::initializer_list``, but with values decided at runtime.
The typemaps would be target language specific.

Note that the default typemap for ``std::initializer_list`` does nothing
but issue the warning and hence any user supplied typemaps will override
it and suppress the warning.

Uniform initialization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The curly brackets {} for member initialization are fully supported by
SWIG:

.. container:: code

   ::

      struct BasicStruct {
       int x;
       double y;
      };
       
      struct AltStruct {
        AltStruct(int x, double y) : x_{x}, y_{y} {}
       
        int x_;
        double y_;
      };

      BasicStruct var1{5, 3.2}; // only fills the struct components
      AltStruct var2{2, 4.3};   // calls the constructor

Uniform initialization does not affect usage from the target language,
for example in Python:

.. container:: targetlang

   ::

      >>> a = AltStruct(10, 142.15)
      >>> a.x_
      10
      >>> a.y_
      142.15

Type inference
~~~~~~~~~~~~~~~~~~~~

SWIG supports ``decltype()`` with some limitations. Single variables are
allowed, however, expressions are not supported yet. For example, the
following code will work:

.. container:: code

   ::

      int i;
      decltype(i) j;

However, using an expression inside the decltype results in syntax
error:

.. container:: code

   ::

      int i; int j;
      decltype(i+j) k;  // syntax error

Range-based for-loop
~~~~~~~~~~~~~~~~~~~~~~~~~~

This feature is part of the implementation block only. SWIG ignores it.

Lambda functions and expressions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG correctly parses most of the Lambda functions syntax. For example:

.. container:: code

   ::

      auto val = [] { return something; };
      auto sum = [](int x, int y) { return x+y; };
      auto sum = [](int x, int y) -> int { return x+y; };

The lambda functions are removed from the wrappers for now, because of
the lack of support for closures (scope of the lambda functions) in the
target languages.

Lambda functions used to create variables can also be parsed, but due to
limited support of ``auto`` when the type is deduced from the
expression, the variables are simply ignored.

.. container:: code

   ::

      auto six = [](int x, int y) { return x+y; }(4, 2);

Better support should be available in a later release.

Alternate function syntax
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG fully supports the new definition of functions. For example:

.. container:: code

   ::

      struct SomeStruct {
        int FuncName(int x, int y);
      };

can now be written as in C++11:

.. container:: code

   ::

      struct SomeStruct {
        auto FuncName(int x, int y) -> int;
      };
       
      auto SomeStruct::FuncName(int x, int y) -> int {
        return x + y;
      }

The usage in the target languages remains the same, for example in
Python:

.. container:: targetlang

   ::

      >>> a = SomeStruct()
      >>> a.FuncName(10, 5)
      15

SWIG will also deal with type inference for the return type, as per the
limitations described earlier. For example:

.. container:: code

   ::

      auto square(float a, float b) -> decltype(a);

Object construction improvement
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are three parts to object construction improvement. The first
improvement is constructor delegation such as the following:

.. container:: code

   ::

      class A {
      public:
        int a;
        int b;
        int c;

        A() : A(10) {}
        A(int aa) : A(aa, 20) {}
        A(int aa, int bb) : A(aa, bb, 30) {}
        A(int aa, int bb, int cc) { a=aa; b=bb; c=cc; }
      };

where peer constructors can be called. SWIG handles this without any
issue.

The second improvement is constructor inheritance via a ``using``
declaration. This is parsed correctly, but the additional constructors
are not currently added to the derived proxy class in the target
language. An example is shown below:

.. container:: code

   ::

      class BaseClass {
      public:
        BaseClass(int iValue);
      };

      class DerivedClass: public BaseClass {
        public:
        using BaseClass::BaseClass; // Adds DerivedClass(int) constructor
      };

The final part is member initialization at the site of the declaration.
This kind of initialization is handled by SWIG.

.. container:: code

   ::

      class SomeClass {
      public:
        SomeClass() {}
        explicit SomeClass(int new_value) : value(new_value) {}

        int value = 5;
      };

Explicit overrides and final
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The special identifiers ``final`` and ``override`` can be used on
methods and destructors, such as in the following example:

.. container:: code

   ::

      struct BaseStruct {
        virtual void ab() const = 0;
        virtual void cd();
        virtual void ef();
        virtual ~BaseStruct();
      };
      struct DerivedStruct : BaseStruct {
        virtual void ab() const override;
        virtual void cd() final;
        virtual void ef() final override;
        virtual ~DerivedStruct() override;
      };

Null pointer constant
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``nullptr`` constant is mostly unimportant in wrappers. In the few
places it has an effect, it is treated like ``NULL``.

Strongly typed enumerations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG supports strongly typed enumerations and parses the new
``enum class`` syntax and forward declarator for the enums, such as:

.. container:: code

   ::

      enum class MyEnum : unsigned int;

Strongly typed enums are often used to avoid name clashes such as the
following:

.. container:: code

   ::

      struct Color {
        enum class RainbowColors : unsigned int {
          Red, Orange, Yellow, Green, Blue, Indigo, Violet
        };
        
        enum class WarmColors {
          Yellow, Orange, Red
        };

        // Note normal enum
        enum PrimeColors {
          Red=100, Green, Blue
        };
      };

There are various ways that the target languages handle enums, so it is
not possible to precisely state how they are handled in this section.
However, generally, most scripting languages mangle in the strongly
typed enumeration's class name, but do not use any additional mangling
for normal enumerations. For example, in Python, the following code

.. container:: targetlang

   ::

      print Color.RainbowColors_Red, Color.WarmColors_Red, Color.Red

results in

.. container:: shell

   ::

      0 2 100

The strongly typed languages often wrap normal enums into an enum class
and so treat normal enums and strongly typed enums the same. The
equivalent in Java is:

.. container:: targetlang

   ::

      System.out.println(Color.RainbowColors.Red.swigValue() + " " + Color.WarmColors.Red.swigValue() + " " + Color.PrimeColors.Red.swigValue());

Double angle brackets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG correctly parses the symbols >> as closing the template block, if
found inside it at the top level, or as the right shift operator >>
otherwise.

.. container:: code

   ::

      std::vector<std::vector<int>> myIntTable;

Explicit conversion operators
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG correctly parses the keyword ``explicit`` for operators in addition
to constructors now. For example:

.. container:: code

   ::

      class U {
      public:
        int u;
      };

      class V {
      public:
        int v;
      };

      class TestClass {
      public:
        //implicit converting constructor
        TestClass(U const &val) { t=val.u; }

        // explicit constructor
        explicit TestClass(V const &val) { t=val.v; }

        int t;
      };

      struct Testable {
        // explicit conversion operator
        explicit operator bool() const {
          return false;
        }
      };

The effect of explicit constructors and operators has little relevance
for the proxy classes as target languages don't have the same concepts
of implicit conversions as C++. Conversion operators either with or
without ``explicit`` need renaming to a valid identifier name in order
to make them available as a normal proxy method.

Type alias and alias templates
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A type alias is a statement of the form:

.. container:: code

   ::

      using PFD = void (*)(double); // New introduced syntax

which is equivalent to the old style typedef:

.. container:: code

   ::

      typedef void (*PFD)(double);  // The old style

The following is an example of an alias template:

.. container:: code

   ::

      template< typename T1, typename T2, int N >
      class SomeType {
      public:
        T1 a;
        T2 b;
      };

      template< typename T2 >
      using TypedefName = SomeType<char*, T2, 5>;

SWIG supports both type aliasing and alias templates. However, in order
to use an alias template, two ``%template`` directives must be used:

.. container:: code

   ::

      %template(SomeTypeBool) SomeType<char*, bool, 5>;
      %template() TypedefName<bool>;

Firstly, the actual template is instantiated with a name to be used by
the target language, as per any template being wrapped. Secondly, the
empty template instantiation, ``%template()``, is required for the alias
template. This second requirement is necessary to add the appropriate
instantiated template type into the type system as SWIG does not
automatically instantiate templates. See the
`Templates <SWIGPlus.html#SWIGPlus_nn30>`__ section for more general
information on wrapping templates.

Unrestricted unions
~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG fully supports any type inside a union even if it does not define a
trivial constructor. For example, the wrapper for the following code
correctly provides access to all members in the union:

.. container:: code

   ::

      struct point {
        point() {}
        point(int x, int y) : x_(x), y_(y) {}
        int x_, y_;
      };

      #include <new> // For placement 'new' in the constructor below
      union P {
        int z;
        double w;
        point p; // Illegal in C++03; legal in C++11.
        // Due to the point member, a constructor definition is required.
        P() {
          new(&p) point();
        }
      } p1;

Variadic templates
~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG supports the variadic templates syntax (inside the <> block,
variadic class inheritance and variadic constructor and initializers)
with some limitations. The following code is correctly parsed:

.. container:: code

   ::

      template <typename... BaseClasses> class ClassName : public BaseClasses... {
      public:
        ClassName (BaseClasses &&... baseClasses) : BaseClasses(baseClasses)... {}
      }

For now however, the ``%template`` directive only accepts one parameter
substitution for the variable template parameters.

.. container:: code

   ::

      %template(MyVariant1) ClassName<>         // zero argument not supported yet
      %template(MyVariant2) ClassName<int>      // ok
      %template(MyVariant3) ClassName<int, int> // too many arguments not supported yet

Support for the variadic ``sizeof()`` function is correctly parsed:

.. container:: code

   ::

      const int SIZE = sizeof...(ClassName<int, int>);

In the above example ``SIZE`` is of course wrapped as a constant.

New character literals
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C++11 adds support for UCS-2 and UCS-4 character literals. These
character literals are preceded by either 'u' or 'U'.

.. container:: code

   ::

      char16_t a = u'a';
      char32_t b = U'b';

**Compatibility note:** SWIG-4.0.0 was the first version to support
these Universal Coded Character Set (UCS) character literals.

New string literals
~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG supports wide string and Unicode string constants and raw string
literals.

.. container:: code

   ::

      // New string literals
      wstring         aa =  L"Wide string";
      const char     *bb = u8"UTF-8 string";
      const char16_t *cc =  u"UTF-16 string";
      const char32_t *dd =  U"UTF-32 string";

      // Raw string literals
      const char      *xx =        ")I'm an \"ascii\" \\ string.";
      const char      *ee =   R"XXX()I'm an "ascii" \ string.)XXX"; // same as xx
      wstring          ff =  LR"XXX(I'm a "raw wide" \ string.)XXX";
      const char      *gg = u8R"XXX(I'm a "raw UTF-8" \ string.)XXX";
      const char16_t  *hh =  uR"XXX(I'm a "raw UTF-16" \ string.)XXX";
      const char32_t  *ii =  UR"XXX(I'm a "raw UTF-32" \ string.)XXX";

Non-ASCII string support varies quite a bit among the various target
languages though.

Note: There is a bug currently where SWIG's preprocessor incorrectly
parses an odd number of double quotes inside raw string literals.

User-defined literals
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG parses the declaration of user-defined literals, that is, the
``operator "" _mysuffix()`` function syntax.

Some examples are the raw literal:

.. container:: code

   ::

      OutputType operator "" _myRawLiteral(const char * value);

numeric cooked literals:

.. container:: code

   ::

      OutputType operator "" _mySuffixIntegral(unsigned long long);
      OutputType operator "" _mySuffixFloat(long double);

and cooked string literals:

.. container:: code

   ::

      OutputType operator "" _mySuffix(const char * string_values, size_t num_chars);
      OutputType operator "" _mySuffix(const wchar_t * string_values, size_t num_chars);
      OutputType operator "" _mySuffix(const char16_t * string_values, size_t num_chars);
      OutputType operator "" _mySuffix(const char32_t * string_values, size_t num_chars);

Like other operators that SWIG parses, a warning is given about renaming
the operator in order for it to be wrapped:

.. container:: shell

   ::

      example.i:27: Warning 503: Can't wrap 'operator "" _myRawLiteral' unless renamed to a valid identifier.

If %rename is used, then it can be called like any other wrapped method.
Currently you need to specify the full declaration including parameters
for %rename:

.. container:: code

   ::

      %rename(MyRawLiteral)  operator"" _myRawLiteral(const char * value);

Or if you just wish to ignore it altogether:

.. container:: code

   ::

      %ignore operator "" _myRawLiteral(const char * value);

Note that use of user-defined literals such as the following still give
a syntax error:

.. container:: code

   ::

      OutputType var1 = "1234"_suffix;
      OutputType var2 = 1234_suffix;
      OutputType var3 = 3.1416_suffix;

Thread-local storage
~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG correctly parses the ``thread_local`` keyword. For example,
variables reachable by the current thread can be defined as:

.. container:: code

   ::

      struct A {
        static thread_local int val;
      };
      thread_local int global_val;

The use of the ``thread_local`` storage specifier does not affect the
wrapping process; it does not modify the wrapper code compared to when
it is not specified. A variable will be thread local if accessed from
different threads from the target language in the same way that it will
be thread local if accessed from C++ code.

Explicitly defaulted functions and deleted functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG handles explicitly defaulted functions, that is, ``= default``
added to a function declaration. Deleted definitions, which are also
called deleted functions, have ``= delete`` added to the function
declaration. For example:

.. container:: code

   ::

      struct NonCopyable {
        NonCopyable & operator=(const NonCopyable &) = delete; /* Removes operator= */
        NonCopyable(const NonCopyable &) = delete;             /* Removes copy constructor */
        NonCopyable() = default;                               /* Explicitly allows the empty constructor */
      };

Wrappers for deleted functions will not be available in the target
language. Wrappers for defaulted functions will of course be available
in the target language. Explicitly defaulted functions have no direct
effect for SWIG wrapping as the declaration is handled much like any
other method declaration parsed by SWIG.

Deleted functions are also designed to prevent implicit conversions when
calling the function. For example, the C++ compiler will not compile any
code which attempts to use an int as the type of the parameter passed to
``f`` below:

.. container:: code

   ::

      struct NoInt {
        void f(double i);
        void f(int) = delete;
      };

This is a C++ compile time check and SWIG does not make any attempt to
detect if the target language is using an int instead of a double
though, so in this case it is entirely possible to pass an int instead
of a double to ``f`` from Java, Python etc.

Type long long int
~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG correctly parses and uses the new ``long long`` type already
introduced in C99 some time ago.

Static assertions
~~~~~~~~~~~~~~~~~~~~~~~~

SWIG correctly parses the new ``static_assert`` declarations (though
3.0.12 and earlier had a bug which meant this wasn't accepted at file
scope). This is a C++ compile time directive so there isn't anything
useful that SWIG can do with it.

.. container:: code

   ::

      template <typename T>
      struct Check {
        static_assert(sizeof(int) <= sizeof(T), "not big enough");
      };

Allow sizeof to work on members of classes without an explicit object
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG can parse the new sizeof() on types as well as on objects. For
example:

.. container:: code

   ::

      struct A {
        int member;
      };

      const int SIZE = sizeof(A::member); // does not work with C++03. Okay with C++11

In Python:

.. container:: targetlang

   ::

      >>> SIZE
      8

Exception specifications and noexcept
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C++11 added in the noexcept specification to exception specifications to
indicate that a function simply may or may not throw an exception,
without actually naming any exception. SWIG understands these, although
there isn't any useful way that this information can be taken advantage
of by target languages, so it is as good as ignored during the wrapping
process. Below are some examples of noexcept in function declarations:

.. container:: code

   ::

      static void noex1() noexcept;
      int noex2(int) noexcept(true);
      int noex3(int, bool) noexcept(false);

Control and query object alignment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

An ``alignof`` operator is used mostly within C++ to return alignment in
number of bytes, but could be used to initialize a variable as shown
below. The variable's value will be available for access by the target
language as any other variable's compile time initialised value.

.. container:: code

   ::

      const int align1 = alignof(A::member);

The ``alignas`` specifier for variable alignment is not yet supported.
Example usage:

.. container:: code

   ::

      struct alignas(16) S {
        int num;
      };
      alignas(double) unsigned char c[sizeof(double)];

Use the preprocessor to work around this for now:

.. container:: code

   ::

      #define alignas(T)

Attributes
~~~~~~~~~~~~~~~~~

Attributes such as those shown below, are not yet supported and will
give a syntax error.

.. container:: code

   ::

      int [[attr1]] i [[attr2, attr3]];

      [[noreturn, nothrow]] void f [[noreturn]] ();

Methods with ref-qualifiers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C++11 non-static member functions can be declared with ref-qualifiers.
Member functions declared with a ``&`` lvalue ref-qualifiers are wrapped
like any other function without ref-qualifiers. Member functions
declared with a ``&&`` rvalue ref-qualifiers are ignored by default as
they are unlikely to be required from non-C++ languages where the
concept of *rvalue-ness* for the implied \*this pointer does not apply.
The warning is hidden by default, but can be displayed as described in
the section on `Enabling extra warnings <Warnings.html#Warnings_nn4>`__.

Consider:

.. container:: code

   ::

      struct RQ {
        void m1(int x) &;
        void m2(int x) &&;
      };

The only wrapped method will be the lvalue ref-qualified method ``m1``
and if SWIG is run with the ``-Wextra`` command-line option, the
following warning will be issued indicating ``m2`` is not wrapped:

.. container:: shell

   ::

      example.i:7: Warning 405: Method with rvalue ref-qualifier m2(int) && ignored.

If you unignore the method as follows, wrappers for ``m2`` will be
generated:

.. container:: code

   ::

      %feature("ignore", "0") RQ::m2(int x) &&;
      struct RQ {
        void m1(int x) &;
        void m2(int x) &&;
      };

Inspection of the generated C++ code, will show that ``std::move`` is
used on the instance of the ``RQ *`` class:

.. container:: code

   ::

        RQ *arg1 = (RQ *) 0 ;
        int arg2 ;

        arg1 = ...marshalled from target language...
        arg2 = ...marshalled from target language...

        std::move(*arg1).m2(arg2);

This will compile but when run, the move effects may not be what you
want. As stated earlier, rvalue ref-qualifiers aren't really applicable
outside the world of C++. However, if you really know what you are
doing, full control over the call to the method is possible via the
low-level "action" feature. This feature completely replaces the call to
the underlying function, that is, the last line in the snippet of code
above.

.. container:: code

   ::

      %feature("ignore", "0") RQ::m2(int x) &&;
      %feature("action") RQ::m2(int x) && %{
        RQ().m2(arg2);
      %}
      struct RQ {
        void m1(int x) &;
        void m2(int x) &&;
      };

resulting in:

.. container:: code

   ::

        RQ *arg1 = (RQ *) 0 ;
        int arg2 ;

        arg1 = ...marshalled from target language...
        arg2 = ...marshalled from target language...

        RQ().m2(arg2);

**Compatibility note:** SWIG-4.0.0 was the first version to support
ref-qualifiers.

Standard library changes
----------------------------

Threading facilities
~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG does not currently wrap or use any of the new threading classes
introduced (thread, mutex, locks, condition variables, task). The main
reason is that SWIG target languages offer their own threading
facilities so there is limited use for them.

Tuple types
~~~~~~~~~~~~~~~~~

SWIG does not provide library files for the new tuple types yet.
Variadic template support requires further work to provide substantial
tuple wrappers.

Hash tables
~~~~~~~~~~~~~~~~~

The new hash tables in the STL are ``unordered_set``,
``unordered_multiset``, ``unordered_map``, ``unordered_multimap``. These
are not available in all target languages. Any missing support can in
principle be easily implemented by adapting the current STL containers.

Regular expressions
~~~~~~~~~~~~~~~~~~~~~~~~~

While SWIG could provide wrappers for the new C++11 regular expressions
classes, there is little need as the target languages have their own
regular expression facilities.

General-purpose smart pointers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG provides special smart pointer handling for ``std::shared_ptr`` in
the same way it has support for ``boost::shared_ptr``. Please see the
`shared_ptr smart pointer <Library.html#Library_std_shared_ptr>`__
library section. There is no special smart pointer handling available
for ``std::weak_ptr`` and ``std::unique_ptr`` yet.

Extensible random number facility
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This feature extends and standardizes the standard library only and does
not effect the C++ language nor SWIG.

Wrapper reference
~~~~~~~~~~~~~~~~~~~~~~~

Wrapper references are similar to normal C++ references but are
copy-constructible and copy-assignable. They could conceivably be used
in public APIs. There is no special support for
``std::reference_wrapper`` in SWIG though. Users would need to write
their own typemaps if wrapper references are being used and these would
be similar to the plain C++ reference typemaps.

Polymorphic wrappers for function objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG supports functor classes in a few languages in a very natural way.
However nothing is provided yet for the new ``std::function`` template.
SWIG will parse usage of the template like any other template.

.. container:: code

   ::

      %rename(__call__) Test::operator(); // Default renaming used for Python

      struct Test {
        bool operator()(int x, int y); // function object
      };

      #include <functional>
      std::function<void (int, int)> pF = Test;   // function template wrapper

Example of supported usage of the plain functor from Python is shown
below. It does not involve ``std::function``.

.. container:: targetlang

   ::

      t = Test()
      b = t(1, 2) # invoke C++ function object

Type traits for metaprogramming
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The type_traits functions to support C++ metaprogramming is useful at
compile time and is aimed specifically at C++ development:

.. container:: code

   ::

      #include <type_traits>

      // First way of operating.
      template< bool B > struct algorithm {
        template< class T1, class T2 > static int do_it(T1 &, T2 &)  { /*...*/ return 1; }
      };

      // Second way of operating.
      template<> struct algorithm<true> {
        template< class T1, class T2 > static int do_it(T1, T2)  { /*...*/ return 2; }
      };

      // Instantiating 'elaborate' will automatically instantiate the correct way to operate, depending on the types used.
      template< class T1, class T2 > int elaborate(T1 A, T2 B) {
        // Use the second way only if 'T1' is an integer and if 'T2' is a floating point,
        // otherwise use the first way.
        return algorithm< std::is_integral<T1>::value && std::is_floating_point<T2>::value >::do_it(A, B);
      }

SWIG correctly parses the template specialization, template types etc.
However, metaprogramming and the additional support in the type_traits
header is really for compile time and is not much use at runtime for the
target languages. For example, as SWIG requires explicit instantiation
of templates via ``%template``, there isn't much that
``std::is_integral<int>`` is going to provide by itself. However,
template functions using such metaprogramming techniques might be useful
to wrap. For example, the following instantiations could be made:

.. container:: code

   ::

      %template(Elaborate) elaborate<int, int>;
      %template(Elaborate) elaborate<int, double>;

Then the appropriate algorithm can be called for the subset of types
given by the above ``%template`` instantiations from a target language,
such as Python:

.. container:: targetlang

   ::

      >>> Elaborate(0, 0)
      1
      >>> Elaborate(0, 0.0)
      2

Uniform method for computing return type of function objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The new ``std::result_of`` class introduced in the <functional> header
provides a generic way to obtain the return type of a function type via
``std::result_of::type``. There isn't any library interface file to
support this type. With a bit of work, SWIG will deduce the return type
of functions when used in ``std::result_of`` using the approach shown
below. The technique basically forward declares the ``std::result_of``
template class, then partially specializes it for the function types of
interest. SWIG will use the partial specialization and hence correctly
use the ``std::result_of::type`` provided in the partial specialization.

.. container:: code

   ::

      %inline %{
      #include <functional>
      typedef double(*fn_ptr)(double);
      %}

      namespace std {
        // Forward declaration of result_of
        template<typename Func> struct result_of;
        // Add in a partial specialization of result_of
        template<> struct result_of< fn_ptr(double) > {
          typedef double type;
        };
      }

      %template() std::result_of< fn_ptr(double) >;

      %inline %{

      double square(double x) {
        return (x * x);
      }

      template<class Fun, class Arg>
      typename std::result_of<Fun(Arg)>::type test_result_impl(Fun fun, Arg arg) {
        return fun(arg);
      }
      %}

      %template(test_result) test_result_impl< fn_ptr, double >;
      %constant double (*SQUARE)(double) = square;

Note the first use of ``%template`` which SWIG requires to instantiate
the template. The empty template instantiation suffices as no proxy
class is required for ``std::result_of<Fun(Arg)>::type`` as this type is
really just a ``double``. The second ``%template`` instantiates the
template function which is being wrapped for use as a callback. The
``%constant`` can then be used for any callback function as described in
`Pointers to functions and callbacks <SWIG.html#SWIG_nn30>`__.

Example usage from Python should give the not too surprising result:

.. container:: targetlang

   ::

      >>> test_result(SQUARE, 5.0)
      25.0

Phew, that is a lot of hard work to get a callback working. You could
just go with the more attractive option of just using ``double`` as the
return type in the function declaration instead of ``result_of``!

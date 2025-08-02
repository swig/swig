// This testcase checks whether SWIG produces the correct wrappers for strongly typed enums.

%module cpp11_strongly_typed_enumerations

%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Class1::Struct1;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Class2::Struct1;

// Some illegal forward declarations (incorrectly accepted by SWIG - oh well!)
enum Enum3;
enum ;
enum : unsigned short;

enum Enum1 : short; // should error as mismatches Enum1 class below

%inline %{
enum class Enum1 {
  Val1,
  Val2,
  Val3 = 13,
  Val4,
  Val5a = 13,
  Val6a
};

enum class Enum2 : short {
  Val1,
  Val2,
  Val3 = 23,
  Val4,
  Val5b = 23,
  Val6b
};
%}

// SWIG should fail this one
enum Enum2 : unsigned short;     // Illegal in C++11, because Enum2 was previously declared with a different type.

%inline %{
/* Forward declarations. */
enum Enum4 : unsigned int;       // Legal in C++11.
enum class Enum5;                // Legal in C++11, because enum class declarations have a default type of "int".
enum class Enum6 : unsigned int; // Legal C++11.

enum Enum4 : unsigned int {
  Val1, Val2, Val3 = 43, Val4
};

enum class Enum5 {
  Val1, Val2, Val3 = 53, Val4
};

enum class Enum6 : unsigned int {
  Val1, Val2, Val3 = 63, Val4
};

typedef enum class Enum7 : unsigned int {
  Val1, Val2, Val3 = 73, Val4
} Enum7td;

// enum inherits from non-primitive type
enum class Enum8 : size_t {
  Val1, Val2, Val3 = 83, Val4
};

template <typename T> struct TType {
  typedef T type_name;
};

using EnumBase9 = unsigned short;
enum class Enum9: EnumBase9 {
  Val1 = 0,
  Val2 = 0x2,
};
%}

%template() TType<unsigned char>; // Instantiate template for underlying type used in Enum10

%inline %{
enum class Enum10 : TType<unsigned char>::type_name {
  Val1, Val2, Val3 = 103, Val4
};

// forward declaration, no definition of enum
enum class Enum11 : int;
struct UseEnum11 {
    Enum11 myenum11;
};

class Class1
{
public:
  enum class Enum12
  {
    Val1 = 1121,
    Val2 = 1122,
    Val3,
    Val4,
    Val5c = 1121,
    Val6c
  };

  enum Enum13
  {
    Val1 = 1131,
    Val2 = 1132,
    Val3,
    Val4,
    Val5d = 1131,
    Val6d
  };

  enum class Enum14
  {
    Val1 = 1141,
    Val2 = 1142,
    Val3,
    Val4,
    Val5e = 1141,
    Val6e
  };

  struct Struct1
  {
    enum class Enum12
    {
      Val1 = 3121,
      Val2 = 3122,
      Val3,
      Val4,
      Val5f = 3121,
      Val6f
    };

    enum Enum13
    {
      Val1 = 3131,
      Val2 = 3132,
      Val3,
      Val4,
    };

    enum class Enum14
    {
      Val1 = 3141,
      Val2 = 3142,
      Val3,
      Val4,
      Val5g = 3141,
      Val6g
    };
  };
  Enum1 class1Test1(Enum1 e) { return e; }
  Enum12 class1Test2(Enum12 e) { return e; }
  Struct1::Enum12 class1Test3(Struct1::Enum12 e) { return e; }
};

class Class2
{
public:
  enum class Enum12
  {
    Val1 = 2121,
    Val2 = 2122,
    Val3,
    Val4,
    Val5h = 2121,
    Val6h
  };

  enum Enum13
  {
    Val1 = 2131,
    Val2 = 2132,
    Val3,
    Val4,
    Val5i = 2131,
    Val6i
  };

  enum class Enum14
  {
    Val1 = 2141,
    Val2 = 2142,
    Val3,
    Val4,
    Val5j = 2141,
    Val6j
  };

  struct Struct1
  {
    enum class Enum12
    {
      Val1 = 4121,
      Val2 = 4122,
      Val3,
      Val4,
      Val5k = 4121,
      Val6k
    };

    enum Enum13
    {
      Val1 = 4131,
      Val2 = 4132,
      Val3,
      Val4,
      Val5l = 4131,
      Val6l
    };

    enum class Enum14
    {
      Val1 = 4141,
      Val2 = 4142,
      Val3,
      Val4,
      Val5m = 4141,
      Val6m
    };
  };
};

Enum1 globalTest1(Enum1 e) { return e; }
Class1::Enum12 globalTest2(Class1::Enum12 e) { return e; }
Class1::Struct1::Enum12 globalTest3(Class1::Struct1::Enum12 e) { return e; }

class PrivateEnumClass {
private:
  enum class Enum {
    PrivateEnum1,
    PrivateEnum2
  };
};
%}

// Target language underlying enum type manipulation
#if defined(SWIGCSHARP)
%typemap(csbase, replace="1") Enum15 "short"
%typemap(csbase) Enum16 "short"
%warnfilter(SWIGWARN_CSHARP_MULTIPLE_INHERITANCE) Enum16;
%typemap(csbase) Enum17 "ulong"
#elif defined(SWIGD)
%typemap(dbase, replace="1") Enum15 "short"
%typemap(dbase) Enum16 "short"
%warnfilter(SWIGWARN_D_MULTIPLE_INHERITANCE) Enum16;
%typemap(dbase) Enum17 "uint"
#endif
%inline %{
  enum class Enum15 : long long
  {
    Val1 = 1151,
    Val2 = 1152,
  };
  enum class Enum16 : long long
  {
    Val1 = 1161,
    Val2 = 1162,
  };
  enum class Enum17
  {
    Val1 = 1171,
    Val2 = 1172,
  };
%}

// Test handling of %rename of enum class and an enumerator.
%rename(Enum18) QEnum18;
%rename(Val1) QVal1;
%inline %{
  enum class QEnum18
  {
    QVal1 = 1181,
    Val2 = 1182,
  };
%}

// Regression tests for cases where SWIG incorrectly included "enum " when
// qualifying the emunerator name:

// #197
%include <std_vector.i>
%inline %{
template<Enum17 E> class Bar {};
%}
%template(Enum17Vector) std::vector<Bar<Enum17::Val1>>;

// #675
%template(Enum17Bar) Bar<Enum17::Val2>;
%inline %{
class SubEnum17Bar : public Bar<Enum17::Val2> {};
%}

// #1677
%inline %{
#include <bitset>
typedef std::bitset<static_cast<unsigned>(Enum17::Val1)> type1677;
type1677 classify(int a) { return type1677{}; }
bool has_type(const type1677&, const Enum17&) { return false; }
%}

// #2047
%feature("compactdefaultargs") MyClass::my_func;
%inline %{
class MyClass {
  public:
    enum class PRINT_SETUP { TO_CONSOLE, TO_CSV };
    void my_func(const PRINT_SETUP& e = PRINT_SETUP::TO_CONSOLE) { (void)e; }
};
%}

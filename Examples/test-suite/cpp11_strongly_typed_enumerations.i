/* This testcase checks whether SWIG produces the correct wrapper for the
   strongly typed enums. Enums with the same type are comparable. Enum classes
   require support for nested classes. */
%module cpp11_strongly_typed_enumerations
%warnfilter(302) Val1;
%warnfilter(302) Val2;
%warnfilter(302) Val3;
%warnfilter(302) Val4;

/* Forward declarations (illegally accepted by SWIG - oh well!) */
enum Enum1 : short;
enum Enum3;
enum ;
enum : unsigned short;

%inline %{
enum class Enum1 {
  Val1,
  Val2,
  Val3 = 100,
  Val4 /* = 101 */
};

enum class Enum2 : short {
  Val1,
  Val2,
  Val3 = 100,
  Val4
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
  Val1, Val2, Val3 = 100, Val4
};

enum class Enum5 {
  Val1, Val2, Val3 = 100, Val4
};

enum class Enum6 : unsigned int {
  Val1, Val2, Val3 = 300, Val4
};

typedef enum class Enum7 : unsigned int {
  Val1, Val2, Val3 = 300, Val4
} Enum7td;

// enum inherits from non-primitive type
enum class Enum8 : size_t {
  Val1, Val2, Val3 = 300, Val4
};

template <typename T> struct TType {
  typedef T type_name;
};

enum class Enum10 : TType<int>::type_name {
  Val1, Val2, Val3 = 300, Val4
};

// forward declaration, no definition of enum
enum class Enum11 : int;
struct UseEnum11 {
    Enum11 myenum11;
};

/*
TODO
enum class MyClass {AAA, BBB, CCC};
namespace Space {
enum MyEnum {XXX, YYY, ZZZ};
}
struct SSS {
  MyClass m;
};
*/
%}


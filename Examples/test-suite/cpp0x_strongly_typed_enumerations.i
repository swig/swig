/* This testcase checks whether Swig produces the correct wrapper for the
   strongly typed enums. Enums with the same type are comparable. Enum classes
   require support for nested classes. */
%module cpp0x_strongly_typed_enumerations

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

/* Forward declarations. GCC doesn't support them */
//enum Enum3;                   // Illegal in C++ and C++0x; no size is explicitly specified.
//enum Enum4 : unsigned int;      // Legal in C++0x.
//enum class Enum5;               // Legal in C++0x, because enum class declarations have a default type of "int".
//enum class Enum6 : unsigned int; // Legal C++0x.
//enum Enum2 : unsigned short;    // Illegal in C++0x, because Enum2 was previously declared with a different type.

enum Enum4 : unsigned int {
  Val1, Val2, Val3 = 100, Val4
};

enum class Enum5 {
  Val1, Val2, Val3 = 100, Val4
};

enum class Enum6 : unsigned int {
  Val1, Val2, Val3 = 300, Val4
};
%}

/* This testcase checks whether SWIG correctly uses the new 'decltype()'
   introduced in C++11.
*/
%module cpp11_decltype

%{
#if defined(_MSC_VER)
  #include <iso646.h> // for alternative operator names, e.g. 'compl'

  #pragma warning(disable : 4804) // warning C4804: '-': unsafe use of type 'bool' in operation
  // For: decltype(-false) should_be_int2;
#endif
%}

%inline %{
  class A {
  public:
    int i;
    decltype(i) j;

    auto get_number(decltype(i) a) -> decltype(i) {
      if (a==5)
        return 10;
      else
        return 0;
    }
  };

  // A function parameter is in scope in the trailing return type, so a decltype there names the
  // parameter rather than anything of the same name outside the function.
  struct Shadowed {
    int member;
  };
  Shadowed parameter_name;

  auto parameter_shadows_global(int parameter_name) -> decltype(parameter_name) {
    return parameter_name + 1;
  }

  auto parameter_only(float only_parameter) -> decltype(only_parameter) {
    return only_parameter + 1;
  }

  // A parameter declared with a function type is adjusted to a pointer to that function, and one declared
  // with an array type to a pointer to its element, so that is the type a decltype naming it gives.
  auto function_parameter(int fn(int)) -> decltype(fn) {
    return fn;
  }

  auto array_parameter(int values[10]) -> decltype(values) {
    return values;
  }

  auto const_array_parameter(const int values[10]) -> decltype(values) {
    return values;
  }

  // The adjusted type is what the address of the parameter points at, so this is 'int **'.
  auto array_parameter_address(int values[10]) -> decltype(&values) {
    static int *held;
    held = values;
    return &held;
  }

  // The same adjustments apply where a typedef hides the array or function the parameter is.
  typedef int FunctionAlias(int);
  typedef int ArrayAlias[10];

  auto function_alias_parameter(FunctionAlias fn) -> decltype(fn) {
    return fn;
  }

  auto array_alias_parameter(ArrayAlias values) -> decltype(values) {
    return values;
  }

  auto array_alias_parameter_address(ArrayAlias values) -> decltype(&values) {
    static int *held;
    held = values;
    return &held;
  }

  using FunctionUsing = int(int);
  template<typename T> using FunctionTemplateUsing = T(T);
%}
%template() FunctionTemplateUsing<int>;
%inline %{

  auto function_using_parameter(FunctionUsing fn) -> decltype(fn) {
    return fn;
  }

  auto function_template_using_parameter(FunctionTemplateUsing<int> fn) -> decltype(fn) {
    return fn;
  }

  int increment(int x) { return x + 1; }
  int (*increment_ptr)(int) = increment;

  int *three_values() {
    static int values[3] = { 11, 22, 33 };
    return values;
  }

  // Helpers proving the deduced type in the target language.
  int call_through(int (*fn)(int), int x) { return fn(x); }
  int deref_first(int *values) { return *values; }
  int deref_first2(int **values) { return **values; }
%}


// A setter for a pointer variable is not what is under test here.
%immutable B::k;
#pragma SWIG nowarn=SWIGWARN_CPP11_DECLTYPE

%ignore hidden_global_char;

%ignore hidden_global_func;

%inline %{
#define DECLARE(VAR, VAL) decltype(VAL) VAR = VAL
  static const char hidden_global_char = '\0';
  void hidden_global_func() { }
  class B {
  public:
    int i;
    decltype(i) j;
    decltype(i+j) ij;
    decltype(&i) k;
    DECLARE(a, false);
    DECLARE(b, true);

    // SWIG < 4.2.0 failed to perform type promotion for the result of unary
    // plus and unary minus, so these would end up wrapped as bool and char.
    decltype(+true) should_be_int;
    decltype(-false) should_be_int2;
    decltype(~'x') should_be_int3;

    decltype(int(0)) should_be_int4;
    decltype((int)0.0) should_be_int5;
    decltype((6)-7) should_be_int6;
    decltype((6)+7) should_be_int7;
    decltype((6)*7) should_be_int8;
    decltype((6)&7) should_be_int9;
    enum e { E1 };
    decltype(+E1) should_be_int10;

    decltype(sizeof(i+j)) should_be_ulong;
    decltype(sizeof(-i)) should_be_ulong2;
    decltype(alignof(int)) should_be_ulong3;

    static constexpr decltype(*"abc") should_be_char = 0;

    static constexpr decltype(&hidden_global_char) should_be_string = "xyzzy";

    // SWIG < 4.2.0 incorrectly used int for the result of logical not in C++
    // so this would end up wrapped as int.
    decltype(!0) should_be_bool;

    // Test alternative operator names work in this context.
    decltype(((compl 42) and (not 1)) or (2 xor 4)) should_be_bool2;

    // Feature test for noexcept as an operator.
    decltype(noexcept(hidden_global_func)) should_be_bool3;

    decltype(E1) should_be_enum;

    auto get_number_sum(decltype(i+j) a) -> decltype(i+j) {
      return i+j;
    }

    auto get_number_address(decltype(&i) a) -> decltype(&i) {
      return &i;
    }

    auto negate(decltype(true) b) -> decltype(b) {
      return !b;
    }
  };
%}

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) paren_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) ptr_lvalue;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) held_lvalue;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) plain_ptr;

%inline %{
  struct Held {
    int member;
  };

  enum Enumerated { enumerated_a, enumerated_b };
  enum class ScopedEnumerated { scoped_a, scoped_b };
  typedef enum { typedefed_a, typedefed_b } TypedefEnumerated;

  int paren_int = 1;
  int paren_other = 2;
  int *paren_ptr = &paren_int;
  Held paren_held = { 3 };
  Enumerated paren_enum = enumerated_a;
  ScopedEnumerated paren_scoped_enum = ScopedEnumerated::scoped_a;
  TypedefEnumerated paren_typedef_enum = typedefed_a;

  int *other_address() { return &paren_other; }

  // A parenthesised id-expression is an lvalue, so a decltype of one names a reference to the type the
  // name was declared with rather than that type on its own.
  decltype((paren_int)) int_lvalue = paren_int;      // int &
  decltype((paren_ptr)) ptr_lvalue = paren_ptr;      // int *&
  decltype((paren_held)) held_lvalue = paren_held;   // Held &
  decltype(paren_ptr) plain_ptr = paren_ptr;         // int *

  // An enumeration is wrapped by value like a scalar, so the reference is dropped for all three spellings.
  decltype((paren_enum)) enum_lvalue = paren_enum;                         // Enumerated &
  decltype((paren_scoped_enum)) scoped_enum_lvalue = paren_scoped_enum;    // ScopedEnumerated &
  decltype((paren_typedef_enum)) typedef_enum_lvalue = paren_typedef_enum; // TypedefEnumerated &

  // A functional cast to a class names the class.
  decltype(Held()) constructed_held = { 7 };
  decltype(Held{8}) braced_held = { 9 };
%}

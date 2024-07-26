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

#ifdef SWIGGO
// FIXME: SWIG/Go tries to wrap this by generating code which tries to
// assign a const char* value to a char* variable.
%ignore should_be_string;
#endif

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
%}


// These are ignored as unable to deduce decltype for (&i)
%ignore B::k;
%ignore B::get_number_address;
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

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

    auto scaled(int v, double factor) -> decltype(v * factor) {
      return v * factor;
    }
  };

  // An expression over parameters takes their types, not those of globals of the same names.
  double shadow_x = 1.5, shadow_y = 2.5;
  auto shadowed_sum(int shadow_x, int shadow_y) -> decltype(shadow_x + shadow_y) {
    return shadow_x + shadow_y;
  }
  auto shadowed_negate(const short &shadow_x) -> decltype(-shadow_x) {
    return -shadow_x;
  }

  // Members named in a trailing return type are looked up in the class, not outside it where the wrapper is.
  double shadow_mf(int) { return 0.5; }
  struct MemberTrailing {
    int d;
    int h() const { return 7; }
    int shadow_mf() const { return 8; }
    auto via_this() const -> decltype(this->d) { return d; }
    auto this_sum() const -> decltype(this->d + 1) { return d + 1; }
    auto call() const -> decltype(h()) { return h(); }
    auto call_sum() const -> decltype(h() * 2) { return h() * 2; }
    auto shadowed_call() const -> decltype(shadow_mf()) { return shadow_mf(); }
    auto self_ptr() -> decltype(this) { return this; }
    auto self_cptr() const -> decltype(this) { return this; }
    auto self_deref() const -> decltype(*this) { return *this; }
    // A ref-qualifier applies to the object expression, not to 'this'.
    auto self_ref_ptr() & -> decltype(this) { return this; }
    auto self_cref_deref() const & -> decltype(*this) { return *this; }
  };

  template<class T> struct TemplateTrailing {
    T v;
    auto self_ptr() -> decltype(this) { return this; }
    auto self_deref() -> decltype(*this) { return *this; }
    auto via_this() const -> decltype(this->v) { return v; }
  };
%}
%template(TemplateTrailingInt) TemplateTrailing<int>;

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) lvalue_ptr;

%inline %{
  // A dereference is an lvalue, so these return 'int &'.
  int lvalue_values[3] = { 4, 5, 6 };
  int *lvalue_ptr = lvalue_values;
  auto deref_lvalue() -> decltype(*lvalue_ptr) { return *lvalue_ptr; }
  auto parameter_deref(int *p) -> decltype(*p) { return *p; }
  auto deref_sum(int *p) -> decltype(*p + 1) { return *p + 1; }
%}

%ignore Indexed::operator[];
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) subscript_ref;

%inline %{
  // A subscript is an lvalue too, so these are 'int &', as is what the one operator[] of Indexed returns.
  struct Indexed {
    int values[3];
    int &operator[](int i) { return values[i]; }
  };
  Indexed indexed = { { 7, 8, 9 } };
  int subscript_values[3] = { 10, 20, 30 };
  void set_subscript_value(int i, int v) { subscript_values[i] = v; }
  auto subscript_lvalue() -> decltype(lvalue_values[1]) { return lvalue_values[1]; }
  auto parameter_subscript(int *p, int i) -> decltype(p[i]) { return p[i]; }
  auto subscript_sum(int *p) -> decltype(p[1] + 1) { return p[1] + 1; }
  auto indexed_element() -> decltype(indexed[2]) { return indexed[2]; }
  decltype(subscript_values[1]) subscript_ref = subscript_values[1];
  decltype("abc"[1]) literal_element_ref = "abc"[1];

  // A name followed by '[' starting a template argument is an array type, not a subscript.
  template<class T> struct ArrayHolder {
    T held;
    static const int count = sizeof(T) / sizeof(int);
  };
  typedef int HeldElement;
%}
%template(ArrayHolder3) ArrayHolder<HeldElement[3]>;

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

  // An enumerator is a prvalue, so a parenthesised one names its enumeration as the unparenthesised one does.
  namespace EnumSpace {
    enum Hue { hue_red, hue_blue };
  }
  decltype((enumerated_b)) paren_enumerator = enumerated_b;                                     // Enumerated
  decltype((Enumerated::enumerated_b)) paren_qualified_enumerator = enumerated_b;                // Enumerated
  decltype((ScopedEnumerated::scoped_b)) paren_scoped_enumerator = ScopedEnumerated::scoped_b;   // ScopedEnumerated
  decltype((EnumSpace::hue_blue)) paren_namespace_enumerator = EnumSpace::hue_blue;              // EnumSpace::Hue
%}

%module cpp11_auto_variable

%ignore func();

%inline %{

static auto t = true;
static constexpr auto f = false;

static auto zero = 0;
static constexpr auto one = 1;

// Cv-qualified auto, either ordering.
static const auto cz = 2;
static auto const zc = 3;

static auto la = 1.0L;
static auto da = 1.0;
static auto fa = 1.0f;
static constexpr auto lc = 1.0L;
static constexpr auto dc = 1.0;
static constexpr auto fc = 1.0f;

static constexpr auto pi_approx = 355. / 133;

static constexpr auto Bar = "foo";
static constexpr auto Foo = "bar";

static constexpr auto Bar2 = Bar;
static constexpr auto Foo2 = Foo;

static auto Bar3 = f ? zero : t;
static constexpr auto Foo3 = f ? f : one;

int func() { return 1; }
static constexpr auto NOEXCEPT_FUNC = noexcept(func);

%}

// The address of a variable in scope deduces to a pointer to that variable's type.  A setter for a
// pointer variable is not what is under test here, so they are read only.
%immutable ptr_t;
%immutable ptr_zero;

%inline %{
static auto ptr_t = &t;                    // bool *
static constexpr auto ptr_f = &f;          // const bool *
static auto ptr_zero = &zero;              // int *
static constexpr auto ptr_one = &one;      // const int *
static const auto const_ptr_zero = &zero;  // int *const
%}

// SWIG can't deduce the type from a function call.
// Test two approaches to suppressing the warning.
%ignore Bad1;
%warnfilter(SWIGWARN_CPP11_AUTO) Bad2;

%inline %{
static auto Bad1 = func();
static auto Bad2 = func();
%}
%{
// Wunused-variable warning suppression
bool warning_suppression() {
  return Bad1 != 0 || Bad2 != 0;
}
%}

%inline %{
// Concatenation of a literal with an encoding prefix and one without
// was added in C++11.
static auto wstring_lit_len1 = sizeof(L"123" "456") / sizeof(wchar_t) - 1;
static auto wstring_lit_len2 = sizeof("123" L"456") / sizeof(wchar_t) - 1;
%}

%inline %{

// FIXME: Not currently handled by SWIG's parser:
//static auto constexpr greeting = "Hello";

// Direct-initialisation of an auto variable, deferred for now:
//static auto direct(42);

%}

%{
// Suppress -Wparentheses warnings since we're testing correct handling of
// operator precedence in the absence of parentheses to enforce the order.
#ifdef __GNUC__
# pragma GCC diagnostic ignored "-Wparentheses"
#endif
%}
%inline %{
// Regression test for #3058.
auto CAST_HAD_WRONG_PRECEDENCE1 = (0)*1+2;
auto CAST_HAD_WRONG_PRECEDENCE2 = (0)&1|2;
auto CAST_HAD_WRONG_PRECEDENCE3 = (0)-1|2;
auto CAST_HAD_WRONG_PRECEDENCE4 = (0)+1|2;
%}

%module cpp11_auto_variable

%ignore func();

%inline %{

static auto t = true;
static constexpr auto f = false;

static auto zero = 0;
static constexpr auto one = 1;

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

// SWIG currently can't deduce the type for examples below.
// Test two approaches to suppressing the warning.
%ignore Bad1;
%ignore Bad2;
%warnfilter(SWIGWARN_CPP11_AUTO) Bad3;
%warnfilter(SWIGWARN_CPP11_AUTO) Bad4;

%inline %{

static auto Bad1 = &t;
static constexpr auto Bad2 = &f;
static auto Bad3 = &zero;
static constexpr auto Bad4 = &one;

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

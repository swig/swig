%module cpp11_auto_variable

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

// FIXME: Not currently handled by SWIG's parser:
//static auto constexpr greeting = "Hello";

%}

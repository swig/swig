%module cpp11_auto_variable

%inline %{

static auto t = true;
static constexpr auto f = false;

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

%}

// SWIG currently can't deduce the type for examples below:
%ignore Bar3;
%ignore Foo3;
%warnfilter(SWIGWARN_CPP11_AUTO) Bar4;
%warnfilter(SWIGWARN_CPP11_AUTO) Foo4;

%inline %{

static auto Bar3 = f ? Bar : Bar2;
static constexpr auto Foo3 = f ? Foo : Foo2;

static auto Bar4 = f ? Bar : Bar2;
static constexpr auto Foo4 = f ? Foo : Foo2;


// FIXME: Not currently handled:
//static auto constexpr greeting = "Hello";

%}

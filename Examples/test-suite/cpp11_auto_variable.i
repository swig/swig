%module cpp11_auto_variable

%inline %{

static auto t = true;
static constexpr auto f = false;

%}

// SWIG currently can't deduce the type for examples below:
#pragma SWIG nowarn=SWIGWARN_CPP11_AUTO

%inline %{

static auto Bar = "foo";
static constexpr auto Foo = "bar";

static auto Bar2 = Bar;
static constexpr auto Foo2 = Foo;

static auto Bar3 = f ? Bar : Bar2;
static constexpr auto Foo3 = f ? Foo : Foo2;

// FIXME: Not currently handled:
//static auto constexpr greeting = "Hello";

%}

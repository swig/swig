%module cpp14_generic_lambda

// C++14 generic lambdas - lambdas with one or more 'auto' parameters.  Each auto parameter introduces an
// invented type template parameter at the C++ level. Lambdas are not directly wrapped, this test shows
// one way to make them available via a manually written C++ function wrapper.

%warnfilter(SWIGWARN_CPP11_LAMBDA);

%inline %{
// Single auto parameter.
auto twice = [](auto x) { return x + x; };

// Two auto parameters.
auto add = [](auto a, auto b) { return a + b; };

int thing = 7;

// C++14 also allows the explicit trailing return type to be the 'auto' placeholder, cv-qualified
// or decorated, the return type then being deduced from the body.
auto negate_value = [](int x) -> auto { return -x; };
auto halve = [](int x) -> const auto { return x / 2; };
auto quarter = [](int x) -> auto const { return x / 4; };
auto reference_thing = [](int) -> auto&& { return thing; };
auto address_of_thing = [](int) -> auto* { return &thing; };

int run_twice(int x)        { return twice(x); }
int run_add(int a, int b)   { return add(a, b); }
int run_negate_value(int x) { return negate_value(x); }
int run_halve(int x)        { return halve(x); }
int run_quarter(int x)      { return quarter(x); }
int run_reference_thing()   { return reference_thing(0); }
int run_address_of_thing()  { return *address_of_thing(0); }
%}

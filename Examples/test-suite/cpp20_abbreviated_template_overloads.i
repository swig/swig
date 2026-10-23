%module cpp20_abbreviated_template_overloads

// Overload identity of C++20 abbreviated function templates.
//
//   - Two %template instantiations of one abbreviated function template given the same target
//     language name are overloads of each other, told apart by the types they instantiate to,
//     exactly as two instantiations of an explicitly written template are.
//
//   - %ignore naming one of two constrained abbreviated overloads by its written declarator
//     leaves the other instantiable, whichever of the two is named.

// The Integral overload is ignored, so classify_double wraps the FloatingPoint one.
%ignore classify(Integral auto);

// The FloatingPoint overload is ignored, so pick_int wraps the Integral one.
%ignore pick(FloatingPoint auto);

// A target language with one numeric type keeps one of the two scaled overloads and drops the other.
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED, SWIGWARN_LANG_OVERLOAD_SHADOW) scaled;

%inline %{
#include <concepts>

template<typename T>
concept Integral = std::integral<T>;

template<typename T>
concept FloatingPoint = std::floating_point<T>;

// One abbreviated function template instantiated twice under one name.  The value returned
// says which instantiation ran, so a dispatcher that reaches the wrong one shows up.
int scaled(auto x) { return int(x * 10); }

int    classify(Integral auto x)      { return int(x) + 1; }
double classify(FloatingPoint auto x) { return x / 2; }

int    pick(Integral auto x)      { return int(x) + 1; }
double pick(FloatingPoint auto x) { return x / 2; }
%}

%template(scaled) scaled<int>;
%template(scaled) scaled<double>;

%template(classify_double) classify<double>;
%template(pick_int)        pick<int>;

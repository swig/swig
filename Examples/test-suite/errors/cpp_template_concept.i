%module xxx

%inline %{
#include <concepts>
template<typename T>
concept Numeric = std::integral<T>;
%}

// Concepts are not types and cannot be %template instantiated.
%template(NumericInt) Numeric<int>;

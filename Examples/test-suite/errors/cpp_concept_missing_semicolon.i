%module xxx

// A concept declaration with no terminating semicolon. The parser reads ahead over the constraint
// expression looking for that semicolon, so this checks it copes with never finding one.

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T>

int after(int x) { return x; }
%}

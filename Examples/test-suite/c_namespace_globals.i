%module c_namespace_globals

// Run with -namespace, as only then are global variables wrapped with accessor functions when wrapping C code
%inline %{
#if defined(__GNUC__)
// Suppress the -Wextra warnings for the const qualified return types
# pragma GCC diagnostic ignored "-Wignored-qualifiers"
#endif

int counter;
const int limit = 5;

const int const_result(int value) {
  return value;
}
%}

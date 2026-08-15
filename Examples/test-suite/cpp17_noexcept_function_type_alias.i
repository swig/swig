%module cpp17_noexcept_function_type_alias

// A noexcept-specifier in an alias declaration, allowed now that it is part of the function type

%inline %{
using alt_noexcept_callback_t = auto (*)(int) noexcept -> int;
using alt_noexcept_function_t = auto (int) noexcept -> int;
using alt_noexcept_expr_callback_t = auto (*)(int) noexcept(true) -> int;

// Alias template - not used in a wrapped declaration as SWIG treats an alias template instantiation as an opaque type.
template<typename T> using alt_noexcept_fn_t = auto (*)(T) noexcept -> T;

int mult2_noexcept(int x) noexcept { return x * 2; }
alt_noexcept_callback_t get_alt_noexcept_callback() { return mult2_noexcept; }
int call_alt_noexcept(alt_noexcept_callback_t funk, int param) { return funk(param); }
int call_alt_noexcept_fn(alt_noexcept_function_t *funk, int param) { return funk(param); }
int call_alt_noexcept_expr(alt_noexcept_expr_callback_t funk, int param) { return funk(param); }
%}

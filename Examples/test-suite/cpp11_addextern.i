%module cpp11_addextern

%{
#if defined(__clang__)
// Suppress: mangled name of 'addexternGetNoexcept' will change in C++17 due to non-throwing exception specification in function signature
#pragma clang diagnostic ignored "-Wc++17-compat-mangling"
#endif
%}

// Run with -addextern, the declarations it adds keep the exception specification of the declared function
%inline %{
int addexternAddOne(int i) { return i + 1; }
extern int addexternNoexcept(int i) noexcept { return i + 1; }
extern int addexternNoexceptExpr(int i) noexcept(sizeof(int) >= 2) { return i + 1; }
extern int addexternNoexceptFalse(int i) noexcept(false) { return i + 1; }
extern int (*addexternGetAddOne() noexcept)(int) { return addexternAddOne; }
extern int (*addexternGetNoexcept())(int) noexcept { return addexternNoexcept; }
extern "C" int addexternNoexceptC(int i) noexcept { return i + 1; }
extern "C" int (*addexternGetAddOneC() noexcept)(int) { return addexternAddOne; }
%}

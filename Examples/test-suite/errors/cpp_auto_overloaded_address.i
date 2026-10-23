%module xxx

// The address of an overloaded function has no type to deduce (C++ rejects these), so SWIG must not pick an overload.
int ov(int) { return 1; }
double ov(double) { return 2; }
struct K { static int sov(int) { return 1; } static double sov(double) { return 2; } };

auto ov_address = &ov;
auto sov_address = &K::sov;
decltype(&ov) ov_decltype = nullptr;

// Not overloaded: deduced as 'int (*)(int)'.
int single(int) { return 3; }
auto single_address = &single;
decltype(&single) single_decltype = nullptr;

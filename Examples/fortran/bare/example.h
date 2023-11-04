/* File : example.h */

#include <cstddef>
#include <utility>

/* -------------------------------------------------------------------------
 * Bare functions
 * ------------------------------------------------------------------------- */

void set_something(int x, double y);
double get_something(int x);
void get_something_ref(int x, double &y);

double &get_something_rref(int x);
const double &get_something_rcref(int x);

// These functions will not support overloading in fortran because the first is
// a "subroutine" and the other a "function".
inline void cannot_overload(int) { /* * */
}
inline int cannot_overload(int x, int y) {
  return x + y;
}

// These functions *can* be overloaded.
inline int can_overload(int x) {
  return x;
}
inline double can_overload(double x) {
  return x;
}

/* -------------------------------------------------------------------------
 * Enums
 * ------------------------------------------------------------------------- */

//! An enumeration declared using external C variables
// (since it has complicated values that must be evaluated by the C compiler)
enum RgbEnum {
  RED = 0,
  GREEN = 0x4,
  BLUE = (1 << 10)
};

//! An enumeration that uses native wrapping
enum CmykEnum { CYAN = 0, MAGENTA, YELLOW, BLACK = -1 };

// Get a color name
void print_rgb(RgbEnum color);
void print_cmyk(CmykEnum color);

/* -------------------------------------------------------------------------
 * Global variables
 * ------------------------------------------------------------------------- */
#if __cplusplus >= 201103
#define CONSTEXPR constexpr
#elif defined(SWIG)
#define CONSTEXPR %constant
#else
#define CONSTEXPR const
#endif

//! An integer that is only known at link time
extern const int linked_const_int;

//! A simple integer
CONSTEXPR int simple_int = 4;

// A more complicated integer
CONSTEXPR int weird_int = (0x1337 | 0x10000);

//! A global constant wrapped as a native parameter
CONSTEXPR double approx_pi = 3.14160000001;

//! A global constant wrapped as a protected external variable
CONSTEXPR double approx_twopi = 2 * approx_pi;

//! A global variable
namespace foo {
extern int global_counter;
}


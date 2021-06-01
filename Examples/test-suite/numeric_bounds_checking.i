%module numeric_bounds_checking

// Tests the bounds checking for integral parameters passed to wrapped functions.
// Note that it needs an accompanying _runme file to perform the actual test.

%inline %{
#include <limits.h>
struct Limits {
  signed char schar_min() { return SCHAR_MIN; }
  signed char schar_max() { return SCHAR_MAX; }
  unsigned char uchar_min() { return 0U; }
  unsigned char uchar_max() { return UCHAR_MAX; }
  short shrt_min() { return SHRT_MIN; }
  short shrt_max() { return SHRT_MAX; }
  unsigned short ushrt_min() { return 0U; }
  unsigned short ushrt_max() { return USHRT_MAX; }
  int int_min() { return INT_MIN; }
  int int_max() { return INT_MAX; }
  unsigned int uint_min() { return 0U; }
  unsigned int uint_max() { return UINT_MAX; }
  long long_min() { return LONG_MIN; }
  long long_max() { return LONG_MAX; }
  unsigned long ulong_min() { return 0UL; }
  unsigned long ulong_max() { return ULONG_MAX; }
#ifdef LLONG_MIN
  long long llong_min() { return LLONG_MIN; }
  long long llong_max() { return LLONG_MAX; }
  unsigned long long ullong_min() { return 0ULL; }
  unsigned long long ullong_max() { return ULLONG_MAX; }
#endif
};

struct Checker {
  signed char pass_schar(signed char v) { return v; }
  unsigned char pass_uchar(unsigned char v) { return v; }
  short pass_shrt(short v) { return v; }
  unsigned short pass_ushrt(unsigned short v) { return v; }
  int pass_int(int v) { return v; }
  unsigned int pass_uint(unsigned int v) { return v; }
  long pass_long(long v) { return v; }
  unsigned long pass_ulong(unsigned long v) { return v; }
#ifdef LLONG_MIN
  long long pass_long(long long v) { return v; }
  unsigned long long pass_ulong(unsigned long long v) { return v; }
#endif
};
%}

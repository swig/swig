%module cpp11_python_pyi_enumvalues
%feature("python:annotations", "typing");

%inline %{
enum DefaultBehavior { DEFAULT_ZERO, DEFAULT_EXPLICIT = 12 };
%}

%feature("python:stub:enumvalues");
%feature("python:stub:enumvalues", "0") OPT_OUT;
%ignore HIDDEN;
%ignore HIDDEN_FIRST;
%rename(RENAMED) ORIGINAL;
%constant int CONSTANT = 23;

%inline %{
enum Values {
  ZERO,
  ONE,
  NEGATIVE = -7,
  NEXT_NEGATIVE,
  HEX = 0x2a,
  OCTAL = 052,
  SUFFIX = 42ULL,
  NEGATIVE_SUFFIX = -42LL,
  HIDDEN = 100,
  AFTER_HIDDEN,
  ORIGINAL,
  OPT_OUT,
  AFTER_OPT_OUT,
  EXPRESSION = 1 << 3,
  AFTER_EXPRESSION,
  RESET = 20,
  AFTER_RESET,
  CAST = (int)30,
  AFTER_CAST,
  REFERENCE = RESET,
  AFTER_REFERENCE,
  NEGATIVE_HEX = -0x2a,
  NEGATIVE_OCTAL = -052,
  LONG_SUFFIX = 42lu
};
enum FirstIgnored { HIDDEN_FIRST, AFTER_HIDDEN_FIRST };
enum UnknownUnsigned : unsigned long long {
  HEX_UNSIGNED_MINUS = -0xffffffff,
  AFTER_HEX_UNSIGNED_MINUS,
  NEGATIVE_UNSIGNED = -1U,
  AFTER_UNSIGNED,
  TOO_LARGE = 18446744073709551615ULL
};
enum SignedBoundary : long long {
  INT_MINIMUM = -2147483648LL,
  NEGATIVE_HEX_LONG_LONG = -0x80000000LL,
  INT_MAXIMUM = 2147483647,
  ABOVE_INT_MAXIMUM
};
enum Boundary : unsigned long long {
  LIMIT = 9223372036854775807LL,
  BOUNDARY_OVERFLOW,
  AFTER_OVERFLOW,
  RECOVER = 4,
  AFTER_RECOVER
};
enum class FirstScope { SHARED = 10, NEXT };
enum class SecondScope { SHARED = 30, NEXT };
struct Holder {
  enum Nested { SHARED = 50, NEXT };
  enum class Scoped { SHARED = 70, NEXT };
  static const int NONENUM = 99;
};
%}

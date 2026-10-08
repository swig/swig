%module matlab_enum
%inline %{
enum { ANONYMOUS_VALUE = 13 };
enum Ordinary { ORDINARY_LOW = -7, ORDINARY_HIGH = 11 };
typedef const Ordinary ConstOrdinary;
typedef volatile Ordinary VolatileOrdinary;
typedef const volatile Ordinary CvOrdinary;
ConstOrdinary echo_const(ConstOrdinary value) { return value; }
Ordinary echo_volatile(VolatileOrdinary value) { return value; }
Ordinary echo_cv(CvOrdinary value) { return value; }
enum Ordinary echo_ordinary(enum Ordinary value) { return value; }
%}

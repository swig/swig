%module matlab_enum_c
%inline %{
enum { ANONYMOUS_VALUE = 13 };
enum Ordinary { ORDINARY_LOW = -7, ORDINARY_HIGH = 11 };
enum Ordinary echo_ordinary(enum Ordinary value) { return value; }
%}

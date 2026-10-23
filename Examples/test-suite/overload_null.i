%module overload_null

%{
struct F {};
%}

%inline %{
struct X {};
struct Y {};
struct F;
enum OverloadNullEnum { OverloadNullEnumValue };

struct Overload {
  int byval1(X x) { return 1; }
  int byval1(Y* y) { return 2; }

  int byval2(Y* y) { return 3; }
  int byval2(X x) { return 4; }

  int byref1(X& x) { return 5; }
  int byref1(Y* y) { return 6; }

  int byref2(Y* y) { return 7; }
  int byref2(X& x) { return 8; }

  int byconstref1(const X& x) { return 9; }
  int byconstref1(Y* y) { return 10; }

  int byconstref2(Y* y) { return 11; }
  int byconstref2(const X& x) { return 12; }

  // const pointer references
  int byval1cpr(X x) { return 13; }
  int byval1cpr(Y*const& y) { return 14; }

  int byval2cpr(Y*const& y) { return 15; }
  int byval2cpr(X x) { return 16; }

  // fwd class declaration
  int byval1fwdptr(X x) { return 17; }
  int byval1fwdptr(F* f) { return 18; }

  int byval2fwdptr(F* f) { return 19; }
  int byval2fwdptr(X x) { return 20; }

  int byval1fwdref(X x) { return 21; }
  int byval1fwdref(F& f) { return -21; }

  int byval2fwdref(F& f) { return -22; }
  int byval2fwdref(X x) { return 22; }

  // NULL is not a char
  int bychar1(char c) { return 23; }
  int bychar1(const char *s) { return 24; }

  // NULL is a NULL pointer for an array of numbers, enums or strings and for a pointer to a bool or an enum
  int byintarray(X x) { return 25; }
  int byintarray(int a[2]) { return 26; }

  int bydoublearray(X x) { return 27; }
  int bydoublearray(double a[]) { return 28; }

  int byenumarray(X x) { return 29; }
  int byenumarray(OverloadNullEnum a[2]) { return 30; }

  int bystringarray(X x) { return 31; }
  int bystringarray(char *a[2]) { return 32; }

  int byboolptr(X x) { return 33; }
  int byboolptr(bool *b) { return 34; }

  int byenumptr(X x) { return 35; }
  int byenumptr(OverloadNullEnum *e) { return 36; }

  // NULL is a NULL pointer for an array of char too, although the array is otherwise a string
  int bychararray(X x) { return 37; }
  int bychararray(char a[4]) { return a ? 38 : -38; }

  int byunsizedchararray(X x) { return 39; }
  int byunsizedchararray(char a[]) { return a ? 40 : -40; }

};
%}

%module overload_null

%{
struct F {};
%}

%inline %{
struct X {};
struct Y {};
struct F;

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

};
%}

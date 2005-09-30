%module compactdefaultargs

// compactdefaultargs off by default

// The following should compile with compactdefaultargs off
%inline %{
class Defaults1 {
  static const int private_default = -1;
public:
  static const double public_default = -1.0;
  Defaults1(int a = private_default) {}
  double ret(double d = public_default) { return d; }
};
%}


// compactdefaultargs now on by default
%feature("compactdefaultargs");

// Turn compactdefaultargs off for the ret method which can't work with this feature
%feature("compactdefaultargs", "0") Defaults2(int a = private_default);

%inline %{
class Defaults2 {
  static const int private_default = -1;
public:
  static const double public_default = -1.0;
  Defaults2(int a = private_default) {}
  double ret(double d = public_default) { return d; }
};
%}


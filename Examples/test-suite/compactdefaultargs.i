%module compactdefaultargs

// compactdefaultargs off by default

// The following should compile with compactdefaultargs off
%inline %{
class Defaults1 {
  static const int PRIVATE_DEFAULT = -1;
public:
  static const double PUBLIC_DEFAULT;
  Defaults1(int a = PRIVATE_DEFAULT) {}
  double ret(double d = PUBLIC_DEFAULT) { return d; }
};
%}

%{
const double Defaults1::PUBLIC_DEFAULT = -1.0;
const int abc = 1234;
int def = 1234;
%}

// compactdefaultargs now on by default
%feature("compactdefaultargs");

// Turn compactdefaultargs off for the constructor which can't work with this feature
%feature("compactdefaultargs", "0") Defaults2(int a = PRIVATE_DEFAULT);

%inline %{
class Defaults2 {
  static const int PRIVATE_DEFAULT = -1;
public:
  static const double PUBLIC_DEFAULT;
  Defaults2(int a = PRIVATE_DEFAULT) {}
  double ret(double d = PUBLIC_DEFAULT) { return d; }
  double nodefault(int x) { return x; }

  typedef const Defaults1& ConstDefaults1;
  void references(const Defaults1& d10 = Defaults1(10), ConstDefaults1 d20 = Defaults1(20)) {}
};

void string_function(const char *str = "") {}
void ptr_function(const int *p1 = &abc, int *p2 = &def) {}
%}

%{
const double Defaults2::PUBLIC_DEFAULT = -1.0;
%}

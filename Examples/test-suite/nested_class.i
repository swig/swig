%module nested_class

#pragma SWIG nowarn=SWIGWARN_PARSE_NESTED_CLASS

%inline %{
struct Outer {
  struct Inner1 {
    int x;
  };

  class Inner2 {
  public:
    int x;
  };

  class {
  public:
    int a;
  };

  struct {
    int b;
  };

  union {
    int c;
    double d;
  };

  class Inner3 {
  public:
    int x;
  } Inner3Name;

  struct Inner4 {
    int x;
  } Inner4Name;
};

%}

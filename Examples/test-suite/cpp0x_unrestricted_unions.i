/* This testcase checks whether Swig correctly parses the support for types
   without the defined trivial constructor in the unions. */
%module cpp0x_unrestricted_unions

%inline %{
struct point {
  point() {}
  point(int x, int y) : x_(x), y_(y) {}
  int x_, y_;
};

union P {
  int z;
  double w;
  point p;
} p1;
%}


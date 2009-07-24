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


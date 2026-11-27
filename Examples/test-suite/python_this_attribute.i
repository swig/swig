%module python_this_attribute

%inline %{
struct Point {
  int x;
  Point(int value) : x(value) {}
};

Point *global_point() {
  static Point p(5);
  return &p;
}

int point_x(const Point &p) {
  return p.x;
}

#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}

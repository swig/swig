%module swift_c

// Swift-specific runtime test for a plain C interface: free functions, a C
// enumeration, a POD struct and a #define constant.  The Swift backend targets
// C++, so this C interface is wrapped with SWIG's -c++ option (the generated
// wrapper is C++ even though the interface itself is plain C).

#define SWIFT_C_ANSWER 42

%inline %{
int swig_c_add(int a, int b) { return a + b; }
double swig_c_scale(double x, double factor) { return x * factor; }

enum Color { RED, GREEN, BLUE };
enum Color next_color(enum Color c) { return (enum Color)((c + 1) % 3); }

typedef struct {
  int x;
  int y;
} Point;

Point make_point(int x, int y) {
  Point p;
  p.x = x;
  p.y = y;
  return p;
}

int point_sum(Point p) { return p.x + p.y; }
%}

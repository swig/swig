%module(directors="1") swift_director_upcall

// Swift-specific test: a virtual method of a director class must reach C++.
// Called on the Swift object the director was created from it runs the C++
// base implementation (or throws for a pure virtual); called on a proxy that
// wraps a C++ object it dispatches virtually, so a C++ override or a Swift
// override in a director subclass runs.

%feature("director") Shape;
%feature("director") Sink;

%newobject make_triangle;

%inline %{
class Shape {
public:
  virtual ~Shape() {}
  virtual int sides() const { return 42; }
  int describe() const { return sides(); }
};

// A C++ subclass that is not a director.
class Triangle : public Shape {
public:
  virtual int sides() const { return 3; }
};

Shape *make_triangle() { return new Triangle(); }

// Hands the same C++ object back, so Swift wraps it in a fresh Shape proxy.
Shape *same_shape(Shape *s) { return s; }

class Sink {
public:
  virtual ~Sink() {}
  virtual int consume(int x) = 0;
  int feed(int x) { return consume(x); }
};
%}

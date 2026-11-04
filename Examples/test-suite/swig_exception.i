/* File : swig_exception.i
 * Test SWIG_exception().
 */
%module swig_exception

%include exception.i

%exception {
    try {
        $action
    } catch (std::exception& e) {
      SWIG_exception(SWIG_SystemError, e.what());
    }
}

%inline %{
class Value {
  int a_;
  int b_;
public:
  Value(int a, int b) : a_(a), b_(b) {}
};

class Shape {
public:
  Shape() {
    nshapes++;
  }
  virtual ~Shape() {
    nshapes--;
  }
  double  x, y;
  void    move(double dx, double dy);
  virtual double area() = 0;
  virtual double perimeter() = 0;
  virtual Value throwException();
  static  int nshapes;
};

class Circle : public Shape {
private:
  double radius;
public:
  Circle(double r) : radius(r) { }
  virtual double area();
  virtual double perimeter();
};

class Square : public Shape {
private:
  double width;
public:
  Square(double w) : width(w) { }
  virtual double area();
  virtual double perimeter();
};
%}

%{
#define PI 3.14159265358979323846

#include <stdexcept>

/* Move the shape to a new location */
void Shape::move(double dx, double dy) {
  x += dx;
  y += dy;
}

Value Shape::throwException() {
    throw std::logic_error("OK");
}

int Shape::nshapes = 0;

double Circle::area() {
  return PI*radius*radius;
}

double Circle::perimeter() {
  return 2*PI*radius;
}

double Square::area() {
  return width*width;
}

double Square::perimeter() {
  return 4*width;
}
%}

%exception throwIndexError {
  try {
    $action
  } catch (std::out_of_range& e) {
    SWIG_exception(SWIG_IndexError, e.what());
  }
}

%inline %{
int throwIndexError() {
  throw std::out_of_range("index out of range");
}
%}

// A 'throws' typemap with a local variable
%typemap(throws, canthrow=1) int (const char *message) {
  message = $1 == 1 ? "int 1 thrown" : "int thrown";
  SWIG_exception(SWIG_RuntimeError, message);
}
%catches(int) throwInt;

%inline %{
int throwInt() {
  throw 1;
}
%}

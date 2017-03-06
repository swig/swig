%module member_pointer_const
// Same as member_pointer.i but using member pointer const functions

%{
#if defined(__SUNPRO_CC)
#pragma error_messages (off, badargtype2w) /* Formal argument ... is being passed extern "C" ... */
#pragma error_messages (off, wbadinit) /* Using extern "C" ... to initialize ... */
#pragma error_messages (off, wbadasg) /* Assigning extern "C" ... */
#endif
%}

%inline %{
class Shape {
public:
  Shape() {
    nshapes++;
  }
  virtual ~Shape() {
    nshapes--;
  };
  double  x, y;
  double  *z;

  void    move(double dx, double dy);
  virtual double area(void) const = 0;
  virtual double perimeter(void) const = 0;
  static  int nshapes;
};

class Circle : public Shape {
private:
  double radius;
public:
  Circle(double r) : radius(r) { };
  virtual double area(void) const;
  virtual double perimeter(void) const;
};

class Square : public Shape {
private:
  double width;
public:
  Square(double w) : width(w) { };
  virtual double area(void) const;
  virtual double perimeter(void) const;
};

/* Typedef */
typedef double (Shape::*PerimeterFunc_td)(void) const;

extern double do_op(Shape *s, double (Shape::*m)(void) const);
extern double do_op_td(Shape *s, PerimeterFunc_td m);

/* Functions that return member pointers */

extern double (Shape::*areapt())(void) const;
extern double (Shape::*perimeterpt())(void) const;
extern PerimeterFunc_td perimeterpt_td();

/* Global variables that are member pointers */
extern double (Shape::*areavar)(void) const;
extern double (Shape::*perimetervar)(void) const;
extern PerimeterFunc_td perimetervar_td;
%}

%{
#  define SWIG_M_PI 3.14159265358979323846

/* Move the shape to a new location */
void Shape::move(double dx, double dy) {
  x += dx;
  y += dy;
}

int Shape::nshapes = 0;

double Circle::area(void) const {
  return SWIG_M_PI*radius*radius;
}

double Circle::perimeter(void) const {
  return 2*SWIG_M_PI*radius;
}

double Square::area(void) const {
  return width*width;
}

double Square::perimeter(void) const {
  return 4*width;
}

double do_op(Shape *s, double (Shape::*m)(void) const) {
  return (s->*m)();
}

double do_op_td(Shape *s, PerimeterFunc_td m) {
  return (s->*m)();
}

double (Shape::*areapt())(void) const {
  return &Shape::area;
}

double (Shape::*perimeterpt())(void) const {
  return &Shape::perimeter;
}

PerimeterFunc_td perimeterpt_td() {
  return &Shape::perimeter;
}

/* Member pointer variables */
double (Shape::*areavar)(void) const = &Shape::area;
double (Shape::*perimetervar)(void) const = &Shape::perimeter;
PerimeterFunc_td perimetervar_td = &Shape::perimeter;
%}


/* Some constants */
%constant double (Shape::*AREAPT)(void) const = &Shape::area;
%constant double (Shape::*PERIMPT)(void) const = &Shape::perimeter;
%constant double (Shape::*NULLPT)(void) const = 0;

/*
%inline %{
  struct Funktions {
    void retByRef(int & (*d)(double)) {}
  };
  void byRef(int & (Funktions::*d)(double)) {}
%}
*/

%inline %{

struct Funktions {
  int addByValue(const int &a, int b) const { return a+b; }
  int * addByPointer(const int &a, int b) const { static int val; val = a+b; return &val; }
  int & addByReference(const int &a, int b) const { static int val; val = a+b; return val; }
};

int call1(int (Funktions::*d)(const int &, int) const, int a, int b) { Funktions f; return (f.*d)(a, b); }
//int call2(int * (Funktions::*d)(const int &, int) const, int a, int b) { Funktions f; return *(f.*d)(a, b); }
//int call3(int & (Funktions::*d)(const int &, int) const, int a, int b) { Funktions f; return (f.*d)(a, b); }
%}

%constant int (Funktions::*ADD_BY_VALUE)(const int &, int) const = &Funktions::addByValue;
//%constant int * (Funktions::*ADD_BY_POINTER)(const int &, int) const = &Funktions::addByPointer;
//%constant int & (Funktions::*ADD_BY_REFERENCE)(const int &, int) const = &Funktions::addByReference;

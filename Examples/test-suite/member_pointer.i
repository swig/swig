%module member_pointer

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
  virtual double area(void) = 0;
  virtual double perimeter(void) = 0;
  static  int nshapes;
};

class Circle : public Shape {
private:
  double radius;
public:
  Circle(double r) : radius(r) { };
  virtual double area(void);
  virtual double perimeter(void);
};
  
class Square : public Shape {
private:
  double width;
public:
  Square(double w) : width(w) { };
  virtual double area(void);
  virtual double perimeter(void);
};

extern double do_op(Shape *s, double (Shape::*m)(void));

/* Functions that return member pointers */

extern double (Shape::*areapt())(void);
extern double (Shape::*perimeterpt())(void);

/* Global variables that are member pointers */
extern double (Shape::*areavar)(void);
extern double (Shape::*perimetervar)(void);

%}

%{
#  define M_PI 3.14159265358979323846

/* Move the shape to a new location */
void Shape::move(double dx, double dy) {
  x += dx;
  y += dy;
}

int Shape::nshapes = 0;

double Circle::area(void) {
  return M_PI*radius*radius;
}

double Circle::perimeter(void) {
  return 2*M_PI*radius;
}

double Square::area(void) {
  return width*width;
}

double Square::perimeter(void) {
  return 4*width;
}

double do_op(Shape *s, double (Shape::*m)(void)) {
  return (s->*m)();
}

double (Shape::*areapt())(void) {
  return &Shape::area;
}

double (Shape::*perimeterpt())(void) {
  return &Shape::perimeter;
}

/* Member pointer variables */
double (Shape::*areavar)(void) = &Shape::area;
double (Shape::*perimetervar)(void) = &Shape::perimeter;
%}


/* Some constants */
%constant double (Shape::*AREAPT)(void) = &Shape::area;
%constant double (Shape::*PERIMPT)(void) = &Shape::perimeter;
%constant double (Shape::*NULLPT)(void) = 0;


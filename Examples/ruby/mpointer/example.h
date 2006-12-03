/* File : example.h */

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

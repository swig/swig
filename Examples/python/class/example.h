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
  char   foo[256];
  void    move(double dx, double dy);
  virtual double area() = 0;
  virtual double perimeter() = 0;
  char *name() { return "Shape"; }
  static  int nshapes;
};

class Circle : public Shape {
private:
  double radius;
public:
  Circle(double r) : radius(r) { };
  virtual double area();
  virtual double perimeter();
};

class XCircle : public Circle {
 public:
  XCircle(double r) : Circle(r) { };
  virtual double area();
  char *name() { return "XCircle"; }
};
  
class Square : public Shape {
private:
  double width;
public:
  Square(double w) : width(w) { };
  virtual double area();
  virtual double perimeter();
};




  

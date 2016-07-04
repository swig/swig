/* File : example.h */

class _Shape {
public:
  _Shape() {
    nshapes++;
  }
  virtual ~_Shape() {
    nshapes--;
  }
  double  x, y;
  void    move(double dx, double dy);
  virtual double area() = 0;
  virtual double perimeter() = 0;
  static  int nshapes;
};

class Circle : public _Shape {
private:
  double radius;
public:
  Circle(double r) : radius(r) { }
  virtual double area();
  virtual double perimeter();
};

class Square : public _Shape {
private:
  double width;
public:
  Square(double w) : width(w) { }
  virtual double area();
  virtual double perimeter();
};

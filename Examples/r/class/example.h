/* File : example.h */

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
  static  int nshapes;
};

class Circle : public Shape {
private:
  double radius;
public:
  Circle(double r) : radius(r) { }
  Circle(double xx, double yy, double rr);
  virtual double area();
  virtual double perimeter();

  bool operator==(const Circle & other);
  bool operator!=(const Circle & other);
};

class Square : public Shape {
private:
  double width;
public:
  Square(double w) : width(w) { }
  virtual double area();
  virtual double perimeter();

  bool operator==(const Square & other);
  bool operator!=(const Square & other);
};

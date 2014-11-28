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
  virtual double area();

  // Test overloading
  virtual double foo(int d){ return area();}
  virtual double foo(){ return perimeter();}

  // Static methods
  static int give_me_nshapes(){ return nshapes;}

  static int give_me_nshapes2(){ return nshapes;}
  static int give_me_nshapes2(int i){ return nshapes+i;}

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

// Test multiple inheritance
class CircleInscribedInSquare : public Circle, public Square {
private:
public:
  CircleInscribedInSquare(double w) : Circle(w/2.0), Square(w) { }

  virtual double area();
//#define FIXME_SWIGMATLAB // uncomment this to demonstrate matlab choke
#ifdef FIXME_SWIGMATLAB
  virtual double perimeter();
#endif
  // let perimeter resolve itself
};

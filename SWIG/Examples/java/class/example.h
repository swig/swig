/* File : example.h */

extern int nshapes; //global variable temporarily replacing static member variable due to static member variable bug in swig core
class Shape {
public:
  Shape() {
    nshapes++;
  }
  virtual ~Shape() {
    nshapes--;
  };
  double  x, y;   
  void    move(double dx, double dy);
  virtual double area() = 0;
  virtual double perimeter() = 0;
//  static  int nshapes;
};

class Circle : public Shape {
private:
  double radius;
public:
  Circle(double r) : radius(r) { };
  virtual double area();
  virtual double perimeter();
};
  
class Square : public Shape {
private:
  double width;
public:
  Square(double w) : width(w) { };
  virtual double area();
  virtual double perimeter();
};




  

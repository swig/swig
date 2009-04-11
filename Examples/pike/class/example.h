/* File : example.h */

class Shape {
public:
  Shape();
  virtual ~Shape();
  double  x, y;   
  void    move(double dx, double dy);
  virtual double area() const = 0;
  virtual double perimeter() const = 0;
  static  int nshapes;
};

class Circle : public Shape {
private:
  double radius;
public:
  Circle(double r) : radius(r) { };
  virtual double area() const;
  virtual double perimeter() const;
};

class Square : public Shape {
private:
  double width;
public:
  Square(double w) : width(w) { };
  virtual double area() const;
  virtual double perimeter() const;
};




  

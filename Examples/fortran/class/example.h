/* File : example.h */
class Shape {
public:
  static int nshapes;
  double x, y;

  Shape() { nshapes++; }
  virtual ~Shape() = 0;
  void move(double dx, double dy);
  virtual double area() const = 0;
  virtual double perimeter() const = 0;
};

class Circle : public Shape {
private:
  double radius;

public:
  explicit Circle(double r);
  virtual double area() const;
  virtual double perimeter() const;
};

class Square : public Shape {
private:
  double width;

public:
  explicit Square(double w) : width(w) {}
  virtual double area() const;
  virtual double perimeter() const;
};

class Sphere {
private:
  double radius;

public:
  explicit Sphere(double r);
  double volume() const;
};

// Function takes the base class and calls virtual functions
double surface_to_volume(const Shape &s);
/* vim: set ts=2 sw=2 sts=2 tw=129 : */

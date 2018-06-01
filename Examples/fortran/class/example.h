/* File : example.h */
class Shape {
public:
  static int nshapes;
  double x, y;

  Shape();
  virtual ~Shape() = 0;
  virtual double area() const = 0;
  virtual double perimeter() const = 0;
  virtual const char* kind() const = 0;
};

class Circle : public Shape {
private:
  double radius;

public:
  explicit Circle(double r);
  virtual double area() const;
  virtual double perimeter() const;
  virtual const char* kind() const { return "circle"; }
};

class Square : public Shape {
private:
  double width;

public:
  explicit Square(double w) : width(w) {}
  virtual double area() const;
  virtual double perimeter() const;
  virtual const char* kind() const { return "square"; }
};

class Sphere {
private:
  double radius;

public:
  explicit Sphere(double r);
  double volume() const;
  const char* kind() const { return "sphere"; }
};

// Function takes the base class and calls virtual functions
double surface_to_volume(const Shape &s);


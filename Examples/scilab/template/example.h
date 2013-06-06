/* File : example.h */

template<typename T>
class Shape {
private:
  static int nbshapes;
public:
  Shape()  { x = 0; y = 0; nbshapes++; }
  virtual ~Shape() { nbshapes--; };
  T x, y;
  void move(T dx, T dy);
  virtual T area() = 0;
  virtual T perimeter() = 0;
  static int getNbShapes();
};

template<typename T>
class Circle : public Shape<T> {
private:
  T radius;
public:
  Circle(T r) : Shape<T>() { radius = r; };
  virtual T area();
  virtual T perimeter();
};

template<typename T>
class Square : public Shape<T> {
private:
  T width;
public:
  Square(T w) : Shape<T>() { width = w; };
  virtual T area();
  virtual T perimeter();
};


/* File : example.h */

class Shape
{
public:
  Shape ()
  {
    nshapes++;
  }
  virtual ~ Shape ()
  {
    nshapes--;
  };
  double x, y;
  void move (double dx, double dy);
  virtual double area (void) const = 0;
  virtual double perimeter (void) const = 0;
protected:
  static int nshapes;
};

class Circle:public Shape
{
private:
  double radius;
public:
    Circle (double r):radius (r)
  {
  };
  virtual double area (void) const;
  virtual double perimeter (void) const;
};

class Square:public Shape
{
private:
  double width;
public:
    Square (double w):width (w)
  {
  };
  virtual double area (void) const;
  virtual double perimeter (void) const;
};

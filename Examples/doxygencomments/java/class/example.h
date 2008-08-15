/** \file example.h 
comments on example.h */

/*! This is describing class Shape
 \author Bob
 */

class Shape {
public:
  Shape() {
    nshapes++;
  }
  virtual ~Shape() {
    nshapes--;
  };
  double  x, y; /*!< Important things  */
  void    move(double dx, double dy);
  virtual double area(void) = 0; /*!< \return the area */
  virtual double perimeter(void) = 0; /*!< \return the perimeter */
  static  int nshapes;
};
/*! This is describing class Circle */
class Circle : public Shape {
private:
  double radius;
public:
  Circle(double r) : radius(r) { };
  virtual double area(void);
  virtual double perimeter(void);
};

/*! This is describing class square */
class Square : public Shape {
private:
  double width;
public:
  Square(double w) : width(w) { };
  virtual double area(void);
  virtual double perimeter(void);
};




  

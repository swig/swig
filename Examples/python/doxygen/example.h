/*! \file example.h 
This file provides a simple set of Shape classes. */

/*! Base class for all shapes.
 \author Bob
 */
class Shape {
public:
  /*! Default constructor for creating a Shape */
  Shape() {
    nshapes++;
  }
  /*! Destructor for destroying a Shape */
  virtual ~Shape() {
    nshapes--;
  }
  double x; /*!< x co-ordinate */
  double y; /*!< y co-ordinate */
  void    move(double dx, double dy); /*!< Move a shape to a new co-ordinate
  \param dx x co-ordinate
  \param dy y co-ordinate */
  virtual double area() = 0; /*!< \return the area */
  virtual double perimeter() = 0; /*!< \return the perimeter */
  static  int nshapes; /*!< Number of shapes currently in existence */
};

/*! A class for representing a circle.
 \author Jack
 */
class Circle : public Shape {
private:
  double radius;
public:
  /*! Construct a circle
   *  \param r radius of the circle */
  Circle(double r);
  /*! Calculate the area of the circle
   *  \return calculated area */
  virtual double area();
  /*! Calculate the perimeter of the circle
   *  \return calculated perimeter of the circle */
  virtual double perimeter();
};

/// A class for representing a square.
class Square : public Shape {
private:
  double width;
public:
  /** Construct a square
   *  \param w width of the square */
  Square(double w);
  /** Calculate the area of the square
   *  \return calculated area */
  virtual double area();
  /** Calculate the perimeter of the square
   *  \return calculated perimeter of the square */
  virtual double perimeter();
};

/// A class for representing a rectangle, templated on the type for the rectangle dimensions
template<typename T>
class Rectangle : public Shape {
private:
  T height;
  T width;
public:
  /** Construct a rectangle
   *  \param h height of the rectangle
   *  \param w width of the rectangle */
  Rectangle(T h, T w) : height(h), width(w) {}
  /** Calculate the area of the rectangle
   *  \return calculated area */
  virtual double area() { return width*height; }
  /** Calculate the perimeter of the rectangle
   *  \return calculated perimeter of the rectangle */
  virtual double perimeter() { return 2*height + 2*width; }
};


/*! Factory function for creating a square
 *  \param r width of the square
 *  \return a fully constructed square */
Square MakeSquare(double r);

/*! Factory function for creating a circle
 *  \param w radius of the circle
 *  \return a fully constructed circle */
Circle MakeCircle(double w);

/*! Factory function for creating a rectangle
 *  \param h height of the rectangle
 *  \param w width of the rectangle
 *  \return a fully constructed rectangle */
template<typename T>
Rectangle<T> MakeRectangle(T h, T w) {
  return Rectangle<T>(h, w);
}



/*! Total number of circles ever created */
extern int NumCircles;

/// Total number of squares ever created
extern int NumSquares;


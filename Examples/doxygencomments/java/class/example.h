/*! \file example.h 
comments on example.h */

/*! This is describing class Shape
 \author Bob
 \exception some sort of exception
 \see OtherShapes()
 */

class Shape {
public:
  Shape() {
    nshapes++;
  }
  virtual ~Shape() {
    nshapes--;
  };
  double  x, y; /*!< Important variables  */
  void    move(double dx, double dy);
  virtual double area(void) = 0; /*!< \return the area \exception exception description */
  virtual double perimeter(void) = 0; /*!< \exception exception description 
					\return the perimeter */
  static  int nshapes; /*!< Details about nshapes. */
};
/*! This is describing class Circle */
class Circle : public Shape {
private:
  double radius;
public:
  Circle(double r) : radius(r) { };
  virtual double area(void); /*!< \return the area \exception exception description */
  virtual double perimeter(void); /*!< \exception exception description 
					\return the perimeter */
};

/*! This is describing class square */
class Square : public Shape {
private:
  double width;
public:
  Square(double w) : width(w) { }; /*!< Create square
					/param w the width
					/exception some description */
  virtual double area(void);
  virtual double perimeter(void);
};




  

(declare (unit precsi))
(declare (uses example))

(if (not (member "-quiet" (cdr (argv))))
    (begin
      ;; display prelude to csi
      (display "class\n\n")

      (display "  A SWIG example for the CHICKEN compiler\n")
      (display "  Author: Jonah Beckford, December 2002\n\n")

      (display "C++ Interface\n")
      (display "-------------\n")
      (display "
class Shape {
public:
  Shape();
  virtual ~Shape();
  double  x, y;   
  void    move(double dx, double dy);
  virtual double area(void) = 0;
  virtual double perimeter(void) = 0;
  static  int nshapes;
  enum SomeEnum {
    First = 0,
    Second,
    Third,
    Last = 1000
  };
};

class Circle : public Shape {
private:
  double radius;
public:
  Circle(double r);
  virtual double area(void);
  virtual double perimeter(void);
};

class Square : public Shape {
private:
  double width;
public:
  Square(double w);
  virtual double area(void);
  virtual double perimeter(void);
};
")

      (display "\n")

      (display "CHICKEN Low-Level Procedures\n")
      (display "----------------------------\n")
      (display "
  (define A-CIRCLE-SHAPE (example:new-Circle %radius))
  (example:Circle-area %circle)
  (example:Circle-perimeter %circle)
  (example:delete-Circle %circle)

  (define A-SQUARE-SHAPE (example:new-Square %width))
  (example:Square-area %square)
  (example:Square-perimeter %square)
  (example:delete-Square %square)

  (example:delete-Shape %shape)
  (example:Shape-x-set %shape %x)
  (example:Shape-x-get %shape)
  (example:Shape-y-set %shape %y)
  (example:Shape-y-get %shape)
  (example:Shape-move %shape %dx %dy)
  (example:Shape-area %shape)
  (example:Shape-perimeter %shape)
  (example:Shape-nshapes)
  (example:Shape-nshapes %nshapes-int)
  (example:Shape-First)
  (example:Shape-Second)
  (example:Shape-Third)
  (example:Shape-Last)
")

      (display "\n")

      (display "TinyCLOS Classes\n")
      (display "----------------\n")
      (display "
  ;; ALL generic methods must be included first
  (include \"example-generic\")
  ;; After generic methods are defined, can include TinyCLOS code
  (include \"example-clos\")

  (define A-CIRCLE-SHAPE (make <example:Circle> %radius))
  (-get-x- %shapeObject)
  (-set-x!- %shapeObject %x)
  (-get-y- %shapeObject)
  (-set-y!- %shapeObject %y)
  (-move!- %shapeObject %dx %dy)
  (-area- %shapeObject)
  (-perimeter- %shapeObject)
  (+example:Shape-nshapes+)
  (+example:Shape-nshapes+ %nshapes-int)
  ;; do not use (example:delete-Shape (slot-ref %shapeObject 'this))
  ;; as %shapeObject is always garbage-collected
")
      (display "\n")))

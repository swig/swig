/* File : template_classes.i */
/* Tests the use of one templated class within another */

%module template_classes

%{
%}

%inline %{

template <class T>
class Point {
public:
  T getX() {return x;}
private:
  T x;
};

template <class T>
class RectangleTest {
public:
  Point<T>& getPoint() {return point;}
  void setPoint(Point<T>& value) {point = value;}
private:
  Point<T> point;
};

%}

%template(PointInt) Point<int>;
%template(RectangleInt) RectangleTest<int>;



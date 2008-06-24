/* File : template_classes.i */
/* Tests the use of one templated class within another */

%module template_classes


#pragma SWIG nowarn=SWIGWARN_PARSE_NESTED_CLASS

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


  template <class Data>
  struct pair2nd_eq
  {
  };
  
  


  struct Foo : Point<int>
  {
  };
  
  Foo foo;
  
};

%}

%template(PointInt) Point<int>;
%template(RectangleInt) RectangleTest<int>;



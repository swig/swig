/* This test checks whether SWIG correctly parses the new constructor
   inheritance.
*/
%module cpp0x_inheriting_constructors

%inline %{
class BaseClass {
private:
  int _val;
public:
  BaseClass(int iValue) { _val = iValue; }
};

class DerivedClass: public BaseClass {
public:
  using BaseClass::BaseClass; // Adds DerivedClass(int) constructor
};
%}

%module method_overloads_with_free_overloads
%inline %{

void myPrint(double) {}
void myPrint(float) {}

void myPrint2(float) {}

void myPrint3(double) {}
void myPrint3(float) {}

namespace MyWorld {

  void myPrint(unsigned) {}

  void myPrint2(unsigned) {}

  void myPrint3(int) {}
  void myPrint3(unsigned) {}

}
%}



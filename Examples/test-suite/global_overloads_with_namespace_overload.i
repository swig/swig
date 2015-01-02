%module method_overloads_with_free_overload
%inline %{

void myPrint(double) {}
void myPrint(float) {}


namespace MyWorld {
  void myPrint(unsigned) {}
}

%}



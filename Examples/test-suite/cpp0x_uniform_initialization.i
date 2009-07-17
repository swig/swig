%module cpp0x_uniform_initialization

%inline %{
struct BasicStruct {
 int x;
 double y;
};
 
struct AltStruct {
  AltStruct(int x, double y) : x_{x}, y_{y} {}
 
private:
  int x_;
  double y_;
};
 
BasicStruct var1{5, 3.2}; // only fills the struct components
AltStruct var2{2, 4.3};   // calls the constructor

%}

%module valuewrapper_default

%inline %{
enum MyType { Val1, Val2 }; 
 
class MyClass1 
{ 
  public: 
  MyClass1(MyType myType) {}
}; 
 
class MyClass2 
{ 
  public : 
   void set(MyClass1 cl1 = Val1) {}
   // This could have been written : set(MyClass1 cl1 = MyClass1(Val1)) 
   // But it works in C++ since there is a "conversion" constructor in  MyClass1. 
};

%}

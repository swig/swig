%module test

%inline %{

class A { 
 public: 
  A() {} 
  
  void hello() 
    { 
    } 
}; 

class B : public A 
{ 
 public: 
  B() {} 
  
};

%}

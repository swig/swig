%module default_ns
%inline %{
namespace AType 
{ 
   enum AType 
   { 
      NoType 
   }; 
} 

void dummy(AType::AType aType = AType::NoType) {}


namespace A { 
  namespace B { 
    int CONST_NUM = 10; 
  } 
  int function(int i = B::CONST_NUM) { return 0; }
} 

%}

 

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
%}

 

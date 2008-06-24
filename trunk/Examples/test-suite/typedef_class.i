%module typedef_class

%inline %{ 
class RealA 
{ 
 public: 
   int a; 
}; 
 
class B 
{ 
 public: 
   typedef RealA A2; 
   int testA (const A2& a) {return a.a;} 
}; 
%} 

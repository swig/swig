%module conversion_ns_template
%{ 
 namespace oss 
 { 
   enum Test {One, Two}; 
   template <Test> 
   struct Foo { 
   }; 
   template <Test T>   
   struct Bar { 
     operator int() { return 0; }
     operator int&() { static int num = 0; return num; }
     operator Foo<T>() { return Foo<T>(); }
     operator Foo<T>&() { return *(new Foo<T>()); }
   }; 
  } 
%} 

 namespace oss 
 { 
   enum Test {One, Two}; 
 
   template <Test> 
   struct Foo { 
   }; 
 
   // these two works 
   %rename(hello1) Bar<One>::operator int&(); 
   %ignore Bar<One>::operator int(); 
 
   // these don't 
   %rename(hello2) Bar<One>::operator Foo<oss::One>&(); 
   %ignore Bar<One>::operator Foo<oss::One>(); 
 
   template <Test T>   
   struct Bar { 
     operator int(); 
     operator int&(); 
     operator Foo<T>(); 
     operator Foo<T>&(); 
   }; 
  } 

  
namespace oss 
{ 
  %template(Foo_One) Foo<One>; 
  %template(Bar_One) Bar<One>; 
} 

%module template_typedef_ptr

%inline %{
 struct C{};
 typedef C* pC;

 template <class A, class B>
   struct Test 
   {
     Test (A a, B b)
     {
     }
     
   };


 template <class A, class B>
   struct Test<A, B*> 
   {
     Test (A a, B* b)
     {
     }
     
   };
%}

  
%template(test_pC) Test<int, pC>;

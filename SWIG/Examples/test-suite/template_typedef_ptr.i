%module("tpltreduc") template_typedef_ptr

 /*
   Use the "tpltreduc" to force swig to reduce the temaplate
   typedef as much as possible.
   
   This fix cases like this one, but it can prevent some
   typemaps for working.

 */

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
     Test (B* a)
     {
     }
     
   };
%}

  
%template(test_pC) Test<int, pC>;

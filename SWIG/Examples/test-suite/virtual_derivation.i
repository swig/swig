%module virtual_derivation

 /*

 Try to add to your favorite language a runtime test like
 this:
 
 b = B(3)
 if (b.get_a() != b.get_b()):
     print "something is wrong"


 The test runs fine with python, but not with ruby.
 
 */

%inline %{

  struct A 
  {
    ~A()
    {
    }
    
    int _a;
    
    A(int a) :_a(a)
    {
    }
    
    int get_a()
    {
      return _a;
    }
    
  };
  
  struct B : virtual A
  {
    B(int a): A(a)
    {
    }
    
    int get_b()
    {
      return get_a();
    }

    // in ruby, get_a() returns trash if called from b, unless is
    // wrapped with the previous get_b or using the 'using'
    // declaration:
    // using A::get_a;
  };
%}

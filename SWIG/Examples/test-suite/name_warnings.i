%module name_warnings
/*
  This test should produce no warnings at all.

  It just show the cases where swig was showing unintended warnings
  before.

  Right now the test includes some cases for python, java and csharp.

*/

/* activate all the name warnings */
%warnfilter(+315,+321,-403);

%{
#ifdef max
#undef max
#endif
%}

%inline 
{
  class string; // csharp keyword
  class complex; // python built-in

  namespace std 
  {
    template <class T>
    class complex;
  }

  typedef complex None;  // python built-in
  
  struct A 
  {
    typedef complex None;
    
    A* clone(int) { return NULL; }
    
    virtual ~A() {}
    virtual int func() = 0;
  private:
     typedef complex False;
  };

  template <class T>
    T max (T a, T b) { // python 'max' built-in
    return a > b ? a : b;
  }  

  struct B : A
  {
    B() {}
  };
  
}

%template(max_i) max<int>;

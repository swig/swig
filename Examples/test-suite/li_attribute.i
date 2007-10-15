%module li_attribute

%include <exception.i>

//#define SWIG_ATTRIBUTE_TEMPLATE
%include <attribute.i>

%{
// forward reference needed if using SWIG_ATTRIBUTE_TEMPLATE
class A;
%}

%attribute(A, int, a, get_a, set_a);
%attribute_ref(A, int, b);

%attribute_ref(Param<int>, int, value);


%attribute(A, int, c, get_c);  /* read-only */
%attribute_ref(A, int, b, d);  /* different attribute name 'd' */

%attribute_ref(B, A*, a)

%inline
{
  struct A
  {
    A(int a, int b, int c) : _a(a), _b(b), _c(c)
    {
    }
    
    int get_a() const 
    {
      return _a;
    }
    
    void set_a(int aa) 
    {
      _a = aa;
    }

    /* only one ref method */
    int& b() 
    {
      return _b;
    }    

    int get_c() const 
    {
      return _c;
    }
  private:
    int _a;
    int _b;
    int _c;
  };

  template <class C>
  struct Param 
  {
    Param(C v) : _v(v)
    {
    }

    const int& value() const 
    {
      return _v;
    }
    
    int& value() 
    {
      return _v;
    }    
  private:
    C _v;
  }; 
  
  
  struct B {
    B(A *a) : mA(a)
    {
    }
    
    A*& a() { return mA; }
    
  protected:
    A*  mA;
  };
 
}

%template(Param_i) Param<int>;



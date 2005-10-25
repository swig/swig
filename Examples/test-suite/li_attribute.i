%module li_attribute

%include attribute.i

%attribute(A, int, a, get_a, set_a);
%attribute_ref(A, int, b);

%attribute_ref(Param<int>, int, value);


%attribute(A, int, c, get_c);  /* read-only */
%attribute_ref(A, int, b, d);  /* different attribute name 'd' */

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
    
    const int& b() const 
    {
      return _b;
    }
    
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
}

%template(Param_i) Param<int>;



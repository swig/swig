%module smart_pointer_inherit

%inline %{

  namespace hi
  {    
    struct Base 
    {
      Base(int i) : val(i) {}
      virtual ~Base() { }
      virtual int value() = 0;
      virtual int value2() { return val; }
      int valuehide() { return val; }
      int val;
    };    
    
    struct Derived : Base 
    {
      Derived(int i) : Base(i) {}
      virtual int value() { return val; }
      int valuehide() { return -1; }
    };

    template <typename T> struct SmartPtr
    {
      SmartPtr(T *t) : ptr(t) {}
      T * operator->() const { return ptr; }
    private:
      T *ptr;
    };
  }
%}

%template(SmartBase) hi::SmartPtr<hi::Base>;
%template(SmartDerived) hi::SmartPtr<hi::Derived>;


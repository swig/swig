%module smart_pointer_inherit

#ifdef SWIGCSHARP
// Test that the override is removed in the smart pointer for custom method modifiers
%csmethodmodifiers hi::Derived::value3 "/*csmethodmodifiers*/ public override";
#endif

%inline %{

  namespace hi
  {    
    struct Base 
    {
      Base(int i) : val(i) {}
      virtual ~Base() { }
      virtual int value() = 0;
      virtual int value2() { return val; }
      virtual int value3() { return val; }
      int valuehide() { return val; }
      int val;
    };    
    
    struct Derived : Base 
    {
      Derived(int i) : Base(i) {}
      virtual int value() { return val; }
      virtual int value3() { return Base::value3(); }
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


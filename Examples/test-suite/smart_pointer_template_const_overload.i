%module smart_pointer_template_const_overload

%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED) SmartPointer<FooImplementation>::operator->;      // Overloaded method SmartPointer< FooImplementation >::operator ->() ignored

%inline %{
  template <class T> class SmartPointer {
    T *ptr;
  public:
    SmartPointer(T *t = 0) : ptr(t) {}
    inline const T * operator->() const { return ptr; }
    inline T * operator->() { return ptr; }
  };

  class FooImplementation {
  public:
    int mingy() {}
    int constmingy() const {}
    static int thingy() {}
    static int svariable;
    static const int constsvariable;
    int normalvariable;
  };
  int FooImplementation::svariable = 0;
  const int FooImplementation::constsvariable = 2;

  void tester() {
    SmartPointer<FooImplementation> p;
    p->mingy();
    p->constmingy();
    p->thingy();
    int a = p->svariable;
    a = p->constsvariable;
    a = p->normalvariable;
  }
%}

%template(FooSmartPointer) SmartPointer<FooImplementation>;

%module extend

%extend Base {
  ~Base() {
    delete $self;
  }
  static int zeroVal() {
    return 0;
  }
  virtual int currentValue() {
    return $self->value;
  }
  int extendmethod(int v) {
    int ret = $self->method(v);
    return ret * 2;
  }
};

%inline %{
struct Base {
  Base(int v = 0) : value(v) {}
  int value;
  virtual int method(int v) {
    return v;
  }
#if !defined(SWIG)
  virtual ~Base() {}
#endif
};
struct Derived : Base {
  double actualval;
};
%}

#ifdef SWIGFORTRAN
%inline %{
#define GETTER(CLS, VALUE) get_ ## CLS ## _ ## VALUE
#define SETTER(CLS, VALUE) set_ ## CLS ## _ ## VALUE
%}
#else
%inline %{
#define GETTER(CLS, VALUE) CLS ## _ ## VALUE ## _get
#define SETTER(CLS, VALUE) CLS ## _ ## VALUE ## _set
%}
#endif

%{
  double extendval = 0;
  double GETTER(Derived,extendval)(Derived *self) {
    return self->actualval * 100;
  }
  void SETTER(Derived,extendval)(Derived *self, double d) {
    self->actualval = d/100;
  }
%}

%extend Derived {
  Derived(int v) {
    Derived *$self = new Derived();
    $self->value = v*2;
    return $self;
  }
  virtual int method(int v) {
    int ret = $self->Base::method(v);
    return ret * 2;
  }
  double extendval;
}

%module template_nested_typemaps

template <typename T> struct Typemap {
  %typemap(in) T {
    $1 = -99;
  }
};

%inline %{
int globalInt1(int s) { return s; }

template <typename T> struct Breeze {
  int methodInt1(int s) { return s; }
#if defined(SWIG)
  %template() Typemap<int>;
#endif
  int methodInt2(int s) { return s; } // only this method should pick up the typemap within Typemap<int>
  void takeIt(T t) {}
};

int globalInt2(int s) { return s; }
%}

%template(BreezeString) Breeze<const char *>;

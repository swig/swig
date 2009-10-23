#pragma SWIG nowarn=SWIGWARN_PARSE_NESTED_TEMPLATE

%module template_nested_typemaps

template <typename T> struct Typemap {
  %typemap(in) T {
    $1 = -99;
  }
};
template <> struct Typemap<short> {
  %typemap(in) short {
    $1 = -77;
  }
};

%inline %{
int globalInt1(int s) { return s; }
short globalShort1(short s) { return s; }

template <typename T> struct Breeze {
  int methodInt1(int s) { return s; }
#if defined(SWIG)
  %template() Typemap<int>;
#endif
  int methodInt2(int s) { return s; } // only this method should pick up the typemap within Typemap<int>
  void takeIt(T t) {}

  short methodShort1(short s) { return s; }
#if defined(SWIG)
  %template(TypemapShort) Typemap<short>; // should issue warning SWIGWARN_PARSE_NESTED_TEMPLATE
#endif
  short methodShort2(short s) { return s; } // only this method should pick up the typemap within Typemap<short> - note specialization
};

int globalInt2(int s) { return s; }
short globalShort2(short s) { return s; }
%}

%template(BreezeString) Breeze<const char *>;

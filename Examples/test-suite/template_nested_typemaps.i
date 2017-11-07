%module template_nested_typemaps

#pragma SWIG nowarn=SWIGWARN_PARSE_NAMED_NESTED_CLASS

// Testing that the typemaps invoked within a class via %template are picked up by appropriate methods
// Only for languages that support nested classes

%inline %{
int globalInt1(int s) { return s; }
short globalShort1(short s) { return s; }

template <typename T> struct Breeze {
  template <typename TMT> struct Typemap {
#ifdef SWIG
    %typemap(in) TMT {
      $1 = -99;
    }
#endif
  };
  template <typename TMT> struct TypemapShort {
#ifdef SWIG
    %typemap(in) short {
      $1 = -77;
    }
#endif
  };

  int methodInt1(int s) { return s; }
#if defined(SWIG)
  %template() Typemap<int>;
#endif
  int methodInt2(int s) { return s; } // should pick up the typemap within Typemap<int>
  void takeIt(T t) {}

  short methodShort1(short s) { return s; }
#if defined(SWIG)
  %template() TypemapShort<short>;
#endif
  short methodShort2(short s) { return s; } // should pick up the typemap within Typemap<short>
};

int globalInt2(int s) { return s; }
short globalShort2(short s) { return s; }
%}

%template(BreezeString) Breeze<const char *>;

%inline %{
int globalInt3(int s) { return s; } // should pick up the typemap within Typemap<int>
short globalShort3(short s) { return s; } // should pick up the typemap within Typemap<short>
%}


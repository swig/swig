%module extend_variable

// Tests %extend for variables

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


%inline %{
class ExtendMe {
  double var;
public:
  ExtendMe() : var(0.0) {}
  bool get(double &d) {
    d = var;
    return true;
  }
  bool set(const double &d) {
    var = d;
    return true;
  }
};
%}

%extend ExtendMe {
  double ExtendVar;
};

%{
// If possible, all language modules should use this naming format for consistency
void SETTER(ExtendMe,ExtendVar)(ExtendMe *thisptr, double value) {
  thisptr->set(value);
}
double GETTER(ExtendMe,ExtendVar)(ExtendMe *thisptr) {
  double value = 0;
  thisptr->get(value);
  return value;
}
%}


%{
  class Foo
  {
  };
%}

#if SWIGJAVA
%javaconst(1) AllBarOne;
#elif SWIGCSHARP
%csconst(1) AllBarOne;
#endif


class Foo {
  public:
    %extend {
        static const int Bar = 42;
        static const int AllBarOne = 4422;
        static const int StaticConstInt;
        static int StaticInt;
    }
};

%{
  int globalVariable = 1111;

  void SETTER(Foo,StaticInt)(int value) {
    globalVariable = value;
  }

  int GETTER(Foo,StaticInt)() {
    return globalVariable;
  }

  int GETTER(Foo,StaticConstInt)() {
    static int var = 2222;
    return var;
  }
%}

%inline {
  namespace ns1
  {
    struct Bar
    {
    }
    ;
  }
}

%{
  int GETTER(ns1_Bar,x)(ns1::Bar *self) {
    return 1;
  }

  void SETTER(ns1_Bar,x)(ns1::Bar *self, int x) {
  }
%}

%extend ns1::Bar
{
  int x;
}




%module xxx

// Test the SWIG preprocessor locator effects on reporting line numbers in warnings when processing SWIG (multiline) macros

// The ignored overloaded methods warnings should have the correct line number reporting
// {} blocks are tested, where the preprocessor expands the macros

%define CLASSMACRO(KLASS)
class KLASS
{
public:
  KLASS() {}
  void methodX(int *) {}
  void methodX(const int *) {}
};
%enddef

%{
#define CLASSMACRO(KLASS) \
class KLASS \
{ \
public: \
  KLASS() {} \
  void methodX(int *) {} \
  void methodX(const int *) {} \
};
%}

%{
#define VARIABLEMACRO(NAME) double NAME;
struct Outer {
  struct Inner {
    VARIABLEMACRO(MyInnerVar)
  };
};
void overload1(int *) {}
void overload1(const int *) {}
void overload2(int *) {}
void overload2(const int *) {}
void overload3(int *) {}
void overload3(const int *) {}
%}

%define VARIABLEMACRO(NAME)
double NAME;
%enddef
struct Outer {
  struct Inner {
    VARIABLEMACRO(MyInnerVar)
  };
};
void overload1(int *) {}
void overload1(const int *) {}

%fragment("FragmentMethod", "header") {
void fragmentMethod() {
}
VARIABLEMACRO(fragVar)
}
void overload2(int *) {}
void overload2(const int *) {}

%inline {
CLASSMACRO(Klass1)
}
#warning inline warning message one
void overload3(int *) {}
void overload3(const int *) {}

%{
struct Classic {
  Classic() {
    VARIABLEMACRO(inconstructor)
  }
  double value;
};
void overload4(int *) {}
void overload4(const int *) {}
void overload5(int *) {}
void overload5(const int *) {}
%}

struct Classic {
  Classic() {
    VARIABLEMACRO(inconstructor)
  }
  double value;
};
void overload4(int *) {}
void overload4(const int *) {}

%inline {
void overloadinline1(int *) {}
void overloadinline1(const int *) {}
CLASSMACRO(Klass2)
#warning an inline warning message 2
void overloadinline2(int *) {}
void overloadinline2(const int *) {}
}
void overload5(int *) {}
void overload5(const int *) {}

%ignore Outer2::QuietInner;
struct Outer2 {
  struct QuietInner {
    VARIABLEMACRO(MyInnerVar)
  };
};

// A macro expanding to a new-expression used as a default argument and as an initialiser
%define NEWDOUBLE(VALUE)
new double(VALUE)
%enddef
void newdefault(double *p = NEWDOUBLE(1.5));
double *const newconst = NEWDOUBLE(2.5);
void overload6(int *) {}
void overload6(const int *) {}

// The same within another macro
%define DECLARE_NEWDOUBLE(NAME, VALUE)
double *const NAME = NEWDOUBLE(VALUE);


%enddef
DECLARE_NEWDOUBLE(newnested, 3.5)
void overload7(int *) {}
void overload7(const int *) {}

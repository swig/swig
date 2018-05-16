%module member_funcptr_galore

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) extra2;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) extra3;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) pp2;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) pp3;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) pp5;

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) ccextra2;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) ccextra3;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) cc2;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) cc3;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) cc5;

%{
#if defined(__SUNPRO_CC)
#pragma error_messages (off, badargtype2w) /* Formal argument ... is being passed extern "C" ... */
#pragma error_messages (off, wbadinit) /* Using extern "C" ... to initialize ... */
#pragma error_messages (off, wbadasg) /* Assigning extern "C" ... */
#endif
%}

%inline %{

namespace FunkSpace {
struct Funktions {
  int addByValue(const int &a, int b) { return a+b; }
  int * addByPointer(const int &a, int b) { static int val; val = a+b; return &val; }
  int & addByReference(const int &a, int b) { static int val; val = a+b; return val; }
};
}

template <typename T> struct Thing {};
namespace Space {
class Shape {
public:
  double  x, y;   
  double  *z;

  void    move(double dx, double dy);
  virtual double area(Shape &ref, int & (FunkSpace::Funktions::*d)(const int &, int)) { return 0.0; }
  virtual double area_const(Shape &ref, int & (FunkSpace::Funktions::*)(const int &, int) const) { return 0.0; } // Note: unnamed parameter
  virtual double zyx(int (FunkSpace::Funktions::*)() const) { return 0.0; } // Note: unnamed parameter
  virtual double abc(Thing<short> ts, Thing< const Space::Shape * > tda[]) { return 0.0; }
  virtual ~Shape() {}
};
}

extern double do_op(Space::Shape *s, double (Space::Shape::*m)(void));

/* Functions that return member pointers */

extern double (Space::Shape::*areapt())(Space::Shape &, int & (FunkSpace::Funktions::*)(const int &, int));
extern double (Space::Shape::*abcpt())(Thing<short>, Thing< const Space::Shape * > tda[]);

/* Global variables that are member pointers */
extern double (Space::Shape::*areavar)(Space::Shape &, int & (FunkSpace::Funktions::*)(const int &, int));
extern double (Space::Shape::*abcvar)(Thing<short>, Thing< const Space::Shape * >[]);

%}

%{
void Space::Shape::move(double dx, double dy) {
  x += dx;
  y += dy;
}

double do_op(Space::Shape *s, double (Space::Shape::*m)(void)) {
  return (s->*m)();
}

double do_op_const(Space::Shape *s, double (Space::Shape::*m)(void) const) {
  return (s->*m)();
}

double (Space::Shape::*areapt(Space::Shape &ref, int & (FunkSpace::Funktions::*d)(const int &, int)))(Space::Shape &, int & (FunkSpace::Funktions::*d)(const int &, int)) {
  return &Space::Shape::area;
}

double (Space::Shape::*areapt())(Space::Shape &, int & (FunkSpace::Funktions::*)(const int &, int)) {
  return 0;
}

double (Space::Shape::*abcpt())(Thing<short>, Thing< const Space::Shape * >[]) {
  return &Space::Shape::abc;
}

/* Member pointer variables */
double (Space::Shape::*areavar)(Space::Shape &, int & (FunkSpace::Funktions::*)(const int &, int)) = &Space::Shape::area;
double (Space::Shape::*abcvar)(Thing<short>, Thing< const Space::Shape * >[]) = &Space::Shape::abc;
%}


/* Some constants */
%constant double (Space::Shape::*AREAPT)(Space::Shape &, int & (FunkSpace::Funktions::*)(const int &, int)) = &Space::Shape::area;
%constant double (Space::Shape::*AREAPT_CONST)(Space::Shape &, int & (FunkSpace::Funktions::*)(const int &, int) const) = &Space::Shape::area_const;
%constant double (Space::Shape::*PERIMPT)(Thing<short>, Thing< const Space::Shape * >[]) = &Space::Shape::abc;
%constant double (Space::Shape::*NULLPT)(void) = 0;

%inline %{

int call1(int (FunkSpace::Funktions::*d)(const int &, int), int a, int b) { FunkSpace::Funktions f; return (f.*d)(a, b); }
int call2(int * (FunkSpace::Funktions::*d)(const int &, int), int a, int b) { FunkSpace::Funktions f; return *(f.*d)(a, b); }
int call3(int & (FunkSpace::Funktions::*d)(const int &, int), int a, int b) { FunkSpace::Funktions f; return (f.*d)(a, b); }
%}

%constant int (FunkSpace::Funktions::*ADD_BY_VALUE)(const int &, int) = &FunkSpace::Funktions::addByValue;
%constant int * (FunkSpace::Funktions::*ADD_BY_POINTER)(const int &, int) = &FunkSpace::Funktions::addByPointer;
%constant int & (FunkSpace::Funktions::*ADD_BY_REFERENCE)(const int &, int) = &FunkSpace::Funktions::addByReference;

%inline %{
// parameter that is a member pointer containing a function ptr, urgh :)
int unreal1(double (Space::Shape::*memptr)(Space::Shape &, int & (FunkSpace::Funktions::*)(const int &, int))) { return 0; }
int unreal2(double (Space::Shape::*memptr)(Thing<short>)) { return 0; }
%}


%inline %{
struct Funcs {
  short FF(bool) { return 0; }
  short CC(bool) const { return 0; }
};

class MemberFuncPtrs
{
public:
    // member const function pointers, unnamed parameters
    int aaa1(short (Funcs::* )(bool) const) const;
    int aaa2(short (Funcs::* const *&)(bool) const) const;
    int aaa3(short (Funcs::* *& )(bool) const) const;
    int aaa4(short (Funcs::* *const& )(bool) const) const;
    int aaa5(short (Funcs::* & )(bool) const) const;
    int aaa6(short (Funcs::* const)(bool) const) const;
    int aaa7(short (Funcs::* const&)(bool) const) const;

    // member non-const function pointers, unnamed parameters
    int bbb1(short (Funcs::* )(bool)) const;
    int bbb2(short (Funcs::* const *&)(bool)) const;
    int bbb3(short (Funcs::* *& )(bool)) const;
    int bbb4(short (Funcs::* *const& )(bool)) const;
    int bbb5(short (Funcs::* & )(bool)) const;
    int bbb6(short (Funcs::* const)(bool)) const;
    int bbb7(short (Funcs::* const&)(bool)) const;

    // member const function pointers, named parameters
    int ppp1(short (Funcs::* pp1)(bool) const) const;
    int ppp2(short (Funcs::* const *& pp2)(bool) const) const;
    int ppp3(short (Funcs::* *& pp3)(bool) const) const;
    int ppp4(short (Funcs::* *const& pp4)(bool) const) const;
    int ppp5(short (Funcs::* & pp5)(bool) const) const;
    int ppp6(short (Funcs::* const pp6)(bool) const) const;
    int ppp7(short (Funcs::* const& pp7)(bool) const) const;

    // member non-const function pointers, named parameters
    int qqq1(short (Funcs::* qq1)(bool)) const;
    int qqq2(short (Funcs::* const *& qq2)(bool)) const;
    int qqq3(short (Funcs::* *& qq3)(bool)) const;
    int qqq4(short (Funcs::* *const& qq4)(bool)) const;
    int qqq5(short (Funcs::* & qq5)(bool)) const;
    int qqq6(short (Funcs::* const qq6)(bool)) const;
    int qqq7(short (Funcs::* const& qq7)(bool)) const;
};

// member const function pointers, unnamed parameters
int MemberFuncPtrs::aaa1(short (Funcs::* )(bool) const) const { return 0; }
int MemberFuncPtrs::aaa2(short (Funcs::* const *&)(bool) const) const { return 0; }
int MemberFuncPtrs::aaa3(short (Funcs::* *& )(bool) const) const { return 0; }
int MemberFuncPtrs::aaa4(short (Funcs::* *const& )(bool) const) const { return 0; }
int MemberFuncPtrs::aaa5(short (Funcs::* & )(bool) const) const { return 0; }
int MemberFuncPtrs::aaa6(short (Funcs::* const)(bool) const) const { return 0; }
int MemberFuncPtrs::aaa7(short (Funcs::* const&)(bool) const) const { return 0; }

// member non-const function pointers, unnamed parameters
int MemberFuncPtrs::bbb1(short (Funcs::* )(bool)) const { return 0; }
int MemberFuncPtrs::bbb2(short (Funcs::* const *&)(bool)) const { return 0; }
int MemberFuncPtrs::bbb3(short (Funcs::* *& )(bool)) const { return 0; }
int MemberFuncPtrs::bbb4(short (Funcs::* *const& )(bool)) const { return 0; }
int MemberFuncPtrs::bbb5(short (Funcs::* & )(bool)) const { return 0; }
int MemberFuncPtrs::bbb6(short (Funcs::* const)(bool)) const { return 0; }
int MemberFuncPtrs::bbb7(short (Funcs::* const&)(bool)) const { return 0; }

// member const function pointers, named parameters
int MemberFuncPtrs::ppp1(short (Funcs::* pp1)(bool) const) const { return 0; }
int MemberFuncPtrs::ppp2(short (Funcs::* const *& pp2)(bool) const) const { return 0; }
int MemberFuncPtrs::ppp3(short (Funcs::* *& pp3)(bool) const) const { return 0; }
int MemberFuncPtrs::ppp4(short (Funcs::* *const& pp4)(bool) const) const { return 0; }
int MemberFuncPtrs::ppp5(short (Funcs::* & pp5)(bool) const) const { return 0; }
int MemberFuncPtrs::ppp6(short (Funcs::* const pp6)(bool) const) const { return 0; }
int MemberFuncPtrs::ppp7(short (Funcs::* const& pp7)(bool) const) const { return 0; }

// member non-const function pointers, named parameters
int MemberFuncPtrs::qqq1(short (Funcs::* qq1)(bool)) const { return 0; }
int MemberFuncPtrs::qqq2(short (Funcs::* const *& qq2)(bool)) const { return 0; }
int MemberFuncPtrs::qqq3(short (Funcs::* *& qq3)(bool)) const { return 0; }
int MemberFuncPtrs::qqq4(short (Funcs::* *const& qq4)(bool)) const { return 0; }
int MemberFuncPtrs::qqq5(short (Funcs::* & qq5)(bool)) const { return 0; }
int MemberFuncPtrs::qqq6(short (Funcs::* const qq6)(bool)) const { return 0; }
int MemberFuncPtrs::qqq7(short (Funcs::* const& qq7)(bool)) const { return 0; }

// member non-const function pointer variables
short (Funcs::* pp1)(bool) = &Funcs::FF;

short (Funcs::* const * extra2)(bool) = &pp1;
short (Funcs::* * extra3)(bool) = &pp1;
short (Funcs::* *const extra4)(bool) = &pp1;

short (Funcs::* const *& pp2)(bool) = extra2;
short (Funcs::* *& pp3)(bool) = extra3;
short (Funcs::* *const& pp4)(bool) = extra4;
short (Funcs::* & pp5)(bool) = pp1;
short (Funcs::* const pp6)(bool) = &Funcs::FF;
short (Funcs::* const& pp7)(bool) = pp1;

// member const function pointer variables
short (Funcs::* cc1)(bool) const = &Funcs::CC;

short (Funcs::* const * ccextra2)(bool) const = &cc1;
short (Funcs::* * ccextra3)(bool) const = &cc1;
short (Funcs::* *const ccextra4)(bool) const = &cc1;

short (Funcs::* const *& cc2)(bool) const = ccextra2;
short (Funcs::* *& cc3)(bool) const = ccextra3;
short (Funcs::* *const& cc4)(bool) const = ccextra4;
short (Funcs::* & cc5)(bool) const = cc1;
short (Funcs::* const cc6)(bool) const = &Funcs::CC;
short (Funcs::* const& cc7)(bool) const = cc1;
%}

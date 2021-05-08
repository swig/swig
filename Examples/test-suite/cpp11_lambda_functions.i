/* This testcase checks whether SWIG correctly parses the lambda expressions
   and closure syntax introduced in C++11.
   SWIG supports only lambda syntax and doesn't produce any wrapper code for
   this.
*/
%module cpp11_lambda_functions

%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda1;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda2;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda3;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda4;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda5;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda6;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda7;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda8;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda9;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda10;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda11;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda12;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda13;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda14;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda15;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda16;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda17;
%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda18;
%warnfilter(SWIGWARN_CPP11_LAMBDA) Space1::lambda19;
%warnfilter(SWIGWARN_CPP11_LAMBDA) Space1::Space2::lambda20;

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW0() throw()
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW0()
#define TESTCASE_THROW1(T1)
%}

%inline %{
/* Defined lambda function with return value. */
auto lambda1 = [](int x, int y) -> int { return x+y; };

/* Defined lambda function without return value.
   Return value is calculated by compiler, if the function contains a
   single statement "return expr;". */
auto lambda2 = [](int x, int y) { return x+y; };

int thing = 0;
#ifdef SWIG
// This is not strictly legal: non-local lambda expression cannot have a capture-default
// gcc-4.7 warns about this and gcc-9 gives an error, but we check that SWIG can parse this anyway.
auto lambda3 = [&](int x, int y) { return x+y; };
auto lambda4 = [=](int x, int y) { return x+y; };
auto lambda5 = [=,&thing]() { return thing; };
#else
auto lambda3 = [](int x, int y) { return x+y; };
auto lambda4 = [](int x, int y) { return x+y; };
auto lambda5 = []() { return thing; };
#endif

void fn1() {
  int stuff = 0;
  auto lambdaxxxx = [=,&stuff]() { return thing; };
}
auto lambda6 = [] (int a, int b) mutable { return a + b; };
auto lambda7 = [] (int x, int y) -> int { return x+y; };
auto lambda8 = [] (int x, int y) TESTCASE_THROW0() -> int { return x+y; };
auto lambda9 = [] (int x, int y) mutable TESTCASE_THROW0() -> int { return x+y; };
auto lambda10 = [] (int x, int y) TESTCASE_THROW1(int) { return x+y; };
auto lambda11 = [] (int x, int y) mutable TESTCASE_THROW1(int) { return x+y; };
auto lambda12 = [] (int a, int b) { return a + b; }(1, 2);
auto lambda13 = [] (int a, int b) mutable { return a + b; }(1, 2);
auto lambda14 = [] () TESTCASE_THROW0() {};
auto lambda15 = [] () mutable TESTCASE_THROW0() {};
auto lambda16 = [] { return thing; };
auto lambda17 = [] { return thing; }();
#if defined(SWIG) || (defined(__cplusplus) && __cplusplus >= 201703L)
#define CONSTEXPR constexpr
#else
#define CONSTEXPR
#endif
CONSTEXPR auto lambda18 = [] (int x, int y) mutable TESTCASE_THROW1(int) { return x+y; };

namespace Space1 {
  CONSTEXPR auto lambda19 = [] (int x, int y) mutable TESTCASE_THROW1(int) { return x+y; };
  namespace Space2 {
    CONSTEXPR auto lambda20 = [] (int x, int y) mutable TESTCASE_THROW1(int) { return x+y; };
  }
}

int runLambda1() {
  return lambda1(5,6);
}

int runLambda2() {
  return lambda2(5,6);
}

int runLambda3() {
  return lambda3(5,6);
}

int runLambda4() {
  return lambda4(5,6);
}

int runLambda5() {
  thing++;
  return lambda5();
}

/* Inline defined lambda function. */
int runLambdaInline() {
  auto myLambda = [](int x, int y) { return x+y; };
  return myLambda(5,6);
}
%}

%{
// TODO
int(*lambda101notauto)(int, int) = [] (int a, int b) { return a + b; };
int lambda102 = [] (int a, int b) mutable { return a + b; }(1, 2);
void lambda_init(int = ([]{ return 0; })());
%}


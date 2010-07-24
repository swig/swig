/* This testcase checks whether SWIG correctly parses the lambda expressions
   and closure syntax introduced in C++0x.
   SWIG supports only lambda syntax and doesn't produce any wrapper code for
   this.
*/
%module cpp0x_lambda_functions

#pragma SWIG nowarn=SWIGWARN_LANG_NATIVE_UNIMPL

%inline %{
/* Defined lambda function with return value. */
auto lambda1 = [](int x, int y) -> int { return x+y; };

/* Defined lambda function without return value.
   Return value is calculated by compiler, if the function contains a
   single statement "return expr;". */
auto lambda2 = [](int x, int y) { return x+y; };

auto lambda3 = [&](int x, int y) { return x+y; };
auto lambda4 = [=](int x, int y) { return x+y; };
int thing = 0;
auto lambda5 = [=,&thing]() { return thing;};

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


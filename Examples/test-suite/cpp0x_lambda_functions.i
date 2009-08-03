/* This testcase checks whether Swig correctly parses the lambda expressions
   and closure syntax introduced in C++0x.
   Swig supports only lambda syntax and doesn't produce any wrapper code for
   this.
*/
%module cpp0x_lambda_functions

%inline %{
struct A {
        /* Defined lambda function with return value. */
        auto lambda1 = [](int x, int y) -> int { return x+y; };
        
        /* Defined lambda function without return value.
           Return value is calculated by compiler, if the function contains a
           single statement "return expr;". */
        auto lambda2 = [](int x, int y) { return x+y; };
};

int runLambda1() {
        A myA;
        return myA.lambda1(5,6);
}

int runLambda2() {
        A myA;
        return myA.lambda2(5,6);
}

/* Inline defined lambda function. */
int runLambda3() {
        auto myLambda = [](int x, int y) { return x+y; };
        return myLambda(5,6);
}
%}

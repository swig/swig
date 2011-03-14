%module overload_return_type

// Regression test for PHP from SF#3168531 (SWIG <= 2.0.1 segfaults).

%inline %{

#include <string>
using namespace std;
class A { };
class B {
    public:
        int foo(int x);
        A foo(string y);
};
%}

%{
int B::foo(int x) { return 0; }
A B::foo(string y) { return A(); }
%}

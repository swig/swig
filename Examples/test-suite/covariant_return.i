%module covariant_return

// Regression test for PHP from SF#3168531i (SWIG <= 2.0.1 segfaults).

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

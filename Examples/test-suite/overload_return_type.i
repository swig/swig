%module overload_return_type

// Regression test for PHP from SF#3168531 (SWIG <= 2.0.1 segfaults).

%inline %{

class A { };
class B {
    public:
        int foo(int x) { return 0; }
        A foo(const char * y) { return A(); }
};
%}

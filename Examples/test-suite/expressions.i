%module expressions

%inline %{
struct A
{
    A() : k( 20/(5-1) ) {}
    A(int i) : k( 20/(5-1)*i /* comment */ ) {}
    int k;
    // Regression test for preprocessor bug with handling a slash immediately
    // followed by a single quote, fixed in 4.2.0.  (#2630)
    int f(int i = 64/' ') { return i; }
};
%}

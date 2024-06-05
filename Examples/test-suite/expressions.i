%module expressions

%inline %{
#if defined(_MSC_VER)
  #include <iso646.h> // for alternative operator names, e.g. 'compl'
#endif

struct A
{
    A() : k( 20/(5-1) ) {}
    A(int i) : k( 20/(5-1)*i /* comment */ ) {}
    int k;
    // Regression test for preprocessor bug with handling a slash immediately
    // followed by a single quote, fixed in 4.2.0.  (#2630)
    int f(int i = 64/' ') { return i; }

    // Regression test for alternative operator names - this failed to parse in
    // SWIG 4.2.0 and earlier.
    int g(bool b = (compl 1 or not 2) xor (3 and 4) xor (3 bitand 6) xor (3 bitor 5) xor (2 + 2 not_eq 5)) { return (int)b; }
};
%}

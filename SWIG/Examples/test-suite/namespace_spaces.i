%module namespace_spaces
%inline %{

class Foo {
public:
    typedef int Integer;
    int blah(int x);
    int spam(int x);
    Integer bar(Integer x);
};

inline int Foo 
::blah(int x) { return 2*x; }

inline int Foo :: spam(int x) { return -x; }

inline Foo :: Integer Foo :: bar(Foo :: Integer x) { return x; }

%}

%module template_static

%inline %{
template<class T> class foo {
public:
    static int test;
};
%}

%template(foo_i) foo<int>;
%template(foo_d) foo<double>;


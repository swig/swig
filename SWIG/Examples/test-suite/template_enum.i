%module template_enum

%inline %{
template<class T> class foo {
public:
    enum { FOO, BAR };
};
%}

%template(foo_i) foo<int>;
%template(foo_d) foo<double>;


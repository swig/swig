%module template_enum

%warnfilter(801) foo<int>;    /* Ruby, wrong class name */
%warnfilter(801) foo<double>; /* Ruby, wrong class name */

%inline %{
template<class T> class foo {
public:
    enum { FOO, BAR };
};
%}

%template(foo_i) foo<int>;
%template(foo_d) foo<double>;


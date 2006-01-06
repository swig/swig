%module template_enum

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) foo<int>;    /* Ruby, wrong class name */
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) foo<double>; /* Ruby, wrong class name */

%inline %{
template<class T> class foo {
public:
    enum { FOO, BAR };
};
%}

%template(foo_i) foo<int>;
%template(foo_d) foo<double>;


%module template_static

%warnfilter(801) foo<int>;    /* Ruby, wrong class name */
%warnfilter(801) foo<double>; /* Ruby, wrong class name */

%inline %{
template<class T> class foo {
public:
    static int test;
};
template<class T> int foo<T>::test = 0;
%}

%template(foo_i) foo<int>;
%template(foo_d) foo<double>;


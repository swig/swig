%module fortran_ownership

%{
#include "boost/shared_ptr.hpp"
%}

%copyctor Foo;
%copyctor Bar;

%include <boost_shared_ptr.i>
%shared_ptr(Bar)

%inline %{
struct Foo {
    int val;
    /* constructor: */
    Foo(int val_) : val(val_) {}
};

Foo& reference(Foo& other) { return other; }

struct Bar {
    int val;
    /* constructor: */
    Bar(int val_) : val(val_) {}
};

boost::shared_ptr<Bar> share(boost::shared_ptr<Bar> other) { return other; }
int use_count(const boost::shared_ptr<Bar>& sp) { return sp.use_count(); }
%}

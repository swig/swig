/* This test a return by value constant SWIGTYPE.
It was reported in bug 899332 by Jermey Brown (jhbrown94) */

%module return_const_value

%inline %{

class Foo {
public:
    int _val;
    Foo(int x): _val(x) {}
    int getVal() const {
        return _val;
    }
};

class Foo_ptr {
    Foo *_ptr;
public:
    Foo_ptr(Foo *p): _ptr(p) {}
    static Foo_ptr getPtr() {
        return Foo_ptr(new Foo(17));
    }
    static const Foo_ptr getConstPtr() {
        return Foo_ptr(new Foo(17));
    }
    const Foo *operator->() {
        return _ptr;
    }
};

%}

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

class FooPtr {
    Foo *_ptr;
public:
    FooPtr(Foo *p): _ptr(p) {}
    static FooPtr getPtr() {
        return FooPtr(new Foo(17));
    }
    static const FooPtr getConstPtr() {
        return FooPtr(new Foo(17));
    }
    const Foo *operator->() {
        return _ptr;
    }
};

%}

%module abstract_inherit_ok

%feature("notabstract") Spam;

%inline %{

class Foo {
public:
    virtual int blah() = 0;
};

class Spam: public Foo {
public:
   Spam() { }
#ifndef SWIG
   int blah() { return 0; }
#endif
};

%}

%module abstract_inherit

%inline %{

class Foo {
public:
    virtual int blah() = 0;
};

class Bar : public Foo { };

class Spam: public Foo {
public:
   Spam() { }
};

%}

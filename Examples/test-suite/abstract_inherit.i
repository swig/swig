%module abstract_inherit

%warnfilter(403) Spam;
%warnfilter(403) Bar;

%inline %{

class Foo {
public:
  virtual ~Foo()
  {
  }
  
  virtual int blah() = 0;
};

class Bar : public Foo { };

class Spam: public Foo {
public:
   Spam() { }
};

%}

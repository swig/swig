// Inheritance through a typedef name
%module typedef_inherit

%inline %{
class Foo {
public:
     virtual char *blah() {
	return (char *) "Foo::blah";
     }
};

typedef Foo FooObj;

class Bar : public FooObj {
 public:
  virtual char *blah() {
    return (char *) "Bar::blah";
  };
};

char *do_blah(FooObj *f) {
  return f->blah();
}

%}

%module class_ignore

%ignore Foo;

%inline %{
class Foo {
public:
   virtual ~Foo() { }
   virtual char *blah() = 0;
};

class Bar : public Foo {
public:
   virtual char *blah() { return (char *) "Bar::blah"; }
};

char *do_blah(Foo *f) {
   return f->blah();
}
%}


// Tests handling of inheritance when a base class isn't provided to SWIG
%module inherit_missing

%{
/* Define the class internally, but don't tell SWIG about it */
class Foo {
public:
     virtual char *blah() {
	return (char *) "Foo::blah";
     }
};
%}

%echo "*** inherit_missing: A warning message about class 'Foo' is expected."

%inline %{

class Bar : public Foo {
 public:
  virtual char *blah() {
    return (char *) "Bar::blah";
  };
};

class Spam : public Bar {
  public:
  virtual char *blah() {
    return (char *) "Spam::blah";
  };
};

Foo *new_Foo() {
   return new Foo();
}

char *do_blah(Foo *f) {
  return f->blah();
}
%}
